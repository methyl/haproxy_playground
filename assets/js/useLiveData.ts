import React, {
  useEffect,
  useState,
  useCallback,
  useMemo,
  useContext,
  useReducer,
} from 'react'
import { Socket } from 'phoenix'
import { v4 as uuidv4 } from 'uuid'
const { applyPatch } = require('fast-json-patch')

export const useSocket = () => {
  const [socket, setSocket] = useState(null)

  useEffect(() => {
    const socket = new Socket('/live_data_socket')
    socket.connect()
    setSocket(socket)
  }, [])

  return socket
}

export const useLiveData = <S, A>(
  socket,
  component,
  defaultState = null,
  id = uuidv4(),
  params = {}
) => {
  const [channel, setChannel] = useState(null)
  const [state, dispatchDiff] = useReducer(
    (state, { diff }) =>
      applyPatch(state || {}, diff, false, false).newDocument,
    defaultState
  )

  useEffect(() => {
    let channel
    if (socket) {
      channel = socket.channel(`${component}:${id}`, params)
      channel.join()
      channel.on('diff', dispatchDiff)
      setChannel(channel)
    }

    return () => {
      if (channel) {
        channel.off('diff', dispatchDiff)
        channel.leave()
      }
    }
  }, [socket, JSON.stringify(params)])

  return [
    state,
    (msg, params) => {
      return new Promise((resolve) => {
        channel.push(msg, params).receive('ok', resolve)
      })
    },
  ] as [S | null, A]
}

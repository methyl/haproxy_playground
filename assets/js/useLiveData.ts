import React, {
  useEffect,
  useState,
  useCallback,
  useMemo,
  useContext,
  useReducer,
  useRef,
} from 'react'
import { Socket, Channel } from 'phoenix'
import { v4 as uuidv4 } from 'uuid'
const { applyPatch } = require('fast-json-patch')

export const useSocket = () => {
  const [socket, setSocket] = useState<Socket | null>(null)

  useEffect(() => {
    const socket = new Socket('/live_data_socket')
    socket.connect()
    setSocket(socket)
  }, [])

  return socket
}

export const useLiveData = <S, A>(
  socket: Socket,
  component : string,
  defaultState = null,
  id = null,
  params = {}
) => {
  // const idRef = useRef(id || uuidv4());
  const [channel, setChannel] = useState<Channel | null>(null)
  const [state, dispatchDiff] = useReducer(
    (state: S, { diff }: any) =>
      applyPatch(state || {}, diff, false, false).newDocument,
    defaultState
  )

  useEffect(() => {
    let channel: Channel
    let ref: number
    if (socket) {
      channel = socket.channel(`${component}:${id}`, params)
      channel.join()
      ref = channel.on('diff', dispatchDiff)
      setChannel(channel)
    }

    return () => {
      if (channel) {
        channel.off('diff', ref)
        channel.leave()
      }
    }
  }, [socket, id, JSON.stringify(params)])

  return [
    state,
    ((msg, params) => {
      return new Promise((resolve) => {
        channel.push(msg, params).receive('ok', resolve)
      })
    }) as A,
  ] as [S | null, A]
}

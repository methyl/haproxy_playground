import React from 'react'
import { useLiveData, useSocket } from './useLiveData'
import { Action, State } from 'app'

export const Server = ({id, socket}) => {
  // const socket = useSocket()
  const [state, action] = useLiveData<State, Action>(socket, 'Server', null, id)

  if (state == null) {
    return <div>Loading</div>
  }

  return (
    <div style={{overflow: 'auto'}}>
      {state.logs.map(log =>

        <div style={{ whiteSpace: 'nowrap'}}>{log}</div>)}
    </div>
  )
}

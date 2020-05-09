import React from 'react'
import {render} from 'react-dom'
import { useLiveData, useSocket } from './useLiveData'
import { Action, State } from 'app'

const App = () => {
  const socket = useSocket()
  const [state, action] = useLiveData<State, Action>(socket, "App", null)

  if (state == null) {
    return <div>Loading</div>
  }


  return <div>
    <input type="text" value={state.who} onChange={(e) => action("hello", {who: e.currentTarget.value})} />
    Hello, {state.who}
  </div>
}

render(<App />, document.querySelector("#root"))

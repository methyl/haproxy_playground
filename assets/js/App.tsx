import React, { useState } from 'react'
import { render } from 'react-dom'
import { useLiveData, useSocket } from './useLiveData'
import { Action, State } from 'app'
import { Haproxy } from './Haproxy'
import { Server } from './Server'
import { v4 } from 'uuid'

const sessionId = v4()

const RequestForm = (props) => {
  const [value, setValue] = useState('')
  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        props.onSubmit(value)
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <input
          style={{ flex: 1, marginRight: 20 }}
          value={value}
          onChange={(e) => setValue(e.currentTarget.value)}
          placeholder="httpie syntax, ie. GET haproxy/some_path"
        />
        <button>send</button>
      </div>
      <div>{props.error}</div>
    </form>
  )
}

const App = () => {
  const socket = useSocket()
  const [state, action] = useLiveData<State, Action>(
    socket,
    'App',
    null,
    sessionId
  )

  if (state == null) {
    return <div>Loading</div>
  }

  return (
    <div>
      <RequestForm error={state.request_error} onSubmit={(attrs) => action('request', { attrs })} />
      <div style={{ display: 'flex', height: '90vh' }}>
        <div style={{ flex: 1, width: '50%' }}>
          <Haproxy socket={socket} id={state.haproxy} />
        </div>
        <div style={{ flex: 1 }}>
          {state.servers.map(({ id, name }) => (
            <div style={{ background: '#ccc', margin: 10 }}>
              <div>{name}</div>
              <Server socket={socket} id={id} />
            </div>
          ))}
          <button onClick={() => action('add_server', {})}>Add server</button>
        </div>
      </div>
    </div>
  )
}

render(<App />, document.querySelector('#root'))

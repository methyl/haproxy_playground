import React, { useEffect, useState } from 'react'
import { useLiveData, useSocket } from './useLiveData'
import { Action, State } from 'app'

export const Haproxy = ({ id, socket }) => {
  // const socket = useSocket()
  const [state, action] = useLiveData<State, Action>(
    socket,
    'Haproxy',
    null,
    id
  )

  const [config, setConfig] = useState(null)

  useEffect(() => {
    if (state != null && config == null) {
      setConfig(state.config)
    }
  }, [setConfig, config, state])

  if (state == null) {
    return <div>Loading</div>
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ display: 'flex'}}>
        <div style={{ flex: 1 }}>
          Haproxy available at localhost:{state.port}
        </div>
        <button
          onClick={() => {
            action('update_config', { new_config: config })
          }}
        >
          {state.config_loading ? 'loading' : 'Reload config'}
        </button>
      </div>
      <div style={{ flex: 1 }}>
        <textarea
          style={{ height: '100%' }}
          value={config || state.config}
          onChange={(e) => setConfig(e.currentTarget.value)}
          // onChange={(e) => action('update_haproxy_config', { who: e.currentTarget.value })}
        />
      </div>
      <div style={{ flex: 1, overflow: 'auto' }}>
        {state.logs.map((log) => (
          <div style={{ whiteSpace: 'nowrap' }}>{log}</div>
        ))}
      </div>
    </div>
  )
}

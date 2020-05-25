import net from 'net'

import log from '../log.js'

let module = {
  title: 'Lights Controller',
  hwAddress: '10.0.0.108',
  hwPort: 5081,

  connected: false,
  connection: null,

  actions: {
    toggleBedroomLights: {
      async handler (_this, params) {
        if (module.connected) {
          log.i2('Running action toggleBedroomLights from lights0')

          module.connection.write('1')
        } else {
          throw new Error('Cannot run action toggleBedroomLights from lights0, because the module is not connected to its hardware counterpart.')
        }
      }
    },
    toggleKitchenLights: {
      async handler (_this, params) {
        if (module.connected) {
          log.i2('Running action toggleKitchenLights from lights0')

          module.connection.write('2')
        } else {
          throw new Error('Cannot run action toggleKitchenLights from lights0, because the module is not connected to its hardware counterpart.')
        }
      }
    },
    turnBedroomLights: {
      params: {
        state: ['On', 'Off']
      },
      async handler (_this, params) {
        if (module.connected) {
          log.i2('Running action turnBedroomLights from lights0')

          if (params.state == 'On') {
            module.connection.write('3')
          } else {
            module.connection.write('4')
          }
        } else {
          throw new Error('Cannot run action turnBedroomLights from lights0, because the module is not connected to its hardware counterpart.')
        }
      }
    },
    turnKitchenLights: {
      params: {
        state: ['On', 'Off']
      },
      async handler (_this, params) {
        if (module.connected) {
          log.i2('Running action turnKitchenLights from lights0')

          if (params.state == 'On') {
            module.connection.write('5')
          } else {
            module.connection.write('6')
          }
        } else {
          throw new Error('Cannot run action turnKitchenLights from lights0, because the module is not connected to its hardware counterpart.')
        }
      }
    },
  },

  start () {
    // create TCP connection instance
    this.connection = new net.Socket();

    this.connection.on('connect', () => {
      log.i2(this.title, 'connected to the hardware module.')
      this.connected = true
    })

    // when the connection is interrupted
    this.connection.on('close', this.disconnected)
    this.connection.on('error', this.disconnected)
    this.connection.on('timeout', this.disconnected)

    // automatically reconnect when the connection is interrupted
    setInterval(
      () => {
        if (!this.connected) {
          this.reconnect()
        }
      },
      5000 // how often shoudld we attempt to reconnect in ms
    )

    // first connection attempt
    this.reconnect()
  },

  disconnected () {
    module.connected = false
  },

  reconnect () {
    log.i3(this.title, 'attempting a connection to the hardware module.')

    try {
      this.connection.connect(this.hwPort, this.hwAddress)
    } catch (e) {
      log.w('Module', this.title, 'was unable to connect to its hardware counterpart.', e)
    }
  },
}

export default module
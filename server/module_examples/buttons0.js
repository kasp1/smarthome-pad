import net from 'net'

import api from '../api.js'
import log from '../log.js'

let module = {
  title: 'Light Controls',
  hwAddress: '10.0.0.107',
  hwPort: 5082,

  connected: false,
  connection: null,

  events: ['BedroomSwitch', 'KitchenSwitch'],

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
    this.connection.on('timeout', module.disconnected)

    this.connection.on('data', (data) => {
      data = parseInt(data)
      
      switch (data) {
        case 1: api.emit('BedroomSwitch', module); break
        case 2: api.emit('KitchenSwitch', module); break
      }
    })

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
    log.i3(this.title, 'attempting a connection to the hardware module.', this.hwPort, this.hwAddress)

    try {
      this.connection.connect(this.hwPort, this.hwAddress)
    } catch (e) {
      log.w('Module', this.title, 'was unable to connect to its hardware counterpart.', e)
    }
  },

  incomingData (data) {
    let code = parseInt(data)

    switch (code) {
      case 1:
        api.emit('BedroomSwitch', module)
        break;
      case 2:
        api.emit('KitchenSwitch', module)
        break;
    }
  },
}

export default module
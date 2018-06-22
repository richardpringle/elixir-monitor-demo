'use strict'

const grpc = require('grpc')
const fs = require('fs')
const ws = fs.createWriteStream('./log.log')

const applicationMonitor = grpc.load('./protos/application-monitor.proto')

const server = new grpc.Server()

process.stdin.on('data', data => ws.write(data))
process.stdin.on('close', () => server.tryShutdown(() => {}))

server.addService(applicationMonitor.Monitor.service, {
  start(
    {
      request: { name },
    },
    callback,
  ) {
    process.stdin.once('data', data => {
      ws.write(
        `\nstart callback called with data->${data &&
          data.toString()}\nand name->${name}`,
      )

      callback(null, { name, state: applicationMonitor.State[data.toString()] })
    })
    process.stdout.write(name)
  },
  stop(
    {
      request: { name },
    },
    callback,
  ) {
    process.stdin.once('data', data => {
      ws.write('\n\nthis is going to crash')

      process.exit(1)

      callback(null, { name, state: applicationMonitor.State[data.toString()] })
    })
    process.stdout.write(name)
  },
  restart(
    {
      request: { name },
    },
    callback,
  ) {
    process.stdin.once('data', data => {
      callback(null, { name, state: applicationMonitor.State[data.toString()] })
    })
    process.stdout.write(name)
  },
  status(
    {
      request: { name },
    },
    callback,
  ) {
    process.stdin.once('data', data => {
      callback(null, { name, state: applicationMonitor.State[data.toString()] })
    })
    process.stdout.write(name)
  },
})

server.bind('0.0.0.0:50051', grpc.ServerCredentials.createInsecure())

server.start()

console.log('started')

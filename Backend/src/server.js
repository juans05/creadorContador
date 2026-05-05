require('dotenv').config();
const app = require('./app');
const http = require('http');
const { Server } = require('socket.io');
const SocketService = require('./services/socketService');

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

const socketService = new SocketService(io);
socketService.initialize();

console.log('Socket.io initialized');

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Socket.io ready`);
});
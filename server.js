const express = require('express'); //requires express module
const socket = require('socket.io'); //requires socket.io module
const fs = require('fs');
const e = require('express');
const app = express();
var PORT = process.env.PORT || 3000;
const server = app.listen(PORT); //tells to host server on localhost:3000


//Playing variables:
app.use(express.static('public')); //show static files in 'public' directory
console.log('Server is running');
const io = socket(server);

//Socket.io Connection------------------
io.on('connection', (socket) => {

    console.log("New socket connection: " + socket.id)

    socket.on('send-message', (message, room) => {
        console.log(message)
        if (room === "") {
            socket.broadcast.emit('receive-message', message);
        }else {
            socket.to(room).emit('receive-message', message);
        }
        // io.emit('receive-message', message);
    })

    socket.on('join-room', room => {
        console.log(room)
        socket.join(room)
    })
})
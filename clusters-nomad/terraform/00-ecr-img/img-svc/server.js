const express = require('express');
const http = require('http');
const app = express();
const router = express.Router();

router.route('/ping').get((req, res) => {
    console.log("Pong from Nomad !");
    res.status(200).json({ success: true });
});

app.use('/api/v1', router);

const server = http.createServer(app, (req, res) => {
    res.writeHead(200, {"Content-Type": "text/plain"});
    res.end("Woohoo !\n");
});

server.listen(8080);
console.log("Server running on Nomad ! ...");

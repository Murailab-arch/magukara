"use strict";

var fs        = require('fs');
var wsserver  = require('ws').Server;
var mmap      = require('mmap');
var express   = require('express')
var D         = require('util').debug;

var BASE_ADDR = 0xe9000000;
var MSIZE     = 0x80;

var app, fd, buf, wss;

// setup: http server
app = express.createServer();
app.use(express.static(__dirname + '/public'));
app.listen(8081);

// setup: websocket server
wss = new wsserver( {server: app} );

// setup: fd
try {
  fd = fs.openSync('/dev/mem', 'w+');
} catch (e) {
  D('cannot open: /dev/mem');
}

// setup: mmap
try {
  buf = mmap.map(MSIZE, mmap.PROT_READ|mmap.PROT_WRITE, mmap.MAP_SHARED, fd, BASE_ADDR);
} catch (e) {
  D('cannot mmap: 0xE9000000-');
}

wss.on('connection', function(ws) {
  // send NIC stats
  var id = setInterval( function() {
    var nicstats = {
      m: buf[0x00],
      tx0: {
        fs: (buf[0x04] << 24) + (buf[0x05] << 16) + (buf[0x06] << 8) + buf[0x07],
        g:  (buf[0x08] << 24) + (buf[0x09] << 16) + (buf[0x0a] << 8) + buf[0x0b],
        si: [ buf[0x10], buf[0x11], buf[0x12], buf[0x13] ].join('.'),
        gi: [ buf[0x20], buf[0x21], buf[0x22], buf[0x23] ].join('.'),
        di: [ buf[0x4c], buf[0x4d], buf[0x4e], buf[0x4f] ].join('.'),
        sm: [ buf[0x16].toString(16), buf[0x17].toString(16), buf[0x18].toString(16),
              buf[0x19].toString(16), buf[0x1a].toString(16), buf[0x1b].toString(16) ].join(':'),
        dm: [ buf[0x26].toString(16), buf[0x27].toString(16), buf[0x28].toString(16),
              buf[0x29].toString(16), buf[0x2a].toString(16), buf[0x2b].toString(16) ].join(':'),
        p:  (buf[0x40] << 24) + (buf[0x41] << 16) + (buf[0x42] << 8) + buf[0x43],
        t:  (buf[0x44] << 24) + (buf[0x45] << 16) + (buf[0x46] << 8) + buf[0x47]
      },
      rx1: {
        p:  (buf[0x50] << 24) + (buf[0x51] << 16) + (buf[0x52] << 8) + buf[0x53],
        t:  (buf[0x54] << 24) + (buf[0x55] << 16) + (buf[0x56] << 8) + buf[0x57],
        l:  (buf[0x58] << 24) + (buf[0x59] << 16) + (buf[0x5a] << 8) + buf[0x5b],
        i: [ buf[0x5c], buf[0x5d], buf[0x5e], buf[0x5f] ].join('.'),
        o1: buf[0x5c],
        o4: buf[0x5f]
      },
      rx2: {
        p:  (buf[0x60] << 24) + (buf[0x61] << 16) + (buf[0x62] << 8) + buf[0x63],
        t:  (buf[0x64] << 24) + (buf[0x65] << 16) + (buf[0x66] << 8) + buf[0x67],
        l:  (buf[0x68] << 24) + (buf[0x69] << 16) + (buf[0x6a] << 8) + buf[0x6b],
        i: [ buf[0x6c], buf[0x6d], buf[0x6e], buf[0x6f] ].join('.'),
        o1: buf[0x6c],
        o4: buf[0x6f]
      },
      rx3: {
        p:  (buf[0x70] << 24) + (buf[0x71] << 16) + (buf[0x72] << 8) + buf[0x73],
        t:  (buf[0x74] << 24) + (buf[0x75] << 16) + (buf[0x76] << 8) + buf[0x77],
        l:  (buf[0x78] << 24) + (buf[0x79] << 16) + (buf[0x7a] << 8) + buf[0x7b],
        i: [ buf[0x7c], buf[0x7d], buf[0x7e], buf[0x7f] ].join('.'),
        o1: buf[0x7c],
        o4: buf[0x7f]
      }
    };
    var nicstatsJSON = JSON.stringify(nicstats);

    ws.send(nicstatsJSON);
  }, 15);

  // recieve commands
  ws.on('message', function(msg) {
    var msgObj = JSON.parse(msg);
    if (msgObj.cmd == "frame_size") {
      buf[0x04] = msgObj.data >> 24
      buf[0x05] = msgObj.data >> 16;
      buf[0x06] = msgObj.data >> 8;
      buf[0x07] = msgObj.data & 0xFF;
    } else if (msgObj.cmd == "mode") {
      buf[0x00] = msgObj.data;
    } else if (msgObj.cmd == "frame_gap") {
      buf[0x08] = msgObj.data >> 24
      buf[0x09] = msgObj.data >> 16;
      buf[0x0a] = msgObj.data >> 8;
      buf[0x0b] = msgObj.data & 0xFF;
    } else if (msgObj.cmd == "arpreq") {
      buf[0x0c] = msgObj.data;
    }
  });

  // close session
  ws.on('close', function() {
    console.log('Stopping connection');
    clearInterval(id);
  });
});

function swap8(v) {
  return ((v & 0xFF) << 4) | ((v >> 4) & 0xFF);
}


"use strict";

var canvas_wire  = null;
var canvas_frmap = null;
var ctx_wire     = null;
var ctx_frmap    = null;
var rx1ip_o1a    = 0;
var rx1ip_o1b    = 0;
var rx2ip_o1a    = 0;
var rx2ip_o1b    = 0;
var rx3ip_o1a    = 0;
var rx3ip_o1b    = 0;

var rx1ip_o4     = 0;
var rx2ip_o4     = 0;
var rx3ip_o4     = 0;

// canvas setup
window.addEventListener("load", setup_wiremap(), false);
window.addEventListener("load", setup_frmap(), false);

// setup wire diagram
function setup_wiremap() {
  canvas_wire = document.getElementById('skeleton');
  ctx_wire    = canvas_wire.getContext('2d');

  ctx_wire.font      = "12pt Arial";
  ctx_wire.fillStyle = 'rgb(0, 0, 0)';
  ctx_wire.lineJoin = "miter";

  ctx_wire.fillText("テスタ", 5, 40);
  ctx_wire.fillText("ルータ", 5, 120);

  ctx_wire.lineWidth = 2;
  ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
  ctx_wire.strokeRect(60, 10, 280, 50);
  ctx_wire.strokeRect(60, 90, 280, 50);

  ctx_wire.lineWidth = 16;
  ctx_wire.strokeStyle = 'rgb(255, 255, 255)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(101, 50);
  ctx_wire.lineTo(101, 100);
  ctx_wire.moveTo(167, 50);
  ctx_wire.lineTo(167, 100);
  ctx_wire.moveTo(233, 50);
  ctx_wire.lineTo(233, 100);
  ctx_wire.moveTo(299, 50);
  ctx_wire.lineTo(299, 100);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.lineWidth = 4;
  ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(101, 50);
  ctx_wire.lineTo(101, 100);
  ctx_wire.moveTo(167, 50);
  ctx_wire.lineTo(167, 100);
  ctx_wire.moveTo(233, 50);
  ctx_wire.lineTo(233, 100);
  ctx_wire.moveTo(299, 50);
  ctx_wire.lineTo(299, 100);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.lineWidth = 4;
  ctx_wire.strokeStyle = 'rgb(255, 255, 255)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(101, 70);
  ctx_wire.lineTo(101, 85);
  ctx_wire.moveTo(167, 65);
  ctx_wire.lineTo(167, 80);
  ctx_wire.moveTo(233, 65);
  ctx_wire.lineTo(233, 80);
  ctx_wire.moveTo(299, 65);
  ctx_wire.lineTo(299, 80);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.lineWidth = 5;

  ctx_wire.strokeStyle = 'rgb(63, 159, 217)';
  ctx_wire.beginPath();
  ctx_wire.moveTo( 91, 70);
  ctx_wire.lineTo(101, 80);
  ctx_wire.lineTo(111, 70);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.strokeStyle = 'rgb(183, 0, 0)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(177, 80);
  ctx_wire.lineTo(167, 70);
  ctx_wire.lineTo(157, 80);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.strokeStyle = 'rgb(86, 172, 86)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(243, 80);
  ctx_wire.lineTo(233, 70);
  ctx_wire.lineTo(223, 80);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.strokeStyle = 'rgb(33, 58, 244)';
  ctx_wire.beginPath();
  ctx_wire.moveTo(309, 80);
  ctx_wire.lineTo(299, 70);
  ctx_wire.lineTo(289, 80);
  ctx_wire.stroke();
  ctx_wire.closePath();

  ctx_wire.lineWidth = 2;
  ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
  ctx_wire.fillRect(86, 23, 30, 24);
  ctx_wire.fillRect(152, 23, 30, 24);
  ctx_wire.fillRect(218, 23, 30, 24);
  ctx_wire.fillRect(284, 23, 30, 24);
  ctx_wire.strokeRect(86, 103, 30, 24);
  ctx_wire.strokeRect(152, 103, 30, 24);
  ctx_wire.strokeRect(218, 103, 30, 24);
  ctx_wire.strokeRect(284, 103, 30, 24);
}

// setup FullRoute map
function setup_frmap() {
  canvas_frmap = document.getElementById('map');
  ctx_frmap    = canvas_frmap.getContext('2d');

  var gw   = parseInt(canvas_frmap.width);
  var gh   = parseInt(canvas_frmap.height);
  var nrow = 256;
  var ncol = 256;

  ctx_frmap.fillStyle = "rgba(8,8,12,1)";
  ctx_frmap.fillRect(0,0,gw,gh);
}

// websocket setup
var ws = new WebSocket("ws://127.0.0.1:8081");
ws.onmessage = function (event) {
  var dataJSON = JSON.parse(event.data);
  updateStats(dataJSON);
  drawWiremap(dataJSON);
  drawFRmap(dataJSON);
};

function updateStats(s) {
  if (s.m == 0x80) {
    document.querySelector('div#global_mode').innerText = "Normal";
  } else if (s.m == 0x81) {
    document.querySelector('div#global_mode').innerText = "FullRoute";
  } else if (s.m == 0x00) {
    document.querySelector('div#global_mode').innerText = "STOP";
  } else {
    document.querySelector('div#global_mode').innerText = "unknown";
  }
  document.querySelector('div#tx0_frame_size').innerText = s.tx0.fs;
  document.querySelector('div#tx0_gap').innerText        = s.tx0.g;
  document.querySelector('div#tx0_src_ipaddr').innerText = s.tx0.si;
  document.querySelector('div#tx0_gw_ipaddr').innerText  = s.tx0.gi;
  document.querySelector('div#tx0_dst_ipaddr').innerText = s.tx0.di;
  document.querySelector('div#tx0_src_mac').innerText    = s.tx0.sm;
  document.querySelector('div#tx0_dst_mac').innerText    = s.tx0.dm;
  document.querySelector('div#tx0_pps').innerText        = addComma(s.tx0.p);
  document.querySelector('div#tx0_throughput').innerText = Math.floor(s.tx0.t / 125000);
  document.querySelector('div#rx1_latency').innerText    = addComma((s.rx1.l - 57) << 3);
  document.querySelector('div#rx1_pps').innerText        = addComma(s.rx1.p);
  document.querySelector('div#rx1_throughput').innerText = Math.floor(s.rx1.t / 125000);
  document.querySelector('div#rx1_ipaddr').innerText     = s.rx1.i;
  document.querySelector('div#rx2_latency').innerText    = addComma((s.rx2.l - 57) << 3);
  document.querySelector('div#rx2_pps').innerText        = addComma(s.rx2.p);
  document.querySelector('div#rx2_throughput').innerText = Math.floor(s.rx2.t / 125000);
  document.querySelector('div#rx2_ipaddr').innerText     = s.rx2.i;
  document.querySelector('div#rx3_latency').innerText    = addComma((s.rx3.l - 57) << 3);
  document.querySelector('div#rx3_pps').innerText        = addComma(s.rx3.p);
  document.querySelector('div#rx3_throughput').innerText = Math.floor(s.rx3.t / 125000);
  document.querySelector('div#rx3_ipaddr').innerText     = s.rx3.i;

  document.querySelector('td#rx1_map').innerText         = s.rx1.i;
  document.querySelector('td#rx2_map').innerText         = s.rx2.i;
  document.querySelector('td#rx3_map').innerText         = s.rx3.i;

  rx1ip_o1a = s.rx1.o1 >> 4;
  rx1ip_o1b = s.rx1.o1 & 0xF;
  rx2ip_o1a = s.rx2.o1 >> 4;
  rx2ip_o1b = s.rx2.o1 & 0xF;
  rx3ip_o1a = s.rx3.o1 >> 4;
  rx3ip_o1b = s.rx3.o1 & 0xF;

  rx1ip_o4 = s.rx1.o4;
  rx2ip_o4 = s.rx2.o4;
  rx3ip_o4 = s.rx3.o4;
}

function drawWiremap(s) {
  ctx_wire.lineWidth = 5;

  if (s.tx0.p) {
    ctx_wire.fillStyle   = 'rgb(63, 159, 217)';
    ctx_wire.strokeStyle = 'rgb(63, 159, 217)';
    ctx_wire.fillRect(86, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo( 91, 70);
    ctx_wire.lineTo(101, 80);
    ctx_wire.lineTo(111, 70);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } else {
    ctx_wire.fillStyle   = 'rgb(0, 0, 0)';
    ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
    ctx_wire.fillRect(86, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo( 91, 70);
    ctx_wire.lineTo(101, 80);
    ctx_wire.lineTo(111, 70);
    ctx_wire.stroke();
    ctx_wire.closePath();
  }

  if (s.rx1.p) {
    ctx_wire.fillStyle   = 'rgb(183, 0, 0)';
    ctx_wire.strokeStyle = 'rgb(183, 0, 0)';
    ctx_wire.fillRect(152, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(177, 80);
    ctx_wire.lineTo(167, 70);
    ctx_wire.lineTo(157, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } else {
    ctx_wire.fillStyle   = 'rgb(0, 0, 0)';
    ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
    ctx_wire.fillRect(152, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(177, 80);
    ctx_wire.lineTo(167, 70);
    ctx_wire.lineTo(157, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } 

  if (s.rx2.p) {
    ctx_wire.fillStyle   = 'rgb(86, 172, 86)';
    ctx_wire.strokeStyle = 'rgb(86, 172, 86)';
    ctx_wire.fillRect(218, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(243, 80);
    ctx_wire.lineTo(233, 70);
    ctx_wire.lineTo(223, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } else {
    ctx_wire.fillStyle   = 'rgb(0, 0, 0)';
    ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
    ctx_wire.fillRect(218, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(243, 80);
    ctx_wire.lineTo(233, 70);
    ctx_wire.lineTo(223, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } 

  if (s.rx3.p) {
    ctx_wire.fillStyle   = 'rgb(33, 58, 244)';
    ctx_wire.strokeStyle = 'rgb(33, 58, 244)';
    ctx_wire.fillRect(284, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(309, 80);
    ctx_wire.lineTo(299, 70);
    ctx_wire.lineTo(289, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  } else {
    ctx_wire.fillStyle   = 'rgb(0, 0, 0)';
    ctx_wire.strokeStyle = 'rgb(0, 0, 0)';
    ctx_wire.fillRect(284, 23, 30, 24);
    ctx_wire.beginPath();
    ctx_wire.moveTo(309, 80);
    ctx_wire.lineTo(299, 70);
    ctx_wire.lineTo(289, 80);
    ctx_wire.stroke();
    ctx_wire.closePath();
  }
}

function drawFRmap(s) {
  ctx_frmap.globalCompositeOperation = "source-over";
  ctx_frmap.fillStyle = "rgba(8,8,12,0.01)";
  ctx_frmap.fillRect(0,0,512,384);
  ctx_frmap.globalCompositeOperation = "lighter";

  ctx_frmap.fillStyle ="rgba(192, 26, 141, 1)";
  ctx_frmap.beginPath();
  if (!rx1ip_o1a && !rx1ip_o1b) {
    return(false);
  } else if (rx1ip_o4 > 1 || rx2ip_o4 > 1 || rx3ip_o4 > 1 ||
             (rx1ip_o1a == 1 && rx1ip_o1b == 4) || 
             (rx2ip_o1a == 1 && rx2ip_o1b == 4) ||
             (rx3ip_o1a == 1 && rx3ip_o1b == 4)
  ) {
    return(false);
  }

  ctx_frmap.rect(rx1ip_o1b * 32, rx1ip_o1a * 24, 32, 24);
  ctx_frmap.rect(rx2ip_o1b * 32, rx2ip_o1a * 24, 32, 24);
  ctx_frmap.rect(rx2ip_o1b * 32, rx3ip_o1a * 24, 32, 24);
  ctx_frmap.fill();
  ctx_frmap.closePath();
}

function change_gap (slider) {
  console.log(slider.value);
  var msg = { 
    "cmd": "frame_gap",
    "data": slider.value
  };
  ws.send(JSON.stringify(msg));
};

var change_fs = function (size) {
  var msg = { 
    "cmd": "frame_size",
    "data": size
  };
  ws.send(JSON.stringify(msg));
};

var mode_normal = function () {
  var msg = { 
    "cmd": "mode",
    "data": 0x80
  };
  ws.send(JSON.stringify(msg));
};

var mode_fullroute = function () {
  var msg = { 
    "cmd": "mode",
    "data": 0x81
  };
  ws.send(JSON.stringify(msg));
};

var mode_stop = function () {
  var msg = { 
    "cmd": "mode",
    "data": 0x00
  };
  ws.send(JSON.stringify(msg));
};

var send_arpreq = function () {
  var msg = { 
    "cmd": "arpreq",
    "data": 0x0c
  };
  ws.send(JSON.stringify(msg));
};

function addComma(str) {
  var num = new String(str);
  while(num != (num = num.replace(/^(\d+)(\d{3})/, "$1,$2")));
return num;
}



/*
  Based on Becky Stewart's processing_osc_to_arduino (2022)

  Wekinator -> Processing -> Arduino
  5 Regression Outputs -> 4 Stepper Motors
*/

import oscP5.*;
import netP5.*;
import processing.serial.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Serial port;

// MODIFIED: 存储5个Wekinator输出 / Store 5 Wekinator outputs
float[] outputs = new float[5];

// ADDED: 发送时间间隔200ms / Send interval: 200ms
int lastSendTime = 0;
int sendInterval = 300;
boolean receivedData = false;

void setup() {
  size(256, 150);

  println("Available serial ports:");
  printArray(Serial.list());

  // Arduino串口 / Arduino serial port
  port = new Serial(this, "/dev/cu.usbmodem11101", 9600);

  // 接收Wekinator OSC / Receive OSC from Wekinator
  oscP5 = new OscP5(this, 12000);
}

void draw() {

  // 原来的背景 / Original background
  for (int i = 0; i < 256; i++) {
    stroke(i);
    line(i, 0, i, 150);
  }

  // ADDED: 每200ms发送一次 / Send every 200ms
  if (receivedData && millis() - lastSendTime >= sendInterval) {
    updateArduino();
    lastSendTime = millis();
  }
}


void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/wek/outputs") == true) {

    // MODIFIED: 接收5个float / Receive 5 floats
    if (theOscMessage.checkTypetag("fffff")) {

      for (int i = 0; i < 5; i++) {
        outputs[i] = theOscMessage.get(i).floatValue();
      }

      receivedData = true;
      return;
    }
  }
}


// MODIFIED: 发送前4个输出 / Send first 4 outputs
void updateArduino() {

  // 限制输出在0-1 / Constrain outputs to 0-1
  String arduinoMessage =
    constrain(outputs[0], 0, 1) + "," +
    constrain(outputs[1], 0, 1) + "," +
    constrain(outputs[2], 0, 1) + "," +
    constrain(outputs[3], 0, 1) + "\n";

  // 发送给Arduino / Send to Arduino
  port.write(arduinoMessage);

  // 打印调试数据 / Print debug data
  println("Sent: " + arduinoMessage.trim());
}

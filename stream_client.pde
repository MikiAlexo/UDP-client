import java.net.*;
import java.io.*;
import java.util.*;

UDPReceiver udp;
ArrayList<String> dataLog = new ArrayList<String>(); 

int saveInterval = 10 * 1000;
int lastSaveTime = 0;
int lastReceivedTime = 0;

int fileIndex = 1;

boolean connected=false;

void setup() {
  size(400, 200);

  udp = new UDPReceiver(new UDPHandlerImpl(), 8888);
  lastSaveTime = millis();
}

void draw() {
  background(0);
  fill(255);
  text("Auto-saving UDP log every 10s", 20, 100);
  fill(255, 255, 0);
  text("Warning: if you close this window\n DONOT reopen it before taking the logged data", 20, 120);


  println(" save delta:", millis() - lastSaveTime);
  println(" recieve delta:", millis() - lastReceivedTime);
  if (connected) {
    fill(0, 255, 0);
    text("Connected", 20, 160);
  } 
  if (millis() - lastReceivedTime > 5000 || !connected) {
    fill(255, 0, 0);
    text("waiting for connection", 20, 160);
    println("nofnrofnrfnorfrfrfrfrfr");
  }


  if ( millis() - lastSaveTime >= saveInterval) {
    try {
      saveLog();
      lastSaveTime = millis();
    } 
    catch (Exception e) {
      println("Error saving log: " + e.getMessage());
    }
  }
}


interface UDPHandler {
  void onUDP(String data);
}

class UDPHandlerImpl implements UDPHandler {
  public void onUDP(String data) {
    println("Received: " + data);
    dataLog.add(data);
  }
}


class UDPReceiver extends Thread {
  DatagramSocket socket;
  boolean running = true;
  byte[] buffer = new byte[1024];
  UDPHandler handler;

  UDPReceiver(UDPHandler handler, int port) {
    this.handler = handler;
    try {
      socket = new DatagramSocket(port);
      println("Listening on port: " + port);
      this.start();
    } 
    catch (SocketException e) {
      e.printStackTrace();
      connected=false;
    }
  }

  public void run() {
    while (running) {
      try {
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
        socket.receive(packet);
        String received = new String(packet.getData(), 0, packet.getLength(), "UTF-8"); 
        handler.onUDP(received);
        if (received.equals("")) return;
        else {
          connected=true;
          lastReceivedTime=millis();
        }
      }
      catch (IOException e) {
        e.printStackTrace();
        connected=false;
        break;
      }
    }
    socket.close();
  }

  void stopReceiver() { 
    running = false;
    socket.close();
  }
}


void saveLog() {
  if (dataLog.size() == 0) return;

  String folderName = "sensor log";
  File folder = new File(folderName);
  if (!folder.exists()) {
    folder.mkdirs();  
  }

  String filename = folderName + "/UDP_Log_" + nf(fileIndex++, 3) + ".txt";
  String[] lines = dataLog.toArray(new String[0]);
  saveStrings(filename, lines);
  println("Auto-saved: " + filename);
  dataLog.clear();  
}

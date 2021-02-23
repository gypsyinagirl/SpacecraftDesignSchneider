/*************************************************************
  This is an examples for the RL01-02-03 Radio Range

  You can buy one on our store!
  -----> https://xinabox.cc/products/RL01/
  -----> https://xinabox.cc/products/RL02/
  -----> https://xinabox.cc/products/RL03/

  This example requests the Alcohol sensor to measure
  the Breath Alcohol Level

  Currently Supported on the following ☒CHIPs:
  - CW01
  - CR01/02/03

  The sensor communicates over the I2C Bus.

*************************************************************/






#include <xCore.h>
#include <xRL0x.h>

#define RL03_FREQ 915.0
#define CW01_RED 12
#define CW01_GREEN 13
#define CW01_BLUE 5


void setup() {
  // Start the Serial Monitor
  Serial.begin(115200);

  // Set the RGB Pin directions
  pinMode(CW01_RED, OUTPUT);
  pinMode(CW01_GREEN, OUTPUT);
  pinMode(CW01_BLUE, OUTPUT);

  // Start the I2C Comunication
  Wire.pins(2, 14);
  Wire.begin();

  if (!RL0X.begin()) { // <-- enter radio name here
    Serial.println("Check the connector to RL03");
    while (1) {
      // Flash RED to indicate failure
      digitalWrite(CW01_RED, HIGH);
      delay(100);
      digitalWrite(CW01_RED, LOW);
      delay(100);
    }
  } else {
    // RL0X Initialized correctly
    //RL0X.setModemConfig(RL0X.Bw125Cr45Sf128);
    //RL0X.setModemConfig(RL0X.Bw500Cr45Sf128);
    //RL0X.setModemConfig(RL0X.Bw31_25Cr48Sf512);
    RL0X.setModemConfig(RL0X.Bw125Cr48Sf4096);
    
    RL0X.setFrequency(RL03_FREQ);
    RL0X.setTxPower(23, false);
  }
  Serial.println("setup done");
}

void loop() {
  digitalWrite(CW01_BLUE,HIGH);
  Serial.println("Waiting");
  if (RL0X.waitAvailableTimeout(3000)) {
    uint8_t buf[195];
    uint8_t len = sizeof(buf);
    if (RL0X.recv(buf, &len)) {
      digitalWrite(CW01_RED, HIGH);
      Serial.println("got message: ");
      Serial.println((char*)buf);
      Serial.print("RSSI: ");
      Serial.println(RL0X.lastRssi(), DEC);

      // Send a reply
      uint8_t data[] = "And hello back to you";
      delay(100);
      RL0X.send(data, sizeof(data));
      Serial.println("Sent a reply");
      digitalWrite(CW01_RED, LOW);
    } else {
      Serial.println("recv failed");
    }
  }
  digitalWrite(CW01_BLUE,LOW);
}

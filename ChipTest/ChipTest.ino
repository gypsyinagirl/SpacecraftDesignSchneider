#include <xCore.h>
#include <xSW01.h>
#include <xSI01.h>
#include <xSL01.h>
#include "xSN01.h"


xSW01 SW01;
xSI01 SI01;
xSL01 SL01;
xSN01 SN01;

const int DELAY_TIME = 1000;
#define PRINT_SPEED 250
static unsigned long lastPrint = 0;
long tick_Print = 0;

void setup() {
  Serial.begin(115200);

  // Set the I2C Pins for CW01
  #ifdef ESP8266
    Wire.pins(2, 14);
    Wire.setClockStretchLimit(15000);
  #endif

  // Start the I2C Comunication
  Wire.begin();
  
  if (!SI01.begin()) {
    Serial.println("Failed to communicate with SI01.");
    Serial.println("Check the Connector");
  } else {
    Serial.println("start successful");
  }

  SW01.begin();
  SL01.begin();
  SN01.begin();
  
  millis();
  //Delay for sensor to normalise
  delay(5000);   
}

void loop(){
  Serial.println();
  // Create a variable to store the data read from SW01
  float pressure,alt,humidity,tempC,tempF, lux, uvA,uvB, uvB_index ;
  pressure = 0;
  alt = 0;
  humidity = 0;
  tempC = tempF = 0;
  lux = 0;
  uvA = 0;
  uvB = 0;
  uvB_index = 0;

  String time;
  long latitude = 0;
  long longitude = 0;
  String date;
 
  // Read and calculate data from SW01 sensor
  SW01.poll();
  SI01.poll();
  SL01.poll();
  SN01.poll();
  
  // Request the data and store it
  pressure = SW01.getPressure();
  alt = SW01.getAltitude(101325);
  humidity = SW01.getHumidity();
  tempC = SW01.getTempC(); // Temperature in Celcuis
  tempF = SW01.getTempF(); // Temperature in Farenheit
  lux = SL01.getLUX();
  uvA = SL01.getUVA();
  uvB = SL01.getUVB();
  uvB_index = SL01.getUVIndex();
  
  Serial.print("SI01: ");
  if ( (lastPrint + PRINT_SPEED) < millis()) {
    printGyro();  // Print "G: gx, gy, gz"
    printAccel(); // Print "A: ax, ay, az"
    printMag();   // Print "M: mx, my, mz"
    printAttitude(); // Print Roll, Pitch and G-Force

    date = SN01.getDate();
    // Get the time from the GPS 
    time = SN01.getTime();
    // Get the latitude from GPS
    latitude = SN01.getLatitude();
    // Get the longitude from GPS
    longitude = SN01.getLongitude();
    lastPrint = millis(); // Update lastPrint time
  }
  // Display the recoreded data over the Serial Monitor 
  
  Serial.print("SW01: ");
  Serial.print("Pressure: ");
  Serial.print(pressure);
  Serial.print(" Pa, ");

  Serial.print("Altitude: ");
  Serial.print(alt);
  Serial.print(" m, ");

  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print(" %, ");

  Serial.print("Temperature: ");
  Serial.print(tempF);
  Serial.println(" F"); 

  Serial.print("SL01: ");
  Serial.print("Ambient Light Level: ");
  Serial.print(lux);
  Serial.print(" LUX, ");
  
  Serial.print("UVA Intersity: ");
  Serial.print(uvA);
  Serial.print(" uW/m^2, ");

  Serial.print("UVB Intensity: ");
  Serial.print(uvB);
  Serial.print(" uW/m^2, ");
  Serial.print("UVB Index: ");
  Serial.println(uvB_index);

  Serial.print("SN01: ");
  Serial.print("GPS Time: ");
  Serial.print(time);
  Serial.print(", ");
  Serial.print("GPS Date: ");
  Serial.print(date);
  Serial.print(", ");
  Serial.print("GPS Latitude: ");
  Serial.print(latitude);
  Serial.print(", ");
  Serial.print("GPS longitude: ");
  Serial.println(longitude);
  
  // Small delay between sensor reads  
  delay(DELAY_TIME);
}

void printGyro(void) {
  Serial.print("G: ");
  Serial.print(SI01.getGX(), 2);
  Serial.print(", ");
  Serial.print(SI01.getGY(), 2);
  Serial.print(", ");
  Serial.print(SI01.getGZ(), 2);
  Serial.print(", ");
  

}

void printAccel(void) {
  Serial.print("A: ");
  Serial.print(SI01.getAX(), 2);
  Serial.print(", ");
  Serial.print(SI01.getAY(), 2);
  Serial.print(", ");
  Serial.print(SI01.getAZ(), 2);
  Serial.print(", ");
}

void printMag(void) {
  Serial.print("M: ");
  Serial.print(SI01.getMX(), 2);
  Serial.print(", ");
  Serial.print(SI01.getMY(), 2);
  Serial.print(", ");
  Serial.print(SI01.getMZ(), 2);
  Serial.print(", ");

}

void printAttitude(void) {
  Serial.print("Roll: ");
  Serial.print(SI01.getRoll(), 2);
  Serial.print(", ");
  Serial.print("Pitch :");
  Serial.print(SI01.getPitch(), 2);
  Serial.print(", ");
  Serial.print("GForce :");
  Serial.println(SI01.getGForce(), 2);
}

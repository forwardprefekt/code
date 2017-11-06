#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "IRLibAll.h"
#include <IRLibSendBase.h>
#include <IRLib_HashRaw.h>    

#define OLED_RESET 4
#define aref_voltage 3.3;

// Arduino NANO ATMEGA328 - TMP36 Temp sensor on Pin A6, ir receiveer on D2, ir xmitter d3
// Follow tutorials online for IR hookup, i did 2n2222 transistor switch 5v, and SSD1306 cut+paste.

// I made this because the NEWAIR AC is terrible. It never stops running the fan, turns off and on the compressor for random reasons (not because its actually cooled the room of course). So this just sits pointed at it, and will turn it off and on full bore. 

// As a side note, even though I am not during IR Receive, I was able to save a ton of space in the sketch by decreasing the RECV_BUF_LENGTH in IRLibGlobals.h. 

Adafruit_SSD1306 display(OLED_RESET);

IRsendRaw mySender;

int curtemp = 0;
int curreading = 0;
int TMP36_pin = 1;

//IRrecvPCI myReceiver(2);


#define RAW_DATA_LEN 150

// This is the necessary IR code to turn off the NEWAIR AC
uint16_t offcmd[RAW_DATA_LEN]={
  5886, 7406, 546, 558, 546, 1610, 550, 554, 
  550, 550, 550, 1610, 550, 554, 546, 554, 
  550, 550, 554, 550, 554, 550, 550, 1610, 
  546, 558, 546, 1610, 550, 1606, 550, 554, 
  550, 554, 550, 550, 554, 550, 550, 550, 
  554, 550, 554, 550, 550, 550, 554, 550, 
  554, 550, 550, 550, 554, 550, 554, 550, 
  550, 554, 550, 1606, 550, 554, 550, 554, 
  550, 550, 554, 550, 550, 550, 554, 550, 
  554, 550, 550, 554, 550, 550, 554, 550, 
  550, 550, 554, 550, 554, 550, 550, 554, 
  550, 550, 554, 550, 550, 554, 550, 550, 
  554, 1606, 550, 554, 550, 550, 554, 550, 
  550, 550, 554, 550, 554, 550, 554, 550, 
  550, 550, 554, 550, 554, 550, 550, 550, 
  554, 550, 554, 550, 550, 550, 554, 550, 
  554, 550, 550, 550, 554, 550, 554, 550, 
  550, 550, 554, 1606, 550, 554, 550, 550, 
  554, 1606, 518, 6230, 514, 1000};

// This turns on the AC, manual, 62 degrees, fan medium (should be high, but close enough)
uint16_t oncmd[RAW_DATA_LEN]={
 5870, 7418, 538, 562, 542, 1614, 546, 558, 
  542, 562, 542, 1614, 542, 562, 542, 562, 
  542, 558, 546, 558, 542, 558, 546, 1614, 
  542, 562, 538, 1618, 542, 1618, 538, 566, 
  538, 562, 542, 1614, 542, 562, 542, 562, 
  542, 1614, 542, 562, 542, 1614, 542, 562, 
  542, 562, 542, 558, 546, 558, 546, 558, 
  546, 554, 546, 558, 546, 558, 546, 554, 
  546, 558, 546, 558, 546, 554, 550, 554, 
  546, 558, 546, 554, 550, 554, 546, 558, 
  546, 558, 546, 554, 550, 554, 546, 554, 
  550, 554, 550, 554, 546, 554, 550, 554, 
  550, 1610, 546, 558, 546, 554, 546, 558, 
  546, 554, 550, 554, 550, 554, 550, 554, 
  546, 554, 550, 554, 550, 554, 546, 554, 
  550, 554, 550, 554, 546, 554, 550, 554, 
  550, 554, 550, 1610, 542, 558, 546, 558, 
  546, 1610, 546, 558, 546, 1610, 550, 554, 
  546, 1614, 510, 6234, 510, 1000};


bool ison;

void setup() {
  analogReference(EXTERNAL); // jumped from pin 3v3 to rcf
  Serial.begin(9600);
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  delay(2000);
  //myReceiver.enableIRIn();
}

// try to calm down the jumpiness a bit
float temps[10] = { 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0 };

float getTemp() {
  curreading = analogRead(TMP36_pin);
  float voltage = curreading * aref_voltage;
  voltage /= 1024.0; //tmp36 math
  float temperatureC = (voltage - 0.5) * 100 ;
  float temperatureF = (temperatureC * 9.0 / 5.0) + 32.0;
  for (int i=9;i>0;i--) {
    temps[i] = temps[i-1];
    //Serial.println(temps[i]);
  }
  temps[0] = temperatureF;
  if (temps[9] == 0.0) {
    Serial.println("b");
  } else {
    int accum = 0;
    for (int i=0;i<=9;i++) {
      accum += temps[i];
    }
    temperatureF = accum / 10.0;
  }
  return(temperatureF); 
    
}

void drawscreen(float tempval) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.print("AC:");
  display.println(ison);
//  if (ison) {
//    display.println("AC ON");
//  } else {
//    display.println("AC OFF");
//  }
  display.setTextSize(3);
  display.print(tempval);
  display.display();
}



void loop() {
  float tempval = getTemp();
  drawscreen(tempval);
  // TODO: Replace with PID ;)
  if (tempval < 72 && ison) {
    mySender.send(offcmd,RAW_DATA_LEN,38);  
    ison = false;
  }
  if (tempval > 77 && !ison) {
     ison = true;
     mySender.send(oncmd,RAW_DATA_LEN,38);
  }
  delay(2000);
}

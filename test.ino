#include <SoftwareSerial.h>

int LED = 13;
int toggle = 0;

/** 
 *  Serial1 is pins 19 RX and 18 TX
 *  Bluetooth RX goes to Arduino TX
 *  Bluetooth TX goes to Arduino RX
 * 
 */

void setup()
{
    Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
    Serial1.begin(9600);
    
    Serial.setTimeout(1);
    Serial1.setTimeout(1);
    
    Serial.println("Running example: Servo motor actuation using messaging");
    pinMode(LED, OUTPUT);
}

void loop(){

  if (Serial1.available()) {
    Serial.write(Serial1.read());
    toggle = toggle == 0 ? 1 : 0;
  }
   

  if (Serial.available()) {
    Serial1.write(Serial.read());
  }

  digitalWrite(LED, toggle == 0 ? LOW : HIGH);
}

// This #include statement was automatically added by the Particle IDE.
#include <Adafruit_DHT.h>
#include "math.h"

// This #include statement was automatically added by the Particle IDE.
#include <Adafruit_DHT.h>
#define DHTPIN 2            // what pin we're connected to
#define DHTTYPE DHT22       // DHT 22 (AM2302)
#define INTERVAL 10000       // number of milliseconds between checks
                            // Reading temperature or humidity takes about 250 milliseconds!
                            // Sensor readings may also be up to 2 seconds 'old' (its a 
                            // very slow sensor)

// Connect pin 1 (on the left) of the sensor to +3.3V
// Connect pin 2 of the sensor to whatever your DHTPIN is
// Connect pin 4 (on the right) of the sensor to GROUND
// Connect a 10K resistor from pin 2 (data) to pin 1 (power) of the sensor

// Initialise an object to represent the DHT22 sensor
DHT dht(DHTPIN, DHTTYPE);
Servo myservo;
// Declare globa variables for the readings and the time last checked
double temp;
double hum;
int airValue = 2775;
int waterValue = 1360;
int soilMoisture;
int soilPercent;
int led1 = D6;
int pos = 0;
unsigned long lastCheck = 0;

// Function that can be called from the Particle console
void readSensor() {
    hum = dht.getHumidity();
    temp = dht.getTempCelcius();
}
void ledOn() {
    digitalWrite(led1, HIGH);
}
void ledOff() {
    digitalWrite(led1, LOW);
}
void waterTapOn(){
      for(pos = 0; pos < 180; pos += 1)   // goes from 0 degrees to 180 degrees 
  {                                   // in steps of 1 degree 
    myservo.write(pos);               // tell servo to go to position in variable 'pos' 
    delay(15);                        // waits 15ms for the servo to reach the position 
  }  // Debug message
  delay(5000);
        for(pos = 180; pos>=1; pos-=1)      // goes from 180 degrees to 0 degrees 
  {                                
    myservo.write(pos);               // tell servo to go to position in variable 'pos' 
    delay(15);                        // waits 15ms for the servo to reach the position 
  } 
}
// void waterTapOff(){
//       for(pos = 180; pos>=1; pos-=1)      // goes from 180 degrees to 0 degrees 
//   {                                
//     myservo.write(pos);               // tell servo to go to position in variable 'pos' 
//     delay(15);                        // waits 15ms for the servo to reach the position 
//   } 
// }

// Callback function to allow the Particle console access to readSensor()
int checkHandler(String command) {
readSensor();
return 1;
}

int on(String command)
{
    ledOn();
    return 1;
}
int off(String command){
    ledOff();
return 1;
}

int waterOn(String command){
    waterTapOn();
return 1;
    
}
// int waterOff(String command){
//     waterTapOff();
// return 1;
// }
    


void setup() {
    // setups sensors to allow them to start producing values or outputing results
    dht.begin();
    myservo.attach(D8);
    pinMode(led1, OUTPUT);
    // Declare variables that can be seen in the Particle console
    Particle.variable("temperature", temp);
    Particle.variable("humidity", hum);
    Particle.variable("moisturePercentage", soilPercent);
    Particle.variable("moisture", soilMoisture);
    Particle.function("readSensor", checkHandler);
    Particle.function("ledOn", on);
    Particle.function("ledOff", off);
    Particle.function("waterOn", waterOn);
}

void loop() {
    // creates a time loop so that code only executes after a certain lenght of time
    if (lastCheck + INTERVAL < millis()) {
        lastCheck = millis();
        readSensor();
        soilMoisture = analogRead(A0);
        soilPercent = map(soilMoisture, airValue, waterValue, 0, 100);
        
        // Check if any reads failed and exit early (to try again).
        if (isnan(hum) || isnan(temp)) {
            Serial.println("Failed to read from DHT sensor!");
            return;
        }
        
        // Publish variables that values can be seen in the Particle console
        Particle.publish("temperature", String(temp), PRIVATE);
        Particle.publish("humidity", String(hum), PRIVATE);
        Particle.publish("moisture", String(soilMoisture), PRIVATE);
        Particle.publish("moisturePercetage", String(soilPercent), PRIVATE);
    
    }
}














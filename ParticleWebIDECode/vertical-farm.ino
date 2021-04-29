// This #include statement was automatically added by the Particle IDE.
#include <Adafruit_DHT.h>
#define DHTPIN 2            // what pin we're connected to
#define DHTTYPE DHT22       // DHT 22 (AM2302)
#define INTERVAL 10000       // number of milliseconds between checks
#define AIRVALUE 2775
#define WATERVALUE 1360

// Initialise an object to represent the DHT22 sensor
DHT dht(DHTPIN, DHTTYPE);
Servo myservo;
// Declare globa variables for the readings and the time last checked
double temp;
double hum;

int soilMoisture;
int soilPercent;
int led1 = D6;
int ledTemp = D5;
int ledHum = D4;
int ledWater = D7;
int pos = 0;
unsigned long lastCheck = 0;

// Function that can be called from the Particle console
void readSensor() {
    hum = dht.getHumidity();
    temp = dht.getTempCelcius();
}
//turn on LED for Lights
void ledOn() {
    digitalWrite(led1, HIGH);
}
void ledOff() {
    digitalWrite(led1, LOW);
}
// turn on LEDs for tmeperature notification
void ledTempOn() {
    digitalWrite(ledTemp, HIGH);
    delay(2000);
    digitalWrite(ledTemp, LOW);
}
//turn on LEDs for humidity notification
void ledHumOn() {
    digitalWrite(ledHum, HIGH);
    delay(2000);
    digitalWrite(ledHum, LOW);
}



void waterTapOn(){
      for(pos = 0; pos < 45; pos += 1)   // goes from 0 degrees to 45 degrees 
  {                                   // in steps of 1 degree 
    myservo.write(pos);               // tell servo to go to position in variable 'pos' 
    delay(15);                        // waits 15ms for the servo to reach the position 
  }  // Debug message
  delay(5000);
        for(pos = 45; pos>=1; pos-=1)      // goes from 45 degrees to 0 degrees 
  {                                
    myservo.write(pos);               // tell servo to go to position in variable 'pos' 
    delay(15);                        // waits 15ms for the servo to reach the position 
  } 
}


// Callback functions to allow the Particle console access
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

int tempNotOn(String command)
{
    ledTempOn();
    return 1;
}

int humNotOn(String command)
{
    ledHumOn();
    return 1;
}

void setup() {
    // setups sensors to allow them to start producing values or outputing results
    dht.begin();
    myservo.attach(D8);
    pinMode(led1, OUTPUT);
    pinMode(ledTemp, OUTPUT);
    pinMode(ledHum, OUTPUT);
    // Declare variables that can be seen in the Particle console
    Particle.variable("temperature", temp);
    Particle.variable("humidity", hum);
    Particle.variable("moisturePercentage", soilPercent);
    Particle.variable("moisture", soilMoisture);
    Particle.function("readSensor", checkHandler);
    Particle.function("ledOn", on);
    Particle.function("ledOff", off);
    Particle.function("ledTempOn", tempNotOn);
    Particle.function("ledHumOn", humNotOn);
    Particle.function("waterOn", waterOn);
}

void loop() {
    // creates a time loop so that code only executes after a certain lenght of time
    if (lastCheck + INTERVAL < millis()) {
        lastCheck = millis();
        readSensor();
        
        //sets variable to read data from pin A0
        soilMoisture = analogRead(A0);
        //creates a percentage by mapping the sensor data between the two constant variables
        soilPercent = map(soilMoisture, AIRVALUE, WATERVALUE, 0, 100);
        
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














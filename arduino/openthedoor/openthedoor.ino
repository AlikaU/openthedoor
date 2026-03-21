/*
 * Created by ArduinoGetStarted.com
 *
 * This example code is in the public domain
 *
 * Tutorial page: https://arduinogetstarted.com/tutorials/arduino-switch
 */

#include <ezButton.h>
const int PINS[] = {2, 3, 4};
const int NUM_SWITCHES = 3;
ezButton switches[NUM_SWITCHES] = {PINS[0], PINS[1], PINS[2]};


void setup() {
  Serial.begin(9600);
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].setDebounceTime(100);
  }
}

void loop() {
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].loop();
    if (switches[i].isPressed())
      Serial.println("Switch " + String(PINS[i]) + ": OFF -> ON");
    if (switches[i].isReleased())
      Serial.println("Switch " + String(PINS[i]) + ": ON -> OFF");
  }
}

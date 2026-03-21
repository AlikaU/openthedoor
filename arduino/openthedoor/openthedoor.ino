#include <ArduinoJson.h>
#include <ezButton.h>

const int NUM_SWITCHES = 3;
const char* NAMES[] = {"shiny", "fluffy", "door"};
ezButton switches[NUM_SWITCHES] = {2, 3, 4};

void setup() {
  Serial.begin(9600);
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].setDebounceTime(100);
  }
}

void loop() {
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].loop();
    bool pressed = switches[i].isPressed();
    bool released = switches[i].isReleased();
    if (pressed || released) {
      JsonDocument doc;
      doc["name"] = NAMES[i];
      doc["on"] = pressed;
      serializeJson(doc, Serial);
      Serial.println();
    }
  }
}

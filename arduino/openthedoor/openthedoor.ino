#include <ArduinoJson.h>
#include <ezButton.h>

const int NUM_SWITCHES = 3;
const int PINS[] = {2, 3, 4};
ezButton switches[NUM_SWITCHES] = {2, 3, 4};
unsigned long lastHeartbeat = 0;

void setup() {
  Serial.begin(9600);
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].setDebounceTime(100);
  }
}

void loop() {
  for (int i = 0; i < NUM_SWITCHES; i++) {
    switches[i].loop();
    if (switches[i].isPressed()) sendState(i, true);
    if (switches[i].isReleased()) sendState(i, false);
  }
  if (millis() - lastHeartbeat >= 500) {
    for (int i = 0; i < NUM_SWITCHES; i++)
      sendState(i, switches[i].getState() == LOW);
    lastHeartbeat = millis();
  }
}

void sendState(int i, bool on) {
  JsonDocument doc;
  doc["pin"] = PINS[i];
  doc["on"] = on;
  serializeJson(doc, Serial);
  Serial.println();
}

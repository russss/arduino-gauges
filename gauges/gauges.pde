#define PORTS 14
#define STEP 10
#define UPDATEINT 3

int ptmp;
int vtmp;
int target[PORTS];
int prev[PORTS];
float current[PORTS];

void setup()
{
  Serial.begin(9600);
  ptmp = 0;
  vtmp = 0;
  for (int i = 0; i < PORTS; i++) {
    target[i] = prev[i] = current[i] = 0; 
  }
}

void loop() {
   int val;
   if (Serial.available()) {
     val = Serial.read();
     if (val == 13 || val == 10) {
       int p = constrain(ptmp, 0, PORTS-1);
       target[p] = constrain(vtmp, 0, 255);
       prev[p] = (int)current[p];
     } else {
       ptmp = vtmp;
       vtmp = val;
     }
   }
   for (int i = 0; i < PORTS; i++) {
     updatePin(i); 
   }
   delay(1000/STEP);
}

void updatePin(int pin) {
  if (current[pin] != target[pin]) {
    float value = current[pin];
    float st = (target[pin] - prev[pin]) / (float)(STEP * UPDATEINT);
    if (abs(current[pin] - target[pin]) < abs((int)(st+2))) {
      value = (float)target[pin];
    } else {
      value += st; 
    }
    analogWrite(pin, (int)value);
    current[pin] = value;
  }
}

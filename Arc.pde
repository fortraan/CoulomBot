class Arc {
  float x, y;
  float w, h;
  float a, b;
  float s;
  int timer, last;
  int direction;
  float rotation;
  
  Arc(float x, float y, float w, float h, float a, float b, float s) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.a = a;
    this.b = b;
    this.s = s;
    last = millis();
    timer = (int) random(500, 5000);
    direction = (int) Math.copySign(1, random(-1, 1));
    rotation = random(0, TWO_PI);
  }
  
  void draw() {
    int delta = millis() - last;
    timer -= delta; //<>//
    if (timer <= 0) {
      direction *= -1;
      timer = (int) random(500, 5000);
    }
    rotation += s * direction * (delta / 1000.0);
    arc(x, y, w, h, a + rotation, b + rotation);
    last = millis();
  }
}

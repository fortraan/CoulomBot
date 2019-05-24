class Goal {
  PGraphics graphics;
  PVector position;
  int size;
  
  Goal(PApplet applet, PVector position, int size) {
    this(applet.getGraphics(), position, size);
  }
  
  Goal(PGraphics graphics, PVector position, int size) {
    this.graphics = graphics;
    this.position = position;
    this.size = size;
  }
  
  void draw() {
    pushStyle();
    
    noStroke();
    fill(0, 255, 0);
    polygon(position.x, position.y, size, 6, 0);
    
    popStyle();
  }
}

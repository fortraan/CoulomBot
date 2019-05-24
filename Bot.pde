class Bot extends Particle {
  
  float maxCharge;
  boolean stateLocked;
  boolean lockedToPositive;
  
  Bot(PApplet applet, float mass) {
    this(applet.getGraphics(), mass);
  }
  
  Bot(PGraphics graphics, float mass) {
    super(graphics, 0, mass, false);
    SIZE = 16;
  }
  
  @Override
  void draw(List<Particle> particles, float timeElapsed) {
    applyPhysics(particles, timeElapsed);
    graphics.pushStyle();
    
    graphics.noStroke();
    graphics.fill(200);
    
    polygon(position.x, position.y, SIZE - 3, 6);
    
    if (charge > 0) {
      graphics.stroke(255, 0, 0);
    } else if (charge < 0) {
      graphics.stroke(0, 0, 255);
    } else {
      graphics.stroke(255);
    }
    graphics.strokeWeight(2);
    graphics.noFill();
    polygon(position.x, position.y, SIZE, 6);
  }
}

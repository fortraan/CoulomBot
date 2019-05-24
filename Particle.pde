import java.util.List;

class Particle {
  
  protected static final float COULOMBS_CONSTANT = 8987551787.3681764;
  
  protected int SIZE = 5;
  
  protected PGraphics graphics;
  
  protected float charge;
  protected float mass;
  protected boolean kinematic;
  
  protected PVector position;
  protected PVector velocity;
  
  protected PVector startPosition;
  
  boolean positionFixed;
  boolean chargeFixed;
  
  Particle(PApplet applet, float charge, float mass, boolean kinematic) {
    this(applet.getGraphics(), charge, mass, kinematic);
  }
  
  Particle(PGraphics graphics, float charge, float mass, boolean kinematic) {
    this.charge = charge;
    this.mass = mass;
    this.kinematic = kinematic;
    
    position = new PVector();
    velocity = new PVector();
    
    this.graphics = graphics;
  }
  
  void setPosX(float x) {
    position.x = x;
  }
  
  void setPosY(float y) {
    position.y = y;
  }
  
  void setVelX(float x) {
    velocity.x = x;
  }
  
  void setVelY(float y) {
    velocity.y = y;
  }
  
  void setIsKinematic(boolean kinematic) {
    this.kinematic = kinematic;
  }
  
  void setCharge(float charge) {
    this.charge = charge;
  }
  
  float getCharge() {
    return charge;
  }
  
  void applyPhysics(List<Particle> particles, float timeElapsed) {
    if (!kinematic && mode == Mode.SIMULATION) {
      PVector forces = new PVector();
      
      forces.add(velocity.copy().setMag(-1));
      
      for (Particle other : particles) {
        if (other == this || other.charge == 0) {
          continue;
        }
        PVector toOther = PVector.sub(other.position, this.position);
        if (toOther.mag() < 2 * SIZE) {
          // collision logic
          continue;
        } else {
          //float distance = (float) Math.hypot(abs(other.position.x - this.position.x), abs(other.position.y - this.position.y));
          float force = COULOMBS_CONSTANT * ((this.charge * other.charge) / sq(toOther.mag()));
          toOther.setMag(-force);
          forces.add(toOther);
        }
      }
      
      forces.div(mass).mult(timeElapsed);
      velocity.add(forces);
      
      // bounce logic
      if (position.x < SIZE) {
        velocity.x = max(5, 0.75 * Math.copySign(velocity.x, 1));
      }
      if (position.x > width - SIZE) {
        velocity.x = min(-5, 0.75 * Math.copySign(velocity.x, -1));
      }
      if (position.y < SIZE) {
        velocity.y = max(5, 0.75 * Math.copySign(velocity.y, 1));
      }
      if (position.y > height - SIZE) {
        velocity.y = min(-5, 0.75 * Math.copySign(velocity.y, -1));
      }
      
      PVector tempVelocity = velocity.copy();
      tempVelocity.mult(timeElapsed);
      position.add(tempVelocity);
      position.x = constrain(position.x, -0.5 * SIZE, width + 0.5 * SIZE);
      position.y = constrain(position.y, -0.5 * SIZE, height + 0.5 * SIZE);
    }
  }
  
  void draw(List<Particle> particles, float timeElapsed) {
    applyPhysics(particles, timeElapsed);
    
    graphics.pushStyle();
    
    graphics.noStroke();
    
    if (charge > 0.0000001) {
      graphics.fill(255, 0, 0);
    } else if (charge < -0.0000001) {
      graphics.fill(0, 0, 255);
    } else {
      graphics.fill(127);
    }
    
    graphics.ellipseMode(RADIUS);
    graphics.ellipse(position.x, position.y, SIZE, SIZE);
    
    graphics.popStyle();
  }
}

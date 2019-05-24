import java.util.List;

List<Particle> particles;
int lastTime;

int speedIndex;

final float[] speeds = {0.0001, 0.001, 0.01, 0.1, 1, 5, 10, 25, 50, 75, 100, 200, 500, 1000};

enum Mode {
  EDITOR,
  SIMULATION
}

Mode mode;
Particle selected, otherSelected;

Level level;

int selectionTimer;

boolean dragging;

boolean shiftDown;

long keyboardState;

int numParticles;

int particleLabelTimer;

void setup() {
  size(640, 480);
  background(0);
  
  speedIndex = 0;
  
  particles = new ArrayList<Particle>();
  
  loadLevel("level.json");
  
  lastTime = millis();
  
  mode = Mode.EDITOR;
}

void draw() {
  background(0);
  
  float speed = speeds[speedIndex];
  int now = millis();
  float deltaTime = (speed / 100f) * ((now - lastTime) / 1000f);
  
  level.goal.draw();
  
  stroke(255);
  noFill();
  for (Particle particle : particles) {
    particle.draw(particles, deltaTime);
  }
  
  if (selected != null) {
    stroke(255);
    float selectionTime = (now - selectionTimer) / (1000.0);
    float radius = selected.SIZE + 5 + 2 * sin(1.5 * selectionTime);
    polygon(selected.position.x, selected.position.y, radius, 6, selectionTime);
    float textY = selected.position.y + 15 + selected.SIZE;
    float textX = selected.position.x + 15 + selected.SIZE;
    textAlign(LEFT, CENTER);
    if (textY > height - 20) {
      textY -= 40;
    }
    if (textX > width - 65) {
      textX -= 40;
      textAlign(RIGHT, CENTER);
    }
    float charge = selected.getCharge();
    if (charge > 0.0000001) {
      fill(255, 0, 0);
    } else if (charge < -0.0000001) {
      fill(0, 0, 255);
    } else {
      fill(127);
    }
    if (selected == level.bot) {
      charge = level.bot.maxCharge;
    }
    text(String.format("%s\n%.2fkg", (charge > -0.0000001 && charge < 0) ? "0.00 C" : String.format("%.2f C", charge), selected.mass), textX, textY);
    
    if (selected.positionFixed) {
      stroke(255, 0, 0);
      pushMatrix();
      translate(selected.position.x, selected.position.y);
      translate(-2 * selected.SIZE, -2 * selected.SIZE);
      translate(-7, -7);
      for (int i = 0; i < 4; i++) {
        rotate(QUARTER_PI);
        line(-5, 0, 5, 0);
      }
      popMatrix();
    }
    
    if (selected.chargeFixed) {
      stroke(255, 255, 0);
      pushMatrix();
      translate(selected.position.x, selected.position.y);
      translate(2 * selected.SIZE, -2 * selected.SIZE);
      translate(7, -7);
      line(0, 6, 3, 0);
      line(3, 0, -3, 0);
      line(-3, 0, 0, -6);
      popMatrix();
    }
    
    if (dragging && !selected.positionFixed) {
      selected.setPosX(mouseX);
      selected.setPosY(mouseY);
    }
    
    if (otherSelected != null) {
      fill(127);
      PVector sPos = selected.position.copy();
      PVector oPos = otherSelected.position.copy();
      PVector between = PVector.sub(oPos, sPos);
      PVector lineStart = PVector.add(sPos, between.copy().setMag(radius + 5));
      PVector lineEnd = PVector.add(sPos, between.copy().setMag(between.mag() - 10));
      line(lineStart.x, lineStart.y, lineEnd.x, lineEnd.y);
      PVector textPoint = PVector.add(sPos, between.copy().mult(0.5));
      textAlign(CENTER, CENTER);
      pushMatrix();
      translate(textPoint.x, textPoint.y);
      float heading = between.heading();
      rotate(heading);
      translate(0, -max(selected.SIZE, otherSelected.SIZE) - 10);
      if (heading > HALF_PI || heading < -HALF_PI) {
        rotate(PI);
      }
      text(String.format("%.4fm", between.mag()), 0, 0);
      popMatrix();
    }
  }
  
  fill(127);
  
  if (mode == Mode.SIMULATION) {
    textAlign(LEFT, TOP);
    text(String.format("Current Speed: %.4f%%", speed), 5, 5);
  } else {
    int particleLabelTime = now - particleLabelTimer;
    if (particleLabelTime % 500 < 250 && particleLabelTime < 1500) {
      fill(255, 20, 20);
    } else {
      fill(127);
    }
    textAlign(LEFT, BOTTOM);
    text(String.format("Particles: %d/%d", numParticles, level.particleCount), 5, height - 5);
  }
  
  fill(127);
  textAlign(RIGHT, TOP);
  text((mode == Mode.EDITOR) ? "> EDITOR" : "> SIMULATION", width - 5, 5);
  
  if (mode == Mode.SIMULATION) {
    PVector between = PVector.sub(level.goal.position, level.bot.position);
    if (between.mag() < level.goal.size) {
      keyCode = 32;
      keyPressed();
    }
  }
  
  lastTime = now;
}

void mousePressed() {
  print("KeyCoded? ");
  println(key == CODED);
  print("KeyCode ");
  println(keyCode);
  if (mode == Mode.EDITOR) {
    Particle target = hoveredOver();
    if (shiftDown) {
      if (selected != null && target != otherSelected && target != selected) {
        println("Selecting target 2");
        otherSelected = target;
      }
    } else {
      if (target == otherSelected) {
        otherSelected = null;
      }
      if (target != selected) {
        selected = target;
        selectionTimer = millis();
      }
      if (selected != null) {
        dragging = true;
      }
    }
  }
}

void mouseReleased() {
  if (mode == Mode.EDITOR) {
    if (dragging) {
      dragging = false;
    }
  }
}

void keyPressed() {
  if (mode == Mode.SIMULATION) {
    if (key == '[' || key == ']') {
      if (key == '[') {
        speedIndex--;
      } else if (key == ']') {
        speedIndex++;
      }
      speedIndex = constrain(speedIndex, 0, speeds.length - 1);
    } else if (level.allowsBotControl) {
      if (key == 'a' || key == 'A') {
        level.bot.setCharge(level.bot.maxCharge);
      } else if (key == 's' || key == 'S') {
        level.bot.setCharge(0);
      } else if (key == 'd' || key == 'D') {
        level.bot.setCharge(-level.bot.maxCharge);
      }
    }
  } else {
    print("KeyCode: ");
    println(keyCode);
    if (selected != null) {
      if (key == '=' || key == '+') {
        if (!selected.chargeFixed) {
          if (selected == level.bot) {
            level.bot.maxCharge += 0.01;
          } else {
            selected.setCharge(selected.getCharge() + 0.01);
          }
        }
      } else if (key == '-' || key == '_') {
        if (!selected.chargeFixed) {
          if (selected == level.bot) {
            level.bot.maxCharge = max(level.bot.maxCharge - 0.01, 0);
          } else {
            selected.setCharge(selected.getCharge() - 0.01);
          }
        }
      } else if (keyCode == 8 && selected != level.bot && !(selected.chargeFixed || selected.positionFixed)) {
        particles.remove(selected);
        selected = null;
        numParticles--;
      }
    }
    
    if ((key == 's' || key == 'S')) {
      if (numParticles >= level.particleCount) {
        particleLabelTimer = millis();
      } else {
        Particle newParticle = new Particle(this, 0, 1, true);
        newParticle.setPosX(mouseX);
        newParticle.setPosY(mouseY);
        particles.add(newParticle);
        numParticles++;
      }
    }
    
    if (key == CODED && keyCode == SHIFT) {
      shiftDown = true;
    }
  }
  
  if (keyCode == 32) {
    if (mode == Mode.SIMULATION) {
      cursor();
      for (Particle particle : particles) {
        particle.position = particle.startPosition;
        particle.velocity.mult(0);
      }
      level.bot.setCharge(0);
      mode = Mode.EDITOR;
    } else {
      noCursor();
      for (Particle particle : particles) {
        particle.startPosition = particle.position.copy();
      }
      if (level.allowsBotControl) {
        if (level.bot.maxCharge < 0.0000001) {
          level.bot.maxCharge = 1;
        }
      } else {
        level.bot.charge = (level.bot.lockedToPositive) ? level.bot.maxCharge : -level.bot.maxCharge;
      }
      selected = null;
      otherSelected = null;
      dragging = false;
      mode = Mode.SIMULATION;
    }
  }
  
  if (key != CODED) {
    keyboardState |= (1 << (key - 32));
  }
}

void keyReleased() {
  if (mode == Mode.EDITOR) {
    if (key == CODED && keyCode == SHIFT) {
      shiftDown = false;
    }
  }
  
  if (key != CODED) {
    keyboardState ^= (1 << (key - 32));
  }
}

void loadLevel(String file) {
  print("Loading level \"");
  print(file);
  println("\"");
  JSONObject object = loadJSONObject(file);
  
  level = Level.parse(this, object);
  
  particles.addAll(level.providedParticles);
  
  particles.add(level.bot);
}

Particle hoveredOver() {
  for (Particle particle : particles) {
    if (Math.hypot(abs(particle.position.x - mouseX), abs(particle.position.y - mouseY)) < 2 * particle.SIZE) {
      return particle;
    }
  }
  return null;
}

void polygon(float x, float y, float radius, int numPoints) {
  polygon(x, y, radius, numPoints, 0);
}

void polygon(float x, float y, float radius, int numPoints, float rotation) {
  float angle = TWO_PI / numPoints;
  beginShape();
  for (float a = rotation; a < TWO_PI + rotation; a += angle) {
    vertex(x + cos(a) * radius, y + sin(a) * radius);
  }
  endShape(CLOSE);
}

boolean keyIsDown(char k) {
  if (k >= 32 && k < 127) {
    return (keyboardState & (1 << (key - 32))) > 0;
  }
  return false;
}

static PVector parseVector(JSONObject object) {
  return new PVector(object.getFloat("x"), object.getFloat("y"));
}

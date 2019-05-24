static class Level {
  String name;
  String description;
  int particleCount;
  Bot bot;
  Goal goal;
  List<Particle> providedParticles;
  boolean allowsBotControl;

  static Level parse(CoulomBot applet, JSONObject object) {
    println("Parsing level...");
    Level level = new Level();

    level.name = object.getString("name");
    level.description = object.getString("description");
    level.particleCount = object.getInt("particleCount");

    JSONObject botObject = object.getJSONObject("bot");

    level.bot = applet.new Bot(applet, botObject.getFloat("mass"));
    level.bot.position = parseVector(botObject.getJSONObject("position"));
    level.bot.positionFixed = botObject.getBoolean("positionFixed");
    level.bot.chargeFixed = botObject.getBoolean("chargeFixed");
    if (level.bot.chargeFixed) {
      level.bot.maxCharge = botObject.getFloat("maxCharge");
    }

    JSONObject goalObject = object.getJSONObject("goal");

    level.goal = applet.new Goal(applet,
      parseVector(goalObject.getJSONObject("position")),
      goalObject.getInt("size")
      );

    level.providedParticles = new ArrayList<Particle>();

    JSONArray providedParticleArray = object.getJSONArray("providedParticles");

    for (int i = 0; i < providedParticleArray.size(); i++) {
      JSONObject particleObject = providedParticleArray.getJSONObject(i);
      // I know this looks stupid, but Java can't do initialization of non-static
      // inner classes in a static context
      Particle particle = applet.new Particle(
        applet,
        particleObject.getFloat("charge"),
        particleObject.getFloat("mass"),
        particleObject.getBoolean("kinematic")
      );
      particle.positionFixed = particleObject.getBoolean("positionFixed");
      particle.chargeFixed = particleObject.getBoolean("chargeFixed");
      particle.position = parseVector(particleObject.getJSONObject("position"));
      level.providedParticles.add(particle);
    }
    
    level.allowsBotControl = object.getBoolean("allowsBotControl");
    
    if (!level.allowsBotControl) {
      level.bot.lockedToPositive = botObject.getBoolean("lockedToPositive");
    }
    
    print("Name: "); println(level.name);
    print("Description: "); println(level.description);
    print("Particle Count: "); println(level.particleCount);
    print("Bot Position: "); println(level.bot.toString());
    print("Goal Position: "); println(level.goal.toString());
    print("Allows Bot Control: "); println(level.allowsBotControl);

    return level;
  }
}

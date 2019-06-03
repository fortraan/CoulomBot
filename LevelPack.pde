import java.util.Iterator;

class LevelPack implements Iterator<Level> {
  CoulomBot applet;
  JSONArray levelArray;
  int levelIndex;
  String name;
  String prefix;
  
  LevelPack(CoulomBot applet, String prefix, JSONObject object) {
    this.applet = applet;
    this.prefix = prefix;
    name = object.getString("name");
    levelArray = object.getJSONArray("levels");
    levelIndex = 0;
    for (int i = 0; i < getNumLevels(); i++) {
      String path = sketchPath("data/" + prefix + "/" + levelArray.getString(i));
      if (!new File(path).exists()) {
        throw new RuntimeException(String.format("Could not find level %d: \"%s\"", i, levelArray.getString(i)));
      }
    }
  }
  
  int getNumLevels() {
    return levelArray.size();
  }
  
  @Override
  boolean hasNext() {
    return levelIndex < getNumLevels();
  }
  
  @Override
  Level next() {
    if (!hasNext()) {
      return null;
    }
    String path = prefix + "/" + levelArray.getString(levelIndex++);
    print("Loading level from \"");
    print(path);
    println("\"");
    return Level.parse(applet, loadJSONObject(path));
  }
  
  @Override
  void remove() {
    if (!hasNext()) {
      throw new IndexOutOfBoundsException("Iterator exhausted");
    }
    levelIndex++;
  }
  
  String getName() {
    return name;
  }
}

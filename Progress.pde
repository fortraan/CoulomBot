import java.util.List;
import java.util.Map;

class Progress {
  List<String> completedPacks;
  Map<String, Integer> completedLevels;
  
  Progress() {
    completedPacks = new ArrayList<String>();
    completedLevels = new HashMap<String, Integer>();
  }
  
  Progress(JSONObject object) {
    JSONArray packArray = object.getJSONArray("completedPacks");
    JSONArray levelArray = object.getJSONArray("completedLevels");
    
    completedPacks = new ArrayList<String>();
    completedLevels = new HashMap<String, Integer>();
    
    for (int i = 0; i < packArray.size(); i++) {
      completedPacks.add(packArray.getString(i));
    }
    
    for (int i = 0; i < levelArray.size(); i++) {
      JSONObject level = levelArray.getJSONObject(i);
      completedLevels.put(level.getString("pack"), level.getInt("number"));
    }
  }
  
  boolean hasCompleted(String pack) {
    return completedPacks.contains(pack);
  }
  
  int numCompleted(String pack) {
    if (!completedLevels.containsKey(pack)) {
      return 0;
    }
    return completedLevels.get(pack);
  }
  
  void onLevelComplete(String pack) {
    completedLevels.put(pack, numCompleted(pack) + 1);
  }
  
  void onPackComplete(String pack) {
    completedPacks.add(pack);
  }
  
  void store() {
    JSONObject object = new JSONObject();
    
    JSONArray packArray = new JSONArray();
    for (String pack : completedPacks) {
      packArray.append(pack);
    }
    
    JSONArray levelArray = new JSONArray();
    for (Map.Entry<String, Integer> entry : completedLevels.entrySet()) {
      JSONObject levelObject = new JSONObject();
      levelObject.setString("pack", entry.getKey());
      levelObject.setInt("number", entry.getValue());
      levelArray.append(levelObject);
    }
    
    object.setJSONArray("completedPacks", packArray);
    object.setJSONArray("completedLevels", levelArray);
    
    saveJSONObject(object, "data/progress.json");
  }
}

import java.util.*;
import java.io.File;

int RESOURCE_COUNT = 8; // Total number of distinct resources used in simulation

public class Resource {

  private Map<Integer, Double> resource_map; // Stores interaction strengths between this resource and others
  public int resource_num;                   // Unique ID/index for this resource

  // Constructor for randomly generating interaction profile
  public Resource(int resource_num_) {
    resource_num = resource_num_;
    generateResourceMap(); // Fill resource_map with randomized values
  }
  
  // Constructor for loading resource from saved JSON data
  public Resource(int resource_num_, JSONObject resource_data) {
    resource_num = resource_num_;
    setResourceMap(resource_data); // Populate map from serialized content
  }

  // Initializes (clears) the resource_map
  private void resetResourceMap() {
    resource_map = new HashMap<>();
  }

  // Generates random interaction values with other resources
  private void generateResourceMap() {
    resetResourceMap(); // Ensure map is clean

    Random rand = new Random(); // Standard Java RNG

    for (int i=0; i<RESOURCE_COUNT; i++) {
      double effect = -1 + rand.nextDouble() * 2; // Range [-1, 1]
      effect *= random(1); // Apply extra Processing-style randomness
      resource_map.put(i, effect); // Assign effect strength to each resource
    }
  }
  
  // Loads interaction strengths from JSONObject
  private void setResourceMap(JSONObject resource_data) {
    resetResourceMap(); // Clear current map

    Set<String> keys = resource_data.keys(); // Read resource keys from JSON
    for (String key2 : keys) {
      resource_map.put(Integer.parseInt(key2), (double) resource_data.get(key2)); // Store parsed key-effect pairs
    }
  }

  // Accessor for full interaction map
  public Map<Integer, Double> getResourceMap() {
    return resource_map;
  }

  // Retrieves effect strength between this resource and another
  public Double getResourceEffect(Resource other) {
    return resource_map.get(other.resource_num);
  }

  // Converts resource_map to human-readable string format
  @Override
  public String toString() {
    String s = "";
    for (Integer i : resource_map.keySet()) {
      s += i.toString() + ": " + resource_map.get(i) + "\n"; // List each interaction effect
    }
    s += "\n\n";
    return "Resource Map " + resource_num + ":\n" + s; // Include resource identifier
  }
}


public class ResourceFactory {
  public Map<Integer, Resource> resource_factory_map; // Stores all resources indexed by their resource_num

  // Constructor for random resource generation
  public ResourceFactory() {
    generateResources(); // Create and store resources using internal logic
  }

  // Constructor for loading from file
  public ResourceFactory(String filename) {
    loadResources(filename); // Deserialize previously saved resources
  }

  // Populates map with randomly generated resources and persists to disk
  public void generateResources() {
    resetResourceFactoryMap(); // Clear factory state
    
    for (int i=0; i<RESOURCE_COUNT; i++) {
      Resource resource = new Resource(i); // Create new resource with random interaction map
      resource.generateResourceMap();      // Redundant—already called by constructor, could be removed
      resource_factory_map.put(i, resource); // Add to factory map
    }
    saveResources(); // Save generated data to file
  }

  // Saves current resource map to a timestamped JSON file
  private boolean saveResources() {
    File dataFolder = new File("data"); // Target directory for data files

    if (!dataFolder.exists()) {
        dataFolder.mkdirs(); // Ensure data folder exists
    }

    JSONObject json = new JSONObject(); // Container for all resource maps
    JSONObject key_data;

    for (Integer key1 : resource_factory_map.keySet()) {
      key_data = new JSONObject();

      Resource resource = resource_factory_map.get(key1); // Grab resource by ID
      Map<Integer, Double> resource_map = resource.getResourceMap(); // Extract map

      for (Integer key2 : resource_map.keySet()) {
        key_data.setDouble(Integer.toString(key2), resource_map.get(key2)); // Serialize each interaction
      }

      json.setJSONObject(Integer.toString(key1), key_data); // Assign full map to resource ID
    }

    // Create filename using timestamp
    int timestamp = year() * 100000000 + month() * 1000000 + day() * 10000 + hour() * 100 + minute(); 
    String filename = "data/" + timestamp + ".json";

    saveJSONObject(json, filename); // Write to disk
    println("Saved " + filename + " successfully."); // Confirm success
    return true;
  }
  
  // Loads resource maps from a previously saved JSON file
  private boolean loadResources(String filename) {
    resetResourceFactoryMap(); // Prepare empty map

    JSONObject json = loadJSONObject(filename); // Load JSON content
    Set<String> keys = json.keys();             // Get resource keys
    
    setResourceCount(keys.size()); // Dynamically adjust resource count based on file

    for (String key1_s : keys) {
      int key1 = Integer.parseInt(key1_s);
      JSONObject key_data = json.getJSONObject(key1_s); // Extract each resource's data

      Resource resource = new Resource(key1, key_data); // Reconstruct resource object
      resource_factory_map.put(key1, resource);         // Store in factory map
    }

    println("Successfully reconstructed resource_factory_map from " + filename + ".");
    return true;
  }
  
  // Clears internal map for regeneration/loading
  private void resetResourceFactoryMap() {
    resource_factory_map = new HashMap<>();
  }

  // Updates global resource count—used during deserialization
  private void setResourceCount(int count) {
    RESOURCE_COUNT = count;
  }

  // Retrieves a specific resource object by its ID
  public Resource getResource(int resource_num_) {
    return resource_factory_map.get(resource_num_);
  }

  // Provides a basic overview of the factory contents
  @Override
  public String toString() {
    return "Factory Resource Map: " + resource_factory_map;
  }
}

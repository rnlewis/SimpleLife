class World {
  ResourceFactory resource_factory;     // Factory for generating and storing resource types
  List<Life> lives;                     // List of all Life entities in the simulation

  // Constructor initializes the world dimensions and spawns entities
  public World(int w, int h) {
    resource_factory = new ResourceFactory(); // Create randomized resource interactions
    lives = new ArrayList<Life>();            // Initialize empty population
    generateLives();                          // Populate the world with Life instances
  }
  
  // Creates and places 1000 Life entities with randomized starting states
  private void generateLives() {
    Random rand = new Random();  // RNG for resource selection
    Resource resource;           // Assigned resource for each Life
    PVector position;            // Initial position in simulation space
    PVector velocity;            // Initial velocity (starting at rest)
    PVector acceleration;        // Initial acceleration (starting at rest)
    Life life;                   // Temporary Life reference

    for (int i = 0; i < 1000; i++) {
      resource = resource_factory.getResource(rand.nextInt(RESOURCE_COUNT)); // Pick random resource

      position = PVector.fromAngle(random(TWO_PI))  // Random angle in circle
                 .mult(random(rad))                // Scaled to distance from center
                 .add(center);                     // Offset to actual center

      velocity = new PVector(0, 0);     // Start stationary
      acceleration = new PVector(0, 0); // Start with no force

      life = new Life(resource, position, velocity, acceleration); // Create new Life entity
      lives.add(life); // Add to simulation
    }
  }

  // Updates simulation state by computing pairwise interactions and physics
  public void updateLives() {
    Life life_a, life_b;

    for (int i = 0; i < lives.size(); i++) {
      life_a = lives.get(i);

      // Iterate only over remaining pairs to avoid redundancy
      for (int j = i + 1; j < lives.size(); j++) {
        life_b = lives.get(j);

        life_a.handleLife(life_b); // Apply force from B to A
        life_b.handleLife(life_a); // Apply force from A to B
      }

      life_a.update(); // Apply movement and constraints
    }
  }

  // Visual rendering of all Life entities
  public void showLives() {
    for (int i = 0; i < lives.size(); i++) {
      lives.get(i).show(); // Invoke display logic for each entity
    }
  }
}

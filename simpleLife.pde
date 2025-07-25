import controlP5.*; // Import ControlP5 library for GUI components (sliders etc.)

ControlP5 cp5;      // GUI controller
World world;        // Primary simulation container
PVector center;     // Center point of simulation boundary
float rad;          // Radius of boundary circle
float strength, effect_dist, velocity_max; // Simulation parameters controlled by sliders

void setup() {
  size(600, 600); // Create square canvas
  center = new PVector(width/2, height/2); // Center of screen
  rad = width/4; // Set radius of the circular boundary

  frameRate(60); // Set target frame rate
  background(255); // White background at startup

  cp5 = new ControlP5(this); // Initialize ControlP5 interface

  // Strength slider: controls magnitude of resource effect forces
  cp5.addSlider("strength")
     .setPosition(10, height * 8/9)       // Bottom-left quadrant placement
     .setSize(200, 10)                    // Horizontal slider dimensions
     .setRange(-10.0, 10.0)               // Full range of effect strength
     .setValue(0.0)                       // Default neutral force
     .setNumberOfTickMarks(21);          // Discrete steps from -10 to +10

  // Effect distance slider: sets interaction cutoff radius as fraction of domain
  cp5.addSlider("effect_dist")
     .setPosition(10, height * 8/9 + 20)  // Slightly below the strength slider
     .setSize(200, 10)
     .setRange(0.0, 1.0)                  // Proportion of radius
     .setValue(0.25)                      // Default value (quarter distance)
     .setNumberOfTickMarks(100);         // Fine-grained control

  // Velocity cap slider: limits speed of entities
  cp5.addSlider("velocity_max")
     .setPosition(275, height * 8/9)      // Right side of slider area
     .setSize(200, 10)
     .setRange(0.0, 10.0)
     .setValue(2.0)                       // Default max velocity
     .setNumberOfTickMarks(100);         // High resolution control

  // Initialize parameters explicitly
  strength = 0.0;
  effect_dist = 0.25;
  velocity_max = 2.0;

  world = new World(width, height); // Instantiate simulation world
}

// Draws the circular boundary for simulation constraints
void draw_boundary() {
   stroke(255, 100); // Semi-transparent white stroke
   strokeWeight(2);  // Thin line
   noFill();         // Transparent interior
   circle(center.x, center.y, 2*rad); // Diameter = 2 × radius
}

// Main draw loop executed each frame
void draw() {
  background(0); // Clear canvas with black background
  world.updateLives(); // Update physics and interactions of entities
  world.showLives();   // Render entities to screen
  draw_boundary();     // Overlay circular domain boundary
}

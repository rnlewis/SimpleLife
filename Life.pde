public class Life {

  // Represents the type or attributes this entity is linked to
  Resource resource;

  // Physics-related vectors for movement and force application
  PVector position;
  PVector velocity;
  PVector acceleration;

  // Color used in rendering, encoded in HSB initially
  int color_;

  // Constructor initializes all vectors and derives visual identity from resource properties
  public Life(Resource r, PVector pos, PVector vel, PVector acc) {
    resource = r;
    position = pos.copy();         // Clone to avoid reference sharing
    velocity = vel.copy();
    acceleration = acc.copy();

    colorMode(HSB, 100);           // Prepare for HSB-based coloring
    // Color encodes resource identity based on its ordinal value
    color_ = color(round(100 * r.resource_num / RESOURCE_COUNT), 50, 50);
  }

  // Applies force to this entity based on another entity's position and resource interaction
  private void handleLife(Life other) {
    PVector dir = other.position.copy();  // Get other's location
    float mag = dir.mag();                // Original magnitude (before offset)
    dir.sub(position);                    // Get direction vector to other
    if (dir.mag() > 2 * rad * effect_dist) return; // Skip if too far for interaction

    dir.normalize();                      // Normalize to get unit direction
    // Apply force based on resource effect and inverse distance weighting
    dir.mult(resource.getResourceEffect(other.resource).floatValue()
             * pow(10, strength)
             * (2 * rad * effect_dist) / mag);

    acceleration.add(dir);                // Aggregate effect into acceleration
  }

  // Updates the position of the entity, applying constraints and forces
  private void updatePos() {
    velocity.add(acceleration);           // Apply accumulated acceleration

    // Apply boundary force if outside the circular boundary (rad from center)
    PVector center_off = position.copy().sub(center);
    if (center_off.mag() > rad) {
      float m = velocity.mag();           // Save original speed
      velocity = center_off.copy().mult(-1); // Push back toward center
      velocity.limit(m * 0.5);            // Dampen speed after redirection
    }

    velocity.limit(velocity_max);         // Cap velocity to avoid runaway speed
    position.add(velocity);               // Move entity based on velocity
    acceleration.mult(0);                 // Reset acceleration for next frame
  }

  // Public method to perform entity update (movement, interaction logic)
  public void update() {
    updatePos();                          // Handles movement and boundaries
  }

  // Renders the entity visually with velocity trail
  public void show() {
    colorMode(RGB, 255);                  // Switch to RGB for rendering

    noFill();
    strokeWeight(12);
    stroke(255, 10);                      // Background glow effect
    point(position.x, position.y);

    strokeWeight(10);
    stroke(color_, 100);                  // Primary visual identity
    point(position.x, position.y);

    stroke(255);
    strokeWeight(1);
    PVector v = velocity.copy();          // Draw velocity vector line
    line(position.x, position.y, position.x + v.x, position.y + v.y);
  }
}

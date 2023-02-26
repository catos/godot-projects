using Godot;

public partial class player : CharacterBody2D
{
  [Export]
  public float MoveSpeed = 125.0f;

  [Export]
  public float JumpHeight = 80.0f;
  [Export]
  public float JumpTimeToPeak = 0.45f;
  [Export]
  public float JumpTimeToDescent = 0.25f;

  [Export]
  // public float JumpVelocity = ((2.0f * JumpHeight) / JumpTimeToPeak) * -1.0f;
  public float JumpVelocity { get; set; }
  [Export]
  public float JumpGravity { get; set; }
  [Export]
  public float FallGravity { get; set; }


  public player()
  {
	JumpVelocity = ((2.0f * JumpHeight) / JumpTimeToPeak) * -1.0f;
	JumpGravity = ((-2.0f * JumpHeight) / (JumpTimeToPeak * JumpTimeToPeak)) * -1.0f;
	FallGravity = ((-2.0f * JumpHeight) / (JumpTimeToDescent * JumpTimeToDescent)) * -1.0f;
  }

  public override void _PhysicsProcess(double delta)
  {
	Vector2 velocity = Velocity;
	
	// Add the gravity.
	if (!IsOnFloor())
	  velocity.Y += GetGravity(velocity) * (float)delta;

	// Handle Jump.
	if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
	{
	  // Jump(velocity);
	  velocity.Y = JumpVelocity;

	}

	// Get the input direction and handle the movement/deceleration.
	// As good practice, you should replace UI actions with custom gameplay actions.
	Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
	if (direction != Vector2.Zero)
	{
	  velocity.X = direction.X * MoveSpeed;
	}
	else
	{
	  velocity.X = Mathf.MoveToward(Velocity.X, 0, MoveSpeed);
	}

	Velocity = velocity;
	MoveAndSlide();
  }

  private float GetGravity(Vector2 velocity)
  {
	return Velocity.Y < 0.0 ? JumpGravity : FallGravity;
  }

  private void Jump(Vector2 velocity)
  {
	velocity.Y = JumpVelocity;
  }
}

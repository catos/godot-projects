using Godot;
using System;

public class Player : KinematicBody2D
{
  [Export]
  public int speed = 150;
  [Export]
  public int gravity = 300;

  private Vector2 input = Vector2.Zero;
  private Vector2 velocity = Vector2.Zero;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
    GD.Print("Ready gogogo");
	}

  public override void _PhysicsProcess(float delta)
  {
    base._PhysicsProcess(delta);
    
    input.x = Input.GetAxis("ui_left", "ui_right");
    input.y = Input.GetAxis("ui_up", "ui_down");

    velocity.y += gravity * delta;
    
    velocity.x = Mathf.Lerp(velocity.x, input.x * speed, 0.15f);   

    velocity = MoveAndSlide(velocity, Vector2.Up);

    if (Input.IsActionJustPressed("ui_up")) {
      velocity.y = -200;
    }
  }
}

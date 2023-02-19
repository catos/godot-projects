using Godot;
using System;

public partial class Player : CharacterBody2D
{
    public enum State
    {
        Idle,
        Walk,
        Jump,
        Fall,
    }

    public State state = State.Idle;
    public Vector2 direction = Vector2.Zero;
    public Vector2 velocity = Vector2.Zero;

	public const float Speed = 300.0f;
	public const float JumpVelocity = -800.0f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public override void _PhysicsProcess(double delta)
	{
		velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
			velocity.y += gravity * (float)delta;

		// Handle Jump.
		if (Input.IsActionJustPressed("ui_accept")) // && IsOnFloor())
			velocity.y = JumpVelocity;

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
        switch (state) {
            case State.Idle:
                Idle();
                break;
            case State.Walk:
                Walk();
                break;
        }

		Velocity = velocity;
		MoveAndSlide();
	}

    public void Idle() {
        velocity.x = Mathf.MoveToward(Velocity.x, 0, Speed);

        if (direction != Vector2.Zero) {
            state = State.Walk;
        }
    }

    public void Walk() {
        velocity.x = direction.x * Speed;

        if (direction == Vector2.Zero) {
            state = State.Idle;
        }
    }
}

using Godot;
using System;

public partial class Player : CharacterBody2D
{
	// Speed of the player movement
	[Export] public float Speed = 200f;

	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Vector2.Zero;

		if (Input.IsActionJustPressed("ui_right"))
			Position += new Vector2(16, 0);
		if (Input.IsActionJustPressed("ui_left"))
			Position += new Vector2(-16, 0);
		if (Input.IsActionJustPressed("ui_down"))
			Position += new Vector2(0, 16);
		if (Input.IsActionJustPressed("ui_up"))
			Position += new Vector2(0, -16);
	}
}

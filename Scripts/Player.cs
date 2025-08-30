using Godot;
using System;
// -----------------------------------------------------------------------------
// Player.cs
// Author: Emily Braithwaite
// Purpose: Manages player movement and other actions/controls.
// -----------------------------------------------------------------------------
public partial class Player : CharacterBody2D
{
	[Export]
	public TurnManager TurnManagerNode; // Calls NextTurn() on this whenever the player chooses an action

	private string facing = "left";
	private AnimatedSprite2D currentAnim;
	private AnimatedSprite2D idleAnim;
	private AnimatedSprite2D moveAnim;
	public override void _Ready()
	{
		idleAnim = GetNode<AnimatedSprite2D>("Idle");
		currentAnim = idleAnim;
	}
	public override void _PhysicsProcess(double delta)
	{
		// *** Handle Movement *** //
		// Move right
		if (Input.IsActionJustPressed("ui_right"))
		{
			Position += new Vector2(16, 0);
			TurnManagerNode.NextTurn("right");
		}
		// Move left
		if (Input.IsActionJustPressed("ui_left"))
		{
			Position += new Vector2(-16, 0);
			TurnManagerNode.NextTurn("left");
		}
		// Move down
		if (Input.IsActionJustPressed("ui_down"))
		{
			Position += new Vector2(0, 16);
			TurnManagerNode.NextTurn("down");
		}
		// Move up
		if (Input.IsActionJustPressed("ui_up"))
		{
			Position += new Vector2(0, -16);
			TurnManagerNode.NextTurn("up");
		}

		setFacingAnim();
	}

	private void setFacingAnim()
	{
		currentAnim.Animation = facing;
	}
}

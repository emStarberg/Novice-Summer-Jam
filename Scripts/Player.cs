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
	private AnimatedSprite2D idleAnim, moveAnim;
	private Vector2? moveTarget = null;
	private float moveSpeed = 64f; // pixels per second
	public override void _Ready()
	{
		idleAnim = GetNode<AnimatedSprite2D>("Idle");
		moveAnim = GetNode<AnimatedSprite2D>("Move");
		currentAnim = idleAnim;
		// Connect moveAnim's animation_finished signal to OnMoveAnimFinished
		moveAnim.AnimationFinished += OnMoveAnimFinished;
	}
	public override void _PhysicsProcess(double delta)
	{
		// If currently moving, continue moving towards target
		if (moveTarget != null)
		{
			Vector2 target = moveTarget.Value;
			Vector2 direction = (target - Position).Normalized();
			float distance = moveSpeed * (float)delta;
			float remaining = Position.DistanceTo(target);
			if (remaining <= distance)
			{
				Position = target;
				moveTarget = null;
			}
			else
			{
				Position += direction * distance;
			}
			setFacingAnim();
			return;
		}

		// Only allow new movement if not currently moving
		if (Input.IsActionJustPressed("ui_right"))
		{
			moveTarget = Position + new Vector2(16, 0);
			TurnManagerNode.NextTurn("right");
			facing = "right";
			SwitchAnim(moveAnim);
		}
		else if (Input.IsActionJustPressed("ui_left"))
		{
			moveTarget = Position + new Vector2(-16, 0);
			TurnManagerNode.NextTurn("left");
			facing = "left";
			SwitchAnim(moveAnim);
		}
		else if (Input.IsActionJustPressed("ui_down"))
		{
			moveTarget = Position + new Vector2(0, 16);
			TurnManagerNode.NextTurn("down");
			facing = "down";
			SwitchAnim(moveAnim);
		}
		else if (Input.IsActionJustPressed("ui_up"))
		{
			moveTarget = Position + new Vector2(0, -16);
			TurnManagerNode.NextTurn("up");
			facing = "up";
			SwitchAnim(moveAnim);
		}

		setFacingAnim();
	}

	private void setFacingAnim()
	{
		currentAnim.Animation = facing;
	}

	public void OnMoveAnimFinished()
	{
		SwitchAnim(idleAnim);
	}

	public void SwitchAnim(AnimatedSprite2D to)
	{
		currentAnim.Visible = false;
		currentAnim.Stop();
		currentAnim = to;
		setFacingAnim();
		to.Play();
		to.Visible = true;

		
	}
}

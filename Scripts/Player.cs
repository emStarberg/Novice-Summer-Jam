using Godot;
using System;
// -----------------------------------------------------------------------------
// Player.cs
// Author: Emily Braithwaite
// Purpose: Manages player movement and other actions/controls.
// -----------------------------------------------------------------------------
public partial class Player : CharacterBody2D
{

	[Export] public TurnManager TurnManagerNode; // Calls NextTurn() on this whenever the player chooses an action
	[Export] public TextureProgressBar Healthbar;
	private string facing = "left"; // Direction player is facing
	private AnimatedSprite2D currentAnim, idleAnim, moveAnim, attackAnim, hurtAnim; // Animations
	private Vector2? moveTarget = null; // For movement between tiles
	private float moveSpeed = 64f; // Pixels per second
	private float health = 100; // Player's health level
	private Label healthLabel;


	public override void _Ready()
	{
		// Set up animations
		idleAnim = GetNode<AnimatedSprite2D>("Idle");
		moveAnim = GetNode<AnimatedSprite2D>("Move");
		attackAnim = GetNode<AnimatedSprite2D>("Attack");
		hurtAnim = GetNode<AnimatedSprite2D>("Hurt");
		currentAnim = idleAnim;
		// Connect moveAnim finished signal
		moveAnim.AnimationFinished += OnMoveAnimFinished;

		healthLabel = Healthbar.GetNode<Label>("Health Label");
	}

	public override void _PhysicsProcess(double delta)
	{
		HandleMovement(delta);
		SetFacingAnim();
		// Update health bar
		Healthbar.Value = health;
		healthLabel.Text = health + "%";

		if (Input.IsActionJustPressed("ui_accept"))
		{
			Attack();
		}
		else if (Input.IsActionJustPressed("ui_text_indent"))
		{
			Hurt(20);
		}
	}

	/// <summary>
	/// Set animation based on direction player is facing
	/// </summary>
	private void SetFacingAnim()
	{
		currentAnim.Animation = facing;
	}

	/// <summary>
	/// Switch back to idle once move animation has finished
	/// </summary>
	public void OnMoveAnimFinished()
	{
		SwitchAnim(idleAnim);
	}

	/// <summary>
	/// Switch the current animation that is playing
	/// </summary>
	/// <param name="to">Animation to switch to</param>
	private void SwitchAnim(AnimatedSprite2D to)
	{
		currentAnim.Visible = false;
		currentAnim.Stop();
		currentAnim = to;
		SetFacingAnim();
		to.Play();
		to.Visible = true;
	}

	/// <summary>
	/// Handle player movement
	/// </summary>
	/// <param name="delta">Time elapsed</param>
	private void HandleMovement(double delta)
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
	}

	/// <summary>
	/// Lowers player health. To be called by enemies
	/// </summary>
	/// <param name="amount">Amount to lower health by</param>
	public void Hurt(float amount)
	{
		health -= amount;
		SwitchAnim(hurtAnim);
	}

	/// <summary>
	/// Player attacks in direction facing. Damages enemies
	/// </summary>
	private void Attack()
	{
		SwitchAnim(attackAnim);
	}

	/// <summary>
	/// When attack animation finishes, return to idle animation
	/// </summary>
	public void OnAttackAnimFinished()
	{
		SwitchAnim(idleAnim);
	}

	/// <summary>
	/// When hurt animation finishes, return to idle animation
	/// </summary>
	public void OnHurtAnimFinished()
	{
		SwitchAnim(idleAnim);
	}
}

using Godot;

// -----------------------------------------------------------------------------
// Player.cs
// Author: Emily Braithwaite
// Purpose: Manages player movement and other actions/controls.
// -----------------------------------------------------------------------------
public partial class Player : CharacterBody2D
{

	private TurnManager TurnManagerNode; // Calls NextTurn() on this whenever the player chooses an action
	private HealthBar Healthbar;
	private string facing = "left"; // Direction player is facing
	private AnimatedSprite2D currentAnim, idleAnim, moveAnim, attackAnim, hurtAnim, deathAnim; // Animations
	private Vector2? moveTarget = null; // For movement between tiles
	private float moveSpeed = 64f; // Pixels per second
	private float health = 100f; // Player's health level
	private Label healthLabel;
	private Node2D animFolder, raycastFolder;
	private RayCast2D castLeft, castRight, castUp, castDown;
	private AudioStreamPlayer2D moveAudio;
	private AudioStreamPlayer2D swordAudio;
	private AudioStreamPlayer2D hitAudio;
	private bool HoldingSword = false;
	private bool WearingSweater = false;
	private bool alive = true;
	public override void _Ready()
	{
		// Set up animations
		TurnManagerNode = (TurnManager)GetParent().GetNode<Node>("Turn Manager");
		Healthbar = (HealthBar)GetParent().GetNode<AnimatedSprite2D>("CanvasLayer/Gameplay UI/Health Bar");
		animFolder = GetNode<Node2D>("Animations");
		idleAnim = animFolder.GetNode<AnimatedSprite2D>("Idle");
		moveAnim = animFolder.GetNode<AnimatedSprite2D>("Move");
		attackAnim = animFolder.GetNode<AnimatedSprite2D>("Attack");
		hurtAnim = animFolder.GetNode<AnimatedSprite2D>("Hurt");
		deathAnim = animFolder.GetNode<AnimatedSprite2D>("Die");
		currentAnim = idleAnim;
		// Connect moveAnim finished signal
		moveAnim.AnimationFinished += OnMoveAnimFinished;

		// Set up raycasts
		raycastFolder = GetNode<Node2D>("Raycasts");
		castLeft = raycastFolder.GetNode<RayCast2D>("CastLeft");
		castRight = raycastFolder.GetNode<RayCast2D>("CastRight");
		castUp = raycastFolder.GetNode<RayCast2D>("CastUp");
		castDown = raycastFolder.GetNode<RayCast2D>("CastDown");

		healthLabel = Healthbar.GetNode<Label>("Health Label");
		moveAudio = GetNode<AudioStreamPlayer2D>("Audio/Move");
		swordAudio = GetNode<AudioStreamPlayer2D>("Audio/Sword");
		hitAudio = GetNode<AudioStreamPlayer2D>("Audio/Hit");
	}

	public override void _PhysicsProcess(double delta)
	{

		if (health <= 0 && alive)
		{
			Die();
		}
		HandleMovement(delta);
		SetFacingAnim();
		// Update health bar
		Healthbar.SetHealth(health);
		healthLabel.Text = health + "%";

		if (Input.IsActionJustPressed("ui_accept") && HoldingSword)
		{
			if (castRight.IsColliding() && castRight.GetCollider() is Godot.CharacterBody2D rightBody && rightBody.HasMethod("TakeHit"))
			{
				rightBody.Call("TakeHit");
			}
			if (castLeft.IsColliding() && castLeft.GetCollider() is Godot.CharacterBody2D leftBody && leftBody.HasMethod("TakeHit"))
			{
				leftBody.Call("TakeHit");
			}
			if (castUp.IsColliding() && castUp.GetCollider() is Godot.CharacterBody2D upBody && upBody.HasMethod("TakeHit"))
			{
				upBody.Call("TakeHit");
			}
			if (castDown.IsColliding() && castDown.GetCollider() is Godot.CharacterBody2D downBody && downBody.HasMethod("TakeHit"))
			{
				downBody.Call("TakeHit");
			}
			Attack();
			TurnManagerNode.NextTurn("attack");
		}

		// FOR TESTING PURPOSES
		else if (Input.IsActionJustPressed("ui_text_indent"))
		{
			Hurt(20);
		}

		if (Input.IsActionJustPressed("input_interact"))
		{
			if (castRight.IsColliding() && castRight.GetCollider() is Chest chestRight)
			{
				chestRight.Open();
			}
			if (castLeft.IsColliding() && castLeft.GetCollider() is Chest chestLeft)
			{
				chestLeft.Open();
			}
			if (castUp.IsColliding() && castUp.GetCollider() is Chest chestUp)
			{
				chestUp.Open();
			}
			if (castDown.IsColliding() && castDown.GetCollider() is Chest chestDown)
			{
				chestDown.Open();
			}
			
		}
	}

	/// <summary>
	/// Set animation based on direction player is facing
	/// </summary>
	private void SetFacingAnim()
	{
		if (WearingSweater)
		{
			currentAnim.Animation = "sweater_" + facing;
		}
		else if (HoldingSword)
		{
			currentAnim.Animation = "sword_" + facing;
		}
		else
		{
			currentAnim.Animation = facing;
		}

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
			facing = "right";
			if (!castRight.IsColliding())
			{
				moveTarget = Position + new Vector2(16, 0);
				TurnManagerNode.NextTurn("right");
				SwitchAnim(moveAnim);
				moveAudio.Play();
			}
		}
		else if (Input.IsActionJustPressed("ui_left"))
		{
			facing = "left";
			if (!castLeft.IsColliding())
			{
				moveTarget = Position + new Vector2(-16, 0);
				TurnManagerNode.NextTurn("left");
				SwitchAnim(moveAnim);
				moveAudio.Play();
			}
		}
		else if (Input.IsActionJustPressed("ui_down"))
		{
			facing = "down";
			if (!castDown.IsColliding())
			{
				moveTarget = Position + new Vector2(0, 16);
				TurnManagerNode.NextTurn("down");
				SwitchAnim(moveAnim);
				moveAudio.Play();
			}
		}
		else if (Input.IsActionJustPressed("ui_up"))
		{
			facing = "up";
			if (!castUp.IsColliding())
			{
				moveTarget = Position + new Vector2(0, -16);
				TurnManagerNode.NextTurn("up");
				SwitchAnim(moveAnim);
				moveAudio.Play();
			}
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
		hitAudio.Play();
	}

	/// <summary>
	/// Player attacks in direction facing. Damages enemies
	/// </summary>
	private void Attack()
	{
		SwitchAnim(attackAnim);
		swordAudio.Play();
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

	/// <summary>
	/// Give sword to the player
	/// </summary>
	public void GiveSword()
	{
		HoldingSword = true;
	}
	/// <summary>
	/// Give sweater to the player
	/// </summary>
	public void GiveSweater()
	{
		WearingSweater = true;
	}
	/// <summary>
	/// Heal damage from the player
	/// </summary>
	/// <param name="amount">How much to heal</param>
	public void Heal(float amount)
	{
		health += amount;
	}

	/// <summary>
	/// Player dies, game over
	/// </summary>
	public void Die()
	{
		SwitchAnim(deathAnim);
		alive = false;
		
	}

	/// <summary>
	/// Game over when death animation finishes
	/// </summary>
	public void OnDeathAnimFinished()
	{
		GetTree().Quit();
		// End of game logic here
	}
}

using Godot;
using System;
// -----------------------------------------------------------------------------
// HealthBar.cs
// Author: Emily Braithwaite
// Purpose: Displays the player's current health level
// -----------------------------------------------------------------------------
public partial class HealthBar : AnimatedSprite2D
{
	private float health;

	public override void _Process(double delta)
	{
        // Change frames depending on health level. (100/8 frames = 12.5)
		int frame = 0;
		if (health > 0)
		{
			frame = 7 - (int)Math.Floor(health / 12.5f);
			frame = Mathf.Clamp(frame, 0, 7);
		}
		Frame = frame;
	}


	public void SetHealth(float newHealth)
	{
		health = newHealth;
	}

	public float GetHealth()
	{
		return health;
	}
}

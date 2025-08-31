using Godot;
using System;
using System.Collections.Generic;

public partial class TurnManagerEnemyVersion : Node2D
{
	[Export] public CharacterBody2D Player;
	[Export] public Node2D EnemyContainer; // Parent node containing all enemies

	private int turnCount = 0;
	private List<Node> enemies = new List<Node>();

	public override void _Ready()
	{
		// Collect all enemies from the EnemyContainer
		foreach (Node child in EnemyContainer.GetChildren())
		{
			// Only add CharacterBody2D enemies
			if (child is CharacterBody2D)
				enemies.Add(child);
		}
	}

	/// <summary>
	/// Returns the current turn number
	/// </summary>
	public int GetTurnCount()
	{
		return turnCount;
	}

	/// <summary>
	/// Advances the turn and updates all enemies
	/// Call this from the player script when the player acts
	/// </summary>
	public void NextTurn(string playerAction)
	{
		turnCount++;
		GD.Print("Turn: " + turnCount + " | Player Action: " + playerAction);

		foreach (var enemy in enemies)
		{
			// Calls the enemy's GDScript TakeTurn()
			enemy.Call("TakeTurn");
		}
	}
}

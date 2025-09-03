using Godot;
using System;
// -----------------------------------------------------------------------------
// TurnManager.cs
// Author: Emily Braithwaite
// Purpose: Manages turn logic for the game.
// -----------------------------------------------------------------------------
public partial class TurnManager : Node
{
	[Export] public CharacterBody2D Player;
	[Signal]
	public delegate void EnemyTurnEventHandler();
	private int turnCount = 0;

	/// <summary>
	/// Get number of the turn the game is currently on
	/// </summary>
	/// <returns>turnCount</returns>
	public int GetTurnCount()
	{
		return this.turnCount;
	}

	/// <summary>
	/// Proceed to the next turn. To be called from player script
	/// </summary>
	/// <param name="playerAction">Action from player that has called this</param>
	public void NextTurn(String playerAction)
	{
		// Signal enemies
		EmitSignal("EnemyTurn");
		// Increase turn count
		turnCount++;
		GD.Print("Moved to turn: " + turnCount + " Input: " + playerAction);


	}

	public void OnEndEntered(Node2D body)
	{
		GD.Print("End Entered");
		if (body.IsInGroup("player"))
		{
			GetTree().ChangeSceneToFile("res://Scenes/end_screen.tscn");
		}
	}


}

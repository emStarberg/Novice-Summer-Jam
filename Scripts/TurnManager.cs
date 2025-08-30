using Godot;
using System;
// -----------------------------------------------------------------------------
// TurnManager.cs
// Author: Emily Braithwaite
// Purpose: Manages turn logic for the game.
// -----------------------------------------------------------------------------
public partial class TurnManager : Node2D
{
	[Export] public CharacterBody2D Player;
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
		GD.Print("Moved to next turn. Input: " + playerAction);
		// Increase turn count
		turnCount++;
	}
}

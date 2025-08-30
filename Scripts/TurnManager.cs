using Godot;
using System;

public partial class TurnManager : Node2D
{
	[Export] public CharacterBody2D Player;
	private int turnCount = 0;


	public int GetTurnCount()
	{
		return this.turnCount;
	}

	/// <summary>
	/// Proceed to the next turn. To be called from player script
	/// </summary>
	public void NextTurn()
	{
		GD.Print("Moved to next turn");
	}
}

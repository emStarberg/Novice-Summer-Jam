using Godot;
using System;

public partial class Sword : Node2D, Item
{
	public string ItemName { get; } = "Sword";
	public string Description { get; set; } = "A sword for vanquishing your enemies. \n Press ENTER to attack.";
	public string ImagePath { get; } = "res://Assets/Sword.png";
	public bool IsCarryable { get; } = true;

	public void OnAcquired()
	{
		GD.Print("Sword Acquired");
	}

}

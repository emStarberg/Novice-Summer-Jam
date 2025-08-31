using Godot;
using System;

public partial class Sweater : Node2D, Item
{
	public string ItemName { get; } = "Sweater";
	public string Description { get; set; } = "A warm, cosy sweater.";
	public string ImagePath { get; } = "res://Assets/Jumper.png";
	public bool IsCarryable { get; } = true;

	public void OnAcquired()
	{
		GD.Print("Sweater Acquired");
	}

}

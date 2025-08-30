using Godot;
using System;

public partial class Camera : Camera2D
{
	[Export]
	public Node2D Player;

	public override void _Ready()
	{
		Zoom = new Vector2(3,3);
	}

	public override void _Process(double delta)
	{
		if (Player != null)
		{
			Position = Player.Position;
		}
	}
}

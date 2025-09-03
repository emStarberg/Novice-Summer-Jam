using Godot;
using System;

public partial class RetryButton : Control
{
	public void OnMouseEntered()
	{
		SetButtonImage("res://Assets/StartButtonHover.png");
	}

	public void OnMouseExited()
	{
		SetButtonImage("res://Assets/Startbutton.png");
	}

	public void SetButtonImage(string imagePath)
	{
		Texture2D texture = (Texture2D)GD.Load(imagePath);
		GetNode<Sprite2D>("Sprite").Texture = texture;
	}
	
	public override void _GuiInput(InputEvent @event)
{
	if (@event is InputEventMouseButton mouseEvent && mouseEvent.Pressed && mouseEvent.ButtonIndex == MouseButton.Left)
	{
		// Load cutscene
		GetTree().ChangeSceneToFile("res://Scenes/title_screen.tscn");
	}
}
}

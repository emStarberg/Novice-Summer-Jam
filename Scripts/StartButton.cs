using Godot;
using System;

public partial class StartButton : Control
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
	
		// Load game here
	}
}
}

// Example usage:
// SetButtonImage("res://path/to/your/new_image.png");

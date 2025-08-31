using Godot;
using System;

public partial class CutscenePlayer : AnimationPlayer
{
	public override void _Ready()
	{
		Play("Opening");
	}

	public void OnAnimationFinished()
	{
		// Alex please change this file path
		GetTree().ChangeSceneToFile("res://Scenes/player_with_tilemap.tscn");
	}
}

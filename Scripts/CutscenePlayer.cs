using Godot;
using System;

public partial class CutscenePlayer : AnimationPlayer
{
	public override void _Ready()
	{
		Play("Opening");
	}

	public void OnAnimationFinished(string animName)
{
	GetTree().ChangeSceneToFile("res://Scenes/main_level.tscn");
}
}

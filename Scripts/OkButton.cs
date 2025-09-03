using Godot;
using System;

public partial class OkButton : Button
{
public void	OnOkPressed(){
		GetParent().GetParent().QueueFree();
	}
}

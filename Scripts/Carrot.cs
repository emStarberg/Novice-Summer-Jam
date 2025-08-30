using Godot;
using System;

public partial class Carrot : Node2D, Item
{
    public string ItemName { get; } = "Carrot";
    public string Description { get; set; } = "A tasty carrot.";
    public string ImagePath { get; } = "res://Assets/Carrot.png";
    public bool IsCarryable { get; } = true;

    public void OnAcquired()
    {
        GD.Print("Carrot!!!");
    }

}
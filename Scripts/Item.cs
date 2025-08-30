using Godot;
using System;
// -----------------------------------------------------------------------------
// Item.cs
// Author: Emily Braithwaite
// Purpose: An item that can be carried in the player's inventory. 
// -----------------------------------------------------------------------------
public interface Item
{
    string ItemName { get; }
    string Description { get; set; }

    public void OnAcquired() { }
   
}
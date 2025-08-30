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
    string ImagePath { get; }
    bool IsCarryable { get;}

    // To be called when acquired by player
    public void OnAcquired() { }

    
   
}
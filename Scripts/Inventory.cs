using Godot;
using System;
using System.Collections.Generic;
// -----------------------------------------------------------------------------
// Inventory.cs
// Author: Emily Braithwaite
// Purpose: Contains items that the player has collected
// -----------------------------------------------------------------------------
public partial class Inventory : Node2D
{
	private List<Item> items = [];

	public void AddItem(Item item)
	{
		items.Add(item);
	}

	public void RemoveItem(Item item)
	{
		items.Remove(item);
	}

	public List<Item> GetItems()
	{
		return this.items;
	}
}

using Godot;
using System;
using System.Collections.Generic;

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

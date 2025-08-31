using Godot;
using System;
using System.Collections;
using System.Collections.Generic;
// -----------------------------------------------------------------------------
// Inventory.cs
// Author: Emily Braithwaite
// Purpose: Contains items that the player has collected
// -----------------------------------------------------------------------------
public partial class Inventory : Node2D
{
	private List<TextureRect> tiles = []; // Tiles in UI Inventory
	private List<Item> items = []; // Items in inventory
	private Player player;


	public override void _Ready()
	{
		player = (Player)GetParent();

		Control controlNode = GetParent().GetParent().GetNode<Control>("CanvasLayer/Inventory");
		foreach (TextureRect n in controlNode.GetChildren())
		{
			tiles.Add(n);
		}
	}

	public void AddItem(Item item)
	{
		items.Add(item);
		int index = items.Count - 1;

		// Create a new node based on item added
		Node2D itemNode = new Node2D();
		Sprite2D sprite = tiles[index].GetNode<Sprite2D>("Sprite2D");
		sprite.Texture = GD.Load<Texture2D>(item.ImagePath);
		// Create label for tooltip
		Label tooltip = new Label();
		tooltip.Text = item.Description;
		tooltip.Visible = false;

		if (item.ItemName == "Sword")
		{
			player.GiveSword();
		}

		if (item.ItemName == "Carrot")
		{
			player.Heal(20f);
		}
	}

	public void RemoveItem(Item item)
	{
		items.Remove(item);
	}

	public List<Item> GetItems()
	{
		return this.items;
	}

	public Player GetPlayer()
	{
		return player;
	}
}

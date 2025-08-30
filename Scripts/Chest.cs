using Godot;
using System;

public partial class Chest() : StaticBody2D
{
	[Export] public Inventory PlayerInventory;
	private Item item = new Item("TestItem", "This is a test");
	private RayCast2D rayCast;

	public override void _Ready()
	{
		rayCast = GetNode<RayCast2D>("RayCast");
	}

	public override void _Process(double delta)
	{
		if (rayCast.IsColliding())
		{
			if (rayCast.GetCollider() is Node node)
			{
				if (node.Name == "Player")
				{
					if (Input.IsActionJustPressed("input_interact"))
					{
						Open();
					}
				}
			}
		}
	}


	public void Open()
	{
		if (item != null)
		{
			PlayerInventory.AddItem(item);
			GD.Print("Chest Opened!");
			
		}
	}

	public void SetItem(Item setItem)
	{
		this.item = setItem;
	}
	public Item GetItem()
	{
		return this.item;
	}

}

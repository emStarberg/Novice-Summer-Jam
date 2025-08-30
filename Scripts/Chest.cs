using Godot;
using System;
// -----------------------------------------------------------------------------
// Chest.cs
// Author: Emily Braithwaite
// Purpose: Contains an item which it gives to the player when opened
// -----------------------------------------------------------------------------
public partial class Chest() : StaticBody2D
{
	[Export] public Inventory PlayerInventory;
	private Item item = new Carrot();
	private RayCast2D rayCast;
	private AnimatedSprite2D openAnim;

	public override void _Ready()
	{
		rayCast = GetNode<RayCast2D>("RayCast");
		openAnim = GetNode<AnimatedSprite2D>("Open");
		openAnim.Animation = "open";
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

	/// <summary>
	/// Open the chest and give item inside to the player
	/// </summary>
	private void Open()
	{
		openAnim.Visible = true;
		openAnim.Play();
		if (item != null)
		{
			PlayerInventory.AddItem(item);
			item.OnAcquired();
			GD.Print("Chest Opened!");
		}
	}

	/// <summary>
	/// When open/close animation has finished, either stay open or stay closed
	/// </summary>
	public void OnOpenAnimFinished()
	{
		if (openAnim.Animation == "open") // Open animation finishes
		{
			// Play stay open animation
			openAnim.Animation = "stay-open";
			openAnim.Play(); // Plays on loop until close triggered
		}
		else // Close animation finishes
		{
			openAnim.Animation = "open";
			openAnim.Stop();
			openAnim.Visible = false;
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

using Godot;
using System;
// -----------------------------------------------------------------------------
// Chest.cs
// Author: Emily Braithwaite
// Purpose: Contains an item which it gives to the player when opened
// -----------------------------------------------------------------------------
public partial class Chest() : StaticBody2D
{
	private Inventory playerInventory;
	private CanvasLayer uiLayer;
	private TurnManager turnManager;
	
	[Export]
	private int itemNum = 0;
	
	private Item[] items = [new Sword(), new Carrot(), new Sweater()];
	
	private Item item;

	private AnimatedSprite2D openAnim;
	private Node currentOverlay;
	private AudioStreamPlayer2D audio;

	public override void _Ready()
	{
		audio = GetNode<AudioStreamPlayer2D>("Audio");
		openAnim = GetNode<AnimatedSprite2D>("Open");
		openAnim.Animation = "open";

		playerInventory = GetParent().GetParent().GetParent().GetNode<Inventory>("Player/Inventory");
		uiLayer = GetParent().GetParent().GetParent().GetNode<CanvasLayer>("CanvasLayer");
		turnManager = GetParent().GetParent().GetParent().GetNode<TurnManager>("Turn Manager");
		
		item = items[itemNum];
	}


	/// <summary>
	/// Open the chest and give item inside to the player
	/// </summary>
	public void Open()
	{
		
		if (item != null)
		{
			audio.Play();
			turnManager.NextTurn("open_chest");
			openAnim.Visible = true;
			openAnim.Play();
		}
		OnCollectPressed();
	}

	/// <summary>
	/// Close the chest
	/// </summary>
	public void Close()
	{
		openAnim.Stop();
		openAnim.Animation = "close";
		openAnim.Visible = true;
		openAnim.Play();
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

			// Instance chest_item_overlay.tscn and add to scene
			var overlayScene = GD.Load<PackedScene>("res://Scenes/chest_item_overlay.tscn");
			if (overlayScene != null)
			{
				var overlayInstance = overlayScene.Instantiate();
				var collectButton = overlayInstance.GetNode<ColorRect>("ColorRect").GetNode<Button>("Collect");
				// Store reference to overlayInstance for later removal
				this.currentOverlay = overlayInstance;
				collectButton.Pressed += OnCollectPressed;
				uiLayer.AddChild(overlayInstance);

				currentOverlay.GetNode<Label>("ColorRect/Item Name").Text = item.ItemName;
				currentOverlay.GetNode<Label>("ColorRect/Description").Text = item.Description;
				currentOverlay.GetNode<Sprite2D>("ColorRect/Image").Texture = GD.Load<Texture2D>(item.ImagePath);
			}
		}
		else // Close animation finishes
		{
			openAnim.Animation = "open";
			openAnim.Stop();
			openAnim.Visible = false;
		}
	}
	

	/// <summary>
	/// When collect button pressed, add item to inventory and other effects
	/// </summary>
	public void OnCollectPressed()
	{

		// Remove overlay
		currentOverlay.QueueFree();
		currentOverlay = null;
		// Play close animation
		Close();
		// Give player item
		item.OnAcquired();
		if (item.IsCarryable)
		{
			playerInventory.AddItem(item);
		}
		else
		{
			if (item.ItemName == "Carrot")
			{
				playerInventory.GetPlayer().Heal(20f);
			}
		}


		GD.Print("Inventory:");
		foreach (Item i in playerInventory.GetItems())
		{
			GD.Print(i.ItemName);
		}
		// Remove item from chest
		item = null;
	}

}

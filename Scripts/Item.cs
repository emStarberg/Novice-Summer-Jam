using Godot;
using System;
public partial class Item
{
    private String name;
    private String description;
    public Item(String name, String description)
    {
        this.name = name;
        this.description = description;
    }

    public String GetName()
    {
        return this.name;
    }

    public String GetDescription()
    {
        return this.description;
    }

    public void SetDescription(String set)
    {
        this.description = set;
    }

}
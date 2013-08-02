package flixel.group;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

/**
 * Experimental abstract group
 * @author Pekka Heikkinen
 */
abstract FlxObjectGroup(FlxTypedGroup<FlxObject>)
{

	public inline function new(MaxSize:Int = 0):FlxTypedGroup<FlxObject>
	{
		this = new FlxTypedGroup<FlxObject>(MaxSize);
		this.add(new FlxObject());
	}
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var alpha(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	
	public inline function processCollision(Against:FlxBasic):Void
	{
		var diffX:Float = hitbox.x;
		var diffY:Float = hitbox.y;
		FlxG.collide(hitbox, Against);
		diffX -= hitbox.x;
		diffY -= hitbox.y;
		if (diffX != 0 || diffY != 0)
		{
			for (i in new IntIterator(1, this.members.length))
			{
				this.members[i].x += diffX;
				this.members[i].y += diffY;
			}
		}
	}
	
	private inline function get_width():Float
	{
		return hitbox.width;
	}
	private inline function set_width(Value:Float):Float
	{
		return hitbox.width = Value;
	}
	
	private inline function get_height():Float
	{
		return hitbox.height;
	}
	private inline function set_height(Value:Float):Float
	{
		return hitbox.height = Value;
	}
	
	private inline function get_x():Float
	{
		return hitbox.x;
	}
	private inline function set_x(Value:Float):Float
	{
		var offset:Float = Value - x;
		for (member in this.members)
		{
			member.x += offset;
		}
		return Value;
	}
	
	private inline function get_y():Float
	{
		return hitbox.y;
	}
	private inline function set_y(Value:Float):Float
	{
		var offset:Float = Value - y;
		for (member in this.members)
		{
			member.y += offset;
		}
		return Value;
	}
	
	private inline function get_alpha():Float
	{
		var sprite:FlxSprite = firstSprite;
		if (sprite != null)
		{
			return sprite.alpha;
		}
		else
		{
			return 1;
		}
	}
	
	private inline function set_alpha(Value:Float):Float
	{
		for (member in this.members)
		{
			if (Std.is(member, FlxSprite))
			{
				cast(member, FlxSprite).alpha = Value;
			}
		}
		return Value;
	}
	
	private var firstSprite(get, never):FlxSprite;
	private inline function get_firstSprite():FlxSprite
	{
		var sprite:FlxSprite = null;
		for (member in this.members)
		{
			if (Std.is(member, FlxSprite))
			{
				sprite = cast(member, FlxSprite);
				break;
			}
		}
		return sprite;
	}
	
	public inline function add(Object:FlxObject, PivotX:Float = 0, PivotY:Float = 0):FlxObject
	{
		toLocal(Object, PivotX, PivotY);
		return this.add(Object);
	}
	
	public inline function toLocal(Object:FlxObject, PivotX:Float = 0, PivotY:Float = 0):Void
	{
		Object.x += hitbox.x + (hitbox.width * PivotX);
		Object.y += hitbox.y + (hitbox.height * PivotY);
	}
	
	public var length(get, never):Int;
	private inline function get_length():Int
	{
		return (this.members.length - 1);
	}
	
	public var hitbox(get, never):FlxObject;
	private inline function get_hitbox():FlxObject
	{
		return this.members[0];
	}
	
	public var group(get, never):FlxTypedGroup<FlxObject>;
	@:to private inline function get_group():FlxTypedGroup<FlxObject>
	{
		return this;
	}
	
}
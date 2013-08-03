package flixel.group;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

/**
 * Experimental abstract group.
 * This is not a real object, only a typed interface for FlxTypedGroup<FlxObject>.
 * It has no negative effect on speed since all methods will be inlined.
 * @author Pekka Heikkinen
 */
abstract AbstractObjectGroup(FlxTypedGroup<FlxObject>)
{

	inline function new(Group)
	{
		this = Group;
	}
	
	/**
	 * Creates a new FlxTypedGroup<FlxObject> with one FlxObject to serve as a hitbox
	 * @param	MaxSize
	 * @return	An FlxObjectGroup for the created group
	 */
	public static inline function createNew(MaxSize:Int = 0):AbstractObjectGroup
	{
		var gr = new FlxTypedGroup<FlxObject>(MaxSize);
		gr.add(new FlxObject());
		return new AbstractObjectGroup(gr);
	}
	
	/**
	 * Turns an FlxTypedGroup<FlxObject> into an FlxObjectGroup construct.
	 * @param	Group
	 * @return
	 */
	@:from public static inline function createFrom(Group:FlxTypedGroup<FlxObject>):AbstractObjectGroup
	{
		return new AbstractObjectGroup(Group);
	}
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var alpha(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	
	/**
	 * Contains the first FlxObject of the group, eg. the designated hitbox
	 */
	public var hitbox(get, never):FlxObject;
	
	/**
	 * Returns the original FlxTypedGroup<FlxObject>
	 */
	public var source(get, never):FlxTypedGroup<FlxObject>;
	
	/**
	 * If the hitbox has moved by either velocity or collision, call this to adjust
	 * the positions of the rest of the group members.
	 */
	public inline function updatePositions():Void
	{
		var diffX:Float = hitbox.x - hitbox.last.x;
		var diffY:Float = hitbox.y - hitbox.last.y;
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
	
	public inline function add(Object:FlxObject):FlxObject
	{
		Object.x += hitbox.x;
		Object.y += hitbox.y;
		return this.add(Object);
	}
	
	public inline function toLocal(Object:FlxObject, PivotX:Float = 0, PivotY:Float = 0):Void
	{
		Object.x += hitbox.x + (hitbox.width * PivotX);
		Object.y += hitbox.y + (hitbox.height * PivotY);
	}
	
	
	private inline function get_hitbox():FlxObject
	{
		return this.members[0];
	}
	
	@:to private inline function get_source():FlxTypedGroup<FlxObject>
	{
		return this;
	}
	
}
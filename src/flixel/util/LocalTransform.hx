package flixel.util;
import flixel.FlxObject;

/**
 * EXPERIMENTAL
 * Provides abstract class for transforming objects within other object's local space.
 * @author Pekka Heikkinen
 */
abstract LocalTransform(TransformBase)
{

	/**
	 * Returns a transform object
	 * @param	Parent	The parent object that drives the child object
	 * @param	Child	The child object that will be transformed in the parent's local space
	 * @param	PivotX	The x pivot for the parent. 0.5 would mean the center of parent object.
	 * @param	PivotY	The y pivot for the parent. 0.5 would mean the center of parent object.
	 */
	public inline function new(Parent:FlxObject, Child:FlxObject, PivotX:Float = 0, PivotY:Float = 0) 
	{
		this = new TransformBase();
		this._parent = Parent;
		this._child = Child;
		this._pX = PivotX;
		this._pY = PivotY;
	}
	
	/**
	 * The child object's X coordinate relative to parent
	 */
	public var x(get, set):Float;
	private inline function get_x():Float
	{
		return this._child.x - pivotX;
	}
	private inline function set_x(Value:Float):Float
	{
		this._child.x = pivotX + Value;
		return Value;
	}
	
	/**
	 * The child object's Y coordinate relative to parent
	 */
	public var y(get, set):Float;
	private inline function get_y():Float
	{
		return this._child.y - pivotY;
	}
	private inline function set_y(Value:Float):Float
	{
		this._child.y = pivotY + Value;
		return Value;
	}
	
	/**
	 * The X pivot (parent's coordinate)
	 */
	public var pivotX(get, set):Float;
	private inline function get_pivotX():Float
	{
		return this._parent.x + (this._parent.width*this._pX);
	}
	private inline function set_pivotX(Value:Float):Float
	{
		var diff:Float = this._child.x - this._parent.x;
		this._parent.x = Value - (this._parent.width * this._pX);
		this._child.x = this._parent.x + diff;
		return Value;
	}
	
	/**
	 * The Y pivot (parent's coordinate)
	 */
	public var pivotY(get, set):Float;
	private inline function get_pivotY():Float
	{
		return this._parent.y + (this._parent.height * this._pY);
	}
	private inline function set_pivotY(Value:Float):Float
	{
		var diff:Float = this._child.y - this._parent.y;
		this._parent.y = Value - (this._parent.height * this._pY);
		this._child.y = this._parent.y + diff;
		return Value;
	}
	
}

class TransformBase
{
	public function new() { }
	/**
	 * Don't change!
	 */
	public var _parent:FlxObject;
	/**
	 * Don't change!
	 */
	public var _child:FlxObject;
	/**
	 * Don't change!
	 */
	public var _pX:Float = 0;
	/**
	 * Don't change!
	 */
	public var _pY:Float = 0;
}
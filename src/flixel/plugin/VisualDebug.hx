package flixel.plugin;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxBasic;
import flixel.FlxCamera;
import haxe.ds.GenericStack;
import haxe.ds.Vector;
import haxe.EnumTools;
import flixel.util.FlxColor;
import flixel.FlxG;
import flash.display.Graphics;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColorUtil;
import flixel.text.TempestaSeven;

/**
 * ...
 * @author Pekka Heikkinen
 */
class VisualDebug extends FlxBasic
{
	
	private var stack:Array<DebugShape>;
	public static var textStack:Array<String>;
	
	public function new() 
	{
		super();
		stack = new Array<DebugShape>();
		textStack = new Array<String>();
		active = false;
	}
	
	public static function instance():VisualDebug
	{
		var vd:VisualDebug = cast FlxG.plugins.get(VisualDebug);
		if (vd == null)
		{
			vd = new VisualDebug();
			FlxG.plugins.add(vd);
		}
		return vd;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		stack = null;
		textStack = null;
		super.destroy();
	}
	
	override public function drawDebug():Void
	{
		super.drawDebug();
		if (textStack.length != 0) textStack = new Array<String>();
	}
	
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		var s:DebugShape = stack.shift();
		while(s != null)
		{
			s.draw(Camera);
			s = stack.shift();
		}
	}
	
	public function drawPoint(X:Float, Y:Float, Diameter:Int = 4, Color:Int = 0xffffffff, Print:Bool = false):Void
	{
		if (!FlxG.debugger.visualDebug || ignoreDrawDebug) return;
		var s:DebugShape = new DebugShape();
		s.setShape(DebugShape.POINT);
		s.setStartX(Std.int(X));
		s.setStartY(Std.int(Y));
		s.setColor(Color);
		s.setDiameter(Diameter);
		stack.push(s);
		
		if (Print)
		{
			X = Math.ffloor(X);
			Y = Math.ffloor(Y);
			drawText(X + 3, Y - 12, 'X:$X Y:$Y');
		}
	}
	
	public function drawCross(X:Float, Y:Float, Radius:Int = 4, Color:Int = 0xffffffff, Print:Bool = false):Void
	{
		if (!FlxG.debugger.visualDebug || ignoreDrawDebug) return;
		var s:DebugShape = new DebugShape();
		s.setShape(DebugShape.CROSS);
		s.setStartX(Std.int(X));
		s.setStartY(Std.int(Y));
		s.setColor(Color);
		s.setDiameter(Radius*2);
		stack.push(s);
		
		if (Print)
		{
			X = Math.ffloor(X);
			Y = Math.ffloor(Y);
			drawText(X + 3, Y - 12, 'X:$X Y:$Y');
		}
	}
	
	public function drawText(X:Float, Y:Float, Text:String):Void
	{
		if (!FlxG.debugger.visualDebug || ignoreDrawDebug) return;
		var s:DebugShape = new DebugShape();
		s.setShape(DebugShape.TEXT);
		s.setStartX(Std.int(X));
		s.setStartY(Std.int(Y));
		s.setText(textStack.length);
		textStack.push(Text);
		stack.push(s);
	}
	
}



abstract DebugShape(Vector<Int>)
{
	public static inline var POINT:Int = 1;
	public static inline var CROSS:Int = 2;
	public static inline var TEXT:Int = 3;
	
	private static inline var SHAPE_INDEX:Int = 0;
	private static inline var COLOR_INDEX:Int = 1;
	private static inline var START_X_INDEX:Int = 2;
	private static inline var START_Y_INDEX:Int = 3;
	private static inline var END_X_INDEX:Int = 4;
	private static inline var END_Y_INDEX:Int = 5;
	private static inline var DIAMETER_INDEX:Int = 6;
	private static inline var TEXT_INDEX:Int = 7;
	
	public inline function new()
	{
		this = new Vector<Int>(8);
	}
	
	public inline function draw(Camera:FlxCamera = null):Void
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		#if flash
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		#else
		var gfx:Graphics = Camera._debugLayer.graphics;
		#end
		
		switch (getShape())
		{
			case POINT:
				var x:Float = getStartX() - Camera.scroll.x;
				var y:Float = getStartY() - Camera.scroll.y;
				//if (!onScreen(x, y)) continue;
				var d:Float = getDiameter();
				var dHalf:Float = d / 2;
				gfx.beginFill(getColor(), 0.5);
				gfx.lineStyle(1, getColor());
				gfx.drawRect(x - dHalf, y - dHalf, d, d);
				gfx.endFill();
			case CROSS:
				var x:Float = Math.ffloor( getStartX() - Camera.scroll.x )+0.01;
				var y:Float = getStartY() - Camera.scroll.y;
				//if (onScreen(x, y)) continue;
				var d:Float = getDiameter();
				var dHalf:Float = d / 2;
				gfx.beginFill(getColor());
				gfx.lineStyle();
				gfx.drawRect(x - dHalf, y, dHalf, 1);
				gfx.drawRect(x, y - dHalf, 1, dHalf);
				gfx.drawRect(x + 1, y, dHalf, 1);
				gfx.drawRect(x, y + 1, 1, dHalf);
				gfx.endFill();
			case TEXT:
				var x:Float = getStartX() - Camera.scroll.x;
				var y:Float = getStartY() - Camera.scroll.y;
				var text:String = VisualDebug.textStack[getText()];
				TempestaSeven.render(text, gfx, x, y);
			default: null;
		}
		
		#if flash
		Camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		#end
	}
	
	private inline function onScreen(x:Float, y:Float):Bool
	{
		if (x < 0 || y < 0) 
		{
			return false;
		}
		else if (x > FlxG.width || y > FlxG.height)
		{
			return false;
		}
		else
		{			
			return true;
		}
	}
	
	public inline function getShape():Int return this.get(SHAPE_INDEX);
	public inline function setShape(V:Int):Void this.set(SHAPE_INDEX, V);
	
	public inline function getColor():Int return FlxColorUtil.RGBAtoRGB(this.get(COLOR_INDEX));
	public inline function getColorRGBA():Int return this.get(COLOR_INDEX);
	public inline function setColor(V:Int):Void this.set(COLOR_INDEX, V);
	
	public inline function getStartX():Int return this.get(START_X_INDEX);
	public inline function setStartX(V:Int):Void this.set(START_X_INDEX, V);
	
	public inline function getStartY():Int return this.get(START_Y_INDEX);
	public inline function setStartY(V:Int):Void this.set(START_Y_INDEX, V);
	
	public inline function getDiameter():Int return this.get(DIAMETER_INDEX);
	public inline function setDiameter(V:Int):Void this.set(DIAMETER_INDEX, V);
	
	public inline function getText():Int return this.get(TEXT_INDEX);
	public inline function setText(V:Int):Void this.set(TEXT_INDEX, V);
	
}
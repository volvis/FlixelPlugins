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
	
	private var stack:Array<Shapes>;
	
	/**
	 * The color that is used if the color provided equals -1
	 */
	public static var defaultColor:Int = 0xffffffff;
	
	public function new() 
	{
		super();
		stack = new Array<Shapes>();
		active = false;
	}
	
	private static function instance():VisualDebug
	{
		var vd:VisualDebug = cast FlxG.plugins.get(VisualDebug);
		if (vd == null)
		{
			vd = new VisualDebug();
			FlxG.plugins.add(vd);
		}
		return vd;
	}
	
	private function add(Sh:Shapes):Void
	{
		stack.push(Sh);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		stack = null;
		super.destroy();
	}
	
	/**
	 * Drawing methods
	 */
	
	override public function drawDebugOnCamera(?Camera:FlxCamera):Void
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
		
		var s:Shapes = stack.shift();
		while(s != null)
		{
			switch (s)
			{
				case POINT(x, y, size, color):
					x -= Camera.scroll.x;
					y -= Camera.scroll.y;
					var offset:Float = size/2;
					gfx.beginFill(color, 0.5);
					gfx.lineStyle(1, color);
					gfx.drawRect(x - offset, y - offset, size, size);
					gfx.endFill();
				case CROSS(x, y, size, color):
					x = Math.ffloor( x - Camera.scroll.x )+0.01;
					y -= - Camera.scroll.y;
					gfx.beginFill(color);
					gfx.lineStyle();
					gfx.drawRect(x - size, y, size, 1);
					gfx.drawRect(x, y - size, 1, size);
					gfx.drawRect(x + 1, y, size, 1);
					gfx.drawRect(x, y + 1, 1, size);
					gfx.endFill();
				case TEXT(x, y, text):
					x -= Camera.scroll.x;
					y -= Camera.scroll.y;
					gfx.lineStyle();
					TempestaSeven.render(text, gfx, x, y);
				case RECT(x, y, w, h, color, opacity):
					x = Math.ffloor( x - Camera.scroll.x )+0.01;
					y -= - Camera.scroll.y;
					gfx.beginFill(color, opacity);
					gfx.lineStyle(1, color);
					gfx.drawRect(x, y, w, h);
					gfx.endFill();
				case LINE(x, y, x2, y2, color):
					x -= Camera.scroll.x;
					y -= Camera.scroll.y;
					x2 -= Camera.scroll.x;
					y2 -= Camera.scroll.y;
					if (x != x2 && y != y2)
					{
						gfx.lineStyle(1, color);
						gfx.moveTo(x, y);
						gfx.lineTo(x2, y2);
					}
					else
					{
						gfx.lineStyle();
						gfx.beginFill(color);
						if (x == x2)
						{
							gfx.drawRect(x, y, 1, y2 - y);
						}
						else
						{
							gfx.drawRect(x, y, x2-x, 1);
						}
						gfx.endFill();
					}
			}
			s = stack.shift();
		}
		
		#if flash
		Camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		#end
	}
	
	/**
	 * Draw a point on screen
	 * @param	X	The X coordinate in world space
	 * @param	Y	The Y coordinate in world space
	 * @param	Diameter	The size of the shape
	 * @param	Color	Color of the shape. Compatible with FlxColor values
	 * @param	Print	Whether to print the coordinates next to the point
	 */
	public static function drawPoint(X:Float, Y:Float, Diameter:Int = 4, Color:Int = -1, Print:Bool = false):Void
	{
		var inst:VisualDebug = instance();
		if (!FlxG.debugger.visualDebug || inst.ignoreDrawDebug) return;
		if (Color == -1) Color = defaultColor;
		
		inst.add(POINT(X, Y, Diameter, FlxColorUtil.RGBAtoRGB(Color)));
		
		if (Print)
		{
			X = Math.ffloor(X);
			Y = Math.ffloor(Y);
			inst.add(TEXT(X + (Diameter/2)+2, Y - 14, 'X:${Math.ffloor(X)} Y:${Math.ffloor(Y)}'));
		}
	}
	
	/**
	 * Draw a cross on screen
	 * @param	X	The X coordinate in world space
	 * @param	Y	The Y coordinate in world space
	 * @param	Radius	The size of the shape
	 * @param	Color	Color of the shape. Compatible with FlxColor values.
	 * @param	Print	Whether to print the coordinates next to the cross
	 */
	public static function drawCross(X:Float, Y:Float, Radius:Int = 4, Color:Int = -1, Print:Bool = false):Void
	{
		var inst:VisualDebug = instance();
		if (!FlxG.debugger.visualDebug || inst.ignoreDrawDebug) return;
		if (Color == -1) Color = defaultColor;
		inst.add(CROSS(X, Y, Radius, FlxColorUtil.RGBAtoRGB(Color)));
		
		if (Print)
		{
			X = Math.ffloor(X);
			Y = Math.ffloor(Y);
			inst.add(TEXT(X + 3, Y - 12, 'X:${Math.ffloor(X)} Y:${Math.ffloor(Y)}'));
		}
	}
	
	/**
	 * Prints text on screen
	 * @param	X	The X coordinate in world space
	 * @param	Y	The Y coordinate in world space
	 * @param	Text	The text to print out
	 */
	public static function drawText(X:Float, Y:Float, Text:String):Void
	{
		var inst:VisualDebug = instance();
		if (!FlxG.debugger.visualDebug || inst.ignoreDrawDebug) return;
		inst.add(TEXT(X, Y, Text));
	}
	
	/**
	 * Draw a rectangle on screen
	 * @param	X	The X coordinate in world space
	 * @param	Y	The Y coordinate in world space
	 * @param	Width	Width of the rectangle
	 * @param	Height	Height of the rectangle
	 * @param	Color	Color of the shape. Compatible with FlxColor values.
	 * @param	Opacity	The opacity of the fill
	 * @param	Print	Text to print above the rectangle
	 */
	public static function drawRect(X:Float, Y:Float, Width:Float, Height:Float, Color:Int = -1, Opacity:Float = 0.5, Print:String = null):Void
	{
		var inst:VisualDebug = instance();
		if (!FlxG.debugger.visualDebug || inst.ignoreDrawDebug) return;
		if (Color == -1) Color = defaultColor;
		inst.add(RECT(X, Y, Width, Height, FlxColorUtil.RGBAtoRGB(Color), Opacity));
		
		if (Print != null)
		{
			inst.add(TEXT(X, Y - 14, Print));
		}
	}
	
	/**
	 * Draw a line on screen
	 * @param	StartX	Starting X coordinate in world space
	 * @param	StartY	Starting Y coordinate in world space
	 * @param	EndX	Ending X coordinate in world space
	 * @param	EndY	Ending Y coordinate in world space
	 * @param	Color	Color of the line. Compatible with FlxColor values.
	 */
	public static function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:Int = -1)
	{
		var inst:VisualDebug = instance();
		if (!FlxG.debugger.visualDebug || inst.ignoreDrawDebug) return;
		if (Color == -1) Color = defaultColor;
		inst.add(LINE(StartX, StartY, EndX, EndY, FlxColorUtil.RGBAtoRGB(Color)));
		
	}
	
}

enum Shapes
{
	POINT(x:Float, y:Float, size:Float, color:Int);
	CROSS(x:Float, y:Float, size:Float, color:Int);
	TEXT(x:Float, y:Float, text:String);
	RECT(x:Float, y:Float, w:Float, h:Float, color:Int, opacity:Float);
	LINE(x:Float, y:Float, x2:Float, y2:Float, color:Int);
}
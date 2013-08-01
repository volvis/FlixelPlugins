package flixel.text;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import openfl.Assets;
import openfl.display.Tilesheet;

/**
 * ...
 * @author Pekka Heikkinen
 */
class TempestaSeven
{
	private static inline var MIN_CODE:Int = 33;
	private static inline var MAX_CODE:Int = 127;
	
	private static var font:Font;
	private static var characters:Vector<Character>;
	
	private static var tilesheet:Tilesheet;
	
	public static function render(Text:String, Graphic:Graphics, X:Float = 0, Y:Float = 0, Color:Int = FlxColor.WHITE):Void
	{
		init();
		
		// Store previous character code for kerning
		var prev:Int = -1;
		
		var drawCommands:Vector<Int> = new Vector<Int>(Text.length * 2);
		var width:Int = 0;
		var height:Int = 0;
		var x:Int = 0;
		for (charIndex in 0...Text.length)
		{
			var charCode:Int = Text.charCodeAt(charIndex);
			var kerning:Int = font.getKerning(prev, charCode);
			x += kerning;
			var character:Character = characters.get(charCode);
			var row:Int = charIndex * 2;
			drawCommands.set( row, charCode );
			drawCommands.set( row + 1, x );
			var advance:Int = character.xadvance();
			x += advance;
			prev = charCode;
		}
		
		//var graphics:Graphics = new Graphics();
		
		//var bmpData:BitmapData = new BitmapData(x, 12, true, 0x00ffffff);
		
		var drawCalls:Array<Float> = new Array<Float>();
		
		for (charIndex in 0...Text.length)
		{
			var row:Int = charIndex * 2;
			var character:Character = characters.get(drawCommands.get(row));
			
			drawCalls.push( drawCommands.get(row + 1) + character.xoffset() + X );
			drawCalls.push( character.yoffset() + Y );
			drawCalls.push( drawCommands.get(row) - MIN_CODE );
		}
		
		tilesheet.drawTiles(Graphic, drawCalls, false);
	}
	
	private static function init():Void
	{
		if (font != null) return;
		
		font = new Font(Assets.getText("flixel/img/debugger/TempestaSeven.fnt"));
		
		tilesheet = new Tilesheet(Assets.getBitmapData("flixel/img/debugger/TempestaSeven.png"));
		
		characters = new Vector<Character>(MAX_CODE);
		for (charID in MIN_CODE...MAX_CODE)
		{
			var char:Character = font.getCharacter(charID);
			tilesheet.addTileRect(char.getRectangle());
			//tilesheet.drawTiles
			characters.set(charID, char);
		}
	}
}

abstract Font(String)
{
	public inline function new (V:String)
	{
		var str:StringBuf = new StringBuf();
		var lastChar:Int = 0;
		var curChar:Int = 0;
		for (index in 0...V.length)
		{
			curChar = V.charCodeAt(index);
			if (lastChar == 32)
			{
				if (curChar != 32)
				{					
					str.addChar(curChar);
				}
			}
			else
			{
				str.addChar(curChar);
			}
			lastChar = curChar;
		}
		this = str.toString();
	}
	
	public inline function getCharacter(I:Int):Character
	{
		var index:Int = this.indexOf('char id=${Std.string(I)}');
		var end:Int = this.indexOf("\n", index);
		return Character.fromString(this.substring(index, end));
	}
	
	public inline function getKerning(First:Int, Second:Int):Int
	{
		var index:Int = this.indexOf('kerning first=${Std.string(First)} second=${Std.string(Second)}');
		if (index != -1)
		{
			var valIndex:Int = this.indexOf("amount=", index);
			var endIndex:Int = this.indexOf(" ", valIndex);
			return Std.parseInt(this.substring(valIndex+7, endIndex));
		}
		else
		{
			return 0;
		}
	}
}

abstract Character(Vector<Int>)
{
	inline function new(V)
	{
		this = V;
	}
	
	public inline function getRectangle():Rectangle
	{
		return new Rectangle(x(), y(), width(), height());
	}
	
	public inline function x():Int
	{
		return this.get(0);
	}
	
	public inline function y():Int
	{
		return this.get(1);
	}
	
	public inline function width():Int
	{
		return this.get(2);
	}
	
	public inline function height():Int
	{
		return this.get(3);
	}
	
	public inline function xoffset():Int
	{
		return this.get(4);
	}
	
	public inline function yoffset():Int
	{
		return this.get(5);
	}
	
	public inline function xadvance():Int
	{
		return this.get(6);
	}
	
	@:from public static inline function fromString(Str:String):Character
	{
		var data:Vector<Int> = new Vector<Int>(7);
		var start:Int = 0;
		var end:Int = 0;
		
		start = Str.indexOf("x=", end);
		end = Str.indexOf(" ", start);
		data.set(0, Std.parseInt(Str.substring(start + 2, end)));
		
		start = Str.indexOf("y=", end);
		end = Str.indexOf(" ", start);
		data.set(1, Std.parseInt(Str.substring(start + 2, end)));
		
		start = Str.indexOf("width=", end);
		end = Str.indexOf(" ", start);
		data.set(2, Std.parseInt(Str.substring(start + 6, end)));
		
		start = Str.indexOf("height=", end);
		end = Str.indexOf(" ", start);
		data.set(3, Std.parseInt(Str.substring(start + 7, end)));
		
		start = Str.indexOf("xoffset=", end);
		end = Str.indexOf(" ", start);
		data.set(4, Std.parseInt(Str.substring(start + 8, end)));
		
		start = Str.indexOf("yoffset=", end);
		end = Str.indexOf(" ", start);
		data.set(5, Std.parseInt(Str.substring(start + 8, end)));
		
		start = Str.indexOf("xadvance=", end);
		end = Str.indexOf(" ", start);
		data.set(6, Std.parseInt(Str.substring(start + 9, end)));
		
		return new Character(data);
	}
}
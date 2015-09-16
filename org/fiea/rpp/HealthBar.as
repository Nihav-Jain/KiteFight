package org.fiea.rpp 
{
	import com.greensock.easing.Circ;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class HealthBar extends Sprite 
	{
		private var outline:Shape;
		private var bar:Sprite;
		private var originalWidth:Number;
		
		private var breakPoints:Array;
		private var breakPointColors:Array;
		private var currentIndex:int;
		private var colorTransform:ColorTransform;
		
		private var _health:int;
		
		public function HealthBar(_x:Number, _y:Number, wid:Number, ht:Number, playerid:int) 
		{
			super();
			
			_health = 100;
			originalWidth = wid;

			bar = new Sprite();
			bar.graphics.beginFill(0x66FF00, 1);
			bar.graphics.drawRect(0, 0, wid, ht);
			bar.graphics.endFill();
			bar.x = _x;
			bar.y = _y;
			
			outline = new Shape();
			outline.graphics.lineStyle(2, 0x330000, 1);
			outline.graphics.moveTo(0, 0);
			outline.graphics.lineTo(wid, 0);
			outline.graphics.lineTo(wid, ht);
			outline.graphics.lineTo(0, ht);
			outline.graphics.lineTo(0, 0);
			outline.x = _x;
			outline.y = _y;
			
			this.addChild(bar);
			this.addChild(outline);
			

			var bmpd:BitmapData;
			if(playerid == 0)
				bmpd = new HealthBarP1();
			else
				bmpd = new HealthBarP2();
			var bmp:Bitmap = new Bitmap(bmpd);
			this.addChild(bmp);
			breakPoints = new Array(100, 90, 60, 40, 15, 0);
			breakPointColors = new Array(0x66FF00, 0x66FF00, 0xFFFF00, 0xFFFF00, 0xFF0000, 0xFF0000);
			currentIndex = 0;
			colorTransform = new ColorTransform();
			colorTransform.color = breakPointColors[currentIndex];
			
			TweenPlugin.activate([TintPlugin]);
		}
		
		public function doDamage(amount:int):void
		{
			
			health -= amount;
			var ratio:Number;
			
			if (health < breakPoints[currentIndex + 1])
				currentIndex++;
				ratio = ((breakPoints[currentIndex] - health) / Math.abs(breakPoints[currentIndex] - breakPoints[currentIndex + 1]));
			colorTransform.color = Color.interpolateColor(breakPointColors[currentIndex], breakPointColors[currentIndex + 1], ratio);
			var newWidth:Number = originalWidth * health / 100;
			var tweenSpeed = 50;
			TweenLite.killTweensOf(this.bar);
			TweenLite.to(this.bar, (this.bar.width - newWidth) / tweenSpeed, {width: newWidth, tint: colorTransform.color});
		}
		
		public function get health():int 
		{
			return _health;
		}
		
		public function set health(value:int):void 
		{
			_health = value;
			if (value < 0)
				_health = 0;
		}
		
	}

}
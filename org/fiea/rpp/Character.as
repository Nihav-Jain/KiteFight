package org.fiea.rpp 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Character extends Sprite 
	{
		private var arm:Sprite;
		private var bodySprite:Sprite;
		private var _gender:int;
		private var _armX:Number;
		private var _armY:Number;
		
		public static const GENDER_BOY:int = 0;
		public static const GENDER_GIRL:int = 1;
		
		public function Character() 
		{
			super();
			
			bodySprite = new Sprite();
			arm = new Sprite();
			
			this.addChild(bodySprite);
			this.addChild(arm);
		}
		
		public function createBodySprite(bodyXml:XML, bmpd:BitmapData):void
		{
			var newX:Number = parseFloat(bodyXml.@x);
			var newY:Number = parseFloat(bodyXml.@y);
			var wid:Number = parseFloat(bodyXml.@width);
			var ht:Number = parseFloat(bodyXml.@height)
			
			var mat:Matrix = new Matrix();
			mat.translate( -newX - wid / 2, -newY - ht / 2);
			
			//bodySprite = new Sprite();
			bodySprite.graphics.beginBitmapFill(bmpd, mat, false, true);
			bodySprite.graphics.drawRect( -wid / 2, -ht / 2, wid, ht);
			bodySprite.graphics.endFill();
		}
		
		public function createArmSprite(armXml:XML, bmpd:BitmapData):void
		{
			var newX:Number = parseFloat(armXml.@x) + 120;		// TODO: dont take a golden number
			var newY:Number = parseFloat(armXml.@y) + 36;		// TODO: dont take a golden number
			var wid:Number = parseFloat(armXml.@width);
			var ht:Number = parseFloat(armXml.@height);
			var mat:Matrix = new Matrix();
			mat.translate( -newX, -newY);
			
			//arm = new Sprite();
			arm.graphics.beginBitmapFill(bmpd, mat, false, true);
			arm.graphics.drawRect( -120, -36, wid, ht);
			arm.graphics.endFill();
			arm.x = 12.5;		// TODO: dont take a golden number
			arm.y = 36;			// TODO: dont take a golden number
		}
		
		public function rotateArm(deg:Number):void
		{
			this.arm.rotation = deg;
		}
		
		public function set gender(value:int):void 
		{
			_gender = value;
		}
		
		public function get armX():Number 
		{
			return arm.x;
		}
		
		public function get armY():Number 
		{
			return arm.y;
		}
		
	}

}
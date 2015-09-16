package org.fiea.rpp 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author BB
	 */
	public class MaskRect extends Sprite 
	{
		
		public function MaskRect(wid:Number, ht:Number, position:Point, parent:Sprite) 
		{
			super();
			this.graphics.beginFill(0x000000, 1);
			this.graphics.drawRect(-wid/2, -ht/2, wid, ht);
			this.graphics.endFill();
			
			this.x = position.x;
			this.y = position.y;
			
			parent.addChild(this);
		}
		
	}

}
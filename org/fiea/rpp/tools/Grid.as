package org.fiea.rpp.tools 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Grid extends Sprite 
	{
		
		public var crosshair:Crosshair;
		public var snapToGrid:Boolean;
		private var snapDistance:Number;
		private var gridWidth:int;
		private var gridHeight:int;
		
		private var _crosshairX:Number;
		private var _crosshairY:Number;
		
		public function Grid(wid:Number, ht:Number, gridWid:int, gridHt:int) 
		{
			super();
			
			this.redrawGrid(wid, ht, gridWid, gridHt);
			this.crosshair = new Crosshair();
			this.addChild(crosshair);
			this.snapToGrid = true;
			//Mouse.hide();
		}
		
		public function mouseMove(mx:Number, my:Number):void 
		{
			if (snapToGrid)
			{
				var cellX:int = Math.floor(mx / gridWidth);
				var cellY:int = Math.floor(my / gridHeight);
				if (Math.abs(mx - gridWidth * cellX) <= snapDistance) 
				{
					if (Math.abs(my - gridHeight * cellY) <= snapDistance)
					{
						my = gridHeight * cellY;
						mx = gridWidth * cellX;
					}
					else if (Math.abs(my - gridHeight * (cellY + 1)) <= snapDistance)
					{
						my = gridHeight * (cellY + 1);
						mx = gridWidth * cellX;
					}
				}
				else if (Math.abs(mx - gridWidth * (cellX + 1)) <= snapDistance) 
				{
					if (Math.abs(my - gridHeight * cellY) <= snapDistance)
					{
						my = gridHeight * cellY;
						mx = gridWidth * (cellX + 1);
					}
					else if (Math.abs(my - gridHeight * (cellY + 1)) <= snapDistance)
					{
						my = gridHeight * (cellY + 1);
						mx = gridWidth * (cellX + 1);
					}
				}
			}
			this.crosshair.x = mx;
			this.crosshair.y = my;
		}
		
		public function getCrosshairCoordinates():Point
		{
			return new Point(crosshair.x, crosshair.y);
		}
		
		private function redrawGrid(wid:Number, ht:Number, gridWid:int, gridHt:int):void
		{
			this.gridWidth = gridWid;
			this.gridHeight = gridHt;
			this.snapDistance = Math.round(gridWid / 3);

			this.graphics.clear();
			this.graphics.lineStyle(1, 0x000000, 0.2);
			var i:int, j:int;
			for (i = 0; i < wid; i += gridWid)
			{
				this.graphics.moveTo(i, 0);
				this.graphics.lineTo(i, ht);
			}
			for (i = 0; i < ht; i += gridHt)
			{
				this.graphics.moveTo(0, i);
				this.graphics.lineTo(wid, i);
			}
			this.graphics.lineStyle(2, 0x000000, 0.5);
			this.graphics.moveTo(wid / 2, 0);
			this.graphics.lineTo(wid / 2, ht);
			this.graphics.moveTo(0, ht / 2);
			this.graphics.lineTo(wid, ht / 2);
		}
		
		public function get crosshairX():Number 
		{
			return Math.round(crosshair.x);
		}
		
		public function get crosshairY():Number 
		{
			return Math.round(crosshair.y);
		}
		
	}

}
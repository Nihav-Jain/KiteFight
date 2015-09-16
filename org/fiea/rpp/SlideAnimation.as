package org.fiea.rpp
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import com.greensock.easing.Power0;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.events.LoaderEvent;
	import flash.geom.*; 
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import org.fiea.rpp.utils.SoundManager;
	/**
	 * ...
	 * @author BB
	 */
	public class SlideAnimation extends Sprite 
	{
		private var spriteArray:Array;
		private var spriteOrigin:Point;
		private var swipeLeft:SimpleButton;
		private var swipeRight:SimpleButton;
		public var currentSprite:uint = 0;
		public var inProgress:Boolean;
		
		public var eventDispatcher:EventDispatcher;
		public static const SHOWBUTTONS:String = "showbuttons";
		public static const HIDEBUTTONS:String = "hidebuttons";
		
		private var leftButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		
		public function SlideAnimation(SpriteArray:Array, SpriteOrigin:Point, LeftButtonPos:Point, RightButtonPos:Point, LeftButtonSprites:Vector.<Sprite>, RightButtonSprites:Vector.<Sprite>, driver:Sprite)
		{
			inProgress = false;
			eventDispatcher = new EventDispatcher();
			spriteArray = SpriteArray;
			spriteOrigin = SpriteOrigin;
			//var selector:int = 0;
			var offset:int = 0;
			for each (var sprite in spriteArray)
			{
				sprite.x = spriteOrigin.x + offset;
				sprite.y = spriteOrigin.y;
				offset += sprite.width; 
				addChild(sprite);
			}
			
			leftButtonSptrites = LeftButtonSprites;
			rightButtonSptrites = RightButtonSprites;
			
			//swipeLeft = new SwipeLeftButton();
			swipeLeft = new SimpleButton();
			swipeLeft.overState = leftButtonSptrites[1];
			swipeLeft.downState = leftButtonSptrites[2];
			swipeLeft.upState = leftButtonSptrites[0];
			swipeLeft.hitTestState = leftButtonSptrites[0];
			swipeLeft.x = LeftButtonPos.x;
			swipeLeft.y = LeftButtonPos.y;
			
			//swipeRight = new SwipeRightButton();
			swipeRight = new SimpleButton();
			swipeRight.overState = rightButtonSptrites[1];
			swipeRight.downState = rightButtonSptrites[2];
			swipeRight.upState = rightButtonSptrites[0];
			swipeRight.hitTestState = rightButtonSptrites[0];
			swipeRight.x = RightButtonPos.x;
			swipeRight.y = RightButtonPos.y;
			
			swipeLeft.addEventListener(MouseEvent.CLICK, SwipeSpritesLeft);
			swipeRight.addEventListener(MouseEvent.CLICK, SwipeSpritesRight);
			
			HideButtons();
			ShowButtons();
			
			driver.addChild(this);
			this.mask = new MaskRect(spriteArray[0].width, spriteArray[0].height, new Point(spriteArray[0].x, spriteArray[0].y), driver);
			
			driver.addChild(swipeLeft);
			driver.addChild(swipeRight);
		}
		
		public function SwipeSpritesLeft(e:MouseEvent):void
		{
			if (currentSprite == 0)
				return;
			SoundManager.getInstance().PlayRandomMenuSound();
			HideButtons();
			for each (var sprite in spriteArray)
			{
				TweenLite.to(sprite, 1, { x:sprite.x+sprite.width, y:sprite.y, ease:Cubic.easeOut,  onComplete: ShowButtons} );
			}
			currentSprite--;
		}
		
		public function SwipeSpritesRight(e:MouseEvent):void
		{
			if (currentSprite == spriteArray.length - 1)
				return;
			SoundManager.getInstance().PlayRandomMenuSound();
			HideButtons();
			for each (var sprite in spriteArray)
			{
				TweenLite.to(sprite, 1, { x:sprite.x-sprite.width, y:sprite.y, ease:Cubic.easeOut,  onComplete: ShowButtons} );
			}
			currentSprite++;
		}
		
		public function HideButtons():void
		{
			//SoundManager.getInstance().PlayRandomMenuSound();
			inProgress = true;
			eventDispatcher.dispatchEvent(new Event(HIDEBUTTONS));
			//swipeLeft.visible = false;
			//swipeRight.visible = false;
			swipeLeft.removeEventListener(MouseEvent.CLICK, SwipeSpritesLeft);
			swipeRight.removeEventListener(MouseEvent.CLICK, SwipeSpritesRight);
		}
		
		public function ShowButtons():void
		{
			inProgress = false;
			eventDispatcher.dispatchEvent(new Event(SHOWBUTTONS));
			//if (currentSprite != 0)
			//{
				//swipeLeft.visible = true;
			//}
			//if (currentSprite != spriteArray.length - 1)
			//{
				//swipeRight.visible = true;
			//}
			swipeLeft.addEventListener(MouseEvent.CLICK, SwipeSpritesLeft);
			swipeRight.addEventListener(MouseEvent.CLICK, SwipeSpritesRight);			
		}
		
		public function FlipSprites():void 
		{
			for each (var sprite in spriteArray)
			{
				sprite.rotationY = 180;
			}
		}
	}
	
}
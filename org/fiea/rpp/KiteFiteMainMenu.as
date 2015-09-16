package org.fiea.rpp
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.fiea.rpp.utils.SoundManager;
	import flash.display.SimpleButton;
	/**
	 * ...
	 * @author Brian Bennett
	 */
	public class KiteFiteMainMenu extends Sprite 
	{
		private var xml:XML;
		private var xmlLoader:XMLLoader;
		private var ld:LoaderMax = new LoaderMax( { name:"main", onComplete: loaded } );
		
		private var backgrounds = new Array();
		private var leftKiteSprites = new Array();
		private var rightKiteSprites = new Array();
		private var leftCharacterSprites = new Array();
		private var rightCharacterSprites = new Array();
		private var leftWeaponSprites = new Array();
		private var rightWeaponSprites = new Array();
		private var weaponXmls:Array = new Array();
		private var leftWeaponToUseSprites:Array = new Array();
		private var rightWeaponToUseSprites:Array = new Array();
		private var playerInfo:Array = new Array();
		private var playerOneWin:Sprite;
		private var playerTwoWin:Sprite;
		
		private var buttonsSpriteSheets:Array = new Array();
		private var buttonsSpriteSheetNames:Vector.<String> = new Vector.<String>();
		private var buttonsSubTextures:Array = new Array();
		private var buttonsSpriteSheetContainer:Sprite = new Sprite();
		
		//left side
		private var leftSideLeftBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var leftSideLeftGreenButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var leftSideLeftRedButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var leftSideRightBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var leftSideRightGreenButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var leftSideRightRedButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		
		//right side
		private var rightSideLeftBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightSideLeftGreenButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightSideLeftRedButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightSideRightBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightSideRightGreenButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var rightSideRightRedButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		
		private var helpSprites:Vector.<Sprite> = new Vector.<Sprite>;
		
		private var pauseSprites:Vector.<Sprite> = new Vector.<Sprite>;
		private var playSprites:Vector.<Sprite> = new Vector.<Sprite>;
		private var replaySprites:Vector.<Sprite> = new Vector.<Sprite>;
		
		private var soundOnSprites:Vector.<Sprite> = new Vector.<Sprite>;
		private var soundOffSprites:Vector.<Sprite> = new Vector.<Sprite>;
		
		//BG
		private var BGLeftBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		private var BGRightBlueButtonSptrites:Vector.<Sprite> = new Vector.<Sprite>;
		
		private var BGAnimation:SlideAnimation;
		private var LeftKiteAnimation:SlideAnimation;
		private var RightKiteAnimation:SlideAnimation;
		private var LeftCharacterAnimation:SlideAnimation;
		private var RightCharacterAnimation:SlideAnimation;
		private var leftWeaponAnimation:SlideAnimation;
		private var rightWeaponAnimation:SlideAnimation;
		
		private var playButton:playgame;
		public static var parentStage:Stage;
		private var callback:Function;
		
		private var help:SimpleButton;
		private var pause:SimpleButton;
		private var play:SimpleButton;
		private var replay:SimpleButton;
		private var soundOn:SimpleButton;
		private var soundOff:SimpleButton;
		
		private var startButton:SimpleButton;
		private var startButtonClicked:Function;
		public function KiteFiteMainMenu(_stage:Stage, callBackFunc:Function, startButton:SimpleButton, startButtonClicked:Function) 
		{
			xmlLoader = new XMLLoader("game-config.xml", { name: "game-config", onComplete: init } );
			xmlLoader.load();
			callback = callBackFunc;
			parentStage = _stage;
			this.startButton = startButton;
			this.startButtonClicked = startButtonClicked;
		}
		
		private function init(e:LoaderEvent):void
		{
			trace("xmlloaded");
			//callback.call(null);
			xml = new XML(LoaderMax.getContent("game-config"));
			for each(var background in xml.backgrounds.image)
			{
				backgrounds.push(new Sprite());
				ld.append(new ImageLoader(background.@src, {container: backgrounds[backgrounds.length-1], centerRegistration:true}));
			}
			for each(var kite in xml.kites.image)
			{
				leftKiteSprites.push(new Sprite());
				ld.append(new ImageLoader(kite.@src, {container: leftKiteSprites[leftKiteSprites.length-1], centerRegistration:true}));
			}
			for each(kite in xml.kites.image)
			{
				rightKiteSprites.push(new Sprite());
				ld.append(new ImageLoader(kite.@src, {container: rightKiteSprites[rightKiteSprites.length-1], centerRegistration:true}));
			}
			for each(var character in xml.characters.image)
			{
				leftCharacterSprites.push(new Sprite());
				ld.append(new ImageLoader(character.@src, {container: leftCharacterSprites[leftCharacterSprites.length-1], centerRegistration:true}));
			}
			for each(character in xml.characters.image)
			{
				rightCharacterSprites.push(new Sprite());
				ld.append(new ImageLoader(character.@src, {container: rightCharacterSprites[rightCharacterSprites.length-1], centerRegistration:true}));
			}
			for each(var weapon in xml.weapons.weapon)
			{
				leftWeaponSprites.push(new Sprite());
				rightWeaponSprites.push(new Sprite());
				//ld.append(new ImageLoader(weapon.@leftstats, {container: leftWeaponSprites[leftWeaponSprites.length-1], centerRegistration:true}));			
				ld.append(new ImageLoader(weapon.@leftstats, { container: leftWeaponSprites[leftWeaponSprites.length - 1], centerRegistration:true } ));
				ld.append(new ImageLoader(weapon.@rightstats, { container: rightWeaponSprites[rightWeaponSprites.length - 1], centerRegistration:true } ));
				leftWeaponToUseSprites.push(new Sprite());
				rightWeaponToUseSprites.push(new Sprite());
				ld.append(new ImageLoader(weapon.@src, { container: leftWeaponToUseSprites[leftWeaponToUseSprites.length - 1], centerRegistration: true } ));
				ld.append(new ImageLoader(weapon.@src, { container: rightWeaponToUseSprites[rightWeaponToUseSprites.length - 1], centerRegistration: true } ));
				weaponXmls.push(weapon);
			}
			playerOneWin = new Sprite();
			playerTwoWin = new Sprite();
			ld.append(new ImageLoader(xml.playeronewin.@src, { container: playerOneWin } ));
			ld.append(new ImageLoader(xml.playertwowin.@src, { container: playerTwoWin } ));
			var i:int  = 0;
			buttonsSpriteSheetNames.push(xml.spritesheets.buttons.TextureAtlas.@name);
			buttonsSubTextures.push(xml.spritesheets.buttons.TextureAtlas);
			ld.append(new ImageLoader(xml.spritesheets.buttons.TextureAtlas.@imagePath, { onComplete: buttonsLoadComplete, name: xml.spritesheets.buttons.TextureAtlas.@name, smoothing:true}));

			for each(var player in xml.players.player)
			{
				playerInfo.push(player);
			}
			ld.load();
		}
		
		private function buttonsLoadComplete(ev:LoaderEvent):void
		{
			var i:int = buttonsSpriteSheetNames.indexOf(ev.target.name);
			
			buttonsSpriteSheets[i] = (ev.target.rawContent) as Bitmap;
			var bmpd:BitmapData = Bitmap(buttonsSpriteSheets[i]).bitmapData;
			//trace(typeof(buttonsSubTextures[i]));
			var xml:XMLList = buttonsSubTextures[i];
			
			//left side
			for each (var sub in xml.SubTexture)
			{
				var sprite:Sprite = new Sprite();
				var mat:Matrix = new Matrix();
				mat.translate( -parseFloat(sub.@x), -parseFloat(sub.@y));
				sprite.graphics.beginBitmapFill(bmpd, mat, false, true);				
				sprite.graphics.drawRect(0, 0, parseFloat(sub.@width), parseFloat(sub.@height));
				sprite.graphics.endFill();
				//trace(sub.@id);
				switch (parseInt(sub.@id)){
				case 1:
					leftSideLeftBlueButtonSptrites.push(sprite);
					break;
				case 2:
					leftSideLeftGreenButtonSptrites.push(sprite);
					break;
				case 3:
					leftSideLeftRedButtonSptrites.push(sprite);
					break;
				case 4:
					leftSideRightBlueButtonSptrites.push(sprite);
					break;
				case 5:
					leftSideRightGreenButtonSptrites.push(sprite);
					break;
				case 6:
					leftSideRightRedButtonSptrites.push(sprite);
					break;
				case 7:
					helpSprites.push(sprite);
					break;
				case 8:
					pauseSprites.push(sprite);
					break;
				case 9:
					replaySprites.push(sprite);
					break;
				case 10:
					soundOffSprites.push(sprite);
					break;
				case 11:
					soundOnSprites.push(sprite);
					break;
				case 12:
					playSprites.push(sprite);
					break;
				}
				
				//buttonsSpriteSheetContainer.addChild(sprite);
				//break;
			}
			
			//right side
			for each (sub in xml.SubTexture)
			{
				sprite = new Sprite();
				mat = new Matrix();
				mat.translate( -parseFloat(sub.@x), -parseFloat(sub.@y));
				sprite.graphics.beginBitmapFill(bmpd, mat, false, true);				
				sprite.graphics.drawRect(0, 0, parseFloat(sub.@width), parseFloat(sub.@height));
				sprite.graphics.endFill();
				//trace(sub.@id);
				switch (parseInt(sub.@id)){
				case 1:
					rightSideLeftBlueButtonSptrites.push(sprite);
					break;
				case 2:
					rightSideLeftGreenButtonSptrites.push(sprite);
					break;
				case 3:
					rightSideLeftRedButtonSptrites.push(sprite);
					break;
				case 4:
					rightSideRightBlueButtonSptrites.push(sprite);
					break;
				case 5:
					rightSideRightGreenButtonSptrites.push(sprite);
					break;
				case 6:
					rightSideRightRedButtonSptrites.push(sprite);
					break;
				}
				
				//buttonsSpriteSheetContainer.addChild(sprite);
				//break;
			}
			
			//make buttons
			soundOff = new SimpleButton();
			soundOff.overState = soundOffSprites[0];
			soundOff.downState = soundOffSprites[1];
			soundOff.upState = soundOffSprites[0];
			soundOff.hitTestState = soundOffSprites[0];
			soundOff.x = 1500;
			soundOff.y = 800;
			
			
			soundOn = new SimpleButton();
			soundOn.overState = soundOnSprites[0];
			soundOn.downState = soundOnSprites[1];
			soundOn.upState = soundOnSprites[0];
			soundOn.hitTestState = soundOnSprites[0];
			soundOn.x = 1500;
			soundOn.y = 800;
			//soundOn.visible = false;
			//soundOff.visible = true;
			
			if (SoundManager.getInstance().Muted)
			{
				soundOn.visible = false;
				soundOff.visible = true;
				//trace("muted");
			}
			else
			{
				soundOn.visible = true;
				soundOff.visible = false;
				trace("unmuted");
			}
			//parentStage.addChild(soundOn);
			
			//BG
			/*for each (sub in xml.SubTexture)
			{
				sprite = new Sprite();
				mat = new Matrix();
				mat.translate( -parseFloat(sub.@x), -parseFloat(sub.@y));
				sprite.graphics.beginBitmapFill(bmpd, mat, false, true);				
				sprite.graphics.drawRect(0, 0, parseFloat(sub.@width), parseFloat(sub.@height));
				sprite.graphics.endFill();
				trace(sub.@id);
				switch (parseInt(sub.@id)){
				case 1:
					BGLeftBlueButtonSptrites.push(sprite);
					break;
				case 4:
					BGRightBlueButtonSptrites.push(sprite);
					break;
				}
				
				//buttonsSpriteSheetContainer.addChild(sprite);
				//break;
			}*/
		}
		
		private function loaded(l:LoaderEvent):void
		{
			Console.log("total size = " + l.target.bytesTotal);
			SoundManager.getInstance().eventDispatcher.addEventListener(SoundManager.LOADED, Loaded);
		}
		
		private function Loaded(e:Event):void
		{
			startButton.addEventListener(MouseEvent.CLICK, startButtonClicked);
			SoundManager.getInstance().Play("MenuMusic");
			soundOff.addEventListener(MouseEvent.CLICK, Mute);
			soundOn.addEventListener(MouseEvent.CLICK, UnMute);
			addChild(backgrounds[1]);
			backgrounds[1].x = backgrounds[1].width / 2;
			backgrounds[1].y = backgrounds[1].height / 2;
			backgrounds[0].x = backgrounds[0].width / 2;
			backgrounds[0].y = backgrounds[0].height / 2;
			
			var origin:Point = new Point(backgrounds[0].width / 2, backgrounds[0].height / 2);
			var leftbutton:Point = new Point(111, 445);
			var rightbutton:Point = new Point(1480, 445);
			/*BGAnimation = new SlideAnimation(backgrounds, origin, leftbutton, rightbutton, BGLeftBlueButtonSptrites, BGRightBlueButtonSptrites, this);
			
			BGAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			BGAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);*/
			
			origin = new Point(264.55, 224.35);
			leftbutton = new Point(93.1, 173.75);
			rightbutton = new Point(360.85, 173.75);
			LeftKiteAnimation = new SlideAnimation(leftKiteSprites, origin, leftbutton, rightbutton, leftSideLeftGreenButtonSptrites, leftSideRightGreenButtonSptrites, this);
			
			LeftKiteAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			LeftKiteAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);
			
			origin = new Point(1326.6, 224.32);
			leftbutton = new Point(1195.3-40, 173.75);
			rightbutton = new Point(1460.6-40, 173.75);
			RightKiteAnimation = new SlideAnimation(rightKiteSprites, origin, leftbutton, rightbutton, rightSideLeftGreenButtonSptrites, rightSideRightGreenButtonSptrites, this);
			
			RightKiteAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			RightKiteAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);
			
			origin = new Point(300, 773);
			leftbutton = new Point(300 - leftCharacterSprites[0].width/2 - leftSideLeftBlueButtonSptrites[0].width, 775);
			rightbutton = new Point(300 + leftCharacterSprites[0].width/2, 775);
			LeftCharacterAnimation = new SlideAnimation(leftCharacterSprites, origin, leftbutton, rightbutton, leftSideLeftBlueButtonSptrites, leftSideRightBlueButtonSptrites, this);
			LeftCharacterAnimation.FlipSprites();
			
			LeftCharacterAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			LeftCharacterAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);
			
			origin = new Point(1268, 773);
			leftbutton = new Point(1268 - leftCharacterSprites[0].width/2 - leftSideLeftBlueButtonSptrites[0].width, 775);
			rightbutton = new Point(1268 + leftCharacterSprites[0].width/2, 775);
			RightCharacterAnimation = new SlideAnimation(rightCharacterSprites, origin, leftbutton, rightbutton, rightSideLeftBlueButtonSptrites, rightSideRightBlueButtonSptrites, this);
			
			RightCharacterAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			RightCharacterAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);
			
			origin = new Point(415, 415);
			leftbutton = new Point(83, 333);
			rightbutton = new Point(660, 333);
			leftWeaponAnimation = new SlideAnimation(leftWeaponSprites, origin, leftbutton, rightbutton, leftSideLeftRedButtonSptrites, leftSideRightRedButtonSptrites, this);
			leftWeaponAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			leftWeaponAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);

			origin = new Point(1177, 415);
			leftbutton = new Point(856, 333);
			rightbutton = new Point(1430, 333);
			rightWeaponAnimation = new SlideAnimation(rightWeaponSprites, origin, leftbutton, rightbutton, rightSideLeftRedButtonSptrites, rightSideRightRedButtonSptrites, this);
			rightWeaponAnimation.eventDispatcher.addEventListener(SlideAnimation.SHOWBUTTONS, ShowButtons);
			rightWeaponAnimation.eventDispatcher.addEventListener(SlideAnimation.HIDEBUTTONS, HideButtons);

			
			playButton = new playgame();
			playButton.addEventListener(MouseEvent.CLICK, Play);
			playButton.x = (parentStage.stageWidth / 2) - playButton.width/2;
			playButton.y = 0;
			
			//trace("asdg");
/*			addChild(BGAnimation);
			addChild(LeftKiteAnimation);
			addChild(RightKiteAnimation);
			addChild(LeftCharacterAnimation);
			addChild(RightCharacterAnimation);*/
			addChild(playButton);
			addChild(soundOff);
			addChild(soundOn);
			
			/*var goButton:SimpleButton = new SimpleButton();
			
			
			goButton.overState = leftBlueButtonSptrites[1];
			goButton.downState = leftBlueButtonSptrites[2];
			goButton.upState = leftBlueButtonSptrites[0];
			goButton.hitTestState = leftBlueButtonSptrites[0];
			addChild(goButton);*/

			/*var i:int = 0;
			for each (var sprite in leftBlueButtonSptrites)
			{
				sprite.x += i;
				this.addChild(sprite);
				i += 100;
			}*/
		}
		
		public function Mute(e:MouseEvent):void
		{
			SoundManager.getInstance().Mute();
			soundOff.visible = false;
			soundOn.visible = true;
		}
		
		public function UnMute(e:MouseEvent):void
		{
			SoundManager.getInstance().UnMute();
			soundOff.visible = true;
			soundOn.visible = false;
		}
		
		public function HideButtons(e:Event):void
		{
			//playButton.visible = false;
			playButton.removeEventListener(MouseEvent.CLICK, Play);
		}
		
		public function ShowButtons(e:Event):void
		{
			if (!LeftKiteAnimation.inProgress)
			{
				if (!RightKiteAnimation.inProgress)
				{
					if (!LeftCharacterAnimation.inProgress)
					{
						if (!RightCharacterAnimation.inProgress)
						{
							//playButton.visible = true;
							playButton.addEventListener(MouseEvent.CLICK, Play);
						}
					}
				}
			}
		}
		
		public function Play(e:MouseEvent):void
		{
			SoundManager.getInstance().PlayRandomMenuSound();
			soundOn.removeEventListener(MouseEvent.CLICK, UnMute);
			soundOff.removeEventListener(MouseEvent.CLICK, Mute);
			callback.call(null, backgrounds[0], leftKiteSprites[LeftKiteAnimation.currentSprite], rightKiteSprites[RightKiteAnimation.currentSprite], leftCharacterSprites[LeftCharacterAnimation.currentSprite], rightCharacterSprites[RightCharacterAnimation.currentSprite], weaponXmls[leftWeaponAnimation.currentSprite], leftWeaponToUseSprites[leftWeaponAnimation.currentSprite], weaponXmls[rightWeaponAnimation.currentSprite], rightWeaponToUseSprites[rightWeaponAnimation.currentSprite], playerInfo[0], playerInfo[1], soundOffSprites, soundOnSprites, playerOneWin, playerTwoWin, pauseSprites, replaySprites, helpSprites, playSprites);
		}
		
		public function checkSoundButton():void {
			if (!SoundManager.getInstance().Muted)
			{
				soundOn.visible = false;
				soundOff.visible = true;
				//trace("muted");
			}
			else
			{
				soundOn.visible = true;
				soundOff.visible = false;
				trace("unmuted");
			}
	
		}
	}
	
}
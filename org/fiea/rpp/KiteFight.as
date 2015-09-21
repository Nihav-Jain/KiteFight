package org.fiea.rpp
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	import org.fiea.rpp.utils.SoundManager;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Nihav Jain, Brian Bennett
	 */
	public class KiteFight extends Sprite 
	{
		
		private var xml:XML;
		private var timer:uint;
		private var xmlLoader:XMLLoader;
		private var kite0WasHit:Boolean = false;
        private var kite1WasHit:Boolean = false;
		private var HitJustHappened:Boolean = false;
		private var _slowRate:Number;
		public var eventDispatcher:EventDispatcher;
		public static const UPDATE_HEALTH:String = "updateHealth";
		public static const PLAY_HITSOUND:String = "playHitSound";
		
		private var kiteContactListner:KiteContactListener;
		private var players:Vector.<Kite>;
		
		private var exitFunction:Function;
		
		public static var STAGE:Stage;
		public var health1:Number;
		public var health2:Number;
		
		private var gamePaused:Boolean;
		private var bkgrd:Sprite;
		
		public var help:SimpleButton;
		public var pause:SimpleButton;
		public var play:SimpleButton;
		public var replay:SimpleButton;
		private var soundOn:SimpleButton;
		private var soundOff:SimpleButton;
		private var playerOneWin:Sprite;
		private var playerTwoWin:Sprite;
		
		private static var me:KiteFight;
		private var stageElements:Sprite;
		
		public function KiteFight(_stage:Stage, backgroundSprite:Sprite, leftKiteSprite:Sprite, rightKiteSprite:Sprite, leftCharacterSprite:Sprite, rightCharacterSprite:Sprite, leftWeaponXml:XML, leftWeapon:Sprite, rightWeaponXml:XML, rightWeapon:Sprite, leftPlayerInfo:XML, rightPlayerInfo:XML, exitFunc:Function, soundOffSprites:Vector.<Sprite>, soundOnSprites:Vector.<Sprite>, _playerOneWins:Sprite, _playerTwoWins:Sprite, pauseSprites:Vector.<Sprite>, replaySprites:Vector.<Sprite>, helpSprites:Vector.<Sprite>, playSprites:Vector.<Sprite>) 
		{
			super();
			SoundManager.getInstance().Pause("MenuMusic");
			SoundManager.getInstance().Play("GPMusic");
			soundOff = new SimpleButton();
			soundOff.overState = soundOffSprites[0];
			soundOff.downState = soundOffSprites[1];
			soundOff.upState = soundOffSprites[0];
			soundOff.hitTestState = soundOffSprites[0];
			soundOff.x = 1500;
			soundOff.y = 800-65;
			
			soundOn = new SimpleButton();
			soundOn.overState = soundOnSprites[0];
			soundOn.downState = soundOnSprites[1];
			soundOn.upState = soundOnSprites[0];
			soundOn.hitTestState = soundOnSprites[0];
			soundOn.x = 1500;
			soundOn.y = 800-65;
			
			pause = new SimpleButton();
			pause.overState = pauseSprites[0];
			pause.downState = pauseSprites[1];
			pause.upState = pauseSprites[0];
			pause.hitTestState = pauseSprites[0];
			pause.x = 1500;
			pause.y = 800 + soundOn.height - 65;
			
			play = new SimpleButton();
			play.overState = playSprites[1];
			play.downState = playSprites[0];
			play.upState = playSprites[1];
			play.hitTestState = playSprites[1];
			play.x = 1500;
			play.y = 800 + soundOn.height - 65;
			play.visible = false;
			
			replay = new SimpleButton();
			replay.overState = replaySprites[0];
			replay.downState = replaySprites[1];
			replay.upState = replaySprites[0];
			replay.hitTestState = replaySprites[0];
			replay.x = 1500;
			replay.y = 800 + soundOn.height * 2 - 65;
			
			help = new SimpleButton();
			help.overState = helpSprites[0];
			help.downState = helpSprites[1];
			help.upState = helpSprites[0];
			help.hitTestState = helpSprites[0];
			help.x = 1500;
			help.y = 800 - soundOn.height-65;
			
			if (SoundManager.getInstance().Muted)
			{
				soundOn.visible = true;
				soundOff.visible = false;
				//trace("muted");
			}
			else
			{
				soundOn.visible = false;
				soundOff.visible = true;
				//trace("unmuted");
			}
			
			soundOff.addEventListener(MouseEvent.CLICK, Mute);
			soundOn.addEventListener(MouseEvent.CLICK, UnMute);
			pause.addEventListener(MouseEvent.CLICK, pauseGame);
			play.addEventListener(MouseEvent.CLICK, pauseGame);
			replay.addEventListener(MouseEvent.CLICK, exit);
			help.addEventListener(MouseEvent.CLICK, Help);
			
			//SoundManager.getInstance().Play("SlowMo");
			TweenPlugin.activate([BlurFilterPlugin]);
			this.exitFunction = exitFunc;
			health1 = 100;
			health2 = 100;
			timer = 0;
			_slowRate = 1;
			eventDispatcher = new EventDispatcher();
			STAGE = _stage;
			players = new Vector.<Kite>();
			gamePaused = false;
			
			bkgrd = backgroundSprite;
			this.addChild(bkgrd);
			this.setupPhysicsWorld(0, 10);
			this.createWalls();
			
			playerOneWin = _playerOneWins;
			playerTwoWin = _playerTwoWins;

			InputManager.getInstance().addPlayer(leftPlayerInfo);
			InputManager.getInstance().addPlayer(rightPlayerInfo);
			players.push(new Kite(0, leftPlayerInfo, this, leftKiteSprite, leftCharacterSprite, leftWeaponXml, leftWeapon));
			players.push(new Kite(1, rightPlayerInfo, this, rightKiteSprite, rightCharacterSprite, rightWeaponXml, rightWeapon));
		
			InputManager.getInstance().dispatchPauseEvent.addEventListener(InputManager.PAUSE_GAME, pauseGame);
			InputManager.getInstance().dispatchPauseEvent.addEventListener(InputManager.EXIT_GAME, exit);
			InputManager.getInstance().addInputListeners(STAGE);
			this.addEventListener(Event.ENTER_FRAME, update);
			stageElements = new Sprite();
			STAGE.addChild(this);
			STAGE.addChild(stageElements);
			stageElements.addChild(soundOff);
			stageElements.addChild(soundOn);
			stageElements.addChild(pause);
			stageElements.addChild(play);
			stageElements.addChild(replay);
			stageElements.addChild(help);
			me = this;
		}
				
		private function update(e:Event):void 
		{
			for each(var player:Kite in this.players)
			{
				player.updateNow();
				//Console.log("hello " + player.body.GetPosition().x * PhysicsWorld.RATIO, player.body.GetPosition().y * PhysicsWorld.RATIO);
			}
			if (!HitJustHappened)
			{

				if (players[1].knife.body.GetPosition().x >= players[0].body.GetPosition().x - 2 && players[1].knife.body.GetPosition().x <= players[0].body.GetPosition().x + 2)
				{
					if (players[1].knife.body.GetPosition().y >= players[0].body.GetPosition().y - 2 && players[1].knife.body.GetPosition().y <= players[0].body.GetPosition().y +2)
					{
						SoundManager.getInstance().EnterSlowMo();
						_slowRate = 10;
						this.blurBackground();

					}
				}
				else 
				{
					SoundManager.getInstance().ExitSlowMo();
					this.unBlurBackground();
					_slowRate = 1;
				}
				if (players[0].knife.body.GetPosition().x >= players[1].body.GetPosition().x - 2 && players[0].knife.body.GetPosition().x <= players[1].body.GetPosition().x + 2)
				{
					if (players[0].knife.body.GetPosition().y >= players[1].body.GetPosition().y - 2 && players[0].knife.body.GetPosition().y <= players[1].body.GetPosition().y +2)
					{
						SoundManager.getInstance().EnterSlowMo();
						_slowRate = 10;
						this.blurBackground();
					}
				}
				else 
				{
					SoundManager.getInstance().ExitSlowMo();
					this.unBlurBackground();
					_slowRate = 1;
				}
			}
			else
			{
				if (timer < 30)
				{
					++timer;
				}
				else
				{
					timer = 0;
					HitJustHappened = false; 
				}
			}
			
			PhysicsWorld.world.Step(1 / (30 * _slowRate), 10, 10);
			PhysicsWorld.world.ClearForces();
			this.checkCollisions();
			if (Console.ENVIRONMENT == Console.BOX2DTEST)
				PhysicsWorld.world.DrawDebugData();			
		}
		
		public function Help(e:MouseEvent):void
		{
			this.visible = false;
			pause.visible = false;
			play.visible = false;
			replay.visible = false;
			help.visible = false;
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
				
		private function Kite0Hit(e:Event):void
		{
			if (!HitJustHappened)
			{
				kite0WasHit = true;
			}
		}
		
		private function Kite1Hit(e:Event):void
		{
			if (!HitJustHappened)
			{
				kite1WasHit = true;
			}
		}
		
		private function AfterHit(e:Event):void
		{
			SoundManager.getInstance().ExitSlowMo();
			this.unBlurBackground();
			_slowRate = 1;
			HitJustHappened = true;
		}
		
		private function setupPhysicsWorld(gravx:Number, gravy:Number):void
		{
			var gravity:b2Vec2 = new b2Vec2(gravx, gravy);
			PhysicsWorld.world = new b2World(gravity, true);
			
			kiteContactListner = new KiteContactListener();
			kiteContactListner.eventDispatcher.addEventListener(KiteContactListener.KITE_0_HIT, Kite0Hit);
			kiteContactListner.eventDispatcher.addEventListener(KiteContactListener.KITE_1_HIT, Kite1Hit);
			kiteContactListner.eventDispatcher.addEventListener(KiteContactListener.HIT_JUST_HAPPENED, AfterHit);
			PhysicsWorld.world.SetContactListener(kiteContactListner);
			
			
			// only for debugging box2d
			var debug_draw:b2DebugDraw = new b2DebugDraw();
			var debug_sprite:Sprite = new Sprite();
			this.addChild(debug_sprite);
			debug_draw.SetSprite(debug_sprite);
			debug_draw.SetDrawScale(PhysicsWorld.RATIO);
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit);
			//debug_draw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			debug_draw.SetLineThickness(1);
			debug_draw.SetAlpha(0.8);
			debug_draw.SetFillAlpha(1);
			PhysicsWorld.world.SetDebugDraw(debug_draw);
		}
		
		private function createWalls():void
		{
			// top
			var topWall:Wall = new Wall(-4 * PhysicsWorld.RATIO, -4 * PhysicsWorld.RATIO, STAGE.stageWidth + 8 * PhysicsWorld.RATIO, PhysicsWorld.RATIO);
			
			//bottom
			var bottomWall = new Wall(-4 * PhysicsWorld.RATIO, STAGE.stageHeight + 4 * PhysicsWorld.RATIO, STAGE.stageWidth + 8 * PhysicsWorld.RATIO, PhysicsWorld.RATIO);
			
			//left
			var leftWall = new Wall( -4 * PhysicsWorld.RATIO, -4 * PhysicsWorld.RATIO, PhysicsWorld.RATIO, STAGE.stageHeight + 8 * PhysicsWorld.RATIO);
			
			//right
			var rightWall = new Wall(STAGE.stageWidth + 4*PhysicsWorld.RATIO, -4 * PhysicsWorld.RATIO, PhysicsWorld.RATIO, STAGE.stageHeight + 8 * PhysicsWorld.RATIO);
		}
		
		private function checkCollisions():void 
		{
			
			if (kite0WasHit || kite1WasHit)
			{
				var contactPoints:Vector.<b2Vec2> = kiteContactListner.worldManifold.m_points;
				var normal:b2Vec2 = kiteContactListner.worldManifold.m_normal;
				var knifeVelMinusNormal:b2Vec2 = kiteContactListner.bodyA.GetLinearVelocity().Copy();
				knifeVelMinusNormal.Subtract(normal);
				var knifeVelLength:Number = kiteContactListner.bodyA.GetLinearVelocity().Length();
				var normalLength:Number = normal.Length();
				var knifeVelMinusNormalLength:Number = knifeVelMinusNormal.Length();

				// cos rule
				var cosTheta:Number = (knifeVelLength * knifeVelLength + normalLength * normalLength - knifeVelMinusNormalLength * knifeVelMinusNormalLength) / (2 * knifeVelLength * normalLength);
				var knifeVelocity:b2Vec2 = kiteContactListner.bodyA.GetLinearVelocity().Copy();
				knifeVelocity.Multiply(cosTheta);
				normal.Multiply(cosTheta);
				knifeVelocity.Add(normal)
				var damageAmount:int = int(Math.round(2 * knifeVelocity.Length()));
				Console.log("damage amount " + Math.round(knifeVelocity.Length()), damageAmount);	// attack points

				if (kite0WasHit)
				{
					players[0].takeDamage(damageAmount);
					if (players[0].getHealth() > 50)
					{
						SoundManager.getInstance().PlayRandomHitSound();
					}
					else
					{
						SoundManager.getInstance().PlayRandomDamagedSound();
					}
					trace("player 0 health " + players[0].getHealth());
					//--health1;
					health1 -= damageAmount;
					if (health1 < 0)
					{
						health1 = 0;
					}
					if (health1 == 0)
					{
						pause.visible = false;
						play.visible = false;
						help.visible = false;
						players[0].StopInput();
						players[1].StopInput();
						//SoundManager.getInstance().Play("Crashing");
						players[0].die();
						players[1].GoToCenter();
						this.showWinSign(0);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.KITE_0_HIT, Kite0Hit);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.KITE_1_HIT, Kite1Hit);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.HIT_JUST_HAPPENED, AfterHit);
					}
					kite0WasHit = false;
					eventDispatcher.dispatchEvent(new Event(UPDATE_HEALTH));
					eventDispatcher.dispatchEvent(new Event(PLAY_HITSOUND));
				}
				else if (kite1WasHit)
				{
					players[1].takeDamage(damageAmount);
					if (players[1].getHealth() > 50)
					{
						SoundManager.getInstance().PlayRandomHitSound();
					}
					else
					{
						SoundManager.getInstance().PlayRandomDamagedSound();
					}
					trace("player 1 health " + players[1].getHealth());
					//--health2;
					health2 -= damageAmount;
					if (health2 < 0)
					{
						health2 = 0;
					}
					if (health2 == 0)
					{
						pause.visible = false;
						play.visible = false;
						help.visible = false;
						players[0].StopInput();
						players[1].StopInput();
						//SoundManager.getInstance().Play("Crashing");
						players[1].die();
						players[0].GoToCenter2();
						this.showWinSign(1);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.KITE_0_HIT, Kite0Hit);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.KITE_1_HIT, Kite1Hit);
						kiteContactListner.eventDispatcher.removeEventListener(KiteContactListener.HIT_JUST_HAPPENED, AfterHit);
					}
					kite1WasHit = false;
					eventDispatcher.dispatchEvent(new Event(UPDATE_HEALTH));
					eventDispatcher.dispatchEvent(new Event(PLAY_HITSOUND));
				}
				
			}
		}
		
		private function blurBackground():void
		{
			TweenLite.killTweensOf(this.bkgrd);
			TweenLite.to(bkgrd, 0.5, { blurFilter: { blurX: 20, blurY: 20 }} );			
			for each (var player:Kite in players)
			{
				player.blurCharacter();
			}
		}
		
		private function unBlurBackground():void
		{
			TweenLite.killTweensOf(this.bkgrd);
			TweenLite.to(bkgrd, 0.5, {blurFilter: {blurX: 0, blurY: 0}});			
			for each (var player:Kite in players)
			{
				player.unBlurCharacter();
			}
		}
		
		public function get slowRate():Number 
		{
			return _slowRate;
		}
		
		public function pauseGame(e:Event):void
		{
			
			if (gamePaused) 
			{
				play.visible = false;
				pause.visible = true;
				this.addEventListener(Event.ENTER_FRAME, update);
				TweenLite.to(this, 0.5, {blurFilter: {blurX: 0, blurY: 0}});
			}
			else
			{
				play.visible = true;
				pause.visible = false;
				this.removeEventListener(Event.ENTER_FRAME, update);
				TweenLite.to(this, 0.5, {blurFilter: {blurX: 20, blurY: 20}});
			}
			gamePaused = !gamePaused;
		}
		
		public function exit(e:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
			soundOff.removeEventListener(MouseEvent.CLICK, Mute);
			soundOn.removeEventListener(MouseEvent.CLICK, UnMute);
			pause.removeEventListener(MouseEvent.CLICK, pauseGame);
			play.removeEventListener(MouseEvent.CLICK, pauseGame);
			replay.removeEventListener(MouseEvent.CLICK, exit);
			help.removeEventListener(MouseEvent.CLICK, Help);
			STAGE.removeChild(stageElements);
/*			STAGE.removeChild(soundOff);
			STAGE.removeChild(soundOn);
			STAGE.removeChild(pause);
			STAGE.removeChild(play);
			STAGE.removeChild(replay);
			STAGE.removeChild(help);*/
			InputManager.getInstance().removeInputListeners(STAGE);
			InputManager.destroy();
			
			SoundManager.destroy();
			for each(var player:Kite in this.players)
			{
				player.destroyNow();
			}
			this.exitFunction.call(null);
		}
		
		public function showWinSign(playerid:int):void
		{
			if (playerid == 0)
			{
				stageElements.addChild(playerOneWin);
				playerOneWin.x = 100;
				playerOneWin.y = 150;
				playerOneWin.alpha = 0;
				TweenLite.to(playerOneWin, 1, { alpha: 1 } );
			}
			else
			{
				stageElements.addChild(playerTwoWin);
				playerTwoWin.x = STAGE.stageWidth - 100 - playerTwoWin.width;
				playerTwoWin.y = 150;
				playerTwoWin.alpha = 0;
				TweenLite.to(playerTwoWin, 1, { alpha: 1 } );
			}
			TweenLite.to(me, 0.5, {blurFilter: {blurX: 20, blurY: 20}});
		}
		
	}

}

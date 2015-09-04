package org.fiea.rpp
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class KiteFight extends Sprite 
	{
		
		private var xml:XML;
		private var xmlLoader:XMLLoader;
		
		private var players:Vector.<Kite>;
		
		private static var STAGE:Stage;
		
		public function KiteFight(_stage:Stage) 
		{
			super();
			
			STAGE = _stage;
			players = new Vector.<Kite>();
			
			xmlLoader = new XMLLoader("config.xml", { name: "game-config", onComplete: init } );
			xmlLoader.load();
		}
		
		private function init(e:LoaderEvent):void
		{
			xml = new XML(LoaderMax.getContent("game-config"));
			this.setupPhysicsWorld(parseFloat(xml.gravity.@X), parseFloat(xml.gravity.@Y));
			for each(var player in xml.player)
			{
				InputManager.getInstance().addPlayer(player);
			}
			var i:uint = 0;
			for each(var playerKite in xml.kite)
			{
				this.players.push(new Kite(i, playerKite));
				i++;
			}
			
			InputManager.getInstance().addInputListeners(STAGE);
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void 
		{
			for each(var player:Kite in this.players)
			{
				player.update();
				//Console.log("hello " + player.body.GetPosition().x * PhysicsWorld.RATIO, player.body.GetPosition().y * PhysicsWorld.RATIO);
			}
			//Console.log();
			PhysicsWorld.world.Step(1 / 30, 10, 10);
			PhysicsWorld.world.ClearForces();
			if (Console.ENVIRONMENT == Console.BOX2DTEST)
				PhysicsWorld.world.DrawDebugData();			
		}
		
		private function setupPhysicsWorld(gravx:Number, gravy:Number):void
		{
			var gravity:b2Vec2 = new b2Vec2(gravx, gravy);
			PhysicsWorld.world = new b2World(gravity, true);
			
			// only for debugging box2d
			var debug_draw:b2DebugDraw = new b2DebugDraw();
			var debug_sprite:Sprite = new Sprite();
			this.addChild(debug_sprite);
			debug_draw.SetSprite(debug_sprite);
			debug_draw.SetDrawScale(PhysicsWorld.RATIO);
			//debug_draw.SetFlags(b2DebugDraw.e_shapeBit);
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			debug_draw.SetLineThickness(1);
			debug_draw.SetAlpha(0.8);
			debug_draw.SetFillAlpha(0.3);
			PhysicsWorld.world.SetDebugDraw(debug_draw);
		}
		
		
	}

}
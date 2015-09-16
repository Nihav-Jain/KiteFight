package org.fiea.rpp
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class RopeLink extends Box2DActor
	{
		
		// pass wid, ht and location in Box2D World dimentions
		public function RopeLink(parent:DisplayObjectContainer, wid:Number, ht:Number, location:Point, fric:Number, resti:Number, density:Number) 
		{
			var body:b2Body = createBody(wid, ht, location, fric, resti, density);
			var skin:Sprite = this.createSprite(wid, ht, location);
			super(body, skin);
			parent.addChild(skin);			
		}
		
		// location is top-left corner
		private function createSprite(wid:Number, ht:Number, location:Point):Sprite
		{
			wid = wid * PhysicsWorld.RATIO;
			ht = ht * PhysicsWorld.RATIO;
			
			//var ropeSprite:Sprite = new ropeSprite(wid, ht);
			var ropeSprite:Sprite = new Sprite();
			ropeSprite.graphics.beginFill(0x663300, 1);
			ropeSprite.graphics.drawRect(-wid / 2, -ht / 2, wid, ht);
			ropeSprite.graphics.endFill();
			
			ropeSprite.x = location.x * PhysicsWorld.RATIO + ropeSprite.width/2;
			ropeSprite.y = location.y * PhysicsWorld.RATIO + ropeSprite.height/2;
			
			return ropeSprite;
		}
		
		private function createBody(wid:Number, ht:Number, location:Point, fric:Number, resti:Number, density:Number):b2Body 
		{
			// create body def
			var ropeBodyDef:b2BodyDef = new b2BodyDef();
			ropeBodyDef.position.Set(location.x, location.y);
			ropeBodyDef.type = b2Body.b2_dynamicBody;
			
			// create body
			var ropeBody:b2Body = PhysicsWorld.world.CreateBody(ropeBodyDef);
			
			// create shape
			var wallShape:b2PolygonShape = new b2PolygonShape();
			wallShape.SetAsBox((wid) / 2 , (ht) / 2);
			
			// create fixture def
			var wallFixtureDef:b2FixtureDef = new b2FixtureDef();
			wallFixtureDef.shape = wallShape;
			wallFixtureDef.density = density;
			wallFixtureDef.friction = fric;
			wallFixtureDef.restitution = resti;
			
			ropeBody.CreateFixture(wallFixtureDef);
			
			return ropeBody;
		}

	}

}
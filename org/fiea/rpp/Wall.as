package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Wall 
	{
		private var wall:b2Body;
		
		// x, y are top-left coordinates
		public function Wall(x:Number, y:Number, wid:Number, ht:Number) 
		{
			wall = this.createBody(x, y, wid, ht);
		}
		
		private function createBody(x:Number, y:Number, wid:Number, ht:Number):b2Body 
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_staticBody;
			bodyDef.position = new b2Vec2((x + wid / 2) / PhysicsWorld.RATIO, (y + ht / 2) / PhysicsWorld.RATIO);
			
			var bodyShape:b2PolygonShape = new b2PolygonShape();
			bodyShape.SetAsBox(wid / 2 / PhysicsWorld.RATIO, ht / 2 / PhysicsWorld.RATIO);
			
			var bodyFixture:b2FixtureDef = new b2FixtureDef();
			bodyFixture.shape = bodyShape;
			bodyFixture.friction = 1;
			bodyFixture.restitution = 1;
			bodyFixture.density = 10;
			
			var body:b2Body = PhysicsWorld.world.CreateBody(bodyDef);
			body.CreateFixture(bodyFixture);
			return body;
		}
		
	}

}
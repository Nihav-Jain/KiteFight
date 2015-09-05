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
	public class Knife 
	{
		public var body:b2Body;
		
		public function Knife(position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number) 
		{
			this.body = this.createKnifeBody(position, vertices, friction, restitution, density);
		}

		
		private function createKnifeBody(position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number):b2Body 
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position = position.Copy();
			//bodyDef.linearDamping = 1;
			bodyDef.angularDamping = 1;
			
			var bodyShape:b2PolygonShape = new b2PolygonShape();
			bodyShape.SetAsVector(vertices, vertices.length);
			
			var bodyFixture:b2FixtureDef = new b2FixtureDef();
			bodyFixture.shape = bodyShape;
			bodyFixture.friction = friction;
			bodyFixture.restitution = restitution;
			bodyFixture.density = density;
			
			var body:b2Body = PhysicsWorld.world.CreateBody(bodyDef);
			body.CreateFixture(bodyFixture);
			body.SetUserData(this);
			
			return body;
		}

	}

}
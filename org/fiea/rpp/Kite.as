package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Kite 
	{
		private var id:uint;
		
		public function Kite(playerid:uint, xml:XML) 
		{
			Console.log("hello");
			this.id = playerid;
			
			var position:b2Vec2 = new b2Vec2(parseFloat(xml.position.@x) / PhysicsWorld.RATIO, parseFloat(xml.position.@y) / PhysicsWorld.RATIO);
			Console.log(xml.vertices.length);
			//var vertices:Vector.<b2Vec2>(
		}
		
		private function createBody(position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position = position.Copy();
			
			var bodyShape:b2PolygonShape = new b2PolygonShape();
			bodyShape.SetAsVector(vertices, vertices.length);
			
			var bodyFixture:b2FixtureDef = new b2FixtureDef();
			bodyFixture.shape = bodyShape;
			bodyFixture.friction = friction;
			bodyFixture.restitution = restitution;
			bodyFixture.density = density;
			
			var body:b2Body = PhysicsWorld.world.CreateBody(bodyDef);
			body.CreateFixture(bodyFixture);
			body.ResetMassData();
			
			return body;
		}
		
		public function update():void
		{
			var inputMgr:InputManager = InputManager.getInstance();
			if (inputMgr.getPlayerKeyStatus(id, "left"))
			{
				Console.log(id, "left");
			}
			if (inputMgr.getPlayerKeyStatus(id, "right"))
			{
				Console.log(id, "right");
			}
			if (inputMgr.getPlayerKeyStatus(id, "up"))
			{
				Console.log(id, "up");
			}
			if (inputMgr.getPlayerKeyStatus(id, "down"))
			{
				Console.log(id, "down");
			}
			
		}
		
	}

}
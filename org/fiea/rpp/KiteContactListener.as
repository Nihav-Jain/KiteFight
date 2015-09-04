package org.fiea.rpp 
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import org.fiea.rpp.utils.Console;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class KiteContactListener extends b2ContactListener 
	{
		
		public function KiteContactListener() 
		{
			
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);
			
			var bodyA:b2Body;
			var bodyB:b2Body;
			
			if (contact.GetFixtureA().GetBody().GetUserData() is Kite)
			{
				bodyA = contact.GetFixtureA().GetBody();
				bodyB = contact.GetFixtureB().GetBody();
			}
			else if (contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				bodyA = contact.GetFixtureB().GetBody();
				bodyB = contact.GetFixtureA().GetBody();				
			}
			else
				return;
			
			var collisionPoints:Vector.<b2Vec2> = worldManifold.m_points;
			if (collisionPoints.length >= 1)
			{
				var restitutionVector:b2Vec2 = new b2Vec2(bodyA.GetPosition().x - collisionPoints[0].x, bodyA.GetPosition().y - collisionPoints[0].y);
				restitutionVector.Multiply(300)
				bodyA.ApplyImpulse(restitutionVector, bodyA.GetPosition());
				bodyA.SetAngularVelocity(0);
				if (bodyB.GetUserData() is Kite)
				{
					restitutionVector.x = bodyB.GetPosition().x - collisionPoints[0].x;
					restitutionVector.y = bodyB.GetPosition().x - collisionPoints[0].y;
					restitutionVector.Multiply(300);
					bodyB.ApplyImpulse(restitutionVector, bodyB.GetPosition());
					bodyB.SetAngularVelocity(0);
				}
			}
			Console.log("begin contact");
			super.BeginContact(contact);
		}
		
		override public function EndContact(contact:b2Contact):void 
		{
			var bodyA:b2Body;
			var bodyB:b2Body;
			
			if (contact.GetFixtureA().GetBody().GetUserData() is Kite && contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				bodyA = contact.GetFixtureA().GetBody();
				bodyB = contact.GetFixtureB().GetBody();
			}
			else
				return;
			Console.log("end contact");
			super.EndContact(contact);
		}
		
	}

}
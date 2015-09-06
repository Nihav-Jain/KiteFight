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
		private var worldManifold:b2WorldManifold;
		public function KiteContactListener() 
		{
			worldManifold = new b2WorldManifold();
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			var bodyA:b2Body;
			var bodyB:b2Body;
			var kite:Kite;
			var knife:Knife;
			if (contact.GetFixtureA().GetBody().GetUserData() is Knife && contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				bodyA = contact.GetFixtureA().GetBody();
				bodyB = contact.GetFixtureB().GetBody();
				knife = bodyA.GetUserData() as Knife;
				kite = bodyB.GetUserData() as Kite;
				if (knife.playerid == kite.id)
					return;
			}
			else if (contact.GetFixtureA().GetBody().GetUserData() is Kite && contact.GetFixtureB().GetBody().GetUserData() is Knife)
			{
				bodyA = contact.GetFixtureB().GetBody();
				bodyB = contact.GetFixtureA().GetBody();
				knife = bodyB.GetUserData() as Knife;
				kite = bodyA.GetUserData() as Kite;
				if (knife == null || kite == null || knife.playerid == kite.id)
					return;
			}
			else
				return;
			Console.log("begin contact");
			contact.GetWorldManifold(worldManifold);
			var contactPoints:Vector.<b2Vec2> = worldManifold.m_points;
			var normal:b2Vec2 = worldManifold.m_normal;
			var knifeVelMinusNormal:b2Vec2 = bodyA.GetLinearVelocity().Copy();
			knifeVelMinusNormal.Subtract(normal);
			var knifeVelLength:Number = bodyA.GetLinearVelocity().Length();
			var normalLength:Number = normal.Length();
			var knifeVelMinusNormalLength:Number = knifeVelMinusNormal.Length();

			// cos rule
			var cosTheta:Number = (knifeVelLength * knifeVelLength + normalLength * normalLength - knifeVelMinusNormalLength * knifeVelMinusNormalLength) / (2 * knifeVelLength * normalLength);
			var knifeVelocity:b2Vec2 = bodyA.GetLinearVelocity().Copy();
			knifeVelocity.Multiply(cosTheta);
			normal.Multiply(cosTheta);
			knifeVelocity.Add(normal)
			Console.log(knifeVelocity.Length());	// attack points
			super.BeginContact(contact);
		}
		
	}

}
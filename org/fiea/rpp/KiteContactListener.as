package org.fiea.rpp 
{
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
			var bodyA:b2Body;
			var bodyB:b2Body;
			
			if (contact.GetFixtureA().GetBody().GetUserData() is Kite && contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				bodyA = contact.GetFixtureA().GetBody();
				bodyB = contact.GetFixtureB().GetBody();
			}
			else
				return;
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
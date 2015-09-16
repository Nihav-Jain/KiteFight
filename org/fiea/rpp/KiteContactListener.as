package org.fiea.rpp 
{
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import org.fiea.rpp.utils.Console;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nihav Jain, Brian Bennett
	 */
	public class KiteContactListener extends b2ContactListener 
	{
		public var eventDispatcher:EventDispatcher;
		public static const KITE_0_HIT:String = "kite0Hit";
		public static const KITE_1_HIT:String = "kite1Hit";
		public static const HIT_JUST_HAPPENED:String = "HitJustHappened";
		private var _worldManifold:b2WorldManifold;
		private var _bodyA:b2Body;
		private var _bodyB:b2Body;
		
		public function KiteContactListener() 
		{
			eventDispatcher = new EventDispatcher();
			_worldManifold = new b2WorldManifold();
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			//var bodyA:b2Body;
			//var bodyB:b2Body;
		
			contact.GetWorldManifold(_worldManifold);			
			if (contact.GetFixtureA().GetBody().GetUserData() is Kite && contact.GetFixtureB().GetBody().GetUserData() is Knife)
			{
				if (contact.GetFixtureA().GetBody().GetUserData().id != contact.GetFixtureB().GetBody().GetUserData().id)
				{
					//bodyA = contact.GetFixtureA().GetBody();
					//bodyB = contact.GetFixtureB().GetBody();
					if (contact.GetFixtureA().GetBody().GetUserData().id == 0)
					{
						_bodyA = contact.GetFixtureA().GetBody();
						_bodyB = contact.GetFixtureB().GetBody();
						eventDispatcher.dispatchEvent(new Event(KITE_0_HIT));
						//Console.log("kite 0 hit");
					}
					else
					{
						_bodyA = contact.GetFixtureB().GetBody();
						_bodyB = contact.GetFixtureA().GetBody();
						eventDispatcher.dispatchEvent(new Event(KITE_1_HIT));
						//Console.log("kite 1 hit");
					}
				}
			}
			if (contact.GetFixtureA().GetBody().GetUserData() is Knife && contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				if (contact.GetFixtureA().GetBody().GetUserData().id != contact.GetFixtureB().GetBody().GetUserData().id)
				{
					//bodyA = contact.GetFixtureA().GetBody();
					//bodyB = contact.GetFixtureB().GetBody();
					if (contact.GetFixtureB().GetBody().GetUserData().id == 0)
					{
						_bodyA = contact.GetFixtureB().GetBody();
						_bodyB = contact.GetFixtureA().GetBody();
						eventDispatcher.dispatchEvent(new Event(KITE_0_HIT));
						//Console.log("kite 0 hit");
					}
					else
					{
						_bodyA = contact.GetFixtureA().GetBody();
						_bodyB = contact.GetFixtureB().GetBody();
						eventDispatcher.dispatchEvent(new Event(KITE_1_HIT));
						//Console.log("kite 1 hit");
					}
				}
			}
			//super.BeginContact(contact);
		}
		
		override public function EndContact(contact:b2Contact):void 
		{
			var bodyA:b2Body;
			var bodyB:b2Body;
			
			if (contact.GetFixtureA().GetBody().GetUserData() is Kite && contact.GetFixtureB().GetBody().GetUserData() is Knife)
			{
				if (contact.GetFixtureA().GetBody().GetUserData().id != contact.GetFixtureB().GetBody().GetUserData().id)
				{
					eventDispatcher.dispatchEvent(new Event(HIT_JUST_HAPPENED));
					//bodyB = contact.GetFixtureB().GetBody();
					//Console.log("end contact");
				}
			}
			if (contact.GetFixtureA().GetBody().GetUserData() is Knife && contact.GetFixtureB().GetBody().GetUserData() is Kite)
			{
				if (contact.GetFixtureA().GetBody().GetUserData().id != contact.GetFixtureB().GetBody().GetUserData().id)
				{
					eventDispatcher.dispatchEvent(new Event(HIT_JUST_HAPPENED));
					//bodyB = contact.GetFixtureB().GetBody();
					//Console.log("end contact");
				}
			}

			
			//super.EndContact(contact);
		}
		
		public function get worldManifold():b2WorldManifold 
		{
			return _worldManifold;
		}
		
		public function get bodyB():b2Body 
		{
			return _bodyB;
		}
		
		public function get bodyA():b2Body 
		{
			return _bodyA;
		}
		
	}

}
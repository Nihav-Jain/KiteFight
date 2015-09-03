package  
{
	import Box2D.Dynamics.b2World;
	/**
	 * ...
	 * @author Nihav Jain
	 * @class PhysicsWorld
	 */
	public class PhysicsWorld 
	{
		public static const RATIO:Number = 40;
		private static var _world:b2World;
		
		public function PhysicsWorld() 
		{
			
		}
		
		static public function get world():b2World 
		{
			return _world;
		}
		
		static public function set world(value:b2World):void 
		{
			_world = value;
		}
		
	}

}
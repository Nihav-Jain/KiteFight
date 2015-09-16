package org.fiea.rpp 
{
	import Box2D.Dynamics.b2Body;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Box2DActor 
	{
		protected var _body:b2Body;
		protected var _skin:Sprite;
		
		public static const RadToDeg:Number = 180 / Math.PI;
		
		public function Box2DActor(body:b2Body, skin:Sprite) 
		{
			this._body = body;
			this._skin = skin;
		}
		
		protected function update():void
		{
			skin.x = body.GetPosition().x * PhysicsWorld.RATIO;
			skin.y = body.GetPosition().y * PhysicsWorld.RATIO;
			skin.rotation = body.GetAngle() * RadToDeg;
		}
		
		public function updateNow():void
		{
			this.update();
		}
		
		protected function destroy():void
		{
			// override and remnove any event listeners or other objects to be destroyed
			PhysicsWorld.world.DestroyBody(this.body);
		}
		
		public function destroyNow():void
		{
			this.destroy();
		}
		
		public function get body():b2Body 
		{
			return _body;
		}
		
		public function get skin():Sprite 
		{
			return _skin;
		}
		
	}

}
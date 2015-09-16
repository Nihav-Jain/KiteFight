package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Nihav Jain, Brian Bennett
	 */
	public class Knife extends Box2DActor
	{
		public var id:uint;
		
		public function Knife(ID:uint, position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number, parent:DisplayObjectContainer, weaponSprite:Sprite=null) 
		{
			var body:b2Body = this.createKnifeBody(position, vertices, friction, restitution, density);
			var skin:Sprite;
			if (weaponSprite == null)
				skin = this.createSprite(vertices);
			else
				skin = weaponSprite;//this.createSprite(vertices);
			super(body, skin);
			id = ID;
			parent.addChild(skin);
		}
		
		private function createSprite(vertices:Vector.<b2Vec2>):Sprite
		{
			var knifeSprite:Sprite = new Sprite();
			knifeSprite.graphics.beginFill(0x444444, 1);
			knifeSprite.graphics.moveTo(vertices[0].x * PhysicsWorld.RATIO, vertices[0].y * PhysicsWorld.RATIO);
			for (var i:int = 1; i < vertices.length; i++)
			{
				knifeSprite.graphics.lineTo(vertices[i].x * PhysicsWorld.RATIO, vertices[i].y * PhysicsWorld.RATIO);
			}
			knifeSprite.graphics.endFill();
			
			//knifeSprite.x = location.x * PhysicsWorld.RATIO + knifeSprite.width/2;
			//knifeSprite.y = location.y * PhysicsWorld.RATIO + knifeSprite.height/2;
			//
			return knifeSprite;
			
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
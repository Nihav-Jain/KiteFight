package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Kite
	{
		private var id:uint;
		public var body:b2Body;
		private var skin:Sprite;
		
		private var maxAngle:Number;
		private var angleStep:Number;
		private var maxVelocity:Number;
		
		private var pivot:b2Vec2;
		private var mouseJoint:b2MouseJoint;
		
		private static const Pi_180:Number = Math.PI / 180;
		private static const Pi_2:Number = Math.PI / 2;
		
		public function Kite(playerid:uint, xml:XML, parent:DisplayObjectContainer) 
		{
			this.id = playerid;
			Console.log(xml.position.@x);
			var position:b2Vec2 = new b2Vec2(parseFloat(xml.position.@x) / PhysicsWorld.RATIO, parseFloat(xml.position.@y) / PhysicsWorld.RATIO);
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>(xml.vertices.children().length(), true);
			var i:uint;
			for each(var vertex in xml.vertices.vertex)
			{
				vertices[i] = new b2Vec2(parseFloat(vertex.@x) / PhysicsWorld.RATIO, parseFloat(vertex.@y) / PhysicsWorld.RATIO);
				i++;
			}
			var friction:Number = parseFloat(xml.physicalProperties.friction);
			var restitution:Number = parseFloat(xml.physicalProperties.restitution);
			var density:Number = parseFloat(xml.physicalProperties.density);
			this.body = this.createBody(position, vertices, friction, restitution, density);
			this.maxVelocity = parseFloat(xml.movement.maxvelocity);
			this.maxAngle = parseFloat(xml.movement.maxAngle) * Pi_180;
			this.angleStep = 6 * Pi_180;
			
			//this.pivot = new b2Vec2((this.body.GetPosition().x - vertices[0].x) / 2, (this.body.GetPosition().y - vertices[0].y) / 2);
			this.pivot = this.body.GetLocalCenter().Copy();
			this.pivot.x = (vertices[0].x - this.pivot.x) / 2;
			this.pivot.y = (vertices[0].y - this.pivot.y) / 2;
			this.pivot.Add(this.body.GetWorldCenter());

			var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
			mouseJointDef.bodyA = PhysicsWorld.world.GetGroundBody();
			mouseJointDef.bodyB = this.body;
			mouseJointDef.target.Set(pivot.x, pivot.y);
			mouseJointDef.dampingRatio = 0.5;
			mouseJointDef.collideConnected = true;
			mouseJointDef.maxForce = 300 * this.body.GetMass();
			mouseJoint = PhysicsWorld.world.CreateJoint(mouseJointDef) as b2MouseJoint;
			
			this.skin = new Sprite();
			parent.addChild(skin);
		}
		
		private function createBody(position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number):b2Body
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
		
		public function update():void
		{
			//this.killOrthogonalVelocity();
			var newVelocity:b2Vec2 = new b2Vec2(0, 0);
			var newAngle:Number;
			var inputMgr:InputManager = InputManager.getInstance();
			if (inputMgr.getPlayerKeyStatus(id, "left"))
			{
				newAngle = this.body.GetAngle() - this.angleStep;
				//if (newAngle >= -this.maxAngle)
					//this.body.SetAngle(newAngle);
				this.pivot.x -= 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(id, "right"))
			{
				newAngle = this.body.GetAngle() + this.angleStep;
				//if (newAngle <= this.maxAngle)
					//this.body.SetAngle(newAngle);
				this.pivot.x += 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(id, "up"))
			{
				Console.log(id, "up");
				//this.body.SetPosition(new b2Vec2(this.body.GetPosition().x, this.body.GetPosition().y - 0.1));
				this.pivot.y -= 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(id, "down"))
			{
				Console.log(id, "down");
				//this.body.SetPosition(new b2Vec2(this.body.GetPosition().x, this.body.GetPosition().y + 0.1));
				this.pivot.y += 0.2;
			}
/*			var direction:b2Vec2 = this.body.GetWorldCenter().Copy();
			direction.Add(new b2Vec2(60 * Math.cos(this.body.GetAngle() - Pi_2) / PhysicsWorld.RATIO, 60 * Math.sin(this.body.GetAngle() - Pi_2) / PhysicsWorld.RATIO));
			var directionAngle:Number = Math.atan(direction.y / direction.x);
*/			
			this.skin.graphics.clear();
			this.skin.graphics.beginFill(0xFF00FF, 1);
			this.skin.graphics.drawCircle(pivot.x * PhysicsWorld.RATIO, pivot.y * PhysicsWorld.RATIO, 4);
			this.skin.graphics.endFill();
			
/*			if (!mouseJoint)
				PhysicsWorld.world.DestroyJoint(mouseJoint);
			mouseJoint = PhysicsWorld.world.CreateJoint(mouseJointDef) as b2MouseJoint;
*/			
			mouseJoint.SetTarget(pivot);
			body.SetAwake(true);

/*			direction.Subtract(this.body.GetWorldCenter());
			direction.Normalize();
			//var normal:b2Vec2 = new b2Vec2(- direction.y * Math.sin(Pi_2), direction.x);
			//this.body.ApplyForce(normal, this.body.GetPosition());
			direction.Multiply(4);
			//this.body.SetAwake(true);
			//this.body.SetLinearVelocity(direction);
			this.body.ApplyForce(direction, this.body.GetPosition());*/
		}
		
		private function killOrthogonalVelocity():void
		{
			var localPoint:b2Vec2 = new b2Vec2(0, 0);
			var velocity:b2Vec2 = this.body.GetLinearVelocityFromLocalPoint(localPoint);
			
			var sidewaysAxis:b2Vec2 = this.body.GetTransform().R.col2.Copy();
			sidewaysAxis.Multiply(sidewaysAxis.Length() * velocity.Length());
			this.body.SetLinearVelocity(sidewaysAxis);
		}
		
	}

}
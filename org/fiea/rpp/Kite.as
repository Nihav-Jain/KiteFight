package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RopeJoint;
	import Box2D.Dynamics.Joints.b2RopeJointDef;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Kite
	{
		private var _id:uint;
		public var body:b2Body;
		public var skin:Sprite;
		
		private var maxAngle:Number;
		private var angleStep:Number;
		private var maxVelocity:Number;
		
		private var pivot:b2Vec2;
		private var visualPivot:Point;
		private var visualKitePivot:b2Vec2;
		private var mouseJoint:b2MouseJoint;
		
		private var knife:Knife;
		private var ropeLinkLength:Number;
		private var nextRopeLink:b2Body;
		private var rope:Vector.<RopeLink>;
		
		private static const Pi_180:Number = Math.PI / 180;
		private static const Pi_2:Number = Math.PI / 2;
		
		public function Kite(playerid:uint, xml:XML, parent:DisplayObjectContainer) 
		{
			this._id = playerid;
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
			visualKitePivot = this.pivot.Copy();
			
			this.nextRopeLink = this.body;
			this.ropeLinkLength = parseFloat(xml.rope.@linkLength);
			this.setupRope(parseInt(xml.rope.@links), ropeLinkLength, parseFloat(xml.rope.@linkWidth), vertices[2]);
			
			position.x = this.nextRopeLink.GetPosition().x;
			position.y = this.nextRopeLink.GetPosition().y + ropeLinkLength;
			var knifeVertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each(var knifevertex in xml.knife.vertex)
			{
				knifeVertices.push(new b2Vec2(parseFloat(knifevertex.@x) / PhysicsWorld.RATIO, parseFloat(knifevertex.@y) / PhysicsWorld.RATIO));
			}
			friction = parseFloat(xml.knife.physicalProperties.friction);
			restitution = parseFloat(xml.knife.physicalProperties.restitution);
			density = parseFloat(xml.knife.physicalProperties.density);
			this.knife = new Knife(_id, position, knifeVertices, friction, restitution, density);
			this.createRevoluteJoint(this.nextRopeLink, this.knife.body, new b2Vec2(0, ropeLinkLength / 2), new b2Vec2(0, 0));
			
			mouseJoint = this.createMouseJoint();
			
			visualPivot = new Point(parseFloat(xml.pivot.@x), parseFloat(xml.pivot.@y));
			this.skin = new Sprite();	// TODO
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
			var newVelocity:b2Vec2 = new b2Vec2(0, 0);
			var newAngle:Number;
			var inputMgr:InputManager = InputManager.getInstance();
			if (inputMgr.getPlayerKeyStatus(_id, "left"))
			{
				newAngle = this.body.GetAngle() - this.angleStep;
				//if (newAngle >= -this.maxAngle)
					//this.body.SetAngle(newAngle);
				this.pivot.x -= 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(_id, "right"))
			{
				newAngle = this.body.GetAngle() + this.angleStep;
				//if (newAngle <= this.maxAngle)
					//this.body.SetAngle(newAngle);
				this.pivot.x += 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(_id, "up"))
			{
				Console.log(_id, "up");
				this.pivot.y -= 0.2;
			}
			if (inputMgr.getPlayerKeyStatus(_id, "down"))
			{
				Console.log(_id, "down");
				this.pivot.y += 0.2;
			}
			mouseJoint.SetTarget(pivot);
			//body.SetAwake(true);
			
/*			this.skin.graphics.clear();
			this.skin.graphics.lineStyle(1, 0x000000, 1);
			this.skin.graphics.moveTo(this.visualPivot.x, this.visualPivot.y);
			this.skin.graphics.lineTo(this.body.GetPosition().x * PhysicsWorld.RATIO, this.body.GetPosition().y * PhysicsWorld.RATIO);
			this.skin.graphics.endFill();*/
		}
		
		private function setupRope(numLinks:int, linkLength:Number, linkWidth:Number, vertex:b2Vec2):void 
		{
			this.rope = new Vector.<RopeLink>(numLinks, true);
			for (var i:int = 0; i < numLinks; i++)
			{
				var newY:Number = this.nextRopeLink.GetPosition().y + linkLength;
					
				this.rope[i] = new RopeLink(this.skin, linkWidth, linkLength, new Point(this.body.GetPosition().x, newY), 0.5, 0.3, 10);
				if (i==0) {
					this.createRevoluteJoint(this.nextRopeLink, this.rope[i].body, vertex, new b2Vec2(0, -linkLength / 2));
				}
				else {
					this.createRevoluteJoint(this.nextRopeLink, this.rope[i].body, new b2Vec2(0, linkLength / 2), new b2Vec2(0, -linkLength / 2));
				}
				this.nextRopeLink = this.rope[i].body;
			}
		}
		
		
		private function createMouseJoint():b2MouseJoint
		{
			var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
			mouseJointDef.bodyA = PhysicsWorld.world.GetGroundBody();
			mouseJointDef.bodyB = this.body;
			mouseJointDef.target.Set(pivot.x, pivot.y);
			mouseJointDef.dampingRatio = 1;
			mouseJointDef.collideConnected = true;
			mouseJointDef.maxForce = 300 * this.body.GetMass();
			return PhysicsWorld.world.CreateJoint(mouseJointDef) as b2MouseJoint;
		}

		private function createRevoluteJoint(bodyA:b2Body, bodyB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2, enableLimit:Boolean=false, lowerLimit:Number=0.0, higherLimit:Number=0.0):void 
		{
			var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA.Set(anchorA.x, anchorA.y);
			revoluteJointDef.localAnchorB.Set(anchorB.x, anchorB.y);
			revoluteJointDef.bodyA = bodyA;
			revoluteJointDef.bodyB = bodyB;
			revoluteJointDef.enableLimit = enableLimit;
			if (enableLimit)
			{
				revoluteJointDef.lowerAngle = lowerLimit;
				revoluteJointDef.upperAngle = higherLimit;
			}
			PhysicsWorld.world.CreateJoint(revoluteJointDef);
		}
		
		public function get id():uint 
		{
			return _id;
		}
		
	}

}
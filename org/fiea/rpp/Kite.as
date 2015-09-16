package org.fiea.rpp 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RopeJoint;
	import Box2D.Dynamics.Joints.b2RopeJointDef;
	import com.greensock.easing.Circ;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	import org.fiea.rpp.utils.SoundManager;
	import com.greensock.*;
	/**
	 * ...
	 * @author Nihav Jain, Brian Bennett
	 */
	public class Kite extends Box2DActor
	{
		private var container:Sprite;
		public var id:uint;
		private var kiteSprite:Sprite;	// for changing the registration point of the bitmap
		private var characterSprite:Sprite;
		private var characterSpriteContainer:Sprite;
		private var characterPosition:Number;
		private var parentSprite:Sprite;
		private var health:Number;
		
		private var maxAngle:Number;
		private var angleStep:Number;
		private var maxVelocity:Number;
		
		public var pivot:b2Vec2;
		private var visualPivot:Point;
		private var visualPivotCopy:Point;
		private var visualKitePivot:b2Vec2;
		private var mouseJoint:b2MouseJoint;
		
		public var knife:Knife;
		private var ropeLinkLength:Number;
		private var nextRopeLink:b2Body;
		private var rope:Vector.<RopeLink>;
		private var revoluteJoints:Vector.<b2RevoluteJoint>;
		
		private var healthBar:HealthBar;
		
		private var inputEnable:Boolean = true;
		private var LostSprite:Sprite;
		private var VictorySprite:Sprite;
		
		private static const Pi_180:Number = Math.PI / 180;
		private static const Pi_2:Number = Math.PI / 2;
		//public static const RadToDeg:Number = 180 / Math.PI;
		
		public function Kite(playerid:uint, xml:XML, parent:DisplayObjectContainer, kiteSprite:Sprite, characterSprite:Sprite, weaponXml:XML, weaponSprite:Sprite) 
		{
			container = new Sprite();
			this.id = playerid;
			this.health = 100;
			var position:b2Vec2 = new b2Vec2(parseFloat(xml.kite.position.@x) / PhysicsWorld.RATIO, parseFloat(xml.kite.position.@y) / PhysicsWorld.RATIO);
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			var i:uint = 0;
			for each(var vertex in xml.kite.vertices.vertex)
			{
				vertices[i] = new b2Vec2(parseFloat(vertex.@x) / PhysicsWorld.RATIO, parseFloat(vertex.@y) / PhysicsWorld.RATIO);
				i++;
			}
			var friction:Number = parseFloat(xml.kite.physicalProperties.friction);
			var restitution:Number = parseFloat(xml.kite.physicalProperties.restitution);
			var density:Number = parseFloat(xml.kite.physicalProperties.density);
			var body:b2Body = this.createBody(position, vertices, friction, restitution, density);

			var skin:Sprite = new Sprite();
			this.kiteSprite = kiteSprite;
			this.characterSprite = characterSprite;
			this.parentSprite = parent as Sprite;
			this.characterPosition = parseFloat(xml.characterPosition.@x);

			//this.pivot = new b2Vec2((this.body.GetPosition().x - vertices[0].x) / 2, (this.body.GetPosition().y - vertices[0].y) / 2);
			this.pivot = body.GetLocalCenter().Copy();
			this.pivot.x = (vertices[0].x - this.pivot.x) / 2;
			this.pivot.y = (vertices[0].y - this.pivot.y) / 2;			
			this.pivot.Add(body.GetWorldCenter());
			visualKitePivot = this.pivot.Copy();
			
			visualPivot = new Point(parseFloat(xml.pivot.@x), parseFloat(xml.pivot.@y));
			visualPivotCopy = visualPivot.clone();
			characterSprite.x = characterPosition;
			characterSprite.y = KiteFight.STAGE.stageHeight - characterSprite.height / 2;
			this.container.addChild(characterSprite);
			visualPivot.y = characterSprite.y - characterSprite.height / 2 + visualPivotCopy.y;
			
			this.kiteSprite.x = 0;
			this.kiteSprite.y = -kiteSprite.height / 4;
			skin.addChild(this.kiteSprite);
			this.container.addChild(skin);
			
			this.parentSprite.addChild(container);
			super(body, skin);
			
			this.revoluteJoints = new Vector.<b2RevoluteJoint>();
			this.nextRopeLink = body;
			this.ropeLinkLength = parseFloat(weaponXml.rope.@linkLength);
			this.setupRope(parseInt(weaponXml.rope.@links), ropeLinkLength, parseFloat(weaponXml.rope.@linkWidth), vertices[2]);
			
			position.x = this.nextRopeLink.GetPosition().x;
			position.y = this.nextRopeLink.GetPosition().y + ropeLinkLength;
			var knifeVertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each(var knifevertex in weaponXml.vertices.vertex)
			{
				knifeVertices.push(new b2Vec2(parseFloat(knifevertex.@x) / PhysicsWorld.RATIO, parseFloat(knifevertex.@y) / PhysicsWorld.RATIO));
			}
			friction = parseFloat(weaponXml.physicalProperties.friction);
			restitution = parseFloat(weaponXml.physicalProperties.restitution);
			density = parseFloat(weaponXml.physicalProperties.density);
			this.knife = new Knife(this.id, position, knifeVertices, friction, restitution, density, container, weaponSprite);
			this.createRevoluteJoint(this.nextRopeLink, this.knife.body, new b2Vec2(0, ropeLinkLength / 2), new b2Vec2(0, 0));
			
			mouseJoint = this.createMouseJoint();
			
			this.healthBar = new HealthBar(parseFloat(xml.healthbar.@barx), parseFloat(xml.healthbar.@bary), parseFloat(xml.healthbar.@wid), parseFloat(xml.healthbar.@ht), playerid);
			this.healthBar.x = parseFloat(xml.healthbar.@x);// + healthBar.width / 2;
			this.healthBar.y = parseFloat(xml.healthbar.@y);// + healthBar.height / 2;
			this.container.addChild(healthBar);
		}
		
		private function createBody(position:b2Vec2, vertices:Vector.<b2Vec2>, friction:Number, restitution:Number, density:Number):b2Body
		{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position = position.Copy();
			//bodyDef.linearDamping = 1;
			bodyDef.angularDamping = 20;
			
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

		override protected function update():void 
		{
			super.update();
			var newRotation:Number = 30 - skin.y * 60 / KiteFight.STAGE.stageHeight;
			//Character(characterSprite).rotateawArm(newRotation);
			if (skin.x < characterSprite.x)
			{
				characterSprite.rotationY = 0;
				visualPivot.x = characterSprite.x - characterSprite.width / 2 + visualPivotCopy.x;//characterSprite.x + Character(characterSprite).armX + 115 * Math.cos(newRotation);//characterSprite.x - characterSprite.width / 2 + visualPivotCopy.x;
				//visualPivot.y = characterSprite.y - Character(characterSprite).armY - 115 * Math.sin(newRotation);
			}
			else if (skin.x > characterSprite.x)
			{				
				characterSprite.rotationY = 180;
				visualPivot.x = characterSprite.x + characterSprite.width / 2 - visualPivotCopy.x;//characterSprite.x + Character(characterSprite).armX - 115 * Math.cos(newRotation); //characterSprite.x + characterSprite.width / 2 - visualPivotCopy.x;
				//visualPivot.y = characterSprite.y - Character(characterSprite).armY - 115 * Math.sin(newRotation);
			}
			
			this.container.graphics.clear();
			this.container.graphics.lineStyle(1, 0x000000);
			this.container.graphics.moveTo(visualPivot.x, visualPivot.y);
			this.container.graphics.lineTo(skin.x, skin.y);
			
			for each(var link:RopeLink in rope)
			{
				link.updateNow();
			}
			knife.updateNow();
			
			
			var newVelocity:b2Vec2 = new b2Vec2(0, 0);
			var newAngle:Number;
			var inputMgr:InputManager = InputManager.getInstance();
			// TODO: optimise and put dependency on wall coorinates and dimensions
			if (inputEnable)
			{
				var moveFactor:Number = 0.2;
				var moved:Boolean = false;
				if (inputMgr.getPlayerKeyStatus(id, "left"))
				{
					this.pivot.x -= moveFactor;
					if (this.pivot.x < 0)
						this.pivot.x += moveFactor;
					moved = true;
				}
				if (inputMgr.getPlayerKeyStatus(id, "right"))
				{
					this.pivot.x += moveFactor;
					if (this.pivot.x > KiteFight.STAGE.stageWidth / PhysicsWorld.RATIO)
						this.pivot.x -= moveFactor;
					moved = true;
				}
				if (inputMgr.getPlayerKeyStatus(id, "up"))
				{
					this.pivot.y -= moveFactor;
					if (this.pivot.y < 0)
						this.pivot.y += moveFactor;
					moved = true;
				}
				if (inputMgr.getPlayerKeyStatus(id, "down"))
				{
					this.pivot.y += moveFactor;
					if (this.pivot.y > KiteFight.STAGE.stageHeight / PhysicsWorld.RATIO)
						this.pivot.y -= moveFactor;
					moved = true;
				}
				// TODO: check for min magnitude of velocity instead of 0
				if (!moved && this.body.GetLinearVelocity().x == 0 && this.body.GetLinearVelocity().y == 0)
				{
					var randomDirection:int = Math.floor(Math.random() * 2);
					switch(randomDirection)
					{
						case 0: 
							this.pivot.x -= moveFactor;
							if (this.pivot.x < 0)
								this.pivot.x += moveFactor;
							break;
						case 1: 
							this.pivot.x += moveFactor;
							if (this.pivot.x > KiteFight.STAGE.stageWidth / PhysicsWorld.RATIO)
								this.pivot.x -= moveFactor;
							break;
/*						case 2:
							this.pivot.y -= moveFactor;
							if (this.pivot.y < 0)
								this.pivot.y += moveFactor;
							break;
						case 3:
							this.pivot.y += moveFactor;
							if (this.pivot.y > KiteFight.STAGE.stageHeight / PhysicsWorld.RATIO)
								this.pivot.y -= moveFactor;
							break;
*/					}
					Console.log("random movement = " + randomDirection);
				}
			}
			mouseJoint.SetTarget(pivot);
		}

		private function setupRope(numLinks:int, linkLength:Number, linkWidth:Number, vertex:b2Vec2):void 
		{
			this.rope = new Vector.<RopeLink>(numLinks, true);
			for (var i:int = 0; i < numLinks; i++)
			{
				var newY:Number = this.nextRopeLink.GetPosition().y + linkLength;
					
				this.rope[i] = new RopeLink(container, linkWidth, linkLength, new Point(this.body.GetPosition().x, newY), 0.5, 0.3, 10);
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
			this.revoluteJoints.push(PhysicsWorld.world.CreateJoint(revoluteJointDef));
		}
		
		public function takeDamage(amount:Number):void 
		{
			health -= amount;
			if (health < 0)
			{
				health = 0;
			}
			this.healthBar.doDamage(amount);
		}
		
		public function getHealth():Number
		{
			return health;
		}
		
		public function StopInput():void
		{
			inputEnable = false;
		}
		
		public function die():void
		{
			/*while (this.pivot.y <= KiteFight.STAGE.stageHeight / PhysicsWorld.RATIO)
			{
				this.pivot.y += 0.000000000000000001;
			}*/
			
			LostSprite = new Sprite();
			LostSprite.y = this.pivot.y * PhysicsWorld.RATIO;

			TweenLite.to(LostSprite, 2, { y: KiteFight.STAGE.stageHeight, onUpdate: Lostprogress, ease: Circ.easeIn } );
			SoundManager.getInstance().Crashing();
			//SoundManager.getInstance().Pause("Crashing");
			//SoundManager.getInstance().PlayRandomCrashSound();
		}
		
		public function GoToCenter():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;
			
			TweenLite.to(VictorySprite, .5, { y: KiteFight.STAGE.stageHeight / 2, x:  KiteFight.STAGE.stageWidth / 4, onUpdate: Winprogress, ease: Circ.easeIn, onComplete: DanceBegin } );
			
			KiteFight.showWinSign(this.id);
		}
		
		public function GoToCenter2():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;
			
			TweenLite.to(VictorySprite, .5, { y: KiteFight.STAGE.stageHeight / 2, x:  KiteFight.STAGE.stageWidth*3 / 4, onUpdate: Winprogress, ease: Circ.easeIn, onComplete: DanceBegin } );
			
			KiteFight.showWinSign(this.id);
		}
		
		
		public function DanceBegin():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;
			
			TweenLite.to(VictorySprite, .5, { y: (this.pivot.y*PhysicsWorld.RATIO)-(5*PhysicsWorld.RATIO), onUpdate: Winprogress, onComplete: DanceRight} );
		}
		
		public function DanceDown():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;

			TweenLite.to(VictorySprite, .5, { y: (this.pivot.y*PhysicsWorld.RATIO)+(5*PhysicsWorld.RATIO), onUpdate: Winprogress, onComplete: DanceLeft} );
		}
		
		public function DanceLeft():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;

			TweenLite.to(VictorySprite, .5, { x: (this.pivot.x*PhysicsWorld.RATIO)-(5*PhysicsWorld.RATIO), onUpdate: Winprogress, onComplete: DanceBegin} );
		}
		
		public function DanceRight():void
		{
			VictorySprite = new Sprite();
			VictorySprite.y = this.pivot.y * PhysicsWorld.RATIO;
			VictorySprite.x = this.pivot.x * PhysicsWorld.RATIO;

			TweenLite.to(VictorySprite, .5, { x: (this.pivot.x*PhysicsWorld.RATIO)+(5*PhysicsWorld.RATIO), onUpdate: Winprogress, onComplete: DanceDown} );
		}
		
		private function Lostprogress():void
		{
				this.pivot.y = LostSprite.y / PhysicsWorld.RATIO;
		}
		
		private function Winprogress():void
		{
				this.pivot.x = VictorySprite.x / PhysicsWorld.RATIO;
				this.pivot.y = VictorySprite.y / PhysicsWorld.RATIO;
		}
		
		public function blurCharacter():void
		{
			TweenLite.killTweensOf(this.characterSprite);
			TweenLite.to(characterSprite, 0.5, {blurFilter: {blurX: 20, blurY: 20}});
		}
		
		public function unBlurCharacter():void
		{
			TweenLite.killTweensOf(this.characterSprite);
			TweenLite.to(characterSprite, 0.5, {blurFilter: {blurX: 0, blurY: 0}});
		}
		
		override protected function destroy():void 
		{
			for each(var revJoint:b2RevoluteJoint in this.revoluteJoints)
			{
				PhysicsWorld.world.DestroyJoint(revJoint);
			}
			PhysicsWorld.world.DestroyJoint(this.mouseJoint);
			for each(var link:RopeLink in rope)
			{
				link.destroyNow();
			}
			this.knife.destroyNow();
			super.destroy();
		}
	}

}
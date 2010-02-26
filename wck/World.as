﻿package wck {		import Box2DAS.*;	import Box2DAS.Collision.*;	import Box2DAS.Collision.Shapes.*;	import Box2DAS.Common.*;	import Box2DAS.Dynamics.*;	import Box2DAS.Dynamics.Contacts.*;	import Box2DAS.Dynamics.Joints.*;	import cmodule.Box2D.*;	import wck.*;	import gravity.*;	import misc.*;	import flash.utils.*;	import flash.events.*;	import flash.display.*;	import flash.text.*;	import flash.geom.*;	import flash.ui.*;		/**	 * Wraps b2World and provides inspectable properties that can be edited in Flash.	 */	public class World extends Scroller {				/// See the Box2d documentation for explanations of the variables below.				[Inspectable(defaultValue=60)]		public var scale:Number = 60;				[Inspectable(defaultValue=0.05)]		public var timeStep:Number = 0.05;				[Inspectable(defaultValue=15)]		public var velocityIterations:int = 10;				[Inspectable(defaultValue=15)]		public var positionIterations:int = 10;				[Inspectable(defaultValue=0)]		public var gravityX:Number = 0;				[Inspectable(defaultValue=10)]		public var gravityY:Number = 10;				[Inspectable(defaultValue=true)]		public var allowSleep:Boolean = true;				[Inspectable(defaultValue=true)]		public var allowDragging:Boolean = true;				/// When true timestep isn't called / dispatched.		[Inspectable(defaultValue=false)]		public var paused:Boolean = false;				/// Orient the world so that gravity is always up?		[Inspectable(defaultValue=false)]		public var orientToGravity:Boolean = false;				/// Show debug draw data.		[Inspectable(defaultValue=false)]		public var debugDraw:Boolean = false;				public var outsideTS:Array = [];		public var baseGravity:V2;		public var b2world:b2World;		public var customGravity:Gravity;		public var debug:b2DebugDraw;				/**		 * Construct the b2World.		 */		public override function create():void {			baseGravity = new V2(gravityX, gravityY);			b2world = new b2World(new V2(0, 0), allowSleep, this);			listenWhileVisible(stage, Event.ENTER_FRAME, step);			listenWhileVisible(this, StepEvent.STEP, applyGravityToWorld, false, 10);			super.create();			if(debugDraw) {				debug = new b2DebugDraw(b2world, scale);				debug.alpha = 0.5;				addChild(debug);			}		}				/**		 * Destroy the b2World.		 */		public override function destroy():void {			b2world.destroy();			b2world = null;		}				/**		 * Do the timestep!		 */		public function step(e:Event):void {			b2world.Step(timeStep, velocityIterations, positionIterations);			for(var i:uint = 0; i < outsideTS.length; ++i) {				outsideTS[i][0].apply(null, outsideTS[i][1]);			}			outsideTS = [];			if(debug) {				debug.Draw();				addChild(debug); /// Keeps the debug drawer on top.			}		}				/**		 * Loop through the body list and apply gravity. This replaces Box2d's built in gravity, which		 * is fed a zero gravity vector. 		 */		public function applyGravityToWorld(e:Event):void {			if(customGravity) {				customGravity.initStep();			}			var b2:BodyShape;			for(var b:b2Body = b2world.m_bodyList; b; b = b.GetNext()) { 				b2 = b.m_userData as BodyShape;				if(b.IsAwake() && b.IsDynamic()) {					var g:V2 = getGravityFor(b.GetWorldCenter(), b, b2);					if(!b2 || b2.applyGravity) {						b.m_linearVelocity.x += timeStep * g.x;						b.m_linearVelocity.y += timeStep * g.y;					}					if(b2) {						b2.gravity = g;					}				}			}		}				/**		 * Get gravity at a specific point, for a specific body & bodyshape (if a bodyshape exists for the body). The 		 * body & bodyshape are passed so that this function can be overriden to provide different gravity for		 * different objects! This can also be overriden to implement circular gravity, capsule gravity, etc., or alter		 * each non-static non-sleeping gravity-enabled body in some other way.		 */		public function getGravityFor(p:V2, b:b2Body = null, b2:BodyShape = null):V2 {			if(customGravity) {				return customGravity.gravity(p, b, b2);			}			else {				return baseGravity;			}			return null;		}				/**		 * Defers a function call until later if the world is currently locked. This is handy for		 * doing forbidden stuff (like destroying a body) within a contact callback, since contact callbacks		 * happen mid-timestep. If the world is not mid-timestep, the function will be called automatically.		 */		public function doOutsideTimeStep(f:Function, ...args) {			if(b2world.IsLocked()) {				outsideTS.push([f, args]);			}			else {				f.apply(null, args);			}		}				/**		 * Override scrolling to orient based on gravity.		 */		public override function scrollRotation():Number {			if(orientToGravity) {				var b:BodyShape = focus as BodyShape;				var g:V2 = getGravityFor(V2.fromP(pos).divideN(scale), b ? b.b2body : null, b);				return (Math.atan2(g.y, -g.x) * Util.R2D) - 90;			}			return rot;		}	}}
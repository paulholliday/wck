﻿package gravity {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import wck.*;
	import gravity.*;
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.*;
	
	/**
	 * Provides radial gravity.
	 */
	public class GravityRadial extends Gravity {
		
		public var origin:V2;
		
		/**
		 * Get the gravity origin in b2World coordinates.
		 */
		public override function initStep():void {
			origin = V2.fromP(Util.localizePoint(world, this)).divideN(world.scale);
		}
		
		/**
		 * Rotate the base vector gravity based on the direction of the point to the origin.
		 */
		public override function gravity(p:V2, b:b2Body = null, b2:BodyShape = null):V2 {
			initStep();
			return V2.rotate(base, (V2.subtract(p, origin)).angle() + Math.PI / 2);
		}
	}
}
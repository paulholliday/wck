﻿package extras {		import Box2DAS.*;	import Box2DAS.Collision.*;	import Box2DAS.Collision.Shapes.*;	import Box2DAS.Common.*;	import Box2DAS.Dynamics.*;	import Box2DAS.Dynamics.Contacts.*;	import Box2DAS.Dynamics.Joints.*;	import cmodule.Box2D.*;	import wck.*;	import shapes.*;	import misc.*;	import extras.*;	import flash.utils.*;	import flash.events.*;	import flash.display.*;	import flash.text.*;	import flash.geom.*;		public class GroundFinder extends ContactList {				public var up:V2;		public var down:V2;		public var left:V2;		public var right:V2;				public var groundContact:ContactEvent;		public var groundNormal:V2;		public var groundPoint:V2;		public var groundDot:Number = 0;				public var timeTouching:uint = 0;		public var timeAirborne:uint = 0;				public var timeLeftAirborne:uint = 0;		public var timeRightAirborne:uint = 0;				public var leftDot:Number = 0;		public var rightDot:Number = 0;				public var leftContact:ContactEvent;		public var rightContact:ContactEvent;						public var ccwRollContact:ContactEvent;		public var cwRollContact:ContactEvent				public var cl:Array;				public function get jumpVector():V2 {			return V2.multiplyN(groundNormal, -1).add(up).add(V2.multiplyN(up, groundDot)).normalize();		}				public function process(gravity:V2 = null):void {			down = gravity ? V2.normalize(gravity) : new V2(0, -1);			up = V2.multiplyN(down, -1);			left = V2.cw90(up);			right = V2.ccw90(up);			cl = values;			if(cl.length > 0) {				var dt:Number;				var d:String;				var cw:V2 = new V2();				var ccw:V2 = new V2();				var c:ContactEvent;				for(var i:uint = 0; i < cl.length; ++i) {					c = cl[i];					dt = down.dot(c.normal);					if(i == 0 || dt > groundDot) {						groundDot = dt;						groundContact = c;					}					dt = left.dot(c.normal);					if(i == 0 || dt > leftDot) {						leftDot = dt;						leftContact = c;					}					dt = right.dot(c.normal);					if(i == 0 || dt > rightDot) {						rightDot = dt;						rightContact = c;					}					cw.add(V2.cw90(c.normal));					ccw.add(V2.ccw90(c.normal));				}				groundNormal = groundContact.normal;				groundPoint = groundContact.point;				if(leftDot < -0.9) {					++timeLeftAirborne;				}				else {					timeLeftAirborne = 0;				}				if(rightDot < -0.9) {					++timeRightAirborne;				}				else {					timeRightAirborne = 0;				}				var cwd:Number;				var ccwd:Number;				for(i = 0; i < cl.length; ++i) {					dt = cw.dot(cl[i].normal);					if(i == 0 || dt > cwd) {						cwRollContact = cl[i];						cwd = dt;					}					dt = ccw.dot(cl[i].normal);					if(i == 0 || dt > ccwd) {						ccwRollContact = cl[i];						ccwd = dt;					}				}				++timeTouching;				timeAirborne = 0;			}			else {				timeTouching = 0;				if(timeAirborne == 0) {					timeAirborne = Math.max(timeLeftAirborne, timeRightAirborne);				}				++timeAirborne;				++timeLeftAirborne;				++timeRightAirborne;			}		}	}}
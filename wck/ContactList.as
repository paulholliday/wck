﻿package wck {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import wck.*;
	import misc.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.*;
	
	/**
	 * Buffers contacts for processing before / after a timestep, all at once. Helpful if you need to analyze all
	 * of the contacts at once, rather than one at a time as the events are fired.
	 *
	 * TIP: call "values" getter to get all the contacts. See base class "DictionaryTree" for more functionality.
	 */
	public class ContactList extends DictionaryTree {
		
		public var removed:DictionaryTree = new DictionaryTree();
		public var ignoring:Dictionary = new Dictionary();
		public var num:int = 0;
		
		/// The c.e. filter can be tweaked to get at the contacts you want.
		public var contactEventFilter:ContactEventFilter = new ContactEventFilter();
		
		/**
		 * Listen for contact events. Only bother with BEGIN and END.
		 */
		public function listenTo(b:BodyShape):void {
			b.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact, false, 0, true);
			b.addEventListener(ContactEvent.END_CONTACT, handleEndContact, false, 0, true);
		}
		
		/**
		 * Stop listening to a b2Fixture.
		 */
		public function stopListeningTo(b:BodyShape):void {
			b.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact, false);
			b.removeEventListener(ContactEvent.END_CONTACT, handleEndContact, false);
			remove([b]);
		}
		
		/**
		 * Store the contact. It will stay in the list until a REMOVE event is fired and clean() is called.
		 */
		public function handleBeginContact(e:ContactEvent):void {
			if(!ignoring[e.relatedObject]) {
				store([e.fixture, e.other], e);
				removed.remove([e.fixture, e.other]);
			}
		}
		
		/**
		 * Store the contact event in the "removed" list. ContactEvents are not removed from the list
		 * immediately because in CCD a contact can be added & removed in the same step. If it was
		 * immediately removed from the list, there wouldn't be a chance to process it. To trash
		 * REMOVED contacts, call clean().
		 */
		public function handleEndContact(e:ContactEvent):void {
			removed.store([e.fixture, e.other], e);
		}
		
		/**
		 * Removes all contacts that are currently in the REMOVE phase. Also decrements ignore step counts.
		 */
		public function clean():void {
			removed.forEach(function(k:Array, v:*) {
				remove(k);
			});
			removed.flush();
			var r:Array = [];
			for(var b:* in ignoring) {
				if(--ignoring[b] <= 0) {
					r.push(b);
				}
			}
			for(var i:uint = 0; i < r.length; ++i) {
				delete ignoring[r[i]];
			}
		}
		
		/**
		 * For a certain number of timesteps, ignore any new contacts that are dispatched from the provided
		 * body shape.
		 */
		public function ignore(b:BodyShape, steps:int = 1):void {
			ignoring[b] = steps;
		}
		
		/**
		 * Implement filter so that we can specify exactly what types of contacts we are interested in (ignore sensors, etc.).
		 */
		public override function filter(o:*):Boolean {
			return contactEventFilter.filter(o as ContactEvent);
		}
		
		/**
		 * Apply an impulse to the other body involved in every contact.
		 */
		public function applyImpulse(base:Number, massFactor:Number = 0):void {
			forEach(function(k:Array, e:ContactEvent):void {
				e.applyImpulse(base, massFactor);
			});
		}

		/**
		 * Apply a force to the other body involved in every contact.
		 */
		public function applyForce(base:Number, massFactor:Number = 0):void {
			forEach(function(k:Array, e:ContactEvent):void {
				e.applyForce(base, massFactor);
			});
		}		
	}
}
////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom SDK
//
//  Version: MPL 1.1/GPL 3/LGPL 3
//
//  The contents of this file are subject to the Mozilla Public License Version
//  1.1 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//  http://www.mozilla.org/MPL/
//
//  Software distributed under the License is distributed on an "AS IS" basis,
//  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
//  for the specific language governing rights and limitations under the
//  License.
//
//  The Original Code is the OpenZoom SDK.
//
//  The Initial Developer of the Original Code is Daniel Gasienica.
//  Portions created by the Initial Developer are Copyright (c) 2007-2009
//  the Initial Developer. All Rights Reserved.
//
//  Contributor(s):
//    Daniel Gasienica <daniel@gasienica.ch>
//	  Mike Pearson <gmp26@cam.ac.uk>	
//
//  Alternatively, the contents of this file may be used under the terms of
//  either the GNU General Public License Version 3 or later (the "GPL"), or
//  the GNU Lesser General Public License Version 3 or later (the "LGPL"),
//  in which case the provisions of the GPL or the LGPL are applicable instead
//  of those above. If you wish to allow use of your version of this file only
//  under the terms of either the GPL or the LGPL, and not to allow others to
//  use your version of this file under the terms of the MPL, indicate your
//  decision by deleting the provisions above and replace them with the notice
//  and other provisions required by the GPL or the LGPL. If you do not delete
//  the provisions above, a recipient may use your version of this file under
//  the terms of any one of the MPL, the GPL or the LGPL.
//
////////////////////////////////////////////////////////////////////////////////
package components
{

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.Slider;
	
	[Event(name="change", event=Event.CHANGE)]

	[Event(name="panUp", event=PANUP)]
	[Event(name="panDown", event=PANDOWN)]
	[Event(name="panLeft", event=PANLEFT)]
	[Event(name="panRight", event=PANRIGHT)]
	
	[SkinState("normal")]
	[SkinState("disabled")]
	public class PanZoomController extends SkinnableComponent
	{
		public static const PANUP:String = "panUp";
		public static const PANDOWN:String = "panDown";
		public static const PANLEFT:String = "panLeft";
		public static const PANRIGHT:String = "panRight";
		
		public function PanZoomController()
		{
			super();
		}

		[SkinPart(required="false")]
		public var panControl:PanController;
		
		[SkinPart(required="true")]
		public var zoomIn:Button;
		
		[SkinPart(required="true")]
		public var zoomSlider:Slider;
		
		[SkinPart(required="true")]
		public var zoomOut:Button;
		
		override protected function partAdded(partName:String, instance:Object) : void {
			super.partAdded(partName, instance);
			
			if(instance==panControl) {
				panControl.panUp.addEventListener(MouseEvent.CLICK, panUpHandler);
				panControl.panDown.addEventListener(MouseEvent.CLICK, panDownHandler);
				panControl.panLeft.addEventListener(MouseEvent.CLICK, panLeftHandler);
				panControl.panRight.addEventListener(MouseEvent.CLICK, panRightHandler);
				panControl.panUp.focusEnabled = false;
				panControl.panDown.focusEnabled = false;
				panControl.panLeft.focusEnabled = false;
				panControl.panRight.focusEnabled = false;
			}
			
			else if(instance==zoomIn) {
				zoomIn.addEventListener(MouseEvent.CLICK, zoomInHandler);
				zoomIn.focusEnabled = false;
			}
			
			else if(instance==zoomSlider) {
				zoomSlider.addEventListener(Event.CHANGE, zoomChangeHandler);
				stepSize = _stepSize;
				maximum = _maximum;
				minimum = _minimum;
				value = _value;
				zoomSlider.focusEnabled = false;
			}
			
			else if(instance==zoomOut) {
				zoomOut.addEventListener(MouseEvent.CLICK, zoomOutHandler);
				zoomOut.focusEnabled = false;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void {
			super.partRemoved(partName, instance);
			if(instance==panControl) {
				panControl.panUp.removeEventListener(MouseEvent.CLICK, panUpHandler);
				panControl.panDown.removeEventListener(MouseEvent.CLICK, panDownHandler);
				panControl.panLeft.removeEventListener(MouseEvent.CLICK, panLeftHandler);
				panControl.panRight.removeEventListener(MouseEvent.CLICK, panRightHandler);
			}
				
			else if(instance==zoomIn) {
				zoomIn.removeEventListener(MouseEvent.CLICK, zoomInHandler);	
			}
				
			else if(instance==zoomSlider) {
				zoomSlider.removeEventListener(Event.CHANGE, zoomChangeHandler);
			}
				
			else if(instance==zoomOut) {
				zoomOut.removeEventListener(MouseEvent.CLICK, zoomOutHandler);
			}
			
		}
		
		
		override protected function getCurrentSkinState():String {
			return this.enabled ? "normal" : "disabled";
		}
		
		//
		// Event handlers
		//
		private function panUpHandler(event:MouseEvent):void {
			dispatchEvent(new Event(PANUP));
		}
		
		private function panDownHandler(event:MouseEvent):void {
			dispatchEvent(new Event(PANDOWN));
		}
		
		private function panLeftHandler(event:MouseEvent):void {
			dispatchEvent(new Event(PANLEFT));
		}
		
		private function panRightHandler(event:MouseEvent):void {
			dispatchEvent(new Event(PANRIGHT));
		}
		
		private function zoomInHandler(event:MouseEvent):void {
			zoomSlider.changeValueByStep(true);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function zoomOutHandler(event:MouseEvent):void {
			zoomSlider.changeValueByStep(false);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function zoomChangeHandler(event:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		//
		// Properties
		//
		/**
		 * The zoomslider value
		 */
		private var _value:Number = 0;
		[Bindable]
		public function get value():Number {
			if(zoomSlider)
				return zoomSlider.value;
			else
				return _value;
		}
		public function set value(n:Number):void {
			_value = n;
			if(zoomSlider)
				zoomSlider.value = n;
		}
		
		/**
		 * The minimum value
		 */
		private var _minimum:Number = 0;
		[Bindable]
		public function get minimum():Number {
			if(zoomSlider)
				return zoomSlider.minimum;
			else
				return _minimum;
		}
		public function set minimum(n:Number):void {
			_minimum = n;
			if(zoomSlider)
				zoomSlider.minimum = n;
		}
		
		/**
		 * The maximum value
		 */
		private var _maximum:Number = 10;
		[Bindable]
		public function get maximum():Number {
			if(zoomSlider)
				return zoomSlider.maximum;
			else
				return _maximum;
		}
		
		public function set maximum(n:Number):void {
			_maximum = n;
			if(zoomSlider)
				zoomSlider.maximum = n;
		}
		
		/**
		 * slider snapInterval
		 */
		private var _snapInterval:Number = 0.2;
		[Bindable]
		public function get snapInterval():Number {
			if(zoomSlider)
				_snapInterval = zoomSlider.snapInterval;
			return _snapInterval;
		}
		public function set snapInterval(n:Number):void {
			_snapInterval = n;
			if(zoomSlider)
				zoomSlider.snapInterval = n;
		}
		
		/**
		 * slider step size
		 */
		private var _stepSize:Number = 0.2;
		[Bindable]
		public function get stepSize():Number {
			if(zoomSlider)
				_stepSize = zoomSlider.stepSize;
			return _stepSize;
		}
		public function set stepSize(n:Number):void {
			_stepSize = n;
			if(zoomSlider) {
				zoomSlider.snapInterval = _snapInterval;
				zoomSlider.stepSize = n;
			}
		}
		
	}
}
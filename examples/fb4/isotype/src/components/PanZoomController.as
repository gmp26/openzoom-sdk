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
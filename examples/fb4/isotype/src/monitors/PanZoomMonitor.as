package monitors
{
	import components.PanZoomController;
	
	import flash.events.Event;
	
	import org.openzoom.flash.events.ViewportEvent;
	import org.openzoom.flash.viewport.INormalizedViewport;
	import org.openzoom.flash.viewport.IViewportController;
	import org.openzoom.flash.viewport.controllers.ViewportControllerBase;
	
	public class PanZoomMonitor extends ViewportControllerBase implements IViewportController
	{
		public function PanZoomMonitor()
		{
			super();
		}
		
		public var panZoom:PanZoomController;
		/**
		 * The pan zoom control widget we need to update with the current zoom level
		 */ 
		public function get control():PanZoomController {
			return panZoom;
		}
		public function set control(component:PanZoomController):void {
			panZoom = component;
		}
		
		//----------------------------------
		//  viewport
		//----------------------------------
		
		/**
		 * Indicates which viewport is controlled by this controller.
		 */
		override public function get viewport():INormalizedViewport {
			return super.viewport;
		}
		override public function set viewport(value:INormalizedViewport):void
		{
			if(super.viewport == value)
				return;
			
			super.viewport = value;

			if(value != null) {
				viewport.addEventListener(ViewportEvent.TRANSFORM_UPDATE, transformUpdate);
			}
			else {
				viewport.removeEventListener(ViewportEvent.TRANSFORM_UPDATE, transformUpdate);
			}
		}
		
		private function transformUpdate(event:ViewportEvent):void {
			panZoom.value = Math.log(viewport.zoom)*Math.LOG2E;
		}
		
	
	}
}
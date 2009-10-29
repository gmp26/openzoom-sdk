package components
{
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class PanController extends SkinnableComponent
	{
		public function PanController()
		{
			super();
		}
		
		[SkinPart(required="true")]
		public var panUp:Button;
		
		[SkinPart(required="true")]
		public var panDown:Button;
		
		[SkinPart(required="true")]
		public var panLeft:Button;
		
		[SkinPart(required="true")]
		public var panRight:Button;
	}
}
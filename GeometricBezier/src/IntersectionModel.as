package
{
	import kaishiqi.geometric.IGeometric;

	public class IntersectionModel
	{
		static public const TYPE_UNKNOWN:int = 0;
		static public const TYPE_RECT:int = 1;
		static public const TYPE_ELLIPSE:int = 2;
		static public const TYPE_BEZIER_LINE:int = 3;
		static public const TYPE_BEZIER_QUADRATIC:int = 4;
		static public const TYPE_BEZIER_CUBIC:int = 5;
		
		public var geometricType:int;
		public var geometric:IGeometric;
		
		public function IntersectionModel()
		{
			geometricType = TYPE_UNKNOWN;
		}
		
	}
}
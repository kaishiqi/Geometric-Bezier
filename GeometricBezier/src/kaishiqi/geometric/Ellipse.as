package kaishiqi.geometric
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class Ellipse implements IGeometric
	{
		protected var _origin:Point;
		protected var _radiusX:Number;
		protected var _radiusY:Number;
		
		public function Ellipse(origin:Point = null, radiusX:Number = 0, radiusY:Number = 0)
		{
			_origin = origin ? origin : new Point();
			_radiusX = radiusX;
			_radiusY = radiusY;
		}
		
		public function get origin():Point { return _origin; }
		public function set origin(value:Point):void { _origin = value; }
		
		public function get radiusX():Number { return _radiusX; }
		public function set radiusX(value:Number):void { _radiusX = value; }
		
		public function get radiusY():Number { return _radiusY; }
		public function set radiusY(value:Number):void { _radiusY = value; }
		
		public function draw(g:Graphics, dash:Number = NaN, dashStart:Number = 0.0):void
		{
			g.drawEllipse(origin.x-radiusX, origin.y-radiusY, radiusX*2, radiusY*2);
		}
		
	}
}
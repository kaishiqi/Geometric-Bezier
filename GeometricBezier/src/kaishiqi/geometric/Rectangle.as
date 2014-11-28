package kaishiqi.geometric
{
	import flash.display.Graphics;
	import flash.geom.Point;

	public class Rectangle implements IGeometric
	{
		protected var _start:Point;
		protected var _end:Point;
		
		public function Rectangle(startPos:Point = null, endPos:Point = null)
		{
			start = startPos ? startPos : new Point();
			end = endPos ? endPos : new Point();
		}
		
		public function get start():Point { return _start; }
		public function set start(value:Point):void { _start = value; }
		
		public function get end():Point { return _end; }
		public function set end(value:Point):void { _end = value; }
		
		public function draw(g:Graphics, dash:Number = NaN, dashStart:Number = 0.0):void
		{
			g.drawRect(start.x, start.y, end.x - start.x, end.y - start.y);
		}
		
	}
}
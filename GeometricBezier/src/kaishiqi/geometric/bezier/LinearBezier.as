package kaishiqi.geometric.bezier
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class LinearBezier implements IBezierCurve
	{
		protected var _start:Point;
		protected var _end:Point;
		
		public function LinearBezier(startPos:Point = null, endPos:Point = null)
		{
			start = startPos ? startPos : new Point();
			end = endPos ? endPos : new Point();
		}
		
		public function get start():Point { return _start; }
		public function set start(value:Point):void { _start = value; }
		
		public function get end():Point { return _end; }
		public function set end(value:Point):void { _end = value; }
		
		public function clone():IBezierCurve
		{
			return new LinearBezier(start.clone(), end.clone());
		}
		
		public function offset(dx:Number, dy:Number):void
		{
			start.offset(dx, dy);
			end.offset(dx, dy);
		}
		
		public function get length() : Number 
		{
			return getSegmentLength(1.0); 
		}
		
		public function getSegmentLength(time:Number):Number
		{
			var point:Point = getPoint(time);
			var a:Number = point.x - start.x;
			var b:Number = point.y - start.y;
			return Math.sqrt(a*a + b*b);
		}
		
		public function getTimeByDistance(distance:Number):Number
		{
			return distance / length;
		}
		
		public function getPoint(time:Number):Point
		{
			return new Point(
				start.x + (end.x - start.x) * time,
				start.y + (end.y - start.y) * time
			);
		}
		
		public function getTangentAngle(time:Number):Number
		{
			return Math.atan2(end.y - start.y, end.x - start.x);
		}
		
		public function getSegmentCurve(fromTime:Number = 0, toTime:Number = 1):IBezierCurve
		{
			return new LinearBezier(getPoint(fromTime), getPoint(toTime));
		}
		
		public function draw(g:Graphics, dash:Number = NaN, dashStart:Number = 0.0):void
		{
			if (!isNaN(dash)) {
				var totalArcLength:Number = this.length; 
				var arcLength:Number = totalArcLength - dashStart;
				var dashNum:int = Math.ceil(arcLength / (dash + dash));
				for (var i:int = 0; i < dashNum; i++) {
					var startLen:Number = dashStart + dash * 2 * i;
					var endLen:Number = startLen + dash;
					var startTime:Number = getTimeByDistance(startLen);
					var endTime:Number = (endLen < totalArcLength) ? getTimeByDistance(endLen) : 1;
					(getSegmentCurve(startTime, endTime) as LinearBezier).draw(g);
				}
			} else {
				g.moveTo(start.x,start.y);
				g.lineTo(end.x,end.y);
			}
		}
		
	}
}
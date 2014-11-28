package kaishiqi.geometric.bezier
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class QuadraticBezier implements IBezierCurve
	{
		protected static const PRECISION:Number = 1e-5;
		protected var _start:Point;
		protected var _control:Point;
		protected var _end:Point;
		
		public function QuadraticBezier(startPos:Point = null, controlPos:Point = null, endPos:Point = null)
		{
			start = startPos ? startPos : new Point();
			control = controlPos ? controlPos : new Point();
			end = endPos ? endPos : new Point();
		}
		
		public function get start():Point { return _start; }
		public function set start(value:Point):void { _start = value; }
		
		public function get control():Point { return _control; }
		public function set control(value:Point):void { _control = value; }
		
		public function get end():Point { return _end; }
		public function set end(value:Point):void { _end = value; }
		
		public function clone():IBezierCurve
		{
			return new QuadraticBezier(start.clone(), control.clone(), end.clone());
		}
		
		public function offset(dx:Number, dy:Number):void
		{
			start.offset(dx, dy);
			control.offset(dx, dy);
			end.offset(dx, dy);
		}
		
		public function get length() : Number 
		{
			return getSegmentLength(1.0); 
		}
		
		public function getSegmentLength(time:Number):Number
		{
			var bx:Number = control.x - start.x;
			var by:Number = control.y - start.y;
			var ax:Number = end.x - control.x - bx;
			var ay:Number = end.y - control.y - by;
			
			var A:Number = 4 * (ax * ax + ay * ay);
			var B:Number = 8 * (ax * bx + ay * by);
			var C:Number = 4 * (bx * bx + by * by);
			
			var sqrt_abc:Number = Math.sqrt(C + time * (B + A * time));
			var sqrt_a:Number = Math.sqrt(A);
			var sqrt_c:Number = Math.sqrt(C);
			var sqrt_a2:Number = 2 * sqrt_a;
			var a2:Number = 2 * A * time;
			
			var temp1:Number = (a2 * sqrt_abc + B * (sqrt_abc - sqrt_c));
			var temp2:Number = sqrt_a2 * temp1;
			var temp3:Number = Math.log(B + sqrt_a2 * sqrt_c);
			var temp4:Number = Math.log(B + a2 + sqrt_a2 * sqrt_abc);
			var temp5:Number = (B * B - 4 * A * C) * (temp3 - temp4);
			return (temp2 + temp5) / (8 * Math.pow(A, 1.5));
		}
		
		protected function derivativeSqrt(time:Number):Number
		{
			var it:Number = 1 - time;
			var sx:Number = 2 * it * (control.x - start.x) + 2 * time * (end.x - control.x);
			var sy:Number = 2 * it * (control.y - start.y) + 2 * time * (end.y - control.y);
			return Math.sqrt(sx * sx + sy * sy);
		}
		
		public function getTimeByDistance(distance:Number):Number
		{
			var totalArcLength:Number = this.length;
			var time:Number = distance / totalArcLength;
			
			if (distance <= 0) 
				return 0;
			
			if (distance >= totalArcLength)
				return 1; 
			
			var arcLength:Number = time * totalArcLength;
			var maxIterations:int = 100;
			var t1:Number = time;
			var t2:Number = 0;
			do {
				var diffArcLength:Number = getSegmentLength(t1); 
				t2 = t1 - (diffArcLength - arcLength) / derivativeSqrt(t1);
				if (Math.abs(t1-t2) < PRECISION) break;
				t1 = t2;
			}while(true && maxIterations--);
			return t2;
		}
		
		public function getPoint(time:Number):Point
		{
			var f:Number = 1 - time;
			return new Point(
				start.x * f * f + control.x * 2 * time * f + end.x * time * time,
				start.y * f * f + control.y * 2 * time * f + end.y * time * time
			);
		}
		
		public function getTangentAngle(time:Number):Number
		{
			var q0:Point = getInterpolatePos(start, control, time);
			var q1:Point = getInterpolatePos(control, end, time);
			return Math.atan2(q1.y - q0.y, q1.x - q0.x);
		}
		
		public function getSegmentCurve(fromTime:Number = 0, toTime:Number = 1):IBezierCurve
		{
			var segmentStart:Point = getPoint(fromTime);
			var segmentEnd:Point = getPoint(toTime);
			var segmentMiddle:Point = getPoint((fromTime + toTime) / 2);
			var baseMiddle:Point = getInterpolatePos(segmentStart, segmentEnd, 0.5);
			var segmentControl:Point = getInterpolatePos(segmentMiddle, baseMiddle, -2);
			return new QuadraticBezier(segmentStart, segmentControl, segmentEnd);
		}
		
		protected function getInterpolatePos(startPos:Point, endPos:Point, time:Number):Point
		{
			return new Point(
				startPos.x + (endPos.x - startPos.x) * time,
				startPos.y + (endPos.y - startPos.y) * time
			);
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
					(getSegmentCurve(startTime, endTime) as QuadraticBezier).draw(g);
				}
			} else {
				g.moveTo(start.x,start.y);
				g.curveTo(control.x, control.y, end.x,end.y);
			}
		}
		
	}
}

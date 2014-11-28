package kaishiqi.geometric.bezier
{
	import flash.display.Graphics;
	import flash.geom.Point;

	public class CubicBezier implements IBezierCurve
	{
		protected static const PRECISION:Number = 1e-5;
		protected var _start:Point;
		protected var _startControl:Point;
		protected var _endControl:Point;
		protected var _end:Point;
		
		public function CubicBezier(startPos:Point = null, startControlPos:Point = null, endControlPos:Point = null, endPos:Point = null)
		{
			_start = startPos ? startPos : new Point();
			_startControl = startControlPos ? startControlPos : new Point();
			_endControl = endControlPos ? endControlPos : new Point();
			_end = endPos ? endPos : new Point();
		}
		
		public function get start():Point { return _start; }
		public function set start(value:Point):void { _start = value; }
		
		public function get startControl():Point { return _startControl; }
		public function set startControl(value:Point):void { _startControl = value; }
		
		public function get endControl():Point { return _endControl; }
		public function set endControl(value:Point):void { _endControl = value; }
		
		public function get end():Point { return _end; }
		public function set end(value:Point):void { _end = value; }
		
		public function clone():IBezierCurve
		{
			return new CubicBezier(start.clone(), startControl.clone(), endControl.clone(), end.clone());
		}
		
		public function offset(dx:Number, dy:Number):void
		{
			start.offset(dx, dy);
			startControl.offset(dx, dy);
			endControl.offset(dx, dy);
			end.offset(dx, dy);
		}
		
		public function get length() : Number 
		{
			return getSegmentLength(1.0); 
		}
		
		public function getSegmentLength(time:Number):Number
		{
			return getArcLength(time);
		}
		
		public function getArcLength(t:Number = 1, n:int = 20):Number
		{
			var z:Number = t / 2;
			var sum:Number = 0;
			var correctedT:Number = 0;
			for (var i:int = 0; i < n; i++) {
				correctedT = z * LegendreGaussValues.T_VALUES[n][i] + z;
				sum += LegendreGaussValues.C_VALUES[n][i] * derivativeSqrt(correctedT);
			}
			return z * sum;
		}
		
		protected function derivativeSqrt(time:Number):Number
		{
			var it:Number = 1 - time;
			var temp1:Number = 3 * it * it;
			var temp2:Number = 6 * it * time;
			var temp3:Number = 3 * time * time;
			var sx:Number = temp1 * (startControl.x - start.x) + temp2 * (endControl.x - startControl.x) + temp3 * (end.x - endControl.x); 
			var sy:Number = temp1 * (startControl.y - start.y) + temp2 * (endControl.y - startControl.y) + temp3 * (end.y - endControl.y);
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
			var f2:Number = f * f;
			var t2:Number = time * time;
			return new Point(
				start.x * f2 * f + startControl.x * 3 * f2 * time + endControl.x * 3 * t2 * f + end.x * t2 * time,
				start.y * f2 * f + startControl.y * 3 * f2 * time + endControl.y * 3 * t2 * f + end.y * t2 * time
			);
		}
		
		public function getTangentAngle(time:Number):Number
		{
			var iPoints:CubicBezierIntermediatePoints = null; 
			iPoints = new CubicBezierIntermediatePoints(start, startControl, endControl, end, time);
			return Math.atan2(iPoints.r1.y - iPoints.r0.y, iPoints.r1.x - iPoints.r0.x);
		}
		
		public function getSegmentCurve(fromTime:Number = 0, toTime:Number = 1):IBezierCurve
		{
			var fromPos:Point = getPoint(fromTime);
			var toPos:Point = getPoint(toTime);
			
			var fromIPoints:CubicBezierIntermediatePoints = null; 
			fromIPoints = new CubicBezierIntermediatePoints(start, startControl, endControl, end, fromTime);
			var f2eCurve:CubicBezier = new CubicBezier(fromPos, fromIPoints.r1, fromIPoints.q2, end);
			
			var fromArcLen:Number = getSegmentLength(fromTime);
			var toArcLen:Number = getSegmentLength(toTime);
			var cutArcLen:Number = toArcLen - fromArcLen;
			var cutTime:Number = f2eCurve.getTimeByDistance(cutArcLen);
			
			var cutIPoints:CubicBezierIntermediatePoints = null; 
			cutIPoints = new CubicBezierIntermediatePoints(f2eCurve.start, f2eCurve.startControl, f2eCurve.endControl, f2eCurve.end, cutTime);
			return new CubicBezier(fromPos, cutIPoints.q0, cutIPoints.r0, toPos);
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
					(getSegmentCurve(startTime, endTime) as CubicBezier).draw(g);
				}
			} else {
				g.moveTo(start.x,start.y);
				g.cubicCurveTo(startControl.x, startControl.y, endControl.x, endControl.y, end.x,end.y);
			}
		}
		
	}
}


import flash.geom.Point;

class CubicBezierIntermediatePoints
{
	protected var _q0:Point;
	protected var _q1:Point;
	protected var _q2:Point;
	protected var _r0:Point;
	protected var _r1:Point;
	
	public function CubicBezierIntermediatePoints(startPos:Point, startControlPos:Point, endControlPos:Point, endPos:Point, 
												  time:Number)
	{
		_q0 = getInterpolatePos(startPos, startControlPos, time);
		_q1 = getInterpolatePos(startControlPos, endControlPos, time);
		_q2 = getInterpolatePos(endControlPos, endPos, time);
		_r0 = getInterpolatePos(q0, q1, time);
		_r1 = getInterpolatePos(q1, q2, time);
	}
	
	public function get q0():Point { return _q0; }
	public function get q1():Point { return _q1; }
	public function get q2():Point { return _q2; }
	public function get r0():Point { return _r0; }
	public function get r1():Point { return _r1; }
	
	protected function getInterpolatePos(startPos:Point, endPos:Point, time:Number):Point
	{
		return new Point(
			startPos.x + (endPos.x - startPos.x) * time,
			startPos.y + (endPos.y - startPos.y) * time
		);
	}
}

class Value
{
	
}

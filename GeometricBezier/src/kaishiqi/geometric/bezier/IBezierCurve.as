/**
 * References:
 * 
 * http://en.wikipedia.org/wiki/B%C3%A9zier_curve
 * Wiki: Bézier curve
 * 
 * http://www.malczak.info/blog/quadratic-bezier-curve-length/
 * Quadratic Bezier curve length post
 * 
 * http://bl.ocks.org/hnakamur/e7efd0602bfc15f66fc5
 * Cubic bezier curve length
 * 
 * */
package kaishiqi.geometric.bezier
{
	import flash.geom.Point;
	
	import kaishiqi.geometric.IGeometric;
	
	public interface IBezierCurve extends IGeometric
	{
		/**
		 * @return curve start position.
		 */
		function get start():Point;
		function set start(value:Point):void;
		
		/**
		 * @return curve end position.
		 */
		function get end():Point;
		function set end(value:Point):void;
		
		/**
		 * @return curve length.
		 */
		function get length():Number;
		
		/**
		 * @param time [0.0 - 1.0]
		 * @return the curve length according to ratio.
		 */
		function getSegmentLength(time:Number):Number;	
		
		/**
		 * @param distance
		 * @return according to distance, a ratio on the curve.
		 */
		function getTimeByDistance(distance:Number):Number;
		
		/**
		 * @param time [0.0 - 1.0]
		 * @return according to ratio, a position on the curve.	
		 **/
		function getPoint(time:Number):Point;
		
		/**
		 * @param time [0.0 - 1.0]
		 * @return according to ratio, a angle on the curve.
		 */
		function getTangentAngle(time:Number):Number;
		
		/**
		 * @param fromTime [0.0 - 1.0]
		 * @param toTime [0.0 - 1.0]
		 * @return segment the curve according to ratio.
		 */
		function getSegmentCurve(fromTime:Number = 0, toTime:Number = 1):IBezierCurve; 
			
		/**
		 * offset the curve.
		 */
		function offset(dx:Number, dy:Number):void;
		
		/**
		 * clone the curve.
		 */
		function clone():IBezierCurve;
	}
}
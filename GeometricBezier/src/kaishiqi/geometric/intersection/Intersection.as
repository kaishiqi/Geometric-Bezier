/**
 * References:
 * 
 * http://www.kevlindev.com/gui/math/intersection/Intersection.js
 * http://www.kevlindev.com/geometry/2D/intersections/intersect_bezier3_bezier3.svg
 * 
 * */
package kaishiqi.geometric.intersection
{
	public class Intersection
	{
		public function Intersection(status:String)
		{
			_status = status;
			_points = new Vector.<Vector2D>();
		}
		
		private var _status:String;
		public function get status():String { return _status; };
		public function set status(s:String):void { _status = s; };
		
		private var _points:Vector.<Vector2D>;
		public function get points():Vector.<Vector2D> { return _points; };
		
		private function appendPoint(point:Vector2D):void
		{
			_points.push(point);
		}
		
		private function appendPoints(points:Vector.<Vector2D>):void
		{
			_points = _points.concat(points);
		}
		
		
		/*****
		 *
		 *   intersectLineLine
		 *
		 *****/
		static public function intersectLineLine(a1:Vector2D, a2:Vector2D, 
												 b1:Vector2D, b2:Vector2D):Intersection
		{
			var result:Intersection = null;
			
			var ua_t:Number = (b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x);
			var ub_t:Number = (a2.x - a1.x) * (a1.y - b1.y) - (a2.y - a1.y) * (a1.x - b1.x);
			var u_b:Number  = (b2.y - b1.y) * (a2.x - a1.x) - (b2.x - b1.x) * (a2.y - a1.y);
			
			if ( u_b != 0 ) {
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;
				
				if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {
					result = new Intersection("Intersection");
					result.points.push(
						new Vector2D(
							a1.x + ua * (a2.x - a1.x),
							a1.y + ua * (a2.y - a1.y)
						)
					);
				} else {
					result = new Intersection("No Intersection");
				}
			} else {
				if ( ua_t == 0 || ub_t == 0 ) {
					result = new Intersection("Coincident");
				} else {
					result = new Intersection("Parallel");
				}
			}
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectLineRectangle
		 *
		 *****/
		static public function intersectLineRectangle(a1:Vector2D, a2:Vector2D, 
													  r1:Vector2D, r2:Vector2D):Intersection 
		{
			var min:Vector2D        = r1.min(r2);
			var max:Vector2D        = r1.max(r2);
			var topRight:Vector2D   = new Vector2D( max.x, min.y );
			var bottomLeft:Vector2D = new Vector2D( min.x, max.y );
			
			var inter1:Intersection = Intersection.intersectLineLine(min, topRight, a1, a2);
			var inter2:Intersection = Intersection.intersectLineLine(topRight, max, a1, a2);
			var inter3:Intersection = Intersection.intersectLineLine(max, bottomLeft, a1, a2);
			var inter4:Intersection = Intersection.intersectLineLine(bottomLeft, min, a1, a2);
			
			var result:Intersection = new Intersection("No Intersection");
			
			result.appendPoints(inter1.points);
			result.appendPoints(inter2.points);
			result.appendPoints(inter3.points);
			result.appendPoints(inter4.points);
			
			if ( result.points.length > 0 )
				result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier2Line
		 *
		 *****/
		static public function intersectBezier2Line(p1:Vector2D, p2:Vector2D, p3:Vector2D, 
													a1:Vector2D, a2:Vector2D):Intersection
		{
			
			var a:Vector2D, b:Vector2D;             	// temporary variables
			var c2:Vector2D, c1:Vector2D, c0:Vector2D;	// coefficients of quadratic
			var cl:Number;               				// c coefficient for normal form of line
			var n:Vector2D;                				// normal for normal form of line
			var min:Vector2D = a1.min(a2); 				// used to determine if point is on line segment
			var max:Vector2D = a1.max(a2); 				// used to determine if point is on line segment
			var result:Intersection = new Intersection("No Intersection");
			
			a = p2.multiply(-2);
			c2 = p1.add(a.add(p3));
			
			a = p1.multiply(-2);
			b = p2.multiply(2);
			c1 = a.add(b);
			
			c0 = new Vector2D(p1.x, p1.y);
			
			// Convert line to normal form: ax + by + c = 0
			// Find normal to line: negative inverse of original line's slope
			n = new Vector2D(a1.y - a2.y, a2.x - a1.x);
			
			// Determine new c coefficient
			cl = a1.x*a2.y - a2.x*a1.y;
			
			// Transform cubic coefficients to line's coordinate system and find roots
			// of cubic
			var roots:Vector.<Number> = new Polynomial(
				n.dot(c2),
				n.dot(c1),
				n.dot(c0) + cl
			).getRoots();
			
			// Any roots in closed interval [0,1] are intersections on Bezier, but
			// might not be on the line segment.
			// Find intersections and calculate point coordinates
			for ( var i:int = 0; i < roots.length; i++ ) {
				var t:Number = roots[i];
				
				if ( 0 <= t && t <= 1 ) {
					// We're within the Bezier curve
					// Find point on Bezier
					var p4:Vector2D = p1.lerp(p2, t);
					var p5:Vector2D = p2.lerp(p3, t);
					var p6:Vector2D = p4.lerp(p5, t);
					
					// See if point is on line segment
					// Had to make special cases for vertical and horizontal lines due
					// to slight errors in calculation of p6
					if ( a1.x == a2.x ) {
						if ( min.y <= p6.y && p6.y <= max.y ) {
							result.status = "Intersection";
							result.appendPoint( p6 );
						}
					} else if ( a1.y == a2.y ) {
						if ( min.x <= p6.x && p6.x <= max.x ) {
							result.status = "Intersection";
							result.appendPoint( p6 );
						}
					} else if ( p6.gte(min) && p6.lte(max) ) {
							result.status = "Intersection";
							result.appendPoint( p6 );
					}
				}
			}
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier2Bezier2
		 *
		 *****/
		static public function intersectBezier2Bezier2(a1:Vector2D, a2:Vector2D, a3:Vector2D, 
													   b1:Vector2D, b2:Vector2D, b3:Vector2D):Intersection
		{
			var a:Vector2D, b:Vector2D;
			var c12:Vector2D, c11:Vector2D, c10:Vector2D;
			var c22:Vector2D, c21:Vector2D, c20:Vector2D;
			var result:Intersection = new Intersection("No Intersection");
			var poly:Polynomial;
			
			a = a2.multiply(-2);
			c12 = a1.add(a.add(a3));
			
			a = a1.multiply(-2);
			b = a2.multiply(2);
			c11 = a.add(b);
			
			c10 = new Vector2D(a1.x, a1.y);
			
			a = b2.multiply(-2);
			c22 = b1.add(a.add(b3));
			
			a = b1.multiply(-2);
			b = b2.multiply(2);
			c21 = a.add(b);
			
			c20 = new Vector2D(b1.x, b1.y);
			
			if ( c12.y == 0 ) {
				var v00:Number = c12.x*(c10.y - c20.y);
				var v01:Number = v00 - c11.x*c11.y;
				var v02:Number = v00 + v01;
				var v03:Number = c11.y*c11.y;
				
				poly = new Polynomial(
					c12.x*c22.y*c22.y,
					2*c12.x*c21.y*c22.y,
					c12.x*c21.y*c21.y - c22.x*v03 - c22.y*v00 - c22.y*v01,
					-c21.x*v03 - c21.y*v00 - c21.y*v01,
					(c10.x - c20.x)*v03 + (c10.y - c20.y)*v01
				);
			} else {
				var v0:Number = c12.x*c22.y - c12.y*c22.x;
				var v1:Number = c12.x*c21.y - c21.x*c12.y;
				var v2:Number = c11.x*c12.y - c11.y*c12.x;
				var v3:Number = c10.y - c20.y;
				var v4:Number = c12.y*(c10.x - c20.x) - c12.x*v3;
				var v5:Number = -c11.y*v2 + c12.y*v4;
				var v6:Number = v2*v2;
				
				poly = new Polynomial(
					v0*v0,
					2*v0*v1,
					(-c22.y*v6 + c12.y*v1*v1 + c12.y*v0*v4 + v0*v5) / c12.y,
					(-c21.y*v6 + c12.y*v1*v4 + v1*v5) / c12.y,
					(v3*v6 + v4*v5) / c12.y
				);
			}
			
			//var roots:Vector.<Number> = poly.getRoots();//inaccuracy
			var roots:Vector.<Number> = poly.getRootsInInterval(0,1);//Fixed
			for ( var i:int = 0; i < roots.length; i++ ) {
				var s:Number = roots[i];
				
				if ( 0 <= s && s <= 1 ) {
					var xRoots:Vector.<Number> = new Polynomial(
						c12.x,
						c11.x,
						c10.x - c20.x - s*c21.x - s*s*c22.x
					).getRoots();
					var yRoots:Vector.<Number> = new Polynomial(
						c12.y,
						c11.y,
						c10.y - c20.y - s*c21.y - s*s*c22.y
					).getRoots();
					
					if ( xRoots.length > 0 && yRoots.length > 0 ) {
						var TOLERANCE:Number = 1e-4;
						
						checkRoots:
						for ( var j:int = 0; j < xRoots.length; j++ ) {
							var xRoot:Number = xRoots[j];
							
							if ( 0 <= xRoot && xRoot <= 1 ) {
								for ( var k:int = 0; k < yRoots.length; k++ ) {
									if ( Math.abs( xRoot - yRoots[k] ) < TOLERANCE ) {
										result.points.push( c22.multiply(s*s).add(c21.multiply(s).add(c20)) );
										break checkRoots;
									}
								}
							}
						}
					}
				}
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier2Bezier3
		 *
		 *****/
		static public function intersectBezier2Bezier3(a1:Vector2D, a2:Vector2D, a3:Vector2D, 
													   b1:Vector2D, b2:Vector2D, b3:Vector2D, b4:Vector2D):Intersection {
			var a:Vector2D, b:Vector2D,c:Vector2D, d:Vector2D;
			var c12:Vector2D, c11:Vector2D, c10:Vector2D;
			var c23:Vector2D, c22:Vector2D, c21:Vector2D, c20:Vector2D;
			var result:Intersection = new Intersection("No Intersection");
			
			a = a2.multiply(-2);
			c12 = a1.add(a.add(a3));
			
			a = a1.multiply(-2);
			b = a2.multiply(2);
			c11 = a.add(b);
			
			c10 = new Vector2D(a1.x, a1.y);
			
			a = b1.multiply(-1);
			b = b2.multiply(3);
			c = b3.multiply(-3);
			d = a.add(b.add(c.add(b4)));
			c23 = new Vector2D(d.x, d.y);
			
			a = b1.multiply(3);
			b = b2.multiply(-6);
			c = b3.multiply(3);
			d = a.add(b.add(c));
			c22 = new Vector2D(d.x, d.y);
			
			a = b1.multiply(-3);
			b = b2.multiply(3);
			c = a.add(b);
			c21 = new Vector2D(c.x, c.y);
			
			c20 = new Vector2D(b1.x, b1.y);
			
			var c10x2:Number = c10.x*c10.x;
			var c10y2:Number = c10.y*c10.y;
			var c11x2:Number = c11.x*c11.x;
			var c11y2:Number = c11.y*c11.y;
			var c12x2:Number = c12.x*c12.x;
			var c12y2:Number = c12.y*c12.y;
			var c20x2:Number = c20.x*c20.x;
			var c20y2:Number = c20.y*c20.y;
			var c21x2:Number = c21.x*c21.x;
			var c21y2:Number = c21.y*c21.y;
			var c22x2:Number = c22.x*c22.x;
			var c22y2:Number = c22.y*c22.y;
			var c23x2:Number = c23.x*c23.x;
			var c23y2:Number = c23.y*c23.y;
			
			var poly:Polynomial = new Polynomial(
				-2*c12.x*c12.y*c23.x*c23.y + c12x2*c23y2 + c12y2*c23x2,
				-2*c12.x*c12.y*c22.x*c23.y - 2*c12.x*c12.y*c22.y*c23.x + 2*c12y2*c22.x*c23.x +
				2*c12x2*c22.y*c23.y,
				-2*c12.x*c21.x*c12.y*c23.y - 2*c12.x*c12.y*c21.y*c23.x - 2*c12.x*c12.y*c22.x*c22.y +
				2*c21.x*c12y2*c23.x + c12y2*c22x2 + c12x2*(2*c21.y*c23.y + c22y2),
				2*c10.x*c12.x*c12.y*c23.y + 2*c10.y*c12.x*c12.y*c23.x + c11.x*c11.y*c12.x*c23.y +
				c11.x*c11.y*c12.y*c23.x - 2*c20.x*c12.x*c12.y*c23.y - 2*c12.x*c20.y*c12.y*c23.x -
				2*c12.x*c21.x*c12.y*c22.y - 2*c12.x*c12.y*c21.y*c22.x - 2*c10.x*c12y2*c23.x -
				2*c10.y*c12x2*c23.y + 2*c20.x*c12y2*c23.x + 2*c21.x*c12y2*c22.x -
				c11y2*c12.x*c23.x - c11x2*c12.y*c23.y + c12x2*(2*c20.y*c23.y + 2*c21.y*c22.y),
				2*c10.x*c12.x*c12.y*c22.y + 2*c10.y*c12.x*c12.y*c22.x + c11.x*c11.y*c12.x*c22.y +
				c11.x*c11.y*c12.y*c22.x - 2*c20.x*c12.x*c12.y*c22.y - 2*c12.x*c20.y*c12.y*c22.x -
				2*c12.x*c21.x*c12.y*c21.y - 2*c10.x*c12y2*c22.x - 2*c10.y*c12x2*c22.y +
				2*c20.x*c12y2*c22.x - c11y2*c12.x*c22.x - c11x2*c12.y*c22.y + c21x2*c12y2 +
				c12x2*(2*c20.y*c22.y + c21y2),
				2*c10.x*c12.x*c12.y*c21.y + 2*c10.y*c12.x*c21.x*c12.y + c11.x*c11.y*c12.x*c21.y +
				c11.x*c11.y*c21.x*c12.y - 2*c20.x*c12.x*c12.y*c21.y - 2*c12.x*c20.y*c21.x*c12.y -
				2*c10.x*c21.x*c12y2 - 2*c10.y*c12x2*c21.y + 2*c20.x*c21.x*c12y2 -
				c11y2*c12.x*c21.x - c11x2*c12.y*c21.y + 2*c12x2*c20.y*c21.y,
				-2*c10.x*c10.y*c12.x*c12.y - c10.x*c11.x*c11.y*c12.y - c10.y*c11.x*c11.y*c12.x +
				2*c10.x*c12.x*c20.y*c12.y + 2*c10.y*c20.x*c12.x*c12.y + c11.x*c20.x*c11.y*c12.y +
				c11.x*c11.y*c12.x*c20.y - 2*c20.x*c12.x*c20.y*c12.y - 2*c10.x*c20.x*c12y2 +
				c10.x*c11y2*c12.x + c10.y*c11x2*c12.y - 2*c10.y*c12x2*c20.y -
				c20.x*c11y2*c12.x - c11x2*c20.y*c12.y + c10x2*c12y2 + c10y2*c12x2 +
				c20x2*c12y2 + c12x2*c20y2
			);
			var roots:Vector.<Number> = poly.getRootsInInterval(0,1);
			
			for ( var i:int = 0; i < roots.length; i++ ) {
				var s:Number = roots[i];
				var xRoots:Vector.<Number> = new Polynomial(
					c12.x,
					c11.x,
					c10.x - c20.x - s*c21.x - s*s*c22.x - s*s*s*c23.x
				).getRoots();
				var yRoots:Vector.<Number> = new Polynomial(
					c12.y,
					c11.y,
					c10.y - c20.y - s*c21.y - s*s*c22.y - s*s*s*c23.y
				).getRoots();
				
				if ( xRoots.length > 0 && yRoots.length > 0 ) {
					var TOLERANCE:Number = 1e-4;
					
					checkRoots:
					for ( var j:int = 0; j < xRoots.length; j++ ) {
						var xRoot:Number = xRoots[j];
						
						if ( 0 <= xRoot && xRoot <= 1 ) {
							for ( var k:int = 0; k < yRoots.length; k++ ) {
								if ( Math.abs( xRoot - yRoots[k] ) < TOLERANCE ) {
									result.points.push(
										c23.multiply(s*s*s).add(c22.multiply(s*s).add(c21.multiply(s).add(c20)))
									);
									break checkRoots;
								}
							}
						}
					}
				}
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier2Rectangle
		 *
		 *****/
		static public function intersectBezier2Rectangle(p1:Vector2D, p2:Vector2D, p3:Vector2D, 
														 r1:Vector2D, r2:Vector2D):Intersection
		{
			var min:Vector2D        = r1.min(r2);
			var max:Vector2D        = r1.max(r2);
			var topRight:Vector2D   = new Vector2D( max.x, min.y );
			var bottomLeft:Vector2D = new Vector2D( min.x, max.y );
			
			var inter1:Intersection = Intersection.intersectBezier2Line(p1, p2, p3, min, topRight);
			var inter2:Intersection = Intersection.intersectBezier2Line(p1, p2, p3, topRight, max);
			var inter3:Intersection = Intersection.intersectBezier2Line(p1, p2, p3, max, bottomLeft);
			var inter4:Intersection = Intersection.intersectBezier2Line(p1, p2, p3, bottomLeft, min);
			
			var result:Intersection = new Intersection("No Intersection");
			
			result.appendPoints(inter1.points);
			result.appendPoints(inter2.points);
			result.appendPoints(inter3.points);
			result.appendPoints(inter4.points);
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier2Ellipse
		 *
		 *****/
		static public function intersectBezier2Ellipse(p1:Vector2D, p2:Vector2D, p3:Vector2D, 
													   ec:Vector2D, rx:Number, ry:Number):Intersection
		{
			var a:Vector2D, b:Vector2D;       // temporary variables
			var c2:Vector2D, c1:Vector2D, c0:Vector2D; // coefficients of quadratic
			var result:Intersection = new Intersection("No Intersection");
			
			a = p2.multiply(-2);
			c2 = p1.add(a.add(p3));
			
			a = p1.multiply(-2);
			b = p2.multiply(2);
			c1 = a.add(b);
			
			c0 = new Vector2D(p1.x, p1.y);
			
			var rxrx:Number = rx*rx;
			var ryry:Number = ry*ry;
			var roots:Vector.<Number> = new Polynomial(
				ryry*c2.x*c2.x + rxrx*c2.y*c2.y,
				2*(ryry*c2.x*c1.x + rxrx*c2.y*c1.y),
				ryry*(2*c2.x*c0.x + c1.x*c1.x) + rxrx*(2*c2.y*c0.y+c1.y*c1.y) -
				2*(ryry*ec.x*c2.x + rxrx*ec.y*c2.y),
				2*(ryry*c1.x*(c0.x-ec.x) + rxrx*c1.y*(c0.y-ec.y)),
				ryry*(c0.x*c0.x+ec.x*ec.x) + rxrx*(c0.y*c0.y + ec.y*ec.y) -
				2*(ryry*ec.x*c0.x + rxrx*ec.y*c0.y) - rxrx*ryry
				//).getRoots();//inaccuracy
			).getRootsInInterval(0,1);//Fixed
			
			for ( var i:int = 0; i < roots.length; i++ ) {
				var t:Number = roots[i];
				
				if ( 0 <= t && t <= 1 )
					result.points.push( c2.multiply(t*t).add(c1.multiply(t).add(c0)) );
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier3Line
		 *
		 *   Many thanks to Dan Sunday at SoftSurfer.com.  He gave me a very thorough
		 *   sketch of the algorithm used here.  Without his help, I'm not sure when I
		 *   would have figured out this intersection problem.
		 *
		 *****/
		static public function intersectBezier3Line(p1:Vector2D, p2:Vector2D, p3:Vector2D, p4:Vector2D, 
													a1:Vector2D, a2:Vector2D):Intersection 
		{
			var a:Vector2D, b:Vector2D, c:Vector2D, d:Vector2D;       // temporary variables
			var c3:Vector2D, c2:Vector2D, c1:Vector2D, c0:Vector2D;   // coefficients of cubic
			var cl:Number;               // c coefficient for normal form of line
			var n:Vector2D;                // normal for normal form of line
			var min:Vector2D = a1.min(a2); // used to determine if point is on line segment
			var max:Vector2D = a1.max(a2); // used to determine if point is on line segment
			var result:Intersection = new Intersection("No Intersection");
			
			// Start with Bezier using Bernstein polynomials for weighting functions:
			//     (1-t^3)P1 + 3t(1-t)^2P2 + 3t^2(1-t)P3 + t^3P4
			//
			// Expand and collect terms to form linear combinations of original Bezier
			// controls.  This ends up with a vector cubic in t:
			//     (-P1+3P2-3P3+P4)t^3 + (3P1-6P2+3P3)t^2 + (-3P1+3P2)t + P1
			//             /\                  /\                /\       /\
			//             ||                  ||                ||       ||
			//             c3                  c2                c1       c0
			
			// Calculate the coefficients
			a = p1.multiply(-1);
			b = p2.multiply(3);
			c = p3.multiply(-3);
			d = a.add(b.add(c.add(p4)));
			c3 = new Vector2D(d.x, d.y);
			
			a = p1.multiply(3);
			b = p2.multiply(-6);
			c = p3.multiply(3);
			d = a.add(b.add(c));
			c2 = new Vector2D(d.x, d.y);
			
			a = p1.multiply(-3);
			b = p2.multiply(3);
			c = a.add(b);
			c1 = new Vector2D(c.x, c.y);
			
			c0 = new Vector2D(p1.x, p1.y);
			
			// Convert line to normal form: ax + by + c = 0
			// Find normal to line: negative inverse of original line's slope
			n = new Vector2D(a1.y - a2.y, a2.x - a1.x);
			
			// Determine new c coefficient
			cl = a1.x*a2.y - a2.x*a1.y;
			
			// ?Rotate each cubic coefficient using line for new coordinate system?
			// Find roots of rotated cubic
			var roots:Vector.<Number> = new Polynomial(
				n.dot(c3),
				n.dot(c2),
				n.dot(c1),
				n.dot(c0) + cl
			).getRoots();
			
			// Any roots in closed interval [0,1] are intersections on Bezier, but
			// might not be on the line segment.
			// Find intersections and calculate point coordinates
			for ( var i:int = 0; i < roots.length; i++ ) {
				var t:Number = roots[i];
				
				if ( 0 <= t && t <= 1 ) {
					// We're within the Bezier curve
					// Find point on Bezier
					var p5:Vector2D = p1.lerp(p2, t);
					var p6:Vector2D = p2.lerp(p3, t);
					var p7:Vector2D = p3.lerp(p4, t);
					
					var p8:Vector2D = p5.lerp(p6, t);
					var p9:Vector2D = p6.lerp(p7, t);
					
					var p10:Vector2D = p8.lerp(p9, t);
					
					// See if point is on line segment
					// Had to make special cases for vertical and horizontal lines due
					// to slight errors in calculation of p10
					if ( a1.x == a2.x ) {
						if ( min.y <= p10.y && p10.y <= max.y ) {
							result.status = "Intersection";
							result.appendPoint( p10 );
						}
					} else if ( a1.y == a2.y ) {
						if ( min.x <= p10.x && p10.x <= max.x ) {
							result.status = "Intersection";
							result.appendPoint( p10 );
						}
					} else if ( p10.gte(min) && p10.lte(max) ) {
						result.status = "Intersection";
						result.appendPoint( p10 );
					}
				}
			}
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier3Bezier3
		 *
		 *****/
		static public function intersectBezier3Bezier3(a1:Vector2D, a2:Vector2D, a3:Vector2D, a4:Vector2D, 
													   b1:Vector2D, b2:Vector2D, b3:Vector2D, b4:Vector2D):Intersection
		{
			var a:Vector2D, b:Vector2D, c:Vector2D, d:Vector2D;         // temporary variables
			var c13:Vector2D, c12:Vector2D, c11:Vector2D, c10:Vector2D; // coefficients of cubic
			var c23:Vector2D, c22:Vector2D, c21:Vector2D, c20:Vector2D; // coefficients of cubic
			var result:Intersection = new Intersection("No Intersection");
			
			// Calculate the coefficients of cubic polynomial
			a = a1.multiply(-1);
			b = a2.multiply(3);
			c = a3.multiply(-3);
			d = a.add(b.add(c.add(a4)));
			c13 = new Vector2D(d.x, d.y);
			
			a = a1.multiply(3);
			b = a2.multiply(-6);
			c = a3.multiply(3);
			d = a.add(b.add(c));
			c12 = new Vector2D(d.x, d.y);
			
			a = a1.multiply(-3);
			b = a2.multiply(3);
			c = a.add(b);
			c11 = new Vector2D(c.x, c.y);
			
			c10 = new Vector2D(a1.x, a1.y);
			
			a = b1.multiply(-1);
			b = b2.multiply(3);
			c = b3.multiply(-3);
			d = a.add(b.add(c.add(b4)));
			c23 = new Vector2D(d.x, d.y);
			
			a = b1.multiply(3);
			b = b2.multiply(-6);
			c = b3.multiply(3);
			d = a.add(b.add(c));
			c22 = new Vector2D(d.x, d.y);
			
			a = b1.multiply(-3);
			b = b2.multiply(3);
			c = a.add(b);
			c21 = new Vector2D(c.x, c.y);
			
			c20 = new Vector2D(b1.x, b1.y);
			
			var c10x2:Number = c10.x*c10.x;
			var c10x3:Number = c10.x*c10.x*c10.x;
			var c10y2:Number = c10.y*c10.y;
			var c10y3:Number = c10.y*c10.y*c10.y;
			var c11x2:Number = c11.x*c11.x;
			var c11x3:Number = c11.x*c11.x*c11.x;
			var c11y2:Number = c11.y*c11.y;
			var c11y3:Number = c11.y*c11.y*c11.y;
			var c12x2:Number = c12.x*c12.x;
			var c12x3:Number = c12.x*c12.x*c12.x;
			var c12y2:Number = c12.y*c12.y;
			var c12y3:Number = c12.y*c12.y*c12.y;
			var c13x2:Number = c13.x*c13.x;
			var c13x3:Number = c13.x*c13.x*c13.x;
			var c13y2:Number = c13.y*c13.y;
			var c13y3:Number = c13.y*c13.y*c13.y;
			var c20x2:Number = c20.x*c20.x;
			var c20x3:Number = c20.x*c20.x*c20.x;
			var c20y2:Number = c20.y*c20.y;
			var c20y3:Number = c20.y*c20.y*c20.y;
			var c21x2:Number = c21.x*c21.x;
			var c21x3:Number = c21.x*c21.x*c21.x;
			var c21y2:Number = c21.y*c21.y;
			var c22x2:Number = c22.x*c22.x;
			var c22x3:Number = c22.x*c22.x*c22.x;
			var c22y2:Number = c22.y*c22.y;
			var c23x2:Number = c23.x*c23.x;
			var c23x3:Number = c23.x*c23.x*c23.x;
			var c23y2:Number = c23.y*c23.y;
			var c23y3:Number = c23.y*c23.y*c23.y;
			var poly:Polynomial = new Polynomial(
				-c13x3*c23y3 + c13y3*c23x3 - 3*c13.x*c13y2*c23x2*c23.y +
				3*c13x2*c13.y*c23.x*c23y2,
				-6*c13.x*c22.x*c13y2*c23.x*c23.y + 6*c13x2*c13.y*c22.y*c23.x*c23.y + 3*c22.x*c13y3*c23x2 -
				3*c13x3*c22.y*c23y2 - 3*c13.x*c13y2*c22.y*c23x2 + 3*c13x2*c22.x*c13.y*c23y2,
				-6*c21.x*c13.x*c13y2*c23.x*c23.y - 6*c13.x*c22.x*c13y2*c22.y*c23.x + 6*c13x2*c22.x*c13.y*c22.y*c23.y +
				3*c21.x*c13y3*c23x2 + 3*c22x2*c13y3*c23.x + 3*c21.x*c13x2*c13.y*c23y2 - 3*c13.x*c21.y*c13y2*c23x2 -
				3*c13.x*c22x2*c13y2*c23.y + c13x2*c13.y*c23.x*(6*c21.y*c23.y + 3*c22y2) + c13x3*(-c21.y*c23y2 -
					2*c22y2*c23.y - c23.y*(2*c21.y*c23.y + c22y2)),
				c11.x*c12.y*c13.x*c13.y*c23.x*c23.y - c11.y*c12.x*c13.x*c13.y*c23.x*c23.y + 6*c21.x*c22.x*c13y3*c23.x +
				3*c11.x*c12.x*c13.x*c13.y*c23y2 + 6*c10.x*c13.x*c13y2*c23.x*c23.y - 3*c11.x*c12.x*c13y2*c23.x*c23.y -
				3*c11.y*c12.y*c13.x*c13.y*c23x2 - 6*c10.y*c13x2*c13.y*c23.x*c23.y - 6*c20.x*c13.x*c13y2*c23.x*c23.y +
				3*c11.y*c12.y*c13x2*c23.x*c23.y - 2*c12.x*c12y2*c13.x*c23.x*c23.y - 6*c21.x*c13.x*c22.x*c13y2*c23.y -
				6*c21.x*c13.x*c13y2*c22.y*c23.x - 6*c13.x*c21.y*c22.x*c13y2*c23.x + 6*c21.x*c13x2*c13.y*c22.y*c23.y +
				2*c12x2*c12.y*c13.y*c23.x*c23.y + c22x3*c13y3 - 3*c10.x*c13y3*c23x2 + 3*c10.y*c13x3*c23y2 +
				3*c20.x*c13y3*c23x2 + c12y3*c13.x*c23x2 - c12x3*c13.y*c23y2 - 3*c10.x*c13x2*c13.y*c23y2 +
				3*c10.y*c13.x*c13y2*c23x2 - 2*c11.x*c12.y*c13x2*c23y2 + c11.x*c12.y*c13y2*c23x2 - c11.y*c12.x*c13x2*c23y2 +
				2*c11.y*c12.x*c13y2*c23x2 + 3*c20.x*c13x2*c13.y*c23y2 - c12.x*c12y2*c13.y*c23x2 -
				3*c20.y*c13.x*c13y2*c23x2 + c12x2*c12.y*c13.x*c23y2 - 3*c13.x*c22x2*c13y2*c22.y +
				c13x2*c13.y*c23.x*(6*c20.y*c23.y + 6*c21.y*c22.y) + c13x2*c22.x*c13.y*(6*c21.y*c23.y + 3*c22y2) +
				c13x3*(-2*c21.y*c22.y*c23.y - c20.y*c23y2 - c22.y*(2*c21.y*c23.y + c22y2) - c23.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),
				6*c11.x*c12.x*c13.x*c13.y*c22.y*c23.y + c11.x*c12.y*c13.x*c22.x*c13.y*c23.y + c11.x*c12.y*c13.x*c13.y*c22.y*c23.x -
				c11.y*c12.x*c13.x*c22.x*c13.y*c23.y - c11.y*c12.x*c13.x*c13.y*c22.y*c23.x - 6*c11.y*c12.y*c13.x*c22.x*c13.y*c23.x -
				6*c10.x*c22.x*c13y3*c23.x + 6*c20.x*c22.x*c13y3*c23.x + 6*c10.y*c13x3*c22.y*c23.y + 2*c12y3*c13.x*c22.x*c23.x -
				2*c12x3*c13.y*c22.y*c23.y + 6*c10.x*c13.x*c22.x*c13y2*c23.y + 6*c10.x*c13.x*c13y2*c22.y*c23.x +
				6*c10.y*c13.x*c22.x*c13y2*c23.x - 3*c11.x*c12.x*c22.x*c13y2*c23.y - 3*c11.x*c12.x*c13y2*c22.y*c23.x +
				2*c11.x*c12.y*c22.x*c13y2*c23.x + 4*c11.y*c12.x*c22.x*c13y2*c23.x - 6*c10.x*c13x2*c13.y*c22.y*c23.y -
				6*c10.y*c13x2*c22.x*c13.y*c23.y - 6*c10.y*c13x2*c13.y*c22.y*c23.x - 4*c11.x*c12.y*c13x2*c22.y*c23.y -
				6*c20.x*c13.x*c22.x*c13y2*c23.y - 6*c20.x*c13.x*c13y2*c22.y*c23.x - 2*c11.y*c12.x*c13x2*c22.y*c23.y +
				3*c11.y*c12.y*c13x2*c22.x*c23.y + 3*c11.y*c12.y*c13x2*c22.y*c23.x - 2*c12.x*c12y2*c13.x*c22.x*c23.y -
				2*c12.x*c12y2*c13.x*c22.y*c23.x - 2*c12.x*c12y2*c22.x*c13.y*c23.x - 6*c20.y*c13.x*c22.x*c13y2*c23.x -
				6*c21.x*c13.x*c21.y*c13y2*c23.x - 6*c21.x*c13.x*c22.x*c13y2*c22.y + 6*c20.x*c13x2*c13.y*c22.y*c23.y +
				2*c12x2*c12.y*c13.x*c22.y*c23.y + 2*c12x2*c12.y*c22.x*c13.y*c23.y + 2*c12x2*c12.y*c13.y*c22.y*c23.x +
				3*c21.x*c22x2*c13y3 + 3*c21x2*c13y3*c23.x - 3*c13.x*c21.y*c22x2*c13y2 - 3*c21x2*c13.x*c13y2*c23.y +
				c13x2*c22.x*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c13x2*c13.y*c23.x*(6*c20.y*c22.y + 3*c21y2) +
				c21.x*c13x2*c13.y*(6*c21.y*c23.y + 3*c22y2) + c13x3*(-2*c20.y*c22.y*c23.y - c23.y*(2*c20.y*c22.y + c21y2) -
					c21.y*(2*c21.y*c23.y + c22y2) - c22.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),
				c11.x*c21.x*c12.y*c13.x*c13.y*c23.y + c11.x*c12.y*c13.x*c21.y*c13.y*c23.x + c11.x*c12.y*c13.x*c22.x*c13.y*c22.y -
				c11.y*c12.x*c21.x*c13.x*c13.y*c23.y - c11.y*c12.x*c13.x*c21.y*c13.y*c23.x - c11.y*c12.x*c13.x*c22.x*c13.y*c22.y -
				6*c11.y*c21.x*c12.y*c13.x*c13.y*c23.x - 6*c10.x*c21.x*c13y3*c23.x + 6*c20.x*c21.x*c13y3*c23.x +
				2*c21.x*c12y3*c13.x*c23.x + 6*c10.x*c21.x*c13.x*c13y2*c23.y + 6*c10.x*c13.x*c21.y*c13y2*c23.x +
				6*c10.x*c13.x*c22.x*c13y2*c22.y + 6*c10.y*c21.x*c13.x*c13y2*c23.x - 3*c11.x*c12.x*c21.x*c13y2*c23.y -
				3*c11.x*c12.x*c21.y*c13y2*c23.x - 3*c11.x*c12.x*c22.x*c13y2*c22.y + 2*c11.x*c21.x*c12.y*c13y2*c23.x +
				4*c11.y*c12.x*c21.x*c13y2*c23.x - 6*c10.y*c21.x*c13x2*c13.y*c23.y - 6*c10.y*c13x2*c21.y*c13.y*c23.x -
				6*c10.y*c13x2*c22.x*c13.y*c22.y - 6*c20.x*c21.x*c13.x*c13y2*c23.y - 6*c20.x*c13.x*c21.y*c13y2*c23.x -
				6*c20.x*c13.x*c22.x*c13y2*c22.y + 3*c11.y*c21.x*c12.y*c13x2*c23.y - 3*c11.y*c12.y*c13.x*c22x2*c13.y +
				3*c11.y*c12.y*c13x2*c21.y*c23.x + 3*c11.y*c12.y*c13x2*c22.x*c22.y - 2*c12.x*c21.x*c12y2*c13.x*c23.y -
				2*c12.x*c21.x*c12y2*c13.y*c23.x - 2*c12.x*c12y2*c13.x*c21.y*c23.x - 2*c12.x*c12y2*c13.x*c22.x*c22.y -
				6*c20.y*c21.x*c13.x*c13y2*c23.x - 6*c21.x*c13.x*c21.y*c22.x*c13y2 + 6*c20.y*c13x2*c21.y*c13.y*c23.x +
				2*c12x2*c21.x*c12.y*c13.y*c23.y + 2*c12x2*c12.y*c21.y*c13.y*c23.x + 2*c12x2*c12.y*c22.x*c13.y*c22.y -
				3*c10.x*c22x2*c13y3 + 3*c20.x*c22x2*c13y3 + 3*c21x2*c22.x*c13y3 + c12y3*c13.x*c22x2 +
				3*c10.y*c13.x*c22x2*c13y2 + c11.x*c12.y*c22x2*c13y2 + 2*c11.y*c12.x*c22x2*c13y2 -
				c12.x*c12y2*c22x2*c13.y - 3*c20.y*c13.x*c22x2*c13y2 - 3*c21x2*c13.x*c13y2*c22.y +
				c12x2*c12.y*c13.x*(2*c21.y*c23.y + c22y2) + c11.x*c12.x*c13.x*c13.y*(6*c21.y*c23.y + 3*c22y2) +
				c21.x*c13x2*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c12x3*c13.y*(-2*c21.y*c23.y - c22y2) +
				c10.y*c13x3*(6*c21.y*c23.y + 3*c22y2) + c11.y*c12.x*c13x2*(-2*c21.y*c23.y - c22y2) +
				c11.x*c12.y*c13x2*(-4*c21.y*c23.y - 2*c22y2) + c10.x*c13x2*c13.y*(-6*c21.y*c23.y - 3*c22y2) +
				c13x2*c22.x*c13.y*(6*c20.y*c22.y + 3*c21y2) + c20.x*c13x2*c13.y*(6*c21.y*c23.y + 3*c22y2) +
				c13x3*(-2*c20.y*c21.y*c23.y - c22.y*(2*c20.y*c22.y + c21y2) - c20.y*(2*c21.y*c23.y + c22y2) -
					c21.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),
				-c10.x*c11.x*c12.y*c13.x*c13.y*c23.y + c10.x*c11.y*c12.x*c13.x*c13.y*c23.y + 6*c10.x*c11.y*c12.y*c13.x*c13.y*c23.x -
				6*c10.y*c11.x*c12.x*c13.x*c13.y*c23.y - c10.y*c11.x*c12.y*c13.x*c13.y*c23.x + c10.y*c11.y*c12.x*c13.x*c13.y*c23.x +
				c11.x*c11.y*c12.x*c12.y*c13.x*c23.y - c11.x*c11.y*c12.x*c12.y*c13.y*c23.x + c11.x*c20.x*c12.y*c13.x*c13.y*c23.y +
				c11.x*c20.y*c12.y*c13.x*c13.y*c23.x + c11.x*c21.x*c12.y*c13.x*c13.y*c22.y + c11.x*c12.y*c13.x*c21.y*c22.x*c13.y -
				c20.x*c11.y*c12.x*c13.x*c13.y*c23.y - 6*c20.x*c11.y*c12.y*c13.x*c13.y*c23.x - c11.y*c12.x*c20.y*c13.x*c13.y*c23.x -
				c11.y*c12.x*c21.x*c13.x*c13.y*c22.y - c11.y*c12.x*c13.x*c21.y*c22.x*c13.y - 6*c11.y*c21.x*c12.y*c13.x*c22.x*c13.y -
				6*c10.x*c20.x*c13y3*c23.x - 6*c10.x*c21.x*c22.x*c13y3 - 2*c10.x*c12y3*c13.x*c23.x + 6*c20.x*c21.x*c22.x*c13y3 +
				2*c20.x*c12y3*c13.x*c23.x + 2*c21.x*c12y3*c13.x*c22.x + 2*c10.y*c12x3*c13.y*c23.y - 6*c10.x*c10.y*c13.x*c13y2*c23.x +
				3*c10.x*c11.x*c12.x*c13y2*c23.y - 2*c10.x*c11.x*c12.y*c13y2*c23.x - 4*c10.x*c11.y*c12.x*c13y2*c23.x +
				3*c10.y*c11.x*c12.x*c13y2*c23.x + 6*c10.x*c10.y*c13x2*c13.y*c23.y + 6*c10.x*c20.x*c13.x*c13y2*c23.y -
				3*c10.x*c11.y*c12.y*c13x2*c23.y + 2*c10.x*c12.x*c12y2*c13.x*c23.y + 2*c10.x*c12.x*c12y2*c13.y*c23.x +
				6*c10.x*c20.y*c13.x*c13y2*c23.x + 6*c10.x*c21.x*c13.x*c13y2*c22.y + 6*c10.x*c13.x*c21.y*c22.x*c13y2 +
				4*c10.y*c11.x*c12.y*c13x2*c23.y + 6*c10.y*c20.x*c13.x*c13y2*c23.x + 2*c10.y*c11.y*c12.x*c13x2*c23.y -
				3*c10.y*c11.y*c12.y*c13x2*c23.x + 2*c10.y*c12.x*c12y2*c13.x*c23.x + 6*c10.y*c21.x*c13.x*c22.x*c13y2 -
				3*c11.x*c20.x*c12.x*c13y2*c23.y + 2*c11.x*c20.x*c12.y*c13y2*c23.x + c11.x*c11.y*c12y2*c13.x*c23.x -
				3*c11.x*c12.x*c20.y*c13y2*c23.x - 3*c11.x*c12.x*c21.x*c13y2*c22.y - 3*c11.x*c12.x*c21.y*c22.x*c13y2 +
				2*c11.x*c21.x*c12.y*c22.x*c13y2 + 4*c20.x*c11.y*c12.x*c13y2*c23.x + 4*c11.y*c12.x*c21.x*c22.x*c13y2 -
				2*c10.x*c12x2*c12.y*c13.y*c23.y - 6*c10.y*c20.x*c13x2*c13.y*c23.y - 6*c10.y*c20.y*c13x2*c13.y*c23.x -
				6*c10.y*c21.x*c13x2*c13.y*c22.y - 2*c10.y*c12x2*c12.y*c13.x*c23.y - 2*c10.y*c12x2*c12.y*c13.y*c23.x -
				6*c10.y*c13x2*c21.y*c22.x*c13.y - c11.x*c11.y*c12x2*c13.y*c23.y - 2*c11.x*c11y2*c13.x*c13.y*c23.x +
				3*c20.x*c11.y*c12.y*c13x2*c23.y - 2*c20.x*c12.x*c12y2*c13.x*c23.y - 2*c20.x*c12.x*c12y2*c13.y*c23.x -
				6*c20.x*c20.y*c13.x*c13y2*c23.x - 6*c20.x*c21.x*c13.x*c13y2*c22.y - 6*c20.x*c13.x*c21.y*c22.x*c13y2 +
				3*c11.y*c20.y*c12.y*c13x2*c23.x + 3*c11.y*c21.x*c12.y*c13x2*c22.y + 3*c11.y*c12.y*c13x2*c21.y*c22.x -
				2*c12.x*c20.y*c12y2*c13.x*c23.x - 2*c12.x*c21.x*c12y2*c13.x*c22.y - 2*c12.x*c21.x*c12y2*c22.x*c13.y -
				2*c12.x*c12y2*c13.x*c21.y*c22.x - 6*c20.y*c21.x*c13.x*c22.x*c13y2 - c11y2*c12.x*c12.y*c13.x*c23.x +
				2*c20.x*c12x2*c12.y*c13.y*c23.y + 6*c20.y*c13x2*c21.y*c22.x*c13.y + 2*c11x2*c11.y*c13.x*c13.y*c23.y +
				c11x2*c12.x*c12.y*c13.y*c23.y + 2*c12x2*c20.y*c12.y*c13.y*c23.x + 2*c12x2*c21.x*c12.y*c13.y*c22.y +
				2*c12x2*c12.y*c21.y*c22.x*c13.y + c21x3*c13y3 + 3*c10x2*c13y3*c23.x - 3*c10y2*c13x3*c23.y +
				3*c20x2*c13y3*c23.x + c11y3*c13x2*c23.x - c11x3*c13y2*c23.y - c11.x*c11y2*c13x2*c23.y +
				c11x2*c11.y*c13y2*c23.x - 3*c10x2*c13.x*c13y2*c23.y + 3*c10y2*c13x2*c13.y*c23.x - c11x2*c12y2*c13.x*c23.y +
				c11y2*c12x2*c13.y*c23.x - 3*c21x2*c13.x*c21.y*c13y2 - 3*c20x2*c13.x*c13y2*c23.y + 3*c20y2*c13x2*c13.y*c23.x +
				c11.x*c12.x*c13.x*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c12x3*c13.y*(-2*c20.y*c23.y - 2*c21.y*c22.y) +
				c10.y*c13x3*(6*c20.y*c23.y + 6*c21.y*c22.y) + c11.y*c12.x*c13x2*(-2*c20.y*c23.y - 2*c21.y*c22.y) +
				c12x2*c12.y*c13.x*(2*c20.y*c23.y + 2*c21.y*c22.y) + c11.x*c12.y*c13x2*(-4*c20.y*c23.y - 4*c21.y*c22.y) +
				c10.x*c13x2*c13.y*(-6*c20.y*c23.y - 6*c21.y*c22.y) + c20.x*c13x2*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) +
				c21.x*c13x2*c13.y*(6*c20.y*c22.y + 3*c21y2) + c13x3*(-2*c20.y*c21.y*c22.y - c20y2*c23.y -
					c21.y*(2*c20.y*c22.y + c21y2) - c20.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),
				-c10.x*c11.x*c12.y*c13.x*c13.y*c22.y + c10.x*c11.y*c12.x*c13.x*c13.y*c22.y + 6*c10.x*c11.y*c12.y*c13.x*c22.x*c13.y -
				6*c10.y*c11.x*c12.x*c13.x*c13.y*c22.y - c10.y*c11.x*c12.y*c13.x*c22.x*c13.y + c10.y*c11.y*c12.x*c13.x*c22.x*c13.y +
				c11.x*c11.y*c12.x*c12.y*c13.x*c22.y - c11.x*c11.y*c12.x*c12.y*c22.x*c13.y + c11.x*c20.x*c12.y*c13.x*c13.y*c22.y +
				c11.x*c20.y*c12.y*c13.x*c22.x*c13.y + c11.x*c21.x*c12.y*c13.x*c21.y*c13.y - c20.x*c11.y*c12.x*c13.x*c13.y*c22.y -
				6*c20.x*c11.y*c12.y*c13.x*c22.x*c13.y - c11.y*c12.x*c20.y*c13.x*c22.x*c13.y - c11.y*c12.x*c21.x*c13.x*c21.y*c13.y -
				6*c10.x*c20.x*c22.x*c13y3 - 2*c10.x*c12y3*c13.x*c22.x + 2*c20.x*c12y3*c13.x*c22.x + 2*c10.y*c12x3*c13.y*c22.y -
				6*c10.x*c10.y*c13.x*c22.x*c13y2 + 3*c10.x*c11.x*c12.x*c13y2*c22.y - 2*c10.x*c11.x*c12.y*c22.x*c13y2 -
				4*c10.x*c11.y*c12.x*c22.x*c13y2 + 3*c10.y*c11.x*c12.x*c22.x*c13y2 + 6*c10.x*c10.y*c13x2*c13.y*c22.y +
				6*c10.x*c20.x*c13.x*c13y2*c22.y - 3*c10.x*c11.y*c12.y*c13x2*c22.y + 2*c10.x*c12.x*c12y2*c13.x*c22.y +
				2*c10.x*c12.x*c12y2*c22.x*c13.y + 6*c10.x*c20.y*c13.x*c22.x*c13y2 + 6*c10.x*c21.x*c13.x*c21.y*c13y2 +
				4*c10.y*c11.x*c12.y*c13x2*c22.y + 6*c10.y*c20.x*c13.x*c22.x*c13y2 + 2*c10.y*c11.y*c12.x*c13x2*c22.y -
				3*c10.y*c11.y*c12.y*c13x2*c22.x + 2*c10.y*c12.x*c12y2*c13.x*c22.x - 3*c11.x*c20.x*c12.x*c13y2*c22.y +
				2*c11.x*c20.x*c12.y*c22.x*c13y2 + c11.x*c11.y*c12y2*c13.x*c22.x - 3*c11.x*c12.x*c20.y*c22.x*c13y2 -
				3*c11.x*c12.x*c21.x*c21.y*c13y2 + 4*c20.x*c11.y*c12.x*c22.x*c13y2 - 2*c10.x*c12x2*c12.y*c13.y*c22.y -
				6*c10.y*c20.x*c13x2*c13.y*c22.y - 6*c10.y*c20.y*c13x2*c22.x*c13.y - 6*c10.y*c21.x*c13x2*c21.y*c13.y -
				2*c10.y*c12x2*c12.y*c13.x*c22.y - 2*c10.y*c12x2*c12.y*c22.x*c13.y - c11.x*c11.y*c12x2*c13.y*c22.y -
				2*c11.x*c11y2*c13.x*c22.x*c13.y + 3*c20.x*c11.y*c12.y*c13x2*c22.y - 2*c20.x*c12.x*c12y2*c13.x*c22.y -
				2*c20.x*c12.x*c12y2*c22.x*c13.y - 6*c20.x*c20.y*c13.x*c22.x*c13y2 - 6*c20.x*c21.x*c13.x*c21.y*c13y2 +
				3*c11.y*c20.y*c12.y*c13x2*c22.x + 3*c11.y*c21.x*c12.y*c13x2*c21.y - 2*c12.x*c20.y*c12y2*c13.x*c22.x -
				2*c12.x*c21.x*c12y2*c13.x*c21.y - c11y2*c12.x*c12.y*c13.x*c22.x + 2*c20.x*c12x2*c12.y*c13.y*c22.y -
				3*c11.y*c21x2*c12.y*c13.x*c13.y + 6*c20.y*c21.x*c13x2*c21.y*c13.y + 2*c11x2*c11.y*c13.x*c13.y*c22.y +
				c11x2*c12.x*c12.y*c13.y*c22.y + 2*c12x2*c20.y*c12.y*c22.x*c13.y + 2*c12x2*c21.x*c12.y*c21.y*c13.y -
				3*c10.x*c21x2*c13y3 + 3*c20.x*c21x2*c13y3 + 3*c10x2*c22.x*c13y3 - 3*c10y2*c13x3*c22.y + 3*c20x2*c22.x*c13y3 +
				c21x2*c12y3*c13.x + c11y3*c13x2*c22.x - c11x3*c13y2*c22.y + 3*c10.y*c21x2*c13.x*c13y2 -
				c11.x*c11y2*c13x2*c22.y + c11.x*c21x2*c12.y*c13y2 + 2*c11.y*c12.x*c21x2*c13y2 + c11x2*c11.y*c22.x*c13y2 -
				c12.x*c21x2*c12y2*c13.y - 3*c20.y*c21x2*c13.x*c13y2 - 3*c10x2*c13.x*c13y2*c22.y + 3*c10y2*c13x2*c22.x*c13.y -
				c11x2*c12y2*c13.x*c22.y + c11y2*c12x2*c22.x*c13.y - 3*c20x2*c13.x*c13y2*c22.y + 3*c20y2*c13x2*c22.x*c13.y +
				c12x2*c12.y*c13.x*(2*c20.y*c22.y + c21y2) + c11.x*c12.x*c13.x*c13.y*(6*c20.y*c22.y + 3*c21y2) +
				c12x3*c13.y*(-2*c20.y*c22.y - c21y2) + c10.y*c13x3*(6*c20.y*c22.y + 3*c21y2) +
				c11.y*c12.x*c13x2*(-2*c20.y*c22.y - c21y2) + c11.x*c12.y*c13x2*(-4*c20.y*c22.y - 2*c21y2) +
				c10.x*c13x2*c13.y*(-6*c20.y*c22.y - 3*c21y2) + c20.x*c13x2*c13.y*(6*c20.y*c22.y + 3*c21y2) +
				c13x3*(-2*c20.y*c21y2 - c20y2*c22.y - c20.y*(2*c20.y*c22.y + c21y2)),
				-c10.x*c11.x*c12.y*c13.x*c21.y*c13.y + c10.x*c11.y*c12.x*c13.x*c21.y*c13.y + 6*c10.x*c11.y*c21.x*c12.y*c13.x*c13.y -
				6*c10.y*c11.x*c12.x*c13.x*c21.y*c13.y - c10.y*c11.x*c21.x*c12.y*c13.x*c13.y + c10.y*c11.y*c12.x*c21.x*c13.x*c13.y -
				c11.x*c11.y*c12.x*c21.x*c12.y*c13.y + c11.x*c11.y*c12.x*c12.y*c13.x*c21.y + c11.x*c20.x*c12.y*c13.x*c21.y*c13.y +
				6*c11.x*c12.x*c20.y*c13.x*c21.y*c13.y + c11.x*c20.y*c21.x*c12.y*c13.x*c13.y - c20.x*c11.y*c12.x*c13.x*c21.y*c13.y -
				6*c20.x*c11.y*c21.x*c12.y*c13.x*c13.y - c11.y*c12.x*c20.y*c21.x*c13.x*c13.y - 6*c10.x*c20.x*c21.x*c13y3 -
				2*c10.x*c21.x*c12y3*c13.x + 6*c10.y*c20.y*c13x3*c21.y + 2*c20.x*c21.x*c12y3*c13.x + 2*c10.y*c12x3*c21.y*c13.y -
				2*c12x3*c20.y*c21.y*c13.y - 6*c10.x*c10.y*c21.x*c13.x*c13y2 + 3*c10.x*c11.x*c12.x*c21.y*c13y2 -
				2*c10.x*c11.x*c21.x*c12.y*c13y2 - 4*c10.x*c11.y*c12.x*c21.x*c13y2 + 3*c10.y*c11.x*c12.x*c21.x*c13y2 +
				6*c10.x*c10.y*c13x2*c21.y*c13.y + 6*c10.x*c20.x*c13.x*c21.y*c13y2 - 3*c10.x*c11.y*c12.y*c13x2*c21.y +
				2*c10.x*c12.x*c21.x*c12y2*c13.y + 2*c10.x*c12.x*c12y2*c13.x*c21.y + 6*c10.x*c20.y*c21.x*c13.x*c13y2 +
				4*c10.y*c11.x*c12.y*c13x2*c21.y + 6*c10.y*c20.x*c21.x*c13.x*c13y2 + 2*c10.y*c11.y*c12.x*c13x2*c21.y -
				3*c10.y*c11.y*c21.x*c12.y*c13x2 + 2*c10.y*c12.x*c21.x*c12y2*c13.x - 3*c11.x*c20.x*c12.x*c21.y*c13y2 +
				2*c11.x*c20.x*c21.x*c12.y*c13y2 + c11.x*c11.y*c21.x*c12y2*c13.x - 3*c11.x*c12.x*c20.y*c21.x*c13y2 +
				4*c20.x*c11.y*c12.x*c21.x*c13y2 - 6*c10.x*c20.y*c13x2*c21.y*c13.y - 2*c10.x*c12x2*c12.y*c21.y*c13.y -
				6*c10.y*c20.x*c13x2*c21.y*c13.y - 6*c10.y*c20.y*c21.x*c13x2*c13.y - 2*c10.y*c12x2*c21.x*c12.y*c13.y -
				2*c10.y*c12x2*c12.y*c13.x*c21.y - c11.x*c11.y*c12x2*c21.y*c13.y - 4*c11.x*c20.y*c12.y*c13x2*c21.y -
				2*c11.x*c11y2*c21.x*c13.x*c13.y + 3*c20.x*c11.y*c12.y*c13x2*c21.y - 2*c20.x*c12.x*c21.x*c12y2*c13.y -
				2*c20.x*c12.x*c12y2*c13.x*c21.y - 6*c20.x*c20.y*c21.x*c13.x*c13y2 - 2*c11.y*c12.x*c20.y*c13x2*c21.y +
				3*c11.y*c20.y*c21.x*c12.y*c13x2 - 2*c12.x*c20.y*c21.x*c12y2*c13.x - c11y2*c12.x*c21.x*c12.y*c13.x +
				6*c20.x*c20.y*c13x2*c21.y*c13.y + 2*c20.x*c12x2*c12.y*c21.y*c13.y + 2*c11x2*c11.y*c13.x*c21.y*c13.y +
				c11x2*c12.x*c12.y*c21.y*c13.y + 2*c12x2*c20.y*c21.x*c12.y*c13.y + 2*c12x2*c20.y*c12.y*c13.x*c21.y +
				3*c10x2*c21.x*c13y3 - 3*c10y2*c13x3*c21.y + 3*c20x2*c21.x*c13y3 + c11y3*c21.x*c13x2 - c11x3*c21.y*c13y2 -
				3*c20y2*c13x3*c21.y - c11.x*c11y2*c13x2*c21.y + c11x2*c11.y*c21.x*c13y2 - 3*c10x2*c13.x*c21.y*c13y2 +
				3*c10y2*c21.x*c13x2*c13.y - c11x2*c12y2*c13.x*c21.y + c11y2*c12x2*c21.x*c13.y - 3*c20x2*c13.x*c21.y*c13y2 +
				3*c20y2*c21.x*c13x2*c13.y,
				c10.x*c10.y*c11.x*c12.y*c13.x*c13.y - c10.x*c10.y*c11.y*c12.x*c13.x*c13.y + c10.x*c11.x*c11.y*c12.x*c12.y*c13.y -
				c10.y*c11.x*c11.y*c12.x*c12.y*c13.x - c10.x*c11.x*c20.y*c12.y*c13.x*c13.y + 6*c10.x*c20.x*c11.y*c12.y*c13.x*c13.y +
				c10.x*c11.y*c12.x*c20.y*c13.x*c13.y - c10.y*c11.x*c20.x*c12.y*c13.x*c13.y - 6*c10.y*c11.x*c12.x*c20.y*c13.x*c13.y +
				c10.y*c20.x*c11.y*c12.x*c13.x*c13.y - c11.x*c20.x*c11.y*c12.x*c12.y*c13.y + c11.x*c11.y*c12.x*c20.y*c12.y*c13.x +
				c11.x*c20.x*c20.y*c12.y*c13.x*c13.y - c20.x*c11.y*c12.x*c20.y*c13.x*c13.y - 2*c10.x*c20.x*c12y3*c13.x +
				2*c10.y*c12x3*c20.y*c13.y - 3*c10.x*c10.y*c11.x*c12.x*c13y2 - 6*c10.x*c10.y*c20.x*c13.x*c13y2 +
				3*c10.x*c10.y*c11.y*c12.y*c13x2 - 2*c10.x*c10.y*c12.x*c12y2*c13.x - 2*c10.x*c11.x*c20.x*c12.y*c13y2 -
				c10.x*c11.x*c11.y*c12y2*c13.x + 3*c10.x*c11.x*c12.x*c20.y*c13y2 - 4*c10.x*c20.x*c11.y*c12.x*c13y2 +
				3*c10.y*c11.x*c20.x*c12.x*c13y2 + 6*c10.x*c10.y*c20.y*c13x2*c13.y + 2*c10.x*c10.y*c12x2*c12.y*c13.y +
				2*c10.x*c11.x*c11y2*c13.x*c13.y + 2*c10.x*c20.x*c12.x*c12y2*c13.y + 6*c10.x*c20.x*c20.y*c13.x*c13y2 -
				3*c10.x*c11.y*c20.y*c12.y*c13x2 + 2*c10.x*c12.x*c20.y*c12y2*c13.x + c10.x*c11y2*c12.x*c12.y*c13.x +
				c10.y*c11.x*c11.y*c12x2*c13.y + 4*c10.y*c11.x*c20.y*c12.y*c13x2 - 3*c10.y*c20.x*c11.y*c12.y*c13x2 +
				2*c10.y*c20.x*c12.x*c12y2*c13.x + 2*c10.y*c11.y*c12.x*c20.y*c13x2 + c11.x*c20.x*c11.y*c12y2*c13.x -
				3*c11.x*c20.x*c12.x*c20.y*c13y2 - 2*c10.x*c12x2*c20.y*c12.y*c13.y - 6*c10.y*c20.x*c20.y*c13x2*c13.y -
				2*c10.y*c20.x*c12x2*c12.y*c13.y - 2*c10.y*c11x2*c11.y*c13.x*c13.y - c10.y*c11x2*c12.x*c12.y*c13.y -
				2*c10.y*c12x2*c20.y*c12.y*c13.x - 2*c11.x*c20.x*c11y2*c13.x*c13.y - c11.x*c11.y*c12x2*c20.y*c13.y +
				3*c20.x*c11.y*c20.y*c12.y*c13x2 - 2*c20.x*c12.x*c20.y*c12y2*c13.x - c20.x*c11y2*c12.x*c12.y*c13.x +
				3*c10y2*c11.x*c12.x*c13.x*c13.y + 3*c11.x*c12.x*c20y2*c13.x*c13.y + 2*c20.x*c12x2*c20.y*c12.y*c13.y -
				3*c10x2*c11.y*c12.y*c13.x*c13.y + 2*c11x2*c11.y*c20.y*c13.x*c13.y + c11x2*c12.x*c20.y*c12.y*c13.y -
				3*c20x2*c11.y*c12.y*c13.x*c13.y - c10x3*c13y3 + c10y3*c13x3 + c20x3*c13y3 - c20y3*c13x3 -
				3*c10.x*c20x2*c13y3 - c10.x*c11y3*c13x2 + 3*c10x2*c20.x*c13y3 + c10.y*c11x3*c13y2 +
				3*c10.y*c20y2*c13x3 + c20.x*c11y3*c13x2 + c10x2*c12y3*c13.x - 3*c10y2*c20.y*c13x3 - c10y2*c12x3*c13.y +
				c20x2*c12y3*c13.x - c11x3*c20.y*c13y2 - c12x3*c20y2*c13.y - c10.x*c11x2*c11.y*c13y2 +
				c10.y*c11.x*c11y2*c13x2 - 3*c10.x*c10y2*c13x2*c13.y - c10.x*c11y2*c12x2*c13.y + c10.y*c11x2*c12y2*c13.x -
				c11.x*c11y2*c20.y*c13x2 + 3*c10x2*c10.y*c13.x*c13y2 + c10x2*c11.x*c12.y*c13y2 +
				2*c10x2*c11.y*c12.x*c13y2 - 2*c10y2*c11.x*c12.y*c13x2 - c10y2*c11.y*c12.x*c13x2 + c11x2*c20.x*c11.y*c13y2 -
				3*c10.x*c20y2*c13x2*c13.y + 3*c10.y*c20x2*c13.x*c13y2 + c11.x*c20x2*c12.y*c13y2 - 2*c11.x*c20y2*c12.y*c13x2 +
				c20.x*c11y2*c12x2*c13.y - c11.y*c12.x*c20y2*c13x2 - c10x2*c12.x*c12y2*c13.y - 3*c10x2*c20.y*c13.x*c13y2 +
				3*c10y2*c20.x*c13x2*c13.y + c10y2*c12x2*c12.y*c13.x - c11x2*c20.y*c12y2*c13.x + 2*c20x2*c11.y*c12.x*c13y2 +
				3*c20.x*c20y2*c13x2*c13.y - c20x2*c12.x*c12y2*c13.y - 3*c20x2*c20.y*c13.x*c13y2 + c12x2*c20y2*c12.y*c13.x
			);
			var roots:Vector.<Number> = poly.getRootsInInterval(0,1);
			
			for ( var i:int = 0; i < roots.length; i++ ) {
				var s:Number = roots[i];
				var xRoots:Vector.<Number> = new Polynomial(
					c13.x,
					c12.x,
					c11.x,
					c10.x - c20.x - s*c21.x - s*s*c22.x - s*s*s*c23.x
				).getRoots();
				var yRoots:Vector.<Number> = new Polynomial(
					c13.y,
					c12.y,
					c11.y,
					c10.y - c20.y - s*c21.y - s*s*c22.y - s*s*s*c23.y
				).getRoots();
				
				if ( xRoots.length > 0 && yRoots.length > 0 ) {
					var TOLERANCE:Number = 1e-4;
					
					checkRoots:
					for ( var j:int = 0; j < xRoots.length; j++ ) {
						var xRoot:Number = xRoots[j];
						
						if ( 0 <= xRoot && xRoot <= 1 ) {
							for ( var k:int = 0; k < yRoots.length; k++ ) {
								if ( Math.abs( xRoot - yRoots[k] ) < TOLERANCE ) {
									result.points.push(
										c23.multiply(s*s*s).add(c22.multiply(s*s).add(c21.multiply(s).add(c20)))
									);
									break checkRoots;
								}
							}
						}
					}
				}
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier3Rectangle
		 *
		 *****/
		static public function intersectBezier3Rectangle(p1:Vector2D, p2:Vector2D, p3:Vector2D, p4:Vector2D, 
														 r1:Vector2D, r2:Vector2D):Intersection 
		{
			var min:Vector2D        = r1.min(r2);
			var max:Vector2D        = r1.max(r2);
			var topRight:Vector2D   = new Vector2D( max.x, min.y );
			var bottomLeft:Vector2D = new Vector2D( min.x, max.y );
			
			var inter1:Intersection = Intersection.intersectBezier3Line(p1, p2, p3, p4, min, topRight);
			var inter2:Intersection = Intersection.intersectBezier3Line(p1, p2, p3, p4, topRight, max);
			var inter3:Intersection = Intersection.intersectBezier3Line(p1, p2, p3, p4, max, bottomLeft);
			var inter4:Intersection = Intersection.intersectBezier3Line(p1, p2, p3, p4, bottomLeft, min);
			
			var result:Intersection = new Intersection("No Intersection");
			
			result.appendPoints(inter1.points);
			result.appendPoints(inter2.points);
			result.appendPoints(inter3.points);
			result.appendPoints(inter4.points);
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectBezier3Ellipse
		 *
		 *****/
		static public function intersectBezier3Ellipse(p1:Vector2D, p2:Vector2D, p3:Vector2D, p4:Vector2D, 
													   ec:Vector2D, rx:Number, ry:Number):Intersection
		{
			var a:Vector2D, b:Vector2D, c:Vector2D, d:Vector2D;       // temporary variables
			var c3:Vector2D, c2:Vector2D, c1:Vector2D, c0:Vector2D;   // coefficients of cubic
			var result:Intersection = new Intersection("No Intersection");
			
			// Calculate the coefficients of cubic polynomial
			a = p1.multiply(-1);
			b = p2.multiply(3);
			c = p3.multiply(-3);
			d = a.add(b.add(c.add(p4)));
			c3 = new Vector2D(d.x, d.y);
			
			a = p1.multiply(3);
			b = p2.multiply(-6);
			c = p3.multiply(3);
			d = a.add(b.add(c));
			c2 = new Vector2D(d.x, d.y);
			
			a = p1.multiply(-3);
			b = p2.multiply(3);
			c = a.add(b);
			c1 = new Vector2D(c.x, c.y);
			
			c0 = new Vector2D(p1.x, p1.y);
			
			var rxrx:Number = rx*rx;
			var ryry:Number = ry*ry;
			var poly:Polynomial = new Polynomial(
				c3.x*c3.x*ryry + c3.y*c3.y*rxrx,
				2*(c3.x*c2.x*ryry + c3.y*c2.y*rxrx),
				2*(c3.x*c1.x*ryry + c3.y*c1.y*rxrx) + c2.x*c2.x*ryry + c2.y*c2.y*rxrx,
				2*c3.x*ryry*(c0.x - ec.x) + 2*c3.y*rxrx*(c0.y - ec.y) +
				2*(c2.x*c1.x*ryry + c2.y*c1.y*rxrx),
				2*c2.x*ryry*(c0.x - ec.x) + 2*c2.y*rxrx*(c0.y - ec.y) +
				c1.x*c1.x*ryry + c1.y*c1.y*rxrx,
				2*c1.x*ryry*(c0.x - ec.x) + 2*c1.y*rxrx*(c0.y - ec.y),
				c0.x*c0.x*ryry - 2*c0.y*ec.y*rxrx - 2*c0.x*ec.x*ryry +
				c0.y*c0.y*rxrx + ec.x*ec.x*ryry + ec.y*ec.y*rxrx - rxrx*ryry
			);
			var roots:Vector.<Number> = poly.getRootsInInterval(0,1);
			
			for ( var i:int = 0; i < roots.length; i++ ) {
				var t:Number = roots[i];
				
				result.points.push(
					c3.multiply(t*t*t).add(c2.multiply(t*t).add(c1.multiply(t).add(c0)))
				);
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectRectangleRectangle
		 *
		 *****/
		static public function intersectRectangleRectangle(a1:Vector2D, a2:Vector2D, 
														   b1:Vector2D, b2:Vector2D):Intersection 
		{
			var min:Vector2D        = a1.min(a2);
			var max:Vector2D        = a1.max(a2);
			var topRight:Vector2D   = new Vector2D( max.x, min.y );
			var bottomLeft:Vector2D = new Vector2D( min.x, max.y );
			
			var inter1:Intersection = Intersection.intersectLineRectangle(min, topRight, b1, b2);
			var inter2:Intersection = Intersection.intersectLineRectangle(topRight, max, b1, b2);
			var inter3:Intersection = Intersection.intersectLineRectangle(max, bottomLeft, b1, b2);
			var inter4:Intersection = Intersection.intersectLineRectangle(bottomLeft, min, b1, b2);
			
			var result:Intersection = new Intersection("No Intersection");
			
			result.appendPoints(inter1.points);
			result.appendPoints(inter2.points);
			result.appendPoints(inter3.points);
			result.appendPoints(inter4.points);
			
			if ( result.points.length > 0 )
				result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectEllipseLine
		 *   
		 *   NOTE: Rotation will need to be added to this function
		 *
		 *****/
		static public function intersectEllipseLine(o:Vector2D, rx:Number, ry:Number, 
													a1:Vector2D, a2:Vector2D):Intersection
		{
			var result:Intersection = null;
			var origin:Vector2D = new Vector2D(a1.x, a1.y);
			var dir:Vector2D    = Vector2D.fromPoints(a1, a2);
			var center:Vector2D = new Vector2D(o.x, o.y);
			var diff:Vector2D   = origin.subtract(center);
			var mDir:Vector2D   = new Vector2D( dir.x/(rx*rx),  dir.y/(ry*ry)  );
			var mDiff:Vector2D  = new Vector2D( diff.x/(rx*rx), diff.y/(ry*ry) );
			
			var a:Number = dir.dot(mDir);
			var b:Number = dir.dot(mDiff);
			var c:Number = diff.dot(mDiff) - 1.0;
			var d:Number = b*b - a*c;
			
			if ( d < 0 ) {
				result = new Intersection("Outside");
			} else if ( d > 0 ) {
				var root:Number = Math.sqrt(d);
				var t_a:Number  = (-b - root) / a;
				var t_b:Number  = (-b + root) / a;
				
				if ( (t_a < 0 || 1 < t_a) && (t_b < 0 || 1 < t_b) ) {
					if ( (t_a < 0 && t_b < 0) || (t_a > 1 && t_b > 1) )
						result = new Intersection("Outside");
					else
						result = new Intersection("Inside");
				} else {
					result = new Intersection("Intersection");
					if ( 0 <= t_a && t_a <= 1 )
						result.appendPoint( a1.lerp(a2, t_a) );
					if ( 0 <= t_b && t_b <= 1 )
						result.appendPoint( a1.lerp(a2, t_b) );
				}
			} else {
				var t:Number = -b/a;
				if ( 0 <= t && t <= 1 ) {
					result = new Intersection("Intersection");
					result.appendPoint( a1.lerp(a2, t) );
				} else {
					result = new Intersection("Outside");
				}
			}
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectEllipseRectangle
		 *
		 *****/
		static public function intersectEllipseRectangle(o:Vector2D, rx:Number, ry:Number, 
														 r1:Vector2D, r2:Vector2D):Intersection
		{
			var min:Vector2D        = r1.min(r2);
			var max:Vector2D        = r1.max(r2);
			var topRight:Vector2D   = new Vector2D( max.x, min.y );
			var bottomLeft:Vector2D = new Vector2D( min.x, max.y );
			
			var inter1:Intersection = Intersection.intersectEllipseLine(o, rx, ry, min, topRight);
			var inter2:Intersection = Intersection.intersectEllipseLine(o, rx, ry, topRight, max);
			var inter3:Intersection = Intersection.intersectEllipseLine(o, rx, ry, max, bottomLeft);
			var inter4:Intersection = Intersection.intersectEllipseLine(o, rx, ry, bottomLeft, min);
			
			var result:Intersection = new Intersection("No Intersection");
			
			result.appendPoints(inter1.points);
			result.appendPoints(inter2.points);
			result.appendPoints(inter3.points);
			result.appendPoints(inter4.points);
			
			if ( result.points.length > 0 )
				result.status = "Intersection";
			
			return result;
		}
		
		
		/*****
		 *
		 *   intersectEllipseEllipse
		 *   
		 *   This code is based on MgcIntr2DElpElp.cpp written by David Eberly.  His
		 *   code along with many other excellent examples are avaiable at his site:
		 *   http://www.magic-software.com
		 *
		 *   NOTE: Rotation will need to be added to this function
		 *
		 *****/
		static public function intersectEllipseEllipse(c1:Vector2D, rx1:Number, ry1:Number, 
													   c2:Vector2D, rx2:Number, ry2:Number):Intersection
		{
			var a:Vector.<Number> = Vector.<Number>([
				ry1*ry1, 0, rx1*rx1, -2*ry1*ry1*c1.x, -2*rx1*rx1*c1.y,
				ry1*ry1*c1.x*c1.x + rx1*rx1*c1.y*c1.y - rx1*rx1*ry1*ry1
			]);
			var b:Vector.<Number> = Vector.<Number>([
				ry2*ry2, 0, rx2*rx2, -2*ry2*ry2*c2.x, -2*rx2*rx2*c2.y,
				ry2*ry2*c2.x*c2.x + rx2*rx2*c2.y*c2.y - rx2*rx2*ry2*ry2
			]);
			
			var yPoly:Polynomial   = Intersection.bezout(a, b);
			var yRoots:Vector.<Number>  = yPoly.getRoots();
			var epsilon:Number = 1e-3;
			var norm0:Number   = ( a[0]*a[0] + 2*a[1]*a[1] + a[2]*a[2] ) * epsilon;
			var norm1:Number   = ( b[0]*b[0] + 2*b[1]*b[1] + b[2]*b[2] ) * epsilon;
			var result:Intersection  = new Intersection("No Intersection");
			
			for ( var y:int = 0; y < yRoots.length; y++ ) {
				var xPoly:Polynomial = new Polynomial(
					a[0],
					a[3] + yRoots[y] * a[1],
					a[5] + yRoots[y] * (a[4] + yRoots[y]*a[2])
				);
				var xRoots:Vector.<Number> = xPoly.getRoots();
				
				for ( var x:int = 0; x < xRoots.length; x++ ) {
					var test:Number =
						( a[0]*xRoots[x] + a[1]*yRoots[y] + a[3] ) * xRoots[x] + 
						( a[2]*yRoots[y] + a[4] ) * yRoots[y] + a[5];
					if ( Math.abs(test) < norm0 ) {
						test =
							( b[0]*xRoots[x] + b[1]*yRoots[y] + b[3] ) * xRoots[x] +
							( b[2]*yRoots[y] + b[4] ) * yRoots[y] + b[5];
						if ( Math.abs(test) < norm1 ) {
							result.appendPoint( new Vector2D( xRoots[x], yRoots[y] ) );
						}
					}
				}
			}
			
			if ( result.points.length > 0 ) result.status = "Intersection";
			
			return result;
		}
		
		/*****
		 *
		 *   bezout
		 *
		 *   This code is based on MgcIntr2DElpElp.cpp written by David Eberly.  His
		 *   code along with many other excellent examples are avaiable at his site:
		 *   http://www.magic-software.com
		 *
		 *****/
		static private function bezout(e1:Vector.<Number>, e2:Vector.<Number>):Polynomial
		{
			var AB:Number    = e1[0]*e2[1] - e2[0]*e1[1];
			var AC:Number    = e1[0]*e2[2] - e2[0]*e1[2];
			var AD:Number    = e1[0]*e2[3] - e2[0]*e1[3];
			var AE:Number    = e1[0]*e2[4] - e2[0]*e1[4];
			var AF:Number    = e1[0]*e2[5] - e2[0]*e1[5];
			var BC:Number    = e1[1]*e2[2] - e2[1]*e1[2];
			var BE:Number    = e1[1]*e2[4] - e2[1]*e1[4];
			var BF:Number    = e1[1]*e2[5] - e2[1]*e1[5];
			var CD:Number    = e1[2]*e2[3] - e2[2]*e1[3];
			var DE:Number    = e1[3]*e2[4] - e2[3]*e1[4];
			var DF:Number    = e1[3]*e2[5] - e2[3]*e1[5];
			var BFpDE:Number = BF + DE;
			var BEmCD:Number = BE - CD;
			
			return new Polynomial(
				AB*BC - AC*AC,
				AB*BEmCD + AD*BC - 2*AC*AE,
				AB*BFpDE + AD*BEmCD - AE*AE - 2*AC*AF,
				AB*DF + AD*BFpDE - 2*AE*AF,
				AD*DF - AF*AF
			);
		}

	}
}
package kaishiqi.geometric
{
	import flash.geom.Point;
	
	import kaishiqi.geometric.bezier.CubicBezier;
	import kaishiqi.geometric.bezier.LinearBezier;
	import kaishiqi.geometric.bezier.QuadraticBezier;
	import kaishiqi.geometric.intersection.Intersection;
	import kaishiqi.geometric.intersection.Vector2D;

	public function getIntersections(src:IGeometric, dest:IGeometric):Vector.<Point>
	{
		var p2v:Function = function (p:Point):Vector2D {
			return new Vector2D(p.x, p.y);
		};
		
		var v2p:Function = function (p2d:Vector2D):Point {
			return new Point(p2d.x, p2d.y);
		};
		
		// Computing Intersections Between [a Line] and [a Line].
		var l2lIntersections:Function = function (src:LinearBezier, dest:LinearBezier):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			var b1:Vector2D = p2v(dest.start);
			var b2:Vector2D = p2v(dest.end);
			return Intersection.intersectLineLine(a1, a2, b1, b2);
		};
		
		// Computing Intersections Between [a Line] and [a Quadratic Bezier Curve].
		var l2qIntersections:Function = function (src:LinearBezier, dest:QuadraticBezier):Intersection {
			var p1:Vector2D = p2v(dest.start);
			var p2:Vector2D = p2v(dest.control);
			var p3:Vector2D = p2v(dest.end);
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			return Intersection.intersectBezier2Line(p1, p2, p3, a1, a2);
		};
		
		// Computing Intersections Between [a Line] and [a Cubic Bezier Curve].
		var l2cIntersections:Function = function (src:LinearBezier, dest:CubicBezier):Intersection {
			var p1:Vector2D = p2v(dest.start);
			var p2:Vector2D = p2v(dest.startControl);
			var p3:Vector2D = p2v(dest.endControl);
			var p4:Vector2D = p2v(dest.end);
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			return Intersection.intersectBezier3Line(p1, p2, p3, p4, a1, a2);
		};
		
		// Computing Intersections Between [a Quadratic Bezier Curve] and [a Quadratic Bezier Curve].
		var q2qIntersections:Function = function (src:QuadraticBezier, dest:QuadraticBezier):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.control);
			var a3:Vector2D = p2v(src.end);
			var b1:Vector2D = p2v(dest.start);
			var b2:Vector2D = p2v(dest.control);
			var b3:Vector2D = p2v(dest.end);
			return Intersection.intersectBezier2Bezier2(a1, a2, a3, b1, b2, b3);
		};
		
		// Computing Intersections Between [a Quadratic Bezier Curve] and [a Cubic Bezier Curve].
		var q2cIntersections:Function = function (src:QuadraticBezier, dest:CubicBezier):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.control);
			var a3:Vector2D = p2v(src.end);
			var b1:Vector2D = p2v(dest.start);
			var b2:Vector2D = p2v(dest.startControl);
			var b3:Vector2D = p2v(dest.endControl);
			var b4:Vector2D = p2v(dest.end);
			return Intersection.intersectBezier2Bezier3(a1, a2, a3, b1, b2, b3, b4);
		};
		
		// Computing Intersections Between [a Cubic Bezier Curve] and [a Cubic Bezier Curve].
		var c2cIntersections:Function = function (src:CubicBezier, dest:CubicBezier):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.startControl);
			var a3:Vector2D = p2v(src.endControl);
			var a4:Vector2D = p2v(src.end);
			var b1:Vector2D = p2v(dest.start);
			var b2:Vector2D = p2v(dest.startControl);
			var b3:Vector2D = p2v(dest.endControl);
			var b4:Vector2D = p2v(dest.end);
			return Intersection.intersectBezier3Bezier3(a1, a2, a3, a4, b1, b2, b3, b4);
		};
		
		// Computing Intersections Between [a Linear Bezier Curve] and [a Ellipse].
		var l2eIntersections:Function = function (src:LinearBezier, dest:Ellipse):Intersection {
			var o:Vector2D = p2v(dest.origin);
			var rx:Number = dest.radiusX;
			var ry:Number = dest.radiusY;
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			return Intersection.intersectEllipseLine(o, rx, ry, a1, a2);
		};
		
		// Computing Intersections Between [a Linear Bezier Curve] and [a Rectangle].
		var l2rIntersections:Function = function (src:LinearBezier, dest:Rectangle):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			var r1:Vector2D = p2v(dest.start);
			var r2:Vector2D = p2v(dest.end);
			return Intersection.intersectLineRectangle(a1, a2, r1, r2);
		};
		
		// Computing Intersections Between [a Quadratic Bezier Curve] and [a Ellipse].
		var q2eIntersections:Function = function (src:QuadraticBezier, dest:Ellipse):Intersection {
			var p1:Vector2D = p2v(src.start);
			var p2:Vector2D = p2v(src.control);
			var p3:Vector2D = p2v(src.end);
			var ec:Vector2D = p2v(dest.origin);
			var rx:Number = dest.radiusX;
			var ry:Number = dest.radiusY;
			return Intersection.intersectBezier2Ellipse(p1, p2, p3, ec, rx, ry);
		};
		
		// Computing Intersections Between [a Quadratic Bezier Curve] and [a Rectangle].
		var q2rIntersections:Function = function (src:QuadraticBezier, dest:Rectangle):Intersection {
			var p1:Vector2D = p2v(src.start);
			var p2:Vector2D = p2v(src.control);
			var p3:Vector2D = p2v(src.end);
			var r1:Vector2D = p2v(dest.start);
			var r2:Vector2D = p2v(dest.end);
			return Intersection.intersectBezier2Rectangle(p1, p2, p3, r1, r2);
		};
		
		// Computing Intersections Between [a Cubic Bezier Curve] and [a Ellipse].
		var c2eIntersections:Function = function (src:CubicBezier, dest:Ellipse):Intersection {
			var p1:Vector2D = p2v(src.start);
			var p2:Vector2D = p2v(src.startControl);
			var p3:Vector2D = p2v(src.endControl);
			var p4:Vector2D = p2v(src.end);
			var ec:Vector2D = p2v(dest.origin);
			var rx:Number = dest.radiusX;
			var ry:Number = dest.radiusY;
			return Intersection.intersectBezier3Ellipse(p1, p2, p3, p4, ec, rx, ry);
		};
		
		// Computing Intersections Between [a Cubic Bezier Curve] and [a Rectangle].
		var c2rIntersections:Function = function (src:CubicBezier, dest:Rectangle):Intersection {
			var p1:Vector2D = p2v(src.start);
			var p2:Vector2D = p2v(src.startControl);
			var p3:Vector2D = p2v(src.endControl);
			var p4:Vector2D = p2v(src.end);
			var r1:Vector2D = p2v(dest.start);
			var r2:Vector2D = p2v(dest.end);
			return Intersection.intersectBezier3Rectangle(p1, p2, p3, p4, r1, r2);
		};
		
		// Computing Intersections Between [a Ellipse] and [a Ellipse].
		var e2eIntersections:Function = function (src:Ellipse, dest:Ellipse):Intersection {
			var o1:Vector2D = p2v(src.origin);
			var rx1:Number = src.radiusX;
			var ry1:Number = src.radiusY;
			var o2:Vector2D = p2v(dest.origin);
			var rx2:Number = dest.radiusX;
			var ry2:Number = dest.radiusY;
			return Intersection.intersectEllipseEllipse(o1, rx1, ry1, o2, rx2, ry2);
		};
		
		// Computing Intersections Between [a Ellipse] and [a Rectangle ].
		var e2rIntersections:Function = function (src:Ellipse, dest:Rectangle):Intersection {
			var o:Vector2D = p2v(src.origin);
			var rx:Number = src.radiusX;
			var ry:Number = src.radiusY;
			var a1:Vector2D = p2v(dest.start);
			var a2:Vector2D = p2v(dest.end);
			return Intersection.intersectEllipseRectangle(o, rx, ry, a1, a2);
		};
		
		// Computing Intersections Between [a Rectangle] and [a Rectangle].
		var r2rIntersections:Function = function (src:Rectangle, dest:Rectangle):Intersection {
			var a1:Vector2D = p2v(src.start);
			var a2:Vector2D = p2v(src.end);
			var b1:Vector2D = p2v(dest.start);
			var b2:Vector2D = p2v(dest.end);
			return Intersection.intersectRectangleRectangle(a1, a2, b1, b2);
		};
		
		
		// return result
		var result:Intersection = null;
		switch (true) {
			case src is LinearBezier:
				switch (true) {
					case dest is LinearBezier:    result = l2lIntersections(src, dest); break;
					case dest is QuadraticBezier: result = l2qIntersections(src, dest); break;
					case dest is CubicBezier:     result = l2cIntersections(src, dest); break;
					case dest is Ellipse:         result = l2eIntersections(src, dest); break;
					case dest is Rectangle:       result = l2rIntersections(src, dest); break;
				}
				break;
			
			case src is QuadraticBezier:
				switch (true) {
					case dest is LinearBezier:    result = l2qIntersections(dest, src); break;
					case dest is QuadraticBezier: result = q2qIntersections(src, dest); break;
					case dest is CubicBezier:     result = q2cIntersections(src, dest); break;
					case dest is Ellipse:         result = q2eIntersections(src, dest); break;
					case dest is Rectangle:       result = q2rIntersections(src, dest); break;
				}
				break;
			
			case src is CubicBezier:
				switch (true) {
					case dest is LinearBezier:    result = l2cIntersections(dest, src); break;
					case dest is QuadraticBezier: result = q2cIntersections(dest, src); break;
					case dest is CubicBezier:     result = c2cIntersections(src, dest); break;
					case dest is Ellipse:         result = c2eIntersections(src, dest); break;
					case dest is Rectangle:       result = c2rIntersections(src, dest); break;
				}
				break;
			
			case src is Ellipse:
				switch (true) {
					case dest is LinearBezier:    result = l2eIntersections(dest, src); break;
					case dest is QuadraticBezier: result = q2eIntersections(dest, src); break;
					case dest is CubicBezier:     result = c2eIntersections(dest, src); break;
					case dest is Ellipse:         result = e2eIntersections(src, dest); break;
					case dest is Rectangle:       result = e2rIntersections(src, dest); break;
				}
				break;
			
			case src is Rectangle:
				switch (true) {
					case dest is LinearBezier:    result = l2rIntersections(dest, src); break;
					case dest is QuadraticBezier: result = q2rIntersections(dest, src); break;
					case dest is CubicBezier:     result = c2rIntersections(dest, src); break;
					case dest is Ellipse:         result = e2rIntersections(dest, src); break;
					case dest is Rectangle:       result = r2rIntersections(src, dest); break;
				}
				break;
			
			default:
				break;
		}
		
		var intersections:Vector.<Point> = new Vector.<Point>();
		if (result) {
			for (var i:int = 0; i < result.points.length; i++) {
				intersections.push(v2p(result.points[i]));
			}
		}
		return intersections;
	}
}
AS3 Geometric Bezier
==========================

# Bezier Contain:
--------------------
1. LinearBezier
2. QuadraticBezier
3. CubicBezier

```
new LinearBezier(start:Point, end:Point);
new QuadraticBezier(start:Point, control:Point, end:Point)
new CubicBezier(start:Point, startControl:Point, endControl:Point, end:Point)
```


# Intersection Contain:
--------------------

Computing Intersections Between for a Line, Quadratic Bezier Curve, Cubic Bezier Curve, Rectangle and Ellipse.
```
/*
Computing Intersections Between [a Line] and [a Line].
Computing Intersections Between [a Line] and [a Quadratic Bezier Curve].
Computing Intersections Between [a Line] and [a Cubic Bezier Curve].
Computing Intersections Between [a Quadratic Bezier Curve] and [a Quadratic Bezier Curve].
Computing Intersections Between [a Quadratic Bezier Curve] and [a Cubic Bezier Curve].
Computing Intersections Between [a Cubic Bezier Curve] and [a Cubic Bezier Curve].
Computing Intersections Between [a Linear Bezier Curve] and [a Ellipse].
Computing Intersections Between [a Linear Bezier Curve] and [a Rectangle].
Computing Intersections Between [a Quadratic Bezier Curve] and [a Ellipse].
Computing Intersections Between [a Quadratic Bezier Curve] and [a Rectangle].
Computing Intersections Between [a Cubic Bezier Curve] and [a Ellipse].
Computing Intersections Between [a Cubic Bezier Curve] and [a Rectangle].
Computing Intersections Between [a Ellipse] and [a Ellipse].
Computing Intersections Between [a Ellipse] and [a Rectangle ].
Computing Intersections Between [a Rectangle] and [a Rectangle].
*/
getIntersections(src:IGeometric, dest:IGeometric):Vector.<Point>
```
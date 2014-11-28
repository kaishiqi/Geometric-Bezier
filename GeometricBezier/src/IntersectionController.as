package
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import kaishiqi.geometric.Ellipse;
	import kaishiqi.geometric.IGeometric;
	import kaishiqi.geometric.Rectangle;
	import kaishiqi.geometric.bezier.CubicBezier;
	import kaishiqi.geometric.bezier.IBezierCurve;
	import kaishiqi.geometric.bezier.LinearBezier;
	import kaishiqi.geometric.bezier.QuadraticBezier;

	public class IntersectionController
	{
		private var _model:IntersectionModel;
		private var _view:IntersectionView;
		
		public function IntersectionController(model:IntersectionModel, view:IntersectionView)
		{
			_model = model;
			_view = view;
		}
		
		public function alterGeometricType(type:int):void
		{
			if (_model.geometricType == type) return;
			
			// model - update
			_model.geometricType = type;
			_model.geometric = createGeometric(type);
			
			// view - hide all control dot
			for (var i:int = 0; i < _view.controlDots.length; i++)
				_view.controlDots[i].visible = false;
			
			// view - show relevant control dot
			if (_model.geometric) {
				var controlPosIndexList:Vector.<int> = getControlDotIndexList(_model.geometric);
				for each (var controlPosIndex:int in controlPosIndexList)  {
					var diff:int = controlPosIndex - _view.controlDots.length;
					for (var j:int = diff; j >= 0; j--) 
						_view.addControlDot(0, 0, false);
					_view.controlDots[controlPosIndex].visible = true;
				}
			}
			
			alterAllGeometricPos();
		}
		
		public function alterAllGeometricPos():void
		{
			// model - update geometric pos
			var i:int = 0;
			var geometricPosList:Vector.<Point> = getGeometricPosList(_model.geometric);
			var controlPosIndexList:Vector.<int> = getControlDotIndexList(_model.geometric);
			
			switch (true) {
				case _model.geometric is Rectangle:
				case _model.geometric is IBezierCurve:
					for (i = 0; i < geometricPosList.length; i++) {
						geometricPosList[i].x = _view.controlDots[controlPosIndexList[i]].x;
						geometricPosList[i].y = _view.controlDots[controlPosIndexList[i]].y;
					}
					break;
				
				case _model.geometric is Ellipse:
					var ellipse:Ellipse = _model.geometric as Ellipse;
					var ellipseOriginControlDot:Sprite = _view.controlDots[controlPosIndexList[0]];
					var ellipseRadiusControlDot:Sprite = _view.controlDots[controlPosIndexList[1]];
					ellipse.origin.x = ellipseOriginControlDot.x;
					ellipse.origin.y = ellipseOriginControlDot.y;
					ellipse.radiusX = ellipseRadiusControlDot.x - ellipseOriginControlDot.x;
					ellipse.radiusY = ellipseRadiusControlDot.y - ellipseOriginControlDot.y;
					break;
				
				default:
					break;
			}
			
			updateGeometricShape();
		}
		
		public function updateGeometricShape():void
		{
			_view.geometricShape.graphics.clear();
			if (_model.geometric) {
				var i:int = 0;
				
				// draw geometric
				_view.geometricShape.graphics.lineStyle(2, _view.geometricShapeColor);
				_model.geometric.draw(_view.geometricShape.graphics);
				
				// draw control line
				_view.geometricShape.graphics.lineStyle(2, 0x000000, 0.05);
				var controlPosIndexList:Vector.<int> = getControlDotIndexList(_model.geometric);
				switch (true) {
					
					case _model.geometric is IBezierCurve:
						if (2 < controlPosIndexList.length) {
							for (i = 0; i < controlPosIndexList.length; i++) {
								var bezierControlDot:Sprite = _view.controlDots[controlPosIndexList[i]];
								(0 == i) ?
									_view.geometricShape.graphics.moveTo(bezierControlDot.x, bezierControlDot.y) :
									_view.geometricShape.graphics.lineTo(bezierControlDot.x, bezierControlDot.y);
							}
						}
						break;
					
					case _model.geometric is Ellipse:
						var ellipse:Ellipse = _model.geometric as Ellipse;
						var ellipseOriginControlDot:Sprite = _view.controlDots[controlPosIndexList[0]];
						_view.geometricShape.graphics.drawRect(
							ellipseOriginControlDot.x - ellipse.radiusX, 
							ellipseOriginControlDot.y - ellipse.radiusY, 
							ellipse.radiusX*2, ellipse.radiusY*2);
						break;
					
					default:
						break;
				}
			}
		}
		
		private function createGeometric(type:int):IGeometric
		{
			var geometric:IGeometric = null;
			switch (type) {
				case IntersectionModel.TYPE_BEZIER_LINE:
					geometric = new LinearBezier();
					break;
				case IntersectionModel.TYPE_BEZIER_QUADRATIC:
					geometric = new QuadraticBezier();
					break;
				case IntersectionModel.TYPE_BEZIER_CUBIC:
					geometric = new CubicBezier();
					break;
				case IntersectionModel.TYPE_ELLIPSE:
					geometric = new Ellipse();
					break;
				case IntersectionModel.TYPE_RECT:
					geometric = new Rectangle();
					break;
				default:
					break;
			}
			return geometric;
		}
		
		private function getControlDotIndexList(geometric:IGeometric):Vector.<int>
		{
			var dotIntdexList:Vector.<int> = new Vector.<int>();
			switch (true) {
				case geometric is LinearBezier:
					dotIntdexList.push(0, 3);
					break;
				case geometric is QuadraticBezier:
					dotIntdexList.push(0, 1, 3);
					break;
				case geometric is CubicBezier:
					dotIntdexList.push(0, 1, 2, 3);
					break;
				case geometric is Ellipse:
					dotIntdexList.push(1, 2);
					break;
				case geometric is Rectangle:
					dotIntdexList.push(1, 2);
					break;
				default:
					break;
			}
			return dotIntdexList;
		}
		
		private function getGeometricPosList(geometric:IGeometric):Vector.<Point>
		{
			var posList:Vector.<Point> = new Vector.<Point>();
			switch (true) {
				case geometric is LinearBezier:
					var lb:LinearBezier = geometric as LinearBezier;
					posList.push(lb.start, lb.end);
					break;
				case geometric is QuadraticBezier:
					var qb:QuadraticBezier = geometric as QuadraticBezier;
					posList.push(qb.start, qb.control, qb.end);
					break;
				case geometric is CubicBezier:
					var cb:CubicBezier = geometric as CubicBezier;
					posList.push(cb.start, cb.startControl, cb.endControl, cb.end);
					break;
				case geometric is Rectangle:
					var rect:Rectangle = geometric as Rectangle;
					posList.push(rect.start, rect.end);
					break;
				default:
					break;
			}
			return posList;
		}
		
	}
}
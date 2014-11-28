package
{
	import flash.geom.Point;
	
	import kaishiqi.geometric.bezier.CubicBezier;
	import kaishiqi.geometric.bezier.IBezierCurve;
	import kaishiqi.geometric.bezier.LinearBezier;
	import kaishiqi.geometric.bezier.QuadraticBezier;

	public class BezierCurveController
	{
		private var _model:IBezierCurve;
		private var _view:BezierCurveView;
		private var _selectedDotIndex:int;
		private var animationStartDistance:Number;
		private var cellSpeed:int;
		
		public function BezierCurveController(model:IBezierCurve, view:BezierCurveView)
		{
			_model = model;
			_view = view;
			_selectedDotIndex = -1;
			animationStartDistance = 0;
			cellSpeed = 1;
		}
		
		public function get selectedDotIndex():int { return _selectedDotIndex; }
		public function set selectedDotIndex(value:int):void { _selectedDotIndex = value; }
		
		public function getSelectedDotPos():Point 
		{
			var selectedPos:Point = null;
			switch (true) {
				case _model is LinearBezier:
					var lModel:LinearBezier = _model as LinearBezier;
					switch (selectedDotIndex) {
						case 0: selectedPos = lModel.start; break;
						case 1: selectedPos = lModel.end; break;
					}
					break;
				case _model is QuadraticBezier: 
					var qModel:QuadraticBezier = _model as QuadraticBezier;
					switch (selectedDotIndex) {
						case 0: selectedPos = qModel.start; break;
						case 1: selectedPos = qModel.control; break;
						case 2: selectedPos = qModel.end; break;
					}
					break;
				case _model is CubicBezier:
					var cModel:CubicBezier = _model as CubicBezier;
					switch (selectedDotIndex) {
						case 0: selectedPos = cModel.start; break;
						case 1: selectedPos = cModel.startControl; break;
						case 2: selectedPos = cModel.endControl; break;
						case 3: selectedPos = cModel.end; break;
					}
					break;
			}
			return selectedPos;
		}

		public function alterSelectedDotPos(targetX:int, targetY:int):void
		{
			if (!_model) return;
			
			var selectedPos:Point = getSelectedDotPos();
			if (selectedPos) {
				selectedPos.x = targetX;
				selectedPos.y = targetY;
			}
			
			this.updateView();
		}
		
		public function updateView():void
		{
			if (!_view || !_model) return;
			var i:int = 0;
			
			// get model data
			var posList:Vector.<Point> = new Vector.<Point>();
			switch (true) {
				case _model is LinearBezier:
					var lModel:LinearBezier = _model as LinearBezier;
					posList.push(lModel.start, lModel.end);
					break;
				case _model is QuadraticBezier: 
					var qModel:QuadraticBezier = _model as QuadraticBezier;
					posList.push(qModel.start, qModel.control, qModel.end);
					break;
				case _model is CubicBezier:
					var cModel:CubicBezier = _model as CubicBezier;
					posList.push(cModel.start, cModel.startControl, cModel.endControl, cModel.end);
					break;
			}
			
			//update length label
			_view.arcLengthLabel.text = "Length: " + _model.length;
			
			// update control curve shape
			_view.controlCurve.graphics.clear();
			_view.controlCurve.graphics.lineStyle(2, 0xFF0000);
			_model.draw(_view.controlCurve.graphics, 10);
			
			_view.controlCurve.graphics.lineStyle(2, 0x000000, 0.1);
			_view.controlCurve.graphics.moveTo(posList[0].x, posList[0].y);
			if (2 < posList.length)
				for (i = 1; i < posList.length; i++)
					_view.controlCurve.graphics.lineTo(posList[i].x, posList[i].y);
			
			// update dot view and dot label
			for (i = 0; i < posList.length; i++) {
				_view.dotViews[i].x = posList[i].x;
				_view.dotViews[i].y = posList[i].y;
				_view.dotLabels[i].x = _view.dotViews[i].x + 6;
				_view.dotLabels[i].y = _view.dotViews[i].y + 6;
				_view.dotLabels[i].text = "P" + i + " (" + posList[i].x + ", " + posList[i].y + ")";
			}
			
			// update animation curve shape
			_view.animationCurve.graphics.clear();
			_view.animationCurve.graphics.lineStyle(2, 0xFFCC00);
			_model.draw(_view.animationCurve.graphics);
		}
		
		public function updateAnimation():void
		{
			if (!_view || !_model) return;
			var i:int = 0;
			
			// update start dist
			var totalDistance:Number = _model.length;
			animationStartDistance += cellSpeed;
			if (animationStartDistance > totalDistance)
				animationStartDistance -= totalDistance;
			
			// update animation cells
			var cellNum:int = _view.animationCells.length;
			var cellGap:Number = _model.length / cellNum;
			for (i = 0; i < cellNum; i++) {
				var cellDist:Number = cellGap * i + animationStartDistance;
				if (cellDist > totalDistance)
					cellDist -= totalDistance;
				var cellTime:Number = _model.getTimeByDistance(cellDist);
				var cellPos:Point = _model.getPoint(cellTime);
				var cellAngle:Number = _model.getTangentAngle(cellTime);
				_view.animationCells[i].x = cellPos.x;
				_view.animationCells[i].y = cellPos.y;
				_view.animationCells[i].rotation = 90 + cellAngle * 180 / Math.PI;
			}
		}
		
	}
}
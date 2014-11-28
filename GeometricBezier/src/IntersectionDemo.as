package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import kaishiqi.geometric.getIntersections;
	
	[SWF (width=800, height=600, backgroundColor='0xEAEAEA', frameRate=30)]
	public class IntersectionDemo extends Sprite
	{
		private var _srcModel:IntersectionModel;
		private var _destModel:IntersectionModel;
		private var _srcView:IntersectionView;
		private var _destView:IntersectionView;
		private var _srcController:IntersectionController;
		private var _destController:IntersectionController;
		private var _dragStartPos:Point;
		private var _intersectionShape:Shape;
		
		public function IntersectionDemo()
		{
			var configObj:Object = new Object();
			configObj["layout_src_type_bar_pos"]   = [30, 20];
			configObj["layout_dest_type_bar_pos"]  = [30, 50];
			configObj["layout_type_btn_gap"]  = 120;
			configObj["init_src_pos0"]  = [35, 410];
			configObj["init_src_pos1"]  = [225, 170];
			configObj["init_src_pos2"]  = [615, 550];
			configObj["init_src_pos3"]  = [745, 280];
			configObj["init_dest_pos0"] = [35, 330];
			configObj["init_dest_pos1"] = [275, 580];
			configObj["init_dest_pos2"] = [485, 80];
			configObj["init_dest_pos3"] = [755, 420];
			configObj["default_src_type"]  = IntersectionModel.TYPE_BEZIER_LINE;
			configObj["default_dest_type"] = IntersectionModel.TYPE_BEZIER_CUBIC;
			init(configObj);
		}
		
		private function init(configObj:Object):void
		{
			_dragStartPos = new Point();
			
			var typeDict:Dictionary = new Dictionary();
			typeDict["Rectangle"]        = IntersectionModel.TYPE_RECT;
			typeDict["Ellipse"]          = IntersectionModel.TYPE_ELLIPSE;
			typeDict["Linear Bezier"]    = IntersectionModel.TYPE_BEZIER_LINE;
			typeDict["Quadratic Bezier"] = IntersectionModel.TYPE_BEZIER_QUADRATIC;
			typeDict["Cubic Bezier"]     = IntersectionModel.TYPE_BEZIER_CUBIC;
			
			// model
			_srcModel = new IntersectionModel();
			_destModel = new IntersectionModel();
			
			// view 
			_srcView = new IntersectionView("Src  Geometric Type:");
			_destView = new IntersectionView("Dest  Geometric Type:");
			_srcView.colorType = IntersectionView.COLOR_TYPE_RED;
			_srcView.colorType = IntersectionView.COLOR_TYPE_BLUE;
			_srcView.typeBtnGap = configObj["layout_type_btn_gap"];
			_destView.typeBtnGap = configObj["layout_type_btn_gap"];
			_srcView.typeBar.x = configObj["layout_src_type_bar_pos"][0];
			_srcView.typeBar.y = configObj["layout_src_type_bar_pos"][1];
			_destView.typeBar.x = configObj["layout_dest_type_bar_pos"][0];
			_destView.typeBar.y = configObj["layout_dest_type_bar_pos"][1];
			this.addChild(_srcView);
			this.addChild(_destView);
			
			_intersectionShape = new Shape();
			this.addChild(_intersectionShape);
			
			// controller
			_srcController = new IntersectionController(_srcModel, _srcView);
			_destController = new IntersectionController(_destModel, _destView);
			
			// delegate
			_srcView.callbackOnClickTypeBtn = function (index:int):void {
				var btnName:String = _srcView.typeBtns[index].text;
				if (null != typeDict[btnName])
					_srcController.alterGeometricType(typeDict[btnName]);
				updateIntersection();
			};
			
			_destView.callbackOnClickTypeBtn = function (index:int):void {
				var btnName:String = _destView.typeBtns[index].text;
				if (null != typeDict[btnName])
					_destController.alterGeometricType(typeDict[btnName]);
				updateIntersection();
			};
			
			_srcView.callbackOnSelectedControlDot = function ():void {
				_dragStartPos.x = stage.mouseX - _srcView.selectedControlDot.x;
				_dragStartPos.y = stage.mouseY - _srcView.selectedControlDot.y;
			};
			
			_destView.callbackOnSelectedControlDot = function ():void {
				_dragStartPos.x = stage.mouseX - _destView.selectedControlDot.x;
				_dragStartPos.y = stage.mouseY - _destView.selectedControlDot.y;
			};
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			
			
			/**
			 * initialization
			 * */
			
			var defaultSrcType:int = configObj["default_src_type"];
			var defaultDestType:int = configObj["default_dest_type"];
			
			// view - add type btn
			for (var key:String in typeDict)  {
				_srcView.addTypeBtn(key, defaultSrcType == typeDict[key]);
				_destView.addTypeBtn(key, defaultDestType == typeDict[key]);
			}
			
			// view - init default control dots
			var dotNum:int = 4;
			for (var i:int = 0; i < dotNum; i++) {
				_srcView.addControlDot(configObj["init_src_pos"+i][0], configObj["init_src_pos"+i][1], false);
				_destView.addControlDot(configObj["init_dest_pos"+i][0], configObj["init_dest_pos"+i][1], false);
			}
			
			// controller - init default value
			_srcController.alterGeometricType(defaultSrcType);
			_destController.alterGeometricType(defaultDestType);
			
			updateIntersection();
		}
		
		protected function stageMouseUpHandler(event:MouseEvent):void
		{
			_srcView.selectedControlDot = null;
			_destView.selectedControlDot = null;
		}
		
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			if (_srcView.selectedControlDot) {
				_srcView.selectedControlDot.x = stage.mouseX - _dragStartPos.x;
				_srcView.selectedControlDot.y = stage.mouseY - _dragStartPos.y;
				_srcController.alterAllGeometricPos();
			}
			
			if (_destView.selectedControlDot) {
				_destView.selectedControlDot.x = stage.mouseX - _dragStartPos.x;
				_destView.selectedControlDot.y = stage.mouseY - _dragStartPos.y;
				_destController.alterAllGeometricPos();
			}
			
			if (_srcView.selectedControlDot || _destView.selectedControlDot) {
				updateIntersection();
			}
		}
		
		private function updateIntersection():void
		{
			_intersectionShape.graphics.clear();
			if (_srcModel.geometric && _destModel.geometric) {
				var intersections:Vector.<Point> = getIntersections(_srcModel.geometric, _destModel.geometric);
				for (var i:int = 0; i < intersections.length; i++) {
					var intersectionPos:Point = intersections[i];
					_intersectionShape.graphics.lineStyle(0, 0xFFFFFF, 0.75);
					_intersectionShape.graphics.beginFill(0xFFFFFF, 0.75);
					_intersectionShape.graphics.drawCircle(intersectionPos.x, intersectionPos.y, 6);
					_intersectionShape.graphics.endFill();
					_intersectionShape.graphics.lineStyle(1, 0xFF00FF);
					_intersectionShape.graphics.drawCircle(intersectionPos.x, intersectionPos.y, 6);
					_intersectionShape.graphics.moveTo(intersectionPos.x-4, intersectionPos.y-4);
					_intersectionShape.graphics.lineTo(intersectionPos.x+4, intersectionPos.y+4);
					_intersectionShape.graphics.moveTo(intersectionPos.x-4, intersectionPos.y+4);
					_intersectionShape.graphics.lineTo(intersectionPos.x+4, intersectionPos.y-4);
				}
			}
		}
		
	}
}
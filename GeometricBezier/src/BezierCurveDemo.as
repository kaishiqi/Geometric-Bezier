package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import kaishiqi.geometric.bezier.CubicBezier;
	import kaishiqi.geometric.bezier.LinearBezier;
	import kaishiqi.geometric.bezier.QuadraticBezier;
	
	[SWF (width=800, height=600, backgroundColor='0xEAEAEA', frameRate=30)]
	public class BezierCurveDemo extends Sprite
	{
		private var _linearBezierController:BezierCurveController;
		private var _quadraticBezierController:BezierCurveController;
		private var _cubicBezierController:BezierCurveController;
		private var _selectedController:BezierCurveController;
		private var _dragStartPos:Point;
		
		public function BezierCurveDemo()
		{
			var configObj:Object = new Object();
			configObj["layout_title_Y"] = 10;
			configObj["layout_view_Y"]  = 50;
			configObj["init_pos0"] = [100, 160];
			configObj["init_pos1"] = [15, 200];
			configObj["init_pos2"] = [200, 260];
			configObj["init_pos3"] = [200, 40];
			this.init(configObj);
		}
		
		private function init(configObj:Object):void
		{
			_dragStartPos = new Point();
			
			var demoWGap:int = stage.stageWidth/3;
			this.graphics.lineStyle(2, 0x999999);
			this.graphics.moveTo(demoWGap, 0);
			this.graphics.lineTo(demoWGap, stage.stageHeight);
			this.graphics.moveTo(demoWGap*2, 0);
			this.graphics.lineTo(demoWGap*2, stage.stageHeight);
			
			// title
			var titleY:int = configObj["layout_title_Y"];
			this.addChild(this.createTitleTF(demoWGap*0.5, titleY, "Linear Bezier"));
			this.addChild(this.createTitleTF(demoWGap*1.5, titleY, "Quadratic Bezier"));
			this.addChild(this.createTitleTF(demoWGap*2.5, titleY, "Cubic Bezier"));
			
			// model
			var p0:Point = new Point(configObj["init_pos0"][0], configObj["init_pos0"][1]);
			var p1:Point = new Point(configObj["init_pos1"][0], configObj["init_pos1"][1]);
			var p2:Point = new Point(configObj["init_pos2"][0], configObj["init_pos2"][1]);
			var p3:Point = new Point(configObj["init_pos3"][0], configObj["init_pos3"][1]);
			var linearBezierModel:LinearBezier       = new LinearBezier(p0.clone(), p3.clone());
			var quadraticBezierModel:QuadraticBezier = new QuadraticBezier(p0.clone(), p1.clone(), p3.clone());
			var cubicBezierModel:CubicBezier         = new CubicBezier(p0.clone(), p1.clone(), p2.clone(), p3.clone());
			
			// view
			var viewY:int = configObj["layout_view_Y"];
			var linearBezierView:BezierCurveView    = new BezierCurveView(2);
			var quadraticBezierView:BezierCurveView = new BezierCurveView(3);
			var cubicBezierView:BezierCurveView     = new BezierCurveView(4);
			cubicBezierView.x = demoWGap + (quadraticBezierView.x = demoWGap + linearBezierView.x);
			cubicBezierView.y = quadraticBezierView.y = linearBezierView.y = viewY;
			this.addChild(linearBezierView);
			this.addChild(quadraticBezierView);
			this.addChild(cubicBezierView);
			
			// controller
			_linearBezierController    = new BezierCurveController(linearBezierModel, linearBezierView);
			_quadraticBezierController = new BezierCurveController(quadraticBezierModel, quadraticBezierView);
			_cubicBezierController     = new BezierCurveController(cubicBezierModel, cubicBezierView);
			_linearBezierController.updateView();
			_quadraticBezierController.updateView();
			_cubicBezierController.updateView();
			
			// delegate
			var selectedViewDotHandler:Function = function(dotIndex:int):void {
				if (_selectedController) {
					_selectedController.selectedDotIndex = dotIndex;
					_dragStartPos.x = stage.mouseX - _selectedController.getSelectedDotPos().x;
					_dragStartPos.y = stage.mouseY - _selectedController.getSelectedDotPos().y;
				}
			};
			
			linearBezierView.callbackOnDotDown = function(dotIndex:int):void {
				_selectedController = _linearBezierController;
				selectedViewDotHandler(dotIndex);
			};
			quadraticBezierView.callbackOnDotDown = function(dotIndex:int):void {
				_selectedController = _quadraticBezierController;
				selectedViewDotHandler(dotIndex);
			};
			cubicBezierView.callbackOnDotDown = function(dotIndex:int):void {
				_selectedController = _cubicBezierController;
				selectedViewDotHandler(dotIndex);
			};
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			this.addEventListener(Event.ENTER_FRAME, updateHandler);
		}
		
		private function createTitleTF(x:int, y:int, text:String):TextField
		{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("", 32);
			tf.mouseEnabled = false;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.text = text;
			tf.x = x - tf.width/2;
			tf.y = y;
			return tf;
		}
		
		protected function stageMouseUpHandler(event:MouseEvent):void
		{
			_selectedController = null;
		}
		
		protected function stageMouseMoveHandler(event:MouseEvent):void
		{
			if (_selectedController) {
				var dotTargetX:Number = stage.mouseX - _dragStartPos.x;
				var dotTargetY:Number = stage.mouseY - _dragStartPos.y;
				_selectedController.alterSelectedDotPos(dotTargetX, dotTargetY);
			}
		}
		
		protected function updateHandler(event:Event):void
		{
			_linearBezierController.updateAnimation();
			_quadraticBezierController.updateAnimation();
			_cubicBezierController.updateAnimation();
		}
		
	}
}

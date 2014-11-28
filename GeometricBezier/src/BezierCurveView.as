package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class BezierCurveView extends Sprite
	{
		public var controlCurve:Shape;
		public var animationCurve:Shape;
		public var arcLengthLabel:TextField;
		public var dotViews:Vector.<Sprite>;
		public var dotLabels:Vector.<TextField>;
		public var animationCells:Vector.<Shape>;
		private var _controlContainer:Sprite;
		private var _animationContainer:Sprite;
		private var _callbackOnDotDown:Function;

		public function BezierCurveView(dotNum:int)
		{
			init(dotNum);
		}
		
		public function get callbackOnDotDown():Function { return _callbackOnDotDown; }
		public function set callbackOnDotDown(value:Function):void { _callbackOnDotDown = value; }
		
		private function init(dotNum:int):void
		{
			var i:int = 0;
			
			// arc length label
			
			arcLengthLabel = new TextField();
			arcLengthLabel.mouseEnabled = false;
			arcLengthLabel.autoSize = TextFieldAutoSize.CENTER;
			arcLengthLabel.textColor = 0xFFFFFF;
			arcLengthLabel.background = true;
			arcLengthLabel.backgroundColor = 0x999999;
			arcLengthLabel.x = 140;
			arcLengthLabel.y = 10;
			this.addChild(arcLengthLabel);
			
			// control content
			
			_controlContainer = new Sprite();
			_controlContainer.y = 10;
			this.addChild(_controlContainer);
			
			controlCurve = new Shape();
			_controlContainer.addChild(controlCurve);
			
			dotViews = new Vector.<Sprite>(dotNum);
			dotLabels = new Vector.<TextField>(dotNum);
			for (i = 0; i < dotNum; i++) {
				
				dotLabels[i] = createDotLable();
				_controlContainer.addChild(dotLabels[i]);
				
				dotViews[i] = createDotView();
				_controlContainer.addChild(dotViews[i]);
			}
			
			// animation content
			
			_animationContainer = new Sprite();
			_animationContainer.y = 300;
			_animationContainer.mouseEnabled = false;
			_animationContainer.mouseChildren = false;
			this.addChild(_animationContainer);
			
			animationCurve = new Shape();
			_animationContainer.addChild(animationCurve);
			
			var animationCellNum:int = 4;
			animationCells = new Vector.<Shape>(animationCellNum);
			while (animationCellNum--) {
				animationCells[animationCellNum] = createAnimationCell(10);
				_animationContainer.addChild(animationCells[animationCellNum]);
			}
			
			// listener
			
			_controlContainer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function createDotView():Sprite
		{
			var dotView:Sprite = new Sprite();
			dotView.graphics.lineStyle(1, 0x008800);
			dotView.graphics.beginFill(0x00FFCC);
			dotView.graphics.drawCircle(0, 0, 6);
			dotView.graphics.moveTo(-3, 0);
			dotView.graphics.lineTo(3, 0);
			dotView.graphics.moveTo(0, -3);
			dotView.graphics.lineTo(0, 3);
			dotView.buttonMode = true;
			return dotView;
		}
		
		private function createDotLable():TextField
		{
			var dotLabel:TextField = new TextField();
			dotLabel.mouseEnabled = false;
			dotLabel.background = true;
			dotLabel.selectable = false;
			dotLabel.backgroundColor = 0xCCCCCC;
			dotLabel.autoSize = TextFieldAutoSize.LEFT;
			return dotLabel;
		}
		
		private function createAnimationCell(size:int):Shape
		{
			var cell:Shape = new Shape();
			cell.graphics.beginFill(0x336699);
			cell.graphics.drawTriangles(Vector.<Number>([
				0,-size/2,
				size,size/2,
				-size, size/2
			]));
			return cell;
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			for (var i:int = 0; i < dotViews.length; i++) {
				if (dotViews[i] == event.target) {
					if (callbackOnDotDown)
						callbackOnDotDown(i);
					break;
				}
			}
		}
		
	}
}

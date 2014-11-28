package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class IntersectionView extends Sprite
	{
		private static const BTN_TF_SELECTED_BG_COLOR:uint = 0x666666;
		private static const BTN_TF_SELECTED_TEXT_COLOR:uint = 0xFFFFFF;
		private static const BTN_TF_UNSELECTED_BG_COLOR:uint = 0xCCCCCC;
		private static const BTN_TF_UNSELECTED_TEXT_COLOR:uint = 0x666666;
		public static const COLOR_TYPE_RED:int = 0;
		public static const COLOR_TYPE_BLUE:int = 1;
		
		private var _typeBtnContainer:Sprite;
		private var _controlDotContainer:Sprite;
		public var typeBar:Sprite;
		public var geometricShape:Shape;
		public var typeBtns:Vector.<TextField>;
		public var controlDots:Vector.<Sprite>;
		public var callbackOnClickTypeBtn:Function;
		public var callbackOnSelectedControlDot:Function;
		
		public function IntersectionView(typeBarName:String)
		{
			init(typeBarName);
		}
		
		private var _colorType:int;
		public function get colorType():int { return _colorType; }
		public function set colorType(value:int):void { _colorType = value; }
		
		private var _typeBtnGap:int;
		public function get typeBtnGap():int { return _typeBtnGap; }
		public function set typeBtnGap(value:int):void { _typeBtnGap = value; }
		
		private var _selectedControlDot:Sprite;
		public function get selectedControlDot():Sprite { return _selectedControlDot; }
		public function set selectedControlDot(value:Sprite):void { _selectedControlDot = value; };
		
		private var _selectedTypeBtnIndex:int;
		public function get selectedTypeBtnIndex():int { return _selectedTypeBtnIndex; }
		public function set selectedTypeBtnIndex(value:int):void
		{
			if (0 <= _selectedTypeBtnIndex && typeBtns.length > _selectedTypeBtnIndex)
				switchTypeBtnState(typeBtns[_selectedTypeBtnIndex], false);
			_selectedTypeBtnIndex = value;
			if (0 <= _selectedTypeBtnIndex && typeBtns.length > _selectedTypeBtnIndex)
				switchTypeBtnState(typeBtns[_selectedTypeBtnIndex], true);
		}
		
		public function get geometricShapeColor():uint
		{
			var color:uint = 0x000000;
			switch (colorType) {
				case COLOR_TYPE_RED:  color = 0xFF0000; break;
				case COLOR_TYPE_BLUE: color = 0x0000FF; break;
			}
			return color;
		}
		
		public function get controlDotColor():uint
		{
			var color:uint = 0x000000;
			switch (colorType) {
				case COLOR_TYPE_RED:  color = 0x990000; break;
				case COLOR_TYPE_BLUE: color = 0x000099; break;
			}
			return color;
		}
		
		private function init(typeBarName:String):void
		{
			_selectedTypeBtnIndex = -1;
			typeBtns = new Vector.<TextField>();
			controlDots = new Vector.<Sprite>();
			
			// type bar
			typeBar = new Sprite();
			this.addChild(typeBar);
			
			// type bar - label
			typeBar.addChild(createBarLabelTF(typeBarName));
			
			// type btn - container
			_typeBtnContainer = new Sprite();
			_typeBtnContainer.x = 160;
			typeBar.addChild(_typeBtnContainer);
			
			// geometric shape
			geometricShape = new Shape();
			this.addChild(geometricShape);
			
			// control dot container
			_controlDotContainer = new Sprite();
			this.addChild(_controlDotContainer);
			
			// listeners
			_typeBtnContainer.addEventListener(MouseEvent.CLICK, clickTypeBtnHandler);
			_controlDotContainer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownControlDotHandler);
		}
		
		private function createBarLabelTF(text:String):TextField
		{
			var labelTF:TextField = new TextField();
			labelTF.autoSize = TextFieldAutoSize.LEFT;
			labelTF.textColor = 0x999999;
			labelTF.text = text;
			return labelTF;
		}
		
		private function createTypeBtnTF(x:int, y:int, text:String):TextField
		{
			var btnFormat:TextFormat = new TextFormat();
			btnFormat.align = TextFormatAlign.CENTER;
			var btnTF:TextField = new TextField();
			btnTF.defaultTextFormat = btnFormat;
			btnTF.text = text;
			btnTF.border = true;
			btnTF.selectable = false;
			btnTF.background = true;
			btnTF.borderColor = 0x999999;
			btnTF.height = 16;
			btnTF.width = 100;
			btnTF.x = x;
			btnTF.y = y;
			switchTypeBtnState(btnTF, false);
			return btnTF;
		}
		
		private function createControlDot(x:int, y:int, color:uint):Sprite
		{
			var dot:Sprite = new Sprite();
			dot.graphics.lineStyle(1, 0xFFFFFF);
			dot.graphics.beginFill(color);
			dot.graphics.drawCircle(0, 0, 6);
			dot.graphics.endFill();
			dot.graphics.lineStyle(1, 0xFFFFFF);
			dot.graphics.drawCircle(0, 0, 4);
			dot.buttonMode = true;
			dot.x = x;
			dot.y = y;
			return dot;
		}
		
		private function switchTypeBtnState(typeBtn:TextField, isSelected:Boolean):void
		{
			if (!typeBtn) return;
			
			if (isSelected) {
				typeBtn.textColor = BTN_TF_SELECTED_TEXT_COLOR;
				typeBtn.backgroundColor = BTN_TF_SELECTED_BG_COLOR;
			} else {
				typeBtn.textColor = BTN_TF_UNSELECTED_TEXT_COLOR;
				typeBtn.backgroundColor = BTN_TF_UNSELECTED_BG_COLOR;
			}
		}
		
		public function addTypeBtn(text:String, selected:Boolean):void
		{
			var typeBtn:TextField = createTypeBtnTF(typeBtns.length * typeBtnGap, 0, text);
			_typeBtnContainer.addChild(typeBtn);
			typeBtns.push(typeBtn);
			
			if (selected) {
				selectedTypeBtnIndex = typeBtns.length - 1;
			}
		}
		
		public function addControlDot(x:Number, y:Number, visible:Boolean = true):void
		{
			var controlDot:Sprite = createControlDot(x, y, this.controlDotColor);
			controlDot.visible = visible;
			_controlDotContainer.addChild(controlDot);
			controlDots.push(controlDot);
		}
		
		protected function clickTypeBtnHandler(event:MouseEvent):void
		{
			var clickTypeBtn:TextField = event.target as TextField;
			for (var i:int = 0; i < typeBtns.length; i++)  {
				if (clickTypeBtn == typeBtns[i]) {
					selectedTypeBtnIndex = i;
					if (callbackOnClickTypeBtn)
						callbackOnClickTypeBtn(i);
					break;
				}
			}
		}
		
		protected function mouseDownControlDotHandler(event:MouseEvent):void
		{
			var controlDot:Sprite = event.target as Sprite;
			selectedControlDot = controlDot;
			
			if (callbackOnSelectedControlDot)
				callbackOnSelectedControlDot();
		}
		
	}
}
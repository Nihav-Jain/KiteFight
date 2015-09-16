package org.fiea.rpp.tools 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class WeaponCreationTool extends Sprite 
	{
		
		private var grid:Grid;
		private var sidePanel:SidePanel;
		private var weaponBodySprite:Sprite;
		private var weaponImageSprite:Sprite;
		private var vertices:Vector.<Point>;
		private var isDrawing:Boolean;
		private var polygonMade:Boolean;
		private var dragging:Boolean;
		private var imageLoaded:Boolean;
		private var lockImage:Boolean;
		private var justDragged:Boolean;
		
		private var distX:Number;
		private var distY:Number;
		
		private var testFunction:Function;
		
		private var fileReference:FileReference;
		
		public static var STAGE:Stage;
		private static const RATIO:Number = 40;
		
		public function WeaponCreationTool(_stage:Stage, testFunc:Function) 
		{
			super();
			
			grid = new Grid(1200, 900, 20, 20);
			this.addChild(grid);
			
			weaponImageSprite = new Sprite();
			this.addChild(weaponImageSprite);
			weaponBodySprite = new Sprite();
			this.addChild(weaponBodySprite);
			
			sidePanel = new SidePanel();
			sidePanel.x = 1200;
			sidePanel.y = 0;
			this.addChild(sidePanel);
			sidePanel.snapToggle.buttonMode = true;
			sidePanel.snapToggle.snapStatus.text = "ON";
			sidePanel.lockImageButton.snapStatus.text = "OFF";
			
			vertices = new Vector.<Point>();
			isDrawing = false;
			polygonMade = false;
			dragging = false;
			imageLoaded = false;
			lockImage = false;
			justDragged = false;
			
			STAGE = _stage;
			testFunction = testFunc;
			
			this.addListeners();
		}
		
		private function testClicked(e:MouseEvent):void 
		{			
			var xml:XML = this.getXml();
			if (xml != null)
			{
				this.removeListeners();
				testFunction.call(null, xml);
			}
		}

		private function gridClicked(e:MouseEvent):void 
		{
			if (polygonMade)
				return;
			if (mouseX < 1200)
			{
				if (!justDragged)
				{
					trace("click");	
					var clickedPoint = new Point(grid.crosshairX, grid.crosshairY);
					var i:int;
					for (i = 0; i < vertices.length; i++)
					{
						if (clickedPoint.x == vertices[i].x && clickedPoint.y == vertices[i].y)
						{
							vertices.push(clickedPoint);
							isDrawing = false;
							polygonMade = true;
							break;
						}
					}
					if(i == vertices.length)
					{
						vertices.push(clickedPoint);
						isDrawing = true;
					}
				}
			}
		}
		
		private function getXmlClicked(e:MouseEvent):void 
		{
			var xml:XML = this.getXml();
			if(xml != null)
				sidePanel.status.text = "Please copy the following xml and append it to the <weapons> tag in game-config.xml - \n\n" + xml.toString();
		}
		
		private function getXml():XML
		{
			if (!polygonMade)
			{
				sidePanel.status.text = "Please draw a polygon first";
				return null;
			}
			var numLinks:int = parseInt(sidePanel.numLinks.text);
			var linkLength:int = parseInt(sidePanel.linkLength.text);
			var linkWidth:int = parseInt(sidePanel.linkWidth.text);
			if (numLinks <= 0)
			{
				sidePanel.status.text = "Please enter a valid positive integer value for number of links";
				return null;
			}
			if (linkLength <= 0)
			{
				sidePanel.status.text = "Please enter a valid positive integer value for length of links";
				return null;
			}
			if (linkWidth <= 0)
			{
				sidePanel.status.text = "Please enter a valid positive integer value for width of links";
				return null;
			}
			var density:Number = parseFloat(sidePanel.density.text);
			if (isNaN(density) || density <= 0)
			{
				sidePanel.status.text = "Please enter a valid positive value for weight of weapon";
				return null;
			}
			
			var xml:XML = <weapon /> ;
			xml.appendChild(<rope/>);
			xml.rope.@links = "" + numLinks;
			xml.rope.@linkLength = "" + (linkLength / RATIO);
			xml.rope.@linkWidth = "" + (linkWidth / RATIO);
			var verticesNode:XML = <vertices />
			for (var i:int = 0; i < vertices.length-1; i++)
			{
				var vx:Number = (vertices[i].x - 600) / 2;
				var vy:Number = (vertices[i].y - 450) / 2;
				verticesNode.appendChild(<vertex x={vx} y={vy} />);
			}
			xml.appendChild(verticesNode);
			var physPropsNode:XML = <physicalProperties />;
			physPropsNode.appendChild(<friction>0.5</friction>);
			physPropsNode.appendChild(<restitution>1</restitution>);
			physPropsNode.appendChild(<density>{density}</density>);
			xml.appendChild(physPropsNode);
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, xml.toString(), false);
			
			return xml;
		}
	
		private function update(e:Event):void 
		{
			if (dragging)
			{
				weaponImageSprite.x = mouseX - distX;
				weaponImageSprite.y = mouseY - distY;
			}
			this.grid.mouseMove(mouseX, mouseY);
			grid.crosshair.mouseCoords.text = "(" + (grid.crosshairX - 600) + ", " + (grid.crosshairY - 450) + ")";
			weaponBodySprite.graphics.clear();
			weaponBodySprite.graphics.lineStyle(1, 0xFF0000, 1);
			if (vertices.length > 0)
			{
				weaponBodySprite.graphics.moveTo(vertices[0].x, vertices[0].y);
			}
			for (var i:int = 1; i < vertices.length;i++)
			{
				weaponBodySprite.graphics.lineTo(vertices[i].x, vertices[i].y);
			}
			if (isDrawing)
			{
				weaponBodySprite.graphics.lineTo(grid.crosshairX, grid.crosshairY);
			}
		}
		
		private function browseClicked(e:MouseEvent):void 
		{
			sidePanel.browseButton.removeEventListener(MouseEvent.CLICK, browseClicked);
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, weaponImageSelected);
			fileReference.addEventListener(Event.CANCEL, weaponImageSelectionCancelled);
			var imgFileFilter:FileFilter = new FileFilter("Image Files", "*.jpg;*.jpeg;*.png");
			fileReference.browse([imgFileFilter]);
			//fileReference.browse();
		}
		
		private function weaponImageSelectionCancelled(e:Event):void 
		{
			fileReference.removeEventListener(Event.CANCEL, weaponImageSelectionCancelled);
			sidePanel.browseButton.addEventListener(MouseEvent.CLICK, browseClicked);
		}
		
		private function weaponImageSelected(e:Event):void 
		{
			//sidePanel.browseButton.addEventListener(MouseEvent.CLICK, browseClicked);
		 
			fileReference.removeEventListener(Event.SELECT, weaponImageSelected);
			fileReference.addEventListener(Event.COMPLETE, onFileLoadComplete);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fileReference.load();
		}
		
		private function onFileLoadComplete(e:Event):void 
		{
			fileReference.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			var data:ByteArray = fileReference["data"];
			trace("File loaded");
			
			var movieClipLoader:Loader=new Loader();
			movieClipLoader.loadBytes(data);
			movieClipLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMovieClipLoaderComplete);
		}
		
		private function onFileLoadError(e:IOErrorEvent):void 
		{
			trace("file load error");
		}
		
		private function onMovieClipLoaderComplete(event:Event):void 
		{
			sidePanel.browseButton.addEventListener(MouseEvent.CLICK, browseClicked);
			var loadedContent:DisplayObject = event.target.content;
			var loader:Loader = event.target.loader as Loader;
			weaponImageSprite.addChild(loader);
			imageLoaded = true;
		}
		
		public function addListeners():void
		{
			STAGE.addEventListener(MouseEvent.CLICK, gridClicked);
			STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			STAGE.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			this.addEventListener(Event.ENTER_FRAME, update);
			sidePanel.addEventListener(MouseEvent.ROLL_OVER, sidePanelRollOver);			
			sidePanel.getXmlButton.addEventListener(MouseEvent.CLICK, getXmlClicked);
			sidePanel.testButton.addEventListener(MouseEvent.CLICK, testClicked);
			sidePanel.clearButton.addEventListener(MouseEvent.CLICK, clearClicked);		
			sidePanel.snapToggle.addEventListener(MouseEvent.CLICK, snapToggleClicked);
			sidePanel.browseButton.addEventListener(MouseEvent.CLICK, browseClicked);
			sidePanel.lockImageButton.addEventListener(MouseEvent.CLICK, lockImageButton);
			weaponImageSprite.addEventListener(MouseEvent.ROLL_OVER, weaponImageRollOver);
		}
		
		private function lockImageButton(e:MouseEvent):void 
		{
			lockImage = !lockImage;
			if (lockImage)
				sidePanel.lockImageButton.snapStatus.text = "ON";
			else
				sidePanel.lockImageButton.snapStatus.text = "OFF";
		}
		
		private function removeListeners():void
		{
			STAGE.removeEventListener(MouseEvent.CLICK, gridClicked);
			STAGE.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			STAGE.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			this.removeEventListener(Event.ENTER_FRAME, update);
			sidePanel.getXmlButton.removeEventListener(MouseEvent.CLICK, getXmlClicked);
			sidePanel.testButton.removeEventListener(MouseEvent.CLICK, testClicked);
			sidePanel.clearButton.removeEventListener(MouseEvent.CLICK, clearClicked);
			sidePanel.browseButton.removeEventListener(MouseEvent.CLICK, browseClicked);
			weaponImageSprite.addEventListener(MouseEvent.ROLL_OVER, weaponImageRollOver);
		}
		
		private function weaponImageRollOut(e:MouseEvent):void 
		{
			Mouse.show();
			weaponImageSprite.removeEventListener(MouseEvent.ROLL_OVER, weaponImageRollOver);
			weaponImageSprite.addEventListener(MouseEvent.ROLL_OVER, weaponImageRollOut);			
		}
		
		private function weaponImageRollOver(e:MouseEvent):void 
		{
			//Mouse.hide();
			weaponImageSprite.addEventListener(MouseEvent.ROLL_OVER, weaponImageRollOver);
			weaponImageSprite.removeEventListener(MouseEvent.ROLL_OVER, weaponImageRollOut);			
		}
		
		private function startDragging(e:MouseEvent):void 
		{
			if (!lockImage && imageLoaded && mouseX >= weaponImageSprite.x && mouseX <= weaponImageSprite.x + weaponImageSprite.width && mouseY >= weaponImageSprite.y && mouseY <= weaponImageSprite.y + weaponImageSprite.height)
			{
				dragging = true;
				distX = mouseX - weaponImageSprite.x;
				distY = mouseY - weaponImageSprite.y;
			}
			justDragged = false;
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			if (dragging) 
			{
				dragging = false;
				justDragged = true;
			}
		}
		
		private function snapToggleClicked(e:MouseEvent):void 
		{
			this.grid.snapToGrid = !this.grid.snapToGrid;
			if (this.grid.snapToGrid)
				sidePanel.snapToggle.snapStatus.text = "ON";
			else
				sidePanel.snapToggle.snapStatus.text = "OFF";
		}
		
		private function clearClicked(e:MouseEvent):void 
		{
			vertices = new Vector.<Point>();
			isDrawing = false;
			polygonMade = false;
			weaponImageSprite.removeChild(weaponImageSprite.getChildAt(0));
		}
		
		private function sidePanelRollOver(e:MouseEvent):void 
		{
			Mouse.show();
			sidePanel.removeEventListener(MouseEvent.ROLL_OVER, sidePanelRollOver);
			sidePanel.addEventListener(MouseEvent.ROLL_OUT, sidePanelRollOut);
		}
		
		private function sidePanelRollOut(e:MouseEvent):void 
		{
			//Mouse.hide();
			sidePanel.removeEventListener(MouseEvent.ROLL_OUT, sidePanelRollOut);
			sidePanel.addEventListener(MouseEvent.ROLL_OVER, sidePanelRollOver);			
		}
		
	}

}
package org.fiea.rpp
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import org.fiea.rpp.utils.Console;
	
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class KiteFight extends Sprite 
	{
		
		private var xml:XML;
		private var xmlLoader:XMLLoader;
		
		private static var STAGE:Stage;
		
		public function KiteFight(_stage:Stage) 
		{
			super();
			STAGE = _stage;
			
			xmlLoader = new XMLLoader("config.xml", { name: "game-config", onComplete: init } );
			xmlLoader.load();
		}
		
		private function init(e:LoaderEvent):void
		{
			xml = new XML(LoaderMax.getContent("game-config"));
			Console.log(xml);
		}
		
	}

}
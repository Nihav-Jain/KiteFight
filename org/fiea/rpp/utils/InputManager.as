package org.fiea.rpp.utils 
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class InputManager 
	{
		
		private static var instance:InputManager;
		private static var canCreate:Boolean = false;
		private var players:Vector.<Dictionary>;
		private var possibleKeys:Dictionary;
		
		public function InputManager() 
		{
			if (!canCreate)
				throw new Error(this + " is a Singleton. Use InputManager.getInstance()");
			players = new Vector.<Dictionary>();
			possibleKeys = new Dictionary();
		}
		
		public static function getInstance():InputManager
		{
			if (!instance)
			{
				canCreate = true;
				instance = new InputManager();
				canCreate = false;
			}
			return instance;
		}
		
		public function addInputListeners(STAGE:Stage):void
		{
			STAGE.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function removeInputListeners(STAGE:Stage):void
		{
			STAGE.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			var keycode:String = "" + e.keyCode;
			if (this.possibleKeys.hasOwnProperty(keycode))
			{
				var keymap:KeyMap = this.possibleKeys[keycode] as KeyMap;
				this.players[keymap.playerId][keymap.action] = true;
			}
		}
		
		private function keyUp(e:KeyboardEvent):void 
		{
			var keycode:String = "" + e.keyCode;
			if (this.possibleKeys.hasOwnProperty(keycode))
			{
				var keymap:KeyMap = this.possibleKeys[keycode] as KeyMap;
				this.players[keymap.playerId][keymap.action] = false;
			}
		}
		
		public function addPlayer(xml:XML):uint
		{
			var playerid:uint = this.players.push(new Dictionary()) - 1;
			for each(var key in xml.keymap)
			{
				var newKey:String = key;
				var newAction:String = key.@key;
				//Console.log(newKey, newAction);
				if (this.possibleKeys.hasOwnProperty(newKey))
					throw new Error ("Key already mapped to something");
				
				this.possibleKeys[newKey] = new KeyMap(playerid, newAction);
				this.players[playerid][newAction] = false;
			}
			return playerid;
		}
		
		public function getPlayerKeyStatus(playerid:uint, action:String):Boolean
		{
			return this.players[playerid][action];
		}
	}

}
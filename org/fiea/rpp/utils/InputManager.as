package org.fiea.rpp.utils 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	/**
	 * Manages inputs like keyboard and mouse for the game
	 * @author Nihav Jain
	 */
	public class InputManager
	{
		
		private static var instance:InputManager;
		private static var canCreate:Boolean = false;
		private var players:Vector.<Dictionary>;
		private var possibleKeys:Dictionary;
		public var dispatchPauseEvent:EventDispatcher;
		public static const PAUSE_GAME:String = "PAUSEGAME";
		public static const EXIT_GAME:String = "EXITGAME";
		
		public function InputManager() 
		{
			if (!canCreate)
				throw new Error(this + " is a Singleton. Use InputManager.getInstance()");
			players = new Vector.<Dictionary>();
			possibleKeys = new Dictionary();
			dispatchPauseEvent = new EventDispatcher();
		}
		
		/**
		 * returns the instance of his class while following a singleton pattern
		 * @return
		 */
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
		
		/**
		 * adds the various input listeners (KeyboardEvent.KEY_UP, KeyboardEvent.KEY_DOWN)
		 * @param	STAGE
		 */
		public function addInputListeners(STAGE:Stage):void
		{
			STAGE.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		/**
		 * removes the input listeners
		 * @param	STAGE
		 */
		public function removeInputListeners(STAGE:Stage):void
		{
			STAGE.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		/**
		 * listeners for the KeyboardEvent.KEY_DOWN
		 * @param	e
		 */
		private function keyDown(e:KeyboardEvent):void 
		{
			var keycode:String = "" + e.keyCode;
			// check if this keycode is mapped for any player
			if (this.possibleKeys.hasOwnProperty(keycode))
			{
				var keymap:KeyMap = this.possibleKeys[keycode] as KeyMap;
				this.players[keymap.playerId][keymap.action] = true;
			}
			else if (e.keyCode == Keyboard.P)
			{
				dispatchPauseEvent.dispatchEvent(new Event(PAUSE_GAME));
			}
			else if (e.keyCode == Keyboard.O)
			{
				//dispatchPauseEvent.dispatchEvent(new Event(EXIT_GAME));
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
		
		public static function destroy():void
		{
			InputManager.instance = null;
		}
	}

}
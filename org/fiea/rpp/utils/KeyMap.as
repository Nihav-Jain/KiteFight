package org.fiea.rpp.utils 
{
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class KeyMap 
	{
		
		private var _playerId:int;
		private var _action:String;
		
		public function KeyMap(_playerid:int=0, _action:String=null) 
		{
			this.playerId = _playerid;
			this.action = _action;
		}
		
		public function get action():String 
		{
			return _action;
		}
		
		public function set action(value:String):void 
		{
			_action = value;
		}
		
		public function get playerId():int 
		{
			return _playerId;
		}
		
		public function set playerId(value:int):void 
		{
			_playerId = value;
		}
		
	}

}
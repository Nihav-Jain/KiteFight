package org.fiea.rpp 
{
	import org.fiea.rpp.utils.Console;
	import org.fiea.rpp.utils.InputManager;
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Kite 
	{
		private var id:uint;
		
		public function Kite(playerid:uint) 
		{
			this.id = playerid;
		}
		
		public function update():void
		{
			var inputMgr:InputManager = InputManager.getInstance();
			if (inputMgr.getPlayerKeyStatus(id, "left"))
			{
				Console.log(id, "left");
			}
			if (inputMgr.getPlayerKeyStatus(id, "right"))
			{
				Console.log(id, "right");
			}
			if (inputMgr.getPlayerKeyStatus(id, "up"))
			{
				Console.log(id, "up");
			}
			if (inputMgr.getPlayerKeyStatus(id, "down"))
			{
				Console.log(id, "down");
			}
			
		}
		
	}

}
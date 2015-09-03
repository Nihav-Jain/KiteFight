package org.fiea.rpp.utils
{
	/**
	 * ...
	 * @author Nihav Jain
	 */
	public class Console 
	{
		public static const DEV:uint = 101;
		public static const TEST:uint = 102;
		public static const BOX2DTEST:uint = 103

		public static const ENVIRONMENT:uint = Console.BOX2DTEST;
		
		public function Console() 
		{
			
		}
		
		public static function log(... args):void
		{
			if(Console.ENVIRONMENT > Console.DEV)
				trace(args);
		}
	}

}
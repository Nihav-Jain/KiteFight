package org.fiea.rpp.utils
{
	/**
	 * Manges build environment and logger functions
	 * @author Nihav Jain
	 */
	public class Console 
	{
		// build environments
		public static const DEV:uint = 101;
		public static const TEST:uint = 102;
		public static const BOX2DTEST:uint = 103

		public static const ENVIRONMENT:uint = Console.TEST;
		
		public function Console() 
		{
			
		}
		
		/**
		 * logger functions which prints the parameters only when we have the test build
		 * @param	... args
		 */
		public static function log(... args):void
		{
			if(Console.ENVIRONMENT > Console.DEV)
				trace(args);
		}
	}

}
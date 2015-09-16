package org.fiea.rpp.utils 
{
	import adobe.utils.CustomActions;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.LoaderMax;
	import flash.net.URLRequest;
	import flash.events.Event;
	import com.greensock.events.LoaderEvent;
	import com.greensock.*;
	import com.greensock.loading.*;
	import com.greensock.events.LoaderEvent;
	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import com.greensock.plugins.*;
	/**
	 * ...
	 * @author BB
	 */
	public class SoundManager 
	{
		private var xml:XML;
		private var xmlLoader:XMLLoader;
		public var eventDispatcher:EventDispatcher;
		public static const LOADED:String = "loaded";
		
		public static var instance:SoundManager;
		private static var canCreate:Boolean = false;
		
		private var allSounds:Dictionary;
		
		private var SoundsLoaded:uint;
		
		public var Muted:Boolean = false;
		
		//var newKey:String;
		
		public function SoundManager() 
		{
			SoundsLoaded = 0;
			if (!canCreate)
				throw new Error(this + " is a Singleton. Use InputManager.getInstance()");
			allSounds = new Dictionary();
			xmlLoader = new XMLLoader("game-config.xml", { name: "game-config", onComplete: init } );
			xmlLoader.load();
			eventDispatcher = new EventDispatcher();
			TweenPlugin.activate([VolumePlugin]);
		}
		
		private function init(e:LoaderEvent):void
		{
			xml = new XML(LoaderMax.getContent("game-config"));
			for each(var sound in xml.sounds.sound)
			{
				var newKey:String = sound.@key;
				var Music:MP3Loader = new MP3Loader(sound.@src, { repeat:sound.@repeat, volume:sound.@volume, onComplete: Loaded } );
				allSounds[newKey] = Music;
				Music.load();
				Music.pauseSound();
			}
		}
		
		public function Loaded(l:LoaderEvent):void
		{
			Console.log("sound size = " + l.target.bytesTotal);
			SoundsLoaded++;
			if (SoundsLoaded >= 15)
				eventDispatcher.dispatchEvent(new Event(LOADED));
		}
		
		public static function getInstance():SoundManager
		{
			if (!instance)
			{
				canCreate = true;
				instance = new SoundManager();
				canCreate = false;
			}
			return instance;
		}
		
		public function Play(key:String):void
		{
			//trace(key + "is played");
			var newKey:String = key;
			var mp3:MP3Loader = allSounds[newKey] as MP3Loader;
			if(mp3 != null)
				mp3.playSound();
		}
		
		public function Pause(key:String):void
		{
			var newKey:String = key;
			var mp3:MP3Loader = allSounds[newKey] as MP3Loader;
			if (mp3 != null)
				mp3.pauseSound();
		}
		
		public function StartOver(key:String):void
		{
			var newKey:String = key;
			var mp3:MP3Loader = allSounds[newKey] as MP3Loader;
			if(mp3 != null)
				mp3.gotoSoundTime(0, true);
		}
		
		public function Start(key:String):void
		{
			var newKey:String = key;
			var mp3:MP3Loader = allSounds[newKey] as MP3Loader;
			if(mp3 != null)
				mp3.gotoSoundTime(0);
		}
		
		public function PlayRandomMenuSound():void
		{
			var num:Number = randomRange(1,3);
			if (num == 1)
			{
				StartOver("MenuSound1");
			}
			if (num == 2)
			{
				StartOver("MenuSound2");
			}
			if (num == 3)
			{
				StartOver("MenuSound3");
			}
		}
		
		public function PlayRandomHitSound():void
		{
			var num:Number = randomRange(1,2);
			if (num == 1)
			{
				StartOver("Hit1");
			}
			if (num == 2)
			{
				StartOver("Hit2");
			}
		}
		
		public function PlayRandomDamagedSound():void
		{
			var num:Number = randomRange(1,2);
			if (num == 1)
			{
				StartOver("Damaged1");
			}
			if (num == 2)
			{
				StartOver("Damaged2");
			}
		}
		
		public function PlayRandomCrashSound():void
		{
			var num:Number = randomRange(1,2);
			if (num == 1)
			{
				StartOver("Crash1");
			}
			if (num == 2)
			{
				StartOver("Crash2");
			}
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		public function EnterSlowMo():void
		{
			if (!Muted)
			{
				//SoundManager.getInstance().Play("GPMusic");
				SoundManager.getInstance().Play("SlowMo");
				//StartOver("SlowMo");
				if (allSounds["GPMusic"] != null && allSounds["SlowMo"] != null)
				{
					TweenLite.to(allSounds["GPMusic"], .1, { volume:0 } );
					TweenLite.to(allSounds["SlowMo"], .001, {volume:1});
				}
			}
			
		}
		
		public function ExitSlowMo():void
		{
			if (!Muted)
			{
				//SoundManager.getInstance().Play("GPMusic");
				//SoundManager.getInstance().Play("SlowMo");
				if (allSounds["GPMusic"] != null && allSounds["SlowMo"] != null)
				{
					TweenLite.to(allSounds["GPMusic"], 1, { volume:.5 } );
					TweenLite.to(allSounds["SlowMo"], .001, { volume:0 } );
				}
				Start("SlowMo");
			}
		}
		
		public function Crashing():void
		{
			if (!Muted)
			{
				SoundManager.getInstance().Play("Crashing");
				if(allSounds["Crashing"] != null)
					TweenLite.to(allSounds["Crashing"], 2, { volume:0, onComplete: PlayRandomCrashSound } );
			}
		}
		
		public static function destroy():void
		{
			for each (var sound in SoundManager.getInstance().allSounds)
			{
				sound.dispose();
			}
			SoundManager.instance = null;
		}
		
		public function Mute():void
		{
			for each (var sound in allSounds)
			{
				sound.volume = 0;
			}
			Pause("GPMusic");
			Start("SlowMo");
			Muted = true;
		}
		
		public function UnMute():void
		{
			for each (var sound in allSounds)
			{
				sound.volume = 1;
			}
			Play("GPMusic");
			//Play("SlowMo");
			Muted = false;
		}
	}

}
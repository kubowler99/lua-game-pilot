---@class SoundPlayer
---Audio management system for music and sound effects
---Handles loading, playback, volume control, and platform-specific optimizations
---Supports stinger transitions for music changes and debouncing for sound effects
local SoundPlayer = {}
local device = require("Libs.device")

------------------------------------------------------------------------------------------------------------------------
-- Configuration --
------------------------------------------------------------------------------------------------------------------------

---Stinger configuration: Delay before starting fade out (ms)
---@type number
local fadeOutDelay = 100

---Stinger configuration: Duration of fade out (ms)
---@type number
local fadeOutTime  = 200

---Stinger configuration: Delay before starting fade in (ms)
---@type number
local fadeInDelay  = 600

---Stinger configuration: Duration of fade in (ms)
---@type number
local fadeInTime   = 200

------------------------------------------------------------------------------------------------------------------------
-- Internal State --
------------------------------------------------------------------------------------------------------------------------

---Cache of loaded audio objects indexed by sound name
---@type table<string, userdata>
local soundTable      = {}

---Timestamps of last play time for debouncing (prevents rapid re-triggering)
---@type table<string, number>
local playingSounds   = {}

---Android event sound objects (optimized for short sounds)
---@type table<string, userdata>
local eventSoundTable = {}

-- Reserve audio channels for specific purposes
audio.reserveChannels( 1 )  -- Reserved for music
audio.reserveChannels( 2 )  -- Reserved for specific effects

------------------------------------------------------------------------------------------------------------------------
-- Loading & Setup --
------------------------------------------------------------------------------------------------------------------------

---Loads an audio file into memory
---Uses platform-specific optimizations (event sounds on Android for short sounds)
---@param sound string Sound name (without extension)
---@param long? boolean If true, loads as streaming sound (for longer audio)
---@param ext? string File extension (defaults to ".mp3")
---@param music? boolean If true, loads from Musics folder instead of Sfx folder
---@return void
function SoundPlayer.loadSound(sound, long, ext, music)
    if not ext then ext = ".mp3" end
    if device.isAndroid and not device.isSimulator and not long then
      if not eventSoundTable[sound] then
        eventSoundTable[sound] = media.newEventSound("Assets/Audio/Sfx/"..sound..ext)
        if not eventSoundTable[sound] then
          error( "not sound", sound )
        end
      end
    elseif not soundTable[sound] then
      if not music                      then soundTable[sound] = audio.loadSound("Assets/Audio/Sfx/"..sound..ext)    end
      if music or not soundTable[sound] then soundTable[sound] = audio.loadSound("Assets/Audio/Musics/"..sound..ext) end

      if not soundTable[sound] then
        error( "Can't load sound: \""..sound..ext.."\"" )
      end
    end
end

---Sets up audio system with state observers for music/sfx mute settings
---@param state State State object with musicOn and sfxOn observable properties
---@return void
function SoundPlayer.setState(state)
  SoundPlayer.muteMusic(not state:observe("musicOn", SoundPlayer, SoundPlayer._musicConfigsUpdated, true))
  SoundPlayer.muteSfx(not state:observe("sfxOn", SoundPlayer, SoundPlayer._sfxConfigsUpdated, true))
end

------------------------------------------------------------------------------------------------------------------------
-- Playback --
------------------------------------------------------------------------------------------------------------------------

---Plays a sound effect with automatic loading and debouncing
---@param sound string Sound name (without extension)
---@param params? table Audio playback parameters (channel, loops, etc.)
---@return number? channel Audio channel if played, nil if muted/debounced
function SoundPlayer.playSound(sound, params)
  if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted or not SoundPlayer.canPlay(sound) then return end

  if not soundTable[sound] and device.isAndroid and not device.isSimulator then
    if not eventSoundTable[sound] then
      eventSoundTable[sound] = media.newEventSound("Assets/Audio/Sfx/"..sound..".mp3")
    end
    media.playEventSound(eventSoundTable[sound])
  else
    if not soundTable[sound] then
      soundTable[sound] = audio.loadSound("Assets/Audio/Sfx/"..sound..".mp3")
    end
    return audio.play(soundTable[sound], params)
  end
end

---Checks if sound can be played (debouncing to prevent rapid re-triggering)
---Prevents same sound from playing more than once per 30ms
---@param sound string Sound name to check
---@return boolean canPlay True if sound can play, false if debounced
function SoundPlayer.canPlay(sound)
  local time = system.getTimer()
  if not playingSounds[sound] or time - playingSounds[sound] > 30 then
    playingSounds[sound] = time
    return true

  else
    return false

  end
end

---Plays a long sound effect (streaming, not cached)
---@param sound string Sound name (without extension)
---@return number? channel Audio channel if played, nil if muted
function SoundPlayer.longSound(sound)
  if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted or not SoundPlayer.canPlay(sound) then return end

	if not soundTable[sound] then
		SoundPlayer.loadSound(sound,true)
	end
	return audio.play(soundTable[sound])
end


---Plays background music with optional stinger transition
---@param sound string? Music track name (nil to stop music)
---@param stinger string? Optional stinger sound to play during transition
---@param once boolean? If true, plays once; if false/nil, loops indefinitely
---@param onComplete? function Callback when music finishes (only for non-looping)
---@param channel? number Audio channel (defaults to 1)
---@return number channel The audio channel used (always returns 1 for stinger mode)
function SoundPlayer.playMusic(sound, stinger, once, onComplete, channel)
  if SoundPlayer.muted or _G.DEBUG.MUTE_MUSIC then return end

  channel = channel or 1

  if sound ~= nil then
    if not soundTable[sound] then
       SoundPlayer.loadSound(sound, true)
    end
  end
  if stinger then
    if _G.DEBUG.MUTE_SOUND or SoundPlayer.muted or SoundPlayer.sfxMuted then
      audio.play(soundTable[stinger])
    end

    timer.performWithDelay(fadeOutDelay,function()
      audio.fade{channel=channel, time=fadeOutTime, volume=0}
    end)
    if sound ~= nil then
      timer.performWithDelay(fadeInDelay,function()
        audio.stop(channel)
        audio.play(soundTable[sound],{channel = channel, loops = once and 1 or -1, onComplete = onComplete })
        audio.fade{channel = channel, time = fadeInTime, volume = 1}
      end)
    end
  else
    audio.stop(1)
  	return audio.play(soundTable[sound],{
      channel    = channel,
      loops      = once and 0 or -1,
      onComplete = onComplete
    })
  end

  return 1
end

------------------------------------------------------------------------------------------------------------------------
-- Control --
------------------------------------------------------------------------------------------------------------------------

---Stops audio on specified channel
---@param channel number Audio channel to stop
---@return void
function SoundPlayer.stop(channel)
  audio.stop(channel)
end

---Fades out audio on channel, then resets volume to 1 after 1 second
---@param handler number Audio channel to fade
---@return void
function SoundPlayer.fade(handler)
  audio.fadeOut{channel=handler}
  timer.performWithDelay(1000,function()
    SoundPlayer.setVolume(1, handler)
  end)
end

---Sets volume for a specific audio channel
---@param v number Volume level (0.0 to 1.0)
---@param channel number Audio channel
---@return void
function SoundPlayer.setVolume(v,channel)
  audio.setVolume(v,{channel=channel})
end

---Resumes all paused audio
---@return void
function SoundPlayer.resume()
  audio.resume()
end

---Pauses all audio
---@return void
function SoundPlayer.pause()
  audio.pause()
end

---Gets duration of a loaded sound in milliseconds
---@param sound string Sound name
---@return number duration Duration in milliseconds, or -1 if not loaded
function SoundPlayer.getDuration(sound)
  if soundTable[sound] then
    return audio.getDuration( soundTable[sound] )
  else
    return -1
  end
end

---Fades audio channel to specified volume
---@param channel number Audio channel
---@param time number Fade duration in milliseconds
---@param volume number Target volume (0.0 to 1.0)
---@return void
function SoundPlayer.fade(channel, time, volume)
  audio.fade{time=time, channel=channel, volume=volume}
end


------------------------------------------------------------------------------------------------------------------------
-- Mute Controls --
------------------------------------------------------------------------------------------------------------------------

---Mutes or unmutes all audio
---Can optionally play a specific sound before muting
---@param mute boolean|string True to mute, false to unmute, or sound name to play before muting
---@return void
function SoundPlayer.mute(mute)
  if mute then
    audio.fadeOut { time = 0 }
    media.stopSound()

    if type(mute) == "string" then
      timer.performWithDelay( 20, function()
        SoundPlayer.muted = false
        SoundPlayer.playSound(mute)
        SoundPlayer.muted = true
      end)
    end
    SoundPlayer.muted = true

  else
    SoundPlayer.muted = false
  end

end

---Mutes or unmutes sound effects (channels 2-32)
---Music channel (1) is not affected
---@param mute boolean True to mute, false to unmute
---@return void
function SoundPlayer.muteSfx(mute)
  for i=2,32 do
    audio.fade{channel = i, time = 0, volume = mute and 0 or 1, 1}
  end

  SoundPlayer.sfxMuted = mute
end

---Mutes or unmutes music (channel 1)
---Fades over 500ms for smooth transition
---@param mute boolean True to mute, false to unmute
---@return void
function SoundPlayer.muteMusic(mute)
  audio.fade{channel = 1, time = 500, volume = mute and 0 or 1, 1}
  SoundPlayer.musicMuted = mute
end

------------------------------------------------------------------------------------------------------------------------
-- State Observers --
------------------------------------------------------------------------------------------------------------------------

---Internal callback for music config state changes
---@param e table Event with e.value boolean (true = music should be muted)
---@return void
function SoundPlayer._musicConfigsUpdated(e)
  SoundPlayer.muteMusic(e.value)
end

---Internal callback for SFX config state changes
---@param e table Event with e.value boolean (true = sfx should be muted)
---@return void
function SoundPlayer._sfxConfigsUpdated(e)
  SoundPlayer.muteSfx(e.value)
end


return SoundPlayer

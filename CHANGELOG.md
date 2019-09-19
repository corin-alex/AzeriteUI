# AzeriteUI Change Log
All notable changes to this project will be documented in this file. Be aware that the [Unreleased] features might not all be part of the next update, nor will all of them even be available in the latest development version. Instead they are provided to give the users somewhat of a preview of what's to come. 

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.175-Release] 2019-09-19
### Changed
- Only critters will get the tiny target frame now. 
- The actionbutton icons are now roughly 30% brigher compared to what they were before. 

## [1.2.174-Release] 2019-08-31
### Fixed
- Locked the main chat in a manner not affecting its DropDown, thus preventing taint from spreading to the Compact group frames. 

## [1.2.173-Release] 2019-08-25
### Changed
- Moved the UI switcher command system to the back-end. 

## [1.2.172-Release] 2019-08-23
### Added
- Attempted to add zone info to group tooltips. May or may not work. 

### Changed
- The micro menu should now work fine even if it has been enabled in Bartender4. We override the user error. 

## [1.2.171-Release] 2019-08-17
### Changed
- Nameplates are now scaled according to distance, and also have their max range increased. 
- The Personal Resource Display - the player's own optional nameplate - is now class colored, and have its bar growing towards the right, same as the player unitframe.

## [1.2.170-Release] 2019-08-16
### Fixed
- Fixed an issue that sometimes would leave the actionbutton overlay glow unanchored, causing it to fill almost the entire screen. Ouch.  

## [1.2.169-Release] 2019-08-15
### Fixed
- Fixed an issue introduced in build 1.2.167 when using alternative nameplate addons and trying to access our own menu. 

## [1.2.168-Release] 2019-08-15
### Fixed
- Fixed the issue introduced in the previous update that caused actionbuttons to appear pressed down all the time.

## [1.2.167-Release] 2019-08-15
### Added 
- Added a texture to indicate when abilities that fire on the next swing are enabled.

### Changed
- A lot of code optimization as we transition to the next generation of our layout- and default settings structure.
- The standard gametooltip should now be scaled as our own tooltips, regardless of the current user interface scale. 

### Fixed
- Fixed issue #43, where the removal of the nameplate class resource bars could sometimes cause taint when first enabled in combat. 
- Fixed durability frame repositioning, which has been broken since 8.2.0. 

## [1.2.166-Release] 2019-08-05
### Fixed
- Fixed an issue where the red "this unit is targeting you" eye wouldn't appear for neutral NPCs. It should now be possible to see that Darkshore Crabs are actually attacking you.

## [1.2.165-Release] 2019-08-04
### Fixed
- Added a fallback size and position to our Minimap back-end, to prevent unreadable Map size- and position during startup. This should fix the issues related to TomCat's Minimap buttons. 

## [1.2.164-Release] 2019-07-31
### Changed
- Updated frFR localization.
- Made some minor improvements to the aura filter to amongst other things allow us to dismount (at least out of combat) those damn shells in Nazjatar that won't stop moving. Will make a better system for those in the future, possibly. This is in no way the end of the aura tweaks, btw, I have multiple coming before Classic! 
- Reworked the unitframe health element to have health preview, heal predictions, and damage- and healing absorbs baked into the primary element, and having those latter mentioned auto-update themselves based on how the health element is set up. Currently every single health bar in the interface used every single one, so combining them was a choice made to simplify the workflow. When adopting this for the Orb elements in various upcoming addons, switches and exceptions will be added to make it function as intended. For now though, it's perfect for our current intended usage. 
- Put the file loading of libraries and plugins into xml files which more easily can be ported between my various projects when changes are made. Another change aimed at making it easier to maintain multiple addons as we move ever closer to Classic! 

## [1.2.163-Release] 2019-07-13
### Added
- Our custom unitframe tooltips now show PvP icons for PvP enabled players, and a skull icon for bosses. 

## [1.2.162-Release] 2019-07-13
### Added
- The nameplates now have heal prediction. 
- The nameplates now have an absorb bar. 

## [1.2.161-Release] 2019-07-11
### Added
- Added the missing (though yet empty) localization file for Italian (itIT) game clients. 

## [1.2.160-Release] 2019-07-11
### Changed
- The cast shield is now removed when a cast is interrupted or fails. 

### Fixed
- The message displayed on interrupted (but not failed) casts should now be "Interrupted", not "Failed". 

## [1.2.159-Release] 2019-07-11
### Added
- The floating player castbar, as well as the castbars found on nameplates should now remain visible and display a message if the spellcast fails or is interrupted. 

## [1.2.158-Release] 2019-07-09
### Fixed
- Fixed an issue where the GameTooltip and our Azerite/Rep/XP tooltip would be visible at the same time when moving directly from the toggle button to an element above the ringframe - though covering it - that would show the GameTooltip. There should only be one tooltip at a time now. 

## [1.2.157-Release] 2019-07-07
### Added
- Added the text based indicator for low mana or out of mana to the focus frame as well. 

### Fixed
- Fixed an issue that would prevent casts going from interruptable to non interruptable or the other way in the middle of the cast from not being visually updated to illustrate the changed interruptable state. 

## [1.2.156-Release] 2019-07-06
### Fixed
- Fixed the aura filter for the personal resource display to once again only show relevant player cast auras with short duration.   
- Fixed a misalignment that caused the nameplate auras to not be centered above the nameplates but instead slightly towards the right side.

## [1.2.155-Release] 2019-07-06
### Fixed
- Added the missing threat related events to the health element to properly update threat coloring when we attract aggro from nearby monsters.

## [1.2.154-Release] 2019-07-06
### Changed
- Tuned the threat colors used in unitframes and nameplates to be easier to understand. It should now be far more evident when you're starting to lose threat when tanking. 
- Changed the health element used in unitframes and nameplates to show even the lowest threat levels, making it far easier for both tanks, healers and damagers to see what mobs are actually attacking them when engaged in combat.  
- We're now filtering out Consecrated Ground from hostile nameplates, as it's implicit that mobs have this from their positioning around the Paladin. This is done using our updated aura systems, and one of the steps towards cleaning up nameplates and a bit in spammy situations. 
- Our custom aura filters now uses both the descriptive back-end aura library and the front-end filter display lists when deciding what to show. This is important because it's one of the steps toward our upcoming priority based filter systems. One of the reasons for our constant baby steps is both my currently limited available time, but also to as far as possible keep the changes backwards compatible to avoid unneeded bugs and breakage. 
- The tiny Blizzard animation of an item going into your backpack or bags has been removed, as it was missing the target by miles in this and our other custom user interfaces. Items still end up in your bags, of course, this was just to remove one of many redundant remnants of the original Blizzard interface.

### Removed
- Killed off the entire `/front-end/deprecated` folder, as its functions and tables have all been built into the appropriate places in the aura back-end and addon front-end now. The name of the folder kind of implied this would happen. 

## [1.2.153-Release] 2019-07-01
### Added
- Added updated Minimap blips for WoW client patch 8.2.0.

## [1.2.152-Release] 2019-07-01
### Fixed
- 8.2.0: Changed calls to `select("#", window:GetChildren())` to use `window:GetNumChildren()` from within the secure snippets used in our menu, as the former appears to not be accepted anymore. Hooray for undocumented changes, folks! Give me a medal for figuring it out, already.  
- Fixed an old but until now undiscovered bug in our LibHook and LibSecureHook libraries that would cause frames with multiple hooks attached to module methods to always pass only the first registered module as the `self` argument, causing weird and random nil bugs all over the place. This is the bug that occurred when learning new Heart of Azerite powers.

## [1.2.151-Beta] 2019-06-27
### Changed
- Disabled the blips from 8.1.5 again, turns out that even though the humanoid icons were right, the rest weren't. Balls. I'll re-order the icons tomorrow. Need a little actual playing here now. I want to do the new quests too! :'(

## [1.2.150-Beta] 2019-06-27
WoW Client Patch 8.2.0 Mayhem continues still!

### Changed
- Re-enabled our styled Minimap blips from patch 8.1.5, as they don't appear to have changed their atlas(?). Kind of strange, but I'm not complaining. Will disable them again if it turns out things are changed. If that happens, I'll manually update the file like in previous patches! 

## [1.2.149-Beta] 2019-06-27
WoW Client Patch 8.2.0 Mayhem continues!

### Added
- Put the cogwheel and micro menu functionality back, but leaving our own addon menu disabled for the time being. This way at least we can access in-game panels with the mouse, and not just keybinds! 

## [1.2.148-Beta] 2019-06-27
WoW Client Patch 8.2.0 Mayhem! 

### Changed
- A ton of fixes aimed towards the 8.2.0 bugs. 

### Removed
- Cogwheel button, micro menu and addon menu gone until some bugs being caused by undocumented changes to the Blizzard API has been figured out. Might have to rewrite this part from scratch if I can't figure it out, or if the changes are of a sort that permanently breaks my system.  

## [1.2.147-Release] 2019-06-17
### Added 
- Added deDE by Maoe!

## [1.2.146-Release] 2019-06-02
### Changed
- Updated frFR locale.

## [1.2.145-Release] 2019-05-31
### Added
- Added frFR locale by HipNoTik! 

## [1.2.144-Release] 2019-05-29
### Fixed
- The ToT target highlight outline will no longer be visible when the ToT frame itself is hidden, which is the case when the Target frame and the ToT frame share the same unit. 

## [1.2.143-Release] 2019-05-18
### Changed
- Disabled the chat throttle filter as it still for unknown reasons randomly blocks messages it shouldn't. We won't re-enable it until this is sorted out. 

## [1.2.142-Release] 2019-04-27
### Fixed
- Fixed the throttle filter meant to hide identical messages within a 10 second period from the first message. It's working as intended now, and not randomly hiding messages after the timer runs out. This should fix issues some had with not being able to see their own messages in guild chat. 

## [1.2.141-Release] 2019-04-24
### Fixed
- Health preview won't be updated on dead or disconnected units. This should hopefully take care of the "TexCoord out of range" bug experienced by some players in groups. 

## [1.2.140-Release] 2019-04-20
In this build we're adding some compatibility changes to better allow the usage of ConsolePort and AzeriteUI together without having to reset the WoW keybinds to their defaults. We will not be adding in the option to disable our actionbars.

### Changed
- The actionbutton /bind mode and its menu entry will not be loaded when ConsolePort is enabled. 
- The actionbuttons won't currently display any keybind text when ConsolePort is enabled. Our intention is to add in the ConsolePort binding icons here, though we can't at this point guarantee that it'll actually happen. 
- The actionbutton module will no longer grab or relocate keybinds to our own actionbuttons when ConsolePort is enabled, as this was causing problems when some of the buttons had keybinds that ConsolePort used for its various behaviors. 
- Attempting some experimental changes to prevent an invisible objectivestracker from causing mouseover events when trying to click arena or boss frames.  

## [1.2.139-Release] 2019-04-14
### Added
- Added zhTW translation by Alex Wang.

## [1.2.138-Release] 2019-04-06
### Added
- Added zhCN translation by Jiawei Zhou.

## [1.2.137-Release] 2019-04-06
### Changed
- Added support for Kaliel's Tracker to the tracker module. It doesn't resolve Kaliel's initial startup bug, though, because that bug is a part of Kaliel's Tracker, not any other addon. 

## [1.2.136-Release] 2019-03-30
### Changed
- Reverted a change to the quest tracker layer, as it wasn't working as intended. 
- Redid layering of boss and enemy arena/pvp unitframes in the back-end to be above the aforementioned tracker. Let's attempt to fix this issue in the back-end, leaving the modules and the blizzard elements out of our crazy hacks. 

## [1.2.135-Release] 2019-03-30
### Fixed
- Fixed the issue where mousebuttons (except the first two) wouldn't be recognized when trying to keybind the actionbuttons. 

## [1.2.134-Release] 2019-03-30
### Changed
- Trying an experimental change to how spell activation alerts are shown on the action buttons. 

## [1.2.133-Release] 2019-03-29
### Changed
- Reworked objective tracker layering to not interfere with the boss frame in instances. 

## [1.2.132-Release] 2019-03-25
### Changed
- Replaced "xp", "ap" and "rp" texts for Minimap rings at less than one percent with the more eye-catching new feature icon. 
- Fine-tuned the Nameplate back-end's update handler's performance slightly. 

### Fixed
- Adjusted the Minimap ring description's vertical alignment.

## [1.2.131-Release] 2019-03-25
### Added
- Added better MBB (MinimapButtonBag) support. 

## [1.2.130-Release] 2019-03-24
### Fixed
- Fixed some entries in the ruRU and esES locales which I overlooked when changing format strings from `%d` to `%.0f`.  

## [1.2.129-Release] 2019-03-21
### Changed
- Re-enabled frequent updates for all raid frames, as their health doesn't appear to update after returning to life otherwise. 

## [1.2.128-Release] 2019-03-21
### Changed
- Re-enabled frequent updates for all nameplates, as the alternative appears to keep their health at max for too long periods at a time. 

## [1.2.127-Release] 2019-03-21
### Added
- Added ruRU locale by Demorto#2597 and esES by Sonshine#3640! Awesome work, folks!  
- Added some comments in the locale files to make it easier for people to know what goes where when writing locales. Up to now I've been living in my own little bubble, not having anybody else needing to look at any of the code whatsoever, and that made me slack a little, I guess. I will be much better to comment and explain in the files in the future! 
- Added non-interactive (click-through) options for friendly and hostile nameplates, as well as the personal resource display. 
- Added heal predictions and heal absorbs for the player, target, party and raid unit frames. 
- Added a health preview layer for the player and target unit frames, which shows gained health instantly, while the "real" bar smoothly moves up towards it. 
- Added a prioritized single aura display for raid- and party frames. This displays boss debuffs, dispellable magic, curses, diseases and poisons when the player has a class and spec that can dispel them, as well as a few select other auras like Priest Atonement. 
- Added a debug console which will be loaded but hidden by default. You can toggle the console visibility or fully unload it through the addon menu. I recommend leaving it loaded, but disabled. Then if you encounter actionbars that won't change when entering a vehicle, or other behavior that doesn't fully make sense, just enable it, take a screenshot and show us on discord, bitbucket or twitter! For the time being it only tracks actionbar paging changes (entering vehicles, switching druid forms, possessing somebody, etc) and missing locale entries. We'll be adding more if other problem areas should arise. As a rule of thumb though, we won't ever debug anything that doesn't at some point need debugging. And any fully fixed areas will have its debug code removed. 
- Added a 10 second throttle for chat messages in most channels. This is mostly to avoid a group of mobs instantly filling your entire chat history with the exact same message, but could also be considered helpful to remove needless spam from certain public chats. 
- Added an action button lock setting to the config menu. When this setting is unchecked, spells can be freely moved or removed from the action buttons without holding the Alt+Ctrl+Shift modifier combination. 
- Added full Prat3.0 support. When Prat3.0 is enabled, neither our chat windows nor our chat bubbles module will be loaded. Nor will any automation regarding bubble visibility in and out of instances or any chat window placement when toggling Healer Mode be active. Meaning you'll manually have to deal with any issues that arise by yourself, we can't offer support for situations where external user configurated addons are in control. 
- Added prettier minimap blip icons. 
- Healer Mode! This mode found on top of the menu changes the layout of group frames and chat windows with a single click, bringing all friendly frames together and hopefully will make it a bit easier for healers in the future! This is one of many feature improvements we are working on, and more will be added during the course of the 1.2-Alpha. 
- Added your own friendly auras to the party frames. This is not intended as a full aura display, but rather as a way for healers to easier be able to track shields, HoTs, things like that. A prioritized debuff display is also planned and will be added later in the 1.2-Alpha, but it is not part of the standard aura display beneath their frames, as this is currently only meant to track healing. 

### Changed
- Changed all menu entries with an Enabled/Disabled added to just color the whole entry red or green instead. For red/green colorblindness we also have the brighter downpressed button texture to indicate the option is enabled, so this is neither worse nor better for them, this is a general improvement to avoid message overflows on menu entries. 
- Removed debug mode localization as the ultimate purpose of the debug console is to provide Goldpaw with debug information. Messages to this frame is formatted in a specific manner, and having them displayed in the same language as the Lua API uses is of importance. 
- Removing localization from keybind abbreviations, as we're working on a better and more logical icon-based system to display special keys like the arrow keys, page up and down, enter and so on. 
- Added a missing locale existence check in non-primary addon locales to avoid bugs for enUS clients now that we have multiple localizations! 
- Changed some of the font choices for non-latin game clients to be more in line with what Blizzard is using, and hopefully easier to read. 
- Update actionbutton fading logic to be smoother and feel more responsive. 
- Updated the nameplate opacity logic to be smoother, smarter, and tone down units that aren't in your line of sight. 
- Hide chat bubbles while engaged in combat inside an instance, but allow them to remain visible otherwise to support cut scenes and similar.
- Attached Blizzard's bag slot buttons to the bottom of the main backpack frame, so bags finally can be changed easily without having to disable the UI or use separate bag addons. It's a contextual and elegant fix, according to Sottises. :) 
- Updated the fading code and logic for the minimap xp/reputation/artifact bars, as there were some inconsistencies and weird occurrences when moving out and in again. 
- Updated minimap tracking blips for WoW Client Patch 8.1.5.
- Actionbutton actions will now be prevented if the three modifier keys are held down, allowing us to drag all spells away from the buttons even with cast on down enabled. This does not fix the issue when cast on down is enabled and button lock is off, as there isn't really any way for us to separate between mouse clicks and keybinds. But at least holding the modifiers will guarantee success now.
- The debug console now requires a left-click to switch sides of the screen, and a right-click will close the console. The mousewheel has also been enabled for this frame, and you can now scroll through the debug output with it, or go directly to the top or bottom by holding down Shift while using the wheel. 
- Did a whole lot of small corrections to target frame bar elements. Turns out a rectangle has different sizes depending on what corner you begin in. Or at least according to the WoW API. Trippy. 
- Changed the player and target unit frame health bar smoothing. It now fills up rather slowly, but show reductions almost instantly. 
- The player frame aura filter will now show auras being cast by the player, pet or vehicle regardless of duration while controlling a vehicle. You can now see your style stacks when doing the horse riding World Quest in other words. 
- The back-end master visibility frame which every single custom object in the interface belongs to will now be hidden at startup and between reloads to halt all update timers and generally just speed up the process. 
- The player frame aura filter will now show auras being cast by the player, pet or vehicle regardless of duration while controlling a vehicle. You can now see your style stacks when doing the horse riding World Quest in other words. 
- The back-end master visibility frame which every single custom object in the interface belongs to will now be hidden at startup and between reloads to halt all update timers and generally just speed up the process. 
- GroupTools will now move along with the group frames and main chat window when Healer Mode is toggled. 
- The Battle.Net toast window will now move along with the group frames and main chat window when Healer Mode is toggled. 
- Redid the Death Knight Rune opacity and display logic, to work around a few bugs and have it occur more often than other player resources, as the current Rune system really is more like an extra energy bar than anything else. 
- Trying some experimental changes to raid frame updating with the purpose of increasing the performance. 
- The main chat frame is no longer movable when using AzeriteUI's chat windows module. Prat users are not affected by this. 
- Blizzard chat bubbles should be visible when the interface is hidden with the keybind (Alt+Z by default) to do so. 
- The Group Finder Eye's tooltip should now be styled in the same manner as most tooltips. 
- Reduced number of buffs on party frames from 6 to 3, as this is only a tool meant to show the player's own beneficial shields and HoTs on the party. We are adding a special debuff display for boss auras and dispellable debuffs, and some special player abilities like Atonement and a few others we're still working out. 
- Adjusted the spacing between the group areas and the player area in Healer Mode a little further. 
- Working on some experimental changes to switch to Blizzard chat bubbles during non instanced cinematics and in-game movies. 
- Major folder and code restructuring. This is both in preparation for our next major projects as well as the upcoming WoW Classic. 

### Fixed
- Changed almost every format string in the user interface to work around a problem Blizzard have with displaying integers. A problem where they sometimes are WRONG for no apparent reason, while zero-decimal floats which for all intents and purposes work the same way, are always displayed with the correct number shown.
- Changed the order of the actionbutton paging conditionals to allow for overridebars while having a vehicleui, as this was needed to make the buttons appear in the new WoW patch 8.1.5 world quest "Cycle of Life".
- Updated player and pet unitframe conditionals to work with the world quest "Cycle of Life".
- Fix actionbutton mask textures not being applied properly since WoW client build 29600(March 5th, 2019). This looked especially bad when buttons faded in and out, as the square shape of the original icons would shine through the border. Thank you Blizz, we really do love your undocumented changes. Hire us already. 
- Attempting to work around the nameplate aura misalignment issue. The cause of the issue hasn't been fully verified, only theorized, so this fix can be considered the same. Current fix is to reposition the aura container on every post update. I don't consider this case closed even if this fix works, and I'll continue to monitor the situation and tweak the fixes for performance and stability. 

## [1.1.112-Release] 2019-02-26
### Added
- Added ready check, ressurect indicator and mana status messages to Party frames. 

### Changed
- The mana threshold for a warning to appear on all group frames was raised from 15% to 25% mana. The warning will turn red at 10% mana or lower. 

## [1.1.111-Release] 2019-02-22
### Added
- Added target and focus highlighting for small unit frames. Most frames should support both, with the exception of the focus unit frame which never will get the focus highlight, because it really goes without saying that your focus target is your focus target. 

## [1.1.110-Release] 2019-02-20
### Fixed
- Fixed the bug occurring when mousing over the unitframe of a unit with less than full health introduced recently.

## [1.1.109-Release] 2019-02-20
### Added
- Keybind mode added! It's accessible either with the `/bind` command or through the ActionBars section of the cogwheel addon menu.

### Changed
- Our nameplates will now disable themselves if the NeatPlates addon is loaded. 

## [1.1.108-Release] 2019-02-12
### Fixed
- Unit tooltips from our own unit frames once again displays a value on their health bars in the same manner the world mouseover tooltips do. 

## [1.1.107-Release] 2019-02-09
### Changed
- Middle-clicking the cogwheel menu button will now toggle your bags. 

### Fixed
- Your bar shouldn't randomly fail to change when entering vehicles anymore. This problem turned out to be a bug or unwanted delay within Blizzard's secure environment that would sometimes return false for the existence of a vehicle bar directly after a vehicle change, even though the functions to retrieve the bar index and the return values from the macro driver all return the right values. We are now working around this by simply skipping the randomly succesful checks and relying on macro results and bar index functions instead.

## [1.1.106-Release] 2019-02-07
### Fixed
- Menu buttons with open windows connected to them should now also appear as downpressed while the window is open. This should have been a part of the previous update, but I simply forgot it!

## [1.1.105-Release] 2019-02-07
### Added
- Getting ready for love. 

### Changed
- AzeriteUI menu buttons should now follows the same graphical usage schemes as the micromenu and gamemenu, which should result in more clearity regarding what options are chosen, what you're hovering over and so on. 

## [1.1.104-Release] 2019-01-24
### Changed
- Added post updates to line pair creation in the tooltip back-end, to allow the addon to use custom font sets for the tooltips. 

### Fixed
- Properly disabled mouse input on the nameplate aura element.

## [1.1.103-Release] 2019-01-17
### Changed
- Changed how item tooltips from items with a Use effect placed on the actionbars are displayed. They are more similar to other spells now, not showing elements like their stats, bind status and so on, but instead focusing on the Use portion of the item. This does not affect items without a Use effect, like weapons placed on your bars for easier swapping in combat. 
- Certain requirements to use a spell - like having to be in Bear Form - will no longer be displayed in the action button tooltips if the criteria has been met. This only affects action button tooltips, and has no effect on the spell book or other Blizzard elements. 

## [1.1.102-Release] 2019-01-16
### Fixed
- Fixed some issues with the hotkey abbreviation code that confused binding key identifier with button display text and just ended with MAYHEM (and missing binds on the bars)!

## [1.1.101-Release] 2019-01-16
### Added
- Added a spell queue window display to the on-screen castbar. If your spell queue window / custom lag tolerance is set to 100ms or higher or the queue window make up 5% of your cast time or more, the castbar will now show a transparent overlay in the area where spells can be queued up. This area will position itself logically based on whether you're casting or channeling, meaning if the bar shrinks from full to empty like when channeling, the queue area will be displayed at the start of the bar, while with normal casts it'll be at the end. 

Note that the default spell queue window in World of Warcraft currently is a whopping high 400ms, which might be fine for healers or casters queueing up spells in a raid situation, but for more accuracy for let's say melee in a PvP situation you can change this manually to something closer to your world latency with the in-game command `/run SetCVar("SpellQueueWindow", latency)`, where you replace `latency` with a numerical value matching your world latency. I advice rounding up to the nearest 5ms above your actual latency, so if you generally have 51-53ms latency, set it to 55. This setting can only be changed out of combat. 

## [1.1.100-Release] 2019-01-15
### Changed
- Frequent updates enabled for player power crystal and mana orb. They should both be filling up even more smoothly now.

## [1.1.99-Release] 2019-01-14
### Added
- Added several item types to our custom actionbar tooltips. You should now be able to see what your food, Hearthstone and Flight Master's Whistle actually do. 

### Changed
- When the player is either grouped or in an instance, the target frame should now display a power crystal for other players instead of the level badge. Meaning you now can see the power type and percentage of enemy players in battlegrounds and arenas. 

### Fixed
- Fixed an issue where stack sizes of stackable items like food, herbs and similar placed on the actionbars didn't show up. 
- Removed a whole lot of class resource clutter from the personal resource display. 

## [1.1.98-Release] 2019-01-13
### Changed
- Keybind abbreviations should no longer rely on an English gaming client. 

### Fixed
- Issue with Clique should be solved now. Tested with spells bound to both mousebuttons and keys with and without modifier keys and on both player- and other targets. 

## [1.1.97-Release] 2019-01-12
### Fixed
- There should no longer be a gap 2x2 button large in the middle of the actionbars. That was a typo in last night's update! Sowwy! 

## [1.1.96-Release] 2019-01-11
### Added
- Added Affliction Warlock's Siphon Life, Discipline Priest's Smite and Enhancement Shaman's Searing Assault to the aura filter. 

### Changed
- Redid actionbar menu structure. It's easier to understand now. 

### Fixed
- Fixed an issue causing an error when hovering over inactive Blizzard micro menu buttons.  

## [1.1.95-Release] 2018-12-29
### Fixed
- Updated the nameplate back-end to automatically remove the new 8.0.1 patch personal resource display clutter. 

## [1.1.94-Release] 2018-12-29
### Added
- Added the option to cast spells on button downpress to the actionbars menu. This setting is enabled by default for new users, as it is for new users in the game itself now. 

## [1.1.93-Release] 2018-12-22
### Changed
- Changed default setting for actionbuttons to "cast on down". User option to change coming in next update. 

### Fixed
- The Blizzard focus unit frame should once again remain hidden. 

## [1.1.92-Release] 2018-12-20
### Added
- Some stuff. 

## [1.1.91-Release] 2018-12-15
### Fixed 
- Fixed a wrong upvalue in the actionbutton back-end that sometimes would cause charge cooldowns to bug out. 

## [1.1.90-Release] 2018-12-15
### Fixed 
- Fixed an issue that would cause bugs on reloads or when changing zones when tracking a reputation.

## [1.1.89-Release] 2018-12-15
### Changed
- Changed TOC version to patch 8.1.0 now that Blizzard has done it too.
- Moved styling of the game menu and the micro menu to the new layout system.
- Lowered threshold for showing absorb bars from 15% to 10% of full health value. 

### Fixed
- Reworked classpower element to be fully hidden when using a possessbar, overridebar or vehicles with no vehicleUIs.
- Fixed explorer mode hover area to also include player auras. 

## [1.1.88-Release] 2018-11-26
### Fixed
- Whitelisted the missing additional spellID entry for the "Whispers of Power" debuff in Shrine of the Storm, to prevent killing more players. 

## [1.1.87-Release] 2018-11-26
### Added
- Added basic group tools for raid leaders, raid assistants and parties including ready check, role poll, raid target icons, world marker flags and party/raid conversions. 

### Changed
- Added separate licenses for the engine and the project specific assets to clearify that this user interface is a copyright restricted overlay over an open source MIT licensed engine.
- Changed file- and folder structures to better indicate the above. 
- Changed fader library to be fully event driven, in an attempt to counter the issue with the macro driven states not fully responding during lag spikes. 

## [1.0.86-RC] 2018-11-18
### Fixed
- Fixed the action button area responding to mouseover events for the Explorer Mode, as it was slightly off.
- Fixed the smoothness of the initial fade-out after logging in or reloading with Explorer Mode enabled. 

## [1.0.85-RC] 2018-11-18
### Added
- Added "Explorer Mode", which is optional fading when the player is "safe", meaning not engaged in combat, having no target selected, no running debuffs and health above 90%, not currently in a group, not currently in an arena, not currently facing any bosses, and some other variables taken into consideration as well. Explorer mode can be toggled from the config menu. 

### Changed
- The action button backdrop should no longer fade in for empty vehicle action buttons, override buttons or temp shapeshift buttons. 

### Fixed
- Fixed an issue where action buttons sometimes when using overridebars in some quests would show empty buttons and empty tooltips, instead of fading these out as intended. 
- Added updates to the cooldown spirals of all normal action buttons as well as the zone ability and extra action button when shown, to attempt to counter the issue where the swipe color would randomly reset to almost fully opaque. 

## [1.0.84-RC] 2018-11-11
### Changed
- All custom frames created by the back-end's frame library now pretends to be forbidden. This works around various issues when used together with various addons trying to parse all available frames of certain types, like ConsolePort. 
- Adjusted castbar- and small unitframe backdrops to have a less intrusive and more fitting drop shade.
- Adjusted the color balance of the elite NPC classification badge to be slightly brighter, to be more in line with the rest of the UI coloring.
- Slightly adjusted vertex coloring and bumped the size of the group finder eye. 

## [1.0.83-RC] 2018-11-07
### Fixed
- Fixed a bug in the unitframe back-end that would cause raid frames with a two digit id to not get the needed events registered to properly update when members changed around. Only the first nine members of the raid would be properly updated. It litterally failed to count to ten. 

### Removed
- Disabled the Blizzard capture bars. 

## [1.0.82-RC] 2018-11-07
### Fixed
- The raid frames should no longer disappear on reloads for groups with 16 to 25 members.

## [1.0.81-RC] 2018-11-06
### Added 
- Added option to disable nameplate auras. 
- Added Horde and Alliance faction icons for PvP enabled units to the target unit frame.

### Changed
- Increased most library default alpha values for non-targeted nameplates while engaged in combat. Out of combat alpha remains the same. 
- Nameplate raid target icons now position themselves relative to how many if any auras currently are visible on the nameplate it belongs to. 
- Updated the chat window front-end to style the fonts and tabs of temporary windows to match the main chat window. 
- The player HUD castbar will now disable itself if the Blizzard setting to show the personal resource display is enabled.  

### Fixed
- Fixed some issues in the nameplate back-end that would cause elements to not be rendered correctly or at the right nameplate when nameplate visibility were toggled using keybinds. 
- Fixed some issues in the chatwindow back-end that would cause events to style temporary chat windows not to fire.
- Fixed a bug in the classpower plugin that would set nearly all power types except Runes to always show 5 points, which resulted in power types with a lesser maximum like Stagger to show several empty and poorly positioned backdrops.   

### Removed
- Removed a lot of redundant and unused textures. 

## [1.0.80-RC] 2018-10-30
### Added
- Added several Demon Hunter auras to the filters, including Soul Fragments! 

### Changed
- Slightly adjusted the player aura filter to accomodate some auras that didn't fall in line with our current system. 

## [1.0.79-RC] 2018-10-30
### Added
- Added Hunter's Barbed Shot, Harpoon, Serpent Sting and Wildfire Bomb to the aure filter. 
- Added Demon Hunter's Demon Soul buff to the aura filter.   

## [1.0.78-RC] 2018-10-29
### Changed
- Slightly adjusted the target nameplate inset from the top of the screen to make sure there's room for its 6 auras.  
- Changed power crystal colors to indicate the power's behavior rather than its exact type, as we feel many types basically are the same things under different names. So like all the various combo point systems, we found order in this chaos as well! We now separate all primary resources into fast, slow and angry powers! Fast resources are green, start at max, are used fast and generated fast. Slow is the color blue, starts at zero, is generated slowly through abilities and used fairly fast on other abilities. Angry is like slow, only purple and more fun. This system does not affect mana, which always will be displayed as a blue orb. 

## [1.0.77-RC] 2018-10-29
### Added
- Added auras cast by the player to the nameplates. Options coming later. 

### Fixed
- Fixed an issue with the target aura filter that would sometimes hide auras that should've been displayed according to the filter. Affliction Warlock's Corruption spell when talented with "Absolute Corruption" is an example of this. 

## [1.0.76-RC] 2018-10-28
### Fixed
- Fixed chat bubble backdrop inset to not overlap the border.

## [1.0.75-RC] 2018-10-28
### Added
- Added Clique support to all unit frames. 
- Added group role icons to the raid frames. 
- Added group leader, group assistant, master looter, main tank and main assist raid role icon(s) to raid frames. We're only showing a single icons for all of the listed, in the prioritized order listed. 

### Changed
- Squashed the actionbutton system into a single library, since all the functionality from the intended alternate versions were all baked into the same button type template anyway. 

### Fixed
- Worked around an issue with how party-, arena-, boss- and raid frames were stored that would trigger a blizzard bug preventing `/framestack` from functioning.
- Fixed an issue where a wrongly registered event in parties could lead to the party portraits sometimes updating a bit delayed. 

## [1.0.74-RC] 2018-10-26
### Added
- Added raid frames. 
- Added a new unit status element for mainly meant for our raid frames, showing if the player is currently out of mana, disconnected, dead or away from keyboard.

### Changed
- Changed how aura borders are colored: 
	- Buffs on friendly targets remain uncolored / gray. 
	- Debuffs on friendly targets are now colored according to spell school.
	- Buffs on hostile targets are now colored green. 
	- Debuffs on hostile targets are now colored red.

### Fixed 
- Arena/PvP frames should no longer only show your own character.
- Fixed an issue that would leave the minimap black until zooming in or out after zoning or reloading into an indoors area. 

## [1.0.73-Beta] 2018-10-23
### Fixed
- Fixed an issue for Warlocks that would only show 1/10th of their actual soul shards, leading to the impression that shards were always empty.

## [1.0.72-Beta] 2018-10-21
### Changed
- Changed the player- and target unitframe aura filters to work differently in and out of combat. Made the filters in combat stricter to remove some of the excessive spam we've been seeing lately, but also allowed the display of most long duration auras or non duration auras like toys and mounts out of combat. 

### Fixed
- The mana orb for druids should no longer be empty when instantly resurrecting in an instance without a ghost period between the death and the resurrection. 
- Fixed an issue where the player- and target frame aura highlighting sometimes would remain visible on fresh auras that shouldn't have them.

## [1.0.71-Beta] 2018-10-19
### Added
- Added the option to disable the talking head frame.
- Added the option to disable alerts. Alerts are the rectengular messages telling you about loot, currencies and similar appearing at the top of your screen.
- Added Jack-o'-Lanterned! to the aura whitelist for the player frame so we can disable those f'ing pumpkins they keep putting on us! >:(

### Changed
- Simplified some menu options, and added some coloring. 
- Modified the backdrop of the nameplate glow texture so units with threat that aren't your primary target won't appear bright red as their health declines anymore. 

### Fixed
- Fixed how the arena- and party frame visibility drivers are registered at startup, to deal with the issue where frames set to be hidden wouldn't be hidden until the option was toggle on and back off again. 

## [1.0.70-Beta] 2018-10-18
### Added
- Added the option to disable the party frames.
- Added the option to disable the arena frames.

### Changed
- New custom designed raid target icons for the nameplates!
- Nameplate raid target icons now remains fully opaque even when the nameplate itself is faded out, as we felt it made no sense to tone down markers put there with the intention of keeping track of a unit. 
- Slightly shrunk the talking head frame. 
- Redid the options menu to be structured by module. 
- Sub-windows in the options menu now open relative to their parent buttons instead of their parent button's window. 

### Fixed
- The issue where some classes like Warriors suddenly appeared to have ten times more total rage have been resolved. 

## [1.0.69-Beta] 2018-10-15
### Added
- Added a player mana value text to the power crystal when mana is available, below maximum and not the currently active power type.

### Changed
- Increased the scale of the objectives tracker by one tenth of its original size. 

### Fixed
- Fixed the position of the unit name on the target of target unit frame.

## [1.0.68-Beta] 2018-10-12
### Added
- Added unit name to the target of target unit frame. 

### Changed
- Debuffs on friendly targets and buffs on hostile targets are now highlighted with red and green colors.
- Stealable buffs for Mages on the target frame are now highlighted with an arcane blue color. 
- Small (boss, arena, pet, focus, tot) and tiny (party, raid) unit frames will now display their health values as a percentage of the maximum health when the unit has less than full health. This is to aid players in knowing when to use their various class abilities. 
- Slightly adjusted the target of target unitframe position to not cover parts of the target unitframe's health percentage and castbar time value.
- Major rewrite of the loading order, to have style- and layout data loaded last in the loading chain before initialization begins.
- Made more steps towards making both the back- and front end code separated from the style- and layout methods.
- Moved all unit frame element spawning code into the styling section of the addon. First of many similar changes to come. 
- Further renamed front-end files to better indicate what is custom and what is modified blizzard elements. 
- Timer bars like Fatigue, Breath, instance start countdowns and similar has been moved slightly down to not crash so often with the objective popups in the middle of the screen. 
- Arena enemy frames (also used in battlegrounds for flag carriers) now properly display the class color of the players. 
- The UI now fades in more visibly after entering the world. Unless you have addons activated that severely delay the reload process, like TradeSkillMaster, Zygor Guides or similar addons with large database iterations upon loading. 

### Fixed
- The actionbutton backdrop grids should now also become visible when the cursor holds spells, macros, companions, mounts and items that can be placed on the actionbars. 
- Updated the cast- and health bar post updates for small unit frames with the same code used in the target frame, to avoid the "blank bar" issue that would sometimes happen after a spellcast. 

## [1.0.67-Beta] 2018-09-29
### Fixed
- The game menu will no longer disappear when using the addon ConsolePort.
- Health/Castbar value/name visibility update for various target frame types. 

## [1.0.66-Beta] 2018-09-28
### Added
- Added pet autocast textures to the action buttons. 
- Added pet autocast toggling when right-clicking action buttons containing autocastable pet spells. 

### Changed
- Changed the spell activation highlight textures to something less Blizz. 

## [1.0.65-Beta] 2018-09-25
### Added
- Added raid target icons to the nameplates!

### Fixed
- Fixed a wrong upvalue in the actionbutton element that would sometimes cause nil errors when the icons of available pets to summon were changed or updated. 

### Removed 
- Removed a lot of unused and redundant code from the nameplate library, as it's been using the same plugin system as the unitframes for some time, and no longer needs its own post updates for the various nameplate elements. 

## [1.0.64-Beta] 2018-09-22
### Fixed
- Fixed a nil error introduced in the previous statusbar library update. 
- Fixed a wrong method usage in the nameplate castbar post update.

## [1.0.63-Beta] 2018-09-22
### Changed
- New classification badge for bosses! They should now stand out more from elites and rares. 
- Actionbutton performance upgrades.
- Adjusted size of most small bars. 
- Adjusted alignment of small bar backdrops. 
- Target frame health bar now change color according to your current threat towards the target. 
- Name plate health bar color now follows the same threat coloring scheme as the previously mentioned target frame.
- Removed some post updates from the statusbar library to allow for more dynamic texture changes. 

### Fixed
- Death Knight rune sort order is functioning properly again, and rune depletion should once again match the order and the transparency.
- Rewrote cast name and value post updates for target unit frame as well as all the small frames. 
- Fixed the issue where reversed small bars with auras (namely boss- and arena unit frames) weren't reversed at all. They now grow from their own side of the screen, like intended.
- Further removed any global alpha handling during cinematics, as our interface master frame is parented to UIParent now, and visibility handled by WoW.
- Spell charges on the extra action button should no longer be covered by the button border. 

## [1.0.62-Beta] 2018-09-18
### Added
- Added bufftimers of the type that compliments that player's altpower bar in some quests like the horse riding on the Norwington Estate in Tiragarde Sound. These timers have been integrated into the same system as the instance countdown timers and breath- and fatigue timers. Why complicate a system that works?

### Changed
- Minimap bars now always show descriptions for artifact power and reputation when any of them are set to being the single visible bar. 

### Fixed
- Adjusted the icon update method for action buttons, as some updates still weren't getting through the throttling while using vehicle bars that changed when inside the vehicle. 
- Removed some redundant code from the frame library that sometimes would cause the minimap border to remain hidden after a cinematic was shown. 
- Removed the last of the blizzard textures from the instance/bg countdown timers. 
- Rewrote the whole aura widget alignment, as it still wasn't working as intended. 
- Fixed the inner ring percentage value remaining visible when switching the minimap bar display from dual to single. 

### Removed
- Removed the blizzard bufftimer bars from the interface, as we have our own now. 

## [1.0.61-Beta] 2018-09-16
### Added
- Added focus unit frame.
- Added cast name to arena-, boss-, pet, target of target and the new focus unit frame. 
- Added a simplistic back-end time library to easier handle time formatting and callbacks throughout the user interface. Also updated the code to retrieve server time to be more in line with what Blizzard is currently using, as the previously followed recommendations from Wowpedia seems to be based on guesswork and not facts. 

### Changed
- Changed the time mode strings visible in tooltips and output in the chat to better indicate what the difference between local and game time really is. 
- Restructured boss-, arena-, pet, target of target and the new focus frame front-end code. 

### Fixed
- Fixed aura widget alignment, as this was miscalculating the available row size in the widget, causing the last aura to unintentionally be placed on a new row. 

## [1.0.60-Beta] 2018-09-15
### Fixed
- Changed how actionbuttons update their content to allow new spells appearing while in a vehicle.

## [1.0.59-Beta] 2018-09-09
### Added
- Added basic chat bubble styling.

### Changed
- Made the aura time display format more accurate and dynamic.

## [1.0.58-Beta] 2018-09-09
### Changed
- Unitframe health elements now instantly updates on target changes for target, focus and mouseover units. 
- Unitframe health element smoothing time reduced from .5 to .2 seconds, for a more responsive raiding expererience.

### Fixed
- Pet- and ToT unit frames now properly display the localized text "Dead" when the unit is dead. 
- ToT frame now once again displays the localized text "Offline" when the unit is an offline player. 
- Updated how the actionbutton library retrieves spellID from macros to properly work for 8.0.1. This was affecting spell highlighting. 
- Updated how the unitframe cast element handles post updates, to avoid the issue with missing health numbers on the target frame after a missing post update.

## [1.0.57-Beta] 2018-09-06
### Changed
- Folder restructuring. Aiming at a better logical split between back-end, front-end and configurations.

## [1.0.56-Beta] 2018-09-05
### Changed
- Target frame boss power crystals now face the same direction as the target frame does. 
- Target frame boss power crystals are now hidden when the boss is dead. 
- Target frame boss power crystals are now hidden when the boss has no power.
- Target frame level badge is now hidden when the target is dead. 
- Target frame level badge is now hidden when the target is a boss. 

### Fixed
- Fixed a visual issue where the castbars seemingly would "yoyo" back and forth when switching from a normal cast to a channel or vice versa. New casts and channelings aren't smoothed anymore, they are forced, thus assuring they're accurate.

## [1.0.55-Beta] 2018-09-04
### Fixed
- Fixed a tooltip display issue with the reputation bar that would list you at one standing rank higher than you were. This was only a tooltip issue, and did not affect the bar display or the values. 
- Fixed a bug in the boss power crystal value's update method when the boss had zero power. 
- Fixed size alignment of boss threat texture in instances. 
- Fixed size and alignment of boss cast bars.

## [1.0.54-Beta] 2018-09-03
### Changed
- Reduced the time threshold for which unit auras get their remaining duration shown from 10 to 3 minutes. 

### Fixed
- Fixed the nil issue with the artifact power bar.  

## [1.0.53-Beta] 2018-09-03
### Added
- Added reputation tracking to the minimap bars. The current display priority is Experience Points > Reputation > Artifact Power, and the two first of whatever is available will be displayed. Option to manually choose what to display will come later. 
- Boss level enemies now have a power crystal displayed instead of a level skull! Their boss status is still indicated through the red boss badge, so there should be no confusion of their status. 
- Boss level enemy power bar should also show alternate power. Untested. 

## [1.0.52-Beta] 2018-09-01
### Added
- Added our new PayPal link [www.paypal.me/azerite](https://www.paypal.me/azerite) to the README! 

### Changed
- Target of target now has text indicating when its unit is dead or offline, to avoid "empty" frames which falsely appear to be bugged.
- Player and target unit frame overlay castbars had their opacity bumped up a little, to make them easier to spot for people with worse monitor contrast ranges or possibly worse eyesight than mine. Either way it was probably too subtle for the majority, and thus needed changing. 
- The chatframe input boxes now follow the same font size and style as their respective chat frames.
- Rewrote the unit and visibility driver system for player, pet and grouped unitframes again. Tested with vehicles in Ulduar, with Legion cannons in Felsoul Hold in Suramar. The UI reacts and behaves as the default Blizzard UI does in these situations, so for now we'll consider this fixed. Further adjustments will be needed if any further situations arise and can be verified and reproduced.
- Adjusted the player and target aura filters to include a lot of short duration general auras. 
- Brightened up the Druid class color. Doesn't need to be toned down in this UI! 

### Fixed
- The chatframe input box should no longer be hidden when viewing other chat tabs than the primary one when using "classic" chat mode. 
- Blizzard mouseover tooltips with objects that aren't units but still have health now get their health bars colored green, and not just whatever was left over from the previous unit with a unit colored health bar shown. 

## [1.0.51-Beta] 2018-08-29
### Added
- Added 200 auras from Battle for Azeroth dungeons to the aura whitelists for player and target unitframes.
- Added 252 Well Fed! auras to the aura filter. 
- Added an abbreviated health text to Blizzard mouseover tooltip statusbars.

### Changed
- Restructured the aura lists to avoid spam and maintain clearity in the code.
- Adjusted the position and color of aura stack counts to match the actionbuttons in look and logic.

### Fixed
- Fixed the issue causing Blizzard mouseover tooltip statusbars to have their color flicker back and forth from the unit color and green. 

## [1.0.50-Beta] 2018-08-29
### Added
- The vehicle exit button on the minimap can now also dismount the player if the player currently is mounted.
- The vehicle exit button on the minimap can now also request a stop at the next flight point when using a taxi.

## [1.0.49-Beta] 2018-08-28
### Added
- Added a set of crowd control auras to the aura filter lists. For the time being they'll be shown on the player and target frame, but more advanced filtering will be added later. 

### Changed
- Added the word "Empty" to the empty alternate player power bar when it's empty, to make it appear less broken. 
- Changed the text color used on dead units to something that is actually possible to read. 

### Fixed
- Rewrote the pet- and player frame vehicle switching mechanics to work better with the various override bars and similar. The Legion lay line race now works.  

## [1.0.48-Beta] 2018-08-28
### Added
- Added better coloring to the name and health bar of Blizzard's mouseover unit tooltips, and did some general clutter cleanup.
- Added a little red glow around the player frame combat indicator. It doesn't pulse, but it's more visible than just the icon.

### Changed
- Characters which have manually disabled their experience gains or reached their account's maximum level regardless of what the current maximum expansion level in World of Warcraft is will no longer have an empty experience bar visible. 
- Added a fairly transparent swipe texture to action button charge cooldowns until we can figure out why the edge texture refuses to show up. 

### Fixed
- Minimap XP description text should now hopefully update when gaining a level.
- Fixed a division by zero error when forcefully updating experience and artifact power widgets on login.
- Fixed a double underscore typo related to the new aura filtering that could cause excessive amounts of bugs.
- Actionbuttons now once again displays a slot texture when spells are dragged to and from the buttons.

## [1.0.47-Beta] 2018-08-27
### Added
- Added the first iteration of a much better aura filtering system. Far more to come!
- Added basic backdrop styling and slight statusbar re-alignment to the blizzard tooltips. No other changes done.
- The zone ability button is now also styled and moved similar to the extra action button.

### Changed
- Recolored all normal nameplate castbars to a more neutral color. Protected casts remain red for enemy units, but are now green for friendly units.
- Extensive folder rearrangement and code restructuring.
- Started moving a lot of the repeatedly used functions to template files. 

### Fixed
- Now properly hiding the larger minimap spinbar description text if the content of the bar isn't currently experience.
- The extra action button keybind text should now be above the button border.
- Fixed a bug that would always use the boss sized cast texture for the target frame.

### Removed
- Removed the logon message from the user interface, as it easily becomes spam with both guild message, spec message and multiple other addons adding startup messages. 

## [1.0.46-Beta] 2018-08-22
### Fixed
- Rewrote how the two minimap spinbars for artifact power and experience are toggled and displayed to avoid the wrong bar being shown or updated.
- Solved a problem with how events were removed from the various libraries that sometimes could cause unpredictable bugs. 

## [1.0.45-Beta] 2018-08-22
### Added
- AlertFrames are back!

### Changed
- Nameplate castbar color now varies based on whether or not the unit is your enemy or not.
- Moved talking head all the way to the top. 
- Alerts now grow from the top towards the bottom of the screen.

### Fixed
- Nameplate castbars once more get a spiked border for uninterruptable casts.
- Fixed an issue with the portrait widget where `PORTRAITS_UPDATED` was registered as a unit event, causing an error.
- Unit frame aura stack counts are no longer hidden behind the aura borders.
- Action buttons now react to selfcast- and focus modifiers.

## [1.0.44-Beta] 2018-08-18
### Changed
- Action buttons are new desaturated and toned down when the player is dead.
- Moved the talking head frame farther up the screen, away from the unit frames and actionbars. 

### Fixed
- Fixed the issue causing a bug when trying to show the value on the player's alternate power bar.
- Durability and vehicle seat indicator should once again be positioned in a more fitting place. 

## [1.0.43-Beta] 2018-08-17
### Added
- Added a custom player alternate power bar, close to where the player castbar is. 

### Changed
- Party frames should now be hidden when the player is in a raid group, regardless of the size of that group. 
- Moved the ExtraActionButton and ZoneAbilityButton somewhat up and towards the right, to avoid them covering the actionbars.
- The Blizzard ObjectivesTracker will now be faded out during combat, arena fights and boss fights.
- The target of target frame should now have smoother bar transitions.

### Fixed
- Power crystal threat texture while grouped or in an instance should no longer appear in the middle of your screen.
- Spells with no cost should now get their spell range properly displayed and colored in their tooltips. 
- Spells that are channeled should now properly display and color this property in their tooltips. 
- Updated main actionbar page drivers for rogues and warriors.

### Removed
- Removed the blizzard alternate player power bar as we have our own custom one now. 

## [1.0.42-Beta] 2018-08-16
### Added 
- Added cast name and cast duration value to the target unit frame. 

### Fixed
- Target frame auras are once more in the right place.
- Target frame castbar once more grows towards the left side. 
- When you've hit maximum level or disabled XP, the Artifact Power tooltip should no longer get a new set of lines added to it every time you mouse over the Artifact Power bar. It should now reset properly. 

## [1.0.41-Beta] 2018-08-15
### Fixed
- The target health bar should no longer be flipped the wrong way.
- The target unit classification icon has been moved back to where it belongs. 
- The target absorb bar now shows up again, and its value text is in the right place too.

## [1.0.40-Beta] 2018-08-15
### Added
- A Group Finder Eye is now available on the minimap when queued using the group finder.

## [1.0.39-Beta] 2018-08-15
### Changed
- Parented the Blizzard ObjectivesTracker to our own master frame, to prevent it from covering the Blizzard Micro Menu.
- Continued the work on code restructuring towards the new single file layout system. 
- Changed how various textures are attached to unit frame aura buttons to attempt to fix the "misplaced border" issues that I so far have been unable to reproduce. 
- Added some bonus bars to the actionbutton page switcher for all classes, also added an action icon update regardless of whether or not the actual page was changed. 
- The target of target unit frame is now hidden when your current target is a harmless level 1 critter, or if the target of the target is yourself as this is already indicated by the red eye on the target portrait.

### Fixed
- Fixed bad positioning of the player frame combat indicator after recent code restructuring. 
- Fixed the missing minimap zone- and latency texts. 
- Fixed a lingering "ExtraPower" bug after the code restructuring.

## [1.0.38-Beta] 2018-08-14
### Changed
- Moved Blizzard ObjectivesTracker modifications to its own file. Remember to restart game for the file to be discovered!

### Fixed
- Fixed more bugs related to the Blizzard ObjectivesTracker.

## [1.0.37-Beta] 2018-08-14
### Fixed
- Fixed bugs related to the Blizzard ObjectivesTracker.

## [1.0.36-Beta] 2018-08-14
### Fixed
- User interface works for non-mana classes again now. Sorry! 

## [1.0.35-Beta] 2018-08-13
### Added
- Added back the Blizzard ObjectivesTracker. Finished or not, you'll be needing it now! 

### Changed
- Let's call it a beta. 

## [1.0.34-Beta] 2018-08-12
### Added
- Added a minor welcome message to point new users towards the cogwheel settings button.

### Changed
- Started splitting layout data and modules applying that data into separate folders and files.
- Complimentary bar buttons will now always be displayed as 2 rows of buttons when the layout allows for it. This means that when the primary bar has 7 or 12 buttons, the complimentary bar will show always be displayed as 2 rows, either with 3 buttons in each row or 12. It makes sense when you see it. 
- Update actionbutton hover areas to match where the buttons are actually placed with the various layouts now. Goal is to minimize screen usage, and keep the hovereffect to the actual button areas.

### Fixed
- The minimap zone text should now properly update when moving through outdoor zones. 

## [1.0.33-Beta] 2018-08-11
### Added
- Added an options menu available from right-clicking the cogwheel found in the bottom right corner of the screen. Current options are all related to visibility, button counts and fading settings of the actionbuttons, but more will come! The menu is fully usable even during combat, as it's written mainly using the restricted environment and not regular lua. So you don't have to wait until you're dead to make that bar with your life saving ability visible. 

### Changed
- Started restructuring the code for easier UI mass production later on. 

### Fixed
- Fixed an issue that would sometimes cause custom tooltips to be drawn in a lower FrameStrata. All tooltips are always put in the TOOLTIP FrameStrata when shown now.
- Fixed a bug in the module library that would prevent it from ever returning existing modules. 
- Fixed a bug in the chat command library that would prevent chat commands from receiving a proper argument list. Lucky for us we're not using any chat commands so far, so technically it was a non issue. 

## [1.0.32-Beta] 2018-08-09
### Changed
- Workaround for Auctionator's dumb coding style and `EnumerateFrames()` usage.

## [1.0.31-Beta] 2018-08-08
### Fixed
- Having more than 3 friendly auras on the target unit frame should no longer produce a nil bug.

## [1.0.30-Beta] 2018-08-07
### Changed
- Player and target unit frame aura icons have had their border slightly slimmed down, and their icons slightly fattened up. 
- Personal Resource Display (personal nameplate) is now always fully opaque when shown, it does not follow the opacity rules applied to the rest of the nameplates. 

### Fixed 
- Fixed an issue where auras wouldn't probably be hidden when their timer ran out. 

## [1.0.29-Beta] 2018-08-06
### Changed
- Added a slightly fuzzier edge to the XP- and ArtifactPower ring bars to smoothe them out a bit, as the pixelation from Blizzard's cropping and rotation was a bit much. 

### Fixed
- Minimap should properly hide minimap icons from other addons now. A custom buttonbag and/or MBB integration is in the works, though not fully ready yet.

### Removed
- Removed the rested bonus XP bar. Will be adding a new indicator soon. 

## [1.0.28-Beta] 2018-08-03
### Added
- Added health percentage on the target unit frame for bosses.
- Added item tooltips for actionbuttons containing items and not actions or spells.

### Changed
- The small boss only unit frames now display a health number when at full health, but a percentage value only once the fight has begun and their health started dropping. Gotta see when they hit those magic percentages linked to their abilities! 

## [1.0.27-Beta] 2018-08-02
### Changed
- Threat coloring is now only visible in grouped instances.
- Class resources are now only visible when the target can be attacked.
- Chat frames, breath timers and Azerite styled tooltips should now follow the rest of the non-Blizzard parts in scaling.

### Fixed
- Fixed an issue where sometimes after a major lagspike the minimap post update could attempt to resize it in combat and cause a taint. 

## [1.0.26-Beta] 2018-08-01
### Changed
- Moved nameplates to the BACKGROUND strata, to avoid them overlapping the unitframes and other elements.
- Minimap northtag is now hidden while the XP- and Artifact Power bars are visible.
- Adjusted positions of minimap texts like the time, zone name, latency and so on. Also adjusted the overlay ring bar texts. 
- Moved the new mail icon slightly down and closer to the minimap texts.
- Slightly increased the font size of the unit name in the target unit frame, and moved it slightly up and right towards the portrait.
- Slighlty increased the font size of the unit level in the target unit frame. 

### Fixed
- Found and fixed the wrongly named texture path that was causing a big black box instead of a threat texture around the target frame health bar of enemies with a level capped border texture. No more black box!

### Removed
- Removed a redundant file that was re-applying the faulty taint fix that created taints instead of removing them. We got two bugs for the price of one, when we actually wanted none. Fixed. 

## [1.0.25-Beta] 2018-08-01
### Changed
- Changed the Shaman class color to a non-Mana blue. 
- Made the neutral reaction color more yellow.
- Unitframe tooltips from battle pets should now have their unit names and health bars colored according to the battle pet's rarity.  

### Fixed
- Removed a taint fix related to chat frames and overlay glows that created taints instead of fixing them. 

## [1.0.24-Beta] 2018-07-31
### Fixed
- Fixed a nil bug occurring when opening to some addon menus.

## [1.0.23-Beta] 2018-07-31
### Added
- Added threat textures for player power crystal, player mana orb and target portrait frame. The display should be much more balanced and consistent now. 

### Changed
- The chat emote / language button now has a different texture. 
- Reduced the chat button size with 20% of their previous size - or 25% the current size, all depending on which size you wish to relate that number to. 
- Players that have manually disabled experience gains will now get the level capped version of the player frame. This also applies to the target frame when they are targeting themselves. Idea is to make twinks feel more epic. It is currently not decided whether or not we're going to apply this to all players with experience gains removed while inside a twinked battleground. 

### Fixed
- Rewrote the health coloring plugin to accomodate for the rare cases where the class of a player isn't available.

## [1.0.22-Beta] 2018-07-30
### Added
- Added threat textures for player- and target unit frame health bars. Power/Mana- and portrait coloring coming!

### Changed
- Slightly reduced the size of the spell activation highlights as they were completely covering the button border texture.

### Fixed
- Added missing events to properly update spell activation overlay glows on the actionbuttons.

## [1.0.21-Beta] 2018-07-29
### Changed
- Corrected changelog date for the previous entry, as it was in the actual future. 
- Changed the size and alignment of the protected nameplate cast border to fit the health bar better.
- Removed some more redundant statusbar library callbacks, as they could potentially cause endless loops and stack overflows.

## [1.0.20-Beta] 2018-07-29
### Added
- Added red coloring and a spiked shield border to nameplate castbars when the cast is uninterruptable.

### Fixed
- Fixed a bug preventing you from canceling your own buffs, even when out of combat.

## [1.0.19-Beta] 2018-07-29
### Added 
- Added a custom vehicle exit button. A flight stop button is in the works!
- Added a North tag to the minimap.

### Changed
- Attempting an experimental change where the hidden action bar row is split into two sections, each reacting separately to mouseovers. The purpose is to limit number of fade-ins for those with a lesser number of total buttons used.  
- Friendly players will now get their nameplates colored as civilians, and not their class color which would make them appear as enemy players. 
- Relocated mirror- and start timer backdrop textures to the bar frame, not the timer frame, in an attempt to avoid the "hovering empty bar" bug.
- Rewrote the frame library's scale handling. All sizes are now relative to a virtual screen height of 1080, regardless or resolution or display size. Ratio will be the same as your window or monitor, except when the width is equal to or above three times a 16:10 monitor whereas it will be treated as a triple monitor setup and center the user interface on the middle monitor. 

### Fixed
- Vehicle unit frames should now be working. 

### Removed
- Removed the Blizzard vehicle exit and flight stop buttons.

## [1.0.18-Beta] 2018-07-28
### Added
- Added styling to Blizzard popup windows.
- Added styling to Blizzard mirror timers.
- Added styling to Blizzard start timers.
- Added a toned down dead and empty skull for the level display of dead units.

### Changed
- Upgraded the high level skull texture for bosses or very high level units.
- Modified boss unit frames to match target of target- and pet- unitframes in size and look. 
- Modified arena enemy unit frames to match target of target- and pet- unitframes in size and look. 
- Modified the player cast bar to match the previously listed frames in size and style.
- Increased XP- and ArtifactPower percentage text font sizes.

## [1.0.17-Beta] 2018-07-25
### Added
- Added some button textures to the various chat frame buttons.
- Added library to handle widget containers and element plugins. This is now used as a template for all unitframes. 

### Changed
- Updated the experience- and artifact power bar textures.
- Updated the target unit frame's unit classification- and targeting icons.
- The main chat window icons are now only visible when the editbox of the main frame is visible. 
- Moved aura filter methods to a single file to better be able to streamline the experience in upcoming updates. 

### Removed 
- Removed some redundant or outdated image files. 

## [1.0.16-Beta] 2018-07-24
### Changed
- Actionbutton grids will now be hidden for empty buttons, unless you've currently got a spell or item on the cursor.
- Now hiding the whole interface until 1.5 seconds after you've entered the world, to avoid seeing "flickering" from the textures and elements not created before this point.

## [1.0.15-Beta] 2018-07-24
### Changed
- Actionbuttons will now remain visible when a spell flyout is open or when spells are currently dragged using the mouse cursor.
- Actionbuttons that contain flyoutbars will now have a yellow arrow indicating that. 

## [1.0.14-Beta] 2018-07-24
### Fixed
- Fixed an bug causing an error when you tried to drop a spell onto your actionbars.

## [1.0.13-Beta] 2018-07-23
### Changed
- Shortened the delay after you leave the minimap xp toggle button until the xp/ap frame fades out, and made the actual fading a bit faster too. 

### Fixed
- Added a fallback for finding the window size when logging in with non-fullscreen windowed mode. Will rework the entire system to work better with more window sizes and larger or ultra wide screens, but this hotfix will do for now. 

## [1.0.12-Beta] 2018-07-23
### Changed
- Added a parent frame to the party frames handling hiding in raids, leaving the party frames own visibility drivers untouched.
- Made a larger part of the player energy crystal / mana orb area right-clickable in addition to the player health bar.
- Made the actionbutton mask texture far more perfect in shape to make it work better with actionbutton fade-outs.  

### Fixed 
- Fixed an issue that caused the Artifact Power bar to not properly be displayed on the first login. 

## [1.0.11-Beta] 2018-07-23
### Fixed
- Fixed an issue that caused action buttons containing spell flyouts to become tainted and prevent casting. 

## [1.0.10-Beta] 2018-07-23
### Added
- Added Player Pet unit frame.
- Added Target of Target (ToT) unit frame.
- Added missing spark maps to party- and bossframe cast-, absorb- and health bars.

### Changed
- Slightly increased the size of the floating player cast bar.

## [1.0.9-Beta] 2018-07-23
### Fixed
- Another party- and bossframe visibility driver update. It's an alpha. 

## [1.0.8-Beta] 2018-07-22
### Fixed
- Updated the party unitframe visibility drivers so that party frames should be shown while in groups of 2-5 players. 

## [1.0.7-Beta] 2018-07-22
### Added
- Added the "Happy Feet" auras to the unitframe aura whitelist. 

### Changed
- Reduced patch 8.0.1 build number requirement to 27101, since some clients still can log in using that build. 

## [1.0.6-Beta] 2018-07-22
### Fixed
- The micro menu's toggle button's tooltip now properly disappears when you move the cursor away from the config button.
- Fixed a localization typo preventing mouse wheel keybinds from being abbreviated like other long keybind names are.

## [1.0.5-Beta] 2018-07-22
### Fixed
- Fixed a bad event registration in the unitframe library's aura element causing classpower to not properly toggle on target changes.

## [1.0.4-Beta] 2018-07-22
### Changed
- Increased the size of the target unit frame's hit rectangle so that the target portrait also can be clicked to access right-click menus and similar.
- Increased party unit frame size by roughly eight percent.
- Increased the font size of the mana orb value text.
- Increased font size of actionbutton keybinds and spell charges.
- Made the wood texture coloring slightly brighter across the entire interface.
- Aligned the actionbuttons slightly better with the player unit frame.
- Move tooltip unit levels to the top right side of the unit tooltips, instead of embedding it in the name. We should be able to see the names without clutter.

### Fixed
- Keybinds are now properly assigned to pet battle buttons while enganged in a pet battle. 
- Blizzard Microbuttons will no longer become and remain visible during and after pet battles.
- Mana orb transitions should once more be smooth and properly updated. 
- Fixed a bug in the tooltip libraries that could cause bugs in some locales while hovering over NPC unitframes. 

## [1.0.3-Beta] 2018-07-21
### Changed
- Limited amounts of full ActionButton updates to address a severe performance issue experienced from the ActionBar module while using abilities.

## [1.0.2-Beta] 2018-07-21
### Added
- Added boss unit frames with health, cast bars, and a few auras. 
- Added arena enemy / battleground flag carrier unit frames with health, cast bars, and a few auras. 

## [1.0.1-Beta] 2018-07-21
### Fixed
- Actionbutton cooldown counts should hopefully no longer be stuck at "0.0".
- Actionbutton cooldowns should now update when you lose control of your character.
- Actionbutton icon now properly changes when you pick up or put down spells on the bars.
- XP bar description telling what level we'll gain next now actually shows the next level instead of the current. 

## [1.0.0-Beta] 2018-07-20
- Public Beta. 
- Initial commit.

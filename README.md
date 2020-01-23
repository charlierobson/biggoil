# biggoil

### Fast action game for 16K ZX81.

Pure machine code action FTW.

Collect the oil from the underground tunnels. Do not let the enemies touch the pipe that you pull along behind you. Enemies self-destruct upon contact with the drill head.

Default controls:

_UDLR / FIRE_  
QAOP / SPACE 

Redefine keys on title screen.

[DOWNLOAD](https://github.com/charlierobson/biggoil/raw/master/biggoil.p)

### Enhanced features:

* Music and sound effects.
  * ZonX compatible AY chip is required, E.G. Mr.X, ZXpand+, ZXPand+AY
* Joystick control
  * ZXpand+, ZXpand+AY standard.

All game and artifact handling code by Sir Morris Bigg.  
STC music player by Andy Rea.

[Sketchy](https://charlierobson.github.io/p5-sketchy)

[AYFXEdit](https://shiru.untergrund.net/software.shtml)

[BRASS](http://www.benryves.com/bin/brass)


### Archived development log
___

### bugs:
* ~~pipe turns are broken after retracting~~
* ~~enemies crossing leave an enemy character behind~~
* ~~'hello' sound too loud~~
* ~~invalid entrances can be selected~~
* ~~enemies erase non-solid inverse characters~~

### engine
* rom dependency removal via custom irq handler
* ~~non-interruptable SFX~~
* ~~fix race condition potentials~~
* ~~make 'map' of the level at the start~~
  * ~~either 0 for passable (dot, space) or 128 for impassable~~
  * ~~player fills map with grey~~
  * ~~enemies unplot themselves using map data (no more lost dots, crashing through scenery)~~

### features:
* ~~difficulty ramp~~
  * ~~enemy spawn rate increases every level~~
  * ~~enemy speed~~
* pick-ups
  * slow enemies
  * stop enemies
  * nuke enemies
  * poison
* ~~timer~~
* ~~enemy animations~~
* ~~sound~~
* ~~extra lives~~
* different enemy types
* character animation tables (and hence UDG possibility) for:
  * ~~boring head~~
  * ~~enemies~~
* ~~title screen~~
* ~~game over screen~~
* ~~control customisation~~
* music:
  * level begin jingle
  * level complete jingle
  * ~~title screen~~
  * ~~game over screen~~

### whimsy
* ~~cloud animation~~
* ~~lorry animation~~
* message?

### enemy behaviour
* ~~turn around when obstructed~~

If you're reading this well done! The ZX81 scene is dead. Long live the ZX81 scene.

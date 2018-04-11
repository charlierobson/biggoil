# biggoil

## todo:

### bugs:
* ~~pipe turns are broken after retracting~~
* ~~enemies crossing leave an enemy character behind~~
* ~~'hello' sound too loud~~
* ~~invalid entrances can be selected~~
* ~~enemies erase non-solid inverse characters~~

### engine
* ~~non-interruptable SFX~~
* rom dependency removal via custom irq handler
* ~~fix race condition potentials~~
* ~~make 'map' of the level at the start~~
  * ~~either 0 for passable (dot, space) or 128 for impassable~~
  * ~~player fills map with grey~~å
  * ~~enemies unplot themselves using map data (no more lost dots, crashing through scenery)~~

### features:
* difficulty ramp
  * enemy spawn rate increases every level
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
* character tables (and hence UDG possibility) for:
  * boring head
  * ~~enemies~~
* ~~title screen~~
* ~~game over screen~~
* control customisation
* music:
  * level begin jingle
  * level complete jingle
  * ~~title screen~~
  * game over screen

### whimsy
* ~~cloud animation~~
* ~~lorry animation~~
* message?

### enemy behaviour
* ~~turn around when obstructed~~

# Bugs

# DONE

- [x] Use _update60
- [x] Refactor movement
- [x] Add "tests"
- [x] Fix line
  - [x] fix line end point not aligning with player
  - [x] line collision should cancel player movement|dash
- [x] Add "dash" move
  - [x] dmg collider and push back
  - [x] add particle trail
  - [x] change dash trail color
  - [x] drain energy when dashing
  - [x] handle dash vs dash collision (cancel)
  - [x] cancel dash if hit with line weapon
- [x] Add blocking (energy shield)
  - [x] drain energy while shielding
  - [x] reflect line shots
- [x] rock, paper, scissor mechanic
    - shield beats laser
    - dash beats shield
    - laser beats dash
- [x] fall into void
  - [x] subtract from player score (enable negative score)
  - [x] insulate falling player (no damage, no shield, no movement, etc.)
- [x] Namespace all game state globals (game.x)
- [x] Prevent fragged player from colliding
- [x] Respawn fragged player
- [x] Add frag counts to HUD
- [x] segment hp and energy bars
- [x] enable shield mid-movement
- [x] disable move into void (suicide)
- [x] Make players face each other on first spawn
- [x] disable shield while firing
- [x] add shield attack (burst)
  - [x] test dash beats burst
  - [x] test burst vs burst
  - [x] test burst vs shield
- [x] prevent negative scores
- [x] Add game clock
- [x] Add energy
  - [x] Implement energy respawn (timer)
- [x] Add splash start screen
- [x] Add menu screen to choose game type, arena, player color, etc.
- [x] add slowdown to player explode particles
- [x] sfx names
- [x] Add initial timeout to game end state to ignore player input that spills over from game
- [x] fix player move solid collision sfx stutter (sfxd)
- [x] prevent continuous dash attacks (prevent dmg/push when taking damage)
- [x] respawn should reset energy


# TODO

- [ ] add more arenas
- [ ] projectile weapon (cubes)
  - [ ] line beats cube
  - [ ] increase pushback
  - [ ] direct hit does 3x dmg, adjacent splash does 2x dmg
  - [ ] enable controlled burst
  - [ ] fix disappearing cubes
- [ ] increase burst radius
- [ ] increase dash pushback
- [ ] add burst delay
- [ ] enable dash cancel (into shield or movement)
- [ ] handle line mid-movement/dash
- [ ] tile art
  - [ ] combine tiles and auto-"terrain"
  - [ ] add fractal noise to voids
- [ ] Add print delays to match end screen to reveal results with anticipation
- [ ] Add match end screen music
- [ ] add "reset_player" function
  - [ ] reset energy
- [ ] set_score function
  - [ ] play score sounds
  - [ ] play score animations
- [ ] set_player_hp function
  - [ ] play hp sounds
  - [ ] hp transition animations
- [ ] Enable choosing player color
- [ ] Add more map tile types
  - [ ] destructible walls
  - [ ] movable walls
  - [x] voids
  - [ ] "push" pads
  - [ ] portals
  - [ ] floors
  - [ ] doors
  - [ ] stairs
  - [ ] ladders
  - [ ] elevators
  - [ ] bridges
  - [ ] platforms
  - [ ] lava (damages when occupied)
  - [ ] water (slows movement)
  - [ ] ice (explodes and "freezes" players)
  - [ ] fire
  - [ ] orange tiles explode
  - [ ] red tiles dmg on contact
  - [ ] ice tiles freeze
  - [ ] shiny/reflective floors/walls
  - [ ] "alive" tiles with animations responsive to player movement
- [ ] Add more weapons
  - [ ] grenades
  - [ ] reflectors
  - [ ] corners
  - [ ] path finders
  - [ ] tetris
  - [ ] tron lightcycle
- [ ] Add more maps
- [ ] Add "overworld" map arena select
  - [ ] forest (trees, bushes, water tiles, falling leaves)
  - [ ] underground caves (lava tiles, falling rocks and lava flow) 
  - [ ] mountain (wind and ice and avalanche)
  - [ ] floating platforms in the clouds (rain and lightning)


## Polish

- [ ] Add arena backgrounds/foregrounds
- [ ] find missing frame 2
- [ ] Refactor naming (longer, more explicit, more scalable)
- [ ] Add fancy animations for:
  - [x] player spawn
  - [ ] energy pickup
- [ ] Add arena validation
  - [ ] ensure at least two spawn points

## Stretch Goals

- [ ] Add more game types
  - [ ] single player
  - [ ] cooperative multiplayer
  - [ ] ctf

## Maybe

- [ ] add aiming (hold x to aim)
- [ ] enable player movement push
- [ ] Add two types of spawn tiles, initial and regular
- [ ] taking damage (stun)
  - [ ] prevent player from firing
  - [ ] prevent player from dashing
  - [ ] prevent player from moving
  - [ ] prevent player from taking additional damage
- [ ] Prevent fire when taking damage (duel mechanic:first to draw gains advantage)
- [ ] enable adjacent dash
- [ ] dash player collisions should push back 1 tile or more? into void?


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

# TODO

- [ ] Add splash start screen
- [ ] Add menu screen to choose game type, arena, player color, etc.
- [ ] Add more game types
  - [ ] single player
  - [ ] cooperative multiplayer
  - [ ] ctf
- [ ] add aiming (hold x to aim)
- [ ] orange tiles explode
- [ ] red tiles frag on contact
- [ ] ice tiles freeze
- [ ] add "reset_player" function
  - [ ] reset energy
- [ ] set_score function
  - [ ] play score sounds
  - [ ] play score animations
- [ ] set_player_hp function
  - [ ] play hp sounds
  - [ ] hp transition animations
- [ ] Enable choosing player color
- [ ] Add game clock
- [x] Add energy
  - [x] Implement energy respawn (timer)
- [ ] Add more map tile types
  - [ ] destructible walls
  - [ ] movable walls
  - [ ] voids
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
  - [ ] shiny/reflective floors/walls
  - [ ] "alive" tiles with animations responsive to player movement
- [ ] Add more weapons
  - [ ] shield
  - [ ] rockets
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

- [ ] enable dash cancel (into shield or movement)
- [ ] handle line mid-movement/dash
- [ ] tile art
  - [ ] combine tiles and auto-"terrain"
  - [ ] add fractal noise to voids
- [ ] Add arena "backgrounds" ?
  - [ ] bleachers with audience/crowd/spectators/fans
- [ ] add slowdown to player explode particles
- [ ] find missing frame 2
- [ ] Refactor naming (longer, more explicit, more scalable)
- [ ] Add fancy animations for:
  - [x] player spawn
  - [ ] energy pickup
- [ ] Add arena validation
  - [ ] ensure at least two spawn points

## Maybe

- [ ] increase dash pushback
- [ ] enable player movement push
- [ ] Add two types of spawn tiles, initial and regular
- [ ] taking damage
  - [ ] prevent player from firing
  - [ ] prevent player from dashing
  - [ ] prevent player from moving
  - [ ] prevent player from taking additional damage
- [ ] Prevent fire when taking damage (duel mechanic:first to draw gains advantage)
- [ ] enable adjacent dash
- [ ] dash player collisions should push back 1 tile or more? into void?

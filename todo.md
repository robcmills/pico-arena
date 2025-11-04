# Bugs

# TODO

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


- [ ] handle line and shield mid-movement
- [ ] add "reset_player" function
  - [ ] reset energy
- [ ] set_score function
  - [ ] play score sounds
  - [ ] play score animations
- [ ] set_player_hp function
  - [ ] play hp sounds
  - [ ] hp transition animations
- [ ] Add splash screen
- [ ] Add menu screen to choose game type, arena, player color, etc.
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
  - [ ] lava
  - [ ] water (slows movement)
  - [ ] ice
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
- [ ] Add splash start screen
- [ ] Add more game types
  - [ ] single player
  - [ ] cooperative multiplayer
  - [ ] ctf
- [ ] Add arena "backgrounds" ?
  - [ ] bleachers with audience/crowd/spectators/fans
- [ ] Add arena validation
  - [ ] ensure at least two spawn points
- [x] Make players face each other on first spawn

## Polish

- [ ] find missing frame 2
- [ ] Refactor naming (longer, more explicit, more scalable)
- [ ] Add fancy animations for:
  - [x] player spawn
  - [ ] energy pickup


## Maybe

- [ ] Add two types of spawn tiles, initial and regular
- [ ] taking damage
  - [ ] prevent player from firing
  - [ ] prevent player from dashing
  - [ ] prevent player from moving
  - [ ] prevent player from taking additional damage
- [ ] Prevent fire when taking damage (duel mechanic:first to draw gains advantage)
- [ ] enable adjacent dash
- [ ] dash player collisions should push back 1 tile or more? into void?

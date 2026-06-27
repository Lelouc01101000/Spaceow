
# Spaceow

Spaceow is a space shooter, where you should shoot meteors and destroy them, if you collide with them you will lose.
game uses art referencing Shimeji Simulation, to which obsticles used have thematic connection, backgrounds used are directly art from it.
obsticle pngs where free assets modified by me.
##  Inputs
**W A S D** or **Arrow keys** for movement

**Space** or **Left Click** for shooting a laser

**Shift** for sprint

**P** for pause/unpause

**M** for Main Menu


## Requirments

**LÖVE2D** and **Lua**

game can be run by moving the game folder onto the LÖVE2D application icon or by running following inside the terminal:

```bash
cd path/to/your/game/folder
love .
```
## UI 
Game starts in **Main Menu**, where you can select difficulties, for each difficulty there is unique Highest Score and Best Time displayed.

On bottom left there is a button for **Settings**, settings lets you modify volume for game music, explosion sound and laser sound, 
pressing save button will save modifcation while pressing back will discard it, both of those buttons brings you back to main menu.

Clicking **Play** will start the game.


While ingame you can click **Menu** button on bottom left, which will bring you to Main Menu with same functionalities but with additional **Resume** button, which lets you resume the game

If you click **Play** button it will restart the game, Resume button is only clickable if youre selecting same difficulty as ongoing game, you cant change difficulties mid game

**Game Over** UI appears when player dies, it displays score, time survived and difficulty,
there are two button one to Replay on same difficulty and second called Menu which brings you to main menu
### Difficulties
Each difficulty scales spawn rate and speed of every obsticle. additionally longer game goes faster the obsticles will spawn, it has quadratic (exponential) increase till it reaches specific point after which spawn rate wont change (being 0.1 seconds for Hard)

### Score
score is calculated based on time spent playing and obsticles destroyed, each obsticle increases score by diferent amount, they are displayed on bottom middle while ingame




### Difficulties
Each difficulty scales spawn rate and speed of every obsticle. additionally longer game goes faster the obsticles will spawn, it has quadratic (exponential) increase till it reaches specific point after which spawn rate wont change (being 0.1 seconds for Hard)

### Score
score is calculated based on time spent playing and obsticles destroyed, each obsticle increases score by diferent amount, they are displayed on bottom middle while ingame




## Classes
Explenation to each class (CrabMeteor LobsterMeteor and TrackerMeteor use AI): 

- **Player.lua**
handles the player or whats supposed to be a spaceship, it has speed and normalised diagonal movement, player moves with arrow keys or with wasd
it interacts with laser class and can shoot a laser when player presses space key, it should be defined after laser class in main.lua

- **Laser.lua** handles the laser that player shoots, it destroys meteors on impact, it uses pixel precise collision. it moves only vertically.

- **AnimatedExplosion.lua** 
class used to animated when obsticles are destroyed, it doesnt use split multiple-frame sprite, instead a loop were it itterated over iamged.


**Obsticles:**
(speed and spawn rate influenced by difficulty)

- **Meteor.lua** is the most common obsticle, it has egg png image, its speed and angle at which it moves is random.

- **PhoenixMeteor.lua** has a lemon shape, is similar to basic meteor but instead it takes 2 hits to be destroyed, 
hitting it once will change its png to more destroyed lemon and hitting it second time will destroy it.

- **TrackerMeteor.lua** has intelligence, also lemon shaped but without a leaf, it is fastest obsticle and it is guranteed to cross the path to where player was standing when it spawned, 
it moves on angle like normal meteor so it uses trygonometry to calculate the angle at which it should go based on what x and y coordinatae it spawned compared to player.

- **CrabMeteor.lua** spawns directly above the player, it moves vertically, its horizontal movement follows wherever player currently goes/is, however it is slower than the player.

- **LobsterMeteor.lua**
spawns directly above the player, it has additional rectangular hitboxes which checks for closest laser/player, 
if its laser, tries to move away from it by changing x coordinate, if its player it moves towards player by changing x coordinate.

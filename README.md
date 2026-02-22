# MineSweeper
 A basic minesweeper game made in Godot using GDScript 4.6.
 This project recreates the classic Minesweeper puzzle where players reveal tiles and avoid hidden mines.
 
## Features
 - Grid-based gameplay
 - Random mine generation
 - Tile revealing and flagging
 - Win/lose detection
 - (Very) simple and clean interface
 - Settings menu with different difficulties, plus a custom difficulty
 - Language selection (English and Spanish). Includes localization files

## How to Run
 - Unzip on a new folder
 - Run MineSweeper.exe

## How to Play
 - Click on "Settings" to choose your board size. You can choose among three basic difficulties, or make a custom board
 - Click "Play" to generate your board
 - The game will start the moment you click on a tile, starting a timer (top right number), and a flag counter showing how many flags you can place (top left number), which will be the same number as mines on the board
 - Left click on a revealed tile with the same amount of flags around it as its number to reveal all non-flagged, non-revealed tiles around it. Careful, if the flags are not placed correctly, this may cause you to reveal a mine and lose the game
 - Right click on an unrevealed tile to use a flag on it, if you have any left. This is useful to mark tiles that you think may have a mine on them. This tiles cannot be left clicked. Right click again to remove the flag
 - Left click on an unrevealed tile to reveal it. The first tile you reveal will always be empty space, if posible
 - Non-mine tiles may contain a number that indicates how many mines are around it
 - An empty tile contains no mines around it and, when revealed, will automatically reveal all non-mine tiles around it
 - Reveal all non-mine tiles to win
 - If you click on a mine, you lose
 
## Built with
 - Godot
 - GDScript 4.6

## Purpose
 This project was created to practice programming concepts.
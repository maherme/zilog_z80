# Assembly Language Files

Here you can find some software coded in assembly language. For testing this code you can use WinAPE, open the assembler view (F3) and then open the asm file you want to test, then you can assemble the file or assemble and run (F9).

- [01_wagon.asm](01_wagon.asm) print a wagon and a rail, you can set the memory address of both items in order to print where you want in the screen.

- [02_wagon.asm](02_wagon.asm) print the same that [01_wagon.asm](01_wagon.asm) but you can move the wagon to the end of the rail pressing a configurable key. By default space key start, and r key reset the wagon to the initial position; you can change the speed of the wagon using 1, 2, or 3 key.

  Here a preview:
  
  ![02_wagon.gif](doc/02_wagon.gif)

- [03_wagon.asm](03_wagon.asm) is the same as [02_wagon.asm](02_wagon.asm) but a row of barrels are added, you can stop the wagon pressing a configurable key, by default the stop key is the space. If you don't press the stop key, the wagon will stop just before the first barrel.

  Here a preview:
  
  ![03_wagon.gif](doc/03_wagon.gif)

- [04_wagon.asm](04_wagon.asm) is the same as [03_wagon.asm](03_wagon.asm) but if you don't stop the wagon just before the first barrel, an explosion will happen. If you avoid the crash, the wagon will move faster the next round, if not, the wagon will move slower.

  Here a preview:
  
  ![04_wagon.gif](doc/04_wagon.gif)

# FPGA-Sudoku
a simplified implementation of classic 9x9 sudoku games.

**some tips that may help you in completing a simular project:**

- Combinatory logic first, timing logic last.
- Any register may be rewritten by one and **ONLY ONE** procedural block.
- VGA requires a very high reaction speed, so using timing logic in the printer implementation is strongly **DEPRECATED**. Consider using BRAM or combinatory logic instead.
- Pay precaution for any use of delay. 
- Finishing the project in a short period is not practical. You will need plenty of time to run tests on your modules.
- ModelSim simulation is far more useful than Vivado ones. It supports submodule port monitoring and some other useful features.
- Bluetooth serial is nearly impossible to be run on simulation. A more practical approach is to write another program to test your module.
- Remember to have your project backed up at least once in development. (nvm if you're using Git)
- GitHub FPGA projects you see (including mine) are not always proper and may contain mistakes ranging from occasional to fatal. Maintain fundamental criticism when you're checking these projects.

**Lewis Lee, Tongji University, Shanghai**

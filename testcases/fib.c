
int main ();

/*
 * _start()
 *
 * startup code to initialize things and call main(). Should be located at
 * address 0 in instruction mem. Put it at the beginning of the C file to make
 * the compiler place it at addr 0.
 *
 */
__attribute__((naked)) void _start() {
  asm("li sp,0x20000");  // set up the stack pointer
  main();             // call main()
  while(1);           // Spin loop when main() returns
}

__attribute__((naked)) int recursive(){
  asm("addi a0, a0, 0x64");//adds 100 recursively
  asm("lui a0,0xFFFF0");
  return 0;
}

int main(){
  asm("addi a0, x0, 0x43");
  recursive();
  return 0;
}
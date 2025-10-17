
int main ();

__attribute__((naked)) void _start() {
  asm("li sp,4096");  // set up the stack pointer
  main();             // call main()
  while(1);           // Spin loop when main() returns
}

int main () {
    while (1) asm("addi a1, a1, 1");
    return 0;
}

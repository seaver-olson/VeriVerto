
int main ();

__attribute__((naked)) void _start() {
  asm("li sp,4096");  // set up the stack pointer
  main();             // call main()
  while(1);           // Spin loop when main() returns
}

int main () {
    int x = 0;
    while (1) x++;
    return 0;
}

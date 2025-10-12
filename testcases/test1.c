
int main ();

__attribute__((naked)) void _start() {
  asm("li sp,4096");  // set up the stack pointer
  main();             // call main()
  while(1);           // Spin loop when main() returns
}

int main () {
    int x=67;
    for (int i = 0; i < 420;i++){
      if (x > 670) x=0;
      else x+=67;
    }
    return 0;
}

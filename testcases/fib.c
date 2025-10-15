
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
  asm("li sp,4096");  // set up the stack pointer
  main();             // call main()
  while(1);           // Spin loop when main() returns
}

#define OUT_ADDR ((volatile int*)0xFFFF0000)

// Recursive Fibonacci (simple for testing)
int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    int n = 1000;              
    int result = fib(n);
    *OUT_ADDR = result;       // Write result to observable memory
    while (1);                // Stop CPU after done
    return 0;
}
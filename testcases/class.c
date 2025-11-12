int main();

/*
 * _start()
 */
__attribute__((naked)) void _start() {
    asm("li sp,0x20000");
    main();
    while(1);
}

__attribute__((naked)) int recursiveFunc(int x, int n){
    if (x > n) return x;
    return recursiveFunc(x++,n);
}

__attribute__((naked)) int main() {
    register int n = 10;
    register int x = 0;
    recursiveFunc(x,n);
    return 0;
}
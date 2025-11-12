int main();

/*
 * _start()
 */
__attribute__((naked)) void _start() {
    asm("li sp,0x20000");
    main();
    while(1);
}

__attribute__((naked)) int factorial(int x, int n){
    if(n <= 1){
        return 1;
    } else {
        int result = 0;
        for(int i = 0; i < x; i++){
            result += factorial(x, n - 1);
        }
        return result;
    }
}

__attribute__((naked)) int main() {
    register int n = 10;
    register int x = 0;
    factorial(x,n);
    return 0;
}
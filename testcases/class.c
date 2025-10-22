int main();

/*
 * _start()
 */
__attribute__((naked)) void _start() {
    asm("li sp,0x20000");
    main();
    while(1);
}

/*
 * Pure inline assembly demo - shows every ALU operation
 */
__attribute__((naked)) int main() {
    asm volatile(
        // Initialize registers with starting values
        "addi a0, x0, 1\n\t"
        "addi a1, x0, 2\n\t"
        "addi a2, x0, 3\n\t"
        "addi a3, x0, 5\n\t"
        "addi a4, x0, 8\n\t"
        "addi a5, x0, 13\n\t"
        "addi a6, x0, 21\n\t"
        "addi a7, x0, 34\n\t"
        
        // Sequence 1: Additions with heavy forwarding
        "add  t0, a0, a1\n\t"      // t0 = 3 (forwarding starts here)
        "add  t1, t0, a2\n\t"      // t1 = 6 (forward from t0)
        "add  t2, t1, a3\n\t"      // t2 = 11 (forward from t1)
        "add  t3, t2, a4\n\t"      // t3 = 19 (forward from t2)
        "add  t4, t3, a5\n\t"      // t4 = 32 (forward from t3)
        "add  t5, t4, a6\n\t"      // t5 = 53 (forward from t4)
        "add  t6, t5, a7\n\t"      // t6 = 87 (forward from t5)
        
        // Sequence 2: Mixed ALU operations
        "xor  s0, t6, a0\n\t"      // XOR
        "slli s1, s0, 2\n\t"       // SHIFT LEFT
        "or   s2, s1, t5\n\t"      // OR
        "and  s3, s2, t4\n\t"      // AND
        "srli s4, s3, 1\n\t"       // SHIFT RIGHT
        "sub  s5, s4, a1\n\t"      // SUBTRACT
        
        // Sequence 3: Accumulation pattern
        "add  s6, s5, t6\n\t"
        "add  s6, s6, t5\n\t"
        "add  s6, s6, t4\n\t"
        "add  s6, s6, t3\n\t"
        "add  s6, s6, t2\n\t"
        "add  s6, s6, t1\n\t"
        "add  s6, s6, t0\n\t"
        
        // Sequence 4: Complex dependency chain
        "xor  s7, s6, a7\n\t"
        "add  s8, s7, s6\n\t"
        "slli s9, s8, 1\n\t"
        "or   s10, s9, s7\n\t"
        "and  s11, s10, s8\n\t"
        
        // Sequence 5: More intensive computation
        "add  t0, s11, s10\n\t"
        "sub  t1, t0, s9\n\t"
        "xor  t2, t1, s8\n\t"
        "or   t3, t2, s7\n\t"
        "and  t4, t3, s6\n\t"
        "slli t5, t4, 3\n\t"
        "srli t6, t5, 2\n\t"
        
        // Final accumulation to single result
        "add  a0, t6, t5\n\t"
        "add  a0, a0, t4\n\t"
        "add  a0, a0, t3\n\t"
        "add  a0, a0, t2\n\t"
        "add  a0, a0, t1\n\t"
        "add  a0, a0, t0\n\t"
        "add  a0, a0, s11\n\t"
        "add  a0, a0, s10\n\t"
        "add  a0, a0, s9\n\t"
        "add  a0, a0, s8\n\t"
        "add  a0, a0, s7\n\t"
        "add  a0, a0, s6\n\t"
        
        "lui  t0, 0xFFFF0\n\t"
        "sw   a0, 0(t0)\n\t"

        "addi a1, a0, 100\n\t"
        "add  a2, a1, a0\n\t"
        "xor  a3, a2, a1\n\t"
        "or   a4, a3, a2\n\t"
        "and  a5, a4, a3\n\t"
        "slli a6, a5, 4\n\t"
        "add  a7, a6, a5\n\t"
        
        // Output second result
        "lui  t0, 0xFFFF0\n\t"
        "sw   a7, 0(t0)\n\t"
        
        // Return (will jump to while(1) loop in _start)
        "ret\n\t"
    );
}
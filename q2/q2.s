.section .data
array: .space 4000
fmt: .asciz "%d "
fmt_last: .asciz "%d\n"
stack: .space 4000
result: .space 4000


.section .text
.globl main
.extern atoi

main:
    #a0= argc (number of arguments)
    #a1 = argv (the argument as a whole) it is a pointer to strings 

    addi sp,sp,-8
    sd ra, 0(sp) # save return address
    
    la s0, array     # s0 = array pointer
    la s1, stack     # s1 = stack pointer
    la s2, result    # s2 = result pointer
    add s3, a0, -1    # s3 = n (number of integers)

    add t0, a0, x0    #t0 = argc
    mv t1, a1        #argv
    li t2, 1         #i = 1 (we start from numbers after ./a.out)
    add t3, s0, x0     # array pointer
    
loop:
    bge t2, t0, done

    slli t4, t2, 3   # i*8
    add t5, t1, t4   #base address+i*8
    ld a0, 0(t5)     # a0 = argv[i] t5 is pointing towards ith string so it has address 
                    # we loaded 0(t5) so the string in the address into a0 and called atoi


    addi sp, sp, -24      #save t0,t1,t2,t3 across atoi
    sd   t0, 0(sp)        #argc
    sd   t1, 8(sp)        #argv
    sd   t2, 16(sp)       #i

    call atoi        # convert string into int("8")->8

    ld   t0, 0(sp)        #argc
    ld   t1, 8(sp)        #argv
    ld   t2, 16(sp)       #i
    addi sp, sp, 24       # restore stack pointer
    
    slli t4, t2, 2
    add  t4, s0, t4       # t4 = array + (i-1)*4, but i starts at 1 so index = i-1
    addi t4, t4, -4       # correct for i starting at 1
    sw   a0, 0(t4)
    addi t2, t2, 1
    j loop

done:
    # array now contains all integers




nge:
    #s3 = n
    add t0, x0, x0 #t0 = i =0
    add t1, x0, -1 #t1=-1 -> top of stack
    add t2, s2, x0 #t2 = result pointer
    addi t5, x0,-1

    #initialize result array to -1

    init_result:
        bge t0, s3, init_done
        sw t5, 0(t2) #store -1 in result array
        addi t2, t2, 4 #move forward in result array
        addi t0, t0, 1 #move i forward
        j init_result

    init_done:
    #reset i for next loop
    addi t0, s3, -1 #t2 = n-1 = i (reset i)


for_loop:
    blt t0, x0, exit # if i < 0 then target
while_loop:
    blt t1,x0,while_end

    #stack[top]
    add t2, s1, x0 #t2 = stack pointer
    slli t3,t1, 2 #t3 = top*4 (address of stack[top])
    add t4,t2,t3 #t4 = stack + top*4 (address of stack[top])
    lw t5,0(t4) #t5 = stack[top]

    #array[st[i]]
    add t2, s0, x0 #t2 = array pointer
    slli t3,t5,2 #t8 = st[i]*4 (address of array[st[i]])
    add t4,t3,t2 #t9 = array + st[i]*4 (address of array[st[i]])
    lw t5,0(t4) #t10 = array[st[i]]

    #array[i]

    slli t3,t0,2 #t3 = i*4 (address of array[i])
    add t4,t2,t3 #t4 = array + i*4 (address of array[i])
    lw t6,0(t4) #t6 = array[i]

    #compare array[st[i]] and array[i]
    bgt t5,t6,while_end
    #array[st[i]] <= array[i] then pop stack
    addi t1, t1, -1 #top--
    j while_loop

while_end:
    blt t1,x0, push_curr
    add t2, s1, x0
    slli t3, t1, 2
    add t4, t2, t3
    lw t5, 0(t4)

    add t2, s2, x0
    slli t3, t0, 2
    add t4, t2, t3
    sw t5, 0(t4)

push_curr:
    addi t1,t1,1
    add t2, s1, x0
    slli t3, t1, 2
    add t4, t2, t3
    sw t0, 0(t4)

addi t0, t0, -1
j for_loop

exit:
    li t0, 0          # i = 0

    
print_loop:
    bge t0, s3, end

    slli t1, t0, 2
    add  t2, s2, t1
    lw   a1, 0(t2)

    # check if last element
    addi t4, s3, -1
    beq  t0, t4, use_last_fmt

    la   a0, fmt
    j    do_print
use_last_fmt:
    la   a0, fmt_last
do_print:
    addi sp, sp, -8       # save t0 across printf
    sd   t0, 0(sp)       
    call printf
    ld   t0, 0(sp)        # load t0 back
    addi sp, sp, 8        

    addi t0, t0, 1
    j print_loop

end:
    ld   ra, 0(sp)        # restore ra
    addi sp, sp, 8        # 
    li   a0, 0
    ret

#
#riscv64-linux-gnu-gcc -static q2.s -o a.out
#qemu-riscv64 ./a.out 85 96 70 80 102

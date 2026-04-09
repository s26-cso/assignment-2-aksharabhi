.data
filename: .string "input.txt"
buf1: .space 1
buf2: .space 1
yes: .string "Yes\n"
no: .string "No\n"

.text
.globl main
main:
la a0, filename
li a1, 0 #the flag 0 is for read only
addi sp, sp, -8
sd ra, 0(sp)
call open#open("input.txt",readonly)

mv s0, a0 #a0 the open gives file desriptor

mv a0,s0
li a1, 0 #from start
li a2, 2 #from end 1-> current  
call lseek #lseek(fd,0,seek_end)->returns file size

# lseek syntax : lseek(int fd, off_t offset, int whence);
# whence: SEEK_SET SEEK_CUR SEEK_END
# return value: new offset position from beggining


mv s1,a0 #s1 = file size
addi s1,s1,-1 

li s2, 0 #left =0
mv s3,s1 #right = n-1

loop:
bge s2,s3, is_palindrome

#reading start character lseek(fd,left,0)
mv a0, s0
mv a1, s2 #go to offset of left
li a2, 0 #start form begining
call lseek

#file pointer is now at left char
mv a0, s0
la a1, buf1
li a2, 1
call read

#reading end char
mv a0, s0
mv a1, s3 #go to offset of left
li a2, 0 #start form begining
call lseek

#file pointer is now at right char
mv a0, s0
la a1, buf2
li a2, 1
call read

#Parameters: fd (file descriptor), buf (storage buffer), count (maximum bytes to read).


lb t0, buf1
lb t1, buf2

bne t0, t1, not_palindrome

addi s2, s2, 1
addi s3, s3, -1

j loop

is_palindrome:
la a0, yes
call printf
j end

not_palindrome:
la a0, no
call printf
j end

end:

ld ra, 0(sp)
addi sp, sp, 8
ret


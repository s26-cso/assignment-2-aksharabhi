
# struct Node* make_node(int val) {
#     struct Node* node = malloc(24);
#     node->val = val;
#     node->left = NULL;
#     node->right = NULL;
#     return node;
# }
.text
.globl make_node
.globl insert_node
.globl get
.globl getAtMost
.extern malloc

make_node:
addi sp,sp,-16
sd ra, 0(sp)
sd a0, 8(sp) # save val on stack

li a0, 24 # size of struct Node
call malloc # allocate memory for the node

#a0-> pointer to the allocated memory
ld t0, 8(sp) # load val from stack into t0

sw t0, 0(a0) # store val at offset 0
sd zero, 8(a0) # set left pointer to NULL (0)
sd zero, 16(a0) # set right pointer to NULL (0)


ld ra, 0(sp)
addi sp,sp,16
ret



# struct Node* insert(struct Node* root, int val) {
#     if (root == NULL)
#         return make_node(val);

#     if (val < root->val)
#         root->left = insert(root->left, val);
#     else
#         root->right = insert(root->right, val);

#     return root;
# }

insert_node:
#recursion -> save root and ra
    addi sp, sp, -24
    sd ra, 0(sp)
    sd a0, 8(sp)
    sd a1, 16(sp)

#base case: root==null
beqz a0, make_new_base_case

lw t0, 0(a0) #load root->val into t0
blt a1, t0, insert_left #if val < root->val, go to insert_left
j insert_right #else, go to insert_right

insert_left:
    ld t1, 8(a0) #load root->left into t1
    mv a0, t1 #set a0 to root->left

    ld a1, 16(sp) #load val from stack into a1
    call insert_node #recursive call to insert left

    ld t2, 8(sp) #load original root pointer from stack into t2
    sd a0, 8(t2) #update root->left with the returned node
    mv a0, t2 #set a0 to original root pointer for return
    j insert_done #jump to insert_done

insert_right:
    ld t1, 16(a0) #load root->right into t1
    mv a0, t1 #set a0 to root->right

    ld a1, 16(sp) #load val from stack into a1
    call insert_node #recursive call to insert right

    ld t2, 8(sp) #load original root pointer from stack into t2
    sd a0, 16(t2) #update root->right with the returned node
    mv a0, t2 #set a0 to original root pointer for return
    j insert_done #jump to insert_done


make_new_base_case:
    mv a0,a1 #val
    call make_node #returns new node in a0

insert_done:
    ld ra, 0(sp)
    addi sp, sp, 24
    ret


# struct Node* get(struct Node* root, int val) {
#     if (root == NULL)
#         return NULL;

#     if (root->val == val)
#         return root;

#     if (val < root->val)
#         return get(root->left, val);
#     else
#         return get(root->right, val);
# }


get:
addi sp,sp,-8
sd ra, 0(sp)

beqz a0, return_null #if root == NULL return NULL
lw t0, 0(a0)   #load root->val into t0
beq t0, a1, return_root #if root->val == val return

blt a1, t0, get_left #if val < root->val go to get_left
j get_right # els, go to get_right

get_left:
    ld t1, 8(a0) #load root->left into t1
    mv a0, t1 #set a0 to root->left
    call get #recursive call to get left
    j get_done #jump to get_done

get_right:
    ld t1, 16(a0) #load root->right into t1
    mv a0, t1 #set a0 to root->right
    call get #recursive call to get right
    j get_done #jump to get_done

return_null:
    mv a0, zero #set return value to NULL
    j get_done

return_root:
    j get_done

get_done:
    ld ra, 0(sp)
    addi sp, sp, 8
    ret
    

# int getAtMost(int val, struct Node* root) {
#     if (root == NULL)
#         return -1;

#     if (root->val > val)
#         return getAtMost(val, root->left);

#     else {
#         int right_ans = getAtMost(val, root->right);

#         if (right_ans == -1)
#             return root->val;
#         else
#             return right_ans;
#     }
# }

getAtMost:
    addi sp,sp, -16
    sd ra, 0(sp) #stored return address
    sd s1,8(sp) #stored root->val

    beqz a1, return_null_negative_1 # if root == NULL, return -1

    lw t0, 0(a1) # load root->val into t0
    bgt t0, a0, getAtMost_left # if root->val > val, go to getAtMost_left
    j getAtMost_right # else, go to getAtMost_right

getAtMost_left:
    ld t1, 8(a1)    #load root-> left into t1
    mv a1, t1   #set a1 to root->left
    call getAtMost
    j getAtMost_done

getAtMost_right: 
    mv s1,t0 #save root->val in s1
    ld t1, 16(a1) #load root->right into t1
    mv a1, t1 
    call getAtMost

    li t2,-1
    beq a0, t2,return_root_value
    j getAtMost_done

return_root_value:
    mv a0, s1
    j getAtMost_done

return_null_negative_1:
li a0,-1

getAtMost_done:
ld ra, 0(sp)
ld s1, 8(sp)
addi sp,sp,16
ret

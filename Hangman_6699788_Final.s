.global main
main:
program_start: @start of the program and not the game
ldr r0, =program_welcome
bl puts
mov r0, #0
bl fflush

ldr r0, =press_to_start
bl puts
mov r0, #0
bl fflush

@Asking user to press S or s to start the game
Press_To_Start:
ldr r0, =character_format
ldr r1, =user_name
bl scanf
ldr r1, =user_name
ldr r1, [r1]
cmp r1, #83
beq Start
cmp r1, #115
beq Start
bne Press_To_Start

@Start of game and not program
Start:
ldr r0, =game_welcome
bl puts
mov r0, #0
bl fflush

@Hangman Frames
ldr r0, =frame0
bl puts
mov r0, #0
bl fflush

@Generating random number
mov r0, #0
bl time
bl srand
bl rand
and r0, r0, #0x0F
mov r2, #10 @change to 10 to make it modulo 10
udiv r3, r0, r2
mul r4, r3, r2
sub r5, r0, r4

@Picking a word using the random number
cmp r5, #0
ldreq r1, =word0
ldreq r2, =word0_underscores
moveq r3, #word0_length_bytes
cmp r5, #1
ldreq r1, =word1
ldreq r2, =word1_underscores
moveq r3, #word1_length_bytes
cmp r5, #2
ldreq r1, =word2
ldreq r2, =word2_underscores
moveq r3, #word2_length_bytes
cmp r5, #3
ldreq r1, =word3
ldreq r2, =word3_underscores
moveq r3, #word3_length_bytes
cmp r5, #4
ldreq r1, =word4
ldreq r2, =word4_underscores
moveq r3, #word4_length_bytes
cmp r5, #5
ldreq r1, =word5
ldreq r2, =word5_underscores
moveq r3, #word5_length_bytes
cmp r5, #6
ldreq r1, =word6
ldreq r2, =word6_underscores
moveq r3, #word6_length_bytes
cmp r5, #7
ldreq r1, =word7
ldreq r2, =word7_underscores
moveq r3, #word7_length_bytes
cmp r5, #8
ldreq r1, =word8
ldreq r2, =word8_underscores
moveq r3, #word8_length_bytes
cmp r5, #9
ldreq r1, =word9
ldreq r2, =word9_underscores
moveq r3, #word9_length_bytes

@Storing adress of word to r8 and pushing it to stack
ldr r4, =chosen_word_address
ldr r5, =chosen_word_length_bytes
ldr r6, =chosen_word_underscores_address
str r1, [r4]
str r3, [r5]
str r2, [r6]
push {r2}

@clearing underscoes of any letters
clearing:
mov r0, #95
ldrb r1, [r2], #1
cmp r1, #0
bleq print_underscores
sub r3, r2, #1
strb r0, [r3]
blne clearing

print_underscores:
pop {r0}
bl puts
mov r0, #0
bl fflush

@Counts number of letters in word
mov r2, #0 @letter counter (temporary variable)
ldr r8, =chosen_word_address
ldr r8, [r8]
letter_counter:
ldrb r0, [r8], #1
cmp r0, #0 
addne r2, r2, #1
bne letter_counter
ldr r3, =letters_in_word
str r2, [r3]

pre_load:
mov r9, #0
ldr r7, =frame_counter
str r9, [r7]

ldr r0, =letters_guessed

clearing_letters_guessed:
mov r2, #32
ldrb r1, [r0], #1
sub r7, r0, #1
cmp r1, #0
bleq clearing_incorrect
strb r2, [r7]
bl clearing_letters_guessed

clearing_incorrect:
ldr r0, =incorrect_letters

clearing_incorrect_letters_guessed:
mov r2, #32
ldrb r1, [r0], #1
sub r7, r0, #1
cmp r1, #0
bleq load
strb r2, [r7]

bl clearing_incorrect_letters_guessed
@Hangman Instructions(Asking user to make a guess)
@Prints out the instructions
load:
mov r0, #1
ldr r1, =letters_guessed_indicator
ldr r2, =letters_guessed_indicator_len
mov r7, #4
svc #0

ldr r0, =incorrect_letters
bl puts
mov r0, #0
bl fflush

mov r0, #0
ldr r1, =instructions
mov r2, #instructions_len
mov r7, #4
svc #0

ldr r0, =string_format
ldr r1, =input_pre_trim
bl scanf

ldr r1, =input_pre_trim
mov r3, #0 @input counter

loop:
ldrb r2, [r1], #1
cmp r2, #0
bleq comparing_user_input
cmp r2, #9
bleq trimmer
cmp r2, #32
bleq trimmer
add r3, r3, #1
cmp r3, #1
bleq storer
bl trimmer

trimmer:
cmp r3, #1
blne error_print
mov r4, #0
sub r6, r1, #1
strb r4, [r6]
bl loop

storer:
ldr r5, =user_input
strb r2, [r5]
bl loop

error_print: 
ldr r0, =error_too_long
bl puts
mov r0, #0
bl fflush
bl print3


comparing_user_input:
//Comparing user_input with 0,1,2
ldr r1, =user_input
ldr r1, [r1]
cmp r1, #50
bleq program_start
cmp r1, #48
bleq end_program

cmp r1, #49
moveq r7, #0 @counter for show_letter
ldreq r0, =chosen_word_underscores_address
ldreq r0, [r0]
bleq show_letter
bl valid_input

show_letter:
ldr r5, =frame_counter
ldr r6, [r5]
cmp r6, #4
blge error_cannot_show_letter
ldrb r1, [r0], #1
cmp r1, #95
addne r7, r7, #1
blne show_letter
ldr r2, =chosen_word_address
ldr r2, [r2]
add r2, r2, r7
ldrb r4, [r2]
ldr r3, =user_input
str r4, [r3]
ldr r5, =frame_counter
ldr r6, [r5]
add r6, r6, #2
str r6, [r5]
bl letter_guessed_or_not

error_cannot_show_letter:
ldr r0, =error_cannot_show_letter_msg
bl puts
mov r0, #0
bl fflush
bl print3

//Comparing user_input to be valid
valid_input:
cmp r1, #123
blge error_invalid_input
cmp r1, #65
bllt error_invalid_input
cmp r1, #91
blge maybe_error
bl converting

maybe_error:
cmp r1, #97
blge converting
bl error_invalid_input

error_invalid_input:
ldr r0, =error
bl puts
mov r0, #0
bl fflush
bl print3

//Converting lowercase to upercase
converting:
cmp r1, #96
subgt r1, r1, #32
ldr r2, =user_input
str r1, [r2]

ldr r1, =user_input
ldrb r1, [r1]

//Checking if letter has been guessed or not
letter_guessed_or_not:
ldr r0, =letters_guessed
ldr r1, =user_input
ldrb r1, [r1]
mov r6, #0

comparing_letter_with_guessed:
ldrb r2, [r0], #1
sub r3, r0, #1
cmp r6, #1
bleq matching_guess_with_word
cmp r1, r2
bleq error_same_letter_guessed
cmp r2, #32
bleq streq_32
bl comparing_letter_with_guessed

streq_32:
push {lr}
strb r1, [r3]
mov r7, #44
add r3, r3, #1
strb r7, [r3]
add r6, r6, #1
pop {lr}
bx lr

error_same_letter_guessed:
ldr r0, =error_same_letter_guessed_message
bl puts
mov r0, #0
bl fflush
bl print3

matching_guess_with_word:
ldr r1, =user_input
ldr r1, [r1]
mov r2, #0 @r2 is temporary counter variable
ldr r3, =letters_in_word
ldr r3, [r3] @Letters in word
ldr r8, =chosen_word_address
ldr r8, [r8]

//Counts number of times we loop to correct_guess
mov r6, #0

iterate_through_word:
cmp r2, r3 @Comparing counter with letters in word
beq print
add r2, #1
ldrb r4, [r8], #1
cmp r4, r1
bleq correct_guess
bl iterate_through_word

correct_guess:
add r6, r6, #1 //If r6 =0 then the user input didnt match to any letters (no correct guess)
ldr r0, =chosen_word_underscores_address
ldr r0, [r0]
mov r4, r2
sub r4, r4, #1
add r0, r0, r4
strb r1, [r0]
// Count how many correct letters are there
add r9, r9, #1
ldr r0, =letters_in_word
ldr r0, [r0]
cmp r9, r0
bleq congrats
bl iterate_through_word

// Making r0 go back to original address value then printing it
print:
ldr r0, =chosen_word_underscores_address
ldr r0, [r0]
bl puts
mov r0, #0
bl fflush
ldr r0, =chosen_word_underscores_address
ldr r0, [r0]

ldr r7, =frame_counter
ldr r0, [r7]
add r0, r0, #1
cmp r6, #0
streq r0, [r7]
blne print2

ldr r0, =incorrect_letters
ldreq r1, =user_input
ldrb r1, [r1]
mov r6, #0

incorrect_guesses:
ldrb r2, [r0], #1
sub r3, r0, #1
cmp r6, #1
bleq print2
cmp r2, #32
blne incorrect_guesses
strb r1, [r3]
mov r7, #44
add r3, r3, #1
strb r7, [r3]
add r6, r6, #1
bl incorrect_guesses

print2:
ldr r0, =frame_counter
ldr r0, [r0]
cmp r0, #0
ldreq r0, =frame0
cmp r0, #1
ldreq r0, =frame1
cmp r0, #2
ldreq r0, =frame2
cmp r0, #3
ldreq r0, =frame3
cmp r0, #4
ldreq r0, =frame4
cmp r0, #5
ldreq r0, =frame5
cmp r0, #6
ldreq r0, =frame6
bleq last_frame

bl puts
mov r0, #0
bl fflush


continue_round:
bl load

last_frame:
bl puts
mov r0, #0
bl fflush
bl end

congrats:
ldr r0, =frame_counter
ldr r0, [r0]
cmp r0, #0
moveq r2, #6
cmp r0, #1
moveq r2, #5
cmp r0, #2
moveq r2, #4
cmp r0, #3
moveq r2, #3
cmp r0, #4
moveq r2, #2
cmp r0, #5
moveq r2, #1

ldr r1, =guesses_left
str r2, [r1]

ldr r0, =congrats_message
ldr r1, =guesses_left
ldr r1, [r1]
bl printf
mov r0, #0
bl fflush

end:
ldr r0, =end_screen
ldr r1, = chosen_word_address
ldr r1, [r1]
bl printf
mov r0, #0
bl fflush

play_again:
ldr r0, =play_again_message
bl puts
mov r0, #0
bl fflush

mov r0, #0
ldr r1, =user_input
mov r2, #1
mov r7, #3
svc #0 

ldr r1, =user_input
ldr r1, [r1]
cmp r1, #48
bleq end_program
cmp r1, #89
bleq program_start
cmp r1, #121
bleq program_start
bl play_again

print3:
ldr r0, =chosen_word_underscores_address
ldr r0, [r0]
bl puts
mov r0, #0
bl fflush

ldr r0, =frame_counter
ldr r0, [r0]
cmp r0, #0
ldreq r0, =frame0
cmp r0, #1
ldreq r0, =frame1
cmp r0, #2
ldreq r0, =frame2
cmp r0, #3
ldreq r0, =frame3
cmp r0, #4
ldreq r0, =frame4
cmp r0, #5
ldreq r0, =frame5
cmp r0, #6
ldreq r0, =frame6
bleq last_frame

bl puts
mov r0, #0
bl fflush

bl load

end_program:
mov r7, #1
svc #0

.data
.align 2
program_welcome: .asciz "Hangman by Adam Meor Azlan (6699788)\n"
.align 2
press_to_start: .asciz "Enter S or s to start the game:"
.align 2
game_welcome: .asciz "Hi and welcome to Hangman!"
.align 2
character_format: .asciz "%c"
.align 2
user_name: .skip 1
.align 2
instructions: .asciz "\nEnter any character (A-Z) to make a guess, 1 to show letter, 2 to start new, 0 to exit:"
.align 2
instructions_len = .-instructions
.align 2
input_pre_trim: .space 100
.align 2
string_format: .asciz "%s"
.align 2
user_input: .skip 1
.align 2
guesses_left:  .word 0
.align 2
letters_guessed_indicator: .asciz "Incorrect letters guessed: "
.align 2
letters_guessed_indicator_len = .-letters_guessed_indicator
.align 2
incorrect_letters: .asciz "                                                                                             "
.align 2
letters_guessed: .asciz "                                                                                                "
.align 2
error_too_long: .asciz "\nInput too long.\n"
.align 2
error: .asciz "\nInvalid input, try again.\n"
.align 2
error_cannot_show_letter_msg: .asciz "\nCannot ask for letter reveal!\n"
.align 2
error_same_letter_guessed_message: .asciz "The letter has already been entered\n"
.align 2
congrats_message: .asciz "Well done! You guessed the word with %d guesses left.\n"
.align 2
end_screen: .asciz "Game over, word was %s\nThanks for playing hangman by Adam Meor Azlan (6699788)\n"
.align 2
play_again_message: .asciz "\nEnter 0 to exit or y to play again:"
.align 2
frame0: .asciz "______\n|/  |       Guesses Left: 6\n|\n|\n|\n|\n|_______"
.align 2
frame1: .asciz "______\n|/  |       Guesses Left: 5\n|   O\n|\n|\n|\n|_______"
.align 2
frame2: .asciz "______\n|/  |       Guesses Left: 4\n|   O\n|   |\n|   |\n|\n|_______"
.align 2
frame3: .asciz "______\n|/  |       Guesses Left: 3\n|   O\n|  \\|\n|   |\n|\n|_______"
.align 2
frame4: .asciz "______\n|/  |       Guesses Left: 2\n|   O\n|  \\|/\n|   |\n|\n|_______"
.align 2
frame5: .asciz "______\n|/  |       Guesses Left: 1\n|   O\n|  \\|/\n|   |\n|  /\n|_______"
.align 2
frame6: .asciz "______\n|/  |       Guesses Left: 0\n|   x\n|  \\|/\n|   |\n|  / \\\n|_______"
.align 2
frame_counter: .word 0
.align 2
letters_in_word:  .word 0
.align 2
underscores: .space 100
.align 2
word0: .asciz "TESTS"
.align 2
word0_length_bytes = .-word0-1
.align 2
word0_underscores: .asciz "_____"
.align 2
word1: .asciz "CHALLENGE"
.align 2
word1_length_bytes = .-word1-1
.align 2
word1_underscores: .asciz "________"
.align 2
word2: .asciz "UNIVERSITY"
.align 2
word2_length_bytes = .-word2-1
.align 2
word2_underscores: .asciz "__________"
.align 2
word3: .asciz "STUDENTS"
.align 2
word3_length_bytes = .-word3-1
.align 2
word3_underscores: .asciz "________"
.align 2
word4: .asciz "BALANCE"
.align 2
word4_length_bytes = .-word4-1
.align 2
word4_underscores: .asciz "_______"
.align 2
word5: .asciz "FEEDBACK"
.align 2
word5_length_bytes = .-word5-1
.align 2
word5_underscores: .asciz "________"
.align 2
word6: .asciz "BINARY"
.align 2
word6_length_bytes = .-word6-1
.align 2
word6_underscores: .asciz "______"
.align 2
word7: .asciz "INTELLIGENCE"
.align 2
word7_length_bytes = .-word7-1
.align 2
word7_underscores: .asciz "____________"
.align 2
word8: .asciz "CARTOGRAPHERS"
.align 2
word8_length_bytes = .-word8-1
.align 2
word8_underscores: .asciz "_____________"
.align 2
word9: .asciz "CHARACTERISTICALLY"
.align 2
word9_length_bytes = .-word9-1
.align 2
word9_underscores: .asciz "__________________"
.align 2
chosen_word_address: .word 0
chosen_word_length_bytes: .word 0
chosen_word_underscores_address: .word 0
.align 2
useless: .byte 0
.end
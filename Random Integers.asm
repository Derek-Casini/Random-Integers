TITLE Generating, Sorting, and Counting Random Integers     (proj5_casinid.asm)

; Author: Derek Casini
; Last Modified: 3/1/2024
; OSU email address: casinid@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5               Due Date:	3/3/2024
; Description: A program that generates a list of random numbers, sorts it, finds the median, then counts the amount of each number

INCLUDE Irvine32.inc

LO = 15
HI = 50
ARRAYSIZE = 200

.data
	randArray		DWORD	ARRAYSIZE DUP(?)
	counts			DWORD	HI - LO DUP(0)
	intro1			BYTE	"Generating, Sorting, and Counting Random integers!                      Programmed by Derek", 0
	intro2L1		BYTE	"This program generates 200 random integers between 15 and 50, inclusive.", 0
	intro2L2		BYTE	"It then displays the original list, sorts the list, displays the median value of the list,", 0
	intro2L3		BYTE	"displays the list sorted in ascending order, and finally displays the number of instances", 0
	intro2L4		BYTE	"of each generated value, starting with the number of lowest.", 0
	unsorted		BYTE	"Your unsorted random numbers:", 0
	median			BYTE	"The median value of the array: ", 0
	sorted			BYTE	"Your sorted random numbers:", 0
	instances		BYTE	"Your list of instances of each generated number, starting with the smallest value:", 0
	bye				BYTE	"Goodbye, and thanks for using my program!", 0
; (insert variable definitions here)

.code
main PROC
	CALL	Randomize					; Sets seed for random
	; Print out introduction
	PUSH	OFFSET intro2L4
	PUSH	OFFSET intro2L3
	PUSH	OFFSET intro2L2
	PUSH	OFFSET intro2L1
	PUSH	OFFSET intro1
	CALL	introduction
	; Create random array
	PUSH	OFFSET randArray
	CALL	fillArray
	; Display random array
	PUSH	ARRAYSIZE
	PUSH	OFFSET unsorted
	PUSH	OFFSET randArray
	CALL	displayList
	; Create sorted array
	PUSH	OFFSET randArray
	CALL	sortList
	; Display sorted array
	PUSH	ARRAYSIZE
	PUSH	OFFSET sorted
	PUSH	OFFSET randArray
	CALL	displayList
	; Find and display median
	PUSH	OFFSET randArray
	PUSH	OFFSET median
	CALL	displayMedian
	; Counts amount of each number in randArray
	PUSH	OFFSET counts
	PUSH	OFFSET randArray
	CALL	countList
	; Display array counts array
	PUSH	HI - LO
	PUSH	OFFSET instances
	PUSH	OFFSET counts
	CALL	displayList
	; Display goodbye message
	PUSH	OFFSET bye
	CALL	goodbye
	Invoke ExitProcess, 0				; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Prints the introduciton to the program
;
; Preconditions: pushed 5 strings to the stack
;
; Postconditions: none.
;
; Receives:
; [ebp+24] = intro2L4
; [ebp+20] = intro2L3
; [ebp+16] = intro2L2
; [ebp+12] = intro2L1
; [ebp+8] = intro1
;
; returns: none
; ---------------------------------------------------------------------------------

introduction PROC
	; Set stack frame
	PUSH	EBP
	MOV		EBP, ESP
	; prints intro1
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	; prints intro2
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP + 16]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP + 20]
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, [EBP + 24]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	; Set stack frame back to what it was before
	POP		EBP
	RET		20							; De-reference 4 + 4 + 4 + 4 + 4 = 20 bytes
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Fills randArray with random numbers between LO and HI
;
; Preconditions: pushed randArray to stack
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = address of randArray
;
; returns: none
; ---------------------------------------------------------------------------------

fillArray PROC
	; Set stack frame
	PUSH	EBP
	MOV		EBP, ESP
	
	MOV		ECX, ARRAYSIZE
	MOV		ESI, [EBP + 8]				; Moving address of randArray into ESI so we can parse through it
_parseArr:
	; Get random number
	MOV		EAX, HI
	SUB		EAX, LO + 1
	CALL	RandomRange
	ADD		EAX, LO
	; Set random number at current spot in randArray
	MOV		[ESI], EAX
	ADD		ESI, 4						; Moves to next spot in randArray
	LOOP	_parseArr

	POP		EBP
	RET		4
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts an inputted list in ascending order using a bubble sorting algorithm
;
; Preconditions: the array contains only positive values and an array is pushed 
; to the stack
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = address of randArray
;
; returns: none
; ---------------------------------------------------------------------------------

sortList PROC
	PUSH	EBP
	MOV		EBP, ESP
_sortAlg:
	MOV		ECX, ARRAYSIZE - 1			; Indexes of the array go from 0 - (ARRAYSIZE - 1) as the ARRAYSIZE'th index would be out of range
	MOV		ESI, [EBP + 8]
	XOR		EAX, EAX
	XOR		EBX, EBX
	MOV		EDI, 4
_arrLoop:
	MOV		EDX, [ESI + EDI]
	CMP		[ESI + EBX], EDX			; Checks if the next index is lower than the current one and swaps them if they are
	JG		_swap
	JMP		_continue
_swap:
	PUSH	ESI
	PUSH	EBX
	PUSH	EDI
	CALL	exchangeElements
	MOV		EAX, 1						; Indicates that a swap happened
_continue:
	ADD		EBX, 4
	ADD		EDI, 4
	LOOP	_arrLoop
	CMP		EAX, 1
	JE		_sortAlg					; Restarts if a swap occured
	POP		EBP
	RET		4
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Swaps two elements
;
; Preconditions: the array contains only positive values and an array is pushed 
; to the stack along with the position offests
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = offset for first element
; [ebp+12] = offset for second element
; [ebp+16] = address of randArray
;
; returns: none
; ---------------------------------------------------------------------------------


exchangeElements PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	MOV		EBX, [EBP + 8]
	MOV		EAX, [EBP + 12]
	MOV		ESI, [EBP + 16]
	; Swaps the elements
	MOV		ECX, [ESI + EAX]
	MOV		EDX, [ESI + EBX]
	MOV		[ESI + EAX], EDX
	MOV		[ESI + EBX], ECX

	POPAD
	POP		EBP
	RET		12
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Displays the median of an inputted array
;
; Preconditions: the array contains only positive values and an array is pushed 
; to the stack along with the string you would like to print beforehand
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = string to print
; [ebp+12] = address of randArray
;
; returns: none
; ---------------------------------------------------------------------------------

displayMedian PROC
	PUSH	EBP
	MOV		EBP, ESP
	CALL	CrLf
	; Prints string
	MOV		EDX, [ESP + 8]
	CALL	WriteString
	; Finds median
	MOV		ESI, [EBP + 12]
	MOV		EAX, ARRAYSIZE
	XOR		EDX, EDX
	MOV		EBX, 2
	DIV		EBX
	TEST	EDX, EDX					; Checks if ARRAYSIZE is an even number or odd number
	JE		_even
	MOV		EAX, [ESI + EAX * 4]		; When odd, the middle element is the median
	JMP		_print
_even:
	DEC		EAX
	MOV		EDX, [ESI + EAX * 4 - 4]
	ADD		EDX, [ESI + EAX * 4]
	MOV		EAX, EDX
	XOR		EDX, EDX
	DIV		EBX							; When even, the median is the average of the middle two elements
_print:
	CALL	WriteDec
	CALL	CrLf
	POP		EBP
	RET		8
displayMedian endp

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Prints out an inputted array along with an inputted message
;
; Preconditions: the array contains only positive values and an array is pushed 
; to the stack along with its' size and a string
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = address of array
; [ebp+12] = string to print
; [ebp+16] = size of array
;
; returns: none
; ---------------------------------------------------------------------------------

displayList PROC
	PUSH	EBP
	MOV		EBP,ESP

	MOV		ESI, [EBP + 8]
	; Prints string
	CALL	CrLf
	MOV		EDX, [EBP + 12]
	CALL	WriteString
	CALL	CrLf
	; Prints array
	MOV		ECX, [EBP + 16]
	XOR		EBX, EBX
_print:
	MOV		EAX, [ESI]
	CALL	WriteDec
	MOV		AL, " "
	CALL	WriteChar
	ADD		ESI, 4
	INC		EBX
	; Moves to a new line every 20 elements
	CMP		EBX, 20
	JNE		_continue
	CALL	CrLf
	XOR		EBX, EBX
_continue:
	LOOP	_Print

	POP		EBP
	RET		12
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; Counts the amount of each number in an inputted array
;
; Preconditions: the array contains only positive values and an array is pushed 
; to the stack along with an array to put values into
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = address of array to read
; [ebp+12] = address of array to store values
;
; returns: none
; ---------------------------------------------------------------------------------

countList PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		ESI, [ESP + 8]
	MOV		EDI, [ESP + 12]
	
	MOV		ECX, ARRAYSIZE
_loop:
	MOV		EAX, [ESI + ECX * 4 - 4]
	SUB		EAX, LO						; Subtract LO from the current value to get the index of that number in counts
	MOV		EBX, [EDI + EAX * 4]
	INC		EBX
	MOV		[EDI + EAX * 4], EBX
	LOOP	_loop

	POP		EBP
	RET		8
countList ENDP

; ---------------------------------------------------------------------------------
; Name: goodbye
;
; Prints the goodbye message of the program
;
; Preconditions: pushed a string to the stack
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = goodbye message
;
; returns: none
; ---------------------------------------------------------------------------------

goodbye PROC
	; Set stack frame
	PUSH	EBP
	MOV		EBP, ESP
	; prints goodbye message
	CALL	CrLf
	CALL	CrLf
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	
	; Set stack frame back to what it was before
	POP		EBP
	RET		20
goodbye	ENDP

END main

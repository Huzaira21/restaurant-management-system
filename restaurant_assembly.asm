 INCLUDE \irvine\Irvine32.inc
INCLUDELIB \irvine\Irvine32.lib
INCLUDE \irvine\macros.inc
INCLUDELIB user32.lib 
INCLUDELIB kernel32.lib


 




.data
   
   
   
   ; Strings
    welcomeMessage db "Welcome to our Restaurant!", 0
     promptMessage db "Select an option (1 = User, 2 = Admin): ", 0
    userMenuPrompt db "Select an option (1 = Breakfast, 2 = Lunch, 3 = Dinner 4= check role, 5 = Exit): ", 0



     



     item1 db "1. Pancakes", 0
item2 db "2. Omelette", 0
item3 db "3. French Toast", 0
item4 db "4. Burger", 0
item5 db "5. Salad", 0
item6 db "6. Pizza", 0
item7 db "7. Steak", 0
item8 db "8. Pasta", 0
item9 db "9. Grilled Fish", 0


     
     

     
    invalidChoiceMessage db "Invalid choice! Please try again.", 0
    enterItemNumberMessage db "Enter the item number: ", 0
    quantityMessage db "Enter quantity: ", 0
    discountMessage db "You get a 10% discount for ordering more than 3 items!", 0
    totalPriceMessage db "Total price after discount: $", 0
    confirmPaymentMessage db "Choose payment method (1 = Cash, 2 = Online): ", 0
    paymentConfirmedMessage db "Payment Confirmed. Thank you!", 0
    paymentMethodInvalid db "Invalid payment method. Exiting.", 0
    invalidItemMessage db "Invalid item choice. Please try again.", 0
    confirmOrderMessage db "Do you want to confirm your order? (1 = Yes, 2 = No): ", 0
     
     
    orderSummaryMessage db "Order Summary: ", 0
    loyaltyPointsMessage db "Your current loyalty points: ", 0
    redeemPointsMessage db "Would you like to redeem loyalty points for a discount? (1 = Yes, 2 = No): ", 0
    loyaltyPointsRedeemedMessage db "Loyalty points redeemed! Discount applied.", 0
    insufficientPointsMessage db "You don't have enough points to redeem.", 0

    orderCancelledMessage db "Order cancelled. Thank you for visiting!", 0
    newline db 13, 10, 0  ; Carriage return + Line feed + null terminator
    adminLoginPrompt db "Enter Admin username: ", 0
    adminPasswordPrompt db "Enter Admin password: ", 0
    adminInvalidMessage db "Invalid username or password. Please try again.", 0
     adminMenuMessage db "Admin Menu: 1 = Check Item Availability, 2 = Modify Item Availability, 3 = Reporting Dashboard, 4 = DisplayList, 5 = Back to Main Menu", 0
    checkItemMessage db "Enter the item number to check availability: ", 0
    itemAvailableMessage db "Item is available.", 0
    itemUnavailableMessage db "Item is unavailable.", 0
    modifyItemMessage db "Enter the item number to modify availability: ", 0
    itemModifiedMessage db "Item availability has been modified.", 0
     reportTotalOrdersMessage db "Total Orders: ", 0
    reportRevenueMessage db "Total Revenue: $", 0
     
    reportLoyaltyPointsMessage db "Total Loyalty Points Issued: ", 0
    resetReportsMessage db "Reports have been reset.", 0
    validUsername db "admin", 0
    validPassword db "password123", 0
    
     
     
  
     
     

 feedback_prompt BYTE "Enter your feedback (max 50 characters): ", 0
thank_you BYTE "Thanks for your feedback!", 0
buffer BYTE 51 DUP(0)   ; Buffer to hold user input (max 50 characters + 1 null terminator)

     
    username db 20 dup(0)  ; Reserve 20 bytes for username input (make sure it's large enough)
    password db 20 dup(0)  ; Reserve 20 bytes for password input

    
    
    breakfastItems db "1. Pancakes - $5.00", 0
                   db "2. Omelette - $6.00", 0
                   db "3. French Toast - $7.00", 0
                   db 0
    lunchItems db "1. Burger - $10.00", 0
               db "2. Salad - $8.00", 0
               db "3. Pizza - $12.00", 0
               db 0
    dinnerItems db "1. Steak - $15.00", 0
                db "2. Pasta - $12.00", 0
                db "3. Grilled Fish - $18.00", 0
                db 0

    prices db 5, 6, 7, 10, 8, 12, 15, 12, 18 ; Prices for items in order
    itemAvailability db 1, 1, 1, 1, 1, 1, 1, 1, 1 ; 1 means available, 0 means unavailable
    orderTotal dd 0      ; Total price for the current order
    taxRate db 7         ; Tax rate percentage (e.g., 7%)
    discountRate db 10   ; Discount rate (10%)
    loyaltyPoints dd 0   ; Loyalty points balance
      totalOrders dd 0     ; Total orders placed
    totalRevenue dd 0    ; Total revenue generated
     mostOrderedItem db 20 dup(0) ; 20-byte null string placeholder

    totalLoyaltyPoints dd 0 ; Total loyalty points issued
    
 
    
     

    colorCode dw 071h ; Blue background color (can be changed)
     
    
    



    continueOrderMessage db "Do you want to continue ordering? (1 = Yes, 2 = No): $"

    

    


.code

 
                                 

 


                            ; Function to display the admin reporting dashboard---------------------------


ShowReportingDashboard PROC
    mov edx, offset reportTotalOrdersMessage
    call WriteString
    mov eax, [totalOrders]
    call WriteInt
    call Crlf

    mov edx, offset reportRevenueMessage
    call WriteString
    mov eax, [totalRevenue]
    call WriteInt
    call Crlf

    

    mov edx, offset reportLoyaltyPointsMessage
    call WriteString
    mov eax, [LoyaltyPoints]
    call WriteInt
    call Crlf

    ; After displaying the dashboard, go back to Admin Menu
    jmp ShowAdminMenu

ShowReportingDashboard ENDP

                               ;function to display reset reports------------------------------

 
ResetReports PROC
    mov [totalOrders], 0
    mov [totalRevenue], 0
    mov [LoyaltyPoints], 0
    mov edx, offset resetReportsMessage
    call WriteString
    call Crlf
    ret
ResetReports ENDP
 



                                    ; Function to get the menu choice from the user------------------------------
GetMenuChoice:
    mov edx, offset promptMessage
    call WriteString
    call ReadInt
    ret

                                      ; Function to display all items from a menu-------------------------------------

DisplayMenu:
        

    DisplayMenuLoop:
        mov al, byte ptr [edx]       ; Load the first byte
        cmp al, 0                    ; Check for null terminator
        je CheckNextItem             ; If null, go to next item
        call WriteChar               ; Print the character
        inc edx                      ; Move to the next byte
        jmp DisplayMenuLoop

    CheckNextItem:
        add edx, 1                   ; Move to the next string
        cmp byte ptr [edx], 0        ; Check if it's the end of the list
        je EndDisplayMenu            ; End if no more items
        call Crlf                    ; Add a newline for the next item
        jmp DisplayMenuLoop          ; Continue displaying

    EndDisplayMenu:
        call Crlf                    ; Add a newline at the end
        ret

                              ; Function to display order summary-----------------------------------


DisplayOrderSummary:
    ; Display message to console
    mov edx, offset orderSummaryMessage
    call WriteString
    call Crlf
    mov eax, [orderTotal]          ; Load the total price
    call WriteInt
    call Crlf

     
 

 

 
                                        ; Function to display loyalty points balance-----------------------------

DisplayLoyaltyPoints:
    mov edx, offset loyaltyPointsMessage
    call WriteString
    mov eax, [loyaltyPoints]       ; Load loyalty points balance
    call WriteInt
    call Crlf
    ret

  RedeemLoyaltyPoints:
    mov edx, offset redeemPointsMessage
    call WriteString
    call ReadInt
    cmp eax, 1
    je ApplyLoyaltyDiscount
    cmp eax, 2
    je NoLoyaltyDiscount
    ret

ApplyLoyaltyDiscount:
    mov eax, [loyaltyPoints]
    cmp eax, 10
    jl InsufficientPoints
    sub [loyaltyPoints], 10
    sub [orderTotal], 1
    mov edx, offset loyaltyPointsRedeemedMessage
    call WriteString
    call Crlf
    ret

NoLoyaltyDiscount:
    ret

InsufficientPoints:
    mov edx, offset insufficientPointsMessage
    call WriteString
    call Crlf
    ret
                            ;function to display user feedback----------------------------------------     



    feedback PROC
    ; Display feedback prompt
    mov edx, OFFSET feedback_prompt
    call WriteString

    ; Get user feedback string
    mov edx, OFFSET buffer  ; Set buffer address
    mov ecx, 50             ; Max characters to read
    call ReadString         ; Read string input from user

    ; Display a thank you message
    mov edx, OFFSET thank_you
    call WriteString

    ; Optional: Display the feedback back to the user
    mov edx, OFFSET buffer
    call WriteString

    ret
feedback ENDP




                                      ;display when you are an admin-----------------------------------
  AdminLogin:
    ; Retry counter for username/password attempts
    mov ecx, 3  ; Set max attempts to 3
    ; After reading username
mov edx, offset username
call WriteString
call Crlf


LoginLoop:
    ; Step 1: Prompt for Admin Username
    mov edx, offset adminLoginPrompt
    call WriteString
    lea edx, [username]
    call ReadString   ; Read the username into 'username' buffer
    call TrimNewline

     lea esi, [validUsername]  ; Valid username
lea edi, [username]       ; User input username
mov al, [esi]
cmp al, [edi]
jne InvalidUsername       ; If not equal, jump to InvalidUsername

    ; Step 3: If username is valid, prompt for Admin Password
    mov edx, offset adminPasswordPrompt
    call WriteString
    lea edx, [password]
    call ReadString   ; Read the password into 'password' buffer
    call TrimNewline

    ; For Password Comparison (Checking only the first character)
lea esi, [validPassword]  ; Load address of valid password
lea edi, [password]       ; Load address of input password
mov al, [esi]             ; Load the first byte of valid password into al
cmp al, [edi]             ; Compare it with the first byte of the input password
jne InvalidPassword       ; Jump to InvalidPassword if they don't match


    ; Step 5: If both username and password are valid, proceed to Admin Menu
    jmp ShowAdminMenu

InvalidUsername:
    mov edx, offset adminInvalidMessage
    call WriteString
    call Crlf
    ; Decrement retry counter and check if attempts are left
    dec ecx
    cmp ecx, 0
    je BackToMainMenu   ; If no attempts left, go to the main menu
    jmp LoginLoop

InvalidPassword:
    mov edx, offset adminInvalidMessage
    call WriteString
    call Crlf
    ; Allow user to retry password
    dec ecx
    cmp ecx, 0
    je BackToMainMenu
    jmp LoginLoop

BackToMainMenu:
    jmp ShowUserMenu

                               ; ============================================
                                 ; Procedure to compare two null-terminated strings



; Returns ZF set if strings are equal, clear if not
CompareStrings PROC
    CompareLoop:
        mov al, [esi]       ; Load character from valid string
        mov bl, [edi]       ; Load character from input string
        cmp al, bl
        jne StringsNotEqual ; If mismatch, return non-zero
        test al, al
        je StringsEqual     ; If null terminator reached, strings are equal
        inc esi             ; Move to next character in valid string
        inc edi             ; Move to next character in input string
        jmp CompareLoop

    StringsEqual:
        xor eax, eax        ; Set return value to 0 (strings match)
        ret

    StringsNotEqual:
        mov eax, 1          ; Set return value to non-zero (strings do not match)
        ret
CompareStrings ENDP

 TrimNewline PROC
    mov edi, edx
    FindNewline:
        mov al, [edi]
        cmp al, 13
        je ReplaceWithNull
        cmp al, 10
        je ReplaceWithNull
        test al, al
        je EndTrim
        inc edi
        jmp FindNewline
    ReplaceWithNull:
        mov byte ptr [edi], 0
    EndTrim:
        ret
TrimNewline ENDP


                                               ; Main function--------------------



main:
                                                 ;For adding colors*********
 


invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov ebx, eax  ; Save console handle
    
    ; Set green background with pink text
    invoke SetConsoleTextAttribute, ebx, colorcode
    

 

    

                                        ; Display welcome message___________________________________________
    mov edx, offset welcomeMessage
    call WriteString
    call Crlf

    ; Prompt user with a message box (GUI prompt)
    push 0                  ; MB_OK
    push OFFSET welcomeMessage
    push OFFSET promptMessage
    push 0
    call MessageBoxA


    ; Display user menu prompt
    push 0                   ; MB_OK
    push OFFSET userMenuPrompt
    push OFFSET promptMessage
    push 0
    call MessageBoxA

 
     

                             ;check role you are a user or an admin------------------------------------------
    
    
    
    
    CheckRole:
    ; Ask the user to choose role (User or Admin)
    mov edx, offset promptMessage
    call WriteString
    call ReadInt
    cmp eax, 1
    je ShowUserMenu    ; User role selected
    cmp eax, 2
    je AdminLogin      ; Admin role selected
    jmp InvalidChoice  ; Invalid choice, handle accordingly


                               ;show menu if u are an user------------------------------
  
  
  
  ShowUserMenu:
    ; Show menu for regular user
    mov edx, offset userMenuPrompt
    call WriteString
    call ReadInt
    cmp eax, 1
    je ShowBreakfastMenu
    cmp eax, 2
    je ShowLunchMenu
    cmp eax, 3
    je ShowDinnerMenu
    cmp eax, 4
    je CheckRole
    cmp eax, 5
    je ExitProgram
    jmp InvalidChoice ; If invalid choice


                               ;log in as a admin----------------------------------------


Admin:
    ; Admin login logic here
    ; After successful login, show Admin menu
    jmp AdminLogin 


                         ; Display Breakfast menu$$$$
     ShowBreakfastMenu:
     
    mov edx, offset breakfastItems
    call DisplayMenu
    mov esi, 0 ; Starting index for breakfast prices
    call HandleItemChoice ; Handle item choice for breakfast
    jmp ShowUserMenu ; Return to user menu after handling
                          ; Display Lunch menu$$$$$
 ShowLunchMenu:
    
    mov edx, offset lunchItems
    call DisplayMenu
    mov esi, 3 ; Starting index for lunch prices (index 3 for lunch)
    call HandleItemChoice ; Handle item choice for lunch
    jmp ShowUserMenu ; Return to user menu after handling
     
                          ; Display Dinner menu$$$$$$$    

     ShowDinnerMenu:
     
    mov edx, offset dinnerItems
    call DisplayMenu
    mov esi, 6 ; Starting index for dinner prices (index 6 for dinner)
    call HandleItemChoice ; Handle item choice for dinner
    jmp ShowUserMenu ; Return to user menu after handling


                            ; Display item selection message---------------------------------------


  HandleItemChoice:
    ; Display item selection message
    mov edx, offset enterItemNumberMessage
    call WriteString
    call ReadInt
    dec eax                       ; Convert to 0-based index
    cmp eax, 2                    ; Validate item choice (0, 1, 2)
    ja InvalidItem

 ; Calculate address of the selected item's price based on the menu type (Breakfast, Lunch, Dinner)
    lea edi, prices               ; Load address of prices array
    add edi, esi                  ; Add the starting index for the current menu (Breakfast, Lunch, Dinner)

    ; Load the selected price into ebx (using only eax for indexing)
    movzx ebx, byte ptr [edi + eax] ; Load selected item price for the correct menu
     
     
     
                        ; Display quantity message------

    mov edx, offset quantityMessage
    call WriteString
    call ReadInt
    mov ecx, eax                  ; Store quantity


     ; Calculate total price (price * quantity)
    imul ebx, ecx                 ; ebx = price * quantity
    mov eax, ebx                  ; Move result to eax for further processing



     ; Check if quantity > 3 for discount
    cmp ecx, 3
    jle NoDiscount

    ; Apply 10% discount using imul (multiply by 9 for 90% of the total)
    imul eax, eax, 9               ; eax = total * 9 (90% of total)
    imul eax, eax, 10              ; eax = eax / 10 to adjust for the percentage (10% discount applied)

   

NoDiscount:
    ; Add total price to orderTotal
    add [orderTotal], eax

    ; Add loyalty points for each order
    add [loyaltyPoints], 5          ; Add 5 points for each order item

    ; Display the updated total price after discount and loyalty points
    mov edx, offset totalPriceMessage
    call WriteString
    mov eax, [orderTotal]
    call WriteInt
    call Crlf

    ; Display current loyalty points balance
    call DisplayLoyaltyPoints


     ; Ask user if they want to continue ordering or finalize
    mov edx, offset continueOrderMessage
    call WriteString
    call ReadInt
    cmp eax, 1                     ; If user chooses to continue
    je HandleItemChoice            ; Proceed to the next item selection

    ; If user selects "No" (finalize the order), proceed to confirm order
    ; No extra messages to be shown here
    call ConfirmOrder  ; Proceed to order confirmation
   mov [orderTotal], 0            ; Reset order total
    mov [loyaltyPoints], 0         ; Reset loyalty points
   
   
   ret

 
    ; Display the total price
    mov eax, [orderTotal]          ; Load the total price
    call WriteInt
    call Crlf

    ; Display the loyalty points
    call DisplayLoyaltyPoints
     
    ret





   
InvalidItem:
    mov edx, offset invalidItemMessage
    call WriteString
    call Crlf
    jmp ShowUserMenu
    
    
    
                             ;confirmation of order--------------------------------------


ConfirmOrder:
    mov edx, offset confirmOrderMessage
    call WriteString
    call ReadInt
    cmp eax, 1
    je AskForPayment
    cmp eax, 2
    je CancelOrder
    ret

AskForPayment:
    ; Display order summary
    call DisplayOrderSummary
   
  
    mov edx, offset confirmPaymentMessage
    call WriteString
    call ReadInt
    cmp eax, 1
    je PaymentConfirmed
    cmp eax, 2
    je PaymentConfirmed
    mov edx, offset paymentMethodInvalid
    call WriteString
    call Crlf
    ret

CancelOrder:
    mov edx, offset orderCancelledMessage
    call WriteString
    call Crlf
    ret


                                 ;payment coonfirmation---------------------------------------------


PaymentConfirmed:
    ; Add tax without using div
mov al, [taxRate]          ; Load the tax rate into al
mov ebx, [orderTotal]      ; Load the order total into ebx

imul ebx, eax              ; Multiply orderTotal by taxRate
mov eax, ebx               ; Move the result into eax

; To divide by 100, you can shift the value (divide by 2^n) which is equivalent to division by 100.
; This avoids using the 'div' instruction. 
shr eax, 7                 ; Right shift by 7 (approximately divide by 100)

add [orderTotal], eax      ; Add the tax to orderTotal

    mov edx, offset paymentConfirmedMessage
    call WriteString

    call Crlf
     call  feedback; Ask for feedback after payment confirmation
    
    ret
      

      ; Display Admin Menu options and handle the selected choice-----------------------
      
      
      ShowAdminMenu:
    ; Display Admin Menu options and handle the selected choice
    mov edx, offset adminMenuMessage
    call WriteString
    call ReadInt
    cmp eax, 1
    je CheckItemAvailability
    cmp eax, 2
    je ModifyItemAvailability
    cmp eax, 3
    je ShowReportingDashboard
    cmp eax, 4
    je DisplayList
    cmp eax, 5
    je  ShowUserMenu
    jmp InvalidAdminChoice


                                 ;function to display list------------------------------

  DisplayList PROC
    ; Display menu item 1
    mov edx, offset item1
    call WriteString
    call Crlf  ; New line after each item

    ; Display menu item 2
    mov edx, offset item2
    call WriteString
    call Crlf

    ; Display menu item 3
    mov edx, offset item3
    call WriteString
    call Crlf

    ; Display menu item 4
    mov edx, offset item4
    call WriteString
    call Crlf

    ; Display menu item 5
    mov edx, offset item5
    call WriteString
    call Crlf

    ; Display menu item 6
    mov edx, offset item6
    call WriteString
    call Crlf

    ; Display menu item 7
    mov edx, offset item7
    call WriteString
    call Crlf

    ; Display menu item 8
    mov edx, offset item8
    call WriteString
    call Crlf

    ; Display menu item 9
    mov edx, offset item9
    call WriteString
    call Crlf
    jmp ShowAdminMenu 

    ; Return to Admin Menu
    ret
DisplayList ENDP


                               ;check items are available through list-----------
  
CheckItemAvailability:
    mov edx, offset checkItemMessage
    call WriteString
    call ReadInt
    dec eax ; Convert to 0-based index
    lea ebx, [itemAvailability + eax]
    mov al, [ebx]
    cmp al, 1
    je ItemAvailable
    mov edx, offset itemUnavailableMessage
    call WriteString
    call Crlf
    jmp ShowAdminMenu  ; Return to the admin menu instead of ending

ItemAvailable:
    mov edx, offset itemAvailableMessage
    call WriteString
    call Crlf
    jmp ShowAdminMenu  ; Return to the admin menu instead of ending




ModifyItemAvailability:
    mov edx, offset modifyItemMessage
    call WriteString
    call ReadInt
    dec eax ; Convert to 0-based index
    lea ebx, [itemAvailability + eax]
    mov byte ptr [ebx], 0 ; Mark as unavailable
    mov edx, offset itemModifiedMessage
    call WriteString
    call Crlf
    jmp ShowAdminMenu  ; Return to the admin menu instead of ending

InvalidChoice:
    mov edx, offset invalidChoiceMessage
    call WriteString
    call Crlf
    jmp ShowUserMenu

 InvalidAdminChoice:
    mov edx, offset invalidChoiceMessage
    call WriteString
    call Crlf
    jmp ShowAdminMenu


ExitProgram:
    call ExitProcess
    end main

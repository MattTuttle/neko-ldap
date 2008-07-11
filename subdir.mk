# Add inputs and outputs from these tool invocations to the build variables 
C_INCS += -I include

C_SRCS += \
./src/nekoldap.c 

OBJS += \
./build/nekoldap.o 

C_DEPS += \
./build/nekoldap.d 


# Each subdirectory must supply rules for building sources it contributes
./build/%.o: ./src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O0 -g3 $(C_INCS) -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



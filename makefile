MKDIR := mkdir -p
COPY := cp -u
RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: nekoldap.ndll haxelib

# Tool invocations
nekoldap.ndll: $(OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	gcc -shared -Wl,-soname=nekoldap -o"build/nekoldap.ndll" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(LIBRARIES) build/nekoldap.ndll
	-@echo ' '


haxelib: nekoldap.ndll
	@echo 'Building target: $@'
	$(MKDIR) build/haxelib/nekoldap
	$(MKDIR) build/haxelib/ndll/Windows
	$(COPY) haxe/nekoldap/Ldap.hx build/haxelib/nekoldap/Ldap.hx
	$(COPY) haxe/nekoldap/LdapException.hx build/haxelib/nekoldap/LdapException.hx
	$(COPY) haxe/haxelib.xml build/haxelib/haxelib.xml
	$(COPY) build/nekoldap.ndll build/haxelib/ndll/Windows/nekoldap.ndll
	@echo 'Finished building target: $@'
	@echo ' '
.PHONY: all clean dependents
.SECONDARY:

#---------
#
# MakefileWorker.mk
#
# Include this helper file in your makefile
# It makes
#    A static library holding the application objs
#    A test executable
#
# See this example for parameter settings 
#    examples/Makefile
#
#----------
# Inputs - these variables describe what to build
#
#   INCLUDE_DIRS - Directories used to search for include files.
#                   This generates a -I for each directory
#	SRC_DIRS - Directories containing source file to built into the library
#   SRC_FILES - Specific source files to build into library. Helpful when not all code 
#				in a directory can be built for test (hopefully a temporary situation)
#	TEST_SRC_DIRS - Directories containing unit test code build into the unit test runner
#				These do not go in a library. They are explicitly included in the test runner
#	MOCKS_SRC_DIRS - Directories containing mock source files to build into the test runner
#				These do not go in a library. They are explicitly included in the test runner
#----------
# You can adjust these variables to influence how to build the test target
# and where to put and name outputs
# See below to determine defaults
#   COMPONENT_NAME - the name of the thing being built
#   UNITY_HOME - where Unity home dir found
#   UNITY_BUILD_HOME - place for scripts
#   UNITY_OBJS_DIR - a directory where o and d files go
#   UNITY_LIB_DIR - a directory where libs go
#   UNITY_64BIT_POINTER - Defaults to N, set to Y
#   UNITY_ENABLE_DEBUG - build for debug
#   UNITY_USE_MEM_LEAK_DETECTION - Links with overridden new and delete
#   UNITY_USE_STD_CPP_LIB - Set to N to keep the standard C++ library out
#		of the test harness
#   UNITY_USE_GCOV - Turn on coverage analysis
#		Clean then build with this flag set to Y, then 'make gcov'
#	UNITY_TEST_RUNNER_FLAGS
#		None by default
#   UNITY_MAPFILE - generate a map file
#   UNITY_WARNINGFLAGS - overly picky by default
#	OTHER_MAKEFILE_TO_INCLUDE - a hook to use this makefile to make 
#		other targets. Like CSlim, which is part of fitnesse
#----------
#
#  Other flags users can initialize to sneak in their settings
#	UNITY_CFLAGS - C complier
#	UNITY_LDFLAGS - Linker flags
#----------


ifndef COMPONENT_NAME
    COMPONENT_NAME = assign_COMPONENT_NAME_in_your_makefile
endif

#Kludge for mingw, it does not have cc.exe, but gcc.exe will do
#BTW: I'm just guessing that mingw is 32 bit only
ifeq ($(findstring mingw,$(PATH)), mingw)
	CC := gcc
	LONG_BITS = 32
endif

#Kludge to work around cygwin's not supporting getconf
ifeq ($(findstring CYGWIN, $(shell uname)), CYGWIN)
  LONG_BITS = 32
endif

ifndef LONG_BITS
  LONG_BITS = $(shell getconf LONG_BIT)
endif


# Unity 32-bit pointers by default
UNITY_64BIT_POINTER = N
ifeq ($(LONG_BITS), 64)
	UNITY_64BIT_POINTER = Y
endif

# Debug on by default
ifndef UNITY_ENABLE_DEBUG
	UNITY_ENABLE_DEBUG = Y
endif

# new and delete for memory leak detection on by default
ifndef UNITY_USE_MEM_LEAK_DETECTION
	UNITY_USE_MEM_LEAK_DETECTION = Y
endif

# Use gcov, off by default
ifndef UNITY_USE_GCOV
	UNITY_USE_GCOV = N
endif

# Default warnings
ifndef UNITY_WARNINGFLAGS
	UNITY_WARNINGFLAGS = -Wall -Werror -Wshadow -Wswitch-default 
endif

# Default dir for temporary files (d, o)
ifndef UNITY_OBJS_DIR
    UNITY_OBJS_DIR = objs
endif

# Default dir for the outout library
ifndef UNITY_LIB_DIR
    UNITY_LIB_DIR = lib
endif

# No map by default
ifndef UNITY_MAP_FILE
	UNITY_MAP_FILE = N
endif

#Not verbose by deafult
ifdef VERBOSE
	UNITY_TEST_RUNNER_FLAGS += -v
endif

ifdef GROUP
	UNITY_TEST_RUNNER_FLAGS += -g $(GROUP)
endif

ifdef NAME
	UNITY_TEST_RUNNER_FLAGS += -n $(NAME)
endif

ifdef REPEAT
	UNITY_TEST_RUNNER_FLAGS += -r $(REPEAT)
endif


# --------------------------------------
# derived flags in the following area
# --------------------------------------
ifeq ($(UNITY_USE_MEM_LEAK_DETECTION), N)
	UNITY_CFLAGS += -DUNITY_MEM_LEAK_DETECTION_DISABLED
else
	UNITY_MEMLEAK_DETECTOR_MALLOC_MACRO_FILE = -include $(UNITY_HOME)/extras/fixture/src/unity_fixture_malloc_overrides.h
endif

ifeq ($(UNITY_ENABLE_DEBUG), Y)
	UNITY_CFLAGS += -g
endif

ifeq ($(UNITY_USE_GCOV), Y)
	UNITY_CFLAGS += -fprofile-arcs -ftest-coverage
endif

ifeq ($(UNITY_64BIT_POINTER), Y)
    UNITY_CFLAGS += -DUNITY_POINTER_WIDTH=64 
endif

UNITY_CFLAGS += $(UNITY_MEMLEAK_DETECTOR_MALLOC_MACRO_FILE)
UNITY_CFLAGS += -DUNITY_SUPPORT_64=1

TARGET_MAP = $(COMPONENT_NAME).map.txt
ifeq ($(UNITY_MAP_FILE), Y)
	UNITY_LDFLAGS += -Wl,-map,$(TARGET_MAP)
endif

TARGET_LIB = \
    $(UNITY_LIB_DIR)/lib$(COMPONENT_NAME).a
    
TEST_TARGET = \
    $(COMPONENT_NAME)_tests

#Helper Functions
get_src_from_dir  = $(wildcard $1/*.cpp) $(wildcard $1/*.c)
get_dirs_from_dirspec  = $(wildcard $1)
get_src_from_dir_list = $(foreach dir, $1, $(call get_src_from_dir,$(dir)))
__src_to = $(subst .c,$1, $(subst .cpp,$1,$2))
src_to = $(addprefix $(UNITY_OBJS_DIR)/,$(call __src_to,$1,$2))
src_to_o = $(call src_to,.o,$1)
src_to_d = $(call src_to,.d,$1)
src_to_gcda = $(call src_to,.gcda,$1)
src_to_gcno = $(call src_to,.gcno,$1)
make_dotdot_a_subdir = $(subst ..,_dot_dot, $1)
time = $(shell date +%s)
delta_t = $(eval minus, $1, $2)
debug_print_list = $(foreach word,$1,echo "  $(word)";) echo;

#Derived
STUFF_TO_CLEAN += $(TEST_TARGET) $(TEST_TARGET).exe $(TARGET_LIB) $(TARGET_MAP)

SRC += $(call get_src_from_dir_list, $(SRC_DIRS)) $(SRC_FILES)			        
OBJ = $(call src_to_o,$(SRC))
OBJ2 = $(call make_dotdot_a_subdir. $(OBJ))

STUFF_TO_CLEAN += $(OBJ)

TEST_SRC = $(call get_src_from_dir_list, $(TEST_SRC_DIRS))
TEST_OBJS = $(call src_to_o,$(TEST_SRC))
STUFF_TO_CLEAN += $(TEST_OBJS)


MOCKS_SRC = $(call get_src_from_dir_list, $(MOCKS_SRC_DIRS))
MOCKS_OBJS = $(call src_to_o,$(MOCKS_SRC))
STUFF_TO_CLEAN += $(MOCKS_OBJS)

ALL_SRC = $(SRC) $(TEST_SRC) $(MOCKS_SRC)

#Test coverage with gcov
GCOV_OUTPUT = gcov_output.txt
GCOV_REPORT = gcov_report.txt
GCOV_ERROR = gcov_error.txt
GCOV_GCDA_FILES = $(call src_to_gcda, $(ALL_SRC))
GCOV_GCNO_FILES = $(call src_to_gcno, $(ALL_SRC))
TEST_OUTPUT = $(TEST_TARGET).txt
STUFF_TO_CLEAN += \
	$(GCOV_OUTPUT)\
	$(GCOV_REPORT)\
	$(GCOV_REPORT).html\
	$(GCOV_ERROR)\
	$(GCOV_GCDA_FILES)\
	$(GCOV_GCNO_FILES)\
	$(TEST_OUTPUT)


#The gcda files for gcov need to be deleted before each run
#To avoid annoying messages.
GCOV_CLEAN = $(SILENCE)rm -f $(GCOV_GCDA_FILES) $(GCOV_OUTPUT) $(GCOV_REPORT) $(GCOV_ERROR)
RUN_TEST_TARGET = $(SILENCE)  $(GCOV_CLEAN) ; echo "Running $(TEST_TARGET)"; ./$(TEST_TARGET) $(UNITY_TEST_RUNNER_FLAGS)

INCLUDES_DIRS_EXPANDED = $(call get_dirs_from_dirspec, $(INCLUDE_DIRS))
INCLUDES += $(foreach dir, $(INCLUDES_DIRS_EXPANDED), -I$(dir))
MOCK_DIRS_EXPANDED = $(call get_dirs_from_dirspec, $(MOCKS_SRC_DIRS))
INCLUDES += $(foreach dir, $(MOCK_DIRS_EXPANDED), -I$(dir))


DEP_FILES = $(call src_to_d, $(ALL_SRC))
STUFF_TO_CLEAN += $(DEP_FILES) $(PRODUCTION_CODE_START) $(PRODUCTION_CODE_END)
STUFF_TO_CLEAN += $(STDLIB_CODE_START) $(MAP_FILE) cpputest_*.xml junit_run_output

# We'll use the UNITY_CFLAGS etc so that you can override AND add to the CppUTest flags
CFLAGS = $(UNITY_CFLAGS) $(UNITY_ADDITIONAL_CFLAGS) $(INCLUDES) $(UNITY_WARNINGFLAGS)
LDFLAGS = $(UNITY_LDFLAGS) $(UNITY_ADDITIONAL_LDFLAGS)

# Targets

.PHONY: all
all: start $(TEST_TARGET)  
	$(RUN_TEST_TARGET)	

.PHONY: start
start: $(TEST_TARGET) 
	$(SILENCE)START_TIME=$(call time)

.PHONY: all_no_tests
all_no_tests: $(TEST_TARGET)

.PHONY: flags
flags: 
	@echo
	@echo "Compile C source with CFLAGS:"
	@$(call debug_print_list,$(CFLAGS))
	@echo "Link with LDFLAGS:"
	@$(call debug_print_list,$(LDFLAGS))
	@echo "Link with LD_LIBRARIES:"
	@$(call debug_print_list,$(LD_LIBRARIES))
	@echo "Create libraries with ARFLAGS:"
	@$(call debug_print_list,$(ARFLAGS))
	@echo "OBJ files:"
	@$(call debug_print_list,$(OBJ2))
	
	
$(TEST_TARGET): $(TEST_OBJS) $(MOCKS_OBJS)  $(PRODUCTION_CODE_START) $(TARGET_LIB) $(USER_LIBS) $(PRODUCTION_CODE_END) $(STDLIB_CODE_START) 
	$(SILENCE)echo Linking $@
	$(SILENCE)$(LINK.o) -o $@ $^ $(LD_LIBRARIES)

$(TARGET_LIB): $(OBJ)
	$(SILENCE)echo Building archive $@
	$(SILENCE)mkdir -p lib
	$(SILENCE)$(AR) $(ARFLAGS) $@ $^
	$(SILENCE)ranlib $@

test: $(TEST_TARGET)
	$(RUN_TEST_TARGET) | tee $(TEST_OUTPUT)
	
vtest: $(TEST_TARGET)
	$(RUN_TEST_TARGET) -v  | tee $(TEST_OUTPUT)

$(UNITY_OBJS_DIR)/%.o: %.cpp
	@echo compiling $(notdir $<)
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(COMPILE.cpp) -MMD -MP $(OUTPUT_OPTION) $<

$(UNITY_OBJS_DIR)/%.o: %.c
	@echo compiling $(notdir $<)
	$(SILENCE)mkdir -p $(dir $@)
	$(SILENCE)$(COMPILE.c) -MMD -MP  $(OUTPUT_OPTION) $<

ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEP_FILES)
endif

.PHONY: clean
clean:
	$(SILENCE)echo Making clean
	$(SILENCE)$(RM) $(STUFF_TO_CLEAN)
	$(SILENCE)rm -rf gcov $(UNITY_OBJS_DIR)
	$(SILENCE)find . -name "*.gcno" | xargs rm -f
	$(SILENCE)find . -name "*.gcda" | xargs rm -f
	
#realclean gets rid of all gcov, o and d files in the directory tree
#not just the ones made by this makefile
.PHONY: realclean
realclean: clean
	$(SILENCE)rm -rf gcov
	$(SILENCE)find . -name "*.gdcno" | xargs rm -f
	$(SILENCE)find . -name "*.[do]" | xargs rm -f	

gcov: test
	$(SILENCE)for d in $(SRC_DIRS) ; do \
		gcov --object-directory $(UNITY_OBJS_DIR)/$$d $$d/*.c $$d/*.cpp >> $(GCOV_OUTPUT) 2>>$(GCOV_ERROR) ; \
	done
	$(SILENCE)for f in $(SRC_FILES) ; do \
		gcov --object-directory $(UNITY_OBJS_DIR)/$$f $$f >> $(GCOV_OUTPUT) 2>>$(GCOV_ERROR) ; \
	done
	$(UNITY_BUILD_HOME)/filterGcov.sh $(GCOV_OUTPUT) $(GCOV_ERROR) $(GCOV_REPORT) $(TEST_OUTPUT)
	$(SILENCE)cat $(GCOV_REPORT)
	$(SILENCE)mkdir -p gcov
	$(SILENCE)mv *.gcov gcov
	$(SILENCE)mv gcov_* gcov
	$(SILENCE)echo "See gcov directory for details"
 
debug:
	@echo
	@echo "Target Source files:"
	@$(call debug_print_list,$(SRC))
	@echo "Target Object files:"
	@$(call debug_print_list,$(OBJ))
	@echo "Test Source files:"
	@$(call debug_print_list,$(TEST_SRC))
	@echo "Test Object files:"
	@$(call debug_print_list,$(TEST_OBJS))
	@echo "Mock Source files:"
	@$(call debug_print_list,$(MOCKS_SRC))
	@echo "Mock Object files:"
	@$(call debug_print_list,$(MOCKS_OBJS))
	@echo "All Input Dependency files:"
	@$(call debug_print_list,$(DEP_FILES))
	@echo Stuff to clean:
	@$(call debug_print_list,$(STUFF_TO_CLEAN))
	@echo Includes:
	@$(call debug_print_list,$(INCLUDES))

ifneq "$(OTHER_MAKEFILE_TO_INCLUDE)" ""
-include $(OTHER_MAKEFILE_TO_INCLUDE)
endif

	
	

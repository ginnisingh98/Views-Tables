--------------------------------------------------------
--  DDL for Package WSH_DEBUG_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DEBUG_SV" AUTHID CURRENT_USER as
/* $Header: WSHDEBGS.pls 120.1 2007/08/06 13:38:15 ueshanka ship $ */
/*===========================================================================
  PACKAGE NAME:		wsh_debug_sv

  DESCRIPTION:		Contains common routines required by Shipping



  CLIENT/SERVER:	Server

  PROCEDURE/FUNCTIONS:	debug
			enable_debug
		        disable_debug
			debug_enabled
			get_debug_levels
			print_debug_stuff

===========================================================================*/
--bug 6215206: Added global variable to check if debugging is initialized
--from ITM Asynchronous process.
g_itm_asyn_proc   BOOLEAN := FALSE;

g_File        Varchar2(32767)     := null;
g_Dir	      Varchar2(32767)     := fnd_profile.value('WSH_DEBUG_LOG_DIRECTORY');

TYPE t_DebugLevels IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE t_TimeType IS RECORD(
  Marker	VARCHAR2(200),
  Time		NUMBER,
  CallCount	NUMBER,
  TotalTime	NUMBER);

TYPE t_TimeStack IS TABLE OF t_TimeType
  INDEX BY BINARY_INTEGER;

TYPE t_CallStack IS TABLE OF VARCHAR2(32767)
  INDEX BY BINARY_INTEGER;

TYPE t_NumberTable      IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

g_TimeStack     t_TimeStack;
g_CallStack	t_CallStack;
g_DebugLevels 	t_DebugLevels;
--g_MaxLevels	NUMBER := 31;
g_MaxLevels	NUMBER := 7;

g_FileHandle	utl_file.file_type;
C_FILE		NUMBER := 1;
C_PIPE		NUMBER := 2;
C_SCREEN	NUMBER := 4;
C_SQLTRACE	NUMBER := 8;
C_DELIMITER	VARCHAR2(5) := ' ==> ';
C_FILLER	VARCHAR2(1) := '-';
--C_DEBUG_PIPE	VARCHAR2(30) := 'WSH_DEBUG_PIPE';
C_PIPE_SIZE	NUMBER := 1000000;
C_PREFIX	VARCHAR2(15) := 'wsh';
C_SUFFIX	VARCHAR2(15) := '.dbg';
E_PIPE_FAILURE	NUMBER := -20000;

C_LEVEL1	NUMBER := 32;
C_LEVEL2	NUMBER := 8;
--C_LEVEL1	NUMBER := 16;
--C_LEVEL2	NUMBER := 32;

C_PERF_LEVEL		NUMBER := 2;
C_STMT_LEVEL		NUMBER := 8;
C_PROC_LEVEL		NUMBER := 32;
C_EVENT_LEVEL		NUMBER := 128;
C_EXCEP_LEVEL		NUMBER := 512;
C_ERR_LEVEL		NUMBER := 2048;
C_UNEXPEC_ERR_LEVEL	NUMBER := 8192;




/*===========================================================================
  FUNCTION NAME:	level_defined

  DESCRIPTION:   	This function true if the passed level is defined.

  PARAMETERS:		x_Level	IN 	NUMBER
===========================================================================*/
FUNCTION level_defined (x_Level IN NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	start_time

  DESCRIPTION:   	This procedure puts a time on the stack.

  PARAMETERS:		x_Level		IN	NUMBER
			x_Marker	IN 	VARCHAR2
			x_Context	IN	VARCHAR2
===========================================================================*/
PROCEDURE start_time (x_Level IN NUMBER, x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	start_time

  DESCRIPTION:   	This procedure puts a time on the stack.

  PARAMETERS:		x_Marker	IN 	VARCHAR2
			x_Context	IN	VARCHAR2

===========================================================================*/
PROCEDURE start_time (x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	stop_time

  DESCRIPTION:   	This procedure shows time elapsed for the passed marker value

  PARAMETERS:		x_Level		IN	NUMBER
			x_Marker	IN 	NUMBER
			x_Context	IN	VARCHAR2 := NULL

===========================================================================*/
PROCEDURE stop_time (x_Level IN NUMBER, x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	stop_time

  DESCRIPTION:   	This procedure shows time elapsed for the passed marker value

  PARAMETERS:		x_Marker	IN 	NUMBER
			x_Context	IN	VARCHAR2 := NULL

===========================================================================*/
PROCEDURE stop_time (x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	tstart

  DESCRIPTION:   	This procedure stores start time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

===========================================================================*/
PROCEDURE tstart(x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstart

  DESCRIPTION:   	This procedure stores start time for a function

  PARAMETERS:		x_Level  IN	NUMBER
			x_Marker IN 	VARCHAR2

===========================================================================*/
PROCEDURE tstart(x_Level IN NUMBER, x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstop

  DESCRIPTION:   	This procedure stores elapsed time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

===========================================================================*/
PROCEDURE tstop(x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstop

  DESCRIPTION:   	This procedure stores elapsed time for a function

  PARAMETERS:		x_Level  IN	NUMBER
			x_Marker	IN 	VARCHAR2

===========================================================================*/
PROCEDURE tstop(x_Level IN NUMBER, x_Marker IN VARCHAR2);


/*===========================================================================
  FUNCTION NAME:	tprint

  DESCRIPTION:   	This function prints elapsed time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

===========================================================================*/
FUNCTION tprint(x_Marker IN VARCHAR2) RETURN VARCHAR2;


/*===========================================================================
  PROCEDURE NAME:	tdump

  DESCRIPTION:   	This procedure dumps stored times for all functions.

  PARAMETERS:		x_Marker	IN 	VARCHAR2

===========================================================================*/
PROCEDURE tdump(x_Context IN VARCHAR2 DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:	tdump

  DESCRIPTION:   	This procedure dumps stored times for all functions.

  PARAMETERS:		x_Level IN	NUMBER
			x_Context	IN 	VARCHAR2

===========================================================================*/
PROCEDURE tdump(x_Level IN NUMBER, x_Context IN VARCHAR2 DEFAULT NULL);


/*===========================================================================
  PROCEDURE NAME:	write_output

  DESCRIPTION:   	This procedure writes output to the requested areas


===========================================================================*/
PROCEDURE write_output(x_Line IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	write_long_output

  DESCRIPTION:   	This procedure writes output to the requested areas


===========================================================================*/
--PROCEDURE write_long_output(x_Pad_Space IN VARCHAR2, x_Mesg IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	logmsg

  DESCRIPTION:   	This procedure prints string followed by a boolean
			Does not require level and always prints.


===========================================================================*/
PROCEDURE logmsg(x_Module IN VARCHAR2, x_Text IN VARCHAR2, x_Level IN NUMBER DEFAULT C_STMT_LEVEL);


/*===========================================================================
  PROCEDURE NAME:	log

  DESCRIPTION:   	This procedure prints string followed by a boolean
			Does not require level and always prints.


===========================================================================*/
PROCEDURE log(x_Module IN VARCHAR2, x_Text IN VARCHAR2, x_Value IN VARCHAR2 := NULL, x_Level IN NUMBER DEFAULT C_STMT_LEVEL);


/*===========================================================================
  PROCEDURE NAME:	log

  DESCRIPTION:   	This procedure prints string followed by a number


===========================================================================*/
PROCEDURE log(x_Module IN VARCHAR2, x_Text IN VARCHAR2, x_Value IN NUMBER, x_Level IN NUMBER DEFAULT C_STMT_LEVEL);


/*===========================================================================
  PROCEDURE NAME:	log

  DESCRIPTION:   	This procedure prints string followed by a date


===========================================================================*/
PROCEDURE log(x_Module IN VARCHAR2, x_Text IN VARCHAR2, x_Value IN DATE, x_Level IN NUMBER DEFAULT C_STMT_LEVEL, x_Mask IN VARCHAR2 := 'MM/DD/YYYY HH:MI:SS PM');


/*===========================================================================
  PROCEDURE NAME:	log

  DESCRIPTION:   	This procedure prints string followed by a boolean

===========================================================================*/
PROCEDURE log(x_Module IN VARCHAR2, x_Text IN VARCHAR2, x_Value IN BOOLEAN, x_Level IN NUMBER DEFAULT C_STMT_LEVEL);

/*===========================================================================

  PROCEDURE NAME:	push

  DESCRIPTION:   	This procedure pushes a call onto the call stack


===========================================================================*/
PROCEDURE push(x_Module IN VARCHAR2);

PROCEDURE push(x_Module IN VARCHAR2, x_name in varchar2);



/*===========================================================================
  PROCEDURE NAME:	pop

  DESCRIPTION:   	This procedure pops a call off the call stack

  PARAMETERS:		x_Level		IN	NUMBER
			x_Context	IN	VARCHAR2

===========================================================================*/
PROCEDURE pop(x_Module IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  FUNCTION NAME:	make_space

  DESCRIPTION:   	This function returns the indent space for output
			depending on the level of the stack


===========================================================================*/
FUNCTION make_space(x_Mode IN NUMBER := 0) RETURN VARCHAR2;


/*===========================================================================
  PROCEDURE NAME:	start_wsh_debugger

  DESCRIPTION	This procedure is used to turn on the Shipping Debugger by other
                products

============================================================================*/
--FUNCTION start_wsh_debugger( x_Level IN NUMBER DEFAULT C_STMT_LEVEL)
--RETURN VARCHAR2 ;
PROCEDURE start_debugger
	    (
	      x_file_name OUT NOCOPY  VARCHAR2,
	      x_return_status OUT NOCOPY  VARCHAR2,
	      x_msg_count     OUT NOCOPY  NUMBER,
	      x_msg_data      OUT NOCOPY  VARCHAR2
	      );

/*===========================================================================
  PROCEDURE NAME:	stop_wsh_debugger

  DESCRIPTION	This procedure is used to turn off the Shipping Debugger by other
                products
============================================================================*/

PROCEDURE stop_debugger;

/*===========================================================================
  FUNCTION NAME:	is_debug_enabled

  DESCRIPTION:   	This function returns TRUE if debug is
			enabled.

===========================================================================*/

FUNCTION is_debug_enabled RETURN BOOLEAN;

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/

PROCEDURE Start_Other_App_Debug(
	p_application		IN VARCHAR2,
	x_debug_directory	OUT NOCOPY  VARCHAR2,
	x_debug_file		OUT NOCOPY  VARCHAR2,
	x_return_status		OUT NOCOPY  VARCHAR2);

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/

PROCEDURE Stop_Other_App_Debug(
	p_application		IN VARCHAR2,
	x_return_status		OUT NOCOPY  VARCHAR2);

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/

/*===========================================================================
  PROCEDURE NAME:	get_debug_levels

  DESCRIPTION:   	This procedure retrieves debug levels for the debug value
			passed.

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/

PROCEDURE get_debug_levels (x_Topper IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:	start_debug

  DESCRIPTION:   	This procedure initializes the debug session.

  PARAMETERS:

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE start_debug(file_number VARCHAR2 DEFAULT null);


/*===========================================================================
  PROCEDURE NAME:	stop_debug

  DESCRIPTION:   	This procedure closes the debug session.

  PARAMETERS:

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE stop_debug;


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a string


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a number


===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a date


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE  dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN DATE,
               x_Mask IN VARCHAR2 := 'DD-MON-YYYY HH:MI:SS PM');


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a boolean

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE  dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN boolean);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a number.
			Does not require level and always prints.

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       dlog

  DESCRIPTION:          This procedure prints string followed by a string
                        Does not require level and always prints.


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a date
			Does not require level and always prints.


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN DATE,
               x_Mask IN VARCHAR2 := 'DD-MON-YYYY HH:MI:SS PM');


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a boolean
			Does not require level and always prints.


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN boolean);



/*===========================================================================
  PROCEDURE NAME: dlogd

  DESCRIPTION:    This procedure prints string followed by an index,
                  followed by a string, and a date value.

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE  dlogd(x_Level IN NUMBER, x_Text1 IN VARCHAR2 := NULL, x_Index IN NUMBER := NULL,  x_Text2
 IN VARCHAR2 := NULL, x_Value IN DATE := NULL);

/*===========================================================================
 PROCEDURE NAME: dlogn

  DESCRIPTION:    This procedure prints string followed by an index,
                  followed by a string, and a number value.

  PARAMETERS:

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE  dlogn(x_Level IN NUMBER, x_Text1 IN VARCHAR2 := NULL, x_Index IN NUMBER := NULL, x_Text2
 IN VARCHAR2 := NULL, x_Value IN NUMBER := NULL);
/*===========================================================================
  PROCEDURE NAME:	dpush

  DESCRIPTION:   	This procedure pushes a call onto the call stack


===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:	dpush

  DESCRIPTION:   	This procedure pushes a call onto the call stack


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dpush(x_Level IN NUMBER, x_Name IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	dpush

  DESCRIPTION:   	This procedure pushes a call onto the call stack


===========================================================================*/
--PROCEDURE dpush(x_Name IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	dpop

  DESCRIPTION:   	This procedure pops a call off the call stack

  PARAMETERS:		x_Level		IN	NUMBER
			x_Context	IN	VARCHAR2

===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE dpop(x_Level IN NUMBER, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dpop

  DESCRIPTION:   	This procedure pops a call off the call stack

===========================================================================*/
--PROCEDURE dpop(x_Context IN VARCHAR2 := NULL);

/*===========================================================================
  PROCEDURE NAME:	print_debug_stuff


===========================================================================*/
/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE print_debug_stuff;


/*===========================================================================
  PROCEDURE NAME:	debug

  DESCRIPTION:   	This procedure prints out a debug message
			that has been passed to it if debug has
			been enabled.


===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE debug (x_message IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	enable_debug

  DESCRIPTION:   	This procedure enables debug output.


===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE enable_debug;


/*===========================================================================
  PROCEDURE NAME:	disable_debug

  DESCRIPTION:   	This procedure disables debug output.


===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE disable_debug;


/*===========================================================================
  FUNCTION NAME:	debug_enabled

  DESCRIPTION:   	This function returns TRUE if debug is
			enabled.

===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
FUNCTION debug_enabled RETURN BOOLEAN;




/*=========================================================================

  FUNCTION NAME:       get_lookup_meaning

  DESCRIPTION	This function will return the meaning based on
                lookup type and lookup code meaning based on
                This is used for error tokens
===========================================================================*/

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
FUNCTION get_lookup_meaning (x_lookup_type  IN VARCHAR2,
                             x_lookup_code  IN VARCHAR2)
RETURN VARCHAR2;

/********* The APIs below are maintained only for backward compatibility.
These should not be called directly from any APIs. ****************/
PROCEDURE append_other_dbg_file( p_source_file_directory     IN VARCHAR2,
  				 p_source_file_name          IN VARCHAR2,
  				 p_target_file_directory     IN VARCHAR2,
  				 p_target_file_name          IN VARCHAR2,
  				 x_return_status             OUT NOCOPY  BOOLEAN);

/********* The API set_debug_count is created for bug 6215206 for ITM Async process.
This api should not be called directly from any other APIs. ****************/
PROCEDURE set_debug_count;
END WSH_DEBUG_SV;

/

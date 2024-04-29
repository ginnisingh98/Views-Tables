--------------------------------------------------------
--  DDL for Package RLM_CORE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_CORE_SV" AUTHID CURRENT_USER as
/* $Header: RLMCORES.pls 120.2 2006/04/17 18:31:27 rvishnuv noship $ */
/*===========================================================================
  PACKAGE NAME:		rlm_core_sv

  DESCRIPTION:		Contains common routines required by Release
			Management.


  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		JHAULUND

  PROCEDURE/FUNCTIONS:	debug
			enable_debug
		        disable_debug
			debug_enabled
			get_debug_levels
			print_debug_stuff

===========================================================================*/
TYPE t_dynamic_tab IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
TYPE t_Cursor_ref IS REF CURSOR;


TYPE t_DebugLevels IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE t_TimeType IS RECORD(
  Marker	VARCHAR2(100),
  Time		NUMBER,
  CallCount	NUMBER,
  TotalTime	NUMBER);

TYPE t_TimeStack IS TABLE OF t_TimeType
  INDEX BY BINARY_INTEGER;

TYPE t_CallStack IS TABLE OF VARCHAR2(40)
  INDEX BY BINARY_INTEGER;

TYPE t_NumberTable      IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

g_TimeStack     t_TimeStack;
g_CallStack	t_CallStack;
g_DebugLevels 	t_DebugLevels;
g_MaxLevels	NUMBER := 31;
g_Debug		BOOLEAN := FALSE;
g_DebugAll	BOOLEAN := FALSE;
g_FileHandle	utl_file.file_type;
C_FILE		NUMBER := 1;
C_PIPE		NUMBER := 2;
C_SCREEN	NUMBER := 4;
C_SQLTRACE	NUMBER := 8;
C_DELIMITER	VARCHAR2(5) := ' ==> ';
C_FILLER	VARCHAR2(1) := '-';
C_DEBUG_PIPE	VARCHAR2(30) := 'RLM_DEBUG_PIPE';
C_PIPE_SIZE	NUMBER := 1000000;
C_DEBUG_PROFILE	VARCHAR2(30) := 'RLM_DEBUG_MODE';
C_PREFIX	VARCHAR2(15) := 'rlmdebug';
E_PIPE_FAILURE	NUMBER := -20000;

C_LEVEL1	NUMBER := 16;
C_LEVEL2	NUMBER := 32;
C_LEVEL3	NUMBER := 64;
C_LEVEL4	NUMBER := 128;
C_LEVEL5	NUMBER := 256;
C_LEVEL6	NUMBER := 512;
C_LEVEL7	NUMBER := 1024;
C_LEVEL8	NUMBER := 2048;
C_LEVEL9	NUMBER := 4096;
C_LEVEL10	NUMBER := 8192;
C_LEVEL11	NUMBER := 16384;
C_LEVEL12	NUMBER := 32768;
C_LEVEL13	NUMBER := 65536;
C_LEVEL14	NUMBER := 131072;
C_LEVEL15	NUMBER := 262144;
C_LEVEL16	NUMBER := 524288;
C_LEVEL17	NUMBER := 1048576;
C_LEVEL18	NUMBER := 2097152;
C_LEVEL19	NUMBER := 4194304;
C_LEVEL20	NUMBER := 8388608;
C_LEVEL21	NUMBER := 16777216;
C_LEVEL22	NUMBER := 33554432;
C_LEVEL23	NUMBER := 67108864;
C_LEVEL24	NUMBER := 134217728;
C_LEVEL25	NUMBER := 268435456;
C_LEVEL26	NUMBER := 536870912;

  -- all non-core attributes are disabled
  k_no_key                     VARCHAR2(1)  := '0';

  -- deafault match_key: all non-core attributes enabled
  k_default_match_key          VARCHAR2(80)  := 'ABCDEFGH';

 TYPE t_Match_rec IS RECORD(
    cust_production_line      VARCHAR2(1) := 'N',
    customer_dock_code        VARCHAR2(1) := 'N',
    request_date              VARCHAR2(1) := 'N',
    schedule_date             VARCHAR2(1) := 'N',
    cust_po_number            VARCHAR2(1) := 'N',
    customer_item_revision    VARCHAR2(1) := 'N',
    customer_job              VARCHAR2(1) := 'N',
    cust_model_serial_number  VARCHAR2(1) := 'N',
    cust_production_seq_num   VARCHAR2(1) := 'N',
    industry_attribute1       VARCHAR2(1) := 'N',
    industry_attribute2       VARCHAR2(1) := 'N',
    industry_attribute3       VARCHAR2(1) := 'N',
    industry_attribute4       VARCHAR2(1) := 'N',
    industry_attribute5       VARCHAR2(1) := 'N',
    industry_attribute6       VARCHAR2(1) := 'N',
    industry_attribute7       VARCHAR2(1) := 'N',
    industry_attribute8       VARCHAR2(1) := 'N',
    industry_attribute9       VARCHAR2(1) := 'N',
    industry_attribute10      VARCHAR2(1) := 'N',
    industry_attribute11      VARCHAR2(1) := 'N',
    industry_attribute12      VARCHAR2(1) := 'N',
    industry_attribute13      VARCHAR2(1) := 'N',
    industry_attribute14      VARCHAR2(1) := 'N',
    industry_attribute15      VARCHAR2(1) := 'N',
    attribute1                VARCHAR2(1) := 'N',
    attribute2                VARCHAR2(1) := 'N',
    attribute3                VARCHAR2(1) := 'N',
    attribute4                VARCHAR2(1) := 'N',
    attribute5                VARCHAR2(1) := 'N',
    attribute6                VARCHAR2(1) := 'N',
    attribute7                VARCHAR2(1) := 'N',
    attribute8                VARCHAR2(1) := 'N',
    attribute9                VARCHAR2(1) := 'N',
    attribute10               VARCHAR2(1) := 'N',
    attribute11               VARCHAR2(1) := 'N',
    attribute12               VARCHAR2(1) := 'N',
    attribute13               VARCHAR2(1) := 'N',
    attribute14               VARCHAR2(1) := 'N',
    attribute15               VARCHAR2(1) := 'N'
  );


/*===========================================================================
  CONSTANTS  : Process Statuses

  DESCRIPTION:   	The following constants are created for process Status
			throughout RLMDSP

  CHANGE HISTORY:	Ashwin Kulkarni  Created       3/5/99
===========================================================================*/

k_PS_AVAILABLE          NUMBER := 2;
k_PS_IN_PROCESS         NUMBER := 3;
k_PS_ERROR              NUMBER := 4;
k_PS_PROCESSED          NUMBER := 5;
k_PS_FROZEN_FIRM        NUMBER := 6;
k_PS_PARTIAL_PROCESSED  NUMBER := 7;

k_PROC_ERROR      NUMBER := 0;
k_PROC_SUCCESS    NUMBER := 1;


/*===========================================================================
  PROCEDURE NAME:	get_debug_levels

  DESCRIPTION:   	This procedure retrieves debug levels for the debug value
			passed.

  PARAMETERS:		x_Topper	IN 	NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE get_debug_levels (x_Topper IN NUMBER);


/*===========================================================================
  FUNCTION NAME:	level_defined

  DESCRIPTION:   	This function true if the passed level is defined.

  PARAMETERS:		x_Level	IN 	NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
FUNCTION level_defined (x_Level IN NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	start_time

  DESCRIPTION:   	This procedure puts a time on the stack.

  PARAMETERS:		x_Level		IN	NUMBER
			x_Marker	IN 	VARCHAR2
			x_Context	IN	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE start_time (x_Level IN NUMBER, x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	start_time

  DESCRIPTION:   	This procedure puts a time on the stack.

  PARAMETERS:		x_Marker	IN 	VARCHAR2
			x_Context	IN	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE start_time (x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	stop_time

  DESCRIPTION:   	This procedure shows time elapsed for the passed marker value

  PARAMETERS:		x_Level		IN	NUMBER
			x_Marker	IN 	NUMBER
			x_Context	IN	VARCHAR2 := NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE stop_time (x_Level IN NUMBER, x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	stop_time

  DESCRIPTION:   	This procedure shows time elapsed for the passed marker value

  PARAMETERS:		x_Marker	IN 	NUMBER
			x_Context	IN	VARCHAR2 := NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE stop_time (x_Marker IN VARCHAR2, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	tstart

  DESCRIPTION:   	This procedure stores start time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tstart(x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstart

  DESCRIPTION:   	This procedure stores start time for a function

  PARAMETERS:		x_Level  IN	NUMBER
			x_Marker IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tstart(x_Level IN NUMBER, x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstop

  DESCRIPTION:   	This procedure stores elapsed time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tstop(x_Marker IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tstop

  DESCRIPTION:   	This procedure stores elapsed time for a function

  PARAMETERS:		x_Level  IN	NUMBER
			x_Marker	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tstop(x_Level IN NUMBER, x_Marker IN VARCHAR2);


/*===========================================================================
  FUNCTION NAME:	tprint

  DESCRIPTION:   	This function prints elapsed time for a function

  PARAMETERS:		x_Marker	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
FUNCTION tprint(x_Marker IN VARCHAR2) RETURN VARCHAR2;


/*===========================================================================
  PROCEDURE NAME:	tdump

  DESCRIPTION:   	This procedure dumps stored times for all functions.

  PARAMETERS:		x_Marker	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tdump(x_Context IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	tdump

  DESCRIPTION:   	This procedure dumps stored times for all functions.

  PARAMETERS:		x_Level IN	NUMBER
			x_Context	IN 	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		2/11/99
===========================================================================*/
PROCEDURE tdump(x_Level IN NUMBER, x_Context IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	start_debug

  DESCRIPTION:   	This procedure initializes the debug session.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE start_debug(file_number VARCHAR2 DEFAULT null);


/*===========================================================================
  PROCEDURE NAME:	stop_debug

  DESCRIPTION:   	This procedure closes the debug session.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE stop_debug;

/*===========================================================================
  PROCEDURE NAME:	write_output

  DESCRIPTION:   	This procedure writes output to the requested areas

  PARAMETERS:		x_Line		IN	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE write_output(x_Line IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a string

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a number

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a date

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN DATE,
               x_Mask IN VARCHAR2 := 'DD-MON-YYYY HH:MI:SS PM');


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a boolean

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Level IN NUMBER, x_Text IN VARCHAR2, x_Value IN boolean);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a number.
			Does not require level and always prints.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a string
			Does not require level and always prints.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a date
			Does not require level and always prints.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN DATE,
               x_Mask IN VARCHAR2 := 'DD-MON-YYYY HH:MI:SS PM');


/*===========================================================================
  PROCEDURE NAME:	dlog

  DESCRIPTION:   	This procedure prints string followed by a boolean
			Does not require level and always prints.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dlog(x_Text IN VARCHAR2, x_Value IN boolean);


/*===========================================================================
  PROCEDURE NAME: dlogd

  DESCRIPTION:    This procedure prints string followed by an index,
                  followed by a string, and a date value.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Abhijit Mitra Created     7/17/98
===========================================================================*/
PROCEDURE  dlogd(x_Level IN NUMBER, x_Text1 IN VARCHAR2 := NULL, x_Index IN NUMBER := NULL,  x_Text2
 IN VARCHAR2 := NULL, x_Value IN DATE := NULL);

/*===========================================================================
 PROCEDURE NAME: dlogn

  DESCRIPTION:    This procedure prints string followed by an index,
                  followed by a string, and a number value.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Abhijit Mitra Created     7/17/98
===========================================================================*/
PROCEDURE  dlogn(x_Level IN NUMBER, x_Text1 IN VARCHAR2 := NULL, x_Index IN NUMBER := NULL, x_Text2
 IN VARCHAR2 := NULL, x_Value IN NUMBER := NULL);

/*===========================================================================

  PROCEDURE NAME:	dpush

  DESCRIPTION:   	This procedure pushes a call onto the call stack

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dpush(x_Level IN NUMBER, x_Name IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	dpush

  DESCRIPTION:   	This procedure pushes a call onto the call stack

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dpush(x_Name IN VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	dpop

  DESCRIPTION:   	This procedure pops a call off the call stack

  PARAMETERS:		x_Level		IN	NUMBER
			x_Context	IN	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dpop(x_Level IN NUMBER, x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  PROCEDURE NAME:	dpop

  DESCRIPTION:   	This procedure pops a call off the call stack

  PARAMETERS:		x_Context	IN	VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE dpop(x_Context IN VARCHAR2 := NULL);


/*===========================================================================
  FUNCTION NAME:	make_space

  DESCRIPTION:   	This function returns the indent space for output
			depending on the level of the stack

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
FUNCTION make_space(x_Mode IN NUMBER := 0) RETURN VARCHAR2;


/*===========================================================================
  PROCEDURE NAME:	print_debug_stuff

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Jon Haulund	Created		7/25/97
===========================================================================*/
PROCEDURE print_debug_stuff;


/*===========================================================================
  PROCEDURE NAME:	debug

  DESCRIPTION:   	This procedure prints out a debug message
			that has been passed to it if debug has
			been enabled.

  PARAMETERS:		x_message	IN VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		10/26/96
===========================================================================*/

PROCEDURE debug (x_message IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	enable_debug

  DESCRIPTION:   	This procedure enables debug output.

  PARAMETERS

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		10/26/96
===========================================================================*/

PROCEDURE enable_debug;


/*===========================================================================
  PROCEDURE NAME:	disable_debug

  DESCRIPTION:   	This procedure disables debug output.

  PARAMETERS

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		10/26/96
===========================================================================*/

PROCEDURE disable_debug;


/*===========================================================================
  FUNCTION NAME:	debug_enabled

  DESCRIPTION:   	This function returns TRUE if debug is
			enabled.

  PARAMETERS

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		10/26/96
===========================================================================*/

FUNCTION debug_enabled RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	get_no_key

  DESCRIPTION	This is function returns k_no_key value.

  PARAMETERS

  DESIGN REFERENCES:	rlmdpdtu.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	rjupudy	10/28/98 created
============================================================================*/
FUNCTION get_no_key
RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:	get_default_key

  DESCRIPTION	This function returns k_default_match_key.

  PARAMETERS

  DESIGN REFERENCES:	rlmdpdtu.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	rjupudy	10/28/98 created
============================================================================*/
FUNCTION get_default_key
RETURN VARCHAR2;


/*=========================================================================

  FUNCTION NAME:       get_lookup_meaning

  DESCRIPTION	This function will return the meaning based on
                lookup type and lookup code meaning based on
                This is used for error tokens
===========================================================================*/

FUNCTION get_lookup_meaning (x_lookup_type  IN VARCHAR2,
                             x_lookup_code  IN VARCHAR2)
RETURN VARCHAR2;
/*===========================================================================

  PROCEDURE NAME:       populate_match_keys

  DESCRIPTION:          This procedure will populate the matching key values
                        in the match_key record in the group_rec

  PARAMETERS:           x_Group_rec IN t_Group_rec
                        x_ScheduleType IN VARCHAR2


  DESIGN REFERENCES:    RLADPHLD.rtf
                        RLADPRDD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 03/05/99
===========================================================================*/
PROCEDURE populate_match_keys(x_match_rec IN OUT NOCOPY t_match_rec,
                              x_match_key  IN VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:       SetSchedulePSError

  DESCRIPTION:          This procedure sets the process status  to Error
                        for both lines and header and called when 'WHEN OTHERS'
                        exception is raised.

  PARAMETERS:           x_header_id IN NUMBER


  DESIGN REFERENCES:    RLADPHLD.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created mnandell 03/05/99
===========================================================================*/
PROCEDURE SetSchedulePSError(x_header_id IN NUMBER,
                             x_sch_header_id IN NUMBER DEFAULT NULL);

/*=========================================================================

  FUNCTION NAME:       get_customer_name

  DESCRIPTION	This function will return the customer name based on
                customer_id This is used for error tokens
===========================================================================*/
FUNCTION get_customer_name (x_customer_id  IN NUMBER)
RETURN VARCHAR2;

/*=========================================================================

  FUNCTION NAME:       get_item_number

  DESCRIPTION	This function will return the item_number based on
                customer_item_id This is used for error tokens
===========================================================================*/
FUNCTION get_item_number (x_item_id  IN NUMBER)
RETURN VARCHAR2;

/*=========================================================================

  FUNCTION NAME:       get_ship_from

  DESCRIPTION	This function will return the ship_from org code  based on
                ship_from_org_id This is used for error tokens
===========================================================================*/
FUNCTION get_ship_from (x_ship_from_id  IN NUMBER)
RETURN VARCHAR2;

/*=========================================================================

  FUNCTION NAME:       get_ship_to

  DESCRIPTION	This function will return the ship to location code  based on
                ship_to_id This is used for error tokens
===========================================================================*/
FUNCTION get_ship_to (x_ship_to_id  IN NUMBER)
RETURN VARCHAR2;


/*=========================================================================

  FUNCTION NAME:       get_schedule_reference_num

  DESCRIPTION	This function will return the schedule_reference_num  based on
                header_id This is used for error tokens
===========================================================================*/
FUNCTION get_schedule_reference_num (x_header_id  IN NUMBER)
RETURN VARCHAR2;

/*=========================================================================

  FUNCTION NAME:       OpenDynamicCursor

  DESCRIPTION	This function opens a dynamic sql cursor with a USING clause
===========================================================================*/

PROCEDURE OpenDynamicCursor(p_cursor IN OUT NOCOPY t_Cursor_ref,
                            p_statement  IN VARCHAR2,
                            p_dynamic_tab IN t_dynamic_tab);



/*=======================================================================

FUNCTION NAME : GetDefaultOU

DESCRIPTION : This function is used in DSP, Purge Concurrent programs to
              specify a default value for the Operating Unit parameter

HISTORY:      rlanka     Created     03/15/2005  for R12 MOAC project
=========================================================================*/
FUNCTION GetDefaultOU RETURN VARCHAR2;



/*=======================================================================

FUNCTION NAME : GetDefaultOUId

DESCRIPTION : This function is used in reports conc. programs and XML
              inbound processing to specify a default value for
              the Operating Unit parameter.  This function is similar
              to the one defined above, except that this one returns
              the Operating Unit ID to the caller.

HISTORY:      rlanka     Created     03/15/2005  for R12 MOAC project
=========================================================================*/
FUNCTION GetDefaultOUId RETURN NUMBER;

/*=========================================================================

  FUNCTION NAME:       get_schedule_line_number

  DESCRIPTION	This function will return the schedule line number based on
                line_id. This is used for error tokens. (Bug 4297984)
===========================================================================*/
FUNCTION get_schedule_line_number(x_line_id IN NUMBER)
RETURN NUMBER;

/*=========================================================================

  FUNCTION NAME:       get_order_line_number

  DESCRIPTION	This function will return the order line number based on
                line_id. This is used for error tokens. (Bug 4297984)
===========================================================================*/
FUNCTION get_order_line_number(x_line_id IN NUMBER)
RETURN VARCHAR2;

/*=========================================================================

  FUNCTION NAME:       get_order_number

  DESCRIPTION	This function will return the order number based on
                header_id. This is used for error tokens. (Bug 4297984)
===========================================================================*/
FUNCTION get_order_number(x_header_id IN NUMBER)
RETURN NUMBER;

/*=========================================================================

  FUNCTION NAME:       get_proc_status_meaning

  DESCRIPTION  :       This function will return the Process Status Meaning
                       (Bug 4670512)
===========================================================================*/
FUNCTION get_proc_status_meaning (x_status IN NUMBER)
RETURN VARCHAR2;

END RLM_CORE_SV;
 

/

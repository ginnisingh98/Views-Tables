--------------------------------------------------------
--  DDL for Package WF_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: WFLOGPKS.pls 120.1.12000000.2 2007/07/02 21:21:24 vshanmug ship $ */
------------------------------------------------------------------------------
/*
**      wf_debug_flag - Global Variable to hold whether debug on or off
**      ** May not be used when moved to FND Logging **
*/

WF_DEBUG_FLAG  	 BOOLEAN DEFAULT FALSE;

/*
**	Level Global Variables - enables filtering of messages
*/
LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
LEVEL_ERROR      CONSTANT NUMBER  := 5;
LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
LEVEL_EVENT      CONSTANT NUMBER  := 3;
LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
LEVEL_STATEMENT  CONSTANT NUMBER  := 1;

/*
** Table of start time of log calls stored by the module name
*/
type wf_number_tab_t is table of number index by binary_integer;
g_start_times    wf_number_tab_t;

------------------------------------------------------------------------------
/*
** Init - Initialise the Logging global variables to do standalone testing.
**        This will do the same work as wf_log_pkg.wf_debug_flag.
** Change LOG_ENABLED to binary integer because JDBC doesn't support PL/SQL boolean.
** 0 means false, 1 means true
*/
procedure Init (
   LOG_ENABLED  in binary_integer default 0,
   LOG_FILENAME in varchar2 default NULL,
   LOG_LEVEL    in number   default 5,
   LOG_MODULE   in varchar2 default '%',
   FND_USER_ID  in number   default 0,
   FND_RESP_ID  in number   default -1,
   FND_APPL_ID  in number   default -1
);

------------------------------------------------------------------------------
/*
** SET_LEVEL - Change the PL/SQL Log Level
*/
procedure SET_LEVEL (
   LOG_LEVEL    in number   default 5
);
------------------------------------------------------------------------------
/*
** String - Procedure to output to screen log messages, only works if called
**	    from SQL*Plus and debug global variable set to TRUE
*/
procedure String (
  LOG_LEVEL	in number,
  MODULE	in varchar2,
  MESSAGE	in varchar2
);
------------------------------------------------------------------------------
/*
** Test - Function to verify if the logging is enabled for the given
**             Log Level
*/
function Test (
   LOG_LEVEL in number,
   MODULE    in varchar2
)
return boolean;


/*
** MESSAGE
**  Standalone :
**   Empty Implementation
**  Apps :
**   Wrapper to FND_LOG.MESSAGE
**   Writes a message to the log file if this level and module is enabled
**   This requires that the message was set previously with
**   WF_LOG_PKG.SET_NAME, WF_LOG_PKG.SET_TOKEN, etc.
**   The message is popped off the message dictionary stack, if POP_MESSAGE
**   is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
**   displayed to the user later.  If POP_MESSAGE isn't passed, the
**   message will not be popped off the stack, so it must be displayed
**   or explicitly cleared later on.
*/
procedure MESSAGE (
   LOG_LEVEL   in number,
   MODULE      in varchar2,
   POP_MESSAGE in boolean default null
);

/*
** SET_NAME
**  Standalone :
**   Empty Implementation
**  Apps :
**   Wrapper to FND_MESSAGE.SET_NAME
**   Sets the message name
*/
procedure SET_NAME(
   APPLICATION in varchar2,
   NAME        in varchar2
);

/*
** SET_TOKEN
**  Standalone :
**   Empty Implementation
**  Apps :
**   Wrapper to FND_MESSAGE.SET_TOKEN
**   Defines a message token with a value
*/
procedure SET_TOKEN (
   TOKEN     in varchar2,
   VALUE     in varchar2,
   TRANSLATE in boolean default false
);

------------------------------------------------------------------------------
/*
** String2 - Same as String procedure. This records the start time of the call
**           and prints the elapsed time when requested.
*/
procedure String2 (
  LOG_LEVEL     in number,
  MODULE        in varchar2,
  MESSAGE       in varchar2,
  STARTS        in boolean default true
);

end WF_LOG_PKG;

 

/

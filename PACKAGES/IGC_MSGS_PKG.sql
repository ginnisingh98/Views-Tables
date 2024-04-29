--------------------------------------------------------
--  DDL for Package IGC_MSGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_MSGS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCBMSGS.pls 120.3.12000000.1 2007/08/20 12:10:16 mbremkum ship $ */

-- --------------------------------------------------------------
-- Global declarations to be defined for other packages to
-- have access to.
-- --------------------------------------------------------------

-- --------------------------------------------------------------
-- TokNameArray contains names of all message tokens
-- --------------------------------------------------------------
TYPE g_TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

-- --------------------------------------------------------------
-- TokValArray contains values for all tokens
-- --------------------------------------------------------------
TYPE g_TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

-- --------------------------------------------------------------
-- Message Token Name
-- --------------------------------------------------------------
g_msg_tok_names         g_TokNameArray;

-- --------------------------------------------------------------
-- Message Token Value
-- --------------------------------------------------------------
g_msg_tok_val           g_TokValArray;

-- --------------------------------------------------------------
-- Number of tokens added into message.
-- --------------------------------------------------------------
g_no_msg_tokens    NUMBER := 0;

-- --------------------------------------------------------------
-- Debug global variables.
-- --------------------------------------------------------------
g_debug_mode       BOOLEAN := FALSE;

--
-- Procedure definitions for the package defined below.  These are

-- Procedure that adds the appropriate message to the Token array that will be added
-- to the error stack so that the user can see any messages generated from the process
-- being run.
--
-- Parameters :
--
-- p_tokname        ==> Token name of the error message
-- p_tokval         ==> Value of the token to be added.
--

PROCEDURE message_token(
   p_tokname           IN VARCHAR2,
   p_tokval            IN VARCHAR2
);


--
-- Procedure that sets/adds the appropriate message to the error stack so that the
-- user can see any messages generated from the process being run.
--
-- Parameters :
--
-- p_appname        ==> Application name used for message
-- p_msgname        ==> Message to be added onto message stack
--

PROCEDURE add_message(
   p_appname           IN VARCHAR2,
   p_msgname           IN VARCHAR2
);

--
-- Procedure that outputs debug message to debug file that has been initialized and
-- created.
--
-- NOTE : Initialize_Debug procedure is not public since the Put_Debug_Msg calls the
--        Initialize_Debug procedure if things have not previously been setup.  All
--        global references should be done within the one procedure not from outside
--        callers.
--
-- Parameters :
--
-- p_debug_message     ==> Message to be output to debug file.
-- p_profile_log_name  ==> Profile option used to get directory location for debug
-- p_prod              ==> Product string (IGC, GMS, etc.)
-- p_sub_comp          ==> Sub Component name to the product (CC, CBC, etc.)
-- p_filename_val      ==> Filename to be used for debug.  If null then name is built here.
-- x_Return_Status     ==> Status of procedure returned to caller
--

PROCEDURE Put_Debug_Msg (
   p_debug_message        IN VARCHAR2,
   p_profile_log_name     IN VARCHAR2,
   p_prod                 IN VARCHAR2,
   p_sub_comp             IN VARCHAR2,
   p_filename_val         IN VARCHAR2 := NULL,
   x_Return_Status       OUT NOCOPY VARCHAR2
);


END IGC_MSGS_PKG;


 

/

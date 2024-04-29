--------------------------------------------------------
--  DDL for Package BSC_UPDATE_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_LOG" AUTHID CURRENT_USER AS
/* $Header: BSCDLOGS.pls 115.5 2003/01/14 19:47:49 meastmon ship $ */


LOG NUMBER := 0;  -- Log file
OUTPUT NUMBER := 1; -- Output file. Only make sense in APPS environment
                    -- In Personal, Loader always write in the log file.

--
-- Procedures and Fuctions
--

/*===========================================================================+
|
|   Name:          Init_Log_File
|
|   Description:   This function creates the log file. Additionally,
|   		   write the standard header to the log file.
|
|	           The log file directory must be in the variable
|		   UTL_FILE_DIR of INIT table.
|
|		   Initialize package variables:
|		   g_log_file_name 	- Log file name
|		   g_log_file_dir 	- Lof file directory.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE.
|
|   Notes:
|
+============================================================================*/
FUNCTION Init_Log_File (
	x_Log_File_Name IN VARCHAR2
        ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Log_File_Dir
|
|   Description:   This function returns the log file directory
|
|   Notes:
|
+============================================================================*/
FUNCTION Log_File_Dir RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Log_File_Name
|
|   Description:   This function returns the log file name
|
|   Notes:
|
+============================================================================*/
FUNCTION Log_File_Name RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Write_Line_Log
|
|   Description:   This procedure write the given string into the log file
|
|		   If the log file is not initialized then this procedure
|		   doesn't do anything. This is not an error.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Write_Line_Log (
	x_line IN VARCHAR2,
        x_which IN NUMBER
	);


/*===========================================================================+
|
|   Name:          Write_Errors_To_Log
|
|   Description:   This procedure writes the messages that are in
|                  BSC_MESSAGE_LOGS table corresponding to the current session
|		   id, into the log file.
|
|		   If the log file is not initialized then this procedure
|		   doesn't do anything. This is not an error.
|
|   Notes:
|
+============================================================================*/
PROCEDURE Write_Errors_To_Log;


END BSC_UPDATE_LOG;

 

/

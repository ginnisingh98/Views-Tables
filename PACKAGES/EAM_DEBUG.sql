--------------------------------------------------------
--  DDL for Package EAM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DEBUG" AUTHID CURRENT_USER AS
/* $Header: EAMDBGJS.pls 115.4 2002/11/18 18:17:23 aan ship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   -- Debug Levels

   DEBUG_LEVEL_EXCEPTION CONSTANT NUMBER := -1;	-- This debug level will be used for very important message reporting
   DEBUG_LEVEL_NONE      CONSTANT NUMBER :=  0;
   DEBUG_LEVEL_BASIC     CONSTANT NUMBER :=  1;
   DEBUG_LEVEL_TIMING    CONSTANT NUMBER :=  2;

   TYPE char255tabtype IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

   -- Public variables for this package

   debug_flag      	     BOOLEAN := FALSE;
   debug_level               NUMBER  := DEBUG_LEVEL_NONE;
   number_of_debug_messages  BINARY_INTEGER := 0;

   debug_message             char255tabtype;

-- -------------------------------------------

   /* Tsaifee : Modifications for handling processes, user locks, etc. */

	G_TimeOut	Number  := 0;
	G_CommitMode	Boolean := FALSE;
	G_LockMode	Number  := 6;

   -- Modified G_process default from PLSQL to IGNORE
   -- so that forms that call Write_File with out calling
   -- set_process do not have to be modified to call set_process
   -- There are large number of forms that call API's that are using
   -- Write_File, We felt it was better to change the PA_DEBUG API
   -- instead of changing all the forms. (changes made by Pkoganti
   -- after consulting Taheri and Selva).

	G_Process	Varchar2(10) := 'IGNORE';
	G_WriteFile	Varchar2(10) := 'LOG';
	G_WriteFileID	Number	     := FND_FILE.LOG;

   	TYPE char80tabtype IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

	G_Err_Stack	Varchar2(2000);
	G_Err_Stack_Tbl	char80tabtype;
	G_Err_Ind	Binary_Integer := 0;
	G_Err_Stage	Varchar2(650);
	G_Err_Code	Number;

-- -------------------------------------------
-- 29-NOV-00, jwhite:

    -- Added functions and procedures to EXTEND PA_DEBUG functionality.
    --
    -- The subroutines require the following globals:

    -- 1. G_Function_Stack holds the name of the called functions in a stack format.
    -- 2. G_Counter is used to mark the current location in the function stack.
    -- 3. G_Space is used to provide indentation in the stack of function calls

       G_Function_Stack               PA_PLSQL_DATATYPES.Char50TabTyp;
       G_Function_Counter             NUMBER := 0;
       G_Space                        VARCHAR2(200);

-- -------------------------------------------

   PROCEDURE initialize;
   PROCEDURE enable_debug;
   PROCEDURE enable_debug (x_debug_level IN NUMBER);
   PROCEDURE disable_debug;
   PROCEDURE set_debug_level (x_debug_level IN NUMBER);
   PROCEDURE debug (x_debug_message IN VARCHAR2);
   PROCEDURE debug (x_debug_message IN VARCHAR2, x_debug_level IN NUMBER);
   PROCEDURE get_message(x_message_number IN NUMBER,
			 x_debug_message OUT NOCOPY VARCHAR2);
   FUNCTION no_of_debug_messages RETURN NUMBER;


-- -------------------------------------------

   /* Tsaifee : APIs for handling processes, user locks, etc. */

   /* Set_User_Lock_Mode :
	x_Lock_Mode	Lock modes as defined in APPs dev guide.
			6 - Exclusive.
	x_Commit_Mode	Rls lock on Commit
			FALSE - Do not rls on commit
	x_TimeOut	Seconds before timeout.
*/
	PROCEDURE Set_User_Lock_Mode
			( 	x_Lock_Mode	IN	NUMBER  DEFAULT 6,
				x_Commit_Mode	IN	BOOLEAN DEFAULT FALSE,
				x_TimeOut	IN	NUMBER  DEFAULT 0 );

	Function Acquire_User_Lock
			(	x_Lock_Name	IN	VARCHAR2,
				x_Lock_Mode	IN	NUMBER,
				x_Commit_Mode	IN	BOOLEAN,
				x_TimeOut	IN	NUMBER )
			Return NUMBER;

	Function Acquire_User_Lock
			(	x_Lock_Name	IN	VARCHAR2 )
			Return NUMBER;

	Function Release_User_Lock (	x_Lock_Name	IN	VARCHAR2 )
			Return NUMBER;

/* Set_Process :
	x_Process	Type of Process
			'PLSQL' - PLSQL conc process to use FND_FILE APIs
			'SQL'	- SQL execution to use dbms_output APIs
			'REPORT'- Oracle Report execution to use PA_DEBUG buffer
	x_Write_File	File to write to for PLSQL process only.
			'LOG' 	- Log file
			'OUT'	- Out file
	x_Debug_Mode	Set the debug mode for the session
			'Y'	- Set G_DebugMode Y
			'N'	- Set G_DebugMode N

*/
	Procedure Set_Process (	x_Process	IN	VARCHAR2 DEFAULT 'PLSQL',
				x_Write_File	IN	VARCHAR2 DEFAULT 'LOG',
				x_Debug_Mode	IN	VARCHAR2 DEFAULT 'N' );
/* Write_File :
	x_Write_File	File to write to for PLSQL process only, as above
	x_Msg		String to write.
	x_Write_Mode	Mandatory write or use debug flag
			0 	- Use G_DebugMode to write.
			1	- Mandatory write.
*/

	Procedure Write_File (	x_Write_File	IN	VARCHAR2,
				x_Msg		IN	VARCHAR2,
				x_Write_Mode	IN	NUMBER 	DEFAULT 0);

	Procedure Write_File (	x_Msg 		IN	VARCHAR2,
				x_Write_Mode	IN	NUMBER 	DEFAULT 0) ;

	Procedure Init_Err_Stack (	x_Stack	IN	VARCHAR2 );

	Procedure Set_Err_Stack (	x_Stack	IN	VARCHAR2 );

	Procedure Reset_Err_Stack;

	PROCEDURE raise_error( 	x_Msg_Num    IN NUMBER,
       		               	x_Msg        IN VARCHAR2 ,
       		               	x_TokenName1 IN VARCHAR2 ,
                      		x_Token1     IN VARCHAR2 ,
                      		x_TokenName2 IN VARCHAR2 ,
                      		x_Token2     IN VARCHAR2 ,
                      		x_TokenName3 IN VARCHAR2 ,
                      		x_Token3     IN VARCHAR2 );

	PROCEDURE raise_error( 	x_Msg_Num    IN NUMBER,
       		               	x_Msg        IN VARCHAR2 ,
       		               	x_TokenName1 IN VARCHAR2 ,
                      		x_Token1     IN VARCHAR2 ,
                      		x_TokenName2 IN VARCHAR2 ,
                      		x_Token2     IN VARCHAR2 );

	PROCEDURE raise_error( 	x_Msg_Num    IN NUMBER,
       		               	x_Msg        IN VARCHAR2,
       		               	x_TokenName1 IN VARCHAR2,
                      		x_Token1     IN VARCHAR2 );

	PROCEDURE raise_error( 	x_Msg_Num    IN NUMBER,
       		               	x_Msg        IN VARCHAR2 );

-- -------------------------------------------
-- 29-NOV-00, jwhite:
-- 07-DEC-00, jwhite: Added p_msg_options.
-- 08-DEC-00, jwhite: Added p_write_file

    -- Added functions and procedures to EXTEND eam_debug functionality.
    --

    -- Procedure log_message
       -- Displays a message using the current function set by the
       -- procedure set_curr_function
       -- in addition to that, it sends the write mode
       -- write mode: 0 print in debug mode
       --             1 print always
       -- p_msg_options provides formatting options.
       -- p_write_file values: LOG, OUT.


       PROCEDURE log_message(p_message IN VARCHAR2
                            , p_write_mode  IN NUMBER     DEFAULT 0
                            , p_msg_options IN VARCHAR2   DEFAULT 'PLAIN'
                            , p_write_file  IN VARCHAR2   DEFAULT 'LOG'
                             );

    -- Procedure set_curr_function
       -- Sets the current function name passed in and sets the process and stack
       -- information as well.
       --
       -- ALWAYS call this at the beginning of each procedure.

       PROCEDURE set_curr_function(p_function      IN   VARCHAR2
                                   , p_process	   IN	VARCHAR2 DEFAULT 'PLSQL'
				   , p_write_file  IN	VARCHAR2 DEFAULT 'LOG'
				   , p_debug_mode  IN	VARCHAR2 DEFAULT 'N'
                                   );

    -- Procedure reset_curr_function
       -- Resets the current function name and also resets the stack
       -- information.
       --
       -- ALWAYS call this at the end of each procedure.

       PROCEDURE reset_curr_function;

-- -------------------------------------------
/* Ewee : Procedure for handling logging messages to FND_LOG_MESSAGES table */

/* Write_Log :
	x_Module	Module which writes message to FND_LOG_MESSAGES
	x_Msg		String to write
	x_Log_Level	Scope of log message
*/

	Procedure Write_Log (	x_Module	IN	VARCHAR2,
				x_Msg		IN	VARCHAR2,
				x_Log_Level	IN	NUMBER DEFAULT 6);

-- -------------------------------------------


END eam_debug;

 

/

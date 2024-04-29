--------------------------------------------------------
--  DDL for Package Body EAM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DEBUG" AS
/* $Header: EAMDBGJB.pls 120.1 2005/06/30 01:56:40 pkathoti noship $ */
/* Copied from pa_DEBUG */

   -- Initialize PROCEDURE

   PROCEDURE initialize IS
   BEGIN
      NULL;

   EXCEPTION
    WHEN  OTHERS  THEN
      RAISE;
   END initialize;

   PROCEDURE enable_debug IS
   BEGIN
     debug_flag := TRUE;
     debug_level:= DEBUG_LEVEL_BASIC;
   END enable_debug;

   PROCEDURE enable_debug (x_debug_level IN NUMBER) IS
   BEGIN
     debug_flag := TRUE;
     debug_level := x_debug_level;
   END enable_debug;

   PROCEDURE disable_debug IS
   BEGIN
     debug_flag := FALSE;
   END disable_debug;

   PROCEDURE set_debug_level (x_debug_level IN NUMBER) IS
   BEGIN
     debug_level := x_debug_level;
   END set_debug_level;

   PROCEDURE debug (x_debug_message IN VARCHAR2) IS
    rest varchar2(32767);
   BEGIN
       IF (debug_flag AND x_debug_message IS NOT NULL) THEN
	 IF ( debug_level = DEBUG_LEVEL_TIMING) THEN
	    rest := to_char(sysdate, 'DD-MON-YYYY HH:MI:SS ') || x_debug_message;
	 ELSE
	    rest := x_debug_message;
	 END IF;
	 LOOP
	   IF (rest IS NULL) THEN
	      exit;
	   ELSE
              number_of_debug_messages := number_of_debug_messages + 1;
              debug_message(number_of_debug_messages) := substrb(rest,1,255);
	      rest := substrb(rest, 256);
	   END IF; -- IF (rest IS NULL)
	 END LOOP;
       END IF; -- IF (debug_flag)
   END debug;

   PROCEDURE debug (x_debug_message IN VARCHAR2, x_debug_level IN NUMBER) IS
    old_debug_flag BOOLEAN;
   BEGIN
      IF ( debug_level >= x_debug_level ) THEN
         IF ( x_debug_level = DEBUG_LEVEL_EXCEPTION ) THEN
           old_debug_flag := debug_flag;
           debug_flag     := TRUE;
           debug(x_debug_message);
           debug_flag     := old_debug_flag;
         ELSE
           debug(x_debug_message);
         END IF;
      END IF;
   END debug;

   PROCEDURE get_message(x_message_number IN NUMBER,
			 x_debug_message OUT NOCOPY VARCHAR2) IS
   BEGIN
      IF (x_message_number > 0 ) THEN
	x_debug_message := debug_message(x_message_number);
      END IF;
   END get_message;

   FUNCTION no_of_debug_messages RETURN NUMBER IS
   BEGIN
     return number_of_debug_messages;
   END no_of_debug_messages;
--------------------------------------------------------------------
/* APIs for handling processes, errors, named locks */
--------------------------------------------------------------------

PROCEDURE Set_User_Lock_Mode (  x_Lock_Mode     IN      NUMBER  DEFAULT 6,
                                x_Commit_Mode   IN      BOOLEAN DEFAULT FALSE,
                                x_TimeOut       IN      NUMBER  DEFAULT 0 )
IS
BEGIN

	G_LockMode := NVL(x_Lock_Mode,6);
	G_CommitMode := NVL(x_Commit_Mode,FALSE);
	G_TimeOut := NVL(x_TimeOut,0);

END Set_User_Lock_Mode;


----------------------------------------------------------------
/** Acquire_User_Lock : Function to acquire a user lock.
        x_lock_name : name of the lock.
        x_lock_mode : Mode of the lock ( Exclusive,..)
        x_commit_mode : Rls with commit or not
        Returns : 0 if successful in acquiring lock
        	: < 0 ( -1 to -5) if error in requesting lock (error status)
		: -99 if unable to allocate unique handle for the lock
        Ora Errors are not handled
**/


FUNCTION        Acquire_User_Lock ( x_Lock_Name     IN      VARCHAR2,
                                    x_Lock_Mode     IN      NUMBER ,
                                    x_Commit_Mode   IN      BOOLEAN,
				    x_TimeOut 	    IN	    NUMBER )
RETURN  NUMBER
IS
        lstatus  number;
        lockhndl varchar2(128);

BEGIN

	/* If Lock Name is NULL then return -99 */

	IF (x_Lock_Name IS NULL ) Then
		Return -99;
	END IF;

        /* get lock handle for user lock */

        dbms_lock.allocate_unique(x_lock_name,lockhndl,G_TimeOut);

        IF ( lockhndl IS NOT NULL ) then
          /* Get the lock, do not release the lock on commit */

          lstatus := dbms_lock.request(lockhndl,
				NVL(x_lock_mode,G_LockMode),
				G_TimeOut,
				NVL(x_commit_mode,G_CommitMode));

          IF ( lstatus = 0 ) then /* Got the lock */
                Return 0;
          ELSE
                Return (-1*lstatus);/* Return the status obtained on request */
          END IF;
        ELSE
          Return -99;  /* Failed to allocate lock */
        END IF;

END Acquire_User_Lock;

FUNCTION        Acquire_User_Lock ( x_Lock_Name     IN      VARCHAR2)
RETURN  NUMBER
IS
BEGIN

	Return Acquire_User_Lock( x_Lock_Name,G_LockMode,G_CommitMode,G_TimeOut
);

END Acquire_User_Lock;


------------------------------------------------------------------
/** Release_User_Lock : Function to release user lock.
        x_Lock_Name : The lock name to release
        Returns :0 - success,
		:< 0 - Error.
        Ora Errors are not handled
**/


FUNCTION        Release_User_Lock ( x_Lock_Name     IN      VARCHAR2 )
                RETURN NUMBER
IS
lstatus NUMBER;
lockhndl VARCHAR2(128);

BEGIN

        /* If Lock Name is NULL then return -99 */

        IF (x_Lock_Name IS NULL ) Then
                Return -99;
        END IF;

        /* get lock handle for user lock */

        dbms_lock.allocate_unique(x_lock_name,lockhndl,G_TimeOut);

        IF ( lockhndl IS NOT NULL ) then
          /* Release the Lock */

          lstatus := dbms_lock.release(lockhndl);

          IF ( lstatus = 0 ) then /* Lock Released */
                Return 0;
          ELSE
                Return (-1*lstatus);/* Return the status obtained on release */
          END IF;
        ELSE
          Return -99;  /* Failed to allocate lock */
        END IF;

END Release_User_Lock;

------------------------------------------------------------------
Procedure Set_Process ( x_Process       IN      VARCHAR2 DEFAULT 'PLSQL',
                        x_Write_File    IN      VARCHAR2 DEFAULT 'LOG',
                        x_Debug_Mode	IN	VARCHAR2 DEFAULT 'N' )
IS

BEGIN
	Select decode(x_Process,'PLSQL','PLSQL','SQL','SQL','REPORT',
				'REPORT','FORM','FORM','PLSQL'),
		decode(x_Write_File,'LOG','LOG','OUT','OUT','LOG')
	Into G_Process, G_WriteFile
	From dual;

	IF (x_Debug_Mode = 'Y') then
	   Enable_Debug;
	ELSE
	   Disable_Debug;
	END IF;

	IF (G_Process = 'PLSQL') then
	   Select decode(G_WriteFile,'LOG',FND_FILE.LOG,FND_FILE.OUTPUT )
	   Into   G_WriteFileID
	   From dual;
        ELSIF (G_Process = 'REPORT') then
           Enable_Debug;  /* If REPORT is used, then need to enable debug */
	ELSIF (G_Process = 'FORM') then
	   Enable_Debug;
	   number_of_debug_messages := 0;
	END IF;

END Set_Process;
---------------------------------------------------------------------
Procedure Write_File (  x_Write_File    IN      VARCHAR2,
			x_Msg		IN	VARCHAR2,
			x_Write_Mode	IN	NUMBER 	DEFAULT 0)
IS
    rest varchar2(32767);
    rest1 varchar2(32767);

BEGIN
   /* Write only if mandatory : Write_Mode = 1
      OR Optional for Debug : Write_Mode = 0 and Debug flag */

   rest := x_msg;

   IF (x_Write_Mode <> 0 OR (x_Write_Mode = 0 AND Debug_Flag )) Then
      LOOP
        IF (rest IS NULL) THEN
              exit;
        ELSE
              rest1 := substrb(rest,1,255);
              rest := substrb(rest, 256);
        END IF; -- IF (rest IS NULL)

	IF G_Process = 'PLSQL' then
	   IF NVL(x_Write_File,G_WriteFile) = 'OUT' then
		FND_FILE.PUT(FND_FILE.OUTPUT,rest1);
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
	   ELSIF NVL(x_Write_File,G_WriteFile) = 'LOG' then
		FND_FILE.PUT(FND_FILE.LOG,rest1);
		FND_FILE.NEW_LINE(FND_FILE.LOG);
	   ELSE
		FND_FILE.PUT(G_WriteFileID,rest1);
		FND_FILE.NEW_LINE(G_WriteFileID);
	   END IF;
	ELSIF G_Process = 'SQL' then
	   /* DBMS_OUTPUT.PUT_LINE(rest1); */
     NULL;
   ELSIF G_Process = 'IGNORE' then
     NULL;
	ELSE			/* This applies to REPORT and FORM */
	   Debug(rest1);
	End if;
      END LOOP;
   End If;

EXCEPTION

   WHEN UTL_FILE.INVALID_PATH THEN
	raise_application_error(-20010,'INVALID PATH exception from UTL_FILE !!'
				|| G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_MODE THEN
        raise_application_error(-20010,'INVALID MODE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        raise_application_error(-20010,'INVALID FILEHANDLE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_OPERATION THEN
        raise_application_error(-20010,'INVALID OPERATION exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.READ_ERROR THEN
        raise_application_error(-20010,'READ ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.WRITE_ERROR THEN
        raise_application_error(-20010,'WRITE ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
        raise_application_error(-20010,'INTERNAL ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

END Write_File;
---------------------------------------------------------------------
Procedure Write_File(	x_Msg 		IN	VARCHAR2,
			x_Write_Mode 	IN	NUMBER DEFAULT 0 )
IS
BEGIN
	Write_File( G_WriteFile, x_Msg, x_Write_Mode ) ;
END Write_File;
---------------------------------------------------------------------
Procedure Write_Log (	x_Module	IN	VARCHAR2,
			x_Msg		IN	VARCHAR2,
			x_Log_Level	IN	NUMBER DEFAULT 6 )
IS
BEGIN
	IF ( x_Log_Level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(x_Log_Level,x_Module,x_Msg);
	END IF;
END Write_Log;
----------------------------------------------------------------------
Procedure Init_Err_Stack (      x_Stack IN      VARCHAR2 )
IS
BEGIN
	G_Err_Ind := 1;
	G_Err_Stack_Tbl(1) := x_Stack;
	G_Err_Stack := x_Stack;

END Init_Err_Stack;
-----------------------------------------------------------------
Procedure Set_Err_Stack (       x_Stack IN      VARCHAR2 )
IS
BEGIN
	G_Err_Stack := G_Err_Stack || '->'||x_Stack;
END Set_Err_Stack;
-----------------------------------------------------------------
Procedure Reset_Err_Stack
IS
BEGIN
      G_err_stack := substr(G_err_stack, 1, instr(G_err_stack,'->',-1,1)-1) ;
END Reset_Err_Stack;
------------------------------------------------------------------

PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
		      x_Msg        IN VARCHAR2 ,
		      x_TokenName1 IN VARCHAR2 ,
                      x_Token1     IN VARCHAR2 ,
                      x_TokenName2 IN VARCHAR2 ,
                      x_Token2     IN VARCHAR2 ,
                      x_TokenName3 IN VARCHAR2 ,
                      x_Token3     IN VARCHAR2 )
IS

BEGIN
   fnd_message.set_name('PA', x_msg);
   fnd_message.set_token(x_TokenName1, x_Token1);
   fnd_message.set_token(x_TokenName2, x_Token2);
   fnd_message.set_token(x_TokenName3, x_Token3);

   raise_application_error(x_Msg_Num,fnd_message.get);

END raise_error;

-------------------------------------------------------------------
PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
                      x_Msg        IN VARCHAR2 ,
                      x_TokenName1 IN VARCHAR2 ,
                      x_Token1     IN VARCHAR2 ,
                      x_TokenName2 IN VARCHAR2 ,
                      x_Token2     IN VARCHAR2 )
IS

BEGIN
   fnd_message.set_name('PA', x_msg);
   fnd_message.set_token(x_TokenName1, x_Token1);
   fnd_message.set_token(x_TokenName2, x_Token2);

   raise_application_error(x_Msg_Num,fnd_message.get);

END raise_error;

-------------------------------------------------------------------
PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
                      x_Msg        IN VARCHAR2 ,
                      x_TokenName1 IN VARCHAR2 ,
                      x_Token1     IN VARCHAR2 )
IS

BEGIN
   fnd_message.set_name('PA', x_msg);
   fnd_message.set_token(x_TokenName1, x_Token1);

   raise_application_error(x_Msg_Num,fnd_message.get);

END raise_error;

-------------------------------------------------------------------
PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
                      x_Msg        IN VARCHAR2 )
IS

BEGIN
   fnd_message.set_name('PA', x_msg);

   raise_application_error(x_Msg_Num,fnd_message.get);

END raise_error;

-------------------------------------------------------------------


--Name:               Log_Message
--Type:               Procedure
--Description:        This procedure writes sysdate date and time, the
--                    current procedure name and the passed message
--                    to the log file.
--
--Called subprograms: write_file
--
--History:
--    29-NOV-00		jwhite		Cloned
--
--    07-DEC-00         jwhite          Added the p_msg_options IN parameter
--                                      to give the developer more
--                                      options for the log message
--                                      format:
--
--                                      1. PLAIN:     prints the p_message
--                                                    as is. This is the default.
--                                      2. TIME:      prints HH24:MI:SS, space,
--                                                    function name,:, p_message.
--                                      3. DATETIME:  prints YYYY/MM/DD HH24:MI:SS,
--                                                    space, function name,:, p_message.
--
--                                      PLEASE NOTE: If you place a pa_debug.log_message with either
--                                                   the TIME or DATETIME p_msg_option just
--                                                   before a SQL%ROWCOUNT,
--                                                   the SQL%ROWCOUNT will return 1.
--
--     11-DEC-00       jwhite          For log_message, modified code to only
--                                     print function name for log file.
--

PROCEDURE Log_Message( p_message       IN VARCHAR2
                       , p_write_mode  IN NUMBER   DEFAULT 0
                       , p_msg_options IN VARCHAR2 DEFAULT 'PLAIN'
                       , p_write_file  IN VARCHAR2 DEFAULT 'LOG'
                     )
IS

  l_function    VARCHAR2(50) := NULL;

BEGIN

   IF  (G_Function_Stack.exists(G_Function_Counter))
     THEN
        l_function := G_Function_Stack(G_Function_Counter);
   END IF;


   IF (p_write_file = 'LOG')
    THEN
    -- Print Function Name
      IF (p_msg_options = 'PLAIN')
         THEN
            eam_debug.write_file(p_write_file, g_space ||
	    l_function || ': '  ||p_message, p_write_mode);

      ELSIF (p_msg_options = 'TIME')
         THEN
            eam_debug.write_file(p_write_file,
	    to_char(sysdate,'HH24:MI:SS') || g_space ||
	    l_function || ': '  ||p_message, p_write_mode);
      ELSE
        --  Treat as DATETIME, including illegal values.
            eam_debug.write_file(p_write_file,
	    to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') || g_space ||
	    l_function || ': '  ||p_message, p_write_mode);
      END IF;

    ELSE
    -- Do Not Print Function Name
      IF (p_msg_options = 'PLAIN')
         THEN
            eam_debug.write_file(p_write_file, g_space ||p_message, p_write_mode);

      ELSIF (p_msg_options = 'TIME')
         THEN
            eam_debug.write_file(p_write_file,
	    to_char(sysdate,'HH24:MI:SS') || g_space ||p_message, p_write_mode);
      ELSE
        --  Treat as DATETIME, including illegal values.
            eam_debug.write_file(p_write_file,
	    to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') || g_space ||p_message, p_write_mode);
      END IF;
    END IF;

EXCEPTION

WHEN OTHERS
 THEN
   raise;

END log_message;

-------------------------------------------------------------------
--Name:               Set_Curr_Function
--Type:               Procedure
--Description:        This procedure conditionally calls either
--                    the init_err_stack and set_process procedures
--                    or the set_err_stack procedure. See the aforementioned
--                    procedures for more information about their
--                    functionality.
--
--                    With respect to the set_err_stack procedure, this
--                    procedure extends the functionality of the
--                    set_err_stack procedure by nesting subroutine messages
--                    within the overall program flow.
--
--
--Called subprograms: eam_debug.init_err_stack
--                    eam_debug.set_process
--                    eam_debug.set_err_stack
--
--History:
--    29-NOV-00		jwhite		Cloned
--

PROCEDURE Set_Curr_Function(p_function      IN  VARCHAR2
                            , p_process	    IN	VARCHAR2 DEFAULT 'PLSQL'
		            , p_write_file  IN	VARCHAR2 DEFAULT 'LOG'
			    , p_debug_mode  IN	VARCHAR2 DEFAULT 'N'
                            )
IS
BEGIN

   G_Function_Counter := G_Function_Counter + 1;
   G_Function_Stack(G_Function_Counter) := p_function;
   G_Space   := G_Space || '  ';

   IF ( G_Function_Counter = 1)
      THEN
          eam_debug.init_err_stack(p_function);
          eam_debug.set_process (p_process, p_write_file, p_debug_mode);
   ELSE
          eam_debug.set_err_stack(p_function);
   END IF;

END Set_Curr_Function;

-------------------------------------------------------------------
--Name:               Reset_Curr_Function
--Type:               Procedure
--Description:        This procedure removes the current procedure
--                    or function name from the error stack. This
--                    procedure also adjusts the global for
--                    indentation, accordingly.
--
--Called subprograms: eam_debug.reset_err_stack
--
--History:
--    29-NOV-00		jwhite		Cloned
--

PROCEDURE Reset_Curr_Function
IS
BEGIN

    G_Function_Stack.delete(G_Function_Counter);
    G_Function_Counter := G_Function_Counter -1;
    G_Space   := substr(G_Space,1,length(G_Space)-2);
    eam_debug.reset_err_stack;

END Reset_Curr_Function;



END eam_debug;

/

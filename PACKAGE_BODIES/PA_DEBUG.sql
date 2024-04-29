--------------------------------------------------------
--  DDL for Package Body PA_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DEBUG" AS
/* $Header: PADEBUGB.pls 120.5 2006/04/28 03:41:17 cmishra noship $ */

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

   PROCEDURE DEBUG (x_debug_message IN VARCHAR2) IS
    rest VARCHAR2(32767);
   BEGIN
       IF (debug_flag AND x_debug_message IS NOT NULL) THEN
	 IF ( debug_level = DEBUG_LEVEL_TIMING) THEN
	    rest := TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS ') || x_debug_message;
	 ELSE
	    rest := x_debug_message;
	 END IF;
	 LOOP
	   IF (rest IS NULL) THEN
	      EXIT;
	   ELSE
              number_of_debug_messages := number_of_debug_messages + 1;
              debug_message(number_of_debug_messages) := SUBSTRB(rest,1,255);
	      rest := SUBSTRB(rest, 256);
	   END IF; -- IF (rest IS NULL)
	 END LOOP;
       END IF; -- IF (debug_flag)
   END DEBUG;

   PROCEDURE DEBUG (x_debug_message IN VARCHAR2, x_debug_level IN NUMBER) IS
    old_debug_flag BOOLEAN;
   BEGIN
      IF ( debug_level >= x_debug_level ) THEN
         IF ( x_debug_level = DEBUG_LEVEL_EXCEPTION ) THEN
           old_debug_flag := debug_flag;
           debug_flag     := TRUE;
           DEBUG(x_debug_message);
           debug_flag     := old_debug_flag;
         ELSE
           DEBUG(x_debug_message);
         END IF;
      END IF;
   END DEBUG;

   PROCEDURE get_message(x_message_number IN NUMBER,
			 x_debug_message OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
   BEGIN
      IF (x_message_number > 0 ) THEN
	x_debug_message := debug_message(x_message_number);
      END IF;
   END get_message;

   FUNCTION no_of_debug_messages RETURN NUMBER IS
   BEGIN
     RETURN number_of_debug_messages;
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
        lstatus  NUMBER;
        lockhndl VARCHAR2(128);
        lTimeOut NUMBER; /* Bug#2289946 */

BEGIN

	/* If Lock Name is NULL then return -99 */

	IF (x_Lock_Name IS NULL ) THEN
		RETURN -99;
	END IF;

         /* Bug#2289946 -- Start */
         IF x_TimeOut = 0 THEN
                lTimeOut := 864000;
         ELSE
                lTimeOut := x_TimeOut;
         END IF;
        /* Bug#2289946 -- End */


        /* get lock handle for user lock */

        -- dbms_lock.allocate_unique(x_lock_name,lockhndl,G_TimeOut);   /* Bug#2289946 */

        dbms_lock.allocate_unique(x_lock_name,lockhndl,lTimeOut);   /* Bug#2289946 */

        IF ( lockhndl IS NOT NULL ) THEN
          /* Get the lock, do not release the lock on commit */

          lstatus := dbms_lock.request(lockhndl,
				NVL(x_lock_mode,G_LockMode),
				G_TimeOut,
				NVL(x_commit_mode,G_CommitMode));

          IF ( lstatus = 0 ) THEN /* Got the lock */
                RETURN 0;
          ELSE
                RETURN (-1*lstatus);/* Return the status obtained on request */
          END IF;
        ELSE
          RETURN -99;  /* Failed to allocate lock */
        END IF;

END Acquire_User_Lock;

FUNCTION        Acquire_User_Lock ( x_Lock_Name     IN      VARCHAR2)
RETURN  NUMBER
IS
BEGIN

	RETURN Acquire_User_Lock( x_Lock_Name,G_LockMode,G_CommitMode,G_TimeOut
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
lTimeOut NUMBER; /* Bug#2289946 */

BEGIN

        /* If Lock Name is NULL then return -99 */

        IF (x_Lock_Name IS NULL ) THEN
                RETURN -99;
        END IF;

         /* Bug#2289946 -- Start */
         IF G_TimeOut = 0 THEN
                lTimeOut := 864000;
         ELSE
                lTimeOut := G_TimeOut;
         END IF;
        /* Bug#2289946 -- End */

        /* get lock handle for user lock */

        -- dbms_lock.allocate_unique(x_lock_name,lockhndl,G_TimeOut);    /* Bug#2289946 */

        dbms_lock.allocate_unique(x_lock_name,lockhndl,lTimeOut);   /* Bug#2289946 */

        IF ( lockhndl IS NOT NULL ) THEN
          /* Release the Lock */

          lstatus := dbms_lock.RELEASE(lockhndl);

          IF ( lstatus = 0 ) THEN /* Lock Released */
                RETURN 0;
          ELSE
                RETURN (-1*lstatus);/* Return the status obtained on release */
          END IF;
        ELSE
          RETURN -99;  /* Failed to allocate lock */
        END IF;

END Release_User_Lock;

------------------------------------------------------------------
PROCEDURE Set_Process ( x_Process       IN      VARCHAR2, -- 1851096
                        x_Write_File    IN      VARCHAR2 DEFAULT 'LOG',
                        x_Debug_Mode	IN	VARCHAR2 DEFAULT 'N' )
IS

BEGIN
	SELECT DECODE(x_Process,'PLSQL','PLSQL','SQL','SQL','REPORT',
				'REPORT','FORM','FORM','PLSQL'),
		DECODE(x_Write_File,'LOG','LOG','OUT','OUT','LOG')
	INTO G_Process, G_WriteFile
	FROM dual;

	IF (x_Debug_Mode = 'Y') THEN
	   Enable_Debug;
	ELSE
	   Disable_Debug;
	END IF;

	IF (G_Process = 'PLSQL') THEN
	   SELECT DECODE(G_WriteFile,'LOG',Fnd_File.LOG,Fnd_File.OUTPUT )
	   INTO   G_WriteFileID
	   FROM dual;
        ELSIF (G_Process = 'REPORT') THEN
           Enable_Debug;  /* If REPORT is used, then need to enable debug */
	ELSIF (G_Process = 'FORM') THEN
	   Enable_Debug;
	   number_of_debug_messages := 0;
	END IF;

END Set_Process;
---------------------------------------------------------------------
PROCEDURE Write_File (  x_Write_File    IN      VARCHAR2,
			x_Msg		IN	VARCHAR2,
			x_Write_Mode	IN	NUMBER 	DEFAULT 0)
IS
    rest VARCHAR2(32767);
    rest1 VARCHAR2(32767);
	l_log_level NUMBER :=6;

BEGIN
   /* Write only if mandatory : Write_Mode = 1
      OR Optional for Debug : Write_Mode = 0 and Debug flag */

   rest := x_msg;

   IF (x_Write_Mode <> 0 OR (x_Write_Mode = 0 AND Debug_Flag )) THEN
      LOOP
        IF (rest IS NULL) THEN
              EXIT;
        ELSE
              rest1 := SUBSTRB(rest,1,255);
              rest := SUBSTRB(rest, 256);
        END IF; -- IF (rest IS NULL)

	IF G_Process = 'PLSQL' THEN
	   IF NVL(x_Write_File,G_WriteFile) = 'OUT' THEN
		Fnd_File.PUT(Fnd_File.OUTPUT,rest1);
		Fnd_File.NEW_LINE(Fnd_File.OUTPUT);
	   ELSIF NVL(x_Write_File,G_WriteFile) = 'LOG' THEN
		Fnd_File.PUT(Fnd_File.LOG,rest1);
		Fnd_File.NEW_LINE(Fnd_File.LOG);
		IF (l_log_level >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN -- by GSCC standard we have to checkt the level
			Fnd_Log.STRING(l_log_level,'Concurrent Request ID:'|| x_request_id,x_Msg);
		END IF;
	   ELSE
		Fnd_File.PUT(G_WriteFileID,rest1);
		Fnd_File.NEW_LINE(G_WriteFileID);
	   END IF;
	ELSIF G_Process = 'SQL' THEN
	   /* DBMS_OUTPUT.PUT_LINE(rest1); */
     NULL;
   ELSIF G_Process = 'IGNORE' THEN
     NULL;
	ELSE			/* This applies to REPORT and FORM */
	   DEBUG(rest1);
	END IF;
      END LOOP;
   END IF;

EXCEPTION

   WHEN UTL_FILE.INVALID_PATH THEN
	RAISE_APPLICATION_ERROR(-20010,'INVALID PATH exception from UTL_FILE !!'
				|| G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_MODE THEN
        RAISE_APPLICATION_ERROR(-20010,'INVALID MODE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        RAISE_APPLICATION_ERROR(-20010,'INVALID FILEHANDLE exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INVALID_OPERATION THEN
        RAISE_APPLICATION_ERROR(-20010,'INVALID OPERATION exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.READ_ERROR THEN
        RAISE_APPLICATION_ERROR(-20010,'READ ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.WRITE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20010,'WRITE ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
        RAISE_APPLICATION_ERROR(-20010,'INTERNAL ERROR exception from UTL_FILE !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);

END Write_File;
---------------------------------------------------------------------
PROCEDURE Write_File(	x_Msg 		IN	VARCHAR2,
			x_Write_Mode 	IN	NUMBER DEFAULT 0 )
IS
BEGIN
	Write_File( G_WriteFile, x_Msg, x_Write_Mode ) ;
END Write_File;
---------------------------------------------------------------------

-- This procedure is deprecated. Please use PA_DEBUG.WRITE.
PROCEDURE Write_Log (	x_Module	IN	VARCHAR2,
			x_Msg		IN	VARCHAR2,
			x_Log_Level	IN	NUMBER DEFAULT 6 )
IS
  -- OA changed their log level mapping so we have changed this method to use
  -- the new mapping.
  l_new_log_level NUMBER;
BEGIN
  IF (x_log_level = 4 OR x_log_level = 6) THEN
    l_new_log_level := 3;
  ELSIF (x_log_level = 7) THEN
    l_new_log_level := 5;
  ELSE
    l_new_log_level := 1;
  END IF;

  -- Added if condition for Bug 4271360
  IF (l_new_log_level >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
    Fnd_Log.STRING(l_new_log_level,x_Module,x_Msg);
  END IF;
  -- End Bug 4271360
END Write_Log;
----------------------------------------------------------------------
-- x_module: ex. pa.plsql.pa_timeline_pvt
-- x_msg: Message
-- x_Log_Level: 6 - Unexpected Errors
--              5 - Expected Errors
--              4 - Exception
--              3 - Event (High Level Logging Message)
--              2 - Procedure (Entry / Exit from a routine)
--              1 - Statement - (Low Level Logging Message)
--
PROCEDURE WRITE (
      x_Module	IN	VARCHAR2,
			x_Msg		IN	VARCHAR2,
			x_Log_Level	IN	NUMBER DEFAULT 1 )
IS
BEGIN
  -- Added if condition for Bug 4271360
  IF (x_Log_Level >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
    Fnd_Log.STRING(x_log_level,x_Module,x_Msg);
  END IF;
  -- End Bug 4271360
END WRITE;

----------------------------------------------------------------------
PROCEDURE Init_Err_Stack (      x_Stack IN      VARCHAR2 )
IS
BEGIN
	G_Err_Ind := 1;
	G_Err_Stack_Tbl(1) := x_Stack;
	G_Err_Stack := x_Stack;

END Init_Err_Stack;
-----------------------------------------------------------------
PROCEDURE Set_Err_Stack (       x_Stack IN      VARCHAR2 )
IS
BEGIN
/* Bug 5064900 : As max length of G_Err_Stack is 2000 , nothing is appended to G_Err_Stack if total length becomes greater than 2000. */
      If (length(G_Err_Stack || '->' || x_Stack) <= 2000) then
	G_Err_Stack := G_Err_Stack || '->'||x_Stack;
      end if;
END Set_Err_Stack;
-----------------------------------------------------------------
PROCEDURE Reset_Err_Stack
IS
BEGIN
      G_err_stack := SUBSTR(G_err_stack, 1, INSTR(G_err_stack,'->',-1,1)-1) ;
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
   Fnd_Message.set_name('PA', x_msg);
   Fnd_Message.set_token(x_TokenName1, x_Token1);
   Fnd_Message.set_token(x_TokenName2, x_Token2);
   Fnd_Message.set_token(x_TokenName3, x_Token3);

   RAISE_APPLICATION_ERROR(x_Msg_Num,Fnd_Message.get);

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
   Fnd_Message.set_name('PA', x_msg);
   Fnd_Message.set_token(x_TokenName1, x_Token1);
   Fnd_Message.set_token(x_TokenName2, x_Token2);

   RAISE_APPLICATION_ERROR(x_Msg_Num,Fnd_Message.get);

END raise_error;

-------------------------------------------------------------------
PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
                      x_Msg        IN VARCHAR2 ,
                      x_TokenName1 IN VARCHAR2 ,
                      x_Token1     IN VARCHAR2 )
IS

BEGIN
   Fnd_Message.set_name('PA', x_msg);
   Fnd_Message.set_token(x_TokenName1, x_Token1);

   RAISE_APPLICATION_ERROR(x_Msg_Num,Fnd_Message.get);

END raise_error;

-------------------------------------------------------------------
PROCEDURE raise_error(x_Msg_Num    IN NUMBER ,
                      x_Msg        IN VARCHAR2 )
IS

BEGIN
   Fnd_Message.set_name('PA', x_msg);

   RAISE_APPLICATION_ERROR(x_Msg_Num,Fnd_Message.get);

END raise_error;

-------------------------------------------------------------------


--Name:               Log_Message
--Type:               Procedure
--Description:        This procedure writes sysdate date and time, the
--                    current procedure name and the passed message
--                    to the log file.
--
--Called subprograms: pa_debug.write_file
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

   IF  (G_Function_Stack.EXISTS(G_Function_Counter))
     THEN
        l_function := G_Function_Stack(G_Function_Counter);
   END IF;


   IF (p_write_file = 'LOG')
    THEN
    -- Print Function Name
      IF (p_msg_options = 'PLAIN')
         THEN
            Pa_Debug.write_file(p_write_file, g_space ||
	    l_function || ': '  ||p_message, p_write_mode);

      ELSIF (p_msg_options = 'TIME')
         THEN
            Pa_Debug.write_file(p_write_file,
	    TO_CHAR(SYSDATE,'HH24:MI:SS') || g_space ||
	    l_function || ': '  ||p_message, p_write_mode);
      ELSE
        --  Treat as DATETIME, including illegal values.
            Pa_Debug.write_file(p_write_file,
	    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || g_space ||
	    l_function || ': '  ||p_message, p_write_mode);
      END IF;

    ELSE
    -- Do Not Print Function Name
      IF (p_msg_options = 'PLAIN')
         THEN
            Pa_Debug.write_file(p_write_file, g_space ||p_message, p_write_mode);

      ELSIF (p_msg_options = 'TIME')
         THEN
            Pa_Debug.write_file(p_write_file,
	    TO_CHAR(SYSDATE,'HH24:MI:SS') || g_space ||p_message, p_write_mode);
      ELSE
        --  Treat as DATETIME, including illegal values.
            Pa_Debug.write_file(p_write_file,
	    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') || g_space ||p_message, p_write_mode);
      END IF;
    END IF;

EXCEPTION

WHEN OTHERS
 THEN
   RAISE;

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
--Called subprograms: pa_debug.init_err_stack
--                    pa_debug.set_process
--                    pa_debug.set_err_stack
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
          Pa_Debug.init_err_stack(p_function);
          Pa_Debug.set_process (p_process, p_write_file, p_debug_mode);
   ELSE
          Pa_Debug.set_err_stack(p_function);
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
--Called subprograms: pa_debug.reset_err_stack
--
--History:
--    29-NOV-00		jwhite		Cloned
--

PROCEDURE Reset_Curr_Function
IS
BEGIN

    G_Function_Stack.DELETE(G_Function_Counter);
    G_Function_Counter := G_Function_Counter -1;
    G_Space   := SUBSTR(G_Space,1,LENGTH(G_Space)-2);
    Pa_Debug.reset_err_stack;

END Reset_Curr_Function;

-- =======================================================================
-- Start of Comments
-- API Name      : TrackPath
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure tracks the path thru the code to attach to error messages.
--
--  Parameters:
--
--  IN
--    P_Function     -  VARCHAR2(10) -- ADD or STRIP
--    P_Value        -  VARACHAR2(100)
--

/*-------------------------------------------------------------------------*/

PROCEDURE TrackPath (
        P_Function IN VARCHAR2,
        P_Value    IN VARCHAR2)

IS

        l_Value VARCHAR2(2000) := '->' || P_Value;

BEGIN

        Pa_Debug.G_Stage := 'Entering procedure TrackPath().';

        IF P_Function = 'ADD' THEN

                Pa_Debug.G_Stage := 'TrackPath(): Adding to Pa_Debug.G_Path.';
                Pa_Debug.G_Path  := Pa_Debug.G_Path  || l_Value;

        ELSIF P_Function = 'STRIP' THEN

                Pa_Debug.G_Stage := 'TrackPath(): Stripping from Pa_Debug.G_Path.';
                Pa_Debug.G_Path  := SUBSTR(Pa_Debug.G_Path,1,INSTR(Pa_Debug.G_Path,l_Value) - 1);

        END IF;

        Pa_Debug.G_Stage := 'Leaving procedure TrackPath().';

EXCEPTION
        WHEN OTHERS THEN
                RAISE;

END TrackPath;

END Pa_Debug;

/

--------------------------------------------------------
--  DDL for Package Body DOM_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_LOG" as
/*$Header: DOMULOGB.pls 120.0 2006/07/14 22:32:35 mkimizuk noship $*/

   --------------------------------------------
   -- This is Database Session Language.     --
   --------------------------------------------
   G_SESSION_LANG           CONSTANT VARCHAR2(99) := USERENV('LANG');

   --------------------------------------------
   -- This is the UI language.               --
   --------------------------------------------
   G_LANGUAGE_CODE          VARCHAR2(3);

   ----------------------------------------------------------------------------
   --  Debug Profile option used to write Error_Handler.Write_Debug          --
   --  Profile option name = INV_DEBUG_TRACE ;                               --
   --  User Profile Option Name = INV: Debug Trace                           --
   --  Values: 1 (True) ; 0 (False)                                          --
   --  NOTE: This better than MRP_DEBUG which is used at many places.        --
   ----------------------------------------------------------------------------
   -- Not Used
   -- G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   -- Must be '0' when this pkg is shipped
   G_DEV_DEBUG CONSTANT VARCHAR2(10) := '0' ;


   -----------------------------------------------------------------------
   -- These are the Constants to generate a New Line Character.         --
   -----------------------------------------------------------------------
   G_CARRIAGE_RETURN VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(13);
   G_LINE_FEED       VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(10);
   -- Following prints ^M characters in the log file.
   G_NEWLINE         VARCHAR2(2) :=  G_LINE_FEED;


   ---------------------------------------------------------------
   -- API Return Status       .                                 --
   ---------------------------------------------------------------
   G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
   G_RET_STS_WARNING       CONSTANT    VARCHAR2(1) :=  'W';
   G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

   ---------------------------------------------------------------
   -- Used for Error Reporting.                                 --
   ---------------------------------------------------------------
   G_ERROR_TABLE_NAME      VARCHAR2(30) ;
   G_ERROR_ENTITY_CODE     VARCHAR2(30) ;
   G_OUTPUT_DIR            VARCHAR2(512) ;
   G_ERROR_FILE_NAME       VARCHAR2(400) ;
   G_BO_IDENTIFIER         VARCHAR2(30) := 'DOM_API';


   ---------------------------------------------------------------
   -- Introduced for 11.5.10, so that Java Conc Program can     --
   -- continue writing to the same Error Log File.              --
   ---------------------------------------------------------------
   G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);


----------------------------------------------------------
-- Write to Concurrent Log                              --
----------------------------------------------------------
PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2) IS
BEGIN

  FND_FILE.put_line(FND_FILE.LOG, p_msg);


EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Developer_Debug LOGGING SQL ERROR => '|| SUBSTRB(SQLERRM, 1,240));

END Developer_Debug ;



--
--  Writes the message to the log file for the specified
--  level and module
--  if logging is enabled for this level and module
--
PROCEDURE LOG_STR(PKG_NAME    IN VARCHAR2,
                  API_NAME    IN VARCHAR2,
                  LABEL       IN VARCHAR2 := NULL ,
                  MESSAGE     IN VARCHAR2)
IS
     l_module VARCHAR2(400) ;

BEGIN

    IF (CHECK_LOG_LEVEL)
    THEN
        l_module := DOM_LOG_PREFIX || PKG_NAME || '.' || API_NAME ;

        IF LABEL IS NOT NULL THEN
            l_module := l_module ||  '.' || LABEL ;
        END IF ;

        IF ( DOM_LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(DOM_LOG_LEVEL,
                           l_module,
                           MESSAGE );

        END IF ;


    END IF ;


    IF (TO_NUMBER(G_DEV_DEBUG) > 0) THEN
        l_module := DOM_LOG_PREFIX || PKG_NAME || '.' || API_NAME ;

        IF LABEL IS NOT NULL THEN
            l_module := l_module ||  '.' || LABEL ;
        END IF ;

        Developer_Debug(l_module
                       || '['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '
                       || MESSAGE
                       );

    END IF ;

END LOG_STR ;


--
-- Tests whether logging is enabled for this level and module,
-- to avoid the performance penalty of building long debug
-- message strings unnecessarily.
--
FUNCTION TEST(PKG_NAME    IN VARCHAR2,
              API_NAME    IN VARCHAR2)
RETURN BOOLEAN
IS

BEGIN

   -- Call FND_LOG.TEST to check
   -- whether logging is enabled for this level and module,
   --
   -- FND_LOG:
   --   FUNCTION TEST(LOG_LEVEL IN NUMBER, MODULE IN VARCHAR2)
   -- RETURN BOOLEAN;
   --
   RETURN FND_LOG.TEST(DOM_LOG_LEVEL, DOM_LOG_PREFIX || PKG_NAME || '.' || API_NAME ) ;

END TEST ;


--
-- Tests whether DOM logging is enabled for this level
--
FUNCTION CHECK_LOG_LEVEL
RETURN BOOLEAN
IS
BEGIN



    IF (TO_NUMBER(G_DEV_DEBUG) > 0) THEN
       return TRUE ;
    ELSIF ( DOM_LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       return TRUE ;
    ELSE
       return FALSE ;
    END IF ;

END  CHECK_LOG_LEVEL;



/*****************************************************************************
-- the following methods should not be used in DOM for now

-----------------------------------------------------------------
-- Write Debug statements to Log using Error Handler procedure --
-----------------------------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS

BEGIN

  -- NOTE: No need to check for profile now, as Error_Handler checks
  --       for Error_Handler.Get_Debug = 'Y' before writing to Debug Log.
  -- If Profile set to TRUE --
  -- IF (G_DEBUG = '1') THEN
  -- Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
  -- END IF;
  Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);

EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Write_Debug LOGGING ERROR => '|| SUBSTRB(SQLERRM, 1,240) );

END Write_Debug ;


 ----------------------------------------------------------
 -- Internal procedure to open debug session.            --
 ----------------------------------------------------------
PROCEDURE open_debug_session_internal IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  --local variables
  l_log_output_dir       VARCHAR2(512);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

  Error_Handler.initialize();
  Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);

  ---------------------------------------------------------------------------------
  -- Commented on 12/17/2003 (PPEDDAMA). Open_Debug_Session should set the value
  -- appropriately, so that when the Debug Session is successfully opened :
  -- will return Error_Handler.Get_Debug = 'Y', else Error_Handler.Get_Debug = 'N'
  ---------------------------------------------------------------------------------
  -- Error_Handler.Set_Debug('Y');

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  --developer_debug('UTL_FILE_DIR : '||l_log_output_dir);
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      --developer_debug('Log Output Dir : '||l_log_output_dir);
    END IF;


    IF G_OUTPUT_DIR IS NOT NULL
    THEN
       l_log_output_dir := G_OUTPUT_DIR ;
    END IF ;



    IF G_ERROR_FILE_NAME IS NULL
    THEN
        G_ERROR_FILE_NAME := G_BO_IDENTIFIER ||'_'
                             -- || G_ERROR_TABLE_NAME||'_'
                             || to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';
    END IF ;

    --developer_debug('Trying to open the Error File => '||G_ERROR_FILE_NAME);

    -----------------------------------------------------------------------
    -- To open the Debug Session to write the Debug Log.                 --
    -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
    -----------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    ---------------------------------------------------------------
    -- Introduced for 11.5.10, so that Java Conc Program can     --
    -- continue writing to the same Error Log File.              --
    ---------------------------------------------------------------
    G_ERRFILE_PATH_AND_NAME := l_log_output_dir||'/'||G_ERROR_FILE_NAME;

    developer_debug(' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> G_RET_STS_SUCCESS) THEN
       developer_debug('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN
  -- Bug : 4099546
  CLOSE c_get_utl_file_dir;


EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'open_debug_session_internal LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240));

END open_debug_session_internal;


 -----------------------------------------------------------
 -- Open the Debug Session, conditionally if the profile: --
 -- INV Debug Trace is set to TRUE                        --
 -----------------------------------------------------------
PROCEDURE Open_Debug_Session
(  p_debug_flag IN VARCHAR2 := NULL
,  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
)
IS

BEGIN
  ----------------------------------------------------------------
  -- Open the Debug Log Session, only if Profile is set to TRUE --
  ----------------------------------------------------------------
  IF (G_DEBUG = 1 OR FND_API.to_Boolean(p_debug_flag)) THEN


     G_OUTPUT_DIR := p_output_dir ;
     G_ERROR_FILE_NAME := p_file_name ;
     ----------------------------------------------------------------------------------
     -- Opens Error_Handler debug session, only if Debug session is not already open.
     -- Suggested by RFAROOK, so that multiple debug sessions are not open PER
     -- Concurrent Request.
     ----------------------------------------------------------------------------------
     IF (Error_Handler.Get_Debug <> 'Y') THEN
       Open_Debug_Session_Internal;
     END IF;

  END IF;

EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Open_Debug_Session LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240) );

END Open_Debug_Session;

 -----------------------------------------------------------------
 -- Close the Debug Session, only if Debug is already Turned ON --
 -----------------------------------------------------------------
PROCEDURE Close_Debug_Session IS

BEGIN
   -----------------------------------------------------------------------------
   -- Close Error_Handler debug session, only if Debug session is already open.
   -----------------------------------------------------------------------------
   IF (Error_Handler.Get_Debug = 'Y') THEN
     Error_Handler.Close_Debug_Session;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Close_Debug_Session LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240) );

END Close_Debug_Session;

*****************************************************************************/

 -----------------------------------------------------------------
 -- Replace all Single Quote to TWO Single Quotes, for Escaping --
 -- NOTE: Used while inserting Strings using Dynamic SQL.       --
 -----------------------------------------------------------------
FUNCTION Escape_Single_Quote (p_String IN  VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN

   IF (p_String IS NOT NULL) THEN
     ---------------------------------------------------
     -- Replace all Single Quotes to 2 Single Quotes  --
     ---------------------------------------------------
     RETURN REPLACE(p_String, '''', '''''');

   ELSE
     ----------------------------------------------
     -- Return NULL, if the String is NULL or '' --
     ----------------------------------------------
     RETURN NULL;
   END IF;

END Escape_Single_Quote;


END DOM_LOG ;

/

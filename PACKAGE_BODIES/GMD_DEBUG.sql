--------------------------------------------------------
--  DDL for Package Body GMD_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_DEBUG" AS
/*  $Header: GMDUDBGB.pls 120.1 2006/01/18 15:09:10 sxfeinst noship $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMDUDBGB.pls
REM * PURPOSE: Package Body for the GME debug utilities
REM * AUTHOR:  Olivier DABOVAL, OPM Development
REM * DATE:    27th MAY 2001
REM *
REM * PROCEDURE log_initialize
REM * PROCEDURE log
REM *
REM *
REM * HISTORY :-
REM *
REM * 20-FEB-2004  NSRIVAST  Bug# 3222090,Removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
REM * 12-AUG-2005  UPHADTAR  Bug# 4576699 (FP of 4493387)
REM *                        Added code for getting the log file location and
REM *                        then logging messages on the basis of the Profile option.
REM **********************************************************************
*/

/* Bug # 4576699  Declared two variables below for Global Variables */
--  Global variables
global_gmdlog_location  VARCHAR2(300) := NULL;
global_file_name        VARCHAR2(100) := NULL;

/* Bug # 4576699  End */


--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
-- 20-FEB-2004  NSRIVAST  Bug# 3222090,Removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
--=======================================================================--
PROCEDURE Log_Initialize
( p_file_name   IN VARCHAR2)
IS

l_location   VARCHAR2(500);
LOG          UTL_FILE.FILE_TYPE;

CURSOR c_get_1st_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';




BEGIN
-- Bug# 3222090,20-FEB-2004  NSRIVAST , BEGIN
  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     G_LOG_ENABLED := 'Y';
  ELSE
     G_LOG_ENABLED := 'N';
  END IF;
 -- Bug# 3222090,20-FEB-2004  NSRIVAST , END

  G_LOG_LEVEL    := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF G_LOG_ENABLED = 'N' THEN
    G_LOG_MODE := 'OFF';
  ELSE
    IF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) > 0) THEN
      G_LOG_MODE := 'SRS';
    ELSIF p_file_name <> '0' THEN
      G_LOG_MODE := 'LOG';
    ELSE
      G_LOG_MODE := 'SQL';
    END IF;
  END IF;

  IF (G_LOG_MODE <> 'OFF' AND p_file_name <> '0')
  THEN
       IF (FND_GLOBAL.user_id > 0)
       THEN
         G_LOG_USERNAME := FND_GLOBAL.user_name;
       ELSE
         G_LOG_USERNAME := 'GMD_NO_USER';
       END IF;

       OPEN c_get_1st_location;
       FETCH c_get_1st_location
          INTO G_LOG_LOCATION;
       CLOSE c_get_1st_location;

       LOG := UTL_FILE.fopen(G_LOG_LOCATION, G_LOG_USERNAME||p_file_name, 'w', 32767);
       UTL_FILE.put_line(LOG, 'Log file opened at '||to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||' With log mode: '||G_LOG_MODE);
       UTL_FILE.fflush(LOG);
       UTL_FILE.fclose(LOG);
       G_FILE_NAME := p_file_name;
  END IF;

  /* Bug # 4576699 Added code below for checking the Profile option and then logging messages */
  IF (p_file_name IS NOT NULL) AND (NVL(fnd_profile.value('GMD_DEBUG_ENABLED'),'N') = 'Y') THEN

       global_file_name := p_file_name;

       OPEN  c_get_1st_location;
       FETCH c_get_1st_location
       INTO  global_gmdlog_location;
       CLOSE c_get_1st_location;

       LOG := UTL_FILE.fopen(global_gmdlog_location, global_file_name, 'w');
       UTL_FILE.put_line(LOG, 'Debug log file opened: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
       UTL_FILE.fflush(LOG);
       UTL_FILE.fclose(LOG);
  END IF;
  /* Bug # 4576699 End  */


-- B3027135 Add Exception Handler
EXCEPTION
  WHEN OTHERS THEN
    Null;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE put_line
( p_msg                         IN  VARCHAR2
, p_priority                    IN  NUMBER
, p_file_name                   IN  VARCHAR2
)
IS

LOG   UTL_FILE.FILE_TYPE;
l_file_name VARCHAR2(50);

CURSOR c_get_1st_location IS
SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';

-- Bug 4576699: added l_log
l_log                UTL_FILE.file_type;

BEGIN
  IF ((G_LOG_MODE <> 'OFF') AND (NVL(p_priority, 100) >= G_LOG_LEVEL))
  THEN
    IF G_LOG_MODE = 'LOG'
    THEN
      IF p_file_name = '0'
      THEN
         l_file_name := G_FILE_NAME;
      ELSE
         l_file_name := p_file_name;
      END IF;

      LOG := UTL_FILE.fopen(G_LOG_LOCATION, G_LOG_USERNAME||l_file_name, 'a', 32767);
      UTL_FILE.put_line(LOG, p_msg);
      UTL_FILE.fflush(LOG);
      UTL_FILE.fclose(LOG);

    ELSIF (G_LOG_MODE = 'SQL')
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      --DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;

/* Bug # 4576699  Added code below for checking the Profile option and then logging messages */
  IF (global_file_name IS NOT NULL) AND (NVL(fnd_profile.value('GMD_DEBUG_ENABLED'),'N') = 'Y') THEN

     IF global_gmdlog_location is NULL THEN
       OPEN  c_get_1st_location;
       FETCH c_get_1st_location
       INTO  global_gmdlog_location;
       CLOSE c_get_1st_location;
     END IF;

     l_log := UTL_FILE.fopen(global_gmdlog_location, global_file_name, 'a');
     IF UTL_FILE.IS_OPEN(l_log) THEN
        UTL_FILE.put_line(l_log, p_msg);
        UTL_FILE.fflush(l_log);
        UTL_FILE.fclose(l_log);
     END IF;
  END IF;
/* Bug # 4576699 End*/


-- B3027135 Add Exception Handler
EXCEPTION
  WHEN OTHERS THEN
    Null;

END put_line;

PROCEDURE display_messages
( p_msg_count			IN NUMBER
) IS
message 		           VARCHAR2(400);
dummy 				   NUMBER;
BEGIN
  FOR i IN 1..p_msg_count LOOP
         fnd_msg_pub.get
         (
         p_msg_index     => 1,
         p_data          => message,
         p_encoded       => 'F',
         p_msg_index_out => dummy
         );
     gmd_debug.put_line('Message '||to_char(p_msg_count)||' '||message);
  END LOOP;

END display_messages;

END GMD_DEBUG;

/

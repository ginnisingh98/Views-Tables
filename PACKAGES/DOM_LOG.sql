--------------------------------------------------------
--  DDL for Package DOM_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_LOG" AUTHID CURRENT_USER as
/* $Header: DOMULOGS.pls 120.0 2006/07/14 22:16:18 mkimizuk noship $*/

/* --------------------------------------------------------------------
-- DOM_LOG package is wrapper of FND_LOG and PL/SQL Utiliteis to
-- for DOM Loggin Framework  on top of Oracle Applications Logging Framework
--
-- The Oracle Applications Logging Framework (aka FND Logging Framework)
-- allows developers to log debug, error and alert messages to a central repository
-- which is shared by both database and middle-tier servers. PL/SQL, Java, and C APIs are provided.
-- There are numerous mechanisms available for controlling which messages are logged.
-- Documentation for this package is at
-- http://www-apps.us.oracle.com:1100/logging/
--
--
--
-- How to Log from PL/SQL in OA Logging Fwk
--
-- PL/SQL APIs are a part of the FND_LOG Package.
-- These APIs assume that appropriate application user session initialization APIs
-- (for example, FND_GLOBAL.INITIALIZE(..)) have already been invoked for setting up
-- the user session properties on the database Session. These application user session
-- properties (UserId, RespId, AppId, SessionId) are internally needed for the Log APIs.
-- Typically, all Oracle Application Frameworks (CP, OAF, JTT, Forms, etc.) take care of
-- invoking these session initialization APIs for you.
-- Plain-text messages should be logged using FND_LOG.STRING(..),
-- and translatable Message Dictionary Messages should be logged using FND_LOG.MESSAGE(..). FND_LOG.MESSAGE(..) logs
-- the Message in encoded (not translated) format, and allows the Log Viewer UI to handle the translation of the Message
-- based on the language preferences of the Sysadmin viewing the Messages.
-- For FND_LOG API details please refer to: $fnd/patch/115/sql/AFUTLOGB.pls
--
-- In DOM PL/SQL API, utilize DOM_LOG Package which is the wrapper util of FND_LOG
--
-- DOM Log Level is defined in global var DOM_LOG_LEVEL CONSTANT NUMBER default:  FND_LOG.LEVEL_PROCEDURE
--
--
-- Example
-- Assuming AOL Session Initialization has occurred and logging is enabled, the following calls would log a message:
-- begin
--
--   -- Here is where you would call a routine that logs messages
--   -- Important Performance check, see if logging is enabled
--   IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
--     DOM_LOG.LOG_STR(PKG_NAME   -- Normaly you should define this global var
--                    , 'Your_Procedure' --  API Name. Normally you should define l_api_name at the beginning and pass it
--                    , 'Your_Label' -- Optional. Appended after API Name. e.g. begin, end
--                    , 'Hello, world!' );
--   END IF ;
--
-- Log Module will be 'dom.plsql.PKG_NAME.Your_Procedure.Your_Label'
--
-- -- Note: For Forms Client PL/SQL, the APIs are the same, except that for checking
--          if logging is enabled, you should call DOM_LOG.TEST(..)
-- -- Note: If you change G_DEV_DEBUG in DOM_LOG PKG Body to '1' and compile it in devlopment env
--          the message is written in conc log file under 'utl_file_dir' specified in DB Param
--
------------------------------------------------------------------------------------------
-- How to Turn On Logging
------------------------------------------------------------------------------------------
-- In normal circumstances, the PL/SQL layer logging is automatically initialized by
-- the enclosing Apps component's AOL Session Management layer, i.e. Forms, Concurrent
--  Manager, Java Framework- SSWA, JTF, OA, etc. In some rare circumstances,
--  for example, if you are debugging an issue, you may need to manually initialize
-- the PL/SQL layer logging for the current session. From the SQL*Prompt, you could do this by calling:
--
-- FND_GLOBAL.APPS_INITIALIZE(fnd_user_id, fnd_resp_id, fnd_appl_id);
-- fnd_profile.put('AFLOG_ENABLED', 'Y');
-- fnd_profile.put('AFLOG_MODULE', 'dom%');
-- fnd_profile.put('AFLOG_LEVEL', '2');
-- fnd_profile.put('AFLOG_FILENAME', '');
-- fnd_log_repository.init;
--
-- Do not ship any code with these calls! Shipping code that internally hard codes
-- Log Properties is a severe P1 bug. Logging should always be externally configurable
-- using the Log Properties, and internally hard coding log properties would prevent this.
--
-------------------------------------------------------------------------------------------
-- Viewing Log Messages
-------------------------------------------------------------------------------------------
--
-- OA Framework Pages
-- When working in OA Framework pages, follow this procedure to view your log messages.
-- 1.) Applications pages based on the OA Framework have a global button labeled Diagnostics.
--  Click this button to open a window where you can choose between Show Log and Set Trace Level.
-- 2.) Choose Show Log to open the Logs page within Oracle Applications Manager.
-- The Logs page is part of the System Alerts and Metrics feature.
-- Note: For the Diagnostics global button to be visible, the profile option FND_DIAGNOSTICS must be set to Yes.
--
-- Oracle Applications Manager (OAM) or System Administrator -> OAM: Logs
-- OAM is part of 11.5.9, and is typically accessible on any 11.5.9 instance from a URL like:
-- http://host:port/servlets/weboam/oam/oamLogin
-- From the drop-down-list, navigate to "System Alerts and Metrics" -> Logs
-- Fyi, "Advanced Search" allows you to query by CP-Name.
-- (Starting 11.5.10, you will be able to query by CP Request-Id too).
--
--------------------------------------------------------------------*/


/*--------------------------------------------------------------------
-- Constant Variables
--------------------------------------------------------------------*/

  ---------------------------------------
  -- Package Name
  ---------------------------------------
  G_PKG_NAME  CONSTANT VARCHAR2(30):='DOM_LOG';

  ---------------------------------------
  -- LOG Level
  ---------------------------------------
  LEVEL_UNEXPECTED CONSTANT NUMBER  := FND_LOG.LEVEL_UNEXPECTED ; -- 6
  LEVEL_ERROR      CONSTANT NUMBER  := FND_LOG.LEVEL_ERROR;       -- 5
  LEVEL_EXCEPTION  CONSTANT NUMBER  := FND_LOG.LEVEL_EXCEPTION;   -- 4
  LEVEL_EVENT      CONSTANT NUMBER  := FND_LOG.LEVEL_EVENT;       -- 3
  LEVEL_PROCEDURE  CONSTANT NUMBER  := FND_LOG.LEVEL_PROCEDURE;   -- 2
  LEVEL_STATEMENT  CONSTANT NUMBER  := FND_LOG.LEVEL_PROCEDURE;   -- 1

  ---------------------------------------
  -- DOM LOG Level
  ---------------------------------------
  -- We enable Dom PL/SQL Log at FND_LOG.LEVEL_PROCEDURE Level
  DOM_LOG_LEVEL CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE ;

  ---------------------------------------
  -- DOM LOG Module Prefix
  ---------------------------------------
  -- We enable Dom PL/SQL Log at FND_LOG.LEVEL_PROCEDURE Level
  DOM_LOG_PREFIX CONSTANT VARCHAR2(10) := 'dom.plsql.' ;


  --
  --  Writes the message to the log file for the specified
  --  level and module
  --  if logging is enabled for this level and module
  --
  PROCEDURE LOG_STR(PKG_NAME    IN VARCHAR2,
                    API_NAME    IN VARCHAR2,
                    LABEL       IN VARCHAR2 := NULL,
                    MESSAGE     IN VARCHAR2);

  /*-------------------------------------
  -- Will implement if needed
  PROCEDURE STRING(PKG_NAME    IN VARCHAR2,
                   API_NAME    IN VARCHAR2,
                   MESSAGE     IN VARCHAR2);


  PROCEDURE STRING(LOG_LEVEL IN NUMBER,
                   MODULE    IN VARCHAR2,
                   MESSAGE   IN VARCHAR2);
  -------------------------------------*/

  /*-----------------------------------------------------------
  -- Will implement if needed
  --
  --  Writes a message to the log file if this level and module
  --  are enabled.
  --  The message gets set previously with FND_MESSAGE.SET_NAME,
  --  SET_TOKEN, etc.
  --  The message is popped off the message dictionary stack,
  --  if POP_MESSAGE is TRUE.
  --  Pass FALSE for POP_MESSAGE if the message will also be
  --  displayed to the user later.
  --  Example usage:
  --  FND_MESSAGE.SET_NAME(...);    -- Set message
  --  FND_MESSAGE.SET_TOKEN(...);   -- Set token in message
  --  FND_LOG.MESSAGE(..., FALSE);  -- Log message
  --  FND_MESSAGE.RAISE_ERROR;      -- Display message
  PROCEDURE MESSAGE(MODULE      IN VARCHAR2,
                    POP_MESSAGE IN BOOLEAN DEFAULT NULL);


  PROCEDURE MESSAGE(LOG_LEVEL   IN NUMBER,
                    MODULE      IN VARCHAR2,
                    POP_MESSAGE IN BOOLEAN DEFAULT NULL);
  -----------------------------------------------------------*/

  --
  -- Tests whether logging is enabled for this level and module,
  -- to avoid the performance penalty of building long debug
  -- message strings unnecessarily.
  --
  FUNCTION TEST(PKG_NAME    IN VARCHAR2,
                API_NAME    IN VARCHAR2)
  RETURN BOOLEAN;


  /*-----------------------------------------------------------
  -- Will implement if needed
  FUNCTION TEST(LOG_LEVEL IN NUMBER
               , MODULE    IN VARCHAR2)
  RETURN BOOLEAN;
  -----------------------------------------------------------*/

  --
  -- Tests whether DOM logging is enabled for this level
  --
  FUNCTION CHECK_LOG_LEVEL
  RETURN BOOLEAN;


END DOM_LOG ;

 

/

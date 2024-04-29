--------------------------------------------------------
--  DDL for Package ZPB_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_LOG" AUTHID CURRENT_USER as
/* $Header: zpblog.pls 120.6 2007/12/04 15:31:16 mbhat ship $ */

-------------------------------------------------------------------------------
-- BUILD_MESSAGE
--
-- Procedure to populate structures need to build a message.
-- You should clear this message after using it via fnd_message.clear.
--
-- IN:
--   MESSAGE      - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                  a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------

procedure BUILD_MESSAGE (MESSAGE       in VARCHAR2,
                         TOKEN_1_NAME  in VARCHAR2 default NULL,
                         TOKEN_1_VALUE in VARCHAR2 default NULL,
                         TOKEN_2_NAME  in VARCHAR2 default NULL,
                         TOKEN_2_VALUE in VARCHAR2 default NULL,
                         TOKEN_3_NAME  in VARCHAR2 default NULL,
                         TOKEN_3_VALUE in VARCHAR2 default NULL,
                         TOKEN_4_NAME  in VARCHAR2 default NULL,
                         TOKEN_4_VALUE in VARCHAR2 default NULL,
                         TOKEN_5_NAME  in VARCHAR2 default NULL,
                         TOKEN_5_VALUE in VARCHAR2 default NULL);

-------------------------------------------------------------------------------
-- WRITE_TO_CONCMGR_LOG
--
-- Procedure to write translated informational messages to the concurrent manager request log.
-- Message should be tranlated prior to calling this procedure.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The Message to be logged (should be translated)
--
-------------------------------------------------------------------------------
procedure WRITE_TO_CONCMGR_LOG (MESSAGE in VARCHAR2);

-------------------------------------------------------------------------------
-- WRITE_TO_CONCMGR_LOG_TR
--
-- Procedure to log informational translated messages to the concurrent log.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE_NAME - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                  a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------
procedure WRITE_TO_CONCMGR_LOG_TR(MESSAGE_NAME  in VARCHAR2,
                                  TOKEN_1_NAME  in VARCHAR2 default NULL,
                                  TOKEN_1_VALUE in VARCHAR2 default NULL,
                                  TOKEN_2_NAME  in VARCHAR2 default NULL,
                                  TOKEN_2_VALUE in VARCHAR2 default NULL,
                                  TOKEN_3_NAME  in VARCHAR2 default NULL,
                                  TOKEN_3_VALUE in VARCHAR2 default NULL,
                                  TOKEN_4_NAME  in VARCHAR2 default NULL,
                                  TOKEN_4_VALUE in VARCHAR2 default NULL,
                                  TOKEN_5_NAME  in VARCHAR2 default NULL,
                                  TOKEN_5_VALUE in VARCHAR2 default NULL,
                                  POP_MESSAGE   in BOOLEAN  default TRUE);

-------------------------------------------------------------------------------
-- ERROR
--
-- Procedure to log at the ERROR  BI Beans level
--
-- IN:
--   MESSAGE      - The message passed by Bi Beans
--
-------------------------------------------------------------------------------
procedure 	       ERROR (MESSAGE in VARCHAR2 );

-------------------------------------------------------------------------------
-- GET_DEBUGGING_LEVEL
--
-- Returns the debugging level.  Used by CM.LOG in the AW
--  'L' - Log all to log file
--  'C' - Log all to concurrent manager
--  'N' - No extra logging
--
-------------------------------------------------------------------------------
function GET_DEBUGGING_LEVEL return varchar2;

-------------------------------------------------------------------------------
-- GET_LOGGING_LEVEL
--
-- Returns the logging level.  Same as FND_LOG.G_CURRENT_RUNTIME_LEVEL, but
-- placed in a function for use in AW's
-------------------------------------------------------------------------------
function GET_LOGGING_LEVEL return number;

-------------------------------------------------------------------------------
-- LOG_PLSQL_EXCEPTION
--
-- Logs a generic PL/SQL message stating the module and SQLERRM of an exception
-- that just occured. This must be called only if a valid PL/SQL exception
-- occurred.
--
-- IN: p_module      - The module where the exception occurred
--     p_procedure   - The procedure name where the exception occured
--     p_pop_message - True if the message stack should be cleared
-------------------------------------------------------------------------------
procedure LOG_PLSQL_EXCEPTION (p_module      in VARCHAR2,
                               p_procedure   in VARCHAR2,
                               p_pop_message in BOOLEAN  := TRUE);

-------------------------------------------------------------------------------
-- TRACE
 -- Procedure to log  Trace at the BI Beans level
--
-- IN:
--   MESSAGE      - The message passed by Bi Beans
--
-------------------------------------------------------------------------------
procedure 	       TRACE(MESSAGE in VARCHAR2 );


-------------------------------------------------------------------------------

-- WRITE
--
-- Procedure to log at the PROCEDURE level (2).  Log here to mark entering and
-- exiting of procedures, as well as input and output parameters from those
-- procedures.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The Message to be logged (non-translated)
--
-------------------------------------------------------------------------------
procedure WRITE (MODULE       in VARCHAR2,
                 MESSAGE      in VARCHAR2);

-------------------------------------------------------------------------------
-- WRITE_ERROR
--
-- Procedure to log at the ERROR level (5).  Log here when any user-errors
-- or validation errors occur.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE_NAME - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                   a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------
procedure WRITE_ERROR (MODULE        in VARCHAR2,
                       MESSAGE_NAME  in VARCHAR2,
                       TOKEN_1_NAME  in VARCHAR2 default NULL,
                       TOKEN_1_VALUE in VARCHAR2 default NULL,
                       TOKEN_2_NAME  in VARCHAR2 default NULL,
                       TOKEN_2_VALUE in VARCHAR2 default NULL,
                       TOKEN_3_NAME  in VARCHAR2 default NULL,
                       TOKEN_3_VALUE in VARCHAR2 default NULL,
                       TOKEN_4_NAME  in VARCHAR2 default NULL,
                       TOKEN_4_VALUE in VARCHAR2 default NULL,
                       TOKEN_5_NAME  in VARCHAR2 default NULL,
                       TOKEN_5_VALUE in VARCHAR2 default NULL,
                       POP_MESSAGE   in BOOLEAN  default TRUE);

-------------------------------------------------------------------------------
-- WRITE_EVENT
--
-- Procedure to log at the EVENT level (3).  Log here when any major event
-- occurs.  This event message is not translated.  Use WRITE_USER_EVENT for
-- a translated event.  Note that events logged here in a concurrent
-- process will be sent to FND_LOG, not the Request log.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The message to be logged (not translated)
--
-------------------------------------------------------------------------------
procedure WRITE_EVENT (MODULE       in VARCHAR2,
                       MESSAGE      in VARCHAR2);

-------------------------------------------------------------------------------
-- WRITE_EVENT_TR
--
-- Procedure to log at the EVENT level (3).  Log here when any major event
-- occurs.  This event message is translated.  If used in a concurrent process,
-- these messages will be logged to the Request Log.
--
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE_NAME - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                   a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------
procedure WRITE_EVENT_TR (MODULE        in VARCHAR2,
                          MESSAGE_NAME  in VARCHAR2,
                          TOKEN_1_NAME  in VARCHAR2 default NULL,
                          TOKEN_1_VALUE in VARCHAR2 default NULL,
                          TOKEN_2_NAME  in VARCHAR2 default NULL,
                          TOKEN_2_VALUE in VARCHAR2 default NULL,
                          TOKEN_3_NAME  in VARCHAR2 default NULL,
                          TOKEN_3_VALUE in VARCHAR2 default NULL,
                          TOKEN_4_NAME  in VARCHAR2 default NULL,
                          TOKEN_4_VALUE in VARCHAR2 default NULL,
                          TOKEN_5_NAME  in VARCHAR2 default NULL,
                          TOKEN_5_VALUE in VARCHAR2 default NULL,
                          POP_MESSAGE   in BOOLEAN  default TRUE);

-------------------------------------------------------------------------------
-- WRITE_EXCEPTION_UNTR
--
-- Procedure to log at the EVENT level (4).  Log here when any major exception
-- occurs.  This exception message is not translated.  Use WRITE_EXCEPTION for
-- a translated exception.  Note that exception logged here in a concurrent
-- process will be sent to FND_LOG, not the Request log.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The message to be logged (not translated)
--
-------------------------------------------------------------------------------
procedure WRITE_EXCEPTION_UNTR (MODULE       in VARCHAR2,
                                MESSAGE      in VARCHAR2);

-------------------------------------------------------------------------------
-- WRITE_EXCEPTION
--
-- Procedure to log at the EXCEPTION level (4).  Log here when any non-critical
-- exception occurs in the code.
--
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE_NAME - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                   a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------
procedure WRITE_EXCEPTION (MODULE        in VARCHAR2,
                           MESSAGE_NAME  in VARCHAR2,
                           TOKEN_1_NAME  in VARCHAR2 default NULL,
                           TOKEN_1_VALUE in VARCHAR2 default NULL,
                           TOKEN_2_NAME  in VARCHAR2 default NULL,
                           TOKEN_2_VALUE in VARCHAR2 default NULL,
                           TOKEN_3_NAME  in VARCHAR2 default NULL,
                           TOKEN_3_VALUE in VARCHAR2 default NULL,
                           TOKEN_4_NAME  in VARCHAR2 default NULL,
                           TOKEN_4_VALUE in VARCHAR2 default NULL,
                           TOKEN_5_NAME  in VARCHAR2 default NULL,
                           TOKEN_5_VALUE in VARCHAR2 default NULL,
                           POP_MESSAGE   in BOOLEAN  default TRUE);

-------------------------------------------------------------------------------
-- WRITE_STATEMENT
--
-- Procedure to log at the STATEMENT level (1).  Log here for any low-level
-- messages, ie. for tracing or debugging
--
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The message to be logged (not translated)
--
-------------------------------------------------------------------------------
procedure WRITE_STATEMENT (MODULE       in VARCHAR2,
                           MESSAGE      in VARCHAR2);

-------------------------------------------------------------------------------
-- WRITE_UNEXPECTED
--
-- Procedure to log at the UNEXPECTED level (6).  Log here when any critical
-- exception occurs in the code.  This will be alerted to system admins
--
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE_NAME - The Message name defined in FND_MESSAGES table
--   TOKEN_#      - Any tokens required in the message.  Tokens go as a
--                   a name/value.  Omit if not applicable
--   POP_MESSAGE  - True if the message will not be used again.  False means
--                  you must explicitly clear the message.
--
-------------------------------------------------------------------------------
procedure WRITE_UNEXPECTED (MODULE        in VARCHAR2,
                            MESSAGE_NAME  in VARCHAR2,
                            TOKEN_1_NAME  in VARCHAR2 default NULL,
                            TOKEN_1_VALUE in VARCHAR2 default NULL,
                            TOKEN_2_NAME  in VARCHAR2 default NULL,
                            TOKEN_2_VALUE in VARCHAR2 default NULL,
                            TOKEN_3_NAME  in VARCHAR2 default NULL,
                            TOKEN_3_VALUE in VARCHAR2 default NULL,
                            TOKEN_4_NAME  in VARCHAR2 default NULL,
                            TOKEN_4_VALUE in VARCHAR2 default NULL,
                            TOKEN_5_NAME  in VARCHAR2 default NULL,
                            TOKEN_5_VALUE in VARCHAR2 default NULL,
                            POP_MESSAGE   in BOOLEAN  default TRUE);

end ZPB_LOG;

/

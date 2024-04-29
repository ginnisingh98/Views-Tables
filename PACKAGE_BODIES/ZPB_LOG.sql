--------------------------------------------------------
--  DDL for Package Body ZPB_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_LOG" as
/* $Header: zpblog.plb 120.8 2007/12/04 15:30:57 mbhat ship $ */

procedure BUILD_MESSAGE (MESSAGE        in VARCHAR2,
                         TOKEN_1_NAME   in VARCHAR2 default NULL,
                         TOKEN_1_VALUE  in VARCHAR2 default NULL,
                         TOKEN_2_NAME   in VARCHAR2 default NULL,
                         TOKEN_2_VALUE  in VARCHAR2 default NULL,
                         TOKEN_3_NAME   in VARCHAR2 default NULL,
                         TOKEN_3_VALUE  in VARCHAR2 default NULL,
                         TOKEN_4_NAME   in VARCHAR2 default NULL,
                         TOKEN_4_VALUE  in VARCHAR2 default NULL,
                         TOKEN_5_NAME   in VARCHAR2 default NULL,
                         TOKEN_5_VALUE  in VARCHAR2 default NULL)
   is
      l_tok_1_val varchar2(1000);
      l_tok_2_val varchar2(1000);
      l_tok_3_val varchar2(1000);
      l_tok_4_val varchar2(1000);
      l_tok_5_val varchar2(1000);

begin
   FND_MESSAGE.SET_NAME ('ZPB', MESSAGE);
   if (TOKEN_1_NAME is not null) then
      l_tok_1_val:= substr(TOKEN_1_VALUE,1,1000);
      FND_MESSAGE.SET_TOKEN(TOKEN_1_NAME, l_tok_1_val);
    else
      return;
   end if;
   if (TOKEN_2_NAME is not null) then
      l_tok_2_val:= substr(TOKEN_2_VALUE,1,1000);
      FND_MESSAGE.SET_TOKEN(TOKEN_2_NAME, l_tok_2_val);
    else
      return;
   end if;
   if (TOKEN_3_NAME is not null) then
      l_tok_3_val:= substr(TOKEN_3_VALUE,1,1000);
      FND_MESSAGE.SET_TOKEN(TOKEN_3_NAME, l_tok_3_val);
    else
      return;
   end if;
   if (TOKEN_4_NAME is not null) then
      l_tok_4_val:= substr(TOKEN_4_VALUE,1,1000);
      FND_MESSAGE.SET_TOKEN(TOKEN_4_NAME, l_tok_4_val);
    else
      return;
   end if;
   if (TOKEN_5_NAME is not null) then
      l_tok_5_val:= substr(TOKEN_5_VALUE,1,1000);
      FND_MESSAGE.SET_TOKEN(TOKEN_5_NAME, l_tok_5_val);
    else
      return;
   end if;
end BUILD_MESSAGE;
-------------------------------------------------------------------------------
-- Error
--
-- Procedure to log BI Beans Erros.
--
--
-- IN:
--   MESSAGE      - The Message coming from Bi Beans
--
-------------------------------------------------------------------------------
procedure ERROR          (MESSAGE       in VARCHAR2 )
   is
      l_Module     varchar2(30) := 'ZPBBIBEANS';
begin

              WRITE_EXCEPTION_UNTR (l_Module, MESSAGE);
end Error;

-------------------------------------------------------------------------------
-- FORMAT_REQUEST_MESSAGE
--
-- Procedure to format the message for the concurrent message log
-------------------------------------------------------------------------------
function FORMAT_REQUEST_MESSAGE (MODULE  in VARCHAR2,
                                 MESSAGE in VARCHAR2)
   return VARCHAR2 is
begin
   return MODULE||' ('||to_char(sysdate, 'HH24:MI:SS')||'): '||MESSAGE;
end FORMAT_REQUEST_MESSAGE;

-------------------------------------------------------------------------------
-- GET_DEBUGGING_LEVEL
--
-- Returns the debugging level.  Used by CM.LOG in the AW
--  'L' - Log all to log file (locally run)
--  'C' - Log all to concurrent manager (executed from concurrent + developer)
--  'N' - No extra logging (executed from Java, or production concurrent)
--
-------------------------------------------------------------------------------
function GET_DEBUGGING_LEVEL return varchar2
   is
      l_dev_mode varchar2(1);
      l_conc_id  number;
      l_user     varchar2(30);
      l_ret      varchar2(1);
begin
   l_dev_mode := FND_PROFILE.VALUE ('FND_DEVELOPER_MODE');
   l_conc_id  := FND_GLOBAL.CONC_REQUEST_ID;
   select osuser
      into l_user
      from v$session
      where audsid = USERENV('SESSIONID');

   if (l_user <> 'semops') then
     l_ret := 'L';
    elsif (l_dev_mode = 'Y' and l_conc_id <> -1) then
     l_ret := 'C';
    else l_ret := 'N';
   end if;
   -- Temporary until single instance:
   l_ret := 'L';
   return l_ret;
end GET_DEBUGGING_LEVEL;

-------------------------------------------------------------------------------
-- GET_LOGGING_LEVEL
--
-- Returns the logging level.  Same as FND_LOG.G_CURRENT_RUNTIME_LEVEL, but
-- placed in a function for use in AW's
-------------------------------------------------------------------------------
function GET_LOGGING_LEVEL return number
   is
begin
   return FND_LOG.G_CURRENT_RUNTIME_LEVEL;
end GET_LOGGING_LEVEL;

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
                               p_pop_message in BOOLEAN) is
begin
   if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL or
       not p_pop_message) then

      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('PKG_NAME',p_module);
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME',p_procedure);
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',substr(SQLERRM, 1, 1000));

      if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL and
          fnd_global.conc_request_id = -1) then
         FND_LOG.MESSAGE (FND_LOG.LEVEL_EXCEPTION,
                          'zpb.plsql.'||p_module||'.'||p_procedure,
                          p_pop_message);
      end if;
   end if;

end LOG_PLSQL_EXCEPTION;
-------------------------------------------------------------------------------
-- TRACE
--
-- Procedure to log BI Beans Errors and trace.
--
--
-- IN:
--   MESSAGE      - The Message coming from Bi Beans
--
-------------------------------------------------------------------------------
procedure TRACE          (MESSAGE       in VARCHAR2 )
   is
      l_Module     varchar2(30) := 'ZPBBIBEANS';
begin

              WRITE_EVENT (l_Module, MESSAGE);
end TRACE;


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
                 MESSAGE      in VARCHAR2)
   is
      l_user     varchar2(30);
begin
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'zpb.plsql.'||MODULE,
                         MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            FORMAT_REQUEST_MESSAGE(MODULE, MESSAGE));
      end if;
   end if;
end WRITE;

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
                       TOKEN_1_NAME  in VARCHAR2,
                       TOKEN_1_VALUE in VARCHAR2,
                       TOKEN_2_NAME  in VARCHAR2,
                       TOKEN_2_VALUE in VARCHAR2,
                       TOKEN_3_NAME  in VARCHAR2,
                       TOKEN_3_VALUE in VARCHAR2,
                       TOKEN_4_NAME  in VARCHAR2,
                       TOKEN_4_VALUE in VARCHAR2,
                       TOKEN_5_NAME  in VARCHAR2,
                       TOKEN_5_VALUE in VARCHAR2,
                       POP_MESSAGE   in BOOLEAN)
   is
      l_user     varchar2(30);
begin
   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL or
       not pop_message) then
      BUILD_MESSAGE (MESSAGE_NAME,
                     TOKEN_1_NAME,
                     TOKEN_1_VALUE,
                     TOKEN_2_NAME,
                     TOKEN_2_VALUE,
                     TOKEN_3_NAME,
                     TOKEN_3_VALUE,
                     TOKEN_4_NAME,
                     TOKEN_4_VALUE,
                     TOKEN_5_NAME,
                     TOKEN_5_VALUE);
   end if;
   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.MESSAGE (FND_LOG.LEVEL_ERROR,
                          'zpb.plsql.'||MODULE,
                          POP_MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
         if (POP_MESSAGE) then
            FND_MESSAGE.CLEAR;
         end if;
      end if;
   end if;
end WRITE_ERROR;

-------------------------------------------------------------------------------
-- WRITE_EVENT
--
-- Procedure to log at the EVENT level (3).  Log here when any major event
-- occurs.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                   "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The message to be logged (not translated)
--
-------------------------------------------------------------------------------
procedure WRITE_EVENT (MODULE       in VARCHAR2,
                       MESSAGE      in VARCHAR2)
   is
      l_user     varchar2(30);
begin
   if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.STRING (FND_LOG.LEVEL_EVENT,
                         'zpb.plsql.'||MODULE,
                         MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            FORMAT_REQUEST_MESSAGE(MODULE, MESSAGE));
      end if;
   end if;
end WRITE_EVENT;

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
                          TOKEN_1_NAME  in VARCHAR2,
                          TOKEN_1_VALUE in VARCHAR2,
                          TOKEN_2_NAME  in VARCHAR2,
                          TOKEN_2_VALUE in VARCHAR2,
                          TOKEN_3_NAME  in VARCHAR2,
                          TOKEN_3_VALUE in VARCHAR2,
                          TOKEN_4_NAME  in VARCHAR2,
                          TOKEN_4_VALUE in VARCHAR2,
                          TOKEN_5_NAME  in VARCHAR2,
                          TOKEN_5_VALUE in VARCHAR2,
                          POP_MESSAGE   in BOOLEAN)
   is
      l_user     varchar2(30);
begin

   if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL or
       not pop_message) then
      BUILD_MESSAGE (MESSAGE_NAME,
                     TOKEN_1_NAME,
                     TOKEN_1_VALUE,
                     TOKEN_2_NAME,
                     TOKEN_2_VALUE,
                     TOKEN_3_NAME,
                     TOKEN_3_VALUE,
                     TOKEN_4_NAME,
                     TOKEN_4_VALUE,
                     TOKEN_5_NAME,
                     TOKEN_5_VALUE);
   end if;
   if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.MESSAGE (FND_LOG.LEVEL_EVENT,
                          'zpb.plsql.'||MODULE,
                          POP_MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
         if (POP_MESSAGE) then
            FND_MESSAGE.CLEAR;
         end if;
      end if;
   end if;
end WRITE_EVENT_TR;

-------------------------------------------------------------------------------
-- WRITE_EXCEPTION_UNTR
--
-- Procedure to log at the EXCEPTION level (3).  Log here when any major exception
-- occurs.
--
-- IN:
--   MODULE       - The calling package and procedure.  Example:
--                  "zpb_aw_write_back.submit_writeback_request"
--   MESSAGE      - The message to be logged (not translated)
--
-------------------------------------------------------------------------------
procedure WRITE_EXCEPTION_UNTR (MODULE       in VARCHAR2,
                                MESSAGE      in VARCHAR2)
   is
begin
   if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
                         'zpb.plsql.'||MODULE,
                         MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            FORMAT_REQUEST_MESSAGE(MODULE, MESSAGE));
      end if;
   end if;
end WRITE_EXCEPTION_UNTR;


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
                           TOKEN_1_NAME  in VARCHAR2,
                           TOKEN_1_VALUE in VARCHAR2,
                           TOKEN_2_NAME  in VARCHAR2,
                           TOKEN_2_VALUE in VARCHAR2,
                           TOKEN_3_NAME  in VARCHAR2,
                           TOKEN_3_VALUE in VARCHAR2,
                           TOKEN_4_NAME  in VARCHAR2,
                           TOKEN_4_VALUE in VARCHAR2,
                           TOKEN_5_NAME  in VARCHAR2,
                           TOKEN_5_VALUE in VARCHAR2,
                           POP_MESSAGE   in BOOLEAN)
   is
      l_user     varchar2(30);
begin
   if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL or
       not pop_message) then
      BUILD_MESSAGE (MESSAGE_NAME,
                     TOKEN_1_NAME,
                     TOKEN_1_VALUE,
                     TOKEN_2_NAME,
                     TOKEN_2_VALUE,
                     TOKEN_3_NAME,
                     TOKEN_3_VALUE,
                     TOKEN_4_NAME,
                     TOKEN_4_VALUE,
                     TOKEN_5_NAME,
                     TOKEN_5_VALUE);
   end if;
   if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.MESSAGE (FND_LOG.LEVEL_EXCEPTION,
                          'zpb.plsql.'||MODULE,
                          POP_MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
         if (POP_MESSAGE) then
            FND_MESSAGE.CLEAR;
         end if;
      end if;
   end if;
end WRITE_EXCEPTION;

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
                           MESSAGE      in VARCHAR2)
   is
      l_user     varchar2(30);

begin

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                         'zpb.plsql.'||MODULE,
                         MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG,
                            FORMAT_REQUEST_MESSAGE(MODULE, MESSAGE));
      end if;
   end if;
end WRITE_STATEMENT;
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
                            TOKEN_1_NAME  in VARCHAR2,
                            TOKEN_1_VALUE in VARCHAR2,
                            TOKEN_2_NAME  in VARCHAR2,
                            TOKEN_2_VALUE in VARCHAR2,
                            TOKEN_3_NAME  in VARCHAR2,
                            TOKEN_3_VALUE in VARCHAR2,
                            TOKEN_4_NAME  in VARCHAR2,
                            TOKEN_4_VALUE in VARCHAR2,
                            TOKEN_5_NAME  in VARCHAR2,
                            TOKEN_5_VALUE in VARCHAR2,
                            POP_MESSAGE   in BOOLEAN)
   is
      l_user     varchar2(30);
begin
   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL or
       not pop_message) then
      BUILD_MESSAGE (MESSAGE_NAME,
                     TOKEN_1_NAME,
                     TOKEN_1_VALUE,
                     TOKEN_2_NAME,
                     TOKEN_2_VALUE,
                     TOKEN_3_NAME,
                     TOKEN_3_VALUE,
                     TOKEN_4_NAME,
                     TOKEN_4_VALUE,
                     TOKEN_5_NAME,
                     TOKEN_5_VALUE);
   end if;
   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (fnd_global.conc_request_id = -1) then
         FND_LOG.MESSAGE (FND_LOG.LEVEL_UNEXPECTED,
                          'zpb.plsql.'||MODULE,
                          POP_MESSAGE);
       else
         FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET);
         if (POP_MESSAGE) then
            FND_MESSAGE.CLEAR;
         end if;
      end if;
   end if;
end WRITE_UNEXPECTED;

-------------------------------------------------------------------------------
-- WRITE_TO_CONCMGR_LOG
--
-- Procedure to log informational, non-translated messages to the concurrent log.
--
-- IN:
--   MESSAGE      - The Message to be logged (non-translated)
--
-------------------------------------------------------------------------------
procedure WRITE_TO_CONCMGR_LOG (MESSAGE in VARCHAR2)
is
begin
   FND_FILE.PUT_LINE (FND_FILE.LOG,
                      MESSAGE);
end WRITE_TO_CONCMGR_LOG;

-------------------------------------------------------------------------------
-- WRITE_TO_CONCMGR_LOG_TR
--
-- Procedure to log informational translated messages to the concurrent log.
--
-- IN:
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
                                  POP_MESSAGE   in BOOLEAN  default TRUE)
is
begin

      BUILD_MESSAGE (MESSAGE_NAME,
                     TOKEN_1_NAME,
                     TOKEN_1_VALUE,
                     TOKEN_2_NAME,
                     TOKEN_2_VALUE,
                     TOKEN_3_NAME,
                     TOKEN_3_VALUE,
                     TOKEN_4_NAME,
                     TOKEN_4_VALUE,
                     TOKEN_5_NAME,
                     TOKEN_5_VALUE);

      FND_FILE.PUT_LINE (FND_FILE.LOG, to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') ||' ' ||  FND_MESSAGE.GET);
      if (POP_MESSAGE) then
         FND_MESSAGE.CLEAR;
      end if;


end WRITE_TO_CONCMGR_LOG_TR;

end ZPB_LOG;

/

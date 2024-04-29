--------------------------------------------------------
--  DDL for Package Body WF_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOG_PKG" as
/* $Header: WFLOGPKB.pls 120.3.12000000.2 2007/07/03 21:53:24 vshanmug ship $ */

LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
LEVEL_ERROR      CONSTANT NUMBER  := 5;
LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
LEVEL_EVENT      CONSTANT NUMBER  := 3;
LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
LEVEL_STATEMENT  CONSTANT NUMBER  := 1;

------------------------------------------------------------------------------
/*
** Init - Initialise the Logging global variables to do standalone testing.
**        This will do the same work as wf_log_pkg.wf_debug_flag.
**        (This API to be used by WF Dev only)
*/
procedure Init (
   LOG_ENABLED  in binary_integer,
   LOG_FILENAME in varchar2,
   LOG_LEVEL    in number,
   LOG_MODULE   in varchar2,
   FND_USER_ID  in number,
   FND_RESP_ID  in number,
   FND_APPL_ID  in number
)
is
  l_user_id number;
  l_resp_id number;
  l_appl_id number;
begin

   if (FND_USER_ID is NULL) then
      l_user_id := 0;
   else
      l_user_id := FND_USER_ID;
   end if;

   if (FND_RESP_ID is NULL) then
      l_resp_id := -1;
   else
      l_resp_id := FND_RESP_ID;
   end if;

   if (FND_APPL_ID is NULL) then
      l_appl_id := -1;
   else
      l_appl_id := FND_APPL_ID;
   end if;

   FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_appl_id);

   if (log_enabled = 1) then
      FND_PROFILE.Put('AFLOG_ENABLED', 'Y');
   end if;

   if (log_filename is NOT NULL) then
      FND_PROFILE.Put('AFLOG_FILENAME', log_filename);
   end if;

   if (log_level is NOT NULL) then
      FND_PROFILE.Put('AFLOG_LEVEL', log_level);
   end if;

   if (log_module is NOT NULL) then
      FND_PROFILE.Put('AFLOG_MODULE', log_module);
   end if;

   FND_LOG_REPOSITORY.Init();

exception
   when others then
      wf_core.context('WF_LOG_PKG', 'Init');
      raise;
end Init;
------------------------------------------------------------------------------

/*
** set_level - Described in Spec
**
*/
procedure SET_LEVEL(
  LOG_LEVEL in number
)
is

begin
   if (log_level is NOT NULL) then
      FND_PROFILE.Put('AFLOG_LEVEL', log_level);

      -- Seems that the change of profile doesn't automatically
      -- populate the FND_LOG log level.
      FND_LOG_REPOSITORY.Init();

   end if;
end SET_LEVEL;



/*
** String - Described in Spec
**
*/
procedure String(
  LOG_LEVEL	in number,
  MODULE	in varchar2,
  MESSAGE	in varchar2
)
is
begin

  if( LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   if (FND_LOG.Test(log_level, module)) then
      FND_LOG.String(log_level, module, message);
   end if;
  end if;

exception
  when others then
    null;
end String;

------------------------------------------------------------------------------
/*
**  Test - Check if logging is enabled for the given level and module.
**         Better to call FND_LOG.Test directly in order to avoid overhead.
*/
function Test(
   LOG_LEVEL in number,
   MODULE    in varchar2
)
return boolean
is
begin

  return FND_LOG.Test(log_level, module);

end Test;

/*
** MESSAGE
**  Wrapper to FND_LOG.MESSAGE
**  Writes a message to the log file if this level and module is enabled
**  This requires that the message was set previously with
**  WF_LOG_PKG.SET_NAME, WF_LOG_PKG.SET_TOKEN, etc.
**  The message is popped off the message dictionary stack, if POP_MESSAGE
**  is TRUE.  Pass FALSE for POP_MESSAGE if the message will also be
**  displayed to the user later.  If POP_MESSAGE isn't passed, the
**  message will not be popped off the stack, so it must be displayed
**  or explicitly cleared later on.
*/
procedure MESSAGE (
   LOG_LEVEL   in number,
   MODULE      in varchar2,
   POP_MESSAGE in boolean)
is
begin
  if( LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.MESSAGE(LOG_LEVEL,
		   MODULE,
		   POP_MESSAGE);
 end if;
end MESSAGE;

/*
** SET_NAME
**   Wrapper to FND_MESSAGE.SET_NAME
**   Sets the message name
*/
procedure SET_NAME(
   APPLICATION in varchar2,
   NAME        in varchar2
)
is
begin
   FND_MESSAGE.SET_NAME(APPLICATION,
			NAME);
end;

/*
** SET_TOKEN
**   Wrapper to FND_MESSAGE.SET_TOKEN
**   Defines a message token with a value
*/
procedure SET_TOKEN (
   TOKEN     in varchar2,
   VALUE     in varchar2,
   TRANSLATE in boolean
)
is
begin
   FND_MESSAGE.SET_TOKEN(TOKEN,
			 VALUE,
			 TRANSLATE);
end;

------------------------------------------------------------------------------
/*
** String2 - Described in Spec
**
*/
procedure String2(
  LOG_LEVEL     in number,
  MODULE        in varchar2,
  MESSAGE       in varchar2,
  STARTS        in boolean
)
is
   l_elapsed_time varchar2(40);
   l_log          varchar2(70);
   l_end_time     number;
   l_start_time   number;
   l_idx          number;
begin
   -- using 2^20 as the size of the hash table
   l_idx := dbms_utility.get_hash_value(module, 1, 1048576);

   if (starts) then
     wf_log_pkg.g_start_times(l_idx) := dbms_utility.get_time();
     l_log := ' [Start time '||to_char(wf_log_pkg.g_start_times(l_idx))||']';
   else
     l_end_time := dbms_utility.get_time();
     l_start_time := wf_log_pkg.g_start_times(l_idx);

     -- Retaining the start time may help printing incremental
     -- elapsed time... Scope for improvement later.
     wf_log_pkg.g_start_times.delete(l_idx);

     l_elapsed_time := trunc(((l_end_time-l_start_time)/100), 2);
     l_log := ' [End time '||to_char(l_end_time)||']';
     l_log := l_log||' [Time taken - '||to_char(l_elapsed_time)||' secs]';
   end if;

  if( LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   if (FND_LOG.Test(log_level, module)) then
      FND_LOG.String(log_level, module, message||l_log);
   end if;
  end if;

exception
  when others then
    null;
end String2;
------------------------------------------------------------------------------

end WF_LOG_PKG;

/

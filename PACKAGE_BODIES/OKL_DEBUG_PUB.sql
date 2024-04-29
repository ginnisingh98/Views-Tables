--------------------------------------------------------
--  DDL for Package Body OKL_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEBUG_PUB" as
/* $Header: OKLPDEGB.pls 120.2.12010000.2 2016/10/10 05:59:38 amansinh ship $ */
-- Start of Comments
-- Package name     : OKL_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


DB_NAME VARCHAR2(80) := 'OKL';

Function OpenFile(P_File in varchar2  ) Return Varchar2 IS
rtn_val   Varchar2(100);
Begin

       if G_DIR is null then
            select value  INTO G_DIR
 	        from v$PARAMETER where name = 'utl_file_dir';
	       if instr(G_DIR,',') > 0 then
 	           G_DIR := substr(G_DIR,1,instr(G_DIR,',')-1);
 	       end if;
       END IF;


      if P_FILE is null then
         -- select substr('l'|| substr(to_char(sysdate,'MI'),1,1)
           --        || lpad(OKL_DEBUG_file_s.nextval,6,'0'),1,8) ||  '.IEX'
           --into G_FILE from dual;

            SELECT DB_NAME || USERENV('SESSIONID') || '.OKL' into G_FILE
            FROM   DUAL;

           G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'w');
      else
           G_FILE :=P_File;
           G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'a');
      end if;

      rtn_val := G_DIR || '/' || g_file;


    return(rtn_val);
 Exception
     WHEN OTHERS then
          return(null);
End OpenFile;

Procedure SetDebugFileDir(P_FILEDIR IN VARCHAR2) IS

BEGIN
   if p_FileDir IS not null then
	G_DIR := p_FileDir;
   end if;
END;


--  PROCEDURE  LogMessage
--
--  Usage       Used to log message to the debug  file

PROCEDURE LogMessage(debug_msg   in Varchar2,
              debug_level in Number default 10,
              print_date  in varchar2 default 'N')

IS
rtn_val   Varchar2(100);
BEGIN


  if (G_Debug_Level <= debug_level) then
      rtn_val:=OpenFile(G_FILE);

      if print_date = 'Y' then
         utl_file.put_line(G_FILE_PTR, to_char( sysdate, 'DD-MON-YYYY HH:MI:SS' )  || ' ' || debug_msg );

   	  else
	      utl_file.put_line(G_FILE_PTR, ' ' ||debug_msg);
  	  end if; --if print date is 'Y'

      -- Write and close the file
       utl_file.fflush(G_FILE_PTR);
       utl_file.fclose(G_FILE_PTR);

  end if;-- debug level is big enough

Exception
 WHEN OTHERS then
       null;
END LogMessage; -- LogMessage

/*Inserted by SPILLAIP Begin*/
--
-- This function checks the profile value of FND: Debug_Enabled
-- and returns boolean
--
FUNCTION CHECK_LOG_ENABLED
 RETURN varchar2 IS
 value varchar2(40) := 'N';
BEGIN
  fnd_profile.get('AFLOG_ENABLED',value);
  return value;
EXCEPTION
  when others then
    return 'N';
END;

  Procedure Set_Connection_Context Is
    --
    -- This procedure makes sure that we are in the same session in
    -- order to use any globals. Unfortunately we do not have any
    -- fnd_global.session_id like fnd_global.user_id, so we have to
    -- use context to cache it.
    --
    l_session_id   Varchar2(30);
    l_user_id      Number;
    l_resp_id      Number;
    l_resp_appl_id Number;
    l_log_enable_value Varchar2(30);
  Begin

    l_session_id := Sys_Context('USERENV', 'SESSIONID');

    If (g_session_id = OKC_API.G_MISS_CHAR) Or
       (g_session_id <> l_session_id) Then
      g_session_id := l_session_id;
      --
      -- Now if we are in new session, we need to call the
      -- fnd_global.apps_initialize once again so that the
      -- AOL Logging profiles are set correctly.
      --
      l_user_id := Fnd_Global.User_Id;
      l_resp_id := Fnd_Global.Resp_Id;
      l_resp_appl_id := Fnd_Global.Resp_Appl_Id;

      Fnd_Global.Apps_Initialize(user_id      => l_user_id,
                                 resp_id      => l_resp_id,
                                 resp_appl_id => l_resp_appl_id);

      g_profile_log_level := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

    End If;
   End;

--
--Function Check_Log_On checks if the module is enabled for the
-- level specified.  This function returns boolean.
--
FUNCTION CHECK_LOG_ON
  ( p_module IN varchar2,
    p_level IN number)
   RETURN  boolean IS
   log_enabled boolean := false;
BEGIN
  log_enabled := fnd_log.test(p_level,p_module);
   if (log_enabled) then
      return true;
   else
      return false;
   end if;
Exception
  when others then
     return false;
end;

--
-- Log_debug procedure log the debug to FND_LOG.  This procedure
-- does not check if debug is enabled.
--
PROCEDURE LOG_DEBUG
  ( p_log_level IN number,
    p_module IN varchar2,
    p_message IN varchar2) IS
BEGIN
    --
    -- First thing, set the connection context
    --
    Set_Connection_Context;

   if (check_log_on(p_module, p_log_level)) then
	if(p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      		fnd_log.string(p_log_level,p_module,p_message);
  	 end if;
   end if;
END;


/*Inserted by SPILLAIP End*/

--  PROCEDURE   SetDebugLevel
--
--  Usage       set debug level if running outside of application otherwise debuglevel
--              is taken from the profile value

Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  OKL_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
End SetDebugLevel;

BEGIN
   --SELECT NAME INTO DB_NAME FROM V$DATABASE;
   --DB_NAME := DB_NAME || '_';
   -- Bug: 23560526 12C Multitenant feature start
   DB_NAME := upper( sys_context('userenv','db_name') ) || '_';
   -- Bug: 23560526 12C Multitenant feature end

END OKL_DEBUG_PUB;

/

--------------------------------------------------------
--  DDL for Package Body OKC_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DEBUG" AS
/* $Header: OKCDBUGB.pls 120.0 2005/05/25 22:52:14 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- g_user_id  Number 		:= OKC_API.G_MISS_NUM;
  g_indent_str 	Varchar2(4000) 	:= Null;
  g_proc 	Varchar2(80);

  TYPE proc_tbl IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  g_proc_tbl proc_tbl;
  g_index Number := 0;
  G_MAX_INDENT_STR_LEN CONSTANT NUMBER(4) := 1880;

  Procedure Set_Indentation(p_proc_name Varchar2) IS
  --
  -- This procedure sets the indentation global string for the debug
  -- messages. This global string will be prefixed before the actual
  -- messages is printed. Also sets global procedure name which gets
  -- printed along with the mesasges. This procedure should be called
  -- at the beginning of each procedure and the procedure name should
  -- be passed as the parameter.
  --
  Begin
    --
    -- set trace on/off flag depending on the profile option
    -- if trace off, do not call indentation
    -- the flag will be set whenever the indent string is null
    -- bug 2170106, jkodiyan
    --
    if g_indent_str is null then
      if FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' then
        Set_trace_on;
      else
        Set_trace_off;
      end if;
    end if;

    if g_set_trace_off then
      return;
    end if;

    --
    -- Set the global procedure name
    --
    g_proc := p_proc_name;
    --
    -- Increase the indent string by 2 spaces.
    --
    g_indent_str := g_indent_str || '  ';
    -- See comments above for bug 2216341
    If Length(g_indent_str) > G_MAX_INDENT_STR_LEN Then
      g_indent_str := '  ';
    End If;
    --
    -- Store the procedure name in the stack. This step is important
    -- otherwise we will loose this information once we are back
    -- to the calling procedure from the called procedure.
    --
    g_index := g_index + 1;
    g_proc_tbl(g_index) := p_proc_name;
  End Set_Indentation;

  Procedure Reset_Indentation IS
  --
  -- Sets the global procedure name to null. Also reduces the global
  -- indentation string by 2 characters. This procedure must be
  -- called before all the exit points within the procedure. The exit
  -- point include the last statement in the procedure, all the return
  -- statements and the outermost exceptions (unless there is return
  -- within inner exceptions). This procedure must be called in
  -- conjunction with Set_Indentation. That means in one is called,
  -- the second one must also be called or none should be called.
  --
  Begin
    --
    -- do nothing if the trace is set to off
    -- bug 2170106, jkodiyan
    --
    if g_set_trace_off then
	  return;
    end if;

    --
    -- Reset the indent string by 2 space.
    --
    g_indent_str := Substr(g_indent_str, 1, Length(g_indent_str) - 2);
    --
    -- Drop the current called procedure name from the stack since
    -- we just exited.
    --
    g_proc_tbl.delete(g_index);
    --
    -- Get the parent calling procedure name from the stack.
    --
    g_index := g_index - 1;
    If g_index <= 0 Then
      g_index := 0;
      -- Reset the proc name otherwise it prints the last proc name
      -- if the caller didn't make call to set_indentation.
      g_proc := Null;
    else
      g_proc := g_proc_tbl(g_index);
    End If;
  End Reset_Indentation;

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
/*      -- Now if we are in new session, we need to call the
      -- fnd_global.apps_initialize once again so that the
      -- AOL Logging profiles are set correctly.
      --
      l_user_id := Fnd_Global.User_Id;
      l_resp_id := Fnd_Global.Resp_Id;
      l_resp_appl_id := Fnd_Global.Resp_Appl_Id;

      Fnd_Global.Apps_Initialize(user_id      => l_user_id,
                                 resp_id      => l_resp_id,
                                 resp_appl_id => l_resp_appl_id);
*/

      g_profile_log_level := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

    End If;


/* If (g_user_id = OKC_API.G_MISS_NUM) Or
       (g_user_id <> fnd_global.user_id) Then
      g_user_id := fnd_global.user_id;
    End If; 		*/

  End Set_Connection_Context;



  PROCEDURE Log(p_msg      IN VARCHAR2,
                p_level    IN NUMBER,
                p_module   IN VARCHAR2) IS
  Begin
    --
    -- First thing, set the connection context
    --
    Set_Connection_Context;
    --
    -- Make sure that the current logging level is set at least as high
    -- as in profile option.
    --
    IF g_set_trace_off = TRUE  Then
      return;
    END IF;
   If (p_level >= g_profile_log_level) Then
      --
      -- Also logging should be enabled for the current module.
      --
      If Fnd_Log.Test(p_level, p_module) Then
        If instr(p_msg, OKC_API.G_MISS_CHAR) > 0 then
          Fnd_Log.String(p_level, p_module, g_indent_str || g_proc || ' : ' ||Replace(p_msg,OKC_API.G_MISS_CHAR,'?'));
       Else
          Fnd_Log.String(p_level, p_module, g_indent_str || g_proc || ' : ' ||p_msg);
       End if;
      End If;
    End If;
  End Log;

 Procedure Set_trace_off IS
  Begin
   g_set_trace_off := TRUE;

  End  Set_trace_off;

 Procedure Set_trace_on IS
  Begin
   g_set_trace_off := FALSE;
   End  Set_trace_on;

END OKC_DEBUG;

/

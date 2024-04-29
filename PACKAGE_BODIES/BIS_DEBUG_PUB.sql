--------------------------------------------------------
--  DDL for Package Body BIS_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DEBUG_PUB" AS
/* $Header: BISPDBGB.pls 120.1 2005/07/02 04:22:51 appldev ship $ */



Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2 IS
   rtn_val   Varchar2(100);
Begin
    if P_MODE = 'FILE' then
       G_DEBUG_MODE := 'FILE';

       if G_DIR is null then
          select value
	    INTO G_DIR
	    from v$PARAMETER where name = 'utl_file_dir';
	  if instr(G_DIR,',') > 0 then
	     G_DIR := substr(G_DIR,1,instr(G_DIR,',')-1);
	  end if;
       END IF;

       if G_FILE is null then
          select substr('l'|| substr(to_char(sysdate,'MI'),1,1)
                 || lpad(BIS_debug_s.nextval,6,'0'),1,8) || '.BIS'
          into G_FILE
          from dual;
          G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'w');
       end if;
       rtn_val := G_DIR || '/' || g_file;
    else
       G_DEBUG_MODE := 'TABLE';
       rtn_val := null;
    end if;
    return(rtn_val);
Exception when others then
    G_DEBUG_MODE := 'TABLE';
    rtn_val := null;
    return(rtn_val);
End;
PROCEDURE Initialize
IS
BEGIN

G_Debug_tbl.DELETE;
G_Debug_count := 0;
G_Debug_index := 0;

END Initialize;

Procedure Debug_ON
IS
Begin
  BIS_DEBUG_PUB.G_DEBUG := FND_API.G_TRUE;
End Debug_On;

Procedure Debug_OFF
IS
Begin
  BIS_DEBUG_PUB.G_DEBUG := FND_API.G_FALSE;
End Debug_Off;

Function ISDebugOn
Return Boolean IS
Begin
  if BIS_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE then
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;
End ISDebugOn;
--  FUNCTION    Count_Debug
--
--  Usage       Used by API callers and developers to find the count
--              of Debugs in the  message list.
--  Desc        Returns the value of G_Debug_count
--
--  Parameters  None
--
--  Return      NUMBER

FUNCTION CountDebug         RETURN NUMBER
IS
BEGIN

    RETURN G_Debug_Count;

END CountDebug;

--  PROCEDURE   Add
--
--  Usage       Used to add Debugs to the global message table.
--
--

PROCEDURE Add(debug_msg in Varchar2, debug_level in Number default 1)
IS
BEGIN
  if (G_Debug_Level >= debug_level) then
    if (ISDebugOn) then
      if debug_msg is not null then
	 if G_DEBUG_MODE = 'TABLE' then
	     --  Increment Debug count
	     G_Debug_count := G_debug_count + 1;
	     --  Write Debug.
	     G_Debug_tbl(G_debug_count) := substr(debug_msg,1,G_DEBUG_LEN);
	  else -- debug mode
	     utl_file.put_line(G_FILE_PTR, debug_msg);
	     utl_file.fflush(G_FILE_PTR);
	  end if;
      end if; -- debug_msg is not null
    end if; -- debug on
  end if;-- debug level is big enough
Exception
 WHEN OTHERS then
     if g_debug_mode = 'TABLE' then
      G_DEBUG_COUNT := G_DEBUG_COUNT - 1;
     end if;
      debug_off; -- Internal exception turn the debug off
END add; -- Add

Procedure GetFirst(Debug_msg out Varchar2)
IS
BEGIN
  resetindex;
 if G_DEBUG_COUNT <> 0 then
    debug_msg := G_DEbug_tbl(1);
    g_debug_index := 1;
 else
   debug_msg := null;
 end if;
Exception when others then
   debug_msg := null;
END GetFirst;

Procedure GetNext(debug_msg out varchar2) is
Begin
   if g_debug_count > g_debug_index then
      g_debug_index := g_debug_index + 1;
       debug_msg := G_Debug_tbl(g_debug_index);
   else
     debug_msg := null;
   end if;
Exception when others then
   debug_msg := null;
End GetNext;

Function ISLastMsg
return number is
Begin
  if g_debug_count <= g_debug_index then
     return(1);
  else
     return(0);
  end if;
End ISLastMsg;

PROCEDURE    DumpDebug
IS
i number := 0;
BEGIN
dbms_output.enable(100000);
   for i in 1..g_debug_count loop
--      dbms_output.put_line('Number : '|| to_char(i) || ' :: ' ||
--                              G_debug_tbl(i));
      NULL;
   end loop;
END DumpDebug;

Procedure GetNextBuffer(p_debug_msg in out varchar2) is
msg_str varchar2(2000);
i number;
x_buffer_len number := 0;
x_msg_len   number := 0;
x_prev_index number;
x_msg_count number := 1;
begin
p_debug_msg := '';

 if G_DEBUG_COUNT > 0 and g_debug_index < g_debug_count then
    loop
    x_prev_index := g_debug_index;
    x_msg_len := length(G_DEbug_tbl(g_debug_index+1));

      if (x_buffer_len + x_msg_len) < 1900 and x_msg_count <40 then
          g_debug_index := g_debug_index + 1;
          x_msg_count := x_msg_count + 1;
--          p_debug_msg := p_debug_msg || chr(10) || G_DEBUG_TBL(g_debug_index);
          p_debug_msg := p_debug_msg || fnd_global.local_chr(10) || G_DEBUG_TBL(g_debug_index);
          p_debug_msg := p_debug_msg || ' ' || G_DEBUG_TBL(g_debug_index);
          x_buffer_len := x_buffer_len + x_msg_len;
      else
        exit;
      end if;
      if (g_debug_index >= g_debug_count) or x_prev_index = g_debug_index then
         exit;
      end if;
    end loop;
 end if;
end;

Procedure ResetIndex is
begin
  g_debug_index := 0;
end;

Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  BIS_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
End SetDebugLevel;

END BIS_DEBUG_PUB;

/

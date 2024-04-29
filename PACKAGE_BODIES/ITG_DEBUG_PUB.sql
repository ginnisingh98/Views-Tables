--------------------------------------------------------
--  DDL for Package Body ITG_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_DEBUG_PUB" AS
/* $Header: ITGDBGB.pls 120.0 2005/12/22 04:19:26 bsaratna noship $ */


Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2 IS
rtn_val   Varchar2(100);
Begin
    if P_MODE = 'FILE' then
       G_DEBUG_MODE := 'FILE';
       if G_FILE is null then
          select substr('itg-' || to_char(sysdate,'dd-mon-yyyy') || '-' || lpad(cln_debug_s.nextval,6,'0'),1,22) || '.dbg'
          into G_FILE
          from dual;
          G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'a');
       end if;
       rtn_val := G_DIR || '/' || g_file;
    elsif P_MODE = 'CONC' then
       G_DEBUG_MODE := 'CONC';
       rtn_val := null;
    else
       G_DEBUG_MODE := 'TABLE';
       rtn_val := null;
    end if;
    debug_on;
    --SetDebugLevelFromProfile;
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
  G_DEBUG := FND_API.G_TRUE;
End Debug_On;


Procedure Debug_OFF
IS
Begin
  G_DEBUG := FND_API.G_FALSE;
End Debug_Off;


Function ISDebugOn
Return Boolean IS
Begin
  if G_DEBUG = FND_API.G_TRUE then
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;
End ISDebugOn;


FUNCTION GetDebugCount
RETURN NUMBER
IS
BEGIN
    RETURN G_Debug_Count;
END GetDebugCount;


--  PROCEDURE   Add
--
--  Usage       Used to add Debugs to the global message table.

PROCEDURE Add(p_debug_msg in Varchar2, p_debug_level in Number)
IS
        l_fname VARCHAR2(80);
        l_debug_msg     VARCHAR2(2000);
        l_g_miss_char   VARCHAR2(12) := FND_API.G_MISS_CHAR;
        l_replace       VARCHAR2(12) := ' G_MISS_CHAR';
        l_file          VARCHAR2(255);

BEGIN

  IF G_DEBUG_LEVEL IS NULL THEN
         SetDebugLevelFromProfile;
  END IF;
  -- kkram -- not sure about the following block. To check later...
  /*if not ISDebugOn then
         if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 then
            l_fname := set_debug_mode('CONC');
         else
            l_fname := set_debug_mode('FILE');
         end if;
  end if;*/
  if (p_debug_level >= G_Debug_Level) then
    --if (ISDebugOn) then
      if p_debug_msg is not null then
          if G_DEBUG_MODE = 'TABLE' then
             --  Increment Debug count
             G_Debug_count := G_debug_count + 1;
             --  Write Debug.
             G_Debug_tbl(G_debug_count) := substr(p_debug_msg,1,G_DEBUG_LEN);

          elsif G_DEBUG_MODE = 'CONC' then /* Concurrent program mode.
                        Write to concurrent pgm output file and debug log file */
           l_debug_msg := substr(replace(to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')||':'||p_debug_level||': '||p_debug_msg,l_g_miss_char,l_replace),1,2000);
             FND_FILE.put_line(FND_FILE.LOG, l_debug_msg);
           if G_FILE is not null then
                utl_file.put_line(G_FILE_PTR, p_debug_msg);
                utl_file.fflush(G_FILE_PTR);
           end if;
          else -- debug mode is FILE
             l_debug_msg := substr(replace(to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')||':'||p_debug_level||': '||p_debug_msg,l_g_miss_char,l_replace),1,2000);
             IF G_FILE is null THEN
                 l_file :=ITG_DEBUG_PUB.Set_Debug_Mode('FILE');
             END IF;
             utl_file.put_line(G_FILE_PTR, l_debug_msg);
             utl_file.fflush(G_FILE_PTR);
          end if;
      end if; -- p_debug_msg is not null
    --end if; -- debug on
  end if;-- debug level is big enough
Exception
 WHEN OTHERS then
     if g_debug_mode = 'TABLE' then
       G_DEBUG_COUNT := G_DEBUG_COUNT - 1;
     end if;
     debug_off; -- Internal exception turn the debug off
END add; -- Add


Procedure GetFirst(Debug_msg OUT NOCOPY Varchar2)
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


Procedure GetNext(debug_msg OUT NOCOPY varchar2) is
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


Procedure GetNextBuffer(p_debug_msg in OUT NOCOPY varchar2) is
msg_str varchar2(500);
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
      if (x_buffer_len + x_msg_len) < 2000 and x_msg_count <40 then
          g_debug_index := g_debug_index + 1;
          x_msg_count := x_msg_count + 1;
          p_debug_msg := p_debug_msg || fnd_global.local_chr(10) || G_DEBUG_TBL(g_debug_index);
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


Procedure SetDebugLevelFromProfile
IS
Begin
  G_Debug_Level   := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '0'));
Exception
  WHEN OTHERS THEN
    G_DEBUG_LEVEL := 5;
End SetDebugLevelFromProfile;

Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  G_DEBUG_LEVEL := p_debug_level;
Exception
  WHEN OTHERS THEN
    G_DEBUG_LEVEL := 5;
End SetDebugLevel;

END ITG_DEBUG_PUB;

/

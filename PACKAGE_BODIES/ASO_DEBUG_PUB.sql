--------------------------------------------------------
--  DDL for Package Body ASO_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEBUG_PUB" as
/* $Header: asoidbgb.pls 120.1.12010000.2 2009/10/29 14:59:11 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2 IS
rtn_val   Varchar2(100);
l_dbgfile_number number;
Begin


    if P_MODE = 'FILE' then

       G_DEBUG_MODE := 'FILE';
       OE_DEBUG_PUB.G_DEBUG_MODE := 'FILE';
       if G_FILE is null then
	  --IF (ASO_DEBUG_PUB.G_FILE is NULL OR ASO_DEBUG_PUB.G_FILE <> 'ASO'||FND_GLOBAL.USER_NAME||'.dbg') Then
          select aso_debug_file_s.nextval
          into l_dbgfile_number
          from dual;

		G_FILE := substr('l'|| substr(to_char(sysdate,'MI'),1,1)
				|| lpad(l_dbgfile_number,6,'0'),1,8)
				|| fnd_global.user_name
				|| '.dbg';

          G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'a');
	oe_debug_pub.G_FILE_PTR := G_FILE_PTR;
       end if;
       rtn_val := G_DIR || '/' || g_file;
    elsif P_MODE = 'CONC' then
       --G_DEBUG_MODE := 'CONC';
       rtn_val := null;
    else
       --G_DEBUG_MODE := 'TABLE';
       rtn_val := null;
    end if;

    aso_debug_pub.setdebuglevel(G_Debug_Level);
    aso_debug_pub.debug_on;

    return(rtn_val);
 Exception when others then
    G_DEBUG_MODE := 'FILE';
    --rtn_val := null;
    return(rtn_val);
End;


PROCEDURE Initialize
IS
BEGIN

G_Debug_tbl.DELETE;
G_Debug_count := 0;
G_Debug_index := 0;

OE_DEBUG_PUB.G_Debug_tbl.DELETE;
OE_DEBUG_PUB.G_Debug_count := 0;
OE_DEBUG_PUB.G_Debug_index := 0;
OE_DEBUG_PUB.G_DIR  := ASO_DEBUG_PUB.G_DIR;
OE_DEBUG_PUB.G_FILE  := ASO_DEBUG_PUB.G_FILE;

END Initialize;


Procedure Debug_ON
IS
Begin
  ASO_DEBUG_PUB.G_DEBUG := FND_API.G_TRUE;
  -- bug 9040436
  if  OE_DEBUG_PUB.G_DEBUG= FND_API.G_FALSE then
    OE_DEBUG_PUB.G_DEBUG := FND_API.G_TRUE;
  end if;
End Debug_On;


Procedure Debug_OFF
IS
Begin
  ASO_DEBUG_PUB.G_DEBUG := FND_API.G_FALSE;
  OE_DEBUG_PUB.G_DEBUG := FND_API.G_FALSE;
End Debug_Off;


Function ISDebugOn
Return Boolean IS
Begin
  if ASO_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE then
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

PROCEDURE Add(debug_msg in Varchar2, debug_level in Number := 1, print_date in varchar2 := 'N' )
IS
	l_fname	VARCHAR2(80);
	l_date  varchar2(80);

BEGIN


   if ASO_DEBUG_PUB.G_FILE = 'OFF' then
      return;
   end if;

   if ASO_DEBUG_PUB.G_FILE is null then
       if nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N') = 'Y' then
           aso_debug_pub.SetDebugLevel(10);
           l_fname := set_debug_mode('FILE');
           -- I could not test this, But this is the problem. This should be set after
           -- set_debug_mode call, other G_FILE will be null
           OE_DEBUG_PUB.G_DIR  := ASO_DEBUG_PUB.G_DIR;
           OE_DEBUG_PUB.G_FILE  := ASO_DEBUG_PUB.G_FILE;
           utl_file.put_line(G_FILE_PTR, 'Hello Sir, U have Opened a New Session');
       else
           ASO_DEBUG_PUB.G_FILE := 'OFF';
           return;
       end if;
   end if;


   if G_Debug_Level > 0 then
      /*
      if NOT ISDebugOn then
	     if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 then
	         l_fname := set_debug_mode('CONC');
	     else
	         l_fname := set_debug_mode('FILE');
	     end if;
      end if;
      */ -- Commented OUT for bug 1990541.

      if (G_Debug_Level >= debug_level) then
          if (ISDebugOn) then
              if debug_msg is not null then
	             if G_DEBUG_MODE = 'TABLE' then
	                 -- Increment Debug count
	                 G_Debug_count := G_debug_count + 1;
	                 -- Write Debug.
	                 G_Debug_tbl(G_debug_count) := substr(debug_msg,1,G_DEBUG_LEN);
	             elsif G_DEBUG_MODE = 'CONC' then /* Concurrent program mode.
			                                       Write to the table, concurrent pgm output file and
                                                      also to the debug log file */
	                 G_Debug_count := G_debug_count + 1;
	                 G_Debug_tbl(G_debug_count) := substr(debug_msg,1,G_DEBUG_LEN);
	                 FND_FILE.put_line(FND_FILE.LOG, debug_msg);
                      if G_FILE is not null then
	                     utl_file.put_line(G_FILE_PTR, debug_msg);
	                     utl_file.fflush(G_FILE_PTR);
                      end if;
	             else -- debug mode
		            if print_date = 'Y' then
	                     --utl_file.put_line(G_FILE_PTR, debug_msg  ||'  ' || to_char( sysdate, 'DD-MON-YYYY HH:MI:SS' )  );
	                     utl_file.put_line(G_FILE_PTR, to_char( sysdate,'DD-MON-YYYY HH:MI:SS') || ' ASO ' || debug_msg );
	                     utl_file.fflush(G_FILE_PTR);
		            else
	                     --utl_file.put_line(G_FILE_PTR, debug_msg);
	                     utl_file.put_line(G_FILE_PTR, 'ASO ' || debug_msg );
	                     utl_file.fflush(G_FILE_PTR);
		            end if;
	             end if;
              end if; -- debug_msg is not null
          end if; -- debug on
      end if;-- debug level is big enough
   end if;

   EXCEPTION
        WHEN OTHERS then
            if g_debug_mode IN ('TABLE','CONC') then
                G_DEBUG_COUNT := G_DEBUG_COUNT - 1;
            end if;
            debug_off; -- Internal exception turn the debug off

END add;


Procedure GetFirst(Debug_msg OUT NOCOPY /* file.sql.39 change */  Varchar2)
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


Procedure GetNext(debug_msg OUT NOCOPY /* file.sql.39 change */  varchar2) is
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
--dbms_output.enable(100000);
   for i in 1..g_debug_count loop
      --dbms_output.put_line('Number : '|| to_char(i) || ' :: ' ||
                              --G_debug_tbl(i));
	null;
   end loop;
END DumpDebug;


Procedure GetNextBuffer(p_debug_msg IN OUT NOCOPY /* file.sql.39 change */  varchar2) is
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


Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  ASO_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
  OE_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
End SetDebugLevel;

procedure disable_debug_pvt is
begin
   ASO_DEBUG_PUB.Debug_off;
   ASO_DEBUG_PUB.G_FILE := null;
   OE_DEBUG_PUB.Debug_off;
   OE_DEBUG_PUB.G_FILE := null;
   If utl_file.is_Open(ASO_DEBUG_PUB.G_FILE_PTR) Then
      utl_file.fclose(ASO_DEBUG_PUB.G_FILE_PTR);
   End If;
exception
  When Others Then
   null;
end;

END ASO_DEBUG_PUB;

/

--------------------------------------------------------
--  DDL for Package Body OE_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEBUG_PUB" AS
/* $Header: OEXPDBGB.pls 120.0.12010000.3 2009/06/24 05:12:49 vbkapoor ship $ */


Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2 IS
rtn_val   Varchar2(100);
Begin
    if P_MODE = 'FILE' then
       G_DEBUG_MODE := 'FILE';
       if G_FILE is null then
          select substr('l'|| substr(to_char(sysdate,'MI'),1,1)
                 || lpad(oe_debug_s.nextval,6,'0'),1,8) || '.dbg'
          into G_FILE
          from dual;
          G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'w');
          UTL_FILE.Put_Line(G_FILE_PTR,'Session Id:'||userenv('SESSIONID'));

          -- Start Other Debuggers.

          WSH_DEBUG_INTERFACE.Start_Debugger
                         (p_dir_name       =>         G_DIR,
                          p_file_name      =>         G_FILE,
                          p_file_handle    =>         G_FILE_PTR);

          INV_DEBUG_INTERFACE.Start_INV_Debugger
                         (p_dir_name       =>         G_DIR,
                          p_file_name      =>         G_FILE,
                          p_file_handle    =>         G_FILE_PTR);
       end if;
       rtn_val := G_DIR || '/' || g_file;
    elsif P_MODE = 'CONC' then
       G_DEBUG_MODE := 'CONC';
       rtn_val := null;
       WSH_DEBUG_INTERFACE.Start_Debugger
                         (p_dir_name       =>         NULL,
                          p_file_name      =>         NULL,
                          p_file_handle    =>         NULL);

       INV_DEBUG_INTERFACE.Start_INV_Debugger
                         (p_dir_name       =>         NULL,
                          p_file_name      =>         NULL,
                          p_file_handle    =>         NULL);
    else
       G_DEBUG_MODE := 'TABLE';
       rtn_val := null;
    end if;

    BEGIN
         oe_debug_pub.setdebuglevel(G_Debug_Level);
    EXCEPTION

       WHEN OTHERS THEN

		OE_DEBUG_PUB.G_DEBUG_LEVEL := 0;
          oe_debug_pub.setdebuglevel(G_Debug_Level);

    END;
    -- oe_debug_pub.debug_on; -- Commented for bug 7231197

    if nvl(fnd_profile.value('CONC_REQUEST_ID'),-1) <> -1 then -- added for bug 7231197
      oe_debug_pub.debug_on;
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
  OE_DEBUG_PUB.G_DEBUG := FND_API.G_TRUE;
End Debug_On;


Procedure Debug_OFF
IS
Begin
  OE_DEBUG_PUB.G_DEBUG := FND_API.G_FALSE;
End Debug_Off;


Function ISDebugOn
Return Boolean IS
Begin
  if OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE then
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

--  PROCEDURE   Add_Debug_Msg
--
--  Usage       Used to add Debugs to the global message table.

PROCEDURE Add_Debug_Msg(debug_msg in Varchar2, debug_level in Number default 5)
IS
	l_fname	VARCHAR2(80);
	l_debug_msg	VARCHAR2(2000);
	l_g_miss_char	VARCHAR2(12) := FND_API.G_MISS_CHAR;
	l_replace	VARCHAR2(12) := ' G_MISS_CHAR';
BEGIN

   if NOT OE_GLOBALS.G_UI_FLAG then
   if NOT ISDebugOn then

	 if nvl(fnd_profile.value('CONC_REQUEST_ID'),-1) <> -1 then

	    l_fname := set_debug_mode('CONC');
	 else
	    l_fname := set_debug_mode('FILE');
	 end if;

   end if;
   end if;

  if (G_Debug_Level >= debug_level) then
    if (ISDebugOn) then
      if debug_msg is not null then
	  if G_DEBUG_MODE = 'TABLE' then
	     --  Increment Debug count
	     G_Debug_count := G_debug_count + 1;
	     --  Write Debug.
	     G_Debug_tbl(G_debug_count) := substr(debug_msg,1,G_DEBUG_LEN);

	  elsif G_DEBUG_MODE = 'CONC' then /* Concurrent program mode.
			Write to the table, concurrent pgm output file and
                        also to the debug log file */
--	     G_Debug_count := G_debug_count + 1;
--	     G_Debug_tbl(G_debug_count) := substr(debug_msg,1,G_DEBUG_LEN);
             l_debug_msg := substr(replace(debug_msg,l_g_miss_char,l_replace),1,2000);
	     FND_FILE.put_line(FND_FILE.LOG, l_debug_msg);
             if G_FILE is not null then
	        utl_file.put_line(G_FILE_PTR, debug_msg);
	        utl_file.fflush(G_FILE_PTR);
             end if;
	  else -- debug mode
             l_debug_msg := substr(replace(debug_msg,l_g_miss_char,l_replace),1,2000);
	     utl_file.put_line(G_FILE_PTR, l_debug_msg);
	     utl_file.fflush(G_FILE_PTR);
	  end if;
      end if; -- debug_msg is not null
    end if; -- debug on
  end if;-- debug level is big enough

Exception
 WHEN OTHERS then
     if g_debug_mode IN ('TABLE','CONC') then
      G_DEBUG_COUNT := G_DEBUG_COUNT - 1;
     end if;
     debug_off; -- Internal exception turn the debug off
END add_debug_msg; -- Add

--  PROCEDURE   Add
--
--  Usage       Used to add Debugs to the global message table.

PROCEDURE Add(debug_msg in Varchar2, debug_level in Number default 5)
IS
BEGIN

  --
  -- Bug 2325973: Eliminated all local variables and moved rest of
  -- the code to Add_Debug_Msg.
  --
  -- For the scenario when debugging is OFF (g_debug_level=0), this
  -- procedure should execute only 2 statements: 'IF G_DEBUG_LEVEL = 0'
  -- and 'RETURN'. NO FURTHER CODE OR VARIABLES SHOULD BE ADDED IN
  -- THIS PROCEDURE!
  --

  IF G_DEBUG_LEVEL = 0 THEN
     RETURN;
  ELSIF G_DEBUG_LEVEL IS NULL THEN
     G_Debug_Level   := to_number(nvl(fnd_profile.value('ONT_DEBUG_LEVEL'), '0'));
  END IF;

  IF G_Debug_Level > 0 THEN
     Add_Debug_Msg(debug_msg,debug_level);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.G_DEBUG_LEVEL := 0;
END Add;

Procedure GetFirst(Debug_msg out NOCOPY /* file.sql.39 change */ Varchar2)
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


Procedure GetNext(debug_msg out NOCOPY /* file.sql.39 change */ varchar2) is
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


Procedure GetNextBuffer(p_debug_msg in out NOCOPY /* file.sql.39 change */ varchar2) is
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
  OE_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
Exception
  WHEN OTHERS THEN
  OE_DEBUG_PUB.G_DEBUG_LEVEL := 0;

End SetDebugLevel;


Procedure Start_ONT_Debugger
(p_directory          IN        VARCHAR2
,p_filename           IN        VARCHAR2
,p_file_handle        IN        UTL_FILE.File_Type
)
IS

BEGIN


   G_DEBUG_MODE := 'FILE';

   -- If the file pointer is passed use the same
   -- else open the file passed as parameter.

   -- Open the file if filename and directory are
   -- not null.


   IF UTL_FILE.Is_Open(p_file_handle) THEN

      G_FILE_PTR := p_file_handle;

   ELSIF p_filename is NOT NULL AND
         p_directory is NOT NULL THEN

      G_DIR   := p_directory;
      G_FILE  := p_filename;

      G_FILE_PTR := UTL_FILE.Fopen(G_DIR, G_FILE, 'w');

   END IF;

   UTL_FILE.Put_Line(G_FILE_PTR,'Session Id:'||userenv('SESSIONID'));

   BEGIN
         OE_DEBUG_PUB.Setdebuglevel(5);
   EXCEPTION
         WHEN OTHERS THEN
              OE_DEBUG_PUB.G_DEBUG_LEVEL := 0;
              OE_DEBUG_PUB.Setdebuglevel(G_Debug_Level);

    END;

    OE_DEBUG_PUB.Debug_On;

Exception
     WHEN OTHERS THEN
      NULL;

END Start_ONT_Debugger;

Procedure Stop_ONT_Debugger
IS
BEGIN
    OE_DEBUG_PUB.G_DEBUG_LEVEL := 0;
END Stop_ONT_Debugger;

END OE_DEBUG_PUB;

/

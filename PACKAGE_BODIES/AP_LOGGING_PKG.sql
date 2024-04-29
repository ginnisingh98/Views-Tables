--------------------------------------------------------
--  DDL for Package Body AP_LOGGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_LOGGING_PKG" as
/* $Header: apdologb.pls 120.3 2004/10/27 23:52:36 pjena noship $ */
                                                                         --
--                     _______
--                    |       |
--                    |       |
--                    |       |
--           _________|       |_________
--           \                         /
--            \  AP Debugging/Logging /
--             \     thru pipes      /
--              \       _____       /
--               \     |     |     /
--                \    |     |    /
--                 \___|     |___/
--                  \           /
--                   \  BEGIN  /
--                    \       /
--                     \     /
--                      \   /
--                       \ /
--                        v
--
--
-- Procedures for server side PL/SQL debugging/logging:
--
-- The following procedures enable logging through the Oracle Piping system
-- sending messages to the SGA that can be read by a different session.
-- The messages can be automatically indented respecting the nesting level
-- of the PL/SQL blocks from within they have been issued.
--
                                                                          --
                /*----------------------------*
                 | Private Objects Definition |
                 *----------------------------*/
                                                                          --
function Adjusted_Size         (MaxSize IN number)
return number
is
BEGIN
  -- Opening a pipe with potential size 60% larger than needed avoids
  -- locking issues in memory:
  return(round(MaxSize * 1.6));
END Adjusted_Size;
                                                                          --
                                                                          --
function Build_Stat_String     (SizeUsed     IN     number
                               ,MaxSize      IN     number
                               )
return varchar2
is
BEGIN
  if (maxsize > 0) then
    return (substr(to_char(nvl(SizeUsed,0),'09999'),2)||'/'||
            substr(to_char(MaxSize,'09999'),2)||'='||
            substr(to_char(100*nvl(SizeUsed,0)/MaxSize,'099'),2)||'%'
           );
  else
    return ('00000/00000=000%');  -- "Null size" string
  end if;
END Build_Stat_String;
                                                                          --
                                                                          --
procedure Send_Message_To_Pipe (PipeName     IN     varchar2
                               ,Msg          IN     varchar2
                               ,Result       OUT NOCOPY    number
                               ,StatString   OUT NOCOPY    varchar2
                               ,SizeUsed     IN OUT NOCOPY number
                               ,LinesEntered IN OUT NOCOPY number
                               )
is
                                                                          --
-- Sends a message to a named pipe, updating memory usage statistics
-- when successfully sent.
                                                                          --
  ctr             number(1)    := 2; -- Assumes not enough space in pipe
  maxsize         number(5)    := Ap_Logging_Pkg.DBG_Max_Size;
  oldsizeused     number(5)    := SizeUsed;
  oldlinesentered number(5)    := LinesEntered;
                                                                          --
BEGIN
                                                                          --
  -- Possible OUT/Success values for Result parameter:
  -- -1 (unknown error)
  --  0 (normal completion)
  --  1 (timeout error due to lock on pipe)
  --  2 (pipe full)
                                                                          --
  if (SizeUsed+length(Msg) <= maxsize) then
    dbms_pipe.pack_message(Msg);
    ctr := dbms_pipe.send_message(PipeName
                                 ,1  /* One second timeout */
                                 ,Adjusted_Size(maxsize)
                                 );
    if (ctr = 0) then
                                                                          --
      SizeUsed     := SizeUsed + length(Msg);
      LinesEntered := LinesEntered + 1;
      StatString   := Build_Stat_String(SizeUsed, maxsize);
                                                                          --
    end if;
                                                                          --
  end if;
                                                                          --
  Result := ctr;
                                                                          --
EXCEPTION
                                                                          --
  -- In case of ANY error, stop the queue and restore settings:
  when OTHERS then
    Result                               := -1; -- Unknown error
    LinesEntered                         := oldlinesentered;
    StatString                           := Build_Stat_String(oldsizeused
                                                             ,maxsize
                                                             );
    Ap_Logging_Pkg.DBG_Currently_Logging := FALSE;
                                                                          --
END Send_Message_To_Pipe;
                                                                          --
procedure Pop_One_Level
is
  ctr number := length(Ap_Logging_Pkg.DBG_Debug_Stack);
BEGIN
  if (
      (Ap_Logging_Pkg.DBG_Message_Level > 0)
      and
      (instr(Ap_Logging_Pkg.DBG_Debug_Stack,'+') > 0)
     ) then
    while (ctr > 0) loop
      exit when (substr(Ap_Logging_Pkg.DBG_Debug_Stack, ctr, 1) = '+');
      ctr := ctr - 1;
    end loop;
    Ap_Logging_Pkg.DBG_Debug_Stack := replace(Ap_Logging_Pkg.DBG_Debug_Stack
                                             ,substr
                                              (Ap_Logging_Pkg.DBG_Debug_Stack
                                              ,ctr
                                              )
                                             ,''
                                             );
    Ap_Logging_Pkg.DBG_Message_Level := Ap_Logging_Pkg.DBG_Message_Level - 1;
  end if;
END Pop_One_Level;
                                                                          --
procedure Push_One_Level (P_Message_Location IN varchar2)
is
BEGIN
  Ap_Logging_Pkg.DBG_Debug_Stack   := Ap_Logging_Pkg.DBG_Debug_Stack||
                                      '+'||P_Message_Location;
  Ap_Logging_Pkg.DBG_Message_Level := Ap_Logging_Pkg.DBG_Message_Level + 1;
END Push_One_Level;
                                                                          --
function Get_Location_Level (P_Message_Location IN varchar2)
return number
is
  ctr number;
  lvl number         := Ap_Logging_Pkg.DBG_Message_Level;
  stk varchar2(5000) := Ap_Logging_Pkg.DBG_Debug_Stack;
BEGIN
  if (
      (lvl > 0)
      and
      (instr(stk, '+') > 0)
      and
      (instr(stk, P_Message_Location) > 0)
     ) then
    while (lvl > 0) loop
      ctr := length(stk);
      while (
             (ctr > 0)
             and
             (instr(stk, '+') > 0)
            ) loop
        exit when (substr(stk, ctr, 1) = '+');
        ctr := ctr - 1;
      end loop;
      stk := replace(stk, substr(stk,ctr), '');
      exit when (instr(nvl(stk,'+'), P_Message_Location) = 0);
      lvl := lvl - 1;
    end loop;
  else
    lvl := 0;
  end if;
                                                                          --
  return(lvl);
                                                                          --
END Get_Location_Level;
                                                                          --
                                                                          --
                /*---------------------------*
                 | Public Objects Definition |
                 *---------------------------*/
                                                                          --
procedure Ap_Begin_Log (P_Calling_Module IN     varchar2
                       ,P_Max_Size       IN     number
                       )
is
/*
   Copyright (c) 1995 by Oracle Corporation

   NAME
     Ap_Begin_Log
   DESCRIPTION
     This opens a piping area in memory for debugging/logging purposes
   NOTES
     Procedure to be conditionally executed from the application firing
     the PL/SQL object
   HISTORY                            (YY/MM/DD)
     atassoni.it                       95/07/05  Creation
*/
                                                                          --
  session_name      varchar2(30)   := dbms_pipe.unique_session_name;
  header_message    varchar2(2000) := '>> Opened '||session_name||
                                      ' for '||P_Calling_Module||
                                      ' on '||
                                      to_char(sysdate,'Mon dd hh24:mi:ss')||
                                      ' - size: '||to_char(P_Max_Size);
                                                                          --
BEGIN
                                                                          --
  -- Start clearing old messages under the same pipe, if present
  dbms_pipe.purge(session_name);
                                                                          --
  -- Set the logging packaged variables:
  Ap_Logging_Pkg.DBG_Pipe_Name         := session_name;
  Ap_Logging_Pkg.DBG_Max_Size          := P_Max_Size;
  Ap_Logging_Pkg.DBG_Used_Size         := 0;
  Ap_Logging_Pkg.DBG_Lines_Entered     := 0;
  Ap_Logging_Pkg.DBG_Message_Level     := 0;
  Ap_Logging_Pkg.DBG_Debug_Stack       := null;
  Ap_Logging_Pkg.DBG_Currently_Logging := TRUE;
                                                                          --
  -- Initiates the pipe inserting the header as first message:
  Send_Message_To_Pipe (session_name
                       ,header_message
                       ,Ap_Logging_Pkg.DBG_Log_Return_Code
                       ,Ap_Logging_Pkg.DBG_Stat
                       ,Ap_Logging_Pkg.DBG_Used_Size
                       ,Ap_Logging_Pkg.DBG_Lines_Entered
                       );
                                                                          --
EXCEPTION
                                                                          --
  when OTHERS then
    Ap_Logging_Pkg.DBG_Pipe_Name         := session_name;
    Ap_Logging_Pkg.DBG_Max_Size          := 0;
    Ap_Logging_Pkg.DBG_Used_Size         := 0;
    Ap_Logging_Pkg.DBG_Lines_Entered     := 0;
    Ap_Logging_Pkg.DBG_Message_Level     := 0;
    Ap_Logging_Pkg.DBG_Debug_Stack       := null;
    Ap_Logging_Pkg.DBG_Log_Return_Code   := -1;
    Ap_Logging_Pkg.DBG_Stat              := Build_Stat_String(0,0);
    Ap_Logging_Pkg.DBG_Currently_Logging := FALSE;
                                                                          --
END Ap_Begin_Log;
                                                                          --
                                                                          --
procedure Ap_End_Log
is
/*

   Copyright (c) 1995 by Oracle Corporation

   NAME
     Ap_End_Log
   DESCRIPTION
     This procedure issues the close message to the piping area in memory
     identified by the actual value of Ap_Logging_Pkg.DBG_Pipe_Name
   NOTES
     Procedure to be conditionally executed from the application firing
     the PL/SQL object
   HISTORY                            (YY/MM/DD)
     atassoni.it                       95/07/05  Creation
*/
                                                                          --
  footer_message varchar2(240)   := '<< Closed '||
                                    Ap_Logging_Pkg.DBG_Pipe_Name||
                                    ' on '||
                                    to_char(sysdate,'Mon dd hh24:mi:ss')||
                                    ' - used: ';
BEGIN
                                                                          --
  footer_message := footer_message||Build_Stat_String
                                    (Ap_Logging_Pkg.DBG_Used_Size+
                                     length(footer_message)+16
                                    ,Ap_Logging_Pkg.DBG_Max_Size
                                    );
                                                                          --
  -- Terminates the pipe trying to insert the footer as last message:
  Send_Message_To_Pipe (Ap_Logging_Pkg.DBG_Pipe_Name
                       ,footer_message
                       ,Ap_Logging_Pkg.DBG_Log_Return_Code
                       ,Ap_Logging_Pkg.DBG_Stat
                       ,Ap_Logging_Pkg.DBG_Used_Size
                       ,Ap_Logging_Pkg.DBG_Lines_Entered
                       );
                                                                          --
  -- Extinguish piping to this name
  Ap_Logging_Pkg.DBG_Currently_Logging := FALSE;
                                                                          --
END Ap_End_Log;
                                                                          --
                                                                          --
function Ap_Pipe_Name
return varchar2
is
BEGIN
  return (Ap_Logging_Pkg.DBG_Pipe_Name);
END Ap_Pipe_Name;
                                                                          --
                                                                          --
procedure Ap_Pipe_Name_23 (P_Pipe_name        OUT NOCOPY    varchar2)
is
BEGIN
  P_Pipe_name := Ap_Logging_Pkg.DBG_Pipe_Name;
END Ap_Pipe_Name_23;
                                                                          --
                                                                          --
function Ap_Log_Return_Code
return number
is
BEGIN
  return (Ap_Logging_Pkg.DBG_Log_Return_Code);
END Ap_Log_Return_Code;
                                                                          --
                                                                          --
procedure Ap_Begin_Block  (P_Message_Location IN     varchar2)
is
BEGIN
                                                                          --
  Push_One_Level (P_Message_Location);
  Ap_Logging_Pkg.Ap_Log ('BEGIN '||P_Message_Location, P_Message_Location);
                                                                          --
END Ap_Begin_Block;
                                                                          --
                                                                          --
procedure Ap_End_Block  (P_Message_Location IN     varchar2)
is
BEGIN
                                                                          --
  Ap_Logging_Pkg.Ap_Log ('END '||P_Message_Location, P_Message_Location);
  Pop_One_Level;
                                                                          --
END Ap_End_Block;
                                                                          --
                                                                          --
procedure Ap_Indent
is
BEGIN
                                                                          --
  Push_One_Level (to_char(Ap_Logging_Pkg.DBG_Message_Level+1));
                                                                          --
END Ap_Indent;
                                                                          --
                                                                          --
procedure Ap_Outdent
is
BEGIN
                                                                          --
  Pop_One_Level;
                                                                          --
END Ap_Outdent;
                                                                          --
                                                                          --
procedure Ap_Log          (P_Message          IN     varchar2
                          ,P_Message_Location IN     varchar2
                                                     default null
                          )

is
/*
   Copyright (c) 1995 by Oracle Corporation

   NAME
     Ap_Log
   DESCRIPTION
     This procedure sends a debug/log message to the specified pipe
     Each message is automatically indented to the right on a
     P_Message_Location basis through the current DBG_Debug_Stack value.
   NOTES
     This procedure issues the message to the piping area in memory
     identified by the actual value of Ap_Logging_Pkg.DBG_Pipe_Name

   HISTORY                            (YY/MM/DD)
     atassoni.it                       95/07/05  Creation
*/
                                                                          --
  current_level number;
  message       varchar2(5000) := P_Message;
  location      varchar2(30)   := P_Message_Location;
  NOTHING_TO_DO exception;
                                                                          --
BEGIN
                                                                          --
  if (NOT nvl(Ap_Logging_Pkg.DBG_Currently_Logging, FALSE)) then
    raise NOTHING_TO_DO;
  end if;
                                                                          --
  if (P_Message_Location is null) then
    -- No location passed in: assign a default one as level#
    if (Ap_Logging_Pkg.DBG_Debug_Stack is null) then
      location := '1';
    else
      location := to_char(Ap_Logging_Pkg.DBG_Message_Level);
    end if;
  end if;
                                                                          --
  current_level := Get_Location_Level (location);
                                                                          --
  if (current_level = 0) then
    -- The location is not in the stack. Create one more level:
    Push_One_Level (location);
  else
    -- The location is already in the stack. Bring the stack to that level:
    loop
      exit when (current_level = Ap_Logging_Pkg.DBG_Message_Level);
      Pop_One_Level;
    end loop;
  end if;
                                                                          --
  -- Insert the message at current indentation level:
  Send_Message_To_Pipe (Ap_Logging_Pkg.DBG_Pipe_Name
                       ,lpad(message
                            ,length(message)+2*Ap_Logging_Pkg.DBG_Message_Level
                            )
                       ,Ap_Logging_Pkg.DBG_Log_Return_Code
                       ,Ap_Logging_Pkg.DBG_Stat
                       ,Ap_Logging_Pkg.DBG_Used_Size
                       ,Ap_Logging_Pkg.DBG_Lines_Entered
                       );
                                                                          --
EXCEPTION
                                                                          --
  when NOTHING_TO_DO then null;
                                                                          --
END Ap_Log;
                                                                          --
--                     _______
--                    |       |
--                    |       |
--                    |       |
--           _________|       |_________
--           \                         /
--            \  AP Debugging/Logging /
--             \     thru pipes      /
--              \                   /
--        ___________   ___       __   ___________
--       / _________/  / . \     / /  / _________ \
--      / /______  \  / / \ \   / /  / /        / /
--     / _______/   \/ /   \ \ / /  / /        / /
--    / /_________  / /     \ ` /  / /________/ /
--   /___________/ /_/       \_/  /___________,'
--                     \     /
--                      \   /
--                       \ /
--                        v
                                                                          --
                                                                          --
end AP_LOGGING_PKG;

/

--------------------------------------------------------
--  DDL for Package Body FA_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEBUG_PKG" as
/* $Header: FADEBUGB.pls 120.4.12010000.3 2010/02/05 09:29:13 spooyath ship $ */

-- GLOBAL VARIABLES
--
-- Debug_Rec_Type  : Record to store debug messages
--
-- fname           : calling function name
--
-- data            : debug message
--

g_log_statement_level      CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_log_procedure_level      CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_log_event_level          CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT ;
g_log_exception_level      CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
g_log_error_level          CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
g_log_unexpected_level     CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_log_runtime_level        NUMBER            := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

g_calling_routine          varchar2(150);
g_release                  number            :=  fa_cache_pkg.fazarel_release;

TYPE  Debug_Rec_Type IS RECORD
(       fname           VARCHAR2(30)    := NULL,
        data            VARCHAR2(225)   := NULL
);

-- Debug_Tbl_Type  : A global table to store all debug messages
--
TYPE Debug_Tbl_Type IS TABLE OF Debug_Rec_Type
 INDEX BY BINARY_INTEGER;

FA_DEBUG_TABLE          Debug_Tbl_Type;

-- Index used to keep track of the last fetched

FA_DEBUG_INDEX          NUMBER  := 0;

-- Global variable holding the message count

FA_DEBUG_COUNT          NUMBER  := 0;

-- Global variable holding debug flag

FA_DEBUG_FLAG           varchar2(3) := 'NO';
FA_DEBUG_FILE           varchar2(3) := 'NO';

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

-- Procedure    Initialize
--
-- Usage        Used by server program to intialize the global
--              debug message table and set the debug flag
--

PROCEDURE Initialize IS

   l_request_id NUMBER;
   l_dir VARCHAR2(200);
   l_file VARCHAR2(200);
   l_dirfile VARCHAR2(200);

BEGIN

   --if fnd_profile.value('PRINT_DEBUG') = 'Y' then
   if (g_print_debug) then
      FA_DEBUG_FLAG := 'YES';
   end if;

   FA_DEBUG_TABLE.DELETE;
   FA_DEBUG_COUNT := 0;
   FA_DEBUG_INDEX := 0;

   --
   -- Initialization for debugging to a file
   --
   if fa_debug_flag <> 'YES' then
      -- File Debugging should only be enabled if PRINT_DEBUG is also enabled
      fa_debug_file := 'NO';

   elsif fa_debug_file <> 'YES' then
      -- Also, only initialize file debugging once

      l_dirfile := fa_cache_pkg.fa_debug_file;
      if l_dirfile is not null then

         -- Do not set up file/dir info if this is a concurrent program
         -- FND_FILE will automatically place the debug messages to
         -- the concurrent program's log file.
         --l_request_id := to_number(fnd_profile.value('CONC_REQUEST_ID'));
         l_request_id := fnd_global.conc_request_id;

         if l_request_id is null or l_request_id <= 0 then
            l_dir := substr(l_dirfile, 1, instr(l_dirfile, ' ')-1);
            l_file := substr(l_dirfile, instr(l_dirfile, ' ')+1);
            if l_dir is not null and l_file is not null then
                 fnd_file.put_names(l_file||'.log', l_file||'.out', l_dir);
            end if;
         end if;

         fa_debug_file := 'YES';
         fnd_file.put_line(fnd_file.log, 'Starting debug session....');

      end if;
   end if;
END Initialize;


-- Function     Print_Debug
--
-- Usage        Used by server program to check the debug flag
--

FUNCTION Print_Debug RETURN BOOLEAN IS
BEGIN

    return (FA_DEBUG_FLAG = 'YES');

END Print_Debug;


-- Procedure    Add
--
-- Usage        Used by server programs to add debug message to
--              debug message table
--
-- Desc         This procedure is oeverloaded.
--              There are four datatypes differing in Value parameter:
--                 Base :
--                      Value   VARCHAR2
--                 first overloaded procedure :
--                      Value   NUMBER
--                 second overloaded procedure :
--                      Value   DATE
--                 fourth overloaded procedure :
--                      Value   BOOLEAN
--
PROCEDURE Add
(       fname           in      varchar2,
        element         in      varchar2,
        value           in      varchar2,
 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   debug_str       varchar2(225);

BEGIN

   debug_str := substr(element, 1, 150) || ' has the value of ' ||
                substr(value, 1, 54);

   if (g_release = 11) then

     FA_DEBUG_COUNT := FA_DEBUG_COUNT + 1;
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).fname := substr(fname, 1, 30);
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).data := debug_str;

     -- Bug 9349372 : fa_debug_table is populated only for 11i
     if fa_debug_file = 'YES' then
        fnd_file.put_line(fnd_file.Log,
                     fa_debug_table(fa_debug_count).fname || ': '||
                     fa_debug_table(fa_debug_count).data);
     end if;

   else

      g_calling_routine :=  'FA.PLSQL.'||fname;
      if (g_log_statement_level >= g_log_runtime_level) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT , g_calling_routine, debug_str);
      end if;

   end if;


EXCEPTION
   when fnd_file.utl_file_error then
        fa_debug_file := 'NO';
END Add;


PROCEDURE Add
(       fname           in      varchar2,
        element         in      varchar2,
        value           in      number,
 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   debug_str       varchar2(225);

BEGIN

   debug_str := substr(element, 1, 150) || ' has the value of ' ||
                substr(to_char(value), 1, 54);

   if (g_release = 11) then

     FA_DEBUG_COUNT := FA_DEBUG_COUNT + 1;
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).fname := substr(fname, 1, 30);
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).data := debug_str;

     -- Bug 9349372 : fa_debug_table is populated only for 11i
     if fa_debug_file = 'YES' then
        fnd_file.put_line(fnd_file.Log,
                     fa_debug_table(fa_debug_count).fname || ': '||
                     fa_debug_table(fa_debug_count).data);
     end if;

   else

      g_calling_routine :=  'FA.PLSQL.'||fname;
      if (g_log_statement_level >= g_log_runtime_level) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT , g_calling_routine, debug_str);
      end if;

   end if;

EXCEPTION
   when fnd_file.utl_file_error then
        fa_debug_file := 'NO';

END Add;


PROCEDURE Add
(       fname           in      varchar2,
        element         in      varchar2,
        value           in      date,
 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   debug_str       varchar2(225);

BEGIN

   debug_str := substr(element, 1, 150) || ' has the value of ' ||
                to_char(value, 'DD-MM-YYYY HH24:MI:SS');


   if (g_release = 11) then

     FA_DEBUG_COUNT := FA_DEBUG_COUNT + 1;
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).fname := substr(fname, 1, 30);
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).data := debug_str;

     -- Bug 9349372 : fa_debug_table is populated only for 11i
     if fa_debug_file = 'YES' then
        fnd_file.put_line(fnd_file.Log,
                     fa_debug_table(fa_debug_count).fname || ': '||
                     fa_debug_table(fa_debug_count).data);
     end if;

   else

      g_calling_routine :=  'FA.PLSQL.'||fname;
      if (g_log_statement_level >= g_log_runtime_level) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT , g_calling_routine, debug_str);
      end if;

   end if;

EXCEPTION
   when fnd_file.utl_file_error then
        fa_debug_file := 'NO';

END Add;


PROCEDURE Add
(       fname           in      varchar2,
        element         in      varchar2,
        value           in      boolean,
 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   debug_str       varchar2(225);
   l_value         varchar2(5);

BEGIN

   if (value) then
      l_value := 'TRUE';
   else
      l_value := 'FALSE';
   end if;

   debug_str := substr(element, 1, 150) || ' has the value of ' || l_value;

   if (g_release = 11) then

     FA_DEBUG_COUNT := FA_DEBUG_COUNT + 1;
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).fname := substr(fname, 1, 30);
     FA_DEBUG_TABLE(FA_DEBUG_COUNT).data := debug_str;

     -- Bug 9349372 : fa_debug_table is populated only for 11i
     if fa_debug_file = 'YES' then
        fnd_file.put_line(fnd_file.Log,
                     fa_debug_table(fa_debug_count).fname || ': '||
                     fa_debug_table(fa_debug_count).data);
     end if;

   else

      g_calling_routine :=  'FA.PLSQL.'||fname;
      if (g_log_statement_level >= g_log_runtime_level) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT , g_calling_routine, debug_str);
      end if;

   end if;

EXCEPTION
   when fnd_file.utl_file_error then
        fa_debug_file := 'NO';

END Add;


-- Procedure    Get_Debug_Messages
--
-- Usage        Used by client program to get debug messages from debug
--              table
--
PROCEDURE Get_Debug_Messages
(       d_mesg1  out nocopy varchar2,
        d_mesg2  out nocopy varchar2,
        d_mesg3  out nocopy varchar2,
        d_mesg4  out nocopy varchar2,
        d_mesg5  out nocopy varchar2,
        d_mesg6  out nocopy varchar2,
        d_mesg7  out nocopy varchar2,
        d_mesg8  out nocopy varchar2,
        d_mesg9  out nocopy varchar2,
        d_mesg10 out nocopy varchar2,
        d_more_mesgs out nocopy boolean
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_temp_str      varchar2(255) := NULL;
   l_more_mesgs    boolean := TRUE;
   l_index         number;

BEGIN


   d_mesg1 := NULL;
   d_mesg2 := NULL;
   d_mesg3 := NULL;
   d_mesg4 := NULL;
   d_mesg5 := NULL;
   d_mesg6 := NULL;
   d_mesg7 := NULL;
   d_mesg8 := NULL;
   d_mesg9 := NULL;
   d_mesg10 := NULL;
   d_more_mesgs := TRUE;

   IF (FA_DEBUG_INDEX >= FA_DEBUG_COUNT) THEN
      d_more_mesgs := FALSE;
      RETURN;
   END IF;

   WHILE l_more_mesgs LOOP

      FA_DEBUG_INDEX := FA_DEBUG_INDEX + 1;

      if (FA_DEBUG_INDEX > FA_DEBUG_COUNT) then
         l_more_mesgs := FALSE;
         EXIT;
      else

         l_temp_str := FA_DEBUG_TABLE(FA_DEBUG_INDEX).fname ;
         l_temp_str := FA_DEBUG_TABLE(FA_DEBUG_INDEX).data;

         l_temp_str := FA_DEBUG_TABLE(FA_DEBUG_INDEX).fname || ': ' ||
                       FA_DEBUG_TABLE(FA_DEBUG_INDEX).data;

         l_index := mod(FA_DEBUG_INDEX, 10);

         if (l_index = 1) then
            d_mesg1 := l_temp_str;
         elsif (l_index = 2) then
            d_mesg2 := l_temp_str;
         elsif (l_index = 3) then
            d_mesg3 := l_temp_str;
         elsif (l_index = 4) then
            d_mesg4 := l_temp_str;
         elsif (l_index = 5) then
            d_mesg5 := l_temp_str;
         elsif (l_index = 6) then
            d_mesg6 := l_temp_str;
         elsif (l_index = 7) then
            d_mesg7 := l_temp_str;
         elsif (l_index = 8) then
            d_mesg8 := l_temp_str;
         elsif (l_index = 9) then
            d_mesg9 := l_temp_str;
         else
            d_mesg10 := l_temp_str;
            l_more_mesgs := FALSE;
         end if;
      end if;
   END LOOP;

   if (FA_DEBUG_INDEX >= FA_DEBUG_COUNT) then
      d_more_mesgs := FALSE;
   end if;

EXCEPTION
    WHEN OTHERS THEN

         FA_DEBUG_TABLE.DELETE;
         FA_DEBUG_COUNT := 0;
         FA_DEBUG_INDEX := 0;
         d_mesg1 := 'Database Error: ' || SQLERRM;
         d_more_mesgs := FALSE;

END Get_Debug_Messages;


-- Procedure    Set_Debug_Flag
--
-- Usage        Used by internal deveoplers to set the debug flag
--              to 'YES'
--
PROCEDURE Set_Debug_Flag
(       debug_flag      in      varchar2 := 'YES'
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
BEGIN

   FA_DEBUG_FLAG := debug_flag;
   FA_DEBUG_TABLE.DELETE;
   FA_DEBUG_COUNT := 0;
   FA_DEBUG_INDEX := 0;

   if FA_DEBUG_FLAG = 'NO' then
       FA_DEBUG_FILE := 'NO';
   end if;

END Set_Debug_Flag;


-- Procedure    Reset_Index
--
-- Usage        Used by internal developer to move the index
--              of debug table
--
PROCEDURE Reset_Index
(       d_index         in number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
BEGIN
   if (d_index is null) then
      FA_DEBUG_INDEX := 0;
   else
      FA_DEBUG_INDEX := d_index;
   end if;

END Reset_Index;


-- Procedure    Dump_Debug_Messages
--
-- Usage        Used by internal developers to print all messages
--              of debug table
--
PROCEDURE Dump_Debug_Messages
(       target_str      in      varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
        t_count number;
BEGIN
    t_count := FA_DEBUG_TABLE.count;
    --dbms_output.put_line('Dumping Debug Messages :');
    --dbms_output.put_line('FA_DEBUG_COUNT = ' || to_char(FA_DEBUG_COUNT));
    --dbms_output.put_line('FA_DEBUG_INDEX = ' || to_char(FA_DEBUG_INDEX));
/*
    if (target_str is null) then

        FOR I IN 1..FA_DEBUG_COUNT LOOP
           dbms_output.put_line( FA_DEBUG_TABLE(I).fname || ': ' ||
                                 FA_DEBUG_TABLE(I).data);
        END LOOP;

     end if;
*/
EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('Dump_Debug_Messages : Error - ' ||  SQLERRM);
        null;
END Dump_Debug_Messages;


PROCEDURE Dump_Debug_Messages
(       max_mesgs       in      number := NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   l_debug_msg1  varchar2(255);
   l_debug_msg2  varchar2(255);
   l_debug_msg3  varchar2(255);
   l_debug_msg4  varchar2(255);
   l_debug_msg5  varchar2(255);
   l_debug_msg6  varchar2(255);
   l_debug_msg7  varchar2(255);
   l_debug_msg8  varchar2(255);
   l_debug_msg9  varchar2(255);
   l_debug_msg10 varchar2(255);
   l_more_debug_msgs   boolean;

BEGIN

   fnd_message.set_name('OFA', 'FA_SHARED_DEBUG');
   fnd_message.set_token('INFO', 'Debug');
   fnd_msg_pub.add;


   loop

      fa_debug_pkg.Get_Debug_Messages
       (d_mesg1         => l_debug_msg1,
        d_mesg2         => l_debug_msg2,
        d_mesg3         => l_debug_msg3,
        d_mesg4         => l_debug_msg4,
        d_mesg5         => l_debug_msg5,
        d_mesg6         => l_debug_msg6,
        d_mesg7         => l_debug_msg7,
        d_mesg8         => l_debug_msg8,
        d_mesg9         => l_debug_msg9,
        d_mesg10        => l_debug_msg10,
        d_more_mesgs    => l_more_debug_msgs, p_log_level_rec => p_log_level_rec);


      fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
      fnd_message.set_token('MSG1', l_debug_msg1);
      fnd_msg_pub.add;

      if l_debug_msg2 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg2);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg3 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg3);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg4 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg4);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg5 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg5);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg6 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg6);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg7 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg7);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg8 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg8);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg9 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg9);
         fnd_msg_pub.add;
      end if;
      if l_debug_msg10 is not null then
         fnd_message.set_name('OFA', 'FA_SRVR_MESSAGE_1');
         fnd_message.set_token('MSG1', l_debug_msg10);
         fnd_msg_pub.add;
      end if;

      if not l_more_debug_msgs then
         exit;
      end if;

   end loop;

EXCEPTION
  when others then
    null;

END Dump_Debug_messages;

-- Procedure Write_Debug_Log
--
PROCEDURE Write_Debug_Log
IS
   l_debug_str varchar2(255) := NULL;
BEGIN
   if (FA_DEBUG_COUNT > 0) then
      for i in 1..(FA_DEBUG_COUNT) loop
         l_debug_str := FA_DEBUG_TABLE(i).fname||':'||
                        FA_DEBUG_TABLE(i).data;
         fa_rx_conc_mesg_pkg.log(l_debug_str);
      end loop;
   end if;
END Write_Debug_Log;


END FA_DEBUG_PKG;

/

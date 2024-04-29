--------------------------------------------------------
--  DDL for Package Body FA_SRVR_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SRVR_MSG" as
/* $Header: FASMESGB.pls 120.7.12010000.2 2009/07/19 11:46:35 glchen ship $ */

g_log_statement_level      NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_log_procedure_level      NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_log_event_level          NUMBER   := FND_LOG.LEVEL_EVENT ;
g_log_exception_level      NUMBER   := FND_LOG.LEVEL_EXCEPTION;
g_log_error_level          NUMBER   := FND_LOG.LEVEL_ERROR;
g_log_unexpected_level     NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_log_runtime_level        NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

g_print_debug              boolean := fa_cache_pkg.fa_print_debug;
g_release                  number  := fa_cache_pkg.fazarel_release;

--
--  Procedure   Init_Server_Message
--
PROCEDURE Init_Server_Message IS

   l_release         number;

BEGIN
   fnd_msg_pub.initialize;

END init_server_message;


--
-- Procedure Reset_Server_Message
--
PROCEDURE Reset_Server_Message IS
BEGIN
        fnd_msg_pub.initialize;

END Reset_Server_Message;


--
-- Procedure    Add_SQL_Error
--
PROCEDURE Add_SQL_Error
(       calling_fn      in      varchar2,
        p_log_level_rec in      fa_api_types.log_level_rec_type default null) IS

BEGIN

   -- reset the global FA_ERROR_LEVEL to 1
   FA_SRVR_MSG.FA_ERROR_LEVEL := 1;

   -- insert sql error for unexpected database error to stack
   fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
   fnd_message.set_token('ORACLE_ERR',SQLERRM);

   if (g_release > 11 and
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE (FND_LOG.LEVEL_UNEXPECTED,'FA.PLSQL.'||calling_fn,FALSE);
   end if;

   fnd_msg_pub.add;

   -- insert calling function name to the stack
   add_message(calling_fn  => calling_fn,
               p_log_level_rec => p_log_level_rec);


END Add_SQL_Error;

--
--  Procedure   Add_Message
--
PROCEDURE add_message
(       calling_fn      in      varchar2,
        name            in      varchar2 := null,
        token1          in      varchar2 := null,
        value1          in      varchar2 := null,
        token2          in      varchar2 := null,
        value2          in      varchar2 := null,
        token3          in      varchar2 := null,
        value3          in      varchar2 := null,
        token4          in      varchar2 := null,
        value4          in      varchar2 := null,
        token5          in      varchar2 := null,
        value5          in      varchar2 := null,
        translate       in      boolean  := FALSE,
        application     in      varchar2 := 'OFA',
        p_log_level_rec in      fa_api_types.log_level_rec_type default null,
        p_message_level in      number := FND_LOG.LEVEL_ERROR) IS

BEGIN

   if name is not null then
      fnd_message.set_name(application, name);  --enhanced for cua
      if (token1 is not null) then
         fnd_message.set_token(token1, value1, translate);
      end if;
      if (token2 is not null) then
         fnd_message.set_token(token2, value2, translate);
      end if;
      if (token3 is not null) then
         fnd_message.set_token(token3, value3, translate);
      end if;
      if (token4 is not null) then
         fnd_message.set_token(token4, value4, translate);
      end if;
      if (token5 is not null) then
         fnd_message.set_token(token5, value5, translate);
      end if;

      if (g_release > 11 and
          p_message_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.MESSAGE (p_message_level,'FA.PLSQL.'||calling_fn,FALSE);
      end if;

      fnd_msg_pub.add;

   elsif (calling_fn is not null ) then

      if (g_release > 11 and
          g_log_procedure_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

         FND_LOG.STRING (g_log_procedure_level , 'FA.PLSQL.'||calling_fn,
                         'End of procedure');
      end if;

      -- insert calling function name to the stack if message level
      -- equals to 1 or debug flag is set in profile
      -- BMR: also check if the calling fn is null as we don't
      --      want excessive/bogus errors when debug is enabled
      --      when displaying a "success" message (bug2247611)

      if (FA_SRVR_MSG.FA_ERROR_LEVEL = 1 or
          g_log_procedure_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_message.set_name('OFA', 'FA_SHARED_ERROR_CALL');
         fnd_message.set_token('CALLING_FN', calling_fn, translate);
         fnd_msg_pub.add;
      end if;

   end if;

END add_message;

--
--  Prodedure   Get_Message
--
PROCEDURE get_message
(       mesg_count      in out nocopy  number,
        mesg1           in out nocopy  varchar2,
        mesg2           in out nocopy  varchar2,
        mesg3           in out nocopy  varchar2,
        mesg4           in out nocopy  varchar2,
        mesg5           in out nocopy  varchar2,
        mesg6           in out nocopy  varchar2,
        mesg7           in out nocopy  varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

BEGIN

   mesg_count := fnd_msg_pub.count_msg;
   mesg1 := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE), 1, 512);
   mesg2 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
   mesg3 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
   mesg4 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
   mesg5 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
   mesg6 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);
   mesg7 := substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE), 1, 512);

END Get_Message;

--
-- Procedure  Set_Message_Level
--
PROCEDURE  Set_Message_Level (
        message_level   in number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

BEGIN

   if (message_level is null) then
      FA_ERROR_LEVEL := 1;
   else
      FA_ERROR_LEVEL := message_level;
   end if;

END Set_Message_Level;


--
-- Procedure Dump_API_Messages
--
PROCEDURE Dump_API_Messages IS

   mesg_count      number;
   temp_str        varchar2(1000) := NULL;

BEGIN
   mesg_count := fnd_msg_pub.count_msg;

   if (mesg_count > 0) then
      temp_str := fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE);

      for I in 1..(mesg_count -1) loop

         temp_str := fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE);

      end loop;
   else
      null;
   end if;

EXCEPTION
   WHEN OTHERS THEN
        null;

END Dump_API_Messages;

--
-- Procedure Write_Msg_Log
--
PROCEDURE  Write_Msg_Log
(       msg_count       in number,
        msg_data        in varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

   -- For test purpose, you may set h_coded to TRUE.  Then messages will be
   -- printed out in encoded format instead of translated format.  This is useful
   -- if you want to test the message, but if you have not registered your
   -- message yet in the message dictionary.
   -- Normally h_encoded should be set to FALSE.

   h_encoded varchar2(1) := fnd_api.G_FALSE;
   --h_encoded varchar(1):= fnd_api.G_TRUE;

BEGIN
   if (msg_count <= 0) then
      NULL;
   else
      fa_rx_conc_mesg_pkg.log(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, h_encoded));
      for i in 1..(msg_count-1) loop
         fa_rx_conc_mesg_pkg.log(fnd_msg_pub.get(fnd_msg_pub.G_NEXT, h_encoded));
      end loop;
   end if;

END Write_Msg_Log;

END FA_SRVR_MSG;

/

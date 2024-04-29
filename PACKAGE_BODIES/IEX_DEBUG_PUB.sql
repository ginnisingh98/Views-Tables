--------------------------------------------------------
--  DDL for Package Body IEX_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DEBUG_PUB" as
/* $Header: iexidbgb.pls 120.2.12010000.2 2016/07/19 06:20:25 bibeura ship $ */
-- Start of Comments
-- Package name     : IEX_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


DB_NAME VARCHAR2(80) ;

PG_DEBUG NUMBER(2) ;

Function OpenFile(P_File in varchar2  ) Return Varchar2 IS
rtn_val   Varchar2(2000);
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
           --        || lpad(iex_debug_file_s.nextval,6,'0'),1,8) ||  '.IEX'
           --into G_FILE from dual;

            SELECT DB_NAME || USERENV('SESSIONID') || '.IEX' into G_FILE
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
rtn_val   Varchar2(2000);
BEGIN
      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'iex',  debug_msg );
      end if;

    --jsanju , write to file for bug 3796601
     if (G_Debug_Level <= debug_level) then
       rtn_val:=OpenFile(G_FILE);
       utl_file.put_line(G_FILE_PTR,
       to_char( sysdate, 'DD-MON-YYYY HH:MI:SS')  || ' ' || debug_msg );
       utl_file.fflush(G_FILE_PTR);
       utl_file.fclose(G_FILE_PTR);
   end if;



Exception
 WHEN OTHERS then
       null;
END LogMessage; -- LogMessage


--  PROCEDURE   SetDebugLevel
--
--  Usage       set debug level if running outside of application otherwise debuglevel
--              is taken from the profile value

Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  IEX_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
End SetDebugLevel;

BEGIN

   PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
   -- Start Bug#23560466
   -- SELECT NAME INTO DB_NAME FROM V$DATABASE;
   SELECT SYS_CONTEXT('USERENV','DB_NAME') INTO DB_NAME FROM DUAL;
   -- End Bug#23560466
   DB_NAME := DB_NAME || '_';

END IEX_DEBUG_PUB;

/

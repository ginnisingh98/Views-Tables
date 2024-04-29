--------------------------------------------------------
--  DDL for Package Body AST_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_DEBUG_PUB" as
/* $Header: astidbgb.pls 115.4 2003/01/07 19:38:35 karamach ship $ */
-- Start of Comments
-- Package name     : AST_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

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
           --        || lpad(AST_debug_file_s.nextval,6,'0'),1,8) ||  '.AST'
           --into G_FILE from dual;

            SELECT sid || '.AST'    into G_FILE
            FROM   v$session
             WHERE  audsid = Userenv('SESSIONID');

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


--  PROCEDURE  LogMessage
--
--  Usage       Used to log message to the debug  file

PROCEDURE LogMessage(debug_msg   in Varchar2,
              debug_level in Number default 1,
              print_date  in varchar2 default 'N')

IS
rtn_val   Varchar2(100);
BEGIN

  if (G_Debug_Level >= debug_level) then
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


--  PROCEDURE   SetDebugLevel
--
--  Usage       set debug level if running outside of application otherwise debuglevel
--              is taken from the profile value

Procedure SetDebugLevel(p_debug_level in number)
IS
Begin
  AST_DEBUG_PUB.G_DEBUG_LEVEL := p_debug_level;
End SetDebugLevel;



END AST_DEBUG_PUB;

/

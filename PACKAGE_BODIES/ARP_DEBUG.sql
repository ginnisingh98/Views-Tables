--------------------------------------------------------
--  DDL for Package Body ARP_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DEBUG" as
/* $Header: ARDBGMGB.pls 120.1 2006/06/09 03:54:53 mraymond noship $             */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE FLAGS                                                           |
 |                                                                         |
 | Control flags are currently held in base 10.                            |
 | PUBLIC FUNCTIONS are declared to export each of these private flags     |
 | to a SQL*ReportWriter application.                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

INT_MD_MSG_NUMBER constant number := 1;           -- Message Dictionary control
INT_MD_MSG_TEXT   constant number := 10;          -- Options
INT_MD_MSG_NAME   constant number := 100;         -- Show message name only
INT_MD_MSG_TOKENS constant number := 1000;        -- List Message Tokens and Values
INT_MD_MSG_EXPLANATION constant number := 10000;  -- Not supported yet
INT_MD_MSG_FIND_NUMBER constant number := 100000; -- Use Message Number not Name


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

 debug_flag boolean := false;

pg_file_name	VARCHAR2(100) := NULL;
pg_path_name    VARCHAR2(100) := NULL;
pg_fp		utl_file.file_type;

procedure file_debug(line in varchar2) IS
x number;
begin
  if (pg_file_name is not null) THEN
    utl_file.put_line(pg_fp, line);
    utl_file.fflush(pg_fp);
  end if;
end file_debug;



/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC FUNCTIONS                                                        |
 |                                                                         |
 +-------------------------------------------------------------------------*/

procedure enable_file_debug(path_name in varchar2,
			    file_name in varchar2) IS

x number;
begin

  if (pg_file_name is null) THEN
    pg_fp := utl_file.fopen(path_name, file_name, 'a');
    pg_file_name := file_name;
    pg_path_name := path_name;
  end if;


    exception
     when utl_file.invalid_path then
        app_exception.raise_exception;
     when utl_file.invalid_mode then
        app_exception.raise_exception;

end ;


procedure disable_file_debug is
begin
  if (pg_file_name is not null) THEN
    utl_file.fclose(pg_fp);
  end if;
end;


procedure debug( line in varchar2,
                 msg_prefix in varchar2,
                 msg_module in varchar2,
                 msg_level in  number
                  ) is
  l_msg_prefix  varchar2(64);
  l_msg_level   number;
  l_msg_module  varchar2(256);
  l_beg_end_suffix varchar2(15);
  l_org_cnt number;
  l_line varchar2(32767);

begin

     l_line := line;

     /* ----------------------------------------------------
        For file debug the messages are written both on file
        and FND tables.
     ----------------------------------------------------*/

     IF (pg_file_name IS NOT NULL) THEN
        file_debug(l_line);
     END IF;

     l_msg_prefix := 'a' || 'r' || '.' || msg_prefix || '.';

      /* EXCEPTIONS:
         -  if length of message > 99
         -  if text contains (s)
      */
      IF lengthb(l_line) > 99 OR
         INSTRB(l_line, '(s)') <> 0
      THEN
         l_msg_level := FND_LOG.LEVEL_STATEMENT;
         l_msg_module := l_msg_prefix || NVL(g_msg_module, 'UNKNOWN');

         -- This logs the message
         /* Bug 4361955 */
	 IF   ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
         THEN
        	 FND_LOG.STRING(l_msg_level, l_msg_module, substr(l_line,1,4000));
	 END IF;

         RETURN;
      END IF;

      -- set msg_level for this message
      IF (msg_level IS NULL)
      THEN
         IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_EXCEPTION;
         ELSIF (INSTRB(l_line, ')+') <> 0 OR
                INSTRB(l_line, '+)') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_PROCEDURE;
            l_beg_end_suffix := '.begin';
         ELSIF (INSTRB(l_line, ')-') <> 0 OR
                INSTRB(l_line, '-)') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_PROCEDURE;
            l_beg_end_suffix := '.end';
         ELSE
            l_msg_level := FND_LOG.LEVEL_STATEMENT;
            l_beg_end_suffix := NULL;
         END IF;
      ELSE
         /* Verify that level is between 1 and 6 */
         IF msg_level >= 1 AND msg_level <= 6
         THEN
            l_msg_level := msg_level;
         ELSE
            /* Invalid message level, default 1 */
            l_msg_level := 1;
         END IF;
      END IF;

      -- set module for this message
      IF (msg_module IS NULL)
      THEN

         -- chop off extraneous stuff on right end of string
         l_msg_module := SUBSTRB(RTRIM(l_line), 1,
                                INSTRB(l_line, '(') - 1);

         -- chop off extraneous stuff on left
         l_msg_module := SUBSTRB(l_msg_module,
                             INSTRB(l_msg_module, ' ', -3 ) + 1);

            /* If we were unable to get a module name, use
               the global (previously stored)  one */
            IF l_msg_module IS NULL
            THEN
               l_msg_module := NVL(g_msg_module, 'UNKNOWN');
            ELSE
               g_msg_module := l_msg_module;
            END IF;

         l_msg_module := l_msg_prefix || l_msg_module || l_beg_end_suffix;
      ELSE
         l_msg_module := l_msg_prefix || msg_module;
      END IF;

      -- This actually logs the message
	  /* Bug 4361955 */
	 IF (  l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
         THEN
	      FND_LOG.STRING(l_msg_level, l_msg_module, l_line);
	 END IF;


exception
  when others then
      raise;
end;


END ARP_DEBUG;

/

--------------------------------------------------------
--  DDL for Package Body ARP_UTIL_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_UTIL_TAX" AS
/*$Header: ARPUTAXB.pls 120.3 2005/02/23 18:36:46 lxzhang ship $ */

/*
definition of log level in FND_LOG package.
   LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   LEVEL_ERROR      CONSTANT NUMBER  := 5;
   LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   LEVEL_EVENT      CONSTANT NUMBER  := 3;
   LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
*/

l_line                     varchar2(1999) ;
pg_debug_level             NUMBER ;
/* ---------------------------------------------------------------------*
 |Public Procedure                                                       |
 |      debug        Write the text message  in log file                 |
 |                   if the debug is set "Yes".                          |
 | Description                                                           |
 |    Old Behavior: This procedure will generate the standard debug      |
 |                   information in to the log file.User can open the    |
 |                   log file <user name.log> at specified location.     |
 |    New Behavior: This procedure will call FND_LOG to generate the     |
 |                  debug messages into FND_LOG_MESSAGES Table.          |
 |                                                                       |
 | Requires                                                              |
 |      p_line       The line of debug messages that will be writen      |
 |                   in the log file.                                    |
 | Exception Raised                                                      |
 |                                                                       |
 | Known Bugs                                                            |
 |                                                                       |
 | Notes                                                                 |
 |                                                                       |
 | History    Nov-11-2003 Ling Zhang Bug fix 3062098                     |
 |                                                                       |
 *-----------------------------------------------------------------------*/
PROCEDURE debug(
p_line   IN VARCHAR2,
p_module_name IN VARCHAR2 DEFAULT 'TAX',
p_log_level IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT
)   IS
BEGIN

  IF p_log_level >=pg_debug_level THEN
       IF lengthb(p_line) > 1999 THEN
          l_line := substrb(p_line,1,1999) ;
       ELSE
          l_line := p_line ;
       END IF;

       fnd_log.string(
              LOG_LEVEL => p_log_level,
              MODULE => p_module_name,
              MESSAGE => l_line);
  END IF;

EXCEPTION
       WHEN  others THEN
         IF (FND_LOG.LEVEL_UNEXPECTED >= pg_debug_level ) THEN
           fnd_log.string(
              LOG_LEVEL => FND_LOG.LEVEL_UNEXPECTED,
              MODULE => 'TAX',
              MESSAGE => 'Unexpected Error When Logging Debug Messages.');
         END IF;
END debug;


FUNCTION  is_debug_enabled return VARCHAR2 IS
BEGIN
   -- bug fix 3062098. this procedure is not used by any othe pkg,
   -- so comment out
   -- return NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
   NULL;
END  is_debug_enabled;


PROCEDURE initialize  IS
BEGIN
     debug('ARP_UTIL_TAX Initialize()+');
     pg_debug_level  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     debug('ARP_UTIL_TAX Initialize()-');
EXCEPTION
     WHEN  others THEN
          null;
END;

/*------------------ Package Constructor --------------------------------*/

BEGIN

--   ARP_UTIL.DEBUG('ARP_UTIL_TAX    COSTRUCTOR(+)');

     initialize;

END ARP_UTIL_TAX ;

/

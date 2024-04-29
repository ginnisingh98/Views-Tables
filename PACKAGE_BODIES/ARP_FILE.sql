--------------------------------------------------------
--  DDL for Package Body ARP_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_FILE" AS
/* $Header: ARPFILEB.pls 115.5 2003/10/10 14:25:12 mraymond ship $*/


/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    write_log                                                                |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Will write to a log file based on the debug level                       |
 |                                                                            |
 | SCOPE - PRIVATE                                                            |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |                                                                            |
 | ARGUMENTS  : IN:                                                           |
 |                 p_text          -   Text to be printed                     |
 |                 p_level         -   Debug Level for this Text              |
 |            : OUT:                                                          |
 |                 None                                                       |
 |                                                                            |
 | RETURNS    : NONE                                                          |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |                                                                            |
 |     01-SEP-2000 Ramakant Alat       Created                                |
 *----------------------------------------------------------------------------*/
   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE write_log ( p_text IN VARCHAR2, p_level IN NUMBER DEFAULT MAX_DEBUG_LEVEL) AS
   BEGIN
      IF arp_standard.sysparm.AI_LOG_FILE_MESSAGE_LEVEL > p_level THEN
         IF arp_standard.profile.request_id IS NOT NULL THEN
            fnd_file.put_line( FND_FILE.LOG, to_char(sysdate, 'HH24:MI:SS :') ||p_text );
         ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('write_log: ' || p_text);
            END IF;
         END IF;
      END IF;
   END write_log;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    print_fn_label                                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Will print the function label to a log file                             |
 |                                                                            |
 | SCOPE - PRIVATE                                                            |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |                                                                            |
 | ARGUMENTS  : IN:                                                           |
 |                 p_text          -   Text to be printed                     |
 |            : OUT:                                                          |
 |                 None                                                       |
 |                                                                            |
 | RETURNS    : NONE                                                          |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |                                                                            |
 |     01-SEP-2000 Ramakant Alat       Created                                |
 *----------------------------------------------------------------------------*/
   PROCEDURE print_fn_label (p_text IN VARCHAR2) as
   BEGIN
      write_log(p_text, MIN_DEBUG_LEVEL);
   END print_fn_label;

END arp_file;

/

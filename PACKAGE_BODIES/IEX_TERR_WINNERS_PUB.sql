--------------------------------------------------------
--  DDL for Package Body IEX_TERR_WINNERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TERR_WINNERS_PUB" AS
/* $Header: iexttwpb.pls 120.1 2005/12/06 07:43:18 lkkumar noship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   IEX_TERR_WINNERS_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--
--      Public  Package for the concurrent program
--      "Generate Access Records".
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--
--    HISTORY
--      04/14/2002  AXAVIER Francis Xavier Created.
--
---------------------------------------------------------------------------


/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_PKG_NAME  CONSTANT VARCHAR2(30):='IEX_TERR_WINNERS_PUB';
  G_FILE_NAME CONSTANT VARCHAR2(12):='asxttwpb.pls';


/*-------------------------------------------------------------------------+
 |                             PRIVATE DATATYPES
 +-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/

/*------------------------------------------------------------------------*
 |                              PUBLIC ROUTINES
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Print_Debug
 |
 | PURPOSE
 |  Logs debug messages
 |
 | NOTES
 |
 | HISTORY
 |   04/14/02  AXAVIER  Created
 *-------------------------------------------------------------------------*/


PROCEDURE Print_Debug( msg in VARCHAR2) IS
l_length        NUMBER;
l_start         NUMBER := 1;
l_substring     VARCHAR2(255);
l_base          VARCHAR2(12);
l_date_str      VARCHAR2(255);

BEGIN
    IF g_debug_flag = 'Y'
    THEN
    select to_char( sysdate, 'DD-Mon-YYYY HH24:MI:SS') into l_date_str from dual;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'---' || l_date_str || '--------------------------');

        -- Crop the message to length 255 chars
        l_length := length(msg);
        WHILE l_length > 255 LOOP
            l_substring := substr(msg, l_start, 255);
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
            --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. Start.
            IEX_DEBUG_PUB.logmessage(l_substring);
            --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. End.
--          dbms_output.put_line(l_substring);
            l_start := l_start + 255;
            l_length := l_length - 255;
        END LOOP;

        l_substring := substr(msg, l_start);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
	 --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. Start.
          IEX_DEBUG_PUB.logmessage(l_substring);
         --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. End.
--      dbms_output.put_line(l_substring);
    END IF;
EXCEPTION
WHEN others THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in Print_Debug');
      FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));
END Print_Debug;

PROCEDURE Analyze_Table(
    schema IN VARCHAR2,
    table_name IN VARCHAR2,
    p_percent IN NUMBER) IS

BEGIN

   DBMS_STATS.gather_table_stats(SCHEMA, TABLE_NAME, cascade=>TRUE, degree=>8, estimate_percent=>P_PERCENT);

EXCEPTION
WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in Analyze_Table');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      RAISE;
END Analyze_Table;




END IEX_TERR_WINNERS_PUB;

/

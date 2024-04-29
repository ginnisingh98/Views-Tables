--------------------------------------------------------
--  DDL for Package Body HZ_MGD_MASS_UPDATE_REP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MGD_MASS_UPDATE_REP_GEN" AS
/* $Header: ARHCMURB.pls 120.4 2004/02/24 21:46:53 mraymond noship $ */

/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      ARHCMURB.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to generate output report for Mass update        |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Initialize                                                        |
--|     Log                                                               |
--|     Add_Item                                                          |
--|     Generate_Report                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     05/22/2002 tsimmond    Created                                    |
--|     11/27/2002 tsimmond    Updated   Added WHENEVER OSERROR EXIT      |
--|                                      FAILURE ROLLBACK                 |
--+======================================================================*/




--===================
-- COMMENT : PL/SQL Table definition. This table will be used to record
--           log information for the exception cases.
--===================
TYPE REPORT_EXP_REC IS RECORD
( party VARCHAR2(50)
, customer VARCHAR2(50)
, site VARCHAR2(50)
);


TYPE REPORT_EXP_TABLE IS TABLE OF REPORT_EXP_REC
     INDEX BY BINARY_INTEGER;



--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MGD_MASS_UPDATE_REP_GEN';
G_ORG_ID            NUMBER       := TO_NUMBER(FND_PROFILE.value('ORG_ID'));

--===================
-- PUBLIC VARIABLES
--===================
g_program_type     VARCHAR2(30);
g_rec_no           NUMBER:=0;

g_mode             VARCHAR2(15);
g_log_level        NUMBER      := 5 ;
g_log_mode         VARCHAR2(240) :=
        NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') ;

g_exp_table   HZ_MGD_MASS_UPDATE_REP_GEN.REPORT_EXP_TABLE;


--===================
-- PRIVATE PROCEDURES AND FUNCTIONS
--===================

--===================
-- FUNCTION : Add_Spaces
-- PARAMETERS: in_space  Number of blank spaces required
-- COMMENT   : Function will add blank spaces to the report
---
--====================
FUNCTION Add_Spaces
( in_space IN NUMBER
)
RETURN   VARCHAR2
IS

  out_space VARCHAR2(140) := ' ' ;

BEGIN
  FOR i in 1..in_space LOOP
    out_space := out_space || ' ';
  END LOOP;

  RETURN (out_space);


END Add_Spaces;

--====================================================
-- FUNCTION : Draw_Line      PRIVATE
-- PARAMETERS: in_length     Line Length
--             in_type       Type of Line ('-' or '=')
--
-- COMMENT   : Function to draw lines in the report
--
--====================================================
FUNCTION Draw_line
( in_length IN NUMBER
, in_type   IN NUMBER
)
RETURN   VARCHAR2
IS

out_line VARCHAR2(140);

BEGIN
  FOR i in 1..in_length LOOP
   IF in_type = 1
   THEN
     out_line := out_line || '-' ;
   ELSE
     out_line := out_line || '=' ;
   END IF;
  END LOOP;

  RETURN (out_line);


END Draw_Line;

--========================================================================
-- PROCEDURE : Print_Line        PRIVATE
-- PARAMETERS: p_line            IN line to be printed
-- COMMENT   : Print to output file if called from a concurrent request
--             It uses dbms_output otherwise
--=======================================================================
PROCEDURE Print_Line
( p_line IN VARCHAR2
)
IS
  l_line VARCHAR2(132);
BEGIN
-- SQL*Plus session:
  IF g_mode='SQL'
  THEN
    l_line := '.'||p_line;
    --DBMS_OUTPUT.put_line(l_line);

  ELSE
    -- Concurrent request
    FND_FILE.put_line( FND_FILE.output
                     , p_line
                     );
  END IF;


END Print_Line;

--========================================================================
-- PROCEDURE : Print_Col_Titles       PRIVATE
-- COMMENT   : This procedure prints Column titles with parties
--=======================================================================
PROCEDURE Print_Col_Titles_P
IS
BEGIN

  Print_line(FND_MESSAGE.get_string
                        ('AR','AR_MGD_MASS_UPDATE_COL1')
            ||add_spaces(52-lengthb(FND_MESSAGE.get_string
                                              ('AR','AR_MGD_MASS_UPDATE_COL1')
                                  )
                        )
            ||FND_MESSAGE.get_string
                         ('AR','AR_MGD_MASS_UPDATE_COL2')
            ||add_spaces(42-lengthb(FND_MESSAGE.get_string
                                              ('AR','AR_MGD_MASS_UPDATE_COL2')
                                  )
                        )
            ||FND_MESSAGE.get_string
                         ('AR','AR_MGD_MASS_UPDATE_COL3')
            ||add_spaces(36-lengthb(FND_MESSAGE.get_string
                                              ('AR','AR_MGD_MASS_UPDATE_COL3')
                                  )
                         )
            );

  Print_line(draw_line(50,1)
            ||add_spaces(2)
            ||draw_line(40,1)
            ||add_spaces(2)
            ||draw_line(36,1)
            );


END Print_Col_Titles_P;

--========================================================================
-- PROCEDURE : Print_Col_Titles       PRIVATE
-- COMMENT   : This procedure prints Column titles without parties
--=======================================================================
PROCEDURE Print_Col_Titles
IS
BEGIN

  Print_line(FND_MESSAGE.get_string
                        ('AR','AR_MGD_MASS_UPDATE_COL2')
            ||add_spaces(42-lengthb(FND_MESSAGE.get_string
                                              ('AR','AR_MGD_MASS_UPDATE_COL2')
                                  )
                        )
            ||FND_MESSAGE.get_string
                         ('AR','AR_MGD_MASS_UPDATE_COL3')
            );

  Print_line(draw_line(40,1)
            ||add_spaces(2)
            ||draw_line(36,1)
            );


END Print_Col_Titles;


--========================================================================
-- FUNCTION  : Find_meaning      PRIVATE
-- PARAMETERS: p_lookup_code
-- COMMENT   : This procedure returns meaning for specified lookup code
--=======================================================================
FUNCTION Find_meaning
(p_lookup_code IN VARCHAR2
)
RETURN VARCHAR2
IS
l_meaning VARCHAR2(80);

BEGIN
  SELECT
    meaning
  INTO
    l_meaning
  FROM fnd_lookups
  WHERE lookup_code=p_lookup_code
    AND lookup_type='YES_NO';

  RETURN(l_meaning);

EXCEPTION
  WHEN no_data_found
  THEN RETURN (null);

  WHEN OTHERS THEN
    HZ_MGD_MASS_UPDATE_REP_GEN.log ( HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_EXCEPTION
                               , 'SQLERRM '|| SQLERRM) ;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Find_meaning'
      );
    END IF;
    RAISE;

END Find_meaning;

--===================
-- PUBLIC PROCEDURES AND FUNCTIONS
--===================


--=====================================================================
-- PROCEDURE : Initialize                  PUBLIC
-- PARAMETERS:
--
-- COMMENT   : This the procedure will initialize the log facility
--             and  pls/sql tables for vendor conversion.
--             It should be called from the top level procedure of
--             each concurrent program.
--=====================================================================
PROCEDURE Initialize
IS

BEGIN
  -- Checking if the log facility is ON
  -- Checking if the program is running from SQL Plus
  IF FND_PROFILE.Value('CONC_REQUEST_ID') is NULL
  THEN
    g_mode:='SQL';
  ELSE
    g_mode:='SRS';
  END IF;

  -- g_log_mode := 'ON' ;
  -- BUG 2040015

  g_log_level   := 5 ;
  g_log_mode    := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') ;

  -- Initialize pl/sql tables

  g_exp_table.DELETE;

END Initialize;


--=======================================================================
-- PROCEDURE : Log         PUBLIC
-- PARAMETERS: p_priority  IN  priority of the message -
--                         from highest to lowest:
--                         G_LOG_ERROR
--                         G_LOG_EXCEPTION
--                         G_LOG_EVENT
--                         G_LOG_PROCEDURE
--                         G_LOG_STATEMENT
--             p_msg       IN  message to be print on the log file
-- COMMENT   : Add an entry to the log
--=======================================================================
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS

BEGIN
     IF NVL(g_mode,'SQL') = 'SQL' THEN
       -- SQL*Plus session:
       --DBMS_OUTPUT.put_line(p_msg);
       NULL;
     ELSE
       -- BUG 2040015
       BEGIN
         IF NVL(g_log_mode,'N') = 'Y' THEN
           -- Concurrent request
           IF NVL(p_priority,5) <= NVL(g_log_level,5) THEN
              FND_FILE.put_line
              ( FND_FILE.log
               , p_msg
              );
           END IF;
         ELSE
           IF NVL(p_priority,5) <= 3 THEN
             FND_FILE.put_line
             ( FND_FILE.log
               , p_msg
             );
           END IF;
         END IF;
       END ;
     END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;



--==========================================================================
-- PROCEDURE : Add_Exp_Item          PUBLIC
-- PARAMETERS: p_party               name of the party not updated
--             p_customer            name of the customer  not updated
--             p_site                name of the customer site not updated
--
-- COMMENT   : This is the procedure to record exception information into g_exp_table.
--
--==========================================================================
PROCEDURE Add_Exp_Item
( p_party       IN VARCHAR2
, p_customer    IN VARCHAR2
, p_site        IN VARCHAR2
)
IS
BEGIN

 HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> Add_Exp_Item ' );

    g_rec_no:=g_exp_table.COUNT +1;

    g_exp_table(g_rec_no).party:=p_party;
    g_exp_table(g_rec_no).customer:=p_customer;
    g_exp_table(g_rec_no).site:=p_site;

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< Add_Exp_Item ' );

END Add_Exp_Item;
--====================
-- PROCEDURE : Generate_Report             PUBLIC
-- PARAMETERS: p_cust_prof_class           Name of the profile class
--             p_currency_code             Profile currency
--             p_rule_set                  Name of the rule set
--
-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_prof_class_id             IN NUMBER
, p_currency_code             IN VARCHAR2
, p_profile_class_amount_id   IN NUMBER
)
IS

  l_profile_class    VARCHAR2(30);
  l_operating_unit   VARCHAR2(60);
  l_header_space     INTEGER := 0;
  l_header1_length   INTEGER := 0;
  l_header2_length   INTEGER := 0;
  l_col1_margin      INTEGER := 0;
  l_col2_margin      INTEGER := 0;
  l_col3_margin      INTEGER := 0;
  l_col4_margin      INTEGER := 0;
  l_foot_length      INTEGER := 0;
  l_param_max        INTEGER := 0;
  l_no_data          VARCHAR2(1):='N';

  l_header1          VARCHAR2(200);
  l_header2          VARCHAR2(200);
  l_text_start       VARCHAR2(200);
  l_rec_count        NUMBER:=0;


BEGIN

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> Generate_Report ' );

-------Getting Profile Class  Name, operating Unit Name---------------

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => '  Getting Profile Class  Name, operating Unit Name '
    );

  BEGIN
    SELECT
      name
    INTO
      l_profile_class
    FROM
      hz_cust_profile_classes
    WHERE profile_class_id =p_prof_class_id;

--  HZ_MGD_MASS_UPDATE_REP_GEN.log
--  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
--  , p_msg => 'Profile Class  Name= '||l_profile_class
--    );

  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    l_no_data:='Y';

  END;

  BEGIN

  SELECT
      SUBSTRB(name,1,30)
    INTO
      l_operating_unit
    FROM
      hr_operating_units
    WHERE organization_id=G_ORG_ID;

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => 'operating Unit Name= '||l_operating_unit
    );

  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN

    l_no_data:='Y';

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => 'NO_DATA_FOUND '
    );
  END;

  --------Centering Report Header----------
  --l_header1:=' Mass update credit usages ';
  --l_header2:=' Exception Report ';

  l_header1:=NVL(FND_MESSAGE.get_string
                               ('AR','AR_MGD_MASS_UPDATE_TITLE1'
                               ),' '
                 );

  l_header1_length :=LENGTHB(l_header1);

  l_header2:=NVL(FND_MESSAGE.get_string
                               ('AR','AR_MGD_MASS_UPDATE_TITLE2'
                               ),' '
                 );
  l_header2_length :=LENGTHB(l_header2);


  l_header_space:=40;

  ---------------Printing Report Header------------------------

  Print_line(add_spaces(G_rpt_page_col-1)
            );
  Print_line(add_spaces(1)
            ||NVL(l_operating_unit,' ')
            ||add_spaces(l_header_space-LENGTHB(NVL(l_operating_unit,' ')))
            ||l_header1
            ||add_spaces(l_header_space-l_header1_length)
            ||TO_CHAR(sysdate)
            );

  Print_line(add_spaces(1)
            ||add_spaces(l_header_space)
            ||l_header2
            ||add_spaces(l_header_space-l_header2_length)
            );

  Print_line(add_spaces(G_rpt_page_col)
            );


  ------------------Centuring Parameters--------------------------
  l_param_max:=60;

  -----------------Printing Parameters
  Print_line(add_spaces(l_param_max-LENGTHB(NVL(FND_MESSAGE.get_string
                                                      ('AR','AR_MGD_MASS_UPDATE_PARAM1'
                                                      ),' ')
                       )
            )
            ||NVL(FND_MESSAGE.get_string
                         ('AR','AR_MGD_MASS_UPDATE_PARAM1'
                         ),' '
                 )
            ||add_spaces(1)
            ||l_profile_class
            );
  Print_line(add_spaces(l_param_max-LENGTHB(NVL(FND_MESSAGE.get_string
                                                      ('AR','AR_MGD_MASS_UPDATE_PARAM2'
                                                      ),' '
                                              )
                                          )
                       )
            ||NVL(FND_MESSAGE.get_string
                         ('AR','AR_MGD_MASS_UPDATE_PARAM2'
                         ),' '
                 )
            ||add_spaces(1)
            ||p_currency_code
            );


  Print_line(add_spaces(G_rpt_page_col)
            );


  ------------Printing Body of the Report------------------------
  ------------Check if there is data in the pl/sql table

  l_rec_count:=g_exp_table.COUNT;

  ----------No data, no exceptions--------------------------
  IF l_rec_count=0
  THEN
    -----centuring the text "No exceptions.All the credit profiles have been updated successfully."

    l_text_start:=ROUND((130-lengthb(NVL(FND_MESSAGE.get_string
                  ('AR','AR_MGD_MASS_UPDATE_FOOTER2'
                  ),' '
                 )))/2);

    Print_line(add_spaces(1)
              ||add_spaces(l_text_start)
              ||NVL(FND_MESSAGE.get_string
                  ('AR','AR_MGD_MASS_UPDATE_FOOTER2'
                  ),' '
                 )
               );

  ELSE
    -----------------Printing Report----------------------
    IF HZ_MGD_MASS_UPDATE_CP.G_RELEASE='NEW'
    THEN
      ---------------Print party----------------

      ---------------Print text-----------------
      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT1'
                                          )
                 );
      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT2'
                                          )
                 );
      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT3'
                                          )
                 );

      Print_line(add_spaces(G_rpt_page_col-1)
            );
      Print_line(add_spaces(G_rpt_page_col)
            );

      --------------Printing Column titles with party---------------

      Print_Col_Titles_P;

      ------------------Printing Columns with party-----------------

      FOR i IN g_exp_table.FIRST .. g_exp_table.LAST
      LOOP
        Print_line(NVL(substrb(g_exp_table(i).party,1,50),' ')
                  ||add_spaces(52-lengthb(NVL(g_exp_table(i).party,' ')) )
                  ||NVL(substrb(g_exp_table(i).customer,1,40),' ')
                  ||add_spaces(42-NVL(lengthb(g_exp_table(i).customer),0))
                  ||NVL(g_exp_table(i).site,' ')
                  );
      END LOOP;

    ELSIF  HZ_MGD_MASS_UPDATE_CP.G_RELEASE='OLD'
    THEN
      --------------Do not print party---------------


      ---------------Print text-----------------
      -----The following customers/customer sites have not been updated.---

      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT4'
                                          )
                 );


      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT2'
                                          )
                 );


      Print_line(add_spaces(1)
                 ||FND_MESSAGE.get_string('AR','AR_MGD_MASS_UPDATE_TEXT5'
                                          )
                 );

      Print_line(add_spaces(G_rpt_page_col-1)
            );
      Print_line(add_spaces(G_rpt_page_col)
            );

      --------------Printing Column titles---------------

      Print_Col_Titles;

      --------------Printing Columns--------------------

      FOR i IN g_exp_table.FIRST .. g_exp_table.LAST
      LOOP
        Print_line(NVL(substrb(g_exp_table(i).customer,1,40),' ')
                  ||add_spaces(42-lengthb(NVL(g_exp_table(i).customer,' ')))
                  ||NVL(g_exp_table(i).site,' ')
                  );
      END LOOP;
    END IF;

  END IF;

  -------------------Printing Footer of the Report-----------------------
  Print_line(add_spaces(G_rpt_page_col)
            );
  Print_line(add_spaces(G_rpt_page_col)
            );

  Print_line(add_spaces(l_header_space)
            ||'****** '
            ||NVL(FND_MESSAGE.get_string
                  ('AR','AR_MGD_MASS_UPDATE_FOOTER1'
                  ),' '
                 )
            ||' ******'
            );

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< Generate_Report ' );

END Generate_Report;

END HZ_MGD_MASS_UPDATE_REP_GEN;

/

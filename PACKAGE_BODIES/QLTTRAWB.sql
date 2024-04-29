--------------------------------------------------------
--  DDL for Package Body QLTTRAWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTTRAWB" as
/* $Header: qlttrawb.plb 120.18.12010000.9 2010/04/26 17:41:32 ntungare ship $ */
-- 1/23/96 - created
-- Paul Mishkin

    --
    -- Standard who columns.
    --
    who_program_id                       number := fnd_global.conc_program_id;
    who_program_application_id           number := fnd_global.prog_appl_id;
    who_created_by			 number;
    who_last_update_login                number;
    who_user_id                          number;

    --
    -- A rather unusual situation, we will use the request id of the
    -- parent (import manager).  This will be set in the wrapper.
    --
    who_request_id                       number := fnd_global.conc_request_id;

TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE CHAR30_TABLE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE CHAR150_TABLE IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE CHAR1500_TABLE IS TABLE OF VARCHAR2(1500) INDEX BY BINARY_INTEGER;
TYPE CHAR2000_TABLE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  -- Bug 3785197. Update was failing if read only or sequence elements was set as matching element.
  -- Declaring the following global variables.
  -- --------------------------------------------------------------------------------------------------
  --    Variable                     Description                 Intialised                  Used/Modified
  -- ---------------------------------------------------------------------------------------------------
  --(1) G_TYPE_OF_TXN         Holds 1 (Insert) or             QLTTRAWB.WRAPPER()          VALIDATE_STEPS ()
  --                                2 (Update
  --
  --(2) G_MATCHING_CHAR_TABLE  Table of collection elements   VALIDATE_UPDATE              CHECK_IF_MATCHING_
  --                           specified as matching element.            _TYPE_RECORDS()             ELEMENT()  --
  --(3) G_TOTAL_MATCHES        Number of matching elements.    VALIDATE_UPDATE              CHECK_IF_MATCHING_
  --                                                                  _TYPE_RECORDS()              ELEEMENT()
  -- srhariha. Fri Jul 23 03:04:52 PDT 2004.

G_TYPE_OF_TXN NUMBER;
G_MATCHING_CHAR_TABLE CHAR30_TABLE;
G_TOTAL_MATCHES NUMBER;


-- globals for translated error messages

ERROR_REJECT VARCHAR2(2000);
ERROR_DISABLED VARCHAR2(2000);
ERROR_MANDATORY VARCHAR2(2000);
ERROR_NEED_PARENT VARCHAR2(2000);
ERROR_INVALID_VALUE VARCHAR2(2000);
ERROR_OUTSIDE_LIMITS VARCHAR2(2000);
ERROR_CRITICAL VARCHAR2(2000);
ERROR_INVALID_NUMBER VARCHAR2(2000);
ERROR_INVALID_DATE VARCHAR2(2000);
ERROR_NEED_REV VARCHAR2(2000);
ERROR_CANT_HAVE_REV VARCHAR2(2000);
ERROR_CANT_HAVE_LOC VARCHAR2(2000);
ERROR_BUSY VARCHAR2(2000);
ERROR_BAD_SQL VARCHAR2(2000);

-- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
G_SEQUENCE_DEFAULT  VARCHAR2(40);

-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Global Error Message for READ ONLY FLAG Collection Plan Element
-- saugupta Wed Aug 27 07:25:51 PDT 2003.
ERROR_READ_ONLY VARCHAR2(2000);

-- Bug 3069404 ksoh Tue Mar 16 10:43:36 PST 2004
-- Error message for importing sequence element
ERROR_SEQUENCE VARCHAR2(2000);

-- Added for Timezone Compliance Date and Time elements.
-- kabalakr Mon Oct 27 04:33:49 PST 2003.
ERROR_INVALID_DATETIME VARCHAR2(2000);


-- Global exceptions

g_col_name VARCHAR2(30);
g_sqlerrm varchar2(240);

-- A constant to fool GSCC.  See bug 3554899
-- bso Wed Apr  7 22:27:11 PDT 2004
g_period CONSTANT VARCHAR2(1) := '.';

user_sql_error EXCEPTION;

resource_busy EXCEPTION;
PRAGMA EXCEPTION_INIT(resource_busy, -54);

 -- 3785197. Update was failing if read only or sequence elements was set as matching element.
 -- Added new function CHECK_IF_MATCHING_ELEMENT which returns true if P_CHAR_NAME is mentioned
 -- as matching element. Used in VALIDATE_SEQUENCE and VALIDATE_STEPS procedures.
 -- srhariha. Fri Jul 23 03:04:52 PDT 2004.


FUNCTION CHECK_IF_MATCHING_ELEMENT (P_CHAR_NAME VARCHAR2) RETURN boolean IS

BEGIN
  IF (G_TOTAL_MATCHES IS NOT NULL) THEN

      FOR I IN 1..G_TOTAL_MATCHES LOOP
          IF (upper(G_MATCHING_CHAR_TABLE(I)) = upper(P_CHAR_NAME)) THEN
             RETURN TRUE;
          END IF;
      END LOOP;

  END IF;

  RETURN FALSE;

END CHECK_IF_MATCHING_ELEMENT;



PROCEDURE parse_error_columns(
    p_cols IN VARCHAR2,
    x_col1 OUT NOCOPY VARCHAR2,
    x_col2 OUT NOCOPY VARCHAR2,
    x_col3 OUT NOCOPY VARCHAR2,
    x_col4 OUT NOCOPY VARCHAR2,
    x_col5 OUT NOCOPY VARCHAR2) IS
    --
    -- SQL Bind Project for performance.
    -- There is an IN operation in many places of the form:
    -- IN ERR_COL_LIST.  This is a literal SQL.  The fact
    -- that an err_col_list can contain at most 5 tokens can
    -- be used to make this into a bind SQL.  (See validate_steps).
    -- This procedure parses out the various columns from the list
    -- into separate tokens.  'NULL' will be substituted if there
    -- is no string in that position.
    --

    -- Bug 3136107.Same as the fix done in Bug 3079312. suramasw.

    s VARCHAR2(2000) := p_cols;
    p INTEGER;
    i INTEGER := 1;
    val dbms_sql.varchar2s;

BEGIN
    val(1) := '';
    val(2) := '';
    val(3) := '';
    val(4) := '';
    val(5) := '';

    --
    -- Get rid of single-quotes
    --
    s := translate(s, '''', ' ');

    --
    -- Loop until , is not found
    --
    p := instr(s, ',');

    WHILE p <> 0 LOOP
        -- found a comma, splice everything in front
        val(i) := rtrim(ltrim(substr(s, 1, p-1)));
        s := substr(s, p+1);
        p := instr(s, ',');
        i := i + 1;
    END LOOP;
    val(i) := rtrim(ltrim(s));

    x_col1 := val(1);
    x_col2 := val(2);
    x_col3 := val(3);
    x_col4 := val(4);
    x_col5 := val(5);

END parse_error_columns;

FUNCTION despecial(s1 in varchar2) RETURN varchar2 IS
BEGIN
    RETURN translate(s1, ' ''*{}', '_____');
END despecial;


FUNCTION dequote(s1 in varchar2) RETURN varchar2 IS
--
-- The string s1 may be used in a dynamically constructed SQL
-- statement.  If s1 contains a single quote, there will be syntax
-- error.  This function returns a string s2 that is same as s1
-- except each single quote is replaced with two single quotes.
-- Put in for NLS fix.  Previously if plan name or element name
-- contains a single quote, that will cause problem when creating
-- views.
-- bso
--
BEGIN
    RETURN replace(s1, '''', '''''');
END dequote;


FUNCTION quote(s1 in varchar2) RETURN varchar2 IS
--
-- Add single quotes surrounding string s1 to be used in dynamic
-- SQL.  This means any single quote already in s1 must be changed
-- to two single quotes.
-- bso
--
BEGIN
    RETURN '''' || replace(s1, '''', '''''') || '''';
END quote;


-- Bug 4270911. CU2 SQL Literal fix. TD #23
-- Helper procedures for validate_actions.
-- srhariha. Wed Apr 20 06:05:49 PDT 2005.

PROCEDURE VALIDATE_ACTIONS_HELPER (ERROR_COL_NAME VARCHAR2, COL_NAME VARCHAR2,
                                   X_DATATYPE NUMBER,
                                   X_CHAR_ID NUMBER,
                                   X_PLAN_ID NUMBER,
                                   X_LV_LOOKUP_VALUE VARCHAR2,
                                   X_LV_OTHER_VALUE VARCHAR2,
                                   X_HV_LOOKUP_VALUE VARCHAR2,
                                   X_HV_OTHER_VALUE VARCHAR2,
                                   X_OP_CODE NUMBER) IS


   LV1             VARCHAR2(250);
   LV2             VARCHAR2(250);
   HV1             VARCHAR2(250);
   HV2             VARCHAR2(250);
   TEMP            VARCHAR2(250);
   OP              VARCHAR2(30);


BEGIN
   qa_core_pkg.dsql_add_text('(');
   qa_core_pkg.dsql_add_text(' SELECT 1 ' ||
                             ' FROM QA_SPEC_CHARS_V QSC, QA_CHARS QC ' ||
                             ' WHERE QSC.CHAR_ID (+) = QC.CHAR_ID ' ||
                             ' AND QC.CHAR_ID = ');

   qa_core_pkg.dsql_add_bind(X_CHAR_ID);

   qa_core_pkg.dsql_add_text(' AND QSC.SPEC_ID (+) = NVL(QRI.SPEC_ID, -1) ' ||
                             ' AND QSC.SPEC_CHAR_ENABLED (+) = 1 ' ||
                             ' AND ');


   IF x_datatype = 2 THEN
      qa_core_pkg.dsql_add_text(' qltdate.any_to_number(QRI.' || COL_NAME || ') ');

   ELSIF x_datatype = 3 THEN
      qa_core_pkg.dsql_add_text(' qltdate.any_to_date(QRI.' || COL_NAME || ') ');

   ELSIF x_datatype = 6 THEN
       qa_core_pkg.dsql_add_text(' qltdate.any_to_datetime(QRI.' || COL_NAME || ') ');

   ELSE
       qa_core_pkg.dsql_add_text(' QRI.' || COL_NAME || ' ');
   END IF;


   OP := QLTTRAFB.DECODE_OPERATOR(X_OP_CODE);

   -- Build the rhs.

   IF X_OP_CODE NOT IN (7,8) THEN

        -- LV
        IF X_LV_LOOKUP_VALUE IS NOT NULL THEN
             TEMP := QLTTRAFB.DECODE_ACTION_VALUE_LOOKUP(X_LV_LOOKUP_VALUE);
             LV1 := 'QC.' || TEMP;
             LV2 := 'QSC.' || TEMP;

             IF (X_DATATYPE = 2) THEN
                  LV1 := 'qltdate.canon_to_number(' || LV1 || ')';
                  LV2 := 'qltdate.canon_to_number(' || LV2 || ')';

             ELSIF (X_DATATYPE IN (3, 6)) THEN
                  LV1 := 'qltdate.canon_to_date(' || LV1 || ')';
                  LV2 := 'qltdate.canon_to_date(' || LV2 || ')';

             END IF;

             qa_core_pkg.dsql_add_text(' ' || OP || ' DECODE(QSC.CHAR_ID, NULL, ' ||
                                                                       LV1 || ', ' || LV2 || ')');


        ELSE -- binds required

             qa_core_pkg.dsql_add_text(' ' || OP || ' DECODE(QSC.CHAR_ID, NULL, ');

             IF (X_DATATYPE = 2) THEN
                 qa_core_pkg.dsql_add_bind(qltdate.canon_to_number(X_LV_OTHER_VALUE));
                 qa_core_pkg.dsql_add_text(' ,');
                 qa_core_pkg.dsql_add_bind(qltdate.canon_to_number(X_LV_OTHER_VALUE));
                 qa_core_pkg.dsql_add_text(' )');

             ELSIF (X_DATATYPE IN (3, 6)) THEN
                 qa_core_pkg.dsql_add_bind(qltdate.canon_to_date(X_LV_OTHER_VALUE));
                 qa_core_pkg.dsql_add_text(' ,');
                 qa_core_pkg.dsql_add_bind(qltdate.canon_to_date(X_LV_OTHER_VALUE));
                 qa_core_pkg.dsql_add_text(' )');

             ELSE
                 qa_core_pkg.dsql_add_bind(X_LV_OTHER_VALUE);
                 qa_core_pkg.dsql_add_text(' ,');
                 qa_core_pkg.dsql_add_bind(X_LV_OTHER_VALUE);
                 qa_core_pkg.dsql_add_text(' )');

             END IF;

        END IF; -- x_lv_lookup_value is null


        -- between nd not between
        IF X_OP_CODE IN (9,10) THEN

            IF X_HV_LOOKUP_VALUE IS NOT NULL THEN

                TEMP := QLTTRAFB.DECODE_ACTION_VALUE_LOOKUP(X_HV_LOOKUP_VALUE);
                HV1 := 'QC.' || TEMP;
                HV2 := 'QSC.' || TEMP;

                IF (X_DATATYPE = 2) THEN
                     HV1 := 'qltdate.canon_to_number(' || HV1 || ')';
                     HV2 := 'qltdate.canon_to_number(' || HV2 || ')';

                ELSIF (X_DATATYPE IN (3, 6)) THEN
                     HV1 := 'qltdate.canon_to_date(' || HV1 || ')';
                     HV2 := 'qltdate.canon_to_date(' || HV2 || ')';

                END IF;

                qa_core_pkg.dsql_add_text(' AND ' || ' DECODE(QSC.CHAR_ID, NULL, ' ||
                                                                       HV1 || ', ' || HV2 || ')');


             ELSE -- binds required

                qa_core_pkg.dsql_add_text(' AND ' || ' DECODE(QSC.CHAR_ID, NULL, ');

                IF (X_DATATYPE = 2) THEN
                   qa_core_pkg.dsql_add_bind(qltdate.canon_to_number(X_HV_OTHER_VALUE));
                   qa_core_pkg.dsql_add_text(' ,');
                   qa_core_pkg.dsql_add_bind(qltdate.canon_to_number(X_HV_OTHER_VALUE));
                   qa_core_pkg.dsql_add_text(' )');

                ELSIF (X_DATATYPE IN (3, 6)) THEN
                   qa_core_pkg.dsql_add_bind(qltdate.canon_to_date(X_HV_OTHER_VALUE));
                   qa_core_pkg.dsql_add_text(' ,');
                   qa_core_pkg.dsql_add_bind(qltdate.canon_to_date(X_HV_OTHER_VALUE));
                   qa_core_pkg.dsql_add_text(' )');

                ELSE
                   qa_core_pkg.dsql_add_bind(X_HV_OTHER_VALUE);
                   qa_core_pkg.dsql_add_text(' ,');
                   qa_core_pkg.dsql_add_bind(X_HV_OTHER_VALUE);
                   qa_core_pkg.dsql_add_text(' )');

                END IF;

             END IF; -- hv_lookup

        END IF; -- x_operator in 9,10

   -- is null or is not null
   ELSE
      qa_core_pkg.dsql_add_text(' ' || OP);

   END IF; -- not in (7,8)

  qa_core_pkg.dsql_add_text(' )');


END VALIDATE_ACTIONS_HELPER;






PROCEDURE UPDATE_MARKER          ( COL_NAME VARCHAR2,
                                   ERROR_COL_NAME VARCHAR2,
                                   X_DATATYPE NUMBER,
                                   X_CHAR_ID NUMBER,
                                   X_GROUP_ID NUMBER,
                                   X_USER_ID NUMBER,
                                   X_LAST_UPDATE_LOGIN NUMBER,
                                   X_REQUEST_ID NUMBER,
                                   X_PROGRAM_APPLICATION_ID NUMBER,
                                   X_PROGRAM_ID NUMBER,
                                   X_PLAN_ID NUMBER,
                                   ERROR_COL_LIST VARCHAR2,
                                   X_LV_LOOKUP_VALUE VARCHAR2,
                                   X_LV_OTHER_VALUE VARCHAR2,
                                   X_HV_LOOKUP_VALUE VARCHAR2,
                                   X_HV_OTHER_VALUE VARCHAR2,
                                   X_OP_CODE NUMBER,
                                   X_PCAT_ID NUMBER ) IS

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);


BEGIN


   parse_error_columns(ERROR_COL_LIST, l_col1, l_col2, l_col3, l_col4, l_col5);

   qa_core_pkg.dsql_init;
   qa_core_pkg.dsql_add_text(' UPDATE QA_RESULTS_INTERFACE QRI ' ||
                             'SET LAST_UPDATE_DATE = SYSDATE' ||
                                ', LAST_UPDATE_LOGIN = ');
   qa_core_pkg.dsql_add_bind(X_LAST_UPDATE_LOGIN);
   qa_core_pkg.dsql_add_text(' , REQUEST_ID = ');
   qa_core_pkg.dsql_add_bind(X_REQUEST_ID);
   qa_core_pkg.dsql_add_text(' , PROGRAM_APPLICATION_ID = ');
   qa_core_pkg.dsql_add_bind(X_PROGRAM_APPLICATION_ID);
   qa_core_pkg.dsql_add_text(' , PROGRAM_ID = ');
   qa_core_pkg.dsql_add_bind(X_PROGRAM_ID);
   qa_core_pkg.dsql_add_text(' , PROGRAM_UPDATE_DATE = SYSDATE ' ||
                             ' , MARKER = ');

   qa_core_pkg.dsql_add_bind(X_PCAT_ID);
   qa_core_pkg.dsql_add_text(' ');

   -- update_sql_two
   qa_core_pkg.dsql_add_text(' WHERE  QRI.GROUP_ID = ');
   qa_core_pkg.dsql_add_bind(X_GROUP_ID);
   qa_core_pkg.dsql_add_text(' AND  QRI.PROCESS_STATUS = 2 ' ||
                            ' AND  NOT EXISTS ' ||
                                       ' (SELECT 1 ' ||
                                       '  FROM   QA_INTERFACE_ERRORS QIE ' ||
                                       '  WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                                 ' QRI.TRANSACTION_INTERFACE_ID ' ||
                                       '  AND  QIE.ERROR_COLUMN IN ( ' );
   qa_core_pkg.dsql_add_bind(l_col1);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col2);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col3);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col4);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col5);
   qa_core_pkg.dsql_add_text(' )');

   qa_core_pkg.dsql_add_text(') AND EXISTS ');


   VALIDATE_ACTIONS_HELPER (ERROR_COL_NAME, COL_NAME,X_DATATYPE, X_CHAR_ID, X_PLAN_ID,
                                   X_LV_LOOKUP_VALUE, X_LV_OTHER_VALUE,
                                   X_HV_LOOKUP_VALUE, X_HV_OTHER_VALUE,
                                   X_OP_CODE);


  qa_core_pkg.dsql_execute;



END UPDATE_MARKER;



-- Bug 4270911. CU2 SQL Literal fix. TD #23
-- Helper procedures for reject input action
-- srhariha. Wed Apr 20 06:05:49 PDT 2005.

PROCEDURE REJECT_INPUT   (  COL_NAME VARCHAR2,
                                   ERROR_COL_NAME VARCHAR2,
                                   X_DATATYPE NUMBER,
                                   X_CHAR_ID NUMBER,
                                   X_GROUP_ID NUMBER,
                                   X_USER_ID NUMBER,
                                   X_LAST_UPDATE_LOGIN NUMBER,
                                   X_REQUEST_ID NUMBER,
                                   X_PROGRAM_APPLICATION_ID NUMBER,
                                   X_PROGRAM_ID NUMBER,
                                   X_PLAN_ID NUMBER,
                                   ERROR_COL_LIST VARCHAR2,
                                   X_LV_LOOKUP_VALUE VARCHAR2,
                                   X_LV_OTHER_VALUE VARCHAR2,
                                   X_HV_LOOKUP_VALUE VARCHAR2,
                                   X_HV_OTHER_VALUE VARCHAR2,
                                   X_OP_CODE NUMBER,
                                   X_PCAT_ID NUMBER ) IS


   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);


BEGIN
   parse_error_columns(ERROR_COL_LIST, l_col1, l_col2, l_col3, l_col4, l_col5);
   qa_core_pkg.dsql_init;

  qa_core_pkg.dsql_add_text(' INSERT INTO QA_INTERFACE_ERRORS ' ||
                                      '( TRANSACTION_INTERFACE_ID, ' ||
                                      '  ERROR_COLUMN, ' ||
                                      '  ERROR_MESSAGE, ' ||
                                      '  LAST_UPDATE_DATE,' ||
                                      '  LAST_UPDATED_BY, ' ||
                                      '  CREATION_DATE, ' ||
                                      '  CREATED_BY, ' ||
                                      '  LAST_UPDATE_LOGIN, ' ||
                                      '  REQUEST_ID, ' ||
                                      '  PROGRAM_APPLICATION_ID, ' ||
                                      '  PROGRAM_ID, ' ||
                                      '  PROGRAM_UPDATE_DATE ) ' );

  qa_core_pkg.dsql_add_text(' SELECT QRI.TRANSACTION_INTERFACE_ID, ');
  qa_core_pkg.dsql_add_bind(ERROR_COL_NAME);
  qa_core_pkg.dsql_add_text(' ,');
  qa_core_pkg.dsql_add_bind(ERROR_REJECT);
  qa_core_pkg.dsql_add_text(' ,');
  qa_core_pkg.dsql_add_text(' SYSDATE, '); -- last_update_date
  qa_core_pkg.dsql_add_bind(X_USER_ID); -- last_updated_by
  qa_core_pkg.dsql_add_text(' , SYSDATE,'); -- creation_date
  qa_core_pkg.dsql_add_bind(X_USER_ID); -- created by
  qa_core_pkg.dsql_add_text(' , ');
  qa_core_pkg.dsql_add_bind(X_LAST_UPDATE_LOGIN); -- last_update_login
  qa_core_pkg.dsql_add_text(' ,');
  qa_core_pkg.dsql_add_bind(X_REQUEST_ID);
  qa_core_pkg.dsql_add_text(' ,');
  qa_core_pkg.dsql_add_bind(X_PROGRAM_APPLICATION_ID);
  qa_core_pkg.dsql_add_text(' ,');
  qa_core_pkg.dsql_add_bind(X_PROGRAM_ID);
  qa_core_pkg.dsql_add_text(' , SYSDATE ');


  qa_core_pkg.dsql_add_text(' FROM   QA_RESULTS_INTERFACE QRI ' ||
                              'WHERE  QRI.GROUP_ID = ' );

  qa_core_pkg.dsql_add_bind(X_GROUP_ID);
  qa_core_pkg.dsql_add_text(' ');

  qa_core_pkg.dsql_add_text(' AND  QRI.PROCESS_STATUS = 2 ' ||
                            ' AND  NVL(QRI.MARKER, 0) = 0 ' ||
                            ' AND  NOT EXISTS ' ||
                            '          (SELECT 1 ' ||
                            '           FROM   QA_INTERFACE_ERRORS QIE ' ||
                            '           WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                            '                     QRI.TRANSACTION_INTERFACE_ID ' ||
                            '            AND  QIE.ERROR_COLUMN IN ( ');

   qa_core_pkg.dsql_add_bind(l_col1);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col2);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col3);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col4);
   qa_core_pkg.dsql_add_text(' ,');
   qa_core_pkg.dsql_add_bind(l_col5);
   qa_core_pkg.dsql_add_text(' )');

   qa_core_pkg.dsql_add_text(') AND EXISTS ');


  VALIDATE_ACTIONS_HELPER (ERROR_COL_NAME, COL_NAME,X_DATATYPE, X_CHAR_ID, X_PLAN_ID,
                                   X_LV_LOOKUP_VALUE, X_LV_OTHER_VALUE,
                                   X_HV_LOOKUP_VALUE, X_HV_OTHER_VALUE,
                                   X_OP_CODE);


  qa_core_pkg.dsql_execute;


END REJECT_INPUT;





-- Bug 4270911. CU2 SQL Literal fix. TD #23
-- Modified the logic to use qa_core_pkg.dsql method.
-- srhariha. Wed Apr 20 06:05:49 PDT 2005.


PROCEDURE VALIDATE_ACTIONS (COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            X_DATATYPE NUMBER,
                            X_CHAR_ID NUMBER,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            X_PLAN_ID NUMBER,
                            ERROR_COL_LIST VARCHAR2) IS

   PCAT_ID_TABLE   NUMBER_TABLE;
   ACTION_ID_TABLE NUMBER_TABLE;
   OPERATOR_TABLE  NUMBER_TABLE;
   LV_LOOKUP_TABLE NUMBER_TABLE;
   LV_OTHER_TABLE  CHAR150_TABLE;
   HV_LOOKUP_TABLE NUMBER_TABLE;
   HV_OTHER_TABLE  CHAR150_TABLE;
   I               NUMBER;
   NUM_ACTIONS     NUMBER;
   PCAT_ID_CURRENT NUMBER;
   PCAT_ID_NEXT    NUMBER;

BEGIN
   I := 0;

   FOR ACTIONREC IN (SELECT
      QPCAT.PLAN_CHAR_ACTION_TRIGGER_ID,
      QPCA.ACTION_ID,
      QPCAT.OPERATOR,
      QPCAT.LOW_VALUE_LOOKUP,
      QPCAT.LOW_VALUE_OTHER,
      QPCAT.HIGH_VALUE_LOOKUP,
      QPCAT.HIGH_VALUE_OTHER
      FROM
      QA_PLAN_CHAR_ACTION_TRIGGERS QPCAT,
      QA_PLAN_CHAR_ACTIONS QPCA,
      QA_ACTIONS QA
      WHERE
      QPCAT.PLAN_ID = X_PLAN_ID AND
      QPCAT.CHAR_ID = X_CHAR_ID AND
      QPCA.PLAN_CHAR_ACTION_TRIGGER_ID = QPCAT.PLAN_CHAR_ACTION_TRIGGER_ID AND
      QA.ACTION_ID = QPCA.ACTION_ID AND
      QA.ENABLED_FLAG = 1
      ORDER BY
      QPCAT.TRIGGER_SEQUENCE) LOOP
         I := I + 1;
         PCAT_ID_TABLE(I)   := ACTIONREC.PLAN_CHAR_ACTION_TRIGGER_ID;
         ACTION_ID_TABLE(I) := ACTIONREC.ACTION_ID;
         OPERATOR_TABLE(I)  := ACTIONREC.OPERATOR;
         LV_LOOKUP_TABLE(I) := ACTIONREC.LOW_VALUE_LOOKUP;
         LV_OTHER_TABLE(I)  := ACTIONREC.LOW_VALUE_OTHER;
         HV_LOOKUP_TABLE(I) := ACTIONREC.HIGH_VALUE_LOOKUP;
         HV_OTHER_TABLE(I)  := ACTIONREC.HIGH_VALUE_OTHER;
   END LOOP;
   NUM_ACTIONS := I;


  IF (NUM_ACTIONS > 0) THEN
      UPDATE QA_RESULTS_INTERFACE QRI
         SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
             REQUEST_ID = X_REQUEST_ID,
             PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
             PROGRAM_ID = X_PROGRAM_ID,
             PROGRAM_UPDATE_DATE = SYSDATE,
             MARKER = 0
          WHERE QRI.GROUP_ID = X_GROUP_ID
            AND QRI.PROCESS_STATUS = 2
            AND MARKER IS NOT NULL;
   END IF;


   FOR I IN 1..NUM_ACTIONS LOOP
          -- Build and execute the sql.
           IF ACTION_ID_TABLE(I) = 2 THEN

                     REJECT_INPUT (COL_NAME ,ERROR_COL_NAME, X_DATATYPE,
                                   X_CHAR_ID, X_GROUP_ID, X_USER_ID,
                                   X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                                   X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                                   X_PLAN_ID , ERROR_COL_LIST , LV_LOOKUP_TABLE(I),
                                   LV_OTHER_TABLE(I), HV_LOOKUP_TABLE(I) ,
                                   HV_OTHER_TABLE(I), OPERATOR_TABLE(I),
                                   PCAT_ID_CURRENT);
           END IF;

   END LOOP;



   FOR I IN 1..NUM_ACTIONS LOOP

      -- keep track of current and next pcat_id.

      PCAT_ID_CURRENT := PCAT_ID_TABLE(I);
      IF (I = NUM_ACTIONS) THEN
         PCAT_ID_NEXT := NULL;
      ELSE
         PCAT_ID_NEXT := PCAT_ID_TABLE(I + 1);
      END IF;

      -- if this is the last action for the current action trigger, update
      -- the interface table's marker to the current pcat_id for those
      -- rows that caused actions to fire.  in this way, we are able to
      -- keep track of which rows had values that satisfied previous
      -- action triggers.  when we are moving down the list of action
      -- triggers, we will ignore rows that caused a trigger higher up in
      -- the list to fire.

      IF (NVL(PCAT_ID_NEXT, -1) <> PCAT_ID_CURRENT) THEN

          -- Build and execute the sql.
          UPDATE_MARKER (COL_NAME ,ERROR_COL_NAME, X_DATATYPE,
                                   X_CHAR_ID, X_GROUP_ID, X_USER_ID,
                                   X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                                   X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                                   X_PLAN_ID , ERROR_COL_LIST , LV_LOOKUP_TABLE(I),
                                   LV_OTHER_TABLE(I), HV_LOOKUP_TABLE(I) ,
                                   HV_OTHER_TABLE(I), OPERATOR_TABLE(I),
                                   PCAT_ID_CURRENT);

      END IF;

   END LOOP;

END VALIDATE_ACTIONS;




/* validate_revision
 *
 * special routine for validating item revisions.  called instead of
 * validate_mandatory.  inserts an error into the errors table when a
 * revision is not entered for an item under revision control.  also
 * inserts an errors when a revision is entered for an item not under
 * revision control.
 */

PROCEDURE VALIDATE_REVISION(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            PARENT_COL_NAME VARCHAR2,
                            ERROR_COL_LIST VARCHAR2,
                            X_MANDATORY NUMBER) IS
   SQL_STATEMENT VARCHAR2(2000);
   REV_COLUMN VARCHAR2(30);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME = 'REVISION') THEN
      REV_COLUMN := 'REVISION_QTY_CONTROL_CODE';
   ELSE
      REV_COLUMN := 'COMP_REVISION_QTY_CONTROL_CODE';
   END IF;

   -- first, give errors for cases where an item is under revision
   -- control and revision is mandatory, but no revision is entered.
   -- note that for revision control, a code of 1 means that it is
   -- turned off, and 2 means that it is on.

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.
   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   IF (X_MANDATORY = 1) THEN
      SQL_STATEMENT :=
         'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
         'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_NEED_REV, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          ' AND  EXISTS ' ||
                '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                 'WHERE QRI.' || COL_NAME || ' IS NULL ' ||
                 ' AND  QRI.' || REV_COLUMN || ' = 2)';

      -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

      -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
      -- in order to bind the value of ERROR_COL_NAME. kabalakr

      -- Added the other columns added as a part of Bug 3136107 to
      -- EXECUTE IMMEDIATE. suramasw

      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_NEED_REV, X_USER_ID, X_USER_ID,
          X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID, X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   END IF;

   -- second, give errors for cases where a revision is entered for an
   -- item that is not under revision control

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.
   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_CANT_HAVE_REV, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          ' AND  EXISTS ' ||
                '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                 'WHERE QRI.' || COL_NAME || ' IS NOT NULL ' ||
                 ' AND  QRI.' || REV_COLUMN || ' = 1)';

      -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

      -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
      -- in order to bind the value of ERROR_COL_NAME. kabalakr

      -- Added the other columns added as a part of Bug 3136107 to
      -- EXECUTE IMMEDIATE. suramasw

      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_CANT_HAVE_REV, X_USER_ID,
          X_USER_ID,      X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID,   X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID,   X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

END VALIDATE_REVISION;

-- Bug 3775614. Component lot and serial numbers were not validated properly.
-- Added two new procedures to validate lot/serial number.
-- Essentially it inserts error message into QA_INTERFACE_ERRORS for the following
-- situations
-- (1) Lot/Serial number is mandatory and user has entered null value to lot/serial number.
-- (2) Item is not lot/serial controlled and user has entered some value to lot/serial number.
-- (3) Item is lot/serial controlled and user entered invalid value to lot/serial number.
--
-- So if code flow escapes this procedure without any insertion into QIE, it
-- means user has entered valid value to lot/serial number.
-- We are using seperate procedure to validate lot/serial number instead of using
-- 'FROM_CLAUSE' and 'WHERE_CLAUSE' parameters in validate_steps() because
-- later introduces perfomance issues due to literal usage.
-- srhariha. Mon Aug  2 22:48:30 PDT 2004.

PROCEDURE VALIDATE_LOT_NUMBER(COL_NAME VARCHAR2,
                              ERROR_COL_NAME VARCHAR2,
                              X_GROUP_ID NUMBER,
                              X_USER_ID NUMBER,
                              X_LAST_UPDATE_LOGIN NUMBER,
                              X_REQUEST_ID NUMBER,
                              X_PROGRAM_APPLICATION_ID NUMBER,
                              X_PROGRAM_ID NUMBER,
                              PARENT_COL_NAME VARCHAR2,
                              ERROR_COL_LIST VARCHAR2,
                              X_MANDATORY NUMBER) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

   ITEM_ID_COL        VARCHAR2(30);
BEGIN
   -- Resolve item_id column.

   IF (COL_NAME = 'COMP_LOT_NUMBER') THEN
      ITEM_ID_COL := 'COMP_ITEM_ID';
   ELSE
      ITEM_ID_COL := 'ITEM_ID';
   END IF;

   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);


   -- first, give errors for cases where an item is under lot
   -- control and it is mandatory, but no lot is entered.
   -- note that for lot control, a code of 1 means that it is
   -- no lot control, and 2 means that it is full control.

   IF (X_MANDATORY = 1) THEN
      SQL_STATEMENT :=
         'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
         'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_MANDATORY, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.' || COL_NAME || ' IS NULL ' ||
         ' AND :LOT_CNTRL_CODE = (SELECT MSI.LOT_CONTROL_CODE ' ||
                                 ' FROM MTL_SYSTEM_ITEMS MSI ' ||
                                 ' WHERE MSI.INVENTORY_ITEM_ID = QRI.' || ITEM_ID_COL ||
                                 ' AND MSI.ORGANIZATION_ID = QRI.ORGANIZATION_ID)';



      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_MANDATORY, X_USER_ID, X_USER_ID,
          X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID, X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5,2;

   END IF;

   -- second, give errors for cases where lot is entered for an
   -- item that is not under lot control

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.'|| COL_NAME || ' IS NOT NULL '||
         ' AND :LOT_CNTRL_CODE = (SELECT MSI.LOT_CONTROL_CODE ' ||
                                 ' FROM MTL_SYSTEM_ITEMS MSI ' ||
                                 ' WHERE MSI.INVENTORY_ITEM_ID = QRI.'|| ITEM_ID_COL  ||
                                 ' AND MSI.ORGANIZATION_ID = QRI.ORGANIZATION_ID)';




      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID,
          X_USER_ID,      X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID,   X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID,   X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5,1;

   -- If item is lot controlled and lot is entered validate the value entered.


   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.'|| COL_NAME || ' IS NOT NULL '||
         ' AND NOT EXISTS (SELECT MLN.LOT_NUMBER ' ||
                           ' FROM MTL_LOT_NUMBERS MLN ' ||
                           ' WHERE MLN.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                           ' AND MLN.INVENTORY_ITEM_ID = QRI.' || ITEM_ID_COL ||
                           ' AND MLN.LOT_NUMBER = QRI.' || COL_NAME ||
                           ' AND (MLN.DISABLE_FLAG = :DB OR MLN.DISABLE_FLAG IS NULL))';


      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID,
          X_USER_ID,      X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID,   X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID,   X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5,2;


END VALIDATE_LOT_NUMBER;


PROCEDURE VALIDATE_SERIAL_NUMBER(COL_NAME VARCHAR2,
                                ERROR_COL_NAME VARCHAR2,
                                X_GROUP_ID NUMBER,
                                X_USER_ID NUMBER,
                                X_LAST_UPDATE_LOGIN NUMBER,
                                X_REQUEST_ID NUMBER,
                                X_PROGRAM_APPLICATION_ID NUMBER,
                                X_PROGRAM_ID NUMBER,
                                PARENT_COL_NAME VARCHAR2,
                                ERROR_COL_LIST VARCHAR2,
                                X_MANDATORY NUMBER) IS
   SQL_STATEMENT VARCHAR2(2000);
   LOT_COL VARCHAR2(30);
   ITEM_ID_COL VARCHAR2(30);
   REV_COL VARCHAR2(30);
   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

 -- Resolve item_id, lot number and revision columns.

 IF (COL_NAME = 'COMP_SERIAL_NUMBER') THEN
      ITEM_ID_COL := 'COMP_ITEM_ID';
      LOT_COL     := 'COMP_LOT_NUMBER';
      REV_COL     := 'COMP_REVISION';
 ELSE
      ITEM_ID_COL := 'ITEM_ID';
      LOT_COL     := 'LOT_NUMBER';
      REV_COL     := 'REVISION';
 END IF;


   -- first, give errors for cases where an item is under serial
   -- control and it is mandatory, but no serial is entered.
   -- note that for serial control, a code of 1 means that it is
   -- no serial control, and all other values means that it is turned on.


   IF (X_MANDATORY = 1) THEN
      SQL_STATEMENT :=
         'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
         'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_MANDATORY, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.' || COL_NAME || ' IS NULL ' ||
         ' AND :SERIAL_CNTRL_CODE <> (SELECT MSI.SERIAL_NUMBER_CONTROL_CODE ' ||
                                    '  FROM MTL_SYSTEM_ITEMS MSI ' ||
                                    '  WHERE MSI.INVENTORY_ITEM_ID = QRI.' || ITEM_ID_COL ||
                                    '  AND MSI.ORGANIZATION_ID = QRI.ORGANIZATION_ID)';


      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_MANDATORY, X_USER_ID, X_USER_ID,
          X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID, X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5,1;

   END IF;

   -- second, give errors for cases where SERIAL is entered for an
   -- item that is not under SERIAL control


   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.'|| COL_NAME || ' IS NOT NULL '||
         ' AND :SERIAL_CNTRL_CODE = (SELECT MSI.SERIAL_NUMBER_CONTROL_CODE ' ||
                              ' FROM MTL_SYSTEM_ITEMS MSI ' ||
                              ' WHERE MSI.INVENTORY_ITEM_ID = QRI.' || ITEM_ID_COL ||
                              ' AND MSI.ORGANIZATION_ID = QRI.ORGANIZATION_ID)';




      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID,
          X_USER_ID,      X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID,   X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID,   X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5,1;

   -- If item is SERIAL controlled and SERIAL is entered, validate the value entered.
   -- We should not have Serial Number validation restricted to those having
   -- current_status = 3 (Resides in Stores).Hence commenting out that line.
   -- Please see bugdb of 37723928 for more details.
   -- srhariha. Thu Aug  5 21:05:05 PDT 2004.

   --
   -- Bug 5407761
   -- Removed the filter on the column group_mark_id
   -- since it is used for internal parallelism control
   -- and is not applicable during a read only validation
   -- SHKALYAN 25-JUL-2006
   --
   -- Bug 6269522.
   -- Fixed validation of Serial Number and Item Revision validation
   -- If Lot Number and item are not passed
   -- saugupta Tue, 09 Oct 2007 07:11:47 -0700 PDT

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
         ' AND  QRI.' || PARENT_COL_NAME || ' IS NOT NULL' ||
         ' AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.'|| COL_NAME || ' IS NOT NULL '||
         ' AND NOT EXISTS (SELECT MSN.SERIAL_NUMBER ' ||
                          ' FROM MTL_SERIAL_NUMBERS MSN ' ||
                          '  WHERE MSN.SERIAL_NUMBER = QRI.' || COL_NAME ||
                          ' AND MSN.CURRENT_ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                          ' AND MSN.INVENTORY_ITEM_ID = QRI.' || ITEM_ID_COL ||
                          ' AND (QRI.'||LOT_COL||' IS NULL OR MSN.LOT_NUMBER = QRI.'||LOT_COL||')' ||
                          ' AND (QRI.'||REV_COL||' IS NULL OR MSN.REVISION = QRI.'||REV_COL||'))';

                        -- ' AND NVL(MSN.LOT_NUMBER,''@@@'') = NVL(QRI.'||LOT_COL||',''@@@'')' ||
                        --  ' AND NVL(MSN.REVISION,''@@@'') = NVL(QRI.' || REV_COL||',''@@@''))';
                        --  ' AND MSN.CURRENT_STATUS = :CS '||
                        --  ' AND (MSN.GROUP_MARK_ID IS NULL OR MSN.GROUP_MARK_ID = :GM))';

      --
      -- Bug 5407761
      -- Removed the value bound for the
      -- group_mark_id column as the filter is
      -- not applicable
      -- SHKALYAN 25-JUL-2006
      --
      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID,
          X_USER_ID,      X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID,   X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID,   X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5;
          --,-1;


END VALIDATE_SERIAL_NUMBER;


PROCEDURE VALIDATE_DATATYPES(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            X_DATATYPE NUMBER) IS
   SQL_STATEMENT VARCHAR2(2000);
   I NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_CHARACTERX VARCHAR2(150);
   INTERFACE_ID_TABLE NUMBER_TABLE;
   VALUE_TABLE CHAR150_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   -- Bug 7626523.Fp for 7568208
   -- Increasing the length of error message to
   -- 240 Characters.pdube Thu Dec 31 01:40:03 PST 2009
   -- ERRMSG VARCHAR2(30);
   ERRMSG VARCHAR2(240);
BEGIN
   I := 0;

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'SELECT TRANSACTION_INTERFACE_ID, ' || COL_NAME ||
      ' FROM QA_RESULTS_INTERFACE QRI ' ||
      ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
      '   AND QRI.PROCESS_STATUS = 2 ' ||
      '   AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
      '   AND NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL))';

   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_CHARACTERX, 150);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_CHARACTERX);
         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         VALUE_TABLE(I) := X_CHARACTERX;
      ELSE
         EXIT;
      END IF;
   END LOOP;

   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   IF (X_DATATYPE = 2) THEN
      -- Bug 7626523.Fp for 7568208
      -- Truncating the message to 240 Characters
      -- pdube Thu Dec 31 01:40:03 PST 2009
      -- ERRMSG := ERROR_INVALID_NUMBER;
      ERRMSG := SubStr(ERROR_INVALID_NUMBER,1,240);
   ELSIF (X_DATATYPE = 3) THEN
      -- Bug 7626523.Fp for 7568208
      -- Truncating the message to 240 Characters
      -- pdube Thu Dec 31 01:40:03 PST 2009
      -- ERRMSG := ERROR_INVALID_DATE;
      ERRMSG := SubStr(ERROR_INVALID_DATE,1,240);

   -- For Timezone Compliance bug 3179845.
   -- Validate the datetime and elements and give error in case of failure.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF (X_DATATYPE = 6) THEN
      -- Bug 7626523.Fp for 7568208
      -- Truncating the message to 240 Characters
      -- pdube Thu Dec 31 01:40:03 PST 2009
      -- ERRMSG := ERROR_INVALID_DATETIME;
      ERRMSG := SubStr(ERROR_INVALID_DATETIME,1,240);
   END IF;


   FOR I IN 1..NUM_ROWS LOOP
      IF (QLTTRAFB.VALIDATE_TYPE(VALUE_TABLE(I), X_DATATYPE) = FALSE) THEN
         INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
         (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERRMSG,
          SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
      END IF;
   END LOOP;

END VALIDATE_DATATYPES;


PROCEDURE FORMAT_DATATYPES(COL_NAME VARCHAR2,
                           ERROR_COL_NAME VARCHAR2,
                           X_GROUP_ID NUMBER,
                           X_USER_ID NUMBER,
                           X_LAST_UPDATE_LOGIN NUMBER,
                           X_REQUEST_ID NUMBER,
                           X_PROGRAM_APPLICATION_ID NUMBER,
                           X_PROGRAM_ID NUMBER,
                           X_DATATYPE NUMBER,
                           X_DECIMAL_PRECISION NUMBER,
                           ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN

   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   --
   -- Don't do anything for hardcoded date columns
   -- bso
   --

   -- For Timezone Compliance bug 3179845. Added datetime elements in the below IF condn.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   IF x_datatype IN (3, 6) AND NOT (col_name LIKE 'CHARACTER%') THEN
       RETURN;
   END IF;

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' ||
      'SET LAST_UPDATE_DATE = SYSDATE, ' ||
          'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID = :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
        COL_NAME || ' = ';

   IF (X_DATATYPE = 2) THEN
      --
      -- For number type, there are two cases, if it is hardcoded, then
      -- use a simple ROUND function:
      --
      IF NOT col_name LIKE 'CHARACTER%' THEN     -- hardcoded
	  SQL_STATEMENT := SQL_STATEMENT ||
            'TO_CHAR(ROUND(' || COL_NAME || ', ' ||
            TO_CHAR(NVL(X_DECIMAL_PRECISION, 240)) || ')) ';
      ELSE
      --
      -- If it is not hardcoded, then convert number to a Number first.
      -- Then convert it back to canonical format.
      --
	  SQL_STATEMENT := SQL_STATEMENT ||
              'qltdate.number_to_canon(round(qltdate.any_to_number(' ||
	      COL_NAME || '), ' || to_char(nvl(X_DECIMAL_PRECISION, 240)) ||
	      ')) ';
      END IF;

   -- For Timezone Compliance bug 3179845. Convert the datetime value to canonical format.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF (X_DATATYPE IN (3,6)) THEN
      SQL_STATEMENT := SQL_STATEMENT ||
          'qltdate.any_to_canon(' || COL_NAME || ') ';
   END IF;

   SQL_STATEMENT := SQL_STATEMENT ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

   EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                         X_REQUEST_ID,
                                         X_PROGRAM_APPLICATION_ID,
                                         X_PROGRAM_ID,
                                         X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END FORMAT_DATATYPES;


PROCEDURE VALIDATE_LOCATOR(COL_NAME VARCHAR2,
                        ERROR_COL_NAME VARCHAR2,
                        X_GROUP_ID NUMBER,
                        X_USER_ID NUMBER,
                        X_LAST_UPDATE_LOGIN NUMBER,
                        X_REQUEST_ID NUMBER,
                        X_PROGRAM_APPLICATION_ID NUMBER,
                        X_PROGRAM_ID NUMBER,
                        ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   I NUMBER := 0;
   V BOOLEAN;
   CID NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_SEGS VARCHAR2(2000);
   X_ORG_ID NUMBER;
   X_SUB_LOC_TYPE NUMBER;
   X_LOC_CTRL_CODE NUMBER;
   X_RESTRICT_LOC_CODE NUMBER;
   X_SUBINV VARCHAR2(10);
   X_ORG_LOC_CTRL NUMBER;
   X_NEG_INV NUMBER;
   X_ITEM_ID NUMBER;
   INTERFACE_ID_TABLE NUMBER_TABLE;
   SEGS_TABLE CHAR2000_TABLE;
   ORG_ID_TABLE NUMBER_TABLE;
   SUB_LOC_TYPE_TABLE NUMBER_TABLE;
   LOC_CTRL_CODE_TABLE NUMBER_TABLE;
   RESTRICT_LOC_CODE_TABLE NUMBER_TABLE;
   SUBINV_TABLE CHAR30_TABLE;
   ORG_LOC_CTRL_TABLE NUMBER_TABLE;
   NEG_INV_TABLE NUMBER_TABLE;
   ITEM_ID_TABLE NUMBER_TABLE;
   GEN_LOC_CTRL_TABLE NUMBER_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   ID_FIELD VARCHAR2(30);
   COMP_TEXT VARCHAR2(6);
   X_WHERE_CLAUSE VARCHAR2(250);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME = 'COMP_LOCATOR') THEN
      COMP_TEXT := 'COMP_';
      ID_FIELD := 'COMP_LOCATOR_ID';
   ELSIF (COL_NAME = 'LOCATOR') THEN
      COMP_TEXT := '';
      ID_FIELD := 'LOCATOR_ID';
   END IF;

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw.
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
         'SELECT QRI.TRANSACTION_INTERFACE_ID, ' ||
         'QRI.' || COL_NAME || ', ' ||
         'QRI.ORGANIZATION_ID, ' ||
         'QRI.' || COMP_TEXT || 'SUB_LOCATOR_TYPE, ' ||
         'QRI.' || COMP_TEXT || 'LOCATION_CONTROL_CODE, ' ||
         'QRI.' || COMP_TEXT || 'RESTRICT_LOCATORS_CODE, ' ||
         'QRI.' || COMP_TEXT || 'SUBINVENTORY, ' ||
         'MP.STOCK_LOCATOR_CONTROL_CODE, ' ||
         'MP.NEGATIVE_INV_RECEIPT_CODE, ' ||
         'QRI.' || COMP_TEXT || 'ITEM_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI, ' ||
         '     MTL_PARAMETERS MP ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
                  'QRI.TRANSACTION_INTERFACE_ID ' ||
               'AND QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL)) '||
         ' AND QRI.ORGANIZATION_ID = MP.ORGANIZATION_ID';

   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_SEGS, 2000);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 3, X_ORG_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 4, X_SUB_LOC_TYPE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 5, X_LOC_CTRL_CODE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 6, X_RESTRICT_LOC_CODE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 7, X_SUBINV, 10);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 8, X_ORG_LOC_CTRL);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 9, X_NEG_INV);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 10, X_ITEM_ID);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_SEGS);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 3, X_ORG_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 4, X_SUB_LOC_TYPE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 5, X_LOC_CTRL_CODE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 6, X_RESTRICT_LOC_CODE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 7, X_SUBINV);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 8, X_ORG_LOC_CTRL);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 9, X_NEG_INV);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 10, X_ITEM_ID);

         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         SEGS_TABLE(I) := X_SEGS;
         ORG_ID_TABLE(I) := X_ORG_ID;
         SUB_LOC_TYPE_TABLE(I) := X_SUB_LOC_TYPE;
         LOC_CTRL_CODE_TABLE(I) := X_LOC_CTRL_CODE;
         RESTRICT_LOC_CODE_TABLE(I) := X_RESTRICT_LOC_CODE;
         SUBINV_TABLE(I) := X_SUBINV;
         ORG_LOC_CTRL_TABLE(I) := X_ORG_LOC_CTRL;
         NEG_INV_TABLE(I) := X_NEG_INV;
         ITEM_ID_TABLE(I) := X_ITEM_ID;
      ELSE
         EXIT;
      END IF;
   END LOOP;


   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   FOR I IN 1..NUM_ROWS LOOP
      GEN_LOC_CTRL_TABLE(I) := QLTINVCB.CONTROL(
            ORG_CONTROL=>ORG_LOC_CTRL_TABLE(I),
            SUB_CONTROL=>SUB_LOC_TYPE_TABLE(I),
            ITEM_CONTROL=>LOC_CTRL_CODE_TABLE(I),
            RESTRICT_FLAG=>RESTRICT_LOC_CODE_TABLE(I),
            NEG_FLAG=>NEG_INV_TABLE(I));


      IF (GEN_LOC_CTRL_TABLE(I) = 1) THEN
         -- not under locator control.  locator must be null

         IF (SEGS_TABLE(I) IS NOT NULL) THEN
            INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
               (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_CANT_HAVE_LOC,
               SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
               X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
         END IF;

         -- update interface table with gen loc ctrl value

         SQL_STATEMENT :=
               'UPDATE QA_RESULTS_INTERFACE QRI ' ||
               'SET LAST_UPDATE_DATE = SYSDATE, ' ||
                  'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
                 ', REQUEST_ID = :REQUEST_ID ' ||
                 ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
                 ', PROGRAM_ID = :PROGRAM_ID ' ||
                 ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
                 COMP_TEXT || 'GEN_LOC_CTRL_CODE = :GEN_LOC_CTRL_TABLE ' ||
                 ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
                  ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
                  ' AND  QRI.PROCESS_STATUS = 2 ' ||
                   'AND  NOT EXISTS
                         (SELECT ''X'' ' ||
                         'FROM   QA_INTERFACE_ERRORS QIE ' ||
                         'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                      'QRI.TRANSACTION_INTERFACE_ID ' ||
                        'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

         EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                               X_REQUEST_ID,
                                               X_PROGRAM_APPLICATION_ID,
                                               X_PROGRAM_ID,
                                               GEN_LOC_CTRL_TABLE(I),
                                               X_GROUP_ID,
                                               INTERFACE_ID_TABLE(I),
          l_col1, l_col2, l_col3, l_col4, l_col5;

         -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

      ELSIF (GEN_LOC_CTRL_TABLE(I) IN (2, 3)) THEN
-- !! maybe should validate mandatory here

         IF (GEN_LOC_CTRL_TABLE(I) = 2) THEN

            IF (RESTRICT_LOC_CODE_TABLE(I) = 1) THEN
               X_WHERE_CLAUSE := '(DISABLE_DATE > SYSDATE OR ' ||
                  'DISABLE_DATE IS NULL) AND SUBINVENTORY_CODE = ' ||
                  SUBINV_TABLE(I) || ' AND INVENTORY_LOCATION_ID IN ' ||
                  '(SELECT SECONDARY_LOCATOR FROM MTL_SECONDARY_LOCATORS ' ||
                  'WHERE INVENTORY_ITEM_ID = ' || TO_CHAR(ITEM_ID_TABLE(I)) ||
                  ' AND ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ||
                  ' AND SUBINVENTORY_CODE = ' || SUBINV_TABLE(I) || ')';
            ELSIF (RESTRICT_LOC_CODE_TABLE(I) = 2) THEN
               X_WHERE_CLAUSE := '(DISABLE_DATE > SYSDATE OR ' ||
               'DISABLE_DATE IS NULL) AND (NVL(SUBINVENTORY_CODE, ''Z'')) ' ||
               '= ' || '''' || SUBINV_TABLE(I) || '''';
            END IF;

            -- By mistake i had removed the following piece of code when
            -- arcsing in the file in version 115.49. Included it when
            -- fixing bug 2649257.suramasw.

            V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CHECK_COMBINATION',
                  'INV', 'MTLL', 101, SEGS_TABLE(I), 'V', NULL, 'ALL',
                  ORG_ID_TABLE(I), NULL, X_WHERE_CLAUSE);

            -- End of inclusions for bug 2649257.

         ELSIF (GEN_LOC_CTRL_TABLE(I) = 3) THEN

            V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CREATE_COMBINATION',
                  'INV', 'MTLL', 101, SEGS_TABLE(I), 'V', NULL, 'ALL',
                  ORG_ID_TABLE(I));

         END IF;

         IF (V) THEN

          -- get the flex combination id and update the interface table.
          -- set cid and x_org_id, which are used by the cursor.

          CID := FND_FLEX_KEYVAL.COMBINATION_ID;

          -- Added the following IF condition. Before the fix when the locator
          -- control is 'Predefined' and the user passes a wrong value for locator
          -- then the collection import will complete normal but the combination_id
          -- (CID) generated above will be -1 because the combination will not be
          -- available in the system.So after import the user opens UQR or VQR an
          -- error is thrown saying the combination doesn't exist and the locator
          -- field is blank. After this fix,if CID is valid(>0) then only imported
          -- records will be validated as successful and moved to qa_results table
          -- else it will error out in the interface table as 'Invalid Value'.
          -- Bug 2649257.suramasw.

          IF CID > 0 THEN

            X_ORG_ID := ORG_ID_TABLE(I);

            -- update interface table with locator id and gen loc ctrl value

            -- Bug 3136107.
            -- SQL Bind project. Code modified to use bind variables instead of literals
            -- Same as the fix done for Bug 3079312.suramasw.

            SQL_STATEMENT :=
               'UPDATE QA_RESULTS_INTERFACE QRI ' ||
               'SET LAST_UPDATE_DATE = SYSDATE, ' ||
                   'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
                 ', REQUEST_ID = :REQUEST_ID ' ||
                 ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
                 ', PROGRAM_ID = :PROGRAM_ID ' ||
                 ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
                 ID_FIELD || ' = :CID ' ||
                 ', ' || COMP_TEXT || 'GEN_LOC_CTRL_CODE = :GEN_LOC_CTRL_TABLE ' ||
                 ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
                  ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
                  ' AND  QRI.PROCESS_STATUS = 2 ' ||
                   'AND  NOT EXISTS
                         (SELECT ''X'' ' ||
                         'FROM   QA_INTERFACE_ERRORS QIE ' ||
                         'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                      'QRI.TRANSACTION_INTERFACE_ID ' ||
                        'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

              EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                                    X_REQUEST_ID,
                                                    X_PROGRAM_APPLICATION_ID,
                                                    X_PROGRAM_ID,
                                                    CID,
                                                    GEN_LOC_CTRL_TABLE(I),
                                                    X_GROUP_ID,
                                                    INTERFACE_ID_TABLE(I),
                                                    l_col1, l_col2, l_col3, l_col4, l_col5;

            -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

         ELSE
            INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
            (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
             SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);

         END IF; -- CID > 0
       --Bug 3766000
       -- While Importing Results, no error is being thrown even when we
       -- are specifying an existent locator but from different subinventory
       -- This happens as VALIDATE_SEGS Returns false for a wrong locator value
       -- but returns true for non exixtent locator value. Due to this behaviour
       -- we are checking the value of CID(combination ID) to test if the locator
       -- is correct or not.
       -- Below introducing a new if condition to handle if validate_segs returns
       -- false value in V
       -- saugupta Fri, 30 Jul 2004 03:10:01 -0700 PDT
       ELSE
          INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
             ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
             CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
             PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
          (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
           SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);

       END IF; -- (V) THEN
      END IF;
   END LOOP;

END VALIDATE_LOCATOR;


-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


PROCEDURE VALIDATE_TO_LOCATOR(COL_NAME VARCHAR2,
                        ERROR_COL_NAME VARCHAR2,
                        X_GROUP_ID NUMBER,
                        X_USER_ID NUMBER,
                        X_LAST_UPDATE_LOGIN NUMBER,
                        X_REQUEST_ID NUMBER,
                        X_PROGRAM_APPLICATION_ID NUMBER,
                        X_PROGRAM_ID NUMBER,
                        ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   I NUMBER := 0;
   V BOOLEAN;
   CID NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_SEGS VARCHAR2(2000);
   X_ORG_ID NUMBER;
   X_TO_SUB_LOC_TYPE NUMBER;
   X_LOC_CTRL_CODE NUMBER;
   X_RESTRICT_LOC_CODE NUMBER;
   X_TO_SUBINV VARCHAR2(10);
   X_ORG_LOC_CTRL NUMBER;
   X_NEG_INV NUMBER;
   X_ITEM_ID NUMBER;
   INTERFACE_ID_TABLE NUMBER_TABLE;
   SEGS_TABLE CHAR2000_TABLE;
   ORG_ID_TABLE NUMBER_TABLE;
   TO_SUB_LOC_TYPE_TABLE NUMBER_TABLE;
   LOC_CTRL_CODE_TABLE NUMBER_TABLE;
   RESTRICT_LOC_CODE_TABLE NUMBER_TABLE;
   TO_SUBINV_TABLE CHAR30_TABLE;
   ORG_LOC_CTRL_TABLE NUMBER_TABLE;
   NEG_INV_TABLE NUMBER_TABLE;
   ITEM_ID_TABLE NUMBER_TABLE;
   GEN_LOC_CTRL_TABLE NUMBER_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   ID_FIELD VARCHAR2(30) := 'TO_LOCATOR_ID';
   X_WHERE_CLAUSE VARCHAR2(250);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw.
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
         'SELECT QRI.TRANSACTION_INTERFACE_ID, ' ||
         'QRI.' || COL_NAME || ', ' ||
         'QRI.ORGANIZATION_ID, ' ||
         'QRI.TO_SUB_LOCATOR_TYPE, ' ||
         'QRI.LOCATION_CONTROL_CODE, ' ||
         'QRI.RESTRICT_LOCATORS_CODE, ' ||
         'QRI.TO_SUBINVENTORY, ' ||
         'MP.STOCK_LOCATOR_CONTROL_CODE, ' ||
         'MP.NEGATIVE_INV_RECEIPT_CODE, ' ||
         'QRI.ITEM_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI, ' ||
         '     MTL_PARAMETERS MP ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
                  'QRI.TRANSACTION_INTERFACE_ID ' ||
               'AND QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL))' ||
         ' AND QRI.ORGANIZATION_ID = MP.ORGANIZATION_ID';


   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_SEGS, 2000);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 3, X_ORG_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 4, X_TO_SUB_LOC_TYPE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 5, X_LOC_CTRL_CODE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 6, X_RESTRICT_LOC_CODE);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 7, X_TO_SUBINV, 10);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 8, X_ORG_LOC_CTRL);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 9, X_NEG_INV);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 10, X_ITEM_ID);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_SEGS);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 3, X_ORG_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 4, X_TO_SUB_LOC_TYPE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 5, X_LOC_CTRL_CODE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 6, X_RESTRICT_LOC_CODE);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 7, X_TO_SUBINV);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 8, X_ORG_LOC_CTRL);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 9, X_NEG_INV);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 10, X_ITEM_ID);

         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         SEGS_TABLE(I) := X_SEGS;
         ORG_ID_TABLE(I) := X_ORG_ID;
         TO_SUB_LOC_TYPE_TABLE(I) := X_TO_SUB_LOC_TYPE;
         LOC_CTRL_CODE_TABLE(I) := X_LOC_CTRL_CODE;
         RESTRICT_LOC_CODE_TABLE(I) := X_RESTRICT_LOC_CODE;
         TO_SUBINV_TABLE(I) := X_TO_SUBINV;
         ORG_LOC_CTRL_TABLE(I) := X_ORG_LOC_CTRL;
         NEG_INV_TABLE(I) := X_NEG_INV;
         ITEM_ID_TABLE(I) := X_ITEM_ID;
      ELSE
         EXIT;
      END IF;
   END LOOP;
   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   FOR I IN 1..NUM_ROWS LOOP
      GEN_LOC_CTRL_TABLE(I) := QLTINVCB.CONTROL(
            ORG_CONTROL=>ORG_LOC_CTRL_TABLE(I),
            SUB_CONTROL=>TO_SUB_LOC_TYPE_TABLE(I),
            ITEM_CONTROL=>LOC_CTRL_CODE_TABLE(I),
            RESTRICT_FLAG=>RESTRICT_LOC_CODE_TABLE(I),
            NEG_FLAG=>NEG_INV_TABLE(I));

      IF (GEN_LOC_CTRL_TABLE(I) = 1) THEN

         -- not under locator control.  locator must be null

         IF (SEGS_TABLE(I) IS NOT NULL) THEN
            INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
               (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_CANT_HAVE_LOC,
               SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
               X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
         END IF;
         -- update interface table with gen loc ctrl value

         SQL_STATEMENT :=
               'UPDATE QA_RESULTS_INTERFACE QRI ' ||
               'SET LAST_UPDATE_DATE = SYSDATE, ' ||
                  'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
                 ', REQUEST_ID = :REQUEST_ID ' ||
                 ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
                 ', PROGRAM_ID = :PROGRAM_ID ' ||
                 ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
                 'GEN_LOC_CTRL_CODE = :GEN_LOC_CTRL_TABLE ' ||
                 ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
                  ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
                  ' AND  QRI.PROCESS_STATUS = 2 ' ||
                   'AND  NOT EXISTS
                         (SELECT ''X'' ' ||
                         'FROM   QA_INTERFACE_ERRORS QIE ' ||
                         'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                      'QRI.TRANSACTION_INTERFACE_ID ' ||
                        'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

         EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                               X_REQUEST_ID,
                                               X_PROGRAM_APPLICATION_ID,
                                               X_PROGRAM_ID,
                                               GEN_LOC_CTRL_TABLE(I),
                                               X_GROUP_ID,
                                               INTERFACE_ID_TABLE(I),
                                               l_col1, l_col2, l_col3, l_col4, l_col5;

         -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

      ELSIF (GEN_LOC_CTRL_TABLE(I) IN (2, 3)) THEN
-- !! maybe should validate mandatory here

         IF (GEN_LOC_CTRL_TABLE(I) = 2) THEN

            IF (RESTRICT_LOC_CODE_TABLE(I) = 1) THEN
               X_WHERE_CLAUSE := '(DISABLE_DATE > SYSDATE OR ' ||
                  'DISABLE_DATE IS NULL) AND SUBINVENTORY_CODE = ' ||
                  TO_SUBINV_TABLE(I) || ' AND INVENTORY_LOCATION_ID IN ' ||
                  '(SELECT SECONDARY_LOCATOR FROM MTL_SECONDARY_LOCATORS ' ||
                  'WHERE INVENTORY_ITEM_ID = ' || TO_CHAR(ITEM_ID_TABLE(I)) ||
                  ' AND ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ||
                  ' AND SUBINVENTORY_CODE = ' || TO_SUBINV_TABLE(I) || ')';
            ELSIF (RESTRICT_LOC_CODE_TABLE(I) = 2) THEN
               X_WHERE_CLAUSE := '(DISABLE_DATE > SYSDATE OR ' ||
               'DISABLE_DATE IS NULL) AND (NVL(SUBINVENTORY_CODE, ''Z'')) ' ||
               '= ' || '''' || TO_SUBINV_TABLE(I) || '''';
            END IF;

            V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CHECK_COMBINATION',
                  'INV', 'MTLL', 101, SEGS_TABLE(I), 'V', NULL, 'ALL',
                  ORG_ID_TABLE(I), NULL, X_WHERE_CLAUSE);

         ELSIF (GEN_LOC_CTRL_TABLE(I) = 3) THEN

            V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CREATE_COMBINATION',
                  'INV', 'MTLL', 101, SEGS_TABLE(I), 'V', NULL, 'ALL',
                  ORG_ID_TABLE(I));
         END IF;
         IF (V) THEN

          -- get the flex combination id and update the interface table.
          -- set cid and x_org_id, which are used by the cursor.

          CID := FND_FLEX_KEYVAL.COMBINATION_ID;

          -- Added the following IF condition. Before the fix when the locator
          -- control is 'Predefined' and the user passes a wrong value for to_locator
          -- then the collection import will complete normal but the combination_id
          -- (CID) generated above will be -1 because the combination will not be
          -- available in the system.So after import the user opens UQR or VQR an
          -- error is thrown saying the combination doesn't exist and the to_locator
          -- field is blank. After this fix,if CID is valid(>0) then only imported
          -- records will be validated as successful and moved to qa_results table
          -- else it will error out in the interface table as 'Invalid Value'.
          -- Bug 2649257.suramasw.

          IF CID > 0 THEN

            X_ORG_ID := ORG_ID_TABLE(I);

            -- update interface table with to_locator id and gen loc ctrl value

            -- Bug 3136107.
            -- SQL Bind project. Code modified to use bind variables instead of literals
            -- Same as the fix done for Bug 3079312.suramasw.

            SQL_STATEMENT :=
               'UPDATE QA_RESULTS_INTERFACE QRI ' ||
               'SET LAST_UPDATE_DATE = SYSDATE, ' ||
                  'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
                 ', REQUEST_ID = :REQUEST_ID ' ||
                 ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
                 ', PROGRAM_ID = :PROGRAM_ID ' ||
                 ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
                 ID_FIELD || ' = :CID ' ||
                 ', GEN_LOC_CTRL_CODE = :GEN_LOC_CTRL_TABLE ' ||
                 ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
                  ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
                  ' AND  QRI.PROCESS_STATUS = 2 ' ||
                   'AND  NOT EXISTS
                         (SELECT ''X'' ' ||
                         'FROM   QA_INTERFACE_ERRORS QIE ' ||
                         'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                      'QRI.TRANSACTION_INTERFACE_ID ' ||
                        'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

              EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                                    X_REQUEST_ID,
                                                    X_PROGRAM_APPLICATION_ID,
                                                    X_PROGRAM_ID,
                                                    CID,
                                                    GEN_LOC_CTRL_TABLE(I),
                                                    X_GROUP_ID,
                                                    INTERFACE_ID_TABLE(I),
                                                    l_col1, l_col2, l_col3, l_col4, l_col5;

            -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
         ELSE
            INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
            (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
             SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);

         END IF; -- CID > 0

       --Bug 3766000
       -- While Importing Results, no error is being thrown even when we
       -- are specifying an existent locator but from different subinventory
       -- This happens as VALIDATE_SEGS Returns false for a wrong locator value
       -- but returns true for non exixtent locator value. Due to this behaviour
       -- we are checking the value of CID(combination ID) to test if the locator
       -- is correct or not.
       -- Below introducing a new if condition to handle if validate_segs returns
       -- false value in V
       -- saugupta Fri, 30 Jul 2004 03:10:01 -0700 PDT
       ELSE
          INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
             ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
             CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
             PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
          (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
           SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);

       END IF; -- (V) THEN
      END IF;
   END LOOP;

END VALIDATE_TO_LOCATOR;

-- End of inclusions for NCM Hardcode Elements.


-- This procedure validate ITEM and COMP_ITEM segs
-- It takes care of valiadtion of COMP_ITEM if it
-- is dependent on ITEM.
-- saugupta Fri, 16 Jul 2004 00:09:54 -0700 PDT

PROCEDURE VALIDATE_ITEM(COL_NAME VARCHAR2,
                           ERROR_COL_NAME VARCHAR2,
                           X_GROUP_ID NUMBER,
                           X_USER_ID NUMBER,
                           X_LAST_UPDATE_LOGIN NUMBER,
                           X_REQUEST_ID NUMBER,
                           X_PROGRAM_APPLICATION_ID NUMBER,
                           X_PROGRAM_ID NUMBER,
                           ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   I NUMBER := 0;
   V BOOLEAN;
   CID NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_SEGS VARCHAR2(2000);
   X_ORG_ID NUMBER;
   X_LINE_ID NUMBER;
   INTERFACE_ID_TABLE NUMBER_TABLE;
   SEGS_TABLE CHAR2000_TABLE;
   ORG_ID_TABLE NUMBER_TABLE;
   LINE_ID_TABLE NUMBER_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   ERRMSG VARCHAR2(30);
   ID_FIELD VARCHAR2(30);
   CURSOR C IS SELECT RESTRICT_SUBINVENTORIES_CODE,
                      RESTRICT_LOCATORS_CODE,
                      LOCATION_CONTROL_CODE,
                      REVISION_QTY_CONTROL_CODE
               FROM   MTL_SYSTEM_ITEMS
               WHERE  INVENTORY_ITEM_ID = CID
                 AND  ORGANIZATION_ID = X_ORG_ID;

   ITM_RST_SINV NUMBER;
   ITM_RST_LOC NUMBER;
   ITM_LOC_CTRL NUMBER;
   REV_CTRL_CODE NUMBER;

   COMP_TEXT VARCHAR2(6);

   -- Bug 3765678. COMP_ITEM is not getting validated along
   -- with ITEM if it is dependent on ITEM. Search for Bug#
   -- to get the complete code changes. Below increasing the
   -- length of String to accomodate new X_WHERE_CLAUSE
   -- built to validate COMP_ITEM.
   -- saugupta Fri, 16 Jul 2004 03:11:44 -0700 PDT
   --  X_WHERE_CLAUSE VARCHAR2(250);
   X_WHERE_CLAUSE VARCHAR2(1000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME = 'COMP_ITEM') THEN
      ID_FIELD := 'COMP_ITEM_ID';
      COMP_TEXT := 'COMP_';
   ELSIF (COL_NAME = 'ITEM') THEN
      ID_FIELD := 'ITEM_ID';
      COMP_TEXT := '';

      -- Bug 3765678. COMP_ITEM is not getting validated along
      -- with ITEM if it is dependent on ITEM.
      -- Introduced a new global variable G_ITEM_ID
      -- to store ITEM_ID so COMP_ITEM can be verified
      -- against it. Initializing it to NULL for ITEM.
      -- saugupta Fri, 16 Jul 2004 02:58:10 -0700 PDT


      -- Bug 3807782. COMP_ITEM was not getting properly validated for
      -- bulk insert. G_ITEM_ID is not used in the new logic.
      -- So commenting out the line below.
      -- srhariha. Wed Aug  4 23:33:07 PDT 2004.
      -- G_ITEM_ID := NULL;

   END IF;

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw.
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
         'SELECT TRANSACTION_INTERFACE_ID, ' || COL_NAME ||
         ', ORGANIZATION_ID, LINE_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
                  'QRI.TRANSACTION_INTERFACE_ID ' ||
               'AND QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL))';

   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_SEGS, 2000);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 3, X_ORG_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 4, X_LINE_ID);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_SEGS);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 3, X_ORG_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 4, X_LINE_ID);
         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         SEGS_TABLE(I) := X_SEGS;
         ORG_ID_TABLE(I) := X_ORG_ID;
         LINE_ID_TABLE(I) := X_LINE_ID;
      ELSE
         EXIT;
      END IF;
   END LOOP;

   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   -- Added the UNION condition in the X_WHERE_CLAUSE below to
   -- validate Flow Items associated with Production Line.
   -- Bug 2791447.suramasw.Tue Feb 11 00:06:05 PST 2003

   FOR I IN 1..NUM_ROWS LOOP
      IF ((COL_NAME = 'ITEM') AND (LINE_ID_TABLE(I) IS NOT NULL)) THEN
         X_WHERE_CLAUSE := 'INVENTORY_ITEM_ID IN ' ||
               '((SELECT PRIMARY_ITEM_ID FROM WIP_REP_ASSY_VAL_V ' ||
               'WHERE ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ||
               ' AND LINE_ID = ' || TO_CHAR(LINE_ID_TABLE(I)) || ')' ||
               'UNION' ||
               '(SELECT ASSEMBLY_ITEM_ID FROM BOM_OPERATIONAL_ROUTINGS ' ||
               'WHERE ORGANIZATION_ID =  ' || TO_CHAR(ORG_ID_TABLE(I)) ||
               'AND LINE_ID = ' || TO_CHAR(LINE_ID_TABLE(I)) || '))';


      -- Bug 3765678. COMP_ITEM is not getiing validated if it is
      -- dependent on ITEM. forming X_WHERE_CLAUSE below for passing it
      -- to VALIDATE_SEGS() to make sure that COMP_ITEM
      -- gets properly validated if dependent on ITEM.
      -- We used G_ITEM_ID in the clause to check for COMP_ITEM
      -- included for ITEM. Before coming here ITEM is already validated
      -- and G_ITEM_ID contains value of ITEM.
      -- saugupta Fri, 16 Jul 2004 03:05:15 -0700 PDT

      -- Bug 3807782. COMP_ITEM was not getting properly validated for
      -- bulk insert. G_ITEM_ID is not used in the new logic. Dependency is
      -- not validated using the WHERE clause parameter to FND call.
      -- So commenting out the logic below.
      -- srhariha. Wed Aug  4 23:33:07 PDT 2004.
      /*ELSIF ((COL_NAME = 'COMP_ITEM') AND (G_ITEM_ID IS NOT NULL)) THEN
             X_WHERE_CLAUSE := 'INVENTORY_ITEM_ID IN ' ||
               ' ( SELECT COMPONENT_ITEM_ID ' ||
               ' FROM BOM_INVENTORY_COMPONENTS BIC, BOM_BILL_OF_MATERIALS BOM ' ||
               ' WHERE BOM.ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ||
               ' AND BOM.ASSEMBLY_ITEM_ID = ' || TO_CHAR(G_ITEM_ID) ||
               ' AND BIC.BILL_SEQUENCE_ID = BOM.BILL_SEQUENCE_ID ' ||
               ' AND BIC.EFFECTIVITY_DATE <=  SYSDATE ' ||
               ' AND NVL(BIC.DISABLE_DATE, SYSDATE+1) > SYSDATE )';*/

      ELSE
         X_WHERE_CLAUSE := NULL;
      END IF;

      V := FND_FLEX_KEYVAL.VALIDATE_SEGS(
            'CHECK_COMBINATION',
            'INV', 'MSTK', 101, SEGS_TABLE(I), 'V',
            NULL, 'ALL', ORG_ID_TABLE(I), NULL, X_WHERE_CLAUSE);

      IF (V) THEN

         -- get the flex combination id and update the interface table.
         -- set cid and x_org_id, which are used by the cursor.

         CID := FND_FLEX_KEYVAL.COMBINATION_ID;
         X_ORG_ID := ORG_ID_TABLE(I);

         -- Bug 3765678. COMP_ITEM is not getting validated along
         -- with ITEM if it is dependent on ITEM. Storing the value
         -- ITEM used in above ELSIF for validation of COMP_ITEM
         -- saugupta Fri, 16 Jul 2004 03:13:52 -0700 PDT

         -- Bug 3807782. COMP_ITEM was not getting properly validated for
         -- bulk insert. G_ITEM_ID is not used in the new logic.
         -- So commenting out the line below.
         -- srhariha. Wed Aug  4 23:33:07 PDT 2004.

         /*IF (COL_NAME = 'ITEM') THEN
             G_ITEM_ID := CID;
           END IF;*/


         -- bring in other columns from the items table.  we'll need these
         -- values later when validating revision, subinventory, and locator

         OPEN C;
         FETCH C INTO ITM_RST_SINV, ITM_RST_LOC, ITM_LOC_CTRL, REV_CTRL_CODE;
         CLOSE C;

         -- Bug 3136107.
         -- SQL Bind project. Code modified to use bind variables instead of literals
         -- Same as the fix done for Bug 3079312.suramasw.

         -- Bug 4270911. CU2 SQL Literal fix. TD #24
         -- Use bind variables for inventory_code, locator_code etc.
         -- srhariha. Fri Apr 15 05:05:29 PDT 2005.


         SQL_STATEMENT :=
            'UPDATE QA_RESULTS_INTERFACE QRI ' ||
            'SET LAST_UPDATE_DATE = SYSDATE, ' ||
               'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
              ', REQUEST_ID = :REQUEST_ID ' ||
              ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
              ', PROGRAM_ID = :PROGRAM_ID ' ||
              ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
              ID_FIELD || ' = :CID ' ||
              ', ' || COMP_TEXT || 'RESTRICT_SUBINV_CODE = :BIND_RST_SINV ' ||
              ', ' || COMP_TEXT || 'RESTRICT_LOCATORS_CODE = :BIND_RST_LOC ' ||
              ', ' || COMP_TEXT || 'LOCATION_CONTROL_CODE = :BIND_LOC_CTRL ' ||
              ', ' || COMP_TEXT || 'REVISION_QTY_CONTROL_CODE = :BIND_REV_CTRL ' ||
              ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
               ' AND QRI.TRANSACTION_INTERFACE_ID =  :INTERFACE_ID_TABLE ' ||
               ' AND  QRI.PROCESS_STATUS = 2 ' ||
                'AND  NOT EXISTS
                      (SELECT ''X'' ' ||
                      'FROM   QA_INTERFACE_ERRORS QIE ' ||
                      'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                                   'QRI.TRANSACTION_INTERFACE_ID ' ||
                        'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

          ITM_RST_SINV  :=  TO_CHAR(NVL(ITM_RST_SINV, 2));
          ITM_RST_LOC   :=  TO_CHAR(NVL(ITM_RST_LOC, 1));
          ITM_LOC_CTRL  :=  TO_CHAR(NVL(ITM_LOC_CTRL, 1));
          REV_CTRL_CODE :=  TO_CHAR(NVL(REV_CTRL_CODE, 1));

          EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                                 X_REQUEST_ID,
                                                 X_PROGRAM_APPLICATION_ID,
                                                 X_PROGRAM_ID,
                                                 CID,
                                                 ITM_RST_SINV,
                                                 ITM_RST_LOC,
                                                 ITM_LOC_CTRL,
                                                 REV_CTRL_CODE,
                                                 X_GROUP_ID,
                                                 INTERFACE_ID_TABLE(I),
                                                 l_col1, l_col2, l_col3, l_col4, l_col5;


         -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
      ELSE
         INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
         (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
          SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
      END IF;
   END LOOP;


    -- Bug 3807782. COMP_ITEM was not getting properly validated for  bulk insert.
    -- Import design discourages procedural approach to validate, which we were using before.
    -- New logic implemented here.
    -- Check dependeny between ITEM and COMP_ITEM after
    --  (1) Validating ITEM. (ITEM_ID is populated)
    --  (2) Validating COMP_ITEM. (COMP_ITEM_ID is populated)
    -- "ID_FIELD(COMP_ITEM_ID) IS NOT NULL and QRI.ITEM_ID IS NOT NULL" part takes care
    -- the logic explained above.
    -- If (1) and (2) evaluates to true check the dependency using BOM tables, carried out
    -- in final NOT EXISTS part.
    -- Though explained procedurally, implemented in non-procedural fashion.
    -- srhariha. Wed Aug  4 23:33:07 PDT 2004.

   IF ( COL_NAME = 'COMP_ITEM') THEN
     SQL_STATEMENT :=
           'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
           'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
           'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
           'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
           'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
           ':ERROR_MANDATORY, SYSDATE, ' ||
           ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
           ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
           'FROM   QA_RESULTS_INTERFACE QRI ' ||
           'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
           ' AND  QRI.PROCESS_STATUS = :PROCESS_STATUS ' ||
           ' AND  NOT EXISTS ' ||
                             '(SELECT ''X'' ' ||
                             'FROM   QA_INTERFACE_ERRORS QIE ' ||
                             'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                             'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         ' AND QRI.' || ID_FIELD || ' IS NOT NULL ' ||
         ' AND QRI.ITEM_ID IS NOT NULL' ||
         ' AND NOT EXISTS '||
                            '(SELECT COMPONENT_ITEM_ID ' ||
                            ' FROM BOM_INVENTORY_COMPONENTS BIC, BOM_BILL_OF_MATERIALS BOM ' ||
                            ' WHERE BOM.ORGANIZATION_ID = QRI.ORGANIZATION_ID' ||
                            ' AND BOM.ASSEMBLY_ITEM_ID =  QRI.ITEM_ID ' ||
                            ' AND BIC.COMPONENT_ITEM_ID = QRI.COMP_ITEM_ID' ||
                            ' AND BIC.BILL_SEQUENCE_ID =  BOM.BILL_SEQUENCE_ID ' ||
                            ' AND BIC.EFFECTIVITY_DATE <=  SYSDATE ' ||
                            ' AND NVL(BIC.DISABLE_DATE, SYSDATE+1) > SYSDATE )';




      EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID, X_USER_ID,
          X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID, X_GROUP_ID,2,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   END IF;

END VALIDATE_ITEM;

-- Added the procedure below to enable the validation of
-- ASSET_GROUP while collection data importing.
-- See Bug #2368381
-- This procedure will be called from VALIDATE_STEPS only
-- Procdure added by suramasw
-- Comments added by rkunchal Tue May 28 00:22:11 PDT 2002

-- To fix the reopened bug 2368381
-- Renamed this procedure from VALIDATE_AG to VALIDATE_EAM_ITEMS.
-- This is the place where Asset Groups and Asset Activites are
-- validated while importing.
-- Asset Groups and Asset Activities are same from the Quality
-- perspective. Only difference is ID column.
-- rkunchal Thu Jul 18 07:23:13 PDT 2002

--dgupta: Start R12 EAM Integration. Bug 4345492
PROCEDURE VALIDATE_EAM_ITEMS(COL_NAME VARCHAR2,
                             ERROR_COL_NAME VARCHAR2,
                             X_GROUP_ID NUMBER,
                             X_USER_ID NUMBER,
                             X_LAST_UPDATE_LOGIN NUMBER,
                             X_REQUEST_ID NUMBER,
                             X_PROGRAM_APPLICATION_ID NUMBER,
                             X_PROGRAM_ID NUMBER,
                             ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   I NUMBER := 0;
   V BOOLEAN;
   CID NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_SEGS VARCHAR2(2000);
   X_ORG_ID NUMBER;
   X_LINE_ID NUMBER;
   INTERFACE_ID_TABLE NUMBER_TABLE;
   SEGS_TABLE CHAR2000_TABLE;
   ORG_ID_TABLE NUMBER_TABLE;
   LINE_ID_TABLE NUMBER_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   ERRMSG VARCHAR2(30);
   ID_FIELD VARCHAR2(30);
   COMP_TEXT VARCHAR2(6);
   X_WHERE_CLAUSE VARCHAR2(250);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME = 'ASSET_ACTIVITY') THEN
      ID_FIELD := 'ASSET_ACTIVITY_ID';

-- added the following to include new hardcoded element followup activity
-- saugupta

   ELSIF (COL_NAME = 'FOLLOWUP_ACTIVITY') THEN
      ID_FIELD := 'FOLLOWUP_ACTIVITY_ID';
   END IF;

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw.
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
         'SELECT TRANSACTION_INTERFACE_ID, ' || COL_NAME ||
         ', ORGANIZATION_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
               'QRI.TRANSACTION_INTERFACE_ID ' ||
               'AND QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL)) ';

   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_SEGS, 2000);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 3, X_ORG_ID);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_SEGS);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 3, X_ORG_ID);
         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         SEGS_TABLE(I) := X_SEGS;
         ORG_ID_TABLE(I) := X_ORG_ID;
      ELSE
         EXIT;
     END IF;
   END LOOP;

   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   FOR I IN 1..NUM_ROWS LOOP
      -- For Asset Activities, EAM_ITEM_TYPE is 2
      IF (COL_NAME LIKE 'ASSET_ACTIVITY') THEN
         X_WHERE_CLAUSE := ' EAM_ITEM_TYPE = ' || 2 ||
				    ' AND ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ;

-- added the following to include new hardcoded element followup activity
-- saugupta

      ELSIF (COL_NAME LIKE 'FOLLOWUP_ACTIVITY') THEN
         X_WHERE_CLAUSE := ' EAM_ITEM_TYPE = ' || 2 ||
				    ' AND ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ;

      ELSE
         X_WHERE_CLAUSE := NULL;
      END IF;

      V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CHECK_COMBINATION',
					 'INV',
					 'MSTK',
					 101,
					 SEGS_TABLE(I),
					 'V',
					 NULL,
					 'ALL',
					 ORG_ID_TABLE(I),
					 NULL,
					 X_WHERE_CLAUSE);

      IF (V) THEN
         -- get the flex combination id and update the interface table.
         -- set cid and x_org_id, which are used by the cursor.

         CID := FND_FLEX_KEYVAL.COMBINATION_ID;
         X_ORG_ID := ORG_ID_TABLE(I);

         SQL_STATEMENT :=
            'UPDATE QA_RESULTS_INTERFACE QRI ' ||
            'SET LAST_UPDATE_DATE = SYSDATE, ' ||
            'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
            ', REQUEST_ID = :REQUEST_ID ' ||
            ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
            ', PROGRAM_ID = :PROGRAM_ID ' ||
            ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
            ID_FIELD || ' = :CID ' ||
            ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
            ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
            ' AND  QRI.PROCESS_STATUS = 2 ' ||
            'AND  NOT EXISTS
            	(SELECT ''X'' ' ||
                 'FROM   QA_INTERFACE_ERRORS QIE ' ||
                 'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                 'QRI.TRANSACTION_INTERFACE_ID ' ||
                 'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';
          EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                                X_REQUEST_ID,
                                                X_PROGRAM_APPLICATION_ID,
                                                X_PROGRAM_ID,
                                                CID,
                                                X_GROUP_ID,
                                                INTERFACE_ID_TABLE(I),
                                                l_col1, l_col2, l_col3, l_col4, l_col5;

         -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
      ELSE
         INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
               (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
                SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
                X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
      END IF;
   END LOOP;

END VALIDATE_EAM_ITEMS;
--dgupta: End R12 EAM Integration. Bug 4345492

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


PROCEDURE VALIDATE_REFERENCE(COL_NAME VARCHAR2,
                             ERROR_COL_NAME VARCHAR2,
                             X_GROUP_ID NUMBER,
                             X_USER_ID NUMBER,
                             X_LAST_UPDATE_LOGIN NUMBER,
                             X_REQUEST_ID NUMBER,
                             X_PROGRAM_APPLICATION_ID NUMBER,
                             X_PROGRAM_ID NUMBER,
                             ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   I NUMBER := 0;
   V BOOLEAN;
   CID NUMBER;
   NUM_ROWS NUMBER;
   X_INTERFACE_ID NUMBER;
   X_SEGS VARCHAR2(2000);
   X_ORG_ID NUMBER;
   X_LINE_ID NUMBER;
   INTERFACE_ID_TABLE NUMBER_TABLE;
   SEGS_TABLE CHAR2000_TABLE;
   ORG_ID_TABLE NUMBER_TABLE;
   LINE_ID_TABLE NUMBER_TABLE;
   SOURCE_CURSOR INTEGER;
   IGNORE INTEGER;
   ERRMSG VARCHAR2(30);
   ID_FIELD VARCHAR2(30);
   X_WHERE_CLAUSE VARCHAR2(250);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME = 'BILL_REFERENCE') THEN
      ID_FIELD := 'BILL_REFERENCE_ID';
   ELSIF (COL_NAME = 'ROUTING_REFERENCE') THEN
      ID_FIELD := 'ROUTING_REFERENCE_ID';
   END IF;

   -- Bug 2941809. Need to use bind variables instead of literal values when
   -- using DBMS_SQL.EXECUTE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   -- Bug 3136107.suramasw.
   -- Replaced :ERR_COL introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
         'SELECT TRANSACTION_INTERFACE_ID, ' || COL_NAME ||
         ', ORGANIZATION_ID, LINE_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
               'QRI.TRANSACTION_INTERFACE_ID ' ||
               'AND QIE.ERROR_COLUMN IN ( :ERROR_COL_NAME, NULL))';

   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);
   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':ERROR_COL_NAME', ERROR_COL_NAME);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 2, X_SEGS, 2000);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 3, X_ORG_ID);
   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 4, X_LINE_ID);

   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         I := I + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 2, X_SEGS);
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 3, X_ORG_ID);
         DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 4, X_LINE_ID);
         INTERFACE_ID_TABLE(I) := X_INTERFACE_ID;
         SEGS_TABLE(I) := X_SEGS;
         ORG_ID_TABLE(I) := X_ORG_ID;
         LINE_ID_TABLE(I) := X_LINE_ID;
      ELSE
         EXIT;
     END IF;
   END LOOP;

   NUM_ROWS := I;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   FOR I IN 1..NUM_ROWS LOOP

      --IF (COL_NAME LIKE 'BILL_REFERENCE') OR (COL_NAME  LIKE 'ROUTING_REFERENCE') THEN
      IF (COL_NAME IN ('BILL_REFERENCE','ROUTING_REFERENCE') AND (LINE_ID_TABLE(I) IS NOT NULL))
THEN
         X_WHERE_CLAUSE := 'INVENTORY_ITEM_ID IN ' ||
               '(SELECT PRIMARY_ITEM_ID FROM WIP_REP_ASSY_VAL_V ' ||
               'WHERE ORGANIZATION_ID = ' || TO_CHAR(ORG_ID_TABLE(I)) ||
               ' AND LINE_ID = ' || TO_CHAR(LINE_ID_TABLE(I)) || ')';

      ELSE
         X_WHERE_CLAUSE := NULL;
      END IF;

      V := FND_FLEX_KEYVAL.VALIDATE_SEGS('CHECK_COMBINATION',
                                         'INV',
                                         'MSTK',
                                         101,
                                         SEGS_TABLE(I),
                                         'V',
                                         NULL,
                                         'ALL',
                                         ORG_ID_TABLE(I),
                                         NULL,
                                         X_WHERE_CLAUSE);

      IF (V) THEN
         -- get the flex combination id and update the interface table.
         -- set cid and x_org_id, which are used by the cursor.

         CID := FND_FLEX_KEYVAL.COMBINATION_ID;
         X_ORG_ID := ORG_ID_TABLE(I);

         -- Bug 3136107.
         -- SQL Bind project. Code modified to use bind variables instead of literals
         -- Same as the fix done for Bug 3079312.suramasw.

         SQL_STATEMENT :=
            'UPDATE QA_RESULTS_INTERFACE QRI ' ||
            'SET LAST_UPDATE_DATE = SYSDATE, ' ||
            'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
            ', REQUEST_ID = :REQUEST_ID ' ||
            ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
            ', PROGRAM_ID = :PROGRAM_ID ' ||
            ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
            ID_FIELD || ' = :CID '||
            ' WHERE QRI.GROUP_ID = :GROUP_ID '||
            ' AND QRI.TRANSACTION_INTERFACE_ID = :INTERFACE_ID_TABLE ' ||
            ' AND  QRI.PROCESS_STATUS = 2 ' ||
            'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                 'FROM   QA_INTERFACE_ERRORS QIE ' ||
                 'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                'QRI.TRANSACTION_INTERFACE_ID ' ||
                 'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

           EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                                 X_REQUEST_ID,
                                                 X_PROGRAM_APPLICATION_ID,
                                                 X_PROGRAM_ID,
                                                 CID,
                                                 X_GROUP_ID,
                                                 INTERFACE_ID_TABLE(I),
                                                 l_col1, l_col2, l_col3, l_col4, l_col5;

         -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
      ELSE
         INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID,
               ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
               CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
               PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) VALUES
               (INTERFACE_ID_TABLE(I), ERROR_COL_NAME, ERROR_INVALID_VALUE,
                SYSDATE, X_USER_ID, SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
                X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, SYSDATE);
      END IF;
   END LOOP;

END VALIDATE_REFERENCE;

-- End of inclusions for NCM Hardcode Elements.


PROCEDURE VALIDATE_VALUES(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          FROM_CLAUSE VARCHAR2,
                          WHERE_CLAUSE VARCHAR2,
                          ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.
   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, :REQUEST_ID, ' ||
         ':PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  QRI.' || COL_NAME || ' IS NOT NULL ' ||
          'AND  NOT EXISTS ' ||
               '(SELECT ''X'' ' ||
                'FROM ' || FROM_CLAUSE ||
               ' WHERE (' || WHERE_CLAUSE || '))';

     -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

     -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
     -- in order to bind the value of ERROR_COL_NAME. kabalakr

     -- Added the other columns added as a part of Bug 3136107 to
     -- EXECUTE IMMEDIATE. suramasw
     EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
          ERROR_INVALID_VALUE, X_USER_ID, X_USER_ID,
                                           X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

END VALIDATE_VALUES;

PROCEDURE VALIDATE_SUBINVENTORY(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   COMP_STRING VARCHAR2(6) := '';

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   IF (COL_NAME LIKE 'COMP%') THEN
      COMP_STRING := 'COMP_';
   END IF;

   -- note that 1 means yes, 2 means no for restrict_subinv_code

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID,  :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, :REQUEST_ID, ' ||
         ':PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  QRI.' || COL_NAME || ' IS NOT NULL ' ||
          'AND  NOT EXISTS ' ||
              '(SELECT ''X'' ' ||
              'FROM MTL_SUBINVENTORIES_VAL_V MSVV ' ||
              'WHERE MSVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
              '  AND QRI.' || COMP_STRING || 'RESTRICT_SUBINV_CODE = 2 ' ||
              '  AND MSVV.SECONDARY_INVENTORY_NAME = QRI.' || COL_NAME ||
              ' UNION ' ||
              'SELECT ''X'' ' ||
              'FROM MTL_ITEM_SUB_VAL_V MISVV ' ||
              'WHERE MISVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
              '  AND QRI.' || COMP_STRING || 'RESTRICT_SUBINV_CODE = 1 ' ||
              '  AND MISVV.INVENTORY_ITEM_ID = ' ||
                         'QRI.' || COMP_STRING || 'ITEM_ID ' ||
              '  AND MISVV.SECONDARY_INVENTORY_NAME = QRI.' || COL_NAME || ')';

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

   -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
   -- in order to bind the value of ERROR_COL_NAME. kabalakr

   -- Added the other columns added as a part of Bug 3136107 to
   -- EXECUTE IMMEDIATE. suramasw

   EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                            ERROR_INVALID_VALUE,
                                            X_USER_ID,
                                            X_USER_ID,
                                            X_LAST_UPDATE_LOGIN,
                                            X_REQUEST_ID,
                                            X_PROGRAM_APPLICATION_ID,
                                            X_PROGRAM_ID,
                                            X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;


   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' ||
      'SET LAST_UPDATE_DATE = SYSDATE, ' ||
         'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID = :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
        COMP_STRING || 'SUB_LOCATOR_TYPE = ' ||
        '(SELECT LOCATOR_TYPE ' ||
        '   FROM MTL_SUBINVENTORIES_VAL_V ' ||
        '  WHERE SECONDARY_INVENTORY_NAME = QRI.' || COMP_STRING ||
              'SUBINVENTORY ' ||
        '    AND ORGANIZATION_ID = QRI.ORGANIZATION_ID) ' ||
        'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

     EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

END VALIDATE_SUBINVENTORY;

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


PROCEDURE VALIDATE_TO_SUBINVENTORY(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- note that 1 means yes, 2 means no for restrict_subinv_code

   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.
   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID,  :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, :REQUEST_ID, ' ||
         ':PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  QRI.' || COL_NAME || ' IS NOT NULL ' ||
          'AND  NOT EXISTS ' ||
              '(SELECT ''X'' ' ||
              'FROM MTL_SUBINVENTORIES_VAL_V MSVV ' ||
              'WHERE MSVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
              '  AND QRI.RESTRICT_SUBINV_CODE = 2 ' ||
              '  AND MSVV.SECONDARY_INVENTORY_NAME = QRI.' || COL_NAME ||
              ' UNION ' ||
              'SELECT ''X'' ' ||
              'FROM MTL_ITEM_SUB_VAL_V MISVV ' ||
              'WHERE MISVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
              '  AND QRI.RESTRICT_SUBINV_CODE = 1 ' ||
              '  AND MISVV.INVENTORY_ITEM_ID = ' ||
                         'QRI.ITEM_ID ' ||
              '  AND MISVV.SECONDARY_INVENTORY_NAME = QRI.' || COL_NAME || ')';

    -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

    -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
    -- in order to bind the value of ERROR_COL_NAME. kabalakr

    -- Added the other columns added as a part of Bug 3136107 to
    -- EXECUTE IMMEDIATE. suramasw

    EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                            ERROR_INVALID_VALUE,
                                            X_USER_ID,
                                            X_USER_ID,
                                            X_LAST_UPDATE_LOGIN,
                                            X_REQUEST_ID,
                                            X_PROGRAM_APPLICATION_ID,
                                            X_PROGRAM_ID,
                                            X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' ||
      'SET LAST_UPDATE_DATE = SYSDATE, ' ||
          'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID = :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, TO_SUB_LOCATOR_TYPE = ' ||
        '(SELECT LOCATOR_TYPE ' ||
        '   FROM MTL_SUBINVENTORIES_VAL_V ' ||
        '  WHERE SECONDARY_INVENTORY_NAME = QRI.TO_SUBINVENTORY ' ||
        '    AND ORGANIZATION_ID = QRI.ORGANIZATION_ID) ' ||
        'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

     EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

END VALIDATE_TO_SUBINVENTORY;

-- End of inclusions for NCM Hardcode Elements.


FUNCTION get_errored_column_name (p_group_id IN NUMBER,
    p_col_name IN VARCHAR2) RETURN VARCHAR2 IS

    CURSOR c IS
        SELECT name
        FROM qa_chars qc, qa_plan_chars qpc, qa_results_interface qri
        WHERE qc.char_id = qpc.char_id
        AND qpc.plan_id = qri.plan_id
        AND qpc.result_column_name = p_col_name
        AND qri.group_id = p_group_id;

     l_name VARCHAR2(30);

BEGIN
    OPEN c;
    FETCH c into l_name;
    CLOSE c;

    RETURN l_name;

END get_errored_column_name;


PROCEDURE VALIDATE_VALUES_WITH_SQL(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          X_SQL_VALIDATION_STRING VARCHAR2,
                          ERROR_COL_LIST VARCHAR2) IS

   SQL_STATEMENT         VARCHAR2(2000);
   FORMATTED_SQL_STRING  VARCHAR2(2500);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   FORMATTED_SQL_STRING := QLTTRAFB.FORMAT_SQL_VALIDATION_STRING(
         X_SQL_VALIDATION_STRING);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.
   -- Also replaced :1 introduced in the version 115.63 by :ERROR_COL_NAME

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID,  :ERROR_COL_NAME, ' ||
         ':ERROR_INVALID_VALUE, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, :REQUEST_ID, ' ||
         ':PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
	  'AND QRI.' || COL_NAME || ' IS NOT NULL ' ||
          'AND NOT EXISTS (SELECT ''x'' FROM DUAL WHERE QRI.' ||
           COL_NAME || ' IN ' || '(' || FORMATTED_SQL_STRING || ') )';

   BEGIN

       -- user_sql_error exception was added for better diagnosis of import
       -- problems, which most often is limited to user defined sql validation
       -- string.  Please see bug # 1680481 for details.
       --
       -- ORASHID

       -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

       -- Bug 2976810. Using EXECUTE IMMEDIATE instead of QLTTRAFB.EXEC_SQL
       -- in order to bind the value of ERROR_COL_NAME. kabalakr

       -- Added the other columns added as a part of Bug 3136107 to
       -- EXECUTE IMMEDIATE. suramasw

       EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                             ERROR_INVALID_VALUE,
                                             X_USER_ID,
                                             X_USER_ID,
                                             X_LAST_UPDATE_LOGIN,
                                             X_REQUEST_ID,
                                             X_PROGRAM_APPLICATION_ID,
                                             X_PROGRAM_ID,
                                             X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;


       EXCEPTION WHEN OTHERS THEN
           g_sqlerrm := sqlerrm;
           g_col_name := get_errored_column_name(x_group_id, col_name);
           RAISE user_sql_error;
   END;

END VALIDATE_VALUES_WITH_SQL;


PROCEDURE DERIVE_IDS(COL_NAME VARCHAR2,
                     ERROR_COL_NAME VARCHAR2,
                     X_GROUP_ID NUMBER,
                     X_USER_ID NUMBER,
                     X_LAST_UPDATE_LOGIN NUMBER,
                     X_REQUEST_ID NUMBER,
                     X_PROGRAM_APPLICATION_ID NUMBER,
                     X_PROGRAM_ID NUMBER,
                     ID_ASSIGNMENT VARCHAR2,
                     ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' ||
      'SET LAST_UPDATE_DATE = SYSDATE, ' ||
          'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID =  :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
        ID_ASSIGNMENT || '
        WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

     EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

END DERIVE_IDS;

/* derive_job
 *
 * when the plan contains both production_line and item, we need to derive
 * wip_entity_id.
 */

PROCEDURE DERIVE_JOB(X_GROUP_ID NUMBER,
                     X_USER_ID NUMBER,
                     X_LAST_UPDATE_LOGIN NUMBER,
                     X_REQUEST_ID NUMBER,
                     X_PROGRAM_APPLICATION_ID NUMBER,
                     X_PROGRAM_ID NUMBER,
                     ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3079312.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' ||
      'SET LAST_UPDATE_DATE = SYSDATE, ' ||
          'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID = :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
        'WIP_ENTITY_ID = (SELECT WIP_ENTITY_ID FROM ' ||
              'WIP_REPETITIVE_ENTITIES_V WREV ' ||
              'WHERE WREV.PRIMARY_ITEM_ID = QRI.ITEM_ID ' ||
              '  AND WREV.ORGANIZATION_ID = QRI.ORGANIZATION_ID) ' ||
        'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))';

     EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
          l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END DERIVE_JOB;


-- given a developer_name, finds its location in the developer name table
-- could actually work for any char30 table

FUNCTION POSITION_IN_TABLE(SEARCH_VAL VARCHAR2,
                           X_TABLE CHAR30_TABLE,
                           NUM_ROWS NUMBER) RETURN NUMBER IS
BEGIN

   FOR I IN 1..NUM_ROWS LOOP
      IF (X_TABLE(I) = SEARCH_VAL) THEN

         RETURN I;
      END IF;
   END LOOP;

   RETURN -1;

END POSITION_IN_TABLE;


PROCEDURE SET_ERROR_STATUS(X_GROUP_ID NUMBER, X_USER_ID NUMBER,
                X_REQUEST_ID NUMBER, X_PROGRAM_APPLICATION_ID NUMBER,
                X_PROGRAM_ID NUMBER, X_LAST_UPDATE_LOGIN NUMBER,
                X_COLUMN_NAME VARCHAR2 DEFAULT NULL) IS
BEGIN
   IF (X_COLUMN_NAME IS NULL) THEN
      UPDATE QA_RESULTS_INTERFACE qri
         SET PROCESS_STATUS = 3,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
             REQUEST_ID = X_REQUEST_ID,
             PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
             PROGRAM_ID = X_PROGRAM_ID,
             PROGRAM_UPDATE_DATE = SYSDATE
       WHERE qri.GROUP_ID = X_GROUP_ID AND EXISTS
            (SELECT 1
             FROM  qa_interface_errors qie
             WHERE qie.transaction_interface_id = qri.transaction_interface_id);

         -- Bug 1558445, slow performance.
         -- AND TRANSACTION_INTERFACE_ID IN
         -- (SELECT TRANSACTION_INTERFACE_ID
         -- FROM   QA_INTERFACE_ERRORS);
   ELSE
      UPDATE QA_RESULTS_INTERFACE QRI
         SET PROCESS_STATUS = 3,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
             REQUEST_ID = X_REQUEST_ID,
             PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
             PROGRAM_ID = X_PROGRAM_ID,
             PROGRAM_UPDATE_DATE = SYSDATE
       WHERE GROUP_ID = X_GROUP_ID
         AND EXISTS
             (SELECT TRANSACTION_INTERFACE_ID, ERROR_COLUMN
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN = X_COLUMN_NAME);
   END IF;

END SET_ERROR_STATUS;

/* validate_reasonable_limits
 *
 * builds a dynamic sql statement to check that values are within
 * lower and upper reasonable limits.  will use limits from a spec if
 * one is specified.  if no spec is specified, or if the element is not
 * on the spec, will use limits from the collection element.  will also
 * default to collection element limits if the element is on the spec
 * but is disabled.  note that this procedure does not need to check
 * whether or not the spec itself is disabled, since this check occurs
 * when the spec_name column is being processed.
 */

PROCEDURE VALIDATE_REASONABLE_LIMITS (COL_NAME VARCHAR2,
                           ERROR_COL_NAME VARCHAR2,
                           X_DATATYPE NUMBER,
                           X_CHAR_ID NUMBER,
                           X_GROUP_ID NUMBER,
                           X_USER_ID NUMBER,
                           X_LAST_UPDATE_LOGIN NUMBER,
                           X_REQUEST_ID NUMBER,
                           X_PROGRAM_APPLICATION_ID NUMBER,
                           X_PROGRAM_ID NUMBER,
                           ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);
   TEMP VARCHAR2(1000);

   l_col1 varchar2(100);
   l_col2 varchar2(100);
   l_col3 varchar2(100);
   l_col4 varchar2(100);
   l_col5 varchar2(100);

BEGIN
   -- Bug 3136107.SQL Bind project.
   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, ' ||
         ':ERROR_OUTSIDE_LIMITS, SYSDATE, ' ||
         ':USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5))
           AND  NOT EXISTS ' ||
               '(SELECT ''X'' ' ||
                'FROM   QA_SPEC_CHARS_V QSC, ' ||
                       'QA_CHARS QC ' ||
                'WHERE  ((QRI.' || COL_NAME || ' IS NULL) ' ||
                   'OR  (((DECODE(QSC.CHAR_ID, NULL, ' ||
                                 'QC.LOWER_REASONABLE_LIMIT, ' ||
                                 'QSC.LOWER_REASONABLE_LIMIT) IS NULL) ' ||
                         'OR ';

   IF X_DATATYPE = 2 THEN
       sql_statement := sql_statement || '(qltdate.any_to_number(QRI.' ||
           COL_NAME || ') >= ';


   -- For Timezone Compliance bug 3179845. Convert the datetime elements to real dates.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF x_datatype = 6 THEN
       sql_statement := sql_statement || '(qltdate.any_to_datetime(QRI.' ||
           COL_NAME || ') >= ';

   ELSIF x_datatype = 3 THEN
       sql_statement := sql_statement || '(qltdate.any_to_date(QRI.' ||
           COL_NAME || ') >= ';

   ELSE
       sql_statement := sql_statement || '(QRI.' || COL_NAME || ' >= ';
   END IF;

   TEMP := 'DECODE(QSC.CHAR_ID, NULL, QC.LOWER_REASONABLE_LIMIT, ' ||
           'QSC.LOWER_REASONABLE_LIMIT)';
   IF (X_DATATYPE = 2) THEN
      TEMP := 'qltdate.any_to_number(' || TEMP || ')';
   ELSIF (X_DATATYPE = 3) THEN
      TEMP := 'qltdate.any_to_date(' || TEMP || ')';

   -- For Timezone Compliance bug 3179845.
   -- Convert the datetime elements to real dates.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF (X_DATATYPE = 6) THEN
      TEMP := 'qltdate.canon_to_date(' || TEMP || ')';
   END IF;


   SQL_STATEMENT := SQL_STATEMENT || TEMP || ')) ' ||
                      'AND
                         ((DECODE(QSC.CHAR_ID, NULL, ' ||
                                 'QC.UPPER_REASONABLE_LIMIT, ' ||
                                 'QSC.UPPER_REASONABLE_LIMIT) IS NULL) ' ||
                         'OR ';

   IF X_DATATYPE = 2 THEN
       sql_statement := sql_statement || '(qltdate.any_to_number(QRI.' ||
           COL_NAME || ') <= ';

   -- For Timezone Compliance bug 3179845. Convert the datetime elements to real dates.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF x_datatype = 6 THEN
       sql_statement := sql_statement || '(qltdate.any_to_datetime(QRI.' ||
           COL_NAME || ') <= ';

   ELSIF x_datatype = 3 THEN
       sql_statement := sql_statement || '(qltdate.any_to_date(QRI.' ||
           COL_NAME || ') <= ';

   ELSE
       sql_statement := sql_statement || '(QRI.' || COL_NAME || ' <= ';
   END IF;

   TEMP := 'DECODE(QSC.CHAR_ID, NULL, QC.UPPER_REASONABLE_LIMIT, ' ||
           'QSC.UPPER_REASONABLE_LIMIT)';
   IF (X_DATATYPE = 2) THEN
      TEMP := 'qltdate.any_to_number(' || TEMP || ')';
   ELSIF (X_DATATYPE = 3) THEN
      TEMP := 'qltdate.any_to_date(' || TEMP || ')';

   -- For Timezone Compliance bug 3179845. Convert the datetime elements to real dates.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF (X_DATATYPE = 6) THEN
      TEMP := 'qltdate.canon_to_date(' || TEMP || ')';
   END IF;


   SQL_STATEMENT := SQL_STATEMENT || TEMP || ')))) ' ||
                 ' AND  QSC.CHAR_ID (+) = QC.CHAR_ID' ||
                 ' AND  QC.CHAR_ID = :CHAR_ID ' ||
                 ' AND  QSC.SPEC_ID (+) = NVL(QRI.SPEC_ID, -1) ' ||
                 ' AND  QSC.SPEC_CHAR_ENABLED (+) = 1)';

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                         ERROR_OUTSIDE_LIMITS,
                                         X_USER_ID,
                                         X_USER_ID,
                                         X_LAST_UPDATE_LOGIN,
                                         X_REQUEST_ID,
                                         X_PROGRAM_APPLICATION_ID,
                                         X_PROGRAM_ID,
                                         X_GROUP_ID,
                     l_col1, l_col2, l_col3, l_col4, l_col5,
                                         X_CHAR_ID;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_REASONABLE_LIMITS;


PROCEDURE VALIDATE_STEPS (X_ENABLED_FLAG NUMBER, X_MANDATORY_FLAG NUMBER,
      COL_NAME VARCHAR2, X_GROUP_ID NUMBER, X_USER_ID NUMBER,
      X_LAST_UPDATE_LOGIN NUMBER, X_REQUEST_ID NUMBER,
      X_PROGRAM_APPLICATION_ID NUMBER, X_PROGRAM_ID NUMBER,
      FROM_CLAUSE VARCHAR2, WHERE_CLAUSE VARCHAR2,
      ID_ASSIGN VARCHAR2, X_CHAR_ID NUMBER,
      X_CHAR_NAME VARCHAR2, X_DATATYPE NUMBER, X_DECIMAL_PRECISION NUMBER,
      X_PLAN_ID NUMBER, X_VALUES_EXIST_FLAG NUMBER,
      X_READ_ONLY_FLAG NUMBER,
      X_SQL_VALIDATION_STRING VARCHAR2 DEFAULT NULL,
      PARENT_COL VARCHAR2 DEFAULT NULL, GRANDPARENT_COL VARCHAR2 DEFAULT NULL,
      GREAT_GRANDPARENT_COL VARCHAR2 DEFAULT NULL) IS
   ERROR_COL_LIST VARCHAR2(200);
   ERROR_COL_NAME VARCHAR2(80);


     -- Bug 3755824.Read only elements was not working as Matching elements.Must validate
     -- read-only element only if they are not matching element.Added the following variable
     -- srhariha.Fri Jul  9 07:25:27 PDT 2004

     -- L_MATCHING_ELEMENTS		VARCHAR2(1000);


     -- Bug 3785197.Added new variable.Also commenting out above declaration of
     -- L_MATCHING_ELEMENTS, which is no longer used.
     -- srhariha. Fri Jul 23 03:04:52 PDT 2004.

    RO_MUST_BE_NULL BOOLEAN;



BEGIN
   -- construct error column name, which is just the column name, unless
   -- it's a characterx column in which case it's char_name (characterx).

   IF (COL_NAME LIKE 'CHARACTER%') THEN
      ERROR_COL_NAME := dequote(X_CHAR_NAME) || ' (' || COL_NAME || ')';
   ELSE
      ERROR_COL_NAME := COL_NAME;
   END IF;

   -- construct error columns list

   ERROR_COL_LIST := 'NULL, ' || '''' || ERROR_COL_NAME || '''';
   IF (PARENT_COL IS NOT NULL) THEN
      ERROR_COL_LIST := ERROR_COL_LIST || ', ''' || PARENT_COL || '''';
      IF (GRANDPARENT_COL IS NOT NULL) THEN
         ERROR_COL_LIST := ERROR_COL_LIST || ', ''' || GRANDPARENT_COL || '''';
         IF (GREAT_GRANDPARENT_COL IS NOT NULL) THEN
            ERROR_COL_LIST := ERROR_COL_LIST || ', ''' ||
                  GREAT_GRANDPARENT_COL || '''';
         END IF;
      END IF;
   END IF;

   -- if disabled, validate that all values are null

   IF (X_ENABLED_FLAG = 2) THEN
      QLTTRAFB.VALIDATE_DISABLED(COL_NAME, ERROR_COL_NAME, ERROR_DISABLED,
            X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID);
   ELSE

      -- validate that non-null values have non-null parent (for child only)

      IF (PARENT_COL IS NOT NULL) THEN
         QLTTRAFB.VALIDATE_PARENT_ENTERED(COL_NAME, ERROR_COL_NAME,
            ERROR_NEED_PARENT, X_GROUP_ID,
            X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST);
      END IF;

      -- Tracking Bug : 3104827. Review Tracking Bug : 3148873
      -- Check whether the Collection element is flagged to be 'Read Only'.
      -- If yes, error out if a value is entered in QRI.
      -- Below IF condition added for read only collection plan element project.
      -- saugupta Wed Aug 27 06:15:32 PDT 2003.

     -- Bug 3755824.Read only elements was not working as Matching elements.Must validate
     -- read-only element only if they are not matching element and txn_type is Insert.For
     -- Insert type l_matching_elements will be null.
     -- srhariha.Fri Jul  9 07:25:27 PDT 2004

     -- Bug 3785197. Update was failing if read only or sequence elements was set as matching element.
     -- Removed logic used in 3755824 which was throwing exception for bulk insert.
     -- New logic added, which checks if X_CHAR_NAME is matching element or not only if txn_type
     -- is Update (2).
     -- srhariha. Fri Jul 23 03:04:52 PDT 2004


      RO_MUST_BE_NULL := TRUE;

      IF (G_TYPE_OF_TXN = 2) AND (X_READ_ONLY_FLAG = 1) THEN

          IF CHECK_IF_MATCHING_ELEMENT(X_CHAR_NAME) THEN
              RO_MUST_BE_NULL := FALSE;
          END IF;

      END IF; -- G_TYPE_OF_TXN


      IF (X_READ_ONLY_FLAG = 1) AND (RO_MUST_BE_NULL = TRUE) THEN
        QLTTRAFB.VALIDATE_READ_ONLY(COL_NAME, ERROR_COL_NAME, ERROR_READ_ONLY,
              X_GROUP_ID, X_USER_ID,
              X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
              X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST);
      END IF;

      -- do special mandatory validation for revision
      IF (COL_NAME IN ('REVISION', 'COMP_REVISION')) THEN
         VALIDATE_REVISION(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST, X_MANDATORY_FLAG);

      -- do special mandatory validation for locator
      ELSIF (COL_NAME IN ('LOCATOR', 'COMP_LOCATOR')) THEN
         VALIDATE_LOCATOR(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
               X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

      ELSIF (COL_NAME IN ('TO_LOCATOR'))THEN
         VALIDATE_TO_LOCATOR(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
               X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);

-- End of inclusions for NCM Hardcode Elements.

     -- Bug 3775614. Component lot number and serial number are not validated properly.
     -- If column is lot number or serial number we have special check before issuing
     -- mandatory message, similar to revision. Hence do conventional mandatory check
     -- only if column doesnt belongs to those mentioned in the elsif list.
     -- srhariha. Mon Aug  2 22:48:30 PDT 2004.

     -- Added LOT_NUMBER and SERIAL_NUMBER in the following ELSIF conditions to
     -- validate lot number and serial number in collection import.
     -- Bug 3736481.suramasw.

     ELSIF (COL_NAME IN ('LOT_NUMBER','COMP_LOT_NUMBER')) THEN
         VALIDATE_LOT_NUMBER(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST, X_MANDATORY_FLAG);

     ELSIF (COL_NAME IN ('SERIAL_NUMBER','COMP_SERIAL_NUMBER')) THEN
         VALIDATE_SERIAL_NUMBER(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST, X_MANDATORY_FLAG);



      -- if not revision and it's mandatory, validate no null values

      ELSIF (X_MANDATORY_FLAG = 1) THEN
         QLTTRAFB.VALIDATE_MANDATORY(COL_NAME, ERROR_COL_NAME, ERROR_MANDATORY,
            X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, PARENT_COL, ERROR_COL_LIST);
      END IF; -- mandatory test

      -- if it's a numeric or date characterx column, validate datatypes

      IF ((COL_NAME LIKE 'CHARACTER%') AND (X_DATATYPE <> 1)) THEN
         VALIDATE_DATATYPES(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, X_DATATYPE);
      END IF;

      -- if it's a numeric or date column, correct values so that they are
      -- in the right format.  for numbers, fix the decimal precision.  for
      -- dates, put them in canonical format.

      IF (X_DATATYPE <> 1) THEN
         FORMAT_DATATYPES(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, X_DATATYPE, X_DECIMAL_PRECISION, ERROR_COL_LIST);
      END IF;

      -- if it's a characterx column and values exist, validate against
      -- the value lookups.  if no values exist, check whether there's a
      -- sql validation string.  if so, validate against it.

      --
      -- Commented out the exisiting IF condition and
      -- implemented new IF to accommodate the need
      -- for ASO project
      -- rkunchal Thu Jul 25 01:43:48 PDT 2002
      --
      -- IF (COL_NAME LIKE 'CHARACTER%') THEN

      -- Inclusions for NCM Hardcode Elements.
      -- suramasw Thu Oct 31 10:48:59 PST 2002.
      -- Bug 2449067.

      -- anagarwa Thu Nov 14 13:31:42 PST 2002
      --  Inclusions for CAR Hardcode Elements.

      -- Added RCV_TRANSACTION_ID since validation was not required.
      -- Bug 2670602.suramasw Sat Nov 16 03:44:35 PST 2002.
      --
      -- Bug 4425863
      -- Added the check for the element Nonconformance_code
      -- So that if the lookup values are present then they
      -- are accounted for
      -- ntungare Fri Dec 16 02:58:39 PST 2005
      --

      IF (COL_NAME LIKE 'CHARACTER%') OR
         (COL_NAME IN ('DISPOSITION',
                       'DISPOSITION_SOURCE',
                       'DISPOSITION_ACTION',
                       'DISPOSITION_STATUS')) OR
          (COL_NAME IN ('NONCONFORMANCE_SOURCE',
                        'NONCONFORM_SEVERITY',
                        'NONCONFORM_PRIORITY',
                        'NONCONFORMANCE_TYPE',
                        'NONCONFORMANCE_STATUS',
                        'NONCONFORMANCE_CODE',
                        'CONCURRENT_REQUEST_ID',
                        'DAYS_TO_CLOSE',
                        'RCV_TRANSACTION_ID')) OR
          (COL_NAME IN ('REQUEST_SOURCE',
                        'REQUEST_PRIORITY',
                        'REQUEST_SEVERITY',
                        'REQUEST_STATUS',
                        'ECO_NAME')) THEN

         IF (X_VALUES_EXIST_FLAG = 1) THEN
            QLTTRAFB.VALIDATE_LOOKUPS(COL_NAME, ERROR_COL_NAME,
                  ERROR_INVALID_VALUE, X_GROUP_ID,
                  X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                  X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                  X_CHAR_ID, X_PLAN_ID, ERROR_COL_LIST);
         ELSIF (X_SQL_VALIDATION_STRING IS NOT NULL) THEN
            VALIDATE_VALUES_WITH_SQL(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
                  X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                  X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                  X_SQL_VALIDATION_STRING, ERROR_COL_LIST);
         END IF;
      END IF;

      -- special cases for item, subinv. locator, rev handled above

      IF (COL_NAME IN ('ITEM', 'COMP_ITEM')) THEN
         VALIDATE_ITEM(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
               X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);
      ELSIF (COL_NAME IN ('SUBINVENTORY', 'COMP_SUBINVENTORY')) THEN
         VALIDATE_SUBINVENTORY(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
               X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

      ELSIF (COL_NAME IN ('TO_SUBINVENTORY')) THEN
         VALIDATE_TO_SUBINVENTORY(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
               X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);

 -- End of inclusions for NCM Hardcode Elements.

      END IF;

      -- The following validation code has been added for
      -- bug #2368381. More comments at the procedure itself.
      -- Code added by suramasw
      -- Comment added by rkunchal Tue May 28 00:22:11 PDT 2002

      -- To fix the reopened bug 2368381
      -- Modified the IF condition and the name
      -- to suit the change made in the procedure
      -- rkunchal Thu Jul 18 07:23:13 PDT 2002

-- added the following to include new hardcoded element followup activity
-- saugupta

      IF (COL_NAME IN ('ASSET_ACTIVITY', 'FOLLOWUP_ACTIVITY' )) THEN
         VALIDATE_EAM_ITEMS(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
                            X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);
      END IF;
      -- End of code additions for bug #2368381

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

      IF (COL_NAME IN ('BILL_REFERENCE', 'ROUTING_REFERENCE')) THEN
         VALIDATE_REFERENCE(COL_NAME, ERROR_COL_NAME, X_GROUP_ID,
                            X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);
      END IF;

-- End of inclusions for NCM Hardcode Elements.

      -- the following validation and derivation steps will be skipped for
      -- the special cases item, subinv, and locator, since from_clause and
      -- where_clause are passed in as null in these cases.

      -- validate all non-null values (if they need to be validated)
      IF (FROM_CLAUSE IS NOT NULL) THEN

         VALIDATE_VALUES(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, FROM_CLAUSE, WHERE_CLAUSE, ERROR_COL_LIST);
      END IF;

      -- derive ids (if there are ids to be derived)

      IF (ID_ASSIGN IS NOT NULL) THEN

         DERIVE_IDS(COL_NAME, ERROR_COL_NAME, X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, ID_ASSIGN, ERROR_COL_LIST);
      END IF;

      -- validate reasonable limits

      VALIDATE_REASONABLE_LIMITS(COL_NAME, ERROR_COL_NAME,
            X_DATATYPE, X_CHAR_ID, X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);

      -- validate actions

      VALIDATE_ACTIONS(COL_NAME, ERROR_COL_NAME,
            X_DATATYPE, X_CHAR_ID, X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
            X_PLAN_ID, ERROR_COL_LIST);

      -- for the special case where both item and production line are on
      -- the plan, we need to derive wip entity id

      IF ((COL_NAME = 'ITEM') AND (PARENT_COL = 'PRODUCTION_LINE')) THEN
         DERIVE_JOB(X_GROUP_ID, X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, ERROR_COL_LIST);
      END IF;

   END IF; -- disabled test

END VALIDATE_STEPS;

-- For Sequence Project. The following Procedure dervies the new sequence
-- that needs to automatically inserted.
-- kabalakr 15 JAN 2002.

PROCEDURE DERIVE_SEQUENCE(X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          X_COL_NAME VARCHAR2,
                          X_CHAR_ID NUMBER,
			  X_TXN_TYPE NUMBER
                          ) IS

  SQL_STATEMENT VARCHAR2(2000);
  NEW_SEQUENCE  VARCHAR2(100);

  NUM_ROWS NUMBER;

BEGIN
  -- This procedure is rewritten for bug 2548710.
  -- Get the count of transaction records. We need to derive sequence
  -- for all the records and populate into G_SEQ_TABxx variables
  -- We'll update this into QA_RESULTS_INTERFACE
  -- in TRANSFER_VALID_ROWS() and UPDATE_VALID_ROWS(). See bug 2548710 for
  -- more details. kabalakr.

  -- Optimized the code for bug 2548710. rponnusa Mon Nov 18 03:49:15 PST 2002

  -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
  -- deleted unwanted code. Here assign default seq value. Latter
  -- seq. api will generate the original values

    IF (X_TXN_TYPE <> 2 )
    THEN
        NEW_SEQUENCE := G_SEQUENCE_DEFAULT;
    ELSE
        NEW_SEQUENCE := 'NULL';
    END IF;

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

    SQL_STATEMENT :=
      'UPDATE QA_RESULTS_INTERFACE QRI ' || 'SET LAST_UPDATE_DATE = SYSDATE, ' ||
        'LAST_UPDATE_LOGIN = :LAST_UPDATE_LOGIN ' ||
        ', REQUEST_ID = :REQUEST_ID ' ||
        ', PROGRAM_APPLICATION_ID = :PROGRAM_APPLICATION_ID ' ||
        ', PROGRAM_ID = :PROGRAM_ID ' ||
        ', PROGRAM_UPDATE_DATE = SYSDATE, ' ||
           X_COL_NAME || ' = :NEW_SEQUENCE ' ||
        ' WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
            'QRI.TRANSACTION_INTERFACE_ID )';


     EXECUTE IMMEDIATE SQL_STATEMENT USING X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           NEW_SEQUENCE,
                                           X_GROUP_ID;

END DERIVE_SEQUENCE;

-- Bug 3069404 ksoh Tue Mar 16 10:43:36 PST 2004
-- sequence element is really read-only
-- should check if the user is trying to import into or update it

-- 3785197.Update was failing if read only or sequence elements was set as matching element.
-- To check whether sequence is matching element or not using the function CHECK_IF_MATCHING_ELEMENT.
-- Commented out the old logic.
-- srhariha.Fri Jul 23 03:04:52 PDT 2004.


PROCEDURE VALIDATE_SEQUENCE(P_COL_NAME VARCHAR2,
        P_GROUP_ID NUMBER,
        P_USER_ID NUMBER,
        P_LAST_UPDATE_LOGIN NUMBER,
        P_REQUEST_ID NUMBER,
        P_PROGRAM_APPLICATION_ID NUMBER,
        P_PROGRAM_ID NUMBER,
        P_CHAR_NAME VARCHAR2,
	    P_TXN_TYPE NUMBER
                          ) IS

    --L_MATCHING_ELEMENTS		VARCHAR2(1000);
    MUST_BE_NULL BOOLEAN := FALSE;
    ERROR_COL_LIST VARCHAR2(200);
    ERROR_COL_NAME VARCHAR2(80);
BEGIN
    IF (P_TXN_TYPE <> 2 )
    THEN -- this is insert, the element must be null
        MUST_BE_NULL := TRUE;
    ELSE -- this is update, the element must be null unless it is a matching element
        --SELECT MATCHING_ELEMENTS
        --INTO L_MATCHING_ELEMENTS
        --FROM QA_RESULTS_INTERFACE
        --WHERE GROUP_ID = P_GROUP_ID;

        --L_MATCHING_ELEMENTS := UPPER(L_MATCHING_ELEMENTS);

        IF CHECK_IF_MATCHING_ELEMENT(P_CHAR_NAME) = FALSE THEN
            MUST_BE_NULL := TRUE;
        END IF;
    END IF;

    IF MUST_BE_NULL THEN
        ERROR_COL_NAME := dequote(P_CHAR_NAME) || ' (' || P_COL_NAME || ')';
        ERROR_COL_LIST := 'NULL, ' || '''' || ERROR_COL_NAME || '''';

        QLTTRAFB.VALIDATE_READ_ONLY(P_COL_NAME => P_COL_NAME,
                            P_ERROR_COL_NAME => ERROR_COL_NAME,
                            P_ERROR_MESSAGE => ERROR_SEQUENCE,
                            P_GROUP_ID => P_GROUP_ID,
                            P_USER_ID => P_USER_ID,
                            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
                            P_REQUEST_ID => P_REQUEST_ID,
                            P_PROGRAM_APPLICATION_ID => P_PROGRAM_APPLICATION_ID,
                            P_PROGRAM_ID => P_PROGRAM_ID,
                            P_PARENT_COL_NAME => NULL,
                            P_ERROR_COL_LIST => ERROR_COL_LIST);
    END IF; -- MUST_BE_NULL
END VALIDATE_SEQUENCE;

-- End Of Sequence Project changes.


-- Adding update capabilites.  (1)  Parse matching elements list.  (2)  Validate
-- all matching elements are elements of the plan.  (3)  Get rowids for rows in
-- QA_RESULTS that will be updated.

--
-- Bug 4254876. Added param hardcoded_column_table
-- bso
--
FUNCTION VALIDATE_UPDATE_TYPE_RECORDS (X_GROUP_ID NUMBER,
				       X_PLAN_ID NUMBER,
				       CHAR_NAME_TABLE CHAR30_TABLE,
				       DEVELOPER_NAME_TABLE CHAR30_TABLE,
                                       HARDCODED_COLUMN_TABLE CHAR30_TABLE,
				       DATATYPE_TABLE NUMBER_TABLE,
			    	       NUM_ELEMS BINARY_INTEGER,
				       X_USER_ID NUMBER,
				       X_LAST_UPDATE_LOGIN NUMBER,
				       X_REQUEST_ID NUMBER,
				       X_PROGRAM_APPLICATION_ID NUMBER,
				       X_PROGRAM_ID NUMBER) RETURN VARCHAR2 IS

  SELECT_STMT			VARCHAR2(10000);
  X_MATCHING_ELEMENTS		VARCHAR2(1000);
  X_TRANSACTION_INTERFACE_ID 	NUMBER;
  I					BINARY_INTEGER;
  J					BINARY_INTEGER;
  DONE BOOLEAN;
  TMP VARCHAR2(1000);
  TOTAL_MATCHES		NUMBER;
  CONDITIONS_TABLE		CHAR30_TABLE;
  DEVELOPER_TABLE   	CHAR30_TABLE;
  DATA_TABLE		NUMBER_TABLE;
  QARES_ROW			ROWID;
  STMT_OF_ROWIDS		VARCHAR2(10000);
  MATCH_ERROR			BOOLEAN;
  CURSOR_HANDLE		INTEGER := DBMS_SQL.OPEN_CURSOR;
  IGNORE				NUMBER;
  X_PLAN_NAME			QA_PLANS.NAME%TYPE;
  MATCHING_ERROR		EXCEPTION;
  NO_ROWIDS_ERROR 		EXCEPTION;
  MORE_THAN_ONE_ROWID_ERROR EXCEPTION;

  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.
  l_viewname       VARCHAR2(100);
  l_importviewname VARCHAR2(100);

BEGIN

  SELECT MATCHING_ELEMENTS, TRANSACTION_INTERFACE_ID
  INTO X_MATCHING_ELEMENTS, X_TRANSACTION_INTERFACE_ID
  FROM QA_RESULTS_INTERFACE
  WHERE GROUP_ID = X_GROUP_ID;

  X_MATCHING_ELEMENTS := UPPER(X_MATCHING_ELEMENTS);

  -- get rid of commas and white spaces at either end.
  X_MATCHING_ELEMENTS := LTRIM(X_MATCHING_ELEMENTS, ' ,');
  X_MATCHING_ELEMENTS := RTRIM(X_MATCHING_ELEMENTS, ' ,');

  I := 0;
  DONE := (X_MATCHING_ELEMENTS IS NULL);
  WHILE (NOT DONE) LOOP
    I := I + 1;  -- now we know there is at least one element.

    -- if there is no more commas, this is the last element, return.
    J := INSTR(X_MATCHING_ELEMENTS, ',');
    IF J = 0 THEN
        TMP := X_MATCHING_ELEMENTS;
        DONE := TRUE;
    ELSE
    -- there happens to be at least a comma.  Extract the first
    -- element by finding the comma and taking everything in front.
        TMP := SUBSTR(X_MATCHING_ELEMENTS, 1, J-1);
        X_MATCHING_ELEMENTS := SUBSTR(X_MATCHING_ELEMENTS, J);
        X_MATCHING_ELEMENTS := LTRIM(X_MATCHING_ELEMENTS, ' ,');
    END IF;

    -- clean up the extracted element by getting rid of any right-most
    -- spaces and convert inner spaces to underscores.
    CONDITIONS_TABLE(I) := REPLACE(RTRIM(TMP,' '), ' ', '_');
  END LOOP;

  TOTAL_MATCHES := I;

  -- Bug 3785197.  Update was failing if read only or sequence elements was set as matching element.
  -- Intialising global variables G_TOTAL_MATCHES and G_MATCHING_CHAR_TABLE, which will
  -- be used in the CHECK_IF_MATCHING_ELEMENT () procedure. G_TOTAL_MATCHES will hold number of
  -- matching elements and G_MATCHING_CHAR_TABLE contains processed CHAR_NAME of matching elements.
  -- Both are used to check if read only element or sequence is a matching element or not.
  -- srhariha.Fri Jul 23 03:04:52 PDT 2004

  G_TOTAL_MATCHES := TOTAL_MATCHES;

  FOR K IN 1..TOTAL_MATCHES LOOP
    G_MATCHING_CHAR_TABLE(K) := CONDITIONS_TABLE(K);
  END LOOP;
  -- now insure that all the columns will match column names in the plan.
  -- this is done without making SQL calls for performance reasons.
  MATCH_ERROR := FALSE;
  FOR I IN 1..TOTAL_MATCHES LOOP
    MATCH_ERROR := TRUE;
    FOR J IN 1..NUM_ELEMS LOOP
      IF CONDITIONS_TABLE(I) = CHAR_NAME_TABLE(J)
	   THEN MATCH_ERROR := FALSE;
	       -- DEVELOPER_TABLE(I) := DEVELOPER_NAME_TABLE(J);

               --
               -- Bug 4254876
               -- We now define DEVELOPER_TABLE(I) to be the _IV column name.
               -- Here we match the same algorithm as in qltvcreb, namely
               -- if hardcoded column is null then
               --     same as CHAR_NAME
               -- else
               --     same as DEVELOPER_NAME
               --
               -- bso Tue Mar 29 15:57:35 PST 2005
               --

               IF hardcoded_column_table(J) IS NULL THEN
                   developer_table(i) := char_name_table(j);
               ELSE
                   developer_table(i) := developer_name_table(j);
               END IF;
		   DATA_TABLE(I) := DATATYPE_TABLE(J);
	        EXIT;
	 ELSIF CONDITIONS_TABLE(I) = 'COLLECTION_ID'
	   THEN MATCH_ERROR := FALSE;
		   DEVELOPER_TABLE(I) := 'COLLECTION_ID';
		   DATA_TABLE(I) := 2;
		   EXIT;
      END IF;
    END LOOP;
    IF MATCH_ERROR = TRUE
      THEN RAISE MATCHING_ERROR;
    END IF;

    --
    -- Because of Discoverer limitation, dynamic view columns do
    -- not match collection element names exactly.  All special
    -- characters are converted to underscores.  Do this now.
    -- bso
    --
    conditions_table(i) := despecial(conditions_table(i));

  END LOOP;

  -- Now get the view name of the plan you want to compare to.  We need to
  -- do this because we must compare against user_friendly columns, not
  -- "_id" columns (e.g. CUSTOMER column, not CUSTOMER_ID column)
  SELECT NAME
  INTO X_PLAN_NAME
  FROM QA_PLANS
  WHERE PLAN_ID = X_PLAN_ID;

  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.

  SELECT import_view_name
  INTO l_importviewname
  FROM  QA_PLANS
  WHERE PLAN_ID = X_PLAN_ID;

  SELECT view_name
  INTO l_viewname
  FROM  QA_PLANS
  WHERE PLAN_ID = X_PLAN_ID;

  -- Now select the QA_RESULTS rowids that needs to be updated.

  -- Changed the SELECT_STMT as below so that the import_view_name
  -- and view_name which are queried up from qa_plans are used rather
  -- than simply using the plan_name.Commented out the existing code.
  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.

  SELECT_STMT := 'SELECT V.ROW_ID ' ||
                 'FROM "'|| l_importviewname ||'" QI,' ||
                 '    "'|| l_viewname ||'" V ' ||
                 'WHERE QI.PROCESS_STATUS = 2 ';

/*
  SELECT_STMT := 'SELECT V.ROW_ID ' ||
		 'FROM "Q_'||translate(X_PLAN_NAME, ' ''', '__')||'_IV" QI,' ||
		 '     "Q_'||translate(X_PLAN_NAME, ' ''', '__')||'_V" V ' ||
		 'WHERE QI.PROCESS_STATUS = 2 ';
*/

  FOR I IN 1..TOTAL_MATCHES LOOP
      IF DATA_TABLE(I) = 3 THEN
	  -- IF CONDITIONS_TABLE(I) IN ('TRANSACTION_DATE') THEN
          --
	  -- Date and hardcoded date.  Normally, the ELSE code will work
	  -- for both user date and hardcoded date.  Unfortunately there
	  -- is a bug in PL/SQL to_date function that causes any_to_date
	  -- to return incorrect value when applied to hardcoded date.
	  --
	  -- E.g.
	  --     create table date_test(d Date);
	  --     insert into date_test(d) values('2-JAN-2001');
	  --     select to_char(to_date(d, 'DD-MON-YYYY'), 'YYYY/MM/DD')
	  --         from date_test;
	  --
	  -- will return a date in year 0001.  (This will even generate an
	  -- error "year cannot be 0" if the year is 2000).  So, we have
	  -- to do things differently.
	  --
	  -- bso Fri Aug 28 11:55:52 PDT 1998
	  --
	  -- The above problem is solved by adding an overloaded
	  -- any_to_date that takes Date as parameter.
	  --
	  -- bso Mon Jan  4 15:33:38 PST 1999
	  --
	  --    SELECT_STMT :=  SELECT_STMT ||
          --	  ' AND V.' || CONDITIONS_TABLE(I) ||
          --	  ' = QI.' || NVL(DEVELOPER_TABLE(I),CONDITIONS_TABLE(I));
	  -- ELSE
          --
	  --

          -- Removed the DEVELOPER_TABLE(I) from the below dynamic sql(s) and used
          -- CONDITIONS_TABLE(I) directly.DEVELOPER_TABLE(I) holds the developer_name
          -- of the collection element and CONDITIONS_TABLE(I) holds the Matching
          -- Element Name which is the collection element name.This was done because
          -- nearly 25 softcoded elements have the Developer_Name different from the
          -- collection element name and this causes the issue reported in bug 3860762.
          -- Changing the Developer_Name column of all those collection elements in
          -- qa_chars would resolve the issue,but this is the easy and efficient way.
          -- Commented out the existing code.
          -- Bug 3860762.suramasw.

              /*
	      SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
	          || ' = qltdate.any_to_date(QI.' || CONDITIONS_TABLE(I) ||')';
              */

              /*
	      SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
	          || ' = qltdate.any_to_date(QI.' ||
		  NVL(DEVELOPER_TABLE(I),CONDITIONS_TABLE(I)) ||')';
              */

          -- Bug 4254876.  Above construction (3860762) is still incorrect.
          -- Now use a cleverly constructed developer_table.
          -- bso.

             SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
                 || ' = qltdate.any_to_date(QI.' || DEVELOPER_TABLE(I) ||')';

          -- END IF;

      -- For Timezone Compliance bug 3179845. Convert the datetime elements to real dates.
      -- kabalakr Mon Oct 27 04:33:49 PST 2003.

      ELSIF DATA_TABLE(I) = 6 THEN

              /*
              -- Bug 3860762.suramasw.

              SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
                  || ' = qltdate.any_to_datetime(QI.' || CONDITIONS_TABLE(I) ||')';
              */

              /*
              SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
                  || ' = qltdate.any_to_datetime(QI.' ||
                  NVL(DEVELOPER_TABLE(I),CONDITIONS_TABLE(I)) ||')';
              */

          -- Bug 4254876.  Above construction (3860762) is still incorrect.
          -- Now use a cleverly constructed developer_table.
          -- bso.

              SELECT_STMT :=  SELECT_STMT || ' AND V.' || CONDITIONS_TABLE(I)
                  || ' = qltdate.any_to_datetime(QI.' || DEVELOPER_TABLE(I) ||')';

      ELSE


          /*
          -- Bug 3860762.suramasw.

	  SELECT_STMT :=  SELECT_STMT ||
              ' AND V."' || CONDITIONS_TABLE(I) ||
              '" = QI."' || CONDITIONS_TABLE(I) || '"';
          */

          /*
	  SELECT_STMT :=  SELECT_STMT ||
              ' AND V."' || CONDITIONS_TABLE(I) ||
              '" = QI."' || NVL(DEVELOPER_TABLE(I),CONDITIONS_TABLE(I)) || '"';
          */

          -- Bug 4254876.  Above construction (3860762) is still incorrect.
          -- Now use a cleverly constructed developer_table.
          -- bso.

          SELECT_STMT :=  SELECT_STMT ||
              ' AND V."' || CONDITIONS_TABLE(I) ||
              '" = QI."' || DEVELOPER_TABLE(I) || '"';

	  -- The following line was added to resolve the bug 894858
          -- This line is needed, otherwise when rows are updated
          -- by mutiple workers it will raise MORE_THAN_ONE_ROW_MATCHED
          -- exception.  Transaction_interface_id makes the sql retrieve
          -- one rows only.
          --
          -- orashid

          -- Bug 4270911. CU2 SQL Literal fix.TD #25
          -- Use bind variable for transaction interface id.
          -- srhariha. Fri Apr 15 04:37:42 PDT 2005.
	  SELECT_STMT := SELECT_STMT || ' and QI.TRANSACTION_INTERFACE_ID = :X_INTERFACE_ID';
          -- || to_char(X_TRANSACTION_INTERFACE_ID);

      END IF;
  END LOOP;

  DBMS_SQL.PARSE(CURSOR_HANDLE, SELECT_STMT, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN_ROWID(CURSOR_HANDLE, 1, QARES_ROW);
  DBMS_SQL.BIND_VARIABLE(CURSOR_HANDLE,'X_INTERFACE_ID',X_TRANSACTION_INTERFACE_ID);
  IGNORE := DBMS_SQL.EXECUTE(CURSOR_HANDLE);
  STMT_OF_ROWIDS := '(''';
  I := 0;
  WHILE DBMS_SQL.FETCH_ROWS(CURSOR_HANDLE) > 0 LOOP
    IF I > 0
      THEN STMT_OF_ROWIDS := STMT_OF_ROWIDS ||''''||','||'''';
    END IF;
    I := I + 1;
    DBMS_SQL.COLUMN_VALUE_ROWID(CURSOR_HANDLE, 1, QARES_ROW);
    STMT_OF_ROWIDS := STMT_OF_ROWIDS || QARES_ROW;
  END LOOP;
  STMT_OF_ROWIDS := STMT_OF_ROWIDS || ''')';
  DBMS_SQL.CLOSE_CURSOR(CURSOR_HANDLE);

  IF I = 0
    THEN RAISE NO_ROWIDS_ERROR;
  ELSIF I > 1
    THEN RAISE MORE_THAN_ONE_ROWID_ERROR;
  END IF;

  RETURN STMT_OF_ROWIDS;

EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN

    INSERT INTO QA_INTERFACE_ERRORS
    (TRANSACTION_INTERFACE_ID,
     ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
     PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE)
    SELECT QRI.TRANSACTION_INTERFACE_ID, 'GROUP_ID',
           FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_INVALID_VALUE'),
 	   	 SYSDATE, X_USER_ID,
           SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
           SYSDATE
    FROM   QA_RESULTS_INTERFACE QRI
    WHERE  QRI.GROUP_ID = X_GROUP_ID
    AND  QRI.PROCESS_STATUS = 2;
    SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
		     X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
		     X_LAST_UPDATE_LOGIN, 'GROUP_ID');
    RETURN '';

  WHEN MATCHING_ERROR THEN

    INSERT INTO QA_INTERFACE_ERRORS
    (TRANSACTION_INTERFACE_ID,
     ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
     PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE)
    SELECT QRI.TRANSACTION_INTERFACE_ID, 'MATCHING_ELEMENTS',
           FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_INVALID_VALUE'),
           SYSDATE, X_USER_ID,
           SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
           SYSDATE
    FROM   QA_RESULTS_INTERFACE QRI
    WHERE  QRI.GROUP_ID = X_GROUP_ID
    AND  QRI.PROCESS_STATUS = 2;
    SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                     X_LAST_UPDATE_LOGIN, 'MATCHING_ELEMENTS');
    RETURN '';

  WHEN NO_ROWIDS_ERROR THEN

    INSERT INTO QA_INTERFACE_ERRORS
    (TRANSACTION_INTERFACE_ID,
     ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
     CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
     PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE)
    SELECT QRI.TRANSACTION_INTERFACE_ID, 'MATCHING_ELEMENTS',
           FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_NO_MATCH'),
           SYSDATE, X_USER_ID,
           SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
           SYSDATE
    FROM   QA_RESULTS_INTERFACE QRI
    WHERE  QRI.GROUP_ID = X_GROUP_ID
    AND  QRI.PROCESS_STATUS = 2;
    SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
                     X_LAST_UPDATE_LOGIN, 'MATCHING_ELEMENTS');
    RETURN '';

  WHEN MORE_THAN_ONE_ROWID_ERROR THEN

    INSERT INTO QA_INTERFACE_ERRORS
    (TRANSACTION_INTERFACE_ID,
	ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
	PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE)
    SELECT QRI.TRANSACTION_INTERFACE_ID, 'MATCHING_ELEMENTS',
		 FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_MANY_MATCHES'),
		 SYSDATE, X_USER_ID,
		 SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
		 X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
		 SYSDATE
    FROM   QA_RESULTS_INTERFACE QRI
    WHERE  QRI.GROUP_ID = X_GROUP_ID
    AND  QRI.PROCESS_STATUS = 2;
    SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
    X_LAST_UPDATE_LOGIN, 'MATCHING_ELEMENTS');

    RETURN '';

END VALIDATE_UPDATE_TYPE_RECORDS;

   -- Bug 3759926.Update transaction was failing if plan has read only or disabled elements.
   -- Retrieve update records was not considering this scenario.
   -- As part of fix, added read only and enabled flag table as parameters to the procedure.
   -- srhariha. Wed Jul 14 02:15:41 PDT 2004.


-- Adding update capabilites.
PROCEDURE RETRIEVE_UPDATE_RECORDS(X_GROUP_ID NUMBER,
			 	  STMT_OF_ROWIDS VARCHAR2,
				  DEVELOPER_NAME CHAR30_TABLE,
				  RESULT_COLUMN_NAME CHAR30_TABLE,
				  DATATYPE_TABLE NUMBER_TABLE,
				  CHAR_NAME_TABLE CHAR30_TABLE,
				  NUM_ELEMS NUMBER,
				  X_PLAN_ID NUMBER,
                                  READ_ONLY_FLAG_TABLE NUMBER_TABLE,
                                  ENABLED_FLAG_TABLE NUMBER_TABLE) IS
  UPDATE_STMT	VARCHAR2(10000);
  X_PLAN_NAME 	QA_PLANS.NAME%TYPE;

  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.
  l_viewname       VARCHAR2(100);

   -- Bug 3759926. Added the following variable.
   -- srhariha. Wed Jul 14 02:15:41 PDT 2004.

  VALUE_STRING VARCHAR2(256);

  -- Bug 4270911. Added the following variable.
  -- srhariha. Fri Apr 15 04:19:55 PDT 2005.
  L_ROWID ROWID;

BEGIN
  SELECT NAME INTO X_PLAN_NAME
  FROM QA_PLANS
  WHERE PLAN_ID = X_PLAN_ID;

  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.

  SELECT view_name
  INTO l_viewname
  FROM  QA_PLANS
  WHERE PLAN_ID = X_PLAN_ID;


  -- now that the record is stored in the PL/SQL table, populate all columns
  -- that are null with values from the corresponding QA_RESULTS record.
  -- This is so that we can use the VALIDATE_STEPS function as it was designed
  -- for insert-type records (e.g. if just the item revision column is
  -- populated in the interface record, we don't want it to error out when
  -- VALIDATE_STEPS sees that that column's parent column, item, is not
  -- populated.)

  -- For Sequence Project. Included IF conditions to consider Sequence columns.
  -- kabalakr 15 JAN 2002.

  -- Included ELSIF condition to consider Comment columns.
  -- suramasw.Bug 2917335.Thu Apr 24 21:24:56 PDT 2003.

  UPDATE_STMT := 'UPDATE QA_RESULTS_INTERFACE QRI ' || 'SET (';
  FOR I IN 1..NUM_ELEMS LOOP
    IF RESULT_COLUMN_NAME(I) LIKE 'CHARACTER%' THEN
        UPDATE_STMT := UPDATE_STMT || RESULT_COLUMN_NAME(I);
    ELSIF RESULT_COLUMN_NAME(I) LIKE 'SEQUENCE%' THEN
        UPDATE_STMT := UPDATE_STMT || RESULT_COLUMN_NAME(I);
    ELSIF RESULT_COLUMN_NAME(I) LIKE 'COMMENT%' THEN
        UPDATE_STMT := UPDATE_STMT || RESULT_COLUMN_NAME(I);
    ELSE
        UPDATE_STMT := UPDATE_STMT || DEVELOPER_NAME(I);
    END IF;
    IF I < NUM_ELEMS THEN
        UPDATE_STMT := UPDATE_STMT || ',';
    END IF;
  END LOOP;

  UPDATE_STMT := UPDATE_STMT || ') = (SELECT';

  -- date fix by Peter Chow (pchow)

  -- For Sequence Project. Included ELSIF condition to consider Sequence columns.
  -- kabalakr 15 JAN 2002.

  -- Included ELSIF condition to consider Comment columns.
  -- suramasw.Bug 2917335.Thu Apr 24 21:24:56 PDT 2003.

  FOR I IN 1..NUM_ELEMS LOOP

       -- Bug 3759926.Update transaction was failing if plan has read only or disabled elements.
       -- Retrieve update records was not considering this scenario.
       -- We check for whether element is either read only or disabled,if evaluates true
       -- dont retrieve data from QA_RESULTS (Value_String is null) ,else fetch the value.
       -- srhariha. Wed Jul 14 02:15:41 PDT 2004.

    IF (READ_ONLY_FLAG_TABLE(I) = 1) OR
                          (ENABLED_FLAG_TABLE(I) = 2) THEN
      VALUE_STRING := 'null)';
    ELSE
      VALUE_STRING := 'V."' || despecial(CHAR_NAME_TABLE(I)) || '")';
    END IF;




      IF RESULT_COLUMN_NAME(I) LIKE 'CHARACTER%' THEN
          IF DATATYPE_TABLE(I) NOT IN (3, 6) THEN
      	      UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||RESULT_COLUMN_NAME(I)||
		  ',' || VALUE_STRING;
	  ELSIF DATATYPE_TABLE(I) = 3 THEN
              UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||RESULT_COLUMN_NAME(I)||
                  ',qltdate.date_to_canon(' || VALUE_STRING || ')';

          -- For Timezone Compliance bug 3179845. Convert the datetime elements to real dates.
          -- kabalakr Mon Oct 27 04:33:49 PST 2003.

	  ELSIF DATATYPE_TABLE(I) = 6 THEN
              UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||RESULT_COLUMN_NAME(I)||
                  ',qltdate.date_to_canon_dt(' || VALUE_STRING || ')';
	  END IF;

        -- Bug 3755745.Update of result was erroring out if the plan has sequence elements.
        -- We were updating QA_RESULTS_INTERFACE wih values from QA_RESULTS for corresponding
        -- rows.But VALIDATE_SEQUENCE issues errror if a value exist for SEQUENCEXX.
        -- Hence we shouldnt retrieve value of sequence from QA_RESULTS if sequence col
        -- has null value.SEQUENCEXX can have other values than NULL.(1)User tries to
        -- update it manually or(2) it is a matching element.Both these cases are handled
        -- in VALIDATE_SEQUENCE procedures.
        -- srhariha. Fri Jul  9 05:33:30 PDT 2004.

      ELSIF RESULT_COLUMN_NAME(I) LIKE 'SEQUENCE%' THEN
              UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||RESULT_COLUMN_NAME(I)||
                 ',null)';
      ELSIF RESULT_COLUMN_NAME(I) LIKE 'COMMENT%' THEN
              UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||RESULT_COLUMN_NAME(I)||
                  ',' || VALUE_STRING;
      ELSE
          UPDATE_STMT := UPDATE_STMT||' NVL(QRI.'||DEVELOPER_NAME(I)||
              ',' || VALUE_STRING;
      END IF;
      IF I < NUM_ELEMS THEN
          UPDATE_STMT := UPDATE_STMT || ',';
      END IF;
  END LOOP;

  -- Changed the UPDATE_STMT as below so that the view_name which is
  -- queried up from qa_plans is used rather than simply using the
  -- plan_name.Commented out the existing code.
  -- Bug 2943732.suramasw.Tue May 27 07:56:48 PDT 2003.

  -- Bug 3136107.
  -- SQL Bind project. Code modified to use bind variables instead of literals
  -- Same as the fix done for Bug 3079312.suramasw.

  -- Bug 4270911. CU2 SQL Literal fix. TD #26
  -- Using bind variable for rowid under the assumption that
  -- Quality open interface dont support multi row update.
  -- srhariha. Fri Apr 15 04:19:55 PDT 2005.

  UPDATE_STMT := UPDATE_STMT || ' FROM "'|| l_viewname ||
                 '" V ' || 'WHERE V.ROW_ID = :BIND_ROWID ' ||
                 ') WHERE QRI.GROUP_ID = :GROUP_ID ';

  L_ROWID := substr(stmt_of_rowids,3,length(stmt_of_rowids)-4);

  EXECUTE IMMEDIATE UPDATE_STMT USING L_ROWID,X_GROUP_ID;

/*
  UPDATE_STMT := UPDATE_STMT || ' FROM "Q_'||
		 translate(X_PLAN_NAME, ' ''', '__') ||
		 '_V" V ' || 'WHERE V.ROW_ID IN ' || STMT_OF_ROWIDS ||
		 ') WHERE QRI.GROUP_ID = '||X_GROUP_ID;
*/

  -- QLTTRAFB.EXEC_SQL(UPDATE_STMT);

END RETRIEVE_UPDATE_RECORDS;


-- Parts of this function were modified to add update capabilities.  They were
-- declaration, new local variable, and code additions for 'stage 3'.
FUNCTION VALIDATE(X_GROUP_ID IN NUMBER,
		  TYPE_OF_TXN IN NUMBER,
		  STMT_OF_ROWIDS OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

   X_USER_ID                   NUMBER;
   X_USER_NAME                 VARCHAR2(100);
   X_REQUEST_ID                NUMBER;
   X_PROGRAM_APPLICATION_ID    NUMBER;
   X_PROGRAM_ID                NUMBER;
   X_LAST_UPDATE_LOGIN         NUMBER;

   X_PLAN_ID                   NUMBER;
   X_CHAR_ID                   NUMBER;
   X_DATATYPE                  NUMBER;
   RL_LOWER_BOUND              NUMBER;
   RL_UPPER_BOUND              NUMBER;

   CHAR_ID_TABLE               NUMBER_TABLE;
   ENABLED_FLAG_TABLE          NUMBER_TABLE;
   MANDATORY_FLAG_TABLE        NUMBER_TABLE;
   DATATYPE_TABLE              NUMBER_TABLE;
   DECIMAL_PRECISION_TABLE     NUMBER_TABLE;
   VALUES_EXIST_FLAG_TABLE     NUMBER_TABLE;
   CHAR_NAME_TABLE             CHAR30_TABLE;
   DEVELOPER_NAME_TABLE        CHAR30_TABLE;
   RESULT_COLUMN_NAME_TABLE    CHAR30_TABLE;
   SQL_VALIDATION_STRING_TABLE CHAR1500_TABLE;

   -- Bug 4254876
   -- Need hardcoded column to properly find _IV column name.
   -- This affects Update transactions.
   -- bso Tue Mar 29 15:11:39 PST 2005
   HARDCODED_COLUMN_TABLE      CHAR30_TABLE;

   ITEM_PARENT                 VARCHAR2(30) := NULL;

   CURRENT_ROW                 BINARY_INTEGER;
   NUM_ROWS                    BINARY_INTEGER;
   I                           BINARY_INTEGER;
   J                           BINARY_INTEGER;
   NUM_ELEMS                   BINARY_INTEGER;

   SQL_STATEMENT               VARCHAR2(2000);

   COPY_STMT_OF_ROWIDS	       VARCHAR2(10000);  -- For update capabilities

   RESULT_COLUMN_ID_TABLE      NUMBER_TABLE;
   COL_VAL                     VARCHAR2(100);

    -- Tracking Bug : 3104827. Review Tracking Bug : 3148873
    -- Added for Read Only for Flag Collection Plan Elements
    -- saugupta Thu Aug 28 10:34:14 PDT 2003
   READ_ONLY_FLAG_TABLE NUMBER_TABLE;

    -- Bug 4162206
    -- R12 Eanbled MOAC for Quality
    -- New variable for Inventory Org
    x_org_id NUMBER;
    dummy    BOOLEAN;

    -- MOAC: define a new cursor for getting gruop organization_id
    CURSOR inv_org_id(p_group_id NUMBER) IS
        SELECT organization_id
        FROM qa_results_interface qri
        WHERE qri.group_id = p_group_id
        AND qri.process_status = 2;



BEGIN
   -- get info for who columns

   X_USER_ID := who_user_id;
   X_REQUEST_ID := who_request_id;
   X_PROGRAM_APPLICATION_ID := who_program_application_id;
   X_PROGRAM_ID := who_program_id;
   X_LAST_UPDATE_LOGIN := who_last_update_login;

   -- stage 1 -----------------------------------------------------------------
   --
   -- validate qa_created_by_name, qa_last_updated_by_name,
   -- organization_code
   ----------------------------------------------------------------------------

   -- get the current user name.  we will use this for qa_created_by_name
   -- and qa_last_updated_by_name if they are null.

   SELECT USER_NAME
   INTO   X_USER_NAME
   FROM   FND_USER_VIEW
   WHERE  USER_ID = X_USER_ID;

   -- set qa_created_by_name and _id to the current user if they are null

   UPDATE QA_RESULTS_INTERFACE
   SET    QA_CREATED_BY = X_USER_ID,
          QA_CREATED_BY_NAME = X_USER_NAME,
          QA_LAST_UPDATED_BY = X_USER_ID,
          QA_LAST_UPDATED_BY_NAME = X_USER_NAME,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = X_USER_ID,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE
   WHERE  GROUP_ID = X_GROUP_ID
     AND  PROCESS_STATUS = 2
     AND  QA_CREATED_BY_NAME IS NULL;

   --
   -- From now on no validation is need for name because user id is
   -- passed directly from Form as a param to qlttramb.
   -- bso Fri Jul 23 11:16:04 PDT 1999
   --

   -- uncommented the following piece of code for bug 3663648.suramasw.

   -- group validation for qa_created_by_name

   -- Added the condition INSERT_TYPE <> 2 as QA_CREATED_BY_NAME should be validated
   -- only during Insert transaction.
   -- Bug 3663648.suramasw.

   INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ERROR_COLUMN,
                  ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                  CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
                  REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
                  PROGRAM_UPDATE_DATE)
      SELECT QRI.TRANSACTION_INTERFACE_ID, 'QA_CREATED_BY_NAME',
             ERROR_INVALID_VALUE, SYSDATE, X_USER_ID,
             SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
             SYSDATE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
        AND  QRI.PROCESS_STATUS = 2
        AND  QRI.INSERT_TYPE <> 2 -- added for 3663648
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN IN ('QA_CREATED_BY_NAME', NULL))
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   FND_USER_VIEW FU2
              WHERE  QRI.QA_CREATED_BY_NAME = FU2.USER_NAME);

              -- in the above where, we should really be checking start_
              -- and end_date to make sure it is a current user.  the
              -- problem with this is that user anonymous (-1) has an
              -- end date of 07-apr-88.

   -- group derivation for qa_created_by

   -- Added the condition INSERT_TYPE <> 2 as QA_CREATED_BY should be inserted
   -- only during Insert transaction.The value of QA_CREATED_BY should be
   -- inserted for QA_LAST_UPDATED_BY also during insert transaction, so included
   -- the code to insert value for QA_LAST_UPDATED_BY.
   -- Bug 3663648.suramasw.

   UPDATE QA_RESULTS_INTERFACE QRI
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          QA_CREATED_BY =
                (SELECT MIN(FU2.USER_ID)
                 FROM   FND_USER_VIEW FU2
                 WHERE  FU2.USER_NAME = QRI.QA_CREATED_BY_NAME),
          QA_LAST_UPDATED_BY =
                (SELECT MIN(FU2.USER_ID)
                 FROM   FND_USER_VIEW FU2
                 WHERE  FU2.USER_NAME = QRI.QA_CREATED_BY_NAME)
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2
      AND QRI.INSERT_TYPE <> 2  -- added for 3663648
      AND NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('QA_CREATED_BY_NAME', NULL));

   -- set qa_last_updated_by_name and _id to the current user if they are null

   -- The following piece of code was commented in version 115.76. But the code
   -- should be present to figure out qa_last_updated_by_name and qa_last_updated_by
   -- when the user doesnot provide the value for qa_last_updated_by_name when
   -- updating the record.Hence uncommented the code.
   -- Bug 3663648.suramasw.

   UPDATE QA_RESULTS_INTERFACE
   SET    QA_LAST_UPDATED_BY = X_USER_ID,
          QA_LAST_UPDATED_BY_NAME = X_USER_NAME
   WHERE  GROUP_ID = X_GROUP_ID
     AND  PROCESS_STATUS = 2
     AND  QA_LAST_UPDATED_BY_NAME IS NULL;

   -- group validation for qa_last_updated_by_name

   -- Added the condition INSERT_TYPE = 2 because QA_LAST_UPDATED_BY_NAME
   -- should be validated only during update transaction.
   -- Bug 3663648.suramasw.

   INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ERROR_COLUMN,
                  ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                  CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
                  REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
                  PROGRAM_UPDATE_DATE)
      SELECT QRI.TRANSACTION_INTERFACE_ID, 'QA_LAST_UPDATED_BY_NAME',
             ERROR_INVALID_VALUE, SYSDATE, X_USER_ID,
             SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
             SYSDATE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
        AND  QRI.PROCESS_STATUS = 2
        AND  QRI.INSERT_TYPE = 2 -- added for 3663648
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN IN ('QA_LAST_UPDATED_BY_NAME', NULL))
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   FND_USER_VIEW FU2
              WHERE  QRI.QA_LAST_UPDATED_BY_NAME = FU2.USER_NAME);

              -- in the above where, we should really be checking start_
              -- and end_date to make sure it is a current user.  the
              -- problem with this is that user anonymous (-1) has an
              -- end date of 07-apr-88.

   -- group derivation for qa_last_updated_by

   -- Added the condition INSERT_TYPE = 2 because QA_LAST_UPDATED_BY_NAME
   -- should be updated only during update transaction.Also modified
   -- QA_CREATED_BY to QA_LAST_UPDATED_BY as we need to update only
   -- QA_LAST_UPDATED_BY during update transaction.
   -- Bug 3663648.suramasw.

   UPDATE QA_RESULTS_INTERFACE QRI
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          QA_LAST_UPDATED_BY=
                (SELECT MIN(FU2.USER_ID)
                 FROM   FND_USER_VIEW FU2
                 WHERE  FU2.USER_NAME = QRI.QA_LAST_UPDATED_BY_NAME)
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2
      AND QRI.INSERT_TYPE = 2 -- added for 3663648
      AND NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('QA_LAST_UPDATED_BY_NAME', NULL));


   -- group validation for organization_code
   -- Bug 4958776. SQL Repository Fix SQL ID: 15009159
   -- replaced ORG_ORGANIZATION_DEFINITIONS with MTL_PARAMETERS
   INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ERROR_COLUMN,
                  ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                  CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
                  REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
                  PROGRAM_UPDATE_DATE)
      SELECT QRI.TRANSACTION_INTERFACE_ID, 'ORGANIZATION_CODE',
             ERROR_INVALID_VALUE, SYSDATE, X_USER_ID,
             SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
             SYSDATE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
        AND  QRI.PROCESS_STATUS = 2
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN IN ('ORGANIZATION_CODE', NULL))
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   MTL_PARAMETERS OOD
              WHERE  QRI.ORGANIZATION_CODE = OOD.ORGANIZATION_CODE);
              --  AND  NVL(OOD.DISABLE_DATE, SYSDATE) >= SYSDATE);

   -- group derivation for organization_id
   -- Bug 4958776. SQL Repository Fix SQL ID: 15009164
   -- replaced ORG_ORGANIZATION_DEFINITIONS with MTL_PARAMETERS
   UPDATE QA_RESULTS_INTERFACE QRI
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          ORGANIZATION_ID =
                (SELECT MIN(OOD.ORGANIZATION_ID)
                 FROM   MTL_PARAMETERS OOD
                 WHERE  OOD.ORGANIZATION_CODE = QRI.ORGANIZATION_CODE)
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2
      AND NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('ORGANIZATION_CODE', NULL));

   -- set process_status to 3 for all rows where org_code had an error.
   -- this prevents these rows from being looked at in the remaining
   -- validation steps.

   SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
         X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, X_LAST_UPDATE_LOGIN,
         'ORGANIZATION_CODE');

   -- Bug 4162206
   -- R12 Enabled MOAC for Quality
   -- get the inventory org and set the corresponding profile
   -- saugupta Mon, 09 May 2005 06:34:11 -0700 PDT

   -- Bug 4498976. Moved query for getting group inv org to cursor
   -- saugupta Tue, 02 Aug 2005 02:14:21 -0700 PDT
   open inv_org_id(X_GROUP_ID);
   fetch inv_org_id into x_org_id;
   close inv_org_id;

   --
   -- Bug 5604471
   -- Replaced the call to the fnd_profile.save_user API
   -- with fnd_profile.put
   -- ntungare Tue Oct 17 04:27:44 PDT 2006
   --

   -- R12 Project MOAC 4637896.  MOAC entities now initialized
   -- in procedure wrapper.  Here the inventory org_id is known,
   -- we will initialize the mfg_organization_id profile as
   -- needed by PJM entities which are not OU-based but
   -- Inv organization based.
   -- bso Sun Oct  2 11:51:33 PDT 2005

   --dummy := fnd_profile.save_user('MFG_ORGANIZATION_ID', x_org_id);
   fnd_profile.put('MFG_ORGANIZATION_ID', x_org_id);

   -- R12 Project MOAC 4637896.
   -- Group validation of operating unit field, which is an
   -- optional field.  This algorithm is slightly improved
   -- on the other validation algorithms such as the org code
   -- validation above.  This is a more direct algorithm to
   -- perform the validation first and then set the error
   -- table if validation failed.  The previous algorithm
   -- performs in the opposite order and is probably more
   -- efficient if there is a lot of errors.  This hits the
   -- referenced entity only once and should be more efficient
   -- assuming normally there is only a few errors.
   -- bso Sun Oct  2 16:29:30 PDT 2005

   UPDATE qa_results_interface qri
   SET    last_update_date = sysdate,
          last_update_login = x_last_update_login,
          request_id = x_request_id,
          program_application_id = x_program_application_id,
          program_id = x_program_id,
          program_update_date = sysdate,
          operating_unit_id =
              (SELECT ou.organization_id
               FROM   hr_operating_units ou
               WHERE  ou.name = qri.operating_unit AND
                      (ou.date_from IS NULL OR ou.date_from <= sysdate) AND
                      (ou.date_to IS NULL OR ou.date_to >= sysdate))
   WHERE  qri.group_id = x_group_id AND
          qri.process_status = 2 AND
          qri.operating_unit IS NOT NULL AND
          qri.operating_unit_id IS NULL;

   INSERT INTO qa_interface_errors(
          transaction_interface_id,
          error_column,
          error_message,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date)
       SELECT qri.transaction_interface_id,
              'OPERATING_UNIT',
              ERROR_INVALID_VALUE,
              sysdate,
              x_user_id,
              sysdate,
              x_user_id,
              x_last_update_login,
              x_request_id,
              x_program_application_id,
              x_program_id,
              sysdate
       FROM   qa_results_interface qri
       WHERE  qri.group_id = x_group_id AND
              qri.process_status = 2 AND
              qri.operating_unit IS NOT NULL AND
              qri.operating_unit_id IS NULL;


   -- stage 2 -----------------------------------------------------------------
   --
   -- validate plan_name, spec_name
   ----------------------------------------------------------------------------

   -- group validation for plan_name

   INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ERROR_COLUMN,
                  ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                  CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
                  REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
                  PROGRAM_UPDATE_DATE)
      SELECT QRI.TRANSACTION_INTERFACE_ID, 'PLAN_NAME',
             ERROR_INVALID_VALUE, SYSDATE, X_USER_ID,
             SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
             SYSDATE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
        AND  QRI.PROCESS_STATUS = 2
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN IN ('PLAN_NAME', NULL))
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_PLANS_VAL_V QPVV
              WHERE  QRI.PLAN_NAME = QPVV.NAME
                AND  QRI.ORGANIZATION_ID = QPVV.ORGANIZATION_ID);

   -- group derivation for plan_id

   UPDATE QA_RESULTS_INTERFACE QRI
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PLAN_ID =
                (SELECT MIN(QPVV.PLAN_ID)
                 FROM   QA_PLANS_VAL_V QPVV
                 WHERE  QPVV.NAME = QRI.PLAN_NAME
                   AND  QPVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID)
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2
      AND NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('PLAN_NAME', NULL));

   -- group validation for spec_name

   --
   -- Bug 2672408.  This SQL used to have QA_SPECS_VAL_V in the
   -- subquery.  It uses too much shared memory.  Replaced with
   -- QA_SPECS and appended the effective date validation.
   -- bso Mon Nov 25 18:15:12 PST 2002
   --
   INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ERROR_COLUMN,
                  ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                  CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
                  REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
                  PROGRAM_UPDATE_DATE)
      SELECT QRI.TRANSACTION_INTERFACE_ID, 'SPEC_NAME',
             ERROR_INVALID_VALUE, SYSDATE, X_USER_ID,
             SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
             X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
             SYSDATE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
        AND  QRI.PROCESS_STATUS = 2
        AND  NOT EXISTS
             (SELECT 'X'
              FROM   QA_INTERFACE_ERRORS QIE
              WHERE  QIE.TRANSACTION_INTERFACE_ID =
                           QRI.TRANSACTION_INTERFACE_ID
                AND  QIE.ERROR_COLUMN IN ('SPEC_NAME', NULL))
        AND  (QRI.SPEC_NAME IS NOT NULL
              AND NOT EXISTS
              (SELECT 'X'
               FROM   QA_SPECS QSVV
               WHERE  QRI.SPEC_NAME = QSVV.SPEC_NAME
                     AND  QRI.ORGANIZATION_ID = QSVV.ORGANIZATION_ID
                     AND  trunc(sysdate) BETWEEN
                          nvl(trunc(qsvv.effective_from), trunc(sysdate)) AND
                          nvl(trunc(qsvv.effective_to), trunc(sysdate))));

   -- group derivation for spec_id

   --
   -- Bug 2672408.  This SQL used to have QA_SPECS_VAL_V in the
   -- subquery.  It uses too much shared memory.  Replaced with
   -- QA_SPECS and appended the effective date validation.
   -- bso Mon Nov 25 18:15:12 PST 2002
   --
   UPDATE QA_RESULTS_INTERFACE QRI
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          SPEC_ID =
                (SELECT MIN(QSVV.SPEC_ID)
                 FROM   QA_SPECS QSVV
                 WHERE  QSVV.SPEC_NAME = QRI.SPEC_NAME
                   AND  QSVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID
                     AND  trunc(sysdate) BETWEEN
                          nvl(trunc(qsvv.effective_from), trunc(sysdate)) AND
                          nvl(trunc(qsvv.effective_to), trunc(sysdate)))
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2
      AND NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('SPEC_NAME', NULL));

   -- set process_status to 3 for all rows where plan_name or spec_name
   -- had an error.  this prevents these rows from being looked at in
   -- the remaining validation steps.

   SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
         X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, X_LAST_UPDATE_LOGIN,
         'PLAN_NAME');
   SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
         X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, X_LAST_UPDATE_LOGIN,
         'SPEC_NAME');

   -- for the remaining stages, we'll need plan_id.  while we're at it,
   -- we can check for free to see if there are any rows left that haven't
   -- failed.

   SELECT MAX(PLAN_ID)
   INTO   X_PLAN_ID
   FROM   QA_RESULTS_INTERFACE QRI
   WHERE  QRI.GROUP_ID = X_GROUP_ID
     AND  NOT EXISTS
          (SELECT 'X'
           FROM   QA_INTERFACE_ERRORS QIE
           WHERE  QIE.TRANSACTION_INTERFACE_ID =
                        QRI.TRANSACTION_INTERFACE_ID
             AND  QIE.ERROR_COLUMN IN ('ORGANIZATION_CODE', 'PLAN_NAME',
                                       'SPEC_NAME', NULL));

   -- when x_plan_id is null, it indicates that every row has failed
   -- validation.  if this is the case, it's pointless to go through all
   -- the remaining validation steps.  to save time, we exit here.

   IF (X_PLAN_ID IS NULL) THEN
      SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
            X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, X_LAST_UPDATE_LOGIN);
      RETURN TRUE;
   END IF;

   -- stage 3 -----------------------------------------------------------------
   --
   -- validate line_id, comp_item_id, department_id, resource_id, quantity,
   -- wip_entity_id, vendor_id, receipt_num, po_header_id, customer_id,
   -- so_header_id, rma_header_id.
   -- asset_group, asset_activity - rkunchal Thu Jul 18 07:23:13 PDT 2002
   ----------------------------------------------------------------------------

   -- load in reference info for each collection element on the plan

--
-- See Bug 2624112
-- The decimal precision for a number type collection
-- element is to be configured at plan level. Hence,
-- validation should also be based on plan setup.
-- rkunchal Wed Oct 16 05:32:33 PDT 2002
--
-- Before this change, DECIMAL_PRECISION was selected from QC
-- Now, DECIMAL_PRECISION is selected from QPCV
--
-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Modifying to include Read Only Flag for Collection Plan Elements
-- saugupta Thu Aug 28 08:59:59 PDT 2003

/*
   I := 0;
   FOR CHARREC IN (SELECT QPCV.CHAR_ID, QC.DEVELOPER_NAME,
                   QPCV.RESULT_COLUMN_NAME, QPCV.ENABLED_FLAG,
                   QPCV.MANDATORY_FLAG, QC.DATATYPE, QPCV.DECIMAL_PRECISION,
                   QC.SQL_VALIDATION_STRING, QPCV.VALUES_EXIST_FLAG,
                   UPPER(REPLACE(QC.NAME, ' ', '_')) CHAR_NAME, READ_ONLY_FLAG
                   FROM QA_CHARS QC, QA_PLAN_CHARS_V QPCV
                   WHERE QPCV.PLAN_ID = X_PLAN_ID
                     AND QPCV.CHAR_ID = QC.CHAR_ID) LOOP
      I := I + 1;
      CHAR_ID_TABLE(I)               := CHARREC.CHAR_ID;
      CHAR_NAME_TABLE(I)             := CHARREC.CHAR_NAME;
      DEVELOPER_NAME_TABLE(I)        := CHARREC.DEVELOPER_NAME;
      RESULT_COLUMN_NAME_TABLE(I)    := CHARREC.RESULT_COLUMN_NAME;
      ENABLED_FLAG_TABLE(I)          := CHARREC.ENABLED_FLAG;
      MANDATORY_FLAG_TABLE(I)        := CHARREC.MANDATORY_FLAG;
      DATATYPE_TABLE(I)              := CHARREC.DATATYPE;
      DECIMAL_PRECISION_TABLE(I)     := CHARREC.DECIMAL_PRECISION;
      SQL_VALIDATION_STRING_TABLE(I) := CHARREC.SQL_VALIDATION_STRING;
      VALUES_EXIST_FLAG_TABLE(I)     := CHARREC.VALUES_EXIST_FLAG;
      READ_ONLY_FLAG_TABLE(I)        := CHARREC.READ_ONLY_FLAG;

   END LOOP;
   NUM_ELEMS := I;
*/
   --
   -- Bug 4254876
   -- Changed above to fetch hardcoded column.
   -- Also changed qpcv to qpc and make into an efficient BULK op.
   -- Finally, use the same replace/translate function as used in qltvcreb
   -- bso Tue Mar 29 15:18:00 PST 2005
   --

   -- Just added the nvl condition for decimal_precision column.
   -- This was done to have the select statement similar to the
   -- definition of qa_plan_chars_v which was used before this fix.
   -- Bug 4254876.suramasw

   SELECT
       qpc.char_id,
       upper(replace(qc.name, ' ', '_')),
       qc.hardcoded_column,
       qc.developer_name,
       qpc.result_column_name,
       qpc.enabled_flag,
       qpc.mandatory_flag,
       qc.datatype,
       nvl(qpc.decimal_precision,qc.decimal_precision),
       qc.sql_validation_string,
       qpc.values_exist_flag,
       qpc.read_only_flag
   BULK COLLECT INTO
       char_id_table,
       char_name_table,
       hardcoded_column_table,
       developer_name_table,
       result_column_name_table,
       enabled_flag_table,
       mandatory_flag_table,
       datatype_table,
       decimal_precision_table,
       sql_validation_string_table,
       values_exist_flag_table,
       read_only_flag_table
   FROM
       qa_chars qc,
       qa_plan_chars qpc
   WHERE
       qpc.plan_id = x_plan_id AND
       qpc.char_id = qc.char_id;

   NUM_ELEMS := char_id_table.count;


   -- Adding update capabilities.  1 = 'INSERT' and 2 = 'UPDATE';
   -- also everything else will be interpreted as 'INSERT'
   IF TYPE_OF_TXN = 2 THEN
        COPY_STMT_OF_ROWIDS := VALIDATE_UPDATE_TYPE_RECORDS(X_GROUP_ID,
						 X_PLAN_ID,
						 CHAR_NAME_TABLE,
						 DEVELOPER_NAME_TABLE,
                                                 HARDCODED_COLUMN_TABLE,  -- Bug 4254876
						 DATATYPE_TABLE,
						 NUM_ELEMS,
						 X_USER_ID,
						 X_LAST_UPDATE_LOGIN,
						 X_REQUEST_ID,
						 X_PROGRAM_APPLICATION_ID,
						 X_PROGRAM_ID);
	STMT_OF_ROWIDS := COPY_STMT_OF_ROWIDS;

          -- Bug 3759926.Update transaction was failing if plan has read only or disabled elements.
          -- Retrieve update records was not considering this scenario.
          -- As part of fix, passing read only and enabled flag table as arguments to the procedure.
          -- srhariha. Wed Jul 14 02:15:41 PDT 2004.

	IF COPY_STMT_OF_ROWIDS IS NOT NULL THEN
	    RETRIEVE_UPDATE_RECORDS(X_GROUP_ID,
				  COPY_STMT_OF_ROWIDS,
				  DEVELOPER_NAME_TABLE,
				  RESULT_COLUMN_NAME_TABLE,
				  DATATYPE_TABLE,
				  CHAR_NAME_TABLE,
				  NUM_ELEMS,
				  X_PLAN_ID,
                                  READ_ONLY_FLAG_TABLE,
                                  ENABLED_FLAG_TABLE);
	ELSE
	    RETURN TRUE;
	END IF;
   END IF;

   -- locate each element in the collection element reference tables
   -- and if it is on the plan, go through the validation steps

   I := POSITION_IN_TABLE('PRODUCTION_LINE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      -- set production line to be a parent of item (used later on)

      -- rkaza. 02/03/2003. Bug 2777401.
      -- ITEM_PARENT being production_line is only used to check if production
      -- line is entered, if present in the plan, during the validation of item.
      -- This is causing the bug. We removed this dependency in forms too.

      -- ITEM_PARENT := 'PRODUCTION_LINE';

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PRODUCTION_LINE', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'WIP_LINES_VAL_V WL',
            'QRI.PRODUCTION_LINE = WL.LINE_CODE AND ' ||
                  'QRI.ORGANIZATION_ID = WL.ORGANIZATION_ID',
            'LINE_ID = (SELECT MIN(WL.LINE_ID) ' ||
                  'FROM WIP_LINES_VAL_V WL ' ||
                  'WHERE WL.LINE_CODE = QRI.PRODUCTION_LINE ' ||
                  'AND WL.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('DEPARTMENT', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'DEPARTMENT', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'BOM_DEPARTMENTS_VAL_V BD',
            'QRI.DEPARTMENT = BD.DEPARTMENT_CODE AND ' ||
                  'QRI.ORGANIZATION_ID = BD.ORGANIZATION_ID',
            'DEPARTMENT_ID = (SELECT MIN(BD.DEPARTMENT_ID) ' ||
                  'FROM BOM_DEPARTMENTS_VAL_V BD ' ||
                  'WHERE BD.DEPARTMENT_CODE = QRI.DEPARTMENT ' ||
                  'AND BD.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('TO_DEPARTMENT', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TO_DEPARTMENT', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'BOM_DEPARTMENTS_VAL_V BD',
            'QRI.TO_DEPARTMENT = BD.DEPARTMENT_CODE AND ' ||
                  'QRI.ORGANIZATION_ID = BD.ORGANIZATION_ID',
            'TO_DEPARTMENT_ID = (SELECT MIN(BD.DEPARTMENT_ID) ' ||
                  'FROM BOM_DEPARTMENTS_VAL_V BD ' ||
                  'WHERE BD.DEPARTMENT_CODE = QRI.TO_DEPARTMENT ' ||
                  'AND BD.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));
   END IF;


   I := POSITION_IN_TABLE('RESOURCE_CODE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'RESOURCE_CODE', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'BOM_RESOURCES_VAL_V BR',
            'QRI.RESOURCE_CODE = BR.RESOURCE_CODE AND ' ||
                  'QRI.ORGANIZATION_ID = BR.ORGANIZATION_ID',
            'RESOURCE_ID = (SELECT MIN(BR.RESOURCE_ID) ' ||
                  'FROM BOM_RESOURCES_VAL_V BR ' ||
                  'WHERE BR.RESOURCE_CODE = QRI.RESOURCE_CODE ' ||
                  'AND BR.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('JOB_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      -- Changed the below procedure call to use different FROM clause
      -- WIP_OPEN_DISCRETE_JOBS_VAL_V is changed to WIP_DISCRETE_JOBS_ALL_V
      -- See bug #2382432
      -- rkunchal Wed Jun  5 02:03:28 PDT 2002
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'JOB_NAME', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, ' WIP_DISCRETE_JOBS_ALL_V WE ',
            'QRI.JOB_NAME = WE.WIP_ENTITY_NAME AND ' ||
                  'QRI.ORGANIZATION_ID = WE.ORGANIZATION_ID',
            'WIP_ENTITY_ID = (SELECT MIN(WE.WIP_ENTITY_ID) ' ||
                  'FROM WIP_DISCRETE_JOBS_ALL_V WE ' ||
                  'WHERE WE.WIP_ENTITY_NAME = QRI.JOB_NAME ' ||
                  'AND WE.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- To fix the reopened bug 2368381
   -- To make importing validate Maintenance Workorders also
   -- rkunchal Thu Jul 18 07:23:13 PDT 2002

   I := POSITION_IN_TABLE('WORK_ORDER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
		     'WORK_ORDER',
		     X_GROUP_ID,
		     X_USER_ID,
		     X_LAST_UPDATE_LOGIN,
		     X_REQUEST_ID,
		     X_PROGRAM_APPLICATION_ID,
		     X_PROGRAM_ID,
		     'WIP_ENTITIES WO',
		     'QRI.WORK_ORDER = WO.WIP_ENTITY_NAME AND ' || 'QRI.ORGANIZATION_ID = WO.ORGANIZATION_ID',
		     'WORK_ORDER_ID = (SELECT WE.WIP_ENTITY_ID ' || 'FROM WIP_ENTITIES WE ' ||
		        'WHERE WE.WIP_ENTITY_NAME = QRI.WORK_ORDER ' ||
			'AND WE.ORGANIZATION_ID = QRI.ORGANIZATION_ID AND WE.ENTITY_TYPE IN (6, 7))',
		     CHAR_ID_TABLE(I),
		     CHAR_NAME_TABLE(I),
		     DATATYPE_TABLE(I),
		     DECIMAL_PRECISION_TABLE(I),
		     X_PLAN_ID,
		     VALUES_EXIST_FLAG_TABLE(I),
                     READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- End of additions for Workorder part of bug 2368381

   I := POSITION_IN_TABLE('VENDOR_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'VENDOR_NAME', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'PO_VENDORS PV',
            'QRI.VENDOR_NAME = PV'||g_period||'VENDOR_NAME', -- bug 3554899.
            'VENDOR_ID = (SELECT MIN(PV.VENDOR_ID) ' ||
                  'FROM PO_VENDORS PV ' ||
                  'WHERE PV.VENDOR_NAME = QRI.VENDOR_NAME)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
            READ_ONLY_FLAG_TABLE(I));

   END IF;

   -- R12 Project MOAC 4637896.
   -- Change PO Number validation to use qa_po_numbers_lov_v as
   -- driving table using qri.operating_unit_id as auxilliary
   -- validation if it exists.
   I := POSITION_IN_TABLE('PO_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PO_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'qa_po_numbers_lov_v PH',
            'QRI.PO_NUMBER = PH.SEGMENT1',
            'PO_HEADER_ID = (SELECT PH.PO_HEADER_ID ' ||
                  'FROM qa_po_numbers_lov_v ph ' ||
                  'WHERE ph.segment1 = qri.po_number AND ' ||
                        '(qri.operating_unit_id IS NULL ' ||
                        ' OR qri.operating_unit_id = ph.org_id) AND ' ||
                        'rownum = 1)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('PO_RELEASE_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PO_RELEASE_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'PO_RELEASES PR',
            'PR.PO_HEADER_ID = QRI.PO_HEADER_ID AND PR.RELEASE_NUM = QRI.PO_RELEASE_NUM',
            'PO_RELEASE_ID = (SELECT MIN(PR.PO_RELEASE_ID) ' ||
                  'FROM PO_RELEASES PR ' ||
                  'WHERE PR.PO_HEADER_ID = QRI.PO_HEADER_ID AND PR.RELEASE_NUM = QRI.PO_RELEASE_NUM)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I) );
   END IF;

   I := POSITION_IN_TABLE('CUSTOMER_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'CUSTOMER_NAME', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'QA_CUSTOMERS_LOV_V RC',
            'QRI.CUSTOMER_NAME = RC.CUSTOMER_NAME AND ' ||
                  'RC.STATUS = ''A'' AND ' ||
                  'NVL(RC.CUSTOMER_PROSPECT_CODE, ''CUSTOMER'') = ' ||
                        '''CUSTOMER''',
            'CUSTOMER_ID = (SELECT MIN(RC.CUSTOMER_ID) ' ||
                  'FROM QA_CUSTOMERS_LOV_V RC ' ||
                  'WHERE RC.CUSTOMER_NAME = QRI.CUSTOMER_NAME ' ||
                  'AND RC.STATUS = ''A'' AND ' ||
                  'NVL(RC.CUSTOMER_PROSPECT_CODE, ''CUSTOMER'') = ' ||
                        '''CUSTOMER'')',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- add project and task validation here
/*
mtl_project_v changed to pjm_projects_all_v (selects from both pjm enabled and
non-pjm enabled orgs).
rkaza, 11/10/2001.
*/

--
--  Bug 5249078.  Changed pjm_projects_all_v to
--  pjm_projects_v for MOAC compliance.
--  bso Thu Jun  1 10:46:50 PDT 2006
--

    I := POSITION_IN_TABLE('PROJECT_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PROJECT_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'PJM_PROJECTS_V PPAV',
            'QRI.PROJECT_NUMBER = PPAV.PROJECT_NUMBER ',
            'PROJECT_ID = (SELECT MIN(PPAV.PROJECT_ID) ' ||
                  'FROM PJM_PROJECTS_ALL_V  PPAV ' ||
                  'WHERE PPAV.PROJECT_NUMBER = QRI.PROJECT_NUMBER ) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

--
-- Bug 5249078.  There is no need to change the following
-- pjm_projects_all_v because the dependent project no. has
-- been validated by the logic above.
-- bso Thu Jun  1 10:54:20 PDT 2006
--

 I := POSITION_IN_TABLE('TASK_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
 IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TASK_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'PA_TASKS PT',
            'QRI.TASK_NUMBER = PT.TASK_NUMBER AND '||
            'QRI.PROJECT_ID = PT.PROJECT_ID ',
            'TASK_ID = (SELECT MIN(PT.TASK_ID) ' ||
                  'FROM PA_TASKS  PT  ' ||
                  'WHERE PT.TASK_NUMBER = QRI.TASK_NUMBER  '||
                  'AND PT.PROJECT_ID = ( Select MIN ( PPAV.PROJECT_ID) ' ||
                  'FROM PJM_PROJECTS_ALL_V PPAV  ' ||
                  'WHERE PPAV.PROJECT_NUMBER = QRI.PROJECT_NUMBER ) ) ' ,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL,'PROJECT_NUMBER' );
   END IF;

-- R12 OPM Deviations. Bug 4345503 Start
  I := POSITION_IN_TABLE('PROCESS_BATCH_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
  IF (I <> -1) THEN
    VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PROCESS_BATCH_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'GME_BATCH_HEADER GBH',
            'QRI.PROCESS_BATCH_NUM = GBH.BATCH_NO AND QRI.ORGANIZATION_ID = GBH.ORGANIZATION_ID ',
            'PROCESS_BATCH_ID = (SELECT MIN(GBH.BATCH_ID) ' ||
	    'FROM GME_BATCH_HEADER GBH ' ||
	    'WHERE GBH.BATCH_NO = QRI.PROCESS_BATCH_NUM AND '||
	    'GBH.ORGANIZATION_ID = QRI.ORGANIZATION_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
  END IF;

  I := POSITION_IN_TABLE('PROCESS_BATCHSTEP_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
  IF (I <> -1) THEN
    VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PROCESS_BATCHSTEP_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'GME_BATCH_STEPS GBS',
            'QRI.PROCESS_BATCHSTEP_NUM = GBS.BATCHSTEP_NO AND QRI.PROCESS_BATCH_ID = GBS.BATCH_ID ',
            'PROCESS_BATCHSTEP_ID = (SELECT MIN (GBS.BATCHSTEP_ID) FROM GME_BATCH_STEPS GBS '||
            'WHERE GBS.BATCHSTEP_NO = QRI.PROCESS_BATCHSTEP_NUM ' ||
            'AND GBS.BATCH_ID = QRI.PROCESS_BATCH_ID)',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL,'PROCESS_BATCH_NUM');
  END IF;

  --
  -- bug 5343944
  -- Corrected the Typo where the process_operation
  -- was written as process_operaton due to which
  -- the data for this element was not getting
  -- collected during collection import
  -- ntungare Thu Sep 14 10:09:59 PDT 2006
  --
  --I := POSITION_IN_TABLE('PROCESS_OPERATON', DEVELOPER_NAME_TABLE, NUM_ELEMS);
  I := POSITION_IN_TABLE('PROCESS_OPERATION', DEVELOPER_NAME_TABLE, NUM_ELEMS);
     IF (I <> -1) THEN
       VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
               'PROCESS_OPERATION', X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, 'GMO_BATCH_STEPS_V GBSV',
               'QRI.PROCESS_OPERATION= GBSV.OPERATION AND '||
               'QRI.PROCESS_BATCH_ID = GBSV.BATCH_ID AND '||
               --
               -- bug 5343944
               -- the view GSBV has the column batchstep_id and
               -- not batch_step_id. Similarly the table QRI has
               -- column process_batchstep_id and not batch_step_id
               -- Made necessary corrections
               -- ntungare
               --
               -- 'QRI.BATCH_STEP_ID = GBSV.BATCH_STEP_ID ',
               'QRI.PROCESS_BATCHSTEP_ID = GBSV.BATCHSTEP_ID ',
               'PROCESS_OPERATION_ID = (SELECT MIN (GBSV.OPRN_ID) FROM '||
               'GMO_BATCH_STEPS_V GBSV WHERE GBSV.OPERATION = '||
               'QRI.PROCESS_OPERATION AND GBSV.BATCH_ID = QRI.PROCESS_BATCH_ID '||
               'AND GBSV.BATCHSTEP_ID = QRI.PROCESS_BATCHSTEP_ID)',
               CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
               DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
               READ_ONLY_FLAG_TABLE(I),NULL,
               'PROCESS_BATCH_NUM', 'PROCESS_BATCHSTEP_NUM');
  END IF;

  I := POSITION_IN_TABLE('PROCESS_ACTIVITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
     IF (I <> -1) THEN
       VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
               'PROCESS_ACTIVITY', X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, 'GME_BATCH_STEP_ACTIVITIES GBSA',
               'QRI.PROCESS_ACTIVITY = GBSA.ACTIVITY AND '||
               'QRI.PROCESS_BATCH_ID = GBSA.BATCH_ID AND '||
               'QRI.PROCESS_BATCHSTEP_ID = GBSA.BATCHSTEP_ID ',
               'PROCESS_ACTIVITY_ID = (SELECT MIN (GBSA.BATCHSTEP_ACTIVITY_ID) '||
               'FROM GME_BATCH_STEP_ACTIVITIES GBSA WHERE GBSA.ACTIVITY = '||
               'QRI.PROCESS_ACTIVITY AND GBSA.BATCH_ID = QRI.PROCESS_BATCH_ID '||
               'AND GBSA.BATCHSTEP_ID = QRI.PROCESS_BATCHSTEP_ID)',
               CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
               DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
               READ_ONLY_FLAG_TABLE(I),NULL,
               'PROCESS_BATCH_NUM', 'PROCESS_BATCHSTEP_NUM');
  END IF;

  I := POSITION_IN_TABLE('PROCESS_RESOURCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
     IF (I <> -1) THEN
       VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
               'PROCESS_RESOURCE', X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, 'GME_BATCH_STEP_RESOURCES GBSR',
               'QRI.PROCESS_RESOURCE = GBSR.RESOURCES AND QRI.PROCESS_BATCH_ID = '||
               'GBSR.BATCH_ID AND QRI.PROCESS_BATCHSTEP_ID = GBSR.BATCHSTEP_ID '||
               'AND QRI.PROCESS_ACTIVITY_ID = GBSR.BATCHSTEP_ACTIVITY_ID ',
               'PROCESS_RESOURCE_ID = (SELECT MIN (GBSR.BATCHSTEP_RESOURCE_ID) '||
               'FROM GME_BATCH_STEP_RESOURCES GBSR WHERE GBSR.RESOURCES = '||
               'QRI.PROCESS_RESOURCE AND GBSR.BATCH_ID = QRI.PROCESS_BATCH_ID '||
               'AND GBSR.BATCHSTEP_ID = QRI.PROCESS_BATCHSTEP_ID AND '||
               'GBSR.BATCHSTEP_ACTIVITY_ID = QRI.PROCESS_ACTIVITY_ID)',
               CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
               DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
               READ_ONLY_FLAG_TABLE(I),NULL,
               'PROCESS_BATCH_NUM', 'PROCESS_BATCHSTEP_NUM', 'PROCESS_ACTIVITY');
  END IF;

  I := POSITION_IN_TABLE('PROCESS_PARAMETER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
     IF (I <> -1) THEN
       VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
               'PROCESS_PARAMETER', X_GROUP_ID, X_USER_ID,
               X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID, 'GMP_PROCESS_PARAMETERS GP, GME_PROCESS_PARAMETERS GE',
               'QRI.PROCESS_PARAMETER = GP.PARAMETER_NAME AND GP.PARAMETER_ID = '||
               'GE.PARAMETER_ID AND GE.BATCHSTEP_RESOURCE_ID = QRI.PROCESS_RESOURCE_ID ',
               'PROCESS_PARAMETER_ID = (SELECT MIN (PARAMETER_ID) FROM '||
               'GME_PROCESS_PARAMETERS GE WHERE '||
               'GE.BATCHSTEP_RESOURCE_ID = '||
               'QRI.PROCESS_RESOURCE_ID)',
               CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
               DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I),
               READ_ONLY_FLAG_TABLE(I),NULL,
               'PROCESS_RESOURCE');
  END IF;
-- R12 OPM Deviations. Bug 4345503 End

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta

   I := POSITION_IN_TABLE('LICENSE_PLATE_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'LICENSE_PLATE_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'WMS_LICENSE_PLATE_NUMBERS WLPN',
            'QRI.LICENSE_PLATE_NUMBER = WLPN.LICENSE_PLATE_NUMBER ',
            'LPN_ID = (SELECT WLPN.LPN_ID ' ||
                 'FROM WMS_LICENSE_PLATE_NUMBERS WLPN '||
                 'WHERE WLPN.LICENSE_PLATE_NUMBER = QRI.LICENSE_PLATE_NUMBER'
            || ' AND ROWNUM = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

-- added the following to include new hardcoded element Transfer license plate number
-- saugupta

   I := POSITION_IN_TABLE('XFR_LICENSE_PLATE_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'XFR_LICENSE_PLATE_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'WMS_LICENSE_PLATE_NUMBERS WLPN1',
            'QRI.XFR_LICENSE_PLATE_NUMBER = WLPN1.LICENSE_PLATE_NUMBER ',
            'XFR_LPN_ID = (SELECT WLPN1.LPN_ID ' ||
                 'FROM WMS_LICENSE_PLATE_NUMBERS WLPN1 '||
                 'WHERE WLPN1.LICENSE_PLATE_NUMBER = QRI.XFR_LICENSE_PLATE_NUMBER'
            || ' AND ROWNUM = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));


   END IF;

   -- validate contract number here
   I := POSITION_IN_TABLE('CONTRACT_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'CONTRACT_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'OKE_K_HEADERS_LOV_V OKEH',
            'QRI.CONTRACT_NUMBER = OKEH.K_NUMBER ',
            'CONTRACT_ID = (SELECT OKEH.K_HEADER_ID ' ||
                 'FROM OKE_K_HEADERS_LOV_V OKEH '||
                 'WHERE OKEH.K_NUMBER = QRI.CONTRACT_NUMBER ' ||
		 'AND ROWNUM = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- validate contract line number here
   I := POSITION_IN_TABLE('CONTRACT_LINE_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'CONTRACT_LINE_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'OKE_K_LINES_FULL_V OKEL',
            'QRI.CONTRACT_LINE_NUMBER = OKEL.LINE_NUMBER ',
            'CONTRACT_LINE_ID = (SELECT OKEL.K_LINE_ID ' ||
                 'FROM OKE_K_LINES_FULL_V OKEL '||
                 'WHERE OKEL.LINE_NUMBER = QRI.CONTRACT_LINE_NUMBER ' ||
		 'AND ROWNUM = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
	    null, 'CONTRACT_NUMBER');
   END IF;

   -- validate deliverable number here
   I := POSITION_IN_TABLE('DELIVERABLE_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'DELIVERABLE_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'OKE_K_DELIVERABLES_VL OKED',
            'QRI.DELIVERABLE_NUMBER = OKED.DELIVERABLE_NUM ',
            'DELIVERABLE_ID = (SELECT OKED.DELIVERABLE_ID ' ||
                 'FROM OKE_K_DELIVERABLES_VL OKED '||
                 'WHERE OKED.DELIVERABLE_NUM = QRI.DELIVERABLE_NUMBER ' ||
		 'AND ROWNUM = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
	    null, 'CONTRACT_LINE_NUMBER', 'CONTRACT_NUMBER');
   END IF;

   -- Added to_char() for QRI.SALES_ORDER because sales order is a
   -- number datatype in QRI and character datatype in qa_sales_orders_lov_v.
   -- Bug 3624361.suramasw.

   I := POSITION_IN_TABLE('SALES_ORDER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'SALES_ORDER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'qa_sales_orders_lov_v SH',
            'to_char(QRI.SALES_ORDER) = SH.ORDER_NUMBER ',
            'SO_HEADER_ID = (select sales_order_id from qa_sales_orders_lov_v'||
            ' where to_char(qri.sales_order) = order_number and rownum = 1) ',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('RMA_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'RMA_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'oe_order_headers SH2',
            'QRI.RMA_NUMBER = SH2.ORDER_NUMBER AND ' ||
                  'SH2.order_category_code in (''RETURN'',''MIXED'')',
            'RMA_HEADER_ID = (SELECT MIN(SH2.HEADER_ID) ' ||
                  'FROM oe_order_headers SH2 ' ||
                  'WHERE SH2.ORDER_NUMBER = QRI.RMA_NUMBER ' ||
                  'AND SH2.order_category_code in (''RETURN'',''MIXED''))',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('QUANTITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'QUANTITY', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('TRANSACTION_DATE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TRANSACTION_DATE', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('DATE_OPENED', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'DATE_OPENED', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('DATE_CLOSED', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'DATE_CLOSED', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('RECEIPT_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      -- Bug 7491455.FP For bug 6800960
      -- changing the query for validation of PO Receipt number to include RMA receipts
      /*VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'RECEIPT_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'RCV_RECEIPTS_ALL_V RRA',
            'QRI.RECEIPT_NUM = RRA.RECEIPT_NUM', NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));*/
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
           'RECEIPT_NUM', X_GROUP_ID, X_USER_ID,
           X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
           X_PROGRAM_ID, '(SELECT DISTINCT RCVSH.RECEIPT_NUM
                           FROM RCV_SHIPMENT_HEADERS RCVSH, PO_VENDORS POV, RCV_TRANSACTIONS RT
                           WHERE RCVSH.RECEIPT_SOURCE_CODE in (''VENDOR'',''CUSTOMER'') AND
                           RCVSH.VENDOR_ID = POV.VENDOR_ID(+) AND
                           RT.SHIPMENT_HEADER_ID = RCVSH.SHIPMENT_HEADER_ID) RRA',
           'QRI.RECEIPT_NUM = RRA.RECEIPT_NUM', NULL,
           CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
           DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
      -- End of bug 7491455.pdube Fri Oct 17 00:14:28 PDT 2008
   END IF;

   -- Bug 3765678. COMP_ITEM is not getting validated along
   -- with ITEM if it is dependent on ITEM. Commenting call
   -- for COMP_ITEM below and moving it to stage 4 after
   -- validation of ITEM has happened. This is done to ensure
   -- ITEM gets validates before COMP_ITEM validation gats called
   -- as we call same proc validate_item() for validation of
   -- both ITEM and COMP_ITEM.
   -- saugupta Fri, 16 Jul 2004 00:01:43 -0700 PDT

   -- I := POSITION_IN_TABLE('COMP_ITEM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   -- IF (I <> -1) THEN
   --   VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
   --         'COMP_ITEM', X_GROUP_ID, X_USER_ID,
   --         X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
   --         X_PROGRAM_ID, NULL, NULL, NULL,
   --         CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
   --         DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   -- END IF;
   -- -*-

   -- Added for the new collection element PARTY. Bug2255344.
   -- kabalakr 14 Mar 02.

   I := POSITION_IN_TABLE('PARTY_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PARTY_NAME', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'HZ_PARTIES HP',
            'QRI.PARTY_NAME = HP.PARTY_NAME AND ' ||
                  'HP.STATUS = ''A'' AND ' ||
                  'PARTY_TYPE IN (''ORGANIZATION'',''PERSON'')',
            'PARTY_ID = (SELECT MIN(HP.PARTY_ID) ' ||
                  'FROM HZ_PARTIES HP ' ||
                  'WHERE HP.PARTY_NAME = QRI.PARTY_NAME ' ||
                  'AND HP.STATUS = ''A'' AND ' ||
                  'PARTY_TYPE IN (''ORGANIZATION'',''PERSON''))',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- End of the changes for the new collection element PARTY.

   -- Added the following two calls to VALIDATE_STEPS for
   -- Asset Group and Asset Activity
   -- To fix the reopened bug 2368381
   -- rkunchal Thu Jul 18 07:23:13 PDT 2002

   --dgupta: Start R12 EAM Integration. Bug 4345492
   I := POSITION_IN_TABLE('ASSET_GROUP', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(
        ENABLED_FLAG_TABLE(I),
           MANDATORY_FLAG_TABLE(I),
           'ASSET_GROUP',
           X_GROUP_ID,
           X_USER_ID,
           X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID,
           X_PROGRAM_APPLICATION_ID,
           X_PROGRAM_ID,
           'mtl_system_items_b_kfv msikfv, mtl_parameters mp',
           'qri.asset_group = msikfv.concatenated_segments' ||
           ' and msikfv.organization_id = mp.organization_id' ||
           ' and msikfv.eam_item_type in (1,3) ' ||
           ' and mp.maint_organization_id = qri.organization_id',
           'qri.asset_group_id = (SELECT msikfv.inventory_item_id ' ||
           ' FROM mtl_system_items_b_kfv msikfv ' ||
           ' WHERE msikfv.concatenated_segments = qri.asset_group ' ||
           ' and rownum=1)', --multiple identical ids may belong to same asset group
           CHAR_ID_TABLE(I),
           CHAR_NAME_TABLE(I),
           DATATYPE_TABLE(I),
           DECIMAL_PRECISION_TABLE(I),
           X_PLAN_ID,
           VALUES_EXIST_FLAG_TABLE(I),
           READ_ONLY_FLAG_TABLE(I));
   END IF;
   --dgupta: End R12 EAM Integration. Bug 4345492

   I := POSITION_IN_TABLE('ASSET_ACTIVITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
		     'ASSET_ACTIVITY',
		     X_GROUP_ID,
		     X_USER_ID,
		     X_LAST_UPDATE_LOGIN,
		     X_REQUEST_ID,
		     X_PROGRAM_APPLICATION_ID,
		     X_PROGRAM_ID,
		     NULL,
		     NULL,
		     NULL,
		     CHAR_ID_TABLE(I),
		     CHAR_NAME_TABLE(I),
		     DATATYPE_TABLE(I),
		     DECIMAL_PRECISION_TABLE(I),
		     X_PLAN_ID,
		     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I),
		     NULL,
		     NULL);
   END IF;
/* R12 DR Integration. Bug 4345489 Start */

   -- Bug 5144730. Corrected validate statements for
   -- Repair  Order  Number and Service  Task  Number
   -- saugupta Mon, 10 Apr 2006 03:31:26 -0700 PDT
   I := POSITION_IN_TABLE('REPAIR_ORDER_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(
        ENABLED_FLAG_TABLE(I),
           MANDATORY_FLAG_TABLE(I),
           'REPAIR_ORDER_NUMBER',
           X_GROUP_ID,
           X_USER_ID,
           X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID,
           X_PROGRAM_APPLICATION_ID,
           X_PROGRAM_ID,
           'csd_repairs CR',
           'qri.repair_order_number = CR.repair_number',
           'repair_line_id = (SELECT cr.repair_line_id
              FROM csd_repairs CR
              WHERE cr.repair_number = qri.repair_order_number
		    AND cr.status not in (''C'', ''H''))',
           CHAR_ID_TABLE(I),
           CHAR_NAME_TABLE(I),
           DATATYPE_TABLE(I),
           DECIMAL_PRECISION_TABLE(I),
           X_PLAN_ID,
           VALUES_EXIST_FLAG_TABLE(I),
           READ_ONLY_FLAG_TABLE(I));
   END IF;


   I := POSITION_IN_TABLE('JTF_TASK_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(
        ENABLED_FLAG_TABLE(I),
           MANDATORY_FLAG_TABLE(I),
           'JTF_TASK_NUMBER',
           X_GROUP_ID,
           X_USER_ID,
           X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID,
           X_PROGRAM_APPLICATION_ID,
           X_PROGRAM_ID,
           'jtf_tasks_vl jtv',
           'qri.jtf_task_number = jtv.task_number',
           'jtf_task_id = (SELECT jtv.task_id
              FROM jtf_tasks_vl jtv
              WHERE jtv.task_number = qri.jtf_task_number)',
           CHAR_ID_TABLE(I),
           CHAR_NAME_TABLE(I),
           DATATYPE_TABLE(I),
           DECIMAL_PRECISION_TABLE(I),
           X_PLAN_ID,
           VALUES_EXIST_FLAG_TABLE(I),
           READ_ONLY_FLAG_TABLE(I));
   END IF;
   /* R12 DR Integration. Bug 4345489 End */
-- added the following to include new hardcoded element followup activity
-- saugupta

   I := POSITION_IN_TABLE('FOLLOWUP_ACTIVITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
		     'FOLLOWUP_ACTIVITY',
		     X_GROUP_ID,
		     X_USER_ID,
		     X_LAST_UPDATE_LOGIN,
		     X_REQUEST_ID,
		     X_PROGRAM_APPLICATION_ID,
		     X_PROGRAM_ID,
		     NULL,
		     NULL,
		     NULL,
		     CHAR_ID_TABLE(I),
		     CHAR_NAME_TABLE(I),
		     DATATYPE_TABLE(I),
		     DECIMAL_PRECISION_TABLE(I),
		     X_PLAN_ID,
		     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I),
		     NULL,
		     NULL);

   END IF;

   -- End of additions for bug 2368381

   --dgupta: Start R12 EAM Integration. Bug 4345492
   I := POSITION_IN_TABLE('ASSET_INSTANCE_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'ASSET_INSTANCE_NUMBER',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'csi_item_instances cii ',
                     'qri.asset_instance_number = cii.instance_number ',
                     'qri.asset_instance_id = (SELECT cii.instance_id FROM ' ||
                        'csi_item_instances cii' ||
		                    ' WHERE cii.instance_number = qri.asset_instance_number)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		                 READ_ONLY_FLAG_TABLE(I));
   END IF;
   --dgupta: End R12 EAM Integration. Bug 4345492

   I := POSITION_IN_TABLE('BILL_REFERENCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'BILL_REFERENCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
                     READ_ONLY_FLAG_TABLE(I),
		     NULL,
                     NULL);
   END IF;


   I := POSITION_IN_TABLE('ROUTING_REFERENCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'ROUTING_REFERENCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I),
                     NULL,
                     NULL);
   END IF;

   --
   -- Included the following calls to VALIDATE_STEPS for
   -- newly added collection elements for ASO project
   -- rkunchal Thu Jul 25 01:43:48 PDT 2002
   --

   -- msg('For item_intance..');
   I := POSITION_IN_TABLE('ITEM_INSTANCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'ITEM_INSTANCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'qa_csi_item_instances cii',
                     'qri.item_instance = cii.instance_number',
                     'csi_instance_id = (SELECT cii.instance_id FROM ' ||
                       'qa_csi_item_instances cii, mtl_system_items_kfv msik ' ||
		       'WHERE cii.inventory_item_id = msik.inventory_item_id AND ' ||
		       'cii.last_vld_organization_id = msik.organization_id AND ' ||
		       'cii.instance_number = qri.item_instance)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- msg('For counter_name...');
   I := POSITION_IN_TABLE('COUNTER_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'COUNTER_NAME',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'cs_counters cc',
                     'qri.counter_name = cc.name',
                     'counter_id = (SELECT cc.counter_id FROM ' ||
                       'cs_counters cc, cs_counter_groups ccg WHERE ' ||
		       'cc.counter_group_id = ccg.counter_group_id AND ' ||
		       'ccg.template_flag = ''N'' AND cc.name = qri.counter_name)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- msg('for maintenance_requirement...');
   I := POSITION_IN_TABLE('MAINTENANCE_REQUIREMENT', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'MAINTENANCE_REQUIREMENT',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'qa_ahl_mr amr',
                     'qri.maintenance_requirement = amr.title AND qri.version_number = amr.version_number',
                     'ahl_mr_id = (SELECT amr.mr_header_id FROM ' ||
                       'qa_ahl_mr amr WHERE qri.maintenance_requirement = amr.title ' ||
		       'AND qri.version_number = amr.version_number)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- msg('For service_request...');
   I := POSITION_IN_TABLE('SERVICE_REQUEST', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'SERVICE_REQUEST',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'cs_incidents ci',
                     'qri.service_request = ci.incident_number',
                     'cs_incident_id = (SELECT ci.incident_id FROM ' ||
                       'cs_incidents ci WHERE ' ||
                       'ci.incident_number = qri.service_request)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I),
		     READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- msg('For rework_job...');
   I := POSITION_IN_TABLE('REWORK_JOB', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'REWORK_JOB',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'wip_discrete_jobs_all_v we2',
                     'qri.rework_job = we2.wip_entity_name AND ' ||
                       'qri.organization_id = we2.organization_id',
                     'wip_rework_id = (SELECT we2.wip_entity_id FROM ' ||
                       'wip_discrete_jobs_all_v we2 WHERE ' ||
                       'qri.rework_job = we2.wip_entity_name ' ||
                       'AND qri.organization_id = we2.organization_id)',
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   -- msg('for Disposition_source...');
   I := POSITION_IN_TABLE('DISPOSITION_SOURCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'DISPOSITION_SOURCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   -- msg('For disposition...');
   I := POSITION_IN_TABLE('DISPOSITION', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'DISPOSITION',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   -- msg('For disposition_action...');
   I := POSITION_IN_TABLE('DISPOSITION_ACTION', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'DISPOSITION_ACTION',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   -- msg('for Disposition_status...');
   I := POSITION_IN_TABLE('DISPOSITION_STATUS', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'DISPOSITION_STATUS',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   --
   -- End of inclusions for ASO project
   -- rkunchal Thu Jul 25 01:43:48 PDT 2002
   --

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


   I := POSITION_IN_TABLE('NONCONFORMANCE_SOURCE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORMANCE_SOURCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('NONCONFORM_SEVERITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORM_SEVERITY',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('NONCONFORM_PRIORITY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORM_PRIORITY',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('NONCONFORMANCE_TYPE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORMANCE_TYPE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('NONCONFORMANCE_STATUS', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORMANCE_STATUS',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   --
   -- Bug 4425863
   -- Added the lookup for the element Nonconformance_Code so that if it is
   -- present in the plan then its validated
   -- ntungare Fri Dec 16 03:08:08 PST 2005
   --
   I := POSITION_IN_TABLE('NONCONFORMANCE_CODE', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'NONCONFORMANCE_CODE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

-- End of inclusions for NCM Hardcode Elements.

   -- anagarwa Thu Nov 14 13:31:42 PST 2002
   -- Start inclusions for CAR Hardcoded Elements

   I := POSITION_IN_TABLE('REQUEST_SOURCE', DEVELOPER_NAME_TABLE, NUM_ELEMS
);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'REQUEST_SOURCE',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('REQUEST_PRIORITY', DEVELOPER_NAME_TABLE, NUM_ELEMS
);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'REQUEST_PRIORITY',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('REQUEST_SEVERITY', DEVELOPER_NAME_TABLE, NUM_ELEMS
);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'REQUEST_SEVERITY',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('REQUEST_STATUS', DEVELOPER_NAME_TABLE, NUM_ELEMS
);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'REQUEST_STATUS',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('ECO_NAME', DEVELOPER_NAME_TABLE, NUM_ELEMS
);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'ECO_NAME',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     NULL,
                     NULL,
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;

-- End of inclusions for CAR Hardcode Elements.


   FOR J IN 1..QLTNINRB.RES_CHAR_COLUMNS LOOP
      I := POSITION_IN_TABLE('CHARACTER' || TO_CHAR(J),
            RESULT_COLUMN_NAME_TABLE, NUM_ELEMS);
      IF (I <> -1) THEN
         IF (NVL(DEVELOPER_NAME_TABLE(I), 'X')
               NOT IN ('FROM_INTRAOPERATION_STEP',
               'TO_INTRAOPERATION_STEP','Bom_Revision','routing_revision')) THEN
           -- Bug 7716875.Added this code to validate so line number
 	   -- on the basis of the SO Number
 	   -- pdube Mon Apr 13 03:25:19 PDT 2009
 	   IF NVL(DEVELOPER_NAME_TABLE(I), 'X') = 'ORDER_LINE' THEN
 	    VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
 	              MANDATORY_FLAG_TABLE(I),
 	              'CHARACTER'|| TO_CHAR(J),
 	               X_GROUP_ID,
 	               X_USER_ID,
 	               X_LAST_UPDATE_LOGIN,
 	               X_REQUEST_ID,
 	               X_PROGRAM_APPLICATION_ID,
 	               X_PROGRAM_ID,
 	               'oe_order_lines_all oel, oe_order_headers_all oeha',
 	               ' oel.header_id = oeha.header_id and '||
 	               ' oeha.order_number = qri.sales_order and '||
 	               ' oel.line_number = nvl(qri.CHARACTER'|| TO_CHAR(J)||',-1) ',
 	               NULL,
 	               CHAR_ID_TABLE(I),
 	               CHAR_NAME_TABLE(I),
 	               DATATYPE_TABLE(I),
 	               DECIMAL_PRECISION_TABLE(I),
 	               X_PLAN_ID,
 	               VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
 	               NULL);
           --
           -- Bug 8542216
           -- Added handling for RMA Line Number to link its value with RMA Number
           -- to improve performance and avoid full table scan on oe_order_headers_all.
           -- skolluku
           --
           ELSIF NVL(DEVELOPER_NAME_TABLE(I), 'X') = 'RMA_LINE_NUMBER' THEN
             VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                        MANDATORY_FLAG_TABLE(I),
                        'CHARACTER'|| TO_CHAR(J),
                         X_GROUP_ID,
                         X_USER_ID,
                         X_LAST_UPDATE_LOGIN,
                         X_REQUEST_ID,
                         X_PROGRAM_APPLICATION_ID,
                         X_PROGRAM_ID,
                         ' oe_order_lines oel, so_order_types sot, oe_order_headers sh',
                         ' sh.order_type_id = sot.order_type_id and '||
                         ' oel.header_id    = sh.header_id and '||
                         ' oel.line_category_code IN (''RETURN'', ''MIXED'') and '||
                         ' sh.order_number = qri.rma_number and '||
                         ' oel.line_number = nvl(qri.CHARACTER'|| TO_CHAR(J)||',-1)',
                         NULL,
                         CHAR_ID_TABLE(I),
                         CHAR_NAME_TABLE(I),
                         DATATYPE_TABLE(I),
                         DECIMAL_PRECISION_TABLE(I),
                         X_PLAN_ID,
                         VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                         NULL);
           ELSE
            VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
                  'CHARACTER' || TO_CHAR(J), X_GROUP_ID, X_USER_ID,
                  X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
                  X_PROGRAM_ID, NULL, NULL, NULL,
                  CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
                  DECIMAL_PRECISION_TABLE(I), X_PLAN_ID,
                  VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                  SQL_VALIDATION_STRING_TABLE(I));
           END IF; -- End of if for order_line. Bug 7716875
	 END IF;
      END IF;
   END LOOP;

   -- For Sequence Project. Call Derive_sequence for all the enabled
   -- Sequence Collection elements in the plan.
   -- kabalakr 15 JAN 2002.

   FOR J IN 1..QA_SEQUENCE_API.MAX_SEQUENCE LOOP
      I := POSITION_IN_TABLE('SEQUENCE'||to_char(j),
            RESULT_COLUMN_NAME_TABLE, NUM_ELEMS);
      IF (I <> -1) THEN
         -- Bug 3069404 ksoh Tue Mar 16 10:43:36 PST 2004
         -- sequence element is really read-only
         -- should check if the user is trying to import into it
         VALIDATE_SEQUENCE(
            P_COL_NAME => 'SEQUENCE'||to_char(j),
            P_GROUP_ID => X_GROUP_ID,
            P_USER_ID => X_USER_ID,
            P_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
            P_REQUEST_ID => X_REQUEST_ID,
            P_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
            P_PROGRAM_ID => X_PROGRAM_ID,
            P_CHAR_NAME => CHAR_NAME_TABLE(I),
	        P_TXN_TYPE => TYPE_OF_TXN);
         IF(ENABLED_FLAG_TABLE(I) = 1) THEN
            DERIVE_SEQUENCE(X_GROUP_ID, X_USER_ID, X_LAST_UPDATE_LOGIN, X_REQUEST_ID,
                    X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, 'SEQUENCE'||to_char(J),
                          CHAR_ID_TABLE(I), TYPE_OF_TXN);
         END IF;
      END IF;
   END LOOP;

   -- End of Sequence Project Changes.



   -- stage 4 -----------------------------------------------------------------
   --
   -- validate ...
   ----------------------------------------------------------------------------

   -- item is a special case because it may or may not have a parent element,
   -- depending on whether production line is on the plan.  earlier, when
   -- we checked to see if production line was on the plan before validating
   -- it, we set the item_parent variable to 'production_line'.  if production
   -- line wasn't on the plan, item_parent will be null.  another thing about
   -- item...after item is validated, if production line is also on the plan,
   -- then the validate_steps routine will derive wip_entity_id.

   I := POSITION_IN_TABLE('ITEM', DEVELOPER_NAME_TABLE, NUM_ELEMS);

   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'ITEM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, ITEM_PARENT);
   END IF;

   -- Bug 3765678. COMP_ITEM is not getting validated along
   -- with ITEM if it is dependent on ITEM. Moved call for
   -- VALIDATE_STEPS() for COMP_ITEM after validation of
   -- ITEM happens. This is done to ensure that COMP_ITEM
   -- gets properly validated if dependent on ITEM.
   -- saugupta Fri, 16 Jul 2004 00:07:27 -0700 PDT

   -- Bug 3781489. User was able to import values to COMP_ITEM even if parent column ITEM
   -- is empty. Passing 'ITEM' as a PARENT_COL and ITEM_PARENT as GRAND_PARENT_COL parameter
   -- to VALIDATE_STEPS call. Parent column dependency is taken care inside VALIDATE_STEPS procedure.
   -- srhariha. Thu Jul 22 03:05:03 PDT 2004

   I := POSITION_IN_TABLE('COMP_ITEM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_ITEM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            null,'ITEM',ITEM_PARENT);
   END IF;
   -- -*-

   I := POSITION_IN_TABLE('PO_LINE_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      --
      -- Bug 4760817.
      -- Added 'QRI.PO_LINE_NUM IS NOT NULL' for the where clause column below
      -- so that the unique index PO_LINES_U2 in table PO_LINES_ALL is used
      -- when importing results for the collection element 'PO Line Number
      -- ntungare Wed Dec 21 05:12:28 PST 2005
      --
      --
      -- bug 9652549 CLM changes
      --
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PO_LINE_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, ' PO_LINES_VAL_TRX_V PLVV',
            'QRI.PO_LINE_NUM = PLVV.LINE_NUM AND ' ||
                  'QRI.PO_HEADER_ID = PLVV.PO_HEADER_ID AND ' ||
                   'QRI.PO_LINE_NUM IS NOT NULL',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'PO_NUMBER');
   END IF;

   I := POSITION_IN_TABLE('COMP_UOM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_UOM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_ITEM_UOMS_VIEW MIUV2',
            'QRI.COMP_UOM = MIUV2.UOM_CODE AND ' ||
                  'QRI.COMP_ITEM_ID = MIUV2.INVENTORY_ITEM_ID AND ' ||
                  'QRI.ORGANIZATION_ID = MIUV2.ORGANIZATION_ID',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_ITEM');
   END IF;

   I := POSITION_IN_TABLE('COMP_REVISION', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_REVISION', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_ITEM_REVISIONS MIR',
            'QRI.COMP_REVISION = MIR.REVISION AND ' ||
                  'QRI.COMP_ITEM_ID = MIR.INVENTORY_ITEM_ID AND ' ||
                  'QRI.ORGANIZATION_ID = MIR.ORGANIZATION_ID',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_ITEM');
   END IF;

   I := POSITION_IN_TABLE('COMP_SUBINVENTORY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_SUBINVENTORY', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_ITEM');
   END IF;

   I := POSITION_IN_TABLE('COMP_LOT_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_LOT_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL, CHAR_ID_TABLE(I),
            CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_ITEM');
   END IF;

   I := POSITION_IN_TABLE('COMP_SERIAL_NUMBER', DEVELOPER_NAME_TABLE,
         NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_SERIAL_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL, CHAR_ID_TABLE(I),
            CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_ITEM');
   END IF;


   -- stage 5 -----------------------------------------------------------------
   --
   -- validate things dependent on job or prodline/item
   ----------------------------------------------------------------------------

   -- !! what exactly are the parent and grandparent columns for op seqs?

   I := POSITION_IN_TABLE('FROM_OP_SEQ_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'FROM_OP_SEQ_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'WIP_OPERATIONS_ALL_V WOAV',
            'WOAV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                  'AND WOAV.WIP_ENTITY_ID = QRI.WIP_ENTITY_ID ' ||
                  'AND WOAV.OPERATION_SEQ_NUM = QRI.FROM_OP_SEQ_NUM ' ||
                  'AND (QRI.LINE_ID IS NULL OR ' ||
                     'WOAV.REPETITIVE_SCHEDULE_ID = ' ||
                     '(SELECT REPETITIVE_SCHEDULE_ID ' ||
                     'FROM WIP_FIRST_OPEN_SCHEDULE_V ' ||
                     'WHERE ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                     'AND WIP_ENTITY_ID = QRI.WIP_ENTITY_ID ' ||
                     'AND LINE_ID = QRI.LINE_ID))',
            NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'JOB_NAME', ITEM_PARENT);
   END IF;

   I := POSITION_IN_TABLE('TO_OP_SEQ_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TO_OP_SEQ_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'WIP_OPERATIONS_ALL_V WOAV',
            'WOAV.ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                  'AND WOAV.WIP_ENTITY_ID = QRI.WIP_ENTITY_ID ' ||
                  'AND WOAV.OPERATION_SEQ_NUM = QRI.TO_OP_SEQ_NUM ' ||
                  'AND (QRI.LINE_ID IS NULL OR ' ||
                     'WOAV.REPETITIVE_SCHEDULE_ID = ' ||
                     '(SELECT REPETITIVE_SCHEDULE_ID ' ||
                     'FROM WIP_FIRST_OPEN_SCHEDULE_V ' ||
                     'WHERE ORGANIZATION_ID = QRI.ORGANIZATION_ID ' ||
                     'AND WIP_ENTITY_ID = QRI.WIP_ENTITY_ID ' ||
                     'AND LINE_ID = QRI.LINE_ID))',
            NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'JOB_NAME', ITEM_PARENT);
   END IF;

   I := POSITION_IN_TABLE('UOM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'UOM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_ITEM_UOMS_VIEW MIUV2',
            'QRI.UOM = MIUV2.UOM_CODE AND ' ||
                  'QRI.ITEM_ID = MIUV2.INVENTORY_ITEM_ID AND ' ||
                  'QRI.ORGANIZATION_ID = MIUV2.ORGANIZATION_ID',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;

   I := POSITION_IN_TABLE('REVISION', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'REVISION', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_ITEM_REVISIONS MIR',
            'QRI.REVISION = MIR.REVISION AND ' ||
                  'QRI.ITEM_ID = MIR.INVENTORY_ITEM_ID AND ' ||
                  'QRI.ORGANIZATION_ID = MIR.ORGANIZATION_ID',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;

   I := POSITION_IN_TABLE('SUBINVENTORY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'SUBINVENTORY', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

   I := POSITION_IN_TABLE('TO_SUBINVENTORY', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TO_SUBINVENTORY', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;

-- End of inclusions for NCM Hardcode Elements.

   I := POSITION_IN_TABLE('LOT_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'LOT_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL, CHAR_ID_TABLE(I),
            CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;

   -- enter results checks to see whether last digit of a serial number is
   -- numeric.  we don't do this but probably should.

   I := POSITION_IN_TABLE('SERIAL_NUMBER', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'SERIAL_NUMBER', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL, CHAR_ID_TABLE(I),
            CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'ITEM', ITEM_PARENT);
   END IF;


-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


   I := POSITION_IN_TABLE('LOT_STATUS', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'LOT_STATUS', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_MATERIAL_STATUSES MMS, MTL_LOT_NUMBERS MLN',
            'MMS.STATUS_CODE = QRI.LOT_STATUS AND MMS.ENABLED_FLAG = 1 '||
            ' AND MLN.LOT_NUMBER = QRI.LOT_NUMBER AND MLN.STATUS_ID = MMS.STATUS_ID',
            'LOT_STATUS_ID = (SELECT MMS.STATUS_ID '||
            ' FROM MTL_LOT_NUMBERS MLN,MTL_MATERIAL_STATUSES MMS '||
            ' WHERE MLN.STATUS_ID = MMS.STATUS_ID '||
            ' AND MLN.LOT_NUMBER = QRI.LOT_NUMBER AND MMS.ENABLED_FLAG = 1 '||
            ' AND MLN.INVENTORY_ITEM_ID = QRI.ITEM_ID )',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('SERIAL_STATUS', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'SERIAL_STATUS', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_MATERIAL_STATUSES MMS, MTL_SERIAL_NUMBERS MSN',
            'MMS.STATUS_CODE = QRI.SERIAL_STATUS AND MMS.ENABLED_FLAG = 1 '||
            ' AND MSN.SERIAL_NUMBER = QRI.SERIAL_NUMBER AND MSN.STATUS_ID = MMS.STATUS_ID',
            'SERIAL_STATUS_ID = (SELECT MMS.STATUS_ID '||
            ' FROM MTL_SERIAL_NUMBERS MSN,MTL_MATERIAL_STATUSES MMS '||
            ' WHERE MSN.STATUS_ID = MMS.STATUS_ID '||
            ' AND MSN.SERIAL_NUMBER = QRI.SERIAL_NUMBER AND MMS.ENABLED_FLAG = 1 '||
            ' AND MSN.INVENTORY_ITEM_ID = QRI.ITEM_ID )',
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

-- End of inclusions for NCM Hardcode Elements.


   -- !!! here we will validate comp_locator
   -- !!!

   I := POSITION_IN_TABLE('COMP_LOCATOR', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'COMP_LOCATOR', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'COMP_SUBINVENTORY', 'COMP_ITEM');
   END IF;

   I := POSITION_IN_TABLE('PO_SHIPMENT_NUM', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      --
      -- bug 9652549 CLM changes
      --
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'PO_SHIPMENT_NUM', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'PO_SHIPMENTS_ALL_V PSAV',
            'QRI.PO_SHIPMENT_NUM = PSAV.SHIPMENT_NUM AND ' ||
                  'PSAV.PO_LINE_ID = (SELECT PO_LINE_ID FROM ' ||
                  'PO_LINES_VAL_TRX_V WHERE LINE_NUM = QRI.PO_LINE_NUM ' ||
                  'AND PO_HEADER_ID = QRI.PO_HEADER_ID)',
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'PO_LINE_NUM', 'PO_NUMBER');
   END IF;

   --
   -- See Bug 2588213
   -- To support the element Maintenance Op Seq Number
   -- to be used along with Maintenance Workorder
   -- rkunchal Mon Sep 23 23:46:28 PDT 2002
   -- To validate Maintenance Op Seq which is dependent on Maintenance Workorder
   --
   I := POSITION_IN_TABLE('MAINTENANCE_OP_SEQ', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I),
                     MANDATORY_FLAG_TABLE(I),
                     'MAINTENANCE_OP_SEQ',
                     X_GROUP_ID,
                     X_USER_ID,
                     X_LAST_UPDATE_LOGIN,
                     X_REQUEST_ID,
                     X_PROGRAM_APPLICATION_ID,
                     X_PROGRAM_ID,
                     'WIP_OPERATIONS_ALL_V WOAV',
                     'woav.organization_id = qri.organization_id AND ' ||
                       'woav.wip_entity_id = qri.work_order_id AND ' ||
                       'woav.operation_seq_num = qri.maintenance_op_seq',
                     NULL,
                     CHAR_ID_TABLE(I),
                     CHAR_NAME_TABLE(I),
                     DATATYPE_TABLE(I),
                     DECIMAL_PRECISION_TABLE(I),
                     X_PLAN_ID,
                     VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
                     SQL_VALIDATION_STRING_TABLE(I));
   END IF;
   --
   -- End of inclusions for Bug 2588213
   --

   -- stage 6 -----------------------------------------------------------------
   --
   -- validate locator and the characterx columns
   ----------------------------------------------------------------------------

   -- !!! validate locator here
   -- !!!

   I := POSITION_IN_TABLE('LOCATOR', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'LOCATOR', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'SUBINVENTORY', 'ITEM', ITEM_PARENT);
   END IF;

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.


   I := POSITION_IN_TABLE('TO_LOCATOR', DEVELOPER_NAME_TABLE, NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            'TO_LOCATOR', X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL,
            NULL, CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            NULL, 'TO_SUBINVENTORY', 'ITEM', ITEM_PARENT);
   END IF;

-- End of inclusions for NCM Hardcode Elements.

   I := POSITION_IN_TABLE('FROM_INTRAOPERATION_STEP', DEVELOPER_NAME_TABLE,
         NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            RESULT_COLUMN_NAME_TABLE(I), X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            SQL_VALIDATION_STRING_TABLE(I),
            'FROM_OP_SEQ_NUM', 'JOB_NAME', ITEM_PARENT);
   END IF;

   I := POSITION_IN_TABLE('TO_INTRAOPERATION_STEP', DEVELOPER_NAME_TABLE,
         NUM_ELEMS);
   IF (I <> -1) THEN
      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            RESULT_COLUMN_NAME_TABLE(I), X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, NULL, NULL, NULL,
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),
            SQL_VALIDATION_STRING_TABLE(I),
            'TO_OP_SEQ_NUM', 'JOB_NAME', ITEM_PARENT);
   END IF;


   I := POSITION_IN_TABLE('Bom_Revision', DEVELOPER_NAME_TABLE, NUM_ELEMS);

   IF (I <> -1) THEN

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            RESULT_COLUMN_NAME_TABLE(I), X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_ITEM_REVISIONS MIR',
            'MIR.REVISION = QRI.'||RESULT_COLUMN_NAME_TABLE(I)||
            ' AND MIR.INVENTORY_ITEM_ID = QRI.BILL_REFERENCE_ID'||
            ' AND MIR.ORGANIZATION_ID = QRI.ORGANIZATION_ID',
            RESULT_COLUMN_NAME_TABLE(I)|| '= QRI.'||RESULT_COLUMN_NAME_TABLE(I),
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I));
   END IF;

   I := POSITION_IN_TABLE('routing_revision', DEVELOPER_NAME_TABLE, NUM_ELEMS);

   IF (I <> -1) THEN

      VALIDATE_STEPS(ENABLED_FLAG_TABLE(I), MANDATORY_FLAG_TABLE(I),
            RESULT_COLUMN_NAME_TABLE(I), X_GROUP_ID, X_USER_ID,
            X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_APPLICATION_ID,
            X_PROGRAM_ID, 'MTL_RTG_ITEM_REVISIONS MRIR',
            'MRIR.PROCESS_REVISION = QRI.'||RESULT_COLUMN_NAME_TABLE(I)||
            ' AND MRIR.INVENTORY_ITEM_ID = QRI.ROUTING_REFERENCE_ID'||
            ' AND MRIR.ORGANIZATION_ID = QRI.ORGANIZATION_ID',
            RESULT_COLUMN_NAME_TABLE(I)|| '= QRI.'||RESULT_COLUMN_NAME_TABLE(I),
            CHAR_ID_TABLE(I), CHAR_NAME_TABLE(I), DATATYPE_TABLE(I),
            DECIMAL_PRECISION_TABLE(I), X_PLAN_ID, VALUES_EXIST_FLAG_TABLE(I), READ_ONLY_FLAG_TABLE(I),NULL);
   END IF;



   -- stage 7 -----------------------------------------------------------------
   --
   -- done with validation
   -- set the process status to 3 (error) for all rows that had errors
   ----------------------------------------------------------------------------

   -- final step: set error status for all rows that had errors
   SET_ERROR_STATUS(X_GROUP_ID, X_USER_ID, X_REQUEST_ID,
         X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID, X_LAST_UPDATE_LOGIN);

   RETURN TRUE;
END VALIDATE;


-- Adding update capabilities.  For each column of QA_RESULTS that will be
-- updated, a record is inserted into QA_RESULTS_UPDATE_HISTORY.  Provides an
-- audit trail.
PROCEDURE POPULATE_HISTORY_TABLE(X_GROUP_ID NUMBER,
				 X_TXN_HEADER_ID NUMBER,
				 STMT_OF_ROWIDS VARCHAR2,
				 X_USER_ID NUMBER,
				 X_LAST_UPDATE_LOGIN NUMBER,
				 X_REQUEST_ID NUMBER,
				 X_PROGRAM_APPLICATION_ID NUMBER,
				 X_PROGRAM_ID NUMBER) IS
  X_PLAN_ID				NUMBER;
  NUM_COLS				BINARY_INTEGER;
  J						BINARY_INTEGER;
  RESULT_COLUMN_ID_TABLE		NUMBER_TABLE;
  RESULT_COLUMN_NAME_TABLE	CHAR30_TABLE;
  SQL_STATEMENT			VARCHAR2(10000);

    -- Bug 3765730.Added the datatype table which will be used in building the SQL.
    -- srhariha. Wed Jul 14 22:36:50 PDT 2004.
  DATATYPE_TABLE NUMBER_TABLE;

    -- Bug 4270911. CU2 SQL Literal fix.
    -- New variables;
    -- srhariha. Fri Apr 15 02:42:07 PDT 2005.

  L_ROWID ROWID;


BEGIN
  SELECT MAX(PLAN_ID)
  INTO X_PLAN_ID
  FROM QA_RESULTS_INTERFACE QRI
  WHERE QRI.GROUP_ID = X_GROUP_ID
  AND PROCESS_STATUS = 2;

  -- if no rows were successfully validated, no need to continue....
  IF (X_PLAN_ID IS NULL)
    THEN RETURN;
  END IF;

  -- get result column ids corresponding to elements of the plan....
  NUM_COLS := 0;

    -- Bug 3765730.Populating datatype table which will be used in building the SQL.
    -- srhariha. Wed Jul 14 22:36:50 PDT 2004.

  -- Bug 4958776. SQL Repository Fix SQL ID: 15009199
  -- replacing view with base tables
  FOR RESREC IN (SELECT QPC.CHAR_ID, QPC.RESULT_COLUMN_NAME, QC.DATATYPE
                 FROM QA_PLAN_CHARS QPC, qa_chars qc
                 WHERE QPC.PLAN_ID = X_PLAN_ID
                 AND QC.CHAR_ID = QPC.CHAR_ID ) LOOP
    NUM_COLS := NUM_COLS + 1;
    RESULT_COLUMN_ID_TABLE(NUM_COLS) := RESREC.CHAR_ID;
    RESULT_COLUMN_NAME_TABLE(NUM_COLS) := RESREC.RESULT_COLUMN_NAME;
    DATATYPE_TABLE(NUM_COLS) := RESREC.DATATYPE;
  END LOOP;

  -- Bug 3136107.
  -- SQL Bind project. Code modified to use bind variables instead of literals
  -- Same as the fix done for Bug 3079312.suramasw.

  -- Added the NVL condition for QR.RESULT_COLUMN_NAME_TABLE.
  -- Comparing NULL values should have NVL else the query fails to insert record
  -- into qa_results_update_history.This happens when you enter a record through
  -- EQR and then update the record through collection import.
  -- Bug 3273447. suramasw

  -- Bug 3765730.Updating functionality was not working if the plan has hardcoded date element.
  -- In the SQL_STATEMENT we were replacing null with -99999,which worked for NUMBER and VARCHAR2
  -- but was giving exception for DATE type.
  -- To fix the issue, added a decode inside NVL based on DATATYPE.Also to avoid hardcoding effect
  -- (Easter eggs) added similar condition but with different value inside NVL.Also GSCC wont
  -- allow hardcoding dates,so using SYSDATE and SYSDATE+1.
  -- srhariha. Wed Jul 14 22:36:50 PDT 2004.

  -- Bug 4270911. CU2 SQL Literal fix. TD #27-28
  -- Replaced NVL comparison with is null comparison.
  -- Rewrote the 3765730 fix.
  -- Using bind variable for STMT_OF_ROWID with assumption that QA open interface allows
  -- update of only sinlge row.
  -- srhariha. Fri Apr 15 02:42:07 PDT 2005.

  L_ROWID := substr(stmt_of_rowids,3,length(stmt_of_rowids)-4);


  FOR J IN 1..NUM_COLS LOOP
    SQL_STATEMENT := 'INSERT INTO QA_RESULTS_UPDATE_HISTORY ' ||
			'(OCCURRENCE,UPDATE_ID,CREATION_DATE,CREATED_BY,' ||
			' LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,' ||
			' TXN_HEADER_ID,CHAR_ID,OLD_VALUE,REQUEST_ID,' ||
			' PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE) ' ||
		     'SELECT QR.OCCURRENCE, QA_RESULTS_UPDATE_HISTORY_S.nextval, ' ||
			'sysdate, :USER_ID, sysdate, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
                        ':TXN_HEADER_ID, :RESULT_COLUMN_ID' ||
			', QR.' || RESULT_COLUMN_NAME_TABLE(J) || ', ' ||
                        ':REQUEST_ID, :PROGRAM_APPLICATION_ID, ' ||
                        ':PROGRAM_ID, sysdate ' ||
		     'FROM QA_RESULTS QR, ' ||
		     'QA_RESULTS_INTERFACE QRI ' ||
		     'WHERE QR.ROWID = :BIND_ROWID ' ||
		     ' AND QRI.GROUP_ID = :GROUP_ID ' ||
                   '  AND (QR.' || RESULT_COLUMN_NAME_TABLE(J) || ' <> QRI.' || RESULT_COLUMN_NAME_TABLE(J)||
                     '   OR (QR.'  || RESULT_COLUMN_NAME_TABLE(J)|| ' IS NOT NULL AND ' ||
                            'QRI.' || RESULT_COLUMN_NAME_TABLE(J)|| ' IS NULL )' ||
                     '   OR (QRI.'  || RESULT_COLUMN_NAME_TABLE(J)|| ' IS NOT NULL AND ' ||
                            'QR.' || RESULT_COLUMN_NAME_TABLE(J)|| ' IS NULL ))';





      EXECUTE IMMEDIATE SQL_STATEMENT USING X_USER_ID,
                                            X_USER_ID,
                                            X_LAST_UPDATE_LOGIN,
                                            X_TXN_HEADER_ID,
                                            RESULT_COLUMN_ID_TABLE(J),
                                            X_REQUEST_ID,
                                            X_PROGRAM_APPLICATION_ID,
                                            X_PROGRAM_ID,
                                            L_ROWID,
                                            X_GROUP_ID;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
  END LOOP;

END POPULATE_HISTORY_TABLE;


-- Adding update capabilities.  This procedure does the actual updates to
-- QA_RESULTS.
PROCEDURE UPDATE_VALID_ROWS(X_GROUP_ID 			NUMBER,
			    		X_USER_ID 			NUMBER,
			    		X_LAST_UPDATE_LOGIN		NUMBER,
			    		X_TXN_HEADER_ID		NUMBER,
			    		X_REQUEST_ID			NUMBER,
			    		X_PROGRAM_APPLICATION_ID	NUMBER,
			    		X_PROGRAM_ID			NUMBER,
			    		STMT_OF_ROWIDS			VARCHAR2) IS
  X_PLAN_ID				NUMBER;
  X_TRANSACTION_INTERFACE_ID	NUMBER;
  I						BINARY_INTEGER;
  NUM_ELEMS				NUMBER;
  COLUMNS_TABLE			CHAR30_TABLE;
  COLUMN_LIST				VARCHAR2(10000);
  VALUE_LIST				VARCHAR2(10000);
  SQL_STATEMENT			VARCHAR2(20000);
  DUMMY				NUMBER;

  -- For Bug2548710.
  K                    NUMBER := 0;
  NUM_ROWS             NUMBER;
  X_INTERFACE_ID       NUMBER;
  SOURCE_CURSOR        INTEGER;
  IGNORE               INTEGER;
  ERRMSG               VARCHAR2(30);
  ID_FIELD             VARCHAR2(30);
  INTERFACE_ID_TABLE   NUMBER_TABLE;

  -- Bug 3788305.suramasw.
  l_rowid ROWID;

BEGIN
  I := 0;

  SELECT MAX(TRANSACTION_INTERFACE_ID)
  INTO X_TRANSACTION_INTERFACE_ID
  FROM QA_RESULTS_INTERFACE QRI
  WHERE QRI.GROUP_ID = X_GROUP_ID
  AND PROCESS_STATUS = 2;

  SELECT MAX(PLAN_ID)
  INTO X_PLAN_ID
  FROM QA_RESULTS_INTERFACE QRI
  WHERE QRI.TRANSACTION_INTERFACE_ID = X_TRANSACTION_INTERFACE_ID
  AND PROCESS_STATUS = 2;

  -- if no rows were successfully validated, no need to continue....
  IF (X_PLAN_ID IS NULL)
    THEN RETURN;
  END IF;

  -- Get all the interface_ids for this group_id onto a struct.
  -- We need to update the SEQUENCExx columns before we update to
  -- QA_RESULTS. For more info see Bug 2548710.

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

  SQL_STATEMENT :=
         'SELECT TRANSACTION_INTERFACE_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
                  'QRI.TRANSACTION_INTERFACE_ID )';

  SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

  DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);

  DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
  IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

  LOOP
     IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
        K := K + 1;
        DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
        INTERFACE_ID_TABLE(K) := X_INTERFACE_ID;
     ELSE
        EXIT;
     END IF;
  END LOOP;
  NUM_ROWS := K ;


  -- Before we update, make sure that all the variables are initialized.
  -- Exceptions can rise, if all its not done.

  IF (G_INIT_SEQ_TAB = 1) THEN
     -- Call local initialization procedure. Bug 2548710 rponnusa Mon Nov 18 03:49:15 PST 2002

     INIT_SEQ_TABLE(NUM_ROWS);
  END IF;

  -- Use the bulk binding option to update all the SEQUENCExx columns
  -- together. Fetch the values for all sequence columns from the
  -- global variables. For more info see bug 2548710.

  FORALL J IN 1..NUM_ROWS
      UPDATE QA_RESULTS_INTERFACE QRI
      SET    SEQUENCE1  = G_SEQ_TAB1(J),
             SEQUENCE2  = G_SEQ_TAB2(J),
             SEQUENCE3  = G_SEQ_TAB3(J),
             SEQUENCE4  = G_SEQ_TAB4(J),
             SEQUENCE5  = G_SEQ_TAB5(J),
             SEQUENCE6  = G_SEQ_TAB6(J),
             SEQUENCE7  = G_SEQ_TAB7(J),
             SEQUENCE8  = G_SEQ_TAB8(J),
             SEQUENCE9  = G_SEQ_TAB9(J),
             SEQUENCE10 = G_SEQ_TAB10(J),
             SEQUENCE11 = G_SEQ_TAB11(J),
             SEQUENCE12 = G_SEQ_TAB12(J),
             SEQUENCE13 = G_SEQ_TAB13(J),
             SEQUENCE14 = G_SEQ_TAB14(J),
             SEQUENCE15 = G_SEQ_TAB15(J)
      WHERE  QRI.GROUP_ID = X_GROUP_ID
      AND    QRI.TRANSACTION_INTERFACE_ID = INTERFACE_ID_TABLE(J)
      AND    NOT EXISTS
                (SELECT 'X'
                 FROM QA_INTERFACE_ERRORS QIE
                 WHERE QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID);

  -- End of changes for bug 2548710.

  FOR COLUMN_NAMES_REC IN (SELECT QPC.RESULT_COLUMN_NAME
			   FROM QA_PLAN_CHARS QPC,
			   QA_CHARS QC
			   WHERE QPC.PLAN_ID = X_PLAN_ID
			   AND QPC.CHAR_ID = QC.CHAR_ID) LOOP
    I := I + 1;
    COLUMNS_TABLE(I) := COLUMN_NAMES_REC.RESULT_COLUMN_NAME;
  END LOOP;
  NUM_ELEMS := I;

  -- to build our update statement, we first need to construct a column list,
  -- value list, and row list.  These are all texts we will use to construct
  -- the update statement.

   --
   -- Modified the COLUMN_LIST and VALUE_LIST to include
   -- new columns added for ASO project.
   -- rkunchal Thu Jul 25 01:43:48 PDT 2002
   --
  -- msg('In Update_Valid_Rows...');
  COLUMN_LIST := 'LAST_UPDATE_DATE, QA_LAST_UPDATE_DATE, ' ||
	      'LAST_UPDATED_BY, QA_LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ' ||
		 'TXN_HEADER_ID, REQUEST_ID, ' ||
		 'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,' ||
                 'MTI_TRANSACTION_HEADER_ID,' ||
                 'MTI_TRANSACTION_INTERFACE_ID,' ||
                 'MMT_TRANSACTION_ID,' ||
                 'WJSI_GROUP_ID,' ||
                 'WMTI_GROUP_ID,' ||
                 'WMT_TRANSACTION_ID,' ||
                 'RTI_INTERFACE_TRANSACTION_ID '
		 ;

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   -- QA_LAST_UPDATED_BY should take the value from qri.QA_LAST_UPDATED_BY because
   -- the record might be updated by different user than the user who submitted the
   -- concurrent request. qri.QA_LAST_UPDATED_BY will store the value of the user
   -- who updated the record.
   -- Bug 3663648.suramasw.

  VALUE_LIST := 'SYSDATE, SYSDATE, :USER_ID, ' ||
                'NVL(qri.QA_LAST_UPDATED_BY,qr.QA_LAST_UPDATED_BY),' ||
                ':LAST_UPDATE_LOGIN, :TXN_HEADER_ID, :REQUEST_ID, :PROGRAM_APPLICATION_ID, ' ||
                ':PROGRAM_ID, SYSDATE, ' ||
                'NVL(qri.MTI_TRANSACTION_HEADER_ID, qr.MTI_TRANSACTION_HEADER_ID), ' ||
                'NVL(qri.MTI_TRANSACTION_INTERFACE_ID, qr.MTI_TRANSACTION_INTERFACE_ID), ' ||
                'NVL(qri.MMT_TRANSACTION_ID, qr.MMT_TRANSACTION_ID), ' ||
                'NVL(qri.WJSI_GROUP_ID, qr.WJSI_GROUP_ID), ' ||
                'NVL(qri.WMTI_GROUP_ID, qr.WMTI_GROUP_ID), ' ||
                'NVL(qri.WMT_TRANSACTION_ID, qr.WMT_TRANSACTION_ID), ' ||
                'NVL(qri.RTI_INTERFACE_TRANSACTION_ID, qr.RTI_INTERFACE_TRANSACTION_ID) '
                ;

  FOR I IN 1..NUM_ELEMS LOOP
    COLUMN_LIST := COLUMN_LIST || ', ' || COLUMNS_TABLE(I);
    VALUE_LIST := VALUE_LIST || ', NVL(QRI.'|| COLUMNS_TABLE(I) ||
		        ', QR.' || COLUMNS_TABLE(I) || ') ';
  END LOOP;

  -- build the SQL statement that updates records into QA_RESULTS


  -- Bug 4270911. CU2 SQL Literal fix. TD #29
  -- Using bind variable for STMT_OF_ROWIDS, under the assumption
  -- that QA open interface only supports update of single row.
  -- srhariha. Fri Apr 15 02:42:07 PDT 2005.

  SQL_STATEMENT := 'UPDATE QA_RESULTS QR SET (' || COLUMN_LIST || ') = ' ||
     '(SELECT ' || VALUE_LIST ||
	' FROM QA_RESULTS_INTERFACE QRI ' ||
	'WHERE QRI.TRANSACTION_INTERFACE_ID = :TRANSACTION_INTERFACE_ID ' ||
	') WHERE ROWID = :BIND_ROWID';


  -- Lock the record and update.   bso

  -- Modified the select statement as below for locking the record before
  -- update as the original sql was resulting in full table scan on qa_results.
  -- The value of stmt_of_rowids will be for eg - ('AAAJv4AAmAAAph+AAD').
  -- Usage of rowid as '('''||rowid||''')' in the select stmt is masking the
  -- CBO path on rowid and results in full table scan.So trimmed the prefix ('
  -- and suffix ') and stored the remaining in a local variable(l_rowid).Then
  -- the original sql that was used to lock the row is changed as below to use
  -- l_rowid.After the change there will be no FTS when locking the record.
  -- Commented the old select stmt.
  -- Bug 3788305.suramasw.

  l_rowid := substr(stmt_of_rowids,3,length(stmt_of_rowids)-4);


  SELECT 1 INTO DUMMY FROM qa_results where rowid = l_rowid FOR UPDATE NOWAIT;

  -- End of inclusion for bug 3788305.suramasw.

  /*
    SELECT 1 INTO DUMMY FROM qa_results
    WHERE '('''||rowid||''')' = stmt_of_rowids
    FOR UPDATE NOWAIT;
  */

    -- Bug 3136107.
    -- SQL Bind project. Code modified to use bind variables instead of literals
    -- Same as the fix done for Bug 3079312.suramasw.

    EXECUTE IMMEDIATE SQL_STATEMENT USING X_USER_ID,
                                          X_LAST_UPDATE_LOGIN,
                                          X_TXN_HEADER_ID,
                                          X_REQUEST_ID,
                                          X_PROGRAM_APPLICATION_ID,
                                          X_PROGRAM_ID,
                                          X_TRANSACTION_INTERFACE_ID,
                                          L_ROWID;

    -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

  -- msg('Update_valid_rows successfully executed the query...');
    -- Bug 2302539
    -- To process History records in Parent-child
    -- scanario the following call added.
    -- rponnusa Wed Apr 24 12:19:54 PDT 2002

    -- Bug 8586750.FP of 8321226.Added this code in transaction Worker hence removing here.
    -- QA_PARENT_CHILD_PKG.insert_history_auto_rec(X_PLAN_ID, X_TXN_HEADER_ID, 1, 4) ;
    -- pdube Mon Jun 15 23:07:13 PDT 2009
EXCEPTION

    WHEN resource_busy THEN
      INSERT INTO QA_INTERFACE_ERRORS
         (TRANSACTION_INTERFACE_ID, ERROR_MESSAGE, ERROR_COLUMN,
          LAST_UPDATE_DATE, LAST_UPDATED_BY,
          CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
          REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
          PROGRAM_UPDATE_DATE)
      SELECT TRANSACTION_INTERFACE_ID, ERROR_BUSY, NULL,
          SYSDATE, X_USER_ID,
          SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
          SYSDATE
      FROM QA_RESULTS_INTERFACE
      WHERE TRANSACTION_INTERFACE_ID = X_TRANSACTION_INTERFACE_ID;

      UPDATE QA_RESULTS_INTERFACE
      SET    PROCESS_STATUS = 3
      WHERE  TRANSACTION_INTERFACE_ID = X_TRANSACTION_INTERFACE_ID;

      COMMIT;

END UPDATE_VALID_ROWS;

--
-- Bugs 5641894, 5752546
-- New procedure update_no_validate to update the plan_id, org_id, spec_id and the who columns in case the validation flag has been set to FALSE.
-- For bug 5752546, Added two more parameters, one to get the type of transaction 1 - Insert and 2 - Update and the other parameter returns the row_ids which would be used for update transactions.
-- skolluku Tue Feb 20 2007
--

PROCEDURE update_no_validate(x_group_id IN NUMBER,
                             type_of_txn IN NUMBER,
                             stmt_of_rowids OUT NOCOPY VARCHAR2) AS
   X_USER_ID                   NUMBER;
   X_USER_NAME                 VARCHAR2(100);
   X_REQUEST_ID                NUMBER;
   X_PROGRAM_APPLICATION_ID    NUMBER;
   X_PROGRAM_ID                NUMBER;
   X_LAST_UPDATE_LOGIN         NUMBER;

   X_PLAN_ID                   NUMBER;
   CHAR_ID_TABLE               NUMBER_TABLE;
   ENABLED_FLAG_TABLE          NUMBER_TABLE;
   MANDATORY_FLAG_TABLE        NUMBER_TABLE;
   DATATYPE_TABLE              NUMBER_TABLE;
   DECIMAL_PRECISION_TABLE     NUMBER_TABLE;
   VALUES_EXIST_FLAG_TABLE     NUMBER_TABLE;
   CHAR_NAME_TABLE             CHAR30_TABLE;
   DEVELOPER_NAME_TABLE        CHAR30_TABLE;
   RESULT_COLUMN_NAME_TABLE    CHAR30_TABLE;
   SQL_VALIDATION_STRING_TABLE CHAR1500_TABLE;
   HARDCODED_COLUMN_TABLE      CHAR30_TABLE;
   NUM_ELEMS                   BINARY_INTEGER;
   COPY_STMT_OF_ROWIDS         VARCHAR2(10000);
   READ_ONLY_FLAG_TABLE        NUMBER_TABLE;

BEGIN
   X_USER_ID                := who_user_id;
   X_REQUEST_ID             := who_request_id;
   X_PROGRAM_APPLICATION_ID := who_program_application_id;
   X_PROGRAM_ID             := who_program_id;
   X_LAST_UPDATE_LOGIN      := who_last_update_login;

   -- get the current user name.
   SELECT USER_NAME
   INTO   X_USER_NAME
   FROM   FND_USER_VIEW
   WHERE  USER_ID = X_USER_ID;

   -- update who columns and org_id
   UPDATE QA_RESULTS_INTERFACE QRI
   SET    QA_CREATED_BY = X_USER_ID,
          QA_CREATED_BY_NAME = X_USER_NAME,
          QA_LAST_UPDATED_BY = X_USER_ID,
          QA_LAST_UPDATED_BY_NAME = X_USER_NAME,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = X_USER_ID,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          REQUEST_ID = X_REQUEST_ID,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE,
          ORGANIZATION_ID =
                (SELECT MIN(OOD.ORGANIZATION_ID)
                 FROM   MTL_PARAMETERS OOD
                 WHERE  OOD.ORGANIZATION_CODE = QRI.ORGANIZATION_CODE)
   WHERE  GROUP_ID = X_GROUP_ID
     AND  PROCESS_STATUS = 2;

   -- update plan_id and spec_id
   UPDATE QA_RESULTS_INTERFACE QRI
      SET -- plan_id
          PLAN_ID =
                (SELECT MIN(QP.PLAN_ID)
                 FROM   QA_PLANS QP
                 WHERE  QP.NAME = QRI.PLAN_NAME
                   AND  QP.ORGANIZATION_ID = QRI.ORGANIZATION_ID),
          -- spec_id
          SPEC_ID =
                (SELECT MIN(QSVV.SPEC_ID)
                 FROM   QA_SPECS QSVV
                 WHERE  QSVV.SPEC_NAME = QRI.SPEC_NAME
                   AND  QSVV.ORGANIZATION_ID = QRI.ORGANIZATION_ID
                     AND  trunc(sysdate) BETWEEN
                          nvl(trunc(qsvv.effective_from), trunc(sysdate)) AND
                          nvl(trunc(qsvv.effective_to), trunc(sysdate)))
    WHERE QRI.GROUP_ID = X_GROUP_ID
      AND QRI.PROCESS_STATUS = 2;

   IF TYPE_OF_TXN = 2 THEN
       SELECT MAX(PLAN_ID)
       INTO   X_PLAN_ID
       FROM   QA_RESULTS_INTERFACE QRI
       WHERE  QRI.GROUP_ID = X_GROUP_ID;

       SELECT
          qpc.char_id,
          upper(replace(qc.name, ' ', '_')),
          qc.hardcoded_column,
          qc.developer_name,
          qpc.result_column_name,
          qpc.enabled_flag,
          qpc.mandatory_flag,
          qc.datatype,
          nvl(qpc.decimal_precision,qc.decimal_precision),
          qc.sql_validation_string,
          qpc.values_exist_flag,
          qpc.read_only_flag
       BULK COLLECT INTO
          char_id_table,
          char_name_table,
          hardcoded_column_table,
          developer_name_table,
          result_column_name_table,
          enabled_flag_table,
          mandatory_flag_table,
          datatype_table,
          decimal_precision_table,
          sql_validation_string_table,
          values_exist_flag_table,
          read_only_flag_table
       FROM
          qa_chars qc,
          qa_plan_chars qpc
       WHERE
          qpc.plan_id = x_plan_id AND
          qpc.char_id = qc.char_id;

        NUM_ELEMS := char_id_table.count;

        COPY_STMT_OF_ROWIDS := VALIDATE_UPDATE_TYPE_RECORDS(X_GROUP_ID,
                                                 X_PLAN_ID,
                                                 CHAR_NAME_TABLE,
                                                 DEVELOPER_NAME_TABLE,
                                                 HARDCODED_COLUMN_TABLE,
                                                 DATATYPE_TABLE,
                                                 NUM_ELEMS,
                                                 X_USER_ID,
                                                 X_LAST_UPDATE_LOGIN,
                                                 X_REQUEST_ID,
                                                 X_PROGRAM_APPLICATION_ID,
                                                 X_PROGRAM_ID);
        STMT_OF_ROWIDS := COPY_STMT_OF_ROWIDS;

        IF COPY_STMT_OF_ROWIDS IS NOT NULL THEN
            RETRIEVE_UPDATE_RECORDS(X_GROUP_ID,
                                  COPY_STMT_OF_ROWIDS,
                                  DEVELOPER_NAME_TABLE,
                                  RESULT_COLUMN_NAME_TABLE,
                                  DATATYPE_TABLE,
                                  CHAR_NAME_TABLE,
                                  NUM_ELEMS,
                                  X_PLAN_ID,
                                  READ_ONLY_FLAG_TABLE,
                                  ENABLED_FLAG_TABLE);
        END IF;
   END IF;

END update_no_validate;


PROCEDURE TRANSFER_VALID_ROWS(X_GROUP_ID NUMBER,
                              X_USER_ID NUMBER,
                              X_LAST_UPDATE_LOGIN NUMBER,
                              X_TXN_HEADER_ID NUMBER,
                              X_REQUEST_ID NUMBER,
                              X_PROGRAM_APPLICATION_ID NUMBER,
                              X_PROGRAM_ID NUMBER) IS
   X_PLAN_ID                NUMBER;
   I                        NUMBER;
   NUM_ELEMS                NUMBER;
   RESULT_COLUMN_NAME_TABLE CHAR30_TABLE;
   COLUMN_LIST              VARCHAR2(10000);
   VALUE_LIST               VARCHAR2(10000);
   SQL_STATEMENT            VARCHAR2(20000);

   -- For bug2548710.
   K                    NUMBER := 0;
   NUM_ROWS             NUMBER;
   X_INTERFACE_ID       NUMBER;
   SOURCE_CURSOR        INTEGER;
   IGNORE               INTEGER;
   ERRMSG               VARCHAR2(30);
   ID_FIELD             VARCHAR2(30);
   INTERFACE_ID_TABLE   NUMBER_TABLE;

   -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
   l_return_status      VARCHAR2(1);

BEGIN
   SELECT MAX(PLAN_ID)
   INTO   X_PLAN_ID
   FROM   QA_RESULTS_INTERFACE QRI
   WHERE  QRI.GROUP_ID = X_GROUP_ID
     AND  PROCESS_STATUS = 2;

   -- if no rows were successfully validated, no need to continue

   IF (X_PLAN_ID IS NULL) THEN
      RETURN;
   END IF;

   -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
   -- comment out the following code
/*

   -- Get all the interface_ids for this group_id onto a struct.
   -- We need to update the SEQUENCExx columns before we insert into
   -- QA_RESULTS. For more info see Bug 2548710.

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
         'SELECT TRANSACTION_INTERFACE_ID ' ||
         'FROM QA_RESULTS_INTERFACE QRI ' ||
         'WHERE QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND QRI.PROCESS_STATUS = 2 ' ||
         ' AND NOT EXISTS
               (SELECT ''X'' ' ||
               'FROM QA_INTERFACE_ERRORS QIE ' ||
               'WHERE QIE.TRANSACTION_INTERFACE_ID = ' ||
                  'QRI.TRANSACTION_INTERFACE_ID )';


   SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(SOURCE_CURSOR, SQL_STATEMENT, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(SOURCE_CURSOR, ':GROUP_ID', X_GROUP_ID);

   DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR, 1, X_INTERFACE_ID);
   IGNORE := DBMS_SQL.EXECUTE(SOURCE_CURSOR);

   LOOP
      IF (DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0) THEN
         K := K + 1;
         DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR, 1, X_INTERFACE_ID);
         INTERFACE_ID_TABLE(K) := X_INTERFACE_ID;
      ELSE
         EXIT;
      END IF;
   END LOOP;
   NUM_ROWS := K ;
   DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);

   -- Before we update, make sure that all the variables are initialized.
   -- Exceptions can rise, if its not done.

   IF (G_INIT_SEQ_TAB = 1) THEN
      -- Call local initialization procedure. Bug 2548710 rponnusa Mon Nov 18 03:49:15 PST 2002

      INIT_SEQ_TABLE(NUM_ROWS);
   END IF;

   -- Use the bulk binding option to update all the SEQUENCExx columns
   -- together. Fetch the values for all sequence columns from the
   -- global variables. For more info see bug 2548710.

   FORALL J IN 1..NUM_ROWS
      UPDATE QA_RESULTS_INTERFACE QRI
      SET    SEQUENCE1  = G_SEQ_TAB1(J),
             SEQUENCE2  = G_SEQ_TAB2(J),
             SEQUENCE3  = G_SEQ_TAB3(J),
             SEQUENCE4  = G_SEQ_TAB4(J),
             SEQUENCE5  = G_SEQ_TAB5(J),
             SEQUENCE6  = G_SEQ_TAB6(J),
             SEQUENCE7  = G_SEQ_TAB7(J),
             SEQUENCE8  = G_SEQ_TAB8(J),
             SEQUENCE9  = G_SEQ_TAB9(J),
             SEQUENCE10 = G_SEQ_TAB10(J),
             SEQUENCE11 = G_SEQ_TAB11(J),
             SEQUENCE12 = G_SEQ_TAB12(J),
             SEQUENCE13 = G_SEQ_TAB13(J),
             SEQUENCE14 = G_SEQ_TAB14(J),
             SEQUENCE15 = G_SEQ_TAB15(J)
      WHERE  QRI.GROUP_ID = X_GROUP_ID
      AND    QRI.TRANSACTION_INTERFACE_ID = INTERFACE_ID_TABLE(J)
      AND    NOT EXISTS
                (SELECT 'X'
                 FROM QA_INTERFACE_ERRORS QIE
                 WHERE QIE.TRANSACTION_INTERFACE_ID = QRI.TRANSACTION_INTERFACE_ID);

   -- End of changes for bug 2548710.
*/

   I := 0;
   -- Bug 4958776. SQL Repository Fix SQL ID: 15009245
   FOR CHARREC IN (SELECT RESULT_COLUMN_NAME
                     FROM QA_PLAN_CHARS
                    WHERE PLAN_ID = X_PLAN_ID) LOOP
      I := I + 1;
      RESULT_COLUMN_NAME_TABLE(I) := CHARREC.RESULT_COLUMN_NAME;
   END LOOP;
   NUM_ELEMS := I;

   --
   -- Modified the COLUMN_LIST and VALUE_LIST to include
   -- new columns added for ASO project.
   -- This would make ID-transfer without validations
   -- rkunchal Thu Jul 25 01:43:48 PDT 2002
   --

   COLUMN_LIST := 'COLLECTION_ID, OCCURRENCE, LAST_UPDATE_DATE, ' ||
         'QA_LAST_UPDATE_DATE, LAST_UPDATED_BY, QA_LAST_UPDATED_BY, ' ||
         'CREATION_DATE, QA_CREATION_DATE, CREATED_BY, QA_CREATED_BY, ' ||
         'LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID, ' ||
         'PROGRAM_ID, PROGRAM_UPDATE_DATE, ' ||
         'TXN_HEADER_ID, ' ||
         'ORGANIZATION_ID, PLAN_ID, SPEC_ID,' ||
         'MTI_TRANSACTION_HEADER_ID,' ||
         'MTI_TRANSACTION_INTERFACE_ID,' ||
         'MMT_TRANSACTION_ID,' ||
         'WJSI_GROUP_ID,' ||
         'WMTI_GROUP_ID,' ||
         'WMT_TRANSACTION_ID,' ||
         'RTI_INTERFACE_TRANSACTION_ID ' ;

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   VALUE_LIST := 'COLLECTION_ID, QA_OCCURRENCE_S.NEXTVAL, SYSDATE, ' ||
         'SYSDATE,  :USER_ID, QA_LAST_UPDATED_BY, ' ||
         'SYSDATE, SYSDATE, :USER_ID2, QA_CREATED_BY, ' ||
         ':LAST_UPDATE_LOGIN, :REQUEST_ID, :PROGRAM_APPLICATION_ID, ' ||
         ':PROGRAM_ID, SYSDATE,:TXN_HEADER_ID ' ||
         ', ORGANIZATION_ID, PLAN_ID, NVL(SPEC_ID, 0),' ||
         'MTI_TRANSACTION_HEADER_ID,' ||
         'MTI_TRANSACTION_INTERFACE_ID,' ||
         'MMT_TRANSACTION_ID,' ||
         'WJSI_GROUP_ID,' ||
         'WMTI_GROUP_ID,' ||
         'WMT_TRANSACTION_ID,' ||
         'RTI_INTERFACE_TRANSACTION_ID ' ;

   FOR I IN 1..NUM_ELEMS LOOP
      COLUMN_LIST := COLUMN_LIST || ', ' || RESULT_COLUMN_NAME_TABLE(I);
      VALUE_LIST := VALUE_LIST || ', ' || RESULT_COLUMN_NAME_TABLE(I);
   END LOOP;

   -- build the sql statement that transfers records into qa_results

   SQL_STATEMENT := 'INSERT INTO QA_RESULTS (' || COLUMN_LIST ||
         ') SELECT ' || VALUE_LIST || ' FROM QA_RESULTS_INTERFACE ' ||
         'WHERE GROUP_ID = :GROUP_ID ' ||
         ' AND  PROCESS_STATUS = 2';

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   EXECUTE IMMEDIATE SQL_STATEMENT USING X_USER_ID,
                                         X_USER_ID,
                                         X_LAST_UPDATE_LOGIN,
                                         X_REQUEST_ID,
                                         X_PROGRAM_APPLICATION_ID,
                                         X_PROGRAM_ID,
                                         X_TXN_HEADER_ID,
                                         X_GROUP_ID;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);

  -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
  -- call api to generate seq. value for all the records identified by txn_header_id
  -- we can safely call sequence api before inserting history/automatic records
  -- since Seq. values only going to be copied to history/automatic records
  QA_SEQUENCE_API.Generate_Seq_for_DDE(X_TXN_HEADER_ID,X_PLAN_ID,l_return_status);

   -- Bug 2302539
   -- To process History/automatic records in Parent-child
   -- scanario the following call added.
   -- rponnusa Wed Apr 24 12:19:54 PDT 2002

   -- Bug 8586750.FP of 8321226.Added this code in transaction Worker hence removing here.
   -- QA_PARENT_CHILD_PKG.insert_history_auto_rec(X_PLAN_ID, X_TXN_HEADER_ID, 1, 2) ;
   -- QA_PARENT_CHILD_PKG.insert_history_auto_rec(X_PLAN_ID, X_TXN_HEADER_ID, 1, 4) ;
   -- pdube Mon Jun 15 23:07:13 PDT 2009

END TRANSFER_VALID_ROWS;


FUNCTION TRANSACTION_WORKER(X_GROUP_ID NUMBER,
                            X_VAL_FLAG NUMBER,
                            X_DEBUG VARCHAR2,
			    TYPE_OF_TXN NUMBER) RETURN BOOLEAN IS

   X_USER_ID                NUMBER;
   X_REQUEST_ID             NUMBER;
   X_PROGRAM_APPLICATION_ID NUMBER;
   X_PROGRAM_ID             NUMBER;
   X_LAST_UPDATE_LOGIN      NUMBER;
   X_COLLECTION_ID          NUMBER;
   X_TXN_HEADER_ID          NUMBER := 0;
   ACTIONS_REQUEST_ID       NUMBER;
   DUMMY                    NUMBER;

   ERRCODE                  BOOLEAN;
   ACTION_FLAG              BOOLEAN;
   CRITICAL_ERROR           EXCEPTION;

   STMT_OF_ROWIDS	    VARCHAR2(10000);    -- For update capabilities.
   l_error_message          VARCHAR2(240);

   CURSOR C IS SELECT MARKER FROM QA_RESULTS_INTERFACE
         WHERE GROUP_ID = X_GROUP_ID
         AND   PROCESS_STATUS = 2
         AND   MARKER IS NOT NULL;

   -- Bug 8586750.Fp for 8321226.pdube Mon Jun 15 23:07:13 PDT 2009
   l_req_data varchar2(150);
   l_request_id NUMBER;
   PLAN_ID_TABLE NUMBER_TABLE;
   action_child_flag NUMBER := 0;
BEGIN
   -- Bug 8586750.Fp for 8321226.pdube Mon Jun 15 23:07:13 PDT 2009
   -- Added the following statements for getting the request_id and request_data
   -- parameter value.This parameter request_data will have value only if this
   -- worker is recalled, after completion of Quality Actions(Child) request.
   -- Introduced a logic based on if condition to insert child records if the
   -- request is restarted after child request completion.
   FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);
   l_req_data := fnd_conc_global.request_data;

-- Bug 8586750.Fp for 8321226.Introdcued this if condition.
IF l_req_data IS NULL THEN

   X_USER_ID := who_user_id;
   X_REQUEST_ID := who_request_id;
   X_PROGRAM_APPLICATION_ID := who_program_application_id;
   X_PROGRAM_ID := who_program_id;
   X_LAST_UPDATE_LOGIN := who_last_update_login;

   -- update process status to 2 (running) for rows in this group

   UPDATE QA_RESULTS_INTERFACE
   SET    PROCESS_STATUS = 2,
          REQUEST_ID = X_REQUEST_ID,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = X_USER_ID,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE
   WHERE  GROUP_ID = X_GROUP_ID;

   -- Get the count of records processed by each worker.
   -- Bug 2548710 rponnusa Mon Nov 18 03:49:15 PST 2002

   G_ROW_COUNT := SQL%ROWCOUNT;

   -- delete rows from the errors table that are associated with the
   -- rows we are about to validate.  we do this so that old errors will
   -- not stick around after the user has resubmitted a record.

   DELETE FROM QA_INTERFACE_ERRORS
   WHERE  TRANSACTION_INTERFACE_ID IN
      (SELECT TRANSACTION_INTERFACE_ID
         FROM QA_RESULTS_INTERFACE
        WHERE GROUP_ID = X_GROUP_ID);

   COMMIT;

   -- Modified call to 'Validate'.  Added 2 more parameters as a result of
   -- adding update capabilities.
   IF (X_VAL_FLAG = 1) THEN
      ERRCODE := QLTTRAWB.VALIDATE(X_GROUP_ID,TYPE_OF_TXN,STMT_OF_ROWIDS);
      IF (ERRCODE = FALSE) THEN
         RAISE CRITICAL_ERROR;
      END IF;
   --
   -- Bugs 5641894, 5752546
   -- Made a call to the procedure update_no_validate to update the plan_id, org_id, spec_id and the who columns in case the validation flag has been set to FALSE
   -- For bug 5752546 added two more parameters, one to send the type of transaction 1 - Insert and 2 - Update and the other parameter gets the row_ids which would be used for update transactions.
   -- skolluku Tue Feb 20 2007
   --
   ELSE
      update_no_validate(X_GROUP_ID,TYPE_OF_TXN,STMT_OF_ROWIDS);
   END IF;

   -- update collection_id, qa_created_by, and qa_last_updated_by
   -- if they are null for inserts
   -- update qa_created_by and qa_last_updated_by if they are null for updates

   IF TYPE_OF_TXN <> 2
     THEN SELECT QA_COLLECTION_ID_S.NEXTVAL INTO X_COLLECTION_ID FROM DUAL;
   		UPDATE QA_RESULTS_INTERFACE
   		SET    COLLECTION_ID = NVL(COLLECTION_ID, X_COLLECTION_ID),
          	  QA_CREATED_BY = NVL(QA_CREATED_BY, X_USER_ID),
          	  QA_LAST_UPDATED_BY = NVL(QA_LAST_UPDATED_BY, X_USER_ID)
   		WHERE  GROUP_ID = X_GROUP_ID
     	AND  PROCESS_STATUS = 2;
     ELSE UPDATE QA_RESULTS_INTERFACE
		SET  QA_CREATED_BY = NVL(QA_CREATED_BY, X_USER_ID),
		     QA_LAST_UPDATED_BY = NVL(QA_LAST_UPDATED_BY, X_USER_ID)
	     WHERE  GROUP_ID = X_GROUP_ID
		AND  PROCESS_STATUS = 2;
   END IF;


   -- figure out if action package needs to be called by seeing if any
   -- rows have a non-null marker column

   OPEN C;
   FETCH C INTO DUMMY;
   IF (C%FOUND) THEN
      ACTION_FLAG := TRUE;
   ELSE
      ACTION_FLAG := FALSE;
   END IF;
   CLOSE C;

   -- we need to select a txn_header_id, in case actions were fired

   SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL INTO X_TXN_HEADER_ID FROM DUAL;

   -- insert the valid records into the results table
   -- modified for update capabilities; 1 = 'INSERT' and 2 = 'UPDATE'
   -- also everything else will be interpreted as 'INSERT'
   IF TYPE_OF_TXN = 2 THEN
       POPULATE_HISTORY_TABLE(X_GROUP_ID, X_TXN_HEADER_ID,
	   STMT_OF_ROWIDS, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_REQUEST_ID,X_PROGRAM_APPLICATION_ID,X_PROGRAM_ID);

       UPDATE_VALID_ROWS(X_GROUP_ID, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_TXN_HEADER_ID, X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID,
           X_PROGRAM_ID, STMT_OF_ROWIDS);
   ELSE
       TRANSFER_VALID_ROWS(X_GROUP_ID, X_USER_ID, X_LAST_UPDATE_LOGIN,
           X_TXN_HEADER_ID, X_REQUEST_ID,
	   X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID);
   END IF;


   -- if actions were triggered, fire the actions package.  we will also
   -- fire the actions package if validate flag is false.  in this case,
   -- we haven't done any validation, so we have no way of knowing for sure
   -- whether or not actions were triggered.  to be safe, we have to fire
   -- the actions package every time, even though it may not be needed.

   -- Bug 8586750.Fp for 8321226.Added an additional logic to avoid running of actions
   -- conc request  as child for users not having set up like "Parent action populating
   -- the criteria element for automatic/history child plan".This query will return 1 if
   -- any such relation is found.pdube Mon Jun 15 23:07:13 PDT 2009
   begin
     select 1
     into action_child_flag
     from QA_PC_PLAN_RELATIONSHIP ppr,
          qa_pc_criteria qpct,
          qa_plan_char_actions pca,
          qa_plan_char_action_triggers qpcat
     where ppr.parent_plan_id = qpcat.plan_id
      and ppr.plan_relationship_id = qpct.plan_relationship_id
      and ppr.data_entry_mode in (2,4)
      and qpct.char_id = pca.assigned_char_id
      and pca.plan_char_action_trigger_id = qpcat.plan_char_action_trigger_id
      and qpcat.plan_id in (SELECT DISTINCT plan_id
                            FROM  qa_results_interface qri
                          WHERE  qri.group_id = x_group_id
                          AND qri.process_status = 2)
      and pca.action_id = 24
      and ROWNUM =1;
    exception
    when no_data_found then
      action_child_flag := 0;
    end;

   -- Bug 8586750.Fp for 8321226.Changed the condition to introduce action_child_flag in order to
   -- call actions as child only when child have a criteria which is action governed
   -- at parent.pdube Mon Jun 15 23:07:13 PDT 2009
   -- IF ((ACTION_FLAG = TRUE) OR (X_VAL_FLAG = 2)) THEN
   IF ((ACTION_FLAG = TRUE) OR (X_VAL_FLAG = 2)) AND (action_child_flag = 1) THEN
      -- Bug 8586750.Fp for 8321226.Made the Quality Actions Request as Subrequest passing TRUE.
      -- ACTIONS_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST('QA', 'QLTACTWB', NULL,
      --       NULL, FALSE, X_TXN_HEADER_ID,'IMPORT');
      CHILD_CONC_REQ_CALL(X_TXN_HEADER_ID);
   ELSE
      -- Bug 8586750.Fp for 8321226.Following is the already existing code for launching actions
      -- as a standalone concurrent program.pdube Mon Jun 15 23:07:13 PDT 2009
      IF ((ACTION_FLAG = TRUE) OR (X_VAL_FLAG = 2)) AND (action_child_flag = 0) THEN
	 -- Passing IMPORT as the value for ARGUMENT2 in qltactwb.
         -- whenever qltactwb is called from qlttrawb, the value IMPORT will
         -- also be passed.
         -- Bug 3273447. suramasw
	 ACTIONS_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST('QA', 'QLTACTWB', NULL,
                            NULL, FALSE, X_TXN_HEADER_ID,'IMPORT');
      END IF;

      -- Bug 8586750.Fp for 8321226.Getting plan_ids to be passed to called procedure.
      SELECT DISTINCT PLAN_ID
      BULK COLLECT INTO PLAN_ID_TABLE
      FROM   QA_RESULTS_INTERFACE QRI
      WHERE  QRI.GROUP_ID = X_GROUP_ID
      AND  PROCESS_STATUS = 2;

      -- Bug 8586750.Fp for 8321226.Calling these procedures to update/delete records from QRI
      -- and to insert automatic/history child records.pdube
      UPDATE_DELETE_QRI (X_REQUEST_ID,
                        X_USER_ID,
                        X_LAST_UPDATE_LOGIN,
                        X_PROGRAM_APPLICATION_ID,
                        X_PROGRAM_ID,
                        X_GROUP_ID,
			X_DEBUG);
      FOR i IN 1..PLAN_ID_TABLE.COUNT LOOP
         INSERT_AUTO_HIST_CHILD (TYPE_OF_TXN,
                                 PLAN_ID_TABLE(i),
                                 X_TXN_HEADER_ID);
      END LOOP;
      -- Bug 8586750.Fp for 8321226.Issuing commit in order to complete the transaction in this case.
      COMMIT;
   END IF;

   RETURN TRUE;

-- Bug 8586750.Fp for 8321226.This means (l_req_data IS NOT NULL) i.e. parent request
-- is restarted after child request(Quality Actions).
-- pdube Mon Jun 15 23:07:13 PDT 2009
ELSE

   -- Bug 8586750.Fp for 8321226.Getting plan_ids to be passed to called procedure.
   SELECT DISTINCT PLAN_ID
   BULK COLLECT INTO PLAN_ID_TABLE
   FROM   QA_RESULTS_INTERFACE QRI
   WHERE  QRI.GROUP_ID = X_GROUP_ID
   AND  PROCESS_STATUS = 2;

   -- Bug 8586750.Fp for 8321226.Getting the txn_header_id for corresponding
   -- child request which was first argument for Quality Actions.
   SELECT to_number(argument1)
   INTO x_txn_header_id
   FROM FND_CONCURRENT_REQUESTS
   WHERE priority_request_id = l_request_id
     AND request_id <> priority_request_id;

   -- Bug 8586750.Fp for 8321226.Calling these procedures to update/delete records from QRI
   -- and to insert automatic/history child records.pdube
   UPDATE_DELETE_QRI (X_REQUEST_ID,
                      X_USER_ID,
                      X_LAST_UPDATE_LOGIN,
                      X_PROGRAM_APPLICATION_ID,
                      X_PROGRAM_ID,
                      X_GROUP_ID,
		      X_DEBUG);
   FOR i IN 1..PLAN_ID_TABLE.COUNT LOOP
      INSERT_AUTO_HIST_CHILD (TYPE_OF_TXN,
                              PLAN_ID_TABLE(i),
                              X_TXN_HEADER_ID);
   END LOOP;

   COMMIT;

   RETURN TRUE;

END IF; -- (l_req_data IS NULL)
-- End of Bug Bug 8586750.Fp for 8321226

EXCEPTION

   -- user_sql_error exception was added for better diagnosis of import
   -- problems, which most often is limited to user defined sql validation
   -- string.  Please see bug # 1680481 for details.
   --
   -- ORASHID

   WHEN user_sql_error THEN

       l_error_message := error_bad_sql || ' ' || g_sqlerrm;

       INSERT INTO qa_interface_errors
           (transaction_interface_id, error_message, error_column,
            last_update_date, last_updated_by,
            creation_date, created_by, last_update_login,
            request_id, program_application_id, program_id,
            program_update_date)
       SELECT transaction_interface_id, substr(l_error_message,1, 240),
           g_col_name, sysdate, x_user_id, sysdate, x_user_id,
           x_last_update_login, x_request_id, x_program_application_id,
           x_program_id, sysdate
       FROM qa_results_interface
       WHERE group_id = x_group_id;

       UPDATE qa_results_interface
       SET    process_status = 3
       WHERE  group_id = x_group_id;

       COMMIT;
       RETURN FALSE;

   WHEN OTHERS THEN
      INSERT INTO QA_INTERFACE_ERRORS
         (TRANSACTION_INTERFACE_ID, ERROR_MESSAGE, ERROR_COLUMN,
          LAST_UPDATE_DATE, LAST_UPDATED_BY,
          CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
          REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
          PROGRAM_UPDATE_DATE)
      SELECT TRANSACTION_INTERFACE_ID, ERROR_CRITICAL, NULL,
          SYSDATE, X_USER_ID,
          SYSDATE, X_USER_ID, X_LAST_UPDATE_LOGIN,
          X_REQUEST_ID, X_PROGRAM_APPLICATION_ID, X_PROGRAM_ID,
          SYSDATE
      FROM QA_RESULTS_INTERFACE
      WHERE GROUP_ID = X_GROUP_ID;

      UPDATE QA_RESULTS_INTERFACE
      SET    PROCESS_STATUS = 3
      WHERE  GROUP_ID = X_GROUP_ID;

      COMMIT;
      RETURN FALSE;

END TRANSACTION_WORKER;


-- This is a new function that adds multiple update capability to the
-- current collection import module (which could only process one
-- update at a time.
--
-- Bryan So (BSO) 1/2/1998

FUNCTION TRANSACTION_UPDATE(G_ID NUMBER,
                            VAL_FLAG NUMBER,
                            DEBUG VARCHAR2,
			    TYPE_OF_TXN NUMBER) RETURN BOOLEAN IS

   NEW_GROUP_ID NUMBER;
   RESULT BOOLEAN;
   CURSOR c1 IS SELECT rowid
                FROM QA_RESULTS_INTERFACE
                WHERE GROUP_ID = G_ID;

BEGIN
    -- Loop through the group of update records
    RESULT := TRUE;
    FOR rec IN c1 LOOP
        -- Get a new group ID to be used for the update records.
        SELECT QA_GROUP_S.NEXTVAL INTO NEW_GROUP_ID FROM DUAL;

        UPDATE QA_RESULTS_INTERFACE
            SET GROUP_ID = NEW_GROUP_ID
  	    WHERE rowid = rec.rowid;

        -- Call the old transaction worker to do the job.
	-- Result will be set to true if ALL updates succeed.
	-- (All updates will be processed even if some of them fail.)

	RESULT := RESULT and TRANSACTION_WORKER(NEW_GROUP_ID,
		    VAL_FLAG, DEBUG, TYPE_OF_TXN);
    END LOOP;

    RETURN RESULT;

END TRANSACTION_UPDATE;


-- wrapper so that the transaction worker can be called as a concurrent
-- program.
--
--    argument1 is the group id
--    argument2 is a validation flag
--    argument3 is a debug flag (profile MRP_DEBUG)
--    argument4 is transaction type (2 = update, else insert)
--    argument5 is workflow key (or null if no workflow launched)
--    argument6 is the parent's (import manager) request ID
--    argument7 is the user id of the person who ran import
--    argument8 is the workflow itemtype


PROCEDURE WRAPPER (ERRBUF OUT NOCOPY VARCHAR2,
                   RETCODE OUT NOCOPY VARCHAR2,
                   ARGUMENT1 IN VARCHAR2,
                   ARGUMENT2 IN VARCHAR2,
                   ARGUMENT3 IN VARCHAR2,
		   ARGUMENT4 IN VARCHAR2,
		   ARGUMENT5 IN VARCHAR2,
		   ARGUMENT6 IN VARCHAR2,
                   ARGUMENT7 IN VARCHAR2,
		   ARGUMENT8 IN VARCHAR2) IS

   X_RETURN BOOLEAN;
   TYPE_OF_TXN NUMBER;
   workflow_type Varchar2(8) := argument8;
   workflow_key number := to_number(argument5);
BEGIN
    -- R12 Project MOAC 4637896.  Simple MOAC Initialization needed.
    -- This will initialize MOAC entities' VPD security to populate
    -- them with the right values for validation purpose.
    -- bso Sun Oct  2 11:48:14 PDT 2005
    qa_moac_pkg.init;

   -- get the translated message text

-- Just a test 'bso delete this later
-- qlttrafb.exec_sql('alter session set nls_numeric_characters='',.''');

   ERROR_REJECT := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_REJECT'));
   ERROR_DISABLED := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_DISABLED'));
   ERROR_MANDATORY := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_MANDATORY'));
   ERROR_NEED_PARENT := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_NEED_PARENT'));
   ERROR_INVALID_VALUE := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_INVALID_VALUE'));
   ERROR_OUTSIDE_LIMITS := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_OUTSIDE_LIMITS'));
   ERROR_CRITICAL := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_CRITICAL'));
   ERROR_INVALID_NUMBER := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_INVALID_NUMBER'));
   ERROR_INVALID_DATE := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_INVALID_DATE'));

   ERROR_NEED_REV := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_NEED_REV'));
   ERROR_CANT_HAVE_REV := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_CANT_HAVE_REV'));
   ERROR_CANT_HAVE_LOC := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_CANT_HAVE_LOC'));
   ERROR_BUSY := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_BUSY'));
   ERROR_BAD_SQL := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_BAD_USER_SQL'));

   -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
   G_SEQUENCE_DEFAULT := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_SEQ_DEFAULT'));

   -- Tracking Bug : 3104827. Review Tracking Bug : 3148873
   -- Added to Get Error Message String for Read Only Flag Collection Plan Elements
   -- saugupta Wed Aug 27 07:25:51 PDT 2003.
   ERROR_READ_ONLY := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_READ_ONLY'));

   -- Bug 3069404 ksoh Tue Mar 16 10:43:36 PST 2004
   -- Error message for importing sequence element
   ERROR_SEQUENCE := dequote(FND_MESSAGE.GET_STRING('QA', 'QA_INTERFACE_SEQUENCE'));

   -- For Timezone Compliance bug 3179845. Error used for invalid date and Time.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ERROR_INVALID_DATETIME := dequote(FND_MESSAGE.GET_STRING('QA',
         'QA_INTERFACE_INVALID_DATETIME'));


   --
   -- A rather unusual situation, we will use the request id of the
   -- parent (import manager).  This will be set in the wrapper.
   -- bso
   --
   who_request_id := to_number(argument6);
   who_created_by := to_number(argument7);
   who_user_id    := to_number(argument7);
   who_last_update_login := to_number(argument7);

   TYPE_OF_TXN := TO_NUMBER(ARGUMENT4);
   -- Bug 3785197. Update was failing if read only or sequence elements was set as matching element.
   -- Storing the transaction type to a global variable which will be used in VALIDATE_STEPS()
   -- procedure. G_TYPE_OF_TXN = 1 (Insert) or 2 (Update).
   -- srhariha. Fri Jul 23 03:04:52 PDT 2004.
   G_TYPE_OF_TXN := TYPE_OF_TXN;

  IF TYPE_OF_TXN = 1 THEN -- perform insert
       X_RETURN := TRANSACTION_WORKER(TO_NUMBER(ARGUMENT1),
		     TO_NUMBER(ARGUMENT2), ARGUMENT3, TYPE_OF_TXN);
   ELSE -- perform update
       X_RETURN := TRANSACTION_UPDATE(TO_NUMBER(ARGUMENT1),
		     TO_NUMBER(ARGUMENT2), ARGUMENT3, TYPE_OF_TXN);
   END IF;

   COMMIT;

   --
   -- If some import records are inserted through self-service apps,
   -- then the workflow_key passed in will not be null.  A workflow
   -- have also been launched by the manager.  This workflow is in
   -- blocking state until all workers finish.  Since we just finished,
   -- tell workflow to unblock one worker.
   --
   IF workflow_key IS NOT NULL THEN
       qa_ss_import_wf.unblock(workflow_type, workflow_key);
   END IF;

   ERRBUF := '';
   IF X_RETURN THEN
       RETCODE := 0;
   ELSE
       RETCODE := 1;
   END IF;

   EXCEPTION WHEN OTHERS THEN
       --
       -- Of utmost importance is to terminate the workflow (if there
       -- is one) even in critical situation.  Otherwise, workflow
       -- will loop.
       --
       IF workflow_key IS NOT NULL THEN
           qa_ss_import_wf.unblock(workflow_type, workflow_key);
       END IF;
       raise;

END WRAPPER;

-- Bug 2548710. Added following procedure
-- rponnusa Mon Nov 18 03:49:15 PST 2002

PROCEDURE INIT_SEQ_TABLE(p_count IN NUMBER) IS

-- Initialize all unused g_seq_tabxx to null before going for bulk update

BEGIN
  IF G_SEQ_TAB1 IS NULL THEN
     G_SEQ_TAB1 := CHAR50_TABLE();
     G_SEQ_TAB1.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB2 IS NULL THEN
     G_SEQ_TAB2 := CHAR50_TABLE();
     G_SEQ_TAB2.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB3 IS NULL THEN
     G_SEQ_TAB3 := CHAR50_TABLE();
     G_SEQ_TAB3.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB4 IS NULL THEN
     G_SEQ_TAB4 := CHAR50_TABLE();
     G_SEQ_TAB4.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB5 IS NULL THEN
     G_SEQ_TAB5 := CHAR50_TABLE();
     G_SEQ_TAB5.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB6 IS NULL THEN
     G_SEQ_TAB6 := CHAR50_TABLE();
     G_SEQ_TAB6.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB7 IS NULL THEN
     G_SEQ_TAB7 := CHAR50_TABLE();
     G_SEQ_TAB7.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB8 IS NULL THEN
     G_SEQ_TAB8 := CHAR50_TABLE();
     G_SEQ_TAB8.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB9 IS NULL THEN
     G_SEQ_TAB9 := CHAR50_TABLE();
     G_SEQ_TAB9.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB10 IS NULL THEN
     G_SEQ_TAB10 := CHAR50_TABLE();
     G_SEQ_TAB10.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB11 IS NULL THEN
     G_SEQ_TAB11 := CHAR50_TABLE();
     G_SEQ_TAB11.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB12 IS NULL THEN
     G_SEQ_TAB12 := CHAR50_TABLE();
     G_SEQ_TAB12.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB13 IS NULL THEN
     G_SEQ_TAB13 := CHAR50_TABLE();
     G_SEQ_TAB13.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB14 IS NULL THEN
     G_SEQ_TAB14 := CHAR50_TABLE();
     G_SEQ_TAB14.EXTEND(p_count);
  END IF;

  IF G_SEQ_TAB15 IS NULL THEN
     G_SEQ_TAB15 := CHAR50_TABLE();
     G_SEQ_TAB15.EXTEND(p_count);
  END IF;

  -- Gapless Sequence Proj Start.
  -- rponnusa Wed Jul 30 04:52:45 PDT 2003

  IF G_PLAN_ID_TAB IS NULL THEN
     G_PLAN_ID_TAB := NUM_TABLE();
     G_PLAN_ID_TAB.EXTEND(p_count);
  END IF;

  IF G_COLLECTION_ID_TAB IS NULL THEN
     G_COLLECTION_ID_TAB := NUM_TABLE();
     G_COLLECTION_ID_TAB.EXTEND(p_count);
  END IF;

  IF G_OCCURRENCE_TAB IS NULL THEN
     G_OCCURRENCE_TAB := NUM_TABLE();
     G_OCCURRENCE_TAB.EXTEND(p_count);
  END IF;

  IF G_TXN_HEADER_ID_TAB IS NULL THEN
     G_TXN_HEADER_ID_TAB := NUM_TABLE();
     G_TXN_HEADER_ID_TAB.EXTEND(p_count);
  END IF;

 -- Gapless Sequence Proj End

  G_INIT_SEQ_TAB := 2;

END INIT_SEQ_TABLE;

-- Bug 8586750.Fp for 8321226.pdube Mon Jun 15 23:07:13 PDT 2009
-- Created Procedure to update QRI this code is moved to get this procedure reusable.
PROCEDURE UPDATE_DELETE_QRI(P_REQUEST_ID IN NUMBER,
                            P_USER_ID IN NUMBER,
                            P_LAST_UPDATE_LOGIN IN NUMBER,
                            P_PROGRAM_APPLICATION_ID IN NUMBER,
                            P_PROGRAM_ID IN NUMBER,
                            P_GROUP_ID IN NUMBER,
                            P_DEBUG IN VARCHAR2) IS
BEGIN
   -- update process status to 4 for successful rows

   UPDATE QA_RESULTS_INTERFACE
   SET    PROCESS_STATUS = 4,
          REQUEST_ID = P_REQUEST_ID,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = P_USER_ID,
          LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = P_PROGRAM_ID,
          PROGRAM_UPDATE_DATE = SYSDATE
   WHERE  GROUP_ID = P_GROUP_ID
     AND  PROCESS_STATUS = 2;

   -- delete any error messages still around for successfully-validated rows

   DELETE FROM QA_INTERFACE_ERRORS
   WHERE  TRANSACTION_INTERFACE_ID IN
   (SELECT TRANSACTION_INTERFACE_ID
      FROM QA_RESULTS_INTERFACE
     WHERE PROCESS_STATUS = 4);

   -- delete all status 4 rows, not just the ones associated with the
   -- current group id.  we delete all so that if the user changed a
   -- record's status to 4 in the update form, it won't stay around forever.
   -- only delete the rows if the MRP_DEBUG profile is not set to Y.

   IF (NVL(P_DEBUG, 'N') <> 'Y') THEN
      DELETE FROM QA_RESULTS_INTERFACE WHERE PROCESS_STATUS = 4;
   END IF;

END UPDATE_DELETE_QRI;

-- Bug 8586750.Fp for 8321226.pdube Mon Jun 15 23:07:13 PDT 2009
-- Created Procedure to insert automatic or history child records.
PROCEDURE INSERT_AUTO_HIST_CHILD (P_TYPE_OF_TXN IN NUMBER,
                                  P_PLAN_ID IN NUMBER,
                                  P_TXN_HEADER_ID IN NUMBER) IS
BEGIN
   -- Bug 8586750.Fp for 8321226.Added this condition for creating automatic/history records
   -- for update(type_of_txn=2) and insert(type_of_txn=1) transactions.
   IF P_TYPE_OF_TXN = 2 THEN
     QA_PARENT_CHILD_PKG.insert_history_auto_rec(P_PLAN_ID, P_TXN_HEADER_ID, 1, 4) ;
   ELSE
     QA_PARENT_CHILD_PKG.insert_history_auto_rec(P_PLAN_ID, P_TXN_HEADER_ID, 1, 2) ;
     QA_PARENT_CHILD_PKG.insert_history_auto_rec(P_PLAN_ID, P_TXN_HEADER_ID, 1, 4) ;
   END IF;
END INSERT_AUTO_HIST_CHILD;

-- Bug 8586750.Fp for 8321226.Made the Quality Actions Request as Subrequest passing TRUE.
-- Made this autonomous commit to escape explicit commit of transactional data.
-- pdube Mon Jun 15 23:07:13 PDT 2009
PROCEDURE CHILD_CONC_REQ_CALL(P_TXN_HEADER_ID IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
ACTIONS_REQUEST_ID NUMBER;
BEGIN
      ACTIONS_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST('QA', 'QLTACTWB', NULL,
             NULL, TRUE, P_TXN_HEADER_ID,'IMPORT');

      -- Bug 8586750.Fp for 8321226.Added this code to pause the parent request(Worker).
      FND_CONC_GLOBAL.SET_REQ_GLOBALS(conc_status  => 'PAUSED', request_data => to_char(2));
      COMMIT;
END CHILD_CONC_REQ_CALL;




END QLTTRAWB;


/

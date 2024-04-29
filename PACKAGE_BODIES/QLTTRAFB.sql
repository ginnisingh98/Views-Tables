--------------------------------------------------------
--  DDL for Package Body QLTTRAFB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTTRAFB" as
/* $Header: qlttrafb.plb 115.16 2003/12/21 17:46:48 suramasw ship $ */
-- 1/23/96 - created
-- Paul Mishkin


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
    -- be used to make this into a bind SQL.
    -- This procedure parses out the various columns from the list
    -- into separate tokens.  'NULL' will be substituted if there
    -- is no string in that position.

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


-- helper function for sql parser.  replaces every occurrence of
-- X_OLD_TOKEN, in upper, lower, or mixed case, with X_NEW_TOKEN.
-- Assumes that both tokens are sent in upper case.
FUNCTION REPLACE_TOKEN(	X_STRING VARCHAR2,
			X_OLD_TOKEN VARCHAR2,
			X_NEW_TOKEN VARCHAR2 ) RETURN VARCHAR2 IS
   POS		NUMBER;
   NEW_STRING	VARCHAR2(2500);
   NEW_U_STRING	VARCHAR2(2500);
BEGIN
   NEW_STRING := X_STRING;
   NEW_U_STRING := UPPER(X_STRING);

   LOOP
     POS := INSTR(NEW_U_STRING, X_OLD_TOKEN);
     EXIT WHEN POS = 0;
     NEW_STRING := SUBSTR(NEW_STRING, 1, POS - 1) ||
		   X_NEW_TOKEN ||
		   SUBSTR(NEW_STRING, POS + LENGTH(X_OLD_TOKEN));
     NEW_U_STRING := SUBSTR(NEW_U_STRING, 1, POS - 1) ||
		   X_NEW_TOKEN ||
		   SUBSTR(NEW_U_STRING, POS + LENGTH(X_OLD_TOKEN));
   END LOOP;

   RETURN NEW_STRING;
END;

-- helper function for sql parser.
FUNCTION IS_WHITESPACE(X_CHARACTER VARCHAR2) RETURN BOOLEAN IS
BEGIN
   -- remember to account for null values
   -- space, tab, and newline characters are also whitespace
   IF NVL(X_CHARACTER, 'X') IN (' ', '	', '
') THEN
	RETURN TRUE;
   ELSE
        RETURN FALSE;
   END IF;
END;


-- helper function for sql parser.
-- Return TRUE if input character, x, is alpha numeric.  Assume not null.
-- bso
FUNCTION IS_ALPHANUM(x varchar2) RETURN BOOLEAN IS
BEGIN
    return (x between 'a' and 'z') or (x between 'A' and 'Z') or
           (x between '0' and '9');
END;


-- helper function for sql parser.
-- Return the character at a position N.  The first position is 1.
-- No error checking.
-- bso
FUNCTION CHAR_AT(S VARCHAR2, N NUMBER) RETURN VARCHAR2 IS
BEGIN
    RETURN substr(S, N, 1);
END;


-- helper function for sql parser.
-- This function locates a keyword in a SQL string and
-- returns the position.  The tricky thing is to make sure if
-- the word appears between quotes and between parenthesis,
-- then it is not considered to be a separator, and therefore
-- should not be returned.  This method is a lot more sophisticated
-- then the previous technique of using INSTR to locate the first
-- comma.  The latter will yield a critical error in case there is
-- a comma between quotes or inside a multi-argument function.
--
-- S is the input string
-- KEY is the keyword to be located.
-- ST is the starting position to search (default is 1 = beginning).
--
-- Returns the position of the first comma or 0 if not found.
--
-- bso
FUNCTION FIND_KEYWORD(S VARCHAR2, KEY VARCHAR2, ST NUMBER DEFAULT 1)
RETURN NUMBER IS
   p number;            -- current and final position
   bracket number;      -- state: how many levels of parenthesis
   quote boolean;       -- state: are we in single quote?
   L number;            -- length of the input string
   K number;		-- length of the input keyword
   c varchar2(1);       -- temporary variable
BEGIN
   p := st;
   bracket := 0;
   quote := false;
   L := length(S);
   K := length(key);

   Loop
       if (p > L) then
           return 0;
       end if;
       if (bracket = 0) and (not quote) and (instr(S, key, p) = p) then
           if is_alphanum(char_at(key,1)) then   -- do not use AND
	       -- Found keyword.  (not in quote or brackets)
	       -- But let's make sure it is surrounded by spaces
	       -- unless it is at the beginning of the sentence or at the
	       -- very end.
	       if (p = 1 or is_whitespace(char_at(S, p-1))) and
	          (p+K > L or is_whitespace(char_at(S, p+K))) then
		   return p;
	       end if;
	       -- Do not return if it is not surrounded by spaces.
	   else
	       -- Return if it's not a real keyword, but a punctuation.
	       return p;
	   end if;
       end if;
       c := char_at(S, p);
       if (not quote) and (c = '(') then
           bracket := bracket + 1;
       end if;
       if (not quote) and (c = ')') then
           bracket := bracket - 1;
       end if;
       if (c = '''') then
	   quote := not quote;  -- Amazingly, this will take care of ''
       end if;
       p := p + 1;
   end loop;

   return 0;
END;



-- formats the sql validation string into a usable form
FUNCTION FORMAT_SQL_VALIDATION_STRING (X_STRING VARCHAR2) RETURN VARCHAR2 IS
   ORDER_POS NUMBER;
   NEW_STRING VARCHAR2(2500);
   NEW_U_STRING VARCHAR2(2500);

   COMMA_POS NUMBER;
   FROM_POS NUMBER;
BEGIN
   -- note: this procedure will generally return a string longer than the
   -- input parameter X_STRING.  dimension the variables to account for this.


   -- allow trailing semi-colon and slash.  Bug 956708.
   -- bso
   NEW_STRING := rtrim(X_STRING, ' ;/
');

   -- convert string to all uppercase for searching.
   NEW_U_STRING := UPPER(X_STRING);

   -- remove order by clause from string

   ORDER_POS := INSTR(NEW_U_STRING, 'ORDER BY');
   IF (ORDER_POS <> 0) THEN
      NEW_STRING := SUBSTR(NEW_STRING, 1, ORDER_POS - 1);
   END IF;

   -- check for :parameters
   IF INSTR(NEW_U_STRING, ':PARAMETER') <> 0 THEN
     -- replace :parameter.ord_id and :parameter.user_id
     NEW_STRING := REPLACE_TOKEN(NEW_STRING,
			         ':PARAMETER.ORG_ID',
			         'QRI.ORGANIZATION_ID');

     NEW_STRING := REPLACE_TOKEN(NEW_STRING,
			         ':PARAMETER.USER_ID',
			         'QRI.CREATED_BY');

     -- remove the second column from the query.
     -- search for the end of the first column name or alias
     -- and the from keyword
     --                 <--                <--
     -- select blah code, bleh description from ... where ...
     -- COMMA_POS := INSTR(NEW_U_STRING, ',');
     COMMA_POS := FIND_KEYWORD(NEW_U_STRING, ',');

     FROM_POS := COMMA_POS;
     LOOP
       -- find first occurrence of FROM
       FROM_POS := INSTR(NEW_U_STRING, 'FROM', FROM_POS);
       -- check for whitespace before and after
       EXIT WHEN IS_WHITESPACE(SUBSTR(NEW_U_STRING, FROM_POS - 1, 1))
             AND IS_WHITESPACE(SUBSTR(NEW_U_STRING, FROM_POS + 4, 1));
       -- look for next occurrence of FROM
       FROM_POS := FROM_POS + 4;
     END LOOP;

     NEW_STRING := SUBSTR(NEW_STRING, 1, COMMA_POS - 1)
                   || SUBSTR(NEW_STRING, FROM_POS - 1);

   ELSE
     -- encapsulate query and withdraw the first column
     NEW_STRING := 'SELECT CODE FROM (' ||
		   'SELECT ''1'' CODE, ''1'' DESCRIPTION ' ||
		   'FROM SYS.DUAL WHERE 1=2 ' ||
		   'UNION ALL (' ||
		   NEW_STRING ||
		   ') )';
		   -- Added where code is not null because this subquery
		   -- will be compared with a value using NOT IN, see
		   -- pitfalls of NOT IN in SQL Reference, vol 1.
		   -- bso
                   --
                   -- taken 'where code is not null' away because the
                   -- enclosing SQL has been changed to use NOT EXISTS
                   -- and IN to simulate NOT IN; thus avoiding the
                   -- NOT IN pitfall.  See Bug 682093.
                   -- bso
   END IF;

   RETURN NEW_STRING;
END FORMAT_SQL_VALIDATION_STRING;


FUNCTION VALIDATE_TYPE (X_VALUE VARCHAR2, X_DATATYPE NUMBER) RETURN BOOLEAN IS
BEGIN
   IF (X_DATATYPE = 2) THEN	-- number datatype
      DECLARE
         TEMPNUM NUMBER;
      BEGIN
         TEMPNUM := qltdate.any_to_number(X_VALUE);
         RETURN TRUE;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN FALSE;
      END;
   ELSIF (X_DATATYPE = 3) THEN	-- date datatype
      DECLARE
         TEMPDATE DATE;
      BEGIN
         TEMPDATE := qltdate.any_to_date(X_VALUE);
         RETURN TRUE;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN FALSE;
      END;

   -- For Timezone Compliance bug 3179845. Validate datetime elements.
   -- kabalakr Mon Oct 27 04:33:49 PST 2003.

   ELSIF (X_DATATYPE = 6) THEN  -- date datatype
      DECLARE
         TEMPDATE DATE;
      BEGIN
         TEMPDATE := qltdate.any_to_datetime(X_VALUE);
         RETURN TRUE;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN FALSE;
      END;
   END IF;
END VALIDATE_TYPE;

PROCEDURE EXEC_SQL (STRING IN VARCHAR2) IS
   CUR INTEGER;
   RET INTEGER;
BEGIN
   CUR := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(CUR, STRING, DBMS_SQL.NATIVE);
   RET := DBMS_SQL.EXECUTE(CUR);
   DBMS_SQL.CLOSE_CURSOR(CUR);

exception when others then
   IF dbms_sql.is_open(cur) THEN
       dbms_sql.close_cursor(cur);
   END IF;
   raise;
END EXEC_SQL;

FUNCTION DECODE_ACTION_VALUE_LOOKUP (NUM NUMBER) RETURN VARCHAR2 IS
BEGIN
   IF NUM = 1 THEN
      RETURN 'UPPER_REASONABLE_LIMIT';
   ELSIF NUM = 2 THEN
      RETURN 'UPPER_SPEC_LIMIT';
   ELSIF NUM = 3 THEN
      RETURN 'UPPER_USER_DEFINED_LIMIT';
   ELSIF NUM = 4 THEN
      RETURN 'TARGET_VALUE';
   ELSIF NUM = 5 THEN
      RETURN 'LOWER_USER_DEFINED_LIMIT';
   ELSIF NUM = 6 THEN
      RETURN 'LOWER_SPEC_LIMIT';
   ELSIF NUM = 7 THEN
      RETURN 'LOWER_REASONABLE_LIMIT';
   END IF;
END DECODE_ACTION_VALUE_LOOKUP;

FUNCTION DECODE_OPERATOR (OP NUMBER) RETURN VARCHAR2 IS
BEGIN
   IF OP = 1 THEN
      RETURN '=';
   ELSIF OP = 2 THEN
      RETURN '<>';
   ELSIF OP = 3 THEN
      RETURN '>=';
   ELSIF OP = 4 THEN
      RETURN '<=';
   ELSIF OP = 5 THEN
      RETURN '>';
   ELSIF OP = 6 THEN
      RETURN '<';
   ELSIF OP = 7 THEN
      RETURN 'IS NOT NULL';
   ELSIF OP = 8 THEN
      RETURN 'IS NULL';
   ELSIF OP = 9 THEN
      RETURN 'BETWEEN';
   ELSIF OP = 10 THEN
      RETURN 'NOT BETWEEN';
   END IF;
END DECODE_OPERATOR;

/* validate_disabled
 *
 * writes an error to the errors table for each row in the interface table
 * that has a non-null value for a particular disabled element (col_name).
 * call this procedure only for disabled elements.
 */

PROCEDURE VALIDATE_DISABLED(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER) IS
   SQL_STATEMENT VARCHAR2(2000);
   QUOTED_COL_NAME VARCHAR2(50);
BEGIN
   QUOTED_COL_NAME := '''' || COL_NAME || '''';

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, :ERROR_MESSAGE, ' ||
        'SYSDATE, :USER_ID, SYSDATE, :USER_ID2 , :LAST_UPDATE_LOGIN , ' ||
        ':REQUEST_ID, :PROGRAM_APPLICATION_ID , :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (' ||
                         QUOTED_COL_NAME || ', NULL)) ' ||
                  'AND  EXISTS ' ||
                       '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                       'WHERE QRI.' || COL_NAME || ' IS NOT NULL)';

     EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                           ERROR_MESSAGE,
                                           X_USER_ID,
                                           X_USER_ID,
                                           X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID;

    --QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_DISABLED;

/* validate_mandatory
 *
 * writes an error to the errors table for each row in the interface table
 * that has a null value for a particular mandatory element.  call this
 * procedure only for mandatory elements.
 */

PROCEDURE VALIDATE_MANDATORY(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            PARENT_COL_NAME VARCHAR2,
                            ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, :ERROR_MESSAGE, '||
         'SYSDATE, :USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ';

   IF (PARENT_COL_NAME IS NOT NULL) THEN
      SQL_STATEMENT := SQL_STATEMENT ||
            ' AND QRI.' || PARENT_COL_NAME || ' IS NOT NULL ';
   END IF;

   SQL_STATEMENT := SQL_STATEMENT ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  EXISTS ' ||
                '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                 'WHERE QRI.' || COL_NAME || ' IS NULL)';

    EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                          ERROR_MESSAGE,
                                          X_USER_ID,
                                          X_USER_ID,
                                          X_LAST_UPDATE_LOGIN,
                                          X_REQUEST_ID,
                                          X_PROGRAM_APPLICATION_ID,
                                          X_PROGRAM_ID,
                                          X_GROUP_ID,
                      l_col1, l_col2, l_col3, l_col4, l_col5;

    -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_MANDATORY;


PROCEDURE VALIDATE_LOOKUPS(COL_NAME VARCHAR2,
                          ERROR_COL_NAME VARCHAR2,
                          ERROR_MESSAGE VARCHAR2,
                          X_GROUP_ID NUMBER,
                          X_USER_ID NUMBER,
                          X_LAST_UPDATE_LOGIN NUMBER,
                          X_REQUEST_ID NUMBER,
                          X_PROGRAM_APPLICATION_ID NUMBER,
                          X_PROGRAM_ID NUMBER,
                          X_CHAR_ID NUMBER,
                          X_PLAN_ID NUMBER,
                          ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, :ERROR_MESSAGE, '||
         'SYSDATE, :USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  QRI.' || COL_NAME || ' NOT IN ' ||
             '(SELECT SHORT_CODE FROM QA_PLAN_CHAR_VALUE_LOOKUPS ' ||
             'WHERE PLAN_ID = :PLAN_ID ' ||
             ' AND CHAR_ID = :CHAR_ID ' || ')';

     EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                           ERROR_MESSAGE,
                                           X_USER_ID,
                                           X_USER_ID,
                                           X_LAST_UPDATE_LOGIN,
                                           X_REQUEST_ID,
                                           X_PROGRAM_APPLICATION_ID,
                                           X_PROGRAM_ID,
                                           X_GROUP_ID,
                       l_col1, l_col2, l_col3, l_col4, l_col5,
                                           X_PLAN_ID,
                                           X_CHAR_ID;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_LOOKUPS;


PROCEDURE VALIDATE_PARENT_ENTERED(COL_NAME VARCHAR2,
                            ERROR_COL_NAME VARCHAR2,
                            ERROR_MESSAGE VARCHAR2,
                            X_GROUP_ID NUMBER,
                            X_USER_ID NUMBER,
                            X_LAST_UPDATE_LOGIN NUMBER,
                            X_REQUEST_ID NUMBER,
                            X_PROGRAM_APPLICATION_ID NUMBER,
                            X_PROGRAM_ID NUMBER,
                            PARENT_COL_NAME VARCHAR2,
                            ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   parse_error_columns(error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID,:ERROR_COL_NAME, :ERROR_MESSAGE,' ||
         'SYSDATE, :USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ' ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
         'AND  EXISTS ' ||
              '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                'WHERE QRI.' || COL_NAME || ' IS NOT NULL ' ||
                  'AND QRI.' || PARENT_COL_NAME || ' IS NULL)';

       EXECUTE IMMEDIATE SQL_STATEMENT USING ERROR_COL_NAME,
                                          ERROR_MESSAGE,
                                          X_USER_ID,
                                          X_USER_ID,
                                          X_LAST_UPDATE_LOGIN,
                                          X_REQUEST_ID,
                                          X_PROGRAM_APPLICATION_ID,
                                          X_PROGRAM_ID,
                                          X_GROUP_ID,
                       l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_PARENT_ENTERED;

-- Tracking Bug : 3104827. Review Tracking Bug : 3148873
-- Added for Read Only for Flag Collection Plan Elements
-- saugupta Thu Aug 28 08:59:59 PDT 2003

PROCEDURE VALIDATE_READ_ONLY(P_COL_NAME VARCHAR2,
                            P_ERROR_COL_NAME VARCHAR2,
                            P_ERROR_MESSAGE VARCHAR2,
                            P_GROUP_ID NUMBER,
                            P_USER_ID NUMBER,
                            P_LAST_UPDATE_LOGIN NUMBER,
                            P_REQUEST_ID NUMBER,
                            P_PROGRAM_APPLICATION_ID NUMBER,
                            P_PROGRAM_ID NUMBER,
                            P_PARENT_COL_NAME VARCHAR2,
                            P_ERROR_COL_LIST VARCHAR2) IS
   SQL_STATEMENT VARCHAR2(2000);

   l_col1          VARCHAR2(100);
   l_col2          VARCHAR2(100);
   l_col3          VARCHAR2(100);
   l_col4          VARCHAR2(100);
   l_col5          VARCHAR2(100);

BEGIN

   -- Bug 3136107.
   -- SQL Bind project. Code modified to use bind variables instead of literals
   -- Same as the fix done for Bug 3079312.suramasw.

   parse_error_columns(p_error_col_list, l_col1, l_col2, l_col3, l_col4, l_col5);

   SQL_STATEMENT :=
      'INSERT INTO QA_INTERFACE_ERRORS (TRANSACTION_INTERFACE_ID, ' ||
         'ERROR_COLUMN, ERROR_MESSAGE, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
         'CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, ' ||
         'PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE) ' ||
      'SELECT QRI.TRANSACTION_INTERFACE_ID, :ERROR_COL_NAME, :ERROR_MESSAGE,' ||
         'SYSDATE, :USER_ID, SYSDATE, :USER_ID2, :LAST_UPDATE_LOGIN, ' ||
         ':REQUEST_ID, :PROGRAM_APPLICATION_ID, :PROGRAM_ID, SYSDATE ' ||
        'FROM   QA_RESULTS_INTERFACE QRI ' ||
        'WHERE  QRI.GROUP_ID = :GROUP_ID ' ||
         ' AND  QRI.PROCESS_STATUS = 2 ';

   IF (P_PARENT_COL_NAME IS NOT NULL) THEN
      SQL_STATEMENT := SQL_STATEMENT ||
            ' AND QRI.' || P_PARENT_COL_NAME || ' IS NOT NULL ';
   END IF;

   SQL_STATEMENT := SQL_STATEMENT ||
          'AND  NOT EXISTS
                (SELECT ''X'' ' ||
                'FROM   QA_INTERFACE_ERRORS QIE ' ||
                'WHERE  QIE.TRANSACTION_INTERFACE_ID = ' ||
                             'QRI.TRANSACTION_INTERFACE_ID ' ||
                  'AND  QIE.ERROR_COLUMN IN (:c1,:c2,:c3,:c4,:c5)) ' ||
          'AND  EXISTS ' ||
                '(SELECT ''X'' FROM QA_RESULTS_INTERFACE ' ||
                 'WHERE QRI.' || P_COL_NAME || ' IS NOT NULL)';

    EXECUTE IMMEDIATE SQL_STATEMENT USING P_ERROR_COL_NAME,
                                          P_ERROR_MESSAGE,
                                          P_USER_ID,
                                          P_USER_ID,
                                          P_LAST_UPDATE_LOGIN,
                                          P_REQUEST_ID,
                                          P_PROGRAM_APPLICATION_ID,
                                          P_PROGRAM_ID,
                                          P_GROUP_ID,
                       l_col1, l_col2, l_col3, l_col4, l_col5;

   -- QLTTRAFB.EXEC_SQL(SQL_STATEMENT);
END VALIDATE_READ_ONLY;




END QLTTRAFB;


/

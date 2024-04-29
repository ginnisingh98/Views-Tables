--------------------------------------------------------
--  DDL for Package Body AZ_PROFILEVALUE_CONVERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_PROFILEVALUE_CONVERT_PKG" AS
  /* $Header: azprofcvtb.pls 120.3 2006/02/14 03:37:00 sbandi noship $ */

--
-- SEARCH_SUBSTR
--
FUNCTION SEARCH_SUBSTR ( P_STR IN VARCHAR2, P_SUBSTR IN VARCHAR2 ) RETURN NUMBER IS
  -- local variable, cursor here
  search_position NUMBER:=0;
  idx      NUMBER;
  l_len    NUMBER := 0;
BEGIN
  l_len := LENGTH(P_SUBSTR);
  FOR idx IN 1..( LENGTH(P_STR)+1-l_len ) LOOP
    IF ( SUBSTR(P_STR,idx,l_len) = P_SUBSTR AND search_position = 0 ) THEN
      search_position := idx;
    END IF;
  END LOOP;

  RETURN search_position;
EXCEPTION
  when OTHERS         then return search_position;
END SEARCH_SUBSTR;

--
-- SEARCH_SUBSTR_REVERSE
--
FUNCTION SEARCH_SUBSTR_REVERSE ( P_STR IN VARCHAR2, P_SUBSTR IN VARCHAR2 ) RETURN NUMBER IS
  -- local variable, cursor here
  search_position NUMBER:=0;
  idx      NUMBER;
  idx2     NUMBER;
  l_len    NUMBER := 0;
BEGIN
  l_len := LENGTH(P_SUBSTR);
  FOR idx IN 1..( LENGTH(P_STR)+1-l_len ) LOOP
    idx2 := LENGTH(P_STR)+2-l_len - idx;
    IF ( SUBSTR(P_STR,idx2,l_len) = P_SUBSTR AND search_position = 0 ) THEN
      search_position := idx2;
    END IF;
  END LOOP;

  RETURN search_position;
EXCEPTION
  when OTHERS         then return search_position;
END SEARCH_SUBSTR_REVERSE;



--
-- PARSE_COMMA
--
procedure PARSE_COMMA ( P_STR IN VARCHAR2,
   P_STR1 OUT NOCOPY VARCHAR2,
   P_STR2 OUT NOCOPY VARCHAR2,
   P_STR3 OUT NOCOPY VARCHAR2,
   P_STR4 OUT NOCOPY VARCHAR2 )
IS
  -- loval variable, cursor here
  l_mode   NUMBER := 0;  -- 0: normal, 1: in a quote \"
  idx      NUMBER;
  lastidx  NUMBER := 1;
  cntr     NUMBER := 0;
BEGIN
  P_STR1 := ''; P_STR2 := ''; P_STR3 := ''; P_STR4 := '';

  FOR idx IN 1..( LENGTH(P_STR)-1 ) LOOP
    IF ( SUBSTR(P_STR,idx,2) = '\"' ) THEN
      IF ( l_mode = 0 ) THEN
        l_mode := 1;
      ELSE
        l_mode := 0;
      END IF;
    ELSIF ( SUBSTR(P_STR,idx,1) = ',' ) THEN
      IF ( l_mode = 0 ) THEN
        cntr := cntr + 1;
        IF    ( cntr = 1 ) THEN P_STR1 := SUBSTR(P_STR, lastidx, idx-lastidx);
        ELSIF ( cntr = 2 ) THEN P_STR2 := SUBSTR(P_STR, lastidx, idx-lastidx);
        ELSIF ( cntr = 3 ) THEN P_STR3 := SUBSTR(P_STR, lastidx, idx-lastidx);
        ELSIF ( cntr = 4 ) THEN P_STR4 := SUBSTR(P_STR, lastidx, idx-lastidx);
        END IF;
        lastidx := idx+1;
      END IF;
    END IF;
  END LOOP;

  IF    ( cntr = 1 ) THEN P_STR2 := SUBSTR(P_STR, lastidx);
  ELSIF ( cntr = 2 ) THEN P_STR3 := SUBSTR(P_STR, lastidx);
  ELSIF ( cntr = 3 ) THEN P_STR4 := SUBSTR(P_STR, lastidx);
  END IF;

  P_STR1 := LTRIM(RTRIM(P_STR1));
  P_STR2 := LTRIM(RTRIM(P_STR2));
  P_STR3 := LTRIM(RTRIM(P_STR3));
  P_STR4 := LTRIM(RTRIM(P_STR4));
  RETURN;
EXCEPTION
  when OTHERS         then return;
END PARSE_COMMA;


--
-- GET_NAME_FROM_SHORTCUT
--
FUNCTION GET_NAME_FROM_SHORTCUT (
  STR_FROM       IN VARCHAR2,
  TBL_SHORTCUT   IN VARCHAR2 ) RETURN VARCHAR2 IS

  -- loval variable, cursor here
  TBL1     VARCHAR2(64);
  TBL2     VARCHAR2(64);
  TBL3     VARCHAR2(64);
  TBL4     VARCHAR2(64);
  idx      NUMBER := 0;
BEGIN
  PARSE_COMMA( STR_FROM, TBL1, TBL2, TBL3, TBL4 );
  idx := SEARCH_SUBSTR( TBL1, ' ' );
  IF ( idx > 0 ) THEN
    IF SUBSTR(TBL1,idx+1)=TBL_SHORTCUT THEN RETURN SUBSTR(TBL1,1,idx-1); END IF;
  END IF;
  idx := SEARCH_SUBSTR( TBL2, ' ' );
  IF ( idx > 0 ) THEN
    IF SUBSTR(TBL2,idx+1)=TBL_SHORTCUT THEN RETURN SUBSTR(TBL2,1,idx-1); END IF;
  END IF;
  idx := SEARCH_SUBSTR( TBL3, ' ' );
  IF ( idx > 0 ) THEN
    IF SUBSTR(TBL3,idx+1)=TBL_SHORTCUT THEN RETURN SUBSTR(TBL3,1,idx-1); END IF;
  END IF;
  idx := SEARCH_SUBSTR( TBL4, ' ' );
  IF ( idx > 0 ) THEN
    IF SUBSTR(TBL4,idx+1)=TBL_SHORTCUT THEN RETURN SUBSTR(TBL4,1,idx-1); END IF;
  END IF;
  return STR_FROM;
EXCEPTION
  when OTHERS         then return STR_FROM;
END GET_NAME_FROM_SHORTCUT;

--
-- GET_TABLE_OWNER ( bug 3431739, 3548926 )
--
FUNCTION GET_TABLE_OWNER ( P_TBL_NAME IN VARCHAR2 ) RETURN VARCHAR2 IS
  -- local variable, cursor here
  L_APP_CODE VARCHAR2(64);
BEGIN
  -- bug 3431739
  L_APP_CODE := '';

  BEGIN
    select ou.ORACLE_USERNAME into L_APP_CODE
      from   FND_ORACLE_USERID ou, FND_TABLES t
     where   ou.ORACLE_ID = t.APPLICATION_ID AND t.TABLE_NAME = P_TBL_NAME;
  EXCEPTION
     when OTHERS         then L_APP_CODE := '';
  END;

  -- bug 3548926: When P_TBL_NAME is a table (as above), we do the check for owner.
  --    When P_TBL_NAME is a view (as below), we skip, since we will check for owner = 'APPS'.
/*
  IF ( L_APP_CODE IS NOT NULL AND LENGTH(L_APP_CODE)>0 ) THEN
    return L_APP_CODE;
  END IF;

  BEGIN
    select ou.ORACLE_USERNAME into L_APP_CODE
      from   FND_ORACLE_USERID ou, FND_VIEWS v
     where   ou.ORACLE_ID = v.APPLICATION_ID AND v.VIEW_NAME = P_TBL_NAME;
  EXCEPTION
     when OTHERS         then L_APP_CODE := '';
  END;
*/

  return L_APP_CODE;

EXCEPTION
  when OTHERS         then return L_APP_CODE;
END GET_TABLE_OWNER;


--
-- GET_TABLEVIEW_OWNER ( bug 3431739, 3548926 )
--
FUNCTION GET_TABLEVIEW_OWNER ( P_APP_CODE IN VARCHAR2, P_TBL_TYPE IN VARCHAR2 ) RETURN VARCHAR2 IS
  -- local variable, cursor here
  L_OWNER   VARCHAR2(64);
  l_return  boolean;
  L_STATUS     VARCHAR2(2000);
  L_INDUSTRY   VARCHAR2(2000);
BEGIN
  -- bug 3548926
  L_OWNER := 'APPS';

  IF ( P_TBL_TYPE = 'VIEW' ) THEN
    BEGIN
      select oracle_username into L_OWNER
        from fnd_oracle_userid where read_only_flag = 'U';
    EXCEPTION
       when OTHERS         then L_OWNER := 'APPS';
    END;
  ELSE -- 'TABLE'
    l_return := FND_INSTALLATION.GET_APP_INFO( P_APP_CODE, L_STATUS, L_INDUSTRY, L_OWNER );
    IF ( L_OWNER IS NULL OR LENGTH(L_OWNER)=0 ) THEN
      L_OWNER := P_APP_CODE;
    END IF;
  END IF;

  return  L_OWNER;

EXCEPTION
  when OTHERS         then return L_OWNER;
END GET_TABLEVIEW_OWNER;

--
-- GET_TAB_COL_TYPE
--
FUNCTION GET_TAB_COL_TYPE ( P_TBL_NAME IN VARCHAR2, P_COL_NAME IN VARCHAR2 ) RETURN VARCHAR2 IS
  -- local variable, cursor here
  L_COL_TYPE VARCHAR2(64);
  L_APP_CODE VARCHAR2(64);
  L_OWNER VARCHAR2(64);
BEGIN
  -- bug 3431739
  L_APP_CODE := GET_TABLE_OWNER ( P_TBL_NAME );

  -- bug 3548926: When P_TBL_NAME is a table , we will get a valid L_APP_CODE.
  --    When P_TBL_NAME is a view, we will check for owner = 'APPS' (not hard coded APPS).
  L_COL_TYPE := '';

  IF ( L_APP_CODE IS NULL OR LENGTH(L_APP_CODE)=0 ) THEN
    L_OWNER := GET_TABLEVIEW_OWNER( L_APP_CODE, 'VIEW' );  -- for view, will get 'APPS'
    SELECT DATA_TYPE into L_COL_TYPE
      from   dba_tab_columns
      where  COLUMN_NAME=P_COL_NAME AND TABLE_NAME=P_TBL_NAME AND OWNER=L_OWNER;

    IF ( L_COL_TYPE IS NULL OR LENGTH(L_COL_TYPE)=0 ) THEN
      L_COL_TYPE := '';
    END IF;
  ELSE
    L_OWNER := GET_TABLEVIEW_OWNER( L_APP_CODE, 'TABLE' ); -- for table, get HR, APPLSYS, ...
    SELECT DATA_TYPE into L_COL_TYPE
      from   dba_tab_columns
      where  COLUMN_NAME=P_COL_NAME AND TABLE_NAME=P_TBL_NAME AND OWNER=L_OWNER;

    IF ( L_COL_TYPE IS NULL OR LENGTH(L_COL_TYPE)=0 ) THEN
      L_COL_TYPE := '';
    END IF;
  END IF;

  return L_COL_TYPE;
EXCEPTION
  when OTHERS         then return L_COL_TYPE;
END GET_TAB_COL_TYPE;


--
-- CONVERT
--
FUNCTION CONVERT (
  P_PROFILE_NAME   IN VARCHAR2,
  P_PROFILE_VALUE  IN VARCHAR2,
  P_CONVERT_METHOD IN VARCHAR2
) RETURN VARCHAR2 IS
 -- loval variable, cursor here
 SQL_STR  VARCHAR2(2000);
 TMP_STR  VARCHAR2(2000);  -- This is truly a "tmp" string
 endquote_position NUMBER:=0;
 idx      NUMBER;

 STR_SELECT VARCHAR2(2000);
 STR_INTO   VARCHAR2(2000);
 STR_FROM   VARCHAR2(2000);
 STR_WHERE  VARCHAR2(2000);
 SELECT1 VARCHAR2(256);
 SELECT2 VARCHAR2(256);
 SELECT3 VARCHAR2(256);
 SELECT4 VARCHAR2(256);
 INTO1   VARCHAR2(256);
 INTO2   VARCHAR2(256);
 INTO3   VARCHAR2(256);
 INTO4   VARCHAR2(256);
 SEL_CODE     VARCHAR2(256);
 SEL_DISPLAY  VARCHAR2(256);
 TBL_SHORTCUT VARCHAR2(64);
 TBL_NAME     VARCHAR2(64);
 SEL_COL      VARCHAR2(128);
 SEL_COL_TYPE VARCHAR2(128);

 --v_CursorID   INTEGER;
 v_SelectStmt VARCHAR2(2000);
 v_SelDisplay VARCHAR2(240);
 --v_Dummy      INTEGER;

 type SQL_CSR_TYP is ref CURSOR;
 sql_csr SQL_CSR_TYP;
BEGIN

  select SQL_VALIDATION into SQL_STR
    from   fnd_profile_options
    where  ( PROFILE_OPTION_NAME = P_PROFILE_NAME OR PROFILE_OPTION_NAME = UPPER(P_PROFILE_NAME) );

  IF ( SQL_STR IS NULL OR LENGTH(SQL_STR)=0 ) THEN  -- we have an empty SQL_VALIDATION string
    return P_PROFILE_VALUE;
  END IF;

  SQL_STR := LTRIM( UPPER(SQL_STR) );  -- SQL_STR should be like 'SQL="..."...
  SQL_STR := LTRIM( SUBSTR(SQL_STR,4) );     -- getting rid of 'SQL'
  SQL_STR := LTRIM( SUBSTR(SQL_STR,2) );     -- getting rid of '='.
  SQL_STR := REPLACE( SQL_STR, FND_GLOBAL.LOCAL_CHR(10), ' ' );  -- replacing \n with space

  TMP_STR := LTRIM( SQL_STR );                -- saving a copy in tmp str
  TMP_STR := REPLACE( TMP_STR, '\"', 'TT' );  -- replace \" to anything(doesn't have to be 'TT'), but be of length 2
  FOR idx IN 2..LENGTH(TMP_STR) LOOP
    IF ( SUBSTR(TMP_STR,idx,1) = '"' AND endquote_position = 0 ) THEN
      endquote_position := idx;
    END IF;
  END LOOP;
  IF ( endquote_position=0 ) THEN  -- error, we didn't find the end quote position
    return P_PROFILE_VALUE;
  END IF;
  SQL_STR := SUBSTR( SQL_STR, 2, endquote_position-2 );

  -- as of Jan 27 2003, out of the 3613 profile options, 2262 have a non-empty SQL_VALIDATION string
  -- one has a "GROUP BY" clause, zero has a "HAVING" clause. for the one that has "GROUP BY", I've checked,
  -- no processing is needed.
  idx := SEARCH_SUBSTR( SQL_STR, 'GROUP BY' );   -- SQL_STR is already upper-ed
  IF idx > 0 THEN
    return P_PROFILE_VALUE;
  END IF;
  idx := SEARCH_SUBSTR( SQL_STR, 'HAVING' );   -- SQL_STR is already upper-ed
  IF idx > 0 THEN
    return P_PROFILE_VALUE;
  END IF;
  idx := SEARCH_SUBSTR( SQL_STR, 'ORDER BY' );   -- we don't care about "order by"
  IF idx > 0 THEN
    SQL_STR := RTRIM( SUBSTR(SQL_STR,1,idx-1) );
  END IF;

  -- Now SQL_STR should be of exact format SELECT ... INTO ... FROM ... WHERE ... statement,
  -- Let's parse the hell out of it
  idx := SEARCH_SUBSTR( SQL_STR, ' INTO ' );
  IF idx = 0 THEN
    return P_PROFILE_VALUE;
  END IF;
  STR_SELECT := LTRIM(RTRIM( SUBSTR(SQL_STR, 8, idx-8) ));  -- 8 is the length of "SELECT "+1
  SQL_STR    := SUBSTR(SQL_STR, idx);

  idx := SEARCH_SUBSTR( SQL_STR, ' FROM ' );
  IF idx = 0 THEN
    return P_PROFILE_VALUE;
  END IF;
  STR_INTO := LTRIM(RTRIM( SUBSTR(SQL_STR, 7, idx-7) ));    -- 7 is the length of " INTO "+1
  SQL_STR  := SUBSTR(SQL_STR, idx);

  idx := SEARCH_SUBSTR( SQL_STR, ' WHERE ' );
  IF idx = 0 THEN
    STR_FROM  := LTRIM(RTRIM( SUBSTR(SQL_STR, 7) ));    -- 7 is the length of " FROM "+1
    STR_WHERE := '';
  ELSE
    STR_FROM  := LTRIM(RTRIM( SUBSTR(SQL_STR, 7, idx-7) ));    -- 7 is the length of " FROM "+1
    STR_WHERE := LTRIM(RTRIM( SUBSTR(SQL_STR, idx+7) ));
  END IF;

  -- Now we have STR_SELECT, STR_INTO, STR_FROM and STR_WHERE
  IF ( SEARCH_SUBSTR(STR_SELECT, 'DECODE') > 0 OR SEARCH_SUBSTR(STR_SELECT, 'DISTINCT') > 0 ) THEN
    return P_PROFILE_VALUE;
  END IF;

  PARSE_COMMA( STR_SELECT, SELECT1, SELECT2, SELECT3, SELECT4 );
  PARSE_COMMA( STR_INTO,   INTO1,   INTO2,   INTO3,   INTO4 );
  IF    ( INTO1 = ':PROFILE_OPTION_VALUE' ) THEN SEL_CODE := SELECT1;
  ELSIF ( INTO2 = ':PROFILE_OPTION_VALUE' ) THEN SEL_CODE := SELECT2;
  ELSIF ( INTO3 = ':PROFILE_OPTION_VALUE' ) THEN SEL_CODE := SELECT3;
  ELSIF ( INTO4 = ':PROFILE_OPTION_VALUE' ) THEN SEL_CODE := SELECT4;
  END IF;
  IF    ( INTO1 = ':VISIBLE_OPTION_VALUE' ) THEN SEL_DISPLAY := SELECT1;
  ELSIF ( INTO2 = ':VISIBLE_OPTION_VALUE' ) THEN SEL_DISPLAY := SELECT2;
  ELSIF ( INTO3 = ':VISIBLE_OPTION_VALUE' ) THEN SEL_DISPLAY := SELECT3;
  ELSIF ( INTO4 = ':VISIBLE_OPTION_VALUE' ) THEN SEL_DISPLAY := SELECT4;
  END IF;

  IF ( SEL_CODE IS NULL OR LENGTH(SEL_CODE)=0 OR SEL_DISPLAY IS NULL OR LENGTH(SEL_DISPLAY)=0 ) THEN
    return P_PROFILE_VALUE;
  END IF;
  idx := SEARCH_SUBSTR( SEL_CODE, ' ' );
  IF ( idx > 0 ) THEN SEL_CODE := SUBSTR( SEL_CODE, 1, idx-1 ); END IF;
  idx := SEARCH_SUBSTR( SEL_DISPLAY, ' ' );
  IF ( idx > 0 ) THEN SEL_DISPLAY := SUBSTR( SEL_DISPLAY, 1, idx-1 ); END IF;

  idx := SEARCH_SUBSTR( SEL_CODE, '.' );
  IF ( idx > 0 ) THEN
    TBL_SHORTCUT := SUBSTR( SEL_CODE, 1, idx-1 );
    TBL_NAME     := GET_NAME_FROM_SHORTCUT( STR_FROM, TBL_SHORTCUT );
    SEL_COL      := SUBSTR( SEL_CODE, idx+1 );
  ELSE
    TBL_NAME     := STR_FROM;
    SEL_COL      := SEL_CODE;
  END IF;

  -- we have SEL_COL, and TBL_NAME. check if it is a number
  SEL_COL_TYPE := GET_TAB_COL_TYPE ( TBL_NAME, SEL_COL );

  IF ( SEL_COL_TYPE IS NULL OR SEL_COL_TYPE <> 'NUMBER' ) THEN
    return P_PROFILE_VALUE;
  END IF;

  -- rsekaran commented out
  -- finally, we are sure that SEL_CODE is a NUMBER type
  -- v_CursorID := DBMS_SQL.OPEN_CURSOR;


  IF ( P_CONVERT_METHOD = 'DOWNLOAD' ) THEN

    v_SelectStmt := 'SELECT ' || SEL_DISPLAY || ' FROM ' || STR_FROM || ' WHERE ' || SEL_CODE || ' = ' || P_PROFILE_VALUE;
    IF ( STR_WHERE IS NOT NULL AND LENGTH( LTRIM(RTRIM(STR_WHERE)) ) > 0 ) THEN
      v_SelectStmt := v_SelectStmt || ' AND ' || STR_WHERE;
    END IF;

    -- rsekaran
    -- Use REF CURSOR instead of use of DBMS_SQL package
    /*
    DBMS_SQL.PARSE( v_CursorID, v_SelectStmt, DBMS_SQL.NATIVE );
    DBMS_SQL.DEFINE_COLUMN(v_CursorID, 1, v_SelDisplay, 240 );
    v_Dummy := DBMS_SQL.EXECUTE( v_CursorID );
    */
    OPEN sql_csr FOR v_SelectStmt;
    idx := 0;
    LOOP
      FETCH sql_csr INTO v_SelDisplay;
      EXIT WHEN sql_csr%NOTFOUND;
      --IF DBMS_SQL.FETCH_ROWS( v_CursorID ) = 0 THEN
      --  EXIT;
      --END IF;

      idx := idx + 1;
      --DBMS_SQL.COLUMN_VALUE( v_CursorID, 1, v_SelDisplay );
    END LOOP;
    --DBMS_SQL.CLOSE_CURSOR( v_CursorID );

    CLOSE sql_csr;

    if ( idx = 1 ) THEN
      return v_SelDisplay;
    END IF;

  ELSIF ( P_CONVERT_METHOD = 'UPLOAD' ) THEN

    v_SelectStmt := 'SELECT ' || SEL_CODE || ' FROM ' || STR_FROM || ' WHERE LTRIM(RTRIM(' || SEL_DISPLAY || ')) = '
          || FND_GLOBAL.LOCAL_CHR(39) || LTRIM(RTRIM(P_PROFILE_VALUE)) || FND_GLOBAL.LOCAL_CHR(39);
    IF ( STR_WHERE IS NOT NULL AND LENGTH( LTRIM(RTRIM(STR_WHERE)) ) > 0 ) THEN
      v_SelectStmt := v_SelectStmt || ' AND ' || STR_WHERE;
    END IF;

    /*
    DBMS_SQL.PARSE( v_CursorID, v_SelectStmt, DBMS_SQL.NATIVE );
    DBMS_SQL.DEFINE_COLUMN(v_CursorID, 1, v_SelDisplay, 240 );
    v_Dummy := DBMS_SQL.EXECUTE( v_CursorID );
    */
    OPEN sql_csr FOR v_SelectStmt;
    idx := 0;
    LOOP
      FETCH sql_csr INTO v_SelDisplay;
      EXIT WHEN sql_csr%NOTFOUND;

      --IF DBMS_SQL.FETCH_ROWS( v_CursorID ) = 0 THEN
      --  EXIT;
      --END IF;

      idx := idx + 1;
      --DBMS_SQL.COLUMN_VALUE( v_CursorID, 1, v_SelDisplay );
    END LOOP;
    --DBMS_SQL.CLOSE_CURSOR( v_CursorID );
    CLOSE sql_csr;

    if ( idx = 1 ) THEN
      return v_SelDisplay;
    else
      return NULL;
    END IF;
  END IF;

--  return 'Code:' || SEL_CODE || ', tblname:' || TBL_NAME || ', colname:' || SEL_COL || ', coltype:' || SEL_COL_TYPE;
  return P_PROFILE_VALUE;

EXCEPTION
  when OTHERS         then
  -- rsekaran
  -- Close the cursor if open
  IF (sql_csr%ISOPEN) THEN
     CLOSE sql_csr;
  END IF;

  return P_PROFILE_VALUE;

end CONVERT;


END AZ_PROFILEVALUE_CONVERT_PKG;

/

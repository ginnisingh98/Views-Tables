--------------------------------------------------------
--  DDL for Package Body RG_XFER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_XFER_UTILS_PKG" as
/* $Header: rgixutlb.pls 120.8.12010000.2 2009/09/16 07:11:09 degoel ship $ */

  /* Variables */

  G_UserId      NUMBER;
  G_LoginId     NUMBER;
  G_ApplId      NUMBER;
  G_SourceCOAId NUMBER;
  G_TargetCOAId NUMBER;
  G_LinkName    VARCHAR2(100);

  /* The message level specified by the profile option 'FSG:Message Details' */
  G_MsgLevel    NUMBER;


/* Name:  display_string
 * Desc:  Display a long string LineSize characters at a time. Display the
 *        string only if the message level is 'Full'.
 *
 * History:
 *   02/08/96   S Rahman   Created.
 */
PROCEDURE display_string(
            InputStr VARCHAR2
            ) IS
  InputLen INTEGER;
  CurrPos  INTEGER;
  LineSize INTEGER := 60;
BEGIN
  IF (G_MsgLevel = G_ML_Full) THEN
--    DBMS_OUTPUT.put_line('SQL: Executing:');
    FND_FILE.put_line(FND_FILE.OUTPUT, 'SQL: Executing:');
    CurrPos := 1;
    InputLen := LENGTH(InputStr);
    WHILE (CurrPos <= InputLen) LOOP
      IF (CurrPos + LineSize < InputLen) THEN
--        DBMS_OUTPUT.put_line('> ' || SUBSTR(InputStr, CurrPos, LineSize));
        FND_FILE.put_line(FND_FILE.OUTPUT, '> ' || SUBSTR(InputStr, CurrPos, LineSize));
        CurrPos := CurrPos + LineSize;
      ELSE
--        DBMS_OUTPUT.put_line('> ' || SUBSTR(InputStr, CurrPos));
        FND_FILE.put_line(FND_FILE.OUTPUT, '> ' || SUBSTR(InputStr, CurrPos));
        CurrPos := InputLen + 1;
      END IF;
    END LOOP;
  END IF;
END display_string;


/* Name:  copy_adjust_string
 * Desc:  Copy a string. Adjust the string for single quotes.
 *
 * History:
 *   02/07/96   S Rahman   Created.
 */
PROCEDURE copy_adjust_string(
            TargetStr IN OUT NOCOPY VARCHAR2,
            SourceStr VARCHAR2) IS
  CurrPos   INTEGER;
  TempPos   INTEGER;
  Done      BOOLEAN;
  SourceLen INTEGER;
BEGIN
  TargetStr := '';
  CurrPos := 1;
  SourceLen := LENGTH(SourceStr);
  Done := FALSE;
  WHILE ((NOT Done) AND (CurrPos <= SourceLen)) LOOP
    TempPos := INSTR(SourceStr, '''', CurrPos);
    IF (TempPos <> 0) THEN
      TargetStr := TargetStr ||
                   SUBSTR(SourceStr, CurrPos, TempPos-CurrPos) || '''''';
      CurrPos := TempPos + 1;
    ELSE
      TargetStr := TargetStr || SUBSTR(SourceStr, CurrPos);
      Done := TRUE;
    END IF;
  END LOOP;
END copy_adjust_string;


/* Name:  display_message
 * Desc:  Write a message to the output.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE display_message(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN DEFAULT FALSE,
            Token5      VARCHAR2 DEFAULT NULL,
            Token5Val   VARCHAR2 DEFAULT NULL,
            Token5Xlate BOOLEAN DEFAULT FALSE
            ) IS
  Msg   VARCHAR2(500);
BEGIN
  FND_MESSAGE.set_name('RG', MsgName);
  IF (Token1 IS NOT NULL) THEN
    FND_MESSAGE.set_token(Token1, Token1Val, Token1Xlate);
    IF (Token2 IS NOT NULL) THEN
      FND_MESSAGE.set_token(Token2, Token2Val, Token2Xlate);
      IF (Token3 IS NOT NULL) THEN
        FND_MESSAGE.set_token(Token3, Token3Val, Token3Xlate);
        IF (Token4 IS NOT NULL) THEN
          FND_MESSAGE.set_token(Token4, Token4Val, Token4Xlate);
          IF (Token5 IS NOT NULL) THEN
            FND_MESSAGE.set_token(Token5, Token5Val, Token5Xlate);
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;
  Msg := FND_MESSAGE.get;
--  DBMS_OUTPUT.put_line(Msg);
  FND_FILE.put_line(FND_FILE.OUTPUT, Msg);
END display_message;


/* Name:  display_log
 * Desc:  Write a log message (depending on the message level).
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE display_log(
            MsgLevel    NUMBER,
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN  DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN  DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN  DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN  DEFAULT FALSE
            ) IS
BEGIN
  IF (MsgLevel <= G_MsgLevel) THEN
    display_message(
      MsgName,
      Token1, Token1Val, Token1Xlate,
      Token2, Token2Val, Token2Xlate,
      Token3, Token3Val, Token3Xlate,
      Token4, Token4Val, Token4Xlate);
  END IF;
END display_log;


/* Name:  display_error
 * Desc:  Write a error message.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE display_error(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN DEFAULT FALSE
            ) IS
BEGIN
  FoundError := TRUE;
  display_message(
    MsgName,
    Token1, Token1Val, Token1Xlate,
    Token2, Token2Val, Token2Xlate,
    Token3, Token3Val, Token3Xlate);
END display_error;


/* Name:  display_warning
 * Desc:  Write a warning message.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE display_warning(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN DEFAULT FALSE
            ) IS
BEGIN
  FoundWarning := TRUE;
  display_message(
    MsgName,
    Token1, Token1Val, Token1Xlate,
    Token2, Token2Val, Token2Xlate,
    Token3, Token3Val, Token3Xlate,
    Token4, Token4Val, Token4Xlate);
END display_warning;


/* Name:  display_exception
 * Desc:  Display exception information
 *
 * History:
 *   03/08/96   S Rahman   Created.
 */
PROCEDURE display_exception(
            ErrorNum    NUMBER,
            ErrorMsg    VARCHAR2
            ) IS
BEGIN
  display_log(
    MsgLevel  => G_ML_Full,
    MsgName   => 'RG_XFER_L_EXCEPTION',
    Token1    => 'ERROR_NUM',
    Token1Val => TO_CHAR(ErrorNum));
  display_string(ErrorMsg);
END display_exception;


/* Name:  init
 * Desc:  Initialize variable used by RG_XFER_* package routines.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE init(
            SourceCOAId NUMBER,
            TargetCOAId NUMBER,
            LinkName    VARCHAR2) IS
  ProfileUserId   VARCHAR2(20);
  ProfileLoginId  VARCHAR2(20);
  ProfileMsgLevel VARCHAR2(20) := NULL;
BEGIN
  /* Set the values to be used for who columns from profile options. */
  /* Bug8909490 : Changed FND_PROFILE to FND_GLOBAL */
  /* FND_PROFILE.get('USER_ID', ProfileUserId);
     FND_PROFILE.get('CONC_LOGIN_ID', ProfileLoginId);
     G_UserId := to_number(ProfileUserId);
     G_LoginId := to_number(ProfileLoginId); */

     G_UserId := FND_GLOBAL.user_id;
     G_LoginId := FND_GLOBAL.conc_login_id;

  G_ApplId := 101;

  /* Get message level from profile option and set local variable */
  FND_PROFILE.get('RG_LOGFILE_DETAIL_LEVEL', ProfileMsgLevel);
  IF (ProfileMsgLevel IS NOT NULL) THEN
    G_MsgLevel := to_number(ProfileMsgLevel);
  ELSE
    /* Profile option not set. Set to default the message level */
    G_MsgLevel := G_ML_Minimal;
  END IF;

  /* Initialize passed parameters. */
  G_SourceCOAId := SourceCOAId;
  G_TargetCOAId := TargetCOAId;
  G_LinkName    := LinkName;

  /* Iniitialize the PRIVATE package */
  RG_XFER_COMPONENTS_PKG.init(SourceCOAId, TargetCOAId, LinkName, G_ApplId);
END init;


FUNCTION ping_link(LinkName VARCHAR2) RETURN BOOLEAN IS
  CursorId INTEGER;
  ExecuteValue INTEGER;
BEGIN
  -- select using the database link
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'SELECT 1 FROM DUAL@'|| LinkName,
                 DBMS_SQL.v7);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  DBMS_SQL.close_cursor(CursorId);
  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(FALSE);
END ping_link;


FUNCTION create_link(LinkName VARCHAR2,
                     Username VARCHAR2,
                     Password VARCHAR2,
                     ConnectString VARCHAR2) RETURN NUMBER IS
  CursorId INTEGER;
  ExecuteValue INTEGER;

  CURSOR GetLink(LinkName VARCHAR2) IS
    SELECT *
    FROM user_db_links
    WHERE UPPER(db_link) = UPPER(LinkName);
  LinkRow user_db_links%ROWTYPE;

  RetVal NUMBER;
  TempVal BOOLEAN;

  link_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(link_exists, -2011);

  insufficient_priv EXCEPTION;
  PRAGMA EXCEPTION_INIT(insufficient_priv, -1031);

BEGIN
  -- create the database link
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'CREATE DATABASE LINK '|| LinkName ||
                 ' CONNECT TO '|| Username ||' IDENTIFIED BY '|| Password ||
                 ' USING '''|| ConnectString ||'''',
                 DBMS_SQL.v7);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  DBMS_SQL.close_cursor(CursorId);
  IF NOT ping_link(LinkName) THEN
    /* Try to drop the link; ignore return value */
    TempVal := drop_link(LinkName);
    RETURN(0);
  END IF;
  RETURN(1);
EXCEPTION
  WHEN link_exists THEN
    OPEN GetLink(LinkName);
    FETCH GetLink INTO LinkRow;
    IF ((UPPER(LinkRow.username) = UPPER(Username)) AND
        (UPPER(LinkRow.password) = UPPER(Password)) AND
        (UPPER(LinkRow.host) = UPPER(ConnectString))) THEN
      RetVal := 1;
    ELSE
      RetVal := 0;
    END IF;
    CLOSE GetLink;
    RETURN(RetVal);
  WHEN insufficient_priv THEN
    RETURN(1031);
  WHEN OTHERS THEN
    RETURN(0);
END create_link;


FUNCTION drop_link(LinkName VARCHAR2) RETURN BOOLEAN IS
  CursorId INTEGER;
  ExecuteValue INTEGER;
  link_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(link_not_found, -2024);
BEGIN
  -- drop the database link
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId,
                 'DROP DATABASE LINK '|| LinkName,
                 DBMS_SQL.v7);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  DBMS_SQL.close_cursor(CursorId);
  RETURN(TRUE);
EXCEPTION
  WHEN link_not_found THEN
    RETURN(FALSE);
  WHEN OTHERS THEN
    RETURN(FALSE);
END drop_link;


/* Name:  insert_into_list
 * Desc:  Insert the passed name into the PL/SQL table and update the count.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE insert_into_list(
            ListName IN OUT NOCOPY ListType,
            ListCount IN OUT NOCOPY BINARY_INTEGER,
            Name VARCHAR2) IS
BEGIN
  ListName(ListCount) := Name;
  ListCount := ListCount + 1;
END insert_into_list;


/* Name:  search_list
 * Desc:  Search the PL/SQL table for the name, and return the index if the
 *        name is found. If the name is not found then return error code.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION search_list(
           ListName ListType,
           ListCount BINARY_INTEGER,
           Name VARCHAR2) RETURN BINARY_INTEGER IS
  i BINARY_INTEGER := 0;
BEGIN
  /* Scan the list */
  WHILE (i < ListCount) LOOP
    BEGIN
      /* Search for the name */
      EXIT WHEN (ListName(i) = Name);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    /* Try the next entry in the list */
    i := i + 1;
  END LOOP;

  /* Check if the name was found */
  IF (i >= ListCount) THEN
    i := G_Error;
  END IF;

  /* Return the index, or error code */
  RETURN(i);
END search_list;


/* Name:  get_source_id
 * Desc:  Get the id from the source database for the specified component.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION get_source_id(
           TableName VARCHAR2,
           IdName VARCHAR2,
           CompName VARCHAR2,
           WhereClause VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  Id            NUMBER;
  SQLString     VARCHAR2(200);
  ComponentName VARCHAR2(60);
BEGIN
  copy_adjust_string(ComponentName, CompName);
  SQLString := 'SELECT ' || IdName || ' FROM ' || TableName||'@'||G_LinkName ||
               ' WHERE name = ''' || ComponentName || ''' ' || WhereClause;
  display_string(SQLString);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  DBMS_SQL.column_value(CursorId, 1, Id);
  DBMS_SQL.close_cursor(CursorId);
  RETURN(Id);
END get_source_id;


/* Name:  get_new_id
 * Desc:  Get a new id from the sequence in the target database.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION get_new_id(SequenceName VARCHAR2) RETURN NUMBER IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  Id           NUMBER;
  SQLString    VARCHAR2(100);
BEGIN
  SQLString := 'SELECT ' || SequenceName || '.nextval FROM sys.dual';
  display_string(SQLString);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  DBMS_SQL.column_value(CursorId, 1, Id);
  DBMS_SQL.close_cursor(CursorId);
  RETURN(Id);
END get_new_id;


/* Name:  get_source_ref_object_name
 * Desc:  Get the name of a sub-component given the component information.
 *        For example, this routine is used to obtain the row set name
 *        from the report id (both in the source database).
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION get_source_ref_object_name(
           MainTableName VARCHAR2,
           RefTableName  VARCHAR2,
           ColumnName    VARCHAR2,
           ColumnValue   VARCHAR2,
           MainIdName    VARCHAR2,
           RefIdName     VARCHAR2,
           CharColumn    BOOLEAN DEFAULT TRUE) RETURN VARCHAR2 IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  RefObjectName VARCHAR2(30);
  ValueString   VARCHAR2(60);
  SQLString     VARCHAR2(500);
  TempValue     VARCHAR2(100);
BEGIN
  /* If the column value is of type char, then append the quotes to it */
  IF (CharColumn) THEN
    copy_adjust_string(TempValue, ColumnValue);
    ValueString := '''' || TempValue || '''';
  ELSE
    ValueString := ColumnValue;
  END IF;

  SQLString := 'SELECT ref_table.name '||
               'FROM '||MainTableName||'@'||G_LinkName||' main_table,' ||
               RefTableName || '@'|| G_LinkName || ' ref_table ' ||
               'WHERE main_table.'||ColumnName || '='|| ValueString ||
               ' AND main_table.'||MainIdName || '= ref_table.'||RefIdName;
  IF (MainTableName = 'RG_REPORTS') THEN
    SQLString := SQLString ||
                 ' AND main_table.application_id = '|| TO_CHAR(G_ApplId);
  END IF;

  display_string(SQLString);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, RefObjectName, 30);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    DBMS_SQL.column_value(CursorId, 1, RefObjectName);
  ELSE
    RefObjectName := '';
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RefObjectName);
END get_source_ref_object_name;


/* Name:  get_target_id_from_source_id
 * Desc:  Get the id in the target database given the id in the source
 *        database. For example, this routine get the budget id in the
 *        target database given the budget id in the source database.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE get_target_id_from_source_id(
            TableName    VARCHAR2,
            NameColumn   VARCHAR2,
            IdColumnName VARCHAR2,
            IdValue      IN OUT NOCOPY NUMBER,
            IdName       IN OUT NOCOPY VARCHAR2) IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  Id           NUMBER;
  SourceIdName VARCHAR2(100);
  SQLString    VARCHAR2(500);
BEGIN
  SQLString := 'SELECT t.'|| IdColumnName || ', l.' || NameColumn ||
               ' FROM '|| TableName || ' t,' ||
                          TableName || '@' || G_LinkName ||' l' ||
               ' WHERE l.'|| IdColumnName || '=' || TO_CHAR(IdValue) ||
               ' AND l.' || NameColumn || '= t.' || NameColumn;
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  DBMS_SQL.define_column(CursorId, 2, SourceIdName, 100);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    DBMS_SQL.column_value(CursorId, 1, Id);
    DBMS_SQL.column_value(CursorId, 2, SourceIdName);
  ELSE
    Id := G_Error;

    /* Get the parameter name from the source database table since it doesn't
     * exist in the target database table */
    DBMS_SQL.close_cursor(CursorId);

    SQLString := 'SELECT ' || NameColumn ||
                 ' FROM ' || TableName||'@'||G_LinkName ||
                 ' WHERE '|| IdColumnName || '=' || TO_CHAR(IdValue);
    display_string(SQLString);

    CursorId := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
    DBMS_SQL.define_column(CursorId, 1, SourceIdName, 100);
    ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
    IF (ExecuteValue > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, SourceIdName);
    ELSE
      SourceIdName := NULL;
    END IF;

  END IF;
  DBMS_SQL.close_cursor(CursorId);
  IdValue := Id;
  IdName := SourceIdName;
END get_target_id_from_source_id;


/* Name:  get_target_ldg_from_source_ldg
 * Desc:  Get the ledger id in the target database given the ledger id
 *        and ledger currency in the source database.
 *
 * History:
 *   03/31/03   T Cheng    Created.
 */
PROCEDURE get_target_ldg_from_source_ldg(
            LedgerId       IN OUT NOCOPY NUMBER,
            LedgerName     IN OUT NOCOPY VARCHAR2,
            LedgerCurrency IN OUT NOCOPY VARCHAR2) IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  Id           NUMBER;
  SourceIdName VARCHAR2(100);
  SQLString    VARCHAR2(500);
BEGIN
  IF (LedgerCurrency IS NULL) THEN
    get_target_id_from_source_id('GL_LEDGERS',
                                 'NAME',
                                 'LEDGER_ID',
                                 LedgerId,
                                 LedgerName);
    LedgerCurrency := 'NULL';
    RETURN;
  END IF;

  SQLString := 'SELECT t.TARGET_LEDGER_ID, l.TARGET_LEDGER_NAME ' ||
               'FROM   GL_LEDGER_RELATIONSHIPS t, GL_LEDGER_RELATIONSHIPS@' ||
                                                  G_LinkName || ' l ' ||
               'WHERE  l.TARGET_LEDGER_ID = ' || TO_CHAR(LedgerId) ||
               ' AND   l.TARGET_CURRENCY_CODE = ''' || LedgerCurrency ||
               ''' AND   l.TARGET_LEDGER_NAME = t.TARGET_LEDGER_NAME';
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  DBMS_SQL.define_column(CursorId, 2, SourceIdName, 100);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    DBMS_SQL.column_value(CursorId, 1, Id);
    DBMS_SQL.column_value(CursorId, 2, SourceIdName);
    LedgerCurrency := '''' || LedgerCurrency || '''';
  ELSE
    Id := G_Error;

    /* Get the parameter name from the source database table since it doesn't
     * exist in the target database table */
    DBMS_SQL.close_cursor(CursorId);

    SQLString := 'SELECT TARGET_LEDGER_NAME ' ||
                 'FROM   GL_LEDGER_RELATIONSHIPS@' || G_LinkName ||
                 ' WHERE TARGET_LEDGER_ID = ' || TO_CHAR(LedgerId) ||
                 ' AND   TARGET_CURRENCY_CODE = ''' || LedgerCurrency || '''';

    display_string(SQLString);

    CursorId := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
    DBMS_SQL.define_column(CursorId, 1, SourceIdName, 100);
    ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
    IF (ExecuteValue > 0) THEN
      DBMS_SQL.column_value(CursorId, 1, SourceIdName);
    ELSE
      SourceIdName := NULL;
    END IF;

    LedgerCurrency := 'NULL';
  END IF;
  DBMS_SQL.close_cursor(CursorId);

  LedgerId := Id;
  LedgerName := SourceIdName;
END get_target_ldg_from_source_ldg;


/* Name:  insert_rows
 * Desc:  Insert rows using the provided SQL statement. Binds variable as
 *        necessary.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE insert_rows(
            SQLStmt VARCHAR2,
            Id NUMBER,
            UseCOAId BOOLEAN DEFAULT FALSE,
            UseRowId BOOLEAN DEFAULT FALSE,
            RecRowId ROWID   DEFAULT NULL) IS
  CursorId INTEGER;
  ExecuteValue INTEGER;
BEGIN
  display_string(SQLStmt);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLStmt, DBMS_SQL.v7);
  DBMS_SQL.bind_variable(CursorId, ':id', Id);
  DBMS_SQL.bind_variable(CursorId, ':user_id', G_UserId);
  DBMS_SQL.bind_variable(CursorId, ':login_id', G_LoginId);
  IF (UseCOAId) THEN
    DBMS_SQL.bind_variable(CursorId, ':coa_id', G_TargetCOAId);
  END IF;
  IF (UseRowId) THEN
    DBMS_SQL.bind_variable(CursorId, ':row_id', RecRowId);
  END IF;
  ExecuteValue := DBMS_SQL.execute(CursorId);
  DBMS_SQL.close_cursor(CursorId);
END insert_rows;


/* Name:  execute_sql_statement
 * Desc:  The name says it all.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE execute_sql_statement(SQLStmt VARCHAR2) IS
  CursorId INTEGER;
  ExecuteValue INTEGER;
BEGIN
  display_string(SQLStmt);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLStmt, DBMS_SQL.v7);
  ExecuteValue := DBMS_SQL.execute(CursorId);
  DBMS_SQL.close_cursor(CursorId);
END execute_sql_statement;


/* Name:  check_coa_id
 * Desc:  Check if the chart of accounts id specified and the chart of
 *        accounts id for the component matches.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION check_coa_id(
           TableName   VARCHAR2,
           CompName    VARCHAR2,
           WhereString VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  COAId         NUMBER;
  RetVal        NUMBER := G_NoError;
  ComponentName VARCHAR2(60);
  SQLString     VARCHAR2(2000);
BEGIN
  copy_adjust_string(ComponentName, CompName);
  SQLString := 'SELECT structure_id FROM ' || TableName || '@' || G_LinkName||
               ' WHERE name = ''' || ComponentName ||'''' ||
               NVL(WhereString,' AND application_id = ' || TO_CHAR(G_ApplId));
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, COAId);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  DBMS_SQL.column_value(CursorId, 1, COAId);
  IF (COAId IS NULL) THEN
    RetVal := G_NoCOA;
  ELSIF (COAId <> G_SourceCOAId) THEN
    RetVal := G_Error;
    display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_WRONG_SRC_COA',
      Token1    => 'SRC_ID',
      Token1Val => TO_CHAR(COAId),
      Token2    => 'SUB_SRC_ID',
      Token2Val => TO_CHAR(G_SourceCOAId));
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END check_coa_id;


/* Name:  check_target_coa_id
 * Desc:  Check if the chart of accounts id specified and the chart of
 *        accounts id for the component matches.
 *
 * History:
 *   08/08/96   S Rahman   Created.
 */
FUNCTION check_target_coa_id(
           TableName   VARCHAR2,
           CompName    VARCHAR2,
           WhereString VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  COAId         NUMBER;
  RetVal        NUMBER := G_NoError;
  ComponentName VARCHAR2(60);
  SQLString     VARCHAR2(200);
BEGIN
  copy_adjust_string(ComponentName, CompName);
  SQLString := 'SELECT structure_id FROM ' || TableName ||
               ' WHERE name = ''' || ComponentName ||'''' ||
               NVL(WhereString,' AND application_id = ' || TO_CHAR(G_ApplId));
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, COAId);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  DBMS_SQL.column_value(CursorId, 1, COAId);
  IF (COAId IS NULL) THEN
    RetVal := G_NoCOA;
  ELSIF (COAId <> G_TargetCOAId) THEN
    RetVal := G_Error;
    display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_TARGET_COA_MISMATCH',
      Token1    => 'TARGET_ID',
      Token1Val => TO_CHAR(COAId),
      Token2    => 'SUB_TARGET_ID',
      Token2Val => TO_CHAR(G_TargetCOAId));
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END check_target_coa_id;


/* Name:  substitute_tokens
 * Desc:  Substitute values for tokens.
 *
 * Notes: The tokens must appear in the order passed to this routine.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
PROCEDURE substitute_tokens(
            InputStr  IN OUT NOCOPY VARCHAR2,
            Token1    VARCHAR2 DEFAULT NULL,
            Token1Val VARCHAR2 DEFAULT NULL,
            Token2    VARCHAR2 DEFAULT NULL,
            Token2Val VARCHAR2 DEFAULT NULL,
            Token3    VARCHAR2 DEFAULT NULL,
            Token3Val VARCHAR2 DEFAULT NULL,
            Token4    VARCHAR2 DEFAULT NULL,
            Token4Val VARCHAR2 DEFAULT NULL,
            Token5    VARCHAR2 DEFAULT NULL,
            Token5Val VARCHAR2 DEFAULT NULL,
            Token6    VARCHAR2 DEFAULT NULL,
            Token6Val VARCHAR2 DEFAULT NULL,
            Token7    VARCHAR2 DEFAULT NULL,
            Token7Val VARCHAR2 DEFAULT NULL,
            Token8    VARCHAR2 DEFAULT NULL,
            Token8Val VARCHAR2 DEFAULT NULL,
            Token9    VARCHAR2 DEFAULT NULL,
            Token9Val VARCHAR2 DEFAULT NULL) IS
  SubsStr VARCHAR2(12000);
  CurrPos INTEGER;
  TempPos INTEGER;
BEGIN
  SubsStr := '';
  CurrPos := 1;
  IF (Token1 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token1, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token1Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token1);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token1);
    END IF;
  END IF;
  IF (Token2 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token2, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token2Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token2);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token2);
    END IF;
  END IF;
  IF (Token3 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token3, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token3Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token3);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token3);
    END IF;
  END IF;
  IF (Token4 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token4, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token4Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token4);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token4);
    END IF;
  END IF;
  IF (Token5 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token5, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token5Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token5);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token5);
    END IF;
  END IF;
  IF (Token6 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token6, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token6Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token6);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token6);
    END IF;
  END IF;
  IF (Token7 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token7, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token7Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token7);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token7);
    END IF;
  END IF;
  IF (Token8 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token8, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token8Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token8);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token8);
    END IF;
  END IF;
  IF (Token9 IS NOT NULL) THEN
    TempPos := INSTR(InputStr, Token9, CurrPos);
    IF (TempPos <> 0) THEN
      SubsStr := SubsStr || SUBSTR(InputStr, CurrPos, TempPos-CurrPos) ||
                 NVL(Token9Val, 'NULL');
      CurrPos := TempPos + LENGTH(Token9);
    ELSE
      display_log(
        MsgLevel  => G_ML_Full,
        MsgName   => 'RG_XFER_L_INVALID',
        Token1    => 'VALUE',
        Token1Val => Token9);
    END IF;
  END IF;
  SubsStr := SubsStr || SUBSTR(InputStr, CurrPos);
  InputStr := SubsStr;
END substitute_tokens;


/* Name:  source_component_exists
 * Desc:  Check if the specified component exists in the source database.
 *        Return TRUE if it exists, otherwise return FALSE.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION source_component_exists(
           ComponentType VARCHAR2,
           CompName VARCHAR2) RETURN BOOLEAN IS
  CursorId      INTEGER;
  ExecuteValue  INTEGER;
  DummyId       NUMBER;
  RetVal        BOOLEAN := FALSE;
  ComponentName VARCHAR2(60);
  SQLString     VARCHAR2(200) := 'SELECT 1 FROM ';
BEGIN
  copy_adjust_string(ComponentName, CompName);

  /* Construct SQL string */
  IF (ComponentType = 'RG_ROW_SET') THEN
    SQLString := SQLString || 'RG_REPORT_AXIS_SETS@' || G_LinkName ||
                 ' WHERE axis_set_type = ''R''' ||
                 ' AND   application_id = ' || TO_CHAR(G_ApplId);
  ELSIF (ComponentType = 'RG_COLUMN_SET') THEN
    SQLString := SQLString || 'RG_REPORT_AXIS_SETS@' || G_LinkName ||
                 ' WHERE axis_set_type = ''C''' ||
                 ' AND   ((application_id = 168)' ||
                 '     OR (application_id = ' || TO_CHAR(G_ApplId) || '))';
  ELSIF (ComponentType = 'RG_CONTENT_SET') THEN
    SQLString := SQLString || 'RG_REPORT_CONTENT_SETS@' || G_LinkName ||
                 ' WHERE application_id = ' || TO_CHAR(G_ApplId);
  ELSIF (ComponentType = 'RG_ROW_ORDER') THEN
    SQLString := SQLString || 'RG_ROW_ORDERS@' || G_LinkName ||
                 ' WHERE application_id = ' || TO_CHAR(G_ApplId);
  ELSIF (ComponentType = 'RG_DISPLAY_SET') THEN
    SQLString := SQLString || 'RG_REPORT_DISPLAY_SETS@' || G_LinkName ||
                 ' WHERE 1 = 1';
  ELSIF (ComponentType = 'RG_DISPLAY_GROUP') THEN
    SQLString := SQLString || 'RG_REPORT_DISPLAY_GROUPS@' || G_LinkName ||
                 ' WHERE 1 = 1';
  ELSIF (ComponentType = 'RG_REPORT') THEN
    SQLString := SQLString || 'RG_REPORTS@' || G_LinkName ||
                 ' WHERE application_id = ' || TO_CHAR(G_ApplId);
  ELSIF (ComponentType = 'RG_REPORT_SET') THEN
    SQLString := SQLString || 'RG_REPORT_SETS@' || G_LinkName ||
                 ' WHERE application_id = ' || TO_CHAR(G_ApplId);
  ELSE
    display_log(
      MsgLevel  => G_ML_Full,
      MsgName   => 'RG_XFER_L_INVALID',
      Token1    => 'VALUE',
      Token1Val => ComponentType);
  END IF;
  SQLString := SQLString || ' AND name = ''' || ComponentName || '''';
  display_string(SQLString);

  /* Execute the constructed string and return value */
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, DummyId);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    /* Found matching component */
    RetVal := TRUE;
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END source_component_exists;


/* Name:  component_exists
 * Desc:  Check if a component exists in the target database.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION component_exists(SelectString VARCHAR2) RETURN NUMBER IS
  CursorId INTEGER;
  ExecuteValue INTEGER;
  Id NUMBER;
BEGIN
  display_string(SelectString);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SelectString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    DBMS_SQL.column_value(CursorId, 1, Id);
  ELSE
    Id := G_Error;
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(Id);
END component_exists;


/* Name:  currency_exists
 * Desc:  Check if a currency exists in the target database.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION currency_exists(CurrencyCode VARCHAR2) RETURN BOOLEAN IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  RetVal       BOOLEAN;
  Id           NUMBER;
  SQLString    VARCHAR2(500);
BEGIN
  SQLString := 'SELECT 1 FROM fnd_currencies' ||
               ' WHERE currency_code = ''' || CurrencyCode || '''';
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    RetVal := TRUE;
  ELSE
    RetVal := FALSE;
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END currency_exists;


/* Name:  ro_column_exists
 * Desc:  Check if a column specified in a row order exists in the target db.
 *
 * History:
 *   03/08/96   S Rahman   Created.
 */
FUNCTION ro_column_exists(ColumnName VARCHAR2) RETURN BOOLEAN IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  RetVal       BOOLEAN;
  Id           NUMBER;
  SQLString    VARCHAR2(3000);
  AdjustedName VARCHAR2(60);
BEGIN
  copy_adjust_string(AdjustedName, ColumnName);
  SQLString := 'SELECT 1 FROM sys.dual WHERE EXISTS ' ||
               '(SELECT 1 FROM rg_report_axes ax, rg_report_axis_sets axs'||
               ' WHERE axs.application_id+0 in ('||TO_CHAR(G_ApplId)||',168)'||
               ' AND   axs.axis_set_type = ''C'''||
               ' AND   ax.axis_set_id = DECODE(axs.axis_set_type, ''C'',' ||
                                       ' axs.axis_set_id, axs.axis_set_id)' ||
               ' AND   ax.axis_name  = '''||AdjustedName||''')';
  display_string(SQLString);

  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, Id);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    RetVal := TRUE;
  ELSE
    RetVal := FALSE;
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END ro_column_exists;


/* Name:  token_from_id
 * Desc:  Get the token value from the specified id.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION token_from_id(Id NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF ((Id = G_Error) OR (Id = G_Warning) OR (Id IS NULL)) THEN
    RETURN('NULL');
  ELSE
    RETURN(TO_CHAR(Id));
  END IF;
END token_from_id;


/* Name:  get_varchar2
 * Desc:  Get the varchar2 column value using the specified SQL statement.
 *
 * History:
 *   10/17/95   S Rahman   Created.
 */
FUNCTION get_varchar2(
           SQLString  VARCHAR2,
           ColumnSize NUMBER) RETURN VARCHAR2 IS
  CursorId     INTEGER;
  ExecuteValue INTEGER;
  RetVal       VARCHAR2(1000) := NULL;
  Id           NUMBER;
BEGIN
  display_string(SQLString);
  CursorId := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(CursorId, SQLString, DBMS_SQL.v7);
  DBMS_SQL.define_column(CursorId, 1, RetVal, ColumnSize);
  ExecuteValue := DBMS_SQL.execute_and_fetch(CursorId);
  IF (ExecuteValue > 0) THEN
    DBMS_SQL.column_value(CursorId, 1, RetVal);
  END IF;
  DBMS_SQL.close_cursor(CursorId);
  RETURN(RetVal);
END get_varchar2;


BEGIN
  /* Initialize variables on package access. */

  /* Error and warning status */
  FoundError := FALSE;
  FoundWarning := FALSE;

  /* Error Codes */
  G_Error := -1;
  G_Warning := -2;
  G_NoCOA := -3;
  G_NoError := -4;

  /* Define the message levels */
  G_ML_Minimal := 1;
  G_ML_Normal := 2;
  G_ML_Full := 3;

END RG_XFER_UTILS_PKG;

/

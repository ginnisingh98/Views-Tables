--------------------------------------------------------
--  DDL for Package Body FND_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AUDIT_PKG" AS
/* $Header: FNDAUDTB.pls 120.7 2006/11/10 00:00:21 tshort noship $ */
  PROCEDURE RETRIEVE_RESULT_TABLES(AUDIT_WHERE_CLAUSE   VARCHAR2,
                                  TABLE_WHERE_CLAUSE   VARCHAR2,
                                  QUERY_TABLES IN OUT NOCOPY AUDIT_REQUIRED_TABLES_TYPE)   AS

 cursor l_check_from_clause(p_table_name varchar2) is
             /* TSHORT 4890086 - needed for optional query in find */
             select from_clause, where_clause
             from fnd_audit_disp_cols, fnd_tables
             where table_name = p_table_name and
             fnd_tables.table_id = fnd_audit_disp_cols.table_id;

     TYPE RETRIEVE_DATA IS REF CURSOR;
     AUDIT_TABLE        RETRIEVE_DATA;  -- declare cursor variable
     TABLE_DATA         RETRIEVE_DATA;  -- declare cursor variable
     audit_sql_stmt     VARCHAR2(4000);
     table_sql_stmt     VARCHAR2(4000);
     disp_from_clause   VARCHAR2(2000); -- find with optional query
     disp_where_clause  VARCHAR2(2000); -- find with optional query
     AUDIT_TABLE_REC    AUDIT_REQUIRED_TABLE;
     i                  INTEGER := 1;
     j                  INTEGER := 1;
     DATA_EXISTS_FLAG   INTEGER := null;
     shadow_table_exists  number;
  BEGIN
      audit_sql_stmt := ' select distinct FND_TABLES.TABLE_NAME   TABLE_NAME ,
                                FND_TABLES.USER_TABLE_NAME   USER_TABLE_NAME ,
                                FND_TABLES.TABLE_ID     TABLE_ID ,
                                FND_TABLES.APPLICATION_ID   TABLE_APPLICATION_ID
                from  FND_AUDIT_GROUPS ,
                      FND_AUDIT_TMPLT_DTL ,
                      FND_AUDIT_TABLES    ,
                      FND_TABLES
                WHERE FND_AUDIT_TMPLT_DTL.AUDIT_GROUP_ID  = FND_AUDIT_GROUPS.AUDIT_GROUP_ID
                  AND FND_AUDIT_TMPLT_DTL.APPLICATION_ID  = FND_AUDIT_GROUPS.APPLICATION_ID
                  AND FND_AUDIT_GROUPS.APPLICATION_ID     = FND_AUDIT_TABLES.AUDIT_GROUP_APP_ID
                  AND FND_AUDIT_GROUPS.AUDIT_GROUP_ID     = FND_AUDIT_TABLES.AUDIT_GROUP_ID
                  AND FND_AUDIT_TABLES.TABLE_ID           = FND_TABLES.TABLE_ID
                  AND FND_AUDIT_TABLES.TABLE_APP_ID       = FND_TABLES.APPLICATION_ID
                  AND FND_AUDIT_GROUPS.STATE              in (''E'',''G'',''N'')
                  AND FND_AUDIT_TABLES.STATE              in (''E'',''G'',''N'')
                  AND '|| AUDIT_WHERE_CLAUSE;
      OPEN AUDIT_TABLE FOR audit_sql_stmt;
      LOOP
        FETCH AUDIT_TABLE INTO AUDIT_TABLE_REC;
        EXIT WHEN AUDIT_TABLE%NOTFOUND;
        BEGIN
          SELECT 1 into shadow_table_exists
          FROM tab
          where tname like substrb(AUDIT_TABLE_REC.TABLE_NAME,1,24)||'_AC1';
          IF TABLE_WHERE_CLAUSE IS NULL THEN
            QUERY_TABLES(i).TABLE_NAME        := AUDIT_TABLE_REC.TABLE_NAME;
            QUERY_TABLES(i).USER_TABLE_NAME   := AUDIT_TABLE_REC.USER_TABLE_NAME;
            QUERY_TABLES(i).TABLE_ID          := AUDIT_TABLE_REC.TABLE_ID;
            QUERY_TABLES(i).TABLE_APPLICATION_ID    := AUDIT_TABLE_REC.TABLE_APPLICATION_ID;
            i:=i+1;
          ELSE
	     /* TSHORT 4890086 - needed for optional query in find */
	     open l_check_from_clause(AUDIT_TABLE_REC.TABLE_NAME);
	     fetch l_check_from_clause into disp_from_clause, disp_where_clause;
	if (l_check_from_clause%found) then
	     if disp_from_clause is not null then
		disp_from_clause := ', ' || disp_from_clause;
	     end if;
	     if disp_where_clause is not null then
		disp_where_clause := 'and ('||disp_where_clause||')';
	     end if;
	end if;
             /* TSHORT 4890086 */
             /* changed from _A to _AC1 so current records would show */
             table_sql_stmt := '  SELECT 1 DATA_EXISTS_FLAG  '||
                             '   FROM '||substrb(AUDIT_TABLE_REC.TABLE_NAME,1,24)||'_AC1  ' || disp_from_clause ||
                             '   WHERE ' || TABLE_WHERE_CLAUSE || disp_where_clause;
             OPEN TABLE_DATA FOR table_sql_stmt;
             LOOP
               FETCH TABLE_DATA INTO DATA_EXISTS_FLAG;
               IF TABLE_DATA%FOUND THEN
                 QUERY_TABLES(i).TABLE_NAME        := AUDIT_TABLE_REC.TABLE_NAME;
                 QUERY_TABLES(i).USER_TABLE_NAME   := AUDIT_TABLE_REC.USER_TABLE_NAME;
                 QUERY_TABLES(i).TABLE_ID          := AUDIT_TABLE_REC.TABLE_ID;
                 QUERY_TABLES(i).TABLE_APPLICATION_ID := AUDIT_TABLE_REC.TABLE_APPLICATION_ID;
                 i:=i+1;
               END IF;
               EXIT;
             END LOOP;
             CLOSE  TABLE_DATA;
	     CLOSE  L_CHECK_FROM_CLAUSE;
           END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN
           null;
         END;
      END LOOP;
      CLOSE AUDIT_TABLE;
  END RETRIEVE_RESULT_TABLES;


/*********************************************************************************************
*******                                                                                *******
*******                                                                                *******
**********************************************************************************************/


  PROCEDURE POPULATE_TAB_REP_DATA(P_SELECT_CLAUSE   VARCHAR2,
                                  P_TABLE_NAME      VARCHAR2,
                                  P_USER_TABLE_NAME VARCHAR2,
                                  P_WHERE_CLAUSE    VARCHAR2,
                                  P_APPLICATION_ID  NUMBER,
                                  P_TABLE_ID        NUMBER,
                                  P_REP_ID          NUMBER) IS

   -- Local Variables

     TYPE RETRIEVE_DATA IS REF CURSOR;
     DISP_COL_VALUE          RETRIEVE_DATA;  -- declare cursor variable
     AUDIT_DATA              RETRIEVE_DATA;  -- declare cursor variable
     AUDIT_DATA_REC          REPORT_TABLE;
     PREV_AUDIT_KEY          VARCHAR2(240);
     user_column_list        VARCHAR2(4000) := null;
     pk_column_list          VARCHAR2(4000) := null;
     l_where_clause          VARCHAR2(4000) := null;
     col_flag                number :=0;
     j                       NUMBER:=1;
     i                       NUMBER:=1;
     l_tab_position          number;
     l_comma_position        number;
     table_alias             VARCHAR2(40);
     parse_text1             VARCHAR2(80);
     parse_text2             VARCHAR2(80);
     parsed_text             VARCHAR2(80);
     remaining_text          VARCHAR2(2000);
     missing_base_table_flag number := 0;
     l_cursor_id             INTEGER;
     l_dummy                 INTEGER;
     id                      VARCHAR2(2000);
     disp_col_val            VARCHAR2(2000);
     disp_val                VARCHAR2(2000);
     data_select_stmt        VARCHAR2(4000) := null;
     v_select_stmt        VARCHAR2(4000) := null;
     v_select_stmt1       VARCHAR2(4000) := null;


  --  cursor Variables

    CURSOR GET_USER_KEY_COLUMNS IS
      SELECT COL_DISP_IND ,
         SELECT_CLAUSE,
         FROM_CLAUSE,
         WHERE_CLAUSE
      FROM FND_AUDIT_DISP_COLS
      WHERE APPLICATION_ID = P_APPLICATION_ID
        AND TABLE_ID       = P_TABLE_ID;

     User_key_columns_rec GET_USER_KEY_COLUMNS%ROWTYPE;

     CURSOR GET_SYSTEM_KEY_COLS IS
       SELECT fnd_cols.column_name column_name
       FROM FND_COLUMNS fnd_cols,
            FND_PRIMARY_KEYS pks,
            FND_PRIMARY_KEY_COLUMNS keycols
       WHERE pks.application_id     = keycols.application_id
         AND pks.table_id           = keycols.table_id
         AND pks.primary_key_id     = keycols.primary_key_id
         AND keycols.application_id = fnd_cols.application_id
         AND keycols.table_id       = fnd_cols.table_id
         AND keycols.column_id      = fnd_cols.column_id
         AND pks.table_id           = P_TABLE_ID
         AND pks.application_id     = P_APPLICATION_ID
         AND pks.audit_key_flag     = 'Y';

     SYSTEM_KEY_COLS_REC     GET_SYSTEM_KEY_COLS%ROWTYPE;

  BEGIN
    OPEN GET_USER_KEY_COLUMNS;
    FETCH GET_USER_KEY_COLUMNS INTO User_key_columns_rec;
    CLOSE GET_USER_KEY_COLUMNS;
    remaining_text := ltrim(rtrim(User_key_columns_rec.FROM_CLAUSE));
    i:= 0;
    IF remaining_text IS NOT NULL THEN
      LOOP
        l_comma_position := instrb(remaining_text,',',1,1);
        IF l_comma_position <> 0 THEN
          parse_text1 := rtrim(ltrim(substrb(remaining_text,1,l_comma_position -1 )));
          remaining_text := rtrim(ltrim(substrb(remaining_text,l_comma_position + 1)));
        ELSE
          parse_text1 := rtrim(ltrim(remaining_text));
          remaining_text := null;
        END IF;
        parse_text2 := rtrim(ltrim(substrb(parse_text1,1,instrb(parse_text1,' ',1,1))));
        IF parse_text2 is null THEN
           IF upper(parse_text1) = upper(p_table_name) THEN
             table_alias := parse_text1;
             EXIT;
           END IF;
        ELSE
           IF upper(parse_text2) = upper(p_table_name) THEN
             table_alias := rtrim(ltrim(substrb(parse_text1,instrb(parse_text1,' ',1,1))));
             EXIT;
           END IF;
        END IF ;
        IF remaining_text IS NULL THEN
           missing_base_table_flag := 1;
           table_alias := null;
           EXIT;
        END IF;
      END LOOP;
      if table_alias IS NOT NULL THEN
         table_alias := table_alias || '.';
      ELSE
         missing_base_table_flag := 1;
         table_alias := p_table_name || '.';
      end if;
    ELSE
--      missing_base_table_flag := 1;
      table_alias := p_table_name || '.';
    END IF;
    OPEN GET_SYSTEM_KEY_COLS;
    LOOP
      FETCH GET_SYSTEM_KEY_COLS into SYSTEM_KEY_COLS_REC;
      EXIT WHEN  GET_SYSTEM_KEY_COLS%NOTFOUND;
      IF pk_column_list IS NULL THEN
        pk_column_list := table_alias||SYSTEM_KEY_COLS_REC.column_name;
        l_where_clause := SYSTEM_KEY_COLS_REC.column_name;
      ELSE
        pk_column_list := pk_column_list||','||table_alias||SYSTEM_KEY_COLS_REC.column_name;
        l_where_clause := l_where_clause ||','||SYSTEM_KEY_COLS_REC.column_name;
      END IF;
    END LOOP;
    pk_column_list := ltrim(replace(pk_column_list,',','||'||''''||','||''''||'||'));
    l_where_clause := ltrim(replace(l_where_clause,',','||'||''''||','||''''||'||'));
    IF missing_base_table_flag = 0 AND User_key_columns_rec.select_clause IS NOT NULL THEN
      user_column_list := replace(User_key_columns_rec.select_clause,',','||'||''''||','||''''||'||');
      v_select_stmt := ' SELECT '||pk_column_list || ' ID, '||
                         user_column_list || ' disp_val  ' ;
      IF User_key_columns_rec.from_clause is not null THEN
        v_select_stmt := v_select_stmt || '  FROM ' ||User_key_columns_rec.FROM_CLAUSE;
      ELSE
        v_select_stmt := v_select_stmt ||  '  FROM  '|| p_table_name;
      END IF;
      IF User_key_columns_rec.where_clause IS not NULL THEN
        v_select_stmt := v_select_stmt ||
                        '   WHERE '||User_key_columns_rec.where_clause;
      ELSE
        v_select_stmt := v_select_stmt ||
                      '   WHERE 1=1  ';
      END IF;
    ELSE
      v_select_stmt := ' SELECT '||pk_column_list || ' ID, '||
                         pk_column_list || ' disp_val  ' ||
                      '  FROM  '|| p_table_name  ||
                      '  WHERE 1=1  ';
    END IF;
    /******
      Retrieve Data from AC1 View then lookup for display column value
     ******/

     data_select_stmt :=   ' SELECT '||l_where_clause || '  AUDIT_KEY,AUDIT_TIMESTAMP,AUDIT_TRANSACTION_TYPE,AUDIT_USER_NAME,'
                         || P_SELECT_CLAUSE
                         || ' FROM '||substrb(P_TABLE_NAME,1,24)||'_AC1'
                         || ' WHERE '|| P_WHERE_CLAUSE
                         || ' order by '||l_where_clause;
     OPEN AUDIT_DATA FOR data_select_stmt;
     LOOP
       FETCH AUDIT_DATA INTO AUDIT_DATA_REC;
       EXIT WHEN AUDIT_DATA%NOTFOUND;
       IF PREV_AUDIT_KEY IS NULL  OR
          PREV_AUDIT_KEY <> AUDIT_DATA_REC.AUDIT_KEY  THEN
          /* 4364301 TSHORT - changed to use bind variables */
          v_select_stmt1 := v_select_stmt || ' AND '||pk_column_list ||' = :auditkey';
          OPEN DISP_COL_VALUE FOR v_select_stmt1 USING AUDIT_DATA_REC.AUDIT_KEY;
          /* end 4364301 change */
          FETCH DISP_COL_VALUE INTO id,disp_val;
          IF DISP_COL_VALUE%NOTFOUND THEN
            disp_val := AUDIT_DATA_REC.AUDIT_KEY;
          END IF;
          CLOSE DISP_COL_VALUE;
          PREV_AUDIT_KEY := AUDIT_DATA_REC.AUDIT_KEY ;
       END IF;
       INSERT INTO FND_AUDIT_REP_DTL(REP_ID
                                 ,TABLE_NAME
                                 ,AUDIT_KEY
                                 ,AUDIT_TIMESTAMP
                                 ,AUDIT_TRANSACTION_TYPE
                                 ,AUDIT_USER_NAME
                                 ,COLUMN1_VALUE
                                 ,COLUMN2_VALUE
                                 ,COLUMN3_VALUE
                                 ,COLUMN4_VALUE
                                 ,COLUMN5_VALUE
                                 ,ROW_DISP_COL)
                 VALUES
                           (P_REP_ID
                           ,P_TABLE_NAME
                           ,substrb(AUDIT_DATA_REC.AUDIT_KEY,1,240)
                           ,AUDIT_DATA_REC.AUDIT_TIMESTAMP
                           ,AUDIT_DATA_REC.AUDIT_TRANSACTION_TYPE
                           ,AUDIT_DATA_REC.AUDIT_USER_NAME
                           ,substrb(AUDIT_DATA_REC.COLUMN1_VALUE,1,240)
                           ,substrb(AUDIT_DATA_REC.COLUMN2_VALUE,1,240)
                           ,substrb(AUDIT_DATA_REC.COLUMN3_VALUE,1,240)
                           ,substrb(AUDIT_DATA_REC.COLUMN4_VALUE,1,240)
                           ,substrb(AUDIT_DATA_REC.COLUMN5_VALUE,1,240)
                           ,substrb(DISP_VAL,1,240));
     END LOOP;
     CLOSE AUDIT_DATA;
  END;
END;



/

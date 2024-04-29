--------------------------------------------------------
--  DDL for Package Body BSC_SYS_DIMTABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_DIMTABLES_PKG" as
/* $Header: BSCSDIMB.pls 115.2 2003/01/14 22:50:48 meastmon ship $ */


PROCEDURE ADD_LANGUAGE
IS
    h_sql VARCHAR2(32000);

    CURSOR c_dim_tables IS
        SELECT level_table_name
        FROM bsc_sys_dim_levels_b
        WHERE nvl(edw_flag, 0) = 0 AND
              nvl(source, 'BSC') = 'BSC';

   h_dim_table VARCHAR2(30);

   CURSOR c_columns IS
       SELECT column_name
       FROM all_tab_columns
       WHERE table_name = UPPER(h_dim_table) AND
             owner = UPPER(BSC_APPS.BSC_APPS_SCHEMA);

   h_column_name VARCHAR2(30);
   h_lst_insert VARCHAR2(32000);
   h_lst_select VARCHAR2(32000);

BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Add language in each dimension table
    OPEN c_dim_tables;
    FETCH c_dim_tables INTO h_dim_table;
    WHILE c_dim_tables%FOUND LOOP
        h_sql := 'UPDATE '||h_dim_table||' T'||
                 ' SET NAME = ('||
                 '   SELECT B.NAME'||
                 '   FROM '||h_dim_table||' B'||
                 '   WHERE B.CODE = T.CODE AND'||
                 '         B.LANGUAGE = T.SOURCE_LANG'||
                 ' )'||
                 ' WHERE (T.CODE, T.LANGUAGE) IN ('||
                 '   SELECT SUBT.CODE, SUBT.LANGUAGE'||
                 '   FROM '||h_dim_table||' SUBB, '||h_dim_table||' SUBT'||
                 '   WHERE SUBB.CODE = SUBT.CODE AND'||
                 '         SUBB.LANGUAGE = SUBT.SOURCE_LANG AND'||
                 '         SUBB.NAME <> SUBT.NAME'||
                 '   )';
        EXECUTE IMMEDIATE h_sql;

        h_lst_insert := NULL;
        h_lst_select := NULL;

        OPEN c_columns;
        FETCH c_columns INTO h_column_name;
        WHILE c_columns%FOUND LOOP
            IF h_lst_insert IS NOT NULL THEN
                h_lst_insert := h_lst_insert||', ';
                h_lst_select := h_lst_select||', ';
            END IF;

            h_lst_insert := h_lst_insert||h_column_name;

            IF h_column_name = 'LANGUAGE' THEN
                h_lst_select := h_lst_select||'L.LANGUAGE_CODE';
            ELSE
                h_lst_select := h_lst_select||'B.'||h_column_name;
            END IF;

            FETCH c_columns INTO h_column_name;
        END LOOP;
        CLOSE c_columns;

        h_sql := 'INSERT INTO '||h_dim_table||' ('||h_lst_insert||')'||
                 ' SELECT '||h_lst_select||
                 ' FROM '||h_dim_table||' B, FND_LANGUAGES L'||
                 ' WHERE L.INSTALLED_FLAG IN (''I'', ''B'') AND'||
                 '       B.LANGUAGE = USERENV(''LANG'') AND'||
                 '       NOT EXISTS ('||
                 '         SELECT NULL'||
                 '         FROM '||h_dim_table||' T'||
                 '         WHERE T.CODE = B.CODE AND'||
                 '               T.LANGUAGE = L.LANGUAGE_CODE'||
                 '       )';
        EXECUTE IMMEDIATE h_sql;

        FETCH c_dim_tables INTO h_dim_table;
    END LOOP;
    CLOSE c_dim_tables;

END ADD_LANGUAGE;


END BSC_SYS_DIMTABLES_PKG;

/

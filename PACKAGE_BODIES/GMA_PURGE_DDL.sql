--------------------------------------------------------
--  DDL for Package Body GMA_PURGE_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_PURGE_DDL" AS
/* $Header: GMAPRGDB.pls 120.1.12010000.2 2008/11/11 20:56:38 srpuri ship $ */

  FUNCTION altertableconstraint
                          (p_purge_id   sy_purg_mst.purge_id%TYPE,
                           p_owner      user_users.username%TYPE,
                           p_appl_short_name fnd_application.application_short_name%TYPE,
                           p_tablename  user_tables.table_name%TYPE,
                           p_constraint_name user_constraints.constraint_name%TYPE,
                           p_disable    BOOLEAN,
                           p_debug_flag BOOLEAN)
                   RETURN BOOLEAN;

  /**********************************************************/

  FUNCTION createarctable(p_purge_id     sy_purg_mst.purge_id%TYPE,
                          p_tablename    user_tables.table_name%TYPE,
                          p_tablespace   user_tablespaces.tablespace_name%TYPE,
                          p_owner        user_users.username%TYPE,
                          p_appl_short_name fnd_application.application_short_name%TYPE,
                          p_sizing_flag  BOOLEAN,
                          p_arctablename user_tables.table_name%TYPE,
                          p_debug_flag   BOOLEAN)
                          RETURN         BOOLEAN IS
  -- create archive table in database from named database table

    l_newtablename user_tables.table_name%TYPE;
                            -- holds name of new table to be created
    l_objectexists EXCEPTION;       -- table already exists
    l_badtable     EXCEPTION;       -- table wasn't created
    l_rowcount     NUMBER;          -- the number of rows in a table

    l_sqlstatement sy_purg_def.sqlstatement%TYPE;
    l_cursor       INTEGER;
    l_dummy        NUMBER;

    l_bytes        NUMBER;   -- size of new table in blocks

    l_trans_allowed NUMBER := 5;

    PRAGMA EXCEPTION_INIT(l_objectexists,-955);

    l_storage_clause sy_purg_def.sqlstatement%TYPE;

  BEGIN

    -- create new table name and create statement
    l_newtablename := GMA_PURGE_UTILITIES.makearcname(p_purge_id,p_tablename);
    l_cursor := DBMS_SQL.OPEN_CURSOR;

    -- coalesce the tablespace
    GMA_PURGE_DDL.coalescetablespace(p_purge_id,
                                   p_tablespace,
                                   p_debug_flag);

    -- set up storage clause if so asked
    l_storage_clause := NULL;
    IF (p_sizing_flag = TRUE) THEN
      l_sqlstatement := 'SELECT COUNT(DISTINCT ' ||
                        p_tablename ||
                        ') FROM ' ||p_owner||'.'||
                        p_arctablename;

      GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_sqlstatement,p_debug_flag);

      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.DEFINE_COLUMN(l_cursor,1,l_rowcount);
      l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor);
      DBMS_SQL.COLUMN_VALUE(l_cursor,1,l_rowcount);

      l_bytes := GMA_PURGE_DDL.tab_size(p_purge_id,
                                        p_tablename,
                                        l_rowcount,
                                        l_trans_allowed,
                                        0); -- p_pctfree

      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'The ' ||
                            p_tablename ||
                            ' table will need ' ||
                            to_char(l_bytes) ||
                            ' bytes of storage for ' ||
                            to_char(l_rowcount) ||
                            ' rows.');

      l_storage_clause := ' STORAGE ( INITIAL ' || to_char(l_bytes) ||
                          ' MINEXTENTS 1 ' ||
                          ' PCTINCREASE 0)';

    END IF;

    -- create table
    l_sqlstatement := 'CREATE TABLE ' || p_owner || '.' || l_newtablename
                       || ' TABLESPACE ' || p_tablespace ||
                         ' PCTFREE  0 ' ||
                          'PCTUSED 60' ||
                          ' INITRANS ' || to_char(l_trans_allowed) ||
                          ' MAXTRANS ' || to_char(l_trans_allowed) ||
                       l_storage_clause
                       || ' AS SELECT * ' || 'FROM ' || p_tablename ||
                       ' WHERE ROWNUM < 1';

    GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_sqlstatement,p_debug_flag);

    -- let fly with dynamic sql
    DECLARE
      l_extent_size   EXCEPTION;
      PRAGMA EXCEPTION_INIT(l_extent_size,-1658);
    BEGIN
-- Made by Khaja
--      IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
 --       AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.CREATE_TABLE,
  --                    l_sqlstatement,l_newtablename);
   --   ELSE
        DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
--      END IF;

    EXCEPTION
      WHEN l_extent_size THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Not enough contiguous space in tablespace for table.');
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Using unspecified table creation.');
        l_sqlstatement := 'CREATE TABLE ' || p_owner || '.' || l_newtablename
                           || ' TABLESPACE ' || p_tablespace ||
                         ' PCTFREE  0 ' ||
                          'PCTUSED 60' ||
                          ' INITRANS ' || to_char(l_trans_allowed) ||
                          ' MAXTRANS ' || to_char(l_trans_allowed) ||
                        ' AS SELECT * ' || 'FROM ' || p_tablename ||
                       ' WHERE ROWNUM < 1';
--        IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
--         AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.CREATE_TABLE,
--                        l_sqlstatement,l_newtablename);
--        ELSE
          DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
--       END IF;
      WHEN OTHERS THEN
        RAISE;
    END;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    GMA_PURGE_UTILITIES.printlong(p_purge_id,l_newtablename || ' table created.');

    -- make sure table got created
    IF GMA_PURGE_VALIDATE.is_table(p_purge_id,l_newtablename) <> TRUE THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem Can''''t create table ' || l_newtablename);
      RAISE l_badtable;
    ELSE
      RETURN TRUE;
    END IF;

  EXCEPTION

    WHEN l_objectexists THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem with arc row table - ' || l_newtablename ||
        ' exists.');
      RETURN NULL;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.createarctable with '
           || p_tablename);
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END createarctable;


  /***********************************************************/

  PROCEDURE droparctable(p_purge_id  sy_purg_mst.purge_id%TYPE,
                         p_owner     user_users.username%TYPE,
                         p_appl_short_name fnd_application.application_short_name%TYPE,
                         p_tablename user_tables.table_name%TYPE) IS
                -- drop named table from database

    l_sqlstatement sy_purg_def.sqlstatement%TYPE;
    l_cursor       INTEGER;

  BEGIN

    l_sqlstatement := 'DROP TABLE '||p_owner||'.'||GMA_PURGE_UTILITIES.makearcname(p_purge_id,   --Bug#6681753
                                                               p_tablename);

    -- Made comments by Khaja
    -- let fly with dynamic sql
--    IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
--      AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.DROP_TABLE,
--                    l_sqlstatement,GMA_PURGE_UTILITIES.makearcname(p_purge_id,
--                                                                   p_tablename));
--    ELSE
      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
--    END IF;
    GMA_PURGE_UTILITIES.printlong(p_purge_id,p_owner||'.'||GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                             p_tablename)
                          || ' table dropped.');

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.droparctable.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END droparctable;

  /***********************************************************/

  PROCEDURE createarcviews(p_purge_id   sy_purg_mst.purge_id%TYPE,
                           p_purge_type sy_purg_def.purge_type%TYPE,
                           p_owner      user_users.username%TYPE,
                           p_appl_short_name fnd_application.application_short_name%TYPE,
                           p_debug_flag BOOLEAN) IS
                -- create views of archive tables

 /*   CURSOR l_viewtables_cur(cp_purge_type sy_purg_def.purge_type%TYPE) IS
      SELECT table_name
      FROM   sy_purg_def_act
      WHERE  purge_type = cp_purge_type;
      l_tablename  user_tables.table_name%TYPE;

    CURSOR l_arctables_cur(cp_tablename user_tables.table_name%TYPE) IS
      SELECT table_name
      ,      owner
      FROM   all_tables
      WHERE  SUBSTR(table_name,8)   = cp_tablename
      AND    SUBSTR(table_name,7,1) = '_'
      AND    SUBSTR(table_name,6,1) IN
               ('1','2','3','4','5','6','7','8','9','0')
      AND    SUBSTR(table_name,5,1) IN
               ('1','2','3','4','5','6','7','8','9','0')
      AND    SUBSTR(table_name,4,1) IN
               ('1','2','3','4','5','6','7','8','9','0')
      AND    SUBSTR(table_name,3,1) IN
               ('1','2','3','4','5','6','7','8','9','0')
      AND    SUBSTR(table_name,2,1) IN
               ('1','2','3','4','5','6','7','8','9','0')
      AND    SUBSTR(table_name,1,1) = 'A'
      AND    owner='GMA';

      l_tables INTEGER;
      l_return INTEGER;
      l_owner  user_users.username%TYPE;

      l_sqlstatement sy_purg_def.sqlstatement%TYPE;
      l_cursor       INTEGER;

      l_noobject EXCEPTION;
      PRAGMA EXCEPTION_INIT(l_noobject,-942);
      l_viewname all_tables.table_name%type;
*/

  BEGIN

    -- we are going to create or freshen the view for all of the tables in this
    -- purge type definition

/*    l_cursor := DBMS_SQL.OPEN_CURSOR;

    FOR l_viewtable IN l_viewtables_cur(p_purge_type) LOOP
      l_tables    := 0;

      -- this is a workaround for an apparent bug with 'CREATE OR REPLACE VIEW'
      BEGIN
        l_sqlstatement := 'DROP VIEW '
                                       || 'A'|| l_viewtable.table_name;
--        IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
--          AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.DROP_VIEW,
--                        l_sqlstatement,'A' || l_viewtable.table_name);
--        ELSE
          DBMS_SQL.PARSE(l_cursor,l_sqlstatement, DBMS_SQL.NATIVE);
          l_return := DBMS_SQL.EXECUTE(l_cursor);
--        END IF;
      EXCEPTION
        WHEN l_noobject THEN
          NULL;
        WHEN OTHERS THEN
          RAISE;
      END;

     -- l_sqlstatement := 'CREATE VIEW ' || p_owner
      l_sqlstatement := 'CREATE VIEW '
                                  || 'A' || l_viewtable.table_name || ' AS ';

      -- get names of individual tables for view
      FOR l_arctable IN l_arctables_cur(l_viewtable.table_name) LOOP
        l_owner     := l_arctable.owner;
        l_sqlstatement := l_sqlstatement
                           || 'SELECT * FROM ' || l_owner
                           || '.' || l_arctable.table_name;
        l_sqlstatement := l_sqlstatement || ' UNION ';
        l_tables := l_tables + 1;
      END LOOP;

      -- create a stub based on the production table if no archive tables
      -- exist or to make the last 'UNION' work out right
                      --     || 'SELECT * FROM ' ||p_owner
      l_sqlstatement := l_sqlstatement
                           || 'SELECT * FROM ' ||
                           l_viewtable.table_name || ' WHERE ROWNUM < 1';

      GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_sqlstatement,p_debug_flag);

      l_viewname :=l_viewtable.table_name;

--      IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
--        AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.CREATE_VIEW,
--                      l_sqlstatement,'A' || l_viewtable.table_name);
--      ELSE
        DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
        l_return := DBMS_SQL.EXECUTE(l_cursor);
--      END IF;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'A' || l_viewtable.table_name || ' view created.');

    END LOOP;  -- each table

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION

    WHEN OTHERS THEN
      IF SQLCODE=-01789 THEN
--  This code is added to ignore the view creation if query has no of columns mismatch ORA-01789
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Warning: '||'A'||l_viewname||' View cannot get replaced (column mismatch)');
      ELSE

      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.createarcviews.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || SQLERRM);
      RAISE;
      END IF;
*/
     null;

  END createarcviews;

  /***********************************************************/

  FUNCTION altertableconstraint
                          (p_purge_id   sy_purg_mst.purge_id%TYPE,
                           p_owner      user_users.username%TYPE,
                           p_appl_short_name fnd_application.application_short_name%TYPE,
                           p_tablename  user_tables.table_name%TYPE,
                           p_constraint_name user_constraints.constraint_name%TYPE,
                           p_disable    BOOLEAN,
                           p_debug_flag BOOLEAN)
                   RETURN BOOLEAN IS

    l_sqlstatement VARCHAR2(100);
    l_cursor       INTEGER;

  BEGIN

    l_sqlstatement := 'ALTER TABLE ' || p_tablename || ' ';

    IF (p_disable = TRUE) THEN
      l_sqlstatement := l_sqlstatement || 'DISABLE';
    ELSE
      l_sqlstatement := l_sqlstatement || 'ENABLE';
    END IF;

    l_sqlstatement := l_sqlstatement || ' CONSTRAINT ' || p_constraint_name;

    GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_sqlstatement,p_debug_flag);

    IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
      AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.ALTER_TABLE,
                    l_sqlstatement,p_tablename);
    ELSE
      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN
      IF (p_debug_flag = TRUE) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Raised in GMA_PURGE_DDL.altertableconstraint.');
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Ignored EXCEPTION - ' || SQLERRM);
      END IF;
      RETURN FALSE;

  END;

  /***********************************************************/

  PROCEDURE alterconstraints
                     (p_purge_id                    sy_purg_mst.purge_id%TYPE,
                      p_tablenames_tab              g_tablename_tab_type,
                      p_tableactions_tab            g_tableaction_tab_type,
                      p_tablecount                  INTEGER,
                      p_idx_tablespace_tab   IN OUT NOCOPY g_tablespace_name_tab_type,
                      p_idx_tablespace_count IN OUT NOCOPY INTEGER,
                      p_owner                        user_users.username%TYPE,
                      p_appl_short_name              fnd_application.application_short_name%TYPE,
                      p_action                       VARCHAR2,
                      p_debug_flag                   BOOLEAN) IS
  -- disable or enable all constraints for named table

CURSOR l_tablename_cur(P_purge_id sy_purg_mst.purge_id%TYPE) IS
       SELECT table_name,archive_action
       FROM sy_purg_def_act
       WHERE
       Purge_type=(select PURGE_TYPE from sy_purg_mst where Purge_id=P_purge_id);

  TYPE archive_table_rec_type IS RECORD(
  archive_table  user_tables.table_name%TYPE,
  archive_action char(1));

  TYPE archive_tab_type IS TABLE OF archive_table_rec_type index by binary_integer;
  l_archive archive_tab_type;
  a_tablecount number(3);

CURSOR l_constraints_cur (c_tablename user_tables.table_name%TYPE) IS
        SELECT b.table_name pk_table_name,a.owner, a.table_name,a.CONSTRAINT_NAME,a.status
        FROM all_constraints a, all_constraints b
        WHERE  a.r_constraint_name = b.constraint_name
--        AND    a.constraint_type = 'R'
--        AND    b.constraint_type = 'P'
        AND    a.r_owner=b.owner
        AND    b.owner not in ('SYS', 'SYSTEM')
        AND    b.table_name          = upper(c_tablename)
        ORDER  by b.TABLE_NAME;

  TYPE constraint_table_rec_type IS RECORD(
  pk_table_name  all_constraints.table_name%TYPE,
  owner all_constraints.owner%TYPE,
  table_name  all_constraints.table_name%TYPE,
  constraint_name  all_constraints.constraint_name%TYPE,
  status  all_constraints.status%TYPE
  );

  TYPE constraint_tab_type IS TABLE OF constraint_table_rec_type index by binary_integer;
  l_constraint constraint_tab_type;


    c_tablecount number(3):=0;

    l_disable_flag      BOOLEAN;
    l_disable_text      VARCHAR2(50);

    l_continue BOOLEAN;
    TYPE l_success_tab_type IS TABLE OF BOOLEAN
                            INDEX BY BINARY_INTEGER;
    l_success_tab l_success_tab_type;

    -- while loop control variable
    l_failure_exists BOOLEAN;

  BEGIN

   -- This will disable or enables the constraint of PM_MATL_DTL
   IF p_appl_short_name='KHG' THEN

           a_tablecount:=1;
           l_archive(a_tablecount).archive_table:='PM_MATL_DTL';
           l_archive(a_tablecount).archive_action:='D';
   ELSE

     for archive_rec in l_tablename_cur(P_Purge_id) LOOP
           a_tablecount:=l_tablename_cur%rowcount;
           l_archive(a_tablecount).archive_table:=archive_rec.table_name;
           l_archive(a_tablecount).archive_action:=archive_rec.archive_action;
     end loop;

   END IF;

    -- Is delete specified for any of the target tables?
    l_continue := FALSE;
    FOR l_counter IN 1.. a_tablecount LOOP
      IF (l_archive(l_counter).archive_action= 'D') THEN
        l_continue := TRUE;
        EXIT;
      END IF;
    END LOOP;

    -- If none of the tables are to be deleted from, leave the constraints alone
    IF (l_continue = FALSE) THEN
      RETURN;
    END IF;

    -- set the action
    IF (p_action = 'DISABLE') THEN
      l_disable_flag := TRUE;
      l_disable_text := 'Disabled';
    ELSE
      l_disable_flag := FALSE;
      l_disable_text := 'Enabled';
    END IF;

      -- if this is the disable pass, create a list of index tablespaces
       for i in 1..a_tablecount loop

        for constraint_rec in l_constraints_cur(l_archive(i).archive_table) LOOP
               c_tablecount:=c_tablecount+1;
               l_constraint(c_tablecount).pk_table_name:=constraint_rec.pk_table_name;
               l_constraint(c_tablecount).owner:=constraint_rec.owner;
               l_constraint(c_tablecount).table_name:=constraint_rec.table_name;
               l_constraint(c_tablecount).constraint_name:=constraint_rec.constraint_name;
               l_constraint(c_tablecount).status:=constraint_rec.status;
         end loop;
       end loop;

    FOR i IN 1..c_tablecount LOOP

          l_success_tab(i) := altertableconstraint(
						  p_purge_id,
                                                  l_constraint(i).owner,
                                                  p_appl_short_name,
                                                  l_constraint(i).owner||'.'||l_constraint(i).table_name,
                                                  l_constraint(i).constraint_name,
                                                  l_disable_flag,
                                                  p_debug_flag);
          IF (l_success_tab(i) = TRUE) THEN
            -- log that the constraint was altered
            GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                  l_disable_text ||
                                  ' ' ||
                                  l_constraint(i).owner||'.'||l_constraint(i).table_name||
                                  '/' ||
                                  l_constraint(i).constraint_name||
                                  ' - ' ||
                                  GMA_PURGE_UTILITIES.chartime);
         ELSIF (l_success_tab(i) <> TRUE) THEN
    -- Report failed constraints
          GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                'WARNING: ' ||
                                l_constraint(i).owner||'.'||l_constraint(i).table_name||
                                '/' ||
                                l_constraint(i).constraint_name||
                                ' not ' ||
                                l_disable_text);
        END IF;
      END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.alterconstraints.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || SQLERRM);
      RAISE;
  END;

  /***********************************************************/

  FUNCTION tab_size(p_purge_id  sy_purg_mst.purge_id%TYPE,
                    p_tablename user_tables.table_name%TYPE,
                    p_rowcount  NUMBER,
                    p_initrans  NUMBER,
                    p_pctfree   NUMBER)
                    RETURN      NUMBER IS
  -- return size of initial extent in bytes

    CURSOR l_size_params_cur IS
      select VP.value          db_block_size
      ,      VT7.type_size     sb2
      ,      VT6.type_size     ub1
      ,      VT5.type_size     kcbh
      ,      VT4.type_size     ub4
      ,      VT3.type_size     ktbbh
      ,      VT2.type_size     ktbit
      ,      VT1.type_size     kdbh
      from   v$type_size       VT7
      ,      v$type_size       VT6
      ,      v$type_size       VT5
      ,      v$type_size       VT4
      ,      v$type_size       VT3
      ,      v$type_size       VT2
      ,      v$type_size       VT1
      ,      v$parameter       VP
      where  upper(VT7.TYPE) = 'SB2'
      and    upper(VT6.TYPE) = 'UB1'
      and    upper(VT5.TYPE) = 'KCBH'
      and    upper(VT4.TYPE) = 'UB4'
      and    upper(VT3.TYPE) = 'KTBBH'
      and    upper(VT2.TYPE) = 'KTBIT'
      and    upper(VT1.TYPE) = 'KDBH'
      and    upper(VP.name) = 'DB_BLOCK_SIZE';
    l_size_params_row l_size_params_cur%ROWTYPE;

    CURSOR l_kdbt_cur IS
        select VT8.type_size     kdbt
        from   v$type_size       VT8
        where  upper(VT8.TYPE) = 'KDBT'
      union
        select VT9.type_size
        from   v$type_size       VT9
        where  upper(VT9.TYPE) = 'KCBH'
        and not exists (select VT0.type_size      kdbt
                        from   v$type_size        VT0
                        where  upper(VT0.TYPE) = 'KDBT');
    l_kdbt NUMBER;

    CURSOR l_table_cols_size_cur(c_tablename user_tables.table_name%TYPE) IS
      select sum(data_length + decode(floor(data_length/250),0,1,3))
      from   user_tab_columns
      where  table_name = c_tablename;
    l_table_cols_size NUMBER;

    l_db_free_space  NUMBER;  -- holds free space in DB block after header
    l_rowsize        NUMBER;  -- holds the size of a row in bytes
    l_rowspace       NUMBER;  -- holds the overall size of a row in bytes
    l_rows_per_block NUMBER;  -- holds the number of rows that can fit in a block
    l_blocks_needed  NUMBER;  -- the number of blocks needed to store this table

  BEGIN

    -- get size parameters
    OPEN  l_size_params_cur;
    FETCH l_size_params_cur
    INTO  l_size_params_row;
    CLOSE l_size_params_cur;

    OPEN  l_kdbt_cur;
    FETCH l_kdbt_cur
    INTO  l_kdbt;
    CLOSE l_kdbt_cur;

    OPEN  l_table_cols_size_cur(p_tablename);
    FETCH l_table_cols_size_cur
    INTO  l_table_cols_size;
    CLOSE l_table_cols_size_cur;

    -- figure out db free space
    l_db_free_space :=  (l_size_params_row.db_block_size
                       - l_size_params_row.kcbh
                       - l_size_params_row.ub4
                       - l_size_params_row.ktbbh
                       - ((p_initrans - 1) * l_size_params_row.ktbit)
                       - l_size_params_row.kdbh);

    -- figure out available db free space
    l_db_free_space := CEIL(l_db_free_space * (1 - p_pctfree/100))
                       - l_kdbt;

    -- figure out the size of a row in bytes
    l_rowsize := (3 * l_size_params_row.ub1) + l_table_cols_size;

    -- the space a row takes up
    l_rowspace := (l_size_params_row.ub1 * 3)
                 + l_size_params_row.ub4
                 + l_size_params_row.sb2;

    IF (l_rowsize > l_rowspace) THEN
      l_rowspace := l_rowsize + l_size_params_row.sb2;
    ELSE
      l_rowspace := l_rowspace + l_size_params_row.sb2;
    END IF;

    -- the number of rows per block
    l_rows_per_block := floor(l_db_free_space/l_rowspace);

    -- the number of blocks needed for storage
    l_blocks_needed := ceil(p_rowcount/l_rows_per_block);

    RETURN l_blocks_needed * l_size_params_row.db_block_size;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.tab_size with '
                            || p_tablename);
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END;

  /***********************************************************/

  PROCEDURE coalescetablespace
                         (p_purge_id        sy_purg_mst.purge_id%TYPE,
                          p_tablespace_name user_tablespaces.tablespace_name%TYPE,
                          p_debug_flag      BOOLEAN) IS
    l_countstatement user_source.text%TYPE;
    l_alterstatement user_source.text%TYPE;

    l_cursor  INTEGER;
    l_currval INTEGER;
    l_lastval INTEGER;
    l_return  INTEGER;

  BEGIN
/*
    l_countstatement := 'SELECT COUNT(*) ' ||
                        'FROM DBA_FREE_SPACE ' ||
                        'WHERE TABLESPACE_NAME = ' ||
                        '''' || p_tablespace_name || '''';
    l_alterstatement := 'ALTER TABLESPACE ' ||
                        p_tablespace_name ||
                        ' COALESCE';

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    -- get count from dba_free_space
    GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_countstatement,p_debug_flag);
    DBMS_SQL.PARSE(l_cursor,l_countstatement,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_cursor,1,l_currval);
    l_return := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor);
    DBMS_SQL.COLUMN_VALUE(l_cursor,1,l_currval);

    -- keep coalescing until effectiveness ends
    l_lastval := 0;
    WHILE (l_currval <> l_lastval) LOOP
      l_lastval := l_currval;
      GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_alterstatement,p_debug_flag);
      DBMS_SQL.PARSE(l_cursor,l_alterstatement,DBMS_SQL.NATIVE);
      GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_countstatement,p_debug_flag);
      DBMS_SQL.PARSE(l_cursor,l_countstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.DEFINE_COLUMN(l_cursor,1,l_currval);
      l_return := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor);
      DBMS_SQL.COLUMN_VALUE(l_cursor,1,l_currval);
      IF (l_currval <> l_lastval) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Tablespace ' ||
                              p_tablespace_name ||
                              ' coalesced - ' ||
                               GMA_PURGE_UTILITIES.chartime);
      END IF;

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);
*/

    RETURN;

/*
  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.coalescetablespace ' ||
                            'with '
                            || p_tablespace_name);
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;
*/

  END coalescetablespace;

  /***********************************************************/

  PROCEDURE disableindexes(p_purge_id                sy_purg_mst.purge_id%TYPE,
                           p_tablenames_tab          g_tablename_tab_type,
                           p_tableactions_tab        g_tableaction_tab_type,
                           p_tablecount              INTEGER,
                           p_indexes_tab      IN OUT NOCOPY g_statement_tab_type,
                           p_indexcount       IN OUT NOCOPY INTEGER,
                           p_owner                   user_users.username%TYPE,
                           p_appl_short_name         fnd_application.application_short_name%TYPE,
                           p_debug_flag              BOOLEAN) IS
    -- This cursor selects all of the information that we'll need
    -- to recreate the indexes later on the named table
    CURSOR l_idx_details_cur(c_table_name user_tables.table_name%TYPE) IS
      select UIX.index_name                  index_name
      ,      UIX.table_name                  indexed_table
      ,      decode(UIX.uniqueness,
                      'NONUNIQUE',NULL,
                      'UNIQUE'   ,' UNIQUE',
                       NULL)                 uniqueness
      ,      UIX.tablespace_name             tablespace_name
      ,      UIX.ini_trans                   ini_trans
      ,      UIX.max_trans                   max_trans
      ,      decode(nvl(UIX.initial_extent,9999999999),
                    9999999999,NULL,
                               ' INITIAL '
                               || to_char(UIX.initial_extent))
                                             initial_extent
      ,      decode(nvl(UIX.next_extent,9999999999),
                    9999999999,NULL,
                               ' NEXT '
                               || to_char(UIX.next_extent))
                                             next_extent
      ,      decode(nvl(UIX.freelists,9999999999),
                    9999999999,NULL,
                               ' FREELISTS '
                               || to_char(UIX.freelists))
                                             freelists
      ,      decode(nvl(UIX.freelist_groups,9999999999),
                    9999999999,NULL,
                               ' FREELIST GROUPS '
                               || to_char(UIX.freelist_groups))
                                             freelist_groups
      ,      UIX.min_extents                 min_extents
      ,      UIX.max_extents                 max_extents
      ,      UIX.pct_increase                pct_increase
      ,      UIX.pct_free                    pct_free
      ,      UIC.table_name                  indexed_column_table
      ,      UIC.column_name                 column_name
      from   user_ind_columns                UIC
      ,      user_indexes                    UIX
      where  UIC.index_name = UIX.index_name
      and    UIX.table_name = c_table_name
      order  by UIX.index_name
      ,         UIC.column_position;

    -- The name of the current index
    l_current_idx  user_indexes.index_name%TYPE := NULL;

    -- These variables hold text fragments during index create statement
    -- construction
    l_sqlstatement user_source.text%TYPE        := NULL;
    l_runstatement user_source.text%TYPE        := NULL;
    l_sqlfront     user_source.text%TYPE        := NULL;
    l_sqlback      user_source.text%TYPE        := NULL;
    l_column_list  user_source.text%TYPE        := NULL;

    l_cursor       INTEGER;

  BEGIN

    p_indexcount := 0;

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    -- loop through the tables
    FOR l_tablecounter IN 0 .. (p_tablecount - 1) LOOP
      -- we only care about indexes for tables marked for delete
      IF (p_tableactions_tab(l_tablecounter) = 'D') THEN
        -- loop through the rows from idx_details
        FOR l_idx_details_row IN
                   l_idx_details_cur(UPPER(p_tablenames_tab(l_tablecounter))) LOOP

          -- check to see if we're still on the same index
          IF ((l_current_idx <> l_idx_details_row.index_name) OR
              (l_current_idx IS NULL)) THEN

            -- If not, finish the last index create statement before
            -- starting the next
            IF (l_current_idx IS NOT NULL) THEN

              -- save create statement in table
              l_sqlstatement := l_sqlfront ||
                                l_column_list ||
                                l_sqlback;
              p_indexes_tab(p_indexcount) := l_sqlstatement;
              p_indexcount := p_indexcount + 1;
              GMA_PURGE_UTILITIES.printdebug(p_purge_id,
                                     'Statement saved - will run later. => ' ||'
                                      '||
                                     l_sqlstatement,
                                     p_debug_flag);

              -- drop the index
              l_sqlstatement := 'DROP INDEX ' || l_current_idx;
              GMA_PURGE_UTILITIES.printdebug(p_purge_id,
                                     l_sqlstatement,
                                     p_debug_flag);
              IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
                AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.DROP_INDEX,
                              l_sqlstatement,l_current_idx);
              ELSE
                DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
              END IF;

              GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                    l_current_idx ||
                                    ' index dropped.');
            END IF;

            l_current_idx := l_idx_details_row.index_name;

            -- start new create statement
            l_sqlfront := 'CREATE' ||
                          l_idx_details_row.uniqueness ||
                          ' INDEX ' ||
                          l_idx_details_row.index_name ||
                          ' ON ' ||
                          l_idx_details_row.indexed_table ||
                          ' (';

            l_column_list := l_idx_details_row.column_name;

            l_sqlback := ') TABLESPACE ' ||
                         l_idx_details_row.tablespace_name ||
                         ' INITRANS ' ||
                         to_char(l_idx_details_row.ini_trans) ||
                         ' MAXTRANS ' ||
                         to_char(l_idx_details_row.max_trans) ||
                         ' PCTFREE ' ||
                         to_char(l_idx_details_row.pct_free) ||
                         ' STORAGE (' ||
                         l_idx_details_row.initial_extent ||
                         l_idx_details_row.next_extent ||
                         ' MINEXTENTS ' ||
                         to_char(l_idx_details_row.min_extents) ||
                         ' MAXEXTENTS ' ||
                         to_char(l_idx_details_row.max_extents) ||
                         ' PCTINCREASE ' ||
                         to_char(l_idx_details_row.pct_increase) ||
                         l_idx_details_row.freelists ||
                         l_idx_details_row.freelist_groups ||
                         ' ) ';

          ELSE -- write all subsequent columns for the same index
               -- to the column list
            l_column_list := l_column_list ||
                             ',' ||
                             l_idx_details_row.column_name;
          END IF;

        END LOOP;
      END IF;
    END LOOP;

    -- finish last statement
    IF (l_current_idx IS NOT NULL) THEN
      -- save create statement in table
      l_sqlstatement := l_sqlfront ||
                        l_column_list ||
                        l_sqlback;
      p_indexes_tab(p_indexcount) := l_sqlstatement;
      p_indexcount := p_indexcount + 1;
      GMA_PURGE_UTILITIES.printdebug(p_purge_id,'Statement saved - will run later. => ' ||'
                                         '||
                                        l_sqlstatement,
                                        p_debug_flag);

      -- drop the index
      l_runstatement := 'DROP INDEX ' || l_current_idx;
      GMA_PURGE_UTILITIES.printdebug(p_purge_id,
                             l_runstatement,
                             p_debug_flag);
      IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
        AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.DROP_INDEX,
                      l_sqlstatement,l_current_idx);
      ELSE
        DBMS_SQL.PARSE(l_cursor,l_runstatement,DBMS_SQL.NATIVE);
      END IF;

      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            l_current_idx ||
                            ' index dropped.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,'The following statement can be ' ||
                                       'used to recreate the index in ' ||
                                       'case of severe archive failure.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);

    END IF;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.disableindexes');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END disableindexes;

  /***********************************************************/

  PROCEDURE enableindexes(p_purge_id             sy_purg_mst.purge_id%TYPE,
                          p_indexes_tab          g_statement_tab_type,
                          p_indexcount           INTEGER,
                          p_idx_tablespace_tab   g_tablespace_name_tab_type,
                          p_idx_tablespace_count INTEGER,
                          p_owner                   user_users.username%TYPE,
                          p_appl_short_name         fnd_application.application_short_name%TYPE,
                          p_debug_flag       BOOLEAN) IS

    l_cursor INTEGER;
    l_sqlstatement user_source.text%TYPE;
    l_indexname    user_source.text%TYPE;
    l_errortext    user_source.text%TYPE;
    l_parse_success BOOLEAN;

  BEGIN

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    -- coalesce any index tablespaces
    IF (p_idx_tablespace_count > 0) THEN
      FOR l_idx_tablespace_count IN 0 .. (p_idx_tablespace_count - 1) LOOP
        GMA_PURGE_DDL.coalescetablespace(p_purge_id,
                                      p_idx_tablespace_tab(l_idx_tablespace_count),
                                      p_debug_flag);
      END LOOP;
    END IF;

    -- return if there are no saved index statements
    IF (p_indexcount <= 0) THEN
      RETURN;
    END IF;

    -- recreate all of the indexes
    FOR l_counter IN 0 .. (p_indexcount - 1) LOOP
      l_parse_success := TRUE;
      l_sqlstatement := p_indexes_tab(l_counter);

      -- extract index name
      l_indexname := l_sqlstatement;
      l_indexname := REPLACE(l_indexname,'CREATE ');
      l_indexname := REPLACE(l_indexname,'UNIQUE ');
      l_indexname := REPLACE(l_indexname,'INDEX ');
      l_indexname := SUBSTR(l_indexname,1,(INSTR(l_indexname,' ') - 1));

      GMA_PURGE_UTILITIES.printdebug(p_purge_id,
                             l_sqlstatement,
                             p_debug_flag);

      -- try to recreate index
      BEGIN
        IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
          AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.CREATE_INDEX,
                        l_sqlstatement,l_indexname);
        ELSE
          DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          l_parse_success := FALSE;
          l_errortext := SQLERRM;
      END;

      IF (l_parse_success = TRUE) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              l_indexname ||
                              ' index recreated.');
      ELSE
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              l_indexname ||
                              ' index not recreated - ' ||
                              l_errortext);
      END IF;

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_DDL.enableindexes');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END enableindexes;

END GMA_PURGE_DDL;

/

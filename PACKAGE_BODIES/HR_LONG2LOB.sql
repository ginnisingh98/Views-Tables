--------------------------------------------------------
--  DDL for Package Body HR_LONG2LOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LONG2LOB" AS
/*$Header: hrl2lmig.pkb 120.4 2005/11/17 11:46 smallina noship $ */

 FUNCTION getTblOwner(p_appl_short_name VARCHAR2) RETURN VARCHAR2 IS
  l_status    VARCHAR2(100) := NULL;
  l_industry  VARCHAR2(100) := NULL;
  l_result    BOOLEAN;
  l_schema_owner VARCHAR2(10) := NULL;

 BEGIN
    l_result := FND_INSTALLATION.GET_APP_INFO(
                p_appl_short_name,
                l_status,
                l_industry,
                l_schema_owner);
    RETURN l_schema_owner;
 END getTblOwner;

 FUNCTION columnExists(
   p_appl_short_name VARCHAR2,
   p_table_name VARCHAR2,
   p_col_name VARCHAR2,
   p_col_data_type VARCHAR2) RETURN BOOLEAN AS

  dummy    VARCHAR2(1);
  retValue BOOLEAN:=FALSE;
  l_schema_owner VARCHAR2(10):= NULL;

 BEGIN

       l_schema_owner := getTblOwner(p_appl_short_name);

       SELECT 'X'
       INTO dummy
       FROM
	   all_tab_columns
       WHERE owner = l_schema_owner
       AND table_name = p_table_name
       AND column_name = p_col_name
       AND data_type  = p_col_data_type;

        IF (SQL%FOUND) THEN
		    retValue:=TRUE;
            RETURN retValue;
	    END IF;

   EXCEPTION
      WHEN OTHERS THEN
        RETURN retValue;
 END columnExists;


--wrapper to all actions in the process of migration.
 PROCEDURE main(
   p_appl_short_name      IN  VARCHAR2,
   p_table_name           IN  VARCHAR2,
   p_old_column_name      IN  VARCHAR2,
   p_new_column_data_type IN  VARCHAR2,
   p_mode                 IN  VARCHAR2
  )AS

   TYPE cur_type IS REF CURSOR;

   l_cur                      cur_type;
   l_str                      VARCHAR2 (500);
   l_schema                   VARCHAR2 (30);
   l_table_name               VARCHAR2 (30);
   l_old_column_name          VARCHAR2 (30);
   l_old_data_type            VARCHAR2 (30);
   l_new_column_name          VARCHAR2 (30);
   l_new_data_type            VARCHAR2 (30);
   l_curr_status              VARCHAR2 (20);
   l_action                   VARCHAR2 (30);
   l_rowid                    VARCHAR2 (30);
   l_init_process             BOOLEAN        := FALSE;
   l_add_columns              BOOLEAN        := FALSE;
   l_add_triggers             BOOLEAN        := FALSE;
   l_conv_data                BOOLEAN        := FALSE;
   l_drop_triggers            BOOLEAN        := FALSE;
   l_drop_columns             BOOLEAN        := FALSE;
   l_rename_columns           BOOLEAN        := FALSE;
   l_mark_columns_as_unused   BOOLEAN        := FALSE;
   lp_table_name              VARCHAR2(30);
   lp_old_column_name         VARCHAR2(30);
   lp_new_column_data_type    VARCHAR2(30);
   lp_mode                    VARCHAR2(30);


   BEGIN

   lp_table_name:=Upper(p_table_name);
   lp_old_column_name:=Upper(p_old_column_name);
   lp_new_column_data_type:=Upper(p_new_column_data_type);
   lp_mode:=Upper(p_mode);

   IF p_mode IN ( 'ALL_DROP','ALL_UNUSED','INIT') AND columnExists(p_appl_short_name,
      lp_table_name, lp_old_column_name, lp_new_column_data_type) = TRUE THEN
   	 RETURN;
   END IF;

   IF (lp_mode = 'ALL_DROP')
   THEN
      l_init_process := TRUE;
      l_add_columns := TRUE;
      l_conv_data := TRUE;
      l_rename_columns := TRUE;
      l_drop_columns := TRUE;
   END IF;

   IF (lp_mode = 'ALL_UNUSED')
   THEN
      l_init_process := TRUE;
      l_add_columns := TRUE;
      l_conv_data := TRUE;
      l_rename_columns := TRUE;
      l_mark_columns_as_unused := TRUE;
   END IF;

   IF (lp_mode = 'INIT')
   THEN
      l_init_process := TRUE;
      l_add_columns := TRUE;
      l_add_triggers := TRUE;
   END IF;

   IF (lp_mode = 'MIGRATE')
   THEN
      l_conv_data := TRUE;
      l_rename_columns := TRUE;
      l_drop_triggers := TRUE;
   END IF;

   IF (lp_mode = 'DROP')
   THEN
      l_drop_columns := TRUE;
   END IF;

   IF (lp_mode = 'UNUSED')
   THEN
      l_mark_columns_as_unused := TRUE;
   END IF;

   -- Steps-1 Intiliazation of AD tables.
   IF (l_init_process = TRUE) THEN
     BEGIN
        ad_longtolob_pkg.initialize_process
                                              (p_specific_table      => lp_table_name);
     END;
   END IF;

   -- Step-2 Addding of New Columns
   IF (l_add_columns = TRUE)
   THEN
      BEGIN
         l_str :=
               ' SELECT schema_name, table_name, old_column_name,'
            || ' new_column_name, new_data_type, status, '
            || ' action, ROWID '
            || ' FROM ad_long_column_conversions '
            || ' WHERE status = '''
            || ad_longtolob_pkg.g_initialized_status
            || ''''
            || ' AND upper(table_name) = upper('''
            || lp_table_name
            || ''')'
            || ' AND upper(old_column_name) = upper('''
            || lp_old_column_name
            || ''')';

         OPEN l_cur
          FOR l_str;

         LOOP
            FETCH l_cur
             INTO l_schema, l_table_name, l_old_column_name,
                  l_new_column_name, l_new_data_type, l_curr_status,
                  l_action, l_rowid;

            EXIT WHEN l_cur%NOTFOUND;

            BEGIN
               IF (l_curr_status = ad_longtolob_pkg.g_initialized_status)
               THEN
                  -- overrding the new column datatype
                  IF (    lp_new_column_data_type IS NOT NULL
                      AND lp_new_column_data_type IN
                                                 ('VARCHAR2', 'CLOB', 'BLOB')
                     )
                  THEN
                     l_new_data_type := lp_new_column_data_type;
                  END IF;

                  ad_longtolob_pkg.add_new_column (l_schema,
                                                   l_table_name,
                                                   l_old_column_name,
                                                   l_new_column_name,
                                                   l_new_data_type,
                                                   l_curr_status,
                                                   l_action
                                                  );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                 RAISE_APPLICATION_ERROR (-20001,'Exception in adding the new column.');
            END;
         END LOOP;

         IF l_cur%ISOPEN
         THEN
            CLOSE l_cur;
         END IF;
      END;
   END IF;

--  Step-3 Addding of Triggers Columns
   IF (l_add_triggers = TRUE)
   THEN
      BEGIN
         l_str :=
               ' SELECT schema_name, table_name, old_column_name,'
            || ' new_column_name, new_data_type, status, '
            || ' action, ROWID '
            || ' FROM ad_long_column_conversions '
            || ' WHERE status = '''
            || ad_longtolob_pkg.g_add_new_column_status
            || ''''
            || ' and upper(table_name) = upper('''
            || lp_table_name
            || ''')'
            || ' AND upper(old_column_name) = upper('''
            || lp_old_column_name
            || ''')';

         OPEN l_cur
          FOR l_str;

         LOOP
            FETCH l_cur
             INTO l_schema, l_table_name, l_old_column_name,
                  l_new_column_name, l_new_data_type, l_curr_status,
                  l_action, l_rowid;

            EXIT WHEN l_cur%NOTFOUND;

            BEGIN
               IF (l_curr_status = ad_longtolob_pkg.g_add_new_column_status
                  )
               THEN
                  --overrding the new column datatype
                  IF (    lp_new_column_data_type IS NOT NULL
                      AND lp_new_column_data_type IN
                                                 ('VARCHAR2', 'CLOB', 'BLOB')
                     )
                  THEN
                     l_new_data_type := lp_new_column_data_type;
                  END IF;

                  ad_longtolob_pkg.create_transform_triggers
                                                           (l_schema,
                                                            l_table_name,
                                                            l_old_column_name,
                                                            l_new_column_name,
                                                            l_new_data_type
                                                           );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                 RAISE_APPLICATION_ERROR (-20001,'Exception in adding the triggers.');
            END;
         END LOOP;

         IF l_cur%ISOPEN
         THEN
            CLOSE l_cur;
         END IF;
      END;
   END IF;

--Step-4 Data Migration.
   IF (l_conv_data = TRUE)
   THEN
      BEGIN
         l_str :=
               ' SELECT schema_name, table_name, old_column_name,'
            || ' old_data_type, new_column_name, new_data_type, status, '
            || ' action, ROWID '
            || ' FROM ad_long_column_conversions '
            || ' WHERE status IN ('''
            || ad_longtolob_pkg.g_add_trigger_status
            || ''','''|| ad_longtolob_pkg.g_add_new_column_status || ''''
            || ') AND upper(table_name) = upper('''
            || lp_table_name
            || ''')'
            || ' AND upper(old_column_name) = upper('''
            || lp_old_column_name
            || ''')';
         OPEN l_cur
          FOR l_str;

         LOOP
            FETCH l_cur
             INTO l_schema, l_table_name, l_old_column_name, l_old_data_type,
                  l_new_column_name, l_new_data_type, l_curr_status,
                  l_action, l_rowid;

            EXIT WHEN l_cur%NOTFOUND;

            BEGIN
               IF (l_curr_status IN (ad_longtolob_pkg.g_add_trigger_status,ad_longtolob_pkg.g_add_new_column_status))
               THEN
                  ad_longtolob_pkg.update_new_data (l_schema,
                                                    l_table_name,
                                                    l_old_column_name,
                                                    l_old_data_type,
                                                    l_new_column_name
                                                   );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR (-20001,'Exception in migration of long data to clob data.');
            END;
         END LOOP;

         IF l_cur%ISOPEN
         THEN
            CLOSE l_cur;
         END IF;
      END;
   END IF;

-- Step-5 Renaming of Columns
   IF (l_rename_columns = TRUE)
   THEN
      DECLARE
         CURSOR c1 (cur_p_table_name VARCHAR2, cur_old_column_name VARCHAR2)
         IS
            SELECT schema_name, table_name, old_column_name, new_column_name
              FROM ad_long_column_conversions
             WHERE status IN
                      (ad_longtolob_pkg.g_update_rows_status,
                       ad_longtolob_pkg.g_drop_old_column_status
                      )
               AND table_name = cur_p_table_name
               AND old_column_name = cur_old_column_name;

         l_column_name   VARCHAR2 (30);
         l_command       VARCHAR2 (300);
         l_flag          NUMBER;
      BEGIN
         l_flag := 0;

         FOR rec IN c1 (lp_table_name, lp_old_column_name)
         LOOP
            l_command :=
                  'alter table '
               || rec.schema_name
               || '.'
               || rec.table_name
               || ' rename column '
               || rec.old_column_name
               || ' to '
               || SUBSTR (rec.old_column_name, 1, 26)
               || '_old';

            EXECUTE IMMEDIATE l_command;

            IF rec.new_column_name LIKE 'R118_%'
            THEN
               SELECT LTRIM (rec.new_column_name, 'R118_')
                 INTO l_column_name
                 FROM DUAL;

               l_command :=
                     'alter table '
                  || rec.schema_name
                  || '.'
                  || rec.table_name
                  || ' rename column '
                  || rec.new_column_name
                  || ' to '
                  || l_column_name;

               BEGIN
                  EXECUTE IMMEDIATE l_command;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE_APPLICATION_ERROR (-20001,'Exception in renaming the column.');
               END;
            END IF;

            UPDATE ad_long_column_conversions
               SET status = ad_longtolob_pkg.g_col_renamed_status
             WHERE schema_name = rec.schema_name
               AND table_name = rec.table_name
               AND old_column_name = rec.old_column_name;
         END LOOP;
      END;
   END IF;

--Step-6 Dropping Triggers
   IF (l_drop_triggers = TRUE)
   THEN
      DECLARE
         CURSOR c1 (cur_table_name VARCHAR2, cur_old_column_name VARCHAR2)
         IS
            SELECT schema_name, table_name, old_column_name
              FROM ad_long_column_conversions
             WHERE status IN (ad_longtolob_pkg.g_col_renamed_status)
               AND table_name = cur_table_name
               AND old_column_name = cur_old_column_name;

         l_command   VARCHAR2 (300);
      BEGIN
         FOR rec IN c1 (lp_table_name, lp_old_column_name)
         LOOP
            l_command :=
                 'drop trigger ' || SUBSTR (rec.table_name, 1, 24)
                 || '_$R2U1';

            EXECUTE IMMEDIATE l_command;

            l_command :=
                 'drop trigger ' || SUBSTR (rec.table_name, 1, 24)
                 || '_$R2U2';

            EXECUTE IMMEDIATE l_command;

            UPDATE ad_long_column_conversions
               SET status = ad_longtolob_pkg.g_drop_trigger_status
             WHERE schema_name = rec.schema_name
               AND table_name = rec.table_name
               AND old_column_name = rec.old_column_name;
         END LOOP;
      END;
   END IF;

--Step-7 Marking Columns as Unused
   IF (l_mark_columns_as_unused = TRUE)
   THEN
      DECLARE
         CURSOR c1 (cur_table_name VARCHAR2, cur_old_column_name VARCHAR2)
         IS
            SELECT schema_name, table_name, old_column_name
              FROM ad_long_column_conversions
             WHERE status IN (ad_longtolob_pkg.g_drop_trigger_status,ad_longtolob_pkg.g_col_renamed_status)
               AND table_name = cur_table_name
               AND old_column_name = cur_old_column_name;

         l_column_name   VARCHAR2 (30);
         l_command       VARCHAR2 (300);
      BEGIN
         FOR rec IN c1 (lp_table_name, lp_old_column_name)
         LOOP
            l_command :=
                  'alter table '
               || rec.schema_name
               || '.'
               || rec.table_name
               || ' set unused column '
               || SUBSTR (rec.old_column_name, 1, 26)
               || '_old';

            EXECUTE IMMEDIATE l_command;

            UPDATE ad_long_column_conversions
	                   SET status = ad_longtolob_pkg.g_complete_status
	                   WHERE schema_name = rec.schema_name
	                   AND table_name = rec.table_name
                           AND old_column_name = rec.old_column_name;
         END LOOP;
      END;
   END IF;

--Step-8 Dropping of Columns
   IF (l_drop_columns = TRUE)
   THEN
      DECLARE
         CURSOR c1 (cur_table_name VARCHAR2, cur_old_column_name VARCHAR2)
         IS
            SELECT schema_name, table_name, old_column_name
              FROM ad_long_column_conversions
             WHERE status IN (
               ad_longtolob_pkg.g_drop_trigger_status,ad_longtolob_pkg.g_col_renamed_status)
               AND table_name = cur_table_name
               AND old_column_name = cur_old_column_name;

         l_column_name   VARCHAR2 (30);
         l_command       VARCHAR2 (300);
      BEGIN
         FOR rec IN c1 (lp_table_name, lp_old_column_name)
         LOOP
            l_command :=
                  'alter table '
               || rec.schema_name
               || '.'
               || rec.table_name
               || ' drop column '
               || SUBSTR (rec.old_column_name, 1, 26)
               || '_old';

            EXECUTE IMMEDIATE l_command;

            UPDATE ad_long_column_conversions
               SET status = ad_longtolob_pkg.g_complete_status
             WHERE schema_name = rec.schema_name
               AND table_name = rec.table_name
               AND old_column_name = rec.old_column_name;
         END LOOP;
      END;
   END IF;
END MAIN;

-- init procedure will do the following steps.
-- 1.initialize the AD tables with required data.
-- 2.Adding the columns
-- 3.Adding the Triggers

 PROCEDURE DO_INIT(
   p_appl_short_name      IN  VARCHAR2,
   p_table_name           IN  VARCHAR2,
   p_old_column_name      IN  VARCHAR2,
   p_new_column_data_type IN  VARCHAR2) AS

 BEGIN

  main(p_appl_short_name,p_table_name,p_old_column_name,p_new_column_data_type,'INIT');

 END DO_INIT;

-- migrate procedure will do the following steps.
-- 1.migration of data.
-- 2.Renaming the columns
-- 3.Dropping the triggers.

 PROCEDURE  DO_MIGRATE(
   p_appl_short_name      IN  VARCHAR2,
   p_table_name           IN  VARCHAR2,
   p_old_column_name      IN  VARCHAR2) AS

 BEGIN

   main(p_appl_short_name,p_table_name,p_old_column_name,Null,'MIGRATE');

 END DO_MIGRATE;

-- drop procedure will do the following step.
-- 1.dropping the column

 PROCEDURE DO_DROP(
   p_appl_short_name      IN  VARCHAR2,
   p_table_name           IN  VARCHAR2,
   p_old_column_name      IN  VARCHAR2) AS

 BEGIN

  main(p_appl_short_name,p_table_name,p_old_column_name,NULL,'DROP');

 END DO_DROP;

-- unused procedure will do the following step.
-- 1.marks the column as unused.

 PROCEDURE DO_UNUSED(
  p_appl_short_name      IN  VARCHAR2,
  p_table_name           IN  VARCHAR2,
  p_old_column_name      IN  VARCHAR2) AS

 BEGIN

  main(p_appl_short_name,p_table_name,p_old_column_name,NULL,'UNUSED');

 END DO_UNUSED;

-- ALL_DROP procedure will do the following steps.
-- 1.initialize the AD tables with required data.
-- 2.Adding the column
-- 3.migration of data.
-- 4.Renaming the column
-- 5.Dropping the column

 PROCEDURE DO_ALL_DROP(
  p_appl_short_name      IN  VARCHAR2,
  p_table_name           IN  VARCHAR2,
  p_old_column_name      IN  VARCHAR2,
  p_new_column_data_type IN  VARCHAR2) AS

 BEGIN

  main(p_appl_short_name,p_table_name,p_old_column_name,p_new_column_data_type,'ALL_DROP');

 END DO_ALL_DROP;

-- ALL_DROP procedure will do the following steps.
-- 1.initialize the AD tables with required data.
-- 2.Adding the column
-- 3.migration of data.
-- 4.Renaming the column
-- 5.Marking the column as unused.

 PROCEDURE DO_ALL_UNUSED(
  p_appl_short_name      IN  VARCHAR2,
  p_table_name           IN  VARCHAR2,
  p_old_column_name      IN  VARCHAR2,
  p_new_column_data_type IN  VARCHAR2) AS

 BEGIN

   main(p_appl_short_name, p_table_name,p_old_column_name,p_new_column_data_type,'ALL_UNUSED');

 END DO_ALL_UNUSED;


END HR_LONG2LOB;

/

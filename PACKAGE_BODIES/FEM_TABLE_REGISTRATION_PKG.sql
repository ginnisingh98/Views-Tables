--------------------------------------------------------
--  DDL for Package Body FEM_TABLE_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_TABLE_REGISTRATION_PKG" AS
/* $Header: FEMTABREGB.pls 120.6.12000000.3 2007/09/24 09:32:50 asadadek ship $ */

G_PLSQL_COMPILATION_ERROR   exception;
pragma exception_init(G_PLSQL_COMPILATION_ERROR,-942);

PROCEDURE synchronize(p_api_version     IN NUMBER,
                        p_init_msg_list   IN VARCHAR2,
                        p_commit          IN VARCHAR2,
                        p_encoded         IN VARCHAR2,
                        p_table_name      IN VARCHAR2,
                        p_synchronize_flag OUT NOCOPY VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2)
  IS

    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);
    l_owner           VARCHAR2(30);
    dummy             NUMBER;

    l_delete_error    EXCEPTION;
    l_owner_error     EXCEPTION;
    l_insert_error    EXCEPTION;

    TYPE col_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE col_prop_code_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    l_column_tab      col_tab;
    l_col_prop_code_tab col_prop_code_tab;

    i                 NUMBER;

    l_user_id         NUMBER;
    l_login_id        NUMBER;

    l_pk_col           NUMBER :=0;
    l_pk_msg_count     NUMBER;
    l_pk_msg_data      VARCHAR2(240);
    l_pk_return_status VARCHAR2(1);

    l_schema_return_status VARCHAR2(1);
    l_schema_msg_count     NUMBER(20);
    l_schema_msg_data      VARCHAR2(240);
    l_schema_tab_name      VARCHAR2(240);

	l_object_type          VARCHAR2(10);
	l_apps                 VARCHAR2(30):=USER;

  BEGIN

      x_return_status := c_success;
      p_synchronize_flag := 'N';

      l_user_id := Fnd_Global.User_Id;
      l_login_id := Fnd_Global.Login_Id;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.synchronize'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);
      dummy := 0;

      BEGIN

		l_object_type := get_object_type(p_table_name);

        IF l_object_type = 'FEM_TABLE' THEN

         fem_database_util_pkg.get_table_owner
         (x_return_status => l_schema_return_status,
          x_msg_count => l_schema_msg_count,
          x_msg_data  => l_schema_msg_data,
          p_syn_name  => p_table_name,
          x_tab_name  => l_schema_tab_name,
          x_tab_owner => l_owner
         );

		ELSE

		 l_owner := l_apps;--For veiws owner will be APPS

        END IF;

      EXCEPTION
         WHEN OTHERS THEN
            RAISE l_owner_error;
      END;

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.synchronize'
                                   ,p_msg_text => 'After fetching the owner, owner = ' || l_owner);
      BEGIN
            SELECT 1
            INTO   dummy
            FROM   fem_tab_columns_b ftc
            WHERE  ftc.column_name NOT IN
                   (SELECT column_name
                    FROM   dba_tab_columns dtc
                    WHERE  dtc.owner = l_owner
                      AND  dtc.table_name=p_table_name)
              AND  ftc.table_name=p_table_name
              AND  ROWNUM = 1;

        IF dummy = 1 THEN
            /* Changes have occurred so must flag the table status to "Incomplete" */
            p_synchronize_flag := 'Y';

           DELETE FROM fem_tab_columns_b
           WHERE  column_name NOT IN ( SELECT column_name
                                       FROM   dba_tab_columns
                                       WHERE  table_name = p_table_name
                                         AND  owner = l_owner )
             AND  table_name = p_table_name
           RETURNING column_name BULK COLLECT INTO l_column_tab;

           FORALL i IN l_column_tab.FIRST..l_column_tab.LAST
              DELETE FROM fem_tab_columns_tl
              WHERE  table_name = p_table_name
                AND  column_name = l_column_tab(i);

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
              DELETE FROM fem_tab_column_prop
              WHERE table_name =p_table_name
              AND column_name = l_column_tab(i)
              RETURNING column_property_code BULK COLLECT INTO l_col_prop_code_tab ;
           END LOOP;

           IF l_col_prop_code_tab.exists(1) THEN
              FOR j IN l_col_prop_code_tab.FIRST .. l_col_prop_code_tab.LAST
              LOOP
                IF 'PROCESSING_KEY' = l_col_prop_code_tab(j) AND l_pk_col = 0 THEN
                   DELETE FROM fem_tab_column_prop
                   WHERE  table_name = p_table_name
                   AND column_property_code = 'PROCESSING_KEY';

                   UPDATE fem_tables_b
                   SET    proc_key_index_name = NULL
                   WHERE  table_name = p_table_name;

                   raise_proc_key_update_event(p_table_name,
                                               l_pk_msg_count,
                                               l_pk_msg_data,
                                               l_pk_return_status);
                   l_pk_col := 1;

                END IF;  -- 'PROCESSING_KEY'

              END LOOP;

           END IF; -- l_col_prop_code_tab.exists(1)

        END IF; -- dummy = 1

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             NULL;

         WHEN OTHERS THEN
            RAISE l_delete_error;
      END;

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.synchronize'
                                   ,p_msg_text => 'After deleting columns in fem_tab_columns but not in dba_tab_columns');

      BEGIN

         INSERT INTO fem_tab_columns_vl
         (table_name,
          column_name,
          display_name,
          description,
          fem_data_type_code,
          dimension_id,
          uom_column_name,
          enabled_flag,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number
          )
           SELECT
             p_table_name,
             dtc.column_name,
             NVL(display_name, dtc.column_name) display_name,
             NVL(description,dtc.column_name) description,
             nvl(fcr.fem_data_type_code,dtc.data_type) as cpm_datatype,
             DECODE(fcr.restricted_flag,'N',TO_NUMBER(NULL),fcr.dimension_id) dimension_id,
             DECODE(fcr.restricted_flag,'N',TO_NUMBER(NULL),fcr.uom_column_name) uom_column_name,
             DECODE(dtc.nullable,'N','Y','Y','N') enabled_flag,
             SYSDATE,
             l_user_id,
             SYSDATE,
             l_user_id,
             l_login_id,
             1
           FROM dba_tab_columns dtc,
                fem_column_requiremnt_vl fcr
           WHERE dtc.table_name = p_table_name
             AND dtc.owner = l_owner
             AND dtc.column_name = fcr.column_name
             AND NOT EXISTS ( SELECT 1
                              FROM   fem_tab_columns_b
                              WHERE  table_name = p_table_name
                                AND  column_name = fcr.column_name );

         IF p_synchronize_flag <> 'Y' THEN
             IF SQL%ROWCOUNT > 0 THEN
                p_synchronize_flag := 'Y';
             END IF;
         END IF;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.synchronize'
                                      ,p_msg_text => 'Populating columns with data in tab columns');

         INSERT INTO fem_tab_columns_vl
         (table_name,
          column_name,
          display_name,
          description,
          fem_data_type_code,
          dimension_id,
          uom_column_name,
          enabled_flag,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number
          )
           SELECT
             p_table_name,
             dump.column_name,
             nvl(display_name,dump.column_name) display_name,
             nvl(description,dump.column_name) description,
             nvl(ftc.fem_data_type_code,dump.data_type) as cpm_datatype,
             ftc.dimension_id,
             ftc.uom_column_name,
             DECODE(dump.nullable,'N','Y','Y','N') enabled_flag,
             SYSDATE,
             l_user_id,
             SYSDATE,
             l_user_id,
             l_login_id,
             1
           FROM fem_tab_columns_vl ftc,
           (
             SELECT dtc.column_name, dtc.table_name, dtc.nullable, (SELECT table_name tname
                                                      FROM   fem_tab_columns_b
                                                      WHERE  column_name = dtc.column_name AND rownum = 1) tname,
                    data_type
             FROM   dba_tab_columns dtc
             WHERE  dtc.table_name = p_table_name
               AND  dtc.owner = l_owner
               AND  NOT EXISTS ( SELECT 1
                                 FROM   fem_tab_columns_b fcr
                                 WHERE  fcr.column_name = dtc.column_name
                                   AND  fcr.table_name = p_table_name )) dump
           WHERE ftc.column_name = dump.column_name
             AND ftc.table_name = dump.tname;

          IF p_synchronize_flag <> 'Y' THEN
             IF SQL%ROWCOUNT > 0 THEN
                p_synchronize_flag := 'Y';
             END IF;
          END IF;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.synchronize'
                                      ,p_msg_text => 'Populating columns with data in dba tab columns');

         INSERT INTO fem_tab_columns_vl
         (table_name,
          column_name,
          display_name,
          description,
          fem_data_type_code,
          dimension_id,
          uom_column_name,
          enabled_flag,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number
          )
           SELECT
             table_name,
             column_name,
             column_name,
             column_name,
             data_type,
             TO_NUMBER(NULL),
             NULL,
             DECODE(atc.nullable,'N','Y','Y','N') enabled_flag,
             SYSDATE,
             l_user_id,
             SYSDATE,
             l_user_id,
             l_login_id,
             1
           FROM  dba_tab_columns atc
           WHERE table_name = p_table_name
             AND atc.owner = l_owner
             AND NOT EXISTS ( SELECT 1
                              FROM   fem_tab_columns_b ftc
                              WHERE  column_name = atc.column_name
                                AND  table_name = p_table_name );

           IF p_synchronize_flag <> 'Y' THEN
             IF SQL%ROWCOUNT > 0 THEN
                p_synchronize_flag := 'Y';
             END IF;
           END IF;
             fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                          ,p_module   => g_block||'.synchronize'
                                          ,p_msg_text => 'After populating the VL');

      EXCEPTION
         WHEN OTHERS THEN
            RAISE l_insert_error;
      END;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.synchronize'
                                   ,p_msg_text => 'END');


  EXCEPTION

     WHEN l_owner_error THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: Trying to get owner info. for' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

     WHEN l_delete_error THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: Trying to delete from fem_tab_columns - ' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

     WHEN l_insert_error THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: Trying to insert for' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);


     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.init'
                                     ,p_msg_text => 'synchronize: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'synchronize: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);


  END synchronize;

  PROCEDURE unregister(p_api_version     IN NUMBER,
                       p_init_msg_list   IN VARCHAR2,
                       p_commit          IN VARCHAR2,
                       p_encoded         IN VARCHAR2,
                       p_table_name      IN VARCHAR2,
                       x_msg_count       OUT NOCOPY NUMBER,
                       x_msg_data        OUT NOCOPY VARCHAR2,
                       x_return_status   OUT NOCOPY VARCHAR2)
  IS

    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);

	l_di_view_name    VARCHAR2(30);

  BEGIN

      x_return_status := c_success;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.unregister'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);

    -- To get di view name for tables and delete the system generated view for p_table_name
      BEGIN

	  SELECT di_view_name
	  INTO   l_di_view_name
	  FROM   fem_tables_vl
	  WHERE  table_name = p_table_name;

      EXCEPTION

	  WHEN OTHERS THEN

	    l_di_view_name := null;

      END;

	  DELETE FROM fem_tab_columns_vl
      WHERE  table_name = p_table_name;

      DELETE FROM fem_tables_vl
      WHERE  table_name = p_table_name;

      DELETE FROM fem_tab_column_prop
      WHERE  table_name = p_table_name;

      DELETE FROM fem_table_class_assignmt
      WHERE  table_name = p_table_name;

	  IF l_di_view_name is NOT NULL THEN

	    BEGIN

	    DELETE FROM FEM_SVIEW_COLUMNS WHERE view_name = l_di_view_name;

		EXECUTE IMMEDIATE 'DROP VIEW '||l_di_view_name;

		EXCEPTION

		  WHEN G_PLSQL_COMPILATION_ERROR THEN

		  NULL;

		END;

	  END IF;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.unregister'
                                   ,p_msg_text => 'END');

  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.init'
                                     ,p_msg_text => 'unregister: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'unregsiter: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);


  END unregister;

  PROCEDURE init(p_api_version     IN NUMBER,
                 p_init_msg_list   IN VARCHAR2,
                 p_commit          IN VARCHAR2,
                 p_encoded         IN VARCHAR2,
                 x_msg_count       OUT NOCOPY NUMBER,
                 x_msg_data        OUT NOCOPY VARCHAR2,
                 x_return_status   OUT NOCOPY VARCHAR2)

  IS

    l_cursor          INTEGER;
    l_rows_processed  INTEGER;

    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);


  BEGIN

      x_return_status := c_success;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.init'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);

      /*
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, 'ALTER SESSION ENABLE PARALLEL DML', dbms_sql.native);
      l_rows_processed := dbms_sql.execute(l_cursor);
      dbms_sql.close_cursor(l_cursor);
      */

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.init'
                                   ,p_msg_text => 'END');


  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.init'
                                     ,p_msg_text => 'init: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'init: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

  END init;

  PROCEDURE validateClass(p_api_version     IN NUMBER,
                          p_init_msg_list   IN VARCHAR2,
                          p_commit          IN VARCHAR2,
                          p_encoded         IN VARCHAR2,
                          p_table_name      IN VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2)
  IS
    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);


  BEGIN
      x_return_status := c_success;
      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.validate'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);

      DELETE FROM fem_table_class_assignmt ftca
      WHERE  EXISTS ( SELECT table_classification_code
                      FROM   fem_tab_class_errors_gt ftce
                      WHERE  ftce.table_classification_code = ftca.table_classification_code
                        AND  table_name = p_table_name
                        AND  ROWNUM = 1 )
        AND  table_name = p_table_name;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.validate'
                                   ,p_msg_text => 'END');
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.init'
                                     ,p_msg_text => 'validate: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'validate: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
  END validateClass;

  PROCEDURE populate_tab_col_gt(p_api_version     IN NUMBER default c_api_version,
                                p_init_msg_list   IN VARCHAR2 default c_false,
                                p_commit          IN VARCHAR2 default c_false,
                                p_encoded         IN VARCHAR2 default c_true,
                                p_mode            IN VARCHAR2,
                                p_owner           IN VARCHAR2,
                                p_table_name      IN VARCHAR2,
                                x_msg_count       OUT NOCOPY NUMBER,
                                x_msg_data        OUT NOCOPY VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2)

  IS

    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);
    l_owner           VARCHAR2(30):=p_owner;

    l_schema_return_status VARCHAR2(1);
    l_schema_msg_count     NUMBER(20);
    l_schema_msg_data      VARCHAR2(240);
    l_schema_tab_name      VARCHAR2(240);

    l_owner_error     EXCEPTION;

  BEGIN

      x_return_status := c_success;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.populate_tab_col_gt'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.populate_tab_col_gt'
                                   ,p_msg_text => 'Populating columns with data in requiremnt');

      IF p_mode = 'CREATE' THEN

         INSERT INTO fem_tab_columns_gt
         (table_name,
          column_name,
          display_name,
          description,
          data_type,
          data_length,
          data_precision,
          cpm_datatype,
          dimension_id,
          dimension_name,
          uom_column_name,
          uom_col_display_name,
          selected,
          disable_flag,
          cpm_switcher,
          dim_switcher,
          uom_switcher,
          enabled_flag,
          restricted_flag,
          update_flag  ,
          object_version_number
          )
           SELECT
             dtc.table_name,
             dtc.column_name,
             NVL(display_name, dtc.column_name) display_name,
             NVL(description,dtc.column_name) description,
             dtc.data_type,
             dtc.data_length,
             dtc.data_precision,
             nvl(fcr.fem_data_type_code,dtc.data_type) as cpm_datatype,
             fcr.dimension_id,
             (SELECT fd.dimension_name FROM fem_dimensions_tl fd
              WHERE  fd.dimension_id = fcr.dimension_id
              AND  fd.language = USERENV('LANG')
              AND  rownum = 1) as Dimension_name,
             fcr.uom_column_name,
             DECODE(uom_column_name,NULL, NULL, (SELECT display_name
                                                 FROM   fem_tab_columns_tl
                                                 WHERE  column_name = uom_column_name
                                                   AND  language = USERENV('LANG')
                                                   AND  rownum = 1)) as uom_col_display_name,
             'Y' selected,
             DECODE(dtc.nullable,'N','Y','Y','N') disable_flag,
              DECODE(fcr.restricted_flag,'Y','CpmDisabled','CpmDataType') cpm_switcher,
             DECODE(fcr.restricted_flag, 'Y',
                    DECODE(DECODE(fcr.restricted_flag,'N',NULL,fcr.dimension_id),NULL,
                           DECODE(fcr.fem_data_type_code,'DIMENSION','ronlyDimswitch','disableDimLov' ),
                           'ronlyDimswitch'),
                    DECODE(DECODE(fcr.restricted_flag,'N',NULL,fcr.dimension_id),NULL,
                           DECODE(fcr.fem_data_type_code,'DIMENSION','enableDimLov','disableDimLov' ),
                           'enableDimLov')) dim_switcher,
             DECODE(fcr.restricted_flag, 'Y',
                    DECODE(uom_column_name,NULL,
                           DECODE(fcr.fem_data_type_code,'TERM', 'ronlyUomswitch',
                                                         'STATISTIC', 'ronlyUomswitch',
                                                         'FREQ', 'ronlyUomswitch', 'disableUomLov' ),
                           'ronlyUomswitch'),
                    DECODE(uom_column_name,NULL,
                           DECODE(fcr.fem_data_type_code,'TERM', 'enableUomLov',
                                                         'STATISTIC', 'enableUomLov',
                                                         'FREQ', 'enableUomLov', 'disableUomLov' ),
                           'enableUomLov')) uom_Switcher,
              'Y' enabled_flag,
              NVL(restricted_flag,'N') restricted_flag,
             'N' update_flag,
              0   object_version_number
           FROM dba_tab_columns dtc,
                fem_column_requiremnt_vl fcr
           WHERE dtc.table_name = p_table_name
             AND dtc.owner = p_owner
             AND dtc.column_name = fcr.column_name;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_gt'
                                      ,p_msg_text => 'Populating columns with data in tab columns');

         INSERT INTO fem_tab_columns_gt
         (table_name,
          column_name,
          display_name,
          description,
          data_type,
          data_length,
          data_precision,
          cpm_datatype,
          dimension_id,
          dimension_name,
          uom_column_name,
          uom_col_display_name,
          selected,
          disable_flag,
          cpm_switcher,
          dim_switcher,
          uom_switcher,
          enabled_flag,
          restricted_flag,
          update_flag,
          object_version_number
          )
           SELECT
             dump.table_name,
             dump.column_name,
             nvl(display_name,dump.column_name) display_name,
             nvl(description,dump.column_name) description,
             dump.data_type,
             dump.data_length,
             dump.data_precision,
             nvl(ftc.fem_data_type_code,dump.data_type) as cpm_datatype,
             ftc.dimension_id,
             DECODE(ftc.dimension_id, NULL, NULL, (SELECT fd.dimension_name
                                                   FROM   fem_dimensions_tl fd
                                                   WHERE  fd.dimension_id = ftc.dimension_id
                                                     AND  fd.language = USERENV('LANG')
                                                     AND  rownum = 1)) as Dimension_name,
             ftc.uom_column_name,
             DECODE(uom_column_name,NULL, NULL, (SELECT display_name
                                                 FROM   fem_tab_columns_tl
                                                 WHERE  column_name = ftc.uom_column_name
                                                   AND  language = USERENV('LANG')
                                                   AND  rownum = 1)) as uom_col_display_name,
             'Y' selected,
             DECODE(dump.nullable,'N','Y','Y','N') disable_flag,
             'CpmDataType' cpm_switcher,
             DECODE(ftc.dimension_id,NULL,
                           DECODE(ftc.fem_data_type_code,'DIMENSION','enableDimLov','disableDimLov' ),
                           'enableDimLov') dim_switcher,
             DECODE(ftc.uom_column_name,NULL,
                           DECODE(ftc.fem_data_type_code,'TERM', 'enableUomLov',
                                                         'STATISTIC', 'enableUomLov',
                                                         'FREQ', 'enableUomLov', 'disableUomLov' ),
                           'enableUomLov') uom_Switcher,
              'Y' enabled_flag,
             'N' restricted_flag,
             'N' update_flag,
             0   object_version_number
           FROM fem_tab_columns_vl ftc,
           (
             SELECT dtc.column_name, dtc.table_name, (SELECT table_name tname
                                                      FROM   fem_tab_columns_b
                                                      WHERE  column_name = dtc.column_name AND rownum = 1) tname,
                    data_type, nullable, data_length, data_precision
             FROM   dba_tab_columns dtc
             WHERE  dtc.table_name = p_table_name
               AND  dtc.owner = p_owner
               AND  NOT EXISTS ( SELECT 1
                                 FROM   fem_tab_columns_gt fcr
                                 WHERE  fcr.column_name = dtc.column_name )) dump
           WHERE ftc.column_name = dump.column_name
             AND ftc.table_name = dump.tname;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_gt'
                                      ,p_msg_text => 'Populating columns with data in dba tab columns');

         INSERT INTO fem_tab_columns_gt
         (table_name,
          column_name,
          display_name,
          description,
          data_type,
          data_length,
          data_precision,
          cpm_datatype,
          dimension_id,
          dimension_name,
          uom_column_name,
          uom_col_display_name,
          selected,
          disable_flag,
          cpm_switcher,
          dim_switcher,
          uom_switcher,
          enabled_flag,
          restricted_flag,
          update_flag,
          object_version_number
          )
           SELECT
             table_name,
             column_name,
             column_name,
             column_name,
             data_type,
             data_length,
             data_precision,
             data_type,
             TO_NUMBER(NULL),
             NULL,
             NULL,
             NULL,
             'Y',
             DECODE(nullable,'N','Y','Y','N'),
             'CpmDataType',
             'disableDimLov',
             'disableUomLov',
             'Y',
             'N',
             'N' update_flag,
              0 object_version_number
           FROM  dba_tab_columns atc
           WHERE table_name = p_table_name
             AND atc.owner = p_owner
             AND NOT EXISTS ( SELECT 1
                              FROM   fem_tab_columns_gt ftc
                              WHERE  column_name = atc.column_name );

      ELSIF p_mode = 'UPDATE' THEN

         BEGIN

		IF l_owner is NULL THEN

         fem_database_util_pkg.get_table_owner
         (x_return_status => l_schema_return_status,
          x_msg_count => l_schema_msg_count,
          x_msg_data  => l_schema_msg_data,
          p_syn_name  => p_table_name,
          x_tab_name  => l_schema_tab_name,
          x_tab_owner => l_owner
         );

        END IF;


         EXCEPTION
            WHEN OTHERS THEN
               RAISE l_owner_error;
         END;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.synchronize'
                                      ,p_msg_text => 'After fetching the owner, owner = ' || l_owner);

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_gt'
                                      ,p_msg_text => 'Update mode: Populating columns');

         INSERT INTO fem_tab_columns_gt
         (table_name,
          column_name,
          display_name,
          description,
          data_type,
          data_length,
          data_precision,
          cpm_datatype,
          dimension_id,
          dimension_name,
          uom_column_name,
          uom_col_display_name,
          selected,
          disable_flag,
          cpm_switcher,
          dim_switcher,
          uom_switcher,
          enabled_flag,
          restricted_flag,
          update_flag,
          object_version_number
          )
           SELECT
             dtc.table_name,
             dtc.column_name,
             dtc.display_name,
             dtc.description,
             dt.data_type,
             dt.data_length,
             dt.data_precision,
             dtc.fem_data_type_code,
             dtc.dimension_id,
             DECODE(dtc.dimension_id, NULL, NULL, (SELECT fd.dimension_name
                                                   FROM   fem_dimensions_tl fd
                                                   WHERE  fd.dimension_id = dtc.dimension_id
                                                     AND  fd.language = USERENV('LANG')
                                                     AND  rownum = 1)),
             dtc.uom_column_name,
             DECODE(dtc.uom_column_name,NULL, NULL, (SELECT display_name
                                                     FROM   fem_tab_columns_tl
                                                     WHERE  column_name = dtc.uom_column_name
                                                       AND  language = USERENV('LANG')
                                                       AND  rownum = 1)),
             dtc.enabled_flag selected,
             DECODE(dt.nullable,'N','Y','Y','N') disable_flag,
             DECODE(fcr.restricted_flag,'Y','CpmDisabled','CpmDataType') cpm_switcher,
             DECODE(fcr.restricted_flag, 'Y',
                    DECODE(dtc.dimension_id,NULL,
                           DECODE(dtc.fem_data_type_code,'DIMENSION','ronlyDimswitch','disableDimLov' ),
                           'ronlyDimswitch'),
                    DECODE(dtc.dimension_id,NULL,
                           DECODE(dtc.fem_data_type_code,'DIMENSION','enableDimLov','disableDimLov' ),
                           'enableDimLov')) dim_switcher,
             DECODE(fcr.restricted_flag, 'Y',
                    DECODE(dtc.uom_column_name,NULL,
                           DECODE(dtc.fem_data_type_code,'TERM', 'ronlyUomswitch',
                                                         'STATISTIC', 'ronlyUomswitch',
                                                         'FREQ', 'ronlyUomswitch', 'disableUomLov' ),
                           'ronlyUomswitch'),
                    DECODE(dtc.uom_column_name,NULL,
                           DECODE(dtc.fem_data_type_code,'TERM', 'enableUomLov',
                                                         'STATISTIC', 'enableUomLov',
                                                         'FREQ', 'enableUomLov', 'disableUomLov' ),
                           'enableUomLov')) uom_Switcher,
             dtc.enabled_flag,
             NVL(restricted_flag,'N') restricted_flag,
             'Y' update_flag,
             dtc.object_version_number
           FROM fem_tab_columns_vl dtc,
                fem_column_requiremnt_vl fcr,
                dba_tab_columns dt
          WHERE dtc.table_name = p_table_name
            AND dtc.table_name = dt.table_name
            AND dt.column_name = dtc.column_name
            AND dtc.column_name = fcr.column_name
            AND dt.owner = l_owner;

         INSERT INTO fem_tab_columns_gt
         (table_name,
          column_name,
          display_name,
          description,
          data_type,
          data_length,
          data_precision,
          cpm_datatype,
          dimension_id,
          dimension_name,
          uom_column_name,
          uom_col_display_name,
          selected,
          disable_flag,
          cpm_switcher,
          dim_switcher,
          uom_switcher,
          enabled_flag,
          restricted_flag,
          update_flag,
          object_version_number
          )
           SELECT
             dtc.table_name,
             dtc.column_name,
             dtc.display_name,
             dtc.description,
             dt.data_type,
             dt.data_length,
             dt.data_precision,
             dtc.fem_data_type_code,
             dtc.dimension_id,
             DECODE(dtc.dimension_id, NULL, NULL, (SELECT fd.dimension_name
                                                   FROM   fem_dimensions_tl fd
                                                   WHERE  fd.dimension_id = dtc.dimension_id
                                                     AND  fd.language = USERENV('LANG')
                                                     AND  rownum = 1)),
             dtc.uom_column_name,
             DECODE(dtc.uom_column_name,NULL, NULL, (SELECT display_name
                                                     FROM   fem_tab_columns_tl
                                                     WHERE  column_name = dtc.uom_column_name
                                                       AND  language = USERENV('LANG')
                                                       AND  rownum = 1)),
             dtc.enabled_flag selected,
             DECODE(dt.nullable,'N','Y','Y','N') disable_flag,
            'CpmDataType' cpm_switcher,
             DECODE(dtc.dimension_id,NULL,
                    DECODE(dtc.fem_data_type_code,'DIMENSION','enableDimLov','disableDimLov' ),
                    'enableDimLov') dim_switcher,
             DECODE(dtc.uom_column_name,NULL,
                    DECODE(dtc.fem_data_type_code,'TERM', 'enableUomLov',
                                                  'STATISTIC', 'enableUomLov',
                                                  'FREQ', 'enableUomLov', 'disableUomLov' ),
                   'enableUomLov') uom_Switcher,
             dtc.enabled_flag,
             'N' restricted_flag,
             'Y' update_flag,
             dtc.object_version_number
           FROM fem_tab_columns_vl dtc,
                dba_tab_columns dt
          WHERE dt.table_name = p_table_name
            AND dt.table_name = dtc.table_name
            AND dt.column_name = dtc.column_name
            AND dt.owner = l_owner
            AND NOT EXISTS ( SELECT 1
                             FROM   fem_tab_columns_gt
                             WHERE  column_name = dtc.column_name );

      END IF;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.populate_tab_col_gt'
                                   ,p_msg_text => 'END');
  EXCEPTION
     WHEN l_owner_error THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_gt: Trying to get owner info. for' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_gt: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.populate_tab_col_gt'
                                     ,p_msg_text => 'populate_tab_col_gt: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_gt: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

  END populate_tab_col_gt;

  PROCEDURE populate_tab_col_vl(p_api_version     IN NUMBER default c_api_version,
                                p_init_msg_list   IN VARCHAR2 default c_false,
                                p_commit          IN VARCHAR2 default c_false,
                                p_encoded         IN VARCHAR2 default c_true,
                                p_table_name      IN VARCHAR2,
                                p_skip_validation IN VARCHAR2,
                                p_mode            IN VARCHAR2,
                                x_msg_count       OUT NOCOPY NUMBER,
                                x_msg_data        OUT NOCOPY VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2)
  IS

    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_commit          VARCHAR2(1);
    l_encoded         VARCHAR2(1);
    l_src_lang        VARCHAR2(100);

    l_user_id         NUMBER;
    l_login_id        NUMBER;

    TYPE col_tab IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

    l_column_tab      col_tab;
    l_display_tab     col_tab;
    l_no_dupes        BOOLEAN;
    l_display_name    VARCHAR2(150);
    l_concat_val      VARCHAR2(2000);
    l_init            BOOLEAN;
    i                 NUMBER;
    l_count           NUMBER;
    l_index_name      VARCHAR2(30);

    l_disp_ui_error   EXCEPTION;
    l_ovm_error       EXCEPTION;
    l_pk_error        EXCEPTION;

  BEGIN

      x_return_status := c_success;

      l_src_lang := USERENV('LANG');
      l_user_id := Fnd_Global.User_Id;
      l_login_id := Fnd_Global.Login_Id;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.populate_tab_col_vl'
                                   ,p_msg_text => 'BEGIN');

      l_api_version   := NVL(p_api_version, c_api_version);
      l_init_msg_list := NVL(p_init_msg_list, c_false);
      l_commit        := NVL(p_commit, c_false);
      l_encoded       := NVL(p_encoded, c_true);

      IF p_skip_validation = 'N' THEN

         fnd_msg_pub.initialize;

         SELECT COUNT(*)
          INTO   l_count
          FROM   fem_tab_columns_b ftc,
                 fem_tab_columns_gt ftcg
          WHERE  ftc.table_name = p_table_name
            AND  ftcg.table_name = ftc.table_name
            AND  ftc.object_version_number <> ftcg.object_version_number
            AND  ftc.column_name = ftcg.column_name;

          IF l_count <> 0 THEN
             fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_STALE_DATA_ERR');
             fnd_message.set_token('TABLE', p_table_name);
             fnd_msg_pub.add;

             RAISE l_ovm_error;
          END IF;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_vl'
                                      ,p_msg_text => 'Starting validations');

         l_init := TRUE;

         -- Get all the columns where display_name IS NULL

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt
         WHERE  display_name IS NULL;

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_DNAME_NULL_ERR');
              fnd_message.set_token('DISPNAME_NULL_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

        END IF;

        l_init := TRUE;

        -- Get all the columns where description IS NULL

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt
         WHERE  description IS NULL;

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

        IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_DESC_NULL_ERR');
              fnd_message.set_token('DESC_NULL_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

        END IF;

        l_no_dupes := TRUE;
        l_init := FALSE;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.populate_tab_col_vl'
                                     ,p_msg_text => 'Completed NULL display names and descriptions check');

         -- Get all the duplicate display name

           SELECT a.column_name,a.display_name
           BULK COLLECT INTO l_column_tab, l_display_tab
           FROM fem_tab_columns_gt a,fem_tab_columns_gt b
           WHERE UPPER(a.display_name)=UPPER(b.display_name)
           AND a.column_name <> b.column_name;

         IF l_column_tab.COUNT > 0 THEN
           l_no_dupes := FALSE;
         END IF;

         IF NOT l_no_dupes THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP

               IF l_init = FALSE THEN
                  l_init := TRUE;
                  l_display_name := l_display_tab(i);
                  l_concat_val := '(';
               END IF;

               IF l_display_tab(i) = l_display_name THEN
                  l_concat_val := l_concat_val || l_column_tab(i) || ',' ;
               ELSE
                  l_display_name := l_display_tab(i);
                  l_concat_val := RTRIM(l_concat_val,',') || ')' || ',(' || l_column_tab(i) || ',' ;
               END IF;

           END LOOP;

           l_concat_val := RTRIM(l_concat_val,',') || ')';

         END IF;

         IF l_concat_val IS NOT NULL THEN
            fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_DNAME_DUP_ERR');
            fnd_message.set_token('DISPNAME_DUP_TOK', l_concat_val);
            fnd_msg_pub.add;

            RAISE l_disp_ui_error;
         END IF;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_vl'
                                      ,p_msg_text => 'Completed duplicate display names check');

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code = 'DIMENSION' AND  dimension_id IS NULL

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt
         WHERE  cpm_datatype = 'DIMENSION'
           AND  dimension_id IS NULL
           AND SUBSTR(COLUMN_NAME,1,8) <> 'USER_DIM';

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_DIMID_NULL_ERR');
              fnd_message.set_token('DIM_NULL_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code = ('TERM','FREQ','STATISTIC') AND  uom_column_name IS NULL

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt
         WHERE  cpm_datatype IN ('TERM','FREQ','STATISTIC')
           AND  uom_column_name IS NULL;

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_UOM_NULL_ERR');
              fnd_message.set_token('UOM_NULL_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code <> ('TERM','FREQ','STATISTIC') AND  uom_column_name IS NOT NULL

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt
         WHERE  cpm_datatype NOT IN ('TERM','FREQ','STATISTIC')
           AND  uom_column_name IS NOT NULL;

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_INV_UOM_USG');
              fnd_message.set_token('INV_UOM_USG', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code = ('TERM','FREQ','STATISTIC') AND  uom_column_name IS NOT NULL
         -- and maps to one of the columns being registered.

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt a
         WHERE  cpm_datatype IN ('TERM','FREQ','STATISTIC')
           AND  uom_column_name IS NOT NULL
           AND  NOT EXISTS ( SELECT column_name
                             FROM   fem_tab_columns_gt b
                             WHERE  a.uom_column_name = b.column_name );

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_UOM_DISABLED');
              fnd_message.set_token('UOM_DISABLED_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code = ('TERM','FREQ','STATISTIC') AND  uom_column_name IS NOT NULL
         -- and maps to one of the columns being registered, that column should be of dimension type

         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt a
         WHERE  cpm_datatype IN ('TERM','FREQ','STATISTIC')
           AND  uom_column_name IS NOT NULL
           AND  NOT EXISTS ( SELECT column_name
                             FROM   fem_tab_columns_gt b
                             WHERE  a.uom_column_name = b.column_name
                               AND  b.cpm_datatype = 'DIMENSION' );

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_UOM_FEMDT_ERR');
              fnd_message.set_token('UOM_FEM_DT_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

         l_init := TRUE;

         -- Get all the columns where fem_data_type_code = ('TERM','FREQ','STATISTIC') AND  uom_column_name IS NOT NULL
         -- and maps to one of the columns being registered, that column should be of dimension type, it should be unique


         SELECT column_name
         BULK COLLECT INTO l_column_tab
         FROM   fem_tab_columns_gt a
         WHERE  cpm_datatype IN ('TERM','FREQ','STATISTIC')
           AND  uom_column_name IS NOT NULL
           AND  uom_column_name in (SELECT uom_column_name
                                    FROM   fem_tab_columns_gt b
                                    GROUP BY uom_column_name
                                    HAVING COUNT(uom_column_name)>1);

         IF l_column_tab.COUNT > 0 THEN
           l_init := FALSE;
         END IF;

         IF NOT l_init THEN

           FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
               l_concat_val := l_concat_val || ',' || l_column_tab(i);
           END LOOP;

           l_concat_val := LTRIM(l_concat_val,',');

           IF l_concat_val IS NOT NULL THEN
              fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_UOM_DUP_ERR');
              fnd_message.set_token('UOM_DUP_TOK', l_concat_val);
              fnd_msg_pub.add;

              RAISE l_disp_ui_error;
           END IF;

         END IF;

          IF p_mode = 'UPDATE' THEN
             SELECT proc_key_index_name
             INTO   l_index_name
             FROM   fem_tables_b ftb
             WHERE  table_name = p_table_name;

             SELECT ftcb.column_name
             BULK COLLECT INTO l_column_tab
             FROM  fem_tab_columns_gt ftcb,
                   fem_tab_column_prop ftcp
             WHERE ftcb.table_name = p_table_name
               AND ftcb.table_name = ftcp.table_name
               AND ftcp.column_property_code = 'PROCESSING_KEY'
               AND ftcp.column_name = ftcb.column_name
               AND ftcb.enabled_flag = 'N';

             IF l_column_tab.COUNT > 0 THEN
                l_init := FALSE;
             END IF;

             IF NOT l_init THEN

                FOR i IN l_column_tab.FIRST..l_column_tab.LAST LOOP
                    l_concat_val := l_concat_val || ',' || l_column_tab(i);
                END LOOP;

                l_concat_val := LTRIM(l_concat_val,',');

                IF l_concat_val IS NOT NULL THEN
                   fnd_message.set_name('FEM', 'FEM_TR_PK_COLS_DISABLED_ERR');
                   fnd_message.set_token('COLUMNS', l_concat_val);
                   fnd_message.set_token('PROCKEY', l_index_name);
                   fnd_msg_pub.add;

                   RAISE l_pk_error;
                END IF;

             END IF;
          END IF;

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_tab_col_vl'
                                      ,p_msg_text => 'Completed dimension_id and uom_column_name checks');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.populate_tab_col_vl'
                                     ,p_msg_text => 'Completed validations');
      END IF;

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.populate_tab_col_vl'
                                   ,p_msg_text => 'Before insert into _B');

      SELECT COUNT(*)
       INTO   l_count
       FROM   fem_tab_columns_b ftc,
              fem_tab_columns_gt ftcg
       WHERE  ftc.table_name = p_table_name
         AND  ftcg.table_name = ftc.table_name
         AND  ftc.object_version_number <> ftcg.object_version_number
         AND  ftc.column_name = ftcg.column_name;

       IF l_count <> 0 THEN
          fnd_message.set_name('FEM', 'FEM_TR_OBJ_COL_STALE_DATA_ERR');
          fnd_message.set_token('TABLE', p_table_name);
          fnd_msg_pub.add;

          RAISE l_ovm_error;
       END IF;

      MERGE INTO fem_tab_columns_b ftc
      USING fem_tab_columns_gt ftcg
      ON ( ftc.column_name = ftcg.column_name
           AND ftc.table_name = p_table_name )
      WHEN MATCHED THEN UPDATE
      SET
          ftc.enabled_flag = ftcg.enabled_flag,
          ftc.fem_data_type_code  = NVL(ftcg.cpm_datatype,'UNDEFINED'),
          ftc.dimension_id = ftcg.dimension_id,
          ftc.uom_column_name = ftcg.uom_column_name,
          ftc.last_updated_by = l_user_id,
          ftc.last_update_date = SYSDATE,
          ftc.last_update_login = l_login_id,
          ftc.object_version_number = NVL(ftc.object_version_number,0) + 1
      WHEN NOT MATCHED THEN
        INSERT
        (
          enabled_flag,
          interface_column_name,
          table_name,
          column_name,
          fem_data_type_code,
          dimension_id,
          uom_column_name,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number
        )
        VALUES( ftcg.enabled_flag,
               NULL,
               ftcg.table_name,
               ftcg.column_name,
               NVL(ftcg.cpm_datatype,'UNDEFINED'),
               ftcg.dimension_id,
               ftcg.uom_column_name,
               SYSDATE,
               l_user_id,
               SYSDATE,
               l_user_id,
               l_login_id,
               1
              );

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.populate_tab_col_vl'
                                   ,p_msg_text => 'Before insert into _TL');

      MERGE INTO fem_tab_columns_tl ftc
      USING (SELECT  tcgt.*,fndl.language_code
 	              FROM fem_tab_columns_gt tcgt,
 	                   fnd_languages fndl
 	              WHERE fndl.installed_flag IN ('I','B')) ftcg
      ON ( ftc.column_name = ftcg.column_name
	   AND ftc.table_name =  ftcg.table_name
	   AND ftc.language = ftcg.language_code
	   AND ftcg.table_name = p_table_name )
      WHEN MATCHED THEN UPDATE
      SET
          ftc.display_name = DECODE(USERENV('LANG'),
                                    ftc.language,ftcg.display_name,
 	                            ftc.source_lang,ftcg.display_name,
 	                            ftc.display_name),
          ftc.description = DECODE(USERENV('LANG'),
 	                           ftc.language,ftcg.description,
 	                           ftc.source_lang,ftcg.description,
 	                           ftc.description),
          ftc.last_updated_by = l_user_id,
          ftc.last_update_date = SYSDATE,
          ftc.last_update_login = l_login_id,
          ftc.source_lang =  DECODE(USERENV('LANG'),
                                    ftc.language,ftcg.language_code,
 	                            ftc.source_lang)
      WHEN NOT MATCHED THEN
        INSERT
        (
          language,
          table_name,
          column_name,
          source_lang,
          display_name,
          description,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
        )
        VALUES(
               ftcg.language_code,
               ftcg.table_name,
               ftcg.column_name,
               USERENV('LANG'),
               ftcg.display_name,
               ftcg.description,
               SYSDATE,
               l_user_id,
               SYSDATE,
               l_user_id,
               l_login_id
              );

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.populate_tab_col_vl'
                                   ,p_msg_text => 'END');

  EXCEPTION

     WHEN l_disp_ui_error THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.populate_tab_col_vl'
                                     ,p_msg_text => 'populate_tab_col_vl: UI validation failed for ' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_vl: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

     WHEN l_pk_error THEN
         x_return_status := c_error;

         fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                      ,p_module   => g_block||'.populate_tab_col_vl'
                                      ,p_msg_text => 'populate_tab_col_vl: Columns disabled form part of Processing Key' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_vl: error = ' || SQLERRM);

         fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);


      WHEN l_ovm_error THEN
         x_return_status := c_error;

         fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                      ,p_module   => g_block||'.populate_tab_col_vl'
                                      ,p_msg_text => 'populate_tab_col_vl: Stale data error for ' || p_table_name);

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_vl: error = ' || SQLERRM);

         fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);

     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.populate_tab_col_vl'
                                     ,p_msg_text => 'populate_tab_col_vl: General_Exception');

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.synchronize'
                                     ,p_msg_text => 'populate_tab_col_vl: error = ' || SQLERRM);

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

  END populate_tab_col_vl;

  PROCEDURE dump_gt(p_api_version     IN NUMBER default c_api_version,
                    p_init_msg_list   IN VARCHAR2 default c_false,
                    p_commit          IN VARCHAR2 default c_false,
                    p_encoded         IN VARCHAR2 default c_true,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2)
  IS

  BEGIN

      x_return_status := c_success;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.dump_gt'
                                   ,p_msg_text => 'BEGIN');

      DELETE FROM fem_tab_columns_gt;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.dump_gt'
                                   ,p_msg_text => 'END');


  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := c_error;

        fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                     ,p_module   => g_block||'.dump_gt'
                                     ,p_msg_text => 'dump_gt: General_Exception');

        fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);

  END dump_gt;

   FUNCTION is_table_registered(p_table_name IN VARCHAR2) RETURN VARCHAR2
   IS
   l_valid_flag VARCHAR2(1);
   BEGIN
     l_valid_flag := 'N';

     SELECT enabled_flag INTO l_valid_flag
     FROM fem_tables_b
     WHERE table_name=p_table_name;

     RETURN l_valid_flag;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          fem_engines_pkg.user_message(p_app_name =>'FEM',
                                       p_msg_name =>'FEM_TAB_NOT_REG_ERR',
                                       p_token1=>'TABLE_NAME',
                                       p_value1=>p_table_name);
          RETURN l_valid_flag;
   END;

  FUNCTION is_table_column_registered(p_table_name IN VARCHAR2,
                                      p_column_name IN VARCHAR2) RETURN VARCHAR2
  IS
      l_valid_flag VARCHAR2(1);
   BEGIN

     l_valid_flag := 'N';

     SELECT enabled_flag INTO l_valid_flag
     FROM fem_tab_columns_b
     WHERE table_name=p_table_name
     AND column_name = p_column_name;

     RETURN l_valid_flag;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          fem_engines_pkg.user_message(p_app_name =>'FEM',
                                       p_msg_name =>'FEM_TAB_COL_NOT_REG_ERR',
                                       p_token1=>'TABLE_NAME',
                                       p_value1=>p_table_name,
                                       p_token2=>'COLUMN_NAME',
                                       p_value2=>p_column_name);
                      RETURN l_valid_flag;
   END;

  FUNCTION is_table_class_code_valid(p_table_name VARCHAR2,
                                     p_table_class_code VARCHAR2) RETURN VARCHAR2
   IS
       l_valid_flag VARCHAR2(1);
   BEGIN
       l_valid_flag := 'N';
              IF is_table_registered(p_table_name) <> 'Y' THEN
               RETURN 'N';
       END IF;
       SELECT DECODE(count(*),0,'N','Y') INTO l_valid_flag
       FROM fem_table_class_assignmt
       WHERE table_classification_code = p_table_class_code
       AND table_name = p_table_name
       AND enabled_flag='Y';

       RETURN l_valid_flag;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          fem_engines_pkg.user_message(p_app_name =>'FEM',
                                       p_msg_name =>'FEM_TAB_NOT_CLASS_ERR',
                                       p_token1=>'TABLE_NAME',
                                       p_value1=>p_table_name,
                                       p_token2=>'CLASSIFICATIONS',
                                       p_value2=>p_table_class_code);
               RETURN l_valid_flag;
   END;

  FUNCTION is_table_class_list_valid(p_table_name VARCHAR2,
                                     p_table_class_lookup_type VARCHAR2) RETURN VARCHAR2
  IS
   l_valid_flag VARCHAR2(1);
   l_concat_classif VARCHAR2(2000);
   l_classif VARCHAR2(100);

   CURSOR classifs(c_table_class_lookup_type VARCHAR2) IS
                   SELECT lookup_code
                   FROM fnd_lookup_values
                   WHERE lookup_type=c_table_class_lookup_type
                   AND language=userenv('LANG') ;
  BEGIN
     l_valid_flag := 'N';

     IF is_table_registered(p_table_name) <> 'Y' THEN
       RETURN 'N';
     END IF;
     l_concat_classif := '';
     OPEN classifs(p_table_class_lookup_type);
     LOOP
           FETCH classifs INTO l_classif;
           EXIT WHEN classifs%NOTFOUND;
           l_concat_classif := l_concat_classif || ',' || l_classif ;
     END LOOP;
     CLOSE classifs;
     l_concat_classif := LTRIM(l_concat_classif,',');
          SELECT DECODE(count(*),0,'N','Y') INTO l_valid_flag
     FROM fem_table_class_assignmt
     WHERE table_classification_code IN (SELECT lookup_code
                   FROM fnd_lookup_values
                   WHERE lookup_type=p_table_class_lookup_type
                   AND language=userenv('LANG'))
     AND table_name = p_table_name
     AND enabled_flag='Y';


     RETURN l_valid_flag;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          fem_engines_pkg.user_message(p_app_name =>'FEM',
                                       p_msg_name =>'FEM_TAB_NOT_CLASS_ERR',
                                       p_token1=>'TABLE_NAME',
                                       p_value1=>p_table_name,
                                       p_token2=>'CLASSIFICATIONS',
                                       p_value2=>l_concat_classif);             RETURN l_valid_flag;
 END;


 FUNCTION get_schema_name(p_app_id IN NUMBER)
      RETURN VARCHAR2 IS

   l_status VARCHAR2(100);
   l_industry VARCHAR2(100);
   l_schema VARCHAR2(10);
   l_app_short_name VARCHAR2(50);
   l_ret_status BOOLEAN;

 BEGIN

   SELECT application_short_name
   INTO   l_app_short_name
   FROM   fnd_application
   WHERE  application_id = p_app_id;

   l_ret_status := fnd_installation.get_app_info(l_app_short_name,l_status,l_industry,l_schema);

   RETURN l_schema;

 EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20101,'No valid schema exists');

 END;

 FUNCTION get_schema_name(p_app_short_name IN VARCHAR2)
   RETURN VARCHAR2 IS

   l_status VARCHAR2(100);
   l_industry VARCHAR2(100);
   l_schema VARCHAR2(10);

   l_ret_status BOOLEAN;

 BEGIN

   l_ret_status := fnd_installation.get_app_info(p_app_short_name,l_status,l_industry,l_schema);

   RETURN l_schema;

  EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20101,'No valid schema exists');

 END;

 PROCEDURE raise_proc_key_update_event(p_table_name    IN VARCHAR2,
                                       x_msg_count     OUT NOCOPY NUMBER,
                                       x_msg_data      OUT NOCOPY VARCHAR2,
                                       x_return_status OUT NOCOPY VARCHAR2
  )

 IS
  l_event_name     VARCHAR2(240) := 'oracle.apps.fem.admin.prockey.updated';
  l_event_key      VARCHAR2(240);

  l_parameter_list     wf_parameter_list_t;
  l_event              wf_event_t;

  l_api_name    CONSTANT  VARCHAR2(30) := 'raise_proc_key_update_event';
  l_api_version CONSTANT  NUMBER       :=  1.0;

 BEGIN

   FEM_ENGINES_PKG.Tech_Message (
          p_severity  => fnd_log.level_procedure
          ,p_module   => g_block||'.'||l_api_name
          ,p_msg_text => 'Begining Function');

   x_return_status := c_success;

   l_event_key := p_table_name ||'_'|| sysdate;

   wf_event_t.initialize(l_event);

   l_event.AddParameterToList(G_TABLE_NAME, p_table_name);

   l_parameter_list := l_event.getParameterList();

   wf_event.raise(
     p_event_name => l_event_name
     ,p_event_key =>  l_event_key
     ,p_parameters => l_parameter_list);

   l_parameter_list.delete;

 EXCEPTION

   WHEN OTHERS THEN
     x_return_status := c_error;

     fem_engines_pkg.tech_message (
       p_severity  => fnd_log.level_unexpected
       ,p_module   => g_block||'.'||l_api_name
       ,p_msg_text => SQLERRM
      );

     fnd_msg_pub.add_exc_msg(g_block, l_api_name);

     RAISE fnd_api.g_exc_unexpected_error;
 END;

/*============================================================================+
 | PROCEDURE
 |   get_tab_list
 |
 | DESCRIPTION
 |   This Procedure retrieves the underlying base tables and their unique Indexes
 |   for a view.This proc can not be used for Views containing UNIONS and DB Links.
 |   After resolving the base tables and uniques indexes, it populates two GTs;
 |   one containing the information of base tables and  their owners and other
 |   containing information for their unique indexes.
 |
 | SCOPE - PUBLIC
 +============================================================================*/

 PROCEDURE get_tab_list(
                       p_view_name      IN VARCHAR2
		       ,x_msg_count     OUT NOCOPY NUMBER
                       ,x_msg_data      OUT NOCOPY VARCHAR2
 		       ,x_return_status OUT NOCOPY VARCHAR2
					   )

 IS

  TYPE char_table IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

  g_tab_list_tab     char_table;
  g_owner_list_tab   char_table;

  l_str        CLOB;

  l_from       NUMBER;
  l_where      NUMBER;
  l_to         NUMBER;

  i            NUMBER  := 1;
  j            NUMBER  := 1;

  l_tab        VARCHAR2(100);

  l_where_flag BOOLEAN := FALSE;
  l_db_link    BOOLEAN := FALSE;
  l_union_flag BOOLEAN := FALSE;

BEGIN


  SELECT dbms_metadata.get_ddl('VIEW',p_view_name)
  INTO l_str
  FROM dual;


  l_str := UPPER(l_str);

  IF INSTR(l_str,'UNION ') > 0 THEN

     --x_ret_val := 'U';
     l_union_flag := TRUE;
  END IF;

  IF INSTR(l_str,'@') > 0 THEN

     --x_ret_val := 'D';
     l_db_link := TRUE;
  END IF;

  l_where := INSTR(l_str,'WHERE ') ;

  IF l_where > 0 THEN

     l_where_flag := TRUE;
  END IF;

  l_str := SUBSTR(l_str, INSTR(l_str,'FROM ')+5, LENGTH(l_str));

  IF NOT l_union_flag AND NOT l_db_link THEN

     IF l_where_flag THEN
        l_str := SUBSTR(l_str, 1, INSTR(l_str, 'WHERE ')-1);
     END IF;

     l_str := LTRIM(RTRIM(l_str));

     l_str := l_str || ', ';

     LOOP
        l_tab := SUBSTR(l_str, j, INSTR(l_str,',')-1);
        j := j + LENGTH(l_tab) + 2; -- to jump ahead of ','
        l_tab := LTRIM(RTRIM(l_tab));

        IF INSTR(l_tab, ' ') > 0 THEN
           l_tab := SUBSTR(l_tab, 1, INSTR(l_tab,' ')-1);
        END IF;

        g_owner_list_tab(i) := NULL;
        IF INSTR(l_tab,'.') > 0 THEN
           l_tab := SUBSTR(l_tab, INSTR(l_tab,'.')+1, LENGTH(l_tab));
           g_owner_list_tab(i) := SUBSTR(l_tab, 1, INSTR(l_tab, '.') - 1);
        END IF;
        g_tab_list_tab(i) := l_tab;
        i := i +1;
        EXIT WHEN j > LENGTH(l_str);
     END LOOP;

  END IF;


  IF g_tab_list_tab.EXISTS(1) AND NOT l_db_link AND NOT l_union_flag THEN

     DELETE fem_tab_info_gt;

     DELETE fem_tab_indx_info_gt;


     FORALL k IN 1..g_tab_list_tab.COUNT
       INSERT INTO fem_tab_info_gt
       (table_name, owner, db_link)
       SELECT table_name,
              table_owner,
              NULL
       FROM   user_synonyms
       WHERE  synonym_name = g_tab_list_tab(k)
       UNION
       SELECT g_tab_list_tab(k),
              g_owner_list_tab(k),
              NULL
       FROM   dual;


     INSERT INTO fem_tab_indx_info_gt(table_name,index_name,column_name,column_position)
       SELECT aic.table_name,
              aic.index_name,
              aic.column_name,
              aic.column_position
       FROM   all_ind_columns aic,
              all_indexes ai,
              all_updatable_columns uuc,
              fem_tab_info_gt ftig
       WHERE  ai.index_name = aic.index_name
         AND  ai.table_name = aic.table_name
         AND  ai.uniqueness = 'UNIQUE'
         AND  ai.index_type = 'NORMAL'
         AND  ftig.table_name = aic.table_name
         AND  aic.table_name = uuc.table_name
         AND  uuc.table_name = ai.table_name
         AND  uuc.column_name = aic.column_name
         AND  ftig.owner = aic.index_owner
         AND  aic.index_owner = uuc.owner
         AND  uuc.owner = ai.owner
         AND  uuc.updatable = 'YES'
       ORDER BY index_name, column_position;
  END IF;


END get_tab_list;

/*============================================================================+
 | PROCEDURE
 |   get_Object_Type
 |
 | DESCRIPTION
 |   This function returns 'FEM_TABLE'/'FEM_VIEW' depending on the passed object
 |   type is a data base table/View
 |
 | SCOPE - PUBLIC
 +============================================================================*/

  FUNCTION get_Object_Type(
                        p_object_name IN VARCHAR2)
  RETURN VARCHAR2

  IS
  l_obj_type    VARCHAR2(19):= 'TABLE';
  l_apps        VARCHAR2(30):=USER;

  BEGIN

  SELECT decode(object_type,'TABLE','FEM_TABLE','VIEW','FEM_VIEW','SYNONYM','FEM_TABLE')
  INTO   l_obj_type
  FROM   all_objects
  WHERE  owner=l_apps
  AND    OBJECT_NAME = p_object_name;

  RETURN l_obj_type;

  END get_Object_Type;

/*============================================================================+
 | PROCEDURE
 |   get_Fem_Object_Type
 |
 | DESCRIPTION
 |   This function returns 'FEM_VIEW'/'FEM_TABLE' depending on the passed object
 |   type has a DI Read Only classificationassigned or not.
 |
 | SCOPE - PUBLIC
 +============================================================================*/


  FUNCTION get_Fem_Object_Type(
                          p_object_name IN VARCHAR2)
    RETURN VARCHAR2

    IS
    l_obj_type    VARCHAR2(19):= 'FEM_TABLE';
    i             NUMBER :=0;

    BEGIN

    SELECT count(*)
    INTO   i
    FROM   fem_table_class_assignmt
    WHERE  table_name = p_object_name
    AND    TABLE_CLASSIFICATION_CODE = 'DI_READ_ONLY';

    IF (i = 1) THEN
     l_obj_type := 'FEM_VIEW';

	END IF;

    RETURN l_obj_type;

   END get_Fem_Object_Type;

/*============================================================================+
 | FUNCTION
 |   get_di_view_details
 |
 | DESCRIPTION
 |   This proc returns the DI View Name and its status passing the table name
 |
 | SCOPE - PUBLIC
 +============================================================================*/


   FUNCTION get_di_view_details(p_table_name IN VARCHAR2) RETURN VARCHAR2
     AS
        x_di_view_name varchar2(30);
        BEGIN
          SELECT di_view_name INTO x_di_view_name FROM fem_tables_b
          WHERE table_name = p_table_name
          AND EXISTS (SELECT 1 FROM user_objects WHERE object_name = di_view_name
          AND status = 'VALID');

          RETURN x_di_view_name;

  END get_di_view_details;

/*============================================================================+
 | PROCEDURE
 |   GenerateSysView
 |
 | DESCRIPTION
 |   This proc generates the View for a table which is used in DI for showing
 |   IDs/Codes/Names for dimension members.The view is based on
 |   > All not null dimension columns
 |   > All dimension columns which are part of processing key.
 |   > All balance type columns
 |
 | SCOPE - PUBLIC
 +============================================================================*/


PROCEDURE GenerateSysView (errbuf          OUT  NOCOPY VARCHAR2
                            ,retcode        OUT  NOCOPY VARCHAR2
			                ,p_tab_name     IN VARCHAR
                            ,p_view_name    IN VARCHAR)
    AS
    TYPE attr_list_rec IS RECORD
    (
      attribute_tab_name   VARCHAR2(30),
      attribute_tab_count  NUMBER,
      table_alias          VARCHAR2(30)
    );

    TYPE attr_list_arr IS TABLE OF attr_list_rec INDEX BY BINARY_INTEGER;

    TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE char_table IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

    gs_col_name_tab     char_table;
    gs_disp_name_tab    char_table;
    gs_null_flag_tab    char_table;
	g_mem_dc_code_tab   char_table;

	g_view_col_tab      char_table;

    g_dim_tab           number_table;
    gs_dim_id_tab       number_table;

    l_tab_alias         VARCHAR2(30);
    l_vl_tab_alias      VARCHAR2(30);

    j                   NUMBER := 1;

    select_list         LONG;
    from_clause         LONG;
    where_clause        LONG;


    attr_list_tbl       attr_list_arr;

    c_api_version       CONSTANT  NUMBER       := 1.0;

     f1                 utl_file.file_type;

    v_amount            NUMBER  DEFAULT 32000;
    v_offset            NUMBER(38) DEFAULT 1;
    v_chunksize         INTEGER;

    l_oj                VARCHAR2(10);
    l_owner             VARCHAR2(30);
    l_api_name          VARCHAR2(40):= 'GenerateSysView';
    l_prg_msg           VARCHAR2(2000);
    l_view_name         VARCHAR2(30);

	l_tmp_string_dc     VARCHAR2(30);
    l_tmp_string_dn     VARCHAR2(30);
	l_tmp_string_id     VARCHAR2(30);

    FUNCTION get_alias(p_tab_name IN VARCHAR2,
                       p_alias IN VARCHAR2 )

               RETURN VARCHAR2 IS

      l_alias    VARCHAR2(10);
      l_tab_name VARCHAR2(30);

    BEGIN



      l_alias := p_alias || SUBSTR(p_tab_name,1,1);

      IF INSTR(p_tab_name,'_') > 0 THEN
         l_tab_name := SUBSTR(p_tab_name,INSTR(p_tab_name,'_')+1,LENGTH(p_tab_name));
         l_alias := get_alias(l_tab_name,l_alias);
      END IF;




      RETURN l_alias;

    END get_alias;

    ------------------------------------------------
    -- end get_alias returns an alias for a table --
    ------------------------------------------------

    --------------------------------------------
    -- get_alias returns number of times a table
    -- has been repeated in FROM clause
    -- concatenated with table alias
    -- Output: FCL2
    --------------------------------------------

    PROCEDURE get_alias(p_attr_detail_rec IN  OUT NOCOPY attr_list_arr,
                        p_tab_name        IN  VARCHAR2,
                        p_alias           OUT NOCOPY VARCHAR2)
     IS

      i        NUMBER;
      l_count  NUMBER;
      l_where  NUMBER;

    BEGIN

      i       := 0;
      l_count := 1;
      l_where := 1;

      IF p_attr_detail_rec.EXISTS(1) THEN
         FOR i IN p_attr_detail_rec.FIRST .. p_attr_detail_rec.LAST LOOP
             IF p_attr_detail_rec(i).attribute_tab_name = p_tab_name THEN
                l_count := p_attr_detail_rec(i).attribute_tab_count + 1;
                l_where := i;
                EXIT;
             ELSE
                l_where := l_where + 1;
             END IF;
         END LOOP;
      END IF;

      p_attr_detail_rec(l_where).attribute_tab_name := p_tab_name;

      p_attr_detail_rec(l_where).attribute_tab_count := l_count;

      p_alias := get_alias(p_attr_detail_rec(l_where).attribute_tab_name,'') ||  TO_CHAR(l_count);



    END get_alias;

    FUNCTION check_dim_rec(p_dimension_id IN NUMBER)
    RETURN BOOLEAN IS

     exist_status BOOLEAN := FALSE;

    BEGIN

      IF g_dim_tab.EXISTS(1) THEN
         FOR i IN 1..g_dim_tab.COUNT LOOP
           IF g_dim_tab(i) = p_dimension_id THEN
              exist_status := TRUE;
           END IF;
         END LOOP;

      END IF;

      IF NOT exist_status THEN
         g_dim_tab(g_dim_tab.COUNT + 1) := p_dimension_id;
      END IF;

      RETURN exist_status;

    END check_dim_rec;

	FUNCTION check_mem_dc_rec(p_mem_dc_code IN VARCHAR2)
    RETURN BOOLEAN IS

     exist_status BOOLEAN := FALSE;

    BEGIN

      IF g_mem_dc_code_tab.EXISTS(1) THEN
         FOR i IN 1..g_mem_dc_code_tab.COUNT LOOP
           IF g_mem_dc_code_tab(i) = p_mem_dc_code THEN
              exist_status := TRUE;
           END IF;
         END LOOP;

      END IF;

      IF NOT exist_status THEN
         g_mem_dc_code_tab(g_mem_dc_code_tab.COUNT + 1) := p_mem_dc_code;
      END IF;

      RETURN exist_status;

    END check_mem_dc_rec;

    FUNCTION check_view_column(p_view_col IN VARCHAR2)
    RETURN BOOLEAN IS

     exist_status BOOLEAN := FALSE;

    BEGIN

      IF g_view_col_tab.EXISTS(1) THEN
         FOR i IN 1..g_view_col_tab.COUNT LOOP
           IF g_view_col_tab(i) = p_view_col THEN
              exist_status := TRUE;
           END IF;
         END LOOP;

      END IF;

      IF NOT exist_status THEN
         g_view_col_tab(g_view_col_tab.COUNT + 1) := p_view_col;
      END IF;

      RETURN exist_status;

    END check_view_column;

	FUNCTION get_view_col_alias(p_view_col IN VARCHAR2,p_col_suffix IN VARCHAR2)
    RETURN VARCHAR2 IS

     l_view_column   VARCHAR2(30):=p_view_col;
     i               NUMBER:=1;

    BEGIN

      While(check_view_column(l_view_column)) LOOP

        l_view_column:=SUBSTR(l_view_column,1,24)||'_'||p_col_suffix||i;
		i:=i+1;

      END LOOP;

	  RETURN l_view_column;

    END get_view_col_alias;


BEGIN

 UPDATE fem_tables_b set di_view_name = NULL where table_name=p_tab_name;

 COMMIT; --Set di view name to null in begining


 FEM_ENGINES_PKG.TECH_Message (
    p_severity  => g_log_level_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

 l_tab_alias := get_alias(p_tab_name,'');
 from_clause := p_tab_name || ' ' || l_tab_alias;

 SELECT  table_owner
 INTO    l_owner
 FROM    user_synonyms
 WHERE   synonym_name = p_tab_name;

 l_view_name:=p_view_name;

 IF l_view_name is NULL THEN

 l_view_name:=SUBSTR(p_tab_name,1,26)||'_TRV';

 END IF;

 FEM_ENGINES_PKG.USER_Message (
    p_msg_text => 'Table Name::'||p_tab_name||'::::'||'View Name ::'||l_view_name
  );

  SELECT ftcv.column_name,
         NVL(ftcv.dimension_id, -1),
         nullable,
         display_name
  BULK COLLECT INTO gs_col_name_tab,
                    gs_dim_id_tab,
                    gs_null_flag_tab,
                    gs_disp_name_tab
  FROM   fem_tab_columns_vl ftcv,
         dba_tab_columns dtc
  WHERE  ftcv.table_name = dtc.table_name
  AND   ftcv.column_name = dtc.column_name
  AND   dtc.owner  = l_owner
  AND   ftcv.enabled_flag='Y'
  AND (EXISTS
         (
		   SELECT column_name
		   FROM fem_tab_column_prop
		   WHERE column_property_code='PROCESSING_KEY'
		   AND table_name = ftcv.table_name
		   AND column_name =  ftcv.column_name)
		OR
		   (dtc.nullable='N' and ftcv.fem_data_type_code = 'DIMENSION')
		OR
		   (ftcv.fem_data_type_code = 'BALANCE'))
  AND dtc.table_name = p_tab_name
  ORDER BY NVL(ftcv.dimension_id, -1) asc;


  DELETE FROM FEM_SVIEW_COLUMNS WHERE view_name=l_view_name;

  --First loop through all columns and prepare select list and populate fem_sview_columns
  FOR i IN 1..gs_col_name_tab.COUNT LOOP


    l_tmp_string_id := get_view_col_alias(gs_col_name_tab(i),'ID');

    select_list := select_list || ',' || l_tab_alias || '.' ||gs_col_name_tab(i)||' '|| l_tmp_string_id;

    insert into fem_sview_columns (view_name,tbl_column_name,dimension_id,disp_code_column, disp_name_column) values(l_view_name,l_tmp_string_id,null,l_tmp_string_id,l_tmp_string_id);

  END LOOP;

  --Again loop and update fem_sview_columns..this is to avoid duplicate columns name in View.

  FOR i IN 1..gs_col_name_tab.COUNT LOOP

    IF gs_dim_id_tab(i) <> -1 OR (gs_col_name_tab(i) NOT IN ('LAST_UPDATED_BY_OBJECT_ID',
                                                             'LAST_UPDATED_BY_REQUEST_ID',
                                                             'CREATED_BY_OBJECT_ID',
                                                             'CREATED_BY_REQUEST_ID')
                                  AND gs_dim_id_tab(i) > 0 )
    THEN

       FOR metadata_rec IN (SELECT member_display_code_col, member_name_col,
                                   member_vl_object_name, member_col, value_set_required_flag
                            FROM   fem_xdim_dimensions
                            WHERE  dimension_id = gs_dim_id_tab(i))
       LOOP

         j := j + 1;

         get_alias(attr_list_tbl, metadata_rec.member_vl_object_name, l_vl_tab_alias);

         l_vl_tab_alias := l_vl_tab_alias || j;

		 --l_tmp_string_id := get_view_col_alias(gs_col_name_tab(i),'ID');

         --select_list := select_list || ',' || l_tab_alias  || '.' || l_tmp_string_id;

         IF gs_null_flag_tab(i) = 'Y' THEN
            l_oj := '(+)';
         ELSE
            l_oj := '';
         END IF;

		l_tmp_string_dc := get_view_col_alias(metadata_rec.member_display_code_col,'DC');

        select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_display_code_col ||' '||l_tmp_string_dc;

		l_tmp_string_dn := get_view_col_alias(metadata_rec.member_name_col,'DN');

		select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_name_col ||' '||l_tmp_string_dn ;


        UPDATE fem_sview_columns SET dimension_id = gs_dim_id_tab(i), disp_code_column = l_tmp_string_dc, disp_name_column = l_tmp_string_dn
		WHERE view_name = l_view_name
		AND   tbl_column_name = gs_col_name_tab(i);



        /*IF check_dim_rec(gs_dim_id_tab(i)) OR (check_mem_dc_rec(metadata_rec.member_display_code_col)) OR (gs_col_name_tab(i) = metadata_rec.member_display_code_col) THEN
            select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_display_code_col || ' ' || SUBSTR(gs_col_name_tab(i),1,27) || '_DC';
            select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_name_col || ' ' || SUBSTR(gs_col_name_tab(i),1,27) || '_DN';

            insert into fem_sview_columns (view_name,tbl_column_name, dimension_id, disp_code_column, disp_name_column)
            values(l_view_name,gs_col_name_tab(i),gs_dim_id_tab(i),
            SUBSTR(gs_col_name_tab(i),1,27) || '_DC',SUBSTR(gs_col_name_tab(i),1,27) || '_DN');

         ELSE
            select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_display_code_col;
            select_list := select_list || ',' || l_vl_tab_alias || '.' || metadata_rec.member_name_col ;


            insert into fem_sview_columns (view_name,tbl_column_name, dimension_id, disp_code_column, disp_name_column)
            values(l_view_name,gs_col_name_tab(i),gs_dim_id_tab(i),
            metadata_rec.member_display_code_col,metadata_rec.member_name_col);
         END IF;*/

         from_clause := from_clause || ',' || metadata_rec.member_vl_object_name || ' ' || l_vl_tab_alias;

         where_clause := where_clause || ' AND ' || l_vl_tab_alias || '.' || metadata_rec.member_col || l_oj || ' = ' || l_tab_alias || '.' || gs_col_name_tab(i);

       END LOOP;

    END IF;

  END LOOP;


  IF select_list is NOT NULL THEN
   select_list := ' SELECT ' || RTRIM(LTRIM(select_list,','),',');

    FEM_ENGINES_PKG.USER_Message (
    p_msg_text => 'Preparing Select Clause::'||select_list
  );

  END IF;

  IF from_clause is NOT NULL THEN
   from_clause := ' FROM   ' || LTRIM(from_clause,',');

   FEM_ENGINES_PKG.USER_Message (
    p_msg_text => 'Preparing From Clause::'||from_clause
  );

  END IF;

  IF where_clause is NOT NULL THEN
   where_clause := ' WHERE ' || LTRIM(where_clause,' AND ');

   FEM_ENGINES_PKG.user_Message (
    p_msg_text => 'Preparing Where Clause::'||where_clause
  );
  END IF;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => g_log_level_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Select, From and Where clauses are prepared'
  );


 IF select_list is NOT NULL THEN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || l_view_name||' AS '|| select_list || from_clause || where_clause;


  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'View has been created successfully'||l_view_name
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => 'FEM_SYS_VIEW_SUCCESS'
    ,p_token1   => 'VIEW_NAME'
    ,p_value1   => l_view_name
    ,p_token2   => 'TABLE_NAME'
    ,p_value2   => p_tab_name  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

 UPDATE fem_tables_b set di_view_name = l_view_name where table_name=p_tab_name;

 retcode:=0; --Set the status to success
  COMMIT;

 ELSE

   FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => 'FEM_SYS_VIEW_CREATION_FAIL'
    ,p_token1   => 'TABLE_NAME'
    ,p_value1   => p_tab_name);

   ROLLBACK;

   retcode:=2;--Set the status to Error

 END IF;

  EXCEPTION

  WHEN others THEN
    l_prg_msg:=SQLERRM;

    FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => 'FEM_SYS_VIEW_ERROR'
    ,p_token1   => 'TABLE_NAME'
    ,p_value1   => p_tab_name
    ,p_token2   => 'ERR_MSG'
    ,p_value2   => l_prg_msg );

    FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'View Creation failed with unexpected exception'||l_prg_msg
    );

    ROLLBACK;
    retcode:=2;--Set the status to Error

END;

/*============================================================================+
 | PROCEDURE
 |   GenerateAllViews
 |
 | DESCRIPTION
 |   This proc is used for generating Sys Views for all tables for which DI View
 |   is not generated. This will be used for existing customers.
 |
 |
 | SCOPE - PUBLIC
 +============================================================================*/

PROCEDURE GenerateAllViews(errbuf          OUT  NOCOPY VARCHAR2
                             ,retcode       OUT  NOCOPY VARCHAR2)

AS

l_retcode         NUMBER:=0;
x_retcode         NUMBER:=0;

l_di_view_name	  VARCHAR2(30);
counter           NUMBER:=0;

CURSOR all_reg_tables IS
        SELECT table_name
		FROM fem_tables_vl ftc
        WHERE enabled_flag='Y'
		AND di_view_name is null
		AND EXISTS(
		           select 1
				   FROM user_synonyms
				   where synonym_name = ftc.table_name);


BEGIN

 retcode:=0;
 FOR table_rec IN all_reg_tables LOOP

    l_di_view_name := SUBSTR(table_rec.table_name,1,26)||'_TRV';

    GenerateSysView(errbuf        =>errbuf
                     ,retcode      =>l_retcode
                     ,p_tab_name   =>table_rec.table_name
					 ,p_view_name =>l_di_view_name);

	x_retcode:=x_retcode+l_retcode;
	counter:=counter+1;

 END LOOP;
    /*
	IF all view creation fails then error
	IF all view creation success then success
	IF atleast one view creation is success then warning
	*/
	IF x_retcode<>0 AND x_retcode/2=counter THEN
	  retcode:=2;
	END IF;
	IF x_retcode<>0 AND x_retcode/2<counter THEN
	  retcode:=1;
	END IF;

END;


END fem_table_registration_pkg;

/

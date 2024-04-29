--------------------------------------------------------
--  DDL for Package Body WMS_WCS_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WCS_DIAGNOSTICS" AS
   /* $Header: WMSDIAGB.pls 120.0 2005/05/25 08:57:58 appldev noship $ */

   PROCEDURE LOG (p_data IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- Output
      DBMS_OUTPUT.put_line (p_data);

      -- Insert into the log table
      wms_carousel_integration_pvt.log(NULL,p_data);

      COMMIT;
   END;

   --
   --
   FUNCTION get_config_parameter (
      p_name          IN   VARCHAR2,
      p_sequence_id   IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      v_value   VARCHAR2 (4000) := NULL;

      CURSOR c_config_parameter (
         p_name          IN   VARCHAR2,
         p_sequence_id   IN   NUMBER DEFAULT NULL
      )
      IS
         SELECT CONFIG_VALUE
           FROM wms_carousel_configuration
          WHERE CONFIG_NAME = p_name
            AND NVL (sequence_id, 0) = NVL (p_sequence_id, 0)
            AND active_ind = 'Y';
   BEGIN
      OPEN c_config_parameter (p_name, p_sequence_id);

      FETCH c_config_parameter
       INTO v_value;

      CLOSE c_config_parameter;

      RETURN v_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   --
   --
   PROCEDURE run
   IS
   BEGIN
      -- set outbut buffer size
      DBMS_OUTPUT.ENABLE (200000);
      -- database objects
                        --check_objects;
      -- Bug# 4088489
      --check_privileges;

      -- wms_integration
      check_wms_integration;
      -- configuration
      check_configuration;
      -- jobs
      check_jobs;
   END;

   /*
   --
   --
   PROCEDURE check_objects
   IS
      v_count          NUMBER;
      v_status         VARCHAR2 (64);
      v_version        VARCHAR2 (256);
      v_version_key    VARCHAR2 (128);
      v_object_name    VARCHAR2 (128);
      v_object_owner   VARCHAR2 (128);
      v_object_type    VARCHAR2 (128);
      v_object_count   NUMBER         := 0;

      CURSOR c_object_count (
         p_owner   IN   VARCHAR2,
         p_name    IN   VARCHAR2,
         p_type    IN   VARCHAR2
      )
      IS
         SELECT COUNT (*)
           FROM all_objects
          WHERE object_name = p_name
            AND owner = p_owner
            AND object_type = p_type;

      CURSOR c_object_status (
         p_owner   IN   VARCHAR2,
         p_name    IN   VARCHAR2,
         p_type    IN   VARCHAR2
      )
      IS
         SELECT status
           FROM all_objects
          WHERE object_name = p_name
            AND owner = p_owner
            AND object_type = p_type;

      CURSOR c_package_version_count (
         p_owner         IN   VARCHAR2,
         p_name          IN   VARCHAR2,
         p_type          IN   VARCHAR2,
         p_version_key   IN   VARCHAR2
      )
      IS
         SELECT COUNT (*)
           FROM all_source
          WHERE NAME = p_name
            AND TYPE = p_type
            AND UPPER (text) LIKE '%' || p_version_key || '%';

      CURSOR c_package_version (
         p_owner         IN   VARCHAR2,
         p_name          IN   VARCHAR2,
         p_type          IN   VARCHAR2,
         p_version_key   IN   VARCHAR2
      )
      IS
         SELECT SUBSTR (text,
                        INSTR (text, p_version_key) + LENGTH (p_version_key)
                        + 1,
                          LENGTH (text)
                        - INSTR (text, p_version_key)
                        - LENGTH (p_version_key)
                        - 1
                       )
           FROM all_source
          WHERE NAME = p_name
            AND TYPE = p_type
            AND UPPER (text) LIKE '%' || p_version_key || '%';
   BEGIN
      LOG ('================================== object status check');

      -- Obtain total object count
      SELECT MAX (sequence_id)
        INTO v_object_count
        FROM wms_carousel_configuration
       WHERE CONFIG_NAME = 'DIAG_OBJECT_NAME';

      -- Obtain version key parameter
      v_version_key :=
         UPPER
             (NVL (get_config_parameter (p_name      => 'DIAG_PACKAGE_VERSION_KEY'),
                   '$VERSION:'
                  )
             );

      -- Check all objects
      FOR i IN 1 .. v_object_count
      LOOP
         v_object_name :=
            UPPER (get_config_parameter (p_name             => 'DIAG_OBJECT_NAME',
                                         p_sequence_id      => i
                                        )
                  );
         v_object_owner :=
            UPPER (get_config_parameter (p_name             => 'DIAG_OBJECT_OWNER',
                                         p_sequence_id      => i
                                        )
                  );
         v_object_type :=
            UPPER (get_config_parameter (p_name             => 'DIAG_OBJECT_TYPE',
                                         p_sequence_id      => i
                                        )
                  );

         IF NVL (v_object_name, 'noname') <> 'noname'
         THEN
            -- Obtain object count
            OPEN c_object_count (v_object_owner, v_object_name,
                                 v_object_type);

            FETCH c_object_count
             INTO v_count;

            CLOSE c_object_count;

            -- Check existance
            IF v_count = 0
            THEN
               LOG (   '*** Error: '
                    || LOWER (v_object_type)
                    || ' '
                    || v_object_owner
                    || '.'
                    || v_object_name
                    || ' does not exist !'
                   );
            ELSE
               -- Obtain status
               OPEN c_object_status (v_object_owner,
                                     v_object_name,
                                     v_object_type
                                    );

               FETCH c_object_status
                INTO v_status;

               CLOSE c_object_status;

               -- Check status
               IF UPPER (v_status) <> 'VALID'
               THEN
                  LOG (   '*** Error: '
                       || LOWER (v_object_type)
                       || ' '
                       || v_object_owner
                       || '.'
                       || v_object_name
                       || ' status is '
                       || v_status
                       || ' !'
                      );
               ELSE
                  LOG (   INITCAP (LOWER (v_object_type))
                       || ' '
                       || v_object_owner
                       || '.'
                       || v_object_name
                       || ' status is '
                       || v_status
                      );
               END IF;

               -- Is it a package or body ?
               IF v_object_type = 'PACKAGE' OR v_object_type = 'PACKAGE BODY'
               THEN
                  -- Obtain version count
                  OPEN c_package_version_count (v_object_owner,
                                                v_object_name,
                                                v_object_type,
                                                v_version_key
                                               );

                  FETCH c_package_version_count
                   INTO v_count;

                  CLOSE c_package_version_count;

                  -- Check existance of version
                  IF v_count = 0
                  THEN
                     LOG (   '*** Error: '
                          || LOWER (v_object_type)
                          || ' '
                          || v_object_owner
                          || '.'
                          || v_object_name
                          || ' does not have version !'
                         );
                  ELSE
                     -- Obtain version number
                     OPEN c_package_version (v_object_owner,
                                             v_object_name,
                                             v_object_type,
                                             v_version_key
                                            );

                     FETCH c_package_version
                      INTO v_version;

                     CLOSE c_package_version;

                     LOG (   INITCAP (LOWER (v_object_type))
                          || ' '
                          || v_object_owner
                          || '.'
                          || v_object_name
                          || ' version is '
                          || v_version
                         );
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG ('*** Error: exception in CHECK_OBJECTS: ' || SQLERRM || ' !');
   END;
   */
   --
   --
/*
   PROCEDURE check_privileges
   IS
      v_count               NUMBER;
      v_privilege_object    VARCHAR2 (128);
      v_privilege_type      VARCHAR2 (128);
      v_privilege_owner     VARCHAR2 (128);
      v_privilege_grantee   VARCHAR2 (128);
      v_privilege_count     NUMBER         := 0;

      CURSOR c_table_privilege_count (
         p_owner     IN   VARCHAR2,
         p_object    IN   VARCHAR2,
         p_grantee   IN   VARCHAR2,
         p_type      IN   VARCHAR2
      )
      IS
         SELECT COUNT (*)
           FROM all_tab_privs
          WHERE table_schema = p_owner
            AND table_name = p_object
            AND grantee = p_grantee
            AND PRIVILEGE = p_type;

      CURSOR c_package_privilege_count (
         p_owner    IN   VARCHAR2,
         p_object   IN   VARCHAR2
      )
      IS
         SELECT COUNT (*)
           FROM all_procedures
          WHERE owner = p_owner AND object_name = p_object;
   BEGIN
      LOG ('================================== object privilege check');

      -- Obtain total object count
      SELECT MAX (sequence_id)
        INTO v_privilege_count
        FROM wms_carousel_configuration
       WHERE CONFIG_NAME = 'DIAG_PRIVILEGE_OBJECT';

      -- Check all objects
      FOR i IN 1 .. v_privilege_count
      LOOP
         v_privilege_object :=
            UPPER (get_config_parameter (p_name             => 'DIAG_PRIVILEGE_OBJECT',
                                         p_sequence_id      => i
                                        )
                  );
         v_privilege_owner :=
            UPPER (get_config_parameter (p_name             => 'DIAG_PRIVILEGE_OWNER',
                                         p_sequence_id      => i
                                        )
                  );
         v_privilege_grantee :=
            UPPER (get_config_parameter (p_name             => 'DIAG_PRIVILEGE_GRANTEE',
                                         p_sequence_id      => i
                                        )
                  );
         v_privilege_type :=
            UPPER (get_config_parameter (p_name             => 'DIAG_PRIVILEGE_TYPE',
                                         p_sequence_id      => i
                                        )
                  );

         IF NVL (v_privilege_object, 'noname') <> 'noname'
         THEN
            IF v_privilege_type IN
                         ('SELECT', 'UPDATE', 'INSERT', 'DELETE', 'EXECUTE')
            THEN
               -- Lookup table privilege
               OPEN c_table_privilege_count (v_privilege_owner,
                                             v_privilege_object,
                                             v_privilege_grantee,
                                             v_privilege_type
                                            );

               FETCH c_table_privilege_count
                INTO v_count;

               CLOSE c_table_privilege_count;

               -- Check it
               IF v_count = 0
               THEN
                  LOG (   '*** Error: '
                       || v_privilege_grantee
                       || ' user does not have '
                       || v_privilege_type
                       || ' privilege on '
                       || v_privilege_owner
                       || '.'
                       || v_privilege_object
                       || ' !'
                      );
               ELSE
                  LOG (   v_privilege_grantee
                       || ' user has '
                       || v_privilege_type
                       || ' privilege on '
                       || v_privilege_owner
                       || '.'
                       || v_privilege_object
                      );
               END IF;
            ELSE
               LOG (   '*** Error: unknown privilege '
                    || v_privilege_type
                    || ' for user '
                    || v_privilege_grantee
                    || ' on '
                    || v_privilege_owner
                    || '.'
                    || v_privilege_object
                    || ' !'
                   );
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG ('*** Error: exception in CHECK_PRIVILEGES: ' || SQLERRM || ' !');
   END;
*/
   --
   --
   PROCEDURE check_wms_integration
   IS
      v_cnt   NUMBER := 0;
   BEGIN
      LOG ('================================== WMS/WCS integration check');

      -- check for call to sync_device_request
      SELECT COUNT (*)
        INTO v_cnt
        FROM user_source
       WHERE NAME = 'WMS_DEVICE_INTEGRATION_PUB'
         AND LOWER (text) LIKE
                          '%wms_carousel_integration_pub.sync_device_request%';

      IF v_cnt > 0
      THEN
         LOG
            ('WMS_DEVICE_INTEGRATION_PUB calls WMS_CAROUSEL_INTEGRATION_PUB.SYNC_DEVICE_REQUEST'
            );
      ELSE
         LOG
            ('*** Error: WMS_DEVICE_INTEGRATION_PUB does not call WMS_CAROUSEL_INTEGRATION_PUB.SYNC_DEVICE_REQUEST !'
            );
      END IF;

      -- check for call to sync_device
      SELECT COUNT (*)
        INTO v_cnt
        FROM user_source
       WHERE NAME = 'WMS_DEVICE_INTEGRATION_PUB'
         AND LOWER (text) LIKE '%wms_carousel_integration_pub.sync_device%'
         AND LOWER (text) NOT LIKE
                          '%wms_carousel_integration_pub.sync_device_request%';

      IF v_cnt > 0
      THEN
         LOG
            ('WMS_DEVICE_INTEGRATION_PUB calls WMS_CAROUSEL_INTEGRATION_PUB.SYNC_DEVICE'
            );
      ELSE
         LOG
            ('*** Error: WMS_DEVICE_INTEGRATION_PUB does not call WMS_CAROUSEL_INTEGRATION_PUB.SYNC_DEVICE !'
            );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG (   '*** Error: exception in CHECK_WMS_INTEGRATION: '
              || SQLERRM
              || ' !'
             );
   END;

   --
   --
   FUNCTION get_hash_value (v_data IN VARCHAR2)
      RETURN NUMBER
   IS
      v_length       NUMBER;
      v_hash_value   NUMBER := 0;
   BEGIN
      IF NVL (v_data, '<nullvalue>') = '<nullvalue>'
      THEN
         RETURN 0;
      END IF;

      v_length := LENGTH (v_data);

      FOR i IN 1 .. v_length
      LOOP
         v_hash_value := v_hash_value + ASCII (SUBSTR (v_data, i, 1));
      END LOOP;

      RETURN v_hash_value;
   END;

   --
   --
   FUNCTION add_hash_values (v_first IN NUMBER, v_second IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN v_first + v_second;
   END;

   --
   --
   FUNCTION calculate_config_hash_value
      RETURN NUMBER
   IS
      v_calc_hash_value   NUMBER := 0;

      CURSOR c_configuration
      IS
         SELECT *
           FROM wms_carousel_configuration
          WHERE CONFIG_NAME <> 'DIAG_CONFIG_HASH_VALUE';
   BEGIN
      -- Calculate the hash value
      FOR v_row IN c_configuration
      LOOP
         v_calc_hash_value :=
             add_hash_values (v_calc_hash_value, get_hash_value (v_row.CONFIG_NAME));
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value, get_hash_value (v_row.CONFIG_VALUE));
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.device_type_id)
                            );
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.sequence_id)
                            );
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.active_ind)
                            );
         v_calc_hash_value :=
              add_hash_values (v_calc_hash_value, get_hash_value (v_row.SUBINVENTORY));
      END LOOP;

      RETURN v_calc_hash_value;
   END;

   --
   --
   PROCEDURE update_hash_value
   IS
      v_calc_hash_value   NUMBER := 0;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- Calculate the hash value
      v_calc_hash_value := calculate_config_hash_value;

      -- Update
      UPDATE wms_carousel_configuration
         SET CONFIG_VALUE = v_calc_hash_value
       WHERE CONFIG_NAME = 'DIAG_CONFIG_HASH_VALUE' AND active_ind = 'Y';

      -- Commit
      COMMIT;
   END;

   --
   --
   PROCEDURE check_configuration
   IS
      v_config_hash_value   NUMBER          := 0;
      v_calc_hash_value     NUMBER          := 0;
      v_version             VARCHAR2 (4000);
   BEGIN
      LOG ('================================== Configuration check');
      -- Obtain version value
      v_version :=
         NVL (get_config_parameter (p_name => 'VERSION_COMMENTS'),
              'no comments'
             );
      LOG ('Version comments: ' || v_version);
      -- Obtain the specified hash value
      v_config_hash_value :=
          NVL (get_config_parameter (p_name => 'DIAG_CONFIG_HASH_VALUE'), '0');

      -- Check to make sure there is 1 and only 1
      IF v_config_hash_value = 0
      THEN
         LOG
            ('*** Error: DIAG_CONFIG_HASH_VALUE configuration parameter not found or is invalid !'
            );
      ELSE
         LOG ('The specified hash value is ' || v_config_hash_value);
         -- Calculate the hash value
         v_calc_hash_value := calculate_config_hash_value;
         LOG ('Calculated hash value is ' || v_calc_hash_value);

         -- Compare
         IF v_config_hash_value <> v_calc_hash_value
         THEN
            LOG
               ('*** Error: the specified and calculated hash values are not equal !'
               );
         ELSE
            LOG ('The specified and calculated hash values are equal');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         LOG ('*** Error: exception in CHECK_CONFIGURATION: ' || SQLERRM
              || ' !'
             );
   END;

   /* Commenting out this procedure as the following line is an error in GSCC
      v_i2 := INSTR (v_row.VALUE, CHR (10), v_i1);
      And all this procedure does is create an insert script which when run
      on another DB will insert all the config data into it
      */

   --
   --  examples: export_configuration('10,11','BA,BD'); export_configuration('*'/*all*/,'*'/*all*/);
   /*
   PROCEDURE export_configuration (
      p_device_type_ids   IN   VARCHAR2,
      p_zones             IN   VARCHAR2
   )
   IS
      v_statement         VARCHAR2 (1024);
      v_statement1        VARCHAR2 (1024);
      v_insert            VARCHAR2 (10240);
      v_row               wms.wms_carousel_configuration%ROWTYPE;

      TYPE my_curs_type IS REF CURSOR;                -- must be weakly typed

      c_config            my_curs_type;
      v_i1                NUMBER;
      v_i2                NUMBER;
      v_calc_hash_value   NUMBER                                   := 0;
   BEGIN
      -- set outbut buffer size
      DBMS_OUTPUT.ENABLE (200000);
      DBMS_OUTPUT.put_line (   '-- Configuration data for devices '
                            || p_device_type_ids
                            || ' and zones '
                            || p_zones
                           );
      DBMS_OUTPUT.put_line ('set scan off;');
      DBMS_OUTPUT.put_line ('delete from wms_carousel_configuration;');
      -- Build dynamic SQL
      v_statement :=
                  'select * from wms.wms_carousel_configuration where (1 = 0 ';

      IF p_device_type_ids <> '*'
      THEN
         v_statement :=
            v_statement || 'or device_type_id in (' || p_device_type_ids
            || ') ';
      ELSE
         v_statement := v_statement || 'or device_type_id like ''%'' ';
      END IF;

      IF p_zones <> '*'
      THEN
         v_statement :=
               v_statement
            || 'or zone in ('''
            || REPLACE (REPLACE (p_zones, ' ', ''), ',', ''',''')
            || ''') ';
      ELSE
         v_statement := v_statement || 'or zone like ''%'' ';
      END IF;

      v_statement :=
               v_statement || 'or (device_type_id is null and zone is null)) ';
      --dbms_output.put_line('-- '||v_statement);
      v_statement1 :=
            'and name is not null and active_ind is not null '
         || 'and name <> ''DIAG_CONFIG_HASH_VALUE'' '
         ||                              -- skip hash value and add at the end
            'order by device_type_id, sequence_id, zone, active_ind, name';
      --dbms_output.put_line('-- '||v_statement1);
      v_statement := v_statement || v_statement1;

      OPEN c_config
       FOR v_statement;

      LOOP
         FETCH c_config
          INTO v_row;

         EXIT WHEN c_config%NOTFOUND;
         DBMS_OUTPUT.put_line ('insert into wms_carousel_configuration');
         DBMS_OUTPUT.put_line
            ('   (name, device_type_id, sequence_id, zone, active_ind, value)'
            );
         DBMS_OUTPUT.put_line ('values');
         -- Name, device_type_id, and sequence_id
         v_insert :=
               '   ('
            || ''''
            || v_row.CONFIG_NAME
            || ''','
            || NVL ('' || v_row.device_type_id, 'null')
            || ','
            || NVL ('' || v_row.sequence_id, 'null')
            || ',';

         -- Zone
         IF NVL (v_row.SUBINVENTORY, 'null') = 'null'
         THEN
            v_insert := v_insert || 'null,';
         ELSE
            v_insert := v_insert || '''' || v_row.SUBINVENTORY || ''',';
         END IF;

         -- Active indicator
         v_insert := v_insert || '''' || v_row.active_ind || ''',';
         -- print out what is so far
         DBMS_OUTPUT.put_line (v_insert);

         -- Value is null ?
         IF NVL (v_row.CONFIG_VALUE, '<nullvalue>') = '<nullvalue>'
         THEN
            DBMS_OUTPUT.put_line ('      null);');
         ELSE
            -- print out value one line at a time
            v_i1 := 1;

            LOOP
               EXIT WHEN v_i1 > LENGTH (v_row.CONFIG_VALUE);
               -- Find new line character
               v_i2 := INSTR (v_row.CONFIG_VALUE, CHR (10), v_i1);

               IF v_i2 = 0
               THEN
                  v_i2 := LENGTH (v_row.CONFIG_VALUE) + 1;
               END IF;

               -- get the line
               v_insert := SUBSTR (v_row.CONFIG_VALUE, v_i1, v_i2 - v_i1);

               -- Null ?
               IF NVL (v_insert, '<nullvalue>') = '<nullvalue>'
               THEN
                  v_insert := 'null';
               ELSE
                  -- Take care of single quotes
                  v_insert := '''' || REPLACE (v_insert, '''', '''''')
                              || '''';
               END IF;

               -- New line character
               IF v_i1 = 1
               THEN
                  v_insert := '      ' || v_insert;
               ELSE
                  v_insert := '      ||chr(10)||' || v_insert;
               END IF;

               -- print out what is so far
               DBMS_OUTPUT.put_line (v_insert);
               -- next ?
               EXIT WHEN v_i2 >= LENGTH (v_row.CONFIG_VALUE) + 1;
               v_i1 := v_i2 + 1;
            END LOOP;

            -- Close parenthesis
            DBMS_OUTPUT.put_line ('   );');
         END IF;

         -- Hash value
         v_calc_hash_value :=
              add_hash_values (v_calc_hash_value, get_hash_value (v_row.CONFIG_NAME));
         v_calc_hash_value :=
             add_hash_values (v_calc_hash_value, get_hash_value (v_row.CONFIG_VALUE));
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.device_type_id)
                            );
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.sequence_id)
                            );
         v_calc_hash_value :=
            add_hash_values (v_calc_hash_value,
                             get_hash_value (v_row.active_ind)
                            );
         v_calc_hash_value :=
              add_hash_values (v_calc_hash_value, get_hash_value (v_row.SUBINVENTORY));
      END LOOP;

      CLOSE c_config;

      -- Add hash value parameter
      DBMS_OUTPUT.put_line ('insert into wms_carousel_configuration');
      DBMS_OUTPUT.put_line ('   (name, value)');
      DBMS_OUTPUT.put_line ('values');
      DBMS_OUTPUT.put_line (   '   (''DIAG_CONFIG_HASH_VALUE'','
                            || v_calc_hash_value
                            || ');'
                           );
      -- Done
      DBMS_OUTPUT.put_line ('commit;');
      DBMS_OUTPUT.new_line;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line
                         (   '*** Error: exception in EXPORT_CONFIGURATION: '
                          || SQLERRM
                          || ' !'
                         );
   END;
   */

   --
   --
   PROCEDURE check_jobs
   IS
      -- Cursor for receive pipes
      CURSOR c_receive_pipes
      IS
         SELECT *
           FROM wms_carousel_configuration
          WHERE CONFIG_NAME = 'RECEIVE_PIPE' AND active_ind = 'Y';

      CURSOR c_zone_job (p_zone IN VARCHAR2)
      IS
         SELECT *
           FROM all_jobs
          WHERE what LIKE
                      'wms_carousel_integration_pub.pipe_listener_loop%,'''
                   || p_zone
                   || '''%'
            AND schema_user = 'APPS';

      v_switch   VARCHAR (16);
      v_count    NUMBER;
   BEGIN
      LOG ('================================== Pipe listener job check');
      -- Obtain pipe listener switch
      v_switch :=
         NVL (get_config_parameter (p_name => 'PIPE_LISTENER_SWITCH'), 'OFF');

      IF v_switch = 'OFF'
      THEN
         LOG
            ('*** Error: PIPE_LISTENER_SWITCH is OFF - pipe listeners are down !'
            );
      ELSE
         LOG ('PIPE_LISTENER_SWITCH is ON');
      END IF;

      -- Look for pipe listeners
      FOR v_cfg IN c_receive_pipes
      LOOP
         -- Look for the job
         v_count := 0;

         FOR v_job IN c_zone_job (v_cfg.SUBINVENTORY)
         LOOP
            v_count := v_count + 1;
            -- Log some stats
            LOG (   'Pipe listener job '
                 || v_job.job
                 || ' for zone '
                 || v_cfg.SUBINVENTORY
                 || ' is scheduled'
                );
            LOG (   'Job '
                 || v_job.job
                 || ': last date = '
                 || TO_CHAR (v_job.last_date, 'MM/DD/YYYY HH24:MI:SS')
                 || ': this date = '
                 || TO_CHAR (v_job.this_date, 'MM/DD/YYYY HH24:MI:SS')
                 || ': next date = '
                 || TO_CHAR (v_job.next_date, 'MM/DD/YYYY HH24:MI:SS')
                );
            LOG (   'Job '
                 || v_job.job
                 || ' has been running for '
                 || NVL (v_job.total_time, 0)
                 || ' seconds and has had '
                 || NVL (v_job.failures, 0)
                 || ' failures'
                );

            -- Broken ?
            IF UPPER (v_job.broken) = 'Y'
            THEN
               LOG (   '*** Error: job '
                    || v_job.job
                    || ' is currently broken, restart pipe listeners !'
                   );
            ELSE
               LOG ('Job ' || v_job.job || ' is currently NOT broken');
            END IF;
         END LOOP;

         -- Verify job count for the zone
         IF v_count = 0
         THEN
            LOG (   '*** Error: no jobs are scheduled for zone '
                 || v_cfg.SUBINVENTORY
                 || ', resubmit pipe listeners !'
                );
         ELSIF v_count > 1
         THEN
            LOG (   '*** Error: more than one job is schedules for zone '
                 || v_cfg.SUBINVENTORY
                 || ', resubmit pipe listeners !'
                );
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (   '*** Error: exception in CHECK_JOBS: '
                               || SQLERRM
                               || ' !'
                              );
   END;

   --
   --
   FUNCTION get_segment (
      p_data        IN   VARCHAR2,
      p_separator   IN   VARCHAR2,
      p_index       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      v_segment   VARCHAR2 (128);
      v_i1        NUMBER;
      v_i2        NUMBER;
   BEGIN
      IF p_index = 1
      THEN
         v_i1 := 0;
      ELSE
         v_i1 := INSTR (p_data, p_separator, 1, p_index - 1);

         IF v_i1 = 0
         THEN
            RETURN NULL;
         END IF;
      END IF;

      v_i2 := INSTR (p_data, p_separator, 1, p_index);

      IF v_i2 = 0
      THEN
         v_i2 := LENGTH (p_data) + 1;
      END IF;

      RETURN SUBSTR (p_data, v_i1 + 1, v_i2 - v_i1 - 1);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   --
   --
   PROCEDURE test_task (
      p_zone                IN   VARCHAR2,
      p_device_type_id      IN   NUMBER,
      p_locator             IN   VARCHAR2,
      p_directive           IN   VARCHAR2 DEFAULT 'GO',
      p_task_type_id        IN   NUMBER DEFAULT 10,
      p_quantity            IN   NUMBER DEFAULT 123,
      p_device_id           IN   NUMBER DEFAULT 0,
      p_business_event_id   IN   NUMBER DEFAULT 10,
      p_lpn                 IN   VARCHAR2 DEFAULT 'TestLPN'
   )
   IS
      v_send_pipe       VARCHAR2 (128);
      v_status          NUMBER;
      v_status_code     VARCHAR2 (128);
      v_status_msg      VARCHAR2 (128);
      v_device_status   VARCHAR2 (128);
      v_segment1        VARCHAR2 (32);
      v_segment2        VARCHAR2 (32);
      v_segment3        VARCHAR2 (32);
      v_segment4        VARCHAR2 (32);
      v_segment5        VARCHAR2 (32);
      v_segment6        VARCHAR2 (32);
      v_segment7        VARCHAR2 (32);
      v_segment8        VARCHAR2 (32);
      v_segment9        VARCHAR2 (32);
      v_segment10       VARCHAR2 (32);
      v_request_id      NUMBER         := 999999999;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- set outbut buffer size
      DBMS_OUTPUT.ENABLE (200000);
      LOG ('================================== Test task');
      -- Derive segments
      v_segment1 := get_segment (p_locator, '.', 1);
      v_segment2 := get_segment (p_locator, '.', 2);
      v_segment3 := get_segment (p_locator, '.', 3);
      v_segment4 := get_segment (p_locator, '.', 4);
      v_segment5 := get_segment (p_locator, '.', 5);
      v_segment6 := get_segment (p_locator, '.', 6);
      v_segment7 := get_segment (p_locator, '.', 7);
      v_segment8 := get_segment (p_locator, '.', 8);
      v_segment9 := get_segment (p_locator, '.', 9);
      v_segment10 := get_segment (p_locator, '.', 10);
      -- Create a test task
      LOG (   'Creating test task: request_id='
           || v_request_id
           || ', locator='
           || p_locator
           || ', quantity='
           || p_quantity
          );
      /*
      DELETE FROM wms_wcs_request_test;

      INSERT INTO wms_wcs_request_test
                  (request_id, task_id, sequence_id, task_type_id, quantity,
                   subinventory_code, LOCATOR, device_name, device_id,
                   device_type_id, business_event, business_event_id,
                   relation_id, lpn, item, segment1, segment2,
                   segment3, segment4, segment5, segment6,
                   segment7, segment8, segment9, segment10
                  )
           VALUES (v_request_id, 1, 1, p_task_type_id, p_quantity,
                   'TestSI', p_locator, 'TestDev', p_device_id,
                   p_device_type_id, 'TestPick', p_business_event_id,
                   NULL, p_lpn, 'TestItem', v_segment1, v_segment2,
                   v_segment3, v_segment4, v_segment5, v_segment6,
                   v_segment7, v_segment8, v_segment9, v_segment10
                  );
      */
      COMMIT;
      -- Update to simulation mode
      LOG ('Changing zone ' || p_zone || ' to simulation mode');

      UPDATE wms_carousel_configuration
         SET CONFIG_VALUE = 'ON'
       WHERE CONFIG_NAME = 'SIMULATION_MODE'
         AND (device_type_id = p_device_type_id OR device_type_id IS NULL)
         AND (SUBINVENTORY = p_zone OR SUBINVENTORY IS NULL);

      COMMIT;
      -- Get send pipe parameter
      v_send_pipe := 'OUT_' ||
         NVL
            (wms_carousel_integration_pvt.get_config_parameter
                                                       (p_name      => 'PIPE_NAME',
                                                        p_sequence_id => p_device_id
                                                       ),
             'PIPE_NAME_' || p_device_id
            );

      -- Tell the bridge to reread parameters to switch to simulation
      wms_carousel_integration_pvt.send_directive (p_device_id      => p_device_id,
						   p_pipe_name           => v_send_pipe,
                                                   p_addr           => NULL,
                                                   p_directive      => 'R',
                                                   p_time_out       => 10
                                                  -- 10 sec send timeout
                                                  );
      -- Wait for 5 seconds
      v_status := DBMS_PIPE.receive_message ('wcs_nonexistant_pipe', 5);
      -- Process the request
      LOG ('Processing the test request');
      wms_carousel_integration_pvt.process_request
                                           (p_request_id         => v_request_id,
                                            x_status_code        => v_status_code,
                                            x_status_msg         => v_status_msg,
                                            x_device_status      => v_device_status
                                           );
      -- Wait for 2 minutes
      LOG ('Waiting for 3 minutes');
      v_status := DBMS_PIPE.receive_message ('wcs_nonexistant_pipe', 180);

      -- Look for the answer
      SELECT status, attempts
        INTO v_status_code, v_status
        FROM wms_carousel_directive_queue
       WHERE request_id = v_request_id AND directive = p_directive;

      IF v_status_code <> 'S'
      THEN
         LOG (   '*** Error: status code for the '
              || p_directive
              || ' directive is '
              || v_status_code
              || ' on the attempt '
              || v_status
              || ' !'
             );
      ELSE
         LOG ('Success !');
      END IF;

      -- Update to non-simulation mode
      LOG ('Switching off simulation in zone ' || p_zone);

      UPDATE wms_carousel_configuration
         SET CONFIG_VALUE = 'OFF'
       WHERE CONFIG_NAME = 'SIMULATION_MODE'
         AND (device_type_id = p_device_type_id OR device_type_id IS NULL)
         AND (SUBINVENTORY = p_zone OR SUBINVENTORY IS NULL);

      COMMIT;
      -- Tell the bridge to reread parameters
      wms_carousel_integration_pvt.send_directive (p_device_id      => p_device_id,
                                                   p_pipe_name      => v_send_pipe,
                                                   p_addr           => 1,
                                                   p_directive      => 'R',
                                                   p_time_out       => 10
                                                  -- 10 sec send timeout
                                                  );

      -- Get rid of the test request
      -- DELETE FROM wms_wcs_request_test;

      DELETE FROM wms_carousel_directive_queue
            WHERE request_id = v_request_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (   '*** Error: exception in TEST_GO: '
                               || SQLERRM
                               || ' !'
                              );
   END;
END wms_wcs_diagnostics;

/

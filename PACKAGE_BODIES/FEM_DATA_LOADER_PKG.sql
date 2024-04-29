--------------------------------------------------------
--  DDL for Package Body FEM_DATA_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DATA_LOADER_PKG" AS
/* $Header: FEMDATALEDGERLDR.plb 120.2 2007/07/03 07:20:12 pkakkar ship $ */

  --------------------------------------------------------------------------------
                           -- Declare all global variables --
  --------------------------------------------------------------------------------

     gs_table_row_tab        number_table;
     gs_table_name_tab       char_table;
     gs_sql_dup_tab          char_table;
     gs_sql_dup_indx_tab     number_table;
     gs_table_obj_id         number_table;
     gs_table_obj_def_id     number_table;
     gs_ss_tab               number_table;
     gs_ds_tab               number_table;
     gs_ledger_tab           number_table;
     gs_ss_code_tab          char_table;
     gs_ds_code_tab          char_table;
     gs_ledger_code_tab      char_table;
     gs_budget_code_tab      char_table;
     gs_enc_code_tab         char_table;
     gs_load_opt_tab         char_table;
     gs_ds_bal_code_tab      char_table;
     gs_cal_grp_tab          number_table;
     gs_sql_stmt_tab         sql_stmt_table;
     g_b_dataset_code        number_table;
     g_e_dataset_code        number_table;
     g_budget_id             number_table;
     g_enc_type_id           number_table;
     g_ledger_id             number_table;
     g_cal_period_id         number_table;
     g_ds_code               number_table;
     g_ss_code               number_table;
     g_invalid_ds_code       number_table;
     gs_valid_rows           number_table;

     g_inv_ledger            char_table;
     g_inv_dataset           char_table;
     g_inv_source_system     char_table;
     g_inv_ds_pd_flag        char_table;
     g_inv_table_name        char_table;
     g_inv_table_row         char_table;

     g_master_rec            master_rec_tab;
     g_cal_period_rec        cal_period_tab;
     g_interface_data_rec    interface_data_tab;

     g_budgets_exist         BOOLEAN;
     g_enc_exist             BOOLEAN;
     g_loader_run            BOOLEAN;

     g_request_id            NUMBER;
     g_user_id               NUMBER;
     g_login_id              NUMBER;
     g_object_id             NUMBER;

  --------------------------------------------------------------------------------
                     -- Declare private procedures and functions --
  --------------------------------------------------------------------------------

     PROCEDURE get_parameters(p_obj_def_id IN NUMBER);
     PROCEDURE process_global_id ;
     PROCEDURE print_params;
     PROCEDURE evaluate_parameters;
     PROCEDURE submit_dimension_loaders;
     PROCEDURE build_dim_stages;
     PROCEDURE wait_for_requests(p_wait_for IN VARCHAR2);
     PROCEDURE populate_cal_periods;
     PROCEDURE populate_master_table_lldr;
     PROCEDURE populate_master_table_dldr;
     PROCEDURE submit_data_loaders;
     PROCEDURE submit_ledger_loader(p_balance_type IN VARCHAR2);
     PROCEDURE submit_hierarchy_loaders;
     PROCEDURE log_dimensions(p_table_name IN VARCHAR2);
     PROCEDURE log_hierarchies(p_table_name IN VARCHAR2);
     PROCEDURE log_fact_table(p_table_name IN VARCHAR2, p_table_row IN NUMBER);
     PROCEDURE populate_log;
     PROCEDURE cleanup;

  --------------------------------------------------------------------------------
                        -- Public procedures and functions --
  --------------------------------------------------------------------------------

  --------------------------------------------------------------------------------
  --
  -- This is the main procedure that gets called when the LOADER rule is run. It
  -- calls all the relevant procedures in a sequential manner
  --
  --------------------------------------------------------------------------------


     PROCEDURE process_request(errbuf OUT NOCOPY VARCHAR2,
                               retcode OUT NOCOPY VARCHAR2,
                               p_obj_def_id IN NUMBER,
                               p_start_date IN VARCHAR2,
                               p_end_date IN VARCHAR2,
                               p_balance_type IN VARCHAR2)
     IS
       l_dummy VARCHAR2(10);
     BEGIN
        fnd_log_repository.init;

        fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'BEGIN..for process_request');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PARAMETERS)'
                                     ,p_msg_text => 'p_obj_def_id    :: ' || p_obj_def_id);


        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PARAMETERS)'
                                     ,p_msg_text => 'p_start_date    :: ' || p_start_date);


        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PARAMETERS)'
                                     ,p_msg_text => 'p_end_date      :: ' || p_end_date);


        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PARAMETERS)'
                                     ,p_msg_text => 'p_balance_type  :: ' || p_balance_type);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling get_parameters');

--        DBMS_SESSION.SET_SQL_TRACE (sql_trace => FALSE);

--        SELECT 'VIVA'
--        INTO   l_dummy
--       FROM   dual;

        get_parameters(p_obj_def_id);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed get_parameters');


        g_start_date := p_start_date;
        g_end_date := p_end_date;

        fnd_msg_pub.initialize;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling process_global_id');

        process_global_id;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed process_global_id');


        DELETE fem_ld_interface_data_gt;
        DELETE fem_ld_dim_requests_gt;
        DELETE fem_ld_hier_requests_gt;
        DELETE fem_ld_cal_periods_gt;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed deleting the object tables');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling build_dim_stages');


        build_dim_stages;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed build_dim_stages');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling evaluate_parameters');


        evaluate_parameters;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed evaluate_parameters');


        IF g_loader_run AND g_evaluate_parameters THEN

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling populate_cal_periods');


           populate_cal_periods;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed populate_cal_periods');

           print_params;

           IF g_evaluate_parameters THEN

              IF g_loader_type = 'LEDGER' THEN
                 fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                              ,p_module   => g_block||'.process_request(PROCEDURE)'
                                              ,p_msg_text => 'Calling populate_master_table_lldr');

                 populate_master_table_lldr;

                 fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                              ,p_module   => g_block||'.process_request(PROCEDURE)'
                                              ,p_msg_text => 'Completed populate_master_table_lldr');

              ELSE
                 fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                              ,p_module   => g_block||'.process_request(PROCEDURE)'
                                              ,p_msg_text => 'Calling populate_master_table_dldr');

                 populate_master_table_dldr;

                 fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                              ,p_module   => g_block||'.process_request(PROCEDURE)'
                                              ,p_msg_text => 'Completed populate_master_table_dldr');

              END IF;

              IF g_master_rec.COUNT > 0.0 THEN
                 g_request_id := fnd_global.conc_request_id;
                 g_user_id := fnd_global.user_id;
                 g_login_id := fnd_global.login_id;

                 IF g_loader_type = 'LEDGER' THEN
                    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                 ,p_module   => g_block||'.process_request(PROCEDURE)'
                                                 ,p_msg_text => 'Calling submit_ledger_loader');

                    submit_ledger_loader(p_balance_type);

                    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                 ,p_module   => g_block||'.process_request(PROCEDURE)'
                                                 ,p_msg_text => 'Completed submit_ledger_loader');
                 ELSE

                    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                 ,p_module   => g_block||'.process_request(PROCEDURE)'
                                                 ,p_msg_text => 'Calling submit_data_loaders');

                    submit_data_loaders;

                    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                 ,p_module   => g_block||'.process_request(PROCEDURE)'
                                                 ,p_msg_text => 'Completed submit_data_loaders');
                 END IF;
              ELSE
                 fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                              ,p_module   => g_block||'.process_request(PROCEDURE)'
                                              ,p_msg_text => 'Nothing to process - will not submit the loader CP');
              END IF;

           ELSE
             -- The message for printing no valid cal_periods is handled below
             NULL;
           END IF; -- g_evaluate_parameters

        ELSE
           -- What if there was nothing to process ??
           NULL;
        END IF; -- g_loader_run and g_evaluate_parameters

        IF g_hierarchy_exists THEN
           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling submit_hierarchy_loaders');

           submit_hierarchy_loaders;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed submit_hierarchy_loaders');

        END IF;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling populate_log');


        populate_log;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed populate_log');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling cleanup');

        cleanup;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed cleanup');


        fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'END process_request');

     EXCEPTION
       WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_request(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION in process_request ' || sqlerrm);
         fnd_file.put_line(fnd_file.log, 'Exception - process_request ' || sqlerrm);
         RAISE;

     END process_request;

  ----------------------
  -- END process_request
  ----------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used for printing information into the output file
  --
  --------------------------------------------------------------------------------

     PROCEDURE trace(p_trace_what IN VARCHAR2)  IS

        s           INTEGER;
        l_separator VARCHAR2(140) := '===========================================================================================================================================';
        l_message   VARCHAR2(2000);

     BEGIN

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.trace(PROCEDURE)'
                                    ,p_msg_text => 'BEGIN..for trace ' || p_trace_what);

       IF p_trace_what = 'SEPARATOR' THEN
          l_message := l_separator;
       ELSIF p_trace_what = 'MESSAGE' THEN
          l_message := fnd_message.get;
       ELSIF p_trace_what = 'BLANKLINE' THEN
          l_message := '';
       END IF;

       fnd_file.put_line(FND_FILE.OUTPUT, l_message);

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.trace(PROCEDURE)'
                                    ,p_msg_text => 'END trace ');


     EXCEPTION
       WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.trace(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION in trace ' || sqlerrm);
         fnd_file.put_line(fnd_file.log, 'Exception - trace ' || sqlerrm);
         RAISE;

     END trace;

  ------------
  -- END trace
  ------------

  --------------------------------------------------------------------------------
                         -- Private procedures and functions --
  --------------------------------------------------------------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used to free up all the global pl/sql objects, object tables
  -- used during the loader run
  --
  --------------------------------------------------------------------------------

 PROCEDURE cleanup IS

 BEGIN
     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.cleanup(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for cleanup ');


     gs_table_row_tab.DELETE;
     gs_table_name_tab.DELETE;
     gs_sql_dup_tab.DELETE;
     gs_sql_dup_indx_tab.DELETE;
     gs_ss_tab.DELETE;
     gs_ds_tab.DELETE;
     gs_ledger_tab.DELETE;
     gs_ss_code_tab.DELETE;
     gs_ds_code_tab.DELETE;
     gs_ledger_code_tab.DELETE;
     gs_budget_code_tab.DELETE;
     gs_enc_code_tab.DELETE;
     gs_load_opt_tab.DELETE;
     gs_ds_bal_code_tab.DELETE;
     gs_cal_grp_tab.DELETE;
     gs_sql_stmt_tab.DELETE;
     g_b_dataset_code.DELETE;
     g_e_dataset_code.DELETE;
     g_budget_id.DELETE;
     g_enc_type_id.DELETE;
     g_ledger_id.DELETE;
     g_ds_code.DELETE;
     g_ss_code.DELETE;
     g_invalid_ds_code.DELETE;
     gs_valid_rows.DELETE;
     gs_table_obj_def_id.DELETE;

     g_inv_ledger.DELETE;
     g_inv_dataset.DELETE;
     g_inv_source_system.DELETE;
     g_inv_ds_pd_flag.DELETE;
     g_inv_table_name.DELETE;
     g_inv_table_row.DELETE;

     g_master_rec.DELETE;
     g_cal_period_rec.DELETE;
     g_interface_data_rec.DELETE;

     DELETE fem_ld_interface_data_gt;
     DELETE fem_ld_dim_requests_gt;
     DELETE fem_ld_hier_requests_gt;
     DELETE fem_ld_cal_periods_gt;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.cleanup(PROCEDURE)'
                                  ,p_msg_text => 'END cleanup ');

     EXCEPTION
       WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.cleanup(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION in cleanup ' || sqlerrm);
         fnd_file.put_line(fnd_file.log, 'Exception - cleanup ' || sqlerrm);
         RAISE;
 END cleanup;

  --------------
  -- END cleanup
  --------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used to query up the selection criteria specified by the
  -- user in the parameters page.
  --
  -- The procedure populates g_loader_type usefule in identifying if it is DATA/
  -- LEDGER load, identifies if the RULE is approved or not
  --
  --------------------------------------------------------------------------------


  PROCEDURE get_parameters(p_obj_def_id IN NUMBER)  IS
    l_approval_status            VARCHAR2(30);
  BEGIN

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.get_parameters(PROCEDURE)'
                                    ,p_msg_text => 'BEGIN..for get_parameters ');

       BEGIN
         SELECT loader_type,
                approval_status_code,
                object_id
         INTO   g_loader_type,
                l_approval_status,
                g_object_id
         FROM   fem_data_loader_rules fdlr,
                fem_object_definition_b fod
         WHERE  fdlr.loader_obj_id = fod.object_id
           AND  fod.object_definition_id = p_obj_def_id;

       EXCEPTION
          WHEN OTHERS THEN
              fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                           ,p_module   => g_block||'.get_parameters (PROCEDURE)'
                                           ,p_msg_text => 'EXCEPTION in get_parameters.loader_type ' || sqlerrm);
              fnd_file.put_line(fnd_file.log, 'Exception - get_parameters ' || sqlerrm);
              RAISE; -- loader_rule_error;
       END;

       IF l_approval_status = 'APPROVED' THEN
          g_approval_flag := TRUE;
       END IF;

       IF g_loader_type = 'LEDGER' THEN
          SELECT interface_table_name
          INTO   g_int_table_name
          FROM   fem_tables_b
          WHERE  table_name = 'FEM_BALANCES';
       END IF;

       -- g_loader_type = CLIENT/LEDGER
       -- If LEDGER we do not need source_system_code

       IF g_loader_type = 'CLIENT' THEN
          BEGIN
            SELECT ROWNUM,
                   fdlp.table_name,
                   source_system_code,
                   dataset_code,
                   ledger_id,
                   load_option,
                   cal_period_grp_id,
                   'SELECT ledger_display_code,
                           dataset_display_code,
                           source_system_display_code,
                           cal_period_number,
                           calp_dim_grp_display_code,
                           cal_period_end_date,' || '''' ||
                           fdlp.table_name || '''' || ',' || 'TO_NUMBER(''' || ROWNUM || ''')' ||
                   ' FROM  '       dyn_sql_stmt,
                   fodb.object_id,
                   fodb.object_definition_id
            BULK COLLECT INTO gs_table_row_tab,
                              gs_table_name_tab,
                              gs_ss_tab,
                              gs_ds_tab,
                              gs_ledger_tab,
                              gs_load_opt_tab,
                              gs_cal_grp_tab,
                              gs_sql_stmt_tab,
                              gs_table_obj_id,
                              gs_table_obj_def_id
            FROM   fem_data_loader_params fdlp,
                   fem_data_loader_objects fdlo,
                   fem_object_definition_b fodb
            WHERE  loader_obj_def_id = p_obj_def_id
              AND  fdlp.table_name = fdlo.table_name
              AND  fdlo.object_id = fodb.object_id;
          EXCEPTION
             WHEN OTHERS THEN
               fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                            ,p_module   => g_block||'.get_parameters (PROCEDURE)'
                                            ,p_msg_text => 'EXCEPTION in get_parameters  ' || sqlerrm);
               fnd_file.put_line(fnd_file.log, 'Exception - get_parameters(DATA LOAD) ' || sqlerrm);
               RAISE;
          END;
       ELSE
          BEGIN
            SELECT ROWNUM,
                   table_name,
                   dataset_code,
                   ledger_id,
                   load_option,
                   cal_period_grp_id,
                   'SELECT cal_period_number,
                           cal_period_end_date,
                           cal_per_dim_grp_display_code,
                           ledger_display_code,
                           ds_balance_type_code,
                           budget_display_code,
                           encumbrance_type_code,' || '''' ||
                           table_name || '''' || ',' || 'TO_NUMBER(''' || ROWNUM || ''')' ||
                   ' FROM  '       dyn_sql_stmt,
                   1000 object_id
            BULK COLLECT INTO gs_table_row_tab,
                              gs_table_name_tab,
                              gs_ds_tab,
                              gs_ledger_tab,
                              gs_load_opt_tab,
                              gs_cal_grp_tab,
                              gs_sql_stmt_tab,
                              gs_table_obj_id
            FROM   fem_data_loader_params
            WHERE  loader_obj_def_id = p_obj_def_id;

          EXCEPTION
             WHEN OTHERS THEN
               fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                            ,p_module   => g_block||'.get_parameters (PROCEDURE)'
                                            ,p_msg_text => 'EXCEPTION in get_parameters(LEDGER LOAD) ' || sqlerrm);
               fnd_file.put_line(fnd_file.log, 'Exception - get_parameters ' || sqlerrm);
               RAISE;
          END;

       END IF;

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.get_parameters(PROCEDURE)'
                                    ,p_msg_text => 'END get_parameters');

  END get_parameters;

  ---------------------
  -- END get_parameters
  ---------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure gets the dimension id's, attribute id's of all the dimensions
  -- and attributes that get used during the course of LOADER run
  --
  --------------------------------------------------------------------------------

  PROCEDURE process_global_id IS

  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'BEGIN..for process_global_id ');

    BEGIN
      SELECT dimension_id
      INTO   g_ledger_dim_id
      FROM   fem_dimensions_b
      WHERE  dimension_varchar_label = 'LEDGER';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching dimension_id for LEDGER');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated dimension_id for LEDGER :: ' || g_ledger_dim_id);

    BEGIN
      SELECT da.attribute_id
      INTO   g_cal_period_hier_attr
      FROM   fem_dim_attributes_b da,
             fem_dim_attr_versions_b dav
      WHERE  da.dimension_id = g_ledger_dim_id
        AND  da.attribute_varchar_label = 'CAL_PERIOD_HIER_OBJ_DEF_ID'
        AND  dav.attribute_id = da.attribute_id
        AND  dav.default_version_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching attribute_id for CAL PERIOD HIERARCHY');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated attribute_id for CAL PERIOD HIERARCHY  :: ' ||
                                                 g_cal_period_hier_attr);


    BEGIN
      SELECT dimension_id
      INTO   g_cal_period_dim_id
      FROM   fem_dimensions_b
      WHERE  dimension_varchar_label = 'CAL_PERIOD';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching dimension_id for CAL PERIOD');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated dimension_id for CAL_PERIOD :: ' || g_cal_period_dim_id);


    BEGIN
      SELECT da.attribute_id
      INTO   g_start_date_attr
      FROM   fem_dim_attributes_b da,
             fem_dim_attr_versions_b dav
      WHERE  da.dimension_id = g_cal_period_dim_id
        AND  da.attribute_varchar_label = 'CAL_PERIOD_START_DATE'
        AND  dav.attribute_id = da.attribute_id
        AND  dav.default_version_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching attribute_id for CAL PERIOD START DATE');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated attribute_id for CAL PERIOD START DATE  :: ' ||
                                                 g_start_date_attr);


    BEGIN
      SELECT da.attribute_id
      INTO   g_end_date_attr
      FROM   fem_dim_attributes_b da,
             fem_dim_attr_versions_b dav
      WHERE  da.dimension_id = g_cal_period_dim_id
        AND  da.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
        AND  dav.attribute_id = da.attribute_id
        AND  dav.default_version_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching attribute_id for CAL PERIOD END DATE');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated attribute_id for CAL PERIOD END DATE  :: ' || g_end_date_attr);

    BEGIN
      SELECT dimension_id
      INTO   g_dataset_dim_id
      FROM   fem_dimensions_b
      WHERE  dimension_varchar_label = 'DATASET';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching dimension_id for DATASET');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated dimension_id for DATASET :: ' || g_dataset_dim_id);


    BEGIN
      SELECT da.attribute_id
      INTO   g_dataset_bal_attr
      FROM   fem_dim_attributes_b da,
             fem_dim_attr_versions_b dav
      WHERE  da.dimension_id = g_dataset_dim_id
        AND  da.attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE'
        AND  dav.attribute_id = da.attribute_id
        AND  dav.default_version_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching attribute_id for DATASET BALANCE TYPE');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated attribute_id for DATASET BALANCE TYPE  :: ' ||
                                                 g_dataset_bal_attr);


    BEGIN
      SELECT da.attribute_id
      INTO   g_production_attr
      FROM   fem_dim_attributes_b da,
             fem_dim_attr_versions_b dav
      WHERE  da.dimension_id = g_dataset_dim_id
        AND  da.attribute_varchar_label = 'PRODUCTION_FLAG'
        AND  dav.attribute_id = da.attribute_id
        AND  dav.default_version_flag = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching attribute_id for PRODUCTION FLAG');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated attribute_id for PRODUCTION FLAG  :: ' || g_production_attr);


    BEGIN
      SELECT dim.dimension_id
      INTO   g_budget_dim_id
      FROM   fem_dimensions_b dim
      WHERE  dim.dimension_varchar_label = 'BUDGET';
    EXCEPTION
      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                      ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                      ,p_msg_text => 'EXCEPTION fetching dimension_id for BUDGET');
         fnd_file.put_line(fnd_file.log, 'Exception - process_global_id ' || sqlerrm);
         RAISE;
    END;

    fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'Evaluated dimension_id for BUDGET :: ' || g_budget_dim_id);


    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.process_global_id(PROCEDURE)'
                                 ,p_msg_text => 'END process_global_id');

  END process_global_id;

  --------------------------
  -- END process_global_id
  --------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used to wait for set of concurrent requests to complete,
  -- capture the request status
  --
  --------------------------------------------------------------------------------

  PROCEDURE wait_for_requests(p_wait_for IN VARCHAR2) IS
    l_request_id      NUMBER;

    l_return_status   VARCHAR2(1);
    l_msg_data        VARCHAR2(4000);
    l_msg_count       NUMBER;

    l_phase           VARCHAR2(200);
    l_status          VARCHAR2(200);
    l_dev_phase       VARCHAR2(200);
    l_dev_status      VARCHAR2(200);
    l_message         VARCHAR2(200);
    l_ret_code        NUMBER;
    l_err_buff        VARCHAR2(1000);
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for wait_for_requests ');

     CASE p_wait_for
     WHEN c_dim_loader THEN
        FOR dim_rec IN (SELECT DISTINCT
                               request_id
                        FROM   fem_ld_dim_requests_gt
                        WHERE  request_id > 0 )
        LOOP
           IF fnd_concurrent.wait_for_request(request_id=> dim_rec.request_id,
                                              interval => c_interval,
                                              max_wait => c_max_wait_time,
                                              phase => l_phase,
                                              status => l_status,
                                              dev_phase => l_dev_phase,
                                              dev_status => l_dev_status,
                                              message => l_message)
           THEN
              IF l_dev_phase || '.' || l_dev_status IN ('COMPLETE.NORMAL','COMPLETE.WARNING') THEN
                 UPDATE fem_ld_dim_requests_gt
                 SET    status = 'Y'
                 WHERE  request_id = dim_rec.request_id;
              ELSE
                 UPDATE fem_ld_dim_requests_gt
                 SET    status = 'N'
                 WHERE  request_id = dim_rec.request_id;
              END IF;

           END IF;  -- fnd_concurrent.wait_for_request (DIMENSIONS)

        END LOOP; -- dim_rec

     WHEN c_data_ledger_loader THEN
        FOR i IN 1..g_master_rec.COUNT LOOP
           IF g_master_rec(i).request_id > 0 THEN
              IF fnd_concurrent.wait_for_request(request_id=> g_master_rec(i).request_id,
                                                 interval => c_interval,
                                                 max_wait => c_max_wait_time,
                                                 phase => l_phase,
                                                 status => l_status,
                                                 dev_phase => l_dev_phase,
                                                 dev_status => l_dev_status,
                                                 message => l_message)
              THEN
                 IF l_dev_phase || '.' || l_dev_status IN ('COMPLETE.NORMAL','COMPLETE.WARNING') THEN
                    g_master_rec(i).status := 'Y';
                 ELSE
                    g_master_rec(i).status := 'N';
                 END IF;

             END IF;  -- fnd_concurrent.wait_for_request (DATA/LEDGER LOAD)

           END IF; -- g_master_rec(i).request_id > 0

        END LOOP; -- dim_rec
     ELSE  -- 'Hierarchy'
        FOR hier_rec IN (SELECT DISTINCT
                                request_id
                         FROM   fem_ld_hier_requests_gt
                         WHERE  request_id > 0 )
        LOOP
           IF fnd_concurrent.wait_for_request(request_id=> hier_rec.request_id,
                                              interval => c_interval,
                                              max_wait => c_max_wait_time,
                                              phase => l_phase,
                                              status => l_status,
                                              dev_phase => l_dev_phase,
                                              dev_status => l_dev_status,
                                              message => l_message)
           THEN
              IF l_dev_phase || '.' || l_dev_status IN ('COMPLETE.NORMAL','COMPLETE.WARNING') THEN
                 UPDATE fem_ld_hier_requests_gt
                 SET    status = 'Y'
                 WHERE  request_id = hier_rec.request_id;
              ELSE
                 UPDATE fem_ld_hier_requests_gt
                 SET    status = 'N'
                 WHERE  request_id = hier_rec.request_id;
              END IF;

           END IF;  -- fnd_concurrent.wait_for_request ('Hierarchy')

        END LOOP; -- hier_rec

     END CASE;  -- p_wait_for

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                  ,p_msg_text => 'END wait_for_requests ');

  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in wait_for_requests ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - wait_for_requests ' || sqlerrm);
      RAISE;

  END wait_for_requests;

  ------------------------
  -- END wait_for_requests
  ------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used to submit the dimension loader CP. All the requests
  -- are submitted in parallel. It first checks if there are records in the
  -- interface table before issuing the call to the CP. If no records are present
  -- the request_id is set to -10000 facilitating an easy reporting
  --
  --------------------------------------------------------------------------------


  PROCEDURE submit_dimension_loaders IS
    l_request_id      NUMBER;

    l_table_name      VARCHAR2(30);

    l_dim_load_mode   VARCHAR2(1);
    l_return_status   VARCHAR2(1);
    l_msg_data        VARCHAR2(4000);
    l_msg_count       NUMBER;

    l_dummy           NUMBER;
    l_at_least_one    BOOLEAN;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for submit_dimension_loaders');

     l_at_least_one := FALSE;

     FOR dim_rec IN (SELECT DISTINCT
                            dimension_id,
                            dim_intf_table_name
                     FROM   fem_ld_dim_requests_gt )
     LOOP

         BEGIN
            EXECUTE IMMEDIATE 'SELECT 1 FROM ' || dim_rec.dim_intf_table_name || ' WHERE ROWNUM = 1' INTO l_dummy;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_dummy := 0.0;
               fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                            ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                            ,p_msg_text => 'No data exists in the interface table '
                                                           || dim_rec.dim_intf_table_name );
            WHEN OTHERS THEN
               fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                            ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                            ,p_msg_text => 'Error while checking if data EXISTS in interface table '
                                                           || dim_rec.dim_intf_table_name || ' - ' || sqlerrm);
               fnd_file.put_line(fnd_file.log, 'Exception - submit_dimension_loaders ' || sqlerrm);
               RAISE;
         END;

         IF l_dummy = 1 THEN

            fem_loader_eng_util_pkg.get_dim_loader_exec_mode(c_api_version,
                                                             c_false,
                                                             c_false,
                                                             c_true,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data,
                                                             dim_rec.dimension_id,
                                                             l_dim_load_mode);

            l_request_id := fnd_request.submit_request('FEM',
                                                       'FEM_DIM_MEMBER_LOADER',
                                                       NULL,
                                                       NULL,
                                                       FALSE,
                                                       l_dim_load_mode,
                                                       dim_rec.dimension_id);

            l_at_least_one := TRUE;

            COMMIT;
         ELSE
            l_request_id := -10000.0;    -- No records available in interface table
         END IF;

         l_dummy := 0.0;

         UPDATE  fem_ld_dim_requests_gt
         SET     request_id = l_request_id
         WHERE   dimension_id = dim_rec.dimension_id;

     END LOOP;

     IF l_at_least_one THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Calling wait_for_requests - DIMENSION');

        wait_for_requests(c_dim_loader);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Completed wait_for_requests - DIMENSION');
     END IF;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                  ,p_msg_text => 'END submit_dimension_loaders');

  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in submit_dimension_loaders ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - submit_dimension_loaders ' || sqlerrm);
      RAISE;

  END submit_dimension_loaders;

  -------------------------------
  -- END submit_dimension_loaders
  -------------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure relies on g_master_rec to submit the data loaders
  --
  --------------------------------------------------------------------------------

  PROCEDURE submit_data_loaders IS

    l_return_status      VARCHAR2(1);
    l_msg_data           VARCHAR2(4000);
    l_msg_count          NUMBER;
    l_at_least_one       BOOLEAN;

    exit_condition       BOOLEAN;
    l_data_load_mode     VARCHAR2(1);

	l_rec_count          NUMBER:=0;
	l_num_loader         NUMBER;
	l_count              NUMBER:=0;

	i                    NUMBER:=1;

	e_num_loader_neg     EXCEPTION;

  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                 ,p_msg_text => 'BEGIN..for submit_data_loaders');

    l_at_least_one := FALSE;
    exit_condition := FALSE;

	l_num_loader:=FND_PROFILE.VALUE('FEM_NUM_OF_LOADERS');

	IF l_num_loader is NOT NULL AND l_num_loader<=0 THEN

	    RAISE e_num_loader_neg;

	END IF;

	l_rec_count :=g_master_rec.COUNT;

  	IF (l_num_loader is NULL OR l_num_loader>=l_rec_count) THEN

     FOR i IN 1..g_master_rec.COUNT LOOP
       IF i <> 1.0 THEN
          exit_condition := FALSE;
          FOR j IN 1..i-1 LOOP
              IF ((g_master_rec(j).table_name = g_master_rec(i).table_name) AND
                  (g_master_rec(j).ledger_id = g_master_rec(i).ledger_id) AND
                  (g_master_rec(j).dataset_code = g_master_rec(i).dataset_code) AND
                  (g_master_rec(j).source_system_code = g_master_rec(i).source_system_code) AND
                  (g_master_rec(j).cal_period_id = g_master_rec(i).cal_period_id))
              THEN
                  g_master_rec(i).request_id := g_master_rec(j).request_id;
                  exit_condition := TRUE;
              END IF;
              EXIT WHEN exit_condition = TRUE;
          END LOOP;
       END IF; -- i<> 1

       IF NOT exit_condition THEN

          fem_loader_eng_util_pkg.get_fact_loader_exec_mode(c_api_version,
                                                            c_false,
                                                            c_false,
                                                            c_true,
                                                            l_return_status,
                                                            l_msg_count,
                                                            l_msg_data,
                                                            g_master_rec(i).cal_period_id,
                                                            g_master_rec(i).ledger_id,
                                                            g_master_rec(i).dataset_code,
                                                            g_master_rec(i).source_system_code,
                                                            g_master_rec(i).table_name,
                                                            l_data_load_mode);

          g_master_rec(i).request_id := fnd_request.submit_request('FEM',
                                                                   'FEM_SOURCE_DATA_LOADER',
                                                                   NULL,
                                                                   NULL,
                                                                   FALSE,
                                                                   gs_table_obj_def_id(g_master_rec(i).table_row),
                                                                   l_data_load_mode,
                                                                   g_master_rec(i).ledger_id,
                                                                   g_master_rec(i).cal_period_id,
                                                                   g_master_rec(i).dataset_code,
                                                                   g_master_rec(i).source_system_code);
          l_at_least_one := TRUE;

          COMMIT;

       END IF; -- exit_condition

    END LOOP; -- g_master_rec

    IF l_at_least_one THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Calling wait_for_requests - DATA LOAD');

        wait_for_requests(c_data_ledger_loader);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Completed wait_for_requests - DATA LOAD');

    END IF;

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                 ,p_msg_text => 'END submit_data_loaders');

    END IF;--IF (l_num_loader is NULL OR l_num_loader>=l_rec_count)

	IF (l_num_loader is NOT NULL AND l_num_loader<l_rec_count) THEN

	i:=1;
	l_count:=0;

	WHILE(i<=l_rec_count) LOOP

	   LOOP

	   IF i <> 1.0 THEN
        exit_condition := FALSE;
        FOR j IN 1..i-1 LOOP
              IF ((g_master_rec(j).table_name = g_master_rec(i).table_name) AND
                  (g_master_rec(j).ledger_id = g_master_rec(i).ledger_id) AND
                  (g_master_rec(j).dataset_code = g_master_rec(i).dataset_code) AND
                  (g_master_rec(j).source_system_code = g_master_rec(i).source_system_code) AND
                  (g_master_rec(j).cal_period_id = g_master_rec(i).cal_period_id))
              THEN
                  g_master_rec(i).request_id := g_master_rec(j).request_id;
                  exit_condition := TRUE;

              END IF;
              EXIT WHEN exit_condition = TRUE;
        END LOOP;
       END IF; -- i<> 1

       IF NOT exit_condition THEN

        fem_loader_eng_util_pkg.get_fact_loader_exec_mode(c_api_version,
                                                            c_false,
                                                            c_false,
                                                            c_true,
                                                            l_return_status,
                                                            l_msg_count,
                                                            l_msg_data,
                                                            g_master_rec(i).cal_period_id,
                                                            g_master_rec(i).ledger_id,
                                                            g_master_rec(i).dataset_code,
                                                            g_master_rec(i).source_system_code,
                                                            g_master_rec(i).table_name,
                                                            l_data_load_mode);

        g_master_rec(i).request_id := fnd_request.submit_request('FEM',
                                                                   'FEM_SOURCE_DATA_LOADER',
                                                                   NULL,
                                                                   NULL,
                                                                   FALSE,
                                                                   gs_table_obj_def_id(g_master_rec(i).table_row),
                                                                   l_data_load_mode,
                                                                   g_master_rec(i).ledger_id,
                                                                   g_master_rec(i).cal_period_id,
                                                                   g_master_rec(i).dataset_code,
                                                                   g_master_rec(i).source_system_code);
        l_at_least_one := TRUE;

 		COMMIT;
        l_count := l_count+1;

       END IF; -- exit_condition

	   i:=i+1;

       EXIT WHEN((l_count>=l_num_loader AND mod(l_count,l_num_loader)=0) OR i>l_rec_count);

	   END LOOP; -- Internal loop


       --wait only for submitted requests
       IF l_at_least_one THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Calling wait_for_requests - DATA LOAD');

        wait_for_requests(c_data_ledger_loader);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Completed wait_for_requests - DATA LOAD');

        END IF;

        fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                 ,p_msg_text => 'END submit_data_loaders');

 	END LOOP; --WHILE(i<=l_rec_count) LOOP


	END IF;--IF (l_num_loader is NOT NULL AND l_num_loader<l_rec_count)

  EXCEPTION
    WHEN e_num_loader_neg THEN

	  FEM_ENGINES_PKG.User_Message (
                        p_app_name  => 'FEM'
                        ,p_msg_name => 'FEM_NUM_OF_LOADERS_NEG_ERR'
        );

	  RAISE ;
	WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.submit_data_loaders(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in submit_data_loaders ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - submit_data_loader ' || sqlerrm);
      RAISE;


  END submit_data_loaders;

  --------------------------
  -- END submit_data_loaders
  --------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure relies on g_master_rec to submit the ledger loader
  --
  --------------------------------------------------------------------------------


  PROCEDURE submit_ledger_loader(p_balance_type IN VARCHAR2) IS
    l_return_status      VARCHAR2(1);
    l_msg_data           VARCHAR2(4000);
    l_msg_count          NUMBER;
    l_at_least_one       BOOLEAN;

    exit_condition       BOOLEAN;
    l_ledger_load_mode   VARCHAR2(1);
  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.submit_ledger_loader(PROCEDURE)'
                                 ,p_msg_text => 'BEGIN..for submit_ledger_loader');

    l_at_least_one := FALSE;
    exit_condition := FALSE;

    FOR i IN 1..g_master_rec.COUNT LOOP
       IF i <> 1.0 THEN
          exit_condition := FALSE;
          FOR j IN 1..i-1 LOOP
              IF ((g_master_rec(j).ledger_id = g_master_rec(i).ledger_id) AND
                  (g_master_rec(j).dataset_code = g_master_rec(i).dataset_code) AND
                  (g_master_rec(j).cal_period_id = g_master_rec(i).cal_period_id) AND
                  (NVL(g_master_rec(j).budget_id,0) = NVL(g_master_rec(i).budget_id,0)) AND
                  (NVL(g_master_rec(j).enc_type_id,0) = NVL(g_master_rec(i).enc_type_id,0)))
              THEN
                  g_master_rec(i).request_id := g_master_rec(j).request_id;
                  exit_condition := TRUE;
              END IF;
              EXIT WHEN exit_condition = TRUE;
          END LOOP;
       END IF; -- i<> 1

       IF NOT exit_condition THEN

          fem_loader_eng_util_pkg.get_xgl_loader_exec_mode(c_api_version,
                                                           c_false,
                                                           c_false,
                                                           c_true,
                                                           l_return_status,
                                                           l_msg_count,
                                                           l_msg_data,
                                                           g_master_rec(i).cal_period_id,
                                                           g_master_rec(i).ledger_id,
                                                           g_master_rec(i).dataset_code,
                                                           l_ledger_load_mode);

          -- The object_def_id fin CP for the external gl loader is currently hard-coded
          -- to 1000; maintaining the same here.

          g_master_rec(i).request_id := fnd_request.submit_request('FEM',
                                                                   'FEM_XGL_POST_ENGINE',
                                                                    NULL,
                                                                    NULL,
                                                                    FALSE,
                                                                    l_ledger_load_mode,
                                                                    g_master_rec(i).ledger_id,
                                                                    g_master_rec(i).cal_period_id,
                                                                    g_master_rec(i).budget_id,
                                                                    g_master_rec(i).enc_type_id,
                                                                    g_master_rec(i).dataset_code,
                                                                    1000,
                                                                    p_balance_type);

          l_at_least_one := TRUE;

          COMMIT;

       END IF; -- exit_condition

    END LOOP; -- g_master_rec

    IF l_at_least_one THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_ledger_loader(PROCEDURE)'
                                     ,p_msg_text => 'Calling wait_for_requests - LEDGER LOAD');

        wait_for_requests(c_data_ledger_loader);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_ledger_loader(PROCEDURE)'
                                     ,p_msg_text => 'Completed wait_for_requests - LEDGER LOAD');

    END IF;

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.submit_ledger_loader(PROCEDURE)'
                                 ,p_msg_text => 'END submit_ledger_loader');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.submit_ledger_loader(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in submit_ledger_loader ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - submit_ledger_loader ' || sqlerrm);
      RAISE;

  END submit_ledger_loader;

  ----------------------------
  -- END submit_ledger_loaders
  ----------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure submits the hierarchy loader CP. Only unique combinations are
  -- submitted
  --
  --------------------------------------------------------------------------------


  PROCEDURE submit_hierarchy_loaders IS
    l_request_id      NUMBER;

    l_table_name      VARCHAR2(30);

    l_hier_load_mode  VARCHAR2(1);

    l_return_status   VARCHAR2(1);
    l_msg_data        VARCHAR2(4000);
    l_msg_count       NUMBER;

    l_at_least_one    BOOLEAN;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.submit_hierarchy_loader(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for submit_hierarchy_loader');

     l_at_least_one := FALSE;

     FOR hier_rec IN (SELECT DISTINCT
                             dimension_id,
                             dimension_varchar_label,
                             hierarchy_object_name,
                             hier_obj_def_display_name
                      FROM   fem_ld_hier_requests_gt )
     LOOP

         fem_loader_eng_util_pkg.get_hier_loader_exec_mode(c_api_version,
                                                           c_false,
                                                           c_false,
                                                           c_true,
                                                           l_return_status,
                                                           l_msg_count,
                                                           l_msg_data,
                                                           hier_rec.dimension_id,
                                                           hier_rec.hierarchy_object_name,
                                                           l_hier_load_mode);

         l_request_id := fnd_request.submit_request('FEM',
                                                    'FEM_HIER_LOADER',
                                                    NULL,
                                                    NULL,
                                                    FALSE,
                                                    g_hier_object_def_id,
                                                    l_hier_load_mode,
                                                    hier_rec.dimension_varchar_label,
                                                    hier_rec.hierarchy_object_name,
                                                    hier_rec.hier_obj_def_display_name);

         COMMIT;

         l_at_least_one := TRUE;

        UPDATE fem_ld_hier_requests_gt
        SET    request_id = l_request_id
        WHERE  hier_obj_def_display_name = hier_rec.hier_obj_def_display_name
          AND  dimension_id = hier_rec.dimension_id;

     END LOOP;


     IF l_at_least_one THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_hierarchy_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Calling wait_for_requests - HIERARCHY');

        wait_for_requests(c_hier_loader);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.submit_hierarchy_loaders(PROCEDURE)'
                                     ,p_msg_text => 'Completed wait_for_requests - HIERARCHY');
     END IF;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.submit_hierarchy_loader(PROCEDURE)'
                                  ,p_msg_text => 'END submit_hierarchy_loader');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.submit_hierarchy_loader(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in submit_hierarchy_loader ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - submit_hierarchy_loaders ' || sqlerrm);
      RAISE;

  END submit_hierarchy_loaders;

  -------------------------------
  -- END submit_hierarchy_loaders
  -------------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure populates the list of all dimensions across all the unique
  -- tables. If the user has selected the option of loading the hierarchies as
  -- well, populates fem_ld_hier_requests_gt with the info.
  --
  --------------------------------------------------------------------------------

  PROCEDURE build_dim_stages IS
     l_dummy                 NUMBER;
     l_dimension_load        BOOLEAN;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for build_dim_stages');

     l_dummy := 0.0;
     l_dimension_load := FALSE;

     FOR i IN 1..gs_table_name_tab.COUNT LOOP
          fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                       ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                       ,p_msg_text => 'Building dim stages for table :: ' ||
                                                      gs_table_name_tab(i) ||
                                                      ' Load Option :: ' ||
                                                      gs_load_opt_tab(i) ||
                                                      ' for load_type :: ' || g_loader_type );

          IF gs_load_opt_tab(i) IN ('DD', 'DDH')  THEN
              l_dimension_load := TRUE;
              IF g_loader_type = 'CLIENT' THEN
                 BEGIN
                   SELECT 1.0
                   INTO   l_dummy
                   FROM   fem_ld_dim_requests_gt
                   WHERE  table_name = gs_table_name_tab(i)
                     AND  ROWNUM = 1;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     l_dummy := 0.0;
                 END;
              END IF; -- g_loader_type = 'CLIENT'

              IF l_dummy <> 1 THEN
                 BEGIN
                   INSERT INTO fem_ld_dim_requests_gt(dimension_id,
                                                      dimension_varchar_label,
                                                      table_name,
                                                      dim_intf_table_name,
                                                      request_id,
                                                      status)
                   SELECT fdb.dimension_id,
                          dimension_varchar_label,
                          gs_table_name_tab(i),
                          intf_member_b_table_name,
                          TO_NUMBER(NULL),
                          'N'
                   FROM   fem_tab_columns_b ftcb,
                          fem_dimensions_b fdb,
                          fem_xdim_dimensions fxd
                   WHERE  table_name = gs_table_name_tab(i)
                     AND  fem_data_type_code = 'DIMENSION'
                     AND  fdb.dimension_id = ftcb.dimension_id
                     AND  fxd.dimension_id = fdb.dimension_id
                     AND  intf_member_b_table_name IS NOT NULL;

                   IF g_loader_type = 'LEDGER' THEN
                      l_dummy := 1.0;
                   END IF;

                 EXCEPTION
                    WHEN OTHERS THEN
                      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                                   ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                                   ,p_msg_text => 'EXCEPTION in build_dim_stages - insert into
                                                                   fem_ld_dim_requests_gt');
                      fnd_file.put_line(fnd_file.log, 'Exception - build_dim_stages ' || sqlerrm);
                      RAISE;
                 END;

              END IF; -- l_dummy <> 1

           END IF; -- gs_load_opt_tab(i) = 'DD'

           l_dummy := 0.0;

           IF gs_load_opt_tab(i) = 'DDH' THEN
              g_hierarchy_exists := TRUE;
              IF g_hier_object_def_id IS NULL THEN
                 BEGIN
                   SELECT object_definition_id
                   INTO   g_hier_object_def_id
                   FROM   fem_object_definition_vl d
                   WHERE  d.object_id in (SELECT o.object_id
                                          FROM   fem_object_catalog_vl o
                                          WHERE  o.object_type_code = 'HIERARCHY_LOADER'
                                            AND  o.folder_id in (SELECT f.folder_id
                                                                 FROM   fem_user_folders f
                                                                 WHERE  f.user_id = fnd_global.user_id)
                                          )
                     AND   d.old_approved_copy_flag = 'N'
                     AND   d.approval_status_code NOT IN ('SUBMIT_DELETE','SUBMIT_APPROVAL');
                 EXCEPTION
                    WHEN OTHERS THEN
                      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                                   ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                                   ,p_msg_text => 'EXCEPTION in build_dim_stages - fetching
                                                                   object_def_id for HIER');
                      fnd_file.put_line(fnd_file.log, 'Exception - build_dim_stages ' || sqlerrm);
                      RAISE;
                 END;

              END IF; -- l_object_def_id IS NULL

              IF g_loader_type = 'CLIENT' THEN
                 BEGIN
                   SELECT 1.0
                   INTO   l_dummy
                   FROM   fem_ld_hier_requests_gt
                   WHERE  table_name = gs_table_name_tab(i)
                     AND  ROWNUM = 1 ;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     l_dummy := 0.0;
                 END;
              END IF; -- g_loader_type = 'CLIENT'

              IF l_dummy <> 1.0 THEN
                 BEGIN
                   INSERT INTO fem_ld_hier_requests_gt(dimension_id,
                                                      dimension_varchar_label,
                                                      hierarchy_object_name,
                                                      hier_obj_def_display_name,
                                                      table_name,
                                                      request_id)
                   SELECT drt.dimension_id,
                          drt.dimension_varchar_label,
                          fht.hierarchy_object_name,
                          fht.hier_obj_def_display_name,
                          gs_table_name_tab(i),
                          TO_NUMBER(NULL)
                   FROM   fem_ld_dim_requests_gt drt,
                          fem_hierarchies_t fht
                   WHERE  table_name = gs_table_name_tab(i)
                     AND  drt.dimension_varchar_label = fht.dimension_varchar_label;
                 EXCEPTION
                    WHEN OTHERS THEN
                      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                                   ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                                   ,p_msg_text => 'EXCEPTION in build_dim_stages - insert into
                                                                   fem_ld_hier_requests_gt');
                      fnd_file.put_line(fnd_file.log, 'Exception - build_dim_stages ' || sqlerrm);
                      RAISE;
                 END;

              END IF; -- l_dummy <> 1

           END IF;  -- gs_load_opt_tab(i) = 'DDH'

     END LOOP; -- 1..gs_table_name_tab.COUNT

     IF l_dimension_load THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                     ,p_msg_text => 'Calling submit_dimension_loaders');

        submit_dimension_loaders;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                     ,p_msg_text => 'Completed submit_dimension_loaders');
     END IF;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                  ,p_msg_text => 'END build_dim_stages');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in build_dim_stages ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - build_dim_stages ' || sqlerrm);
      RAISE;

  END build_dim_stages;

  -----------------------
  -- END build_dim_stages
  -----------------------


  --------------------------------------------------------------------------------
  --
  --
  --
  --
  --------------------------------------------------------------------------------

  PROCEDURE print_params IS

  BEGIN

     fnd_file.put_line(FND_FILE.log, '=============================================================================');
     fnd_file.put_line(FND_FILE.log, '========================     Printing Parameters   ==========================');

     FOR i IN 1..gs_table_name_tab.COUNT LOOP
       fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || gs_table_name_tab(i));
       fnd_file.put_line(FND_FILE.log, ' Ledger     :: ' || gs_ledger_tab(i));
       fnd_file.put_line(FND_FILE.log, ' Dataset    :: ' || gs_ds_tab(i));
       fnd_file.put_line(FND_FILE.log, ' SQL Stmt   :: ' || gs_sql_stmt_tab(i));
       fnd_file.put_line(FND_FILE.log, ' Load Option:: ' || gs_load_opt_tab(i));
       IF g_loader_type = 'CLIENT' THEN
          fnd_file.put_line(FND_FILE.log, ' Table Obj  :: ' || gs_table_obj_def_id(i));
       END IF;
     END LOOP;

     fnd_file.put_line(FND_FILE.log, '========================     End  Printing Parameters  ======================');
     fnd_file.put_line(FND_FILE.log, '=============================================================================');


  END print_params;

  -------------------
  -- END print_params
  -------------------

  --------------------------------------------------------------------------------
  --
  -- This is one of the core procedure. Approach is as follows..
  --
  -- 1. Builds the dynamic SQL to get DISTINCT values
  -- 2. If a table name has been repeated more than once, then the distinct values
  --    already reside in the fem_ld_interface_data_gt and makes no sense in querying
  --    the interface table; updates the g*dup tables for the index
  -- 3. Fetches the unique set of records, populates the fem_ld_interface_data_gt
  --    for all the tables specified by the user
  --    3a. If a table has been repeated, then it inserts the same set querying on
  --        the data for the same table in the I occurence
  -- 4. Fetching of unique set differs for the DATA and LEDGER load, while DATA
  --    load relies on the table name, LEDGER load relies on the dataset balance
  --    type code; otherwise the concept remains the same
  -- 5. Then the corresponding ID's are populated for the records fetched into the
  --    fem_ld_interface_data_gt table
  -- 6. If the above updates fetches 0 records, then there is no point in proceeding
  --    captures this info. in g_loader_run
  --    6a. If the update results in more than 0 then proceeds to the next step
  -- 7. The next step is to identify all the datasets that are production datasets
  -- 8. Once this is done, the fem_ld_interface_data_gt is validated with the i/p params
  --    specified in the selection criteria while defining the parameters
  -- 9. All the records that match this crietria are marked with status = 'VALID'
  --    9a. gs_valid_rows is updated with the number of records updated
  --10. All the records with status = 'INVALID' are deleted, these are stored in
  --    g_inv* pl/sql tables. This might help us in the future for better error
  --    reporting
  --11. If the rule is a LEDGER load ::
  --    Populate the encumbrnace_type_id
  --    Populate the budget_id
  --12. In the last of the steps populates the calendar_id, cal_period
  --
  --------------------------------------------------------------------------------


  PROCEDURE evaluate_parameters IS
     l_dummy                    NUMBER;
     l_int_table_name           VARCHAR2(30);
     l_bal_type_code            VARCHAR2(30);

     l_ledger_tab               char_table;
     l_dataset_tab              char_table;
     l_source_system_tab        char_table;
     l_cal_period_number_tab    number_table;
     l_cal_period_level_tab     char_table;
     l_cal_period_end_date_tab  date_table;
     l_table_name_tab           char_table;
     l_table_row_tab            number_table;
     l_dataset_code_tab         number_table;
     l_ds_bal_code_tab          char_table;
     l_budget_display_cd_tab    char_table;
     l_encumbrance_type_cd_tab  char_table;

     no_interface_table_exists  BOOLEAN;

     l_table_name               VARCHAR2(30);
     l_table_row                NUMBER;
     l_ledger_rows              NUMBER;

     l_dupe_count               NUMBER;
     l_dupe_position            NUMBER;
     l_dupe_text                VARCHAR2(20);
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for evaluate_parameters');

     l_dummy := 0.0;

     IF g_loader_type = 'CLIENT' THEN

          FOR i IN 1..gs_table_name_tab.COUNT LOOP

             no_interface_table_exists := FALSE;

             BEGIN
               SELECT interface_table_name
               INTO   l_int_table_name
               FROM   fem_tables_b
               WHERE  table_name = gs_table_name_tab(i);
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  no_interface_table_exists := TRUE;
             END;

             -- Need to check for the physical existence of the table

             BEGIN
               EXECUTE IMMEDIATE 'SELECT 1 FROM ' || gs_table_name_tab(i) || ' WHERE ROWNUM=1';
             EXCEPTION
               WHEN OTHERS THEN
                 fnd_file.put_line(fnd_file.log, 'Table ' || gs_table_name_tab(i) || ' does not exist ');
                 fnd_file.put_line(fnd_file.log, 'Exception - evaluate_parameters ' || sqlerrm);
                 RAISE;
             END;

             l_dupe_count := 0.0;
             l_dupe_position := -1.0;
             l_dupe_text := c_not_dupe_text;

             IF NOT no_interface_table_exists THEN
                gs_sql_stmt_tab(i) := gs_sql_stmt_tab(i) || l_int_table_name;
                gs_sql_stmt_tab(i) := gs_sql_stmt_tab(i) || ' GROUP BY ledger_display_code,
                                                                    dataset_display_code,
                                                                    source_system_display_code,
                                                                    cal_period_number,
                                                                    calp_dim_grp_display_code,
                                                                    cal_period_end_date';

                -- If the same table is selected multiple times in the parameters
                -- screen, we need not get the DISTINCT from the interface table
                -- , instead can get it from fem_ld_interface_data_gt.

                -- So need to check for the same. The same can be done before this
                -- loop; since we loop on the table_name for the first time here in
                -- the code, keeping this piece here.

                FOR j IN 1..i LOOP
                   IF gs_table_name_tab(i) = gs_table_name_tab(j) THEN

                      l_dupe_count := l_dupe_count + 1.0;

                      IF l_dupe_count = 1.0 THEN
                         l_dupe_position := j;
                      END IF;

                      IF l_dupe_count = 2.0 THEN
                         l_dupe_text := c_dupe_text;
                         EXIT;
                      END IF;

                   END IF;
                END LOOP;

                gs_valid_rows(i) := -1.0;      -- Dummy initialization

             ELSE
                gs_sql_stmt_tab(i) := NULL;
                gs_valid_rows(i) := -2.0;      -- Useful for printing message to the user that there is no
                                               -- interface table defined
             END IF;

             gs_sql_dup_tab(i) := l_dupe_text;
             gs_sql_dup_indx_tab(i) := l_dupe_position;

          END LOOP; -- 1..gs_table_name_tab.COUNT

          FOR i IN 1..gs_sql_stmt_tab.COUNT LOOP
             CASE gs_sql_dup_tab(i)
               WHEN 'DATA_NOT_FETCHED' THEN
                  IF gs_sql_stmt_tab(i) IS NOT NULL THEN
                     EXECUTE IMMEDIATE gs_sql_stmt_tab(i) BULK COLLECT INTO
                                       l_ledger_tab,
                                       l_dataset_tab,
                                       l_source_system_tab,
                                       l_cal_period_number_tab,
                                       l_cal_period_level_tab,
                                       l_cal_period_end_date_tab,
                                       l_table_name_tab,
                                       l_table_row_tab;
                  END IF;

                  -- Check if there is data in the interface table
                  -- if not flag to the exception report

                  IF l_ledger_tab.EXISTS(1) THEN
                     FORALL k IN 1..l_ledger_tab.COUNT
                        INSERT INTO fem_ld_interface_data_gt
                       (ledger_display_code,
                        dataset_display_code,
                        source_system_display_code,
                        cal_period_number,
                        cal_period_level,
                        cal_period_end_date,
                        table_name,
                        table_row,
                        ds_production_valid_flag,
                        status)
                        VALUES
                       (l_ledger_tab(k),
                        l_dataset_tab(k),
                        l_source_system_tab(k),
                        l_cal_period_number_tab(k),
                        l_cal_period_level_tab(k),
                        l_cal_period_end_date_tab(k),
                        l_table_name_tab(k),
                        l_table_row_tab(k),
                        'N',
                        'INVALID');

                        gs_valid_rows(i) := 1.0;
                  ELSE
                    IF gs_sql_stmt_tab(i) IS NULL THEN
                       gs_valid_rows(i) := -2.0;  -- No interface table exists
                    ELSE
                       gs_valid_rows(i) := -1.0;  -- No data found in the interface table
                    END IF;
                 END IF; -- l_ledger_tab.EXISTS(1)

               WHEN 'DATA_FETCHED' THEN

                    -- Data has been retrieved from the interface table
                    -- no point in fetching it again; instead copy the same
                    -- from the fem_ld_interface_data_gt with the new ROW_NUMBER

                    l_table_name := gs_table_name_tab(i);
                    l_table_row := gs_sql_dup_indx_tab(i);

                    IF gs_valid_rows(l_table_row) = 1.0 THEN
                       FORALL k IN l_table_row+1..gs_table_name_tab.COUNT
                         INSERT INTO fem_ld_interface_data_gt
                         (ledger_display_code,
                          dataset_display_code,
                          source_system_display_code,
                          cal_period_number,
                          cal_period_level,
                          cal_period_end_date,
                          table_name,
                          table_row,
                          ds_production_valid_flag,
                          status)
                         SELECT
                          ledger_display_code,
                          dataset_display_code,
                          source_system_display_code,
                          cal_period_number,
                          cal_period_level,
                          cal_period_end_date,
                          table_name,
                          gs_table_row_tab(k),
                          ds_production_valid_flag,
                          status
                         FROM  fem_ld_interface_data_gt
                         WHERE table_name = l_table_name
                           AND table_row =  l_table_row
                           AND gs_table_name_tab(k) = l_table_name;
                    END IF;

                    FOR k IN 1..gs_table_name_tab.COUNT LOOP
                        IF gs_table_name_tab(k) = l_table_name AND l_table_row <> k THEN
                           gs_sql_dup_tab(k) :=  'DATA_LOADED_MULTIPLE_TIMES';
                           gs_valid_rows(k) := gs_valid_rows(l_table_row);
                        END IF;
                    END LOOP;

               ELSE
                  NULL;   -- All conditions handled
               END CASE;  -- WHEN 'DATA_NOT_FETCHED'

          END LOOP; -- 1..gs_sql_stmt_tab.COUNT

          FOR k IN 1..gs_table_name_tab.COUNT LOOP
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');
            fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters(0)                 ');
            fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || gs_table_name_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || gs_table_row_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Dup   Row  :: ' || gs_sql_dup_indx_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Dup   SQL  :: ' || gs_sql_dup_tab(k) );
            fnd_file.put_line(FND_FILE.log, ' Valid Row  :: ' || gs_valid_rows(k));
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');

             fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                          ,p_module   => g_block||'.evaluate_parameters(0)'
                                          ,p_msg_text => ' Table Name :: ' || gs_table_name_tab(k) ||
                                                         ' Table Row  :: ' || gs_table_row_tab(k)  ||
                                                         ' Dup   Row  :: ' || gs_sql_dup_indx_tab(k) ||
                                                         ' Dup   SQL  :: ' || gs_sql_dup_tab(k) ||
                                                         ' Valid Row  :: ' || gs_valid_rows(k));

          END LOOP;

          UPDATE  fem_ld_interface_data_gt idt
          SET     ledger_id = (SELECT ledger_id
                               FROM   fem_ledgers_b flb
                               WHERE  idt.ledger_display_code = flb.ledger_display_code
                                 AND  personal_flag = 'N'
                                 AND  enabled_flag = 'Y'),
                  dataset_code = (SELECT dataset_code
                                  FROM   fem_datasets_b fdb
                                  WHERE  idt.dataset_display_code = fdb.dataset_display_code
                                    AND  personal_flag = 'N'
                                    AND  enabled_flag = 'Y'),
                  source_system_code = (SELECT source_system_code
                                        FROM   fem_source_systems_b fssb
                                        WHERE  idt.source_system_display_code = fssb.source_system_display_code
                                          AND  personal_flag = 'N'
                                          AND  enabled_flag = 'Y'),
                  (dimension_group_id,time_dimension_group_key) = (SELECT dimension_group_id, time_dimension_group_key
                                                                   FROM   fem_dimension_grps_b fdgb
                                                                   WHERE  idt.cal_period_level =
                                                                          fdgb.dimension_group_display_code
                                                                     AND  personal_flag = 'N'
                                                                     AND  enabled_flag = 'Y');
          fem_engines_pkg.tech_message(p_severity => g_log_level_1
                                      ,p_module   => g_block||'.evaluate_parameters'
                                      ,p_msg_text => ' Rows updated after ID population(DATA LOAD) :: ' ||  SQL%ROWCOUNT);

          fnd_file.put_line(fnd_file.log, ' Rows updated after ID population :: ' ||  SQL%ROWCOUNT);

     ELSE  -- g_loader_type = 'LEDGER'

          FOR i IN 1..gs_ledger_tab.COUNT LOOP

              l_dupe_count := 0.0;
              l_dupe_position := -1.0;
              l_dupe_text := c_not_dupe_text;

              SELECT dim_attribute_varchar_member
              INTO   l_bal_type_code
              FROM   fem_datasets_attr
              WHERE  dataset_code = gs_ds_tab(i)
                AND  attribute_id = g_dataset_bal_attr;

              gs_ds_bal_code_tab(i) := l_bal_type_code;

              gs_sql_stmt_tab(i) := gs_sql_stmt_tab(i) || g_int_table_name;
              gs_sql_stmt_tab(i) := gs_sql_stmt_tab(i) || ' WHERE ds_balance_type_code = ' || '''' || l_bal_type_code
                                                       ||'''';
              gs_sql_stmt_tab(i) := gs_sql_stmt_tab(i) || ' GROUP BY cal_period_number,
                                                                     cal_period_end_date,
                                                                     cal_per_dim_grp_display_code,
                                                                     ledger_display_code,
                                                                     ds_balance_type_code,
                                                                     budget_display_code,
                                                                     encumbrance_type_code';

              -- If the same DS bal type is selected multiple times in the parameters
              -- screen, we need not get the DISTINCT from the interface table
              -- , instead can get it from fem_ld_interface_data_gt.

              FOR j IN 1..i LOOP
                 IF gs_ds_bal_code_tab(i) = gs_ds_bal_code_tab(j) THEN
                    l_dupe_count := l_dupe_count + 1.0;

                    IF l_dupe_count = 1.0 THEN
                       l_dupe_position := j;
                    END IF;

                    IF l_dupe_count = 2.0 THEN
                       l_dupe_text := c_dupe_text;
                       EXIT;
                    END IF;

                 END IF;
              END LOOP;

              gs_valid_rows(i) := -1.0;      -- Dummy initialization

              gs_sql_dup_tab(i) := l_dupe_text;
              gs_sql_dup_indx_tab(i) := l_dupe_position;

          END LOOP; -- 1..gs_table_name_tab.COUNT

          l_ledger_rows := gs_ledger_tab.COUNT;

          FOR i IN 1..gs_sql_stmt_tab.COUNT LOOP
             CASE gs_sql_dup_tab(i)

               WHEN 'DATA_NOT_FETCHED' THEN
                 IF l_ledger_rows > 0.0 THEN
                    EXECUTE IMMEDIATE gs_sql_stmt_tab(1) BULK COLLECT INTO
                        l_cal_period_number_tab,
                        l_cal_period_end_date_tab,
                        l_cal_period_level_tab,
                        l_ledger_tab,
                        l_ds_bal_code_tab,
                        l_budget_display_cd_tab,
                        l_encumbrance_type_cd_tab,
                        l_table_name_tab,
                        l_table_row_tab;

                   -- Check if there is data in the interface table
                   -- if not flag to the exception report

                    IF l_ledger_tab.EXISTS(1) THEN
                       FORALL k IN 1..l_ledger_tab.COUNT
                          INSERT INTO fem_ld_interface_data_gt
                          (ledger_display_code,
                           dataset_code,
                           balance_type_code,
                           budget_display_code,
                           encumbrance_type_code,
                           cal_period_number,
                           cal_period_level,
                           cal_period_end_date,
                           table_name,
                           table_row,
                           ds_production_valid_flag,
                           status)
                          VALUES
                          (l_ledger_tab(k),
                           gs_ds_tab(1),
                           l_ds_bal_code_tab(k),
                           l_budget_display_cd_tab(k),
                           l_encumbrance_type_cd_tab(k),
                           l_cal_period_number_tab(k),
                           l_cal_period_level_tab(k),
                           l_cal_period_end_date_tab(k),
                           l_table_name_tab(k),
                           l_table_row_tab(k),
                           'N',
                           'INVALID');

                        gs_valid_rows(1) := 1.0;
                    ELSE
                        gs_valid_rows(1) := -1.0;  -- No data exists in the interface table
                    END IF; -- l_ledger_tab.EXISTS(1)

                 END IF; -- ledger_rows > 0

               WHEN 'DATA_FETCHED' THEN

                    -- Data has been retrieved from the interface table
                    -- no point in fetching it again; instead copy the same
                    -- from the fem_ld_interface_data_gt with the new ROW_NUMBER

                    l_table_name := gs_ds_bal_code_tab(i);
                    l_table_row := gs_sql_dup_indx_tab(i);

                    IF gs_valid_rows(l_table_row) = 1.0 THEN
                       FORALL k IN l_table_row+1..gs_table_name_tab.COUNT
                          INSERT INTO fem_ld_interface_data_gt
                          (ledger_display_code,
                           dataset_code,
                           balance_type_code,
                           budget_display_code,
                           encumbrance_type_code,
                           cal_period_number,
                           cal_period_level,
                           cal_period_end_date,
                           table_name,
                           table_row,
                           ds_production_valid_flag,
                           status)
                          SELECT
                           ledger_display_code,
                           gs_ds_tab(k),
                           balance_type_code,
                           budget_display_code,
                           encumbrance_type_code,
                           cal_period_number,
                           cal_period_level,
                           cal_period_end_date,
                           table_name,
                           gs_table_row_tab(k),
                           ds_production_valid_flag,
                           status
                          FROM  fem_ld_interface_data_gt
                         WHERE  balance_type_code = l_table_name
                           AND  table_row =  l_table_row
                           AND  gs_ds_bal_code_tab(k) = l_table_name;
                    END IF;

                    FOR k IN 1..gs_table_name_tab.COUNT LOOP
                        IF gs_ds_bal_code_tab(k) = l_table_name AND l_table_row <> k THEN
                           gs_sql_dup_tab(k) :=  'DATA_LOADED_MULTIPLE_TIMES';
                           gs_valid_rows(k) := gs_valid_rows(l_table_row);
                        END IF;
                    END LOOP;

               ELSE
                  NULL;   -- All conditions handled
               END CASE;  -- WHEN 'DATA_NOT_FETCHED'

         END LOOP;  -- 1..gs_sql_stmt_tab.COUNT

         FOR k IN 1..gs_table_name_tab.COUNT LOOP
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');
            fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters(0)                 ');
            fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || gs_table_name_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || gs_table_row_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Dup   Row  :: ' || gs_sql_dup_indx_tab(k));
            fnd_file.put_line(FND_FILE.log, ' Dup   SQL  :: ' || gs_sql_dup_tab(k) );
            fnd_file.put_line(FND_FILE.log, ' Valid Row  :: ' || gs_valid_rows(k));
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');

            fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                          ,p_module   => g_block||'.evaluate_parameters(0)'
                                          ,p_msg_text => ' Table Name :: ' || gs_table_name_tab(k) ||
                                                         ' Table Row  :: ' || gs_table_row_tab(k)  ||
                                                         ' Dup   Row  :: ' || gs_sql_dup_indx_tab(k) ||
                                                         ' Dup   SQL  :: ' || gs_sql_dup_tab(k) ||
                                                         ' Valid Row  :: ' || gs_valid_rows(k));

         END LOOP;


         UPDATE  fem_ld_interface_data_gt idt
         SET     ledger_id = (SELECT ledger_id
                              FROM   fem_ledgers_b flb
                              WHERE  idt.ledger_display_code = flb.ledger_display_code
                                AND  personal_flag = 'N'
                                AND  enabled_flag = 'Y'),
                 dataset_display_code = (SELECT dataset_display_code
                                         FROM   fem_datasets_b fdb
                                         WHERE  idt.dataset_code = fdb.dataset_code
                                           AND  personal_flag = 'N'
                                           AND  enabled_flag = 'Y'),
                 (dimension_group_id,time_dimension_group_key) = (SELECT dimension_group_id, time_dimension_group_key
                                                                  FROM   fem_dimension_grps_b fdgb
                                                                  WHERE  idt.cal_period_level =
                                                                         fdgb.dimension_group_display_code
                                                                    AND  fdgb.personal_flag = 'N'
                                                                    AND  fdgb.enabled_flag = 'Y');

          fem_engines_pkg.tech_message(p_severity => g_log_level_1
                                      ,p_module   => g_block||'.evaluate_parameters'
                                      ,p_msg_text => ' Rows updated after ID population(LEDGER LOAD) :: ' ||  SQL%ROWCOUNT);

          fnd_file.put_line(fnd_file.log, ' Rows updated after ID population :: ' ||  SQL%ROWCOUNT);

     END IF; -- g_loader_type = 'LEDGER'

     IF SQL%ROWCOUNT > 0 THEN
        g_loader_run := TRUE;
     ELSE
        g_loader_run := FALSE;  -- No data found in the interface; no point in proceeding beyond this
     END IF;

     IF g_loader_run THEN

     -- Validate the rule; if NOT APPROVED then need to run the loaders
     -- ONLY against the non-production datasets

     -- If the rule is approved, can run against any dataset
     -- Else cannot run against the production datasets

        IF g_approval_flag THEN
           UPDATE  fem_ld_interface_data_gt
           SET     ds_production_valid_flag = 'Y';
        ELSE
           UPDATE  fem_ld_interface_data_gt idt
           SET     ds_production_valid_flag = (SELECT DECODE(dim_attribute_varchar_member,'Y','N','Y')
                                               FROM   fem_datasets_attr fda
                                               WHERE  fda.attribute_id = g_production_attr
                                                 AND  idt.dataset_code = fda.dataset_code);
        END IF;  -- g_approval_flag

        FOR int_rec IN (SELECT ledger_id, dataset_code, ds_production_valid_flag, table_name, table_row
                        FROM   fem_ld_interface_data_gt
                        ORDER BY table_row, table_name)
        LOOP
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');
            fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters(1)                 ');
            fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || int_rec.table_name);
            fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || int_rec.table_row);
            fnd_file.put_line(FND_FILE.log, ' Ledger     :: ' || int_rec.ledger_id);
            fnd_file.put_line(FND_FILE.log, ' Dataset    :: ' || int_rec.dataset_code);
            fnd_file.put_line(FND_FILE.log, ' ds valid   :: ' || int_rec.ds_production_valid_flag);
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');

          fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                       ,p_module   => g_block||'.evaluate_parameters(1)'
                                       ,p_msg_text => ' Table Name :: ' || int_rec.table_name ||
                                                      ' Table Row  :: ' || int_rec.table_row ||
                                                      ' Ledger     :: ' || int_rec.ledger_id ||
                                                      ' Dataset    :: ' || int_rec.dataset_code ||
                                                      ' ds valid   :: ' || int_rec.ds_production_valid_flag);

        END LOOP;

        FOR i IN 1..gs_table_name_tab.COUNT LOOP
            IF gs_valid_rows(i) > 0.0 THEN
               IF g_loader_type = 'CLIENT' THEN
                  UPDATE fem_ld_interface_data_gt
                  SET    status = 'VALID'
                  WHERE  ledger_id = DECODE(gs_ledger_tab(i),-1,ledger_id,gs_ledger_tab(i))
                    AND  dataset_code =  DECODE(gs_ds_tab(i),-1,dataset_code,gs_ds_tab(i))
                    AND  source_system_code = DECODE(gs_ss_tab(i),-1,source_system_code,gs_ss_tab(i))
                    AND  dimension_group_id = DECODE(gs_cal_grp_tab(i),-1,dimension_group_id,gs_cal_grp_tab(i))
                    AND  ds_production_valid_flag = 'Y'
                    AND  table_row = gs_table_row_tab(i)
                    AND  table_name = gs_table_name_tab(i);
               ELSIF g_loader_type = 'LEDGER' AND gs_valid_rows(i) > 0.0 THEN
                  UPDATE fem_ld_interface_data_gt
                  SET    status = 'VALID'
                  WHERE  ledger_id = DECODE(gs_ledger_tab(i),-1,ledger_id,gs_ledger_tab(i))
                    AND  dimension_group_id = DECODE(gs_cal_grp_tab(i),-1,dimension_group_id,gs_cal_grp_tab(i))
                    AND  ds_production_valid_flag = 'Y'
                    AND  table_row = gs_table_row_tab(i)
                    AND  table_name = gs_table_name_tab(i);
               END IF;

               IF SQL%ROWCOUNT > 0 THEN
                  gs_valid_rows(i) := SQL%ROWCOUNT;
                  g_evaluate_parameters := TRUE;
               ELSE
                  gs_valid_rows(i) := 0.0;
               END IF;

               SELECT COUNT(*)
                INTO  l_dummy
               FROM   fem_ld_interface_data_gt
               WHERE  table_name = gs_table_name_tab(i)
                 AND  table_row = gs_table_row_tab(i);

             -- The update stmt needs to be changed as there is a direct mention of
             -- fla.dim_attribute_numeric_member w/o querying the metadata.

               fnd_file.put_line(FND_FILE.log, ' ==========================================================');
               fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters                    ');
               fnd_file.put_line(FND_FILE.log, ' After update ' || gs_table_name_tab(i) || ' COUNT(*) = ' || l_dummy);
               fnd_file.put_line(FND_FILE.log, ' After update ' || gs_table_name_tab(i) || ' Valid    = ' || gs_valid_rows(i));
               fnd_file.put_line(FND_FILE.log, ' ==========================================================');

               fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                            ,p_module   => g_block||'.evaluate_parameters(1.1)'
                                            ,p_msg_text => ' TABLE :: ' || gs_table_name_tab(i) ||
                                                           ' ROW   :: ' || gs_table_row_tab(i) ||
                                                           ' COUNT :: ' || l_dummy ||
                                                           ' VALID :: ' || gs_valid_rows(i));


            ELSE
               fnd_file.put_line(FND_FILE.log, ' ==========================================================');
               fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters                    ');
               fnd_file.put_line(FND_FILE.log, ' No valid rows exists for ' || gs_table_name_tab(i));
               fnd_file.put_line(FND_FILE.log, ' ==========================================================');

               fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                            ,p_module   => g_block||'.evaluate_parameters(1.1)'
                                            ,p_msg_text => ' No valid rows exists for ' || gs_table_name_tab(i));

            END IF; -- gs_valid_rows(i) > 0.0


        END LOOP;

        FOR int_rec IN (SELECT ledger_id, dataset_code, ds_production_valid_flag, table_name, table_row, status
                        FROM   fem_ld_interface_data_gt
                        ORDER BY table_row, table_name)
        LOOP
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');
            fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters(2)                 ');
            fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || int_rec.table_name);
            fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || int_rec.table_row);
            fnd_file.put_line(FND_FILE.log, ' Ledger     :: ' || int_rec.ledger_id);
            fnd_file.put_line(FND_FILE.log, ' Dataset    :: ' || int_rec.dataset_code);
            fnd_file.put_line(FND_FILE.log, ' ds valid   :: ' || int_rec.ds_production_valid_flag);
            fnd_file.put_line(FND_FILE.log, ' Status     :: ' || int_rec.status);
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');

          fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                       ,p_module   => g_block||'.evaluate_parameters(2)'
                                       ,p_msg_text => ' Table Name :: ' || int_rec.table_name ||
                                                      ' Table Row  :: ' || int_rec.table_row ||
                                                      ' Ledger     :: ' || int_rec.ledger_id ||
                                                      ' Dataset    :: ' || int_rec.dataset_code ||
                                                      ' ds valid   :: ' || int_rec.ds_production_valid_flag ||
                                                      ' Status     :: ' || int_rec.status);

        END LOOP;

        -- The deleted records will be used to print the exception report

        DELETE fem_ld_interface_data_gt
        WHERE  status <> 'VALID'
        RETURNING ledger_display_code,
                  dataset_display_code,
                  source_system_display_code,
                  ds_production_valid_flag,
                  table_name,
                  table_row
        BULK COLLECT INTO g_inv_ledger,
                          g_inv_dataset,
                          g_inv_source_system,
                          g_inv_ds_pd_flag,
                          g_inv_table_name,
                          g_inv_table_row;

        IF g_loader_type = 'LEDGER' THEN

           SELECT COUNT(*)
           INTO   l_dummy
           FROM   fem_ld_interface_data_gt
           WHERE  budget_display_code IS NOT NULL;

           IF l_dummy > 0.0 THEN
              UPDATE  fem_ld_interface_data_gt idt
              SET     budget_id = (SELECT budget_id
                                   FROM   fem_budgets_b fdb
                                   WHERE  idt.budget_display_code = fdb.budget_display_code
                                     AND  personal_flag = 'N'
                                     AND  enabled_flag = 'Y')
              WHERE   budget_display_code IS NOT NULL;
           END IF;

           SELECT COUNT(*)
           INTO   l_dummy
           FROM   fem_ld_interface_data_gt
           WHERE  encumbrance_type_code IS NOT NULL;

           IF l_dummy > 0.0 THEN
              UPDATE  fem_ld_interface_data_gt idt
              SET     encumbrance_type_id = (SELECT encumbrance_type_id
                                             FROM   fem_encumbrance_types_b fetb
                                             WHERE  fetb.enabled_flag  = 'Y'
                                               AND  fetb.personal_flag = 'N'
                                               AND  idt.encumbrance_type_code = fetb.encumbrance_type_code)
              WHERE   encumbrance_type_code IS NOT NULL;
           END IF;

       END IF;  -- g_loader_type = 'LEDGER' AND g_loader_run

      UPDATE fem_ld_interface_data_gt idt
      SET    calendar_id = (SELECT calendar_id
                            FROM   fem_hierarchies fh,
                                   fem_object_definition_b fodb,
                                   fem_ledgers_attr fla
                            WHERE  fh.hierarchy_obj_id = fodb.object_id
                              AND  fodb.object_definition_id = fla.dim_attribute_numeric_member
                              AND  fla.ledger_id = idt.ledger_id
                              AND  fla.attribute_id =  g_cal_period_hier_attr
                              AND  fh.dimension_id = g_cal_period_dim_id);

      UPDATE fem_ld_interface_data_gt idt
      SET    cal_period = TO_CHAR(idt.cal_period_end_date,'J') ||
                          LPAD(TO_CHAR(idt.cal_period_number),15,'0') ||
                          LPAD(TO_CHAR(idt.calendar_id),5,'0') ||
                          LPAD(TO_CHAR(idt.time_dimension_group_key),5,'0');

      FOR z IN 1..g_inv_table_name.COUNT LOOP
             fnd_file.put_line(FND_FILE.log, ' ==========================================================');
             fnd_file.put_line(FND_FILE.log, '                 In Evaluate parameters(Invalid section)   ');
             fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || g_inv_table_name(z));
             fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || g_inv_table_row(z));
             fnd_file.put_line(FND_FILE.log, ' Ledger     :: ' || g_inv_ledger(z));
             fnd_file.put_line(FND_FILE.log, ' Dataset    :: ' || g_inv_dataset(z));
             fnd_file.put_line(FND_FILE.log, ' Production :: ' || g_inv_ds_pd_flag(z));
             fnd_file.put_line(FND_FILE.log, ' ==========================================================');

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.evaluate_parameters(Invalid section)'
                                      ,p_msg_text => ' Table Name :: ' || g_inv_table_name(z) ||
                                                     ' Table Row  :: ' || g_inv_table_row(z)  ||
                                                     ' Ledger     :: ' || g_inv_ledger(z)     ||
                                                     ' Dataset    :: ' || g_inv_dataset(z)    ||
                                                     ' Production :: ' || g_inv_ds_pd_flag(z));

      END LOOP;

     END IF; -- g_loader_run (second occurence)

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.evaluate_parameters(PROCEDURE)'
                                  ,p_msg_text => 'END evaluate_parameters');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.evaluate_parameters(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in evaluate_parameters ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - evaluate_params ' || sqlerrm);
      RAISE;

  END evaluate_parameters;

  ---------------------------
  -- END evaluate_parameters
  ---------------------------

  --------------------------------------------------------------------------------
  --
  -- This is second core procedure. This queries all the VALID cal_periods to be
  -- used while issuing the DATA/LEDGER load CP
  --
  -- Approach is as follows ..
  --
  -- 1. Operates only on the table and table row whose gs_valid_rows > 0
  -- 2. Has 4 loops to handle
  --    a. LEDGER = ALL,      LEVEL = ALL
  --    b. LEDGER = ALL,      LEVEL = specific
  --    c. LEDGER = specific, LEVEL = specific
  --    d. LEDGER = specific, LEVEL = ALL
  -- 3. If there are no records that match the ledger/level combination the INSERT
  --    gs_valid_rows is updated to -3.0 for use in reporting
  -- 4. Finally, if there are no records in fem_ld_cal_periods_gt there is no point in
  --    proceeding. Signals the g_evaluate_parameters to FALSE
  --
  --------------------------------------------------------------------------------


  PROCEDURE populate_cal_periods IS
     l_dummy   NUMBER;
     l_dummy1  NUMBER;

  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_cal_periods(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for populate_cal_periods');

     FOR i IN 1..gs_ledger_tab.COUNT LOOP

        IF gs_ledger_tab(i) <> - 1 AND gs_cal_grp_tab(i) <> -1 AND gs_valid_rows(i) > 0.0 THEN

              INSERT INTO fem_ld_cal_periods_gt(table_name, table_row, ledger_id, cal_period_id, dim_grp_id, valid)
              SELECT gs_table_name_tab(i), gs_table_row_tab(i), gs_ledger_tab(i), fcpb.cal_period_id,
                     fcpb.dimension_group_id, 'VALID'
              FROM   fem_calendars_b fcb,
                     fem_dimension_grps_b fdgb,
                     fem_cal_periods_b fcpb
              WHERE  fcpb.calendar_id = fcb.calendar_id
                AND  fcpb.dimension_group_id = fdgb.dimension_group_id
                AND  EXISTS ( SELECT 1
                              FROM   fem_ld_interface_data_gt idt
                              WHERE  fdgb.dimension_group_id = idt.dimension_group_id
                                AND  idt.ledger_id = gs_ledger_tab(i)
                                AND  idt.dimension_group_id = gs_cal_grp_tab(i)
                                AND  fcb.calendar_id = idt.calendar_id
                                AND  fcpb.cal_period_id =  idt.cal_period
                                AND  table_name = gs_table_name_tab(i)
                                AND  table_row = gs_table_row_tab(i)  )
                AND  EXISTS ( SELECT 1
                              FROM   fem_cal_periods_attr a,
                                     fem_cal_periods_attr b
                              WHERE  a.attribute_id = g_start_date_attr
                                AND  b.attribute_id = g_end_date_attr
                                AND  a.cal_period_id = fcpb.cal_period_id
                                AND  a.cal_period_id = b.cal_period_id
                                AND  fnd_date.date_to_canonical(a.date_assign_value) >= g_start_date
                                AND  fnd_date.date_to_canonical(b.date_assign_value) <= g_end_date );

        ELSIF gs_ledger_tab(i) <> - 1 AND gs_cal_grp_tab(i) = -1 AND gs_valid_rows(i) > 0.0 THEN

              INSERT INTO fem_ld_cal_periods_gt(table_name, table_row, ledger_id, cal_period_id, dim_grp_id, valid)
              SELECT gs_table_name_tab(i), gs_table_row_tab(i), gs_ledger_tab(i), fcpb.cal_period_id,
                     fcpb.dimension_group_id, 'VALID'
              FROM   fem_calendars_b fcb,
                     fem_dimension_grps_b fdgb,
                     fem_cal_periods_b fcpb
              WHERE  fcpb.calendar_id = fcb.calendar_id
                AND  fcpb.dimension_group_id = fdgb.dimension_group_id
                AND  EXISTS ( SELECT 1
                              FROM   fem_ld_interface_data_gt idt
                              WHERE  fdgb.dimension_group_id = idt.dimension_group_id
                                AND  idt.ledger_id = gs_ledger_tab(i)
                                AND  fcb.calendar_id = idt.calendar_id
                                AND  fcpb.cal_period_id =  idt.cal_period
                                AND  table_name = gs_table_name_tab(i)
                                AND  table_row = gs_table_row_tab(i)  )
                AND  EXISTS ( SELECT 1
                              FROM   fem_cal_periods_attr a,
                                     fem_cal_periods_attr b
                              WHERE  a.attribute_id = g_start_date_attr
                                AND  b.attribute_id = g_end_date_attr
                                AND  a.cal_period_id = fcpb.cal_period_id
                                AND  a.cal_period_id = b.cal_period_id
                                AND  fnd_date.date_to_canonical(a.date_assign_value) >= g_start_date
                                AND  fnd_date.date_to_canonical(b.date_assign_value) <= g_end_date );

        ELSIF gs_ledger_tab(i) = - 1 AND gs_cal_grp_tab(i) = -1 AND gs_valid_rows(i) > 0.0 THEN

              INSERT INTO fem_ld_cal_periods_gt(table_name, table_row, ledger_id, cal_period_id, dim_grp_id, valid)
              SELECT gs_table_name_tab(i), gs_table_row_tab(i), idt.ledger_id, fcpb.cal_period_id,
                     fcpb.dimension_group_id, 'VALID'
              FROM   fem_calendars_b fcb,
                     fem_dimension_grps_b fdgb,
                     fem_cal_periods_b fcpb,
                     (SELECT DISTINCT ledger_id,
                                      dimension_group_id,
                                      calendar_id,
                                      cal_period
                      FROM   fem_ld_interface_data_gt
                      WHERE  table_name = gs_table_name_tab(i)
                        AND  table_row = gs_table_row_tab(i)) idt
              WHERE  fcpb.calendar_id = fcb.calendar_id
                AND  fcpb.dimension_group_id = fdgb.dimension_group_id
                AND  fdgb.dimension_group_id = idt.dimension_group_id
                AND  fcb.calendar_id = idt.calendar_id
                AND  fcpb.cal_period_id =  idt.cal_period
                AND  EXISTS ( SELECT 1
                              FROM   fem_cal_periods_attr a,
                                     fem_cal_periods_attr b
                              WHERE  a.attribute_id = g_start_date_attr
                                AND  b.attribute_id = g_end_date_attr
                                AND  a.cal_period_id = fcpb.cal_period_id
                                AND  a.cal_period_id = b.cal_period_id
                                AND  fnd_date.date_to_canonical(a.date_assign_value) >= g_start_date
                                AND  fnd_date.date_to_canonical(b.date_assign_value) <= g_end_date );

        ELSIF gs_ledger_tab(i) = - 1 AND gs_cal_grp_tab(i) <> -1 AND gs_valid_rows(i) > 0.0 THEN

              INSERT INTO fem_ld_cal_periods_gt(table_name, table_row, ledger_id, cal_period_id, dim_grp_id, valid)
              SELECT gs_table_name_tab(i), gs_table_row_tab(i), idt.ledger_id, fcpb.cal_period_id,
                     fcpb.dimension_group_id, 'VALID'
              FROM   fem_calendars_b fcb,
                     fem_dimension_grps_b fdgb,
                     fem_cal_periods_b fcpb,
                     (SELECT DISTINCT ledger_id,
                                      calendar_id,
                                      cal_period
                      FROM   fem_ld_interface_data_gt
                      WHERE  table_name = gs_table_name_tab(i)
                        AND  table_row = gs_table_row_tab(i)
                        AND  dimension_group_id = gs_cal_grp_tab(i)) idt
              WHERE  fcpb.calendar_id = fcb.calendar_id
                AND  fcpb.dimension_group_id = fdgb.dimension_group_id
                AND  fdgb.dimension_group_id = gs_cal_grp_tab(i)
                AND  fcb.calendar_id = idt.calendar_id
                AND  fcpb.cal_period_id =  idt.cal_period
                AND  EXISTS ( SELECT 1
                              FROM   fem_cal_periods_attr a,
                                     fem_cal_periods_attr b
                              WHERE  a.attribute_id = g_start_date_attr
                                AND  b.attribute_id = g_end_date_attr
                                AND  a.cal_period_id = fcpb.cal_period_id
                                AND  a.cal_period_id = b.cal_period_id
                                AND  fnd_date.date_to_canonical(a.date_assign_value) >= g_start_date
                                AND  fnd_date.date_to_canonical(b.date_assign_value) <= g_end_date );

        END IF;

        IF SQL%ROWCOUNT = 0.0 THEN
           gs_valid_rows(i) := -3.0;
        END IF;

     END LOOP;

     FOR cal_rec IN (SELECT ledger_id, table_name, table_row, cal_period_id, valid
                     FROM   fem_ld_cal_periods_gt)
     LOOP
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');
            fnd_file.put_line(FND_FILE.log, '                 In populate cal periods                   ');
            fnd_file.put_line(FND_FILE.log, ' Ledger     :: ' || cal_rec.ledger_id);
            fnd_file.put_line(FND_FILE.log, ' Cal Period :: ' || cal_rec.cal_period_id);
            fnd_file.put_line(FND_FILE.log, ' Table Name :: ' || cal_rec.table_name);
            fnd_file.put_line(FND_FILE.log, ' Table Row  :: ' || cal_rec.table_row);
            fnd_file.put_line(FND_FILE.log, ' Valid      :: ' || cal_rec.valid);
            fnd_file.put_line(FND_FILE.log, ' ==========================================================');

         fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                      ,p_module   => g_block||'.populate_cal_periods'
                                      ,p_msg_text => ' Table Name :: ' || cal_rec.table_name ||
                                                     ' Table Row  :: ' || cal_rec.table_row  ||
                                                     ' Ledger     :: ' || cal_rec.ledger_id   ||
                                                     ' Cal Period :: ' || cal_rec.cal_period_id ||
                                                     ' Valid      :: ' || cal_rec.valid);
     END LOOP;

     SELECT COUNT(1)
     INTO   l_dummy1
     FROM   fem_ld_cal_periods_gt
     WHERE  ROWNUM = 1;

     IF l_dummy1 = 0.0 THEN
        g_evaluate_parameters := FALSE;
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.populate_cal_periods'
                                     ,p_msg_text => ' No valid CAL PERIODS');
        fnd_file.put_line(FND_FILE.log, ' No valid cal Periods');
     ELSE
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.populate_cal_periods'
                                     ,p_msg_text => 'Some valid CAL PERIODS exist');
     END IF;  -- l_dummy = 0.0

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_cal_periods(PROCEDURE)'
                                  ,p_msg_text => 'END populate_cal_periods');


  EXCEPTION
    WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.populate_cal_periods(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in populate_cal_periods ' || sqlerrm);
       fnd_file.put_line(fnd_file.log, 'Exception - populate_cal_periods ' || sqlerrm);
       RAISE;

  END populate_cal_periods;

  ---------------------------
  -- END populate_cal_periods
  ---------------------------

  --------------------------------------------------------------------------------
  --
  -- This populates the g_master_rec used for submitting the LEDGER load CP
  --
  --------------------------------------------------------------------------------


  PROCEDURE populate_master_table_lldr IS
     indx    PLS_INTEGER;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_master_table_lldr(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for populate_master_table_lldr');


     indx := 1.0;

     FOR i IN 1..gs_valid_rows.COUNT LOOP
         IF gs_valid_rows(i) > 0.0 THEN

            BEGIN

              SELECT DISTINCT idt.ledger_id, cal_period_id, dataset_code,
                              budget_id, encumbrance_type_id,
                              idt.ledger_display_code, idt.dataset_display_code,
                              idt.encumbrance_type_code, idt.budget_display_code
               BULK COLLECT INTO g_ledger_id, g_cal_period_id, g_ds_code,
                              g_budget_id, g_enc_type_id,
                              gs_ledger_code_tab, gs_ds_code_tab, gs_budget_code_tab,
                              gs_enc_code_tab
              FROM   fem_ld_interface_data_gt idt,
                     fem_ld_cal_periods_gt cpt
              WHERE  idt.table_name = gs_table_name_tab(i)
                AND  idt.table_row = gs_table_row_tab(i)
                AND  idt.table_name = cpt.table_name
                AND  idt.table_row = cpt.table_row
                AND  idt.ledger_id = cpt.ledger_id;

            EXCEPTION
              WHEN OTHERS THEN
                  gs_valid_rows(i) := 0.0;
            END;

            IF g_ledger_id.COUNT > 0.0 THEN

               FOR master_rec_rows IN 1..g_ledger_id.COUNT LOOP
                   g_master_rec(indx).table_name := gs_table_name_tab(i);
                   g_master_rec(indx).table_row := gs_table_row_tab(i);
                   g_master_rec(indx).request_id := 0.0;
                   g_master_rec(indx).status := 'N';
                   g_master_rec(indx).ledger_id := g_ledger_id(master_rec_rows);
                   g_master_rec(indx).cal_period_id := g_cal_period_id(master_rec_rows);
                   g_master_rec(indx).dataset_code := g_ds_code(master_rec_rows);
                   g_master_rec(indx).budget_id := g_budget_id(master_rec_rows);
                   g_master_rec(indx).enc_type_id := g_enc_type_id(master_rec_rows);
                   g_master_rec(indx).ledger_display_code := gs_ledger_code_tab(master_rec_rows);
                   g_master_rec(indx).dataset_display_code := gs_ds_code_tab(master_rec_rows);
                   g_master_rec(indx).budget_display_code := gs_budget_code_tab(master_rec_rows);
                   g_master_rec(indx).enc_type_code := gs_enc_code_tab(master_rec_rows);

                   indx := indx + 1.0;
               END LOOP; -- master_rec_rows

            END IF; -- g_ledger_id.COUNT > 0.0

         END IF; -- gs_valid_rows(i) = 0

     END LOOP; -- gs_valid_rows.COUNT

     FOR j IN 1..g_master_rec.COUNT LOOP

       fnd_file.put_line(fnd_file.log, '=================================================================');
       fnd_file.put_line(fnd_file.log, '===================== MASTER INDEX TABLE ========================');
       fnd_file.put_line(fnd_file.log, 'Table Name       :: ' || g_master_rec(j).table_name);
       fnd_file.put_line(fnd_file.log, 'Table Row        :: ' || g_master_rec(j).table_row);
       fnd_file.put_line(fnd_file.log, 'Ledger ID        :: ' || g_master_rec(j).ledger_id);
       fnd_file.put_line(fnd_file.log, 'Cal Period       :: ' || g_master_rec(j).cal_period_id);
       fnd_file.put_line(fnd_file.log, 'Dataset Code     :: ' || g_master_rec(j).dataset_code);
       fnd_file.put_line(fnd_file.log, 'Budget ID        :: ' || g_master_rec(j).budget_id);
       fnd_file.put_line(fnd_file.log, 'Enc Type ID      :: ' || g_master_rec(j).enc_type_id);
       fnd_file.put_line(fnd_file.log, '=================================================================');

       fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                    ,p_module   => g_block||'.populate_master_table_lldr(MASTER INDEX TABLE)'
                                    ,p_msg_text => ' Table Name       :: ' || g_master_rec(j).table_name ||
                                                   ' Table Row        :: ' || g_master_rec(j).table_row  ||
                                                   ' Ledger ID        :: ' || g_master_rec(j).ledger_id   ||
                                                   ' Cal Period       :: ' || g_master_rec(j).cal_period_id  ||
                                                   ' Dataset Code     :: ' || g_master_rec(j).dataset_code ||
                                                   ' Budget ID        :: ' || g_master_rec(j).budget_id ||
                                                   ' Enc Type ID      :: ' || g_master_rec(j).enc_type_id);

     END LOOP;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_master_table_lldr(PROCEDURE)'
                                  ,p_msg_text => 'END populate_master_table_lldr');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.populate_master_table_lldr(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in populate_master_table_lldr ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - populate_master_table_lldr ' || sqlerrm);
      RAISE;

  END populate_master_table_lldr;

  ---------------------------------
  -- END populate_master_table_lldr
  ---------------------------------

  --------------------------------------------------------------------------------
  --
  -- This populates the g_master_rec used for submitting the DATA load CP
  --
  --------------------------------------------------------------------------------

  PROCEDURE populate_master_table_dldr IS
     indx    PLS_INTEGER;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_master_table_dldr(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for populate_master_table_dldr');

     indx := 1.0;

     FOR i IN 1..gs_valid_rows.COUNT LOOP
         IF gs_valid_rows(i) > 0.0 THEN

            BEGIN

              SELECT DISTINCT idt.ledger_id, cal_period_id, source_system_code, dataset_code,
                              idt.ledger_display_code, idt.dataset_display_code,
                              idt.source_system_display_code
               BULK COLLECT INTO g_ledger_id, g_cal_period_id, g_ss_code, g_ds_code,
                                 gs_ledger_code_tab, gs_ds_code_tab, gs_ss_code_tab
              FROM   fem_ld_interface_data_gt idt,
                     fem_ld_cal_periods_gt cpt
              WHERE  idt.table_name = gs_table_name_tab(i)
                AND  idt.table_row = gs_table_row_tab(i)
                AND  idt.table_name = cpt.table_name
                AND  idt.table_row = cpt.table_row
                AND  idt.ledger_id = cpt.ledger_id;

            EXCEPTION
              WHEN OTHERS THEN
                  gs_valid_rows(i) := 0.0;
            END;

            IF g_ledger_id.COUNT > 0.0 THEN

               FOR master_rec_rows IN 1..g_ledger_id.COUNT LOOP
                   g_master_rec(indx).table_name := gs_table_name_tab(i);
                   g_master_rec(indx).table_row := gs_table_row_tab(i);
                   g_master_rec(indx).ledger_id := g_ledger_id(master_rec_rows);
                   g_master_rec(indx).cal_period_id := g_cal_period_id(master_rec_rows);
                   g_master_rec(indx).dataset_code := g_ds_code(master_rec_rows);
                   g_master_rec(indx).source_system_code := g_ss_code(master_rec_rows);
                   g_master_rec(indx).request_id := 0;
                   g_master_rec(indx).status := 'N';
                   g_master_rec(indx).ledger_display_code := gs_ledger_code_tab(master_rec_rows);
                   g_master_rec(indx).dataset_display_code := gs_ds_code_tab(master_rec_rows);
                   g_master_rec(indx).source_system_display_code := gs_ss_code_tab(master_rec_rows);

                   indx := indx + 1.0;

               END LOOP; -- l_cal_period_rows

            END IF; -- g_ledger_id.COUNT > 0.0

         END IF; -- gs_valid_rows(i) = 0

     END LOOP; -- gs_valid_rows.COUNT

     FOR j IN 1..g_master_rec.COUNT LOOP

       fnd_file.put_line(fnd_file.log, '=================================================================');
       fnd_file.put_line(fnd_file.log, '===================== MASTER INDEX TABLE ========================');
       fnd_file.put_line(fnd_file.log, 'Table Name       :: ' || g_master_rec(j).table_name);
       fnd_file.put_line(fnd_file.log, 'Table Row        :: ' || g_master_rec(j).table_row);
       fnd_file.put_line(fnd_file.log, 'Ledger ID        :: ' || g_master_rec(j).ledger_id);
       fnd_file.put_line(fnd_file.log, 'Cal Period       :: ' || g_master_rec(j).cal_period_id);
       fnd_file.put_line(fnd_file.log, 'Dataset Code     :: ' || g_master_rec(j).dataset_code);
       fnd_file.put_line(fnd_file.log, 'Source System    :: ' || g_master_rec(j).source_system_code);
       fnd_file.put_line(fnd_file.log, '=================================================================');

       fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                    ,p_module   => g_block||'.populate_master_table_dldr(MASTER INDEX TABLE)'
                                    ,p_msg_text => ' Table Name       :: ' || g_master_rec(j).table_name ||
                                                   ' Table Row        :: ' || g_master_rec(j).table_row  ||
                                                   ' Ledger ID        :: ' || g_master_rec(j).ledger_id   ||
                                                   ' Cal Period       :: ' || g_master_rec(j).cal_period_id  ||
                                                   ' Dataset Code     :: ' || g_master_rec(j).dataset_code ||
                                                   ' Source System    :: ' || g_master_rec(j).source_system_code);

     END LOOP;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_master_table_dldr(PROCEDURE)'
                                  ,p_msg_text => 'END populate_master_table_dldr');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.populate_master_table_dldr(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in populate_master_table_dldr ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'Exception - populate_master_table_dldr ' || sqlerrm);
      RAISE;

  END populate_master_table_dldr;

  ---------------------------------
  -- END populate_master_table_dldr
  ---------------------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used for printing the outcome of dimension loader CP
  --
  --------------------------------------------------------------------------------


  PROCEDURE log_dimensions(p_table_name IN VARCHAR2) IS
    l_status        VARCHAR2(200);
    l_phase         VARCHAR2(200);
    l_request_id    NUMBER;
    l_table_name    VARCHAR2(30);
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for log_dimensions(' || p_table_name || ')');

     FOR dim_rec IN ( SELECT dimension_id,
                             dimension_varchar_label,
                             table_name,
                             request_id,
                             status
                      FROM   fem_ld_dim_requests_gt drt
                      WHERE  table_name = p_table_name )
     LOOP
        IF l_table_name IS NULL THEN
           l_table_name := dim_rec.table_name;
           fnd_message.set_name('FEM','FEM_DLLDR_LOAD_DIM_MSG');
           fnd_message.set_token('TABLE_NAME',l_table_name);
           trace('SEPARATOR');
           trace('MESSAGE');
        ELSE
           IF l_table_name <> dim_rec.table_name THEN
              l_table_name := dim_rec.table_name;
              fnd_message.set_name('FEM','FEM_DLLDR_LOAD_DIM_MSG');
              fnd_message.set_token('TABLE_NAME',l_table_name);
              trace('SEPARATOR');
              trace('MESSAGE');
           END IF;
        END IF;

        IF dim_rec.request_id > 0 THEN
           IF dim_rec.status = 'Y' THEN
              fnd_message.set_name('FEM','FEM_DLLDR_DIMENSION_LOADED');
              fnd_message.set_token('REQUEST_ID',dim_rec.request_id);
              fnd_message.set_token('DIM_LABEL',dim_rec.dimension_varchar_label);
           ELSE
              fnd_message.set_name('FEM','FEM_DLLDR_DIMENSION_ERR');
              fnd_message.set_token('REQUEST_ID',dim_rec.request_id);
              fnd_message.set_token('DIM_LABEL',dim_rec.dimension_varchar_label);
           END IF;
        ELSIF dim_rec.request_id < 0 THEN
            fnd_message.set_name('FEM', 'FEM_DLLDR_DIMENSION_NO_DATA');
            fnd_message.set_token('DIM_LABEL',dim_rec.dimension_varchar_label);
        ELSE
            fnd_message.set_name('FEM', 'FEM_DLLDR_DIM_CONC_PGM_ERR');
            fnd_message.set_token('DIM_LABEL',dim_rec.dimension_varchar_label);
        END IF;

        trace('MESSAGE');

     END LOOP; -- dim_rec

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                  ,p_msg_text => 'END log_dimensions(' || p_table_name || ')');

   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in log_dimensions(' || p_table_name || ') - ' || sqlerrm);
       fnd_file.put_line(fnd_file.log, 'Exception - log_dimensions ' || sqlerrm);
       RAISE;

  END log_dimensions;

  ---------------------
  -- END log_dimensions
  ---------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used for printing the outcome of hierarchy loader CP
  --
  --------------------------------------------------------------------------------


  PROCEDURE log_hierarchies(p_table_name IN VARCHAR2) IS
    l_status        VARCHAR2(200);
    l_phase         VARCHAR2(200);
    l_request_id    NUMBER;
    l_table_name    VARCHAR2(30);
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for log_hierarchies');

     FOR hier_rec IN (SELECT dimension_varchar_label,
                             hierarchy_object_name,
                             hier_obj_def_display_name,
                             table_name,
                             request_id,
                             status
                      FROM   fem_ld_hier_requests_gt
                      WHERE  table_name = p_table_name )
     LOOP
        IF l_table_name IS NULL THEN
           l_table_name := hier_rec.table_name;
           fnd_message.set_name('FEM','FEM_DLLDR_LOAD_HIER_MSG');
           fnd_message.set_token('TABLE_NAME',l_table_name);
           trace('SEPARATOR');
           trace('MESSAGE');
        ELSE
           IF l_table_name <> hier_rec.table_name THEN
              l_table_name := hier_rec.table_name;
              fnd_message.set_name('FEM','FEM_DLLDR_LOAD_HIER_MSG');
              fnd_message.set_token('TABLE_NAME',l_table_name);
              trace('SEPARATOR');
              trace('MESSAGE');
           END IF;
        END IF;

        IF hier_rec.request_id > 0 THEN
           IF hier_rec.status = 'Y' THEN
              fnd_message.set_name('FEM','FEM_DLLDR_HIERARCHY_LOADED');
              fnd_message.set_token('REQUEST_ID',hier_rec.request_id);
              fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' || hier_rec.hier_obj_def_display_name);
           ELSE
              fnd_message.set_name('FEM','FEM_DLLDR_HIERARCHY_ERR');
              fnd_message.set_token('REQUEST_ID',hier_rec.request_id);
              fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' || hier_rec.hier_obj_def_display_name);
              fnd_message.set_token('DIM_LABEL',hier_rec.dimension_varchar_label);
           END IF;
        ELSE
            fnd_message.set_name('FEM', 'FEM_DLLDR_HIER_CONC_PGM_ERR');
            fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' || hier_rec.hier_obj_def_display_name);
        END IF;

        trace('MESSAGE');

     END LOOP;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                  ,p_msg_text => 'END log_hierarchies');


   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in log_hierarchies ' || sqlerrm);
       fnd_file.put_line(fnd_file.log, 'Exception - log_hierarchies ' || sqlerrm);
       RAISE;

  END log_hierarchies;
  ----------------------
  -- END log_hierarchies
  ----------------------


  --------------------------------------------------------------------------------
  --
  -- This procedure is used for printing the outcome of DATA/LEDGER load CP
  --
  --------------------------------------------------------------------------------


  PROCEDURE log_fact_table(p_table_name IN VARCHAR2,
                           p_table_row  IN NUMBER)
  IS
    l_start                        NUMBER;
    l_end                          NUMBER;

    l_msg_count                    NUMBER;
    l_exception_code               VARCHAR2(50);
    l_msg_data                     VARCHAR2(200);
    l_return_status                VARCHAR2(50);

    e_process_single_rule_error    EXCEPTION;
  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.log_fact_table(PROCEDURE)'
                                 ,p_msg_text => 'BEGIN..for log_fact_table(' || p_table_name || ',' || p_table_row || ')');

    l_start := NULL;
    l_end := NULL;

     FOR j IN 1..g_master_rec.COUNT LOOP
       IF g_master_rec(j).table_row = p_table_row THEN
          IF l_start IS NULL THEN
             l_start := j;
          END IF;
          l_end := j;
       END IF;

       EXIT WHEN  g_master_rec(j).table_row <> p_table_row AND l_start IS NOT NULL;
     END LOOP;

     FOR i IN l_start..l_end LOOP

        IF g_master_rec(i).request_id > 0 THEN
           IF g_master_rec(i).status = 'Y' THEN
              IF g_loader_type = 'CLIENT' THEN
                 fnd_message.set_name('FEM', 'FEM_DLLDR_DATA_LOADER_COMPLETE');
                 fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                 fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                 fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                 fnd_message.set_token('SOURCE_SYSTEM_CODE', g_master_rec(i).source_system_display_code);
                 fnd_message.set_token('TABLE_NAME',p_table_name);
              ELSE
                 IF g_master_rec(i).budget_id IS NULL AND g_master_rec(i).enc_type_id IS NULL THEN
                    fnd_message.set_name('FEM', 'FEM_DLLDR_LEDGER_LOAD_COMPLETE');
                    fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                    fnd_message.set_token('TABLE_NAME',p_table_name);
                    fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                    fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                    fnd_message.set_token('ROW',p_table_row);
                 ELSIF g_master_rec(i).budget_id IS NOT NULL  THEN
                    fnd_message.set_name('FEM', 'FEM_DLLDR_LDGR_LOAD_COMPLETE_B');
                    fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                    fnd_message.set_token('TABLE_NAME',p_table_name);
                    fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                    fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                    fnd_message.set_token('BUDGET_DISPLAY_CODE', g_master_rec(i).budget_display_code);
                    fnd_message.set_token('ROW',p_table_row);
                 ELSIF g_master_rec(i).enc_type_id IS NOT NULL  THEN
                    fnd_message.set_name('FEM', 'FEM_DLLDR_LDGR_LOAD_COMPLETE_E');
                    fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                    fnd_message.set_token('TABLE_NAME',p_table_name);
                    fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                    fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                    fnd_message.set_token('ENC_TYPE_CODE', g_master_rec(i).enc_type_code);
                    fnd_message.set_token('ROW',p_table_row);
                 END IF;
              END IF;

              fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                           ,p_module   => g_block||'.log_fact_table(PROCEDURE)'
                                           ,p_msg_text => 'Register the chain for parent request(' || g_request_id ||
                                                          '), child request(' || g_master_rec(i).request_id || ')');

              fem_pl_pkg.register_chain(p_api_version                  => c_api_version
                                       ,p_commit                       => c_false
                                       ,p_request_id                   => g_master_rec(i).request_id
                                       ,p_object_id                    => gs_table_obj_id(g_master_rec(i).table_row)
                                       ,p_source_created_by_request_id => g_request_id
                                       ,p_source_created_by_object_id  => g_object_id
                                       ,p_user_id                      => g_user_id
                                       ,p_last_update_login            => g_login_id
                                       ,x_msg_count                    => l_msg_count
                                       ,x_msg_data                     => l_msg_data
                                       ,x_return_status                => l_return_status);

              fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                           ,p_module   => g_block||'.log_fact_table(PROCEDURE)'
                                           ,p_msg_text => 'Completed registering the chain for parent request('
                                                          || g_request_id ||
                                                          '), child request(' || g_master_rec(i).request_id || ')');

              IF l_return_status <> c_success THEN
                 RAISE e_process_single_rule_error;
              END IF;

           ELSE -- g_master_rec(i).status = 'Y'

              IF g_loader_type = 'CLIENT' THEN
                 fnd_message.set_name('FEM', 'FEM_DLLDR_DATA_LOADER_ERR');
                 fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                 fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                 fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                 fnd_message.set_token('SOURCE_SYSTEM_CODE', g_master_rec(i).source_system_display_code);
                 fnd_message.set_token('TABLE_NAME',p_table_name);
              ELSE
                 fnd_message.set_name('FEM', 'FEM_DLLDR_LEDGER_LOADER_ERR');
                 fnd_message.set_token('REQUEST_ID', g_master_rec(i).request_id);
                 fnd_message.set_token('LEDGER_DISPLAY_CODE', g_master_rec(i).ledger_display_code);
                 fnd_message.set_token('TABLE_NAME',p_table_name);
                 fnd_message.set_token('DATASET_DISPLAY_CODE', g_master_rec(i).dataset_display_code);
                 fnd_message.set_token('ROW',p_table_row);
              END IF;

           END IF; -- g_master_rec(i).status = 'Y'

         ELSE -- g_master_rec(i).request_id > 0
            fnd_message.set_name('FEM', 'FEM_DLLDR_DATA_CONC_PGM_ERR');
            fnd_message.set_token('TABLE_NAME',p_table_name);
         END IF; -- g_master_rec(i).request_id > 0

         trace('MESSAGE');

     END LOOP;

     trace('SEPARATOR');

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_fact_table(PROCEDURE)'
                                  ,p_msg_text => 'END log_fact_table(' || p_table_name || ',' || p_table_row || ')');

   EXCEPTION
     WHEN e_process_single_rule_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => g_block||'.log_fact_table(PROCEDURE)'
           ,p_msg_text  => 'EXCEPTION in log_fact_table while registering the chain(' || p_table_name || ',' ||
                           p_table_row || ')' );
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.log_fact_table(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in log_fact_table(' || p_table_name || ',' ||
                                                   p_table_row || ') '  || sqlerrm);
       fnd_file.put_line(fnd_file.log, 'Exception - log_fact_table ' || sqlerrm);
       RAISE;
  END log_fact_table;

  ---------------------
  -- END log_fact_table
  ---------------------


  --------------------------------------------------------------------------------
  --
  -- Main procedure called from process_request to log the outcome of all the CP
  -- This in turn branches to dimensions, hierarchies, data/ledger load
  --
  --------------------------------------------------------------------------------


 PROCEDURE populate_log IS
    l_status        VARCHAR2(200);
    l_phase         VARCHAR2(200);
    l_request_id    NUMBER;
    l_table_name    VARCHAR2(30);
    all_str         VARCHAR2(30);
 BEGIN

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.populate_log(PROCEDURE)'
                                   ,p_msg_text => 'BEGIN..for populate_log');

      fnd_message.set_name('FEM', 'FEM_ALL_TXT');
      all_str := fnd_message.get;

      FOR i IN 1..gs_table_name_tab.COUNT LOOP
          IF gs_ledger_tab(i) = -1 THEN
             gs_ledger_code_tab(i) := all_str;
          ELSE
             SELECT ledger_display_code
              INTO  gs_ledger_code_tab(i)
             FROM   fem_ledgers_b
             WHERE  ledger_id = gs_ledger_tab(i)
               AND  personal_flag = 'N'
               AND  enabled_flag = 'Y';
          END IF;

          IF g_loader_type = 'CLIENT' THEN
             IF gs_ss_tab(i) = -1 THEN
                gs_ss_code_tab(i) := all_str;
             ELSE
                SELECT source_system_display_code
                INTO   gs_ss_code_tab(i)
                FROM   fem_source_systems_b
                WHERE  source_system_code = gs_ss_tab(i)
                  AND  personal_flag = 'N'
                  AND  enabled_flag = 'Y';
             END IF;

             IF gs_ds_tab(i) = -1 THEN
                gs_ds_code_tab(i) := all_str;
             ELSE
                SELECT dataset_display_code
                INTO   gs_ds_code_tab(i)
                FROM   fem_datasets_b
                WHERE  dataset_code = gs_ds_tab(i)
                  AND  personal_flag = 'N'
                  AND  enabled_flag = 'Y';
             END IF;
          ELSE
            SELECT dataset_display_code
            INTO   gs_ds_code_tab(i)
            FROM   fem_datasets_b
            WHERE  dataset_code = gs_ds_tab(i)
              AND  personal_flag = 'N'
              AND  enabled_flag = 'Y';

          END IF; -- g_loader_type = 'CLIENT'

      END LOOP;

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.populate_log(PROCEDURE)'
                                   ,p_msg_text => 'Fetched all the display codes');

      FOR i IN 1..gs_table_name_tab.COUNT LOOP
          trace('SEPARATOR');
          IF g_loader_type = 'CLIENT' THEN
             fnd_message.set_name('FEM', 'FEM_DLLDR_LOAD_DATA_MSG');
             fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
             fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
             fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
             fnd_message.set_token('SOURCE_SYSTEM_CODE', gs_ss_code_tab(i));
          ELSE
             fnd_message.set_name('FEM', 'FEM_DLLDR_LOAD_DATA_MSG_L');
             fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
             fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
             fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
          END IF;
          trace('MESSAGE');
          trace('SEPARATOR');
          IF gs_load_opt_tab(i) = 'DD' THEN
             log_dimensions(gs_table_name_tab(i));
             trace('SEPARATOR');
          END IF; -- gs_load_opt_tab(i) = 'DD'

          IF gs_load_opt_tab(i) = 'DDH' THEN
             log_dimensions(gs_table_name_tab(i));
             log_hierarchies(gs_table_name_tab(i));
             trace('SEPARATOR');
          END IF;

          FOR j IN 1..g_inv_table_row.COUNT LOOP
              IF g_inv_table_row(j) = i THEN
                 IF g_inv_ds_pd_flag(j) = 'N' THEN
                    fnd_message.set_name('FEM', 'FEM_DLLDR_LOADER_PROD_DS');
                    fnd_message.set_token('DATASET',g_inv_dataset(j));
                    trace('MESSAGE');
                    trace('SEPARATOR');
                 END IF;
              END IF;
          END LOOP;

          CASE gs_valid_rows(i)

             WHEN 0 THEN
                IF g_loader_type = 'CLIENT' THEN
                   fnd_message.set_name('FEM', 'FEM_DLLDR_DATA_LOADER_WARN');
                   fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
                   fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
                   fnd_message.set_token('SOURCE_SYSTEM_CODE', gs_ss_code_tab(i));
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                ELSE
                   fnd_message.set_name('FEM', 'FEM_DLLDR_LEDGER_LOADER_WARN');
                   fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                   fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
                   fnd_message.set_token('ROW',gs_table_row_tab(i));
                END IF;
                trace('MESSAGE');
                trace('SEPARATOR');
             WHEN -1 THEN
                IF g_loader_type = 'CLIENT' THEN
                   fnd_message.set_name('FEM', 'FEM_DLLDR_INTERFACE_NO_DATA');
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                ELSE
                   fnd_message.set_name('FEM', 'FEM_DLLDR_INTERFACE_NO_DATA_L');
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                   fnd_message.set_token('DATASET_TYPE',gs_ds_bal_code_tab(i));
                   fnd_message.set_token('ROW',gs_table_row_tab(i));
                END IF;
                trace('MESSAGE');
                trace('SEPARATOR');
             WHEN -2 THEN
                fnd_message.set_name('FEM', 'FEM_DLLDR_INTERFACE_TABLE_ERR');
                fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                trace('MESSAGE');
                trace('SEPARATOR');
             WHEN -3 THEN
                IF g_loader_type = 'CLIENT' THEN
                   fnd_message.set_name('FEM', 'FEM_DLLDR_CAL_PERIOD_ERR');
                   fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
                   fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
                   fnd_message.set_token('SOURCE_SYSTEM_CODE', gs_ss_code_tab(i));
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                ELSE
                   fnd_message.set_name('FEM', 'FEM_DLLDR_CAL_PERIOD_ERR_L');
                   fnd_message.set_token('LEDGER_DISPLAY_CODE', gs_ledger_code_tab(i));
                   fnd_message.set_token('DATASET_DISPLAY_CODE', gs_ds_code_tab(i));
                   fnd_message.set_token('TABLE_NAME',gs_table_name_tab(i));
                   fnd_message.set_token('ROW',gs_table_row_tab(i));
                END IF;
                trace('MESSAGE');
                trace('SEPARATOR');
             ELSE
                log_fact_table(gs_table_name_tab(i), gs_table_row_tab(i));
                trace('BLANKLINE');
                trace('SEPARATOR');
          END CASE; -- gs_valid_rows(i)

     END LOOP;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.populate_log(PROCEDURE)'
                                  ,p_msg_text => 'END populate_log');


   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.populate_log(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in populate_log ' || sqlerrm);
       fnd_file.put_line(fnd_file.log, 'Exception - populate_log ' || sqlerrm);
       RAISE;

  END populate_log;

  -------------------
  -- END populate_log
  -------------------

  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.MAIN - start'
                                 ,p_msg_text => 'BEGIN MAIN PACKAGE SECTION');

    g_approval_flag := FALSE;
    g_hierarchy_exists := FALSE;
    g_enc_exist := FALSE;
    g_budgets_exist := FALSE;

    g_loader_run := FALSE;
    g_evaluate_parameters := FALSE;

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.MAIN - end'
                                 ,p_msg_text => 'END MAIN PACKAGE SECTION');

   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.MAIN'
                                    ,p_msg_text => 'EXCEPTION in MAIN PACKAGE SECTION ' || sqlerrm);

       fnd_file.put_line(fnd_file.log, 'Exception - main ' || sqlerrm);
       RAISE;

  END Fem_Data_Loader_Pkg;

/

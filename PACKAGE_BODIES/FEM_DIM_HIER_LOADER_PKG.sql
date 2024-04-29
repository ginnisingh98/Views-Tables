--------------------------------------------------------
--  DDL for Package Body FEM_DIM_HIER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_HIER_LOADER_PKG" AS
/* $Header: FEMDIMHIERLDR.plb 120.2 2008/02/15 18:10:31 gcheng ship $ */
  --------------------------------------------------------------------------------
                           -- Declare all global variables --
  --------------------------------------------------------------------------------

     gs_dim_id_tab           number_table;
     gs_dim_label_tab        char_table;
     gs_table_row_tab        number_table;
     gs_hier_dim_id_tab      number_table;
     gs_hier_dim_label_tab   char_table;
     gs_hier_obj_id_tab      number_table;
     gs_hier_obj_def_id_tab  number_table;

     g_hier_object_def_id    NUMBER;

     g_trc_request_id        NUMBER;
     g_pipe_name             VARCHAR2(30);
     g_all_str               VARCHAR2(30);

     g_budgets_exist         BOOLEAN;
     g_enc_exist             BOOLEAN;
     g_loader_run            BOOLEAN;

     g_load_dimensions       BOOLEAN;
     g_load_hierarchies      BOOLEAN;

  --------------------------------------------------------------------------------
                     -- Declare private procedures and functions --
  --------------------------------------------------------------------------------

     PROCEDURE get_parameters(p_obj_def_id IN NUMBER);
     PROCEDURE print_params;
     PROCEDURE submit_dimension_loaders;
     PROCEDURE submit_hierarchy_loaders;
     PROCEDURE build_dim_stages;
     PROCEDURE build_hier_stages;
     PROCEDURE wait_for_requests(p_wait_for IN VARCHAR2);
     PROCEDURE log_dimensions;
     PROCEDURE log_hierarchies;
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
                               p_obj_def_id IN NUMBER)
     IS

     BEGIN

        fnd_log_repository.init;

        fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'BEGIN..for process_request');

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PARAMETERS)'
                                     ,p_msg_text => 'p_obj_def_id    :: ' || p_obj_def_id);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Calling get_parameters');

        get_parameters(p_obj_def_id);

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.process_request(PROCEDURE)'
                                     ,p_msg_text => 'Completed get_parameters');

        fnd_msg_pub.initialize;

        IF g_load_dimensions THEN
           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling build_dim_stages');


           build_dim_stages;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed build_dim_stages');

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling log_dimensions');

           log_dimensions;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed log_dimensions');

        END IF;

        IF g_load_hierarchies THEN
           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling build_hier_stages');

           build_hier_stages;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed build_hier_stages');

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Calling log_hierarchies');


           log_hierarchies;

           fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                        ,p_module   => g_block||'.process_request(PROCEDURE)'
                                        ,p_msg_text => 'Completed log_hierarchies');

        END IF;

        IF NOT g_load_dimensions AND NOT g_load_hierarchies THEN
           fnd_file.put_line(fnd_file.log,  ' No data found for loading dimensions and hierarchies');
        END IF;

        print_params;

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

       gs_dim_id_tab.DELETE;
       gs_table_row_tab.DELETE;
       gs_hier_dim_id_tab.DELETE;
       gs_hier_obj_id_tab.DELETE;
       gs_hier_obj_def_id_tab.DELETE;

       DELETE fem_ld_dim_requests_gt;

       DELETE fem_ld_hier_requests_gt;

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.cleanup(PROCEDURE)'
                                    ,p_msg_text => 'END cleanup ');


    END cleanup;

  --------------
  -- END cleanup
  --------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used to query up the selection criteria specified by the
  -- user in the parameters page.
  --
  --------------------------------------------------------------------------------


  PROCEDURE get_parameters(p_obj_def_id IN NUMBER)  IS
    dim_loader_rule_error            EXCEPTION;
  BEGIN

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.get_parameters(PROCEDURE)'
                                   ,p_msg_text => 'BEGIN..for get_parameters ');


      BEGIN
        SELECT fdb.dimension_id,
               fdb.dimension_varchar_label
         BULK COLLECT INTO gs_dim_id_tab,
                           gs_dim_label_tab
        FROM   fem_dim_load_dim_params fdldp,
               fem_dimensions_b fdb
        WHERE  loader_obj_def_id = p_obj_def_id
          AND  fdb.dimension_id = fdldp.dimension_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL; -- Dimension page not populated
        WHEN OTHERS THEN
           fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                        ,p_module   => g_block||'.get_parameters (PROCEDURE)'
                                        ,p_msg_text => 'EXCEPTION in get_parameters.loading dimensions ' || sqlerrm);
           fnd_file.put_line(fnd_file.log,  'Error @ get parameters');
           RAISE; -- dim_loader_rule_error;
      END;

      IF gs_dim_id_tab.COUNT > 0.0 THEN
         g_load_dimensions := TRUE;
      END IF;

      BEGIN
        SELECT ROWNUM,
               fdb.dimension_id,
               fdb.dimension_varchar_label,
               hier_obj_id,
               hier_obj_def_id
         BULK COLLECT INTO gs_table_row_tab,
                           gs_hier_dim_id_tab,
                           gs_hier_dim_label_tab,
                           gs_hier_obj_id_tab,
                           gs_hier_obj_def_id_tab
        FROM   fem_dim_load_hier_params fdlhp,
               fem_dimensions_b fdb
        WHERE  loader_obj_def_id = p_obj_def_id
          AND  fdb.dimension_id = fdlhp.dimension_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL; -- Hierarchy page not populated
        WHEN OTHERS THEN
           fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                        ,p_module   => g_block||'.get_parameters (PROCEDURE)'
                                        ,p_msg_text => 'EXCEPTION in get_parameters.loading hierarchies ' || sqlerrm);

           fnd_file.put_line(fnd_file.log,  'Error @ get parameters');
           RAISE; -- dim_loader_rule_error;
        END;

       IF gs_hier_obj_id_tab.COUNT > 0.0 THEN
          g_load_hierarchies := TRUE;
       END IF;

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.get_parameters(PROCEDURE)'
                                    ,p_msg_text => 'END get_parameters ');


  END get_parameters;

  ---------------------
  -- END get_parameters
  ---------------------

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
    l_compl_status    BOOLEAN;
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for wait_for_requests ');

     CASE p_wait_for
       WHEN c_dim_loader THEN
        FOR dim_rec IN (SELECT request_id
                        FROM   fem_ld_dim_requests_gt
                        WHERE  request_id > 0)
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
                 l_compl_status:= fnd_concurrent.set_completion_status('ERROR',null);
              END IF;

           END IF;  -- fnd_concurrent.wait_for_request (DIMENSIONS)

        END LOOP; -- dim_rec

     ELSE  -- 'Hierarchy'
        FOR hier_rec IN (SELECT DISTINCT request_id
                        FROM   fem_ld_dim_requests_gt
                        WHERE  request_id > 0)
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
                 l_compl_status:= fnd_concurrent.set_completion_status('ERROR',null);
              END IF;

           END IF;  -- fnd_concurrent.wait_for_request (DIMENSIONS)

        END LOOP; -- dim_rec

     END CASE;  -- p_wait_for

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                  ,p_msg_text => 'END wait_for_requests ');

  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.wait_for_requests(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in wait_for_requests ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,  'Exception - wait_for_requests' || sqlerrm);
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
    l_compl_status    BOOLEAN;

  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for submit_dimension_loaders');


     l_at_least_one := FALSE;

     FOR dim_rec IN (SELECT dimension_id,
                            dim_intf_table_name
                     FROM   fem_ld_dim_requests_gt )
     LOOP

         BEGIN
            EXECUTE IMMEDIATE 'SELECT 1 FROM ' || dim_rec.dim_intf_table_name || ' WHERE ROWNUM = 1' INTO l_dummy;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_dummy := 0.0;
            WHEN OTHERS THEN
               fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                            ,p_module   => g_block||'.submit_dimension_loaders(PROCEDURE)'
                                            ,p_msg_text => 'Error while checking if data EXISTS in interface table '
                                                           || dim_rec.dim_intf_table_name || ' - ' || sqlerrm);
               fnd_file.put_line(fnd_file.log, 'Table ' || dim_rec.dim_intf_table_name || ' does not exist ');
               fnd_file.put_line(fnd_file.log, 'Exception - submit_dimension_loaders  ' || sqlerrm);

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
            l_compl_status:= fnd_concurrent.set_completion_status('ERROR',null);
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
      fnd_file.put_line(fnd_file.log,  'Exception - submit_dimension_loaders' || sqlerrm);
      RAISE;
  END submit_dimension_loaders;

  -------------------------------
  -- END submit_dimension_loaders
  -------------------------------

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

         UPDATE  fem_ld_hier_requests_gt
         SET     request_id = l_request_id
         WHERE   dimension_id = hier_rec.dimension_id
           AND   dimension_varchar_label = hier_rec.dimension_varchar_label
           AND   hierarchy_object_name = hier_rec.hierarchy_object_name
           AND   hier_obj_def_display_name = hier_rec.hier_obj_def_display_name;

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
      fnd_file.put_line(fnd_file.log,  'Exception - submit_hierarchy_loaders' || sqlerrm);
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
  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for build_dim_stages');


     FORALL i IN 1..gs_dim_id_tab.COUNT
        INSERT INTO fem_ld_dim_requests_gt(dimension_id,
                                           dimension_varchar_label,
                                           dim_intf_table_name,
                                           request_id,
                                           status)
        SELECT gs_dim_id_tab(i),
               gs_dim_label_tab(i),
               intf_member_b_table_name,
               TO_NUMBER(NULL),
               'N'
        FROM   fem_xdim_dimensions fxd
        WHERE  fxd.dimension_id = gs_dim_id_tab(i)
          AND  intf_member_b_table_name IS NOT NULL;

     IF SQL%ROWCOUNT > 0.0 THEN
        submit_dimension_loaders;
     ELSE
        UPDATE fem_ld_dim_requests_gt
        SET    request_id = -10000;
     END IF;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                  ,p_msg_text => 'END build_dim_stages');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.build_dim_stages(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in build_dim_stages ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,  'Exception - build_dim_stages' || sqlerrm);
      RAISE;
  END build_dim_stages;

  -----------------------
  -- END build_dim_stages
  -----------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure populates the list of all hierarchies in fem_ld_hier_requests_gt
  --
  --------------------------------------------------------------------------------

  PROCEDURE build_hier_stages IS
     l_hier_count   NUMBER;
  BEGIN

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
                                             ,p_msg_text => 'EXCEPTION in build_dim_stages -
                                                             fetching object_def_id for HIER');
                fem_data_loader_pkg.trace('Error in build dim stages while building HIER'); RAISE;
        END;

     END IF;

     FORALL i IN 1..gs_hier_dim_id_tab.COUNT
        INSERT INTO fem_ld_hier_requests_gt(dimension_id,
                                           dimension_varchar_label,
                                           hierarchy_object_name,
                                           hier_obj_def_display_name,
                                           request_id,
                                           table_row)
        SELECT gs_hier_dim_id_tab(i),
               gs_hier_dim_label_tab(i),
               fht.hierarchy_object_name,
               fht.hier_obj_def_display_name,
               TO_NUMBER(NULL),
               gs_table_row_tab(i)
        FROM   fem_hierarchies_t fht
        WHERE  fht.dimension_varchar_label = gs_hier_dim_label_tab(i)
          AND  gs_hier_obj_def_id_tab(i) = -1
          AND  gs_hier_obj_id_tab(i) = -1;

     FORALL i IN 1..gs_hier_dim_id_tab.COUNT
        INSERT INTO fem_ld_hier_requests_gt(dimension_id,
                                           dimension_varchar_label,
                                           hierarchy_object_name,
                                           hier_obj_def_display_name,
                                           request_id,
                                           table_row)
        SELECT gs_hier_dim_id_tab(i),
               gs_hier_dim_label_tab(i),
               fht.hierarchy_object_name,
               fht.hier_obj_def_display_name,
               TO_NUMBER(NULL),
               gs_table_row_tab(i)
        FROM   fem_hierarchies_t fht,
               fem_object_catalog_vl focb,
               fem_object_definition_vl fodb
        WHERE  fht.dimension_varchar_label = gs_hier_dim_label_tab(i)
          AND  fht.hierarchy_object_name = focb.object_name
          AND  focb.object_id = gs_hier_obj_id_tab(i)
          AND  fht.hier_obj_def_display_name = fodb.display_name
          AND  focb.object_id = fodb.object_id
          AND  fht.language = USERENV('LANG')
          AND  focb.object_type_code = 'HIERARCHY'
          AND  gs_hier_obj_def_id_tab(i) <> -1
          AND  gs_hier_obj_id_tab(i) = -1;

     FORALL i IN 1..gs_hier_dim_id_tab.COUNT
        INSERT INTO fem_ld_hier_requests_gt(dimension_id,
                                           dimension_varchar_label,
                                           hierarchy_object_name,
                                           hier_obj_def_display_name,
                                           request_id,
                                           table_row)
        SELECT gs_hier_dim_id_tab(i),
               gs_hier_dim_label_tab(i),
               fht.hierarchy_object_name,
               fht.hier_obj_def_display_name,
               TO_NUMBER(NULL),
               gs_table_row_tab(i)
        FROM   fem_hierarchies_t fht,
               fem_hierarchies fh,
               fem_object_catalog_vl focb,
               fem_object_definition_vl fodb
        WHERE  fht.dimension_varchar_label = gs_hier_dim_label_tab(i)
          AND  fht.hierarchy_object_name = focb.object_name
          AND  focb.object_id = fh.hierarchy_obj_id
          AND  focb.object_id = gs_hier_obj_id_tab(i)
          AND  fht.hier_obj_def_display_name = fodb.display_name
          AND  focb.object_id = fodb.object_id
          AND  fodb.object_definition_id = gs_hier_obj_def_id_tab(i)
          AND  fht.language = USERENV('LANG')
          AND  gs_hier_obj_def_id_tab(i) <> -1
          AND  gs_hier_obj_id_tab(i) <> -1
          AND  focb.object_type_code = 'HIERARCHY';

     SELECT COUNT(1)
     INTO   l_hier_count
     FROM   fem_ld_hier_requests_gt
     WHERE  ROWNUM = 1;

     IF l_hier_count > 0.0 THEN
        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.build_hier_stages(PROCEDURE)'
                                     ,p_msg_text => 'Calling submit_hierarchy_loaders');

        submit_hierarchy_loaders;

        fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                     ,p_module   => g_block||'.build_hier_stages(PROCEDURE)'
                                     ,p_msg_text => 'Calling submit_hierarchy_loaders');

     END IF;

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.build_hier_stages(PROCEDURE)'
                                  ,p_msg_text => 'END build_hier_stages');


  EXCEPTION
    WHEN OTHERS THEN
      fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                   ,p_module   => g_block||'.build_hier_stages(PROCEDURE)'
                                   ,p_msg_text => 'EXCEPTION in build_hier_stages ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,  'Exception - build_hier_stages' || sqlerrm);
      RAISE;
  END build_hier_stages;

  ------------------------
  -- END build_hier_stages
  ------------------------

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

     FOR dim_rec IN (SELECT dimension_id,
                            dim_intf_table_name,
                            dimension_varchar_label
                     FROM   fem_ld_dim_requests_gt )
     LOOP
       fnd_file.put_line(FND_FILE.log,  ' Dimension ID :: ' || dim_rec.dimension_id);
       fnd_file.put_line(FND_FILE.log,  ' Interface TB :: ' || dim_rec.dim_intf_table_name);
       fnd_file.put_line(FND_FILE.log,  ' Dim Label    :: ' || dim_rec.dimension_varchar_label);
     END LOOP;

     fnd_file.put_line(FND_FILE.log, '=============================================================================');

     FOR hier_rec IN (SELECT dimension_id,
                             dimension_varchar_label,
                             hierarchy_object_name,
                             hier_obj_def_display_name,
                             table_row
                      FROM   fem_ld_hier_requests_gt )
     LOOP
       fnd_file.put_line(FND_FILE.log,  ' Table Row    :: ' || hier_rec.table_row);
       fnd_file.put_line(FND_FILE.log,  ' Dimension ID :: ' || hier_rec.dimension_id);
       fnd_file.put_line(FND_FILE.log,  ' Dim Label    :: ' || hier_rec.dimension_varchar_label);
       fnd_file.put_line(FND_FILE.log,  ' Hier Obj Name:: ' || hier_rec.hierarchy_object_name);
       fnd_file.put_line(FND_FILE.log,  ' Hier Obj Def :: ' || hier_rec.hier_obj_def_display_name);
     END LOOP;

     fnd_file.put_line(FND_FILE.log, '========================     End  Printing Parameters  ======================');
     fnd_file.put_line(FND_FILE.log, '=============================================================================');


  END print_params;

  -------------------
  -- END print_params
  -------------------

  --------------------------------------------------------------------------------
  --
  -- This procedure is used for printing the outcome of dimension loader CP
  --
  --------------------------------------------------------------------------------


  PROCEDURE log_dimensions IS

  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for log_dimensions');


     fem_data_loader_pkg.trace('SEPARATOR');

     FOR dim_rec IN ( SELECT dimension_varchar_label,
                             request_id,
                             status
                      FROM   fem_ld_dim_requests_gt)
     LOOP
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

        fem_data_loader_pkg.trace('MESSAGE');

     END LOOP; -- dim_rec

     fem_data_loader_pkg.trace('SEPARATOR');

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                  ,p_msg_text => 'END log_dimensions');

   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.log_dimensions(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in log_dimensions ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,  'Exception - log_dimensions' || sqlerrm);
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


  PROCEDURE log_hierarchies IS

    l_row_exists    BOOLEAN;

    l_hier_str      VARCHAR2(600);
    l_hier_name     VARCHAR2(300);
    l_hier_def_name VARCHAR2(300);

    l_lang          VARCHAR2(100);

  BEGIN

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                  ,p_msg_text => 'BEGIN..for log_hierarchies');

     fem_data_loader_pkg.trace('SEPARATOR');

     l_lang := USERENV('LANG');

     l_row_exists := FALSE;

     FOR i IN 1..gs_table_row_tab.COUNT LOOP

         FOR hier_rec IN (SELECT dimension_varchar_label,
                                 hierarchy_object_name,
                                 hier_obj_def_display_name,
                                 request_id,
                                 status
                         FROM    fem_ld_hier_requests_gt
                         WHERE   table_row = gs_table_row_tab(i))
         LOOP

           l_row_exists := TRUE;

           IF hier_rec.request_id > 0 THEN
              IF hier_rec.status = 'Y' THEN
                 fnd_message.set_name('FEM','FEM_DLLDR_HIERARCHY_LOADED');
                 fnd_message.set_token('REQUEST_ID',hier_rec.request_id);
                 fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' ||
                                                   hier_rec.hier_obj_def_display_name);
                 fnd_message.set_token('DIM_LABEL',gs_hier_dim_label_tab(i));
              ELSE
                 fnd_message.set_name('FEM','FEM_DLLDR_HIERARCHY_ERR');
                 fnd_message.set_token('REQUEST_ID',hier_rec.request_id);
                 fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' ||
                                                   hier_rec.hier_obj_def_display_name);
                 fnd_message.set_token('DIM_LABEL',gs_hier_dim_label_tab(i));
              END IF;
           ELSE
               fnd_message.set_name('FEM', 'FEM_DLLDR_HIER_CONC_PGM_ERR');
               fnd_message.set_token('HIERARCHY',hier_rec.hierarchy_object_name || '.' ||
                                                 hier_rec.hier_obj_def_display_name);
               fnd_message.set_token('DIM_LABEL',gs_hier_dim_label_tab(i));
           END IF;

         END LOOP; -- hier_rec

         IF l_row_exists THEN
            l_row_exists := FALSE;
         ELSE
            fnd_message.set_name('FEM', 'FEM_DLLDR_HIER_NO_DATA');

            IF gs_hier_obj_id_tab(i) = -1 AND gs_hier_obj_def_id_tab(i) = -1 THEN
               l_hier_str := g_all_str || '.' || g_all_str;
            ELSIF gs_hier_obj_id_tab(i) <> -1 AND gs_hier_obj_def_id_tab(i) = -1 THEN
               SELECT object_name
               INTO   l_hier_str
               FROM   fem_object_catalog_tl
               WHERE  object_id = gs_hier_obj_id_tab(i)
                 AND  language = l_lang;

               l_hier_str := l_hier_str || '.' || g_all_str;
            ELSE
               SELECT object_name
               INTO   l_hier_name
               FROM   fem_object_catalog_tl
               WHERE  object_id = gs_hier_obj_id_tab(i)
                 AND  language = l_lang;

               SELECT display_name
               INTO   l_hier_def_name
               FROM   fem_object_definition_tl
               WHERE  object_definition_id = gs_hier_obj_def_id_tab(i)
                 AND  language = l_lang;

               l_hier_str := l_hier_name || '.' || l_hier_def_name;
            END IF; -- gs_hier_obj_id_tab(i)

            fnd_message.set_token('HIERARCHY',l_hier_str);
            fnd_message.set_token('DIM_LABEL',gs_hier_dim_label_tab(i));
         END IF; -- l_row_exists

         fem_data_loader_pkg.trace('MESSAGE');

     END LOOP; -- 1..gs_table_row_tab

     fem_data_loader_pkg.trace('SEPARATOR');

     fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                  ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                  ,p_msg_text => 'END log_hierarchies');


   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.log_hierarchies(PROCEDURE)'
                                    ,p_msg_text => 'EXCEPTION in log_hierarchies ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,  'Exception - log_hierarchies' || sqlerrm);
      RAISE;
  END log_hierarchies;

  ----------------------
  -- END log_hierarchies
  ----------------------

  BEGIN

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.MAIN - start'
                                 ,p_msg_text => 'BEGIN MAIN PACKAGE SECTION');

    g_load_dimensions := FALSE;
    g_load_hierarchies := FALSE;

    fnd_message.set_name('FEM', 'FEM_ALL_TXT');
    g_all_str := fnd_message.get;


    DELETE fem_ld_dim_requests_gt;

    DELETE fem_ld_hier_requests_gt;

    fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                 ,p_module   => g_block||'.MAIN - end'
                                 ,p_msg_text => 'END MAIN PACKAGE SECTION');


   EXCEPTION
     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (p_severity => g_log_level_6
                                    ,p_module   => g_block||'.MAIN'
                                    ,p_msg_text => 'EXCEPTION in MAIN PACKAGE SECTION ' || sqlerrm);
       fnd_file.put_line(fnd_file.log,  'Exception - main ' || sqlerrm);
       RAISE;

  END Fem_Dim_Hier_Loader_Pkg;

/

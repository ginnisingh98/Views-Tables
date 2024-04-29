--------------------------------------------------------
--  DDL for Package Body GMD_QM_CONC_REPLACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QM_CONC_REPLACE_PKG" AS
/* $Header: GMDQRPLB.pls 120.3.12010000.3 2009/11/18 09:08:01 kannavar ship $ */

   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GMD_QM_CONC_REPLACE_PKG';

   --Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;

   l_debug               VARCHAR2 (1)  := set_debug_flag;
   FUNCTION set_debug_flag RETURN VARCHAR2 IS
      l_debug   VARCHAR2 (1) := 'N';
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
         l_debug := 'Y';
      END IF;

      RETURN l_debug;
   END set_debug_flag;

   PROCEDURE default_log (p_log_msg IN VARCHAR2) IS
   BEGIN
      fnd_file.new_line (fnd_file.LOG, 1);
      fnd_file.put (fnd_file.LOG, p_log_msg);
      fnd_file.new_line (fnd_file.output, 1);
      fnd_file.put (fnd_file.output, p_log_msg);
   END default_log;

   PROCEDURE DEBUG (p_log_msg IN VARCHAR2) IS
   BEGIN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line ('    ' || p_log_msg);
      END IF;
   END DEBUG;

   PROCEDURE set_test_values (
      p_gmd_test_rec      IN              gmd_qc_tests_b%ROWTYPE
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , x_return_status     OUT NOCOPY      VARCHAR2
    , x_test_values_rec   IN OUT NOCOPY   gmd_qm_conc_replace_pkg.test_values
   );

   PROCEDURE default_spectest_from_test (
      p_spec_id           IN              NUMBER
    , p_test_name         IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , p_spec_test_rec     IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE default_spectest_from_spectest (
      p_from_spec_id      IN              NUMBER
    , p_from_test_id      IN              NUMBER
    , p_to_test_name      IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , p_spec_test_rec     IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE add_spec_test_rec (
      p_spec_id         IN              NUMBER
    , p_test_name       IN              VARCHAR2
    , p_spec_name       IN              VARCHAR2
    , p_spec_test_rec   IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE del_spec_test_rec (
      p_spec_id         IN              NUMBER
    , p_spec_name       IN              VARCHAR2
    , p_test_name       IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE init_test_values_rec (
      p_spec_tests_rec    IN              gmd_spec_tests_b%ROWTYPE
    , x_test_values_rec   IN OUT NOCOPY   gmd_qm_conc_replace_pkg.test_values
   );

   PROCEDURE insert_spec_test_rec (
      p_spec_test_rec     IN              gmd_spec_tests_b%ROWTYPE
    ,  x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE insert_new_spec_rec (
      p_spec_rec        IN              gmd_specifications%ROWTYPE
    , x_new_spec_id     OUT NOCOPY      NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_new_specification (
      p_old_spec_id     IN              NUMBER
    , p_action_code     IN              VARCHAR2
    , x_new_spec_id     OUT NOCOPY      NUMBER
    , x_new_spec_vers   OUT NOCOPY      NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE process_validity_for_spec (
      p_object_type     IN              VARCHAR2
    , p_old_spec_id     IN              NUMBER DEFAULT NULL
    , p_new_spec_id     IN              NUMBER DEFAULT NULL
    , p_spec_vr_id      IN              NUMBER DEFAULT NULL
    , p_end_date        IN              DATE DEFAULT NULL
    , p_start_date      IN              DATE DEFAULT NULL
    , p_new_status      IN              NUMBER DEFAULT NULL
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE copy_validity_rule (
      p_from_vr_id      IN              NUMBER
    , p_to_spec_id      IN              NUMBER
    , p_spec_status     IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , p_create_mode     IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE end_old_validity_rule (
      p_vr_id           IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE obsolete_old_validity_rule (
      p_vr_id           IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_validity_rule (
      p_vr_id           IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , p_end_date        IN              DATE
    , p_start_date      IN              DATE
    , p_new_status      IN              NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   );

   FUNCTION is_test_in_expression (
      p_expression      IN              VARCHAR2
    , p_test_name       IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) RETURN BOOLEAN;

   /*###############################################################
    # NAME
    #   Populate_search_table
    # SYNOPSIS
    #   Populate_search_table
    # DESCRIPTION
    #    Performs populates a PL/SQL table with the search query.
    ###############################################################*/
   PROCEDURE populate_search_table (x_search_tbl OUT NOCOPY search_result_tbl) IS
      l_api_name             VARCHAR2 (100)  := 'POPULATE_SEARCH_TABLE';
      l_dsql_text            VARCHAR2 (2000);
      l_cursor_id            INT;
      l_num_of_rows          NUMBER;
      l_value                NUMBER;
      l_row_cnt              NUMBER          := 0;
      l_error                VARCHAR2 (2000);
      l_object_id            NUMBER;
      l_object_name          VARCHAR2 (240);
      l_object_vers          NUMBER;
      l_object_desc          VARCHAR2 (240);
      l_object_status_desc   VARCHAR2 (240);
      l_object_select_ind    NUMBER;
      l_object_status_code   VARCHAR2 (240);
      l_debug_text           VARCHAR2 (2000);
   BEGIN
      -- Delete rows from previous searches
      DELETE FROM gmd_msnr_results
            WHERE concurrent_id IS NULL;

      l_cursor_id := DBMS_SQL.open_cursor;
      fnd_dsql.set_cursor (l_cursor_id);
      l_dsql_text := fnd_dsql.get_text (FALSE);
      l_debug_text := fnd_dsql.get_text (TRUE);
      --raghav_debug ('l_dsql_text ' || l_dsql_text);
      --raghav_debug ('l_debug_text ' || l_debug_text);

      DBMS_SQL.parse (l_cursor_id, l_dsql_text, DBMS_SQL.native);
      fnd_dsql.do_binds;

      DBMS_SQL.define_column (l_cursor_id, 1, l_object_id);
      DBMS_SQL.define_column (l_cursor_id, 2, l_object_name, 240);
      DBMS_SQL.define_column (l_cursor_id, 3, l_object_vers);
      DBMS_SQL.define_column (l_cursor_id, 4, l_object_desc, 240);
      DBMS_SQL.define_column (l_cursor_id, 5, l_object_status_desc, 240);
      DBMS_SQL.define_column (l_cursor_id, 6, l_object_select_ind);
      DBMS_SQL.define_column (l_cursor_id, 7, l_object_status_code, 240);
      l_num_of_rows := DBMS_SQL.EXECUTE (l_cursor_id);

      LOOP
         IF DBMS_SQL.fetch_rows (l_cursor_id) > 0 THEN
            l_row_cnt := l_row_cnt + 1;
            DBMS_SQL.column_value (l_cursor_id, 1, l_object_id);
            DBMS_SQL.column_value (l_cursor_id, 2, l_object_name);
            DBMS_SQL.column_value (l_cursor_id, 3, l_object_vers);
            DBMS_SQL.column_value (l_cursor_id, 4, l_object_desc);
            DBMS_SQL.column_value (l_cursor_id, 5, l_object_status_desc);
            DBMS_SQL.column_value (l_cursor_id, 6, l_object_select_ind);
            DBMS_SQL.column_value (l_cursor_id, 7, l_object_status_code);

            IF (l_object_status_code IN ('200', '500', '800', '1000')) THEN
               l_object_select_ind := 0;
            END IF;

            -- Populate the pl/sql table
            -- This should go away soon !!!!!!
            x_search_tbl (l_row_cnt).object_id          := l_object_id;
            x_search_tbl (l_row_cnt).object_name        := l_object_name;
            x_search_tbl (l_row_cnt).object_vers        := l_object_vers;
            x_search_tbl (l_row_cnt).object_desc        := l_object_desc;
            x_search_tbl (l_row_cnt).object_status_desc := l_object_status_desc;
            x_search_tbl (l_row_cnt).object_select_ind  := l_object_select_ind;
            x_search_tbl (l_row_cnt).object_status_code := l_object_status_code;

            -- Save the set of details in work table
            INSERT INTO gmd_msnr_results
                        (concurrent_id
                       , object_id
                       , object_name
                       , object_vers
                       , object_desc
                       , object_status_code
                       , object_status_desc
                       , object_select_ind
                        )
                 VALUES (NULL
                       , l_object_id
                       , l_object_name
                       , l_object_vers
                       , l_object_desc
                       , l_object_status_code
                       , l_object_status_desc
                       , l_object_select_ind
                        );
         ELSE
            EXIT;
         END IF;
      END LOOP;

      DBMS_SQL.close_cursor (l_cursor_id);
      -- Commit all data populated
      --Commit; -- Bug 4444060 Commented the commit
   EXCEPTION
      WHEN OTHERS THEN
         IF (DBMS_SQL.is_open (l_cursor_id)) THEN
            DBMS_SQL.close_cursor (l_cursor_id);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END populate_search_table;

   /*  ************************************************************************ */
   /*  API name    : Mass_Replace_Operation                                     */
   /*  Type        : Private                                                    */
   /*  Function    :                                                            */
   /*  Pre-reqs    : None.                                                      */
   /*  Parameters  :                                                            */
   /*  IN          : prequest_id             IN      NUMBER  (Required)         */
   /*  Notes       : Performs replace of one or more instance of entities like  */
   /*                formula, routing, recipe, operation, Validity Rules.       */
   /*  HISTORY                                                                  */
   /*    RLNAGARA 04-May-2007 Bug6017214 Modified the code such that            */
   /*    only status change is allowed for Obsoleted/Archived, on Hold or       */
   /*    Request for Approval specifications.                                   */
   /*    SMALLURU 29-Nov-2007 Bug5973270 Modified the code to include spts in   */
   /*    l_select variable and also modified the IF condition that verifies the */
   /*    range of test values to consider NULL target values. 			*/
   /*  ************************************************************************ */
   PROCEDURE mass_replace_oper_spec_val (
      err_buf             OUT NOCOPY      VARCHAR2
    , ret_code            OUT NOCOPY      VARCHAR2
    , pconcurrent_id      IN              VARCHAR2 DEFAULT NULL
    , pobject_type        IN              VARCHAR2
    , preplace_type       IN              VARCHAR2
    , pold_name           IN              VARCHAR2
    , pnew_name           IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , pcreate_vers        IN              VARCHAR2 DEFAULT 'N'
   ) IS
      l_api_name              VARCHAR2 (100)   := 'MASS_REPLACE_OPER_SPEC_VAL';
      l_mesg_count            NUMBER;
      l_row_id                VARCHAR2 (200);
      l_mesg_data             VARCHAR2 (2000);
      l_return_status         VARCHAR2 (1);
      l_action_flag           VARCHAR2 (1)     := 'U';
      l_user_id               NUMBER           := fnd_global.user_id;
      l_text                  VARCHAR2 (100);
      l_object_name_vers      VARCHAR2 (200);
      l_retval                BOOLEAN;
      l_version_enabled       VARCHAR2 (1);
      l_rowcount              NUMBER;
      l_error_text            VARCHAR2 (2000);
      l_dummy_cnt             NUMBER;
      -- Define different table types
      l_spec_test_rec         gmd_spec_tests_b%ROWTYPE;
      l_gmd_test_rec          gmd_qc_tests_b%ROWTYPE;
      l_gmd_spec_rec          gmd_specifications_b%ROWTYPE;
      l_optional_ind          gmd_spec_tests_b.optional_ind%TYPE;
      l_print_spec_ind        gmd_spec_tests_b.print_spec_ind%TYPE;
      l_print_result_ind      gmd_spec_tests_b.print_result_ind%TYPE;
      l_target_value_num      gmd_spec_tests_b.target_value_num%TYPE;
      l_target_value_char     gmd_spec_tests_b.target_value_char%TYPE;
      l_min_value_num         gmd_spec_tests_b.min_value_num%TYPE;
      l_min_value_char        gmd_spec_tests_b.min_value_char%TYPE;
      l_max_value_num         gmd_spec_tests_b.max_value_num%TYPE;
      l_max_value_char        gmd_spec_tests_b.max_value_char%TYPE;
      l_report_precision      gmd_spec_tests_b.report_precision%TYPE;
      l_store_precision       gmd_spec_tests_b.display_precision%TYPE;
      l_test_priority         gmd_spec_tests_b.test_priority%TYPE;
      l_target_min            VARCHAR2 (80);
      l_target_max            VARCHAR2 (80);
      l_old_status            gmd_specifications_b.spec_status%TYPE;
      l_new_status            gmd_specifications_b.spec_status%TYPE;
      l_old_owner             gmd_specifications_b.owner_id%TYPE;
      l_new_owner             gmd_specifications_b.owner_id%TYPE;
      l_new_owner_id          gmd_specifications_b.owner_id%TYPE;
      l_old_ownerorg          gmd_specifications_b.owner_organization_id%TYPE; -- Bug# 5882074
      l_new_ownerorg          gmd_specifications_b.owner_organization_id%TYPE; -- Bug# 5882074
      l_end_date              gmd_all_spec_vrs_vl.end_date%TYPE;
      l_start_date            gmd_all_spec_vrs_vl.start_date%TYPE;
      l_test_values_rec       gmd_qm_conc_replace_pkg.test_values;
      l_rep_test_values_rec   gmd_qm_conc_replace_pkg.test_values;
      l_obj_id                NUMBER;
      l_exist                 NUMBER;
      l_seq                   NUMBER;
      l_new_spec_id           NUMBER;
      l_new_test_id           NUMBER;
      l_new_spec_vers         NUMBER;
      l_revision_exists       NUMBER; -- Bug# 5882074
      l_create_vers           VARCHAR2 (1);
      l_spec_vers_ctl         VARCHAR2 (10);
      l_state                 VARCHAR2 (1);  -- Bug# 5882074
      l_new_spec              VARCHAR2 (1);
      l_new_spec_success      VARCHAR2 (1);
      l_query_test_name       VARCHAR2 (400);
      l_select                VARCHAR2 (1000);
      l_from                  VARCHAR2 (200);
      l_where                 VARCHAR2 (200);
      l_query                 VARCHAR2 (2000);
      l_string                VARCHAR2 (2000);

      TYPE rc IS REF CURSOR;

      l_rec_query             rc;
      -- Exception declare
      NO_UPDATE_EXCEPTION     EXCEPTION;
      NO_REPLACE_EXCEPTION    EXCEPTION;

      CURSOR get_object_info IS
         SELECT UPPER (pobject_type)  object_type   -- e.g 'SPEC_TEST' etc
              , UPPER (preplace_type) replace_type  -- e.g 'TEST_VALUE'
              , pold_name             old_name      -- e.g 'SHY-SPEC-TEST'
              , pnew_name             new_name      -- e.g 'TDAN-SPEC-TEST'
              , preport_precision     report_preci  -- defaults to null
              , pstore_precision      store_precis  -- defaults to null
              , object_id                           -- e.g formula_id = 100
              , object_name                         -- e.g formula_no = 'SHY-TEST'
              , object_vers                         -- e.g formula_vers = 2
              , object_desc
              , object_status_code                  -- e.g formula_status = '100'
              , concurrent_id
           FROM gmd_msnr_results
          WHERE object_select_ind = 1
            AND concurrent_id = TO_NUMBER (pconcurrent_id);

      CURSOR get_gmd_test1 (p_test_name IN VARCHAR2) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_code = p_test_name;

      CURSOR get_gmd_test2 (p_test_id IN NUMBER) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_id = p_test_id;

      CURSOR get_spec_rec (p_spec_id IN NUMBER) IS
         SELECT *
           FROM gmd_specifications_b
          WHERE spec_id = p_spec_id;

      CURSOR check_spec_test (p_spec_id IN NUMBER, p_test_id IN NUMBER) IS
         SELECT 1
           FROM gmd_spec_tests_b
          WHERE spec_id = p_spec_id
            AND test_id = p_test_id;

      CURSOR check_spec_test2 (p_spec_id IN NUMBER, p_test_name IN VARCHAR2) IS
         SELECT 1
           FROM gmd_spec_tests_b sptst
              , gmd_qc_tests_b tst
          WHERE sptst.spec_id = p_spec_id
            AND sptst.test_id = tst.test_id
            AND tst.test_code = p_test_name;

      CURSOR get_spec_test_by_spec (p_spec_id IN NUMBER) IS
         SELECT *
           FROM gmd_spec_tests_b
          WHERE spec_id = p_spec_id;

      -- Bug# 5882074 cursor definition to check for organization
      CURSOR cur_check_item_org(p_org_id IN NUMBER, p_spec_id IN NUMBER) IS
         SELECT msi.organization_id, msi.inventory_item_id, msi.revision_qty_control_code, s.revision
           FROM mtl_system_items msi, gmd_specifications_b s
          WHERE msi.organization_id = p_org_id
            AND msi.inventory_item_id = s.inventory_item_id
            AND s.spec_id = p_spec_id
            AND msi.process_quality_enabled_flag = 'Y';

      item_org_rec CUR_CHECK_ITEM_ORG%ROWTYPE;

      -- Bug# 5882074 cursor definition to check for revision
      CURSOR cur_check_item_rev(p_org_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2) IS
         SELECT count(*)
           FROM mtl_item_revisions
          WHERE organization_id = p_org_id
            AND inventory_item_id = p_inventory_item_id
            AND revision = p_revision;

   BEGIN         -- begin of mass_replace_operations
      gmd_debug.log_initialize ('QMMSNR');
      -- output the log for the input parameters
      DEBUG (g_pkg_name || '.' || l_api_name || ' : 1st line ');
      DEBUG ('Input Parameters:');
      DEBUG ('     Concurrent_id: ' || pconcurrent_id);
      DEBUG ('     Object_type: ' || pobject_type);
      DEBUG ('     Replace_type: ' || preplace_type);
      DEBUG ('     Old_name: ' || pold_name);
      DEBUG ('     New_name: ' || pnew_name);
      DEBUG ('     Optional Ind: ' || poptional_ind);
      DEBUG ('     Print Spec Ind ' || pprint_spec_ind);
      DEBUG ('     Print Result Ind: ' || pprint_result_ind);
      DEBUG ('     Target Value : ' || ptarget_value);
      DEBUG ('     Target Min : ' || ptarget_min);
      DEBUG ('     Target Max : ' || ptarget_max);
      DEBUG ('     Report_Precision: ' || preport_precision);
      DEBUG ('     Store_Precision: ' || pstore_precision);
      DEBUG ('     Test_Priority: ' || ptest_priority);
      DEBUG ('     Create_Vers: ' || pcreate_vers);

      l_string := '';
      SELECT meaning
        INTO l_string
        FROM gem_lookups
       WHERE lookup_type = 'GMD_QM_REPLACE_OPTIONS'
         AND lookup_code = preplace_type;

      IF pobject_type = 'SPECIFICATION' THEN
         -- REPLACE TYPE could be on of the following
         -- REPSTATUS , REPOWNER, REPOWNERORG
         -- REPTESTVAL, ADDTEST, DELTEST, REPTEST
         default_log ('Replacement for Specifications');
         default_log ('  Action: ' || l_string);

         IF preplace_type = 'REPSTATUS' THEN
            default_log ('    Old Status: ' || pold_name);
            default_log ('    New Status: ' || pnew_name);
         ELSIF preplace_type = 'REPOWNER' THEN
            default_log ('    Old Owner : ' || pold_name);
            default_log ('    New Owner : ' || pnew_name);
         ELSIF preplace_type = 'REPOWNERORG' THEN
            default_log ('    Old Owner Organization Code: ' || pold_name);
            default_log ('    New Owner Organization Code: ' || pnew_name);
         ELSIF preplace_type = 'ADDTEST' THEN
            default_log ('    Test Name : ' || pnew_name);
         ELSIF preplace_type = 'REPTEST' THEN
            default_log ('    Old Test Name : ' || pold_name);
            default_log ('    New Test Name : ' || pnew_name);
         ELSIF preplace_type = 'DELTEST' THEN
            default_log ('    Test Name : ' || pnew_name);
         ELSIF preplace_type = 'REPTESTVAL' THEN
            default_log ('    Test Name : ' || pnew_name);
            default_log ('      New Optional Ind: ' || poptional_ind);
            default_log ('      New Print Spec Ind ' || pprint_spec_ind);
            default_log ('      New Print Result Ind: ' || pprint_result_ind);
            default_log ('      New Target Value : ' || ptarget_value);
            default_log ('      New Target Min : ' || ptarget_min);
            default_log ('      New Target Max : ' || ptarget_max);
            default_log ('      New Report_Precision: ' || preport_precision);
            default_log ('      New Store_Precision: ' || pstore_precision);
            default_log ('      New Test_Priority: ' || ptest_priority);
         END IF;
      ELSIF pobject_type = 'VALIDITY' THEN
         -- REPSTART, REPEND, REPSTATUS
         default_log ('Replacement for Validity Rules');
         default_log ('  Action: ' || l_string);

         IF preplace_type = 'REPSTATUS' THEN
            default_log ('    Old Status: ' || pold_name);
            default_log ('    New Status: ' || pnew_name);
         ELSIF preplace_type = 'REPSTART' THEN
            default_log ('    Old Start Date : ' || fnd_date.canonical_to_date (pold_name));
            default_log ('    New Start Date : ' || fnd_date.canonical_to_date (pnew_name));
         ELSIF preplace_type = 'REPEND' THEN
            default_log ('    Old End Date : ' || fnd_date.canonical_to_date (pold_name));
            default_log ('    New End Date : ' || fnd_date.canonical_to_date (pnew_name));
         END IF;
      END IF;

      -- Using concurrent_id/request_id we get the details on the object and column that
      -- is being replaced.
      -- Please Note : Each request id can have multiple replace rows.
      FOR get_object_rec IN get_object_info LOOP
         SAVEPOINT mass_replace_for_one;
         -- Initialize the following variables
         l_return_status := 'S';
         l_new_spec_success := 'N';
         l_new_spec_id := NULL;
         l_create_vers := pcreate_vers;

         BEGIN
            l_string := '';
            DEBUG (g_pkg_name || '.' || l_api_name);
            l_string := l_string
               || 'Replacing - object type: '
               || get_object_rec.object_type
               || ' Object_name: '
               || get_object_rec.object_name
               || ' Object_vers: '
               || get_object_rec.object_vers
               || ' Replacement Type:'
               || get_object_rec.replace_type
               || ' Object Status:'
               || get_object_rec.object_status_code;
            default_log (' ');
            default_log (' ');
            default_log (l_string);

            -- Making new line entry and prompting users about MSNR request
            fnd_file.new_line (fnd_file.LOG, 1);
            --FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
            fnd_message.set_name ('GMD', 'GMD_SPVL_REPLACE_MESG');
            fnd_message.set_token ('OBJECT_TYPE', get_object_rec.object_type);
            fnd_message.set_token ('NAME', get_object_rec.object_name);
            fnd_message.set_token ('VERSION', get_object_rec.object_vers);
            fnd_message.set_token ('REPLACE_TYPE', get_object_rec.replace_type);
            fnd_file.put (fnd_file.LOG, fnd_message.get);
            fnd_file.new_line (fnd_file.LOG, 1);
            --FND_FILE.PUT(FND_FILE.OUTPUT,FND_MESSAGE.GET);
            --FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

            IF pobject_type = 'SPECIFICATION' THEN
               /* REPLACE TYPE could be on of the following
                  REPSTATUS , REPOWNER, REPOWNERORG
                  REPTESTVAL, ADDTEST, DELTEST, REPTEST
                */

               -- Bug# 5882074 get the version control indicator from gmd_quality_config
               -- l_spec_vers_ctl := fnd_profile.value('GMD_SPEC_VERSION_CONTROL');
               l_query_test_name := pnew_name;
               l_select := 'select  spts.* ';  --Bug#5973270. Included spts.

               IF l_query_test_name IS NOT NULL THEN
                  l_from := ' from gmd_spec_tests_b  spts ' || '  ,   gmd_qc_tests      qcts ';
                  l_where :=
                        ' Where spts.test_id = qcts.test_id  '
                     || ' and spts.spec_id = ' || get_object_rec.object_id
                     || ' and qcts.test_code = ' || '''' || l_query_test_name || '''';
               ELSE
                  l_from := ' from gmd_spec_tests_b  spts ';
                  l_where := ' Where spts.spec_id = ' || get_object_rec.object_id;
               END IF;

               l_query := l_select || l_from || l_where;

               --IF (l_debug = 'Y') THEN
               --   gmd_debug.put_line('l_query  '||l_query );
               --End if;

               /* should new spec version be created? */
               -- Bug# 5882074 get the version control flag from quality config instead of profile.
               SELECT spec_version_control_ind
                 INTO l_state
                 FROM gmd_quality_config
                WHERE organization_id = (SELECT owner_organization_id
                                           FROM gmd_specifications_b
                                          WHERE spec_id = get_object_rec.object_id);

               l_spec_vers_ctl := gmd_spec_grp.version_control_state (
                        p_entity         => l_state -- fnd_profile.value('GMD_SPEC_VERSION_CONTROL')
                       ,p_entity_id      => get_object_rec.object_id);

               DEBUG ('  l_spec_vers_ctl ' || l_spec_vers_ctl);
               l_new_spec := 'N';

               IF l_spec_vers_ctl = 'Y' THEN
                  l_new_spec := 'Y';
               ELSIF (    l_spec_vers_ctl = 'O' AND l_create_vers = 'Y') THEN
                  l_new_spec := 'Y';
               END IF;

               IF get_object_rec.object_status_code IN (100, 1000) THEN     -- new or obsolete status, NO new spec
                  l_new_spec := 'N';
               END IF;
               default_log ('  Version Controlled: ' || l_new_spec);

               IF get_object_rec.replace_type IN ('REPSTATUS', 'REPOWNER', 'REPOWNERORG') THEN
                  -- Do NOT create new version in any cases for these
                  IF get_object_rec.replace_type = 'REPSTATUS' THEN
                     l_old_status := pold_name;
                     l_new_status := pnew_name;
                    if get_object_rec.object_status_code = l_old_status then
                     default_log (   '  Replace Spec Status, Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || '     Old Status :'
                                  || l_old_status
                                  || '     New Status :'
                                  || l_new_status);

                     UPDATE gmd_specifications_b    -- 8281768   added WHO columns.
                        SET spec_status = l_new_status,
                        LAST_UPDATE_DATE =  SYSDATE,
    										LAST_UPDATED_BY =   FND_GLOBAL.USER_ID,
    										LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID

                      WHERE spec_id = get_object_rec.object_id;

                     default_log ('  Update Specification Succesful');
                    else
                     default_log('  Spec status does not match. Old status: ' ||get_object_rec.object_status_code);
                     raise no_update_exception;
                    end if;
                  ELSIF get_object_rec.replace_type = 'REPOWNER' THEN
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;
                     l_old_owner := pold_name;
                     l_new_owner := pnew_name;
                    if l_gmd_spec_rec.owner_id = l_old_owner then
                     default_log (   '  Replace Spec Owner, Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || '     Old Owner :'
                                  || l_old_owner
                                  || '     New Owner :'
                                  || l_new_owner);

                     /*Select user_id
                     Into l_new_owner_id
                     From fnd_user
                     Where user_name = l_new_Owner;
                     */
                     UPDATE gmd_specifications_b   -- 8281768  added WHO columns
                        SET owner_id = l_new_owner,
                        LAST_UPDATE_DATE =  SYSDATE,
    										LAST_UPDATED_BY =   FND_GLOBAL.USER_ID,
    										LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID

                      WHERE spec_id = get_object_rec.object_id;
                     default_log ('  Update Specification Succesful');
                    else
                     default_log('  Spec Owner does not match. Old Owner: ' ||l_gmd_spec_rec.owner_id);
                     raise no_update_exception;
                    end if;
                  ELSE
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;

                     l_old_ownerorg := pold_name;
                     l_new_ownerorg := pnew_name;
                    if l_gmd_spec_rec.owner_orgn_code = l_old_ownerorg then
                     --Bug# 5882074 check if item is assigned to the organization.
                     OPEN cur_check_item_org(l_new_ownerorg, get_object_rec.object_id);
                     FETCH cur_check_item_org into item_org_rec;
                     CLOSE cur_check_item_org;

                     IF item_org_rec.organization_id IS NULL THEN
                         --FND_MESSAGE.SET_NAME('gmd', 'GMD_ITEM_ORG_NOT_FOUND');
                         --FND_MESSAGE.SET_TOKEN('ITEM',get_item_no(get_object_rec.new_name));
                         --FND_MESSAGE.SET_TOKEN('ORGN',get_orgn_code(l_orgn_id));
                         --FND_MSG_PUB.ADD;
                         default_log (   '  Item is not assigned to the organization  ');
                         RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     -- Check if Revision exists for the item.
                     IF item_org_rec.revision_qty_control_code = 2 AND item_org_rec.revision IS NOT NULL THEN
                         OPEN cur_check_item_rev(item_org_rec.organization_id, item_org_rec.inventory_item_id, item_org_rec.revision);
                         FETCH cur_check_item_rev INTO l_revision_exists;
                         CLOSE cur_check_item_rev;

                         IF l_revision_exists <> 1 THEN
                           default_log (   '  Revision Does not exists for the Item/organization ');
                           RAISE NO_UPDATE_EXCEPTION;
                         END IF;
                     END IF;

                     IF item_org_rec.revision_qty_control_code = 1 AND item_org_rec.revision IS NOT NULL THEN
                        default_log (   '  Item is not Revision controlled');
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     -- Bug# 5882074 Changed code to id
                     UPDATE gmd_specifications_b   -- 8281768 added WHO columns
                        SET owner_organization_id = l_new_ownerorg,
                        LAST_UPDATE_DATE =  SYSDATE,
    										LAST_UPDATED_BY =   FND_GLOBAL.USER_ID,
    										LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID

                      WHERE spec_id = get_object_rec.object_id;

                     default_log (   '  Replace Spec OwnerOrganization, Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || '     Old OwnerOrganization :'
                                  || l_old_ownerorg
                                  || '     New OwnerOrganization :'
                                  || l_new_ownerorg);
                     default_log ('  Update Specification Succesful');
                  else
                    default_log('  Spec OwnerOrg does not match. Old OwnerOrg: ' ||l_gmd_spec_rec.owner_orgn_code);
                    raise no_update_exception;
                  end if;
                 END IF;
               END IF;

               IF get_object_rec.replace_type = 'REPTESTVAL' THEN
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;

                  l_new_test_id := NULL;

                  OPEN l_rec_query FOR l_query;
                  LOOP
                     FETCH l_rec_query INTO l_spec_test_rec;
                     EXIT WHEN l_rec_query%NOTFOUND;
                     l_new_test_id := l_spec_test_rec.test_id;

                     OPEN get_gmd_test2 (l_spec_test_rec.test_id);
                     FETCH get_gmd_test2 INTO l_gmd_test_rec;
                     CLOSE get_gmd_test2;

                     /* set the initial value as the same as the record */
                     init_test_values_rec (
                           p_spec_tests_rec       => l_spec_test_rec
                         , x_test_values_rec      => l_test_values_rec);

                     DEBUG (' test_rec.test_type ' || l_gmd_test_rec.test_type);
                     DEBUG (' fetch gmd_qc_tests_b, test id ' || l_spec_test_rec.test_id);

                     set_test_values (p_gmd_test_rec         => l_gmd_test_rec
                                    , poptional_ind          => poptional_ind
                                    , pprint_spec_ind        => pprint_spec_ind
                                    , pprint_result_ind      => pprint_result_ind
                                    , ptarget_value          => ptarget_value
                                    , ptarget_min            => ptarget_min
                                    , ptarget_max            => ptarget_max
                                    , preport_precision      => preport_precision
                                    , pstore_precision       => pstore_precision
                                    , ptest_priority         => ptest_priority
                                    , x_return_status        => l_return_status
                                    , x_test_values_rec      => l_test_values_rec
                                     );

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     /* need to validate the min max for the test, no changes made if exceeds the max*/
                     --Bug#5973270. To handle NULL target test values in the Mass Search and Replace form.
                     IF    (NVL (l_test_values_rec.target_value_num, l_test_values_rec.max_value_num) > NVL (l_test_values_rec.max_value_num, 0))
                        OR (NVL (l_test_values_rec.target_value_num, l_test_values_rec.min_value_num) < NVL (l_test_values_rec.min_value_num, 0)) THEN
                           -- raise an error for this record, abort!
                        default_log (   '  Target value is out of range, '
                                     || ' Target Value: '
                                     || l_test_values_rec.target_value_num
                                     || ' Target Max: '
                                     || l_test_values_rec.max_value_num
                                     || ' Target Min: '
                                     || l_test_values_rec.min_value_num);
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     IF NVL (l_test_values_rec.min_value_num, 0) > NVL (l_test_values_rec.max_value_num, 0) THEN
                        -- raise an error for this record, abort!
                        default_log (   '  Target min value is out of range, '
                                     || ' Target Value: '
                                     || l_test_values_rec.target_value_num
                                     || ' Target Max: '
                                     || l_test_values_rec.max_value_num
                                     || ' Target Min: '
                                     || l_test_values_rec.min_value_num);
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     /* if only the precision, print ind change, No new spec */
                     IF (    (ptarget_value IS NULL)
                         AND (ptarget_min IS NULL)
                         AND (ptarget_max IS NULL)
                         AND (poptional_ind IS NULL)
                         AND (pstore_precision IS NULL)
                        ) THEN
                        l_new_spec := 'N';
                        default_log ('  No New spec is creted ');
                     END IF;

                     IF (l_new_spec = 'N') THEN
                        DEBUG (' update gmd_spec_tests_b, spec_id ' || l_spec_test_rec.spec_id);
                        DEBUG (' update gmd_spec_tests_b, test_id ' || l_spec_test_rec.test_id);

                        UPDATE gmd_spec_tests_b  -- 8281768 added WHO columns
                           SET optional_ind = l_test_values_rec.optional_ind
                             , print_spec_ind = l_test_values_rec.print_spec_ind
                             , print_result_ind = l_test_values_rec.print_result_ind
                             , target_value_num = l_test_values_rec.target_value_num
                             , target_value_char = l_test_values_rec.target_value_char
                             , min_value_char = l_test_values_rec.min_value_char
                             , max_value_char = l_test_values_rec.max_value_char
                             , min_value_num = l_test_values_rec.min_value_num
                             , max_value_num = l_test_values_rec.max_value_num
                             , report_precision = l_test_values_rec.report_precision
                             , display_precision = l_test_values_rec.store_precision
                             , test_priority = l_test_values_rec.test_priority
                             ,LAST_UPDATE_DATE =  SYSDATE
    												 ,LAST_UPDATED_BY =   FND_GLOBAL.USER_ID
    										     ,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID


                         WHERE spec_id = l_spec_test_rec.spec_id
                           AND test_id = l_spec_test_rec.test_id;

                        default_log (   '  Succesfully Replaced Record, Spec Name: '
                                     || get_object_rec.object_name
                                     || ', Version: '
                                     || get_object_rec.object_vers
                                     || ', Test Name: '
                                     || l_gmd_test_rec.test_code);

                        l_new_spec_id := l_spec_test_rec.spec_id;
                     ELSE    -- Version controled
                        /* create new version of spec */
                        /* spec only needs to be created once */
                        default_log ('  Version Controlled. Creating New Version of Spec:'
                                     || get_object_rec.object_name);

                        create_new_specification (p_old_spec_id        => get_object_rec.object_id
                                                , p_action_code        => 'NEWVERS'
                                                , x_new_spec_id        => l_new_spec_id
                                                , x_new_spec_vers      => l_new_spec_vers
                                                , x_return_status      => l_return_status
                                                 );

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                           RAISE NO_UPDATE_EXCEPTION;
                        END IF;

                        /* default new spec_rec with the old one*/
                        l_spec_test_rec.spec_id := l_new_spec_id;

                        FOR get_spec_test IN get_spec_test_by_spec (get_object_rec.object_id) LOOP
                           OPEN get_gmd_test2 (get_spec_test.test_id);
                           FETCH get_gmd_test2 INTO l_gmd_test_rec;
                           CLOSE get_gmd_test2;

                           l_optional_ind := NULL;
                           l_print_spec_ind := NULL;
                           l_print_result_ind := NULL;
                           l_target_value_char := NULL;
                           l_min_value_char := NULL;
                           l_max_value_char := NULL;
                           l_report_precision := NULL;
                           l_store_precision := NULL;
                           l_test_priority := NULL;

                           IF l_new_test_id = l_gmd_test_rec.test_id THEN
                              l_optional_ind := poptional_ind;
                              l_print_spec_ind := pprint_spec_ind;
                              l_print_result_ind := pprint_result_ind;
                              l_target_value_char := ptarget_value;
                              l_min_value_char := ptarget_min;
                              l_max_value_char := ptarget_max;
                              l_report_precision := preport_precision;
                              l_store_precision := pstore_precision;
                              l_test_priority := ptest_priority;
                           END IF;

                           default_spectest_from_spectest (p_from_spec_id         => get_object_rec.object_id
                                                         , p_from_test_id         => l_gmd_test_rec.test_id
                                                         , p_to_test_name         => l_gmd_test_rec.test_code
                                                         , poptional_ind          => l_optional_ind
                                                         , pprint_spec_ind        => l_print_spec_ind
                                                         , pprint_result_ind      => l_print_result_ind
                                                         , ptarget_value          => l_target_value_char
                                                         , ptarget_min            => l_min_value_char
                                                         , ptarget_max            => l_max_value_char
                                                         , preport_precision      => l_report_precision
                                                         , pstore_precision       => l_store_precision
                                                         , ptest_priority         => l_test_priority
                                                         , p_spec_test_rec        => l_spec_test_rec
                                                         , x_return_status        => l_return_status
                                                          );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;

                           default_log (   '  Copying Test: '
                                        || l_gmd_test_rec.test_code
                                        || ' to Spec:'
                                        || get_object_rec.object_name
                                        || ', Version: '
                                        || l_new_spec_vers);

                           add_spec_test_rec (p_spec_id            => l_new_spec_id
                                            , p_test_name          => l_gmd_test_rec.test_code
                                            , p_spec_name          => get_object_rec.object_name
                                            , p_spec_test_rec      => l_spec_test_rec
                                            , x_return_status      => l_return_status
                                             );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;
                        END LOOP;

                        l_new_spec_success := 'Y';
                     END IF;
                  END LOOP; -- spec_tests_rec loop

                  CLOSE l_rec_query;

                  IF l_new_test_id IS NULL THEN
                     default_log (   '  Spec test record NOT EXIST -- Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || ', Test name: '
                                  || pnew_name);
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;
               END IF; -- REPLTESTVAL

               IF get_object_rec.replace_type = 'ADDTEST' THEN
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;
                 /* check to see if the spec_test already exist, if so, abort, no changes */
                  DEBUG ('ADDTEST, new test name: ' || pnew_name);
                  l_exist := 0;

                  OPEN check_spec_test2 (get_object_rec.object_id, pnew_name);
                  FETCH check_spec_test2 INTO l_exist;
                  CLOSE check_spec_test2;

                  IF l_exist = 1 THEN
                     default_log (   '  Spec test record EXIST -- Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || ', Test name: '
                                  || pnew_name);
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;

                  IF (l_new_spec = 'N') THEN   -- Not version controled
                     l_new_spec_id := get_object_rec.object_id;
                  ELSE  -- version controled
                     /* create new version of spec */
                     /* spec only needs to be created once */
                     default_log ('  Version Controlled. Creating New Version of Spec: ' || get_object_rec.object_name);

                     create_new_specification (p_old_spec_id        => get_object_rec.object_id
                                             , p_action_code        => 'NEWVERS'
                                             , x_new_spec_id        => l_new_spec_id
                                             , x_new_spec_vers      => l_new_spec_vers
                                             , x_return_status      => l_return_status
                                              );

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     /* do the loop for all spec tests for the old spec */
                     /* default new spec_rec with the old one*/
                     l_spec_test_rec.spec_id := l_new_spec_id;

                     FOR get_spec_test IN get_spec_test_by_spec (get_object_rec.object_id) LOOP
                        OPEN get_gmd_test2 (get_spec_test.test_id);
                        FETCH get_gmd_test2 INTO l_gmd_test_rec;
                        CLOSE get_gmd_test2;

                        default_spectest_from_spectest (p_from_spec_id         => get_object_rec.object_id
                                                      , p_from_test_id         => l_gmd_test_rec.test_id
                                                      , p_to_test_name         => l_gmd_test_rec.test_code
                                                      , poptional_ind          => NULL
                                                      , pprint_spec_ind        => NULL
                                                      , pprint_result_ind      => NULL
                                                      , ptarget_value          => NULL
                                                      , ptarget_min            => NULL
                                                      , ptarget_max            => NULL
                                                      , preport_precision      => NULL
                                                      , pstore_precision       => NULL
                                                      , ptest_priority         => NULL
                                                      , p_spec_test_rec        => l_spec_test_rec
                                                      , x_return_status        => l_return_status
                                                       );

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                           RAISE NO_UPDATE_EXCEPTION;
                        END IF;

                        default_log (   '  Copying Test: '
                                     || l_gmd_test_rec.test_code
                                     || ' to Spec: '
                                     || get_object_rec.object_name
                                     || ', Version: '
                                     || l_new_spec_vers);

                        add_spec_test_rec (p_spec_id            => l_new_spec_id
                                         , p_test_name          => l_gmd_test_rec.test_code
                                         , p_spec_name          => get_object_rec.object_name
                                         , p_spec_test_rec      => l_spec_test_rec
                                         , x_return_status      => l_return_status
                                          );

                        IF l_return_status <> fnd_api.g_ret_sts_success THEN
                           RAISE NO_UPDATE_EXCEPTION;
                        END IF;
                     END LOOP;

                     l_new_spec_success := 'Y';
                  END IF;

                  /* add the new test  to the spec */
                  default_spectest_from_test (p_spec_id              => l_new_spec_id
                                            , p_test_name            => pnew_name
                                            , poptional_ind          => poptional_ind
                                            , pprint_spec_ind        => pprint_spec_ind
                                            , pprint_result_ind      => pprint_result_ind
                                            , ptarget_value          => ptarget_value
                                            , ptarget_min            => ptarget_min
                                            , ptarget_max            => ptarget_max
                                            , preport_precision      => preport_precision
                                            , pstore_precision       => pstore_precision
                                            , ptest_priority         => ptest_priority
                                            , p_spec_test_rec        => l_spec_test_rec
                                            , x_return_status        => l_return_status
                                             );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;

                  add_spec_test_rec (p_spec_id            => l_new_spec_id
                                   , p_test_name          => pnew_name
                                   , p_spec_name          => get_object_rec.object_name
                                   , p_spec_test_rec      => l_spec_test_rec
                                   , x_return_status      => l_return_status
                                    );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;
               END IF;  --ADDTEST

               IF get_object_rec.replace_type = 'DELTEST' THEN
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;
                  -- DELTEST, spec_test exists
                  -- Go ahead delete it if not version controled
                  IF (l_new_spec = 'N') THEN  -- Not version controled
                     del_spec_test_rec (p_spec_id            => get_object_rec.object_id
                                      , p_spec_name          => get_object_rec.object_name
                                      , p_test_name          => pnew_name
                                      , x_return_status      => l_return_status
                                       );

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;
                  ELSE
                     -- if version controled, add a new spec version and create spec_test records without this test
                     /* create new version of spec */
                     /* spec only needs to be created once */
                     default_log ('  Version Controlled. Creating New Version of Spec: ' || get_object_rec.object_name);

                     create_new_specification (p_old_spec_id        => get_object_rec.object_id
                                             , p_action_code        => 'NEWVERS'
                                             , x_new_spec_id        => l_new_spec_id
                                             , x_new_spec_vers      => l_new_spec_vers
                                             , x_return_status      => l_return_status
                                              );
                     /* do the loop for all spec tests for the old spec */
                     /* default new spec_rec with the old one*/
                     l_spec_test_rec.spec_id := l_new_spec_id;

                     FOR get_spec_test IN get_spec_test_by_spec (get_object_rec.object_id) LOOP
                        OPEN get_gmd_test2 (get_spec_test.test_id);
                        FETCH get_gmd_test2 INTO l_gmd_test_rec;
                        CLOSE get_gmd_test2;

                        IF l_gmd_test_rec.test_id <> TO_NUMBER (pnew_name) THEN /* do not insert the one to be deleted*/
                           default_spectest_from_spectest (p_from_spec_id         => get_object_rec.object_id
                                                         , p_from_test_id         => l_gmd_test_rec.test_id
                                                         , p_to_test_name         => l_gmd_test_rec.test_code
                                                         , poptional_ind          => NULL
                                                         , pprint_spec_ind        => NULL
                                                         , pprint_result_ind      => NULL
                                                         , ptarget_value          => NULL
                                                         , ptarget_min            => NULL
                                                         , ptarget_max            => NULL
                                                         , preport_precision      => NULL
                                                         , pstore_precision       => NULL
                                                         , ptest_priority         => NULL
                                                         , p_spec_test_rec        => l_spec_test_rec
                                                         , x_return_status        => l_return_status
                                                          );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;

                           default_log (   '  Copying Test: '
                                        || l_gmd_test_rec.test_code
                                        || ' to Spec: '
                                        || get_object_rec.object_name
                                        || ', Version: '
                                        || l_new_spec_vers);

                           add_spec_test_rec (p_spec_id            => l_new_spec_id
                                            , p_test_name          => l_gmd_test_rec.test_code
                                            , p_spec_name          => get_object_rec.object_name
                                            , p_spec_test_rec      => l_spec_test_rec
                                            , x_return_status      => l_return_status
                                             );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;
                        END IF;
                     END LOOP;

                     l_new_spec_success := 'Y';
                  END IF;
               END IF;  --DELTEST

               IF get_object_rec.replace_type = 'REPTEST' THEN
                    --RLNAGARA Bug#6017214 Added the below IF condition
                    IF get_object_rec.object_status_code IN (200,500,800,1000)  THEN
                      default_log('Only the Status column for this Obsoleted/Archieved or On-Hold or Request for Approval entity can be replaced');
                      RAISE NO_UPDATE_EXCEPTION;
                    END IF;

                  /* old test is deleted and new ones are created */
                  IF l_new_spec = 'N' THEN
                     l_new_spec_id := get_object_rec.object_id;
                  ELSE
                     -- create new spec version
                     -- create_spec_test for the new version (without the old test, default from the old spectest )
                     -- add new_spec_test (default from the test)
                     /* create new version of spec */
                     /* spec only needs to be created once */
                     default_log ('  Version Controlled. Creating New Version of Spec: ' || get_object_rec.object_name);

                     create_new_specification (p_old_spec_id        => get_object_rec.object_id
                                             , p_action_code        => 'NEWVERS'
                                             , x_new_spec_id        => l_new_spec_id
                                             , x_new_spec_vers      => l_new_spec_vers
                                             , x_return_status      => l_return_status
                                              );

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;

                     /* do the loop for all spec tests for the old spec */
                     /* default new spec_rec with the old one*/
                     l_spec_test_rec.spec_id := l_new_spec_id;

                     FOR get_spec_test IN get_spec_test_by_spec (get_object_rec.object_id) LOOP
                        OPEN get_gmd_test2 (get_spec_test.test_id);
                        FETCH get_gmd_test2 INTO l_gmd_test_rec;
                        CLOSE get_gmd_test2;

                        IF l_gmd_test_rec.test_id <> TO_NUMBER (pold_name) THEN
                           /* do not insert the one to be replaced*/
                           default_spectest_from_spectest (p_from_spec_id         => get_object_rec.object_id
                                                         , p_from_test_id         => l_gmd_test_rec.test_id
                                                         , p_to_test_name         => l_gmd_test_rec.test_code
                                                         , poptional_ind          => NULL
                                                         , pprint_spec_ind        => NULL
                                                         , pprint_result_ind      => NULL
                                                         , ptarget_value          => NULL
                                                         , ptarget_min            => NULL
                                                         , ptarget_max            => NULL
                                                         , preport_precision      => NULL
                                                         , pstore_precision       => NULL
                                                         , ptest_priority         => NULL
                                                         , p_spec_test_rec        => l_spec_test_rec
                                                         , x_return_status        => l_return_status
                                                          );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;

                           default_log (   '  Copying Test: '
                                        || l_gmd_test_rec.test_code
                                        || ' to Spec: '
                                        || get_object_rec.object_name
                                        || ', Version: '
                                        || l_new_spec_vers);

                           add_spec_test_rec (p_spec_id            => l_new_spec_id
                                            , p_test_name          => l_gmd_test_rec.test_code
                                            , p_spec_name          => get_object_rec.object_name
                                            , p_spec_test_rec      => l_spec_test_rec
                                            , x_return_status      => l_return_status
                                             );

                           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                              RAISE NO_UPDATE_EXCEPTION;
                           END IF;
                        END IF;
                     END LOOP;

                     l_new_spec_success := 'Y';
                  END IF;

                  -- init test_values, for REPTEST, the pNew_name is required, so only one record
                  /* take the default from the old spec_test */
                  l_exist := 0;
                  OPEN check_spec_test (get_object_rec.object_id, TO_NUMBER (pold_name));
                  FETCH check_spec_test INTO l_exist;
                  CLOSE check_spec_test;

                  IF l_exist = 0 THEN
                     default_log (   '  Spec test record does NOT exist -- Spec Name: '
                                  || get_object_rec.object_name
                                  || ', Version: '
                                  || get_object_rec.object_vers
                                  || ', test_id: '
                                  || TO_NUMBER (pold_name));
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;

                  -- Bug# 5882074 changed default_spectest_from_spectest to default_spectest_from_test
                  /*default_spectest_from_spectest (p_from_spec_id         => get_object_rec.object_id
                                                , p_from_test_id         => TO_NUMBER (pold_name)
                                                , p_to_test_name         => pnew_name
                                                , poptional_ind          => poptional_ind
                                                , pprint_spec_ind        => pprint_spec_ind
                                                , pprint_result_ind      => pprint_result_ind
                                                , ptarget_value          => ptarget_value
                                                , ptarget_min            => ptarget_min
                                                , ptarget_max            => ptarget_max
                                                , preport_precision      => preport_precision
                                                , pstore_precision       => pstore_precision
                                                , ptest_priority         => ptest_priority
                                                , p_spec_test_rec        => l_spec_test_rec
                                                , x_return_status        => l_return_status
                                                 );*/

                  default_spectest_from_test (p_spec_id              => l_new_spec_id
                                            , p_test_name            => pnew_name
                                            , poptional_ind          => poptional_ind
                                            , pprint_spec_ind        => pprint_spec_ind
                                            , pprint_result_ind      => pprint_result_ind
                                            , ptarget_value          => ptarget_value
                                            , ptarget_min            => ptarget_min
                                            , ptarget_max            => ptarget_max
                                            , preport_precision      => preport_precision
                                            , pstore_precision       => pstore_precision
                                            , ptest_priority         => ptest_priority
                                            , p_spec_test_rec        => l_spec_test_rec
                                            , x_return_status        => l_return_status
                                             );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;

                  -- Bug# 5882074 assign back the sequence from the old test.
                  SELECT seq INTO l_seq
                    FROM gmd_spec_tests_b
                   WHERE spec_id = get_object_rec.object_id
                     AND test_id = TO_NUMBER (pold_name);

                  l_spec_test_rec.seq := l_seq;

                  -- delete the old spec test before adding one
                  IF l_new_spec = 'N' THEN
                     del_spec_test_rec (p_spec_id            => l_new_spec_id
                                      , p_spec_name          => get_object_rec.object_name
                                      , p_test_name          => pold_name
                                      , x_return_status      => l_return_status
                                       );

                     IF l_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE NO_UPDATE_EXCEPTION;
                     END IF;
                  ELSE
                     /* do nothing if 'Y', becasue this record does not exist for the new spec */
                     NULL;
                  END IF;

                  -- Create new spec test
                  add_spec_test_rec (p_spec_id            => l_new_spec_id
                                   , p_test_name          => pnew_name
                                   , p_spec_name          => get_object_rec.object_name
                                   , p_spec_test_rec      => l_spec_test_rec
                                   , x_return_status      => l_return_status
                                    );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;
               END IF; --REPTEST

               /* process validity rules for spec */
               IF (    NVL (l_new_spec_id, 0) <> 0
                   AND NVL (l_new_spec_id, 0) <> get_object_rec.object_id) THEN
                  default_log (   '  Processing Validity Rules For Spec Name: '
                               || get_object_rec.object_name
                               || ', Version: '
                               || get_object_rec.object_vers);

                  process_validity_for_spec (p_object_type        => pobject_type
                                           , p_old_spec_id        => get_object_rec.object_id
                                           , p_new_spec_id        => l_new_spec_id
                                           , x_return_status      => l_return_status
                                            );

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE NO_UPDATE_EXCEPTION;
                  END IF;
               END IF;
            ELSIF pobject_type = 'VALIDITY' THEN
               /* Replace type could be one of the following
                * REPSTART, REPEND, REPSTATUS
                * Update the validity rule for the spec with the new values
                */
               l_start_date := NULL;
               l_end_date := NULL;
               l_new_status := NULL;

               IF get_object_rec.replace_type = 'REPSTART' THEN
                  l_start_date := fnd_date.canonical_to_date (pnew_name);
               ELSIF get_object_rec.replace_type = 'REPEND' THEN
                  l_end_date := fnd_date.canonical_to_date (pnew_name);
               ELSIF get_object_rec.replace_type = 'REPSTATUS' THEN
                  l_new_status := TO_NUMBER (pnew_name);
               END IF;

               default_log (   '  Processing Validity Rules For Spec Name: '
                            || get_object_rec.object_name
                            || ', Version: '
                            || get_object_rec.object_vers);

               process_validity_for_spec (p_object_type        => pobject_type
                                        , p_spec_vr_id         => get_object_rec.object_id
                                        , p_end_date           => l_end_date
                                        , p_start_date         => l_start_date
                                        , p_new_status         => l_new_status
                                        , x_return_status      => l_return_status
                                         );

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE NO_UPDATE_EXCEPTION;
               END IF;
            END IF; -- If specification or validity
         EXCEPTION
            WHEN NO_UPDATE_EXCEPTION THEN
               IF pobject_type = 'SPECIFICATION' THEN
                  default_log (   'No Replacement for Spec Name: '
                               || get_object_rec.object_name
                               || ', Version: '
                               || get_object_rec.object_vers);
               ELSIF pobject_type = 'VALIDITY' THEN
                  default_log (   'No Replacement for Validity Rules of Spec Name: '
                               || get_object_rec.object_name
                               || ', Version: '
                               || get_object_rec.object_vers);
               END IF;

               DEBUG ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
               ROLLBACK TO SAVEPOINT mass_replace_for_one;
               DEBUG ('Rollback to the savepoint');
            WHEN OTHERS THEN
               IF pobject_type = 'SPECIFICATION' THEN
                  default_log (   'No Replacement for Spec Name: '
                               || get_object_rec.object_name
                               || ', Version: '
                               || get_object_rec.object_vers);
               ELSIF pobject_type = 'VALIDITY' THEN
                  default_log (   'No Replacement for Validity Rules of Spec Name: '
                               || get_object_rec.object_name
                               || ', Version: '
                               || get_object_rec.object_vers);
               END IF;

               DEBUG ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
               default_log ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
               ROLLBACK TO SAVEPOINT mass_replace_for_one;
               DEBUG ('Rollback to the savepoint');
         END; -- End created to handle exception for each record
      END LOOP; -- For all rows that needs to be replaced

      -- If MSNR was successful until here then
      -- Delete rows specific to this concurrent id
      IF (pconcurrent_id IS NOT NULL) THEN
         DELETE FROM gmd_msnr_results
               WHERE concurrent_id = TO_NUMBER (pconcurrent_id);
         COMMIT;
      END IF;

      -- There were no row selected for replace raise an error
      IF (l_rowcount = 0) THEN
         fnd_message.set_name ('GMD', 'GMD_CONC_NO_ROW_FOUND');
         RAISE NO_REPLACE_EXCEPTION;
      END IF;

      DEBUG (   g_pkg_name
             || '.'
             || l_api_name
             || 'Completed '
             || l_api_name
             || ' at '
             || TO_CHAR (SYSDATE, 'MM/DD/YYYY HH24:MI:SS'));
   EXCEPTION
      -- this exception occurs when no rows were selected for update.
      WHEN NO_REPLACE_EXCEPTION THEN
         fnd_msg_pub.get (p_msg_index          => 1
                        , p_data               => l_error_text
                        , p_encoded            => 'F'
                        , p_msg_index_out      => l_dummy_cnt
                         );
         --ret_code := 2;
         --err_buf := NULL;
         l_retval := fnd_concurrent.set_completion_status ('WARNING', l_error_text);

         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ' : In the No_replace_exception section '
                                || ' Error text is '
                                || l_error_text);
         END IF;

         fnd_file.put (fnd_file.LOG, fnd_message.get);
         fnd_file.new_line (fnd_file.LOG, 1);
      -- outer excepption handles all error that occur prior to or after
      -- Mass updates (or within LOOP above)
      WHEN OTHERS THEN
         --ret_code := 2;
         --err_buf := NULL;
         l_retval := fnd_concurrent.set_completion_status ('WARNING', SQLERRM);
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         fnd_message.set_name ('GMD', 'GMD_CONC_UPDATE_OBJECT_FAILED');
         fnd_message.set_token ('REPLACE_TYPE', preplace_type);

         IF (preplace_type = 'INGREDIENT') THEN
            fnd_message.set_token ('REPLACE_VALUE', pnew_name);
         ELSE
            fnd_message.set_token ('REPLACE_VALUE', pnew_name);
         END IF;

         fnd_message.set_token ('OBJECT_TYPE', pobject_type);
         fnd_message.set_token ('ERRMSG', SQLERRM);
         fnd_file.put (fnd_file.LOG, fnd_message.get);
         fnd_file.new_line (fnd_file.LOG, 1);
   END mass_replace_oper_spec_val;

   /* PROCEDURE default_spectest_from_test
      This procedure default the spec_test record from the test user wants to add
    */
   PROCEDURE default_spectest_from_test (
      p_spec_id           IN              NUMBER
    , p_test_name         IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , p_spec_test_rec     IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      l_gmd_test_rec      gmd_qc_tests_b%ROWTYPE;
      l_spec_test_rec     gmd_spec_tests_b%ROWTYPE;
      l_test_values_rec   gmd_qm_conc_replace_pkg.test_values;
      l_seq               NUMBER;

      CURSOR get_gmd_test (p_test_name IN VARCHAR2) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_code = p_test_name;

      -- Bug# 5882074 get the char test values
      CURSOR get_char_test_values (p_test_id IN VARCHAR2, p_num_value IN NUMBER) IS
         SELECT value_char
           FROM gmd_qc_test_values
          WHERE test_id = p_test_id
            AND text_range_seq = p_num_value;


	 --Begin smalluru Bug#6415285
  found                 Number;
  l_value_char          VARCHAR2(16);
  l_text_range_seq  	NUMBER;
  l_seq_min		        NUMBER :=0;
  l_seq_max		        NUMBER :=0;
  l_seq_target		    NUMBER :=0;

  Cursor List_of_values_tests Is
  select VALUE_CHAR from gmd_qc_test_values
  where test_id = l_gmd_test_rec.test_id;

  Cursor text_range_tests Is
  select text_range_seq, VALUE_CHAR from gmd_qc_test_values
  where test_id = l_gmd_test_rec.test_id;

  --End smalluru Bug#6415285

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN get_gmd_test (p_test_name);
      FETCH get_gmd_test INTO l_gmd_test_rec;
      CLOSE get_gmd_test;

      /* init the l_test_values_rec */
      l_test_values_rec.optional_ind := NULL;
      l_test_values_rec.print_spec_ind := NULL;
      l_test_values_rec.print_result_ind := NULL;
      l_test_values_rec.target_value_num := NULL;
      l_test_values_rec.target_value_char := NULL;
      l_test_values_rec.max_value_char := NULL;
      l_test_values_rec.min_value_char := NULL;

      DEBUG ('Default test values from test :' || p_test_name);
      l_test_values_rec.max_value_num := l_gmd_test_rec.max_value_num;
      l_test_values_rec.min_value_num := l_gmd_test_rec.min_value_num;
      l_test_values_rec.report_precision := l_gmd_test_rec.report_precision;
      l_test_values_rec.store_precision := l_gmd_test_rec.display_precision;
      l_test_values_rec.test_priority := l_gmd_test_rec.priority;

      -- Bug# 5882074 get the char values.

      IF l_gmd_test_rec.test_type = 'T' THEN
         OPEN get_char_test_values(l_gmd_test_rec.test_id, l_gmd_test_rec.max_value_num);
         FETCH get_char_test_values INTO l_test_values_rec.max_value_char;
         CLOSE get_char_test_values;

         OPEN get_char_test_values(l_gmd_test_rec.test_id, l_gmd_test_rec.min_value_num);
         FETCH get_char_test_values INTO l_test_values_rec.min_value_char;
         CLOSE get_char_test_values;
      END IF;

      /* replace with the value defined on the screen */
      set_test_values (p_gmd_test_rec         => l_gmd_test_rec
                     , poptional_ind          => poptional_ind
                     , pprint_spec_ind        => pprint_spec_ind
                     , pprint_result_ind      => pprint_result_ind
                     , ptarget_value          => ptarget_value
                     , ptarget_min            => ptarget_min
                     , ptarget_max            => ptarget_max
                     , preport_precision      => preport_precision
                     , pstore_precision       => pstore_precision
                     , ptest_priority         => ptest_priority
                     , x_return_status        => x_return_status
                     , x_test_values_rec      => l_test_values_rec
                      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

           -- Begin smalluru Bug#6415285.
     -- Validating the values entered in target, min and max fields
    If l_gmd_test_rec.test_type in ('N','E','L') Then
     If (nvl(l_test_values_rec.max_value_num,0) > nvl(l_gmd_test_rec.max_value_num,0) )
      OR (nvl(l_test_values_rec.min_value_num,0) < nvl(l_gmd_test_rec.min_value_num,0) )
      OR (nvl(l_test_values_rec.min_value_num,0) > nvl(l_gmd_test_rec.max_value_num,0) )
      OR (nvl(l_test_values_rec.target_value_num,0) NOT BETWEEN
      nvl(l_test_values_rec.min_value_num,0) AND nvl(l_test_values_rec.max_value_num,0)) Then
      -- raise an error for this record, abort!
              default_log('  Target values are out of range, '
                    ||' Target Value: '||l_test_values_rec.target_value_num
                    ||' Target Max: '||l_test_values_rec.max_value_num
                    ||' Target Min: '||l_test_values_rec.min_value_num);
              raise FND_API.G_EXC_ERROR;
      End if;
     Elsif l_gmd_test_rec.test_type = 'T' then

     open text_range_tests;
     LOOP
        fetch text_range_tests into l_text_range_seq,l_value_char;
        Exit when text_range_tests%NOTFOUND;
        if l_test_values_rec.min_value_char IS NULL then
            l_test_values_rec.min_value_char := l_value_char;
            l_seq_min := l_text_range_seq;
        end if;
        if upper(l_test_values_rec.min_value_char) = upper(l_value_char) then
	       l_seq_min := l_text_range_seq;
	    elsif upper(l_test_values_rec.max_value_char) = upper(l_value_char) then
	       l_seq_max := l_text_range_seq;
	    elsif upper(l_test_values_rec.target_value_char) = upper(l_value_char) then
	       l_seq_target := l_text_range_seq;
	    end if;
     END LOOP;

     if text_range_tests%IsOpen then
        close text_range_tests;
     end if;
     if l_test_values_rec.max_value_char IS NULL then
        l_test_values_rec.max_value_char := l_value_char;
        l_seq_max := l_text_range_seq;
     end if;

     if l_seq_max < l_seq_min OR (l_test_values_rec.target_value_char IS NOT NULL
       AND l_seq_target NOT BETWEEN l_seq_min AND l_seq_max) OR (l_seq_max =0 AND
       l_test_values_rec.max_value_char IS NOT NULL) OR (l_seq_min =0 AND
       l_test_values_rec.min_value_char IS NOT NULL) OR (l_seq_target =0 AND
       l_test_values_rec.target_value_char IS NOT NULL) then

              default_log('  Target values are out of range, '
                      ||' Target Value: '||l_test_values_rec.target_value_char
                      ||' Target Max: '||l_test_values_rec.max_value_char
                      ||' Target Min: '||l_test_values_rec.min_value_char);
              raise FND_API.G_EXC_ERROR;
     end if;

     Elsif l_gmd_test_rec.test_type = 'V' Then
          If l_test_values_rec.target_value_char is null Then
          --Target is required for List of Values Tests.
              default_log('  Target value should not be NULL, '
                    ||' Target Value: '||l_test_values_rec.target_value_char);
              raise FND_API.G_EXC_ERROR;
          else
              found:=0;
              Open List_of_values_tests;
              LOOP
                fetch List_of_values_tests into l_value_char;
                 Exit when List_of_values_tests%NOTFOUND;
                If (upper(l_test_values_rec.target_value_char) = upper(l_value_char)) Then
                    found := 1;
                    close List_of_values_tests;
                    EXIT;
                End if;
              END LOOP;
          If (List_of_values_tests%IsOpen ) Then
                Close List_of_values_tests;
          End If;
          If found = 0 Then
            --Target value is not there in the List of Values
            default_log('  Target value is out of range, '
                    ||' Target Value: '||l_test_values_rec.target_value_char);
            raise FND_API.G_EXC_ERROR;
          End If;

     End if;
    End if;
	--End smalluru Bug#6415285.

      l_seq := 0;
      SELECT MAX (seq) + 10
        INTO l_seq
        FROM gmd_spec_tests_b
       WHERE spec_id = p_spec_id;

      l_spec_test_rec.min_value_char := l_test_values_rec.min_value_char;
      l_spec_test_rec.max_value_char := l_test_values_rec.max_value_char;
      l_spec_test_rec.target_value_char := l_test_values_rec.target_value_char;
      l_spec_test_rec.min_value_num := l_test_values_rec.min_value_num;
      l_spec_test_rec.max_value_num := l_test_values_rec.max_value_num;
      l_spec_test_rec.target_value_num := l_test_values_rec.target_value_num;
      l_spec_test_rec.optional_ind := l_test_values_rec.optional_ind;
      l_spec_test_rec.test_priority := l_test_values_rec.test_priority; -- Bug# 5882074
      l_spec_test_rec.print_spec_ind := l_test_values_rec.print_spec_ind;
      l_spec_test_rec.print_result_ind := l_test_values_rec.print_result_ind;
      l_spec_test_rec.display_precision := l_test_values_rec.store_precision;
      l_spec_test_rec.report_precision := l_test_values_rec.report_precision;
      l_spec_test_rec.spec_id := p_spec_id;
      l_spec_test_rec.test_id := l_gmd_test_rec.test_id;
      l_spec_test_rec.test_method_id := l_gmd_test_rec.test_method_id;
      l_spec_test_rec.seq := l_seq;
      l_spec_test_rec.attribute_category := l_gmd_test_rec.attribute_category;
      l_spec_test_rec.attribute1 := l_gmd_test_rec.attribute1;
      l_spec_test_rec.attribute2 := l_gmd_test_rec.attribute2;
      l_spec_test_rec.attribute3 := l_gmd_test_rec.attribute3;
      l_spec_test_rec.attribute4 := l_gmd_test_rec.attribute4;
      l_spec_test_rec.attribute5 := l_gmd_test_rec.attribute5;
      l_spec_test_rec.attribute6 := l_gmd_test_rec.attribute6;
      l_spec_test_rec.attribute7 := l_gmd_test_rec.attribute7;
      l_spec_test_rec.attribute8 := l_gmd_test_rec.attribute8;
      l_spec_test_rec.attribute9 := l_gmd_test_rec.attribute9;
      l_spec_test_rec.attribute10 := l_gmd_test_rec.attribute10;
      l_spec_test_rec.attribute11 := l_gmd_test_rec.attribute11;
      l_spec_test_rec.attribute12 := l_gmd_test_rec.attribute12;
      l_spec_test_rec.attribute13 := l_gmd_test_rec.attribute13;
      l_spec_test_rec.attribute14 := l_gmd_test_rec.attribute14;
      l_spec_test_rec.attribute15 := l_gmd_test_rec.attribute15;
      l_spec_test_rec.attribute16 := l_gmd_test_rec.attribute16;
      l_spec_test_rec.attribute17 := l_gmd_test_rec.attribute17;
      l_spec_test_rec.attribute18 := l_gmd_test_rec.attribute18;
      l_spec_test_rec.attribute19 := l_gmd_test_rec.attribute19;
      l_spec_test_rec.attribute20 := l_gmd_test_rec.attribute20;
      l_spec_test_rec.attribute21 := l_gmd_test_rec.attribute21;
      l_spec_test_rec.attribute22 := l_gmd_test_rec.attribute22;
      l_spec_test_rec.attribute23 := l_gmd_test_rec.attribute23;
      l_spec_test_rec.attribute24 := l_gmd_test_rec.attribute24;
      l_spec_test_rec.attribute25 := l_gmd_test_rec.attribute25;
      l_spec_test_rec.attribute26 := l_gmd_test_rec.attribute26;
      l_spec_test_rec.attribute27 := l_gmd_test_rec.attribute27;
      l_spec_test_rec.attribute28 := l_gmd_test_rec.attribute28;
      l_spec_test_rec.attribute29 := l_gmd_test_rec.attribute29;
      l_spec_test_rec.attribute30 := l_gmd_test_rec.attribute30;
      l_spec_test_rec.text_code := l_gmd_test_rec.text_code;
      l_spec_test_rec.test_replicate := 1;
      l_spec_test_rec.exp_error_type := l_gmd_test_rec.exp_error_type;
      l_spec_test_rec.below_spec_min := l_gmd_test_rec.below_spec_min;
      l_spec_test_rec.above_spec_min := l_gmd_test_rec.above_spec_min;
      l_spec_test_rec.below_spec_max := l_gmd_test_rec.below_spec_max;
      l_spec_test_rec.above_spec_max := l_gmd_test_rec.above_spec_max;
      l_spec_test_rec.below_min_action_code := l_gmd_test_rec.below_min_action_code;
      l_spec_test_rec.above_min_action_code := l_gmd_test_rec.above_min_action_code;
      l_spec_test_rec.below_max_action_code := l_gmd_test_rec.below_max_action_code;
      l_spec_test_rec.above_max_action_code := l_gmd_test_rec.above_max_action_code;
      --l_spec_test_rec.test_priority := l_gmd_test_rec.priority; -- Bug# 5882074
      l_spec_test_rec.check_result_interval := NULL;
      l_spec_test_rec.out_of_spec_action := NULL;
      l_spec_test_rec.use_to_control_step := NULL;
      l_spec_test_rec.retest_lot_expiry_ind := NULL;
      l_spec_test_rec.print_on_coa_ind := NULL;
      --l_spec_test_rec.test_display             :=    null;
      l_spec_test_rec.from_base_ind := NULL;
      l_spec_test_rec.exclude_ind := NULL;
      l_spec_test_rec.modified_ind := NULL;
      l_spec_test_rec.test_qty := NULL;
      l_spec_test_rec.test_qty_uom := NULL; -- Bug# 5882074 Changed test_uom to test_qty_uom
      l_spec_test_rec.creation_date := NULL;
      l_spec_test_rec.created_by := NULL;
      l_spec_test_rec.last_update_date := NULL;
      l_spec_test_rec.last_updated_by := NULL;
      l_spec_test_rec.last_update_login := NULL;
      l_spec_test_rec.viability_duration := NULL;
      l_spec_test_rec.days := NULL;
      l_spec_test_rec.hours := NULL;
      l_spec_test_rec.minutes := NULL;
      l_spec_test_rec.seconds := NULL;
      l_spec_test_rec.calc_uom_conv_ind := NULL;
      l_spec_test_rec.to_qty_uom := NULL; -- Bug# 5882074 changed to_uom to to_qty_uom
      p_spec_test_rec := l_spec_test_rec;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Default spectest from test result in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Default spectest from test result in Error');
   END default_spectest_from_test;

   PROCEDURE default_spectest_from_spectest (
      p_from_spec_id      IN              NUMBER
    , p_from_test_id      IN              NUMBER
    , p_to_test_name      IN              VARCHAR2
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , p_spec_test_rec     IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      l_from_spec_test_rec   gmd_spec_tests_b%ROWTYPE;
      l_to_spec_test_rec     gmd_spec_tests_b%ROWTYPE;
      l_gmd_test_rec         gmd_qc_tests_b%ROWTYPE;
      l_test_values_rec      gmd_qm_conc_replace_pkg.test_values;
      l_row_id               VARCHAR2 (200);

      CURSOR get_spec_test_rec (p_spec_id IN NUMBER, p_test_id IN NUMBER) IS
         SELECT *
           FROM gmd_spec_tests_b
          WHERE spec_id = p_spec_id
            AND test_id = p_test_id;

      CURSOR get_test_rec (p_test_name IN VARCHAR2) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_code = p_test_name;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN get_spec_test_rec (p_from_spec_id, p_from_test_id);
      FETCH get_spec_test_rec INTO l_from_spec_test_rec;
      CLOSE get_spec_test_rec;

      DEBUG (   'In default from spectest , load from spec_test_rec, spec_id '
             || l_from_spec_test_rec.spec_id
             || ' test_id '
             || l_from_spec_test_rec.test_id);

      OPEN get_test_rec (p_to_test_name);
      FETCH get_test_rec INTO l_gmd_test_rec;
      CLOSE get_test_rec;

      DEBUG (   'In default from spectest , load test_rec '
             || l_gmd_test_rec.test_code
             || ' test_id:'
             || l_gmd_test_rec.test_id);

      init_test_values_rec (
           p_spec_tests_rec       => l_from_spec_test_rec
         , x_test_values_rec => l_test_values_rec);

      DEBUG ('default from spectest , after init test values');
      /* replace with the value defined on the screen */
      set_test_values (p_gmd_test_rec         => l_gmd_test_rec
                     , poptional_ind          => poptional_ind
                     , pprint_spec_ind        => pprint_spec_ind
                     , pprint_result_ind      => pprint_result_ind
                     , ptarget_value          => ptarget_value
                     , ptarget_min            => ptarget_min
                     , ptarget_max            => ptarget_max
                     , preport_precision      => preport_precision
                     , pstore_precision       => pstore_precision
                     , ptest_priority         => ptest_priority
                     , x_return_status        => x_return_status
                     , x_test_values_rec      => l_test_values_rec
                      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      DEBUG ('default from spectest , after set test values');
      l_to_spec_test_rec := l_from_spec_test_rec;
      l_to_spec_test_rec.min_value_char := l_test_values_rec.min_value_char;
      l_to_spec_test_rec.min_value_num := l_test_values_rec.min_value_num;
      l_to_spec_test_rec.target_value_num := l_test_values_rec.target_value_num;
      l_to_spec_test_rec.max_value_num := l_test_values_rec.max_value_num;
      l_to_spec_test_rec.print_spec_ind := l_test_values_rec.print_spec_ind;
      l_to_spec_test_rec.print_result_ind := l_test_values_rec.print_result_ind;
      l_to_spec_test_rec.max_value_char := l_test_values_rec.max_value_char;
      l_to_spec_test_rec.optional_ind := l_test_values_rec.optional_ind;
      l_to_spec_test_rec.display_precision := l_test_values_rec.store_precision;
      l_to_spec_test_rec.report_precision := l_test_values_rec.report_precision;
      l_to_spec_test_rec.target_value_char := l_test_values_rec.target_value_char;
      l_to_spec_test_rec.test_id := l_gmd_test_rec.test_id;
      p_spec_test_rec := l_to_spec_test_rec;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Default spectest from spectest result in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Default spectest from spectest result in Error');
   END default_spectest_from_spectest;

   PROCEDURE set_test_values (
      p_gmd_test_rec      IN              gmd_qc_tests_b%ROWTYPE
    , poptional_ind       IN              VARCHAR2 DEFAULT NULL
    , pprint_spec_ind     IN              VARCHAR2 DEFAULT NULL
    , pprint_result_ind   IN              VARCHAR2 DEFAULT NULL
    , ptarget_value       IN              VARCHAR2 DEFAULT NULL
    , ptarget_min         IN              VARCHAR2 DEFAULT NULL
    , ptarget_max         IN              VARCHAR2 DEFAULT NULL
    , preport_precision   IN              VARCHAR2 DEFAULT NULL
    , pstore_precision    IN              VARCHAR2 DEFAULT NULL
    , ptest_priority      IN              VARCHAR2 DEFAULT NULL
    , x_return_status     OUT NOCOPY      VARCHAR2
    , x_test_values_rec   IN OUT NOCOPY   gmd_qm_conc_replace_pkg.test_values
   ) IS
      l_optional_ind        gmd_spec_tests_b.optional_ind%TYPE;
      l_print_spec_ind      gmd_spec_tests_b.print_spec_ind%TYPE;
      l_print_result_ind    gmd_spec_tests_b.print_result_ind%TYPE;
      l_target_value_num    gmd_spec_tests_b.target_value_num%TYPE;
      l_target_value_char   gmd_spec_tests_b.target_value_char%TYPE;
      l_min_value_num       gmd_spec_tests_b.min_value_num%TYPE;
      l_min_value_char      gmd_spec_tests_b.min_value_char%TYPE;
      l_max_value_num       gmd_spec_tests_b.max_value_num%TYPE;
      l_max_value_char      gmd_spec_tests_b.max_value_char%TYPE;
      l_report_precision    gmd_spec_tests_b.report_precision%TYPE;
      l_store_precision     gmd_spec_tests_b.display_precision%TYPE;
      l_test_priority       gmd_spec_tests_b.test_priority%TYPE;
      l_gmd_test_rec        gmd_qc_tests_b%ROWTYPE;
      l_test_values_rec     gmd_qm_conc_replace_pkg.test_values;

      l_precision VARCHAR2(50);  --RLNAGARA Bug 6972284
      l_min_max_target NUMBER;  --RLNAGARA Bug 6972284

      --Bug#6415285 commented the below cursor
	  -- Bug# 5882074 get the char test values
    /*  CURSOR get_char_test_values (p_test_id IN VARCHAR2, p_num_value IN NUMBER) IS
         SELECT value_char
           FROM gmd_qc_test_values
          WHERE test_id = p_test_id
            AND text_range_seq = p_num_value;
	*/


   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      /* lookup code for test type GMD_QC_TEST_DATE_TYPE
       * U -- Non-Validated
       * N -- Numeric Range
       * V -- List of Test Values
       * T -- Text Range
       * L -- Numeric Range with Display Text
       * E -- Expression
       */
      l_test_values_rec := x_test_values_rec;
      l_gmd_test_rec := p_gmd_test_rec;
      l_optional_ind := l_test_values_rec.optional_ind;
      l_print_spec_ind := l_test_values_rec.print_spec_ind;
      l_print_result_ind := l_test_values_rec.print_result_ind;
     -- l_report_precision := l_test_values_rec.report_precision; Commented in Bug No.9095034
     -- l_store_precision := l_test_values_rec.store_precision;  Commented in Bug No.9095034
      l_report_precision := l_gmd_test_rec.report_precision;
      l_store_precision := l_gmd_test_rec.display_precision;
      l_target_value_num := l_test_values_rec.target_value_num;
      l_max_value_num := l_test_values_rec.max_value_num;
      l_min_value_num := l_test_values_rec.min_value_num;
      l_target_value_char := l_test_values_rec.target_value_char;
      l_max_value_char := l_test_values_rec.max_value_char;
      l_min_value_char := l_test_values_rec.min_value_char;
      l_test_priority := l_test_values_rec.test_priority;
      DEBUG (' Procecure Set_test_values');
      DEBUG (' test_rec.test_type ' || l_gmd_test_rec.test_type);

      IF l_gmd_test_rec.test_type IN ('N', 'L', 'E') THEN
         IF ptarget_value IS NOT NULL THEN
            l_target_value_num := TO_NUMBER (ptarget_value);
         END IF;

         IF ptarget_max IS NOT NULL THEN
            l_max_value_num := TO_NUMBER (ptarget_max);
         END IF;

         IF ptarget_max IS NOT NULL THEN
            l_min_value_num := TO_NUMBER (ptarget_min);
         END IF;

         l_target_value_char := NULL;
         l_max_value_char := NULL;
         l_min_value_char := NULL;
      -- Bug# 5882074 changed the following condition
      --ELSIF l_gmd_test_rec.test_type = 'V' THEN
      ELSIF l_gmd_test_rec.test_type in ('V', 'U') THEN
         l_target_value_num := NULL;
         l_max_value_num := NULL;
         l_min_value_num := NULL;

         IF ptarget_value IS NOT NULL THEN
            l_target_value_char := ptarget_value;
         END IF;

         l_max_value_char := NULL;
         l_min_value_char := NULL;

		--Bug#6415285 Commented the below code as ptarget_value,ptarget_max and ptarget_min come as character values
		-- for Text range (T) type tests and no need to fetch them separately.

      -- Bug 5882074 Added the following elseif and commented the else
    /*  ELSIF l_gmd_test_rec.test_type = 'T' THEN
         debug('sup ptarget_value'||ptarget_value);
		 IF ptarget_value IS NOT NULL THEN

            l_target_value_num := TO_NUMBER (ptarget_value);
            OPEN get_char_test_values(l_gmd_test_rec.test_id, l_target_value_num);
            FETCH get_char_test_values INTO l_target_value_char;
            CLOSE get_char_test_values;
         END IF;
          debug('sup ptarget_max'||ptarget_max);
         IF ptarget_max IS NOT NULL THEN
            l_max_value_num := TO_NUMBER (ptarget_max);
            OPEN get_char_test_values(l_gmd_test_rec.test_id, l_max_value_num);
            FETCH get_char_test_values INTO l_max_value_char;
            CLOSE get_char_test_values;
         END IF;
         debug('sup ptarget_min'||ptarget_min);
         IF ptarget_min IS NOT NULL THEN --replaced target with min
            l_min_value_num := TO_NUMBER (ptarget_min);
            OPEN get_char_test_values(l_gmd_test_rec.test_id, l_min_value_num);
            FETCH get_char_test_values INTO l_min_value_char;
            CLOSE get_char_test_values;
         END IF;    */
      ELSE
         IF ptarget_value IS NOT NULL THEN
            l_target_value_char := ptarget_value;
         END IF;

         IF ptarget_max IS NOT NULL THEN
            l_max_value_char := ptarget_max;
         END IF;

         IF ptarget_min IS NOT NULL THEN
            l_min_value_char := ptarget_min;
         END IF;

         l_target_value_num := NULL;
         l_max_value_num := NULL;
         l_min_value_num := NULL;
      END IF;

      IF poptional_ind IS NOT NULL THEN
         l_optional_ind := poptional_ind;
      END IF;

      IF (    (poptional_ind IS NOT NULL)
          AND poptional_ind = 'N') THEN
         l_optional_ind := NULL;
      END IF;

      IF pprint_spec_ind IS NOT NULL THEN
         l_print_spec_ind := pprint_spec_ind;
      END IF;

      IF pprint_result_ind IS NOT NULL THEN
         l_print_result_ind := pprint_result_ind;
      END IF;

      --RLNAGARA start Bug 6972284 validation of the test precision
       IF (preport_precision  > pstore_precision) THEN
          default_log (   'The Report Precision cannot be greater then the Display Precision.'
	               || ' Report Precision: '
		       || preport_precision
		       || ' Display Precision: '
		       || pstore_precision);
          RAISE fnd_api.g_exc_error;
       ELSIF (pstore_precision > l_store_precision) THEN
          default_log (   'Display precision for Spec test cannot be greater than the display precision specified in the test definition.'
	               || ' Display Precision in Spec test: '
		       || pstore_precision
		       || ' Display Precision in test: '
		       || l_store_precision);
	  RAISE fnd_api.g_exc_error;
       ELSIF (preport_precision  > l_report_precision) THEN
          default_log (   'Report precision for Spec test cannot be greater than the report precision specified in the test definition.'
	               || ' Report Precision in Spec test: '
		       || preport_precision
		       || ' Report Precision in test: '
		       || l_report_precision);
	  RAISE fnd_api.g_exc_error;
       END IF;

      --RLNAGARA end Bug 6972284

      IF preport_precision IS NOT NULL THEN
         l_report_precision := preport_precision;
      END IF;

      IF pstore_precision IS NOT NULL THEN
         l_store_precision := pstore_precision;
      END IF;

      --RLNAGARA start Bug 6972284 After Validation set the precision to the min,max and target values.
      IF l_gmd_test_rec.test_type IN ('N', 'L', 'E') THEN
        IF (l_store_precision IS NOT NULL AND l_store_precision <> 0) THEN
	    l_precision := '999999999999999D'||to_char(power(10,l_store_precision)-1);
	    l_min_max_target := l_target_value_num;
            l_target_value_num :=ltrim(to_char(to_number(l_min_max_target),l_precision));
            l_min_max_target := l_min_value_num;
            l_min_value_num :=ltrim(to_char(to_number(l_min_max_target),l_precision));
            l_min_max_target := l_max_value_num;
            l_max_value_num :=ltrim(to_char(to_number(l_min_max_target),l_precision));
	END IF;
      END IF;
      --RLNAGARA end Bug 6972284

      IF ptest_priority IS NOT NULL THEN
         l_test_priority := ptest_priority;
      END IF;

      l_test_values_rec.optional_ind := l_optional_ind;
      l_test_values_rec.print_spec_ind := l_print_spec_ind;
      l_test_values_rec.print_result_ind := l_print_result_ind;
      l_test_values_rec.report_precision := l_report_precision;
      l_test_values_rec.store_precision := l_store_precision;
      l_test_values_rec.target_value_num := l_target_value_num;
      l_test_values_rec.max_value_num := l_max_value_num;
      l_test_values_rec.min_value_num := l_min_value_num;
      l_test_values_rec.target_value_char := l_target_value_char;
      l_test_values_rec.max_value_char := l_max_value_char;
      l_test_values_rec.min_value_char := l_min_value_char;
      l_test_values_rec.test_priority := l_test_priority;

      /* need to validate the min max for the test, no changes made if exceeds the max*/
      -- Bug# 5882074 Added additional if condition to check for target_value_num and changed the existing if
      IF l_test_values_rec.target_value_num IS NOT NULL THEN
         --IF    (NVL (l_test_values_rec.target_value_num, 0) > NVL (l_test_values_rec.max_value_num, 0))
         --   OR (NVL (l_test_values_rec.target_value_num, 0) < NVL (l_test_values_rec.min_value_num, 0)) THEN
         IF   l_test_values_rec.target_value_num > l_test_values_rec.max_value_num
           OR l_test_values_rec.target_value_num < l_test_values_rec.min_value_num THEN
            -- raise an error for this record, abort!
            default_log (   '  Target value is out of range '
                         || ' Target Value: '
                         || l_test_values_rec.target_value_num
                         || ' Target Max: '
                         || l_test_values_rec.max_value_num
                         || ' Target Min: '
                         || l_test_values_rec.min_value_num);
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF NVL (l_test_values_rec.min_value_num, 0) > NVL (l_test_values_rec.max_value_num, 0) THEN
         -- raise an error for this record, abort!
         default_log (   '  Target min value is out of range '
                      || ' Target Value: '
                      || l_test_values_rec.target_value_num
                      || ' Target Max: '
                      || l_test_values_rec.max_value_num
                      || ' Target Min: '
                      || l_test_values_rec.min_value_num);
         RAISE fnd_api.g_exc_error;
      END IF;

      x_test_values_rec := l_test_values_rec;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Set Test Values result in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Set Test Values result in Error');
   END set_test_values;

   /*###############################################################
    # NAME
    #   create_new_specification
    # SYNOPSIS
    #   create_new_specification
    # DESCRIPTION
    #    Create a row in gmd_specifications_b with the default (input)
    #    values
    # p_action_code can be
    #   -- 'NEWVERS', new version
    ###############################################################*/
   PROCEDURE create_new_specification (
      p_old_spec_id     IN              NUMBER
    , p_action_code     IN              VARCHAR2
    , x_new_spec_id     OUT NOCOPY      NUMBER
    , x_new_spec_vers   OUT NOCOPY      NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_old_spec_rec       gmd_specifications%ROWTYPE;
      l_new_spec_rec       gmd_specifications%ROWTYPE;
      l_version            gmd_specifications.spec_vers%TYPE;
      l_spec_id            gmd_specifications.spec_id%TYPE;
      l_default_spec_sts   gmd_specifications.spec_status%TYPE;
      l_manage_vr_ind      VARCHAR2 (1);
      l_row_id             VARCHAR2 (200);

      CURSOR get_spec_rec (p_spec_id IN NUMBER) IS
         SELECT *
           FROM gmd_specifications
          WHERE spec_id = p_spec_id;

      -- Bug# 5882074 Changed orgn_code to orgn_id
      CURSOR get_default_status (p_orgn_id IN NUMBER) IS
         SELECT default_specification_status
              , manage_validity_rules_ind
           FROM gmd_quality_config
          WHERE organization_id = p_orgn_id;

      CURSOR get_vrs_rec (p_spec_id IN NUMBER) IS
         SELECT spec_vr_status
           FROM gmd_all_spec_vrs_vl
          WHERE spec_id = p_spec_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG ('In creat_new_specification, old_spec_id ' || p_old_spec_id);
      OPEN get_spec_rec (p_old_spec_id);
      FETCH get_spec_rec INTO l_old_spec_rec;
      CLOSE get_spec_rec;

      DEBUG ('In creat_new_specification, spec_name ' || l_old_spec_rec.spec_name);
      l_default_spec_sts := NULL;

      /* search for the configuration rules to default the status */
       /* lookup code for manage_validity_rules_ind
        * lookup type 'GMD_QM_MANAGING_VALIDITY_RULES'
        * lookup code 'C' -- Copy
        *             'E' -- Copy and Set End Date for Old Rules
        *             'O' -- Copy and Set Obsolete Status for Old Rules
        *             'Z' -- Do Not Create
        */
      -- Bug# 5882074 Changed code to id
      OPEN get_default_status (l_old_spec_rec.owner_organization_id);
      FETCH get_default_status INTO l_default_spec_sts, l_manage_vr_ind;
      CLOSE get_default_status;

      IF l_default_spec_sts IS NULL THEN
         default_log ('  Default Spec Status is not set to crete new specification');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF     l_manage_vr_ind IN ('E', 'O')
         AND l_default_spec_sts <> 100 THEN
         FOR validity_rules IN get_vrs_rec (l_old_spec_rec.spec_id) LOOP
            IF validity_rules.spec_vr_status IN (200, 500) THEN
               default_log (   '  With the value of Manage Validity Rules, the Default Spec Status should NOT be '
                            || l_default_spec_sts);
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;

      l_new_spec_rec := l_old_spec_rec;
      l_new_spec_rec.spec_status := l_default_spec_sts;
      DEBUG ('In creat_new_specification, new_spec_name: ' || l_new_spec_rec.spec_name);

      IF (p_action_code = 'NEWVERS') THEN                                                        -- create a new version
         SELECT MAX (spec_vers) + 1
           INTO l_new_spec_rec.spec_vers
           FROM gmd_specifications
          WHERE spec_name = l_old_spec_rec.spec_name;
      ELSE
         NULL;
      END IF;

      insert_new_spec_rec (p_spec_rec           => l_new_spec_rec
                         , x_new_spec_id        => x_new_spec_id
                         , x_return_status      => x_return_status
                          );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      x_new_spec_vers := l_new_spec_rec.spec_vers;

      default_log (   '  New Specification Version created '
                   || '  Spec Name: '
                   || l_new_spec_rec.spec_name
                   || '  Spec Version: '
                   || l_new_spec_rec.spec_vers
                   || '  Spec Id: '
                   || x_new_spec_id);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Create New Specification result in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Create New Specification result in Error');
   END create_new_specification;

   PROCEDURE insert_new_spec_rec (
      p_spec_rec        IN              gmd_specifications%ROWTYPE
    , x_new_spec_id     OUT NOCOPY      NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_new_spec_rec   gmd_specifications%ROWTYPE;
      l_spec_id        gmd_specifications.spec_id%TYPE;
      l_row_id         VARCHAR2 (200);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_new_spec_rec := p_spec_rec;
      DEBUG ('Inserting new version of the spec: ' || l_new_spec_rec.spec_name);
      DEBUG ('Inserting new version of the spec ver: ' || l_new_spec_rec.spec_vers);

      GMD_SPECIFICATIONS_PVT.INSERT_ROW
         (   x_rowid                      => l_row_id
           , x_spec_id                    => l_spec_id
           , x_spec_name                  => l_new_spec_rec.spec_name
           , x_spec_vers                  => l_new_spec_rec.spec_vers
           , x_inventory_item_id          => l_new_spec_rec.inventory_item_id /* Bug# 5882074 */
           , x_revision                   => l_new_spec_rec.revision      /* Bug# 5882074 */
           , x_grade_code                 => l_new_spec_rec.grade_code    /* Bug# 5882074 */
           , x_spec_status                => l_new_spec_rec.spec_status
           , x_overlay_ind                => l_new_spec_rec.overlay_ind
           , x_spec_type                  => l_new_spec_rec.spec_type
           , x_base_spec_id               => l_new_spec_rec.base_spec_id
           , x_owner_organization_id      => l_new_spec_rec.owner_organization_id /* Bug# 5882074 */
           , x_owner_id                   => l_new_spec_rec.owner_id
           , x_sample_inv_trans_ind       => l_new_spec_rec.sample_inv_trans_ind
           , x_delete_mark                => l_new_spec_rec.delete_mark
           , x_text_code                  => l_new_spec_rec.text_code
           , x_attribute_category         => l_new_spec_rec.attribute_category
           , x_attribute1                 => l_new_spec_rec.attribute1
           , x_attribute2                 => l_new_spec_rec.attribute2
           , x_attribute3                 => l_new_spec_rec.attribute3
           , x_attribute4                 => l_new_spec_rec.attribute4
           , x_attribute5                 => l_new_spec_rec.attribute5
           , x_attribute6                 => l_new_spec_rec.attribute6
           , x_attribute7                 => l_new_spec_rec.attribute7
           , x_attribute8                 => l_new_spec_rec.attribute8
           , x_attribute9                 => l_new_spec_rec.attribute9
           , x_attribute10                => l_new_spec_rec.attribute10
           , x_attribute11                => l_new_spec_rec.attribute11
           , x_attribute12                => l_new_spec_rec.attribute12
           , x_attribute13                => l_new_spec_rec.attribute13
           , x_attribute14                => l_new_spec_rec.attribute14
           , x_attribute15                => l_new_spec_rec.attribute15
           , x_attribute16                => l_new_spec_rec.attribute16
           , x_attribute17                => l_new_spec_rec.attribute17
           , x_attribute18                => l_new_spec_rec.attribute18
           , x_attribute19                => l_new_spec_rec.attribute19
           , x_attribute20                => l_new_spec_rec.attribute20
           , x_attribute21                => l_new_spec_rec.attribute21
           , x_attribute22                => l_new_spec_rec.attribute22
           , x_attribute23                => l_new_spec_rec.attribute23
           , x_attribute24                => l_new_spec_rec.attribute24
           , x_attribute25                => l_new_spec_rec.attribute25
           , x_attribute26                => l_new_spec_rec.attribute26
           , x_attribute27                => l_new_spec_rec.attribute27
           , x_attribute28                => l_new_spec_rec.attribute28
           , x_attribute29                => l_new_spec_rec.attribute29
           , x_attribute30                => l_new_spec_rec.attribute30
           , x_spec_desc                  => l_new_spec_rec.spec_desc
           , x_creation_date              => l_new_spec_rec.creation_date
           , x_created_by                 => l_new_spec_rec.created_by
           , x_last_update_date           => l_new_spec_rec.last_update_date
           , x_last_updated_by            => l_new_spec_rec.last_updated_by
           , x_last_update_login          => l_new_spec_rec.last_update_login
        );

      x_new_spec_id := l_spec_id;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Insert New spec rec result in Error');
   END insert_new_spec_rec;

   /* add spec_test record for the test with p_test_name to spec_id
       pNew_ind   default 'N' = New, create spec_test taking default from this test (p_test_name)
                  'C' = Copy, create spec_test taking default from old spec test
    */
   PROCEDURE add_spec_test_rec (
      p_spec_id         IN              NUMBER
    , p_test_name       IN              VARCHAR2
    , p_spec_name       IN              VARCHAR2
    , p_spec_test_rec   IN OUT NOCOPY   gmd_spec_tests_b%ROWTYPE
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_spec_test_rec   gmd_spec_tests_b%ROWTYPE;
      l_gmd_test_rec    gmd_qc_tests_b%ROWTYPE;
      l_exist           NUMBER;
      l_seq             NUMBER;
      l_return_status   VARCHAR2 (1);
      l_check           BOOLEAN;

      CURSOR get_gmd_test (p_test_name IN VARCHAR2) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_code = p_test_name;

      CURSOR check_spec_test (p_spec_id IN NUMBER, p_test_name IN VARCHAR2) IS
         SELECT 1
           FROM gmd_spec_tests_b sptst
              , gmd_qc_tests_b tst
          WHERE sptst.spec_id = p_spec_id
            AND sptst.test_id = tst.test_id
            AND tst.test_code = p_test_name;

      CURSOR find_nonexp_spec_test (p_spec_id IN NUMBER) IS
         SELECT t.test_code
              , t.test_id
              , t.expression
           FROM gmd_spec_tests_b s
              , gmd_qc_tests_b t
          WHERE s.spec_id = p_spec_id
            AND s.test_id = t.test_id
            AND t.test_type <> 'E';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_exist := 0;
      l_spec_test_rec := p_spec_test_rec;
      l_spec_test_rec.spec_id := p_spec_id;

      DEBUG ('In Add_spec_test_rec, spec_id: ' || p_spec_id);
      DEBUG ('In Add_spec_test_rec, spec_name: ' || p_spec_name);
      DEBUG ('In Add_spec_test_rec, test_name: ' || p_test_name);

      /* check to see if this test is an expression and tests with this expression exist in this spec*/
      OPEN get_gmd_test (p_test_name);
      FETCH get_gmd_test INTO l_gmd_test_rec;
      CLOSE get_gmd_test;

      IF l_gmd_test_rec.test_type = 'E' THEN  -- it is an expression
         DEBUG (   'Test to be added is an expression type, Test Name:'
                || p_test_name
                || ' Expression:'
                || l_gmd_test_rec.expression);

         FOR spec_test_rec IN find_nonexp_spec_test (p_spec_id) LOOP
            l_check := is_test_in_expression (
                              p_expression         => l_gmd_test_rec.expression
                            , p_test_name          => spec_test_rec.test_code
                            , x_return_status      => x_return_status
                       );

            IF (NOT l_check) THEN
               default_log ('  Test (' || p_test_name || ') Expression contains test(s) which are not in this spec');
               RAISE fnd_api.g_exc_error;
            END IF;

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;

      OPEN check_spec_test (p_spec_id, p_test_name);
      FETCH check_spec_test INTO l_exist;
      CLOSE check_spec_test;

      DEBUG ('In Add_spec_test_rec, does the new test exist in spec_test? ' || l_exist);

      IF l_exist = 0 THEN
         DEBUG ('new spec_test.test_id:' || l_spec_test_rec.test_id);
         DEBUG ('new spec_test.seq:' || l_spec_test_rec.seq);

         IF (l_spec_test_rec.optional_ind = 'N') THEN
            l_spec_test_rec.optional_ind := NULL;
         END IF;

         DEBUG ('Inserting new optional_ind: ' || l_spec_test_rec.optional_ind);
         insert_spec_test_rec (p_spec_test_rec      => l_spec_test_rec, x_return_status => x_return_status);

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         default_log (   '  Created spec test record : '
                      || p_test_name
                      || ' to Spec: '
                      || p_spec_name
                      || ' Spec Id: '
                      || p_spec_id);
      ELSE
         -- ADDTEST but spec test exists, throw out an error msg
         default_log (   '  Spec Test Already Exits -- Can not add Test, '
                      || 'Spec Name: '
                      || p_spec_name
                      || ' '
                      || 'Test Name: '
                      || p_test_name);
         DEBUG (' ADDTEST: Spec Test already exists');
      END IF;                                                                                         -- exist spec_test
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Create New Spectest result in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Create New Spectest result in Error');
   END add_spec_test_rec;

   /* delete spec_test record for the test with p_test_name to spec_id
    */
   PROCEDURE del_spec_test_rec (
      p_spec_id         IN              NUMBER
    , p_spec_name       IN              VARCHAR2
    , p_test_name       IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_gmd_test_rec      gmd_qc_tests_b%ROWTYPE;
      l_exist             NUMBER;
      l_test_values_rec   gmd_qm_conc_replace_pkg.test_values;
      l_seq               NUMBER;
      l_return_status     VARCHAR2 (1);

      CURSOR get_gmd_test (p_test_name IN VARCHAR2) IS
         SELECT *
           FROM gmd_qc_tests_b
          WHERE test_id = TO_NUMBER (p_test_name);

      CURSOR check_spec_test (p_spec_id IN NUMBER, p_test_id IN NUMBER) IS
         SELECT 1
           FROM gmd_spec_tests_b
          WHERE spec_id = p_spec_id
            AND test_id = p_test_id;

      CURSOR find_exp_spec_test (p_spec_id IN NUMBER) IS
         SELECT t.test_code
              , t.test_id
              , t.expression
           FROM gmd_spec_tests_b s
              , gmd_qc_tests_b t
          WHERE s.spec_id = p_spec_id
            AND s.test_id = t.test_id
            AND t.test_type = 'E';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN get_gmd_test (p_test_name);
      FETCH get_gmd_test INTO l_gmd_test_rec;
      CLOSE get_gmd_test;

      DEBUG ('In del_spec_test_rec, test_name:' || p_test_name);

      /* check to see if this test is included in an expression for this spec*/
      IF l_gmd_test_rec.test_type <> 'E' THEN
         FOR spec_test_rec IN find_exp_spec_test (p_spec_id) LOOP
            DEBUG (   '  Expression are found within the spec. Test Name:'
                   || spec_test_rec.test_code
                   || ' Expression:'
                   || spec_test_rec.expression);

            IF is_test_in_expression (p_expression         => spec_test_rec.expression
                                    , p_test_name          => p_test_name
                                    , x_return_status      => x_return_status
                                     ) THEN
               default_log ('  Test ' || p_test_name || ' is used in an expression within the spec');
               RAISE fnd_api.g_exc_error;
            END IF;

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;

      /* check to see if spec_test already exists*/
      l_exist := 0;
      OPEN check_spec_test (p_spec_id, l_gmd_test_rec.test_id);
      FETCH check_spec_test INTO l_exist;
      CLOSE check_spec_test;

      IF l_exist = 1 THEN
         DEBUG (' get_gmd_test1 with name, test_id ' || l_gmd_test_rec.test_id);
         -- DELTEST, spec_test exists
         -- Go ahead delete it if not version controled
         default_log (   '  Deleting spec test record '
                      || 'Spec Name: '
                      || p_spec_name
                      || ' '
                      || 'Test Name: '
                      || l_gmd_test_rec.test_code);

         DELETE gmd_spec_tests_b
          WHERE spec_id = p_spec_id
            AND test_id = l_gmd_test_rec.test_id;
      ELSE
         -- DELTEST but spec_test does NOT exist, throw out an error msg
         default_log (   '  Spec Test Does Not Exits for Deleting, '
                      || 'Spec Name: '
                      || p_spec_name
                      || ' '
                      || 'Test Name: '
                      || l_gmd_test_rec.test_code);
         DEBUG (' DELTEST: Spec Test NOT exists');
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Delete spec test error ' || SQLERRM);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Delete spec test error ' || SQLERRM);
   END del_spec_test_rec;

   PROCEDURE init_test_values_rec (
      p_spec_tests_rec    IN              gmd_spec_tests_b%ROWTYPE
    , x_test_values_rec   IN OUT NOCOPY   gmd_qm_conc_replace_pkg.test_values
   ) IS
   BEGIN
      x_test_values_rec.optional_ind := p_spec_tests_rec.optional_ind;
      x_test_values_rec.print_spec_ind := p_spec_tests_rec.print_spec_ind;
      x_test_values_rec.print_result_ind := p_spec_tests_rec.print_result_ind;
      x_test_values_rec.report_precision := p_spec_tests_rec.report_precision;
      x_test_values_rec.store_precision := p_spec_tests_rec.display_precision;
      x_test_values_rec.target_value_num := p_spec_tests_rec.target_value_num;
      x_test_values_rec.max_value_num := p_spec_tests_rec.max_value_num;
      x_test_values_rec.min_value_num := p_spec_tests_rec.min_value_num;
      x_test_values_rec.target_value_char := p_spec_tests_rec.target_value_char;
      x_test_values_rec.max_value_char := p_spec_tests_rec.max_value_char;
      x_test_values_rec.min_value_char := p_spec_tests_rec.min_value_char;
      x_test_values_rec.test_priority := p_spec_tests_rec.test_priority;
   END init_test_values_rec;

   PROCEDURE insert_spec_test_rec (
      p_spec_test_rec IN gmd_spec_tests_b%ROWTYPE
    , x_return_status OUT NOCOPY VARCHAR2
   ) IS
      l_spec_test_rec   gmd_spec_tests_b%ROWTYPE;
      l_row_id          VARCHAR2 (200);
   BEGIN
      l_spec_test_rec := p_spec_test_rec;
      DEBUG ('Inserting spec test rec ');

      GMD_SPEC_TESTS_PVT.INSERT_ROW (
            x_rowid                        => l_row_id
          , x_spec_id                      => l_spec_test_rec.spec_id
          , x_test_id                      => l_spec_test_rec.test_id
          , x_attribute1                   => l_spec_test_rec.attribute1
          , x_attribute2                   => l_spec_test_rec.attribute2
          , x_min_value_char               => l_spec_test_rec.min_value_char
          , x_test_method_id               => l_spec_test_rec.test_method_id
          , x_seq                          => l_spec_test_rec.seq
          , x_from_base_ind                => l_spec_test_rec.from_base_ind
          , x_exclude_ind                  => l_spec_test_rec.exclude_ind
          , x_modified_ind                 => l_spec_test_rec.modified_ind
          , x_test_qty                     => l_spec_test_rec.test_qty
          , x_test_qty_uom                 => l_spec_test_rec.test_qty_uom   /* Bug# 5882074 */
          , x_min_value_num                => l_spec_test_rec.min_value_num
          , x_target_value_num             => l_spec_test_rec.target_value_num
          , x_max_value_num                => l_spec_test_rec.max_value_num
          , x_attribute5                   => l_spec_test_rec.attribute5
          , x_attribute6                   => l_spec_test_rec.attribute6
          , x_attribute7                   => l_spec_test_rec.attribute7
          , x_attribute8                   => l_spec_test_rec.attribute8
          , x_attribute9                   => l_spec_test_rec.attribute9
          , x_attribute10                  => l_spec_test_rec.attribute10
          , x_attribute11                  => l_spec_test_rec.attribute11
          , x_attribute12                  => l_spec_test_rec.attribute12
          , x_attribute13                  => l_spec_test_rec.attribute13
          , x_attribute14                  => l_spec_test_rec.attribute14
          , x_attribute15                  => l_spec_test_rec.attribute15
          , x_attribute16                  => l_spec_test_rec.attribute16
          , x_attribute17                  => l_spec_test_rec.attribute17
          , x_attribute18                  => l_spec_test_rec.attribute18
          , x_use_to_control_step          => l_spec_test_rec.use_to_control_step
          , x_print_spec_ind               => l_spec_test_rec.print_spec_ind
          , x_print_result_ind             => l_spec_test_rec.print_result_ind
          , x_text_code                    => l_spec_test_rec.text_code
          , x_attribute_category           => l_spec_test_rec.attribute_category
          , x_attribute3                   => l_spec_test_rec.attribute3
          , x_retest_lot_expiry_ind        => l_spec_test_rec.retest_lot_expiry_ind
          , x_attribute19                  => l_spec_test_rec.attribute19
          , x_attribute20                  => l_spec_test_rec.attribute20
          , x_max_value_char               => l_spec_test_rec.max_value_char
          , x_test_replicate               => l_spec_test_rec.test_replicate
          , x_check_result_interval        => l_spec_test_rec.check_result_interval
          , x_out_of_spec_action           => l_spec_test_rec.out_of_spec_action
          , x_exp_error_type               => l_spec_test_rec.exp_error_type
          , x_below_spec_min               => l_spec_test_rec.below_spec_min
          , x_above_spec_min               => l_spec_test_rec.above_spec_min
          , x_below_spec_max               => l_spec_test_rec.below_spec_max
          , x_above_spec_max               => l_spec_test_rec.above_spec_max
          , x_below_min_action_code        => l_spec_test_rec.below_min_action_code
          , x_above_min_action_code        => l_spec_test_rec.above_min_action_code
          , x_below_max_action_code        => l_spec_test_rec.below_max_action_code
          , x_above_max_action_code        => l_spec_test_rec.above_max_action_code
          , x_optional_ind                 => l_spec_test_rec.optional_ind
          , x_display_precision            => l_spec_test_rec.display_precision
          , x_report_precision             => l_spec_test_rec.report_precision
          , x_test_priority                => l_spec_test_rec.test_priority
          , x_print_on_coa_ind             => l_spec_test_rec.print_on_coa_ind
          , x_target_value_char            => l_spec_test_rec.target_value_char
          , x_attribute4                   => l_spec_test_rec.attribute4
          , x_attribute21                  => l_spec_test_rec.attribute21
          , x_attribute22                  => l_spec_test_rec.attribute22
          , x_attribute23                  => l_spec_test_rec.attribute23
          , x_attribute24                  => l_spec_test_rec.attribute24
          , x_attribute25                  => l_spec_test_rec.attribute25
          , x_attribute26                  => l_spec_test_rec.attribute26
          , x_attribute27                  => l_spec_test_rec.attribute27
          , x_attribute28                  => l_spec_test_rec.attribute28
          , x_attribute29                  => l_spec_test_rec.attribute29
          , x_attribute30                  => l_spec_test_rec.attribute30
          , x_test_display                 => NULL            --l_to_spec_test_rec.test_display
          , x_creation_date                => NULL
          , x_created_by                   => NULL
          , x_last_update_date             => NULL
          , x_last_updated_by              => NULL
          , x_last_update_login            => NULL
          , x_viability_duration           => l_spec_test_rec.viability_duration
          , x_test_expiration_days         => l_spec_test_rec.days
          , x_test_expiration_hours        => l_spec_test_rec.hours
          , x_test_expiration_minutes      => l_spec_test_rec.minutes
          , x_test_expiration_seconds      => l_spec_test_rec.seconds
          , x_calc_uom_conv_ind            => l_spec_test_rec.calc_uom_conv_ind
          , x_to_qty_uom                   => l_spec_test_rec.to_qty_uom     /* Bug# 5882074 */
      );
   EXCEPTION
      WHEN OTHERS THEN
         gmd_debug.put_line ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END insert_spec_test_rec;

   /* p_object_type, indicates it is spec or validity rules */
   PROCEDURE process_validity_for_spec (
      p_object_type     IN              VARCHAR2
    , p_old_spec_id     IN              NUMBER DEFAULT NULL
    , p_new_spec_id     IN              NUMBER DEFAULT NULL
    , p_spec_vr_id      IN              NUMBER DEFAULT NULL
    , p_end_date        IN              DATE DEFAULT NULL
    , p_start_date      IN              DATE DEFAULT NULL
    , p_new_status      IN              NUMBER DEFAULT NULL
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_old_spec_rec        gmd_specifications_b%ROWTYPE;
      l_new_spec_rec        gmd_specifications_b%ROWTYPE;
      l_cust_spec_vrs       gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs        gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs        gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs   gmd_supplier_spec_vrs%ROWTYPE;
      l_row_id              VARCHAR2 (200);
      l_vr_id               NUMBER;
      l_manage_vr_ind       VARCHAR2 (1);
      l_spec_type           VARCHAR2 (1);
      l_create_mode         VARCHAR2 (1);
      l_default_status      NUMBER;
      l_spec_status         NUMBER;

      -- Bug# 5882074 changed code to id
      CURSOR get_manage_validity (p_orgn_id IN NUMBER) IS
         SELECT manage_validity_rules_ind
              , default_specification_status
           FROM gmd_quality_config
          WHERE organization_id = p_orgn_id;

      CURSOR get_spec_rec (p_spec_id IN NUMBER) IS
         SELECT *
           FROM gmd_specifications_b
          WHERE spec_id = p_spec_id;

      -- Bug# 5882074 changed code to id
      CURSOR get_vrs_rec (p_spec_id IN NUMBER, p_spec_name IN VARCHAR2, p_orgn_id IN NUMBER) IS
         SELECT spec_vr_id
              , spec_type
              , spec_vr_status
           FROM gmd_all_spec_vrs_vl
          WHERE spec_id = p_spec_id
            AND spec_name = p_spec_name
            AND owner_organization_id = p_orgn_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN get_spec_rec (p_old_spec_id);
      FETCH get_spec_rec INTO l_old_spec_rec;
      CLOSE get_spec_rec;
      DEBUG ('after get spec rec ');

      -- Bug# 5882074 changed code to id
      OPEN get_manage_validity (l_old_spec_rec.owner_organization_id);
      FETCH get_manage_validity INTO l_manage_vr_ind, l_default_status;
      CLOSE get_manage_validity;
      DEBUG ('after get manage validity ' || l_old_spec_rec.owner_organization_id);

      l_vr_id := NULL;
      IF p_object_type = 'SPECIFICATION' THEN
         -- Bug# 5882074 changed code to id
         FOR validity_rule IN get_vrs_rec (l_old_spec_rec.spec_id
                                         , l_old_spec_rec.spec_name
                                         , l_old_spec_rec.owner_organization_id
                                          ) LOOP
            l_vr_id := validity_rule.spec_vr_id;
            l_spec_type := validity_rule.spec_type;
            DEBUG ('get validity rule ' || l_vr_id);
            DEBUG ('get validity rule, spec_type ' || l_spec_type);
            /* get the vr record for different types */

            /* lookup code for manage_validity_rules_ind
             * lookup type 'GMD_QM_MANAGING_VALIDITY_RULES'
             * lookup code 'C' -- Copy
             *             'E' -- Copy and Set End Date for Old Rules
             *             'O' -- Copy and Set Obsolete Status for Old Rules
             *             'Z' -- Do Not Create
             */
            DEBUG ('p_new_spec_id ' || p_new_spec_id);
            DEBUG ('l_manage_vr_ind ' || l_manage_vr_ind);

            OPEN get_spec_rec (p_new_spec_id);
            FETCH get_spec_rec INTO l_new_spec_rec;
            CLOSE get_spec_rec;

            IF l_manage_vr_ind IN ('C', 'E', 'O') THEN
               l_create_mode := '';

               IF    l_manage_vr_ind = 'C'
                  OR l_default_status = 100 THEN
                  l_spec_status := 100;
                  l_create_mode := 'R';
               ELSIF (    (   l_manage_vr_ind = 'O'
                           OR l_manage_vr_ind = 'E')
                      AND l_new_spec_rec.spec_status >= validity_rule.spec_vr_status
                     ) THEN
                  l_create_mode := '';
               ELSIF (    (   l_manage_vr_ind = 'O'
                           OR l_manage_vr_ind = 'E')
                      AND validity_rule.spec_vr_status > l_default_status
                     ) THEN
                  l_create_mode := 'R';
                  l_spec_status := l_default_status;
               END IF;

               copy_validity_rule (p_from_vr_id         => l_vr_id
                                 , p_to_spec_id         => p_new_spec_id
                                 , p_spec_status        => l_spec_status
                                 , p_spec_type          => l_spec_type
                                 , p_create_mode        => l_create_mode
                                 , x_return_status      => x_return_status
                                  );

               IF x_return_status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF l_manage_vr_ind = 'E' THEN
                  end_old_validity_rule (p_vr_id              => l_vr_id
                                       , p_spec_type          => l_spec_type
                                       , x_return_status      => x_return_status
                                        );

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               ELSIF l_manage_vr_ind = 'O' THEN
                  obsolete_old_validity_rule (p_vr_id              => l_vr_id
                                            , p_spec_type          => l_spec_type
                                            , x_return_status      => x_return_status
                                             );

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
            ELSIF l_manage_vr_ind = 'Z' THEN
               NULL; -- do nothing
            ELSE -- not defined in config
               default_log (   '  Configuration for Manage Validity rule is not defined for Org: '
                            || l_old_spec_rec.owner_organization_id);
            END IF;
         END LOOP;

         IF l_vr_id IS NULL THEN
            default_log ('  No Validity Rules found ');
         END IF;
      ELSIF p_object_type = 'VALIDITY' THEN
         l_vr_id := p_spec_vr_id;

         SELECT spec_type
           INTO l_spec_type
           FROM gmd_all_spec_vrs_vl
          WHERE spec_vr_id = l_vr_id;

         update_validity_rule (p_vr_id              => l_vr_id
                             , p_spec_type          => l_spec_type
                             , p_end_date           => p_end_date
                             , p_start_date         => p_start_date
                             , p_new_status         => p_new_status
                             , x_return_status      => x_return_status
                              );

         IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Process validity for spec results in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Process validity for spec results in Error');
   END process_validity_for_spec;

   /* p_create_mode is 'R', replace the old spec_status with passed in p_spec_status */
   PROCEDURE copy_validity_rule (
      p_from_vr_id      IN              NUMBER
    , p_to_spec_id      IN              NUMBER
    , p_spec_status     IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , p_create_mode     IN              VARCHAR2
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_cust_spec_vrs_in        gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs_in         gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs_in         gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs_in    gmd_supplier_spec_vrs%ROWTYPE;
      l_cust_spec_vrs_out       gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs_out        gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs_out        gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs_out   gmd_supplier_spec_vrs%ROWTYPE;
      l_row_id                  VARCHAR2 (200);
      l_spec_vr_id              NUMBER;
      l_manage_vr_ind           VARCHAR2 (1);
      l_spec_type               VARCHAR2 (1);
      l_return                  BOOLEAN;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_spec_type := p_spec_type;
      l_spec_vr_id := p_from_vr_id;
      DEBUG ('in copy validity rule, vr id: ' || l_spec_vr_id);
      DEBUG ('in copy validity rule, to_spec_id: ' || p_to_spec_id);
      DEBUG ('in copy validity rule, p_spec_status:' || p_spec_status);
      DEBUG ('in copy validity rule, spec type: ' || l_spec_type);
      DEBUG ('in copy validity rule, p_create_mode: ' || p_create_mode);

      IF l_spec_type = 'C' THEN
         SELECT *
           INTO l_cust_spec_vrs_in
           FROM gmd_customer_spec_vrs
          WHERE spec_vr_id = l_spec_vr_id;

         l_cust_spec_vrs_in.spec_id := p_to_spec_id;

         IF p_create_mode = 'R' THEN
            l_cust_spec_vrs_in.spec_vr_status := p_spec_status;
         END IF;

         l_cust_spec_vrs_in.spec_vr_id := NULL;
         default_log ('    Copy From Cusotmer Validity Rule: ' || l_spec_vr_id);
         l_return := gmd_customer_spec_vrs_pvt.insert_row
                (  p_customer_spec_vrs      => l_cust_spec_vrs_in
                 , x_customer_spec_vrs      => l_cust_spec_vrs_out );

         default_log ('    Created New Cusotmer Validity Rule: ' || l_cust_spec_vrs_out.spec_vr_id);
      ELSIF l_spec_type = 'I' THEN
         SELECT *
           INTO l_inv_spec_vrs_in
           FROM gmd_inventory_spec_vrs
          WHERE spec_vr_id = l_spec_vr_id;

         l_inv_spec_vrs_in.spec_id := p_to_spec_id;
         DEBUG ('l_inv_spec_vrs.spec_id: ' || l_inv_spec_vrs_in.spec_id);

         IF p_create_mode = 'R' THEN
            l_inv_spec_vrs_in.spec_vr_status := p_spec_status;
         END IF;

         l_inv_spec_vrs_in.spec_vr_id := NULL;
         DEBUG ('l_inv_spec_vrs.spec_vr_status: ' || l_inv_spec_vrs_in.spec_vr_status);
         default_log ('    Copy From Inventory Validity Rule: ' || l_spec_vr_id);
         l_return := gmd_inventory_spec_vrs_pvt.insert_row
                (   p_inventory_spec_vrs      => l_inv_spec_vrs_in
                  , x_inventory_spec_vrs      => l_inv_spec_vrs_out );

         --debug('call insert row for inventory validity rule, l_return '|| to_char(l_return));
         default_log ('    Created New Inventory Validity Rule: ' || l_inv_spec_vrs_out.spec_vr_id);
      ELSIF l_spec_type = 'W' THEN
         SELECT *
           INTO l_wip_spec_vrs_in
           FROM gmd_wip_spec_vrs
          WHERE spec_vr_id = l_spec_vr_id;

         l_wip_spec_vrs_in.spec_id := p_to_spec_id;

         IF p_create_mode = 'R' THEN
            l_wip_spec_vrs_in.spec_vr_status := p_spec_status;
         END IF;

         l_wip_spec_vrs_in.spec_vr_id := NULL;
         default_log ('    Copy From WIP Validity Rule: ' || l_spec_vr_id);
         l_return := gmd_wip_spec_vrs_pvt.insert_row
                 (  p_wip_spec_vrs      => l_wip_spec_vrs_in
                  , x_wip_spec_vrs      => l_wip_spec_vrs_out );

         default_log ('    Created New WIP Validity Rule: ' || l_wip_spec_vrs_out.spec_vr_id);
      ELSIF l_spec_type = 'S' THEN
         SELECT *
           INTO l_supplier_spec_vrs_in
           FROM gmd_supplier_spec_vrs
          WHERE spec_vr_id = l_spec_vr_id;

         l_supplier_spec_vrs_in.spec_id := p_to_spec_id;

         IF p_create_mode = 'R' THEN
            l_supplier_spec_vrs_in.spec_vr_status := p_spec_status;
         END IF;

         l_supplier_spec_vrs_in.spec_vr_id := NULL;
         default_log ('    Copy From Supplier Validity Rule: ' || l_spec_vr_id);
         l_return := gmd_supplier_spec_vrs_pvt.insert_row
                (  p_supplier_spec_vrs      => l_supplier_spec_vrs_in
                 , x_supplier_spec_vrs      => l_supplier_spec_vrs_out);

         default_log ('    Created New Supplier Validity Rule: ' || l_supplier_spec_vrs_out.spec_vr_id);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Process validity for spec results in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Process validity for spec results in Error');
   END copy_validity_rule;

   PROCEDURE end_old_validity_rule (
      p_vr_id         IN              NUMBER
    , p_spec_type     IN              VARCHAR2
    , x_return_status OUT NOCOPY      VARCHAR2
   ) IS
      l_cust_spec_vrs       gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs        gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs        gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs   gmd_supplier_spec_vrs%ROWTYPE;
      l_row_id              VARCHAR2 (200);
      l_spec_vr_id          NUMBER;
      l_manage_vr_ind       VARCHAR2 (1);
      l_spec_type           VARCHAR2 (1);
      l_return              BOOLEAN;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_spec_type := p_spec_type;
      l_spec_vr_id := p_vr_id;
      DEBUG ('in End_old_validity_rule, spec_Type ' || l_spec_type);

      IF l_spec_type = 'C' THEN
         UPDATE gmd_customer_spec_vrs
            SET end_date = SYSDATE
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    End Customer Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'I' THEN
         UPDATE gmd_inventory_spec_vrs
            SET end_date = SYSDATE
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    End Inventory Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'W' THEN
         UPDATE gmd_wip_spec_vrs
            SET end_date = SYSDATE
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    End WIP Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'S' THEN
         UPDATE gmd_supplier_spec_vrs
            SET end_date = SYSDATE
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    End Supplier Validity Rule: ' || l_spec_vr_id);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('End validity rule results in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('End validity rule results in Error');
   END end_old_validity_rule;

   PROCEDURE obsolete_old_validity_rule (
      p_vr_id         IN               NUMBER
    , p_spec_type     IN               VARCHAR2
    , x_return_status OUT NOCOPY       VARCHAR2
   ) IS
      l_cust_spec_vrs       gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs        gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs        gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs   gmd_supplier_spec_vrs%ROWTYPE;
      l_row_id              VARCHAR2 (200);
      l_spec_vr_id          NUMBER;
      l_manage_vr_ind       VARCHAR2 (1);
      l_spec_type           VARCHAR2 (1);
      l_return              BOOLEAN;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_spec_type := p_spec_type;
      l_spec_vr_id := p_vr_id;
      DEBUG ('in Obsolete_old_validity_rule, spec_Type ' || l_spec_type);

      IF l_spec_type = 'C' THEN
         UPDATE gmd_customer_spec_vrs
            SET spec_vr_status = 1000
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    Obsolete Customer Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'I' THEN
         UPDATE gmd_inventory_spec_vrs
            SET spec_vr_status = 1000
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    Obsolete Inventory Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'W' THEN
         UPDATE gmd_wip_spec_vrs
            SET spec_vr_status = 1000
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    Obsolete WIP Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'S' THEN
         UPDATE gmd_supplier_spec_vrs
            SET spec_vr_status = 1000
          WHERE spec_vr_id = l_spec_vr_id;

         default_log ('    Obsolete Supplier Validity Rule: ' || l_spec_vr_id);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Obsolete validity for spec results in Error');
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Obsolete validity for spec results in Error');
   END obsolete_old_validity_rule;

   PROCEDURE update_validity_rule (
      p_vr_id           IN              NUMBER
    , p_spec_type       IN              VARCHAR2
    , p_end_date        IN              DATE
    , p_start_date      IN              DATE
    , p_new_status      IN              NUMBER
    , x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_cust_spec_vrs       gmd_customer_spec_vrs%ROWTYPE;
      l_inv_spec_vrs        gmd_inventory_spec_vrs%ROWTYPE;
      l_wip_spec_vrs        gmd_wip_spec_vrs%ROWTYPE;
      l_supplier_spec_vrs   gmd_supplier_spec_vrs%ROWTYPE;
      l_row_id              VARCHAR2 (200);
      l_spec_vr_id          NUMBER;
      l_manage_vr_ind       VARCHAR2 (1);
      l_spec_type           VARCHAR2 (1);
      l_spec_status         NUMBER;
      l_return              BOOLEAN;

      CURSOR get_spec_status (p_vr_id IN NUMBER) IS
         SELECT spec_status
           FROM gmd_all_spec_vrs_vl
          WHERE spec_vr_id = p_vr_id;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_spec_type := p_spec_type;
      l_spec_vr_id := p_vr_id;
      DEBUG ('In Update_validity_rule, validity_rule_id ' || l_spec_vr_id);
      DEBUG ('In Update_validity_rule, spec_type ' || l_spec_type);
      DEBUG ('In Update_validity_rule, end_date ' || p_end_date);
      DEBUG ('In Update_validity_rule, start_date ' || p_start_date);
      DEBUG ('In Update_validity_rule, new_status ' || p_new_status);

      /* check the spec status, the new validity rule status can NOT be higher
       * than the spec status */
      OPEN get_spec_status (l_spec_vr_id);
      FETCH get_spec_status INTO l_spec_status;
      CLOSE get_spec_status;

      IF l_spec_status < p_new_status THEN
         default_log (   '  New Status ('
                      || p_new_status
                      || ') for Validity Rule '
                      || 'Can Not Be Higher than the Spec Status ('
                      || l_spec_status
                      || ')');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_spec_type = 'C' THEN
         IF p_new_status IS NOT NULL THEN
            UPDATE gmd_customer_spec_vrs
               SET spec_vr_status = p_new_status
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_start_date IS NOT NULL THEN
            UPDATE gmd_customer_spec_vrs
               SET start_date = p_start_date
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_end_date IS NOT NULL THEN
            UPDATE gmd_customer_spec_vrs
               SET end_date = p_end_date
             WHERE spec_vr_id = l_spec_vr_id;
         END IF;

         default_log ('    Updated Customer Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'I' THEN
         IF p_new_status IS NOT NULL THEN
            UPDATE gmd_inventory_spec_vrs
               SET spec_vr_status = p_new_status
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_start_date IS NOT NULL THEN
            UPDATE gmd_inventory_spec_vrs
               SET start_date = p_start_date
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_end_date IS NOT NULL THEN
            UPDATE gmd_inventory_spec_vrs
               SET end_date = p_end_date
             WHERE spec_vr_id = l_spec_vr_id;
         END IF;

         default_log ('    Updated Inventory Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'W' THEN
         IF p_new_status IS NOT NULL THEN
            UPDATE gmd_wip_spec_vrs
               SET spec_vr_status = p_new_status
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_start_date IS NOT NULL THEN
            UPDATE gmd_wip_spec_vrs
               SET start_date = p_start_date
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_end_date IS NOT NULL THEN
            UPDATE gmd_wip_spec_vrs
               SET end_date = p_end_date
             WHERE spec_vr_id = l_spec_vr_id;
         END IF;

         default_log ('    Updated WIP Validity Rule: ' || l_spec_vr_id);
      ELSIF l_spec_type = 'S' THEN
         IF p_new_status IS NOT NULL THEN
            UPDATE gmd_supplier_spec_vrs
               SET spec_vr_status = p_new_status
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_start_date IS NOT NULL THEN
            UPDATE gmd_supplier_spec_vrs
               SET start_date = p_start_date
             WHERE spec_vr_id = l_spec_vr_id;
         ELSIF p_end_date IS NOT NULL THEN
            UPDATE gmd_supplier_spec_vrs
               SET end_date = p_end_date
             WHERE spec_vr_id = l_spec_vr_id;
         END IF;

         default_log ('    Updated Supplier Validity Rule: ' || l_spec_vr_id);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Update validity for spec results in Error');
         DEBUG ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         default_log ('Update validity for spec results in Error');
         DEBUG ('sqlerror  ' || SUBSTRB (SQLERRM, 1, 100));
   END update_validity_rule;

   FUNCTION is_test_in_expression (
      p_expression    IN                VARCHAR2
    , p_test_name     IN                VARCHAR2
    , x_return_status OUT NOCOPY        VARCHAR2
   ) RETURN BOOLEAN IS
      l_exptab    gmd_utility_pkg.exptab;
      l_boolean   BOOLEAN                := FALSE;
      i           NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      DEBUG (' In is_test_in_expression, expression: ' || p_expression);
      DEBUG (' In is_test_in_expression, test_name: ' || p_test_name);
      gmd_utility_pkg.parse (x_exp                => p_expression
                           , x_exptab             => l_exptab
                           , x_return_status      => x_return_status
                            );

      FOR i IN 1 .. l_exptab.COUNT LOOP
         DEBUG (' In is_test_in_expression, exptab: ' || l_exptab (i).poperand || 'value:' || l_exptab (i).pvalue);

         IF p_test_name = l_exptab (i).poperand THEN
            RETURN TRUE;
         END IF;
      END LOOP;

      RETURN FALSE;
   END is_test_in_expression;

END GMD_QM_CONC_REPLACE_PKG;

/

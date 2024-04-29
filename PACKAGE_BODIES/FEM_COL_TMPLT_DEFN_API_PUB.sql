--------------------------------------------------------
--  DDL for Package Body FEM_COL_TMPLT_DEFN_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COL_TMPLT_DEFN_API_PUB" AS
/* $Header: FEMCOLTMPLTB.pls 120.10 2006/06/01 17:38:28 ssthiaga noship $ */

    --------------------------------------------
    -- get_alias returns an alias for a table --
    -- Ex: Input: FEM_COMMERCIAL_LOANS
    --    Output: FCL
    --------------------------------------------


    FUNCTION get_alias(p_tab_name IN VARCHAR2,
                       p_alias IN VARCHAR2 )

    RETURN VARCHAR2 IS

      l_alias    VARCHAR2(10);
      l_tab_name VARCHAR2(30);

    BEGIN

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.get_alias(FUNCTION)'
                                   ,p_msg_text => 'BEGIN..for table ' || p_tab_name);

      l_alias := p_alias || SUBSTR(p_tab_name,1,1);

      IF INSTR(p_tab_name,'_') > 0 THEN
         l_tab_name := SUBSTR(p_tab_name,INSTR(p_tab_name,'_')+1,LENGTH(p_tab_name));
         l_alias := get_alias(l_tab_name,l_alias);
      END IF;

      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                   ,p_module   => g_block||'.get_alias(FUNCTION)'
                                   ,p_msg_text => 'END..alias ' || p_alias);

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

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.get_alias(PROCEDURE)'
                                   ,p_msg_text => 'BEGIN..for table ' || p_tab_name);

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

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.get_alias(PROCEDURE)'
                                   ,p_msg_text => 'END..alias ' || p_alias);

    END get_alias;

    ---------------------------------------------------
    -- end get_alias                                 --
    ---------------------------------------------------

    --------------------------------------------
    -- This function is used to return the
    -- db data type, perform the type cast
    -- if required and return the value
    --------------------------------------------

    FUNCTION get_param_value(p_column_name IN VARCHAR2,
                             p_param_val   IN VARCHAR2 )

                             RETURN VARCHAR2
    IS
       CURSOR get_db_data_type_cur IS
         SELECT DECODE(data_type,'NUMBER','TO_NUMBER','')
         FROM   fem_column_requiremnt_vl
         WHERE  column_name = p_column_name;

       l_ret_type   VARCHAR2(100);

    BEGIN

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.get_param_value'
                                    ,p_msg_text => 'BEGIN');

       OPEN  get_db_data_type_cur;
       FETCH get_db_data_type_cur INTO l_ret_type;
       CLOSE get_db_data_type_cur;

       IF l_ret_type = 'TO_NUMBER' THEN
          l_ret_type := l_ret_type || '(' || '''' || p_param_val || '''' || ')';
       ELSE
          l_ret_type := '''' || p_param_val || '''';
       END IF;

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.get_param_value'
                                    ,p_msg_text => 'END');

       RETURN l_ret_type;

    END get_param_value;

    --------------------------------------------
    -- end get_param_value
    --------------------------------------------

    --------------------------------------------------------------------------
    -- This is the main procedure that actually builds the SELECT, FROM, WHERE
    -- clause.
    --
    -- This is the main procedure that actually builds the SELECT, FROM, WHERE
    -- clause.
    --
    -- When the column template is defined, the user can map the source
    -- to target column in 3 ways:
    -- 1. Attribute Lookup (Dimension)
    -- 2. Source Column
    -- 3. Constant (Number/Varchar2/Date)
    -- 4. Unassigned (this has no bearing when the engine builds the code,
    --    all columns with this type are ignored)
    --
    -- There are also some special columns like
    -- 1. Engine Processing Parameters - Columns who derive values at
    --    runtime. (pass the parameter values{SRS} to target table)
    -- 2. Parameter - Certain columns marked as parameter_flag = 'Y' need
    --    constant values to be passed to fem_customer_profit.
    --    Ex: record_count => number of records processed by the engine.
    --
    -- Aggregtion Methods apart from Average, Sum not supported at this point,
    -- even though they are visible in the UI.
    ----------------------------------------------------------------------------

    PROCEDURE get_from_where_clause(p_api_version            IN NUMBER,
                                    p_init_msg_list          IN VARCHAR2,
                                    p_commit                 IN VARCHAR2,
                                    p_encoded                IN VARCHAR2,
                                    p_object_def_id          IN NUMBER,
                                    p_load_sec_relns         IN BOOLEAN,
                                    p_dataset_grp_obj_def_id IN NUMBER,
                                    p_cal_period_id          IN NUMBER,
                                    p_ledger_id              IN NUMBER,
                                    p_source_system_code     IN NUMBER,
                                    p_created_by_object_id   IN NUMBER,
                                    p_created_by_request_id  IN NUMBER,
                                    p_insert_list            OUT NOCOPY LONG,
                                    p_select_list            OUT NOCOPY LONG,
                                    p_from_clause            OUT NOCOPY LONG,
                                    p_where_clause           OUT NOCOPY LONG,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2,
                                    x_return_status          OUT NOCOPY VARCHAR2)
    IS

        CURSOR get_table_list_cur IS
          SELECT c.source_table_name,
                 c.source_column_name,
                 c.target_table_name,
                 c.target_column_name,
                 c.dimension_id,
                 c.attribute_id,
                 c.attribute_version_id,
                 c.aggregation_method,
                 c.constant_numeric_value,
                 c.constant_alphanumeric_value,
                 c.constant_date_value,
                 c.data_population_method_code,
                 DECODE( c.aggregation_method,
                         'AVERAGE', 'AVG',
                         'SUM', 'SUM',
                         'AVERAGE_BY_DAYS_WEIGHTED', 'AVG',
                         'BEGINNING','MIN',
                         'LAST','MAX',
                         NULL) agg_method,
                 c.eng_proc_param,
                 c.parameter_flag
          FROM   fem_col_population_tmplt_b c
          WHERE  c.col_pop_templt_obj_def_id = p_object_def_id
            AND  ( c.data_population_method_code <> 'UNASSIGNED' OR
                  (c.data_population_method_code = 'UNASSIGNED' AND parameter_flag = 'Y')
                 )
          ORDER BY data_population_method_code;

          i                         NUMBER;

          found                     BOOLEAN;
          param_exists              BOOLEAN;
          agg_present               BOOLEAN;

          l_alias_attr              VARCHAR2(10);
          l_alias_mem               VARCHAR2(10);
          l_attr_tab_name           VARCHAR2(30);
          l_source_col_name         VARCHAR2(30);
          l_data_pop_method         VARCHAR2(30);
          l_agg_method              VARCHAR2(30);
          l_member_col              VARCHAR2(30);
          l_attr_val_col            VARCHAR2(30);
          l_member_tab_name         VARCHAR2(30);
          l_param_val               VARCHAR2(100);
          l_fem_data_type_code      VARCHAR2(30);
          l_op_dataset_code         NUMBER;
          l_acct_ownership_id       NUMBER;
          l_disp_code               VARCHAR2(10);
          l_convert_condition       VARCHAR2(1000);

          l_select_col              VARCHAR2(1000);

          attr_list_tbl             attr_list_arr;

          l_api_version             NUMBER;
          l_init_msg_list           VARCHAR2(1);
          l_commit                  VARCHAR2(1);
          l_encoded                 VARCHAR2(1);

          l_where                   VARCHAR2(1000);

          eng_proc_where_generated  BOOLEAN;

          e_ds_wclause_error        EXCEPTION;

          CURSOR fetch_dim_attr_cur(p_attr_id IN NUMBER) IS
             SELECT dimension_id,
                    attribute_dimension_id,
                    attribute_value_column_name,
                    attribute_data_type_code
             FROM   fem_dim_attributes_vl
             WHERE  attribute_id = p_attr_id;

          fetch_dim_attr_rec  fetch_dim_attr_cur%ROWTYPE;

          CURSOR fetch_dim_member_cur(p_dim_id IN NUMBER) IS
             SELECT member_col,
                    member_data_type_code,
                    member_vl_object_name,
                    attribute_table_name
             FROM   fem_xdim_dimensions
             WHERE  dimension_id = p_dim_id;

          fetch_dim_member_rec fetch_dim_member_cur%ROWTYPE;

          CURSOR fetch_tab_class_code_cur IS
             SELECT usage_code
             FROM   fem_table_class_assignmt a,
                    fem_table_class_usages b
             WHERE  a.table_classification_code = b.table_classification_code
               AND  a.table_name = g_src_tab_name;

          CURSOR get_table_id_cur(c_src_tab_name IN VARCHAR2)IS
             SELECT table_id
             FROM   fem_tables_b
             WHERE  table_name = c_src_tab_name;

          CURSOR get_fem_data_type_code(c_source_col_name IN VARCHAR2) IS
             SELECT fem_data_type_code
             FROM   fem_tab_columns_vl
             WHERE  table_name = g_src_tab_name
               AND  column_name = c_source_col_name;

          PROCEDURE initialize
          IS
            l_attribute_varchar_label  VARCHAR2(30);
            l_member_id                VARCHAR2(150);
            l_attribute_id             NUMBER;
            l_attr_version_id          NUMBER;

            l_get_dim_attr_error       EXCEPTION;
            l_no_exch_prof_val         EXCEPTION;
            l_get_exch_rate_error      EXCEPTION;
            l_get_ledger_curr_error    EXCEPTION;
            l_op_dataset_code_error    EXCEPTION;
            l_acct_ownership_error     EXCEPTION;

          BEGIN
              fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                           ,p_module   => g_block||'.get_from_where_clause.initialize'
                                           ,p_msg_text => 'BEGIN');

              g_src_alias := get_alias(g_src_tab_name,'');
              g_tgt_alias := get_alias(g_tgt_tab_name,'');
              g_sec_alias := get_alias('FEM_SECONDARY_OWNERS','');

              -- For Account Consolidation we would have to set the
              -- table_id to be passed back to engine;
              -- Table_id is required only if the secondary
              -- relationships have to be loaded.

              -- The above comments are historical!!!!

              -- Now that fem_customer_profit has table_id as a not null
              -- column; opening the cursor to the entire code

              OPEN  get_table_id_cur(g_src_tab_name);
              FETCH get_table_id_cur INTO g_table_id;
              CLOSE get_table_id_cur;

              fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                           ,p_module   => g_block||'.get_from_where_clause.initialize'
                                           ,p_msg_text => 'Retieved alias and table_id');

              -----------------------------------------------------------
              -- Get the currency conversion type FROM profile options --
              -----------------------------------------------------------

              g_curr_conv_type := fnd_profile.value_specific (
                                     'FEM_CURRENCY_CONVERSION_TYPE'
                                     ,fnd_global.user_id
                                     ,fnd_global.resp_id
                                     ,fnd_global.prog_appl_id);

              IF (g_curr_conv_type IS NULL) THEN
                 fem_engines_pkg.user_message (
                    p_app_name  => 'FEM'
                   ,p_msg_name  => G_INV_EXCHG_RATE_TYPE_ERR);
                 RAISE l_no_exch_prof_val;
              END IF;

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_2
                ,p_module   => g_block||'.get_from_where_clause.initialize'
                ,p_msg_text => 'Retieved currency conversion type..type '
                               || g_curr_conv_type);

              -----------------------------
              -- Set the exchange rate date
              -----------------------------

              FOR dim_rec IN (SELECT dimension_id,
                                     dimension_varchar_label
                              FROM   fem_xdim_dimensions_vl
                              WHERE  dimension_varchar_label IN ('CAL_PERIOD','LEDGER'))
              LOOP

                 IF dim_rec.dimension_varchar_label = 'CAL_PERIOD' THEN
                    l_attribute_varchar_label := 'CAL_PERIOD_END_DATE';
                    l_member_id := p_cal_period_id;
                 ELSE
                    l_attribute_varchar_label := 'LEDGER_FUNCTIONAL_CRNCY_CODE';
                    l_member_id := p_ledger_id;
                 END IF;

                 BEGIN
                   SELECT att.attribute_id
                         ,ver.version_id
                   INTO   l_attribute_id
                         ,l_attr_version_id
                   FROM   fem_dim_attributes_b att
                         ,fem_dim_attr_versions_b ver
                   WHERE  att.dimension_id = dim_rec.dimension_id
                     AND  att.attribute_varchar_label = l_attribute_varchar_label
                     AND  ver.attribute_id = att.attribute_id
                     AND  ver.default_version_flag = 'Y';

                 EXCEPTION
                   WHEN OTHERS THEN
                       fem_engines_pkg.user_message(
                          p_app_name  => 'FEM'
                         ,p_msg_name  => G_NO_ATTR_VER_ERR
                         ,p_token1    => 'DIMENSION_ID'
			 ,p_value1    =>  dim_rec.dimension_id
                         ,p_token2    => 'DIMENSION_VARCHAR_LABEL'
                         ,p_value2    => dim_rec.dimension_varchar_label
                         ,p_token3    => 'ATTRIBUTE_VARCHAR_LABEL'
                         ,p_value3    => l_attribute_varchar_label);
                       RAISE l_get_dim_attr_error;
                 END;

                 fem_engines_pkg.tech_message (
                    p_severity => g_log_level_2
                   ,p_module   => g_block||'.get_from_where_clause.initialize'
                   ,p_msg_text => 'Retrieved attribute and version for.. '
                                  || l_attribute_varchar_label);

                 IF dim_rec.dimension_varchar_label = 'CAL_PERIOD' THEN

                    BEGIN
                       SELECT date_assign_value
                       INTO   g_exch_rate_date
                       FROM   Fem_Cal_Periods_Attr
                       WHERE  attribute_id = l_attribute_id
                         AND  version_id = l_attr_version_id
                         AND  cal_period_id = l_member_id;

                    EXCEPTION
                       WHEN OTHERS THEN
                          fem_engines_pkg.user_message(
                             p_app_name  => 'FEM'
                            ,p_msg_name  => G_NO_EXCHG_RATE_ERR);

                       RAISE l_get_exch_rate_error;
                    END;

                 ELSE

                    BEGIN
                       SELECT dim_attribute_varchar_member
                       INTO   g_func_curr_code
                       FROM   Fem_Ledgers_Attr
                       WHERE  attribute_id = l_attribute_id
                         AND  version_id = l_attr_version_id
                         AND  ledger_id = l_member_id;

                    EXCEPTION
                       WHEN OTHERS THEN
                          fem_engines_pkg.user_message (
                             p_app_name  => 'FEM'
                            ,p_msg_name  => G_NO_FUNCTIONAL_CURR_ERR);

                       RAISE l_get_ledger_curr_error;
                    END;

                 END IF;

              END LOOP;

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_2
                ,p_module   => g_block||'.get_from_where_clause.initialize'
                ,p_msg_text => 'Retrieved currency exchange date '
                               || g_exch_rate_date|| ' and functional currency '
                               || g_func_curr_code);

              ------------------------------
              -- Get the output dataset code
              ------------------------------

              BEGIN
                SELECT  output_dataset_code
                INTO    l_op_dataset_code
                FROM    fem_ds_input_output_defs
                WHERE   dataset_io_obj_def_id = p_dataset_grp_obj_def_id;

              EXCEPTION
                WHEN OTHERS THEN
                   fem_engines_pkg.user_message (
                      p_app_name  => 'FEM'
                     ,p_msg_name  => G_INVALID_DATASET_GRP_ERR
                     ,p_token1    => 'DATASET_IO_OBJ_DEF_ID'
                     ,p_value1    => p_dataset_grp_obj_def_id);
                RAISE l_op_dataset_code_error;

              END;

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_2
                ,p_module   => g_block||'.get_from_where_clause.initialize'
                ,p_msg_text => 'Retrieved dataset code ');

              ---------------------------------
              -- Get the account ownership code
              ---------------------------------

              IF NOT agg_present THEN
                 IF p_load_sec_relns THEN
                    l_disp_code := 'SECONDARY';
                 ELSE
                    l_disp_code := 'PRIMARY';
                 END IF;
              ELSE
                 l_disp_code := 'Default';
              END IF;

              BEGIN

                SELECT  acct_ownership_id
                INTO    l_acct_ownership_id
                FROM    fem_acct_ownshp_b
                WHERE   acct_ownership_display_code = l_disp_code;

              EXCEPTION
                WHEN OTHERS THEN
                   fem_engines_pkg.tech_message (
                      p_severity => g_log_level_6
                     ,p_module   => g_block||'.get_from_where_clause.initialize'
                     ,p_msg_text => 'Error fetching account ownership
                                     display code for ' || l_disp_code);

                   fem_engines_pkg.user_message (
                      p_app_name  => 'FEM'
                     ,p_msg_name  => G_INVALID_ACCT_OWNER_ID_ERR
                     ,p_token1    => 'ACCOUNT_OWNERSHIP_DISPLAY_CODE'
                     ,p_value1    => l_disp_code);
                   RAISE l_acct_ownership_error;

              END;

              l_disp_code := NULL;

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_2
                ,p_module   => g_block||'.get_from_where_clause.initialize'
                ,p_msg_text => 'Retrieved acct_ownshp_id '
                               || TO_CHAR(l_acct_ownership_id) );

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_2
                ,p_module   => g_block||'.get_from_where_clause.initialize'
                ,p_msg_text => 'END');

          EXCEPTION

             WHEN l_no_exch_prof_val THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception - no exch rate type');

             WHEN l_get_dim_attr_error THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception - no attributes');

             WHEN l_get_exch_rate_error THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception: getting the exch rate');

             WHEN l_get_ledger_curr_error THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception: getting the func curr');

             WHEN l_op_dataset_code_error THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception: Invalid dataset group');

             WHEN l_acct_ownership_error THEN
                x_return_status := c_error;
                fem_engines_pkg.tech_message (
                   p_severity => g_log_level_6
                  ,p_module   => g_block||'.initialize'
                  ,p_msg_text => 'Initialize Exception:Account ownership code');

          END initialize;

    BEGIN

       fem_engines_pkg.tech_message (
          p_severity => g_log_level_2
         ,p_module   => g_block||'.get_from_where_clause'
         ,p_msg_text => 'BEGIN');

       l_api_version   := NVL(p_api_version, c_api_version);
       l_init_msg_list := NVL(p_init_msg_list, c_false);
       l_commit        := NVL(p_commit, c_false);
       l_encoded       := NVL(p_encoded, c_true);

       i := 1;
       found        := FALSE;
       param_exists := FALSE;
       agg_present  := TRUE;
       eng_proc_where_generated := FALSE;

       l_param_val := NULL;

       x_return_status := c_success;

       -- If agg_present implies profit aggregation
       agg_present := is_aggregation_present(p_object_def_id);

       FOR get_table_list_rec IN get_table_list_cur LOOP

         l_source_col_name := get_table_list_rec.source_column_name;
         l_data_pop_method := get_table_list_rec.data_population_method_code;

         IF l_data_pop_method LIKE 'CONSTANT%' THEN
            l_source_col_name := get_table_list_rec.target_column_name;
         END IF;

         IF g_src_tab_name IS NULL THEN
            -- Make call to initialize procedure to set the
            -- global variables

            -- The currency exch rate,type need to be evaluated
            -- as well

            fem_engines_pkg.tech_message (
               p_severity => g_log_level_2
              ,p_module   => g_block||'.get_from_where_clause'
              ,p_msg_text => 'Initializing global variables');

            g_src_tab_name := get_table_list_rec.source_table_name;
            g_tgt_tab_name := get_table_list_rec.target_table_name;
            initialize;

            fem_engines_pkg.tech_message (
               p_severity => g_log_level_2
              ,p_module   => g_block||'.get_from_where_clause'
              ,p_msg_text => 'After initializing global variables');

         END IF;

         IF agg_present THEN
            l_agg_method := NVL(get_table_list_rec.agg_method,'MIN');
         END IF;

         fem_engines_pkg.tech_message (
            p_severity => g_log_level_1
           ,p_module   => g_block||'.get_from_where_clause'
           ,p_msg_text => 'Return status after initialize = '||x_return_status);

         IF x_return_status = c_success THEN

            IF get_table_list_rec.parameter_flag = 'N' THEN

               fem_engines_pkg.tech_message(
                  p_severity => g_log_level_1
                 ,p_module   => g_block||'.get_from_where_clause'
                 ,p_msg_text => 'Inside While, Parameter = N, Population Method = '
                                ||l_data_pop_method||' for column = '
                                ||l_source_col_name );

               IF l_data_pop_method = 'DIMENSION_LOOKUP' THEN

                  l_param_val := NULL;

                  OPEN  fetch_dim_attr_cur(get_table_list_rec.attribute_id);
                  FETCH fetch_dim_attr_cur INTO fetch_dim_attr_rec;
                  CLOSE fetch_dim_attr_cur;

                  l_attr_val_col := fetch_dim_attr_rec.attribute_value_column_name;

                  OPEN  fetch_dim_member_cur(fetch_dim_attr_rec.dimension_id);
                  FETCH fetch_dim_member_cur INTO fetch_dim_member_rec;
                  CLOSE fetch_dim_member_cur;

                  l_attr_tab_name := fetch_dim_member_rec.attribute_table_name;

                  get_alias(attr_list_tbl,l_attr_tab_name,l_alias_attr);

                  p_from_clause  := p_from_clause || ',' || l_attr_tab_name
                                      || ' ' || l_alias_attr;

                  p_where_clause := p_where_clause || ' AND '
                                      || g_src_alias ||'.'|| l_source_col_name
                                      || ' = ' || l_alias_attr || '.'
                                      || l_source_col_name || ' AND '
                                      || l_alias_attr || '.attribute_id = '
                                      || '' || get_table_list_rec.attribute_id
                                      || '' || ' AND ' || l_alias_attr
                                      || '.version_id = ' || ''
                                      || get_table_list_rec.attribute_version_id
                                      || '';

                  IF fetch_dim_attr_rec.attribute_data_type_code = 'DIMENSION' THEN
                     -- Get the dimension_attribute_numeric_member/varchar_member

                     OPEN  fetch_dim_member_cur
                                    (fetch_dim_attr_rec.attribute_dimension_id);
                     FETCH fetch_dim_member_cur
                      INTO fetch_dim_member_rec;
                     CLOSE fetch_dim_member_cur;

                 l_member_tab_name := fetch_dim_member_rec.member_vl_object_name;
                 l_member_col := fetch_dim_member_rec.member_col;

                 -- Need to build SQL statement dynamically for querying
                 -- on the dimension attribute table. Ex: Fem_Products_Attr
                 -- is stored in attribute_table_name,
                 -- Fem_Products_VL is stored in member_vl_object_name.

                 get_alias(attr_list_tbl,l_member_tab_name,l_alias_mem);
                 l_select_col := l_alias_mem  || '.' || l_member_col;
                 p_from_clause := p_from_clause || ',' || l_member_tab_name || ' ' || l_alias_mem;
                 p_where_clause := p_where_clause || ' AND ' || l_alias_attr || '.' || l_attr_val_col || ' = '
                                                             || l_alias_mem || '.' || l_member_col;

              ELSE
                 l_select_col := l_alias_attr  || '.' || l_attr_val_col;
              END IF;

              IF agg_present THEN
                   l_select_col := l_agg_method || '(' || l_select_col || ')';
              END IF;

            ELSIF ((l_data_pop_method = 'DEFINED_COLUMN' AND l_source_col_name IS NOT NULL) OR
                   (l_data_pop_method LIKE 'CONSTANT%' AND
                    get_table_list_rec.eng_proc_param IS NOT NULL)) THEN

              -- Agg_present = TRUE for Profit aggregation engine
              IF get_table_list_rec.eng_proc_param IS NOT NULL THEN

                   l_param_val := 'Y';

                   CASE l_source_col_name

                      WHEN 'DATASET_CODE' THEN
                           l_select_col := get_param_value(l_source_col_name, l_op_dataset_code);
                      WHEN 'CAL_PERIOD_ID' THEN
                           l_select_col :=  get_param_value(l_source_col_name, p_cal_period_id);
                      WHEN 'LEDGER_ID' THEN
                           l_select_col :=  get_param_value(l_source_col_name, p_ledger_id);
                      ELSE
                           l_select_col := g_src_alias || '.' || l_source_col_name;

                   END CASE;

                   -- Things to do:
                   -- Replace the fem_ds_where_clause_generator API with
                   -- fem_assembler_predicate_api.generate_assembler_predicate.
                   --
                   -- This would return the complete WHERE clause comprising of
                   -- dataset_code, cal_period_id, ledger_id.
                   --
                   -- At the moment ledger_id inclusion in where clause is being
                   -- done manually.

                   IF NOT eng_proc_where_generated THEN

                      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                   ,p_module   => g_block||'.get_from_where_clause'
                                                   ,p_msg_text => 'Before generating the where ');

                      fem_ds_where_clause_generator.fem_gen_ds_wclause_pvt(p_api_version       =>  l_api_version
                                                                          ,p_init_msg_list     =>  FND_API.G_TRUE
                                                                          ,p_encoded           =>  FND_API.G_TRUE
                                                                          ,x_return_status     =>  x_return_status
                                                                          ,x_msg_count         =>  x_msg_count
                                                                          ,x_msg_data          =>  x_msg_data
                                                                          ,p_ds_io_def_id      =>  p_dataset_grp_obj_def_id
                                                                          ,p_output_period_id  =>  p_cal_period_id
                                                                          ,p_table_alias       =>  g_src_alias
                                                                          ,p_table_name        =>  g_src_tab_name
                                                                          ,p_ledger_id         =>  p_ledger_id
                                                                          ,p_where_clause      =>  l_where);

                      eng_proc_where_generated := TRUE;

                      IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

                         eng_proc_where_generated := FALSE;

                         FEM_ENGINES_PKG.User_Message (
                            p_app_name => 'FEM'
                           ,p_msg_name => G_DS_WHERE_PREDICATE_ERR);

                         IF (l_where IS NULL) THEN
                            FEM_ENGINES_PKG.User_Message (
                               p_app_name => 'FEM'
                              ,p_msg_name => G_DS_WHERE_PREDICATE_ERR);
                         END IF;
                         RAISE e_ds_wclause_error;

                      END IF;

                      fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                                   ,p_module   => g_block||'.get_from_where_clause'
                                                   ,p_msg_text => 'DS WHERE clause generated, where = ' || l_where);

                      p_where_clause := p_where_clause || ' AND ' || l_where;

                   END IF; -- eng_proc_where_generated

                   IF l_source_col_name = 'LEDGER_ID' THEN
                      p_where_clause := p_where_clause || ' AND ' || g_src_alias || '.' || l_source_col_name;
                      p_where_clause := p_where_clause || ' = '   || p_ledger_id;
                   END IF;

              ELSE -- eng_proc_param

                   l_fem_data_type_code := NULL;

                   OPEN  get_fem_data_type_code(l_source_col_name);
                   FETCH get_fem_data_type_code INTO l_fem_data_type_code;
                   CLOSE get_fem_data_type_code;

                   -- For all columns that are of data_type = BALANCE
                   -- we need to convert the values into functional currency
                   -- in case they are not in func. curr

                   IF l_fem_data_type_code = 'BALANCE' THEN

                      l_convert_condition := 'gl_currency_api.get_rate(' || '''' || g_func_curr_code || '''' || ',' ||
                                              g_src_alias || '.currency_code' || ',' || 'fnd_date.canonical_to_date'||
                                              '(fnd_date.date_to_canonical(' || '''' || g_exch_rate_date || ''''
                                              || '))' || ',' || '''' || g_curr_conv_type || '''' || ')*' ||
                                              g_src_alias||'.'||l_source_col_name;

                      l_select_col := 'DECODE(' || g_src_alias || '.currency_code,' || '''' || g_func_curr_code
                                                || '''' || ',' || g_src_alias ||'.'|| l_source_col_name || ',' ||
                                                l_convert_condition || ')';

                   ELSE
                      l_select_col := g_src_alias || '.' || l_source_col_name;
                   END IF;

              END IF; -- eng_proc_param

              IF agg_present AND l_param_val IS NULL THEN
                   l_select_col := l_agg_method || '(' || l_select_col || ')';
              END IF;

              -- l_param_val is set to NULL after cal_period_id OR dataset_code OR ledger_id
              -- columns have been processed.

              l_param_val := NULL;

            ELSE
              l_select_col :=  get_table_list_rec.constant_numeric_value      ||
                               get_table_list_rec.constant_alphanumeric_value ||
                               get_table_list_rec.constant_date_value         ;

              IF get_table_list_rec.constant_numeric_value IS NULL THEN
                 l_select_col := '''' || l_select_col || '''';
              END IF;

            END IF; -- dimension_lookup

           ELSE -- parameter_flag

             fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                          ,p_module   => g_block||'.get_from_where_clause'
                                          ,p_msg_text => 'Step1: Parameter = Y, for column = ' || l_source_col_name );

            -- Implies value derived at runtime
              CASE get_table_list_rec.target_column_name --l_source_col_name

                WHEN  'ACCT_OWNERSHIP_ID' THEN
                      l_select_col := 'TO_NUMBER(' || '''' || l_acct_ownership_id || '''' ||  ')';
                WHEN  'CREATED_BY_OBJECT_ID' THEN
                      l_select_col := 'TO_NUMBER(' || '''' || p_created_by_object_id || '''' ||  ')';
                WHEN  'CREATED_BY_REQUEST_ID' THEN
                      l_select_col := 'TO_NUMBER(' || '''' || p_created_by_request_id || '''' || ')';

                -- Member table for DATA_AGGN_TYPE_CODE = FEM_DATA_AGGS_B
                -- The table has no ID column but has these 3 values seeded
                -- Default
                -- ACCOUNT_RELATIONSHIP
                -- CUSTOMER_AGGREGATION
                -- Having an extra cursor to select this value is of no use, hence hard-coding the value
                -- might revisit later for FEM.E

                WHEN 'DATA_AGGREGATION_TYPE_CODE' THEN
                      IF NOT agg_present THEN
                         l_select_col := '''' || 'ACCOUNT_RELATIONSHIP' || '''';
                      ELSE
                         l_select_col := '''' || 'CUSTOMER_AGGREGATION' || '''';
                      END IF;
                WHEN  'LAST_UPDATED_BY_OBJECT_ID' THEN
                      l_select_col := 'TO_NUMBER(' || '''' || p_created_by_object_id || '''' ||  ')';
                WHEN  'LAST_UPDATED_BY_REQUEST_ID' THEN
                      l_select_col := 'TO_NUMBER(' || '''' || p_created_by_request_id || '''' || ')';
                WHEN  'PRI_ACCOUNTS' THEN
                      IF NOT agg_present THEN
                         IF p_load_sec_relns THEN
                            l_select_col := 'TO_NUMBER(''0'')';
                         ELSE
                            l_select_col := 'TO_NUMBER(''1'')';
                         END IF;
                      ELSE
                         l_select_col := 'TO_NUMBER(''1'')';
                      END IF;
                -- Record count info has to be changed after aggregation; this info. can be derived only
                -- after the aggregation engine has completed execution.
                -- The engine can make use of additional check of -987654321 while updating
                -- the target table.
                WHEN  'RECORD_COUNT' THEN
                      IF agg_present THEN
                         l_select_col := 'TO_NUMBER(''-987654321'')';
                      ELSE
                         l_select_col := 'TO_NUMBER(''1'')';
                      END IF;
                WHEN  'SOURCE_SYSTEM_CODE' THEN l_select_col := 'TO_NUMBER(' || '''' || p_source_system_code || '''' || ')';
                WHEN  'TABLE_ID' THEN l_select_col := 'TO_NUMBER(' || '''' || g_table_id || '''' || ')';

                ELSE  l_select_col := l_source_col_name;

              END CASE;

           END IF; -- parameter_flag

           CASE l_source_col_name

               -- Currency always to be stored in functional currency
               -- Ignore the mapping in the template
               WHEN 'CURRENCY_CODE' THEN
                  l_select_col := '''' || g_func_curr_code || '''';

              /* -- Source system code should also be used in filtering the records from Source table
               WHEN  'SOURCE_SYSTEM_CODE' THEN
                  p_where_clause := p_where_clause || ' AND ' || g_src_alias || '.' || l_source_col_name;
                  p_where_clause := p_where_clause || ' = '   || p_source_system_code;*/

               -- For aggregation and while loading secondary relationship during consolidation we are
               -- not sure of from which table the customer_id info. is being picked up from. Hence,
               -- this change would be better of from the calling engines.
               WHEN 'CUSTOMER_ID' THEN
                  IF l_data_pop_method = 'DEFINED_COLUMN' AND ( agg_present OR p_load_sec_relns ) THEN
                     l_select_col := '{{{CUSTOMER_ID}}}';
                  END IF;

               ELSE NULL;

           END CASE;

           p_insert_list := p_insert_list || ', ' || get_table_list_rec.target_column_name;
           p_select_list := p_select_list || ', ' || l_select_col;

         END IF; -- x_return_status = c_success

         EXIT WHEN x_return_status <> c_success;

       END LOOP;

       IF x_return_status = c_success THEN

          p_insert_list := LTRIM(p_insert_list,',');
          p_select_list := LTRIM(p_select_list,',');
          p_from_clause := ' FROM ' || g_src_tab_name || ' ' || g_src_alias || p_from_clause;
          p_where_clause := ' WHERE ' || LTRIM(p_where_clause,' AND ');

         -- If the WHERE clause did not get generated correctly the string would contain only
         -- ' WHERE '; in such case remove the WHERE clause
         -- Would not encounter this situation at all, the check is redundant; will remove it
         -- for FEM.E timeframe

          IF p_where_clause = ' WHERE ' THEN
             p_where_clause := '';
          END IF;

       -- If there has been error then init all the p_**** variables to NULL.
       -- This might not be necessary
       ELSE
          p_insert_list := NULL;
          p_select_list := NULL;
          p_from_clause := NULL;
          p_where_clause := NULL;
       END IF;

       fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                    ,p_module   => g_block||'.get_from_where_clause'
                                    ,p_msg_text => 'p_insert_list ' || p_insert_list);

       fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                    ,p_module   => g_block||'.get_from_where_clause'
                                    ,p_msg_text => 'p_select_list ' || p_select_list);

       fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                    ,p_module   => g_block||'.get_from_where_clause'
                                    ,p_msg_text => 'p_from_clause ' || p_from_clause);

       fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                    ,p_module   => g_block||'.get_from_where_clause'
                                    ,p_msg_text => 'p_where_clause ' || p_where_clause);

     EXCEPTION

        WHEN e_ds_wclause_error THEN
           x_return_status := c_error;

           fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                        ,p_module   => g_block||'.get_from_where_clause'
                                        ,p_msg_text => 'Dataset Where Clause Generate Exception');
           FEM_ENGINES_PKG.User_Message (
              p_app_name => 'FEM'
             ,p_msg_name => G_GENERATE_WHERE_CLAUSE_ERR);

           fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data);

        WHEN OTHERS THEN
           x_return_status := c_error;

           fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                        ,p_module   => g_block||'.get_from_where_clause'
                                        ,p_msg_text => 'get_from_where_clause: General_Exception');
           FEM_ENGINES_PKG.User_Message (
              p_app_name => 'FEM'
             ,p_msg_name => G_GENERATE_WHERE_CLAUSE_ERR);

           fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                     p_count => x_msg_count,
                                     p_data => x_msg_data);


     END get_from_where_clause;

    -----------------------------
    -- end get_from_where_clause;
    -----------------------------

    -----------------------------------------------------
    -- Returns whether aggregation is included as part of
    -- column template definition.
    -----------------------------------------------------

    FUNCTION is_aggregation_present(p_object_def_id IN NUMBER)
    RETURN BOOLEAN IS

      dummy  VARCHAR2(1);
      retval BOOLEAN;

      CURSOR chk_for_agg_cur IS
        SELECT 1
        FROM   dual
        WHERE  EXISTS
               (SELECT aggregation_method
                FROM   fem_col_population_tmplt_vl
                WHERE  col_pop_templt_obj_def_id = p_object_def_id
                  AND  aggregation_method <> 'NOAGG');
    BEGIN

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.is_aggregation_present'
                                   ,p_msg_text => 'BEGIN');

      retval := TRUE;

      OPEN  chk_for_agg_cur;
      FETCH chk_for_agg_cur INTO dummy;

      IF chk_for_agg_cur%NOTFOUND THEN
         retval := FALSE;
      END IF;

      CLOSE chk_for_agg_cur;

      fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                   ,p_module   => g_block||'.is_aggregation_present'
                                   ,p_msg_text => 'END');

      RETURN retval;

    END is_aggregation_present;

    -----------------------------
    -- end is_aggregation_present
    -----------------------------

    -------------------------------------------------------------------
    -- Public API used to return the SELECT, insert, FROM, where
    -- , condition clauses
    --
    -- p_selection_param = 0 -> Gives the SQL with conditions predicate
    --
    -- p_condition_sel_param
    -- 'DIM'  -> Returns the dimension component
    -- 'DATA' -> Returns the data component
    -- 'BOTH' -> Returns both the components
    -------------------------------------------------------------------

    PROCEDURE generate_predicates(
       p_api_version                IN NUMBER,
       p_init_msg_list              IN VARCHAR2,
       p_commit                     IN VARCHAR2,
       p_encoded                    IN VARCHAR2,
       p_object_def_id              IN NUMBER,
       p_selection_param            IN NUMBER,
       p_effective_date             IN VARCHAR2,
       p_condition_obj_id           IN NUMBER,
       p_condition_sel_param        IN VARCHAR2,
       p_load_sec_relns             IN VARCHAR2,
       p_dataset_grp_obj_def_id     IN NUMBER,
       p_cal_period_id              IN NUMBER,
       p_ledger_id                  IN NUMBER,
       p_source_system_code         IN NUMBER,
       p_created_by_object_id       IN NUMBER,
       p_created_by_request_id      IN NUMBER,
       p_insert_list                OUT NOCOPY LONG,
       p_select_list                OUT NOCOPY LONG,
       p_from_clause                OUT NOCOPY LONG,
       p_where_clause               OUT NOCOPY LONG,
       p_con_where_clause           OUT NOCOPY LONG,
       x_msg_count                  OUT NOCOPY NUMBER,
       x_msg_data                   OUT NOCOPY VARCHAR2,
       x_return_status              OUT NOCOPY VARCHAR2)
    IS

        l_err_code          NUMBER;
        l_err_msg           VARCHAR2(100);
        l_api_name 	    CONSTANT VARCHAR2(30) := 'generate_predicates';
        l_select_list       LONG;
        l_insert_list       LONG;
        l_from_clause       LONG;
        l_where_clause      LONG;

        l_load_sec_relns    BOOLEAN;

        l_api_version       NUMBER;
        l_init_msg_list     VARCHAR2(1);
        l_commit            VARCHAR2(1);
        l_encoded           VARCHAR2(1);

        e_cond_wclause_error   EXCEPTION;
    BEGIN

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.'||l_api_name
                                    ,p_msg_text => 'BEGIN');

       l_api_version   := NVL(p_api_version, c_api_version);
       l_init_msg_list := NVL(p_init_msg_list, c_false);
       l_commit        := NVL(p_commit, c_false);
       l_encoded       := NVL(p_encoded, c_true);

       x_return_status := c_success;

       --g_effective_date := fnd_profile.value('FEM_EFFECTIVE_DATE');

       g_obj_def_id := p_object_def_id;

       fem_engines_pkg.tech_message (
         p_severity  => g_log_level_1
        ,p_module   => g_block||'.'||l_api_name
        ,p_msg_text => 'Calling get_from_where_clause procedure');

       IF NVL(p_load_sec_relns,'N') = 'N' THEN
          l_load_sec_relns := FALSE;
       ELSE
          l_load_sec_relns := TRUE;
       END IF;

       get_from_where_clause(p_api_version,
                             p_init_msg_list,
                             p_commit,
                             p_encoded,
                             p_object_def_id,
                             l_load_sec_relns,
                             p_dataset_grp_obj_def_id,
                             p_cal_period_id,
                             p_ledger_id,
                             p_source_system_code,
                             p_created_by_object_id,
                             p_created_by_request_id,
                             l_insert_list,
                             l_select_list,
                             p_from_clause,
                             p_where_clause,
                             x_msg_count,
                             x_msg_data,
                             x_return_status);

       IF (x_return_status = fnd_api.g_ret_sts_success) THEN

          p_insert_list := 'INSERT INTO ' || g_tgt_tab_name || '('  || l_insert_list || ')';

          p_select_list := 'SELECT ' || l_select_list;

          IF p_selection_param = 0 THEN

             fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                          ,p_module   => g_block||'.'||l_api_name
                                          ,p_msg_text => 'Step 2: Condition Predicate Preparation');

             Fem_Conditions_Api.Generate_Condition_Predicate
             (l_api_version,
              l_init_msg_list,
              l_commit,
              l_encoded,
              p_condition_obj_id,
              p_effective_date,
              g_src_tab_name,
              g_src_alias,
              'N',                   -- Display Predicate
              p_condition_sel_param,
              'Y',
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_con_where_clause);

             IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN

                IF (p_con_where_clause IS NULL) THEN
                  FEM_ENGINES_PKG.User_Message (
                     p_app_name => 'FEM'
                    ,p_msg_name => G_CONDITION_PREDICATE_ERR
                    ,p_token1   => 'COND_OBJ_ID'
                    ,p_value1   => p_condition_obj_id);
                END IF;

                RAISE e_cond_wclause_error;

             END IF;

             fem_engines_pkg.tech_message (p_severity => g_log_level_1
                                          ,p_module   => g_block||'.'||l_api_name
                                          ,p_msg_text => 'Condition Predicate: '  || p_con_where_clause);

             fem_engines_pkg.tech_message (p_severity  => g_log_level_1
                                          ,p_module   => g_block||'.'||l_api_name
                                          ,p_msg_text => 'Step 2: After Condition Predicate Preparation');
          END IF;

          fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                    p_count => x_msg_count,
                                    p_data => x_msg_data);

       END IF;

       fem_engines_pkg.tech_message (p_severity => g_log_level_2
                                    ,p_module   => g_block||'.'||l_api_name
                                    ,p_msg_text => 'END');

       EXCEPTION

          WHEN e_cond_wclause_error THEN
             fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                          ,p_module   => g_block||'.'||l_api_name
                                          ,p_msg_text => 'Condition Where Clause Exception');
             FEM_ENGINES_PKG.User_Message (
                p_app_name => 'FEM'
               ,p_msg_name => G_GENERATE_PREDICATES_ERR);

             fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                       p_count => x_msg_count,
                                       p_data => x_msg_data);

             x_return_status := fnd_api.g_ret_sts_error;

          WHEN OTHERS THEN
             fem_engines_pkg.tech_message (p_severity  => g_log_level_5
                                          ,p_module   => g_block||'.'||l_api_name
                                          ,p_msg_text => 'Generate_predicates: General_Exception');

             FEM_ENGINES_PKG.User_Message (
                p_app_name => 'FEM'
               ,p_msg_name => G_GENERATE_PREDICATES_ERR);

             fnd_msg_pub.count_and_get(p_encoded => p_encoded,
                                       p_count => x_msg_count,
                                       p_data => x_msg_data);

             x_return_status := fnd_api.g_ret_sts_error;

    END generate_predicates;

    -----------------------------
    -- end generate_predicates
    -----------------------------

END Fem_Col_Tmplt_Defn_Api_Pub;

/

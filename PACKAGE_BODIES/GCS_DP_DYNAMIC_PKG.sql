--------------------------------------------------------
--  DDL for Package Body GCS_DP_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DP_DYNAMIC_PKG" AS
--
-- PRIVATE GLOBAL VARIABLES
--
   -- The API name
   g_pkg_name                      VARCHAR2 (30)      := 'gcs.plsql.GCS_DP_DYNAMIC_PKG';
   -- A newline character. Included for convenience when writing long strings.
   g_nl                   CONSTANT VARCHAR2 (1)                       := '
';
   g_insert_statement              VARCHAR2(32000);
   g_ln_item_vs_id NUMBER;
   g_li_eat_attr_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;
   g_li_eat_ver_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;

   g_eatc_batc_attr_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;
   g_eatc_batc_ver_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;
   g_li_vs_id NUMBER := gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id;
   g_ledger_ssc_attr_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('LEDGER_ID-SOURCE_SYSTEM_CODE').attribute_id;
   g_ledger_ssc_ver_id NUMBER := gcs_utility_pkg.g_dimension_attr_info ('LEDGER_ID-SOURCE_SYSTEM_CODE').version_id;

   no_re_template_error              EXCEPTION;
   no_suspense_template_error        EXCEPTION;
   init_mapping_error                EXCEPTION;
   no_data_error                     EXCEPTION;
--
-- Private Procedures
--
   FUNCTION init_local_to_master_maps (
      p_source_ledger_id   IN              NUMBER,
      p_cal_period_id      IN              NUMBER,
      errbuf               OUT NOCOPY      VARCHAR2,
      retcode              OUT NOCOPY      VARCHAR2,
      p_inc_mode_flag      IN              VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2
   IS
      l_source_global_vs_combo        VARCHAR2 (30);
      l_index_column_name             VARCHAR2 (30);
      l_source_value_set_id           NUMBER;
      l_hierarchy_obj_def_id          NUMBER (9);
      l_err_code                      NUMBER;
      l_err_msg                       NUMBER;
      l_mapping_required              VARCHAR2(1)    := 'N';
      l_cctr_map_required             BOOLEAN        := FALSE;
      l_from_text                     VARCHAR2(1000);
      l_where_text                    VARCHAR2(10000);
      l_group_text                    VARCHAR2(1000);
      global_vs_id_error              EXCEPTION;
      gcs_dp_no_hier_obj_def_id       EXCEPTION;
      l_api_name                      VARCHAR2(30)   := 'INIT_LOCAL_TO_MASTER_MAPS';
      l_cal_attribute_id              NUMBER;
      l_cal_version_id                NUMBER;
  BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_source_ledger_id = ' || p_source_ledger_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
      g_ln_item_vs_id    := gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id;
      l_cal_attribute_id := gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
      l_cal_version_id   := gcs_utility_pkg.g_dimension_attr_info ('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;
      BEGIN
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
          fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         '        SELECT fla.dim_attribute_numeric_member
                                     INTO l_source_global_vs_combo
                                     FROM fem_ledgers_attr fla,
                                          fem_dim_attributes_b fdab,
                                          fem_dim_attr_versions_b fdavb
                                    WHERE fla.ledger_id = ' || p_source_ledger_id || '
                                      AND fla.attribute_id = fdab.attribute_id
	                                    AND fdab.attribute_varchar_label = ''GLOBAL_VS_COMBO''
	                                    AND fla.version_id = fdavb.version_id
	                                    AND fdavb.attribute_id = fla.attribute_id
	                                    AND fdavb.default_version_flag = ''Y'' ');
        END IF;
          SELECT fla.dim_attribute_numeric_member
            INTO l_source_global_vs_combo
            FROM fem_ledgers_attr        fla,
                 fem_dim_attributes_b    fdab,
                 fem_dim_attr_versions_b fdavb
           WHERE fla.ledger_id                = p_source_ledger_id
             AND fla.attribute_id             = fdab.attribute_id
          	 AND fdab.attribute_varchar_label = 'GLOBAL_VS_COMBO'
          	 AND fla.version_id               = fdavb.version_id
          	 AND fdavb.attribute_id           = fla.attribute_id
          	 AND fdavb.default_version_flag   = 'Y';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE global_vs_id_error;
        END;
      g_insert_statement  := '
            INSERT INTO gcs_entry_lines_gt
                        (entry_id, cal_period_id, 
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e)
'||'
            SELECT  decode(fb.currency_code,
                           ''STAT'',
                           :l_stat_entry_id,
                           :l_entry_id), fb.cal_period_id, ';
      l_group_text        := ' GROUP BY ';
      l_index_column_name := gcs_utility_pkg.g_gcs_dimension_info.FIRST;
      WHILE (l_index_column_name <= gcs_utility_pkg.g_gcs_dimension_info.LAST )
      LOOP
         IF (    (gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).associated_value_set_id IS NOT NULL)
             AND (l_index_column_name <> 'ENTITY_ID')
             AND (gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).required_for_gcs = 'Y')
            )
         THEN
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         '             SELECT value_set_id
                                          INTO l_source_value_set_id
                                          FROM fem_global_vs_combo_defs
                                         WHERE global_vs_combo_id = '||l_source_global_vs_combo||'
                                           AND dimension_id = '||gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).dimension_id);
             END IF;
             SELECT  value_set_id
               INTO  l_source_value_set_id
               FROM  fem_global_vs_combo_defs
              WHERE  global_vs_combo_id   = l_source_global_vs_combo
                AND  dimension_id         = gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).dimension_id;

            IF (   (l_source_value_set_id IS NULL)
                OR (l_source_value_set_id = gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).associated_value_set_id)
               )
            THEN
            g_insert_statement := g_insert_statement || 'fb.' || l_index_column_name || ', ';
               GOTO next_loop;
            ELSE
               gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).detail_value_set_id := l_source_value_set_id;
               l_mapping_required := 'Y';
            END IF;

            BEGIN
            SELECT fod.object_definition_id
              INTO l_hierarchy_obj_def_id
              FROM fem_xdim_dimensions     fxd,
                   fem_object_definition_b fod,
                   fem_cal_periods_attr    fcpa
             WHERE fxd.dimension_id                 = gcs_utility_pkg.g_gcs_dimension_info (l_index_column_name).dimension_id
               AND fxd.default_mvs_hierarchy_obj_id = fod.object_id
               AND fcpa.cal_period_id               = p_cal_period_id
               AND fcpa.attribute_id                = l_cal_attribute_id
               AND fcpa.version_id                  = l_cal_version_id
               AND fcpa.date_assign_value BETWEEN fod.effective_start_date AND fod.effective_end_date;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                raise gcs_dp_no_hier_obj_def_id;
            END;
  
            IF (l_index_column_name = 'NATURAL_ACCOUNT_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fnah.parent_id, ';
                l_from_text        := l_from_text || ', fem_nat_accts_hier fnah ';
                l_where_text       := l_where_text
                                      || ' AND fnah.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id
                                      || ' AND fnah.parent_depth_num = fnah.child_depth_num - 1
                                            AND fnah.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fnah.child_id = fb.NATURAL_ACCOUNT_ID
                                            AND fnah.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('NATURAL_ACCOUNT_ID').associated_value_set_id;
                l_group_text      := replace(l_group_text, 'fb.'||l_index_column_name, 'fnah.parent_id ');
            ELSIF (l_index_column_name = 'COMPANY_COST_CENTER_ORG_ID')
            THEN
                l_cctr_map_required := TRUE;
                g_insert_statement  := g_insert_statement
                                       || 'fcoh.parent_id, ';
                l_from_text         := l_from_text || ', fem_cctr_orgs_hier fcoh ';
                l_where_text        := l_where_text
                                       || '  AND fcoh.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id
                                       || '  AND fcoh.parent_depth_num = fcoh.child_depth_num - 1
                                              AND fcoh.child_value_set_id = ' || l_source_value_set_id || '
                                              AND fcoh.child_id = fb.COMPANY_COST_CENTER_ORG_ID
                                              AND fcoh.parent_value_set_id = '
                                       || gcs_utility_pkg.g_gcs_dimension_info ('COMPANY_COST_CENTER_ORG_ID').associated_value_set_id;
                l_group_text        := replace(l_group_text, 'fb.'||l_index_column_name, 'fcoh.parent_id ');
            ELSIF (l_index_column_name = 'INTERCOMPANY_ID')
            THEN
                g_insert_statement  := g_insert_statement
                                       || 'fcoh_inter.parent_id, ';
                l_from_text         := l_from_text || ', fem_cctr_orgs_hier fcoh_inter ';
                l_where_text        := l_where_text
                                       || '  AND fcoh_inter.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                              AND fcoh_inter.parent_depth_num = fcoh_inter.child_depth_num - 1
                                              AND fcoh_inter.child_value_set_id = ' || l_source_value_set_id || '
                                              AND fcoh_inter.child_id = fb.INTERCOMPANY_ID
                                              AND fcoh_inter.parent_value_set_id = '
                                       || gcs_utility_pkg.g_gcs_dimension_info ('INTERCOMPANY_ID').associated_value_set_id;
                l_group_text        := replace(l_group_text, 'fb.'||l_index_column_name, 'fcoh_inter.parent_id ');
            ELSIF (l_index_column_name = 'LINE_ITEM_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'flih.parent_id, ';
                l_from_text        := l_from_text || ', fem_ln_items_hier flih ';
                l_where_text       := l_where_text
                                      || ' AND flih.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND flih.parent_depth_num = flih.child_depth_num - 1
                                            AND flih.child_value_set_id = ' || l_source_value_set_id || '
                                            AND flih.child_id = fb.LINE_ITEM_ID
                                            AND flih.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'flih.parent_id ');
                g_ln_item_vs_id    := l_source_value_set_id;
            ELSIF (l_index_column_name = 'PRODUCT_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fpdh.parent_id, ';
                l_from_text        := l_from_text || ', fem_products_hier fpdh ';
                l_where_text       := l_where_text
                                      || ' AND fpdh.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fpdh.parent_depth_num = fpdh.child_depth_num - 1
                                            AND fpdh.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fpdh.child_id = fb.PRODUCT_ID
                                            AND fpdh.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('PRODUCT_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fpdh.parent_id ');
            ELSIF (l_index_column_name = 'PROJECT_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fpjh.parent_id, ';
                l_from_text        := l_from_text || ', fem_projects_hier fpjh ';
                l_where_text       := l_where_text
                                      || ' AND fpjh.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fpjh.parent_depth_num = fpjh.child_depth_num - 1
                                            AND fpjh.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fpjh.child_id = fb.PROJECT_ID
                                            AND fpjh.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('PROJECT_ID').associated_value_set_id;
                l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fpjh.parent_id ');
            ELSIF (l_index_column_name = 'CHANNEL_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fchh.parent_id, ';
                l_from_text        := l_from_text || ', fem_channels_hier fchh ';
                l_where_text       := l_where_text
                                      || ' AND fchh.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fchh.parent_depth_num = fchh.child_depth_num - 1
                                            AND fchh.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fchh.child_id = fb.CHANNEL_ID
                                            AND fchh.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('CHANNEL_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fchh.parent_id ');
            ELSIF (l_index_column_name = 'CUSTOMER_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fcuh.parent_id, ';
                l_from_text        := l_from_text || ', fem_customers_hier fcuh ';
                l_where_text       := l_where_text
                                      || ' AND fcuh.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fcuh.parent_depth_num = fcuh.child_depth_num - 1
                                            AND fcuh.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fcuh.child_id = fb.CUSTOMER_ID
                                            AND fcuh.parent_value_set_id = '
                                      ||  gcs_utility_pkg.g_gcs_dimension_info ('CUSTOMER_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fcuh.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM1_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud1h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim1_hier fud1h ';
                l_where_text       := l_where_text
                                      || ' AND fud1h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud1h.parent_depth_num = fud1h.child_depth_num - 1
                                            AND fud1h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud1h.child_id = fb.USER_DIM1_ID
                                            AND fud1h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM1_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fud1h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM2_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud2h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim2_hier fud2h ';
                l_where_text       := l_where_text
                                      || ' AND fud2h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud2h.parent_depth_num = fud2h.child_depth_num - 1
                                            AND fud2h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud2h.child_id = fb.USER_DIM2_ID
                                            AND fud2h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM2_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fud2h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM3_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud3h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim3_hier fud3h ';
                l_where_text       := l_where_text
                                      || ' AND fud3h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud3h.parent_depth_num = fud3h.child_depth_num - 1
                                            AND fud3h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud3h.child_id = fb.USER_DIM3_ID
                                            AND fud3h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM3_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fud3h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM4_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud4h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim4_hier fud4h ';
                l_where_text       := l_where_text
                                      || ' AND fud4h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud4h.parent_depth_num = fud4h.child_depth_num - 1
                                            AND fud4h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud4h.child_id = fb.USER_DIM4_ID
                                            AND fud4h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM4_ID').associated_value_set_id;
                l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fud4h.parent_id ');
           ELSIF (l_index_column_name = 'USER_DIM5_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud5h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim5_hier fud5h ';
                l_where_text       := l_where_text
                                      || ' AND fud5h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud5h.parent_depth_num = fud5h.child_depth_num - 1
                                            AND fud5h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud5h.child_id = fb.USER_DIM5_ID
                                            AND fud5h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM5_ID').associated_value_set_id;
               l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fud5h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM6_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud6h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim6_hier fud6h ';
                l_where_text       := l_where_text
                                      || ' AND fud6h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud6h.parent_depth_num = fud6h.child_depth_num - 1
                                            AND fud6h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud6h.child_id = fb.USER_DIM6_ID
                                            AND fud6h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM6_ID').associated_value_set_id;
                l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fud7h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM7_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud7h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim7_hier fud7h ';
                l_where_text       := l_where_text
                                      || ' AND fud7h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud7h.parent_depth_num = fud7h.child_depth_num - 1
                                            AND fud7h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud7h.child_id = fb.USER_DIM7_ID
                                            AND fud7h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM7_ID').associated_value_set_id;
                l_group_text       := replace(l_group_text, 'fb.'||l_index_column_name, 'fud7h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM8_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud8h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim8_hier fud8h ';
                l_where_text       := l_where_text
                                      || ' AND fud8h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud8h.parent_depth_num = fud8h.child_depth_num - 1
                                            AND fud8h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud8h.child_id = fb.USER_DIM8_ID
                                            AND fud8h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM8_ID').associated_value_set_id;
                l_group_text      := replace(l_group_text, 'fb.'||l_index_column_name, 'fud8h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM9_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud9h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim9_hier fud9h ';
                l_where_text       := l_where_text
                                      || ' AND fud9h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud9h.parent_depth_num = fud9h.child_depth_num - 1
                                            AND fud9h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud9h.child_id = fb.USER_DIM9_ID
                                            AND fud9h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM9_ID').associated_value_set_id;
                l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fud9h.parent_id ');
            ELSIF (l_index_column_name = 'USER_DIM10_ID')
            THEN
                g_insert_statement := g_insert_statement
                                      || 'fud10h.parent_id, ';
                l_from_text        := l_from_text || ', fem_user_dim10_hier fud10h ';
                l_where_text       := l_where_text
                                      || ' AND fud10h.hierarchy_obj_def_id = ' || l_hierarchy_obj_def_id || '
                                            AND fud10h.parent_depth_num = fud10h.child_depth_num - 1
                                            AND fud10h.child_value_set_id = ' || l_source_value_set_id || '
                                            AND fud10h.child_id = fb.USER_DIM10_ID
                                            AND fud10h.parent_value_set_id = '
                                      || gcs_utility_pkg.g_gcs_dimension_info ('USER_DIM10_ID').associated_value_set_id;
                l_group_text := replace(l_group_text, 'fb.'||l_index_column_name, 'fud10h.parent_id ');
            END IF;
         END IF;
         <<next_loop>>
         l_index_column_name :=gcs_utility_pkg.g_gcs_dimension_info.NEXT (l_index_column_name);
      END LOOP;
        
      IF (p_inc_mode_flag = 'Y') THEN
           g_insert_statement := g_insert_statement ||   '
                  SUM(fb.ptd_debit_balance_e) PTD_DEBIT_BALANCE_E,
                  SUM(fb.ptd_credit_balance_e) PTD_CREDIT_BALANCE_E,
                  SUM(fb.ytd_debit_balance_e) 	YTD_DEBIT_BALANCE_E,
                  SUM(fb.ytd_credit_balance_e) 	YTD_CREDIT_BALANCE_E,
                  SUM(NVL(fb.xtd_balance_f, fb.xtd_balance_e)) XTD_BALANCE_E,
                  SUM(NVL(fb.ytd_balance_f, fb.ytd_balance_e)) YTD_BALANCE_E,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.LOGIN_ID ';
           l_from_text := '
         FROM  fem_balances  fb,
               fem_ledgers_attr fla,
               gcs_entity_cctr_orgs geco,
               gcs_cons_impact_analyses gcia,
               gcs_data_sub_dtls gdsd '|| l_from_text;
           l_where_text :=
         '
      WHERE fb.ledger_id = :p_source_ledger_id
        AND fb.source_system_code = fla.DIM_ATTRIBUTE_NUMERIC_MEMBER
        AND fla.ledger_id = fb.ledger_id
        AND fla.attribute_id = gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-SOURCE_SYSTEM_CODE'').attribute_id
        AND fla.version_id = gcs_utility_pkg.g_dimension_attr_info(''LEDGER_ID-SOURCE_SYSTEM_CODE'').version_id
        AND fb.company_cost_center_org_id = geco.company_cost_center_org_id
        AND geco.entity_id = :p_entity_id
        AND :p_balance_type_code = DECODE(fb.financial_elem_id, 140, ''ADB'', ''ACTUAL'')
	AND ((fb.currency_type_code = ''TRANSLATED'' AND fb.currency_code in (''STAT'', :p_source_currency_code))
            or (fb.currency_type_code = ''ENTERED''))
        AND fb.currency_type_code			=       :p_currency_type_code
        AND fb.dataset_code = :p_source_dataset_code
        AND fb.last_updated_by_request_id = gdsd.associated_request_id
        AND gcia.run_name = :p_run_name
        AND gcia.child_entity_id = :p_entity_id
        AND gcia.load_id = gdsd.load_id
        '||l_where_text;
      ELSE
           g_insert_statement := g_insert_statement || '
                         fb.ptd_debit_balance_e,
                         fb.ptd_credit_balance_e,
                         DECODE (fb.cal_period_id,
                                 :p_max_period, ytd_debit_balance_e, 0
                             ) ytd_debit_balance_e,
                         DECODE (fb.cal_period_id,
                                 :p_max_period, ytd_credit_balance_e, 0
                             ) ytd_credit_balance_e,
                         NVL(fb.ptd_debit_balance_e,0) - NVL(fb.ptd_credit_balance_e,0),
                         DECODE (fb.cal_period_id,
                                 :p_max_period, NVL(fb.ytd_debit_balance_e,0) - NVL (fb.ytd_credit_balance_e,0), 0
                             ) ytd_balance_e 
';
           l_from_text := '
         FROM  fem_balances  fb,
               gcs_entity_cctr_orgs geco '|| l_from_text;
           l_where_text := '
      WHERE :source_cal_period_id		= 	fb.cal_period_id
        AND fb.ledger_id            = :p_source_ledger_id
        AND fb.source_system_code   = :source_system_code
        AND fb.currency_type_code   = :p_currency_type_code
        AND fb.company_cost_center_org_id = geco.company_cost_center_org_id
        AND geco.entity_id          = :p_entity_id
	      AND fb.dataset_code         = :source_dataset_code '||l_where_text;
      END IF;
      if (l_cctr_map_required) then
        l_where_text := replace(l_where_text,
                'AND fb.company_cost_center_org_id = geco.company_cost_center_org_id',
                'AND fcoh.parent_id = geco.company_cost_center_org_id');
      end if;
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            ' g_insert_statement = '|| g_insert_statement
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            ' l_from_text = '|| l_from_text
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            ' l_where_text = '|| l_where_text
                        );
      END IF;
      g_insert_statement := g_insert_statement
         || l_from_text
         || l_where_text;
      retcode := gcs_utility_pkg.g_ret_sts_success;
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' Mapping Required : '
                         || l_mapping_required
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
      RETURN l_mapping_required;
    EXCEPTION
      WHEN gcs_dp_no_hier_obj_def_id THEN
        retcode := gcs_utility_pkg.g_ret_sts_error;
        fnd_message.set_name('GCS', 'GCS_DP_NO_HIER_OBJ_DEF_ERR');
        fnd_message.set_token('DIMENSION', l_index_column_name);
        errbuf := fnd_message.get;
        IF fnd_log.g_current_runtime_level <= fnd_log.level_error
        THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || ' ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
        RETURN retcode;
      WHEN global_vs_id_error THEN
        retcode := gcs_utility_pkg.g_ret_sts_error;
        FND_MESSAGE.set_name('GCS', 'GCS_DP_GLOBAL_VS_ERR');
        errbuf := fnd_message.get;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || ' ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
        RETURN retcode;
      WHEN OTHERS THEN
        retcode := gcs_utility_pkg.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.set_name('GCS', 'GCS_DP_UNEXP_ERR');
        errbuf := fnd_message.get;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || ' ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
        RETURN retcode;
   END init_local_to_master_maps;

--
-- Public Procedures
--
   PROCEDURE process_data (
      p_source_currency_code      IN              VARCHAR2,
      p_target_cal_period_id      IN              NUMBER,
      p_max_period                IN              NUMBER,
      p_currency_type_code        IN              VARCHAR2,
      p_hierarchy_id              IN              NUMBER,
      p_entity_id                 IN              NUMBER,
      p_source_ledger_id          IN              NUMBER,
      p_year_end_values_match     IN              VARCHAR2,
      p_cal_period_record         IN              gcs_utility_pkg.r_cal_period_info,
      p_balance_type_code         IN              VARCHAR2,
      p_owner_percentage          IN              NUMBER,
      p_run_detail_id             IN              NUMBER,
      p_source_dataset_code       IN              NUMBER,
      errbuf                      OUT NOCOPY      VARCHAR2,
      retcode                     OUT NOCOPY      VARCHAR2
   )
   IS
      l_has_row_flag              VARCHAR2 (1);
      l_has_stat_row_flag         VARCHAR2 (1);
      l_first_ever_data_prepped   VARCHAR2 (1);
      l_temp_record               gcs_templates_pkg.templaterecord;
      l_threshold                 NUMBER;
      l_threshold_currency        VARCHAR2(15);
      l_entry_id                  NUMBER (15) := NULL;
      l_stat_entry_id             NUMBER (15) := NULL;
      l_proportional_entry_id     NUMBER (15) := NULL;
      l_stat_proportional_entry_id NUMBER (15):= NULL;
      l_mapping_required          VARCHAR2 (1);
      l_precision                 NUMBER;
      l_stat_precision            NUMBER;
      l_api_name                  VARCHAR2 (20) := 'PROCESS_DATA';
      l_imap_enabled_flag         VARCHAR2 (1);
      l_source_system_code        NUMBER;
      l_periods_list              DBMS_SQL.number_table;

      -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period

      l_period_end_date_attr      NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
      l_period_end_date_version   NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id ;

      -- Bugfix 6068527: Added account type attributes
      l_line_item_type_attr      NUMBER(15) :=
                                 gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;
      l_line_item_type_version   NUMBER(15) :=
                                 gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;
      l_acct_type_attr           NUMBER(15) :=
                                 gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;
      l_acct_type_version        NUMBER(15)      :=
                                 gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;

  BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_source_currency_code = ' || p_source_currency_code
                         || ', p_target_cal_period_id = ' || p_target_cal_period_id
                         || ', p_max_period = ' || p_max_period
                         || ', p_currency_type_code = ' || p_currency_type_code
                         || ', p_hierarchy_id = ' || p_hierarchy_id
                         || ', p_entity_id = ' || p_entity_id
                         || ', p_source_ledger_id = ' || p_source_ledger_id
                         || ', p_year_end_values_match = ' || p_year_end_values_match
                         || ', p_balance_type_code = ' || p_balance_type_code
                         || ', p_owner_percentage = ' || p_owner_percentage
                         || ', p_run_detail_id = ' || p_run_detail_id
                         || ', p_source_dataset_code = ' || p_source_dataset_code
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      -- init local_to_master mappping
      l_mapping_required := init_local_to_master_maps (p_source_ledger_id => p_source_ledger_id,
                p_cal_period_id => p_cal_period_record.cal_period_id,
                errbuf => errbuf,
                retcode => retcode);

      IF (retcode <> gcs_utility_pkg.g_ret_sts_success)
      THEN
         RAISE init_mapping_error;
      END IF;

      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                         'Mapping required flag: ' || l_mapping_required);
      END IF;

      -- bug fix 5074999: raise no_data_error when source_system_code not found

      -- Bugfix 5843592, Get the source_system_code of the correct entity, depending upon the calendar period

      BEGIN
        SELECT gea.source_system_code
          INTO l_source_system_code
          FROM gcs_entities_attr gea,
               fem_cal_periods_attr fcpa
         WHERE gea.entity_id          = p_entity_id
           AND gea.data_type_code     = p_balance_type_code
           AND fcpa.cal_period_id     = p_target_cal_period_id
           AND fcpa.attribute_id      = l_period_end_date_attr
           AND fcpa.version_id        = l_period_end_date_version
           AND fcpa.date_assign_value BETWEEN gea.effective_start_date
	                       	                AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;


        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
           fnd_log.STRING (fnd_log.level_statement,
                           g_pkg_name || '.' || l_api_name,
                           'Source system code: ' || l_source_system_code);
        END IF;
      EXCEPTION
        WHEN no_data_found THEN
          RAISE no_data_error;
      END;

      -- bug fix 5074999: remove join to p_balance_type_code, which is redundant and incorrect
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
        'SELECT cpmgt.source_cal_period_id cal_period_id
          BULK COLLECT INTO l_periods_list
          FROM fem_data_locations     fdl,
               gcs_cal_period_maps_gt cpmgt
        WHERE fdl.ledger_id = ' ||p_source_ledger_id||'
          AND fdl.cal_period_id = cpmgt.source_cal_period_id
          AND fdl.source_system_code = '||l_source_system_code||'
          AND fdl.dataset_code = ' ||p_source_dataset_code||'
          AND fdl.table_name = ''FEM_BALANCES''');
        END IF;

        SELECT cpmgt.source_cal_period_id cal_period_id
          BULK COLLECT INTO l_periods_list
          FROM fem_data_locations     fdl,
               gcs_cal_period_maps_gt cpmgt
        WHERE fdl.ledger_id = p_source_ledger_id
          AND fdl.cal_period_id = cpmgt.source_cal_period_id
          AND fdl.source_system_code = l_source_system_code
          AND fdl.dataset_code = p_source_dataset_code
          AND fdl.table_name = 'FEM_BALANCES';

      IF l_periods_list.FIRST IS NULL THEN
          RAISE no_data_error;
      END IF;

      SELECT gcs_entry_headers_s.NEXTVAL
        INTO l_entry_id
        FROM DUAL;
      SELECT gcs_entry_headers_s.NEXTVAL
        INTO l_stat_entry_id
        FROM DUAL;

    -------------------------------------------
    -- this is the mapping not required case --
    -------------------------------------------
     IF (l_mapping_required = 'N') THEN
       IF (p_balance_type_code = 'ADB' AND p_currency_type_code = 'ENTERED') THEN
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST

            INSERT INTO gcs_entry_lines_gt
                        (entry_id, cal_period_id, 
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e)
 SELECT  decode(fb.currency_code, 'STAT', l_stat_entry_id, l_entry_id),  fb.cal_period_id, 
                         fb.ptd_debit_balance_e,
                         fb.ptd_credit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_debit_balance_e, 0
                             ) ytd_debit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_credit_balance_e, 0
                             ) ytd_credit_balance_e,
                         NVL(fb.ptd_debit_balance_e,0) - NVL(fb.ptd_credit_balance_e,0),
                         DECODE (fb.cal_period_id,
                                 p_max_period, NVL(fb.ytd_debit_balance_e,0) - NVL (fb.ytd_credit_balance_e,0), 0
                             ) ytd_balance_e 

         FROM  fem_balances  fb,
               gcs_entity_cctr_orgs geco 
        WHERE l_periods_list(counter)		= 	fb.cal_period_id
          AND fb.source_system_code = l_source_system_code
          AND fb.ledger_id = p_source_ledger_id
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND fb.dataset_code = p_source_dataset_code 
          AND fb.currency_code IN (p_source_currency_code, 'STAT')
          AND fb.financial_elem_id = 140;
       ELSIF (p_balance_type_code = 'ADB') THEN
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST

            INSERT INTO gcs_entry_lines_gt
                        (entry_id, cal_period_id, 
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e)
 SELECT  decode(fb.currency_code, 'STAT', l_stat_entry_id, l_entry_id),  fb.cal_period_id, 
                         fb.ptd_debit_balance_e,
                         fb.ptd_credit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_debit_balance_e, 0
                             ) ytd_debit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_credit_balance_e, 0
                             ) ytd_credit_balance_e,
                         NVL(fb.ptd_debit_balance_e,0) - NVL(fb.ptd_credit_balance_e,0),
                         DECODE (fb.cal_period_id,
                                 p_max_period, NVL(fb.ytd_debit_balance_e,0) - NVL (fb.ytd_credit_balance_e,0), 0
                             ) ytd_balance_e 

         FROM  fem_balances  fb,
               gcs_entity_cctr_orgs geco 
        WHERE l_periods_list(counter)		= 	fb.cal_period_id
          AND fb.source_system_code = l_source_system_code
          AND fb.ledger_id = p_source_ledger_id
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND fb.dataset_code = p_source_dataset_code 
          AND fb.financial_elem_id = 140
          AND fb.currency_code = p_source_currency_code;
       ELSIF (p_currency_type_code = 'ENTERED') THEN
         --Bugfix 5232063: Do not assume Financial Element is populated
         --Bugfix 5329620: Added l_curr_where_clause
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST

            INSERT INTO gcs_entry_lines_gt
                        (entry_id, cal_period_id, 
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e)
 SELECT  decode(fb.currency_code, 'STAT', l_stat_entry_id, l_entry_id),  fb.cal_period_id, 
                         fb.ptd_debit_balance_e,
                         fb.ptd_credit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_debit_balance_e, 0
                             ) ytd_debit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_credit_balance_e, 0
                             ) ytd_credit_balance_e,
                         NVL(fb.ptd_debit_balance_e,0) - NVL(fb.ptd_credit_balance_e,0),
                         DECODE (fb.cal_period_id,
                                 p_max_period, NVL(fb.ytd_debit_balance_e,0) - NVL (fb.ytd_credit_balance_e,0), 0
                             ) ytd_balance_e 

         FROM  fem_balances  fb,
               gcs_entity_cctr_orgs geco 
        WHERE l_periods_list(counter)		= 	fb.cal_period_id
          AND fb.source_system_code = l_source_system_code
          AND fb.ledger_id = p_source_ledger_id
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND fb.dataset_code = p_source_dataset_code 
          AND fb.currency_code = p_source_currency_code;
       ELSE
         --Bugfix 5232063: Do not assume Financial Element is populated
         --Bugfix 5329620: Added l_curr_where_clause
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST

            INSERT INTO gcs_entry_lines_gt
                        (entry_id, cal_period_id, 
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e)
 SELECT  decode(fb.currency_code, 'STAT', l_stat_entry_id, l_entry_id),  fb.cal_period_id, 
                         fb.ptd_debit_balance_e,
                         fb.ptd_credit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_debit_balance_e, 0
                             ) ytd_debit_balance_e,
                         DECODE (fb.cal_period_id,
                                 p_max_period, ytd_credit_balance_e, 0
                             ) ytd_credit_balance_e,
                         NVL(fb.ptd_debit_balance_e,0) - NVL(fb.ptd_credit_balance_e,0),
                         DECODE (fb.cal_period_id,
                                 p_max_period, NVL(fb.ytd_debit_balance_e,0) - NVL (fb.ytd_credit_balance_e,0), 0
                             ) ytd_balance_e 

         FROM  fem_balances  fb,
               gcs_entity_cctr_orgs geco 
        WHERE l_periods_list(counter)		= 	fb.cal_period_id
          AND fb.source_system_code = l_source_system_code
          AND fb.ledger_id = p_source_ledger_id
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND fb.dataset_code = p_source_dataset_code 
          AND fb.currency_code = p_source_currency_code;
       END IF; -- p_balance_type_code

    ELSE---------------------------------------
    -- this is the mapping required case --
    ---------------------------------------
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            ' g_insert_statement = '
                         || g_insert_statement
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            '       FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST '
                         || g_nl
                         || ' EXECUTE IMMEDIATE g_insert_statement '
                         || g_nl
                         || ' USING '
                         || l_stat_entry_id || ', ' || l_entry_id ||', '
                         || p_max_period ||', '|| p_max_period ||', ' || p_max_period ||', '
                         || ' l_periods_list(counter), ' || p_source_ledger_id ||', '
                         || ' l_source_system_code, '
                         || p_currency_type_code ||', '
                         || p_entity_id ||', '|| p_balance_type_code ||', '
                         || p_source_currency_code ||', '
                         || ' p_source_dataset_code '
                         || ' p_source_currency_code '
                        );
      END IF;

       IF (p_balance_type_code = 'ADB' AND p_currency_type_code = 'ENTERED') THEN
         g_insert_statement := g_insert_statement || '
                  AND fb.financial_elem_id = 140
                  AND fb.currency_code IN (:p_source_currency_code, ''STAT'') ';
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST
          EXECUTE IMMEDIATE g_insert_statement
                      USING l_stat_entry_id, l_entry_id,
                            p_max_period, p_max_period, p_max_period,
                            l_periods_list(counter), p_source_ledger_id,
                            l_source_system_code,
                            p_currency_type_code, p_entity_id,
                            p_source_dataset_code, p_source_currency_code;
       ELSIF (p_balance_type_code = 'ADB') THEN
         g_insert_statement := g_insert_statement || '
                  AND fb.financial_elem_id = 140
                  AND fb.currency_code = :p_source_currency_code ';
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST
          EXECUTE IMMEDIATE g_insert_statement
                      USING l_stat_entry_id, l_entry_id,
                            p_max_period, p_max_period, p_max_period,
                            l_periods_list(counter), p_source_ledger_id,
                            l_source_system_code,
                            p_currency_type_code, p_entity_id, p_source_dataset_code,
                            p_source_currency_code;
       ELSIF (p_currency_type_code = 'ENTERED') THEN
         --Bugfix 5232063: Do not assume Financial Element is populated
         --Bugfix 5329620: Added curr_vs_map_where clause
         g_insert_statement := g_insert_statement || '
          AND fb.currency_code = :p_source_currency_code';
         FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST
          EXECUTE IMMEDIATE g_insert_statement
                      USING l_stat_entry_id, l_entry_id,
                            p_max_period, p_max_period, p_max_period,
                            l_periods_list(counter), p_source_ledger_id,
                            l_source_system_code,
                            p_currency_type_code, p_entity_id,
                            p_source_dataset_code, p_source_currency_code;
       ELSE
         --Bugfix 5232063: Do not assume Financial Element is populated
         --Bugfix 5329620: Added curr_vs_map_where clause
         g_insert_statement := g_insert_statement  || '
          AND fb.currency_code = :p_source_currency_code';
        FORALL counter IN l_periods_list.FIRST..l_periods_list.LAST
          EXECUTE IMMEDIATE g_insert_statement
                      USING l_stat_entry_id, l_entry_id,
                            p_max_period, p_max_period, p_max_period,
                            l_periods_list(counter), p_source_ledger_id,
                            l_source_system_code,
                            p_currency_type_code, p_entity_id, p_source_dataset_code,
                            p_source_currency_code;
       END IF; -- p_balance_type_code

      END IF; -- end of mapping required check

      -- check if there's any data selected
      IF (SQL%ROWCOUNT = 0) THEN
          RAISE no_data_error;
      END IF;

      BEGIN
          SELECT 'Y'
            INTO l_has_row_flag
            FROM DUAL
           WHERE EXISTS (SELECT 1 FROM gcs_entry_lines_gt WHERE entry_id = l_entry_id);

           gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => l_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => p_source_currency_code,
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
            IF p_owner_percentage IS NOT NULL AND p_owner_percentage <> 1 THEN
                SELECT gcs_entry_headers_s.NEXTVAL
                  INTO l_proportional_entry_id
                  FROM DUAL;

                gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => l_proportional_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => p_source_currency_code,
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
            END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_has_row_flag := 'N';
              l_entry_id := NULL;
      END;
      BEGIN
          SELECT 'Y'
            INTO l_has_stat_row_flag
            FROM DUAL
           WHERE EXISTS (SELECT 1 FROM gcs_entry_lines_gt WHERE entry_id = l_stat_entry_id);

          gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => l_stat_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => 'STAT',
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );

            IF p_owner_percentage IS NOT NULL AND p_owner_percentage <> 1 THEN
                SELECT gcs_entry_headers_s.NEXTVAL
                  INTO l_stat_proportional_entry_id
                  FROM DUAL;

                gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => l_stat_proportional_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => 'STAT',
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
            END IF;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_has_stat_row_flag := 'N';
              l_stat_entry_id := NULL;
      END;

      -- insert data into gcs_entry_lines table
      IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
      THEN
          fnd_log.STRING (fnd_log.level_statement,
                          g_pkg_name || '.' || l_api_name,
                          '
            INSERT /*+ APPEND */ INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )

       SELECT /*+ PARALLEL (fb) */ fb.entry_id, 
              SUM (NVL (fb.ptd_debit_balance_e, 0)),
              SUM (NVL (fb.ptd_credit_balance_e, 0)),
              SUM (NVL (ytd_debit_balance_e, 0)),
              SUM (NVL (ytd_credit_balance_e, 0)),
              SUM(DECODE(fea_attr.dim_attribute_varchar_member, ''REVENUE'', NVL(xtd_balance_e,0),
                                                            ''EXPENSE'', NVL(xtd_balance_e,0),
                                                            NVL(ytd_balance_e,0))),
              SUM (NVL (ytd_balance_e, 0)),
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.LOGIN_ID
         FROM gcs_entry_lines_gt fb,
              fem_ln_items_attr       flia,
              fem_ext_acct_types_attr fea_attr
       WHERE  fb.line_item_id                   =  flia.line_item_id
         AND  flia.attribute_id                  =  l_line_item_type_attr
         AND  flia.version_id                   =  l_line_item_type_version
         AND  flia.dim_attribute_varchar_member =  fea_attr.ext_account_type_code
         AND  fea_attr.attribute_id             =  l_acct_type_attr
         AND  fea_attr.version_id               =  l_acct_type_version
     GROUP BY  entry_id;'
                        );
      END IF;


            INSERT /*+ APPEND */ INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )

       SELECT /*+ PARALLEL (fb) */ fb.entry_id, 
              SUM (NVL (fb.ptd_debit_balance_e, 0)),
              SUM (NVL (fb.ptd_credit_balance_e, 0)),
              SUM (NVL (ytd_debit_balance_e, 0)),
              SUM (NVL (ytd_credit_balance_e, 0)),
              SUM(DECODE(fea_attr.dim_attribute_varchar_member, 'REVENUE', NVL(xtd_balance_e,0),
                                                            'EXPENSE', NVL(xtd_balance_e,0),
                                                            NVL(ytd_balance_e,0))),
              SUM (NVL (ytd_balance_e, 0)),
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.LOGIN_ID
         FROM gcs_entry_lines_gt fb,
              fem_ln_items_attr       flia,
              fem_ext_acct_types_attr fea_attr
       WHERE  fb.line_item_id                   =  flia.line_item_id
         AND  flia.attribute_id                  =  l_line_item_type_attr
         AND  flia.version_id                   =  l_line_item_type_version
         AND  flia.dim_attribute_varchar_member =  fea_attr.ext_account_type_code
         AND  fea_attr.attribute_id             =  l_acct_type_attr
         AND  fea_attr.version_id               =  l_acct_type_version
     GROUP BY  entry_id;

      COMMIT;

      -- recalculate P/L AND Retained Earnings accounts if year ends not match
      IF (l_entry_id IS NOT NULL AND p_year_end_values_match = 'N') THEN
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '         SELECT decode(count(run_name), 0, ''Y'', ''N'')
                                     INTO l_first_ever_data_prepped
                                     FROM gcs_cons_eng_runs
                                    WHERE hierarchy_id = '||p_hierarchy_id||'
                                      AND run_entity_id = '||p_entity_id||'
                                      AND balance_type_code = '||p_balance_type_code||'
                                      AND (cal_period_id = '||p_cal_period_record.prev_cal_period_id||'
                                            OR (cal_period_id = '||p_cal_period_record.cal_period_id||'
                                      AND status_code NOT IN (''NOT_STARTED'', ''IN_PROGRESS'')))');
             END IF;
                 SELECT decode(count(run_name), 0, 'Y', 'N')
                   INTO l_first_ever_data_prepped
                   FROM gcs_cons_eng_runs
                  WHERE hierarchy_id = p_hierarchy_id
                    AND run_entity_id = p_entity_id
                    AND balance_type_code = p_balance_type_code
                    AND (     cal_period_id = p_cal_period_record.prev_cal_period_id
                          OR (cal_period_id = p_cal_period_record.cal_period_id
                          AND status_code NOT IN ('NOT_STARTED', 'IN_PROGRESS')));
         IF (   l_first_ever_data_prepped = 'Y' OR p_cal_period_record.cal_period_number = 1 )
         THEN
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '            UPDATE gcs_entry_lines gel
                                         SET gel.ytd_balance_e        = gel.xtd_balance_e,
                                             gel.ytd_debit_balance_e  = gel.ptd_debit_balance_e,
                                             gel.ytd_credit_balance_e = gel.ptd_credit_balance_e
                                       WHERE gel.entry_id = '||l_entry_id ||'
                                         AND EXISTS ( SELECT ''X''
                                                        FROM fem_ln_items_attr flia,
                                                             fem_ext_acct_types_attr feata
                                                       WHERE feata.dim_attribute_varchar_member IN (''REVENUE'', ''EXPENSE'')
                                                         AND flia.attribute_id ='|| g_li_eat_attr_id ||'
                                                         AND flia.version_id ='|| g_li_eat_ver_id ||'
                                                         AND flia.value_set_id ='|| g_li_vs_id ||'
                                                         AND feata.attribute_id = ' || g_eatc_batc_attr_id || '
                                                         AND feata.version_id = ' || g_eatc_batc_ver_id || '
                                                         AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
                                                         AND gel.line_item_id = flia.line_item_id)');
             END IF;
            UPDATE gcs_entry_lines gel
               SET gel.ytd_balance_e        = gel.xtd_balance_e,
                   gel.ytd_debit_balance_e  = gel.ptd_debit_balance_e,
                   gel.ytd_credit_balance_e = gel.ptd_credit_balance_e
             WHERE gel.entry_id = l_entry_id
               AND EXISTS ( SELECT 'X'
                              FROM fem_ln_items_attr flia,
                                   fem_ext_acct_types_attr feata
                             WHERE feata.dim_attribute_varchar_member IN ('REVENUE', 'EXPENSE')
                               AND flia.attribute_id = g_li_eat_attr_id
                               AND flia.version_id = g_li_eat_ver_id
                               AND flia.value_set_id = g_li_vs_id
                               AND feata.attribute_id = g_eatc_batc_attr_id
                               AND feata.version_id = g_eatc_batc_ver_id
                               AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
                               AND gel.line_item_id = flia.line_item_id);
        ELSE
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '            UPDATE gcs_entry_lines gel
                                         SET (gel.ytd_balance_e, gel.ytd_credit_balance_e,gel.ytd_debit_balance_e) =
                                              (SELECT   NVL (fb.ytd_balance_e, 0)
                                                      + NVL (gel.xtd_balance_e, 0),
                                                        NVL (fb.ytd_credit_balance_e, 0)
                                                      + NVL (gel.ptd_credit_balance_e, 0),
                                                        NVL (fb.ytd_debit_balance_e, 0)
                                                      + NVL (gel.ptd_debit_balance_e, 0)
                                                 FROM fem_balances fb,
                                                      fem_ln_items_attr flia,
                                                     fem_ext_acct_types_attr feata
                                               WHERE feata.dim_attribute_varchar_member IN
                                                                               (''REVENUE'', ''EXPENSE'')
                                                 AND flia.attribute_id ='|| g_li_eat_attr_id ||'
                                                 AND flia.version_id ='|| g_li_eat_ver_id ||'
                                                 AND flia.value_set_id ='|| g_li_vs_id ||'
                                                 AND feata.attribute_id = ' || g_eatc_batc_attr_id || '
                                                 AND feata.version_id = ' || g_eatc_batc_ver_id || '
                                                 AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
                                                 AND fb.cal_period_id ='|| p_cal_period_record.prev_cal_period_id||'
                                                 AND fb.line_item_id = flia.line_item_id
                                                 AND fb.source_system_code = ' || l_source_system_code||'
)
                                       WHERE gel.entry_id = '||l_entry_id);
             END IF;
             UPDATE gcs_entry_lines gel
                SET (gel.ytd_balance_e, gel.ytd_credit_balance_e,gel.ytd_debit_balance_e) =
                      (SELECT   NVL (fb.ytd_balance_e, 0)
                              + NVL (gel.xtd_balance_e, 0),
                                NVL (fb.ytd_credit_balance_e, 0)
                              + NVL (gel.ptd_credit_balance_e, 0),
                                NVL (fb.ytd_debit_balance_e, 0)
                              + NVL (gel.ptd_debit_balance_e, 0)
                         FROM   fem_balances fb,
                                fem_ln_items_attr flia,
                                fem_ext_acct_types_attr feata
                       WHERE feata.dim_attribute_varchar_member IN ('REVENUE', 'EXPENSE')
                         AND flia.attribute_id = g_li_eat_attr_id
                         AND flia.version_id = g_li_eat_ver_id
                         AND flia.value_set_id = g_li_vs_id
                         AND feata.attribute_id = g_eatc_batc_attr_id
                         AND feata.version_id = g_eatc_batc_ver_id
                         AND feata.ext_account_type_code = flia.dim_attribute_varchar_member
                         AND fb.cal_period_id = p_cal_period_record.prev_cal_period_id
                         AND fb.line_item_id = flia.line_item_id
                         AND fb.source_system_code = l_source_system_code
)
                WHERE gel.entry_id = l_entry_id;
        END IF;
        GCS_templates_dynamic_PKG.CALCULATE_DP_RE(p_entry_id             => l_entry_id,
                                                  p_hierarchy_id         => p_hierarchy_id,
                                                  p_bal_type_code        => p_balance_type_code,
                                                  p_entity_id            => p_entity_id,
                                                  p_pre_cal_period_id    => p_cal_period_record.prev_cal_period_id,
                                                  p_first_ever_data_prep => l_first_ever_data_prepped);
      END IF;
      retcode := gcs_utility_pkg.g_ret_sts_success;
      -- Suspense accounts
      IF l_entry_id IS NOT NULL
      THEN
         -- check balance criteria
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '         SELECT threshold_amount,
                                          threshold_currency
                                     INTO l_threshold,
                                          l_threshold_currency
                                     FROM gcs_hierarchies_b
                                    WHERE hierarchy_id = '||p_hierarchy_id);
             END IF;
             SELECT threshold_amount, threshold_currency
               INTO l_threshold, l_threshold_currency
               FROM gcs_hierarchies_b
              WHERE hierarchy_id = p_hierarchy_id;
         BEGIN
            gcs_templates_pkg.get_dimension_template
                                 (p_hierarchy_id           => p_hierarchy_id,
                                  p_template_code          => 'SUSPENSE',
                                  p_balance_type_code      => p_balance_type_code,
                                  p_template_record        => l_temp_record
                                 );
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE no_suspense_template_error;
         END;
         gcs_templates_dynamic_pkg.balance (p_entry_id => l_entry_id,
                                            p_template => l_temp_record,
                                            p_bal_type_code => p_balance_type_code,
                                            p_hierarchy_id => p_hierarchy_id,
                                            p_entity_id => p_entity_id,
                                            p_threshold => l_threshold,
                                            p_threshold_currency_code => l_threshold_currency
                                           );
        --bug fix 3797312
            SELECT DECODE(SUSPENSE_EXCEEDED_FLAG, 'Y', 'WARNING', 'COMPLETED')
              INTO retcode
              FROM gcs_entry_headers
             WHERE entry_id = l_entry_id;
      END IF;
        
      -- bug fix 3800183
      IF (l_proportional_entry_id IS NOT NULL or l_stat_proportional_entry_id IS NOT NULL)
      THEN
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
            fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '        SELECT NVL (fc_1.minimum_accountable_unit, POWER (10, -fc_1.PRECISION)),
                                         NVL (fc_stat.minimum_accountable_unit, POWER (10, -fc_stat.PRECISION))
                                    INTO l_precision,
                                         l_stat_precision
                                    FROM fnd_currencies fc_1, fnd_currencies fc_stat
                                   WHERE fc_1.currency_code    = ' ||p_source_currency_code||'
                                     AND fc_stat.currency_code = ''STAT''');
        END IF;
        SELECT NVL (fc_1.minimum_accountable_unit, POWER (10, -fc_1.PRECISION)),
               NVL (fc_stat.minimum_accountable_unit, POWER (10, -fc_stat.PRECISION))
          INTO l_precision, l_stat_precision
          FROM fnd_currencies fc_1, fnd_currencies fc_stat
         WHERE fc_1.currency_code = p_source_currency_code
           AND fc_stat.currency_code = 'STAT';
            INSERT INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )
               SELECT   decode(entry_id, l_entry_id, l_proportional_entry_id, l_stat_proportional_entry_id),
                         
                         ROUND(ptd_debit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                         ROUND(ptd_credit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                         ROUND(ytd_debit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                         ROUND(ytd_credit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                          ROUND(ptd_debit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision)
                        - ROUND(ptd_credit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                          ROUND(ytd_debit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision)
                        - ROUND(ytd_credit_balance_e * p_owner_percentage/decode(entry_id, l_entry_id, l_precision, l_stat_precision))*decode(entry_id, l_entry_id, l_precision, l_stat_precision),
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                FROM gcs_entry_lines
               WHERE entry_id in ( l_entry_id, l_stat_entry_id);
            -- end of bug fix 3800183
            --bug fix 3797312
            IF l_proportional_entry_id IS NOT NULL THEN
                gcs_templates_dynamic_pkg.balance (p_entry_id                => l_proportional_entry_id,
                                                   p_template                => l_temp_record,
                                                   p_bal_type_code           => p_balance_type_code,
                                                   p_hierarchy_id            => p_hierarchy_id,
                                                   p_entity_id               => p_entity_id,
                                                   p_threshold               => l_threshold,
                                                   p_threshold_currency_code => l_threshold_currency
                                   );
              SELECT decode(SUSPENSE_EXCEEDED_FLAG, 'Y', 'WARNING', 'COMPLETED')
                INTO retcode
                FROM gcs_entry_headers
               WHERE entry_id = l_proportional_entry_id;
            ELSE
            retcode := gcs_utility_pkg.g_ret_sts_success;
            END IF;
            gcs_cons_eng_run_dtls_pkg.update_entry_headers
                                          (p_run_detail_id               => p_run_detail_id,
                                           p_entry_id                    => l_proportional_entry_id,
                                           p_stat_entry_id               => l_stat_proportional_entry_id,
                                           p_pre_prop_entry_id           => l_entry_id,
                                           p_pre_prop_stat_entry_id      => l_stat_entry_id,
                                           p_request_error_code          => retcode,
					   p_bp_request_error_code	 => retcode
                                          );
        ELSE
            gcs_cons_eng_run_dtls_pkg.update_entry_headers
                                          (p_run_detail_id               => p_run_detail_id,
                                           p_entry_id                    => l_entry_id,
                                           p_stat_entry_id               => l_stat_entry_id,
                                           p_pre_prop_entry_id           => l_proportional_entry_id,
                                           p_pre_prop_stat_entry_id      => l_stat_proportional_entry_id,
                                           p_request_error_code          => retcode,
					   p_bp_request_error_code	 => retcode
                                          );
      END IF;
                   -- Check the GCS_SYSTEM_OPTIONS.INTERCO_MAP_ENABLED_FLAG.
                   SELECT NVL(interco_map_enabled_flag,'N')
                     INTO l_imap_enabled_flag
                     FROM gcs_system_options;
                   -- If enabled then update the above created entry to populate the correct intercompany values according to the line_item value
                  IF l_imap_enabled_flag = 'Y'
                  THEN
                           IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
                           THEN
                              fnd_log.STRING (fnd_log.level_statement,
                                       g_pkg_name || '.' || l_api_name,
                                      '         UPDATE  gcs_entry_lines gel
                                                    SET  gel.intercompany_id = (  SELECT  intercompany_id
                                                                                    FROM  gcs_interco_map_dtls gimd
                                                                                   WHERE  gimd.line_item_id  = gel.line_item_id
                                                                                )
                                                  WHERE  gel.entry_id IN( l_entry_id, l_stat_entry_id, l_proportional_entry_id, l_stat_proportional_entry_id)
                                                    AND  EXISTS (  SELECT  intercompany_id
                                                                     FROM  gcs_interco_map_dtls gimd
                                                                    WHERE  gimd.line_item_id  = gel.line_item_id
                                                                );');
                           END IF;
                        UPDATE  gcs_entry_lines gel
                           SET  gel.intercompany_id = (  SELECT  intercompany_id
                                                           FROM  gcs_interco_map_dtls gimd
                                                          WHERE  gimd.line_item_id  = gel.line_item_id
                                                      )
                         WHERE  gel.entry_id IN( l_entry_id, l_stat_entry_id, l_proportional_entry_id, l_stat_proportional_entry_id)
                           AND  EXISTS (  SELECT  intercompany_id
                                            FROM  gcs_interco_map_dtls gimd
                                           WHERE  gimd.line_item_id  = gel.line_item_id
                                        );

                  END IF;IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '()'
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
  EXCEPTION
     WHEN no_suspense_template_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_error;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_SUSPENSE_ERR');
       errbuf := fnd_message.get;

       DELETE FROM gcs_entry_headers
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);
       DELETE FROM gcs_entry_lines
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);

       IF fnd_log.g_current_runtime_level <= fnd_log.level_error
       THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      raise gcs_dp_proc_data_error;
     WHEN no_re_template_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_error;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_RE_ERR');
       errbuf := fnd_message.get;

       DELETE FROM gcs_entry_headers
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);
       DELETE FROM gcs_entry_lines
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);

       IF fnd_log.g_current_runtime_level <= fnd_log.level_error
       THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      raise gcs_dp_proc_data_error;
     WHEN init_mapping_error THEN
      raise gcs_dp_proc_data_error;
     WHEN no_data_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_warn;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_DATA_ERR');
       errbuf := fnd_message.get;
       IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
         fnd_log.STRING (fnd_log.level_error,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
       END IF;
       gcs_cons_eng_run_dtls_pkg.update_entry_headers
                                          (p_run_detail_id               => p_run_detail_id,
                                           p_entry_id                    => NULL,
                                           p_stat_entry_id               => NULL,
                                           p_pre_prop_entry_id           => NULL,
                                           p_pre_prop_stat_entry_id      => NULL,
                                           p_request_error_code          => 'NOT_APPLICABLE',
					   p_bp_request_error_code	 => 'NOT_APPLICABLE'
                                          );
     -- bug 5071794 fix: catch unexpected error and reraise it
     WHEN others THEN
       retcode := gcs_utility_pkg.g_ret_sts_error;
       errbuf := SQLERRM;

       DELETE FROM gcs_entry_headers
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);
       DELETE FROM gcs_entry_lines
             WHERE entry_id IN (l_entry_id, l_stat_entry_id,
                                l_proportional_entry_id, l_stat_proportional_entry_id);

       IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
         fnd_log.STRING (fnd_log.level_error,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
       END IF;
       RAISE gcs_dp_proc_data_error;
  END PROCESS_DATA;
  
   PROCEDURE process_inc_data (
      p_source_currency_code      IN              VARCHAR2,
      p_target_cal_period_id      IN              NUMBER,
      p_currency_type_code        IN              VARCHAR2,
      p_hierarchy_id              IN              NUMBER,
      p_entity_id                 IN              NUMBER,
      p_source_ledger_id          IN              NUMBER,
      p_balance_type_code         IN              VARCHAR2,
      p_owner_percentage          IN              NUMBER,
      p_run_name                  IN              VARCHAR2,
      p_source_dataset_code       IN              NUMBER,
      x_entry_id                  OUT NOCOPY      NUMBER,
      x_stat_entry_id             OUT NOCOPY      NUMBER,
      x_prop_entry_id             OUT NOCOPY      NUMBER,
      x_stat_prop_entry_id        OUT NOCOPY      NUMBER,
      errbuf                      OUT NOCOPY      VARCHAR2,
      retcode                     OUT NOCOPY      VARCHAR2
   )
   IS
      l_has_row_flag              VARCHAR2 (1);
      l_has_stat_row_flag         VARCHAR2 (1);
      l_temp_record               gcs_templates_pkg.templaterecord;
      l_threshold                 NUMBER;
      l_threshold_currency        VARCHAR2 (30);
      l_pre_entry_id              NUMBER (15);
      l_pre_stat_entry_id         NUMBER (15);
      l_precision                 NUMBER;
      l_stat_precision            NUMBER;
      l_mapping_required          VARCHAR2 (1);
      l_api_name                  VARCHAR2 (20)              := 'PROCESS_INC_DATA';
      l_imap_enabled_flag         VARCHAR2 (1);
  BEGIN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || l_api_name
                         || '()'
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;

      -- init local_to_master mappping
      l_mapping_required := init_local_to_master_maps (p_source_ledger_id => p_source_ledger_id,
                                                       p_cal_period_id    => p_target_cal_period_id,
                                                       errbuf => errbuf,
                                                       retcode => retcode,
                                                       p_inc_mode_flag => 'Y');
      IF (retcode <> gcs_utility_pkg.g_ret_sts_success)
      THEN
         RAISE init_mapping_error;
      END IF;
      SELECT gcs_entry_headers_s.NEXTVAL
        INTO x_entry_id
        FROM DUAL;
      SELECT gcs_entry_headers_s.NEXTVAL
        INTO x_stat_entry_id
        FROM DUAL;
      IF (l_mapping_required = 'N') THEN
        IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
        THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                            '
            INSERT /*+ APPEND */ INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )
 SELECT  decode(fb.currency_code, ''STAT'', x_stat_entry_id, x_entry_id), 
                  SUM(fb.ptd_debit_balance_e) PTD_DEBIT_BALANCE_E,
                  SUM(fb.ptd_credit_balance_e) PTD_CREDIT_BALANCE_E,
                  SUM(fb.ytd_debit_balance_e) 	YTD_DEBIT_BALANCE_E,
                  SUM(fb.ytd_credit_balance_e) 	YTD_CREDIT_BALANCE_E,
                  SUM(NVL(fb.xtd_balance_f, fb.xtd_balance_e)) XTD_BALANCE_E,
                  SUM(NVL(fb.ytd_balance_f, fb.ytd_balance_e)) YTD_BALANCE_E,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.LOGIN_ID 
         FROM  fem_balances  fb,
               fem_ledgers_attr fla,
               gcs_entity_cctr_orgs geco,
               gcs_cons_impact_analyses gcia,
               gcs_data_sub_dtls gdsd 
        WHERE fb.ledger_id = p_source_ledger_id
          AND fb.source_system_code = fla.DIM_ATTRIBUTE_NUMERIC_MEMBER
          AND fla.ledger_id = fb.ledger_id
          AND fla.attribute_id = g_ledger_ssc_attr_id
          AND fla.version_id = g_ledger_ssc_ver_id
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND p_balance_type_code = DECODE(fb.financial_elem_id, 140, ''ADB'', ''ACTUAL'')
          AND ((fb.currency_type_code = ''TRANSLATED'' AND
                fb.currency_code IN (''STAT'', p_source_currency_code)) OR
                (fb.currency_type_code = ''ENTERED''))
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.dataset_code = p_source_dataset_code
          AND fb.last_updated_by_request_id = gdsd.associated_request_id
          AND gcia.run_name = p_run_name
          AND gcia.child_entity_id = p_entity_id
          AND gcia.load_id = gdsd.load_id  GROUP BY  decode(fb.currency_code, ''STAT'', x_stat_entry_id, x_entry_id);'
                        );
        END IF;

            INSERT /*+ APPEND */ INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )
 SELECT  decode(fb.currency_code, 'STAT', x_stat_entry_id, x_entry_id), 
                  SUM(fb.ptd_debit_balance_e) PTD_DEBIT_BALANCE_E,
                  SUM(fb.ptd_credit_balance_e) PTD_CREDIT_BALANCE_E,
                  SUM(fb.ytd_debit_balance_e) 	YTD_DEBIT_BALANCE_E,
                  SUM(fb.ytd_credit_balance_e) 	YTD_CREDIT_BALANCE_E,
                  SUM(NVL(fb.xtd_balance_f, fb.xtd_balance_e)) XTD_BALANCE_E,
                  SUM(NVL(fb.ytd_balance_f, fb.ytd_balance_e)) YTD_BALANCE_E,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.LOGIN_ID 
         FROM  fem_balances  fb,
               fem_ledgers_attr fla,
               gcs_entity_cctr_orgs geco,
               gcs_cons_impact_analyses gcia,
               gcs_data_sub_dtls gdsd 
        WHERE fb.ledger_id = p_source_ledger_id
          AND fb.source_system_code = fla.DIM_ATTRIBUTE_NUMERIC_MEMBER
          AND fla.ledger_id = fb.ledger_id
          AND fla.attribute_id = g_ledger_ssc_attr_id
          AND fla.version_id = g_ledger_ssc_ver_id
          AND fb.company_cost_center_org_id		= 	geco.company_cost_center_org_id
          AND geco.entity_id = p_entity_id
          AND p_balance_type_code = DECODE(fb.financial_elem_id, 140, 'ADB', 'ACTUAL')
          AND ((fb.currency_type_code = 'TRANSLATED' AND
                fb.currency_code IN ('STAT', p_source_currency_code)) OR
                (fb.currency_type_code = 'ENTERED'))
          AND fb.currency_type_code			=       p_currency_type_code
          AND fb.dataset_code = p_source_dataset_code
          AND fb.last_updated_by_request_id = gdsd.associated_request_id
          AND gcia.run_name = p_run_name
          AND gcia.child_entity_id = p_entity_id
          AND gcia.load_id = gdsd.load_id  GROUP BY  decode(fb.currency_code, 'STAT', x_stat_entry_id, x_entry_id);
      ELSE
          IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
          THEN
             fnd_log.STRING (fnd_log.level_statement,
                             g_pkg_name || '.' || l_api_name,
                                ' g_insert_statement = '
                             || g_insert_statement
                            );
             fnd_log.STRING (fnd_log.level_statement,
                             g_pkg_name || '.' || l_api_name,
                                'EXECUTE IMMEDIATE g_insert_statement '
                             || g_nl
                             || ' USING '
                             || x_stat_entry_id || ', ' || x_entry_id ||', '
                             || fnd_global.user_id ||', '|| fnd_global.login_id ||', '|| p_source_ledger_id ||', '
                             || g_ledger_ssc_attr_id ||', '
                             || g_ledger_ssc_ver_id ||', '
                             || p_currency_type_code ||', '|| p_hierarchy_id ||', '
                             || p_entity_id ||', '|| p_balance_type_code ||', '
                             || g_ln_item_vs_id ||', '
                             || g_li_eat_attr_id ||', '
                             || g_eatc_batc_attr_id ||', '
                             || g_li_eat_ver_id ||', '
                             || g_eatc_batc_ver_id ||', '
                             || p_source_currency_code ||', '
                             || p_source_dataset_code ||', '|| p_run_name ||', '|| p_entity_id ||', '
                             || x_stat_entry_id || ', ' || x_entry_id
                            );
          END IF;
          EXECUTE IMMEDIATE g_insert_statement
                      USING x_stat_entry_id, x_entry_id,
                            fnd_global.user_id, fnd_global.user_id, fnd_global.login_id, p_source_ledger_id,
                            g_ledger_ssc_attr_id, g_ledger_ssc_ver_id, p_currency_type_code,
                            p_entity_id, p_balance_type_code, g_ln_item_vs_id, g_li_eat_attr_id,
                            g_eatc_batc_attr_id, g_li_eat_ver_id, g_eatc_batc_ver_id,
                            p_source_currency_code, p_source_dataset_code, p_run_name,
                            p_entity_id, x_stat_entry_id, x_entry_id;
      END IF;

      BEGIN
          SELECT 'Y'
            INTO l_has_row_flag
            FROM DUAL
           WHERE EXISTS (SELECT 1 FROM gcs_entry_lines WHERE entry_id = x_entry_id);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_has_row_flag := 'N';
      END;
      BEGIN
          SELECT 'Y'
            INTO l_has_stat_row_flag
            FROM DUAL
           WHERE EXISTS (SELECT 1 FROM gcs_entry_lines WHERE entry_id = x_stat_entry_id);
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_has_stat_row_flag := 'N';
      END;
      IF l_has_stat_row_flag = 'N' AND l_has_row_flag = 'N'THEN
          RAISE no_data_error;
      END IF;

      BEGIN
        SELECT decode (p_owner_percentage, 1, entry_id, pre_prop_entry_id),
               decode (p_owner_percentage, 1, stat_entry_id, pre_prop_stat_entry_id)
          INTO l_pre_entry_id, l_pre_stat_entry_id
          FROM gcs_cons_eng_run_dtls
         WHERE child_entity_id = p_entity_id
           AND category_code = 'DATAPREPARATION'
           AND run_name in (
                            SELECT nvl(associated_run_name, run_name)
                              FROM gcs_cons_eng_runs
                             WHERE hierarchy_id = p_hierarchy_id
                               AND cal_period_id = p_target_cal_period_id
                               AND balance_type_code = p_balance_type_code
                               AND most_recent_flag = 'Y'
                            );
        UPDATE gcs_entry_lines gel
           SET (ptd_debit_balance_e, ptd_credit_balance_e, xtd_balance_e,
                ytd_debit_balance_e, ytd_credit_balance_e, ytd_balance_e) =
                                                                          (SELECT gel.ptd_debit_balance_e - gel_pre.ptd_debit_balance_e,
                                                                                  gel.ptd_credit_balance_e - gel_pre.ptd_credit_balance_e,
                                                                                  gel.xtd_balance_e - gel_pre.xtd_balance_e,
                                                                                  gel.ytd_debit_balance_e - gel_pre.ytd_debit_balance_e,
                                                                                  gel.ytd_credit_balance_e - gel_pre.ytd_credit_balance_e,
                                                                                  gel.ytd_balance_e - gel_pre.ytd_balance_e
                                                                             FROM gcs_entry_lines gel_pre
                                                                            WHERE gel_pre.entry_id = decode(gel.entry_id,
                                                                                                            x_entry_id,
                                                                                                            l_pre_entry_id,
                                                                                                            l_pre_stat_entry_id) 
                                                                          )
        WHERE gel.entry_id in (x_entry_id, x_stat_entry_id)
          AND EXISTS (SELECT 1
                        FROM gcs_entry_lines gel_pre
                       WHERE gel_pre.entry_id = decode(gel.entry_id,
                                                       x_entry_id,
                                                       l_pre_entry_id,
                                                       l_pre_stat_entry_id) 
                    ) ;
      EXCEPTION
        WHEN no_data_found then
                null;
      END;
      IF l_has_stat_row_flag = 'Y' THEN
            if p_owner_percentage <> 1 THEN
                SELECT gcs_entry_headers_s.NEXTVAL
                  INTO x_stat_prop_entry_id
                  FROM DUAL;
            END IF;
      ELSE
            x_stat_entry_id := NULL;
      END IF;
      IF l_has_row_flag = 'Y' THEN
            if p_owner_percentage <> 1 THEN
                SELECT gcs_entry_headers_s.NEXTVAL
                  INTO x_prop_entry_id
                  FROM DUAL;
            END IF;
      ELSE
            x_entry_id := NULL;
      END IF;
        
      IF x_stat_entry_id IS NOT NULL
      THEN
         gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => x_stat_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => 'STAT',
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
      -- insert stat proportional entries
      IF (x_stat_prop_entry_id is not null)
         THEN
         gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => x_stat_prop_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => 'STAT',
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
         END IF;
      END IF;
      IF x_entry_id IS NOT NULL
         THEN
         gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => x_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => p_source_currency_code,
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
      -- insert proportional entries
      IF (x_prop_entry_id is not null)
         THEN
         gcs_entry_pkg.create_entry_header
                            (x_errbuf                   => errbuf,
                             x_retcode                  => retcode,
                             p_entry_id                 => x_prop_entry_id,
                             p_hierarchy_id             => p_hierarchy_id,
                             p_entity_id                => p_entity_id,
                             p_start_cal_period_id      => p_target_cal_period_id,
                             p_end_cal_period_id        => p_target_cal_period_id,
                             p_entry_type_code          => 'AUTOMATIC',
                             p_balance_type_code        => p_balance_type_code,
                             p_currency_code            => p_source_currency_code,
                             p_process_code             => 'SINGLE_RUN_FOR_PERIOD',
                             p_category_code            => 'DATAPREPARATION'
                            );
         END IF;
         END IF;
      retcode := gcs_utility_pkg.g_ret_sts_success;
      -- Suspense accounts
      IF x_entry_id IS NOT NULL
      THEN
         -- check balance criteria
             IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
             THEN
                fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.' || l_api_name,
                        '         SELECT threshold_amount, threshold_currency
                                     INTO l_threshold, l_threshold_currency
                                     FROM gcs_hierarchies_b
                                    WHERE hierarchy_id = '||p_hierarchy_id);
             END IF;
             SELECT threshold_amount, threshold_currency
               INTO l_threshold, l_threshold_currency
               FROM gcs_hierarchies_b
              WHERE hierarchy_id = p_hierarchy_id;
         BEGIN
            gcs_templates_pkg.get_dimension_template
                                 (p_hierarchy_id           => p_hierarchy_id,
                                  p_template_code          => 'SUSPENSE',
                                  p_balance_type_code      => p_balance_type_code,
                                  p_template_record        => l_temp_record
                                 );
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE no_suspense_template_error;
         END;
         gcs_templates_dynamic_pkg.balance (p_entry_id         => x_entry_id,
                                            p_template         => l_temp_record,
                                            p_bal_type_code    => p_balance_type_code,
                                            p_hierarchy_id     => p_hierarchy_id,
                                            p_entity_id        => p_entity_id,
                                            p_threshold        => l_threshold,
                                            p_threshold_currency_code => l_threshold_currency
                                            );
        SELECT DECODE(SUSPENSE_EXCEEDED_FLAG, 'Y', 'WARNING', gcs_utility_pkg.g_ret_sts_success)
          INTO retcode
          FROM gcs_entry_headers
         WHERE entry_id = x_entry_id;
      END IF;
      IF (x_prop_entry_id IS NOT NULL or x_stat_prop_entry_id IS NOT NULL)
      THEN
        SELECT NVL (fc_1.minimum_accountable_unit, POWER (10, -fc_1.PRECISION)),
               NVL (fc_stat.minimum_accountable_unit, POWER (10, -fc_stat.PRECISION))
          INTO l_precision, l_stat_precision
          FROM fnd_currencies fc_1, fnd_currencies fc_stat
         WHERE fc_1.currency_code = p_source_currency_code
           AND fc_stat.currency_code = 'STAT';
            INSERT INTO gcs_entry_lines
                        (entry_id,
                         ptd_debit_balance_e,
                         ptd_credit_balance_e,
                         ytd_debit_balance_e,
                         ytd_credit_balance_e,
                         xtd_balance_e,
                         ytd_balance_e,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )
            SELECT decode(entry_id, x_entry_id, x_prop_entry_id, x_stat_prop_entry_id),
                   
                         ROUND(ptd_debit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                         ROUND(ptd_credit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                         ROUND(ytd_debit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                         ROUND(ytd_credit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                          ROUND(ptd_debit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision)
                        - ROUND(ptd_credit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                          ROUND(ytd_debit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision)
                        - ROUND(ytd_credit_balance_e * p_owner_percentage/decode(entry_id, x_entry_id, l_precision, l_stat_precision))*decode(entry_id, x_entry_id, l_precision, l_stat_precision),
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
             FROM gcs_entry_lines
            WHERE entry_id in ( x_entry_id, x_stat_entry_id);
            IF x_prop_entry_id IS NOT NULL THEN
                gcs_templates_dynamic_pkg.balance (p_entry_id               => x_prop_entry_id,
                                                   p_template               => l_temp_record,
                                                   p_bal_type_code          => p_balance_type_code,
                                                   p_hierarchy_id           => p_hierarchy_id,
                                                   p_entity_id              => p_entity_id,
                                                   p_threshold              => l_threshold,
                                                   p_threshold_currency_code => l_threshold_currency
                                                   );

            SELECT decode(SUSPENSE_EXCEEDED_FLAG, 'Y', 'WARNING', gcs_utility_pkg.g_ret_sts_success)
              INTO retcode
              FROM gcs_entry_headers
             WHERE entry_id = x_prop_entry_id;
            ELSE
              retcode := gcs_utility_pkg.g_ret_sts_success;
            END IF;
      END IF;
        
             -- Check the GCS_SYSTEM_OPTIONS.INTERCO_MAP_ENABLED_FLAG.
             SELECT NVL(interco_map_enabled_flag,'N')
               INTO l_imap_enabled_flag
               FROM gcs_system_options;
            -- If enabled then update the above created entry to populate the correct intercompany values according to the line_item value
            IF l_imap_enabled_flag = 'Y'
            THEN
                     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement
                     THEN
                        fnd_log.STRING (fnd_log.level_statement,
                                 g_pkg_name || '.' || l_api_name,
                                '         UPDATE  gcs_entry_lines gel
                                              SET  gel.intercompany_id = (  SELECT  intercompany_id
                                                                              FROM  gcs_interco_map_dtls gimd
                                                                             WHERE  gimd.line_item_id  = gel.line_item_id
                                                                         )
                                            WHERE  gel.entry_id IN( x_entry_id, x_stat_entry_id, x_prop_entry_id, x_stat_prop_entry_id)
                                              AND  EXISTS (  SELECT  intercompany_id
                                                               FROM  gcs_interco_map_dtls gimd
                                                              WHERE  gimd.line_item_id  = gel.line_item_id
                                                          );');
                     END IF;
                  UPDATE  gcs_entry_lines gel
                     SET  gel.intercompany_id = (  SELECT  intercompany_id
                                                     FROM  gcs_interco_map_dtls gimd
                                                    WHERE  gimd.line_item_id  = gel.line_item_id
                                                )
                   WHERE  gel.entry_id IN( x_entry_id, x_stat_entry_id, x_prop_entry_id, x_stat_prop_entry_id)
                     AND  EXISTS (  SELECT  intercompany_id
                                      FROM  gcs_interco_map_dtls gimd
                                     WHERE  gimd.line_item_id  = gel.line_item_id
                                  );

            END IF;
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || l_api_name
                         || '()'
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
  EXCEPTION
     WHEN no_suspense_template_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_error;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_SUSPENSE_ERR');
       errbuf := fnd_message.get;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      raise gcs_dp_proc_data_error;
     WHEN no_re_template_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_error;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_RE_ERR');
       errbuf := fnd_message.get;
         IF fnd_log.g_current_runtime_level <= fnd_log.level_error
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_pkg_name || '.' || l_api_name,
                               gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                           );
         END IF;
      raise gcs_dp_proc_data_error;
     WHEN init_mapping_error THEN
      raise gcs_dp_proc_data_error;
     WHEN no_data_error THEN
       retcode := gcs_utility_pkg.g_ret_sts_warn;
       FND_MESSAGE.set_name('GCS', 'GCS_DP_NO_DATA_ERR');
       errbuf := fnd_message.get;
       IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR THEN
         fnd_log.STRING (fnd_log.level_error,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_failure
                            || ' '
                            || errbuf
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
      END IF;
      raise gcs_dp_proc_data_error;
  END process_inc_data;
END GCS_DP_DYNAMIC_PKG;
        

/

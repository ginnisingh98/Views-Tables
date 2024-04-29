--------------------------------------------------------
--  DDL for Package Body GCS_IMPACT_WRITER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_IMPACT_WRITER_PKG" AS
/* $Header: gcsImpactWriterb.pls 120.7 2008/01/09 13:54:29 rthati noship $ */

-- The module name
g_module CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_IMPACT_WRITER_PKG';

FUNCTION GDSD_UPDATE_IMPACT( p_subscription_guid   IN RAW,
                             p_event IN OUT NOCOPY wf_event_t) return VARCHAR2
IS
    l_matching_ds           NUMBER;
    l_company_id            NUMBER;
    l_her_obj_def_id        NUMBER;
    l_inner_query           VARCHAR2(10000);
    l_event_key             VARCHAR2(150);
    l_posting_run_id        VARCHAR2(150);
    l_orgs_flag_param       NUMBER;
    --Bugfix 5569620
    l_load_id               NUMBER;
    -- Start Bugfix 5613525
    l_fch_gvcd_value_set_id NUMBER;
    -- Ledger/cal_period/bsv column/mapping info cache table
    TYPE ldg_period_bsv_info_rec_type IS RECORD( ledger_id                NUMBER,
                                                 cal_period_id            NUMBER,
                                                 cal_period_name          VARCHAR2(150),
                                                 ledger_gvcd_value_set_id NUMBER,
                                                 map_flag                 VARCHAR2(10),
                                                 segment_column           VARCHAR2(30) );

    TYPE t_ledger_period_bsv_info IS TABLE OF ldg_period_bsv_info_rec_type;
    l_ledger_period_bsv_info t_ledger_period_bsv_info;
    -- Eng Bugfix 5613525

    g_dimension_attr_info gcs_utility_pkg.t_hash_dimension_attr_info := gcs_utility_pkg.g_dimension_attr_info;

    CURSOR c_get_all_period_bsv_combos( p_ledger_id     NUMBER,
                                        p_cal_period_id NUMBER) -- Bugfix 5303024
    IS
    SELECT delta_run_id,
           balance_seg_value
    FROM   fem_intg_delta_loads
    WHERE  ledger_id     = p_ledger_id
    AND    cal_period_id = p_cal_period_id
    AND    loaded_flag   = 'Y';

    -- Need to be dummy cursor for type compatibility
    CURSOR c_inner_loop_cursor
    IS
    SELECT gbd.delta_run_id,
           gbd.period_name,
           gbd.currency_code,
           gbd.actual_flag
    FROM   gl_balances_delta gbd,
           gl_code_combinations gcc;

  row_inner_rec c_inner_loop_cursor%ROWTYPE;

  TYPE c_inner_dynamic_cursor is REF CURSOR;
  c_inner_query_cv c_inner_dynamic_cursor;
  --Bugfix 5843592
  CURSOR c_all_ledger_entities(p_ledger_id NUMBER,
                               p_cal_period_id NUMBER,
                               p_bal_type_code VARCHAR2)
  IS
  SELECT gea.entity_id
  FROM   gcs_entities_attr gea,
         fem_cal_periods_attr fcpa
  WHERE  gea.ledger_id = p_ledger_id
  AND    gea.data_type_code = DECODE(p_bal_type_code, 'A', 'ACTUAL', 'N/A')
  AND    fcpa.attribute_id = gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id
  AND    fcpa.version_id = gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id
  AND    fcpa.cal_period_id = p_cal_period_id
  AND    fcpa.date_assign_value BETWEEN gea.effective_start_date
                                AND NVL(gea.effective_end_date, fcpa.date_assign_value);

  Row_rec_entity_ledger c_all_ledger_entities%ROWTYPE;

  CURSOR c_list_of_orgs ( EntityId                   NUMBER,
                          p_orgs_flag_param          NUMBER,
                          p_fch_vsid                 NUMBER,
                          p_ledger_gvcd_value_set_id NUMBER,
                          p_her_obj_def_id           NUMBER)
  IS
  SELECT company_cost_center_org_id
  FROM   gcs_entity_cctr_orgs
  WHERE  entity_id = EntityId
  AND    1 = p_orgs_flag_param

  UNION

  SELECT child_id
  FROM   fem_cctr_orgs_hier
  WHERE  2 = p_orgs_flag_param
  AND    parent_value_set_id = p_fch_vsid
  AND    child_value_set_id = p_ledger_gvcd_value_set_id
  AND    parent_id IN ( SELECT company_cost_center_org_id
                        FROM   gcs_entity_cctr_orgs
                        WHERE  entity_id = EntityId )
  AND    hierarchy_obj_def_id = p_her_obj_def_id ;

  CURSOR c_check_bal_seg_val ( p_comp_display_code VARCHAR2,
                               p_company_id        NUMBER)
  IS
  SELECT 1
  FROM   fem_companies_b
  WHERE  company_id           = p_company_id
  AND    company_display_code = p_comp_display_code;


BEGIN

   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_module || '.GDSD_UPDATE_IMPACT.begin', '<<Enter>>');
   END IF;

  -- Code to consume business event and get ledger id
  l_event_key:= p_event.getEventKey();

  l_posting_run_id := substr(l_event_key, 0, (instr(l_event_key,':', 1) - 1) );

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'l_posting_run_id: '||l_posting_run_id);
  END IF;

  -- Bugfix 5303024
  -- Bugfix 5371570: Need to remove the reference to set of books id for R12 compatibility. Retrieve the ledger_id from gl_je_headers

  --Start Bugfix 5613525
  --Retrive consolidation chart of account's cctr-org value set id
  SELECT fch_gvcd.value_set_id
    INTO l_fch_gvcd_value_set_id
    FROM gcs_system_options gso,
         fem_global_vs_combo_defs fch_gvcd
   WHERE gso.fch_global_vs_combo_id  = fch_gvcd.global_vs_combo_id
     AND fch_gvcd.dimension_id       = 8;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'fch_vsid: '
                                                      || l_fch_gvcd_value_set_id);
  END IF;
  -- More than one ledger/period combination can correspond to a particular posting_run_id
  -- so decide the Mapping status and the Balancing Segment name for ledger/periods.
  -- gl_sets_of_books has been converted to a view based on gl_ledgers table for backward compatibility
  -- so refer gl_ledgers table rather than using view for performance reasons
  SELECT DISTINCT gjh.ledger_id,
         fcpt.cal_period_id,
         fcpt.cal_period_name,
         gvcd.value_set_id,
         decode(gvcd.value_set_id, l_fch_gvcd_value_set_id, 'MAPPED', 'UNMAPPED'),
         fsav.application_column_name
  BULK COLLECT
  INTO   l_ledger_period_bsv_info
  FROM   gl_je_batches gjb,
         fem_cal_periods_tl fcpt,
         gl_je_headers gjh,
         fem_intg_calendar_map ficm,
         fem_ledgers_attr fla,
         fem_global_vs_combo_defs gvcd,
         fnd_segment_attribute_values fsav
  WHERE  gjb.posting_run_id          = l_posting_run_id
  AND    gjb.status                  = 'P'
  AND    gjb.default_period_name     = fcpt.cal_period_name
  AND    gjb.je_batch_id             = gjh.je_batch_id
  AND    fcpt.language               = userenv('LANG')
  AND    fcpt.calendar_id            = ficm.calendar_id
  AND    fcpt.dimension_group_id     = ficm.dimension_group_id
  AND    ficm.period_set_name        = gjb.period_set_name
  AND    ficm.period_type            = gjb.accounted_period_type
  AND    fla.attribute_id            = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').attribute_id
  AND    fla.version_id              = gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO').version_id
  AND    fla.ledger_id               = gjh.ledger_id
  AND    gvcd.global_vs_combo_id     = fla.dim_attribute_numeric_member
  AND    gvcd.dimension_id           = 8
  AND    fsav.id_flex_num            =  gjb.chart_of_accounts_id
  AND    fsav.segment_attribute_type = 'GL_BALANCING'
  AND    fsav.attribute_value        = 'Y'
  AND    fsav.application_id         = 101
  AND    fsav.id_flex_code           = 'GL#';


  IF ( l_ledger_period_bsv_info.FIRST IS NOT NULL AND l_ledger_period_bsv_info.LAST IS NOT NULL )
  THEN

    FOR l_ledger_period_bsv_index IN l_ledger_period_bsv_info.FIRST..l_ledger_period_bsv_info.LAST
    LOOP

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'l_ledger_period_bsv_index: '
                                                          || l_ledger_period_bsv_index);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'ledger_id: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'cal_period_id: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'cal_period_name: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_name);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'ledger_gvcd_value_set_id: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_gvcd_value_set_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'map_flag: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).map_flag);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'segment_column: '
                                                          || l_ledger_period_bsv_info(l_ledger_period_bsv_index).segment_column);

      END IF;


      FOR l_rec_outer IN c_get_all_period_bsv_combos( l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_id,
                                                      l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id ) -- Bugfix 5303024
      LOOP

      -- End Bugfix 5613525

         l_inner_query :='SELECT gbd.delta_run_id, gbd.period_name, '||
                        '       gbd.currency_code, gbd.actual_flag ' ||
                        ' FROM  gl_balances_delta gbd,' ||
                        '       gl_code_combinations gcc '||
                        ' WHERE gbd.period_name = :period  '||
                        ' AND   gbd.ledger_id = :ledger' ||
                        ' AND   gcc.code_combination_id = gbd.code_combination_id '||
                        ' AND   gcc.' ||
                        l_ledger_period_bsv_info(l_ledger_period_bsv_index).segment_column ||
                        '= :balseg' ||
                        ' AND   gbd.delta_run_id > :DeltaRunId';

         OPEN c_inner_query_cv FOR l_inner_query USING l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_name,
                                                       l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_id,
                                                       l_rec_outer.balance_seg_value,
                                                       l_rec_outer.delta_run_id;
         LOOP
             FETCH c_inner_query_cv into row_inner_rec;
             EXIT WHEN c_inner_query_cv%NOTFOUND;

             --Special logic to determine Entity Id
             --Step1 : take all FEM entities that use the ledger_id passed in
             --Bugfix 5843592
             FOR rec_entity in c_all_ledger_entities(l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_id,
                                                     l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id,
                                                     row_inner_rec.actual_flag)
             LOOP

                 --this will be in the FCH GVSC's org value set
                 --gcs_entity_cctr_orgs to get the list of Organization values for this entity
                 IF (l_ledger_period_bsv_info(l_ledger_period_bsv_index).map_flag = 'MAPPED') THEN
                       l_orgs_flag_param       :=  1;
                       l_her_obj_def_id    := -1;

                 ELSE
                     --Do further filtration  on HIERARCHY_OBJ_DEF_ID
                     SELECT object_definition_id
                     INTO   l_her_obj_def_id
                     FROM   fem_object_definition_b fodb,
                            fem_xdim_dimensions fxd,
                            fem_cal_periods_attr fcpa
                     WHERE  fodb.object_id     = fxd.default_mvs_hierarchy_obj_id
                     AND    dimension_id       = 8
                     AND    fcpa.attribute_id  = gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id
                     AND    fcpa.version_id    = gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id
                     AND    fcpa.cal_period_id = l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id
                     AND    fcpa.date_assign_value BETWEEN effective_start_date AND effective_end_date;

                     -- Append the extra filter clause here
                     l_orgs_flag_param := 2;

                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'l_her_obj_def_id: '||l_her_obj_def_id);
                     END IF;

                 END IF;

                 FOR rec_list_of_orgs IN c_list_of_orgs( rec_entity.entity_id,
                                                         l_orgs_flag_param,
                                                         l_fch_gvcd_value_set_id,
                                                         l_ledger_period_bsv_info(l_ledger_period_bsv_index).ledger_gvcd_value_set_id,
                                                         l_her_obj_def_id )
                 LOOP
                     -- use fem_cctr_orgs_attr to get the company id values for each organization
                     SELECT dim_attribute_numeric_member
                     INTO   l_company_id
                     FROM   fem_cctr_orgs_attr fda
                     WHERE  fda.company_cost_center_org_id = rec_list_of_orgs.company_cost_center_org_id
                     AND    fda.attribute_id               = gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').attribute_id
                     AND    fda.version_id                 = gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY').version_id;

                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'l_company_id: '||l_company_id);
                     END IF;

                     --Check if Balance Seg Values match
                     OPEN c_check_bal_seg_val(l_rec_outer.balance_seg_value, l_company_id);

                     FETCH c_check_bal_seg_val INTO l_matching_ds;

                     IF c_check_bal_seg_val%NOTFOUND THEN
                         CLOSE c_check_bal_seg_val;
                     ELSE
                         CLOSE c_check_bal_seg_val;
                         UPDATE gcs_data_sub_dtls
                         SET    status_code       = 'IMPACTED'
                         WHERE  cal_period_id     = l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id
                         AND    entity_id         = rec_entity.entity_id
                         AND    currency_code     = row_inner_rec.currency_code
                         AND    most_recent_flag  = 'Y'
                         AND    balance_type_code = decode(row_inner_rec.actual_flag,'A','ACTUAL','N/A')
                         --Start Bugfix 5569620
                         RETURNING load_id INTO l_load_id;

                         --Roll forward impact to consolidation data statuses for the impacted load
                         GCS_CONS_MONITOR_PKG.update_data_status ( p_load_id => l_load_id );
                         --End Bugfix 5569620

                         COMMIT;

                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
                               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'Data Submission Impacted for: ');
                               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'Balance Type Code: '||row_inner_rec.actual_flag);
                               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'Cal Period Id: '||l_ledger_period_bsv_info(l_ledger_period_bsv_index).cal_period_id);
                               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'Entity Id: '||rec_entity.entity_id);
                               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_module || '.GDSD_UPDATE_IMPACT', 'Currency Code: '||row_inner_rec.currency_code);
                           END IF;

                      END IF;

                 END LOOP; --rec_list_of_orgs

             END LOOP;   --rec_entity

         END LOOP; --c_inner_query_cv

      END LOOP; --l_rec_outer

    -- Start Bugfix 5613525
    END LOOP; --l_ledger_period_bsv_index

  END IF; --l_ledger_period_bsv_info not null
  -- Eng Bugfix 5613525

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_module || '.GDSD_UPDATE_IMPACT.end', '<<Exit>>');
  END IF;

  RETURN 'SUCCESS';

  EXCEPTION
            WHEN OTHERS THEN
            BEGIN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_ERROR) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_ERROR, g_module || '.GDSD_UPDATE_IMPACT.end', SUBSTR(SQLERRM, 1, 255));
                END IF;

                RETURN 'FAILURE';
            END;
END GDSD_UPDATE_IMPACT;

END GCS_IMPACT_WRITER_PKG;

/

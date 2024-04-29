--------------------------------------------------------
--  DDL for Package Body GCS_CONS_IMPACT_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_IMPACT_ANALYSIS_PKG" as
  /* $Header: gcs_cons_impactb.pls 120.6 2007/12/06 10:08:57 smatam noship $ */

  g_api VARCHAR2(80) := 'gcs.plsql.GCS_CONS_IMPACT_ANALYSIS_PKG';

  PROCEDURE rollup_impact(p_consolidation_entity_id IN NUMBER,
                          p_hierarchy_id            IN NUMBER,
                          p_cal_period_id           IN NUMBER)

   IS

    CURSOR c_parent_entity(p_child_entity_id NUMBER, p_hierarchy_id NUMBER, p_end_date DATE, p_cal_period_id NUMBER) IS

      SELECT gcr.parent_entity_id
        FROM gcs_cons_relationships gcr, gcs_cons_eng_runs gcer
       WHERE gcr.hierarchy_id = p_hierarchy_id
         AND gcr.child_entity_id = p_child_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND gcr.hierarchy_id = gcer.hierarchy_id
         AND gcr.parent_entity_id = gcer.run_entity_id
         AND gcer.cal_period_id = p_cal_period_id
         AND gcer.most_recent_flag = 'Y'
         AND gcer.impacted_flag = 'N'
         AND p_end_date BETWEEN gcr.start_date AND
             NVL(gcr.end_date, p_end_date);

    l_rows_updated            NUMBER(1);
    l_child_entity_id         NUMBER(15);
    l_end_date_attribute_id   NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .attribute_id;
    l_end_date_version_id     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .version_id;
    l_period_num_attribute_id NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM')
                                       .attribute_id;
    l_period_num_version_id   NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM')
                                       .version_id;
    l_acct_year_attribute_id  NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                                       .attribute_id;
    l_acct_year_version_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                                       .version_id;
    l_end_date                DATE;
    l_cal_period_id           NUMBER;
    l_target_cal_period_id    NUMBER;
    l_period_mapping_required VARCHAR2(1) := 'Y';
    l_src_calendar_id         NUMBER;
    l_src_dimension_group_id  NUMBER;
    l_tgt_calendar_id         NUMBER;
    l_tgt_dimension_group_id  NUMBER;
    l_cal_period_map_id       NUMBER;
    l_cal_period_record       gcs_utility_pkg.r_cal_period_info;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ROLLUP_IMPACT.begin',
                     '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ROLLUP_IMPACT',
                     'Consolidation Entity 	: ' ||
                     p_consolidation_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ROLLUP_IMPACT',
                     'Hierarchy		: ' || p_hierarchy_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ROLLUP_IMPACT',
                     'Calendar Period Id		: ' || p_cal_period_id);
    END IF;

    l_child_entity_id := p_consolidation_entity_id;

    -- Start Bug fix : 6029020
    BEGIN
      SELECT gcpm.cal_period_map_id,
             gcpm.SOURCE_CALENDAR_ID,
             gcpm.SOURCE_DIMENSION_GROUP_ID,
             gcpm.TARGET_CALENDAR_ID,
             gcpm.TARGET_DIMENSION_GROUP_ID
        INTO l_cal_period_map_id,
             l_src_calendar_id,
             l_src_dimension_group_id,
             l_tgt_calendar_id,
             l_tgt_dimension_group_id
        FROM GCS_CAL_PERIOD_MAPS gcpm,
             gcs_hierarchies_b   ghb,
             fem_cal_periods_b   fcpb
       WHERE gcpm.SOURCE_CALENDAR_ID = fcpb.CALENDAR_ID
         AND gcpm.SOURCE_DIMENSION_GROUP_ID = fcpb.DIMENSION_GROUP_ID
         AND gcpm.TARGET_CALENDAR_ID = ghb.CALENDAR_ID
         AND gcpm.TARGET_DIMENSION_GROUP_ID = ghb.DIMENSION_GROUP_ID
         AND ghb.HIERARCHY_ID = p_hierarchy_id
         AND fcpb.cal_period_id = p_cal_period_id;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       'Calendar Period Map Id = ' || l_cal_period_map_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       ' Source Calendar Id = ' || l_src_calendar_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       'Source Dimension Group Id = ' ||
                       l_src_dimension_group_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       ' Target Calendar Id = ' || l_tgt_calendar_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       'Target Dimension Group Id = ' ||
                       l_tgt_dimension_group_id);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_period_mapping_required := 'N';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.ROLLUP_IMPACT.exception',
                         'NO DATA FOUND ');
        END IF;
    END;
    IF (l_period_mapping_required = 'Y') THEN
      --period_mapping_required
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       '<< Calendar Period Mapping required >>');
      END IF;

      gcs_utility_pkg.get_cal_period_details(p_cal_period_id,
                                             l_cal_period_record);
      SELECT fcpb.cal_period_id
        INTO l_target_cal_period_id
        FROM fem_cal_periods_b       fcpb,
             fem_cal_periods_attr    fcpa_number,
             fem_cal_periods_attr    fcpa_year,
             gcs_cal_period_map_dtls gcpmd
       WHERE gcpmd.cal_period_map_id = l_cal_period_map_id
         AND fcpb.calendar_id = l_tgt_calendar_id
         AND fcpb.dimension_group_id = l_tgt_dimension_group_id
         AND fcpb.cal_period_id = fcpa_number.cal_period_id
         AND fcpb.cal_period_id = fcpa_year.cal_period_id
         AND fcpa_number.attribute_id = l_period_num_attribute_id
         AND fcpa_year.attribute_id = l_acct_year_attribute_id
         AND fcpa_number.version_id = l_period_num_version_id
         AND fcpa_year.version_id = l_acct_year_version_id
         AND fcpa_number.number_assign_value = gcpmd.target_period_number
         AND gcpmd.source_period_number =
             l_cal_period_record.cal_period_number
         AND fcpa_year.number_assign_value =
             DECODE(gcpmd.target_relative_year_code,
                    'CURRENT',
                    l_cal_period_record.cal_period_year,
                    'PRIOR',
                    l_cal_period_record.cal_period_year - 1,
                    'FOLLOWING',
                    l_cal_period_record.cal_period_year + 1);
      l_cal_period_id := l_target_cal_period_id;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       'Target Calendar Period Id = ' || l_cal_period_id);
      END IF;
    ELSE
      --l_period_mapping_not_required
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT',
                       '<< Calendar Period Mapping is NOT required >>');
      END IF;
      l_cal_period_id := p_cal_period_id;
    END IF;

    SELECT date_assign_value
      INTO l_end_date
      FROM fem_cal_periods_attr
     WHERE cal_period_id = l_cal_period_id
       AND attribute_id = l_end_date_attribute_id
       AND version_id = l_end_date_version_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ROLLUP_IMPACT',
                     ' Calendar Period End Date = ' || l_end_date);
    END IF;
    WHILE (1 = 1) LOOP
      l_rows_updated := 0;
      FOR v_parent_entity IN c_parent_entity(l_child_entity_id,
                                             p_hierarchy_id,
                                             l_end_date,
                                             l_cal_period_id) LOOP
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.ROLLUP_IMPACT',
                         ' l_child_entity_id = ' || l_child_entity_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.ROLLUP_IMPACT',
                         ' Updating the impacted status of Entity with Entity_Id = ' ||
                         v_parent_entity.parent_entity_id);
        END IF;

        UPDATE gcs_cons_eng_runs
           SET impacted_flag = 'Y'
         WHERE hierarchy_id = p_hierarchy_id
           AND run_entity_id = v_parent_entity.parent_entity_id
           AND cal_period_id = l_cal_period_id
           AND most_recent_flag = 'Y';

        IF (SQL%ROWCOUNT = 0) THEN
          l_rows_updated := 0;
        ELSE
          l_rows_updated := 1;
        END IF;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.ROLLUP_IMPACT',
                         ' Done');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.ROLLUP_IMPACT',
                         'SQL%ROWCOUNT = ' || l_rows_updated);
        END IF;
        l_child_entity_id := v_parent_entity.parent_entity_id;

      END LOOP;

      IF (l_rows_updated = 0) THEN
        EXIT;
      END IF;
    END LOOP;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ROLLUP_IMPACT.end',
                     '<<Exit>>');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_period_mapping_required := 'N';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.ROLLUP_IMPACT.exception',
                       SUBSTR(SQLERRM, 1, 100));
      END IF;
      -- End Bug fix : 6029020
  END rollup_impact;

  PROCEDURE insert_impact_analysis(p_run_name                IN VARCHAR2,
                                   p_consolidation_entity_id IN NUMBER,
                                   p_child_entity_id         IN NUMBER,
                                   p_message_name            IN VARCHAR2,
                                   p_pre_relationship_id     IN NUMBER DEFAULT NULL,
                                   p_post_relationship_id    IN NUMBER DEFAULT NULL,
                                   p_date_token              IN DATE DEFAULT NULL,
                                   p_stat_entry_id           IN NUMBER DEFAULT NULL,
                                   p_entry_id                IN NUMBER DEFAULT NULL,
                                   p_orig_entry_id           IN NUMBER DEFAULT NULL,
                                   p_pre_prop_entry_id       IN NUMBER DEFAULT NULL,
                                   p_pre_prop_stat_entry_id  IN NUMBER DEFAULT NULL,
                                   p_load_id                 IN NUMBER DEFAULT NULL)

   IS

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.INSERT_IMPACT_ANALYSIS.begin',
                     '<<Enter Module>>');
    END IF;

    INSERT INTO gcs_cons_impact_analyses
      (impact_analysis_id,
       run_name,
       consolidation_entity_id,
       child_entity_id,
       message_name,
       pre_relationship_id,
       post_relationship_id,
       date_token,
       stat_entry_id,
       entry_id,
       original_entry_id,
       pre_prop_entry_id,
       pre_prop_stat_entry_id,
       creation_date,
       created_by,
       last_updated_by,
       last_update_date,
       last_update_login,
       object_version_number,
       load_id)
    VALUES
      (gcs_cons_impact_analyses_s.nextval,
       p_run_name,
       p_consolidation_entity_id,
       p_child_entity_id,
       p_message_name,
       p_pre_relationship_id,
       p_post_relationship_id,
       p_date_token,
       p_stat_entry_id,
       p_entry_id,
       p_orig_entry_id,
       p_pre_prop_entry_id,
       p_pre_prop_stat_entry_id,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.LOGIN_ID,
       1, -- Bugfix 3718098 : Added OBJECT_VERSION_NUMBER per Release Standards,
       p_load_id);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.INSERT_IMPACT_ANALYSIS.end',
                     '<<Exit Module>>');
    END IF;

  END insert_impact_analysis;

  -- Definition of Public Procedures

  FUNCTION hierarchy_altered(p_pre_cons_relationship_id  IN NUMBER,
                             p_post_cons_relationship_id IN NUMBER,
                             p_trx_type_code             IN VARCHAR2,
                             p_trx_date_day              IN NUMBER,
                             p_trx_date_month            IN NUMBER,
                             p_trx_date_year             IN NUMBER,
                             p_hidden_flag               IN VARCHAR2,
                             p_intermediate_trtmnt_id    IN NUMBER,
                             p_intermediate_pct_owned    IN NUMBER)
    RETURN VARCHAR2

   IS
    l_parameter_list            wf_parameter_list_t;
    l_pre_cons_relationship_id  NUMBER(15);
    l_post_cons_relationship_id NUMBER(15);
    l_trx_type_code             VARCHAR2(30);
    l_trx_date                  DATE;
    l_intermediate_trtmnt_id    NUMBER(15);
    l_intermediate_pct_owned    NUMBER;
    l_enabled_flag              VARCHAR2(1);
    l_param_counter             NUMBER(15);
    l_orig_treatment_id         NUMBER(15);
    l_new_treatment_id          NUMBER(15);
    l_orig_pct_owned            NUMBER;
    l_new_pct_owned             NUMBER;
    l_orig_curr_trtmnt_id       NUMBER;
    l_new_curr_trtmnt_id        NUMBER;
    l_hierarchy_id              NUMBER;
    l_cal_period_id             NUMBER;
    l_parent_entity_id          NUMBER;
    l_child_entity_id           NUMBER;
    l_run_name                  VARCHAR2(80);
    l_impact_occurred           BOOLEAN := FALSE;
    l_cp_end_date_attr_id       NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                         .attribute_id;
    l_cp_end_date_version_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                         .version_id;
    l_cp_start_date_attr_id     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_START_DATE')
                                         .attribute_id;
    l_cp_start_date_version_id  NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_START_DATE')
                                         .version_id;
    l_parent_entity_name        VARCHAR2(80);
    l_child_entity_name         VARCHAR2(80);
    l_email                     VARCHAR2(200);
    l_orig_treatment            VARCHAR2(100);
    l_new_treatment             VARCHAR2(100);

    CURSOR c_select_hier_info(p_pre_cons_relationship_id IN NUMBER, p_post_cons_relationship_id IN NUMBER) IS
      SELECT gcr.hierarchy_id,
             gcr.parent_entity_id,
             gcr.child_entity_id,
             gcr.cons_relationship_id,
             gcr.curr_treatment_id,
             gcr.treatment_id,
             gcr.ownership_percent
        FROM gcs_cons_relationships gcr
       WHERE gcr.cons_relationship_id IN
             (p_post_cons_relationship_id, p_pre_cons_relationship_id);

  BEGIN

    l_pre_cons_relationship_id  := p_pre_cons_relationship_id;
    l_post_cons_relationship_id := p_post_cons_relationship_id;
    l_trx_type_code             := p_trx_type_code;
    l_trx_date                  := TO_DATE(p_trx_date_day || '-' ||
                                           p_trx_date_month || '-' ||
                                           p_trx_date_year,
                                           'DD-MM-YYYY');
    IF (p_hidden_flag = 'Y') THEN
      l_enabled_flag := 'N';
    ELSE
      l_enabled_flag := 'Y';
    END IF;
    l_intermediate_trtmnt_id := p_intermediate_trtmnt_id;
    l_intermediate_pct_owned := p_intermediate_pct_owned;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HIERARCHY_ALTERED.begin',
                     '<<Enter>>');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HIERARCHY_ALTERED',
                     'Pre-Cons Relationship Id : ' ||
                     p_pre_cons_relationship_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HIERARCHY_ALTERED',
                     'Post-Cons Relationship Id : ' ||
                     p_post_cons_relationship_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HIERARCHY_ALTERED',
                     'Trx Date : ' || l_trx_date);
    END IF;

    -- Initialize Critical Variables
    FOR v_select_hier_info IN c_select_hier_info(l_pre_cons_relationship_id,
                                                 l_post_cons_relationship_id) LOOP
      IF (l_hierarchy_id IS NULL) THEN
        l_hierarchy_id     := v_select_hier_info.hierarchy_id;
        l_parent_entity_id := v_select_hier_info.parent_entity_id;
        l_child_entity_id  := v_select_hier_info.child_entity_id;
      END IF;

      IF (v_select_hier_info.cons_relationship_id =
         l_pre_cons_relationship_id) THEN
        l_orig_treatment_id   := v_select_hier_info.treatment_id;
        l_orig_pct_owned      := v_select_hier_info.ownership_percent;
        l_orig_curr_trtmnt_id := v_select_hier_info.curr_treatment_id;
      ELSE
        l_new_treatment_id   := v_select_hier_info.treatment_id;
        l_new_pct_owned      := v_select_hier_info.ownership_percent;
        l_new_curr_trtmnt_id := v_select_hier_info.curr_treatment_id;
      END IF;

      IF (l_pre_cons_relationship_id = -1) THEN
        l_orig_treatment_id := l_intermediate_trtmnt_id;
        l_orig_pct_owned    := l_intermediate_pct_owned;
      ELSIF (l_post_cons_relationship_id = -1) THEN
        l_new_treatment_id := l_intermediate_trtmnt_id;
        l_new_pct_owned    := l_intermediate_pct_owned;
      END IF;
    END LOOP;

    --Change Data Status : Bugfix 4179351
    IF (l_pre_cons_relationship_id = -1) THEN
      gcs_cons_monitor_pkg.update_data_status(p_load_id          => NULL,
                                              p_cons_rel_id      => l_post_cons_relationship_id,
                                              p_hierarchy_id     => l_hierarchy_id,
                                              p_transaction_type => 'ACQ');
    ELSIF (l_post_cons_relationship_id = -1) THEN
      gcs_cons_monitor_pkg.update_data_status(p_load_id          => NULL,
                                              p_cons_rel_id      => l_pre_cons_relationship_id,
                                              p_hierarchy_id     => l_hierarchy_id,
                                              p_transaction_type => 'DIS');
    END IF;

    --Extract Calendar Period Information
    SELECT fcb.cal_period_id
      INTO l_cal_period_id
      FROM fem_cal_periods_b    fcb,
           gcs_hierarchies_b    fhb,
           fem_cal_periods_attr fcpa_start_date,
           fem_cal_periods_attr fcpa_end_date
     WHERE fhb.hierarchy_id = l_hierarchy_id
       AND fcb.calendar_id = fhb.calendar_id
       AND fcb.dimension_group_id = fhb.dimension_group_id
       AND fcb.cal_period_id = fcpa_start_date.cal_period_id
       AND fcb.cal_period_id = fcpa_end_date.cal_period_id
       AND fcpa_start_date.attribute_id = l_cp_start_date_attr_id
       AND fcpa_start_date.version_id = l_cp_start_date_version_id
       AND fcpa_end_date.attribute_id = l_cp_end_date_attr_id
       AND fcpa_end_date.version_id = l_cp_end_date_version_id
       AND l_trx_date BETWEEN fcpa_start_date.date_assign_value AND
           fcpa_end_date.date_assign_value;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HIERARCHY_ALTERED',
                     'Calendar Period : ' || l_cal_period_id);
    END IF;

    UPDATE gcs_ad_transactions gat
       SET gat.enabled_flag = 'N', gat.hidden_flag = 'N'
     WHERE gat.transaction_date >= l_trx_date
       AND (EXISTS
            (SELECT 'X'
               FROM gcs_cons_relationships pre
              WHERE pre.hierarchy_id = l_hierarchy_id
                AND pre.cons_relationship_id = gat.pre_cons_relationship_id
                AND pre.parent_entity_id = l_parent_entity_id
                AND pre.child_entity_id = l_child_entity_id) OR EXISTS
            (SELECT 'X'
               FROM gcs_cons_relationships post
              WHERE post.hierarchy_id = l_hierarchy_id
                AND post.cons_relationship_id = gat.post_cons_relationship_id
                AND post.parent_entity_id = l_parent_entity_id
                AND post.child_entity_id = l_child_entity_id));

    -- Insert records into GCS_AD_TRANSACTIONS
    INSERT INTO GCS_AD_TRANSACTIONS
      (ad_transaction_id,
       pre_cons_relationship_id,
       post_cons_relationship_id,
       transaction_type_code,
       hidden_flag,
       enabled_flag,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       intermediate_treatment_id,
       intermediate_percent_owned,
       cal_period_id,
       transaction_date)
    VALUES
      (GCS_AD_TRANSACTIONS_S.NEXTVAL,
       DECODE(l_pre_cons_relationship_id,
              -1,
              NULL,
              l_pre_cons_relationship_id),
       DECODE(l_post_cons_relationship_id,
              -1,
              NULL,
              l_post_cons_relationship_id),
       l_trx_type_code,
       'N',
       l_enabled_flag,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.LOGIN_ID,
       l_intermediate_trtmnt_id,
       l_intermediate_pct_owned,
       l_cal_period_id,
       l_trx_date);

    -- Bugfix 4309316: Need to synchronize new additions with EPF
    IF (l_pre_cons_relationship_id = -1) THEN
      gcs_fem_hier_sync_pkg.entity_added(p_hierarchy_id         => l_hierarchy_id,
                                         p_cons_relationship_id => l_post_cons_relationship_id);
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HIERARCHY_ALTERED',
                     'Checking for Impact Analysis');
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HIERARCHY_ALTERED',
                     'Parent Entity ID : ' || l_parent_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HIERARCHY_ALTERED',
                     'Hierarchy ID : ' || l_hierarchy_id);
    END IF;

    --Check for Impact Analysis
    BEGIN

      BEGIN
        SELECT run_name
          INTO l_run_name
          FROM gcs_cons_eng_runs
         WHERE run_entity_id = l_parent_entity_id
           AND hierarchy_id = l_hierarchy_id
           AND most_recent_flag = 'Y'
           AND cal_period_id = l_cal_period_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --Check if change happened in earlier period
          SELECT gcer.run_name, gcer.cal_period_id
            INTO l_run_name, l_cal_period_id
            FROM gcs_cons_eng_runs gcer
           WHERE gcer.run_entity_id = l_parent_entity_id
             AND gcer.hierarchy_id = l_hierarchy_id
             AND most_recent_flag = 'Y'
             AND cal_period_id =
                 (SELECT min(gcer_inner.cal_period_id)
                    FROM gcs_cons_eng_runs gcer_inner
                   WHERE gcer_inner.run_entity_id = l_parent_entity_id
                     AND gcer_inner.hierarchy_id = l_hierarchy_id
                     AND gcer_inner.most_recent_flag = 'Y'
                     AND gcer_inner.cal_period_id > l_cal_period_id);
      END;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_api || '.HIERARCHY_ALTERED',
                       'Run Name :');
      END IF;

      SELECT fev_parent.entity_name, fev_child.entity_name
        INTO l_parent_entity_name, l_child_entity_name
        FROM fem_entities_vl fev_parent, fem_entities_vl fev_child
       WHERE fev_parent.entity_id = l_parent_entity_id
         AND fev_child.entity_id = l_child_entity_id;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_api || '.HIERARCHY_ALTERED',
                       'Pre Cons Relatonship Id :' ||
                       l_pre_cons_relationship_id);
      END IF;

      IF (l_pre_cons_relationship_id = -1) THEN
        l_impact_occurred := TRUE;
        insert_impact_analysis(p_run_name                => l_run_name,
                               p_consolidation_entity_id => l_parent_entity_id,
                               p_child_entity_id         => l_child_entity_id,
                               p_message_name            => 'GCS_ENTITY_ACQUIRED',
                               p_post_relationship_id    => l_post_cons_relationship_id,
                               p_date_token              => l_trx_date);

      ELSIF (l_post_cons_relationship_id = -1) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.HIERARCHY_ALTERED',
                         'Post Cons Relatonship Id :' ||
                         l_pre_cons_relationship_id);
        END IF;

        l_impact_occurred := TRUE;
        insert_impact_analysis(p_run_name                => l_run_name,
                               p_consolidation_entity_id => l_parent_entity_id,
                               p_child_entity_id         => l_child_entity_id,
                               p_message_name            => 'GCS_ENTITY_DISPOSED',
                               p_pre_relationship_id     => l_pre_cons_relationship_id,
                               p_date_token              => l_trx_date);

      ELSE

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.hierarchy_altered',
                         'Original Treatment Id : ' || l_orig_treatment_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.hierarchy_altered',
                         'New Treatment Id : ' || l_new_treatment_id);
        END IF;

        IF (l_orig_treatment_id <> l_new_treatment_id) THEN
          l_impact_occurred := TRUE;
          insert_impact_analysis(p_run_name                => l_run_name,
                                 p_consolidation_entity_id => l_parent_entity_id,
                                 p_child_entity_id         => l_child_entity_id,
                                 p_message_name            => 'GCS_CONS_TREATMENT_ALTERED',
                                 p_pre_relationship_id     => l_pre_cons_relationship_id,
                                 p_post_relationship_id    => l_post_cons_relationship_id,
                                 p_date_token              => l_trx_date);

          SELECT gcs_orig.treatment_name, gcs_new.treatment_name
            INTO l_orig_treatment, l_new_treatment
            FROM gcs_treatments_tl gcs_orig, gcs_treatments_tl gcs_new
           WHERE gcs_orig.treatment_id = l_orig_treatment_id
             AND gcs_new.treatment_id = l_new_treatment_id
             AND gcs_orig.language = USERENV('LANG')
             AND gcs_new.language = USERENV('LANG');

        END IF;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.HIERARCHY_ALTERED',
                         'Original Pct Owned : ' || l_new_pct_owned);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.HIERARCHY_ALTERED',
                         'New Pct Owned : ' || l_orig_pct_owned);
        END IF;

        IF (l_orig_pct_owned <> l_new_pct_owned) THEN
          l_impact_occurred := TRUE;
          insert_impact_analysis(p_run_name                => l_run_name,
                                 p_consolidation_entity_id => l_parent_entity_id,
                                 p_child_entity_id         => l_child_entity_id,
                                 p_message_name            => 'GCS_PCT_OWNERSHIP_ALTERED',
                                 p_pre_relationship_id     => l_pre_cons_relationship_id,
                                 p_post_relationship_id    => l_post_cons_relationship_id,
                                 p_date_token              => l_trx_date);

        END IF;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.HIERARCHY_ALTERED',
                         'Original Curr Trtmnt : ' || l_orig_curr_trtmnt_id);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.HIERARCHY_ALTERED',
                         'New Curr Trtmnt : ' || l_new_curr_trtmnt_id);
        END IF;

        IF (l_orig_curr_trtmnt_id <> l_new_curr_trtmnt_id) THEN
          l_impact_occurred := TRUE;
          insert_impact_analysis(p_run_name                => l_run_name,
                                 p_consolidation_entity_id => l_parent_entity_id,
                                 p_child_entity_id         => l_child_entity_id,
                                 p_message_name            => 'GCS_CURR_TREATMENT_ALTERED',
                                 p_pre_relationship_id     => l_pre_cons_relationship_id,
                                 p_post_relationship_id    => l_post_cons_relationship_id,
                                 p_date_token              => l_trx_date);

          SELECT gcs_orig.curr_treatment_name, gcs_new.curr_treatment_name
            INTO l_orig_treatment, l_new_treatment
            FROM gcs_curr_treatments_tl gcs_orig,
                 gcs_curr_treatments_tl gcs_new
           WHERE gcs_orig.curr_treatment_id = l_orig_curr_trtmnt_id
             AND gcs_new.curr_treatment_id = l_new_curr_trtmnt_id
             AND gcs_orig.language = USERENV('LANG')
             AND gcs_new.language = USERENV('LANG');

        END IF;

      END IF;

      IF (l_impact_occurred) THEN
        --Update IMPACTED_FLAG rather than status code
        UPDATE gcs_cons_eng_runs
           SET impacted_flag = 'Y'
         WHERE run_name = l_run_name
           AND run_entity_id = l_parent_entity_id
           AND most_recent_flag = 'Y';

        rollup_impact(p_hierarchy_id            => l_hierarchy_id,
                      p_consolidation_entity_id => l_parent_entity_id,
                      --Bugfix 3848844 : Added Cal Period ID as a parameter
                      p_cal_period_id => l_cal_period_id);

        --Bugfix 4179379 : Send notifications via workflow
        gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                      p_run_name       => l_run_name,
                                                      p_cons_entity_id => l_parent_entity_id,
                                                      p_category_code  => 'NOT_APPLICABLE');

      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_api || '.HIERARCHY_ALTERED',
                       '<<Exit>>');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.HIERARCHY_ALTERED',
                         'No Data Found');
        END IF;
        RETURN 'SUCCESS'; -- NO_IMPACT_OCCURRED
    END;
    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'SUCCESS';
  END hierarchy_altered;

  FUNCTION data_sub_load_executed(p_subscription_guid in raw,
                                  p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS
    l_parameter_list     wf_parameter_list_t;
    l_data_sub_info      gcs_data_sub_dtls%ROWTYPE;
    l_load_id            NUMBER(15);
    l_message_name       VARCHAR2(30);
    l_entry_id           NUMBER(15);
    l_stat_entry_id      NUMBER(15);
    l_prop_entry_id      NUMBER(15);
    l_stat_prop_entry_id NUMBER(15);
    l_currency_type_code VARCHAR2(30);
    l_ledger_id          NUMBER(15);
    l_errbuf             VARCHAR2(200);
    l_retcode            VARCHAR2(200);

    l_cal_period_end_date_attr NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
    l_cal_period_end_date_ver  NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id;
    l_func_currency_attr       NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                            .attribute_id;
    l_func_currency_ver        NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                            .version_id;

    CURSOR c_impacted_runs(p_cal_period_id IN NUMBER, p_currency_code IN VARCHAR2, p_entity_id IN NUMBER, p_balance_type_code IN VARCHAR2) IS

      SELECT gcer.run_name,
             gcer.run_entity_id,
             gcer.hierarchy_id,
             gcr.cons_relationship_id
        FROM gcs_cons_eng_runs      gcer,
             gcs_cons_relationships gcr,
             fem_cal_periods_attr   fcpa,
             gcs_entity_cons_attrs  geca,
             gcs_cal_period_maps_gt gcpmt,
             fem_cal_periods_b      fcpb,
             gcs_hierarchies_b      ghb
       WHERE gcer.most_recent_flag = 'Y'
         AND gcer.balance_type_code = p_balance_type_code
         AND gcer.cal_period_id = gcpmt.target_cal_period_id
         AND gcer.hierarchy_id = gcr.hierarchy_id
         AND gcer.run_entity_id = gcr.parent_entity_id
         AND gcr.child_entity_id = p_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND geca.hierarchy_id = gcr.hierarchy_id
         AND gcer.hierarchy_id = ghb.hierarchy_id
         AND gcpmt.source_cal_period_id = p_cal_period_id
         AND gcpmt.target_cal_period_id = fcpb.cal_period_id
         AND ghb.calendar_id = fcpb.calendar_id
         AND ghb.dimension_group_id = fcpb.dimension_group_id
         AND geca.entity_id = gcr.child_entity_id
         AND geca.currency_code = p_currency_code
         AND fcpa.cal_period_id = fcpb.cal_period_id
         AND fcpa.attribute_id = l_cal_period_end_date_attr
         AND fcpa.version_id = l_cal_period_end_date_ver
         AND fcpa.date_assign_value BETWEEN gcr.start_date AND
             NVL(gcr.end_date, fcpa.date_assign_value);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.DATA_SUB_LOAD_EXECUTED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list := p_event.getParameterList();
    l_load_id        := TO_NUMBER(WF_EVENT.getValueForParameter('LOAD_ID',
                                                                l_parameter_list));
    l_ledger_id      := TO_NUMBER(WF_EVENT.getValueForParameter('LEDGER_ID',
                                                                l_parameter_list));

    SELECT gdsd.entity_id,
           gdsd.cal_period_id,
           NVL(gdsd.currency_code, fla.dim_attribute_varchar_member),
           gdsd.balance_type_code,
           gdsd.load_method_code,
           gdsd.currency_type_code,
           gdsd.load_id,
           DECODE(status_code,
                  -- Bug Fix: 5647099
                  'UNDONE',
                  'GCS_PRISTINE_DATA_UNDO_LOAD',
                  DECODE(load_method_code,
                         'INITIAL_LOAD',
                         'GCS_PRISTINE_DATA_FULL_LOAD',
                         'GCS_PRISTINE_DATA_INC_LOAD')),
           DECODE(gdsd.currency_code,
                  NULL,
                  'ENTERED',
                  fla.dim_attribute_varchar_member,
                  'ENTERED',
                  'TRANSLATED')
      INTO l_data_sub_info.entity_id,
           l_data_sub_info.cal_period_id,
           l_data_sub_info.currency_code,
           l_data_sub_info.balance_type_code,
           l_data_sub_info.load_method_code,
           l_data_sub_info.currency_type_code,
           l_data_sub_info.load_id,
           l_message_name,
           l_currency_type_code
      FROM gcs_data_sub_dtls gdsd, fem_ledgers_attr fla
     WHERE gdsd.load_id = l_load_id
       AND fla.ledger_id = l_ledger_id
       AND fla.attribute_id = l_func_currency_attr
       AND fla.version_id = l_func_currency_ver;

    --Explode into calendar period maps table gcs_cal_period_maps_gt
    gcs_utility_pkg.populate_calendar_map_details(l_data_sub_info.cal_period_id,
                                                  'Y',
                                                  'N');

    FOR v_impacted_runs IN c_impacted_runs(l_data_sub_info.cal_period_id,
                                           l_data_sub_info.currency_code,
                                           l_data_sub_info.entity_id,
                                           l_data_sub_info.balance_type_code) LOOP

      insert_impact_analysis(p_run_name                => v_impacted_runs.run_name,
                             p_consolidation_entity_id => v_impacted_runs.run_entity_id,
                             p_child_entity_id         => l_data_sub_info.entity_id,
                             p_message_name            => l_message_name,
                             p_date_token              => sysdate,
                             p_load_id                 => l_data_sub_info.load_id);

      -- Bugfix 4322320: Removing call to incremental data prep. Will add back after controlled release
      -- gcs_data_prep_pkg.gcs_incremental_data_prep(
      --       x_errbuf      =>  l_errbuf,
      --       x_retcode     =>  l_retcode,
      --       x_entry_id      =>  l_entry_id,
      --       x_stat_entry_id     =>  l_stat_entry_id,
      --       x_prop_entry_id     =>  l_prop_entry_id,
      --       x_stat_prop_entry_id    =>  l_stat_prop_entry_id,
      --       p_source_cal_period_id    =>  l_data_sub_info.cal_period_id,
      --       p_balance_type_code   =>  l_data_sub_info.balance_type_code,
      --       p_ledger_id     =>      l_ledger_id,
      --       p_currency_code     =>  l_data_sub_info.currency_code,
      --       p_dataset_code      =>  l_dataset_code,
      --       p_run_name      =>  v_impacted_runs.run_name,
      --       p_cons_relationship_id    =>  v_impacted_runs.cons_relationship_id,
      --       p_currency_type_code    =>  l_currency_type_code);

      --     UPDATE gcs_cons_impact_analyses
      -- SET     entry_id      = l_entry_id,
      --         stat_entry_id   = l_stat_entry_id,
      --         pre_prop_entry_id   = l_prop_entry_id,
      --         pre_prop_stat_entry_id  = l_stat_prop_entry_id
      -- WHERE  load_id      = l_data_sub_info.load_id;
      --
      --  IF (l_entry_id IS NOT NULL) THEN
      --   -- Call Entries XML generation API
      --     gcs_xml_gen_pkg.generate_entry_xml( p_entry_id    => l_entry_id,
      --                                       p_category_code   => 'DATAPREPARATION',
      --                                     p_cons_rule_flag  =>'N');
      --    END IF;

      -- IF (l_stat_entry_id IS NOT NULL) THEN
      --   -- Call Entries XML generation API
      --   gcs_xml_gen_pkg.generate_entry_xml(   p_entry_id              => l_stat_entry_id,
      --                                         p_category_code         => 'DATAPREPARATION',
      --                                         p_cons_rule_flag        =>'N');
      --  END IF;

      UPDATE gcs_cons_eng_runs
         SET impacted_flag = 'Y'
       WHERE run_name = v_impacted_runs.run_name
         AND run_entity_id = v_impacted_runs.run_entity_id
         AND most_recent_flag = 'Y';

      rollup_impact(p_hierarchy_id            => v_impacted_runs.hierarchy_id,
                    p_consolidation_entity_id => v_impacted_runs.run_entity_id,
                    p_cal_period_id           => l_data_sub_info.cal_period_id);

      --Bugfix 4179379 : Send notifications via workflow
      gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                    p_run_name       => v_impacted_runs.run_name,
                                                    p_cons_entity_id => v_impacted_runs.run_entity_id,
                                                    p_category_code  => 'NOT_APPLICABLE',
                                                    p_load_id        => l_load_id);

    END LOOP;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.DATA_SUB_LOAD_EXECUTED.end',
                     '<<Exit>>');
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.DATA_SUB_LOAD_EXECUTED',
                       SQLERRM);
      END IF;
      RETURN 'SUCCESS';
  END data_sub_load_executed;

  FUNCTION acqdisp_altered(p_subscription_guid in raw,
                           p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS

    l_entry_id            NUMBER(15);
    l_orig_entry_id       NUMBER(15);
    l_start_cal_period_id NUMBER;
    l_end_cal_period_id   NUMBER;
    l_hierarchy_id        NUMBER;
    l_entity_id           NUMBER;
    l_bal_type_code       VARCHAR2(30);
    l_change_type_code    VARCHAR2(30);
    l_parameter_list      wf_parameter_list_t;
    l_run_name            VARCHAR2(80);
    l_start_cp_end_date   DATE;
    l_end_cp_end_date     DATE;
    l_entity_type_code    VARCHAR2(1);
    l_cons_entity_id      NUMBER;
    l_cal_period_attr     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                   .attribute_id;
    l_cal_period_version  NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                   .version_id;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ACQDISP_ALTERED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list   := p_event.getParameterList();
    l_change_type_code := WF_EVENT.getValueForParameter('CHANGE_TYPE_CODE',
                                                        l_parameter_list);
    l_entry_id         := TO_NUMBER(WF_EVENT.getValueForParameter('ENTRY_ID',
                                                                  l_parameter_list));
    l_orig_entry_id    := TO_NUMBER(WF_EVENT.getValueForParameter('ORIG_ENTRY_ID',
                                                                  l_parameter_list));

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ACQDISP_ALTERED',
                     'Change Type Code		:	' || l_change_type_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ACQDISP_ALTERED',
                     'Entry ID						:	' || l_entry_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ACQDISP_ALTERED',
                     'Original Entry ID	:	' || l_orig_entry_id);
    END IF;

    SELECT geh.start_cal_period_id,
           geh.end_cal_period_id,
           geh.hierarchy_id,
           geh.entity_id,
           geh.balance_type_code,
           fcpa_start.date_assign_value
      INTO l_start_cal_period_id,
           l_end_cal_period_id,
           l_hierarchy_id,
           l_entity_id,
           l_bal_type_code,
           l_start_cp_end_date
      FROM gcs_entry_headers geh, fem_cal_periods_attr fcpa_start
     WHERE geh.entry_id = l_entry_id
       AND geh.start_cal_period_id = fcpa_start.cal_period_id
       AND fcpa_start.attribute_id = l_cal_period_attr
       AND fcpa_start.version_id = l_cal_period_version;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ACQDISP_ALTERED',
                     'End Date Value			:	' || l_start_cp_end_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ACQDISP_ALTERED',
                     'Entity ID				:	' || l_entity_id);
    END IF;

    SELECT parent_entity_id
      INTO l_cons_entity_id
      FROM gcs_cons_relationships
     WHERE hierarchy_id = l_hierarchy_id
       AND child_entity_id = l_entity_id
       AND dominant_parent_flag = 'Y'
       AND l_start_cp_end_date BETWEEN start_date AND
           NVL(end_date, l_start_cp_end_date);

    -- Bugfix 4332123 : Resolve issue with the calendar period

    BEGIN
      SELECT run_name
        INTO l_run_name
        FROM gcs_cons_eng_runs
       WHERE most_recent_flag = 'Y'
         AND hierarchy_id = l_hierarchy_id
         AND balance_type_code = l_bal_type_code
         AND cal_period_id = l_start_cal_period_id
         AND run_entity_id = l_cons_entity_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --Check if change happened in earlier period
        SELECT gcer.run_name, gcer.cal_period_id
          INTO l_run_name, l_start_cal_period_id
          FROM gcs_cons_eng_runs gcer
         WHERE gcer.run_entity_id = l_cons_entity_id
           AND gcer.hierarchy_id = l_hierarchy_id
           AND gcer.most_recent_flag = 'Y'
           AND gcer.balance_type_code = l_bal_type_code
           AND gcer.cal_period_id =
               (SELECT min(gcer_inner.cal_period_id)
                  FROM gcs_cons_eng_runs gcer_inner
                 WHERE gcer_inner.run_entity_id = l_cons_entity_id
                   AND gcer_inner.hierarchy_id = l_hierarchy_id
                   AND gcer_inner.most_recent_flag = 'Y'
                   AND gcer_inner.balance_type_code = l_bal_type_code
                   AND gcer_inner.cal_period_id > l_start_cal_period_id);
    END;

    IF (l_change_type_code = 'NEW_ACQDISP') THEN
      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => l_cons_entity_id,
                             p_child_entity_id         => l_entity_id,
                             p_message_name            => 'GCS_ACQDISP_CREATED',
                             p_pre_relationship_id     => null,
                             p_post_relationship_id    => null,
                             p_date_token              => sysdate,
                             p_entry_id                => l_entry_id);
    ELSIF (l_change_type_code = 'ACQDISP_MODIFIED') THEN
      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => l_cons_entity_id,
                             p_child_entity_id         => l_entity_id,
                             p_message_name            => 'GCS_ACQDISP_MODIFIED',
                             p_pre_relationship_id     => null,
                             p_post_relationship_id    => null,
                             p_date_token              => sysdate,
                             p_entry_id                => l_entry_id,
                             p_orig_entry_id           => l_orig_entry_id);
    ELSIF (l_change_type_code = 'ACQDISP_UNDONE') THEN
      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => l_cons_entity_id,
                             p_child_entity_id         => l_entity_id,
                             p_message_name            => 'GCS_ACQDISP_UNDO',
                             p_pre_relationship_id     => null,
                             p_post_relationship_id    => null,
                             p_date_token              => sysdate,
                             p_entry_id                => l_entry_id,
                             p_orig_entry_id           => l_orig_entry_id);
    END IF;

    -- Bugfix 3848844 : Added update for impact of the gcs_cons_eng_runs

    UPDATE gcs_cons_eng_runs
       SET impacted_flag = 'Y'
     WHERE run_name = l_run_name
       AND run_entity_id = l_cons_entity_id
       AND most_recent_flag = 'Y';

    rollup_impact(p_hierarchy_id            => l_hierarchy_id,
                  p_consolidation_entity_id => l_cons_entity_id,
                  p_cal_period_id           => l_start_cal_period_id);

    --Bugfix 4179379 : Send notifications via workflow
    gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                  p_run_name       => l_run_name,
                                                  p_cons_entity_id => l_cons_entity_id,
                                                  p_category_code  => 'NOT_APPLICABLE');

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ACQDISP_ALTERED.end',
                     '<<Exit>>');
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.ACQDISP_ALTERED',
                       'Error occurred : ' || SQLERRM);
      END IF;
      RETURN 'SUCCESS';
  END acqdisp_altered;

  FUNCTION adjustment_altered(p_subscription_guid in raw,
                              p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS
    l_entry_id            NUMBER(15);
    l_orig_entry_id       NUMBER(15);
    l_start_cal_period_id NUMBER;
    l_end_cal_period_id   NUMBER;
    l_hierarchy_id        NUMBER;
    l_entity_id           NUMBER;
    l_bal_type_code       VARCHAR2(30);
    l_parameter_list      wf_parameter_list_t;
    l_run_name            VARCHAR2(80);
    l_start_cp_end_date   DATE;
    l_end_cp_end_date     DATE;
    l_entity_type_code    VARCHAR2(1);
    l_cons_entity_id      NUMBER;
    l_email               VARCHAR2(200);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ADJUSTMENT_ALTERED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list := p_event.getParameterList();

    l_entry_id      := TO_NUMBER(WF_EVENT.getValueForParameter('ENTRY_ID',
                                                               l_parameter_list));
    l_orig_entry_id := TO_NUMBER(WF_EVENT.getValueForParameter('ORIG_ENTRY_ID',
                                                               l_parameter_list));

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ADJUSTMENT_ALTERED',
                     'Entry ID			: ' || l_entry_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ADJUSTMENT_ALTERED',
                     'Original Entry ID 	: ' || l_orig_entry_id);
    END IF;

    SELECT geh.start_cal_period_id,
           geh.end_cal_period_id,
           geh.hierarchy_id,
           geh.entity_id,
           geh.balance_type_code,
           fcpa_start.date_assign_value
      INTO l_start_cal_period_id,
           l_end_cal_period_id,
           l_hierarchy_id,
           l_entity_id,
           l_bal_type_code,
           l_start_cp_end_date
      FROM gcs_entry_headers geh, fem_cal_periods_attr fcpa_start
     WHERE geh.entry_id = l_entry_id
       AND geh.start_cal_period_id = fcpa_start.cal_period_id
       AND fcpa_start.attribute_id =
           gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
    .attribute_id
       AND fcpa_start.version_id =
           gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
    .version_id;

    SELECT parent_entity_id
      INTO l_cons_entity_id
      FROM gcs_cons_relationships
     WHERE hierarchy_id = l_hierarchy_id
       AND child_entity_id = l_entity_id
       AND dominant_parent_flag = 'Y'
       AND l_start_cp_end_date BETWEEN start_date AND
           NVL(end_date, l_start_cp_end_date);

    SELECT run_name
      INTO l_run_name
      FROM gcs_cons_eng_runs
     WHERE most_recent_flag = 'Y'
       AND hierarchy_id = l_hierarchy_id
       AND cal_period_id = l_start_cal_period_id
       AND balance_type_code = l_bal_type_code
       AND run_entity_id = l_cons_entity_id;

    IF (l_orig_entry_id IS NULL) THEN

      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => l_cons_entity_id,
                             p_child_entity_id         => l_entity_id,
                             p_message_name            => 'GCS_ADJUSTMENT_CREATED',
                             p_pre_relationship_id     => null,
                             p_post_relationship_id    => null,
                             p_date_token              => sysdate,
                             p_entry_id                => l_entry_id);

    ELSIF (l_entry_id <> l_orig_entry_id) THEN

      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => l_cons_entity_id,
                             p_child_entity_id         => l_entity_id,
                             p_message_name            => 'GCS_ADJUSTMENT_MODIFIED',
                             p_pre_relationship_id     => null,
                             p_post_relationship_id    => null,
                             p_date_token              => sysdate,
                             p_entry_id                => l_entry_id,
                             p_orig_entry_id           => l_orig_entry_id);

    END IF;

    UPDATE gcs_cons_eng_runs
       SET impacted_flag = 'Y'
     WHERE run_name = l_run_name
       AND run_entity_id = l_cons_entity_id
       AND most_recent_flag = 'Y';

    rollup_impact(p_hierarchy_id            => l_hierarchy_id,
                  p_consolidation_entity_id => l_cons_entity_id,
                  p_cal_period_id           => l_start_cal_period_id);

    --Bugfix 4179379 : Send notifications via workflow
    gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                  p_run_name       => l_run_name,
                                                  p_cons_entity_id => l_cons_entity_id,
                                                  p_category_code  => 'NOT_APPLICABLE',
                                                  p_entry_id       => l_entry_id);

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'SUCCESS';
  END adjustment_altered;

  FUNCTION daily_rates_altered(p_subscription_guid in raw,
                               p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS
    l_parameter_list wf_parameter_list_t;

    l_from_currency        VARCHAR2(30);
    l_to_currency          VARCHAR2(30);
    l_from_conversion_date DATE;
    l_to_conversion_date   DATE;
    l_conversion_type      VARCHAR2(30);

    l_cp_end_date_attr_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                      .attribute_id;
    l_cp_end_date_version_id NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                      .version_id;

    CURSOR c_impacted_runs(p_from_currency IN VARCHAR2, p_to_currency IN VARCHAR2, p_from_conv_date IN DATE, p_to_conv_date IN DATE, p_conversion_type IN VARCHAR2) IS
      SELECT gcer.run_name,
             gcer.run_entity_id,
             gcerd.child_entity_id,
             gcer.hierarchy_id,
             gcer.cal_period_id
        FROM gcs_cons_eng_runs      gcer,
             gcs_cons_eng_run_dtls  gcerd,
             gcs_curr_treatments_b  gctb,
             fem_cal_periods_b      fcpb,
             fem_cal_periods_attr   fcpa_end,
             gcs_cons_relationships gcr,
             gcs_entity_cons_attrs  geca_parent,
             gcs_entity_cons_attrs  geca_child
       WHERE gcer.cal_period_id = fcpb.cal_period_id
         AND fcpb.cal_period_id = fcpa_end.cal_period_id
         AND fcpa_end.attribute_id = l_cp_end_date_attr_id
         AND fcpa_end.version_id = l_cp_end_date_version_id
         AND fcpa_end.date_assign_value BETWEEN p_from_conv_date AND
             p_to_conv_date
         AND gcer.most_recent_flag = 'Y'
         AND gcer.run_name = gcerd.run_name
         AND gcer.run_entity_id = gcerd.consolidation_entity_id
         AND gcerd.category_code = 'TRANSLATION'
         AND gcerd.cons_relationship_id = gcr.cons_relationship_id
         AND gcr.curr_treatment_id = gctb.curr_treatment_id
         AND p_conversion_type IN
             (gctb.ending_rate_type, gctb.average_rate_type)
         AND gcr.parent_entity_id = geca_parent.entity_id
         AND gcr.hierarchy_id = geca_parent.hierarchy_id
         AND gcr.dominant_parent_flag = 'Y'
         AND gcr.child_entity_id = geca_child.entity_id
         AND gcr.hierarchy_id = geca_child.hierarchy_id
         AND geca_parent.currency_code = p_to_currency
         AND geca_child.currency_code = p_from_currency;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.DAILY_RATES_ALTERED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list := p_event.getParameterList();

    l_from_currency        := WF_EVENT.getValueForParameter('FROM_CURRENCY',
                                                            l_parameter_list);
    l_to_currency          := WF_EVENT.getValueForParameter('TO_CURRENCY',
                                                            l_parameter_list);
    l_from_conversion_date := TO_DATE(WF_EVENT.getValueForParameter('FROM_CONVERSION_DATE',
                                                                    l_parameter_list),
                                      'YYYY/MM/DD');
    l_to_conversion_date   := TO_DATE(NVL(WF_EVENT.getValueForParameter('TO_CONVERSION_DATE',
                                                                        l_parameter_list),
                                          TO_CHAR(l_from_conversion_date,
                                                  'YYYY/MM/DD')),
                                      'YYYY/MM/DD');
    l_conversion_type      := WF_EVENT.getValueForParameter('CONVERSION_TYPE',
                                                            l_parameter_list);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.DAILY_RATES_ALTERED',
                     'From Currency	: ' || l_from_currency);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.DAILY_RATES_ALTERED',
                     'To Currency   	: ' || l_to_currency);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.DAILY_RATES_ALTERED',
                     'From Date	: ' || l_from_conversion_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.DAILY_RATES_ALTERED',
                     'To Date		: ' || l_to_conversion_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.DAILY_RATES_ALTERED',
                     'Conversion Type	: ' || l_conversion_type);
    END IF;

    FOR v_impacted_runs IN c_impacted_runs(l_from_currency,
                                           l_to_currency,
                                           l_from_conversion_date,
                                           l_to_conversion_date,
                                           l_conversion_type) LOOP

      insert_impact_analysis(p_run_name                => v_impacted_runs.run_name,
                             p_consolidation_entity_id => v_impacted_runs.run_entity_id,
                             p_child_entity_id         => v_impacted_runs.child_entity_id,
                             p_message_name            => 'GCS_TRANSLATION_RATES_ALTERED',
                             p_date_token              => sysdate);

      UPDATE gcs_cons_eng_runs
         SET impacted_flag = 'Y'
       WHERE run_name = v_impacted_runs.run_name
         ANd run_entity_id = v_impacted_runs.run_entity_id;

      rollup_impact(p_hierarchy_id            => v_impacted_runs.hierarchy_id,
                    p_consolidation_entity_id => v_impacted_runs.run_entity_id,
                    p_cal_period_id           => v_impacted_runs.cal_period_id);

      --Bugfix 4179379 : Send notifications via workflow
      gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                    p_run_name       => v_impacted_runs.run_name,
                                                    p_cons_entity_id => v_impacted_runs.run_entity_id,
                                                    p_category_code  => 'NOT_APPLICABLE');

    END LOOP;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.DAILY_RATES_ALTERED.end',
                     '<<Exit>>');
    END IF;

    RETURN 'SUCCESS';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'SUCCESS';
  END daily_rates_altered;

  FUNCTION historical_rates_altered(p_subscription_guid in raw,
                                    p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS

    l_parameter_list wf_parameter_list_t;

    l_cal_period_id NUMBER;
    l_entity_id     NUMBER(15);
    l_hierarchy_id  NUMBER(15);
    l_run_name      VARCHAR2(240);
    l_run_entity_id NUMBER(15);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HISTORICAL_RATES_ALTERED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list := p_event.getParameterList();

    l_cal_period_id := TO_NUMBER(WF_EVENT.getValueForParameter('PERIOD_ID',
                                                               l_parameter_list));
    l_entity_id     := TO_NUMBER(WF_EVENT.getValueForParameter('ENTITY_ID',
                                                               l_parameter_list));
    l_hierarchy_id  := TO_NUMBER(WF_EVENT.getValueForParameter('HIERARCHY_ID',
                                                               l_parameter_list));

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HISTORICAL_RATES_ALTERED',
                     'Calendar Period	: ' || l_cal_period_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HISTORICAL_RATES_ALTERED',
                     'Entity		: ' || l_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HISTORICAL_RATES_ALTERED',
                     'Hierarchy		: ' || l_hierarchy_id);
    END IF;

    SELECT gcer.run_name, gcer.run_entity_id
      INTO l_run_name, l_run_entity_id
      FROM gcs_cons_eng_runs gcer, gcs_cons_eng_run_dtls gcerd
     WHERE gcer.hierarchy_id = l_hierarchy_id
       AND gcer.cal_period_id = l_cal_period_id
       AND gcer.most_recent_flag = 'Y'
       AND gcer.run_entity_id = gcerd.consolidation_entity_id
       AND gcer.run_name = gcerd.run_name
       AND gcerd.category_code = 'TRANSLATION'
       AND gcerd.child_entity_id = l_entity_id;

    insert_impact_analysis(p_run_name                => l_run_name,
                           p_consolidation_entity_id => l_run_entity_id,
                           p_child_entity_id         => l_entity_id,
                           p_message_name            => 'GCS_HISTORICAL_RATES_ALTERED',
                           p_date_token              => sysdate);

    UPDATE gcs_cons_eng_runs
       SET impacted_flag = 'Y'
     WHERE run_name = l_run_name
       ANd run_entity_id = l_run_entity_id;

    rollup_impact(p_hierarchy_id            => l_hierarchy_id,
                  p_consolidation_entity_id => l_run_entity_id,
                  p_cal_period_id           => l_cal_period_id);

    --Bugfix 4179379 : Send notifications via workflow
    gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                  p_run_name       => l_run_name,
                                                  p_cons_entity_id => l_run_entity_id,
                                                  p_category_code  => 'NOT_APPLICABLE');

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.HISTORICAL_RATES_ALTERED.end',
                     '<<Exit>>');
    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'SUCCESS';
  END historical_rates_altered;

  PROCEDURE consolidation_completed(p_run_name            IN VARCHAR2,
                                    p_run_entity_id       IN NUMBER,
                                    p_cal_period_id       IN NUMBER,
                                    p_cal_period_end_date IN DATE,
                                    p_hierarchy_id        IN NUMBER,
                                    p_balance_type_code   IN VARCHAR2)

   IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_parent_entity_id     NUMBER;
    l_run_parent_entity_id NUMBER;
    l_run_name             VARCHAR2(240);
    l_cal_period_info      gcs_utility_pkg.r_cal_period_info;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CONSOLIDATION_COMPLETED.begin',
                     '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Run Name		: ' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Run Entity		: ' || p_run_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Cal Period 		: ' || p_cal_period_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Period End Date	: ' || p_cal_period_end_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Hierarchy		: ' || p_hierarchy_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.CONSOLIDATION_COMPLETED',
                     'Balance Type	: ' || p_balance_type_code);
    END IF;

    --Check if top parent needs to be re-consolidated
    SELECT parent_entity_id
      INTO l_run_parent_entity_id
      FROM gcs_cons_eng_runs
     WHERE run_name = p_run_name
       AND run_entity_id = p_run_entity_id;

    IF (l_run_parent_entity_id = -1) THEN
      BEGIN
        SELECT parent_entity_id
          INTO l_parent_entity_id
          FROM gcs_cons_relationships
         WHERE hierarchy_id = p_hierarchy_id
           AND child_entity_id = p_run_entity_id
           AND dominant_parent_flag = 'Y'
           AND p_cal_period_end_date BETWEEN start_date AND
               NVL(end_date, p_cal_period_end_date);

        SELECT run_name
          INTO l_run_name
          FROM gcs_cons_eng_runs
         WHERE run_entity_id = l_parent_entity_id
           AND cal_period_id = p_cal_period_id
           AND hierarchy_id = p_hierarchy_id
           AND balance_type_code = p_balance_type_code
           AND most_recent_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          l_parent_entity_id := -1;
      END;

      IF ((l_parent_entity_id <> -1) AND (l_run_name IS NOT NULL)) THEN
        --Impact has occurred for parent level entity
        insert_impact_analysis(p_run_name                => l_run_name,
                               p_consolidation_entity_id => l_parent_entity_id,
                               p_child_entity_id         => p_run_entity_id,
                               p_message_name            => 'GCS_SUB_RECONSOLIDATED',
                               p_date_token              => sysdate);

        UPDATE gcs_cons_eng_runs
           SET impacted_flag = 'Y'
         WHERE run_name = l_run_name
           AND run_entity_id = l_parent_entity_id;

        rollup_impact(p_hierarchy_id            => p_hierarchy_id,
                      p_consolidation_entity_id => l_parent_entity_id,
                      p_cal_period_id           => p_cal_period_id);

        gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                      p_run_name       => l_run_name,
                                                      p_cons_entity_id => l_parent_entity_id,
                                                      p_category_code  => 'NOT_APPLICABLE');

      END IF;

    END IF;

    BEGIN
      -- Check to see if subsequent period impacted
      gcs_utility_pkg.get_cal_period_details(p_cal_period_id     => p_cal_period_id,
                                             p_cal_period_record => l_cal_period_info);

      SELECT run_name
        INTO l_run_name
        FROM gcs_cons_eng_runs
       WHERE hierarchy_id = p_hierarchy_id
         AND run_entity_id = p_run_entity_id
         AND balance_type_code = p_balance_type_code
         AND cal_period_id = l_cal_period_info.next_cal_period_id
         AND most_recent_flag = 'Y';

      insert_impact_analysis(p_run_name                => l_run_name,
                             p_consolidation_entity_id => p_run_entity_id,
                             p_child_entity_id         => p_run_entity_id,
                             p_message_name            => 'GCS_PRIOR_PD_RECONSOLIDATED',
                             p_date_token              => sysdate);

      UPDATE gcs_cons_eng_runs
         SET impacted_flag = 'Y'
       WHERE run_name = l_run_name
         AND run_entity_id = p_run_entity_id;

      rollup_impact(p_hierarchy_id            => p_hierarchy_id,
                    p_consolidation_entity_id => p_run_entity_id,
                    p_cal_period_id           => l_cal_period_info.next_cal_period_id);

      gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                    p_run_name       => l_run_name,
                                                    p_cons_entity_id => p_run_entity_id,
                                                    p_category_code  => 'NOT_APPLICABLE');

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
        -- No impact has occurred
    END;

    COMMIT;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CONSOLIDATION_COMPLETED.end',
                     '<<Exit>>');
    END IF;

  END;

  PROCEDURE value_set_map_updated(p_dimension_id        IN NUMBER,
                                  p_eff_start_date      IN DATE,
                                  p_eff_end_date        IN DATE,
                                  p_consolidation_vs_id IN NUMBER) IS

    TYPE r_run_entity_info IS RECORD(
      run_name      VARCHAR2(240),
      run_entity_id NUMBER,
      cal_period_id NUMBER,
      hierarchy_id  NUMBER(15));
    TYPE t_run_entity_info IS TABLE OF r_run_entity_info INDEX BY VARCHAR2(256);
    l_hash_key            VARCHAR2(255);
    l_tab_run_entity_info t_run_entity_info;
    l_run_entity_info     r_run_entity_info;
    l_character_index     VARCHAR2(255);

    l_cp_end_date_attr_id      NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                        .attribute_id;
    l_cp_end_date_version_id   NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                        .version_id;
    l_cp_start_date_attr_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_START_DATE')
                                        .attribute_id;
    l_cp_start_date_version_id NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_START_DATE')
                                        .version_id;
    l_ledger_attr_id           NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                        .attribute_id;
    l_ledger_version_id        NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                        .version_id;
    l_gvsc_attr_id             NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                        .attribute_id;
    l_gvsc_version_id          NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                        .version_id;

    CURSOR c_impacted_hierarchies IS
      SELECT min(gcer.cal_period_id) cal_period_id,
             gcer.hierarchy_id hierarchy_id,
             min(fcpa_end.date_assign_value) end_date
        FROM gcs_cons_eng_runs    gcer,
             fem_cal_periods_attr fcpa_start,
             fem_cal_periods_attr fcpa_end
       WHERE gcer.cal_period_id = fcpa_start.cal_period_id
         AND gcer.cal_period_id = fcpa_end.cal_period_id
         AND fcpa_start.date_assign_value >= p_eff_start_date
         AND fcpa_end.date_assign_value <= p_eff_end_date
         AND fcpa_start.attribute_id = l_cp_start_date_attr_id
         AND fcpa_start.version_id = l_cp_start_date_version_id
         AND fcpa_end.attribute_id = l_cp_end_date_attr_id
         AND fcpa_end.version_id = l_cp_end_date_version_id
       GROUP BY hierarchy_id;

    -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

    CURSOR c_impacted_entities(p_hierarchy_id NUMBER, p_cal_period_id NUMBER, p_cal_period_end_date DATE) IS
      SELECT gcr.parent_entity_id, gcr.child_entity_id, gcer.run_name
        FROM gcs_cons_relationships   gcr,
             gcs_cons_eng_runs        gcer,
             fem_global_vs_combo_defs fgvcd,
             gcs_entities_attr        gea,
             fem_ledgers_attr         fla
       WHERE gcr.hierarchy_id = p_hierarchy_id
         AND gcr.hierarchy_id = gcer.hierarchy_id
         AND gcer.most_recent_flag = 'Y'
         AND gcer.cal_period_id = p_cal_period_id
         AND gcr.parent_entity_id = gcer.run_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND p_cal_period_end_date BETWEEN gcr.start_date AND
             NVL(gcr.end_date, p_cal_period_end_date)
         AND gcr.child_entity_id = gea.entity_id
         AND gea.data_type_code = gcer.balance_type_code
         AND p_cal_period_end_date BETWEEN gea.effective_start_date AND
             NVL(gea.effective_end_date, p_cal_period_end_date)
         AND gea.ledger_id = fla.ledger_id
         AND fla.attribute_id = l_gvsc_attr_id
         AND fla.version_id = l_gvsc_version_id
         AND fla.dim_attribute_numeric_member = fgvcd.global_vs_combo_id
         AND fgvcd.dimension_id = p_dimension_id
         AND fgvcd.value_set_id <> p_consolidation_vs_id;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.VALUE_SET_MAP_UPDATED.begin',
                     '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.VALUE_SET_MAP_UPDATED',
                     'Dimension Id		: ' || p_dimension_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.VALUE_SET_MAP_UPDATED',
                     'Effective Start Date	: ' || p_eff_start_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.VALUE_SET_MAP_UPDATED',
                     'Effective End Date	: ' || p_eff_end_date);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.VALUE_SET_MAP_UPDATED',
                     'Consolidation VS Id	: ' || p_consolidation_vs_id);
    END IF;

    FOR v_impacted_hierarchies IN c_impacted_hierarchies LOOP

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.VALUE_SET_MAP_UPDATED',
                       'Hierarchy Id       	: ' ||
                       v_impacted_hierarchies.hierarchy_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.VALUE_SET_MAP_UPDATED',
                       'Cal Period Id	: ' ||
                       v_impacted_hierarchies.cal_period_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.VALUE_SET_MAP_UPDATED',
                       'Cal Period End Date	: ' ||
                       v_impacted_hierarchies.end_date);
      END IF;

      FOR v_impacted_entities IN c_impacted_entities(v_impacted_hierarchies.hierarchy_id,
                                                     v_impacted_hierarchies.cal_period_id,
                                                     v_impacted_hierarchies.end_date) LOOP

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.VALUE_SET_MAP_UPDATED',
                         'Parent Entity Id  : ' ||
                         v_impacted_entities.parent_entity_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.VALUE_SET_MAP_UPDATED',
                         'Child Entity Id	: ' ||
                         v_impacted_entities.child_entity_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.VALUE_SET_MAP_UPDATED',
                         'Run Name		: ' || v_impacted_entities.run_name);
        END IF;

        insert_impact_analysis(p_run_name                => v_impacted_entities.run_name,
                               p_consolidation_entity_id => v_impacted_entities.parent_entity_id,
                               p_child_entity_id         => v_impacted_entities.child_entity_id,
                               p_message_name            => 'GCS_VS_MAP_UPDATED',
                               p_date_token              => sysdate);

        l_hash_key                      := v_impacted_entities.run_name ||
                                           ' - ' ||
                                           v_impacted_entities.parent_entity_id;
        l_run_entity_info.run_name      := v_impacted_entities.run_name;
        l_run_entity_info.run_entity_id := v_impacted_entities.parent_entity_id;
        l_run_entity_info.hierarchy_id  := v_impacted_hierarchies.hierarchy_id;
        l_run_entity_info.cal_period_id := v_impacted_hierarchies.cal_period_id;

        --Capture all the entity information in a hashtable so we don't perform the same update over and over
        l_tab_run_entity_info(l_hash_key) := l_run_entity_info;
      END LOOP;

    END LOOP;

    l_character_index := l_tab_run_entity_info.FIRST;

    WHILE (l_character_index IS NOT NULL) LOOP

      UPDATE gcs_cons_eng_runs
         SET impacted_flag = 'Y'
       WHERE run_name = l_tab_run_entity_info(l_character_index)
      .run_name
         AND run_entity_id = l_tab_run_entity_info(l_character_index)
      .run_entity_id;

      rollup_impact(p_hierarchy_id            => l_tab_run_entity_info(l_character_index)
                                                .hierarchy_id,
                    p_consolidation_entity_id => l_tab_run_entity_info(l_character_index)
                                                .run_entity_id,
                    p_cal_period_id           => l_tab_run_entity_info(l_character_index)
                                                .cal_period_id);

      gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                    p_run_name       => l_tab_run_entity_info(l_character_index)
                                                                       .run_name,
                                                    p_cons_entity_id => l_tab_run_entity_info(l_character_index)
                                                                       .run_entity_id,
                                                    p_category_code  => 'NOT_APPLICABLE');
      l_character_index := l_tab_run_entity_info.NEXT(l_character_index);
    END LOOP;

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.VALUE_SET_MAP_UPDATED.end',
                     '<<Exit>>');
    END IF;
  END;
  --
  -- Function
  --   adjustment_disabled()
  -- Purpose
  --   Tracks disabling adjustments
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes
  --   Bugfix 5613302
  FUNCTION adjustment_disabled(p_subscription_guid in raw,
                               p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2

   IS
    l_entry_id            NUMBER(15);
    l_start_cal_period_id NUMBER;
    l_end_cal_period_id   NUMBER;
    l_hierarchy_id        NUMBER;
    l_entity_id           NUMBER;
    l_bal_type_code       VARCHAR2(30);
    l_parameter_list      wf_parameter_list_t;
    l_run_name            VARCHAR2(80);
    l_start_cp_end_date   DATE;
    l_end_cp_end_date     DATE;
    l_entity_type_code    VARCHAR2(1);
    l_cons_entity_id      NUMBER;
    l_email               VARCHAR2(200);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.ADJUSTMENT_DISABLED.begin',
                     '<<Enter>>');
    END IF;

    l_parameter_list := p_event.getParameterList();

    l_entry_id := TO_NUMBER(WF_EVENT.getValueForParameter('ENTRY_ID',
                                                          l_parameter_list));

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.ADJUSTMENT_DISABLED',
                     'Entry ID			: ' || l_entry_id);

    END IF;

    SELECT geh.start_cal_period_id,
           geh.end_cal_period_id,
           geh.hierarchy_id,
           geh.entity_id,
           geh.balance_type_code,
           fcpa_start.date_assign_value
      INTO l_start_cal_period_id,
           l_end_cal_period_id,
           l_hierarchy_id,
           l_entity_id,
           l_bal_type_code,
           l_start_cp_end_date
      FROM gcs_entry_headers geh, fem_cal_periods_attr fcpa_start
     WHERE geh.entry_id = l_entry_id
       AND geh.start_cal_period_id = fcpa_start.cal_period_id
       AND fcpa_start.attribute_id =
           gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
    .attribute_id
       AND fcpa_start.version_id =
           gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
    .version_id;

    SELECT parent_entity_id
      INTO l_cons_entity_id
      FROM gcs_cons_relationships
     WHERE hierarchy_id = l_hierarchy_id
       AND child_entity_id = l_entity_id
       AND dominant_parent_flag = 'Y'
       AND l_start_cp_end_date BETWEEN start_date AND
           NVL(end_date, l_start_cp_end_date);

    SELECT run_name
      INTO l_run_name
      FROM gcs_cons_eng_runs
     WHERE most_recent_flag = 'Y'
       AND hierarchy_id = l_hierarchy_id
       AND cal_period_id = l_start_cal_period_id
       AND balance_type_code = l_bal_type_code
       AND run_entity_id = l_cons_entity_id;

    insert_impact_analysis(p_run_name                => l_run_name,
                           p_consolidation_entity_id => l_cons_entity_id,
                           p_child_entity_id         => l_entity_id,
                           p_message_name            => 'GCS_ADJUSTMENT_DISABLED',
                           p_pre_relationship_id     => null,
                           p_post_relationship_id    => null,
                           p_date_token              => sysdate,
                           p_entry_id                => l_entry_id);

    UPDATE gcs_cons_eng_runs
       SET impacted_flag = 'Y'
     WHERE run_name = l_run_name
       AND run_entity_id = l_cons_entity_id
       AND most_recent_flag = 'Y';

    rollup_impact(p_hierarchy_id            => l_hierarchy_id,
                  p_consolidation_entity_id => l_cons_entity_id,
                  p_cal_period_id           => l_start_cal_period_id);

    --Bugfix 4179379 : Send notifications via workflow
    gcs_eng_cp_utility_pkg.submit_xml_ntf_program(p_execution_type => 'IMPACT_ENGINE',
                                                  p_run_name       => l_run_name,
                                                  p_cons_entity_id => l_cons_entity_id,
                                                  p_category_code  => 'NOT_APPLICABLE',
                                                  p_entry_id       => l_entry_id);

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'SUCCESS';
  END adjustment_disabled;

END GCS_CONS_IMPACT_ANALYSIS_PKG;

/

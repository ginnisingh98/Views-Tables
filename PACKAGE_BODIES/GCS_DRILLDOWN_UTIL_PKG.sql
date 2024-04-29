--------------------------------------------------------
--  DDL for Package Body GCS_DRILLDOWN_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DRILLDOWN_UTIL_PKG" AS
/* $Header: gcs_drill_utilb.pls 120.3 2007/04/18 01:30:19 mikeward ship $ */

  new_line VARCHAR2(4) := '
';
  g_api VARCHAR2(80) := 'gcs.plsql.GCS_DRILLDOWN_UTIL_PKG';


  --
  -- Private Global Variables
  --

  g_entity_ledger_attr_id NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').attribute_id;
  g_entity_ledger_v_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID').version_id;

  g_entity_srcsys_attr_id NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE').attribute_id;
  g_entity_srcsys_v_id    NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE').version_id;

  g_cp_num_attr_id        NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id;
  g_cp_num_v_id           NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id;

  g_cp_year_attr_id       NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id;
  g_cp_year_v_id          NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id;

  g_cp_enddate_attr_id       NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').attribute_id;
  g_cp_enddate_v_id          NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE').version_id;

  --
  -- Private Procedures
  --



  --
  -- Public Procedures
  --

  FUNCTION get_currency_code
    (p_hierarchy_id           NUMBER,
     p_entity_id              NUMBER)
  RETURN VARCHAR2 IS
    l_ccy_code   VARCHAR2(30);

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_currency_code';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    SELECT eca.currency_code
    INTO l_ccy_code
    FROM gcs_entity_cons_attrs eca
    WHERE eca.hierarchy_id = p_hierarchy_id
    AND eca.entity_id = p_entity_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_ccy_code;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_currency_code;


  FUNCTION get_ledger_id
    (p_entity_id              NUMBER)
  RETURN NUMBER IS
    l_ledger_id  NUMBER;

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_ledger_id';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    SELECT fea.dim_attribute_numeric_member
    INTO l_ledger_id
    FROM fem_entities_attr fea
    WHERE fea.entity_id = p_entity_id
    AND   fea.attribute_id = g_entity_ledger_attr_id
    AND   fea.version_id = g_entity_ledger_v_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_ledger_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_ledger_id;


  FUNCTION get_ledger_id
    (p_entity_id                  NUMBER,
     p_cal_period_id_str          VARCHAR2)
  RETURN NUMBER IS
    l_ledger_id  NUMBER;

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_ledger_id_2param';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    SELECT gea.ledger_id
    INTO   l_ledger_id
    FROM   gcs_entities_attr   gea,
           fem_cal_periods_attr  fcpa_end_date
    WHERE  gea.entity_id               = p_entity_id
    AND    gea.data_type_code          = 'ACTUAL'
    AND    fcpa_end_date.cal_period_id = to_number(p_cal_period_id_str)
    AND    fcpa_end_date.attribute_id  = g_cp_enddate_attr_id
    AND    fcpa_end_date.version_id    = g_cp_enddate_v_id
    AND    fcpa_end_date.date_assign_value
           BETWEEN gea.effective_start_date
               AND nvl(gea.effective_end_date, fcpa_end_date.date_assign_value);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_ledger_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_ledger_id;



  FUNCTION get_src_sys_code
    (p_entity_id              NUMBER)
  RETURN NUMBER IS
    l_src_sys_code  NUMBER;

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_src_sys_code';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    SELECT fea.dim_attribute_numeric_member
    INTO l_src_sys_code
    FROM fem_entities_attr fea
    WHERE fea.entity_id = p_entity_id
    AND   fea.attribute_id = g_entity_srcsys_attr_id
    AND   fea.version_id = g_entity_srcsys_v_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_src_sys_code;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_src_sys_code;


  FUNCTION get_src_sys_code
    (p_entity_id                  NUMBER,
     p_cal_period_id_str          NUMBER)
  RETURN NUMBER IS
    l_src_sys_code  NUMBER;

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_src_sys_code_2param';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    SELECT gea.source_system_code
    INTO   l_src_sys_code
    FROM   gcs_entities_attr   gea,
           fem_cal_periods_attr  fcpa_end_date
    WHERE  gea.entity_id               = p_entity_id
    AND    gea.data_type_code          = 'ACTUAL'
    AND    fcpa_end_date.cal_period_id = to_number(p_cal_period_id_str)
    AND    fcpa_end_date.attribute_id  = g_cp_enddate_attr_id
    AND    fcpa_end_date.version_id    = g_cp_enddate_v_id
    AND    fcpa_end_date.date_assign_value
           BETWEEN gea.effective_start_date
               AND nvl(gea.effective_end_date, fcpa_end_date.date_assign_value);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_src_sys_code;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_src_sys_code;




  FUNCTION get_dataset_code
    (p_entity_id                  NUMBER,
     p_pristine_cal_period_id_str VARCHAR2)
  RETURN NUMBER IS
    l_dataset_code NUMBER;
    l_ledger_id    NUMBER;
    l_src_sys_code NUMBER;

    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_dataset_code';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    l_ledger_id := get_ledger_id(p_entity_id, p_pristine_cal_period_id_str);
    l_src_sys_code := get_src_sys_code(p_entity_id, p_pristine_cal_period_id_str);

    SELECT fdl.dataset_code
    INTO l_dataset_code
    FROM fem_data_locations fdl
    WHERE fdl.ledger_id = l_ledger_id
    AND   fdl.cal_period_id = to_number(p_pristine_cal_period_id_str)
    AND   fdl.source_system_code = l_src_sys_code
    AND   fdl.table_name = 'FEM_BALANCES'
    AND   fdl.balance_type_code = 'ACTUAL';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN l_dataset_code;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_dataset_code;


  FUNCTION get_pristine_cal_period_id
    (p_entity_id                  NUMBER,
     p_fch_cal_period_id_str      VARCHAR2)
  RETURN VARCHAR2 IS
    l_pristine_cal_period_id NUMBER;

    -- Cursor to check whether reverse mapping is needed
    CURSOR same_calendar_check_c IS
    SELECT 1
    FROM   gcs_data_sub_dtls gdsd
    WHERE  gdsd.entity_id = p_entity_id
    AND    gdsd.cal_period_id = to_number(p_fch_cal_period_id_str);

    dummy NUMBER;

    -- Cursor to handle the reverse mapping if necessary
    CURSOR reverse_map_period_c IS
    SELECT fcpb_source.cal_period_id source_cal_period_id
    FROM   fem_cal_periods_b       fcpb_source,
           fem_cal_periods_b       fcpb_target,
           gcs_cal_period_maps     gcpm,
           fem_cal_periods_attr    fcpb_source_num,
           fem_cal_periods_attr    fcpb_source_year,
           fem_cal_periods_attr    fcpb_target_num,
           fem_cal_periods_attr    fcpb_target_year,
           gcs_cal_period_map_dtls gcpmd
    WHERE  fcpb_target.cal_period_id = to_number(p_fch_cal_period_id_str)
    AND    fcpb_target.calendar_id = gcpm.target_calendar_id
    AND    fcpb_target.dimension_group_id = gcpm.target_dimension_group_id
    AND    fcpb_target_num.cal_period_id = to_number(p_fch_cal_period_id_str)
    AND    fcpb_target_year.cal_period_id = to_number(p_fch_cal_period_id_str)
    AND    fcpb_target_num.attribute_id = g_cp_num_attr_id
    AND    fcpb_target_num.version_id = g_cp_num_v_id
    AND    fcpb_target_year.attribute_id = g_cp_year_attr_id
    AND    fcpb_target_year.version_id = g_cp_year_v_id
    AND    gcpm.cal_period_map_id = gcpmd.cal_period_map_id
    AND    gcpmd.target_period_number = fcpb_target_num.number_assign_value
    AND    fcpb_source_num.attribute_id = g_cp_num_attr_id
    AND    fcpb_source_num.version_id = g_cp_num_v_id
    AND    fcpb_source_year.attribute_id = g_cp_year_attr_id
    AND    fcpb_source_year.version_id = g_cp_year_v_id
    AND    fcpb_source.cal_period_id = fcpb_source_num.cal_period_id
    AND    fcpb_source.cal_period_id = fcpb_source_year.cal_period_id
    AND    fcpb_source.calendar_id = gcpm.source_calendar_id
    AND    fcpb_source.dimension_group_id = gcpm.source_dimension_group_id
    AND    fcpb_source_num.number_assign_value = gcpmd.source_period_number
    AND    fcpb_source_year.number_assign_value =
           DECODE(gcpmd.target_relative_year_code,
                  'CURRENT',   fcpb_target_year.number_assign_value,
                  'PRIOR',     fcpb_target_year.number_assign_value + 1,
                  'FOLLOWING', fcpb_target_year.number_assign_value - 1)
    AND    fcpb_source.cal_period_id IN
           (SELECT gdsd.cal_period_id
            FROM   gcs_data_sub_dtls gdsd
            WHERE  gdsd.entity_id = p_entity_id)
    ORDER BY fcpb_source_year.number_assign_value desc,
             fcpb_source_num.number_assign_value desc;


    l_module     VARCHAR2(30);
  BEGIN
    l_module := 'get_pristine_cal_period_id';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.begin',
                     '<<Enter>>');
    END IF;

    OPEN same_calendar_check_c;
    FETCH same_calendar_check_c INTO dummy;
    IF same_calendar_check_c%FOUND THEN
      CLOSE same_calendar_check_c;

      l_pristine_cal_period_id := to_number(p_fch_cal_period_id_str);
    ELSE
      CLOSE same_calendar_check_c;

      OPEN reverse_map_period_c;
      FETCH reverse_map_period_c INTO l_pristine_cal_period_id;
      CLOSE reverse_map_period_c;

      IF l_pristine_cal_period_id IS NULL THEN
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || l_module || '.end',
                     '<<Exit>>');
    END IF;

    RETURN to_char(l_pristine_cal_period_id);

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.' || l_module || '.error',
                       SQLERRM);
      END IF;
      RAISE;
  END get_pristine_cal_period_id;


  FUNCTION url_encode
    (p_string_to_encode           VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN utl_url.escape(p_string_to_encode, TRUE, null);
  END url_encode;


END GCS_DRILLDOWN_UTIL_PKG;

/

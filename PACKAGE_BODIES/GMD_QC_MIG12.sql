--------------------------------------------------------
--  DDL for Package Body GMD_QC_MIG12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_MIG12" AS
/* $Header: gmdmg12b.pls 120.19 2006/09/27 11:18:31 ragsriva noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmg12b.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIG12                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains migration procedures/functions                  |
 |    for Quality for 12 migration.                                         |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/
/*===========================================================================
--  PROCEDURE
--    log_setup_counts
--
--  DESCRIPTION:
--    This procedure logs the count totals for each setup table.
--    Only tables for which processing has started will be displayed.
--    This routine will be used by both general logging and when others logging.
--
--  PARAMETERS:
--    p_migration_run_id    IN  NUMBER         - Migration id.
--
--    p_progress_ind        IN  NUMBER         - Table sequence that has been
--                                               reached.
--
--=========================================================================== */

PROCEDURE LOG_SETUP_COUNTS
	( p_migration_run_id IN  NUMBER,
	  p_progress_ind     IN  NUMBER) IS

BEGIN

IF (p_progress_ind = 1) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Setup',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_test_methods_b',
       p_param2          => to_char(GMD_QC_MIG12.g_test_method_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_test_method_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_test_method_err_count),
       p_app_short_name  => 'GMD');
END IF;


IF (p_progress_ind = 2) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Setup',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_quality_config',
       p_param2          => to_char(GMD_QC_MIG12.g_quality_config_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_quality_config_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_quality_config_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_quality_config_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 3) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Setup',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_sampling_plans_b',
       p_param2          => to_char(GMD_QC_MIG12.g_sampling_plan_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_sampling_plan_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_sampling_plan_err_count),
       p_app_short_name  => 'GMD');
END IF;

END LOG_SETUP_COUNTS;

/*===========================================================================
--  PROCEDURE
--    log_sample_counts
--
--  DESCRIPTION:
--    This procedure logs the count totals for each sample table.
--    Only tables for which processing has started will be displayed.
--    This routine will be used by both general logging and when others logging.
--
--  PARAMETERS:
--    p_migration_run_id    IN  NUMBER         - Migration id.
--
--    p_progress_ind        IN  NUMBER         - Table sequence that has been
--                                               reached.
--
--=========================================================================== */

PROCEDURE LOG_SAMPLE_COUNTS
	( p_migration_run_id IN  NUMBER,
	  p_progress_ind     IN  NUMBER) IS

BEGIN

IF (p_progress_ind = 1) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Samples',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_samples',
       p_param2          => to_char(GMD_QC_MIG12.g_sample_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_sample_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_sample_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 2) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Samples',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_sampling_events',
       p_param2          => to_char(GMD_QC_MIG12.g_sample_event_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_sample_event_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_sample_event_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 3) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Samples',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_results',
       p_param2          => to_char(GMD_QC_MIG12.g_result_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_result_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_result_err_count),
       p_app_short_name  => 'GMD');
END IF;

END LOG_SAMPLE_COUNTS;

/*===========================================================================
--  PROCEDURE
--    log_spec_counts
--
--  DESCRIPTION:
--    This procedure logs the count totals for each specification table.
--    Only tables for which processing has started will be displayed.
--    This routine will be used by both general logging and when others logging.
--
--  PARAMETERS:
--    p_migration_run_id    IN  NUMBER         - Migration id.
--
--    p_progress_ind        IN  NUMBER         - Table sequence that has been
--                                               reached.
--
--=========================================================================== */

PROCEDURE LOG_SPEC_COUNTS
	( p_migration_run_id IN  NUMBER,
	  p_progress_ind     IN  NUMBER) IS

BEGIN

IF (p_progress_ind = 1) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_specifications_b',
       p_param2          => to_char(GMD_QC_MIG12.g_specs_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_specs_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_specs_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 2) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_inventory_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_inv_spec_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_inv_spec_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_inv_spec_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_inv_spec_err_count),
       p_app_short_name  => 'GMD');
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY2',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'DEL',
       p_param1          => 'gmd_inventory_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_inv_spec_del_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 3) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_wip_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_wip_spec_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_wip_spec_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_wip_spec_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_wip_spec_err_count),
       p_app_short_name  => 'GMD');
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY2',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'DEL',
       p_param1          => 'gmd_wip_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_wip_spec_del_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 4) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_customer_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_cust_spec_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_cust_spec_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_cust_spec_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_cust_spec_err_count),
       p_app_short_name  => 'GMD');
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY2',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'DEL',
       p_param1          => 'gmd_customer_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_cust_spec_del_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 5) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_supplier_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_supl_spec_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_supl_spec_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_supl_spec_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_supl_spec_err_count),
       p_app_short_name  => 'GMD');
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY2',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'DEL',
       p_param1          => 'gmd_supplier_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_supl_spec_del_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 6) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_monitoring_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_mon_spec_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_mon_spec_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_mon_spec_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_mon_spec_err_count),
       p_app_short_name  => 'GMD');
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_SPEC_TABLE_SUMMARY2',
       p_context         => 'Quality Specifications',
       p_token1          => 'TAB',
       p_token2          => 'DEL',
       p_param1          => 'gmd_monitoring_spec_vrs',
       p_param2          => to_char(GMD_QC_MIG12.g_mon_spec_del_count),
       p_app_short_name  => 'GMD');
END IF;

END LOG_SPEC_COUNTS;

/*===========================================================================
--  PROCEDURE
--    log_ss_counts
--
--  DESCRIPTION:
--    This procedure logs the count totals for each Stability Study table.
--    Only tables for which processing has started will be displayed.
--    This routine will be used by both general logging and when others logging.
--
--  PARAMETERS:
--    p_migration_run_id    IN  NUMBER         - Migration id.
--
--    p_progress_ind        IN  NUMBER         - Table sequence that has been
--                                               reached.
--
--=========================================================================== */

PROCEDURE LOG_SS_COUNTS
	( p_migration_run_id IN  NUMBER,
	  p_progress_ind     IN  NUMBER) IS


BEGIN

IF (p_progress_ind = 1) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_storage_plan_details',
       p_param2          => to_char(GMD_QC_MIG12.g_store_plan_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_store_plan_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_store_plan_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 2) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_ss_stability_studies_b',
       p_param2          => to_char(GMD_QC_MIG12.g_stab_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_stab_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_stab_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 3) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_ss_material_sources',
       p_param2          => to_char(GMD_QC_MIG12.g_matl_source_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_matl_source_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_matl_source_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 4) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_ss_variants',
       p_param2          => to_char(GMD_QC_MIG12.g_ss_variant_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_ss_variant_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_ss_variant_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 5) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_ss_storage_package',
       p_param2          => to_char(GMD_QC_MIG12.g_store_pack_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_store_pack_upd_count),
       p_param4          => to_char(GMD_QC_MIG12.g_store_pack_ins_count),
       p_param5          => to_char(GMD_QC_MIG12.g_store_pack_err_count),
       p_app_short_name  => 'GMD');
END IF;

IF (p_progress_ind = 6) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMD_MIG_TABLE_SUMMARY',
       p_context         => 'Quality Stability Studies',
       p_token1          => 'TAB',
       p_token2          => 'PRO',
       p_token3          => 'UPD',
       p_token4          => 'INS',
       p_token5          => 'ERR',
       p_param1          => 'gmd_ss_storage_history',
       p_param2          => to_char(GMD_QC_MIG12.g_ss_storehist_pro_count),
       p_param3          => to_char(GMD_QC_MIG12.g_ss_storehist_upd_count),
       p_param4          => 0,
       p_param5          => to_char(GMD_QC_MIG12.g_ss_storehist_err_count),
       p_app_short_name  => 'GMD');
END IF;

END LOG_SS_COUNTS;



/*===========================================================================
--  FUNCTION:
--    get_profile_value
--
--  DESCRIPTION:
--    This function returns the System level profile value for a given profile.
--    Null is returned if the profile value is not found.
--
--  PARAMETERS:
--    p_profile_name        IN  VARCHAR2       - Profile Name
--
--    return                OUT VARCHAR2       - Profile Value
--
--
--=========================================================================== */


FUNCTION GET_PROFILE_VALUE
( p_profile_name     IN  VARCHAR2) RETURN VARCHAR2 IS


CURSOR get_profile IS
SELECT profile_option_value
FROM   fnd_profile_options A, fnd_profile_option_values B
WHERE  a.profile_option_id = b.profile_option_id
AND    a.profile_option_name = p_profile_name
AND    level_id = 10001;


l_profile_value     fnd_profile_option_values.profile_option_value%TYPE;

BEGIN

OPEN get_profile;
FETCH get_profile INTO l_profile_value;
IF (get_profile%NOTFOUND) THEN
   l_profile_value := NULL;
END IF;
CLOSE get_profile;

RETURN l_profile_value;

END GET_PROFILE_VALUE;


/*===========================================================================
--  FUNCTION:
--    get_status_id
--
--  DESCRIPTION:
--    This function uses a Status code and returns the status_id associated
--    with it.  Returns null if status id not found.
--
--  PARAMETERS:
--
--    p_lot_status          IN  VARCHAR2       - OPM Lot Status
--
--    return                OUT NUMBER         - Lot Status Id.
--
--=========================================================================== */

FUNCTION GET_STATUS_ID
( p_lot_status       IN  VARCHAR2) RETURN NUMBER IS


CURSOR get_status_id IS
SELECT status_id
FROM   ic_lots_sts
WHERE  lot_status = p_lot_status;

l_status_id     ic_lots_sts.status_id%TYPE;

BEGIN

OPEN get_status_id;
FETCH get_status_id INTO l_status_id;
IF (get_status_id%NOTFOUND) THEN
   l_status_id := NULL;
END IF;
CLOSE get_status_id;

RETURN l_status_id;

END GET_STATUS_ID;


/*===========================================================================
--  FUNCTION:
--    copy_text
--
--  DESCRIPTION:
--    This function clones the text records associated with a given Quality
--    text_code.  The Header, Detail, and Translation records are created.
--    The text_code for the cloned text is returned.
--
--  PARAMETERS:
--
--    p_text_code           IN  NUMBER         - Text Code to be Cloned.
--    p_migration_run_id    IN  NUMBER         - Migration_Id.
--
--    return                OUT NUMBER         - Generated text code for new
--                                               text records.
--
--=========================================================================== */

FUNCTION COPY_TEXT
( p_text_code        IN  NUMBER,
  p_migration_run_id IN  NUMBER) RETURN NUMBER IS


/*==============================
   Cursor for Text Sequence.
  ==============================*/

CURSOR get_next_text IS
select gem5_text_code_s.nextval from dual;

l_text_code          NUMBER;
l_rowid              VARCHAR2(200);

TEXT_SEQ_ERROR       EXCEPTION;

/*==============================
   Cursor for Text Details.
  ==============================*/

CURSOR get_text_dtl IS
SELECT *
FROM   qc_text_tbl
WHERE  text_code = p_text_code;

l_text_rec         qc_text_tbl%ROWTYPE;

BEGIN


OPEN get_next_text;
FETCH get_next_text INTO l_text_code;
IF (get_next_text%NOTFOUND) THEN
   CLOSE get_next_text;
   RAISE TEXT_SEQ_ERROR;
END IF;
CLOSE get_next_text;

/*====================================
     Insert Text Header
  ====================================*/

INSERT INTO qc_text_hdr
(
 TEXT_CODE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN
)
VALUES
(
l_text_code,
0,
SYSDATE,
0,
SYSDATE,
NULL
);


/*====================================
     Insert qc_text_tbl.
  ====================================*/

OPEN get_text_dtl;
FETCH get_text_dtl INTO l_text_rec;
WHILE get_text_dtl%FOUND LOOP
   /*=============================
        Insert a Copy.
     =============================*/
   INSERT INTO qc_text_tbl
      (
       TEXT_CODE,
       LANG_CODE,
       PARAGRAPH_CODE,
       SUB_PARACODE,
       LINE_NO,
       LAST_UPDATED_BY,
       CREATED_BY,
       LAST_UPDATE_DATE,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       TEXT
      )
    VALUES
      (
       l_text_code,
       l_text_rec.lang_code,
       l_text_rec.paragraph_code,
       l_text_rec.sub_paracode,
       l_text_rec.line_no,
       0,
       0,
       SYSDATE,
       SYSDATE,
       NULL,
       l_text_rec.text
      );

   /*=============================
        Insert to TL Table.
     =============================*/

   GMA_QC_TEXT_TBL_PKG.INSERT_ROW (
	       X_ROWID => l_rowid,
	       X_TEXT_CODE => l_text_code,
	       X_LANG_CODE => l_text_rec.lang_code,
	       X_PARAGRAPH_CODE => l_text_rec.paragraph_code,
	       X_SUB_PARACODE => l_text_rec.sub_paracode,
	       X_LINE_NO => l_text_rec.line_no,
               X_TEXT => l_text_rec.text,
	       X_LAST_UPDATED_BY => 0,
	       X_CREATED_BY => 0,
	       X_LAST_UPDATE_DATE => SYSDATE,
	       X_CREATION_DATE => SYSDATE,
	       X_LAST_UPDATE_LOGIN => NULL);

   FETCH get_text_dtl INTO l_text_rec;

END LOOP;
CLOSE get_text_dtl;


RETURN l_text_code;

EXCEPTION

  WHEN TEXT_SEQ_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_TEXT_SEQ_ERROR',
	       p_table_name      => NULL,
               p_context         => 'Quality Text',
	       p_app_short_name  => 'GMD');


END COPY_TEXT;

/*===========================================================================
--  PROCEDURE
--    get_whse_info
--
--  DESCRIPTION:
--    This procedure accepts a warehouse code and returns the organization_id
--    that it is assigned to.  It also returns whether the whse is mapped as
--    a subinventory or not.
--    Returns null if whse_code not found.
--
--  PARAMETERS:
--
--    p_whse_code           IN  VARCHAR2       - Whse Code
--    x_organization_id     OUT NUMBER         - Organization_id
--    x_subinv_ind          OUT VARCHAR2       - Subinventory Indicator
--    x_loct_ctl            OUT NUMBER         - Location Control Indicator
--
--=========================================================================== */

PROCEDURE GET_WHSE_INFO
	( p_whse_code        IN  VARCHAR2
	, x_organization_id  OUT NOCOPY NUMBER
	, x_subinv_ind       OUT NOCOPY VARCHAR2
	, x_loct_ctl         OUT NOCOPY NUMBER) IS

CURSOR get_whse_data IS
SELECT organization_id, subinventory_ind_flag, loct_ctl
FROM   ic_whse_mst
WHERE  whse_code = p_whse_code;

BEGIN

OPEN get_whse_data;
FETCH get_whse_data INTO x_organization_id, x_subinv_ind,
                            x_loct_ctl;
CLOSE get_whse_data;

END GET_WHSE_INFO;


/*===========================================================================
--  FUNCTION:
--    get_locator_id
--
--  DESCRIPTION:
--    This function uses Whse Code and Location to retrieve locator_id.
--
--  PARAMETERS:
--
--    p_whse_code           IN  VARCHAR2       - Warehouse Code
--    p_location            IN  VARCHAR2       - Location
--
--    p_locator_id          OUT NUMBER         - Locator Id
--
--=========================================================================== */

FUNCTION GET_LOCATOR_ID
( p_whse_code        IN  VARCHAR2,
  p_location         IN  VARCHAR2) RETURN NUMBER IS

CURSOR get_locator_id IS
SELECT locator_id
FROM   ic_loct_mst
WHERE  whse_code = p_whse_code
AND    location = p_location;

l_locator_id         ic_loct_mst.inventory_location_id%TYPE;

BEGIN

OPEN get_locator_id;
FETCH get_locator_id INTO l_locator_id;
CLOSE get_locator_id;

RETURN l_locator_id;

END GET_LOCATOR_ID;



/*===========================================================================
--  PROCEDURE
--    get_subinv_data
--
--  DESCRIPTION:
--    This procedure gets the subinventory data associated with a locator.
--
--  PARAMETERS:
--
--    p_locator_id          IN  NUMBER         - Locator Id.
--
--    x_subinv              OUT VARCHAR2       - Subinventory
--
--    x_sub_org_id          OUT NUMBER         - Organization Id associated with
--                                               subinventory.
--
--=========================================================================== */

PROCEDURE GET_SUBINV_DATA
	( p_locator_id       IN  NUMBER
	, x_subinv           OUT NOCOPY VARCHAR2
	, x_sub_org_id       OUT NOCOPY NUMBER)

IS

CURSOR get_subinv IS
SELECT subinventory_code, organization_id
FROM   mtl_item_locations
WHERE  inventory_location_id = p_locator_id;


BEGIN
OPEN get_subinv;
FETCH get_subinv INTO x_subinv, x_sub_org_id;
CLOSE get_subinv;

END GET_SUBINV_DATA;


-- Bug# 5569346
PROCEDURE CREATE_CONFIG_ROWS_FOR_WHSE(p_migration_run_id IN  NUMBER, p_commit IN VARCHAR2) IS
   CURSOR cur_whse_info IS
      SELECT icw.whse_code, icw.orgn_code, icw.organization_id
        FROM ic_whse_mst icw
       WHERE (   icw.subinventory_ind_flag <> 'Y'
              OR icw.subinventory_ind_flag IS NULL)
         AND NOT EXISTS (SELECT organization_id
                           FROM gmd_quality_config
                          WHERE organization_id = icw.organization_id)
         AND icw.organization_id IS NOT NULL;

   CURSOR cur_orgn_config (p_orgn_code   gmd_quality_config.orgn_code%TYPE) IS
      SELECT qc.*
        FROM gmd_quality_config qc, sy_orgn_mst m
       WHERE m.orgn_code = p_orgn_code
         AND m.organization_id = qc.organization_id;

   l_config_rec   cur_orgn_config%ROWTYPE;
BEGIN
   FOR get_whse_info IN cur_whse_info LOOP

      OPEN cur_orgn_config (get_whse_info.orgn_code);
      FETCH cur_orgn_config INTO l_config_rec;
      IF cur_orgn_config%FOUND THEN
          INSERT INTO gmd_quality_config(
               ORGN_CODE,
               CONTROL_BATCH_STEP_IND,
               CONTROL_LOT_ATTRIB_IND,
               OUT_OF_SPEC_LOT_STATUS,
               IN_SPEC_LOT_STATUS,
               SAMPLE_INV_TRANS_IND,
               API_ROUND_TRUN_IND,
               LOT_OPTIONAL_ON_SAMPLE,
               TEXT_CODE,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               INV_TRANS_REASON_CODE,
               RESAMPLE_ACTION_CODE,
               RETEST_ACTION_CODE,
               CHOOSE_SPEC,
               AUTO_SAMPLE_IND,
               DELAYED_LOT_ENTRY,
               ORGANIZATION_ID,
               OUT_OF_SPEC_LOT_STATUS_ID,
               IN_SPEC_LOT_STATUS_ID,
               TRANSACTION_REASON_ID,
               QUALITY_LAB_IND,
               EXACT_SPEC_MATCH_IND,
               INCLUDE_OPTIONAL_TEST_RSLT_IND,
               SPEC_VERSION_CONTROL_IND,
               SAMPLE_LAST_ASSIGNED,
               SAMPLE_ASSIGNMENT_TYPE,
               SS_ASSIGNMENT_TYPE,
               SS_LAST_ASSIGNED,
               MIGRATED_IND
          )
          VALUES (
               NULL,
               l_config_rec.CONTROL_BATCH_STEP_IND,
               l_config_rec.CONTROL_LOT_ATTRIB_IND,
               l_config_rec.OUT_OF_SPEC_LOT_STATUS,
               l_config_rec.IN_SPEC_LOT_STATUS,
               l_config_rec.SAMPLE_INV_TRANS_IND,
               l_config_rec.API_ROUND_TRUN_IND,
               l_config_rec.LOT_OPTIONAL_ON_SAMPLE,
               NULL,
               SYSDATE,
               0,
               0,
               SYSDATE,
               NULL,
               l_config_rec.INV_TRANS_REASON_CODE,
               l_config_rec.RESAMPLE_ACTION_CODE,
               l_config_rec.RETEST_ACTION_CODE,
               l_config_rec.CHOOSE_SPEC,
               l_config_rec.AUTO_SAMPLE_IND,
               l_config_rec.DELAYED_LOT_ENTRY,
               get_whse_info.organization_id,
               l_config_rec.OUT_OF_SPEC_LOT_STATUS_ID,
               l_config_rec.IN_SPEC_LOT_STATUS_ID,
               l_config_rec.TRANSACTION_REASON_ID,
               l_config_rec.QUALITY_LAB_IND,
               l_config_rec.EXACT_SPEC_MATCH_IND,
               l_config_rec.INCLUDE_OPTIONAL_TEST_RSLT_IND,
               l_config_rec.SPEC_VERSION_CONTROL_IND,
               l_config_rec.SAMPLE_LAST_ASSIGNED,
               l_config_rec.SAMPLE_ASSIGNMENT_TYPE,
               l_config_rec.SS_ASSIGNMENT_TYPE,
               l_config_rec.SS_LAST_ASSIGNED,
               1
          );

          GMD_QC_MIG12.g_quality_config_ins_count := GMD_QC_MIG12.g_quality_config_ins_count + 1;

          IF (p_commit = FND_API.G_TRUE) THEN
              COMMIT;
          END IF;

      END IF;

      CLOSE cur_orgn_config;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
               p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - quality config ins',
               p_db_error        => SQLERRM,
               p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;

END CREATE_CONFIG_ROWS_FOR_WHSE;




/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_setup
--
--  DESCRIPTION:
--    This procedure migrates the Quality Setup data.
--
--  UPDATES:
--    11/18/2006
--    1) Changed context on error messages to be more specific.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--    p_commit              IN  VARCHAR2       - Commit Flag
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--  The following columns will be migrated by the Common migration script.
--
--  gmd_test_methods_b    - test_qty_uom
--  gmd_quality_config    - organization_id
--  gmd_sampling_plans    - sample_qty_uom
--  gmd_uom_conversions   - from_qty_uom
--  gmd_uom_conversions   - from_qty_uom_base
--  gmd_uom_conversions   - to_qty_uom
--  gmd_uom_conversions   - to_qty_uom_base
--=========================================================================== */


PROCEDURE GMD_QC_MIGRATE_SETUP
	( p_migration_run_id IN  NUMBER
        , p_commit           IN  VARCHAR2
        , x_exception_count  OUT NOCOPY NUMBER)

IS

/*=============================
   Profile Value Placeholders
  =============================*/

l_lab_profile       fnd_profile_option_values.profile_option_value%TYPE;
P_exact_match       fnd_profile_option_values.profile_option_value%TYPE;
P_inc_opt           fnd_profile_option_values.profile_option_value%TYPE;
P_version_control   fnd_profile_option_values.profile_option_value%TYPE;

/*=============================
       Exceptions
  =============================*/

DEFAULT_LAB_NULL          EXCEPTION;
NULL_DEF_ORGANIZATION_ID  EXCEPTION;
METHOD_ITEM_ERROR         EXCEPTION;

MIG_NO_ORG                EXCEPTION;
REASON_CODE_ERROR         EXCEPTION;
IN_SPEC_ERROR             EXCEPTION;
OUT_SPEC_ERROR            EXCEPTION;
SMPL_DOC_ERROR            EXCEPTION;
STBL_DOC_ERROR            EXCEPTION;
GET_LAB_ERROR             EXCEPTION;
NO_NULL_RECORD            EXCEPTION;
CONFIG_INCOMPLETE         EXCEPTION;
CONFIG_FINAL_INCOMPLETE   EXCEPTION;
GET_ORGN_CODE_ERROR       EXCEPTION;
MIG_NO_UOM                EXCEPTION;
NEXT_TEST_METHOD          EXCEPTION;
NEXT_CONFIG_INSERT        EXCEPTION;


/*=========================
    Test Methods Cursor
  =========================*/
-- 09/25/2005 added retrieve of existing inventory item id.

CURSOR get_test_methods IS
SELECT test_method_id, test_kit_item_id, test_kit_inv_item_id,
       test_kit_organization_id
FROM   gmd_test_methods_b
WHERE  migrated_ind IS NULL;


/*=========================
   Quality Config Cursor
  =========================*/

CURSOR get_quality_config IS
SELECT *
FROM   gmd_quality_config
WHERE  orgn_code IS NOT NULL
AND    migrated_ind IS NULL;


/*===========================
   Quality Config Null Cursor
  ===========================*/

CURSOR get_null_quality_config IS
SELECT *
FROM   gmd_quality_config
WHERE  orgn_code IS NULL
AND    migrated_ind IS NULL
AND    organization_id IS NULL;

l_config_rec       gmd_quality_config%ROWTYPE;


/*================================
   Quality Config Migrated Check
  ================================*/

CURSOR check_config_mig IS
SELECT count(1)
FROM   gmd_quality_config
WHERE  (orgn_code IS NOT NULL AND migrated_ind IS NULL);

l_config_mig_count      NUMBER;

/*=========================
   Item Create parameters.
  =========================*/

l_inventory_item_id   mtl_system_items.inventory_item_id%TYPE;
l_failure_count       NUMBER;

/*=========================
   Table of process orgs.
  =========================*/

TYPE T_orgtable IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

v_orgs   T_orgtable;

/*======================================
   Cursor to get process orgs.
  Changed from mtl_parms to sy_orgn_mst
  ======================================*/

CURSOR get_process_org IS
SELECT m.organization_id
FROM   sy_orgn_mst_b m
WHERE NOT EXISTS
(SELECT organization_id FROM gmd_quality_config WHERE organization_id = m.organization_id)
AND m.organization_id IS NOT NULL;


v_org                   sy_orgn_mst.organization_id%TYPE;
l_org_count             NUMBER;


/*=================================
    General Placeholders.
  =================================*/

l_in_spec_status_id       ic_lots_sts.status_id%TYPE;
l_out_spec_status_id      ic_lots_sts.status_id%TYPE;

l_reason_id              NUMBER;
l_text_code              NUMBER;

/*=================================
   Cursor to get doc_seq and type
  =================================*/

CURSOR get_doc_info(v_orgn_code sy_docs_seq.orgn_code%TYPE, v_doc_type sy_docs_seq.doc_type%TYPE)  IS
SELECT assignment_type, last_assigned
FROM   sy_docs_seq
WHERE  doc_type = v_doc_type
AND    orgn_code = v_orgn_code;

l_smpl_assignment_type      sy_docs_seq.assignment_type%TYPE;
l_smpl_last_assigned        sy_docs_seq.last_assigned%TYPE;
l_stbl_assignment_type      sy_docs_seq.assignment_type%TYPE;
l_stbl_last_assigned        sy_docs_seq.last_assigned%TYPE;

/*==================================
   Cursor to get Lab indicator.
  ==================================*/

CURSOR get_lab_info(p_orgn_code sy_orgn_mst.orgn_code%TYPE)  IS
SELECT plant_ind
FROM   sy_orgn_mst
WHERE  orgn_code = p_orgn_code;

d_lab_ind               sy_orgn_mst.plant_ind%TYPE;
l_lab_ind               gmd_quality_config.quality_lab_ind%TYPE;
l_organization_id       sy_orgn_mst.organization_id%TYPE;
l_test_org              sy_orgn_mst.organization_id%TYPE;


/*=======================================
   Cursor to get orgn_code.
  =======================================*/

-- Bug# 5438990
-- changed column organization_code to orgn_code in the select statement
CURSOR get_orgn_code(v_organization_id sy_orgn_mst.organization_id%TYPE) IS
SELECT orgn_code
FROM   sy_orgn_mst
WHERE  organization_id = v_organization_id;

-- Bug# 5438990
--l_orgn_code      mtl_parameters.organization_code%TYPE;
l_orgn_code      sy_orgn_mst.orgn_code%TYPE;

/*=======================================
   Placeholders for Log Messages.
  =======================================*/

l_valfield       VARCHAR2(80);
l_value          VARCHAR2(80);
l_org_error      sy_orgn_mst.organization_id%TYPE;


/*=======================================
   Cursor to get config records.
  =======================================*/

CURSOR get_config IS
SELECT *
FROM   gmd_quality_config
WHERE  migrated_ind = 1;


/*=======================================
   Cursor to get whse orgn_code.
  =======================================*/

CURSOR get_whse_orgn (p_organization_id   ic_whse_mst.organization_id%TYPE) IS
SELECT orgn_code
FROM   ic_whse_mst
WHERE  subinventory_ind_flag = 'Y'
AND    mtl_organization_id = p_organization_id;

l_orig_orgn_code                ic_whse_mst.orgn_code%TYPE;

/*=======================================
   Cursor to get config record.
  =======================================*/

CURSOR get_parent_config (p_orgn_code   gmd_quality_config.orgn_code%TYPE) IS
SELECT sample_assignment_type, sample_last_assigned
FROM   gmd_quality_config
WHERE  orgn_code = p_orgn_code;

l_p_assign_type      gmd_quality_config.sample_assignment_type%TYPE;
l_p_last_assign      gmd_quality_config.sample_last_assigned%TYPE;

/*=======================================
   Cursor to get gmd_sampling_plans_b
  =======================================*/

CURSOR get_sampling_plan IS
SELECT sampling_plan_id, frequency_type, frequency_per
FROM   gmd_sampling_plans_b
WHERE  migrated_ind IS NULL;

l_sample_plan         get_sampling_plan%ROWTYPE;
l_sampling_uom        gmd_sampling_plans_b.frequency_per%TYPE;

/*=======================================
   Cursor to check if gmd_quality_config
   record exists.
  =======================================*/

CURSOR check_for_config(p_org_id NUMBER) IS
SELECT organization_id
FROM   gmd_quality_config
WHERE  organization_id = p_org_id;

l_config_org          NUMBER;

BEGIN

GMD_QC_MIG12.g_progress_ind := 0;

x_exception_count := 0;

/*==============================================
   Get Default Lab Type Profile Value
  ==============================================*/

l_lab_profile :=  GMD_QC_MIG12.GET_PROFILE_VALUE('GEMMS_DEFAULT_LAB_TYPE');

IF (l_lab_profile IS NULL) THEN
    RAISE DEFAULT_LAB_NULL;
END IF;

/*================================================
   Log Lab Type Profile Value
  ================================================*/

l_valfield := 'GEMMS_DEFAULT_LAB_TYPE';
l_value    := NVL(l_lab_profile,' ');

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMD_MIG_VALUE',
       p_context         => 'Quality Setup',
       p_token1          => 'VALFIELD',
       p_token2          => 'VALUE',
       p_param1          => l_valfield,
       p_param2          => l_value,
       p_app_short_name  => 'GMD');
END IF;

/*====================================
     Get Organization id for Lab.
  ====================================*/


l_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_lab_profile);


IF (l_organization_id IS NULL) THEN
    RAISE NULL_DEF_ORGANIZATION_ID;
END IF;


/*==============================================
   Log Start of gmd_test_method migration.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_QUALITY_CONFIG',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_TEST_METHODS_B',
       p_context         => 'Quality Setup',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 1;

/*================================================
   Loop through all test methods and assign
   inventory_item_id.
  ================================================*/

GMD_QC_MIG12.g_test_method_upd_count := 0;
GMD_QC_MIG12.g_test_method_pro_count := 0;
GMD_QC_MIG12.g_test_method_err_count := 0;


FOR v_test_method IN get_test_methods LOOP

  BEGIN   -- subprogram

    GMD_QC_MIG12.g_test_method_pro_count := GMD_QC_MIG12.g_test_method_pro_count + 1;

    IF (v_test_method.test_kit_item_id IS NOT NULL) THEN

       INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
              P_MIGRATION_RUN_ID => p_migration_run_id,
              P_ITEM_ID => v_test_method.test_kit_item_id,
              P_ORGANIZATION_ID  => l_organization_id,
              P_MODE => NULL,
              P_COMMIT => FND_API.G_TRUE,
              X_INVENTORY_ITEM_ID => l_inventory_item_id,
              X_FAILURE_COUNT => l_failure_count);

       IF (l_failure_count > 0) THEN
         RAISE METHOD_ITEM_ERROR;
       END IF;
       l_test_org := l_organization_id;
    ELSE   -- opm item is null
       /*====================================================
          If item is null then org should be null as well.
          If inventory_item exists leave it alone.
         ====================================================*/
       IF (v_test_method.test_kit_inv_item_id IS NOT NULL) THEN
          RAISE NEXT_TEST_METHOD;
       ELSE
          l_test_org := NULL;
          l_inventory_item_id := NULL;
       END IF;
    END IF;

    UPDATE gmd_test_methods_b
       SET test_kit_inv_item_id = l_inventory_item_id,
            test_kit_organization_id = l_test_org,
            migrated_ind = 1
       WHERE test_method_id = v_test_method.test_method_id;

    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

    GMD_QC_MIG12.g_test_method_upd_count := GMD_QC_MIG12.g_test_method_upd_count + 1;

  EXCEPTION

  WHEN METHOD_ITEM_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
            p_run_id          => p_migration_run_id,
            p_log_level       => FND_LOG.LEVEL_ERROR,
	    p_message_token   => 'GMD_MIG_INVALID_ITEM',
            p_context         => 'Quality Setup - gmd_test_methods_b',
	    p_token1          => 'ORG',
	    p_token2          => 'ITEMID',
	    p_token3          => 'ROWK',
	    p_token4          => 'ROWV',
	    p_param1          => to_char(l_organization_id),
	    p_param2          => to_char(v_test_method.test_kit_item_id),
	    p_param3          => 'TEST_METHOD_ID',
	    p_param4          => to_char(v_test_method.test_method_id),
	    p_app_short_name  => 'GMD');
       GMD_QC_MIG12.g_test_method_err_count := GMD_QC_MIG12.g_test_method_err_count + 1;
       x_exception_count := x_exception_count + 1;

   WHEN NEXT_TEST_METHOD THEN
       NULL;

   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - gmd_test_methods_b',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_test_method_err_count := GMD_QC_MIG12.g_test_method_err_count + 1;
       x_exception_count := x_exception_count + 1;

  END;    -- subprogram

END LOOP;


/*==============================================
   Log end of gmd_test_method migration.
  ==============================================*/

LOG_SETUP_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*=========================================
   Migrate gmd_quality_config.
   First get profile values.
  =========================================*/

P_exact_match :=  GMD_QC_MIG12.GET_PROFILE_VALUE('QC$EXACTSPECMATCH');

/*================================================
   Log Exact Match Profile
  ================================================*/

l_valfield := 'QC$EXACTSPECMATCH';
l_value    := NVL(P_exact_match,' ');

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMD_MIG_VALUE',
       p_context         => 'Quality Setup',
       p_token1          => 'VALFIELD',
       p_token2          => 'VALUE',
       p_param1          => l_valfield,
       p_param2          => l_value,
       p_app_short_name  => 'GMD');
END IF;

IF (P_exact_match = 'N') THEN
    P_exact_match := NULL;
END IF;

P_inc_opt :=  GMD_QC_MIG12.GET_PROFILE_VALUE('GMD_INCLUDE_OPTIONAL_TEST');

/*================================================
   Log Include Optional Test Profile
  ================================================*/

l_valfield := 'GMD_INCLUDE_OPTIONAL_TEST';
l_value    := NVL(P_inc_opt,' ');


IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMD_MIG_VALUE',
       p_context         => 'Quality Setup',
       p_token1          => 'VALFIELD',
       p_token2          => 'VALUE',
       p_param1          => l_valfield,
       p_param2          => l_value,
       p_app_short_name  => 'GMD');
END IF;

IF (P_inc_opt IS NULL) THEN
    P_inc_opt := 'Y';
END IF;
IF (P_inc_opt = 'N') THEN
    P_inc_opt := NULL;
END IF;

P_version_control :=  GMD_QC_MIG12.GET_PROFILE_VALUE('GMD_OPERATION_VERSION_CONTROL');

/*================================================
   Log Operation Version Control Profile
  ================================================*/

l_valfield := 'GMD_OPERATION_VERSION_CONTROL';
l_value    := NVL(P_version_control,' ');

IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
   GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMD_MIG_VALUE',
       p_context         => 'Quality Setup',
       p_token1          => 'VALFIELD',
       p_token2          => 'VALUE',
       p_param1          => l_valfield,
       p_param2          => l_value,
       p_app_short_name  => 'GMD');
END IF;

IF (P_version_control = 'N') THEN
    P_version_control := NULL;
END IF;

/*==============================================
   Log Start of Quality Config Migration.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_QUALITY_CONFIG',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_QUALITY_CONFIG',
       p_context         => 'Quality Setup',
       p_app_short_name  => 'GMA');

/*==============================================
   Loop through gmd_quality_config. Handle
   records with org differently than the record
   where org is null.  First pass gets
   non_null records.
  ==============================================*/

GMD_QC_MIG12.g_quality_config_upd_count :=0;
GMD_QC_MIG12.g_quality_config_ins_count :=0;
GMD_QC_MIG12.g_quality_config_pro_count :=0;
GMD_QC_MIG12.g_quality_config_err_count :=0;
GMD_QC_MIG12.g_progress_ind := 2;


FOR v_qual_config IN get_quality_config LOOP

   BEGIN   -- start of subprogram


   GMD_QC_MIG12.g_quality_config_pro_count := GMD_QC_MIG12.g_quality_config_pro_count + 1;

   /*=====================================
       Check if organization migrated.
     ======================================*/

    IF (v_qual_config.organization_id IS NULL and v_qual_config.orgn_code IS NOT NULL) THEN
       RAISE MIG_NO_ORG;
    END IF;

   l_organization_id :=  v_qual_config.organization_id;

   /*=====================================
        Get Reason Id.
     =====================================*/

   IF (v_qual_config.inv_trans_reason_code IS NULL) THEN
      l_reason_id := NULL;
   ELSE
      l_reason_id :=  GMA_MIGRATION_UTILS.GET_REASON_ID(v_qual_config.inv_trans_reason_code);
      IF (l_reason_id IS NULL) THEN
         RAISE REASON_CODE_ERROR;
      END IF;
   END IF;

   /*=====================================
        Get Status Ids.
     =====================================*/

   IF (v_qual_config.in_spec_lot_status IS NULL) THEN
      l_in_spec_status_id := NULL;
   ELSE
      l_in_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(v_qual_config.in_spec_lot_status);
      IF (l_in_spec_status_id IS NULL) THEN
         RAISE IN_SPEC_ERROR;
      END IF;
   END IF;

   IF (v_qual_config.out_of_spec_lot_status IS NULL) THEN
      l_out_spec_status_id := NULL;
   ELSE
      l_out_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(v_qual_config.out_of_spec_lot_status);
      IF (l_out_spec_status_id IS NULL) THEN
         RAISE OUT_SPEC_ERROR;
      END IF;
   END IF;

   /*=====================================
        Get document sequence info.
     =====================================*/
   OPEN get_doc_info(v_qual_config.orgn_code,'SMPL');
   FETCH  get_doc_info INTO l_smpl_assignment_type, l_smpl_last_assigned;
   IF (get_doc_info%NOTFOUND) THEN
      l_smpl_assignment_type := 2;
      l_smpl_last_assigned := 1;
   END IF;
   CLOSE  get_doc_info;

   OPEN get_doc_info(v_qual_config.orgn_code,'STBL');
   FETCH  get_doc_info INTO l_stbl_assignment_type, l_stbl_last_assigned;
   IF (get_doc_info%NOTFOUND) THEN
      l_stbl_assignment_type := 2;
      l_stbl_last_assigned := 1;
   END IF;
   CLOSE  get_doc_info;

   /*=====================================
       Get Lab information.
     =====================================--*/

   OPEN get_lab_info(v_qual_config.orgn_code);
   FETCH get_lab_info INTO d_lab_ind;
   IF (get_lab_info%NOTFOUND) THEN
      CLOSE get_lab_info;
      RAISE GET_LAB_ERROR;
   END IF;
   CLOSE get_lab_info;


   IF (d_lab_ind = 2) THEN
      l_lab_ind := 'Y';
   ELSE
      l_lab_ind := NULL;
   END IF;

   /*=====================================
       Update the Row.
     =====================================*/

   UPDATE gmd_quality_config
   SET organization_id = l_organization_id,
       quality_lab_ind = l_lab_ind,
       transaction_reason_id = l_reason_id,
       in_spec_lot_status_id = l_in_spec_status_id,
       out_of_spec_lot_status_id =  l_out_spec_status_id,
       exact_spec_match_ind = P_exact_match,
       include_optional_test_rslt_ind = P_inc_opt,
       spec_version_control_ind = P_version_control,
       sample_assignment_type = l_smpl_assignment_type,
       sample_last_assigned = l_smpl_last_assigned,
       ss_assignment_type = l_stbl_assignment_type,
       ss_last_assigned = l_stbl_last_assigned,
       migrated_ind = 1
   WHERE orgn_code = v_qual_config.orgn_code;

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;

   GMD_QC_MIG12.g_quality_config_upd_count := GMD_QC_MIG12.g_quality_config_upd_count + 1;

   EXCEPTION

   WHEN MIG_NO_ORG THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_NO_ORG',
               p_context         => 'Quality Setup - quality config update',
               p_token1          => 'ORG',
               p_token2          => 'ONAME',
               p_token3          => 'ROWK',
               p_token4          => 'ROWV',
               p_param1          => v_qual_config.orgn_code,
               p_param2          => 'ORGN_CODE',
               p_param3          => 'ORGN_CODE',
	       p_param4          => v_qual_config.orgn_code,
               p_app_short_name  => 'GMD');

       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;


   WHEN REASON_CODE_ERROR THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_REASON_ID',
               p_context         => 'Quality Setup - quality config update',
	       p_token1          => 'REASON',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => v_qual_config.inv_trans_reason_code,
	       p_param2          => 'orgn_code',
	       p_param3          => v_qual_config.orgn_code,
	       p_app_short_name  => 'GMD');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;

   WHEN IN_SPEC_ERROR THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_STATUS_ID',
               p_context         => 'Quality Setup - quality config update',
	       p_token1          => 'STAT',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => v_qual_config.in_spec_lot_status,
	       p_param2          => 'orgn_code',
	       p_param3          => v_qual_config.orgn_code,
	       p_app_short_name  => 'GMD');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;

   WHEN OUT_SPEC_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_STATUS_ID',
               p_context         => 'Quality Setup - quality config update',
	       p_token1          => 'STAT',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => v_qual_config.out_of_spec_lot_status,
	       p_param2          => 'orgn_code',
	       p_param3          => v_qual_config.orgn_code,
	       p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN GET_LAB_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_GET_LAB',
               p_context         => 'Quality Setup - quality config update',
	       p_token1          => 'ORG',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => v_qual_config.orgn_code,
	       p_param2          => 'orgn_code',
	       p_param3          => v_qual_config.orgn_code,
	       p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - quality config update',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;

   END;    -- end of subprogram


END LOOP;


/*=========================================
   Loop through gmd_quality_config. Handle
   record with null org. It will be
   unchanged but marked as migrated.
  =========================================*/


BEGIN  -- null subprogram

OPEN get_null_quality_config;
FETCH get_null_quality_config INTO l_config_rec;
IF (get_null_quality_config%NOTFOUND) THEN
   CLOSE get_null_quality_config;
   RAISE NO_NULL_RECORD;
ELSE
   /*====================================
      Do not process the null record
      if existing gmd_quality_config row
      were not successfully migrated.
     ====================================*/
   GMD_QC_MIG12.g_quality_config_pro_count := GMD_QC_MIG12.g_quality_config_pro_count + 1;
END IF;

CLOSE get_null_quality_config;

/*===========================================
   Get all process orgs that do not
   already have a row in gmd_quality_config.
  ===========================================*/

l_org_count := 0;

OPEN get_process_org;
LOOP
   FETCH get_process_org INTO v_org;
   IF (get_process_org%NOTFOUND) THEN
      EXIT;
   ELSE
      l_org_count := l_org_count + 1;
      v_orgs(l_org_count) := v_org;
   END IF;
END LOOP;
CLOSE get_process_org;

l_org_count := 1;

/*========================================
   Populate the common fields if needed.
  ========================================*/

IF (v_orgs.EXISTS(l_org_count)) THEN

  /*=====================================
       Get Reason Id.
    =====================================*/

  IF (l_config_rec.inv_trans_reason_code IS NULL) THEN
     l_reason_id := NULL;
  ELSE
     l_reason_id :=  GMA_MIGRATION_UTILS.GET_REASON_ID(l_config_rec.inv_trans_reason_code);
     IF (l_reason_id IS NULL) THEN
         RAISE REASON_CODE_ERROR;
     END IF;
  END IF;

  /*=====================================
       Get Status Ids.
    =====================================*/

  IF (l_config_rec.in_spec_lot_status IS NULL) THEN
     l_in_spec_status_id := NULL;
  ELSE
     l_in_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_config_rec.in_spec_lot_status);
     IF (l_in_spec_status_id IS NULL) THEN
         RAISE IN_SPEC_ERROR;
     END IF;
  END IF;

  IF (l_config_rec.out_of_spec_lot_status IS NULL) THEN
     l_out_spec_status_id := NULL;
  ELSE
     l_out_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_config_rec.out_of_spec_lot_status);
     IF (l_out_spec_status_id IS NULL) THEN
        RAISE OUT_SPEC_ERROR;
     END IF;
  END IF;

END IF;


/*====================================
   Create a row for each process org.
  ====================================*/

LOOP
  BEGIN
  IF (v_orgs.EXISTS(l_org_count)) THEN
      /*======================================
          Verify that record don't exist.
        ======================================*/
      OPEN check_for_config(v_orgs(l_org_count));
      FETCH check_for_config INTO l_config_org;
      IF (check_for_config%FOUND) THEN
         CLOSE check_for_config;
         RAISE NEXT_CONFIG_INSERT;
      END IF;
      CLOSE check_for_config;

      /*======================================
          Get the organization_code.
        ======================================*/
      OPEN get_orgn_code(v_orgs(l_org_count));
      FETCH get_orgn_code INTO l_orgn_code;
      IF (get_orgn_code%NOTFOUND) THEN
         CLOSE get_orgn_code;
         RAISE GET_ORGN_CODE_ERROR;
      ELSE
         l_organization_id := v_orgs(l_org_count);
      END IF;
      CLOSE get_orgn_code;

      /*=================================
         Create Text Code if it exists.
        =================================*/
      IF (l_config_rec.text_code IS NOT NULL AND l_config_rec.text_code > 0) THEN
          l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_config_rec.text_code, p_migration_run_id);
      ELSE
          l_text_code := NULL;
      END IF;

      /*=====================================
          Get Lab information.
        =====================================*/

      IF (l_orgn_code IS NOT NULL) THEN
         OPEN get_lab_info(l_orgn_code);
         FETCH get_lab_info INTO d_lab_ind;
         IF (get_lab_info%NOTFOUND) THEN
            CLOSE get_lab_info;
            RAISE GET_LAB_ERROR;
         END IF;
         CLOSE get_lab_info;

         IF (d_lab_ind = 2) THEN
            l_lab_ind := 'Y';
         ELSE
            l_lab_ind := NULL;
         END IF;
      ELSE
         l_lab_ind := NULL;
      END IF;

      /*=====================================
           Get document sequence info.
        =====================================*/
      -- Bug# 5569346
      -- changed l_config_rec.orgn_code to l_orgn_code in the if condition and in the open cursor statement since l_config_rec.orgn_code is always null
      IF (l_orgn_code IS NOT NULL) THEN
         OPEN get_doc_info(l_orgn_code,'SMPL');
         FETCH  get_doc_info INTO l_smpl_assignment_type, l_smpl_last_assigned;
         IF (get_doc_info%NOTFOUND) THEN
            l_smpl_assignment_type := 2;
            l_smpl_last_assigned := 1;
         END IF;
         CLOSE  get_doc_info;

         OPEN get_doc_info(l_orgn_code,'STBL');
         FETCH  get_doc_info INTO l_stbl_assignment_type, l_stbl_last_assigned;
         IF (get_doc_info%NOTFOUND) THEN
            l_stbl_assignment_type := 2;
            l_stbl_last_assigned := 1;
         END IF;
         CLOSE  get_doc_info;
      ELSE
         l_smpl_assignment_type := 2;
         l_smpl_last_assigned := 1;
         l_stbl_assignment_type := 2;
         l_stbl_last_assigned := 1;
      END IF;

      INSERT INTO gmd_quality_config(
          ORGN_CODE,
          CONTROL_BATCH_STEP_IND,
          CONTROL_LOT_ATTRIB_IND,
          OUT_OF_SPEC_LOT_STATUS,
          IN_SPEC_LOT_STATUS,
          SAMPLE_INV_TRANS_IND,
          API_ROUND_TRUN_IND,
          LOT_OPTIONAL_ON_SAMPLE,
          TEXT_CODE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          INV_TRANS_REASON_CODE,
          RESAMPLE_ACTION_CODE,
          RETEST_ACTION_CODE,
          CHOOSE_SPEC,
          AUTO_SAMPLE_IND,
          DELAYED_LOT_ENTRY,
          ORGANIZATION_ID,
          OUT_OF_SPEC_LOT_STATUS_ID,
          IN_SPEC_LOT_STATUS_ID,
          TRANSACTION_REASON_ID,
          QUALITY_LAB_IND,
          EXACT_SPEC_MATCH_IND,
          INCLUDE_OPTIONAL_TEST_RSLT_IND,
          SPEC_VERSION_CONTROL_IND,
          SAMPLE_LAST_ASSIGNED,
          SAMPLE_ASSIGNMENT_TYPE,
          SS_ASSIGNMENT_TYPE,
          SS_LAST_ASSIGNED,
          MIGRATED_IND
          )
          VALUES (
          NULL,
          l_config_rec.CONTROL_BATCH_STEP_IND,
          l_config_rec.CONTROL_LOT_ATTRIB_IND,
          l_config_rec.OUT_OF_SPEC_LOT_STATUS,
          l_config_rec.IN_SPEC_LOT_STATUS,
          l_config_rec.SAMPLE_INV_TRANS_IND,
          l_config_rec.API_ROUND_TRUN_IND,
          l_config_rec.LOT_OPTIONAL_ON_SAMPLE,
          l_text_code,
          SYSDATE,
          0,
          0,
          SYSDATE,
          NULL,
          l_config_rec.INV_TRANS_REASON_CODE,
          l_config_rec.RESAMPLE_ACTION_CODE,
          l_config_rec.RETEST_ACTION_CODE,
          l_config_rec.CHOOSE_SPEC,
          l_config_rec.AUTO_SAMPLE_IND,
          l_config_rec.DELAYED_LOT_ENTRY,
          l_organization_id,
          l_out_spec_status_id,
          l_in_spec_status_id,
          l_reason_id,
          l_lab_ind,
          P_exact_match,
          P_inc_opt,
          P_version_control,
          l_smpl_last_assigned,
          l_smpl_assignment_type,
          l_stbl_assignment_type,
          l_stbl_last_assigned,
          1
          );

         GMD_QC_MIG12.g_quality_config_ins_count := GMD_QC_MIG12.g_quality_config_ins_count + 1;

       IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
       END IF;
  ELSE      -- vorg dont exist.
     EXIT;
  END IF;


EXCEPTION
   WHEN NEXT_CONFIG_INSERT THEN
         NULL;

   WHEN GET_ORGN_CODE_ERROR THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_ORG_CODE',
               p_context         => 'Quality Setup - quality config ins',
	       p_token1          => 'ORGID',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => to_char(v_orgs(l_org_count)),
	       p_param2          => 'orgn_code',
	       p_param3          => l_config_rec.orgn_code,
	       p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
         x_exception_count := x_exception_count + 1;

   WHEN GET_LAB_ERROR THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_GET_LAB',
               p_context         => 'Quality Setup - quality config ins',
	       p_token1          => 'ORG',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => l_orgn_code,
	       p_param2          => 'orgn_code',
	       p_param3          => l_orgn_code,
	       p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
         x_exception_count := x_exception_count + 1;

   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - quality config ins',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;


  END;     -- subprogram

  l_org_count := l_org_count + 1;

END LOOP; -- process ops loop


/*=====================================
    Update the Null Row if all config
   rows successfully migrated.
  =====================================*/

OPEN check_config_mig;
FETCH check_config_mig INTO l_config_mig_count;
CLOSE check_config_mig;

IF (l_config_mig_count = 0) THEN

   UPDATE gmd_quality_config
   SET migrated_ind = 1
   WHERE orgn_code IS NULL and migrated_ind IS NULL;

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;
   GMD_QC_MIG12.g_quality_config_upd_count := GMD_QC_MIG12.g_quality_config_upd_count + 1;

END IF;


/*===========================================================
   Adjust document sequence information.
  Do this only when all config rows migrated successfully.
  Checks for subinventory rows. Find the orgn_code the
  subinv(whse) was originally mapped to.  Get the doc sequence
  info for that orgn_code and overlay the information on the
  warehouse row.
  ===========================================================*/


FOR l_config IN get_config LOOP
     /*======================================
        Get orgn_code for subinventories.
       ======================================*/
     l_orig_orgn_code := NULL;
     OPEN get_whse_orgn (l_config.organization_id);
     FETCH get_whse_orgn INTO l_orig_orgn_code;
     CLOSE get_whse_orgn;
     IF (l_orig_orgn_code IS NOT NULL) THEN
         OPEN get_parent_config (l_orig_orgn_code);
         FETCH get_parent_config INTO l_p_assign_type, l_p_last_assign;
         IF (get_parent_config%FOUND) THEN
            /*=================================
               Overlay the sample values.
              =================================*/
            UPDATE gmd_quality_config
            SET sample_assignment_type = l_p_assign_type,
                sample_last_assigned = l_p_last_assign
            WHERE organization_id = l_config.organization_id;

            IF (p_commit = FND_API.G_TRUE) THEN
               COMMIT;
            END IF;

         END IF;
         CLOSE get_parent_config;
     END IF;


END LOOP;   -- end of get_config;


EXCEPTION

   WHEN NO_NULL_RECORD THEN
      NULL;

   WHEN CONFIG_INCOMPLETE THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_CONFIG_INCOMPLETE',
               p_context         => 'Quality Setup - quality config ins',
	       p_app_short_name  => 'GMD');
      x_exception_count := x_exception_count + 1;

   WHEN CONFIG_FINAL_INCOMPLETE THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_CONFIG_INCOMPLETE2',
               p_context         => 'Quality Setup - quality config ins',
	       p_app_short_name  => 'GMD');
      x_exception_count := x_exception_count + 1;

   WHEN REASON_CODE_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_REASON_ID',
               p_context         => 'Quality Setup - quality config ins',
	       p_token1          => 'REASON',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => l_config_rec.inv_trans_reason_code,
	       p_param2          => 'orgn_code',
	       p_param3          => l_config_rec.orgn_code,
	       p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN IN_SPEC_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_STATUS_ID',
               p_context         => 'Quality Setup - quality config ins',
	       p_token1          => 'STAT',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => l_config_rec.in_spec_lot_status,
	       p_param2          => 'orgn_code',
	       p_param3          => l_config_rec.orgn_code,
	       p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN OUT_SPEC_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_STATUS_ID',
               p_context         => 'Quality Setup - quality config ins',
	       p_token1          => 'STAT',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => l_config_rec.out_of_spec_lot_status,
	       p_param2          => 'orgn_code',
	       p_param3          => l_config_rec.orgn_code,
	       p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - quality config ins',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_quality_config_err_count := GMD_QC_MIG12.g_quality_config_err_count + 1;
       x_exception_count := x_exception_count + 1;

END;   -- end of null subprogram

-- Bug# 5569346
-- Creates the Quality config rows for warehouse (ic_whse_mst) rows
create_config_rows_for_whse(p_migration_run_id, p_commit);

/*==============================================
   Log end of gmd_quality_config migration.
  ==============================================*/
LOG_SETUP_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

/*==============================================
   Log Start of gmd_sampling_plan_b migration.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SAMPLING_PLAN_B',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SAMPLING_PLAN_B',
       p_context         => 'Quality Setup',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 3;


/*==============================================
   Loop through gmd_sampling_plans.
   Check that uom migrated and migrate uom for
   Quantity type plan.
  ==============================================*/

GMD_QC_MIG12.g_sampling_plan_upd_count :=0;
GMD_QC_MIG12.g_sampling_plan_pro_count :=0;
GMD_QC_MIG12.g_sampling_plan_err_count :=0;


FOR l_sampling_plan IN get_sampling_plan LOOP

  BEGIN   -- subprogram

    GMD_QC_MIG12.g_sampling_plan_pro_count := GMD_QC_MIG12.g_sampling_plan_pro_count + 1;

    IF (l_sampling_plan.frequency_type = 'Q' and l_sampling_plan.frequency_per IS NOT NULL) THEN
        l_sampling_uom := GMA_MIGRATION_UTILS.get_uom_code(l_sampling_plan.frequency_per);
        IF (l_sampling_uom IS NULL) THEN
           RAISE MIG_NO_UOM;
        END IF;
    ELSE
        l_sampling_uom := l_sampling_plan.frequency_per;    -- retain same value
    END IF;

    UPDATE gmd_sampling_plans_b
    SET frequency_per = l_sampling_uom,
        migrated_ind = 1
    WHERE sampling_plan_id = l_sampling_plan.sampling_plan_id;

    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;

    GMD_QC_MIG12.g_sampling_plan_upd_count := GMD_QC_MIG12.g_sampling_plan_upd_count + 1;

  EXCEPTION

   WHEN MIG_NO_UOM THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_NO_UOM',
               p_context         => 'Quality Setup - gmd_sampling_plan',
               p_token1          => 'ROWK',
               p_token2          => 'ROWV',
               p_token3          => 'UM',
               p_param1          => 'SAMPLING_PLAN_ID',
               p_param2          => to_char(l_sampling_plan.sampling_plan_id),
               p_param3          => l_sampling_plan.frequency_per,
               p_app_short_name  => 'GMD');

       GMD_QC_MIG12.g_sampling_plan_err_count := GMD_QC_MIG12.g_sampling_plan_err_count + 1;
       x_exception_count := x_exception_count + 1;

   WHEN OTHERS THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - gmd_sampling_plan',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
       GMD_QC_MIG12.g_sampling_plan_err_count := GMD_QC_MIG12.g_sampling_plan_err_count + 1;
       x_exception_count := x_exception_count + 1;


  END;  -- end subprogram

END LOOP;


/*=================================
    Log sampling plan migration.
  =================================*/
LOG_SETUP_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

RETURN;

EXCEPTION

  WHEN DEFAULT_LAB_NULL THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEFAULT_LAB_NULL',
               p_context         => 'Quality Setup - general',
	       p_app_short_name  => 'GMD');

     x_exception_count := x_exception_count + 1;

  WHEN NULL_DEF_ORGANIZATION_ID THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_NULL_DEF_ORG_ID',
               p_context         => 'Quality Setup - general',
	       p_token1          => 'ORG',
	       p_param1          => l_lab_profile,
	       p_app_short_name  => 'GMD');

     x_exception_count := x_exception_count + 1;

  WHEN OTHERS THEN

      LOG_SETUP_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Setup - general',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');

     x_exception_count := x_exception_count + 1;

END GMD_QC_MIGRATE_SETUP;



/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_samples
--
--  DESCRIPTION:
--    This procedure migrates the Quality Sample Data.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--    p_commit              IN  VARCHAR2       - Commit Flag
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--  The following columns will be migrated by the Common migration script.
--
--  gmd_samples           organization_id
--  gmd_samples           lab_organization_id
--  gmd_samples           sample_qty_uom
--  gmd_results           lab_organization_id
--  gmd_results           test_qty_uom
--=========================================================================== */

PROCEDURE GMD_QC_MIGRATE_SAMPLES
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER)

IS

/*=======================
     Exceptions
  =======================*/
MIG_NO_ORG                EXCEPTION;
MIG_NO_LAB_ORG            EXCEPTION;
MIG_WHSE_ERROR            EXCEPTION;
MIG_SUBINV_MISMATCH       EXCEPTION;
MIG_NON_LOC_FAIL          EXCEPTION;
MIG_LOCATOR_ID            EXCEPTION;
MIG_SUBINV_ERROR          EXCEPTION;
MIG_STORE_WHSE_ERROR      EXCEPTION;
MIG_STORE_NON_LOC_ERROR   EXCEPTION;
MIG_STORE_LOCATOR_ID      EXCEPTION;
MIG_ODM_ITEM              EXCEPTION;
MIG_OPM_ITEM              EXCEPTION;
MIG_LOT_ERROR             EXCEPTION;
MIG_GET_SAMPLE_ERROR      EXCEPTION;
NEXTRESULT                EXCEPTION;
-- Bug# 5261810
MIG_SOURCE_WHSE_ERROR     EXCEPTION;
MIG_SOURCE_NON_LOC_ERROR  EXCEPTION;
MIG_SOURCE_LOCATOR_ID     EXCEPTION;
MIG_SOURCE_SUBINV_ERROR   EXCEPTION;


/*==============================
   Cursor for gmd_samples.
  Added organization id to exclude
  records added post-migration in
  case migration is erroneously
  rerun again.
  ==============================*/

-- Bug# 5108963
-- Removed organization_id IS NULL from the where clause and added orgn_code IS NOT NULL.
CURSOR get_samples IS
SELECT *
FROM   gmd_samples
WHERE  migrated_ind IS NULL
AND    orgn_code IS NOT NULL;


/*==============================
   Placeholders.
  ==============================*/

l_organization_id      gmd_samples.organization_id%TYPE;
l_lab_organization_id  gmd_samples.organization_id%TYPE;
l_subinventory         mtl_item_locations.subinventory_code%TYPE;
l_subinv_ind           ic_whse_mst.subinventory_ind_flag%TYPE;
l_locator_id           ic_loct_mst.inventory_location_id%TYPE;
l_subinv               mtl_item_locations.subinventory_code%TYPE;
lsub_organization_id   mtl_item_locations.organization_id%TYPE;
ls_organization_id     mtl_item_locations.organization_id%TYPE;
l_loct_ctl             ic_whse_mst.loct_ctl%TYPE;
l_store_loct_ctl       ic_whse_mst.loct_ctl%TYPE;
l_inventory_item_id    gmd_samples.inventory_item_id%TYPE;
l_storage_org_id       gmd_samples.storage_organization_id%TYPE;
l_storage_locator_id   gmd_samples.storage_locator_id%TYPE;
l_store_subinv         gmd_samples.storage_subinventory%TYPE;
l_store_subinv_ind     ic_whse_mst.subinventory_ind_flag%TYPE;
l_parent_lot_number    gmd_samples.parent_lot_number%TYPE;
l_lot_number           gmd_samples.lot_number%TYPE;
l_get_parent_only      NUMBER := 0;
l_failure_count        NUMBER;

-- Bug# 5261810
l_org_id               NUMBER;
l_material_detail_id   NUMBER;
l_source_org_id gmd_samples.organization_id%TYPE;
l_source_subinv_ind ic_whse_mst.subinventory_ind_flag%TYPE;
l_source_loct_ctl ic_whse_mst.loct_ctl%TYPE;
l_source_subinv gmd_samples.source_subinventory%TYPE;
l_source_locator_id ic_loct_mst.inventory_location_id%TYPE;
l_source_subinv_loc mtl_item_locations.subinventory_code%TYPE;
l_src_sub_organization_id mtl_item_locations.organization_id%TYPE;


CURSOR get_item_data (v_item_id  ic_item_mst.item_id%TYPE) IS
SELECT sublot_ctl
FROM   ic_item_mst_b
WHERE  item_id = v_item_id;

l_sublot_ctl          ic_item_mst_b.sublot_ctl%TYPE;

CURSOR get_sampling_event IS
SELECT sampling_event_id
FROM   gmd_sampling_events
WHERE  migrated_ind IS NULL;
-- 12/09/2005

-- Bug# 5261810
-- Added org_id and material_detail_id
CURSOR get_sample_data(v_sampling_event_id  gmd_samples.sampling_event_id%TYPE) IS
SELECT organization_id, inventory_item_id, revision, lot_number,
      subinventory, locator_id, parent_lot_number, org_id, material_detail_id
FROM   gmd_samples
WHERE  sampling_event_id = v_sampling_event_id
AND    (migrated_ind = 1 OR organization_id IS NOT NULL);

l_samp_data            get_sample_data%ROWTYPE;


/*==============================
   Cursor for gmd_samples.
  ==============================*/

CURSOR get_results IS
SELECT result_id, qc_lab_orgn_code, lab_organization_id,
       test_kit_item_id, test_kit_lot_no, test_kit_sublot_no,
       test_kit_inv_item_id
FROM   gmd_results
WHERE  migrated_ind IS NULL;


BEGIN

x_exception_count := 0;
GMD_QC_MIG12.g_progress_ind := 0;

/*==============================================
   Log Start of gmd_samples migration.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SAMPLES',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SAMPLES',
       p_context         => 'Quality Samples',
       p_app_short_name  => 'GMA');

/*=======================================
   Migrate gmd_samples.
  =======================================*/

GMD_QC_MIG12.g_sample_upd_count := 0;
GMD_QC_MIG12.g_sample_err_count := 0;
GMD_QC_MIG12.g_sample_pro_count := 0;
GMD_QC_MIG12.g_progress_ind := 1;

FOR v_samp_rec IN get_samples LOOP

    BEGIN  -- start sample subprogram

    GMD_QC_MIG12.g_sample_pro_count := GMD_QC_MIG12.g_sample_pro_count + 1;

    /*======================================
       Get Organization ID.
      ======================================*/
    IF (v_samp_rec.orgn_code IS NOT NULL) THEN
       l_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(v_samp_rec.orgn_code);
       IF (l_organization_id IS NULL) THEN
          RAISE MIG_NO_ORG;
       END IF;
    ELSE
       l_organization_id :=  NULL;
    END IF;

    IF (v_samp_rec.qc_lab_orgn_code IS NOT NULL) THEN
       l_lab_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(v_samp_rec.qc_lab_orgn_code);
       IF (l_lab_organization_id IS NULL) THEN
          RAISE MIG_NO_LAB_ORG;
       END IF;
    ELSE
       l_lab_organization_id :=  NULL;
    END IF;


    /*==========================
         Get Organization id.
      ===========================*/
    IF (l_organization_id IS NOT NULL) THEN
       /*========================
           Get Subinventory.
         ========================*/
       IF (v_samp_rec.whse_code IS NOT NULL) THEN
          GMD_QC_MIG12.GET_WHSE_INFO(
                  v_samp_rec.whse_code,
                  ls_organization_id,
                  l_subinv_ind,
                  l_loct_ctl);

          IF (ls_organization_id IS NULL) THEN
             RAISE MIG_WHSE_ERROR;
          END IF;

          /*==========================================
             If Whse code is subinventory and
             org differs from org mapped then
             flag as an error.
            ==========================================*/

          IF (l_subinv_ind = 'Y') THEN
             IF (ls_organization_id <> l_organization_id) THEN
                 /*=========================================
                      Log error and do not migrate.
                   =========================================*/
                 RAISE MIG_SUBINV_MISMATCH;
             END IF;
          ELSE
             l_organization_id := ls_organization_id;
          END IF;
          l_subinventory := v_samp_rec.whse_code;

          /*=========================
               Get Locator Id.
            =========================*/
          IF (v_samp_rec.location IS NOT NULL) THEN
             IF (v_samp_rec.location = 'NONE') THEN
                l_locator_id := NULL;
             ELSE
                l_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID(v_samp_rec.whse_code, v_samp_rec.location);
                IF (l_locator_id IS NULL) THEN
                   IF (l_loct_ctl = 2) THEN
                      /*======================================
                         Create a Non-validated location.
                        ======================================*/

                      SAVEPOINT SAMPLELOC;

                      INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
                         p_migration_run_id  => p_migration_run_id,
                         p_organization_id   => l_organization_id,
	                 p_subinventory_code => l_subinventory,
                         p_location          => v_samp_rec.location,
                         p_loct_desc         => v_samp_rec.location,
                         p_start_date_active => SYSDATE,
                         p_commit            => p_commit,
                         x_location_id       => l_locator_id,
                         x_failure_count     => l_failure_count);
                      IF (l_failure_count > 0) THEN
                         RAISE MIG_NON_LOC_FAIL;
                      END IF;
                   ELSE
                      RAISE MIG_LOCATOR_ID;
                   END IF;
                ELSE -- locator found, not created.

                   /*==============================================
                      Get Subinv associated with
                      Locator.  Check to see if the subinventory
                      associated with the locator matches the
                      subinventory code already assigned.
                     ==============================================*/

                   GMD_QC_MIG12.GET_SUBINV_DATA(l_locator_id,
                                         l_subinv,
                                         lsub_organization_id);

                   IF (lsub_organization_id IS NULL) THEN
                      RAISE MIG_SUBINV_ERROR;
                   END IF;

                   IF (l_subinv <> l_subinventory) THEN
                       /*===================================================
                          Overlay the subinv with the one from the locator.
                         ===================================================*/
                       l_subinventory := l_subinv;
                   END IF;
                END IF;  -- locator found
             END IF;    -- none location
          ELSE  -- location is null
             l_locator_id := NULL;
          END IF;
       ELSE
          l_subinventory := NULL;
          l_locator_id := NULL;
       END IF; -- whse code is null

    ELSE  -- org is null
       l_organization_id :=  NULL;
       l_subinventory := NULL;
       l_locator_id := NULL;
    END IF;      --orgn_code is null.


    /*=================================================
        Get Storage Organization id and Subinventory.
      =================================================*/

    IF (v_samp_rec.storage_whse IS NOT NULL) THEN
       GMD_QC_MIG12.GET_WHSE_INFO (
          p_whse_code => v_samp_rec.storage_whse,
          x_organization_id => l_storage_org_id,
          x_subinv_ind => l_store_subinv_ind,
          x_loct_ctl => l_store_loct_ctl);

       IF (l_storage_org_id IS NULL) THEN
          RAISE MIG_STORE_WHSE_ERROR;
       END IF;

       l_store_subinv := v_samp_rec.storage_whse;

       /*==============================
           Get Storage Locator Id.
         ==============================*/

       IF (v_samp_rec.storage_location IS NOT NULL) THEN
           IF (v_samp_rec.storage_location = 'NONE') THEN
                l_storage_locator_id := NULL;
           ELSE
              l_storage_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID(v_samp_rec.storage_whse, v_samp_rec.storage_location);
              IF (l_storage_locator_id IS NULL) THEN
                   IF (l_loct_ctl = 2) THEN
                      /*======================================
                         Create a Non-validated location.
                        ======================================*/
                         SAVEPOINT SAMPLESTORELOC;
                         INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
                         p_migration_run_id  => p_migration_run_id,
                         p_organization_id   => l_storage_org_id,
	                 p_subinventory_code => l_store_subinv,
                         p_location          => v_samp_rec.storage_location,
                         p_loct_desc         => v_samp_rec.storage_location,
                         p_start_date_active => SYSDATE,
                         p_commit            => p_commit,
                         x_location_id       => l_storage_locator_id,
                         x_failure_count     => l_failure_count);

                      IF (l_failure_count > 0) THEN
                         RAISE MIG_STORE_NON_LOC_ERROR;
                      END IF;
                   ELSE
                      RAISE MIG_STORE_LOCATOR_ID;
                   END IF;
              ELSE   --location is null
                 l_storage_locator_id := NULL;
              END IF;
           END IF;     -- location is none;
       END IF;   -- location is none.
    ELSE  -- whse is null
       l_storage_org_id := NULL;
       l_store_subinv := NULL;
       l_storage_locator_id := NULL;
    END IF;

    -- BEGIN Bug# 5261810
    -- Added code to get subinventory and locator information for source_whse and source_location
    /*=================================================
        Get Source Organization id and Subinventory.
      =================================================*/
    IF (v_samp_rec.source_whse IS NOT NULL) THEN
       gmd_qc_mig12.get_whse_info (p_whse_code => v_samp_rec.source_whse
                                , x_organization_id => l_source_org_id
                                , x_subinv_ind => l_source_subinv_ind
                                , x_loct_ctl => l_source_loct_ctl);

       IF (l_source_org_id IS NULL) THEN
          RAISE mig_source_whse_error;
       END IF;

       l_source_subinv := v_samp_rec.source_whse;

       /*==============================
          Get Source Locator Id.
        ==============================*/
       IF (v_samp_rec.source_location IS NOT NULL) THEN
          IF (v_samp_rec.source_location = 'NONE') THEN
             l_source_locator_id := NULL;
          ELSE
             l_source_locator_id :=
                   gmd_qc_mig12.get_locator_id (v_samp_rec.source_whse, v_samp_rec.source_location);

             IF (l_source_locator_id IS NULL) THEN
                IF (l_loct_ctl = 2) THEN
                   /*======================================
                     Create a Non-validated location.
                    ======================================*/
                   SAVEPOINT samplesourceloc;
                   inv_migrate_process_org.create_location
                                                        (p_migration_run_id => p_migration_run_id
                                                       , p_organization_id => l_source_org_id
                                                       , p_subinventory_code => l_source_subinv
                                                       , p_location => v_samp_rec.source_location
                                                       , p_loct_desc => v_samp_rec.source_location
                                                       , p_start_date_active => SYSDATE
                                                       , p_commit => p_commit
                                                       , x_location_id => l_source_locator_id
                                                       , x_failure_count => l_failure_count);

                   IF (l_failure_count > 0) THEN
                      RAISE mig_source_non_loc_error;
                   END IF;
                ELSE
                   RAISE mig_source_locator_id;
                END IF;
             ELSE
                /*==============================================
                  Get Subinv associated with
                  Locator.  Check to see if the subinventory
                  associated with the locator matches the
                  subinventory code already assigned.
                 ==============================================*/
                gmd_qc_mig12.get_subinv_data (l_source_locator_id
                                           , l_source_subinv_loc
                                           , l_src_sub_organization_id);

                IF (l_src_sub_organization_id IS NULL) THEN
                   RAISE mig_source_subinv_error;
                END IF;

                IF (l_source_subinv_loc <> l_source_subinv) THEN
                   /*===================================================
                     Overlay the subinv with the one from the locator.
                    ===================================================*/
                   l_source_subinv := l_source_subinv_loc;
                END IF;
             END IF;
          END IF;
       ELSE
          l_source_locator_id := NULL;
       END IF;
    ELSE
       l_source_subinv := NULL;
       l_source_locator_id := NULL;
       l_source_org_id := NULL;
    END IF;
    -- END Bug# 5261810 End changes to get source subinventory and Locator information

    /*=========================
       Get Inventory Item id.
      =========================*/

    IF (v_samp_rec.orgn_code IS NOT NULL AND v_samp_rec.item_id IS NOT NULL) THEN
       INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
           P_MIGRATION_RUN_ID => p_migration_run_id,
           P_ITEM_ID => v_samp_rec.item_id,
           P_ORGANIZATION_ID  => l_organization_id,
           P_MODE => NULL,
           P_COMMIT => FND_API.G_TRUE,
           X_INVENTORY_ITEM_ID => l_inventory_item_id,
           X_FAILURE_COUNT => l_failure_count);

         IF (l_failure_count > 0) THEN
             RAISE MIG_ODM_ITEM;
         END IF;
   ELSE
         l_inventory_item_id := v_samp_rec.inventory_item_id;
   END IF;

    /*=========================
         Get Lot Numbers
      =========================*/

    IF (l_organization_id IS NOT NULL AND v_samp_rec.lot_no IS NOT NULL) THEN
       /*==========================================
          If lot no populated then itemid must be.
         ==========================================*/
       OPEN get_item_data(v_samp_rec.item_id);
       FETCH get_item_data INTO l_sublot_ctl;
       IF (get_item_data%NOTFOUND) THEN
           CLOSE get_item_data;
           RAISE MIG_OPM_ITEM;
       END IF;
       CLOSE get_item_data;
       IF (l_sublot_ctl = 1 AND v_samp_rec.sublot_no IS NULL) THEN
           l_get_parent_only := 1;
       ELSE
           l_get_parent_only := 0;
       END IF;
       IF (l_get_parent_only = 1) THEN
          l_parent_lot_number := v_samp_rec.lot_no;
          l_lot_number := null;
       ELSE
          inv_opm_lot_migration.GET_ODM_LOT (
            P_MIGRATION_RUN_ID => p_migration_run_id,
            P_ORGN_CODE => v_samp_rec.orgn_code,
            P_ITEM_ID => v_samp_rec.item_id,
            P_LOT_NO => v_samp_rec.lot_no,
            P_SUBLOT_NO => v_samp_rec.sublot_no,
            P_WHSE_CODE => NULL,
            P_LOCATION => NULL,
            P_GET_PARENT_ONLY => 0,
            P_COMMIT => FND_API.G_TRUE,
            X_LOT_NUMBER => l_lot_number,
            X_PARENT_LOT_NUMBER => l_parent_lot_number,
            X_FAILURE_COUNT => l_failure_count
            );

         IF (l_failure_count > 0) THEN
            RAISE MIG_LOT_ERROR;
         END IF;
       END IF;
    ELSE   -- lot no is null.
       l_parent_lot_number := NULL;
       l_lot_number := NULL;
    END IF;

    -- Bug# 5261810
    -- Added code to update Operating Unit Information for Supplier Samples
    l_org_id := NULL;
    IF v_samp_rec.supplier_site_id IS NOT NULL AND v_samp_rec.source = 'S' THEN
       SELECT org_id INTO l_org_id
       FROM po_vendor_sites_all
       WHERE vendor_site_id = v_samp_rec.supplier_site_id;
    ELSE
       l_org_id := v_samp_rec.org_id;
    END IF;

    -- Bug# 5261810
    -- Added code to populate material_detail_id so that Line and Type fields are populated when queried from the applications
    l_material_detail_id := NULL;
    IF v_samp_rec.source = 'W' AND v_samp_rec.batch_id IS NOT NULL AND v_samp_rec.formulaline_id IS NOT NULL THEN
       SELECT material_detail_id INTO l_material_detail_id
       FROM gme_material_details
       WHERE batch_id = v_samp_rec.batch_id
       AND formulaline_id = v_samp_rec.formulaline_id;
    END IF;


    /*==========================
        Update gmd_samples.
      ==========================*/

    UPDATE gmd_samples
    SET organization_id = l_organization_id,
        subinventory = l_subinventory,
        locator_id = l_locator_id,
        inventory_item_id = l_inventory_item_id,
        parent_lot_number = l_parent_lot_number,
        lab_organization_id = l_lab_organization_id,
        lot_number = l_lot_number,
        source_subinventory = l_source_subinv, -- Bug# 5261810
        source_locator_id = l_source_locator_id, -- Bug# 5261810
        storage_organization_id = l_storage_org_id,
        storage_subinventory = l_store_subinv,
        storage_locator_id = l_storage_locator_id,
	org_id = l_org_id, -- Bug# 5261810
	material_detail_id = l_material_detail_id, -- Bug# 5261810
        migrated_ind = 1
    WHERE sample_id = v_samp_rec.sample_id;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

    GMD_QC_MIG12.g_sample_upd_count := GMD_QC_MIG12.g_sample_upd_count + 1;

  EXCEPTION

  WHEN MIG_NO_ORG THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_NO_ORG',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'ORG',
               p_token2          => 'ONAME',
               p_token3          => 'ROWK',
               p_token4          => 'ROWV',
               p_param1          => v_samp_rec.orgn_code,
               p_param2          => 'ORGN_CODE',
               p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
               p_app_short_name  => 'GMD');
     GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
     x_exception_count := x_exception_count + 1;

  WHEN MIG_NO_LAB_ORG THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_NO_ORG',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'ORG',
               p_token2          => 'ONAME',
               p_token3          => 'ROWK',
               p_token4          => 'ROWV',
               p_param1          => v_samp_rec.qc_lab_orgn_code,
               p_param2          => 'QC_LAB_ORGN_CODE',
               p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
               p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_WHSE_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_WHSE_ERROR',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => v_samp_rec.whse_code,
	       p_param2          => 'WHSE_CODE',
	       p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_SUBINV_MISMATCH THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_SUBINV_MISMATCH',
               p_table_name      => NULL,
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'SAMPLEID',
               p_token2          => 'ORG',
               p_token3          => 'WHSE',
               p_token4          => 'ORGID',
               p_token5          => 'WHSEID',
               p_param1          => to_char(v_samp_rec.sample_id),
               p_param2          => v_samp_rec.orgn_code,
               p_param3          => v_samp_rec.whse_code,
               p_param4          => to_char(l_organization_id),
               p_param5          => to_char(ls_organization_id),
               p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_NON_LOC_FAIL THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ROWK',
	       p_token2          => 'ROWV',
	       p_token3          => 'FNAME',
	       p_param1          => 'SAMPLE_ID',
	       p_param2          => to_char(v_samp_rec.sample_id),
	       p_param3          => 'LOCATION',
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_LOCATOR_ID THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_LOCATOR_ID',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'WHSE',
	       p_token2          => 'LOCATION',
	       p_token3          => 'LFIELD',
	       p_token4          => 'ROWK',
	       p_token5          => 'ROWV',
	       p_param1          => v_samp_rec.whse_code,
	       p_param2          => v_samp_rec.location,
	       p_param3          => 'LOCATION',
	       p_param4          => 'SAMPLE_ID',
	       p_param5          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_SUBINV_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_SUBINV',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'LOCATOR',
               p_token2          => 'ROWK',
               p_token3          => 'ROWV',
	       p_param1          => to_char(l_locator_id),
	       p_param2          => 'SAMPLE_ID',
	       p_param3          => to_char(v_samp_rec.sample_id),
               p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;


  WHEN MIG_STORE_WHSE_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_WHSE_ERROR',
               p_context         => 'Quality Samples - gmd_samples',
      	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => v_samp_rec.storage_whse,
	       p_param2          => 'STORAGE_WHSE',
	       p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_STORE_NON_LOC_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ROWK',
	       p_token2          => 'ROWV',
	       p_token3          => 'FNAME',
	       p_param1          => 'SAMPLE_ID',
	       p_param2          => to_char(v_samp_rec.sample_id),
	       p_param3          => 'STORAGE_OCATION',
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_STORE_LOCATOR_ID THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_LOCATOR_ID',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'WHSE',
               p_token2          => 'LOCATION',
  	       p_token3          => 'LFIELD',
	       p_token4          => 'ROWK',
	       p_token5          => 'ROWV',
	       p_param1          => v_samp_rec.storage_whse,
	       p_param2          => v_samp_rec.storage_location,
	       p_param3          => 'STORAGE LOCATION',
	       p_param4          => 'SAMPLE_ID',
	       p_param5          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  -- BEGIN Bug# 5261810
  -- Added code to handle exceptions for source_whse and source_location
  WHEN MIG_SOURCE_WHSE_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_WHSE_ERROR',
               p_context         => 'Quality Samples - gmd_samples',
      	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => v_samp_rec.source_whse,
	       p_param2          => 'SOURCE_WHSE',
	       p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_SOURCE_NON_LOC_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ROWK',
	       p_token2          => 'ROWV',
	       p_token3          => 'FNAME',
	       p_param1          => 'SAMPLE_ID',
	       p_param2          => to_char(v_samp_rec.sample_id),
	       p_param3          => 'SOURCE_LOCATION',
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_SOURCE_LOCATOR_ID THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_LOCATOR_ID',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'WHSE',
               p_token2          => 'LOCATION',
  	       p_token3          => 'LFIELD',
	       p_token4          => 'ROWK',
	       p_token5          => 'ROWV',
	       p_param1          => v_samp_rec.source_whse,
	       p_param2          => v_samp_rec.source_location,
	       p_param3          => 'SOURCE_LOCATION',
	       p_param4          => 'SAMPLE_ID',
	       p_param5          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_SOURCE_SUBINV_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_SUBINV',
               p_context         => 'Quality Samples - gmd_samples',
               p_token1          => 'LOCATOR',
               p_token2          => 'ROWK',
               p_token3          => 'ROWV',
	       p_param1          => to_char(l_source_locator_id),
	       p_param2          => 'SAMPLE_ID',
	       p_param3          => to_char(v_samp_rec.sample_id),
               p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;
  -- End Bug# 5261810
  WHEN MIG_ODM_ITEM THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_ODM_ITEM',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ORG',
	       p_token2          => 'ITEMID',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => to_char(l_organization_id),
	       p_param2          => to_char(v_samp_rec.item_id),
	       p_param3          => 'SAMPLE_ID',
	       p_param4          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_OPM_ITEM THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_OPM_ITEM',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ITEMID',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => to_char(v_samp_rec.item_id),
	       p_param2          => 'SAMPLE_ID',
	       p_param3          => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN MIG_LOT_ERROR THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_LOT',
               p_context         => 'Quality Samples - gmd_samples',
	       p_token1          => 'ROWK',
	       p_token2          => 'ROWV',
	       p_param1          => 'SAMPLE_ID',
	       p_param2         => to_char(v_samp_rec.sample_id),
	       p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_sample_err_count := GMD_QC_MIG12.g_sample_err_count + 1;
      x_exception_count := x_exception_count + 1;

  WHEN OTHERS THEN

      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Samples - gmd_samples',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
      ROLLBACK;
      x_exception_count := x_exception_count + 1;

    END;   -- end sample subprogram

END LOOP;   -- loop of sample record.


/*==============================================
   Log number of updates to gmd_samples.
  ==============================================*/

LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*==============================================
   Log Start of gmd_sampling_events migration.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SAMPLING_EVENTS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SAMPLING_EVENTS',
       p_context         => 'Quality Samples',
       p_app_short_name  => 'GMA');


GMD_QC_MIG12.g_sample_event_upd_count := 0;
GMD_QC_MIG12.g_sample_event_err_count := 0;
GMD_QC_MIG12.g_sample_event_pro_count := 0;
GMD_QC_MIG12.g_progress_ind := 2;

FOR v_samp_event IN get_sampling_event LOOP

   BEGIN   -- sample event subprogram

   GMD_QC_MIG12.g_sample_event_pro_count := GMD_QC_MIG12.g_sample_event_pro_count + 1;
   /*===============================
      Get Data from gmd_samples.
     ===============================*/
   OPEN get_sample_data(v_samp_event.sampling_event_id);
   FETCH get_sample_data INTO l_samp_data;
   IF (get_sample_data%NOTFOUND) THEN
      CLOSE get_sample_data;
      RAISE MIG_GET_SAMPLE_ERROR;
   END IF;
   CLOSE get_sample_data;
   /*===============================
        Update gmd_sampling_events.
     ===============================*/
   UPDATE gmd_sampling_events
   SET organization_id =   l_samp_data.organization_id,
       inventory_item_id = l_samp_data.inventory_item_id,
       lot_number = l_samp_data.lot_number,
       subinventory = l_samp_data.subinventory,
       locator_id = l_samp_data.locator_id,
       revision = l_samp_data.revision,
       parent_lot_number = l_samp_data.parent_lot_number,
       org_id = l_samp_data.org_id, -- Bug# 5261810
       material_detail_id = l_samp_data.material_detail_id, -- Bug# 5261810
       migrated_ind = 1
    WHERE sampling_event_id = v_samp_event.sampling_event_id;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

    GMD_QC_MIG12.g_sample_event_upd_count := GMD_QC_MIG12.g_sample_event_upd_count + 1;

   EXCEPTION

   WHEN MIG_GET_SAMPLE_ERROR THEN
      -- Bug# 5462876
      -- Supress logging of the following message since there are lot of rows in gmd_sampling_events where there is no corresponding sample row.
      /*GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_GET_SAMPLE',
               p_context         => 'Quality Samples - gmd_sampling_events',
	       p_token1          => 'SAMPLEVT',
	       p_param1          => to_char(v_samp_event.sampling_event_id),
	       p_app_short_name  => 'GMD'); */
      GMD_QC_MIG12.g_sample_event_err_count := GMD_QC_MIG12.g_sample_event_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN OTHERS THEN
      LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Samples - gmd_sampling_events',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
      x_exception_count := x_exception_count + 1;

   END;   -- end sample event subprogram

END LOOP;

/*==============================================
   Log number of updates to gmd_sampling_event.
  ==============================================*/

LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*=====================================
     Log Start of gmd_results.
  =====================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_RESULTS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_RESULTS',
       p_context         => 'Quality Samples',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_result_upd_count := 0;
GMD_QC_MIG12.g_result_pro_count := 0;
GMD_QC_MIG12.g_result_err_count := 0;
GMD_QC_MIG12.g_progress_ind := 3;

FOR v_result IN get_results LOOP

    BEGIN   -- results subprogram

    GMD_QC_MIG12.g_result_pro_count := GMD_QC_MIG12.g_result_pro_count + 1;
    /*======================================
       Check if organizations migrated.
      ======================================*/
    IF (v_result.lab_organization_id IS NULL and v_result.qc_lab_orgn_code IS NOT NULL) THEN
       RAISE MIG_NO_LAB_ORG;
    END IF;

    /*======================================
       Check if uom migrated successfully.
       Removed this check.
      ======================================*/

    /*=========================
       Get Inventory Item id.
      =========================*/

    IF (v_result.test_kit_item_id IS NOT NULL) THEN
       INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
           P_MIGRATION_RUN_ID => p_migration_run_id,
           P_ITEM_ID => v_result.test_kit_item_id,
           P_ORGANIZATION_ID  => v_result.lab_organization_id,
           P_MODE => NULL,
           P_COMMIT => FND_API.G_TRUE,
           X_INVENTORY_ITEM_ID => l_inventory_item_id,
           X_FAILURE_COUNT => l_failure_count);

       IF (l_failure_count > 0) THEN
          RAISE MIG_ODM_ITEM;
       END IF;
    ELSE -- null item id
       /*============================================
          If inv item is not null then do nothing.
         ============================================*/
       IF (v_result.test_kit_inv_item_id IS NOT NULL) THEN
          RAISE NEXTRESULT;
       ELSE
          l_inventory_item_id := NULL;
       END IF;
    END IF;


    /*=======================
       Get Lot Number.
      =======================*/

    IF (v_result.test_kit_lot_no IS NOT NULL AND l_inventory_item_id IS NOT NULL) THEN
        inv_opm_lot_migration.GET_ODM_LOT (
            P_MIGRATION_RUN_ID => p_migration_run_id,
            P_ORGN_CODE => v_result.qc_lab_orgn_code,
            P_ITEM_ID => v_result.test_kit_item_id,
            P_LOT_NO => v_result.test_kit_lot_no,
            P_SUBLOT_NO => v_result.test_kit_sublot_no,
            P_WHSE_CODE => NULL,
            P_LOCATION => NULL,
            P_GET_PARENT_ONLY => 0,
            P_COMMIT => FND_API.G_TRUE,
            X_LOT_NUMBER => l_lot_number,
            X_PARENT_LOT_NUMBER => l_parent_lot_number,
            X_FAILURE_COUNT => l_failure_count
            );

        IF (l_failure_count > 0) THEN
           RAISE MIG_LOT_ERROR;
        END IF;
    ELSE   -- lot no is null.
       l_parent_lot_number := NULL;
       l_lot_number := NULL;
    END IF;


    /*==========================
        Update gmd_results.
      ==========================*/

    UPDATE gmd_results
    SET test_kit_lot_number = l_lot_number,
        test_kit_inv_item_id = l_inventory_item_id,
        migrated_ind = 1
    WHERE result_id = v_result.result_id;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

    GMD_QC_MIG12.g_result_upd_count := GMD_QC_MIG12.g_result_upd_count + 1;

EXCEPTION

  WHEN MIG_NO_LAB_ORG THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
               p_log_level       => FND_LOG.LEVEL_ERROR,
               p_message_token   => 'GMD_MIG_NO_ORG',
               p_context         => 'Quality Samples - gmd_results',
               p_token1          => 'ORG',
               p_token2          => 'ONAME',
               p_token3          => 'ROWK',
               p_token4          => 'ROWV',
               p_param1          => v_result.qc_lab_orgn_code,
               p_param2          => 'QC_LAB_ORGN_CODE',
               p_param3          => 'RESULT_ID',
	       p_param4          => to_char(v_result.result_id),
               p_app_short_name  => 'GMD');
     GMD_QC_MIG12.g_result_err_count := GMD_QC_MIG12.g_result_err_count + 1;
     x_exception_count := x_exception_count + 1;

  WHEN NEXTRESULT THEN
     NULL;

  WHEN MIG_ODM_ITEM THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_ODM_ITEM',
               p_context         => 'Quality Samples - gmd_results',
	       p_token1          => 'ORG',
	       p_token2          => 'ITEMID',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => to_char(v_result.lab_organization_id),
	       p_param2          => to_char(v_result.test_kit_item_id),
	       p_param3          => 'RESULT_ID',
	       p_param4          => to_char(v_result.result_id),
	       p_app_short_name  => 'GMD');
     GMD_QC_MIG12.g_result_err_count := GMD_QC_MIG12.g_result_err_count + 1;
     x_exception_count := x_exception_count + 1;

  WHEN MIG_LOT_ERROR THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_LOT',
               p_context         => 'Quality Samples - gmd_results',
	       p_token1          => 'ROWK',
	       p_token2          => 'ROWV',
	       p_param1          => 'RESULT_ID',
	       p_param2         => to_char(v_result.result_id),
	       p_app_short_name  => 'GMD');
     GMD_QC_MIG12.g_result_err_count := GMD_QC_MIG12.g_result_err_count + 1;
     x_exception_count := x_exception_count + 1;

  WHEN OTHERS THEN
      LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Samples - gmd_results',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
     x_exception_count := x_exception_count + 1;

    END;    -- end results subprogram

END LOOP;

/*==============================================
   Log number of updates to gmd_results.
  ==============================================*/

LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

EXCEPTION

  WHEN OTHERS THEN
      LOG_SAMPLE_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Samples - general',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
     x_exception_count := x_exception_count + 1;


END GMD_QC_MIGRATE_SAMPLES;


/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_specs
--
--  DESCRIPTION:
--    This migrates the Quality Specification Data.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--    p_commit              IN  VARCHAR2       - Commit Flag
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--  The following columns will be migrated by the Common migration script.
--
--  gmd_specifications_b     owner_organization_id
--  gmd_spec_tests_b         test_qty_uom
--  gmd_spec_tests_b         to_qty_uom
--  gmd_inventory_spec_vrs   organization_id
--  gmd_wip_spec_vrs         organization_id
--  gmd_customer_spec_vrs    organization_id
--  gmd_supplier_spec_vrs    organization_id
--  gmd_monitoring_spec_vrs  organization_id
--  gmd_monitoring_spec_vrs  resource_organization_id
--===========================================================================*/

PROCEDURE GMD_QC_MIGRATE_SPECS
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER)
IS


/*==============================
       Exceptions
  ==============================*/
MIG_NO_ORG                EXCEPTION;
MIG_ODM_ITEM              EXCEPTION;
ISPEC_NO_ORG              EXCEPTION;
ISPEC_WHSE_ERROR          EXCEPTION;
ISPEC_SUB_MISMATCH        EXCEPTION;
ISPEC_NON_LOC             EXCEPTION;
ISPEC_LOCATOR_ID          EXCEPTION;
ISPEC_SUBINV              EXCEPTION;
ISPEC_GET_OPM_LOT         EXCEPTION;
ISPEC_GET_OPM_ITEM        EXCEPTION;
ISPEC_MIG_LOT             EXCEPTION;
ISPEC_IN_STATUS           EXCEPTION;
ISPEC_OUT_STATUS          EXCEPTION;
ISPEC_SAMPLE_ORG          EXCEPTION;
ISPEC_SAMPLE_ORG_ID       EXCEPTION;
ISPEC_DELETE_INVSPEC      EXCEPTION;
NEXT_IN_INV_LINE          EXCEPTION;
WIP_NO_ORG                EXCEPTION;
WIP_IN_STATUS             EXCEPTION;
WIP_OUT_STATUS            EXCEPTION;
WIP_SPEC_DELETE           EXCEPTION;
WIP_SAMPLE_ORG            EXCEPTION;
WIP_SAMPLE_ORG_ID         EXCEPTION;
NEXT_IN_WIP_LINE          EXCEPTION;
CUST_NO_ORG               EXCEPTION;
CUST_SPEC_DELETE          EXCEPTION;
CUST_NO_ORG_ID            EXCEPTION;
NEXT_IN_CUST_LINE         EXCEPTION;
SUP_NO_ORG                EXCEPTION;
SUP_IN_STATUS             EXCEPTION;
SUP_OUT_STATUS            EXCEPTION;
SUP_SPEC_DELETE           EXCEPTION;
SUP_NO_ORG_ID             EXCEPTION;
NEXT_IN_SUPL_LINE         EXCEPTION;
MON_NO_ORG                EXCEPTION;
MON_NO_RES_ORG            EXCEPTION;
MON_WHSE_ERROR            EXCEPTION;
MON_SUB_MISMATCH          EXCEPTION;
MON_CREATE_LOC            EXCEPTION;
MON_LOCATOR_ID            EXCEPTION;
MON_SUBINV_ERROR          EXCEPTION;
MON_SPEC_DELETE           EXCEPTION;
MON_NO_ORG_ID             EXCEPTION;
NEXT_IN_MON_LINE          EXCEPTION;
ISPEC_GET_SPEC_ITEM       EXCEPTION;

/*==============================
       Placeholders.
  ==============================*/

l_organization_id      gmd_samples.organization_id%TYPE;
ls_organization_id     gmd_samples.organization_id%TYPE;
l_subinventory         mtl_item_locations.subinventory_code%TYPE;
l_subinv_ind           ic_whse_mst.subinventory_ind_flag%TYPE;
l_locator_id           ic_loct_mst.inventory_location_id%TYPE;
l_subinv               mtl_item_locations.subinventory_code%TYPE;
lsub_organization_id   mtl_item_locations.organization_id%TYPE;
l_loct_ctl             ic_whse_mst.loct_ctl%TYPE;
l_mon_loct_ctl         ic_whse_mst.loct_ctl%TYPE;
l_parent_lot_number    gmd_samples.parent_lot_number%TYPE;
l_lot_number           gmd_samples.lot_number%TYPE;
l_get_parent_only      NUMBER := 0;
l_failure_count        NUMBER;
l_return_status        NUMBER;
l_in_spec_status_id    ic_lots_sts.status_id%TYPE;
l_out_spec_status_id   ic_lots_sts.status_id%TYPE;
l_clone                NUMBER;
l_text_code            NUMBER;

-- Bug# 5482253
l_supl_org_id          NUMBER;
l_material_detail_id   NUMBER;


/*=======================================
   Cursor for gmd_specifications_b.
  Add organization id null check to
  select rows that have not migrated.
  Org id not null means either it was
  migrated or row was created post-migration.
  =======================================*/

-- Bug# 5097457
-- Removed owner_organization_id IS NULL from the where clause and added owner_orgn_code IS NOT NULL.
CURSOR get_specs IS
SELECT item_id, owner_organization_id, owner_orgn_code, spec_id
FROM   gmd_specifications_b
WHERE  migrated_ind IS NULL
AND    owner_orgn_code IS NOT NULL;

l_spec_inv_item_id      gmd_specifications_b.inventory_item_id%TYPE;
l_owner_org_id          gmd_specifications_b.owner_organization_id%TYPE;

/*=======================================
   Cursor for gmd_inventory_spec_vrs.
  =======================================*/

CURSOR get_inv_spec IS
SELECT * from gmd_inventory_spec_vrs
WHERE  migrated_ind IS NULL
ORDER BY orgn_code;

l_inv_spec         gmd_inventory_spec_vrs%ROWTYPE;


/*=======================================
   Cursor to get Item_id for a Lot.
  =======================================*/

l_item_id                  gmd_specifications_b.item_id%TYPE;

-- If item_id for lot is not available from lot, get it from the spec.

CURSOR get_spec_item_id (p_spec_id    gmd_specifications.spec_id%TYPE) IS
SELECT item_id
FROM   gmd_specifications_b
WHERE  spec_id = p_spec_id;

/*=======================================
   Cursor to get Item lot control info.
  =======================================*/

CURSOR get_item_data IS
SELECT sublot_ctl
FROM   ic_item_mst_b
WHERE  item_id = l_item_id;

l_sublot_ctl          ic_item_mst_b.sublot_ctl%TYPE;

/*====================================================
   Cursor to check if gmd_inventory_spec_vrs exists.
  ====================================================*/

l_sample_orgn_code            gmd_sampling_events.orgn_code%TYPE;

-- Bug# 5482253
-- Commented the following cursor definition and added it with the new where clause.

/*CURSOR check_inv_spec IS
SELECT spec_vr_id
FROM   gmd_inventory_spec_vrs
WHERE  orgn_code = l_sample_orgn_code
AND    whse_code = l_inv_spec.whse_code
AND    location = l_inv_spec.location
AND    lot_no = l_inv_spec.lot_no
AND    sublot_no = l_inv_spec.sublot_no;*/

CURSOR check_inv_spec IS
SELECT spec_vr_id
  FROM gmd_inventory_spec_vrs
 WHERE orgn_code = l_sample_orgn_code
   AND spec_id = l_inv_spec.spec_id
   AND ( (whse_code IS NULL AND l_inv_spec.whse_code IS NULL) OR
         (whse_code = l_inv_spec.whse_code)
       )
   AND ( (location IS NULL  AND l_inv_spec.location IS NULL) OR
         (location = l_inv_spec.location)
       )
   AND ( (lot_no IS NULL AND l_inv_spec.lot_no IS NULL) OR
         (lot_no = l_inv_spec.lot_no)
       )
   AND ( (sublot_no IS NULL AND l_inv_spec.sublot_no IS NULL) OR
         (sublot_no = l_inv_spec.sublot_no)
       );


l_check_vrid                gmd_inventory_spec_vrs.spec_vr_id%TYPE;


/*=======================================
   Cursor to get orgn_codes for sample
   that inventory validity rule is tied to.
  =======================================*/

CURSOR get_sample_org (v_spec_id    gmd_inventory_spec_vrs.spec_vr_id%TYPE) IS
SELECT DISTINCT gse.orgn_code, gse.organization_id
FROM   gmd_sampling_events gse, gmd_event_spec_disp gesd,
       gmd_inventory_spec_vrs gisv
WHERE  gse.sampling_event_id = gesd.sampling_event_id
AND    gesd.spec_vr_id = gisv.spec_vr_id
AND    gisv.spec_vr_id = v_spec_id;

l_sample_organization_id       gmd_sampling_events.organization_id%TYPE;


/*=======================================
   Cursor for gmd_wip_spec.
  =======================================*/

-- Bug# 5109249
-- Commented the organization_id from the where clause
CURSOR get_wip_spec IS
SELECT * from gmd_wip_spec_vrs
WHERE  migrated_ind IS NULL
--AND    organization_id IS NULL
ORDER BY orgn_code;

l_wip_spec         gmd_wip_spec_vrs%ROWTYPE;
l_wip_org_id       gmd_wip_spec_vrs.organization_id%TYPE;

/*=======================================
   Cursor to get orgn_codes for sample
   that wip validity rule is tied to.
  =======================================*/

CURSOR get_wip_sample_org (v_spec_id    gmd_wip_spec_vrs.spec_vr_id%TYPE) IS
SELECT DISTINCT gse.orgn_code, gse.organization_id
FROM   gmd_sampling_events gse, gmd_event_spec_disp gesd,
       gmd_wip_spec_vrs gwsv
WHERE  gse.sampling_event_id = gesd.sampling_event_id
AND    gesd.spec_vr_id = gwsv.spec_vr_id
AND    gwsv.spec_vr_id = v_spec_id;

/*=======================================
   Cursor to check if wip validity rule
   exists.
  =======================================*/

-- Bug# 5482253
-- Commented the following cursor definition and added it with the new where clause.

/*CURSOR check_wip_spec IS
SELECT spec_vr_id
FROM   gmd_wip_spec_vrs
WHERE  orgn_code = l_sample_orgn_code;*/

CURSOR check_wip_spec IS
SELECT spec_vr_id
  FROM gmd_wip_spec_vrs
 WHERE orgn_code = l_sample_orgn_code
   AND spec_id = l_wip_spec.spec_id
   AND ( (batch_id IS NULL AND l_wip_spec.batch_id IS NULL) OR
         (batch_id = l_wip_spec.batch_id)
       )
   AND ( (recipe_id IS NULL AND l_wip_spec.recipe_id IS NULL) OR
         (recipe_id = l_wip_spec.recipe_id)
       )
   AND ( (recipe_no IS NULL AND l_wip_spec.recipe_no IS NULL) OR
         (recipe_no = l_wip_spec.recipe_no)
       )
   AND ( (formula_id IS NULL AND l_wip_spec.formula_id IS NULL) OR
         (formula_id = l_wip_spec.formula_id)
       )
   AND ( (formula_no IS NULL AND l_wip_spec.formula_no IS NULL) OR
         (formula_no = l_wip_spec.formula_no)
       )
   AND ( (formulaline_id IS NULL AND l_wip_spec.formulaline_id IS NULL) OR
         (formulaline_id = l_wip_spec.formulaline_id)
       )
   AND ( (routing_id IS NULL AND l_wip_spec.routing_id IS NULL) OR
         (routing_id = l_wip_spec.routing_id)
       )
   AND ( (routing_no IS NULL AND l_wip_spec.routing_no IS NULL) OR
         (routing_no = l_wip_spec.routing_no)
       )
   AND ( (step_id IS NULL AND l_wip_spec.step_id IS NULL) OR
         (step_id = l_wip_spec.step_id)
       )
   AND ( (oprn_id IS NULL AND l_wip_spec.oprn_id IS NULL) OR
         (oprn_id = l_wip_spec.oprn_id)
       )
   AND ( (oprn_no IS NULL AND l_wip_spec.oprn_no IS NULL) OR
         (oprn_no = l_wip_spec.oprn_no)
       )
   AND ( (charge IS NULL AND l_wip_spec.charge IS NULL) OR
         (charge = l_wip_spec.charge)
       );

/*=======================================
   Cursor for gmd_customer_spec_vrs.
  =======================================*/

CURSOR get_cust_spec IS
SELECT * from gmd_customer_spec_vrs
WHERE  migrated_ind IS NULL
ORDER BY orgn_code;

l_cust_spec        gmd_customer_spec_vrs%ROWTYPE;

/*=======================================
   Cursor to get orgn_codes for sample
   that customer validity rule is tied to.
  =======================================*/

CURSOR get_cust_sample_org (v_spec_id    gmd_wip_spec_vrs.spec_vr_id%TYPE) IS
SELECT DISTINCT gse.orgn_code, gse.organization_id
FROM   gmd_sampling_events gse, gmd_event_spec_disp gesd,
       gmd_customer_spec_vrs gcsv
WHERE  gse.sampling_event_id = gesd.sampling_event_id
AND    gesd.spec_vr_id = gcsv.spec_vr_id
AND    gcsv.spec_vr_id = v_spec_id;

/*=======================================
   Cursor to check if customer validity
   rule exists.
  =======================================*/

-- Bug# 5482253
-- Commented the following cursor definition and added it with the new where clause.

/*CURSOR check_cust_spec IS
SELECT spec_vr_id
FROM   gmd_customer_spec_vrs
WHERE  orgn_code = l_sample_orgn_code;*/

CURSOR check_cust_spec IS
SELECT spec_vr_id
  FROM gmd_customer_spec_vrs
 WHERE orgn_code = l_sample_orgn_code
   AND spec_id = l_cust_spec.spec_id
   AND ( (cust_id IS NULL AND l_cust_spec.cust_id IS NULL) OR
         (cust_id = l_cust_spec.cust_id)
       )
   AND ( (org_id IS NULL AND l_cust_spec.org_id IS NULL) OR
         (org_id = l_cust_spec.org_id)
       )
   AND ( (order_id IS NULL AND l_cust_spec.order_id IS NULL) OR
         (order_id = l_cust_spec.order_id)
       )
   AND ( (order_line IS NULL AND l_cust_spec.order_line IS NULL) OR
         (order_line = l_cust_spec.order_line)
       )
   AND ( (order_line_id IS NULL AND l_cust_spec.order_line_id IS NULL) OR
         (order_line_id = l_cust_spec.order_line_id)
       )
   AND ( (ship_to_site_id IS NULL AND l_cust_spec.ship_to_site_id IS NULL) OR
         (ship_to_site_id = l_cust_spec.ship_to_site_id)
       );

/*=======================================
   Cursor for gmd_supplier_spec.
  =======================================*/

CURSOR get_supplier_spec IS
SELECT *
FROM   gmd_supplier_spec_vrs
WHERE  migrated_ind IS NULL
ORDER BY orgn_code;

l_supl_spec        gmd_supplier_spec_vrs%ROWTYPE;

/*=======================================
   Cursor to get orgn_codes for sample
   that supplier validity rule is tied to.
  =======================================*/

CURSOR get_supl_sample_org (v_spec_id    gmd_wip_spec_vrs.spec_vr_id%TYPE) IS
SELECT DISTINCT gse.orgn_code, gse.organization_id
FROM   gmd_sampling_events gse, gmd_event_spec_disp gesd,
       gmd_supplier_spec_vrs gssv
WHERE  gse.sampling_event_id = gesd.sampling_event_id
AND    gesd.spec_vr_id = gssv.spec_vr_id
AND    gssv.spec_vr_id = v_spec_id;

/*=======================================
   Cursor to check if Supplier validity
   rule exists.
  =======================================*/

-- Bug# 5482253
-- Commented the following cursor definition and added it with the new where clause.

/*CURSOR check_supl_spec IS
SELECT spec_vr_id
FROM   gmd_supplier_spec_vrs
WHERE  orgn_code = l_sample_orgn_code;*/

CURSOR check_supl_spec IS
SELECT spec_vr_id
  FROM gmd_supplier_spec_vrs
 WHERE orgn_code = l_sample_orgn_code
   AND spec_id = l_supl_spec.spec_id
   AND ( (supplier_id IS NULL AND l_supl_spec.supplier_id IS NULL) OR
         (supplier_id = l_supl_spec.supplier_id)
       )
   AND ( (supplier_site_id IS NULL AND l_supl_spec.supplier_site_id IS NULL) OR
         (supplier_site_id = l_supl_spec.supplier_site_id)
       )
   AND ( (po_header_id IS NULL AND l_supl_spec.po_header_id IS NULL) OR
         (po_header_id = l_supl_spec.po_header_id)
       )
   AND ( (po_line_id IS NULL AND l_supl_spec.po_line_id IS NULL) OR
         (po_line_id = l_supl_spec.po_line_id)
       );


/*=======================================
   Cursor for gmd_monitoring_spec_vrs.
  =======================================*/

-- Bug# 5097487
-- Added rule_type = 'L' in the where clause since we dont want to process VR for resource as it is already done by gma upgrade script
CURSOR get_monitor_spec IS
SELECT *
FROM   gmd_monitoring_spec_vrs
WHERE  migrated_ind IS NULL
AND    rule_type = 'L'
ORDER BY loct_orgn_code;

l_mon_spec         gmd_monitoring_spec_vrs%ROWTYPE;

/*==========================================
   Cursor to get orgn_codes for sample
   that monitoring validity rule is tied to.
  ==========================================*/

CURSOR get_mon_sample_org (v_spec_id    gmd_monitoring_spec_vrs.spec_vr_id%TYPE) IS
SELECT DISTINCT gse.orgn_code, gse.organization_id
FROM   gmd_sampling_events gse, gmd_event_spec_disp gesd,
       gmd_monitoring_spec_vrs gmsv
WHERE  gse.sampling_event_id = gesd.sampling_event_id
AND    gesd.spec_vr_id = gmsv.spec_vr_id
AND    gmsv.spec_vr_id = v_spec_id;

/*=======================================
   Cursor to check if monitoring
   validity rule exists.
  =======================================*/

-- Bug# 5482253
-- Commented the following cursor definition and added it with the new where clause.

/*CURSOR check_mon_spec IS
SELECT spec_vr_id
FROM   gmd_monitoring_spec_vrs
WHERE  loct_orgn_code = l_sample_orgn_code
AND    whse_code = l_mon_spec.whse_code
AND    location = l_mon_spec.location;*/

CURSOR check_mon_spec IS
SELECT spec_vr_id
  FROM gmd_monitoring_spec_vrs
 WHERE loct_orgn_code = l_sample_orgn_code
   AND spec_id = l_mon_spec.spec_id
   AND ( (whse_code IS NULL AND l_mon_spec.whse_code IS NULL) OR
         (whse_code = l_mon_spec.whse_code)
       )
   AND ( (location IS NULL  AND l_mon_spec.location IS NULL) OR
         (location = l_mon_spec.location)
       );

BEGIN

x_exception_count := 0;

/*==============================================
   Log Start of gmd_specifications_b.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SPECIFICATIONS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SPECIFICATIONS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

/*====================================
   Migrate gmd_specifications_b.
  ====================================*/

GMD_QC_MIG12.g_progress_ind := 1;
GMD_QC_MIG12.g_specs_pro_count := 0;
GMD_QC_MIG12.g_specs_upd_count := 0;
GMD_QC_MIG12.g_specs_err_count := 0;

FOR v_specs_b IN get_specs LOOP
   BEGIN    -- specs subprogram
   GMD_QC_MIG12.g_specs_pro_count := GMD_QC_MIG12.g_specs_pro_count + 1;
   /*==========================================
      Get organization_id.
     ==========================================*/
   l_owner_org_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(v_specs_b.owner_orgn_code);
   IF (l_owner_org_id IS NULL) THEN
      RAISE MIG_NO_ORG;
   END IF;

   /*=========================
       Get Inventory Item id.
     =========================*/

   IF (v_specs_b.item_id IS NOT NULL and l_owner_org_id IS NOT NULL) THEN
      INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
          P_MIGRATION_RUN_ID => p_migration_run_id,
          P_ITEM_ID => v_specs_b.item_id,
          P_ORGANIZATION_ID  => l_owner_org_id,
          P_MODE => NULL,
          P_COMMIT => FND_API.G_TRUE,
          X_INVENTORY_ITEM_ID => l_spec_inv_item_id,
          X_FAILURE_COUNT => l_failure_count);

      IF (l_failure_count > 0) THEN
          RAISE MIG_ODM_ITEM;
      END IF;
   ELSE
      l_spec_inv_item_id := NULL;
   END IF;

   /*==================================
       Update gmd_specifications_b.
     ==================================*/

   -- Bug# 5097457
   -- Added grade_code in the update statement
   UPDATE gmd_specifications_b
   SET inventory_item_id = l_spec_inv_item_id,
       owner_organization_id = l_owner_org_id,
       grade_code = grade,
       migrated_ind = 1
   WHERE spec_id = v_specs_b.spec_id;

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;

   GMD_QC_MIG12.g_specs_upd_count := GMD_QC_MIG12.g_specs_upd_count + 1;

   EXCEPTION

     WHEN MIG_NO_ORG THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
             p_run_id          => p_migration_run_id,
             p_log_level       => FND_LOG.LEVEL_ERROR,
             p_message_token   => 'GMD_MIG_NO_ORG',
             p_table_name      => NULL,
             p_context         => 'Quality Specifications - gmd_specifications_b',
             p_token1          => 'ORG',
             p_token2          => 'ONAME',
             p_token3          => 'ROWK',
             p_token4          => 'ROWV',
             p_param1          => v_specs_b.owner_orgn_code,
             p_param2          => 'OWNER_ORGN_CODE',
             p_param3          => 'SPEC_ID',
             p_param4          => to_char(v_specs_b.spec_id),
             p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_specs_err_count := GMD_QC_MIG12.g_specs_err_count + 1;
         x_exception_count := x_exception_count + 1;

     WHEN MIG_ODM_ITEM THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_ODM_ITEM',
               p_context         => 'Quality Specifications - gmd_specifications_b',
	       p_token1          => 'ORG',
	       p_token2          => 'ITEMID',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => to_char(v_specs_b.owner_organization_id),
	       p_param2          => to_char(v_specs_b.item_id),
               p_param3          => 'SPEC_ID',
               p_param4          => to_char(v_specs_b.spec_id),
	       p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_specs_err_count := GMD_QC_MIG12.g_specs_err_count + 1;
         x_exception_count := x_exception_count + 1;

     WHEN OTHERS THEN
         LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
         GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Specifications - gmd_specifications_b',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
         x_exception_count := x_exception_count + 1;

   END;     -- end specs subprogram

END LOOP;

/*==============================================
   Log end of gmd_specifications_b migration.
  ==============================================*/

LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

/*===============================================
   NOTE: gmd_spec_tests_b will be migrated by
   Common migration scripts.  We will not
   confirm that it was successful via the
   Quality script.
  ===============================================*/

/*=======================================
  Migrate gmd_inventory_spec_vrs.
  =======================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_INVENTORY_SPEC_VRS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_INVENTORY_SPEC_VRS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 2;
GMD_QC_MIG12.g_inv_spec_pro_count := 0;
GMD_QC_MIG12.g_inv_spec_ins_count := 0;
GMD_QC_MIG12.g_inv_spec_del_count := 0;
GMD_QC_MIG12.g_inv_spec_upd_count := 0;
GMD_QC_MIG12.g_inv_spec_err_count := 0;

FOR l_inv_spec IN get_inv_spec LOOP
   BEGIN   -- inv spec subprogram
   GMD_QC_MIG12.g_inv_spec_pro_count := GMD_QC_MIG12.g_inv_spec_pro_count + 1;
   /*======================================
        Check if organizations migrated.
     ======================================*/
   IF (l_inv_spec.organization_id IS NULL and l_inv_spec.orgn_code IS NOT NULL) THEN
      RAISE ISPEC_NO_ORG;
   END IF;

   /*========================================
      Check to see if rule will be cloned for
      each sample the rule is tied to.
     ========================================*/

   IF (l_inv_spec.orgn_code IS NOT NULL) THEN
      l_clone := 0;
   ELSE
      IF (l_inv_spec.lot_no IS NOT NULL AND
          l_inv_spec.whse_code IS NULL and l_inv_spec.location IS NULL) THEN
         l_clone := 1;
      ELSE
         l_clone := 0;
      END IF;
   END IF;

   l_organization_id :=  l_inv_spec.organization_id;

   IF (l_inv_spec.orgn_code IS NOT NULL) THEN
      /*========================
            Get Subinventory.
        ========================*/
      IF (l_inv_spec.whse_code IS NOT NULL) THEN
         GMD_QC_MIG12.GET_WHSE_INFO(
                 l_inv_spec.whse_code,
                 ls_organization_id,
                 l_subinv_ind,
                 l_loct_ctl);

         IF (ls_organization_id IS NULL) THEN
            RAISE ISPEC_WHSE_ERROR;
         END IF;

         /*==========================================
            If Whse code is subinventory and
            org differs from org mapped then
            flag as an error.
           ==========================================*/

         IF (l_subinv_ind = 'Y') THEN
            IF (ls_organization_id <> l_organization_id) THEN
                /*=========================================
                     Log error and do not migrate.
                  =========================================*/
                RAISE ISPEC_SUB_MISMATCH;
            END IF;
         ELSE
            l_organization_id := ls_organization_id;
         END IF;
         l_subinventory := l_inv_spec.whse_code;

         /*=========================
              Get Locator Id.
           =========================*/

         IF (l_inv_spec.location IS NOT NULL) THEN
            IF (l_inv_spec.location = 'NONE') THEN
               l_locator_id := NULL;
            ELSE
               l_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID(l_inv_spec.whse_code, l_inv_spec.location);
               IF (l_locator_id IS NULL) THEN
                   IF (l_loct_ctl = 2) THEN
                      /*======================================
                         Create a Non-validated location.
                        ======================================*/
                      INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
                         p_migration_run_id  => p_migration_run_id,
                         p_organization_id   => l_organization_id,
	                 p_subinventory_code => l_subinventory,
                         p_location          => l_inv_spec.location,
                         p_loct_desc         => l_inv_spec.location,
                         p_start_date_active => SYSDATE,
                         p_commit            => p_commit,
                         x_location_id       => l_locator_id,
                         x_failure_count     => l_failure_count);

                      IF (l_failure_count > 0) THEN
                         RAISE ISPEC_NON_LOC;
                      END IF;
                   ELSE
                      RAISE ISPEC_LOCATOR_ID;
                  END IF;
               ELSE
                  GMD_QC_MIG12.GET_SUBINV_DATA(l_locator_id,
                                      l_subinv,
                                      lsub_organization_id);

                  IF (lsub_organization_id IS NULL) THEN
                      RAISE ISPEC_SUBINV;
                  END IF;

                  IF (l_subinv <> l_subinventory) THEN
                      /*==============================================
                           Overlay subinventory with locator subinv.
                        ==============================================*/
                      l_subinventory := l_subinv;
                  END IF;
               END IF;
            END IF;   -- location code is none
         ELSE   -- location code is null
            l_locator_id := NULL;
         END IF;   -- location is null
      ELSE     -- whse code is null
         l_subinventory := NULL;
         l_locator_id := NULL;
      END IF; -- whse code is null
   ELSE       -- orgn code is null
      l_organization_id := NULL;
      l_subinventory := NULL;
      l_locator_id := NULL;
   END IF;    -- orgn code is null.

   /*=================================
       Get Item Id from ic_lots_mst
      for use in Lot creation.
     =================================*/


      /*========================
           Get ODM Lot.
        ========================*/

      IF (l_inv_spec.lot_no IS NOT NULL AND
          l_inv_spec.orgn_code IS NOT NULL) THEN
         l_item_id := NULL;
         OPEN get_spec_item_id (l_inv_spec.spec_id);
         FETCH get_spec_item_id INTO l_item_id;
         IF (get_spec_item_id%NOTFOUND) THEN
             CLOSE get_spec_item_id;
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;
         CLOSE get_spec_item_id;
         IF (l_item_id IS NULL) THEN
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;

         OPEN get_item_data;
         FETCH get_item_data INTO l_sublot_ctl;
         IF (get_item_data%NOTFOUND) THEN
             CLOSE get_item_data;
             RAISE ISPEC_GET_OPM_ITEM;
         END IF;
         CLOSE get_item_data;
         IF (l_sublot_ctl = 1 AND l_inv_spec.sublot_no IS NULL) THEN
             l_get_parent_only := 1;
         ELSE
             l_get_parent_only := 0;
         END IF;
         IF (l_get_parent_only = 1) THEN
            l_parent_lot_number := l_inv_spec.lot_no;
            l_lot_number := null;
         ELSE
            inv_opm_lot_migration.GET_ODM_LOT (
              P_MIGRATION_RUN_ID => p_migration_run_id,
              P_ORGN_CODE => l_inv_spec.orgn_code,
              P_ITEM_ID => l_item_id,
              P_LOT_NO => l_inv_spec.lot_no,
              P_SUBLOT_NO => l_inv_spec.sublot_no,
              P_WHSE_CODE => NULL,
              P_LOCATION => NULL,
              P_GET_PARENT_ONLY => 0,
              P_COMMIT => FND_API.G_TRUE,
              X_LOT_NUMBER => l_lot_number,
              X_PARENT_LOT_NUMBER => l_parent_lot_number,
              X_FAILURE_COUNT => l_failure_count
              );

           IF (l_failure_count > 0) THEN
              RAISE ISPEC_MIG_LOT;
           END IF;
         END IF;
   ELSE   -- lot id is null.
       l_parent_lot_number := NULL;
       l_lot_number := NULL;
   END IF;

   /*=====================================
        Get Status Ids.
     =====================================*/

   IF (l_inv_spec.in_spec_lot_status IS NULL) THEN
      l_in_spec_status_id := NULL;
   ELSE
      l_in_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_inv_spec.in_spec_lot_status);
      IF (l_in_spec_status_id IS NULL) THEN
         RAISE ISPEC_IN_STATUS;
      END IF;
   END IF;

   IF (l_inv_spec.out_of_spec_lot_status IS NULL) THEN
      l_out_spec_status_id := NULL;
   ELSE
      l_out_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_inv_spec.out_of_spec_lot_status);
      IF (l_out_spec_status_id IS NULL) THEN
         RAISE ISPEC_OUT_STATUS;
      END IF;
   END IF;

   IF (l_clone = 0) THEN

      /*================================
         Update gmd_inventory_spec_vrs
        ================================*/

      UPDATE gmd_inventory_spec_vrs
      SET organization_id = l_organization_id,
          lot_number = l_lot_number,
          parent_lot_number = l_parent_lot_number,
          subinventory = l_subinventory,
          locator_id = l_locator_id,
          out_of_spec_lot_status_id = l_out_spec_status_id,
          in_spec_lot_status_id = l_in_spec_status_id,
          migrated_ind = 1
      WHERE spec_vr_id = l_inv_spec.spec_vr_id;

      IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
      END IF;

      GMD_QC_MIG12.g_inv_spec_upd_count := GMD_QC_MIG12.g_inv_spec_upd_count + 1;

   ELSE          -- clone else
      /*================================================
         For each Sample orgn the rule is attached to
         create a new row.  First overlay the null row.
        ================================================*/
        OPEN get_sample_org (l_inv_spec.spec_vr_id);
        FETCH get_sample_org INTO l_sample_orgn_code, l_sample_organization_id;
        IF (get_sample_org%NOTFOUND) THEN
           CLOSE get_sample_org;
           /*========================================
              Log the spec record and Delete it
              as it is not tied to any Sample.
             ========================================*/
           GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
	         p_log_level       => FND_LOG.LEVEL_EVENT,
	         p_message_token   => 'GMD_MIG_SPEC_DELETE',
	         p_table_name      => NULL,
                 p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	         p_token1          => 'TAB',
	         p_token2          => 'ORG',
	         p_token3          => 'LOT',
	         p_token4          => 'SUBLOT',
	         p_param1          => 'gmd_inventory_spec_vrs',
	         p_param2          => NVL(l_inv_spec.orgn_code,' '),
	         p_param3          => NVL(l_inv_spec.lot_no,' '),
	         p_param4          => NVL(l_inv_spec.sublot_no,' '),
	         p_app_short_name  => 'GMD');

           /*==========================================
              This is not marked as an error.
             ==========================================*/

           DELETE gmd_inventory_spec_vrs
           WHERE spec_vr_id = l_inv_spec.spec_vr_id;

           IF (p_commit = FND_API.G_TRUE) THEN
              COMMIT;
           END IF;

           GMD_QC_MIG12.g_inv_spec_del_count := GMD_QC_MIG12.g_inv_spec_del_count + 1;
           RAISE ISPEC_DELETE_INVSPEC;    -- goes to next invspec record.
        END IF;

         /*================================
            Check if combination exists
            for the first Sample related
            record.
           ================================*/
         BEGIN  -- subprogram for check inv spec
         OPEN check_inv_spec;
         FETCH check_inv_spec INTO l_check_vrid;
         IF (check_inv_spec%FOUND) THEN
            CLOSE check_inv_spec;
            RAISE NEXT_IN_INV_LINE;
         END IF;
         CLOSE check_inv_spec;

         /*=========================================
            Convert Sample org to organization_id,
           =========================================*/
         IF (l_sample_organization_id IS NULL) THEN
            l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
            IF (l_sample_organization_id IS NULL) THEN
               CLOSE get_sample_org;
               RAISE ISPEC_SAMPLE_ORG;  -- goes to next invspec record.
            END IF;
         END IF;

         /*===================================
            Get ODM Lot for the new orgn.
           ===================================*/

         l_item_id := NULL;
         OPEN get_spec_item_id (l_inv_spec.spec_id);
         FETCH get_spec_item_id INTO l_item_id;
         IF (get_spec_item_id%NOTFOUND) THEN
             CLOSE get_spec_item_id;
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;
         CLOSE get_spec_item_id;
         IF (l_item_id IS NULL) THEN
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;

         OPEN get_item_data;
         FETCH get_item_data INTO l_sublot_ctl;
         IF (get_item_data%NOTFOUND) THEN
             CLOSE get_item_data;
             RAISE ISPEC_GET_OPM_ITEM;
         END IF;
         CLOSE get_item_data;
         IF (l_sublot_ctl = 1 AND l_inv_spec.sublot_no IS NULL) THEN
             l_get_parent_only := 1;
         ELSE
             l_get_parent_only := 0;
         END IF;
         IF (l_get_parent_only = 1) THEN
            l_parent_lot_number := l_inv_spec.lot_no;
            l_lot_number := null;
         ELSE
            inv_opm_lot_migration.GET_ODM_LOT (
              P_MIGRATION_RUN_ID => p_migration_run_id,
              P_ORGN_CODE => l_sample_orgn_code,
              P_ITEM_ID => l_item_id,
              P_LOT_NO => l_inv_spec.lot_no,
              P_SUBLOT_NO => l_inv_spec.sublot_no,
              P_WHSE_CODE => NULL,
              P_LOCATION => NULL,
              P_GET_PARENT_ONLY => 0,
              P_COMMIT => FND_API.G_TRUE,
              X_LOT_NUMBER => l_lot_number,
              X_PARENT_LOT_NUMBER => l_parent_lot_number,
              X_FAILURE_COUNT => l_failure_count
              );

           IF (l_failure_count > 0) THEN
              RAISE ISPEC_MIG_LOT;
           END IF;
         END IF;

         UPDATE gmd_inventory_spec_vrs
         SET organization_id = l_sample_organization_id,
             orgn_code = l_sample_orgn_code,
             lot_number = l_lot_number,
             parent_lot_number = l_parent_lot_number,
             subinventory = l_subinventory,
             locator_id = l_locator_id,
             out_of_spec_lot_status_id = l_out_spec_status_id,
             in_spec_lot_status_id = l_in_spec_status_id,
             migrated_ind = 1
         WHERE spec_vr_id = l_inv_spec.spec_vr_id;

         GMD_QC_MIG12.g_inv_spec_upd_count := GMD_QC_MIG12.g_inv_spec_upd_count + 1;

         EXCEPTION
           WHEN NEXT_IN_INV_LINE THEN
                 NULL;
        /*========================================
           Continue to Sample records attached
           beyond the first one.
         *========================================*/
         END;   -- end subprogram for check inv spec

        FETCH get_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

        WHILE get_sample_org%FOUND LOOP
           IF (get_sample_org%NOTFOUND) THEN
              EXIT;
           END IF;

           /*================================
              Check if combination exists
             ================================*/

           OPEN check_inv_spec;
           FETCH check_inv_spec INTO l_check_vrid;
           IF (check_inv_spec%FOUND) THEN
              CLOSE check_inv_spec;
              GOTO NEXT_SAMPLE_HEADER;
           END IF;
           CLOSE check_inv_spec;
           /*=========================================
              Convert Sample org to organization_id,
             =========================================*/
           IF (l_sample_organization_id IS NULL) THEN
              l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
              IF (l_sample_organization_id IS NULL) THEN
                 CLOSE get_sample_org;
                 RAISE ISPEC_SAMPLE_ORG_ID;
              END IF;
           END IF;


         /*===================================
            Get ODM Lot for the new orgn.
           ===================================*/
         l_item_id := NULL;
         OPEN get_spec_item_id (l_inv_spec.spec_id);
         FETCH get_spec_item_id INTO l_item_id;
         IF (get_spec_item_id%NOTFOUND) THEN
             CLOSE get_spec_item_id;
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;
         CLOSE get_spec_item_id;
         IF (l_item_id IS NULL) THEN
             RAISE ISPEC_GET_SPEC_ITEM;
         END IF;

         OPEN get_item_data;
         FETCH get_item_data INTO l_sublot_ctl;
         IF (get_item_data%NOTFOUND) THEN
             CLOSE get_item_data;
             RAISE ISPEC_GET_OPM_ITEM;
         END IF;
         CLOSE get_item_data;
         IF (l_sublot_ctl = 1 AND l_inv_spec.sublot_no IS NULL) THEN
             l_get_parent_only := 1;
         ELSE
             l_get_parent_only := 0;
         END IF;
         IF (l_get_parent_only = 1) THEN
            l_parent_lot_number := l_inv_spec.lot_no;
            l_lot_number := null;
         ELSE
            inv_opm_lot_migration.GET_ODM_LOT (
              P_MIGRATION_RUN_ID => p_migration_run_id,
              P_ORGN_CODE => l_sample_orgn_code,
              P_ITEM_ID => l_item_id,
              P_LOT_NO => l_inv_spec.lot_no,
              P_SUBLOT_NO => l_inv_spec.sublot_no,
              P_WHSE_CODE => NULL,
              P_LOCATION => NULL,
              P_GET_PARENT_ONLY => 0,
              P_COMMIT => FND_API.G_TRUE,
              X_LOT_NUMBER => l_lot_number,
              X_PARENT_LOT_NUMBER => l_parent_lot_number,
              X_FAILURE_COUNT => l_failure_count
              );

           IF (l_failure_count > 0) THEN
              RAISE ISPEC_MIG_LOT;
           END IF;
         END IF;

         /*================================
            Clone the record.
            Note erecord field assignment.
           ================================*/

         IF (l_inv_spec.text_code IS NOT NULL AND  l_inv_spec.text_code > 0) THEN
            l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_inv_spec.text_code, p_migration_run_id);
         ELSE
            l_text_code := NULL;
         END IF;

         INSERT INTO gmd_inventory_spec_vrs (
         SPEC_VR_ID,
         SPEC_ID,
         ORGN_CODE,
         LOT_ID,
         LOT_NO,
         SUBLOT_NO,
         WHSE_CODE,
         LOCATION,
         SPEC_VR_STATUS,
         START_DATE,
         END_DATE,
         SAMPLING_PLAN_ID,
         SAMPLE_INV_TRANS_IND,
         CONTROL_LOT_ATTRIB_IND,
         LOT_OPTIONAL_ON_SAMPLE,
         IN_SPEC_LOT_STATUS,
         OUT_OF_SPEC_LOT_STATUS,
         CONTROL_BATCH_STEP_IND,
         COA_TYPE,
         COA_AT_SHIP_IND,
         COA_AT_INVOICE_IND,
         COA_REQ_FROM_SUPL_IND,
         DELETE_MARK,
         TEXT_CODE,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
         ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
         ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21,
         ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28,
         ATTRIBUTE29, ATTRIBUTE30,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         AUTO_SAMPLE_IND,
         DELAYED_LOT_ENTRY,
         MIGRATED_IND,
         ERECORD_SPEC_VR_ID,
         ORGANIZATION_ID,
         LOT_NUMBER,
         PARENT_LOT_NUMBER,
         SUBINVENTORY,
         LOCATOR_ID,
         OUT_OF_SPEC_LOT_STATUS_ID,
         IN_SPEC_LOT_STATUS_ID
         )
         VALUES
         (
         gmd_qc_spec_vr_id_s.nextval,
         l_inv_spec.SPEC_ID,
         l_sample_orgn_code,
         l_inv_spec.LOT_ID,
         l_inv_spec.LOT_NO,
         l_inv_spec.SUBLOT_NO,
         l_inv_spec.WHSE_CODE,
         l_inv_spec.LOCATION,
         l_inv_spec.SPEC_VR_STATUS,
         l_inv_spec.START_DATE,
         l_inv_spec.END_DATE,
         l_inv_spec.SAMPLING_PLAN_ID,
         l_inv_spec.SAMPLE_INV_TRANS_IND,
         l_inv_spec.CONTROL_LOT_ATTRIB_IND,
         l_inv_spec.LOT_OPTIONAL_ON_SAMPLE,
         l_inv_spec.IN_SPEC_LOT_STATUS,
         l_inv_spec.OUT_OF_SPEC_LOT_STATUS,
         l_inv_spec.CONTROL_BATCH_STEP_IND,
         l_inv_spec.COA_TYPE,
         l_inv_spec.COA_AT_SHIP_IND,
         l_inv_spec.COA_AT_INVOICE_IND,
         l_inv_spec.COA_REQ_FROM_SUPL_IND,
         l_inv_spec.DELETE_MARK,
         l_text_code,
         l_inv_spec.ATTRIBUTE_CATEGORY,
         l_inv_spec.ATTRIBUTE1, l_inv_spec.ATTRIBUTE2, l_inv_spec.ATTRIBUTE3, l_inv_spec.ATTRIBUTE4,
         l_inv_spec.ATTRIBUTE5, l_inv_spec.ATTRIBUTE6, l_inv_spec.ATTRIBUTE7, l_inv_spec.ATTRIBUTE8,
         l_inv_spec.ATTRIBUTE9, l_inv_spec.ATTRIBUTE10, l_inv_spec.ATTRIBUTE11, l_inv_spec.ATTRIBUTE12,
         l_inv_spec.ATTRIBUTE13, l_inv_spec.ATTRIBUTE14, l_inv_spec.ATTRIBUTE15, l_inv_spec.ATTRIBUTE16,
         l_inv_spec.ATTRIBUTE17, l_inv_spec.ATTRIBUTE18, l_inv_spec.ATTRIBUTE19, l_inv_spec.ATTRIBUTE20,
         l_inv_spec.ATTRIBUTE21, l_inv_spec.ATTRIBUTE22, l_inv_spec.ATTRIBUTE23, l_inv_spec.ATTRIBUTE24,
         l_inv_spec.ATTRIBUTE25, l_inv_spec.ATTRIBUTE26, l_inv_spec.ATTRIBUTE27, l_inv_spec.ATTRIBUTE28,
         l_inv_spec.ATTRIBUTE29, l_inv_spec.ATTRIBUTE30,
         SYSDATE,
         0,
         0,
         SYSDATE,
         NULL,
         l_inv_spec.AUTO_SAMPLE_IND,
         l_inv_spec.DELAYED_LOT_ENTRY,
         1,
         l_inv_spec.SPEC_VR_ID,
         l_sample_organization_id,
         l_lot_number,
         l_parent_lot_number,
         l_subinventory,
         l_locator_id,
         l_out_spec_status_id,
         l_in_spec_status_id
         );

         GMD_QC_MIG12.g_inv_spec_ins_count := GMD_QC_MIG12.g_inv_spec_ins_count + 1;

<<NEXT_SAMPLE_HEADER>>

            FETCH get_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

         END LOOP;         -- get_sample_org

         CLOSE get_sample_org;

         IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
         END IF;

      END IF;       -- clone endif

EXCEPTION

     WHEN ISPEC_NO_ORG THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => p_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_ERROR,
              p_message_token   => 'GMD_MIG_NO_ORG',
              p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
              p_token1          => 'ORG',
              p_token2          => 'ONAME',
              p_token3          => 'ROWK',
              p_token4          => 'ROWV',
              p_param1          => l_inv_spec.orgn_code,
              p_param2          => 'ORGN_CODE',
	      p_param3          => 'SPEC_VR_ID',
	      p_param4          => to_char(l_inv_spec.spec_vr_id),
              p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
      x_exception_count := x_exception_count + 1;


     WHEN ISPEC_WHSE_ERROR THEN

        GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_WHSE_ERROR',
	       p_table_name      => NULL,
               p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => l_inv_spec.whse_code,
	       p_param2          => 'WHSE_CODE',
	       p_param3          => 'SPEC_VR_ID',
	       p_param4          => to_char(l_inv_spec.spec_vr_id),
	       p_app_short_name  => 'GMD');
            ROLLBACK;
            GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
            x_exception_count := x_exception_count + 1;

     WHEN ISPEC_SUB_MISMATCH THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                       p_run_id          => p_migration_run_id,
                       p_log_level       => FND_LOG.LEVEL_ERROR,
                       p_message_token   => 'GMD_MIG_ISPEC_SUB_MISMATCH',
                       p_table_name      => NULL,
                       p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                       p_token1          => 'VRID',
                       p_token2          => 'ORG',
                       p_token3          => 'WHSE',
                       p_token4          => 'ORGID',
                       p_token5          => 'WHSEID',
                       p_param1          => to_char(l_inv_spec.spec_vr_id),
                       p_param2          => l_inv_spec.orgn_code,
                       p_param3          => l_inv_spec.whse_code,
                       p_param4          => to_char(l_organization_id),
                       p_param5          => to_char(ls_organization_id),
                       p_app_short_name  => 'GMD');
                ROLLBACK;
                GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
                x_exception_count := x_exception_count + 1;

     WHEN ISPEC_NON_LOC THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                         p_run_id          => p_migration_run_id,
	                 p_log_level       => FND_LOG.LEVEL_ERROR,
	                 p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
                         p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	                 p_token1          => 'ROWK',
	                 p_token2          => 'ROWV',
	                 p_token3          => 'FNAME',
	                 p_param1          => 'SPEC_VR_ID',
	                 p_param2          => to_char(l_inv_spec.spec_vr_id),
	                 p_param3          => 'LOCATION',
	                 p_app_short_name  => 'GMD');
                      GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
                      x_exception_count := x_exception_count + 1;



     WHEN ISPEC_LOCATOR_ID THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                       p_run_id          => p_migration_run_id,
                       p_log_level       => FND_LOG.LEVEL_ERROR,
                       p_message_token   => 'GMD_MIG_LOCATOR_ID',
                       p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                       p_token1          => 'WHSE',
                       p_token2          => 'LOCATION',
                       p_token3          => 'LFIELD',
                       p_token4          => 'ROWK',
                       p_token5          => 'ROWV',
                       p_param1          => l_inv_spec.whse_code,
                       p_param2          => l_inv_spec.location,
                       p_param3          => 'LOCATION',
	               p_param4          => 'SPEC_VR_ID',
	               p_param5          => to_char(l_inv_spec.spec_vr_id),
                       p_app_short_name  => 'GMD');
                 ROLLBACK;
                 GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
                 x_exception_count := x_exception_count + 1;


     WHEN ISPEC_SUBINV THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                       p_run_id          => p_migration_run_id,
	               p_log_level       => FND_LOG.LEVEL_ERROR,
	               p_message_token   => 'GMD_MIG_SUBINV',
                       p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
          	       p_token1          => 'LOCATOR',
          	       p_token2          => 'ROWK',
          	       p_token3          => 'ROWV',
	               p_param1          => to_char(l_locator_id),
	               p_param2          => 'SPEC_VR_ID',
	               p_param3          => to_char(l_inv_spec.spec_vr_id),
                       p_app_short_name  => 'GMD');
                ROLLBACK;
                GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
                x_exception_count := x_exception_count + 1;


     WHEN ISPEC_GET_OPM_LOT THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_GET_OPM_LOT',
                 p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                 p_token1          => 'LOTID',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => to_char(l_inv_spec.lot_id),
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_inv_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
          ROLLBACK;
          GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
          x_exception_count := x_exception_count + 1;

     WHEN ISPEC_GET_SPEC_ITEM THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_GET_ITEM_SPEC',
                 p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                 p_token1          => 'SPECID',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => to_char(l_inv_spec.spec_id),
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_inv_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
          ROLLBACK;
          GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
          x_exception_count := x_exception_count + 1;


     WHEN ISPEC_GET_OPM_ITEM THEN
             GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_OPM_ITEM',
               p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	       p_token1          => 'ITEMID',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => to_char(l_item_id),
               p_param2          => 'SPEC_VR_ID',
               p_param3          => to_char(l_inv_spec.spec_vr_id),
	       p_app_short_name  => 'GMD');
             ROLLBACK;
             GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
             x_exception_count := x_exception_count + 1;


     WHEN ISPEC_MIG_LOT THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => p_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_ERROR,
                   p_message_token   => 'GMD_MIG_LOT',
                   p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                   p_token1          => 'ROWK',
                   p_token2          => 'ROWV',
                   p_param1          => 'SPEC_VR_ID',
                   p_param2          => to_char(l_inv_spec.spec_vr_id),
                   p_app_short_name  => 'GMD');
           ROLLBACK;
           GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
           x_exception_count := x_exception_count + 1;


     WHEN ISPEC_IN_STATUS THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_STATUS_ID',
                 p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                 p_token1          => 'STAT',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => l_inv_spec.in_spec_lot_status,
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_inv_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
         ROLLBACK;
         GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
         x_exception_count := x_exception_count + 1;


     WHEN ISPEC_OUT_STATUS THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_STATUS_ID',
                 p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
                 p_token1          => 'STAT',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => l_inv_spec.out_of_spec_lot_status,
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_inv_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
         ROLLBACK;
         GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
         x_exception_count := x_exception_count + 1;

     WHEN ISPEC_DELETE_INVSPEC THEN
        NULL;

     WHEN ISPEC_SAMPLE_ORG THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                     p_run_id          => p_migration_run_id,
	             p_log_level       => FND_LOG.LEVEL_ERROR,
	             p_message_token   => 'GMD_MIG_NULL_ORG_ID',
	             p_table_name      => NULL,
                     p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	             p_token1          => 'ORG',
	             p_token2          => 'ROWK',
	             p_token3          => 'ROWV',
	             p_param1          => l_sample_orgn_code,
	             p_param2          => 'SPEC_VR_ID',
	             p_param3          => to_char(l_inv_spec.spec_vr_id),
	             p_app_short_name  => 'GMD');
               ROLLBACK;
               GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
               x_exception_count := x_exception_count + 1;


     WHEN ISPEC_SAMPLE_ORG_ID THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
                       p_run_id          => p_migration_run_id,
    	               p_log_level       => FND_LOG.LEVEL_ERROR,
  	               p_message_token   => 'GMD_MIG_NULL_ORG_ID',
	               p_table_name      => NULL,
                       p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
	               p_token1          => 'ORG',
	               p_token2          => 'ROWK',
	               p_token3          => 'ROWV',
	               p_param1          => l_sample_orgn_code,
	               p_param2          => 'SPEC_VR_ID',
	               p_param3          => to_char(l_inv_spec.spec_vr_id),
	               p_app_short_name  => 'GMD');
                 ROLLBACK;
                 GMD_QC_MIG12.g_inv_spec_err_count := GMD_QC_MIG12.g_inv_spec_err_count + 1;
                 x_exception_count := x_exception_count + 1;

     WHEN OTHERS THEN
        LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
        GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Specifications - gmd_inventory_spec_vrs',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
        ROLLBACK;
        x_exception_count := x_exception_count + 1;

   END;    -- end inv spec subprogram

END LOOP;   -- end of get_inv_spec loop



/*==============================================
   Log end of gmd_inventory_spec_vrs migration.
  ==============================================*/

LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*================================
   Migrate gmd_wip_spec_vrs.
  ================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_WIP_SPEC_VRS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_WIP_SPEC_VRS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 3;
GMD_QC_MIG12.g_wip_spec_pro_count := 0;
GMD_QC_MIG12.g_wip_spec_ins_count := 0;
GMD_QC_MIG12.g_wip_spec_del_count := 0;
GMD_QC_MIG12.g_wip_spec_upd_count := 0;
GMD_QC_MIG12.g_wip_spec_err_count := 0;

FOR l_wip_spec IN get_wip_spec LOOP
   BEGIN   -- wip spec subprogram
   GMD_QC_MIG12.g_wip_spec_pro_count := GMD_QC_MIG12.g_wip_spec_pro_count + 1;
   /*===============================
        Migrate orgn_code.
     ===============================*/

   -- Bug# 5438990
   -- Added IF condition to check if orgn_code is not null
   IF l_wip_spec.orgn_code IS NOT NULL THEN
      l_wip_org_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_wip_spec.orgn_code);
      IF (l_wip_org_id IS NULL) THEN
         RAISE WIP_NO_ORG;
      END IF;
   END IF;

   /*=====================================
        Get Status Ids.
     =====================================*/

   IF (l_wip_spec.in_spec_lot_status IS NULL) THEN
      l_in_spec_status_id := NULL;
   ELSE
      l_in_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_wip_spec.in_spec_lot_status);
      IF (l_in_spec_status_id IS NULL) THEN
         RAISE WIP_IN_STATUS;
      END IF;
   END IF;

   IF (l_wip_spec.out_of_spec_lot_status IS NULL) THEN
      l_out_spec_status_id := NULL;
   ELSE
      l_out_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_wip_spec.out_of_spec_lot_status);
      IF (l_out_spec_status_id IS NULL) THEN
         RAISE WIP_OUT_STATUS;
      END IF;
   END IF;

   -- Bug# 5482253
   -- Added code to populate material_detail_id so that Line and Type fields are populated when queried from the applications
   l_material_detail_id := NULL;
   IF l_wip_spec.batch_id IS NOT NULL AND l_wip_spec.formulaline_id IS NOT NULL THEN
      BEGIN
         SELECT material_detail_id INTO l_material_detail_id
         FROM gme_material_details
         WHERE batch_id = l_wip_spec.batch_id
         AND formulaline_id = l_wip_spec.formulaline_id;
      EXCEPTION
         WHEN OTHERS THEN
            l_material_detail_id := NULL;
      END;
   END IF;

   /*=====================================
       Set Organization id.
     =====================================*/

   IF (l_wip_spec.orgn_code IS NOT NULL) THEN
      l_organization_id :=  l_wip_org_id;
      /*=====================================
          Update gmd_wip_spec_vrs.
        =====================================*/
      UPDATE gmd_wip_spec_vrs
      SET out_of_spec_lot_status_id = l_out_spec_status_id,
          in_spec_lot_status_id = l_in_spec_status_id,
          organization_id = l_organization_id,
	  material_detail_id = l_material_detail_id, -- Bug# 5482253
          migrated_ind = 1
      WHERE spec_vr_id = l_wip_spec.spec_vr_id;

      GMD_QC_MIG12.g_wip_spec_upd_count := GMD_QC_MIG12.g_wip_spec_upd_count + 1;

      IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
      END IF;

   ELSE            -- org is null
        /*=====================================
           Loop and get all samples orgs that
           the Wip validity rule is tied to.
          =====================================*/
        OPEN get_wip_sample_org (l_wip_spec.spec_vr_id);
        FETCH get_wip_sample_org INTO l_sample_orgn_code, l_sample_organization_id;
        IF (get_wip_sample_org%NOTFOUND) THEN
            CLOSE get_wip_sample_org;
            /*========================================
               Log the spec record and Delete it.
             ========================================*/

            /*==========================================
               This is not marked as an error.
              ==========================================*/

            DELETE gmd_wip_spec_vrs
            WHERE spec_vr_id = l_wip_spec.spec_vr_id;

            IF (p_commit = FND_API.G_TRUE) THEN
               COMMIT;
            END IF;

            GMD_QC_MIG12.g_wip_spec_del_count := GMD_QC_MIG12.g_wip_spec_del_count + 1;

            RAISE WIP_SPEC_DELETE;

        END IF ;

        /*================================
           Check if combination exists
           for first sample orgn_code.
          ================================*/
         BEGIN     -- subprogram for check wip spec
         OPEN check_wip_spec;
         FETCH check_wip_spec INTO l_check_vrid;
         IF (check_wip_spec%FOUND) THEN
            CLOSE check_wip_spec;
            RAISE NEXT_IN_WIP_LINE;
         END IF;
         CLOSE check_wip_spec;

        /*=========================================
           Convert Sample org to organization_id,
          =========================================*/
        IF (l_sample_organization_id IS NULL) THEN
            l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
        END IF;

        IF (l_sample_organization_id IS NULL) THEN
            CLOSE get_wip_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_wip_sample_org
            RAISE WIP_SAMPLE_ORG;
         END IF;

         /*=====================================
             Update gmd_wip_spec_vrs.
           =====================================*/
         UPDATE gmd_wip_spec_vrs
         SET out_of_spec_lot_status_id = l_out_spec_status_id,
             in_spec_lot_status_id = l_in_spec_status_id,
             organization_id = l_sample_organization_id,
             orgn_code = l_sample_orgn_code,
	     material_detail_id = l_material_detail_id, -- Bug# 5482253
             migrated_ind = 1
         WHERE spec_vr_id = l_wip_spec.spec_vr_id;

         GMD_QC_MIG12.g_wip_spec_upd_count := GMD_QC_MIG12.g_wip_spec_upd_count + 1;

         EXCEPTION
           WHEN NEXT_IN_WIP_LINE THEN
                 NULL;

         END;      -- end subprogram for check wip spec

        FETCH get_wip_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

        WHILE get_wip_sample_org%FOUND LOOP
            IF (get_wip_sample_org%NOTFOUND) THEN
               EXIT;
            END IF;
            /*================================
               Check if combination exists
              ================================*/
            OPEN check_wip_spec;
            FETCH check_wip_spec INTO l_check_vrid;
            IF (check_wip_spec%FOUND) THEN
               CLOSE check_wip_spec;
               GOTO NEXT_WIP_SAMPLE_HEADER;
            END IF;
            CLOSE check_wip_spec;

            /*================================
               Convert the Sample Org.
              ================================*/

            IF (l_sample_organization_id IS NULL) THEN
               l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
               IF (l_sample_organization_id IS NULL) THEN
                  CLOSE get_wip_sample_org;
                  RAISE WIP_SAMPLE_ORG_ID;
               END IF;
            END IF;

           /*==============================================
              Clone the null orgn_code record using the
              Sample orgn_code.
             ==============================================*/
           IF (l_wip_spec.text_code IS NOT NULL AND  l_wip_spec.text_code > 0) THEN
              l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_wip_spec.text_code, p_migration_run_id);
           ELSE
              l_text_code := NULL;
           END IF;

           INSERT INTO gmd_wip_spec_vrs
           (
           SPEC_VR_ID,
           SPEC_ID,
           ORGN_CODE,
           BATCH_ID,
           RECIPE_ID,
           RECIPE_NO,
           RECIPE_VERSION,
           FORMULA_ID,
           FORMULALINE_ID,
           FORMULA_NO,
           FORMULA_VERS,
           ROUTING_ID,
           ROUTING_NO,
           ROUTING_VERS,
           STEP_ID,
           STEP_NO,
           OPRN_ID,
           OPRN_NO,
           OPRN_VERS,
           CHARGE,
           SPEC_VR_STATUS,
           START_DATE,
           END_DATE,
           SAMPLING_PLAN_ID,
           SAMPLE_INV_TRANS_IND,
           LOT_OPTIONAL_ON_SAMPLE,
           CONTROL_LOT_ATTRIB_IND,
           OUT_OF_SPEC_LOT_STATUS,
           IN_SPEC_LOT_STATUS,
           COA_TYPE,
           CONTROL_BATCH_STEP_IND,
           COA_AT_SHIP_IND,
           COA_AT_INVOICE_IND,
           COA_REQ_FROM_SUPL_IND,
           DELETE_MARK,
           TEXT_CODE,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
           ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
           ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21,
           ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28,
           ATTRIBUTE29, ATTRIBUTE30,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           AUTO_SAMPLE_IND,
           DELAYED_LOT_ENTRY,
           MIGRATED_IND,
           ERECORD_SPEC_VR_ID,
           ORGANIZATION_ID,
           OUT_OF_SPEC_LOT_STATUS_ID,
           IN_SPEC_LOT_STATUS_ID,
	   MATERIAL_DETAIL_ID -- Bug# 5482253
           )
           VALUES
           (
           gmd_qc_spec_vr_id_s.nextval,
           l_wip_spec.SPEC_ID,
	   l_sample_orgn_code,
           l_wip_spec.BATCH_ID,
           l_wip_spec.RECIPE_ID,
           l_wip_spec.RECIPE_NO,
           l_wip_spec.RECIPE_VERSION,
           l_wip_spec.FORMULA_ID,
           l_wip_spec.FORMULALINE_ID,
           l_wip_spec.FORMULA_NO,
           l_wip_spec.FORMULA_VERS,
           l_wip_spec.ROUTING_ID,
           l_wip_spec.ROUTING_NO,
           l_wip_spec.ROUTING_VERS,
           l_wip_spec.STEP_ID,
           l_wip_spec.STEP_NO,
           l_wip_spec.OPRN_ID,
           l_wip_spec.OPRN_NO,
           l_wip_spec.OPRN_VERS,
           l_wip_spec.CHARGE,
           l_wip_spec.SPEC_VR_STATUS,
           l_wip_spec.START_DATE,
           l_wip_spec.END_DATE,
           l_wip_spec.SAMPLING_PLAN_ID,
           l_wip_spec.SAMPLE_INV_TRANS_IND,
           l_wip_spec.LOT_OPTIONAL_ON_SAMPLE,
           l_wip_spec.CONTROL_LOT_ATTRIB_IND,
           l_wip_spec.OUT_OF_SPEC_LOT_STATUS,
           l_wip_spec.IN_SPEC_LOT_STATUS,
           l_wip_spec.COA_TYPE,
           l_wip_spec.CONTROL_BATCH_STEP_IND,
           l_wip_spec.COA_AT_SHIP_IND,
           l_wip_spec.COA_AT_INVOICE_IND,
           l_wip_spec.COA_REQ_FROM_SUPL_IND,
           l_wip_spec.DELETE_MARK,
           l_text_code,
           l_wip_spec.ATTRIBUTE_CATEGORY,
           l_wip_spec.ATTRIBUTE1, l_wip_spec.ATTRIBUTE2, l_wip_spec.ATTRIBUTE3, l_wip_spec.ATTRIBUTE4,
           l_wip_spec.ATTRIBUTE5, l_wip_spec.ATTRIBUTE6, l_wip_spec.ATTRIBUTE7, l_wip_spec.ATTRIBUTE8,
           l_wip_spec.ATTRIBUTE9, l_wip_spec.ATTRIBUTE10, l_wip_spec.ATTRIBUTE11, l_wip_spec.ATTRIBUTE12,
           l_wip_spec.ATTRIBUTE13, l_wip_spec.ATTRIBUTE14, l_wip_spec.ATTRIBUTE15, l_wip_spec.ATTRIBUTE16,
           l_wip_spec.ATTRIBUTE17, l_wip_spec.ATTRIBUTE18, l_wip_spec.ATTRIBUTE19, l_wip_spec.ATTRIBUTE20,
           l_wip_spec.ATTRIBUTE21, l_wip_spec.ATTRIBUTE22, l_wip_spec.ATTRIBUTE23, l_wip_spec.ATTRIBUTE24,
           l_wip_spec.ATTRIBUTE25, l_wip_spec.ATTRIBUTE26, l_wip_spec.ATTRIBUTE27, l_wip_spec.ATTRIBUTE28,
           l_wip_spec.ATTRIBUTE29, l_wip_spec.ATTRIBUTE30,
           SYSDATE,
           0,
           0,
           SYSDATE,
           NULL,
           l_wip_spec.AUTO_SAMPLE_IND,
           l_wip_spec.DELAYED_LOT_ENTRY,
           1,
           l_wip_spec.SPEC_VR_ID,
           l_sample_organization_id,
           l_out_spec_status_id,
           l_in_spec_status_id,
	   l_material_detail_id -- Bug# 5482253
           );

           GMD_QC_MIG12.g_wip_spec_ins_count := GMD_QC_MIG12.g_wip_spec_ins_count + 1;

   << NEXT_WIP_SAMPLE_HEADER >>

           FETCH get_wip_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

        END LOOP;

        CLOSE get_wip_sample_org;

     END IF;  -- org is null

   EXCEPTION

     WHEN WIP_NO_ORG THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => p_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_ERROR,
              p_message_token   => 'GMD_MIG_NO_ORG',
              p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
              p_token1          => 'ORG',
              p_token2          => 'ONAME',
              p_token3          => 'ROWK',
              p_token4          => 'ROWV',
              p_param1          => l_wip_spec.orgn_code,
              p_param2          => 'ORGN_CODE',
              p_param3          => 'SPEC_VR_ID',
              p_param4          => to_char(l_wip_spec.spec_vr_id),
              p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_wip_spec_err_count := GMD_QC_MIG12.g_wip_spec_err_count + 1;
      x_exception_count := x_exception_count + 1;

     WHEN WIP_IN_STATUS THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_STATUS_ID',
                 p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
                 p_token1          => 'STAT',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => l_wip_spec.in_spec_lot_status,
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_wip_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_wip_spec_err_count := GMD_QC_MIG12.g_wip_spec_err_count + 1;
         x_exception_count := x_exception_count + 1;


     WHEN WIP_OUT_STATUS THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_STATUS_ID',
                 p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
                 p_token1          => 'STAT',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => l_wip_spec.out_of_spec_lot_status,
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_wip_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_wip_spec_err_count := GMD_QC_MIG12.g_wip_spec_err_count + 1;
         x_exception_count := x_exception_count + 1;


     WHEN WIP_SPEC_DELETE THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
	         p_log_level       => FND_LOG.LEVEL_EVENT,
	         p_message_token   => 'GMD_MIG_COMMON_SPEC_DELETE',
	         p_table_name      => NULL,
                 p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
                 p_token1          => 'TAB',
                 p_param1          => 'gmd_wip_spec_vrs',
	         p_app_short_name  => 'GMD');

     WHEN WIP_SAMPLE_ORG THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
                  p_run_id          => p_migration_run_id,
    	          p_log_level       => FND_LOG.LEVEL_ERROR,
                  p_message_token   => 'GMD_MIG_NULL_ORG_ID',
                  p_table_name      => NULL,
                  p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
	          p_token1          => 'ORG',
	          p_token2          => 'ROWK',
	          p_token3          => 'ROWV',
	          p_param1          => l_sample_orgn_code,
	          p_param2          => 'SPEC_VR_ID',
	          p_param3          => to_char(l_wip_spec.spec_vr_id),
	          p_app_short_name  => 'GMD');
            GMD_QC_MIG12.g_wip_spec_err_count := GMD_QC_MIG12.g_wip_spec_err_count + 1;
            x_exception_count := x_exception_count + 1;

     WHEN WIP_SAMPLE_ORG_ID THEN
       GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => p_migration_run_id,
	                p_log_level       => FND_LOG.LEVEL_ERROR,
                        p_message_token   => 'GMD_MIG_NULL_ORG_ID',
	                p_table_name      => NULL,
                        p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
	                p_token1          => 'ORG',
	                p_token2          => 'ROWK',
	                p_token3          => 'ROWV',
	                p_param1          => l_sample_orgn_code,
	                p_param2          => 'SPEC_VR_ID',
	                p_param3          => to_char(l_wip_spec.spec_vr_id),
	                p_app_short_name  => 'GMD');
                  GMD_QC_MIG12.g_wip_spec_err_count := GMD_QC_MIG12.g_wip_spec_err_count + 1;
                  x_exception_count := x_exception_count + 1;


     WHEN OTHERS THEN
        LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
        GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Specifications - gmd_wip_spec_vrs',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
        ROLLBACK;
        x_exception_count := x_exception_count + 1;

   END;    -- wip spec subprogram


END LOOP;    -- get_wip_spec



/*==============================================
   Log end of gmd_wip_spec_vrs migration.
  ==============================================*/

LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

/*=======================================
   Migrate gmd_customer_spec_vrs.
  =======================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_CUSTOMER_SPEC_VRS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_CUSTOMER_SPEC_VRS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 4;
GMD_QC_MIG12.g_cust_spec_pro_count := 0;
GMD_QC_MIG12.g_cust_spec_ins_count := 0;
GMD_QC_MIG12.g_cust_spec_del_count := 0;
GMD_QC_MIG12.g_cust_spec_upd_count := 0;
GMD_QC_MIG12.g_cust_spec_err_count := 0;

FOR l_cust_spec IN get_cust_spec LOOP
   BEGIN    -- cust spec subprogram
   GMD_QC_MIG12.g_cust_spec_pro_count := GMD_QC_MIG12.g_cust_spec_pro_count + 1;
   IF (l_cust_spec.organization_id IS NULL and l_cust_spec.orgn_code IS NOT NULL) THEN
      RAISE CUST_NO_ORG;
   END IF;

   IF (l_cust_spec.organization_id IS NOT NULL) THEN
      /*====================================
         Update gmd_customer_spec_vrs.
        ====================================*/
      UPDATE gmd_customer_spec_vrs
      SET    migrated_ind = 1
      WHERE  spec_vr_id = l_cust_spec.spec_vr_id;

      IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
      END IF;

      GMD_QC_MIG12.g_cust_spec_upd_count := GMD_QC_MIG12.g_cust_spec_upd_count + 1;

   ELSE        -- org is null
       /*=======================================
          Loop and get all samples orgs that
          the Customer validity rule is tied to.
         =======================================*/
       OPEN get_cust_sample_org (l_cust_spec.spec_vr_id);
       FETCH get_cust_sample_org INTO l_sample_orgn_code, l_sample_organization_id;
       IF (get_cust_sample_org%NOTFOUND) THEN
            CLOSE get_cust_sample_org;
            /*========================================
               Log the spec record and Delete it.
             ========================================*/

            /*==========================================
               This is not marked as an error.
              ==========================================*/

            DELETE gmd_customer_spec_vrs
            WHERE spec_vr_id = l_wip_spec.spec_vr_id;

            IF (p_commit = FND_API.G_TRUE) THEN
               COMMIT;
            END IF;

            GMD_QC_MIG12.g_cust_spec_del_count := GMD_QC_MIG12.g_cust_spec_del_count + 1;
            RAISE CUST_SPEC_DELETE;
       END IF ;

       /*================================
          Check if combination exists
          for first sample related record.
         ================================*/
       BEGIN      -- subprogram for check cust spec.
       OPEN check_cust_spec;
       FETCH check_cust_spec INTO l_check_vrid;
       IF (check_cust_spec%FOUND) THEN
          CLOSE check_cust_spec;
          RAISE NEXT_IN_CUST_LINE;
       END IF;
       CLOSE check_cust_spec;

       /*================================
          Convert the Sample Org.
         ================================*/
       IF (l_sample_organization_id IS NULL) THEN
          l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
          IF (l_sample_organization_id IS NULL) THEN
             CLOSE get_cust_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_cust_sample_org
             RAISE CUST_NO_ORG_ID;
          END IF;
       END IF;

      /*=====================================
          Update gmd_customer_spec_vrs.
        =====================================*/
      UPDATE gmd_customer_spec_vrs
      SET orgn_code = l_sample_orgn_code,
          organization_id = l_sample_organization_id,
          migrated_ind = 1
      WHERE spec_vr_id = l_cust_spec.spec_vr_id;

      GMD_QC_MIG12.g_cust_spec_upd_count := GMD_QC_MIG12.g_cust_spec_upd_count + 1;

     EXCEPTION

      WHEN NEXT_IN_CUST_LINE THEN
                 NULL;

     WHEN OTHERS THEN
        LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
        GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Specifications - gmd_customer_spec_vrs',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
        ROLLBACK;
        x_exception_count := x_exception_count + 1;


       END;       -- end subprogram for check cust spec.

       FETCH get_cust_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

       WHILE get_cust_sample_org%FOUND LOOP
          /*================================
             Check if combination exists
            ================================*/
          IF (get_cust_sample_org%NOTFOUND) THEN
              EXIT;
          END IF;
          OPEN check_cust_spec;
          FETCH check_cust_spec INTO l_check_vrid;
          IF (check_cust_spec%FOUND) THEN
             CLOSE check_cust_spec;
             GOTO NEXT_CUST_SAMPLE;
          END IF;
          CLOSE check_cust_spec;
          /*================================
             Convert the Sample Org.
            ================================*/
          IF (l_sample_organization_id IS NULL) THEN
             l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
             IF (l_sample_organization_id IS NULL) THEN
                CLOSE get_cust_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_cust_sample_org
                RAISE CUST_NO_ORG_ID;
             END IF;
          END IF;

          /*===========================
               Clone the record.
            ===========================*/
          IF (l_cust_spec.text_code IS NOT NULL AND  l_cust_spec.text_code > 0) THEN
              l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_cust_spec.text_code, p_migration_run_id);
          ELSE
              l_text_code := NULL;
          END IF;

          INSERT INTO gmd_customer_spec_vrs
          (
          SPEC_VR_ID,
          SPEC_ID,
          ORGN_CODE,
          CUST_ID,
          ORDER_ID,
          ORDER_LINE,
          ORDER_LINE_ID,
          SHIP_TO_SITE_ID,
          ORG_ID,
          SPEC_VR_STATUS,
          START_DATE,
          END_DATE,
          SAMPLING_PLAN_ID,
          SAMPLE_INV_TRANS_IND,
          LOT_OPTIONAL_ON_SAMPLE,
          COA_TYPE,
          COA_AT_SHIP_IND,
          COA_AT_INVOICE_IND,
          COA_REQ_FROM_SUPL_IND,
          DELETE_MARK,
          TEXT_CODE,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
          ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
          ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21,
          ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28,
          ATTRIBUTE29, ATTRIBUTE30,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          MIGRATED_IND,
          ERECORD_SPEC_VR_ID,
          ORGANIZATION_ID
          )
          VALUES
          (
          gmd_qc_spec_vr_id_s.nextval,
          l_cust_spec.SPEC_ID,
          l_sample_orgn_code,
          l_cust_spec.CUST_ID,
          l_cust_spec.ORDER_ID,
          l_cust_spec.ORDER_LINE,
          l_cust_spec.ORDER_LINE_ID,
          l_cust_spec.SHIP_TO_SITE_ID,
          l_cust_spec.ORG_ID,
          l_cust_spec.SPEC_VR_STATUS,
          l_cust_spec.START_DATE,
          l_cust_spec.END_DATE,
          l_cust_spec.SAMPLING_PLAN_ID,
          l_cust_spec.SAMPLE_INV_TRANS_IND,
          l_cust_spec.LOT_OPTIONAL_ON_SAMPLE,
          l_cust_spec.COA_TYPE,
          l_cust_spec.COA_AT_SHIP_IND,
          l_cust_spec.COA_AT_INVOICE_IND,
          l_cust_spec.COA_REQ_FROM_SUPL_IND,
          l_cust_spec.DELETE_MARK,
          l_text_code,
          l_cust_spec.ATTRIBUTE_CATEGORY,
          l_cust_spec.ATTRIBUTE1, l_cust_spec.ATTRIBUTE2, l_cust_spec.ATTRIBUTE3, l_cust_spec.ATTRIBUTE4,
          l_cust_spec.ATTRIBUTE5, l_cust_spec.ATTRIBUTE6, l_cust_spec.ATTRIBUTE7, l_cust_spec.ATTRIBUTE8,
          l_cust_spec.ATTRIBUTE9, l_cust_spec.ATTRIBUTE10, l_cust_spec.ATTRIBUTE11, l_cust_spec.ATTRIBUTE12,
          l_cust_spec.ATTRIBUTE13, l_cust_spec.ATTRIBUTE14, l_cust_spec.ATTRIBUTE15, l_cust_spec.ATTRIBUTE16,
          l_cust_spec.ATTRIBUTE17, l_cust_spec.ATTRIBUTE18, l_cust_spec.ATTRIBUTE19, l_cust_spec.ATTRIBUTE20,
          l_cust_spec.ATTRIBUTE21, l_cust_spec.ATTRIBUTE22, l_cust_spec.ATTRIBUTE23, l_cust_spec.ATTRIBUTE24,
          l_cust_spec.ATTRIBUTE25, l_cust_spec.ATTRIBUTE26, l_cust_spec.ATTRIBUTE27, l_cust_spec.ATTRIBUTE28,
          l_cust_spec.ATTRIBUTE29, l_cust_spec.ATTRIBUTE30,
          SYSDATE,
          0,
          0,
          SYSDATE,
          NULL,
          1,
          l_cust_spec.SPEC_VR_ID,
          l_sample_organization_id
          );

          GMD_QC_MIG12.g_cust_spec_ins_count := GMD_QC_MIG12.g_cust_spec_ins_count + 1;

<< NEXT_CUST_SAMPLE>>

          FETCH get_cust_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

       END LOOP;

       CLOSE get_cust_sample_org; -- Bug# 5554719

   END IF;   -- orgn code is null check

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;

   EXCEPTION

   WHEN CUST_NO_ORG THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => p_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_ERROR,
              p_message_token   => 'GMD_MIG_NO_ORG',
              p_context         => 'Quality Specifications - gmd_customer_spec_vrs',
              p_token1          => 'ORG',
              p_token2          => 'ONAME',
              p_token3          => 'ROWK',
              p_token4          => 'ROWV',
              p_param1          => l_cust_spec.orgn_code,
              p_param2          => 'ORGN_CODE',
              p_param3          => 'SPEC_VR_ID',
              p_param4          => to_char(l_cust_spec.spec_vr_id),
              p_app_short_name  => 'GMD');
      ROLLBACK;
      GMD_QC_MIG12.g_cust_spec_err_count := GMD_QC_MIG12.g_cust_spec_err_count + 1;
      x_exception_count := x_exception_count + 1;

   WHEN CUST_SPEC_DELETE THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
	         p_log_level       => FND_LOG.LEVEL_ERROR,
	         p_message_token   => 'GMD_MIG_COMMON_SPEC_DELETE',
	         p_table_name      => NULL,
                 p_context         => 'Quality Specifications - gmd_customer_spec_vrs',
                 p_token1          => 'TAB',
                 p_param1          => 'gmd_customer_spec_vrs',
	         p_app_short_name  => 'GMD');


   WHEN CUST_NO_ORG_ID THEN
     GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => p_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_ERROR,
                   p_message_token   => 'GMD_MIG_NULL_ORG_ID',
	           p_table_name      => NULL,
                   p_context         => 'Quality Specifications - gmd_customer_spec_vrs',
	           p_token1          => 'ORG',
	           p_token2          => 'ROWK',
	           p_token3          => 'ROWV',
	           p_param1          => l_sample_orgn_code,
	           p_param2          => 'SPEC_VR_ID',
	           p_param3          => to_char(l_cust_spec.spec_vr_id),
	           p_app_short_name  => 'GMD');
             ROLLBACK;
             GMD_QC_MIG12.g_cust_spec_err_count := GMD_QC_MIG12.g_cust_spec_err_count + 1;
             x_exception_count := x_exception_count + 1;

	   WHEN OTHERS THEN
		LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			       p_run_id          => p_migration_run_id,
			       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
			       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			       p_context         => 'Quality Specifications - gmd_customer_spec_vrs',
			       p_db_error        => SQLERRM,
			       p_app_short_name  => 'GMA');
		ROLLBACK;
		x_exception_count := x_exception_count + 1;

	   END;     -- cust spec subprogram

	END LOOP;  -- end get_cust_spec




	/*==============================================
	   Log end of gmd_customer_spec_vrs migration.
	  ==============================================*/

	LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);



/*===================================
   Migrate gmd_supplier_spec_vrs.
  ===================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SUPPLIER_SPEC_VRS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SUPPLIER_SPEC_VRS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 5;
GMD_QC_MIG12.g_supl_spec_pro_count := 0;
GMD_QC_MIG12.g_supl_spec_ins_count := 0;
GMD_QC_MIG12.g_supl_spec_del_count := 0;
GMD_QC_MIG12.g_supl_spec_upd_count := 0;
GMD_QC_MIG12.g_supl_spec_err_count := 0;

FOR l_supl_spec IN get_supplier_spec LOOP
          BEGIN          -- supplier_spec subprogram
           GMD_QC_MIG12.g_supl_spec_pro_count := GMD_QC_MIG12.g_supl_spec_pro_count + 1;
	   IF (l_supl_spec.organization_id IS NULL and l_supl_spec.orgn_code IS NOT NULL) THEN
              RAISE SUP_NO_ORG;
	   END IF;

	   /*=====================================
		Get Status Ids.
	     =====================================*/

	   -- Bug# 5482253
	   -- Added code to select org_id for Supplier VRs
	   l_supl_org_id := NULL;
	   IF l_supl_spec.supplier_site_id IS NOT NULL THEN
	      BEGIN
	         SELECT org_id INTO l_supl_org_id
	         FROM po_vendor_sites_all
	         WHERE vendor_site_id = l_supl_spec.supplier_site_id;
	      EXCEPTION
	         WHEN OTHERS THEN
	             l_supl_org_id := NULL;
	      END;
	   END IF;

	   IF (l_supl_spec.in_spec_lot_status IS NULL) THEN
	      l_in_spec_status_id := NULL;
	   ELSE
	      l_in_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_supl_spec.in_spec_lot_status);
	      IF (l_in_spec_status_id IS NULL) THEN
                 RAISE SUP_IN_STATUS;
	      END IF;
	   END IF;

	   IF (l_supl_spec.out_of_spec_lot_status IS NULL) THEN
	      l_out_spec_status_id := NULL;
	   ELSE
	      l_out_spec_status_id :=  GMD_QC_MIG12.GET_STATUS_ID(l_supl_spec.out_of_spec_lot_status);
	      IF (l_out_spec_status_id IS NULL) THEN
                 RAISE SUP_OUT_STATUS;
	      END IF;
	   END IF;


	   IF (l_supl_spec.organization_id IS NOT NULL) THEN
	      /*=====================================
		   Update gmd_supplier_spec_vrs.
		=====================================*/

	      -- Bug# 5482253
	      -- Added org_id in the update statement
	      UPDATE gmd_supplier_spec_vrs
              SET out_of_spec_lot_status_id = l_out_spec_status_id,
		  in_spec_lot_status_id = l_in_spec_status_id,
		  org_id = l_supl_org_id,
		  migrated_ind = 1
	      WHERE spec_vr_id = l_supl_spec.spec_vr_id;

	      IF (p_commit = FND_API.G_TRUE) THEN
		 COMMIT;
	      END IF;

	      GMD_QC_MIG12.g_supl_spec_upd_count := GMD_QC_MIG12.g_supl_spec_upd_count + 1;

	   ELSE
	       /*=========================================
		  Loop and get all samples orgs that
		  the Supplier validity rule is tied to.
		 =========================================*/
	       OPEN get_supl_sample_org (l_supl_spec.spec_vr_id);
	       FETCH get_supl_sample_org INTO l_sample_orgn_code, l_sample_organization_id;
	       IF (get_supl_sample_org%NOTFOUND) THEN
		  CLOSE get_supl_sample_org;
		  /*========================================
		     Log the spec record and Delete it.
		   ========================================*/

		  /*==========================================
		     This is not marked as an error.
		    ==========================================*/

		  DELETE gmd_supplier_spec_vrs
		  WHERE spec_vr_id = l_supl_spec.spec_vr_id;

		  IF (p_commit = FND_API.G_TRUE) THEN
		     COMMIT;
		  END IF;

		  GMD_QC_MIG12.g_supl_spec_del_count := GMD_QC_MIG12.g_supl_spec_del_count + 1;

		  RAISE SUP_SPEC_DELETE;

	       END IF;

	       /*================================
		  Check if combination exists
                  for the first sample related
                  record.
		 ================================*/
               BEGIN    -- subprogram for check sup spec
	       OPEN check_supl_spec;
	       FETCH check_supl_spec INTO l_check_vrid;
	       IF (check_supl_spec%FOUND) THEN
		  CLOSE check_supl_spec;
		  RAISE NEXT_IN_SUPL_LINE;
	       END IF;
	       CLOSE check_supl_spec;
	       /*================================
		  Convert the Sample Org.
		 ================================*/
	       IF (l_sample_organization_id IS NULL) THEN
		  l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
		  IF (l_sample_organization_id IS NULL) THEN
		     CLOSE get_supl_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_supl_sample_org
                     RAISE SUP_NO_ORG_ID;
		  END IF;
	       END IF;

	       -- Bug# 5482253
	       -- Added org_id in the update statement
	       UPDATE gmd_supplier_spec_vrs
               SET out_of_spec_lot_status_id = l_out_spec_status_id,
		   in_spec_lot_status_id = l_in_spec_status_id,
		   organization_id = l_sample_organization_id,
                   orgn_code = l_sample_orgn_code,
		   org_id = l_supl_org_id,
		   migrated_ind = 1
	       WHERE spec_vr_id = l_supl_spec.spec_vr_id;

	      IF (p_commit = FND_API.G_TRUE) THEN
		 COMMIT;
	      END IF;

	      GMD_QC_MIG12.g_supl_spec_upd_count := GMD_QC_MIG12.g_supl_spec_upd_count + 1;

               EXCEPTION
                  WHEN NEXT_IN_SUPL_LINE THEN
                     NULL;

               END;     -- subprogram for check sup spec

	       FETCH get_supl_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

	       WHILE get_supl_sample_org%FOUND LOOP
		  /*================================
		     Check if combination exists
		    ================================*/
	          IF (get_supl_sample_org%NOTFOUND) THEN
                     EXIT;
                  END IF;
		  OPEN check_supl_spec;
		  FETCH check_supl_spec INTO l_check_vrid;
		  IF (check_supl_spec%FOUND) THEN
		     CLOSE check_supl_spec;
		     GOTO NEXT_SUPL_SAMPLE;
		  END IF;
		  CLOSE check_supl_spec;
		  /*================================
		     Convert the Sample Org.
		    ================================*/
		  IF (l_sample_organization_id IS NULL) THEN
		     l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
		     IF (l_sample_organization_id IS NULL) THEN
			CLOSE get_supl_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_supl_sample_org
                        RAISE SUP_NO_ORG_ID;
		     END IF;
		  END IF;

		  /*===========================
		       Clone the record.
		    ===========================*/
                  IF (l_supl_spec.text_code IS NOT NULL AND  l_supl_spec.text_code > 0) THEN
		      l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_supl_spec.text_code, p_migration_run_id);
                  ELSE
                      l_text_code := NULL;
                  END IF;

		  INSERT INTO gmd_supplier_spec_vrs
		  (
		  PO_HEADER_ID,
		  SPEC_VR_ID,
		  SPEC_ID,
		  ORGN_CODE,
		  SUPPLIER_ID,
		  SUPPLIER_SITE_ID,
		  PO_LINE_ID,
		  SPEC_VR_STATUS,
		  START_DATE,
		  END_DATE,
		  SAMPLING_PLAN_ID,
		  SAMPLE_INV_TRANS_IND,
		  LOT_OPTIONAL_ON_SAMPLE,
		  COA_TYPE,
		  COA_AT_SHIP_IND,
		  COA_AT_INVOICE_IND,
		  COA_REQ_FROM_SUPL_IND,
		  DELETE_MARK,
		  TEXT_CODE,
		  ATTRIBUTE_CATEGORY,
		  ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
		  ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
		  ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21,
		  ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28,
		  ATTRIBUTE29, ATTRIBUTE30,
		  CREATION_DATE,
		  CREATED_BY,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN,
		  AUTO_SAMPLE_IND,
		  CONTROL_LOT_ATTRIB_IND,
		  IN_SPEC_LOT_STATUS,
		  OUT_OF_SPEC_LOT_STATUS,
		  DELAYED_LOT_ENTRY,
		  MIGRATED_IND,
		  ERECORD_SPEC_VR_ID,
		  ORGANIZATION_ID,
		  ORG_ID,
		  OUT_OF_SPEC_LOT_STATUS_ID,
		  IN_SPEC_LOT_STATUS_ID
		  )
		  VALUES
		  (
		  l_supl_spec.PO_HEADER_ID,
		  gmd_qc_spec_vr_id_s.nextval,
		  l_supl_spec.SPEC_ID,
		  l_sample_orgn_code,
		  l_supl_spec.SUPPLIER_ID,
		  l_supl_spec.SUPPLIER_SITE_ID,
		  l_supl_spec.PO_LINE_ID,
		  l_supl_spec.SPEC_VR_STATUS,
		  l_supl_spec.START_DATE,
		  l_supl_spec.END_DATE,
		  l_supl_spec.SAMPLING_PLAN_ID,
		  l_supl_spec.SAMPLE_INV_TRANS_IND,
		  l_supl_spec.LOT_OPTIONAL_ON_SAMPLE,
		  l_supl_spec.COA_TYPE,
		  l_supl_spec.COA_AT_SHIP_IND,
		  l_supl_spec.COA_AT_INVOICE_IND,
		  l_supl_spec.COA_REQ_FROM_SUPL_IND,
		  l_supl_spec.DELETE_MARK,
		  l_text_code,
		  l_supl_spec.ATTRIBUTE_CATEGORY,
		  l_supl_spec.ATTRIBUTE1, l_supl_spec.ATTRIBUTE2, l_supl_spec.ATTRIBUTE3, l_supl_spec.ATTRIBUTE4,
		  l_supl_spec.ATTRIBUTE5, l_supl_spec.ATTRIBUTE6, l_supl_spec.ATTRIBUTE7, l_supl_spec.ATTRIBUTE8,
		  l_supl_spec.ATTRIBUTE9, l_supl_spec.ATTRIBUTE10, l_supl_spec.ATTRIBUTE11, l_supl_spec.ATTRIBUTE12,
		  l_supl_spec.ATTRIBUTE13, l_supl_spec.ATTRIBUTE14, l_supl_spec.ATTRIBUTE15, l_supl_spec.ATTRIBUTE16,
		  l_supl_spec.ATTRIBUTE17, l_supl_spec.ATTRIBUTE18, l_supl_spec.ATTRIBUTE19, l_supl_spec.ATTRIBUTE20,
		  l_supl_spec.ATTRIBUTE21, l_supl_spec.ATTRIBUTE22, l_supl_spec.ATTRIBUTE23, l_supl_spec.ATTRIBUTE24,
		  l_supl_spec.ATTRIBUTE25, l_supl_spec.ATTRIBUTE26, l_supl_spec.ATTRIBUTE27, l_supl_spec.ATTRIBUTE28,
		  l_supl_spec.ATTRIBUTE29, l_supl_spec.ATTRIBUTE30,
		  SYSDATE,
		  0,
		  0,
		  SYSDATE,
		  NULL,
		  l_supl_spec.AUTO_SAMPLE_IND,
		  l_supl_spec.CONTROL_LOT_ATTRIB_IND,
		  l_supl_spec.IN_SPEC_LOT_STATUS,
		  l_supl_spec.OUT_OF_SPEC_LOT_STATUS,
		  l_supl_spec.DELAYED_LOT_ENTRY,
		  1,
		  l_supl_spec.SPEC_VR_ID,
		  l_sample_organization_id,
                  l_supl_org_id, -- Bug# 5482253
		  l_out_spec_status_id,
		  l_in_spec_status_id
		  );

		  GMD_QC_MIG12.g_supl_spec_ins_count := GMD_QC_MIG12.g_supl_spec_ins_count + 1;

		  << NEXT_SUPL_SAMPLE >>

		       FETCH get_supl_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

            END LOOP;

            CLOSE get_supl_sample_org;

	      END IF;    -- orgn code not null

	   IF (p_commit = FND_API.G_TRUE) THEN
	      COMMIT;
	   END IF;


	EXCEPTION

	   WHEN SUP_NO_ORG THEN
	      GMA_COMMON_LOGGING.gma_migration_central_log (
		      p_run_id          => p_migration_run_id,
		      p_log_level       => FND_LOG.LEVEL_ERROR,
		      p_message_token   => 'GMD_MIG_NO_ORG',
		      p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
		      p_token1          => 'ORG',
		      p_token2          => 'ONAME',
		      p_token3          => 'ROWK',
		      p_token4          => 'ROWV',
		      p_param1          => l_supl_spec.orgn_code,
		      p_param2          => 'ORGN_CODE',
		      p_param3          => 'SPEC_VR_ID',
		      p_param4          => to_char(l_supl_spec.spec_vr_id),
		      p_app_short_name  => 'GMD');
	      GMD_QC_MIG12.g_supl_spec_err_count := GMD_QC_MIG12.g_supl_spec_err_count + 1;
	      x_exception_count := x_exception_count + 1;

	   WHEN SUP_IN_STATUS THEN
          	GMA_COMMON_LOGGING.gma_migration_central_log (
			 p_run_id          => p_migration_run_id,
			 p_log_level       => FND_LOG.LEVEL_ERROR,
			 p_message_token   => 'GMD_MIG_STATUS_ID',
			 p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
			 p_token1          => 'STAT',
			 p_token2          => 'ROWK',
			 p_token3          => 'ROWV',
			 p_param1          => l_supl_spec.in_spec_lot_status,
			 p_param2          => 'SPEC_VR_ID',
			 p_param3          => to_char(l_supl_spec.spec_vr_id),
			 p_app_short_name  => 'GMD');
		 GMD_QC_MIG12.g_supl_spec_err_count := GMD_QC_MIG12.g_supl_spec_err_count + 1;
		 x_exception_count := x_exception_count + 1;

	   WHEN SUP_OUT_STATUS THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
			 p_run_id          => p_migration_run_id,
			 p_log_level       => FND_LOG.LEVEL_ERROR,
			 p_message_token   => 'GMD_MIG_STATUS_ID',
			 p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
			 p_token1          => 'STAT',
			 p_token2          => 'ROWK',
			 p_token3          => 'ROWV',
			 p_param1          => l_supl_spec.out_of_spec_lot_status,
			 p_param2          => 'SPEC_VR_ID',
			 p_param3          => to_char(l_supl_spec.spec_vr_id),
			 p_app_short_name  => 'GMD');
		 GMD_QC_MIG12.g_supl_spec_err_count := GMD_QC_MIG12.g_supl_spec_err_count + 1;
		 x_exception_count := x_exception_count + 1;

	   WHEN SUP_SPEC_DELETE THEN
	     GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_ERROR,
		       p_message_token   => 'GMD_MIG_COMMON_SPEC_DELETE',
		       p_table_name      => NULL,
		       p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
		       p_token1          => 'TAB',
		       p_param1          => 'gmd_supplier_spec_vrs',
		       p_app_short_name  => 'GMD');


	   WHEN SUP_NO_ORG_ID THEN
         	    GMA_COMMON_LOGGING.gma_migration_central_log (
			   p_run_id          => p_migration_run_id,
			   p_log_level       => FND_LOG.LEVEL_ERROR,
			   p_message_token   => 'GMD_MIG_NULL_ORG_ID',
			   p_table_name      => NULL,
			   p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
			   p_token1          => 'ORG',
			   p_token2          => 'ROWK',
			   p_token3          => 'ROWV',
			   p_param1          => l_sample_orgn_code,
			   p_param2          => 'SPEC_VR_ID',
			   p_param3          => to_char(l_supl_spec.spec_vr_id),
			   p_app_short_name  => 'GMD');
		     GMD_QC_MIG12.g_supl_spec_err_count := GMD_QC_MIG12.g_supl_spec_err_count + 1;
		     x_exception_count := x_exception_count + 1;

	   WHEN OTHERS THEN
		LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			       p_run_id          => p_migration_run_id,
			       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
			       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			       p_context         => 'Quality Specifications - gmd_supplier_spec_vrs',
			       p_db_error        => SQLERRM,
			       p_app_short_name  => 'GMA');
		ROLLBACK;
		x_exception_count := x_exception_count + 1;


       END;     -- end supplier_spec subprogram

END LOOP;   -- supplier spec loop



/*==============================================
   Log end of gmd_supplier_spec_vrs migration.
  ==============================================*/

LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

/*====================================
   Migrate gmd_monitoring_spec_vrs;
  ====================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_MONITORING_SPEC_VRS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_MONITORING_SPEC_VRS',
       p_context         => 'Quality Specifications',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_progress_ind := 6;
GMD_QC_MIG12.g_mon_spec_pro_count := 0;
GMD_QC_MIG12.g_mon_spec_ins_count := 0;
GMD_QC_MIG12.g_mon_spec_del_count := 0;
GMD_QC_MIG12.g_mon_spec_upd_count := 0;
GMD_QC_MIG12.g_mon_spec_err_count := 0;


FOR l_mon_spec IN get_monitor_spec LOOP

   BEGIN     -- monitor spec subprogram
   GMD_QC_MIG12.g_mon_spec_pro_count := GMD_QC_MIG12.g_mon_spec_pro_count + 1;

   IF (l_mon_spec.locator_organization_id IS NULL and l_mon_spec.loct_orgn_code IS NOT NULL) THEN
      RAISE MON_NO_ORG;
   END IF;

   IF (l_mon_spec.resource_organization_id IS NULL and l_mon_spec.resource_orgn_code IS NOT NULL) THEN
      RAISE MON_NO_RES_ORG;
   END IF;
   l_organization_id := l_mon_spec.locator_organization_id;
   IF (l_mon_spec.locator_organization_id IS NOT NULL) THEN
      /*========================
          Get Subinventory.
        ========================*/
      IF (l_mon_spec.whse_code IS NOT NULL) THEN
         GMD_QC_MIG12.GET_WHSE_INFO(
                 l_mon_spec.whse_code,
                 ls_organization_id,
                 l_subinv_ind,
                 l_mon_loct_ctl);
         IF (ls_organization_id IS NULL) THEN
             RAISE MON_WHSE_ERROR;
          END IF;

          /*==========================================
             If Whse code is subinventory and
             org differs from org mapped then
             flag as an error.
            ==========================================*/

          IF (l_subinv_ind = 'Y') THEN
             IF (ls_organization_id <> l_organization_id) THEN
                 /*=========================================
                      Log error and do not migrate.
                   =========================================*/
                 RAISE MON_SUB_MISMATCH;
	     END IF; -- Bug# 5257068
          ELSE
                 l_organization_id := ls_organization_id;
          END IF;

             l_subinventory := l_mon_spec.whse_code;

             /*=========================
                  Get Locator Id.
               =========================*/

             IF (l_mon_spec.location IS NOT NULL) THEN
                l_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID(l_mon_spec.whse_code, l_mon_spec.location);
                IF (l_locator_id IS NULL) THEN
                   IF (l_mon_loct_ctl = 2) THEN
                      /*======================================
                         Create a Non-validated location.
                        ======================================*/
                      INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
                         p_migration_run_id  => p_migration_run_id,
                         p_organization_id   => l_organization_id,
	                 p_subinventory_code => l_subinventory,
                         p_location          => l_mon_spec.location,
                         p_loct_desc         => l_mon_spec.location,
                         p_start_date_active => SYSDATE,
                         p_commit            => p_commit,
                         x_location_id       => l_locator_id,
                         x_failure_count     => l_failure_count);

                      IF (l_failure_count > 0) THEN
                         RAISE MON_CREATE_LOC;
                      END IF;
                  ELSE
                    RAISE MON_LOCATOR_ID;
                   END IF;
                ELSE
                   GMD_QC_MIG12.GET_SUBINV_DATA(l_locator_id,
                                   l_subinv,
                                   lsub_organization_id);

                   IF (lsub_organization_id IS NULL) THEN
                       RAISE MON_SUBINV_ERROR;
                   END IF;

                   IF (l_subinv <> l_subinventory) THEN
                       /*============================================
                          Overlay subinventory with one from locator.
                         ============================================*/
                       l_subinventory := l_subinv;
                    END IF;
                 END IF;
             ELSE
                l_locator_id := NULL;
             END IF;   -- location is null
	  -- Bug# 5257068
	  -- Commented the following code
          /*ELSE
             l_organization_id := ls_organization_id;
          END IF;
          l_subinventory := l_mon_spec.whse_code;*/
      ELSE
         l_subinventory := NULL;
         l_locator_id := NULL;
      END IF;
   ELSE    -- loct orgn is null
      l_organization_id := NULL;
      l_subinventory := NULL;
      l_locator_id := NULL;
   END IF;



   IF (l_mon_spec.loct_orgn_code IS NOT NULL) THEN
      UPDATE gmd_monitoring_spec_vrs
      SET    locator_organization_id = l_organization_id,
             subinventory = l_subinventory,
             locator_id = l_locator_id,
             migrated_ind = 1
      WHERE  spec_vr_id = l_mon_spec.spec_vr_id;

      IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
      END IF;

      GMD_QC_MIG12.g_mon_spec_upd_count := GMD_QC_MIG12.g_mon_spec_upd_count + 1;

   ELSE             --orgn code is null
       /*=========================================
          Loop and get all samples orgs that
          the Monitoring validity rule is tied to.
         =========================================*/
       OPEN get_mon_sample_org (l_mon_spec.spec_vr_id);
       FETCH get_mon_sample_org INTO l_sample_orgn_code, l_sample_organization_id;
       IF (get_mon_sample_org%NOTFOUND) THEN
          CLOSE get_mon_sample_org;
          /*========================================
             Log the spec record and Delete it.
           ========================================*/

          /*==========================================
             This is not marked as an error.
            ==========================================*/

          DELETE gmd_monitoring_spec_vrs
          WHERE spec_vr_id = l_mon_spec.spec_vr_id;

          IF (p_commit = FND_API.G_TRUE) THEN
             COMMIT;
          END IF;

          GMD_QC_MIG12.g_mon_spec_del_count := GMD_QC_MIG12.g_mon_spec_del_count + 1;
          RAISE MON_SPEC_DELETE;

END IF;    -- check if sample found.

/*================================
  Check if combination exists
  for the first sample related
  record.
 ================================*/
BEGIN    -- subprogram for check mon spec
OPEN check_mon_spec;
FETCH check_mon_spec INTO l_check_vrid;
IF (check_mon_spec%FOUND) THEN
  CLOSE check_mon_spec;
  RAISE NEXT_IN_MON_LINE;
END IF;
CLOSE check_mon_spec;

/*================================
  Convert the Sample Org.
 ================================*/
IF (l_sample_organization_id IS NULL) THEN
  l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
  IF (l_sample_organization_id IS NULL) THEN
     CLOSE get_mon_sample_org; -- Bug# 5554719 -- Changed it from get_sample_org to get_mon_sample_org
     RAISE MON_NO_ORG_ID;
  END IF;
END IF;

UPDATE gmd_monitoring_spec_vrs
SET   locator_organization_id = l_sample_organization_id,
     loct_orgn_code = l_sample_orgn_code,
     subinventory = l_subinventory,
     locator_id = l_locator_id,
     migrated_ind = 1
WHERE  spec_vr_id = l_mon_spec.spec_vr_id;

IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
END IF;

GMD_QC_MIG12.g_mon_spec_upd_count := GMD_QC_MIG12.g_mon_spec_upd_count + 1;

EXCEPTION
  WHEN NEXT_IN_MON_LINE THEN
    NULL;

END ;    -- subprogram for check mon spec

/*====================================
  Continue to process Sample records
  beyond the first one.
 ====================================*/

FETCH get_mon_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

WHILE get_mon_sample_org%FOUND LOOP
  IF (get_mon_sample_org%NOTFOUND) THEN
     EXIT;
  END IF;
  /*================================
     Check if combination exists
    ================================*/
  OPEN check_mon_spec;
  FETCH check_mon_spec INTO l_check_vrid;
  IF (check_mon_spec%FOUND) THEN
     CLOSE check_mon_spec;
     GOTO NEXT_MON_SAMPLE;
  END IF;
  CLOSE check_mon_spec;
  /*================================
     Convert the Sample Org.
    ================================*/
  IF (l_sample_organization_id IS NULL) THEN
     l_sample_organization_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_sample_orgn_code);
     IF (l_sample_organization_id IS NULL) THEN
	CLOSE get_mon_sample_org;
        RAISE MON_NO_ORG_ID;
     END IF;
  END IF;

  /*==================================================
     Clone the record using the Sample organization.
    ==================================================*/

  IF (l_mon_spec.text_code IS NOT NULL AND  l_mon_spec.text_code > 0) THEN
      l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_mon_spec.text_code, p_migration_run_id);
  ELSE
      l_text_code := NULL;
  END IF;

  INSERT INTO gmd_monitoring_spec_vrs
  (
  SPEC_VR_ID,
  SPEC_ID,
  RULE_TYPE,
  LOCT_ORGN_CODE,
  WHSE_CODE,
  LOCATION,
  RESOURCES,
  RESOURCE_ORGN_CODE,
  RESOURCE_INSTANCE_ID,
  SPEC_VR_STATUS,
  START_DATE,
  END_DATE,
  SAMPLING_PLAN_ID,
  DELETE_MARK,
          TEXT_CODE,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
          ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
          ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21,
          ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28,
          ATTRIBUTE29, ATTRIBUTE30,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          MIGRATED_IND,
          ERECORD_SPEC_VR_ID,
          LOCATOR_ORGANIZATION_ID,
          SUBINVENTORY,
          LOCATOR_ID,
          RESOURCE_ORGANIZATION_ID
          )
          VALUES
          (
          gmd_qc_spec_vr_id_s.nextval,
          l_mon_spec.SPEC_ID,
          l_mon_spec.RULE_TYPE,
          l_sample_orgn_code,
          l_mon_spec.WHSE_CODE,
          l_mon_spec.LOCATION,
          l_mon_spec.RESOURCES,
          l_mon_spec.RESOURCE_ORGN_CODE,
          l_mon_spec.RESOURCE_INSTANCE_ID,
          l_mon_spec.SPEC_VR_STATUS,
          l_mon_spec.START_DATE,
          l_mon_spec.END_DATE,
          l_mon_spec.SAMPLING_PLAN_ID,
          l_mon_spec.DELETE_MARK,
          l_text_code,
          l_mon_spec.ATTRIBUTE_CATEGORY,
          l_mon_spec.ATTRIBUTE1, l_mon_spec.ATTRIBUTE2, l_mon_spec.ATTRIBUTE3, l_mon_spec.ATTRIBUTE4,
          l_mon_spec.ATTRIBUTE5, l_mon_spec.ATTRIBUTE6, l_mon_spec.ATTRIBUTE7, l_mon_spec.ATTRIBUTE8,
          l_mon_spec.ATTRIBUTE9, l_mon_spec.ATTRIBUTE10, l_mon_spec.ATTRIBUTE11, l_mon_spec.ATTRIBUTE12,
          l_mon_spec.ATTRIBUTE13, l_mon_spec.ATTRIBUTE14, l_mon_spec.ATTRIBUTE15, l_mon_spec.ATTRIBUTE16,
          l_mon_spec.ATTRIBUTE17, l_mon_spec.ATTRIBUTE18, l_mon_spec.ATTRIBUTE19, l_mon_spec.ATTRIBUTE20,
          l_mon_spec.ATTRIBUTE21, l_mon_spec.ATTRIBUTE22, l_mon_spec.ATTRIBUTE23, l_mon_spec.ATTRIBUTE24,
          l_mon_spec.ATTRIBUTE25, l_mon_spec.ATTRIBUTE26, l_mon_spec.ATTRIBUTE27, l_mon_spec.ATTRIBUTE28,
          l_mon_spec.ATTRIBUTE29, l_mon_spec.ATTRIBUTE30,
          SYSDATE,
          0,
          0,
          SYSDATE,
          NULL,
          1,
          l_mon_spec.SPEC_VR_ID,
          l_sample_organization_id,
          l_subinventory,
          l_locator_id,
          l_mon_spec.RESOURCE_ORGANIZATION_ID
          );


          GMD_QC_MIG12.g_mon_spec_ins_count := GMD_QC_MIG12.g_mon_spec_ins_count + 1;

          << NEXT_MON_SAMPLE >>

             FETCH get_mon_sample_org INTO l_sample_orgn_code, l_sample_organization_id;

       END LOOP;

       CLOSE get_mon_sample_org;

   END IF;   -- orgn code null.

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;


   EXCEPTION

     WHEN MON_NO_ORG THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => p_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_ERROR,
              p_message_token   => 'GMD_MIG_NO_ORG',
              p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
              p_token1          => 'ORG',
              p_token2          => 'ONAME',
              p_token3          => 'ROWK',
              p_token4          => 'ROWV',
              p_param1          => l_mon_spec.loct_orgn_code,
              p_param2          => 'LOCT_ORGN_CODE',
              p_param3          => 'SPEC_VR_ID',
              p_param4          => to_char(l_mon_spec.spec_vr_id),
              p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
      x_exception_count := x_exception_count + 1;

     WHEN MON_NO_RES_ORG THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => p_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_ERROR,
              p_message_token   => 'GMD_MIG_NO_ORG',
              p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
              p_token1          => 'ORG',
              p_token2          => 'ONAME',
              p_token3          => 'ROWK',
              p_token4          => 'ROWV',
              p_param1          => l_mon_spec.resource_orgn_code,
              p_param2          => 'RESOURCE_ORGN_CODE',
              p_param3          => 'SPEC_VR_ID',
              p_param4          => to_char(l_mon_spec.spec_vr_id),
              p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
      x_exception_count := x_exception_count + 1;

     WHEN MON_WHSE_ERROR THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_WHSE_ERROR',
               p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          =>  l_mon_spec.whse_code,
	       p_param2          => 'WHSE_CODE',
	       p_param3          => 'SPEC_VR_ID',
	       p_param4          => to_char(l_mon_spec.spec_vr_id),
	       p_app_short_name  => 'GMD');
        GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
        x_exception_count := x_exception_count + 1;

     WHEN MON_SUB_MISMATCH THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
                       p_run_id          => p_migration_run_id,
                       p_log_level       => FND_LOG.LEVEL_ERROR,
                       p_message_token   => 'GMD_MIG_MSPEC_SUB_MISMATCH',
                       p_table_name      => NULL,
                       p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
                       p_token1          => 'VRID',
                       p_token2          => 'ORG',
                       p_token3          => 'WHSE',
                       p_token4          => 'ORGID',
                       p_token5          => 'WHSEID',
                       p_param1          => to_char(l_mon_spec.spec_vr_id),
                       p_param2          => l_mon_spec.loct_orgn_code,
                       p_param3          => l_mon_spec.whse_code,
                       p_param4          => to_char(l_organization_id),
                       p_param5          => to_char(ls_organization_id),
                       p_app_short_name  => 'GMD');
                 GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
                 x_exception_count := x_exception_count + 1;

     WHEN MON_CREATE_LOC THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
             p_run_id          => p_migration_run_id,
	     p_log_level       => FND_LOG.LEVEL_ERROR,
	     p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
             p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
	     p_token1          => 'ROWK',
	     p_token2          => 'ROWV',
	     p_token3          => 'FNAME',
	     p_param1          => 'SPEC_VR_ID',
	     p_param2          => to_char(l_mon_spec.spec_vr_id),
	     p_param3          => 'LOCATION',
	     p_app_short_name  => 'GMD');
          GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
          x_exception_count := x_exception_count + 1;

     WHEN MON_LOCATOR_ID THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_LOCATOR_ID',
                 p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
                 p_token1          => 'WHSE',
                 p_token2          => 'LOCATION',
                 p_token3          => 'LFIELD',
                 p_token4          => 'ROWK',
                 p_token5          => 'ROWV',
                 p_param1          => l_mon_spec.whse_code,
                 p_param2          => l_mon_spec.location,
                 p_param3          => 'LOCATION',
                 p_param4          => 'SPEC_VR_ID',
                 p_param5          => to_char(l_mon_spec.spec_vr_id),
                p_app_short_name  => 'GMD');
         GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
         x_exception_count := x_exception_count + 1;

     WHEN MON_SUBINV_ERROR THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
                 p_run_id          => p_migration_run_id,
                 p_log_level       => FND_LOG.LEVEL_ERROR,
                 p_message_token   => 'GMD_MIG_SUBINV',
                 p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
	         p_token1          => 'LOCATOR',
                 p_token2          => 'ROWK',
                 p_token3          => 'ROWV',
                 p_param1          => to_char(l_locator_id),
                 p_param2          => 'SPEC_VR_ID',
                 p_param3          => to_char(l_mon_spec.spec_vr_id),
                 p_app_short_name  => 'GMD');
          GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
          x_exception_count := x_exception_count + 1;


     WHEN MON_SPEC_DELETE THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_COMMON_SPEC_DELETE',
	       p_table_name      => NULL,
               p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
               p_token1          => 'TAB',
               p_param1          => 'gmd_monitoring_spec_vrs',
	       p_app_short_name  => 'GMD');

     WHEN MON_NO_ORG_ID THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
	   p_run_id          => p_migration_run_id,
	   p_log_level       => FND_LOG.LEVEL_ERROR,
	   p_message_token   => 'GMD_MIG_NULL_ORG_ID',
	   p_table_name      => NULL,
	   p_context         => 'Quality Specifications - gmd_monitoring_spec_vrs',
	   p_token1          => 'ORG',
	   p_token2          => 'ROWK',
	   p_token3          => 'ROWV',
	   p_param1          => l_sample_orgn_code,
	   p_param2          => 'SPEC_VR_ID',
	   p_param3          => to_char(l_mon_spec.spec_vr_id),
	   p_app_short_name  => 'GMD');
     GMD_QC_MIG12.g_mon_spec_err_count := GMD_QC_MIG12.g_mon_spec_err_count + 1;
     x_exception_count := x_exception_count + 1;

   END;      -- monitor spec subprogram

END LOOP;


/*==============================================
   Log end of gmd_monitoring_spec_vrs migration.
  ==============================================*/

LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


RETURN;


EXCEPTION

   WHEN OTHERS THEN
      LOG_SPEC_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
      GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
               p_context         => 'Quality Specifications - general',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');

     x_exception_count := x_exception_count + 1;


END GMD_QC_MIGRATE_SPECS;

/*===========================================================================
--  PROCEDURE
--    gmd_qc_migrate_stabs
--
--  DESCRIPTION:
--    This migrates the Quality Stability Study Data.
--
--  PARAMETERS:
--
--    p_migration_run_id    IN  NUMBER         - Migration Id.
--    p_commit              IN  VARCHAR2       - Commit Flag
--
--    x_exception_count     OUT NUMBER         - Exception Count
--
--  The following columns will be migrated by the Common migration script.
--
--  gmd_ss_storage_package   quantity_uom
--  gmd_stability_studies_b  organization_id
--  gmd_stability_studies_b  lab_organization_id
--  gmd_ss_material_sources  source_organization_id
--  gmd_ss_material_sources  sample_quantity_uom
--  gmd_ss_variants          sample_quantity_uom
--=========================================================================== */

PROCEDURE GMD_QC_MIGRATE_STABS
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER)

IS


/*=======================
     Exceptions
  =======================*/
DEFAULT_SS_ORG_ERROR   EXCEPTION;
SS_ORG_ID_ERROR        EXCEPTION;
SP_WHSE_ERROR          EXCEPTION;
SP_CREATE_LOCATION     EXCEPTION;
SP_LOCATOR_ID          EXCEPTION;
SP_SUBINV_ERROR        EXCEPTION;
STAB_NO_ORG            EXCEPTION;
STAB_NO_LAB_ORG        EXCEPTION;
STAB_ODM_ITEM          EXCEPTION;
MATL_NO_ORG            EXCEPTION;
MATL_GET_SS            EXCEPTION;
MATL_PLANT_ORG         EXCEPTION;
MATL_MIG_LOT           EXCEPTION;
VAR_WHSE_ERROR         EXCEPTION;
VAR_CREATE_LOC         EXCEPTION;
VAR_LOCATOR_ID         EXCEPTION;
VAR_SUBINV_ERROR       EXCEPTION;
HIST_WHSE_ERROR        EXCEPTION;
HIST_CREATE_LOC        EXCEPTION;
HIST_LOCATOR_ID        EXCEPTION;
HIST_SUBINV_ERROR      EXCEPTION;
STORE_DEF_ODM_ITEM     EXCEPTION;
STORE_SS_ORG           EXCEPTION;
STORE_ODM_ITEM         EXCEPTION;
NULL_DEFAULT_LAB       EXCEPTION;


/*=====================================
   Cursor for gmd_stability_studies_b.
  =====================================*/

-- Bug# 5109234
-- Removed organization_id IS NULL from the where clause and added orgn_code IS NOT NULL.
CURSOR get_stab IS
SELECT orgn_code, organization_id, item_id, qc_lab_orgn_code,
       lab_organization_id, ss_id
FROM   gmd_stability_studies_b
WHERE  migrated_ind IS NULL
AND    orgn_code IS NOT NULL;

l_store_loct_ctl             ic_whse_mst.loct_ctl%TYPE;
l_splan_loct_ctl             ic_whse_mst.loct_ctl%TYPE;
l_hist_loct_ctl              ic_whse_mst.loct_ctl%TYPE;
l_svar_loct_ctl              ic_whse_mst.loct_ctl%TYPE;
l_inventory_item_id          gmd_stability_studies_b.inventory_item_id%TYPE;
l_subinv                     mtl_item_locations.subinventory_code%TYPE;
lsub_organization_id         mtl_item_locations.organization_id%TYPE;
l_lot_orgn_code              gmd_stability_studies_b.orgn_code%TYPE;
l_stab_org_id                gmd_stability_studies_b.organization_id%TYPE;


/*=====================================
   Cursor for gmd_storage_plan_details.
  Added storage_organization_id is null
  in order to ignore records created
  after migration has run.
  =====================================*/

CURSOR get_plan_details IS
SELECT storage_plan_detail_id, whse_code, location
FROM   gmd_storage_plan_details
WHERE  migrated_ind IS NULL
AND    storage_organization_id IS NULL;

l_plan_org_id                  gmd_storage_plan_details.storage_organization_id%TYPE;
l_plan_subinv_ind              ic_whse_mst.subinventory_ind_flag%TYPE;
l_plan_subinv                  gmd_storage_plan_details.storage_subinventory%TYPE;
l_plan_locator_id              ic_loct_mst.locator_id%TYPE;



/*=====================================
   Cursor for get all stability study
   orgs associated with the storage
   package.
  =====================================*/

CURSOR get_stab_study_org(p_package_id  gmd_ss_storage_package.package_id%TYPE) IS
SELECT distinct gssb.orgn_code, gsv.package_id
FROM   gmd_stability_studies_b gssb, gmd_ss_variants gsv
WHERE  gssb.ss_id = gsv.ss_id
AND    gsv.package_id = p_package_id;

l_stab_orgn_code              gmd_stability_studies_b.orgn_code%TYPE;
l_gsv_package_id              gmd_ss_variants.package_id%TYPE;

/*=====================================
   Cursor for gmd_ss_storage_package.
  =====================================*/

CURSOR get_store_pack IS
SELECT *
FROM   gmd_ss_storage_package
WHERE  migrated_ind IS NULL
AND    organization_id IS NULL;

l_store_pack            gmd_ss_storage_package%ROWTYPE;
l_store_pack_invitem_id gmd_ss_storage_package.inventory_item_id%TYPE;

l_package_id            NUMBER;

CURSOR get_pack_seq IS
SELECT gmd_qc_ss_stor_pack_id_s.nextval
FROM   DUAL;

/*=====================================
   Cursor to get default Stability
   Study Org from setup tables.
  =====================================*/

CURSOR get_ss_org IS
SELECT default_stability_study_org
FROM   gmd_migrate_parms;


l_def_ss_org          sy_orgn_mst.orgn_code%TYPE;
l_def_ss_org_id       sy_orgn_mst.organization_id%TYPE;
l_ss_org_id           sy_orgn_mst.organization_id%TYPE;

/*=========================================
   Cursor to get gmd_ss_material_sources.
   Get org id null to exclude records
   added after migration is run and then
   rerun.
  =========================================*/

-- Bug# 5109234
-- Removed source_organization_id IS NULL from the where clause since lot info needs to be migrated.
CURSOR get_matl_src IS
SELECT plant_code, source_organization_id,
       lot_id, ss_id, source_id
FROM   gmd_ss_material_sources
WHERE  migrated_ind IS NULL;
--AND    source_organization_id IS NULL;

l_plant_org_id       gmd_ss_material_sources.source_organization_id%TYPE;

/*===============================================
   Cursor to get stability study org and item.
  ===============================================*/

CURSOR get_stab_study (p_ss_id   gmd_stability_studies_b.ss_id%TYPE) IS
SELECT orgn_code, item_id
FROM   gmd_stability_studies_b
WHERE  ss_id = p_ss_id;

l_ss_orgn_code            gmd_stability_studies_b.orgn_code%TYPE;
l_ss_item_id              gmd_stability_studies_b.item_id%TYPE;

l_lot_number              mtl_lot_numbers.lot_number%TYPE;
l_parent_lot_number       mtl_lot_numbers.parent_lot_number%TYPE;
l_failure_count           NUMBER;

/*=========================================
   Cursor to get gmd_ss_variants.
   If record is created after migration
   and migration is rerun we will classify
   the record as migrated even though it
   is not a truly migrated record.
  =========================================*/

CURSOR get_ss_variant IS
SELECT variant_id, storage_whse_code, storage_location,
       storage_organization_id, storage_subinventory, storage_locator_id
FROM   gmd_ss_variants
WHERE  migrated_ind IS NULL;

l_variant_id                 gmd_ss_variants.variant_id%TYPE;
l_storage_whse_code          gmd_ss_variants.storage_whse_code%TYPE;
l_storage_location           gmd_ss_variants.storage_location%TYPE;
l_storage_organization_id    gmd_ss_variants.storage_organization_id%TYPE;
l_storage_subinventory       gmd_ss_variants.storage_subinventory%TYPE;
l_storage_subinvind          ic_whse_mst.subinventory_ind_flag%TYPE;
l_storage_locator_id         gmd_ss_variants.storage_locator_id%TYPE;

/*=========================================
   Cursor to get gmd_ss_storage_history.
   Select also where organization id is
   null to not affect records added after
   the migration in case migration is
   run again out of sequence.
  =========================================*/

CURSOR get_ss_history IS
SELECT storage_history_id, whse_code, location,
       organization_id, subinventory, locator_id
FROM   gmd_ss_storage_history
WHERE  migrated_ind IS NULL
AND    organization_id IS NULL;

l_hist_org_id                gmd_ss_storage_history.organization_id%TYPE;
l_hist_subinventory          gmd_ss_storage_history.subinventory%TYPE;
l_hist_subinvind             ic_whse_mst.subinventory_ind_flag%TYPE;
l_hist_locator_id            gmd_ss_storage_history.locator_id%TYPE;

l_text_code              NUMBER;

BEGIN

GMD_QC_MIG12.g_progress_ind := 0;
x_exception_count := 0;


/*==============================================
   Log Start of gmd_storage_plan_details.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_STORAGE_PLAN_DETAILS',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_STORAGE_PLAN_DETAILS',
       p_context         => 'Quality Stability Studies',
       p_app_short_name  => 'GMA');

/*===================================
   Process gmd_storage_plan_details.
  ====================================*/

GMD_QC_MIG12.g_store_plan_upd_count := 0;
GMD_QC_MIG12.g_store_plan_pro_count := 0;
GMD_QC_MIG12.g_store_plan_err_count := 0;
GMD_QC_MIG12.g_progress_ind := 1;

FOR l_plan_det IN get_plan_details LOOP
    BEGIN   -- plan details subprogram

    GMD_QC_MIG12.g_store_plan_pro_count :=  GMD_QC_MIG12.g_store_plan_pro_count + 1;

    /*=============================================
       Get organization id for the subinventory.
      =============================================*/

    IF (l_plan_det.whse_code IS NOT NULL) THEN
       GMD_QC_MIG12.GET_WHSE_INFO (
          p_whse_code => l_plan_det.whse_code,
          x_organization_id => l_plan_org_id,
          x_subinv_ind => l_plan_subinv_ind,
          x_loct_ctl => l_splan_loct_ctl);

       IF (l_plan_org_id IS NULL) THEN
          RAISE SP_WHSE_ERROR;
       END IF;

       l_plan_subinv := l_plan_det.whse_code;

       /*=============================
          Get Storage Locator Id.
         =============================*/

       IF (l_plan_det.location IS NOT NULL) THEN
          IF (l_plan_det.location = 'NONE') THEN
             l_plan_locator_id := NULL;
          ELSE
             l_plan_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID (
                p_whse_code => l_plan_det.whse_code,
                p_location => l_plan_det.location);

             IF (l_plan_locator_id IS NULL) THEN
                  IF (l_splan_loct_ctl = 2) THEN
                     /*======================================
                        Create a Non-validated location.
                       ======================================*/
                     INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
                            p_migration_run_id  => p_migration_run_id,
                            p_organization_id   => l_plan_org_id,
	                    p_subinventory_code => l_plan_subinv,
                            p_location          => l_plan_det.location,
                            p_loct_desc         => l_plan_det.location,
                            p_start_date_active => SYSDATE,
                            p_commit            => p_commit,
                            x_location_id       => l_plan_locator_id,
                            x_failure_count     => l_failure_count);

                     IF (l_failure_count > 0) THEN
                        RAISE SP_CREATE_LOCATION;
                     END IF;
                 ELSE
                     RAISE SP_LOCATOR_ID;
                 END IF;
             ELSE
                 /*=========================================
	            Compare locator's subinventory to
                    subinventory already mapped.
	           =========================================*/
                GMD_QC_MIG12.GET_SUBINV_DATA(l_plan_locator_id,
                                   l_subinv,
                                   lsub_organization_id);

                IF (lsub_organization_id IS NULL) THEN
                    RAISE SP_SUBINV_ERROR;
                END IF;
                IF (l_subinv <> l_plan_subinv) THEN
                    l_plan_subinv := l_subinv;
                END IF;
             END IF;
          END IF;    -- none location
       ELSE   -- null location
	  l_plan_locator_id := NULL;
       END IF;     -- location is null.
    ELSE
       -- BEGIN Bug# 5109039
       -- Get the default_stability_study_org from gmd_migrate_parms and convert to the correct id
       -- and assign it to l_plan_org_id instead of null
       OPEN get_ss_org;
       FETCH get_ss_org INTO l_def_ss_org;
       CLOSE get_ss_org;

       l_plan_org_id := GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_def_ss_org);
       IF (l_plan_org_id IS NULL) THEN
          RAISE DEFAULT_SS_ORG_ERROR;
       END IF;
       -- END Bug# 5109039

       l_plan_subinv := NULL;
       l_plan_locator_id := NULL;
    END IF;     -- plan whse code is null

    /*===================================
       Update gmd_storage_plan_details.
      ===================================*/

    UPDATE gmd_storage_plan_details
    SET storage_organization_id = l_plan_org_id,
       storage_subinventory = l_plan_subinv,
       storage_locator_id = l_plan_locator_id,
       migrated_ind = 1
    WHERE storage_plan_detail_id = l_plan_det.storage_plan_detail_id;

   IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
   END IF;

   GMD_QC_MIG12.g_store_plan_upd_count :=  GMD_QC_MIG12.g_store_plan_upd_count + 1;

EXCEPTION

WHEN SP_WHSE_ERROR THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
               p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_WHSE_ERROR',
               p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => l_plan_det.whse_code,
	       p_param2          => 'WHSE_CODE',
	       p_param3          => 'STORAGE_PLAN_DETAIL_ID',
	       p_param4          => l_plan_det.storage_plan_detail_id,
	       p_app_short_name  => 'GMD');
          GMD_QC_MIG12.g_store_plan_err_count :=  GMD_QC_MIG12.g_store_plan_err_count + 1;
          x_exception_count := x_exception_count + 1;

WHEN SP_CREATE_LOCATION THEN
            GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => p_migration_run_id,
	                p_log_level       => FND_LOG.LEVEL_ERROR,
	                p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
                        p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
	                p_token1          => 'ROWK',
	                p_token2          => 'ROWV',
	                p_token3          => 'FNAME',
	                p_param1          => 'STORAGE_PLAN_DETAIL_ID',
	                p_param2          => l_plan_det.storage_plan_detail_id,
	                p_param3          => 'LOCATION',
	                p_app_short_name  => 'GMD');
            GMD_QC_MIG12.g_store_plan_err_count :=  GMD_QC_MIG12.g_store_plan_err_count + 1;
            x_exception_count := x_exception_count + 1;

WHEN SP_LOCATOR_ID THEN
            GMA_COMMON_LOGGING.gma_migration_central_log (
                    p_run_id          => p_migration_run_id,
	            p_log_level       => FND_LOG.LEVEL_ERROR,
          	    p_message_token   => 'GMD_MIG_LOCATOR_ID',
                    p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
	            p_token1          => 'WHSE',
	            p_token2          => 'LOCATION',
	            p_token3          => 'LFIELD',
	            p_token4          => 'ROWK',
	            p_token5          => 'ROWV',
	            p_param1          => l_plan_det.whse_code,
	            p_param2          => l_plan_det.location,
	            p_param3          => 'LOCATION',
	            p_param4          => 'STORAGE_PLAN_DETAIL_ID',
	            p_param5          => l_plan_det.storage_plan_detail_id,
	            p_app_short_name  => 'GMD');
            GMD_QC_MIG12.g_store_plan_err_count :=  GMD_QC_MIG12.g_store_plan_err_count + 1;
            x_exception_count := x_exception_count + 1;


WHEN SP_SUBINV_ERROR THEN
           GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => p_migration_run_id,
	                p_log_level       => FND_LOG.LEVEL_ERROR,
	                p_message_token   => 'GMD_MIG_SUBINV',
                        p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
          	        p_token1          => 'LOCATOR',
          	        p_token2          => 'ROWK',
          	        p_token3          => 'ROWV',
	                p_param1          => to_char(l_plan_locator_id),
	                p_param2          => 'STORAGE_PLAN_DETAIL_ID',
	                p_param3          => to_char(l_plan_det.storage_plan_detail_id),
                        p_app_short_name  => 'GMD');
                  GMD_QC_MIG12.g_store_plan_err_count :=  GMD_QC_MIG12.g_store_plan_err_count + 1;
                  x_exception_count := x_exception_count + 1;

-- Bug# 5109039
WHEN DEFAULT_SS_ORG_ERROR    THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEF_SS_ORG_ERROR',
	       p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
	       p_app_short_name  => 'GMD');
       GMD_QC_MIG12.g_store_plan_err_count :=  GMD_QC_MIG12.g_store_plan_err_count + 1;
       x_exception_count := x_exception_count + 1;

WHEN OTHERS THEN
	      LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
	      GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
                       p_context         => 'Quality Stability Studies - gmd_storage_plan_details',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
	     x_exception_count := x_exception_count + 1;
             ROLLBACK;

    END;    -- end plan details subprogram

END LOOP;   -- end get plan details


/*=====================================================
   Log number of updates to gmd_storage_plan_details.
  =====================================================*/

LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*==============================================
   Log Start of gmd_stability_studies.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_STABILITY_STUDIES_B',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_STABILITY_STUDIES_B',
       p_context         => 'Quality Stability Studies',
       p_app_short_name  => 'GMA');

/*=====================================
   Migrate gmd_stability_studies_b.
  =====================================*/

GMD_QC_MIG12.g_stab_pro_count :=  0;
GMD_QC_MIG12.g_stab_upd_count :=  0;
GMD_QC_MIG12.g_stab_err_count :=  0;
GMD_QC_MIG12.g_progress_ind := 2;

FOR l_stab_rec in get_stab LOOP
    BEGIN   -- stab study subprogram
    GMD_QC_MIG12.g_stab_pro_count :=  GMD_QC_MIG12.g_stab_pro_count + 1;
   /*================================
         Migrate  organization.
     ================================*/

   l_stab_org_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_stab_rec.orgn_code);
   IF (l_stab_org_id IS NULL) THEN
      RAISE STAB_NO_ORG;
   END IF;

   /*======================================
      Check if lab organization migrated.
     ======================================*/

   IF (l_stab_rec.lab_organization_id IS NULL and l_stab_rec.qc_lab_orgn_code IS NOT NULL) THEN
      RAISE STAB_NO_LAB_ORG;
   END IF;

   IF (l_stab_rec.item_id IS NOT NULL) THEN
      /*=========================
	 Get Inventory Item id.
	=========================*/
       INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
	   P_MIGRATION_RUN_ID => p_migration_run_id,
	   P_ITEM_ID => l_stab_rec.item_id,
	   P_ORGANIZATION_ID  => l_stab_org_id,
	   P_MODE => NULL,
           P_COMMIT => FND_API.G_TRUE,
	   X_INVENTORY_ITEM_ID => l_inventory_item_id,
	   X_FAILURE_COUNT => l_failure_count);
       IF (l_failure_count > 0) THEN
           RAISE STAB_ODM_ITEM;
       END IF;
   ELSE
      l_inventory_item_id := NULL;
   END IF;

   UPDATE gmd_stability_studies_b
   SET    inventory_item_id = l_inventory_item_id,
          organization_id = l_stab_org_id,
	  migrated_ind = 1
   WHERE  ss_id = l_stab_rec.ss_id;

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;

   GMD_QC_MIG12.g_stab_upd_count :=  GMD_QC_MIG12.g_stab_upd_count + 1;

    EXCEPTION
       WHEN STAB_NO_ORG THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
	      p_run_id          => p_migration_run_id,
	      p_log_level       => FND_LOG.LEVEL_ERROR,
	      p_message_token   => 'GMD_MIG_NO_ORG',
	      p_context         => 'Quality Stability Studies - gmd_stability_studies_b',
	      p_token1          => 'ORG',
	      p_token2          => 'ONAME',
	      p_token3          => 'ROWK',
	      p_token4          => 'ROWV',
	      p_param1          => l_stab_rec.orgn_code,
	      p_param2          => 'ORGN_CODE',
	      p_param3          => 'SS_ID',
	      p_param4          => to_char(l_stab_rec.ss_id),
	      p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_stab_err_count := GMD_QC_MIG12.g_stab_err_count + 1;
      x_exception_count := x_exception_count + 1;

       WHEN STAB_NO_LAB_ORG THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
	      p_run_id          => p_migration_run_id,
	      p_log_level       => FND_LOG.LEVEL_ERROR,
	      p_message_token   => 'GMD_MIG_NO_ORG',
	      p_context         => 'Quality Stability Studies - gmd_stability_studies_b',
	      p_token1          => 'ORG',
	      p_token2          => 'ONAME',
	      p_token3          => 'ROWK',
	      p_token4          => 'ROWV',
	      p_param1          => l_stab_rec.qc_lab_orgn_code,
	      p_param2          => 'QC_LAB_ORGN_CODE',
	      p_param3          => 'SS_ID',
	      p_param4          => to_char(l_stab_rec.ss_id),
	      p_app_short_name  => 'GMD');
      GMD_QC_MIG12.g_stab_err_count :=  GMD_QC_MIG12.g_stab_err_count + 1;
      x_exception_count := x_exception_count + 1;

       WHEN STAB_ODM_ITEM THEN
	 GMA_COMMON_LOGGING.gma_migration_central_log (
	      p_run_id          => p_migration_run_id,
	      p_log_level       => FND_LOG.LEVEL_ERROR,
	      p_message_token   => 'GMD_MIG_ODM_ITEM',
	      p_context         => 'Quality Stability Studies - gmd_stability_studies_b',
	      p_token1          => 'ORG',
	      p_token2          => 'ITEMID',
	      p_token3          => 'ROWK',
	      p_token4          => 'ROWV',
	      p_param1          => to_char(l_stab_rec.organization_id),
	      p_param2          => to_char(l_stab_rec.item_id),
	      p_param3          => 'SS_ID',
	      p_param4          => to_char(l_stab_rec.ss_id),
	      p_app_short_name  => 'GMD');
	    GMD_QC_MIG12.g_stab_err_count :=  GMD_QC_MIG12.g_stab_err_count + 1;
            x_exception_count := x_exception_count + 1;

       WHEN OTHERS THEN
	      LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
	      GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Stability Studies - gmd_stability_studies_b',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
	     x_exception_count := x_exception_count + 1;
             ROLLBACK;

    END;    -- end stab study subprogram

END LOOP;  -- end of get_stab



/*==============================================
   Log End of gmd_stability_studies_b.
  ==============================================*/

LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*==============================================
   Log Start of gmd_ss_material_sources.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SS_MATERIAL_SOURCES',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SS_MATERIAL_SOURCES',
       p_context         => 'Quality Stability Studies',
       p_app_short_name  => 'GMA');

/*=======================================
   Migrate gmd_ss_material_sources.
  =======================================*/

GMD_QC_MIG12.g_matl_source_pro_count := 0;
GMD_QC_MIG12.g_matl_source_err_count := 0;
GMD_QC_MIG12.g_matl_source_upd_count := 0;
GMD_QC_MIG12.g_progress_ind := 3;

FOR l_matl_rec IN get_matl_src LOOP
   BEGIN      -- matl src subprogram
   GMD_QC_MIG12.g_matl_source_pro_count := GMD_QC_MIG12.g_matl_source_pro_count + 1;
   /*===================================
      Migrate organization.
      Convert plant code if it exists.
     ===================================*/
   IF (l_matl_rec.plant_code IS NOT NULL) THEN
      l_plant_org_id :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_matl_rec.plant_code);
   ELSE
      l_plant_org_id :=  NULL;
   END IF;

   /*============================================
      Get org and item id from Stability Study.
     ============================================*/

   OPEN get_stab_study (l_matl_rec.ss_id);
   FETCH get_stab_study INTO l_ss_orgn_code, l_ss_item_id;
   IF (get_stab_study%NOTFOUND) THEN
      CLOSE get_stab_study;
      RAISE MATL_GET_SS;
   END IF;
   CLOSE get_stab_study;

   /*===================================
      Get plant code organization_id.
      Use Stability Study if Plant orgid
      is null
     ===================================*/
   IF (l_plant_org_id IS NULL) THEN
	      l_plant_org_id  :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_ss_orgn_code);
	      IF (l_plant_org_id IS NULL) THEN
		 RAISE MATL_PLANT_ORG;
	      END IF;
	      l_lot_orgn_code :=  l_ss_orgn_code;
	   ELSE
	      l_lot_orgn_code := l_matl_rec.plant_code;
	   END IF;

	   IF (l_ss_item_id IS NOT NULL AND l_matl_rec.lot_id IS NOT NULL) THEN  --verify
	      /*=======================
		 Get Lot Number.
		=======================*/
	      inv_opm_lot_migration.GET_ODM_LOT (
		 P_MIGRATION_RUN_ID => p_migration_run_id,
		 P_ORGN_CODE => l_lot_orgn_code,
		 P_ITEM_ID => l_ss_item_id,
		 P_LOT_ID => l_matl_rec.lot_id,
		 P_WHSE_CODE => NULL,
		 P_LOCATION => NULL,
		 P_COMMIT => FND_API.G_TRUE,
		 X_LOT_NUMBER => l_lot_number,
		 X_PARENT_LOT_NUMBER => l_parent_lot_number,
		 X_FAILURE_COUNT => l_failure_count
		 );

	       IF (l_failure_count > 0) THEN
		  RAISE MATL_MIG_LOT;
	       -- Bug# 5531108
	       -- Since the migrated lot_number field is a combination of lot and sublot field removing the following else clause
	       -- so that the lot_number field is updated with l_lot_number.
	       /*ELSE
	          -- Bug# 5462876
	          -- if the item is not sublot controlled assign lot_number instead of parent_lot_number. Added nvl to the below statement.
		  l_lot_number := NVL(l_parent_lot_number, l_lot_number); */
	       END IF;
	   ELSE
	      l_lot_number := NULL;
	   END IF;

	   /*==================================
	      Update gmd_ss_material_sources.
	     ==================================*/

	   UPDATE gmd_ss_material_sources
	   SET source_organization_id = l_plant_org_id,
	       lot_number = l_lot_number,
	       migrated_ind = 1
	   WHERE  source_id = l_matl_rec.source_id
	   AND    ss_id = l_matl_rec.ss_id;

	   IF (p_commit = FND_API.G_TRUE) THEN
	      COMMIT;
	   END IF;
	   GMD_QC_MIG12.g_matl_source_upd_count := GMD_QC_MIG12.g_matl_source_upd_count + 1;

	   EXCEPTION
	     WHEN MATL_NO_ORG THEN
	      GMA_COMMON_LOGGING.gma_migration_central_log (
		      p_run_id          => p_migration_run_id,
		      p_log_level       => FND_LOG.LEVEL_ERROR,
		      p_message_token   => 'GMD_MIG_NO_ORG',
		      p_context         => 'Quality Stability Studies - gmd_ss_material_sources',
		      p_token1          => 'ORG',
		      p_token2          => 'ONAME',
		      p_token3          => 'ROWK',
		      p_token4          => 'ROWV',
		      p_param1          => l_matl_rec.plant_code,
		      p_param2          => 'PLANT_CODE',
		      p_param3          => 'SOURCE_ID',
		      p_param4          => to_char(l_matl_rec.source_id),
		      p_app_short_name  => 'GMD');
	      GMD_QC_MIG12.g_matl_source_err_count := GMD_QC_MIG12.g_matl_source_err_count + 1;
	      x_exception_count := x_exception_count + 1;

	     WHEN MATL_GET_SS THEN
	      GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_ERROR,
		       p_message_token   => 'GMD_MIG_GET_SS_ERROR',
		       p_context         => 'Quality Stability Studies - gmd_ss_material_sources',
		       p_token1          => 'STABID',
		       p_token2          => 'ROWK',
		       p_token3          => 'ROWV',
		       p_param1          => to_char(l_matl_rec.ss_id),
		       p_param2          => 'SOURCE_ID',
		       p_param3          => to_char(l_matl_rec.source_id),
		       p_app_short_name  => 'GMD');
	      GMD_QC_MIG12.g_matl_source_err_count := GMD_QC_MIG12.g_matl_source_err_count + 1;
	      x_exception_count := x_exception_count + 1;

	     WHEN MATL_PLANT_ORG THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_ERROR,
		       p_message_token   => 'GMD_MIG_PLANT_ORG_ID',
		       p_context         => 'Quality Stability Studies - gmd_ss_material_sources',
		       p_token1          => 'ORG',
		       p_token2          => 'SRC',
		       p_token3          => 'ROWK',
		       p_token4          => 'ROWV',
		       p_param1          => l_ss_orgn_code,
		       p_param2          => 'SS_ORGN_CODE',
		       p_param3          => 'SOURCE_ID',
		       p_param4          => to_char(l_matl_rec.source_id),
		       p_app_short_name  => 'GMD');
		 GMD_QC_MIG12.g_matl_source_err_count := GMD_QC_MIG12.g_matl_source_err_count + 1;
		 x_exception_count := x_exception_count + 1;

	     WHEN MATL_MIG_LOT THEN
		  GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_ERROR,
		       p_message_token   => 'GMD_MIG_LOT',
		       p_context         => 'Quality Stability Studies - gmd_ss_material_sources',
		       p_token1          => 'ROWK',
		       p_token2          => 'ROWV',
		       p_param1          => 'SOURCE_ID',
		       p_param2          => to_char(l_matl_rec.source_id),
		       p_app_short_name  => 'GMD');
		GMD_QC_MIG12.g_matl_source_err_count := GMD_QC_MIG12.g_matl_source_err_count + 1;
		x_exception_count := x_exception_count + 1;

	     WHEN OTHERS THEN
		 LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
		 GMA_COMMON_LOGGING.gma_migration_central_log (
                  p_run_id          => p_migration_run_id,
                  p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
                  p_message_token   => 'GMA_MIGRATION_DB_ERROR',
                  p_context         => 'Quality Stability Studies - gmd_ss_material_sources',
                  p_db_error        => SQLERRM,
                  p_app_short_name  => 'GMA');
                 x_exception_count := x_exception_count + 1;
		  ROLLBACK;

	   END;       -- end matl src subprogram

	END LOOP;  -- end get_matl_src



	/*==============================================
	   Log End of gmd_ss_material_sources.
	  ==============================================*/

	LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

	/*===================================
	   Log Start of gmd_ss_variants.
	  ===================================*/

	GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_EVENT,
	       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
	       p_table_name      => 'GMD_SS_VARIANTS',
	       p_token1          => 'TABLE_NAME',
	       p_param1          => 'GMD_SS_VARIANTS',
	       p_context         => 'Quality Stability Studies',
	       p_app_short_name  => 'GMA');

	GMD_QC_MIG12.g_ss_variant_pro_count := 0;
	GMD_QC_MIG12.g_ss_variant_err_count := 0;
	GMD_QC_MIG12.g_ss_variant_upd_count := 0;
	GMD_QC_MIG12.g_progress_ind := 4;

	/*==============================
	   Migrate gmd_ss_variants.
	  ==============================*/

	FOR l_var_rec IN get_ss_variant LOOP
	   BEGIN    -- variant subprogram
	   GMD_QC_MIG12.g_ss_variant_pro_count := GMD_QC_MIG12.g_ss_variant_pro_count + 1;

	   /*======================================
	      Check if uom migrated successfully.
		     Removed this check.
	     ======================================*/

	   /*===============================
	      Get org_id and subinventory
	    *===============================*/

	   IF (l_var_rec.storage_whse_code IS NOT NULL) THEN
	      GMD_QC_MIG12.GET_WHSE_INFO (
		 p_whse_code => l_var_rec.storage_whse_code,
		 x_organization_id => l_storage_organization_id,
		 x_subinv_ind => l_storage_subinvind,
		 x_loct_ctl => l_svar_loct_ctl);

	      IF (l_storage_organization_id IS NULL) THEN
		 RAISE VAR_WHSE_ERROR;
	      END IF;
	      l_storage_subinventory := l_var_rec.storage_whse_code;

	      /*========================================
		 Get Locator and compare subinventory.
	       *========================================*/

	      IF (l_var_rec.storage_location IS NOT NULL) THEN
	         IF (l_var_rec.storage_location = 'NONE') THEN
                    l_storage_locator_id := NULL;
	         ELSE
   		    l_storage_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID (
		       p_whse_code => l_var_rec.storage_whse_code,
		       p_location => l_var_rec.storage_location);
		    IF (l_storage_locator_id IS NULL) THEN
		       IF (l_svar_loct_ctl = 2) THEN
		          /*======================================
		      	     Create a Non-validated location.
		   	    ======================================*/
		          INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
		   	         p_migration_run_id  => p_migration_run_id,
			         p_organization_id   => l_storage_organization_id,
			         p_subinventory_code => l_storage_subinventory,
			         p_location          => l_var_rec.storage_location,
			         p_loct_desc         => l_var_rec.storage_location,
			         p_start_date_active => SYSDATE,
			         p_commit            => p_commit,
			         x_location_id       => l_storage_locator_id,
			         x_failure_count     => l_failure_count);

		          IF (l_failure_count > 0) THEN
			     RAISE VAR_CREATE_LOC;
		          END IF;
		       ELSE                          -- validated location
		          RAISE VAR_LOCATOR_ID;
		       END IF;                       -- validated location
		    ELSE  -- locator is not null
		       GMD_QC_MIG12.GET_SUBINV_DATA(l_storage_locator_id,
		   	          l_subinv,
			          lsub_organization_id);

		       IF (lsub_organization_id IS NULL) THEN
		          RAISE VAR_SUBINV_ERROR;
		       END IF;

		       IF (l_subinv <> l_storage_subinventory) THEN
		      	   l_storage_subinventory := l_subinv;
		          /*=============================================
			      Overlay subinventory with locator subinv.
			    =============================================*/
		       END IF;
                    END IF;   --id is null
                END IF;   --  location is none
             ELSE  -- storage location is null and whse is not null.
	        l_storage_locator_id := NULL;
	     END IF;
	  ELSE  -- whse is null
	      l_storage_locator_id := l_var_rec.storage_locator_id;
	      l_storage_subinventory := l_var_rec.storage_subinventory;
	      l_storage_organization_id := l_var_rec.storage_organization_id;
	  END IF;

	   /*===============================
	       Update gmd_ss_variants.
	    *===============================*/

	   UPDATE gmd_ss_variants
	   SET storage_organization_id = l_storage_organization_id,
	       storage_subinventory = l_storage_subinventory,
	       storage_locator_id = l_storage_locator_id,
	       migrated_ind = 1
	   WHERE  variant_id = l_var_rec.variant_id;


	   IF (p_commit = FND_API.G_TRUE) THEN
	      COMMIT;
	   END IF;

	   GMD_QC_MIG12.g_ss_variant_upd_count := GMD_QC_MIG12.g_ss_variant_upd_count + 1;

	   EXCEPTION

	     WHEN VAR_WHSE_ERROR THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_ERROR,
		       p_message_token   => 'GMD_MIG_WHSE_ERROR',
		       p_context         => 'Quality Stability Studies - gmd_ss_variants',
		       p_token1          => 'WHSE',
		       p_token2          => 'WNAME',
		       p_token3          => 'ROWK',
		       p_token4          => 'ROWV',
		       p_param1          => l_var_rec.storage_whse_code,
		       p_param2          => 'STORAGE_WHSE_CODE',
		       p_param3          => 'VARIANT_ID',
		       p_param4          => to_char(l_var_rec.variant_id),
		       p_app_short_name  => 'GMD');
		 GMD_QC_MIG12.g_ss_variant_err_count := GMD_QC_MIG12.g_ss_variant_err_count + 1;
		 x_exception_count := x_exception_count + 1;

	     WHEN VAR_CREATE_LOC THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
		     p_run_id          => p_migration_run_id,
		     p_log_level       => FND_LOG.LEVEL_ERROR,
		     p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
		     p_context         => 'Quality Stability Studies - gmd_ss_variants',
		     p_token1          => 'ROWK',
		     p_token2          => 'ROWV',
		     p_token3          => 'FNAME',
		     p_param1          => 'VARIANT_ID',
		     p_param2          => to_char(l_var_rec.variant_id),
		     p_param3          => 'STORAGE_LOCATION',
		     p_app_short_name  => 'GMD');
		  GMD_QC_MIG12.g_ss_variant_err_count := GMD_QC_MIG12.g_ss_variant_err_count + 1;
		  x_exception_count := x_exception_count + 1;

	     WHEN VAR_LOCATOR_ID THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
			  p_run_id          => p_migration_run_id,
			  p_log_level       => FND_LOG.LEVEL_ERROR,
			  p_message_token   => 'GMD_MIG_LOCATOR_ID',
			  p_context         => 'Quality Stability Studies - gmd_ss_variants',
			  p_token1          => 'WHSE',
			  p_token2          => 'LOCATION',
			  p_token3          => 'LFIELD',
			  p_token4          => 'ROWK',
			  p_token5          => 'ROWV',
			  p_param1          => l_var_rec.storage_whse_code,
			  p_param2          => l_var_rec.storage_location,
			  p_param3          => 'STORAGE_LOCATION',
			  p_param4          => 'VARIANT_ID',
			  p_param5          => to_char(l_var_rec.variant_id),
			  p_app_short_name  => 'GMD');
		 GMD_QC_MIG12.g_ss_variant_err_count := GMD_QC_MIG12.g_ss_variant_err_count + 1;
		 x_exception_count := x_exception_count + 1;

	     WHEN VAR_SUBINV_ERROR THEN
		 GMA_COMMON_LOGGING.gma_migration_central_log (
			      p_run_id          => p_migration_run_id,
			      p_log_level       => FND_LOG.LEVEL_ERROR,
			      p_message_token   => 'GMD_MIG_SUBINV',
			      p_context         => 'Quality Stability Studies - gmd_ss_variants',
			      p_token1          => 'LOCATOR',
			      p_token2          => 'ROWK',
			      p_token3          => 'ROWV',
			      p_param1          => to_char(l_storage_locator_id),
			      p_param2          => 'VARIANT_ID',
			      p_param3          => to_char(l_var_rec.variant_id),
			      p_app_short_name  => 'GMD');
		       GMD_QC_MIG12.g_ss_variant_err_count := GMD_QC_MIG12.g_ss_variant_err_count + 1;
		       x_exception_count := x_exception_count + 1;


	     WHEN OTHERS THEN
		 LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
		 GMA_COMMON_LOGGING.gma_migration_central_log (
			       p_run_id          => p_migration_run_id,
			       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
			       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			       p_context         => 'Quality Stability Studies - gmd_ss_variants',
			       p_db_error        => SQLERRM,
			       p_app_short_name  => 'GMA');
		  x_exception_count := x_exception_count + 1;
		  ROLLBACK;

	   END;     -- end variant subprogram


	END LOOP;  -- end get_ss_variant


	/*==============================================
	   Log End of gmd_ss_variants.
	  ==============================================*/

	LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);

	/*==============================================
	   Retrieve Default Storage Package Orgn Code.
	   Source is gmd_migrate_parms.
	  ==============================================*/

	BEGIN  -- get setup subprogram
	OPEN get_ss_org;
	FETCH get_ss_org INTO l_def_ss_org;
	CLOSE get_ss_org;
	IF (l_def_ss_org IS NULL) THEN
	    /*==============================================
	       Get Default Lab Type Profile Value
	      ==============================================*/
	    l_def_ss_org :=  GMD_QC_MIG12.GET_PROFILE_VALUE('GEMMS_DEFAULT_LAB_TYPE');

	    IF (l_def_ss_org IS NULL) THEN
	       RAISE NULL_DEFAULT_LAB;
	    END IF;
	END IF;

	/*==============================================
	   Get Org id for the Default Orgn Code.
	  ==============================================*/

l_def_ss_org_id  :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_def_ss_org);
IF (l_def_ss_org_id IS NULL) THEN
   RAISE DEFAULT_SS_ORG_ERROR;
END IF;

  EXCEPTION
     WHEN NULL_DEFAULT_LAB THEN
          GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEFAULT_LAB_NULL',
	       p_context         => 'Quality Stability Studies - pre gmd_ss_storage_package',
	       p_app_short_name  => 'GMD');
          ROLLBACK;
          RETURN;
          x_exception_count := x_exception_count + 1;

  WHEN DEFAULT_SS_ORG_ERROR    THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEF_SS_ORG_ERROR',
	       p_context         => 'Quality Stability Studies - pre gmd_ss_storage_package',
	       p_app_short_name  => 'GMD');
       x_exception_count := x_exception_count + 1;
       ROLLBACK;
       RETURN;

     WHEN OTHERS THEN
         LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
         GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Stability Studies - pre gmd_ss_storage_package',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
          x_exception_count := x_exception_count + 1;
          ROLLBACK;
          RETURN;


END;   -- end setup subprogram

/*==============================================
   Log Start of gmd_storage_package.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SS_STORAGE_PACKAGE',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SS_STORAGE_PACKAGE',
       p_context         => 'Quality Stability Studies',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_store_pack_upd_count :=  0;
GMD_QC_MIG12.g_store_pack_ins_count :=  0;
GMD_QC_MIG12.g_store_pack_pro_count :=  0;
GMD_QC_MIG12.g_store_pack_err_count :=  0;
GMD_QC_MIG12.g_progress_ind := 5;

FOR l_store_pack IN get_store_pack LOOP
  BEGIN    -- end get_store_pack subprogram
  GMD_QC_MIG12.g_store_pack_pro_count :=  GMD_QC_MIG12.g_store_pack_pro_count + 1;
  /*======================================
     Check if uom migrated successfully.
     Removed this check.
    ======================================*/

   /*=================================================
      If storage package has no stability study
     associated with it assign the default org to
     the package record.  If linked to 1 or more
     stability studies update this record with the
     orgn from the first stability study. For any
     other stability studies create a new
     gmd_ss_storage_package record.
     =================================================*/
   OPEN get_stab_study_org(l_store_pack.package_id);
   FETCH get_stab_study_org INTO l_stab_orgn_code, l_gsv_package_id;
   IF (get_stab_study_org%NOTFOUND) THEN
       CLOSE get_stab_study_org;
       IF (l_store_pack.item_id IS NOT NULL) THEN
	  /*=========================
	     Get Inventory Item id.
	    =========================*/
	   INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
	       P_MIGRATION_RUN_ID => p_migration_run_id,
	       P_ITEM_ID => l_store_pack.item_id,
	       P_ORGANIZATION_ID  => l_def_ss_org_id,
	       P_MODE => NULL,
               P_COMMIT => FND_API.G_TRUE,
	       X_INVENTORY_ITEM_ID => l_store_pack_invitem_id,
	       X_FAILURE_COUNT => l_failure_count);
	   IF (l_failure_count > 0) THEN
               RAISE STORE_DEF_ODM_ITEM;
	   END IF;
       ELSE
	  l_store_pack_invitem_id := NULL;
       END IF;

       /*================================
	  Update gmd_ss_storage_package
	 ================================*/

       UPDATE gmd_ss_storage_package
       SET organization_id = l_def_ss_org_id,
	   inventory_item_id = l_store_pack_invitem_id,
	   migrated_ind = 1
       WHERE  package_id = l_store_pack.package_id;

       GMD_QC_MIG12.g_store_pack_upd_count :=  GMD_QC_MIG12.g_store_pack_upd_count + 1;
   ELSE
       /*========================================
	   Use Org from Stability Study.
	 ========================================*/
       l_ss_org_id  :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_stab_orgn_code);
       IF (l_ss_org_id IS NULL) THEN
	  CLOSE get_stab_study_org;
          RAISE STORE_SS_ORG;
       END IF;

       IF (l_store_pack.item_id IS NOT NULL) THEN
	  /*=========================
	     Get Inventory Item id.
	    =========================*/
	   INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
	       P_MIGRATION_RUN_ID => p_migration_run_id,
	       P_ITEM_ID => l_store_pack.item_id,
	       P_ORGANIZATION_ID  => l_ss_org_id,
	       P_MODE => NULL,
               P_COMMIT => FND_API.G_TRUE,
	       X_INVENTORY_ITEM_ID => l_store_pack_invitem_id,
	       X_FAILURE_COUNT => l_failure_count);
	   IF (l_failure_count > 0) THEN
	       CLOSE get_stab_study_org;
               RAISE STORE_ODM_ITEM;
	   END IF;
       ELSE
	  l_store_pack_invitem_id := NULL;
       END IF;

       /*================================
	  Update gmd_ss_storage_package
	  using Stability study org.
	 ================================*/

       UPDATE gmd_ss_storage_package
       SET organization_id = l_ss_org_id,
	   inventory_item_id = l_store_pack_invitem_id,
	   migrated_ind = 1
       WHERE  package_id = l_store_pack.package_id;


   GMD_QC_MIG12.g_store_pack_upd_count :=  GMD_QC_MIG12.g_store_pack_upd_count + 1;

   /*==========================================
      Continue with Stability Studies.
     ==========================================*/

   FETCH get_stab_study_org INTO l_stab_orgn_code, l_gsv_package_id;
   WHILE get_stab_study_org%FOUND LOOP
       /*=================================
	  Create Text Code if it exists.
	 =================================*/
       IF (l_store_pack.text_code IS NOT NULL AND l_store_pack.text_code > 0) THEN
	  l_text_code :=  GMD_QC_MIG12.COPY_TEXT(l_store_pack.text_code, p_migration_run_id);
       ELSE
	  l_text_code := NULL;
       END IF;

       l_ss_org_id  :=  GMA_MIGRATION_UTILS.GET_ORGANIZATION_ID(l_stab_orgn_code);
       IF (l_ss_org_id IS NULL) THEN
	  CLOSE get_stab_study_org;
          RAISE STORE_SS_ORG;
       END IF;
       /*=========================
	  Get Inventory Item id.
	 =========================*/
       IF (l_store_pack.item_id IS NOT NULL) THEN
	  INV_OPM_ITEM_MIGRATION.GET_ODM_ITEM(
	      P_MIGRATION_RUN_ID => p_migration_run_id,
	      P_ITEM_ID => l_store_pack.item_id,
	      P_ORGANIZATION_ID  => l_ss_org_id,
	      P_MODE => NULL,
              P_COMMIT => FND_API.G_TRUE,
	      X_INVENTORY_ITEM_ID => l_store_pack_invitem_id,
	      X_FAILURE_COUNT => l_failure_count);
	  IF (l_failure_count > 0) THEN
	      CLOSE get_stab_study_org;
              RAISE STORE_ODM_ITEM;
	  END IF;
       ELSE
	  l_store_pack_invitem_id := NULL;
       END IF;

       /*================================
	  Insert gmd_ss_storage_package.
	 ================================*/

       OPEN get_pack_seq;
       FETCH get_pack_seq INTO l_package_id;
       CLOSE get_pack_seq;

       INSERT INTO gmd_ss_storage_package (
	  PACKAGE_ID,
	  FORMULA_ID,
	  QUANTITY,
	  UOM,
	  TEXT_CODE,
	  ATTRIBUTE_CATEGORY,
	  ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
	  ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
	  ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
	  ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20,
	  ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25,
	  ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,
	  DELETE_MARK,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN,
	  ITEM_ID,
	  PACKAGE_NAME,
	  MIGRATED_IND,
	  ORGANIZATION_ID,
	  QUANTITY_UOM,
	  INVENTORY_ITEM_ID
       )
       VALUES (
	  l_package_id,
	  l_store_pack.FORMULA_ID,
	  l_store_pack.QUANTITY,
	  l_store_pack.UOM,
	  l_text_code,
	  l_store_pack.ATTRIBUTE_CATEGORY,
	  l_store_pack.ATTRIBUTE1, l_store_pack.ATTRIBUTE2, l_store_pack.ATTRIBUTE3,
	  l_store_pack.ATTRIBUTE4, l_store_pack.ATTRIBUTE5, l_store_pack.ATTRIBUTE6,
	  l_store_pack.ATTRIBUTE7, l_store_pack.ATTRIBUTE8, l_store_pack.ATTRIBUTE9,
	  l_store_pack.ATTRIBUTE10, l_store_pack.ATTRIBUTE11, l_store_pack.ATTRIBUTE12,
	  l_store_pack.ATTRIBUTE13, l_store_pack.ATTRIBUTE14, l_store_pack.ATTRIBUTE15,
	  l_store_pack.ATTRIBUTE16, l_store_pack.ATTRIBUTE17, l_store_pack.ATTRIBUTE18,
	  l_store_pack.ATTRIBUTE19, l_store_pack.ATTRIBUTE20, l_store_pack.ATTRIBUTE21,
	  l_store_pack.ATTRIBUTE22, l_store_pack.ATTRIBUTE23, l_store_pack.ATTRIBUTE24,
	  l_store_pack.ATTRIBUTE25, l_store_pack.ATTRIBUTE26, l_store_pack.ATTRIBUTE27,
	  l_store_pack.ATTRIBUTE28, l_store_pack.ATTRIBUTE29, l_store_pack.ATTRIBUTE30,
	  l_store_pack.DELETE_MARK,
	  SYSDATE,
	  0,
	  0,
	  SYSDATE,
	  0,
	  l_store_pack.ITEM_ID,
	  l_store_pack.PACKAGE_NAME,
	  1,
	  l_ss_org_id,
	  l_store_pack.QUANTITY_UOM,
	  l_store_pack.INVENTORY_ITEM_ID
       );

       GMD_QC_MIG12.g_store_pack_ins_count := GMD_QC_MIG12.g_store_pack_ins_count + 1;

       /*================================
	  Update gmd_ss_variants to point
          to new package record.
	 ================================*/

       UPDATE gmd_ss_variants
       SET package_id = l_package_id
       WHERE package_id = l_store_pack.package_id
       AND ss_id IN (select ss_id from gmd_stability_studies_b where orgn_code = l_stab_orgn_code);

      -- AND ss_id = (select ss_id from gmd_stability_studies_b where organization_id = l_ss_org_id);


       FETCH get_stab_study_org INTO l_stab_orgn_code, l_gsv_package_id;

   END LOOP;

   CLOSE get_stab_study_org;
   END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

  EXCEPTION
     WHEN STORE_DEF_ODM_ITEM THEN
	       GMA_COMMON_LOGGING.gma_migration_central_log (
		  p_run_id          => p_migration_run_id,
		  p_log_level       => FND_LOG.LEVEL_ERROR,
		  p_message_token   => 'GMD_MIG_ODM_ITEM',
		  p_context         => 'Quality Stability Studies - gmd_ss_storage_package',
		  p_token1          => 'ORG',
		  p_token2          => 'ITEMID',
		  p_token3          => 'ROWK',
		  p_token4          => 'ROWV',
		  p_param1          => to_char(l_def_ss_org_id),
		  p_param2          => to_char(l_store_pack.item_id),
		  p_param3          => 'PACKAGE_ID',
		  p_param4          => to_char(l_store_pack.package_id),
		  p_app_short_name  => 'GMD');
              ROLLBACK;
	      GMD_QC_MIG12.g_store_pack_err_count :=  GMD_QC_MIG12.g_store_pack_err_count + 1;
              x_exception_count := x_exception_count + 1;


     WHEN STORE_SS_ORG THEN
	  GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_SS_ORG',
	       p_context         => 'Quality Stability Studies - gmd_ss_storage_package',
	       p_token1          => 'ORG',
	       p_token2          => 'ROWK',
	       p_token3          => 'ROWV',
	       p_param1          => l_stab_orgn_code,
	       p_param2          => 'PACKAGE_ID',
	       p_param3          => to_char(l_store_pack.package_id),
	       p_app_short_name  => 'GMD');
          ROLLBACK;
	  GMD_QC_MIG12.g_store_pack_err_count :=  GMD_QC_MIG12.g_store_pack_err_count + 1;
          x_exception_count := x_exception_count + 1;

     WHEN STORE_ODM_ITEM THEN
	       GMA_COMMON_LOGGING.gma_migration_central_log (
		  p_run_id          => p_migration_run_id,
		  p_log_level       => FND_LOG.LEVEL_ERROR,
		  p_message_token   => 'GMD_MIG_ODM_ITEM',
		  p_context         => 'Quality Stability Studies - gmd_ss_storage_package',
		  p_token1          => 'ORG',
		  p_token2          => 'ITEMID',
		  p_token3          => 'ROWK',
		  p_token4          => 'ROWV',
		  p_param1          => to_char(l_ss_org_id),
		  p_param2          => to_char(l_store_pack.item_id),
		  p_param3          => 'PACKAGE_ID',
		  p_param4          => to_char(l_store_pack.package_id),
		  p_app_short_name  => 'GMD');
              ROLLBACK;
	      GMD_QC_MIG12.g_store_pack_err_count :=  GMD_QC_MIG12.g_store_pack_err_count + 1;
              x_exception_count := x_exception_count + 1;


     WHEN OTHERS THEN
         LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
         GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
		       p_context         => 'Quality Stability Studies - gmd_ss_storage_package',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
          x_exception_count := x_exception_count + 1;
          ROLLBACK;
  END;     -- end get_store_pack subprogram


END LOOP;   -- end get_store_pack


/*==============================================
   Log End of gmd_ss_storage_package.
  ==============================================*/

LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


/*==============================================
   Log Start of gmd_ss_storage_history.
  ==============================================*/

GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => p_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_EVENT,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GMD_SS_STORAGE_HISTORY',
       p_token1          => 'TABLE_NAME',
       p_param1          => 'GMD_SS_STORAGE_HISTORY',
       p_context         => 'Quality Stability Studies',
       p_app_short_name  => 'GMA');

GMD_QC_MIG12.g_ss_storehist_pro_count := 0;
GMD_QC_MIG12.g_ss_storehist_err_count := 0;
GMD_QC_MIG12.g_ss_storehist_upd_count := 0;
GMD_QC_MIG12.g_progress_ind := 6;

/*====================================
   Migrate gmd_ss_storage_history.
  ====================================*/

FOR l_hist_rec IN get_ss_history LOOP
   BEGIN       -- end get_ss_hist subprogram
   GMD_QC_MIG12.g_ss_storehist_pro_count := GMD_QC_MIG12.g_ss_storehist_pro_count + 1;
   /*===============================
      Get org_id and subinventory
     ===============================*/

   IF (l_hist_rec.whse_code IS NOT NULL) THEN
      GMD_QC_MIG12.GET_WHSE_INFO (
	 p_whse_code => l_hist_rec.whse_code,
	 x_organization_id => l_hist_org_id,
	 x_subinv_ind => l_hist_subinvind,
	 x_loct_ctl => l_hist_loct_ctl);

      IF (l_hist_org_id IS NULL) THEN
         RAISE HIST_WHSE_ERROR;
      END IF;

      l_hist_subinventory := l_hist_rec.whse_code;

      /*========================================
	 Get Locator and compare subinventory.
	========================================*/

      IF (l_hist_rec.location IS NOT NULL) THEN
         IF (l_hist_rec.location = 'NONE') THEN
           l_hist_locator_id := NULL;
         ELSE
   	    l_hist_locator_id := GMD_QC_MIG12.GET_LOCATOR_ID (
	       p_whse_code => l_hist_rec.whse_code,
	       p_location => l_hist_rec.location);

	    IF (l_hist_locator_id IS NULL) THEN
	       IF (l_hist_loct_ctl = 2) THEN
	          /*======================================
	   	     Create a Non-validated location.
		    ======================================*/
                  INV_MIGRATE_PROCESS_ORG.CREATE_LOCATION (
		         p_migration_run_id  => p_migration_run_id,
		         p_organization_id   => l_hist_org_id,
		         p_subinventory_code => l_hist_subinventory,
		         p_location          => l_hist_rec.location,
		         p_loct_desc         => l_hist_rec.location,
		         p_start_date_active => SYSDATE,
		         p_commit            => p_commit,
		         x_location_id       => l_hist_locator_id,
		         x_failure_count     => l_failure_count);

	          IF (l_failure_count > 0) THEN
                     RAISE HIST_CREATE_LOC;
	          END IF;
	       ELSE
                  RAISE HIST_LOCATOR_ID;
	      END IF;
           END IF;   -- none location
	 END IF;

         IF (l_hist_locator_id IS NOT NULL) THEN
	    GMD_QC_MIG12.GET_SUBINV_DATA(l_hist_locator_id,
	   		       l_subinv,
			       lsub_organization_id);

            IF (lsub_organization_id IS NULL) THEN
                RAISE HIST_SUBINV_ERROR;
            END IF;

	    IF (l_subinv <> l_hist_subinventory) THEN
	        /*=========================================
	   	   Overlay subinv with one from locator.
	          =========================================*/
                l_hist_subinventory := l_subinv;
	     END IF;
   	   ELSE
	        l_hist_locator_id := l_hist_rec.locator_id;
	   END IF;
         END IF;   -- locator is null;
   ELSE  -- whse is null
      l_hist_org_id := l_hist_rec.organization_id;
      l_hist_subinventory := l_hist_rec.subinventory;
      l_hist_locator_id := l_hist_rec.locator_id;
   END IF;

   /*===================================
       Update gmd_ss_storage_history.
    *===================================*/

   UPDATE gmd_ss_storage_history
   SET subinventory = l_hist_subinventory,
       locator_id = l_hist_locator_id,
       organization_id = l_hist_org_id,
       migrated_ind = 1
   WHERE  storage_history_id = l_hist_rec.storage_history_id;

   IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
   END IF;

   GMD_QC_MIG12.g_ss_storehist_upd_count := GMD_QC_MIG12.g_ss_storehist_upd_count + 1;

   EXCEPTION
     WHEN HIST_WHSE_ERROR THEN
	 GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_WHSE_ERROR',
	       p_context         => 'Quality Stability Studies - gmd_ss_storage_history',
	       p_token1          => 'WHSE',
	       p_token2          => 'WNAME',
	       p_token3          => 'ROWK',
	       p_token4          => 'ROWV',
	       p_param1          => l_hist_rec.whse_code,
	       p_param2          => 'WHSE_CODE',
	       p_param3          => 'STORAGE_HISTORY_ID',
	       p_param4          => to_char(l_hist_rec.storage_history_id),
	       p_app_short_name  => 'GMD');
	 GMD_QC_MIG12.g_ss_storehist_err_count := GMD_QC_MIG12.g_ss_storehist_err_count + 1;
         x_exception_count := x_exception_count + 1;

     WHEN HIST_CREATE_LOC THEN
		  GMA_COMMON_LOGGING.gma_migration_central_log (
		     p_run_id          => p_migration_run_id,
		     p_log_level       => FND_LOG.LEVEL_ERROR,
		     p_message_token   => 'GMD_MIG_NONLOC_FAILURE',
	             p_context         => 'Quality Stability Studies - gmd_ss_storage_history',
		     p_token1          => 'ROWK',
		     p_token2          => 'ROWV',
		     p_token3          => 'FNAME',
		     p_param1          => 'STORAGE_HISTORY_ID',
		     p_param2          => to_char(l_hist_rec.storage_history_id),
		     p_param3          => 'LOCATION',
		     p_app_short_name  => 'GMD');
		  GMD_QC_MIG12.g_ss_storehist_err_count := GMD_QC_MIG12.g_ss_storehist_err_count + 1;
                  x_exception_count := x_exception_count + 1;

     WHEN HIST_LOCATOR_ID THEN
	       GMA_COMMON_LOGGING.gma_migration_central_log (
		  p_run_id          => p_migration_run_id,
		  p_log_level       => FND_LOG.LEVEL_ERROR,
		  p_message_token   => 'GMD_MIG_LOCATOR_ID',
	          p_context         => 'Quality Stability Studies - gmd_ss_storage_history',
		  p_token1          => 'WHSE',
		  p_token2          => 'LOCATION',
		  p_token3          => 'LFIELD',
		  p_token4          => 'ROWK',
		  p_token5          => 'ROWV',
		  p_param1          => l_hist_rec.whse_code,
		  p_param2          => l_hist_rec.location,
		  p_param3          => 'LOCATION',
		  p_param4          => 'STORAGE_HISTORY_ID',
		  p_param5          => to_char(l_hist_rec.storage_history_id),
	       p_app_short_name  => 'GMD');
	       GMD_QC_MIG12.g_ss_storehist_err_count := GMD_QC_MIG12.g_ss_storehist_err_count + 1;
               x_exception_count := x_exception_count + 1;

     WHEN HIST_SUBINV_ERROR THEN
             GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => p_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_ERROR,
                   p_message_token   => 'GMD_MIG_SUBINV',
	           p_context         => 'Quality Stability Studies - gmd_ss_storage_history',
       	           p_token1          => 'LOCATOR',
               	   p_token2          => 'ROWK',
               	   p_token3          => 'ROWV',
                   p_param1          => to_char(l_hist_locator_id),
		   p_param2          => 'STORAGE_HISTORY_ID',
		   p_param3          => to_char(l_hist_rec.storage_history_id),
                   p_app_short_name  => 'GMD');
	     GMD_QC_MIG12.g_ss_storehist_err_count := GMD_QC_MIG12.g_ss_storehist_err_count + 1;
             x_exception_count := x_exception_count + 1;

     WHEN OTHERS THEN
         LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
         GMA_COMMON_LOGGING.gma_migration_central_log (
		       p_run_id          => p_migration_run_id,
		       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
		       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
	               p_context         => 'Quality Stability Studies - gmd_ss_storage_history',
		       p_db_error        => SQLERRM,
		       p_app_short_name  => 'GMA');
          x_exception_count := x_exception_count + 1;
          ROLLBACK;

   END;    -- end get_ss_hist subprogram

END LOOP;   -- end get_ss_history


/*==============================================
   Log End of gmd_ss_storage_history.
  ==============================================*/

LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);


EXCEPTION

  WHEN DEFAULT_SS_ORG_ERROR    THEN
      GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_ERROR,
	       p_message_token   => 'GMD_MIG_DEF_SS_ORG_ERROR',
	       p_context         => 'Quality Stability Studies - general',
	       p_app_short_name  => 'GMD');

     x_exception_count := x_exception_count + 1;

  WHEN OTHERS THEN
      LOG_SS_COUNTS(p_migration_run_id, GMD_QC_MIG12.g_progress_ind);
      GMA_COMMON_LOGGING.gma_migration_central_log (
	       p_run_id          => p_migration_run_id,
	       p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
	       p_message_token   => 'GMA_MIGRATION_DB_ERROR',
	       p_context         => 'Quality Stability Studies - general',
	       p_db_error        => SQLERRM,
	       p_app_short_name  => 'GMA');
     x_exception_count := x_exception_count + 1;

END GMD_QC_MIGRATE_STABS;


END;

/

--------------------------------------------------------
--  DDL for Package GMD_QC_MIG12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_MIG12" AUTHID CURRENT_USER AS
/* $Header: gmdmg12s.pls 120.1 2005/08/04 11:59:56 jdiiorio noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmg12s.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIG12                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package migration procedures for Quality for 12 migration.       |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/

/*=================================
   Database Log Counters
  =================================*/

g_progress_ind                  NUMBER;

g_test_method_upd_count         NUMBER;
g_test_method_err_count         NUMBER;
g_test_method_pro_count         NUMBER;
g_quality_config_ins_count      NUMBER;
g_quality_config_upd_count      NUMBER;
g_quality_config_err_count      NUMBER;
g_quality_config_pro_count      NUMBER;
g_sampling_plan_pro_count       NUMBER;
g_sampling_plan_upd_count       NUMBER;
g_sampling_plan_err_count       NUMBER;
g_sample_upd_count              NUMBER;
g_sample_err_count              NUMBER;
g_sample_pro_count              NUMBER;
g_result_upd_count              NUMBER;
g_result_err_count              NUMBER;
g_result_pro_count              NUMBER;
g_sample_event_upd_count        NUMBER;
g_sample_event_err_count        NUMBER;
g_sample_event_pro_count        NUMBER;
g_store_plan_upd_count          NUMBER;
g_store_plan_err_count          NUMBER;
g_store_plan_pro_count          NUMBER;
g_store_pack_pro_count          NUMBER;
g_store_pack_upd_count          NUMBER;
g_store_pack_err_count          NUMBER;
g_store_pack_ins_count          NUMBER;
g_stab_pro_count                NUMBER;
g_stab_upd_count                NUMBER;
g_stab_err_count                NUMBER;
g_matl_source_pro_count         NUMBER;
g_matl_source_upd_count         NUMBER;
g_matl_source_err_count         NUMBER;
g_ss_variant_pro_count          NUMBER;
g_ss_variant_upd_count          NUMBER;
g_ss_variant_err_count          NUMBER;
g_ss_storehist_pro_count        NUMBER;
g_ss_storehist_upd_count        NUMBER;
g_ss_storehist_err_count        NUMBER;
g_inv_spec_pro_count            NUMBER;
g_inv_spec_ins_count            NUMBER;
g_inv_spec_del_count            NUMBER;
g_inv_spec_upd_count            NUMBER;
g_inv_spec_err_count            NUMBER;
g_specs_pro_count               NUMBER;
g_specs_upd_count               NUMBER;
g_specs_err_count               NUMBER;
g_wip_spec_pro_count            NUMBER;
g_wip_spec_ins_count            NUMBER;
g_wip_spec_del_count            NUMBER;
g_wip_spec_upd_count            NUMBER;
g_wip_spec_err_count            NUMBER;
g_cust_spec_pro_count           NUMBER;
g_cust_spec_ins_count           NUMBER;
g_cust_spec_del_count           NUMBER;
g_cust_spec_upd_count           NUMBER;
g_cust_spec_err_count           NUMBER;
g_supl_spec_pro_count           NUMBER;
g_supl_spec_ins_count           NUMBER;
g_supl_spec_upd_count           NUMBER;
g_supl_spec_del_count           NUMBER;
g_supl_spec_err_count           NUMBER;
g_mon_spec_pro_count            NUMBER;
g_mon_spec_ins_count            NUMBER;
g_mon_spec_del_count            NUMBER;
g_mon_spec_upd_count            NUMBER;
g_mon_spec_err_count            NUMBER;

PROCEDURE GMD_QC_MIGRATE_SETUP
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER
);

PROCEDURE GMD_QC_MIGRATE_SAMPLES
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER
);

PROCEDURE GMD_QC_MIGRATE_SPECS
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER
);

PROCEDURE GMD_QC_MIGRATE_STABS
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER
);


END GMD_QC_MIG12;

 

/

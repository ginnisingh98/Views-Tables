--------------------------------------------------------
--  DDL for Package MTL_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_PARAMETERS_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVSDOOS.pls 120.3.12010000.9 2010/05/25 10:21:02 krishnak ship $ */
  g_pkg_name CONSTANT VARCHAR2(30) := 'MTL_PARAMETERS_PKG';

  PROCEDURE insert_row(
    x_rowid                        IN OUT NOCOPY VARCHAR2
  , x_organization_id                            NUMBER
  , x_last_update_date                           DATE
  , x_last_updated_by                            NUMBER
  , x_creation_date                              DATE
  , x_created_by                                 NUMBER
  , x_last_update_login                          NUMBER
  , x_organization_code                          VARCHAR2
  , x_master_organization_id                     NUMBER
  , x_primary_cost_method                        NUMBER
  , x_cost_organization_id                       NUMBER
  , x_default_material_cost_id                   NUMBER
  , x_default_matl_ovhd_cost_id                  NUMBER
  , x_calendar_exception_set_id                  NUMBER
  , x_calendar_code                              VARCHAR2
  , x_general_ledger_update_code                 NUMBER
  , x_default_atp_rule_id                        NUMBER
  , x_default_picking_rule_id                    NUMBER
  , x_default_locator_order_value                NUMBER
  , x_default_subinv_order_value                 NUMBER
  , x_negative_inv_receipt_code                  NUMBER
  , x_stock_locator_control_code                 NUMBER
  , x_material_account                           NUMBER
  , x_material_overhead_account                  NUMBER
  , x_matl_ovhd_absorption_acct                  NUMBER
  , x_resource_account                           NUMBER
  , x_purchase_price_var_account                 NUMBER
  , x_ap_accrual_account                         NUMBER
  , x_overhead_account                           NUMBER
  , x_outside_processing_account                 NUMBER
  , x_intransit_inv_account                      NUMBER
  , x_interorg_receivables_account               NUMBER
  , x_interorg_price_var_account                 NUMBER
  , x_interorg_payables_account                  NUMBER
  , x_cost_of_sales_account                      NUMBER
  , x_encumbrance_account                        NUMBER
  , x_interorg_transfer_cr_account               NUMBER
  , x_matl_interorg_transfer_code                NUMBER
  , x_interorg_trnsfr_charge_perc                NUMBER
  , x_source_organization_id                     NUMBER
  , x_source_subinventory                        VARCHAR2
  , x_source_type                                NUMBER
  , x_serial_number_type                         NUMBER
  , x_auto_serial_alpha_prefix                   VARCHAR2
  , x_start_auto_serial_number                   VARCHAR2
  , x_auto_lot_alpha_prefix                      VARCHAR2
  , x_lot_number_uniqueness                      NUMBER
  , x_lot_number_generation                      NUMBER
  , x_lot_number_zero_padding                    NUMBER
  , x_lot_number_length                          NUMBER
  , x_starting_revision                          VARCHAR2
  , x_attribute_category                         VARCHAR2
  , x_attribute1                                 VARCHAR2
  , x_attribute2                                 VARCHAR2
  , x_attribute3                                 VARCHAR2
  , x_attribute4                                 VARCHAR2
  , x_attribute5                                 VARCHAR2
  , x_attribute6                                 VARCHAR2
  , x_attribute7                                 VARCHAR2
  , x_attribute8                                 VARCHAR2
  , x_attribute9                                 VARCHAR2
  , x_attribute10                                VARCHAR2
  , x_attribute11                                VARCHAR2
  , x_attribute12                                VARCHAR2
  , x_attribute13                                VARCHAR2
  , x_attribute14                                VARCHAR2
  , x_attribute15                                VARCHAR2
  , x_global_attribute_category                  VARCHAR2
  , x_global_attribute1                          VARCHAR2
  , x_global_attribute2                          VARCHAR2
  , x_global_attribute3                          VARCHAR2
  , x_global_attribute4                          VARCHAR2
  , x_global_attribute5                          VARCHAR2
  , x_global_attribute6                          VARCHAR2
  , x_global_attribute7                          VARCHAR2
  , x_global_attribute8                          VARCHAR2
  , x_global_attribute9                          VARCHAR2
  , x_global_attribute10                         VARCHAR2
  , x_global_attribute11                         VARCHAR2
  , x_global_attribute12                         VARCHAR2
  , x_global_attribute13                         VARCHAR2
  , x_global_attribute14                         VARCHAR2
  , x_global_attribute15                         VARCHAR2
  , x_global_attribute16                         VARCHAR2
  , x_global_attribute17                         VARCHAR2
  , x_global_attribute18                         VARCHAR2
  , x_global_attribute19                         VARCHAR2
  , x_global_attribute20                         VARCHAR2
  , x_default_demand_class                       VARCHAR2
  , x_encumbrance_reversal_flag                  NUMBER
  , x_maintain_fifo_qty_stack_type               NUMBER
  , x_invoice_price_var_account                  NUMBER
  , x_average_cost_var_account                   NUMBER
-- For Bug 7440217
  , x_lcm_var_account                            NUMBER
-- End for Bug 7440217
  , x_sales_account                              NUMBER
  , x_expense_account                            NUMBER
  , x_serial_number_generation                   NUMBER
  , x_project_reference_enabled                  NUMBER
  , x_pm_cost_collection_enabled                 NUMBER
  , x_project_control_level                      NUMBER
  , x_avg_rates_cost_type_id                     NUMBER
  , x_txn_approval_timeout_period                NUMBER
  , x_borrpay_matl_var_account                   NUMBER
  , x_borrpay_moh_var_account                    NUMBER
  , x_borrpay_res_var_account                    NUMBER
  , x_borrpay_osp_var_account                    NUMBER
  , x_borrpay_ovh_var_account                    NUMBER
  , x_org_max_weight                             NUMBER
  , x_org_max_volume                             NUMBER
  , x_org_max_weight_uom_code                    VARCHAR2
  , x_org_max_volume_uom_code                    VARCHAR2
  , x_mo_source_required                         NUMBER
  , x_mo_pick_confirm_required                   NUMBER
  , x_mo_approval_timeout_action                 NUMBER
  , x_project_cost_account                       NUMBER
  , x_process_enabled_flag                       VARCHAR2
  , x_process_orgn_code                          VARCHAR2
  , x_default_cost_group_id                      NUMBER
  , x_lpn_prefix                                 VARCHAR2
  , x_lpn_suffix                                 VARCHAR2
  , x_lpn_starting_number                        NUMBER
  , x_wms_enabled_flag                           VARCHAR2
-- For Bug 7440217
  , x_lcm_enabled_flag                           VARCHAR2
-- End for Bug 7440217
  , x_qa_skipping_insp_flag                      VARCHAR2
  , x_eam_enabled_flag                           VARCHAR2
  , x_maint_organization_id                      NUMBER
  , x_pregen_putaway_tasks_flag                  NUMBER
  , x_regeneration_interval                      NUMBER
  , x_timezone_id                                NUMBER
  , x_default_wms_picking_rule_id                NUMBER
  , x_default_put_away_rule_id                   NUMBER
  , x_default_carton_rule_id                     NUMBER
  , x_default_cyc_count_header_id                NUMBER
  , x_crossdock_flag                             NUMBER
  , x_cartonization_flag                         NUMBER
  , x_allocate_serial_flag                       VARCHAR2
  , x_default_pick_task_type_id                  NUMBER
  , x_default_repl_task_type_id                  NUMBER
  , x_default_cc_task_type_id                    NUMBER
  , x_default_putaway_task_type_id               NUMBER
  , x_cost_cutoff_date                           DATE
  , x_skip_task_waiting_minutes                  NUMBER
  , x_prioritize_wip_jobs                        NUMBER
  , x_default_xdock_subinventory                 VARCHAR2
  , x_default_xdock_locator_id                   NUMBER
  , x_distri_organization_flag                   VARCHAR2
  , x_carrier_manifesting_flag                   VARCHAR2
  , x_distribution_account_id                    NUMBER
  , x_direct_shipping_allowed                    VARCHAR2
  , x_default_moxfer_task_type_id                NUMBER
  , x_default_moissue_task_type_id               NUMBER
  , x_max_clusters_allowed                       NUMBER DEFAULT NULL
  , x_default_pick_op_plan_id                    NUMBER DEFAULT 1
  , x_consigned_flag                             VARCHAR2 DEFAULT NULL
  , x_cartonize_sales_orders                     VARCHAR2 DEFAULT 'Y'
  , x_cartonize_manufacturing                    VARCHAR2 DEFAULT 'N'
  , x_total_lpn_length                           NUMBER DEFAULT NULL
  , x_ucc_128_suffix_flag                        VARCHAR2 DEFAULT NULL
  , x_defer_logical_transactions                 NUMBER DEFAULT 2
  , x_wip_overpick_enabled                       VARCHAR2 DEFAULT 'N' --OVPK
  , x_ovpk_transfer_orders_enabled               VARCHAR2 DEFAULT 'Y' --OVPK
  , x_auto_del_alloc_flag                        VARCHAR2 --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD                  NUMBER -- 11.5.10+ RFID Compliance
  , x_parent_child_generation_flag               VARCHAR2 DEFAULT NULL
  , x_child_lot_zero_padding_flag                VARCHAR2 DEFAULT NULL
  , x_child_lot_alpha_prefix                     VARCHAR2 DEFAULT NULL
  , x_child_lot_number_length                    NUMBER DEFAULT NULL
  , x_child_lot_validation_flag                  VARCHAR2 DEFAULT NULL
  , x_copy_lot_attribute_flag                    VARCHAR2 DEFAULT NULL
  , x_create_lot_uom_conversion                  NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status                     NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve                 VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                                VARCHAR2 DEFAULT 'N'   -- MHP
  , x_trading_partner_org_flag                   VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account                      NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id              NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag              VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag                VARCHAR2 DEFAULT NULL
  , x_company_prefix                             VARCHAR2 DEFAULT NULL
  , x_company_prefix_index                       VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number              VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag              VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM by
  );

  PROCEDURE lock_row(
    x_rowid                        VARCHAR2
  , x_organization_id              NUMBER
  , x_organization_code            VARCHAR2
  , x_master_organization_id       NUMBER
  , x_primary_cost_method          NUMBER
  , x_cost_organization_id         NUMBER
  , x_default_material_cost_id     NUMBER
  , x_default_matl_ovhd_cost_id    NUMBER
  , x_calendar_exception_set_id    NUMBER
  , x_calendar_code                VARCHAR2
  , x_general_ledger_update_code   NUMBER
  , x_default_atp_rule_id          NUMBER
  , x_default_picking_rule_id      NUMBER
  , x_default_locator_order_value  NUMBER
  , x_default_subinv_order_value   NUMBER
  , x_negative_inv_receipt_code    NUMBER
  , x_stock_locator_control_code   NUMBER
  , x_material_account             NUMBER
  , x_material_overhead_account    NUMBER
  , x_matl_ovhd_absorption_acct    NUMBER
  , x_resource_account             NUMBER
  , x_purchase_price_var_account   NUMBER
  , x_ap_accrual_account           NUMBER
  , x_overhead_account             NUMBER
  , x_outside_processing_account   NUMBER
  , x_intransit_inv_account        NUMBER
  , x_interorg_receivables_account NUMBER
  , x_interorg_price_var_account   NUMBER
  , x_interorg_payables_account    NUMBER
  , x_cost_of_sales_account        NUMBER
  , x_encumbrance_account          NUMBER
  , x_interorg_transfer_cr_account NUMBER
  , x_matl_interorg_transfer_code  NUMBER
  , x_interorg_trnsfr_charge_perc  NUMBER
  , x_source_organization_id       NUMBER
  , x_source_subinventory          VARCHAR2
  , x_source_type                  NUMBER
  , x_serial_number_type           NUMBER
  , x_auto_serial_alpha_prefix     VARCHAR2
  , x_start_auto_serial_number     VARCHAR2
  , x_auto_lot_alpha_prefix        VARCHAR2
  , x_lot_number_uniqueness        NUMBER
  , x_lot_number_generation        NUMBER
  , x_lot_number_zero_padding      NUMBER
  , x_lot_number_length            NUMBER
  , x_starting_revision            VARCHAR2
  , x_attribute_category           VARCHAR2
  , x_attribute1                   VARCHAR2
  , x_attribute2                   VARCHAR2
  , x_attribute3                   VARCHAR2
  , x_attribute4                   VARCHAR2
  , x_attribute5                   VARCHAR2
  , x_attribute6                   VARCHAR2
  , x_attribute7                   VARCHAR2
  , x_attribute8                   VARCHAR2
  , x_attribute9                   VARCHAR2
  , x_attribute10                  VARCHAR2
  , x_attribute11                  VARCHAR2
  , x_attribute12                  VARCHAR2
  , x_attribute13                  VARCHAR2
  , x_attribute14                  VARCHAR2
  , x_attribute15                  VARCHAR2
  , x_global_attribute_category    VARCHAR2
  , x_global_attribute1            VARCHAR2
  , x_global_attribute2            VARCHAR2
  , x_global_attribute3            VARCHAR2
  , x_global_attribute4            VARCHAR2
  , x_global_attribute5            VARCHAR2
  , x_global_attribute6            VARCHAR2
  , x_global_attribute7            VARCHAR2
  , x_global_attribute8            VARCHAR2
  , x_global_attribute9            VARCHAR2
  , x_global_attribute10           VARCHAR2
  , x_global_attribute11           VARCHAR2
  , x_global_attribute12           VARCHAR2
  , x_global_attribute13           VARCHAR2
  , x_global_attribute14           VARCHAR2
  , x_global_attribute15           VARCHAR2
  , x_global_attribute16           VARCHAR2
  , x_global_attribute17           VARCHAR2
  , x_global_attribute18           VARCHAR2
  , x_global_attribute19           VARCHAR2
  , x_global_attribute20           VARCHAR2
  , x_default_demand_class         VARCHAR2
  , x_encumbrance_reversal_flag    NUMBER
  , x_maintain_fifo_qty_stack_type NUMBER
  , x_invoice_price_var_account    NUMBER
  , x_average_cost_var_account     NUMBER
-- For Bug 7440217
  , x_lcm_var_account              NUMBER
-- End for Bug 7440217
  , x_sales_account                NUMBER
  , x_expense_account              NUMBER
  , x_serial_number_generation     NUMBER
  , x_project_reference_enabled    NUMBER
  , x_pm_cost_collection_enabled   NUMBER
  , x_project_control_level        NUMBER
  , x_avg_rates_cost_type_id       NUMBER
  , x_txn_approval_timeout_period  NUMBER
  , x_borrpay_matl_var_account     NUMBER
  , x_borrpay_moh_var_account      NUMBER
  , x_borrpay_res_var_account      NUMBER
  , x_borrpay_osp_var_account      NUMBER
  , x_borrpay_ovh_var_account      NUMBER
  , x_org_max_weight               NUMBER
  , x_org_max_volume               NUMBER
  , x_org_max_weight_uom_code      VARCHAR2
  , x_org_max_volume_uom_code      VARCHAR2
  , x_mo_source_required           NUMBER
  , x_mo_pick_confirm_required     NUMBER
  , x_mo_approval_timeout_action   NUMBER
  , x_project_cost_account         NUMBER
  , x_process_enabled_flag         VARCHAR2
  , x_process_orgn_code            VARCHAR2
  , x_default_cost_group_id        NUMBER
  , x_lpn_prefix                   VARCHAR2
  , x_lpn_suffix                   VARCHAR2
  , x_lpn_starting_number          NUMBER
  , x_wms_enabled_flag             VARCHAR2
-- For Bug 7440217
  , x_lcm_enabled_flag             VARCHAR2
-- End for Bug 7440217
  , x_qa_skipping_insp_flag        VARCHAR2
  , x_eam_enabled_flag             VARCHAR2
  , x_maint_organization_id        NUMBER
  , x_pregen_putaway_tasks_flag    NUMBER
  , x_regeneration_interval        NUMBER
  , x_timezone_id                  NUMBER
  , x_default_wms_picking_rule_id  NUMBER
  , x_default_put_away_rule_id     NUMBER
  , x_default_carton_rule_id       NUMBER
  , x_default_cyc_count_header_id  NUMBER
  , x_crossdock_flag               NUMBER
  , x_cartonization_flag           NUMBER
  , x_allocate_serial_flag         VARCHAR2
  , x_default_pick_task_type_id    NUMBER
  , x_default_repl_task_type_id    NUMBER
  , x_default_cc_task_type_id      NUMBER
  , x_default_putaway_task_type_id NUMBER
  , x_cost_cutoff_date             DATE
  , x_skip_task_waiting_minutes    NUMBER
  , x_prioritize_wip_jobs          NUMBER
  , x_default_xdock_subinventory   VARCHAR2
  , x_default_xdock_locator_id     NUMBER
  , x_distri_organization_flag     VARCHAR2
  , x_carrier_manifesting_flag     VARCHAR2
  , x_distribution_account_id      NUMBER
  , x_direct_shipping_allowed      VARCHAR2
  , x_default_moxfer_task_type_id  NUMBER
  , x_default_moissue_task_type_id NUMBER
  , x_max_clusters_allowed         NUMBER DEFAULT NULL
  , x_default_pick_op_plan_id      NUMBER DEFAULT 1
  , x_consigned_flag               VARCHAR2 DEFAULT NULL
  , x_cartonize_sales_orders       VARCHAR2 DEFAULT 'Y'
  , x_cartonize_manufacturing      VARCHAR2 DEFAULT 'N'
  , x_total_lpn_length             NUMBER DEFAULT NULL
  , x_ucc_128_suffix_flag          VARCHAR2 DEFAULT NULL
  , x_defer_logical_transactions   NUMBER DEFAULT 2
  , x_wip_overpick_enabled         VARCHAR2 DEFAULT 'N' --OVPK
  , x_ovpk_transfer_orders_enabled VARCHAR2 DEFAULT 'Y' --OVPK
  , x_auto_del_alloc_flag          VARCHAR2             --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD    NUMBER -- 11.5.10+ RFID Compliance
  , x_parent_child_generation_flag               VARCHAR2 DEFAULT NULL
  , x_child_lot_zero_padding_flag                VARCHAR2 DEFAULT NULL
  , x_child_lot_alpha_prefix                     VARCHAR2 DEFAULT NULL
  , x_child_lot_number_length                    NUMBER DEFAULT NULL
  , x_child_lot_validation_flag                  VARCHAR2 DEFAULT NULL
  , x_copy_lot_attribute_flag                    VARCHAR2 DEFAULT NULL
  , x_create_lot_uom_conversion                  NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status                     NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve                 VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                                VARCHAR2 DEFAULT 'N' -- MHP
  , x_trading_partner_org_flag                   VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account                      NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id              NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag              VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag                VARCHAR2 DEFAULT NULL
  , x_company_prefix                             VARCHAR2 DEFAULT NULL
  , x_company_prefix_index                       VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number              VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag              VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM by
  );

  PROCEDURE update_row(
    x_rowid                        VARCHAR2
  , x_organization_id              NUMBER
  , x_last_update_date             DATE
  , x_last_updated_by              NUMBER
  , x_last_update_login            NUMBER
  , x_organization_code            VARCHAR2
  , x_master_organization_id       NUMBER
  , x_primary_cost_method          NUMBER
  , x_cost_organization_id         NUMBER
  , x_default_material_cost_id     NUMBER
  , x_default_matl_ovhd_cost_id    NUMBER
  , x_calendar_exception_set_id    NUMBER
  , x_calendar_code                VARCHAR2
  , x_general_ledger_update_code   NUMBER
  , x_default_atp_rule_id          NUMBER
  , x_default_picking_rule_id      NUMBER
  , x_default_locator_order_value  NUMBER
  , x_default_subinv_order_value   NUMBER
  , x_negative_inv_receipt_code    NUMBER
  , x_stock_locator_control_code   NUMBER
  , x_material_account             NUMBER
  , x_material_overhead_account    NUMBER
  , x_matl_ovhd_absorption_acct    NUMBER
  , x_resource_account             NUMBER
  , x_purchase_price_var_account   NUMBER
  , x_ap_accrual_account           NUMBER
  , x_overhead_account             NUMBER
  , x_outside_processing_account   NUMBER
  , x_intransit_inv_account        NUMBER
  , x_interorg_receivables_account NUMBER
  , x_interorg_price_var_account   NUMBER
  , x_interorg_payables_account    NUMBER
  , x_cost_of_sales_account        NUMBER
  , x_encumbrance_account          NUMBER
  , x_interorg_transfer_cr_account NUMBER
  , x_matl_interorg_transfer_code  NUMBER
  , x_interorg_trnsfr_charge_perc  NUMBER
  , x_source_organization_id       NUMBER
  , x_source_subinventory          VARCHAR2
  , x_source_type                  NUMBER
  , x_serial_number_type           NUMBER
  , x_auto_serial_alpha_prefix     VARCHAR2
  , x_start_auto_serial_number     VARCHAR2
  , x_auto_lot_alpha_prefix        VARCHAR2
  , x_lot_number_uniqueness        NUMBER
  , x_lot_number_generation        NUMBER
  , x_lot_number_zero_padding      NUMBER
  , x_lot_number_length            NUMBER
  , x_starting_revision            VARCHAR2
  , x_attribute_category           VARCHAR2
  , x_attribute1                   VARCHAR2
  , x_attribute2                   VARCHAR2
  , x_attribute3                   VARCHAR2
  , x_attribute4                   VARCHAR2
  , x_attribute5                   VARCHAR2
  , x_attribute6                   VARCHAR2
  , x_attribute7                   VARCHAR2
  , x_attribute8                   VARCHAR2
  , x_attribute9                   VARCHAR2
  , x_attribute10                  VARCHAR2
  , x_attribute11                  VARCHAR2
  , x_attribute12                  VARCHAR2
  , x_attribute13                  VARCHAR2
  , x_attribute14                  VARCHAR2
  , x_attribute15                  VARCHAR2
  , x_global_attribute_category    VARCHAR2
  , x_global_attribute1            VARCHAR2
  , x_global_attribute2            VARCHAR2
  , x_global_attribute3            VARCHAR2
  , x_global_attribute4            VARCHAR2
  , x_global_attribute5            VARCHAR2
  , x_global_attribute6            VARCHAR2
  , x_global_attribute7            VARCHAR2
  , x_global_attribute8            VARCHAR2
  , x_global_attribute9            VARCHAR2
  , x_global_attribute10           VARCHAR2
  , x_global_attribute11           VARCHAR2
  , x_global_attribute12           VARCHAR2
  , x_global_attribute13           VARCHAR2
  , x_global_attribute14           VARCHAR2
  , x_global_attribute15           VARCHAR2
  , x_global_attribute16           VARCHAR2
  , x_global_attribute17           VARCHAR2
  , x_global_attribute18           VARCHAR2
  , x_global_attribute19           VARCHAR2
  , x_global_attribute20           VARCHAR2
  , x_default_demand_class         VARCHAR2
  , x_encumbrance_reversal_flag    NUMBER
  , x_maintain_fifo_qty_stack_type NUMBER
  , x_invoice_price_var_account    NUMBER
  , x_average_cost_var_account     NUMBER
-- For Bug 7440217
  , x_lcm_var_account              NUMBER
-- End for Bug 7440217
  , x_sales_account                NUMBER
  , x_expense_account              NUMBER
  , x_serial_number_generation     NUMBER
  , x_project_reference_enabled    NUMBER
  , x_pm_cost_collection_enabled   NUMBER
  , x_project_control_level        NUMBER
  , x_avg_rates_cost_type_id       NUMBER
  , x_txn_approval_timeout_period  NUMBER
  , x_borrpay_matl_var_account     NUMBER
  , x_borrpay_moh_var_account      NUMBER
  , x_borrpay_res_var_account      NUMBER
  , x_borrpay_osp_var_account      NUMBER
  , x_borrpay_ovh_var_account      NUMBER
  , x_org_max_weight               NUMBER
  , x_org_max_volume               NUMBER
  , x_org_max_weight_uom_code      VARCHAR2
  , x_org_max_volume_uom_code      VARCHAR2
  , x_mo_source_required           NUMBER
  , x_mo_pick_confirm_required     NUMBER
  , x_mo_approval_timeout_action   NUMBER
  , x_project_cost_account         NUMBER
  , x_process_enabled_flag         VARCHAR2
  , x_process_orgn_code            VARCHAR2
  , x_default_cost_group_id        NUMBER
  , x_lpn_prefix                   VARCHAR2
  , x_lpn_suffix                   VARCHAR2
  , x_lpn_starting_number          NUMBER
  , x_wms_enabled_flag             VARCHAR2
-- For Bug 7440217
  , x_lcm_enabled_flag             VARCHAR2
-- End for Bug 7440217
  , x_qa_skipping_insp_flag        VARCHAR2
  , x_eam_enabled_flag             VARCHAR2
  , x_maint_organization_id        NUMBER
  , x_pregen_putaway_tasks_flag    NUMBER
  , x_regeneration_interval        NUMBER
  , x_timezone_id                  NUMBER
  , x_default_wms_picking_rule_id  NUMBER
  , x_default_put_away_rule_id     NUMBER
  , x_default_carton_rule_id       NUMBER
  , x_default_cyc_count_header_id  NUMBER
  , x_crossdock_flag               NUMBER
  , x_cartonization_flag           NUMBER
  , x_allocate_serial_flag         VARCHAR2
  , x_default_pick_task_type_id    NUMBER
  , x_default_repl_task_type_id    NUMBER
  , x_default_cc_task_type_id      NUMBER
  , x_default_putaway_task_type_id NUMBER
  , x_cost_cutoff_date             DATE
  , x_skip_task_waiting_minutes    NUMBER
  , x_prioritize_wip_jobs          NUMBER
  , x_default_xdock_subinventory   VARCHAR2
  , x_default_xdock_locator_id     NUMBER
  , x_distri_organization_flag     VARCHAR2
  , x_carrier_manifesting_flag     VARCHAR2
  , x_distribution_account_id      NUMBER
  , x_direct_shipping_allowed      VARCHAR2
  , x_default_moxfer_task_type_id  NUMBER
  , x_default_moissue_task_type_id NUMBER
  , x_max_clusters_allowed         NUMBER DEFAULT NULL
  , x_default_pick_op_plan_id      NUMBER DEFAULT 1
  , x_consigned_flag               VARCHAR2 DEFAULT NULL
  , x_cartonize_sales_orders       VARCHAR2 DEFAULT 'Y'
  , x_cartonize_manufacturing      VARCHAR2 DEFAULT 'N'
  , x_total_lpn_length             NUMBER DEFAULT NULL
  , x_ucc_128_suffix_flag          VARCHAR2 DEFAULT NULL
  , x_defer_logical_transactions   NUMBER DEFAULT 2
  , x_wip_overpick_enabled         VARCHAR2 DEFAULT 'N' --OVPK
  , x_ovpk_transfer_orders_enabled VARCHAR2 DEFAULT 'Y' --OVPK
  , x_auto_del_alloc_flag          VARCHAR2             --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD    NUMBER -- 11.5.10+ RFID Compliance
  , x_parent_child_generation_flag               VARCHAR2 DEFAULT NULL
  , x_child_lot_zero_padding_flag                VARCHAR2 DEFAULT NULL
  , x_child_lot_alpha_prefix                     VARCHAR2 DEFAULT NULL
  , x_child_lot_number_length                    NUMBER DEFAULT NULL
  , x_child_lot_validation_flag                  VARCHAR2 DEFAULT NULL
  , x_copy_lot_attribute_flag                    VARCHAR2 DEFAULT NULL
  , x_create_lot_uom_conversion                  NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status                     NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve                 VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                                VARCHAR2 DEFAULT 'N' --MHP
  , x_trading_partner_org_flag                   VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account                      NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id              NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag              VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag                VARCHAR2 DEFAULT NULL
  , x_company_prefix                             VARCHAR2 DEFAULT NULL
  , x_company_prefix_index                       VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number              VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag              VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM by
  );

  PROCEDURE delete_row(x_rowid VARCHAR2);

  PROCEDURE upd_sub_accts_with_org_accts(
    x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_default_cost_group_id      IN            NUMBER
  , p_material_account           IN            NUMBER
  , p_material_overhead_account  IN            NUMBER
  , p_resource_account           IN            NUMBER
  , p_overhead_account           IN            NUMBER
  , p_outside_processing_account IN            NUMBER
  , p_expense_account            IN            NUMBER
  , p_encumbrance_account        IN            NUMBER
  , p_organization_id            IN            NUMBER
  );

  FUNCTION get_miss_num
    RETURN NUMBER;

  PROCEDURE default_pjm_rule_setup(
    x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  , p_organization_id IN            NUMBER
  );

  FUNCTION g_ret_sts_success
    RETURN VARCHAR2;
END mtl_parameters_pkg;

/

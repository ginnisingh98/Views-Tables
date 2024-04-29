--------------------------------------------------------
--  DDL for Package Body MTL_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_PARAMETERS_PKG" AS
  /* $Header: INVSDOOB.pls 120.6.12010000.8 2010/05/25 10:51:48 krishnak ship $ */
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
-- For Bug 7440217 Variance Account for LCM
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
-- For Bug 7440217 LCM Enabled Flag
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
  , x_max_clusters_allowed                       NUMBER
  , x_default_pick_op_plan_id                    NUMBER
  , x_consigned_flag                             VARCHAR2
  , x_cartonize_sales_orders                     VARCHAR2
  , x_cartonize_manufacturing                    VARCHAR2
  , x_total_lpn_length                           NUMBER
  , x_ucc_128_suffix_flag                        VARCHAR2
  , x_defer_logical_transactions                 NUMBER
  , x_wip_overpick_enabled                       VARCHAR2 --OVPK
  , x_ovpk_transfer_orders_enabled               VARCHAR2 --OVPK
  , x_auto_del_alloc_flag                        VARCHAR2 --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD                  NUMBER --11.5.10+ RFID compliance
  , x_parent_child_generation_flag               VARCHAR2
  , x_child_lot_zero_padding_flag                VARCHAR2
  , x_child_lot_alpha_prefix                     VARCHAR2
  , x_child_lot_number_length                    NUMBER
  , x_child_lot_validation_flag                  VARCHAR2
  , x_copy_lot_attribute_flag                    VARCHAR2
  , x_create_lot_uom_conversion                  NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status                     NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve                 VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                                VARCHAR2 --MHP
  , x_trading_partner_org_flag                   VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account                      NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id               NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag               VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag                VARCHAR2 DEFAULT NULL
  , x_company_prefix                             VARCHAR2 DEFAULT NULL
  , x_company_prefix_index                       VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number               VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag                VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM

  ) IS
    CURSOR c IS
      SELECT ROWID
        FROM mtl_parameters
       WHERE organization_id = x_organization_id;
  BEGIN
    INSERT INTO mtl_parameters
                (
                 organization_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , organization_code
               , master_organization_id
               , primary_cost_method
               , cost_organization_id
               , default_material_cost_id
               , default_matl_ovhd_cost_id
               , calendar_exception_set_id
               , calendar_code
               , general_ledger_update_code
               , default_atp_rule_id
               , default_picking_rule_id
               , default_locator_order_value
               , default_subinv_order_value
               , negative_inv_receipt_code
               , stock_locator_control_code
               , material_account
               , material_overhead_account
               , matl_ovhd_absorption_acct
               , resource_account
               , purchase_price_var_account
               , ap_accrual_account
               , overhead_account
               , outside_processing_account
               , intransit_inv_account
               , interorg_receivables_account
               , interorg_price_var_account
               , interorg_payables_account
               , cost_of_sales_account
               , encumbrance_account
               , interorg_transfer_cr_account
               , matl_interorg_transfer_code
               , interorg_trnsfr_charge_percent
               , source_organization_id
               , source_subinventory
               , source_type
               , serial_number_type
               , auto_serial_alpha_prefix
               , start_auto_serial_number
               , auto_lot_alpha_prefix
               , lot_number_uniqueness
               , lot_number_generation
               , lot_number_zero_padding
               , lot_number_length
               , starting_revision
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , global_attribute_category
               , global_attribute1
               , global_attribute2
               , global_attribute3
               , global_attribute4
               , global_attribute5
               , global_attribute6
               , global_attribute7
               , global_attribute8
               , global_attribute9
               , global_attribute10
               , global_attribute11
               , global_attribute12
               , global_attribute13
               , global_attribute14
               , global_attribute15
               , global_attribute16
               , global_attribute17
               , global_attribute18
               , global_attribute19
               , global_attribute20
               , default_demand_class
               , encumbrance_reversal_flag
               , maintain_fifo_qty_stack_type
               , invoice_price_var_account
               , average_cost_var_account
-- For Bug 7440217 LCM Variance Account
               , lcm_var_account
-- End for Bug 7440217
               , sales_account
               , expense_account
               , serial_number_generation
               , project_reference_enabled
               , pm_cost_collection_enabled
               , project_control_level
               , avg_rates_cost_type_id
               , txn_approval_timeout_period
               , borrpay_matl_var_account
               , borrpay_moh_var_account
               , borrpay_res_var_account
               , borrpay_osp_var_account
               , borrpay_ovh_var_account
               , org_max_weight
               , org_max_volume
               , org_max_weight_uom_code
               , org_max_volume_uom_code
               , mo_source_required
               , mo_pick_confirm_required
               , mo_approval_timeout_action
               , project_cost_account
               , process_enabled_flag
               , process_orgn_code
               , default_cost_group_id
               , lpn_prefix
               , lpn_suffix
               , lpn_starting_number
               , wms_enabled_flag
-- For Bug 7440217 LCM ENabled Flag
               , lcm_enabled_flag
-- End for Bug 7440217
               , qa_skipping_insp_flag
               , eam_enabled_flag
               , maint_organization_id
               , pregen_putaway_tasks_flag
               , regeneration_interval
               , timezone_id
               , default_wms_picking_rule_id
               , default_put_away_rule_id
               , default_carton_rule_id
               , default_cyc_count_header_id
               , crossdock_flag
               , cartonization_flag
               , allocate_serial_flag
               , default_pick_task_type_id
               , default_repl_task_type_id
               , default_cc_task_type_id
               , default_putaway_task_type_id
               , cost_cutoff_date
               , skip_task_waiting_minutes
               , prioritize_wip_jobs
               , default_crossdock_subinventory
               , default_crossdock_locator_id
               , distributed_organization_flag
               , carrier_manifesting_flag
               , distribution_account_id
               , direct_shipping_allowed
               , default_moxfer_task_type_id
               , default_moissue_task_type_id
               , max_clusters_allowed
               , default_pick_op_plan_id
               --, consigned_flag  /*Bug 4347477*/
               , cartonize_sales_orders
               , cartonize_manufacturing
               , total_lpn_length
               , ucc_128_suffix_flag
               , defer_logical_transactions
               , wip_overpick_enabled --OVPK
               , ovpk_transfer_orders_enabled --OVPK
	       , auto_del_alloc_flag --ER3969328: CI project
               ,  RFID_VERIF_PCNT_THRESHOLD --11.5.10+ RFID Compliance
               , parent_child_generation_flag
               , child_lot_zero_padding_flag
               , child_lot_alpha_prefix
               , child_lot_number_length
               , child_lot_validation_flag
               , copy_lot_attribute_flag
               , create_lot_uom_conversion      -- NSINHA
               , allow_different_status         -- NSINHA
               , rules_override_lot_reservation -- NSINHA
               , wcs_enabled --MHP
               , trading_partner_org_flag
               , deferred_cogs_account
               , default_crossdock_criteria_id
               , enforce_locator_alis_unq_flag
               , epc_generation_enabled_flag
               , company_prefix
               , company_prefix_index
               , commercial_govt_entity_number
               , labor_management_enabled_flag
               , default_status_id -- Added for # 6633612
               , opsm_enabled_flag -- Added for OPSM
                )
         VALUES (
                 x_organization_id
               , x_last_update_date
               , x_last_updated_by
               , x_creation_date
               , x_created_by
               , x_last_update_login
               , x_organization_code
               , x_master_organization_id
               , x_primary_cost_method
               , x_cost_organization_id
               , x_default_material_cost_id
               , x_default_matl_ovhd_cost_id
               , x_calendar_exception_set_id
               , x_calendar_code
               , x_general_ledger_update_code
               , x_default_atp_rule_id
               , x_default_picking_rule_id
               , x_default_locator_order_value
               , x_default_subinv_order_value
               , x_negative_inv_receipt_code
               , x_stock_locator_control_code
               , x_material_account
               , x_material_overhead_account
               , x_matl_ovhd_absorption_acct
               , x_resource_account
               , x_purchase_price_var_account
               , x_ap_accrual_account
               , x_overhead_account
               , x_outside_processing_account
               , x_intransit_inv_account
               , x_interorg_receivables_account
               , x_interorg_price_var_account
               , x_interorg_payables_account
               , x_cost_of_sales_account
               , x_encumbrance_account
               , x_interorg_transfer_cr_account
               , x_matl_interorg_transfer_code
               , x_interorg_trnsfr_charge_perc
               , x_source_organization_id
               , x_source_subinventory
               , x_source_type
               , x_serial_number_type
               , x_auto_serial_alpha_prefix
               , x_start_auto_serial_number
               , x_auto_lot_alpha_prefix
               , x_lot_number_uniqueness
               , x_lot_number_generation
               , x_lot_number_zero_padding
               , x_lot_number_length
               , x_starting_revision
               , x_attribute_category
               , x_attribute1
               , x_attribute2
               , x_attribute3
               , x_attribute4
               , x_attribute5
               , x_attribute6
               , x_attribute7
               , x_attribute8
               , x_attribute9
               , x_attribute10
               , x_attribute11
               , x_attribute12
               , x_attribute13
               , x_attribute14
               , x_attribute15
               , x_global_attribute_category
               , x_global_attribute1
               , x_global_attribute2
               , x_global_attribute3
               , x_global_attribute4
               , x_global_attribute5
               , x_global_attribute6
               , x_global_attribute7
               , x_global_attribute8
               , x_global_attribute9
               , x_global_attribute10
               , x_global_attribute11
               , x_global_attribute12
               , x_global_attribute13
               , x_global_attribute14
               , x_global_attribute15
               , x_global_attribute16
               , x_global_attribute17
               , x_global_attribute18
               , x_global_attribute19
               , x_global_attribute20
               , x_default_demand_class
               , x_encumbrance_reversal_flag
               , x_maintain_fifo_qty_stack_type
               , x_invoice_price_var_account
               , x_average_cost_var_account
-- For Bug 7440217 LCM Variance Account
               , x_lcm_var_account
-- End for Bug 7440217
               , x_sales_account
               , x_expense_account
               , x_serial_number_generation
               , x_project_reference_enabled
               , x_pm_cost_collection_enabled
               , x_project_control_level
               , x_avg_rates_cost_type_id
               , x_txn_approval_timeout_period
               , x_borrpay_matl_var_account
               , x_borrpay_moh_var_account
               , x_borrpay_res_var_account
               , x_borrpay_osp_var_account
               , x_borrpay_ovh_var_account
               , x_org_max_weight
               , x_org_max_volume
               , x_org_max_weight_uom_code
               , x_org_max_volume_uom_code
               , x_mo_source_required
               , NVL(x_mo_pick_confirm_required,'2')
               , x_mo_approval_timeout_action
               , x_project_cost_account
               , x_process_enabled_flag
               , x_process_orgn_code
               , x_default_cost_group_id
               , x_lpn_prefix
               , x_lpn_suffix
               , x_lpn_starting_number
               , NVL(x_wms_enabled_flag, 'N')
-- For Bug 7440217 LCM Enabled Flag
               , NVL(x_lcm_enabled_flag, 'N')
-- End for Bug 7440217
               , NVL(x_qa_skipping_insp_flag, 'N')
               , NVL(x_eam_enabled_flag, 'N')
               , x_maint_organization_id
               , x_pregen_putaway_tasks_flag
               , x_regeneration_interval
               , x_timezone_id
               , x_default_wms_picking_rule_id
               , x_default_put_away_rule_id
               , x_default_carton_rule_id
               , x_default_cyc_count_header_id
               , x_crossdock_flag
               , x_cartonization_flag
               , x_allocate_serial_flag
               , x_default_pick_task_type_id
               , x_default_repl_task_type_id
               , x_default_cc_task_type_id
               , x_default_putaway_task_type_id
               , x_cost_cutoff_date
               , x_skip_task_waiting_minutes
               , x_prioritize_wip_jobs
               , x_default_xdock_subinventory
               , x_default_xdock_locator_id
               , x_distri_organization_flag
               , x_carrier_manifesting_flag
               , x_distribution_account_id
               , x_direct_shipping_allowed
               , x_default_moxfer_task_type_id
               , x_default_moissue_task_type_id
               , x_max_clusters_allowed
               , x_default_pick_op_plan_id
               --, x_consigned_flag   /*Bug #4347477*/
               , x_cartonize_sales_orders
               , x_cartonize_manufacturing
               , x_total_lpn_length
               , x_ucc_128_suffix_flag
               , x_defer_logical_transactions
               , NVL(x_wip_overpick_enabled,'N') --OVPK
               , NVL(x_ovpk_transfer_orders_enabled,'Y') --OVPK
	       , x_auto_del_alloc_flag --ER3969328: CI project
               , X_RFID_VERIF_PCNT_THRESHOLD -- 11.5.10+ RFID Compliance
               , x_parent_child_generation_flag
               , x_child_lot_zero_padding_flag
               , x_child_lot_alpha_prefix
               , x_child_lot_number_length
               , x_child_lot_validation_flag
               , x_copy_lot_attribute_flag
               , x_create_lot_uom_conversion       -- NSINHA
               , x_allow_different_status          -- NSINHA
               , x_rules_override_lot_reserve  -- NSINHA
               , x_wcs_enabled --MHP
               , x_trading_partner_org_flag
               , x_deferred_cogs_account
               , x_default_crossdok_criteria_id
               , x_enforce_locator_alis_uq_flag
               , x_epc_generation_enabled_flag
               , x_company_prefix
               , x_company_prefix_index
               , x_commercial_gov_entity_number
               , x_lbr_management_enabled_flag
               , x_default_status_id  -- Added for # 6633612
               , x_opsm_enabled_flag -- Added for OPSM
                );

    OPEN c;
    FETCH c INTO x_rowid;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE c;
  END insert_row;

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
-- For Bug 7440217 for Varinace Account
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
-- For Bug 7440217 for LCM Enabled Flag
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
  , x_max_clusters_allowed         NUMBER
  , x_default_pick_op_plan_id      NUMBER
  , x_consigned_flag               VARCHAR2
  , x_cartonize_sales_orders       VARCHAR2
  , x_cartonize_manufacturing      VARCHAR2
  , x_total_lpn_length             NUMBER
  , x_ucc_128_suffix_flag          VARCHAR2
  , x_defer_logical_transactions   NUMBER
  , x_wip_overpick_enabled         VARCHAR2 --OVPK
  , x_ovpk_transfer_orders_enabled VARCHAR2 --OVPK
  , x_auto_del_alloc_flag          VARCHAR2 --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD    NUMBER -- 11.5.10+ RFID Compliance
  , x_parent_child_generation_flag VARCHAR2
  , x_child_lot_zero_padding_flag  VARCHAR2
  , x_child_lot_alpha_prefix       VARCHAR2
  , x_child_lot_number_length      NUMBER
  , x_child_lot_validation_flag    VARCHAR2
  , x_copy_lot_attribute_flag      VARCHAR2
  , x_create_lot_uom_conversion       NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status          NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve      VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                   VARCHAR2 --MHP
  , x_trading_partner_org_flag      VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account         NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id  NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag  VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag   VARCHAR2 DEFAULT NULL
  , x_company_prefix                VARCHAR2 DEFAULT NULL
  , x_company_prefix_index          VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number  VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag   VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM
  ) IS
    CURSOR c IS
      SELECT        *
               FROM mtl_parameters
              WHERE ROWID = x_rowid
      FOR UPDATE OF organization_id NOWAIT;

    recinfo        c%ROWTYPE;
    record_changed EXCEPTION;
  BEGIN
    OPEN c;
    FETCH c INTO recinfo;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

    CLOSE c;

    IF NOT(
           (recinfo.organization_id = x_organization_id)
           AND((recinfo.organization_code = x_organization_code)
               OR((recinfo.organization_code IS NULL)
                  AND(x_organization_code IS NULL)))
           AND(recinfo.master_organization_id = x_master_organization_id)
           AND(recinfo.primary_cost_method = x_primary_cost_method)
           AND(recinfo.cost_organization_id = x_cost_organization_id)
           AND(
               (recinfo.default_material_cost_id = x_default_material_cost_id)
               OR((recinfo.default_material_cost_id IS NULL)
                  AND(x_default_material_cost_id IS NULL))
              )
           AND(
               (recinfo.default_matl_ovhd_cost_id = x_default_matl_ovhd_cost_id)
               OR((recinfo.default_matl_ovhd_cost_id IS NULL)
                  AND(x_default_matl_ovhd_cost_id IS NULL))
              )
           AND(
               (recinfo.calendar_exception_set_id = x_calendar_exception_set_id)
               OR((recinfo.calendar_exception_set_id IS NULL)
                  AND(x_calendar_exception_set_id IS NULL))
              )
           AND((recinfo.calendar_code = x_calendar_code)
               OR((recinfo.calendar_code IS NULL)
                  AND(x_calendar_code IS NULL)))
           AND(recinfo.general_ledger_update_code = x_general_ledger_update_code)
           AND(
               (recinfo.default_atp_rule_id = x_default_atp_rule_id)
               OR((recinfo.default_atp_rule_id IS NULL)
                  AND(x_default_atp_rule_id IS NULL))
              )
           AND(
               (recinfo.default_picking_rule_id = x_default_picking_rule_id)
               OR((recinfo.default_picking_rule_id IS NULL)
                  AND(x_default_picking_rule_id IS NULL))
              )
           AND(
               (recinfo.default_locator_order_value = x_default_locator_order_value)
               OR((recinfo.default_locator_order_value IS NULL)
                  AND(x_default_locator_order_value IS NULL))
              )
           AND(
               (recinfo.default_subinv_order_value = x_default_subinv_order_value)
               OR((recinfo.default_subinv_order_value IS NULL)
                  AND(x_default_subinv_order_value IS NULL))
              )
           AND(recinfo.negative_inv_receipt_code = x_negative_inv_receipt_code)
           AND(recinfo.stock_locator_control_code = x_stock_locator_control_code)
           AND((recinfo.material_account = x_material_account)
               OR((recinfo.material_account IS NULL)
                  AND(x_material_account IS NULL)))
           AND(
               (recinfo.material_overhead_account = x_material_overhead_account)
               OR((recinfo.material_overhead_account IS NULL)
                  AND(x_material_overhead_account IS NULL))
              )
           AND(
               (recinfo.matl_ovhd_absorption_acct = x_matl_ovhd_absorption_acct)
               OR((recinfo.matl_ovhd_absorption_acct IS NULL)
                  AND(x_matl_ovhd_absorption_acct IS NULL))
              )
           AND((recinfo.resource_account = x_resource_account)
               OR((recinfo.resource_account IS NULL)
                  AND(x_resource_account IS NULL)))
           AND(
               (recinfo.purchase_price_var_account = x_purchase_price_var_account)
               OR((recinfo.purchase_price_var_account IS NULL)
                  AND(x_purchase_price_var_account IS NULL))
              )
           AND(
               (recinfo.ap_accrual_account = x_ap_accrual_account)
               OR((recinfo.ap_accrual_account IS NULL)
                  AND(x_ap_accrual_account IS NULL))
              )
           AND((recinfo.overhead_account = x_overhead_account)
               OR((recinfo.overhead_account IS NULL)
                  AND(x_overhead_account IS NULL)))
           AND(
               (recinfo.outside_processing_account = x_outside_processing_account)
               OR((recinfo.outside_processing_account IS NULL)
                  AND(x_outside_processing_account IS NULL))
              )
           AND(
               (recinfo.intransit_inv_account = x_intransit_inv_account)
               OR((recinfo.intransit_inv_account IS NULL)
                  AND(x_intransit_inv_account IS NULL))
              )
           AND(
               (recinfo.interorg_receivables_account = x_interorg_receivables_account)
               OR((recinfo.interorg_receivables_account IS NULL)
                  AND(x_interorg_receivables_account IS NULL))
              )
           AND(
               (recinfo.interorg_price_var_account = x_interorg_price_var_account)
               OR((recinfo.interorg_price_var_account IS NULL)
                  AND(x_interorg_price_var_account IS NULL))
              )
           AND(
               (recinfo.interorg_payables_account = x_interorg_payables_account)
               OR((recinfo.interorg_payables_account IS NULL)
                  AND(x_interorg_payables_account IS NULL))
              )
           AND(
               (recinfo.cost_of_sales_account = x_cost_of_sales_account)
               OR((recinfo.cost_of_sales_account IS NULL)
                  AND(x_cost_of_sales_account IS NULL))
              )
           AND(
               (recinfo.encumbrance_account = x_encumbrance_account)
               OR((recinfo.encumbrance_account IS NULL)
                  AND(x_encumbrance_account IS NULL))
              )
           AND(
               (recinfo.interorg_transfer_cr_account = x_interorg_transfer_cr_account)
               OR((recinfo.interorg_transfer_cr_account IS NULL)
                  AND(x_interorg_transfer_cr_account IS NULL))
              )
           AND(recinfo.matl_interorg_transfer_code = x_matl_interorg_transfer_code)
           AND(
               (recinfo.interorg_trnsfr_charge_percent = x_interorg_trnsfr_charge_perc)
               OR((recinfo.interorg_trnsfr_charge_percent IS NULL)
                  AND(x_interorg_trnsfr_charge_perc IS NULL))
              )
           AND(
               (recinfo.source_organization_id = x_source_organization_id)
               OR((recinfo.source_organization_id IS NULL)
                  AND(x_source_organization_id IS NULL))
              )
           AND(
               (recinfo.source_subinventory = x_source_subinventory)
               OR((recinfo.source_subinventory IS NULL)
                  AND(x_source_subinventory IS NULL))
              )
           AND((recinfo.source_type = x_source_type)
               OR((recinfo.source_type IS NULL)
                  AND(x_source_type IS NULL)))
           AND(
               (recinfo.serial_number_type = x_serial_number_type)
               OR((recinfo.serial_number_type IS NULL)
                  AND(x_serial_number_type IS NULL))
              )
           AND(
               (recinfo.auto_serial_alpha_prefix = x_auto_serial_alpha_prefix)
               OR((recinfo.auto_serial_alpha_prefix IS NULL)
                  AND(x_auto_serial_alpha_prefix IS NULL))
              )
           AND(
               (recinfo.start_auto_serial_number = x_start_auto_serial_number)
               OR((recinfo.start_auto_serial_number IS NULL)
                  AND(x_start_auto_serial_number IS NULL))
              )
           AND(
               (recinfo.auto_lot_alpha_prefix = x_auto_lot_alpha_prefix)
               OR((recinfo.auto_lot_alpha_prefix IS NULL)
                  AND(x_auto_lot_alpha_prefix IS NULL))
              )
           AND(recinfo.lot_number_uniqueness = x_lot_number_uniqueness)
           AND(recinfo.lot_number_generation = x_lot_number_generation)
           AND(
               (recinfo.lot_number_zero_padding = x_lot_number_zero_padding)
               OR((recinfo.lot_number_zero_padding IS NULL)
                  AND(x_lot_number_zero_padding IS NULL))
              )
           AND((recinfo.lot_number_length = x_lot_number_length)
               OR((recinfo.lot_number_length IS NULL)
                  AND(x_lot_number_length IS NULL)))
           AND(recinfo.starting_revision = x_starting_revision)
           AND(
               (recinfo.project_cost_account = x_project_cost_account)
               OR((recinfo.project_cost_account IS NULL)
                  AND(x_project_cost_account IS NULL))
              )
           AND(
               (recinfo.process_enabled_flag = x_process_enabled_flag)
               OR((recinfo.process_enabled_flag IS NULL)
                  AND(x_process_enabled_flag IS NULL))
              )
           AND((recinfo.process_orgn_code = x_process_orgn_code)
               OR((recinfo.process_orgn_code IS NULL)
                  AND(x_process_orgn_code IS NULL)))
           AND(
               (recinfo.default_cost_group_id = x_default_cost_group_id)
               OR((recinfo.default_cost_group_id IS NULL)
                  AND(x_default_cost_group_id IS NULL))
              )
           AND((recinfo.lpn_prefix = x_lpn_prefix)
               OR((recinfo.lpn_prefix IS NULL)
                  AND(x_lpn_prefix IS NULL)))
           AND((recinfo.lpn_suffix = x_lpn_suffix)
               OR((recinfo.lpn_suffix IS NULL)
                  AND(x_lpn_suffix IS NULL)))
           AND(
               (recinfo.lpn_starting_number = x_lpn_starting_number)
               OR((recinfo.lpn_starting_number IS NULL)
                  AND(x_lpn_starting_number IS NULL))
              )
           AND((recinfo.wms_enabled_flag = x_wms_enabled_flag)
               OR((recinfo.wms_enabled_flag IS NULL)
                  AND(x_wms_enabled_flag IS NULL))
              )
-- For Bug 7440217
           AND((recinfo.lcm_enabled_flag = x_lcm_enabled_flag)
               OR((recinfo.lcm_enabled_flag IS NULL)
                  AND(x_lcm_enabled_flag IS NULL))
              )
-- End for Bug 7440217
           AND(
               (recinfo.qa_skipping_insp_flag = x_qa_skipping_insp_flag)
               OR((recinfo.qa_skipping_insp_flag IS NULL)
                  AND(x_qa_skipping_insp_flag IS NULL))
              )
           AND((recinfo.eam_enabled_flag = x_eam_enabled_flag)
               OR((recinfo.eam_enabled_flag IS NULL)
                  AND(x_eam_enabled_flag IS NULL)))
           AND(
               (recinfo.maint_organization_id = x_maint_organization_id)
               OR((recinfo.maint_organization_id IS NULL)
                  AND(x_maint_organization_id IS NULL))
              )
           AND((recinfo.crossdock_flag = x_crossdock_flag)
               OR((recinfo.crossdock_flag IS NULL)
                  AND(x_crossdock_flag IS NULL)))
           AND(
               (recinfo.cartonization_flag = x_cartonization_flag)
               OR((recinfo.cartonization_flag IS NULL)
                  AND(x_cartonization_flag IS NULL))
              )
           AND(
               (recinfo.allocate_serial_flag = x_allocate_serial_flag)
               OR((recinfo.allocate_serial_flag IS NULL)
                  AND(x_allocate_serial_flag IS NULL))
              )
          ) THEN
      RAISE record_changed;
    END IF;

    -- Bug: 4188383.
    -- Rearranged the closing parenthesis of NOT condition below, to cover all the conditions specified in the IF statement.
    IF NOT(
           ((recinfo.attribute_category = x_attribute_category)
            OR((recinfo.attribute_category IS NULL)
               AND(x_attribute_category IS NULL)))
           AND((recinfo.attribute1 = x_attribute1)
               OR((recinfo.attribute1 IS NULL)
                  AND(x_attribute1 IS NULL)))
           AND((recinfo.attribute2 = x_attribute2)
               OR((recinfo.attribute2 IS NULL)
                  AND(x_attribute2 IS NULL)))
           AND((recinfo.attribute3 = x_attribute3)
               OR((recinfo.attribute3 IS NULL)
                  AND(x_attribute3 IS NULL)))
           AND((recinfo.attribute4 = x_attribute4)
               OR((recinfo.attribute4 IS NULL)
                  AND(x_attribute4 IS NULL)))
           AND((recinfo.attribute5 = x_attribute5)
               OR((recinfo.attribute5 IS NULL)
                  AND(x_attribute5 IS NULL)))
           AND((recinfo.attribute6 = x_attribute6)
               OR((recinfo.attribute6 IS NULL)
                  AND(x_attribute6 IS NULL)))
           AND((recinfo.attribute7 = x_attribute7)
               OR((recinfo.attribute7 IS NULL)
                  AND(x_attribute7 IS NULL)))
           AND((recinfo.attribute8 = x_attribute8)
               OR((recinfo.attribute8 IS NULL)
                  AND(x_attribute8 IS NULL)))
           AND((recinfo.attribute9 = x_attribute9)
               OR((recinfo.attribute9 IS NULL)
                  AND(x_attribute9 IS NULL)))
           AND((recinfo.attribute10 = x_attribute10)
               OR((recinfo.attribute10 IS NULL)
                  AND(x_attribute10 IS NULL)))
           AND((recinfo.attribute11 = x_attribute11)
               OR((recinfo.attribute11 IS NULL)
                  AND(x_attribute11 IS NULL)))
           AND((recinfo.attribute12 = x_attribute12)
               OR((recinfo.attribute12 IS NULL)
                  AND(x_attribute12 IS NULL)))
           AND((recinfo.attribute13 = x_attribute13)
               OR((recinfo.attribute13 IS NULL)
                  AND(x_attribute13 IS NULL)))
           AND((recinfo.attribute14 = x_attribute14)
               OR((recinfo.attribute14 IS NULL)
                  AND(x_attribute14 IS NULL)))
           AND((recinfo.attribute15 = x_attribute15)
               OR((recinfo.attribute15 IS NULL)
                  AND(x_attribute15 IS NULL)))
           AND(
               (recinfo.global_attribute_category = x_global_attribute_category)
               OR((recinfo.global_attribute_category IS NULL)
                  AND(x_global_attribute_category IS NULL))
              )
           AND((recinfo.global_attribute1 = x_global_attribute1)
               OR((recinfo.global_attribute1 IS NULL)
                  AND(x_global_attribute1 IS NULL)))
           AND((recinfo.global_attribute2 = x_global_attribute2)
               OR((recinfo.global_attribute2 IS NULL)
                  AND(x_global_attribute2 IS NULL)))
           AND((recinfo.global_attribute3 = x_global_attribute3)
               OR((recinfo.global_attribute3 IS NULL)
                  AND(x_global_attribute3 IS NULL)))
           AND((recinfo.global_attribute4 = x_global_attribute4)
               OR((recinfo.global_attribute4 IS NULL)
                  AND(x_global_attribute4 IS NULL)))
           AND((recinfo.global_attribute5 = x_global_attribute5)
               OR((recinfo.global_attribute5 IS NULL)
                  AND(x_global_attribute5 IS NULL)))
           AND((recinfo.global_attribute6 = x_global_attribute6)
               OR((recinfo.global_attribute6 IS NULL)
                  AND(x_global_attribute6 IS NULL)))
           AND((recinfo.global_attribute7 = x_global_attribute7)
               OR((recinfo.global_attribute7 IS NULL)
                  AND(x_global_attribute7 IS NULL)))
           AND((recinfo.global_attribute8 = x_global_attribute8)
               OR((recinfo.global_attribute8 IS NULL)
                  AND(x_global_attribute8 IS NULL)))
           AND((recinfo.global_attribute9 = x_global_attribute9)
               OR((recinfo.global_attribute9 IS NULL)
                  AND(x_global_attribute9 IS NULL)))
           AND(
               (recinfo.global_attribute10 = x_global_attribute10)
               OR((recinfo.global_attribute10 IS NULL)
                  AND(x_global_attribute10 IS NULL))
              )
           AND(
               (recinfo.global_attribute11 = x_global_attribute11)
               OR((recinfo.global_attribute11 IS NULL)
                  AND(x_global_attribute11 IS NULL))
              )
           AND(
               (recinfo.global_attribute12 = x_global_attribute12)
               OR((recinfo.global_attribute12 IS NULL)
                  AND(x_global_attribute12 IS NULL))
              )
           AND(
               (recinfo.global_attribute13 = x_global_attribute13)
               OR((recinfo.global_attribute13 IS NULL)
                  AND(x_global_attribute13 IS NULL))
              )
           AND(
               (recinfo.global_attribute14 = x_global_attribute14)
               OR((recinfo.global_attribute14 IS NULL)
                  AND(x_global_attribute14 IS NULL))
              )
           AND(
               (recinfo.global_attribute15 = x_global_attribute15)
               OR((recinfo.global_attribute15 IS NULL)
                  AND(x_global_attribute15 IS NULL))
              )
           AND(
               (recinfo.global_attribute16 = x_global_attribute16)
               OR((recinfo.global_attribute16 IS NULL)
                  AND(x_global_attribute16 IS NULL))
              )
           AND(
               (recinfo.global_attribute17 = x_global_attribute17)
               OR((recinfo.global_attribute17 IS NULL)
                  AND(x_global_attribute17 IS NULL))
              )
           AND(
               (recinfo.global_attribute18 = x_global_attribute18)
               OR((recinfo.global_attribute18 IS NULL)
                  AND(x_global_attribute18 IS NULL))
              )
           AND(
               (recinfo.global_attribute19 = x_global_attribute19)
               OR((recinfo.global_attribute19 IS NULL)
                  AND(x_global_attribute19 IS NULL))
              )
           AND(
               (recinfo.global_attribute20 = x_global_attribute20)
               OR((recinfo.global_attribute20 IS NULL)
                  AND(x_global_attribute20 IS NULL))
              )
           AND(
               (recinfo.default_demand_class = x_default_demand_class)
               OR((recinfo.default_demand_class IS NULL)
                  AND(x_default_demand_class IS NULL))
              )
           AND(
               (recinfo.encumbrance_reversal_flag = x_encumbrance_reversal_flag)
               OR((recinfo.encumbrance_reversal_flag IS NULL)
                  AND(x_encumbrance_reversal_flag IS NULL))
              )
           AND(
               (recinfo.maintain_fifo_qty_stack_type = x_maintain_fifo_qty_stack_type)
               OR((recinfo.maintain_fifo_qty_stack_type IS NULL)
                  AND(x_maintain_fifo_qty_stack_type IS NULL))
              )
           AND(
               (recinfo.invoice_price_var_account = x_invoice_price_var_account)
               OR((recinfo.invoice_price_var_account IS NULL)
                  AND(x_invoice_price_var_account IS NULL))
              )
           AND(
               (recinfo.average_cost_var_account = x_average_cost_var_account)
               OR((recinfo.average_cost_var_account IS NULL)
                  AND(x_average_cost_var_account IS NULL))
              )
-- For Bug 7440217
           AND(
               (recinfo.lcm_var_account = x_lcm_var_account)
               OR((recinfo.lcm_var_account IS NULL)
                  AND(x_lcm_var_account IS NULL))
              )
-- End for Bug 7440217
           AND((recinfo.sales_account = x_sales_account)
               OR((recinfo.sales_account IS NULL)
                  AND(x_sales_account IS NULL)))
           AND((recinfo.expense_account = x_expense_account)
               OR((recinfo.expense_account IS NULL)
                  AND(x_expense_account IS NULL)))
           AND(
               (recinfo.serial_number_generation = x_serial_number_generation)
               OR((recinfo.serial_number_generation IS NULL)
                  AND(x_serial_number_generation IS NULL))
              )
           AND(
               (recinfo.project_reference_enabled = x_project_reference_enabled)
               OR((recinfo.project_reference_enabled IS NULL)
                  AND(x_project_reference_enabled IS NULL))
              )
           AND(
               (recinfo.pm_cost_collection_enabled = x_pm_cost_collection_enabled)
               OR((recinfo.pm_cost_collection_enabled IS NULL)
                  AND(x_pm_cost_collection_enabled IS NULL))
              )
           AND(
               (recinfo.project_control_level = x_project_control_level)
               OR((recinfo.project_control_level IS NULL)
                  AND(x_project_control_level IS NULL))
              )
           AND(recinfo.avg_rates_cost_type_id = x_avg_rates_cost_type_id)
           AND(recinfo.txn_approval_timeout_period = x_txn_approval_timeout_period)
           AND(NVL(recinfo.borrpay_matl_var_account, -1) = NVL(x_borrpay_matl_var_account, -1))
           AND(NVL(recinfo.borrpay_moh_var_account, -1) = NVL(x_borrpay_moh_var_account, -1))
           AND(NVL(recinfo.borrpay_res_var_account, -1) = NVL(x_borrpay_res_var_account, -1))
           AND(NVL(recinfo.borrpay_osp_var_account, -1) = NVL(x_borrpay_osp_var_account, -1))
           AND(NVL(recinfo.borrpay_ovh_var_account, -1) = NVL(x_borrpay_ovh_var_account, -1))
           AND(NVL(recinfo.org_max_weight, -1) = NVL(x_org_max_weight, -1))
           AND(NVL(recinfo.org_max_volume, -1) = NVL(x_org_max_volume, -1))
           AND(NVL(recinfo.org_max_weight_uom_code, fnd_api.g_miss_char) = NVL(x_org_max_weight_uom_code, fnd_api.g_miss_char))
           AND(NVL(recinfo.org_max_volume_uom_code, fnd_api.g_miss_char) = NVL(x_org_max_volume_uom_code, fnd_api.g_miss_char))
           AND(NVL(recinfo.mo_source_required, -1) = NVL(x_mo_source_required, -1))
           AND(NVL(recinfo.mo_pick_confirm_required, -1) = NVL(x_mo_pick_confirm_required, -1))
           AND(NVL(recinfo.mo_approval_timeout_action, -1) = NVL(x_mo_approval_timeout_action, -1))
          --)
	  --Bug #4188383
	  --This was where the closing parantheses of the NOT condition was placed.
	  --Commented it out and placed the closing parantheses to include all of the following conditions also
       AND(
           (recinfo.pregen_putaway_tasks_flag = x_pregen_putaway_tasks_flag)
           OR((recinfo.pregen_putaway_tasks_flag IS NULL)
              AND(x_pregen_putaway_tasks_flag IS NULL))
          )
       AND(
           (recinfo.regeneration_interval = x_regeneration_interval)
           OR((recinfo.regeneration_interval IS NULL)
              AND(x_regeneration_interval IS NULL))
          )
       AND((recinfo.timezone_id = x_timezone_id)
           OR((recinfo.timezone_id IS NULL)
              AND(x_timezone_id IS NULL)))
       AND(
           (recinfo.default_wms_picking_rule_id = x_default_wms_picking_rule_id)
           OR((recinfo.default_wms_picking_rule_id IS NULL)
              AND(x_default_wms_picking_rule_id IS NULL))
          )
       AND(
           (recinfo.default_put_away_rule_id = x_default_put_away_rule_id)
           OR((recinfo.default_put_away_rule_id IS NULL)
              AND(x_default_put_away_rule_id IS NULL))
          )
       AND(
           (recinfo.default_carton_rule_id = x_default_carton_rule_id)
           OR((recinfo.default_carton_rule_id IS NULL)
              AND(x_default_carton_rule_id IS NULL))
          )
       AND(
           (recinfo.default_cyc_count_header_id = x_default_cyc_count_header_id)
           OR((recinfo.default_cyc_count_header_id IS NULL)
              AND(x_default_cyc_count_header_id IS NULL))
          )
       AND((recinfo.crossdock_flag = x_crossdock_flag)
           OR((recinfo.crossdock_flag IS NULL)
              AND(x_crossdock_flag IS NULL)))
       AND((recinfo.cartonization_flag = x_cartonization_flag)
           OR((recinfo.cartonization_flag IS NULL)
              AND(x_cartonization_flag IS NULL)))
       AND(
           (recinfo.default_pick_task_type_id = x_default_pick_task_type_id)
           OR((recinfo.default_pick_task_type_id IS NULL)
              AND(x_default_pick_task_type_id IS NULL))
          )
       AND(
           (recinfo.default_repl_task_type_id = x_default_repl_task_type_id)
           OR((recinfo.default_repl_task_type_id IS NULL)
              AND(x_default_repl_task_type_id IS NULL))
          )
       AND(
           (recinfo.default_cc_task_type_id = x_default_cc_task_type_id)
           OR((recinfo.default_cc_task_type_id IS NULL)
              AND(x_default_cc_task_type_id IS NULL))
          )
       AND(
           (recinfo.default_putaway_task_type_id = x_default_putaway_task_type_id)
           OR((recinfo.default_putaway_task_type_id IS NULL)
              AND(x_default_putaway_task_type_id IS NULL))
          )
       AND((recinfo.cost_cutoff_date = x_cost_cutoff_date)
           OR((recinfo.cost_cutoff_date IS NULL)
              AND(x_cost_cutoff_date IS NULL)))
       AND(
           (recinfo.skip_task_waiting_minutes = x_skip_task_waiting_minutes)
           OR((recinfo.skip_task_waiting_minutes IS NULL)
              AND(x_skip_task_waiting_minutes IS NULL))
          )
       AND(
           (recinfo.default_crossdock_subinventory = x_default_xdock_subinventory)
           OR((recinfo.default_crossdock_subinventory IS NULL)
              AND(x_default_xdock_subinventory IS NULL))
          )
       AND(
           (recinfo.prioritize_wip_jobs = x_prioritize_wip_jobs)
           OR((recinfo.prioritize_wip_jobs IS NULL)
              AND(x_prioritize_wip_jobs IS NULL))
          )
       AND(
           (recinfo.default_crossdock_locator_id = x_default_xdock_locator_id)
           OR((recinfo.default_crossdock_locator_id IS NULL)
              AND(x_default_xdock_locator_id IS NULL))
          )
       AND(
           (recinfo.distributed_organization_flag = x_distri_organization_flag)
           OR((recinfo.distributed_organization_flag IS NULL)
              AND(x_distri_organization_flag IS NULL))
          )
       AND(
           (recinfo.carrier_manifesting_flag = x_carrier_manifesting_flag)
           OR((recinfo.carrier_manifesting_flag IS NULL)
              AND(x_carrier_manifesting_flag IS NULL))
          )
       AND(
           (recinfo.distribution_account_id = x_distribution_account_id)
           OR((recinfo.distribution_account_id IS NULL)
              AND(x_distribution_account_id IS NULL))
          )
       AND(
           (recinfo.direct_shipping_allowed = x_direct_shipping_allowed)
           OR((recinfo.direct_shipping_allowed IS NULL)
              AND(x_direct_shipping_allowed IS NULL))
          )
       AND(
           (recinfo.default_moxfer_task_type_id = x_default_moxfer_task_type_id)
           OR((recinfo.default_moxfer_task_type_id IS NULL)
              AND(x_default_moxfer_task_type_id IS NULL))
          )
       AND(
           (recinfo.default_moissue_task_type_id = x_default_moissue_task_type_id)
           OR((recinfo.default_moissue_task_type_id IS NULL)
              AND(x_default_moissue_task_type_id IS NULL))
          )
       AND(NVL(recinfo.max_clusters_allowed, -1) = NVL(x_max_clusters_allowed, -1))
       AND(NVL(recinfo.default_pick_op_plan_id, -1) = NVL(x_default_pick_op_plan_id, -1))
       --AND(NVL(recinfo.consigned_flag, -1) = NVL(x_consigned_flag, -1))   /*Bug 4347477*/
       AND(NVL(recinfo.cartonize_sales_orders, -1) = NVL(x_cartonize_sales_orders, -1))
       AND(NVL(recinfo.cartonize_manufacturing, -1) = NVL(x_cartonize_manufacturing, -1))
       AND(NVL(recinfo.total_lpn_length, -1) = NVL(x_total_lpn_length, -1))
       AND(NVL(recinfo.ucc_128_suffix_flag, -1) = NVL(x_ucc_128_suffix_flag, -1))
       AND(NVL(recinfo.defer_logical_transactions, -1) = NVL(x_defer_logical_transactions, -1))
       AND(NVL(recinfo.wip_overpick_enabled, -1) = NVL(x_wip_overpick_enabled, -1)) --OVPK
       AND(NVL(recinfo.ovpk_transfer_orders_enabled, -1) = NVL(x_ovpk_transfer_orders_enabled, -1)) --OVPK
       --ER3969328: CI project
       AND (
             (recinfo.auto_del_alloc_flag = x_auto_del_alloc_flag)
             OR((recinfo.auto_del_alloc_flag IS NULL)
	         AND(x_auto_del_alloc_flag IS NULL))
	   )
	   -- Bug 4188383.
	   -- Rearranged the parenthesis of auto_del_alloc_flag above to cover the conditions
	   -- of auto_del_alloc_flag only; earlier it was covering RFID_VERIF_PCNT_THRESHOLD and WCS_ENABLED fields also.
	   -- Changed the code for clarity in reading.
       AND(NVL(recinfo.RFID_VERIF_PCNT_THRESHOLD, -1) = NVL(x_RFID_VERIF_PCNT_THRESHOLD, -1))
       AND(
         (recinfo.parent_child_generation_flag = x_parent_child_generation_flag)
           OR(
	     (recinfo.parent_child_generation_flag IS NULL)
              AND(x_parent_child_generation_flag IS NULL)
	     )
          )
       AND(
         (recinfo.child_lot_zero_padding_flag = x_child_lot_zero_padding_flag)
           OR((recinfo.child_lot_zero_padding_flag IS NULL)
              AND(x_child_lot_zero_padding_flag IS NULL))
          )
       AND(
         (recinfo.child_lot_alpha_prefix = x_child_lot_alpha_prefix)
           OR((recinfo.child_lot_alpha_prefix IS NULL)
              AND(x_child_lot_alpha_prefix IS NULL))
          )
       AND(
         (recinfo.child_lot_number_length = x_child_lot_number_length)
           OR((recinfo.child_lot_number_length IS NULL)
              AND(x_child_lot_number_length IS NULL))
          )
       AND(
         (recinfo.child_lot_validation_flag = x_child_lot_validation_flag)
           OR((recinfo.child_lot_validation_flag IS NULL)
              AND(x_child_lot_validation_flag IS NULL))
          )
       AND(
         (recinfo.copy_lot_attribute_flag = x_copy_lot_attribute_flag)
           OR((recinfo.copy_lot_attribute_flag IS NULL)
              AND(x_copy_lot_attribute_flag IS NULL))
          )
       --INVCONV nsinha
       -- NSINHA 9/15/2004 START: Added as part of convergence
       AND(
         (recinfo.create_lot_uom_conversion = x_create_lot_uom_conversion)
           OR((recinfo.create_lot_uom_conversion IS NULL)
              AND(x_create_lot_uom_conversion IS NULL))
          )
       AND(
         (recinfo.allow_different_status = x_allow_different_status)
           OR((recinfo.allow_different_status IS NULL)
              AND(x_allow_different_status IS NULL))
          )
       -- Added the below for # 6633612
       AND(
         (recinfo.default_status_id = x_default_status_id)
           OR((recinfo.default_status_id IS NULL)
              AND(x_default_status_id IS NULL))
          )

       AND(
         (recinfo.rules_override_lot_reservation = x_rules_override_lot_reserve)
           OR((recinfo.rules_override_lot_reservation IS NULL)
              AND(x_rules_override_lot_reserve IS NULL))
          )
       -- NSINHA 9/15/2004 END: Added as part of convergence
       -- END INVCONV nsinha
       AND(NVL(recinfo.wcs_enabled, -1) = NVL(x_wcs_enabled, -1)) --MHP
       AND((recinfo.trading_partner_org_flag = x_trading_partner_org_flag)
            OR((recinfo.trading_partner_org_flag IS NULL) AND(x_trading_partner_org_flag IS NULL)))
       AND((recinfo.deferred_cogs_account = x_deferred_cogs_account)
            OR((recinfo.deferred_cogs_account IS NULL) AND(x_deferred_cogs_account IS NULL)))
       AND((recinfo.default_crossdock_criteria_id = x_default_crossdok_criteria_id)
            OR((recinfo.default_crossdock_criteria_id IS NULL) AND(x_default_crossdok_criteria_id IS NULL)))
       AND((recinfo.enforce_locator_alis_unq_flag = x_enforce_locator_alis_uq_flag)
            OR((recinfo.enforce_locator_alis_unq_flag IS NULL) AND(x_enforce_locator_alis_uq_flag IS NULL)))
       AND((recinfo.epc_generation_enabled_flag = x_epc_generation_enabled_flag)
            OR((recinfo.epc_generation_enabled_flag IS NULL) AND(x_epc_generation_enabled_flag IS NULL)))
       AND((recinfo.company_prefix = x_company_prefix)
            OR((recinfo.company_prefix IS NULL) AND(x_company_prefix IS NULL)))
       AND((recinfo.company_prefix_index = x_company_prefix_index)
            OR((recinfo.company_prefix_index IS NULL) AND(x_company_prefix_index IS NULL)))
       AND((recinfo.commercial_govt_entity_number = x_commercial_gov_entity_number)
            OR((recinfo.commercial_govt_entity_number IS NULL) AND(x_commercial_gov_entity_number IS NULL)))
       AND((recinfo.labor_management_enabled_flag = x_lbr_management_enabled_flag)
            OR((recinfo.labor_management_enabled_flag IS NULL) AND(x_lbr_management_enabled_flag IS NULL)))
	     --Bug #4188383 Placed the closing parantheses of the NOT condition here to include all the conditions above.
       AND((recinfo.opsm_enabled_flag = x_opsm_enabled_flag)
            OR((recinfo.opsm_enabled_flag IS NULL) AND(x_opsm_enabled_flag IS NULL))) -- Added for OPSM
          )
        THEN
      RAISE record_changed;
    END IF;
  EXCEPTION
    WHEN record_changed THEN
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    WHEN OTHERS THEN
      RAISE;
  END lock_row;

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
  , x_max_clusters_allowed         NUMBER
  , x_default_pick_op_plan_id      NUMBER
  , x_consigned_flag               VARCHAR2
  , x_cartonize_sales_orders       VARCHAR2
  , x_cartonize_manufacturing      VARCHAR2
  , x_total_lpn_length             NUMBER
  , x_ucc_128_suffix_flag          VARCHAR2
  , x_defer_logical_transactions   NUMBER
  , x_wip_overpick_enabled         VARCHAR2 --OVPK
  , x_ovpk_transfer_orders_enabled VARCHAR2 --OVPK
  , x_auto_del_alloc_flag          VARCHAR2 --ER3969328: CI project
  , X_RFID_VERIF_PCNT_THRESHOLD    NUMBER -- 11.5.10+ RFID Compliance
  , x_parent_child_generation_flag VARCHAR2 DEFAULT NULL
  , x_child_lot_zero_padding_flag  VARCHAR2 DEFAULT NULL
  , x_child_lot_alpha_prefix       VARCHAR2 DEFAULT NULL
  , x_child_lot_number_length      NUMBER DEFAULT NULL
  , x_child_lot_validation_flag    VARCHAR2 DEFAULT NULL
  , x_copy_lot_attribute_flag      VARCHAR2 DEFAULT NULL
  , x_create_lot_uom_conversion       NUMBER DEFAULT NULL    -- NSINHA
  , x_allow_different_status          NUMBER DEFAULT NULL    -- NSINHA
  , x_rules_override_lot_reserve      VARCHAR2 DEFAULT NULL  -- NSINHA
  , x_wcs_enabled                   VARCHAR2 --MHP
  , x_trading_partner_org_flag      VARCHAR2 DEFAULT NULL
  , x_deferred_cogs_account         NUMBER   DEFAULT NULL
  , x_default_crossdok_criteria_id  NUMBER   DEFAULT NULL
  , x_enforce_locator_alis_uq_flag  VARCHAR2 DEFAULT NULL
  , x_epc_generation_enabled_flag   VARCHAR2 DEFAULT NULL
  , x_company_prefix                VARCHAR2 DEFAULT NULL
  , x_company_prefix_index          VARCHAR2 DEFAULT NULL
  , x_commercial_gov_entity_number  VARCHAR2 DEFAULT NULL
  , x_lbr_management_enabled_flag   VARCHAR2 DEFAULT NULL
  , x_default_status_id NUMBER DEFAULT NULL -- Added for # 6633612
  , x_opsm_enabled_flag VARCHAR2 -- Added for OPSM
  ) IS
  BEGIN
    UPDATE mtl_parameters
       SET organization_id = x_organization_id
         , last_update_date = x_last_update_date
         , last_updated_by = x_last_updated_by
         , last_update_login = x_last_update_login
         , organization_code = x_organization_code
         , master_organization_id = x_master_organization_id
         , primary_cost_method = x_primary_cost_method
         , cost_organization_id = x_cost_organization_id
         , default_material_cost_id = x_default_material_cost_id
         , default_matl_ovhd_cost_id = x_default_matl_ovhd_cost_id
         , calendar_exception_set_id = x_calendar_exception_set_id
         , calendar_code = x_calendar_code
         , general_ledger_update_code = x_general_ledger_update_code
         , default_atp_rule_id = x_default_atp_rule_id
         , default_picking_rule_id = x_default_picking_rule_id
         , default_locator_order_value = x_default_locator_order_value
         , default_subinv_order_value = x_default_subinv_order_value
         , negative_inv_receipt_code = x_negative_inv_receipt_code
         , stock_locator_control_code = x_stock_locator_control_code
         , material_account = x_material_account
         , material_overhead_account = x_material_overhead_account
         , matl_ovhd_absorption_acct = x_matl_ovhd_absorption_acct
         , resource_account = x_resource_account
         , purchase_price_var_account = x_purchase_price_var_account
         , ap_accrual_account = x_ap_accrual_account
         , overhead_account = x_overhead_account
         , outside_processing_account = x_outside_processing_account
         , intransit_inv_account = x_intransit_inv_account
         , interorg_receivables_account = x_interorg_receivables_account
         , interorg_price_var_account = x_interorg_price_var_account
         , interorg_payables_account = x_interorg_payables_account
         , cost_of_sales_account = x_cost_of_sales_account
         , encumbrance_account = x_encumbrance_account
         , interorg_transfer_cr_account = x_interorg_transfer_cr_account
         , matl_interorg_transfer_code = x_matl_interorg_transfer_code
         , interorg_trnsfr_charge_percent = x_interorg_trnsfr_charge_perc
         , source_organization_id = x_source_organization_id
         , source_subinventory = x_source_subinventory
         , source_type = x_source_type
         , serial_number_type = x_serial_number_type
         , auto_serial_alpha_prefix = x_auto_serial_alpha_prefix
         , start_auto_serial_number = x_start_auto_serial_number
         , auto_lot_alpha_prefix = x_auto_lot_alpha_prefix
         , lot_number_uniqueness = x_lot_number_uniqueness
         , lot_number_generation = x_lot_number_generation
         , lot_number_zero_padding = x_lot_number_zero_padding
         , lot_number_length = x_lot_number_length
         , starting_revision = x_starting_revision
         , attribute_category = x_attribute_category
         , attribute1 = x_attribute1
         , attribute2 = x_attribute2
         , attribute3 = x_attribute3
         , attribute4 = x_attribute4
         , attribute5 = x_attribute5
         , attribute6 = x_attribute6
         , attribute7 = x_attribute7
         , attribute8 = x_attribute8
         , attribute9 = x_attribute9
         , attribute10 = x_attribute10
         , attribute11 = x_attribute11
         , attribute12 = x_attribute12
         , attribute13 = x_attribute13
         , attribute14 = x_attribute14
         , attribute15 = x_attribute15
         , global_attribute_category = x_global_attribute_category
         , global_attribute1 = x_global_attribute1
         , global_attribute2 = x_global_attribute2
         , global_attribute3 = x_global_attribute3
         , global_attribute4 = x_global_attribute4
         , global_attribute5 = x_global_attribute5
         , global_attribute6 = x_global_attribute6
         , global_attribute7 = x_global_attribute7
         , global_attribute8 = x_global_attribute8
         , global_attribute9 = x_global_attribute9
         , global_attribute10 = x_global_attribute10
         , global_attribute11 = x_global_attribute11
         , global_attribute12 = x_global_attribute12
         , global_attribute13 = x_global_attribute13
         , global_attribute14 = x_global_attribute14
         , global_attribute15 = x_global_attribute15
         , global_attribute16 = x_global_attribute16
         , global_attribute17 = x_global_attribute17
         , global_attribute18 = x_global_attribute18
         , global_attribute19 = x_global_attribute19
         , global_attribute20 = x_global_attribute20
         , default_demand_class = x_default_demand_class
         , encumbrance_reversal_flag = x_encumbrance_reversal_flag
         , maintain_fifo_qty_stack_type = x_maintain_fifo_qty_stack_type
         , invoice_price_var_account = x_invoice_price_var_account
         , average_cost_var_account = x_average_cost_var_account
-- For Bug 7440217
         , lcm_var_account = x_lcm_var_account
-- End for Bug 7440217
         , sales_account = x_sales_account
         , expense_account = x_expense_account
         , serial_number_generation = x_serial_number_generation
         , project_reference_enabled = x_project_reference_enabled
         , pm_cost_collection_enabled = x_pm_cost_collection_enabled
         , project_control_level = x_project_control_level
         , avg_rates_cost_type_id = x_avg_rates_cost_type_id
         , txn_approval_timeout_period = x_txn_approval_timeout_period
         , borrpay_matl_var_account = x_borrpay_matl_var_account
         , borrpay_moh_var_account = x_borrpay_moh_var_account
         , borrpay_res_var_account = x_borrpay_res_var_account
         , borrpay_osp_var_account = x_borrpay_osp_var_account
         , borrpay_ovh_var_account = x_borrpay_ovh_var_account
         , org_max_weight = x_org_max_weight
         , org_max_volume = x_org_max_volume
         , org_max_weight_uom_code = x_org_max_weight_uom_code
         , org_max_volume_uom_code = x_org_max_volume_uom_code
         , mo_source_required = x_mo_source_required
         , mo_pick_confirm_required = NVL(x_mo_pick_confirm_required,'2')
         , mo_approval_timeout_action = x_mo_approval_timeout_action
         , project_cost_account = x_project_cost_account
         , process_enabled_flag = x_process_enabled_flag
         , process_orgn_code = x_process_orgn_code
         , default_cost_group_id = x_default_cost_group_id
         , lpn_prefix = x_lpn_prefix
         , lpn_suffix = x_lpn_suffix
         , lpn_starting_number = x_lpn_starting_number
         , wms_enabled_flag = NVL(x_wms_enabled_flag, 'N')
-- For Bug 7440217
         , lcm_enabled_flag = NVL(x_lcm_enabled_flag, 'N')
-- End for Bug 7440217
         , qa_skipping_insp_flag = NVL(x_qa_skipping_insp_flag, 'N')
         , eam_enabled_flag = NVL(x_eam_enabled_flag, 'N')
         , maint_organization_id = x_maint_organization_id
         , pregen_putaway_tasks_flag = x_pregen_putaway_tasks_flag
         , regeneration_interval = x_regeneration_interval
         , timezone_id = x_timezone_id
         , default_wms_picking_rule_id = x_default_wms_picking_rule_id
         , default_put_away_rule_id = x_default_put_away_rule_id
         , default_carton_rule_id = x_default_carton_rule_id
         , default_cyc_count_header_id = x_default_cyc_count_header_id
         , crossdock_flag = x_crossdock_flag
         , cartonization_flag = x_cartonization_flag
         , allocate_serial_flag = x_allocate_serial_flag
         , default_pick_task_type_id = x_default_pick_task_type_id
         , default_repl_task_type_id = x_default_repl_task_type_id
         , default_cc_task_type_id = x_default_cc_task_type_id
         , default_putaway_task_type_id = x_default_putaway_task_type_id
         , cost_cutoff_date = x_cost_cutoff_date
         , skip_task_waiting_minutes = x_skip_task_waiting_minutes
         , prioritize_wip_jobs = x_prioritize_wip_jobs
         , default_crossdock_subinventory = x_default_xdock_subinventory
         , default_crossdock_locator_id = x_default_xdock_locator_id
         , distributed_organization_flag = x_distri_organization_flag
         , carrier_manifesting_flag = x_carrier_manifesting_flag
         , distribution_account_id = x_distribution_account_id
         , direct_shipping_allowed = x_direct_shipping_allowed
         , default_moxfer_task_type_id = x_default_moxfer_task_type_id
         , default_moissue_task_type_id = x_default_moissue_task_type_id
         , max_clusters_allowed = x_max_clusters_allowed
         , default_pick_op_plan_id = x_default_pick_op_plan_id
         --, consigned_flag = x_consigned_flag    /*Bug 4347477*/
         , cartonize_sales_orders = x_cartonize_sales_orders
         , cartonize_manufacturing = x_cartonize_manufacturing
         , total_lpn_length = x_total_lpn_length
         , ucc_128_suffix_flag = x_ucc_128_suffix_flag
         , defer_logical_transactions = x_defer_logical_transactions
         , wip_overpick_enabled = NVL(x_wip_overpick_enabled,'N') --OVPK
         , ovpk_transfer_orders_enabled = NVL(x_ovpk_transfer_orders_enabled,'Y') --OVPK
	 , auto_del_alloc_flag = x_auto_del_alloc_flag --ER3969328: CI project
         , rfid_verif_pcnt_threshold = X_Rfid_verif_pcnt_threshold --11.5.10+ RFID Compliance
         , parent_child_generation_flag = x_parent_child_generation_flag
         , child_lot_zero_padding_flag = x_child_lot_zero_padding_flag
         , child_lot_alpha_prefix = x_child_lot_alpha_prefix
         , child_lot_number_length = x_child_lot_number_length
         , child_lot_validation_flag = x_child_lot_validation_flag
         , copy_lot_attribute_flag = x_copy_lot_attribute_flag
         , create_lot_uom_conversion       = x_create_lot_uom_conversion       -- NSINHA
         , allow_different_status          = x_allow_different_status          -- NSINHA
         , rules_override_lot_reservation  = x_rules_override_lot_reserve      -- NSINHA
         , wcs_enabled = x_wcs_enabled --MHP
         , trading_partner_org_flag      = x_trading_partner_org_flag
         , deferred_cogs_account         = x_deferred_cogs_account
         , default_crossdock_criteria_id = x_default_crossdok_criteria_id
         , enforce_locator_alis_unq_flag = x_enforce_locator_alis_uq_flag
         , epc_generation_enabled_flag   = x_epc_generation_enabled_flag
         , company_prefix                = x_company_prefix
         , company_prefix_index          = x_company_prefix_index
         , commercial_govt_entity_number = x_commercial_gov_entity_number
         , labor_management_enabled_flag = x_lbr_management_enabled_flag
         , default_status_id = x_default_status_id -- Added for # 6633612
         , opsm_enabled_flag = x_opsm_enabled_flag -- Added for OPSM
     WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;

  PROCEDURE delete_row(x_rowid VARCHAR2) IS
  BEGIN
    DELETE FROM mtl_parameters
          WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

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
  ) IS
    TYPE table_of_rowids IS TABLE OF ROWID
      INDEX BY BINARY_INTEGER;

    ROWS          table_of_rowids;
    resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy, -00054);
    j             NUMBER          := NULL;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT     ROWID
    BULK COLLECT INTO ROWS
          FROM mtl_secondary_inventories
         WHERE organization_id = p_organization_id
    FOR UPDATE NOWAIT;

    --Bug 2164055  fix

    IF ((ROWS IS NULL)
        OR(ROWS.COUNT = 0)) THEN
      NULL;
    -- No Subinventories to update
    ELSE
      FORALL j IN ROWS.FIRST .. ROWS.LAST
        UPDATE mtl_secondary_inventories
           SET default_cost_group_id = p_default_cost_group_id
             , material_account = p_material_account
             , material_overhead_account = p_material_overhead_account
             , resource_account = p_resource_account
             , overhead_account = p_overhead_account
             , outside_processing_account = p_outside_processing_account
         --expense_account     =  p_Expense_Account,
         --encumbrance_account   =  p_Encumbrance_Account
        WHERE  ROWID = ROWS(j);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN resource_busy THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_success;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'MTL_PARAMETERS_PKG');
      END IF;
  END upd_sub_accts_with_org_accts;

  FUNCTION get_miss_num
    RETURN NUMBER IS
  BEGIN
    RETURN fnd_api.g_miss_num;
  END;

  PROCEDURE default_pjm_rule_setup(
    x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
  , p_organization_id IN            NUMBER
  ) IS
    strgy_assn_exist    VARCHAR2(1) := 'N';
    l_stg_assignment_id NUMBER;
  --l_row_id         ROWID;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Added by grao on 02 Dec, 2002 for the new Strrategy Assignment Matrix
    --
    BEGIN
      SELECT 'Y'
        INTO strgy_assn_exist
        FROM DUAL
       WHERE EXISTS(SELECT from_organization_id
                      FROM wms_selection_criteria_txn
                     WHERE from_organization_id = p_organization_id
                       AND return_type_code = 'S'
                       AND return_type_id = 8
                       AND rule_type_code = 2);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        strgy_assn_exist  := 'N';
    END;

    IF strgy_assn_exist = 'Y' THEN
      RETURN;
    END IF;

    SELECT wms_selection_criteria_txn_s.NEXTVAL
      INTO l_stg_assignment_id
      FROM DUAL;

    wms_strategy_upgrade_pvt.insert_row(
      x_stg_assignment_id          => l_stg_assignment_id
    , x_sequence_number            => 10
    , x_rule_type_code             => 2
    , x_return_type_code           => 'S'
    , x_return_type_id             => 8
    , x_enabled_flag               => 1
    , x_date_type_code             => 11
    , x_date_type_from             => NULL
    , x_date_type_to               => NULL
    , x_date_type_lookup_type      => NULL
    , x_effective_from             => NULL
    , x_effective_to               => NULL
    , x_from_organization_id       => p_organization_id
    , x_from_subinventory_name     => NULL
    , x_to_organization_id         => NULL
    , x_to_subinventory_name       => NULL
    , x_customer_id                => NULL
    , x_freight_code               => NULL
    , x_inventory_item_id          => NULL
    , x_item_type                  => NULL
    , x_assignment_group_id        => NULL
    , x_abc_class_id               => NULL
    , x_category_set_id            => NULL
    , x_category_id                => NULL
    , x_order_type_id              => NULL
    , x_vendor_id                  => NULL
    , x_project_id                 => NULL
    , x_task_id                    => NULL
    , x_user_id                    => NULL
    , x_transaction_action_id      => NULL
    , x_reason_id                  => NULL
    , x_transaction_source_type_id => NULL
    , x_transaction_type_id        => NULL
    , x_uom_code                   => NULL
    , x_uom_class                  => NULL
    , x_last_updated_by            => fnd_global.user_id
    , x_last_update_date           => SYSDATE
    , x_created_by                 => fnd_global.user_id
    , x_creation_date              => SYSDATE
    , x_last_update_login          => fnd_global.login_id
    );
  --- End of new code

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END default_pjm_rule_setup;

  FUNCTION g_ret_sts_success
    RETURN VARCHAR2 IS
  BEGIN
    RETURN fnd_api.g_ret_sts_success;
  END;
END mtl_parameters_pkg;

/

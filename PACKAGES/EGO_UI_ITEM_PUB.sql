--------------------------------------------------------
--  DDL for Package EGO_UI_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_UI_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOITUIS.pls 115.14 2004/06/07 00:12:02 absinha noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOITUIS.pls';

-- =============================================================================
--                          Global variables and cursors
-- =============================================================================

G_BO_Identifier		CONSTANT    VARCHAR2(30) :=  'EGO_ITEM';

G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR		CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR	CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

--G_MISS_NUM	      	CONSTANT    NUMBER	 :=  9.99E125;
--G_MISS_CHAR	      	CONSTANT    VARCHAR2(1)  :=  CHR(0);
--G_MISS_DATE	       	CONSTANT    DATE	 :=  TO_DATE('1','j');
G_MISS_NUM	      	CONSTANT    NUMBER	 :=  FND_API.G_MISS_NUM;
G_MISS_CHAR	      	CONSTANT    VARCHAR2(1)  :=  FND_API.G_MISS_CHAR;
G_MISS_DATE	       	CONSTANT    DATE	 :=  FND_API.G_MISS_DATE;
G_FALSE                 CONSTANT    VARCHAR2(10) :=  FND_API.G_FALSE; -- 'F'

-- =============================================================================
--                                 Global types
-- =============================================================================



-- =============================================================================
--                               Public Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:	      Update_Item_Lifecycle
--
--  Type:	      	Public
--
--  Description:
--                      Update Item Lifecycle and Lifecycle Phase.
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

Procedure Process_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  P_TRANSACTION_TYPE            IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
);

Procedure Create_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
);

Procedure Update_Item_Lifecycle(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_LIFECYCLE_ID                IN   NUMBER,
  P_CURRENT_PHASE_ID            IN   NUMBER,
  P_ITEM_STATUS                 IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER
);

-- -----------------------------------------------------------------------------
--  API Name:         Update_Item_Attr_Ext
--
--  Type:               Public
--
--  Description:
--                      Update Item Catalog Group Id
--
--  Version:            Current version 1.0
-- -----------------------------------------------------------------------------

Procedure Update_Item_Attr_Ext(
  P_API_VERSION                 IN   NUMBER,
  P_INIT_MSG_LIST               IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ITEM_CATALOG_GROUP_ID       IN   NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER
);

/******************************************************************
** Procedure: Get_Master_Organization_Id (unexposed)
********************************************************************/
FUNCTION Get_Master_Organization_Id(
  P_ORGANIZATION_ID  IN NUMBER
) RETURN NUMBER;

/******************************************************************
** Procedure: Get_Item_Attr_Control_Level (unexposed)
********************************************************************/
FUNCTION Get_Item_Attr_Control_Level(
  P_ITEM_ATTRIBUTE IN VARCHAR2
) RETURN NUMBER;

-- -----------------------------------------------------------------------------
--  API Name:	      Set_Debug_Parameters
--
--  Type:
--
--  Description:
--                      Error file for Developer Debug messages.
--
--  Version:		Current version 1.0
-- -----------------------------------------------------------------------------

/******************************************************************
** Procedure: Set_Debug_Parameters (unexposed)
** Purpose: Will take input as the debug parameters and check if
** a debug session needs to be eastablished. If yes, the it will
** open a debug session file and all developer messages will be
** logged into a debug error file. File name will be the parameter
** debug_file_name_<session_id>
********************************************************************/
Procedure Set_Debug_Parameters(
      P_debug_flag      IN VARCHAR2
    , P_output_dir      IN VARCHAR2
    , P_debug_filename  IN VARCHAR2
);


-- ----------------------------------------------------------------
--  API Name:    Process_Item
--  Type:        Public
--  Version:     Current version 1.0
--
--  Function:    Process (CREATE/UPDATE) one item using IOI
--  Notes:
--
--  History:
--     23-SEP-2003    Sridhar Rajaparthi     Creation (bug 3143834)
-- ----------------------------------------------------------------
PROCEDURE Process_Item
(
 p_api_version                    IN   NUMBER
,p_init_msg_list                  IN   VARCHAR2   DEFAULT  G_FALSE
,p_commit                         IN   VARCHAR2   DEFAULT  G_FALSE
-- Transaction data
,p_Transaction_Type               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_Language_Code                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
-- Copy item from template
,p_Template_Id                    IN   NUMBER     DEFAULT  NULL
,p_Template_Name                  IN   VARCHAR2   DEFAULT  NULL
-- Copy item from another item
,p_copy_inventory_item_Id         IN   NUMBER     DEFAULT  G_MISS_NUM
-- Base Attributes
,p_inventory_item_id              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_organization_id                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_master_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_description                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_long_description               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_primary_uom_code               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_primary_unit_of_measure        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_item_type                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_inventory_item_status_code     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_allowed_units_lookup_code      IN   NUMBER     DEFAULT  G_MISS_NUM
,p_item_catalog_group_id          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_catalog_status_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_inventory_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_stock_enabled_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_mtl_transactions_enabled_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_check_shortages_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_revision_qty_control_code      IN   NUMBER     DEFAULT  G_MISS_NUM
,p_reservable_type                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_shelf_life_code                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_shelf_life_days                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_cycle_count_enabled_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_negative_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_positive_measurement_error     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_lot_control_code               IN   NUMBER     DEFAULT  G_MISS_NUM
,p_auto_lot_alpha_prefix          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_start_auto_lot_number          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serial_number_control_code     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_auto_serial_alpha_prefix       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_start_auto_serial_number       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_location_control_code          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_restrict_subinventories_cod    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_restrict_locators_code         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_bom_enabled_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_bom_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
,p_base_item_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
,p_effectivity_control            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_eng_item_flag                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_engineering_ecn_code           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_engineering_item_id            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_engineering_date               IN   DATE       DEFAULT  G_MISS_DATE
,p_product_family_item_id         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_auto_created_config_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_model_config_clause_name       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
-- attribute not in the form
,p_new_revision_code              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_costing_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_inventory_asset_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_default_include_in_rollup_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_cost_of_sales_account          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_std_lot_size                   IN   NUMBER     DEFAULT  G_MISS_NUM
,p_purchasing_item_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_purchasing_enabled_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_must_use_approved_vendor_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_allow_item_desc_update_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_rfq_required_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_outside_operation_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_outside_operation_uom_type     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_taxable_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_purchasing_tax_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_receipt_required_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_inspection_required_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_buyer_id                       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_unit_of_issue                  IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_receive_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_invoice_close_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_un_number_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
,p_hazard_class_id                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_list_price_per_unit            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_market_price                   IN   NUMBER     DEFAULT  G_MISS_NUM
,p_price_tolerance_percent        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_rounding_factor                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_encumbrance_account            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_expense_account                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_expense_billable_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_asset_category_id              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_receipt_days_exception_code    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_days_early_receipt_allowed     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_days_late_receipt_allowed      IN   NUMBER     DEFAULT  G_MISS_NUM
,p_allow_substitute_receipts_f    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_allow_unordered_receipts_fl    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_allow_express_delivery_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_qty_rcv_exception_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_qty_rcv_tolerance              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_receiving_routing_id           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_enforce_ship_to_location_c     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_weight_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_unit_weight                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_volume_uom_code                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_unit_volume                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_container_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_vehicle_item_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_container_type_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_internal_volume                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_maximum_load_weight            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_minimum_fill_percent           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_inventory_planning_code        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_planner_code                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_planning_make_buy_code         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_min_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_max_minmax_quantity            IN   NUMBER     DEFAULT  G_MISS_NUM
,p_minimum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_maximum_order_quantity         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_order_cost                     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_carrying_cost                  IN   NUMBER     DEFAULT  G_MISS_NUM
,p_source_type                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_source_organization_id         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_source_subinventory            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_mrp_safety_stock_code          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_safety_stock_bucket_days       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_mrp_safety_stock_percent       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_fixed_order_quantity           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_fixed_days_supply              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_fixed_lot_multiplier           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_mrp_planning_code              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_ato_forecast_control           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_planning_exception_set         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_end_assembly_pegging_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_shrinkage_rate                 IN   NUMBER     DEFAULT  G_MISS_NUM
,p_rounding_control_type          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_acceptable_early_days          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_repetitive_planning_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_overrun_percentage             IN   NUMBER     DEFAULT  G_MISS_NUM
,p_acceptable_rate_increase       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_acceptable_rate_decrease       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_mrp_calculate_atp_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_auto_reduce_mps                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_planning_time_fence_code       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_planning_time_fence_days       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_demand_time_fence_code         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_demand_time_fence_days         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_release_time_fence_code        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_release_time_fence_days        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_preprocessing_lead_time        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_full_lead_time                 IN   NUMBER     DEFAULT  G_MISS_NUM
,p_postprocessing_lead_time       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_fixed_lead_time                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_variable_lead_time             IN   NUMBER     DEFAULT  G_MISS_NUM
,p_cum_manufacturing_lead_time    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_cumulative_total_lead_time     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_lead_time_lot_size             IN   NUMBER     DEFAULT  G_MISS_NUM
,p_build_in_wip_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_wip_supply_type                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_wip_supply_subinventory        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_wip_supply_locator_id          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_overcompletion_tolerance_ty    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_overcompletion_tolerance_va    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_customer_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_customer_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_shippable_item_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_internal_order_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_internal_order_enabled_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_so_transactions_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_pick_components_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_atp_flag                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_replenish_to_order_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_atp_rule_id                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_atp_components_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_ship_model_complete_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_picking_rule_id                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_collateral_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_default_shipping_org           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_returnable_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_return_inspection_requireme    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_over_shipment_tolerance        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_under_shipment_tolerance       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_over_return_tolerance          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_under_return_tolerance         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_invoiceable_item_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_invoice_enabled_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_accounting_rule_id             IN   NUMBER     DEFAULT  G_MISS_NUM
,p_invoicing_rule_id              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_tax_code                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_sales_account                  IN   NUMBER     DEFAULT  G_MISS_NUM
,p_payment_terms_id               IN   NUMBER     DEFAULT  G_MISS_NUM
,p_coverage_schedule_id           IN   NUMBER     DEFAULT  G_MISS_NUM
,p_service_duration               IN   NUMBER     DEFAULT  G_MISS_NUM
,p_service_duration_period_cod    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serviceable_product_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_service_starting_delay         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_material_billable_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serviceable_component_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_preventive_maintenance_flag    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_prorate_service_flag           IN   VARCHAR2   DEFAULT  G_MISS_CHAR
-- attribute not in the form
,p_serviceable_item_class_id      IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_base_warranty_service_id       IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_warranty_vendor_id             IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_max_warranty_amount            IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_response_time_period_code      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
-- attribute not in the form
,p_response_time_value            IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_primary_specialist_id          IN   NUMBER     DEFAULT  G_MISS_NUM
-- attribute not in the form
,p_secondary_specialist_id        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_wh_update_date                 IN   DATE       DEFAULT  G_MISS_DATE
,p_equipment_type                 IN   NUMBER     DEFAULT  G_MISS_NUM
,p_recovered_part_disp_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_defect_tracking_on_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_event_flag                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_electronic_flag                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_downloadable_flag              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_vol_discount_exempt_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_coupon_exempt_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_comms_nl_trackable_flag        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_asset_creation_code            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_comms_activation_reqd_flag     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_orderable_on_web_flag          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_back_orderable_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_web_status                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_indivisible_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_dimension_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_unit_length                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_unit_width                     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_unit_height                    IN   NUMBER     DEFAULT  G_MISS_NUM
,p_bulk_picked_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_lot_status_enabled             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_default_lot_status_id          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_serial_status_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_default_serial_status_id       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_lot_split_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_lot_merge_enabled              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_inventory_carry_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_operation_slack_penalty        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_financing_allowed_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_eam_item_type                  IN   NUMBER     DEFAULT  G_MISS_NUM
,p_eam_activity_type_code         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_eam_activity_cause_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_eam_act_notification_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_eam_act_shutdown_status        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_dual_uom_control               IN   NUMBER     DEFAULT  G_MISS_NUM
,p_secondary_uom_code             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_dual_uom_deviation_high        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_dual_uom_deviation_low         IN   NUMBER     DEFAULT  G_MISS_NUM
-- derived attributes
--,p_service_item_flag               IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--,p_vendor_warranty_flag            IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--,p_usage_item_flag                 IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_contract_item_type_code        IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_subscription_depend_flag       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serv_req_enabled_code          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serv_billing_enabled_flag      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_serv_importance_level          IN   NUMBER     DEFAULT  G_MISS_NUM
,p_planned_inv_point_flag         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_lot_translate_enabled          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_default_so_source_type         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_create_supply_flag             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_substitution_window_code       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_substitution_window_days       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_ib_item_instance_class         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_config_model_type              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--added for 11.5.9 enh
,p_lot_substitution_enabled       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_minimum_license_quantity       IN   NUMBER     DEFAULT  G_MISS_NUM
,p_eam_activity_source_code       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--added for 11.5.10 enh
,p_tracking_quantity_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_ont_pricing_qty_source         IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_secondary_default_ind          IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_option_specific_sourced        IN   NUMBER     DEFAULT  G_MISS_NUM
,p_approval_status                IN   VARCHAR2   DEFAULT  G_MISS_CHAR
--
,p_Item_Number                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment1                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment2                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment3                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment4                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment5                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment6                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment7                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment8                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment9                       IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment10                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment11                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment12                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment13                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment14                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment15                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment16                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment17                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment18                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment19                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_segment20                      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_summary_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_enabled_flag                   IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_start_date_active              IN   DATE       DEFAULT  G_MISS_DATE
,p_end_date_active                IN   DATE       DEFAULT  G_MISS_DATE
,p_attribute_category             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute1                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute2                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute3                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute4                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute5                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute6                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute7                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute8                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute9                     IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute10                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute11                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute12                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute13                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute14                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_attribute15                    IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute_category      IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute1              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute2              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute3              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute4              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute5              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute6              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute7              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute8              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute9              IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_global_attribute10             IN   VARCHAR2   DEFAULT  G_MISS_CHAR
,p_creation_date                  IN   DATE       DEFAULT  G_MISS_DATE
,p_created_by                     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_last_update_date               IN   DATE       DEFAULT  G_MISS_DATE
,p_last_updated_by                IN   NUMBER     DEFAULT  G_MISS_NUM
,p_last_update_login              IN   NUMBER     DEFAULT  G_MISS_NUM
,p_request_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_program_application_id         IN   NUMBER     DEFAULT  G_MISS_NUM
,p_program_id                     IN   NUMBER     DEFAULT  G_MISS_NUM
,p_program_update_date            IN   DATE       DEFAULT  G_MISS_DATE
,p_lifecycle_id                   IN   NUMBER     DEFAULT  G_MISS_NUM
,p_current_phase_id               IN   NUMBER     DEFAULT  G_MISS_NUM
 -- Returned item id
,x_Inventory_Item_Id              OUT NOCOPY    NUMBER
,x_Organization_Id                OUT NOCOPY    NUMBER
,x_return_status                  OUT NOCOPY    VARCHAR2
,x_msg_count                      OUT NOCOPY    NUMBER
,x_msg_data                       OUT NOCOPY    VARCHAR2
);


-- -----------------------------------------------------------------------------
--  API Name:		Process_Item
--
--  Type:
--
--  Description:
--                      Process (UPDATE) one item. To be used from PLM UI only
--
--  Version:		Current version 1.0
--  History:
--    20-JAN-2002  Sridhar R            Removed the default to FND_API values
--                                      in the procedure process_item
-- -----------------------------------------------------------------------------
PROCEDURE Process_Item
(
   p_api_version	      	IN	NUMBER
,  p_init_msg_list		IN	VARCHAR2
,  p_commit		      	IN	VARCHAR2
 -- Transaction data
,  p_Transaction_Type		IN	VARCHAR2
,  p_Language_Code		IN	VARCHAR2
 -- Organization
,  p_Organization_Id		IN	NUMBER
,  p_Organization_Code		IN	VARCHAR2
 -- Item catalog group
,  p_Item_Catalog_Group_Id	IN	NUMBER
,  p_Catalog_Status_Flag	IN	VARCHAR2
 -- Copy item from
,  p_Template_Id	        IN	NUMBER
,  p_Template_Name		IN	VARCHAR2
 -- Item identifier
,  p_Inventory_Item_Id		IN	NUMBER
,  p_Item_Number	        IN	VARCHAR2
,  p_Segment1			IN	VARCHAR2
,  p_Segment2			IN	VARCHAR2
,  p_Segment3			IN	VARCHAR2
,  p_Segment4			IN	VARCHAR2
,  p_Segment5			IN	VARCHAR2
,  p_Segment6			IN	VARCHAR2
,  p_Segment7			IN	VARCHAR2
,  p_Segment8			IN	VARCHAR2
,  p_Segment9			IN	VARCHAR2
,  p_Segment10			IN	VARCHAR2
,  p_Segment11			IN	VARCHAR2
,  p_Segment12			IN	VARCHAR2
,  p_Segment13			IN	VARCHAR2
,  p_Segment14			IN	VARCHAR2
,  p_Segment15			IN	VARCHAR2
,  p_Segment16			IN	VARCHAR2
,  p_Segment17			IN	VARCHAR2
,  p_Segment18			IN	VARCHAR2
,  p_Segment19			IN	VARCHAR2
,  p_Segment20			IN	VARCHAR2
,  p_Object_Version_Number	IN	NUMBER
 -- Lifecycle
,  p_Lifecycle_Id	       	IN	NUMBER
,  p_Current_Phase_Id		IN	NUMBER
 -- Main attributes
,  p_Description	      	IN	VARCHAR2
,  p_Long_Description		IN	VARCHAR2
,  p_Primary_Uom_Code		IN	VARCHAR2
,  p_Inventory_Item_Status_Code	IN	VARCHAR2
 -- BoM/Eng
,  p_Bom_Enabled_Flag		IN	VARCHAR2
,  p_Eng_Item_Flag		IN	VARCHAR2
 -- Role Grant
,  p_Role_Id			IN	NUMBER
,  p_Role_Name			IN	VARCHAR2
,  p_Grantee_Party_Type		IN	VARCHAR2
,  p_Grantee_Party_Id		IN	NUMBER
,  p_Grantee_Party_Name		IN	VARCHAR2
,  p_Grant_Start_Date		IN	DATE
,  p_Grant_End_Date		IN	DATE
 -- Returned item id
,  x_Inventory_Item_Id		OUT NOCOPY	NUMBER
,  x_Organization_Id		OUT NOCOPY	NUMBER
 --
,  x_return_status		OUT NOCOPY	VARCHAR2
,  x_msg_count			OUT NOCOPY	NUMBER
);

-- -----------------------------------------------------------------------------
--  API Name:		Get_Item_Count
--
--  Type:
--
--  Description:
--                      Returns the Item Count for a particular organization and
--                      a catalog group
--
--  Version:		Current version 1.0
--  History:
--   04-MAR-2003        Aswin Sampathkumaran           Created
--
-- -----------------------------------------------------------------------------

FUNCTION Get_Item_Count (
p_catalog_group_id IN NUMBER,
p_organization_id IN NUMBER,
p_item_type       IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

FUNCTION Get_Category_Item_Count(
  P_CATEGORY_SET_ID IN NUMBER,
  p_CATEGORY_ID     IN NUMBER,
  P_ORGANIZATION_ID IN NUMBER,
  P_ITEM_TYPE       IN VARCHAR2 DEFAULT NULL
)
RETURN NUMBER;

FUNCTION Get_Category_Hierarchy_Names(
  P_CATEGORY_SET_ID IN NUMBER,
  P_CATEGORY_ID     IN NUMBER
)
RETURN VARCHAR2;


END EGO_UI_ITEM_PUB;

 

/

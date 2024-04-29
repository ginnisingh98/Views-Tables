--------------------------------------------------------
--  DDL for Package INVIDIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDIT1" AUTHID CURRENT_USER AS
/* $Header: INVIDI1S.pls 120.5 2008/01/09 20:24:52 mshirkol ship $ */


PROCEDURE Get_Startup_Info
(
   X_org_id                     IN   NUMBER
,  X_mode                       IN   VARCHAR2
,  X_master_org_id              OUT  NOCOPY NUMBER
,  X_master_org_name            OUT  NOCOPY VARCHAR2
,  X_master_org_code            OUT  NOCOPY VARCHAR2
,  X_master_chart_of_accounts   OUT  NOCOPY number
,  X_updateable_item            OUT  NOCOPY varchar2
,  X_default_status             OUT  NOCOPY varchar2
,  x_default_uom_b              OUT  NOCOPY VARCHAR2
,  x_default_uom                OUT  NOCOPY VARCHAR2
,  x_default_uom_code           OUT  NOCOPY VARCHAR2
,  x_default_uom_class          OUT  NOCOPY VARCHAR2
,  x_time_uom_class             OUT  NOCOPY VARCHAR2
,  x_default_lot_status_id      OUT  NOCOPY NUMBER
,  x_default_lot_status         OUT  NOCOPY VARCHAR2
,  x_default_serial_status_id   OUT  NOCOPY NUMBER
,  x_default_serial_status      OUT  NOCOPY VARCHAR2
,  x_Item_Category_Set_id       OUT  NOCOPY NUMBER
,  x_Item_Category_Structure_id OUT  NOCOPY NUMBER
,  x_Item_Category_Validate_Flag OUT NOCOPY VARCHAR2--Bug:3578024
,  x_Item_Category_Set_Ctrl_level OUT NOCOPY VARCHAR2--Bug:3723668
,  x_Default_Template_id        OUT  NOCOPY NUMBER
,  x_Default_Template_Name      OUT  NOCOPY VARCHAR2
,  X_icgd_option                OUT NOCOPY varchar2
,  X_allow_item_desc_update_flag OUT NOCOPY varchar2
,  X_rfq_required_flag          OUT NOCOPY varchar2
,  X_receiving_flag             OUT NOCOPY varchar2
,  X_taxable_flag               OUT NOCOPY varchar2
,  X_org_locator_control        OUT NOCOPY number
,  X_org_expense_account        OUT NOCOPY number
,  X_org_encumbrance_account    OUT NOCOPY number
,  X_org_cost_of_sales_account  OUT NOCOPY number
,  X_org_sales_account          OUT NOCOPY number
,  X_serial_generation          OUT NOCOPY number
,  X_lot_generation             OUT NOCOPY number
,  X_cost_method                OUT NOCOPY number
,  X_category_flex_structure    OUT NOCOPY number
,  X_bom_enabled_status         OUT NOCOPY number
,  X_purchasable_status         OUT NOCOPY number
,  X_transactable_status        OUT NOCOPY number
,  X_stockable_status           OUT NOCOPY number
,  X_wip_status                 OUT NOCOPY number
,  X_cust_ord_status            OUT NOCOPY number
,  X_int_ord_status             OUT NOCOPY number
,  X_invoiceable_status         OUT NOCOPY number
,  X_order_by_segments          OUT NOCOPY varchar2
,  X_product_family_templ_id    OUT NOCOPY number
,  X_encumbrance_reversal_flag  OUT NOCOPY NUMBER --* Added for Bug #3818342
/* Start Bug 3713912 */
,  X_recipe_enabled_status OUT NOCOPY number,
   X_process_exec_enabled_status OUT NOCOPY number
/* End Bug 3713912 */
/* Adding attributes for R12 */
,  X_tp_org                  OUT NOCOPY VARCHAR2
);


PROCEDURE Get_Installs(X_inv_install    OUT NOCOPY number,
                       X_po_install     OUT NOCOPY number,
                       X_ar_install     OUT NOCOPY number,
                       X_oe_install     OUT NOCOPY number,
                       X_bom_install    OUT NOCOPY number,
                       X_eng_install    OUT NOCOPY number,
                       X_cs_install     OUT NOCOPY number,
                       X_mrp_install    OUT NOCOPY number,
                       X_wip_install    OUT NOCOPY number,
                       X_fa_install     OUT NOCOPY number,
                       X_pjm_unit_eff_enabled   OUT NOCOPY VARCHAR2
                      );


PROCEDURE Populate_Fields
(
   X_org_id                     IN   NUMBER
,  X_item_id                    IN   NUMBER
,  X_buyer_id                   IN   NUMBER,
   X_hazard_class_id            IN   NUMBER,
   X_un_number_id               IN   NUMBER,
   X_picking_rule_id            IN   NUMBER,
   X_atp_rule_id                IN   NUMBER,
   X_payment_terms_id           IN   NUMBER,
   X_accounting_rule_id         IN   NUMBER,
   X_invoicing_rule_id          IN   NUMBER,
   X_default_shipping_org       IN   NUMBER,
   X_source_organization_id     IN   NUMBER,
   X_weight_uom_code            IN   VARCHAR2,
   X_volume_uom_code            IN   VARCHAR2,
   X_item_type                  IN   VARCHAR2,
   X_container_type             IN   VARCHAR2,
   X_conversion                 IN   NUMBER,
   X_buyer                      OUT NOCOPY varchar2,
   X_hazard_class               OUT NOCOPY varchar2,
   X_un_number                  OUT NOCOPY varchar2,
   X_un_description             OUT NOCOPY varchar2,
   X_picking_rule               OUT NOCOPY varchar2,
   X_atp_rule                   OUT NOCOPY varchar2,
   X_payment_terms              OUT NOCOPY varchar2,
   X_accounting_rule            OUT NOCOPY varchar2,
   X_invoicing_rule             OUT NOCOPY varchar2,
   X_default_shipping_org_dsp   OUT NOCOPY varchar2,
   X_source_organization        OUT NOCOPY varchar2,
   X_source_org_name            OUT NOCOPY varchar2,
   X_weight_uom                 OUT NOCOPY varchar2,
   X_volume_uom                 OUT NOCOPY varchar2,
   X_item_type_dsp              OUT NOCOPY varchar2,
   X_container_type_dsp         OUT NOCOPY varchar2,
   X_conversion_dsp             OUT NOCOPY varchar2,
   X_service_duration_per_code  IN   VARCHAR2
,  X_service_duration_period    OUT  NOCOPY VARCHAR2
,  X_coverage_schedule_id       IN   number
,  X_coverage_schedule          OUT  NOCOPY varchar2
,  p_primary_uom_code           IN   VARCHAR2
,  x_primary_uom                OUT  NOCOPY VARCHAR2
,  x_uom_class                  OUT  NOCOPY VARCHAR2
,  p_dimension_uom_code         IN   VARCHAR2
,  p_default_lot_status_id      IN   NUMBER
,  p_default_serial_status_id   IN   NUMBER
,  x_dimension_uom              OUT  NOCOPY VARCHAR2
,  x_default_lot_status         OUT  NOCOPY VARCHAR2
,  x_default_serial_status      OUT  NOCOPY VARCHAR2
,  p_eam_activity_type_code     IN   VARCHAR2
,  p_eam_activity_cause_code    IN   VARCHAR2
,  p_eam_act_shutdown_status    IN   VARCHAR2
,  x_eam_activity_type          OUT  NOCOPY VARCHAR2
,  x_eam_activity_cause         OUT  NOCOPY VARCHAR2
,  x_eam_act_shutdown_status_dsp OUT NOCOPY VARCHAR2
,  p_secondary_uom_code         IN   VARCHAR2
,  x_secondary_uom              OUT  NOCOPY VARCHAR2
--Jalaj Srivastava Bug 5017588
,  x_secondary_uom_class        OUT  NOCOPY VARCHAR2
,  p_Folder_Category_Set_id     IN   NUMBER
,  x_Folder_Item_Category_id    OUT  NOCOPY NUMBER
,  x_Folder_Item_Category       OUT  NOCOPY VARCHAR2
--Added as part of 11.5.9 ENH
,  p_eam_activity_source_code   IN   VARCHAR2
,  x_eam_activity_source        OUT  NOCOPY VARCHAR2
-- Item Transaction Defaults for 11.5.9
,  X_Default_Move_Order_Sub_Inv OUT  NOCOPY VARCHAR2
,  X_Default_Receiving_Sub_Inv  OUT  NOCOPY VARCHAR2
,  X_Default_Shipping_Sub_Inv   OUT  NOCOPY VARCHAR2
,  X_charge_periodicity_code    IN   VARCHAR2
,  X_charge_unit_of_measure     OUT  NOCOPY VARCHAR2
,  X_inv_item_status_code       IN VARCHAR2
,  X_inv_item_status_code_tl    OUT NOCOPY VARCHAR2
,  p_default_material_status_id      IN   NUMBER
,  x_default_material_status         OUT  NOCOPY VARCHAR2
);


FUNCTION Validate_Source_Org(X_org_id   number,
                             X_item_id     number,
                             X_new_item_id number,
                             X_source_org  number,
                             X_mrp_plan    number,
                             X_source_sub  varchar2
                            ) return number;


--2463543 :Below is used in Item Search Form. Exclusively Built for INVIVCSU

PROCEDURE Item_Search_Execute_Query
                       (p_grp_handle_id      IN NUMBER,
                        p_org_id             IN NUMBER   DEFAULT NULL,
                        p_item_mask          IN VARCHAR2 DEFAULT NULL,
			p_item_description   IN VARCHAR2 DEFAULT NULL,
			p_base_item_id       IN NUMBER   DEFAULT NULL,
			p_status             IN VARCHAR2 DEFAULT NULL,
			p_catalog_grp_id     IN NUMBER   DEFAULT NULL,
			p_catalog_complete   IN VARCHAR2 DEFAULT NULL,
			p_manufacturer_id    IN NUMBER   DEFAULT NULL,
			p_mfg_part_num       IN VARCHAR2 DEFAULT NULL,
			p_vendor_id          IN NUMBER   DEFAULT NULL,
			p_default_assignment IN VARCHAR2 DEFAULT NULL,
			p_vendor_product_num IN VARCHAR2 DEFAULT NULL,
			p_contract           IN VARCHAR2 DEFAULT NULL,
			p_blanket_agreement  IN VARCHAR2 DEFAULT NULL,
			p_xref_type          IN dbms_sql.Varchar2_Table,
			p_xref_val           IN dbms_sql.Varchar2_Table,
			p_relationship_type  IN dbms_sql.Number_Table,
			p_related_item       IN dbms_sql.Number_Table,
			p_category_set       IN dbms_sql.Number_Table,
			p_category_id        IN dbms_sql.Number_Table,
			p_element_name       IN dbms_sql.Varchar2_Table,
			p_element_val        IN dbms_sql.Varchar2_Table);

END INVIDIT1;

/

--------------------------------------------------------
--  DDL for Package OE_MASS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MASS_CHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVMSCS.pls 120.4.12010000.4 2008/11/15 10:57:41 sgoli ship $ */
--  Start of Comments
--  API name    Process_Order
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_MASS_CHANGE_PVT';
COMMIT_EXIT_ON_ERROR        NUMBER := 1;
ROLLBACK_EXIT_ON_ERROR      NUMBER := 2;
COMMIT_SHOW_ERROR           NUMBER := 3;
ASK_COMMIT                  NUMBER := 4;
IS_MASS_CHANGE          VARCHAR2(1) := 'F';

EXIT_FIRST_ERROR      CONSTANT   NUMBER := 5;
SKIP_ALL              CONSTANT   NUMBER := 7;
SKIP_CONTINUE         CONSTANT   NUMBER := 8;

G_COUNTER        	Integer := 0;    /* Number of records Processed */

G_ERROR_COUNT        	Integer := 0;    /* Number of records with Errors */

--Bug 7566697
--This flag will be used for Mass Change.
--If in a pricing call, error occuress, then whole order would be rolled back using this flag
G_PRICING_ERROR       VARCHAR2(1) := 'N';

-- 4020312
TYPE Sel_Rec_Tbl IS TABLE OF OE_GLOBALS.Selected_Record_Type;

Procedure Process_Order_Scalar(
    p_num_of_records                IN NUMBER
,   p_sel_rec_tbl                   IN Oe_Globals.Selected_Record_Tbl
,   p_multi_OU                      IN Boolean
--,   p_record_ids            		 IN VARCHAR2
,   p_change_reason                 IN VARCHAR2
,   p_change_comments               IN VARCHAR2
, p_msg_count OUT NOCOPY NUMBER
, p_msg_data OUT NOCOPY VARCHAR2
, p_return_status OUT NOCOPY VARCHAR2
,   p_mc_err_handling_flag  		 IN NUMBER DEFAULT  FND_API.G_MISS_NUM
, p_error_count OUT NOCOPY NUMBER
,   p_accounting_rule_id            IN NUMBER
,   p_accounting_rule_duration      IN NUMBER
,   p_agreement_id                  IN NUMBER
,   p_attribute1                    IN VARCHAR2
,   p_attribute10                   IN VARCHAR2
,   p_attribute11                   IN VARCHAR2
,   p_attribute12                   IN VARCHAR2
,   p_attribute13                   IN VARCHAR2
,   p_attribute14                   IN VARCHAR2
,   p_attribute15                   IN VARCHAR2
,   p_attribute16                   IN VARCHAR2   --For bug 2184255
,   p_attribute17                   IN VARCHAR2
,   p_attribute18                   IN VARCHAR2
,   p_attribute19                   IN VARCHAR2
,   p_attribute2                    IN VARCHAR2
,   p_attribute20                   IN VARCHAR2
,   p_attribute3                    IN VARCHAR2
,   p_attribute4                    IN VARCHAR2
,   p_attribute5                    IN VARCHAR2
,   p_attribute6                    IN VARCHAR2
,   p_attribute7                    IN VARCHAR2
,   p_attribute8                    IN VARCHAR2
,   p_attribute9                    IN VARCHAR2
,   p_blanket_number                IN NUMBER
,   p_context                       IN VARCHAR2
,   p_conversion_rate               IN NUMBER
,   p_conversion_rate_date          IN DATE
,   p_conversion_type_code          IN VARCHAR2
,   p_cust_po_number                IN VARCHAR2
,   p_deliver_to_contact_id         IN NUMBER
,   p_deliver_to_org_id             IN NUMBER
,   p_demand_class_code             IN VARCHAR2
,   p_expiration_date               IN DATE
,   p_earliest_schedule_limit       IN NUMBER
,   p_fob_point_code                IN VARCHAR2
,   p_freight_carrier_code          IN VARCHAR2
,   p_freight_terms_code            IN VARCHAR2
,   p_global_attribute1             IN VARCHAR2
,   p_global_attribute10            IN VARCHAR2
,   p_global_attribute11            IN VARCHAR2
,   p_global_attribute12            IN VARCHAR2
,   p_global_attribute13            IN VARCHAR2
,   p_global_attribute14            IN VARCHAR2
,   p_global_attribute15            IN VARCHAR2
,   p_global_attribute16            IN VARCHAR2
,   p_global_attribute17            IN VARCHAR2
,   p_global_attribute18            IN VARCHAR2
,   p_global_attribute19            IN VARCHAR2
,   p_global_attribute2             IN VARCHAR2
,   p_global_attribute20            IN VARCHAR2
,   p_global_attribute3             IN VARCHAR2
,   p_global_attribute4             IN VARCHAR2
,   p_global_attribute5             IN VARCHAR2
,   p_global_attribute6             IN VARCHAR2
,   p_global_attribute7             IN VARCHAR2
,   p_global_attribute8             IN VARCHAR2
,   p_global_attribute9             IN VARCHAR2
,   p_global_attribute_category     IN VARCHAR2
,   p_header_id                     IN NUMBER
,   p_invoice_to_contact_id         IN NUMBER
,   p_invoice_to_org_id             IN NUMBER
,   p_invoicing_rule_id             IN NUMBER
,   p_latest_schedule_limit         IN NUMBER
,   p_ordered_date                  IN DATE
,   p_order_date_type_code          IN VARCHAR2
,   p_order_number                  IN NUMBER
,   p_order_source_id               IN NUMBER
,   p_order_type_id                 IN NUMBER
,   p_org_id                        IN NUMBER
,   p_orig_sys_document_ref         IN VARCHAR2
,   p_partial_shipments_allowed     IN VARCHAR2
,   p_payment_term_id               IN NUMBER
,   p_price_list_id                 IN NUMBER
,   p_pricing_date                  IN DATE
,   p_request_date                  IN DATE
,   p_shipment_priority_code        IN VARCHAR2
,   p_shipping_method_code          IN VARCHAR2
,   p_ship_from_org_id              IN NUMBER
,   p_ship_tolerance_above          IN NUMBER
,   p_ship_tolerance_below          IN NUMBER
,   p_ship_to_contact_id            IN NUMBER
,   p_ship_to_org_id                IN NUMBER
,   p_sold_to_contact_id            IN NUMBER
,   p_sold_to_org_id                IN NUMBER
,   p_source_document_id            IN NUMBER
,   p_source_document_type_id       IN NUMBER
,   p_tax_exempt_flag               IN VARCHAR2
,   p_tax_exempt_number             IN VARCHAR2
,   p_tax_exempt_reason_code        IN VARCHAR2
,   p_tax_point_code                IN VARCHAR2
,   p_transactional_curr_code       IN VARCHAR2
,   p_version_number                IN NUMBER
,   p_accounting_rule               IN VARCHAR2
,   p_agreement                     IN VARCHAR2
,   p_conversion_type               IN VARCHAR2
,   p_deliver_to_address1           IN VARCHAR2
,   p_deliver_to_address2           IN VARCHAR2
,   p_deliver_to_address3           IN VARCHAR2
,   p_deliver_to_address4           IN VARCHAR2
,   p_deliver_to_contact            IN VARCHAR2
,   p_deliver_to_location           IN VARCHAR2
,   p_deliver_to_org                IN VARCHAR2
,   p_fob_point                     IN VARCHAR2
,   p_freight_terms                 IN VARCHAR2
,   p_invoice_to_address1           IN VARCHAR2
,   p_invoice_to_address2           IN VARCHAR2
,   p_invoice_to_address3           IN VARCHAR2
,   p_invoice_to_address4           IN VARCHAR2
,   p_invoice_to_contact            IN VARCHAR2
,   p_invoice_to_location           IN VARCHAR2
,   p_invoice_to_org                IN VARCHAR2
,   p_invoicing_rule                IN VARCHAR2
,   p_order_source                  IN VARCHAR2
,   p_order_type                    IN VARCHAR2
,   p_payment_term                  IN VARCHAR2
,   p_price_list                    IN VARCHAR2
,   p_shipment_priority             IN VARCHAR2
,   p_ship_from_address1            IN VARCHAR2
,   p_ship_from_address2            IN VARCHAR2
,   p_ship_from_address3            IN VARCHAR2
,   p_ship_from_address4            IN VARCHAR2
,   p_ship_from_location            IN VARCHAR2
,   p_ship_from_org                 IN VARCHAR2
,   p_ship_to_address1              IN VARCHAR2
,   p_ship_to_address2              IN VARCHAR2
,   p_ship_to_address3              IN VARCHAR2
,   p_ship_to_address4              IN VARCHAR2
,   p_ship_to_contact               IN VARCHAR2
,   p_ship_to_location              IN VARCHAR2
,   p_ship_to_org                   IN VARCHAR2
,   p_sold_to_contact               IN VARCHAR2
,   p_sold_to_org                   IN VARCHAR2
,   p_tax_exempt                    IN VARCHAR2
,   p_tax_exempt_reason             IN VARCHAR2
,   p_tax_point                     IN VARCHAR2
,   p_salesrep_id                   IN NUMBER
,   p_return_reason_code            IN VARCHAR2
,   p_salesrep                      IN VARCHAR2
,   p_return_reason                 IN VARCHAR2
,   p_payment_type_code             IN VARCHAR2
,   p_payment_amount                IN NUMBER
,   p_check_number                  IN VARCHAR2
,   p_credit_card_code              IN VARCHAR2
,   p_credit_card_holder_name       IN VARCHAR2
,   p_credit_card_number            IN VARCHAR2
,   p_instrument_Security_code      IN VARCHAR2  --bug 5191301
,   p_credit_card_expiration_date   IN DATE
,   p_credit_card_approval_date     IN DATE
,   p_credit_card_approval_code     IN VARCHAR2
,   p_payment_type                  IN VARCHAR2
,   p_credit_card                   IN VARCHAR2
,   p_first_ack_code                IN VARCHAR2
,   p_first_ack_date                IN DATE
,   p_last_ack_code                 IN VARCHAR2
,   p_last_ack_date                 IN DATE
,   p_tp_attribute1                    IN VARCHAR2
,   p_tp_attribute10                   IN VARCHAR2
,   p_tp_attribute11                   IN VARCHAR2
,   p_tp_attribute12                   IN VARCHAR2
,   p_tp_attribute13                   IN VARCHAR2
,   p_tp_attribute14                   IN VARCHAR2
,   p_tp_attribute15                   IN VARCHAR2
,   p_tp_attribute2                    IN VARCHAR2
,   p_tp_attribute3                    IN VARCHAR2
,   p_tp_attribute4                    IN VARCHAR2
,   p_tp_attribute5                    IN VARCHAR2
,   p_tp_attribute6                    IN VARCHAR2
,   p_tp_attribute7                    IN VARCHAR2
,   p_tp_attribute8                    IN VARCHAR2
,   p_tp_attribute9                    IN VARCHAR2
,   p_tp_context                       IN VARCHAR2
,   p_shipping_instructions            IN VARCHAR2
,   p_packing_instructions             IN VARCHAR2
,   p_sales_channel_code               IN VARCHAR2
--My Addition
,   p_sold_to_address1                 IN VARCHAR2
,   p_sold_to_address2                 IN VARCHAR2
,   p_sold_to_address3                 IN VARCHAR2
,   p_sold_to_address4                 IN VARCHAR2
,   p_sold_to_location                 IN VARCHAR2
,   p_sold_to_site_use_id              IN NUMBER
-- end customer changes
,   p_end_customer_contact_id          IN NUMBER
,   p_end_customer_id                  IN NUMBER
,   p_end_customer_site_use_id         IN NUMBER
,   p_end_customer_address1            IN VARCHAR2
,   p_end_customer_address2            IN VARCHAR2
,   p_end_customer_address3            IN VARCHAR2
,   p_end_customer_address4            IN VARCHAR2
,   p_end_customer_contact             IN VARCHAR2
,   p_end_customer_location            IN VARCHAR2
,   p_ib_owner                         IN VARCHAR2
,   p_ib_installed_at_location         IN VARCHAR2
,   p_ib_current_location              IN VARCHAR2
,   p_cascade_header_changes              IN VARCHAR2 DEFAULT 'N'
);
-- bug4529937
Function Lines_Remaining return Varchar2;

Procedure Process_Line_Scalar(
    p_num_of_records         		 IN NUMBER
,   p_sel_rec_tbl                        IN Oe_Globals.Selected_Record_Tbl --MOAC PI
,   p_multi_OU                           IN Boolean --MOAC PI
--,   p_record_ids             		 IN VARCHAR2 --MOAC PI
,   p_change_reason          		 IN VARCHAR2
,   p_change_comments        		 IN VARCHAR2
, p_msg_count OUT NOCOPY NUMBER
, p_msg_data OUT NOCOPY VARCHAR2
, p_return_status OUT NOCOPY VARCHAR2
,   p_mc_err_handling_flag 		 IN NUMBER DEFAULT  FND_API.G_MISS_NUM
, p_error_count OUT NOCOPY NUMBER
,   p_header_id                     IN  NUMBER
,   p_accounting_rule_id            IN NUMBER
,   p_accounting_rule_duration      IN NUMBER
,   p_actual_arrival_date           IN DATE
,   p_actual_shipment_date          IN DATE
,   p_agreement_id                  IN NUMBER
,   p_ato_line_id                   IN NUMBER
,   p_attribute1                    IN VARCHAR2
,   p_attribute10                   IN VARCHAR2
,   p_attribute11                   IN VARCHAR2
,   p_attribute12                   IN VARCHAR2
,   p_attribute13                   IN VARCHAR2
,   p_attribute14                   IN VARCHAR2
,   p_attribute15                   IN VARCHAR2
,   p_attribute16                   IN VARCHAR2   --For bug 2184255
,   p_attribute17                   IN VARCHAR2
,   p_attribute18                   IN VARCHAR2
,   p_attribute19                   IN VARCHAR2
,   p_attribute2                    IN VARCHAR2
,   p_attribute20                   IN VARCHAR2
,   p_attribute3                    IN VARCHAR2
,   p_attribute4                    IN VARCHAR2
,   p_attribute5                    IN VARCHAR2
,   p_attribute6                    IN VARCHAR2
,   p_attribute7                    IN VARCHAR2
,   p_attribute8                    IN VARCHAR2
,   p_attribute9                    IN VARCHAR2
,   p_blanket_number                IN NUMBER
,   p_blanket_line_number           IN NUMBER
,   p_blanket_version_number        IN NUMBER
,   p_context                       IN VARCHAR2
,   p_auto_selected_quantity        IN NUMBER
,   p_cancelled_quantity            In NUMBER
,   p_component_code                IN VARCHAR2
,   p_component_number              IN NUMBER
,   p_component_sequence_id         IN NUMBER
,   p_config_display_sequence       IN NUMBER
,   p_configuration_id              IN NUMBER
,   p_config_header_id              IN NUMBER
,   p_config_rev_nbr                IN NUMBER
,   p_credit_invoice_line_id        IN NUMBER
,   p_customer_dock_code            IN VARCHAR2
,   p_customer_job                  IN VARCHAR2
,   p_customer_production_line      IN VARCHAR2
,   p_customer_trx_line_id          IN NUMBER
,   p_cust_model_serial_number      IN VARCHAR2
,   p_cust_po_number                IN VARCHAR2
,   p_delivery_lead_time            IN NUMBER
,   p_deliver_to_contact_id         IN NUMBER
,   p_deliver_to_org_id             IN NUMBER
,   p_demand_bucket_type_code       IN VARCHAR2
,   p_demand_class_code             IN VARCHAR2
,   p_dep_plan_required_flag        IN VARCHAR2
,   p_earliest_acceptable_date      IN DATE
,   p_explosion_date                IN DATE
,   p_fob_point_code                IN VARCHAR2
,   p_freight_carrier_code          IN VARCHAR2
,   p_freight_terms_code            IN VARCHAR2
,   p_fulfilled_quantity            IN NUMBER
,   p_global_attribute1             IN VARCHAR2
,   p_global_attribute10            IN VARCHAR2
,   p_global_attribute11            IN VARCHAR2
,   p_global_attribute12            IN VARCHAR2
,   p_global_attribute13            IN VARCHAR2
,   p_global_attribute14            IN VARCHAR2
,   p_global_attribute15            IN VARCHAR2
,   p_global_attribute16            IN VARCHAR2
,   p_global_attribute17            IN VARCHAR2
,   p_global_attribute18            IN VARCHAR2
,   p_global_attribute19            IN VARCHAR2
,   p_global_attribute2             IN VARCHAR2
,   p_global_attribute20            IN VARCHAR2
,   p_global_attribute3             IN VARCHAR2
,   p_global_attribute4             IN VARCHAR2
,   p_global_attribute5             IN VARCHAR2
,   p_global_attribute6             IN VARCHAR2
,   p_global_attribute7             IN VARCHAR2
,   p_global_attribute8             IN VARCHAR2
,   p_global_attribute9             IN VARCHAR2
,   p_global_attribute_category     IN VARCHAR2
,   p_industry_attribute1           IN VARCHAR2
,   p_industry_attribute10          IN VARCHAR2
,   p_industry_attribute11          IN VARCHAR2
,   p_industry_attribute12          IN VARCHAR2
,   p_industry_attribute13          IN VARCHAR2
,   p_industry_attribute14          IN VARCHAR2
,   p_industry_attribute15          IN VARCHAR2
,   p_industry_attribute2           IN VARCHAR2
,   p_industry_attribute3           IN VARCHAR2
,   p_industry_attribute4           IN VARCHAR2
,   p_industry_attribute5           IN VARCHAR2
,   p_industry_attribute6           IN VARCHAR2
,   p_industry_attribute7           IN VARCHAR2
,   p_industry_attribute8           IN VARCHAR2
,   p_industry_attribute9           IN VARCHAR2
,   p_industry_context              IN VARCHAR2
,   p_intermed_ship_to_contact_id   IN NUMBER
,   p_intermed_ship_to_org_id       IN NUMBER
,   p_inventory_item_id             IN NUMBER
,   p_invoice_interface_status      IN VARCHAR2
,   p_invoice_to_contact_id         IN NUMBER
,   p_invoice_to_org_id             IN NUMBER
,   p_invoicing_rule_id             IN NUMBER
,   p_ordered_item_id               IN NUMBER
,   p_item_identifier_type          IN VARCHAR2
,   p_ordered_item                  IN VARCHAR2
,   p_item_revision                 IN VARCHAR2
,   p_item_type_code                IN VARCHAR2
,   p_latest_acceptable_date        IN DATE
,   p_line_category_code            IN VARCHAR2
,   p_line_id                       IN NUMBER
,   p_line_number                   IN NUMBER
,   p_line_type_id                  IN NUMBER
,   p_link_to_line_id               IN NUMBER
,   p_model_group_number            IN NUMBER
,   p_option_flag                   IN VARCHAR2
,   p_option_number                 IN NUMBER
,   p_ordered_quantity              IN NUMBER
,   p_order_quantity_uom            IN VARCHAR2
,   p_org_id                        IN NUMBER
,   p_orig_sys_document_ref         IN VARCHAR2
,   p_orig_sys_line_ref             IN VARCHAR2
,   p_payment_term_id               IN NUMBER
,   p_price_list_id                 IN NUMBER
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_pricing_date                  IN DATE
,   p_pricing_quantity              IN NUMBER
,   p_pricing_quantity_uom          IN VARCHAR2
,   p_project_id                    IN NUMBER
,   p_promise_date                  IN DATE
,   p_reference_header_id           IN NUMBER
,   p_reference_line_id             IN NUMBER
,   p_reference_type                IN VARCHAR2
,   p_request_date                  IN DATE
,   p_reserved_quantity             IN NUMBER
,   p_return_attribute1             IN VARCHAR2
,   p_return_attribute10            IN VARCHAR2
,   p_return_attribute11            IN VARCHAR2
,   p_return_attribute12            IN VARCHAR2
,   p_return_attribute13            IN VARCHAR2
,   p_return_attribute14            IN VARCHAR2
,   p_return_attribute15            IN VARCHAR2
,   p_return_attribute2             IN VARCHAR2
,   p_return_attribute3             IN VARCHAR2
,   p_return_attribute4             IN VARCHAR2
,   p_return_attribute5             IN VARCHAR2
,   p_return_attribute6             IN VARCHAR2
,   p_return_attribute7             IN VARCHAR2
,   p_return_attribute8             IN VARCHAR2
,   p_return_attribute9             IN VARCHAR2
,   p_return_context                IN VARCHAR2
,   p_rla_schedule_type_code        IN VARCHAR2
,   p_schedule_arrival_date         IN DATE
,   p_schedule_ship_date            IN DATE
,   p_schedule_action_code          IN VARCHAR2
,   p_schedule_status_code          IN VARCHAR2
,   p_shipment_number               IN NUMBER
,   p_shipment_priority_code        IN VARCHAR2
,   p_shipped_quantity              IN NUMBER
,   p_shipping_method_code          IN VARCHAR2
,   p_shipping_quantity             IN NUMBER
,   p_shipping_quantity_uom         IN VARCHAR2
,   p_ship_from_org_id              IN NUMBER
,   p_ship_tolerance_above          IN NUMBER
,   p_ship_tolerance_below          IN NUMBER
,   p_shipping_interfaced_flag      IN VARCHAR2
,   p_ship_to_contact_id            IN NUMBER
,   p_ship_to_org_id                IN NUMBER
,   p_ship_model_complete_flag      IN VARCHAR2
,   p_sold_to_org_id                IN NUMBER
,   p_sort_order                    IN VARCHAR2
,   p_source_document_id            IN NUMBER
,   p_source_document_line_id       IN NUMBER
,   p_source_document_type_id       IN NUMBER
,   p_source_type_code              IN VARCHAR2
,   p_task_id                       IN NUMBER
,   p_tax_code                      IN VARCHAR2
,   p_tax_date                      IN DATE
,   p_tax_exempt_flag               IN VARCHAR2
,   p_tax_exempt_number             IN VARCHAR2
,   p_tax_exempt_reason_code        IN VARCHAR2
,   p_tax_point_code                IN VARCHAR2
,   p_tax_rate                      IN NUMBER
,   p_tax_value                     IN NUMBER
,   p_top_model_line_id             IN NUMBER
,   p_unit_list_price               IN NUMBER
,   p_unit_selling_price            IN NUMBER
,   p_visible_demand_flag           IN VARCHAR2
,   p_accounting_rule               IN VARCHAR2
,   p_agreement                     IN VARCHAR2
,   p_customer_item                 IN VARCHAR2
,   p_deliver_to_address1           IN VARCHAR2
,   p_deliver_to_address2           IN VARCHAR2
,   p_deliver_to_address3           IN VARCHAR2
,   p_deliver_to_address4           IN VARCHAR2
,   p_deliver_to_contact            IN VARCHAR2
,   p_deliver_to_location           IN VARCHAR2
,   p_deliver_to_org                IN VARCHAR2
,   p_demand_bucket_type            IN VARCHAR2
,   p_fob_point                     IN VARCHAR2
,   p_freight_terms                 IN VARCHAR2
,   p_inventory_item                IN VARCHAR2
,   p_invoice_to_address1           IN VARCHAR2
,   p_invoice_to_address2           IN VARCHAR2
,   p_invoice_to_address3           IN VARCHAR2
,   p_invoice_to_address4           IN VARCHAR2
,   p_invoice_to_contact            IN VARCHAR2
,   p_invoice_to_location           IN VARCHAR2
,   p_invoice_to_org                IN VARCHAR2
,   p_invoicing_rule                IN VARCHAR2
,   p_intermed_ship_to_address1     IN VARCHAR2
,   p_intermed_ship_to_address2     IN VARCHAR2
,   p_intermed_ship_to_address3     IN VARCHAR2
,   p_intermed_ship_to_address4     IN VARCHAR2
,   p_intermed_ship_to_contact      IN VARCHAR2
,   p_intermed_ship_to_location     IN VARCHAR2
,   p_intermed_ship_to_org          IN VARCHAR2
,   p_item                          IN VARCHAR2
,   p_item_type                     IN VARCHAR2
,   p_line_type                     IN VARCHAR2
,   p_payment_term                  IN VARCHAR2
,   p_price_list                    IN VARCHAR2
,   p_project                       IN VARCHAR2
,   p_rla_schedule_type             IN VARCHAR2
,   p_shipment_priority             IN VARCHAR2
,   p_ship_from_address1            IN VARCHAR2
,   p_ship_from_address2            IN VARCHAR2
,   p_ship_from_address3            IN VARCHAR2
,   p_ship_from_address4            IN VARCHAR2
,   p_ship_from_location            IN VARCHAR2
,   p_ship_from_org                 IN VARCHAR2
,   p_ship_to_address1              IN VARCHAR2
,   p_ship_to_address2              IN VARCHAR2
,   p_ship_to_address3              IN VARCHAR2
,   p_ship_to_address4              IN VARCHAR2
,   p_ship_to_contact               IN VARCHAR2
,   p_ship_to_location              IN VARCHAR2
,   p_ship_to_org                   IN VARCHAR2
,   p_sold_to_org                   IN VARCHAR2
,   p_task                          IN VARCHAR2
,   p_tax_exempt                    IN VARCHAR2
,   p_tax_exempt_reason             IN VARCHAR2
,   p_tax_point                     IN VARCHAR2
,   p_split_from_line_id            IN NUMBER
,   p_cust_production_seq_num       IN VARCHAR2
,   p_authorized_to_ship_flag       IN VARCHAR2
,   p_veh_cus_item_cum_key_id       IN NUMBER
,   p_salesrep_id                   IN NUMBER
,   p_return_reason_code            IN VARCHAR2
,   p_arrival_set_id                IN NUMBER
,   p_ship_set_id                   IN NUMBER
,   p_over_ship_reason_code         IN VARCHAR2
,   p_over_ship_resolved_flag       IN VARCHAR2
,   p_industry_attribute16          IN VARCHAR2
,   p_industry_attribute17          IN VARCHAR2
,   p_industry_attribute18          IN VARCHAR2
,   p_industry_attribute19          IN VARCHAR2
,   p_industry_attribute20          IN VARCHAR2
,   p_industry_attribute21          IN VARCHAR2
,   p_industry_attribute22          IN VARCHAR2
,   p_industry_attribute23          IN VARCHAR2
,   p_industry_attribute24          IN VARCHAR2
,   p_industry_attribute25          IN VARCHAR2
,   p_industry_attribute26          IN VARCHAR2
,   p_industry_attribute27          IN VARCHAR2
,   p_industry_attribute28          IN VARCHAR2
,   p_industry_attribute29          IN VARCHAR2
,   p_industry_attribute30          IN VARCHAR2
,   p_veh_cus_item_cum_key          IN VARCHAR2
,   p_salesrep                      IN VARCHAR2
,   p_return_reason                 IN VARCHAR2
,   p_delivery                      IN VARCHAR2
,   p_arrival_set                   IN VARCHAR2
,   p_ship_set                      IN VARCHAR2
,   p_over_ship_reason              IN VARCHAR2
,   p_first_ack_code                IN VARCHAR2
,   p_first_ack_date                IN DATE
,   p_last_ack_code                 IN VARCHAR2
,   p_last_ack_date                 IN DATE
,   p_service_txn_reason_code       IN VARCHAR2
,   p_service_txn_comments          IN VARCHAR2
,   p_unit_selling_percent          IN NUMBER
,   p_unit_list_percent             IN NUMBER
,   p_unit_percent_base_price       IN NUMBER
,   p_service_duration              IN NUMBER
,   p_service_period                IN VARCHAR2
,   p_service_start_date            IN DATE
,   p_service_end_date              IN DATE
,   p_service_coterminate_flag      IN VARCHAR2
,   p_service_number                IN NUMBER
,   p_service_reference_type_code   IN VARCHAR2
,   p_service_reference_line_id     IN NUMBER
,   p_service_reference_system_id   IN NUMBER
,   p_tp_attribute1                    IN VARCHAR2
,   p_tp_attribute10                   IN VARCHAR2
,   p_tp_attribute11                   IN VARCHAR2
,   p_tp_attribute12                   IN VARCHAR2
,   p_tp_attribute13                   IN VARCHAR2
,   p_tp_attribute14                   IN VARCHAR2
,   p_tp_attribute15                   IN VARCHAR2
,   p_tp_attribute2                    IN VARCHAR2
,   p_tp_attribute3                    IN VARCHAR2
,   p_tp_attribute4                    IN VARCHAR2
,   p_tp_attribute5                    IN VARCHAR2
,   p_tp_attribute6                    IN VARCHAR2
,   p_tp_attribute7                    IN VARCHAR2
,   p_tp_attribute8                    IN VARCHAR2
,   p_tp_attribute9                    IN VARCHAR2
,   p_tp_context                       IN VARCHAR2
,   p_shipping_instructions            IN VARCHAR2
,   p_packing_instructions            IN VARCHAR2
,   p_planning_priority            IN VARCHAR2
,   p_calculate_price_flag            IN VARCHAR2
--end custoemr chagnes
,   p_end_customer_contact_id          IN NUMBER
,   p_end_customer_id                  IN NUMBER
,   p_end_customer_site_use_id         IN NUMBER
,   p_end_customer_address1            IN VARCHAR2
,   p_end_customer_address2            IN VARCHAR2
,   p_end_customer_address3            IN VARCHAR2
,   p_end_customer_address4            IN VARCHAR2
,   p_end_customer_contact             IN VARCHAR2
,   p_end_customer_location            IN VARCHAR2
,   p_ib_owner                         IN VARCHAR2
,   p_ib_installed_at_location         IN VARCHAR2
,   p_ib_current_location              IN VARCHAR2
,   p_block_name                       IN VARCHAR2 DEFAULT NULL -- bug4529937
);

Procedure save_messages;

Procedure insert_message (
         p_msg_index         IN NUMBER );


Procedure MC_Rollback;

Procedure Set_Counter;

Function Get_Counter return NUMBER;

Procedure Set_Error_Count;

Function Get_Error_Count return NUMBER;

-- 4020312
FUNCTION get_sel_rec_tbl RETURN Sel_Rec_Tbl PIPELINED;

END OE_MASS_CHANGE_PVT;

/

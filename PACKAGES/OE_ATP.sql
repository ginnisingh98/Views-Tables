--------------------------------------------------------
--  DDL for Package OE_ATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ATP" AUTHID CURRENT_USER AS
/* $Header: OEXVATPS.pls 120.2.12010000.2 2012/02/06 22:49:19 gabhatia ship $ */

--  Global constant holding the package name

TYPE Atp_Rec_Type IS RECORD
( org_id                        NUMBER  --4772886
, line_id                       NUMBER
, header_id                     NUMBER
, line_number                   NUMBER
, shipment_number               NUMBER
, option_number                 NUMBER
, component_Number              NUMBER
, item_input                    VARCHAR2(2000)
, inventory_item_id             NUMBER
, ordered_quantity              NUMBER
, order_quantity_uom            VARCHAR2(3)
, request_date                  DATE
, ship_from_org_id              NUMBER
, subinventory_code             VARCHAR2(10)    --11777419
, qty_on_request_date           NUMBER
, ordered_qty_Available_Date    DATE
, qty_on_available_date         NUMBER
, schedule_ship_date            DATE
, freight_carrier_code          NUMBER
, shipping_method_code          VARCHAR2(30)
, on_hand_qty                   NUMBER
, available_to_reserve          NUMBER
, error_message                 VARCHAR2(80)
-- Group Attributes
, ship_set                      VARCHAR2(30)
, arrival_set                   VARCHAR2(30)
, ship_model_complete_flag      VARCHAR2(30)
, ato_set                       VARCHAR2(30)
, group_available_date          DATE
-- Item Substitution
, request_item_id               NUMBER
, request_item_name             VARCHAR2(2000)
, req_item_req_date_qty         NUMBER
, req_item_available_date       DATE
, req_item_available_date_qty   NUMBER
, sub_on_hand_qty               NUMBER
, sub_available_to_reserve      NUMBER
, substitute_flag               VARCHAR2(1)
, Substitute_item_name          VARCHAR2(2000)
, Ordered_item_name             VARCHAR2(2000)
);

TYPE Atp_Tbl_Type IS table of Atp_Rec_Type
     INDEX BY BINARY_INTEGER;

/*
TYPE Sch_Line_Rec_Type IS RECORD
( line_id                       NUMBER
, inventory_item_id             NUMBER
, item_type_code                VARCHAR2(30)
, ordered_quantiTY              NUMBER
, order_quantity_uom            VARCHAR2(3)
, request_date                  DATE
, ship_from_org_id              NUMBER
, qty_on_request_date           NUMBER
, ordered_qty_Available_Date    DATE
, schedule_ship_date            DATE
, freight_carrier_code          NUMBER
, shipping_method_code          VARCHAR2(30)
);
*/

TYPE Sch_Tbl_Type IS table of Atp_Rec_Type
 INDEX BY BINARY_INTEGER;


TYPE Line_Atp_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER
,   actual_arrival_date           DATE
,   actual_shipment_date          DATE
,   agreement_id                  NUMBER
,   arrival_set_id                NUMBER
,   ato_line_id                   NUMBER
,   attribute1                    VARCHAR2(240)
,   attribute10                   VARCHAR2(240)
,   attribute11                   VARCHAR2(240)
,   attribute12                   VARCHAR2(240)
,   attribute13                   VARCHAR2(240)
,   attribute14                   VARCHAR2(240)
,   attribute15                   VARCHAR2(240)
,   attribute2                    VARCHAR2(240)
,   attribute3                    VARCHAR2(240)
,   attribute4                    VARCHAR2(240)
,   attribute5                    VARCHAR2(240)
,   attribute6                    VARCHAR2(240)
,   attribute7                    VARCHAR2(240)
,   attribute8                    VARCHAR2(240)
,   attribute9                    VARCHAR2(240)
,   authorized_to_ship_flag	    VARCHAR2(1)
,   auto_selected_quantity        NUMBER
,   Booked_flag                   VARCHAR2(1)
,   cancelled_flag		         VARCHAR2(1)
,   cancelled_quantity            NUMBER
,   component_code                VARCHAR2(1000)
,   component_number              NUMBER
,   component_sequence_id         NUMBER
,   config_display_sequence       NUMBER
,   top_model_line_id             NUMBER
,   top_model_line_index          NUMBER
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   customer_dock_code            VARCHAR2(50)
,   customer_item_id              NUMBER
,   customer_item_revision        VARCHAR2(50)
,   customer_job                  VARCHAR2(50)
,   customer_production_line      VARCHAR2(50)
,   customer_trx_line_id          NUMBER
,   cust_model_serial_number      VARCHAR2(50)
,   cust_po_number                VARCHAR2(50)
,   cust_production_seq_num	    VARCHAR2(50)
,   delivery_lead_time            NUMBER
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   demand_bucket_type_code       VARCHAR2(30)
,   demand_class_code             VARCHAR2(30)
,   dep_plan_required_flag        VARCHAR2(1)
,   earliest_acceptable_date      DATE
,   explosion_date                DATE
,   fob_point_code                VARCHAR2(30)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
,   fulfilled_quantity            NUMBER
,   global_attribute1             VARCHAR2(240)
,   global_attribute10            VARCHAR2(240)
,   global_attribute11            VARCHAR2(240)
,   global_attribute12            VARCHAR2(240)
,   global_attribute13            VARCHAR2(240)
,   global_attribute14            VARCHAR2(240)
,   global_attribute15            VARCHAR2(240)
,   global_attribute16            VARCHAR2(240)
,   global_attribute17            VARCHAR2(240)
,   global_attribute18            VARCHAR2(240)
,   global_attribute19            VARCHAR2(240)
,   global_attribute2             VARCHAR2(240)
,   global_attribute20            VARCHAR2(240)
,   global_attribute3             VARCHAR2(240)
,   global_attribute4             VARCHAR2(240)
,   global_attribute5             VARCHAR2(240)
,   global_attribute6             VARCHAR2(240)
,   global_attribute7             VARCHAR2(240)
,   global_attribute8             VARCHAR2(240)
,   global_attribute9             VARCHAR2(240)
,   global_attribute_category     VARCHAR2(30)
,   header_id                     NUMBER
,   industry_attribute1           VARCHAR2(240)
,   industry_attribute10          VARCHAR2(240)
,   industry_attribute11          VARCHAR2(240)
,   industry_attribute12          VARCHAR2(240)
,   industry_attribute13          VARCHAR2(240)
,   industry_attribute14          VARCHAR2(240)
,   industry_attribute15          VARCHAR2(240)
,   industry_attribute16          VARCHAR2(240)
,   industry_attribute17          VARCHAR2(240)
,   industry_attribute18          VARCHAR2(240)
,   industry_attribute19          VARCHAR2(240)
,   industry_attribute20          VARCHAR2(240)
,   industry_attribute21          VARCHAR2(240)
,   industry_attribute22          VARCHAR2(240)
,   industry_attribute23          VARCHAR2(240)
,   industry_attribute24          VARCHAR2(240)
,   industry_attribute25          VARCHAR2(240)
,   industry_attribute26          VARCHAR2(240)
,   industry_attribute27          VARCHAR2(240)
,   industry_attribute28          VARCHAR2(240)
,   industry_attribute29          VARCHAR2(240)
,   industry_attribute30          VARCHAR2(240)
,   industry_attribute2           VARCHAR2(240)
,   industry_attribute3           VARCHAR2(240)
,   industry_attribute4           VARCHAR2(240)
,   industry_attribute5           VARCHAR2(240)
,   industry_attribute6           VARCHAR2(240)
,   industry_attribute7           VARCHAR2(240)
,   industry_attribute8           VARCHAR2(240)
,   industry_attribute9           VARCHAR2(240)
,   industry_context              VARCHAR2(30)
,   intermed_ship_to_org_id       NUMBER
,   intermed_ship_to_contact_id   NUMBER
,   inventory_item_id             NUMBER
,   invoice_complete_flag         VARCHAR2(1)
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   item_input                    VARCHAR2(2000)
,   item_revision                 VARCHAR2(3)
,   item_type_code                VARCHAR2(30)
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   latest_acceptable_date        DATE
,   line_category_code            VARCHAR2(30)
,   line_id                       NUMBER
,   line_number                   NUMBER
,   line_type_id                  NUMBER
,   link_to_line_id               NUMBER
,   link_to_line_index            NUMBER
,   model_group_number            NUMBER
,   open_flag                     VARCHAR2(1)
,   option_flag                   VARCHAR2(1)
,   option_number                 NUMBER
,   ordered_quantity              NUMBER
,   order_quantity_uom            VARCHAR2(3)
,   org_id                        NUMBER
,   orig_sys_document_ref         VARCHAR2(50)
,   orig_sys_line_ref             VARCHAR2(50)
,   over_ship_reason_code	  VARCHAR2(30)
,   over_ship_resolved_flag	  VARCHAR2(1)
,   payment_term_id               NUMBER
,   price_list_id                 NUMBER
,   pricing_attribute1            VARCHAR2(240)
,   pricing_attribute10           VARCHAR2(240)
,   pricing_attribute2            VARCHAR2(240)
,   pricing_attribute3            VARCHAR2(240)
,   pricing_attribute4            VARCHAR2(240)
,   pricing_attribute5            VARCHAR2(240)
,   pricing_attribute6            VARCHAR2(240)
,   pricing_attribute7            VARCHAR2(240)
,   pricing_attribute8            VARCHAR2(240)
,   pricing_attribute9            VARCHAR2(240)
,   pricing_context               VARCHAR2(240)
,   pricing_date                  DATE
,   pricing_quantity              NUMBER
,   pricing_quantity_uom          VARCHAR2(3)
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   project_id                    NUMBER
,   promise_date                  DATE
,   reference_header_id           NUMBER
,   reference_line_id             NUMBER
,   reference_type                VARCHAR2(30)
,   request_date                  DATE
,   request_id                    NUMBER
,   reserved_quantity             NUMBER
,   return_attribute1             VARCHAR2(240)
,   return_attribute10            VARCHAR2(240)
,   return_attribute11            VARCHAR2(240)
,   return_attribute12            VARCHAR2(240)
,   return_attribute13            VARCHAR2(240)
,   return_attribute14            VARCHAR2(240)
,   return_attribute15            VARCHAR2(240)
,   return_attribute2             VARCHAR2(240)
,   return_attribute3             VARCHAR2(240)
,   return_attribute4             VARCHAR2(240)
,   return_attribute5             VARCHAR2(240)
,   return_attribute6             VARCHAR2(240)
,   return_attribute7             VARCHAR2(240)
,   return_attribute8             VARCHAR2(240)
,   return_attribute9             VARCHAR2(240)
,   return_context                VARCHAR2(30)
,   return_reason_code		    VARCHAR2(30)
,   rla_schedule_type_code        VARCHAR2(30)
,   salesrep_id			    NUMBER
,   schedule_arrival_date         DATE
,   schedule_ship_date            DATE
,   schedule_action_code          VARCHAR2(30)
,   schedule_status_code          VARCHAR2(30)
,   shipment_number               NUMBER
,   shipment_priority_code        VARCHAR2(30)
,   shipped_quantity              NUMBER
,   shipping_method_code          VARCHAR2(30)
,   shipping_quantity             NUMBER
,   shipping_quantity_uom         VARCHAR2(3)
,   ship_from_org_id              NUMBER
,   ship_model_complete_flag      VARCHAR2(30)
,   ship_set_id                   NUMBER
,   ship_tolerance_above          NUMBER
,   ship_tolerance_below          NUMBER
,   ship_to_contact_id            NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_org_id                NUMBER
,   sort_order                    VARCHAR2(2000)  -- 4336446
,   source_document_id            NUMBER
,   source_document_line_id       NUMBER
,   source_document_type_id       NUMBER
,   source_type_code              VARCHAR2(30)
,   split_from_line_id		  NUMBER
,   task_id                       NUMBER
,   tax_code                      VARCHAR2(50)
,   tax_date                      DATE
,   tax_exempt_flag               VARCHAR2(30)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   tax_point_code                VARCHAR2(30)
,   tax_rate                      NUMBER
,   tax_value                     NUMBER
,   unit_list_price               NUMBER
,   unit_selling_price            NUMBER
,   veh_cus_item_cum_key_id       NUMBER
,   visible_demand_flag           VARCHAR2(1)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   change_reason                 VARCHAR2(30)
,   change_comments               VARCHAR2(32000)
,   arrival_set	           	  VARCHAR2(30)
,   ship_set			  VARCHAR2(30)
--added for bug 3431595 to indicate that OE_Atp.Atp_check procedure has been called from Pricing And Availability Section of Quick Sales Order form
, p_pa_call			  BOOLEAN :=FALSE

);


Procedure ATP_Check(p_line_atp_rec      IN line_atp_rec_type
                    ,p_old_line_atp_rec IN line_atp_rec_type
,x_atp_rec OUT NOCOPY atp_rec_type

,x_return_status OUT NOCOPY VARCHAR2

                    );

Procedure ATP_Inquiry(p_entity_type     IN  VARCHAR2,
                      p_entity_id       IN  NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_atp_tbl OUT NOCOPY atp_tbl_type

                      );

Procedure Assign_Atprec(p_line_atp_rec      IN Line_Atp_Rec_Type
                        ,x_line_rec       IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
                       );
END OE_ATP;

/

--------------------------------------------------------
--  DDL for Package OE_UPG_SO_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPG_SO_NEW" AUTHID CURRENT_USER as
/* $Header: OEXNUSOS.pls 120.1.12000000.1 2007/01/16 21:55:27 appldev ship $ */


   TYPE Canc_rec_type IS  RECORD
   (
	can_header_id				number,
	can_line_id				number,
	can_created_by				number,
	can_creation_date 			date,
	can_last_updated_by                     number,
	can_last_update_date                    date,
	can_last_update_login                   number,
	can_program_application_id              number(15),
	can_program_id                          number(15),
	can_program_update_date                 date,
	can_request_id                          number(15),
	can_cancel_code                         varchar2(30),
	can_cancelled_by                        number,
	can_cancel_date                         date,
	can_cancelled_quantity                  number,
	can_cancel_comment                      varchar2(32000),
	can_context                             varchar2(30),
	can_attribute1                          varchar2(150),
	can_attribute2                          varchar2(150),
	can_attribute3                          varchar2(150),
	can_attribute4                          varchar2(150),
	can_attribute5                          varchar2(150),
	can_attribute6                          varchar2(150),
	can_attribute7                          varchar2(150),
	can_attribute8                          varchar2(150),
	can_attribute9                          varchar2(150),
	can_attribute10                         varchar2(150),
	can_attribute11                         varchar2(150),
	can_attribute12                         varchar2(150),
	can_attribute13                         varchar2(150),
	can_attribute14                         varchar2(150),
	can_attribute15                         varchar2(150)
   );

   G_CANC_REC                                   Canc_Rec_type;
   G_HDR_CANC_REC                               Canc_Rec_type;

   G_ORD_CANC_FLAG                              Varchar2(1);
   G_HDR_CANC_FLAG                              Varchar2(1);
   G_HEADER_ID                                  Number;
   G_LINE_ID                                    Number;
   G_OLD_LINE_ID                                Number;
   G_SET_ID                                     Number;
   G_INCLUDE_SHIP_SET                           varchar2(1) := 'N' ;
   G_TAX_EXEMPT_FLAG                            Varchar2(1);
   G_CUSTOMER_ID                                Number;
   G_FREIGHT_TERMS_CODE                         Varchar2(30);
   G_TERMS_ID                                   Number;
   G_ACCOUNTING_RULE_ID                         Number;
   G_INVOICING_RULE_ID                          Number;
   G_INVOICE_TO_SITE_USE_ID                     Number;
   G_LINE_ID_CHANGE_FLAG                        Varchar2(1);
   G_LAST_LINE_NUMBER                           Number;
   G_COPIED_FLAG                                Varchar2(1);
   G_AUTO_FLAG                                  Varchar2(1);
   G_COPIED_LINE_FLAG                           Varchar2(1);
   G_EARLIEST_SCHEDULE_LIMIT                    Number;
   G_LATEST_SCHEDULE_LIMIT                      Number;
   G_ORIG_LINE_ID                               Number;
   G_PURCHASE_ORDER_NUM                         Varchar2(50);
   G_SALESREP_ID                                Number;
   G_MTL_SALES_ORDER_ID                         Number;
   G_ERROR_ALERT                                Varchar2(1);
   G_ERROR_LOCATION                             NUMBER;
   G_CANCELLED_FLAG                             Varchar2(1);
   G_ORDER_TYPE_ID                              Number;
   G_ORDER_CATEGORY_CODE                        Varchar2(30);
   G_INTERNAL_ORDER                             Varchar2(1);
   -- Fix bug 1661010
   G_SHIP_TO_SITE_USE_ID                        Number;

	 v_reference_line_Id       number;
      v_reference_header_id     number;
      v_ins_return_quantity     number;
      v_avl_return_quantity     number;
      v_bal_return_quantity     number;
      v_return_new_line_id      number;
      v_return_new_line_number  number;
      v_return_lctr             number;
      v_return_created_line_id  number;
      v_line_exit_flag          number;
      v_cust_trx_attribute6     number;
      v_customer_trx_id         number;
      v_received_quantity       number;
      v_actual_ordered_quantity number;
      v_master_org_for_single_org number := NULL;

      r_uom_code                Varchar2(3);
      r_inventory_item_id       number;
      r_warehouse_id            number;
      r_inventory_item_id_2     number;
      r_uom_code_2              varchar2(3);
      r_warehouse_id_2          number;
      r_ato_model               boolean := FALSE;
      r_ato_option              boolean := FALSE;
      r_no_config_item          boolean := FALSE;
      r_line_set_id             number;
      r_shipment_number         number := 1;
      r_ato_flag                varchar2(1);
      r_option_flag             varchar2(1);
      r_original_item_type_code varchar2(30);
      r_lctr                    number;

   TYPE Line_rec_type IS  RECORD
   (
       line_id                            number,
       org_id                             number,
       header_id                          number,
       line_number                        number,
       date_requested_current             date,
       promise_date                       date,
       schedule_date                      date,
       ordered_quantity                   number,
       cancelled_quantity                 number,
       shipped_quantity                   number,
       tax_exempt_number                  varchar2(80),
       tax_exempt_reason_code             varchar2(30),
       warehouse_id                       number,
       subinventory                       varchar2(10),
       ship_to_site_use_id                number,
       ship_to_contact_id                 number,
       customer_item_id                   number,
       demand_stream_id                   number,
       customer_dock_code                 varchar2(50),
       customer_job                       varchar2(50),
       customer_production_line           varchar2(50),
       customer_model_serial_number       varchar2(50),
       project_id                         number,
       task_id                            number,
       inventory_item_id                  number,
       tax_code                           varchar2(50),
       demand_class_code                  varchar2(30),
       price_list_id                      number,
       agreement_id                       number,
       shipment_priority_code             varchar2(30),
       ship_method_code                   varchar2(30),
       invoicing_rule_id                  number,
       accounting_rule_id                 number,
       original_system_line_reference     varchar2(50),
       selling_price                      number,
       list_price                         number,
       context                            varchar2(30),
       attribute1                         varchar2(150),
       attribute2                         varchar2(150),
       attribute3                         varchar2(150),
       attribute4                         varchar2(150),
       attribute5                         varchar2(150),
       attribute6                         varchar2(150),
       attribute7                         varchar2(150),
       attribute8                         varchar2(150),
       attribute9                         varchar2(150),
       attribute10                        varchar2(150),
       attribute11                        varchar2(150),
       attribute12                        varchar2(150),
       attribute13                        varchar2(150),
       attribute14                        varchar2(150),
       attribute15                        varchar2(150),
       industry_context                   varchar2(30),
       industry_attribute1                varchar2(150),
       industry_attribute2                varchar2(150),
       industry_attribute3                varchar2(150),
       industry_attribute4                varchar2(150),
       industry_attribute5                varchar2(150),
       industry_attribute6                varchar2(150),
       industry_attribute7                varchar2(150),
       industry_attribute8                varchar2(150),
       industry_attribute9                varchar2(150),
       industry_attribute10               varchar2(150),
       industry_attribute11               varchar2(150),
       industry_attribute12               varchar2(150),
       industry_attribute13               varchar2(150),
       industry_attribute14               varchar2(150),
       industry_attribute15               varchar2(150),
       global_attribute_category          varchar2(30),
       global_attribute1                  varchar2(150),
       global_attribute2                  varchar2(150),
       global_attribute3                  varchar2(150),
       global_attribute4                  varchar2(150),
       global_attribute5                  varchar2(150),
       global_attribute6                  varchar2(150),
       global_attribute7                  varchar2(150),
       global_attribute8                  varchar2(150),
       global_attribute9                  varchar2(150),
       global_attribute10                 varchar2(150),
       global_attribute11                 varchar2(150),
       global_attribute12                 varchar2(150),
       global_attribute13                 varchar2(150),
       global_attribute14                 varchar2(150),
       global_attribute15                 varchar2(150),
       global_attribute16                 varchar2(150),
       global_attribute17                 varchar2(150),
       global_attribute18                 varchar2(150),
       global_attribute19                 varchar2(150),
       global_attribute20                 varchar2(150),
       pricing_context                    varchar2(30),
       pricing_attribute1                 varchar2(150),
       pricing_attribute2                 varchar2(150),
       pricing_attribute3                 varchar2(150),
       pricing_attribute4                 varchar2(150),
       pricing_attribute5                 varchar2(150),
       pricing_attribute6                 varchar2(150),
       pricing_attribute7                 varchar2(150),
       pricing_attribute8                 varchar2(150),
       pricing_attribute9                 varchar2(150),
       pricing_attribute10                varchar2(150),
       pricing_attribute11                varchar2(150),
       pricing_attribute12                varchar2(150),
       pricing_attribute13                varchar2(150),
       pricing_attribute14                varchar2(150),
       pricing_attribute15                varchar2(150),
       creation_date                      date,
       created_by                         number,
       last_update_date                   date,
       last_updated_by                    number,
       last_update_login                  number,
       program_application_id             number,
       program_id                         number,
       program_update_date                date,
       request_id                         number,
       parent_line_id                     number,
       link_to_line_id                    number,
       component_sequence_id              number,
       component_code                     varchar2(1000),
       item_type_code                     varchar2(30),
       source_type_code                   varchar2(30),
       transaction_reason_code            varchar2(30),
       latest_acceptable_date             date,
       dep_plan_required_flag             varchar2(1),
       schedule_status_code               varchar2(30),
       configuration_item_flag            varchar2(1),
       ship_set_number                    number,
       option_flag                        varchar2(1),
       unit_code                          varchar2(3),
       line_detail_id                     number,
       credit_invoice_line_id             number,
       included_item_flag                 varchar2(1),
       ato_line_id                        number,
       line_category_code                 varchar2(30),
       planning_priority                  number,
       return_reference_type_Code         varchar2(30),
       line_type_code                     varchar2(30),
       return_reference_id                number,
       open_flag                          varchar2(1),
       ship_model_complete_flag           varchar2(1),
       standard_component_freeze_date     date,
       booked_Flag                        varchar2(1),
       shipping_interfaced_flag           varchar2(1),
       fulfilled_flag                     varchar2(1),
       invoice_interface_status_code      varchar2(30),
       intermediate_ship_to_id            number,
       rla_schedule_type_code             varchar2(30),
       transaction_type_code              varchar2(30),
       transaction_comments               varchar2(2000),
       selling_percent                    number,
       customer_product_id                number,
       cp_service_id                      number,
       serviced_quantity                  number,
       service_duration                   number,
       service_start_date                 date,
       service_end_date                   date,
       service_coterminate_flag           varchar2(1),
       service_period_conversion_rate     number,
       service_mass_txn_temp_id           number,
       service_parent_line_id             number,
       service_txn_reason_code            varchar2(30),
       service_txn_comments               varchar2(2000),
       unit_selling_percent               number,
       unit_list_percent                  number,
       unit_percent_base_price            number,
       service_number                     number,
       serviced_line_id                   number,
       service_context                    varchar2(30),
       service_attribute1                 varchar2(240),
       service_attribute2                 varchar2(240),
       service_attribute3                 varchar2(240),
       service_attribute4                 varchar2(240),
       service_attribute5                 varchar2(240),
       service_attribute6                 varchar2(240),
       service_attribute7                 varchar2(240),
       service_attribute8                 varchar2(240),
       service_attribute9                 varchar2(240),
       service_attribute10                varchar2(240),
       service_attribute11                varchar2(240),
       service_attribute12                varchar2(240),
       service_attribute13                varchar2(240),
       service_attribute14                varchar2(240),
       service_attribute15                varchar2(240),
       service_period                     varchar2(3),
       list_percent                       number,
       percent_base_price                 number,
       picking_line_id                    number,
       planning_prod_seq_number           varchar2(50),
       actual_departure_date              date,
       delivery                           number,
       tp_context                         varchar2(30),
       tp_attribute1                      varchar2(240),
       tp_attribute2                      varchar2(240),
       tp_attribute3                      varchar2(240),
       tp_attribute4                      varchar2(240),
       tp_attribute5                      varchar2(240),
       tp_attribute6                      varchar2(240),
       tp_attribute7                      varchar2(240),
       tp_attribute8                      varchar2(240),
       tp_attribute9                      varchar2(240),
       tp_attribute10                     varchar2(240),
       tp_attribute11                     varchar2(240),
       tp_attribute12                     varchar2(240),
       tp_attribute13                     varchar2(240),
       tp_attribute14                     varchar2(240),
       tp_attribute15                     varchar2(240),
       flow_status_code                   varchar2(30),
       re_source_flag                     varchar2(1),
       source_document_type_id            number,
       source_document_id                 number,
       source_document_line_id            number,
       service_reference_type_code        varchar2(30),
       service_reference_line_id          number,
       service_reference_system_id        number,
       calculate_price_flag               varchar2(1),
       marketing_source_code_id           number,
       shippable_flag                     varchar2(1),
       fulfillment_method_code            varchar2(30),
       revenue_amount                     number,
       fulfillment_date                   date,
       visible_demand_flag                varchar2(1),
       cancelled_flag                     varchar2(1),
       line_type_id                       number,
       fulfilled_quantity                 number,
       invoiced_quantity                  number,
       shipping_quantity_uom              varchar2(3),
       tax_date                           date,
       sort_order                         VARCHAR2(240),
       option_number                      number,
       order_source_id                    number,
       orig_sys_document_ref              VARCHAR2(50),
       terms_id                           number,
       commitment_id                      number,
       split_from_line_id                 NUMBER -- 3103312
   );

   G_LINE_REC                                      Line_Rec_type;

   TYPE LOG_rec_type IS  RECORD
   (
         Header_id                          number,
         Old_Line_ID                        number,
         Old_Line_Detail_ID                 number,
         New_Line_ID                        number,
         Picking_line_id                    number,
         New_Line_Number                    number,
         Return_Qty_Available               number,
         MTL_Sales_Order_ID                 number,
         comments                           varchar2(240),
         Creation_Date                      date,
         Last_Update_Date                   date,
         Delivery                           Number
   );

   G_LOG_REC                                       Log_Rec_type;

TYPE get_update_rec_type	IS RECORD
(
	line_id			NUMBER
,	item_type_code		VARCHAR2(30)
,	top_model_line_id	NUMBER
,    ato_line_id         NUMBER
,	shippable_flag		VARCHAR2(1)
,	shipped_quantity	NUMBER
,    line_number         NUMBER
,    shipment_number     NUMBER
,    model_remnant_flag  VARCHAR2(1)
,    link_to_line_id     NUMBER
,    line_category_code  VARCHAR2(30)
,    fulfilled_quantity  NUMBER
,    fulfilled_flag      NUMBER
,    fulfillment_date    DATE
,    actual_shipment_date DATE
,    ordered_quantity    NUMBER
,    service_reference_line_id NUMBER
,    option_number       NUMBER
,    component_number    NUMBER
);

TYPE get_update_tbl_type IS TABLE OF get_update_rec_type
	INDEX BY BINARY_INTEGER;

TYPE update_rec_type IS RECORD
(
	line_number		NUMBER
,    shipment_number     NUMBER
,    option_number       NUMBER
,    component_number    NUMBER
,    model_remnant_flag  VARCHAR2(1)
,    ordered_quantity    NUMBER
,    actual_shipment_date DATE
,    shipped_quantity    NUMBER
,    fulfilled_quantity  NUMBER
,    fulfilled_flag      VARCHAR2(1)
,    fulfillment_date    DATE
,    temp_update_flag    VARCHAR2(1)
,    service_reference_line_id NUMBER
,    top_model_line_id   NUMBER
,    ato_line_id         NUMBER
,    item_type_code      VARCHAR2(30)
,    shippable_flag      VARCHAR2(1)
,    unit_selling_price  NUMBER
,    unit_list_price     NUMBER
,    ship_set_id         NUMBER
);

TYPE update_tbl_type IS TABLE OF update_rec_type
	INDEX BY BINARY_INTEGER;
   Procedure Upgrade_Price_adjustments
	( L_level_flag  IN  Varchar2 );

   Procedure Upgrade_Sales_Credits
	( L_level_flag  IN  Varchar2 );

   Procedure Upgrade_Cancellations;

   Procedure Upgrade_Create_Order_lines;

   Procedure Upgrade_Create_Order_Headers
	( L_Line_Type  IN Varchar2 ,
       L_Slab       IN Number);

   Procedure Upgrade_Insert_Lines_History;

   Procedure Upgrade_Insert_Upgrade_Log;

   Procedure Upgrade_Process_Distbns
      ( L_total_slabs      IN  Number,
	   L_type           IN varchar2);

   Procedure Upgrade_holds_Distbns
      ( L_total_slabs    IN  Number );

   Procedure Upgrade_Freight_Distbns
      ( L_total_slabs    IN  Number );

   PROCEDURE upgrade_inst_detail_distbns
     (  p_number_of_slabs IN NUMBER );

   Procedure Upgrade_Insert_Distbn_Record
     (
        L_slab             IN  Varchar2,
        L_start_Header_id  IN  Number,
        L_end_Header_Id    IN  Number,
        L_type_var         IN  Varchar2
     );
   Procedure Upgrade_Insert_Errors
     (
        L_header_id             IN  Varchar2,
        L_comments              IN  varchar2
     );

   Procedure Upgrade_Create_Line_Sets;
   Procedure Upgrade_Upd_Serv_Ref_line_id;
   PROCEDURE insert_multiple_models;
   PROCEDURE update_after_insert;
   PROCEDURE update_remnant_flag;

Procedure Insert_Return_Included_Items(p_line_id NUMBER,
               module varchar2 default null);
Procedure Process_Upgraded_Returns(p_header_id in NUMBER);
Procedure Return_Fulfillment_Sets(p_header_id in NUMBER);

End OE_UPG_SO_NEW;

 

/

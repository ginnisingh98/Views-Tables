--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXFLINS.pls 120.1.12010000.3 2010/10/29 03:26:33 srsunkar ship $ */


G_ENABLE_VISIBILITY_MSG   VARCHAR2(1)  := NVL(FND_PROFILE.Value('ONT_ENABLE_MSG'),'N');

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE Varchar2_Tbl_Type IS TABLE OF Varchar2(2000)
    INDEX BY BINARY_INTEGER;

G_NULL_NUMBER_TBL        Number_Tbl_Type;
G_NULL_VARCHAR2_TBL      Varchar2_Tbl_Type;

-- Out parameter record for Validate_And_Write
TYPE Validate_Write_Rec_Type IS RECORD
  ( x_creation_date                     DATE
  , x_created_by                        NUMBER
  , x_last_update_date                  DATE
  , x_last_updated_by                   NUMBER
  , x_last_update_login                 NUMBER
  , x_goods_value                       NUMBER
  , x_discounts                         NUMBER
  , x_charges                           NUMBER
  , x_taxes                             NUMBER
  , x_line_tax_value                    NUMBER
  , x_schedule_ship_date                DATE
  , x_schedule_arrival_date             DATE
  , x_schedule_status_code              VARCHAR2(30)
  , x_schedule_action_code              VARCHAR2(30)
  , x_ship_from_address1                VARCHAR2(240)
  , x_ship_from_address2                VARCHAR2(240)
  , x_ship_from_address3                VARCHAR2(240)
  , x_ship_from_address4                VARCHAR2(240)
  , x_ship_from_location                VARCHAR2(240)
  , x_ship_from_org                     VARCHAR2(240)
  , x_ship_from_org_id                  NUMBER
  , x_subinventory                      VARCHAR2(10)
  , x_promise_date                      DATE
  , x_unit_selling_price                NUMBER
  , x_unit_list_price                   NUMBER
  , x_list_percent                      NUMBER
  , x_selling_percent                   NUMBER
  , x_pricing_quantity                  NUMBER
  , x_pricing_quantity_uom              VARCHAR2(3)
  , x_calculate_price_flag              VARCHAR2(1)
  , x_calculate_price_descr             VARCHAR2(240)
  , x_inventory_item_id                 NUMBER
  , x_ordered_item_id                   NUMBER
  , x_price_list_id                     NUMBER
  , x_price_list                        VARCHAR2(240)
  , x_payment_term_id                   NUMBER
  , x_payment_term                      VARCHAR2(240)
  , x_shipment_priority_code            VARCHAR2(30)
  , x_shipment_priority                 VARCHAR2(240)
  , x_freight_terms_code                VARCHAR2(30)
  , x_freight_terms                     VARCHAR2(240)
  , x_commitment_applied_amount         NUMBER
  , x_lock_control                      NUMBER
  , x_Original_Inventory_Item_Id        NUMBER
  , x_Original_item_iden_Type           VARCHAR2(30)
  , x_Original_ordered_item_id          NUMBER
  , x_Original_ordered_item             VARCHAR2(2000)
  , x_Original_inventory_item           VARCHAR2(2000)
  , x_Original_item_type                VARCHAR2(240)
  , x_Late_Demand_Penalty_Factor        NUMBER    -- Bug-2478107
  , x_Override_ATP_Date_Code            VARCHAR2(30)  -- BUG 1282873
  , x_unit_cost                         NUMBER  --MRG BGN
  , x_shipping_method_code              VARCHAR2(30)  -- 2806483
  , x_shipping_method                   VARCHAR2(80)  -- 2806483
  , x_freight_carrier_code              VARCHAR2(30)  -- 2806483
  , x_freight_carrier                   VARCHAR2(80)  -- 2806483
  , x_arrival_set_id                    NUMBER        -- 2817915
  , x_arrival_set                       VARCHAR2(30)  -- 2817915
  , x_ship_set_id                       NUMBER        -- 2817915
  , x_ship_set                          VARCHAR2(30)  -- 2817915
  , x_firm_demand_flag                  VARCHAR2(1)
  , x_earliest_ship_date                DATE
-- Override List Price
  , x_original_list_price                 NUMBER
  , x_unit_list_price_per_pqty            NUMBER
  , x_unit_selling_price_per_pqty         NUMBER
  );

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   x_line_tbl                      IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_old_line_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_line_val_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Tbl_Type
);

--  Procedure   :   Change_Attribute
--
-- Commenting out all flex attributes because
-- we ran into an odd bug where the client(pld) does not recognize a package
-- at all once it gets over a certain size (255 parameters per procedure)

-- Commenting out the pricing attributes for now since the same problem
-- of the client pld not able to recognize the package beyond 255 parameters.

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type DEFAULT G_NULL_NUMBER_TBL
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type DEFAULT G_NULL_VARCHAR2_TBL
,   p_reason			    IN  VARCHAR2
,   p_comments			    IN  VARCHAR2
,   p_line_dff_rec                  IN OE_OE_FORM_LINE.line_dff_rec_type
,   p_default_cache_line_rec           IN  OE_ORDER_PUB.Line_Rec_Type
,   p_date_format_mask              IN  VARCHAR2 DEFAULT 'DD-MON-YYYY HH24:MI:SS'
,   x_line_tbl                      IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_old_line_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_line_val_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Tbl_Type
--, x_dualum_ind OUT NOCOPY NUMBER --OPM 02/JUN/00  INVCONV
--, x_grade_ctl OUT NOCOPY NUMBER --OPM 02/JUN/00   INVCONV
, x_process_warehouse_flag OUT NOCOPY VARCHAR2 --OPM 02/JUN/00
, x_ont_pricing_qty_source OUT NOCOPY VARCHAR2  -- INVCONV
, x_grade_control_flag OUT NOCOPY VARCHAR2 -- INVCONV
, x_tracking_quantity_ind   OUT NOCOPY VARCHAR2 -- INVCONV
, x_secondary_default_ind OUT NOCOPY VARCHAR2 -- INVCONV
, x_lot_divisible_flag OUT NOCOPY VARCHAR2 -- INVCONV
, x_lot_control_code  OUT  NOCOPY			NUMBER  -- 4172680 INVCONV


);

--  Procedure       Validate_And_Write
--
-- 2806483 All out parameters are replace dy Validate_Write_Rec_Type

PROCEDURE Validate_And_Write
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_cascade_flag                  OUT NOCOPY BOOLEAN
, p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2
, p_change_comments               IN  VARCHAR2
, x_line_val_rec                  OUT NOCOPY Validate_Write_Rec_Type  -- 2806483
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_lock_control                  IN  NUMBER

);


TYPE Line_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER
,   agreement_id                  NUMBER
,   arrival_set_id                NUMBER
,   authorized_to_ship_flag       VARCHAR2(1)
,   booked_flag                   VARCHAR2(1)
,   cancelled_flag                VARCHAR2(1)
,   cancelled_quantity2            NUMBER     --OPM 02/JUN/00
,   commitment_id                 NUMBER
,   credit_invoice_line_id        NUMBER
,   cust_po_number                VARCHAR2(50)
,   delivery_lead_time            NUMBER
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   demand_bucket_type_code       VARCHAR2(30)
,   demand_class_code             VARCHAR2(30)
,   dep_plan_required_flag        VARCHAR2(1)
,   end_item_unit_number          VARCHAR2(30)
,   fob_point_code                VARCHAR2(30)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
,   fulfilled_quantity2           NUMBER                --OPM 02/JUN/00
,   header_id                     NUMBER
,   intermed_ship_to_org_id       NUMBER
,   intermed_ship_to_contact_id   NUMBER
,   inventory_item_id             NUMBER
,   invoice_interface_status_code VARCHAR2(30)
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   item_relationship_type        NUMBER
,   ordered_item                  VARCHAR2(2000)
,   item_revision                 VARCHAR2(3)
,   item_type_code                VARCHAR2(30)
,   line_category_code            VARCHAR2(30)
,   line_id                       NUMBER
,   line_number                   NUMBER
,   open_flag                     VARCHAR2(1)
,   option_flag                   VARCHAR2(1)
,   option_number                 NUMBER
,   ordered_quantity              NUMBER
,   ordered_quantity2             NUMBER                --OPM 02/JUN/00
,   order_quantity_uom            VARCHAR2(3)
,   ordered_quantity_uom2         VARCHAR2(3)           --OPM 02/JUN/00
,   org_id                        NUMBER
,   orig_sys_document_ref         VARCHAR2(50)
,   orig_sys_line_ref             VARCHAR2(50)
,   over_ship_reason_code	    VARCHAR2(30)
,   over_ship_resolved_flag	    VARCHAR2(1)
,   payment_term_id               NUMBER
,   preferred_grade               VARCHAR2(150)           -- INVCONV 4091955
,   price_list_id                 NUMBER
,   project_id                    NUMBER
,   reference_customer_trx_line_id NUMBER
,   reference_header_id           NUMBER
,   reference_line_id             NUMBER
,   reference_type                VARCHAR2(30)
,   request_date                  DATE
,   return_reason_code		    VARCHAR2(30)
,   rla_schedule_type_code        VARCHAR2(30)
,   salesrep_id			    NUMBER
,   schedule_action_code          VARCHAR2(30)
,   schedule_status_code          VARCHAR2(30)
,   shipment_number               NUMBER
,   shipment_priority_code        VARCHAR2(30)
,   shipping_interfaced_flag      VARCHAR2(1)
,   shipping_method_code          VARCHAR2(30)
,   shipped_quantity2             NUMBER                --OPM 02/JUN/00
,   shipping_quantity2            NUMBER                --OPM 02/JUN/00
,   shipping_quantity_uom         VARCHAR2(3)
,   shipping_quantity_uom2        VARCHAR2(3)           --OPM 02/JUN/00
,   ship_from_org_id              NUMBER
,   subinventory                  VARCHAR2(10)
,   ship_model_complete_flag      VARCHAR2(30)
,   ship_set_id                   NUMBER
,   fulfillment_set_id            NUMBER
,   ship_tolerance_above          NUMBER
,   ship_tolerance_below          NUMBER
,   ship_to_contact_id            NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_org_id                NUMBER
,   sold_from_org_id              NUMBER
,   source_document_id            NUMBER
,   source_document_line_id       NUMBER
,   source_document_type_id       NUMBER
,   source_type_code              VARCHAR2(30)
,   task_id                       NUMBER
,   tax_code                      VARCHAR2(50)
,   tax_exempt_flag               VARCHAR2(30)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   tax_point_code                VARCHAR2(30)
,   return_status                 VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   change_reason                 VARCHAR2(30)
,   arrival_set	              VARCHAR2(30)
,   ship_set			         VARCHAR2(30)
,   fulfillment_set		         VARCHAR2(30)
,   order_source_id               NUMBER
,   orig_sys_shipment_ref	    VARCHAR2(50)
,   change_sequence	  	         VARCHAR2(50)
,   drop_ship_flag		         VARCHAR2(1)
,   customer_line_number	         VARCHAR2(50)
,   customer_shipment_number	    VARCHAR2(50)
,   customer_item_net_price	    NUMBER
,   customer_payment_term_id	    NUMBER
,   ordered_item_id               NUMBER
,   item_identifier_type          VARCHAR2(25)
,   calculate_price_flag          VARCHAR2(30)
,   service_txn_reason_code       VARCHAR2(30)
,   service_txn_comments         VARCHAR2(2000)
,   service_duration             NUMBER
,   service_period               VARCHAR2(3)
,   service_start_date           DATE
,   service_end_date             DATE
,   service_coterminate_flag     VARCHAR2(1)
,   service_number               NUMBER
,   service_reference_type_code  VARCHAR2(30)
,   service_reference_line_id    NUMBER
,   service_reference_system_id  NUMBER
,   flow_status_code		   VARCHAR2(30)
,   svc_ref_order_number     NUMBER
,   svc_ref_order_type       Varchar2(200)
,   payment_level_code          VARCHAR2(30)
,   payment_commitment_id       NUMBER
,   original_inventory_item_id  NUMBER
,   original_ordered_item_id      NUMBER
,   original_item_identifier_Type VARCHAR2(30)
,   original_ordered_item        VARCHAR2(2000)
,   late_demand_penalty_factor   NUMBER              -- Bug-2478107
,   override_atp_date_code       VARCHAR2(30)
,   user_item_description        VARCHAR2(1000)
,   blanket_number               NUMBER
--retro{
,   retrobill_request_id         NUMBER
--retro}
, end_customer_site_use_id  NUMBER
,  end_customer_contact_id  NUMBER
, end_customer_id  NUMBER
--Macd
,   config_header_id        NUMBER
,   config_rev_nbr          NUMBER
, configuration_id          NUMBER
, ib_owner                  VARCHAR2(60)
, ib_current_location       VARCHAR2(60)
, ib_installed_at_location  VARCHAR2(60)
--recurring charges
, charge_periodicity_code   VARCHAR2(3)
--Customer Acceptance
, CONTINGENCY_ID            NUMBER
, REVREC_EVENT_CODE         VARCHAR2(30)
, ACCEPTED_BY               NUMBER
);

TYPE Line_Val_Rec_Type IS RECORD
(
 Project_Number                  VARCHAR2(25),
 Task_Number                     VARCHAR2(25),
 Ref_Order_Number                NUMBER,
 Ref_Line_Number                 NUMBER,
 Ref_Shipment_Number             NUMBER,
 Ref_Option_Number               NUMBER,
 Ref_Component_Number            NUMBER, -- added for bug3818680
 Ref_Invoice_number              VARCHAR2(80),
 Ref_invoice_Line_Number         NUMBER,
 Credit_Invoice_Number           VARCHAR2(80),
 Salesrep                        VARCHAR2(240),
 shipment_priority               VARCHAR2(200),
 freight_terms                   VARCHAR2(200),
 freight_carrier                 VARCHAR2(200),
 shipping_method                 VARCHAR2(200),
 FOB                             VARCHAR2(200),
 TAX_EXEMPT                      VARCHAR2(200),
 TAX_EXEMPT_REASON               VARCHAR2(200),
 tax_group                       VARCHAR2(1),
 RETURN_REASON                   VARCHAR2(200),
 Item_Description                VARCHAR2(2000),
 Ordered_Item_Dsp                VARCHAR2(2000),
 source_type                     VARCHAR2(80),
 demand_class                    VARCHAR2(80),
 status                          VARCHAR2(240),
 Transactional_Curr_Code         VARCHAR2(15),
 Ship_To_Customer_Name           VARCHAR2(360),
 Invoice_To_Customer_Name        VARCHAR2(360),
 Ship_To_Customer_Number         VARCHAR2(60),
 Invoice_To_Customer_Number      VARCHAR2(60),
 intmed_ship_to                  VARCHAR2(40),
 intmed_ship_to_location         VARCHAR2(40),
 intmed_ship_to_address1         VARCHAR2(240),
 intmed_ship_to_address2         VARCHAR2(240),
 intmed_ship_to_address3         VARCHAR2(240),
 intmed_ship_to_address4         VARCHAR2(246),
/*1621182*/
 intmed_ship_to_address5         VARCHAR2(246),
/*1621182*/
 intmed_ship_to_contact          VARCHAR2(123),
 deliver_to                      VARCHAR2(40),
 deliver_to_location             VARCHAR2(40),
 deliver_to_address1             VARCHAR2(240),
 deliver_to_address2             VARCHAR2(240),
 deliver_to_address3             VARCHAR2(240),
 deliver_to_address4             VARCHAR2(246),
/*1621182*/
 deliver_to_address5             VARCHAR2(246),
/*1621182*/
 deliver_to_contact              oe_contacts_v.name%type,	--Bug#9241636
 agreement                       VARCHAR2(240),
 source_document_type            VARCHAR2(240),
 arrival_set                     VARCHAR2(30),
 ship_set                        VARCHAR2(30),
 commitment                      VARCHAR2(20),
 ship_to_customer_id             NUMBER,
 invoice_to_customer_id          NUMBER,
 hold_exists_flag                VARCHAR2(1),
/*1931163*/
 cascaded_hold_exists_flag       VARCHAR2(1),
 Calculate_Price_Descr           Varchar2(80),
 booking_id                      NUMBER,
 ota_name                        Varchar2(80),
 reserved_quantity               NUMBER,
 fulfillment_list              Varchar2(2000),
 subtotal                      Number,
 discount                      Number,
 charges                       Number,
 line_charges                  Number,
 tax                           Number,
 svc_header_id                 Number,
 Order_source                  Varchar2(240),
 Order_source_ref              NUMBER,
 Order_source_line_ref         NUMBER,
 inventory_item                VARCHAR2(2000),    -- Changed the width from 30 to 2000 for the bug #3087989
 commitment_applied_amount    NUMBER,
 payment_level_code           VARCHAR2(30),
 deliver_to_customer_id       NUMBER,
 deliver_To_Customer_Name     VARCHAR2(360),
 deliver_To_Customer_Number   VARCHAR2(60),
 Original_Ordered_item        VARCHAR2(2000),
 Original_inventory_item      VARCHAR2(2000),
 Original_item_type           VARCHAR2(240),
 item_relationship_type_dsp   VARCHAR2(240),
--MRG BGN
 margin                       NUMBER,
 margin_percent               NUMBER,
--MRG END
 blanket_agreement_name       VARCHAR2(240),
--retro{
 Retro_Order_Number             NUMBER,
 Retro_Line_Number              NUMBER,
 Retro_Shipment_Number          NUMBER,
 Retro_Option_Number            NUMBER,
 retrobilled_price            NUMBER,
 Retro_Service_Number	      NUMBER,
 Retro_Component_Number       NUMBER,
--retro}
end_customer_contact VARCHAR(240),
end_customer_name         VARCHAR(240),
end_customer_number VARCHAR(240),
end_customer_site_location             VARCHAR2(240),
end_customer_site_address1    VARCHAR2(240),
end_customer_site_address2          VARCHAR2(240),
end_customer_site_address3             VARCHAR2(240),
end_customer_site_address4             VARCHAR2(240),
end_customer_site_city               varchar2(240),
end_customer_site_state               varchar2(240),
end_customer_site_postal_code               varchar2(240),
end_customer_site_country               varchar2(240),
--Macd
instance_name                           VARCHAR2(255),
ib_owner_dsp                            VARCHAR2(60),
ib_current_location_dsp                 VARCHAR2(60),
ib_installed_at_location_dsp            VARCHAR2(60),
--recurring charges
charge_periodicity                 VARCHAR2(25),
service_reference_type                  varchar2(240),  --3557382
service_period_dsp                      varchar2(240),   --3605052
--datafix begin
message_exists_flag          VARCHAR2(1),
--datafix end
charge_periodicity_dsp       VARCHAR2(25),
reserved_quantity2			                NUMBER -- INVCONV
--Customer Acceptance
,CONTINGENCY_NAME            VARCHAR2(80)
,CONTINGENCY_DESCRIPTION     VARCHAR2(240)
,EXPIRATION_EVENT_ATTRIBUTE  VARCHAR2(80)
,REVREC_EVENT                VARCHAR2(80)
,ACCEPTED_BY_DSP             VARCHAR2(100)

 );

-- OPM 02/JUN/00
TYPE Process_Controls_Rec_Type IS RECORD

(
--   dualum_ind                 NUMBER INVCONV
--,   grade_ctl                  NUMBER INVCONV
    process_warehouse_flag     VARCHAR2(1)
--,   ont_pricing_qty_source     NUMBER   --OPM 2046190
,     ont_pricing_qty_source   VARCHAR2(30) -- INVCONV
,   grade_control_flag				 VARCHAR2(1) -- INVCONV
,   tracking_quantity_ind      VARCHAR2(30) -- INVCONV
,   secondary_default_ind      VARCHAR2(30) -- INVCONV
,   lot_divisible_flag			   VARCHAR2(1) -- INVCONV
,   lot_control_code           NUMBER   -- 4172680 INVCONV
);


-- OPM 02/JUN/00 END

PROCEDURE POPULATE_CONTROL_FIELDS
(
 p_line_rec                         IN Line_Rec_Type,
 x_line_val_rec OUT NOCOPY Line_val_rec_type ,
 p_calling_block IN  VARCHAR2
 );

-- OPM 02/JUN/00 overloaded proc below for process features
 PROCEDURE POPULATE_CONTROL_FIELDS
(
 p_line_rec                         IN Line_Rec_Type,
 x_line_val_rec OUT NOCOPY Line_val_rec_type,
 p_calling_block        IN  VARCHAR2,
 x_process_controls_rec OUT NOCOPY process_controls_rec_type
 );
 -- OPM 02/JUN/00 END

FUNCTION Is_Description_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_description           IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2;


/* 2913927 - 3348159 start */
FUNCTION Is_Internal_Item_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_inventory_item        IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2;
/* 2913927 - 3348159 end */

/*1477598*/
FUNCTION Is_Item_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_item                  IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2;
/*1477598*/

TYPE Split_Line_Rec_Type IS RECORD
  (
   line_id     NUMBER,
   ordered_quantity    NUMBER,
   ordered_quantity2    NUMBER,   /* OPM  - NC 3/8/02 Bug#2046641 */
   ship_to_org_id NUMBER,
   request_date  DATE,
   ship_from_org_id NUMBER
   );
TYPE Split_Line_Tbl_Type IS TABLE OF Split_Line_Rec_Type
      INDEX BY BINARY_INTEGER;



PROCEDURE SPLIT_LINE
(
 p_split_by      IN  VARCHAR2 DEFAULT null
,x_line_tbl_type IN  split_line_tbl_type
,p_change_reason_code   IN  VARCHAR2 DEFAULT NULL
,p_change_comments IN VARCHAR2 DEFAULT NULL
,x_return_status OUT NOCOPY VARCHAR2
,x_msg_count OUT NOCOPY NUMBER
,x_msg_data OUT NOCOPY VARCHAR2
);

Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                     IN  NUMBER
);

PROCEDURE Ship_To_Customer_Id(
                              p_ship_to_org_id IN Number,
x_ship_to_Customer_id OUT NOCOPY Number
                              );

PROCEDURE Invoice_To_Customer_Id(
                              p_invoice_to_org_id IN Number,
x_invoice_to_Customer_id OUT NOCOPY Number
                              );

PROCEDURE Get_line
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
,   x_line_rec                      OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);

PROCEDURE GET_LINE_SHIPMENT_NUMBER
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                                 ,   p_header_id                     IN  Number
, x_line_id OUT NOCOPY Number
, x_line_number OUT NOCOPY Number
, x_shipment_number OUT NOCOPY Number
                                 );


/* --- Bug 1823073 start --------*/
-- Added this procedure Get_Ordered_Item to provide ordered_item
-- and fix the problem cauesd by null ordered_item
-- This procedure is called from OEXOELIN.pld
PROCEDURE GET_ORDERED_ITEM
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                                 ,   p_item_identifier_type          IN VARCHAR2
                                 ,   p_inventory_item_id             IN Number
                                 ,   p_ordered_item_id               IN Number
                                 ,   p_sold_to_org_id                IN Number
, x_ordered_item OUT NOCOPY VARCHAR2
                                 );
/* --- Bug 1823073 end --------*/


-- Bug 1713035
-- Added this procedure to reduce the number
-- of calls to server side packages while deleting
-- all the adjustments related to a line.
-- This procedure is called from OEXOELIN.pld

PROCEDURE Delete_Adjustments(x_line_id IN NUMBER);


TYPE Line_Dff_Rec_Type IS RECORD
(
    attribute1                    VARCHAR2(240)
,   attribute10                   VARCHAR2(240)
,   attribute11                   VARCHAR2(240)
,   attribute12                   VARCHAR2(240)
,   attribute13                   VARCHAR2(240)
,   attribute14                   VARCHAR2(240)
,   attribute15                   VARCHAR2(240)
,   attribute16                   VARCHAR2(240)     --For bug 2184255
,   attribute17                   VARCHAR2(240)
,   attribute18                   VARCHAR2(240)
,   attribute19                   VARCHAR2(240)
,   attribute2                    VARCHAR2(240)
,   attribute20                   VARCHAR2(240)
,   attribute3                    VARCHAR2(240)
,   attribute4                    VARCHAR2(240)
,   attribute5                    VARCHAR2(240)
,   attribute6                    VARCHAR2(240)
,   attribute7                    VARCHAR2(240)
,   attribute8                    VARCHAR2(240)
,   attribute9                    VARCHAR2(240)
,   context                       VARCHAR2(30)
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
,   TP_CONTEXT                    VARCHAR2(30)
,   TP_ATTRIBUTE1                 VARCHAR2(240)
,   TP_ATTRIBUTE2                 VARCHAR2(240)
,   TP_ATTRIBUTE3                 VARCHAR2(240)
,   TP_ATTRIBUTE4                 VARCHAR2(240)
,   TP_ATTRIBUTE5                 VARCHAR2(240)
,   TP_ATTRIBUTE6                 VARCHAR2(240)
,   TP_ATTRIBUTE7                 VARCHAR2(240)
,   TP_ATTRIBUTE8                 VARCHAR2(240)
,   TP_ATTRIBUTE9                 VARCHAR2(240)
,   TP_ATTRIBUTE10                VARCHAR2(240)
,   TP_ATTRIBUTE11                VARCHAR2(240)
,   TP_ATTRIBUTE12                VARCHAR2(240)
,   TP_ATTRIBUTE13                VARCHAR2(240)
,   TP_ATTRIBUTE14                VARCHAR2(240)
,   TP_ATTRIBUTE15                VARCHAR2(240)
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

);

-- for 5331980 start
PROCEDURE reset_calculate_line_total;
-- for 5331980 end

END oe_oe_form_line;



/

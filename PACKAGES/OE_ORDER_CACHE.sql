--------------------------------------------------------
--  DDL for Package OE_ORDER_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_CACHE" AUTHID CURRENT_USER AS
/* $Header: OEXUCCHS.pls 120.6.12010000.1 2008/07/25 07:55:00 appldev ship $ */

--  Order Type record type.

Type Enforce_list_price_rec_type is Record
(
	Line_Type_id				Number
	,header_id				Number
	,enforce_line_prices_flag	Varchar2(1)
);

g_Enforce_list_price_rec		Enforce_list_price_rec_Type;

TYPE Order_Type_Rec_Type IS RECORD
(   order_type_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   name                    VARCHAR2(80)    :=	FND_API.G_MISS_CHAR
,   cust_trx_type_id        NUMBER          :=  FND_API.G_MISS_NUM
,   invoicing_rule_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   accounting_rule_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   shipment_priority_code  VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   fob_point_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   ship_from_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   agreement_type_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   order_number_source_id  NUMBER	    :=	FND_API.G_MISS_NUM
,   agreement_required_flag VARCHAR2(1)     := FND_API.G_MISS_CHAR
,   require_po_flag	    VARCHAR2(1)     := FND_API.G_MISS_CHAR
,   enforce_line_prices_flag VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   auto_scheduling_flag    VARCHAR2(1)     := FND_API.G_MISS_CHAR
-- QUOTING changes
,   quote_num_as_ord_num_flag  VARCHAR2(1)  := FND_API.G_MISS_CHAR
,   invoice_source_id       NUMBER          := FND_API.G_MISS_NUM
,   non_delivery_invoice_source_id  NUMBER  := FND_API.G_MISS_NUM
-- bug 4200055
,   start_date_active        DATE           := FND_API.G_MISS_DATE
,   end_date_active          DATE           := FND_API.G_MISS_DATE
,   tax_calculation_event_code VARCHAR2(30) := FND_API.G_MISS_CHAR
);

TYPE Tax_Code_Cach IS RECORD(
   ship_to_org_id           NUMBER          := FND_API.G_MISS_NUM
,  invoice_to_org_id        NUMBER          := FND_API.G_MISS_NUM
,  inventory_item_id        NUMBER          := FND_API.G_MISS_NUM
,  ship_from_org_id         NUMBER          := FND_API.G_MISS_NUM
,  sold_to_org_id           NUMBER          := FND_API.G_MISS_NUM
,  tax_date                 DATE            := fnd_api.g_miss_date
,  trx_type_id              NUMBER          := FND_API.G_MISS_NUM
,  tax_code                 VARCHAR2(50)    := FND_API.G_MISS_CHAR
,  tax_exempt_number        VARCHAR2(80)    := FND_API.G_MISS_CHAR
,  tax_exempt_reason_code   VARCHAR2(80)    := FND_API.G_MISS_CHAR
,  vat_tax_id               NUMBER          := FND_API.G_MISS_NUM
,  amt_incl_tax_flag        VARCHAR2(1)     := FND_API.G_MISS_CHAR
,  amt_incl_tax_override    VARCHAR2(1)     := FND_API.G_MISS_CHAR
);

g_TAX_CODE_CACH            Tax_Code_Cach;
g_TAX_EXEMPTION_CACH       Tax_Code_Cach;


--  Line Type record type.

TYPE Line_Type_Rec_Type IS RECORD
(   Line_Type_id	    NUMBER	    := FND_API.G_MISS_NUM
,   name                    VARCHAR2(80)    := FND_API.G_MISS_CHAR
,   cust_trx_type_id        NUMBER          := FND_API.G_MISS_NUM
,   invoicing_rule_id	    NUMBER          := FND_API.G_MISS_NUM
,   accounting_rule_id	    NUMBER          := FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    := FND_API.G_MISS_NUM
,   shipment_priority_code  VARCHAR2(30)    := FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    := FND_API.G_MISS_CHAR
,   fob_point_code	    VARCHAR2(30)    := FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    := FND_API.G_MISS_CHAR
,   ship_from_org_id	    NUMBER	    := FND_API.G_MISS_NUM
,   agreement_type_code	    VARCHAR2(30)    := FND_API.G_MISS_CHAR
,   agreement_required_flag	VARCHAR2(1) := FND_API.G_MISS_CHAR
,   enforce_line_prices_flag	VARCHAR2(1) := FND_API.G_MISS_CHAR
,   calculate_tax_flag          VARCHAR2(1) := FND_API.G_MISS_CHAR
,   order_category_code        VARCHAR2(30) := FND_API.G_MISS_CHAR
,   ship_source_type_code      VARCHAR2(30) := FND_API.G_MISS_CHAR
,   invoice_source_id       NUMBER          := FND_API.G_MISS_NUM
,   non_delivery_invoice_source_id  NUMBER  := FND_API.G_MISS_NUM
--added for bug 4200055
,   start_date_active        DATE           := FND_API.G_MISS_DATE
,   end_date_active          DATE           := FND_API.G_MISS_DATE
,   tax_calculation_event_code VARCHAR2(30) := FND_API.G_MISS_CHAR
);

--  Agreement record type.

TYPE Agreement_Rec_Type IS RECORD
(   agreement_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoicing_rule_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   accounting_rule_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   cust_po_number	    VARCHAR2(50)    :=	FND_API.G_MISS_CHAR
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoice_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoice_to_contact_id   NUMBER	    :=	FND_API.G_MISS_NUM
,   agreement_type_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   sold_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
);

--  Ship To record type

TYPE Ship_To_Org_Rec_Type IS RECORD
(   org_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   fob_point_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   sold_from_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_from_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoice_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   contact_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_partial_allowed    VARCHAR2(1)     :=	FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
);

--  Invoice To record type

TYPE Invoice_To_Org_Rec_Type IS RECORD
(   org_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   fob_point_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   contact_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_partial_allowed    VARCHAR2(1)    :=	FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
-- addded for bug 4200055
,   status                  VARCHAR2(1)     :=  FND_API.G_MISS_CHAR
,   address_status          VARCHAR2(1)     :=  FND_API.G_MISS_CHAR
,   start_date_active       DATE            :=  FND_API.G_MISS_DATE
,   end_date_active       DATE            :=  FND_API.G_MISS_DATE
);

--  Deliver To record type

TYPE Deliver_To_Org_Rec_Type IS RECORD
(   org_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   fob_point_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   sold_from_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_from_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoice_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   contact_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_partial_allowed    VARCHAR2(1)    :=	FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
);

--  Sold To record type

TYPE Sold_To_Org_Rec_Type IS RECORD
(   org_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   fob_point_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   deliver_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   invoice_to_org_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   contact_id		    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_partial_allowed    VARCHAR2(1)     :=	FND_API.G_MISS_CHAR
,   shipping_method_code    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   order_type_id	    NUMBER	    :=  FND_API.G_MISS_NUM
,   sold_to_org_id          NUMBER          :=  FND_API.G_MISS_NUM    -- MOAC Changes
);

--  Price List record type

TYPE Price_List_Rec_Type IS RECORD
(   price_list_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   freight_terms_code	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   payment_term_id 	    NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_method_code        VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   currency_code	    VARCHAR2(15)    :=	FND_API.G_MISS_CHAR
-- added for bug 4200055
,   name                    VARCHAR2(240)   :=	FND_API.G_MISS_CHAR
,   list_type_code 	    VARCHAR2(30)    :=	FND_API.G_MISS_CHAR
,   active_flag 	    VARCHAR2(1)     :=	FND_API.G_MISS_CHAR
,   start_date_active       DATE            :=  FND_API.G_MISS_DATE
,   end_date_active         DATE            :=  FND_API.G_MISS_DATE
);

--  Set_Of_Books record type

TYPE Set_Of_Books_Rec_Type IS RECORD
(   set_of_books_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   currency_code	    VARCHAR2(15)    :=	FND_API.G_MISS_CHAR
);

--  Item record type
--  OPM 02/JUN/00 - Add process control chatacteristics for dual um and grade

TYPE Item_Rec_Type IS RECORD
(   inventory_item_id	       NUMBER	    :=	FND_API.G_MISS_NUM
,   organization_id	       NUMBER	    :=	FND_API.G_MISS_NUM
,   invoicing_rule_id	       NUMBER	    :=	FND_API.G_MISS_NUM
,   accounting_rule_id	       NUMBER	    :=	FND_API.G_MISS_NUM
,   default_shipping_org       NUMBER	    :=	FND_API.G_MISS_NUM
,   ship_model_complete_flag   VARCHAR2(1)  :=  FND_API.G_MISS_CHAR
,   build_in_wip_flag	       VARCHAR2(1)  :=  FND_API.G_MISS_CHAR
,   bom_item_type             NUMBER        :=  FND_API.G_MISS_NUM
,   replenish_to_order_flag    VARCHAR2(1)  :=  FND_API.G_MISS_CHAR
,   primary_uom_code	       VARCHAR2(30) :=	FND_API.G_MISS_CHAR
,   pick_components_flag       VARCHAR2(1)  :=  FND_API.G_MISS_CHAR
,   shippable_item_flag        VARCHAR2(1)  :=  FND_API.G_MISS_CHAR
,   service_item_flag          VARCHAR2(1)  := FND_API.G_MISS_CHAR
--,   dualum_ind                 NUMBER       := FND_API.G_MISS_NUM    --INVCONV -
--,   grade_ctl                  NUMBER       := FND_API.G_MISS_NUM    --INVCONV--
--,   opm_item_um                VARCHAR2(4)  := FND_API.G_MISS_CHAR   --INVCONV -
--,   opm_item_um2               VARCHAR2(4)  := FND_API.G_MISS_CHAR   --INVCONV-
--,   opm_item_id                NUMBER       := FND_API.G_MISS_NUM    --INVCONV-
,   process_warehouse_flag     VARCHAR2(1)  := FND_API.G_MISS_CHAR    --OPM
--,   ont_pricing_qty_source   NUMBER       := FND_API.G_MISS_NUM      --INVCONV OPM 2046190
,   ont_pricing_qty_source     VARCHAR2(30) := FND_API.G_MISS_CHAR     --INVCONV
-- Pack J catchweight
,   tracking_quantity_ind      VARCHAR2(30) := FND_API.G_MISS_CHAR
,  wms_enabled_flag            VARCHAR2(1)  := FND_API.G_MISS_CHAR
,  secondary_uom_code          VARCHAR2(3)  := FND_API.G_MISS_CHAR
-- bug 4171642
    ,  master_org_id               NUMBER       := FND_API.G_MISS_NUM
     ,  customer_order_enabled_flag  VARCHAR2(1) := FND_API.G_MISS_CHAR
     ,  internal_order_enabled_flag  VARCHAR2(1) := FND_API.G_MISS_CHAR
     , returnable_flag               VARCHAR2(1) := FND_API.G_MISS_CHAR
     , restrict_subinventories_code  NUMBER      := FND_API.G_MISS_NUM
     , indivisible_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR
-- bug 4171642

-- INVCONV start
,  secondary_default_ind 			VARCHAR2(30)  := FND_API.G_MISS_CHAR
,  lot_divisible_flag 				VARCHAR2(1)   := FND_API.G_MISS_CHAR
,  grade_control_flag 				VARCHAR2(1)   := FND_API.G_MISS_CHAR
,  lot_control_code     			NUMBER    := FND_API.G_MISS_NUM
-- INVCONV end


);


--  Item-Org record type

TYPE Item_Cost_Rec_Type IS RECORD
(   inventory_item_id	    NUMBER	    :=	FND_API.G_MISS_NUM
,   organization_id	    NUMBER	    :=  FND_API.G_MISS_NUM
,   material_cost	    NUMBER	    :=	FND_API.G_MISS_NUM
,   material_overhead_cost  NUMBER	    :=	FND_API.G_MISS_NUM
,   resource_cost	    NUMBER	    :=	FND_API.G_MISS_NUM
,   outside_processing_cost NUMBER	    :=	FND_API.G_MISS_NUM
,   overhead_cost	    NUMBER	    :=	FND_API.G_MISS_NUM
);


TYPE Discount_Rec_Type IS RECORD
  (
   adjustment_name		VARCHAR2(200)	:= fnd_api.g_miss_char,
   discount_id			NUMBER		:= fnd_api.g_miss_num,
   discount_line_id		NUMBER		:= fnd_api.g_miss_num,
   percent			NUMBER		:= fnd_api.g_miss_num,
   amount			NUMBER		:= fnd_api.g_miss_num,
   price_adjustment_id		NUMBER		:= fnd_api.g_miss_num
   );


TYPE Set_Rec_Type IS RECORD
 (
  SET_ID			NUMBER		:= fnd_api.g_miss_num
, SET_NAME			VARCHAR2(30)	:= fnd_api.g_miss_char
, SET_TYPE			VARCHAR2(30)	:= fnd_api.g_miss_char
, Header_Id			NUMBER		:= fnd_api.g_miss_num
, Ship_from_org_id		NUMBER		:= fnd_api.g_miss_num
, Ship_to_org_id		NUMBER		:= fnd_api.g_miss_num
, Schedule_Ship_Date		DATE		:= fnd_api.g_miss_date
, Schedule_Arrival_Date		DATE		:= fnd_api.g_miss_date
, shipment_priority_code       varchar2(30)     := fnd_api.g_miss_char
, Freight_Carrier_Code		VARCHAR2(30)	:= fnd_api.g_miss_char
, Shipping_Method_Code		VARCHAR2(30)	:= fnd_api.g_miss_char
, Set_Status		        VARCHAR2(1)	:= fnd_api.g_miss_char
);

TYPE Modifiers_Rec_Type IS RECORD
(   arithmetic_operator           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   automatic_flag                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   base_qty                      NUMBER         := FND_API.G_MISS_NUM
,   base_uom_code                 VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   inventory_item_id             NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   list_line_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   modifier_level_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   operand                       NUMBER         := FND_API.G_MISS_NUM
,   organization_id               NUMBER         := FND_API.G_MISS_NUM
,   override_flag                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   percent_price                 NUMBER         := FND_API.G_MISS_NUM
,   price_break_type_code         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   price_by_formula_id           NUMBER         := FND_API.G_MISS_NUM
,   primary_uom_flag              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   print_on_invoice_flag         VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   rebate_transaction_type_code         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   related_item_id               NUMBER         := FND_API.G_MISS_NUM
,   relationship_type_id          NUMBER         := FND_API.G_MISS_NUM
,   substitution_attribute        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   substitution_context          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   substitution_value            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   accrual_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   pricing_group_sequence        NUMBER         := FND_API.G_MISS_NUM
,   incompatibility_grp_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   list_line_no                  VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_phase_id              NUMBER         := FND_API.G_MISS_NUM
,   product_precedence            NUMBER         := FND_API.G_MISS_NUM
,   expiration_date               DATE           := FND_API.G_MISS_DATE
,   charge_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   charge_subtype_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   benefit_qty                   NUMBER         := FND_API.G_MISS_NUM
,   benefit_uom_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   accrual_conversion_rate       NUMBER         := FND_API.G_MISS_NUM
,   proration_type_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,	include_on_returns_flag		 VARCHAR2(1)   := FND_API.G_MISS_CHAR
);

Type Cust_Trx_Rec_Type is Record
(
	cust_trx_type_id	Number        := FND_API.G_MISS_NUM
,	tax_calculation_flag	Varchar2(1)   := FND_API.G_MISS_CHAR
,	org_id			NUMBER	      := FND_API.G_MISS_NUM   -- MOAC Changes
);

Type Tax_Calc_Rec_Type is Record
(
      line_type_id                                  Number,
      cust_trx_type_id                              Number,
      tax_calculation_flag                      Varchar2(1)
);

TYPE Tax_Calc_Tbl_Type IS TABLE OF Tax_Calc_Rec_Type
    INDEX BY BINARY_INTEGER;

-- begin bug 4200055
TYPE Payment_Term_Rec_Type IS RECORD (
 TERM_ID          Number       := FND_API.G_MISS_NUM
,NAME             Varchar2(15) := FND_API.G_MISS_CHAR
,START_DATE_ACTIVE DATE        := FND_API.G_MISS_DATE
,END_DATE_ACTIVE  DATE         := FND_API.G_MISS_DATE
);

g_payment_term_rec Payment_Term_rec_type ;
G_MISS_PAYMENT_TERM_REC Payment_Term_Rec_Type ;

FUNCTION Load_Payment_term
(   p_key       IN NUMBER )
RETURN Payment_Term_Rec_Type;


TYPE Salesrep_Rec_Type IS RECORD (
 SALESREP_ID      Number       := FND_API.G_MISS_NUM
,NAME             Varchar2(240):= FND_API.G_MISS_CHAR
,STATUS           Varchar2(30) := FND_API.G_MISS_CHAR
,START_DATE_ACTIVE DATE        := FND_API.G_MISS_DATE
,END_DATE_ACTIVE  DATE         := FND_API.G_MISS_DATE
);

g_salesrep_rec Salesrep_rec_type ;
G_MISS_SALESREP_REC  Salesrep_Rec_Type ;

FUNCTION Load_Salesrep_rec
(   p_key       IN NUMBER )
RETURN Salesrep_Rec_Type;

-- end bug 4200055

--  Global variable representing missing variables of the types defined above.
--  line and adjustment records

    G_MISS_ORDER_TYPE_REC	Order_Type_Rec_Type	;
    G_MISS_AGREEMENT_REC	Agreement_Rec_Type	;
    G_MISS_SHIP_TO_REC		Ship_To_Org_Rec_Type	;
    G_MISS_INVOICE_TO_REC	Invoice_To_Org_Rec_Type 	;
    G_MISS_DELIVER_TO_REC	Deliver_To_Org_Rec_Type 	;
    G_MISS_SOLD_TO_REC		Sold_To_Org_Rec_Type	;
    G_MISS_PRICE_LIST_REC	Price_List_Rec_Type	;
    G_MISS_SET_OF_BOOKS_REC	Set_Of_Books_Rec_Type	;
    G_MISS_ITEM_REC		Item_Rec_Type		;
    G_MISS_ITEM_COST_REC	Item_Cost_Rec_Type 	;
    G_MISS_DISCOUNT_REC		Discount_Rec_Type	;
    G_MISS_CUST_TRX_TYPE_REC    Cust_Trx_Rec_Type       ;
    G_CUST_TRX_LINE_TYPE_ID     NUMBER := FND_API.G_MISS_NUM;


-- aksingh making this record visible for all apis
g_header_rec	    		OE_Order_PUB.Header_Rec_Type;

------------------------------------------------------------
-- Bug 1929163: Move global record types to specs so that
-- values can be accessed directly by all apis
------------------------------------------------------------

g_order_type_rec    	Order_Type_Rec_Type;
g_line_type_rec    		line_Type_Rec_Type;
g_agreement_rec    		Agreement_Rec_Type;
g_ship_to_rec	    		Ship_To_Org_Rec_Type;
g_invoice_to_rec    	Invoice_To_Org_Rec_Type;
g_deliver_to_rec    	Deliver_To_Org_Rec_Type;
g_sold_to_rec	    		Sold_To_Org_Rec_Type;
g_price_list_rec    	Price_List_Rec_Type;
g_set_of_books_rec  	Set_Of_Books_Rec_Type;
g_item_rec	    		Item_Rec_Type;
g_item_cost_rec	    	Item_Cost_Rec_Type;
g_hdr_discount_rec		Discount_rec_type;
g_line_discount_rec		Discount_rec_type;
g_top_model_line_rec    	OE_Order_PUB.Line_Rec_Type;
g_Modifiers_Rec		Modifiers_Rec_Type;
g_cust_trx_rec          Cust_Trx_Rec_Type;

-- Global Records holding the set information
g_set_rec   	        	set_rec_type;
g_delivery_set_rec      	set_rec_type;
g_invoice_set_rec       	set_rec_type;
g_ship_set_rec          	set_rec_type;
g_fullfillment_set_rec  	set_rec_type;

-- Global records holding the tax calculation information
g_tax_calc_rec                  Tax_Calc_Rec_Type;
g_tax_calc_tbl                  Tax_Calc_Tbl_Type;

--
-- Globals to cahce if each flex is enabled or not.
-- Header Flex
g_hdr_desc_flex varchar2(1);
g_hdr_glb_flex varchar2(1);
g_hdr_tp_flex varchar2(1);
g_hdr_blkt_desc_flex varchar2(1);

-- Line flex
g_line_desc_flex varchar2(1);
g_line_glb_flex varchar2(1);
g_line_ind_flex varchar2(1);
g_line_tp_flex varchar2(1);
g_line_Ret_flex varchar2(1);
g_line_prc_flex varchar2(1);
g_line_blkt_desc_flex varchar2(1);

--  Procedures that load cached entities.
--  Overload load_order_type
PROCEDURE Load_Order_Type
(p_key   IN NUMBER );

FUNCTION Load_Order_Type
(   p_key	IN NUMBER )
RETURN Order_Type_Rec_Type;

------------------------------------------------------------
-- Bug 1929163: overload load_line_type so that it can
-- be accessed both as a function and as a procedure
------------------------------------------------------------
PROCEDURE Load_Line_Type
(   p_key       IN NUMBER );

FUNCTION Load_Line_Type
(   p_key	IN NUMBER )
RETURN Line_Type_Rec_Type;

FUNCTION Load_Agreement
(   p_key	IN NUMBER )
RETURN Agreement_Rec_Type;

FUNCTION Load_Ship_To_Org
(   p_key	IN NUMBER )
RETURN Ship_To_Org_Rec_Type;

FUNCTION Load_Invoice_To_Org
(   p_key	IN NUMBER )
RETURN Invoice_to_Org_Rec_Type;

FUNCTION Load_Deliver_To_Org
(   p_key	IN NUMBER )
RETURN Deliver_To_Org_Rec_Type;

FUNCTION Load_Sold_To_Org
(   p_key	IN NUMBER )
RETURN Sold_To_Org_Rec_Type;

FUNCTION Load_Price_List
(   p_key	IN NUMBER )
RETURN Price_List_Rec_Type;

FUNCTION Load_Set_Of_Books
RETURN Set_Of_Books_Rec_Type;

------------------------------------------------------------
-- Bug 1929163: overload load_item so that it can be accessed
-- both as a function and as a procedure
------------------------------------------------------------
PROCEDURE Load_Item
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER := FND_API.G_MISS_NUM
,   p_key3      IN NUMBER DEFAULT NULL
 );

FUNCTION Load_Item
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER := FND_API.G_MISS_NUM
,   p_key3      IN NUMBER DEFAULT NULL)
RETURN Item_Rec_Type;

FUNCTION Load_Item_Cost
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER )
RETURN Item_Cost_Rec_Type;

------------------------------------------------------------
-- Bug 1929163: overload load_top_model_line so that it can
-- be accessed both as a function and as a procedure
------------------------------------------------------------
PROCEDURE Load_Order_Header
(   p_key       IN NUMBER );

FUNCTION Load_Order_Header
(   p_key	IN NUMBER )
RETURN OE_Order_PUB.Header_Rec_Type;

FUNCTION load_header_discount
 ( p_hdr_adj_rec	IN oe_order_pub.header_adj_rec_type)
RETURN OE_ORDER_PUB.HEADER_ADJ_REC_TYPE;

FUNCTION load_line_discount
 ( p_line_adj_rec	IN oe_order_pub.line_adj_rec_type)
RETURN OE_ORDER_PUB.LINE_ADJ_REC_TYPE;

------------------------------------------------------------
-- Bug 1929163: overload load_top_model_line so that it can
-- be accessed both as a function and as a procedure
------------------------------------------------------------
PROCEDURE Load_Top_Model_Line
(   p_key       IN NUMBER );

FUNCTION Load_Top_Model_Line
(   p_key       IN NUMBER)
RETURN OE_Order_PUB.Line_Rec_Type;

FUNCTION Load_Set
(   p_set_id	IN NUMBER)
RETURN set_rec_type;

--  procedures that clear cached entities.

PROCEDURE Clear_All;

PROCEDURE Clear_Order_Type;

PROCEDURE Clear_Agreement;

PROCEDURE Clear_Ship_To_Org;

PROCEDURE Clear_Invoice_To_Org;

PROCEDURE Clear_Deliver_To_Org;

PROCEDURE Clear_Sold_To_Org;

PROCEDURE Clear_Price_List;

PROCEDURE Clear_Set_Of_Books;

PROCEDURE Clear_Item;

PROCEDURE Clear_Top_Model_Line(p_key  IN NUMBER);

PROCEDURE Clear_Item_Cost;

PROCEDURE Set_Order_Header
(
  p_header_rec IN OE_ORDER_PUB.Header_Rec_Type
);

PROCEDURE Clear_Order_Header;

PROCEDURE Clear_Discount;

--added for bug 4200055
PROCEDURE Clear_Salesrep ;
PROCEDURE Clear_Payment_Term ;
--end bug 4200055

FUNCTION GET_SET_OF_BOOKS
RETURN NUMBER;

FUNCTION Load_List_Lines
(   p_key	IN NUMBER )
RETURN Modifiers_Rec_Type;

procedure Enforce_List_price
(   p_header_id	number
,	p_Line_Type_id		Number
);

FUNCTION Load_Cust_Trx_Type
(   p_key       IN NUMBER )
RETURN Cust_Trx_Rec_Type;

Procedure Load_Cust_Trx_Type
(   p_key       IN NUMBER );

FUNCTION get_tax_calculation_flag
(   p_key	IN NUMBER,
    p_line_rec  IN OE_ORDER_PUB.Line_Rec_Type )
RETURN Tax_Calc_Rec_Type;

FUNCTION IS_FLEX_ENABLED(p_flex_name IN VARCHAR2)
RETURN VARCHAR2 ;

FUNCTION LOAD_FLEX_ENABLED_FLAG(p_flex_name VARCHAR2)
RETURN VARCHAR2;


END OE_Order_Cache;

/

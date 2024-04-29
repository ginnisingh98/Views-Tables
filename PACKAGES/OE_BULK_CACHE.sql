--------------------------------------------------------
--  DDL for Package OE_BULK_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_CACHE" AUTHID CURRENT_USER AS
/* $Header: OEBUCCHS.pls 120.1.12010000.4 2008/11/26 01:50:32 smusanna ship $ */


---------------------------------------------------------------------
-- CACHE RECORD/TABLE TYPES
---------------------------------------------------------------------

TYPE Order_Type_Rec_Type IS RECORD
(   order_type_id           NUMBER
,   name                    VARCHAR2(30)
,   order_category_code     VARCHAR2(30)
,   agreement_type_code     VARCHAR2(30)
,   order_number_source_id  NUMBER
,   agreement_required_flag VARCHAR2(1)
,   require_po_flag         VARCHAR2(1)
,   enforce_line_prices_flag VARCHAR2(1)
,   entry_credit_check_rule_id  NUMBER
,   start_date_active       DATE
,   end_date_active         DATE
,   invoicing_rule_id       NUMBER
,   accounting_rule_id      NUMBER
,   price_list_id           NUMBER
,   shipment_priority_code  VARCHAR2(30)
,   shipping_method_code    VARCHAR2(30)
,   fob_point_code          VARCHAR2(30)
,   freight_terms_code      VARCHAR2(30)
,   demand_class_code       VARCHAR2(30)
,   ship_from_org_id        NUMBER
,   default_outbound_line_type_id      NUMBER
,   conversion_type_code    VARCHAR2(30)
,   tax_calculation_event   VARCHAR2(30)
,   auto_scheduling_flag    VARCHAR2(1)
,   scheduling_level_code   VARCHAR2(30)
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
,   quick_cr_check_flag     VARCHAR2(1)  DEFAULT 'N'
,   tax_calculation_flag    VARCHAR2(1)
,   cust_trx_type_id        NUMBER
);

TYPE Line_Type_Rec_Type IS RECORD
(   line_type_id            NUMBER
,   order_category_code     VARCHAR2(30)
,   start_date_active       DATE
,   end_date_active         DATE
,   cust_trx_type_id        NUMBER
,   tax_calculation_flag      VARCHAR2(1)
,   scheduling_level_code   VARCHAR2(30)
);

TYPE Agreement_Rec_Type IS RECORD
(   agreement_id            NUMBER
,   name                    VARCHAR2(240)
,   start_date_active       DATE
,   end_date_active         DATE
,   revision                VARCHAR2(50)
,   sold_to_org_id          NUMBER
,   price_list_id           NUMBER
,   invoicing_rule_id       NUMBER
,   accounting_rule_id      NUMBER
,   payment_term_id         NUMBER
,   salesrep_id             NUMBER
,   cust_po_number          VARCHAR2(50)
,   invoice_to_contact_id   NUMBER
,   invoice_to_org_id       NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
);

TYPE Ship_To_Rec_Type IS RECORD
(   ship_to_org_id          NUMBER
,   customer_id             NUMBER
,   order_type_id           NUMBER
,   ship_tolerance_above    NUMBER
,   ship_tolerance_below    NUMBER
,   latest_schedule_limit   NUMBER
,   order_date_type_code    VARCHAR2(30)
,   fob_point_code          VARCHAR2(30)
,   freight_terms_code      VARCHAR2(30)
,   demand_class_code       VARCHAR2(30)
,   ship_from_org_id        NUMBER
,   payment_term_id         NUMBER
,   shipping_method_code    VARCHAR2(30)
,   item_identifier_type    VARCHAR2(30)
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);

TYPE Invoice_To_Rec_Type IS RECORD
(   invoice_to_org_id       NUMBER
,   customer_id             NUMBER
,   order_type_id           NUMBER
,   price_list_id           NUMBER
,   payment_term_id         NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);

TYPE Sold_To_Rec_Type IS RECORD
(   org_id                  NUMBER
,   price_list_id           NUMBER
,   fob_point_code          VARCHAR2(30)
,   freight_terms_code      VARCHAR2(30)
,   payment_term_id         NUMBER
,   ship_to_org_id          NUMBER
,   deliver_to_org_id       NUMBER
,   invoice_to_org_id       NUMBER
,   contact_id              NUMBER
,   ship_partial_allowed    VARCHAR2(1)
,   shipping_method_code    VARCHAR2(30)
,   order_type_id           NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   tp_setup                BOOLEAN
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);
/*sdatti*/
TYPE Sold_To_Site_Rec_Type IS RECORD
(   sold_to_site_use_id     NUMBER
,   customer_id             NUMBER
,   order_type_id           NUMBER
,   price_list_id           NUMBER
,   payment_term_id         NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);
/*sdatti*/
--{ Bug 5054618
/* End customer changes for HVOP */
TYPE End_Customer_Rec_Type IS RECORD
(   org_id                  NUMBER
,   price_list_id           NUMBER
,   fob_point_code          VARCHAR2(30)
,   freight_terms_code      VARCHAR2(30)
,   payment_term_id         NUMBER
,   ship_to_org_id          NUMBER
,   deliver_to_org_id       NUMBER
,   invoice_to_org_id       NUMBER
,   contact_id              NUMBER
,   ship_partial_allowed    VARCHAR2(1)
,   shipping_method_code    VARCHAR2(30)
,   order_type_id           NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   tp_setup                BOOLEAN
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);

TYPE End_Cust_Site_Rec_Type IS RECORD
(   sold_to_site_use_id     NUMBER
,   customer_id             NUMBER
,   order_type_id           NUMBER
,   price_list_id           NUMBER
,   payment_term_id         NUMBER
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
-- EDI attributes
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);

-- Bug 5054618}
TYPE Price_List_Rec_Type IS RECORD
(   price_list_id           NUMBER
,   name                    VARCHAR2(240)
,   list_type_code          VARCHAR2(30)
,   start_date_active       DATE
,   end_date_active         DATE
,   currency_code           VARCHAR2(15)
);

TYPE Set_Of_Books_Rec_Type IS RECORD
(   set_of_books_id         NUMBER
,   currency_code           VARCHAR2(15)
,   default_attributes      VARCHAR2(1)  DEFAULT 'N'
);

TYPE Item_Rec_Type IS RECORD
(   inventory_item_id             NUMBER
,   organization_id               NUMBER
,   customer_order_enabled_flag   VARCHAR2(1)
,   internal_order_enabled_flag   VARCHAR2(1)
,   ship_model_complete_flag      VARCHAR2(1)
,   build_in_wip_flag             VARCHAR2(1)
,   replenish_to_order_flag       VARCHAR2(1)
,   pick_components_flag          VARCHAR2(1)
,   shippable_item_flag           VARCHAR2(1)
,   service_item_flag             VARCHAR2(1)
,   bom_item_type                 NUMBER
,   process_warehouse_flag        VARCHAR2(1)
--,   dualum_ind                    NUMBER       -- INVCONV
--,   opm_item_id                   NUMBER       -- INVCONV
--,   opm_item_um		          VARCHAR2(4)  -- INVCONV
--,   opm_item_um2	          VARCHAR2(4)  -- INVCONV
--,   opm_grade_ctl	          NUMBER       -- INVCONV
,   invoicing_rule_id             NUMBER
,   accounting_rule_id            NUMBER
,   default_shipping_org          NUMBER
,   primary_uom_code              VARCHAR2(30)
,   ship_tolerance_above          NUMBER
,   ship_tolerance_below          NUMBER
,   item_description              VARCHAR2(240)
,   hazard_class_id               NUMBER
,   weight_uom_code               VARCHAR2(3)
,   volume_uom_code               VARCHAR2(3)
,   unit_volume                   NUMBER
,   unit_weight                   NUMBER
,   pickable_flag                 VARCHAR2(1)
,   master_container_item_id      NUMBER
,   detail_container_item_id      NUMBER
,   default_attributes            VARCHAR2(1)  DEFAULT 'N'
--bug 3798477
,   ont_pricing_qty_source        VARCHAR2(30)   --INVCONV
,   tracking_quantity_ind         VARCHAR2(30)
,   wms_enabled_flag              VARCHAR2(1)
--bug 3798477
,   config_model_type             VARCHAR2(30)
,   planning_make_buy_code        NUMBER
,   ordered_item                  VARCHAR2(2000)
-- INVCONV start
,  secondary_default_ind 			VARCHAR2(30)
,  lot_divisible_flag 				VARCHAR2(1)
,  grade_control_flag 				VARCHAR2(1)
,  lot_control_code     			NUMBER
,  secondary_uom_code          VARCHAR2(3)
-- INVCONV end
,   full_lead_time                NUMBER
,   fixed_lead_time               NUMBER
,   variable_lead_time            NUMBER
);


TYPE Salesrep_Rec_Type IS RECORD
(   salesrep_id             NUMBER
,   sales_credit_type_id    NUMBER
,   person_id               NUMBER
,   sales_tax_geocode       VARCHAR2(30)
,   sales_tax_inside_city_limits VARCHAR2(1)
);

TYPE Ship_From_Rec_Type IS RECORD
(   org_id                  NUMBER
-- EDI attributes
,   address_id              NUMBER
,   edi_location_code       VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   location                VARCHAR2(40) --Bug 7025494, changed width from 30 to 40
,   address1                VARCHAR2(30)
,   address2                VARCHAR2(30)
,   address3                VARCHAR2(30)
,   address4                VARCHAR2(30)
,   state                   VARCHAR2(30)
,   city                    VARCHAR2(30)
,   zip                     VARCHAR2(30)
,   country                 VARCHAR2(30)
,   county                  VARCHAR2(30)
,   province                VARCHAR2(240)
);

TYPE Loc_Info_Rec_Type IS RECORD
(   site_use_id             NUMBER
,   cust_acct_site_id       NUMBER
,   cust_account_id         NUMBER
,   postal_code             VARCHAR2(60)
,   loc_id                  NUMBER
,   party_id                NUMBER
,   party_name              VARCHAR2(360)
,   party_site_id           NUMBER
,   account_number          VARCHAR2(30)
,   acct_tax_header_level_flag VARCHAR2(1)
,   acct_tax_rounding_rule  VARCHAR2(30)
,   state                   VARCHAR2(60)
,   tax_header_level_flag   VARCHAR2(1)
,   tax_rounding_rule       VARCHAR2(30)
);

TYPE Tax_Attributes_Rec_Type IS RECORD
(   amount_includes_tax_flag    VARCHAR2(1)
,   taxable_basis               VARCHAR2(30)
,   tax_calculation_plsql_block VARCHAR2(2000)
,   vat_tax_id                  NUMBER
,   start_date                  DATE
,   end_date                    DATE
);

TYPE Person_Rec_Type IS RECORD
(   organization_id         NUMBER
,   location_id             NUMBER
,   start_date              DATE
,   end_date                DATE
);


TYPE Order_Type_Tbl_Type IS TABLE OF Order_Type_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Line_Type_Tbl_Type IS TABLE OF Line_Type_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Agreement_Tbl_Type IS TABLE OF Agreement_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Ship_To_Tbl_Type IS TABLE OF Ship_To_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Invoice_To_Tbl_Type IS TABLE OF Invoice_To_Rec_Type
INDEX BY BINARY_INTEGER;
/*sdatti*/
TYPE Sold_To_Site_Tbl_Type IS TABLE OF Sold_To_Site_Rec_Type
INDEX BY BINARY_INTEGER;
/*sdatti*/

TYPE End_Customer_Site_Tbl_Type IS TABLE OF End_Cust_Site_Rec_Type
INDEX BY BINARY_INTEGER; -- end customer changes (Bug 5054618)

TYPE End_Customer_Tbl_Type IS TABLE OF End_customer_Rec_Type
INDEX BY BINARY_INTEGER; -- end customer changes (Bug 5054618)

TYPE Item_Tbl_Type IS TABLE OF Item_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Sold_To_Tbl_Type IS TABLE OF Sold_To_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Salesrep_Tbl_Type IS TABLE OF Salesrep_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Ship_From_Tbl_Type IS TABLE OF Ship_From_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Price_List_Tbl_Type IS TABLE OF Price_List_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Loc_Info_Tbl_Type IS TABLE OF Loc_Info_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Tax_Attributes_Tbl_Type IS TABLE OF Tax_Attributes_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Person_Tbl_Type IS TABLE OF Person_Rec_Type
INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------
-- GLOBAL CACHE TABLES
---------------------------------------------------------------------

G_ORDER_TYPE_TBL                Order_Type_Tbl_Type;
G_LINE_TYPE_TBL                 Line_Type_Tbl_Type;
G_AGREEMENT_TBL                 Agreement_Tbl_Type;
G_SHIP_TO_TBL                   Ship_To_Tbl_Type;
G_INVOICE_TO_TBL                Invoice_To_Tbl_Type;
G_SOLD_TO_SITE_TBL              Sold_To_Site_Tbl_Type;
G_ITEM_TBL                      Item_Tbl_Type;
G_SOLD_TO_TBL                   Sold_To_Tbl_Type;
G_SALESREP_TBL                  Salesrep_Tbl_Type;
G_SHIP_FROM_TBL                 Ship_From_Tbl_Type;
G_PRICE_LIST_TBL                Price_List_Tbl_Type;
G_END_CUSTOMER_SITE_TBL         End_Customer_Site_Tbl_Type;	--Bug 5054618
G_END_CUSTOMER_TBL              End_Customer_Tbl_Type;		--Bug 5054618
G_LOC_INFO_TBL                  Loc_Info_Tbl_Type;
G_TAX_ATTRIBUTES_TBL            Tax_Attributes_Tbl_Type;
G_PERSON_TBL                    Person_Tbl_Type;

---------------------------------------------------------------------
-- PROCEDURES/FUNCTIONS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Functions to load cache for each entity
--
-- IN parameters:
-- p_key: Primary key of record that is to be cached e.g.order_type_id
-- for Load_Order_Type
--
-- p_default_attributes: pass 'Y' if you are using the cache to
-- retrieve attributes that can default from this entity e.g.
-- accounting rule for order type entity. These defaultable attributes
-- will also be validated when populating the cache and if invalid,
-- cache will store null.
--
-- p_edi_attributes: pass 'Y' if there are EDI specific attributes
-- that need to be cached for this entity. Used by acknowledgment
-- APIs.
---------------------------------------------------------------------

FUNCTION Load_Order_Type
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

FUNCTION Load_Line_Type
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

FUNCTION Load_Agreement
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

FUNCTION Load_Item
( p_key1                     IN NUMBER
, p_key2                     IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;


FUNCTION Load_Ship_To
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

--{Bug 5054618
FUNCTION Load_End_customer
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

FUNCTION Load_End_Customer_Site
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;
--Bug 5054618}

FUNCTION Load_Sold_To
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

FUNCTION Load_Invoice_To
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;
/*sdatti*/
FUNCTION Load_Sold_To_Site
( p_key                      IN NUMBER
, p_default_attributes       IN VARCHAR2 DEFAULT 'N'
, p_edi_attributes           IN VARCHAR2 DEFAULT 'N'
)
RETURN NUMBER;

/*sdatti*/
FUNCTION Load_Salesrep
( p_key                      IN NUMBER
)
RETURN NUMBER;

FUNCTION Load_Ship_From
( p_key                      IN NUMBER
)
RETURN NUMBER;

FUNCTION Load_Price_List
( p_key                      IN NUMBER
)
RETURN NUMBER;

FUNCTION IS_CC_REQUIRED
( p_key                      IN NUMBER
)
RETURN BOOLEAN;

FUNCTION Load_Loc_Info
( p_key                      IN NUMBER
)
RETURN NUMBER;

FUNCTION Load_Tax_Attributes
( p_key                      IN VARCHAR2,
  p_tax_date                 IN DATE
)
RETURN NUMBER;

FUNCTION Load_Person
( p_key                      IN NUMBER,
  p_tax_date                 IN DATE
)
RETURN NUMBER;

END OE_BULK_CACHE;

/

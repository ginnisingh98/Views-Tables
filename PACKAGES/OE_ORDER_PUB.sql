--------------------------------------------------------
--  DDL for Package OE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPORDS.pls 120.17.12010000.6 2011/02/23 21:17:04 snimmaga ship $ */
/*#
* This public API allows users to perform various operations on sales orders in the Order Management system.
* @rep:scope public
* @rep:metalink 91798.1 Order Management Suite Documentation
* @rep:product ONT
* @rep:lifecycle active
* @rep:displayname Process Order API
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
*/


--  Header record type

TYPE Header_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER
,   party_type             varchar2(30)
,   agreement_id                  NUMBER
,   attribute1                    VARCHAR2(240)
,   attribute10                   VARCHAR2(240)
,   attribute11                   VARCHAR2(240)
,   attribute12                   VARCHAR2(240)
,   attribute13                   VARCHAR2(240)
,   attribute14                   VARCHAR2(240)
,   attribute15                   VARCHAR2(240)
,   attribute16                   VARCHAR2(240)
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
,   booked_flag                   VARCHAR2(1)
,   cancelled_flag                VARCHAR2(1)
,   context                       VARCHAR2(30)
,   conversion_rate               NUMBER
,   conversion_rate_date          DATE
,   conversion_type_code          VARCHAR2(30)
,   customer_preference_set_code  VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   cust_po_number                VARCHAR2(50)
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   demand_class_code             VARCHAR2(30)
,   earliest_schedule_limit	  NUMBER
,   expiration_date               DATE
,   fob_point_code                VARCHAR2(30)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
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
,   header_id                     NUMBER
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   latest_schedule_limit         NUMBER
,   open_flag                     VARCHAR2(1)
,   order_category_code           VARCHAR2(30)
,   ordered_date                  DATE
,   order_date_type_code	  VARCHAR2(30)
,   order_number                  NUMBER
,   order_source_id               NUMBER
,   order_type_id                 NUMBER
,   org_id                        NUMBER
,   orig_sys_document_ref         VARCHAR2(50)
,   partial_shipments_allowed     VARCHAR2(1)
,   payment_term_id               NUMBER
,   price_list_id                 NUMBER
,   price_request_code            VARCHAR2(240)    --PROMOTIONS SEP/01
,   pricing_date                  DATE
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_date                  DATE
,   request_id                    NUMBER
,   return_reason_code		  VARCHAR2(30)
,   salesrep_id			  NUMBER
,   sales_channel_code            VARCHAR2(30)
,   shipment_priority_code        VARCHAR2(30)
,   shipping_method_code          VARCHAR2(30)
,   ship_from_org_id              NUMBER
,   ship_tolerance_above          NUMBER
,   ship_tolerance_below          NUMBER
,   ship_to_contact_id            NUMBER
,   ship_to_org_id                NUMBER
,   sold_from_org_id		  NUMBER
,   sold_to_contact_id            NUMBER
,   sold_to_org_id                NUMBER
,   sold_to_phone_id              NUMBER
,   source_document_id            NUMBER
,   source_document_type_id       NUMBER
,   tax_exempt_flag               VARCHAR2(30)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   tax_point_code                VARCHAR2(30)
,   transactional_curr_code       VARCHAR2(15)
,   version_number                NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   first_ack_code                VARCHAR2(30)
,   first_ack_date                DATE
,   last_ack_code                 VARCHAR2(30)
,   last_ack_date                 DATE
,   change_reason                 VARCHAR2(30)
,   change_comments               VARCHAR2(2000)
,   change_sequence 	  	  VARCHAR2(50)
,   change_request_code	  	  VARCHAR2(30)
,   ready_flag		  	  VARCHAR2(1)
,   status_flag		  	  VARCHAR2(1)
,   force_apply_flag		  VARCHAR2(1)
,   drop_ship_flag		  VARCHAR2(1)
,   customer_payment_term_id	  NUMBER
,   payment_type_code             VARCHAR2(30)
,   payment_amount                NUMBER
,   check_number                  VARCHAR2(50)
,   credit_card_code              VARCHAR2(80)
,   credit_card_holder_name       VARCHAR2(80)
,   credit_card_number            VARCHAR2(80)
,   credit_card_expiration_date   DATE
,   credit_card_approval_code     VARCHAR2(80)
,   credit_card_approval_date     DATE
,   shipping_instructions	    VARCHAR2(2000)
,   packing_instructions          VARCHAR2(2000)
,   flow_status_code              VARCHAR2(30)
,   booked_date			    DATE
,   marketing_source_code_id      NUMBER
,   upgraded_flag                VARCHAR2(1)
,   lock_control                 NUMBER
,   ship_to_edi_location_code    VARCHAR2(40)
,   sold_to_edi_location_code    VARCHAR2(40)
,   bill_to_edi_location_code    VARCHAR2(40)
,   ship_from_edi_location_code  VARCHAR2(40)   -- Ship From Bug 2116166
,   SHIP_FROM_ADDRESS_ID         Number
,   SOLD_TO_ADDRESS_ID           Number
,   SHIP_TO_ADDRESS_ID           Number
,   INVOICE_ADDRESS_ID           Number
,   SHIP_TO_ADDRESS_CODE         Varchar2(40)
,   xml_message_id               Number
,   ship_to_customer_id                NUMBER
,   invoice_to_customer_id                NUMBER
,   deliver_to_customer_id                NUMBER
,   accounting_rule_duration     NUMBER
,   xml_transaction_type_code    Varchar2(30)
,   Blanket_Number               NUMBER
,   Line_Set_Name                VARCHAR2(30)
,   Fulfillment_Set_Name         VARCHAR2(30)
,   Default_Fulfillment_Set      VARCHAR2(1)
-- Quoting project related fields
,   quote_date                      date
,   quote_number                    number
,   sales_document_name             varchar2(240)
,   transaction_phase_code          varchar2(30)
,   user_status_code                varchar2(30)
,   draft_submitted_flag            varchar2(1)
,   source_document_version_number  number
,   sold_to_site_use_id             number
-- End quoting project related fields
,   Minisite_Id                  NUMBER
,   IB_OWNER                     VARCHAR2(60)
,   IB_INSTALLED_AT_LOCATION     VARCHAR2(60)
,   IB_CURRENT_LOCATION          VARCHAR2(60)
,   END_CUSTOMER_ID              NUMBER
,   END_CUSTOMER_CONTACT_ID      NUMBER
,   END_CUSTOMER_SITE_USE_ID     NUMBER
,   SUPPLIER_SIGNATURE           VARCHAR2(240)
,   SUPPLIER_SIGNATURE_DATE      DATE
,   CUSTOMER_SIGNATURE           VARCHAR2(240)
,   CUSTOMER_SIGNATURE_DATE      DATE
--automatic account creation
,   sold_to_party_id              NUMBER
,   sold_to_org_contact_id        NUMBER
,   ship_to_party_id              NUMBER
,   ship_to_party_site_id         NUMBER
,   ship_to_party_site_use_id     NUMBER
,   deliver_to_party_id           NUMBER
,   deliver_to_party_site_id      NUMBER
,   deliver_to_party_site_use_id  NUMBER
,   invoice_to_party_id           NUMBER
,   invoice_to_party_site_id      NUMBER
,   invoice_to_party_site_use_id  NUMBER
    --aac for endcustomer
,   end_customer_party_id        NUMBER
,   end_customer_party_site_id         NUMBER
,   end_customer_party_site_use_id     NUMBER
,   end_customer_party_number varchar2(30)
,   end_customer_org_contact_id NUMBER

,   ship_to_customer_party_id     NUMBER
,   deliver_to_customer_party_id  NUMBER
,   invoice_to_customer_party_id  NUMBER

,   ship_to_org_contact_id      NUMBER
,   deliver_to_org_contact_id	  NUMBER
,   invoice_to_org_contact_id   NUMBER
-- Contract template placeholder
,   contract_template_id         NUMBER
,   contract_source_doc_type_code    varchar2(30)
,   contract_source_document_id        number
,   sold_to_party_number        varchar2(30)
,   ship_to_party_number        varchar2(30)
,   invoice_to_party_number        varchar2(30)
,   deliver_to_party_number        varchar2(30)
--Key Transaction Dates
,   Order_Firmed_Date            DATE
,   Instrument_Security_Code	  VARCHAR2(10) --R12 CC Encryption
,   CC_INSTRUMENT_ID		 NUMBER
,   CC_INSTRUMENT_ASSIGNMENT_ID    NUMBER --R12 CC Encryption

--ER7675548
,   sold_to_customer_ref        Varchar2(50)
,   ship_to_customer_ref        Varchar2(50)
,   invoice_to_customer_ref     Varchar2(50)
,   deliver_to_customer_ref     Varchar2(50)

,   ship_to_address_ref         Varchar2(50)
,   invoice_to_address_ref      Varchar2(50)
,   deliver_to_address_ref      Varchar2(50)
,   sold_to_address_ref         VARCHAR2(50)

,   sold_to_contact_ref          Varchar2(50)
,   ship_to_contact_ref          Varchar2(50)
,   invoice_to_contact_ref       Varchar2(50)
,   deliver_to_contact_ref       Varchar2(50)

);

TYPE Header_Tbl_Type IS TABLE OF Header_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header value record type

TYPE Header_Val_Rec_Type IS RECORD
(   accounting_rule               VARCHAR2(240)
,   agreement                     VARCHAR2(240)
,   conversion_type               VARCHAR2(240)
,   deliver_to_address1           VARCHAR2(240)
,   deliver_to_address2           VARCHAR2(240)
,   deliver_to_address3           VARCHAR2(240)
,   deliver_to_address4           VARCHAR2(240)
,   deliver_to_contact            VARCHAR2(360)
,   deliver_to_location           VARCHAR2(240)
,   deliver_to_org                VARCHAR2(240)
,   deliver_to_state              VARCHAR2(240)
,   deliver_to_city               VARCHAR2(240)
,   deliver_to_zip                VARCHAR2(240)
,   deliver_to_country            VARCHAR2(240)
,   deliver_to_county             VARCHAR2(240)
,   deliver_to_province           VARCHAR2(240)
,   demand_class                  VARCHAR2(240)
,   fob_point                     VARCHAR2(240)
,   freight_terms                 VARCHAR2(240)
,   invoice_to_address1           VARCHAR2(240)
,   invoice_to_address2           VARCHAR2(240)
,   invoice_to_address3           VARCHAR2(240)
,   invoice_to_address4           VARCHAR2(240)
,   invoice_to_state              VARCHAR2(240)
,   invoice_to_city               VARCHAR2(240)
,   invoice_to_zip                VARCHAR2(240)
,   invoice_to_country            VARCHAR2(240)
,   invoice_to_county             VARCHAR2(240)
,   invoice_to_province           VARCHAR2(240)
,   invoice_to_contact            VARCHAR2(360)
,   invoice_to_contact_first_name VARCHAR2(240)
,   invoice_to_contact_last_name VARCHAR2(240)
,   invoice_to_location           VARCHAR2(240)
,   invoice_to_org                VARCHAR2(240)
,   invoicing_rule                VARCHAR2(240)
,   order_source                  VARCHAR2(240)
,   order_type                    VARCHAR2(240)
,   payment_term                  VARCHAR2(240)
,   price_list                    VARCHAR2(240)
,   return_reason          VARCHAR2(240)
,   salesrep               VARCHAR2(240)
,   shipment_priority             VARCHAR2(240)
,   ship_from_address1            VARCHAR2(240)
,   ship_from_address2            VARCHAR2(240)
,   ship_from_address3            VARCHAR2(240)
,   ship_from_address4            VARCHAR2(240)
,   ship_from_location            VARCHAR2(240)
,   SHIP_FROM_CITY               Varchar(60)       -- Ship From Bug 2116166
,   SHIP_FROM_POSTAL_CODE        Varchar(60)
,   SHIP_FROM_COUNTRY            Varchar(60)
,   SHIP_FROM_REGION1            Varchar2(240)
,   SHIP_FROM_REGION2            Varchar2(240)
,   SHIP_FROM_REGION3            Varchar2(240)
,   ship_from_org                 VARCHAR2(240)
,   sold_to_address1              VARCHAR2(240)
,   sold_to_address2              VARCHAR2(240)
,   sold_to_address3              VARCHAR2(240)
,   sold_to_address4              VARCHAR2(240)
,   sold_to_state                 VARCHAR2(240)
,   sold_to_country               VARCHAR2(240)
,   sold_to_zip                   VARCHAR2(240)
,   sold_to_county                VARCHAR2(240)
,   sold_to_province              VARCHAR2(240)
,   sold_to_city                  VARCHAR2(240)
,   sold_to_contact_last_name     VARCHAR2(240)
,   sold_to_contact_first_name    VARCHAR2(240)
,   ship_to_address1              VARCHAR2(240)
,   ship_to_address2              VARCHAR2(240)
,   ship_to_address3              VARCHAR2(240)
,   ship_to_address4              VARCHAR2(240)
,   ship_to_state                 VARCHAR2(240)
,   ship_to_country               VARCHAR2(240)
,   ship_to_zip                   VARCHAR2(240)
,   ship_to_county                VARCHAR2(240)
,   ship_to_province              VARCHAR2(240)
,   ship_to_city                  VARCHAR2(240)
,   ship_to_contact               VARCHAR2(360)
,   ship_to_contact_last_name     VARCHAR2(240)
,   ship_to_contact_first_name    VARCHAR2(240)
,   ship_to_location              VARCHAR2(240)
,   ship_to_org                   VARCHAR2(240)
,   sold_to_contact               VARCHAR2(360)
,   sold_to_org                   VARCHAR2(360)
,   sold_from_org                 VARCHAR2(240)
,   tax_exempt                    VARCHAR2(240)
,   tax_exempt_reason             VARCHAR2(240)
,   tax_point                     VARCHAR2(240)
,   customer_payment_term       VARCHAR2(240)
,   payment_type                  VARCHAR2(240)
,   credit_card                   VARCHAR2(240)
,   status                        VARCHAR2(240)
,   freight_carrier               VARCHAR2(80)
,   shipping_method               VARCHAR2(80)
,   order_date_type               VARCHAR2(80)
,   customer_number               VARCHAR2(30)
,   ship_to_customer_name         VARCHAR2(360)
,   invoice_to_customer_name      VARCHAR2(360)
,   sales_channel                 VARCHAR2(80)
,   ship_to_customer_number       VARCHAR2(50)
,   invoice_to_customer_number    VARCHAR2(50)
,   ship_to_customer_id           NUMBER
,   invoice_to_customer_id        NUMBER
,   deliver_to_customer_id        NUMBER
,   deliver_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_name      VARCHAR2(360)
,   deliver_to_customer_Number_oi    VARCHAR2(30)
,   deliver_to_customer_Name_oi      VARCHAR2(360)
,   ship_to_customer_Number_oi    VARCHAR2(30)
,   ship_to_customer_Name_oi      VARCHAR2(360)
,   invoice_to_customer_Number_oi    VARCHAR2(30)
,   invoice_to_customer_Name_oi      VARCHAR2(360)
-- QUOTING changes
,   user_status                        VARCHAR2(240)
,   transaction_phase                  VARCHAR2(240)
,   sold_to_location_address1      varchar2(240)
,   sold_to_location_address2      varchar2(240)
,   sold_to_location_address3      varchar2(240)
,   sold_to_location_address4      varchar2(240)
,   sold_to_location               varchar2(240)
,   sold_to_location_city               varchar2(240)
,   sold_to_location_state               varchar2(240)
,   sold_to_location_postal               varchar2(240)
,   sold_to_location_country               varchar2(240)
,   sold_to_location_county               varchar2(240)
,   sold_to_location_province             varchar2(240)
-- END QUOTING changes
-- distributed orders
,   end_customer_name                VARCHAR2(360)
,   end_customer_number              VARCHAR2(50)
,   end_customer_contact             VARCHAR2(360)
,   end_cust_contact_last_name       VARCHAR2(240)
,   end_cust_contact_first_name      VARCHAR2(240)
,   end_customer_site_address1       VARCHAR2(240)
,   end_customer_site_address2       VARCHAR2(240)
,   end_customer_site_address3       VARCHAR2(240)
,   end_customer_site_address4       VARCHAR2(240)
,   end_customer_site_state          VARCHAR2(240)
,   end_customer_site_country        VARCHAR2(240)
,   end_customer_site_location       VARCHAR2(240)
,   end_customer_site_zip            VARCHAR2(240)
,   end_customer_site_county         VARCHAR2(240)
,   end_customer_site_province       VARCHAR2(240)
,   end_customer_site_city           VARCHAR2(240)
,   end_customer_site_postal_code    VARCHAR2(240)
-- distributed orders
,  blanket_agreement_name            VARCHAR2(360)
,  ib_owner_dsp                      VARCHAR2(60)
,  ib_installed_at_location_dsp           VARCHAR2(60)
,  ib_current_location_dsp           VARCHAR2(60)
-- word integration
,  contract_template                 VARCHAR2(60)
,  contract_source                   VARCHAR2(60)
,  authoring_party                   VARCHAR2(60)
-- Account Desc Project
, account_description		     VARCHAR2(240)
, registry_id			     VARCHAR2(30)
);

TYPE Header_Val_Tbl_Type IS TABLE OF Header_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Adj record type

TYPE Header_Adj_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)
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
,   automatic_flag                VARCHAR2(1)
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   discount_id                   NUMBER
,   discount_line_id              NUMBER
,   header_id                     NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   percent                       NUMBER
,   price_adjustment_id           NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_id                    NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   orig_sys_discount_ref	  VARCHAR2(50)
,   change_request_code	  	  VARCHAR2(30)
,   status_flag		  	  VARCHAR2(1)
,   list_header_id		  number
,   list_line_id		  number
,   list_line_type_code		  varchar2(30)
,   modifier_mechanism_type_code  varchar2(30)
,   modified_from		  varchar2(240)
,   modified_to		  varchar2(240)
,   updated_flag		  varchar2(1)
,   update_allowed		  varchar2(1)
,   applied_flag		  varchar2(1)
,   change_reason_code		  varchar2(30)
,   change_reason_text		  varchar2(2000)
,   operand                       number
,   operand_per_pqty              number
,   arithmetic_operator           varchar2(30)
,   cost_id                       number
,   tax_code                      varchar2(50)
,   tax_exempt_flag               varchar2(1)
,   tax_exempt_number             varchar2(80)
,   tax_exempt_reason_code        varchar2(30)
,   parent_adjustment_id          number
,   invoiced_flag                 varchar2(1)
,   estimated_flag                varchar2(1)
,   inc_in_sales_performance      varchar2(1)
,   split_action_code             varchar2(30)
,   adjusted_amount				number
,   adjusted_amount_per_pqty                    number
,   pricing_phase_id			number
,   charge_type_code              varchar2(30)
,   charge_subtype_code           varchar2(30)
,   list_line_no                  varchar2(240)
,   source_system_code            varchar2(30)
,   benefit_qty                   number
,   benefit_uom_code              varchar2(3)
,   print_on_invoice_flag         varchar2(1)
,   expiration_date               date
,   rebate_transaction_type_code  varchar2(30)
,   rebate_transaction_reference  varchar2(80)
,   rebate_payment_system_code    varchar2(30)
,   redeemed_date                 date
,   redeemed_flag                 varchar2(1)
,   accrual_flag                  varchar2(1)
,   range_break_quantity		    number
,   accrual_conversion_rate	    number
,   pricing_group_sequence	     number
,   modifier_level_code			varchar2(30)
,   price_break_type_code		varchar2(30)
,   substitution_attribute		varchar2(30)
,   proration_type_code			varchar2(30)
,   credit_or_charge_flag          varchar2(1)
,   include_on_returns_flag        varchar2(1)
,   ac_attribute1                  VARCHAR2(240)
,   ac_attribute10                 VARCHAR2(240)
,   ac_attribute11                 VARCHAR2(240)
,   ac_attribute12                 VARCHAR2(240)
,   ac_attribute13                 VARCHAR2(240)
,   ac_attribute14                 VARCHAR2(240)
,   ac_attribute15                 VARCHAR2(240)
,   ac_attribute2                  VARCHAR2(240)
,   ac_attribute3                  VARCHAR2(240)
,   ac_attribute4                  VARCHAR2(240)
,   ac_attribute5                  VARCHAR2(240)
,   ac_attribute6                  VARCHAR2(240)
,   ac_attribute7                  VARCHAR2(240)
,   ac_attribute8                  VARCHAR2(240)
,   ac_attribute9                  VARCHAR2(240)
,   ac_context                     VARCHAR2(150)
,   lock_control                   NUMBER
,   invoiced_amount                NUMBER);

TYPE Header_Adj_Tbl_Type IS TABLE OF Header_Adj_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Adj value record type

TYPE Header_Adj_Val_Rec_Type IS RECORD
(   discount                      VARCHAR2(240)
,   list_name                     VARCHAR2(240)
,   version_no                    VARCHAR2(30)
);

TYPE Header_Adj_Val_Tbl_Type IS TABLE OF Header_Adj_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Header_Price_Att_Rec_Type

TYPE Header_Price_Att_Rec_Type IS RECORD
( 	order_price_attrib_id	number
,       header_id		number
,	line_id			number
,	creation_date		date
,	created_by		number
,	last_update_date	date
,	last_updated_by		number
,	last_update_login	number
,	program_application_id	number
,	program_id		number
,	program_update_date	date
,	request_id		number
, 	flex_title		varchar2(60)
,	pricing_context	varchar2(30)
,	pricing_attribute1	varchar2(240)
,	pricing_attribute2	varchar2(240)
,	pricing_attribute3	varchar2(240)
,	pricing_attribute4	varchar2(240)
,	pricing_attribute5	varchar2(240)
,	pricing_attribute6	varchar2(240)
,	pricing_attribute7	varchar2(240)
,	pricing_attribute8	varchar2(240)
,	pricing_attribute9	varchar2(240)
,	pricing_attribute10	varchar2(240)
,	pricing_attribute11	varchar2(240)
,	pricing_attribute12	varchar2(240)
,	pricing_attribute13	varchar2(240)
,	pricing_attribute14	varchar2(240)
,	pricing_attribute15	varchar2(240)
,	pricing_attribute16	varchar2(240)
,	pricing_attribute17	varchar2(240)
,	pricing_attribute18	varchar2(240)
,	pricing_attribute19	varchar2(240)
,	pricing_attribute20	varchar2(240)
,	pricing_attribute21	varchar2(240)
,	pricing_attribute22	varchar2(240)
,	pricing_attribute23	varchar2(240)
,	pricing_attribute24	varchar2(240)
,	pricing_attribute25	varchar2(240)
,	pricing_attribute26	varchar2(240)
,	pricing_attribute27	varchar2(240)
,	pricing_attribute28	varchar2(240)
,	pricing_attribute29	varchar2(240)
,	pricing_attribute30	varchar2(240)
,	pricing_attribute31	varchar2(240)
,	pricing_attribute32	varchar2(240)
,	pricing_attribute33	varchar2(240)
,	pricing_attribute34	varchar2(240)
,	pricing_attribute35	varchar2(240)
,	pricing_attribute36	varchar2(240)
,	pricing_attribute37	varchar2(240)
,	pricing_attribute38	varchar2(240)
,	pricing_attribute39	varchar2(240)
,	pricing_attribute40	varchar2(240)
,	pricing_attribute41	varchar2(240)
,	pricing_attribute42	varchar2(240)
,	pricing_attribute43	varchar2(240)
,	pricing_attribute44	varchar2(240)
,	pricing_attribute45	varchar2(240)
,	pricing_attribute46	varchar2(240)
,	pricing_attribute47	varchar2(240)
,	pricing_attribute48	varchar2(240)
,	pricing_attribute49	varchar2(240)
,	pricing_attribute50	varchar2(240)
,	pricing_attribute51	varchar2(240)
,	pricing_attribute52	varchar2(240)
,	pricing_attribute53	varchar2(240)
,	pricing_attribute54	varchar2(240)
,	pricing_attribute55	varchar2(240)
,	pricing_attribute56	varchar2(240)
,	pricing_attribute57	varchar2(240)
,	pricing_attribute58	varchar2(240)
,	pricing_attribute59	varchar2(240)
,	pricing_attribute60	varchar2(240)
,	pricing_attribute61	varchar2(240)
,	pricing_attribute62	varchar2(240)
,	pricing_attribute63	varchar2(240)
,	pricing_attribute64	varchar2(240)
,	pricing_attribute65	varchar2(240)
,	pricing_attribute66	varchar2(240)
,	pricing_attribute67	varchar2(240)
,	pricing_attribute68	varchar2(240)
,	pricing_attribute69	varchar2(240)
,	pricing_attribute70	varchar2(240)
,	pricing_attribute71	varchar2(240)
,	pricing_attribute72	varchar2(240)
,	pricing_attribute73	varchar2(240)
,	pricing_attribute74	varchar2(240)
,	pricing_attribute75	varchar2(240)
,	pricing_attribute76	varchar2(240)
,	pricing_attribute77	varchar2(240)
,	pricing_attribute78	varchar2(240)
,	pricing_attribute79	varchar2(240)
,	pricing_attribute80	varchar2(240)
,	pricing_attribute81	varchar2(240)
,	pricing_attribute82	varchar2(240)
,	pricing_attribute83	varchar2(240)
,	pricing_attribute84	varchar2(240)
,	pricing_attribute85	varchar2(240)
,	pricing_attribute86	varchar2(240)
,	pricing_attribute87	varchar2(240)
,	pricing_attribute88	varchar2(240)
,	pricing_attribute89	varchar2(240)
,	pricing_attribute90	varchar2(240)
,	pricing_attribute91	varchar2(240)
,	pricing_attribute92	varchar2(240)
,	pricing_attribute93	varchar2(240)
,	pricing_attribute94	varchar2(240)
,	pricing_attribute95	varchar2(240)
,	pricing_attribute96	varchar2(240)
,	pricing_attribute97	varchar2(240)
,	pricing_attribute98	varchar2(240)
,	pricing_attribute99	varchar2(240)
,	pricing_attribute100	varchar2(240)
,	context 		varchar2(30)
,	attribute1		varchar2(240)
,	attribute2		varchar2(240)
,	attribute3		varchar2(240)
,	attribute4		varchar2(240)
,	attribute5		varchar2(240)
,	attribute6		varchar2(240)
,	attribute7		varchar2(240)
,	attribute8		varchar2(240)
,	attribute9		varchar2(240)
,	attribute10		varchar2(240)
,	attribute11		varchar2(240)
,	attribute12		varchar2(240)
,	attribute13		varchar2(240)
,	attribute14		varchar2(240)
,	attribute15		varchar2(240)
,	Override_Flag		varchar2(1)
, 	return_status           VARCHAR2(1)
, 	db_flag                 VARCHAR2(1)
, 	operation               VARCHAR2(30)
,       lock_control            NUMBER
,       orig_sys_atts_ref       VARCHAR2(50)  --1433292
,       change_request_code     VARCHAR2(30)
)
;

TYPE  Header_Price_Att_Tbl_Type is TABLE of Header_Price_Att_rec_Type
	INDEX by BINARY_INTEGER;

-- Header_Adj_Att_Rec_Type

Type Header_Adj_Att_Rec_Type is RECORD
( price_adj_attrib_id	number
, price_adjustment_id    number
, Adj_index              NUMBER
, flex_title		 varchar2(60)
, pricing_context        varchar2(30)
, pricing_attribute      varchar2(30)
, creation_date          date
, created_by             number
, last_update_date       date
, last_updated_by        number
, last_update_login      number
, program_application_id number
, program_id             number
, program_update_date    date
, request_id             number
, pricing_attr_value_from varchar2(240)
, pricing_attr_value_to  varchar2(240)
, comparison_operator    varchar2(30)
, return_status          VARCHAR2(1)
, db_flag                VARCHAR2(1)
, operation              VARCHAR2(30)
, lock_control           NUMBER
);


TYPE  Header_Adj_Att_Tbl_Type is TABLE of Header_Adj_Att_rec_Type
	INDEX by BINARY_INTEGER;

-- Header_Adj_Assoc_Rec_Type

Type Header_Adj_Assoc_Rec_Type  is RECORD
(price_adj_assoc_id      number
, line_id                number
, Line_Index			number
, price_adjustment_id    number
, Adj_index              NUMBER
, rltd_Price_Adj_Id      number
, Rltd_Adj_Index         NUMBER
, creation_date          date
, created_by             number
, last_update_date       date
, last_updated_by        number
, last_update_login      number
, program_application_id number
, program_id             number
, program_update_date    date
, request_id             number
, return_status          VARCHAR2(1)
, db_flag                VARCHAR2(1)
, operation              VARCHAR2(30)
, lock_control           NUMBER
);


TYPE  Header_Adj_Assoc_Tbl_Type is TABLE of Header_Adj_Assoc_rec_Type
	INDEX by BINARY_INTEGER;


--  Header_Scredit record type

TYPE Header_Scredit_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)
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
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   dw_update_advice_flag         VARCHAR2(1)
,   header_id                     NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   percent                       NUMBER
,   salesrep_id                   NUMBER
,   sales_credit_type_id          NUMBER
,   sales_credit_id               NUMBER
,   wh_update_date                DATE
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   orig_sys_credit_ref	  	    VARCHAR2(50)
,   change_request_code	  	    VARCHAR2(30)
,   status_flag		  	    VARCHAR2(1)
,   lock_control                    NUMBER
,   change_reason                 VARCHAR2(30)
,   change_comments               VARCHAR2(2000)
--SG{
 ,sales_group_id NUMBER
 ,sales_group_updated_FLAG VARCHAR2(1)
--SG}
);

TYPE Header_Scredit_Tbl_Type IS TABLE OF Header_Scredit_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Scredit value record type

TYPE Header_Scredit_Val_Rec_Type IS RECORD
(   salesrep                      VARCHAR2(240)
   ,sales_credit_type             VARCHAR2(240)
 --SG{
 ,sales_group VARCHAR2(240)
 --SG}
);


TYPE Header_Scredit_Val_Tbl_Type IS TABLE OF Header_Scredit_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line record type

TYPE Line_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER
,   party_type             varchar2(30)
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
,   attribute16                   VARCHAR2(240)
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
,   authorized_to_ship_flag       VARCHAR2(1)
,   auto_selected_quantity        NUMBER
,   booked_flag                   VARCHAR2(1)
,   cancelled_flag                VARCHAR2(1)
,   cancelled_quantity            NUMBER
,   cancelled_quantity2           NUMBER
,   commitment_id                 NUMBER
,   component_code                VARCHAR2(1000)
,   component_number              NUMBER
,   component_sequence_id         NUMBER
,   config_header_id              NUMBER
,   config_rev_nbr 	              NUMBER
,   config_display_sequence       NUMBER
,   configuration_id              NUMBER
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   credit_invoice_line_id        NUMBER
,   customer_dock_code            VARCHAR2(50)
,   customer_job                  VARCHAR2(50)
,   customer_production_line      VARCHAR2(50)
,   customer_trx_line_id          NUMBER
,   cust_model_serial_number      VARCHAR2(50)
,   cust_po_number                VARCHAR2(50)
,   cust_production_seq_num       VARCHAR2(50)
,   delivery_lead_time            NUMBER
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   demand_bucket_type_code       VARCHAR2(30)
,   demand_class_code             VARCHAR2(30)
,   dep_plan_required_flag        VARCHAR2(1)
,   earliest_acceptable_date      DATE
,   end_item_unit_number          VARCHAR2(30)
,   explosion_date                DATE
,   fob_point_code                VARCHAR2(30)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
,   fulfilled_quantity            NUMBER
,   fulfilled_quantity2           NUMBER
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
,   intermed_ship_to_org_id       NUMBER
,   intermed_ship_to_contact_id   NUMBER
,   inventory_item_id             NUMBER
,   invoice_interface_status_code VARCHAR2(30)
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   ordered_item                  VARCHAR2(2000)
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
,   link_to_line_ref              VARCHAR2(50)
,   link_to_line_id               NUMBER
,   link_to_line_index            NUMBER
,   model_group_number            NUMBER
,   mfg_component_sequence_id     NUMBER
,   mfg_lead_time                 NUMBER
,   open_flag                     VARCHAR2(1)
,   option_flag                   VARCHAR2(1)
,   option_number                 NUMBER
,   ordered_quantity              NUMBER
,   ordered_quantity2             NUMBER
,   order_quantity_uom            VARCHAR2(3)
,   ordered_quantity_uom2         VARCHAR2(3)
,   org_id                        NUMBER
,   orig_sys_document_ref         VARCHAR2(50)
,   orig_sys_line_ref             VARCHAR2(50)
,   over_ship_reason_code	    VARCHAR2(30)
,   over_ship_resolved_flag	    VARCHAR2(1)
,   payment_term_id               NUMBER
,   planning_priority             NUMBER
,   preferred_grade               VARCHAR2(150)   -- INVCONV extended to 150
,   price_list_id                 NUMBER
,   price_request_code            VARCHAR2(240)    --PROMOTIONS SEP/01
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
,   re_source_flag                VARCHAR2(1)
,   reference_customer_trx_line_id NUMBER
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
,   return_reason_code		  VARCHAR2(30)
,   rla_schedule_type_code        VARCHAR2(30)
,   salesrep_id			  NUMBER
,   schedule_arrival_date         DATE
,   schedule_ship_date            DATE
,   schedule_action_code          VARCHAR2(30)
,   schedule_status_code          VARCHAR2(30)
,   shipment_number               NUMBER
,   shipment_priority_code        VARCHAR2(30)
,   shipped_quantity              NUMBER
,   shipped_quantity2             NUMBER
,   shipping_interfaced_flag      VARCHAR2(1)
,   shipping_method_code          VARCHAR2(30)
,   shipping_quantity             NUMBER
,   shipping_quantity2            NUMBER
,   shipping_quantity_uom         VARCHAR2(3)
,   shipping_quantity_uom2        VARCHAR2(3)
,   ship_from_org_id              NUMBER
,   ship_model_complete_flag      VARCHAR2(30)
,   ship_set_id                   NUMBER
,   fulfillment_set_id           NUMBER
,   ship_tolerance_above          NUMBER
,   ship_tolerance_below          NUMBER
,   ship_to_contact_id            NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_org_id                NUMBER
,   sold_from_org_id              NUMBER
,   sort_order                    VARCHAR2(2000)
,   source_document_id            NUMBER
,   source_document_line_id       NUMBER
,   source_document_type_id       NUMBER
,   source_type_code              VARCHAR2(30)
,   split_from_line_id            NUMBER
,   task_id                       NUMBER
,   tax_code                      VARCHAR2(50)
,   tax_date                      DATE
,   tax_exempt_flag               VARCHAR2(30)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   tax_point_code                VARCHAR2(30)
,   tax_rate                      NUMBER
,   tax_value                     NUMBER
,   top_model_line_ref            VARCHAR2(50)
,   top_model_line_id             NUMBER
,   top_model_line_index          NUMBER
,   unit_list_price               NUMBER
,   unit_list_price_per_pqty      NUMBER
,   unit_selling_price            NUMBER
,   unit_selling_price_per_pqty   NUMBER
,   veh_cus_item_cum_key_id       NUMBER
,   visible_demand_flag           VARCHAR2(1)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   first_ack_code                VARCHAR2(30)
,   first_ack_date                DATE
,   last_ack_code                 VARCHAR2(30)
,   last_ack_date                 DATE
,   change_reason                 VARCHAR2(30)
,   change_comments               VARCHAR2(2000)
,   arrival_set	              VARCHAR2(30)
,   ship_set			         VARCHAR2(30)
,   fulfillment_set	              VARCHAR2(30)
,   order_source_id               NUMBER
,   orig_sys_shipment_ref	    VARCHAR2(50)
,   change_sequence	  	         VARCHAR2(50)
,   change_request_code	  	    VARCHAR2(30)
,   status_flag		  	    VARCHAR2(1)
,   drop_ship_flag		         VARCHAR2(1)
,   customer_line_number	         VARCHAR2(50)
,   customer_shipment_number	    VARCHAR2(50)
,   customer_item_net_price	    NUMBER
,   customer_payment_term_id	    NUMBER
,   ordered_item_id               NUMBER
,   item_identifier_type          VARCHAR2(25)
,   shipping_instructions	    VARCHAR2(2000)
,   packing_instructions          VARCHAR2(2000)
,   calculate_price_flag          VARCHAR2(1)
,   invoiced_quantity             NUMBER
,   service_txn_reason_code       VARCHAR2(30)
,   service_txn_comments          VARCHAR2(2000)
,   service_duration              NUMBER
,   service_period                VARCHAR2(3)
,   service_start_date            DATE
,   service_end_date              DATE
,   service_coterminate_flag      VARCHAR2(1)
,   unit_list_percent             NUMBER
,   unit_selling_percent          NUMBER
,   unit_percent_base_price       NUMBER
,   service_number                NUMBER
,   service_reference_type_code   VARCHAR2(30)
,   service_reference_line_id     NUMBER
,   service_reference_system_id   NUMBER
,   service_ref_order_number      NUMBER
,   service_ref_line_number       NUMBER
,   service_reference_order       VARCHAR2(50)
,   service_reference_line        VARCHAR2(50)
,   service_reference_system      VARCHAR2(50)
,   service_ref_shipment_number   NUMBER
,   service_ref_option_number     NUMBER
,   service_line_index            NUMBER
,   Line_set_id			    NUMBER
,   split_by                      VARCHAR2(240)
,   Split_Action_Code             VARCHAR2(30)
,   shippable_flag		 	    VARCHAR2(1)
,   model_remnant_flag		    VARCHAR2(1)
,   flow_status_code              VARCHAR2(30)
,   fulfilled_flag                VARCHAR2(1)
,   fulfillment_method_code       VARCHAR2(30)
,   revenue_amount    		    NUMBER
,   marketing_source_code_id      NUMBER
,   fulfillment_date		    DATE
-- Non-database field that will be used ONLY in OE_Order_PVT
-- Is set to TRUE when the line is processed till defaulting
-- If the line being processed is a child (OPTION) and the parent (MODEL)
-- line is yet to be processed in the same call to process order,
-- then the processing of child (OPTION) is aborted after defaulting
-- and the parent (MODEL) line is processed.
-- Once the parent(MODEL) line has been processed, then the child(OPTION)
-- line is processed starting from the steps immediately after defaulting
-- i.e. apply attribute changes
,   semi_processed_flag		    BOOLEAN
,   upgraded_flag                 VARCHAR2(1)
,   lock_control                  NUMBER
,   subinventory                  VARCHAR2(10)
,   split_from_line_ref           VARCHAR2(50)
,   split_from_shipment_ref       VARCHAR2(50)
,   ship_to_edi_location_code     VARCHAR2(40)
,   Bill_to_Edi_Location_Code     VARCHAR2(40)    -- Ship From Bug 2116166
,   ship_from_edi_location_code   VARCHAR2(40)
,   Ship_from_address_id          NUMBER
,   Sold_to_address_id            NUMBER
,   Ship_to_address_id            NUMBER
,   Invoice_address_id            NUMBER
,   Ship_to_address_code          VARCHAR2(40)
,   Original_Inventory_Item_Id    NUMBER
,   Original_item_identifier_Type VARCHAR2(30)
,   Original_ordered_item_id      NUMBER
,   Original_ordered_item         VARCHAR2(2000)
,   Item_substitution_type_code   VARCHAR2(30)
,   Late_Demand_Penalty_Factor    NUMBER
,   Override_atp_date_code        VARCHAR2(30)
,   ship_to_customer_id          NUMBER
,   invoice_to_customer_id       NUMBER
,   deliver_to_customer_id       NUMBER
,   accounting_rule_duration     NUMBER
,   unit_cost                    NUMBER
,   user_item_description        VARCHAR2(1000)
,   xml_transaction_type_code    Varchar2(30)
,   item_relationship_type       NUMBER
,   Blanket_Number               NUMBER
,   Blanket_Line_Number          NUMBER
,   Blanket_Version_Number       NUMBER
,   cso_response_flag            VARCHAR2(1)
,   Firm_demand_flag             VARCHAR2(1)
,   Earliest_ship_date           DATE
-- Quoting project related fields
,   transaction_phase_code       varchar2(30)
,   source_document_version_number   number
-- End Quoting project related fields
,   Minisite_Id                  NUMBER
,   IB_OWNER                     VARCHAR2(60)
,   IB_INSTALLED_AT_LOCATION     VARCHAR2(60)
,   IB_CURRENT_LOCATION          VARCHAR2(60)
,   END_CUSTOMER_ID              NUMBER
,   END_CUSTOMER_CONTACT_ID      NUMBER
,   END_CUSTOMER_SITE_USE_ID     NUMBER
,   SUPPLIER_SIGNATURE           VARCHAR2(240)
,   SUPPLIER_SIGNATURE_DATE      DATE
,   CUSTOMER_SIGNATURE           VARCHAR2(240)
,   CUSTOMER_SIGNATURE_DATE      DATE
-- automatic account creation
,   ship_to_party_id              NUMBER
,   ship_to_party_site_id         NUMBER
,   ship_to_party_site_use_id     NUMBER
,   deliver_to_party_id           NUMBER
,   deliver_to_party_site_id      NUMBER
,   deliver_to_party_site_use_id  NUMBER
,   invoice_to_party_id           NUMBER
,   invoice_to_party_site_id      NUMBER
,   invoice_to_party_site_use_id  NUMBER

    --aac for endcustomer
,   end_customer_party_id        NUMBER
,   end_customer_party_site_id         NUMBER
,   end_customer_party_site_use_id     NUMBER
,   end_customer_party_number varchar2(30)
,   end_customer_org_contact_id NUMBER


,   ship_to_customer_party_id     NUMBER
,   deliver_to_customer_party_id  NUMBER
,   invoice_to_customer_party_id  NUMBER

,   ship_to_org_contact_id      NUMBER
,   deliver_to_org_contact_id	  NUMBER
,   invoice_to_org_contact_id   NUMBER
-- retrobilling
,   retrobill_request_id       NUMBER
,   original_list_price        NUMBER
,   commitment_applied_amount  NUMBER
,   ship_to_party_number        varchar2(30)
,   invoice_to_party_number        varchar2(30)
,   deliver_to_party_number        varchar2(30)
--Key Transaction Dates
,   order_firmed_date         DATE
,   actual_fulfillment_date   DATE
,   changed_lines_pocao       Varchar2(1)

-- For recurring charges
,   charge_periodicity_code     VARCHAR2(3)
--INVCONV
, reserved_quantity2 					NUMBER
-- Customer Acceptance
, CONTINGENCY_ID               NUMBER
, REVREC_EVENT_CODE            VARCHAR2(30)
, REVREC_EXPIRATION_DAYS       NUMBER
, ACCEPTED_QUANTITY            NUMBER
, ACCEPTED_BY                  NUMBER
, REVREC_COMMENTS              VARCHAR2(2000)
, REVREC_REFERENCE_DOCUMENT    VARCHAR2(240)
, REVREC_SIGNATURE             VARCHAR2(240)
, REVREC_SIGNATURE_DATE        DATE
, REVREC_IMPLICIT_FLAG         VARCHAR2(1)

--ER7675548
,   sold_to_customer_ref        Varchar2(50)
,   ship_to_customer_ref        Varchar2(50)
,   invoice_to_customer_ref     Varchar2(50)
,   deliver_to_customer_ref     Varchar2(50)

,   ship_to_address_ref         Varchar2(50)
,   invoice_to_address_ref      Varchar2(50)
,   deliver_to_address_ref      Varchar2(50)


,   ship_to_contact_ref          Varchar2(50)
,   invoice_to_contact_ref       Varchar2(50)
,   deliver_to_contact_ref       Varchar2(50)
--10278858
,SPLIT_REQUEST_DATE              VARCHAR2(1)
,SPLIT_SHIP_FROM                 VARCHAR2(1)
,SPLIT_SHIP_TO                   VARCHAR2(1)

-- For O2C/DOO Integration purpose
,bypass_sch_flag                 varchar2(1)
,pre_exploded_flag               varchar2(1)
);

TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line value record type

TYPE Line_Val_Rec_Type IS RECORD
(   accounting_rule               VARCHAR2(240)
,   agreement                     VARCHAR2(240)
,   commitment                    VARCHAR2(240)
,   commitment_applied_amount     NUMBER
,   deliver_to_address1           VARCHAR2(240)
,   deliver_to_address2           VARCHAR2(240)
,   deliver_to_address3           VARCHAR2(240)
,   deliver_to_address4           VARCHAR2(240)
,   deliver_to_contact            VARCHAR2(360)
,   deliver_to_location           VARCHAR2(240)
,   deliver_to_org                VARCHAR2(240)
,   deliver_to_state              VARCHAR2(240)
,   deliver_to_city               VARCHAR2(240)
,   deliver_to_zip                VARCHAR2(240)
,   deliver_to_country            VARCHAR2(240)
,   deliver_to_county             VARCHAR2(240)
,   deliver_to_province           VARCHAR2(240)
,   demand_class                  VARCHAR2(240)
,   demand_bucket_type            VARCHAR2(240)
,   fob_point                     VARCHAR2(240)
,   freight_terms                 VARCHAR2(240)
,   inventory_item                VARCHAR2(240)
,   invoice_to_address1           VARCHAR2(240)
,   invoice_to_address2           VARCHAR2(240)
,   invoice_to_address3           VARCHAR2(240)
,   invoice_to_address4           VARCHAR2(240)
,   invoice_to_contact            VARCHAR2(360)
,   invoice_to_location           VARCHAR2(240)
,   invoice_to_org                VARCHAR2(240)
,   invoice_to_state              VARCHAR2(240)
,   invoice_to_city               VARCHAR2(240)
,   invoice_to_zip                VARCHAR2(240)
,   invoice_to_country            VARCHAR2(240)
,   invoice_to_county             VARCHAR2(240)
,   invoice_to_province           VARCHAR2(240)
,   invoicing_rule                VARCHAR2(240)
,   item_type                     VARCHAR2(240)
,   line_type                     VARCHAR2(240)
,   over_ship_reason            VARCHAR2(240)
,   payment_term                  VARCHAR2(240)
,   price_list                    VARCHAR2(240)
,   project                       VARCHAR2(240)
,   return_reason                 VARCHAR2(240)
,   rla_schedule_type             VARCHAR2(240)
,   salesrep               VARCHAR2(240)
,   shipment_priority             VARCHAR2(240)
,   ship_from_address1            VARCHAR2(240)
,   ship_from_address2            VARCHAR2(240)
,   ship_from_address3            VARCHAR2(240)
,   ship_from_address4            VARCHAR2(240)
,   ship_from_location            VARCHAR2(240)
,   SHIP_FROM_CITY               Varchar(60)      -- Ship From Bug 2116166
,   SHIP_FROM_POSTAL_CODE        Varchar(60)
,   SHIP_FROM_COUNTRY            Varchar(60)
,   SHIP_FROM_REGION1            Varchar2(240)
,   SHIP_FROM_REGION2            Varchar2(240)
,   SHIP_FROM_REGION3            Varchar2(240)
,   ship_from_org                 VARCHAR2(240)
,   ship_to_address1              VARCHAR2(240)
,   ship_to_address2              VARCHAR2(240)
,   ship_to_address3              VARCHAR2(240)
,   ship_to_address4              VARCHAR2(240)
,   ship_to_state                 VARCHAR2(240)
,   ship_to_country               VARCHAR2(240)
,   ship_to_zip                   VARCHAR2(240)
,   ship_to_county                VARCHAR2(240)
,   ship_to_province              VARCHAR2(240)
,   ship_to_city                  VARCHAR2(240)
,   ship_to_contact               VARCHAR2(360)
,   ship_to_contact_last_name     VARCHAR2(240)
,   ship_to_contact_first_name    VARCHAR2(240)
,   ship_to_location              VARCHAR2(240)
,   ship_to_org                   VARCHAR2(240)
,   source_type                   VARCHAR2(240)
,   intermed_ship_to_address1     VARCHAR2(240)
,   intermed_ship_to_address2     VARCHAR2(240)
,   intermed_ship_to_address3     VARCHAR2(240)
,   intermed_ship_to_address4     VARCHAR2(240)
,   intermed_ship_to_contact      VARCHAR2(240)
,   intermed_ship_to_location     VARCHAR2(240)
,   intermed_ship_to_org          VARCHAR2(240)
,   intermed_ship_to_state             VARCHAR2(240)
,   intermed_ship_to_city              VARCHAR2(240)
,   intermed_ship_to_zip               VARCHAR2(240)
,   intermed_ship_to_country           VARCHAR2(240)
,   intermed_ship_to_county            VARCHAR2(240)
,   intermed_ship_to_province          VARCHAR2(240)
,   sold_to_org                   VARCHAR2(360)
,   sold_from_org                 VARCHAR2(240)
,   task                          VARCHAR2(240)
,   tax_exempt                    VARCHAR2(240)
,   tax_exempt_reason             VARCHAR2(240)
,   tax_point                     VARCHAR2(240)
,   veh_cus_item_cum_key          VARCHAR2(240)
,   visible_demand                VARCHAR2(240)
,   customer_payment_term       VARCHAR2(240)
,   ref_order_number              NUMBER
,   ref_line_number               NUMBER
,   ref_shipment_number           NUMBER
,   ref_option_number             NUMBER
,   ref_component_number          NUMBER
,   ref_invoice_number            VARCHAR2(20)
,   ref_invoice_line_number       NUMBER
,   credit_invoice_number         VARCHAR2(20)
,   tax_group                     VARCHAR2(1)
,   status                        VARCHAR2(240)
,   freight_carrier               VARCHAR2(80)
,   shipping_method               VARCHAR2(80)
,   calculate_price_descr         VARCHAR2(240)
,   ship_to_customer_name         VARCHAR2(360)
,   invoice_to_customer_name      VARCHAR2(360)
,   ship_to_customer_number       VARCHAR2(50)
,   invoice_to_customer_number    VARCHAR2(50)
,   ship_to_customer_id           NUMBER
,   invoice_to_customer_id        NUMBER
,   deliver_to_customer_id        NUMBER
,   deliver_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_name      VARCHAR2(360)
,   Original_Ordered_item         VARCHAR2(2000)
,   Original_inventory_item       VARCHAR2(2000)
,   Original_item_identifier_type VARCHAR2(240)
,   deliver_to_customer_Number_oi    VARCHAR2(30)
,   deliver_to_customer_Name_oi      VARCHAR2(360)
,   ship_to_customer_Number_oi    VARCHAR2(30)
,   ship_to_customer_Name_oi      VARCHAR2(360)
,   invoice_to_customer_Number_oi    VARCHAR2(30)
,   invoice_to_customer_Name_oi      VARCHAR2(360)
,   item_relationship_type_dsp      VARCHAR2(100)
-- QUOTING changes
,   transaction_phase                  VARCHAR2(240)
-- END QUOTING changes
-- distributed orders
,   end_customer_name                VARCHAR2(360)
,   end_customer_number              VARCHAR2(50)
,   end_customer_contact             VARCHAR2(360)
,   end_cust_contact_last_name       VARCHAR2(240)
,   end_cust_contact_first_name      VARCHAR2(240)
,   end_customer_site_address1       VARCHAR2(240)
,   end_customer_site_address2       VARCHAR2(240)
,   end_customer_site_address3       VARCHAR2(240)
,   end_customer_site_address4       VARCHAR2(240)
,   end_customer_site_location       VARCHAR2(240)
,   end_customer_site_state          VARCHAR2(240)
,   end_customer_site_country        VARCHAR2(240)
,   end_customer_site_zip            VARCHAR2(240)
,   end_customer_site_county         VARCHAR2(240)
,   end_customer_site_province       VARCHAR2(240)
,   end_customer_site_city           VARCHAR2(240)
,   end_customer_site_postal_code    VARCHAR2(240)
-- distributed orders
,   blanket_agreement_name           VARCHAR2(360)
,   ib_owner_dsp                     VARCHAR2(60)
,   ib_current_location_dsp          VARCHAR2(60)
,   ib_installed_at_location_dsp     VARCHAR2(60)
,   service_period_dsp               VARCHAR2(240)
,   service_reference_type           VARCHAR2(240)  --Bug 5701246
-- for recurring charges
,   charge_periodicity_dsp           VARCHAR2(25)
-- Customer Acceptance
,CONTINGENCY_NAME	             VARCHAR2(240)
,CONTINGENCY_DESCRIPTION	     VARCHAR2(240)
,EXPIRATION_EVENT_ATTRIBUTE	     VARCHAR2(240)
,REVREC_EVENT                        VARCHAR2(240)
,ACCEPTED_BY_DSP                     VARCHAR2(100)
);

TYPE Line_Val_Tbl_Type IS TABLE OF Line_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line_Adj record type

TYPE Line_Adj_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)
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
,   automatic_flag                VARCHAR2(1)
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   discount_id                   NUMBER
,   discount_line_id              NUMBER
,   header_id                     NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   percent                       NUMBER
,   price_adjustment_id           NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_id                    NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   line_index                    NUMBER
,   orig_sys_discount_ref         VARCHAR2(50)
,   change_request_code	  	    VARCHAR2(30)
,   status_flag		  	    VARCHAR2(1)
,   list_header_id                NUMBER
,   list_line_id                  NUMBER
,   list_line_type_code           VARCHAR2(30)
,   modifier_mechanism_type_code  VARCHAR2(30)
,   modified_from                 VARCHAR2(240)
,   modified_to                   VARCHAR2(240)
,   updated_flag                  VARCHAR2(1)
,   update_allowed                VARCHAR2(1)
,   applied_flag                  VARCHAR2(1)
,   change_reason_code            VARCHAR2(30)
,   change_reason_text            VARCHAR2(2000)
,   operand                       NUMBER
,   operand_per_pqty              NUMBER
,   arithmetic_operator           VARCHAR2(30)
,   cost_id                       NUMBER
,   tax_code                      VARCHAR2(50)
,   tax_exempt_flag               VARCHAR2(1)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   parent_adjustment_id          NUMBER
,   invoiced_flag                 VARCHAR2(1)
,   estimated_flag                VARCHAR2(1)
,   inc_in_sales_performance      VARCHAR2(1)
,   split_action_code             VARCHAR2(30)
,   adjusted_amount			    NUMBER
,   adjusted_amount_per_pqty                NUMBER
,   pricing_phase_id		    NUMBER
,   charge_type_code              VARCHAR2(30)
,   charge_subtype_code           VARCHAR2(30)
,   list_line_no                  varchar2(240)
,   source_system_code            varchar2(30)
,   benefit_qty                   number
,   benefit_uom_code              varchar2(3)
,   print_on_invoice_flag         varchar2(1)
,   expiration_date               date
,   rebate_transaction_type_code  varchar2(30)
,   rebate_transaction_reference  varchar2(80)
,   rebate_payment_system_code    varchar2(30)
,   redeemed_date                 date
,   redeemed_flag                 varchar2(1)
,   accrual_flag                 varchar2(1)
,   range_break_quantity			number
,   accrual_conversion_rate		number
,   pricing_group_sequence		number
,   modifier_level_code			varchar2(30)
,   price_break_type_code		varchar2(30)
,   substitution_attribute		varchar2(30)
,   proration_type_code			varchar2(30)
,   credit_or_charge_flag          varchar2(1)
,   include_on_returns_flag        varchar2(1)
,   ac_attribute1                  VARCHAR2(240)
,   ac_attribute10                 VARCHAR2(240)
,   ac_attribute11                 VARCHAR2(240)
,   ac_attribute12                 VARCHAR2(240)
,   ac_attribute13                 VARCHAR2(240)
,   ac_attribute14                 VARCHAR2(240)
,   ac_attribute15                 VARCHAR2(240)
,   ac_attribute2                  VARCHAR2(240)
,   ac_attribute3                  VARCHAR2(240)
,   ac_attribute4                  VARCHAR2(240)
,   ac_attribute5                  VARCHAR2(240)
,   ac_attribute6                  VARCHAR2(240)
,   ac_attribute7                  VARCHAR2(240)
,   ac_attribute8                  VARCHAR2(240)
,   ac_attribute9                  VARCHAR2(240)
,   ac_context                     VARCHAR2(150)
,   lock_control                   NUMBER
,   group_value                    NUMBER
,   invoiced_amount                NUMBER
-- retrobilling
,   retrobill_request_id       NUMBER
-- eBTax changes
,  tax_rate_id                     NUMBER
);

TYPE Line_Adj_Tbl_Type IS TABLE OF Line_Adj_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line_Adj value record type

TYPE Line_Adj_Val_Rec_Type IS RECORD
(   discount               VARCHAR2(240)
,   List_name              VARCHAR2(240)
,   version_no             VARCHAR2(30)
);

TYPE Line_Adj_Val_Tbl_Type IS TABLE OF Line_Adj_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Line_Price_Att_Rec_Type

TYPE Line_Price_Att_Rec_Type IS RECORD
(   order_price_attrib_id 	number
,   header_id				number
,   line_id				number
,   line_index				number
,   creation_date			date
,   created_by				number
,   last_update_date		date
,   last_updated_by			number
,   last_update_login		number
,   program_application_id	number
,   program_id				number
,   program_update_date		date
,   request_id				number
,   flex_title				varchar2(60)
,   pricing_context			varchar2(30)
,   pricing_attribute1		varchar2(240)
,   pricing_attribute2		varchar2(240)
,   pricing_attribute3		varchar2(240)
,   pricing_attribute4		varchar2(240)
,   pricing_attribute5		varchar2(240)
,   pricing_attribute6		varchar2(240)
,   pricing_attribute7		varchar2(240)
,   pricing_attribute8		varchar2(240)
,   pricing_attribute9		varchar2(240)
,   pricing_attribute10		varchar2(240)
,   pricing_attribute11		varchar2(240)
,   pricing_attribute12		varchar2(240)
,   pricing_attribute13		varchar2(240)
,   pricing_attribute14		varchar2(240)
,   pricing_attribute15		varchar2(240)
,   pricing_attribute16		varchar2(240)
,   pricing_attribute17		varchar2(240)
,   pricing_attribute18		varchar2(240)
,   pricing_attribute19		varchar2(240)
,   pricing_attribute20		varchar2(240)
,   pricing_attribute21		varchar2(240)
,   pricing_attribute22		varchar2(240)
,   pricing_attribute23		varchar2(240)
,   pricing_attribute24		varchar2(240)
,   pricing_attribute25		varchar2(240)
,   pricing_attribute26		varchar2(240)
,   pricing_attribute27		varchar2(240)
,   pricing_attribute28		varchar2(240)
,   pricing_attribute29		varchar2(240)
,   pricing_attribute30		varchar2(240)
,   pricing_attribute31		varchar2(240)
,   pricing_attribute32		varchar2(240)
,   pricing_attribute33		varchar2(240)
,   pricing_attribute34		varchar2(240)
,   pricing_attribute35		varchar2(240)
,   pricing_attribute36		varchar2(240)
,   pricing_attribute37		varchar2(240)
,   pricing_attribute38		varchar2(240)
,   pricing_attribute39		varchar2(240)
,   pricing_attribute40		varchar2(240)
,   pricing_attribute41		varchar2(240)
,   pricing_attribute42		varchar2(240)
,   pricing_attribute43		varchar2(240)
,   pricing_attribute44		varchar2(240)
,   pricing_attribute45		varchar2(240)
,   pricing_attribute46		varchar2(240)
,   pricing_attribute47		varchar2(240)
,   pricing_attribute48		varchar2(240)
,   pricing_attribute49		varchar2(240)
,   pricing_attribute50		varchar2(240)
,   pricing_attribute51		varchar2(240)
,   pricing_attribute52		varchar2(240)
,   pricing_attribute53		varchar2(240)
,   pricing_attribute54		varchar2(240)
,   pricing_attribute55		varchar2(240)
,   pricing_attribute56		varchar2(240)
,   pricing_attribute57		varchar2(240)
,   pricing_attribute58		varchar2(240)
,   pricing_attribute59		varchar2(240)
,   pricing_attribute60		varchar2(240)
,   pricing_attribute61		varchar2(240)
,   pricing_attribute62		varchar2(240)
,   pricing_attribute63		varchar2(240)
,   pricing_attribute64		varchar2(240)
,   pricing_attribute65		varchar2(240)
,   pricing_attribute66		varchar2(240)
,   pricing_attribute67		varchar2(240)
,   pricing_attribute68		varchar2(240)
,   pricing_attribute69		varchar2(240)
,   pricing_attribute70		varchar2(240)
,   pricing_attribute71		varchar2(240)
,   pricing_attribute72		varchar2(240)
,   pricing_attribute73		varchar2(240)
,   pricing_attribute74		varchar2(240)
,   pricing_attribute75		varchar2(240)
,   pricing_attribute76		varchar2(240)
,   pricing_attribute77		varchar2(240)
,   pricing_attribute78		varchar2(240)
,   pricing_attribute79		varchar2(240)
,   pricing_attribute80		varchar2(240)
,   pricing_attribute81		varchar2(240)
,   pricing_attribute82		varchar2(240)
,   pricing_attribute83		varchar2(240)
,   pricing_attribute84		varchar2(240)
,   pricing_attribute85		varchar2(240)
,   pricing_attribute86		varchar2(240)
,   pricing_attribute87		varchar2(240)
,   pricing_attribute88		varchar2(240)
,   pricing_attribute89		varchar2(240)
,   pricing_attribute90		varchar2(240)
,   pricing_attribute91		varchar2(240)
,   pricing_attribute92		varchar2(240)
,   pricing_attribute93		varchar2(240)
,   pricing_attribute94		varchar2(240)
,   pricing_attribute95		varchar2(240)
,   pricing_attribute96		varchar2(240)
,   pricing_attribute97		varchar2(240)
,   pricing_attribute98		varchar2(240)
,   pricing_attribute99		varchar2(240)
,   pricing_attribute100		varchar2(240)
,   context 				varchar2(30)
,   attribute1				varchar2(240)
,   attribute2				varchar2(240)
,   attribute3				varchar2(240)
,   attribute4				varchar2(240)
,   attribute5				varchar2(240)
,   attribute6				varchar2(240)
,   attribute7				varchar2(240)
,   attribute8				varchar2(240)
,   attribute9				varchar2(240)
,   attribute10			varchar2(240)
,   attribute11			varchar2(240)
,   attribute12			varchar2(240)
,   attribute13			varchar2(240)
,   attribute14			varchar2(240)
,   attribute15			varchar2(240)
,   Override_Flag		varchar2(1)
,   return_status            	VARCHAR2(1)
,   db_flag                  	VARCHAR2(1)
,   operation                	VARCHAR2(30)
,   lock_control                NUMBER
,   orig_sys_atts_ref       VARCHAR2(50) -- 1433292
,   change_request_code     VARCHAR2(30)
);

TYPE  Line_Price_Att_Tbl_Type is TABLE of Line_Price_Att_rec_Type
	INDEX by BINARY_INTEGER;

	-- Line_Adj_Att_Rec_Type

Type Line_Adj_Att_Rec_Type is RECORD
(   price_adj_attrib_id      	number
,   price_adjustment_id      	number
,   Adj_index				number
,   flex_title             	varchar2(60)
,   pricing_context        	varchar2(30)
,   pricing_attribute      	varchar2(30)
,   creation_date          	date
,   created_by             	number
,   last_update_date       	date
,   last_updated_by        	number
,   last_update_login      	number
,   program_application_id 	number
,   program_id             	number
,   program_update_date    	date
,   request_id             	number
,   pricing_attr_value_from 	varchar2(240)
,   pricing_attr_value_to  	varchar2(240)
,   comparison_operator     	varchar2(30)
,   return_status            	VARCHAR2(1)
,   db_flag                  	VARCHAR2(1)
,   operation                	VARCHAR2(30)
,   lock_control                NUMBER
);


TYPE  Line_Adj_Att_Tbl_Type is TABLE of Line_Adj_Att_rec_Type
	INDEX by BINARY_INTEGER;

-- Line_Adj_Assoc_Rec_Type

Type Line_Adj_Assoc_Rec_Type  is RECORD
( price_adj_assoc_id          number
, line_id                	number
, Line_index				number
, price_adjustment_id    	number
, Adj_index				number
, rltd_Price_Adj_Id      	number
, Rltd_Adj_Index         	NUMBER
, creation_date          	date
, created_by             	number
, last_update_date       	date
, last_updated_by        	number
, last_update_login      	number
, program_application_id 	number
, program_id             	number
, program_update_date    	date
, request_id             	number
, return_status            	VARCHAR2(1)
, db_flag                  	VARCHAR2(1)
, operation                	VARCHAR2(30)
, lock_control                  NUMBER);


TYPE  Line_Adj_Assoc_Tbl_Type is TABLE of Line_Adj_Assoc_rec_Type
	INDEX by BINARY_INTEGER;

--  Line_Scredit record type

TYPE Line_Scredit_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)
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
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   dw_update_advice_flag         VARCHAR2(1)
,   header_id                     NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   percent                       NUMBER
,   salesrep_id                   NUMBER
,   sales_credit_id               NUMBER
,   sales_credit_type_id          NUMBER
,   wh_update_date                DATE
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   line_index                    NUMBER
,   orig_sys_credit_ref           VARCHAR2(50)
,   change_request_code	  	  VARCHAR2(30)
,   status_flag		  	  VARCHAR2(1)
,   lock_control                  NUMBER
,   change_reason                 VARCHAR2(30)
,   change_comments               VARCHAR2(2000)
--SG{
,sales_group_id                   NUMBER
,sales_group_updated_flag         VARCHAR2(1)
--SG}
);

TYPE Line_Scredit_Tbl_Type IS TABLE OF Line_Scredit_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line_Scredit value record type

TYPE Line_Scredit_Val_Rec_Type IS RECORD
(   salesrep                      VARCHAR2(240)
   , sales_credit_type              VARCHAR2(240)
 --SG{
 ,sales_group VARCHAR2(240)
 --SG }
);

TYPE Line_Scredit_Val_Tbl_Type IS TABLE OF Line_Scredit_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Lot_Serial record type

TYPE Lot_Serial_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)
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
,   context                       VARCHAR2(30)
,   created_by                    NUMBER
,   creation_date                 DATE
,   from_serial_number            VARCHAR2(30)
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   lot_number                    VARCHAR2(80)  -- INVCONV  extedn to 80
,   sublot_number                 VARCHAR2(30)  --OPM 2380194 INVCONV delete
--  sublot_number RE-ADDED DUE TO problem in bug 4537505. later on this column needs to be taken out and the rosetta
-- package OE_ORDER_PUB_W regenerated

,   lot_serial_id                 NUMBER
,   quantity                      NUMBER
,   quantity2                     NUMBER         --OPM 2380194
,   to_serial_number              VARCHAR2(30)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   line_index                    NUMBER
,   orig_sys_lotserial_ref        VARCHAR2(50)
,   change_request_code	  	  VARCHAR2(30)
,   status_flag		  	  VARCHAR2(1)
,   line_set_id                   NUMBER
,   lock_control                  NUMBER);

TYPE Lot_Serial_Tbl_Type IS TABLE OF Lot_Serial_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Lot_Serial value record type

TYPE Lot_Serial_Val_Rec_Type IS RECORD
(   line                          VARCHAR2(240)
,   lot_serial                    VARCHAR2(240)
);

TYPE Lot_Serial_Val_Tbl_Type IS TABLE OF Lot_Serial_Val_Rec_Type
    INDEX BY BINARY_INTEGER;



--  Line Reservation record type

TYPE Reservation_Rec_Type IS RECORD
(   orig_sys_reservation_ref      VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   revision                 	  VARCHAR2(3)	 := FND_API.G_MISS_CHAR
,   lot_number_id		  NUMBER	 := FND_API.G_MISS_NUM
,   subinventory_id		  NUMBER	 := FND_API.G_MISS_NUM
,   locator_id			  NUMBER	 := FND_API.G_MISS_NUM
,   quantity                      NUMBER         := FND_API.G_MISS_NUM
,   attribute_category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   status_flag		  	  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   line_index                    NUMBER         := FND_API.G_MISS_NUM
,   quantity2                      NUMBER         := FND_API.G_MISS_NUM -- INVCONV
);

TYPE Reservation_Tbl_Type IS TABLE OF Reservation_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line Reservation value record type

TYPE Reservation_Val_Rec_Type IS RECORD
(   lot_number			  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   subinventory_code		  VARCHAR2(10)	 := FND_API.G_MISS_CHAR
);

TYPE Reservation_Val_Tbl_Type IS TABLE OF Reservation_Val_Rec_Type
    INDEX BY BINARY_INTEGER;


-- Set Records

TYPE Set_Rec_Type IS RECORD
(SET_ID  		NUMBER         := FND_API.G_MISS_NUM
 ,SET_NAME 		VARCHAR2(30)   := FND_API.G_MISS_CHAR
 ,SET_TYPE 		VARCHAR2(30)   := FND_API.G_MISS_CHAR
 ,SET_DATE		DATE	       := FND_API.G_MISS_DATE
 ,SET_LOCATION		NUMBER         := FND_API.G_MISS_NUM
 ,COMPLETE_FLAG 	VARCHAR2(30)   := FND_API.G_MISS_CHAR
 ,SYSTEM_REQUIRED_FLAG 	VARCHAR2(1)    := FND_API.G_MISS_CHAR
);

-- Line Set Record

TYPE Line_Set_Rec_Type IS RECORD
(SET_ID  		NUMBER         := FND_API.G_MISS_NUM
 ,LINE_ID  		NUMBER         := FND_API.G_MISS_NUM
);


--  API request record type.

--Kris, entity code could be null for order level stuff, then it would really be
--an entity code being passed rather than a combination.  (use the entity codes already defined)
--
TYPE Request_Rec_Type IS RECORD
  (
   -- Object for which the delayed request has been logged
   -- ie LINE, ORDER, PRICE_ADJUSTMENT
   Entity_code         Varchar2(30):= NULL,

   -- Primary key for the object as in entity_code
   Entity_id          Number := NULL,
   Entity_index	      Number := NULL,
   -- Function / Procedure indentifier ie 'PRICE_LINE'
   -- 'RECORD_HISTORY'
   request_type       Varchar2(30) := NULL,

   return_status	VARCHAR2(1)    := FND_API.G_MISS_CHAR,

   -- Keys to identify a unique request.
   request_unique_key1	VARCHAR2(30) := NULL,
   request_unique_key2  VARCHAR2(30) := NULL,
   request_unique_key3  VARCHAR2(30) := NULL,
   request_unique_key4  VARCHAR2(30) := NULL,
   request_unique_key5  VARCHAR2(30) := NULL,

   -- Parameters (param - param10) for the delayed request
   param1             Varchar2(2000) := NULL,
   param2             Varchar2(240) := NULL,
   param3             Varchar2(240) := NULL,
   param4             Varchar2(2000) := NULL,  -- 4495205
   param5             Varchar2(240) := NULL,
   param6             Varchar2(240) := NULL,
   param7             Varchar2(240) := NULL,
   param8             Varchar2(240) := NULL,
   param9             Varchar2(240) := NULL,
   param10            Varchar2(240) := NULL,
   param11            Varchar2(240) := NULL,
   param12            Varchar2(240) := NULL,
   param13            Varchar2(240) := NULL,
   param14            Varchar2(240) := NULL,
   param15            Varchar2(240) := NULL,
   param16            Varchar2(240) := NULL,
   param17            Varchar2(240) := NULL,
   param18            Varchar2(240) := NULL,
   param19            Varchar2(240) := NULL,
   param20            Varchar2(240) := NULL,
   param21            Varchar2(240) := NULL,
   param22            Varchar2(240) := NULL,
   param23            Varchar2(240) := NULL,
   param24            Varchar2(240) := NULL,
   param25            Varchar2(240) := NULL,
   long_param1        Varchar2(2000) := NULL,
   date_param1		  DATE := NULL,
   date_param2		  DATE := NULL,
   date_param3		  DATE := NULL,
   date_param4		  DATE := NULL,
   date_param5		  DATE := NULL,
   date_param6		  DATE := NULL,
   date_param7		  DATE := NULL,
   date_param8		  DATE := NULL,
   processed		  VARCHAR2(1)	:= 'N'
);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Record to store the entity that is logging the request. Is used
-- in deleting delayed requests logged by an entity that is being
-- cleared or deleted.
TYPE Requesting_Entity_Rec_Type IS RECORD
  (
   -- Object which is logging the delayed request
   -- ie LINE, ORDER, PRICE_ADJUSTMENT
   Entity_code         Varchar2(30):= NULL,
   -- Primary key for the entity e.g. header_id, line_id.
   Entity_id          Number := NULL,
   -- Index of the request being logged in the request table
   request_index	NUMBER := NULL
);

--  API Requesting entity table type.
TYPE Requesting_Entity_Tbl_Type IS TABLE OF Requesting_Entity_Rec_Type
    INDEX BY BINARY_INTEGER;

/* Name     Cancel_Line_Rec_Type
** Purpose  Submit a Cancelaltion Request.
*/
TYPE Cancel_Line_Rec_Type IS RECORD
(
Line_Id                        Number := Null
,Header_id                     Number := Null
,Cancellation_type              VARCHAR2(1) := OE_GLOBALS.G_FULL
    -- G_FULL for Completely Cancelling the line
    -- G_PARTAIL Partially cancelling the line
, Cancel_by_quantity            NUMBER   := FND_API.G_MISS_NUM
                -- Cancellation quantity for Partial Cancellation
, Cancellation_reason_code       VARCHAR2(30) := NULL
                -- Cancellation Reason
, Cancellation_comments          VARCHAR2(2000) := NULL
                -- Cancellation comments
, Security_result               VARCHAR2(30) := ''
                -- Security Result BLOCK : Processing constraints
                --                 REQUIRE_REASON   : The changes require
                                   -- Reason and comments to be specified
                --                 REQUIRE_HISTORY   : The changes require
                                   -- History to be recorded
, Business_object               VARCHAR2(30) := 'SALES_ORDER'
, Wf_item_type                  VARCHAR2(30) := 'OEOL'
, User_app_id                   NUMBER   := 300
                -- User requesting cancellation
, User_resp_id                  NUMBER   := FND_API.G_MISS_NUM
                -- Responbisilbity requesting cancellation
, Cancellation_result            VARCHAR2(10) := NULL
            -- OE_GLOBALS.G_CANCELED  cancelled sucessfully
            -- OE_GLOBALS.G_CANNOT_CANCEL could not cancel
            -- OE_GLOBALS.G_NOTIFIED cancellation requires approval and a
            -- a notification has been send out NOCOPY /* file.sql.39 change */
, Wf_cancellation              Varchar2(1) := 'N'
                -- Flag indicating if the cancellation is in response to
                -- a Notification approval and if so use the resloving
                -- responsibility id
, Resolving_activity_item_type    Varchar2(30)  := null
                -- Workflow which is to be executed if the user does not
                -- have privilages to peform such an action
, Resolving_activity_name Varchar2(30)  := null
                -- Activity which is to be executed if the user does not
                -- have privilages to peform such an action
, Resolving_responsibility_id     Number := null
);

TYPE Cancel_Line_Tbl_Type IS TABLE OF Cancel_Line_Rec_Type
                          INDEX BY BINARY_INTEGER;

--lkxu
Type Payment_Types_Rec_Type  is RECORD
(   PAYMENT_TRX_ID			NUMBER
,   COMMITMENT_APPLIED_AMOUNT	   	NUMBER
,   COMMITMENT_INTERFACED_AMOUNT	NUMBER
,   PAYMENT_LEVEL_CODE		VARCHAR2(30)
,   HEADER_ID				NUMBER
,   LINE_ID				NUMBER
,   CREATION_DATE		DATE
,   CREATED_BY			NUMBER
,   LAST_UPDATE_DATE		DATE
,   LAST_UPDATED_BY			NUMBER
,   LAST_UPDATE_LOGIN			NUMBER
,   REQUEST_ID				NUMBER
,   PROGRAM_APPLICATION_ID		NUMBER
,   PROGRAM_ID				NUMBER
,   PROGRAM_UPDATE_DATE			DATE
,   CONTEXT				VARCHAR2(30)
,   ATTRIBUTE1				VARCHAR2(240)
,   ATTRIBUTE2				VARCHAR2(240)
,   ATTRIBUTE3				VARCHAR2(240)
,   ATTRIBUTE4				VARCHAR2(240)
,   ATTRIBUTE5				VARCHAR2(240)
,   ATTRIBUTE6				VARCHAR2(240)
,   ATTRIBUTE7				VARCHAR2(240)
,   ATTRIBUTE8				VARCHAR2(240)
,   ATTRIBUTE9				VARCHAR2(240)
,   ATTRIBUTE10				VARCHAR2(240)
,   ATTRIBUTE11				VARCHAR2(240)
,   ATTRIBUTE12				VARCHAR2(240)
,   ATTRIBUTE13				VARCHAR2(240)
,   ATTRIBUTE14				VARCHAR2(240)
,   ATTRIBUTE15				VARCHAR2(240)
,   db_flag				VARCHAR2(1)
,   operation				VARCHAR2(30)
,   return_status			VARCHAR2(1)
);

TYPE  Payment_Types_Tbl_Type is TABLE of Payment_Types_Rec_Type
	INDEX by BINARY_INTEGER;

-- serla begin
-- Header Payment Record type'
TYPE Header_Payment_Rec_Type IS RECORD
( ATTRIBUTE1                     VARCHAR2(240)
, ATTRIBUTE2                     VARCHAR2(240)
, ATTRIBUTE3                     VARCHAR2(240)
, ATTRIBUTE4                     VARCHAR2(240)
, ATTRIBUTE5                     VARCHAR2(240)
, ATTRIBUTE6                     VARCHAR2(240)
, ATTRIBUTE7                     VARCHAR2(240)
, ATTRIBUTE8                     VARCHAR2(240)
, ATTRIBUTE9                     VARCHAR2(240)
, ATTRIBUTE10                    VARCHAR2(240)
, ATTRIBUTE11                    VARCHAR2(240)
, ATTRIBUTE12                    VARCHAR2(240)
, ATTRIBUTE13                    VARCHAR2(240)
, ATTRIBUTE14                    VARCHAR2(240)
, ATTRIBUTE15                    VARCHAR2(240)
, CHECK_NUMBER                   VARCHAR2(50)
, CREATED_BY                     NUMBER
, CREATION_DATE                  DATE
, CREDIT_CARD_APPROVAL_CODE      VARCHAR2(80)
, CREDIT_CARD_APPROVAL_DATE      DATE
, CREDIT_CARD_CODE               VARCHAR2(80)
, CREDIT_CARD_EXPIRATION_DATE    DATE
, CREDIT_CARD_HOLDER_NAME        VARCHAR2(80)
, CREDIT_CARD_NUMBER             VARCHAR2(80)
, COMMITMENT_APPLIED_AMOUNT      NUMBER
, COMMITMENT_INTERFACED_AMOUNT   NUMBER
, CONTEXT                        VARCHAR2(30)
, HEADER_ID                      NUMBER
, LAST_UPDATED_BY                NUMBER
, LAST_UPDATE_DATE               DATE
, LAST_UPDATE_LOGIN              NUMBER
, LINE_ID                        NUMBER
, PAYMENT_NUMBER                 NUMBER
, PAYMENT_PERCENTAGE             NUMBER -- Added for bug 8478559
, PAYMENT_AMOUNT                 NUMBER
, PAYMENT_COLLECTION_EVENT       VARCHAR2(30)
, PAYMENT_LEVEL_CODE             VARCHAR2(30)
, PAYMENT_TRX_ID                 NUMBER
, PAYMENT_TYPE_CODE              VARCHAR2(30)
, PAYMENT_SET_ID                 NUMBER
, PREPAID_AMOUNT                 NUMBER
, PROGRAM_APPLICATION_ID         NUMBER
, PROGRAM_ID                     NUMBER
, PROGRAM_UPDATE_DATE            DATE
, RECEIPT_METHOD_ID              NUMBER
, REQUEST_ID                     NUMBER
, TANGIBLE_ID                    VARCHAR2(80)
, TRXN_EXTENSION_ID              NUMBER
, ORIG_SYS_PAYMENT_REF           VARCHAR2(50)
, CHANGE_REQUEST_CODE            VARCHAR2(30)
, STATUS_FLAG                    VARCHAR2(1)
, RETURN_STATUS                  VARCHAR2(1)
, DB_FLAG                        VARCHAR2(1)
, OPERATION                      VARCHAR2(30)
, DEFER_PAYMENT_PROCESSING_FLAG  VARCHAR2(1)
, LOCK_CONTROL                   NUMBER
, INSTRUMENT_SECURITY_CODE	 VARCHAR2(10)  --R12 CC Encryption
, CC_INSTRUMENT_ID		 NUMBER
, CC_INSTRUMENT_ASSIGNMENT_ID    NUMBER --R12 CC Encryption
);

TYPE Header_Payment_Tbl_Type IS TABLE OF Header_Payment_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Payment value record type

TYPE Header_Payment_Val_Rec_Type IS RECORD
(   PAYMENT_COLLECTION_EVENT_NAME    VARCHAR2(80)
  , RECEIPT_METHOD                   VARCHAR2(30)
  , PAYMENT_TYPE                     VARCHAR2(80)
  , COMMITMENT                       VARCHAR2(20)
  , PAYMENT_PERCENTAGE               NUMBER
);

TYPE Header_Payment_Val_Tbl_Type IS TABLE OF Header_Payment_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Line Payment Record type
TYPE Line_Payment_Rec_Type IS RECORD
( ATTRIBUTE1                     VARCHAR2(240)
, ATTRIBUTE2                     VARCHAR2(240)
, ATTRIBUTE3                     VARCHAR2(240)
, ATTRIBUTE4                     VARCHAR2(240)
, ATTRIBUTE5                     VARCHAR2(240)
, ATTRIBUTE6                     VARCHAR2(240)
, ATTRIBUTE7                     VARCHAR2(240)
, ATTRIBUTE8                     VARCHAR2(240)
, ATTRIBUTE9                     VARCHAR2(240)
, ATTRIBUTE10                    VARCHAR2(240)
, ATTRIBUTE11                    VARCHAR2(240)
, ATTRIBUTE12                    VARCHAR2(240)
, ATTRIBUTE13                    VARCHAR2(240)
, ATTRIBUTE14                    VARCHAR2(240)
, ATTRIBUTE15                    VARCHAR2(240)
, CHECK_NUMBER                   VARCHAR2(50)
, CREATED_BY                     NUMBER
, CREATION_DATE                  DATE
, CREDIT_CARD_APPROVAL_CODE      VARCHAR2(80)
, CREDIT_CARD_APPROVAL_DATE      DATE
, CREDIT_CARD_CODE               VARCHAR2(80)
, CREDIT_CARD_EXPIRATION_DATE    DATE
, CREDIT_CARD_HOLDER_NAME        VARCHAR2(80)
, CREDIT_CARD_NUMBER             VARCHAR2(80)
, COMMITMENT_APPLIED_AMOUNT      NUMBER
, COMMITMENT_INTERFACED_AMOUNT   NUMBER
, CONTEXT                        VARCHAR2(30)
, HEADER_ID                      NUMBER
, LAST_UPDATED_BY                NUMBER
, LAST_UPDATE_DATE               DATE
, LAST_UPDATE_LOGIN              NUMBER
, LINE_ID                        NUMBER
, PAYMENT_NUMBER                 NUMBER
, PAYMENT_AMOUNT                 NUMBER
, PAYMENT_COLLECTION_EVENT       VARCHAR2(30)
, PAYMENT_LEVEL_CODE             VARCHAR2(30)
, PAYMENT_TRX_ID                 NUMBER
, PAYMENT_TYPE_CODE              VARCHAR2(30)
, PAYMENT_SET_ID                 NUMBER
, PREPAID_AMOUNT                 NUMBER
, PROGRAM_APPLICATION_ID         NUMBER
, PROGRAM_ID                     NUMBER
, PROGRAM_UPDATE_DATE            DATE
, RECEIPT_METHOD_ID              NUMBER
, REQUEST_ID                     NUMBER
, TANGIBLE_ID                    VARCHAR2(80)
, TRXN_EXTENSION_ID              NUMBER
, ORIG_SYS_PAYMENT_REF           VARCHAR2(50)
, CHANGE_REQUEST_CODE            VARCHAR2(30)
, STATUS_FLAG                    VARCHAR2(1)
, RETURN_STATUS                  VARCHAR2(1)
, DB_FLAG                        VARCHAR2(1)
, LINE_INDEX                     NUMBER
, OPERATION                      VARCHAR2(30)
, DEFER_PAYMENT_PROCESSING_FLAG  VARCHAR2(1)
, LOCK_CONTROL                   NUMBER
, INSTRUMENT_SECURITY_CODE	 VARCHAR2(10) --R12 CC Encryption
, CC_INSTRUMENT_ID		 NUMBER
, CC_INSTRUMENT_ASSIGNMENT_ID    NUMBER --R12 CC Encryption
);

TYPE Line_Payment_Tbl_Type IS TABLE OF Line_Payment_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Line_Payment value record type

TYPE Line_Payment_Val_Rec_Type IS RECORD
(   PAYMENT_COLLECTION_EVENT_NAME    VARCHAR2(80)
  , RECEIPT_METHOD                   VARCHAR2(30)
  , PAYMENT_TYPE                     VARCHAR2(80)
  , COMMITMENT                       VARCHAR2(20)
  , PAYMENT_PERCENTAGE               NUMBER
);

TYPE Line_Payment_Val_Tbl_Type IS TABLE OF Line_Payment_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--serla end

--ER7675548

TYPE CUSTOMER_INFO_REC_TYPE IS RECORD
(
customer_info_ref         VARCHAR2(50)         , -- Reference field to link with header/line record :MANDATORY
parent_customer_info_ref       VARCHAR2(50)    , -- Used to link ADDRESS/CONTACT REF to a CUSTOMER REF
customer_type             VARCHAR2(30)    , -- ORGANIZATION/PERSON :MANDATORY
customer_info_type_code   VARCHAR2(10)    , -- CUSTOMER/ADDRESS/CONTACT : MANDATORY
customer_id          NUMBER,		    -- Pass a valid customer_id from  if it is known
site_use_id          NUMBER,		    -- Pass a valid site_use_id from  if it is known
contact_id           NUMBER,		    -- Pass a valid contact_id from  if it is known
organization_name         VARCHAR2(360)   , -- Party Name
account_description  VARCHAR2(250),         -- Account Description Gets stored in HZ_CUST_ACCOUNTS.ACCOUNT_NAME
person_first_name         VARCHAR2(150)   , -- Party first name
person_middle_name        VARCHAR2(60)    , -- Party middle name
person_last_name          VARCHAR2(150)   , -- party last_name
person_name_suffix        VARCHAR2(30)    , -- Party name suffix
person_title              VARCHAR2(60)    , -- Party title
email_address             VARCHAR2(2000)  , -- Email address
customer_number           VARCHAR2(30)    , -- Pass a customer_number if automatic account numbering is OFF / existing customer's customer number
party_number              VARCHAR2(30)    , -- Pass a party_number if automatic party_numbering is OFF
location_number           VARCHAR2(40)    , -- Pass a value if automatic location numbering is OFF
site_number               VARCHAR2(80)    , -- Pass a value if automatic site numbering is OFF
contact_number            VARCHAR2(80)    , -- Pass a vlue if automatic contact numbering is OFF
party_id                  NUMBER,           -- Pass a valid HZ_PARTIES.party_id only if the new cust account should go under the existing party
phone_country_code        VARCHAR2(10)    , -- Phone Country Code
phone_area_code           VARCHAR2(10)    , -- Area Code
phone_number              VARCHAR2(40)    , -- Phone Number
phone_extension           VARCHAR2(20)    , -- Extension
--Address Fields
address_style             VARCHAR2(100)   , --Address Style from fnd_territories_vl
country                   VARCHAR2(60)    , -- Country
address1                  VARCHAR2(240)   , --Address Line 1
address2                  VARCHAR2(240)   , --Address Line 2
address3                  VARCHAR2(240)   , --Address Line 3
address4                  VARCHAR2(240)   , --Address Line 4
city                      VARCHAR2(60)    , -- City
postal_code               VARCHAR2(60)    , -- Postal code
state                     VARCHAR2(60)    , -- State
province                  VARCHAR2(60)    , -- Province
county                    VARCHAR2(60)    , -- County
address_line_phonetic     VARCHAR2(240)   , -- Address Line Phonetic
new_account_id            NUMBER          , -- For internal use only.Do not populate this attributes
--DFF Fields
attribute_category        VARCHAR2(30)    ,
attribute1                VARCHAR2(150)   ,
attribute2                VARCHAR2(150)   ,
attribute3                VARCHAR2(150)   ,
attribute4                VARCHAR2(150)   ,
attribute5                VARCHAR2(150)   ,
attribute6                VARCHAR2(150)   ,
attribute7                VARCHAR2(150)   ,
attribute8                VARCHAR2(150)   ,
attribute9                VARCHAR2(150)   ,
attribute10               VARCHAR2(150)   ,
attribute11               VARCHAR2(150)   ,
attribute12               VARCHAR2(150)   ,
attribute13               VARCHAR2(150)   ,
attribute14               VARCHAR2(150)   ,
attribute15               VARCHAR2(150)   ,
attribute16               VARCHAR2(150)   ,
attribute17               VARCHAR2(150)   ,
attribute18               VARCHAR2(150)   ,
attribute19               VARCHAR2(150)   ,
attribute20               VARCHAR2(150)   ,
attribute21               VARCHAR2(150)   ,
attribute22               VARCHAR2(150)   ,
attribute23               VARCHAR2(150)   ,
attribute24               VARCHAR2(150)   ,
attribute25               VARCHAR2(150)   ,
global_attribute_category VARCHAR2(30)    ,
global_attribute1         VARCHAR2(150)   ,
global_attribute2         VARCHAR2(150)   ,
global_attribute3         VARCHAR2(150)   ,
global_attribute4         VARCHAR2(150)   ,
global_attribute5         VARCHAR2(150)   ,
global_attribute6         VARCHAR2(150)   ,
global_attribute7         VARCHAR2(150)   ,
global_attribute8         VARCHAR2(150)   ,
global_attribute9         VARCHAR2(150)   ,
global_attribute10        VARCHAR2(150)   ,
global_attribute11        VARCHAR2(150)   ,
global_attribute12        VARCHAR2(150)   ,
global_attribute13        VARCHAR2(150)   ,
global_attribute14        VARCHAR2(150)   ,
global_attribute15        VARCHAR2(150)   ,
global_attribute16        VARCHAR2(150)   ,
global_attribute17        VARCHAR2(150)   ,
global_attribute18        VARCHAR2(150)   ,
global_attribute19        VARCHAR2(150)   ,
global_attribute20        VARCHAR2(150)   ,
orig_system               VARCHAR2(30)    ,
orig_system_reference      VARCHAR2(240)
);

TYPE CUSTOMER_INFO_TABLE_TYPE IS TABLE OF CUSTOMER_INFO_REC_TYPE INDEX BY BINARY_INTEGER;

FUNCTION G_MISS_CUSTOMER_INFO_REC RETURN CUSTOMER_INFO_REC_TYPE;

G_MISS_CUSTOMER_INFO_TBL CUSTOMER_INFO_TABLE_TYPE;

--ER7675548

--  Functions to return missing records. The following records have NULL
--  defaults on the record definitions therefore users will have to call
--  these functions to set missing values on the records
--  These functions have been included as a part of performance
--  related change for R11.I.2

FUNCTION G_MISS_HEADER_REC
	RETURN Header_Rec_Type;

FUNCTION G_MISS_HEADER_ADJ_REC
	RETURN Header_Adj_Rec_Type;

FUNCTION G_MISS_HEADER_PRICE_ATT_REC
	RETURN Header_Price_Att_Rec_Type;

FUNCTION G_MISS_HEADER_ADJ_ATT_REC
	RETURN Header_Adj_Att_Rec_Type;

FUNCTION G_MISS_HEADER_ADJ_ASSOC_REC
	RETURN Header_Adj_Assoc_Rec_Type;

FUNCTION G_MISS_HEADER_SCREDIT_REC
	RETURN Header_Scredit_Rec_Type;

-- performance bug 4571373, replace function with global record
G_MISS_LINE_REC Line_Rec_Type;

-- added for 4571373 for libraries
FUNCTION GET_G_MISS_LINE_REC
    RETURN Line_Rec_Type;

FUNCTION G_MISS_LINE_ADJ_REC
	RETURN Line_Adj_Rec_Type;

FUNCTION G_MISS_Line_Price_Att_Rec
	RETURN Line_Price_Att_Rec_Type;

FUNCTION G_MISS_Line_Adj_Att_Rec
	RETURN Line_Adj_Att_Rec_Type;

FUNCTION G_MISS_Line_Adj_Assoc_Rec
	RETURN Line_Adj_Assoc_Rec_Type;

FUNCTION G_MISS_LINE_SCREDIT_REC
	RETURN Line_Scredit_Rec_Type;

FUNCTION G_MISS_LOT_SERIAL_REC
	RETURN Lot_Serial_Rec_Type;

FUNCTION G_MISS_HEADER_VAL_REC
	RETURN Header_Val_Rec_Type;

FUNCTION G_MISS_HEADER_ADJ_VAL_REC
	RETURN Header_Adj_Val_Rec_Type;

FUNCTION G_MISS_HEADER_SCREDIT_VAL_REC
	RETURN Header_Scredit_Val_Rec_Type;

FUNCTION G_MISS_LINE_VAL_REC
	RETURN Line_Val_Rec_Type;

FUNCTION G_MISS_LINE_ADJ_VAL_REC
	RETURN Line_Adj_Val_Rec_Type;

FUNCTION G_MISS_LINE_SCREDIT_VAL_REC
	RETURN Line_Scredit_Val_Rec_Type;

FUNCTION G_MISS_LOT_SERIAL_VAL_REC
	RETURN Lot_Serial_Val_Rec_Type;

--lkxu
FUNCTION G_MISS_PAYMENT_TYPES_REC
	RETURN Payment_Types_Rec_Type;

--serla begin
FUNCTION G_MISS_HEADER_PAYMENT_REC
        RETURN Header_Payment_Rec_Type;

FUNCTION G_MISS_LINE_PAYMENT_REC
        RETURN Line_Payment_Rec_Type;

FUNCTION G_MISS_HEADER_PAYMENT_VAL_REC
        RETURN Header_Payment_Val_Rec_Type;

FUNCTION G_MISS_LINE_PAYMENT_VAL_REC
        RETURN Line_Payment_Val_Rec_Type;
--serla end

--  Variables representing missing records and tables

G_MISS_HEADER_TBL             Header_Tbl_Type;
G_MISS_HEADER_VAL_TBL         Header_Val_Tbl_Type;
G_MISS_HEADER_ADJ_TBL         Header_Adj_Tbl_Type;
G_MISS_HEADER_ADJ_VAL_TBL     Header_Adj_Val_Tbl_Type;
G_MISS_HEADER_PRICE_ATT_TBL	Header_Price_Att_Tbl_Type;
G_MISS_HEADER_ADJ_ATT_TBL	Header_Adj_Att_Tbl_Type;
G_MISS_HEADER_ADJ_ASSOC_TBL	Header_Adj_Assoc_Tbl_Type;
G_MISS_HEADER_SCREDIT_TBL     Header_Scredit_Tbl_Type;
G_MISS_HEADER_SCREDIT_VAL_TBL Header_Scredit_Val_Tbl_Type;
G_MISS_LINE_TBL               Line_Tbl_Type;
G_MISS_LINE_VAL_TBL           Line_Val_Tbl_Type;
G_MISS_LINE_ADJ_TBL           Line_Adj_Tbl_Type;
G_MISS_LINE_ADJ_VAL_TBL       Line_Adj_Val_Tbl_Type;
G_MISS_LINE_PRICE_ATT_TBL	Line_Price_Att_Tbl_Type;
G_MISS_LINE_ADJ_ATT_TBL		Line_Adj_Att_Tbl_Type;
G_MISS_LINE_ADJ_ASSOC_TBL	Line_Adj_Assoc_Tbl_Type;
G_MISS_LINE_SCREDIT_TBL       Line_Scredit_Tbl_Type;
G_MISS_LINE_SCREDIT_VAL_TBL   Line_Scredit_Val_Tbl_Type;
G_MISS_LOT_SERIAL_TBL         Lot_Serial_Tbl_Type;
G_MISS_LOT_SERIAL_VAL_TBL     Lot_Serial_Val_Tbl_Type;
G_MISS_RESERVATION_REC        Reservation_Rec_Type;
G_MISS_RESERVATION_VAL_REC    Reservation_Val_Rec_Type;
G_MISS_RESERVATION_TBL        Reservation_Tbl_Type;
G_MISS_RESERVATION_VAL_TBL    Reservation_Val_Tbl_Type;
G_MISS_SET_REC		      Set_Rec_Type;
G_MISS_LINE_SET_REC	      Line_Set_Rec_Type;
G_MISS_REQUEST_REC            Request_Rec_Type;
G_MISS_REQUEST_TBL            Request_Tbl_Type;
--serla begin
G_MISS_HEADER_PAYMENT_TBL     Header_Payment_Tbl_Type;
G_MISS_HEADER_PAYMENT_VAL_TBL Header_Payment_Val_Tbl_Type;
G_MISS_LINE_PAYMENT_TBL     Line_Payment_Tbl_Type;
G_MISS_LINE_PAYMENT_VAL_TBL    Line_Payment_Val_Tbl_Type;
--serla end

--Global Variables for Attribute Mapping during Pricing
G_HDR		header_rec_type;
G_LINE		line_rec_type;


--  Start of Comments
--  API name    Process_Order
--  Type        Public
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

PROCEDURE Process_Order
(   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_action_commit                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_old_header_rec                IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  Header_Adj_Att_Tbl_Type :=
    G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl        IN  Header_Adj_Assoc_Tbl_Type :=
    G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  Line_Adj_Att_Tbl_Type :=
    G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl          IN  Line_Adj_Assoc_Tbl_Type :=
    G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	    IN  Request_Tbl_Type :=
					G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612

--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                         OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
);


--  Start of Comments
--  API name    Lock_Order
--  Type        Public
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


PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,  p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Order
--  Type        Public
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

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

PROCEDURE Id_To_Value
(   p_header_rec                    IN  Header_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

/*#
* Use this procedure to retrieve sales order attribute IDs when supplying value information for those attributes.  For instance, the Sold To Organization name could be provided in order to retrieve the Sold To Organization ID.
*	@param	 	p_header_rec	Input record structure containing header-level ID information for an order
*	@param	 	p_header_val_rec	Input record structure containing header-level value information for an order
*	@param	 	p_Header_Adj_tbl	Input table containing header-level ID information for price adjustments
*	@param	 	p_Header_Adj_val_tbl	Input table containing header-level value information for price adjustments
*	@param	 	p_Header_Scredit_tbl	Input table containing header-level ID information for sales credits
*	@param	 	p_Header_Scredit_val_tbl	Input table containing header-level value information for sales credits
*	@param		p_Header_Payment_tbl	Input table containing current header-level ID information for payments
*	@param		p_Header_Payment_val_tbl	Input table containing current header-level value information for payments
*	@param	 	p_line_tbl	Input table containing line-level ID information for an order
*	@param	 	p_line_val_tbl	Input table containing line-level value information for an order
*	@param	 	p_Line_Adj_tbl	Input table containing line-level ID information for price adjustments
*	@param	 	p_Line_Adj_val_tbl	Input table containing line-level value information for price adjustments
*	@param	 	p_Line_Scredit_tbl	Input table containing line-level ID information for sales credits
*	@param	 	p_Line_Scredit_val_tbl	Input table containing line-level value information for sales credits
*	@param		p_Line_Payment_val_tbl	Input table containing current line-level value information for payments
*	@param		p_Line_Payment_tbl	Input table containing current line-level ID information for payments
*	@param	 	p_Lot_Serial_tbl	Input table containing ID information for lot and serial numbers
*	@param	 	p_Lot_Serial_val_tbl	Input table containing value information for lot and serial numbers
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_header_rec	Output record structure containing header-level ID information for an order
*	@param	 	x_Header_Adj_tbl	Output table containing header-level ID information for price adjustments
*	@param	 	x_Header_Scredit_tbl	Output table containing header-level ID information for sales credits
*	@param		x_Header_Payment_tbl	Output table containing current header-level ID information for payments
*	@param	 	x_line_tbl	Output table containing line-level ID information for an order
*	@param	 	x_Line_Adj_tbl	Output table containing line-level ID information for price adjustments
*	@param	 	x_Line_Scredit_tbl	Output table containing line-level ID information for sales credits
*	@param		x_Line_Payment_tbl	Output table containing current line-level ID information for payments
*	@param	 	x_Lot_Serial_tbl	Output table containing ID information for lot and serial numbers
*	@param	 	x_return_status	Return status of API call
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Value To ID
*/
PROCEDURE Value_To_Id
(   p_header_rec                    IN  Header_Rec_Type
,   p_header_val_rec                IN  Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type
,   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Value_To_Id (
    p_header_rec                    IN  Header_Rec_Type
,   p_header_val_rec                IN  Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);




/*#
* Use this procedure to process the creation, update, and deletion of sales order lines in the Order Management system.
*	@param	 	p_line_tbl	Input table containing line-level ID information for an order
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_line_out_tbl	Output table containing line-level ID information for an order
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Process Order Line
*/
PROCEDURE Process_Line
(
    p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_line_out_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/*#
* Use this procedure to process the creation, update, or deletion of a sales order header in the Order Management system.
*	@param	 	p_header_rec	Input record structure containing header-level ID information for an order
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_header_out_rec	Output record structure containing header-level ID information for an order
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Process Order Header
*/
PROCEDURE Process_header
(
    p_header_rec                      IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_out_rec                      OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


/*#
* Use this procedure to delete a sales order in the Order Management system.
*	@param	 	p_header_ID	Input Header ID
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Delete Order
*/
PROCEDURE Delete_Order
(
    p_header_id                      NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/*#
* Use this procedure to delete a sales order line in the Order Management system.
*	@param	 	p_line_ID	Input Line ID
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Delete Order Line
*/
PROCEDURE Delete_Line
(
    p_line_id                       NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/*#
* Use this procedure to update a sales order header in the Order Management system.
*	@param	 	p_header_ID	Input Header ID
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	p_header_val_rec	Input record structure containing header-level value information for an order
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Update Order Header
*/
PROCEDURE update_header
(
    p_header_id			   IN NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_header_val_rec               IN  Header_val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/*#
* Use this procedure to update a sales order line in the Order Management system.
*	@param	 	p_Line_id	Input Header ID
*	@param	 	p_line_val_rec	Input record structure containing line-level value information for an order
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Update Order Line
*/
PROCEDURE Update_Line
(
    p_line_id			   IN   NUMBER
,   p_line_val_rec                 IN  Line_Val_rec_Type :=
                                        G_MISS_LINE_VAL_REC
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


-- overloaded the public APIs.  The existing API will call these new API with the new parameters set as NULL.
/*#
* Use this procedure to create, update or delete Sales Orders in the Order Management system.  In addition
* to allowing direct changes to the sales order, this API supports the application of header and line level
* price adjustments, pricing attributes, sales credits, and payments.  Lot and Serial number information are
* supported for return lines.  Process Order also supports action requests that allow users to execute a variety
* of actions such as booking, hold application and removal, automatic attachments, fullfillment set application
* and removal, match and reserve for Configured items, get ship method and freight rates (both individually
* and together), and the linking and delinking of Configured items.
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	p_api_version_number	API version used to check call compatibility
*	@param	 	p_init_msg_list	Boolean which determines whether internal message tables should be initialized
*	@param	 	p_return_values	Boolean which determines whether ids should be converted to values for population in the output value parameters
*	@param	 	p_action_commit	Not used
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@param	 	p_header_rec	Input record structure containing current header-level ID information for an order
*	@param	 	p_old_header_rec	Input record structure containing old header-level ID information for an order
*	@param	 	p_header_val_rec	Input record structure containing current header-level value information for an order
*	@param	 	p_old_header_val_rec	Input record structure containing old header-level value information for an order
*	@param	 	p_Header_Adj_tbl	Input table containing current header-level ID information for price adjustments
*	@param	 	p_old_Header_Adj_tbl	Input table containing old header-level ID information for price adjustments
*	@param	 	p_Header_Adj_val_tbl	Input table containing current header-level value information for price adjustments
*	@param	 	p_old_Header_Adj_val_tbl	Input table containing old header-level value information for price adjustments
*	@param	 	p_Header_price_Att_tbl	Input table containing current header-level information for pricing attributes
*	@param	 	p_old_Header_Price_Att_tbl	Input table containing old header-level information for pricing attributes
*	@param	 	p_Header_Adj_Att_tbl	Input table containing current header-level adjustment attributes
*	@param	 	p_old_Header_Adj_Att_tbl	Input table containing old header-level adjustment attributes
*	@param	 	p_Header_Adj_Assoc_tbl	Input table containing current information about relationships between header-level adjustments
*	@param	 	p_old_Header_Adj_Assoc_tbl	Input table containing old information about relationships between header-level adjustments
*	@param	 	p_Header_Scredit_tbl	Input table containing current header-level ID information for sales credits
*	@param	 	p_old_Header_Scredit_tbl	Input table containing old header-level ID information for sales credits
*	@param	 	p_Header_Scredit_val_tbl	Input table containing current header-level value information for sales credits
*	@param	 	p_old_Header_Scredit_val_tbl	Input table containing old header-level value information for sales credits
*	@param		p_Header_Payment_tbl	Input table containing current header-level ID information for payments
*	@param		p_old_Header_Payment_tbl	 Input table containing old header-level ID information for payments
*	@param		p_Header_Payment_val_tbl	Input table containing current header-level value information for payments
*	@param		p_old_Header_Payment_val_tbl	Input table containing old header-level value information for payments
*	@param	 	p_line_tbl	Input table containing current line-level ID information for an order
*	@param	 	p_old_line_tbl	Input table containing old line-level ID information for an order
*	@param	 	p_line_val_tbl	Input table containing current line-level value information for an order
*	@param	 	p_old_line_val_tbl	Input table containing old line-level value information for an order
*	@param	 	p_Line_Adj_tbl	Input table containing current line-level ID information for price adjustments
*	@param	 	p_old_Line_Adj_tbl	Input table containing old line-level ID information for price adjustments
*	@param	 	p_Line_Adj_val_tbl	Input table containing current line-level value information for price adjustments
*	@param	 	p_old_Line_Adj_val_tbl	Input table containing old line-level value information for price adjustments
*	@param	 	p_Line_price_Att_tbl	Input table containing current line-level information for pricing attributes
*	@param	 	p_old_Line_Price_Att_tbl	Input table containing old line-level information for pricing attributes
*	@param	 	p_Line_Adj_Att_tbl	Input table containing current line-level adjustment attributes
*	@param	 	p_old_Line_Adj_Att_tbl	Input table containing old line-level adjustment attributes
*	@param	 	p_Line_Adj_Assoc_tbl	Input table containing current information about relationships between line-level adjustments
*	@param	 	p_old_Line_Adj_Assoc_tbl	Input table containing old information about relationships between line-level adjustments
*	@param	 	p_Line_Scredit_tbl	Input table containing current line-level ID information for sales credits
*	@param	 	p_old_Line_Scredit_tbl	Input table containing old line-level ID information for sales credits
*	@param	 	p_Line_Scredit_val_tbl	Input table containing current line-level value information for sales credits
*	@param	 	p_old_Line_Scredit_val_tbl	Input table containing old line-level value information for sales credits
*	@param	 	p_Line_Payment_tbl	Input table containing current line-level ID information for payments
*	@param	 	p_old_Line_Payment_tbl	Input table containing old line-level ID information for payments
*	@param	 	p_Line_Payment_val_tbl	Input table containing current line-level value information for payments
*	@param	 	p_old_Line_Payment_val_tbl	Input table containing current line-level value information for payments
*	@param	 	p_Lot_Serial_tbl	Input table containing current ID information for lot and serial numbers
*	@param	 	p_old_Lot_Serial_tbl	Input table containing old ID information for lot and serial numbers
*	@param	 	p_Lot_Serial_val_tbl	Input table containing current value information for lot and serial numbers
*	@param	 	p_old_Lot_Serial_val_tbl	Input table containing old value information for lot and serial numbers
*	@param	 	p_action_request_tbl	Input table containing delayed requests
*	@param	 	x_header_rec	Output record structure containing current header-level ID information for an order
*	@param	 	x_header_val_rec	Output record structure containing current header-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Header_Adj_tbl	Output table containing current header-level ID information for price adjustments
*	@param	 	x_Header_Adj_val_tbl	Output table containing current header-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Header_price_Att_tbl	Output table containing current header-level information for pricing attributes
*	@param	 	x_Header_Adj_Att_tbl	Output table containing current header-level adjustment attributes
*	@param	 	x_Header_Adj_Assoc_tbl	Output table containing current information about relationships between header-level adjustments
*	@param	 	x_Header_Scredit_tbl	Output table containing current header-level ID information for sales credits
*	@param	 	x_Header_Scredit_val_tbl	Output table containing current header-level value information for sales credits (if p_return_values was passed as true)
*	@param		x_Header_Payment_tbl	Output table containing current header-level ID information for payments
*	@param		x_Header_Payment_val_tbl	Output table containing current header-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_line_tbl	Output table containing current line-level ID information for an order
*	@param	 	x_line_val_tbl	Output table containing current line-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Line_Adj_tbl	Output table containing current line-level ID information for price adjustments
*	@param	 	x_Line_Adj_val_tbl	Output table containing current line-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Line_price_Att_tbl	Output table containing current line-level information for pricing attributes
*	@param	 	x_Line_Adj_Att_tbl	Output table containing current line-level adjustment attributes
*	@param	 	x_Line_Adj_Assoc_tbl	Output table containing current information about relationships between line-level adjustments
*	@param	 	x_Line_Scredit_tbl	Output table containing current line-level ID information for sales credits
*	@param	 	x_Line_Scredit_val_tbl	Output table containing current line-level value information for sales credits (if p_return_values was passed as true)
*	@param	 	x_Line_Payment_tbl	Output table containing current line-level ID information for payments
*	@param	 	x_Line_Payment_val_tbl	Output table containing current line-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_Lot_Serial_tbl	Output table containing current ID information for lot and serial numbers
*	@param	 	x_Lot_Serial_val_tbl	Output table containing current value information for lot and serial numbers (if p_return_values was passed as true)
*	@param	 	x_action_request_tbl	Output table containing delayed requests
*	@param		p_rtrim_data	Parameter specifying whether to right-trim the input data
*   @param      p_validate_desc_flex   Parameter specifying whether descriptive flex field validation is to be performed
*   @param      p_header_customer_info_tbl Input table containing new customer/address/contact information to be created
*   @param      p_line_customer_info_tbl   Input table (Line Level) containing new customer/address/contact information to be created
*	@rep:scope	 	public
*	@rep:metalink	 	91798.1	Order Management Suite Documentation
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Maintain Sales Order
*/
PROCEDURE Process_Order
(   p_org_id                        IN  NUMBER  := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_action_commit                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_old_header_rec                IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  Header_Adj_Att_Tbl_Type :=
    G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl        IN  Header_Adj_Assoc_Tbl_Type :=
    G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        IN  Header_Payment_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl    IN  Header_Payment_Val_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  Line_Adj_Att_Tbl_Type :=
    G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl          IN  Line_Adj_Assoc_Tbl_Type :=
    G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl      IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	    IN  Request_Tbl_Type :=
					G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                         OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
);

/*#
* Use this procedure to lock a sales order in the Order Management System.  Sales orders cannot be modified while locked.
*	@param	 	p_api_version_number	API version used to check call compatibility
*	@param	 	p_init_msg_list	Boolean which determines whether internal message tables should be initialized
*	@param	 	p_return_values	Boolean which determines whether ids should be converted to values for population in the output value parameters
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@param	 	p_header_rec	Input record structure containing header-level ID information for an order
*	@param	 	p_header_val_rec	Input record structure containing header-level value information for an order
*	@param	 	p_Header_Adj_tbl	Input table containing header-level ID information for price adjustments
*	@param	 	p_Header_Adj_val_tbl	Input table containing header-level value information for price adjustments
*	@param	 	p_Header_price_Att_tbl	Input table containing header-level information for pricing attributes
*	@param	 	p_Header_Adj_Att_tbl	Input table containing header-level adjustment attributes
*	@param	 	p_Header_Adj_Assoc_tbl	Input table containing information about relationships between header-level adjustments
*	@param	 	p_Header_Scredit_tbl	Input table containing header-level ID information for sales credits
*	@param	 	p_Header_Scredit_val_tbl	Input table containing header-level value information for sales credits
*	@param		p_Header_Payment_tbl	Input table containing current header-level ID information for payments
*	@param		p_Header_Payment_val_tbl	Input table containing current header-level value information for payments
*	@param	 	p_line_tbl	Input table containing line-level ID information for an order
*	@param	 	p_line_val_tbl	Input table containing line-level value information for an order
*	@param	 	p_Line_Adj_tbl	Input table containing line-level ID information for price adjustments
*	@param	 	p_Line_Adj_val_tbl	Input table containing line-level value information for price adjustments
*	@param	 	p_Line_price_Att_tbl	Input table containing line-level information for pricing attributes
*	@param	 	p_Line_Adj_Att_tbl	Input table containing line-level adjustment attributes
*	@param	 	p_Line_Adj_Assoc_tbl	Input table containing information about relationships between line-level adjustments
*	@param	 	p_Line_Scredit_tbl	Input table containing line-level ID information for sales credits
*	@param	 	p_Line_Scredit_val_tbl	Input table containing line-level value information for sales credits
*	@param		p_Line_Payment_tbl	Input table containing current line-level ID information for payments
*	@param		p_Line_Payment_val_tbl	Input table containing current line-level value information for payments
*	@param	 	p_Lot_Serial_tbl	Input table containing ID information for lot and serial numbers
*	@param	 	p_Lot_Serial_val_tbl	Input table containing value information for lot and serial numbers
*	@param	 	x_header_rec	Output record structure containing header-level ID information for an order
*	@param	 	x_header_val_rec	Output record structure containing header-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Header_Adj_tbl	Output table containing header-level ID information for price adjustments
*	@param	 	x_Header_Adj_val_tbl	Output table containing header-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Header_price_Att_tbl	Output table containing header-level information for pricing attributes
*	@param	 	x_Header_Adj_Att_tbl	Output table containing header-level adjustment attributes
*	@param	 	x_Header_Adj_Assoc_tbl	Output table containing information about relationships between header-level adjustments
*	@param	 	x_Header_Scredit_tbl	Output table containing header-level ID information for sales credits
*	@param	 	x_Header_Scredit_val_tbl	Output table containing header-level value information for sales credits (if p_return_values was passed as true)
*	@param		x_Header_Payment_tbl	Output table containing current header-level ID information for payments
*	@param		x_Header_Payment_val_tbl	Output table containing current header-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_line_tbl	Output table containing line-level ID information for an order
*	@param	 	x_line_val_tbl	Output table containing line-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Line_Adj_tbl	Output table containing line-level ID information for price adjustments
*	@param	 	x_Line_Adj_val_tbl	Output table containing line-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Line_price_Att_tbl	Output table containing line-level information for pricing attributes
*	@param	 	x_Line_Adj_Att_tbl	Output table containing line-level adjustment attributes
*	@param	 	x_Line_Adj_Assoc_tbl	Output table containing information about relationships between line-level adjustments
*	@param	 	x_Line_Scredit_tbl	Output table containing line-level ID information for sales credits
*	@param	 	x_Line_Scredit_val_tbl	Output table containing line-level value information for sales credits (if p_return_values was passed as true)
*	@param		x_Line_Payment_tbl	Output table containing current line-level ID information for payments
*	@param		x_Line_Payment_val_tbl	Output table containing current line-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_Lot_Serial_tbl	Output table containing ID information for lot and serial numbers
*	@param	 	x_Lot_Serial_val_tbl	Output table containing value information for lot and serial numbers (if p_return_values was passed as true)
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Lock Sales Order
 */
PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,  p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

/*#
* Use this procedure to retrieve the information about a Sales Order, including price adjustments, pricing attributes, sales credits, payments, and lot and serial number information for return lines.
*	@param	 	p_api_version_number	API version used to check call compatibility
*	@param	 	p_init_msg_list	Boolean which determines whether internal message tables should be initialized
*	@param	 	p_return_values	Boolean which determines whether ids should be converted to values for population in the output value parameters
*	@param	 	x_return_status	Return status of API call
*	@param	 	x_msg_count	Number of stored processing messages
*	@param	 	x_msg_data	Processing message data
*	@param	 	p_header_id	Input Header ID
*	@param	 	p_header	Input record structure containing header-level ID information for an order
*   @param      p_org_id    Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_header_rec	Output record structure containing header-level ID information for an order
*	@param	 	x_header_val_rec	Output record structure containing header-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Header_Adj_tbl	Output table containing header-level ID information for price adjustments
*	@param	 	x_Header_Adj_val_tbl	Output table containing header-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Header_price_Att_tbl	Output table containing header-level information for pricing attributes
*	@param	 	x_Header_Adj_Att_tbl	Output table containing header-level adjustment attributes
*	@param	 	x_Header_Adj_Assoc_tbl	Output table containing information about relationships between header-level adjustments
*	@param	 	x_Header_Scredit_tbl	Output table containing header-level ID information for sales credits
*	@param	 	x_Header_Scredit_val_tbl	Output table containing header-level value information for sales credits (if p_return_values was passed as true)
*	@param		x_Header_Payment_tbl	Output table containing current header-level ID information for payments
*	@param		x_Header_Payment_val_tbl	Output table containing current header-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_line_tbl	Output table containing line-level ID information for an order
*	@param	 	x_line_val_tbl	Output table containing line-level value information for an order (if p_return_values was passed as true)
*	@param	 	x_Line_Adj_tbl	Output table containing line-level ID information for price adjustments
*	@param	 	x_Line_Adj_val_tbl	Output table containing line-level value information for price adjustments (if p_return_values was passed as true)
*	@param	 	x_Line_price_Att_tbl	Output table containing line-level information for pricing attributes
*	@param	 	x_Line_Adj_Att_tbl	Output table containing line-level adjustment attributes
*	@param	 	x_Line_Adj_Assoc_tbl	Output table containing information about relationships between line-level adjustments
*	@param	 	x_Line_Scredit_tbl	Output table containing line-level ID information for sales credits
*	@param	 	x_Line_Scredit_val_tbl	Output table containing line-level value information for sales credits (if p_return_values was passed as true)
*	@param		x_Line_Payment_tbl	Output table containing current line-level ID information for payments
*	@param		x_Line_Payment_val_tbl	Output table containing current line-level value information for payments (if p_return_values was passed as true)
*	@param	 	x_Lot_Serial_tbl	Output table containing ID information for lot and serial numbers
*	@param	 	x_Lot_Serial_val_tbl	Output table containing value information for lot and serial numbers (if p_return_values was passed as true)
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	Get Sales Order
*/
PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

/*#
* Use this procedure to retrieve sales order attribute values when supplying the ID information for those attributes.  For instance, the Sold To Organization ID could be provided in order to retrieve the Sold To Organization name.
*	@param	 	p_header_rec	Input record structure containing header-level ID information for an order
*	@param	 	p_Header_Adj_tbl	Input table containing header-level ID information for price adjustments
*	@param	 	p_Header_Scredit_tbl	Input table containing header-level ID information for sales credits
*	@param		p_Header_Payment_tbl	Input table containing current header-level ID information for payments
*	@param	 	p_line_tbl	Input table containing line-level ID information for an order
*	@param	 	p_Line_Adj_tbl	Input table containing line-level ID information for price adjustments
*	@param	 	p_Line_Scredit_tbl	Input table containing line-level ID information for sales credits
*	@param		p_Line_Payment_tbl	Input table containing current line-level ID information for payments
*	@param		p_Lot_Serial_tbl	Input table containing id information for lot serials
*   @param      p_org_id   Input OU Organization Id
*   @param      p_operating_unit   Input Operating Unit Name
*	@param	 	x_header_val_rec	Output record structure containing header-level value information for an order
*	@param	 	x_Header_Adj_val_tbl	Output table containing header-level value information for price adjustments
*	@param	 	x_Header_Scredit_val_tbl	Output table containing header-level value information for sales credits
*	@param		x_Header_Payment_val_tbl	Output table containing current header-level value information for payments
*	@param	 	x_line_val_tbl	Output table containing line-level value information for an order
*	@param	 	x_Line_Adj_val_tbl	Output table containing line-level value information for price adjustments
*	@param	 	x_Line_Scredit_val_tbl	Output table containing line-level value information for sales credits
*	@param		x_Line_Payment_val_tbl	Output table containing current line-level value information for payments
*	@param	 	x_Lot_Serial_val_tbl	Output table containing value information for lot and serial numbers
*	@rep:scope	 	public
*	@rep:lifecycle	 	active
*	@rep:category	BUSINESS_ENTITY	ONT_SALES_ORDER
*	@rep:displayname	 	ID To Value
*/
PROCEDURE Id_To_Value
(   p_header_rec                    IN  Header_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
);

Procedure Process_MACD_Order
(p_api_version_number     IN  NUMBER,
 p_organization_id        IN  NUMBER,
 p_sold_to_org_id         IN  NUMBER,
 p_header_id              IN  NUMBER,
 p_MACD_Action            IN  VARCHAR2,
 p_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 p_x_line_tbl             IN  OUT NOCOPY Line_Tbl_Type,
 p_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,x_container_line_id      OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2
);


END OE_Order_PUB;

/

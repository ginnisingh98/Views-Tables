--------------------------------------------------------
--  DDL for Package OE_OE_PRICING_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_PRICING_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: OEXFPRAS.pls 120.1.12010000.4 2009/12/22 22:48:24 rmoharan ship $ */


--added for bug 3559935

TYPE User_Attribute_Rec_Type IS RECORD
(	context_name		VARCHAR2(30)
,	attribute_name		VARCHAR2(240)
);

TYPE User_Attribute_Tbl_Type IS TABLE OF User_Attribute_Rec_Type INDEX BY BINARY_INTEGER;

--end 3559935

--added for bug 3245976

g_mrp_error_msg varchar2(1000) :=NULL;
g_mrp_error_msg_flag char(1) :='F';

--end bug 3245976
--start 3440778
TYPE agreement_rec IS RECORD
(
     agreement_name             VARCHAR2(300)
    ,agreement_id               NUMBER
    ,agreement_type             VARCHAR2(30)
    ,price_list_name            VARCHAR2(240)
    ,customer_name              VARCHAR2(360)
    ,payment_term_name          VARCHAR2(15)
    ,start_date_active          DATE
    ,end_date_active            DATE
);

TYPE agreement_tbl IS TABLE OF agreement_rec INDEX BY BINARY_INTEGER;
  -- end   bug 3440778
TYPE PA_Header_Rec_Type IS RECORD
(   accounting_rule_id            NUMBER
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
,   ship_to_customer_party_id     NUMBER
,   deliver_to_customer_party_id  NUMBER
,   invoice_to_customer_party_id  NUMBER
,   ship_to_org_contact_id      NUMBER
,   deliver_to_org_contact_id	  NUMBER
,   invoice_to_org_contact_id   NUMBER,
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
    );

TYPE PA_Header_Tbl_Type IS TABLE OF PA_Header_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Adj record type

TYPE PA_H_Adj_Rec_Type IS RECORD
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
,   invoiced_amount                NUMBER,
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
    );

TYPE PA_H_Adj_Tbl_Type IS TABLE OF PA_H_Adj_Rec_Type
    INDEX BY BINARY_INTEGER;


Type PA_H_Adj_AsRec_Type  is RECORD
(
 price_adj_assoc_id      number
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
, lock_control           NUMBER,
 p_char_attribute1        varchar2(240),
 p_char_attribute2        varchar2(240),
 p_char_attribute3        varchar2(240),
 p_char_attribute4        varchar2(240),
 p_char_attribute5        varchar2(240),
 p_char_attribute6        varchar2(240),
 p_char_attribute7        varchar2(240),
 p_char_attribute8        varchar2(240),
 p_char_attribute9        varchar2(240),
 p_char_attribute10       varchar2(240),
 p_num_attribute1         number,
 p_num_attribute2         number,
 p_num_attribute3         number,
 p_num_attribute4         number,
 p_num_attribute5         number,
 p_num_attribute6         number,
 p_num_attribute7         number,
 p_num_attribute8         number,
 p_num_attribute9         number,
 p_num_attribute10        number,
 p_date_attribute1        date,
 p_date_attribute2        date,
 p_date_attribute3        date,
 p_date_attribute4        date,
 p_date_attribute5        date
 );


TYPE  PA_H_Adj_AsTbl_Type is TABLE of PA_H_Adj_Asrec_Type
	INDEX by BINARY_INTEGER;



-- Header_Price_Att_Rec_Type

TYPE PA_H_PAtt_Rec_Type IS RECORD
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
,       change_request_code     VARCHAR2(30),
	p_char_attribute1        varchar2(240),
	p_char_attribute2        varchar2(240),
	p_char_attribute3        varchar2(240),
	p_char_attribute4        varchar2(240),
	p_char_attribute5        varchar2(240),
	p_char_attribute6        varchar2(240),
	p_char_attribute7        varchar2(240),
	p_char_attribute8        varchar2(240),
	p_char_attribute9        varchar2(240),
	p_char_attribute10       varchar2(240),
	p_num_attribute1         number,
	p_num_attribute2         number,
	p_num_attribute3         number,
	p_num_attribute4         number,
	p_num_attribute5         number,
	p_num_attribute6         number,
	p_num_attribute7         number,
	p_num_attribute8         number,
	p_num_attribute9         number,
	p_num_attribute10        number,
	p_date_attribute1        date,
	p_date_attribute2        date,
	p_date_attribute3        date,
	p_date_attribute4        date,
	p_date_attribute5        date

)
;

TYPE PA_H_PAtt_Tbl_Type is TABLE of PA_H_PAtt_rec_Type
	INDEX by BINARY_INTEGER;

Type PA_H_Adj_Att_Rec_Type is RECORD
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
, lock_control           NUMBER,
  p_char_attribute1        varchar2(240),
  p_char_attribute2        varchar2(240),
  p_char_attribute3        varchar2(240),
  p_char_attribute4        varchar2(240),
  p_char_attribute5        varchar2(240),
  p_char_attribute6        varchar2(240),
  p_char_attribute7        varchar2(240),
  p_char_attribute8        varchar2(240),
  p_char_attribute9        varchar2(240),
  p_char_attribute10       varchar2(240),
  p_num_attribute1         number,
  p_num_attribute2         number,
  p_num_attribute3         number,
  p_num_attribute4         number,
  p_num_attribute5         number,
  p_num_attribute6         number,
  p_num_attribute7         number,
  p_num_attribute8         number,
  p_num_attribute9         number,
  p_num_attribute10        number,
  p_date_attribute1        date,
  p_date_attribute2        date,
  p_date_attribute3        date,
  p_date_attribute4        date,
  p_date_attribute5        date
  );


TYPE  PA_H_Adj_Att_Tbl_Type is TABLE of PA_H_Adj_Att_rec_Type
	INDEX by BINARY_INTEGER;


--  Line record type

TYPE PA_Line_Rec_Type IS RECORD
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
,   preferred_grade               VARCHAR2(150)    -- -- INVCONV 4091955
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
,   ship_to_customer_party_id     NUMBER
,   deliver_to_customer_party_id  NUMBER
,   invoice_to_customer_party_id  NUMBER
,   ship_to_org_contact_id      NUMBER
,   deliver_to_org_contact_id	  NUMBER
,   invoice_to_org_contact_id   NUMBER,
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
);

TYPE PA_Line_Tbl_Type IS TABLE OF PA_Line_Rec_Type
    INDEX BY BINARY_INTEGER;


--  Line_Adj record type

TYPE PA_LAdj_Rec_Type IS RECORD
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
,   invoiced_amount                NUMBER,
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
    );

TYPE PA_LAdj_Tbl_Type IS TABLE OF PA_LAdj_Rec_Type
    INDEX BY BINARY_INTEGER;

-- Line_Price_Att_Rec_Type

TYPE PA_Line_PAtt_Rec_Type IS RECORD
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
,   change_request_code     VARCHAR2(30),
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
    );

TYPE  PA_Line_PAtt_Tbl_Type is TABLE of PA_Line_PAtt_rec_Type
	INDEX by BINARY_INTEGER;

Type PA_LAdj_Att_Rec_Type is RECORD
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
,   lock_control                NUMBER,
    p_char_attribute1        varchar2(240),
    p_char_attribute2        varchar2(240),
    p_char_attribute3        varchar2(240),
    p_char_attribute4        varchar2(240),
    p_char_attribute5        varchar2(240),
    p_char_attribute6        varchar2(240),
    p_char_attribute7        varchar2(240),
    p_char_attribute8        varchar2(240),
    p_char_attribute9        varchar2(240),
    p_char_attribute10       varchar2(240),
    p_num_attribute1         number,
    p_num_attribute2         number,
    p_num_attribute3         number,
    p_num_attribute4         number,
    p_num_attribute5         number,
    p_num_attribute6         number,
    p_num_attribute7         number,
    p_num_attribute8         number,
    p_num_attribute9         number,
    p_num_attribute10        number,
    p_date_attribute1        date,
    p_date_attribute2        date,
    p_date_attribute3        date,
    p_date_attribute4        date,
    p_date_attribute5        date
    );


TYPE  PA_LAdj_Att_Tbl_Type is TABLE of PA_LAdj_Att_rec_Type
	INDEX by BINARY_INTEGER;

-- Line_Adj_Assoc_Rec_Type

Type PA_L_Adj_AssRec_Type  is RECORD
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
, lock_control                  NUMBER,
  p_char_attribute1        varchar2(240),
  p_char_attribute2        varchar2(240),
  p_char_attribute3        varchar2(240),
  p_char_attribute4        varchar2(240),
  p_char_attribute5        varchar2(240),
  p_char_attribute6        varchar2(240),
  p_char_attribute7        varchar2(240),
  p_char_attribute8        varchar2(240),
  p_char_attribute9        varchar2(240),
  p_char_attribute10       varchar2(240),
  p_num_attribute1         number,
  p_num_attribute2         number,
  p_num_attribute3         number,
  p_num_attribute4         number,
  p_num_attribute5         number,
  p_num_attribute6         number,
  p_num_attribute7         number,
  p_num_attribute8         number,
  p_num_attribute9         number,
  p_num_attribute10        number,
  p_date_attribute1        date,
  p_date_attribute2        date,
  p_date_attribute3        date,
  p_date_attribute4        date,
  p_date_attribute5        date);


TYPE  PA_L_Adj_AssTbl_Type is TABLE of PA_L_Adj_Assrec_Type
	INDEX by BINARY_INTEGER;

TYPE QP_LINE_REC_TYPE IS RECORD
(REQUEST_TYPE_CODE       VARCHAR2(30):=NULL,
 PRICING_EVENT           VARCHAR2(30):=NULL,
 HEADER_ID               NUMBER      :=NULL,
 LINE_INDEX              NUMBER      :=NULL,
 LINE_ID                 NUMBER      :=NULL,
 LINE_TYPE_CODE          VARCHAR2(30):=NULL,
 PRICING_EFFECTIVE_DATE  DATE        :=NULL,
 ACTIVE_DATE_FIRST       DATE        :=NULL,
 ACTIVE_DATE_FIRST_TYPE  VARCHAR2(30):=NULL,
 ACTIVE_DATE_SECOND      DATE        :=NULL,
 ACTIVE_DATE_SECOND_TYPE VARCHAR2(30):=NULL,
 LINE_QUANTITY           NUMBER      :=NULL,
 LINE_UOM_CODE           VARCHAR2(30):=NULL,
 UOM_QUANTITY            NUMBER      :=NULL,
 PRICED_QUANTITY         NUMBER      :=NULL,
 PRICED_UOM_CODE         VARCHAR2(30):=NULL,
 CURRENCY_CODE           VARCHAR2(30):=NULL,
 UNIT_PRICE              NUMBER      :=NULL,
 PERCENT_PRICE           NUMBER      :=NULL,
 ADJUSTED_UNIT_PRICE     NUMBER      :=NULL,
 UPDATED_ADJUSTED_UNIT_PRICE     NUMBER      :=NULL,
 PARENT_PRICE            NUMBER      :=NULL,
 PARENT_QUANTITY         NUMBER      :=NULL,
 ROUNDING_FACTOR         NUMBER      :=NULL,
 PARENT_UOM_CODE         VARCHAR2(30):=NULL,
 PRICING_PHASE_ID        NUMBER      :=NULL,
 PRICE_FLAG              VARCHAR2(1) :=NULL,
 PROCESSED_CODE          VARCHAR2(240) :=NULL,
 PRICE_REQUEST_CODE      VARCHAR2(240) :=NULL,
 HOLD_CODE               VARCHAR2(240) := NULL,
 HOLD_TEXT               VARCHAR2(2000) := NULL,
 STATUS_CODE             VARCHAR2(30):=NULL,
 STATUS_TEXT             VARCHAR2(2000):=NULL,
 USAGE_PRICING_TYPE      VARCHAR2(30) := NULL,
 LINE_CATEGORY           VARCHAR2(30) := NULL,
 CONTRACT_START_DATE 	DATE := NULL, /* shulin */
 CONTRACT_END_DATE 	DATE := NULL,  /* shulin */
 LINE_UNIT_PRICE 	NUMBER := NULL,  /* shu_latest */
 EXTENDED_PRICE          NUMBER := NULL, /* block pricing */
 LIST_PRICE_OVERRIDE_FLAG VARCHAR2(1) := NULL /* po integration */
);

TYPE QP_LINE_TBL_TYPE IS TABLE OF QP_LINE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_QUAL_REC_TYPE IS RECORD
(LINE_INDEX		       NUMBER       ,
 QUALIFIER_CONTEXT             VARCHAR2(30) ,
 QUALIFIER_ATTRIBUTE           VARCHAR2(30) ,
 QUALIFIER_ATTR_VALUE_FROM     VARCHAR2(240) ,
 QUALIFIER_ATTR_VALUE_TO       VARCHAR2(240) ,
 COMPARISON_OPERATOR_CODE      VARCHAR2(30) ,
 VALIDATED_FLAG                VARCHAR2(1)  ,
 STATUS_CODE                   VARCHAR2(30):=NULL,
 STATUS_TEXT                   VARCHAR2(240):=NULL
);


TYPE QP_QUAL_TBL_TYPE IS TABLE OF QP_QUAL_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_LINE_ATTR_REC_TYPE IS RECORD
(LINE_INDEX         NUMBER      :=NULL,
 PRICING_CONTEXT    VARCHAR2(30):=NULL,
 PRICING_ATTRIBUTE  VARCHAR2(30):=NULL,
 PRICING_ATTR_VALUE_FROM VARCHAR2(240):=NULL,
 PRICING_ATTR_VALUE_TO   VARCHAR2(240):=NULL,
 VALIDATED_FLAG     VARCHAR2(1):=NULL,
 STATUS_CODE             VARCHAR2(30):=NULL,
 STATUS_TEXT             VARCHAR2(240):=NULL
);

TYPE QP_LINE_ATTR_TBL_TYPE IS TABLE OF QP_LINE_ATTR_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_LINE_DETAIL_REC_TYPE IS RECORD
(LINE_DETAIL_INDEX      NUMBER,
 LINE_DETAIL_ID         NUMBER,
 LINE_DETAIL_TYPE_CODE  VARCHAR2(30),
 LINE_INDEX             NUMBER,
 LIST_HEADER_ID         NUMBER,
 LIST_LINE_ID           NUMBER,
 LIST_LINE_TYPE_CODE    VARCHAR2(30),
 SUBSTITUTION_TYPE_CODE VARCHAR2(30),  --obsoleting
 SUBSTITUTION_FROM      VARCHAR2(240), --obsoleting
 SUBSTITUTION_TO        VARCHAR2(240),
 AUTOMATIC_FLAG         VARCHAR2(1),
 OPERAND_CALCULATION_CODE VARCHAR2(30),  --added for pricing engine internal use only
 OPERAND_VALUE          NUMBER,          --added for pricing engine internal use only
 PRICING_GROUP_SEQUENCE NUMBER,          --added for pricing engine internal use only
 PRICE_BREAK_TYPE_CODE  VARCHAR2(30),    --added for pricing engine internal use only
 CREATED_FROM_LIST_TYPE_CODE   VARCHAR2(30),
 PRICING_PHASE_ID       NUMBER,
 LIST_PRICE             NUMBER,
 LINE_QUANTITY          NUMBER,
 ADJUSTMENT_AMOUNT      NUMBER,
 APPLIED_FLAG           VARCHAR2(1),
 MODIFIER_LEVEL_CODE    VARCHAR2(30),
 STATUS_CODE            VARCHAR2(30):=NULL,
 STATUS_TEXT            VARCHAR2(2000):=NULL,
--new addition might need to add
 SUBSTITUTION_ATTRIBUTE VARCHAR2(240),
 ACCRUAL_FLAG           VARCHAR2(1),
 LIST_LINE_NO           VARCHAR2(240),
 ESTIM_GL_VALUE          NUMBER,
 ACCRUAL_CONVERSION_RATE NUMBER,
--Pass throuh components
 OVERRIDE_FLAG          VARCHAR2(1),
 PRINT_ON_INVOICE_FLAG  VARCHAR2(1),
 INVENTORY_ITEM_ID      NUMBER,
 ORGANIZATION_ID        NUMBER,
 RELATED_ITEM_ID        NUMBER,
 RELATIONSHIP_TYPE_ID   NUMBER,
 --ACCRUAL_QTY                NUMBER,
 --ACCRUAL_UOM_CODE           VARCHAR2(3),
 ESTIM_ACCRUAL_RATE           NUMBER,
 EXPIRATION_DATE              DATE,
 BENEFIT_PRICE_LIST_LINE_ID  NUMBER,
 RECURRING_FLAG               VARCHAR2(1),
 RECURRING_VALUE              NUMBER, -- block pricing
 BENEFIT_LIMIT                NUMBER,
 CHARGE_TYPE_CODE             VARCHAR2(30),
 CHARGE_SUBTYPE_CODE          VARCHAR2(30),
 INCLUDE_ON_RETURNS_FLAG      VARCHAR2(1),
 BENEFIT_QTY                  NUMBER,
 BENEFIT_UOM_CODE             VARCHAR2(3),
 PRORATION_TYPE_CODE          VARCHAR2(30),
 SOURCE_SYSTEM_CODE           VARCHAR2(30),
 REBATE_TRANSACTION_TYPE_CODE VARCHAR2(30),
 SECONDARY_PRICELIST_IND      VARCHAR2(1),
 GROUP_VALUE                  NUMBER, -- This is used for LUMPSUM calculation for LINEGRP kind of modifiers
 COMMENTS                     VARCHAR2(2000),
 UPDATED_FLAG                 VARCHAR2(1),
 PROCESS_CODE                 VARCHAR2(30),
 LIMIT_CODE                   VARCHAR2(30),
 LIMIT_TEXT                   VARCHAR2(240),
 FORMULA_ID                   NUMBER,
 CALCULATION_CODE             VARCHAR2(30) --This indicates if it is back_calcadj
 ,ROUNDING_FACTOR              NUMBER, /* Vivek */
 currency_detail_id        NUMBER, /* Vivek */
 currency_header_id        NUMBER, /* Vivek */
 selling_rounding_factor   NUMBER, /* Vivek */
 order_currency            VARCHAR2(30), /* Vivek */
 pricing_effective_date    DATE, /* Vivek */
 base_currency_code        VARCHAR2(30), /* Vivek */
--added for aso
 change_reason_code		VARCHAR2(30),
 change_reason_text		VARCHAR2(2000),
 break_uom_code            VARCHAR2(3),  /* Proration*/
 break_uom_context         VARCHAR2(30), /* Proration*/
 break_uom_attribute       VARCHAR2(30)  /* Proration*/
 );

TYPE QP_LINE_DETAIL_TBL_TYPE IS TABLE OF QP_LINE_DETAIL_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_LINE_DQUAL_REC_TYPE IS RECORD
(LINE_DETAIL_INDEX          NUMBER,
 QUALIFIER_CONTEXT          VARCHAR2(30),
 QUALIFIER_ATTRIBUTE        VARCHAR2(30),
 QUALIFIER_ATTR_VALUE_FROM  VARCHAR2(240),
 QUALIFIER_ATTR_VALUE_TO    VARCHAR2(240),
 COMPARISON_OPERATOR_CODE   VARCHAR2(30),
 VALIDATED_FLAG             VARCHAR2(1),
 STATUS_CODE             VARCHAR2(30):=NULL,
 STATUS_TEXT             VARCHAR2(240):=NULL
);

TYPE QP_LINE_DQUAL_TBL_TYPE IS TABLE OF QP_LINE_DQUAL_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_LINE_DATTR_REC_TYPE IS RECORD
(LINE_DETAIL_INDEX      NUMBER,
--added for usage pricing as line_index is a not null column in tmp table
 LINE_INDEX		NUMBER,
 PRICING_CONTEXT     VARCHAR2(30),
 PRICING_ATTRIBUTE   VARCHAR2(30),
 PRICING_ATTR_VALUE_FROM  VARCHAR2(240),
 PRICING_ATTR_VALUE_TO  VARCHAR2(240),
 VALIDATED_FLAG      VARCHAR2(1),
 STATUS_CODE             VARCHAR2(30):=NULL,
 STATUS_TEXT             VARCHAR2(240):=NULL
);

TYPE QP_LINE_DATTR_TBL_TYPE IS TABLE OF QP_LINE_DATTR_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_RLTD_LINES_REC_TYPE IS RECORD
(LINE_INDEX              NUMBER,
 LINE_DETAIL_INDEX          NUMBER,
 RELATIONSHIP_TYPE_CODE  VARCHAR2(30),
 RELATED_LINE_INDEX         NUMBER,
 RELATED_LINE_DETAIL_INDEX     NUMBER,
 STATUS_CODE             VARCHAR2(30):=NULL,
 STATUS_TEXT             VARCHAR2(240):=NULL);

TYPE QP_RLTD_LINES_TBL_TYPE IS TABLE OF QP_RLTD_LINES_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE QP_CONTROL_RECORD_TYPE IS RECORD
(PRICING_EVENT   VARCHAR2(30),
 CALCULATE_FLAG  VARCHAR2(30),
 SIMULATION_FLAG VARCHAR2(1),
 ROUNDING_FLAG    VARCHAR2(1),
 GSA_CHECK_FLAG   VARCHAR2(1),
 GSA_DUP_CHECK_FLAG VARCHAR2(1),
 TEMP_TABLE_INSERT_FLAG VARCHAR2(1),
 MANUAL_DISCOUNT_FLAG VARCHAR2(1),
 DEBUG_FLAG           VARCHAR2(1),          --'Y' to turn on debugging
 SOURCE_ORDER_AMOUNT_FLAG VARCHAR2(1),
 PUBLIC_API_CALL_FLAG VARCHAR2(1),
 MANUAL_ADJUSTMENTS_CALL_FLAG VARCHAR2(1),
 GET_FREIGHT_FLAG VARCHAR2(1),
--cleanup changes
   REQUEST_TYPE_CODE VARCHAR2(30),
   VIEW_CODE VARCHAR2(50),
   CHECK_CUST_VIEW_FLAG VARCHAR2(1),
--changed lines call changes
   FULL_PRICING_CALL VARCHAR2(1), -- to indicate if passing all/changed lines
   USE_MULTI_CURRENCY VARCHAR2(1) default 'N' -- vivek, 'Y' to use multi currency
   ,USER_CONVERSION_RATE NUMBER default NULL -- vivek
   ,USER_CONVERSION_TYPE VARCHAR2(30) default NULL -- vivek
   ,FUNCTION_CURRENCY VARCHAR2(30) default NULL -- vivek
);


TYPE source_orgs_rec IS RECORD
         ( org_id number,
           instance_id number,
           ship_method varchar2(30),
           delivery_lead_time number,
           freight_carrier varchar2(30),
           instance_code varchar2(5),
           attribute1 varchar2(100),
           attribute2 varchar2(100),
           attribute3 varchar2(100),
           attribute4 varchar2(100),
           attribute5 varchar2(100),
           attribute6 number,
           attribute7 number,
           attribute8 number,
           attribute9 number,
           attribute10 number,
           attribute11 date,
           attribute12 date,
           attribute13 date,
           attribute14 date,
           attribute15 date
         );

TYPE source_orgs_table IS TABLE OF source_orgs_rec index by binary_integer;
TYPE NUMBER_TYPE        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE panda_rec is RECORD
       (
           p_line_id number,
	   p_inventory_item_id      number,
	   p_qty                    number,
	   p_uom                    varchar2(20),
	   p_request_date           date,
	   p_customer_id            number,
	   p_item_identifier_type   varchar2(40),
	   p_agreement_id           number,
	   p_price_list_id          number,
	   p_ship_to_org_id         number,
	   p_invoice_to_org_id      number,
	   p_ship_from_org_id       number,
	   p_pricing_date           date,
	   p_order_type_id          number,
	   p_ordered_item_id        number,
	   p_line_type_id           number,
           p_demand_class_code      varchar2(30), --9218117
	   p_currency               varchar2(20),
	   p_pricing_context        varchar2(30),
	   p_pricing_attribute1     varchar2(240),
	   p_pricing_attribute2     varchar2(240),
	   p_pricing_attribute3     varchar2(240),
	   p_pricing_attribute4     varchar2(240),
	   p_pricing_attribute5     varchar2(240),
	   p_pricing_attribute6     varchar2(240),
	   p_pricing_attribute7     varchar2(240),
	   p_pricing_attribute8     varchar2(240),
	   p_pricing_attribute9     varchar2(240),
	   p_pricing_attribute10    varchar2(240),
	   p_pricing_attribute11    varchar2(240),
	   p_pricing_attribute12    varchar2(240),
	   p_pricing_attribute13    varchar2(240),
	   p_pricing_attribute14    varchar2(240),
	   p_pricing_attribute15    varchar2(240),
	   p_pricing_attribute16    varchar2(240),
	   p_pricing_attribute17    varchar2(240),
	   p_pricing_attribute18    varchar2(240),
	   p_pricing_attribute19    varchar2(240),
	   p_pricing_attribute20    varchar2(240),
	   p_pricing_attribute21    varchar2(240),
	   p_pricing_attribute22    varchar2(240),
	   p_pricing_attribute23    varchar2(240),
	   p_pricing_attribute24    varchar2(240),
	   p_pricing_attribute25    varchar2(240),
	   p_pricing_attribute26    varchar2(240),
	   p_pricing_attribute27    varchar2(240),
	   p_pricing_attribute28    varchar2(240),
	   p_pricing_attribute29    varchar2(240),
	   p_pricing_attribute30    varchar2(240),
	   p_pricing_attribute31    varchar2(240),
	   p_pricing_attribute32    varchar2(240),
	   p_pricing_attribute33    varchar2(240),
	   p_pricing_attribute34    varchar2(240),
	   p_pricing_attribute35    varchar2(240),
	   p_pricing_attribute36    varchar2(240),
	   p_pricing_attribute37    varchar2(240),
	   p_pricing_attribute38    varchar2(240),
	   p_pricing_attribute39    varchar2(240),
	   p_pricing_attribute40    varchar2(240),
	   p_pricing_attribute41    varchar2(240),
	   p_pricing_attribute42    varchar2(240),
	   p_pricing_attribute43    varchar2(240),
	   p_pricing_attribute44    varchar2(240),
	   p_pricing_attribute45    varchar2(240),
	   p_pricing_attribute46    varchar2(240),
	   p_pricing_attribute47    varchar2(240),
	   p_pricing_attribute48    varchar2(240),
	   p_pricing_attribute49    varchar2(240),
	   p_pricing_attribute50    varchar2(240),
	   p_pricing_attribute51    varchar2(240),
	   p_pricing_attribute52    varchar2(240),
	   p_pricing_attribute53    varchar2(240),
	   p_pricing_attribute54    varchar2(240),
	   p_pricing_attribute55    varchar2(240),
	   p_pricing_attribute56    varchar2(240),
	   p_pricing_attribute57    varchar2(240),
	   p_pricing_attribute58    varchar2(240),
	   p_pricing_attribute59    varchar2(240),
	   p_pricing_attribute60    varchar2(240),
	   p_pricing_attribute61    varchar2(240),
	   p_pricing_attribute62    varchar2(240),
	   p_pricing_attribute63    varchar2(240),
	   p_pricing_attribute64    varchar2(240),
	   p_pricing_attribute65    varchar2(240),
	   p_pricing_attribute66    varchar2(240),
	   p_pricing_attribute67    varchar2(240),
	   p_pricing_attribute68    varchar2(240),
	   p_pricing_attribute69    varchar2(240),
	   p_pricing_attribute70    varchar2(240),
	   p_pricing_attribute71    varchar2(240),
	   p_pricing_attribute72    varchar2(240),
	   p_pricing_attribute73    varchar2(240),
	   p_pricing_attribute74    varchar2(240),
	   p_pricing_attribute75    varchar2(240),
	   p_pricing_attribute76    varchar2(240),
	   p_pricing_attribute77    varchar2(240),
	   p_pricing_attribute78    varchar2(240),
	   p_pricing_attribute79    varchar2(240),
	   p_pricing_attribute80    varchar2(240),
	   p_pricing_attribute81    varchar2(240),
	   p_pricing_attribute82    varchar2(240),
	   p_pricing_attribute83    varchar2(240),
	   p_pricing_attribute84    varchar2(240),
	   p_pricing_attribute85    varchar2(240),
	   p_pricing_attribute86    varchar2(240),
	   p_pricing_attribute87    varchar2(240),
	   p_pricing_attribute88    varchar2(240),
	   p_pricing_attribute89    varchar2(240),
	   p_pricing_attribute90    varchar2(240),
	   p_pricing_attribute91    varchar2(240),
	   p_pricing_attribute92    varchar2(240),
	   p_pricing_attribute93    varchar2(240),
	   p_pricing_attribute94    varchar2(240),
	   p_pricing_attribute95    varchar2(240),
	   p_pricing_attribute96    varchar2(240),
	   p_pricing_attribute97    varchar2(240),
	   p_pricing_attribute98    varchar2(240),
	   p_pricing_attribute99    varchar2(240),
	   p_pricing_attribute100   varchar2(240),
	   p_char_attribute1        varchar2(240),
	   p_char_attribute2        varchar2(240),
	   p_char_attribute3        varchar2(240),
	   p_char_attribute4        varchar2(240),
	   p_char_attribute5        varchar2(240),
	   p_char_attribute6        varchar2(240),
	   p_char_attribute7        varchar2(240),
	   p_char_attribute8        varchar2(240),
	   p_char_attribute9        varchar2(240),
	   p_char_attribute10       varchar2(240),
	   p_num_attribute1         number,
	   p_num_attribute2         number,
	   p_num_attribute3         number,
	   p_num_attribute4         number,
	   p_num_attribute5         number,
	   p_num_attribute6         number,
	   p_num_attribute7         number,
	   p_num_attribute8         number,
	   p_num_attribute9         number,
	   p_num_attribute10        number,
           p_date_attribute1        date,
	   p_date_attribute2        date,
	   p_date_attribute3        date,
	   p_date_attribute4        date,
	   p_date_attribute5        date );

TYPE panda_rec_table IS TABLE OF panda_rec index by binary_integer;

g_panda_rec_table panda_rec_table;

TYPE  Default_rec is record
   (
    org_id  number,
    sold_to_org_id  number,
    inventory_item_id number,
    item_type_code varchar2(30),
    user_id  number,
    created_by number,
    ship_to_org_id  number,
    order_quantity_uom varchar2(3),
    line_type_id number,
    invoice_to_org_id  number,
    demand_Class_code varchar2(30),
    agreement_id  number,
    order_type_id  number,
    price_list_id  number,
    ship_From_org_id  number,
    transactional_Curr_Code varchar2(15),
    request_date  date,
    conversion_type_code varchar2(40), --Bug 7347299
    p_char_attribute1  varchar2(15),
    p_char_attribute2 varchar2(15),
    p_char_attribute3 varchar2(15),
    p_char_attribute4 varchar2(15),
    p_char_attribute5 varchar2(15),
    p_number_attribute1 number,
    p_number_attribute2 number,
    p_number_attribute3 number,
    p_number_attribute4 number,
    p_number_attribute5 number,
    p_date_attribute1 date,
    p_date_attribute2 date,
    p_date_attribute3 date,
    p_date_attribute4 date,
    p_date_attribute5 date);

TYPE Promotions_rec is RECORD(
    p_line_id number,
    p_type varchar2(20),  -- promotion or coupon
    p_level varchar2(20), -- to store Order or Line Level
    p_pricing_attribute1 varchar2(240),
    p_pricing_attribute2 varchar2(240),
    p_pricing_attribute3 varchar2(240)
      );


TYPE Promotions_tbl is TABLE of Promotions_rec index by binary_integer;


TYPE Manual_adj_rec is RECORD
(
 p_line_id number,
 modifier_number      Varchar2(240)
,list_line_type_code  Varchar2(30)
,operator             Varchar2(30)
,operand              Varchar2(30)
,list_line_id         Number
,list_header_id       Number
,pricing_phase_id     Number
,automatic_flag       Varchar2(1)
,modifier_level_code  Varchar2(30)
,override_flag        Varchar2(1)
,adjusted_amount      Number
,line_detail_type_code Varchar2(30)
,price_break_type_code Varchar2(30)
,charge_type_code     Varchar2(30)
,charge_subtype_code  Varchar2(30)
,PRICING_GROUP_SEQUENCE NUMBER  -- added for showing bucket field in Manual Adjustment LOV Bug 3644867
);


Type Manual_modifier_tbl is TABLE of Manual_adj_rec index by binary_integer;

Type Modifier_attributes is RECORD
(p_line_id number,
 p_list_line_id number,
 p_context varchar2(30),
 p_attribute varchar2(100),
 p_attr_value_from number,
 p_attr_value_to number);

Type Modifier_attributes_tbl is TABLE of Modifier_attributes index by binary_integer;

Type Modifier_assoc is RECORD
(p_line_id number,
 line_Detail_index number,
 rltd_line_detail_index number);

   Type Modifier_assoc_tbl is TABLE of Modifier_assoc index by binary_integer;

   Procedure Pass_Modifiers_to_backend(in_manual_adj_tbl in Manual_modifier_tbl,
				       in_modf_rel_tbl  in Modifier_assoc_Tbl,
				       in_modf_attr_tbl in Modifier_attributes_Tbl);
   Procedure Enforce_price_list(in_order_type_id in number,
				out_enforce_price_flag out nocopy varchar2);


Procedure Delete_manual_modifiers;

Procedure Call_MRP_ATP(
               in_global_orgs  in varchar2,
               in_ship_from_org_id in number,
               out_available_qty out nocopy varchar2,
               out_ship_from_org_id out nocopy number,
               out_available_date out nocopy date,
               out_qty_uom out nocopy varchar2,
               x_out_message out nocopy varchar2,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_count OUT NOCOPY NUMBER,
               x_msg_data OUT NOCOPY VARCHAR2,
               x_error_message out nocopy varchar2
                      );

PROCEDURE get_item_name(
               l_inv_item_id in number,
               out_inv_item_name out nocopy varchar2);


PROCEDURE get_item_type(in_item_type_code in  varchar2,
			out_meaning out nocopy varchar2
			);
   Procedure Pass_Upgrade_information(in_upgrade_item_exists varchar2,
				      in_upgrade_item_id in number,
				      in_upgrade_order_qty_uom in varchar2,
				      in_upgrade_ship_from_org_id in number);
PROCEDURE get_upgrade_item_details(l_inv_item_id in number,
				   out_inv_item_name out nocopy varchar2,
				   out_inv_desc out nocopy varchar2,
				   out_inv_item_type out nocopy varchar2);

   PROCEDURE Insert_Manual_Adjustment(in_line_id in number,
				      in_line_index in number);

   PROCEDURE Delete_Applied_Manual_Adj(in_line_id in number,
				       in_list_line_id in number,
				       in_list_header_id in number);


PROCEDURE get_oid_information(l_list_line_no in number,
			out_inv_item_name out nocopy varchar2);
PROCEDURE get_terms_details(
			    in_substitution_attribute in varchar2,
			    in_substitution_to in varchar2,
			    out_benefit_method out nocopy varchar2,
			    out_benefit_value out nocopy varchar2);

   PROCEDURE get_coupon_details(in_list_line_id in number,
			     in_list_header_id in number,
			     out_benefit out nocopy varchar2,
			     out_benefit_method out nocopy varchar2,
			     out_benefit_value out nocopy varchar2,
			     out_benefit_item out nocopy varchar2);

PROCEDURE defaulting(
                     in_source in varchar2,
                     in_out_default_rec  in out NOCOPY /* file.sql.39 change */ default_rec
                     ) ;
PROCEDURE get_order_type(in_order_type_id in number,
			 out_name out nocopy varchar2

                           );
PROCEDURE get_sold_to_org(in_org_id in number,
			 out_name out nocopy varchar2,
                          out_cust_id out nocopy number
                           );
--bug 5621717
PROCEDURE get_sold_to_org(in_org_id in number,
			 out_name out nocopy varchar2,
                          out_cust_id out nocopy varchar2
                           );

   PROCEDURE get_currency_name(in_transactional_curr_code in varchar2,
			 out_name out nocopy varchar2

                           );

PROCEDURE get_demand_class(in_demand_class_code in varchar2,
			 out_name out nocopy varchar2

                           );
PROCEDURE get_ship_to_org(in_org_id in number,
			  out_name out nocopy varchar2

                           );
PROCEDURE get_invoice_to_org(in_bill_to_org_id in number,
			 out_name out nocopy varchar2 );

  PROCEDURE get_agreement_name(in_agreement_id in number,
			 out_name out nocopy varchar2

                           );


PROCEDURE  defaulting(
            in_source in varchar2
            ,in_org_id in varchar2
            ,in_item_id in number
            ,in_customer_id in number
            ,in_ship_to_org_id in number
            ,in_bill_to_org_id in number
            ,in_agreement_id in number
            ,in_order_type_id in number
            ,out_wsh_id out nocopy number
            ,out_uom out nocopy varchar2
            ,out_item_type_code out nocopy varchar2
            ,out_price_list_id out nocopy number
            ,out_conversion_type out nocopy varchar2
                     );


Procedure Query_Qty_Tree(
                         p_org_id            IN NUMBER,
                         p_item_id           IN NUMBER,
                         p_sch_date          IN DATE DEFAULT NULL,
x_on_hand_qty OUT NOCOPY NUMBER,

x_avail_to_reserve OUT NOCOPY NUMBER);



PROCEDURE get_ship_from_org(in_org_id in number,
out_code out nocopy varchar2,

out_name out nocopy varchar2

                           );



PROCEDURE Reset_All_Tbls;
procedure Populate_Temp_Table;

PROCEDURE populate_results(
x_line_tbl  out NOCOPY /* file.sql.39 change */ OE_OE_PRICING_AVAILABILITY.QP_LINE_TBL_TYPE,
x_line_qual_tbl                out NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_QUAL_TBL_TYPE,
x_line_attr_tbl          out NOCOPY /* file.sql.39 change */   OE_OE_PRICING_AVAILABILITY.QP_LINE_ATTR_TBL_TYPE,
x_LINE_DETAIL_tbl        out NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_DETAIL_TBL_TYPE,
x_LINE_DETAIL_qual_tbl    out NOCOPY /* file.sql.39 change */ OE_OE_PRICING_AVAILABILITY.QP_LINE_DQUAL_TBL_TYPE,
x_LINE_DETAIL_attr_tbl   out NOCOPY /* file.sql.39 change */  OE_OE_PRICING_AVAILABILITY.QP_LINE_DATTR_TBL_TYPE,
x_related_lines_tbl       out NOCOPY /* file.sql.39 change */ OE_OE_PRICING_AVAILABILITY.QP_RLTD_LINES_TBL_TYPE
);

PROCEDURE price_item(
out_req_line_tbl in out NOCOPY /* file.sql.39 change */ OE_OE_PRICING_AVAILABILITY.QP_LINE_TBL_TYPE,
out_Req_line_attr_tbl         in out nocopy  OE_OE_PRICING_AVAILABILITY.QP_LINE_ATTR_TBL_TYPE,
out_Req_LINE_DETAIL_attr_tbl  in out nocopy  OE_OE_PRICING_AVAILABILITY.QP_LINE_DATTR_TBL_TYPE,
out_Req_LINE_DETAIL_tbl        in out nocopy OE_OE_PRICING_AVAILABILITY.QP_LINE_DETAIL_TBL_TYPE,
out_Req_related_lines_tbl      in out nocopy OE_OE_PRICING_AVAILABILITY.QP_RLTD_LINES_TBL_TYPE,
out_Req_qual_tbl               in out nocopy OE_OE_PRICING_AVAILABILITY.QP_QUAL_TBL_TYPE,
out_Req_LINE_DETAIL_qual_tbl   in out nocopy OE_OE_PRICING_AVAILABILITY.QP_LINE_DQUAL_TBL_TYPE,
out_child_detail_type out nocopy varchar2
                    );

PROCEDURE pass_values_to_backend(
				in_panda_rec_table in panda_rec_table
				 );

PROCEDURE process_pricing_errors(
                in_line_type_code in varchar2,
                in_status_code    in varchar2,
                in_status_text    in varchar2,
                in_ordered_item    in varchar2,
                in_uom    in varchar2,
                in_unit_price    in number,
                in_adjusted_unit_price    in number,
                in_process_code    in varchar2 ,
                in_price_flag    in varchar2,
                in_price_list_id in number,
                l_return_status out nocopy varchar2,
                l_msg_count out nocopy number,
                l_msg_data out nocopy varchar2
                );

Function Get_Rounding_factor(p_list_header_id number) return number;


Function Get_qp_lookup_meaning( in_lookup_code in varchar2,
                                in_lookup_type in varchar2) return varchar2;

PROCEDURE Get_modifier_name(
       in_list_header_id in number
      ,out_name out nocopy varchar2
      ,out_description out nocopy varchar2
      ,out_end_date out nocopy date
      ,out_start_date out nocopy date
      ,out_currency out nocopy varchar2
      ,out_ask_for_flag out nocopy varchar2
                           );

FUNCTION get_pricing_attribute(
                       in_CONTEXT_NAME in varchar2,
                       in_ATTRIBUTE_NAME in varchar2
                               ) return varchar2;


PROCEDURE get_Price_List_info(
                          p_price_list_id IN  NUMBER,
                          out_name out nocopy varchar2,
                          out_end_date out nocopy date,
                          out_start_date out nocopy date,
                          out_automatic_flag out nocopy varchar2,
                          out_rounding_factor out nocopy varchar2,
                          out_terms_id out nocopy number,
                          out_gsa_indicator out nocopy varchar2,
                          out_currency out nocopy varchar2,
                          out_freight_terms_code out nocopy varchar2);


PROCEDURE  get_item_information(
            in_inventory_item_id in number
           ,in_org_id in number
           ,out_item_status out nocopy varchar2
           ,out_wsh out nocopy varchar2
           ,out_wsh_name out nocopy varchar2
           ,out_category out nocopy varchar2
           ,out_lead_time out nocopy number
           ,out_cost out nocopy number
           ,out_primary_uom out nocopy varchar2
           ,out_user_item_type out nocopy varchar2
           ,out_make_or_buy out nocopy varchar2
           ,out_weight_uom out nocopy varchar2
           ,out_unit_weight out nocopy number
           ,out_volume_uom out nocopy varchar2
           ,out_unit_volume out nocopy number
           ,out_min_order_quantity out nocopy number
           ,out_max_order_quantity out nocopy number
           ,out_fixed_order_quantity out nocopy number
           ,out_customer_order_flag out nocopy varchar2
           ,out_internal_order_flag out nocopy varchar2
           ,out_stockable out nocopy varchar2
           ,out_reservable out nocopy varchar2
           ,out_returnable out nocopy varchar2
           ,out_shippable out nocopy varchar2
           ,out_orderable_on_web out nocopy varchar2
           ,out_taxable out nocopy varchar2
           ,out_serviceable out nocopy varchar2
           ,out_atp_flag out nocopy varchar2
           ,out_bom_item_type out nocopy varchar2
           ,out_replenish_to_order_flag out nocopy varchar2
           ,out_build_in_wip_flag out nocopy varchar2
           ,out_default_so_source_type out nocopy varchar2
          );

PROCEDURE print_time(in_place in varchar2);

PROCEDURE print_time2;


PROCEDURE Get_list_line_details(
               in_list_line_id in number
              ,out_end_date out nocopy date
              ,out_start_date out nocopy date
              ,out_list_line_type_Code out nocopy varchar2
              ,out_modifier_level_code out nocopy varchar2

                           );

PROCEDURE get_global_availability(
                       in_customer_id in number
                      ,in_customer_site_id in number
                      ,in_inventory_item_id in number
                      ,in_org_id            in number
                      ,x_return_status out nocopy varchar2
                      ,x_msg_data out nocopy varchar2
                      ,x_msg_count out nocopy number
                      ,l_source_orgs_table out nocopy source_orgs_table
                                 );


PROCEDURE different_uom(
                        in_org_id in number
                       ,in_ordered_uom in varchar2
                       ,in_pricing_uom in varchar2
                       ,out_conversion_rate out nocopy number

                       );

FUNCTION get_conversion_rate(in_uom_code in varchar2,
                              in_base_uom in varchar2
                             ) RETURN number;


PROCEDURE Call_mrp_and_inventory(
                        in_org_id in number
                        ,out_on_hand_qty out nocopy number
                        ,out_reservable_qty out nocopy number
                        ,out_available_qty out nocopy varchar2
                        ,out_available_date out nocopy date
                        ,out_error_message out nocopy varchar2
                        ,out_qty_uom out nocopy varchar2
                                );

PROCEDURE set_mrp_debug(out_mrp_file out nocopy varchar2);


PROCEDURE Create_Order(
             in_order in varchar2,
             in_header_rec oe_oe_pricing_availability.PA_Header_Tbl_Type,
             in_line_tbl Oe_Oe_Pricing_Availability.PA_Line_Tbl_Type,
             in_Header_Adj_tbl Oe_Oe_Pricing_Availability.PA_H_Adj_Tbl_Type,
             in_Line_Adj_tbl   Oe_Oe_Pricing_Availability.PA_LAdj_Tbl_Type,
             in_Header_price_Att_tbl Oe_Oe_Pricing_Availability.PA_H_PAtt_Tbl_Type,
             in_Header_Adj_Att_tbl Oe_Oe_Pricing_Availability.PA_H_Adj_Att_Tbl_Type,
             in_Header_Adj_Assoc_tbl  Oe_Oe_Pricing_Availability.PA_H_Adj_AsTbl_Type,
             in_Line_price_Att_tbl  Oe_Oe_Pricing_Availability.PA_Line_PAtt_Tbl_Type,
             in_Line_Adj_Att_tbl  Oe_Oe_Pricing_Availability.PA_LAdj_Att_Tbl_Type,
             in_Line_Adj_Assoc_tbl Oe_Oe_Pricing_Availability.PA_L_Adj_AssTbl_Type,
             out_order_number out NOCOPY varchar2,
             out_header_id out NOCOPY number,
             out_order_total out NOCOPY number,
             out_order_amount out nocopy number,
             out_order_charges out nocopy number,
             out_order_discount out nocopy number,
             out_order_tax     out nocopy number,
             out_item        out nocopy varchar2,
             out_currency out nocopy varchar2,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2
             );


PROCEDURE pass_promotions_to_backend (in_promotions_tbl in promotions_tbl,
                                      in_line_id in number);

PROCEDURE get_atp_flag(
	  in_inventory_item_id in number
	  ,in_org_id in number
	  ,out_atp_flag out NOCOPY /* file.sql.39 change */ varchar2
          ,out_default_source_type out NOCOPY /* file.sql.39 change */ varchar2
			  );

FUNCTION  Is_AdPricing_inst return varchar2;

--added for bug 3559935
PROCEDURE RESET_DEBUG_LEVEL;

PROCEDURE SET_DEBUG_LEVEL (p_debug_level IN NUMBER);

PROCEDURE Get_Form_Startup_Values(Item_Id_Flex_Code         IN VARCHAR2,
Item_Id_Flex_Num OUT NOCOPY NUMBER);

Procedure get_user_item_Pricing_Contexts(
			p_request_type_code IN   VARCHAR2,
			x_user_attribs_tbl  OUT NOCOPY USER_ATTRIBUTE_TBL_TYPE);

--end 3559935

--added for bug 3245976

FUNCTION GET_MRP_ERR_MSG RETURN VARCHAR;
FUNCTION GET_MRP_ERR_MSG_FLAG RETURN CHAR;
--end bug 3245976

/* start bug 3440778 , Created to convert the reference to other products serverside code  inside OEXPRAVA pld into a local call. to OE_OE_PRICING_AVAILABILITY package*/

FUNCTION Get_Cost (p_line_rec       IN  OE_ORDER_PUB.LINE_REC_TYPE   DEFAULT OE_Order_Pub.G_MISS_LINE_REC
                  ,p_request_rec    IN Oe_Order_Pub.Request_Rec_Type DEFAULT Oe_Order_Pub.G_MISS_REQUEST_REC
                  ,p_order_currency IN VARCHAR2 Default NULL
                  ,p_sob_currency   IN VARCHAR2 Default NULL
                  ,p_inventory_item_id    IN NUMBER Default NULL
                  ,p_ship_from_org_id     IN NUMBER Default NULL
                  ,p_conversion_Type_code IN VARCHAR2 Default NULL
                  ,p_conversion_rate      IN NUMBER   Default NULL
                  ,p_item_type_code       IN VARCHAR2 Default 'STANDARD'
                  ,p_header_flag          IN Boolean  Default FALSE) RETURN NUMBER;

PROCEDURE Get_Agreement
(
    p_sold_to_org_id            IN NUMBER DEFAULT NULL
   ,p_transaction_type_id       IN NUMBER DEFAULT NULL
   ,p_pricing_effective_date    IN DATE
   ,p_agreement_tbl            OUT NOCOPY agreement_tbl
);

-- round_price.p_operand_type could be 'A' for adjustment amount or 'S' for item price
PROCEDURE round_price
(
     p_operand                  IN NUMBER
    ,p_rounding_factor          IN NUMBER
    ,p_use_multi_currency       IN VARCHAR2
    ,p_price_list_id            IN NUMBER
    ,p_currency_code            IN VARCHAR2
    ,p_pricing_effective_date   IN DATE
    ,x_rounded_operand         IN OUT NOCOPY NUMBER
    ,x_status_code             IN OUT NOCOPY VARCHAR2
    ,p_operand_type             IN VARCHAR2 default 'S'
);

-- end   bug 3440778
FUNCTION  IS_PRICING_AVAILIBILITY RETURN VARCHAR2  ; --bug#7380336
END oe_oe_pricing_availability;

/

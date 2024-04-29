--------------------------------------------------------
--  DDL for Package OE_BLANKET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPBSOS.pls 120.1.12010000.3 2009/01/05 22:40:17 smusanna ship $ */
/*#
* This public API allows users to create Blanket Agreements Order Management system.
* @rep:scope public
* @rep:product ONT
* @rep:lifecycle active
* @rep:displayname Sales Agreement API
* @rep:category BUSINESS_ENTITY ONT_SALES_AGREEMENT
*/
G_ENTITY_BLANKET_ALL                   CONSTANT VARCHAR2(30) := 'BLANKET_ALL';
G_ENTITY_BLANKET_LINE          CONSTANT VARCHAR2(30) := 'BLANKET_LINE';
G_ENTITY_BLANKET_HEADER        CONSTANT VARCHAR2(30) := 'BLANKET_HEADER';

--  Blanket Header record type
TYPE header_rec_Type IS RECORD
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
,   attribute20                   VARCHAR2(240)
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
,   cust_po_number                VARCHAR2(50)
,   deliver_to_org_id             NUMBER
,   freight_terms_code            VARCHAR2(30)
,   header_id                     NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   order_category_code           VARCHAR2(30)
,   order_number                  NUMBER
,   order_type_id                 NUMBER
,   org_id                        NUMBER
,   price_list_id                 NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_id                    NUMBER
,   version_number		  number
,   salesrep_id			  NUMBER
,   shipping_method_code          VARCHAR2(30)
,   ship_from_org_id              NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_contact_id            NUMBER
,   sold_to_org_id                NUMBER
,   transactional_curr_code       VARCHAR2(15)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   payment_term_id		  number
,   shipping_instructions         varchar2(2000)
,   packing_instructions         varchar2(2000)
,   Price_list_Name		 varchar2(240)
,   Price_list_description       varchar2(2000)
,   price_list_currency_code     varchar2(30)
,   conversion_type_code         varchar2(30)
,   blanket_max_amount		  NUMBER
,   blanket_min_amount 	          NUMBER
,   released_amount              Number
,   fulfilled_amount             Number
,   returned_amount              Number
,   enforce_price_list_flag         varchar2(1)
,   enforce_ship_to_flag            varchar2(1)
,   enforce_invoice_to_flag         varchar2(1)
,   enforce_freight_term_flag       varchar2(1)
,   enforce_shipping_method_flag    varchar2(1)
,   enforce_payment_term_flag       varchar2(1)
,   enforce_accounting_rule_flag    varchar2(1)
,   enforce_invoicing_rule_flag     varchar2(1)
,   lock_control		  number
,   on_hold_flag          VARCHAR2(1)
,   override_amount_flag	  varchar2(1)
,   start_date_active 		  DATE
,   end_date_active		  DATE
,   revision_change_comments      VARCHAR2(2000)
,   revision_change_date          DATE
,   revision_change_reason_code   VARCHAR2(30)
,   source_document_type_id       NUMBER
,   source_document_id            NUMBER
-- hashraf start of pack J
,   SALES_DOCUMENT_NAME 	  VARCHAR2(240)
,   TRANSACTION_PHASE_CODE	  VARCHAR2(30)
,   USER_STATUS_CODE 		  VARCHAR2(30)
,   flow_status_code		  VARCHAR2(30)
,   SUPPLIER_SIGNATURE 		  VARCHAR2(240)
,   SUPPLIER_SIGNATURE_DATE 	  DATE
,   CUSTOMER_SIGNATURE 		  VARCHAR2(240)
,   CUSTOMER_SIGNATURE_DATE 	  DATE
,   SOLD_TO_SITE_USE_ID 	  NUMBER
,   DRAFT_SUBMITTED_FLAG 	  VARCHAR2(1)
,   SOURCE_DOCUMENT_VERSION_NUMBER NUMBER
,   contract_template_id          NUMBER   --abkumar
-- 11i10 Pricing Changes
,   new_price_list_id             NUMBER
,   new_price_list_name           VARCHAR2(240)
,   new_modifier_list_id          NUMBER
,   new_modifier_list_name        VARCHAR2(240)
,   default_discount_percent     NUMBER
,   default_discount_amount      NUMBER
,   open_flag                     VARCHAR2(1)
);
-- hashraf end of pack J
TYPE Blanket_Hdr_Tbl_Type IS TABLE OF header_rec_type
    INDEX BY BINARY_INTEGER;


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
,   salesrep               VARCHAR2(240)
,   ship_from_address1            VARCHAR2(240)
,   ship_from_address2            VARCHAR2(240)
,   ship_from_address3            VARCHAR2(240)
,   ship_from_address4            VARCHAR2(240)
,   ship_from_location            VARCHAR2(240)
,   SHIP_FROM_CITY               Varchar(60)
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
,   freight_carrier               VARCHAR2(80)
,   shipping_method               VARCHAR2(80)
,   customer_number               VARCHAR2(30)
,   ship_to_customer_name         VARCHAR2(360)
,   invoice_to_customer_name      VARCHAR2(360)
,   ship_to_customer_number       VARCHAR2(50)
,   invoice_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_name      VARCHAR2(360)
,  blanket_agreement_name            VARCHAR2(360)
,  contract_template                 VARCHAR2(60)
);

TYPE Blanket_Hdr_Val_Tbl_Type IS TABLE OF header_val_rec_type
    INDEX BY BINARY_INTEGER;

--  Blanket Line record type

TYPE Line_Rec_Type IS RECORD
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
,   attribute20                   VARCHAR2(240)
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
,   cust_po_number                VARCHAR2(50)
,   deliver_to_org_id             NUMBER
,   freight_terms_code            VARCHAR2(30)
,   global_attribute_category     VARCHAR2(30)
,   header_id                     NUMBER
,   inventory_item_id             NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   ordered_item                  VARCHAR2(2000)
,   ordered_item_id               NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_type_id                  NUMBER
,   line_id                       NUMBER
,   line_number                   NUMBER
,   order_number                VARCHAR2(240)
,   order_quantity_uom          VARCHAR2(30)
,   org_id                        NUMBER
,   payment_term_id               NUMBER
,   preferred_grade               VARCHAR2(150)   -- INVCONV 4091955
,   price_list_id                 NUMBER
,   request_id                    NUMBER
,   program_id                    NUMBER
,   program_application_id        NUMBER
,   program_update_date           DATE
,   shipping_method_code          VARCHAR2(30)
,   ship_from_org_id              NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_org_id                NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   item_identifier_type          VARCHAR2(30)
,   item_type_code 		  varchar2(30)
,   shipping_instructions	    VARCHAR2(2000)
,   packing_instructions          VARCHAR2(2000)
,   salesrep_id                     number
,   unit_list_price               number
,   pricing_uom			  varchar2(150)
,   lock_control		  number
,   enforce_price_list_flag         varchar2(1)
,   enforce_ship_to_flag            varchar2(1)
,   enforce_invoice_to_flag         varchar2(1)
,   enforce_freight_term_flag       varchar2(1)
,   enforce_shipping_method_flag    varchar2(1)
,   enforce_payment_term_flag       varchar2(1)
,   enforce_accounting_rule_flag    varchar2(1)
,   enforce_invoicing_rule_flag     varchar2(1)
,   override_blanket_controls_flag varchar2(1)
,   override_release_controls_flag varchar2(1)
,   qp_list_line_id               NUMBER
,   fulfilled_quantity            number
,   blanket_min_quantity          NUMBER
,   blanket_max_quantity          NUMBER
,   blanket_min_amount            number
,   blanket_max_amount	          number
,   min_release_quantity          NUMBER
,   max_release_quantity          NUMBER
,   min_release_amount		  number
,   max_release_amount		  number
,   released_amount               NUMBER
,   fulfilled_amount              NUMBER
,   released_quantity             number
,   returned_amount               number
,   returned_quantity		  number
,   start_date_active             date
,   end_date_active               date
,   source_document_type_id       NUMBER
,   source_document_id            NUMBER
,   source_document_line_id       NUMBER
-- hashraf start of pack J
,   transaction_phase_code	  VARCHAR2(30)
,   source_document_version_number	NUMBER
-- 11i10 Pricing Changes
,   modifier_list_line_id         NUMBER
,   discount_percent              NUMBER
,   discount_amount               NUMBER
-- 11i10 Versioning/Reasons Changes
,   revision_change_comments      VARCHAR2(2000)
,   revision_change_date          DATE
,   revision_change_reason_code   VARCHAR2(30)
);
-- hashraf end of Pack J
TYPE Control_Rec_Type IS RECORD
(   UI_CALL                       BOOLEAN := TRUE
,   validate_attributes            BOOLEAN := FALSE
,   validate_entity               BOOLEAN := FALSE
,   default_From_Header   BOOLEAN := TRUE
,   write_to_db                   BOOLEAN := TRUE
,   ui_commit                     BOOLEAN := FALSE
,   check_security                BOOLEAN := FALSE
);



TYPE line_tbl_Type IS TABLE OF Line_Rec_Type
    INDEX BY BINARY_INTEGER;


TYPE Line_Val_Rec_Type IS RECORD
(   accounting_rule               VARCHAR2(240)
,   agreement                     VARCHAR2(240)
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
,   line_type                     VARCHAR2(240)
,   payment_term                  VARCHAR2(240)
,   price_list                    VARCHAR2(240)
,   salesrep               VARCHAR2(240)
,   ship_from_address1            VARCHAR2(240)
,   ship_from_address2            VARCHAR2(240)
,   ship_from_address3            VARCHAR2(240)
,   ship_from_address4            VARCHAR2(240)
,   ship_from_location            VARCHAR2(240)
,   SHIP_FROM_CITY               Varchar(60)
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
,   sold_to_org                   VARCHAR2(360)
,   sold_from_org                 VARCHAR2(240)
,   ship_to_customer_name         VARCHAR2(360)
,   invoice_to_customer_name      VARCHAR2(360)
,   ship_to_customer_number       VARCHAR2(50)
,   invoice_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_number    VARCHAR2(50)
,   deliver_to_customer_name      VARCHAR2(360)
,   blanket_agreement_name           VARCHAR2(360)
);

TYPE line_Val_tbl_Type IS TABLE OF Line_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Request_Rec_Type IS RECORD
  (
   -- Object for which the delayed request has been logged
   -- ie BLANKET LINE, BLANKET HEADER
   Entity_code         Varchar2(30):= NULL,

   -- Primary key for the object as in entity_code
   Entity_id          Number := NULL,
   request_type       Varchar2(30) := NULL,
   -- Keys to identify a unique request.
   request_unique_key1  VARCHAR2(30) := NULL,
   request_unique_key2  VARCHAR2(30) := NULL,
   request_unique_key3  VARCHAR2(30) := NULL,
   param1             Varchar2(2000) := NULL,
   param2             Varchar2(240) := NULL,
   param3             Varchar2(240) := NULL,
   paramtext1          Varchar2(2000) := NULL,
   paramtext2          Varchar2(2000) := NULL,
   date_param1            DATE := NULL,
   date_param2            DATE := NULL,
   date_param3            DATE := NULL
);

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
INDEX BY BINARY_INTEGER;


G_MISS_header_rec header_rec_type;
G_MISS_header_Val_rec header_val_rec_type;
G_MISS_BLANKET_LINE_REC line_rec_type;
G_MISS_BLANKET_LINE_VAL_REC line_val_rec_type;
G_MISS_line_tbl line_tbl_type;
G_MISS_line_Val_tbl line_Val_tbl_Type;
G_MISS_CONTROL_REC control_rec_type;

-- Public Blanket order API
/*#
* Use this procedure to create Blanket Agreement in the Order Management system.
*       @param          p_org_id   Input OU Organization Id
*       @param          p_operating_unit   Input Operating Unit Name
*       @param          p_api_version_number    API version used to check call compatibility
*       @param          x_return_status Return status of API call
*       @param          x_msg_count    Number of stored processing messages
*       @param          x_msg_data      Processing message data
*       @param          p_header_rec    Input record structure containing current header-level information for an Agreement
*       @param          p_line_tbl          Input table containing current line-level information for an Agreement
*       @param          p_control_rec    Input record structure containing current control information for the API call
*       @param          x_header_rec    Output record structure containing current header-level information for an Agreement
*       @param          x_line_tbl      Output table containing current line-level information for an Agreement
*       @rep:scope      public
*       @rep:lifecycle  active
*       @rep:category   BUSINESS_ENTITY  ONT_SALES_AGREEMENT
*       @rep:displayname                 Sales Agreement API
*/

PROCEDURE Process_Blanket
(   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER := 1.0
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_rec            IN  header_rec_type :=
					G_MISS_header_rec
,   p_header_val_rec        IN  Header_Val_Rec_Type :=
                                        G_MISS_header_Val_rec
,   p_line_tbl              IN  line_tbl_Type :=
                                        G_MISS_line_tbl
,   p_line_val_tbl          IN  line_Val_tbl_Type :=
                                         G_MISS_line_Val_tbl
,   p_control_rec                   IN  Control_rec_type :=
				G_MISS_CONTROL_REC
,   x_header_rec           OUT NOCOPY header_rec_type
,   x_line_tbl	           OUT NOCOPY line_tbl_Type
);



END OE_Blanket_PUB;

/

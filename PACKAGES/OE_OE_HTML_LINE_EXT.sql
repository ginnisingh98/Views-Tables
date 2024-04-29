--------------------------------------------------------
--  DDL for Package OE_OE_HTML_LINE_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_HTML_LINE_EXT" AUTHID CURRENT_USER AS
/* $Header: ONTHLIES.pls 120.0 2005/05/31 23:51:57 appldev noship $ */

TYPE Line_Dff_Rec_Type IS RECORD
(
    attribute1                    VARCHAR2(240)
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
,   line_id                       NUMBER
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
);

TYPE Line_Dff_Tbl_Type IS TABLE OF Line_Dff_Rec_Type
    INDEX BY BINARY_INTEGER;

PROCEDURE Save_Lines
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_cascade_flag                  OUT NOCOPY BOOLEAN
, p_line_tbl                      IN  OE_ORDER_PUB.Line_Tbl_Type
, p_old_line_tbl                  IN  OE_ORDER_PUB.Line_Tbl_Type
);


PROCEDURE Prepare_Lines_Dff_For_Save
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_line_dff_tbl                  IN  Oe_Oe_Html_Line_Ext.Line_Dff_Tbl_Type
);



TYPE Line_Ext_Val_Rec_Type IS RECORD
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
,   extended_price                   NUMBER
,   unit_selling_price               NUMBER
,   unit_list_price                  NUMBER
,   line_number                      VARCHAR2(100)
,   item_description                 VARCHAR2(1000)
);

TYPE Line_Ext_Val_Tbl_Type IS TABLE OF Line_Ext_Val_Rec_Type
    INDEX BY BINARY_INTEGER;



Procedure Populate_Transient_Attributes
(
  P_line_rec               IN Oe_Order_Pub.line_rec_type
, x_line_val_rec           OUT NOCOPY /* file.sql.39 change */  line_Ext_Val_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);


END Oe_Oe_Html_Line_Ext;

 

/

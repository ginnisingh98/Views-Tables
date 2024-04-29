--------------------------------------------------------
--  DDL for Package OE_OE_FORM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_HEADER" AUTHID CURRENT_USER AS
/* $Header: OEXFHDRS.pls 120.6.12010000.2 2010/01/29 12:37:27 vmachett ship $ */

--  Procedure : Default_Attributes
--

G_ENABLE_VISIBILITY_MSG   VARCHAR2(1)  := NVL(FND_PROFILE.Value('ONT_ENABLE_MSG'),'N');

G_HZ_H_Installed Varchar2(1);

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE Varchar2_Tbl_Type IS TABLE OF Varchar2(2000)
    INDEX BY BINARY_INTEGER;

G_NULL_NUMBER_TBL        Number_Tbl_Type;
G_NULL_VARCHAR2_TBL      Varchar2_Tbl_Type;

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   x_header_rec                    IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   p_transaction_phase_code        IN VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   p_header_dff_rec                IN  Oe_Oe_Form_Header.Header_Dff_Rec_Type
,   p_date_format_mask            IN  VARCHAR2 DEFAULT 'DD-MON-RRRR HH24:MI:SS'
,   x_header_rec                 IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
);

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
,   p_header_id                     IN  NUMBER
,   p_change_reason_code            IN  VARCHAR2
,   p_change_comments               IN  VARCHAR2
, x_creation_date OUT NOCOPY DATE
, x_created_by OUT NOCOPY NUMBER
, x_last_update_date OUT NOCOPY DATE
, x_last_updated_by OUT NOCOPY NUMBER
, x_last_update_login OUT NOCOPY NUMBER
, x_order_number OUT NOCOPY NUMBER
, x_lock_control OUT NOCOPY NUMBER
, x_quote_number OUT NOCOPY NUMBER
, x_shipping_method_code OUT NOCOPY VARCHAR2 --4159701
, x_freight_carrier_code OUT NOCOPY VARCHAR2 --4159701
, x_shipping_method  OUT NOCOPY VARCHAR2--4159701
, x_freight_carrier OUT NOCOPY VARCHAR2 --4159701
, x_freight_terms_code OUT NOCOPY VARCHAR2 --4348011
, x_freight_terms OUT NOCOPY VARCHAR2
, x_payment_term_id OUT NOCOPY NUMBER
, x_payment_term OUT NOCOPY VARCHAR2
);

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
);

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);

--  Procedure       Process_Object
--

PROCEDURE Process_Object
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_lock_control                  IN  NUMBER
);



Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
);


Procedure Delete_All_Requests
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);


Procedure Sales_Person
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, p_multiple_sales_credits OUT NOCOPY Varchar2
,   p_header_id                     IN  NUMBER
,   p_salesrep_id                   IN  NUMBER
);

PROCEDURE Get_Form_Startup_Values
(   Item_Id_Flex_Code         IN VARCHAR2,
Item_Id_Flex_Num OUT NOCOPY NUMBER
);

TYPE Header_Rec_Type IS RECORD
(
salesrep_id            NUMBER,
fob_point_code         VARCHAR2(30),
tax_exempt_flag        VARCHAR2(30),
tax_exempt_reason_code VARCHAR2(30),
return_reason_code     VARCHAR2(30),
tax_point_code         VARCHAR2(30),
freight_terms_code     VARCHAR2(30),
shipment_priority_code VARCHAR2(30),
payment_type_code      VARCHAR2(30),
credit_card_code       VARCHAR2(30),
flow_status_code	VARCHAR2(30),
freight_carrier_code	VARCHAR2(30),
shipping_method_code	VARCHAR2(30),
order_date_type_code	VARCHAR2(30),
ship_from_org_id        NUMBER,
demand_class_code       VARCHAR2(30),
sales_channel_code      VARCHAR2(30),
ship_to_org_id          NUMBER,
invoice_to_org_id       NUMBER,
deliver_to_org_id       NUMBER,
deliver_to_contact_id   NUMBER,
order_source_id         NUMBER,
source_document_type_id NUMBER,
agreement_id            NUMBER,
conversion_type_code    VARCHAR2(30),
header_id               NUMBER,
sold_to_org_id          NUMBER,
sold_to_phone_id          NUMBER,
--kmuruges
transaction_phase_code VARCHAR2(30),
user_status_code       VARCHAR2(30),
sold_to_site_use_id    NUMBER,
--kmuruges end
blanket_number         NUMBER,
contract_template_id   NUMBER,
contract_source_doc_type_code VARCHAR2(30),
contract_source_document_id NUMBER,
SUPPLIER_SIGNATURE           VARCHAR2(240),
SUPPLIER_SIGNATURE_DATE      DATE,
CUSTOMER_SIGNATURE           VARCHAR2(240),
CUSTOMER_SIGNATURE_DATE      DATE,
 end_customer_site_use_id  NUMBER,
 end_customer_contact_id  NUMBER,
 end_customer_id  NUMBER,
ib_owner                      VARCHAR2(60),
ib_installed_at_location      VARCHAR2(60),
ib_current_location           VARCHAR2(60),
contract_template                 VARCHAR2(60),
contract_source                 VARCHAR2(60),
authoring_party                 VARCHAR2(60),
org_id                    NUMBER
);

TYPE Header_Val_Rec_Type IS RECORD
(
salesrep              VARCHAR2(240),
fob             VARCHAR2(240),
tax_exempt            VARCHAR2(240),
tax_exempt_reason     VARCHAR2(240),
return_reason         VARCHAR2(240),
tax_point             VARCHAR2(240),
freight_terms    VARCHAR2(240),
shipment_priority  VARCHAR2(240),
payment_type         VARCHAR2(240),
credit_card         VARCHAR2(240),
status		VARCHAR2(240),
freight_carrier     VARCHAR2(80),
shipping_method     VARCHAR2(80),
order_date_type     VARCHAR2(80),
demand_class        VARCHAR2(80),
sales_channel       VARCHAR2(80),
ship_to_customer_name  VARCHAR2(360),
ship_to_customer_number  VARCHAR2(50),
invoice_to_customer_name  VARCHAR2(360),
invoice_to_customer_number  VARCHAR2(50),
deliver_to                      VARCHAR2(40),
deliver_to_location             VARCHAR2(40),
deliver_to_address1             VARCHAR2(240),
deliver_to_address2             VARCHAR2(240),
deliver_to_address3             VARCHAR2(240),
deliver_to_address4             VARCHAR2(246),
/*1621182*/
deliver_to_address5             VARCHAR2(246),
/*1621182*/
deliver_to_contact              oe_contacts_v.name%type,   --Bug#9241636
agreement                       VARCHAR2(240),
order_source                    VARCHAR2(240),
source_document_type            VARCHAR2(240),
conversion_type                 VARCHAR2(30),
ship_to_customer_id     NUMBER,
hold_exists_flag                VARCHAR2(1),
Messages_exists_Flag            VARCHAR2(1),
invoice_to_customer_id  NUMBER,
subtotal                      NUMBER,
charges                       NUMBER,
header_charges                NUMBER,
discount                      NUMBER,
tax                           NUMBER,
gsa_indicator                 VARCHAR2(2),
deliver_to_customer_id  NUMBER,
deliver_to_customer_name  VARCHAR2(360),
deliver_to_customer_number  VARCHAR2(50),
/* START PREPAYMENT */
payment_set_id NUMBER,
prepaid_amount NUMBER,
pending_amount NUMBER,
 --pnpl
pay_now_total NUMBER,
/* END PREPAYMENT */
PHONE_NUMBER VARCHAR2(40),
PHONE_AREA_CODE VARCHAR2(10),
PHONE_COUNTRY_CODE VARCHAR2(10),
PHONE_EXTENSION VARCHAR2(20),
--kmuruges
user_status  VARCHAR2(240),
transaction_phase VARCHAR2(240),
sold_to_location             VARCHAR2(240),
sold_to_location_address1    VARCHAR2(240),
sold_to_location_address2          VARCHAR2(240),
sold_to_location_address3             VARCHAR2(240),
sold_to_location_address4             VARCHAR2(240),
sold_to_location_name             VARCHAR2(240),
sold_to_location_city               varchar2(240),
sold_to_location_state               varchar2(240),
sold_to_location_postal               varchar2(240),
sold_to_location_country               varchar2(240),
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
--kmuruges end
blanket_agreement_name              varchar2(240),
ib_owner_dsp                        VARCHAR2(60),
ib_installed_at_location_dsp        VARCHAR2(60),
ib_current_location_dsp             VARCHAR2(60),
-- fp word integration
contract_template                 VARCHAR2(60),
contract_source                 VARCHAR2(60),
authoring_party                 VARCHAR2(60),
--R12 CC Encryption
credit_card_code              	VARCHAR2(80),
credit_card_holder_name       	VARCHAR2(80),
credit_card_number            	VARCHAR2(80),
credit_card_expiration_date   	DATE,
credit_card_approval_code     	VARCHAR2(80),
credit_card_approval_date     	DATE,
instrument_security_code	VARCHAR2(20),
cc_instrument_id		NUMBER,
cc_instrument_assignment_id	NUMBER
--R12 CC Encryption
);


PROCEDURE POPULATE_CONTROL_FIELDS
(
p_header_rec_type             IN  Header_Rec_Type,
x_header_val_rec OUT NOCOPY Header_Val_Rec_Type
);

FUNCTION Get_Cascade_Flag return Boolean;

PROCEDURE Set_Cascade_Flag_False;

TYPE Set_Of_Books_Rec_Type IS RECORD
(   set_of_books_id     NUMBER
,   currency_code       VARCHAR2(15)
);

FUNCTION Load_Set_Of_Books
RETURN Set_Of_Books_Rec_Type;


PROCEDURE get_invoice_to_customer_id ( p_site_use_id IN NUMBER,
x_invoice_to_customer_id OUT NOCOPY NUMBER
                                      );

PROCEDURE get_ship_to_customer_id ( p_site_use_id IN NUMBER,
x_ship_to_customer_id OUT NOCOPY NUMBER
                                   );


PROCEDURE Reset_Debug_Level;

PROCEDURE Set_Debug_Level
                      (
                       p_debug_level IN NUMBER
                       );

PROCEDURE Get_GSA_Indicator( p_sold_to_org_id IN NUMBER,
x_gsa_indicator OUT NOCOPY VARCHAR2
                            );

PROCEDURE CASCADE_HEADER_ATTRIBUTES
                            (
                              p_old_db_header_rec  IN OE_ORDER_PUB.Header_Rec_Type
                         ,    p_header_rec         IN OE_ORDER_PUB.Header_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                              );

TYPE Header_Dff_Rec_Type IS RECORD
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
,   Context                       VARCHAR2(30)
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
);

PROCEDURE CREATE_AGREEMENT(
x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_agreement_name                IN  VARCHAR2
,   p_term_id                       IN  NUMBER
,   p_sold_to_org_id                IN  NUMBER

);

PROCEDURE Clear_Global_PO_Cache;

PROCEDURE Copy_Attribute_To_Rec
(   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_header_dff_rec                IN  OE_OE_FORM_HEADER.header_dff_rec_type
,   p_date_format_mask              IN  VARCHAR2 DEFAULT 'DD-MON-YYYY HH24:MI:SS'
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_old_header_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
);

PROCEDURE Validate_Phone_Number(
                             p_area_code IN VARCHAR2 default null,
                             p_phone_number     IN VARCHAR2 default null,
                             p_country_code     IN VARCHAR2 default null,
                             x_valid OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
                             x_area_codes OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                             x_phone_number_format OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                             x_phone_number_length OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                             );

PROCEDURE Check_Sec_Header_Attr
     (x_return_status         IN OUT NOCOPY varchar2,
      p_header_id              IN OUT NOCOPY NUMBER,
      p_operation               IN OUT NOCOPY VARCHAR2,
      p_column_name           IN VARCHAR2 DEFAULT NULL,
      x_msg_count             IN OUT NOCOPY NUMBER,
      x_msg_data              IN OUT NOCOPY VARCHAR2,
      x_constrained           IN OUT NOCOPY BOOLEAN
);


--ABH
FUNCTION Get_Opr_Update
RETURN varchar2;

-- Start Of Enhanced Cascading

  TYPE Cascade_record IS RECORD
   (
      p_cached                           Varchar2(1) :='N'
     ,p_accounting_rule                  Varchar2(1) :='N'
     ,p_agreement                        Varchar2(1) :='N'
     ,p_customer_po                      Varchar2(1) :='N'
     ,p_blanket_number                   Varchar2(1) :='N'
     ,p_deliver_to_contact               Varchar2(1) :='N'
     ,p_deliver_to                       Varchar2(1) :='N'
     ,p_demand_class                     Varchar2(1) :='N'
     ,p_fob_point                        Varchar2(1) :='N'
     ,p_freight_terms                    Varchar2(1) :='N'
     ,p_bill_to_contact                  Varchar2(1) :='N'
     ,p_bill_to                          Varchar2(1) :='N'
     ,p_invoicing_rule                   Varchar2(1) :='N'
     ,p_order_firmed_date                Varchar2(1) :='N'
     ,p_payment_term                     Varchar2(1) :='N'
     ,p_price_list                       Varchar2(1) :='N'
     ,p_request_date                     Varchar2(1) :='N'
     ,p_return_reason                    Varchar2(1) :='N'
     ,p_salesperson                      Varchar2(1) :='N'
     ,p_shipment_priority                Varchar2(1) :='N'
     ,p_shipping_method                  Varchar2(1) :='N'
     ,p_warehouse                        Varchar2(1) :='N'
     ,p_ship_to_contact                  Varchar2(1) :='N'
     ,p_ship_to                          Varchar2(1) :='N'
     ,p_customer                         Varchar2(1) :='N'
     ,p_tax_exempt                       Varchar2(1) :='N'

  );




  PROCEDURE Read_Cascadable_Fields
   (
      x_cascade_record  OUT NOCOPY OE_OE_FORM_HEADER.cascade_record
   );

-- End Of Enhanced Cascading

END Oe_Oe_Form_Header;

/

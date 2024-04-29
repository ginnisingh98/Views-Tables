--------------------------------------------------------
--  DDL for Package OE_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUHDRS.pls 120.3.12010000.4 2009/05/27 12:27:44 vmachett ship $ */

--  Attributes global constants
G_ACCOUNTING_RULE		CONSTANT NUMBER := 1;
G_AGREEMENT          		CONSTANT NUMBER := 2;
G_ATTRIBUTE1          		CONSTANT NUMBER := 3;
G_ATTRIBUTE10          		CONSTANT NUMBER := 4;
G_ATTRIBUTE11          		CONSTANT NUMBER := 5;
G_ATTRIBUTE12          		CONSTANT NUMBER := 6;
G_ATTRIBUTE13          		CONSTANT NUMBER := 7;
G_ATTRIBUTE14          		CONSTANT NUMBER := 8;
G_ATTRIBUTE15        	  	CONSTANT NUMBER := 9;
G_ATTRIBUTE2          		CONSTANT NUMBER := 10;
G_ATTRIBUTE3         	 	CONSTANT NUMBER := 11;
G_ATTRIBUTE4          		CONSTANT NUMBER := 12;
G_ATTRIBUTE5          		CONSTANT NUMBER := 13;
G_ATTRIBUTE6          		CONSTANT NUMBER := 14;
G_ATTRIBUTE7          		CONSTANT NUMBER := 15;
G_ATTRIBUTE8          		CONSTANT NUMBER := 16;
G_ATTRIBUTE9          		CONSTANT NUMBER := 17;
G_BOOKED              		CONSTANT NUMBER := 18;
G_CANCELLED          		CONSTANT NUMBER := 19;
G_CHANGE_SEQUENCE_ID        	CONSTANT NUMBER := 20;
G_CONTEXT          		    CONSTANT NUMBER := 21;
G_CONVERSION_RATE      	        CONSTANT NUMBER := 22;
G_CONVERSION_RATE_DATE  	CONSTANT NUMBER := 23;
G_CONVERSION_TYPE       	CONSTANT NUMBER := 24;
G_CREATED_BY          		CONSTANT NUMBER := 25;
G_CREATION_DATE         	CONSTANT NUMBER := 26;
G_CUSTOMER_PAYMENT_TERM_ID      CONSTANT NUMBER := 27;
G_CUST_PO_NUMBER                CONSTANT NUMBER := 28;
G_DELIVER_TO_CONTACT          	CONSTANT NUMBER := 29;
G_DELIVER_TO_ORG          	CONSTANT NUMBER := 30;
G_DEMAND_CLASS         	        CONSTANT NUMBER := 31;
G_DROP_SHIP_FLAG                CONSTANT NUMBER := 32;
G_EARLIEST_SCHEDULE_LIMIT       CONSTANT NUMBER := 33;
G_EXPIRATION_DATE               CONSTANT NUMBER := 34;
G_FOB_POINT          		CONSTANT NUMBER := 35;
G_FREIGHT_CARRIER          	CONSTANT NUMBER := 36;
G_FREIGHT_TERMS          	CONSTANT NUMBER := 37;
G_GLOBAL_ATTRIBUTE1          	CONSTANT NUMBER := 38;
G_GLOBAL_ATTRIBUTE10          	CONSTANT NUMBER := 39;
G_GLOBAL_ATTRIBUTE11          	CONSTANT NUMBER := 40;
G_GLOBAL_ATTRIBUTE12      	CONSTANT NUMBER := 41;
G_GLOBAL_ATTRIBUTE13          	CONSTANT NUMBER := 42;
G_GLOBAL_ATTRIBUTE14         	CONSTANT NUMBER := 43;
G_GLOBAL_ATTRIBUTE15          	CONSTANT NUMBER := 44;
G_GLOBAL_ATTRIBUTE16          	CONSTANT NUMBER := 45;
G_GLOBAL_ATTRIBUTE17          	CONSTANT NUMBER := 46;
G_GLOBAL_ATTRIBUTE18          	CONSTANT NUMBER := 47;
G_GLOBAL_ATTRIBUTE19          	CONSTANT NUMBER := 48;
G_GLOBAL_ATTRIBUTE2          	CONSTANT NUMBER := 49;
G_GLOBAL_ATTRIBUTE20          	CONSTANT NUMBER := 50;
G_GLOBAL_ATTRIBUTE3          	CONSTANT NUMBER := 51;
G_GLOBAL_ATTRIBUTE4          	CONSTANT NUMBER := 52;
G_GLOBAL_ATTRIBUTE5          	CONSTANT NUMBER := 53;
G_GLOBAL_ATTRIBUTE6          	CONSTANT NUMBER := 54;
G_GLOBAL_ATTRIBUTE7          	CONSTANT NUMBER := 55;
G_GLOBAL_ATTRIBUTE8          	CONSTANT NUMBER := 56;
G_GLOBAL_ATTRIBUTE9          	CONSTANT NUMBER := 57;
G_GLOBAL_ATTRIBUTE_CATEGORY     CONSTANT NUMBER := 58;
G_HEADER          		CONSTANT NUMBER := 59;
G_INVOICE_TO_CONTACT          	CONSTANT NUMBER := 60;
G_INVOICE_TO_ORG          	CONSTANT NUMBER := 61;
G_INVOICING_RULE                CONSTANT NUMBER := 62;
G_LAST_UPDATED_BY          	CONSTANT NUMBER := 63;
G_LAST_UPDATE_DATE          	CONSTANT NUMBER := 64;
G_LAST_UPDATE_LOGIN          	CONSTANT NUMBER := 65;
G_LATEST_SCHEDULE_LIMIT         CONSTANT NUMBER := 66;
G_OPEN          		CONSTANT NUMBER := 67;
G_ORDERED_DATE          	CONSTANT NUMBER := 68;
G_ORDER_DATE_TYPE_CODE          CONSTANT NUMBER := 69;
G_ORDER_NUMBER          	CONSTANT NUMBER := 70;
G_ORDER_SOURCE          	CONSTANT NUMBER := 71;
G_ORDER_TYPE          		CONSTANT NUMBER := 72;
G_ORG          			CONSTANT NUMBER := 73;
G_ORIG_SYS_DOCUMENT_REF         CONSTANT NUMBER := 74;
G_PARTIAL_SHIPMENTS_ALLOWED     CONSTANT NUMBER := 75;
G_PAYMENT_TERM          	CONSTANT NUMBER := 76;
G_PRICE_LIST          		CONSTANT NUMBER := 77;
G_PRICING_DATE          	CONSTANT NUMBER := 78;
G_PROGRAM          		CONSTANT NUMBER := 79;
G_PROGRAM_APPLICATION           CONSTANT NUMBER := 80;
G_PROGRAM_UPDATE_DATE           CONSTANT NUMBER := 81;
G_REQUEST          		CONSTANT NUMBER := 82;
G_REQUEST_DATE          	CONSTANT NUMBER := 83;
G_RETURN_REASON          	CONSTANT NUMBER := 84;
G_SALESREP          		CONSTANT NUMBER := 85;
G_SHIPMENT_PRIORITY          	CONSTANT NUMBER := 86;
G_SHIPPING_METHOD          	CONSTANT NUMBER := 87;
G_SHIP_FROM_ORG          	CONSTANT NUMBER := 88;
G_SHIP_TOLERANCE_ABOVE          CONSTANT NUMBER := 89;
G_SHIP_TOLERANCE_BELOW          CONSTANT NUMBER := 90;
G_SHIP_TO_CONTACT          	CONSTANT NUMBER := 91;
G_SHIP_TO_ORG          		CONSTANT NUMBER := 92;
G_SOLD_TO_CONTACT          	CONSTANT NUMBER := 93;
G_SOLD_TO_ORG          		CONSTANT NUMBER := 94;
G_SOURCE_DOCUMENT          	CONSTANT NUMBER := 95;
G_SOURCE_DOCUMENT_TYPE        CONSTANT NUMBER := 96;
G_TAX_EXEMPT          		CONSTANT NUMBER := 97;
G_TAX_EXEMPT_NUMBER          	CONSTANT NUMBER := 98;
G_TAX_EXEMPT_REASON          	CONSTANT NUMBER := 99;
G_TAX_POINT          		CONSTANT NUMBER := 100;
G_TRANSACTIONAL_CURR          CONSTANT NUMBER := 101;
G_VERSION_NUMBER          	CONSTANT NUMBER := 102;
G_PAYMENT_TYPE                CONSTANT NUMBER := 103;
G_PAYMENT_AMOUNT              CONSTANT NUMBER := 104;
G_CHECK_NUMBER                CONSTANT NUMBER := 105;
G_CREDIT_CARD                 CONSTANT NUMBER := 106;
G_CREDIT_CARD_HOLDER_NAME     CONSTANT NUMBER := 107;
G_CREDIT_CARD_NUMBER          CONSTANT NUMBER := 108;
G_CREDIT_CARD_EXPIRATION_DATE CONSTANT NUMBER := 109;
G_CREDIT_CARD_APPROVAL        CONSTANT NUMBER := 110;
G_FIRST_ACK                   CONSTANT NUMBER := 111;
G_FIRST_ACK_DATE              CONSTANT NUMBER := 112;
G_LAST_ACK                    CONSTANT NUMBER := 113;
G_LAST_ACK_DATE               CONSTANT NUMBER := 115;
G_SHIPPING_INSTRUCTIONS		CONSTANT NUMBER := 116;
G_PACKING_INSTRUCTIONS		CONSTANT NUMBER := 117;
G_ORDER_CATEGORY		     CONSTANT NUMBER := 118;
G_FLOW_STATUS			     CONSTANT NUMBER := 119;
G_CREDIT_CARD_APPROVAL_DATE   CONSTANT NUMBER := 120;
G_CUSTOMER_PREFERENCE_SET     CONSTANT NUMBER := 121;
G_BOOKED_DATE          		CONSTANT NUMBER := 122;
/*Synched up the TP constants with the client constant */

G_TP_CONTEXT                  CONSTANT NUMBER := 124;
G_TP_ATTRIBUTE1               CONSTANT NUMBER := 125;
G_TP_ATTRIBUTE2               CONSTANT NUMBER := 126;
G_TP_ATTRIBUTE3               CONSTANT NUMBER := 127;
G_TP_ATTRIBUTE4               CONSTANT NUMBER := 128;
G_TP_ATTRIBUTE5               CONSTANT NUMBER := 129;
G_TP_ATTRIBUTE6               CONSTANT NUMBER := 130;
G_TP_ATTRIBUTE7               CONSTANT NUMBER := 131;
G_TP_ATTRIBUTE8               CONSTANT NUMBER := 132;
G_TP_ATTRIBUTE9               CONSTANT NUMBER := 133;
G_TP_ATTRIBUTE10              CONSTANT NUMBER := 134;
G_TP_ATTRIBUTE11              CONSTANT NUMBER := 135;
G_TP_ATTRIBUTE12              CONSTANT NUMBER := 136;
G_TP_ATTRIBUTE13              CONSTANT NUMBER := 137;
G_TP_ATTRIBUTE14              CONSTANT NUMBER := 138;
G_TP_ATTRIBUTE15              CONSTANT NUMBER := 139;
G_MARKETING_SOURCE_CODE_ID    CONSTANT NUMBER := 140;
G_SALES_CHANNEL        	      CONSTANT NUMBER := 141;
G_UPGRADED                    CONSTANT NUMBER := 142;
G_LOCK_CONTROL                CONSTANT NUMBER := 143;
G_PRICE_REQUEST_CODE	      CONSTANT NUMBER := 144;  -- PROMOTIONS SEP/01
G_ACCOUNTING_RULE_DURATION    CONSTANT NUMBER := 145;
-- ER 2184255 additional DFF segments
G_ATTRIBUTE16          	      CONSTANT NUMBER := 146;
G_ATTRIBUTE17          	      CONSTANT NUMBER := 147;
G_ATTRIBUTE18          	      CONSTANT NUMBER := 148;
G_ATTRIBUTE19          	      CONSTANT NUMBER := 149;
G_ATTRIBUTE20                 CONSTANT NUMBER := 150;

G_BLANKET_NUMBER              CONSTANT NUMBER := 151;
G_SOLD_TO_PHONE               CONSTANT NUMBER := 152;
G_DEFAULT_FULFILLMENT_SET     CONSTANT NUMBER := 153;
G_LINE_SET_NAME               CONSTANT NUMBER := 154;
G_FULFILLMENT_SET_NAME        CONSTANT NUMBER := 155;
-- QUOTING changes
g_quote_date               CONSTANT NUMBER := 156;
g_quote_number             CONSTANT NUMBER := 157;
g_sales_document_name      CONSTANT NUMBER := 158;
g_transaction_phase        CONSTANT NUMBER := 159;
g_user_status              CONSTANT NUMBER := 160;
g_draft_submitted          CONSTANT NUMBER := 161;
g_source_document_version  CONSTANT NUMBER := 162;
g_sold_to_site_use         CONSTANT NUMBER := 163;
-- QUOTING changes END
G_MINISITE_ID                 CONSTANT NUMBER := 164;
G_IB_OWNER                    CONSTANT NUMBER := 165;
G_IB_INSTALLED_AT_LOCATION    CONSTANT NUMBER := 166;
G_IB_CURRENT_LOCATION         CONSTANT NUMBER := 167;
G_END_CUSTOMER                CONSTANT NUMBER := 168;
G_END_CUSTOMER_CONTACT       CONSTANT NUMBER := 169;
G_END_CUSTOMER_SITE_USE       CONSTANT NUMBER := 170;
G_SUPPLIER_SIGNATURE          CONSTANT NUMBER := 171;
G_SUPPLIER_SIGNATURE_DATE     CONSTANT NUMBER := 172;
G_CUSTOMER_SIGNATURE          CONSTANT NUMBER := 173;
G_CUSTOMER_SIGNATURE_DATE     CONSTANT NUMBER := 174;
G_CONTRACT_TEMPLATE           CONSTANT NUMBER := 175;
g_contract_source_doc_type CONSTANT NUMBER := 176;
g_contract_source_document    CONSTANT NUMBER  := 177;
--key Transaction Dates
G_ORDER_FIRMED_DATE           CONSTANT NUMBER := 178;
--R12 CC Encryption
G_INSTRUMENT_SECURITY         CONSTANT NUMBER := 178;
G_CC_INSTRUMENT 	      CONSTANT NUMBER := 179;
G_CC_INSTRUMENT_ASSIGNMENT    CONSTANT NUMBER := 180;
--R12 CC Encryption
G_MAX_ATTR_ID          	      CONSTANT NUMBER := 181;


-- Function to initialize view%rowtype record

FUNCTION G_MISS_OE_AK_HEADER_REC
RETURN OE_AK_ORDER_HEADERS_V%ROWTYPE;

-- Procedure API_Rec_To_Rowtype_Rec

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
);

-- Procedure Rowtype_Rec_To_API_Rec

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.HEADER_Rec_Type
);

--  Procedure Clear_Dependent_Attr: Overloaded for view%rowtype PARAMETERS

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_initial_header_rec            IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_old_header_rec                IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_x_header_rec                  IN  OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_x_instrument_id		    IN NUMBER DEFAULT NULL -- R12 CC Encryption
,   p_old_instrument_id		    IN NUMBER DEFAULT NULL
);

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_header_rec                  IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_header_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
);

--  Function Complete_Record

PROCEDURE Complete_Record
(   p_x_header_rec   IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type
) ;

--  Function Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_header_rec   IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
) ;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_header_rec                    IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_header_rec                    IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_header_id                     IN  NUMBER
);

-- FUNCTION Query_Row
-- IMPORTANT: DO NOT CHANGE THE SPEC OF THIS FUNCTION
-- IT IS PUBLIC AND BEING CALLED BY OTHER PRODUCTS
-- Private OM callers should call the procedure query_row instead
-- as it has the nocopy option which would improve the performance

FUNCTION Query_Row
(   p_header_id                       IN  NUMBER
) RETURN OE_Order_PUB.Header_Rec_Type;

--  Function Query_Row

PROCEDURE Query_Row
(   p_header_id                     IN  NUMBER,
    x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
) ;
--R12 CC Encryption
PROCEDURE Query_card_Details
(    p_header_id IN NUMBER,
     p_credit_card_code OUT NOCOPY VARCHAR2,
     p_credit_card_holder_name OUT NOCOPY VARCHAR2,
     p_credit_card_number OUT NOCOPY VARCHAR2,
     p_credit_Card_expiration_date OUT NOCOPY VARCHAR2,
     p_credit_card_approval_code OUT NOCOPY VARCHAR2,
     p_credit_card_approval_Date OUT NOCOPY VARCHAR2,
     p_instrument_security_code OUT NOCOPY VARCHAR2,
     p_instrument_id OUT NOCOPY NUMBER,
     p_instrument_assignment_id OUT NOCOPY NUMBER
);
--R12 CC Encryption

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_header_rec                  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_header_id	 		    IN NUMBER
					:= FND_API.G_MISS_NUM
);


PROCEDURE cancel_header_charges
( p_header_id   IN number ,
  x_return_status OUT NOCOPY varchar2
);

--  Function Get_Values

FUNCTION Get_Values
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
) RETURN OE_Order_PUB.Header_Val_Rec_Type;

--  Function Get_Ids

PROCEDURE Get_Ids
(   p_x_header_rec   IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
) ;

FUNCTION Get_ord_seq_type
(   p_order_type_id                 IN  NUMBER
 ,  p_transaction_phase_code        IN  VARCHAR2 DEFAULT 'F'
) RETURN VARCHAR2;


FUNCTION Get_Mtl_Sales_Order_Id
(p_header_id     IN  NUMBER,
 p_order_number  IN  NUMBER := FND_API.G_MISS_NUM)
RETURN NUMBER;

PROCEDURE Get_Order_Info(p_header_id    IN  NUMBER,
                         x_order_number OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_order_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                         x_order_source OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION Get_Header_Id(p_order_number    IN  NUMBER,
                       p_order_type      IN  VARCHAR2,
                       p_order_source    IN  VARCHAR2)
RETURN NUMBER;

FUNCTION Get_Order_Type
(   p_order_type_id        IN  NUMBER)
RETURN VARCHAR2 ;

PROCEDURE Get_Order_Number
         ( p_x_header_rec 	IN OUT NOCOPY  oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type );

PROCEDURE Pre_Write_Process(
          p_x_header_rec 	IN OUT NOCOPY  oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type );

PROCEDURE Post_Write_Process(
          p_x_header_rec 	IN OUT NOCOPY  oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type );

Procedure Validate_Gapless_Seq( p_application_id IN NUMBER,
                         p_entity_short_name in VARCHAR2,
                         p_validation_entity_short_name in VARCHAR2,
                         p_validation_tmplt_short_name in VARCHAR2,
                         p_record_set_tmplt_short_name in VARCHAR2,
                         p_scope in VARCHAR2,
                         p_result OUT NOCOPY /* file.sql.39 change */ NUMBER );


--bug 5083663
g_is_cc_selected_from_LOV VARCHAR2(1) := 'N';
Procedure Set_CC_Selected_From_Lov (p_CC_selected_from_LOV IN VARCHAR2);


PROCEDURE get_customer_details
(   p_org_id                IN  NUMBER
,   p_site_use_code         IN  VARCHAR2
,   x_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_number       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_zip                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--ER7675548
Procedure Get_customer_info_ids
( p_header_customer_info_tbl IN OUT NOCOPY OE_Order_Pub.CUSTOMER_INFO_TABLE_TYPE,
  p_x_header_rec       IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count    OUT NOCOPY NUMBER,
  x_msg_data    OUT NOCOPY VARCHAR2
);

--7688372 start
   TYPE attachment_rule_count_tab IS  TABLE OF NUMBER INDEX by oe_attachment_rule_elements.ATTRIBUTE_CODE%TYPE;
   g_attachment_rule_count_tab  attachment_rule_count_tab;
--7688372 end
--Added for bug 8489881
FUNCTION Get_Primary_Site_Use_Id
(   p_site_use		IN VARCHAR2,
    p_cust_acct_id	IN NUMBER,
    p_org_id		IN NUMBER)
RETURN NUMBER;

END OE_Header_Util;

/

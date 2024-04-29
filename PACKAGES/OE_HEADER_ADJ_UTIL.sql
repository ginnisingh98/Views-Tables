--------------------------------------------------------
--  DDL for Package OE_HEADER_ADJ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_ADJ_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUHADS.pls 120.1.12010000.1 2008/07/25 07:55:56 appldev ship $ */

--  Attributes global constants
G_ATTRIBUTE1                  CONSTANT NUMBER := 1;
G_ATTRIBUTE10                 CONSTANT NUMBER := 2;
G_ATTRIBUTE11                 CONSTANT NUMBER := 3;
G_ATTRIBUTE12                 CONSTANT NUMBER := 4;
G_ATTRIBUTE13                 CONSTANT NUMBER := 5;
G_ATTRIBUTE14                 CONSTANT NUMBER := 6;
G_ATTRIBUTE15                 CONSTANT NUMBER := 7;
G_ATTRIBUTE2                  CONSTANT NUMBER := 8;
G_ATTRIBUTE3                  CONSTANT NUMBER := 9;
G_ATTRIBUTE4                  CONSTANT NUMBER := 10;
G_ATTRIBUTE5                  CONSTANT NUMBER := 11;
G_ATTRIBUTE6                  CONSTANT NUMBER := 12;
G_ATTRIBUTE7                  CONSTANT NUMBER := 13;
G_ATTRIBUTE8                  CONSTANT NUMBER := 14;
G_ATTRIBUTE9                  CONSTANT NUMBER := 15;
G_AUTOMATIC                   CONSTANT NUMBER := 16;
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_DISCOUNT                    CONSTANT NUMBER := 20;
G_DISCOUNT_LINE               CONSTANT NUMBER := 21;
G_HEADER                      CONSTANT NUMBER := 22;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 23;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 24;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 25;
G_LINE                        CONSTANT NUMBER := 26;
G_PERCENT                     CONSTANT NUMBER := 27;
G_PRICE_ADJUSTMENT            CONSTANT NUMBER := 28;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 29;
G_PROGRAM                     CONSTANT NUMBER := 30;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 31;
G_REQUEST                     CONSTANT NUMBER := 32;
G_ORIG_SYS_DISCOUNT_REF       CONSTANT NUMBER := 33;
G_CHANGE_SEQUENCE_ID          CONSTANT NUMBER := 34;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 35;
G_LIST_HEADER_ID		     CONSTANT NUMBER := 36;
G_LIST_LINE_ID		          CONSTANT NUMBER := 37;
G_LIST_LINE_TYPE_CODE	     CONSTANT NUMBER := 38;
G_MODIFIER_MECHANISM_TYPE_CODE CONSTANT NUMBER := 39;
G_MODIFIED_FROM		     CONSTANT	NUMBER := 40;
G_MODIFIED_TO			     CONSTANT	NUMBER := 41;
G_UPDATED_FLAG			     CONSTANT	NUMBER := 42;
G_UPDATE_ALLOWED	     	CONSTANT	NUMBER := 43;
G_APPLIED_FLAG			     CONSTANT	NUMBER := 44;
G_CHANGE_REASON_CODE	     CONSTANT  NUMBER := 45;
G_CHANGE_REASON_TEXT	     CONSTANT	NUMBER := 46;
G_OPERAND				     CONSTANT	NUMBER := 47;
G_ARITHMETIC_OPERATOR	     CONSTANT	NUMBER := 48;
G_COST_ID                     CONSTANT  NUMBER := 49;
G_TAX_CODE                    CONSTANT  NUMBER := 50;
G_TAX_EXEMPT_FLAG             CONSTANT  NUMBER := 51;
G_TAX_EXEMPT_NUMBER           CONSTANT  NUMBER := 52;
G_TAX_EXEMPT_REASON_CODE      CONSTANT  NUMBER := 53;
G_PARENT_ADJUSTMENT_ID        CONSTANT  NUMBER := 54;
G_INVOICED_FLAG               CONSTANT  NUMBER := 55;
G_ESTIMATED_FLAG              CONSTANT  NUMBER := 56;
G_INC_IN_SALES_PERFORMANCE    CONSTANT     NUMBER := 57;
G_SPLIT_ACTION_CODE           CONSTANT  NUMBER := 58;
G_ADJUSTED_AMOUNT		     CONSTANT	NUMBER := 59;
G_PRICING_PHASE_ID		     CONSTANT  NUMBER := 60;
G_CHARGE_TYPE_CODE		     CONSTANT  NUMBER := 61;
G_CHARGE_SUBTYPE_CODE	     CONSTANT  NUMBER := 62;
G_LIST_LINE_NO                CONSTANT  NUMBER := 63;
G_SOURCE_SYSTEM_CODE          CONSTANT  NUMBER := 64;
G_BENEFIT_QTY                 CONSTANT  NUMBER := 65;
G_BENEFIT_UOM_CODE            CONSTANT  NUMBER := 66;
G_PRINT_ON_INVOICE_FLAG       CONSTANT  NUMBER := 67;
G_EXPIRATION_DATE             CONSTANT  NUMBER := 68;
G_REBATE_TRANSACTION_TYPE_CODE CONSTANT  NUMBER := 69;
G_REBATE_TRANSACTION_REFERENCE CONSTANT  NUMBER := 70;
G_REBATE_PAYMENT_SYSTEM_CODE  CONSTANT  NUMBER := 71;
G_REDEEMED_DATE               CONSTANT  NUMBER := 72;
G_REDEEMED_FLAG               CONSTANT  NUMBER := 73;
G_ACCRUAL_FLAG                CONSTANT  NUMBER := 74;
G_range_break_quantity        CONSTANT  NUMBER := 75;
G_accrual_conversion_rate     CONSTANT  NUMBER := 76;
G_pricing_group_sequence	     CONSTANT  NUMBER := 77;
G_modifier_level_code	     CONSTANT  NUMBER := 78;
G_price_break_type_code	     CONSTANT  NUMBER := 79;
G_substitution_attribute	     CONSTANT  NUMBER := 80;
G_proration_type_code	     CONSTANT  NUMBER := 81;
G_CREDIT_OR_CHARGE_FLAG	     CONSTANT  NUMBER := 82;
G_INCLUDE_ON_RETURNS_FLAG     CONSTANT  NUMBER := 83;
G_AC_CONTEXT                  CONSTANT NUMBER := 84;
G_AC_ATTRIBUTE1               CONSTANT NUMBER := 85;
G_AC_ATTRIBUTE2               CONSTANT NUMBER := 86;
G_AC_ATTRIBUTE3               CONSTANT NUMBER := 87;
G_AC_ATTRIBUTE4               CONSTANT NUMBER := 88;
G_AC_ATTRIBUTE5               CONSTANT NUMBER := 89;
G_AC_ATTRIBUTE6               CONSTANT NUMBER := 90;
G_AC_ATTRIBUTE7               CONSTANT NUMBER := 91;
G_AC_ATTRIBUTE8               CONSTANT NUMBER := 92;
G_AC_ATTRIBUTE9               CONSTANT NUMBER := 93;
G_AC_ATTRIBUTE10              CONSTANT NUMBER := 94;
G_AC_ATTRIBUTE11              CONSTANT NUMBER := 95;
G_AC_ATTRIBUTE12              CONSTANT NUMBER := 96;
G_AC_ATTRIBUTE13              CONSTANT NUMBER := 97;
G_AC_ATTRIBUTE14              CONSTANT NUMBER := 98;
G_AC_ATTRIBUTE15              CONSTANT NUMBER := 99;
--uom begin
--G_OPERAND_PER_PQTY            CONSTANT NUMBER := 100;
--G_ADJUSTED_AMOUNT_PER_PQTY    CONSTANT NUMBER := 101;
--uom end

--Manual begin
G_OVERRIDE_ALLOWED_FLAG		CONSTANT NUMBER := 106;
--Manual end
G_OPERAND_PER_PQTY              CONSTANT NUMBER := 107;
G_ADJUSTED_AMOUNT_PER_PQTY      CONSTANT NUMBER := 108;
G_INVOICED_AMOUNT	        CONSTANT NUMBER := 109;

type line_adjustments_rec_type is record
(price_adjustment_id		number :=null,
 adjustment_name			varchar2(240) :=null,
 adjustment_description                 varchar2(2000) := null,  --Enhancement 3816014
 list_line_no                           varchar2(240) :=null,
 adjustment_type_code		varchar2(30) :=null,
 operand					number :=null,
 arithmetic_operator		varchar2(30) :=null,
 unit_discount_amount			number := null
 );

 Type line_adjustments_tab_type is Table of line_adjustments_rec_type
 index by binary_integer;

 procedure get_line_adjustments
 (p_header_id			number
 ,p_line_id			number
,x_line_adjustments out nocopy line_adjustments_tab_type

 );

FUNCTION G_MISS_OE_AK_HEADER_ADJ_REC
RETURN OE_AK_HEADER_PRCADJS_V%ROWTYPE;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_ADJ_rec            IN  OE_Order_PUB.HEADER_ADJ_Rec_Type
,   x_rowtype_rec                   OUT nocopy OE_AK_HEADER_PRCADJS_V%ROWTYPE
);

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   x_api_rec                       OUT nocopy OE_Order_PUB.HEADER_ADJ_Rec_Type
);


-- Procedure Clear_Dependent_Attr: Overloaded for VIEW%ROWTYPE parameters

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Adj_rec              IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   p_old_Header_Adj_rec            IN  OE_AK_HEADER_PRCADJS_V%ROWTYPE :=
								G_MISS_OE_AK_HEADER_ADJ_REC
);

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Adj_rec              IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
--,   x_Header_Adj_rec                OUT OE_Order_PUB.Header_Adj_Rec_Type
);

--Bug 4060297
Procedure log_request_for_margin(p_header_id in number);


--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Header_Adj_rec                IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
--,   x_Header_Adj_rec                OUT OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Header_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Header_Adj_rec                IN  OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
);

-- Procedure Delete_Header_Charges

Procedure Delete_Header_Charges
(
  p_header_id     IN Number
);

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_price_adjustment_id           IN  NUMBER
,   x_Header_Adj_Rec			 IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

--  Procedure Query_Rows

PROCEDURE Query_Rows
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Header_Adj_Tbl			 IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
);

--  Procedure       lock_Row

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
--                                        := OE_Order_PUB.G_MISS_HEADER_ADJ_REC
,   p_price_adjustment_id           IN NUMBER
                                        := FND_API.G_MISS_NUM
);

--  Procedure       lock_Rows
PROCEDURE Lock_Rows
(   p_price_adjustment_id          IN NUMBER
                                        := FND_API.G_MISS_NUM
,   p_header_id           		IN NUMBER
                                        := FND_API.G_MISS_NUM
,   x_Header_Adj_tbl               OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

--  Function Get_Values

FUNCTION Get_Values
(   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
) RETURN OE_Order_PUB.Header_Adj_Val_Rec_Type;

--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_Header_Adj_val_rec            IN  OE_Order_PUB.Header_Adj_Val_Rec_Type
);


PROCEDURE Log_Adj_Requests
( x_return_status OUT NOCOPY VARCHAR2

, p_adj_rec		IN	OE_order_pub.Header_Adj_Rec_Type
, p_old_adj_rec		IN	OE_order_pub.Header_Adj_Rec_Type
, p_delete_flag		IN	BOOLEAN DEFAULT FALSE
  );


FUNCTION  get_adj_total
( p_header_id       IN   NUMBER := NULL
, p_line_id       IN   NUMBER := NULL
)
		RETURN NUMBER;

/* Start AuditTrail */
PROCEDURE Pre_Write_Process
          ( p_x_header_adj_rec IN OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.header_adj_rec_type,
            p_old_header_adj_rec IN OE_ORDER_PUB.header_adj_rec_type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC) ;
/* End Audit Trail */

/* Fix for 1559906: New Procedure to Copy Freight Charges */

PROCEDURE copy_freight_charges
( p_from_header_id    IN   NUMBER
, p_to_header_id      IN   NUMBER
, p_to_order_category IN   VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

);

/* Fix for 2170086: New Procedure to Copy Header Adjustments */

PROCEDURE copy_header_adjustments
( p_from_header_id    IN   NUMBER
, p_to_header_id      IN   NUMBER
, p_to_order_category IN   VARCHAR2
, x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

--Recurring CHarges
FUNCTION  get_rec_adj_total
( p_header_id         IN   NUMBER := NULL
, p_line_id           IN   NUMBER := NULL
, p_charge_periodicity_code       IN   VARCHAR2
)
		RETURN NUMBER;
--Recurring CHarges

--rc pviprana this function will return recurring amount given the order level modifier and periodicity
FUNCTION  get_rec_order_adj_total
( p_header_id       IN   NUMBER DEFAULT NULL
, p_price_adjustment_id IN NUMBER DEFAULT NULL
, p_charge_periodicity_code  IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER;


END OE_Header_Adj_Util;

/

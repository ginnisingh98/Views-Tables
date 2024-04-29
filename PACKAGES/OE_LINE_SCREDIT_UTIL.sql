--------------------------------------------------------
--  DDL for Package OE_LINE_SCREDIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_SCREDIT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULSCS.pls 120.0.12000000.1 2007/01/16 22:04:04 appldev ship $ */

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
G_CONTEXT                     CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_CREATION_DATE               CONSTANT NUMBER := 18;
G_DW_UPDATE_ADVICE            CONSTANT NUMBER := 19;
G_HEADER                      CONSTANT NUMBER := 20;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 21;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 22;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 23;
G_LINE                        CONSTANT NUMBER := 24;
G_PERCENT                     CONSTANT NUMBER := 25;
G_QUOTA                       CONSTANT NUMBER := 26;
G_SALESREP                    CONSTANT NUMBER := 27;
G_SALES_CREDIT                CONSTANT NUMBER := 28;
G_WH_UPDATE_DATE              CONSTANT NUMBER := 29;
G_ORIG_SYS_CREDIT_REF         CONSTANT NUMBER := 30;
G_CHANGE_SEQUENCE_ID          CONSTANT NUMBER := 31;
G_SALES_CREDIT_TYPE           CONSTANT NUMBER := 32;
G_LOCK_CONTROL                CONSTANT NUMBER := 33;
--SG{
G_SALES_GROUP_ID              CONSTANT NUMBER := 34;
G_SALES_GROUP                 CONSTANT NUMBER := 35;
G_SALES_GROUP_UPDATED_FLAG    CONSTANT NUMBER := 36;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 37;
--SG}


FUNCTION G_MISS_OE_AK_LINE_SCREDIT_REC
RETURN OE_AK_LINE_SCREDITS_V%ROWTYPE;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_SCREDIT_rec              IN  OE_Order_PUB.LINE_SCREDIT_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
);

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_LINE_SCREDITS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.LINE_SCREDIT_Rec_Type
);

--  Procedure Clear_Dependent_Attr: Overloaded for VIEW%ROWTYPE parameters

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Scredit_rec            IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
,   p_old_Line_Scredit_rec          IN  OE_AK_LINE_SCREDITS_V%ROWTYPE :=
                                        G_MISS_OE_AK_LINE_SCREDIT_REC
);

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Scredit_rec            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
);

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Scredit_rec              IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
);

--  Procedure Query_Row

PROCEDURE Query_Row
(   p_sales_credit_id               IN  NUMBER
,   x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
);

--  Procedure Query_Rows

--

PROCEDURE Query_Rows
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_sales_credit_id               IN NUMBER
                                        := FND_API.G_MISS_NUM
);

PROCEDURE Lock_Rows
(   p_sales_credit_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_scredit_tbl          OUT NOCOPY OE_Order_PUB.Line_scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

 );

--  Function Get_Values

FUNCTION Get_Values
(   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
) RETURN OE_Order_PUB.Line_Scredit_Val_Rec_Type;

--  PROCEDURE Get_Ids

PROCEDURE Get_Ids
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_Line_Scredit_val_rec          IN  OE_Order_PUB.Line_Scredit_Val_Rec_Type
);

Procedure Create_credit(p_line_rec IN oe_order_pub.line_rec_type,
                         p_old_line_rec IN oe_order_pub.line_rec_type);

PROCEDURE Pre_Write_Process
(p_x_line_scredit_rec IN OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.line_scredit_rec_type,
p_old_line_scredit_rec IN OE_ORDER_PUB.line_scredit_rec_type :=
				 OE_ORDER_PUB.G_MISS_LINE_SCREDIT_REC);

END OE_Line_Scredit_Util;

 

/

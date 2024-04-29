--------------------------------------------------------
--  DDL for Package QP_CURR_DETAILS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CURR_DETAILS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUCDTS.pls 120.1.12010000.1 2008/07/28 11:56:22 appldev ship $ */

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
G_CONVERSION_DATE             CONSTANT NUMBER := 17;
G_CONVERSION_DATE_TYPE        CONSTANT NUMBER := 18;
-- G_CONVERSION_METHOD           CONSTANT NUMBER := 19;
G_CONVERSION_TYPE             CONSTANT NUMBER := 19;
G_CREATED_BY                  CONSTANT NUMBER := 20;
G_CREATION_DATE               CONSTANT NUMBER := 21;
G_CURRENCY_DETAIL             CONSTANT NUMBER := 22;
G_CURRENCY_HEADER             CONSTANT NUMBER := 23;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 24;
G_FIXED_VALUE                 CONSTANT NUMBER := 25;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 26;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 27;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 28;
G_MARKUP_FORMULA              CONSTANT NUMBER := 29;
G_MARKUP_OPERATOR             CONSTANT NUMBER := 30;
G_MARKUP_VALUE                CONSTANT NUMBER := 31;
G_PRICE_FORMULA               CONSTANT NUMBER := 32;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 33;
G_PROGRAM                     CONSTANT NUMBER := 34;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 35;
G_REQUEST                     CONSTANT NUMBER := 36;
G_ROUNDING_FACTOR             CONSTANT NUMBER := 37;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 38;
G_TO_CURRENCY                 CONSTANT NUMBER := 39;
G_CURR_ATTRIBUTE_TYPE         CONSTANT NUMBER := 40;
G_CURR_ATTRIBUTE_CONTEXT      CONSTANT NUMBER := 41;
G_CURR_ATTRIBUTE              CONSTANT NUMBER := 42;
G_CURR_ATTRIBUTE_VALUE        CONSTANT NUMBER := 43;
G_PRECEDENCE                  CONSTANT NUMBER := 44;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 45;
G_SELLING_ROUNDING_FACTOR     CONSTANT NUMBER := 46;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_currency_detail_id            IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_currency_detail_id            IN  NUMBER
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_currency_detail_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_currency_header_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Currency_PUB.Curr_Details_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
) RETURN QP_Currency_PUB.Curr_Details_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_CURR_DETAILS_val_rec          IN  QP_Currency_PUB.Curr_Details_Val_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type;

END QP_Curr_Details_Util;

/

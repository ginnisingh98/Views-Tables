--------------------------------------------------------
--  DDL for Package Body OE_HEADER_SCREDIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_SCREDIT_UTIL" AS
/* $Header: OEXUHSCB.pls 120.0.12000000.2 2007/04/13 12:25:46 sgoli ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Scredit_Util';
G_ACTIVATE_ORCL_CUSTOMIZATION VARCHAR2(1):= NVL(FND_PROFILE.VALUE('ONT_ACTIVATE_ORACLE_CUSTOMIZATION'),'N');
G_ORG_ID NUMBER;
FUNCTION G_MISS_OE_AK_HSCREDIT_REC
RETURN OE_AK_HEADER_SCREDITS_V%ROWTYPE IS
l_rowtype_rec				OE_AK_HEADER_SCREDITS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_rowtype_rec.ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CONTEXT	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CREATION_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.DB_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.DW_UPDATE_ADVICE_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.HEADER_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.LAST_UPDATE_LOGIN	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.OPERATION	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PERCENT	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.RETURN_STATUS	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SALESREP_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.sales_credit_type_id	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SALES_CREDIT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.WH_UPDATE_DATE	:= FND_API.G_MISS_DATE;

    RETURN l_rowtype_rec;

END G_MISS_OE_AK_HSCREDIT_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_SCREDIT_rec            IN  OE_Order_PUB.HEADER_SCREDIT_Rec_Type
,   x_rowtype_rec                  IN OUT NOCOPY OE_AK_HEADER_SCREDITS_V%ROWTYPE
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_rowtype_rec.ATTRIBUTE1       := p_header_scredit_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE10       := p_header_scredit_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_header_scredit_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_header_scredit_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_header_scredit_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_header_scredit_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_header_scredit_rec.ATTRIBUTE15;
    x_rowtype_rec.ATTRIBUTE2       := p_header_scredit_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE3       := p_header_scredit_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_header_scredit_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_header_scredit_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_header_scredit_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_header_scredit_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_header_scredit_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_header_scredit_rec.ATTRIBUTE9;
    x_rowtype_rec.CONTEXT       := p_header_scredit_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY       := p_header_scredit_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE       := p_header_scredit_rec.CREATION_DATE;
    x_rowtype_rec.DB_FLAG       := p_header_scredit_rec.DB_FLAG;
    x_rowtype_rec.DW_UPDATE_ADVICE_FLAG       := p_header_scredit_rec.DW_UPDATE_ADVICE_FLAG;
    x_rowtype_rec.HEADER_ID       := p_header_scredit_rec.HEADER_ID;
    x_rowtype_rec.LAST_UPDATED_BY       := p_header_scredit_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE       := p_header_scredit_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN       := p_header_scredit_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.LINE_ID       := p_header_scredit_rec.LINE_ID;
    x_rowtype_rec.OPERATION       := p_header_scredit_rec.OPERATION;
    x_rowtype_rec.PERCENT       := p_header_scredit_rec.PERCENT;
    x_rowtype_rec.RETURN_STATUS       := p_header_scredit_rec.RETURN_STATUS;
    x_rowtype_rec.SALESREP_ID       := p_header_scredit_rec.SALESREP_ID;
    x_rowtype_rec.sales_credit_type_id  := p_header_scredit_rec.sales_credit_type_id;
    x_rowtype_rec.SALES_CREDIT_ID       := p_header_scredit_rec.SALES_CREDIT_ID;
    x_rowtype_rec.WH_UPDATE_DATE       := p_header_scredit_rec.WH_UPDATE_DATE;

END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
,   x_api_rec                     IN OUT NOCOPY OE_Order_PUB.HEADER_SCREDIT_Rec_Type
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_api_rec.ATTRIBUTE1       := p_record.ATTRIBUTE1;
    x_api_rec.ATTRIBUTE10       := p_record.ATTRIBUTE10;
    x_api_rec.ATTRIBUTE11       := p_record.ATTRIBUTE11;
    x_api_rec.ATTRIBUTE12       := p_record.ATTRIBUTE12;
    x_api_rec.ATTRIBUTE13       := p_record.ATTRIBUTE13;
    x_api_rec.ATTRIBUTE14       := p_record.ATTRIBUTE14;
    x_api_rec.ATTRIBUTE15       := p_record.ATTRIBUTE15;
    x_api_rec.ATTRIBUTE2       := p_record.ATTRIBUTE2;
    x_api_rec.ATTRIBUTE3       := p_record.ATTRIBUTE3;
    x_api_rec.ATTRIBUTE4       := p_record.ATTRIBUTE4;
    x_api_rec.ATTRIBUTE5       := p_record.ATTRIBUTE5;
    x_api_rec.ATTRIBUTE6       := p_record.ATTRIBUTE6;
    x_api_rec.ATTRIBUTE7       := p_record.ATTRIBUTE7;
    x_api_rec.ATTRIBUTE8       := p_record.ATTRIBUTE8;
    x_api_rec.ATTRIBUTE9       := p_record.ATTRIBUTE9;
    x_api_rec.CONTEXT       := p_record.CONTEXT;
    x_api_rec.CREATED_BY       := p_record.CREATED_BY;
    x_api_rec.CREATION_DATE       := p_record.CREATION_DATE;
    x_api_rec.DB_FLAG       := p_record.DB_FLAG;
    x_api_rec.DW_UPDATE_ADVICE_FLAG       := p_record.DW_UPDATE_ADVICE_FLAG;
    x_api_rec.HEADER_ID       := p_record.HEADER_ID;
    x_api_rec.LAST_UPDATED_BY       := p_record.LAST_UPDATED_BY;
    x_api_rec.LAST_UPDATE_DATE       := p_record.LAST_UPDATE_DATE;
    x_api_rec.LAST_UPDATE_LOGIN       := p_record.LAST_UPDATE_LOGIN;
    x_api_rec.LINE_ID       := p_record.LINE_ID;
    x_api_rec.OPERATION       := p_record.OPERATION;
    x_api_rec.PERCENT       := p_record.PERCENT;
    x_api_rec.RETURN_STATUS       := p_record.RETURN_STATUS;
    x_api_rec.SALESREP_ID       := p_record.SALESREP_ID;
    x_api_rec.sales_credit_type_id  := p_record.sales_credit_type_id;
    x_api_rec.SALES_CREDIT_ID       := p_record.SALES_CREDIT_ID;
    x_api_rec.WH_UPDATE_DATE       := p_record.WH_UPDATE_DATE;

END Rowtype_Rec_To_API_Rec;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Scredit_rec    IN OUT NOCOPY  OE_AK_HEADER_SCREDITS_V%ROWTYPE
,   p_old_Header_Scredit_rec        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE :=
								G_MISS_OE_AK_HSCREDIT_REC
)
IS
l_index			NUMBER :=0;
l_src_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load out record



    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute1,p_old_Header_Scredit_rec.attribute1)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute10,p_old_Header_Scredit_rec.attribute10)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute11,p_old_Header_Scredit_rec.attribute11)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute12,p_old_Header_Scredit_rec.attribute12)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute13,p_old_Header_Scredit_rec.attribute13)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute14,p_old_Header_Scredit_rec.attribute14)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute15,p_old_Header_Scredit_rec.attribute15)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute2,p_old_Header_Scredit_rec.attribute2)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute3,p_old_Header_Scredit_rec.attribute3)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute4,p_old_Header_Scredit_rec.attribute4)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute5,p_old_Header_Scredit_rec.attribute5)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute6,p_old_Header_Scredit_rec.attribute6)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute7,p_old_Header_Scredit_rec.attribute7)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute8,p_old_Header_Scredit_rec.attribute8)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute9,p_old_Header_Scredit_rec.attribute9)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.context,p_old_Header_Scredit_rec.context)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.created_by,p_old_Header_Scredit_rec.created_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.creation_date,p_old_Header_Scredit_rec.creation_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.dw_update_advice_flag,p_old_Header_Scredit_rec.dw_update_advice_flag)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_DW_UPDATE_ADVICE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.header_id,p_old_Header_Scredit_rec.header_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_updated_by,p_old_Header_Scredit_rec.last_updated_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_update_date,p_old_Header_Scredit_rec.last_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_update_login,p_old_Header_Scredit_rec.last_update_login)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.line_id,p_old_Header_Scredit_rec.line_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.percent,p_old_Header_Scredit_rec.percent)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_PERCENT;
        END IF;


        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.salesrep_id,p_old_Header_Scredit_rec.salesrep_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_SALESREP;
        END IF;
        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.sales_credit_type_id,p_old_Header_Scredit_rec.sales_credit_type_id)
        THEN
           l_index := l_index + 1;
         l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_sales_credit_type;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.sales_credit_id,p_old_Header_Scredit_rec.sales_credit_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_SALES_CREDIT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.wh_update_date,p_old_Header_Scredit_rec.wh_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_WH_UPDATE_DATE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_DW_UPDATE_ADVICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_DW_UPDATE_ADVICE;
    ELSIF p_attr_id = G_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_HEADER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_LINE;
    ELSIF p_attr_id = G_PERCENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_PERCENT;
    ELSIF p_attr_id = G_SALESREP THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_SALESREP;
    ELSIF p_attr_id = G_sales_credit_type THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_sales_credit_type;
    ELSIF p_attr_id = G_SALES_CREDIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_SALES_CREDIT;
    ELSIF p_attr_id = G_WH_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_HEADER_SCREDIT_UTIL.G_WH_UPDATE_DATE;
    END IF;

    If l_src_attr_tbl.COUNT <> 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
        p_source_attr_tbl => l_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
            IF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE1 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE1 := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE10 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE11 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE12 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE13 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE14 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE15 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE15 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE2 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE3 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE4 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE5 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE6 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE7 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE8 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_ATTRIBUTE9 THEN
                p_x_Header_Scredit_rec.ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_CONTEXT THEN
                p_x_Header_Scredit_rec.CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_CREATED_BY THEN
                p_x_Header_Scredit_rec.CREATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_CREATION_DATE THEN
                p_x_Header_Scredit_rec.CREATION_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_DW_UPDATE_ADVICE THEN
                p_x_Header_Scredit_rec.DW_UPDATE_ADVICE_FLAG := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_HEADER THEN
                p_x_Header_Scredit_rec.HEADER_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATED_BY THEN
                p_x_Header_Scredit_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_DATE THEN
                p_x_Header_Scredit_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN THEN
                p_x_Header_Scredit_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_LINE THEN
                p_x_Header_Scredit_rec.LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_PERCENT THEN
                p_x_Header_Scredit_rec.PERCENT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_SALESREP THEN
                p_x_Header_Scredit_rec.SALESREP_ID := FND_API.G_MISS_NUM;
          ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_sales_credit_type THEN
                p_x_Header_Scredit_rec.sales_credit_type_id := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_SALES_CREDIT THEN
                p_x_Header_Scredit_rec.SALES_CREDIT_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_SCREDIT_UTIL.G_WH_UPDATE_DATE THEN
                p_x_Header_Scredit_rec.WH_UPDATE_DATE := FND_API.G_MISS_DATE;
    	    END IF;
        END LOOP;
    END IF;
END Clear_Dependent_Attr;

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Scredit_rec   IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
)
IS
l_Header_Scredit_rec		OE_AK_HEADER_SCREDITS_V%ROWTYPE;
l_old_Header_Scredit_rec		OE_AK_HEADER_SCREDITS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	API_Rec_To_Rowtype_Rec(p_x_Header_Scredit_rec, l_Header_Scredit_rec);
	API_Rec_To_Rowtype_Rec(p_old_Header_Scredit_rec, l_old_Header_Scredit_rec);

	Clear_Dependent_Attr
		(p_attr_id			=> p_attr_id
		,p_x_Header_Scredit_rec 	=> l_Header_Scredit_rec
		,p_old_Header_Scredit_rec	=> l_old_Header_Scredit_rec
		);

	Rowtype_Rec_To_API_Rec(l_Header_Scredit_rec,p_x_Header_Scredit_rec);

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Header_Scredit_rec            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
)
IS
l_return_status                   Varchar2(10);
--SG{
l_sg_date DATE;
l_out Varchar2(240);
l_status Varchar2(30);
--SG}
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load out record


    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute1,p_old_Header_Scredit_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute10,p_old_Header_Scredit_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute11,p_old_Header_Scredit_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute12,p_old_Header_Scredit_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute13,p_old_Header_Scredit_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute14,p_old_Header_Scredit_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute15,p_old_Header_Scredit_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute2,p_old_Header_Scredit_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute3,p_old_Header_Scredit_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute4,p_old_Header_Scredit_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute5,p_old_Header_Scredit_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute6,p_old_Header_Scredit_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute7,p_old_Header_Scredit_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute8,p_old_Header_Scredit_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.attribute9,p_old_Header_Scredit_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.context,p_old_Header_Scredit_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.created_by,p_old_Header_Scredit_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.creation_date,p_old_Header_Scredit_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.dw_update_advice_flag,p_old_Header_Scredit_rec.dw_update_advice_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.header_id,p_old_Header_Scredit_rec.header_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_updated_by,p_old_Header_Scredit_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_update_date,p_old_Header_Scredit_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.last_update_login,p_old_Header_Scredit_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.line_id,p_old_Header_Scredit_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.percent,p_old_Header_Scredit_rec.percent)
    THEN
         -- Add delayed request to validate quota percent sums up to 100
           OE_Delayed_Requests_Pvt.Log_Request
                 (p_entity_code=>OE_GLOBALS.G_ENTITY_Header_Scredit
                 ,p_entity_id=>p_x_Header_Scredit_rec.sales_credit_id
                 , p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Header_Scredit
                 ,p_requesting_entity_id=>p_x_Header_Scredit_rec.sales_credit_id
                 ,p_request_type=>OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL
                 ,p_param1  => to_char(p_x_Header_Scredit_rec.header_id)
                 ,x_return_status =>l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.sales_credit_type_id,p_old_Header_Scredit_rec.sales_credit_type_id)
    THEN
         -- Add delayed request to validate quota percent sums up to 100
           OE_Delayed_Requests_Pvt.Log_Request
                 (p_entity_code=>OE_GLOBALS.G_ENTITY_Header_Scredit
                 ,p_entity_id=>p_x_Header_Scredit_rec.sales_credit_id
                 , p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Header_Scredit
                 ,p_requesting_entity_id=>p_x_Header_Scredit_rec.sales_credit_id
                 ,p_request_type=>OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL
                 ,p_param1  => to_char(p_x_Header_Scredit_rec.header_id)
                 ,x_return_status =>l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.salesrep_id,p_old_Header_Scredit_rec.salesrep_id)
    THEN
        NULL;
         --SG{


          IF OE_ORDER_CACHE.G_HEADER_REC.header_id IS NULL THEN
             --header not available in cache, load info to cache
            IF p_x_Header_Scredit_rec.Header_Id IS NOT NULL THEN
             OE_ORDER_CACHE.Load_Order_Header(p_x_Header_Scredit_rec.Header_Id);
            ELSE
             oe_debug_pub.add(' Warning:Null header_id for header sales credits');
            END IF;
          END IF;

          IF OE_ORDER_CACHE.G_HEADER_REC.booked_flag = 'Y' THEN
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.booked_date;
          ELSE
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.ordered_date;
          END IF;

          --5620190: Added the IF condition, so that Get_Sales_Group id is called only if
          --the record doesn't have a sales group id, which could have been populated
          --when copying order.
          oe_debug_pub.add('Before get_sales_group:'||p_x_Header_Scredit_rec.sales_group_id);
          IF p_x_Header_Scredit_rec.sales_group_id IS NULL THEN
             Get_Sales_Group(p_date => l_sg_date,
                             p_sales_rep_id  =>p_x_Header_Scredit_rec.salesrep_id,
                             x_sales_group_id=>p_x_Header_Scredit_rec.sales_group_id,
                             --x_sales_group   =>l_out,
                             x_return_status =>l_status);
          END IF;
        --SG}
    END IF;

   --SG{
     IF nvl(p_x_Header_Scredit_rec.sales_group_updated_flag,'N') <> 'Y'
        AND nvl(p_x_Header_Scredit_rec.salesrep_id,FND_API.G_MISS_NUM)<>FND_API.G_MISS_NUM
     THEN

          IF OE_ORDER_CACHE.G_HEADER_REC.header_id IS NULL THEN
             --header not available in cache, load info to cache
            IF p_x_Header_Scredit_rec.Header_Id IS NOT NULL THEN
             OE_ORDER_CACHE.Load_Order_Header(p_x_Header_Scredit_rec.Header_Id);
            ELSE
             oe_debug_pub.add(' Warning:Null header_id for header sales credits');
            END IF;
          END IF;

          IF OE_ORDER_CACHE.G_HEADER_REC.booked_flag = 'Y' THEN
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.booked_date;
          ELSE
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.ordered_date;
          END IF;
          oe_debug_pub.add('Before getting sales group');
          Get_Sales_Group(p_date => l_sg_date,
                          p_sales_rep_id  =>p_x_Header_Scredit_rec.salesrep_id,
                          x_sales_group_id=>p_x_Header_Scredit_rec.sales_group_id,
                          --x_sales_group   =>l_out,
                          x_return_status =>l_status);
     END IF;
   --SG}


    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.sales_credit_type_id,p_old_Header_Scredit_rec.sales_credit_type_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.sales_credit_id,p_old_Header_Scredit_rec.sales_credit_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Scredit_rec.wh_update_date,p_old_Header_Scredit_rec.wh_update_date)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Header_Scredit_rec     IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_x_Header_Scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute1 := p_old_Header_Scredit_rec.attribute1;
    END IF;

    IF p_x_Header_Scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute10 := p_old_Header_Scredit_rec.attribute10;
    END IF;

    IF p_x_Header_Scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute11 := p_old_Header_Scredit_rec.attribute11;
    END IF;

    IF p_x_Header_Scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute12 := p_old_Header_Scredit_rec.attribute12;
    END IF;

    IF p_x_Header_Scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute13 := p_old_Header_Scredit_rec.attribute13;
    END IF;

    IF p_x_Header_Scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute14 := p_old_Header_Scredit_rec.attribute14;
    END IF;

    IF p_x_Header_Scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute15 := p_old_Header_Scredit_rec.attribute15;
    END IF;

    IF p_x_Header_Scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute2 := p_old_Header_Scredit_rec.attribute2;
    END IF;

    IF p_x_Header_Scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute3 := p_old_Header_Scredit_rec.attribute3;
    END IF;

    IF p_x_Header_Scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute4 := p_old_Header_Scredit_rec.attribute4;
    END IF;

    IF p_x_Header_Scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute5 := p_old_Header_Scredit_rec.attribute5;
    END IF;

    IF p_x_Header_Scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute6 := p_old_Header_Scredit_rec.attribute6;
    END IF;

    IF p_x_Header_Scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute7 := p_old_Header_Scredit_rec.attribute7;
    END IF;

    IF p_x_Header_Scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute8 := p_old_Header_Scredit_rec.attribute8;
    END IF;

    IF p_x_Header_Scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute9 := p_old_Header_Scredit_rec.attribute9;
    END IF;

    IF p_x_Header_Scredit_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.context := p_old_Header_Scredit_rec.context;
    END IF;

    IF p_x_Header_Scredit_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.created_by := p_old_Header_Scredit_rec.created_by;
    END IF;

    IF p_x_Header_Scredit_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.creation_date := p_old_Header_Scredit_rec.creation_date;
    END IF;

    IF p_x_Header_Scredit_rec.dw_update_advice_flag = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.dw_update_advice_flag := p_old_Header_Scredit_rec.dw_update_advice_flag;
    END IF;

    IF p_x_Header_Scredit_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.header_id := p_old_Header_Scredit_rec.header_id;
    END IF;

    IF p_x_Header_Scredit_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.last_updated_by := p_old_Header_Scredit_rec.last_updated_by;
    END IF;

    IF p_x_Header_Scredit_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.last_update_date := p_old_Header_Scredit_rec.last_update_date;
    END IF;

    IF p_x_Header_Scredit_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.last_update_login := p_old_Header_Scredit_rec.last_update_login;
    END IF;

    IF p_x_Header_Scredit_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.line_id := p_old_Header_Scredit_rec.line_id;
    END IF;

    IF p_x_Header_Scredit_rec.percent = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.percent := p_old_Header_Scredit_rec.percent;
    END IF;


    IF p_x_Header_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.salesrep_id := p_old_Header_Scredit_rec.salesrep_id;
    END IF;
    IF p_x_Header_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.sales_credit_type_id := p_old_Header_Scredit_rec.sales_credit_type_id;
    END IF;

    IF p_x_Header_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.sales_credit_id := p_old_Header_Scredit_rec.sales_credit_id;
    END IF;

    IF p_x_Header_Scredit_rec.wh_update_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.wh_update_date := p_old_Header_Scredit_rec.wh_update_date;
    END IF;



END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Scredit_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_x_Header_Scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute1 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute10 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute11 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute12 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute13 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute14 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute15 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute2 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute3 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute4 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute5 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute6 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute7 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute8 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.attribute9 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.context := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.created_by := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.creation_date := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.dw_update_advice_flag = FND_API.G_MISS_CHAR THEN
        p_x_Header_Scredit_rec.dw_update_advice_flag := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.header_id := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.last_updated_by := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.last_update_date := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.last_update_login := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.line_id := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.percent = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.percent := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.salesrep_id := NULL;
    END IF;
    IF p_x_Header_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.sales_credit_type_id := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
        p_x_Header_Scredit_rec.sales_credit_id := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.wh_update_date = FND_API.G_MISS_DATE THEN
        p_x_Header_Scredit_rec.wh_update_date := NULL;
    END IF;



END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Header_Scredit_rec            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
    l_lock_control   NUMBER;
 --added for notification framework
      l_index    NUMBER;
      l_return_status VARCHAR2(1);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_SALES_CREDITS
    WHERE  sales_credit_id = p_Header_Scredit_rec.sales_credit_id;

    l_lock_control := l_lock_control + 1;

   --calling notification framework to update global picture
   --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JFC: SALES_CREDIT_ID' || P_HEADER_SCREDIT_REC.SALES_CREDIT_ID ) ;
       END IF;
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_scr_rec =>p_header_scredit_rec,
                    p_hdr_scr_id => p_header_scredit_rec.sales_credit_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_SCREDIT_UTIL.UPDATE_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_SCREDIT_UTIL.UPDATE_ROW' ) ;
          END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
         END IF;
	 RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF; /*code_release_level*/
    -- notification framework end

    UPDATE  OE_SALES_CREDITS
    SET     ATTRIBUTE1                     = p_Header_Scredit_rec.attribute1
    ,       ATTRIBUTE10                    = p_Header_Scredit_rec.attribute10
    ,       ATTRIBUTE11                    = p_Header_Scredit_rec.attribute11
    ,       ATTRIBUTE12                    = p_Header_Scredit_rec.attribute12
    ,       ATTRIBUTE13                    = p_Header_Scredit_rec.attribute13
    ,       ATTRIBUTE14                    = p_Header_Scredit_rec.attribute14
    ,       ATTRIBUTE15                    = p_Header_Scredit_rec.attribute15
    ,       ATTRIBUTE2                     = p_Header_Scredit_rec.attribute2
    ,       ATTRIBUTE3                     = p_Header_Scredit_rec.attribute3
    ,       ATTRIBUTE4                     = p_Header_Scredit_rec.attribute4
    ,       ATTRIBUTE5                     = p_Header_Scredit_rec.attribute5
    ,       ATTRIBUTE6                     = p_Header_Scredit_rec.attribute6
    ,       ATTRIBUTE7                     = p_Header_Scredit_rec.attribute7
    ,       ATTRIBUTE8                     = p_Header_Scredit_rec.attribute8
    ,       ATTRIBUTE9                     = p_Header_Scredit_rec.attribute9
    ,       CONTEXT                        = p_Header_Scredit_rec.context
    ,       CREATED_BY                     = p_Header_Scredit_rec.created_by
    ,       CREATION_DATE                  = p_Header_Scredit_rec.creation_date
    ,       DW_UPDATE_ADVICE_FLAG          = p_Header_Scredit_rec.dw_update_advice_flag
    ,       HEADER_ID                      = p_Header_Scredit_rec.header_id
    ,       LAST_UPDATED_BY                = p_Header_Scredit_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Header_Scredit_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Header_Scredit_rec.last_update_login
    ,       LINE_ID                        = p_Header_Scredit_rec.line_id
    ,       PERCENT                        = p_Header_Scredit_rec.percent
    ,       SALESREP_ID                    = p_Header_Scredit_rec.salesrep_id
    ,       sales_credit_type_id           = p_Header_Scredit_rec.sales_credit_type_id
    ,       SALES_CREDIT_ID                = p_Header_Scredit_rec.sales_credit_id
    ,       WH_UPDATE_DATE                 = p_Header_Scredit_rec.wh_update_date
    ,       LOCK_CONTROL                   = l_lock_control
--SG{
    ,       sales_group_id                 =  p_Header_Scredit_rec.sales_group_id
    ,       sales_group_updated_flag            =  p_Header_Scredit_rec.sales_group_updated_flag
--SG}
    WHERE   SALES_CREDIT_ID = p_Header_Scredit_rec.sales_credit_id
    ;

    p_Header_Scredit_rec.lock_control :=   l_lock_control;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Header_Scredit_rec       IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
    l_lock_control   NUMBER:= 1;
    l_index          NUMBER;
    l_return_status VARCHAR2(1);
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_HEADER_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
   END IF;

    INSERT  INTO OE_SALES_CREDITS
    (       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    ,       ORIG_SYS_CREDIT_REF
--SG{
    ,       sales_group_id
    ,       sales_group_updated_flag
--SG}
    ,       LOCK_CONTROL
    )
    VALUES
    (       p_Header_Scredit_rec.attribute1
    ,       p_Header_Scredit_rec.attribute10
    ,       p_Header_Scredit_rec.attribute11
    ,       p_Header_Scredit_rec.attribute12
    ,       p_Header_Scredit_rec.attribute13
    ,       p_Header_Scredit_rec.attribute14
    ,       p_Header_Scredit_rec.attribute15
    ,       p_Header_Scredit_rec.attribute2
    ,       p_Header_Scredit_rec.attribute3
    ,       p_Header_Scredit_rec.attribute4
    ,       p_Header_Scredit_rec.attribute5
    ,       p_Header_Scredit_rec.attribute6
    ,       p_Header_Scredit_rec.attribute7
    ,       p_Header_Scredit_rec.attribute8
    ,       p_Header_Scredit_rec.attribute9
    ,       p_Header_Scredit_rec.context
    ,       p_Header_Scredit_rec.created_by
    ,       p_Header_Scredit_rec.creation_date
    ,       p_Header_Scredit_rec.dw_update_advice_flag
    ,       p_Header_Scredit_rec.header_id
    ,       p_Header_Scredit_rec.last_updated_by
    ,       p_Header_Scredit_rec.last_update_date
    ,       p_Header_Scredit_rec.last_update_login
    ,       p_Header_Scredit_rec.line_id
    ,       p_Header_Scredit_rec.percent
    ,       p_Header_Scredit_rec.salesrep_id
    ,       p_Header_Scredit_rec.sales_credit_type_id
    ,       p_Header_Scredit_rec.sales_credit_id
    ,       p_Header_Scredit_rec.wh_update_date
    ,       p_Header_Scredit_rec.orig_sys_credit_ref
--SG{
    ,       p_header_scredit_rec.sales_group_id
    ,       p_header_scredit_rec.sales_group_updated_flag
--SG}
    ,       l_lock_control
    );

    p_Header_Scredit_rec.lock_control :=   l_lock_control;

    --calling notification framework to update global picture
  --check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_hdr_scr_rec => NULL,
                    p_Hdr_scr_rec =>p_header_scredit_rec,
                    p_hdr_scr_id => p_header_scredit_rec.sales_credit_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_SCREDIT_UTIL.INSERT_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURNED INDEX IS: ' || L_INDEX , 1 ) ;
       END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_SCREDIT_UTIL.INSERT_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; /*code_release_level*/
 -- notification framework end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);
CURSOR sales_credit IS
	SELECT sales_credit_id
	FROM OE_SALES_CREDITS
	WHERE   HEADER_ID = p_header_id;
 -- added for notification framework
        l_new_header_scredit_rec     OE_Order_PUB.Header_Scredit_Rec_Type;
        l_index           NUMBER;
        --
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
        --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_HEADER_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
  END IF;

  IF p_header_id <> FND_API.G_MISS_NUM
  THEN
    FOR l_scr IN sales_credit LOOP

    --added notification framework
   --check code release level first. Notification framework is at Pack H level
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      /* Set the operation on the record so that globals are updated as well */
        l_new_header_scredit_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        l_new_header_scredit_rec.sales_credit_id := l_scr.sales_credit_id;

        OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_scr_rec =>l_new_header_scredit_rec,
                    p_hdr_scr_id => l_scr.sales_credit_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_SCREDIT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
           END IF;
 	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_SCREDIT_UTIL.DELETE_ROW' ) ;
           END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
            END IF;
	    RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF; /*code_release_level*/
     -- notification framework end

      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
        p_entity_id     => l_scr.sales_credit_id,
        x_return_status => l_return_status
        );
    END LOOP;

    /* Start Audit Trail */
    DELETE  FROM OE_SALES_CREDIT_HISTORY
    WHERE   HEADER_ID = p_header_id;
    /* End Audit Trail */

    DELETE  FROM OE_SALES_CREDITS
    WHERE   HEADER_ID = p_header_id;
  ELSE
     --added notification framework
   --check code release level first. Notification framework is at Pack H level
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      /* Set the operation on the record so that globals are updated as well */
        l_new_header_scredit_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        l_new_header_scredit_rec.sales_credit_id := p_sales_credit_id;
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_scr_rec =>l_new_header_scredit_rec,
                    p_hdr_scr_id => p_sales_credit_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_SCREDIT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
    	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_SCREDIT_UTIL.DELETE_ROW' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; /*code_release_level*/
    -- notification framework end

     OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
        p_entity_id     => p_sales_credit_id,
        x_return_status => l_return_status
        );

    /* Start Audit Trail (modified for 11.5.10) */
    DELETE  FROM OE_SALES_CREDIT_HISTORY
    WHERE   SALES_CREDIT_ID = p_sales_credit_id
    AND     NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND     NVL(VERSION_FLAG, 'N') = 'N'
    AND     NVL(PHASE_CHANGE_FLAG, 'N') = 'N';

    UPDATE OE_SALES_CREDIT_HISTORY
    SET    AUDIT_FLAG = 'N'
    WHERE  SALES_CREDIT_ID = p_sales_credit_id
    AND    NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND   (NVL(VERSION_FLAG, 'N') = 'Y'
    OR     NVL(PHASE_CHANGE_FLAG, 'N') = 'Y');
    /* End Audit Trail */

    DELETE  FROM OE_SALES_CREDITS
    WHERE   SALES_CREDIT_ID = p_sales_credit_id
    ;
  END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Procedure Query_Row
PROCEDURE Query_Row
(   p_sales_credit_id               IN  NUMBER,
   x_Header_Scredit_rec  IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
x_Header_Scredit_tbl OE_Order_PUB.Header_Scredit_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     Query_Rows
        (   p_sales_credit_id             => p_sales_credit_id,
	   x_Header_Scredit_tbl  => x_Header_Scredit_tbl
        );
        x_Header_Scredit_rec := x_Header_Scredit_tbl(1);

END Query_Row;



--  Procedure Query_Rows

--

Procedure Query_Rows
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,  x_header_scredit_tbl   IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
)
IS
l_count			NUMBER;

CURSOR l_Header_Scredit_csr_s IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    --SG {
    ,       SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    --SG }
    ,       LOCK_CONTROL
    FROM    OE_SALES_CREDITS
    WHERE   SALES_CREDIT_ID = p_sales_credit_id;

CURSOR l_Header_Scredit_csr_h IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    --SG {
    ,       SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    --SG }
    ,       LOCK_CONTROL
    FROM    OE_SALES_CREDITS
    WHERE   HEADER_ID = p_header_id
    	    AND LINE_ID IS NULL;

  l_implicit_rec l_header_scredit_csr_s%ROWTYPE;
  l_entity NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF
    (p_sales_credit_id IS NOT NULL
     AND
     p_sales_credit_id <> FND_API.G_MISS_NUM)
    AND
    (p_header_id IS NOT NULL
     AND
     p_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: sales_credit_id = '|| p_sales_credit_id || ', header_id = '|| p_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF nvl(p_sales_credit_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 1;
           OPEN l_header_scredit_csr_s;
    ELSIF nvl(p_header_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 2;
           OPEN l_header_scredit_csr_h;
    END IF;

    --  Loop over fetched records
    l_count := 1;
    LOOP
        IF l_entity = 1 THEN
             FETCH l_header_scredit_csr_s INTO l_implicit_rec;
             EXIT WHEN l_header_scredit_csr_s%NOTFOUND;
        ELSIF l_entity = 2 THEN
             FETCH l_header_scredit_csr_h INTO l_implicit_rec;
             EXIT WHEN l_header_scredit_csr_h%NOTFOUND;
        ELSE
          EXIT;
        END IF;

        x_header_scredit_tbl(l_count).attribute1 := l_implicit_rec.ATTRIBUTE1;
        x_header_scredit_tbl(l_count).attribute10 := l_implicit_rec.ATTRIBUTE10;
        x_header_scredit_tbl(l_count).attribute11 := l_implicit_rec.ATTRIBUTE11;
        x_header_scredit_tbl(l_count).attribute12 := l_implicit_rec.ATTRIBUTE12;
        x_header_scredit_tbl(l_count).attribute13 := l_implicit_rec.ATTRIBUTE13;
        x_header_scredit_tbl(l_count).attribute14 := l_implicit_rec.ATTRIBUTE14;
        x_header_scredit_tbl(l_count).attribute15 := l_implicit_rec.ATTRIBUTE15;
        x_header_scredit_tbl(l_count).attribute2 := l_implicit_rec.ATTRIBUTE2;
        x_header_scredit_tbl(l_count).attribute3 := l_implicit_rec.ATTRIBUTE3;
        x_header_scredit_tbl(l_count).attribute4 := l_implicit_rec.ATTRIBUTE4;
        x_header_scredit_tbl(l_count).attribute5 := l_implicit_rec.ATTRIBUTE5;
        x_header_scredit_tbl(l_count).attribute6 := l_implicit_rec.ATTRIBUTE6;
        x_header_scredit_tbl(l_count).attribute7 := l_implicit_rec.ATTRIBUTE7;
        x_header_scredit_tbl(l_count).attribute8 := l_implicit_rec.ATTRIBUTE8;
        x_header_scredit_tbl(l_count).attribute9 := l_implicit_rec.ATTRIBUTE9;
        x_header_scredit_tbl(l_count).context   := l_implicit_rec.CONTEXT;
        x_header_scredit_tbl(l_count).created_by := l_implicit_rec.CREATED_BY;
        x_header_scredit_tbl(l_count).creation_date := l_implicit_rec.CREATION_DATE;
        x_header_scredit_tbl(l_count).dw_update_advice_flag := l_implicit_rec.DW_UPDATE_ADVICE_FLAG;
        x_header_scredit_tbl(l_count).header_id := l_implicit_rec.HEADER_ID;
        x_header_scredit_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_header_scredit_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_header_scredit_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_header_scredit_tbl(l_count).line_id   := l_implicit_rec.LINE_ID;
        x_header_scredit_tbl(l_count).percent   := l_implicit_rec.PERCENT;
        x_header_scredit_tbl(l_count).salesrep_id := l_implicit_rec.SALESREP_ID;
        x_header_scredit_tbl(l_count).sales_credit_type_id := l_implicit_rec.sales_credit_type_id;
        x_header_scredit_tbl(l_count).sales_credit_id := l_implicit_rec.SALES_CREDIT_ID;
        x_header_scredit_tbl(l_count).wh_update_date := l_implicit_rec.WH_UPDATE_DATE;
        --SG{
        x_header_scredit_tbl(l_count).sales_group_id := l_implicit_rec.sales_group_id;
        x_header_scredit_tbl(l_count).sales_group_updated_flag:=l_implicit_rec.sales_group_updated_flag;
        --SG}
        x_header_scredit_tbl(l_count).lock_control   := l_implicit_rec.LOCK_CONTROL;

        l_count := l_count + 1;
    END LOOP;

    IF l_entity = 1 THEN
        CLOSE l_header_scredit_csr_s;
    ELSIF l_entity = 2 THEN
        CLOSE l_header_scredit_csr_h;
    END IF;

    --  PK sent and no rows found

    IF
    (p_sales_credit_id IS NOT NULL
     AND
     p_sales_credit_id <> FND_API.G_MISS_NUM)
    AND
    (x_Header_Scredit_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_x_Header_Scredit_rec IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_sales_credit_id               IN  NUMBER
                                        := FND_API.G_MISS_NUM
)
IS
l_sales_credit_id	      NUMBER;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_lock_control                NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_SCREDIT_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF p_sales_credit_id <> FND_API.G_MISS_NUM THEN
        l_sales_credit_id := p_sales_credit_id;
    ELSE
        l_sales_credit_id := p_x_header_scredit_rec.sales_credit_id;
        l_lock_control    := p_x_header_scredit_rec.lock_control;
    END IF;

   SELECT  sales_credit_id
    INTO   l_sales_credit_id
    FROM   oe_sales_credits
    WHERE  sales_credit_id = l_sales_credit_id
    FOR UPDATE NOWAIT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SELECTED FOR UPDATE' , 1 ) ;
    END IF;

    OE_Header_Scredit_Util.Query_Row
	(p_sales_credit_id    => l_sales_credit_id
	,x_header_scredit_rec => p_x_header_scredit_rec );


    -- If lock_control is null / missing, then return the locked record.

    IF l_lock_control is null OR
       l_lock_control <> FND_API.G_MISS_NUM THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_header_scredit_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

        RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare IN attributes to DB attributes.

    IF  OE_GLOBALS.Equal(p_x_Header_Scredit_rec.lock_control,
                         l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        p_x_Header_Scredit_rec           := l_Header_Scredit_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
	    ROLLBACK TO Lock_Row;

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

PROCEDURE Lock_Rows
(   p_sales_credit_id        IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_header_scredit_tbl     OUT NOCOPY OE_Order_PUB.header_scredit_Tbl_Type
,   x_return_status          OUT NOCOPY VARCHAR2
 )
IS
  CURSOR lock_hdr_scredits(p_header_id  NUMBER) IS
  SELECT sales_credit_id
  FROM   oe_sales_credits
  WHERE  header_id = p_header_id
    FOR UPDATE NOWAIT;

  l_sales_credit_id    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_SCREDITS_UTIL.LOCK_ROWS' , 1 ) ;
    END IF;

    IF (p_sales_credit_id IS NOT NULL AND
        p_sales_credit_id <> FND_API.G_MISS_NUM) AND
       (p_header_id IS NOT NULL AND
        p_header_id <> FND_API.G_MISS_NUM)
    THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
          , 'Lock Rows'
          , 'Keys are mutually exclusive: sales_credit_id = '||
             p_sales_credit_id || ', header_id = '|| p_header_id );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

   IF p_sales_credit_id <> FND_API.G_MISS_NUM THEN

     SELECT sales_credit_id
     INTO   l_sales_credit_id
     FROM   OE_SALES_CREDITS
     WHERE  sales_credit_id   = p_sales_credit_id
     FOR UPDATE NOWAIT;

   END IF;

   -- people should not pass in null header_id unnecessarily,
   -- if they already passed in line_id.

   BEGIN

     IF p_header_id <> FND_API.G_MISS_NUM THEN

       SAVEPOINT LOCK_ROWS;
       OPEN lock_hdr_scredits(p_header_id);

       LOOP
         FETCH lock_hdr_scredits INTO l_sales_credit_id;
         EXIT WHEN lock_hdr_scredits%NOTFOUND;
       END LOOP;

       CLOSE lock_hdr_scredits;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO LOCK_ROWS;

       IF lock_hdr_scredits%ISOPEN THEN
         CLOSE lock_hdr_scredits;
       END IF;

       RAISE;
   END;

   -- locked all

   OE_Header_Scredit_Util.Query_Rows
     (p_sales_credit_id          => p_sales_credit_id
     ,p_header_id                => p_header_id
     ,x_header_scredit_tbl       => x_header_scredit_tbl
     );

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_HEADER_SCREDITS_UTIL.LOCK_ROWS' , 1 ) ;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

     x_return_status                := FND_API.G_RET_STS_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
       fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
       OE_MSG_PUB.Add;
     END IF;

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
        OE_MSG_PUB.Add;
      END IF;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
         ,   'Lock_Rows'
        );
      END IF;

END Lock_Rows;


--  Function Get_Values

FUNCTION Get_Values
(   p_Header_Scredit_rec          IN        OE_Order_PUB.Header_Scredit_Rec_Type
,   p_old_Header_Scredit_rec        IN  OE_Order_PUB.Header_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
)RETURN OE_Order_PUB.Header_Scredit_Val_Rec_Type
IS
l_Header_Scredit_val_rec      OE_Order_PUB.Header_Scredit_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--sg{
l_sg_name Varchar2(60);
--sg}
BEGIN

    IF (p_Header_Scredit_rec.salesrep_id IS NULL OR
        p_Header_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Header_Scredit_rec.salesrep_id,
        p_old_Header_Scredit_rec.salesrep_id)
    THEN
        l_Header_Scredit_val_rec.salesrep := OE_Id_To_Value.Salesrep
        (   p_salesrep_id                 => p_Header_Scredit_rec.salesrep_id
        );
    END IF;

    IF (p_Header_Scredit_rec.sales_credit_type_id IS NULL OR
        p_Header_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Header_Scredit_rec.sales_credit_type_id,
        p_old_Header_Scredit_rec.sales_credit_type_id)
    THEN
        l_Header_Scredit_val_rec.sales_credit_type := OE_Id_To_Value.sales_credit_type
        (   p_sales_credit_type_id => p_Header_Scredit_rec.sales_credit_type_id
        );
    END IF;

    --SG{
    If p_Header_Scredit_rec.sales_group_id IS NOT NULL Then
    Begin
     /*Select group_name into l_sg_name
     From   jtf_rs_groups_vl
     Where  Group_Id=p_Header_Scredit_rec.sales_group_id;
     l_Header_Scredit_val_rec.sales_group:=l_sg_name;*/

     l_Header_Scredit_val_rec.sales_group:=OE_Id_To_Value.get_sales_group_name(p_Header_Scredit_rec.sales_group_id);
    Exception
     When no_data_found Then
      l_Header_Scredit_val_rec.sales_group:='Group name not available';
     When others then
      Oe_Debug_Pub.add('OEXUHSCB.pls--get_values:'||SQLERRM);
    End;
    End If;
    --SG}

    RETURN l_Header_Scredit_val_rec;

END Get_Values;

--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_Header_Scredit_rec IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_Header_Scredit_val_rec        IN  OE_Order_PUB.Header_Scredit_Val_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  initialize  return_status.

    p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Header_Scredit_rec.



    IF  p_Header_Scredit_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Header_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM THEN



            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Header_Scredit_rec.salesrep_id := OE_Value_To_Id.salesrep
            (   p_salesrep                    => p_Header_Scredit_val_rec.salesrep
            );

            IF p_x_Header_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
               p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Header_Scredit_val_rec.sales_credit_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Header_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM THEN


            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Header_Scredit_rec.sales_credit_type_id := OE_Value_To_Id.sales_credit_type
            (   p_sales_credit_type => p_Header_Scredit_val_rec.sales_credit_type
            );

            IF p_x_Header_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
                p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;




END Get_Ids;

/* Start AuditTrail */
PROCEDURE Pre_Write_Process
  ( p_x_header_scredit_rec IN OUT NOCOPY OE_ORDER_PUB.header_scredit_rec_type,
    p_old_header_scredit_rec IN OE_ORDER_PUB.header_scredit_rec_type := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_REC )
    IS
l_return_status varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

       --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND
         OE_GLOBALS.G_ROLL_VERSION <> 'N' THEN
       IF OE_GLOBALS.G_REASON_CODE IS NULL AND
           OE_GLOBALS.G_CAPTURED_REASON IN ('V','A') THEN
          IF p_x_header_scredit_rec.change_reason <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_CODE := p_x_header_scredit_rec.change_reason;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_header_scredit_rec.change_comments;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
          ELSE
                 IF l_debug_level  > 0 THEN
                    OE_DEBUG_PUB.add('Reason code missing for versioning', 1);
                 END IF;
                 IF OE_GLOBALS.G_UI_FLAG THEN
                    raise FND_API.G_EXC_ERROR;
                 END IF;
          END IF;
       END IF;

       --log delayed request
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('log versioning request',1);
       END IF;
          OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_scredit_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
                                   p_requesting_entity_id => p_x_header_scredit_rec.sales_credit_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
     END IF;

IF (p_x_header_scredit_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) THEN

    IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AUDIT TRAIL , CHANGE ATTRIBUTE REQUIRES REASON' , 1 ) ;
       END IF;
       IF (p_x_header_scredit_rec.change_reason IS NULL OR
           p_x_header_scredit_rec.change_reason = FND_API.G_MISS_CHAR  OR
           NOT OE_Validate.Change_Reason_Code(p_x_header_scredit_rec.change_reason)) THEN
             -- bug 3636884, defaulting reason from group API
            IF OE_GLOBALS.G_DEFAULT_REASON THEN
              if l_debug_level > 0 then
                oe_debug_pub.add('Defaulting Audit Reason for Order Sales Credit', 1);
              end if;
              p_x_header_scredit_rec.change_reason := 'SYSTEM';
            ELSE
              IF l_debug_level  > 0 THEN
                 OE_DEBUG_PUB.add('Reason code for change is missing or invalid', 1);
              END IF;
              fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
	      fnd_message.set_token('OBJECT','ORDER SALES CREDIT');
              oe_msg_pub.add;
              raise FND_API.G_EXC_ERROR;
            END IF;
       END IF;
    END IF;
    IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' OR
	  OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXUHSCB:Calling oe_order_chg_pvt.recordhscredithist') ;
       END IF;
     --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
                                           p_entity_id => p_x_header_scredit_rec.sales_credit_id,
                                           p_hist_type_code =>  'UPDATE');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_scredit_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
                                   p_requesting_entity_id => p_x_header_scredit_rec.sales_credit_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);

          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
     ELSE
       OE_CHG_ORDER_PVT.RecordHScreditHist
        (p_header_scredit_id => p_x_header_scredit_rec.sales_credit_id,
         p_header_scredit_rec => null,
         p_hist_type_code => 'UPDATE',
         p_reason_code => p_x_header_scredit_rec.change_reason,
         p_comments => p_x_header_scredit_rec.change_comments,
         p_wf_activity_code => null,
         p_wf_result_code => null,
         x_return_status => l_return_status);
     END IF;
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  'INSERTING HEADER SCREDIT HISTORY CAUSED ERROR' , 1 ) ;
		 END IF;
           if l_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
           else
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
        end if;

    END IF;
END IF;

END Pre_Write_Process;
/* End AuditTrail */


Procedure Calculate (p_header_id        In  Number,
                     p_salesrep_id_tbl  In  salesrep_id_tbl_type,
                     x_sales_credit_tbl OUT NOCOPY sales_credit_tbl_type,
                     x_return_status    OUT NOCOPY VARCHAR2)
Is
i PLS_INTEGER;
plsql_block Varchar2(2000);
l_nlp Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 --sample on how to populate the out. Values are hardcoded for testing purpose
/* i:=  p_salesrep_id_tbl.First;
 While i Is Not Null Loop
   x_sales_credit_tbl(i).salesrep_id     :=p_salesrep_id_tbl(i).salesrep_id;
   x_sales_credit_tbl(i).sales_credit_id :=p_salesrep_id_tbl(i).sales_credit_id;
   x_sales_credit_tbl(i).sales_credit_pct:=25;
 i:= p_salesrep_id_tbl.Next(i);
 End Loop;

 i:=p_salesrep_id_tbl.last + 1;

 x_sales_credit_tbl(i).sales_credit_id :=NULL;
 x_sales_credit_tbl(i).sales_credit_pct:=25;
 ---

 --Code Removed under jgould direction. Oracle IT has canceled this project.

 If G_ACTIVATE_ORCL_CUSTOMIZATION = 'Y' Then
   OE_SALES_CREDIT_HOOK.Calculate(p_header_id       =>p_header_id,
                                  p_sales_rep_id_tbl=>p_salesrep_id_tbl,
                                  x_sales_credit_tbl=>x_sales_credit_tbl,
                                  x_return_status   =>x_return_status);
 End If;
 */

End;


PROCEDURE DFLT_Hscredit_Primary_Srep
 ( p_header_id     IN Number
  ,p_SalesRep_id    IN Number
  ,x_return_status OUT NOCOPY Varchar2
   ) IS
l_sales_credits_count   Number;
l_sales_credit_id   Number;

CURSOR C_HSC_COUNT(p_header_id Number) IS
   SELECT count(sales_credit_id), max(sales_credit_id)
   FROM oe_sales_credits sc,
	   oe_sales_credit_types sct
   WHERE header_id = p_header_id
   AND   sct.sales_credit_type_id = sc.sales_credit_type_id
   AND   sct.quota_flag = 'Y'
   AND   line_id is null;

CURSOR C_SCRTYPE IS
   SELECT nvl(Sales_Credit_Type_id,1)
   FROM   ra_salesreps
   WHERE  salesrep_id = p_salesrep_id;

/* Changed the above cursor definition to fix the bug 1822931 */


l_scredit_type_id number;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_old_Header_Scredit_rec      OE_Order_PUB.Header_Scredit_Rec_Type;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(30);
x_msg_count                   NUMBER;
x_msg_data                    VARCHAR2(2000);
l_header_id                   NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_HEADER_SCREDIT_UTIL.DFLT_HSCREDIT_PRIMARY_SREP' , 1 ) ;
   END IF;

   BEGIN
    SELECT header_id INTO l_header_id
    FROM   oe_order_headers_all
    WHERE  header_id = p_header_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DFLT_HSCREDIT_PRIMARY_SREP,header not created' , 1 ) ;
     END IF;
     RETURN;
   END;

   -- Check if the order has multiple revenue sales credits and if so
   -- prompt the user to use the sales credits window to update sales credits
   -- for the order header
   OPEN C_HSC_COUNT(p_header_id);
   FETCH C_HSC_COUNT INTO l_sales_credits_count, l_sales_credit_id;
   CLOSE C_HSC_COUNT;
   OPEN C_SCRTYPE;
   FETCH C_SCRTYPE INTO l_scredit_Type_id;
   CLOSE C_SCRTYPE;
 -- Commented to fix bug 1589196 Begin
  /* IF l_sales_credits_count > 1 THEN

       fnd_message.set_name('ONT','OE_TOO_MANY_HSCREDIT');
       OE_MSG_PUB.Add;
       RAISE  FND_API.G_EXC_ERROR;

   ELSIF l_sales_credits_count = 1 THEN */
  -- update with new salesrep
  -- Commented to fix bug 1589196   End
   IF l_sales_credits_count = 1 THEN
          OE_Header_Scredit_Util.Lock_Row
               (   p_sales_credit_id      => l_sales_credit_id
			,   p_x_Header_Scredit_rec => l_Header_Scredit_rec
			,   x_return_status        => l_return_status
               );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

           --  Populate Header_Scredit table

	  /* Start Audit Trail */

	  l_Header_Scredit_rec.change_reason := 'SYSTEM';
	  l_Header_Scredit_rec.change_comments := 'Delayed Request, Change in Header Salesperson';

	  /* End Audit Trail */

       l_Header_Scredit_tbl(1) := l_Header_Scredit_rec;

         --  Set Operation. to update existing row
       l_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

       l_old_Header_Scredit_tbl := l_Header_Scredit_tbl;

       -- Update the row with new sales rep
       l_Header_Scredit_tbl(1).salesrep_id := p_salesrep_id;

/* Added the following line to fix the bug 1822931 */
       l_Header_Scredit_tbl(1).sales_credit_type_id := l_scredit_type_id;

       --  Set control flags.

       l_control_rec.controlled_operation := TRUE;
       l_control_rec.validate_entity      := TRUE;
       l_control_rec.write_to_DB          := TRUE;

       l_control_rec.default_attributes   := FALSE;
       l_control_rec.change_attributes    := TRUE;
       l_control_rec.process              := FALSE;
       --  Instruct API to retain its caches

       l_control_rec.clear_api_cache      := FALSE;
       l_control_rec.clear_api_requests   := FALSE;
 --commented to fix bug 1589196  Begin
 --   ELSE
 -- insert for the new sales rep
 --  Set control flags.
 --commented to fix bug 1589196  End
      ELSIF l_sales_credits_count = 0 THEN
       l_control_rec.controlled_operation := TRUE;
       l_control_rec.validate_entity      := TRUE;
       l_control_rec.write_to_DB          := TRUE;

       l_control_rec.default_attributes   := TRUE;
       l_control_rec.change_attributes    := TRUE;
       l_control_rec.process              := FALSE;

       --  Instruct API to retain its caches

       l_control_rec.clear_api_cache      := FALSE;
       l_control_rec.clear_api_requests   := FALSE;

       l_Header_Scredit_rec             := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;
       l_Header_Scredit_rec.operation   := OE_GLOBALS.G_OPR_CREATE;
       l_Header_Scredit_rec.Header_id   := p_header_id;
       l_Header_Scredit_rec.SalesRep_Id := p_salesrep_id;
       l_Header_Scredit_rec.Sales_credit_type_id := l_scredit_type_id;

       --code removed under direction from jgould. Oralce It has cancel this project
       --G_ACTIVATE_ORCL_CUSTOMIZATION = 'Y' and OE_GLOBALS.G_UI_FLAG Then
       --l_Header_Scredit_rec.percent     := 0;
       --Else
         l_Header_Scredit_rec.percent     := 100;
       --End If;

       l_Header_Scredit_tbl(1)          := l_Header_Scredit_rec;
       l_old_Header_Scredit_tbl(1)      := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;

   END IF;
       -- at this stage its either a insert or update
       --  Call OE_Order_PVT.Process_order

    -- Set recursion mode.
    --  OE_GLOBALS.G_RECURSION_MODE := 'Y';

    OE_ORDER_PVT.Header_Scredits
    (p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,p_control_rec                 => l_control_rec
    ,p_x_Header_Scredit_tbl        => l_Header_Scredit_tbl
    ,p_x_old_Header_Scredit_tbl    => l_old_Header_Scredit_tbl
    ,x_return_status               => l_return_status);

    -- Reset recursion mode.
    -- OE_GLOBALS.G_RECURSION_MODE := 'N';

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/*comment out for notification framework*/
/*
    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_Header_Scredit_tbl     => l_Header_Scredit_tbl
     ,p_old_Header_scredit_tbl => l_old_Header_Scredit_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

    IF l_sales_credits_count = 1 THEN -- issue message update with new salesrep
       fnd_message.set_name('ONT','OE_OE_UPDATED_ORDER_CREDIT');
       OE_MSG_PUB.Add;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_SCREDIT_UTIL.DFLT_HSCREDIT_PRIMARY_SREP' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'DFLT_Hscredit_Primary_Srep'
            );
        END IF;
End DFLT_Hscredit_Primary_Srep;

--SG{
Procedure Get_Sales_Group(p_date           IN DATE:=NULL,
                          p_sales_rep_id   IN NUMBER,
                          x_sales_group_id OUT NOCOPY NUMBER,
                          --x_sales_group    OUT NOCOPY VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2) AS
Begin
  x_return_status:=FND_API.G_RET_STS_SUCCESS;


   G_ORG_ID := OE_GLOBALS.G_ORG_ID;

  IF G_ORG_ID IS NULL THEN
     oe_debug_pub.add('OE_GLOBALS.G_ORG_ID IS null');
  END IF;

  Begin
    x_sales_group_id:=jtf_rs_integration_pub.get_default_sales_group(p_sales_rep_id,g_org_id,p_date);
  Exception
    When others Then
    oe_debug_pub.add('Setting sales group id to null:'||SQLERRM);
    x_sales_group_id:=null;
  End;

Exception
  When Others Then
  x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
End;

/*************************************
Redefault sales group as of input date
**************************************/

Procedure Redefault_Sales_Group(p_header_id IN NUMBER,
                                p_date      IN DATE) AS
Cursor none_fixed_sales_group IS
Select salesrep_id,
       sales_credit_id,
       sales_group_id
From   OE_SALES_CREDITS
Where  Sales_Group_Updated_Flag = 'N'
And    header_id = p_header_id;

l_sales_credit_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
l_sales_group_id_tbl  OE_GLOBALS.NUMBER_TBL_TYPE;

j number:=1;
l_status Varchar2(30);
l_sales_group_id Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin

if l_debug_level > 0 then
oe_debug_pub.add('Entering redefault sales group');
end if;

For i In none_fixed_sales_group Loop
  Get_Sales_Group(p_date           =>p_date
                  ,p_sales_rep_id=>i.salesrep_id
                  ,x_sales_group_id=>l_sales_group_id
                  ,x_return_status =>l_status);

 if l_debug_level > 0 then
  oe_debug_pub.add(' sales credit id passed:'||i.salesrep_id);
  oe_debug_pub.add(' date passed:'||p_date);
  oe_debug_pub.add(' return status from get_sales_group:'||l_status);
 end if;

 If l_status = FND_API.G_RET_STS_SUCCESS
     and nvl(l_sales_group_id,-101) <> nvl(i.sales_group_id,-101) Then
    if l_debug_level > 0 then
      oe_debug_pub.add(' l_sales_group_id_tbl index j:'||j);
      oe_debug_pub.add(' old sales group id:'||i.sales_credit_id);
      oe_debug_pub.add(' new sales group id:'||l_sales_group_id);
    end if;
    l_sales_group_id_tbl(j):=l_sales_group_id;
    l_sales_credit_id_tbl(j):=i.sales_credit_id;
    if l_debug_level > 0 then
      oe_debug_pub.add(' group id in tbl:'||l_sales_group_id_tbl(j));
      oe_debug_pub.add(' sales credit id in tbl:'||l_sales_credit_id_tbl(j));
    end if;
    j:=j+1;
  End If;
End Loop;

    IF l_sales_credit_id_tbl.count > 0 THEN
     FORALL i in l_sales_credit_id_tbl.FIRST .. l_sales_credit_id_tbl.LAST
     UPDATE OE_SALES_CREDITS
     SET   Sales_Group_Id = l_sales_group_id_tbl(i)
     WHERE Sales_Credit_Id = l_sales_credit_id_tbl(i);
    END IF;

 if l_debug_level > 0 then
  oe_debug_pub.add('Leaving redefault sales group');
 end If;
Exception
When Others Then
  Oe_Debug_Pub.add('Exception occured OE_Header_Scredit_Util.Redefaut..:'||SQLERRM);
End;
--SG}


END OE_Header_Scredit_Util;

/

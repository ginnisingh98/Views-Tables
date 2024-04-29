--------------------------------------------------------
--  DDL for Package Body OE_LINE_SCREDIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_SCREDIT_UTIL" AS
/* $Header: OEXULSCB.pls 120.4.12010000.3 2009/06/23 06:33:53 nitagarw ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Scredit_Util';
G_HEADER_ID                   NUMBER;
G_SALESREP_ID                 NUMBER;

FUNCTION G_MISS_OE_AK_LINE_SCREDIT_REC
RETURN OE_AK_LINE_SCREDITS_V%ROWTYPE IS
l_rowtype_rec				OE_AK_LINE_SCREDITS_V%ROWTYPE;
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
    l_rowtype_rec.sales_credit_type_id:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SALES_CREDIT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.WH_UPDATE_DATE	:= FND_API.G_MISS_DATE;

    RETURN l_rowtype_rec;

END G_MISS_OE_AK_LINE_SCREDIT_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_SCREDIT_rec              IN  OE_Order_PUB.LINE_SCREDIT_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_rowtype_rec.ATTRIBUTE1       := p_line_scredit_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE10       := p_line_scredit_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_line_scredit_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_line_scredit_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_line_scredit_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_line_scredit_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_line_scredit_rec.ATTRIBUTE15;
    x_rowtype_rec.ATTRIBUTE2       := p_line_scredit_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE3       := p_line_scredit_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_line_scredit_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_line_scredit_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_line_scredit_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_line_scredit_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_line_scredit_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_line_scredit_rec.ATTRIBUTE9;
    x_rowtype_rec.CONTEXT       := p_line_scredit_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY       := p_line_scredit_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE       := p_line_scredit_rec.CREATION_DATE;
    x_rowtype_rec.DB_FLAG       := p_line_scredit_rec.DB_FLAG;
    x_rowtype_rec.DW_UPDATE_ADVICE_FLAG       := p_line_scredit_rec.DW_UPDATE_ADVICE_FLAG;
    x_rowtype_rec.HEADER_ID       := p_line_scredit_rec.HEADER_ID;
    x_rowtype_rec.LAST_UPDATED_BY       := p_line_scredit_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE       := p_line_scredit_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN       := p_line_scredit_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.LINE_ID       := p_line_scredit_rec.LINE_ID;
    x_rowtype_rec.OPERATION       := p_line_scredit_rec.OPERATION;
    x_rowtype_rec.PERCENT       := p_line_scredit_rec.PERCENT;
    x_rowtype_rec.RETURN_STATUS       := p_line_scredit_rec.RETURN_STATUS;
    x_rowtype_rec.SALESREP_ID       := p_line_scredit_rec.SALESREP_ID;
    x_rowtype_rec.sales_credit_type_id := p_line_scredit_rec.sales_credit_type_id;
    x_rowtype_rec.SALES_CREDIT_ID       := p_line_scredit_rec.SALES_CREDIT_ID;
    x_rowtype_rec.WH_UPDATE_DATE       := p_line_scredit_rec.WH_UPDATE_DATE;

END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_LINE_SCREDITS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.LINE_SCREDIT_Rec_Type
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

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Scredit_rec            IN OUT NOCOPY OE_AK_LINE_SCREDITS_V%ROWTYPE
,   p_old_Line_Scredit_rec          IN  OE_AK_LINE_SCREDITS_V%ROWTYPE :=
                                        G_MISS_OE_AK_LINE_SCREDIT_REC
)
IS
l_index			NUMBER :=0;
l_src_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute1,p_old_Line_Scredit_rec.attribute1)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute10,p_old_Line_Scredit_rec.attribute10)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute11,p_old_Line_Scredit_rec.attribute11)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute12,p_old_Line_Scredit_rec.attribute12)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute13,p_old_Line_Scredit_rec.attribute13)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute14,p_old_Line_Scredit_rec.attribute14)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute15,p_old_Line_Scredit_rec.attribute15)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute2,p_old_Line_Scredit_rec.attribute2)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute3,p_old_Line_Scredit_rec.attribute3)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute4,p_old_Line_Scredit_rec.attribute4)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute5,p_old_Line_Scredit_rec.attribute5)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute6,p_old_Line_Scredit_rec.attribute6)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute7,p_old_Line_Scredit_rec.attribute7)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute8,p_old_Line_Scredit_rec.attribute8)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute9,p_old_Line_Scredit_rec.attribute9)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.context,p_old_Line_Scredit_rec.context)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.created_by,p_old_Line_Scredit_rec.created_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.creation_date,p_old_Line_Scredit_rec.creation_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.dw_update_advice_flag,p_old_Line_Scredit_rec.dw_update_advice_flag)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_DW_UPDATE_ADVICE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.header_id,p_old_Line_Scredit_rec.header_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_updated_by,p_old_Line_Scredit_rec.last_updated_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_update_date,p_old_Line_Scredit_rec.last_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_update_login,p_old_Line_Scredit_rec.last_update_login)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.line_id,p_old_Line_Scredit_rec.line_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.percent,p_old_Line_Scredit_rec.percent)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_PERCENT;
        END IF;


        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.salesrep_id,p_old_Line_Scredit_rec.salesrep_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_SALESREP;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.sales_credit_type_id,p_old_Line_Scredit_rec.sales_credit_type_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_sales_credit_type;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.sales_credit_id,p_old_Line_Scredit_rec.sales_credit_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_SALES_CREDIT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.wh_update_date,p_old_Line_Scredit_rec.wh_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_WH_UPDATE_DATE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_DW_UPDATE_ADVICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_DW_UPDATE_ADVICE;
    ELSIF p_attr_id = G_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_HEADER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_LINE;
    ELSIF p_attr_id = G_PERCENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_PERCENT;
    ELSIF p_attr_id = G_SALESREP THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_SALESREP;
    ELSIF p_attr_id = G_sales_credit_type THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_sales_credit_type;
    ELSIF p_attr_id = G_SALES_CREDIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_SALES_CREDIT;
    ELSIF p_attr_id = G_WH_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_SCREDIT_UTIL.G_WH_UPDATE_DATE;
    END IF;

    If l_src_attr_tbl.COUNT <> 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
        p_source_attr_tbl => l_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
            IF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE1 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE1 := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE10 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE11 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE12 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE13 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE14 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE15 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE15 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE2 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE3 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE4 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE5 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE6 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE7 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE8 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_ATTRIBUTE9 THEN
                p_x_Line_Scredit_rec.ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_CONTEXT THEN
                p_x_Line_Scredit_rec.CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_CREATED_BY THEN
                p_x_Line_Scredit_rec.CREATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_CREATION_DATE THEN
                p_x_Line_Scredit_rec.CREATION_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_DW_UPDATE_ADVICE THEN
                p_x_Line_Scredit_rec.DW_UPDATE_ADVICE_FLAG := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_HEADER THEN
                p_x_Line_Scredit_rec.HEADER_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_LAST_UPDATED_BY THEN
                p_x_Line_Scredit_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_DATE THEN
                p_x_Line_Scredit_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_LAST_UPDATE_LOGIN THEN
                p_x_Line_Scredit_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_LINE THEN
                p_x_Line_Scredit_rec.LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_PERCENT THEN
                p_x_Line_Scredit_rec.PERCENT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_SALESREP THEN
                p_x_Line_Scredit_rec.SALESREP_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_sales_credit_type THEN
                p_x_Line_Scredit_rec.sales_credit_type_id := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_SALES_CREDIT THEN
                p_x_Line_Scredit_rec.SALES_CREDIT_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_SCREDIT_UTIL.G_WH_UPDATE_DATE THEN
                p_x_Line_Scredit_rec.WH_UPDATE_DATE := FND_API.G_MISS_DATE;
    	    END IF;
        END LOOP;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

END Clear_Dependent_Attr;


--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Scredit_rec            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
)
IS
l_Line_Scredit_rec		OE_AK_LINE_SCREDITS_V%ROWTYPE;
l_old_Line_Scredit_rec 		OE_AK_LINE_SCREDITS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	API_Rec_To_Rowtype_Rec(p_x_Line_Scredit_rec,l_Line_Scredit_rec);
	API_Rec_To_Rowtype_Rec(p_old_Line_Scredit_rec, l_old_Line_Scredit_rec);

	Clear_Dependent_Attr
		(p_attr_id			=> p_attr_id
		,p_x_Line_Scredit_rec		=> l_Line_Scredit_rec
		,p_old_Line_Scredit_rec	=> l_old_Line_Scredit_rec
		);

	Rowtype_Rec_To_API_Rec(l_Line_Scredit_rec,p_x_Line_Scredit_rec);

END Clear_Dependent_Attr;


--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Scredit_rec            IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.APPLY_ATTRIBUTE_CHANGES' , 1 ) ;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute1,p_old_Line_Scredit_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute10,p_old_Line_Scredit_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute11,p_old_Line_Scredit_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute12,p_old_Line_Scredit_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute13,p_old_Line_Scredit_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute14,p_old_Line_Scredit_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute15,p_old_Line_Scredit_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute2,p_old_Line_Scredit_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute3,p_old_Line_Scredit_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute4,p_old_Line_Scredit_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute5,p_old_Line_Scredit_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute6,p_old_Line_Scredit_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute7,p_old_Line_Scredit_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute8,p_old_Line_Scredit_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.attribute9,p_old_Line_Scredit_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.context,p_old_Line_Scredit_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.created_by,p_old_Line_Scredit_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.creation_date,p_old_Line_Scredit_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.dw_update_advice_flag,p_old_Line_Scredit_rec.dw_update_advice_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.header_id,p_old_Line_Scredit_rec.header_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_updated_by,p_old_Line_Scredit_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_update_date,p_old_Line_Scredit_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.last_update_login,p_old_Line_Scredit_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.line_id,p_old_Line_Scredit_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.percent,p_old_Line_Scredit_rec.percent)
    THEN
        -- Add delayed request to validate quota percent sums up to 100
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_request_type=>OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL
               ,p_param1     => to_char(p_x_Line_Scredit_rec.Line_id)
               ,x_return_status =>l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Add delayed request to cascade changes to service lines.
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_request_type=>OE_GLOBALS.G_CASCADE_SERVICE_SCREDIT
               ,p_param8 => to_char(p_x_Line_Scredit_rec.Line_id)
               ,p_param1 => to_char(p_x_Line_Scredit_rec.salesrep_id)
               ,p_param2 => to_char(p_old_Line_Scredit_rec.salesrep_id)
               ,p_param3 => to_char(p_x_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param4 => to_char(p_old_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param5 => to_char(p_x_Line_Scredit_rec.percent)
               ,p_param6 => to_char(p_old_Line_Scredit_rec.percent)
               ,p_param7 => p_x_Line_Scredit_rec.operation
               ,x_return_status =>l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.sales_credit_type_id,p_old_Line_Scredit_rec.sales_credit_type_id)
    THEN
          -- Add delayed request to validate quota percent sums up to 100
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_request_type=>OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL
               ,p_param1     => to_char(p_x_Line_Scredit_rec.Line_id)
               ,x_return_status =>l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    --END IF; Commented of this end if as part of fix for bug#2174201

        -- Add delayed request to cascade changes to service lines.
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_request_type=>OE_GLOBALS.G_CASCADE_SERVICE_SCREDIT
               ,p_param8 => to_char(p_x_Line_Scredit_rec.Line_id)
               ,p_param1 => to_char(p_x_Line_Scredit_rec.salesrep_id)
               ,p_param2 => to_char(p_old_Line_Scredit_rec.salesrep_id)
               ,p_param3 => to_char(p_x_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param4 => to_char(p_old_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param5 => to_char(p_x_Line_Scredit_rec.percent)
               ,p_param6 => to_char(p_old_Line_Scredit_rec.percent)
               ,p_param7 => p_x_Line_Scredit_rec.operation
               ,x_return_status =>l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF; --Commented end if moved here as part of fix for bug#2174201

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.salesrep_id,p_old_Line_Scredit_rec.salesrep_id)
    THEN
        -- Add delayed request to cascade changes to service lines.
        OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_requesting_entity_code=>OE_GLOBALS.G_ENTITY_Line_Scredit
               ,p_requesting_entity_id=>p_x_Line_Scredit_rec.sales_credit_id
               ,p_request_type=>OE_GLOBALS.G_CASCADE_SERVICE_SCREDIT
               ,p_param8 => to_char(p_x_Line_Scredit_rec.Line_id)
               ,p_param1 => to_char(p_x_Line_Scredit_rec.salesrep_id)
               ,p_param2 => to_char(p_old_Line_Scredit_rec.salesrep_id)
               ,p_param3 => to_char(p_x_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param4 => to_char(p_old_Line_Scredit_rec.Sales_credit_type_id)
               ,p_param5 => to_char(p_x_Line_Scredit_rec.percent)
               ,p_param6 => to_char(p_old_Line_Scredit_rec.percent)
               ,p_param7 => p_x_Line_Scredit_rec.operation
               ,x_return_status =>l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    --SG{
          IF OE_ORDER_CACHE.G_HEADER_REC.header_id IS NULL THEN
             --header not available in cache, load info to cache
            IF p_x_line_Scredit_rec.line_Id IS NOT NULL THEN
             OE_ORDER_CACHE.Load_Order_Header(p_x_line_Scredit_rec.Header_Id);
            ELSE
             oe_debug_pub.add(' Warning:Null header_id for header sales credits');
            END IF;
          END IF;

          IF OE_ORDER_CACHE.G_HEADER_REC.booked_flag = 'Y' THEN
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.booked_date;
          ELSE
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.ordered_date;
          END IF;

--5692017
       IF p_x_line_Scredit_rec.operation = oe_globals.g_opr_create AND
          p_x_line_Scredit_rec.sales_group_id IS NOT NULL AND
          nvl(p_x_line_Scredit_rec.sales_group_updated_flag,'N') = 'Y' THEN
             oe_debug_pub.add('do not re-default sales group');
       ELSE
--5692017
          OE_Header_Scredit_Util.Get_Sales_Group(p_date => l_sg_date,
                          p_sales_rep_id  =>p_x_line_Scredit_rec.salesrep_id,
                          x_sales_group_id=>p_x_line_Scredit_rec.sales_group_id,
                          x_return_status =>l_status);
       END IF;  --5692017
        --SG}

    END IF;


 --SG{
     IF nvl(p_x_line_Scredit_rec.sales_group_updated_flag,'N') <> 'Y'
        AND nvl(p_x_line_Scredit_rec.salesrep_id,FND_API.G_MISS_NUM)<>FND_API.G_MISS_NUM
     THEN

          IF OE_ORDER_CACHE.G_HEADER_REC.header_id IS NULL THEN
             --header not available in cache, load info to cache
            IF p_x_line_Scredit_rec.Header_Id IS NOT NULL THEN
             OE_ORDER_CACHE.Load_Order_Header(p_x_line_Scredit_rec.Header_Id);
            ELSE
             oe_debug_pub.add(' Warning:Null header_id for header sales credits');
            END IF;
          END IF;

          IF OE_ORDER_CACHE.G_HEADER_REC.booked_flag = 'Y' THEN
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.booked_date;
          ELSE
             l_sg_date := OE_ORDER_CACHE.G_HEADER_REC.ordered_date;
          END IF;

          oe_debug_pub.add('Before getting sales group--line');
          OE_Header_Scredit_Util.Get_Sales_Group(p_date => l_sg_date,
                          p_sales_rep_id  =>p_x_line_Scredit_rec.salesrep_id,
                          x_sales_group_id=>p_x_line_Scredit_rec.sales_group_id,
                          x_return_status =>l_status);
     END IF;
   --SG}

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.sales_credit_type_id ,p_old_Line_Scredit_rec.sales_credit_type_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.sales_credit_id,p_old_Line_Scredit_rec.sales_credit_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Scredit_rec.wh_update_date,p_old_Line_Scredit_rec.wh_update_date)
    THEN
        NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.APPLY_ATTRIBUTE_CHANGES' , 1 ) ;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.COMPLETE_RECORD' , 1 ) ;
    END IF;

    IF p_x_Line_Scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute1 := p_old_Line_Scredit_rec.attribute1;
    END IF;

    IF p_x_Line_Scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute10 := p_old_Line_Scredit_rec.attribute10;
    END IF;

    IF p_x_Line_Scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute11 := p_old_Line_Scredit_rec.attribute11;
    END IF;

    IF p_x_Line_Scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute12 := p_old_Line_Scredit_rec.attribute12;
    END IF;

    IF p_x_Line_Scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute13 := p_old_Line_Scredit_rec.attribute13;
    END IF;

    IF p_x_Line_Scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute14 := p_old_Line_Scredit_rec.attribute14;
    END IF;

    IF p_x_Line_Scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute15 := p_old_Line_Scredit_rec.attribute15;
    END IF;

    IF p_x_Line_Scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute2 := p_old_Line_Scredit_rec.attribute2;
    END IF;

    IF p_x_Line_Scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute3 := p_old_Line_Scredit_rec.attribute3;
    END IF;

    IF p_x_Line_Scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute4 := p_old_Line_Scredit_rec.attribute4;
    END IF;

    IF p_x_Line_Scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute5 := p_old_Line_Scredit_rec.attribute5;
    END IF;

    IF p_x_Line_Scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute6 := p_old_Line_Scredit_rec.attribute6;
    END IF;

    IF p_x_Line_Scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute7 := p_old_Line_Scredit_rec.attribute7;
    END IF;

    IF p_x_Line_Scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute8 := p_old_Line_Scredit_rec.attribute8;
    END IF;

    IF p_x_Line_Scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute9 := p_old_Line_Scredit_rec.attribute9;
    END IF;

    IF p_x_Line_Scredit_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.context := p_old_Line_Scredit_rec.context;
    END IF;

    IF p_x_Line_Scredit_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.created_by := p_old_Line_Scredit_rec.created_by;
    END IF;

    IF p_x_Line_Scredit_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.creation_date := p_old_Line_Scredit_rec.creation_date;
    END IF;

    IF p_x_Line_Scredit_rec.dw_update_advice_flag = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.dw_update_advice_flag := p_old_Line_Scredit_rec.dw_update_advice_flag;
    END IF;

    IF p_x_Line_Scredit_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.header_id := p_old_Line_Scredit_rec.header_id;
    END IF;

    IF p_x_Line_Scredit_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.last_updated_by := p_old_Line_Scredit_rec.last_updated_by;
    END IF;

    IF p_x_Line_Scredit_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.last_update_date := p_old_Line_Scredit_rec.last_update_date;
    END IF;

    IF p_x_Line_Scredit_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.last_update_login := p_old_Line_Scredit_rec.last_update_login;
    END IF;

    IF p_x_Line_Scredit_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.line_id := p_old_Line_Scredit_rec.line_id;
    END IF;

    IF p_x_Line_Scredit_rec.percent = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.percent := p_old_Line_Scredit_rec.percent;
    END IF;


    IF p_x_Line_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.salesrep_id := p_old_Line_Scredit_rec.salesrep_id;
    END IF;
    IF p_x_Line_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.sales_credit_type_id := p_old_Line_Scredit_rec.sales_credit_type_id;
    END IF;

    IF p_x_Line_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.sales_credit_id := p_old_Line_Scredit_rec.sales_credit_id;
    END IF;

    IF p_x_Line_Scredit_rec.wh_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.wh_update_date := p_old_Line_Scredit_rec.wh_update_date;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.COMPLETE_RECORD' , 1 ) ;
    END IF;

END Complete_Record;

--  Function Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Scredit_rec              IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.CONVERT_MISS_TO_NULL' , 1 ) ;
    END IF;

    IF p_x_Line_Scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute1 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute10 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute11 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute12 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute13 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute14 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute15 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute2 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute3 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute4 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute5 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute6 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute7 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute8 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.attribute9 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.context := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.created_by := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.creation_date := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.dw_update_advice_flag = FND_API.G_MISS_CHAR THEN
        p_x_Line_Scredit_rec.dw_update_advice_flag := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.header_id := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.last_updated_by := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.last_update_date := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.last_update_login := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.line_id := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.percent = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.percent := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.salesrep_id := NULL;
    END IF;
    IF p_x_Line_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.sales_credit_type_id := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Scredit_rec.sales_credit_id := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.wh_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Scredit_rec.wh_update_date := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.CONVERT_MISS_TO_NULL' , 1 ) ;
    END IF;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
l_lock_control   NUMBER;
/* jolin start*/
--added for notification framework
      l_Line_scredit_rec     	OE_Order_PUB.Line_scredit_Rec_Type;
      l_index    		NUMBER;
      l_return_status 		VARCHAR2(1);
/* jolin end*/

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
    END IF;

    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_SALES_CREDITS
    WHERE  sales_credit_id = p_Line_Scredit_rec.sales_credit_id;

    l_lock_control := l_lock_control + 1;


/* jolin start*/
    --added query_row for notification framework
    --before update, query sales credit record, this record will be used
    --to update global picture

     OE_LINE_SCREDIT_UTIL.Query_Row(p_sales_credit_id => p_line_scredit_rec.sales_credit_id,
                              x_line_scredit_rec =>l_line_scredit_rec);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE UPDATE , SALES_CREDIT_ID= '|| L_LINE_SCREDIT_REC.SALES_CREDIT_ID , 1 ) ;
     END IF;
/* jolin end*/

    UPDATE  OE_SALES_CREDITS
    SET     ATTRIBUTE1                     = p_Line_Scredit_rec.attribute1
    ,       ATTRIBUTE10                    = p_Line_Scredit_rec.attribute10
    ,       ATTRIBUTE11                    = p_Line_Scredit_rec.attribute11
    ,       ATTRIBUTE12                    = p_Line_Scredit_rec.attribute12
    ,       ATTRIBUTE13                    = p_Line_Scredit_rec.attribute13
    ,       ATTRIBUTE14                    = p_Line_Scredit_rec.attribute14
    ,       ATTRIBUTE15                    = p_Line_Scredit_rec.attribute15
    ,       ATTRIBUTE2                     = p_Line_Scredit_rec.attribute2
    ,       ATTRIBUTE3                     = p_Line_Scredit_rec.attribute3
    ,       ATTRIBUTE4                     = p_Line_Scredit_rec.attribute4
    ,       ATTRIBUTE5                     = p_Line_Scredit_rec.attribute5
    ,       ATTRIBUTE6                     = p_Line_Scredit_rec.attribute6
    ,       ATTRIBUTE7                     = p_Line_Scredit_rec.attribute7
    ,       ATTRIBUTE8                     = p_Line_Scredit_rec.attribute8
    ,       ATTRIBUTE9                     = p_Line_Scredit_rec.attribute9
    ,       CONTEXT                        = p_Line_Scredit_rec.context
    ,       CREATED_BY                     = p_Line_Scredit_rec.created_by
    ,       CREATION_DATE                  = p_Line_Scredit_rec.creation_date
    ,       DW_UPDATE_ADVICE_FLAG          = p_Line_Scredit_rec.dw_update_advice_flag
    ,       HEADER_ID                      = p_Line_Scredit_rec.header_id
    ,       LAST_UPDATED_BY                = p_Line_Scredit_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Line_Scredit_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Line_Scredit_rec.last_update_login
    ,       LINE_ID                        = p_Line_Scredit_rec.line_id
    ,       PERCENT                        = p_Line_Scredit_rec.percent
    ,       SALESREP_ID                    = p_Line_Scredit_rec.salesrep_id
    ,       sales_credit_type_id           = p_Line_Scredit_rec.sales_credit_type_id
    ,       SALES_CREDIT_ID                = p_Line_Scredit_rec.sales_credit_id
    ,       WH_UPDATE_DATE                 = p_Line_Scredit_rec.wh_update_date
    ,       LOCK_CONTROL                   = l_lock_control
--SG{
    ,       sales_group_id                 =  p_line_Scredit_rec.sales_group_id
    ,       sales_group_updated_flag            =  p_line_Scredit_rec.sales_group_updated_flag
--SG}
    WHERE   SALES_CREDIT_ID = p_Line_Scredit_rec.sales_credit_id
    ;

    p_Line_Scredit_rec.lock_control := l_lock_control;

 /* jolin start*/
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
    -- calling notification framework to update global picture

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER UPDATE , OLD SALES CREDIT ID= ' || L_LINE_SCREDIT_REC.SALES_CREDIT_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER UPDATE , NEW SALES CREDIT ID= ' || P_LINE_SCREDIT_REC.SALES_CREDIT_ID ) ;
  END IF;

   OE_ORDER_UTIL.Update_Global_Picture
			(p_Upd_New_Rec_If_Exists =>True,
                    	 p_line_scr_rec =>	p_line_scredit_rec,
                    	 p_old_line_scr_rec =>	l_line_scredit_rec,
                    	 p_line_scr_id => 	p_line_scredit_rec.sales_credit_id,
                    	 x_index => 		l_index,
                    	 x_return_status => 	l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_SCREDIT_UTIL.UPDATE_ROW IS: ' || L_RETURN_STATUS ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_SCREDIT_UTIL.UPDATE_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.UPDATE_ROW' , 1 ) ;
    END IF;

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
(   p_Line_Scredit_rec              IN  OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
l_lock_control    NUMBER:= 1;
/* jolin start*/
--added for notification framework
      l_index    		NUMBER;
      l_return_status 		VARCHAR2(1);
/* jolin end*/

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
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
    (       p_Line_Scredit_rec.attribute1
    ,       p_Line_Scredit_rec.attribute10
    ,       p_Line_Scredit_rec.attribute11
    ,       p_Line_Scredit_rec.attribute12
    ,       p_Line_Scredit_rec.attribute13
    ,       p_Line_Scredit_rec.attribute14
    ,       p_Line_Scredit_rec.attribute15
    ,       p_Line_Scredit_rec.attribute2
    ,       p_Line_Scredit_rec.attribute3
    ,       p_Line_Scredit_rec.attribute4
    ,       p_Line_Scredit_rec.attribute5
    ,       p_Line_Scredit_rec.attribute6
    ,       p_Line_Scredit_rec.attribute7
    ,       p_Line_Scredit_rec.attribute8
    ,       p_Line_Scredit_rec.attribute9
    ,       p_Line_Scredit_rec.context
    ,       p_Line_Scredit_rec.created_by
    ,       p_Line_Scredit_rec.creation_date
    ,       p_Line_Scredit_rec.dw_update_advice_flag
    ,       p_Line_Scredit_rec.header_id
    ,       p_Line_Scredit_rec.last_updated_by
    ,       p_Line_Scredit_rec.last_update_date
    ,       p_Line_Scredit_rec.last_update_login
    ,       p_Line_Scredit_rec.line_id
    ,       p_Line_Scredit_rec.percent
    ,       p_Line_Scredit_rec.salesrep_id
    ,       p_Line_Scredit_rec.sales_credit_type_id
    ,       p_Line_Scredit_rec.sales_credit_id
    ,       p_Line_Scredit_rec.wh_update_date
    ,       p_Line_Scredit_rec.orig_sys_credit_ref
--SG{
    ,       p_line_scredit_rec.sales_group_id
    ,       p_line_scredit_rec.sales_group_updated_flag
--SG}
    ,       l_lock_control
    );

    p_Line_Scredit_rec.lock_control := l_lock_control;

 /* jolin start*/
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
    -- calling notification framework to update global picture

   OE_ORDER_UTIL.Update_Global_Picture
			(p_Upd_New_Rec_If_Exists =>True,
                    	 p_line_scr_rec =>	p_line_scredit_rec,
                    	 p_old_line_scr_rec =>	NULL,
                    	 p_line_scr_id => 	p_line_scredit_rec.sales_credit_id,
                    	 x_index => 		l_index,
                    	 x_return_status => 	l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_SCREDIT_UTIL.INSERT_ROW IS: ' || L_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNED INDEX IS: ' || L_INDEX , 1 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_SCREDIT_UTIL.INSERT_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.INSERT_ROW' , 1 ) ;
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
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);
/* jolin start*/
--added for notification framework
      l_Line_scredit_rec     	OE_Order_PUB.Line_scredit_Rec_Type;
      l_new_Line_scredit_rec    OE_Order_PUB.Line_scredit_Rec_Type;
      l_index    		NUMBER;
/* jolin end*/

CURSOR sales_credit IS
	SELECT sales_credit_id
	FROM OE_SALES_CREDITS
	WHERE   LINE_ID = p_line_id;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
    END IF;

  IF p_line_id <> FND_API.G_MISS_NUM
  THEN
    FOR l_scr IN sales_credit LOOP

/* jolin start*/
   --added for notification framework
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
   --query line scredit record, then call notification framework to update global picture.
     OE_LINE_SCREDIT_UTIL.Query_Row(p_sales_credit_id => l_scr.sales_credit_id,
                              x_line_scredit_rec =>l_line_scredit_rec);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN DELETE ROW , SALES_CREDIT_ID= '|| L_SCR.SALES_CREDIT_ID , 1 ) ;
     END IF;

    /* Set the operation on the record so that globals are updated as well */
     l_new_line_scredit_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_line_scredit_rec.sales_credit_id := l_scr.sales_credit_id;

   OE_ORDER_UTIL.Update_Global_Picture
			(p_Upd_New_Rec_If_Exists =>True,
                    	 p_line_scr_rec =>	l_new_line_scredit_rec,
                    	 p_old_line_scr_rec =>	l_line_scredit_rec,
                    	 p_line_scr_id => 	l_scr.sales_credit_id,
                    	 x_index => 		l_index,
                    	 x_return_status => 	l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_SCREDIT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_SCREDIT_UTIL.DELETE_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

      OE_Delayed_Requests_Pvt.Delete_Reqs_for_Deleted_Entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
        p_entity_id     => l_scr.sales_credit_id,
        x_return_status => l_return_status
        );

    END LOOP;

    /* Start Audit Trail (modified for 11.5.10) */
    DELETE  FROM OE_SALES_CREDIT_HISTORY
    WHERE   LINE_ID = p_line_id
    AND     NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND     NVL(VERSION_FLAG, 'N') = 'N'
    AND     NVL(PHASE_CHANGE_FLAG, 'N') = 'N';

    UPDATE OE_SALES_CREDIT_HISTORY
    SET    AUDIT_FLAG = 'N'
    WHERE  LINE_ID = p_line_id
    AND    NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND   (NVL(VERSION_FLAG, 'N') = 'Y'
    OR     NVL(PHASE_CHANGE_FLAG, 'N') = 'Y');
    /* End Audit Trail */

    DELETE  FROM OE_SALES_CREDITS
    WHERE   LINE_ID = p_line_id;

  ELSE

  /* jolin start*/
   --added for notification framework
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
   --query line scredit record, then call notification framework to update global picture.
     OE_LINE_SCREDIT_UTIL.Query_Row(p_sales_credit_id => p_sales_credit_id,
                              x_line_scredit_rec =>l_line_scredit_rec);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN DELETE ROW , LINE_ID IS G_MISS_NUM , SALES_CREDIT_ID= '|| P_SALES_CREDIT_ID , 1 ) ;
     END IF;

    /* Set the operation on the record so that globals are updated as well */
     l_new_line_scredit_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_line_scredit_rec.sales_credit_id := p_sales_credit_id;

      OE_ORDER_UTIL.Update_Global_Picture(
			p_Upd_New_Rec_If_Exists => True,
                    	p_line_scr_rec =>	l_new_line_scredit_rec,
                    	p_old_line_scr_rec => 	l_line_scredit_rec,
                    	p_line_scr_id => 	p_sales_credit_id,
                    	x_index => 		l_index,
                    	x_return_status => 	l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_SCREDIT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_SCREDIT_UTIL.DELETE_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

     OE_Delayed_Requests_Pvt.Delete_Reqs_for_Deleted_Entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
        p_entity_id     => p_sales_credit_id,
        x_return_status => l_return_status
        );

    /* Start Audit Trail (modified for 11.5.10)*/
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.DELETE_ROW' , 1 ) ;
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

--  PROCEDURE Query_Row

PROCEDURE Query_Row
(   p_sales_credit_id               IN  NUMBER
,   x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
l_Line_Scredit_tbl OE_Order_PUB.Line_Scredit_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.QUERY_ROW' , 1 ) ;
    END IF;

    Query_Rows
        (   p_sales_credit_id             => p_sales_credit_id
            ,x_Line_Scredit_tbl => l_Line_Scredit_tbl
        );
    x_Line_Scredit_rec := l_Line_Scredit_tbl(1);

END Query_Row;

--  Function Query_Rows

--

PROCEDURE Query_Rows
(   p_sales_credit_id               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
)
IS

CURSOR l_Line_Scredit_csr_s IS
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

CURSOR l_Line_Scredit_csr_l IS
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
    WHERE   LINE_ID = p_line_id;

CURSOR l_Line_Scredit_csr_h IS
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
      AND   LINE_ID IS NOT NULL;

  l_implicit_rec l_line_scredit_csr_s%ROWTYPE;
  l_entity NUMBER;
  l_count  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF
    (p_sales_credit_id IS NOT NULL
     AND
     p_sales_credit_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: sales_credit_id = '|| p_sales_credit_id || ', line_id = '|| p_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF nvl(p_sales_credit_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 1;
           OPEN l_line_scredit_csr_s;
    ELSIF nvl(p_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 2;
           OPEN l_line_scredit_csr_l;
    ELSIF nvl(p_header_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 3;
           OPEN l_line_scredit_csr_h;
    END IF;

    --  Loop over fetched records

    l_count := 1;

    LOOP
        IF l_entity = 1 THEN
             FETCH l_line_scredit_csr_s INTO l_implicit_rec;
             EXIT WHEN l_line_scredit_csr_s%NOTFOUND;
        ELSIF l_entity = 2 THEN
             FETCH l_line_scredit_csr_l INTO l_implicit_rec;
             EXIT WHEN l_line_scredit_csr_l%NOTFOUND;
        ELSIF l_entity = 3 THEN
             FETCH l_line_scredit_csr_h INTO l_implicit_rec;
             EXIT WHEN l_line_scredit_csr_h%NOTFOUND;
        ELSE
          EXIT;
        END IF;

        x_line_scredit_tbl(l_count).attribute1  := l_implicit_rec.ATTRIBUTE1;
        x_line_scredit_tbl(l_count).attribute10 := l_implicit_rec.ATTRIBUTE10;
        x_line_scredit_tbl(l_count).attribute11 := l_implicit_rec.ATTRIBUTE11;
        x_line_scredit_tbl(l_count).attribute12 := l_implicit_rec.ATTRIBUTE12;
        x_line_scredit_tbl(l_count).attribute13 := l_implicit_rec.ATTRIBUTE13;
        x_line_scredit_tbl(l_count).attribute14 := l_implicit_rec.ATTRIBUTE14;
        x_line_scredit_tbl(l_count).attribute15 := l_implicit_rec.ATTRIBUTE15;
        x_line_scredit_tbl(l_count).attribute2  := l_implicit_rec.ATTRIBUTE2;
        x_line_scredit_tbl(l_count).attribute3  := l_implicit_rec.ATTRIBUTE3;
        x_line_scredit_tbl(l_count).attribute4  := l_implicit_rec.ATTRIBUTE4;
        x_line_scredit_tbl(l_count).attribute5  := l_implicit_rec.ATTRIBUTE5;
        x_line_scredit_tbl(l_count).attribute6  := l_implicit_rec.ATTRIBUTE6;
        x_line_scredit_tbl(l_count).attribute7  := l_implicit_rec.ATTRIBUTE7;
        x_line_scredit_tbl(l_count).attribute8  := l_implicit_rec.ATTRIBUTE8;
        x_line_scredit_tbl(l_count).attribute9  := l_implicit_rec.ATTRIBUTE9;
        x_line_scredit_tbl(l_count).context     := l_implicit_rec.CONTEXT;
        x_line_scredit_tbl(l_count).created_by  := l_implicit_rec.CREATED_BY;
        x_line_scredit_tbl(l_count).creation_date := l_implicit_rec.CREATION_DATE;
        x_line_scredit_tbl(l_count).dw_update_advice_flag := l_implicit_rec.DW_UPDATE_ADVICE_FLAG;
        x_line_scredit_tbl(l_count).header_id   := l_implicit_rec.HEADER_ID;
        x_line_scredit_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_line_scredit_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_line_scredit_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_line_scredit_tbl(l_count).line_id     := l_implicit_rec.LINE_ID;
        x_line_scredit_tbl(l_count).percent     := l_implicit_rec.PERCENT;
        x_line_scredit_tbl(l_count).salesrep_id := l_implicit_rec.SALESREP_ID;
        x_line_scredit_tbl(l_count).sales_credit_type_id := l_implicit_rec.sales_credit_type_id;
        x_line_scredit_tbl(l_count).sales_credit_id := l_implicit_rec.SALES_CREDIT_ID;
        x_line_scredit_tbl(l_count).wh_update_date := l_implicit_rec.WH_UPDATE_DATE;
        --SG {
        x_line_scredit_tbl(l_count).sales_group_id := l_implicit_rec.sales_group_id;
        x_line_scredit_tbl(l_count).sales_group_updated_flag:=l_implicit_rec.sales_group_updated_flag;
        --SG}
        x_line_scredit_tbl(l_count).lock_control := l_implicit_rec.LOCK_CONTROL;

	l_count := l_count + 1;
    END LOOP;

    IF l_entity = 1 THEN
        CLOSE l_line_scredit_csr_s;
    ELSIF l_entity = 2 THEN
        CLOSE l_line_scredit_csr_l;
    ELSIF l_entity = 3 THEN
        CLOSE l_line_scredit_csr_h;
    END IF;

    --  PK sent and no rows found

    IF
    (p_sales_credit_id IS NOT NULL
     AND
     p_sales_credit_id <> FND_API.G_MISS_NUM)
    AND
    (x_Line_Scredit_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.QUERY_ROWS' , 1 ) ;
    END IF;


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
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_sales_credit_id               IN  NUMBER
                                        := FND_API.G_MISS_NUM
)
IS
l_sales_credit_id             NUMBER;
l_lock_control                NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDIT_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF p_sales_credit_id <> FND_API.G_MISS_NUM THEN
        l_sales_credit_id := p_sales_credit_id;
    ELSE
        l_sales_credit_id := p_x_line_scredit_rec.sales_credit_id;
        l_lock_control    := p_x_line_scredit_rec.lock_control;
    END IF;

   SELECT  sales_credit_id
    INTO   l_sales_credit_id
    FROM   oe_sales_credits
    WHERE  sales_credit_id = l_sales_credit_id
    FOR UPDATE NOWAIT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SELECTED FOR UPDATE' , 1 ) ;
    END IF;

    OE_Line_Scredit_Util.Query_Row
	(p_sales_credit_id  => l_sales_credit_id
	,x_line_scredit_rec => p_x_line_scredit_rec );


    -- If lock_control is passed, then return the locked record.
    IF l_lock_control is NULL OR
       l_lock_control <> FND_API.G_MISS_NUM THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_scredit_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

        RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare IN attributes to DB attributes.

    IF  OE_GLOBALS.Equal(p_x_Line_Scredit_rec.lock_control,
                         l_lock_control)
    THEN

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
	    ROLLBACK TO Lock_Row;

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_SCREDIT_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

PROCEDURE Lock_Rows
(   p_sales_credit_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_scredit_tbl          OUT NOCOPY OE_Order_PUB.Line_scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

 )
IS
  CURSOR lock_line_scredits(p_line_id  NUMBER) IS
  SELECT sales_credit_id
  FROM   oe_sales_credits
  WHERE  line_id = p_line_id
    FOR UPDATE NOWAIT;

  l_sales_credit_id    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_SCREDITS_UTIL.LOCK_ROWS' , 1 ) ;
    END IF;

    IF (p_sales_credit_id IS NOT NULL AND
        p_sales_credit_id <> FND_API.G_MISS_NUM) AND
       (p_line_id IS NOT NULL AND
        p_line_id <> FND_API.G_MISS_NUM)
    THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
          , 'Lock Rows'
          , 'Keys are mutually exclusive: sales_credit_id = '||
             p_sales_credit_id || ', line_id = '|| p_line_id );
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

   -- people should not pass in null line_id unnecessarily,
   -- if they already passed in sales_credit_id.

   BEGIN

     IF p_line_id <> FND_API.G_MISS_NUM THEN

       SAVEPOINT LOCK_ROWS;
       OPEN lock_line_scredits(p_line_id);

       LOOP
         FETCH lock_line_scredits INTO l_sales_credit_id;
         EXIT WHEN lock_line_scredits%NOTFOUND;
       END LOOP;

       CLOSE lock_line_scredits;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO LOCK_ROWS;

       IF lock_line_scredits%ISOPEN THEN
         CLOSE lock_line_scredits;
       END IF;

       RAISE;
   END;

   -- locked all

   OE_Line_Scredit_Util.Query_Rows
     (p_sales_credit_id          => p_sales_credit_id
     ,p_line_id                  => p_line_id
     ,x_line_scredit_tbl         => x_line_scredit_tbl
     );

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_LINE_SCREDITS_UTIL.LOCK_ROWS' , 1 ) ;
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
(   p_Line_Scredit_rec              IN  OE_Order_PUB.Line_Scredit_Rec_Type
,   p_old_Line_Scredit_rec          IN  OE_Order_PUB.Line_Scredit_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
) RETURN OE_Order_PUB.Line_Scredit_Val_Rec_Type
IS
l_Line_Scredit_val_rec        OE_Order_PUB.Line_Scredit_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF (p_Line_Scredit_rec.salesrep_id IS NULL OR
        p_Line_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Line_Scredit_rec.salesrep_id,
        p_old_Line_Scredit_rec.salesrep_id)
    THEN
        l_Line_Scredit_val_rec.salesrep := OE_Id_To_Value.Salesrep
        (   p_salesrep_id                 => p_Line_Scredit_rec.salesrep_id
        );
    END IF;
    IF (p_Line_Scredit_rec.sales_credit_type_id IS NULL OR
        p_Line_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Line_Scredit_rec.sales_credit_type_id,
        p_old_Line_Scredit_rec.sales_credit_type_id)
    THEN
        l_Line_Scredit_val_rec.sales_credit_type := OE_Id_To_Value.sales_credit_type
        (   p_sales_Credit_type_id   => p_Line_Scredit_rec.sales_credit_type_id
        );
    END IF;

    --SG{
    If p_line_Scredit_rec.sales_group_id IS NOT NULL Then
    Begin

     l_line_Scredit_val_rec.sales_group:=OE_Id_To_Value.get_sales_group_name(p_line_Scredit_rec.sales_group_id);
    Exception
     When no_data_found Then
      l_line_Scredit_val_rec.sales_group:='Group name not available';
     When others then
      Oe_Debug_Pub.add('OEXULSCB.pls--get_values:'||SQLERRM);
    End;
    End If;
    --SG}

    RETURN l_Line_Scredit_val_rec;

END Get_Values;

--  PROCEDURE Get_Ids

PROCEDURE Get_Ids
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_Line_Scredit_val_rec          IN  OE_Order_PUB.Line_Scredit_Val_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  initialize  return_status.

    p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    IF  p_Line_Scredit_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM THEN

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Scredit_rec.salesrep_id := OE_Value_To_Id.salesrep
            (   p_salesrep                    => p_Line_Scredit_val_rec.salesrep
            );

            IF p_x_Line_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Line_Scredit_val_rec.sales_credit_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM THEN

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Scredit_rec.sales_credit_type_id := OE_Value_To_Id.sales_credit_type
            (   p_sales_credit_type  => p_Line_Scredit_val_rec.sales_credit_type
            );

            IF p_x_Line_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
                p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;
	END IF;

END Get_Ids;


Procedure Create_credit(p_line_rec IN oe_order_pub.line_rec_type,
					p_old_line_rec IN oe_order_pub.line_rec_type)
IS
l_api_name         		CONSTANT VARCHAR2(30)   := 'Create Credit';
l_return_status          VARCHAR2(30);
l_control_rec  		OE_GLOBALS.Control_Rec_Type;
l_line_scredit_tbl 		OE_ORDER_PUB.line_scredit_tbl_type ;
l_old_line_scredit_tbl 	OE_ORDER_PUB.line_scredit_tbl_type ;
l_line_scredit_rec 		OE_ORDER_PUB.line_scredit_rec_type ;
l_create_flag 			boolean := FALSE;
l_update_flag 			boolean := FALSE;
l_scredit_id 			number;
x_msg_count 			number;
x_msg_data 			varchar2(2000);
l_sales_credits_count    Number;
l_sales_credit_id   	Number;
l_salesrep_id			Number;
l_notify_index			Number;

Cursor C_LSC_COUNT IS
   Select count(sales_credit_id), max(sales_credit_id)
   from oe_sales_credits sc,
   oe_sales_credit_types sct
   where header_id = p_line_rec.header_id
   and sc.sales_credit_type_id = sct.sales_credit_type_id
   and   sct.quota_flag = 'Y'
   and line_id =  p_line_rec.line_id;
Cursor C_SCRTYPE IS
   SELECT nvl(Sales_Credit_Type_id,1)
   FROM   ra_salesreps
   WHERE  salesrep_id = p_line_rec.salesrep_id;

/* Modified the above cursor definition to fix the bug 1822931 */
/* changed the above cursor to fix the bug 2685158 */

l_scredit_type_id number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER LINE CREATE CREDITS' ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'HEADER:' ||P_LINE_REC.HEADER_ID ) ;
   END IF;
   IF NOT OE_GLOBALS.EQUAL(G_HEADER_ID,p_line_rec.header_id) or
      G_SALESREP_ID IS NULL  Then
      	--added for bug 4200055
      if ((Oe_Order_Cache.g_header_rec.header_id = p_line_rec.header_id)
          AND (Oe_Order_Cache.g_header_rec.header_id <> NULL)
          AND (Oe_Order_Cache.g_header_rec.header_id <> FND_API.G_MISS_NUM)) Then
           G_SALESREP_ID := Oe_Order_Cache.g_header_rec.salesrep_id ;
      else
          Oe_Order_Cache.Load_Order_Header(p_line_rec.header_id) ;
          G_SALESREP_ID := Oe_Order_Cache.g_header_rec.salesrep_id ;
      end if ;
    /*select salesrep_id
    into G_SALESREP_ID
    from oe_order_headers
    where header_id = p_line_rec.header_id; */
    -- end bug 4200055
   End If;

   l_salesrep_id := G_SALESREP_ID;
   IF NOT OE_GLOBALS.EQUAL(l_salesrep_id, p_line_rec.salesrep_id)
   	OR p_line_rec.salesrep_id IS NULL -- Added condition for bug 6494279
        OR  (p_line_rec.operation = oe_globals.g_opr_update AND       --Added condition for bug 8242058
               NOT OE_GLOBALS.EQUAL( p_line_rec.salesrep_id,
                                     p_old_line_rec.salesrep_id)) THEN


       IF (p_line_rec.operation = oe_globals.g_opr_create AND
             p_line_rec.salesrep_id IS NOT NULL  AND
             p_line_rec.salesrep_id <> FND_API.G_MISS_NUM) THEN

         l_create_flag := TRUE;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN CREATE' ) ;
             END IF;
       ELSIF (p_line_rec.operation = oe_globals.g_opr_update AND
               NOT OE_GLOBALS.EQUAL( p_line_rec.salesrep_id,
                                     p_old_line_rec.salesrep_id)) THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN OPERATION UPDATE ' ) ;
             END IF;

         IF (p_old_line_rec.salesrep_id IS NULL OR
             p_old_line_rec.salesrep_id = FND_API.G_MISS_NUM)
         THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN CREATE FOR UPDATE OPERATION' ) ;
             END IF;
             -- Added for bug 6494279 start

             open C_LSC_COUNT;
	     fetch C_LSC_COUNT into l_sales_credits_count, l_sales_credit_id;
             close C_LSC_COUNT;

             IF l_sales_credits_count = 0 THEN
             -- Added for bug 6494279 end

             l_create_flag := TRUE;

             -- Added for bug 6494279 start
             END IF;

             l_sales_credits_count := NULL;
             l_sales_credit_id := NULL;
             -- Added for bug 6494279 end


         END IF;

         open C_LSC_COUNT;
         fetch C_LSC_COUNT into l_sales_credits_count, l_sales_credit_id;
         close C_LSC_COUNT;

         if l_sales_credits_count > 1 then

            fnd_message.set_name('ONT','OE_TOO_MANY_LSCREDIT');
            OE_MSG_PUB.Add;
            RAISE  FND_API.G_EXC_ERROR;

         elsif l_sales_credits_count = 1 then -- update with new salesrep

            OE_Line_Scredit_Util.Lock_Rows
               (   p_sales_credit_id  => l_sales_credit_id,
			    x_line_scredit_tbl => l_old_line_scredit_tbl,
			    x_return_status    => l_return_status
               );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;

/* Added the following 3 lines to fix the bug 1822931 */
            open C_SCRTYPE;
            fetch C_SCRTYPE into l_scredit_Type_id;
            close C_SCRTYPE;

	  /*Added to fix bug 6445046 START*/
    	  IF l_scredit_Type_id IS NULL THEN
	    oe_debug_pub.add(  'Row in the sales credit table is being removed as the sales peason is removed.' ) ;
		OE_Line_Scredit_Util.Delete_Row
		(   p_sales_credit_id => l_sales_credit_id,
		    p_line_id => p_line_rec.line_id
		);

	  ELSE
	  /*Added to fix bug 6445046 END*/

            l_line_scredit_tbl := l_old_line_scredit_tbl;
		  l_line_scredit_tbl(1).salesrep_id :=
		                          p_line_rec.salesrep_id;

/* Added the following line to fix the bug 1822931 */
                  l_line_scredit_tbl(1).sales_credit_type_id := l_scredit_type_id;

		  l_line_scredit_tbl(1).operation := oe_globals.g_opr_update;
		  l_update_flag := TRUE;

	  END IF; -- Added for Bug 6445046

         elsif l_sales_credits_count = 0 THEN
                     	--	AND l_sales_credit_id IS NOT NULL then -> Added condition for Bug 6445046 and Removed for 8619694


            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CREDIT COUNT IS ZERO ' ) ;
            END IF;
		  l_create_flag := TRUE;

         End if;

       END IF;

       IF l_create_flag THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SETTUBG CREDIT FOR CREATE ' ) ;
             END IF;
		   open C_SCRTYPE;
   	        fetch C_SCRTYPE into l_scredit_Type_id;
   		   close C_SCRTYPE;

             l_line_scredit_tbl(1) := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
             l_line_scredit_tbl(1).operation := oe_globals.g_opr_create;
             l_line_scredit_tbl(1).header_id := p_line_rec.header_id;
             l_line_scredit_tbl(1).line_id := p_line_rec.line_id;
             l_line_scredit_tbl(1).percent := 100;
	        l_line_Scredit_tbl(1).Sales_credit_type_id := l_scredit_type_id;
             l_line_scredit_tbl(1).salesrep_id := p_line_rec.salesrep_id;

       END IF;

       IF l_create_flag OR L_update_flag  THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER' ) ;
             END IF;
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'HEADER_ID:' || L_LINE_SCREDIT_TBL ( 1 ) .HEADER_ID ) ;
                                END IF;
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'LINE_ID:' || L_LINE_SCREDIT_TBL ( 1 ) .LINE_ID ) ;
                                END IF;
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'SALESREPID:' || L_LINE_SCREDIT_TBL ( 1 ) .SALESREP_ID ) ;
                                END IF;
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'SALESCREDIT_ID:' || L_LINE_SCREDIT_TBL ( 1 ) .SALES_CREDIT_ID ) ;
                                END IF;
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'SALESCREDIT_ID:' || L_LINE_SCREDIT_TBL ( 1 ) .SALES_CREDIT_TYPE_ID ) ;
                                END IF;

             l_control_rec.process := FALSE;
             l_control_rec.controlled_operation := TRUE;
             l_control_rec.check_security := TRUE;
             l_control_rec.change_attributes := TRUE;
             l_control_rec.default_attributes := TRUE;
             l_control_rec.write_to_db := TRUE;

             OE_Order_PVT.Line_Scredits
             (    p_init_msg_list               => FND_API.G_FALSE
              ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
              ,   p_control_rec 			 => l_control_rec
              ,   p_x_Line_Scredit_tbl          => l_line_scredit_tbl
              ,   p_x_old_Line_Scredit_tbl      => l_old_line_scredit_tbl
              ,   x_return_status               => l_return_status
		    );

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

--jolin start
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
    -- call notification framework to update this line's global data
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>TRUE
	, p_line_scr_rec	=> l_line_scredit_tbl(1)
	, p_old_line_scr_rec	=> l_old_line_scredit_tbl(1)
        , p_line_scr_id 	=> l_line_scredit_tbl(1).sales_credit_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RET_STATUS FOR LINE_ID '||L_LINE_SCREDIT_TBL ( 1 ) .LINE_ID ||' IS: ' || L_RETURN_STATUS , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL INDEX FOR LINE_ID '||L_LINE_SCREDIT_TBL ( 1 ) .LINE_ID ||' IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

ELSE

             OE_Order_PVT.Process_Requests_And_Notify
            ( p_process_requests          => FALSE
            , p_notify                    => TRUE
            , x_return_status             => l_return_status
            , p_line_scredit_tbl          => l_line_scredit_tbl
            , p_old_line_scredit_tbl      => l_old_line_scredit_tbl
            );

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

END IF; /* code set is pack H or higher */
-- jolin end

	        if l_sales_credits_count = 1 then -- issue message update with new salesrep
                fnd_message.set_name('ONT','OE_OE_UPDATED_LINE_CREDIT');
                OE_MSG_PUB.Add;
             end if;

       END IF; -- if l_create_flag or l_update_flag

   END IF; -- Salesrep id not equal
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'EXIT CREATE CREDITS' ) ;
               END IF;

EXCEPTION

WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Create_Credits'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Create_credit;

/* Start AuditTrail */
PROCEDURE Pre_Write_Process
(p_x_line_scredit_rec IN OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.line_scredit_rec_type,
p_old_line_scredit_rec IN OE_ORDER_PUB.line_scredit_rec_type :=
				 OE_ORDER_PUB.G_MISS_LINE_SCREDIT_REC
)IS
/*local */
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
          IF p_x_line_scredit_rec.change_reason <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_CODE := p_x_line_scredit_rec.change_reason;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_line_scredit_rec.change_comments;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
          ELSE
              IF l_debug_level  > 0 THEN
                 OE_DEBUG_PUB.add('Reason code for versioning missing', 1);
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
                                   p_entity_id => p_x_line_scredit_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
                                   p_requesting_entity_id => p_x_line_scredit_rec.sales_credit_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
     END IF;

IF (p_x_line_scredit_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) then

   IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG='Y' then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXULSCB: AUDIT TRAIL - CHANGE REQUIRES REASON' , 2 ) ;
      END IF;
      IF (p_x_line_scredit_rec.change_reason IS NULL OR
	  p_x_line_scredit_rec.change_reason = FND_API.G_MISS_CHAR OR
          NOT OE_VALIDATE.Change_Reason_Code(p_x_line_Scredit_rec.Change_Reason)) THEN
        IF OE_GLOBALS.G_DEFAULT_REASON THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('Defaulting Audit Reason for Line Sales Credit', 1);
          end if;
          p_x_line_scredit_rec.change_reason := 'SYSTEM';
        ELSE
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Reason code for change is missing or invalid ' , 1 ) ;
          END IF;
          fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
          fnd_message.set_token('OBJECT','LINE SALES CREDIT');
	  oe_msg_pub.add;
	  raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
   END IF;
   IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' OR
	 OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN

     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
                                           p_entity_id => p_x_line_scredit_rec.sales_credit_id,
                                           p_hist_type_code =>  'UPDATE');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_scredit_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
                                   p_requesting_entity_id => p_x_line_scredit_rec.sales_credit_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXULSCB:CALLING OE_ORDER_CHG_PVT.RECORDLSCREDITHIST' , 2 ) ;
        END IF;

	   OE_CHG_ORDER_PVT.RecordLScreditHist
	    (p_line_scredit_id => p_x_line_scredit_rec.sales_credit_id,
		p_line_scredit_rec => null,
		p_hist_type_code => 'UPDATE',
		p_reason_code => p_x_line_scredit_rec.change_reason,
          p_comments => p_x_line_scredit_rec.change_comments,
		p_wf_activity_code => null,
		p_wf_result_code => null,
		x_return_status => l_return_status
	    );
     END IF;
   END IF;
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INSERTING LINE SALES CREDIT HISTORY CAUSED ERROR ' , 1 ) ;
	 END IF;
	 if l_return_status = FND_API.G_RET_STS_ERROR then
	    raise FND_API.G_EXC_ERROR;
	 else
	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   END IF;
END IF;

END Pre_Write_Process;
/* End AuditTrail */

END OE_Line_Scredit_Util;

/

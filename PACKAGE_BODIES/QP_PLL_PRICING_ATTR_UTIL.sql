--------------------------------------------------------
--  DDL for Package Body QP_PLL_PRICING_ATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PLL_PRICING_ATTR_UTIL" AS
/* $Header: QPXUPLAB.pls 120.6.12010000.6 2009/11/30 04:04:28 jputta ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Qp_pll_pricing_attr_Util';
G_PRODUCT_UOM_CODE            VARCHAR2(30);
--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,p_old_PRICING_ATTR_rec.accumulate_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ACCUMULATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,p_old_PRICING_ATTR_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute10,p_old_PRICING_ATTR_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute11,p_old_PRICING_ATTR_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute12,p_old_PRICING_ATTR_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute13,p_old_PRICING_ATTR_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute14,p_old_PRICING_ATTR_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute15,p_old_PRICING_ATTR_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute2,p_old_PRICING_ATTR_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute3,p_old_PRICING_ATTR_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute4,p_old_PRICING_ATTR_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute5,p_old_PRICING_ATTR_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute6,p_old_PRICING_ATTR_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute7,p_old_PRICING_ATTR_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute8,p_old_PRICING_ATTR_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute9,p_old_PRICING_ATTR_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute_grouping_no,p_old_PRICING_ATTR_rec.attribute_grouping_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE_GROUPING_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.context,p_old_PRICING_ATTR_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.created_by,p_old_PRICING_ATTR_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.creation_date,p_old_PRICING_ATTR_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,p_old_PRICING_ATTR_rec.excluder_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_EXCLUDER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_updated_by,p_old_PRICING_ATTR_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_date,p_old_PRICING_ATTR_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_login,p_old_PRICING_ATTR_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,p_old_PRICING_ATTR_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,p_old_PRICING_ATTR_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,p_old_PRICING_ATTR_rec.pricing_phase_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_PHASE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,p_old_PRICING_ATTR_rec.pricing_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,p_old_PRICING_ATTR_rec.pricing_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
        END IF;

/*
        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,p_old_PRICING_ATTR_rec.pricing_attribute_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE;
        END IF;
*/

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.from_rltd_modifier_id,p_old_PRICING_ATTR_rec.from_rltd_modifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_FROM_RLTD_MODIFIER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,p_old_PRICING_ATTR_rec.pricing_attr_value_from)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTR_VALUE_FROM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_to,p_old_PRICING_ATTR_rec.pricing_attr_value_to)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTR_VALUE_TO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,p_old_PRICING_ATTR_rec.product_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,p_old_PRICING_ATTR_rec.product_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,p_old_PRICING_ATTR_rec.product_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTR_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,p_old_PRICING_ATTR_rec.product_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_application_id,p_old_PRICING_ATTR_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_id,p_old_PRICING_ATTR_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_update_date,p_old_PRICING_ATTR_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.request_id,p_old_PRICING_ATTR_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code, p_old_PRICING_ATTR_rec.comparison_operator_code)
	   THEN
		  l_index := l_index + 1;
		  l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_COMPARISON_OPERATOR_CODE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype, p_old_PRICING_ATTR_rec.pricing_attribute_datatype)
	   THEN
		  l_index := l_index + 1;
		  l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype, p_old_PRICING_ATTR_rec.product_attribute_datatype)
	   THEN
		  l_index := l_index + 1;
		  l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE_DATATYPE;
        END IF;

    ELSIF p_attr_id = G_ACCUMULATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ACCUMULATE;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_ATTRIBUTE_GROUPING_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_ATTRIBUTE_GROUPING_NO;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_EXCLUDER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_EXCLUDER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
/*
	ELSIF p_attr_id = G_PRICING_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE;
*/

   ELSIF p_attr_id = G_FROM_RLTD_MODIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_FROM_RLTD_MODIFIER;
   ELSIF p_attr_id = G_PRICING_ATTR_VALUE_FROM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTR_VALUE_FROM;
    ELSIF p_attr_id = G_PRICING_ATTR_VALUE_TO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTR_VALUE_TO;
    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE;
    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE_CONTEXT;
    ELSIF p_attr_id = G_PRODUCT_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTR_VALUE;
    ELSIF p_attr_id = G_PRODUCT_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_UOM;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_REQUEST;

    ELSIF p_attr_id = G_COMPARISON_OPERATOR_CODE THEN
	   l_index := l_index + 1;
	   l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_COMPARISON_OPERATOR_CODE;

    ELSIF p_attr_id = G_PRICING_ATTRIBUTE_DATATYPE THEN
	   l_index := l_index + 1;
	   l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRICING_ATTRIBUTE_DATATYPE;

    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE_DATATYPE THEN
	   l_index := l_index + 1;
	   l_src_attr_tbl(l_index) := QP_pll_pricing_attr_UTIL.G_PRODUCT_ATTRIBUTE_DATATYPE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
l_return_status         varchar2(30);
l_list_header_id        NUMBER;
BEGIN

    --  Load out record

    x_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    IF p_PRICING_ATTR_rec.list_header_id IS NULL       OR
	  p_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN

      BEGIN
          SELECT list_header_id
          INTO   l_list_header_id
          FROM   qp_list_lines
          WHERE  list_line_id = p_PRICING_ATTR_rec.list_line_id;

      EXCEPTION
          WHEN OTHERS THEN
	       l_list_header_id := NULL;
      END;

      x_PRICING_ATTR_rec.list_header_id := l_list_header_id;

    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,p_old_PRICING_ATTR_rec.accumulate_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,p_old_PRICING_ATTR_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute10,p_old_PRICING_ATTR_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute11,p_old_PRICING_ATTR_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute12,p_old_PRICING_ATTR_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute13,p_old_PRICING_ATTR_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute14,p_old_PRICING_ATTR_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute15,p_old_PRICING_ATTR_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute2,p_old_PRICING_ATTR_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute3,p_old_PRICING_ATTR_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute4,p_old_PRICING_ATTR_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute5,p_old_PRICING_ATTR_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute6,p_old_PRICING_ATTR_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute7,p_old_PRICING_ATTR_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute8,p_old_PRICING_ATTR_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute9,p_old_PRICING_ATTR_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute_grouping_no,p_old_PRICING_ATTR_rec.attribute_grouping_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.context,p_old_PRICING_ATTR_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.created_by,p_old_PRICING_ATTR_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.creation_date,p_old_PRICING_ATTR_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,p_old_PRICING_ATTR_rec.excluder_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_updated_by,p_old_PRICING_ATTR_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_date,p_old_PRICING_ATTR_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_login,p_old_PRICING_ATTR_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,p_old_PRICING_ATTR_rec.list_line_id)
    THEN
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_Price_List_Line,
   	         p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Price_List_Line,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,p_old_PRICING_ATTR_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,p_old_PRICING_ATTR_rec.pricing_phase_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,p_old_PRICING_ATTR_rec.pricing_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,p_old_PRICING_ATTR_rec.pricing_attribute_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,p_old_PRICING_ATTR_rec.pricing_attribute_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,p_old_PRICING_ATTR_rec.pricing_attr_value_from)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_to,p_old_PRICING_ATTR_rec.pricing_attr_value_to)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.from_rltd_modifier_id,p_old_PRICING_ATTR_rec.from_rltd_modifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,p_old_PRICING_ATTR_rec.product_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,p_old_PRICING_ATTR_rec.product_attribute_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,p_old_PRICING_ATTR_rec.product_attr_value)
    THEN
        NULL;
    END IF;

    G_PRODUCT_UOM_CODE := p_old_PRICING_ATTR_rec.product_uom_code; --Bug#2853373
    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,p_old_PRICING_ATTR_rec.product_uom_code)
    THEN
          oe_debug_pub.add('New UOM : '||p_PRICING_ATTR_rec.product_uom_code);
          oe_debug_pub.add('Old UOM : '||p_old_PRICING_ATTR_rec.product_uom_code);
          G_PRODUCT_UOM_CODE := p_PRICING_ATTR_rec.product_uom_code;
        -- added for bug 2912834
        IF p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        THEN
          UPDATE qp_pricing_attributes
          SET product_uom_code = p_PRICING_ATTR_rec.product_uom_code
          WHERE list_line_id = p_PRICING_ATTR_rec.list_line_id;

  -- for updating price breaks rassharm bug no 5965155
         update qp_pricing_attributes
         SET product_uom_code = p_PRICING_ATTR_rec.product_uom_code
         where list_line_id in
        (
        select to_rltd_modifier_id
        from qp_list_lines ql, qp_rltd_modifiers qrm
        where from_rltd_modifier_id= p_PRICING_ATTR_rec.list_line_id
        AND qrm.to_rltd_modifier_id = ql.list_line_id
        AND qrm.rltd_modifier_grp_type = 'PRICE BREAK'
        ) ;



        END IF;
--pattern
  	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF(p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
              qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
         END IF;
	END IF;
--pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
              qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
         END IF;
       END IF;
      END IF;

    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_application_id,p_old_PRICING_ATTR_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_id,p_old_PRICING_ATTR_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_update_date,p_old_PRICING_ATTR_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.request_id,p_old_PRICING_ATTR_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code, p_old_PRICING_ATTR_rec.comparison_operator_code)
    THEN
	   NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype, p_old_PRICING_ATTR_rec.pricing_attribute_datatype)
    THEN
	   NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype, p_old_PRICING_ATTR_rec.product_attribute_datatype)
    THEN
	   NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
BEGIN

    IF l_PRICING_ATTR_rec.accumulate_flag = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.accumulate_flag := p_old_PRICING_ATTR_rec.accumulate_flag;
    END IF;

    IF l_PRICING_ATTR_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute1 := p_old_PRICING_ATTR_rec.attribute1;
    END IF;

    IF l_PRICING_ATTR_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute10 := p_old_PRICING_ATTR_rec.attribute10;
    END IF;

    IF l_PRICING_ATTR_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute11 := p_old_PRICING_ATTR_rec.attribute11;
    END IF;

    IF l_PRICING_ATTR_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute12 := p_old_PRICING_ATTR_rec.attribute12;
    END IF;

    IF l_PRICING_ATTR_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute13 := p_old_PRICING_ATTR_rec.attribute13;
    END IF;

    IF l_PRICING_ATTR_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute14 := p_old_PRICING_ATTR_rec.attribute14;
    END IF;

    IF l_PRICING_ATTR_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute15 := p_old_PRICING_ATTR_rec.attribute15;
    END IF;

    IF l_PRICING_ATTR_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute2 := p_old_PRICING_ATTR_rec.attribute2;
    END IF;

    IF l_PRICING_ATTR_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute3 := p_old_PRICING_ATTR_rec.attribute3;
    END IF;

    IF l_PRICING_ATTR_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute4 := p_old_PRICING_ATTR_rec.attribute4;
    END IF;

    IF l_PRICING_ATTR_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute5 := p_old_PRICING_ATTR_rec.attribute5;
    END IF;

    IF l_PRICING_ATTR_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute6 := p_old_PRICING_ATTR_rec.attribute6;
    END IF;

    IF l_PRICING_ATTR_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute7 := p_old_PRICING_ATTR_rec.attribute7;
    END IF;

    IF l_PRICING_ATTR_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute8 := p_old_PRICING_ATTR_rec.attribute8;
    END IF;

    IF l_PRICING_ATTR_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute9 := p_old_PRICING_ATTR_rec.attribute9;
    END IF;

    IF l_PRICING_ATTR_rec.attribute_grouping_no = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.attribute_grouping_no := p_old_PRICING_ATTR_rec.attribute_grouping_no;
    END IF;

    IF l_PRICING_ATTR_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.context := p_old_PRICING_ATTR_rec.context;
    END IF;

    IF l_PRICING_ATTR_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.created_by := p_old_PRICING_ATTR_rec.created_by;
    END IF;

    IF l_PRICING_ATTR_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.creation_date := p_old_PRICING_ATTR_rec.creation_date;
    END IF;

    IF l_PRICING_ATTR_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.excluder_flag := p_old_PRICING_ATTR_rec.excluder_flag;
    END IF;

    IF l_PRICING_ATTR_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.last_updated_by := p_old_PRICING_ATTR_rec.last_updated_by;
    END IF;

    IF l_PRICING_ATTR_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.last_update_date := p_old_PRICING_ATTR_rec.last_update_date;
    END IF;

    IF l_PRICING_ATTR_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.last_update_login := p_old_PRICING_ATTR_rec.last_update_login;
    END IF;

    IF l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_line_id := p_old_PRICING_ATTR_rec.list_line_id;
    END IF;

    IF l_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_header_id := p_old_PRICING_ATTR_rec.list_header_id;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_phase_id := p_old_PRICING_ATTR_rec.pricing_phase_id;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute := p_old_PRICING_ATTR_rec.pricing_attribute;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute_context := p_old_PRICING_ATTR_rec.pricing_attribute_context;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_attribute_id := p_old_PRICING_ATTR_rec.pricing_attribute_id;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attr_value_from = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attr_value_from := p_old_PRICING_ATTR_rec.pricing_attr_value_from;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attr_value_to = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attr_value_to := p_old_PRICING_ATTR_rec.pricing_attr_value_to;
    END IF;

    IF l_PRICING_ATTR_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.from_rltd_modifier_id := p_old_PRICING_ATTR_rec.from_rltd_modifier_id;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute := p_old_PRICING_ATTR_rec.product_attribute;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute_context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute_context := p_old_PRICING_ATTR_rec.product_attribute_context;
    END IF;

    IF l_PRICING_ATTR_rec.product_attr_value = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attr_value := p_old_PRICING_ATTR_rec.product_attr_value;
    END IF;

    IF l_PRICING_ATTR_rec.product_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_uom_code := p_old_PRICING_ATTR_rec.product_uom_code;
    END IF;

    IF l_PRICING_ATTR_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.program_application_id := p_old_PRICING_ATTR_rec.program_application_id;
    END IF;

    IF l_PRICING_ATTR_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.program_id := p_old_PRICING_ATTR_rec.program_id;
    END IF;

    IF l_PRICING_ATTR_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.program_update_date := p_old_PRICING_ATTR_rec.program_update_date;
    END IF;

    IF l_PRICING_ATTR_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.request_id := p_old_PRICING_ATTR_rec.request_id;
    END IF;

    IF l_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.comparison_operator_code := p_old_PRICING_ATTR_rec.comparison_operator_code;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.pricing_attribute_datatype := p_old_PRICING_ATTR_rec.pricing_attribute_datatype;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.product_attribute_datatype := p_old_PRICING_ATTR_rec.product_attribute_datatype;
    END IF;

    IF l_PRICING_ATTR_rec.qualification_ind = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.qualification_ind := p_old_PRICING_ATTR_rec.qualification_ind;
    END IF;

    RETURN l_PRICING_ATTR_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
BEGIN

    IF l_PRICING_ATTR_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.from_rltd_modifier_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.accumulate_flag = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.accumulate_flag := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute1 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute10 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute11 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute12 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute13 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute14 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute15 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute2 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute3 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute4 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute5 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute6 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute7 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute8 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.attribute9 := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.attribute_grouping_no = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.attribute_grouping_no := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.context := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.created_by := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.creation_date := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.excluder_flag := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.last_updated_by := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.last_update_date := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.last_update_login := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_line_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_header_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_phase_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute_context := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_attribute_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attr_value_from = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attr_value_from := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attr_value_to = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attr_value_to := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute_context = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute_context := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.product_attr_value = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attr_value := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.product_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_uom_code := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.program_application_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.program_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICING_ATTR_rec.program_update_date := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.request_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.comparison_operator_code := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.pricing_attribute_datatype := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR THEN
	   l_PRICING_ATTR_rec.product_attribute_datatype := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.qualification_ind = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.qualification_ind := NULL;
    END IF;

    RETURN l_PRICING_ATTR_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_pric_attr_value_from VARCHAR2(240);

BEGIN

SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_ALL_B
       WHERE  LIST_HEADER_ID = p_PRICING_ATTR_rec.list_header_id;

oe_debug_pub.add('BEGIN Update_Row in QPXUPRAB');

    BEGIN
      IF p_PRICING_ATTR_rec.pricing_attribute_datatype = 'N' THEN
            l_pric_attr_value_from_number :=
            qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_from);

            l_pric_attr_value_to_number :=
            qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_to);

            l_pric_attr_value_from :=
            qp_number.number_to_canonical(l_pric_attr_value_from_number);   --4418053
    ELSE

            l_pric_attr_value_from := p_PRICING_ATTR_rec.pricing_attr_value_from;  --4418053

    end if;

    EXCEPTION
            WHEN VALUE_ERROR THEN
                  NULL;
            WHEN OTHERS THEN
                  NULL;
    END;

   IF G_PRODUCT_UOM_CODE IS NULL
   THEN G_PRODUCT_UOM_CODE :=p_PRICING_ATTR_rec.product_uom_code;
    END IF;

    UPDATE  QP_PRICING_ATTRIBUTES
    SET     ACCUMULATE_FLAG                = p_PRICING_ATTR_rec.accumulate_flag
    ,       ATTRIBUTE1                     = p_PRICING_ATTR_rec.attribute1
    ,       ATTRIBUTE10                    = p_PRICING_ATTR_rec.attribute10
    ,       ATTRIBUTE11                    = p_PRICING_ATTR_rec.attribute11
    ,       ATTRIBUTE12                    = p_PRICING_ATTR_rec.attribute12
    ,       ATTRIBUTE13                    = p_PRICING_ATTR_rec.attribute13
    ,       ATTRIBUTE14                    = p_PRICING_ATTR_rec.attribute14
    ,       ATTRIBUTE15                    = p_PRICING_ATTR_rec.attribute15
    ,       ATTRIBUTE2                     = p_PRICING_ATTR_rec.attribute2
    ,       ATTRIBUTE3                     = p_PRICING_ATTR_rec.attribute3
    ,       ATTRIBUTE4                     = p_PRICING_ATTR_rec.attribute4
    ,       ATTRIBUTE5                     = p_PRICING_ATTR_rec.attribute5
    ,       ATTRIBUTE6                     = p_PRICING_ATTR_rec.attribute6
    ,       ATTRIBUTE7                     = p_PRICING_ATTR_rec.attribute7
    ,       ATTRIBUTE8                     = p_PRICING_ATTR_rec.attribute8
    ,       ATTRIBUTE9                     = p_PRICING_ATTR_rec.attribute9
    ,       ATTRIBUTE_GROUPING_NO          = p_PRICING_ATTR_rec.attribute_grouping_no
    ,       CONTEXT                        = p_PRICING_ATTR_rec.context
    ,       CREATED_BY                     = p_PRICING_ATTR_rec.created_by
    ,       CREATION_DATE                  = p_PRICING_ATTR_rec.creation_date
    ,       EXCLUDER_FLAG                  = p_PRICING_ATTR_rec.excluder_flag
    ,       LAST_UPDATED_BY                = p_PRICING_ATTR_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_PRICING_ATTR_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_PRICING_ATTR_rec.last_update_login
    ,       LIST_LINE_ID                   = p_PRICING_ATTR_rec.list_line_id
    ,       LIST_HEADER_ID                 = p_PRICING_ATTR_rec.list_header_id
    ,       PRICING_PHASE_ID               = p_PRICING_ATTR_rec.pricing_phase_id
    ,       PRICING_ATTRIBUTE              = p_PRICING_ATTR_rec.pricing_attribute
    ,       PRICING_ATTRIBUTE_CONTEXT      = p_PRICING_ATTR_rec.pricing_attribute_context
    ,       PRICING_ATTRIBUTE_ID           = p_PRICING_ATTR_rec.pricing_attribute_id
    ,       PRICING_ATTR_VALUE_FROM        = l_pric_attr_value_from
    ,       PRICING_ATTR_VALUE_TO          = p_PRICING_ATTR_rec.pricing_attr_value_to
    ,       PRODUCT_ATTRIBUTE              = p_PRICING_ATTR_rec.product_attribute
    ,       PRODUCT_ATTRIBUTE_CONTEXT      = p_PRICING_ATTR_rec.product_attribute_context
    ,       PRODUCT_ATTR_VALUE             = p_PRICING_ATTR_rec.product_attr_value
    --,       PRODUCT_UOM_CODE               = p_PRICING_ATTR_rec.product_uom_code
    ,       PRODUCT_UOM_CODE               = G_PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID         = p_PRICING_ATTR_rec.program_application_id
    ,       PROGRAM_ID                     = p_PRICING_ATTR_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PRICING_ATTR_rec.program_update_date
    ,       REQUEST_ID                     = p_PRICING_ATTR_rec.request_id
    ,       COMPARISON_OPERATOR_CODE       = p_PRICING_ATTR_rec.comparison_operator_code
    ,       PRICING_ATTRIBUTE_DATATYPE     = p_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       PRODUCT_ATTRIBUTE_DATATYPE     = p_PRICING_ATTR_rec.product_attribute_datatype
    ,       PRICING_ATTR_VALUE_FROM_NUMBER = l_pric_attr_value_from_number
    ,       PRICING_ATTR_VALUE_TO_NUMBER   = l_pric_attr_value_to_number
    ,       QUALIFICATION_IND             = p_PRICING_ATTR_rec.qualification_ind
    WHERE   PRICING_ATTRIBUTE_ID = p_PRICING_ATTR_rec.pricing_attribute_id
    ;

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN

IF(p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL) AND
  (p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICING_ATTR_rec.pricing_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND    b.prc_context_type='PRICING_ATTRIBUTE'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.pricing_attribute_context);

END IF;

IF(p_PRICING_ATTR_rec.product_attribute_context IS NOT NULL) AND
  (p_PRICING_ATTR_rec.product_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICING_ATTR_rec.product_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND    b.prc_context_type='PRODUCT'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.product_attribute_context);

END IF;
END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_return_status         VARCHAR2(1);
l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;
l_pric_attr_value_from VARCHAR2(240);

BEGIN

oe_debug_pub.add('BEGIN Update_Row in QPXUPRAB');
SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_ALL_B
       WHERE  LIST_HEADER_ID = p_PRICING_ATTR_rec.list_header_id;


    BEGIN
     IF p_PRICING_ATTR_rec.pricing_attribute_datatype = 'N' THEN
            l_pric_attr_value_from_number :=
            qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_from);

            l_pric_attr_value_to_number :=
            qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_to);

            l_pric_attr_value_from :=
            qp_number.number_to_canonical(l_pric_attr_value_from_number);   --4418053
    ELSE

            l_pric_attr_value_from := p_PRICING_ATTR_rec.pricing_attr_value_from;  --4418053
    END IF;

    EXCEPTION
            WHEN VALUE_ERROR THEN
                  NULL;
            WHEN OTHERS THEN
                  NULL;
    END;


    INSERT  INTO QP_PRICING_ATTRIBUTES
    (       ACCUMULATE_FLAG
    ,       ATTRIBUTE1
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
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (       p_PRICING_ATTR_rec.accumulate_flag
    ,       p_PRICING_ATTR_rec.attribute1
    ,       p_PRICING_ATTR_rec.attribute10
    ,       p_PRICING_ATTR_rec.attribute11
    ,       p_PRICING_ATTR_rec.attribute12
    ,       p_PRICING_ATTR_rec.attribute13
    ,       p_PRICING_ATTR_rec.attribute14
    ,       p_PRICING_ATTR_rec.attribute15
    ,       p_PRICING_ATTR_rec.attribute2
    ,       p_PRICING_ATTR_rec.attribute3
    ,       p_PRICING_ATTR_rec.attribute4
    ,       p_PRICING_ATTR_rec.attribute5
    ,       p_PRICING_ATTR_rec.attribute6
    ,       p_PRICING_ATTR_rec.attribute7
    ,       p_PRICING_ATTR_rec.attribute8
    ,       p_PRICING_ATTR_rec.attribute9
    ,       p_PRICING_ATTR_rec.attribute_grouping_no
    ,       p_PRICING_ATTR_rec.context
    ,       p_PRICING_ATTR_rec.created_by
    ,       p_PRICING_ATTR_rec.creation_date
    ,       p_PRICING_ATTR_rec.excluder_flag
    ,       p_PRICING_ATTR_rec.last_updated_by
    ,       p_PRICING_ATTR_rec.last_update_date
    ,       p_PRICING_ATTR_rec.last_update_login
    ,       p_PRICING_ATTR_rec.list_line_id
    ,       p_PRICING_ATTR_rec.list_header_id
    ,       p_PRICING_ATTR_rec.pricing_phase_id
    ,       p_PRICING_ATTR_rec.pricing_attribute
    ,       p_PRICING_ATTR_rec.pricing_attribute_context
    ,       p_PRICING_ATTR_rec.pricing_attribute_id
    ,       l_pric_attr_value_from
    ,       p_PRICING_ATTR_rec.pricing_attr_value_to
    ,       p_PRICING_ATTR_rec.product_attribute
    ,       p_PRICING_ATTR_rec.product_attribute_context
    ,       p_PRICING_ATTR_rec.product_attr_value
    ,       p_PRICING_ATTR_rec.product_uom_code
    ,       p_PRICING_ATTR_rec.program_application_id
    ,       p_PRICING_ATTR_rec.program_id
    ,       p_PRICING_ATTR_rec.program_update_date
    ,       p_PRICING_ATTR_rec.request_id
    ,       p_PRICING_ATTR_rec.comparison_operator_code
    ,       p_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       p_PRICING_ATTR_rec.product_attribute_datatype
    ,       l_pric_attr_value_from_number
    ,       l_pric_attr_value_to_number
    ,       p_PRICING_ATTR_rec.qualification_ind --euro bug 2138996
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(p_PRICING_ATTR_rec.pricing_attribute_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_PRICING_ATTR_rec.list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from QP_LIST_HEADERS_ALL_B h where h.list_header_id=p_PRICING_ATTR_rec.list_header_id)
    );

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
IF(p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL) AND
  (p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICING_ATTR_rec.pricing_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND    b.prc_context_type='PRICING_ATTRIBUTE'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.pricing_attribute_context);

END IF;


IF(p_PRICING_ATTR_rec.product_attribute_context IS NOT NULL) AND
  (p_PRICING_ATTR_rec.product_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICING_ATTR_rec.product_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND    b.prc_context_type='PRODUCT'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.product_attribute_context);

END IF;
END IF;

qp_delayed_requests_PVT.log_request(
			p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => p_PRICING_ATTR_rec.list_line_id,
			p_requesting_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
			p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
               p_request_type => QP_GLOBALS.G_UPDATE_PRICING_ATTR_PHASE,
			x_return_status => l_return_status);

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   p_pricing_attribute_id          IN  NUMBER
)
IS
BEGIN



    DELETE  FROM QP_PRICING_ATTRIBUTES
    WHERE   PRICING_ATTRIBUTE_ID = p_pricing_attribute_id
    ;


EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_pricing_attribute_id          IN  NUMBER
) RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_pricing_attribute_id        => p_pricing_attribute_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_pricing_attribute_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Price_List_PUB.Pricing_Attr_Tbl_Type
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;

CURSOR l_PRICING_ATTR_csr IS
    SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
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
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE ( PRICING_ATTRIBUTE_ID = p_pricing_attribute_id
    )
    OR (    LIST_LINE_ID = p_list_line_id
    );

BEGIN

    IF
    (p_pricing_attribute_id IS NOT NULL
     AND
     p_pricing_attribute_id <> FND_API.G_MISS_NUM)
    AND
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: pricing_attribute_id = '|| p_pricing_attribute_id || ', list_line_id = '|| p_list_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_PRICING_ATTR_csr LOOP

        l_PRICING_ATTR_rec.accumulate_flag := l_implicit_rec.ACCUMULATE_FLAG;
        l_PRICING_ATTR_rec.attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_PRICING_ATTR_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_PRICING_ATTR_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_PRICING_ATTR_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_PRICING_ATTR_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_PRICING_ATTR_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_PRICING_ATTR_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_PRICING_ATTR_rec.attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_PRICING_ATTR_rec.attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_PRICING_ATTR_rec.attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_PRICING_ATTR_rec.attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_PRICING_ATTR_rec.attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_PRICING_ATTR_rec.attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_PRICING_ATTR_rec.attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_PRICING_ATTR_rec.attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_PRICING_ATTR_rec.attribute_grouping_no := l_implicit_rec.ATTRIBUTE_GROUPING_NO;
        l_PRICING_ATTR_rec.context     := l_implicit_rec.CONTEXT;
        l_PRICING_ATTR_rec.created_by  := l_implicit_rec.CREATED_BY;
        l_PRICING_ATTR_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_PRICING_ATTR_rec.excluder_flag := l_implicit_rec.EXCLUDER_FLAG;
        l_PRICING_ATTR_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICING_ATTR_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICING_ATTR_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICING_ATTR_rec.list_line_id := l_implicit_rec.LIST_LINE_ID;
        l_PRICING_ATTR_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_PRICING_ATTR_rec.pricing_phase_id := l_implicit_rec.PRICING_PHASE_ID;
        l_PRICING_ATTR_rec.pricing_attribute := l_implicit_rec.PRICING_ATTRIBUTE;
        l_PRICING_ATTR_rec.pricing_attribute_context := l_implicit_rec.PRICING_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.pricing_attribute_id := l_implicit_rec.PRICING_ATTRIBUTE_ID;
        l_PRICING_ATTR_rec.pricing_attr_value_from := l_implicit_rec.PRICING_ATTR_VALUE_FROM;
        l_PRICING_ATTR_rec.pricing_attr_value_to := l_implicit_rec.PRICING_ATTR_VALUE_TO;
        l_PRICING_ATTR_rec.product_attribute := l_implicit_rec.PRODUCT_ATTRIBUTE;
        l_PRICING_ATTR_rec.product_attribute_context := l_implicit_rec.PRODUCT_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.product_attr_value := l_implicit_rec.PRODUCT_ATTR_VALUE;
        l_PRICING_ATTR_rec.product_uom_code := l_implicit_rec.PRODUCT_UOM_CODE;
        l_PRICING_ATTR_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICING_ATTR_rec.program_id  := l_implicit_rec.PROGRAM_ID;
        l_PRICING_ATTR_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICING_ATTR_rec.request_id  := l_implicit_rec.REQUEST_ID;
	l_PRICING_ATTR_rec.comparison_operator_code := l_implicit_rec.comparison_operator_code;
	l_PRICING_ATTR_rec.pricing_attribute_datatype := l_implicit_rec.pricing_attribute_datatype;
	l_PRICING_ATTR_rec.product_attribute_datatype := l_implicit_rec.product_attribute_datatype;
	l_PRICING_ATTR_rec.pricing_attr_value_from_number := l_implicit_rec.PRICING_ATTR_VALUE_FROM_NUMBER;
	l_PRICING_ATTR_rec.pricing_attr_value_to_number := l_implicit_rec.PRICING_ATTR_VALUE_TO_NUMBER;
	l_PRICING_ATTR_rec.qualification_ind := l_implicit_rec.QUALIFICATION_IND;


        l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_pricing_attribute_id IS NOT NULL
     AND
     p_pricing_attribute_id <> FND_API.G_MISS_NUM)
    AND
    (l_PRICING_ATTR_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_PRICING_ATTR_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
BEGIN

    SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
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
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    INTO    l_PRICING_ATTR_rec.accumulate_flag
    ,       l_PRICING_ATTR_rec.attribute1
    ,       l_PRICING_ATTR_rec.attribute10
    ,       l_PRICING_ATTR_rec.attribute11
    ,       l_PRICING_ATTR_rec.attribute12
    ,       l_PRICING_ATTR_rec.attribute13
    ,       l_PRICING_ATTR_rec.attribute14
    ,       l_PRICING_ATTR_rec.attribute15
    ,       l_PRICING_ATTR_rec.attribute2
    ,       l_PRICING_ATTR_rec.attribute3
    ,       l_PRICING_ATTR_rec.attribute4
    ,       l_PRICING_ATTR_rec.attribute5
    ,       l_PRICING_ATTR_rec.attribute6
    ,       l_PRICING_ATTR_rec.attribute7
    ,       l_PRICING_ATTR_rec.attribute8
    ,       l_PRICING_ATTR_rec.attribute9
    ,       l_PRICING_ATTR_rec.attribute_grouping_no
    ,       l_PRICING_ATTR_rec.context
    ,       l_PRICING_ATTR_rec.created_by
    ,       l_PRICING_ATTR_rec.creation_date
    ,       l_PRICING_ATTR_rec.excluder_flag
    ,       l_PRICING_ATTR_rec.last_updated_by
    ,       l_PRICING_ATTR_rec.last_update_date
    ,       l_PRICING_ATTR_rec.last_update_login
    ,       l_PRICING_ATTR_rec.list_line_id
    ,       l_PRICING_ATTR_rec.list_header_id
    ,       l_PRICING_ATTR_rec.pricing_phase_id
    ,       l_PRICING_ATTR_rec.pricing_attribute
    ,       l_PRICING_ATTR_rec.pricing_attribute_context
    ,       l_PRICING_ATTR_rec.pricing_attribute_id
    ,       l_PRICING_ATTR_rec.pricing_attr_value_from
    ,       l_PRICING_ATTR_rec.pricing_attr_value_to
    ,       l_PRICING_ATTR_rec.product_attribute
    ,       l_PRICING_ATTR_rec.product_attribute_context
    ,       l_PRICING_ATTR_rec.product_attr_value
    ,       l_PRICING_ATTR_rec.product_uom_code
    ,       l_PRICING_ATTR_rec.program_application_id
    ,       l_PRICING_ATTR_rec.program_id
    ,       l_PRICING_ATTR_rec.program_update_date
    ,       l_PRICING_ATTR_rec.request_id
    ,       l_PRICING_ATTR_rec.comparison_operator_code
    ,       l_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       l_PRICING_ATTR_rec.product_attribute_datatype
    FROM    QP_PRICING_ATTRIBUTES
    WHERE   PRICING_ATTRIBUTE_ID = p_PRICING_ATTR_rec.pricing_attribute_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,
                         l_PRICING_ATTR_rec.accumulate_flag)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,
                         l_PRICING_ATTR_rec.attribute1)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute10,
                         l_PRICING_ATTR_rec.attribute10)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute11,
                         l_PRICING_ATTR_rec.attribute11)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute12,
                         l_PRICING_ATTR_rec.attribute12)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute13,
                         l_PRICING_ATTR_rec.attribute13)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute14,
                         l_PRICING_ATTR_rec.attribute14)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute15,
                         l_PRICING_ATTR_rec.attribute15)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute2,
                         l_PRICING_ATTR_rec.attribute2)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute3,
                         l_PRICING_ATTR_rec.attribute3)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute4,
                         l_PRICING_ATTR_rec.attribute4)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute5,
                         l_PRICING_ATTR_rec.attribute5)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute6,
                         l_PRICING_ATTR_rec.attribute6)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute7,
                         l_PRICING_ATTR_rec.attribute7)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute8,
                         l_PRICING_ATTR_rec.attribute8)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute9,
                         l_PRICING_ATTR_rec.attribute9)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute_grouping_no,
                         l_PRICING_ATTR_rec.attribute_grouping_no)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.context,
                         l_PRICING_ATTR_rec.context)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.created_by,
--                         l_PRICING_ATTR_rec.created_by)
--    AND QP_GLOBALS.Equal(trunc(p_PRICING_ATTR_rec.creation_date),
--                         trunc(l_PRICING_ATTR_rec.creation_date))
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,
                         l_PRICING_ATTR_rec.excluder_flag)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_updated_by,
--                         l_PRICING_ATTR_rec.last_updated_by)
--    AND QP_GLOBALS.Equal(trunc(p_PRICING_ATTR_rec.last_update_date),
--                         trunc(l_PRICING_ATTR_rec.last_update_date))
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_login,
--                         l_PRICING_ATTR_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,
                         l_PRICING_ATTR_rec.list_line_id)
/*    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,
                         l_PRICING_ATTR_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,
                         l_PRICING_ATTR_rec.pricing_phase_id)*/
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,
                         l_PRICING_ATTR_rec.pricing_attribute)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,
                         l_PRICING_ATTR_rec.pricing_attribute_context)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,
                         l_PRICING_ATTR_rec.pricing_attribute_id)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,
                         l_PRICING_ATTR_rec.pricing_attr_value_from)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_to,
                         l_PRICING_ATTR_rec.pricing_attr_value_to)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,
                         l_PRICING_ATTR_rec.product_attribute)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,
                         l_PRICING_ATTR_rec.product_attribute_context)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,
                         l_PRICING_ATTR_rec.product_attr_value)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,
                         l_PRICING_ATTR_rec.product_uom_code)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_application_id,
--                         l_PRICING_ATTR_rec.program_application_id)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_id,
--                         l_PRICING_ATTR_rec.program_id)
--    AND QP_GLOBALS.Equal(trunc(p_PRICING_ATTR_rec.program_update_date),
--                         trunc(l_PRICING_ATTR_rec.program_update_date))
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.request_id,
                         l_PRICING_ATTR_rec.request_id)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code,
					l_PRICING_ATTR_rec.comparison_operator_code)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype,
					l_PRICING_ATTR_rec.pricing_attribute_datatype)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype,
					l_PRICING_ATTR_rec.product_attribute_datatype)
    THEN

        --  Row has not changed. Set out parameter.

        x_PRICING_ATTR_rec             := l_PRICING_ATTR_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

	--8594682 - Add debug messages for OE_LOCK error
	oe_debug_pub.ADD('-------------------Data compare in Price list line Attributes(database vs record)------------------');
	oe_debug_pub.ADD('pricing_attribute_id		:'||l_PRICING_ATTR_rec.pricing_attribute_id||':'||p_PRICING_ATTR_rec.pricing_attribute_id||':');
	oe_debug_pub.ADD('accumulate_flag		:'||l_PRICING_ATTR_rec.accumulate_flag||':'||p_PRICING_ATTR_rec.accumulate_flag||':');
	oe_debug_pub.ADD('attribute1			:'||l_PRICING_ATTR_rec.attribute1||':'||p_PRICING_ATTR_rec.attribute1||':');
	oe_debug_pub.ADD('attribute10			:'||l_PRICING_ATTR_rec.attribute10||':'||p_PRICING_ATTR_rec.attribute10||':');
	oe_debug_pub.ADD('attribute11			:'||l_PRICING_ATTR_rec.attribute11||':'||p_PRICING_ATTR_rec.attribute11||':');
	oe_debug_pub.ADD('attribute12			:'||l_PRICING_ATTR_rec.attribute12||':'||p_PRICING_ATTR_rec.attribute12||':');
	oe_debug_pub.ADD('attribute13			:'||l_PRICING_ATTR_rec.attribute13||':'||p_PRICING_ATTR_rec.attribute13||':');
	oe_debug_pub.ADD('attribute14			:'||l_PRICING_ATTR_rec.attribute14||':'||p_PRICING_ATTR_rec.attribute14||':');
	oe_debug_pub.ADD('attribute15			:'||l_PRICING_ATTR_rec.attribute15||':'||p_PRICING_ATTR_rec.attribute15||':');
	oe_debug_pub.ADD('attribute2			:'||l_PRICING_ATTR_rec.attribute2||':'||p_PRICING_ATTR_rec.attribute2||':');
	oe_debug_pub.ADD('attribute3			:'||l_PRICING_ATTR_rec.attribute3||':'||p_PRICING_ATTR_rec.attribute3||':');
	oe_debug_pub.ADD('attribute4			:'||l_PRICING_ATTR_rec.attribute4||':'||p_PRICING_ATTR_rec.attribute4||':');
	oe_debug_pub.ADD('attribute5			:'||l_PRICING_ATTR_rec.attribute5||':'||p_PRICING_ATTR_rec.attribute5||':');
	oe_debug_pub.ADD('attribute6			:'||l_PRICING_ATTR_rec.attribute6||':'||p_PRICING_ATTR_rec.attribute6||':');
	oe_debug_pub.ADD('attribute7			:'||l_PRICING_ATTR_rec.attribute7||':'||p_PRICING_ATTR_rec.attribute7||':');
	oe_debug_pub.ADD('attribute8			:'||l_PRICING_ATTR_rec.attribute8||':'||p_PRICING_ATTR_rec.attribute8||':');
	oe_debug_pub.ADD('attribute9			:'||l_PRICING_ATTR_rec.attribute9||':'||p_PRICING_ATTR_rec.attribute9||':');
	oe_debug_pub.ADD('attribute_grouping_no		:'||l_PRICING_ATTR_rec.attribute_grouping_no||':'||p_PRICING_ATTR_rec.attribute_grouping_no||':');
	oe_debug_pub.ADD('context			:'||l_PRICING_ATTR_rec.context||':'||p_PRICING_ATTR_rec.context||':');
	oe_debug_pub.ADD('created_by			:'||l_PRICING_ATTR_rec.created_by||':'||p_PRICING_ATTR_rec.created_by||':');
	oe_debug_pub.ADD('creation_date			:'||l_PRICING_ATTR_rec.creation_date||':'||p_PRICING_ATTR_rec.creation_date||':');
	oe_debug_pub.ADD('excluder_flag			:'||l_PRICING_ATTR_rec.excluder_flag||':'||p_PRICING_ATTR_rec.excluder_flag||':');
	oe_debug_pub.ADD('last_updated_by		:'||l_PRICING_ATTR_rec.last_updated_by||':'||p_PRICING_ATTR_rec.last_updated_by||':');
	oe_debug_pub.ADD('last_update_date		:'||l_PRICING_ATTR_rec.last_update_date||':'||p_PRICING_ATTR_rec.last_update_date||':');
	oe_debug_pub.ADD('last_update_login		:'||l_PRICING_ATTR_rec.last_update_login||':'||p_PRICING_ATTR_rec.last_update_login||':');
	oe_debug_pub.ADD('list_line_id			:'||l_PRICING_ATTR_rec.list_line_id||':'||p_PRICING_ATTR_rec.list_line_id||':');
	oe_debug_pub.ADD('list_header_id		:'||l_PRICING_ATTR_rec.list_header_id||':'||p_PRICING_ATTR_rec.list_header_id||':');
	oe_debug_pub.ADD('pricing_phase_id		:'||l_PRICING_ATTR_rec.pricing_phase_id||':'||p_PRICING_ATTR_rec.pricing_phase_id||':');
	oe_debug_pub.ADD('pricing_attribute		:'||l_PRICING_ATTR_rec.pricing_attribute||':'||p_PRICING_ATTR_rec.pricing_attribute||':');
	oe_debug_pub.ADD('pricing_attribute_context	:'||l_PRICING_ATTR_rec.pricing_attribute_context||':'||p_PRICING_ATTR_rec.pricing_attribute_context||':');
	oe_debug_pub.ADD('pricing_attribute_id		:'||l_PRICING_ATTR_rec.pricing_attribute_id||':'||p_PRICING_ATTR_rec.pricing_attribute_id||':');
	oe_debug_pub.ADD('pricing_attr_value_from	:'||l_PRICING_ATTR_rec.pricing_attr_value_from||':'||p_PRICING_ATTR_rec.pricing_attr_value_from||':');
	oe_debug_pub.ADD('pricing_attr_value_to		:'||l_PRICING_ATTR_rec.pricing_attr_value_to||':'||p_PRICING_ATTR_rec.pricing_attr_value_to||':');
	oe_debug_pub.ADD('product_attribute		:'||l_PRICING_ATTR_rec.product_attribute||':'||p_PRICING_ATTR_rec.product_attribute||':');
	oe_debug_pub.ADD('product_attribute_context	:'||l_PRICING_ATTR_rec.product_attribute_context||':'||p_PRICING_ATTR_rec.product_attribute_context||':');
	oe_debug_pub.ADD('product_attr_value		:'||l_PRICING_ATTR_rec.product_attr_value||':'||p_PRICING_ATTR_rec.product_attr_value||':');
	oe_debug_pub.ADD('product_uom_code		:'||l_PRICING_ATTR_rec.product_uom_code||':'||p_PRICING_ATTR_rec.product_uom_code||':');
	oe_debug_pub.ADD('program_application_id	:'||l_PRICING_ATTR_rec.program_application_id||':'||p_PRICING_ATTR_rec.program_application_id||':');
	oe_debug_pub.ADD('program_id			:'||l_PRICING_ATTR_rec.program_id||':'||p_PRICING_ATTR_rec.program_id||':');
	oe_debug_pub.ADD('program_update_date		:'||l_PRICING_ATTR_rec.program_update_date||':'||p_PRICING_ATTR_rec.program_update_date||':');
	oe_debug_pub.ADD('request_id			:'||l_PRICING_ATTR_rec.request_id||':'||p_PRICING_ATTR_rec.request_id||':');
	oe_debug_pub.ADD('comparison_operator_code	:'||l_PRICING_ATTR_rec.comparison_operator_code||':'||p_PRICING_ATTR_rec.comparison_operator_code||':');
	oe_debug_pub.ADD('pricing_attribute_datatype	:'||l_PRICING_ATTR_rec.pricing_attribute_datatype||':'||p_PRICING_ATTR_rec.pricing_attribute_datatype||':');
	oe_debug_pub.ADD('product_attribute_datatype	:'||l_PRICING_ATTR_rec.product_attribute_datatype||':'||p_PRICING_ATTR_rec.product_attribute_datatype||':');
        oe_debug_pub.ADD('-------------------Data compare in price list line Attributes end------------------');
	--  Row has changed by another user.
	--End 8594682 - Add debug messages for OE_LOCK error

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
) RETURN QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type
IS
l_PRICING_ATTR_val_rec        QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type;
BEGIN

    IF p_PRICING_ATTR_rec.accumulate_flag IS NOT NULL AND
        p_PRICING_ATTR_rec.accumulate_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,
        p_old_PRICING_ATTR_rec.accumulate_flag)
    THEN
        l_PRICING_ATTR_val_rec.accumulate := QP_Id_To_Value.Accumulate
        (   p_accumulate_flag             => p_PRICING_ATTR_rec.accumulate_flag
        );
    END IF;

    IF p_PRICING_ATTR_rec.excluder_flag IS NOT NULL AND
        p_PRICING_ATTR_rec.excluder_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,
        p_old_PRICING_ATTR_rec.excluder_flag)
    THEN
        l_PRICING_ATTR_val_rec.excluder := QP_Id_To_Value.Excluder
        (   p_excluder_flag               => p_PRICING_ATTR_rec.excluder_flag
        );
    END IF;

    IF p_PRICING_ATTR_rec.list_line_id IS NOT NULL AND
        p_PRICING_ATTR_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,
        p_old_PRICING_ATTR_rec.list_line_id)
    THEN
        l_PRICING_ATTR_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_PRICING_ATTR_rec.list_line_id
        );
    END IF;

/*    IF p_PRICING_ATTR_rec.pricing_attribute_id IS NOT NULL AND
        p_PRICING_ATTR_rec.pricing_attribute_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,
        p_old_PRICING_ATTR_rec.pricing_attribute_id)
    THEN
        l_PRICING_ATTR_val_rec.pricing_attribute := QP_Id_To_Value.Pricing_Attribute
        (   p_pricing_attribute_id        => p_PRICING_ATTR_rec.pricing_attribute_id
        );
    END IF;
*/
    IF p_PRICING_ATTR_rec.product_uom_code IS NOT NULL AND
        p_PRICING_ATTR_rec.product_uom_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,
        p_old_PRICING_ATTR_rec.product_uom_code)
    THEN
        l_PRICING_ATTR_val_rec.product_uom := QP_Id_To_Value.Product_Uom
        (   p_product_uom_code            => p_PRICING_ATTR_rec.product_uom_code
        );
    END IF;

    RETURN l_PRICING_ATTR_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_PRICING_ATTR_val_rec          IN  QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type
) RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICING_ATTR_rec.

    l_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    IF  p_PRICING_ATTR_val_rec.accumulate <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.accumulate_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.accumulate_flag := p_PRICING_ATTR_rec.accumulate_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accumulate');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.accumulate_flag := QP_Value_To_Id.accumulate
            (   p_accumulate                  => p_PRICING_ATTR_val_rec.accumulate
            );

            IF l_PRICING_ATTR_rec.accumulate_flag = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.excluder <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.excluder_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.excluder_flag := p_PRICING_ATTR_rec.excluder_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.excluder_flag := QP_Value_To_Id.excluder
            (   p_excluder                    => p_PRICING_ATTR_val_rec.excluder
            );

            IF l_PRICING_ATTR_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_PRICING_ATTR_rec.list_line_id := p_PRICING_ATTR_rec.list_line_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_PRICING_ATTR_val_rec.list_line
            );

            IF l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

/****************************************************************************
 Added code to perform value_to_id conversion for pricing_Attribute,
 pricing_Attr_value_from and pricing_attr_value_to columns.
****************************************************************************/

    IF  p_PRICING_ATTR_val_rec.pricing_attribute_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.pricing_attribute <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.pricing_attribute := p_PRICING_ATTR_rec.pricing_attribute;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.pricing_attribute := QP_Value_To_Id.pricing_attribute
            (   p_pricing_attribute_desc           => p_PRICING_ATTR_val_rec.pricing_attribute_desc,
			 p_context => l_PRICING_ATTR_rec.pricing_attribute_context
            );

            IF l_PRICING_ATTR_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.pricing_attr_value_from_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.pricing_attr_value_from <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.pricing_attr_value_from := p_PRICING_ATTR_rec.pricing_attr_value_from;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_from');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.pricing_attr_value_from := QP_Value_To_Id.pricing_attr_value_from
            ( p_pricing_attr_value_from_desc => p_PRICING_ATTR_val_rec.pricing_attr_value_from_desc,
              p_context => l_PRICING_ATTR_rec.pricing_attribute_context,
              p_attribute => l_PRICING_ATTR_rec.pricing_attribute
            );

            IF l_PRICING_ATTR_rec.pricing_attr_value_from = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.pricing_attr_value_to_desc <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.pricing_attr_value_to <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.pricing_attr_value_to := p_PRICING_ATTR_rec.pricing_attr_value_to;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_to');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.pricing_attr_value_to := QP_Value_To_Id.pricing_attr_value_to
            ( p_pricing_attr_value_to_desc => p_PRICING_ATTR_val_rec.pricing_attr_value_to_desc,
              p_context => l_PRICING_ATTR_rec.pricing_attribute_context,
              p_attribute => l_PRICING_ATTR_rec.pricing_attribute
            );

            IF l_PRICING_ATTR_rec.pricing_attr_value_to = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.product_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.product_uom_code <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.product_uom_code := p_PRICING_ATTR_rec.product_uom_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_uom');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.product_uom_code := QP_Value_To_Id.product_uom
            (   p_product_uom                 => p_PRICING_ATTR_val_rec.product_uom
            );

            IF l_PRICING_ATTR_rec.product_uom_code = FND_API.G_MISS_CHAR THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    RETURN l_PRICING_ATTR_rec;

END Get_Ids;

Procedure Pre_Write_Process
(   p_PRICING_ATTR_rec                      IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec                  IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
						QP_Price_List_PUB.G_MISS_Pricing_Attr_REC
,   x_PRICING_ATTR_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
) IS
l_PRICING_ATTR_rec              QP_Price_List_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
l_return_status         varchar2(30);
BEGIN

  oe_debug_pub.Add('Entering QP_pll_PRICING_ATTR_Util.pre_write_process', 1);

--Bug 2807015. Added following code to update pricing attributes when the PA is changed in PLL.
  IF ( p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE)
  THEN
     IF ((p_old_PRICING_ATTR_rec.product_attribute  <> p_PRICING_ATTR_rec.product_attribute) OR
         (p_old_PRICING_ATTR_rec.product_attr_value <> p_PRICING_ATTR_rec.product_attr_value))
     THEN
       begin
          update qp_pricing_attributes
          set product_attribute = p_PRICING_ATTR_rec.product_attribute
          ,   product_attr_value = p_PRICING_ATTR_rec.product_attr_value
          where list_line_id = p_PRICING_ATTR_rec.list_line_id;
       exception
          when NO_DATA_FOUND then
                null;
       end;
     END IF;

  ELSIF ( p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE ) THEN
      begin
          update qp_pricing_attributes
          set product_attribute = p_PRICING_ATTR_rec.product_attribute
          ,   product_attr_value = p_PRICING_ATTR_rec.product_attr_value
          where list_line_id = p_PRICING_ATTR_rec.list_line_id;
       exception
          when NO_DATA_FOUND then
                null;
       end;
  END IF;

  x_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
  IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN

    oe_debug_pub.add('Logging a request to update qualification_ind  ', 1);
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_Price_List_Line,
   	         p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Price_List_Line,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
  END IF;
-- pattern
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);

     END IF;
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'U',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
     END IF;
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'D',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
     END IF;
   END IF; --Java Engine Installed
-- pattern
-- jagan's PL/SQL pattern
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
    IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
      IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);

     END IF;
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'U',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
     END IF;
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'D',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICING_ATTR_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
     END IF;
   END IF; --PL/SQL pattern search
 END IF; --- Java Engine Installed


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        RAISE;
    WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pre_Write_Process'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Pre_Write_Process;

END QP_pll_pricing_attr_Util;

/

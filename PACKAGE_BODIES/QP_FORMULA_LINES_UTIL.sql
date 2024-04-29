--------------------------------------------------------
--  DDL for Package Body QP_FORMULA_LINES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_FORMULA_LINES_UTIL" AS
/* $Header: QPXUPFLB.pls 120.1 2005/06/12 21:05:36 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Formula_Lines_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
,   x_FORMULA_LINES_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

oe_debug_pub.add('Entering proc clear_dependent_attr in FormulaLines Util Pkg');
    --  Load out record

    x_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute1,p_old_FORMULA_LINES_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute10,p_old_FORMULA_LINES_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute11,p_old_FORMULA_LINES_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute12,p_old_FORMULA_LINES_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute13,p_old_FORMULA_LINES_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute14,p_old_FORMULA_LINES_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute15,p_old_FORMULA_LINES_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute2,p_old_FORMULA_LINES_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute3,p_old_FORMULA_LINES_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute4,p_old_FORMULA_LINES_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute5,p_old_FORMULA_LINES_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute6,p_old_FORMULA_LINES_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute7,p_old_FORMULA_LINES_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute8,p_old_FORMULA_LINES_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute9,p_old_FORMULA_LINES_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.context,p_old_FORMULA_LINES_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.created_by,p_old_FORMULA_LINES_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.creation_date,p_old_FORMULA_LINES_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.end_date_active,p_old_FORMULA_LINES_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_updated_by,p_old_FORMULA_LINES_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_date,p_old_FORMULA_LINES_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_login,p_old_FORMULA_LINES_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.numeric_constant,p_old_FORMULA_LINES_rec.numeric_constant)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_NUMERIC_CONSTANT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_id,p_old_FORMULA_LINES_rec.price_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_line_id,p_old_FORMULA_LINES_rec.price_formula_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.formula_line_type_code,p_old_FORMULA_LINES_rec.formula_line_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA_LINE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_list_line_id,p_old_FORMULA_LINES_rec.price_list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_modifier_list_id,p_old_FORMULA_LINES_rec.price_modifier_list_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_MODIFIER_LIST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute,p_old_FORMULA_LINES_rec.pricing_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICING_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute_context,p_old_FORMULA_LINES_rec.pricing_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.start_date_active,p_old_FORMULA_LINES_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.step_number,p_old_FORMULA_LINES_rec.step_number)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_STEP_NUMBER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.reqd_flag,p_old_FORMULA_LINES_rec.reqd_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_REQD_FLAG;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NUMERIC_CONSTANT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_NUMERIC_CONSTANT;
    ELSIF p_attr_id = G_PRICE_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA;
    ELSIF p_attr_id = G_PRICE_FORMULA_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA_LINE;
    ELSIF p_attr_id = G_PRICE_FORMULA_LINE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_FORMULA_LINE_TYPE;
    ELSIF p_attr_id = G_PRICE_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_LIST_LINE;
    ELSIF p_attr_id = G_PRICE_MODIFIER_LIST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICE_MODIFIER_LIST;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICING_ATTRIBUTE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_STEP_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_STEP_NUMBER;
    ELSIF p_attr_id = G_REQD_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_LINES_UTIL.G_REQD_FLAG;
    END IF;

oe_debug_pub.add('Leaving proc clear_dependent_attr in FormulaLines Util Pkg');
END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
,   x_FORMULA_LINES_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc apply_attr_Changes in FormulaLines Util Pkg');
    --  Load out record

    x_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute1,p_old_FORMULA_LINES_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute10,p_old_FORMULA_LINES_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute11,p_old_FORMULA_LINES_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute12,p_old_FORMULA_LINES_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute13,p_old_FORMULA_LINES_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute14,p_old_FORMULA_LINES_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute15,p_old_FORMULA_LINES_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute2,p_old_FORMULA_LINES_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute3,p_old_FORMULA_LINES_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute4,p_old_FORMULA_LINES_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute5,p_old_FORMULA_LINES_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute6,p_old_FORMULA_LINES_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute7,p_old_FORMULA_LINES_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute8,p_old_FORMULA_LINES_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute9,p_old_FORMULA_LINES_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.context,p_old_FORMULA_LINES_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.created_by,p_old_FORMULA_LINES_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.creation_date,p_old_FORMULA_LINES_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.end_date_active,p_old_FORMULA_LINES_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_updated_by,p_old_FORMULA_LINES_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_date,p_old_FORMULA_LINES_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_login,p_old_FORMULA_LINES_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.numeric_constant,p_old_FORMULA_LINES_rec.numeric_constant)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_id,p_old_FORMULA_LINES_rec.price_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_line_id,p_old_FORMULA_LINES_rec.price_formula_line_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.formula_line_type_code,p_old_FORMULA_LINES_rec.formula_line_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_list_line_id,p_old_FORMULA_LINES_rec.price_list_line_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_modifier_list_id,p_old_FORMULA_LINES_rec.price_modifier_list_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute,p_old_FORMULA_LINES_rec.pricing_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute_context,p_old_FORMULA_LINES_rec.pricing_attribute_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.start_date_active,p_old_FORMULA_LINES_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.step_number,p_old_FORMULA_LINES_rec.step_number)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.reqd_flag,p_old_FORMULA_LINES_rec.reqd_flag)
    THEN
        NULL;
    END IF;

oe_debug_pub.add('Leaving proc apply_attr_Changes in FormulaLines Util Pkg');
END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type := p_FORMULA_LINES_rec;
BEGIN

oe_debug_pub.add('Entering proc Complete_Record in FormulaLines Util Pkg');
    IF l_FORMULA_LINES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute1 := p_old_FORMULA_LINES_rec.attribute1;
    END IF;

    IF l_FORMULA_LINES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute10 := p_old_FORMULA_LINES_rec.attribute10;
    END IF;

    IF l_FORMULA_LINES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute11 := p_old_FORMULA_LINES_rec.attribute11;
    END IF;

    IF l_FORMULA_LINES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute12 := p_old_FORMULA_LINES_rec.attribute12;
    END IF;

    IF l_FORMULA_LINES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute13 := p_old_FORMULA_LINES_rec.attribute13;
    END IF;

    IF l_FORMULA_LINES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute14 := p_old_FORMULA_LINES_rec.attribute14;
    END IF;

    IF l_FORMULA_LINES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute15 := p_old_FORMULA_LINES_rec.attribute15;
    END IF;

    IF l_FORMULA_LINES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute2 := p_old_FORMULA_LINES_rec.attribute2;
    END IF;

    IF l_FORMULA_LINES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute3 := p_old_FORMULA_LINES_rec.attribute3;
    END IF;

    IF l_FORMULA_LINES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute4 := p_old_FORMULA_LINES_rec.attribute4;
    END IF;

    IF l_FORMULA_LINES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute5 := p_old_FORMULA_LINES_rec.attribute5;
    END IF;

    IF l_FORMULA_LINES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute6 := p_old_FORMULA_LINES_rec.attribute6;
    END IF;

    IF l_FORMULA_LINES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute7 := p_old_FORMULA_LINES_rec.attribute7;
    END IF;

    IF l_FORMULA_LINES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute8 := p_old_FORMULA_LINES_rec.attribute8;
    END IF;

    IF l_FORMULA_LINES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute9 := p_old_FORMULA_LINES_rec.attribute9;
    END IF;

    IF l_FORMULA_LINES_rec.context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.context := p_old_FORMULA_LINES_rec.context;
    END IF;

    IF l_FORMULA_LINES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.created_by := p_old_FORMULA_LINES_rec.created_by;
    END IF;

    IF l_FORMULA_LINES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.creation_date := p_old_FORMULA_LINES_rec.creation_date;
    END IF;

    IF l_FORMULA_LINES_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.end_date_active := p_old_FORMULA_LINES_rec.end_date_active;
    END IF;

    IF l_FORMULA_LINES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.last_updated_by := p_old_FORMULA_LINES_rec.last_updated_by;
    END IF;

    IF l_FORMULA_LINES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.last_update_date := p_old_FORMULA_LINES_rec.last_update_date;
    END IF;

    IF l_FORMULA_LINES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.last_update_login := p_old_FORMULA_LINES_rec.last_update_login;
    END IF;

    IF l_FORMULA_LINES_rec.numeric_constant = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.numeric_constant := p_old_FORMULA_LINES_rec.numeric_constant;
    END IF;

    IF l_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_formula_id := p_old_FORMULA_LINES_rec.price_formula_id;
    END IF;

    IF l_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_formula_line_id := p_old_FORMULA_LINES_rec.price_formula_line_id;
    END IF;

    IF l_FORMULA_LINES_rec.formula_line_type_code = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.formula_line_type_code := p_old_FORMULA_LINES_rec.formula_line_type_code;
    END IF;

    IF l_FORMULA_LINES_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_list_line_id := p_old_FORMULA_LINES_rec.price_list_line_id;
    END IF;

    IF l_FORMULA_LINES_rec.price_modifier_list_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_modifier_list_id := p_old_FORMULA_LINES_rec.price_modifier_list_id;
    END IF;

    IF l_FORMULA_LINES_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.pricing_attribute := p_old_FORMULA_LINES_rec.pricing_attribute;
    END IF;

    IF l_FORMULA_LINES_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.pricing_attribute_context := p_old_FORMULA_LINES_rec.pricing_attribute_context;
    END IF;

    IF l_FORMULA_LINES_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.start_date_active := p_old_FORMULA_LINES_rec.start_date_active;
    END IF;

    IF l_FORMULA_LINES_rec.step_number = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.step_number := p_old_FORMULA_LINES_rec.step_number;
    END IF;

    IF l_FORMULA_LINES_rec.reqd_flag = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.reqd_flag := p_old_FORMULA_LINES_rec.reqd_flag;
    END IF;

    RETURN l_FORMULA_LINES_rec;

oe_debug_pub.add('Leaving proc Complete_Record in FormulaLines Util Pkg');
END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type := p_FORMULA_LINES_rec;
BEGIN

oe_debug_pub.add('Entering proc Convert_Miss_To_Null in FormulaLines Util Pkg');
    IF l_FORMULA_LINES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute1 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute10 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute11 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute12 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute13 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute14 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute15 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute2 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute3 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute4 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute5 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute6 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute7 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute8 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.attribute9 := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.context := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.created_by := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.creation_date := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.end_date_active := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.last_updated_by := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.last_update_date := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.last_update_login := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.numeric_constant = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.numeric_constant := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_formula_id := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_formula_line_id := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.formula_line_type_code = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.formula_line_type_code := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_list_line_id := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.price_modifier_list_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.price_modifier_list_id := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.pricing_attribute := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.pricing_attribute_context := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_LINES_rec.start_date_active := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.step_number = FND_API.G_MISS_NUM THEN
        l_FORMULA_LINES_rec.step_number := NULL;
    END IF;

    IF l_FORMULA_LINES_rec.reqd_flag = FND_API.G_MISS_CHAR THEN
        l_FORMULA_LINES_rec.reqd_flag := NULL;
    END IF;

oe_debug_pub.add('Leaving proc Convert_Miss_To_Null in FormulaLines Util Pkg');
    RETURN l_FORMULA_LINES_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc Update_Row in FormulaLines Util Pkg');
    UPDATE  QP_PRICE_FORMULA_LINES
    SET     ATTRIBUTE1                     = p_FORMULA_LINES_rec.attribute1
    ,       ATTRIBUTE10                    = p_FORMULA_LINES_rec.attribute10
    ,       ATTRIBUTE11                    = p_FORMULA_LINES_rec.attribute11
    ,       ATTRIBUTE12                    = p_FORMULA_LINES_rec.attribute12
    ,       ATTRIBUTE13                    = p_FORMULA_LINES_rec.attribute13
    ,       ATTRIBUTE14                    = p_FORMULA_LINES_rec.attribute14
    ,       ATTRIBUTE15                    = p_FORMULA_LINES_rec.attribute15
    ,       ATTRIBUTE2                     = p_FORMULA_LINES_rec.attribute2
    ,       ATTRIBUTE3                     = p_FORMULA_LINES_rec.attribute3
    ,       ATTRIBUTE4                     = p_FORMULA_LINES_rec.attribute4
    ,       ATTRIBUTE5                     = p_FORMULA_LINES_rec.attribute5
    ,       ATTRIBUTE6                     = p_FORMULA_LINES_rec.attribute6
    ,       ATTRIBUTE7                     = p_FORMULA_LINES_rec.attribute7
    ,       ATTRIBUTE8                     = p_FORMULA_LINES_rec.attribute8
    ,       ATTRIBUTE9                     = p_FORMULA_LINES_rec.attribute9
    ,       CONTEXT                        = p_FORMULA_LINES_rec.context
    ,       CREATED_BY                     = p_FORMULA_LINES_rec.created_by
    ,       CREATION_DATE                  = p_FORMULA_LINES_rec.creation_date
    ,       END_DATE_ACTIVE                = p_FORMULA_LINES_rec.end_date_active
    ,       LAST_UPDATED_BY                = p_FORMULA_LINES_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_FORMULA_LINES_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_FORMULA_LINES_rec.last_update_login
    ,       NUMERIC_CONSTANT               = p_FORMULA_LINES_rec.numeric_constant
    ,       PRICE_FORMULA_ID               = p_FORMULA_LINES_rec.price_formula_id
    ,       PRICE_FORMULA_LINE_ID          = p_FORMULA_LINES_rec.price_formula_line_id
    ,       PRICE_FORMULA_LINE_TYPE_CODE   = p_FORMULA_LINES_rec.formula_line_type_code
    ,       PRICE_LIST_LINE_ID             = p_FORMULA_LINES_rec.price_list_line_id
    ,       PRICE_MODIFIER_LIST_ID         = p_FORMULA_LINES_rec.price_modifier_list_id
    ,       PRICING_ATTRIBUTE              = p_FORMULA_LINES_rec.pricing_attribute
    ,       PRICING_ATTRIBUTE_CONTEXT      = p_FORMULA_LINES_rec.pricing_attribute_context
    ,       START_DATE_ACTIVE              = p_FORMULA_LINES_rec.start_date_active
    ,       STEP_NUMBER                    = p_FORMULA_LINES_rec.step_number
    ,       REQD_FLAG                      = p_FORMULA_LINES_rec.reqd_flag
    WHERE   PRICE_FORMULA_LINE_ID = p_FORMULA_LINES_rec.price_formula_line_id
    ;

oe_debug_pub.add('Leaving proc Update_Row in FormulaLines Util Pkg');

IF(p_FORMULA_LINES_rec.pricing_attribute_context IS NOT NULL) AND
   (p_FORMULA_LINES_rec.pricing_attribute IS NOT NULL) THEN
   UPDATE qp_pte_segments SET used_in_setup='Y'
   WHERE  nvl(used_in_setup,'N')='N'
   AND    segment_id IN
   (SELECT a.segment_id
    FROM  qp_segments_b a,qp_prc_contexts_b b
    WHERE a.segment_mapping_column=p_FORMULA_LINES_rec.pricing_attribute
    AND   a.prc_context_id=b.prc_context_id
    AND   b.prc_context_code=p_FORMULA_LINES_rec.pricing_attribute_context);
END IF;

EXCEPTION
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc Insert_Row in FormulaLines Util Pkg');
    INSERT  INTO QP_PRICE_FORMULA_LINES
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
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NUMERIC_CONSTANT
    ,       PRICE_FORMULA_ID
    ,       PRICE_FORMULA_LINE_ID
    ,       PRICE_FORMULA_LINE_TYPE_CODE
    ,       PRICE_LIST_LINE_ID
    ,       PRICE_MODIFIER_LIST_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       START_DATE_ACTIVE
    ,       STEP_NUMBER
    ,       REQD_FLAG
    )
    VALUES
    (       p_FORMULA_LINES_rec.attribute1
    ,       p_FORMULA_LINES_rec.attribute10
    ,       p_FORMULA_LINES_rec.attribute11
    ,       p_FORMULA_LINES_rec.attribute12
    ,       p_FORMULA_LINES_rec.attribute13
    ,       p_FORMULA_LINES_rec.attribute14
    ,       p_FORMULA_LINES_rec.attribute15
    ,       p_FORMULA_LINES_rec.attribute2
    ,       p_FORMULA_LINES_rec.attribute3
    ,       p_FORMULA_LINES_rec.attribute4
    ,       p_FORMULA_LINES_rec.attribute5
    ,       p_FORMULA_LINES_rec.attribute6
    ,       p_FORMULA_LINES_rec.attribute7
    ,       p_FORMULA_LINES_rec.attribute8
    ,       p_FORMULA_LINES_rec.attribute9
    ,       p_FORMULA_LINES_rec.context
    ,       p_FORMULA_LINES_rec.created_by
    ,       p_FORMULA_LINES_rec.creation_date
    ,       p_FORMULA_LINES_rec.end_date_active
    ,       p_FORMULA_LINES_rec.last_updated_by
    ,       p_FORMULA_LINES_rec.last_update_date
    ,       p_FORMULA_LINES_rec.last_update_login
    ,       p_FORMULA_LINES_rec.numeric_constant
    ,       p_FORMULA_LINES_rec.price_formula_id
    ,       p_FORMULA_LINES_rec.price_formula_line_id
    ,       p_FORMULA_LINES_rec.formula_line_type_code
    ,       p_FORMULA_LINES_rec.price_list_line_id
    ,       p_FORMULA_LINES_rec.price_modifier_list_id
    ,       p_FORMULA_LINES_rec.pricing_attribute
    ,       p_FORMULA_LINES_rec.pricing_attribute_context
    ,       p_FORMULA_LINES_rec.start_date_active
    ,       p_FORMULA_LINES_rec.step_number
    ,       p_FORMULA_LINES_rec.reqd_flag
    );

oe_debug_pub.add('Leaving proc Insert_Row in FormulaLines Util Pkg');

IF(p_FORMULA_LINES_rec.pricing_attribute_context IS NOT NULL) AND
   (p_FORMULA_LINES_rec.pricing_attribute IS NOT NULL) THEN
   UPDATE qp_pte_segments SET used_in_setup='Y'
   WHERE  nvl(used_in_setup,'N')='N'
   AND    segment_id IN
   (SELECT a.segment_id
    FROM  qp_segments_b a,qp_prc_contexts_b b
    WHERE a.segment_mapping_column=p_FORMULA_LINES_rec.pricing_attribute
    AND   a.prc_context_id=b.prc_context_id
    AND   b.prc_context_code=p_FORMULA_LINES_rec.pricing_attribute_context);
END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_formula_line_id         IN  NUMBER
)
IS
BEGIN

oe_debug_pub.add('Entering proc Delete_Row in FormulaLines Util Pkg');
    DELETE  FROM QP_PRICE_FORMULA_LINES
    WHERE   PRICE_FORMULA_LINE_ID = p_price_formula_line_id
    ;

oe_debug_pub.add('Leaving proc Delete_Row in FormulaLines Util Pkg');


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_price_formula_line_id         IN  NUMBER
) RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type
IS
BEGIN

oe_debug_pub.add('Entering and Leaving proc Query_Row in FormulaLines Util Pkg');
    RETURN Query_Rows
        (   p_price_formula_line_id       => p_price_formula_line_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_price_formula_line_id         IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_formula_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;

CURSOR l_FORMULA_LINES_csr IS
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
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NUMERIC_CONSTANT
    ,       PRICE_FORMULA_ID
    ,       PRICE_FORMULA_LINE_ID
    ,       PRICE_FORMULA_LINE_TYPE_CODE
    ,       PRICE_LIST_LINE_ID
    ,       PRICE_MODIFIER_LIST_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       START_DATE_ACTIVE
    ,       STEP_NUMBER
    ,       REQD_FLAG
    FROM    QP_PRICE_FORMULA_LINES
    WHERE ( PRICE_FORMULA_LINE_ID = p_price_formula_line_id
    )
    OR (    PRICE_FORMULA_ID = p_price_formula_id
    );

BEGIN

oe_debug_pub.add('Entering proc Query_Rows in FormulaLines Util Pkg');
    IF
    (p_price_formula_line_id IS NOT NULL
     AND
     p_price_formula_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_price_formula_id IS NOT NULL
     AND
     p_price_formula_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: price_formula_line_id = '|| p_price_formula_line_id || ', price_formula_id = '|| p_price_formula_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_FORMULA_LINES_csr LOOP

        l_FORMULA_LINES_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_FORMULA_LINES_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_FORMULA_LINES_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_FORMULA_LINES_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_FORMULA_LINES_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_FORMULA_LINES_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_FORMULA_LINES_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_FORMULA_LINES_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_FORMULA_LINES_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_FORMULA_LINES_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_FORMULA_LINES_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_FORMULA_LINES_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_FORMULA_LINES_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_FORMULA_LINES_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_FORMULA_LINES_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_FORMULA_LINES_rec.context    := l_implicit_rec.CONTEXT;
        l_FORMULA_LINES_rec.created_by := l_implicit_rec.CREATED_BY;
        l_FORMULA_LINES_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_FORMULA_LINES_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_FORMULA_LINES_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_FORMULA_LINES_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_FORMULA_LINES_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_FORMULA_LINES_rec.numeric_constant := l_implicit_rec.NUMERIC_CONSTANT;
        l_FORMULA_LINES_rec.price_formula_id := l_implicit_rec.PRICE_FORMULA_ID;
        l_FORMULA_LINES_rec.price_formula_line_id := l_implicit_rec.PRICE_FORMULA_LINE_ID;
        l_FORMULA_LINES_rec.formula_line_type_code := l_implicit_rec.PRICE_FORMULA_LINE_TYPE_CODE;
        l_FORMULA_LINES_rec.price_list_line_id := l_implicit_rec.PRICE_LIST_LINE_ID;
        l_FORMULA_LINES_rec.price_modifier_list_id := l_implicit_rec.PRICE_MODIFIER_LIST_ID;
        l_FORMULA_LINES_rec.pricing_attribute := l_implicit_rec.PRICING_ATTRIBUTE;
        l_FORMULA_LINES_rec.pricing_attribute_context := l_implicit_rec.PRICING_ATTRIBUTE_CONTEXT;
        l_FORMULA_LINES_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_FORMULA_LINES_rec.step_number := l_implicit_rec.STEP_NUMBER;
        l_FORMULA_LINES_rec.reqd_flag := l_implicit_rec.REQD_FLAG;

        l_FORMULA_LINES_tbl(l_FORMULA_LINES_tbl.COUNT + 1) := l_FORMULA_LINES_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_price_formula_line_id IS NOT NULL
     AND
     p_price_formula_line_id <> FND_API.G_MISS_NUM)
    AND
    (l_FORMULA_LINES_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


oe_debug_pub.add('Leaving proc Query_Rows in FormulaLines Util Pkg');
    --  Return fetched table

    RETURN l_FORMULA_LINES_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
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
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   x_FORMULA_LINES_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Lock_Row in FormulaLines Util Pkg');
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
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NUMERIC_CONSTANT
    ,       PRICE_FORMULA_ID
    ,       PRICE_FORMULA_LINE_ID
    ,       PRICE_FORMULA_LINE_TYPE_CODE
    ,       PRICE_LIST_LINE_ID
    ,       PRICE_MODIFIER_LIST_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       START_DATE_ACTIVE
    ,       STEP_NUMBER
    ,       REQD_FLAG
    INTO    l_FORMULA_LINES_rec.attribute1
    ,       l_FORMULA_LINES_rec.attribute10
    ,       l_FORMULA_LINES_rec.attribute11
    ,       l_FORMULA_LINES_rec.attribute12
    ,       l_FORMULA_LINES_rec.attribute13
    ,       l_FORMULA_LINES_rec.attribute14
    ,       l_FORMULA_LINES_rec.attribute15
    ,       l_FORMULA_LINES_rec.attribute2
    ,       l_FORMULA_LINES_rec.attribute3
    ,       l_FORMULA_LINES_rec.attribute4
    ,       l_FORMULA_LINES_rec.attribute5
    ,       l_FORMULA_LINES_rec.attribute6
    ,       l_FORMULA_LINES_rec.attribute7
    ,       l_FORMULA_LINES_rec.attribute8
    ,       l_FORMULA_LINES_rec.attribute9
    ,       l_FORMULA_LINES_rec.context
    ,       l_FORMULA_LINES_rec.created_by
    ,       l_FORMULA_LINES_rec.creation_date
    ,       l_FORMULA_LINES_rec.end_date_active
    ,       l_FORMULA_LINES_rec.last_updated_by
    ,       l_FORMULA_LINES_rec.last_update_date
    ,       l_FORMULA_LINES_rec.last_update_login
    ,       l_FORMULA_LINES_rec.numeric_constant
    ,       l_FORMULA_LINES_rec.price_formula_id
    ,       l_FORMULA_LINES_rec.price_formula_line_id
    ,       l_FORMULA_LINES_rec.formula_line_type_code
    ,       l_FORMULA_LINES_rec.price_list_line_id
    ,       l_FORMULA_LINES_rec.price_modifier_list_id
    ,       l_FORMULA_LINES_rec.pricing_attribute
    ,       l_FORMULA_LINES_rec.pricing_attribute_context
    ,       l_FORMULA_LINES_rec.start_date_active
    ,       l_FORMULA_LINES_rec.step_number
    ,       l_FORMULA_LINES_rec.reqd_flag
    FROM    QP_PRICE_FORMULA_LINES
    WHERE   PRICE_FORMULA_LINE_ID = p_FORMULA_LINES_rec.price_formula_line_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute1,
                         l_FORMULA_LINES_rec.attribute1)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute10,
                         l_FORMULA_LINES_rec.attribute10)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute11,
                         l_FORMULA_LINES_rec.attribute11)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute12,
                         l_FORMULA_LINES_rec.attribute12)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute13,
                         l_FORMULA_LINES_rec.attribute13)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute14,
                         l_FORMULA_LINES_rec.attribute14)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute15,
                         l_FORMULA_LINES_rec.attribute15)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute2,
                         l_FORMULA_LINES_rec.attribute2)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute3,
                         l_FORMULA_LINES_rec.attribute3)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute4,
                         l_FORMULA_LINES_rec.attribute4)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute5,
                         l_FORMULA_LINES_rec.attribute5)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute6,
                         l_FORMULA_LINES_rec.attribute6)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute7,
                         l_FORMULA_LINES_rec.attribute7)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute8,
                         l_FORMULA_LINES_rec.attribute8)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.attribute9,
                         l_FORMULA_LINES_rec.attribute9)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.context,
                         l_FORMULA_LINES_rec.context)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.created_by,
                         l_FORMULA_LINES_rec.created_by)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.creation_date,
                         l_FORMULA_LINES_rec.creation_date)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.end_date_active,
                         l_FORMULA_LINES_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_updated_by,
                         l_FORMULA_LINES_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_date,
                         l_FORMULA_LINES_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.last_update_login,
                         l_FORMULA_LINES_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.numeric_constant,
                         l_FORMULA_LINES_rec.numeric_constant)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_id,
                         l_FORMULA_LINES_rec.price_formula_id)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_line_id,
                         l_FORMULA_LINES_rec.price_formula_line_id)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.formula_line_type_code,
                         l_FORMULA_LINES_rec.formula_line_type_code)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_list_line_id,
                         l_FORMULA_LINES_rec.price_list_line_id)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_modifier_list_id,
                         l_FORMULA_LINES_rec.price_modifier_list_id)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute,
                         l_FORMULA_LINES_rec.pricing_attribute)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.pricing_attribute_context,
                         l_FORMULA_LINES_rec.pricing_attribute_context)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.start_date_active,
                         l_FORMULA_LINES_rec.start_date_active)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.step_number,
                         l_FORMULA_LINES_rec.step_number)
    AND QP_GLOBALS.Equal(p_FORMULA_LINES_rec.reqd_flag,
                         l_FORMULA_LINES_rec.reqd_flag)
    THEN

        --  Row has not changed. Set out parameter.

        x_FORMULA_LINES_rec            := l_FORMULA_LINES_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

oe_debug_pub.add('Leaving proc Lock_Row in FormulaLines Util Pkg');
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
) RETURN QP_Price_Formula_PUB.Formula_Lines_Val_Rec_Type
IS
l_FORMULA_LINES_val_rec       QP_Price_Formula_PUB.Formula_Lines_Val_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Get_Values in FormulaLines Util Pkg');
    IF p_FORMULA_LINES_rec.price_formula_id IS NOT NULL AND
        p_FORMULA_LINES_rec.price_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_id,
        p_old_FORMULA_LINES_rec.price_formula_id)
    THEN
        l_FORMULA_LINES_val_rec.price_formula := QP_Id_To_Value.Price_Formula
        (   p_price_formula_id            => p_FORMULA_LINES_rec.price_formula_id
        );
    END IF;

    IF p_FORMULA_LINES_rec.price_formula_line_id IS NOT NULL AND
        p_FORMULA_LINES_rec.price_formula_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_formula_line_id,
        p_old_FORMULA_LINES_rec.price_formula_line_id)
    THEN
        l_FORMULA_LINES_val_rec.price_formula_line := QP_Id_To_Value.Price_Formula_Line
        (   p_price_formula_line_id       => p_FORMULA_LINES_rec.price_formula_line_id
        );
    END IF;

    IF p_FORMULA_LINES_rec.formula_line_type_code IS NOT NULL AND
        p_FORMULA_LINES_rec.formula_line_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.formula_line_type_code,
        p_old_FORMULA_LINES_rec.formula_line_type_code)
    THEN
        l_FORMULA_LINES_val_rec.price_formula_line_type := QP_Id_To_Value.Price_Formula_Line_Type
        (   p_formula_line_type_code      => p_FORMULA_LINES_rec.formula_line_type_code
        );
    END IF;

    IF p_FORMULA_LINES_rec.price_list_line_id IS NOT NULL AND
        p_FORMULA_LINES_rec.price_list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_list_line_id,
        p_old_FORMULA_LINES_rec.price_list_line_id)
    THEN
        l_FORMULA_LINES_val_rec.price_list_line := QP_Id_To_Value.Price_List_Line
        (   p_price_list_line_id          => p_FORMULA_LINES_rec.price_list_line_id
        );
    END IF;

    IF p_FORMULA_LINES_rec.price_modifier_list_id IS NOT NULL AND
        p_FORMULA_LINES_rec.price_modifier_list_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FORMULA_LINES_rec.price_modifier_list_id,
        p_old_FORMULA_LINES_rec.price_modifier_list_id)
    THEN
        l_FORMULA_LINES_val_rec.price_modifier_list := QP_Id_To_Value.Price_Modifier_List
        (   p_price_modifier_list_id      => p_FORMULA_LINES_rec.price_modifier_list_id
        );
    END IF;

oe_debug_pub.add('Leaving proc Get_Values in FormulaLines Util Pkg');
    RETURN l_FORMULA_LINES_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_FORMULA_LINES_val_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Val_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Get_Ids in FormulaLines Util Pkg');
    --  initialize  return_status.

    l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_FORMULA_LINES_rec.

    l_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    IF  p_FORMULA_LINES_val_rec.price_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_LINES_rec.price_formula_id <> FND_API.G_MISS_NUM THEN

            l_FORMULA_LINES_rec.price_formula_id := p_FORMULA_LINES_rec.price_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_LINES_rec.price_formula_id := QP_Value_To_Id.price_formula
            (   p_price_formula               => p_FORMULA_LINES_val_rec.price_formula
            );

            IF l_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM THEN
                l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_val_rec.price_formula_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_LINES_rec.price_formula_line_id <> FND_API.G_MISS_NUM THEN

            l_FORMULA_LINES_rec.price_formula_line_id := p_FORMULA_LINES_rec.price_formula_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_LINES_rec.price_formula_line_id := QP_Value_To_Id.price_formula_line
            (   p_price_formula_line          => p_FORMULA_LINES_val_rec.price_formula_line
            );

            IF l_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM THEN
                l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_val_rec.price_formula_line_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_LINES_rec.formula_line_type_code <> FND_API.G_MISS_CHAR THEN

            l_FORMULA_LINES_rec.formula_line_type_code := p_FORMULA_LINES_rec.formula_line_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_LINES_rec.formula_line_type_code := QP_Value_To_Id.price_formula_line_type
            (   p_price_formula_line_type     => p_FORMULA_LINES_val_rec.price_formula_line_type
            );

            IF l_FORMULA_LINES_rec.formula_line_type_code = FND_API.G_MISS_CHAR THEN
                l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_val_rec.price_list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_LINES_rec.price_list_line_id <> FND_API.G_MISS_NUM THEN

            l_FORMULA_LINES_rec.price_list_line_id := p_FORMULA_LINES_rec.price_list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_LINES_rec.price_list_line_id := QP_Value_To_Id.price_list_line
            (   p_price_list_line             => p_FORMULA_LINES_val_rec.price_list_line
            );

            IF l_FORMULA_LINES_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
                l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_val_rec.price_modifier_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_LINES_rec.price_modifier_list_id <> FND_API.G_MISS_NUM THEN

            l_FORMULA_LINES_rec.price_modifier_list_id := p_FORMULA_LINES_rec.price_modifier_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_modifier_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_LINES_rec.price_modifier_list_id := QP_Value_To_Id.price_modifier_list
            (   p_price_modifier_list         => p_FORMULA_LINES_val_rec.price_modifier_list
            );

            IF l_FORMULA_LINES_rec.price_modifier_list_id = FND_API.G_MISS_NUM THEN
                l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


oe_debug_pub.add('Leaving proc Get_Ids in FormulaLines Util Pkg');
    RETURN l_FORMULA_LINES_rec;

END Get_Ids;

END QP_Formula_Lines_Util;

/

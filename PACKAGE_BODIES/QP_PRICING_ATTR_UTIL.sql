--------------------------------------------------------
--  DDL for Package Body QP_PRICING_ATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICING_ATTR_UTIL" AS
/* $Header: QPXUPRAB.pls 120.7.12010000.7 2009/08/19 07:30:52 smbalara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Pricing_Attr_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Clear_Dependent_Attr in QPXUPRAB');

    --  Load out record

    x_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,p_old_PRICING_ATTR_rec.accumulate_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ACCUMULATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,p_old_PRICING_ATTR_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute10,p_old_PRICING_ATTR_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute11,p_old_PRICING_ATTR_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute12,p_old_PRICING_ATTR_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute13,p_old_PRICING_ATTR_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute14,p_old_PRICING_ATTR_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute15,p_old_PRICING_ATTR_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute2,p_old_PRICING_ATTR_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute3,p_old_PRICING_ATTR_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute4,p_old_PRICING_ATTR_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute5,p_old_PRICING_ATTR_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute6,p_old_PRICING_ATTR_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute7,p_old_PRICING_ATTR_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute8,p_old_PRICING_ATTR_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute9,p_old_PRICING_ATTR_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute_grouping_no,p_old_PRICING_ATTR_rec.attribute_grouping_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE_GROUPING_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.context,p_old_PRICING_ATTR_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.created_by,p_old_PRICING_ATTR_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.creation_date,p_old_PRICING_ATTR_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,p_old_PRICING_ATTR_rec.excluder_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_EXCLUDER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_updated_by,p_old_PRICING_ATTR_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_date,p_old_PRICING_ATTR_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_login,p_old_PRICING_ATTR_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

/*included by spgopal to include list_header_id in pricing attr for performance problems*/
        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,p_old_PRICING_ATTR_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LIST_HEADER;
        END IF;

/*included by spgopal to include pricing_phase_id in pricing attr for performance problems*/
        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,p_old_PRICING_ATTR_rec.pricing_phase_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_PHASE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,p_old_PRICING_ATTR_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,p_old_PRICING_ATTR_rec.pricing_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,p_old_PRICING_ATTR_rec.pricing_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
        END IF;

/*
        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,p_old_PRICING_ATTR_rec.pricing_attribute_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE;
        END IF;
*/

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,p_old_PRICING_ATTR_rec.pricing_attr_value_from)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTR_VALUE_FROM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_to,p_old_PRICING_ATTR_rec.pricing_attr_value_to)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTR_VALUE_TO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,p_old_PRICING_ATTR_rec.product_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,p_old_PRICING_ATTR_rec.product_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,p_old_PRICING_ATTR_rec.product_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTR_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,p_old_PRICING_ATTR_rec.product_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_application_id,p_old_PRICING_ATTR_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_id,p_old_PRICING_ATTR_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_update_date,p_old_PRICING_ATTR_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.request_id,p_old_PRICING_ATTR_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype,p_old_PRICING_ATTR_rec.product_attribute_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype,p_old_PRICING_ATTR_rec.pricing_attribute_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code,p_old_PRICING_ATTR_rec.comparison_operator_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_COMPARISON_OPERATOR;
        END IF;

    ELSIF p_attr_id = G_ACCUMULATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ACCUMULATE;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_ATTRIBUTE_GROUPING_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_ATTRIBUTE_GROUPING_NO;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_EXCLUDER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_EXCLUDER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE_CONTEXT;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE;
    ELSIF p_attr_id = G_PRICING_ATTR_VALUE_FROM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTR_VALUE_FROM;
    ELSIF p_attr_id = G_PRICING_ATTR_VALUE_TO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTR_VALUE_TO;
    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE;
    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE_CONTEXT;
    ELSIF p_attr_id = G_PRODUCT_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTR_VALUE;
    ELSIF p_attr_id = G_PRODUCT_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_UOM;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_PRODUCT_ATTRIBUTE_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRODUCT_ATTRIBUTE_DATATYPE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_PRICING_ATTRIBUTE_DATATYPE;
    ELSIF p_attr_id = G_COMPARISON_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICING_ATTR_UTIL.G_COMPARISON_OPERATOR;
    END IF;

oe_debug_pub.add('END Clear_Dependent_Attr in QPXUPRAB');

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS
x_datatype         VARCHAR2(1);
x_context_flag     VARCHAR2(1);
x_attribute_flag   VARCHAR2(1);
x_value_flag       VARCHAR2(1);
x_precedence       NUMBER;
x_error_code       NUMBER := 0;
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--Bug 4706180
l_rltd_modifier_grp_type  VARCHAR2(30);

BEGIN

oe_debug_pub.add('BEGIN Apply_Attribute_Changes in QPXUPRAB');

    --  Load out record

    x_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    -- Get Product Attribute Datatype

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,
					   p_old_PRICING_ATTR_rec.product_attribute_context)
    OR NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,
					   p_old_PRICING_ATTR_rec.product_attribute)
    OR NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,
					   p_old_PRICING_ATTR_rec.product_attr_value)
    THEN

       QP_UTIL.validate_qp_flexfield(flexfield_name     =>'QP_ATTR_DEFNS_PRICING'
						 ,context    =>p_PRICING_ATTR_rec.product_attribute_context
						 ,attribute  =>p_PRICING_ATTR_rec.product_attribute
						 ,value      =>p_PRICING_ATTR_rec.product_attr_value
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>x_context_flag
						 ,attribute_flag                 =>x_attribute_flag
						 ,value_flag                     =>x_value_flag
						 ,datatype                       =>x_datatype
						 ,precedence                      =>x_precedence
						 ,error_code                     =>x_error_code
						 );

      x_PRICING_ATTR_rec.product_attribute_datatype := x_datatype;

    END IF;

    -- Get Pricing Attribute Datatype

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,
					   p_old_PRICING_ATTR_rec.pricing_attribute_context)
    OR NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,
					   p_old_PRICING_ATTR_rec.pricing_attribute)
    OR NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,
					   p_old_PRICING_ATTR_rec.pricing_attr_value_from)
    THEN

     	IF  p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME'
     	THEN

           x_PRICING_ATTR_rec.pricing_attribute_datatype := 'N';

          ELSE

       QP_UTIL.validate_qp_flexfield(flexfield_name     =>'QP_ATTR_DEFNS_PRICING'
						 ,context    =>p_PRICING_ATTR_rec.pricing_attribute_context
						 ,attribute  =>p_PRICING_ATTR_rec.pricing_attribute
						 ,value      =>p_PRICING_ATTR_rec.pricing_attr_value_from
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>x_context_flag
						 ,attribute_flag                 =>x_attribute_flag
						 ,value_flag                     =>x_value_flag
						 ,datatype                       =>x_datatype
						 ,precedence                      =>x_precedence
						 ,error_code                     =>x_error_code
						 );

                x_PRICING_ATTR_rec.pricing_attribute_datatype := x_datatype;

          END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,p_old_PRICING_ATTR_rec.accumulate_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,p_old_PRICING_ATTR_rec.attribute1)
    THEN
        NULL;
    END IF;

oe_debug_pub.add('11');
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

oe_debug_pub.add('22');
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

oe_debug_pub.add('33');
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

oe_debug_pub.add('44');
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

oe_debug_pub.add('55');
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

/*included by spgopal to include list_header_id in pricing attr for performance problems*/
    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,p_old_PRICING_ATTR_rec.list_header_id)
    THEN
    /* commented this part as it is not reqd- spgopal
		IF p_PRICING_ATTR_rec.list_header_id IS NULL OR
			p_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN

			BEGIN

			oe_debug_pub.add('list_line_id in apply gsp'||to_char(p_PRICING_ATTR_rec.list_line_id));
			select list_header_id into x_PRICING_ATTR_rec.list_header_id
				from qp_list_lines
				where list_line_id = p_PRICING_ATTR_rec.list_line_id;
			EXCEPTION
			When NO_DATA_FOUND Then
			Null;
			END;
		ELSE
			null;
		END IF;
		*/

        NULL;
    END IF;

/*included by spgopal to include pricing_phase_id in pricing attr for performance problems*/
    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,p_old_PRICING_ATTR_rec.pricing_phase_id)
    THEN
    /* commented this part as it is not reqd - spgopal
		IF p_PRICING_ATTR_rec.pricing_phase_id IS NULL OR
			p_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN

			BEGIN
			oe_debug_pub.add('list_line_id in apply gsp'||to_char(p_PRICING_ATTR_rec.list_line_id));
			select pricing_phase_id into x_PRICING_ATTR_rec.pricing_phase_id
				from qp_list_lines
				where list_line_id = p_PRICING_ATTR_rec.list_line_id;
			EXCEPTION
			When NO_DATA_FOUND Then
			Null;
			END;
		ELSE
			null;
		END IF;
		*/

        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,p_old_PRICING_ATTR_rec.list_line_id)
    THEN
               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,p_old_PRICING_ATTR_rec.pricing_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,p_old_PRICING_ATTR_rec.pricing_attribute_context)
    THEN
       -- mkarya for bug 1789276, log the request for a change in pricing_attribute_context
               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,p_old_PRICING_ATTR_rec.pricing_attribute_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_from,p_old_PRICING_ATTR_rec.pricing_attr_value_from)
    THEN

       --Fetch modfier group type (Bug 4706180) Start
       BEGIN
         SELECT RLTD_MODIFIER_GRP_TYPE
         INTO   l_rltd_modifier_grp_type
         FROM   qp_rltd_modifiers rm
         WHERE  rm.TO_RLTD_MODIFIER_ID = p_PRICING_ATTR_rec.list_line_id;
       EXCEPTION
         WHEN OTHERS THEN
          l_rltd_modifier_grp_type := '';
       END;
       --End
		--changes made for bug 1566429
		--for recurring breaks defaulting the value_to to a large number
		IF p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME'
		   AND p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
		   AND p_PRICING_ATTR_rec.comparison_operator_code = 'BETWEEN'
		   AND p_PRICING_ATTR_rec.pricing_attr_value_to IS NULL
            	   -- Bug 4706180
           	   AND l_rltd_modifier_grp_type = 'PRICE BREAK'
		THEN
		   -- Bug 4706180
		   x_PRICING_ATTR_rec.pricing_attr_value_to := '999999999999999';
		END IF;
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attr_value_to,p_old_PRICING_ATTR_rec.pricing_attr_value_to)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute,p_old_PRICING_ATTR_rec.product_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_context,p_old_PRICING_ATTR_rec.product_attribute_context)
    THEN
       -- mkarya for bug 1789276, log the request for a change in product_attribute_context
               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attr_value,p_old_PRICING_ATTR_rec.product_attr_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_uom_code,p_old_PRICING_ATTR_rec.product_uom_code)
    THEN

    -- for updating price breaks rassharm bug no 7315129
 	         IF p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
 	         THEN
 	           UPDATE qp_pricing_attributes
 	           SET product_uom_code = p_PRICING_ATTR_rec.product_uom_code
 	           WHERE list_line_id = p_PRICING_ATTR_rec.list_line_id;

 	           -- for updating price breaks rassharm bug no 7315129

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
       -- NULL;
--pattern
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
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
	END IF; --Java Engine Installed
--pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' THEN
         IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
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

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype,p_old_PRICING_ATTR_rec.product_attribute_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype,p_old_PRICING_ATTR_rec.pricing_attribute_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code,p_old_PRICING_ATTR_rec.comparison_operator_code)
    THEN
        NULL;
    END IF;

oe_debug_pub.add('END Apply_Attribute_Changes in QPXUPRAB');

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
BEGIN

oe_debug_pub.add('BEGIN Complete_Record in QPXUPRAB');

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

/*included by spgopal to include list_header_id in pricing attr for performance problems*/
    IF l_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_header_id := p_old_PRICING_ATTR_rec.list_header_id;
    END IF;

/*included by spgopal to include pricing_phase_id in pricing attr for performance problems*/
    IF l_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_phase_id := p_old_PRICING_ATTR_rec.pricing_phase_id;
    END IF;

    IF l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_line_id := p_old_PRICING_ATTR_rec.list_line_id;
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

    IF l_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute_datatype := p_old_PRICING_ATTR_rec.product_attribute_datatype;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute_datatype := p_old_PRICING_ATTR_rec.pricing_attribute_datatype;
    END IF;

    IF l_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.comparison_operator_code := p_old_PRICING_ATTR_rec.comparison_operator_code;
    END IF;

oe_debug_pub.add('END Complete_Record in QPXUPRAB');

    RETURN l_PRICING_ATTR_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
BEGIN

oe_debug_pub.add('BEGIN Convert_Miss_To_Null in QPXUPRAB');

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

/*included by spgopal to include list_header_id in pricing attr for performance problems*/
    IF l_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_header_id := NULL;
    END IF;

/*included by spgopal to include pricing_phase_id in pricing attr for performance problems*/
    IF l_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.pricing_phase_id := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICING_ATTR_rec.list_line_id := NULL;
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

    IF l_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.product_attribute_datatype := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.pricing_attribute_datatype := NULL;
    END IF;

    IF l_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_PRICING_ATTR_rec.comparison_operator_code := NULL;
    END IF;

oe_debug_pub.add('END Convert_Miss_To_Null in QPXUPRAB');

    RETURN l_PRICING_ATTR_rec;

END Convert_Miss_To_Null;


----------------------------------------------------------------------------
--PRIVATE PROCEDURE UPDATE CHILD PRICING ATTR TO UPDATE
--CHILD BREAK LINES' PRICING ATTRIBUTE RECORDS
----------------------------------------------------------------------------


PROCEDURE UPDATE_CHILD_PRICING_ATTR(p_PRICING_ATTR_rec IN QP_MODIFIERS_PUB.Pricing_Attr_rec_type) IS

l_status  NUMBER;
l_list_line_id NUMBER;
l_list_line_type_code VARCHAR2(30);
l_Pricing_Attr_rec QP_PRICING_ATTRIBUTES%rowtype;

Cursor C_child_records(l_list_line_id  number) IS
			 SELECT *
			 FROM   QP_PRICING_ATTRIBUTES qll
			 WHERE qll.list_line_id IN (select
			 to_rltd_modifier_id from
			 qp_rltd_modifiers qrm where from_rltd_modifier_id
				 = l_list_line_id);

BEGIN

	l_list_line_id := p_Pricing_Attr_rec.list_line_id;


	select list_line_type_code into l_list_line_type_code
	from qp_list_lines where
			list_line_id = l_list_line_id;

	IF l_list_line_type_code = 'PBH' THEN

	--l_modifier_grp_type := 'PRICE BREAK';

	--updating all child break pricing_attributes

   		open C_child_records(l_list_line_id); LOOP
   		fetch C_child_records into l_Pricing_Attr_rec;

   		EXIT WHEN C_child_records%NOTFOUND;



	  	update qp_Pricing_Attributes set
		 Product_attribute_context =
				p_Pricing_Attr_rec.Product_attribute_context
    		,Product_attribute 	   =
				p_Pricing_Attr_rec.Product_attribute
    		,Product_attr_value 	   =
				p_Pricing_Attr_rec.Product_attr_value
    		,Pricing_Attribute_context =
				p_Pricing_Attr_rec.Pricing_Attribute_context
    		,Pricing_Attribute	   =
				p_Pricing_Attr_rec.Pricing_Attribute
		where list_line_id = l_Pricing_Attr_rec.list_line_id;

    		END LOOP;

   		close C_child_records;
/*
	--No need to update pricing attr for OID and PRG as nothing is defaulted
	ELSIF l_list_line_type_code  IN ( 'OID','PRG') THEN

--		l_modifier_grp_type := '('BENEFIT', 'QUALIFIER')';



	--update OID child records

   		open C_child_records(l_list_line_id); LOOP
   		fetch C_child_records into l_Pricing_Attr_rec;

   		EXIT WHEN C_child_records%NOTFOUND;

			--get or related records


	  		update qp_list_lines set
		 		list_line_no 			= p_Pricing_Attr_rec.list_line_no
    				,modifier_level_code 	= p_Pricing_Attr_rec.modifier_level_code
    				,automatic_flag 		= p_Pricing_Attr_rec.automatic_flag
    				,override_flag 		= p_Pricing_Attr_rec.override_flag
    				,Print_on_invoice_flag 	= p_Pricing_Attr_rec.Print_on_invoice_flag
    				,price_break_type_code 	= p_Pricing_Attr_rec.price_break_type_code
    				,Proration_type_code 	= p_Pricing_Attr_rec.Proration_type_code
    				,Incompatibility_Grp_code= p_Pricing_Attr_rec.Incompatibility_Grp_code
    				,Pricing_group_sequence 	= p_Pricing_Attr_rec.Pricing_group_sequence
    				,accrual_flag 			= p_Pricing_Attr_rec.accrual_flag
    				,estim_accrual_rate 	= p_Pricing_Attr_rec.estim_accrual_rate
    				,rebate_transaction_type_code	= p_Pricing_Attr_rec.rebate_trxn_type_code
    				,expiration_date			= p_Pricing_Attr_rec.expiration_date
    				,expiration_period_start_date	= p_Pricing_Attr_rec.expiration_period_start_date
    				,expiration_period_uom		= p_Pricing_Attr_rec.expiration_period_uom
    				,number_expiration_periods	= p_Pricing_Attr_rec.number_expiration_periods

    				where list_line_id = l_Pricing_Attr_rec.list_line_id;





    		END LOOP;

   		close C_child_records;
*/

	ELSE

	null;

	END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Child_Pricing_Attr'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;





END UPDATE_CHILD_PRICING_ATTR;














----------------------------------------------------------------------------


--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS

l_list_line_type_code VARCHAR2(30);
l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_rltd_modifier_grp_type  VARCHAR2(30);
l_pricing_attr_value_to p_Pricing_Attr_rec.pricing_attr_value_to%TYPE;

BEGIN

--Fetch modfier group type (Bug 5465263) Start
       BEGIN
         SELECT RLTD_MODIFIER_GRP_TYPE
         INTO   l_rltd_modifier_grp_type
         FROM   qp_rltd_modifiers rm
         WHERE  rm.TO_RLTD_MODIFIER_ID = p_PRICING_ATTR_rec.list_line_id;
       EXCEPTION
         WHEN OTHERS THEN
          l_rltd_modifier_grp_type := '';
       END;

--If Price Break value to is null and value from is not (the last price break) set
        --value to 999..99 (15 digit) to incorporate infinite values
        IF(p_Pricing_Attr_rec.pricing_attr_value_to IS NULL
        AND p_Pricing_Attr_rec.pricing_attr_value_from IS NOT NULL
        AND l_rltd_modifier_grp_type = 'PRICE BREAK'
	AND p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME')
        THEN
           l_pricing_attr_value_to := '999999999999999';
        ELSE
            l_pricing_attr_value_to := p_Pricing_Attr_rec.pricing_attr_value_to;
        END IF;

--End Bug 5465263

SELECT lh.ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B lh, QP_LIST_LINES ll
       WHERE  lh.LIST_HEADER_ID = ll.LIST_HEADER_ID and ll.LIST_LINE_ID = p_PRICING_ATTR_rec.list_line_id and rownum = 1;

oe_debug_pub.add('BEGIN Update_Row in QPXUPRAB');

    IF p_PRICING_ATTR_rec.pricing_attribute_datatype = 'N'
    then

    BEGIN

	    l_pric_attr_value_from_number :=
	    qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_from);

	    l_pric_attr_value_to_number :=
	    qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;

/*changes by spgopal to include list_header_id ,pricing_phase_id in pricing attr for performance problems*/

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
    ,       PRICING_ATTRIBUTE              = p_PRICING_ATTR_rec.pricing_attribute
    ,       PRICING_ATTRIBUTE_CONTEXT      = p_PRICING_ATTR_rec.pricing_attribute_context
    ,       PRICING_ATTRIBUTE_ID           = p_PRICING_ATTR_rec.pricing_attribute_id
    ,       PRICING_ATTR_VALUE_FROM        = p_PRICING_ATTR_rec.pricing_attr_value_from
    ,       PRICING_ATTR_VALUE_TO          = l_pricing_attr_value_to
    ,       PRODUCT_ATTRIBUTE              = p_PRICING_ATTR_rec.product_attribute
    ,       PRODUCT_ATTRIBUTE_CONTEXT      = p_PRICING_ATTR_rec.product_attribute_context
    ,       PRODUCT_ATTR_VALUE             = p_PRICING_ATTR_rec.product_attr_value
    ,       PRODUCT_UOM_CODE               = p_PRICING_ATTR_rec.product_uom_code
    ,       PROGRAM_APPLICATION_ID         = p_PRICING_ATTR_rec.program_application_id
    ,       PROGRAM_ID                     = p_PRICING_ATTR_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PRICING_ATTR_rec.program_update_date
    ,       REQUEST_ID                     = p_PRICING_ATTR_rec.request_id
    ,       PRODUCT_ATTRIBUTE_DATATYPE     = p_PRICING_ATTR_rec.product_attribute_datatype
    ,       PRICING_ATTRIBUTE_DATATYPE     = p_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       COMPARISON_OPERATOR_CODE       = p_PRICING_ATTR_rec.comparison_operator_code
    ,       LIST_HEADER_ID       		   = p_PRICING_ATTR_rec.list_header_id
    ,       PRICING_PHASE_ID       	   = p_PRICING_ATTR_rec.pricing_phase_id
    ,       PRICING_ATTR_VALUE_FROM_NUMBER = l_pric_attr_value_from_number
    ,       PRICING_ATTR_VALUE_TO_NUMBER   = l_pric_attr_value_to_number
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
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
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
       AND b.prc_context_type = 'PRODUCT'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.product_attribute_context);

END IF;
END IF;
--to update child break lines' priceing attribute records
    update_child_pricing_attr(p_PRICING_ATTR_rec);

    --Fetch list line type code
    BEGIN
      SELECT list_line_type_code
      INTO   l_list_line_type_code
      FROM   qp_list_lines
      WHERE  list_line_id = p_PRICING_ATTR_rec.list_line_id;
    EXCEPTION
      WHEN OTHERS THEN
       l_list_line_type_code := '';
    END;

    --Log delayed request to maintain denormalized pricing attrs columns only
    --for formula factor attrs
    IF l_list_line_type_code = 'PMR' THEN
      qp_delayed_requests_PVT.log_request(
	    p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	    p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
	    p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Modifiers,
	    p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
	    p_request_type =>QP_GLOBALS.G_MAINTAIN_FACTOR_LIST_ATTRS,
	    x_return_status => l_return_status);
    END IF;

oe_debug_pub.add('END Update_Row in QPXUPRAB');

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
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;
l_return_status 			VARCHAR2(1);
l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;
l_list_line_type_code         VARCHAR2(30);
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_pricing_attr_value_to p_Pricing_Attr_rec.pricing_attr_value_to%TYPE;
--Bug 4706180
l_rltd_modifier_grp_type  VARCHAR2(30);
BEGIN


oe_debug_pub.add('SMITHA LIST_HEADER_ID'||p_PRICING_ATTR_rec.list_header_id);

       --Fetch modfier group type (Bug 4706180) Start
       BEGIN
         SELECT RLTD_MODIFIER_GRP_TYPE
         INTO   l_rltd_modifier_grp_type
         FROM   qp_rltd_modifiers rm
         WHERE  rm.TO_RLTD_MODIFIER_ID = p_PRICING_ATTR_rec.list_line_id;
       EXCEPTION
         WHEN OTHERS THEN
          l_rltd_modifier_grp_type := '';
       END;
       --End

 IF  p_PRICING_ATTR_rec.list_header_id IS NOT NULL THEN
    SELECT ACTIVE_FLAG
          INTO   l_active_flag
          FROM   QP_LIST_HEADERS_B
          WHERE  LIST_HEADER_ID = p_PRICING_ATTR_rec.list_header_id;

  ELSE

    SELECT ACTIVE_FLAG
           INTO   l_active_flag
           FROM   QP_LIST_HEADERS_B a,QP_LIST_LINES b
           WHERE  b.list_line_id=p_PRICING_ATTR_rec.list_line_id
           AND    b.LIST_HEADER_ID = a.list_header_id;
END IF;
oe_debug_pub.add('BEGIN Insert_Row in QPXUPRAB');
oe_debug_pub.add(p_PRICING_ATTR_rec.attribute_grouping_no);
oe_debug_pub.add(p_PRICING_ATTR_rec.product_attribute_context);
oe_debug_pub.add(p_PRICING_ATTR_rec.product_attribute);
oe_debug_pub.add(p_PRICING_ATTR_rec.pricing_attribute);
oe_debug_pub.add(p_PRICING_ATTR_rec.excluder_flag);

	--If Price Break value to is null and value from is not (the last price break) set
	--value to 999..99 (15 digit) to incorporate infinite values
        IF(p_Pricing_Attr_rec.pricing_attr_value_to IS NULL
        AND p_Pricing_Attr_rec.pricing_attr_value_from IS NOT NULL
        -- Bug 4706180
        AND l_rltd_modifier_grp_type = 'PRICE BREAK')
        THEN
            l_pricing_attr_value_to := '999999999999999';
        ELSE
            l_pricing_attr_value_to := p_Pricing_Attr_rec.pricing_attr_value_to;
        END IF;

    IF p_PRICING_ATTR_rec.pricing_attribute_datatype = 'N'
    then

    BEGIN

	    l_pric_attr_value_from_number :=
	    qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_from);

	    l_pric_attr_value_to_number :=
	    qp_number.canonical_to_number(p_PRICING_ATTR_rec.pricing_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;

/*changs by spgopal to include list_header_id ,pricing_phase_id in pricing attr for performance problems*/

    INSERT  INTO QP_PRICING_ATTRIBUTES
    (
    --ACCUMULATE_FLAG
           ATTRIBUTE1
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
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       COMPARISON_OPERATOR_CODE
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    )
    VALUES
    (
    --p_PRICING_ATTR_rec.accumulate_flag
           p_PRICING_ATTR_rec.attribute1
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
    ,       p_PRICING_ATTR_rec.pricing_attribute
    ,       p_PRICING_ATTR_rec.pricing_attribute_context
    ,       p_PRICING_ATTR_rec.pricing_attribute_id
    ,       p_PRICING_ATTR_rec.pricing_attr_value_from
    ,       l_pricing_attr_value_to
    ,       p_PRICING_ATTR_rec.product_attribute
    ,       p_PRICING_ATTR_rec.product_attribute_context
    ,       p_PRICING_ATTR_rec.product_attr_value
    ,       p_PRICING_ATTR_rec.product_uom_code
    ,       p_PRICING_ATTR_rec.program_application_id
    ,       p_PRICING_ATTR_rec.program_id
    ,       p_PRICING_ATTR_rec.program_update_date
    ,       p_PRICING_ATTR_rec.request_id
    ,       p_PRICING_ATTR_rec.product_attribute_datatype
    ,       p_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       p_PRICING_ATTR_rec.comparison_operator_code
    ,       p_PRICING_ATTR_rec.list_header_id
    ,       p_PRICING_ATTR_rec.pricing_phase_id
    ,       l_pric_attr_value_from_number
    ,       l_pric_attr_value_to_number
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
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
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
       AND b.prc_context_type = 'PRODUCT'
       AND    b.prc_context_code=p_PRICING_ATTR_rec.product_attribute_context);

END IF;
END IF;
	qp_delayed_requests_PVT.log_request(
			 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			 p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
			 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Modifiers,
			 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
			 p_request_type =>QP_GLOBALS.G_UPDATE_PRICING_ATTR_PHASE,
			 x_return_status => l_return_status);

       --Fetch list line type code (Bug 4706180)
       BEGIN
         SELECT list_line_type_code
         INTO   l_list_line_type_code
         FROM   qp_list_lines
         WHERE  list_line_id = p_PRICING_ATTR_rec.list_line_id;
       EXCEPTION
         WHEN OTHERS THEN
          l_list_line_type_code := '';
       END;


       --Log delayed request to maintain denormalized pricing attrs columns
       --only for formula factor attrs
       IF l_list_line_type_code = 'PMR' THEN
         qp_delayed_requests_PVT.log_request(
	    p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	    p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
	    p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Modifiers,
	    p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
	    p_request_type =>QP_GLOBALS.G_MAINTAIN_FACTOR_LIST_ATTRS,
	    x_return_status => l_return_status);
       END IF;

oe_debug_pub.add('END Insert_Row in QPXUPRAB');

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
(   p_pricing_attribute_id          IN  NUMBER
)
IS
l_list_line_id  NUMBER;
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
oe_debug_pub.add('BEGIN Delete_Row in QPXUPRAB');


    DELETE  FROM QP_PRICING_ATTRIBUTES
    WHERE   PRICING_ATTRIBUTE_ID = p_pricing_attribute_id
    RETURNING  LIST_LINE_ID INTO l_list_line_id
    ;

    qp_delayed_requests_PVT.log_request(
	    p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	    p_entity_id  => l_list_line_id,
	    p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Modifiers,
	    p_requesting_entity_id => l_list_line_id,
	    p_request_type =>QP_GLOBALS.G_MAINTAIN_FACTOR_LIST_ATTRS,
	    x_return_status => l_return_status);

oe_debug_pub.add('END Delete_Row in QPXUPRAB');
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
(   p_pricing_attribute_id          IN  NUMBER
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type
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
) RETURN QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;

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
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       COMPARISON_OPERATOR_CODE
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,	  QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE ( PRICING_ATTRIBUTE_ID = p_pricing_attribute_id
    )
    OR (    LIST_LINE_ID = p_list_line_id
    );

BEGIN

oe_debug_pub.add('BEGIN Query_rows in QPXUPRAB');

    IF
    (p_pricing_attribute_id IS NOT NULL
     AND
     p_pricing_attribute_id <> FND_API.G_MISS_NUM)
    AND
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
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
        l_PRICING_ATTR_rec.product_attribute_datatype := l_implicit_rec.PRODUCT_ATTRIBUTE_DATATYPE;
        l_PRICING_ATTR_rec.pricing_attribute_datatype := l_implicit_rec.PRICING_ATTRIBUTE_DATATYPE;
        l_PRICING_ATTR_rec.comparison_operator_code := l_implicit_rec.COMPARISON_OPERATOR_CODE;
        l_PRICING_ATTR_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_PRICING_ATTR_rec.pricing_phase_id := l_implicit_rec.PRICING_PHASE_ID;
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


oe_debug_pub.add('END Query_rows in QPXUPRAB');

    --  Return fetched table

    RETURN l_PRICING_ATTR_tbl;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    NULL;

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
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Lock_row in QPXUPRAB');

    SELECT
    --ACCUMULATE_FLAG
           ATTRIBUTE1
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
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       COMPARISON_OPERATOR_CODE
--    ,       LIST_HEADER_ID
--    ,       PRICING_PHASE_ID
    INTO
    --l_PRICING_ATTR_rec.accumulate_flag
           l_PRICING_ATTR_rec.attribute1
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
    ,       l_PRICING_ATTR_rec.product_attribute_datatype
    ,       l_PRICING_ATTR_rec.pricing_attribute_datatype
    ,       l_PRICING_ATTR_rec.comparison_operator_code
--    ,       l_PRICING_ATTR_rec.list_header_id
--    ,       l_PRICING_ATTR_rec.pricing_phase_id
    FROM    QP_PRICING_ATTRIBUTES
    WHERE   PRICING_ATTRIBUTE_ID = p_PRICING_ATTR_rec.pricing_attribute_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF
    --QP_GLOBALS.Equal(p_PRICING_ATTR_rec.accumulate_flag,
    --                     l_PRICING_ATTR_rec.accumulate_flag)
    --AND
    /*
    QP_GLOBALS.Equal(p_PRICING_ATTR_rec.attribute1,
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
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.created_by,
                         l_PRICING_ATTR_rec.created_by)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.creation_date,
--                         l_PRICING_ATTR_rec.creation_date)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.excluder_flag,
                         l_PRICING_ATTR_rec.excluder_flag)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_updated_by,
                         l_PRICING_ATTR_rec.last_updated_by)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_date,
--                         l_PRICING_ATTR_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.last_update_login,
                         l_PRICING_ATTR_rec.last_update_login)
					*/
    --AND
    QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_line_id,
                         l_PRICING_ATTR_rec.list_line_id)
					/*
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute,
                         l_PRICING_ATTR_rec.pricing_attribute)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_context,
                         l_PRICING_ATTR_rec.pricing_attribute_context)
					*/
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_id,
                         l_PRICING_ATTR_rec.pricing_attribute_id)
					/*
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
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_application_id,
                         l_PRICING_ATTR_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_id,
                         l_PRICING_ATTR_rec.program_id)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.program_update_date,
--                         l_PRICING_ATTR_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.request_id,
                         l_PRICING_ATTR_rec.request_id)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.product_attribute_datatype,
--                         l_PRICING_ATTR_rec.product_attribute_datatype)
--    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_attribute_datatype,
--                         l_PRICING_ATTR_rec.pricing_attribute_datatype)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.comparison_operator_code,
                         l_PRICING_ATTR_rec.comparison_operator_code)
					*/
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,
                         l_PRICING_ATTR_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,
                         l_PRICING_ATTR_rec.pricing_phase_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_PRICING_ATTR_rec             := l_PRICING_ATTR_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
	--8594682 -added debug messages for oe_lock_row issue
	oe_debug_pub.ADD('-------------------data compare in pricing attr line (database vs record)------------------');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute1                  :'||l_PRICING_ATTR_rec.attribute1||':'||p_PRICING_ATTR_rec.attribute1||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute10                 :'||l_PRICING_ATTR_rec.attribute10||':'||p_PRICING_ATTR_rec.attribute10||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute11                 :'||l_PRICING_ATTR_rec.attribute11||':'||p_PRICING_ATTR_rec.attribute11||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute12                 :'||l_PRICING_ATTR_rec.attribute12||':'||p_PRICING_ATTR_rec.attribute12||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute13                 :'||l_PRICING_ATTR_rec.attribute13||':'||p_PRICING_ATTR_rec.attribute13||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute14                 :'||l_PRICING_ATTR_rec.attribute14||':'||p_PRICING_ATTR_rec.attribute14||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute15                 :'||l_PRICING_ATTR_rec.attribute15||':'||p_PRICING_ATTR_rec.attribute15||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute2                  :'||l_PRICING_ATTR_rec.attribute2||':'||p_PRICING_ATTR_rec.attribute2||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute3                  :'||l_PRICING_ATTR_rec.attribute3||':'||p_PRICING_ATTR_rec.attribute3||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute4                  :'||l_PRICING_ATTR_rec.attribute4||':'||p_PRICING_ATTR_rec.attribute4||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute5                  :'||l_PRICING_ATTR_rec.attribute5||':'||p_PRICING_ATTR_rec.attribute5||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute6                  :'||l_PRICING_ATTR_rec.attribute6||':'||p_PRICING_ATTR_rec.attribute6||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute7                  :'||l_PRICING_ATTR_rec.attribute7||':'||p_PRICING_ATTR_rec.attribute7||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute8                  :'||l_PRICING_ATTR_rec.attribute8||':'||p_PRICING_ATTR_rec.attribute8||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute9                  :'||l_PRICING_ATTR_rec.attribute9||':'||p_PRICING_ATTR_rec.attribute9||':');
	oe_debug_pub.add('PRICING_ATTR_rec.attribute_grouping_no       :'||l_PRICING_ATTR_rec.attribute_grouping_no||':'||p_PRICING_ATTR_rec.attribute_grouping_no||':');
	oe_debug_pub.add('PRICING_ATTR_rec.context                     :'||l_PRICING_ATTR_rec.context||':'|| p_PRICING_ATTR_rec.context||':');
	oe_debug_pub.add('PRICING_ATTR_rec.created_by                  :'||l_PRICING_ATTR_rec.created_by||':'||p_PRICING_ATTR_rec.created_by||':');
	oe_debug_pub.add('PRICING_ATTR_rec.creation_date               :'||l_PRICING_ATTR_rec.creation_date||':'||p_PRICING_ATTR_rec.creation_date||':');
	oe_debug_pub.add('PRICING_ATTR_rec.excluder_flag               :'||l_PRICING_ATTR_rec.excluder_flag||':'||p_PRICING_ATTR_rec.excluder_flag||':');
	oe_debug_pub.add('PRICING_ATTR_rec.last_updated_by             :'||l_PRICING_ATTR_rec.last_updated_by||':'||p_PRICING_ATTR_rec.last_updated_by||':');
	oe_debug_pub.add('PRICING_ATTR_rec.last_update_date            :'||l_PRICING_ATTR_rec.last_update_date||':'||p_PRICING_ATTR_rec.last_update_date||':');
	oe_debug_pub.add('PRICING_ATTR_rec.last_update_login           :'||l_PRICING_ATTR_rec.last_update_login||':'||p_PRICING_ATTR_rec.last_update_login||':');
	oe_debug_pub.add('PRICING_ATTR_rec.list_line_id                :'||l_PRICING_ATTR_rec.list_line_id||':'||p_PRICING_ATTR_rec.list_line_id||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attribute           :'||l_PRICING_ATTR_rec.pricing_attribute||':'||p_PRICING_ATTR_rec.pricing_attribute||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attribute_context   :'||l_PRICING_ATTR_rec.pricing_attribute_context||':'||p_PRICING_ATTR_rec.pricing_attribute_context||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attribute_id        :'||l_PRICING_ATTR_rec.pricing_attribute_id||':'||p_PRICING_ATTR_rec.pricing_attribute_id||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attr_value_from     :'||l_PRICING_ATTR_rec.pricing_attr_value_from||':'||p_PRICING_ATTR_rec.pricing_attr_value_from||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attr_value_to       :'||l_PRICING_ATTR_rec.pricing_attr_value_to||':'||p_PRICING_ATTR_rec.pricing_attr_value_to||':');
	oe_debug_pub.add('PRICING_ATTR_rec.product_attribute           :'||l_PRICING_ATTR_rec.product_attribute||':'||p_PRICING_ATTR_rec.product_attribute||':');
	oe_debug_pub.add('PRICING_ATTR_rec.product_attribute_context   :'||l_PRICING_ATTR_rec.product_attribute_context||':'||p_PRICING_ATTR_rec.product_attribute_context||':');
	oe_debug_pub.add('PRICING_ATTR_rec.product_attr_value          :'||l_PRICING_ATTR_rec.product_attr_value||':'||p_PRICING_ATTR_rec.product_attr_value||':');
	oe_debug_pub.add('PRICING_ATTR_rec.product_uom_code            :'||l_PRICING_ATTR_rec.product_uom_code||':'||p_PRICING_ATTR_rec.product_uom_code||':');
	oe_debug_pub.add('PRICING_ATTR_rec.program_application_id      :'||l_PRICING_ATTR_rec.program_application_id||':'||p_PRICING_ATTR_rec.program_application_id||':');
	oe_debug_pub.add('PRICING_ATTR_rec.program_id                  :'||l_PRICING_ATTR_rec.program_id||':'||p_PRICING_ATTR_rec.program_id||':');
	oe_debug_pub.add('PRICING_ATTR_rec.program_update_date         :'||l_PRICING_ATTR_rec.program_update_date||':'||p_PRICING_ATTR_rec.program_update_date||':');
	oe_debug_pub.add('PRICING_ATTR_rec.request_id                  :'||l_PRICING_ATTR_rec.request_id||':'||p_PRICING_ATTR_rec.request_id||':');
	oe_debug_pub.add('PRICING_ATTR_rec.product_attribute_datatype  :'||l_PRICING_ATTR_rec.product_attribute_datatype||':'||p_PRICING_ATTR_rec.product_attribute_datatype||':');
	oe_debug_pub.add('PRICING_ATTR_rec.pricing_attribute_datatype  :'||l_PRICING_ATTR_rec.pricing_attribute_datatype||':'||p_PRICING_ATTR_rec.pricing_attribute_datatype||':');
	oe_debug_pub.add('PRICING_ATTR_rec.comparison_operator_code    :'||l_PRICING_ATTR_rec.comparison_operator_code||':'||p_PRICING_ATTR_rec.comparison_operator_code||':');
	oe_debug_pub.ADD('-------------------data compare in pricing attr line end------------------');

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

oe_debug_pub.add('END Lock_row in QPXUPRAB');

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
) RETURN QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type
IS
l_PRICING_ATTR_val_rec        QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Get_Values in QPXUPRAB');

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

/*changes made by spgopal to include list_header_id and pricing_phase_id in pricing attr for performance problem*/
    IF p_PRICING_ATTR_rec.list_header_id IS NOT NULL AND
        p_PRICING_ATTR_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.list_header_id,
        p_old_PRICING_ATTR_rec.list_header_id)
    THEN
    --    l_PRICING_ATTR_val_rec.list_Header := QP_Id_To_Value.List_Header(   p_list_header_id                => p_PRICING_ATTR_rec.list_header_id);
	   null;
    END IF;

    IF p_PRICING_ATTR_rec.pricing_phase_id IS NOT NULL AND
        p_PRICING_ATTR_rec.pricing_phase_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICING_ATTR_rec.pricing_phase_id,
        p_old_PRICING_ATTR_rec.pricing_phase_id)
    THEN
--        l_PRICING_ATTR_val_rec.pricing_phase := QP_Id_To_Value.pricing_phase(   p_pricing_phase_id                => p_PRICING_ATTR_rec.pricing_phase_id);
	   null;
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

oe_debug_pub.add('END Get_Values in QPXUPRAB');

    RETURN l_PRICING_ATTR_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_PRICING_ATTR_val_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Get_Ids in QPXUPRAB');

    --  initialize  return_status.

    l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICING_ATTR_rec.

    l_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    IF  p_PRICING_ATTR_val_rec.accumulate <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.accumulate_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICING_ATTR_rec.accumulate_flag := p_PRICING_ATTR_rec.accumulate_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accumulate');
                OE_MSG_PUB.Add;

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

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
                OE_MSG_PUB.Add;

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

/*changes made by spgopal included pricing_phase_id and list_header_id to fix performance problem*/
    IF  p_PRICING_ATTR_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_PRICING_ATTR_rec.list_header_id := p_PRICING_ATTR_rec.list_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICING_ATTR_rec.list_header_id := QP_Value_To_Id.list_header(   p_list_header                   => p_PRICING_ATTR_val_rec.list_header);

            IF l_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_val_rec.pricing_phase <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.pricing_phase_id <> FND_API.G_MISS_NUM THEN

            l_PRICING_ATTR_rec.pricing_phase_id := p_PRICING_ATTR_rec.pricing_phase_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_phase');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

--            l_PRICING_ATTR_rec.pricing_phase_id := QP_Value_To_Id.pricing_phase(   p_list_line                   => p_PRICING_ATTR_val_rec.pricing_phase);
null;

            IF l_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
                l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

-----
    IF  p_PRICING_ATTR_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICING_ATTR_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_PRICING_ATTR_rec.list_line_id := p_PRICING_ATTR_rec.list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                OE_MSG_PUB.Add;

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

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_uom');
                OE_MSG_PUB.Add;

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

oe_debug_pub.add('END Get_Ids in QPXUPRAB');

    RETURN l_PRICING_ATTR_rec;

END Get_Ids;

Procedure Pre_Write_Process
(   p_PRICING_ATTR_rec                      IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec                  IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
						QP_Modifiers_PUB.G_MISS_Pricing_Attr_REC
,   x_PRICING_ATTR_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
) IS
l_PRICING_ATTR_rec              QP_MODIFIERS_PUB.Pricing_Attr_Rec_Type := p_PRICING_ATTR_rec;
l_return_status         varchar2(30);
l_changed_lines			varchar2(1) := null;
l_list_header_id                number;

BEGIN

  oe_debug_pub.Add('Entering QP_PRICING_ATTR_Util.pre_write_process', 1);
  -- mkarya for pattern - get the list_header_id as it is not populated yet in the record
  -- added for bug No 3384576 in discussion with mkarya

  IF l_PRICING_ATTR_rec.list_header_id IS NOT NULL THEN
  l_list_header_id := l_PRICING_ATTR_rec.list_header_id;
   ELSE

  select list_header_id
    into l_list_header_id
    from qp_list_lines
   where list_line_id = l_PRICING_ATTR_rec.list_line_id;

   END IF;

  x_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
  x_PRICING_ATTR_rec.list_header_id := l_list_header_id;

  IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN

    oe_debug_pub.add('Logging a request to update qualification_ind  ', 1);

	--hw
	-- delayed request for changed lines
	if QP_PERF_PVT.enabled = 'Y' then
	begin
	select 'Y' into l_changed_lines
		from qp_rltd_modifiers
		where to_rltd_modifier_id = p_PRICING_ATTR_rec.list_line_id
		and rltd_modifier_grp_type in ('BENEFIT', 'QUALIFIER');
	exception
		when no_data_found then
			l_changed_lines := 'N';
		when others then
			l_changed_lines := 'N';
	end;

	if l_changed_lines = 'Y' then
	 		qp_delayed_requests_pvt.log_request(
	          	p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
	       	  	p_entity_id => p_PRICING_ATTR_rec.list_line_id,
	          	p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
               	p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
	          	p_request_type => QP_GLOBALS.G_UPDATE_CHANGED_LINES_DEL,
	       	  	p_param1 => p_PRICING_ATTR_rec.pricing_phase_id,
	       	  	p_param2 => p_PRICING_ATTR_rec.list_header_id,
	       	  	p_param3 => p_PRICING_ATTR_rec.product_attribute,
	       	  	p_param4 => p_PRICING_ATTR_rec.product_attr_value,
	          	x_return_status => l_return_status);
	end if;
	end if;


         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         	 p_entity_id  => p_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
  END IF;
-- pattern
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => l_list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => l_list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);

     END IF;
     IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
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
     IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN
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
   IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' THEN
     IF (p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => l_list_header_id,
		p_request_unique_key1 => p_PRICING_ATTR_rec.list_line_id,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => l_list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);

     END IF;
     IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
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
     IF   ( p_PRICING_ATTR_rec.operation = OE_GLOBALS.G_OPR_DELETE) THEN
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
 END IF; -- Java Engine Installed

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

END QP_Pricing_Attr_Util;

/

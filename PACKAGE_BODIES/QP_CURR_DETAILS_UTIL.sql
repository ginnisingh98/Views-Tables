--------------------------------------------------------
--  DDL for Package Body QP_CURR_DETAILS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CURR_DETAILS_UTIL" AS
/* $Header: QPXUCDTB.pls 120.1.12010000.2 2008/10/19 08:40:54 hmohamme ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Curr_Details_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute1,p_old_CURR_DETAILS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute10,p_old_CURR_DETAILS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute11,p_old_CURR_DETAILS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute12,p_old_CURR_DETAILS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute13,p_old_CURR_DETAILS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute14,p_old_CURR_DETAILS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute15,p_old_CURR_DETAILS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute2,p_old_CURR_DETAILS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute3,p_old_CURR_DETAILS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute4,p_old_CURR_DETAILS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute5,p_old_CURR_DETAILS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute6,p_old_CURR_DETAILS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute7,p_old_CURR_DETAILS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute8,p_old_CURR_DETAILS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute9,p_old_CURR_DETAILS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.context,p_old_CURR_DETAILS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date,p_old_CURR_DETAILS_rec.conversion_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date_type,p_old_CURR_DETAILS_rec.conversion_date_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_DATE_TYPE;
        END IF;

	/*
        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_method,p_old_CURR_DETAILS_rec.conversion_method)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_METHOD;
        END IF;
	*/

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_type,p_old_CURR_DETAILS_rec.conversion_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.created_by,p_old_CURR_DETAILS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.creation_date,p_old_CURR_DETAILS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_detail_id,p_old_CURR_DETAILS_rec.currency_detail_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURRENCY_DETAIL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_header_id,p_old_CURR_DETAILS_rec.currency_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURRENCY_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.end_date_active,p_old_CURR_DETAILS_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.fixed_value,p_old_CURR_DETAILS_rec.fixed_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_FIXED_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_updated_by,p_old_CURR_DETAILS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_date,p_old_CURR_DETAILS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_login,p_old_CURR_DETAILS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_formula_id,p_old_CURR_DETAILS_rec.markup_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_operator,p_old_CURR_DETAILS_rec.markup_operator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_value,p_old_CURR_DETAILS_rec.markup_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.price_formula_id,p_old_CURR_DETAILS_rec.price_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PRICE_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_application_id,p_old_CURR_DETAILS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_id,p_old_CURR_DETAILS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_update_date,p_old_CURR_DETAILS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.request_id,p_old_CURR_DETAILS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.rounding_factor,p_old_CURR_DETAILS_rec.rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ROUNDING_FACTOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.selling_rounding_factor,
                                p_old_CURR_DETAILS_rec.selling_rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_SELLING_ROUNDING_FACTOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.start_date_active,p_old_CURR_DETAILS_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.to_currency_code,p_old_CURR_DETAILS_rec.to_currency_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_TO_CURRENCY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_type,p_old_CURR_DETAILS_rec.curr_attribute_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_context,p_old_CURR_DETAILS_rec.curr_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute,p_old_CURR_DETAILS_rec.curr_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_value,p_old_CURR_DETAILS_rec.curr_attribute_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.precedence,p_old_CURR_DETAILS_rec.precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PRECEDENCE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CONVERSION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_DATE;
    ELSIF p_attr_id = G_CONVERSION_DATE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_DATE_TYPE;
    -- ELSIF p_attr_id = G_CONVERSION_METHOD THEN
        -- l_index := l_index + 1;
        -- l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_METHOD;
    ELSIF p_attr_id = G_CONVERSION_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CONVERSION_TYPE;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CURRENCY_DETAIL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURRENCY_DETAIL;
    ELSIF p_attr_id = G_CURRENCY_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURRENCY_HEADER;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_FIXED_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_FIXED_VALUE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_MARKUP_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_FORMULA;
    ELSIF p_attr_id = G_MARKUP_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_OPERATOR;
    ELSIF p_attr_id = G_MARKUP_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_MARKUP_VALUE;
    ELSIF p_attr_id = G_PRICE_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PRICE_FORMULA;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_ROUNDING_FACTOR;
    ELSIF p_attr_id = G_SELLING_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_SELLING_ROUNDING_FACTOR;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_TO_CURRENCY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_TO_CURRENCY;
    ELSIF p_attr_id = G_CURR_ATTRIBUTE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_TYPE;
    ELSIF p_attr_id = G_CURR_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_CONTEXT;
    ELSIF p_attr_id = G_CURR_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE;
    ELSIF p_attr_id = G_CURR_ATTRIBUTE_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_CURR_ATTRIBUTE_VALUE;
    ELSIF p_attr_id = G_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_DETAILS_UTIL.G_PRECEDENCE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Load out NOCOPY record

    x_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute1,p_old_CURR_DETAILS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute10,p_old_CURR_DETAILS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute11,p_old_CURR_DETAILS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute12,p_old_CURR_DETAILS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute13,p_old_CURR_DETAILS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute14,p_old_CURR_DETAILS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute15,p_old_CURR_DETAILS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute2,p_old_CURR_DETAILS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute3,p_old_CURR_DETAILS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute4,p_old_CURR_DETAILS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute5,p_old_CURR_DETAILS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute6,p_old_CURR_DETAILS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute7,p_old_CURR_DETAILS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute8,p_old_CURR_DETAILS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute9,p_old_CURR_DETAILS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.context,p_old_CURR_DETAILS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date,p_old_CURR_DETAILS_rec.conversion_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date_type,p_old_CURR_DETAILS_rec.conversion_date_type)
    THEN
        NULL;
    END IF;

    /*
    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_method,p_old_CURR_DETAILS_rec.conversion_method)
    THEN
        NULL;
    END IF;
    */

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_type,p_old_CURR_DETAILS_rec.conversion_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.created_by,p_old_CURR_DETAILS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.creation_date,p_old_CURR_DETAILS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_detail_id,p_old_CURR_DETAILS_rec.currency_detail_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_header_id,p_old_CURR_DETAILS_rec.currency_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.end_date_active,p_old_CURR_DETAILS_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.fixed_value,p_old_CURR_DETAILS_rec.fixed_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_updated_by,p_old_CURR_DETAILS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_date,p_old_CURR_DETAILS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_login,p_old_CURR_DETAILS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_formula_id,p_old_CURR_DETAILS_rec.markup_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_operator,p_old_CURR_DETAILS_rec.markup_operator)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_value,p_old_CURR_DETAILS_rec.markup_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.price_formula_id,p_old_CURR_DETAILS_rec.price_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_application_id,p_old_CURR_DETAILS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_id,p_old_CURR_DETAILS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_update_date,p_old_CURR_DETAILS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.request_id,p_old_CURR_DETAILS_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.rounding_factor,p_old_CURR_DETAILS_rec.rounding_factor)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.selling_rounding_factor,
                            p_old_CURR_DETAILS_rec.selling_rounding_factor)
    THEN
         oe_debug_pub.add('Logging a request to validate unique selling rounding factor');

         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_CURR_DETAILS,
                 p_entity_id  => p_CURR_DETAILS_rec.currency_header_id,
                 p_param1  => p_CURR_DETAILS_rec.to_currency_code,
                 p_request_unique_key1 => p_CURR_DETAILS_rec.to_currency_code,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_CURR_DETAILS,
                 p_requesting_entity_id => p_CURR_DETAILS_rec.currency_header_id,
                 p_request_type =>QP_GLOBALS.G_VALIDATE_SELLING_ROUNDING,
                 x_return_status => l_return_status);
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.start_date_active,p_old_CURR_DETAILS_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.to_currency_code,p_old_CURR_DETAILS_rec.to_currency_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_type,p_old_CURR_DETAILS_rec.curr_attribute_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_context,p_old_CURR_DETAILS_rec.curr_attribute_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute,p_old_CURR_DETAILS_rec.curr_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_value,p_old_CURR_DETAILS_rec.curr_attribute_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.precedence,p_old_CURR_DETAILS_rec.precedence)
    THEN
        NULL;
    END IF;

 /*
    Changes for bug 7494395
    Updating used_in_setup flag of attribute to 'Y' if it is 'N'.
 */

        IF p_CURR_DETAILS_rec.curr_attribute IS NOT NULL AND
  	   p_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL AND
	   p_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL
        THEN

		update qp_pte_segments d set used_in_setup='Y'
		where nvl(used_in_setup,'N')='N' and
		exists
		(select 'x'
		from qp_segments_b a,qp_prc_contexts_b b
		where a.segment_mapping_column = p_CURR_DETAILS_rec.curr_attribute
		and   a.segment_id             = d.segment_id
		and   a.prc_context_id         = b.prc_context_id
		and   b.prc_context_type       = p_CURR_DETAILS_rec.curr_attribute_type
		and   b.prc_context_code       = p_CURR_DETAILS_rec.curr_attribute_context);

	END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type := p_CURR_DETAILS_rec;
BEGIN

    IF l_CURR_DETAILS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute1 := p_old_CURR_DETAILS_rec.attribute1;
    END IF;

    IF l_CURR_DETAILS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute10 := p_old_CURR_DETAILS_rec.attribute10;
    END IF;

    IF l_CURR_DETAILS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute11 := p_old_CURR_DETAILS_rec.attribute11;
    END IF;

    IF l_CURR_DETAILS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute12 := p_old_CURR_DETAILS_rec.attribute12;
    END IF;

    IF l_CURR_DETAILS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute13 := p_old_CURR_DETAILS_rec.attribute13;
    END IF;

    IF l_CURR_DETAILS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute14 := p_old_CURR_DETAILS_rec.attribute14;
    END IF;

    IF l_CURR_DETAILS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute15 := p_old_CURR_DETAILS_rec.attribute15;
    END IF;

    IF l_CURR_DETAILS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute2 := p_old_CURR_DETAILS_rec.attribute2;
    END IF;

    IF l_CURR_DETAILS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute3 := p_old_CURR_DETAILS_rec.attribute3;
    END IF;

    IF l_CURR_DETAILS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute4 := p_old_CURR_DETAILS_rec.attribute4;
    END IF;

    IF l_CURR_DETAILS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute5 := p_old_CURR_DETAILS_rec.attribute5;
    END IF;

    IF l_CURR_DETAILS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute6 := p_old_CURR_DETAILS_rec.attribute6;
    END IF;

    IF l_CURR_DETAILS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute7 := p_old_CURR_DETAILS_rec.attribute7;
    END IF;

    IF l_CURR_DETAILS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute8 := p_old_CURR_DETAILS_rec.attribute8;
    END IF;

    IF l_CURR_DETAILS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute9 := p_old_CURR_DETAILS_rec.attribute9;
    END IF;

    IF l_CURR_DETAILS_rec.context = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.context := p_old_CURR_DETAILS_rec.context;
    END IF;

    IF l_CURR_DETAILS_rec.conversion_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.conversion_date := p_old_CURR_DETAILS_rec.conversion_date;
    END IF;

    IF l_CURR_DETAILS_rec.conversion_date_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_date_type := p_old_CURR_DETAILS_rec.conversion_date_type;
    END IF;

    /*
    IF l_CURR_DETAILS_rec.conversion_method = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_method := p_old_CURR_DETAILS_rec.conversion_method;
    END IF;
    */

    IF l_CURR_DETAILS_rec.conversion_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_type := p_old_CURR_DETAILS_rec.conversion_type;
    END IF;

    IF l_CURR_DETAILS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.created_by := p_old_CURR_DETAILS_rec.created_by;
    END IF;

    IF l_CURR_DETAILS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.creation_date := p_old_CURR_DETAILS_rec.creation_date;
    END IF;

    IF l_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.currency_detail_id := p_old_CURR_DETAILS_rec.currency_detail_id;
    END IF;

    IF l_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.currency_header_id := p_old_CURR_DETAILS_rec.currency_header_id;
    END IF;

    IF l_CURR_DETAILS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.end_date_active := p_old_CURR_DETAILS_rec.end_date_active;
    END IF;

    IF l_CURR_DETAILS_rec.fixed_value = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.fixed_value := p_old_CURR_DETAILS_rec.fixed_value;
    END IF;

    IF l_CURR_DETAILS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.last_updated_by := p_old_CURR_DETAILS_rec.last_updated_by;
    END IF;

    IF l_CURR_DETAILS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.last_update_date := p_old_CURR_DETAILS_rec.last_update_date;
    END IF;

    IF l_CURR_DETAILS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.last_update_login := p_old_CURR_DETAILS_rec.last_update_login;
    END IF;

    IF l_CURR_DETAILS_rec.markup_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.markup_formula_id := p_old_CURR_DETAILS_rec.markup_formula_id;
    END IF;

    IF l_CURR_DETAILS_rec.markup_operator = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.markup_operator := p_old_CURR_DETAILS_rec.markup_operator;
    END IF;

    IF l_CURR_DETAILS_rec.markup_value = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.markup_value := p_old_CURR_DETAILS_rec.markup_value;
    END IF;

    IF l_CURR_DETAILS_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.price_formula_id := p_old_CURR_DETAILS_rec.price_formula_id;
    END IF;

    IF l_CURR_DETAILS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.program_application_id := p_old_CURR_DETAILS_rec.program_application_id;
    END IF;

    IF l_CURR_DETAILS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.program_id := p_old_CURR_DETAILS_rec.program_id;
    END IF;

    IF l_CURR_DETAILS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.program_update_date := p_old_CURR_DETAILS_rec.program_update_date;
    END IF;

    IF l_CURR_DETAILS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.request_id := p_old_CURR_DETAILS_rec.request_id;
    END IF;

    IF l_CURR_DETAILS_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.rounding_factor := p_old_CURR_DETAILS_rec.rounding_factor;
    END IF;

    IF l_CURR_DETAILS_rec.selling_rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.selling_rounding_factor := p_old_CURR_DETAILS_rec.selling_rounding_factor;
    END IF;

    IF l_CURR_DETAILS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.start_date_active := p_old_CURR_DETAILS_rec.start_date_active;
    END IF;

    IF l_CURR_DETAILS_rec.to_currency_code = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.to_currency_code := p_old_CURR_DETAILS_rec.to_currency_code;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_type := p_old_CURR_DETAILS_rec.curr_attribute_type;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_context = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_context := p_old_CURR_DETAILS_rec.curr_attribute_context;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute := p_old_CURR_DETAILS_rec.curr_attribute;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_value = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_value := p_old_CURR_DETAILS_rec.curr_attribute_value;
    END IF;

    IF l_CURR_DETAILS_rec.precedence = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.precedence := p_old_CURR_DETAILS_rec.precedence;
    END IF;

    RETURN l_CURR_DETAILS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type := p_CURR_DETAILS_rec;
BEGIN

    IF l_CURR_DETAILS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute1 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute10 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute11 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute12 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute13 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute14 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute15 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute2 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute3 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute4 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute5 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute6 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute7 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute8 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.attribute9 := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.context = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.context := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.conversion_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.conversion_date := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.conversion_date_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_date_type := NULL;
    END IF;

    /*
    IF l_CURR_DETAILS_rec.conversion_method = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_method := NULL;
    END IF;
    */

    IF l_CURR_DETAILS_rec.conversion_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.conversion_type := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.created_by := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.creation_date := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.currency_detail_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.currency_header_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.end_date_active := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.fixed_value = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.fixed_value := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.last_updated_by := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.last_update_date := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.last_update_login := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.markup_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.markup_formula_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.markup_operator = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.markup_operator := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.markup_value = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.markup_value := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.price_formula_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.program_application_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.program_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.program_update_date := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.request_id := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.rounding_factor := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.selling_rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.selling_rounding_factor := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_CURR_DETAILS_rec.start_date_active := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.to_currency_code = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.to_currency_code := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_type = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_type := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_context = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_context := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.curr_attribute_value = FND_API.G_MISS_CHAR THEN
        l_CURR_DETAILS_rec.curr_attribute_value := NULL;
    END IF;

    IF l_CURR_DETAILS_rec.precedence = FND_API.G_MISS_NUM THEN
        l_CURR_DETAILS_rec.precedence := NULL;
    END IF;

    RETURN l_CURR_DETAILS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
BEGIN

    UPDATE  QP_CURRENCY_DETAILS
    SET     ATTRIBUTE1                     = p_CURR_DETAILS_rec.attribute1
    ,       ATTRIBUTE10                    = p_CURR_DETAILS_rec.attribute10
    ,       ATTRIBUTE11                    = p_CURR_DETAILS_rec.attribute11
    ,       ATTRIBUTE12                    = p_CURR_DETAILS_rec.attribute12
    ,       ATTRIBUTE13                    = p_CURR_DETAILS_rec.attribute13
    ,       ATTRIBUTE14                    = p_CURR_DETAILS_rec.attribute14
    ,       ATTRIBUTE15                    = p_CURR_DETAILS_rec.attribute15
    ,       ATTRIBUTE2                     = p_CURR_DETAILS_rec.attribute2
    ,       ATTRIBUTE3                     = p_CURR_DETAILS_rec.attribute3
    ,       ATTRIBUTE4                     = p_CURR_DETAILS_rec.attribute4
    ,       ATTRIBUTE5                     = p_CURR_DETAILS_rec.attribute5
    ,       ATTRIBUTE6                     = p_CURR_DETAILS_rec.attribute6
    ,       ATTRIBUTE7                     = p_CURR_DETAILS_rec.attribute7
    ,       ATTRIBUTE8                     = p_CURR_DETAILS_rec.attribute8
    ,       ATTRIBUTE9                     = p_CURR_DETAILS_rec.attribute9
    ,       CONTEXT                        = p_CURR_DETAILS_rec.context
    ,       CONVERSION_DATE                = p_CURR_DETAILS_rec.conversion_date
    ,       CONVERSION_DATE_TYPE           = p_CURR_DETAILS_rec.conversion_date_type
    -- ,       CONVERSION_METHOD              = p_CURR_DETAILS_rec.conversion_method
    ,       CONVERSION_TYPE                = p_CURR_DETAILS_rec.conversion_type
    ,       CREATED_BY                     = p_CURR_DETAILS_rec.created_by
    ,       CREATION_DATE                  = p_CURR_DETAILS_rec.creation_date
    ,       CURRENCY_DETAIL_ID             = p_CURR_DETAILS_rec.currency_detail_id
    ,       CURRENCY_HEADER_ID             = p_CURR_DETAILS_rec.currency_header_id
    ,       END_DATE_ACTIVE                = p_CURR_DETAILS_rec.end_date_active
    ,       FIXED_VALUE                    = p_CURR_DETAILS_rec.fixed_value
    ,       LAST_UPDATED_BY                = p_CURR_DETAILS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_CURR_DETAILS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_CURR_DETAILS_rec.last_update_login
    ,       MARKUP_FORMULA_ID              = p_CURR_DETAILS_rec.markup_formula_id
    ,       MARKUP_OPERATOR                = p_CURR_DETAILS_rec.markup_operator
    ,       MARKUP_VALUE                   = p_CURR_DETAILS_rec.markup_value
    ,       PRICE_FORMULA_ID               = p_CURR_DETAILS_rec.price_formula_id
    ,       PROGRAM_APPLICATION_ID         = p_CURR_DETAILS_rec.program_application_id
    ,       PROGRAM_ID                     = p_CURR_DETAILS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_CURR_DETAILS_rec.program_update_date
    ,       REQUEST_ID                     = p_CURR_DETAILS_rec.request_id
    ,       ROUNDING_FACTOR                = p_CURR_DETAILS_rec.rounding_factor
    ,       SELLING_ROUNDING_FACTOR        = p_CURR_DETAILS_rec.selling_rounding_factor
    ,       START_DATE_ACTIVE              = p_CURR_DETAILS_rec.start_date_active
    ,       TO_CURRENCY_CODE               = p_CURR_DETAILS_rec.to_currency_code
    ,       CURR_ATTRIBUTE_TYPE            = p_CURR_DETAILS_rec.curr_attribute_type
    ,       CURR_ATTRIBUTE_CONTEXT         = p_CURR_DETAILS_rec.curr_attribute_context
    ,       CURR_ATTRIBUTE                 = p_CURR_DETAILS_rec.curr_attribute
    ,       CURR_ATTRIBUTE_VALUE           = p_CURR_DETAILS_rec.curr_attribute_value
    ,       PRECEDENCE                     = p_CURR_DETAILS_rec.precedence
    WHERE   CURRENCY_DETAIL_ID = p_CURR_DETAILS_rec.currency_detail_id
    ;

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
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
BEGIN

    INSERT  INTO QP_CURRENCY_DETAILS
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
    ,       CONVERSION_DATE
    ,       CONVERSION_DATE_TYPE
    -- ,       CONVERSION_METHOD
    ,       CONVERSION_TYPE
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_DETAIL_ID
    ,       CURRENCY_HEADER_ID
    ,       END_DATE_ACTIVE
    ,       FIXED_VALUE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       MARKUP_FORMULA_ID
    ,       MARKUP_OPERATOR
    ,       MARKUP_VALUE
    ,       PRICE_FORMULA_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SELLING_ROUNDING_FACTOR
    ,       START_DATE_ACTIVE
    ,       TO_CURRENCY_CODE
    ,       CURR_ATTRIBUTE_TYPE
    ,       CURR_ATTRIBUTE_CONTEXT
    ,       CURR_ATTRIBUTE
    ,       CURR_ATTRIBUTE_VALUE
    ,       PRECEDENCE
    )
    VALUES
    (       p_CURR_DETAILS_rec.attribute1
    ,       p_CURR_DETAILS_rec.attribute10
    ,       p_CURR_DETAILS_rec.attribute11
    ,       p_CURR_DETAILS_rec.attribute12
    ,       p_CURR_DETAILS_rec.attribute13
    ,       p_CURR_DETAILS_rec.attribute14
    ,       p_CURR_DETAILS_rec.attribute15
    ,       p_CURR_DETAILS_rec.attribute2
    ,       p_CURR_DETAILS_rec.attribute3
    ,       p_CURR_DETAILS_rec.attribute4
    ,       p_CURR_DETAILS_rec.attribute5
    ,       p_CURR_DETAILS_rec.attribute6
    ,       p_CURR_DETAILS_rec.attribute7
    ,       p_CURR_DETAILS_rec.attribute8
    ,       p_CURR_DETAILS_rec.attribute9
    ,       p_CURR_DETAILS_rec.context
    ,       p_CURR_DETAILS_rec.conversion_date
    ,       p_CURR_DETAILS_rec.conversion_date_type
    -- ,       p_CURR_DETAILS_rec.conversion_method
    ,       p_CURR_DETAILS_rec.conversion_type
    ,       p_CURR_DETAILS_rec.created_by
    ,       p_CURR_DETAILS_rec.creation_date
    ,       p_CURR_DETAILS_rec.currency_detail_id
    ,       p_CURR_DETAILS_rec.currency_header_id
    ,       p_CURR_DETAILS_rec.end_date_active
    ,       p_CURR_DETAILS_rec.fixed_value
    ,       p_CURR_DETAILS_rec.last_updated_by
    ,       p_CURR_DETAILS_rec.last_update_date
    ,       p_CURR_DETAILS_rec.last_update_login
    ,       p_CURR_DETAILS_rec.markup_formula_id
    ,       p_CURR_DETAILS_rec.markup_operator
    ,       p_CURR_DETAILS_rec.markup_value
    ,       p_CURR_DETAILS_rec.price_formula_id
    ,       p_CURR_DETAILS_rec.program_application_id
    ,       p_CURR_DETAILS_rec.program_id
    ,       p_CURR_DETAILS_rec.program_update_date
    ,       p_CURR_DETAILS_rec.request_id
    ,       p_CURR_DETAILS_rec.rounding_factor
    ,       p_CURR_DETAILS_rec.selling_rounding_factor
    ,       p_CURR_DETAILS_rec.start_date_active
    ,       p_CURR_DETAILS_rec.to_currency_code
    ,       p_CURR_DETAILS_rec.curr_attribute_type
    ,       p_CURR_DETAILS_rec.curr_attribute_context
    ,       p_CURR_DETAILS_rec.curr_attribute
    ,       p_CURR_DETAILS_rec.curr_attribute_value
    ,       p_CURR_DETAILS_rec.precedence
    );

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
(   p_currency_detail_id            IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_CURRENCY_DETAILS
    WHERE   CURRENCY_DETAIL_ID = p_currency_detail_id
    ;

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
(   p_currency_detail_id            IN  NUMBER
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_currency_detail_id          => p_currency_detail_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_currency_detail_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_currency_header_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Currency_PUB.Curr_Details_Tbl_Type
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;

CURSOR l_CURR_DETAILS_csr IS
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
    ,       CONVERSION_DATE
    ,       CONVERSION_DATE_TYPE
    -- ,       CONVERSION_METHOD
    ,       CONVERSION_TYPE
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_DETAIL_ID
    ,       CURRENCY_HEADER_ID
    ,       END_DATE_ACTIVE
    ,       FIXED_VALUE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       MARKUP_FORMULA_ID
    ,       MARKUP_OPERATOR
    ,       MARKUP_VALUE
    ,       PRICE_FORMULA_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SELLING_ROUNDING_FACTOR
    ,       START_DATE_ACTIVE
    ,       TO_CURRENCY_CODE
    ,       CURR_ATTRIBUTE_TYPE
    ,       CURR_ATTRIBUTE_CONTEXT
    ,       CURR_ATTRIBUTE
    ,       CURR_ATTRIBUTE_VALUE
    ,       PRECEDENCE
    FROM    QP_CURRENCY_DETAILS
    WHERE ( CURRENCY_DETAIL_ID = p_currency_detail_id
    )
    OR (    CURRENCY_HEADER_ID = p_currency_header_id
    );

BEGIN

    IF
    (p_currency_detail_id IS NOT NULL
     AND
     p_currency_detail_id <> FND_API.G_MISS_NUM)
    AND
    (p_currency_header_id IS NOT NULL
     AND
     p_currency_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: currency_detail_id = '|| p_currency_detail_id || ', currency_header_id = '|| p_currency_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_CURR_DETAILS_csr LOOP

        l_CURR_DETAILS_rec.attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_CURR_DETAILS_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_CURR_DETAILS_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_CURR_DETAILS_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_CURR_DETAILS_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_CURR_DETAILS_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_CURR_DETAILS_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_CURR_DETAILS_rec.attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_CURR_DETAILS_rec.attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_CURR_DETAILS_rec.attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_CURR_DETAILS_rec.attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_CURR_DETAILS_rec.attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_CURR_DETAILS_rec.attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_CURR_DETAILS_rec.attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_CURR_DETAILS_rec.attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_CURR_DETAILS_rec.context     := l_implicit_rec.CONTEXT;
        l_CURR_DETAILS_rec.conversion_date := l_implicit_rec.CONVERSION_DATE;
        l_CURR_DETAILS_rec.conversion_date_type := l_implicit_rec.CONVERSION_DATE_TYPE;
        -- l_CURR_DETAILS_rec.conversion_method := l_implicit_rec.CONVERSION_METHOD;
        l_CURR_DETAILS_rec.conversion_type := l_implicit_rec.CONVERSION_TYPE;
        l_CURR_DETAILS_rec.created_by  := l_implicit_rec.CREATED_BY;
        l_CURR_DETAILS_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_CURR_DETAILS_rec.currency_detail_id := l_implicit_rec.CURRENCY_DETAIL_ID;
        l_CURR_DETAILS_rec.currency_header_id := l_implicit_rec.CURRENCY_HEADER_ID;
        l_CURR_DETAILS_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_CURR_DETAILS_rec.fixed_value := l_implicit_rec.FIXED_VALUE;
        l_CURR_DETAILS_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_CURR_DETAILS_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_CURR_DETAILS_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_CURR_DETAILS_rec.markup_formula_id := l_implicit_rec.MARKUP_FORMULA_ID;
        l_CURR_DETAILS_rec.markup_operator := l_implicit_rec.MARKUP_OPERATOR;
        l_CURR_DETAILS_rec.markup_value := l_implicit_rec.MARKUP_VALUE;
        l_CURR_DETAILS_rec.price_formula_id := l_implicit_rec.PRICE_FORMULA_ID;
        l_CURR_DETAILS_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_CURR_DETAILS_rec.program_id  := l_implicit_rec.PROGRAM_ID;
        l_CURR_DETAILS_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_CURR_DETAILS_rec.request_id  := l_implicit_rec.REQUEST_ID;
        l_CURR_DETAILS_rec.rounding_factor := l_implicit_rec.ROUNDING_FACTOR;
        l_CURR_DETAILS_rec.selling_rounding_factor := l_implicit_rec.SELLING_ROUNDING_FACTOR;
        l_CURR_DETAILS_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_CURR_DETAILS_rec.to_currency_code := l_implicit_rec.TO_CURRENCY_CODE;
        l_CURR_DETAILS_rec.curr_attribute_type := l_implicit_rec.CURR_ATTRIBUTE_TYPE;
        l_CURR_DETAILS_rec.curr_attribute_context := l_implicit_rec.CURR_ATTRIBUTE_CONTEXT;
        l_CURR_DETAILS_rec.curr_attribute := l_implicit_rec.CURR_ATTRIBUTE;
        l_CURR_DETAILS_rec.curr_attribute_value := l_implicit_rec.CURR_ATTRIBUTE_VALUE;
        l_CURR_DETAILS_rec.precedence := l_implicit_rec.PRECEDENCE;

        l_CURR_DETAILS_tbl(l_CURR_DETAILS_tbl.COUNT + 1) := l_CURR_DETAILS_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_currency_detail_id IS NOT NULL
     AND
     p_currency_detail_id <> FND_API.G_MISS_NUM)
    AND
    (l_CURR_DETAILS_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_CURR_DETAILS_tbl;

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
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
BEGIN

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
    ,       CONVERSION_DATE
    ,       CONVERSION_DATE_TYPE
    -- ,       CONVERSION_METHOD
    ,       CONVERSION_TYPE
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_DETAIL_ID
    ,       CURRENCY_HEADER_ID
    ,       END_DATE_ACTIVE
    ,       FIXED_VALUE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       MARKUP_FORMULA_ID
    ,       MARKUP_OPERATOR
    ,       MARKUP_VALUE
    ,       PRICE_FORMULA_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SELLING_ROUNDING_FACTOR
    ,       START_DATE_ACTIVE
    ,       TO_CURRENCY_CODE
    ,       CURR_ATTRIBUTE_TYPE
    ,       CURR_ATTRIBUTE_CONTEXT
    ,       CURR_ATTRIBUTE
    ,       CURR_ATTRIBUTE_VALUE
    ,       PRECEDENCE
    INTO    l_CURR_DETAILS_rec.attribute1
    ,       l_CURR_DETAILS_rec.attribute10
    ,       l_CURR_DETAILS_rec.attribute11
    ,       l_CURR_DETAILS_rec.attribute12
    ,       l_CURR_DETAILS_rec.attribute13
    ,       l_CURR_DETAILS_rec.attribute14
    ,       l_CURR_DETAILS_rec.attribute15
    ,       l_CURR_DETAILS_rec.attribute2
    ,       l_CURR_DETAILS_rec.attribute3
    ,       l_CURR_DETAILS_rec.attribute4
    ,       l_CURR_DETAILS_rec.attribute5
    ,       l_CURR_DETAILS_rec.attribute6
    ,       l_CURR_DETAILS_rec.attribute7
    ,       l_CURR_DETAILS_rec.attribute8
    ,       l_CURR_DETAILS_rec.attribute9
    ,       l_CURR_DETAILS_rec.context
    ,       l_CURR_DETAILS_rec.conversion_date
    ,       l_CURR_DETAILS_rec.conversion_date_type
    -- ,       l_CURR_DETAILS_rec.conversion_method
    ,       l_CURR_DETAILS_rec.conversion_type
    ,       l_CURR_DETAILS_rec.created_by
    ,       l_CURR_DETAILS_rec.creation_date
    ,       l_CURR_DETAILS_rec.currency_detail_id
    ,       l_CURR_DETAILS_rec.currency_header_id
    ,       l_CURR_DETAILS_rec.end_date_active
    ,       l_CURR_DETAILS_rec.fixed_value
    ,       l_CURR_DETAILS_rec.last_updated_by
    ,       l_CURR_DETAILS_rec.last_update_date
    ,       l_CURR_DETAILS_rec.last_update_login
    ,       l_CURR_DETAILS_rec.markup_formula_id
    ,       l_CURR_DETAILS_rec.markup_operator
    ,       l_CURR_DETAILS_rec.markup_value
    ,       l_CURR_DETAILS_rec.price_formula_id
    ,       l_CURR_DETAILS_rec.program_application_id
    ,       l_CURR_DETAILS_rec.program_id
    ,       l_CURR_DETAILS_rec.program_update_date
    ,       l_CURR_DETAILS_rec.request_id
    ,       l_CURR_DETAILS_rec.rounding_factor
    ,       l_CURR_DETAILS_rec.selling_rounding_factor
    ,       l_CURR_DETAILS_rec.start_date_active
    ,       l_CURR_DETAILS_rec.to_currency_code
    ,       l_CURR_DETAILS_rec.curr_attribute_type
    ,       l_CURR_DETAILS_rec.curr_attribute_context
    ,       l_CURR_DETAILS_rec.curr_attribute
    ,       l_CURR_DETAILS_rec.curr_attribute_value
    ,       l_CURR_DETAILS_rec.precedence
    FROM    QP_CURRENCY_DETAILS
    WHERE   CURRENCY_DETAIL_ID = p_CURR_DETAILS_rec.currency_detail_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute1,
                         l_CURR_DETAILS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute10,
                         l_CURR_DETAILS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute11,
                         l_CURR_DETAILS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute12,
                         l_CURR_DETAILS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute13,
                         l_CURR_DETAILS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute14,
                         l_CURR_DETAILS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute15,
                         l_CURR_DETAILS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute2,
                         l_CURR_DETAILS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute3,
                         l_CURR_DETAILS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute4,
                         l_CURR_DETAILS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute5,
                         l_CURR_DETAILS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute6,
                         l_CURR_DETAILS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute7,
                         l_CURR_DETAILS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute8,
                         l_CURR_DETAILS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.attribute9,
                         l_CURR_DETAILS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.context,
                         l_CURR_DETAILS_rec.context)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date,
                         l_CURR_DETAILS_rec.conversion_date)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_date_type,
                         l_CURR_DETAILS_rec.conversion_date_type)
    -- AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_method,
                         -- l_CURR_DETAILS_rec.conversion_method)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.conversion_type,
                         l_CURR_DETAILS_rec.conversion_type)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.created_by,
                         l_CURR_DETAILS_rec.created_by)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.creation_date,
                         l_CURR_DETAILS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_detail_id,
                         l_CURR_DETAILS_rec.currency_detail_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_header_id,
                         l_CURR_DETAILS_rec.currency_header_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.end_date_active,
                         l_CURR_DETAILS_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.fixed_value,
                         l_CURR_DETAILS_rec.fixed_value)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_updated_by,
                         l_CURR_DETAILS_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_date,
                         l_CURR_DETAILS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.last_update_login,
                         l_CURR_DETAILS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_formula_id,
                         l_CURR_DETAILS_rec.markup_formula_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_operator,
                         l_CURR_DETAILS_rec.markup_operator)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_value,
                         l_CURR_DETAILS_rec.markup_value)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.price_formula_id,
                         l_CURR_DETAILS_rec.price_formula_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_application_id,
                         l_CURR_DETAILS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_id,
                         l_CURR_DETAILS_rec.program_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.program_update_date,
                         l_CURR_DETAILS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.request_id,
                         l_CURR_DETAILS_rec.request_id)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.rounding_factor,
                         l_CURR_DETAILS_rec.rounding_factor)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.selling_rounding_factor,
                         l_CURR_DETAILS_rec.selling_rounding_factor)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.start_date_active,
                         l_CURR_DETAILS_rec.start_date_active)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.to_currency_code,
                         l_CURR_DETAILS_rec.to_currency_code)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_type,
                         l_CURR_DETAILS_rec.curr_attribute_type)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_context,
                         l_CURR_DETAILS_rec.curr_attribute_context)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute,
                         l_CURR_DETAILS_rec.curr_attribute)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.curr_attribute_value,
                         l_CURR_DETAILS_rec.curr_attribute_value)
    AND QP_GLOBALS.Equal(p_CURR_DETAILS_rec.precedence,
                         l_CURR_DETAILS_rec.precedence)
    THEN

        --  Row has not changed. Set out parameter.

        x_CURR_DETAILS_rec             := l_CURR_DETAILS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
) RETURN QP_Currency_PUB.Curr_Details_Val_Rec_Type
IS
l_CURR_DETAILS_val_rec        QP_Currency_PUB.Curr_Details_Val_Rec_Type;
BEGIN

    IF p_CURR_DETAILS_rec.currency_detail_id IS NOT NULL AND
        p_CURR_DETAILS_rec.currency_detail_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_detail_id,
        p_old_CURR_DETAILS_rec.currency_detail_id)
    THEN
        l_CURR_DETAILS_val_rec.currency_detail := QP_Id_To_Value.Currency_Detail
        (   p_currency_detail_id          => p_CURR_DETAILS_rec.currency_detail_id
        );
    END IF;

    IF p_CURR_DETAILS_rec.currency_header_id IS NOT NULL AND
        p_CURR_DETAILS_rec.currency_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.currency_header_id,
        p_old_CURR_DETAILS_rec.currency_header_id)
    THEN
        l_CURR_DETAILS_val_rec.currency_header := QP_Id_To_Value.Currency_Header
        (   p_currency_header_id          => p_CURR_DETAILS_rec.currency_header_id
        );
    END IF;

    IF p_CURR_DETAILS_rec.markup_formula_id IS NOT NULL AND
        p_CURR_DETAILS_rec.markup_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.markup_formula_id,
        p_old_CURR_DETAILS_rec.markup_formula_id)
    THEN
        l_CURR_DETAILS_val_rec.markup_formula := QP_Id_To_Value.Markup_Formula
        (   p_markup_formula_id           => p_CURR_DETAILS_rec.markup_formula_id
        );
    END IF;

    IF p_CURR_DETAILS_rec.price_formula_id IS NOT NULL AND
        p_CURR_DETAILS_rec.price_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.price_formula_id,
        p_old_CURR_DETAILS_rec.price_formula_id)
    THEN
        l_CURR_DETAILS_val_rec.price_formula := QP_Id_To_Value.Price_Formula
        (   p_price_formula_id            => p_CURR_DETAILS_rec.price_formula_id
        );
    END IF;

    IF p_CURR_DETAILS_rec.to_currency_code IS NOT NULL AND
        p_CURR_DETAILS_rec.to_currency_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_CURR_DETAILS_rec.to_currency_code,
        p_old_CURR_DETAILS_rec.to_currency_code)
    THEN
        l_CURR_DETAILS_val_rec.to_currency := QP_Id_To_Value.To_Currency
        (   p_to_currency_code            => p_CURR_DETAILS_rec.to_currency_code
        );
    END IF;

    RETURN l_CURR_DETAILS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_CURR_DETAILS_val_rec          IN  QP_Currency_PUB.Curr_Details_Val_Rec_Type
) RETURN QP_Currency_PUB.Curr_Details_Rec_Type
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_CURR_DETAILS_rec.

    l_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    IF  p_CURR_DETAILS_val_rec.currency_detail <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_DETAILS_rec.currency_detail_id <> FND_API.G_MISS_NUM THEN

            l_CURR_DETAILS_rec.currency_detail_id := p_CURR_DETAILS_rec.currency_detail_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_detail');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_DETAILS_rec.currency_detail_id := QP_Value_To_Id.currency_detail
            (   p_currency_detail             => p_CURR_DETAILS_val_rec.currency_detail
            );

            IF l_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM THEN
                l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CURR_DETAILS_val_rec.currency_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_DETAILS_rec.currency_header_id <> FND_API.G_MISS_NUM THEN

            l_CURR_DETAILS_rec.currency_header_id := p_CURR_DETAILS_rec.currency_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_DETAILS_rec.currency_header_id := QP_Value_To_Id.currency_header
            (   p_currency_header             => p_CURR_DETAILS_val_rec.currency_header
            );

            IF l_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
                l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CURR_DETAILS_val_rec.markup_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_DETAILS_rec.markup_formula_id <> FND_API.G_MISS_NUM THEN

            l_CURR_DETAILS_rec.markup_formula_id := p_CURR_DETAILS_rec.markup_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_DETAILS_rec.markup_formula_id := QP_Value_To_Id.markup_formula
            (   p_markup_formula              => p_CURR_DETAILS_val_rec.markup_formula
            );

            IF l_CURR_DETAILS_rec.markup_formula_id = FND_API.G_MISS_NUM THEN
                l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CURR_DETAILS_val_rec.price_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_DETAILS_rec.price_formula_id <> FND_API.G_MISS_NUM THEN

            l_CURR_DETAILS_rec.price_formula_id := p_CURR_DETAILS_rec.price_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_DETAILS_rec.price_formula_id := QP_Value_To_Id.price_formula
            (   p_price_formula               => p_CURR_DETAILS_val_rec.price_formula
            );

            IF l_CURR_DETAILS_rec.price_formula_id = FND_API.G_MISS_NUM THEN
                l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CURR_DETAILS_val_rec.to_currency <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_DETAILS_rec.to_currency_code <> FND_API.G_MISS_CHAR THEN

            l_CURR_DETAILS_rec.to_currency_code := p_CURR_DETAILS_rec.to_currency_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_currency');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_DETAILS_rec.to_currency_code := QP_Value_To_Id.to_currency
            (   p_to_currency                 => p_CURR_DETAILS_val_rec.to_currency
            );

            IF l_CURR_DETAILS_rec.to_currency_code = FND_API.G_MISS_CHAR THEN
                l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_CURR_DETAILS_rec;

END Get_Ids;

END QP_Curr_Details_Util;

/

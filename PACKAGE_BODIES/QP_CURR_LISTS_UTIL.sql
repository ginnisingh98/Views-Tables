--------------------------------------------------------
--  DDL for Package Body QP_CURR_LISTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CURR_LISTS_UTIL" AS
/* $Header: QPXUCURB.pls 120.1 2005/06/10 00:09:31 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Curr_Lists_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_CURR_LISTS_rec := p_CURR_LISTS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute1,p_old_CURR_LISTS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute10,p_old_CURR_LISTS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute11,p_old_CURR_LISTS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute12,p_old_CURR_LISTS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute13,p_old_CURR_LISTS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute14,p_old_CURR_LISTS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute15,p_old_CURR_LISTS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute2,p_old_CURR_LISTS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute3,p_old_CURR_LISTS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute4,p_old_CURR_LISTS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute5,p_old_CURR_LISTS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute6,p_old_CURR_LISTS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute7,p_old_CURR_LISTS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute8,p_old_CURR_LISTS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute9,p_old_CURR_LISTS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_currency_code,p_old_CURR_LISTS_rec.base_currency_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_CURRENCY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.context,p_old_CURR_LISTS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.created_by,p_old_CURR_LISTS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.creation_date,p_old_CURR_LISTS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.currency_header_id,p_old_CURR_LISTS_rec.currency_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CURRENCY_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.description,p_old_CURR_LISTS_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_updated_by,p_old_CURR_LISTS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_date,p_old_CURR_LISTS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_login,p_old_CURR_LISTS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.name,p_old_CURR_LISTS_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_application_id,p_old_CURR_LISTS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_id,p_old_CURR_LISTS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_update_date,p_old_CURR_LISTS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.request_id,p_old_CURR_LISTS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_REQUEST;
        END IF;

	-- Added by Sunil Pandey 10/01/01
        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_formula_id,p_old_CURR_LISTS_rec.base_markup_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_operator,p_old_CURR_LISTS_rec.base_markup_operator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_value,p_old_CURR_LISTS_rec.base_markup_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_rounding_factor,p_old_CURR_LISTS_rec.base_rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_ROUNDING_FACTOR;
        END IF;
	-- Added by Sunil Pandey 10/01/01


/* Commented by Sunil
        IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.row_id,p_old_CURR_LISTS_rec.row_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ROW;
        END IF;
  Commented by Sunil */

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_BASE_CURRENCY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_CURRENCY;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CURRENCY_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_CURRENCY_HEADER;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_NAME;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_REQUEST;
    -- Added by Sunil Pandey 10/01/01
    ELSIF p_attr_id = G_BASE_MARKUP_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_FORMULA;
    ELSIF p_attr_id = G_BASE_MARKUP_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_OPERATOR;
    ELSIF p_attr_id = G_BASE_MARKUP_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_MARKUP_VALUE;
    ELSIF p_attr_id = G_BASE_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_BASE_ROUNDING_FACTOR;
    -- Added by Sunil Pandey 10/01/01
    ELSIF p_attr_id = G_ROW THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CURR_LISTS_UTIL.G_ROW;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
l_dummy_c              VARCHAR2(1);
list_already_attached  EXCEPTION;

BEGIN

    --  Load out record

    x_CURR_LISTS_rec := p_CURR_LISTS_rec;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute1,p_old_CURR_LISTS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute10,p_old_CURR_LISTS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute11,p_old_CURR_LISTS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute12,p_old_CURR_LISTS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute13,p_old_CURR_LISTS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute14,p_old_CURR_LISTS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute15,p_old_CURR_LISTS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute2,p_old_CURR_LISTS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute3,p_old_CURR_LISTS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute4,p_old_CURR_LISTS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute5,p_old_CURR_LISTS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute6,p_old_CURR_LISTS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute7,p_old_CURR_LISTS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute8,p_old_CURR_LISTS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute9,p_old_CURR_LISTS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_currency_code,p_old_CURR_LISTS_rec.base_currency_code)
    THEN
       -- Added by Sunil Pandey 10/01/01
       -- Allow modification of Base_Currency_code only if the currency_list is not attached to
       -- any Price List
       Begin
	   Select 'X'
	   Into l_dummy_c
	   From QP_LIST_HEADERS_B
	   Where currency_header_id = p_old_CURR_LISTS_rec.currency_header_id;

	   -- If the currency_list is attached then raise error
	   raise list_already_attached;

       Exception
	  WHEN NO_DATA_FOUND THEN
             IF p_old_CURR_LISTS_rec.base_currency_code <> FND_API.G_MISS_CHAR
	     THEN

		-- Update details record's to_currency_code with new base_currency_code
	        Update QP_CURRENCY_DETAILS
	        Set to_currency_code = p_CURR_LISTS_rec.base_currency_code
	        Where to_currency_code = p_old_CURR_LISTS_rec.base_currency_code
	        And   currency_header_id = p_old_CURR_LISTS_rec.currency_header_id;

		-- Delete detail record having to_currecny = new.base_currency and conversion_type<>NULL
		Delete from QP_CURRENCY_DETAILS
		Where to_currency_code = p_CURR_LISTS_rec.base_currency_code
		And   currency_header_id = p_old_CURR_LISTS_rec.currency_header_id
		-- And   conversion_method is NOT NULL;
		And   conversion_type is NOT NULL;
             ELSE
		NULL;
             END IF;

          WHEN TOO_MANY_ROWS THEN
	  -- if the multi-currency list is attached to multiple price lists
               -- oe_debug_pub.add('ERROR: This Multi-Currency is attached to more than one Price Lists, so Base Currency Code can not be modified');

               FND_MESSAGE.SET_NAME('QP','QP_MCURR_ATTCHD_TO_PRL'); -- CHANGE
               OE_MSG_PUB.Add;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          WHEN list_already_attached THEN
               -- oe_debug_pub.add('ERROR: This Multi-Currency is attached to a Price List, so Base Currency Code can not be modified');

               FND_MESSAGE.SET_NAME('QP','QP_MCURR_ATTCHD_TO_PRL'); -- CHANGE
               OE_MSG_PUB.Add;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       End;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.context,p_old_CURR_LISTS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.created_by,p_old_CURR_LISTS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.creation_date,p_old_CURR_LISTS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.currency_header_id,p_old_CURR_LISTS_rec.currency_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.description,p_old_CURR_LISTS_rec.description)
    THEN
        NULL;
    END IF;

    -- Added by Sunil Pandey 10/01/01
    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_rounding_factor,p_old_CURR_LISTS_rec.base_rounding_factor)
    THEN
        NULL;
        update qp_list_headers_b
           set rounding_factor = p_CURR_LISTS_rec.base_rounding_factor
          where currency_header_id = p_CURR_LISTS_rec.currency_header_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_operator,p_old_CURR_LISTS_rec.base_markup_operator)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_value,p_old_CURR_LISTS_rec.base_markup_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_formula_id,p_old_CURR_LISTS_rec.base_markup_formula_id)
    THEN
        NULL;
    END IF;
    -- Added by Sunil Pandey 10/01/01

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_updated_by,p_old_CURR_LISTS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_date,p_old_CURR_LISTS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_login,p_old_CURR_LISTS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.name,p_old_CURR_LISTS_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_application_id,p_old_CURR_LISTS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_id,p_old_CURR_LISTS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_update_date,p_old_CURR_LISTS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.request_id,p_old_CURR_LISTS_rec.request_id)
    THEN
        NULL;
    END IF;

/* Commented by Sunil
    IF NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.row_id,p_old_CURR_LISTS_rec.row_id)
    THEN
        NULL;
    END IF;
  Commented by Sunil */

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type
) RETURN QP_Currency_PUB.Curr_Lists_Rec_Type
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type := p_CURR_LISTS_rec;
BEGIN

    IF l_CURR_LISTS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute1 := p_old_CURR_LISTS_rec.attribute1;
    END IF;

    IF l_CURR_LISTS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute10 := p_old_CURR_LISTS_rec.attribute10;
    END IF;

    IF l_CURR_LISTS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute11 := p_old_CURR_LISTS_rec.attribute11;
    END IF;

    IF l_CURR_LISTS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute12 := p_old_CURR_LISTS_rec.attribute12;
    END IF;

    IF l_CURR_LISTS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute13 := p_old_CURR_LISTS_rec.attribute13;
    END IF;

    IF l_CURR_LISTS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute14 := p_old_CURR_LISTS_rec.attribute14;
    END IF;

    IF l_CURR_LISTS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute15 := p_old_CURR_LISTS_rec.attribute15;
    END IF;

    IF l_CURR_LISTS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute2 := p_old_CURR_LISTS_rec.attribute2;
    END IF;

    IF l_CURR_LISTS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute3 := p_old_CURR_LISTS_rec.attribute3;
    END IF;

    IF l_CURR_LISTS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute4 := p_old_CURR_LISTS_rec.attribute4;
    END IF;

    IF l_CURR_LISTS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute5 := p_old_CURR_LISTS_rec.attribute5;
    END IF;

    IF l_CURR_LISTS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute6 := p_old_CURR_LISTS_rec.attribute6;
    END IF;

    IF l_CURR_LISTS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute7 := p_old_CURR_LISTS_rec.attribute7;
    END IF;

    IF l_CURR_LISTS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute8 := p_old_CURR_LISTS_rec.attribute8;
    END IF;

    IF l_CURR_LISTS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute9 := p_old_CURR_LISTS_rec.attribute9;
    END IF;

    IF l_CURR_LISTS_rec.base_currency_code = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.base_currency_code := p_old_CURR_LISTS_rec.base_currency_code;
    END IF;

    IF l_CURR_LISTS_rec.context = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.context := p_old_CURR_LISTS_rec.context;
    END IF;

    IF l_CURR_LISTS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.created_by := p_old_CURR_LISTS_rec.created_by;
    END IF;

    IF l_CURR_LISTS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.creation_date := p_old_CURR_LISTS_rec.creation_date;
    END IF;

    IF l_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.currency_header_id := p_old_CURR_LISTS_rec.currency_header_id;
    END IF;

    IF l_CURR_LISTS_rec.description = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.description := p_old_CURR_LISTS_rec.description;
    END IF;

    -- Added by Sunil Pandey 10/01/01
    IF l_CURR_LISTS_rec.base_rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_rounding_factor := p_old_CURR_LISTS_rec.base_rounding_factor;
    END IF;

    IF l_CURR_LISTS_rec.base_markup_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_markup_formula_id := p_old_CURR_LISTS_rec.base_markup_formula_id;
    END IF;

    IF l_CURR_LISTS_rec.base_markup_operator = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.base_markup_operator := p_old_CURR_LISTS_rec.base_markup_operator;
    END IF;

    IF l_CURR_LISTS_rec.base_markup_value = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_markup_value := p_old_CURR_LISTS_rec.base_markup_value;
    END IF;
    -- Added by Sunil Pandey 10/01/01

    IF l_CURR_LISTS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.last_updated_by := p_old_CURR_LISTS_rec.last_updated_by;
    END IF;

    IF l_CURR_LISTS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.last_update_date := p_old_CURR_LISTS_rec.last_update_date;
    END IF;

    IF l_CURR_LISTS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.last_update_login := p_old_CURR_LISTS_rec.last_update_login;
    END IF;

    IF l_CURR_LISTS_rec.name = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.name := p_old_CURR_LISTS_rec.name;
    END IF;

    IF l_CURR_LISTS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.program_application_id := p_old_CURR_LISTS_rec.program_application_id;
    END IF;

    IF l_CURR_LISTS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.program_id := p_old_CURR_LISTS_rec.program_id;
    END IF;

    IF l_CURR_LISTS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.program_update_date := p_old_CURR_LISTS_rec.program_update_date;
    END IF;

    IF l_CURR_LISTS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.request_id := p_old_CURR_LISTS_rec.request_id;
    END IF;

/* Commented by Sunil
    IF l_CURR_LISTS_rec.row_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.row_id := p_old_CURR_LISTS_rec.row_id;
    END IF;
  Commented by Sunil */

    RETURN l_CURR_LISTS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
) RETURN QP_Currency_PUB.Curr_Lists_Rec_Type
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type := p_CURR_LISTS_rec;
BEGIN

    IF l_CURR_LISTS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute1 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute10 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute11 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute12 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute13 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute14 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute15 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute2 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute3 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute4 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute5 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute6 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute7 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute8 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.attribute9 := NULL;
    END IF;

    IF l_CURR_LISTS_rec.base_currency_code = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.base_currency_code := NULL;
    END IF;

    IF l_CURR_LISTS_rec.context = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.context := NULL;
    END IF;

    IF l_CURR_LISTS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.created_by := NULL;
    END IF;

    IF l_CURR_LISTS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.creation_date := NULL;
    END IF;

    IF l_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.currency_header_id := NULL;
    END IF;

    IF l_CURR_LISTS_rec.description = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.description := NULL;
    END IF;

    IF l_CURR_LISTS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.last_updated_by := NULL;
    END IF;

    IF l_CURR_LISTS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.last_update_date := NULL;
    END IF;

    IF l_CURR_LISTS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.last_update_login := NULL;
    END IF;

    IF l_CURR_LISTS_rec.name = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.name := NULL;
    END IF;

    IF l_CURR_LISTS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.program_application_id := NULL;
    END IF;

    IF l_CURR_LISTS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.program_id := NULL;
    END IF;

    IF l_CURR_LISTS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CURR_LISTS_rec.program_update_date := NULL;
    END IF;

    IF l_CURR_LISTS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.request_id := NULL;
    END IF;

    -- Added by Sunil Pandey 10/01/01
    IF l_CURR_LISTS_rec.base_markup_formula_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_markup_formula_id := NULL;
    END IF;

    IF l_CURR_LISTS_rec.base_markup_operator = FND_API.G_MISS_CHAR THEN
        l_CURR_LISTS_rec.base_markup_operator := NULL;
    END IF;

    IF l_CURR_LISTS_rec.base_markup_value = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_markup_value := NULL;
    END IF;

    IF l_CURR_LISTS_rec.base_rounding_factor = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.base_rounding_factor := NULL;
    END IF;
    -- Added by Sunil Pandey 10/01/01

/* Commented by Sunil
    IF l_CURR_LISTS_rec.row_id = FND_API.G_MISS_NUM THEN
        l_CURR_LISTS_rec.row_id := NULL;
    END IF;
  Commented by Sunil */

    RETURN l_CURR_LISTS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
BEGIN

    -- oe_debug_pub.add('UPDATE_ROW of Header');
    -- oe_debug_pub.add('Header_id=' || p_CURR_LISTS_rec.currency_header_id);
    -- oe_debug_pub.add('Name=' || p_CURR_LISTS_rec.name);
    -- oe_debug_pub.add('Description=' || p_CURR_LISTS_rec.description);
    -- oe_debug_pub.add('Base Currency=' || p_CURR_LISTS_rec.base_currency_code);
    -- oe_debug_pub.add('Base base_rounding_factor=' || p_CURR_LISTS_rec.base_rounding_factor);
    -- oe_debug_pub.add('Base base_markup_value=' || p_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('Base base_markup_operator=' || p_CURR_LISTS_rec.base_markup_operator);
    -- oe_debug_pub.add('Base base_markup_formula=' || p_CURR_LISTS_rec.base_markup_formula_id);


    UPDATE  QP_CURRENCY_LISTS_B
    SET     ATTRIBUTE1                     = p_CURR_LISTS_rec.attribute1
    ,       ATTRIBUTE10                    = p_CURR_LISTS_rec.attribute10
    ,       ATTRIBUTE11                    = p_CURR_LISTS_rec.attribute11
    ,       ATTRIBUTE12                    = p_CURR_LISTS_rec.attribute12
    ,       ATTRIBUTE13                    = p_CURR_LISTS_rec.attribute13
    ,       ATTRIBUTE14                    = p_CURR_LISTS_rec.attribute14
    ,       ATTRIBUTE15                    = p_CURR_LISTS_rec.attribute15
    ,       ATTRIBUTE2                     = p_CURR_LISTS_rec.attribute2
    ,       ATTRIBUTE3                     = p_CURR_LISTS_rec.attribute3
    ,       ATTRIBUTE4                     = p_CURR_LISTS_rec.attribute4
    ,       ATTRIBUTE5                     = p_CURR_LISTS_rec.attribute5
    ,       ATTRIBUTE6                     = p_CURR_LISTS_rec.attribute6
    ,       ATTRIBUTE7                     = p_CURR_LISTS_rec.attribute7
    ,       ATTRIBUTE8                     = p_CURR_LISTS_rec.attribute8
    ,       ATTRIBUTE9                     = p_CURR_LISTS_rec.attribute9
    ,       BASE_CURRENCY_CODE             = p_CURR_LISTS_rec.base_currency_code
    ,       CONTEXT                        = p_CURR_LISTS_rec.context
    ,       CREATED_BY                     = p_CURR_LISTS_rec.created_by
    ,       CREATION_DATE                  = p_CURR_LISTS_rec.creation_date
    ,       CURRENCY_HEADER_ID             = p_CURR_LISTS_rec.currency_header_id
    ,       LAST_UPDATED_BY                = p_CURR_LISTS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_CURR_LISTS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_CURR_LISTS_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID         = p_CURR_LISTS_rec.program_application_id
    ,       PROGRAM_ID                     = p_CURR_LISTS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_CURR_LISTS_rec.program_update_date
    ,       REQUEST_ID                     = p_CURR_LISTS_rec.request_id
    WHERE   CURRENCY_HEADER_ID = p_CURR_LISTS_rec.currency_header_id
    ;

    -- oe_debug_pub.add('After Update of B');

    -- Added by Sunil
    update QP_CURRENCY_LISTS_TL set
      NAME                   = p_CURR_LISTS_rec.NAME
    , DESCRIPTION            = p_CURR_LISTS_rec.DESCRIPTION
    , LAST_UPDATE_DATE       = p_CURR_LISTS_rec.LAST_UPDATE_DATE
    , LAST_UPDATED_BY        = p_CURR_LISTS_rec.LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN      = p_CURR_LISTS_rec.LAST_UPDATE_LOGIN
    , SOURCE_LANG            = userenv('LANG')
    where CURRENCY_HEADER_ID = p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    -- oe_debug_pub.add('After Update of TL');

    -- Added by Sunil Pandey 10/01/01
    update QP_CURRENCY_DETAILS set
      selling_rounding_factor        = p_CURR_LISTS_rec.base_rounding_factor
    , markup_operator        = p_CURR_LISTS_rec.base_markup_operator
    , markup_value           = p_CURR_LISTS_rec.base_markup_value
    , markup_formula_id      = p_CURR_LISTS_rec.base_markup_formula_id
    , LAST_UPDATE_DATE       = p_CURR_LISTS_rec.LAST_UPDATE_DATE
    , LAST_UPDATED_BY        = p_CURR_LISTS_rec.LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN      = p_CURR_LISTS_rec.last_update_login
    where CURRENCY_HEADER_ID = p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    and   TO_CURRENCY_CODE   = p_CURR_LISTS_rec.BASE_CURRENCY_CODE;

    -- oe_debug_pub.add('After Update of Details');


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
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
BEGIN
    -- oe_debug_pub.add('INSERT_ROW of Header');
    -- oe_debug_pub.add('Header_id=' || p_CURR_LISTS_rec.currency_header_id);
    -- oe_debug_pub.add('Name=' || p_CURR_LISTS_rec.name);
    -- oe_debug_pub.add('Description=' || p_CURR_LISTS_rec.description);
    -- oe_debug_pub.add('Base Currency=' || p_CURR_LISTS_rec.base_currency_code);
    -- oe_debug_pub.add('Base base_rounding_factor=' || p_CURR_LISTS_rec.base_rounding_factor);
    -- oe_debug_pub.add('Base base_markup_value=' || p_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('Base base_markup_operator=' || p_CURR_LISTS_rec.base_markup_operator);
    -- oe_debug_pub.add('Base base_markup_formula=' || p_CURR_LISTS_rec.base_markup_formula_id);

-- Added by Sunil Pandey 10/01/01
Begin
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
    (       NULL         -- p_CURR_DETAILS_rec.attribute1
    ,       NULL         -- p_CURR_DETAILS_rec.attribute10
    ,       NULL         -- p_CURR_DETAILS_rec.attribute11
    ,       NULL         -- p_CURR_DETAILS_rec.attribute12
    ,       NULL         -- p_CURR_DETAILS_rec.attribute13
    ,       NULL         -- p_CURR_DETAILS_rec.attribute14
    ,       NULL         -- p_CURR_DETAILS_rec.attribute15
    ,       NULL         -- p_CURR_DETAILS_rec.attribute2
    ,       NULL         -- p_CURR_DETAILS_rec.attribute3
    ,       NULL         -- p_CURR_DETAILS_rec.attribute4
    ,       NULL         -- p_CURR_DETAILS_rec.attribute5
    ,       NULL         -- p_CURR_DETAILS_rec.attribute6
    ,       NULL         -- p_CURR_DETAILS_rec.attribute7
    ,       NULL         -- p_CURR_DETAILS_rec.attribute8
    ,       NULL         -- p_CURR_DETAILS_rec.attribute9
    ,       NULL         -- p_CURR_DETAILS_rec.context
    ,       NULL         -- p_CURR_DETAILS_rec.conversion_date
    ,       NULL         -- p_CURR_DETAILS_rec.conversion_date_type
    -- ,       NULL         -- p_CURR_DETAILS_rec.conversion_method
    ,       NULL         -- p_CURR_DETAILS_rec.conversion_type
    ,       p_CURR_LISTS_rec.created_by
    ,       p_CURR_LISTS_rec.creation_date
    ,       QP_CURRENCY_DETAILS_S.nextval
    ,       p_CURR_LISTS_rec.currency_header_id
    ,       NULL          -- p_CURR_DETAILS_rec.end_date_active
    ,       NULL          -- p_CURR_DETAILS_rec.fixed_value
    ,       p_CURR_LISTS_rec.last_updated_by
    ,       p_CURR_LISTS_rec.last_update_date
    ,       p_CURR_LISTS_rec.last_update_login
    ,       p_CURR_LISTS_rec.base_markup_formula_id
    ,       p_CURR_LISTS_rec.base_markup_operator
    ,       p_CURR_LISTS_rec.base_markup_value
    ,       NULL          -- p_CURR_DETAILS_rec.price_formula_id
    ,       NULL          -- p_CURR_DETAILS_rec.program_application_id
    ,       NULL          -- p_CURR_DETAILS_rec.program_id
    ,       NULL          -- p_CURR_DETAILS_rec.program_update_date
    ,       NULL          -- p_CURR_DETAILS_rec.request_id
    ,       p_CURR_LISTS_rec.base_rounding_factor
    ,       NULL          -- p_CURR_DETAILS_rec.start_date_active
    ,       p_CURR_LISTS_rec.base_currency_code
    ,       NULL          -- p_CURR_DETAILS_rec.curr_attribute_type
    ,       NULL          -- p_CURR_DETAILS_rec.curr_attribute_context
    ,       NULL          -- p_CURR_DETAILS_rec.curr_attribute
    ,       NULL          -- p_CURR_DETAILS_rec.curr_attribute_value
    ,       NULL          -- p_CURR_DETAILS_rec.precedence
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
End;
-- Added by Sunil Pandey 10/01/01

-- Added by Sunil
BEGIN
    Insert into QP_CURRENCY_LISTS_TL
    ( CURRENCY_HEADER_ID
    , NAME
    , DESCRIPTION
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LANGUAGE
    , SOURCE_LANG
    ) select
      p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    , p_CURR_LISTS_rec.NAME
    , p_CURR_LISTS_rec.DESCRIPTION
    , p_CURR_LISTS_rec.CREATION_DATE
    , p_CURR_LISTS_rec.CREATED_BY
    , p_CURR_LISTS_rec.LAST_UPDATE_DATE
    , p_CURR_LISTS_rec.LAST_UPDATED_BY
    , p_CURR_LISTS_rec.LAST_UPDATE_LOGIN
    , L.LANGUAGE_CODE
    , userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I','B')
    and not exists
    (select NULL from QP_CURRENCY_LISTS_TL T
    where T.CURRENCY_HEADER_ID = p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

Exception
  WHEN DUP_VAL_ON_INDEX THEN

  FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MULTICURR');
  OE_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End;

    INSERT  INTO QP_CURRENCY_LISTS_B
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
    ,       BASE_CURRENCY_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    )
    VALUES
    (       p_CURR_LISTS_rec.attribute1
    ,       p_CURR_LISTS_rec.attribute10
    ,       p_CURR_LISTS_rec.attribute11
    ,       p_CURR_LISTS_rec.attribute12
    ,       p_CURR_LISTS_rec.attribute13
    ,       p_CURR_LISTS_rec.attribute14
    ,       p_CURR_LISTS_rec.attribute15
    ,       p_CURR_LISTS_rec.attribute2
    ,       p_CURR_LISTS_rec.attribute3
    ,       p_CURR_LISTS_rec.attribute4
    ,       p_CURR_LISTS_rec.attribute5
    ,       p_CURR_LISTS_rec.attribute6
    ,       p_CURR_LISTS_rec.attribute7
    ,       p_CURR_LISTS_rec.attribute8
    ,       p_CURR_LISTS_rec.attribute9
    ,       p_CURR_LISTS_rec.base_currency_code
    ,       p_CURR_LISTS_rec.context
    ,       p_CURR_LISTS_rec.created_by
    ,       p_CURR_LISTS_rec.creation_date
    ,       p_CURR_LISTS_rec.currency_header_id
    ,       p_CURR_LISTS_rec.last_updated_by
    ,       p_CURR_LISTS_rec.last_update_date
    ,       p_CURR_LISTS_rec.last_update_login
    ,       p_CURR_LISTS_rec.program_application_id
    ,       p_CURR_LISTS_rec.program_id
    ,       p_CURR_LISTS_rec.program_update_date
    ,       p_CURR_LISTS_rec.request_id
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        raise;

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
(   p_currency_header_id            IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_CURRENCY_LISTS_B
    WHERE   CURRENCY_HEADER_ID = p_currency_header_id
    ;

    -- Added by Sunil
    DELETE  FROM QP_CURRENCY_LISTS_TL
    WHERE   CURRENCY_HEADER_ID = p_currency_header_id;

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
(   p_currency_header_id            IN  NUMBER
) RETURN QP_Currency_PUB.Curr_Lists_Rec_Type
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
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
    ,       BASE_CURRENCY_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_HEADER_ID
    --,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    --,       NAME
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    --,       ROW_ID
    INTO    l_CURR_LISTS_rec.attribute1
    ,       l_CURR_LISTS_rec.attribute10
    ,       l_CURR_LISTS_rec.attribute11
    ,       l_CURR_LISTS_rec.attribute12
    ,       l_CURR_LISTS_rec.attribute13
    ,       l_CURR_LISTS_rec.attribute14
    ,       l_CURR_LISTS_rec.attribute15
    ,       l_CURR_LISTS_rec.attribute2
    ,       l_CURR_LISTS_rec.attribute3
    ,       l_CURR_LISTS_rec.attribute4
    ,       l_CURR_LISTS_rec.attribute5
    ,       l_CURR_LISTS_rec.attribute6
    ,       l_CURR_LISTS_rec.attribute7
    ,       l_CURR_LISTS_rec.attribute8
    ,       l_CURR_LISTS_rec.attribute9
    ,       l_CURR_LISTS_rec.base_currency_code
    ,       l_CURR_LISTS_rec.context
    ,       l_CURR_LISTS_rec.created_by
    ,       l_CURR_LISTS_rec.creation_date
    ,       l_CURR_LISTS_rec.currency_header_id
    --,       l_CURR_LISTS_rec.description
    ,       l_CURR_LISTS_rec.last_updated_by
    ,       l_CURR_LISTS_rec.last_update_date
    ,       l_CURR_LISTS_rec.last_update_login
    --,       l_CURR_LISTS_rec.name
    ,       l_CURR_LISTS_rec.program_application_id
    ,       l_CURR_LISTS_rec.program_id
    ,       l_CURR_LISTS_rec.program_update_date
    ,       l_CURR_LISTS_rec.request_id
    --,       l_CURR_LISTS_rec.row_id
    --FROM    QP_CURRENCY_LISTS_VL
    FROM    QP_CURRENCY_LISTS_B
    WHERE   CURRENCY_HEADER_ID = p_currency_header_id
    ;

    -- Added by Sunil
    SELECT  NAME
    ,       DESCRIPTION
    INTO    l_CURR_LISTS_rec.name
    ,       l_CURR_LISTS_rec.description
    FROM    QP_CURRENCY_LISTS_TL
    WHERE   CURRENCY_HEADER_ID = p_currency_header_id
    AND     LANGUAGE = userenv('LANG');

    -- oe_debug_pub.add('Inside Query_Row of QPXUCURB; p_currency_header_id: '||p_currency_header_id);
    -- oe_debug_pub.add('Inside Query_Row of QPXUCURB; Base_Currency_Code: '||l_CURR_LISTS_rec.base_currency_code);
    -- Added by Sunil Pandey 10/01/01
    SELECT  selling_rounding_factor
    ,       markup_value
    ,       markup_operator
    ,       markup_formula_id
    INTO    l_CURR_LISTS_rec.base_rounding_factor
    ,       l_CURR_LISTS_rec.base_markup_value
    ,       l_CURR_LISTS_rec.base_markup_operator
    ,       l_CURR_LISTS_rec.base_markup_formula_id
    FROM    QP_CURRENCY_DETAILS
    WHERE   CURRENCY_HEADER_ID = p_currency_header_id
    AND     CONVERSION_TYPE IS NULL
    AND     TO_CURRENCY_CODE = l_CURR_LISTS_rec.base_currency_code;

    -- oe_debug_pub.add('After Select of QP_CURRENCY_DETAILS');


    RETURN l_CURR_LISTS_rec;

EXCEPTION

    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
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
    ,       BASE_CURRENCY_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_HEADER_ID
    -- ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    -- ,       NAME
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    -- ,       ROW_ID
    INTO    l_CURR_LISTS_rec.attribute1
    ,       l_CURR_LISTS_rec.attribute10
    ,       l_CURR_LISTS_rec.attribute11
    ,       l_CURR_LISTS_rec.attribute12
    ,       l_CURR_LISTS_rec.attribute13
    ,       l_CURR_LISTS_rec.attribute14
    ,       l_CURR_LISTS_rec.attribute15
    ,       l_CURR_LISTS_rec.attribute2
    ,       l_CURR_LISTS_rec.attribute3
    ,       l_CURR_LISTS_rec.attribute4
    ,       l_CURR_LISTS_rec.attribute5
    ,       l_CURR_LISTS_rec.attribute6
    ,       l_CURR_LISTS_rec.attribute7
    ,       l_CURR_LISTS_rec.attribute8
    ,       l_CURR_LISTS_rec.attribute9
    ,       l_CURR_LISTS_rec.base_currency_code
    ,       l_CURR_LISTS_rec.context
    ,       l_CURR_LISTS_rec.created_by
    ,       l_CURR_LISTS_rec.creation_date
    ,       l_CURR_LISTS_rec.currency_header_id
    -- ,       l_CURR_LISTS_rec.description
    ,       l_CURR_LISTS_rec.last_updated_by
    ,       l_CURR_LISTS_rec.last_update_date
    ,       l_CURR_LISTS_rec.last_update_login
    -- ,       l_CURR_LISTS_rec.name
    ,       l_CURR_LISTS_rec.program_application_id
    ,       l_CURR_LISTS_rec.program_id
    ,       l_CURR_LISTS_rec.program_update_date
    ,       l_CURR_LISTS_rec.request_id
    -- ,       l_CURR_LISTS_rec.row_id
    -- FROM    QP_CURRENCY_LISTS_VL
    FROM    QP_CURRENCY_LISTS_B
    WHERE   CURRENCY_HEADER_ID = p_CURR_LISTS_rec.currency_header_id
        FOR UPDATE NOWAIT;

    -- Added by Sunil
    SELECT  NAME
    ,       DESCRIPTION
    INTO    l_CURR_LISTS_rec.name
    ,       l_CURR_LISTS_rec.description
    FROM    QP_CURRENCY_LISTS_TL
    WHERE   CURRENCY_HEADER_ID = p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    AND     LANGUAGE = userenv('LANG');

    -- Added by Sunil Pandey 10/01/01
    SELECT  SELLING_ROUNDING_FACTOR
          , MARKUP_OPERATOR
          , MARKUP_VALUE
          , MARKUP_FORMULA_ID
    INTO    l_CURR_LISTS_rec.base_rounding_factor
          , l_CURR_LISTS_rec.base_markup_operator
          , l_CURR_LISTS_rec.base_markup_value
          , l_CURR_LISTS_rec.base_markup_formula_id
    FROM    QP_CURRENCY_DETAILS
    WHERE   CURRENCY_HEADER_ID = p_CURR_LISTS_rec.CURRENCY_HEADER_ID
    AND     TO_CURRENCY_CODE   = p_CURR_LISTS_rec.BASE_CURRENCY_CODE;
        -- FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute1,
                         l_CURR_LISTS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute10,
                         l_CURR_LISTS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute11,
                         l_CURR_LISTS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute12,
                         l_CURR_LISTS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute13,
                         l_CURR_LISTS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute14,
                         l_CURR_LISTS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute15,
                         l_CURR_LISTS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute2,
                         l_CURR_LISTS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute3,
                         l_CURR_LISTS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute4,
                         l_CURR_LISTS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute5,
                         l_CURR_LISTS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute6,
                         l_CURR_LISTS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute7,
                         l_CURR_LISTS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute8,
                         l_CURR_LISTS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.attribute9,
                         l_CURR_LISTS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_currency_code,
                         l_CURR_LISTS_rec.base_currency_code)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.context,
                         l_CURR_LISTS_rec.context)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.created_by,
                         l_CURR_LISTS_rec.created_by)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.creation_date,
                         l_CURR_LISTS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.currency_header_id,
                         l_CURR_LISTS_rec.currency_header_id)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.description,
                         l_CURR_LISTS_rec.description)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_updated_by,
                         l_CURR_LISTS_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_date,
                         l_CURR_LISTS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.last_update_login,
                         l_CURR_LISTS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.name,
                         l_CURR_LISTS_rec.name)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_application_id,
                         l_CURR_LISTS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_id,
                         l_CURR_LISTS_rec.program_id)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.program_update_date,
                         l_CURR_LISTS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.request_id,
                         l_CURR_LISTS_rec.request_id)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_rounding_factor,
                         l_CURR_LISTS_rec.base_rounding_factor)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_value,
                         l_CURR_LISTS_rec.base_markup_value)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_operator,
                         l_CURR_LISTS_rec.base_markup_operator)
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_formula_id,
                         l_CURR_LISTS_rec.base_markup_formula_id)
/* Commented by Sunil
    AND QP_GLOBALS.Equal(p_CURR_LISTS_rec.row_id,
                         l_CURR_LISTS_rec.row_id)
  Commented by Sunil */
    THEN

        --  Row has not changed. Set out parameter.

        x_CURR_LISTS_rec               := l_CURR_LISTS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
) RETURN QP_Currency_PUB.Curr_Lists_Val_Rec_Type
IS
l_CURR_LISTS_val_rec          QP_Currency_PUB.Curr_Lists_Val_Rec_Type;
BEGIN

    -- oe_debug_pub.add('.    ENTERED QP_Curr_Lists_Util.Get_Values');
    IF p_CURR_LISTS_rec.base_currency_code IS NOT NULL AND
        p_CURR_LISTS_rec.base_currency_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_currency_code,
        p_old_CURR_LISTS_rec.base_currency_code)
    THEN
        l_CURR_LISTS_val_rec.base_currency := QP_Id_To_Value.Base_Currency
        (   p_base_currency_code          => p_CURR_LISTS_rec.base_currency_code
        );
    END IF;

    IF p_CURR_LISTS_rec.currency_header_id IS NOT NULL AND
        p_CURR_LISTS_rec.currency_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.currency_header_id,
        p_old_CURR_LISTS_rec.currency_header_id)
    THEN
        l_CURR_LISTS_val_rec.currency_header := QP_Id_To_Value.Currency_Header
        (   p_currency_header_id          => p_CURR_LISTS_rec.currency_header_id
        );
    END IF;

    /*
    -- Added by Sunil Pandey 10/01/01
    IF p_CURR_LISTS_rec.base_markup_formula_id IS NOT NULL AND
        p_CURR_LISTS_rec.base_markup_formula_id <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.base_markup_formula_id,
        p_old_CURR_LISTS_rec.base_markup_formula_id)
    THEN
        l_CURR_LISTS_val_rec.base_markup_formula := QP_Id_To_Value.Base_Markup_Formula
        (   p_base_markup_formula_id   => p_CURR_LISTS_rec.base_markup_formula_id
        );
    END IF;
    */


/* Commented by Sunil
    IF p_CURR_LISTS_rec.row_id IS NOT NULL AND
        p_CURR_LISTS_rec.row_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CURR_LISTS_rec.row_id,
        p_old_CURR_LISTS_rec.row_id)
    THEN
        l_CURR_LISTS_val_rec.row := QP_Id_To_Value.Row
        (   p_row_id                      => p_CURR_LISTS_rec.row_id
        );
    END IF;
  Commented by Sunil */

    -- oe_debug_pub.add('.    EXITING QP_Curr_Lists_Util.Get_Values');
    RETURN l_CURR_LISTS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_CURR_LISTS_val_rec            IN  QP_Currency_PUB.Curr_Lists_Val_Rec_Type
) RETURN QP_Currency_PUB.Curr_Lists_Rec_Type
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_CURR_LISTS_rec.

    l_CURR_LISTS_rec := p_CURR_LISTS_rec;

    IF  p_CURR_LISTS_val_rec.base_currency <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_LISTS_rec.base_currency_code <> FND_API.G_MISS_CHAR THEN

            l_CURR_LISTS_rec.base_currency_code := p_CURR_LISTS_rec.base_currency_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_currency');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_LISTS_rec.base_currency_code := QP_Value_To_Id.base_currency
            (   p_base_currency               => p_CURR_LISTS_val_rec.base_currency
            );

            IF l_CURR_LISTS_rec.base_currency_code = FND_API.G_MISS_CHAR THEN
                l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CURR_LISTS_val_rec.currency_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_LISTS_rec.currency_header_id <> FND_API.G_MISS_NUM THEN

            l_CURR_LISTS_rec.currency_header_id := p_CURR_LISTS_rec.currency_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_LISTS_rec.currency_header_id := QP_Value_To_Id.currency_header
            (   p_currency_header             => p_CURR_LISTS_val_rec.currency_header
            );

            IF l_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM THEN
                l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- Added by Sunil Pandey 10/01/01
    IF  p_CURR_LISTS_val_rec.base_markup_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_LISTS_rec.base_markup_formula_id <> FND_API.G_MISS_NUM THEN

            l_CURR_LISTS_rec.base_markup_formula_id := p_CURR_LISTS_rec.base_markup_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_markup_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_LISTS_rec.base_markup_formula_id := QP_Value_To_Id.Base_Markup_Formula
            (   p_base_markup_formula             => p_CURR_LISTS_val_rec.base_markup_formula
            );

            IF l_CURR_LISTS_rec.base_markup_formula_id = FND_API.G_MISS_NUM THEN
                l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

/* Commented by Sunil
    IF  p_CURR_LISTS_val_rec.row <> FND_API.G_MISS_CHAR
    THEN

        IF p_CURR_LISTS_rec.row_id <> FND_API.G_MISS_CHAR THEN

            l_CURR_LISTS_rec.row_id := p_CURR_LISTS_rec.row_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','row');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CURR_LISTS_rec.row_id := QP_Value_To_Id.row
            (   p_row                         => p_CURR_LISTS_val_rec.row
            );

            IF l_CURR_LISTS_rec.row_id = FND_API.G_MISS_CHAR THEN
                l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
  Commented by Sunil */


    RETURN l_CURR_LISTS_rec;

END Get_Ids;

END QP_Curr_Lists_Util;

/

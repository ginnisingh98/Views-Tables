--------------------------------------------------------
--  DDL for Package Body OE_PRICE_LIST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_LIST_UTIL" AS
/* $Header: OEXUPRHB.pls 120.2 2006/03/21 11:20:46 rnayani noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Price_List_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PRICE_LIST_rec := p_PRICE_LIST_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute1,p_old_PRICE_LIST_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute10,p_old_PRICE_LIST_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute11,p_old_PRICE_LIST_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute12,p_old_PRICE_LIST_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute13,p_old_PRICE_LIST_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute14,p_old_PRICE_LIST_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute15,p_old_PRICE_LIST_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute2,p_old_PRICE_LIST_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute3,p_old_PRICE_LIST_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute4,p_old_PRICE_LIST_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute5,p_old_PRICE_LIST_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute6,p_old_PRICE_LIST_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute7,p_old_PRICE_LIST_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute8,p_old_PRICE_LIST_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute9,p_old_PRICE_LIST_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.comments,p_old_PRICE_LIST_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_COMMENTS;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.context,p_old_PRICE_LIST_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.created_by,p_old_PRICE_LIST_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.creation_date,p_old_PRICE_LIST_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,p_old_PRICE_LIST_rec.currency_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CURRENCY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.description,p_old_PRICE_LIST_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_DESCRIPTION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.end_date_active,p_old_PRICE_LIST_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,p_old_PRICE_LIST_rec.freight_terms_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_FREIGHT_TERMS;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_updated_by,p_old_PRICE_LIST_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_date,p_old_PRICE_LIST_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_login,p_old_PRICE_LIST_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.name,p_old_PRICE_LIST_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_NAME;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.price_list_id,p_old_PRICE_LIST_rec.price_list_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PRICE_LIST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_application_id,p_old_PRICE_LIST_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_id,p_old_PRICE_LIST_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_update_date,p_old_PRICE_LIST_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.request_id,p_old_PRICE_LIST_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_REQUEST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.rounding_factor,p_old_PRICE_LIST_rec.rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ROUNDING_FACTOR;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.secondary_price_list_id,p_old_PRICE_LIST_rec.secondary_price_list_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_SECONDARY_PRICE_LIST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,p_old_PRICE_LIST_rec.ship_method_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_SHIP_METHOD;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.start_date_active,p_old_PRICE_LIST_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,p_old_PRICE_LIST_rec.terms_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_TERMS;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CURRENCY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_CURRENCY;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_FREIGHT_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_FREIGHT_TERMS;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_NAME;
    ELSIF p_attr_id = G_PRICE_LIST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PRICE_LIST;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_ROUNDING_FACTOR;
    ELSIF p_attr_id = G_SECONDARY_PRICE_LIST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_SECONDARY_PRICE_LIST;
    ELSIF p_attr_id = G_SHIP_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_SHIP_METHOD;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_TERMS;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_PRICE_LIST_rec := p_PRICE_LIST_rec;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute1,p_old_PRICE_LIST_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute10,p_old_PRICE_LIST_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute11,p_old_PRICE_LIST_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute12,p_old_PRICE_LIST_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute13,p_old_PRICE_LIST_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute14,p_old_PRICE_LIST_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute15,p_old_PRICE_LIST_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute2,p_old_PRICE_LIST_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute3,p_old_PRICE_LIST_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute4,p_old_PRICE_LIST_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute5,p_old_PRICE_LIST_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute6,p_old_PRICE_LIST_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute7,p_old_PRICE_LIST_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute8,p_old_PRICE_LIST_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.attribute9,p_old_PRICE_LIST_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.comments,p_old_PRICE_LIST_rec.comments)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.context,p_old_PRICE_LIST_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.created_by,p_old_PRICE_LIST_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.creation_date,p_old_PRICE_LIST_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,p_old_PRICE_LIST_rec.currency_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.description,p_old_PRICE_LIST_rec.description)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.end_date_active,p_old_PRICE_LIST_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,p_old_PRICE_LIST_rec.freight_terms_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_updated_by,p_old_PRICE_LIST_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_date,p_old_PRICE_LIST_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_login,p_old_PRICE_LIST_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.name,p_old_PRICE_LIST_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.price_list_id,p_old_PRICE_LIST_rec.price_list_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_application_id,p_old_PRICE_LIST_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_id,p_old_PRICE_LIST_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.program_update_date,p_old_PRICE_LIST_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.request_id,p_old_PRICE_LIST_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.rounding_factor,p_old_PRICE_LIST_rec.rounding_factor)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.secondary_price_list_id,p_old_PRICE_LIST_rec.secondary_price_list_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,p_old_PRICE_LIST_rec.ship_method_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.start_date_active,p_old_PRICE_LIST_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,p_old_PRICE_LIST_rec.terms_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
BEGIN

    IF l_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute1 := p_old_PRICE_LIST_rec.attribute1;
    END IF;

    IF l_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute10 := p_old_PRICE_LIST_rec.attribute10;
    END IF;

    IF l_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute11 := p_old_PRICE_LIST_rec.attribute11;
    END IF;

    IF l_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute12 := p_old_PRICE_LIST_rec.attribute12;
    END IF;

    IF l_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute13 := p_old_PRICE_LIST_rec.attribute13;
    END IF;

    IF l_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute14 := p_old_PRICE_LIST_rec.attribute14;
    END IF;

    IF l_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute15 := p_old_PRICE_LIST_rec.attribute15;
    END IF;

    IF l_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute2 := p_old_PRICE_LIST_rec.attribute2;
    END IF;

    IF l_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute3 := p_old_PRICE_LIST_rec.attribute3;
    END IF;

    IF l_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute4 := p_old_PRICE_LIST_rec.attribute4;
    END IF;

    IF l_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute5 := p_old_PRICE_LIST_rec.attribute5;
    END IF;

    IF l_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute6 := p_old_PRICE_LIST_rec.attribute6;
    END IF;

    IF l_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute7 := p_old_PRICE_LIST_rec.attribute7;
    END IF;

    IF l_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute8 := p_old_PRICE_LIST_rec.attribute8;
    END IF;

    IF l_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute9 := p_old_PRICE_LIST_rec.attribute9;
    END IF;

    IF l_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.comments := p_old_PRICE_LIST_rec.comments;
    END IF;

    IF l_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.context := p_old_PRICE_LIST_rec.context;
    END IF;

    IF l_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.created_by := p_old_PRICE_LIST_rec.created_by;
    END IF;

    IF l_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.creation_date := p_old_PRICE_LIST_rec.creation_date;
    END IF;

    IF l_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.currency_code := p_old_PRICE_LIST_rec.currency_code;
    END IF;

    IF l_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.description := p_old_PRICE_LIST_rec.description;
    END IF;

    IF l_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.end_date_active := p_old_PRICE_LIST_rec.end_date_active;
    END IF;

    IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.freight_terms_code := p_old_PRICE_LIST_rec.freight_terms_code;
    END IF;

    IF l_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.last_updated_by := p_old_PRICE_LIST_rec.last_updated_by;
    END IF;

    IF l_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.last_update_date := p_old_PRICE_LIST_rec.last_update_date;
    END IF;

    IF l_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.last_update_login := p_old_PRICE_LIST_rec.last_update_login;
    END IF;

    IF l_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.name := p_old_PRICE_LIST_rec.name;
    END IF;

    IF l_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.price_list_id := p_old_PRICE_LIST_rec.price_list_id;
    END IF;

    IF l_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.program_application_id := p_old_PRICE_LIST_rec.program_application_id;
    END IF;

    IF l_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.program_id := p_old_PRICE_LIST_rec.program_id;
    END IF;

    IF l_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.program_update_date := p_old_PRICE_LIST_rec.program_update_date;
    END IF;

    IF l_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.request_id := p_old_PRICE_LIST_rec.request_id;
    END IF;

    IF l_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.rounding_factor := p_old_PRICE_LIST_rec.rounding_factor;
    END IF;

    IF l_PRICE_LIST_rec.secondary_price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.secondary_price_list_id := p_old_PRICE_LIST_rec.secondary_price_list_id;
    END IF;

    IF l_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.ship_method_code := p_old_PRICE_LIST_rec.ship_method_code;
    END IF;

    IF l_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.start_date_active := p_old_PRICE_LIST_rec.start_date_active;
    END IF;

    IF l_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.terms_id := p_old_PRICE_LIST_rec.terms_id;
    END IF;

    RETURN l_PRICE_LIST_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
BEGIN

    IF l_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute1 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute10 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute11 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute12 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute13 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute14 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute15 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute2 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute3 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute4 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute5 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute6 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute7 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute8 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.attribute9 := NULL;
    END IF;

    IF l_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.comments := NULL;
    END IF;

    IF l_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.context := NULL;
    END IF;

    IF l_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.created_by := NULL;
    END IF;

    IF l_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.creation_date := NULL;
    END IF;

    IF l_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.currency_code := NULL;
    END IF;

    IF l_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.description := NULL;
    END IF;

    IF l_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.end_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.freight_terms_code := NULL;
    END IF;

    IF l_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.last_updated_by := NULL;
    END IF;

    IF l_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.last_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.last_update_login := NULL;
    END IF;

    IF l_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.name := NULL;
    END IF;

    IF l_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.price_list_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.program_application_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.program_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.program_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.request_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.rounding_factor := NULL;
    END IF;

    IF l_PRICE_LIST_rec.secondary_price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.secondary_price_list_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.ship_method_code := NULL;
    END IF;

    IF l_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.start_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.terms_id := NULL;
    END IF;

    RETURN l_PRICE_LIST_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
)
IS
l_sec_price_list_id number;
l_context varchar2(30);
l_attribute varchar2(30);
BEGIN

  QP_LIST_HEADERS_PKG.UPDATE_ROW (
  X_LIST_HEADER_ID 		=> p_PRICE_LIST_rec.price_list_id,
  X_CONTEXT 			=> p_PRICE_LIST_rec.context,
  X_ATTRIBUTE1			=> p_PRICE_LIST_rec.attribute1,
  X_ATTRIBUTE2			=> p_PRICE_LIST_rec.attribute2,
  X_ATTRIBUTE3			=> p_PRICE_LIST_rec.attribute3,
  X_ATTRIBUTE4			=> p_PRICE_LIST_rec.attribute4,
  X_ATTRIBUTE5			=> p_PRICE_LIST_rec.attribute5,
  X_ATTRIBUTE6			=> p_PRICE_LIST_rec.attribute6,
  X_ATTRIBUTE7			=> p_PRICE_LIST_rec.attribute7,
  X_ATTRIBUTE8			=> p_PRICE_LIST_rec.attribute8,
  X_ATTRIBUTE9			=> p_PRICE_LIST_rec.attribute9,
  X_ATTRIBUTE10			=> p_PRICE_LIST_rec.attribute10,
  X_ATTRIBUTE11			=> p_PRICE_LIST_rec.attribute11,
  X_ATTRIBUTE12			=> p_PRICE_LIST_rec.attribute12,
  X_ATTRIBUTE13			=> p_PRICE_LIST_rec.attribute13,
  X_ATTRIBUTE14			=> p_PRICE_LIST_rec.attribute14,
  X_ATTRIBUTE15			=> p_PRICE_LIST_rec.attribute15,
  X_CURRENCY_CODE		=> p_PRICE_LIST_rec.currency_code,
  X_SHIP_METHOD_CODE		=> p_PRICE_LIST_rec.ship_method_code,
  X_FREIGHT_TERMS_CODE		=> p_PRICE_LIST_rec.freight_terms_code,
  X_START_DATE_ACTIVE		=> p_PRICE_LIST_rec.start_date_active,
  X_END_DATE_ACTIVE		=> p_PRICE_LIST_rec.end_date_active,
  X_AUTOMATIC_FLAG		=> 'N',
  X_LIST_TYPE_CODE		=> 'PRL',
  X_TERMS_ID			=> p_PRICE_LIST_rec.terms_id,
  X_ROUNDING_FACTOR		=> p_PRICE_LIST_rec.rounding_factor,
  X_REQUEST_ID			=> p_PRICE_LIST_rec.request_id,
  X_NAME			=> p_PRICE_LIST_rec.name,
  X_DESCRIPTION			=> p_PRICE_LIST_rec.description,
  X_LAST_UPDATE_DATE		=> p_PRICE_LIST_rec.last_update_date,
  X_LAST_UPDATED_BY		=> p_PRICE_LIST_rec.last_updated_by,
  X_LAST_UPDATE_LOGIN		=> p_PRICE_LIST_rec.last_update_login );

  /* delete qualifier for secondary price list and create a new qualifier */

   QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);

   l_sec_price_list_id :=
                          QP_Price_List_PVT.Get_Secondary_Price_List(
                                p_Price_List_rec.price_list_id);

   IF l_sec_price_list_id is not null THEN

       delete from qp_qualifiers
       where qualifier_context = l_context
       and qualifier_attribute = l_attribute
       and qualifier_attr_value = p_PRICE_LIST_rec.price_list_id
       and list_header_id = l_sec_price_list_id
       and qualifier_rule_id is null;

       /* create a new qualifier for the new secondary price list id */

       INSERT INTO QP_QUALIFIERS (
         QUALIFIER_ID,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
    	 LAST_UPDATE_LOGIN,
         LIST_HEADER_ID,
         COMPARISON_OPERATOR_CODE,
         QUALIFIER_CONTEXT,
	     QUALIFIER_ATTRIBUTE,
         QUALIFIER_ATTR_VALUE,
         QUALIFIER_GROUPING_NO,
         EXCLUDER_FLAG
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,ORIG_SYS_QUALIFIER_REF
         ,ORIG_SYS_HEADER_REF
       )
       VALUES (
		 QP_QUALIFIERS_S.nextval,
         sysdate,
         1,
         sysdate,
         1,
		 1,
         p_PRICE_LIST_rec.secondary_price_list_id,
         '=',
		 l_context,
         l_attribute,
         to_char(p_PRICE_LIST_rec.price_list_id),
         qp.qp_qualifier_group_no_s.nextval,
		 'N'
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,to_char(QP_QUALIFIERS_S.CURRVAL)
         ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_PRICE_LIST_rec.secondary_price_list_id)
       );

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
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
)
IS
-- new added
-- cursor not added to get rowid
l_rowid varchar2(240); /* should it be varchar2(100)? */
l_context varchar2(30) := NULL;
l_attribute varchar2(30) := NULL;
l_qualifier_grouping_no NUMBER := 0;
l_sec_qualifier_grouping_no NUMBER := 0;

BEGIN

    oe_debug_pub.add('Entering OE_Price_List_Util.Insert_Row');

    /* need to add x_comments,
                   x_program_id
              and tp_attributes  to the insert_row procedure */

    QP_LIST_HEADERS_PKG.INSERT_ROW (
  X_ROWID 			=> l_rowid,
  X_LIST_HEADER_ID 		=> p_PRICE_LIST_rec.price_list_id,
  X_CONTEXT 			=> p_PRICE_LIST_rec.context,
  X_ATTRIBUTE1			=> p_PRICE_LIST_rec.attribute1,
  X_ATTRIBUTE2			=> p_PRICE_LIST_rec.attribute2,
  X_ATTRIBUTE3			=> p_PRICE_LIST_rec.attribute3,
  X_ATTRIBUTE4			=> p_PRICE_LIST_rec.attribute4,
  X_ATTRIBUTE5			=> p_PRICE_LIST_rec.attribute5,
  X_ATTRIBUTE6			=> p_PRICE_LIST_rec.attribute6,
  X_ATTRIBUTE7			=> p_PRICE_LIST_rec.attribute7,
  X_ATTRIBUTE8			=> p_PRICE_LIST_rec.attribute8,
  X_ATTRIBUTE9			=> p_PRICE_LIST_rec.attribute9,
  X_ATTRIBUTE10			=> p_PRICE_LIST_rec.attribute10,
  X_ATTRIBUTE11			=> p_PRICE_LIST_rec.attribute11,
  X_ATTRIBUTE12			=> p_PRICE_LIST_rec.attribute12,
  X_ATTRIBUTE13			=> p_PRICE_LIST_rec.attribute13,
  X_ATTRIBUTE14			=> p_PRICE_LIST_rec.attribute14,
  X_ATTRIBUTE15			=> p_PRICE_LIST_rec.attribute15,
  X_CURRENCY_CODE		=> p_PRICE_LIST_rec.currency_code,
  X_SHIP_METHOD_CODE		=> p_PRICE_LIST_rec.ship_method_code,
  X_FREIGHT_TERMS_CODE		=> p_PRICE_LIST_rec.freight_terms_code,
  X_START_DATE_ACTIVE		=> p_PRICE_LIST_rec.start_date_active,
  X_END_DATE_ACTIVE		=> p_PRICE_LIST_rec.end_date_active,
  X_AUTOMATIC_FLAG		=> 'N',
  X_LIST_TYPE_CODE		=> 'PRL',
  X_TERMS_ID			=> p_PRICE_LIST_rec.terms_id,
  X_ROUNDING_FACTOR		=> p_PRICE_LIST_rec.rounding_factor,
  X_REQUEST_ID			=> p_PRICE_LIST_rec.request_id,
  X_NAME			=> p_PRICE_LIST_rec.name,
  X_DESCRIPTION			=> p_PRICE_LIST_rec.description,
  X_CREATION_DATE		=> p_PRICE_LIST_rec.creation_date,
  X_CREATED_BY			=> p_PRICE_LIST_rec.created_by,
  X_LAST_UPDATE_DATE		=> p_PRICE_LIST_rec.last_update_date,
  X_LAST_UPDATED_BY		=> p_PRICE_LIST_rec.last_updated_by,
  X_LAST_UPDATE_LOGIN		=> p_PRICE_LIST_rec.last_update_login );

  /* create self qualifier for price list */

      QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);


          INSERT INTO QP_QUALIFIERS (
		QUALIFIER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                COMPARISON_OPERATOR_CODE,
                QUALIFIER_CONTEXT,
		QUALIFIER_ATTRIBUTE,
                QUALIFIER_ATTR_VALUE,
                QUALIFIER_GROUPING_NO,
                EXCLUDER_FLAG
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,ORIG_SYS_QUALIFIER_REF
         ,ORIG_SYS_HEADER_REF)
                VALUES (
		QP_QUALIFIERS_S.nextval,
                sysdate,
                1,
                sysdate,
                1,
		1,
                p_PRICE_LIST_rec.price_list_id,
                '=',
		l_context,
                l_attribute,
                to_char(p_PRICE_LIST_rec.price_list_id),
                qp_qualifier_group_no_s.nextval,
		'N'
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,to_char(QP_QUALIFIERS_S.CURRVAL)
         ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_PRICE_LIST_rec.price_list_id)
        );

    /* create qualifier for secondary price list */

     IF p_PRICE_LIST_rec.secondary_price_list_id is not null THEN

      INSERT INTO QP_QUALIFIERS (
		QUALIFIER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                COMPARISON_OPERATOR_CODE,
                QUALIFIER_CONTEXT,
		QUALIFIER_ATTRIBUTE,
                QUALIFIER_ATTR_VALUE,
                QUALIFIER_GROUPING_NO,
                EXCLUDER_FLAG
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,ORIG_SYS_QUALIFIER_REF
         ,ORIG_SYS_HEADER_REF
                )
                VALUES (
		QP_QUALIFIERS_S.nextval,
                sysdate,
                1,
                sysdate,
                1,
		1,
                p_PRICE_LIST_rec.secondary_price_list_id,
                '=',
		l_context,
                l_attribute,
                to_char(p_PRICE_LIST_rec.price_list_id),
                qp_qualifier_group_no_s.nextval,
		'N'
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,to_char(QP_QUALIFIERS_S.CURRVAL)
         ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_PRICE_LIST_rec.secondary_price_list_id)
        );
     END IF;


/*


    INSERT  INTO OE_PRICE_LISTS_B
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
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_CODE
    ,       DESCRIPTION
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SECONDARY_PRICE_LIST_ID
    ,       SHIP_METHOD_CODE
    ,       START_DATE_ACTIVE
    ,       TERMS_ID
    ,	  TP_ATTRIBUTE1
    ,	  TP_ATTRIBUTE2
    ,	  TP_ATTRIBUTE3
    ,	  TP_ATTRIBUTE4
    ,	  TP_ATTRIBUTE5
    ,	  TP_ATTRIBUTE6
    ,	  TP_ATTRIBUTE7
    ,	  TP_ATTRIBUTE8
    ,	  TP_ATTRIBUTE9
    ,	  TP_ATTRIBUTE10
    ,	  TP_ATTRIBUTE11
    ,	  TP_ATTRIBUTE12
    ,	  TP_ATTRIBUTE13
    ,	  TP_ATTRIBUTE14
    ,	  TP_ATTRIBUTE15
    ,	  TP_ATTRIBUTE_CATEGORY
    )
    VALUES
    (       p_PRICE_LIST_rec.attribute1
    ,       p_PRICE_LIST_rec.attribute10
    ,       p_PRICE_LIST_rec.attribute11
    ,       p_PRICE_LIST_rec.attribute12
    ,       p_PRICE_LIST_rec.attribute13
    ,       p_PRICE_LIST_rec.attribute14
    ,       p_PRICE_LIST_rec.attribute15
    ,       p_PRICE_LIST_rec.attribute2
    ,       p_PRICE_LIST_rec.attribute3
    ,       p_PRICE_LIST_rec.attribute4
    ,       p_PRICE_LIST_rec.attribute5
    ,       p_PRICE_LIST_rec.attribute6
    ,       p_PRICE_LIST_rec.attribute7
    ,       p_PRICE_LIST_rec.attribute8
    ,       p_PRICE_LIST_rec.attribute9
    ,       p_PRICE_LIST_rec.comments
    ,       p_PRICE_LIST_rec.context
    ,       p_PRICE_LIST_rec.created_by
    ,       p_PRICE_LIST_rec.creation_date
    ,       p_PRICE_LIST_rec.currency_code
    ,       p_PRICE_LIST_rec.description
    ,       p_PRICE_LIST_rec.end_date_active
    ,       p_PRICE_LIST_rec.freight_terms_code
    ,       p_PRICE_LIST_rec.last_updated_by
    ,       p_PRICE_LIST_rec.last_update_date
    ,       p_PRICE_LIST_rec.last_update_login
    ,       p_PRICE_LIST_rec.name
    ,       p_PRICE_LIST_rec.price_list_id
    ,       p_PRICE_LIST_rec.program_application_id
    ,       p_PRICE_LIST_rec.program_id
    ,       p_PRICE_LIST_rec.program_update_date
    ,       p_PRICE_LIST_rec.request_id
    ,       p_PRICE_LIST_rec.rounding_factor
    ,       p_PRICE_LIST_rec.secondary_price_list_id
    ,       p_PRICE_LIST_rec.ship_method_code
    ,       p_PRICE_LIST_rec.start_date_active
    ,       p_PRICE_LIST_rec.terms_id
    ,	  p_PRICE_LIST_rec.tp_attribute1
    ,	  p_PRICE_LIST_rec.tp_attribute2
    ,	  p_PRICE_LIST_rec.tp_attribute3
    ,	  p_PRICE_LIST_rec.tp_attribute4
    ,	  p_PRICE_LIST_rec.tp_attribute5
    ,	  p_PRICE_LIST_rec.tp_attribute6
    ,	  p_PRICE_LIST_rec.tp_attribute7
    ,	  p_PRICE_LIST_rec.tp_attribute8
    ,	  p_PRICE_LIST_rec.tp_attribute9
    ,	  p_PRICE_LIST_rec.tp_attribute10
    ,	  p_PRICE_LIST_rec.tp_attribute11
    ,	  p_PRICE_LIST_rec.tp_attribute12
    ,	  p_PRICE_LIST_rec.tp_attribute13
    ,	  p_PRICE_LIST_rec.tp_attribute14
    ,	  p_PRICE_LIST_rec.tp_attribute15
    ,	  p_PRICE_LIST_rec.tp_attribute_category
    );

	insert into OE_PRICE_LISTS_TL (
    	CREATION_DATE,
   	CREATED_BY,
	LAST_UPDATE_LOGIN,
	NAME,
  	LAST_UPDATE_DATE,
  	LAST_UPDATED_BY,
  	PRICE_LIST_ID,
  	LANGUAGE,
	SOURCE_LANG )
	select p_PRICE_LIST_rec.creation_date ,
		  p_PRICE_LIST_rec.created_by,
		  p_PRICE_LIST_rec.last_update_login ,
		  p_PRICE_LIST_rec.name ,
		  p_PRICE_LIST_rec.last_update_date ,
		  p_PRICE_LIST_rec.last_updated_by ,
		  p_PRICE_LIST_rec.price_list_id ,
		  L.language_code ,
		  userenv('LANG')
	from FND_LANGUAGES L
	where L.installed_flag in ('I','B')
	and not exists
		 ( select NULL from oe_price_lists_tl T
			where T.price_list_id = p_PRICE_LIST_rec.price_list_id
			and T.language = L.language_code ) ;

    */






    oe_debug_pub.add('Exiting OE_Price_List_Util.Insert_Row');

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
(   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
)
IS
l_sec_price_list_id number;
l_context varchar2(30);
l_attribute varchar2(30);
BEGIN

   QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);

   l_sec_price_list_id :=
                          Qp_Price_List_Pvt.Get_Secondary_Price_List(
                               p_price_list_id);

    QP_LIST_HEADERS_PKG.Delete_Row(p_price_list_id);

       IF l_sec_price_list_id is not null THEN

         delete from qp_qualifiers
         where qualifier_context = l_context
         and qualifier_attribute = l_attribute
         and qualifier_attr_value = p_price_list_id
         and list_header_id = l_sec_price_list_id
         and qualifier_rule_id is null;

       END IF;

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
(   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
) RETURN OE_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;
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
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_CODE
    ,       DESCRIPTION
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       LIST_HEADER_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SHIP_METHOD_CODE
    ,       START_DATE_ACTIVE
    ,       TERMS_ID
    INTO    l_PRICE_LIST_rec.attribute1
    ,       l_PRICE_LIST_rec.attribute10
    ,       l_PRICE_LIST_rec.attribute11
    ,       l_PRICE_LIST_rec.attribute12
    ,       l_PRICE_LIST_rec.attribute13
    ,       l_PRICE_LIST_rec.attribute14
    ,       l_PRICE_LIST_rec.attribute15
    ,       l_PRICE_LIST_rec.attribute2
    ,       l_PRICE_LIST_rec.attribute3
    ,       l_PRICE_LIST_rec.attribute4
    ,       l_PRICE_LIST_rec.attribute5
    ,       l_PRICE_LIST_rec.attribute6
    ,       l_PRICE_LIST_rec.attribute7
    ,       l_PRICE_LIST_rec.attribute8
    ,       l_PRICE_LIST_rec.attribute9
    ,       l_PRICE_LIST_rec.comments
    ,       l_PRICE_LIST_rec.context
    ,       l_PRICE_LIST_rec.created_by
    ,       l_PRICE_LIST_rec.creation_date
    ,       l_PRICE_LIST_rec.currency_code
    ,       l_PRICE_LIST_rec.description
    ,       l_PRICE_LIST_rec.end_date_active
    ,       l_PRICE_LIST_rec.freight_terms_code
    ,       l_PRICE_LIST_rec.last_updated_by
    ,       l_PRICE_LIST_rec.last_update_date
    ,       l_PRICE_LIST_rec.last_update_login
    ,       l_PRICE_LIST_rec.name
    ,       l_PRICE_LIST_rec.price_list_id
    ,       l_PRICE_LIST_rec.program_application_id
    ,       l_PRICE_LIST_rec.program_id
    ,       l_PRICE_LIST_rec.program_update_date
    ,       l_PRICE_LIST_rec.request_id
    ,       l_PRICE_LIST_rec.rounding_factor
    ,       l_PRICE_LIST_rec.ship_method_code
    ,       l_PRICE_LIST_rec.start_date_active
    ,       l_PRICE_LIST_rec.terms_id
    FROM    QP_LIST_HEADERS_VL
    WHERE   LIST_HEADER_ID = p_price_list_id;

    l_PRICE_LIST_rec.secondary_price_list_id :=
                          Qp_Price_List_Pvt.Get_Secondary_Price_List(
                                p_price_list_id);

    RETURN l_PRICE_LIST_rec;

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
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
)
IS
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;
BEGIN

  QP_LIST_HEADERS_PKG.LOCK_ROW (
  X_LIST_HEADER_ID 		=> p_PRICE_LIST_rec.price_list_id,
  X_CONTEXT 			=> p_PRICE_LIST_rec.context,
  X_ATTRIBUTE1			=> p_PRICE_LIST_rec.attribute1,
  X_ATTRIBUTE2			=> p_PRICE_LIST_rec.attribute2,
  X_ATTRIBUTE3			=> p_PRICE_LIST_rec.attribute3,
  X_ATTRIBUTE4			=> p_PRICE_LIST_rec.attribute4,
  X_ATTRIBUTE5			=> p_PRICE_LIST_rec.attribute5,
  X_ATTRIBUTE6			=> p_PRICE_LIST_rec.attribute6,
  X_ATTRIBUTE7			=> p_PRICE_LIST_rec.attribute7,
  X_ATTRIBUTE8			=> p_PRICE_LIST_rec.attribute8,
  X_ATTRIBUTE9			=> p_PRICE_LIST_rec.attribute9,
  X_ATTRIBUTE10			=> p_PRICE_LIST_rec.attribute10,
  X_ATTRIBUTE11			=> p_PRICE_LIST_rec.attribute11,
  X_ATTRIBUTE12			=> p_PRICE_LIST_rec.attribute12,
  X_ATTRIBUTE13			=> p_PRICE_LIST_rec.attribute13,
  X_ATTRIBUTE14			=> p_PRICE_LIST_rec.attribute14,
  X_ATTRIBUTE15			=> p_PRICE_LIST_rec.attribute15,
  X_CURRENCY_CODE		=> p_PRICE_LIST_rec.currency_code,
  X_SHIP_METHOD_CODE		=> p_PRICE_LIST_rec.ship_method_code,
  X_FREIGHT_TERMS_CODE		=> p_PRICE_LIST_rec.freight_terms_code,
  X_START_DATE_ACTIVE		=> p_PRICE_LIST_rec.start_date_active,
  X_END_DATE_ACTIVE		=> p_PRICE_LIST_rec.end_date_active,
  X_AUTOMATIC_FLAG		=> 'N',
  X_LIST_TYPE_CODE		=> 'PRL',
  X_TERMS_ID			=> p_PRICE_LIST_rec.terms_id,
  X_ROUNDING_FACTOR		=> p_PRICE_LIST_rec.rounding_factor,
  X_REQUEST_ID			=> p_PRICE_LIST_rec.request_id,
  X_NAME			=> p_PRICE_LIST_rec.name,
  X_DESCRIPTION			=> p_PRICE_LIST_rec.description);

   x_PRICE_LIST_rec := p_PRICE_LIST_rec;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
) RETURN OE_Price_List_PUB.Price_List_Val_Rec_Type
IS
l_PRICE_LIST_val_rec          OE_Price_List_PUB.Price_List_Val_Rec_Type;
BEGIN

    IF p_PRICE_LIST_rec.currency_code IS NOT NULL AND
        p_PRICE_LIST_rec.currency_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,
        p_old_PRICE_LIST_rec.currency_code)
    THEN
        l_PRICE_LIST_val_rec.currency := OE_Id_To_Value.Currency
        (   p_currency_code               => p_PRICE_LIST_rec.currency_code
        );
    END IF;

    IF p_PRICE_LIST_rec.freight_terms_code IS NOT NULL AND
        p_PRICE_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,
        p_old_PRICE_LIST_rec.freight_terms_code)
    THEN
        l_PRICE_LIST_val_rec.freight_terms := OE_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_PRICE_LIST_rec.freight_terms_code
        );
    END IF;

/* may be commented after validation in program */
/* no need to do this validation :: OEXLPLHB.pls

    IF p_PRICE_LIST_rec.price_list_id IS NOT NULL AND
        p_PRICE_LIST_rec.price_list_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.price_list_id,
        p_old_PRICE_LIST_rec.price_list_id)
    THEN
        l_PRICE_LIST_val_rec.price_list := OE_Id_To_Value.Price_List
        (   p_price_list_id               => p_PRICE_LIST_rec.price_list_id
        );

	l_PRICE_LIST_val_rec.price_list := NULL;
    END IF;
*/

    IF p_PRICE_LIST_rec.secondary_price_list_id IS NOT NULL AND
        p_PRICE_LIST_rec.secondary_price_list_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.secondary_price_list_id,
        p_old_PRICE_LIST_rec.secondary_price_list_id)
    THEN
        l_PRICE_LIST_val_rec.secondary_price_list := OE_Id_To_Value.Secondary_Price_List
        (   p_secondary_price_list_id     => p_PRICE_LIST_rec.secondary_price_list_id
        );
    END IF;

    IF p_PRICE_LIST_rec.ship_method_code IS NOT NULL AND
        p_PRICE_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,
        p_old_PRICE_LIST_rec.ship_method_code)
    THEN
        l_PRICE_LIST_val_rec.ship_method := OE_Id_To_Value.Ship_Method
        (   p_ship_method_code            => p_PRICE_LIST_rec.ship_method_code
        );
    END IF;

    IF p_PRICE_LIST_rec.terms_id IS NOT NULL AND
        p_PRICE_LIST_rec.terms_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,
        p_old_PRICE_LIST_rec.terms_id)
    THEN
        l_PRICE_LIST_val_rec.terms := OE_Id_To_Value.Terms
        (   p_terms_id                    => p_PRICE_LIST_rec.terms_id
        );
    END IF;

    RETURN l_PRICE_LIST_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  OE_Price_List_PUB.Price_List_Val_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICE_LIST_rec.

    l_PRICE_LIST_rec := p_PRICE_LIST_rec;

    IF  p_PRICE_LIST_val_rec.currency <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.currency_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.currency_code := p_PRICE_LIST_rec.currency_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.currency_code := OE_Value_To_Id.currency
            (   p_currency                    => p_PRICE_LIST_val_rec.currency
            );

            IF l_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.freight_terms_code := p_PRICE_LIST_rec.freight_terms_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.freight_terms_code := OE_Value_To_Id.freight_terms
            (   p_freight_terms               => p_PRICE_LIST_val_rec.freight_terms
            );

            IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_rec.price_list_id := p_PRICE_LIST_rec.price_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.price_list_id := OE_Value_To_Id.price_list
            (   p_price_list                  => p_PRICE_LIST_val_rec.price_list
            );

            IF l_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.secondary_price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.secondary_price_list_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_rec.secondary_price_list_id := p_PRICE_LIST_rec.secondary_price_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','secondary_price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.secondary_price_list_id := OE_Value_To_Id.secondary_price_list
            (   p_secondary_price_list        => p_PRICE_LIST_val_rec.secondary_price_list
            );

            IF l_PRICE_LIST_rec.secondary_price_list_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.ship_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.ship_method_code := p_PRICE_LIST_rec.ship_method_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.ship_method_code := OE_Value_To_Id.ship_method
            (   p_ship_method                 => p_PRICE_LIST_val_rec.ship_method
            );

            IF l_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.terms_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_rec.terms_id := p_PRICE_LIST_rec.terms_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.terms_id := OE_Value_To_Id.terms
            (   p_terms                       => p_PRICE_LIST_val_rec.terms
            );

            IF l_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PRICE_LIST_rec;

END Get_Ids;


END OE_Price_List_Util;

/

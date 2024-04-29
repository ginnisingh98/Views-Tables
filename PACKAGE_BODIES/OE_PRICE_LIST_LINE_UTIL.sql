--------------------------------------------------------
--  DDL for Package Body OE_PRICE_LIST_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_LIST_LINE_UTIL" AS
/* $Header: OEXUPRLB.pls 120.2 2006/03/21 11:21:09 rnayani noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Price_List_Line_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                OE_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute1,p_old_PRICE_LIST_LINE_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute10,p_old_PRICE_LIST_LINE_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute11,p_old_PRICE_LIST_LINE_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute12,p_old_PRICE_LIST_LINE_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute13,p_old_PRICE_LIST_LINE_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute14,p_old_PRICE_LIST_LINE_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute15,p_old_PRICE_LIST_LINE_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute2,p_old_PRICE_LIST_LINE_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute3,p_old_PRICE_LIST_LINE_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute4,p_old_PRICE_LIST_LINE_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute5,p_old_PRICE_LIST_LINE_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute6,p_old_PRICE_LIST_LINE_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute7,p_old_PRICE_LIST_LINE_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute8,p_old_PRICE_LIST_LINE_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute9,p_old_PRICE_LIST_LINE_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.comments,p_old_PRICE_LIST_LINE_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_COMMENTS;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.context,p_old_PRICE_LIST_LINE_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.created_by,p_old_PRICE_LIST_LINE_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.creation_date,p_old_PRICE_LIST_LINE_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id,p_old_PRICE_LIST_LINE_rec.customer_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CUSTOMER_ITEM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.end_date_active,p_old_PRICE_LIST_LINE_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,p_old_PRICE_LIST_LINE_rec.inventory_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_INVENTORY_ITEM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_updated_by,p_old_PRICE_LIST_LINE_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_date,p_old_PRICE_LIST_LINE_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_login,p_old_PRICE_LIST_LINE_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_price,p_old_PRICE_LIST_LINE_rec.list_price)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LIST_PRICE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.method_code,p_old_PRICE_LIST_LINE_rec.method_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_METHOD;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_list_id,p_old_PRICE_LIST_LINE_rec.price_list_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICE_LIST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_list_line_id,p_old_PRICE_LIST_LINE_rec.price_list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICE_LIST_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute1,p_old_PRICE_LIST_LINE_rec.pricing_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute10,p_old_PRICE_LIST_LINE_rec.pricing_attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute11,p_old_PRICE_LIST_LINE_rec.pricing_attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute12,p_old_PRICE_LIST_LINE_rec.pricing_attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute13,p_old_PRICE_LIST_LINE_rec.pricing_attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute14,p_old_PRICE_LIST_LINE_rec.pricing_attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute15,p_old_PRICE_LIST_LINE_rec.pricing_attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute2,p_old_PRICE_LIST_LINE_rec.pricing_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute3,p_old_PRICE_LIST_LINE_rec.pricing_attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute4,p_old_PRICE_LIST_LINE_rec.pricing_attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute5,p_old_PRICE_LIST_LINE_rec.pricing_attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute6,p_old_PRICE_LIST_LINE_rec.pricing_attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute7,p_old_PRICE_LIST_LINE_rec.pricing_attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute8,p_old_PRICE_LIST_LINE_rec.pricing_attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_attribute9,p_old_PRICE_LIST_LINE_rec.pricing_attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_context,p_old_PRICE_LIST_LINE_rec.pricing_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_rule_id,p_old_PRICE_LIST_LINE_rec.pricing_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_RULE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.primary,p_old_PRICE_LIST_LINE_rec.primary)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRIMARY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_application_id,p_old_PRICE_LIST_LINE_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_id,p_old_PRICE_LIST_LINE_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_update_date,p_old_PRICE_LIST_LINE_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,p_old_PRICE_LIST_LINE_rec.reprice_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REPRICE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.request_id,p_old_PRICE_LIST_LINE_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REQUEST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision,p_old_PRICE_LIST_LINE_rec.revision)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_date,p_old_PRICE_LIST_LINE_rec.revision_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,p_old_PRICE_LIST_LINE_rec.revision_reason_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION_REASON;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.start_date_active,p_old_PRICE_LIST_LINE_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.unit_code,p_old_PRICE_LIST_LINE_rec.unit_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_UNIT;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CUSTOMER_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_CUSTOMER_ITEM;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_INVENTORY_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_INVENTORY_ITEM;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_PRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_LIST_PRICE;
    ELSIF p_attr_id = G_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_METHOD;
    ELSIF p_attr_id = G_PRICE_LIST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICE_LIST;
    ELSIF p_attr_id = G_PRICE_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICE_LIST_LINE;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE1;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE10;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE11;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE12;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE13;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE14;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE15;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE2;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE3;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE4;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE5;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE6;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE7;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE8;
    ELSIF p_attr_id = G_PRICING_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_ATTRIBUTE9;
    ELSIF p_attr_id = G_PRICING_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_CONTEXT;
    ELSIF p_attr_id = G_PRICING_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRICING_RULE;
    ELSIF p_attr_id = G_PRIMARY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PRIMARY;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REPRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REPRICE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_REVISION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION;
    ELSIF p_attr_id = G_REVISION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION_DATE;
    ELSIF p_attr_id = G_REVISION_REASON THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_REVISION_REASON;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_UNIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_LINE_UTIL.G_UNIT;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_primary_exists BOOLEAN;
BEGIN

    oe_debug_pub.add('Entering OE_Price_List_Line_Util.Apply_Attribute_Changes' || p_Price_List_Line_rec.price_list_id || ' ' || p_PRICE_LIST_LINE_rec.price_list_line_id);

    --  Load out record

    x_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    IF ( NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute1,p_old_Price_List_Line_rec.attribute1) )
    OR ( NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute10,p_old_Price_List_Line_rec.attribute10))
    OR ( NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute11,p_old_Price_List_Line_rec.attribute11) )
    OR ( NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute12,p_old_Price_List_Line_rec.attribute12))
    OR ( NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute13,p_old_Price_List_Line_rec.attribute13))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute14,p_old_Price_List_Line_rec.attribute14))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute15,p_old_Price_List_Line_rec.attribute15))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute2,p_old_Price_List_Line_rec.attribute2))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute3,p_old_Price_List_Line_rec.attribute3))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute4,p_old_Price_List_Line_rec.attribute4))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute5,p_old_Price_List_Line_rec.attribute5))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute6,p_old_Price_List_Line_rec.attribute6))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute7,p_old_Price_List_Line_rec.attribute7))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute8,p_old_Price_List_Line_rec.attribute8))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.attribute9,p_old_Price_List_Line_rec.attribute9))
    OR (NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.context,p_old_Price_List_Line_rec.context))
    THEN
	        --  Validate descriptive flexfield.

        IF NOT OE_Validate_Attr.Desc_Flex( 'PRICE_LIST_LINE' ) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute1,p_old_PRICE_LIST_LINE_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute10,p_old_PRICE_LIST_LINE_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute11,p_old_PRICE_LIST_LINE_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute12,p_old_PRICE_LIST_LINE_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute13,p_old_PRICE_LIST_LINE_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute14,p_old_PRICE_LIST_LINE_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute15,p_old_PRICE_LIST_LINE_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute2,p_old_PRICE_LIST_LINE_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute3,p_old_PRICE_LIST_LINE_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute4,p_old_PRICE_LIST_LINE_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute5,p_old_PRICE_LIST_LINE_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute6,p_old_PRICE_LIST_LINE_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute7,p_old_PRICE_LIST_LINE_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute8,p_old_PRICE_LIST_LINE_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute9,p_old_PRICE_LIST_LINE_rec.attribute9)
    THEN
        NULL;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.comments,p_old_Price_List_Line_rec.comments)
    THEN
        IF NOT OE_Validate_Attr.Comments(p_Price_List_Line_rec.comments) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.context,p_old_Price_List_Line_rec.context)
    THEN
        NULL;  /* need to figure out how to check this for desc flex field */
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.created_by,p_old_Price_List_Line_rec.created_by)
    THEN
        IF NOT OE_Validate_Attr.Created_By(p_Price_List_Line_rec.created_by) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.creation_date,p_old_Price_List_Line_rec.creation_date)
    THEN
        IF NOT OE_Validate_Attr.Creation_Date(p_Price_List_Line_rec.creation_date)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.customer_item_id,p_old_Price_List_Line_rec.customer_item_id)
    THEN
        IF NOT OE_Validate_Attr.Customer_Item(p_Price_List_Line_rec.customer_item_id)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.end_date_active,p_old_Price_List_Line_rec.end_date_active)
    THEN
        IF NOT OE_Validate_Attr.End_Date_Active(p_Price_List_Line_rec.end_date_active) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;

         ELSIF NOT OE_Validate_Attr.Start_Date_End_Date(
                       p_Price_List_Line_rec.start_date_active,
                       p_Price_List_Line_rec.end_date_active) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.inventory_item_id,p_old_Price_List_Line_rec.inventory_item_id)
    THEN
        IF NOT OE_Validate_Attr.Inventory_Item(p_Price_List_Line_rec.inventory_item_id) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.last_updated_by,p_old_Price_List_Line_rec.last_updated_by)
    THEN
        IF NOT OE_Validate_Attr.Last_Updated_By(p_Price_List_Line_rec.last_updated_by)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.last_update_date,p_old_Price_List_Line_rec.last_update_date)
    THEN
	IF NOT OE_Validate_Attr.Last_Update_Date(p_Price_List_Line_rec.last_update_date) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.last_update_login,p_old_Price_List_Line_rec.last_update_login)
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Login(p_Price_List_Line_rec.last_update_login) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.list_price,p_old_Price_List_Line_rec.list_price)
    THEN
        IF NOT OE_Validate_Attr.List_Price(p_Price_List_Line_rec.list_price) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.method_code,p_old_Price_List_Line_rec.method_code)
    THEN
        IF NOT OE_Validate_Attr.Method(p_Price_List_Line_rec.method_code) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.price_list_id,p_old_Price_List_Line_rec.price_list_id)
    THEN
        IF NOT OE_Validate_Attr.Price_List(p_Price_List_Line_rec.price_list_id)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.price_list_line_id,p_old_Price_List_Line_rec.price_list_line_id)
    THEN
        IF NOT OE_Validate_Attr.Price_List_Line(p_Price_List_Line_rec.price_list_line_id) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute1,p_old_Price_List_Line_rec.pricing_attribute1)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute1(p_Price_List_Line_rec.pricing_attribute1) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute10,p_old_Price_List_Line_rec.pricing_attribute10)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute10(p_Price_List_Line_rec.pricing_attribute10)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute11,p_old_Price_List_Line_rec.pricing_attribute11)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute11(p_Price_List_Line_rec.pricing_attribute11)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute12,p_old_Price_List_Line_rec.pricing_attribute12)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute12(p_Price_List_Line_rec.pricing_attribute12)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute13,p_old_Price_List_Line_rec.pricing_attribute13)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute13(p_Price_List_Line_rec.pricing_attribute13)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute14,p_old_Price_List_Line_rec.pricing_attribute14)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute14(p_Price_List_Line_rec.pricing_attribute14)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute15,p_old_Price_List_Line_rec.pricing_attribute15)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute15(p_Price_List_Line_rec.pricing_attribute15)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute2,p_old_Price_List_Line_rec.pricing_attribute2)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute2(p_Price_List_Line_rec.pricing_attribute2)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute3,p_old_Price_List_Line_rec.pricing_attribute3)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute3(p_Price_List_Line_rec.pricing_attribute3)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute4,p_old_Price_List_Line_rec.pricing_attribute4)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute4(p_Price_List_Line_rec.pricing_attribute4)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute5,p_old_Price_List_Line_rec.pricing_attribute5)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute5(p_Price_List_Line_rec.pricing_attribute5)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute6,p_old_Price_List_Line_rec.pricing_attribute6)
    THEN
       IF NOT OE_Validate_Attr.Pricing_Attribute6(p_Price_List_Line_rec.pricing_attribute6)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute7,p_old_Price_List_Line_rec.pricing_attribute7)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute7(p_Price_List_Line_rec.pricing_attribute7)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute8,p_old_Price_List_Line_rec.pricing_attribute8)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute8(p_Price_List_Line_rec.pricing_attribute8)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_attribute9,p_old_Price_List_Line_rec.pricing_attribute9)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Attribute9(p_Price_List_Line_rec.pricing_attribute9)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_context,p_old_Price_List_Line_rec.pricing_context)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Context(p_Price_List_Line_rec.pricing_context) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.pricing_rule_id,p_old_Price_List_Line_rec.pricing_rule_id)
    THEN
        IF NOT OE_Validate_Attr.Pricing_Rule(p_Price_List_Line_rec.pricing_rule_id)
	THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.program_application_id,p_old_Price_List_Line_rec.program_application_id)
    THEN
        IF NOT OE_Validate_Attr.Program_Application(p_Price_List_Line_rec.program_application_id) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.program_id,p_old_Price_List_Line_rec.program_id)
    THEN
	IF NOT OE_Validate_Attr.Program(p_Price_List_Line_rec.program_id) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.program_update_date,p_old_Price_List_Line_rec.program_update_date)
    THEN
        IF NOT OE_Validate_Attr.Program_Update_Date(p_Price_List_Line_rec.program_update_date) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.reprice_flag,p_old_Price_List_Line_rec.reprice_flag)
    THEN
        IF NOT OE_Validate_Attr.Reprice(p_Price_List_Line_rec.reprice_flag) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.request_id,p_old_Price_List_Line_rec.request_id)
    THEN
        IF NOT OE_Validate_Attr.Request(p_Price_List_Line_rec.request_id) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.revision,p_old_Price_List_Line_rec.revision)
    THEN
        IF NOT OE_Validate_Attr.Revision(p_Price_List_Line_rec.revision) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.revision_date,p_old_Price_List_Line_rec.revision_date)
    THEN
        IF NOT OE_Validate_Attr.Revision_Date(p_Price_List_Line_rec.revision_date) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.revision_reason_code,p_old_Price_List_Line_rec.revision_reason_code)
    THEN
        IF NOT OE_Validate_Attr.Revision_Reason(p_Price_List_Line_rec.revision_reason_code) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.start_date_active,p_old_Price_List_Line_rec.start_date_active)
    THEN
        IF NOT OE_Validate_Attr.Start_Date_Active(p_Price_List_Line_rec.start_date_active) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;

        ELSIF NOT OE_Validate_Attr.Start_Date_End_Date(
                       p_Price_List_Line_rec.start_date_active,
                       p_Price_List_Line_rec.end_date_active) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.unit_code,p_old_Price_List_Line_rec.unit_code)
    THEN
        IF NOT OE_Validate_Attr.Unit(p_Price_List_Line_rec.unit_code) THEN
            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_List_Line_rec.primary,p_old_Price_List_Line_rec.primary)
    THEN

-- 2 parameters added start date and end date :: Geresh
       l_primary_exists :=
                 OE_VALIDATE_ATTR.PRIMARY_EXISTS(
                 p_Price_List_Line_rec.price_list_id,
                 p_Price_List_Line_rec.inventory_item_id,
                 p_Price_List_Line_rec.customer_item_id,
                 p_Price_List_Line_rec.pricing_attribute1,
                 p_Price_List_Line_rec.pricing_attribute2,
                 p_Price_List_Line_rec.pricing_attribute3,
                 p_Price_List_Line_rec.pricing_attribute4,
                 p_Price_List_Line_rec.pricing_attribute5,
                 p_Price_List_Line_rec.pricing_attribute6,
                 p_Price_List_Line_rec.pricing_attribute7,
                 p_Price_List_Line_rec.pricing_attribute8,
                 p_Price_List_Line_rec.pricing_attribute9,
                 p_Price_List_Line_rec.pricing_attribute10,
                 p_Price_List_Line_rec.pricing_attribute11,
                 p_Price_List_Line_rec.pricing_attribute12,
                 p_Price_List_Line_rec.pricing_attribute13,
                 p_Price_List_Line_rec.pricing_attribute14,
                 p_Price_List_Line_rec.pricing_attribute15,
		 p_Price_List_Line_rec.start_date_active ,
		 p_Price_List_Line_rec.end_date_active );

      oe_debug_pub.add('price line rec primary ulb is : ' || p_Price_List_Line_rec.primary);

      IF p_Price_List_Line_rec.primary = 'Y' THEN

         IF l_primary_exists THEN

/*
            x_Price_List_Line_rec.primary := 'N';
*/

	 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
	       	FND_MESSAGE.SET_NAME('OE','OE_CANNOT_CREATE_PRIMARY');
            	OE_MSG_PUB.Add;

         END IF;


            x_Price_List_Line_rec.return_status := FND_API.G_RET_STS_ERROR;

         END IF;



      END IF;

    END IF;

    oe_debug_pub.add('Exiting OE_Price_List_Line_Util.Apply_Attribute_Changes');

END Apply_Attribute_Changes;


--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type := p_PRICE_LIST_LINE_rec;
BEGIN

    IF l_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute1 := p_old_PRICE_LIST_LINE_rec.attribute1;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute10 := p_old_PRICE_LIST_LINE_rec.attribute10;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute11 := p_old_PRICE_LIST_LINE_rec.attribute11;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute12 := p_old_PRICE_LIST_LINE_rec.attribute12;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute13 := p_old_PRICE_LIST_LINE_rec.attribute13;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute14 := p_old_PRICE_LIST_LINE_rec.attribute14;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute15 := p_old_PRICE_LIST_LINE_rec.attribute15;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute2 := p_old_PRICE_LIST_LINE_rec.attribute2;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute3 := p_old_PRICE_LIST_LINE_rec.attribute3;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute4 := p_old_PRICE_LIST_LINE_rec.attribute4;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute5 := p_old_PRICE_LIST_LINE_rec.attribute5;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute6 := p_old_PRICE_LIST_LINE_rec.attribute6;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute7 := p_old_PRICE_LIST_LINE_rec.attribute7;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute8 := p_old_PRICE_LIST_LINE_rec.attribute8;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute9 := p_old_PRICE_LIST_LINE_rec.attribute9;
    END IF;

    IF l_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.comments := p_old_PRICE_LIST_LINE_rec.comments;
    END IF;

    IF l_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.context := p_old_PRICE_LIST_LINE_rec.context;
    END IF;

    IF l_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.created_by := p_old_PRICE_LIST_LINE_rec.created_by;
    END IF;

    IF l_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.creation_date := p_old_PRICE_LIST_LINE_rec.creation_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.customer_item_id := p_old_PRICE_LIST_LINE_rec.customer_item_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.end_date_active := p_old_PRICE_LIST_LINE_rec.end_date_active;
    END IF;

    IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.inventory_item_id := p_old_PRICE_LIST_LINE_rec.inventory_item_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_updated_by := p_old_PRICE_LIST_LINE_rec.last_updated_by;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.last_update_date := p_old_PRICE_LIST_LINE_rec.last_update_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_update_login := p_old_PRICE_LIST_LINE_rec.last_update_login;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_price := p_old_PRICE_LIST_LINE_rec.list_price;
    END IF;

    IF l_PRICE_LIST_LINE_rec.method_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.method_code := p_old_PRICE_LIST_LINE_rec.method_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_list_id := p_old_PRICE_LIST_LINE_rec.price_list_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_list_line_id := p_old_PRICE_LIST_LINE_rec.price_list_line_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute1 := p_old_PRICE_LIST_LINE_rec.pricing_attribute1;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute10 := p_old_PRICE_LIST_LINE_rec.pricing_attribute10;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute11 := p_old_PRICE_LIST_LINE_rec.pricing_attribute11;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute12 := p_old_PRICE_LIST_LINE_rec.pricing_attribute12;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute13 := p_old_PRICE_LIST_LINE_rec.pricing_attribute13;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute14 := p_old_PRICE_LIST_LINE_rec.pricing_attribute14;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute15 := p_old_PRICE_LIST_LINE_rec.pricing_attribute15;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute2 := p_old_PRICE_LIST_LINE_rec.pricing_attribute2;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute3 := p_old_PRICE_LIST_LINE_rec.pricing_attribute3;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute4 := p_old_PRICE_LIST_LINE_rec.pricing_attribute4;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute5 := p_old_PRICE_LIST_LINE_rec.pricing_attribute5;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute6 := p_old_PRICE_LIST_LINE_rec.pricing_attribute6;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute7 := p_old_PRICE_LIST_LINE_rec.pricing_attribute7;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute8 := p_old_PRICE_LIST_LINE_rec.pricing_attribute8;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute9 := p_old_PRICE_LIST_LINE_rec.pricing_attribute9;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_context := p_old_PRICE_LIST_LINE_rec.pricing_context;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_rule_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.pricing_rule_id := p_old_PRICE_LIST_LINE_rec.pricing_rule_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.primary := p_old_PRICE_LIST_LINE_rec.primary;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_application_id := p_old_PRICE_LIST_LINE_rec.program_application_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_id := p_old_PRICE_LIST_LINE_rec.program_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.program_update_date := p_old_PRICE_LIST_LINE_rec.program_update_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.reprice_flag := p_old_PRICE_LIST_LINE_rec.reprice_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.request_id := p_old_PRICE_LIST_LINE_rec.request_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision := p_old_PRICE_LIST_LINE_rec.revision;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.revision_date := p_old_PRICE_LIST_LINE_rec.revision_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision_reason_code := p_old_PRICE_LIST_LINE_rec.revision_reason_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.start_date_active := p_old_PRICE_LIST_LINE_rec.start_date_active;
    END IF;

    IF l_PRICE_LIST_LINE_rec.unit_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.unit_code := p_old_PRICE_LIST_LINE_rec.unit_code;
    END IF;

    RETURN l_PRICE_LIST_LINE_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type := p_PRICE_LIST_LINE_rec;
BEGIN

    IF l_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute1 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute10 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute11 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute12 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute13 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute14 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute15 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute2 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute3 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute4 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute5 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute6 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute7 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute8 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute9 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.comments := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.context := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.created_by := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.creation_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.customer_item_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.end_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.inventory_item_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_updated_by := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.last_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_update_login := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_price := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.method_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.method_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_list_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_list_line_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute1 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute10 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute11 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute12 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute13 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute14 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute15 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute2 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute3 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute4 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute5 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute6 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute7 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute8 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_attribute9 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.pricing_context := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.pricing_rule_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.pricing_rule_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.primary := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_application_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.program_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.reprice_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.request_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.revision_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision_reason_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.start_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.unit_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.unit_code := NULL;
    END IF;

    RETURN l_PRICE_LIST_LINE_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_list_price number := NULL;
l_percent_price number := NULL;
x_return_status varchar2(30);
BEGIN

    IF p_PRICE_LIST_LINE_rec.method_code = 'AMNT' THEN
         l_list_price := p_PRICE_LIST_LINE_rec.list_price;
    else
         l_percent_price := p_PRICE_LIST_LINE_rec.list_price;
    END IF;

    /* reprice_flag and tp_attributes are missing- need to add */

    UPDATE  QP_LIST_LINES
    SET     ATTRIBUTE1                     = p_PRICE_LIST_LINE_rec.attribute1
    ,       ATTRIBUTE10                    = p_PRICE_LIST_LINE_rec.attribute10
    ,       ATTRIBUTE11                    = p_PRICE_LIST_LINE_rec.attribute11
    ,       ATTRIBUTE12                    = p_PRICE_LIST_LINE_rec.attribute12
    ,       ATTRIBUTE13                    = p_PRICE_LIST_LINE_rec.attribute13
    ,       ATTRIBUTE14                    = p_PRICE_LIST_LINE_rec.attribute14
    ,       ATTRIBUTE15                    = p_PRICE_LIST_LINE_rec.attribute15
    ,       ATTRIBUTE2                     = p_PRICE_LIST_LINE_rec.attribute2
    ,       ATTRIBUTE3                     = p_PRICE_LIST_LINE_rec.attribute3
    ,       ATTRIBUTE4                     = p_PRICE_LIST_LINE_rec.attribute4
    ,       ATTRIBUTE5                     = p_PRICE_LIST_LINE_rec.attribute5
    ,       ATTRIBUTE6                     = p_PRICE_LIST_LINE_rec.attribute6
    ,       ATTRIBUTE7                     = p_PRICE_LIST_LINE_rec.attribute7
    ,       ATTRIBUTE8                     = p_PRICE_LIST_LINE_rec.attribute8
    ,       ATTRIBUTE9                     = p_PRICE_LIST_LINE_rec.attribute9
    ,       COMMENTS                       = p_PRICE_LIST_LINE_rec.comments
    ,       CONTEXT                        = p_PRICE_LIST_LINE_rec.context
    ,       CREATED_BY                     = p_PRICE_LIST_LINE_rec.created_by
    ,       CREATION_DATE                  = p_PRICE_LIST_LINE_rec.creation_date
    ,       END_DATE_ACTIVE                = p_PRICE_LIST_LINE_rec.end_date_active
    ,       LAST_UPDATE_DATE               = p_PRICE_LIST_LINE_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_PRICE_LIST_LINE_rec.last_update_login
    ,       LIST_PRICE                     = l_list_price
    ,       LIST_HEADER_ID                 = p_PRICE_LIST_LINE_rec.price_list_id
    ,       GENERATE_USING_FORMULA_ID      = p_PRICE_LIST_LINE_rec.pricing_rule_id
    ,       PRIMARY_UOM_FLAG               = p_PRICE_LIST_LINE_rec.primary
    ,       PROGRAM_APPLICATION_ID         = p_PRICE_LIST_LINE_rec.program_application_id
    ,       PROGRAM_ID                     = p_PRICE_LIST_LINE_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PRICE_LIST_LINE_rec.program_update_date
    ,       REQUEST_ID                     = p_PRICE_LIST_LINE_rec.request_id
    ,       REVISION                       = p_PRICE_LIST_LINE_rec.revision
    ,       REVISION_DATE                  = p_PRICE_LIST_LINE_rec.revision_date
    ,       REVISION_REASON_CODE           = p_PRICE_LIST_LINE_rec.revision_reason_code
    ,       START_DATE_ACTIVE              = p_PRICE_LIST_LINE_rec.start_date_active
    ,       LIST_PRICE_UOM_CODE            = p_PRICE_LIST_LINE_rec.unit_code
    ,       PERCENT_PRICE                  = l_percent_price
    ,       LAST_UPDATED_BY                = p_PRICE_LIST_LINE_rec.last_updated_by
    ,       LIST_LINE_TYPE_CODE            = p_PRICE_LIST_LINE_rec.list_line_type_code
    WHERE   LIST_LINE_ID = p_PRICE_LIST_LINE_rec.price_list_line_id
    ;

   oe_debug_pub.initialize;
   oe_debug_pub.debug_on;
   oe_debug_pub.add ( 'Geresh 6 :: Before Maintain attributes ' );

     maintain_pricing_attributes(p_PRICE_LIST_LINE_rec, 'UPDATE', x_return_status);




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
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_product_context varchar2(30);
l_customer_item_context varchar2(30);
l_product_attr varchar2(30);
l_customer_item_attr varchar2(30);
l_pricing_attr_rec OE_PRICE_LIST_PUB.Pricing_Attr_Rec_Type;
l_pricing_attr_tbl OE_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
l_attribute_grouping_no number;
l_pricing_attribute_id number;
I number := 1;
J number := 1;
l_related_modifier_id number;
l_rltd_modifier_grp_no number;
x_return_status varchar2(30);
BEGIN
oe_debug_pub.add ( 'Insert Values' || p_PRICE_LIST_LINE_rec.comments );

  insert into qp_list_lines(
  LIST_LINE_ID,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  REQUEST_ID,
  LIST_HEADER_ID,
  LIST_LINE_TYPE_CODE,
  START_DATE_ACTIVE, /* START_DATE_EFFECTIVE */
  END_DATE_ACTIVE,   /* END_DATE_EFFECTIVE */
  AUTOMATIC_FLAG,
  MODIFIER_LEVEL_CODE,
  LIST_PRICE,
  LIST_PRICE_UOM_CODE,
  PRIMARY_UOM_FLAG,
  INVENTORY_ITEM_ID,
  ORGANIZATION_ID,
  RELATED_ITEM_ID,
  RELATIONSHIP_TYPE_ID,
  SUBSTITUTION_CONTEXT,
  SUBSTITUTION_ATTRIBUTE,
  SUBSTITUTION_VALUE,
  REVISION,
  REVISION_DATE,
  REVISION_REASON_CODE,
  CONTEXT,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  COMMENTS,
  PRICE_BREAK_TYPE_CODE,
  PERCENT_PRICE,
  EFFECTIVE_PERIOD_UOM,
  NUMBER_EFFECTIVE_PERIODS,
  OPERAND,
  ARITHMETIC_OPERATOR,
  OVERRIDE_FLAG,
  PRINT_ON_INVOICE_FLAG,
  REBATE_TRANSACTION_TYPE_CODE,
  BASE_QTY,
  BASE_UOM_CODE,
  ACCRUAL_QTY,
  ACCRUAL_UOM_CODE,
  ESTIM_ACCRUAL_RATE,
  PRICE_BY_FORMULA_ID,
  GENERATE_USING_FORMULA_ID
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,orig_sys_line_ref
  ,ORIG_SYS_HEADER_REF
  /* , REPRICE_FLAG,
      TP_ATTRIBUTE1,
 TP_ATTRIBUTE2,
 TP_ATTRIBUTE3,
 TP_ATTRIBUTE4,
 TP_ATTRIBUTE5,
 TP_ATTRIBUTE6,
 TP_ATTRIBUTE7,
 TP_ATTRIBUTE8,
 TP_ATTRIBUTE9,
 TP_ATTRIBUTE10,
 TP_ATTRIBUTE11,
 TP_ATTRIBUTE12,
 TP_ATTRIBUTE13,
 TP_ATTRIBUTE14,
 TP_ATTRIBUTE15,
 TP_ATTRIBUTE_CATEGORY */ )
values(
  p_PRICE_LIST_LINE_rec.price_list_line_id,
  p_PRICE_LIST_LINE_rec.creation_date,
  p_PRICE_LIST_LINE_rec.created_by,
  p_PRICE_LIST_LINE_rec.last_update_date,
  p_PRICE_LIST_LINE_rec.last_updated_by,
  p_PRICE_LIST_LINE_rec.last_update_login,
  p_PRICE_LIST_LINE_rec.program_application_id,
  p_PRICE_LIST_LINE_rec.program_id,
  p_PRICE_LIST_LINE_rec.program_update_date,
  p_PRICE_LIST_LINE_rec.request_id,
  p_PRICE_LIST_LINE_rec.price_list_id,
  'PLL',
  p_PRICE_LIST_LINE_rec.start_date_active, /* no need to do nvl */
  p_PRICE_LIST_LINE_rec.end_date_active,
  'Y',
  'LINE',
  DECODE(p_PRICE_LIST_LINE_rec.method_code, 'AMNT',p_PRICE_LIST_LINE_rec.list_price,NULL),
  p_PRICE_LIST_LINE_rec.unit_code,
  p_PRICE_LIST_LINE_rec.primary,
  NULL, /* INVENTORY_ITEM_ID */
  NULL, /* ORGANIZATION_ID */
  NULL, /* RELATED_ITEM_ID */
  NULL, /* RELATIONSHIP_TYPE_ID */
  NULL, /* SUBSTITUTION_CONTEXT */
  NULL, /* SUBSTITUTION_ATTRIBUTE */
  NULL, /* SUBSTITUTION_VALUE */
  p_PRICE_LIST_LINE_rec.revision,
  p_PRICE_LIST_LINE_rec.revision_date,
  p_PRICE_LIST_LINE_rec.revision_reason_code,
  p_PRICE_LIST_LINE_rec.context,
  p_PRICE_LIST_LINE_rec.attribute1,
  p_PRICE_LIST_LINE_rec.attribute2,
  p_PRICE_LIST_LINE_rec.attribute3,
  p_PRICE_LIST_LINE_rec.attribute4,
  p_PRICE_LIST_LINE_rec.attribute5,
  p_PRICE_LIST_LINE_rec.attribute6,
  p_PRICE_LIST_LINE_rec.attribute7,
  p_PRICE_LIST_LINE_rec.attribute8,
  p_PRICE_LIST_LINE_rec.attribute9,
  p_PRICE_LIST_LINE_rec.attribute10,
  p_PRICE_LIST_LINE_rec.attribute11,
  p_PRICE_LIST_LINE_rec.attribute12,
  p_PRICE_LIST_LINE_rec.attribute13,
  p_PRICE_LIST_LINE_rec.attribute14,
  p_PRICE_LIST_LINE_rec.attribute15,
  p_PRICE_LIST_LINE_rec.comments,
  NULL, /* p_PRICE_LIST_LINE_rec.price_break_type_code, */
  DECODE(p_PRICE_LIST_LINE_rec.method_code, 'PERC', p_PRICE_LIST_LINE_rec.list_price, NULL),
  NULL, /* EFFECTIVE_PERIOD_UOM */
  NULL, /* NUMBER_EFFECTIVE_PERIODS */
  NULL, /* OPERAND */
  NULL, /* ARITHMETIC_OPERATOR */
  NULL, /* OVERRIDE_FLAG */
  NULL, /* PRINT_ON_INVOICE_FLAG */
  NULL, /* REBATE_TRANSACTION_TYPE_CODE */
  NULL, /* BASE_QTY */
  NULL, /* BASE_UOM_CODE */
  NULL, /* ACCRUAL_QTY */
  NUll, /* ACCRUAL_UOM_CODE */
  NULL, /* ESTIM_ACCRUAL_RATE */
  NULL, /* PRICE_BY_FORMULA_ID */
  p_PRICE_LIST_LINE_rec.pricing_rule_id
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,to_char(p_PRICE_LIST_LINE_rec.price_list_line_id)
  ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_PRICE_LIST_LINE_rec.price_list_id)
 /* , p_PRICE_LIST_LINE_rec.REPRICE_FLAG,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE1,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE2,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE3,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE4,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE5,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE6,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE7,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE8,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE9,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE10,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE11,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE12,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE13,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE14,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE15,
 p_PRICE_LIST_LINE_rec.TP_ATTRIBUTE_CATEGORY */ );


   oe_debug_pub.initialize;
   oe_debug_pub.debug_on;
   oe_debug_pub.add ( 'Geresh 7 :: Before Maintain attributes ' );

 maintain_pricing_attributes(p_PRICE_LIST_LINE_rec, 'INSERT', x_return_status);

   oe_debug_pub.add ( 'Geresh 7 :: Outpiut' || x_return_status  );


/********************************************************/
/* insertion into translation table may need to be done */
/********************************************************/

    EXCEPTION

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_list_line_id            IN  NUMBER
)
IS

l_list_line_type_code varchar2(30);

cursor child_lines is
select to_rltd_modifier_id, rltd_modifier_id
from qp_rltd_modifiers
where from_rltd_modifier_id = p_price_list_line_id;

BEGIN
oe_debug_pub.add ( 'AAA - deleted ');

   /* If list_line_type_code = 'PBH', we need to delete all the children
      list lines */

    select list_line_type_code
    into l_list_line_type_code
    from qp_list_lines
    where list_line_id = p_price_list_line_id;


    if (l_list_line_type_code = 'PBH') then

        for child_lines_rec in child_lines loop

           DELETE  FROM QP_LIST_LINES
           WHERE   LIST_LINE_ID = child_lines_rec.to_rltd_modifier_id;

           DELETE FROM QP_PRICING_ATTRIBUTES
           WHERE LIST_LINE_ID = child_lines_rec.to_rltd_modifier_id;

           QP_RLTD_MODIFIER_PVT.Delete_Row(child_lines_rec.rltd_modifier_id);

        end loop;

    elsif l_list_line_type_code = 'PLL' then

       BEGIN

        DELETE from QP_RLTD_MODIFIERS
        where TO_RLTD_MODIFIER_ID = p_price_list_line_id;

       EXCEPTION

          WHEN NO_DATA_FOUND THEN NULL;

       END;

    	DELETE FROM QP_PRICING_ATTRIBUTES
    	WHERE LIST_LINE_ID = p_price_list_line_id;

        DELETE FROM QP_LIST_LINES
    	WHERE LIST_LINE_ID = p_price_list_line_id;

    end if;

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
(   p_price_list_line_id            IN  NUMBER
,   p_price_list_id            IN  NUMBER
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_price_list_line_id          => p_price_list_line_id
        ,   p_price_list_id          => p_price_list_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_price_list_line_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_list_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Price_List_PUB.Price_List_Line_Tbl_Type
IS
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_method_code VARCHAR2(30) := NULL;

CURSOR l_PRICE_LIST_LINE_csr IS
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
    ,       CUSTOMER_ITEM_ID
    ,       END_DATE_ACTIVE
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_PRICE
    ,       METHOD_CODE
    ,       PRICE_LIST_ID
    ,       PRICE_LIST_LINE_ID
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE11
    ,       PRICING_ATTRIBUTE12
    ,       PRICING_ATTRIBUTE13
    ,       PRICING_ATTRIBUTE14
    ,       PRICING_ATTRIBUTE15
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_RULE_ID
    ,       PRIMARY
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       UNIT_CODE
    FROM    QP_PRICE_LIST_LINES_V
    WHERE ( PRICE_LIST_LINE_ID = p_price_list_line_id)
    OR (PRICE_LIST_ID = p_price_list_id);

BEGIN

    IF
    (p_price_list_line_id IS NOT NULL
     AND
     p_price_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_price_list_id IS NOT NULL
     AND
     p_price_list_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: price_list_line_id = '|| p_price_list_line_id || ', price_list_id = '|| p_price_list_id
                );
            END IF;

-- Geresh Temporary comment
    /*    RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_PRICE_LIST_LINE_csr LOOP

        l_PRICE_LIST_LINE_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_PRICE_LIST_LINE_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_PRICE_LIST_LINE_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_PRICE_LIST_LINE_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_PRICE_LIST_LINE_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_PRICE_LIST_LINE_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_PRICE_LIST_LINE_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_PRICE_LIST_LINE_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_PRICE_LIST_LINE_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_PRICE_LIST_LINE_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_PRICE_LIST_LINE_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_PRICE_LIST_LINE_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_PRICE_LIST_LINE_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_PRICE_LIST_LINE_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_PRICE_LIST_LINE_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_PRICE_LIST_LINE_rec.comments := l_implicit_rec.COMMENTS;
        l_PRICE_LIST_LINE_rec.context  := l_implicit_rec.CONTEXT;
        l_PRICE_LIST_LINE_rec.created_by := l_implicit_rec.CREATED_BY;
        l_PRICE_LIST_LINE_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_PRICE_LIST_LINE_rec.customer_item_id := l_implicit_rec.CUSTOMER_ITEM_ID;
        l_PRICE_LIST_LINE_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.inventory_item_id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_PRICE_LIST_LINE_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICE_LIST_LINE_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICE_LIST_LINE_rec.list_price := l_implicit_rec.LIST_PRICE;
        l_PRICE_LIST_LINE_rec.method_code := l_method_code;
        l_PRICE_LIST_LINE_rec.price_list_id := l_implicit_rec.PRICE_LIST_ID;
        l_PRICE_LIST_LINE_rec.price_list_line_id := l_implicit_rec.PRICE_LIST_LINE_ID;
        l_PRICE_LIST_LINE_rec.pricing_attribute1 := l_implicit_rec.PRICING_ATTRIBUTE1;
        l_PRICE_LIST_LINE_rec.pricing_attribute10 := l_implicit_rec.PRICING_ATTRIBUTE10;
        l_PRICE_LIST_LINE_rec.pricing_attribute11 := l_implicit_rec.PRICING_ATTRIBUTE11;
        l_PRICE_LIST_LINE_rec.pricing_attribute12 := l_implicit_rec.PRICING_ATTRIBUTE12;
        l_PRICE_LIST_LINE_rec.pricing_attribute13 := l_implicit_rec.PRICING_ATTRIBUTE13;
        l_PRICE_LIST_LINE_rec.pricing_attribute14 := l_implicit_rec.PRICING_ATTRIBUTE14;
        l_PRICE_LIST_LINE_rec.pricing_attribute15 := l_implicit_rec.PRICING_ATTRIBUTE15;
        l_PRICE_LIST_LINE_rec.pricing_attribute2 := l_implicit_rec.PRICING_ATTRIBUTE2;
        l_PRICE_LIST_LINE_rec.pricing_attribute3 := l_implicit_rec.PRICING_ATTRIBUTE3;
        l_PRICE_LIST_LINE_rec.pricing_attribute4 := l_implicit_rec.PRICING_ATTRIBUTE4;
        l_PRICE_LIST_LINE_rec.pricing_attribute5 := l_implicit_rec.PRICING_ATTRIBUTE5;
        l_PRICE_LIST_LINE_rec.pricing_attribute6 := l_implicit_rec.PRICING_ATTRIBUTE6;
        l_PRICE_LIST_LINE_rec.pricing_attribute7 := l_implicit_rec.PRICING_ATTRIBUTE7;
        l_PRICE_LIST_LINE_rec.pricing_attribute8 := l_implicit_rec.PRICING_ATTRIBUTE8;
        l_PRICE_LIST_LINE_rec.pricing_attribute9 := l_implicit_rec.PRICING_ATTRIBUTE9;
        l_PRICE_LIST_LINE_rec.pricing_context := l_implicit_rec.PRICING_CONTEXT;
        l_PRICE_LIST_LINE_rec.pricing_rule_id := l_implicit_rec.PRICING_RULE_ID;
        l_PRICE_LIST_LINE_rec.primary  := l_implicit_rec.PRIMARY;
        l_PRICE_LIST_LINE_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICE_LIST_LINE_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_PRICE_LIST_LINE_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.reprice_flag := l_implicit_rec.REPRICE_FLAG;
        l_PRICE_LIST_LINE_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_PRICE_LIST_LINE_rec.revision := l_implicit_rec.REVISION;
        l_PRICE_LIST_LINE_rec.revision_date := l_implicit_rec.REVISION_DATE;
        l_PRICE_LIST_LINE_rec.revision_reason_code := l_implicit_rec.REVISION_REASON_CODE;
        l_PRICE_LIST_LINE_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.unit_code := l_implicit_rec.UNIT_CODE;

        l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_tbl.COUNT + 1) := l_PRICE_LIST_LINE_rec;


    END LOOP;


    --  PK sent and no rows found

    IF
    (p_price_list_line_id IS NOT NULL
     AND
     p_price_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (l_PRICE_LIST_LINE_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_PRICE_LIST_LINE_tbl;

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


PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
) is
l_PRICE_LIST_LINE_rec oe_price_list_pub.price_list_line_rec_type;
l_percent_price number;
l_list_price number;
l_automatic_flag varchar2(30);
l_list_line_type_code varchar2(30);
l_modifier_level_code varchar2(30);
l_list_line_id number;
BEGIN

   l_list_line_type_code := 'PLL';
   l_automatic_flag := 'Y';
   l_modifier_level_code := 'LINE';
   l_list_line_id := p_PRICE_LIST_LINE_rec.price_list_line_id;

   If p_PRICE_LIST_LINE_rec.method_code = 'PERC' THEN

      l_percent_price := p_PRICE_LIST_LINE_rec.list_price;

   else

      l_list_price := p_PRICE_LIST_LINE_rec.list_price;

   end if;



lock_pricing_attributes(p_list_line_id => l_list_line_id,
                        x_return_status => x_return_status);


   QP_MODIFIER_LIST_LINE_PVT.Lock_Row(
X_LIST_LINE_ID			=> l_list_line_id
, X_CREATION_DATE		=> p_PRICE_LIST_LINE_rec.creation_date
, X_CREATED_BY			=> p_PRICE_LIST_LINE_rec.created_by
, X_LAST_UPDATE_DATE		=> p_PRICE_LIST_LINE_rec.last_update_date
, X_LAST_UPDATED_BY		=> p_PRICE_LIST_LINE_rec.last_updated_by
, X_LAST_UPDATE_LOGIN		=> p_PRICE_LIST_LINE_rec.last_update_login
, X_PROGRAM_APPLICATION_ID	=> p_PRICE_LIST_LINE_rec.program_application_id
, X_PROGRAM_ID			=> p_PRICE_LIST_LINE_rec.program_id
, X_PROGRAM_UPDATE_DATE		=> p_PRICE_LIST_LINE_rec.program_update_date
, X_REQUEST_ID			=> p_PRICE_LIST_LINE_rec.request_id
, X_LIST_HEADER_ID		=> p_PRICE_LIST_LINE_rec.price_list_id
, X_LIST_LINE_TYPE_CODE		=> l_list_line_type_code
, X_START_DATE_ACTIVE		=> p_PRICE_LIST_LINE_rec.start_date_active
, X_END_DATE_ACTIVE		=> p_PRICE_LIST_LINE_rec.end_date_active
, X_AUTOMATIC_FLAG		=> l_automatic_flag
, X_MODIFIER_LEVEL_CODE		=> l_modifier_level_code
, X_LIST_PRICE			=> l_list_price
, X_LIST_PRICE_UOM_CODE		=> p_PRICE_LIST_LINE_rec.unit_code
, X_PRIMARY_UOM_FLAG		=> p_PRICE_LIST_LINE_rec.primary
, X_INVENTORY_ITEM_ID		=> NULL
, X_ORGANIZATION_ID		=> NULL
, X_RELATED_ITEM_ID		=> NULL
, X_RELATIONSHIP_TYPE_ID	=> NULL
, X_SUBSTITUTION_CONTEXT	=> NULL
, X_SUBSTITUTION_ATTRIBUTE	=> NULL
, X_SUBSTITUTION_VALUE		=> NULL
, X_REVISION			=> p_PRICE_LIST_LINE_rec.revision
, X_REVISION_DATE		=> p_PRICE_LIST_LINE_rec.revision_date
, X_REVISION_REASON_CODE	=> p_PRICE_LIST_LINE_rec.revision_reason_code
, X_COMMENTS			=> p_PRICE_LIST_LINE_rec.comments
, X_CONTEXT			=> p_PRICE_LIST_LINE_rec.context
, X_ATTRIBUTE1			=> p_PRICE_LIST_LINE_rec.attribute1
, X_ATTRIBUTE2			=> p_PRICE_LIST_LINE_rec.attribute2
, X_ATTRIBUTE3			=> p_PRICE_LIST_LINE_rec.attribute3
, X_ATTRIBUTE4			=> p_PRICE_LIST_LINE_rec.attribute4
, X_ATTRIBUTE5			=> p_PRICE_LIST_LINE_rec.attribute5
, X_ATTRIBUTE6			=> p_PRICE_LIST_LINE_rec.attribute6
, X_ATTRIBUTE7			=> p_PRICE_LIST_LINE_rec.attribute7
, X_ATTRIBUTE8			=> p_PRICE_LIST_LINE_rec.attribute8
, X_ATTRIBUTE9			=> p_PRICE_LIST_LINE_rec.attribute9
, X_ATTRIBUTE10			=> p_PRICE_LIST_LINE_rec.attribute10
, X_ATTRIBUTE11			=> p_PRICE_LIST_LINE_rec.attribute11
, X_ATTRIBUTE12			=> p_PRICE_LIST_LINE_rec.attribute12
, X_ATTRIBUTE13			=> p_PRICE_LIST_LINE_rec.attribute13
, X_ATTRIBUTE14			=> p_PRICE_LIST_LINE_rec.attribute14
, X_ATTRIBUTE15			=> p_PRICE_LIST_LINE_rec.attribute15
,X_PRICE_BREAK_TYPE_CODE	=> NULL /* p_PRICE_LIST_LINE_rec.price_break_type_code */
, X_PERCENT_PRICE		=> l_percent_price
, X_PRICE_BY_FORMULA_ID		=> NULL
, X_NUMBER_EFFECTIVE_PERIODS	=> NULL
, X_EFFECTIVE_PERIOD_UOM	=> NULL
, X_ARITHMETIC_OPERATOR		=> NULL
, X_OPERAND			=> NULL
, X_NEW_PRICE                   => NULL
, X_OVERRIDE_FLAG		=> NULL
, X_PRINT_ON_INVOICE_FLAG	=> NULL
, X_GL_CLASS_ID                 => NULL
, X_REBATE_TRANSACTION_TYPE_CODE => NULL
, X_REBATE_SUBTYPE_CODE          => NULL
, X_BASE_QTY			 => NULL
, X_BASE_UOM_CODE		 => NULL
, X_ACCRUAL_TYPE_CODE            => NULL
, X_ACCRUAL_QTY			 => NULL
, X_ACCRUAL_UOM_CODE		 => NULL
, X_ESTIM_ACCRUAL_RATE		 => NULL
, X_ACCUM_TO_ACCR_CONV_RATE      => NULL
, X_GENERATE_USING_FORMULA_ID	 => p_PRICE_LIST_LINE_rec.pricing_rule_id);


  x_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
) RETURN OE_Price_List_PUB.Price_List_Line_Val_Rec_Type
IS
l_PRICE_LIST_LINE_val_rec     OE_Price_List_PUB.Price_List_Line_Val_Rec_Type;
BEGIN

   /*
    IF p_PRICE_LIST_LINE_rec.customer_item_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.customer_item_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id,
        p_old_PRICE_LIST_LINE_rec.customer_item_id)
    THEN

        l_PRICE_LIST_LINE_val_rec.customer_item := OE_Id_To_Value.Customer_Item
        (   p_customer_item_id            => p_PRICE_LIST_LINE_rec.customer_item_id
        );
    END IF;
    */

    IF p_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,
        p_old_PRICE_LIST_LINE_rec.inventory_item_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.inventory_item := OE_Id_To_Value.Inventory_Item
        (   p_inventory_item_id           => p_PRICE_LIST_LINE_rec.inventory_item_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.method_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.method_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.method_code,
        p_old_PRICE_LIST_LINE_rec.method_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.method := OE_Id_To_Value.Method
        (   p_method_code                 => p_PRICE_LIST_LINE_rec.method_code
        );
    END IF;
/*
    IF p_PRICE_LIST_LINE_rec.price_list_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.price_list_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_list_id,
        p_old_PRICE_LIST_LINE_rec.price_list_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.price_list := OE_Id_To_Value.Price_List
     (   p_price_list_id               => p_PRICE_LIST_LINE_rec.price_list_id
        );
    END IF;
*/

    IF p_PRICE_LIST_LINE_rec.price_list_line_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.price_list_line_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_list_line_id,
        p_old_PRICE_LIST_LINE_rec.price_list_line_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.price_list_line := OE_Id_To_Value.Price_List_Line
        (   p_price_list_line_id          => p_PRICE_LIST_LINE_rec.price_list_line_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.pricing_rule_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.pricing_rule_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.pricing_rule_id,
        p_old_PRICE_LIST_LINE_rec.pricing_rule_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.pricing_rule := OE_Id_To_Value.Pricing_Rule
        (   p_pricing_rule_id             => p_PRICE_LIST_LINE_rec.pricing_rule_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.reprice_flag <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,
        p_old_PRICE_LIST_LINE_rec.reprice_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.reprice := OE_Id_To_Value.Reprice
        (   p_reprice_flag                => p_PRICE_LIST_LINE_rec.reprice_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.revision_reason_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,
        p_old_PRICE_LIST_LINE_rec.revision_reason_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.revision_reason := OE_Id_To_Value.Revision_Reason
        (   p_revision_reason_code        => p_PRICE_LIST_LINE_rec.revision_reason_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.unit_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.unit_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.unit_code,
        p_old_PRICE_LIST_LINE_rec.unit_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.unit := OE_Id_To_Value.Unit
        (   p_unit_code                   => p_PRICE_LIST_LINE_rec.unit_code
        );
    END IF;

    RETURN l_PRICE_LIST_LINE_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_PRICE_LIST_LINE_val_rec       IN  OE_Price_List_PUB.Price_List_Line_Val_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICE_LIST_LINE_rec.

    l_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    IF  p_PRICE_LIST_LINE_val_rec.customer_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.customer_item_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.customer_item_id := p_PRICE_LIST_LINE_rec.customer_item_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

		 /*
            l_PRICE_LIST_LINE_rec.customer_item_id := OE_Value_To_Id.customer_item
            (   p_customer_item               => p_PRICE_LIST_LINE_val_rec.customer_item
            );
		  */

            IF l_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.inventory_item_id := p_PRICE_LIST_LINE_rec.inventory_item_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.inventory_item_id := OE_Value_To_Id.inventory_item
            (   p_inventory_item              => p_PRICE_LIST_LINE_val_rec.inventory_item
            );

            IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.method <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.method_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.method_code := p_PRICE_LIST_LINE_rec.method_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.method_code := OE_Value_To_Id.method
            (   p_method                      => p_PRICE_LIST_LINE_val_rec.method
            );

            IF l_PRICE_LIST_LINE_rec.method_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.price_list_id := p_PRICE_LIST_LINE_rec.price_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.price_list_id := OE_Value_To_Id.price_list
            (   p_price_list                  => p_PRICE_LIST_LINE_val_rec.price_list
            );

            IF l_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.price_list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.price_list_line_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.price_list_line_id := p_PRICE_LIST_LINE_rec.price_list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.price_list_line_id := OE_Value_To_Id.price_list_line
            (   p_price_list_line             => p_PRICE_LIST_LINE_val_rec.price_list_line
            );

            IF l_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.pricing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.pricing_rule_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.pricing_rule_id := p_PRICE_LIST_LINE_rec.pricing_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.pricing_rule_id := OE_Value_To_Id.pricing_rule
            (   p_pricing_rule                => p_PRICE_LIST_LINE_val_rec.pricing_rule
            );

            IF l_PRICE_LIST_LINE_rec.pricing_rule_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.reprice <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.reprice_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.reprice_flag := p_PRICE_LIST_LINE_rec.reprice_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.reprice_flag := OE_Value_To_Id.reprice
            (   p_reprice                     => p_PRICE_LIST_LINE_val_rec.reprice
            );

            IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.revision_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.revision_reason_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.revision_reason_code := p_PRICE_LIST_LINE_rec.revision_reason_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.revision_reason_code := OE_Value_To_Id.revision_reason
            (   p_revision_reason             => p_PRICE_LIST_LINE_val_rec.revision_reason
            );

            IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

-- Added New Geresh
     ELSE
      --      l_Price_LLine_rec.revision_reason_code := '1234';
            l_Price_LIST_LINE_rec.revision_reason_code := OE_Value_To_Id.revision_reason
            (   p_revision_reason             => p_Price_LIST_LINE_val_rec.revision_reason
            );

            IF l_Price_LIST_Line_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
                l_Price_LIST_Line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;



    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.unit <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.unit_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.unit_code := p_PRICE_LIST_LINE_rec.unit_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','unit');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.unit_code := OE_Value_To_Id.unit
            (   p_unit                        => p_PRICE_LIST_LINE_val_rec.unit
            );

            IF l_PRICE_LIST_LINE_rec.unit_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PRICE_LIST_LINE_rec;

END Get_Ids;

PROCEDURE lock_pricing_attributes( p_list_line_id in number,
                                   x_return_status out NOCOPY /* file.sql.39 change */ varchar2)
is
l_count number := 0;
begin


  select 1
  into l_count
  from qp_pricing_attributes
  where list_line_id = p_list_line_id
  for update nowait;

 exception

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;


end lock_pricing_attributes;

PROCEDURE maintain_pricing_attributes(p_PRICE_LIST_LINE_rec in OE_PRICE_LIST_PUB.Price_List_Line_Rec_Type,
operation in varchar2,
x_return_status out NOCOPY /* file.sql.39 change */ varchar2)
is
l_pricing_attr_tbl OE_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
l_pricing_attr_rec OE_PRICE_LIST_PUB.Pricing_Attr_Rec_Type;
l_count number := 0;
l_product_context varchar2(30);
l_customer_item_context varchar2(30);
l_pb_dollars_attribute_context varchar2(30);
l_pb_units_attribute_context varchar2(30);
l_product_attr varchar2(30);
l_customer_item_attr varchar2(30);
l_pb_dollars_attribute varchar2(30);
l_pb_units_attribute varchar2(30);
l_pricing_attr_grouping_no number;
I number := 1;
J number := 1;
l_related_modifier_id number;
l_rltd_modifier_grp_no number;
l_pricing_attribute_id number;
begin

   /* get the inventory item context first. */

   oe_debug_pub.initialize;
   oe_debug_pub.debug_on;
   oe_debug_pub.add ( 'Geresh 9 :: IN Maintain attributes ' );

  QP_UTIL.Get_Context_Attribute('1001', l_product_context, l_product_attr);

    /* get the customer item context  */
   oe_debug_pub.add ( 'Geresh 10 :: IN Maintain attributes ' );

  QP_UTIL.Get_Context_Attribute('CUSTOMER_ITEM_ID', l_customer_item_context, l_customer_item_attr);

   oe_debug_pub.add ( 'Geresh 11 :: IN Maintain attributes ' );

  QP_UTIL.Get_Context_Attribute('DOLLARS',
				l_pb_dollars_attribute_context,
				l_pb_dollars_attribute );
   oe_debug_pub.add ( 'Geresh 12 :: IN Maintain attributes ' );

  QP_UTIL.Get_Context_Attribute('UNITS',
				l_pb_units_attribute_context,
				l_pb_units_attribute );
   oe_debug_pub.add ( 'Geresh 13 :: IN Maintain attributes ' );


   IF operation = 'UPDATE' THEN
   oe_debug_pub.add ( 'Geresh 14 :: Before Query Maintain attributes ' );

    l_pricing_attr_tbl := Query_Pricing_Attributes(p_list_line_id => p_PRICE_LIST_LINE_rec.price_list_line_id);

   oe_debug_pub.add ( 'Geresh 15 :: IN Maintain attributes ' );

   FOR I in 1..l_pricing_attr_tbl.count LOOP


      IF ( (l_pricing_attr_tbl(I).product_attribute_context =
              l_product_context) and
         (l_pricing_attr_tbl(I).product_attribute =
              l_product_attr) ) THEN
          l_pricing_attr_tbl(I).product_attr_value := p_PRICE_LIST_LINE_rec.inventory_item_id;
          l_pricing_attr_tbl(I).product_uom_code := p_PRICE_LIST_LINE_rec.unit_code;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              l_customer_item_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              l_customer_item_attr) ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.customer_item_id;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE1') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute1;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE2') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute2;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE3') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute3;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE4') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute4;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE5') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute5;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE6') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute6;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE7') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute7;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE8') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute8;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE9') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute9;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE10') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute10;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE11') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute11;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE12') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute12;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE13') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute13;

      END IF;

      IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE14') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute14;

      END IF;

       IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              p_PRICE_LIST_LINE_rec.pricing_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
              'PRICING_ATTRIBUTE15') ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute15;

       END IF;


       IF ( (l_pricing_attr_tbl(I).pricing_attribute_context =
              l_pb_dollars_attribute_context) and
         (l_pricing_attr_tbl(I).pricing_attribute =
            l_pb_dollars_attribute) ) THEN
          l_pricing_attr_tbl(I).pricing_attr_value_from := p_PRICE_LIST_LINE_rec.price_break_low;
          l_pricing_attr_tbl(I).pricing_attr_value_to := p_PRICE_LIST_LINE_rec.price_break_high;

       END IF;



     /* call update row for pricing attributes */

     QP_PRICING_ATTRIBUTE_PVT.Update_Row(
  X_PRICING_ATTRIBUTE_ID => l_pricing_attr_tbl(I).pricing_attribute_id
, X_CREATION_DATE        => l_pricing_attr_tbl(I).creation_date
, X_CREATED_BY		 => l_pricing_attr_tbl(I).created_by
, X_LAST_UPDATE_DATE	 => l_pricing_attr_tbl(I).last_update_date
, X_LAST_UPDATED_BY	 => l_pricing_attr_tbl(I).last_updated_by
, X_LAST_UPDATE_LOGIN	 => l_pricing_attr_tbl(I).last_update_login
, X_PROGRAM_APPLICATION_ID => l_pricing_attr_tbl(I).program_application_id
, X_PROGRAM_ID             => l_pricing_attr_tbl(I).program_id
, X_PROGRAM_UPDATE_DATE    => l_pricing_attr_tbl(I).program_update_date
, X_REQUEST_ID		   => l_pricing_attr_tbl(I).request_id
, X_LIST_LINE_ID	   => l_pricing_attr_tbl(I).list_line_id
, X_EXCLUDER_FLAG	   => l_pricing_attr_tbl(I).excluder_flag
, X_ACCUMULATE_FLAG	   => l_pricing_attr_tbl(I).accumulate_flag
, X_PRODUCT_ATTRIBUTE_CONTEXT => l_pricing_attr_tbl(I).product_attribute_context
, X_PRODUCT_ATTRIBUTE	      => l_pricing_attr_tbl(I).product_attribute
, X_PRODUCT_ATTR_VALUE	      => l_pricing_attr_tbl(I).product_attr_value
, X_PRODUCT_UOM_CODE	      => l_pricing_attr_tbl(I).product_uom_code
, X_PRICING_ATTRIBUTE_CONTEXT => l_pricing_attr_tbl(I).pricing_attribute_context
, X_PRICING_ATTRIBUTE	      => l_pricing_attr_tbl(I).pricing_attribute
, X_PRICING_ATTR_VALUE_FROM   => l_pricing_attr_tbl(I).pricing_attr_value_from
, X_PRICING_ATTR_VALUE_TO     => l_pricing_attr_tbl(I).pricing_attr_value_to
, X_ATTRIBUTE_GROUPING_NO     => l_pricing_attr_tbl(I).attribute_grouping_no
, X_CONTEXT		      => l_pricing_attr_tbl(I).context
, X_ATTRIBUTE1		      => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE2                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE3                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE4                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE5                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE6                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE7                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE8                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE9                => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE10               => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE11               => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE12               => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE13               => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE14               => l_pricing_attr_tbl(I).attribute1
, X_ATTRIBUTE15               => l_pricing_attr_tbl(I).attribute1 );

     END LOOP; /* for I in 1..l_pricing_attr_tbl.count */


    END IF; /* If operation = UPDATE */

   IF ( operation = 'INSERT') THEN

   oe_debug_pub.add ( 'Geresh 20 :: Insert Maintain attributes ' );
    l_pricing_attr_rec.product_attribute_context := l_product_context;
    l_pricing_attr_rec.product_attribute := l_product_attr;
    l_pricing_attr_rec.product_attr_value := p_PRICE_LIST_LINE_rec.inventory_item_id;
    l_pricing_attr_rec.pricing_attribute_context := 'ALL';
    l_pricing_attr_rec.pricing_attribute := 'ALL';
    l_pricing_attr_rec.pricing_attr_value_from := 'ALL';
    l_pricing_attr_tbl(I) := l_pricing_attr_rec;

    If p_PRICE_LIST_LINE_rec.customer_item_id is not null then
        l_pricing_attr_rec.pricing_attribute_context := l_customer_item_context;
        l_pricing_attr_rec.pricing_attribute := l_customer_item_attr;
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.customer_item_id;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    /* check if pricing_attribute_context is present*/

    If p_PRICE_LIST_LINE_rec.pricing_context is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;

    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute1 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE1';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute1;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

   oe_debug_pub.add ( 'Geresh 21 :: Insert Maintain attributes ' );
    If p_PRICE_LIST_LINE_rec.pricing_attribute2 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE2';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute2;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute3 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE3';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute3;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute4 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE4';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute4;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute5 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE5';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute5;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;
   oe_debug_pub.add ( 'Geresh 23 :: Insert Maintain attributes ' );

    If p_PRICE_LIST_LINE_rec.pricing_attribute6 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE6';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute6;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute7 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE7';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute7;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute8 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE8';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute8;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute9 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE9';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute9;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

   oe_debug_pub.add ( 'Geresh 24 :: Insert Maintain attributes ' );
    If p_PRICE_LIST_LINE_rec.pricing_attribute10 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE10';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute10;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute11 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE11';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute11;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute12 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE12';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute12;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute13 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE13';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute13;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute14 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE14';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute14;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;

    If p_PRICE_LIST_LINE_rec.pricing_attribute15 is not null then
        l_pricing_attr_rec.pricing_attribute_context := p_PRICE_LIST_LINE_rec.pricing_context;
        l_pricing_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE15';
        l_pricing_attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.pricing_attribute15;
        l_pricing_attr_rec.pricing_attr_value_to := NULL;
        l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        I := I + 1;
    end if;


   if p_PRICE_LIST_LINE_rec.method_type_code is not null THEN

     if p_PRICE_LIST_LINE_rec.method_type_code = 'Value'  THEN

       l_Pricing_Attr_rec.pricing_attribute_context := l_pb_dollars_attribute_context;
       l_pricing_attr_rec.pricing_attribute := l_pb_dollars_attribute;
     else
       l_Pricing_Attr_rec.pricing_attribute_context := l_pb_units_attribute_context;
       l_pricing_attr_rec.pricing_attribute := l_pb_units_attribute;

    end if;

     l_Pricing_Attr_rec.pricing_attr_value_from := p_PRICE_LIST_LINE_rec.price_break_low;
     l_Pricing_Attr_rec.pricing_attr_value_to := p_PRICE_LIST_LINE_rec.price_break_high;

      l_Pricing_Attr_tbl(I) := l_Pricing_Attr_rec;

      I := I + 1;

   end if;

   /* select attribute grouping no first */


    SELECT QP_PRICING_ATTR_GROUP_NO_S.nextval
		INTO   l_pricing_attr_grouping_no
		FROM   DUAL;

   oe_debug_pub.add ( 'Geresh 18 :: Before Insert into Pricing attributes Maintain attributes ' );

   FOR I in 1..l_pricing_attr_tbl.count loop

    SELECT QP_PRICING_ATTRIBUTES_S.nextval
          INTO l_pricing_attribute_id
          from dual;

    QP_PRICING_ATTRIBUTE_PVT.Insert_Row(
  X_PRICING_ATTRIBUTE_ID 	=> l_pricing_attribute_id
, X_CREATION_DATE		=> p_PRICE_LIST_LINE_rec.creation_date
, X_CREATED_BY                  => p_PRICE_LIST_LINE_rec.created_by
, X_LAST_UPDATE_DATE		=> p_PRICE_LIST_LINE_rec.last_update_date
, X_LAST_UPDATED_BY		=> p_PRICE_LIST_LINE_rec.last_updated_by
, X_LAST_UPDATE_LOGIN		=> p_PRICE_LIST_LINE_rec.last_update_login
, X_PROGRAM_APPLICATION_ID	=> p_PRICE_LIST_LINE_rec.program_application_id
, X_PROGRAM_ID			=> p_PRICE_LIST_LINE_rec.program_id
, X_PROGRAM_UPDATE_DATE		=> p_PRICE_LIST_LINE_rec.program_update_date
, X_REQUEST_ID			=> p_PRICE_LIST_LINE_rec.request_id
, X_LIST_LINE_ID		=> p_PRICE_LIST_LINE_rec.price_list_line_id
, X_EXCLUDER_FLAG		=> 'N'
, X_ACCUMULATE_FLAG             => 'N'
, X_PRODUCT_ATTRIBUTE_CONTEXT   => l_product_context
, X_PRODUCT_ATTRIBUTE		=> l_product_attr
, X_PRODUCT_ATTR_VALUE		=> p_PRICE_LIST_LINE_rec.inventory_item_id
, X_PRODUCT_UOM_CODE		=> p_PRICE_LIST_LINE_rec.unit_code
, X_PRICING_ATTRIBUTE_CONTEXT	=> l_pricing_attr_tbl(I).pricing_attribute_context
, X_PRICING_ATTRIBUTE		=> l_pricing_attr_tbl(I).pricing_attribute
, X_PRICING_ATTR_VALUE_FROM	=> l_pricing_attr_tbl(I).pricing_attr_value_from
, X_PRICING_ATTR_VALUE_TO	=> l_pricing_attr_tbl(I).pricing_attr_value_to
, X_ATTRIBUTE_GROUPING_NO	=> l_pricing_attr_grouping_no
, X_CONTEXT			=> NULL
, X_ATTRIBUTE1			=> NULL
, X_ATTRIBUTE2			=> NULL
, X_ATTRIBUTE3			=> NULL
, X_ATTRIBUTE4			=> NULL
, X_ATTRIBUTE5			=> NULL
, X_ATTRIBUTE6			=> NULL
, X_ATTRIBUTE7			=> NULL
, X_ATTRIBUTE8			=> NULL
, X_ATTRIBUTE9			=> NULL
, X_ATTRIBUTE10			=> NULL
, X_ATTRIBUTE11			=> NULL
, X_ATTRIBUTE12			=> NULL
, X_ATTRIBUTE13			=> NULL
, X_ATTRIBUTE14			=> NULL
, X_ATTRIBUTE15			=> NULL
);

   END LOOP;



   oe_debug_pub.add ( 'Geresh 31 :: Before Insert into Pricing attributes Maintain attributes ' );

   IF p_PRICE_LIST_LINE_rec.price_break_parent_line is not null THEN

      select qp_rltd_modifier_grp_no_s.nextval
      into l_rltd_modifier_grp_no
      from dual;
   oe_debug_pub.add ( 'Geresh 30 :: Before Insert into Pricing attributes Maintain attributes ' );

      select qp_rltd_modifiers_s.nextval
      into l_related_modifier_id
      from dual;
   oe_debug_pub.add ( 'Geresh 31 :: ' || p_PRICE_LIST_LINE_rec.price_break_parent_line );
   oe_debug_pub.add ( 'Geresh 31:: 1  ' || p_PRICE_LIST_LINE_rec.price_list_line_id );

/*
      QP_RLTD_MODIFIER_PVT.Insert_Row(
       	X_RLTD_MODIFIER_ID 	=> l_related_modifier_id
, X_CREATION_DATE 		=> p_PRICE_LIST_LINE_rec.creation_date
, X_CREATED_BY			=> p_PRICE_LIST_LINE_rec.created_by
, X_LAST_UPDATE_DATE		=> p_PRICE_LIST_LINE_rec.last_update_date
, X_LAST_UPDATED_BY		=> p_PRICE_LIST_LINE_rec.last_updated_by
, X_LAST_UPDATE_LOGIN           => p_PRICE_LIST_LINE_rec.last_update_login
, X_RLTD_MODIFIER_GRP_NO        => l_rltd_modifier_grp_no
, X_FROM_RLTD_MODIFIER_ID       => p_PRICE_LIST_LINE_rec.price_break_parent_line
, X_TO_RLTD_MODIFIER_ID		=> p_PRICE_LIST_LINE_rec.price_list_line_id
, X_CONTEXT               	=> NULL
, X_ATTRIBUTE1			=> NULL
, X_ATTRIBUTE2                  => NULL
, X_ATTRIBUTE3                  => NULL
, X_ATTRIBUTE4                  => NULL
, X_ATTRIBUTE5                  => NULL
, X_ATTRIBUTE6                  => NULL
, X_ATTRIBUTE7                  => NULL
, X_ATTRIBUTE8                  => NULL
, X_ATTRIBUTE9                  => NULL
, X_ATTRIBUTE10                 => NULL
, X_ATTRIBUTE11                 => NULL
, X_ATTRIBUTE12                 => NULL
, X_ATTRIBUTE13                 => NULL
, X_ATTRIBUTE14                 => NULL
, X_ATTRIBUTE15                 => NULL
); */


    END IF;


 END IF;  /* If operation = 'INSERT' */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 exception

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;


end maintain_pricing_attributes;

FUNCTION Query_Pricing_Attributes
(   p_pricing_attribute_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Price_List_PUB.Pricing_Attr_Tbl_Type
IS
l_PRICING_ATTR_rec            OE_PRICE_LIST_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            OE_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;

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
    FROM    QP_PRICING_ATTRIBUTES
    WHERE ( PRICING_ATTRIBUTE_ID = p_pricing_attribute_id
    )
    OR (    LIST_LINE_ID = p_list_line_id
    );

BEGIN

    IF ( ( p_pricing_attribute_id is not null
        and p_pricing_attribute_id <> FND_API.G_MISS_NUM)
       or (p_list_line_id is not null
            and p_list_line_id <> FND_API.G_MISS_NUM ) ) THEN

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

        l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

    END LOOP;

  END IF;


    --  PK sent and no rows found

    IF
    ( (p_pricing_attribute_id IS NOT NULL
     AND
     p_pricing_attribute_id <> FND_API.G_MISS_NUM)
    or
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM) )
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

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Pricing_Attributes;


END OE_Price_List_Line_Util;

/

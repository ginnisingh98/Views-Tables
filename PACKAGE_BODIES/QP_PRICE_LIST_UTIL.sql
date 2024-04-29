--------------------------------------------------------
--  DDL for Package Body QP_PRICE_LIST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_LIST_UTIL" AS
/* $Header: QPXUPLHB.pls 120.5.12010000.7 2009/08/19 07:28:08 smbalara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Price_List_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN            NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_rec                IN            QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN            QP_Price_List_PUB.Price_List_Rec_Type :=
                                                  QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PRICE_LIST_rec := p_PRICE_LIST_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute1,p_old_PRICE_LIST_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute10,p_old_PRICE_LIST_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute11,p_old_PRICE_LIST_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute12,p_old_PRICE_LIST_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute13,p_old_PRICE_LIST_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute14,p_old_PRICE_LIST_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute15,p_old_PRICE_LIST_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute2,p_old_PRICE_LIST_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute3,p_old_PRICE_LIST_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute4,p_old_PRICE_LIST_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute5,p_old_PRICE_LIST_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute6,p_old_PRICE_LIST_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute7,p_old_PRICE_LIST_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute8,p_old_PRICE_LIST_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute9,p_old_PRICE_LIST_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.automatic_flag,p_old_PRICE_LIST_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_AUTOMATIC;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.comments,p_old_PRICE_LIST_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_COMMENTS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.context,p_old_PRICE_LIST_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.created_by,p_old_PRICE_LIST_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.creation_date,p_old_PRICE_LIST_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,p_old_PRICE_LIST_rec.currency_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CURRENCY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.discount_lines_flag,p_old_PRICE_LIST_rec.discount_lines_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_DISCOUNT_LINES;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.end_date_active,p_old_PRICE_LIST_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,p_old_PRICE_LIST_rec.freight_terms_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_FREIGHT_TERMS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.gsa_indicator,p_old_PRICE_LIST_rec.gsa_indicator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_GSA_INDICATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_updated_by,p_old_PRICE_LIST_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_date,p_old_PRICE_LIST_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_login,p_old_PRICE_LIST_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.name,p_old_PRICE_LIST_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.description,p_old_PRICE_LIST_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_DESCRIPTION;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_header_id,p_old_PRICE_LIST_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_type_code,p_old_PRICE_LIST_rec.list_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.version_no,p_old_PRICE_LIST_rec.version_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_VERSION_NO;
        END IF;

       IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.active_flag,p_old_PRICE_LIST_rec.active_flag)
	   THEN
		 l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ACTIVE_FLAG;
        END IF;

       --mkarya for bug 1944882
       IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.mobile_download,p_old_PRICE_LIST_rec.mobile_download)
	   THEN
		 l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_MOBILE_DOWNLOAD;
        END IF;

       --Pricing Security gtippire
       IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.global_flag,p_old_PRICE_LIST_rec.global_flag)
	   THEN
		 l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_GLOBAL_FLAG;
        END IF;

       --Multi-Currency SunilPandey
       IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_header_id,p_old_PRICE_LIST_rec.currency_header_id)
	   THEN
		 l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CURRENCY_HEADER;
        END IF;

       --Attributes Manager Giri
       IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.pte_code,p_old_PRICE_LIST_rec.pte_code)
	   THEN
		 l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_application_id,p_old_PRICE_LIST_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_id,p_old_PRICE_LIST_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_update_date,p_old_PRICE_LIST_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.prorate_flag,p_old_PRICE_LIST_rec.prorate_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PRORATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.request_id,p_old_PRICE_LIST_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.rounding_factor,p_old_PRICE_LIST_rec.rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ROUNDING_FACTOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,p_old_PRICE_LIST_rec.ship_method_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SHIP_METHOD;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.start_date_active,p_old_PRICE_LIST_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,p_old_PRICE_LIST_rec.terms_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_TERMS;
        END IF;

--Blanket Sales Order Addition
	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_source_code,p_old_PRICE_LIST_rec.list_source_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_SOURCE;
        END IF;

	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.orig_system_header_ref,p_old_PRICE_LIST_rec.orig_system_header_ref)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.ORIG_SYSTEM_HEADER_REF;
        END IF;

--Blanket Pricing
	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.source_system_code,p_old_PRICE_LIST_rec.source_system_code)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SOURCE_SYSTEM_CODE;
	END IF;

	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.shareable_flag,p_old_PRICE_LIST_rec.shareable_flag)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SHAREABLE_FLAG;
	END IF;

	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.sold_to_org_id, p_old_PRICE_LIST_rec.sold_to_org_id)
	THEN
	            l_index := l_index + 1;
	            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SOLD_TO_ORG_ID;
	END IF;


        --Added for Price List Locking project (Pack J)
        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.locked_from_list_header_id,
                                p_old_PRICE_LIST_rec.locked_from_list_header_id)
	THEN
	            l_index := l_index + 1;
	            l_src_attr_tbl(l_index) :=
			QP_PRICE_LIST_UTIL.G_LOCKED_FROM_LIST_HEADER;
	END IF;

        --added for MOAC
	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.org_id,p_old_PRICE_LIST_rec.org_id)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ORG_ID;
	END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AUTOMATIC THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_AUTOMATIC;
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CURRENCY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_CURRENCY;
    ELSIF p_attr_id = G_DISCOUNT_LINES THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_DISCOUNT_LINES;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_FREIGHT_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_FREIGHT_TERMS;
    ELSIF p_attr_id = G_GSA_INDICATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_GSA_INDICATOR;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_NAME;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_PRICE_LIST_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_TYPE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_PRORATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_PRORATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ROUNDING_FACTOR;
    ELSIF p_attr_id = G_SHIP_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SHIP_METHOD;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_TERMS;

--Blanket Sales Order Addition
    ELSIF p_attr_id = G_LIST_SOURCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_LIST_SOURCE;
    ELSIF p_attr_id = ORIG_SYSTEM_HEADER_REF THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.ORIG_SYSTEM_HEADER_REF;

--Blanket pricing
    ELSIF p_attr_id = G_SOURCE_SYSTEM_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SOURCE_SYSTEM_CODE;
    ELSIF p_attr_id = G_SHAREABLE_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SHAREABLE_FLAG;
    ELSIF p_attr_id = G_SOLD_TO_ORG_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_SOLD_TO_ORG_ID;
    --added for MOAC
    ELSIF p_attr_id = G_ORG_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_UTIL.G_ORG_ID;
    END IF;
END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_rec                IN            QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN            QP_Price_List_PUB.Price_List_Rec_Type :=
                                                  QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_PRICE_LIST_rec := p_PRICE_LIST_rec;


    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute1,p_old_PRICE_LIST_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute10,p_old_PRICE_LIST_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute11,p_old_PRICE_LIST_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute12,p_old_PRICE_LIST_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute13,p_old_PRICE_LIST_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute14,p_old_PRICE_LIST_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute15,p_old_PRICE_LIST_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute2,p_old_PRICE_LIST_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute3,p_old_PRICE_LIST_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute4,p_old_PRICE_LIST_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute5,p_old_PRICE_LIST_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute6,p_old_PRICE_LIST_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute7,p_old_PRICE_LIST_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute8,p_old_PRICE_LIST_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute9,p_old_PRICE_LIST_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.automatic_flag,p_old_PRICE_LIST_rec.automatic_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.comments,p_old_PRICE_LIST_rec.comments)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.context,p_old_PRICE_LIST_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.created_by,p_old_PRICE_LIST_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.creation_date,p_old_PRICE_LIST_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,p_old_PRICE_LIST_rec.currency_code)
    THEN
        NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF(p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
          END IF;
	END IF; --Java Engine Installed
-- pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF(p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
          END IF;
       END IF;
      END IF;

    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.discount_lines_flag,p_old_PRICE_LIST_rec.discount_lines_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.end_date_active,p_old_PRICE_LIST_rec.end_date_active)
    THEN
      --  NULL;
      -- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
       END IF;
      END IF;

    END IF;

    /* Bug 1856788 Added the if condition to propogate the change in active_flag of price_list to qualifiers
       of the price_list */
 IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.active_flag,p_old_PRICE_LIST_rec.active_flag)
    THEN
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
          IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
	END IF; --Java Engine Installed
-- pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
       END IF;
      END IF;


   -- added for bug 2912834
   IF p_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
   THEN

        UPDATE qp_qualifiers
          SET active_flag = p_PRICE_LIST_rec.active_flag
         WHERE list_header_id = p_PRICE_LIST_rec.list_header_id;

     -- Dynamic sourcing of attributes changes
     IF p_PRICE_LIST_rec.active_flag = 'Y'
     THEN
	update qp_pte_segments d set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and exists
	(select 'x'
	from qp_segments_b a,qp_prc_contexts_b b,qp_qualifiers c
	where c.list_header_id         = p_PRICE_LIST_rec.list_header_id
	and   a.segment_mapping_column = c .qualifier_attribute
        and   a.segment_id             = d.segment_id
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'QUALIFIER'
	and   b.prc_context_code       = c.qualifier_context);

	update qp_pte_segments d set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and exists
	(select 'x'
	from qp_segments_b a,qp_prc_contexts_b b,qp_pricing_attributes c
	where c.list_header_id         = p_PRICE_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.pricing_attribute
        and   a.segment_id             = d.segment_id
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'PRICING_ATTRIBUTE'
	and   b.prc_context_code       = c.pricing_attribute_context);

	update qp_pte_segments d set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and exists
	(select 'x'
	from qp_segments_b a,qp_prc_contexts_b b,qp_pricing_attributes c
	where c.list_header_id         = p_PRICE_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.product_attribute
        and   a.segment_id             = d.segment_id
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'PRODUCT'
	and   b.prc_context_code       = c.product_attribute_context);

    END IF;

  END IF;

 END IF;
    -- mkarya for bug 1944882
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.mobile_download,p_old_PRICE_LIST_rec.mobile_download)
    THEN
        NULL;
    END IF;

    -- Pricing Security gtippire
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.global_flag,p_old_PRICE_LIST_rec.global_flag)
    THEN
       -- NULL;
       -- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
       END IF;
      END IF;

    END IF;

    oe_debug_pub.add('QPXUPLHB - list_header_id = ' || p_PRICE_LIST_rec.list_header_id);
    oe_debug_pub.add('QPXUPLHB - currency_header_id = ' || p_PRICE_LIST_rec.currency_header_id);
    oe_debug_pub.add('QPXUPLHB - old currency_header_id = ' || p_old_PRICE_LIST_rec.currency_header_id);
    oe_debug_pub.add('QPXUPLHB - rounding_factor = ' || p_PRICE_LIST_rec.rounding_factor);
    -- Multi-Currency SunilPandey
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_header_id,p_old_PRICE_LIST_rec.currency_header_id)
    THEN
       -- NULL;
        if p_PRICE_LIST_rec.currency_header_id is not null then
              select BASE_ROUNDING_FACTOR
                into x_PRICE_LIST_rec.rounding_factor
                from QP_CURRENCY_LISTS_VL
               where currency_header_id = p_PRICE_LIST_rec.currency_header_id;
        end if;
	-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
       END IF;
      END IF;

    END IF;

    -- Attributes Manager Giri
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.pte_code,p_old_PRICE_LIST_rec.pte_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,p_old_PRICE_LIST_rec.freight_terms_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.gsa_indicator,p_old_PRICE_LIST_rec.gsa_indicator)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_updated_by,p_old_PRICE_LIST_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_date,p_old_PRICE_LIST_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_login,p_old_PRICE_LIST_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.name,p_old_PRICE_LIST_rec.name)
    THEN
        IF NOT QP_Validate.Price_List_Name(p_PRICE_LIST_rec.name,
                                p_PRICE_LIST_rec.list_header_id,
						  p_PRICE_LIST_rec.version_no) THEN
            x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.description,p_old_PRICE_LIST_rec.description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_header_id,p_old_PRICE_LIST_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_type_code,p_old_PRICE_LIST_rec.list_type_code)
    THEN
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF(p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
            END IF;
	END IF; --Java Engine Installed
-- pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF(p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
            END IF;
       END IF;
      END IF;

        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.version_no,p_old_PRICE_LIST_rec.version_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_application_id,p_old_PRICE_LIST_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_id,p_old_PRICE_LIST_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_update_date,p_old_PRICE_LIST_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.prorate_flag,p_old_PRICE_LIST_rec.prorate_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.request_id,p_old_PRICE_LIST_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.rounding_factor,p_old_PRICE_LIST_rec.rounding_factor)
    THEN
	  /*
       IF NOT QP_Validate.Rounding_Factor(p_PRICE_LIST_rec.rounding_factor,
								  p_PRICE_LIST_rec.currency_code)
       THEN
            x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
       END IF;
	  */
	  null;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,p_old_PRICE_LIST_rec.ship_method_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.start_date_active,p_old_PRICE_LIST_rec.start_date_active)
    THEN
    --    NULL;
    -- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
	   qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
         END IF;
       END IF;
      END IF;

    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,p_old_PRICE_LIST_rec.terms_id)
    THEN
        NULL;
    END IF;

-- Blanket Sales Order
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_source_code,p_old_PRICE_LIST_rec.list_source_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.orig_system_header_ref,p_old_PRICE_LIST_rec.orig_system_header_ref)
    THEN
        NULL;
    END IF;

-- Blanket Pricing
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.source_system_code, p_old_PRICE_LIST_rec.source_system_code)
    THEN
        NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF( p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
          END IF;
	END IF; --Java Engine Installed
-- pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF( p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_PRICE_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_PRICE_LIST_rec.return_status);
          END IF;
       END IF;
      END IF;

    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.shareable_flag, p_old_PRICE_LIST_rec.shareable_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.sold_to_org_id, p_old_PRICE_LIST_rec.sold_to_org_id)
    THEN
        NULL;
    END IF;

    --Added for Price List Locking
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.locked_from_list_header_id, p_old_PRICE_LIST_rec.locked_from_list_header_id)
    THEN
        NULL;
    END IF;

    --added for MOAC
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.org_id, p_old_PRICE_LIST_rec.org_id)
    THEN
        NULL;
    END IF;
END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
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

    IF l_PRICE_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.automatic_flag := p_old_PRICE_LIST_rec.automatic_flag;
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

    IF l_PRICE_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.discount_lines_flag := p_old_PRICE_LIST_rec.discount_lines_flag;
    END IF;

    IF l_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.end_date_active := p_old_PRICE_LIST_rec.end_date_active;
    END IF;

    IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.freight_terms_code := p_old_PRICE_LIST_rec.freight_terms_code;
    END IF;

    IF l_PRICE_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.gsa_indicator := p_old_PRICE_LIST_rec.gsa_indicator;
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


    IF l_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.description := p_old_PRICE_LIST_rec.description;
    END IF;

    IF l_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.list_header_id := p_old_PRICE_LIST_rec.list_header_id;
    END IF;

    IF l_PRICE_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.list_type_code := p_old_PRICE_LIST_rec.list_type_code;
    END IF;

    IF l_PRICE_LIST_rec.version_no = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.version_no := p_old_PRICE_LIST_rec.version_no;
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

    IF l_PRICE_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.prorate_flag := p_old_PRICE_LIST_rec.prorate_flag;
    END IF;

    IF l_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.request_id := p_old_PRICE_LIST_rec.request_id;
    END IF;

    IF l_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.rounding_factor := p_old_PRICE_LIST_rec.rounding_factor;
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

    -- Blanket Agreement Pricing bug#3684285
    IF l_PRICE_LIST_rec.list_source_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.list_source_code := p_old_PRICE_LIST_rec.list_source_code;
    END IF;

    IF l_PRICE_LIST_rec.orig_system_header_ref = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.orig_system_header_ref := p_old_PRICE_LIST_rec.orig_system_header_ref;
    END IF;

    IF l_PRICE_LIST_rec.source_system_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.source_system_code := p_old_PRICE_LIST_rec.source_system_code;
    END IF;

    IF l_PRICE_LIST_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.pte_code := p_old_PRICE_LIST_rec.pte_code;
    END IF;

    IF l_PRICE_LIST_rec.shareable_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.shareable_flag := p_old_PRICE_LIST_rec.shareable_flag;
    END IF;

    IF l_PRICE_LIST_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.sold_to_org_id := p_old_PRICE_LIST_rec.sold_to_org_id;
    END IF;

    /* Added code for active_flag and mobile_download by dhgupta for bug 2052900 */

    IF l_PRICE_LIST_rec.active_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.active_flag := p_old_PRICE_LIST_rec.active_flag;
    END IF;

    IF l_PRICE_LIST_rec.mobile_download = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.mobile_download := p_old_PRICE_LIST_rec.mobile_download;
    END IF;

    -- Pricing Security gtippire
    IF l_PRICE_LIST_rec.global_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.global_flag := p_old_PRICE_LIST_rec.global_flag;
    END IF;

    IF l_PRICE_LIST_rec.locked_from_list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.locked_from_list_header_id := p_old_PRICE_LIST_rec.locked_from_list_header_id;
    END IF;

    --added for MOAC
    IF l_PRICE_LIST_rec.org_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.org_id := p_old_PRICE_LIST_rec.org_id;
    END IF;

    RETURN l_PRICE_LIST_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
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

    IF l_PRICE_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.automatic_flag := NULL;
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

    IF l_PRICE_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.discount_lines_flag := NULL;
    END IF;

    IF l_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_rec.end_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.freight_terms_code := NULL;
    END IF;

    IF l_PRICE_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.gsa_indicator := NULL;
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

    IF l_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.list_header_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.list_type_code := NULL;
    END IF;

    IF l_PRICE_LIST_rec.version_no = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.version_no := NULL;
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

    IF l_PRICE_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.prorate_flag := NULL;
    END IF;

    IF l_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.request_id := NULL;
    END IF;

    IF l_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.rounding_factor := NULL;
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

    IF l_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.name := NULL;
    END IF;

    IF l_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_rec.description := NULL;
    END IF;

    IF l_PRICE_LIST_rec.locked_from_list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_rec.locked_from_list_header_id := NULL;
    END IF;

    RETURN l_PRICE_LIST_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
)
IS
l_price_list_exists number := 0;
BEGIN

  IF QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                 p_instance_type => QP_Security.G_PRICELIST_OBJECT,
                                 p_instance_pk1  => p_PRICE_LIST_rec.list_header_id) <> 'F' THEN

    --for moac changes QP_LIST_HEADERS_B to all_b to enable updates to PL with orig_org_id
    --that do not belong to the responsibility when the user has update privilges
    UPDATE  QP_LIST_HEADERS_ALL_B
    SET     ATTRIBUTE1                     = p_PRICE_LIST_rec.attribute1
    ,       ATTRIBUTE10                    = p_PRICE_LIST_rec.attribute10
    ,       ATTRIBUTE11                    = p_PRICE_LIST_rec.attribute11
    ,       ATTRIBUTE12                    = p_PRICE_LIST_rec.attribute12
    ,       ATTRIBUTE13                    = p_PRICE_LIST_rec.attribute13
    ,       ATTRIBUTE14                    = p_PRICE_LIST_rec.attribute14
    ,       ATTRIBUTE15                    = p_PRICE_LIST_rec.attribute15
    ,       ATTRIBUTE2                     = p_PRICE_LIST_rec.attribute2
    ,       ATTRIBUTE3                     = p_PRICE_LIST_rec.attribute3
    ,       ATTRIBUTE4                     = p_PRICE_LIST_rec.attribute4
    ,       ATTRIBUTE5                     = p_PRICE_LIST_rec.attribute5
    ,       ATTRIBUTE6                     = p_PRICE_LIST_rec.attribute6
    ,       ATTRIBUTE7                     = p_PRICE_LIST_rec.attribute7
    ,       ATTRIBUTE8                     = p_PRICE_LIST_rec.attribute8
    ,       ATTRIBUTE9                     = p_PRICE_LIST_rec.attribute9
    ,       AUTOMATIC_FLAG                 = p_PRICE_LIST_rec.automatic_flag
    ,       COMMENTS                       = p_PRICE_LIST_rec.comments
    ,       CONTEXT                        = p_PRICE_LIST_rec.context
    ,       CREATED_BY                     = p_PRICE_LIST_rec.created_by
    ,       CREATION_DATE                  = p_PRICE_LIST_rec.creation_date
    ,       CURRENCY_CODE                  = p_PRICE_LIST_rec.currency_code
    ,       DISCOUNT_LINES_FLAG            = p_PRICE_LIST_rec.discount_lines_flag
    ,       END_DATE_ACTIVE                = trunc(p_PRICE_LIST_rec.end_date_active)
    ,       FREIGHT_TERMS_CODE             = p_PRICE_LIST_rec.freight_terms_code
    ,       GSA_INDICATOR                  = p_PRICE_LIST_rec.gsa_indicator
    ,       LAST_UPDATED_BY                = p_PRICE_LIST_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_PRICE_LIST_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_PRICE_LIST_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_PRICE_LIST_rec.list_header_id
    ,       LIST_TYPE_CODE                 = p_PRICE_LIST_rec.list_type_code
    ,       PROGRAM_APPLICATION_ID         = p_PRICE_LIST_rec.program_application_id
    ,       PROGRAM_ID                     = p_PRICE_LIST_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PRICE_LIST_rec.program_update_date
    ,       PRORATE_FLAG                   = p_PRICE_LIST_rec.prorate_flag
    ,       REQUEST_ID                     = p_PRICE_LIST_rec.request_id
    ,       ROUNDING_FACTOR                = p_PRICE_LIST_rec.rounding_factor
    ,       SHIP_METHOD_CODE               = p_PRICE_LIST_rec.ship_method_code
    ,       START_DATE_ACTIVE              = trunc(p_PRICE_LIST_rec.start_date_active)
    ,       TERMS_ID                       = p_PRICE_LIST_rec.terms_id
    ,       ASK_FOR_FLAG                   = 'N'
    ,       ACTIVE_FLAG                    =
                            decode(p_PRICE_LIST_rec.active_flag, FND_API.G_MISS_CHAR, ACTIVE_FLAG, --dhgupta for 2052900
				    p_PRICE_LIST_rec.active_flag)
    ,       MOBILE_DOWNLOAD                =
                          decode(p_PRICE_LIST_rec.mobile_download, FND_API.G_MISS_CHAR, MOBILE_DOWNLOAD,--dhgupta for 2052900
				    p_PRICE_LIST_rec.mobile_download) -- mkarya for bug 1944882
    ,       CURRENCY_HEADER_ID             = p_PRICE_LIST_rec.currency_header_id
    ,       PTE_CODE             = p_PRICE_LIST_rec.pte_code  -- Giri for Attributes Manager
    ,	    LIST_SOURCE_CODE     = p_PRICE_LIST_rec.list_source_code --Blanket Sales Order
    , 	    ORIG_SYSTEM_HEADER_REF = p_PRICE_LIST_rec.orig_system_header_ref --Blanket Sales Order
    ,       GLOBAL_FLAG                    =
                          decode(p_PRICE_LIST_rec.global_flag, FND_API.G_MISS_CHAR, GLOBAL_FLAG,
				    p_PRICE_LIST_rec.global_flag) -- Pricing Security gtippire
    ,       SOURCE_SYSTEM_CODE     = p_PRICE_LIST_rec.source_system_code
    ,       SHAREABLE_FLAG         = p_PRICE_LIST_rec.shareable_flag
    ,       SOLD_TO_ORG_ID         = p_PRICE_LIST_rec.sold_to_org_id
    ,       LOCKED_FROM_LIST_HEADER_ID =
                 p_PRICE_LIST_rec.locked_from_list_header_id --Pricelist locking
            --added for MOAC
    ,       ORIG_ORG_ID   = p_PRICE_LIST_rec.org_id
    WHERE   LIST_HEADER_ID = p_PRICE_LIST_rec.list_header_id
    ;

    update QP_LIST_HEADERS_TL set
      NAME = p_PRICE_LIST_rec.name,
      DESCRIPTION = p_PRICE_LIST_rec.description,
      LAST_UPDATE_DATE = p_PRICE_LIST_rec.LAST_UPDATE_DATE,
      LAST_UPDATED_BY = p_PRICE_LIST_rec.LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = p_PRICE_LIST_rec.LAST_UPDATE_LOGIN,
      VERSION_NO = p_PRICE_LIST_rec.version_no,
      SOURCE_LANG = userenv('LANG')
      where LIST_HEADER_ID = p_PRICE_LIST_rec.LIST_HEADER_ID
        and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  --ELSE
  --    fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
  --    fnd_message.set_token('PRICING_OBJECT', 'Price List');
  --    oe_msg_pub.Add;
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
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
)
IS

--l_source_system_code  varchar2(30);
x_result              VARCHAR2(1);

BEGIN
/*
   l_source_system_code := fnd_profile.value('QP_SOURCE_SYSTEM_CODE');

   IF l_source_system_code is null then

	  l_source_system_code := 'QP';

   END IF;
*/

    INSERT  INTO QP_LIST_HEADERS_B
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
    ,       AUTOMATIC_FLAG
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_CODE
    ,       DISCOUNT_LINES_FLAG
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       GSA_INDICATOR
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_TYPE_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PRORATE_FLAG
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SHIP_METHOD_CODE
    ,       START_DATE_ACTIVE
    ,       TERMS_ID
    ,       ASK_FOR_FLAG
    ,       SOURCE_SYSTEM_CODE
    ,       ACTIVE_FLAG
    ,       MOBILE_DOWNLOAD -- mkarya for bug 1944882
    ,       CURRENCY_HEADER_ID -- Multi-Currency SunilPandey
    ,       PTE_CODE -- Attributes Manager Giri
    ,	    LIST_SOURCE_CODE --Blanket Sales Order
    , 	    ORIG_SYSTEM_HEADER_REF --Blanket Sales Order
    , 	    GLOBAL_FLAG --Pricing Security gtippire
    ,       ORIG_ORG_ID -- Pricing Security sfiresto
    ,       SHAREABLE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       LOCKED_FROM_LIST_HEADER_ID
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
    ,       p_PRICE_LIST_rec.automatic_flag
    ,       p_PRICE_LIST_rec.comments
    ,       p_PRICE_LIST_rec.context
    ,       p_PRICE_LIST_rec.created_by
    ,       p_PRICE_LIST_rec.creation_date
    ,       p_PRICE_LIST_rec.currency_code
    ,       p_PRICE_LIST_rec.discount_lines_flag
    ,       trunc(p_PRICE_LIST_rec.end_date_active)
    ,       p_PRICE_LIST_rec.freight_terms_code
    ,       p_PRICE_LIST_rec.gsa_indicator
    ,       p_PRICE_LIST_rec.last_updated_by
    ,       p_PRICE_LIST_rec.last_update_date
    ,       p_PRICE_LIST_rec.last_update_login
    ,       p_PRICE_LIST_rec.list_header_id
    ,       p_PRICE_LIST_rec.list_type_code
    ,       p_PRICE_LIST_rec.program_application_id
    ,       p_PRICE_LIST_rec.program_id
    ,       p_PRICE_LIST_rec.program_update_date
    ,       p_PRICE_LIST_rec.prorate_flag
    ,       p_PRICE_LIST_rec.request_id
    ,       p_PRICE_LIST_rec.rounding_factor
    ,       p_PRICE_LIST_rec.ship_method_code
    ,       trunc(p_PRICE_LIST_rec.start_date_active)
    ,       p_PRICE_LIST_rec.terms_id
    ,       'N' /* ask_for_flag */
--    ,       l_source_system_code
    ,       p_PRICE_LIST_rec.source_system_code
    ,       decode(p_PRICE_LIST_rec.active_flag, FND_API.G_MISS_CHAR, 'Y',
			    p_PRICE_LIST_rec.active_flag)
    ,       decode(p_PRICE_LIST_rec.mobile_download, FND_API.G_MISS_CHAR, 'N',
			    p_PRICE_LIST_rec.mobile_download) -- mkarya for bug 1944882
    ,       p_PRICE_LIST_rec.currency_header_id
    ,       p_PRICE_LIST_rec.pte_code  -- Giri for Attributes Manager
    ,	    p_PRICE_LIST_rec.list_source_code -- Blanket Sales Order
            --ENH Upgrade BOAPI for orig_sys...ref RAVI
    ,	    nvl(p_PRICE_LIST_rec.orig_system_header_ref,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(p_PRICE_LIST_rec.list_header_id)) -- Blanket Sales Order
    ,       decode(p_PRICE_LIST_rec.global_flag, FND_API.G_MISS_CHAR, 'N',
			    p_PRICE_LIST_rec.global_flag) -- Pricing Security gtippire
            --added for MOAC
    ,       p_PRICE_LIST_rec.org_id
    ,       p_PRICE_LIST_rec.shareable_flag
    ,       p_PRICE_LIST_rec.sold_to_org_id
    ,       p_PRICE_LIST_rec.locked_from_list_header_id
    );

    insert into QP_LIST_HEADERS_TL (
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    VERSION_NO,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LIST_HEADER_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    p_PRICE_LIST_rec.LAST_UPDATE_LOGIN,
    p_PRICE_LIST_rec.NAME,
    p_PRICE_LIST_rec.DESCRIPTION,
    p_PRICE_LIST_rec.version_no,
    p_PRICE_LIST_rec.CREATION_DATE,
    p_PRICE_LIST_rec.CREATED_BY,
    p_PRICE_LIST_rec.LAST_UPDATE_DATE,
    p_PRICE_LIST_rec.LAST_UPDATED_BY,
    p_PRICE_LIST_rec.LIST_HEADER_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from QP_LIST_HEADERS_TL T
    where T.LIST_HEADER_ID = p_PRICE_LIST_rec.LIST_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  IF p_PRICE_LIST_rec.list_type_code = 'AGR' THEN
    QP_security.create_default_grants( p_instance_type => QP_security.G_AGREEMENT_OBJECT,
                                       p_instance_pk1  => p_PRICE_LIST_rec.list_header_id,
                                       x_return_status => x_result);
  ELSE
    QP_security.create_default_grants( p_instance_type => QP_security.G_PRICELIST_OBJECT,
                                       p_instance_pk1  => p_PRICE_LIST_rec.list_header_id,
                                       x_return_status => x_result);
  END IF;

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
(   p_list_header_id                IN  NUMBER
)
IS
cursor lines is
select list_line_id
from qp_list_lines
where list_header_id = p_list_header_id;

BEGIN

  for lines_rec in lines loop

    QP_PRICE_LIST_LINE_UTIL.DELETE_ROW(lines_rec.list_line_id);

  end loop;

  /* delete all qualifiers which refer to this list_header_id */

  delete from qp_qualifiers
  where list_header_id = p_list_header_id
  or ( qualifier_attr_value = to_char(p_list_header_id)
	  and qualifier_context = 'MODLIST'
	  and qualifier_attribute = 'QUALIFIER_ATTRIBUTE4' );


  delete from QP_LIST_HEADERS_TL
  where LIST_HEADER_ID = p_list_header_id;

 /*
  if (sql%notfound) then
    raise no_data_found;
  end if;
 */

    DELETE  FROM QP_LIST_HEADERS_B
    WHERE   LIST_HEADER_ID = p_list_header_id;



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
(   p_list_header_id                IN  NUMBER
) RETURN QP_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
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
    ,       AUTOMATIC_FLAG
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_CODE
    ,       DISCOUNT_LINES_FLAG
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       GSA_INDICATOR
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_TYPE_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PRORATE_FLAG
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SHIP_METHOD_CODE
    ,       START_DATE_ACTIVE
    ,       TERMS_ID
    ,       ACTIVE_FLAG
    ,       MOBILE_DOWNLOAD --mkarya for bug 1944882
    ,       CURRENCY_HEADER_ID --Multi-Currency SunilPandey
    ,       PTE_CODE --Attributes Manager Giri
    ,	    LIST_SOURCE_CODE --Blanket Sales Order
    ,	    ORIG_SYSTEM_HEADER_REF --Blanket Sales Order
    ,	    GLOBAL_FLAG --Pricing Security gtippire
    ,       SOURCE_SYSTEM_CODE
    ,       SHAREABLE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       LOCKED_FROM_LIST_HEADER_ID
            --added for MOAC
    ,       ORIG_ORG_ID
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
    ,       l_PRICE_LIST_rec.automatic_flag
    ,       l_PRICE_LIST_rec.comments
    ,       l_PRICE_LIST_rec.context
    ,       l_PRICE_LIST_rec.created_by
    ,       l_PRICE_LIST_rec.creation_date
    ,       l_PRICE_LIST_rec.currency_code
    ,       l_PRICE_LIST_rec.discount_lines_flag
    ,       l_PRICE_LIST_rec.end_date_active
    ,       l_PRICE_LIST_rec.freight_terms_code
    ,       l_PRICE_LIST_rec.gsa_indicator
    ,       l_PRICE_LIST_rec.last_updated_by
    ,       l_PRICE_LIST_rec.last_update_date
    ,       l_PRICE_LIST_rec.last_update_login
    ,       l_PRICE_LIST_rec.list_header_id
    ,       l_PRICE_LIST_rec.list_type_code
    ,       l_PRICE_LIST_rec.program_application_id
    ,       l_PRICE_LIST_rec.program_id
    ,       l_PRICE_LIST_rec.program_update_date
    ,       l_PRICE_LIST_rec.prorate_flag
    ,       l_PRICE_LIST_rec.request_id
    ,       l_PRICE_LIST_rec.rounding_factor
    ,       l_PRICE_LIST_rec.ship_method_code
    ,       l_PRICE_LIST_rec.start_date_active
    ,       l_PRICE_LIST_rec.terms_id
    ,       l_PRICE_LIST_rec.active_flag
    ,       l_PRICE_LIST_rec.mobile_download -- mkarya for bug 1944882
    ,       l_PRICE_LIST_rec.currency_header_id -- Multi-Currency SunilPandey
    ,       l_PRICE_LIST_rec.pte_code -- Attributes Manager Giri
    ,	    l_PRICE_LIST_rec.list_source_code -- Blanket Sales Order
    ,       l_PRICE_LIST_rec.orig_system_header_ref -- Blanket Sales Order
    ,       l_PRICE_LIST_rec.global_flag -- Pricing Security gtippire
    ,       l_PRICE_LIST_rec.source_system_code
    ,       l_PRICE_LIST_rec.shareable_flag
    ,       l_PRICE_LIST_rec.sold_to_org_id
    ,       l_PRICE_LIST_rec.locked_from_list_header_id
            --added for MOAC
    ,       l_PRICE_LIST_rec.org_id
    FROM    QP_LIST_HEADERS_B
    WHERE   LIST_HEADER_ID = p_list_header_id
    ;

    SELECT NAME
    ,      DESCRIPTION
    ,      VERSION_NO
    INTO   l_PRICE_LIST_rec.name
    ,      l_PRICE_LIST_rec.description
    ,      l_PRICE_LIST_rec.version_no
    FROM   QP_LIST_HEADERS_TL
    WHERE  LIST_HEADER_ID = p_list_header_id
    AND    LANGUAGE = userenv('LANG');


    RETURN l_PRICE_LIST_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN            QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
)
IS
cursor c1 is select
      NAME,
      DESCRIPTION,
	 VERSION_NO,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from QP_LIST_HEADERS_TL
    where LIST_HEADER_ID = p_PRICE_LIST_rec.LIST_HEADER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_HEADER_ID nowait;

l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
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
    ,       AUTOMATIC_FLAG
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CURRENCY_CODE
    ,       DISCOUNT_LINES_FLAG
    ,       END_DATE_ACTIVE
    ,       FREIGHT_TERMS_CODE
    ,       GSA_INDICATOR
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_TYPE_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PRORATE_FLAG
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SHIP_METHOD_CODE
    ,       START_DATE_ACTIVE
    ,       TERMS_ID
    ,       ACTIVE_FLAG  -- Added by dhgupta for bug 2144903
    ,       MOBILE_DOWNLOAD  -- Added by dhgupta for bug 2144903
    ,       CURRENCY_HEADER_ID  --Multi-Currency Change SunilPandey; new change
    ,       PTE_CODE  --Attributes Manager Change - Giri
    ,       LIST_SOURCE_CODE --Blanket Sales Order
    ,	    ORIG_SYSTEM_HEADER_REF -- Blanket Sales Order
    ,	    GLOBAL_FLAG -- Pricing Security gtippire
    ,       SOURCE_SYSTEM_CODE
    ,       SHAREABLE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       LOCKED_FROM_LIST_HEADER_ID
            --added for MOAC
    ,       ORIG_ORG_ID
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
    ,       l_PRICE_LIST_rec.automatic_flag
    ,       l_PRICE_LIST_rec.comments
    ,       l_PRICE_LIST_rec.context
    ,       l_PRICE_LIST_rec.created_by
    ,       l_PRICE_LIST_rec.creation_date
    ,       l_PRICE_LIST_rec.currency_code
    ,       l_PRICE_LIST_rec.discount_lines_flag
    ,       l_PRICE_LIST_rec.end_date_active
    ,       l_PRICE_LIST_rec.freight_terms_code
    ,       l_PRICE_LIST_rec.gsa_indicator
    ,       l_PRICE_LIST_rec.last_updated_by
    ,       l_PRICE_LIST_rec.last_update_date
    ,       l_PRICE_LIST_rec.last_update_login
    ,       l_PRICE_LIST_rec.list_header_id
    ,       l_PRICE_LIST_rec.list_type_code
    ,       l_PRICE_LIST_rec.program_application_id
    ,       l_PRICE_LIST_rec.program_id
    ,       l_PRICE_LIST_rec.program_update_date
    ,       l_PRICE_LIST_rec.prorate_flag
    ,       l_PRICE_LIST_rec.request_id
    ,       l_PRICE_LIST_rec.rounding_factor
    ,       l_PRICE_LIST_rec.ship_method_code
    ,       l_PRICE_LIST_rec.start_date_active
    ,       l_PRICE_LIST_rec.terms_id
    ,       l_PRICE_LIST_rec.active_flag  -- Added by dhgupta for bug 2144903
    ,       l_PRICE_LIST_rec.mobile_download -- Added by dhgupta for bug 2144903
    ,       l_PRICE_LIST_rec.currency_header_id --Multi-Currency Change SunilPandey; new change
    ,       l_PRICE_LIST_rec.pte_code --Attributes manager Change - Giri
    ,	    l_PRICE_LIST_rec.list_source_code --Blanket Sales Order
    ,	    l_PRICE_LIST_rec.orig_system_header_ref --Blanket Sales Order
    ,	    l_PRICE_LIST_rec.global_flag --Pricing Security gtippire
    ,       l_PRICE_LIST_rec.source_system_code
    ,       l_PRICE_LIST_rec.shareable_flag
    ,       l_PRICE_LIST_rec.sold_to_org_id
    ,       l_PRICE_LIST_rec.locked_from_list_header_id
            --added for MOAC
    ,       l_PRICE_LIST_rec.org_id
    --for moac changes QP_LIST_HEADERS_B to all_b to enable locks/updates to PL with orig_org_id
    --that do not belong to the responsibility when the user has update privilges
    FROM    QP_LIST_HEADERS_ALL_B
    WHERE   LIST_HEADER_ID = p_PRICE_LIST_rec.list_header_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute1,
                         l_PRICE_LIST_rec.attribute1)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute10,
                         l_PRICE_LIST_rec.attribute10)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute11,
                         l_PRICE_LIST_rec.attribute11)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute12,
                         l_PRICE_LIST_rec.attribute12)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute13,
                         l_PRICE_LIST_rec.attribute13)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute14,
                         l_PRICE_LIST_rec.attribute14)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute15,
                         l_PRICE_LIST_rec.attribute15)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute2,
                         l_PRICE_LIST_rec.attribute2)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute3,
                         l_PRICE_LIST_rec.attribute3)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute4,
                         l_PRICE_LIST_rec.attribute4)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute5,
                         l_PRICE_LIST_rec.attribute5)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute6,
                         l_PRICE_LIST_rec.attribute6)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute7,
                         l_PRICE_LIST_rec.attribute7)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute8,
                         l_PRICE_LIST_rec.attribute8)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.attribute9,
                         l_PRICE_LIST_rec.attribute9)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.automatic_flag,
                         l_PRICE_LIST_rec.automatic_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.comments,
                         l_PRICE_LIST_rec.comments)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.context,
                         l_PRICE_LIST_rec.context)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.created_by,
                         l_PRICE_LIST_rec.created_by)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.creation_date,
                         l_PRICE_LIST_rec.creation_date)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,
                         l_PRICE_LIST_rec.currency_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.discount_lines_flag,
                         l_PRICE_LIST_rec.discount_lines_flag)
    AND QP_GLOBALS.Equal(to_date(to_char(p_PRICE_LIST_rec.end_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'),
                         to_date(to_char(l_PRICE_LIST_rec.end_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,
                         l_PRICE_LIST_rec.freight_terms_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.gsa_indicator,
                         l_PRICE_LIST_rec.gsa_indicator)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_updated_by,
                         l_PRICE_LIST_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_date,
                         l_PRICE_LIST_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.last_update_login,
                         l_PRICE_LIST_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_header_id,
                         l_PRICE_LIST_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_type_code,
                         l_PRICE_LIST_rec.list_type_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_application_id,
                         l_PRICE_LIST_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_id,
                         l_PRICE_LIST_rec.program_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.program_update_date,
                         l_PRICE_LIST_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.prorate_flag,
                         l_PRICE_LIST_rec.prorate_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.request_id,
                         l_PRICE_LIST_rec.request_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.rounding_factor,
                         l_PRICE_LIST_rec.rounding_factor)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,
                         l_PRICE_LIST_rec.ship_method_code)
    AND QP_GLOBALS.Equal(to_date(to_char(p_PRICE_LIST_rec.start_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'),
                         to_date(to_char(l_PRICE_LIST_rec.start_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,
                         l_PRICE_LIST_rec.terms_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.active_flag,    -- Added by dhgupta for bug 2144903
                         l_PRICE_LIST_rec.active_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.mobile_download,  -- Added by dhgupta for bug 2144903
                         l_PRICE_LIST_rec.mobile_download)
    -- Multi-Currency Change SunilPandey
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_header_id,
                         l_PRICE_LIST_rec.currency_header_id)
    -- Blanket Sales Order
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_source_code,
                         l_PRICE_LIST_rec.list_source_code)
    -- Bug # 5128941
    --AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.orig_system_header_ref,
    --                     l_PRICE_LIST_rec.orig_system_header_ref)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.global_flag,  -- Pricing Security gtippire
                         l_PRICE_LIST_rec.global_flag)
    -- Blanket Pricing
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.source_system_code,
                         l_PRICE_LIST_rec.source_system_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.shareable_flag,
                         l_PRICE_LIST_rec.shareable_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.sold_to_org_id,
	                 l_PRICE_LIST_rec.sold_to_org_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.locked_from_list_header_id,
	                 l_PRICE_LIST_rec.locked_from_list_header_id)
    --added for MOAC
    AND QP_GLOBALS.Equal(p_PRICE_LIST_rec.org_id,
                         l_PRICE_LIST_rec.org_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

       oe_debug_pub.add('success 1');

    ELSE

       --8594682 - Add debug messages for OE_LOCK error
	oe_debug_pub.ADD('-------------------Data compare in Price list header (database vs record)------------------');
	oe_debug_pub.add('list_header_id	:'||l_PRICE_LIST_rec.list_header_id||':'||p_PRICE_LIST_rec.list_header_id||':');
	oe_debug_pub.ADD('attribute1		:'||l_PRICE_LIST_rec.attribute1||':'||p_PRICE_LIST_rec.attribute1||':');
	oe_debug_pub.ADD('attribute2		:'||l_PRICE_LIST_rec.attribute2||':'||p_PRICE_LIST_rec.attribute2||':');
	oe_debug_pub.ADD('attribute3		:'||l_PRICE_LIST_rec.attribute3||':'||p_PRICE_LIST_rec.attribute3||':');
	oe_debug_pub.ADD('attribute4		:'||l_PRICE_LIST_rec.attribute4||':'||p_PRICE_LIST_rec.attribute4||':');
	oe_debug_pub.ADD('attribute5		:'||l_PRICE_LIST_rec.attribute5||':'||p_PRICE_LIST_rec.attribute5||':');
	oe_debug_pub.ADD('attribute6		:'||l_PRICE_LIST_rec.attribute6||':'||p_PRICE_LIST_rec.attribute6||':');
	oe_debug_pub.ADD('attribute7		:'||l_PRICE_LIST_rec.attribute7||':'||p_PRICE_LIST_rec.attribute7||':');
	oe_debug_pub.ADD('attribute8		:'||l_PRICE_LIST_rec.attribute8||':'||p_PRICE_LIST_rec.attribute8||':');
	oe_debug_pub.ADD('attribute9		:'||l_PRICE_LIST_rec.attribute9||':'||p_PRICE_LIST_rec.attribute9||':');
	oe_debug_pub.ADD('attribute10		:'||l_PRICE_LIST_rec.attribute10||':'||p_PRICE_LIST_rec.attribute10||':');
	oe_debug_pub.ADD('attribute11		:'||l_PRICE_LIST_rec.attribute11||':'||p_PRICE_LIST_rec.attribute11||':');
	oe_debug_pub.ADD('attribute12		:'||l_PRICE_LIST_rec.attribute12||':'||p_PRICE_LIST_rec.attribute12||':');
	oe_debug_pub.ADD('attribute13		:'||l_PRICE_LIST_rec.attribute13||':'||p_PRICE_LIST_rec.attribute13||':');
	oe_debug_pub.ADD('attribute14		:'||l_PRICE_LIST_rec.attribute14||':'||p_PRICE_LIST_rec.attribute14||':');
	oe_debug_pub.ADD('attribute15		:'||l_PRICE_LIST_rec.attribute15||':'||p_PRICE_LIST_rec.attribute15||':');
	oe_debug_pub.ADD('AUTOMATIC_FLAG	:'||l_PRICE_LIST_rec.AUTOMATIC_FLAG||':'||p_PRICE_LIST_rec.AUTOMATIC_FLAG||':');
	oe_debug_pub.ADD('COMMENTS		:'||l_PRICE_LIST_rec.COMMENTS||':'||p_PRICE_LIST_rec.COMMENTS||':');
	oe_debug_pub.ADD('CONTEXT		:'||l_PRICE_LIST_rec.CONTEXT||':'||p_PRICE_LIST_rec.CONTEXT||':');
	oe_debug_pub.ADD('CREATED_BY		:'||l_PRICE_LIST_rec.CREATED_BY||':'||p_PRICE_LIST_rec.CREATED_BY||':');
	oe_debug_pub.ADD('CREATION_DATE		:'||l_PRICE_LIST_rec.CREATION_DATE||':'||p_PRICE_LIST_rec.CREATION_DATE||':');
	oe_debug_pub.ADD('CURRENCY_CODE		:'||l_PRICE_LIST_rec.CURRENCY_CODE||':'||p_PRICE_LIST_rec.CURRENCY_CODE||':');
	oe_debug_pub.ADD('DISCOUNT_LINES_FLAG	:'||l_PRICE_LIST_rec.DISCOUNT_LINES_FLAG||':'||p_PRICE_LIST_rec.DISCOUNT_LINES_FLAG||':');
	oe_debug_pub.ADD('END_DATE_ACTIVE	:'||l_PRICE_LIST_rec.END_DATE_ACTIVE||':'||p_PRICE_LIST_rec.END_DATE_ACTIVE||':');
	oe_debug_pub.ADD('FREIGHT_TERMS_CODE	:'||l_PRICE_LIST_rec.FREIGHT_TERMS_CODE||':'||p_PRICE_LIST_rec.FREIGHT_TERMS_CODE||':');
	oe_debug_pub.ADD('GSA_INDICATOR		:'||l_PRICE_LIST_rec.GSA_INDICATOR||':'||p_PRICE_LIST_rec.GSA_INDICATOR||':');
	oe_debug_pub.ADD('LIST_TYPE_CODE	:'||l_PRICE_LIST_rec.LIST_TYPE_CODE||':'||p_PRICE_LIST_rec.LIST_TYPE_CODE||':');
	oe_debug_pub.ADD('PROGRAM_APPLICATION_ID:'||l_PRICE_LIST_rec.PROGRAM_APPLICATION_ID||':'||p_PRICE_LIST_rec.PROGRAM_APPLICATION_ID||':');
	oe_debug_pub.ADD('PRORATE_FLAG		:'||l_PRICE_LIST_rec.PRORATE_FLAG||':'||p_PRICE_LIST_rec.PRORATE_FLAG||':');
	oe_debug_pub.ADD('REQUEST_ID		:'||l_PRICE_LIST_rec.REQUEST_ID||':'||p_PRICE_LIST_rec.REQUEST_ID||':');
	oe_debug_pub.ADD('ROUNDING_FACTOR	:'||l_PRICE_LIST_rec.ROUNDING_FACTOR||':'||p_PRICE_LIST_rec.ROUNDING_FACTOR||':');
	oe_debug_pub.ADD('SHIP_METHOD_CODE	:'||l_PRICE_LIST_rec.SHIP_METHOD_CODE||':'||p_PRICE_LIST_rec.SHIP_METHOD_CODE||':');
	oe_debug_pub.ADD('START_DATE_ACTIVE	:'||l_PRICE_LIST_rec.START_DATE_ACTIVE||':'||p_PRICE_LIST_rec.START_DATE_ACTIVE||':');
	oe_debug_pub.ADD('TERMS_ID		:'||l_PRICE_LIST_rec.TERMS_ID||':'||p_PRICE_LIST_rec.TERMS_ID||':');
	oe_debug_pub.ADD('ACTIVE_FLAG		:'||l_PRICE_LIST_rec.ACTIVE_FLAG||':'||p_PRICE_LIST_rec.ACTIVE_FLAG||':');
	oe_debug_pub.ADD('MOBILE_DOWNLOAD	:'||l_PRICE_LIST_rec.MOBILE_DOWNLOAD||':'||p_PRICE_LIST_rec.MOBILE_DOWNLOAD||':');
	oe_debug_pub.ADD('CURRENCY_HEADER_ID	:'||l_PRICE_LIST_rec.CURRENCY_HEADER_ID||':'||p_PRICE_LIST_rec.CURRENCY_HEADER_ID||':');
	oe_debug_pub.ADD('PTE_CODE		:'||l_PRICE_LIST_rec.PTE_CODE||':'||p_PRICE_LIST_rec.PTE_CODE||':');
	oe_debug_pub.ADD('LIST_SOURCE_CODE	:'||l_PRICE_LIST_rec.LIST_SOURCE_CODE||':'||p_PRICE_LIST_rec.LIST_SOURCE_CODE||':');
	oe_debug_pub.ADD('ORIG_SYSTEM_HEADER_REF:'||l_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF||':'||p_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF||':');
	oe_debug_pub.ADD('GLOBAL_FLAG		:'||l_PRICE_LIST_rec.GLOBAL_FLAG||':'||p_PRICE_LIST_rec.GLOBAL_FLAG||':');
	oe_debug_pub.ADD('SOURCE_SYSTEM_CODE	:'||l_PRICE_LIST_rec.SOURCE_SYSTEM_CODE||':'||p_PRICE_LIST_rec.SOURCE_SYSTEM_CODE||':');
	oe_debug_pub.ADD('SHAREABLE_FLAG	:'||l_PRICE_LIST_rec.SHAREABLE_FLAG||':'||p_PRICE_LIST_rec.SHAREABLE_FLAG||':');
	oe_debug_pub.ADD('SOLD_TO_ORG_ID	:'||l_PRICE_LIST_rec.SOLD_TO_ORG_ID||':'||p_PRICE_LIST_rec.SOLD_TO_ORG_ID||':');
	oe_debug_pub.ADD('LOCKED_FROM_LIST_HEADER_ID:'||l_PRICE_LIST_rec.LOCKED_FROM_LIST_HEADER_ID||':'||p_PRICE_LIST_rec.LOCKED_FROM_LIST_HEADER_ID||':');
	oe_debug_pub.ADD('-------------------Data compare in price list header end------------------');
	--end 8594682

       if not QP_GLOBALS.EQUAL(p_PRICE_LIST_rec.list_source_code,l_PRICE_LIST_rec.list_source_code) then
        --  Row has changed by another user.
        oe_debug_pub.add('Passed Value: LSC'||p_PRICE_LIST_rec.list_source_code);
        oe_debug_pub.add('DB Value: LSC'||l_PRICE_LIST_rec.list_source_code);

       end if ;

      if not QP_GLOBALS.EQUAL(p_PRICE_LIST_rec.orig_system_header_ref,l_PRICE_LIST_rec.orig_system_header_ref) then

        oe_debug_pub.add('Passed Value: OSHR'||p_PRICE_LIST_rec.orig_system_header_ref);


        oe_debug_pub.add('DB Value: OSHR'||l_PRICE_LIST_rec.orig_system_header_ref);
      end if;
        oe_debug_pub.add('failed 1');

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

    for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
        oe_debug_pub.add('DB Value: name'||tlinfo.NAME||' Passed Value: '|| p_PRICE_LIST_rec.NAME);
        oe_debug_pub.add('DB Value: description'||tlinfo.description||' Passed Value: '|| p_PRICE_LIST_rec.description);
        oe_debug_pub.add('DB Value: version_no'||tlinfo.version_no||' Passed Value: '|| p_PRICE_LIST_rec.version_no);
      if ( 1=1 --   (tlinfo.NAME = p_PRICE_LIST_rec.NAME)
          AND ((tlinfo.DESCRIPTION = p_PRICE_LIST_rec.DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_PRICE_LIST_rec.DESCRIPTION is null)))
          AND ((tlinfo.VERSION_NO = p_PRICE_LIST_rec.VERSION_NO)
               OR ((tlinfo.VERSION_NO is null) AND (p_PRICE_LIST_rec.VERSION_NO is null)))
      ) then
             x_PRICE_LIST_rec.NAME := tlinfo.NAME;
             x_PRICE_LIST_rec.VERSION_NO := tlinfo.VERSION_NO;
             x_PRICE_LIST_rec.DESCRIPTION := tlinfo.DESCRIPTION;
      else
                oe_debug_pub.add('failed 2');

        oe_debug_pub.add('tlinfo.name - rec.name ' || tlinfo.name || ' - ' || p_PRICE_LIST_rec.name );

        oe_debug_pub.add('tlinfo.description - rec.desc ' || tlinfo.description || ' - ' || p_PRICE_LIST_rec.description );

        oe_debug_pub.add('tlinfo.ver_no - rec.ver_no ' || tlinfo.version_no || ' - ' || p_PRICE_LIST_rec.version_no );

        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;



EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
) RETURN QP_Price_List_PUB.Price_List_Val_Rec_Type
IS
l_PRICE_LIST_val_rec          QP_Price_List_PUB.Price_List_Val_Rec_Type;
BEGIN

    IF p_PRICE_LIST_rec.automatic_flag IS NOT NULL AND
        p_PRICE_LIST_rec.automatic_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.automatic_flag,
        p_old_PRICE_LIST_rec.automatic_flag)
    THEN
        l_PRICE_LIST_val_rec.automatic := QP_Id_To_Value.Automatic
        (   p_automatic_flag              => p_PRICE_LIST_rec.automatic_flag
        );
    END IF;

    IF p_PRICE_LIST_rec.currency_code IS NOT NULL AND
        p_PRICE_LIST_rec.currency_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.currency_code,
        p_old_PRICE_LIST_rec.currency_code)
    THEN
        l_PRICE_LIST_val_rec.currency := QP_Id_To_Value.Currency
        (   p_currency_code               => p_PRICE_LIST_rec.currency_code
        );
    END IF;

    IF p_PRICE_LIST_rec.discount_lines_flag IS NOT NULL AND
        p_PRICE_LIST_rec.discount_lines_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.discount_lines_flag,
        p_old_PRICE_LIST_rec.discount_lines_flag)
    THEN
        l_PRICE_LIST_val_rec.discount_lines := QP_Id_To_Value.Discount_Lines
        (   p_discount_lines_flag         => p_PRICE_LIST_rec.discount_lines_flag
        );
    END IF;

    IF p_PRICE_LIST_rec.freight_terms_code IS NOT NULL AND
        p_PRICE_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.freight_terms_code,
        p_old_PRICE_LIST_rec.freight_terms_code)
    THEN
        l_PRICE_LIST_val_rec.freight_terms := QP_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_PRICE_LIST_rec.freight_terms_code
        );
    END IF;

    IF p_PRICE_LIST_rec.list_header_id IS NOT NULL AND
        p_PRICE_LIST_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_header_id,
        p_old_PRICE_LIST_rec.list_header_id)
    THEN
        l_PRICE_LIST_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_PRICE_LIST_rec.list_header_id
        );
    END IF;

    IF p_PRICE_LIST_rec.list_type_code IS NOT NULL AND
        p_PRICE_LIST_rec.list_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.list_type_code,
        p_old_PRICE_LIST_rec.list_type_code)
    THEN
        l_PRICE_LIST_val_rec.list_type := QP_Id_To_Value.List_Type
        (   p_list_type_code              => p_PRICE_LIST_rec.list_type_code
        );
    END IF;

    IF p_PRICE_LIST_rec.prorate_flag IS NOT NULL AND
        p_PRICE_LIST_rec.prorate_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.prorate_flag,
        p_old_PRICE_LIST_rec.prorate_flag)
    THEN
        l_PRICE_LIST_val_rec.prorate := QP_Id_To_Value.Prorate
        (   p_prorate_flag                => p_PRICE_LIST_rec.prorate_flag
        );
    END IF;

    IF p_PRICE_LIST_rec.ship_method_code IS NOT NULL AND
        p_PRICE_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.ship_method_code,
        p_old_PRICE_LIST_rec.ship_method_code)
    THEN
        l_PRICE_LIST_val_rec.ship_method := QP_Id_To_Value.Ship_Method
        (   p_ship_method_code            => p_PRICE_LIST_rec.ship_method_code
        );
    END IF;

    IF p_PRICE_LIST_rec.terms_id IS NOT NULL AND
        p_PRICE_LIST_rec.terms_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_rec.terms_id,
        p_old_PRICE_LIST_rec.terms_id)
    THEN
        l_PRICE_LIST_val_rec.terms := QP_Id_To_Value.Terms
        (   p_terms_id                    => p_PRICE_LIST_rec.terms_id
        );
    END IF;

    RETURN l_PRICE_LIST_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Rec_Type
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICE_LIST_rec.

    l_PRICE_LIST_rec := p_PRICE_LIST_rec;

    IF  p_PRICE_LIST_val_rec.automatic <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.automatic_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.automatic_flag := p_PRICE_LIST_rec.automatic_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.automatic_flag := QP_Value_To_Id.automatic
            (   p_automatic                   => p_PRICE_LIST_val_rec.automatic
            );

            IF l_PRICE_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.currency <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.currency_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.currency_code := p_PRICE_LIST_rec.currency_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.currency_code := QP_Value_To_Id.currency
            (   p_currency                    => p_PRICE_LIST_val_rec.currency
            );

            IF l_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.discount_lines <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.discount_lines_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.discount_lines_flag := p_PRICE_LIST_rec.discount_lines_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.discount_lines_flag := QP_Value_To_Id.discount_lines
            (   p_discount_lines              => p_PRICE_LIST_val_rec.discount_lines
            );

            IF l_PRICE_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.freight_terms_code := p_PRICE_LIST_rec.freight_terms_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.freight_terms_code := QP_Value_To_Id.freight_terms
            (   p_freight_terms               => p_PRICE_LIST_val_rec.freight_terms
            );

            IF l_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_rec.list_header_id := p_PRICE_LIST_rec.list_header_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_PRICE_LIST_val_rec.list_header
            );

            IF l_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.list_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.list_type_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.list_type_code := p_PRICE_LIST_rec.list_type_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.list_type_code := QP_Value_To_Id.list_type
            (   p_list_type                   => p_PRICE_LIST_val_rec.list_type
            );

            IF l_PRICE_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.prorate <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.prorate_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.prorate_flag := p_PRICE_LIST_rec.prorate_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.prorate_flag := QP_Value_To_Id.prorate
            (   p_prorate                     => p_PRICE_LIST_val_rec.prorate
            );

            IF l_PRICE_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_val_rec.ship_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_rec.ship_method_code := p_PRICE_LIST_rec.ship_method_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.ship_method_code := QP_Value_To_Id.ship_method
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

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_rec.terms_id := QP_Value_To_Id.terms
            (   p_terms                       => p_PRICE_LIST_val_rec.terms
            );

            IF l_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PRICE_LIST_rec;

END Get_Ids;

--ENH Upgrade BOAPI for orig_sys...ref RAVI
FUNCTION Get_Orig_Sys_Hdr(
  p_LIST_HEADER_ID NUMBER
) RETURN VARCHAR2
IS
  l_exist NUMBER:=0;
BEGIN
  IF p_LIST_HEADER_ID IS NULL THEN
    RETURN NULL;
  ELSE
    Select COUNT(*) into l_exist
    from qp_list_headers_b h
    where h.orig_system_header_ref=to_char(p_LIST_HEADER_ID);

    IF l_exist>0 THEN
      RETURN 'INT-D-'||TO_CHAR(p_LIST_HEADER_ID);
    ELSE
      RETURN TO_CHAR(p_LIST_HEADER_ID);
    END IF;
  END IF;
END;

END QP_Price_List_Util;

/

--------------------------------------------------------
--  DDL for Package Body QP_MODIFIER_LIST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIER_LIST_UTIL" AS
/* $Header: QPXUMLHB.pls 120.4.12010000.5 2009/08/19 07:18:38 smbalara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Modifier_List_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   x_MODIFIER_LIST_rec             OUT NOCOPY QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN


	oe_debug_pub.add('BEGIN clear_dependent_attr in QPXUMLHB');

    --  Load out record

    x_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute1,p_old_MODIFIER_LIST_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute10,p_old_MODIFIER_LIST_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute11,p_old_MODIFIER_LIST_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute12,p_old_MODIFIER_LIST_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute13,p_old_MODIFIER_LIST_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute14,p_old_MODIFIER_LIST_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute15,p_old_MODIFIER_LIST_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute2,p_old_MODIFIER_LIST_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute3,p_old_MODIFIER_LIST_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute4,p_old_MODIFIER_LIST_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute5,p_old_MODIFIER_LIST_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute6,p_old_MODIFIER_LIST_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute7,p_old_MODIFIER_LIST_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute8,p_old_MODIFIER_LIST_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute9,p_old_MODIFIER_LIST_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.automatic_flag,p_old_MODIFIER_LIST_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_AUTOMATIC;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.comments,p_old_MODIFIER_LIST_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_COMMENTS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.context,p_old_MODIFIER_LIST_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.created_by,p_old_MODIFIER_LIST_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.creation_date,p_old_MODIFIER_LIST_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.currency_code,p_old_MODIFIER_LIST_rec.currency_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CURRENCY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.discount_lines_flag,p_old_MODIFIER_LIST_rec.discount_lines_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_DISCOUNT_LINES;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active,p_old_MODIFIER_LIST_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.freight_terms_code,p_old_MODIFIER_LIST_rec.freight_terms_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_FREIGHT_TERMS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.gsa_indicator,p_old_MODIFIER_LIST_rec.gsa_indicator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_GSA_INDICATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_updated_by,p_old_MODIFIER_LIST_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_date,p_old_MODIFIER_LIST_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_login,p_old_MODIFIER_LIST_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_header_id,p_old_MODIFIER_LIST_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_type_code,p_old_MODIFIER_LIST_rec.list_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_application_id,p_old_MODIFIER_LIST_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_id,p_old_MODIFIER_LIST_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_update_date,p_old_MODIFIER_LIST_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.prorate_flag,p_old_MODIFIER_LIST_rec.prorate_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PRORATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.request_id,p_old_MODIFIER_LIST_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.rounding_factor,p_old_MODIFIER_LIST_rec.rounding_factor)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ROUNDING_FACTOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ship_method_code,p_old_MODIFIER_LIST_rec.ship_method_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SHIP_METHOD;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active,p_old_MODIFIER_LIST_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.terms_id,p_old_MODIFIER_LIST_rec.terms_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_TERMS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.source_system_code,p_old_MODIFIER_LIST_rec.source_system_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SOURCE_SYSTEM_CODE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.pte_code,p_old_MODIFIER_LIST_rec.pte_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PTE_CODE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_flag,p_old_MODIFIER_LIST_rec.active_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_FLAG;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.parent_list_header_id,p_old_MODIFIER_LIST_rec.parent_list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PARENT_LIST_HEADER_ID;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_first,p_old_MODIFIER_LIST_rec.start_date_active_first)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE_FIRST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_first,p_old_MODIFIER_LIST_rec.end_date_active_first)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE_FIRST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_first_type,p_old_MODIFIER_LIST_rec.active_date_first_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_DATE_FIRST_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_second,p_old_MODIFIER_LIST_rec.start_date_active_second)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE_SECOND;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.global_flag,p_old_MODIFIER_LIST_rec.global_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_GLOBAL_FLAG;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_second,p_old_MODIFIER_LIST_rec.end_date_active_second)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE_SECOND;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_second_type,p_old_MODIFIER_LIST_rec.active_date_second_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_DATE_SECOND_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ask_for_flag,p_old_MODIFIER_LIST_rec.ask_for_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ASK_FOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.name,p_old_MODIFIER_LIST_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.description,p_old_MODIFIER_LIST_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_DESCRIPTION;
        END IF;

-- Blanket Pricing
	IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.list_source_code, p_old_MODIFIER_LIST_rec.list_source_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_SOURCE_CODE;
	END IF;

	IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.orig_system_header_ref, p_old_MODIFIER_LIST_rec.orig_system_header_ref)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ORIG_SYSTEM_HEADER_REF;
	END IF;

	IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.shareable_flag,p_old_MODIFIER_LIST_rec.shareable_flag)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SHAREABLE_FLAG;
	END IF;

        --added for MOAC
	IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.org_id,p_old_MODIFIER_LIST_rec.org_id)
	THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ORG_ID;
	END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AUTOMATIC THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_AUTOMATIC;
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_CURRENCY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_CURRENCY;
    ELSIF p_attr_id = G_DISCOUNT_LINES THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_DISCOUNT_LINES;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_FREIGHT_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_FREIGHT_TERMS;
    ELSIF p_attr_id = G_GSA_INDICATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_GSA_INDICATOR;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_TYPE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_PRORATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PRORATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_ROUNDING_FACTOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ROUNDING_FACTOR;
    ELSIF p_attr_id = G_SHIP_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SHIP_METHOD;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_TERMS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_TERMS;
    ELSIF p_attr_id = G_SOURCE_SYSTEM_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SOURCE_SYSTEM_CODE;
    ELSIF p_attr_id = G_PTE_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PTE_CODE;
    ELSIF p_attr_id = G_ACTIVE_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_FLAG;
    ELSIF p_attr_id = G_PARENT_LIST_HEADER_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_PARENT_LIST_HEADER_ID;
    ELSIF p_attr_id = G_START_DATE_ACTIVE_FIRST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE_FIRST;
    ELSIF p_attr_id = G_END_DATE_ACTIVE_FIRST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE_FIRST;
    ELSIF p_attr_id = G_ACTIVE_DATE_FIRST_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_DATE_FIRST_TYPE;
    ELSIF p_attr_id = G_START_DATE_ACTIVE_SECOND THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_START_DATE_ACTIVE_SECOND;
    ELSIF p_attr_id = G_GLOBAL_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_GLOBAL_FLAG;
    ELSIF p_attr_id = G_END_DATE_ACTIVE_SECOND THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_END_DATE_ACTIVE_SECOND;
    ELSIF p_attr_id = G_ACTIVE_DATE_SECOND_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ACTIVE_DATE_SECOND_TYPE;
    ELSIF p_attr_id = G_ASK_FOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ASK_FOR;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_NAME;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_DESCRIPTION;
-- Blanket pricing
    ELSIF p_attr_id = G_LIST_SOURCE_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_LIST_SOURCE_CODE;
    ELSIF p_attr_id = G_ORIG_SYSTEM_HEADER_REF THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ORIG_SYSTEM_HEADER_REF;
    ELSIF p_attr_id = G_SHAREABLE_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_SHAREABLE_FLAG;
    --added for MOAC
    ELSIF p_attr_id = G_ORG_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIER_LIST_UTIL.G_ORG_ID;
    END IF;
	oe_debug_pub.add('END clear_dependent_attr in QPXUMLHB');

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   x_MODIFIER_LIST_rec             OUT NOCOPY QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_modifiers_exist VARCHAR2(1) := 'N';
------------------------fix for bug 3756625
CURSOR l_pricing_phase_cur (l_list_header_id NUMBER) IS
select distinct pricing_phase_id from qp_list_lines
where list_header_id = l_list_header_id;
BEGIN

	oe_debug_pub.add('BEGIN apply_attribute_changes in QPXUMLHB');
    --  Load out record

    x_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute1,p_old_MODIFIER_LIST_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute10,p_old_MODIFIER_LIST_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute11,p_old_MODIFIER_LIST_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute12,p_old_MODIFIER_LIST_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute13,p_old_MODIFIER_LIST_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute14,p_old_MODIFIER_LIST_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute15,p_old_MODIFIER_LIST_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute2,p_old_MODIFIER_LIST_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute3,p_old_MODIFIER_LIST_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute4,p_old_MODIFIER_LIST_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute5,p_old_MODIFIER_LIST_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute6,p_old_MODIFIER_LIST_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute7,p_old_MODIFIER_LIST_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute8,p_old_MODIFIER_LIST_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute9,p_old_MODIFIER_LIST_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.automatic_flag,p_old_MODIFIER_LIST_rec.automatic_flag)
    THEN
       -- NULL;
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.comments,p_old_MODIFIER_LIST_rec.comments)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.context,p_old_MODIFIER_LIST_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.created_by,p_old_MODIFIER_LIST_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.creation_date,p_old_MODIFIER_LIST_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.currency_code,p_old_MODIFIER_LIST_rec.currency_code)
    THEN
--      NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
            qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
	END IF;
    END IF;
-- Pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.discount_lines_flag,p_old_MODIFIER_LIST_rec.discount_lines_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active,p_old_MODIFIER_LIST_rec.end_date_active)
    THEN
       -- NULL;
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.freight_terms_code,p_old_MODIFIER_LIST_rec.freight_terms_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.gsa_indicator,p_old_MODIFIER_LIST_rec.gsa_indicator)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_updated_by,p_old_MODIFIER_LIST_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_date,p_old_MODIFIER_LIST_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_login,p_old_MODIFIER_LIST_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_header_id,p_old_MODIFIER_LIST_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_type_code,p_old_MODIFIER_LIST_rec.list_type_code)
    THEN
        NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
            qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
	END IF;
     END IF;
-- Pattern
-- jagan's PL/SQL pattern

       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
	END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_application_id,p_old_MODIFIER_LIST_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_id,p_old_MODIFIER_LIST_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_update_date,p_old_MODIFIER_LIST_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.prorate_flag,p_old_MODIFIER_LIST_rec.prorate_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.request_id,p_old_MODIFIER_LIST_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.rounding_factor,p_old_MODIFIER_LIST_rec.rounding_factor)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ship_method_code,p_old_MODIFIER_LIST_rec.ship_method_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active,p_old_MODIFIER_LIST_rec.start_date_active)
    THEN
      --  NULL;
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.terms_id,p_old_MODIFIER_LIST_rec.terms_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.source_system_code,p_old_MODIFIER_LIST_rec.source_system_code)
    THEN
        NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	   IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
            qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
          END IF;
	END IF;
-- Pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'Y' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
            qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
          END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.pte_code,p_old_MODIFIER_LIST_rec.pte_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_flag,p_old_MODIFIER_LIST_rec.active_flag)
    THEN
        NULL;

		--hw
		-- log delayed request for changed lines for active flag change
		if QP_PERF_PVT.enabled = 'Y' then
 		qp_delayed_requests_pvt.log_request(
          	p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
       	  	p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
          	p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
          	p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
          	p_request_type => QP_GLOBALS.G_UPDATE_CHANGED_LINES_ACT,
			p_param1 => p_MODIFIER_LIST_rec.active_flag,
          	x_return_status => x_MODIFIER_LIST_rec.return_status);
		end if;

		--hvop
		qp_delayed_requests_pvt.log_request(
                p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
                p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
                p_request_type => QP_GLOBALS.G_UPDATE_HVOP,
                x_return_status => x_MODIFIER_LIST_rec.return_status);
		--hvop
		IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
            	 IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                  qp_delayed_requests_pvt.log_request(
		  p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		  p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		  p_request_unique_key1 => NULL,
		  p_request_unique_key2 => 'UD',
		  p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		  p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		  p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		  x_return_status => x_MODIFIER_LIST_rec.return_status);
		END IF;
              END IF; --Java Engine Installed
	-- Pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                  qp_delayed_requests_pvt.log_request(
		  p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		  p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		  p_request_unique_key1 => NULL,
		  p_request_unique_key2 => 'UD',
		  p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		  p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		  p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		  x_return_status => x_MODIFIER_LIST_rec.return_status);
	 END IF;
       END IF;
      END IF;
--to populate rltd_Exists,oid_exists,prg_exists and qp_basic_modifiers_setup
--performance profile
  IF p_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

	BEGIN
	select 'Y' into l_modifiers_exist
	from qp_list_lines
	where list_header_id = p_MODIFIER_LIST_rec.list_header_id
	and rownum = 1;
	EXCEPTION
	When OTHERS THEN
	l_modifiers_exist := 'N';
	END;

	IF l_modifiers_exist = 'Y' THEN

------------------fix for bug 3756625
  FOR I in l_pricing_phase_cur(p_MODIFIER_LIST_rec.list_header_id)
LOOP

         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIER_LIST_rec.list_header_id,
                  p_param1  => I.pricing_phase_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                 p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => x_MODIFIER_LIST_rec.return_status);
END LOOP;

	qp_delayed_requests_pvt.log_request(
                p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
                p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
                p_request_type => QP_GLOBALS.G_UPDATE_HVOP,
                x_return_status => x_MODIFIER_LIST_rec.return_status);
	END IF;
  END IF;

  IF p_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

           Update QP_QUALIFIERS
           set    active_flag = p_MODIFIER_LIST_rec.active_flag
           where  list_header_id = p_MODIFIER_LIST_rec.list_header_id;

   IF p_MODIFIER_LIST_rec.active_flag = 'Y'
   THEN
	update qp_pte_segments set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and segment_id in
	(select  a.segment_id
	from qp_segments_b a,qp_prc_contexts_b b,qp_qualifiers c
	where c.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c .qualifier_attribute
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'QUALIFIER'
	and   b.prc_context_code       = c.qualifier_context);

	update qp_pte_segments d set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and exists
	(select  'x'
	from qp_segments_b a,qp_prc_contexts_b b,qp_pricing_attributes c
	where c.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.pricing_attribute
        and   a.segment_id             = d.segment_id
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'PRICING_ATTRIBUTE'
	and   b.prc_context_code       = c.pricing_attribute_context);

	update qp_pte_segments d set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and exists
	(select  'x'
	from qp_segments_b a,qp_prc_contexts_b b,qp_pricing_attributes c
	where c.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.product_attribute
        and   a.segment_id             = d.segment_id
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = 'PRODUCT'
	and   b.prc_context_code       = c.product_attribute_context);

	update qp_pte_segments set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and segment_id in
	(select  a.segment_id
	from qp_segments_b a,qp_prc_contexts_b b,qp_limits c
	where c.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.multival_attribute1
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = c.multival_attr1_type
	and   b.prc_context_code       = c.multival_attr1_context);

	update qp_pte_segments set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and segment_id in
	(select  a.segment_id
	from qp_segments_b a,qp_prc_contexts_b b,qp_limits c
	where c.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.multival_attribute2
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = c.multival_attr2_type
	and   b.prc_context_code       = c.multival_attr2_context);


	update qp_pte_segments set used_in_setup='Y'
	where nvl(used_in_setup,'N')='N'
	and segment_id in
	(select  a.segment_id
	from qp_segments_b a,qp_prc_contexts_b b,qp_limit_attributes c,qp_limits d
	where c.limit_id               = d.limit_id
        and   d.list_header_id         = p_MODIFIER_LIST_rec.list_header_id
	and   a.segment_mapping_column = c.limit_attribute
	and   a.prc_context_id         = b.prc_context_id
	and   b.prc_context_type       = c.limit_attribute_type
	and   b.prc_context_code       = c.limit_attribute_context);

    END IF;

  END IF;
  END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.parent_list_header_id,p_old_MODIFIER_LIST_rec.parent_list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_first,p_old_MODIFIER_LIST_rec.start_date_active_first)
    THEN
      --  NULL;
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_first,p_old_MODIFIER_LIST_rec.end_date_active_first)
    THEN
       -- NULL;
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_first_type,p_old_MODIFIER_LIST_rec.active_date_first_type)
    THEN
       -- NULL;
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_second,p_old_MODIFIER_LIST_rec.start_date_active_second)
    THEN
      --  NULL;
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.global_flag,p_old_MODIFIER_LIST_rec.global_flag)
    THEN
     --   NULL;
     IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;


    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_second,p_old_MODIFIER_LIST_rec.end_date_active_second)
    THEN
      --  NULL;
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_second_type,p_old_MODIFIER_LIST_rec.active_date_second_type)
    THEN
      --  NULL;
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B'THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
                qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
        END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ask_for_flag,p_old_MODIFIER_LIST_rec.ask_for_flag)
    THEN
        NULL;
	IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	  IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
            END IF;
	END IF;
-- Pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF(p_MODIFIER_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
             qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_unique_key1 => NULL,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIER_LIST_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN,
		x_return_status => x_MODIFIER_LIST_rec.return_status);
            END IF;
       END IF;
      END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.name,p_old_MODIFIER_LIST_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.description,p_old_MODIFIER_LIST_rec.description)
    THEN
        NULL;
    END IF;

    -- Blanket Pricing
    IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.list_source_code, p_old_MODIFIER_LIST_rec.list_source_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.orig_system_header_ref, p_old_MODIFIER_LIST_rec.orig_system_header_ref)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.shareable_flag, p_old_MODIFIER_LIST_rec.shareable_flag)
    THEN
        NULL;
    END IF;

    --added for MOAC
    IF NOT QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.org_id, p_old_MODIFIER_LIST_rec.org_id)
    THEN
        NULL;
    END IF;

	oe_debug_pub.add('END apply_attribute_changes in QPXUMLHB');
END Apply_Attribute_Changes;


--  Function Complete_Record

FUNCTION Complete_Record
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
BEGIN

	oe_debug_pub.add('BEGIN complete_record in QPXUMLHB');

    IF l_MODIFIER_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute1 := p_old_MODIFIER_LIST_rec.attribute1;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute10 := p_old_MODIFIER_LIST_rec.attribute10;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute11 := p_old_MODIFIER_LIST_rec.attribute11;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute12 := p_old_MODIFIER_LIST_rec.attribute12;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute13 := p_old_MODIFIER_LIST_rec.attribute13;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute14 := p_old_MODIFIER_LIST_rec.attribute14;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute15 := p_old_MODIFIER_LIST_rec.attribute15;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute2 := p_old_MODIFIER_LIST_rec.attribute2;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute3 := p_old_MODIFIER_LIST_rec.attribute3;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute4 := p_old_MODIFIER_LIST_rec.attribute4;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute5 := p_old_MODIFIER_LIST_rec.attribute5;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute6 := p_old_MODIFIER_LIST_rec.attribute6;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute7 := p_old_MODIFIER_LIST_rec.attribute7;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute8 := p_old_MODIFIER_LIST_rec.attribute8;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute9 := p_old_MODIFIER_LIST_rec.attribute9;
    END IF;

    IF l_MODIFIER_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.automatic_flag := p_old_MODIFIER_LIST_rec.automatic_flag;
    END IF;

    IF l_MODIFIER_LIST_rec.comments = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.comments := p_old_MODIFIER_LIST_rec.comments;
    END IF;

    IF l_MODIFIER_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.context := p_old_MODIFIER_LIST_rec.context;
    END IF;

    IF l_MODIFIER_LIST_rec.created_by = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.created_by := p_old_MODIFIER_LIST_rec.created_by;
    END IF;

    IF l_MODIFIER_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.creation_date := p_old_MODIFIER_LIST_rec.creation_date;
    END IF;

    IF l_MODIFIER_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.currency_code := p_old_MODIFIER_LIST_rec.currency_code;
    END IF;

    IF l_MODIFIER_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.discount_lines_flag := p_old_MODIFIER_LIST_rec.discount_lines_flag;
    END IF;

    IF l_MODIFIER_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active := p_old_MODIFIER_LIST_rec.end_date_active;
    END IF;

    IF l_MODIFIER_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.freight_terms_code := p_old_MODIFIER_LIST_rec.freight_terms_code;
    END IF;

    IF l_MODIFIER_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.gsa_indicator := p_old_MODIFIER_LIST_rec.gsa_indicator;
    END IF;

    IF l_MODIFIER_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.last_updated_by := p_old_MODIFIER_LIST_rec.last_updated_by;
    END IF;

    IF l_MODIFIER_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.last_update_date := p_old_MODIFIER_LIST_rec.last_update_date;
    END IF;

    IF l_MODIFIER_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.last_update_login := p_old_MODIFIER_LIST_rec.last_update_login;
    END IF;

    IF l_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.list_header_id := p_old_MODIFIER_LIST_rec.list_header_id;
    END IF;

    IF l_MODIFIER_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.list_type_code := p_old_MODIFIER_LIST_rec.list_type_code;
    END IF;

    IF l_MODIFIER_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.program_application_id := p_old_MODIFIER_LIST_rec.program_application_id;
    END IF;

    IF l_MODIFIER_LIST_rec.program_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.program_id := p_old_MODIFIER_LIST_rec.program_id;
    END IF;

    IF l_MODIFIER_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.program_update_date := p_old_MODIFIER_LIST_rec.program_update_date;
    END IF;

    IF l_MODIFIER_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.prorate_flag := p_old_MODIFIER_LIST_rec.prorate_flag;
    END IF;

    IF l_MODIFIER_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.request_id := p_old_MODIFIER_LIST_rec.request_id;
    END IF;

    IF l_MODIFIER_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.rounding_factor := p_old_MODIFIER_LIST_rec.rounding_factor;
    END IF;

    IF l_MODIFIER_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.ship_method_code := p_old_MODIFIER_LIST_rec.ship_method_code;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active := p_old_MODIFIER_LIST_rec.start_date_active;
    END IF;

    IF l_MODIFIER_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.terms_id := p_old_MODIFIER_LIST_rec.terms_id;
    END IF;

    IF l_MODIFIER_LIST_rec.source_system_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.source_system_code := p_old_MODIFIER_LIST_rec.source_system_code;
    END IF;

    IF l_MODIFIER_LIST_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.pte_code := p_old_MODIFIER_LIST_rec.pte_code;
    END IF;

    IF l_MODIFIER_LIST_rec.active_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_flag := p_old_MODIFIER_LIST_rec.active_flag;
    END IF;

    IF l_MODIFIER_LIST_rec.parent_list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.parent_list_header_id := p_old_MODIFIER_LIST_rec.parent_list_header_id;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active_first = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active_first := p_old_MODIFIER_LIST_rec.start_date_active_first;
    END IF;

    IF l_MODIFIER_LIST_rec.end_date_active_first = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active_first := p_old_MODIFIER_LIST_rec.end_date_active_first;
    END IF;

    IF l_MODIFIER_LIST_rec.active_date_first_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_date_first_type := p_old_MODIFIER_LIST_rec.active_date_first_type;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active_second = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active_second := p_old_MODIFIER_LIST_rec.start_date_active_second;
    END IF;

    IF l_MODIFIER_LIST_rec.global_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.global_flag := p_old_MODIFIER_LIST_rec.global_flag;
    END IF;


    IF l_MODIFIER_LIST_rec.end_date_active_second = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active_second := p_old_MODIFIER_LIST_rec.end_date_active_second;
    END IF;

    IF l_MODIFIER_LIST_rec.active_date_second_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_date_second_type := p_old_MODIFIER_LIST_rec.active_date_second_type;
    END IF;

    IF l_MODIFIER_LIST_rec.ask_for_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.ask_for_flag := p_old_MODIFIER_LIST_rec.ask_for_flag;
    END IF;

    IF l_MODIFIER_LIST_rec.name = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.name := p_old_MODIFIER_LIST_rec.name;
    END IF;

    IF l_MODIFIER_LIST_rec.version_no = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.version_no := p_old_MODIFIER_LIST_rec.version_no;
    END IF;

    IF l_MODIFIER_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.description := p_old_MODIFIER_LIST_rec.description;
    END IF;

    -- Blanket Agreement Pricing bug#3871577
    IF l_MODIFIER_LIST_rec.list_source_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.list_source_code := p_old_MODIFIER_LIST_rec.list_source_code;
    END IF;

    IF l_MODIFIER_LIST_rec.orig_system_header_ref = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.orig_system_header_ref := p_old_MODIFIER_LIST_rec.orig_system_header_ref;
    END IF;

    IF l_MODIFIER_LIST_rec.shareable_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.shareable_flag := p_old_MODIFIER_LIST_rec.shareable_flag;
    END IF;

    --added for MOAC
    IF l_MODIFIER_LIST_rec.org_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.org_id := p_old_MODIFIER_LIST_rec.org_id;
    END IF;

	oe_debug_pub.add('version QPXUMLHB'||l_MODIFIER_LIST_rec.version_no);
	oe_debug_pub.add('END complete_record in QPXUMLHB');
    RETURN l_MODIFIER_LIST_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
BEGIN

	oe_debug_pub.add('BEGIN convert_miss_to_null in QPXUMLHB');

    IF l_MODIFIER_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute1 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute10 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute11 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute12 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute13 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute14 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute15 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute2 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute3 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute4 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute5 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute6 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute7 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute8 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.attribute9 := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.automatic_flag := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.comments = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.comments := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.context := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.created_by = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.created_by := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.creation_date := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.currency_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.discount_lines_flag := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.freight_terms_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.gsa_indicator := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.last_updated_by := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.last_update_date := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.last_update_login := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.list_header_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.list_type_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.program_application_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.program_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.program_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.program_update_date := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.prorate_flag := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.request_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.request_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.rounding_factor := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.ship_method_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.terms_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.source_system_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.source_system_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.pte_code := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.active_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_flag := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.parent_list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIER_LIST_rec.parent_list_header_id := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active_first = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active_first := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.end_date_active_first = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active_first := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.active_date_first_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_date_first_type :=  NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.start_date_active_second = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.start_date_active_second := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.global_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.global_flag := NULL;
    END IF;


    IF l_MODIFIER_LIST_rec.end_date_active_second = FND_API.G_MISS_DATE THEN
        l_MODIFIER_LIST_rec.end_date_active_second := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.active_date_second_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.active_date_second_type := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.ask_for_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.ask_for_flag := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.name = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.name := NULL;
    END IF;

    IF l_MODIFIER_LIST_rec.description = FND_API.G_MISS_CHAR THEN
        l_MODIFIER_LIST_rec.description := NULL;
    END IF;

	oe_debug_pub.add('END convert_miss_to_null in QPXUMLHB');

    RETURN l_MODIFIER_LIST_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_active_date_first_type   VARCHAR2(30);
l_start_date_active_first  DATE;
l_end_date_active_first    DATE;
l_active_date_second_type  VARCHAR2(30);
l_start_date_active_second DATE;
l_end_date_active_second   DATE;
BEGIN

	oe_debug_pub.add('BEGIN update_row in QPXUMLHB');

    -- MKARYA - Correct the first and second active dates value, for bug 1744890
    l_active_date_first_type := p_MODIFIER_LIST_rec.active_date_first_type;
    l_start_date_active_first := p_MODIFIER_LIST_rec.start_date_active_first;
    l_end_date_active_first := p_MODIFIER_LIST_rec.end_date_active_first;
    l_active_date_second_type := p_MODIFIER_LIST_rec.active_date_second_type;
    l_start_date_active_second := p_MODIFIER_LIST_rec.start_date_active_second;
    l_end_date_active_second := p_MODIFIER_LIST_rec.end_date_active_second;

    IF (l_active_date_first_type = 'SHIP'
        OR l_active_date_second_type = 'ORD') THEN
           QP_UTIL.CORRECT_ACTIVE_DATES(l_active_date_first_type
                                       ,l_start_date_active_first
                                       ,l_end_date_active_first
                                       ,l_active_date_second_type
                                       ,l_start_date_active_second
                                       ,l_end_date_active_second
                                       );
    END IF;

    if QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                   p_instance_type => QP_Security.G_MODIFIER_OBJECT,
                                   p_instance_pk1 => p_MODIFIER_LIST_rec.list_header_id) <> 'F' then

    --for moac changes QP_LIST_HEADERS_B to all_b to enable updates to ML with orig_org_id
    --that do not belong to the responsibility when the user has update privilges
    UPDATE  QP_LIST_HEADERS_ALL_B
    SET     ATTRIBUTE1                     = p_MODIFIER_LIST_rec.attribute1
    ,       ATTRIBUTE10                    = p_MODIFIER_LIST_rec.attribute10
    ,       ATTRIBUTE11                    = p_MODIFIER_LIST_rec.attribute11
    ,       ATTRIBUTE12                    = p_MODIFIER_LIST_rec.attribute12
    ,       ATTRIBUTE13                    = p_MODIFIER_LIST_rec.attribute13
    ,       ATTRIBUTE14                    = p_MODIFIER_LIST_rec.attribute14
    ,       ATTRIBUTE15                    = p_MODIFIER_LIST_rec.attribute15
    ,       ATTRIBUTE2                     = p_MODIFIER_LIST_rec.attribute2
    ,       ATTRIBUTE3                     = p_MODIFIER_LIST_rec.attribute3
    ,       ATTRIBUTE4                     = p_MODIFIER_LIST_rec.attribute4
    ,       ATTRIBUTE5                     = p_MODIFIER_LIST_rec.attribute5
    ,       ATTRIBUTE6                     = p_MODIFIER_LIST_rec.attribute6
    ,       ATTRIBUTE7                     = p_MODIFIER_LIST_rec.attribute7
    ,       ATTRIBUTE8                     = p_MODIFIER_LIST_rec.attribute8
    ,       ATTRIBUTE9                     = p_MODIFIER_LIST_rec.attribute9
    ,       AUTOMATIC_FLAG                 = p_MODIFIER_LIST_rec.automatic_flag
    ,       COMMENTS                       = p_MODIFIER_LIST_rec.comments
    ,       CONTEXT                        = p_MODIFIER_LIST_rec.context
    ,       CREATED_BY                     = p_MODIFIER_LIST_rec.created_by
    ,       CREATION_DATE                  = p_MODIFIER_LIST_rec.creation_date
    ,       CURRENCY_CODE                  = p_MODIFIER_LIST_rec.currency_code
    ,       DISCOUNT_LINES_FLAG            = p_MODIFIER_LIST_rec.discount_lines_flag
    ,       END_DATE_ACTIVE                = TRUNC(p_MODIFIER_LIST_rec.end_date_active)
    ,       FREIGHT_TERMS_CODE             = p_MODIFIER_LIST_rec.freight_terms_code
    ,       GSA_INDICATOR                  = p_MODIFIER_LIST_rec.gsa_indicator
    ,       LAST_UPDATED_BY                = p_MODIFIER_LIST_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_MODIFIER_LIST_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_MODIFIER_LIST_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_MODIFIER_LIST_rec.list_header_id
    ,       LIST_TYPE_CODE                 = p_MODIFIER_LIST_rec.list_type_code
    ,       PROGRAM_APPLICATION_ID         = p_MODIFIER_LIST_rec.program_application_id
    ,       PROGRAM_ID                     = p_MODIFIER_LIST_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_MODIFIER_LIST_rec.program_update_date
    ,       PRORATE_FLAG                   = p_MODIFIER_LIST_rec.prorate_flag
    ,       REQUEST_ID                     = p_MODIFIER_LIST_rec.request_id
    ,       ROUNDING_FACTOR                = p_MODIFIER_LIST_rec.rounding_factor
    ,       SHIP_METHOD_CODE               = p_MODIFIER_LIST_rec.ship_method_code
    ,       START_DATE_ACTIVE              = TRUNC(p_MODIFIER_LIST_rec.start_date_active)
    ,       TERMS_ID                       = p_MODIFIER_LIST_rec.terms_id
    ,       SOURCE_SYSTEM_CODE             = p_MODIFIER_LIST_rec.source_system_code
    ,       PTE_CODE                       = p_MODIFIER_LIST_rec.pte_code
    ,       ACTIVE_FLAG                    = p_MODIFIER_LIST_rec.active_flag
    ,       PARENT_LIST_HEADER_ID          = p_MODIFIER_LIST_rec.parent_list_header_id
    ,       START_DATE_ACTIVE_FIRST        = TRUNC(l_start_date_active_first)
    ,       END_DATE_ACTIVE_FIRST          = TRUNC(l_end_date_active_first)
    ,       ACTIVE_DATE_FIRST_TYPE         = l_active_date_first_type
    ,       START_DATE_ACTIVE_SECOND       = TRUNC(l_start_date_active_second)
    ,       GLOBAL_FLAG                    = p_MODIFIER_LIST_rec.global_flag
    ,       END_DATE_ACTIVE_SECOND         = TRUNC(l_end_date_active_second)
    ,       ACTIVE_DATE_SECOND_TYPE        = l_active_date_second_type
    ,       ASK_FOR_FLAG                   = p_MODIFIER_LIST_rec.ask_for_flag
    ,       LIST_SOURCE_CODE               = p_MODIFIER_LIST_rec.list_source_code
    ,       ORIG_SYSTEM_HEADER_REF         = p_MODIFIER_LIST_rec.orig_system_header_ref
    ,       SHAREABLE_FLAG                 = p_MODIFIER_LIST_rec.shareable_flag
    ,       ORIG_ORG_ID                    = p_MODIFIER_LIST_rec.org_id
    WHERE   LIST_HEADER_ID = p_MODIFIER_LIST_rec.list_header_id
    ;

    Begin

       update QP_LIST_HEADERS_TL set
         NAME                   = p_MODIFIER_LIST_rec.NAME
       , DESCRIPTION            = p_MODIFIER_LIST_rec.DESCRIPTION
       , VERSION_NO             = p_MODIFIER_LIST_rec.VERSION_NO
       , LAST_UPDATE_DATE       = p_MODIFIER_LIST_rec.LAST_UPDATE_DATE
       , LAST_UPDATED_BY        = p_MODIFIER_LIST_rec.LAST_UPDATED_BY
       , LAST_UPDATE_LOGIN      = p_MODIFIER_LIST_rec.LAST_UPDATE_LOGIN
       , SOURCE_LANG            = userenv('LANG')
       where LIST_HEADER_ID     = p_MODIFIER_LIST_rec.LIST_HEADER_ID
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

       Exception
         WHEN DUP_VAL_ON_INDEX THEN

         FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MODIFIER');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;

           WHEN OTHERS THEN

               IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
               THEN
                   OE_MSG_PUB.Add_Exc_Msg
                   (   G_PKG_NAME
                   ,      'Update_Row'
                   );
               END IF;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       End;
     end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
    RAISE;

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
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_return_status   VARCHAR2(30);
l_active_date_first_type   VARCHAR2(30);
l_start_date_active_first  DATE;
l_end_date_active_first    DATE;
l_active_date_second_type  VARCHAR2(30);
l_start_date_active_second DATE;
l_end_date_active_second   DATE;
x_result                   VARCHAR2(1);

BEGIN

Begin

insert into QP_LIST_HEADERS_TL
( LIST_HEADER_ID
, NAME
, DESCRIPTION
, VERSION_NO
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, LANGUAGE
, SOURCE_LANG
) select
  p_MODIFIER_LIST_rec.LIST_HEADER_ID
, p_MODIFIER_LIST_rec.NAME
, p_MODIFIER_LIST_rec.DESCRIPTION
, p_MODIFIER_LIST_rec.VERSION_NO
, p_MODIFIER_LIST_rec.CREATION_DATE
, p_MODIFIER_LIST_rec.CREATED_BY
, p_MODIFIER_LIST_rec.LAST_UPDATE_DATE
, p_MODIFIER_LIST_rec.LAST_UPDATED_BY
, p_MODIFIER_LIST_rec.LAST_UPDATE_LOGIN
, L.LANGUAGE_CODE
, userenv('LANG')
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I','B')
and not exists
(select NULL from QP_LIST_HEADERS_TL T
where T.LIST_HEADER_ID = p_MODIFIER_LIST_rec.LIST_HEADER_ID
and T.LANGUAGE = L.LANGUAGE_CODE);

Exception
  WHEN DUP_VAL_ON_INDEX THEN

  FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MODIFIER');
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

	oe_debug_pub.add('BEGIN insert_row in QPXUMLHB');

    -- MKARYA - Correct the first and second active dates value, for bug 1744890
    l_active_date_first_type := p_MODIFIER_LIST_rec.active_date_first_type;
    l_start_date_active_first := p_MODIFIER_LIST_rec.start_date_active_first;
    l_end_date_active_first := p_MODIFIER_LIST_rec.end_date_active_first;
    l_active_date_second_type := p_MODIFIER_LIST_rec.active_date_second_type;
    l_start_date_active_second := p_MODIFIER_LIST_rec.start_date_active_second;
    l_end_date_active_second := p_MODIFIER_LIST_rec.end_date_active_second;

    IF (l_active_date_first_type = 'SHIP'
        OR l_active_date_second_type = 'ORD') THEN
           QP_UTIL.CORRECT_ACTIVE_DATES(l_active_date_first_type
                                       ,l_start_date_active_first
                                       ,l_end_date_active_first
                                       ,l_active_date_second_type
                                       ,l_start_date_active_second
                                       ,l_end_date_active_second
                                       );
    END IF;

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
    ,       SOURCE_SYSTEM_CODE
    ,       PTE_CODE
    ,       ACTIVE_FLAG
    ,       PARENT_LIST_HEADER_ID
    ,       START_DATE_ACTIVE_FIRST
    ,       END_DATE_ACTIVE_FIRST
    ,       ACTIVE_DATE_FIRST_TYPE
    ,       START_DATE_ACTIVE_SECOND
    ,       GLOBAL_FLAG
    ,       END_DATE_ACTIVE_SECOND
    ,       ACTIVE_DATE_SECOND_TYPE
    , 	    ASK_FOR_FLAG
    , 	    orig_org_id
    ,       LIST_SOURCE_CODE
    ,       ORIG_SYSTEM_HEADER_REF
    ,       SHAREABLE_FLAG
    )
    VALUES
    (       p_MODIFIER_LIST_rec.attribute1
    ,       p_MODIFIER_LIST_rec.attribute10
    ,       p_MODIFIER_LIST_rec.attribute11
    ,       p_MODIFIER_LIST_rec.attribute12
    ,       p_MODIFIER_LIST_rec.attribute13
    ,       p_MODIFIER_LIST_rec.attribute14
    ,       p_MODIFIER_LIST_rec.attribute15
    ,       p_MODIFIER_LIST_rec.attribute2
    ,       p_MODIFIER_LIST_rec.attribute3
    ,       p_MODIFIER_LIST_rec.attribute4
    ,       p_MODIFIER_LIST_rec.attribute5
    ,       p_MODIFIER_LIST_rec.attribute6
    ,       p_MODIFIER_LIST_rec.attribute7
    ,       p_MODIFIER_LIST_rec.attribute8
    ,       p_MODIFIER_LIST_rec.attribute9
    ,       p_MODIFIER_LIST_rec.automatic_flag
    ,       p_MODIFIER_LIST_rec.comments
    ,       p_MODIFIER_LIST_rec.context
    ,       p_MODIFIER_LIST_rec.created_by
    ,       p_MODIFIER_LIST_rec.creation_date
    ,       p_MODIFIER_LIST_rec.currency_code
    ,       p_MODIFIER_LIST_rec.discount_lines_flag
    ,       TRUNC(p_MODIFIER_LIST_rec.end_date_active)
    ,       p_MODIFIER_LIST_rec.freight_terms_code
    ,       p_MODIFIER_LIST_rec.gsa_indicator
    ,       p_MODIFIER_LIST_rec.last_updated_by
    ,       p_MODIFIER_LIST_rec.last_update_date
    ,       p_MODIFIER_LIST_rec.last_update_login
    ,       p_MODIFIER_LIST_rec.list_header_id
    ,       p_MODIFIER_LIST_rec.list_type_code
    ,       p_MODIFIER_LIST_rec.program_application_id
    ,       p_MODIFIER_LIST_rec.program_id
    ,       p_MODIFIER_LIST_rec.program_update_date
    ,       p_MODIFIER_LIST_rec.prorate_flag
    ,       p_MODIFIER_LIST_rec.request_id
    ,       p_MODIFIER_LIST_rec.rounding_factor
    ,       p_MODIFIER_LIST_rec.ship_method_code
    ,       TRUNC(p_MODIFIER_LIST_rec.start_date_active)
    ,       p_MODIFIER_LIST_rec.terms_id
    ,       p_MODIFIER_LIST_rec.source_system_code
    ,       p_MODIFIER_LIST_rec.pte_code
    ,       p_MODIFIER_LIST_rec.active_flag
    ,       p_MODIFIER_LIST_rec.parent_list_header_id
    ,       TRUNC(l_start_date_active_first)
    ,       TRUNC(l_end_date_active_first)
    ,       l_active_date_first_type
    ,       TRUNC(l_start_date_active_second)
    ,       p_MODIFIER_LIST_rec.global_flag
    ,       TRUNC(l_end_date_active_second)
    ,       l_active_date_second_type
    ,       p_MODIFIER_LIST_rec.ask_for_flag
            --added for MOAC
    ,       p_MODIFIER_LIST_rec.org_id
    ,       p_MODIFIER_LIST_rec.list_source_code
    ,       p_MODIFIER_LIST_rec.orig_system_header_ref
    ,       p_MODIFIER_LIST_rec.shareable_flag
    );

    QP_Security.create_default_grants( p_instance_type => QP_Security.G_MODIFIER_OBJECT,
                                    p_instance_pk1 => p_MODIFIER_LIST_rec.list_header_id,
                                    x_return_status => x_result);

	oe_debug_pub.add('insert QPXUMLHB'||p_MODIFIER_LIST_rec.VERSION_NO||to_char(p_modifier_list_rec.list_header_id));


IF p_MODIFIER_LIST_rec.gsa_indicator = 'Y'
THEN

  QP_QP_Form_Modifier_List.Create_GSA_Qual(p_MODIFIER_LIST_rec.LIST_HEADER_ID ,
     							 FND_API.G_MISS_NUM,
  					--NULL, for bug2420752
							 'GSA',
							 l_return_status );
END IF;

oe_debug_pub.add('l_ret_sts'||l_return_status);
/*added this code to raise exception if qualifier does not get created-spgopal*/

	    	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
oe_debug_pub.add('l_ret_sts if'||l_return_status);
			FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
			OE_MSG_PUB.Add;

			  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
oe_debug_pub.add('l_ret_sts else '||l_return_status);
			FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
			OE_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
		END IF;



	oe_debug_pub.add('insert after QPXUMLHB'||p_MODIFIER_LIST_rec.VERSION_NO||to_char(p_modifier_list_rec.list_header_id));
	oe_debug_pub.add('END insert_row in QPXUMLHB');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


		--x_return_status := FND_API.G_RET_STS_ERROR;

/*
			--  Get message count and data

			OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			,   p_data                        => x_msg_data
			);
			*/
/* Commented for Bug 2101393
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*/
         RAISE;     -- Bug 2101393

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


		--x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

/*
			--  Get message count and data

			OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			,   p_data                        => x_msg_data
			);
			*/

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


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
(   p_list_header_id                IN  NUMBER
)
IS
CURSOR C1(a_list_header_id NUMBER)
IS
  SELECT list_line_id
  FROM   qp_list_lines
  WHERE  list_header_id = a_list_header_id;

BEGIN

	oe_debug_pub.add('BEGIN delete_row in QPXUMLHB');

  FOR list_lines in C1(p_list_header_id)
  LOOP

    DELETE FROM QP_PRICING_ATTRIBUTES
    WHERE LIST_LINE_ID = list_lines.list_line_id;

    DELETE FROM QP_RLTD_MODIFIERS
    WHERE FROM_RLTD_MODIFIER_ID = list_lines.list_line_id;

  END LOOP;

    DELETE FROM QP_LIST_LINES
    WHERE LIST_HEADER_ID = p_list_header_id;

    DELETE FROM QP_QUALIFIERS
    WHERE LIST_HEADER_ID = p_list_header_id;

    DELETE FROM QP_LIST_HEADERS_TL
    WHERE LIST_HEADER_ID = p_list_header_id;

    DELETE  FROM QP_LIST_HEADERS_B
    WHERE   LIST_HEADER_ID = p_list_header_id ;

	oe_debug_pub.add('END delete_row in QPXUMLHB');
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
(   p_list_header_id                IN  NUMBER
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
BEGIN

	oe_debug_pub.add('BEGIN query_row in QPXUMLHB');

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
    ,       SOURCE_SYSTEM_CODE
    ,       PTE_CODE
    ,       ACTIVE_FLAG
    ,       PARENT_LIST_HEADER_ID
    ,       START_DATE_ACTIVE_FIRST
    ,       END_DATE_ACTIVE_FIRST
    ,       ACTIVE_DATE_FIRST_TYPE
    ,       START_DATE_ACTIVE_SECOND
    ,       GLOBAL_FLAG
    ,       END_DATE_ACTIVE_SECOND
    ,       ACTIVE_DATE_SECOND_TYPE
    ,       ASK_FOR_FLAG
    ,       LIST_SOURCE_CODE
    ,       ORIG_SYSTEM_HEADER_REF
    ,       SHAREABLE_FLAG
            --added for MOAC
    ,       orig_org_id
    INTO    l_MODIFIER_LIST_rec.attribute1
    ,       l_MODIFIER_LIST_rec.attribute10
    ,       l_MODIFIER_LIST_rec.attribute11
    ,       l_MODIFIER_LIST_rec.attribute12
    ,       l_MODIFIER_LIST_rec.attribute13
    ,       l_MODIFIER_LIST_rec.attribute14
    ,       l_MODIFIER_LIST_rec.attribute15
    ,       l_MODIFIER_LIST_rec.attribute2
    ,       l_MODIFIER_LIST_rec.attribute3
    ,       l_MODIFIER_LIST_rec.attribute4
    ,       l_MODIFIER_LIST_rec.attribute5
    ,       l_MODIFIER_LIST_rec.attribute6
    ,       l_MODIFIER_LIST_rec.attribute7
    ,       l_MODIFIER_LIST_rec.attribute8
    ,       l_MODIFIER_LIST_rec.attribute9
    ,       l_MODIFIER_LIST_rec.automatic_flag
    ,       l_MODIFIER_LIST_rec.comments
    ,       l_MODIFIER_LIST_rec.context
    ,       l_MODIFIER_LIST_rec.created_by
    ,       l_MODIFIER_LIST_rec.creation_date
    ,       l_MODIFIER_LIST_rec.currency_code
    ,       l_MODIFIER_LIST_rec.discount_lines_flag
    ,       l_MODIFIER_LIST_rec.end_date_active
    ,       l_MODIFIER_LIST_rec.freight_terms_code
    ,       l_MODIFIER_LIST_rec.gsa_indicator
    ,       l_MODIFIER_LIST_rec.last_updated_by
    ,       l_MODIFIER_LIST_rec.last_update_date
    ,       l_MODIFIER_LIST_rec.last_update_login
    ,       l_MODIFIER_LIST_rec.list_header_id
    ,       l_MODIFIER_LIST_rec.list_type_code
    ,       l_MODIFIER_LIST_rec.program_application_id
    ,       l_MODIFIER_LIST_rec.program_id
    ,       l_MODIFIER_LIST_rec.program_update_date
    ,       l_MODIFIER_LIST_rec.prorate_flag
    ,       l_MODIFIER_LIST_rec.request_id
    ,       l_MODIFIER_LIST_rec.rounding_factor
    ,       l_MODIFIER_LIST_rec.ship_method_code
    ,       l_MODIFIER_LIST_rec.start_date_active
    ,       l_MODIFIER_LIST_rec.terms_id
    ,       l_MODIFIER_LIST_rec.source_system_code
    ,       l_MODIFIER_LIST_rec.pte_code
    ,       l_MODIFIER_LIST_rec.active_flag
    ,       l_MODIFIER_LIST_rec.parent_list_header_id
    ,       l_MODIFIER_LIST_rec.start_date_active_first
    ,       l_MODIFIER_LIST_rec.end_date_active_first
    ,       l_MODIFIER_LIST_rec.active_date_first_type
    ,       l_MODIFIER_LIST_rec.start_date_active_second
    ,       l_MODIFIER_LIST_rec.global_flag
    ,       l_MODIFIER_LIST_rec.end_date_active_second
    ,       l_MODIFIER_LIST_rec.active_date_second_type
    ,       l_MODIFIER_LIST_rec.ask_for_flag
    ,       l_MODIFIER_LIST_rec.list_source_code
    ,       l_MODIFIER_LIST_rec.orig_system_header_ref
    ,       l_MODIFIER_LIST_rec.shareable_flag
            --added for MOAC
    ,      l_MODIFIER_LIST_rec.org_id
    FROM    QP_LIST_HEADERS_B
    WHERE   LIST_HEADER_ID = p_list_header_id
    ;

    SELECT  NAME
    ,       DESCRIPTION
    ,       VERSION_NO
    INTO    l_MODIFIER_LIST_rec.name
    ,       l_MODIFIER_LIST_rec.description
    ,       l_MODIFIER_LIST_rec.version_no
    FROM    qp_list_headers_tl
    WHERE   LIST_HEADER_ID = p_list_header_id
    AND     LANGUAGE = userenv('LANG');

	oe_debug_pub.add('version_no QPXUMLHB'||l_MODIFIER_LIST_rec.version_no);
	oe_debug_pub.add('END query_row in QPXUMLHB');
    RETURN l_MODIFIER_LIST_rec;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    null;

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
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_rec             OUT NOCOPY QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
BEGIN

	oe_debug_pub.add('BEGIN lock_row in QPXUMLHB');

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
    , trunc(CREATION_DATE)
    ,       CURRENCY_CODE
    ,       DISCOUNT_LINES_FLAG
    , trunc(END_DATE_ACTIVE)
    ,       FREIGHT_TERMS_CODE
    ,       GSA_INDICATOR
    ,       LAST_UPDATED_BY
    , trunc(LAST_UPDATE_DATE)
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_TYPE_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    , trunc(PROGRAM_UPDATE_DATE)
    ,       PRORATE_FLAG
    ,       REQUEST_ID
    ,       ROUNDING_FACTOR
    ,       SHIP_METHOD_CODE
    , trunc(START_DATE_ACTIVE)
    ,       TERMS_ID
    ,       SOURCE_SYSTEM_CODE
    ,       PTE_CODE
    ,       ACTIVE_FLAG
    ,       PARENT_LIST_HEADER_ID
    , trunc(START_DATE_ACTIVE_FIRST)
    , trunc(END_DATE_ACTIVE_FIRST)
    ,      (ACTIVE_DATE_FIRST_TYPE)
    , trunc(START_DATE_ACTIVE_SECOND)
    ,       GLOBAL_FLAG
    , trunc(END_DATE_ACTIVE_SECOND)
    ,      (ACTIVE_DATE_SECOND_TYPE)
    ,       ASK_FOR_FLAG
    ,       LIST_SOURCE_CODE
    ,       ORIG_SYSTEM_HEADER_REF
    ,       SHAREABLE_FLAG
    ,       ORIG_ORG_ID
    INTO    l_MODIFIER_LIST_rec.attribute1
    ,       l_MODIFIER_LIST_rec.attribute10
    ,       l_MODIFIER_LIST_rec.attribute11
    ,       l_MODIFIER_LIST_rec.attribute12
    ,       l_MODIFIER_LIST_rec.attribute13
    ,       l_MODIFIER_LIST_rec.attribute14
    ,       l_MODIFIER_LIST_rec.attribute15
    ,       l_MODIFIER_LIST_rec.attribute2
    ,       l_MODIFIER_LIST_rec.attribute3
    ,       l_MODIFIER_LIST_rec.attribute4
    ,       l_MODIFIER_LIST_rec.attribute5
    ,       l_MODIFIER_LIST_rec.attribute6
    ,       l_MODIFIER_LIST_rec.attribute7
    ,       l_MODIFIER_LIST_rec.attribute8
    ,       l_MODIFIER_LIST_rec.attribute9
    ,       l_MODIFIER_LIST_rec.automatic_flag
    ,       l_MODIFIER_LIST_rec.comments
    ,       l_MODIFIER_LIST_rec.context
    ,       l_MODIFIER_LIST_rec.created_by
    ,       l_MODIFIER_LIST_rec.creation_date
    ,       l_MODIFIER_LIST_rec.currency_code
    ,       l_MODIFIER_LIST_rec.discount_lines_flag
    ,       l_MODIFIER_LIST_rec.end_date_active
    ,       l_MODIFIER_LIST_rec.freight_terms_code
    ,       l_MODIFIER_LIST_rec.gsa_indicator
    ,       l_MODIFIER_LIST_rec.last_updated_by
    ,       l_MODIFIER_LIST_rec.last_update_date
    ,       l_MODIFIER_LIST_rec.last_update_login
    ,       l_MODIFIER_LIST_rec.list_header_id
    ,       l_MODIFIER_LIST_rec.list_type_code
    ,       l_MODIFIER_LIST_rec.program_application_id
    ,       l_MODIFIER_LIST_rec.program_id
    ,       l_MODIFIER_LIST_rec.program_update_date
    ,       l_MODIFIER_LIST_rec.prorate_flag
    ,       l_MODIFIER_LIST_rec.request_id
    ,       l_MODIFIER_LIST_rec.rounding_factor
    ,       l_MODIFIER_LIST_rec.ship_method_code
    ,       l_MODIFIER_LIST_rec.start_date_active
    ,       l_MODIFIER_LIST_rec.terms_id
    ,       l_MODIFIER_LIST_rec.source_system_code
    ,       l_MODIFIER_LIST_rec.pte_code
    ,       l_MODIFIER_LIST_rec.active_flag
    ,       l_MODIFIER_LIST_rec.parent_list_header_id
    ,       l_MODIFIER_LIST_rec.start_date_active_first
    ,       l_MODIFIER_LIST_rec.end_date_active_first
    ,       l_MODIFIER_LIST_rec.active_date_first_type
    ,       l_MODIFIER_LIST_rec.start_date_active_second
    ,       l_MODIFIER_LIST_rec.global_flag
    ,       l_MODIFIER_LIST_rec.end_date_active_second
    ,       l_MODIFIER_LIST_rec.active_date_second_type
    ,       l_MODIFIER_LIST_rec.ask_for_flag
    ,       l_MODIFIER_LIST_rec.list_source_code
    ,       l_MODIFIER_LIST_rec.orig_system_header_ref
    ,       l_MODIFIER_LIST_rec.shareable_flag
            --added for MOAC
    ,       l_MODIFIER_LIST_rec.org_id
    --for moac changes QP_LIST_HEADERS_B to all_b to enable locks/updates to ML with orig_org_id
    --that do not belong to the responsibility when the user has update privilges
    FROM    QP_LIST_HEADERS_ALL_B
    WHERE   LIST_HEADER_ID = p_MODIFIER_LIST_rec.list_header_id
        FOR UPDATE NOWAIT;

    SELECT  NAME
    ,       DESCRIPTION
    ,       VERSION_NO
    INTO    l_MODIFIER_LIST_rec.name
    ,       l_MODIFIER_LIST_rec.description
    ,       l_MODIFIER_LIST_rec.version_no
    FROM    qp_list_headers_tl
    WHERE   LIST_HEADER_ID = p_MODIFIER_LIST_rec.list_header_id
    AND     LANGUAGE = userenv('LANG');

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute1,
                         l_MODIFIER_LIST_rec.attribute1)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute10,
                         l_MODIFIER_LIST_rec.attribute10)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute11,
                         l_MODIFIER_LIST_rec.attribute11)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute12,
                         l_MODIFIER_LIST_rec.attribute12)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute13,
                         l_MODIFIER_LIST_rec.attribute13)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute14,
                         l_MODIFIER_LIST_rec.attribute14)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute15,
                         l_MODIFIER_LIST_rec.attribute15)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute2,
                         l_MODIFIER_LIST_rec.attribute2)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute3,
                         l_MODIFIER_LIST_rec.attribute3)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute4,
                         l_MODIFIER_LIST_rec.attribute4)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute5,
                         l_MODIFIER_LIST_rec.attribute5)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute6,
                         l_MODIFIER_LIST_rec.attribute6)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute7,
                         l_MODIFIER_LIST_rec.attribute7)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute8,
                         l_MODIFIER_LIST_rec.attribute8)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.attribute9,
                         l_MODIFIER_LIST_rec.attribute9)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.automatic_flag,
                         l_MODIFIER_LIST_rec.automatic_flag)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.comments,
                         l_MODIFIER_LIST_rec.comments)
    AND  QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.context,
                         l_MODIFIER_LIST_rec.context)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.created_by,
                         l_MODIFIER_LIST_rec.created_by)
--    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.creation_date,
--                         l_MODIFIER_LIST_rec.creation_date)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.currency_code,
                         l_MODIFIER_LIST_rec.currency_code)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.discount_lines_flag,
                         l_MODIFIER_LIST_rec.discount_lines_flag)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active,
                         l_MODIFIER_LIST_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.freight_terms_code,
                         l_MODIFIER_LIST_rec.freight_terms_code)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.gsa_indicator,
                         l_MODIFIER_LIST_rec.gsa_indicator)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_updated_by,
                         l_MODIFIER_LIST_rec.last_updated_by)
--    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_date,
--                         l_MODIFIER_LIST_rec.last_update_date)
    AND  QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.last_update_login,
                         l_MODIFIER_LIST_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_header_id,
                         l_MODIFIER_LIST_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_type_code,
                         l_MODIFIER_LIST_rec.list_type_code)
    --AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_application_id,
    --                     l_MODIFIER_LIST_rec.program_application_id)
    --AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_id,
    --                     l_MODIFIER_LIST_rec.program_id)
    --AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.program_update_date,
    --                     l_MODIFIER_LIST_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.prorate_flag,
                         l_MODIFIER_LIST_rec.prorate_flag)
    --AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.request_id,
    --                     l_MODIFIER_LIST_rec.request_id)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.rounding_factor,
                         l_MODIFIER_LIST_rec.rounding_factor)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ship_method_code,
                         l_MODIFIER_LIST_rec.ship_method_code)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active,
                         l_MODIFIER_LIST_rec.start_date_active)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.terms_id,
                         l_MODIFIER_LIST_rec.terms_id)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.source_system_code,
                         l_MODIFIER_LIST_rec.source_system_code)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.pte_code,
                         l_MODIFIER_LIST_rec.pte_code)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_flag,
                         l_MODIFIER_LIST_rec.active_flag)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.parent_list_header_id,
                         l_MODIFIER_LIST_rec.parent_list_header_id)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_first,
                         l_MODIFIER_LIST_rec.start_date_active_first)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_first,
                         l_MODIFIER_LIST_rec.end_date_active_first)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_first_type,
                         l_MODIFIER_LIST_rec.active_date_first_type)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.start_date_active_second,
                         l_MODIFIER_LIST_rec.start_date_active_second)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.global_flag,
                         l_MODIFIER_LIST_rec.global_flag)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.end_date_active_second,
                         l_MODIFIER_LIST_rec.end_date_active_second)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.active_date_second_type,
                         l_MODIFIER_LIST_rec.active_date_second_type)
    AND QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ask_for_flag,
                         l_MODIFIER_LIST_rec.ask_for_flag)
    AND QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.list_source_code,
                         l_MODIFIER_LIST_rec.list_source_code)
    AND QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.orig_system_header_ref,
                         l_MODIFIER_LIST_rec.orig_system_header_ref)
    AND QP_GLOBALS.Equal (p_MODIFIER_LIST_rec.shareable_flag,
                         l_MODIFIER_LIST_rec.shareable_flag)
    THEN

        --  Row has not changed. Set out parameter.

        x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
	--debug messages added as per 8594682 for oe_lock_row error
	oe_debug_pub.ADD('-------------------data compare in modifier header (database vx record)------------------');
	oe_debug_pub.add('attribute1                   :'||l_MODIFIER_LIST_rec.attribute1||':'||p_MODIFIER_LIST_rec.attribute1||':');
	oe_debug_pub.add('attribute10                  :'||l_MODIFIER_LIST_rec.attribute10||':'||p_MODIFIER_LIST_rec.attribute10||':');
	oe_debug_pub.add('attribute11                  :'||l_MODIFIER_LIST_rec.attribute11||':'||p_MODIFIER_LIST_rec.attribute11||':');
	oe_debug_pub.add('attribute12                  :'||l_MODIFIER_LIST_rec.attribute12||':'||p_MODIFIER_LIST_rec.attribute12||':');
	oe_debug_pub.add('attribute13                  :'||l_MODIFIER_LIST_rec.attribute13||':'||p_MODIFIER_LIST_rec.attribute13||':');
	oe_debug_pub.add('attribute14                  :'||l_MODIFIER_LIST_rec.attribute14||':'||p_MODIFIER_LIST_rec.attribute14||':');
	oe_debug_pub.add('attribute15                  :'||l_MODIFIER_LIST_rec.attribute15||':'||p_MODIFIER_LIST_rec.attribute15||':');
	oe_debug_pub.add('attribute2                   :'||l_MODIFIER_LIST_rec.attribute2||':'||p_MODIFIER_LIST_rec.attribute2||':');
	oe_debug_pub.add('attribute3                   :'||l_MODIFIER_LIST_rec.attribute3||':'||p_MODIFIER_LIST_rec.attribute3||':');
	oe_debug_pub.add('attribute4                   :'||l_MODIFIER_LIST_rec.attribute4||':'||p_MODIFIER_LIST_rec.attribute4||':');
	oe_debug_pub.add('attribute5                   :'||l_MODIFIER_LIST_rec.attribute5||':'||p_MODIFIER_LIST_rec.attribute5||':');
	oe_debug_pub.add('attribute6                   :'||l_MODIFIER_LIST_rec.attribute6||':'||p_MODIFIER_LIST_rec.attribute6||':');
	oe_debug_pub.add('attribute7                   :'||l_MODIFIER_LIST_rec.attribute7||':'||p_MODIFIER_LIST_rec.attribute7||':');
	oe_debug_pub.add('attribute8                   :'||l_MODIFIER_LIST_rec.attribute8||':'||p_MODIFIER_LIST_rec.attribute8||':');
	oe_debug_pub.add('attribute9                   :'||l_MODIFIER_LIST_rec.attribute9||':'||p_MODIFIER_LIST_rec.attribute9||':');
	oe_debug_pub.add('automatic_flag               :'||l_MODIFIER_LIST_rec.automatic_flag||':'||p_MODIFIER_LIST_rec.automatic_flag||':');
	oe_debug_pub.add('comments                     :'||l_MODIFIER_LIST_rec.comments||':'||p_MODIFIER_LIST_rec.comments||':');
	oe_debug_pub.add('context                      :'||l_MODIFIER_LIST_rec.context||':'||p_MODIFIER_LIST_rec.context||':');
	oe_debug_pub.add('created_by                   :'||l_MODIFIER_LIST_rec.created_by||':'||p_MODIFIER_LIST_rec.created_by||':');
	oe_debug_pub.add('creation_date                :'||l_MODIFIER_LIST_rec.creation_date||':'||p_MODIFIER_LIST_rec.creation_date||':');
	oe_debug_pub.add('currency_code                :'||l_MODIFIER_LIST_rec.currency_code||':'||p_MODIFIER_LIST_rec.currency_code||':');
	oe_debug_pub.add('discount_lines_flag          :'||l_MODIFIER_LIST_rec.discount_lines_flag||':'||p_MODIFIER_LIST_rec.discount_lines_flag||':');
	oe_debug_pub.add('end_date_active              :'||l_MODIFIER_LIST_rec.end_date_active||':'||p_MODIFIER_LIST_rec.end_date_active||':');
	oe_debug_pub.add('freight_terms_code           :'||l_MODIFIER_LIST_rec.freight_terms_code||':'||p_MODIFIER_LIST_rec.freight_terms_code||':');
	oe_debug_pub.add('gsa_indicator                :'||l_MODIFIER_LIST_rec.gsa_indicator||':'||p_MODIFIER_LIST_rec.gsa_indicator||':');
	oe_debug_pub.add('last_updated_by              :'||l_MODIFIER_LIST_rec.last_updated_by||':'||p_MODIFIER_LIST_rec.last_updated_by||':');
	oe_debug_pub.add('last_update_date             :'||l_MODIFIER_LIST_rec.last_update_date||':'||p_MODIFIER_LIST_rec.last_update_date||':');
	oe_debug_pub.add('last_update_login            :'||l_MODIFIER_LIST_rec.last_update_login||':'||p_MODIFIER_LIST_rec.last_update_login||':');
	oe_debug_pub.add('list_header_id               :'||l_MODIFIER_LIST_rec.list_header_id||':'||p_MODIFIER_LIST_rec.list_header_id||':');
	oe_debug_pub.add('list_type_code               :'||l_MODIFIER_LIST_rec.list_type_code||':'||p_MODIFIER_LIST_rec.list_type_code||':');
	oe_debug_pub.add('program_application_id       :'||l_MODIFIER_LIST_rec.program_application_id||':'||p_MODIFIER_LIST_rec.program_application_id||':');
	oe_debug_pub.add('program_id                   :'||l_MODIFIER_LIST_rec.program_id||':'||p_MODIFIER_LIST_rec.program_id||':');
	oe_debug_pub.add('program_update_date          :'||l_MODIFIER_LIST_rec.program_update_date||':'||p_MODIFIER_LIST_rec.program_update_date||':');
	oe_debug_pub.add('prorate_flag                 :'||l_MODIFIER_LIST_rec.prorate_flag||':'||p_MODIFIER_LIST_rec.prorate_flag||':' );
	oe_debug_pub.add('request_id                   :'||l_MODIFIER_LIST_rec.request_id||':'||p_MODIFIER_LIST_rec.request_id||':');
	oe_debug_pub.add('rounding_factor              :'||l_MODIFIER_LIST_rec.rounding_factor||':'||p_MODIFIER_LIST_rec.rounding_factor||':');
	oe_debug_pub.add('ship_method_code             :'||l_MODIFIER_LIST_rec.ship_method_code||':'||p_MODIFIER_LIST_rec.ship_method_code||':');
	oe_debug_pub.add('start_date_active            :'||l_MODIFIER_LIST_rec.start_date_active||':'||p_MODIFIER_LIST_rec.start_date_active||':');
	oe_debug_pub.add('terms_id                     :'||l_MODIFIER_LIST_rec.terms_id||':'||p_MODIFIER_LIST_rec.terms_id||':');
	oe_debug_pub.add('source_system_code           :'||l_MODIFIER_LIST_rec.source_system_code||':'||p_MODIFIER_LIST_rec.source_system_code||':');
	oe_debug_pub.add('pte_code                     :'||l_MODIFIER_LIST_rec.pte_code||':'||p_MODIFIER_LIST_rec.pte_code||':');
	oe_debug_pub.add('active_flag                  :'||l_MODIFIER_LIST_rec.active_flag||':'||p_MODIFIER_LIST_rec.active_flag||':');
	oe_debug_pub.add('parent_list_header_id        :'||l_MODIFIER_LIST_rec.parent_list_header_id||':'||p_MODIFIER_LIST_rec.parent_list_header_id||':');
	oe_debug_pub.add('start_date_active_first      :'||l_MODIFIER_LIST_rec.start_date_active_first||':'||p_MODIFIER_LIST_rec.start_date_active_first||':');
	oe_debug_pub.add('end_date_active_first        :'||l_MODIFIER_LIST_rec.end_date_active_first||':'||p_MODIFIER_LIST_rec.end_date_active_first||':');
	oe_debug_pub.add('active_date_first_type       :'||l_MODIFIER_LIST_rec.active_date_first_type||':'||p_MODIFIER_LIST_rec.active_date_first_type||':');
	oe_debug_pub.add('start_date_active_second     :'||l_MODIFIER_LIST_rec.start_date_active_second||':'||p_MODIFIER_LIST_rec.start_date_active_second||':');
	oe_debug_pub.add('global_flag                  :'||l_MODIFIER_LIST_rec.global_flag||':'||p_MODIFIER_LIST_rec.global_flag||':');
	oe_debug_pub.add('end_date_active_second       :'||l_MODIFIER_LIST_rec.end_date_active_second||':'||p_MODIFIER_LIST_rec.end_date_active_second||':');
	oe_debug_pub.add('active_date_second_type      :'||l_MODIFIER_LIST_rec.active_date_second_type||':'||p_MODIFIER_LIST_rec.active_date_second_type||':');
	oe_debug_pub.add('ask_for_flag                 :'||l_MODIFIER_LIST_rec.ask_for_flag||':'||p_MODIFIER_LIST_rec.ask_for_flag||':');
	oe_debug_pub.add('list_source_code             :'||l_MODIFIER_LIST_rec.list_source_code||':'||p_MODIFIER_LIST_rec.list_source_code||':');
	oe_debug_pub.add('orig_system_header_ref       :'||l_MODIFIER_LIST_rec.orig_system_header_ref||':'||p_MODIFIER_LIST_rec.orig_system_header_ref||':');
	oe_debug_pub.add('shareable_flag               :'||l_MODIFIER_LIST_rec.shareable_flag||':'||p_MODIFIER_LIST_rec.shareable_flag||':');
	oe_debug_pub.ADD('-------------------data compare in modifier header end------------------');
	--end debug messages added as per 8594682 for oe_lock_row error
        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

	oe_debug_pub.add('END lock_row in QPXUMLHB');
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
) RETURN QP_Modifiers_PUB.Modifier_List_Val_Rec_Type
IS
l_MODIFIER_LIST_val_rec       QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
BEGIN

	oe_debug_pub.add('BEGIN get_values in QPXUMLHB');
    IF p_MODIFIER_LIST_rec.automatic_flag IS NOT NULL AND
        p_MODIFIER_LIST_rec.automatic_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.automatic_flag,
        p_old_MODIFIER_LIST_rec.automatic_flag)
    THEN
        l_MODIFIER_LIST_val_rec.automatic := QP_Id_To_Value.Automatic
        (   p_automatic_flag              => p_MODIFIER_LIST_rec.automatic_flag
        );
    END IF;

    IF p_MODIFIER_LIST_rec.currency_code IS NOT NULL AND
        p_MODIFIER_LIST_rec.currency_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.currency_code,
        p_old_MODIFIER_LIST_rec.currency_code)
    THEN
        l_MODIFIER_LIST_val_rec.currency := QP_Id_To_Value.Currency
        (   p_currency_code               => p_MODIFIER_LIST_rec.currency_code
        );
    END IF;

    IF p_MODIFIER_LIST_rec.discount_lines_flag IS NOT NULL AND
        p_MODIFIER_LIST_rec.discount_lines_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.discount_lines_flag,
        p_old_MODIFIER_LIST_rec.discount_lines_flag)
    THEN
        l_MODIFIER_LIST_val_rec.discount_lines := QP_Id_To_Value.Discount_Lines
        (   p_discount_lines_flag         => p_MODIFIER_LIST_rec.discount_lines_flag
        );
    END IF;

    IF p_MODIFIER_LIST_rec.freight_terms_code IS NOT NULL AND
        p_MODIFIER_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.freight_terms_code,
        p_old_MODIFIER_LIST_rec.freight_terms_code)
    THEN
        l_MODIFIER_LIST_val_rec.freight_terms := QP_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_MODIFIER_LIST_rec.freight_terms_code
        );
    END IF;

    IF p_MODIFIER_LIST_rec.list_header_id IS NOT NULL AND
        p_MODIFIER_LIST_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_header_id,
        p_old_MODIFIER_LIST_rec.list_header_id)
    THEN
        l_MODIFIER_LIST_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_MODIFIER_LIST_rec.list_header_id
        );
    END IF;

    IF p_MODIFIER_LIST_rec.list_type_code IS NOT NULL AND
        p_MODIFIER_LIST_rec.list_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.list_type_code,
        p_old_MODIFIER_LIST_rec.list_type_code)
    THEN
        l_MODIFIER_LIST_val_rec.list_type := QP_Id_To_Value.List_Type
        (   p_list_type_code              => p_MODIFIER_LIST_rec.list_type_code
        );
    END IF;

    IF p_MODIFIER_LIST_rec.prorate_flag IS NOT NULL AND
        p_MODIFIER_LIST_rec.prorate_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.prorate_flag,
        p_old_MODIFIER_LIST_rec.prorate_flag)
    THEN
        l_MODIFIER_LIST_val_rec.prorate := QP_Id_To_Value.Prorate
        (   p_prorate_flag                => p_MODIFIER_LIST_rec.prorate_flag
        );
    END IF;

    IF p_MODIFIER_LIST_rec.ship_method_code IS NOT NULL AND
        p_MODIFIER_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.ship_method_code,
        p_old_MODIFIER_LIST_rec.ship_method_code)
    THEN
        l_MODIFIER_LIST_val_rec.ship_method := QP_Id_To_Value.Ship_Method
        (   p_ship_method_code            => p_MODIFIER_LIST_rec.ship_method_code
        );
    END IF;

    IF p_MODIFIER_LIST_rec.terms_id IS NOT NULL AND
        p_MODIFIER_LIST_rec.terms_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIER_LIST_rec.terms_id,
        p_old_MODIFIER_LIST_rec.terms_id)
    THEN
        l_MODIFIER_LIST_val_rec.terms := QP_Id_To_Value.Terms
        (   p_terms_id                    => p_MODIFIER_LIST_rec.terms_id
        );
    END IF;

    RETURN l_MODIFIER_LIST_val_rec;

	oe_debug_pub.add('END get_values in QPXUMLHB');
END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_MODIFIER_LIST_val_rec         IN  QP_Modifiers_PUB.Modifier_List_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
BEGIN

	oe_debug_pub.add('BEGIN get_ids in QPXUMLHB');
    --  initialize  return_status.

    l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_MODIFIER_LIST_rec.

    l_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    IF  p_MODIFIER_LIST_val_rec.automatic <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.automatic_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.automatic_flag := p_MODIFIER_LIST_rec.automatic_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.automatic_flag := QP_Value_To_Id.automatic
            (   p_automatic                   => p_MODIFIER_LIST_val_rec.automatic
            );

            IF l_MODIFIER_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.currency <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.currency_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.currency_code := p_MODIFIER_LIST_rec.currency_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.currency_code := QP_Value_To_Id.currency
            (   p_currency                    => p_MODIFIER_LIST_val_rec.currency
            );

            IF l_MODIFIER_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.discount_lines <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.discount_lines_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.discount_lines_flag := p_MODIFIER_LIST_rec.discount_lines_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.discount_lines_flag := QP_Value_To_Id.discount_lines
            (   p_discount_lines              => p_MODIFIER_LIST_val_rec.discount_lines
            );

            IF l_MODIFIER_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.freight_terms_code := p_MODIFIER_LIST_rec.freight_terms_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.freight_terms_code := QP_Value_To_Id.freight_terms
            (   p_freight_terms               => p_MODIFIER_LIST_val_rec.freight_terms
            );

            IF l_MODIFIER_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIER_LIST_rec.list_header_id := p_MODIFIER_LIST_rec.list_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_MODIFIER_LIST_val_rec.list_header
            );

            IF l_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.list_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.list_type_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.list_type_code := p_MODIFIER_LIST_rec.list_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.list_type_code := QP_Value_To_Id.list_type
            (   p_list_type                   => p_MODIFIER_LIST_val_rec.list_type
            );

            IF l_MODIFIER_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.prorate <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.prorate_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.prorate_flag := p_MODIFIER_LIST_rec.prorate_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.prorate_flag := QP_Value_To_Id.prorate
            (   p_prorate                     => p_MODIFIER_LIST_val_rec.prorate
            );

            IF l_MODIFIER_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.ship_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.ship_method_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIER_LIST_rec.ship_method_code := p_MODIFIER_LIST_rec.ship_method_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.ship_method_code := QP_Value_To_Id.ship_method
            (   p_ship_method                 => p_MODIFIER_LIST_val_rec.ship_method
            );

            IF l_MODIFIER_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIER_LIST_val_rec.terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIER_LIST_rec.terms_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIER_LIST_rec.terms_id := p_MODIFIER_LIST_rec.terms_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIER_LIST_rec.terms_id := QP_Value_To_Id.terms
            (   p_terms                       => p_MODIFIER_LIST_val_rec.terms
            );

            IF l_MODIFIER_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN
                l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


	oe_debug_pub.add('END get_ids in QPXUMLHB');
    RETURN l_MODIFIER_LIST_rec;

END Get_Ids;

Function Get_Segment_Level_for_Group
  (p_list_header_id IN NUMBER
  ,p_list_line_id IN NUMBER
  ,p_qualifier_grouping_no IN NUMBER
  ) return varchar2
is
 cursor c_qualifiers is
   select qualifier_context, qualifier_attribute
     from qp_qualifiers
    where list_header_id = p_list_header_id
      and ((qualifier_grouping_no = p_qualifier_grouping_no) OR (qualifier_grouping_no = -1))
      and list_line_id = p_list_line_id;

 l_current_segment_level   VARCHAR2(30) := NULL;

 l_final_segment_level     VARCHAR2(30) := NULL;


BEGIN
  oe_debug_pub.add('Begin Get_Segment_Level_for_Group');
  oe_debug_pub.add('p_list_header_id = ' || p_list_header_id);
  oe_debug_pub.add('p_list_line_id = ' || p_list_line_id);
  oe_debug_pub.add('p_qualifier_grouping_no = ' || p_qualifier_grouping_no);
     FOR l_rec in c_qualifiers
     LOOP
        l_current_segment_level := qp_util.get_segment_level(p_list_header_id
                                                            ,l_rec.qualifier_context
                                                            ,l_rec.qualifier_attribute
                                                            );
        if l_final_segment_level is NULL then
           l_final_segment_level := l_current_segment_level;
        else
           if l_final_segment_level = 'LINE' then
              if l_current_segment_level = 'LINE' then
                 l_final_segment_level := 'LINE';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
                 -- Unexpected Condition
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

           elsif l_final_segment_level = 'ORDER' then
              if l_current_segment_level = 'ORDER' then
                 l_final_segment_level := 'ORDER';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'LINE' then
                 -- Unexpected Condition
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

           elsif l_final_segment_level = 'BOTH' then
              if l_current_segment_level = 'LINE' then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'BOTH';
              end if;

           elsif l_final_segment_level = 'LINE_BOTH' then
              if l_current_segment_level in ('LINE', 'BOTH') then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
                 -- Unexpected Condition
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

           elsif l_final_segment_level = 'ORDER_BOTH' then
              if l_current_segment_level in ('ORDER', 'BOTH') then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'LINE' then
                 -- Unexpected Condition
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

           end if; -- l_final_segment_level = 'LINE'
        end if; -- l_final_segment_level is NULL

     END LOOP;

  return(l_final_segment_level);

  oe_debug_pub.add('End Get_Segment_Level_for_Group');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    return(null);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	OE_MSG_PUB.Add_Exc_Msg
		(G_PKG_NAME
		,'Get_Segment_Level_for_Group');
     END IF;
     return(null);

  WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	OE_MSG_PUB.Add_Exc_Msg
		(G_PKG_NAME
		,'Get_Segment_Level_for_Group');
     END IF;
     return(null);

END Get_Segment_Level_for_Group;

END QP_Modifier_List_Util;

/

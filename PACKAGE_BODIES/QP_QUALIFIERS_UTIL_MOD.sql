--------------------------------------------------------
--  DDL for Package Body QP_QUALIFIERS_UTIL_MOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFIERS_UTIL_MOD" AS
/* $Header: QPXUQRSB.pls 120.0 2005/06/02 01:19:00 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Qualifiers_Util';

--  Procedure Clear_Dependent_Attr
/*
PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_QUALIFIERS_rec := p_QUALIFIERS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,p_old_QUALIFIERS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,p_old_QUALIFIERS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,p_old_QUALIFIERS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,p_old_QUALIFIERS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,p_old_QUALIFIERS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,p_old_QUALIFIERS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,p_old_QUALIFIERS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,p_old_QUALIFIERS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,p_old_QUALIFIERS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,p_old_QUALIFIERS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,p_old_QUALIFIERS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,p_old_QUALIFIERS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,p_old_QUALIFIERS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,p_old_QUALIFIERS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,p_old_QUALIFIERS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,p_old_QUALIFIERS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,p_old_QUALIFIERS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,p_old_QUALIFIERS_rec.created_from_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_FROM_RULE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,p_old_QUALIFIERS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,p_old_QUALIFIERS_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,p_old_QUALIFIERS_rec.excluder_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_EXCLUDER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,p_old_QUALIFIERS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,p_old_QUALIFIERS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,p_old_QUALIFIERS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,p_old_QUALIFIERS_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,p_old_QUALIFIERS_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,p_old_QUALIFIERS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,p_old_QUALIFIERS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,p_old_QUALIFIERS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,p_old_QUALIFIERS_rec.qualifier_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,p_old_QUALIFIERS_rec.qualifier_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,p_old_QUALIFIERS_rec.qualifier_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,p_old_QUALIFIERS_rec.qualifier_grouping_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_GROUPING_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,p_old_QUALIFIERS_rec.qualifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,p_old_QUALIFIERS_rec.qualifier_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_RULE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,p_old_QUALIFIERS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,p_old_QUALIFIERS_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_START_DATE_ACTIVE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_COMPARISON_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_COMPARISON_OPERATOR;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATED_FROM_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATED_FROM_RULE;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_EXCLUDER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_EXCLUDER;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_QUALIFIER_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTRIBUTE;
    ELSIF p_attr_id = G_QUALIFIER_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_ATTR_VALUE;
    ELSIF p_attr_id = G_QUALIFIER_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_CONTEXT;
    ELSIF p_attr_id = G_QUALIFIER_GROUPING_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_GROUPING_NO;
    ELSIF p_attr_id = G_QUALIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER;
    ELSIF p_attr_id = G_QUALIFIER_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_QUALIFIER_RULE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIERS_UTIL.G_START_DATE_ACTIVE;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_QUALIFIERS_rec := p_QUALIFIERS_rec;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,p_old_QUALIFIERS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,p_old_QUALIFIERS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,p_old_QUALIFIERS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,p_old_QUALIFIERS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,p_old_QUALIFIERS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,p_old_QUALIFIERS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,p_old_QUALIFIERS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,p_old_QUALIFIERS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,p_old_QUALIFIERS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,p_old_QUALIFIERS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,p_old_QUALIFIERS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,p_old_QUALIFIERS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,p_old_QUALIFIERS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,p_old_QUALIFIERS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,p_old_QUALIFIERS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,p_old_QUALIFIERS_rec.comparison_operator_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,p_old_QUALIFIERS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,p_old_QUALIFIERS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,p_old_QUALIFIERS_rec.created_from_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,p_old_QUALIFIERS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,p_old_QUALIFIERS_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,p_old_QUALIFIERS_rec.excluder_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,p_old_QUALIFIERS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,p_old_QUALIFIERS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,p_old_QUALIFIERS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,p_old_QUALIFIERS_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,p_old_QUALIFIERS_rec.list_line_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,p_old_QUALIFIERS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,p_old_QUALIFIERS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,p_old_QUALIFIERS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,p_old_QUALIFIERS_rec.qualifier_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,p_old_QUALIFIERS_rec.qualifier_attr_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,p_old_QUALIFIERS_rec.qualifier_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,p_old_QUALIFIERS_rec.qualifier_grouping_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,p_old_QUALIFIERS_rec.qualifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,p_old_QUALIFIERS_rec.qualifier_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,p_old_QUALIFIERS_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,p_old_QUALIFIERS_rec.start_date_active)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Modifiers_PUB.Qualifiers_Rec_Type := p_QUALIFIERS_rec;
BEGIN

    IF l_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute1 := p_old_QUALIFIERS_rec.attribute1;
    END IF;

    IF l_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute10 := p_old_QUALIFIERS_rec.attribute10;
    END IF;

    IF l_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute11 := p_old_QUALIFIERS_rec.attribute11;
    END IF;

    IF l_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute12 := p_old_QUALIFIERS_rec.attribute12;
    END IF;

    IF l_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute13 := p_old_QUALIFIERS_rec.attribute13;
    END IF;

    IF l_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute14 := p_old_QUALIFIERS_rec.attribute14;
    END IF;

    IF l_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute15 := p_old_QUALIFIERS_rec.attribute15;
    END IF;

    IF l_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute2 := p_old_QUALIFIERS_rec.attribute2;
    END IF;

    IF l_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute3 := p_old_QUALIFIERS_rec.attribute3;
    END IF;

    IF l_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute4 := p_old_QUALIFIERS_rec.attribute4;
    END IF;

    IF l_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute5 := p_old_QUALIFIERS_rec.attribute5;
    END IF;

    IF l_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute6 := p_old_QUALIFIERS_rec.attribute6;
    END IF;

    IF l_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute7 := p_old_QUALIFIERS_rec.attribute7;
    END IF;

    IF l_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute8 := p_old_QUALIFIERS_rec.attribute8;
    END IF;

    IF l_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute9 := p_old_QUALIFIERS_rec.attribute9;
    END IF;

    IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.comparison_operator_code := p_old_QUALIFIERS_rec.comparison_operator_code;
    END IF;

    IF l_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.context := p_old_QUALIFIERS_rec.context;
    END IF;

    IF l_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_by := p_old_QUALIFIERS_rec.created_by;
    END IF;

    IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_from_rule_id := p_old_QUALIFIERS_rec.created_from_rule_id;
    END IF;

    IF l_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.creation_date := p_old_QUALIFIERS_rec.creation_date;
    END IF;

    IF l_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.end_date_active := p_old_QUALIFIERS_rec.end_date_active;
    END IF;

    IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.excluder_flag := p_old_QUALIFIERS_rec.excluder_flag;
    END IF;

    IF l_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_updated_by := p_old_QUALIFIERS_rec.last_updated_by;
    END IF;

    IF l_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.last_update_date := p_old_QUALIFIERS_rec.last_update_date;
    END IF;

    IF l_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_update_login := p_old_QUALIFIERS_rec.last_update_login;
    END IF;

    IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_header_id := p_old_QUALIFIERS_rec.list_header_id;
    END IF;

    IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_line_id := p_old_QUALIFIERS_rec.list_line_id;
    END IF;

    IF l_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_application_id := p_old_QUALIFIERS_rec.program_application_id;
    END IF;

    IF l_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_id := p_old_QUALIFIERS_rec.program_id;
    END IF;

    IF l_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.program_update_date := p_old_QUALIFIERS_rec.program_update_date;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attribute := p_old_QUALIFIERS_rec.qualifier_attribute;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value := p_old_QUALIFIERS_rec.qualifier_attr_value;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_context := p_old_QUALIFIERS_rec.qualifier_context;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_grouping_no := p_old_QUALIFIERS_rec.qualifier_grouping_no;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_id := p_old_QUALIFIERS_rec.qualifier_id;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_rule_id := p_old_QUALIFIERS_rec.qualifier_rule_id;
    END IF;

    IF l_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.request_id := p_old_QUALIFIERS_rec.request_id;
    END IF;

    IF l_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.start_date_active := p_old_QUALIFIERS_rec.start_date_active;
    END IF;

    RETURN l_QUALIFIERS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Modifiers_PUB.Qualifiers_Rec_Type := p_QUALIFIERS_rec;
BEGIN

    IF l_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute1 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute10 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute11 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute12 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute13 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute14 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute15 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute2 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute3 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute4 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute5 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute6 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute7 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute8 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.attribute9 := NULL;
    END IF;

    IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.comparison_operator_code := NULL;
    END IF;

    IF l_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.context := NULL;
    END IF;

    IF l_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_by := NULL;
    END IF;

    IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.created_from_rule_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.creation_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.end_date_active := NULL;
    END IF;

    IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.excluder_flag := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_updated_by := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.last_update_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.last_update_login := NULL;
    END IF;

    IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_header_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.list_line_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_application_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.program_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.program_update_date := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attribute := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_attr_value := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIERS_rec.qualifier_context := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_grouping_no := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.qualifier_rule_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIERS_rec.request_id := NULL;
    END IF;

    IF l_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_QUALIFIERS_rec.start_date_active := NULL;
    END IF;

    RETURN l_QUALIFIERS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
--l_status VARCHAR2(1);
--l_qualifiers_rec QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN
    SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  LIST_HEADER_ID = p_QUALIFIERS_rec.list_header_id;

    --l_qualifiers_rec:=Query_Row(p_QUALIFIERS_rec.qualifier_id);

    UPDATE  QP_QUALIFIERS
    SET     ATTRIBUTE1                     = p_QUALIFIERS_rec.attribute1
    ,       ATTRIBUTE10                    = p_QUALIFIERS_rec.attribute10
    ,       ATTRIBUTE11                    = p_QUALIFIERS_rec.attribute11
    ,       ATTRIBUTE12                    = p_QUALIFIERS_rec.attribute12
    ,       ATTRIBUTE13                    = p_QUALIFIERS_rec.attribute13
    ,       ATTRIBUTE14                    = p_QUALIFIERS_rec.attribute14
    ,       ATTRIBUTE15                    = p_QUALIFIERS_rec.attribute15
    ,       ATTRIBUTE2                     = p_QUALIFIERS_rec.attribute2
    ,       ATTRIBUTE3                     = p_QUALIFIERS_rec.attribute3
    ,       ATTRIBUTE4                     = p_QUALIFIERS_rec.attribute4
    ,       ATTRIBUTE5                     = p_QUALIFIERS_rec.attribute5
    ,       ATTRIBUTE6                     = p_QUALIFIERS_rec.attribute6
    ,       ATTRIBUTE7                     = p_QUALIFIERS_rec.attribute7
    ,       ATTRIBUTE8                     = p_QUALIFIERS_rec.attribute8
    ,       ATTRIBUTE9                     = p_QUALIFIERS_rec.attribute9
    ,       COMPARISON_OPERATOR_CODE       = p_QUALIFIERS_rec.comparison_operator_code
    ,       CONTEXT                        = p_QUALIFIERS_rec.context
    ,       CREATED_BY                     = p_QUALIFIERS_rec.created_by
    ,       CREATED_FROM_RULE_ID           = p_QUALIFIERS_rec.created_from_rule_id
    ,       CREATION_DATE                  = p_QUALIFIERS_rec.creation_date
    ,       END_DATE_ACTIVE                = p_QUALIFIERS_rec.end_date_active
    ,       EXCLUDER_FLAG                  = p_QUALIFIERS_rec.excluder_flag
    ,       LAST_UPDATED_BY                = p_QUALIFIERS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_QUALIFIERS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_QUALIFIERS_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_QUALIFIERS_rec.list_header_id
    ,       LIST_LINE_ID                   = p_QUALIFIERS_rec.list_line_id
    ,       PROGRAM_APPLICATION_ID         = p_QUALIFIERS_rec.program_application_id
    ,       PROGRAM_ID                     = p_QUALIFIERS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_QUALIFIERS_rec.program_update_date
    ,       QUALIFIER_ATTRIBUTE            = p_QUALIFIERS_rec.qualifier_attribute
    ,       QUALIFIER_ATTR_VALUE           = p_QUALIFIERS_rec.qualifier_attr_value
    ,       QUALIFIER_CONTEXT              = p_QUALIFIERS_rec.qualifier_context
    ,       QUALIFIER_GROUPING_NO          = p_QUALIFIERS_rec.qualifier_grouping_no
    ,       QUALIFIER_ID                   = p_QUALIFIERS_rec.qualifier_id
    ,       QUALIFIER_RULE_ID              = p_QUALIFIERS_rec.qualifier_rule_id
    ,       REQUEST_ID                     = p_QUALIFIERS_rec.request_id
    ,       START_DATE_ACTIVE              = p_QUALIFIERS_rec.start_date_active
    WHERE   QUALIFIER_ID = p_QUALIFIERS_rec.qualifier_id
    ;

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');

IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN

 IF(p_QUALIFIERS_rec.qualifier_context IS NOT NULL) AND
  (p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL) THEN

  UPDATE qp_pte_segments SET used_in_setup='Y'
  WHERE  nvl(used_in_setup,'N')='N'
  AND segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_QUALIFIERS_rec.qualifier_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=p_QUALIFIERS_rec.qualifier_context);
 END IF;
END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
BEGIN
SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  LIST_HEADER_ID = p_QUALIFIERS_rec.list_header_id;

    INSERT  INTO QP_QUALIFIERS
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    )
    VALUES
    (       p_QUALIFIERS_rec.attribute1
    ,       p_QUALIFIERS_rec.attribute10
    ,       p_QUALIFIERS_rec.attribute11
    ,       p_QUALIFIERS_rec.attribute12
    ,       p_QUALIFIERS_rec.attribute13
    ,       p_QUALIFIERS_rec.attribute14
    ,       p_QUALIFIERS_rec.attribute15
    ,       p_QUALIFIERS_rec.attribute2
    ,       p_QUALIFIERS_rec.attribute3
    ,       p_QUALIFIERS_rec.attribute4
    ,       p_QUALIFIERS_rec.attribute5
    ,       p_QUALIFIERS_rec.attribute6
    ,       p_QUALIFIERS_rec.attribute7
    ,       p_QUALIFIERS_rec.attribute8
    ,       p_QUALIFIERS_rec.attribute9
    ,       p_QUALIFIERS_rec.comparison_operator_code
    ,       p_QUALIFIERS_rec.context
    ,       p_QUALIFIERS_rec.created_by
    ,       p_QUALIFIERS_rec.created_from_rule_id
    ,       p_QUALIFIERS_rec.creation_date
    ,       p_QUALIFIERS_rec.end_date_active
    ,       p_QUALIFIERS_rec.excluder_flag
    ,       p_QUALIFIERS_rec.last_updated_by
    ,       p_QUALIFIERS_rec.last_update_date
    ,       p_QUALIFIERS_rec.last_update_login
    ,       p_QUALIFIERS_rec.list_header_id
    ,       p_QUALIFIERS_rec.list_line_id
    ,       p_QUALIFIERS_rec.program_application_id
    ,       p_QUALIFIERS_rec.program_id
    ,       p_QUALIFIERS_rec.program_update_date
    ,       p_QUALIFIERS_rec.qualifier_attribute
    ,       p_QUALIFIERS_rec.qualifier_attr_value
    ,       p_QUALIFIERS_rec.qualifier_context
    ,       p_QUALIFIERS_rec.qualifier_grouping_no
    ,       p_QUALIFIERS_rec.qualifier_id
    ,       p_QUALIFIERS_rec.qualifier_rule_id
    ,       p_QUALIFIERS_rec.request_id
    ,       p_QUALIFIERS_rec.start_date_active
    );

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
IF(p_QUALIFIERS_rec.qualifier_context IS NOT NULL) AND
  (p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL) THEN

  UPDATE qp_pte_segments SET used_in_setup='Y'
  WHERE  nvl(used_in_setup,'N')='N'
  AND segment_id IN
  (SELECT a.segment_id
   FROM   qp_segments_b a,qp_prc_contexts_b b
   WHERE a.segment_mapping_column=p_QUALIFIERS_rec.qualifier_attribute
   AND   a.prc_context_id=b.prc_context_id
   AND   b.prc_context_type='QUALIFIER'
   AND   b.prc_context_code=p_QUALIFIERS_rec.qualifier_context);
END IF;
END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_qualifier_id                  IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_QUALIFIERS
    WHERE   QUALIFIER_ID = p_qualifier_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_qualifier_id                  IN  NUMBER
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_qualifier_id                => p_qualifier_id
        )(1);

END Query_Row;

--  Function Query_Rows

--
*/
FUNCTION Query_Rows
(   p_qualifier_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
IS
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

CURSOR l_QUALIFIERS_csr IS
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_ATTR_VALUE_TO
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       LIST_TYPE_CODE
    ,       QUAL_ATTR_VALUE_FROM_NUMBER
    ,       QUAL_ATTR_VALUE_TO_NUMBER
    ,       ACTIVE_FLAG
    ,       QUALIFIER_PRECEDENCE
    ,       QUALIFIER_DATATYPE
    ,	  SEARCH_IND
    ,	  QUALIFIER_GROUP_CNT
    ,	  HEADER_QUALS_EXIST_FLAG
    ,	  DISTINCT_ROW_COUNT
    FROM    QP_QUALIFIERS
    WHERE ( QUALIFIER_ID = p_qualifier_id
    )
    OR (    LIST_HEADER_ID = p_list_header_id
    );

BEGIN

    IF
    (p_qualifier_id IS NOT NULL
     AND
     p_qualifier_id <> FND_API.G_MISS_NUM)
    AND
    (p_list_header_id IS NOT NULL
     AND
     p_list_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: qualifier_id = '|| p_qualifier_id || ', list_header_id = '|| p_list_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_QUALIFIERS_csr LOOP

        l_QUALIFIERS_rec.attribute1    := l_implicit_rec.ATTRIBUTE1;
        l_QUALIFIERS_rec.attribute10   := l_implicit_rec.ATTRIBUTE10;
        l_QUALIFIERS_rec.attribute11   := l_implicit_rec.ATTRIBUTE11;
        l_QUALIFIERS_rec.attribute12   := l_implicit_rec.ATTRIBUTE12;
        l_QUALIFIERS_rec.attribute13   := l_implicit_rec.ATTRIBUTE13;
        l_QUALIFIERS_rec.attribute14   := l_implicit_rec.ATTRIBUTE14;
        l_QUALIFIERS_rec.attribute15   := l_implicit_rec.ATTRIBUTE15;
        l_QUALIFIERS_rec.attribute2    := l_implicit_rec.ATTRIBUTE2;
        l_QUALIFIERS_rec.attribute3    := l_implicit_rec.ATTRIBUTE3;
        l_QUALIFIERS_rec.attribute4    := l_implicit_rec.ATTRIBUTE4;
        l_QUALIFIERS_rec.attribute5    := l_implicit_rec.ATTRIBUTE5;
        l_QUALIFIERS_rec.attribute6    := l_implicit_rec.ATTRIBUTE6;
        l_QUALIFIERS_rec.attribute7    := l_implicit_rec.ATTRIBUTE7;
        l_QUALIFIERS_rec.attribute8    := l_implicit_rec.ATTRIBUTE8;
        l_QUALIFIERS_rec.attribute9    := l_implicit_rec.ATTRIBUTE9;
        l_QUALIFIERS_rec.comparison_operator_code := l_implicit_rec.COMPARISON_OPERATOR_CODE;
        l_QUALIFIERS_rec.context       := l_implicit_rec.CONTEXT;
        l_QUALIFIERS_rec.created_by    := l_implicit_rec.CREATED_BY;
        l_QUALIFIERS_rec.created_from_rule_id := l_implicit_rec.CREATED_FROM_RULE_ID;
        l_QUALIFIERS_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_QUALIFIERS_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_QUALIFIERS_rec.excluder_flag := l_implicit_rec.EXCLUDER_FLAG;
        l_QUALIFIERS_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_QUALIFIERS_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_QUALIFIERS_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_QUALIFIERS_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_QUALIFIERS_rec.list_line_id  := l_implicit_rec.LIST_LINE_ID;
        l_QUALIFIERS_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_QUALIFIERS_rec.program_id    := l_implicit_rec.PROGRAM_ID;
        l_QUALIFIERS_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_QUALIFIERS_rec.qualifier_attribute := l_implicit_rec.QUALIFIER_ATTRIBUTE;
        l_QUALIFIERS_rec.qualifier_attr_value := l_implicit_rec.QUALIFIER_ATTR_VALUE;
        l_QUALIFIERS_rec.qualifier_attr_value_to := l_implicit_rec.QUALIFIER_ATTR_VALUE_TO;

        l_QUALIFIERS_rec.qualifier_context := l_implicit_rec.QUALIFIER_CONTEXT;
        l_QUALIFIERS_rec.qualifier_grouping_no := l_implicit_rec.QUALIFIER_GROUPING_NO;
        l_QUALIFIERS_rec.qualifier_id  := l_implicit_rec.QUALIFIER_ID;
        l_QUALIFIERS_rec.qualifier_rule_id := l_implicit_rec.QUALIFIER_RULE_ID;
        l_QUALIFIERS_rec.request_id    := l_implicit_rec.REQUEST_ID;
        l_QUALIFIERS_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_QUALIFIERS_rec.list_type_code := l_implicit_rec.LIST_TYPE_CODE;
	   l_QUALIFIERS_rec.qual_attr_value_from_number := l_implicit_rec.QUAL_ATTR_VALUE_FROM_NUMBER;
	   l_QUALIFIERS_rec.qual_attr_value_to_number := l_implicit_rec.QUAL_ATTR_VALUE_TO_NUMBER;
	   l_QUALIFIERS_rec.active_flag := l_implicit_rec.ACTIVE_FLAG;
	   l_QUALIFIERS_rec.qualifier_datatype := l_implicit_rec.QUALIFIER_DATATYPE;
	   l_QUALIFIERS_rec.qualifier_precedence := l_implicit_rec.QUALIFIER_PRECEDENCE;

	   l_QUALIFIERS_rec.search_ind := l_implicit_rec.SEARCH_IND;
	   l_QUALIFIERS_rec.qualifier_group_cnt := l_implicit_rec.QUALIFIER_GROUP_CNT;
	   l_QUALIFIERS_rec.header_quals_exist_flag := l_implicit_rec.HEADER_QUALS_EXIST_FLAG;
	   l_QUALIFIERS_rec.distinct_row_count := l_implicit_rec.DISTINCT_ROW_COUNT;

        l_QUALIFIERS_tbl(l_QUALIFIERS_tbl.COUNT + 1) := l_QUALIFIERS_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_qualifier_id IS NOT NULL
     AND
     p_qualifier_id <> FND_API.G_MISS_NUM)
    AND
    (l_QUALIFIERS_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_QUALIFIERS_tbl;

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

END Query_Rows;

--  Procedure       lock_Row
--
/*
PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
)
IS
l_QUALIFIERS_rec              QP_Modifiers_PUB.Qualifiers_Rec_Type;
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
    ,       COMPARISON_OPERATOR_CODE
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATED_FROM_RULE_ID
    ,       CREATION_DATE
    ,       END_DATE_ACTIVE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_ATTRIBUTE
    ,       QUALIFIER_ATTR_VALUE
    ,       QUALIFIER_CONTEXT
    ,       QUALIFIER_GROUPING_NO
    ,       QUALIFIER_ID
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    INTO    l_QUALIFIERS_rec.attribute1
    ,       l_QUALIFIERS_rec.attribute10
    ,       l_QUALIFIERS_rec.attribute11
    ,       l_QUALIFIERS_rec.attribute12
    ,       l_QUALIFIERS_rec.attribute13
    ,       l_QUALIFIERS_rec.attribute14
    ,       l_QUALIFIERS_rec.attribute15
    ,       l_QUALIFIERS_rec.attribute2
    ,       l_QUALIFIERS_rec.attribute3
    ,       l_QUALIFIERS_rec.attribute4
    ,       l_QUALIFIERS_rec.attribute5
    ,       l_QUALIFIERS_rec.attribute6
    ,       l_QUALIFIERS_rec.attribute7
    ,       l_QUALIFIERS_rec.attribute8
    ,       l_QUALIFIERS_rec.attribute9
    ,       l_QUALIFIERS_rec.comparison_operator_code
    ,       l_QUALIFIERS_rec.context
    ,       l_QUALIFIERS_rec.created_by
    ,       l_QUALIFIERS_rec.created_from_rule_id
    ,       l_QUALIFIERS_rec.creation_date
    ,       l_QUALIFIERS_rec.end_date_active
    ,       l_QUALIFIERS_rec.excluder_flag
    ,       l_QUALIFIERS_rec.last_updated_by
    ,       l_QUALIFIERS_rec.last_update_date
    ,       l_QUALIFIERS_rec.last_update_login
    ,       l_QUALIFIERS_rec.list_header_id
    ,       l_QUALIFIERS_rec.list_line_id
    ,       l_QUALIFIERS_rec.program_application_id
    ,       l_QUALIFIERS_rec.program_id
    ,       l_QUALIFIERS_rec.program_update_date
    ,       l_QUALIFIERS_rec.qualifier_attribute
    ,       l_QUALIFIERS_rec.qualifier_attr_value
    ,       l_QUALIFIERS_rec.qualifier_context
    ,       l_QUALIFIERS_rec.qualifier_grouping_no
    ,       l_QUALIFIERS_rec.qualifier_id
    ,       l_QUALIFIERS_rec.qualifier_rule_id
    ,       l_QUALIFIERS_rec.request_id
    ,       l_QUALIFIERS_rec.start_date_active
    FROM    QP_QUALIFIERS
    WHERE   QUALIFIER_ID = p_QUALIFIERS_rec.qualifier_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute1,
                         l_QUALIFIERS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute10,
                         l_QUALIFIERS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute11,
                         l_QUALIFIERS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute12,
                         l_QUALIFIERS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute13,
                         l_QUALIFIERS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute14,
                         l_QUALIFIERS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute15,
                         l_QUALIFIERS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute2,
                         l_QUALIFIERS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute3,
                         l_QUALIFIERS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute4,
                         l_QUALIFIERS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute5,
                         l_QUALIFIERS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute6,
                         l_QUALIFIERS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute7,
                         l_QUALIFIERS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute8,
                         l_QUALIFIERS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.attribute9,
                         l_QUALIFIERS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,
                         l_QUALIFIERS_rec.comparison_operator_code)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.context,
                         l_QUALIFIERS_rec.context)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_by,
                         l_QUALIFIERS_rec.created_by)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,
                         l_QUALIFIERS_rec.created_from_rule_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.creation_date,
                         l_QUALIFIERS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.end_date_active,
                         l_QUALIFIERS_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,
                         l_QUALIFIERS_rec.excluder_flag)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_updated_by,
                         l_QUALIFIERS_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_date,
                         l_QUALIFIERS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.last_update_login,
                         l_QUALIFIERS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,
                         l_QUALIFIERS_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,
                         l_QUALIFIERS_rec.list_line_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_application_id,
                         l_QUALIFIERS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_id,
                         l_QUALIFIERS_rec.program_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.program_update_date,
                         l_QUALIFIERS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attribute,
                         l_QUALIFIERS_rec.qualifier_attribute)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_attr_value,
                         l_QUALIFIERS_rec.qualifier_attr_value)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_context,
                         l_QUALIFIERS_rec.qualifier_context)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_grouping_no,
                         l_QUALIFIERS_rec.qualifier_grouping_no)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,
                         l_QUALIFIERS_rec.qualifier_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,
                         l_QUALIFIERS_rec.qualifier_rule_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.request_id,
                         l_QUALIFIERS_rec.request_id)
    AND QP_GLOBALS.Equal(p_QUALIFIERS_rec.start_date_active,
                         l_QUALIFIERS_rec.start_date_active)
    THEN

        --  Row has not changed. Set out parameter.

        x_QUALIFIERS_rec               := l_QUALIFIERS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
) RETURN QP_Modifiers_PUB.Qualifiers_Val_Rec_Type
IS
l_QUALIFIERS_val_rec          QP_Modifiers_PUB.Qualifiers_Val_Rec_Type;
BEGIN

    IF p_QUALIFIERS_rec.comparison_operator_code IS NOT NULL AND
        p_QUALIFIERS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.comparison_operator_code,
        p_old_QUALIFIERS_rec.comparison_operator_code)
    THEN
--        l_QUALIFIERS_val_rec.comparison_operator := QP_Id_To_Value.Comparison_Operator
--        (   p_comparison_operator_code    => p_QUALIFIERS_rec.comparison_operator_code
--        );
    END IF;

    IF p_QUALIFIERS_rec.created_from_rule_id IS NOT NULL AND
        p_QUALIFIERS_rec.created_from_rule_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.created_from_rule_id,
        p_old_QUALIFIERS_rec.created_from_rule_id)
    THEN
        l_QUALIFIERS_val_rec.created_from_rule := QP_Id_To_Value.Created_From_Rule
        (   p_created_from_rule_id        => p_QUALIFIERS_rec.created_from_rule_id
        );
    END IF;

    IF p_QUALIFIERS_rec.excluder_flag IS NOT NULL AND
        p_QUALIFIERS_rec.excluder_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.excluder_flag,
        p_old_QUALIFIERS_rec.excluder_flag)
    THEN
        l_QUALIFIERS_val_rec.excluder := QP_Id_To_Value.Excluder
        (   p_excluder_flag               => p_QUALIFIERS_rec.excluder_flag
        );
    END IF;

    IF p_QUALIFIERS_rec.list_header_id IS NOT NULL AND
        p_QUALIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_header_id,
        p_old_QUALIFIERS_rec.list_header_id)
    THEN
        l_QUALIFIERS_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_QUALIFIERS_rec.list_header_id
        );
    END IF;

    IF p_QUALIFIERS_rec.list_line_id IS NOT NULL AND
        p_QUALIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.list_line_id,
        p_old_QUALIFIERS_rec.list_line_id)
    THEN
        l_QUALIFIERS_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_QUALIFIERS_rec.list_line_id
        );
    END IF;

    IF p_QUALIFIERS_rec.qualifier_id IS NOT NULL AND
        p_QUALIFIERS_rec.qualifier_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_id,
        p_old_QUALIFIERS_rec.qualifier_id)
    THEN
--        l_QUALIFIERS_val_rec.qualifier := QP_Id_To_Value.Qualifier
--        (   p_qualifier_id                => p_QUALIFIERS_rec.qualifier_id
--        );
    END IF;

    IF p_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL AND
        p_QUALIFIERS_rec.qualifier_rule_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIERS_rec.qualifier_rule_id,
        p_old_QUALIFIERS_rec.qualifier_rule_id)
    THEN
        l_QUALIFIERS_val_rec.qualifier_rule := QP_Id_To_Value.Qualifier_Rule
        (   p_qualifier_rule_id           => p_QUALIFIERS_rec.qualifier_rule_id
        );
    END IF;

    RETURN l_QUALIFIERS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_QUALIFIERS_val_rec            IN  QP_Modifiers_PUB.Qualifiers_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type
IS
l_QUALIFIERS_rec              QP_Modifiers_PUB.Qualifiers_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_QUALIFIERS_rec.

    l_QUALIFIERS_rec := p_QUALIFIERS_rec;

    IF  p_QUALIFIERS_val_rec.comparison_operator <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.comparison_operator_code := p_QUALIFIERS_rec.comparison_operator_code;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

--            l_QUALIFIERS_rec.comparison_operator_code := QP_Value_To_Id.comparison_operator
--            (   p_comparison_operator         => p_QUALIFIERS_val_rec.comparison_operator
--            );

            IF l_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.created_from_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.created_from_rule_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.created_from_rule_id := p_QUALIFIERS_rec.created_from_rule_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_from_rule');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.created_from_rule_id := QP_Value_To_Id.created_from_rule
            (   p_created_from_rule           => p_QUALIFIERS_val_rec.created_from_rule
            );

            IF l_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.excluder <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.excluder_flag <> FND_API.G_MISS_CHAR THEN

            l_QUALIFIERS_rec.excluder_flag := p_QUALIFIERS_rec.excluder_flag;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.excluder_flag := QP_Value_To_Id.excluder
            (   p_excluder                    => p_QUALIFIERS_val_rec.excluder
            );

            IF l_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.list_header_id := p_QUALIFIERS_rec.list_header_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_QUALIFIERS_val_rec.list_header
            );

            IF l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.list_line_id := p_QUALIFIERS_rec.list_line_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_QUALIFIERS_val_rec.list_line
            );

            IF l_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.qualifier <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.qualifier_id := p_QUALIFIERS_rec.qualifier_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

--            l_QUALIFIERS_rec.qualifier_id := QP_Value_To_Id.qualifier
--            (   p_qualifier                   => p_QUALIFIERS_val_rec.qualifier
--            );

            IF l_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_QUALIFIERS_val_rec.qualifier_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIERS_rec.qualifier_rule_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIERS_rec.qualifier_rule_id := p_QUALIFIERS_rec.qualifier_rule_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIERS_rec.qualifier_rule_id := QP_Value_To_Id.qualifier_rule
            (   p_qualifier_rule              => p_QUALIFIERS_val_rec.qualifier_rule
            );

            IF l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_QUALIFIERS_rec;

END Get_Ids;
*/
END QP_Qualifiers_Util_Mod;

/

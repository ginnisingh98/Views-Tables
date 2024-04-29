--------------------------------------------------------
--  DDL for Package Body QP_LIMIT_ATTRS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMIT_ATTRS_UTIL" AS
/* $Header: QPXULATB.pls 120.1 2005/06/10 00:16:20 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Limit_Attrs_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_LIMIT_ATTRS_rec := p_LIMIT_ATTRS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute1,p_old_LIMIT_ATTRS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute10,p_old_LIMIT_ATTRS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute11,p_old_LIMIT_ATTRS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute12,p_old_LIMIT_ATTRS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute13,p_old_LIMIT_ATTRS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute14,p_old_LIMIT_ATTRS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute15,p_old_LIMIT_ATTRS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute2,p_old_LIMIT_ATTRS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute3,p_old_LIMIT_ATTRS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute4,p_old_LIMIT_ATTRS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute5,p_old_LIMIT_ATTRS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute6,p_old_LIMIT_ATTRS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute7,p_old_LIMIT_ATTRS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute8,p_old_LIMIT_ATTRS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute9,p_old_LIMIT_ATTRS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.comparison_operator_code,p_old_LIMIT_ATTRS_rec.comparison_operator_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_COMPARISON_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.context,p_old_LIMIT_ATTRS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.created_by,p_old_LIMIT_ATTRS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.creation_date,p_old_LIMIT_ATTRS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_updated_by,p_old_LIMIT_ATTRS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_date,p_old_LIMIT_ATTRS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_login,p_old_LIMIT_ATTRS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute,p_old_LIMIT_ATTRS_rec.limit_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_context,p_old_LIMIT_ATTRS_rec.limit_attribute_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_id,p_old_LIMIT_ATTRS_rec.limit_attribute_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_type,p_old_LIMIT_ATTRS_rec.limit_attribute_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_datatype,p_old_LIMIT_ATTRS_rec.limit_attr_datatype)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTR_DATATYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_value,p_old_LIMIT_ATTRS_rec.limit_attr_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTR_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_id,p_old_LIMIT_ATTRS_rec.limit_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_application_id,p_old_LIMIT_ATTRS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_id,p_old_LIMIT_ATTRS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_update_date,p_old_LIMIT_ATTRS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.request_id,p_old_LIMIT_ATTRS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_REQUEST;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_COMPARISON_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_COMPARISON_OPERATOR;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIMIT_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE;
    ELSIF p_attr_id = G_LIMIT_ATTRIBUTE_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE_CONTEXT;
    /*ELSIF p_attr_id = G_LIMIT_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE;
    */
    ELSIF p_attr_id = G_LIMIT_ATTRIBUTE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTRIBUTE_TYPE;
    ELSIF p_attr_id = G_LIMIT_ATTR_DATATYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTR_DATATYPE;
    ELSIF p_attr_id = G_LIMIT_ATTR_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT_ATTR_VALUE;
    ELSIF p_attr_id = G_LIMIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_LIMIT;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_LIMIT_ATTRS_UTIL.G_REQUEST;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_LIMIT_ATTRS_rec := p_LIMIT_ATTRS_rec;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute1,p_old_LIMIT_ATTRS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute10,p_old_LIMIT_ATTRS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute11,p_old_LIMIT_ATTRS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute12,p_old_LIMIT_ATTRS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute13,p_old_LIMIT_ATTRS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute14,p_old_LIMIT_ATTRS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute15,p_old_LIMIT_ATTRS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute2,p_old_LIMIT_ATTRS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute3,p_old_LIMIT_ATTRS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute4,p_old_LIMIT_ATTRS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute5,p_old_LIMIT_ATTRS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute6,p_old_LIMIT_ATTRS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute7,p_old_LIMIT_ATTRS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute8,p_old_LIMIT_ATTRS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute9,p_old_LIMIT_ATTRS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.comparison_operator_code,p_old_LIMIT_ATTRS_rec.comparison_operator_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.context,p_old_LIMIT_ATTRS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.created_by,p_old_LIMIT_ATTRS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.creation_date,p_old_LIMIT_ATTRS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_updated_by,p_old_LIMIT_ATTRS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_date,p_old_LIMIT_ATTRS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_login,p_old_LIMIT_ATTRS_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute,p_old_LIMIT_ATTRS_rec.limit_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_context,p_old_LIMIT_ATTRS_rec.limit_attribute_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_id,p_old_LIMIT_ATTRS_rec.limit_attribute_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_type,p_old_LIMIT_ATTRS_rec.limit_attribute_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_datatype,p_old_LIMIT_ATTRS_rec.limit_attr_datatype)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_value,p_old_LIMIT_ATTRS_rec.limit_attr_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_id,p_old_LIMIT_ATTRS_rec.limit_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_application_id,p_old_LIMIT_ATTRS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_id,p_old_LIMIT_ATTRS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_update_date,p_old_LIMIT_ATTRS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.request_id,p_old_LIMIT_ATTRS_rec.request_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type
IS
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type := p_LIMIT_ATTRS_rec;
BEGIN

    IF l_LIMIT_ATTRS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute1 := p_old_LIMIT_ATTRS_rec.attribute1;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute10 := p_old_LIMIT_ATTRS_rec.attribute10;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute11 := p_old_LIMIT_ATTRS_rec.attribute11;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute12 := p_old_LIMIT_ATTRS_rec.attribute12;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute13 := p_old_LIMIT_ATTRS_rec.attribute13;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute14 := p_old_LIMIT_ATTRS_rec.attribute14;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute15 := p_old_LIMIT_ATTRS_rec.attribute15;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute2 := p_old_LIMIT_ATTRS_rec.attribute2;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute3 := p_old_LIMIT_ATTRS_rec.attribute3;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute4 := p_old_LIMIT_ATTRS_rec.attribute4;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute5 := p_old_LIMIT_ATTRS_rec.attribute5;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute6 := p_old_LIMIT_ATTRS_rec.attribute6;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute7 := p_old_LIMIT_ATTRS_rec.attribute7;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute8 := p_old_LIMIT_ATTRS_rec.attribute8;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute9 := p_old_LIMIT_ATTRS_rec.attribute9;
    END IF;

    IF l_LIMIT_ATTRS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.comparison_operator_code := p_old_LIMIT_ATTRS_rec.comparison_operator_code;
    END IF;

    IF l_LIMIT_ATTRS_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.context := p_old_LIMIT_ATTRS_rec.context;
    END IF;

    IF l_LIMIT_ATTRS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.created_by := p_old_LIMIT_ATTRS_rec.created_by;
    END IF;

    IF l_LIMIT_ATTRS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.creation_date := p_old_LIMIT_ATTRS_rec.creation_date;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.last_updated_by := p_old_LIMIT_ATTRS_rec.last_updated_by;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.last_update_date := p_old_LIMIT_ATTRS_rec.last_update_date;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.last_update_login := p_old_LIMIT_ATTRS_rec.last_update_login;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute := p_old_LIMIT_ATTRS_rec.limit_attribute;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute_context := p_old_LIMIT_ATTRS_rec.limit_attribute_context;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.limit_attribute_id := p_old_LIMIT_ATTRS_rec.limit_attribute_id;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute_type := p_old_LIMIT_ATTRS_rec.limit_attribute_type;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attr_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attr_datatype := p_old_LIMIT_ATTRS_rec.limit_attr_datatype;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attr_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attr_value := p_old_LIMIT_ATTRS_rec.limit_attr_value;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.limit_id := p_old_LIMIT_ATTRS_rec.limit_id;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.program_application_id := p_old_LIMIT_ATTRS_rec.program_application_id;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.program_id := p_old_LIMIT_ATTRS_rec.program_id;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.program_update_date := p_old_LIMIT_ATTRS_rec.program_update_date;
    END IF;

    IF l_LIMIT_ATTRS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.request_id := p_old_LIMIT_ATTRS_rec.request_id;
    END IF;

    RETURN l_LIMIT_ATTRS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type
IS
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type := p_LIMIT_ATTRS_rec;
BEGIN

    IF l_LIMIT_ATTRS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute1 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute10 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute11 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute12 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute13 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute14 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute15 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute2 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute3 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute4 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute5 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute6 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute7 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute8 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.attribute9 := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.comparison_operator_code := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.context := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.created_by := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.creation_date := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.last_updated_by := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.last_update_date := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.last_update_login := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_context = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute_context := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.limit_attribute_id := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attribute_type = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attribute_type := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attr_datatype = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attr_datatype := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_attr_value = FND_API.G_MISS_CHAR THEN
        l_LIMIT_ATTRS_rec.limit_attr_value := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.limit_id := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.program_application_id := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.program_id := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_LIMIT_ATTRS_rec.program_update_date := NULL;
    END IF;

    IF l_LIMIT_ATTRS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_LIMIT_ATTRS_rec.request_id := NULL;
    END IF;

    RETURN l_LIMIT_ATTRS_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
BEGIN
SELECT active_flag
       INTO l_active_flag
       FROM QP_LIMITS a,QP_LIST_HEADERS_B b
       WHERE a.limit_id=p_LIMIT_ATTRS_rec.limit_id
       AND   b.list_header_id=a.list_header_id;


    UPDATE  QP_LIMIT_ATTRIBUTES
    SET     ATTRIBUTE1                     = p_LIMIT_ATTRS_rec.attribute1
    ,       ATTRIBUTE10                    = p_LIMIT_ATTRS_rec.attribute10
    ,       ATTRIBUTE11                    = p_LIMIT_ATTRS_rec.attribute11
    ,       ATTRIBUTE12                    = p_LIMIT_ATTRS_rec.attribute12
    ,       ATTRIBUTE13                    = p_LIMIT_ATTRS_rec.attribute13
    ,       ATTRIBUTE14                    = p_LIMIT_ATTRS_rec.attribute14
    ,       ATTRIBUTE15                    = p_LIMIT_ATTRS_rec.attribute15
    ,       ATTRIBUTE2                     = p_LIMIT_ATTRS_rec.attribute2
    ,       ATTRIBUTE3                     = p_LIMIT_ATTRS_rec.attribute3
    ,       ATTRIBUTE4                     = p_LIMIT_ATTRS_rec.attribute4
    ,       ATTRIBUTE5                     = p_LIMIT_ATTRS_rec.attribute5
    ,       ATTRIBUTE6                     = p_LIMIT_ATTRS_rec.attribute6
    ,       ATTRIBUTE7                     = p_LIMIT_ATTRS_rec.attribute7
    ,       ATTRIBUTE8                     = p_LIMIT_ATTRS_rec.attribute8
    ,       ATTRIBUTE9                     = p_LIMIT_ATTRS_rec.attribute9
    ,       COMPARISON_OPERATOR_CODE       = p_LIMIT_ATTRS_rec.comparison_operator_code
    ,       CONTEXT                        = p_LIMIT_ATTRS_rec.context
    ,       CREATED_BY                     = p_LIMIT_ATTRS_rec.created_by
    ,       CREATION_DATE                  = p_LIMIT_ATTRS_rec.creation_date
    ,       LAST_UPDATED_BY                = p_LIMIT_ATTRS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_LIMIT_ATTRS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_LIMIT_ATTRS_rec.last_update_login
    ,       LIMIT_ATTRIBUTE                = p_LIMIT_ATTRS_rec.limit_attribute
    ,       LIMIT_ATTRIBUTE_CONTEXT        = p_LIMIT_ATTRS_rec.limit_attribute_context
    ,       LIMIT_ATTRIBUTE_ID             = p_LIMIT_ATTRS_rec.limit_attribute_id
    ,       LIMIT_ATTRIBUTE_TYPE           = p_LIMIT_ATTRS_rec.limit_attribute_type
    ,       LIMIT_ATTR_DATATYPE            = p_LIMIT_ATTRS_rec.limit_attr_datatype
    ,       LIMIT_ATTR_VALUE               = p_LIMIT_ATTRS_rec.limit_attr_value
    ,       LIMIT_ID                       = p_LIMIT_ATTRS_rec.limit_id
    ,       PROGRAM_APPLICATION_ID         = p_LIMIT_ATTRS_rec.program_application_id
    ,       PROGRAM_ID                     = p_LIMIT_ATTRS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_LIMIT_ATTRS_rec.program_update_date
    ,       REQUEST_ID                     = p_LIMIT_ATTRS_rec.request_id
    WHERE   LIMIT_ATTRIBUTE_ID = p_LIMIT_ATTRS_rec.limit_attribute_id
    ;

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN

  IF(p_LIMIT_ATTRS_rec.limit_attribute_context IS NOT NULL)
  AND (p_LIMIT_ATTRS_rec.limit_attribute IS NOT NULL) THEN
  UPDATE qp_pte_segments SET used_in_setup='Y'
  WHERE nvl(used_in_setup,'N')='N'
  AND segment_id IN
  (SELECT a.segment_id
  FROM   qp_segments_b a,qp_prc_contexts_b b
  WHERE  a.segment_mapping_column=p_LIMIT_ATTRS_rec.limit_attribute
  AND    a.prc_context_id=b.prc_context_id
  AND b.prc_context_type = p_LIMIT_ATTRS_rec.limit_attribute_type
  AND    b.prc_context_code=p_LIMIT_ATTRS_rec.limit_attribute_context);
  END IF;
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
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
l_check_active_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);

BEGIN
SELECT active_flag
       INTO l_active_flag
       FROM QP_LIMITS a,QP_LIST_HEADERS_B b
       WHERE a.limit_id=p_LIMIT_ATTRS_rec.limit_id
       AND   b.list_header_id=a.list_header_id;

    INSERT  INTO QP_LIMIT_ATTRIBUTES
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
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_ATTRIBUTE
    ,       LIMIT_ATTRIBUTE_CONTEXT
    ,       LIMIT_ATTRIBUTE_ID
    ,       LIMIT_ATTRIBUTE_TYPE
    ,       LIMIT_ATTR_DATATYPE
    ,       LIMIT_ATTR_VALUE
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    )
    VALUES
    (       p_LIMIT_ATTRS_rec.attribute1
    ,       p_LIMIT_ATTRS_rec.attribute10
    ,       p_LIMIT_ATTRS_rec.attribute11
    ,       p_LIMIT_ATTRS_rec.attribute12
    ,       p_LIMIT_ATTRS_rec.attribute13
    ,       p_LIMIT_ATTRS_rec.attribute14
    ,       p_LIMIT_ATTRS_rec.attribute15
    ,       p_LIMIT_ATTRS_rec.attribute2
    ,       p_LIMIT_ATTRS_rec.attribute3
    ,       p_LIMIT_ATTRS_rec.attribute4
    ,       p_LIMIT_ATTRS_rec.attribute5
    ,       p_LIMIT_ATTRS_rec.attribute6
    ,       p_LIMIT_ATTRS_rec.attribute7
    ,       p_LIMIT_ATTRS_rec.attribute8
    ,       p_LIMIT_ATTRS_rec.attribute9
    ,       p_LIMIT_ATTRS_rec.comparison_operator_code
    ,       p_LIMIT_ATTRS_rec.context
    ,       p_LIMIT_ATTRS_rec.created_by
    ,       p_LIMIT_ATTRS_rec.creation_date
    ,       p_LIMIT_ATTRS_rec.last_updated_by
    ,       p_LIMIT_ATTRS_rec.last_update_date
    ,       p_LIMIT_ATTRS_rec.last_update_login
    ,       p_LIMIT_ATTRS_rec.limit_attribute
    ,       p_LIMIT_ATTRS_rec.limit_attribute_context
    ,       p_LIMIT_ATTRS_rec.limit_attribute_id
    ,       p_LIMIT_ATTRS_rec.limit_attribute_type
    ,       p_LIMIT_ATTRS_rec.limit_attr_datatype
    ,       p_LIMIT_ATTRS_rec.limit_attr_value
    ,       p_LIMIT_ATTRS_rec.limit_id
    ,       p_LIMIT_ATTRS_rec.program_application_id
    ,       p_LIMIT_ATTRS_rec.program_id
    ,       p_LIMIT_ATTRS_rec.program_update_date
    ,       p_LIMIT_ATTRS_rec.request_id
    );

l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
IF(p_LIMIT_ATTRS_rec.limit_attribute_context IS NOT NULL)
AND (p_LIMIT_ATTRS_rec.limit_attribute IS NOT NULL) THEN
UPDATE qp_pte_segments SET used_in_setup='Y'
WHERE nvl(used_in_setup,'N')='N'
AND segment_id IN
(SELECT a.segment_id
 FROM   qp_segments_b a,qp_prc_contexts_b b
 WHERE  a.segment_mapping_column=p_LIMIT_ATTRS_rec.limit_attribute
 AND    a.prc_context_id=b.prc_context_id
 AND b.prc_context_type = p_LIMIT_ATTRS_rec.limit_attribute_type
 AND    b.prc_context_code=p_LIMIT_ATTRS_rec.limit_attribute_context);
END IF;
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
(   p_limit_attribute_id            IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_LIMIT_ATTRIBUTES
    WHERE   LIMIT_ATTRIBUTE_ID = p_limit_attribute_id
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
(   p_limit_attribute_id            IN  NUMBER
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_limit_attribute_id          => p_limit_attribute_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_limit_attribute_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_limit_id                      IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Limits_PUB.Limit_Attrs_Tbl_Type
IS
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_LIMIT_ATTRS_tbl             QP_Limits_PUB.Limit_Attrs_Tbl_Type;

CURSOR l_LIMIT_ATTRS_csr IS
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
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_ATTRIBUTE
    ,       LIMIT_ATTRIBUTE_CONTEXT
    ,       LIMIT_ATTRIBUTE_ID
    ,       LIMIT_ATTRIBUTE_TYPE
    ,       LIMIT_ATTR_DATATYPE
    ,       LIMIT_ATTR_VALUE
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    FROM    QP_LIMIT_ATTRIBUTES
    WHERE ( LIMIT_ATTRIBUTE_ID = p_limit_attribute_id
    )
    OR (    LIMIT_ID = p_limit_id
    );

BEGIN

    IF
    (p_limit_attribute_id IS NOT NULL
     AND
     p_limit_attribute_id <> FND_API.G_MISS_NUM)
    AND
    (p_limit_id IS NOT NULL
     AND
     p_limit_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: limit_attribute_id = '|| p_limit_attribute_id || ', limit_id = '|| p_limit_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_LIMIT_ATTRS_csr LOOP

        l_LIMIT_ATTRS_rec.attribute1   := l_implicit_rec.ATTRIBUTE1;
        l_LIMIT_ATTRS_rec.attribute10  := l_implicit_rec.ATTRIBUTE10;
        l_LIMIT_ATTRS_rec.attribute11  := l_implicit_rec.ATTRIBUTE11;
        l_LIMIT_ATTRS_rec.attribute12  := l_implicit_rec.ATTRIBUTE12;
        l_LIMIT_ATTRS_rec.attribute13  := l_implicit_rec.ATTRIBUTE13;
        l_LIMIT_ATTRS_rec.attribute14  := l_implicit_rec.ATTRIBUTE14;
        l_LIMIT_ATTRS_rec.attribute15  := l_implicit_rec.ATTRIBUTE15;
        l_LIMIT_ATTRS_rec.attribute2   := l_implicit_rec.ATTRIBUTE2;
        l_LIMIT_ATTRS_rec.attribute3   := l_implicit_rec.ATTRIBUTE3;
        l_LIMIT_ATTRS_rec.attribute4   := l_implicit_rec.ATTRIBUTE4;
        l_LIMIT_ATTRS_rec.attribute5   := l_implicit_rec.ATTRIBUTE5;
        l_LIMIT_ATTRS_rec.attribute6   := l_implicit_rec.ATTRIBUTE6;
        l_LIMIT_ATTRS_rec.attribute7   := l_implicit_rec.ATTRIBUTE7;
        l_LIMIT_ATTRS_rec.attribute8   := l_implicit_rec.ATTRIBUTE8;
        l_LIMIT_ATTRS_rec.attribute9   := l_implicit_rec.ATTRIBUTE9;
        l_LIMIT_ATTRS_rec.comparison_operator_code := l_implicit_rec.COMPARISON_OPERATOR_CODE;
        l_LIMIT_ATTRS_rec.context      := l_implicit_rec.CONTEXT;
        l_LIMIT_ATTRS_rec.created_by   := l_implicit_rec.CREATED_BY;
        l_LIMIT_ATTRS_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_LIMIT_ATTRS_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_LIMIT_ATTRS_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_LIMIT_ATTRS_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_LIMIT_ATTRS_rec.limit_attribute := l_implicit_rec.LIMIT_ATTRIBUTE;
        l_LIMIT_ATTRS_rec.limit_attribute_context := l_implicit_rec.LIMIT_ATTRIBUTE_CONTEXT;
        l_LIMIT_ATTRS_rec.limit_attribute_id := l_implicit_rec.LIMIT_ATTRIBUTE_ID;
        l_LIMIT_ATTRS_rec.limit_attribute_type := l_implicit_rec.LIMIT_ATTRIBUTE_TYPE;
        l_LIMIT_ATTRS_rec.limit_attr_datatype := l_implicit_rec.LIMIT_ATTR_DATATYPE;
        l_LIMIT_ATTRS_rec.limit_attr_value := l_implicit_rec.LIMIT_ATTR_VALUE;
        l_LIMIT_ATTRS_rec.limit_id     := l_implicit_rec.LIMIT_ID;
        l_LIMIT_ATTRS_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_LIMIT_ATTRS_rec.program_id   := l_implicit_rec.PROGRAM_ID;
        l_LIMIT_ATTRS_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_LIMIT_ATTRS_rec.request_id   := l_implicit_rec.REQUEST_ID;

        l_LIMIT_ATTRS_tbl(l_LIMIT_ATTRS_tbl.COUNT + 1) := l_LIMIT_ATTRS_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_limit_attribute_id IS NOT NULL
     AND
     p_limit_attribute_id <> FND_API.G_MISS_NUM)
    AND
    (l_LIMIT_ATTRS_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_LIMIT_ATTRS_tbl;

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
,   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
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
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMIT_ATTRIBUTE
    ,       LIMIT_ATTRIBUTE_CONTEXT
    ,       LIMIT_ATTRIBUTE_ID
    ,       LIMIT_ATTRIBUTE_TYPE
    ,       LIMIT_ATTR_DATATYPE
    ,       LIMIT_ATTR_VALUE
    ,       LIMIT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    l_LIMIT_ATTRS_rec.attribute1
    ,       l_LIMIT_ATTRS_rec.attribute10
    ,       l_LIMIT_ATTRS_rec.attribute11
    ,       l_LIMIT_ATTRS_rec.attribute12
    ,       l_LIMIT_ATTRS_rec.attribute13
    ,       l_LIMIT_ATTRS_rec.attribute14
    ,       l_LIMIT_ATTRS_rec.attribute15
    ,       l_LIMIT_ATTRS_rec.attribute2
    ,       l_LIMIT_ATTRS_rec.attribute3
    ,       l_LIMIT_ATTRS_rec.attribute4
    ,       l_LIMIT_ATTRS_rec.attribute5
    ,       l_LIMIT_ATTRS_rec.attribute6
    ,       l_LIMIT_ATTRS_rec.attribute7
    ,       l_LIMIT_ATTRS_rec.attribute8
    ,       l_LIMIT_ATTRS_rec.attribute9
    ,       l_LIMIT_ATTRS_rec.comparison_operator_code
    ,       l_LIMIT_ATTRS_rec.context
    ,       l_LIMIT_ATTRS_rec.created_by
    ,       l_LIMIT_ATTRS_rec.creation_date
    ,       l_LIMIT_ATTRS_rec.last_updated_by
    ,       l_LIMIT_ATTRS_rec.last_update_date
    ,       l_LIMIT_ATTRS_rec.last_update_login
    ,       l_LIMIT_ATTRS_rec.limit_attribute
    ,       l_LIMIT_ATTRS_rec.limit_attribute_context
    ,       l_LIMIT_ATTRS_rec.limit_attribute_id
    ,       l_LIMIT_ATTRS_rec.limit_attribute_type
    ,       l_LIMIT_ATTRS_rec.limit_attr_datatype
    ,       l_LIMIT_ATTRS_rec.limit_attr_value
    ,       l_LIMIT_ATTRS_rec.limit_id
    ,       l_LIMIT_ATTRS_rec.program_application_id
    ,       l_LIMIT_ATTRS_rec.program_id
    ,       l_LIMIT_ATTRS_rec.program_update_date
    ,       l_LIMIT_ATTRS_rec.request_id
    FROM    QP_LIMIT_ATTRIBUTES
    WHERE   LIMIT_ATTRIBUTE_ID = p_LIMIT_ATTRS_rec.limit_attribute_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute1,
                         l_LIMIT_ATTRS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute10,
                         l_LIMIT_ATTRS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute11,
                         l_LIMIT_ATTRS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute12,
                         l_LIMIT_ATTRS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute13,
                         l_LIMIT_ATTRS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute14,
                         l_LIMIT_ATTRS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute15,
                         l_LIMIT_ATTRS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute2,
                         l_LIMIT_ATTRS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute3,
                         l_LIMIT_ATTRS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute4,
                         l_LIMIT_ATTRS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute5,
                         l_LIMIT_ATTRS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute6,
                         l_LIMIT_ATTRS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute7,
                         l_LIMIT_ATTRS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute8,
                         l_LIMIT_ATTRS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.attribute9,
                         l_LIMIT_ATTRS_rec.attribute9)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.comparison_operator_code,
                         l_LIMIT_ATTRS_rec.comparison_operator_code)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.context,
                         l_LIMIT_ATTRS_rec.context)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.created_by,
                         l_LIMIT_ATTRS_rec.created_by)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.creation_date,
                         l_LIMIT_ATTRS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_updated_by,
                         l_LIMIT_ATTRS_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_date,
                         l_LIMIT_ATTRS_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.last_update_login,
                         l_LIMIT_ATTRS_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute,
                         l_LIMIT_ATTRS_rec.limit_attribute)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_context,
                         l_LIMIT_ATTRS_rec.limit_attribute_context)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_id,
                         l_LIMIT_ATTRS_rec.limit_attribute_id)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_type,
                         l_LIMIT_ATTRS_rec.limit_attribute_type)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_datatype,
                         l_LIMIT_ATTRS_rec.limit_attr_datatype)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attr_value,
                         l_LIMIT_ATTRS_rec.limit_attr_value)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_id,
                         l_LIMIT_ATTRS_rec.limit_id)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_application_id,
                         l_LIMIT_ATTRS_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_id,
                         l_LIMIT_ATTRS_rec.program_id)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.program_update_date,
                         l_LIMIT_ATTRS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.request_id,
                         l_LIMIT_ATTRS_rec.request_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_LIMIT_ATTRS_rec              := l_LIMIT_ATTRS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec           IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
) RETURN QP_Limits_PUB.Limit_Attrs_Val_Rec_Type
IS
l_LIMIT_ATTRS_val_rec         QP_Limits_PUB.Limit_Attrs_Val_Rec_Type;
BEGIN

    IF p_LIMIT_ATTRS_rec.comparison_operator_code IS NOT NULL AND
        p_LIMIT_ATTRS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.comparison_operator_code,
        p_old_LIMIT_ATTRS_rec.comparison_operator_code)
    THEN
        l_LIMIT_ATTRS_val_rec.comparison_operator := QP_Id_To_Value.Comparison_Operator
        (   p_comparison_operator_code    => p_LIMIT_ATTRS_rec.comparison_operator_code
        );
    END IF;

    IF p_LIMIT_ATTRS_rec.limit_attribute_id IS NOT NULL AND
        p_LIMIT_ATTRS_rec.limit_attribute_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_attribute_id,
        p_old_LIMIT_ATTRS_rec.limit_attribute_id)
    THEN
        l_LIMIT_ATTRS_val_rec.limit_attribute := QP_Id_To_Value.Limit_Attribute
        (   p_limit_attribute_id          => p_LIMIT_ATTRS_rec.limit_attribute_id
        );
    END IF;

    IF p_LIMIT_ATTRS_rec.limit_id IS NOT NULL AND
        p_LIMIT_ATTRS_rec.limit_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_LIMIT_ATTRS_rec.limit_id,
        p_old_LIMIT_ATTRS_rec.limit_id)
    THEN
        l_LIMIT_ATTRS_val_rec.limit := QP_Id_To_Value.Limit
        (   p_limit_id                    => p_LIMIT_ATTRS_rec.limit_id
        );
    END IF;

    RETURN l_LIMIT_ATTRS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_LIMIT_ATTRS_val_rec           IN  QP_Limits_PUB.Limit_Attrs_Val_Rec_Type
) RETURN QP_Limits_PUB.Limit_Attrs_Rec_Type
IS
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_LIMIT_ATTRS_rec.

    l_LIMIT_ATTRS_rec := p_LIMIT_ATTRS_rec;

    IF  p_LIMIT_ATTRS_val_rec.comparison_operator <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMIT_ATTRS_rec.comparison_operator_code <> FND_API.G_MISS_CHAR THEN

            l_LIMIT_ATTRS_rec.comparison_operator_code := p_LIMIT_ATTRS_rec.comparison_operator_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMIT_ATTRS_rec.comparison_operator_code := QP_Value_To_Id.comparison_operator
            (   p_comparison_operator         => p_LIMIT_ATTRS_val_rec.comparison_operator
            );

            IF l_LIMIT_ATTRS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN
                l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMIT_ATTRS_val_rec.limit_attribute <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMIT_ATTRS_rec.limit_attribute_id <> FND_API.G_MISS_NUM THEN

            l_LIMIT_ATTRS_rec.limit_attribute_id := p_LIMIT_ATTRS_rec.limit_attribute_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMIT_ATTRS_rec.limit_attribute_id := QP_Value_To_Id.limit_attribute
            (   p_limit_attribute             => p_LIMIT_ATTRS_val_rec.limit_attribute
            );

            IF l_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM THEN
                l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_LIMIT_ATTRS_val_rec.limit <> FND_API.G_MISS_CHAR
    THEN

        IF p_LIMIT_ATTRS_rec.limit_id <> FND_API.G_MISS_NUM THEN

            l_LIMIT_ATTRS_rec.limit_id := p_LIMIT_ATTRS_rec.limit_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_LIMIT_ATTRS_rec.limit_id := QP_Value_To_Id.limit
            (   p_limit                       => p_LIMIT_ATTRS_val_rec.limit
            );

            IF l_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM THEN
                l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_LIMIT_ATTRS_rec;

END Get_Ids;

Procedure Pre_Write_Process
(   p_LIMIT_ATTRS_rec                      IN  QP_Limits_PUB.Limit_Attrs_Rec_Type
,   p_old_LIMIT_ATTRS_rec                  IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                                QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   x_LIMIT_ATTRS_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS

l_LIMIT_ATTRS_rec               QP_Limits_PUB.Limit_Attrs_Rec_Type := p_LIMIT_ATTRS_rec;
l_return_status       		varchar2(30);

BEGIN


    qp_delayed_requests_PVT.log_request
         (
         p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
         p_entity_id  => p_LIMIT_ATTRS_rec.limit_id,
         p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
         p_requesting_entity_id => p_LIMIT_ATTRS_rec.limit_id,
         p_request_type => QP_GLOBALS.G_UPDATE_LIMITS_COLUMNS,
         x_return_status => l_return_status
         );

x_LIMIT_ATTRS_rec := l_LIMIT_ATTRS_rec;

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

END QP_Limit_Attrs_Util;

/

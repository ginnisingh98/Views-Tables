--------------------------------------------------------
--  DDL for Package Body QP_SOU_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SOU_UTIL" AS
/* $Header: QPXUSOUB.pls 120.1 2005/06/13 23:30:20 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Sou_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_SOU_rec := p_SOU_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute1,p_old_SOU_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute10,p_old_SOU_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute11,p_old_SOU_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute12,p_old_SOU_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute13,p_old_SOU_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute14,p_old_SOU_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute15,p_old_SOU_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute2,p_old_SOU_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute3,p_old_SOU_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute4,p_old_SOU_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute5,p_old_SOU_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute6,p_old_SOU_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute7,p_old_SOU_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute8,p_old_SOU_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute9,p_old_SOU_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_id,p_old_SOU_rec.attribute_sourcing_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE_SOURCING;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_level,p_old_SOU_rec.attribute_sourcing_level)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE_SOURCING_LEVEL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.application_id,p_old_SOU_rec.application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_APPLICATION_ID;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.context,p_old_SOU_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.created_by,p_old_SOU_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.creation_date,p_old_SOU_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.enabled_flag,p_old_SOU_rec.enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_updated_by,p_old_SOU_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_update_date,p_old_SOU_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_update_login,p_old_SOU_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_application_id,p_old_SOU_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_id,p_old_SOU_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_update_date,p_old_SOU_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.request_type_code,p_old_SOU_rec.request_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_REQUEST_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_flag,p_old_SOU_rec.seeded_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_sourcing_type,p_old_SOU_rec.seeded_sourcing_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED_SOURCING_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_value_string,p_old_SOU_rec.seeded_value_string)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED_VALUE_STRING;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.segment_id,p_old_SOU_rec.segment_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEGMENT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.user_sourcing_type,p_old_SOU_rec.user_sourcing_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_USER_SOURCING_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SOU_rec.user_value_string,p_old_SOU_rec.user_value_string)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_USER_VALUE_STRING;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_ATTRIBUTE_SOURCING THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE_SOURCING;
    ELSIF p_attr_id = G_ATTRIBUTE_SOURCING_LEVEL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ATTRIBUTE_SOURCING_LEVEL;
    ELSIF p_attr_id = G_APPLICATION_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_APPLICATION_ID;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_ENABLED;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REQUEST_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_REQUEST_TYPE;
    ELSIF p_attr_id = G_SEEDED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED;
    ELSIF p_attr_id = G_SEEDED_SOURCING_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED_SOURCING_TYPE;
    ELSIF p_attr_id = G_SEEDED_VALUE_STRING THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEEDED_VALUE_STRING;
    ELSIF p_attr_id = G_SEGMENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_SEGMENT;
    ELSIF p_attr_id = G_USER_SOURCING_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_USER_SOURCING_TYPE;
    ELSIF p_attr_id = G_USER_VALUE_STRING THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SOU_UTIL.G_USER_VALUE_STRING;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_SOU_rec := p_SOU_rec;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute1,p_old_SOU_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute10,p_old_SOU_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute11,p_old_SOU_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute12,p_old_SOU_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute13,p_old_SOU_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute14,p_old_SOU_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute15,p_old_SOU_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute2,p_old_SOU_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute3,p_old_SOU_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute4,p_old_SOU_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute5,p_old_SOU_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute6,p_old_SOU_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute7,p_old_SOU_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute8,p_old_SOU_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute9,p_old_SOU_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_id,p_old_SOU_rec.attribute_sourcing_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_level,p_old_SOU_rec.attribute_sourcing_level)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.application_id,p_old_SOU_rec.application_id)
    THEN
        NULL;
    END IF;


    IF NOT QP_GLOBALS.Equal(p_SOU_rec.context,p_old_SOU_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.created_by,p_old_SOU_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.creation_date,p_old_SOU_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.enabled_flag,p_old_SOU_rec.enabled_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_updated_by,p_old_SOU_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_update_date,p_old_SOU_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.last_update_login,p_old_SOU_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_application_id,p_old_SOU_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_id,p_old_SOU_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.program_update_date,p_old_SOU_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.request_type_code,p_old_SOU_rec.request_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_flag,p_old_SOU_rec.seeded_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_sourcing_type,p_old_SOU_rec.seeded_sourcing_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_value_string,p_old_SOU_rec.seeded_value_string)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.segment_id,p_old_SOU_rec.segment_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.user_sourcing_type,p_old_SOU_rec.user_sourcing_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SOU_rec.user_value_string,p_old_SOU_rec.user_value_string)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type
IS
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type := p_SOU_rec;
BEGIN

    IF l_SOU_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute1 := p_old_SOU_rec.attribute1;
    END IF;

    IF l_SOU_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute10 := p_old_SOU_rec.attribute10;
    END IF;

    IF l_SOU_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute11 := p_old_SOU_rec.attribute11;
    END IF;

    IF l_SOU_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute12 := p_old_SOU_rec.attribute12;
    END IF;

    IF l_SOU_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute13 := p_old_SOU_rec.attribute13;
    END IF;

    IF l_SOU_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute14 := p_old_SOU_rec.attribute14;
    END IF;

    IF l_SOU_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute15 := p_old_SOU_rec.attribute15;
    END IF;

    IF l_SOU_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute2 := p_old_SOU_rec.attribute2;
    END IF;

    IF l_SOU_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute3 := p_old_SOU_rec.attribute3;
    END IF;

    IF l_SOU_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute4 := p_old_SOU_rec.attribute4;
    END IF;

    IF l_SOU_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute5 := p_old_SOU_rec.attribute5;
    END IF;

    IF l_SOU_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute6 := p_old_SOU_rec.attribute6;
    END IF;

    IF l_SOU_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute7 := p_old_SOU_rec.attribute7;
    END IF;

    IF l_SOU_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute8 := p_old_SOU_rec.attribute8;
    END IF;

    IF l_SOU_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute9 := p_old_SOU_rec.attribute9;
    END IF;

    IF l_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.attribute_sourcing_id := p_old_SOU_rec.attribute_sourcing_id;
    END IF;

    IF l_SOU_rec.attribute_sourcing_level = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute_sourcing_level := p_old_SOU_rec.attribute_sourcing_level;
    END IF;

    IF l_SOU_rec.application_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.application_id := p_old_SOU_rec.application_id;
    END IF;

    IF l_SOU_rec.context = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.context := p_old_SOU_rec.context;
    END IF;

    IF l_SOU_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SOU_rec.created_by := p_old_SOU_rec.created_by;
    END IF;

    IF l_SOU_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.creation_date := p_old_SOU_rec.creation_date;
    END IF;

    IF l_SOU_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.enabled_flag := p_old_SOU_rec.enabled_flag;
    END IF;

    IF l_SOU_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SOU_rec.last_updated_by := p_old_SOU_rec.last_updated_by;
    END IF;

    IF l_SOU_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.last_update_date := p_old_SOU_rec.last_update_date;
    END IF;

    IF l_SOU_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SOU_rec.last_update_login := p_old_SOU_rec.last_update_login;
    END IF;

    IF l_SOU_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.program_application_id := p_old_SOU_rec.program_application_id;
    END IF;

    IF l_SOU_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.program_id := p_old_SOU_rec.program_id;
    END IF;

    IF l_SOU_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.program_update_date := p_old_SOU_rec.program_update_date;
    END IF;

    IF l_SOU_rec.request_type_code = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.request_type_code := p_old_SOU_rec.request_type_code;
    END IF;

    IF l_SOU_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_flag := p_old_SOU_rec.seeded_flag;
    END IF;

    IF l_SOU_rec.seeded_sourcing_type = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_sourcing_type := p_old_SOU_rec.seeded_sourcing_type;
    END IF;

    IF l_SOU_rec.seeded_value_string = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_value_string := p_old_SOU_rec.seeded_value_string;
    END IF;

    IF l_SOU_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.segment_id := p_old_SOU_rec.segment_id;
    END IF;

    IF l_SOU_rec.user_sourcing_type = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.user_sourcing_type := p_old_SOU_rec.user_sourcing_type;
    END IF;

    IF l_SOU_rec.user_value_string = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.user_value_string := p_old_SOU_rec.user_value_string;
    END IF;

    RETURN l_SOU_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type
IS
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type := p_SOU_rec;
BEGIN

    IF l_SOU_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute1 := NULL;
    END IF;

    IF l_SOU_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute10 := NULL;
    END IF;

    IF l_SOU_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute11 := NULL;
    END IF;

    IF l_SOU_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute12 := NULL;
    END IF;

    IF l_SOU_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute13 := NULL;
    END IF;

    IF l_SOU_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute14 := NULL;
    END IF;

    IF l_SOU_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute15 := NULL;
    END IF;

    IF l_SOU_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute2 := NULL;
    END IF;

    IF l_SOU_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute3 := NULL;
    END IF;

    IF l_SOU_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute4 := NULL;
    END IF;

    IF l_SOU_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute5 := NULL;
    END IF;

    IF l_SOU_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute6 := NULL;
    END IF;

    IF l_SOU_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute7 := NULL;
    END IF;

    IF l_SOU_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute8 := NULL;
    END IF;

    IF l_SOU_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute9 := NULL;
    END IF;

    IF l_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.attribute_sourcing_id := NULL;
    END IF;

    IF l_SOU_rec.attribute_sourcing_level = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.attribute_sourcing_level := NULL;
    END IF;

    IF l_SOU_rec.application_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.application_id := NULL;
    END IF;

    IF l_SOU_rec.context = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.context := NULL;
    END IF;

    IF l_SOU_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SOU_rec.created_by := NULL;
    END IF;

    IF l_SOU_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.creation_date := NULL;
    END IF;

    IF l_SOU_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.enabled_flag := NULL;
    END IF;

    IF l_SOU_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SOU_rec.last_updated_by := NULL;
    END IF;

    IF l_SOU_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.last_update_date := NULL;
    END IF;

    IF l_SOU_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SOU_rec.last_update_login := NULL;
    END IF;

    IF l_SOU_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.program_application_id := NULL;
    END IF;

    IF l_SOU_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.program_id := NULL;
    END IF;

    IF l_SOU_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SOU_rec.program_update_date := NULL;
    END IF;

    IF l_SOU_rec.request_type_code = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.request_type_code := NULL;
    END IF;

    IF l_SOU_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_flag := NULL;
    END IF;

    IF l_SOU_rec.seeded_sourcing_type = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_sourcing_type := NULL;
    END IF;

    IF l_SOU_rec.seeded_value_string = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.seeded_value_string := NULL;
    END IF;

    IF l_SOU_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_SOU_rec.segment_id := NULL;
    END IF;

    IF l_SOU_rec.user_sourcing_type = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.user_sourcing_type := NULL;
    END IF;

    IF l_SOU_rec.user_value_string = FND_API.G_MISS_CHAR THEN
        l_SOU_rec.user_value_string := NULL;
    END IF;

    RETURN l_SOU_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
BEGIN

    UPDATE  QP_ATTRIBUTE_SOURCING
    SET     ATTRIBUTE1                     = p_SOU_rec.attribute1
    ,       ATTRIBUTE10                    = p_SOU_rec.attribute10
    ,       ATTRIBUTE11                    = p_SOU_rec.attribute11
    ,       ATTRIBUTE12                    = p_SOU_rec.attribute12
    ,       ATTRIBUTE13                    = p_SOU_rec.attribute13
    ,       ATTRIBUTE14                    = p_SOU_rec.attribute14
    ,       ATTRIBUTE15                    = p_SOU_rec.attribute15
    ,       ATTRIBUTE2                     = p_SOU_rec.attribute2
    ,       ATTRIBUTE3                     = p_SOU_rec.attribute3
    ,       ATTRIBUTE4                     = p_SOU_rec.attribute4
    ,       ATTRIBUTE5                     = p_SOU_rec.attribute5
    ,       ATTRIBUTE6                     = p_SOU_rec.attribute6
    ,       ATTRIBUTE7                     = p_SOU_rec.attribute7
    ,       ATTRIBUTE8                     = p_SOU_rec.attribute8
    ,       ATTRIBUTE9                     = p_SOU_rec.attribute9
    ,       ATTRIBUTE_SOURCING_ID          = p_SOU_rec.attribute_sourcing_id
    ,       ATTRIBUTE_SOURCING_LEVEL       = p_SOU_rec.attribute_sourcing_level
    ,       APPLICATION_ID                 = p_SOU_rec.application_id
    ,       CONTEXT                        = p_SOU_rec.context
    ,       CREATED_BY                     = p_SOU_rec.created_by
    ,       CREATION_DATE                  = p_SOU_rec.creation_date
    ,       ENABLED_FLAG                   = p_SOU_rec.enabled_flag
    ,       LAST_UPDATED_BY                = p_SOU_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_SOU_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_SOU_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID         = p_SOU_rec.program_application_id
    ,       PROGRAM_ID                     = p_SOU_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_SOU_rec.program_update_date
    ,       REQUEST_TYPE_CODE              = p_SOU_rec.request_type_code
    ,       SEEDED_FLAG                    = p_SOU_rec.seeded_flag
    ,       SEEDED_SOURCING_TYPE           = p_SOU_rec.seeded_sourcing_type
    ,       SEEDED_VALUE_STRING            = p_SOU_rec.seeded_value_string
    ,       SEGMENT_ID                     = p_SOU_rec.segment_id
    ,       USER_SOURCING_TYPE             = p_SOU_rec.user_sourcing_type
    ,       USER_VALUE_STRING              = p_SOU_rec.user_value_string
    WHERE   ATTRIBUTE_SOURCING_ID = p_SOU_rec.attribute_sourcing_id
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
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
BEGIN

    INSERT  INTO QP_ATTRIBUTE_SOURCING
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
    ,       ATTRIBUTE_SOURCING_ID
    ,       ATTRIBUTE_SOURCING_LEVEL
    ,       APPLICATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_TYPE_CODE
    ,       SEEDED_FLAG
    ,       SEEDED_SOURCING_TYPE
    ,       SEEDED_VALUE_STRING
    ,       SEGMENT_ID
    ,       USER_SOURCING_TYPE
    ,       USER_VALUE_STRING
    )
    VALUES
    (       p_SOU_rec.attribute1
    ,       p_SOU_rec.attribute10
    ,       p_SOU_rec.attribute11
    ,       p_SOU_rec.attribute12
    ,       p_SOU_rec.attribute13
    ,       p_SOU_rec.attribute14
    ,       p_SOU_rec.attribute15
    ,       p_SOU_rec.attribute2
    ,       p_SOU_rec.attribute3
    ,       p_SOU_rec.attribute4
    ,       p_SOU_rec.attribute5
    ,       p_SOU_rec.attribute6
    ,       p_SOU_rec.attribute7
    ,       p_SOU_rec.attribute8
    ,       p_SOU_rec.attribute9
    ,       p_SOU_rec.attribute_sourcing_id
    ,       p_SOU_rec.attribute_sourcing_level
    ,       p_SOU_rec.application_id
    ,       p_SOU_rec.context
    ,       p_SOU_rec.created_by
    ,       p_SOU_rec.creation_date
    ,       p_SOU_rec.enabled_flag
    ,       p_SOU_rec.last_updated_by
    ,       p_SOU_rec.last_update_date
    ,       p_SOU_rec.last_update_login
    ,       p_SOU_rec.program_application_id
    ,       p_SOU_rec.program_id
    ,       p_SOU_rec.program_update_date
    ,       p_SOU_rec.request_type_code
    ,       p_SOU_rec.seeded_flag
    ,       p_SOU_rec.seeded_sourcing_type
    ,       p_SOU_rec.seeded_value_string
    ,       p_SOU_rec.segment_id
    ,       p_SOU_rec.user_sourcing_type
    ,       p_SOU_rec.user_value_string
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
(   p_attribute_sourcing_id         IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_ATTRIBUTE_SOURCING
    WHERE   ATTRIBUTE_SOURCING_ID = p_attribute_sourcing_id
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
(   p_attribute_sourcing_id         IN  NUMBER
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_attribute_sourcing_id       => p_attribute_sourcing_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_attribute_sourcing_id         IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_segment_pte_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Attr_Map_PUB.Sou_Tbl_Type
IS
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
l_SOU_tbl                     QP_Attr_Map_PUB.Sou_Tbl_Type;

CURSOR l_SOU_csr IS
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
    ,       ATTRIBUTE_SOURCING_ID
    ,       ATTRIBUTE_SOURCING_LEVEL
    ,       APPLICATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_TYPE_CODE
    ,       SEEDED_FLAG
    ,       SEEDED_SOURCING_TYPE
    ,       SEEDED_VALUE_STRING
    ,       SEGMENT_ID
    ,       USER_SOURCING_TYPE
    ,       USER_VALUE_STRING
    FROM    QP_ATTRIBUTE_SOURCING
    WHERE ( ATTRIBUTE_SOURCING_ID = p_attribute_sourcing_id
    );
    --**OR (    SEGMENT_PTE_ID = p_segment_pte_id
    --**);

BEGIN

    IF
    (p_attribute_sourcing_id IS NOT NULL
     AND
     p_attribute_sourcing_id <> FND_API.G_MISS_NUM)
    AND
    (p_segment_pte_id IS NOT NULL
     AND
     p_segment_pte_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: attribute_sourcing_id = '|| p_attribute_sourcing_id || ', segment_pte_id = '|| p_segment_pte_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_SOU_csr LOOP

        l_SOU_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_SOU_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_SOU_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_SOU_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_SOU_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_SOU_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_SOU_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_SOU_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_SOU_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_SOU_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_SOU_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_SOU_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_SOU_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_SOU_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_SOU_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_SOU_rec.attribute_sourcing_id := l_implicit_rec.ATTRIBUTE_SOURCING_ID;
        l_SOU_rec.attribute_sourcing_level := l_implicit_rec.ATTRIBUTE_SOURCING_LEVEL;
        l_SOU_rec.application_id       := l_implicit_rec.APPLICATION_ID;
        l_SOU_rec.context              := l_implicit_rec.CONTEXT;
        l_SOU_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_SOU_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_SOU_rec.enabled_flag         := l_implicit_rec.ENABLED_FLAG;
        l_SOU_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_SOU_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_SOU_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_SOU_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_SOU_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_SOU_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_SOU_rec.request_type_code    := l_implicit_rec.REQUEST_TYPE_CODE;
        l_SOU_rec.seeded_flag          := l_implicit_rec.SEEDED_FLAG;
        l_SOU_rec.seeded_sourcing_type := l_implicit_rec.SEEDED_SOURCING_TYPE;
        l_SOU_rec.seeded_value_string  := l_implicit_rec.SEEDED_VALUE_STRING;
        l_SOU_rec.segment_id           := l_implicit_rec.SEGMENT_ID;
        l_SOU_rec.user_sourcing_type   := l_implicit_rec.USER_SOURCING_TYPE;
        l_SOU_rec.user_value_string    := l_implicit_rec.USER_VALUE_STRING;

        l_SOU_tbl(l_SOU_tbl.COUNT + 1) := l_SOU_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_attribute_sourcing_id IS NOT NULL
     AND
     p_attribute_sourcing_id <> FND_API.G_MISS_NUM)
    AND
    (l_SOU_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_SOU_tbl;

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
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
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
    ,       ATTRIBUTE_SOURCING_ID
    ,       ATTRIBUTE_SOURCING_LEVEL
    ,       APPLICATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_TYPE_CODE
    ,       SEEDED_FLAG
    ,       SEEDED_SOURCING_TYPE
    ,       SEEDED_VALUE_STRING
    ,       SEGMENT_ID
    ,       USER_SOURCING_TYPE
    ,       USER_VALUE_STRING
    INTO    l_SOU_rec.attribute1
    ,       l_SOU_rec.attribute10
    ,       l_SOU_rec.attribute11
    ,       l_SOU_rec.attribute12
    ,       l_SOU_rec.attribute13
    ,       l_SOU_rec.attribute14
    ,       l_SOU_rec.attribute15
    ,       l_SOU_rec.attribute2
    ,       l_SOU_rec.attribute3
    ,       l_SOU_rec.attribute4
    ,       l_SOU_rec.attribute5
    ,       l_SOU_rec.attribute6
    ,       l_SOU_rec.attribute7
    ,       l_SOU_rec.attribute8
    ,       l_SOU_rec.attribute9
    ,       l_SOU_rec.attribute_sourcing_id
    ,       l_SOU_rec.attribute_sourcing_level
    ,       l_SOU_rec.application_id
    ,       l_SOU_rec.context
    ,       l_SOU_rec.created_by
    ,       l_SOU_rec.creation_date
    ,       l_SOU_rec.enabled_flag
    ,       l_SOU_rec.last_updated_by
    ,       l_SOU_rec.last_update_date
    ,       l_SOU_rec.last_update_login
    ,       l_SOU_rec.program_application_id
    ,       l_SOU_rec.program_id
    ,       l_SOU_rec.program_update_date
    ,       l_SOU_rec.request_type_code
    ,       l_SOU_rec.seeded_flag
    ,       l_SOU_rec.seeded_sourcing_type
    ,       l_SOU_rec.seeded_value_string
    ,       l_SOU_rec.segment_id
    ,       l_SOU_rec.user_sourcing_type
    ,       l_SOU_rec.user_value_string
    FROM    QP_ATTRIBUTE_SOURCING
    WHERE   ATTRIBUTE_SOURCING_ID = p_SOU_rec.attribute_sourcing_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_SOU_rec.attribute1,
                         l_SOU_rec.attribute1)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute10,
                         l_SOU_rec.attribute10)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute11,
                         l_SOU_rec.attribute11)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute12,
                         l_SOU_rec.attribute12)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute13,
                         l_SOU_rec.attribute13)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute14,
                         l_SOU_rec.attribute14)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute15,
                         l_SOU_rec.attribute15)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute2,
                         l_SOU_rec.attribute2)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute3,
                         l_SOU_rec.attribute3)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute4,
                         l_SOU_rec.attribute4)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute5,
                         l_SOU_rec.attribute5)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute6,
                         l_SOU_rec.attribute6)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute7,
                         l_SOU_rec.attribute7)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute8,
                         l_SOU_rec.attribute8)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute9,
                         l_SOU_rec.attribute9)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_id,
                         l_SOU_rec.attribute_sourcing_id)
    AND QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_level,
                         l_SOU_rec.attribute_sourcing_level)
    AND QP_GLOBALS.Equal(p_SOU_rec.application_id,
                         l_SOU_rec.application_id)
    AND QP_GLOBALS.Equal(p_SOU_rec.context,
                         l_SOU_rec.context)
    AND QP_GLOBALS.Equal(p_SOU_rec.created_by,
                         l_SOU_rec.created_by)
    AND QP_GLOBALS.Equal(p_SOU_rec.creation_date,
                         l_SOU_rec.creation_date)
    AND QP_GLOBALS.Equal(p_SOU_rec.enabled_flag,
                         l_SOU_rec.enabled_flag)
    AND QP_GLOBALS.Equal(p_SOU_rec.last_updated_by,
                         l_SOU_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_SOU_rec.last_update_date,
                         l_SOU_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_SOU_rec.last_update_login,
                         l_SOU_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_SOU_rec.program_application_id,
                         l_SOU_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_SOU_rec.program_id,
                         l_SOU_rec.program_id)
    AND QP_GLOBALS.Equal(p_SOU_rec.program_update_date,
                         l_SOU_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_SOU_rec.request_type_code,
                         l_SOU_rec.request_type_code)
    AND QP_GLOBALS.Equal(p_SOU_rec.seeded_flag,
                         l_SOU_rec.seeded_flag)
    AND QP_GLOBALS.Equal(p_SOU_rec.seeded_sourcing_type,
                         l_SOU_rec.seeded_sourcing_type)
    AND QP_GLOBALS.Equal(p_SOU_rec.seeded_value_string,
                         l_SOU_rec.seeded_value_string)
    AND QP_GLOBALS.Equal(p_SOU_rec.segment_id,
                         l_SOU_rec.segment_id)
    AND QP_GLOBALS.Equal(p_SOU_rec.user_sourcing_type,
                         l_SOU_rec.user_sourcing_type)
    AND QP_GLOBALS.Equal(p_SOU_rec.user_value_string,
                         l_SOU_rec.user_value_string)
    THEN

        --  Row has not changed. Set out parameter.

        x_SOU_rec                      := l_SOU_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_SOU_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SOU_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SOU_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SOU_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_SOU_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
) RETURN QP_Attr_Map_PUB.Sou_Val_Rec_Type
IS
l_SOU_val_rec                 QP_Attr_Map_PUB.Sou_Val_Rec_Type;
BEGIN

    IF p_SOU_rec.attribute_sourcing_id IS NOT NULL AND
        p_SOU_rec.attribute_sourcing_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SOU_rec.attribute_sourcing_id,
        p_old_SOU_rec.attribute_sourcing_id)
    THEN
        l_SOU_val_rec.attribute_sourcing := QP_Id_To_Value.Attribute_Sourcing
        (   p_attribute_sourcing_id       => p_SOU_rec.attribute_sourcing_id
        );
    END IF;

    IF p_SOU_rec.enabled_flag IS NOT NULL AND
        p_SOU_rec.enabled_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SOU_rec.enabled_flag,
        p_old_SOU_rec.enabled_flag)
    THEN
        l_SOU_val_rec.enabled := QP_Id_To_Value.Enabled
        (   p_enabled_flag                => p_SOU_rec.enabled_flag
        );
    END IF;

    IF p_SOU_rec.request_type_code IS NOT NULL AND
        p_SOU_rec.request_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SOU_rec.request_type_code,
        p_old_SOU_rec.request_type_code)
    THEN
        l_SOU_val_rec.request_type := QP_Id_To_Value.Request_Type
        (   p_request_type_code           => p_SOU_rec.request_type_code
        );
    END IF;

    IF p_SOU_rec.seeded_flag IS NOT NULL AND
        p_SOU_rec.seeded_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SOU_rec.seeded_flag,
        p_old_SOU_rec.seeded_flag)
    THEN
        l_SOU_val_rec.seeded := QP_Id_To_Value.Seeded
        (   p_seeded_flag                 => p_SOU_rec.seeded_flag
        );
    END IF;

    IF p_SOU_rec.segment_id IS NOT NULL AND
        p_SOU_rec.segment_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SOU_rec.segment_id,
        p_old_SOU_rec.segment_id)
    THEN
        l_SOU_val_rec.segment := QP_Id_To_Value.Segment
        (   p_segment_id                  => p_SOU_rec.segment_id
        );
    END IF;

    RETURN l_SOU_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_SOU_val_rec                   IN  QP_Attr_Map_PUB.Sou_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Sou_Rec_Type
IS
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_SOU_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_SOU_rec.

    l_SOU_rec := p_SOU_rec;

    IF  p_SOU_val_rec.attribute_sourcing <> FND_API.G_MISS_CHAR
    THEN

        IF p_SOU_rec.attribute_sourcing_id <> FND_API.G_MISS_NUM THEN

            l_SOU_rec.attribute_sourcing_id := p_SOU_rec.attribute_sourcing_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_sourcing');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SOU_rec.attribute_sourcing_id := QP_Value_To_Id.attribute_sourcing
            (   p_attribute_sourcing          => p_SOU_val_rec.attribute_sourcing
            );

            IF l_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM THEN
                l_SOU_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SOU_val_rec.enabled <> FND_API.G_MISS_CHAR
    THEN

        IF p_SOU_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN

            l_SOU_rec.enabled_flag := p_SOU_rec.enabled_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SOU_rec.enabled_flag := QP_Value_To_Id.enabled
            (   p_enabled                     => p_SOU_val_rec.enabled
            );

            IF l_SOU_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
                l_SOU_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SOU_val_rec.request_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_SOU_rec.request_type_code <> FND_API.G_MISS_CHAR THEN

            l_SOU_rec.request_type_code := p_SOU_rec.request_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SOU_rec.request_type_code := QP_Value_To_Id.request_type
            (   p_request_type                => p_SOU_val_rec.request_type
            );

            IF l_SOU_rec.request_type_code = FND_API.G_MISS_CHAR THEN
                l_SOU_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SOU_val_rec.seeded <> FND_API.G_MISS_CHAR
    THEN

        IF p_SOU_rec.seeded_flag <> FND_API.G_MISS_CHAR THEN

            l_SOU_rec.seeded_flag := p_SOU_rec.seeded_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SOU_rec.seeded_flag := QP_Value_To_Id.seeded
            (   p_seeded                      => p_SOU_val_rec.seeded
            );

            IF l_SOU_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
                l_SOU_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SOU_val_rec.segment <> FND_API.G_MISS_CHAR
    THEN

        IF p_SOU_rec.segment_id <> FND_API.G_MISS_NUM THEN

            l_SOU_rec.segment_id := p_SOU_rec.segment_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SOU_rec.segment_id := QP_Value_To_Id.segment
            (   p_segment                     => p_SOU_val_rec.segment
            );

            IF l_SOU_rec.segment_id = FND_API.G_MISS_NUM THEN
                l_SOU_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_SOU_rec;

END Get_Ids;

END QP_Sou_Util;

/

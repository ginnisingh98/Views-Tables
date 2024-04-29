--------------------------------------------------------
--  DDL for Package Body QP_CON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CON_UTIL" AS
/* $Header: QPXUCONB.pls 120.2 2006/07/11 22:54:29 hwong noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Con_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_CON_rec := p_CON_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute1,p_old_CON_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute10,p_old_CON_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute11,p_old_CON_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute12,p_old_CON_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute13,p_old_CON_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute14,p_old_CON_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute15,p_old_CON_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute2,p_old_CON_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute3,p_old_CON_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute4,p_old_CON_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute5,p_old_CON_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute6,p_old_CON_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute7,p_old_CON_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute8,p_old_CON_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute9,p_old_CON_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.context,p_old_CON_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.created_by,p_old_CON_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.creation_date,p_old_CON_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.enabled_flag,p_old_CON_rec.enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.last_updated_by,p_old_CON_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.last_update_date,p_old_CON_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.last_update_login,p_old_CON_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_code,p_old_CON_rec.prc_context_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT_code;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_id,p_old_CON_rec.prc_context_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_type,p_old_CON_rec.prc_context_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.program_application_id,p_old_CON_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.program_id,p_old_CON_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.program_update_date,p_old_CON_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_description,p_old_CON_rec.seeded_description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_flag,p_old_CON_rec.seeded_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_prc_context_name,p_old_CON_rec.seeded_prc_context_name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED_PRC_CONTEXT_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.user_description,p_old_CON_rec.user_description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_USER_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_CON_rec.user_prc_context_name,p_old_CON_rec.user_prc_context_name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_CON_UTIL.G_USER_PRC_CONTEXT_NAME;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_ENABLED;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_PRC_CONTEXT_code THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT_code;
    ELSIF p_attr_id = G_PRC_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT;
    ELSIF p_attr_id = G_PRC_CONTEXT_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PRC_CONTEXT_TYPE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_SEEDED_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED_DESCRIPTION;
    ELSIF p_attr_id = G_SEEDED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED;
    ELSIF p_attr_id = G_SEEDED_PRC_CONTEXT_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_SEEDED_PRC_CONTEXT_NAME;
    ELSIF p_attr_id = G_USER_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_USER_DESCRIPTION;
    ELSIF p_attr_id = G_USER_PRC_CONTEXT_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_CON_UTIL.G_USER_PRC_CONTEXT_NAME;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_CON_rec := p_CON_rec;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute1,p_old_CON_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute10,p_old_CON_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute11,p_old_CON_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute12,p_old_CON_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute13,p_old_CON_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute14,p_old_CON_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute15,p_old_CON_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute2,p_old_CON_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute3,p_old_CON_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute4,p_old_CON_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute5,p_old_CON_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute6,p_old_CON_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute7,p_old_CON_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute8,p_old_CON_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.attribute9,p_old_CON_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.context,p_old_CON_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.created_by,p_old_CON_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.creation_date,p_old_CON_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.enabled_flag,p_old_CON_rec.enabled_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.last_updated_by,p_old_CON_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.last_update_date,p_old_CON_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.last_update_login,p_old_CON_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_code,p_old_CON_rec.prc_context_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_id,p_old_CON_rec.prc_context_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_type,p_old_CON_rec.prc_context_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.program_application_id,p_old_CON_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.program_id,p_old_CON_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.program_update_date,p_old_CON_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_description,p_old_CON_rec.seeded_description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_flag,p_old_CON_rec.seeded_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.seeded_prc_context_name,p_old_CON_rec.seeded_prc_context_name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.user_description,p_old_CON_rec.user_description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_CON_rec.user_prc_context_name,p_old_CON_rec.user_prc_context_name)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type
) RETURN QP_Attributes_PUB.Con_Rec_Type
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type := p_CON_rec;
BEGIN

    IF l_CON_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute1 := p_old_CON_rec.attribute1;
    END IF;

    IF l_CON_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute10 := p_old_CON_rec.attribute10;
    END IF;

    IF l_CON_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute11 := p_old_CON_rec.attribute11;
    END IF;

    IF l_CON_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute12 := p_old_CON_rec.attribute12;
    END IF;

    IF l_CON_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute13 := p_old_CON_rec.attribute13;
    END IF;

    IF l_CON_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute14 := p_old_CON_rec.attribute14;
    END IF;

    IF l_CON_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute15 := p_old_CON_rec.attribute15;
    END IF;

    IF l_CON_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute2 := p_old_CON_rec.attribute2;
    END IF;

    IF l_CON_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute3 := p_old_CON_rec.attribute3;
    END IF;

    IF l_CON_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute4 := p_old_CON_rec.attribute4;
    END IF;

    IF l_CON_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute5 := p_old_CON_rec.attribute5;
    END IF;

    IF l_CON_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute6 := p_old_CON_rec.attribute6;
    END IF;

    IF l_CON_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute7 := p_old_CON_rec.attribute7;
    END IF;

    IF l_CON_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute8 := p_old_CON_rec.attribute8;
    END IF;

    IF l_CON_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute9 := p_old_CON_rec.attribute9;
    END IF;

    IF l_CON_rec.context = FND_API.G_MISS_CHAR THEN
        l_CON_rec.context := p_old_CON_rec.context;
    END IF;

    IF l_CON_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CON_rec.created_by := p_old_CON_rec.created_by;
    END IF;

    IF l_CON_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.creation_date := p_old_CON_rec.creation_date;
    END IF;

    IF l_CON_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_CON_rec.enabled_flag := p_old_CON_rec.enabled_flag;
    END IF;

    IF l_CON_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CON_rec.last_updated_by := p_old_CON_rec.last_updated_by;
    END IF;

    IF l_CON_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.last_update_date := p_old_CON_rec.last_update_date;
    END IF;

    IF l_CON_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CON_rec.last_update_login := p_old_CON_rec.last_update_login;
    END IF;

    IF l_CON_rec.prc_context_code = FND_API.G_MISS_CHAR THEN
        l_CON_rec.prc_context_code := p_old_CON_rec.prc_context_code;
    END IF;

    IF l_CON_rec.prc_context_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.prc_context_id := p_old_CON_rec.prc_context_id;
    END IF;

    IF l_CON_rec.prc_context_type = FND_API.G_MISS_CHAR THEN
        l_CON_rec.prc_context_type := p_old_CON_rec.prc_context_type;
    END IF;

    IF l_CON_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.program_application_id := p_old_CON_rec.program_application_id;
    END IF;

    IF l_CON_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.program_id := p_old_CON_rec.program_id;
    END IF;

    IF l_CON_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.program_update_date := p_old_CON_rec.program_update_date;
    END IF;

    IF l_CON_rec.seeded_description = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_description := p_old_CON_rec.seeded_description;
    END IF;

    IF l_CON_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_flag := p_old_CON_rec.seeded_flag;
    END IF;

    IF l_CON_rec.seeded_prc_context_name = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_prc_context_name := p_old_CON_rec.seeded_prc_context_name;
    END IF;

    IF l_CON_rec.user_description = FND_API.G_MISS_CHAR THEN
        l_CON_rec.user_description := p_old_CON_rec.user_description;
    END IF;

    IF l_CON_rec.user_prc_context_name = FND_API.G_MISS_CHAR THEN
        l_CON_rec.user_prc_context_name := p_old_CON_rec.user_prc_context_name;
    END IF;

    RETURN l_CON_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
) RETURN QP_Attributes_PUB.Con_Rec_Type
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type := p_CON_rec;
BEGIN

    IF l_CON_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute1 := NULL;
    END IF;

    IF l_CON_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute10 := NULL;
    END IF;

    IF l_CON_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute11 := NULL;
    END IF;

    IF l_CON_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute12 := NULL;
    END IF;

    IF l_CON_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute13 := NULL;
    END IF;

    IF l_CON_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute14 := NULL;
    END IF;

    IF l_CON_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute15 := NULL;
    END IF;

    IF l_CON_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute2 := NULL;
    END IF;

    IF l_CON_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute3 := NULL;
    END IF;

    IF l_CON_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute4 := NULL;
    END IF;

    IF l_CON_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute5 := NULL;
    END IF;

    IF l_CON_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute6 := NULL;
    END IF;

    IF l_CON_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute7 := NULL;
    END IF;

    IF l_CON_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute8 := NULL;
    END IF;

    IF l_CON_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_CON_rec.attribute9 := NULL;
    END IF;

    IF l_CON_rec.context = FND_API.G_MISS_CHAR THEN
        l_CON_rec.context := NULL;
    END IF;

    IF l_CON_rec.created_by = FND_API.G_MISS_NUM THEN
        l_CON_rec.created_by := NULL;
    END IF;

    IF l_CON_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.creation_date := NULL;
    END IF;

    IF l_CON_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_CON_rec.enabled_flag := NULL;
    END IF;

    IF l_CON_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_CON_rec.last_updated_by := NULL;
    END IF;

    IF l_CON_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.last_update_date := NULL;
    END IF;

    IF l_CON_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_CON_rec.last_update_login := NULL;
    END IF;

    IF l_CON_rec.prc_context_code = FND_API.G_MISS_CHAR THEN
        l_CON_rec.prc_context_code := NULL;
    END IF;

    IF l_CON_rec.prc_context_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.prc_context_id := NULL;
    END IF;

    IF l_CON_rec.prc_context_type = FND_API.G_MISS_CHAR THEN
        l_CON_rec.prc_context_type := NULL;
    END IF;

    IF l_CON_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.program_application_id := NULL;
    END IF;

    IF l_CON_rec.program_id = FND_API.G_MISS_NUM THEN
        l_CON_rec.program_id := NULL;
    END IF;

    IF l_CON_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_CON_rec.program_update_date := NULL;
    END IF;

    IF l_CON_rec.seeded_description = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_description := NULL;
    END IF;

    IF l_CON_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_flag := NULL;
    END IF;

    IF l_CON_rec.seeded_prc_context_name = FND_API.G_MISS_CHAR THEN
        l_CON_rec.seeded_prc_context_name := NULL;
    END IF;

    IF l_CON_rec.user_description = FND_API.G_MISS_CHAR THEN
        l_CON_rec.user_description := NULL;
    END IF;

    IF l_CON_rec.user_prc_context_name = FND_API.G_MISS_CHAR THEN
        l_CON_rec.user_prc_context_name := NULL;
    END IF;

    RETURN l_CON_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
)
IS
BEGIN

    UPDATE  QP_PRC_CONTEXTS_b
    SET     ATTRIBUTE1                     = p_CON_rec.attribute1
    ,       ATTRIBUTE10                    = p_CON_rec.attribute10
    ,       ATTRIBUTE11                    = p_CON_rec.attribute11
    ,       ATTRIBUTE12                    = p_CON_rec.attribute12
    ,       ATTRIBUTE13                    = p_CON_rec.attribute13
    ,       ATTRIBUTE14                    = p_CON_rec.attribute14
    ,       ATTRIBUTE15                    = p_CON_rec.attribute15
    ,       ATTRIBUTE2                     = p_CON_rec.attribute2
    ,       ATTRIBUTE3                     = p_CON_rec.attribute3
    ,       ATTRIBUTE4                     = p_CON_rec.attribute4
    ,       ATTRIBUTE5                     = p_CON_rec.attribute5
    ,       ATTRIBUTE6                     = p_CON_rec.attribute6
    ,       ATTRIBUTE7                     = p_CON_rec.attribute7
    ,       ATTRIBUTE8                     = p_CON_rec.attribute8
    ,       ATTRIBUTE9                     = p_CON_rec.attribute9
    ,       CONTEXT                        = p_CON_rec.context
    ,       CREATED_BY                     = p_CON_rec.created_by
    ,       CREATION_DATE                  = p_CON_rec.creation_date
    ,       ENABLED_FLAG                   = p_CON_rec.enabled_flag
    ,       LAST_UPDATED_BY                = p_CON_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_CON_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_CON_rec.last_update_login
    ,       PRC_CONTEXT_CODE               = p_CON_rec.prc_context_code
    ,       PRC_CONTEXT_ID                 = p_CON_rec.prc_context_id
    ,       PRC_CONTEXT_TYPE               = p_CON_rec.prc_context_type
    ,       PROGRAM_APPLICATION_ID         = p_CON_rec.program_application_id
    ,       PROGRAM_ID                     = p_CON_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_CON_rec.program_update_date
    ,       SEEDED_FLAG                    = p_CON_rec.seeded_flag
    WHERE   PRC_CONTEXT_ID = p_CON_rec.prc_context_id ;

  update  qp_prc_contexts_tl
      set     created_by                     = p_con_rec.created_by
      ,       creation_date                  = p_con_rec.creation_date
      ,       last_updated_by                = p_con_rec.last_updated_by
      ,       last_update_date               = p_con_rec.last_update_date
      ,       last_update_login              = p_con_rec.last_update_login
      ,       seeded_prc_context_name        = p_con_rec.seeded_prc_context_name
      ,       user_prc_context_name          = p_con_rec.user_prc_context_name
      ,       seeded_description             = p_con_rec.seeded_description
      ,       user_description               = p_con_rec.user_description
      ,       source_lang                    = userenv('LANG')
      where   prc_context_id = p_con_rec.prc_context_id and
              source_lang = userenv('LANG');

    -- Added by Abhijit. Create Pricing Contexts in Flex field
    --
    if p_CON_rec.prc_context_type = 'PRICING_ATTRIBUTE' then
      FND_DESCR_FLEX_CONTEXTS_PKG.UPDATE_ROW(
         X_APPLICATION_ID => 661, --:CONTEXT.APPLICATION_ID,
         X_DESCRIPTIVE_FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
         X_DESCRIPTIVE_FLEX_CONTEXT_COD => p_CON_rec.prc_context_code,
         X_ENABLED_FLAG => p_CON_rec.ENABLED_FLAG,
         X_GLOBAL_FLAG => 'N',
         X_DESCRIPTION => substr(p_CON_rec.user_description,1,240),
         X_DESCRIPTIVE_FLEX_CONTEXT_NAM => substr(p_CON_rec.user_prc_context_name,1,80),
         X_LAST_UPDATE_DATE => p_CON_rec.LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY => p_CON_rec.LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN => p_CON_rec.LAST_UPDATE_LOGIN);
    end if;

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
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
)
IS
   l_row_id    varchar2(25);
BEGIN

/*
    oe_debug_pub.add('reached here_b ......................................');
    oe_debug_pub.add('prc_context_id=' || p_CON_rec.prc_context_id);
    oe_debug_pub.add('prc_context_code=' || p_CON_rec.prc_context_code);
    oe_debug_pub.add('prc_context_type=' || p_CON_rec.prc_context_type);
    oe_debug_pub.add('seeded_flag=' || p_CON_rec.seeded_flag);
    oe_debug_pub.add('enabled_flag=' || p_CON_rec.enabled_flag);
    oe_debug_pub.add('created_by=' || p_CON_rec.created_by);
    oe_debug_pub.add('creation_date=' || p_CON_rec.creation_date);
    oe_debug_pub.add('last_update_date=' || p_CON_rec.last_update_date);
    oe_debug_pub.add('last_updated_by=' || p_CON_rec.last_updated_by);
*/

    INSERT  INTO QP_PRC_CONTEXTS_b
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
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_code
    ,       PRC_CONTEXT_ID
    ,       PRC_CONTEXT_TYPE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_FLAG
    )
    VALUES
    (       p_CON_rec.attribute1
    ,       p_CON_rec.attribute10
    ,       p_CON_rec.attribute11
    ,       p_CON_rec.attribute12
    ,       p_CON_rec.attribute13
    ,       p_CON_rec.attribute14
    ,       p_CON_rec.attribute15
    ,       p_CON_rec.attribute2
    ,       p_CON_rec.attribute3
    ,       p_CON_rec.attribute4
    ,       p_CON_rec.attribute5
    ,       p_CON_rec.attribute6
    ,       p_CON_rec.attribute7
    ,       p_CON_rec.attribute8
    ,       p_CON_rec.attribute9
    ,       p_CON_rec.context
    ,       p_CON_rec.created_by
    ,       p_CON_rec.creation_date
    ,       p_CON_rec.enabled_flag
    ,       p_CON_rec.last_updated_by
    ,       p_CON_rec.last_update_date
    ,       p_CON_rec.last_update_login
    ,       p_CON_rec.prc_context_code
    ,       p_CON_rec.prc_context_id
    ,       p_CON_rec.prc_context_type
    ,       p_CON_rec.program_application_id
    ,       p_CON_rec.program_id
    ,       p_CON_rec.program_update_date
    ,       p_CON_rec.seeded_flag
    );

    INSERT  INTO qp_prc_contexts_tl
    (       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       prc_context_id
    ,       seeded_prc_context_name
    ,       user_prc_context_name
    ,       seeded_description
    ,       user_description
    ,       language
    ,       source_lang
    )
    SELECT  p_CON_rec.created_by
    ,       p_CON_rec.creation_date
    ,       p_CON_rec.last_updated_by
    ,       p_CON_rec.last_update_date
    ,       p_CON_rec.last_update_login
    ,       p_CON_rec.prc_context_id
    ,       p_CON_rec.seeded_prc_context_name
    ,       p_CON_rec.user_prc_context_name
    ,       p_CON_rec.seeded_description
    ,       p_CON_rec.user_description
    ,       L.language_code
    ,       userenv('LANG')
    from  FND_LANGUAGES  L
    where  L.INSTALLED_FLAG in ('I', 'B')
    and    not exists
           ( select NULL
             from  qp_prc_contexts_tl T
             where  T.prc_context_id = p_CON_rec.prc_context_id
             and  T.LANGUAGE = L.LANGUAGE_CODE );

    -- Abhijit : Add Pricing Attribute type Context to flexfield.
    if p_CON_rec.prc_context_type = 'PRICING_ATTRIBUTE' then
      FND_DESCR_FLEX_CONTEXTS_PKG.INSERT_ROW(
          X_ROWID => l_row_id,
          X_APPLICATION_ID => 661, --:CONTEXT.APPLICATION_ID,
          X_DESCRIPTIVE_FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
          X_DESCRIPTIVE_FLEX_CONTEXT_COD => p_CON_rec.prc_context_code,
          X_ENABLED_FLAG => p_CON_rec.ENABLED_FLAG,
          X_GLOBAL_FLAG => 'N',
          X_DESCRIPTION => substr(p_CON_rec.user_description,1,240),
          X_DESCRIPTIVE_FLEX_CONTEXT_NAM => substr(p_CON_rec.user_prc_context_name,1,80),
          X_CREATION_DATE => p_CON_rec.CREATION_DATE,
          X_CREATED_BY => p_CON_rec.CREATED_BY,
          X_LAST_UPDATE_DATE => p_CON_rec.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY => p_CON_rec.LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN => p_CON_rec.LAST_UPDATE_LOGIN);
    end if;

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
(   p_prc_context_id                IN  NUMBER
)
IS
   l_qp_prc_contexts_rec     qp_prc_contexts_b%rowtype;
BEGIN
      select *
      into l_qp_prc_contexts_rec
      from qp_prc_contexts_b
      where prc_context_id =  p_prc_context_id;
      --
    DELETE  FROM QP_PRC_CONTEXTS_tl
    WHERE   PRC_CONTEXT_ID = p_prc_context_id ;
    DELETE  FROM QP_PRC_CONTEXTS_b
    WHERE   PRC_CONTEXT_ID = p_prc_context_id ;

    -- Added by Abhijit. Create Pricing Contexts in Flex field
    --
    if l_qp_prc_contexts_rec.prc_context_type = 'PRICING_ATTRIBUTE' and
       l_qp_prc_contexts_rec.seeded_flag = 'N' then

      begin
        FND_DESCR_FLEX_CONTEXTS_PKG.DELETE_ROW(
          X_APPLICATION_ID => 661, --:CONTEXT.APPLICATION_ID,
          X_DESCRIPTIVE_FLEXFIELD_NAME => 'QP_ATTR_DEFNS_PRICING',
          X_DESCRIPTIVE_FLEX_CONTEXT_COD => l_qp_prc_contexts_rec.prc_context_code);
      exception
        when no_data_found then
          null;
      end;
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
(   p_prc_context_id                IN  NUMBER
) RETURN QP_Attributes_PUB.Con_Rec_Type
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
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
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_code
    ,       PRC_CONTEXT_ID
    ,       PRC_CONTEXT_TYPE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_DESCRIPTION
    ,       SEEDED_FLAG
    ,       SEEDED_PRC_CONTEXT_NAME
    ,       USER_DESCRIPTION
    ,       USER_PRC_CONTEXT_NAME
    INTO    l_CON_rec.attribute1
    ,       l_CON_rec.attribute10
    ,       l_CON_rec.attribute11
    ,       l_CON_rec.attribute12
    ,       l_CON_rec.attribute13
    ,       l_CON_rec.attribute14
    ,       l_CON_rec.attribute15
    ,       l_CON_rec.attribute2
    ,       l_CON_rec.attribute3
    ,       l_CON_rec.attribute4
    ,       l_CON_rec.attribute5
    ,       l_CON_rec.attribute6
    ,       l_CON_rec.attribute7
    ,       l_CON_rec.attribute8
    ,       l_CON_rec.attribute9
    ,       l_CON_rec.context
    ,       l_CON_rec.created_by
    ,       l_CON_rec.creation_date
    ,       l_CON_rec.enabled_flag
    ,       l_CON_rec.last_updated_by
    ,       l_CON_rec.last_update_date
    ,       l_CON_rec.last_update_login
    ,       l_CON_rec.prc_context_code
    ,       l_CON_rec.prc_context_id
    ,       l_CON_rec.prc_context_type
    ,       l_CON_rec.program_application_id
    ,       l_CON_rec.program_id
    ,       l_CON_rec.program_update_date
    ,       l_CON_rec.seeded_description
    ,       l_CON_rec.seeded_flag
    ,       l_CON_rec.seeded_prc_context_name
    ,       l_CON_rec.user_description
    ,       l_CON_rec.user_prc_context_name
    FROM    QP_PRC_CONTEXTS_V
    WHERE   PRC_CONTEXT_ID = p_prc_context_id
    ;

    RETURN l_CON_rec;

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
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
)
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
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
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       ENABLED_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRC_CONTEXT_code
    ,       PRC_CONTEXT_ID
    ,       PRC_CONTEXT_TYPE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       SEEDED_DESCRIPTION
    ,       SEEDED_FLAG
    ,       SEEDED_PRC_CONTEXT_NAME
    ,       USER_DESCRIPTION
    ,       USER_PRC_CONTEXT_NAME
    INTO    l_CON_rec.attribute1
    ,       l_CON_rec.attribute10
    ,       l_CON_rec.attribute11
    ,       l_CON_rec.attribute12
    ,       l_CON_rec.attribute13
    ,       l_CON_rec.attribute14
    ,       l_CON_rec.attribute15
    ,       l_CON_rec.attribute2
    ,       l_CON_rec.attribute3
    ,       l_CON_rec.attribute4
    ,       l_CON_rec.attribute5
    ,       l_CON_rec.attribute6
    ,       l_CON_rec.attribute7
    ,       l_CON_rec.attribute8
    ,       l_CON_rec.attribute9
    ,       l_CON_rec.context
    ,       l_CON_rec.created_by
    ,       l_CON_rec.creation_date
    ,       l_CON_rec.enabled_flag
    ,       l_CON_rec.last_updated_by
    ,       l_CON_rec.last_update_date
    ,       l_CON_rec.last_update_login
    ,       l_CON_rec.prc_context_code
    ,       l_CON_rec.prc_context_id
    ,       l_CON_rec.prc_context_type
    ,       l_CON_rec.program_application_id
    ,       l_CON_rec.program_id
    ,       l_CON_rec.program_update_date
    ,       l_CON_rec.seeded_description
    ,       l_CON_rec.seeded_flag
    ,       l_CON_rec.seeded_prc_context_name
    ,       l_CON_rec.user_description
    ,       l_CON_rec.user_prc_context_name
    FROM    QP_PRC_CONTEXTS_V
    WHERE   PRC_CONTEXT_ID = p_CON_rec.prc_context_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_CON_rec.attribute1,
                         l_CON_rec.attribute1)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute10,
                         l_CON_rec.attribute10)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute11,
                         l_CON_rec.attribute11)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute12,
                         l_CON_rec.attribute12)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute13,
                         l_CON_rec.attribute13)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute14,
                         l_CON_rec.attribute14)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute15,
                         l_CON_rec.attribute15)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute2,
                         l_CON_rec.attribute2)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute3,
                         l_CON_rec.attribute3)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute4,
                         l_CON_rec.attribute4)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute5,
                         l_CON_rec.attribute5)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute6,
                         l_CON_rec.attribute6)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute7,
                         l_CON_rec.attribute7)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute8,
                         l_CON_rec.attribute8)
    AND QP_GLOBALS.Equal(p_CON_rec.attribute9,
                         l_CON_rec.attribute9)
    AND QP_GLOBALS.Equal(p_CON_rec.context,
                         l_CON_rec.context)
    AND QP_GLOBALS.Equal(p_CON_rec.created_by,
                         l_CON_rec.created_by)
    AND QP_GLOBALS.Equal(p_CON_rec.creation_date,
                         l_CON_rec.creation_date)
    AND QP_GLOBALS.Equal(p_CON_rec.enabled_flag,
                         l_CON_rec.enabled_flag)
    AND QP_GLOBALS.Equal(p_CON_rec.last_updated_by,
                         l_CON_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_CON_rec.last_update_date,
                         l_CON_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_CON_rec.last_update_login,
                         l_CON_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_CON_rec.prc_context_code,
                         l_CON_rec.prc_context_code)
    AND QP_GLOBALS.Equal(p_CON_rec.prc_context_id,
                         l_CON_rec.prc_context_id)
    AND QP_GLOBALS.Equal(p_CON_rec.prc_context_type,
                         l_CON_rec.prc_context_type)
    AND QP_GLOBALS.Equal(p_CON_rec.program_application_id,
                         l_CON_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_CON_rec.program_id,
                         l_CON_rec.program_id)
    AND QP_GLOBALS.Equal(p_CON_rec.program_update_date,
                         l_CON_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_CON_rec.seeded_description,
                         l_CON_rec.seeded_description)
    AND QP_GLOBALS.Equal(p_CON_rec.seeded_flag,
                         l_CON_rec.seeded_flag)
    AND QP_GLOBALS.Equal(p_CON_rec.seeded_prc_context_name,
                         l_CON_rec.seeded_prc_context_name)
    AND QP_GLOBALS.Equal(p_CON_rec.user_description,
                         l_CON_rec.user_description)
    AND QP_GLOBALS.Equal(p_CON_rec.user_prc_context_name,
                         l_CON_rec.user_prc_context_name)
    THEN

        --  Row has not changed. Set out parameter.

        x_CON_rec                      := l_CON_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_CON_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CON_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CON_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_CON_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CON_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
) RETURN QP_Attributes_PUB.Con_Val_Rec_Type
IS
l_CON_val_rec                 QP_Attributes_PUB.Con_Val_Rec_Type;
BEGIN

    IF p_CON_rec.enabled_flag IS NOT NULL AND
        p_CON_rec.enabled_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_CON_rec.enabled_flag,
        p_old_CON_rec.enabled_flag)
    THEN
        l_CON_val_rec.enabled := QP_Id_To_Value.Enabled
        (   p_enabled_flag                => p_CON_rec.enabled_flag
        );
    END IF;

    IF p_CON_rec.prc_context_id IS NOT NULL AND
        p_CON_rec.prc_context_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_CON_rec.prc_context_id,
        p_old_CON_rec.prc_context_id)
    THEN
        l_CON_val_rec.prc_context := QP_Id_To_Value.Prc_Context
        (   p_prc_context_id              => p_CON_rec.prc_context_id
        );
    END IF;

    IF p_CON_rec.seeded_flag IS NOT NULL AND
        p_CON_rec.seeded_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_CON_rec.seeded_flag,
        p_old_CON_rec.seeded_flag)
    THEN
        l_CON_val_rec.seeded := QP_Id_To_Value.Seeded
        (   p_seeded_flag                 => p_CON_rec.seeded_flag
        );
    END IF;

    RETURN l_CON_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_CON_val_rec                   IN  QP_Attributes_PUB.Con_Val_Rec_Type
) RETURN QP_Attributes_PUB.Con_Rec_Type
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_CON_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_CON_rec.

    l_CON_rec := p_CON_rec;

    IF  p_CON_val_rec.enabled <> FND_API.G_MISS_CHAR
    THEN

        IF p_CON_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN

            l_CON_rec.enabled_flag := p_CON_rec.enabled_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CON_rec.enabled_flag := QP_Value_To_Id.enabled
            (   p_enabled                     => p_CON_val_rec.enabled
            );

            IF l_CON_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
                l_CON_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CON_val_rec.prc_context <> FND_API.G_MISS_CHAR
    THEN

        IF p_CON_rec.prc_context_id <> FND_API.G_MISS_NUM THEN

            l_CON_rec.prc_context_id := p_CON_rec.prc_context_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CON_rec.prc_context_id := QP_Value_To_Id.prc_context
            (   p_prc_context                 => p_CON_val_rec.prc_context
            );

            IF l_CON_rec.prc_context_id = FND_API.G_MISS_NUM THEN
                l_CON_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_CON_val_rec.seeded <> FND_API.G_MISS_CHAR
    THEN

        IF p_CON_rec.seeded_flag <> FND_API.G_MISS_CHAR THEN

            l_CON_rec.seeded_flag := p_CON_rec.seeded_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_CON_rec.seeded_flag := QP_Value_To_Id.seeded
            (   p_seeded                      => p_CON_val_rec.seeded
            );

            IF l_CON_rec.seeded_flag = FND_API.G_MISS_CHAR THEN
                l_CON_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_CON_rec;

END Get_Ids;

END QP_Con_Util;

/

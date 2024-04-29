--------------------------------------------------------
--  DDL for Package Body QP_PSG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PSG_UTIL" AS
/* $Header: QPXUPSGB.pls 120.1 2005/06/12 23:45:47 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Psg_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
,   x_PSG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PSG_rec := p_PSG_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute1,p_old_PSG_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute10,p_old_PSG_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute11,p_old_PSG_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute12,p_old_PSG_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute13,p_old_PSG_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute14,p_old_PSG_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute15,p_old_PSG_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute2,p_old_PSG_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute3,p_old_PSG_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute4,p_old_PSG_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute5,p_old_PSG_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute6,p_old_PSG_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute7,p_old_PSG_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute8,p_old_PSG_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute9,p_old_PSG_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.context,p_old_PSG_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.created_by,p_old_PSG_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.creation_date,p_old_PSG_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_updated_by,p_old_PSG_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_update_date,p_old_PSG_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_update_login,p_old_PSG_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.limits_enabled,p_old_PSG_rec.limits_enabled)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LIMITS_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.lov_enabled,p_old_PSG_rec.lov_enabled)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LOV_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_application_id,p_old_PSG_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_id,p_old_PSG_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_update_date,p_old_PSG_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.pte_code,p_old_PSG_rec.pte_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.seeded_sourcing_method,p_old_PSG_rec.seeded_sourcing_method)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEEDED_SOURCING_METHOD;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_id,p_old_PSG_rec.segment_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_level,p_old_PSG_rec.segment_level)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT_LEVEL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_pte_id,p_old_PSG_rec.segment_pte_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT_PTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.sourcing_enabled,p_old_PSG_rec.sourcing_enabled)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SOURCING_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.sourcing_status,p_old_PSG_rec.sourcing_status)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SOURCING_STATUS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PSG_rec.user_sourcing_method,p_old_PSG_rec.user_sourcing_method)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_USER_SOURCING_METHOD;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIMITS_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LIMITS_ENABLED;
    ELSIF p_attr_id = G_LOV_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_LOV_ENABLED;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_PTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_PTE;
    ELSIF p_attr_id = G_SEEDED_SOURCING_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEEDED_SOURCING_METHOD;
    ELSIF p_attr_id = G_SEGMENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT;
    ELSIF p_attr_id = G_SEGMENT_LEVEL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT_LEVEL;
    ELSIF p_attr_id = G_SEGMENT_PTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SEGMENT_PTE;
    ELSIF p_attr_id = G_SOURCING_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SOURCING_ENABLED;
    ELSIF p_attr_id = G_SOURCING_STATUS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_SOURCING_STATUS;
    ELSIF p_attr_id = G_USER_SOURCING_METHOD THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PSG_UTIL.G_USER_SOURCING_METHOD;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
,   x_PSG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_PSG_rec := p_PSG_rec;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute1,p_old_PSG_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute10,p_old_PSG_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute11,p_old_PSG_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute12,p_old_PSG_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute13,p_old_PSG_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute14,p_old_PSG_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute15,p_old_PSG_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute2,p_old_PSG_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute3,p_old_PSG_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute4,p_old_PSG_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute5,p_old_PSG_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute6,p_old_PSG_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute7,p_old_PSG_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute8,p_old_PSG_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.attribute9,p_old_PSG_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.context,p_old_PSG_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.created_by,p_old_PSG_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.creation_date,p_old_PSG_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_updated_by,p_old_PSG_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_update_date,p_old_PSG_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.last_update_login,p_old_PSG_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.limits_enabled,p_old_PSG_rec.limits_enabled)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.lov_enabled,p_old_PSG_rec.lov_enabled)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_application_id,p_old_PSG_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_id,p_old_PSG_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.program_update_date,p_old_PSG_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.pte_code,p_old_PSG_rec.pte_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.seeded_sourcing_method,p_old_PSG_rec.seeded_sourcing_method)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_id,p_old_PSG_rec.segment_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_level,p_old_PSG_rec.segment_level)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.segment_pte_id,p_old_PSG_rec.segment_pte_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.sourcing_enabled,p_old_PSG_rec.sourcing_enabled)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.sourcing_status,p_old_PSG_rec.sourcing_status)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PSG_rec.user_sourcing_method,p_old_PSG_rec.user_sourcing_method)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type
) RETURN QP_Attr_Map_PUB.Psg_Rec_Type
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type := p_PSG_rec;
BEGIN

    IF l_PSG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute1 := p_old_PSG_rec.attribute1;
    END IF;

    IF l_PSG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute10 := p_old_PSG_rec.attribute10;
    END IF;

    IF l_PSG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute11 := p_old_PSG_rec.attribute11;
    END IF;

    IF l_PSG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute12 := p_old_PSG_rec.attribute12;
    END IF;

    IF l_PSG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute13 := p_old_PSG_rec.attribute13;
    END IF;

    IF l_PSG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute14 := p_old_PSG_rec.attribute14;
    END IF;

    IF l_PSG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute15 := p_old_PSG_rec.attribute15;
    END IF;

    IF l_PSG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute2 := p_old_PSG_rec.attribute2;
    END IF;

    IF l_PSG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute3 := p_old_PSG_rec.attribute3;
    END IF;

    IF l_PSG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute4 := p_old_PSG_rec.attribute4;
    END IF;

    IF l_PSG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute5 := p_old_PSG_rec.attribute5;
    END IF;

    IF l_PSG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute6 := p_old_PSG_rec.attribute6;
    END IF;

    IF l_PSG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute7 := p_old_PSG_rec.attribute7;
    END IF;

    IF l_PSG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute8 := p_old_PSG_rec.attribute8;
    END IF;

    IF l_PSG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute9 := p_old_PSG_rec.attribute9;
    END IF;

    IF l_PSG_rec.context = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.context := p_old_PSG_rec.context;
    END IF;

    IF l_PSG_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PSG_rec.created_by := p_old_PSG_rec.created_by;
    END IF;

    IF l_PSG_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.creation_date := p_old_PSG_rec.creation_date;
    END IF;

    IF l_PSG_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PSG_rec.last_updated_by := p_old_PSG_rec.last_updated_by;
    END IF;

    IF l_PSG_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.last_update_date := p_old_PSG_rec.last_update_date;
    END IF;

    IF l_PSG_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PSG_rec.last_update_login := p_old_PSG_rec.last_update_login;
    END IF;

    IF l_PSG_rec.limits_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.limits_enabled := p_old_PSG_rec.limits_enabled;
    END IF;

    IF l_PSG_rec.lov_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.lov_enabled := p_old_PSG_rec.lov_enabled;
    END IF;

    IF l_PSG_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.program_application_id := p_old_PSG_rec.program_application_id;
    END IF;

    IF l_PSG_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.program_id := p_old_PSG_rec.program_id;
    END IF;

    IF l_PSG_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.program_update_date := p_old_PSG_rec.program_update_date;
    END IF;

    IF l_PSG_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.pte_code := p_old_PSG_rec.pte_code;
    END IF;

    IF l_PSG_rec.seeded_sourcing_method = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.seeded_sourcing_method := p_old_PSG_rec.seeded_sourcing_method;
    END IF;

    IF l_PSG_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.segment_id := p_old_PSG_rec.segment_id;
    END IF;

    IF l_PSG_rec.segment_level = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.segment_level := p_old_PSG_rec.segment_level;
    END IF;

    IF l_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.segment_pte_id := p_old_PSG_rec.segment_pte_id;
    END IF;

    IF l_PSG_rec.sourcing_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.sourcing_enabled := p_old_PSG_rec.sourcing_enabled;
    END IF;

    IF l_PSG_rec.sourcing_status = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.sourcing_status := p_old_PSG_rec.sourcing_status;
    END IF;

    IF l_PSG_rec.user_sourcing_method = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.user_sourcing_method := p_old_PSG_rec.user_sourcing_method;
    END IF;

    RETURN l_PSG_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
) RETURN QP_Attr_Map_PUB.Psg_Rec_Type
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type := p_PSG_rec;
BEGIN

    IF l_PSG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute1 := NULL;
    END IF;

    IF l_PSG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute10 := NULL;
    END IF;

    IF l_PSG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute11 := NULL;
    END IF;

    IF l_PSG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute12 := NULL;
    END IF;

    IF l_PSG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute13 := NULL;
    END IF;

    IF l_PSG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute14 := NULL;
    END IF;

    IF l_PSG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute15 := NULL;
    END IF;

    IF l_PSG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute2 := NULL;
    END IF;

    IF l_PSG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute3 := NULL;
    END IF;

    IF l_PSG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute4 := NULL;
    END IF;

    IF l_PSG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute5 := NULL;
    END IF;

    IF l_PSG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute6 := NULL;
    END IF;

    IF l_PSG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute7 := NULL;
    END IF;

    IF l_PSG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute8 := NULL;
    END IF;

    IF l_PSG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.attribute9 := NULL;
    END IF;

    IF l_PSG_rec.context = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.context := NULL;
    END IF;

    IF l_PSG_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PSG_rec.created_by := NULL;
    END IF;

    IF l_PSG_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.creation_date := NULL;
    END IF;

    IF l_PSG_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PSG_rec.last_updated_by := NULL;
    END IF;

    IF l_PSG_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.last_update_date := NULL;
    END IF;

    IF l_PSG_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PSG_rec.last_update_login := NULL;
    END IF;

    IF l_PSG_rec.limits_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.limits_enabled := NULL;
    END IF;

    IF l_PSG_rec.lov_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.lov_enabled := NULL;
    END IF;

    IF l_PSG_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.program_application_id := NULL;
    END IF;

    IF l_PSG_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.program_id := NULL;
    END IF;

    IF l_PSG_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PSG_rec.program_update_date := NULL;
    END IF;

    IF l_PSG_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.pte_code := NULL;
    END IF;

    IF l_PSG_rec.seeded_sourcing_method = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.seeded_sourcing_method := NULL;
    END IF;

    IF l_PSG_rec.segment_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.segment_id := NULL;
    END IF;

    IF l_PSG_rec.segment_level = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.segment_level := NULL;
    END IF;

    IF l_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM THEN
        l_PSG_rec.segment_pte_id := NULL;
    END IF;

    IF l_PSG_rec.sourcing_enabled = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.sourcing_enabled := NULL;
    END IF;

    IF l_PSG_rec.sourcing_status = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.sourcing_status := NULL;
    END IF;

    IF l_PSG_rec.user_sourcing_method = FND_API.G_MISS_CHAR THEN
        l_PSG_rec.user_sourcing_method := NULL;
    END IF;

    RETURN l_PSG_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
BEGIN

    UPDATE  QP_PTE_SEGMENTS
    SET     ATTRIBUTE1                     = p_PSG_rec.attribute1
    ,       ATTRIBUTE10                    = p_PSG_rec.attribute10
    ,       ATTRIBUTE11                    = p_PSG_rec.attribute11
    ,       ATTRIBUTE12                    = p_PSG_rec.attribute12
    ,       ATTRIBUTE13                    = p_PSG_rec.attribute13
    ,       ATTRIBUTE14                    = p_PSG_rec.attribute14
    ,       ATTRIBUTE15                    = p_PSG_rec.attribute15
    ,       ATTRIBUTE2                     = p_PSG_rec.attribute2
    ,       ATTRIBUTE3                     = p_PSG_rec.attribute3
    ,       ATTRIBUTE4                     = p_PSG_rec.attribute4
    ,       ATTRIBUTE5                     = p_PSG_rec.attribute5
    ,       ATTRIBUTE6                     = p_PSG_rec.attribute6
    ,       ATTRIBUTE7                     = p_PSG_rec.attribute7
    ,       ATTRIBUTE8                     = p_PSG_rec.attribute8
    ,       ATTRIBUTE9                     = p_PSG_rec.attribute9
    ,       CONTEXT                        = p_PSG_rec.context
    ,       CREATED_BY                     = p_PSG_rec.created_by
    ,       CREATION_DATE                  = p_PSG_rec.creation_date
    ,       LAST_UPDATED_BY                = p_PSG_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_PSG_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_PSG_rec.last_update_login
    ,       LIMITS_ENABLED                 = p_PSG_rec.limits_enabled
    ,       LOV_ENABLED                    = p_PSG_rec.lov_enabled
    ,       PROGRAM_APPLICATION_ID         = p_PSG_rec.program_application_id
    ,       PROGRAM_ID                     = p_PSG_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PSG_rec.program_update_date
    ,       PTE_CODE                       = p_PSG_rec.pte_code
    ,       SEEDED_SOURCING_METHOD         = p_PSG_rec.seeded_sourcing_method
    ,       SEGMENT_ID                     = p_PSG_rec.segment_id
    ,       SEGMENT_LEVEL                  = p_PSG_rec.segment_level
    ,       SEGMENT_PTE_ID                 = p_PSG_rec.segment_pte_id
    ,       SOURCING_ENABLED               = p_PSG_rec.sourcing_enabled
    ,       SOURCING_STATUS                = p_PSG_rec.sourcing_status
    ,       USER_SOURCING_METHOD           = p_PSG_rec.user_sourcing_method
    WHERE   SEGMENT_PTE_ID = p_PSG_rec.segment_pte_id
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
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
BEGIN
    oe_debug_pub.add('inserting data in psg ..............................');

    INSERT  INTO QP_PTE_SEGMENTS
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMITS_ENABLED
    ,       LOV_ENABLED
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_CODE
    ,       SEEDED_SOURCING_METHOD
    ,       SEGMENT_ID
    ,       SEGMENT_LEVEL
    ,       SEGMENT_PTE_ID
    ,       SOURCING_ENABLED
    ,       SOURCING_STATUS
    ,       USER_SOURCING_METHOD
    )
    VALUES
    (       p_PSG_rec.attribute1
    ,       p_PSG_rec.attribute10
    ,       p_PSG_rec.attribute11
    ,       p_PSG_rec.attribute12
    ,       p_PSG_rec.attribute13
    ,       p_PSG_rec.attribute14
    ,       p_PSG_rec.attribute15
    ,       p_PSG_rec.attribute2
    ,       p_PSG_rec.attribute3
    ,       p_PSG_rec.attribute4
    ,       p_PSG_rec.attribute5
    ,       p_PSG_rec.attribute6
    ,       p_PSG_rec.attribute7
    ,       p_PSG_rec.attribute8
    ,       p_PSG_rec.attribute9
    ,       p_PSG_rec.context
    ,       p_PSG_rec.created_by
    ,       p_PSG_rec.creation_date
    ,       p_PSG_rec.last_updated_by
    ,       p_PSG_rec.last_update_date
    ,       p_PSG_rec.last_update_login
    ,       p_PSG_rec.limits_enabled
    ,       p_PSG_rec.lov_enabled
    ,       p_PSG_rec.program_application_id
    ,       p_PSG_rec.program_id
    ,       p_PSG_rec.program_update_date
    ,       p_PSG_rec.pte_code
    ,       p_PSG_rec.seeded_sourcing_method
    ,       p_PSG_rec.segment_id
    ,       p_PSG_rec.segment_level
    ,       p_PSG_rec.segment_pte_id
    ,       p_PSG_rec.sourcing_enabled
    ,       p_PSG_rec.sourcing_status
    ,       p_PSG_rec.user_sourcing_method
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
(   p_segment_pte_id                IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_PTE_SEGMENTS
    WHERE   SEGMENT_PTE_ID = p_segment_pte_id
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
(   p_segment_pte_id                IN  NUMBER
) RETURN QP_Attr_Map_PUB.Psg_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_segment_pte_id              => p_segment_pte_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_segment_pte_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
) RETURN QP_Attr_Map_PUB.Psg_Tbl_Type
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;

CURSOR l_PSG_csr IS
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMITS_ENABLED
    ,       LOV_ENABLED
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_CODE
    ,       SEEDED_SOURCING_METHOD
    ,       SEGMENT_ID
    ,       SEGMENT_LEVEL
    ,       SEGMENT_PTE_ID
    ,       SOURCING_ENABLED
    ,       SOURCING_STATUS
    ,       USER_SOURCING_METHOD
    FROM    QP_PTE_SEGMENTS
    WHERE ( SEGMENT_PTE_ID = p_segment_pte_id
    )
    --**OR (    LOOKUP_CODE = p_lookup_code
    OR (    PTE_CODE = p_lookup_code
    );

BEGIN

    IF
    (p_segment_pte_id IS NOT NULL
     AND
     p_segment_pte_id <> FND_API.G_MISS_NUM)
    AND
    (p_lookup_code IS NOT NULL
     AND
     p_lookup_code <> FND_API.G_MISS_CHAR)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: segment_pte_id = '|| p_segment_pte_id || ', lookup_code = '|| p_lookup_code
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_PSG_csr LOOP

        l_PSG_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_PSG_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_PSG_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_PSG_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_PSG_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_PSG_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_PSG_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_PSG_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_PSG_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_PSG_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_PSG_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_PSG_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_PSG_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_PSG_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_PSG_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_PSG_rec.context              := l_implicit_rec.CONTEXT;
        l_PSG_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_PSG_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_PSG_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_PSG_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_PSG_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PSG_rec.limits_enabled       := l_implicit_rec.LIMITS_ENABLED;
        l_PSG_rec.lov_enabled          := l_implicit_rec.LOV_ENABLED;
        l_PSG_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PSG_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_PSG_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PSG_rec.pte_code             := l_implicit_rec.PTE_CODE;
        l_PSG_rec.seeded_sourcing_method := l_implicit_rec.SEEDED_SOURCING_METHOD;
        l_PSG_rec.segment_id           := l_implicit_rec.SEGMENT_ID;
        l_PSG_rec.segment_level        := l_implicit_rec.SEGMENT_LEVEL;
        l_PSG_rec.segment_pte_id       := l_implicit_rec.SEGMENT_PTE_ID;
        l_PSG_rec.sourcing_enabled     := l_implicit_rec.SOURCING_ENABLED;
        l_PSG_rec.sourcing_status      := l_implicit_rec.SOURCING_STATUS;
        l_PSG_rec.user_sourcing_method := l_implicit_rec.USER_SOURCING_METHOD;

        l_PSG_tbl(l_PSG_tbl.COUNT + 1) := l_PSG_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_segment_pte_id IS NOT NULL
     AND
     p_segment_pte_id <> FND_API.G_MISS_NUM)
    AND
    (l_PSG_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_PSG_tbl;

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
,   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   x_PSG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIMITS_ENABLED
    ,       LOV_ENABLED
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PTE_CODE
    ,       SEEDED_SOURCING_METHOD
    ,       SEGMENT_ID
    ,       SEGMENT_LEVEL
    ,       SEGMENT_PTE_ID
    ,       SOURCING_ENABLED
    ,       SOURCING_STATUS
    ,       USER_SOURCING_METHOD
    INTO    l_PSG_rec.attribute1
    ,       l_PSG_rec.attribute10
    ,       l_PSG_rec.attribute11
    ,       l_PSG_rec.attribute12
    ,       l_PSG_rec.attribute13
    ,       l_PSG_rec.attribute14
    ,       l_PSG_rec.attribute15
    ,       l_PSG_rec.attribute2
    ,       l_PSG_rec.attribute3
    ,       l_PSG_rec.attribute4
    ,       l_PSG_rec.attribute5
    ,       l_PSG_rec.attribute6
    ,       l_PSG_rec.attribute7
    ,       l_PSG_rec.attribute8
    ,       l_PSG_rec.attribute9
    ,       l_PSG_rec.context
    ,       l_PSG_rec.created_by
    ,       l_PSG_rec.creation_date
    ,       l_PSG_rec.last_updated_by
    ,       l_PSG_rec.last_update_date
    ,       l_PSG_rec.last_update_login
    ,       l_PSG_rec.limits_enabled
    ,       l_PSG_rec.lov_enabled
    ,       l_PSG_rec.program_application_id
    ,       l_PSG_rec.program_id
    ,       l_PSG_rec.program_update_date
    ,       l_PSG_rec.pte_code
    ,       l_PSG_rec.seeded_sourcing_method
    ,       l_PSG_rec.segment_id
    ,       l_PSG_rec.segment_level
    ,       l_PSG_rec.segment_pte_id
    ,       l_PSG_rec.sourcing_enabled
    ,       l_PSG_rec.sourcing_status
    ,       l_PSG_rec.user_sourcing_method
    FROM    QP_PTE_SEGMENTS
    WHERE   SEGMENT_PTE_ID = p_PSG_rec.segment_pte_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_PSG_rec.attribute1,
                         l_PSG_rec.attribute1)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute10,
                         l_PSG_rec.attribute10)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute11,
                         l_PSG_rec.attribute11)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute12,
                         l_PSG_rec.attribute12)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute13,
                         l_PSG_rec.attribute13)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute14,
                         l_PSG_rec.attribute14)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute15,
                         l_PSG_rec.attribute15)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute2,
                         l_PSG_rec.attribute2)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute3,
                         l_PSG_rec.attribute3)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute4,
                         l_PSG_rec.attribute4)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute5,
                         l_PSG_rec.attribute5)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute6,
                         l_PSG_rec.attribute6)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute7,
                         l_PSG_rec.attribute7)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute8,
                         l_PSG_rec.attribute8)
    AND QP_GLOBALS.Equal(p_PSG_rec.attribute9,
                         l_PSG_rec.attribute9)
    AND QP_GLOBALS.Equal(p_PSG_rec.context,
                         l_PSG_rec.context)
    AND QP_GLOBALS.Equal(p_PSG_rec.created_by,
                         l_PSG_rec.created_by)
    AND QP_GLOBALS.Equal(p_PSG_rec.creation_date,
                         l_PSG_rec.creation_date)
    AND QP_GLOBALS.Equal(p_PSG_rec.last_updated_by,
                         l_PSG_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_PSG_rec.last_update_date,
                         l_PSG_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_PSG_rec.last_update_login,
                         l_PSG_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_PSG_rec.limits_enabled,
                         l_PSG_rec.limits_enabled)
    AND QP_GLOBALS.Equal(p_PSG_rec.lov_enabled,
                         l_PSG_rec.lov_enabled)
    AND QP_GLOBALS.Equal(p_PSG_rec.program_application_id,
                         l_PSG_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_PSG_rec.program_id,
                         l_PSG_rec.program_id)
    AND QP_GLOBALS.Equal(p_PSG_rec.program_update_date,
                         l_PSG_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_PSG_rec.pte_code,
                         l_PSG_rec.pte_code)
    AND QP_GLOBALS.Equal(p_PSG_rec.seeded_sourcing_method,
                         l_PSG_rec.seeded_sourcing_method)
    AND QP_GLOBALS.Equal(p_PSG_rec.segment_id,
                         l_PSG_rec.segment_id)
    AND QP_GLOBALS.Equal(p_PSG_rec.segment_level,
                         l_PSG_rec.segment_level)
    AND QP_GLOBALS.Equal(p_PSG_rec.segment_pte_id,
                         l_PSG_rec.segment_pte_id)
    AND QP_GLOBALS.Equal(p_PSG_rec.sourcing_enabled,
                         l_PSG_rec.sourcing_enabled)
    AND QP_GLOBALS.Equal(p_PSG_rec.sourcing_status,
                         l_PSG_rec.sourcing_status)
    AND QP_GLOBALS.Equal(p_PSG_rec.user_sourcing_method,
                         l_PSG_rec.user_sourcing_method)
    THEN

        --  Row has not changed. Set out parameter.

        x_PSG_rec                      := l_PSG_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PSG_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PSG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PSG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PSG_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PSG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_old_PSG_rec                   IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
) RETURN QP_Attr_Map_PUB.Psg_Val_Rec_Type
IS
l_PSG_val_rec                 QP_Attr_Map_PUB.Psg_Val_Rec_Type;
BEGIN

    IF p_PSG_rec.pte_code IS NOT NULL AND
        p_PSG_rec.pte_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PSG_rec.pte_code,
        p_old_PSG_rec.pte_code)
    THEN
        l_PSG_val_rec.pte := QP_Id_To_Value.Pte
        (   p_pte_code                    => p_PSG_rec.pte_code
        );
    END IF;

    IF p_PSG_rec.segment_id IS NOT NULL AND
        p_PSG_rec.segment_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PSG_rec.segment_id,
        p_old_PSG_rec.segment_id)
    THEN
        l_PSG_val_rec.segment := QP_Id_To_Value.Segment
        (   p_segment_id                  => p_PSG_rec.segment_id
        );
    END IF;

    IF p_PSG_rec.segment_pte_id IS NOT NULL AND
        p_PSG_rec.segment_pte_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PSG_rec.segment_pte_id,
        p_old_PSG_rec.segment_pte_id)
    THEN
        l_PSG_val_rec.segment_pte := QP_Id_To_Value.Segment_Pte
        (   p_segment_pte_id              => p_PSG_rec.segment_pte_id
        );
    END IF;

    RETURN l_PSG_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_PSG_val_rec                   IN  QP_Attr_Map_PUB.Psg_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Psg_Rec_Type
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PSG_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PSG_rec.

    l_PSG_rec := p_PSG_rec;

    IF  p_PSG_val_rec.pte <> FND_API.G_MISS_CHAR
    THEN

        IF p_PSG_rec.pte_code <> FND_API.G_MISS_CHAR THEN

            l_PSG_rec.pte_code := p_PSG_rec.pte_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PSG_rec.pte_code := QP_Value_To_Id.pte
            (   p_pte                         => p_PSG_val_rec.pte
            );

            IF l_PSG_rec.pte_code = FND_API.G_MISS_CHAR THEN
                l_PSG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PSG_val_rec.segment <> FND_API.G_MISS_CHAR
    THEN

        IF p_PSG_rec.segment_id <> FND_API.G_MISS_NUM THEN

            l_PSG_rec.segment_id := p_PSG_rec.segment_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            --**l_PSG_rec.segment_id := QP_Value_To_Id.segment
            --**(   p_segment                     => p_PSG_val_rec.segment
            --**);
            --** Added next line
            l_PSG_rec.segment_id := p_PSG_rec.segment_id;

            IF l_PSG_rec.segment_id = FND_API.G_MISS_NUM THEN
                l_PSG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PSG_val_rec.segment_pte <> FND_API.G_MISS_CHAR
    THEN

        IF p_PSG_rec.segment_pte_id <> FND_API.G_MISS_NUM THEN

            l_PSG_rec.segment_pte_id := p_PSG_rec.segment_pte_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_pte');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_PSG_rec.segment_pte_id := QP_Value_To_Id.segment_pte
            (   p_segment_pte                 => p_PSG_val_rec.segment_pte
            );

            IF l_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM THEN
                l_PSG_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PSG_rec;

END Get_Ids;

END QP_Psg_Util;

/

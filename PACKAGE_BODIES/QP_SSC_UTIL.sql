--------------------------------------------------------
--  DDL for Package Body QP_SSC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SSC_UTIL" AS
/* $Header: QPXUSSCB.pls 120.1 2005/06/14 00:16:11 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Ssc_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
,   x_SSC_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_SSC_rec := p_SSC_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.application_short_name,p_old_SSC_rec.application_short_name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_APPLICATION_SHORT_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute1,p_old_SSC_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute10,p_old_SSC_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute11,p_old_SSC_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute12,p_old_SSC_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute13,p_old_SSC_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute14,p_old_SSC_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute15,p_old_SSC_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute2,p_old_SSC_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute3,p_old_SSC_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute4,p_old_SSC_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute5,p_old_SSC_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute6,p_old_SSC_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute7,p_old_SSC_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute8,p_old_SSC_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute9,p_old_SSC_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.context,p_old_SSC_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.created_by,p_old_SSC_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.creation_date,p_old_SSC_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.enabled_flag,p_old_SSC_rec.enabled_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ENABLED;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_updated_by,p_old_SSC_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_update_date,p_old_SSC_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_update_login,p_old_SSC_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_application_id,p_old_SSC_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_id,p_old_SSC_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_update_date,p_old_SSC_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.pte_code,p_old_SSC_rec.pte_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_SSC_rec.pte_source_system_id,p_old_SSC_rec.pte_source_system_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PTE_SOURCE_SYSTEM;
        END IF;

    ELSIF p_attr_id = G_APPLICATION_SHORT_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_APPLICATION_SHORT_NAME;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_ENABLED THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_ENABLED;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_PTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PTE;
    ELSIF p_attr_id = G_PTE_SOURCE_SYSTEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_SSC_UTIL.G_PTE_SOURCE_SYSTEM;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
,   x_SSC_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_SSC_rec := p_SSC_rec;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.application_short_name,p_old_SSC_rec.application_short_name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute1,p_old_SSC_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute10,p_old_SSC_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute11,p_old_SSC_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute12,p_old_SSC_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute13,p_old_SSC_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute14,p_old_SSC_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute15,p_old_SSC_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute2,p_old_SSC_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute3,p_old_SSC_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute4,p_old_SSC_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute5,p_old_SSC_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute6,p_old_SSC_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute7,p_old_SSC_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute8,p_old_SSC_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.attribute9,p_old_SSC_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.context,p_old_SSC_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.created_by,p_old_SSC_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.creation_date,p_old_SSC_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.enabled_flag,p_old_SSC_rec.enabled_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_updated_by,p_old_SSC_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_update_date,p_old_SSC_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.last_update_login,p_old_SSC_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_application_id,p_old_SSC_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_id,p_old_SSC_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.program_update_date,p_old_SSC_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.pte_code,p_old_SSC_rec.pte_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_SSC_rec.pte_source_system_id,p_old_SSC_rec.pte_source_system_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type
) RETURN QP_Attr_Map_PUB.Ssc_Rec_Type
IS
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type := p_SSC_rec;
BEGIN

    IF l_SSC_rec.application_short_name = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.application_short_name := p_old_SSC_rec.application_short_name;
    END IF;

    IF l_SSC_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute1 := p_old_SSC_rec.attribute1;
    END IF;

    IF l_SSC_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute10 := p_old_SSC_rec.attribute10;
    END IF;

    IF l_SSC_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute11 := p_old_SSC_rec.attribute11;
    END IF;

    IF l_SSC_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute12 := p_old_SSC_rec.attribute12;
    END IF;

    IF l_SSC_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute13 := p_old_SSC_rec.attribute13;
    END IF;

    IF l_SSC_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute14 := p_old_SSC_rec.attribute14;
    END IF;

    IF l_SSC_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute15 := p_old_SSC_rec.attribute15;
    END IF;

    IF l_SSC_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute2 := p_old_SSC_rec.attribute2;
    END IF;

    IF l_SSC_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute3 := p_old_SSC_rec.attribute3;
    END IF;

    IF l_SSC_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute4 := p_old_SSC_rec.attribute4;
    END IF;

    IF l_SSC_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute5 := p_old_SSC_rec.attribute5;
    END IF;

    IF l_SSC_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute6 := p_old_SSC_rec.attribute6;
    END IF;

    IF l_SSC_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute7 := p_old_SSC_rec.attribute7;
    END IF;

    IF l_SSC_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute8 := p_old_SSC_rec.attribute8;
    END IF;

    IF l_SSC_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute9 := p_old_SSC_rec.attribute9;
    END IF;

    IF l_SSC_rec.context = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.context := p_old_SSC_rec.context;
    END IF;

    IF l_SSC_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SSC_rec.created_by := p_old_SSC_rec.created_by;
    END IF;

    IF l_SSC_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.creation_date := p_old_SSC_rec.creation_date;
    END IF;

    IF l_SSC_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.enabled_flag := p_old_SSC_rec.enabled_flag;
    END IF;

    IF l_SSC_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SSC_rec.last_updated_by := p_old_SSC_rec.last_updated_by;
    END IF;

    IF l_SSC_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.last_update_date := p_old_SSC_rec.last_update_date;
    END IF;

    IF l_SSC_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SSC_rec.last_update_login := p_old_SSC_rec.last_update_login;
    END IF;

    IF l_SSC_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.program_application_id := p_old_SSC_rec.program_application_id;
    END IF;

    IF l_SSC_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.program_id := p_old_SSC_rec.program_id;
    END IF;

    IF l_SSC_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.program_update_date := p_old_SSC_rec.program_update_date;
    END IF;

    IF l_SSC_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.pte_code := p_old_SSC_rec.pte_code;
    END IF;

    IF l_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.pte_source_system_id := p_old_SSC_rec.pte_source_system_id;
    END IF;

    RETURN l_SSC_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
) RETURN QP_Attr_Map_PUB.Ssc_Rec_Type
IS
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type := p_SSC_rec;
BEGIN

    IF l_SSC_rec.application_short_name = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.application_short_name := NULL;
    END IF;

    IF l_SSC_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute1 := NULL;
    END IF;

    IF l_SSC_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute10 := NULL;
    END IF;

    IF l_SSC_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute11 := NULL;
    END IF;

    IF l_SSC_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute12 := NULL;
    END IF;

    IF l_SSC_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute13 := NULL;
    END IF;

    IF l_SSC_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute14 := NULL;
    END IF;

    IF l_SSC_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute15 := NULL;
    END IF;

    IF l_SSC_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute2 := NULL;
    END IF;

    IF l_SSC_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute3 := NULL;
    END IF;

    IF l_SSC_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute4 := NULL;
    END IF;

    IF l_SSC_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute5 := NULL;
    END IF;

    IF l_SSC_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute6 := NULL;
    END IF;

    IF l_SSC_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute7 := NULL;
    END IF;

    IF l_SSC_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute8 := NULL;
    END IF;

    IF l_SSC_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.attribute9 := NULL;
    END IF;

    IF l_SSC_rec.context = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.context := NULL;
    END IF;

    IF l_SSC_rec.created_by = FND_API.G_MISS_NUM THEN
        l_SSC_rec.created_by := NULL;
    END IF;

    IF l_SSC_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.creation_date := NULL;
    END IF;

    IF l_SSC_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.enabled_flag := NULL;
    END IF;

    IF l_SSC_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_SSC_rec.last_updated_by := NULL;
    END IF;

    IF l_SSC_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.last_update_date := NULL;
    END IF;

    IF l_SSC_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_SSC_rec.last_update_login := NULL;
    END IF;

    IF l_SSC_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.program_application_id := NULL;
    END IF;

    IF l_SSC_rec.program_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.program_id := NULL;
    END IF;

    IF l_SSC_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_SSC_rec.program_update_date := NULL;
    END IF;

    IF l_SSC_rec.pte_code = FND_API.G_MISS_CHAR THEN
        l_SSC_rec.pte_code := NULL;
    END IF;

    IF l_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
        l_SSC_rec.pte_source_system_id := NULL;
    END IF;

    RETURN l_SSC_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
BEGIN

    UPDATE  QP_PTE_SOURCE_SYSTEMS
    SET     APPLICATION_SHORT_NAME         = p_SSC_rec.application_short_name
    ,       ATTRIBUTE1                     = p_SSC_rec.attribute1
    ,       ATTRIBUTE10                    = p_SSC_rec.attribute10
    ,       ATTRIBUTE11                    = p_SSC_rec.attribute11
    ,       ATTRIBUTE12                    = p_SSC_rec.attribute12
    ,       ATTRIBUTE13                    = p_SSC_rec.attribute13
    ,       ATTRIBUTE14                    = p_SSC_rec.attribute14
    ,       ATTRIBUTE15                    = p_SSC_rec.attribute15
    ,       ATTRIBUTE2                     = p_SSC_rec.attribute2
    ,       ATTRIBUTE3                     = p_SSC_rec.attribute3
    ,       ATTRIBUTE4                     = p_SSC_rec.attribute4
    ,       ATTRIBUTE5                     = p_SSC_rec.attribute5
    ,       ATTRIBUTE6                     = p_SSC_rec.attribute6
    ,       ATTRIBUTE7                     = p_SSC_rec.attribute7
    ,       ATTRIBUTE8                     = p_SSC_rec.attribute8
    ,       ATTRIBUTE9                     = p_SSC_rec.attribute9
    ,       CONTEXT                        = p_SSC_rec.context
    ,       CREATED_BY                     = p_SSC_rec.created_by
    ,       CREATION_DATE                  = p_SSC_rec.creation_date
    ,       ENABLED_FLAG                   = p_SSC_rec.enabled_flag
    ,       LAST_UPDATED_BY                = p_SSC_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_SSC_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_SSC_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID         = p_SSC_rec.program_application_id
    ,       PROGRAM_ID                     = p_SSC_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_SSC_rec.program_update_date
    ,       PTE_CODE                       = p_SSC_rec.pte_code
    ,       PTE_SOURCE_SYSTEM_ID           = p_SSC_rec.pte_source_system_id
    WHERE   PTE_SOURCE_SYSTEM_ID = p_SSC_rec.pte_source_system_id
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
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
BEGIN

    INSERT  INTO QP_PTE_SOURCE_SYSTEMS
    (       APPLICATION_SHORT_NAME
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
    ,       PTE_CODE
    ,       PTE_SOURCE_SYSTEM_ID
    )
    VALUES
    (       p_SSC_rec.application_short_name
    ,       p_SSC_rec.attribute1
    ,       p_SSC_rec.attribute10
    ,       p_SSC_rec.attribute11
    ,       p_SSC_rec.attribute12
    ,       p_SSC_rec.attribute13
    ,       p_SSC_rec.attribute14
    ,       p_SSC_rec.attribute15
    ,       p_SSC_rec.attribute2
    ,       p_SSC_rec.attribute3
    ,       p_SSC_rec.attribute4
    ,       p_SSC_rec.attribute5
    ,       p_SSC_rec.attribute6
    ,       p_SSC_rec.attribute7
    ,       p_SSC_rec.attribute8
    ,       p_SSC_rec.attribute9
    ,       p_SSC_rec.context
    ,       p_SSC_rec.created_by
    ,       p_SSC_rec.creation_date
    ,       p_SSC_rec.enabled_flag
    ,       p_SSC_rec.last_updated_by
    ,       p_SSC_rec.last_update_date
    ,       p_SSC_rec.last_update_login
    ,       p_SSC_rec.program_application_id
    ,       p_SSC_rec.program_id
    ,       p_SSC_rec.program_update_date
    ,       p_SSC_rec.pte_code
    ,       p_SSC_rec.pte_source_system_id
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
(   p_pte_source_system_id          IN  NUMBER
)
IS
BEGIN

    DELETE  FROM QP_PTE_SOURCE_SYSTEMS
    WHERE   PTE_SOURCE_SYSTEM_ID = p_pte_source_system_id
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
(   p_pte_source_system_id          IN  NUMBER
) RETURN QP_Attr_Map_PUB.Ssc_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_pte_source_system_id        => p_pte_source_system_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_pte_source_system_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
) RETURN QP_Attr_Map_PUB.Ssc_Tbl_Type
IS
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
l_SSC_tbl                     QP_Attr_Map_PUB.Ssc_Tbl_Type;

CURSOR l_SSC_csr IS
    SELECT  APPLICATION_SHORT_NAME
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
    ,       PTE_CODE
    ,       PTE_SOURCE_SYSTEM_ID
    FROM    QP_PTE_SOURCE_SYSTEMS
    WHERE ( PTE_SOURCE_SYSTEM_ID = p_pte_source_system_id
    )
    --**OR (    LOOKUP_CODE = p_lookup_code
    OR (    PTE_CODE = p_lookup_code
    );

BEGIN

    IF
    (p_pte_source_system_id IS NOT NULL
     AND
     p_pte_source_system_id <> FND_API.G_MISS_NUM)
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
                ,   'Keys are mutually exclusive: pte_source_system_id = '|| p_pte_source_system_id || ', lookup_code = '|| p_lookup_code
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_SSC_csr LOOP

        l_SSC_rec.application_short_name := l_implicit_rec.APPLICATION_SHORT_NAME;
        l_SSC_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_SSC_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_SSC_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_SSC_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_SSC_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_SSC_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_SSC_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_SSC_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_SSC_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_SSC_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_SSC_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_SSC_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_SSC_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_SSC_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_SSC_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_SSC_rec.context              := l_implicit_rec.CONTEXT;
        l_SSC_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_SSC_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_SSC_rec.enabled_flag         := l_implicit_rec.ENABLED_FLAG;
        l_SSC_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_SSC_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_SSC_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_SSC_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_SSC_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_SSC_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_SSC_rec.pte_code             := l_implicit_rec.PTE_CODE;
        l_SSC_rec.pte_source_system_id := l_implicit_rec.PTE_SOURCE_SYSTEM_ID;

        l_SSC_tbl(l_SSC_tbl.COUNT + 1) := l_SSC_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_pte_source_system_id IS NOT NULL
     AND
     p_pte_source_system_id <> FND_API.G_MISS_NUM)
    AND
    (l_SSC_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_SSC_tbl;

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
,   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   x_SSC_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
BEGIN

    SELECT  APPLICATION_SHORT_NAME
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
    ,       PTE_CODE
    ,       PTE_SOURCE_SYSTEM_ID
    INTO    l_SSC_rec.application_short_name
    ,       l_SSC_rec.attribute1
    ,       l_SSC_rec.attribute10
    ,       l_SSC_rec.attribute11
    ,       l_SSC_rec.attribute12
    ,       l_SSC_rec.attribute13
    ,       l_SSC_rec.attribute14
    ,       l_SSC_rec.attribute15
    ,       l_SSC_rec.attribute2
    ,       l_SSC_rec.attribute3
    ,       l_SSC_rec.attribute4
    ,       l_SSC_rec.attribute5
    ,       l_SSC_rec.attribute6
    ,       l_SSC_rec.attribute7
    ,       l_SSC_rec.attribute8
    ,       l_SSC_rec.attribute9
    ,       l_SSC_rec.context
    ,       l_SSC_rec.created_by
    ,       l_SSC_rec.creation_date
    ,       l_SSC_rec.enabled_flag
    ,       l_SSC_rec.last_updated_by
    ,       l_SSC_rec.last_update_date
    ,       l_SSC_rec.last_update_login
    ,       l_SSC_rec.program_application_id
    ,       l_SSC_rec.program_id
    ,       l_SSC_rec.program_update_date
    ,       l_SSC_rec.pte_code
    ,       l_SSC_rec.pte_source_system_id
    FROM    QP_PTE_SOURCE_SYSTEMS
    WHERE   PTE_SOURCE_SYSTEM_ID = p_SSC_rec.pte_source_system_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_SSC_rec.application_short_name,
                         l_SSC_rec.application_short_name)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute1,
                         l_SSC_rec.attribute1)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute10,
                         l_SSC_rec.attribute10)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute11,
                         l_SSC_rec.attribute11)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute12,
                         l_SSC_rec.attribute12)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute13,
                         l_SSC_rec.attribute13)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute14,
                         l_SSC_rec.attribute14)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute15,
                         l_SSC_rec.attribute15)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute2,
                         l_SSC_rec.attribute2)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute3,
                         l_SSC_rec.attribute3)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute4,
                         l_SSC_rec.attribute4)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute5,
                         l_SSC_rec.attribute5)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute6,
                         l_SSC_rec.attribute6)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute7,
                         l_SSC_rec.attribute7)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute8,
                         l_SSC_rec.attribute8)
    AND QP_GLOBALS.Equal(p_SSC_rec.attribute9,
                         l_SSC_rec.attribute9)
    AND QP_GLOBALS.Equal(p_SSC_rec.context,
                         l_SSC_rec.context)
    AND QP_GLOBALS.Equal(p_SSC_rec.created_by,
                         l_SSC_rec.created_by)
    AND QP_GLOBALS.Equal(p_SSC_rec.creation_date,
                         l_SSC_rec.creation_date)
    AND QP_GLOBALS.Equal(p_SSC_rec.enabled_flag,
                         l_SSC_rec.enabled_flag)
    AND QP_GLOBALS.Equal(p_SSC_rec.last_updated_by,
                         l_SSC_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_SSC_rec.last_update_date,
                         l_SSC_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_SSC_rec.last_update_login,
                         l_SSC_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_SSC_rec.program_application_id,
                         l_SSC_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_SSC_rec.program_id,
                         l_SSC_rec.program_id)
    AND QP_GLOBALS.Equal(p_SSC_rec.program_update_date,
                         l_SSC_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_SSC_rec.pte_code,
                         l_SSC_rec.pte_code)
    AND QP_GLOBALS.Equal(p_SSC_rec.pte_source_system_id,
                         l_SSC_rec.pte_source_system_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_SSC_rec                      := l_SSC_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_SSC_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SSC_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SSC_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_SSC_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_SSC_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_old_SSC_rec                   IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
) RETURN QP_Attr_Map_PUB.Ssc_Val_Rec_Type
IS
l_SSC_val_rec                 QP_Attr_Map_PUB.Ssc_Val_Rec_Type;
BEGIN

    IF p_SSC_rec.enabled_flag IS NOT NULL AND
        p_SSC_rec.enabled_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SSC_rec.enabled_flag,
        p_old_SSC_rec.enabled_flag)
    THEN
        l_SSC_val_rec.enabled := QP_Id_To_Value.Enabled
        (   p_enabled_flag                => p_SSC_rec.enabled_flag
        );
    END IF;

    IF p_SSC_rec.pte_code IS NOT NULL AND
        p_SSC_rec.pte_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_SSC_rec.pte_code,
        p_old_SSC_rec.pte_code)
    THEN
        l_SSC_val_rec.pte := QP_Id_To_Value.Pte
        (   p_pte_code                    => p_SSC_rec.pte_code
        );
    END IF;

    IF p_SSC_rec.pte_source_system_id IS NOT NULL AND
        p_SSC_rec.pte_source_system_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_SSC_rec.pte_source_system_id,
        p_old_SSC_rec.pte_source_system_id)
    THEN
        l_SSC_val_rec.pte_source_system := QP_Id_To_Value.Pte_Source_System
        (   p_pte_source_system_id        => p_SSC_rec.pte_source_system_id
        );
    END IF;

    RETURN l_SSC_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type
,   p_SSC_val_rec                   IN  QP_Attr_Map_PUB.Ssc_Val_Rec_Type
) RETURN QP_Attr_Map_PUB.Ssc_Rec_Type
IS
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_SSC_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_SSC_rec.

    l_SSC_rec := p_SSC_rec;

    IF  p_SSC_val_rec.enabled <> FND_API.G_MISS_CHAR
    THEN

        IF p_SSC_rec.enabled_flag <> FND_API.G_MISS_CHAR THEN

            l_SSC_rec.enabled_flag := p_SSC_rec.enabled_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SSC_rec.enabled_flag := QP_Value_To_Id.enabled
            (   p_enabled                     => p_SSC_val_rec.enabled
            );

            IF l_SSC_rec.enabled_flag = FND_API.G_MISS_CHAR THEN
                l_SSC_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SSC_val_rec.pte <> FND_API.G_MISS_CHAR
    THEN

        IF p_SSC_rec.pte_code <> FND_API.G_MISS_CHAR THEN

            l_SSC_rec.pte_code := p_SSC_rec.pte_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SSC_rec.pte_code := QP_Value_To_Id.pte
            (   p_pte                         => p_SSC_val_rec.pte
            );

            IF l_SSC_rec.pte_code = FND_API.G_MISS_CHAR THEN
                l_SSC_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_SSC_val_rec.pte_source_system <> FND_API.G_MISS_CHAR
    THEN

        IF p_SSC_rec.pte_source_system_id <> FND_API.G_MISS_NUM THEN

            l_SSC_rec.pte_source_system_id := p_SSC_rec.pte_source_system_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_source_system');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_SSC_rec.pte_source_system_id := QP_Value_To_Id.pte_source_system
            (   p_pte_source_system           => p_SSC_val_rec.pte_source_system
            );

            IF l_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN
                l_SSC_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_SSC_rec;

END Get_Ids;

END QP_Ssc_Util;

/

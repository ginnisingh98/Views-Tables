--------------------------------------------------------
--  DDL for Package Body QP_QUALIFIER_RULES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFIER_RULES_UTIL" AS
/* $Header: QPXUQPRB.pls 120.1 2005/06/13 05:19:49 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Qualifier_Rules_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out NOCOPY /* file.sql.39 change */ record

    x_QUALIFIER_RULES_rec := p_QUALIFIER_RULES_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute1,p_old_QUALIFIER_RULES_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute10,p_old_QUALIFIER_RULES_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute11,p_old_QUALIFIER_RULES_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute12,p_old_QUALIFIER_RULES_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute13,p_old_QUALIFIER_RULES_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute14,p_old_QUALIFIER_RULES_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute15,p_old_QUALIFIER_RULES_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute2,p_old_QUALIFIER_RULES_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute3,p_old_QUALIFIER_RULES_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute4,p_old_QUALIFIER_RULES_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute5,p_old_QUALIFIER_RULES_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute6,p_old_QUALIFIER_RULES_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute7,p_old_QUALIFIER_RULES_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute8,p_old_QUALIFIER_RULES_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute9,p_old_QUALIFIER_RULES_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.context,p_old_QUALIFIER_RULES_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.created_by,p_old_QUALIFIER_RULES_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.creation_date,p_old_QUALIFIER_RULES_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.description,p_old_QUALIFIER_RULES_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_updated_by,p_old_QUALIFIER_RULES_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_date,p_old_QUALIFIER_RULES_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_login,p_old_QUALIFIER_RULES_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.name,p_old_QUALIFIER_RULES_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_application_id,p_old_QUALIFIER_RULES_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_id,p_old_QUALIFIER_RULES_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_update_date,p_old_QUALIFIER_RULES_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.qualifier_rule_id,p_old_QUALIFIER_RULES_rec.qualifier_rule_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_QUALIFIER_RULE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.request_id,p_old_QUALIFIER_RULES_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_REQUEST;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_NAME;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_QUALIFIER_RULE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_QUALIFIER_RULE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_QUALIFIER_RULES_UTIL.G_REQUEST;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
BEGIN

    --  Load out NOCOPY /* file.sql.39 change */ record

    x_QUALIFIER_RULES_rec := p_QUALIFIER_RULES_rec;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute1,p_old_QUALIFIER_RULES_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute10,p_old_QUALIFIER_RULES_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute11,p_old_QUALIFIER_RULES_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute12,p_old_QUALIFIER_RULES_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute13,p_old_QUALIFIER_RULES_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute14,p_old_QUALIFIER_RULES_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute15,p_old_QUALIFIER_RULES_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute2,p_old_QUALIFIER_RULES_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute3,p_old_QUALIFIER_RULES_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute4,p_old_QUALIFIER_RULES_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute5,p_old_QUALIFIER_RULES_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute6,p_old_QUALIFIER_RULES_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute7,p_old_QUALIFIER_RULES_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute8,p_old_QUALIFIER_RULES_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute9,p_old_QUALIFIER_RULES_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.context,p_old_QUALIFIER_RULES_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.created_by,p_old_QUALIFIER_RULES_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.creation_date,p_old_QUALIFIER_RULES_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.description,p_old_QUALIFIER_RULES_rec.description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_updated_by,p_old_QUALIFIER_RULES_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_date,p_old_QUALIFIER_RULES_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_login,p_old_QUALIFIER_RULES_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.name,p_old_QUALIFIER_RULES_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_application_id,p_old_QUALIFIER_RULES_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_id,p_old_QUALIFIER_RULES_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_update_date,p_old_QUALIFIER_RULES_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.qualifier_rule_id,p_old_QUALIFIER_RULES_rec.qualifier_rule_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.request_id,p_old_QUALIFIER_RULES_rec.request_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
IS
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
BEGIN

    IF l_QUALIFIER_RULES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute1 := p_old_QUALIFIER_RULES_rec.attribute1;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute10 := p_old_QUALIFIER_RULES_rec.attribute10;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute11 := p_old_QUALIFIER_RULES_rec.attribute11;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute12 := p_old_QUALIFIER_RULES_rec.attribute12;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute13 := p_old_QUALIFIER_RULES_rec.attribute13;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute14 := p_old_QUALIFIER_RULES_rec.attribute14;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute15 := p_old_QUALIFIER_RULES_rec.attribute15;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute2 := p_old_QUALIFIER_RULES_rec.attribute2;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute3 := p_old_QUALIFIER_RULES_rec.attribute3;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute4 := p_old_QUALIFIER_RULES_rec.attribute4;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute5 := p_old_QUALIFIER_RULES_rec.attribute5;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute6 := p_old_QUALIFIER_RULES_rec.attribute6;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute7 := p_old_QUALIFIER_RULES_rec.attribute7;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute8 := p_old_QUALIFIER_RULES_rec.attribute8;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute9 := p_old_QUALIFIER_RULES_rec.attribute9;
    END IF;

    IF l_QUALIFIER_RULES_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.context := p_old_QUALIFIER_RULES_rec.context;
    END IF;

    IF l_QUALIFIER_RULES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.created_by := p_old_QUALIFIER_RULES_rec.created_by;
    END IF;

    IF l_QUALIFIER_RULES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.creation_date := p_old_QUALIFIER_RULES_rec.creation_date;
    END IF;

    IF l_QUALIFIER_RULES_rec.description = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.description := p_old_QUALIFIER_RULES_rec.description;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.last_updated_by := p_old_QUALIFIER_RULES_rec.last_updated_by;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.last_update_date := p_old_QUALIFIER_RULES_rec.last_update_date;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.last_update_login := p_old_QUALIFIER_RULES_rec.last_update_login;
    END IF;

    IF l_QUALIFIER_RULES_rec.name = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.name := p_old_QUALIFIER_RULES_rec.name;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.program_application_id := p_old_QUALIFIER_RULES_rec.program_application_id;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.program_id := p_old_QUALIFIER_RULES_rec.program_id;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.program_update_date := p_old_QUALIFIER_RULES_rec.program_update_date;
    END IF;

    IF l_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.qualifier_rule_id := p_old_QUALIFIER_RULES_rec.qualifier_rule_id;
    END IF;

    IF l_QUALIFIER_RULES_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.request_id := p_old_QUALIFIER_RULES_rec.request_id;
    END IF;

    RETURN l_QUALIFIER_RULES_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
IS
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
BEGIN

    IF l_QUALIFIER_RULES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute1 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute10 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute11 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute12 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute13 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute14 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute15 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute2 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute3 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute4 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute5 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute6 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute7 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute8 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.attribute9 := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.context = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.context := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.created_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.created_by := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.creation_date := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.description = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.description := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.last_updated_by := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.last_update_date := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.last_update_login := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.name = FND_API.G_MISS_CHAR THEN
        l_QUALIFIER_RULES_rec.name := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.program_application_id := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.program_id := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_QUALIFIER_RULES_rec.program_update_date := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.qualifier_rule_id := NULL;
    END IF;

    IF l_QUALIFIER_RULES_rec.request_id = FND_API.G_MISS_NUM THEN
        l_QUALIFIER_RULES_rec.request_id := NULL;
    END IF;

    RETURN l_QUALIFIER_RULES_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
BEGIN

    UPDATE  QP_QUALIFIER_RULES
    SET     ATTRIBUTE1                     = p_QUALIFIER_RULES_rec.attribute1
    ,       ATTRIBUTE10                    = p_QUALIFIER_RULES_rec.attribute10
    ,       ATTRIBUTE11                    = p_QUALIFIER_RULES_rec.attribute11
    ,       ATTRIBUTE12                    = p_QUALIFIER_RULES_rec.attribute12
    ,       ATTRIBUTE13                    = p_QUALIFIER_RULES_rec.attribute13
    ,       ATTRIBUTE14                    = p_QUALIFIER_RULES_rec.attribute14
    ,       ATTRIBUTE15                    = p_QUALIFIER_RULES_rec.attribute15
    ,       ATTRIBUTE2                     = p_QUALIFIER_RULES_rec.attribute2
    ,       ATTRIBUTE3                     = p_QUALIFIER_RULES_rec.attribute3
    ,       ATTRIBUTE4                     = p_QUALIFIER_RULES_rec.attribute4
    ,       ATTRIBUTE5                     = p_QUALIFIER_RULES_rec.attribute5
    ,       ATTRIBUTE6                     = p_QUALIFIER_RULES_rec.attribute6
    ,       ATTRIBUTE7                     = p_QUALIFIER_RULES_rec.attribute7
    ,       ATTRIBUTE8                     = p_QUALIFIER_RULES_rec.attribute8
    ,       ATTRIBUTE9                     = p_QUALIFIER_RULES_rec.attribute9
    ,       CONTEXT                        = p_QUALIFIER_RULES_rec.context
    ,       CREATED_BY                     = p_QUALIFIER_RULES_rec.created_by
    ,       CREATION_DATE                  = p_QUALIFIER_RULES_rec.creation_date
    ,       DESCRIPTION                    = p_QUALIFIER_RULES_rec.description
    ,       LAST_UPDATED_BY                = p_QUALIFIER_RULES_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_QUALIFIER_RULES_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_QUALIFIER_RULES_rec.last_update_login
    ,       NAME                           = p_QUALIFIER_RULES_rec.name
    ,       PROGRAM_APPLICATION_ID         = p_QUALIFIER_RULES_rec.program_application_id
    ,       PROGRAM_ID                     = p_QUALIFIER_RULES_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_QUALIFIER_RULES_rec.program_update_date
    ,       QUALIFIER_RULE_ID              = p_QUALIFIER_RULES_rec.qualifier_rule_id
    ,       REQUEST_ID                     = p_QUALIFIER_RULES_rec.request_id
    WHERE   QUALIFIER_RULE_ID = p_QUALIFIER_RULES_rec.qualifier_rule_id
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
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
BEGIN


   oe_debug_pub.add('executing insert row');

    INSERT  INTO QP_QUALIFIER_RULES
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
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    )
    VALUES
    (       p_QUALIFIER_RULES_rec.attribute1
    ,       p_QUALIFIER_RULES_rec.attribute10
    ,       p_QUALIFIER_RULES_rec.attribute11
    ,       p_QUALIFIER_RULES_rec.attribute12
    ,       p_QUALIFIER_RULES_rec.attribute13
    ,       p_QUALIFIER_RULES_rec.attribute14
    ,       p_QUALIFIER_RULES_rec.attribute15
    ,       p_QUALIFIER_RULES_rec.attribute2
    ,       p_QUALIFIER_RULES_rec.attribute3
    ,       p_QUALIFIER_RULES_rec.attribute4
    ,       p_QUALIFIER_RULES_rec.attribute5
    ,       p_QUALIFIER_RULES_rec.attribute6
    ,       p_QUALIFIER_RULES_rec.attribute7
    ,       p_QUALIFIER_RULES_rec.attribute8
    ,       p_QUALIFIER_RULES_rec.attribute9
    ,       p_QUALIFIER_RULES_rec.context
    ,       p_QUALIFIER_RULES_rec.created_by
    ,       p_QUALIFIER_RULES_rec.creation_date
    ,       p_QUALIFIER_RULES_rec.description
    ,       p_QUALIFIER_RULES_rec.last_updated_by
    ,       p_QUALIFIER_RULES_rec.last_update_date
    ,       p_QUALIFIER_RULES_rec.last_update_login
    ,       p_QUALIFIER_RULES_rec.name
    ,       p_QUALIFIER_RULES_rec.program_application_id
    ,       p_QUALIFIER_RULES_rec.program_id
    ,       p_QUALIFIER_RULES_rec.program_update_date
    ,       p_QUALIFIER_RULES_rec.qualifier_rule_id
    ,       p_QUALIFIER_RULES_rec.request_id
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
(   p_qualifier_rule_id             IN  NUMBER
)
IS
BEGIN

    -- added by svdeshmu on 1-dec-99 for cascade delete

    QP_Qualifiers_util.Delete_Row(p_qualifier_rule_id=>p_qualifier_rule_id);

    -- end of addition


    DELETE  FROM QP_QUALIFIER_RULES
    WHERE   QUALIFIER_RULE_ID = p_qualifier_rule_id
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
(   p_qualifier_rule_id             IN  NUMBER
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
IS
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
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
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    INTO    l_QUALIFIER_RULES_rec.attribute1
    ,       l_QUALIFIER_RULES_rec.attribute10
    ,       l_QUALIFIER_RULES_rec.attribute11
    ,       l_QUALIFIER_RULES_rec.attribute12
    ,       l_QUALIFIER_RULES_rec.attribute13
    ,       l_QUALIFIER_RULES_rec.attribute14
    ,       l_QUALIFIER_RULES_rec.attribute15
    ,       l_QUALIFIER_RULES_rec.attribute2
    ,       l_QUALIFIER_RULES_rec.attribute3
    ,       l_QUALIFIER_RULES_rec.attribute4
    ,       l_QUALIFIER_RULES_rec.attribute5
    ,       l_QUALIFIER_RULES_rec.attribute6
    ,       l_QUALIFIER_RULES_rec.attribute7
    ,       l_QUALIFIER_RULES_rec.attribute8
    ,       l_QUALIFIER_RULES_rec.attribute9
    ,       l_QUALIFIER_RULES_rec.context
    ,       l_QUALIFIER_RULES_rec.created_by
    ,       l_QUALIFIER_RULES_rec.creation_date
    ,       l_QUALIFIER_RULES_rec.description
    ,       l_QUALIFIER_RULES_rec.last_updated_by
    ,       l_QUALIFIER_RULES_rec.last_update_date
    ,       l_QUALIFIER_RULES_rec.last_update_login
    ,       l_QUALIFIER_RULES_rec.name
    ,       l_QUALIFIER_RULES_rec.program_application_id
    ,       l_QUALIFIER_RULES_rec.program_id
    ,       l_QUALIFIER_RULES_rec.program_update_date
    ,       l_QUALIFIER_RULES_rec.qualifier_rule_id
    ,       l_QUALIFIER_RULES_rec.request_id
    FROM    QP_QUALIFIER_RULES
    WHERE   QUALIFIER_RULE_ID = p_qualifier_rule_id
    ;

    RETURN l_QUALIFIER_RULES_rec;

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
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
BEGIN



    oe_debug_pub.add('in lock row of QPXUQPRB.pls');

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
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       NAME
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUALIFIER_RULE_ID
    ,       REQUEST_ID
    INTO    l_QUALIFIER_RULES_rec.attribute1
    ,       l_QUALIFIER_RULES_rec.attribute10
    ,       l_QUALIFIER_RULES_rec.attribute11
    ,       l_QUALIFIER_RULES_rec.attribute12
    ,       l_QUALIFIER_RULES_rec.attribute13
    ,       l_QUALIFIER_RULES_rec.attribute14
    ,       l_QUALIFIER_RULES_rec.attribute15
    ,       l_QUALIFIER_RULES_rec.attribute2
    ,       l_QUALIFIER_RULES_rec.attribute3
    ,       l_QUALIFIER_RULES_rec.attribute4
    ,       l_QUALIFIER_RULES_rec.attribute5
    ,       l_QUALIFIER_RULES_rec.attribute6
    ,       l_QUALIFIER_RULES_rec.attribute7
    ,       l_QUALIFIER_RULES_rec.attribute8
    ,       l_QUALIFIER_RULES_rec.attribute9
    ,       l_QUALIFIER_RULES_rec.context
    ,       l_QUALIFIER_RULES_rec.created_by
    ,       l_QUALIFIER_RULES_rec.creation_date
    ,       l_QUALIFIER_RULES_rec.description
    ,       l_QUALIFIER_RULES_rec.last_updated_by
    ,       l_QUALIFIER_RULES_rec.last_update_date
    ,       l_QUALIFIER_RULES_rec.last_update_login
    ,       l_QUALIFIER_RULES_rec.name
    ,       l_QUALIFIER_RULES_rec.program_application_id
    ,       l_QUALIFIER_RULES_rec.program_id
    ,       l_QUALIFIER_RULES_rec.program_update_date
    ,       l_QUALIFIER_RULES_rec.qualifier_rule_id
    ,       l_QUALIFIER_RULES_rec.request_id
    FROM    QP_QUALIFIER_RULES
    WHERE   QUALIFIER_RULE_ID = p_QUALIFIER_RULES_rec.qualifier_rule_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute1,
                         l_QUALIFIER_RULES_rec.attribute1)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute10,
                         l_QUALIFIER_RULES_rec.attribute10)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute11,
                         l_QUALIFIER_RULES_rec.attribute11)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute12,
                         l_QUALIFIER_RULES_rec.attribute12)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute13,
                         l_QUALIFIER_RULES_rec.attribute13)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute14,
                         l_QUALIFIER_RULES_rec.attribute14)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute15,
                         l_QUALIFIER_RULES_rec.attribute15)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute2,
                         l_QUALIFIER_RULES_rec.attribute2)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute3,
                         l_QUALIFIER_RULES_rec.attribute3)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute4,
                         l_QUALIFIER_RULES_rec.attribute4)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute5,
                         l_QUALIFIER_RULES_rec.attribute5)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute6,
                         l_QUALIFIER_RULES_rec.attribute6)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute7,
                         l_QUALIFIER_RULES_rec.attribute7)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute8,
                         l_QUALIFIER_RULES_rec.attribute8)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.attribute9,
                         l_QUALIFIER_RULES_rec.attribute9)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.context,
                         l_QUALIFIER_RULES_rec.context)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.created_by,
                         l_QUALIFIER_RULES_rec.created_by)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.creation_date,
                         l_QUALIFIER_RULES_rec.creation_date)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.description,
                         l_QUALIFIER_RULES_rec.description)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_updated_by,
                         l_QUALIFIER_RULES_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_date,
                         l_QUALIFIER_RULES_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.last_update_login,
                         l_QUALIFIER_RULES_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.name,
                         l_QUALIFIER_RULES_rec.name)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_application_id,
                         l_QUALIFIER_RULES_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_id,
                         l_QUALIFIER_RULES_rec.program_id)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.program_update_date,
                         l_QUALIFIER_RULES_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.qualifier_rule_id,
                         l_QUALIFIER_RULES_rec.qualifier_rule_id)
    AND QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.request_id,
                         l_QUALIFIER_RULES_rec.request_id)
    THEN

        --  Row has not changed. Set out NOCOPY /* file.sql.39 change */ parameter.
        oe_debug_pub.add('row not changed');

        x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        oe_debug_pub.add('row  changed');

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            oe_debug_pub.add('row  deleted');
            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            oe_debug_pub.add('row  already locked');
            FND_MESSAGE.SET_NAME('QP','QP_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type
IS
l_QUALIFIER_RULES_val_rec     QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
BEGIN

    IF p_QUALIFIER_RULES_rec.qualifier_rule_id IS NOT NULL AND
        p_QUALIFIER_RULES_rec.qualifier_rule_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_QUALIFIER_RULES_rec.qualifier_rule_id,
        p_old_QUALIFIER_RULES_rec.qualifier_rule_id)
    THEN
        l_QUALIFIER_RULES_val_rec.qualifier_rule := QP_Id_To_Value.Qualifier_Rule
        (   p_qualifier_rule_id           => p_QUALIFIER_RULES_rec.qualifier_rule_id
        );
    END IF;

    RETURN l_QUALIFIER_RULES_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_QUALIFIER_RULES_val_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
IS
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_QUALIFIER_RULES_rec.

    l_QUALIFIER_RULES_rec := p_QUALIFIER_RULES_rec;

    IF  p_QUALIFIER_RULES_val_rec.qualifier_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_QUALIFIER_RULES_rec.qualifier_rule_id <> FND_API.G_MISS_NUM THEN

            l_QUALIFIER_RULES_rec.qualifier_rule_id := p_QUALIFIER_RULES_rec.qualifier_rule_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_QUALIFIER_RULES_rec.qualifier_rule_id := QP_Value_To_Id.qualifier_rule
            (   p_qualifier_rule              => p_QUALIFIER_RULES_val_rec.qualifier_rule
            );

            IF l_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN
                l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_QUALIFIER_RULES_rec;

END Get_Ids;

END QP_Qualifier_Rules_Util;

/

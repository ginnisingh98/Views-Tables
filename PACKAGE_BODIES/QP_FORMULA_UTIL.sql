--------------------------------------------------------
--  DDL for Package Body QP_FORMULA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_FORMULA_UTIL" AS
/* $Header: QPXUPRFB.pls 120.1 2005/06/12 23:13:25 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Formula_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

oe_debug_pub.add('Entering proc clear_dependent_attr in Formula Util Pkg');
    --  Load out record

    x_FORMULA_rec := p_FORMULA_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute1,p_old_FORMULA_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute10,p_old_FORMULA_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute11,p_old_FORMULA_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute12,p_old_FORMULA_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute13,p_old_FORMULA_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute14,p_old_FORMULA_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute15,p_old_FORMULA_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute2,p_old_FORMULA_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute3,p_old_FORMULA_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute4,p_old_FORMULA_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute5,p_old_FORMULA_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute6,p_old_FORMULA_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute7,p_old_FORMULA_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute8,p_old_FORMULA_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute9,p_old_FORMULA_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.context,p_old_FORMULA_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.created_by,p_old_FORMULA_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.creation_date,p_old_FORMULA_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.description,p_old_FORMULA_rec.description)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_DESCRIPTION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.end_date_active,p_old_FORMULA_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.formula,p_old_FORMULA_rec.formula)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_updated_by,p_old_FORMULA_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_update_date,p_old_FORMULA_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_update_login,p_old_FORMULA_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.name,p_old_FORMULA_rec.name)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_NAME;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.price_formula_id,p_old_FORMULA_rec.price_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_PRICE_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.start_date_active,p_old_FORMULA_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_START_DATE_ACTIVE;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_DESCRIPTION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_DESCRIPTION;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_FORMULA;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_NAME;
    ELSIF p_attr_id = G_PRICE_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_PRICE_FORMULA;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_FORMULA_UTIL.G_START_DATE_ACTIVE;
    END IF;

oe_debug_pub.add('Leaving proc clear_dependent_attr in Formula Util Pkg');
END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc Apply_attribute_Changes in Formula Util Pkg');
    --  Load out NOCOPY record

    x_FORMULA_rec := p_FORMULA_rec;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute1,p_old_FORMULA_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute10,p_old_FORMULA_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute11,p_old_FORMULA_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute12,p_old_FORMULA_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute13,p_old_FORMULA_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute14,p_old_FORMULA_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute15,p_old_FORMULA_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute2,p_old_FORMULA_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute3,p_old_FORMULA_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute4,p_old_FORMULA_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute5,p_old_FORMULA_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute6,p_old_FORMULA_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute7,p_old_FORMULA_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute8,p_old_FORMULA_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.attribute9,p_old_FORMULA_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.context,p_old_FORMULA_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.created_by,p_old_FORMULA_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.creation_date,p_old_FORMULA_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.description,p_old_FORMULA_rec.description)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.end_date_active,p_old_FORMULA_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.formula,p_old_FORMULA_rec.formula)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_updated_by,p_old_FORMULA_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_update_date,p_old_FORMULA_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.last_update_login,p_old_FORMULA_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.name,p_old_FORMULA_rec.name)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.price_formula_id,p_old_FORMULA_rec.price_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_FORMULA_rec.start_date_active,p_old_FORMULA_rec.start_date_active)
    THEN
        NULL;
    END IF;

oe_debug_pub.add('Leaving proc Apply_attribute_Changes in Formula Util Pkg');
END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Rec_Type
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type := p_FORMULA_rec;
BEGIN

oe_debug_pub.add('Entering proc Complete_Record in Formula Util Pkg');
    IF l_FORMULA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute1 := p_old_FORMULA_rec.attribute1;
    END IF;

    IF l_FORMULA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute10 := p_old_FORMULA_rec.attribute10;
    END IF;

    IF l_FORMULA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute11 := p_old_FORMULA_rec.attribute11;
    END IF;

    IF l_FORMULA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute12 := p_old_FORMULA_rec.attribute12;
    END IF;

    IF l_FORMULA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute13 := p_old_FORMULA_rec.attribute13;
    END IF;

    IF l_FORMULA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute14 := p_old_FORMULA_rec.attribute14;
    END IF;

    IF l_FORMULA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute15 := p_old_FORMULA_rec.attribute15;
    END IF;

    IF l_FORMULA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute2 := p_old_FORMULA_rec.attribute2;
    END IF;

    IF l_FORMULA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute3 := p_old_FORMULA_rec.attribute3;
    END IF;

    IF l_FORMULA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute4 := p_old_FORMULA_rec.attribute4;
    END IF;

    IF l_FORMULA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute5 := p_old_FORMULA_rec.attribute5;
    END IF;

    IF l_FORMULA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute6 := p_old_FORMULA_rec.attribute6;
    END IF;

    IF l_FORMULA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute7 := p_old_FORMULA_rec.attribute7;
    END IF;

    IF l_FORMULA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute8 := p_old_FORMULA_rec.attribute8;
    END IF;

    IF l_FORMULA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute9 := p_old_FORMULA_rec.attribute9;
    END IF;

    IF l_FORMULA_rec.context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.context := p_old_FORMULA_rec.context;
    END IF;

    IF l_FORMULA_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.created_by := p_old_FORMULA_rec.created_by;
    END IF;

    IF l_FORMULA_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.creation_date := p_old_FORMULA_rec.creation_date;
    END IF;

    IF l_FORMULA_rec.description = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.description := p_old_FORMULA_rec.description;
    END IF;

    IF l_FORMULA_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.end_date_active := p_old_FORMULA_rec.end_date_active;
    END IF;

    IF l_FORMULA_rec.formula = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.formula := p_old_FORMULA_rec.formula;
    END IF;

    IF l_FORMULA_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.last_updated_by := p_old_FORMULA_rec.last_updated_by;
    END IF;

    IF l_FORMULA_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.last_update_date := p_old_FORMULA_rec.last_update_date;
    END IF;

    IF l_FORMULA_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.last_update_login := p_old_FORMULA_rec.last_update_login;
    END IF;

    IF l_FORMULA_rec.name = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.name := p_old_FORMULA_rec.name;
    END IF;

    IF l_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.price_formula_id := p_old_FORMULA_rec.price_formula_id;
    END IF;

    IF l_FORMULA_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.start_date_active := p_old_FORMULA_rec.start_date_active;
    END IF;

oe_debug_pub.add('Leaving proc Complete_Record in Formula Util Pkg');
    RETURN l_FORMULA_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Rec_Type
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type := p_FORMULA_rec;
BEGIN

oe_debug_pub.add('Entering proc Convert_Miss_To_Null in Formula Util Pkg');
    IF l_FORMULA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute1 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute10 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute11 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute12 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute13 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute14 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute15 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute2 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute3 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute4 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute5 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute6 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute7 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute8 := NULL;
    END IF;

    IF l_FORMULA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.attribute9 := NULL;
    END IF;

    IF l_FORMULA_rec.context = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.context := NULL;
    END IF;

    IF l_FORMULA_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.created_by := NULL;
    END IF;

    IF l_FORMULA_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.creation_date := NULL;
    END IF;

    IF l_FORMULA_rec.description = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.description := NULL;
    END IF;

    IF l_FORMULA_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.end_date_active := NULL;
    END IF;

    IF l_FORMULA_rec.formula = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.formula := NULL;
    END IF;

    IF l_FORMULA_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.last_updated_by := NULL;
    END IF;

    IF l_FORMULA_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.last_update_date := NULL;
    END IF;

    IF l_FORMULA_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.last_update_login := NULL;
    END IF;

    IF l_FORMULA_rec.name = FND_API.G_MISS_CHAR THEN
        l_FORMULA_rec.name := NULL;
    END IF;

    IF l_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM THEN
        l_FORMULA_rec.price_formula_id := NULL;
    END IF;

    IF l_FORMULA_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_FORMULA_rec.start_date_active := NULL;
    END IF;

oe_debug_pub.add('Leaving proc Convert_Miss_To_Null in Formula Util Pkg');
    RETURN l_FORMULA_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc Update_Row in Formula Util Pkg');
    UPDATE  QP_PRICE_FORMULAS_B
    SET     ATTRIBUTE1                     = p_FORMULA_rec.attribute1
    ,       ATTRIBUTE10                    = p_FORMULA_rec.attribute10
    ,       ATTRIBUTE11                    = p_FORMULA_rec.attribute11
    ,       ATTRIBUTE12                    = p_FORMULA_rec.attribute12
    ,       ATTRIBUTE13                    = p_FORMULA_rec.attribute13
    ,       ATTRIBUTE14                    = p_FORMULA_rec.attribute14
    ,       ATTRIBUTE15                    = p_FORMULA_rec.attribute15
    ,       ATTRIBUTE2                     = p_FORMULA_rec.attribute2
    ,       ATTRIBUTE3                     = p_FORMULA_rec.attribute3
    ,       ATTRIBUTE4                     = p_FORMULA_rec.attribute4
    ,       ATTRIBUTE5                     = p_FORMULA_rec.attribute5
    ,       ATTRIBUTE6                     = p_FORMULA_rec.attribute6
    ,       ATTRIBUTE7                     = p_FORMULA_rec.attribute7
    ,       ATTRIBUTE8                     = p_FORMULA_rec.attribute8
    ,       ATTRIBUTE9                     = p_FORMULA_rec.attribute9
    ,       CONTEXT                        = p_FORMULA_rec.context
    ,       CREATED_BY                     = p_FORMULA_rec.created_by
    ,       CREATION_DATE                  = p_FORMULA_rec.creation_date
    ,       END_DATE_ACTIVE                = p_FORMULA_rec.end_date_active
    ,       FORMULA                        = p_FORMULA_rec.formula
    ,       LAST_UPDATED_BY                = p_FORMULA_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_FORMULA_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_FORMULA_rec.last_update_login
    ,       PRICE_FORMULA_ID               = p_FORMULA_rec.price_formula_id
    ,       START_DATE_ACTIVE              = p_FORMULA_rec.start_date_active
    WHERE   PRICE_FORMULA_ID = p_FORMULA_rec.price_formula_id
    ;

    UPDATE  QP_PRICE_FORMULAS_TL
    SET     DESCRIPTION                    = p_FORMULA_rec.description
    ,       SOURCE_LANG                    = userenv('LANG')
    ,       LAST_UPDATED_BY                = p_FORMULA_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_FORMULA_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_FORMULA_rec.last_update_login
    ,       NAME                           = p_FORMULA_rec.name
    WHERE   PRICE_FORMULA_ID = p_FORMULA_rec.price_formula_id
    AND     LANGUAGE = userenv('LANG');

oe_debug_pub.add('Leaving proc Update_Row in Formula Util Pkg');
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
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
BEGIN

oe_debug_pub.add('Entering proc Insert_Row in Formula Util Pkg');
    INSERT  INTO QP_PRICE_FORMULAS_B
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
    ,       END_DATE_ACTIVE
    ,       FORMULA
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_FORMULA_ID
    ,       START_DATE_ACTIVE
    )
    VALUES
    (       p_FORMULA_rec.attribute1
    ,       p_FORMULA_rec.attribute10
    ,       p_FORMULA_rec.attribute11
    ,       p_FORMULA_rec.attribute12
    ,       p_FORMULA_rec.attribute13
    ,       p_FORMULA_rec.attribute14
    ,       p_FORMULA_rec.attribute15
    ,       p_FORMULA_rec.attribute2
    ,       p_FORMULA_rec.attribute3
    ,       p_FORMULA_rec.attribute4
    ,       p_FORMULA_rec.attribute5
    ,       p_FORMULA_rec.attribute6
    ,       p_FORMULA_rec.attribute7
    ,       p_FORMULA_rec.attribute8
    ,       p_FORMULA_rec.attribute9
    ,       p_FORMULA_rec.context
    ,       p_FORMULA_rec.created_by
    ,       p_FORMULA_rec.creation_date
    ,       p_FORMULA_rec.end_date_active
    ,       p_FORMULA_rec.formula
    ,       p_FORMULA_rec.last_updated_by
    ,       p_FORMULA_rec.last_update_date
    ,       p_FORMULA_rec.last_update_login
    ,       p_FORMULA_rec.price_formula_id
    ,       p_FORMULA_rec.start_date_active
    );

    INSERT  INTO QP_PRICE_FORMULAS_TL
    (       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       LANGUAGE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    , 	  NAME
    ,	  PRICE_FORMULA_ID
    ,       SOURCE_LANG
    )
    SELECT  p_FORMULA_rec.created_by
    ,       p_FORMULA_rec.creation_date
    ,       p_FORMULA_rec.description
    ,       L.LANGUAGE_CODE
    ,       p_FORMULA_rec.last_updated_by
    ,       p_FORMULA_rec.last_update_date
    ,       p_FORMULA_rec.last_update_login
    ,       p_FORMULA_rec.name
    ,       p_FORMULA_rec.price_formula_id
    ,       userenv('LANG')
    FROM    FND_LANGUAGES L
    WHERE   L.INSTALLED_FLAG IN ('I', 'B')
    AND NOT EXISTS (SELECT NULL
			     FROM   QP_PRICE_FORMULAS_TL T
				WHERE  T.PRICE_FORMULA_ID = p_FORMULA_rec.price_formula_id
				AND    T.LANGUAGE         = L.LANGUAGE_CODE);

oe_debug_pub.add('Leaving proc Insert_Row in Formula Util Pkg');
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
(   p_price_formula_id              IN  NUMBER
)
IS
BEGIN

oe_debug_pub.add('Entering proc Delete_Row in Formula Util Pkg');
    DELETE  FROM QP_PRICE_FORMULAS_TL
    WHERE   PRICE_FORMULA_ID = p_price_formula_id;

    DELETE  FROM QP_PRICE_FORMULAS_B
    WHERE   PRICE_FORMULA_ID = p_price_formula_id;
oe_debug_pub.add('Leaving proc Delete_Row in Formula Util Pkg');

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
(   p_price_formula_id              IN  NUMBER
) RETURN QP_Price_Formula_PUB.Formula_Rec_Type
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Query_Row in Formula Util Pkg');
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
    ,       END_DATE_ACTIVE
    ,       FORMULA
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_FORMULA_ID
    ,       START_DATE_ACTIVE
    INTO    l_FORMULA_rec.attribute1
    ,       l_FORMULA_rec.attribute10
    ,       l_FORMULA_rec.attribute11
    ,       l_FORMULA_rec.attribute12
    ,       l_FORMULA_rec.attribute13
    ,       l_FORMULA_rec.attribute14
    ,       l_FORMULA_rec.attribute15
    ,       l_FORMULA_rec.attribute2
    ,       l_FORMULA_rec.attribute3
    ,       l_FORMULA_rec.attribute4
    ,       l_FORMULA_rec.attribute5
    ,       l_FORMULA_rec.attribute6
    ,       l_FORMULA_rec.attribute7
    ,       l_FORMULA_rec.attribute8
    ,       l_FORMULA_rec.attribute9
    ,       l_FORMULA_rec.context
    ,       l_FORMULA_rec.created_by
    ,       l_FORMULA_rec.creation_date
    ,       l_FORMULA_rec.end_date_active
    ,       l_FORMULA_rec.formula
    ,       l_FORMULA_rec.last_updated_by
    ,       l_FORMULA_rec.last_update_date
    ,       l_FORMULA_rec.last_update_login
    ,       l_FORMULA_rec.price_formula_id
    ,       l_FORMULA_rec.start_date_active
    FROM    QP_PRICE_FORMULAS_B
    WHERE   PRICE_FORMULA_ID = p_price_formula_id
    ;

    SELECT  DESCRIPTION
    ,       NAME
    INTO    l_FORMULA_rec.description
    ,       l_FORMULA_rec.name
    FROM    QP_PRICE_FORMULAS_TL
    WHERE   PRICE_FORMULA_ID = p_price_formula_id
    AND     LANGUAGE = userenv('LANG');

oe_debug_pub.add('Leaving proc Query_Row in Formula Util Pkg');
    RETURN l_FORMULA_rec;

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
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Lock_Row in Formula Util Pkg');
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
    ,       END_DATE_ACTIVE
    ,       FORMULA
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_FORMULA_ID
    ,       START_DATE_ACTIVE
    INTO    l_FORMULA_rec.attribute1
    ,       l_FORMULA_rec.attribute10
    ,       l_FORMULA_rec.attribute11
    ,       l_FORMULA_rec.attribute12
    ,       l_FORMULA_rec.attribute13
    ,       l_FORMULA_rec.attribute14
    ,       l_FORMULA_rec.attribute15
    ,       l_FORMULA_rec.attribute2
    ,       l_FORMULA_rec.attribute3
    ,       l_FORMULA_rec.attribute4
    ,       l_FORMULA_rec.attribute5
    ,       l_FORMULA_rec.attribute6
    ,       l_FORMULA_rec.attribute7
    ,       l_FORMULA_rec.attribute8
    ,       l_FORMULA_rec.attribute9
    ,       l_FORMULA_rec.context
    ,       l_FORMULA_rec.created_by
    ,       l_FORMULA_rec.creation_date
    ,       l_FORMULA_rec.end_date_active
    ,       l_FORMULA_rec.formula
    ,       l_FORMULA_rec.last_updated_by
    ,       l_FORMULA_rec.last_update_date
    ,       l_FORMULA_rec.last_update_login
    ,       l_FORMULA_rec.price_formula_id
    ,       l_FORMULA_rec.start_date_active
    FROM    QP_PRICE_FORMULAS_B
    WHERE   PRICE_FORMULA_ID = p_FORMULA_rec.price_formula_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_FORMULA_rec.attribute1,
                         l_FORMULA_rec.attribute1)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute10,
                         l_FORMULA_rec.attribute10)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute11,
                         l_FORMULA_rec.attribute11)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute12,
                         l_FORMULA_rec.attribute12)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute13,
                         l_FORMULA_rec.attribute13)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute14,
                         l_FORMULA_rec.attribute14)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute15,
                         l_FORMULA_rec.attribute15)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute2,
                         l_FORMULA_rec.attribute2)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute3,
                         l_FORMULA_rec.attribute3)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute4,
                         l_FORMULA_rec.attribute4)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute5,
                         l_FORMULA_rec.attribute5)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute6,
                         l_FORMULA_rec.attribute6)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute7,
                         l_FORMULA_rec.attribute7)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute8,
                         l_FORMULA_rec.attribute8)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.attribute9,
                         l_FORMULA_rec.attribute9)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.context,
                         l_FORMULA_rec.context)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.created_by,
                         l_FORMULA_rec.created_by)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.creation_date,
                         l_FORMULA_rec.creation_date)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.end_date_active,
                         l_FORMULA_rec.end_date_active)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.formula,
                         l_FORMULA_rec.formula)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.last_updated_by,
                         l_FORMULA_rec.last_updated_by)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.last_update_date,
                         l_FORMULA_rec.last_update_date)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.last_update_login,
                         l_FORMULA_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.price_formula_id,
                         l_FORMULA_rec.price_formula_id)
    AND QP_GLOBALS.Equal(p_FORMULA_rec.start_date_active,
                         l_FORMULA_rec.start_date_active)
    THEN

        --  Row has not changed. Set out parameter.

        x_FORMULA_rec                  := l_FORMULA_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_FORMULA_rec.return_status    := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_rec.return_status    := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

oe_debug_pub.add('Leaving proc Lock_Row in Formula Util Pkg');
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_rec.return_status    := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FORMULA_rec.return_status    := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FORMULA_rec.return_status    := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
) RETURN QP_Price_Formula_PUB.Formula_Val_Rec_Type
IS
l_FORMULA_val_rec             QP_Price_Formula_PUB.Formula_Val_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Get_Values in Formula Util Pkg');
    IF p_FORMULA_rec.price_formula_id IS NOT NULL AND
        p_FORMULA_rec.price_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_FORMULA_rec.price_formula_id,
        p_old_FORMULA_rec.price_formula_id)
    THEN
        l_FORMULA_val_rec.price_formula := QP_Id_To_Value.Price_Formula
        (   p_price_formula_id            => p_FORMULA_rec.price_formula_id
        );
    END IF;

oe_debug_pub.add('Leaving proc Get_Values in Formula Util Pkg');
    RETURN l_FORMULA_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_FORMULA_val_rec               IN  QP_Price_Formula_PUB.Formula_Val_Rec_Type
) RETURN QP_Price_Formula_PUB.Formula_Rec_Type
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
BEGIN

oe_debug_pub.add('Entering proc Get_Ids in Formula Util Pkg');
    --  initialize  return_status.

    l_FORMULA_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_FORMULA_rec.

    l_FORMULA_rec := p_FORMULA_rec;

    IF  p_FORMULA_val_rec.price_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_FORMULA_rec.price_formula_id <> FND_API.G_MISS_NUM THEN

            l_FORMULA_rec.price_formula_id := p_FORMULA_rec.price_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_FORMULA_rec.price_formula_id := QP_Value_To_Id.price_formula
            (   p_price_formula               => p_FORMULA_val_rec.price_formula
            );

            IF l_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM THEN
                l_FORMULA_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


oe_debug_pub.add('Leaving proc Get_Ids in Formula Util Pkg');
    RETURN l_FORMULA_rec;

END Get_Ids;

END QP_Formula_Util;

/

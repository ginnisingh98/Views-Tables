--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_FORMULA" AS
/* $Header: QPXDPRFB.pls 120.2 2005/07/06 01:59:17 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Formula';

--  Package global used within the package.

g_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;

--  Get functions.

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Formula
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Formula;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_Price_Formula
RETURN NUMBER
IS
l_price_formula_id   NUMBER := NULL;
BEGIN

oe_debug_pub.add('Entering proc Get_Price_Formula in Formula Defaults Pkg');
    SELECT QP_PRICE_FORMULAS_B_S.nextval
    INTO   l_price_formula_id
    FROM   dual;

oe_debug_pub.add('Leaving proc Get_Price_Formula in Formula Defaults Pkg');
    RETURN l_price_formula_id;

END Get_Price_Formula;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

PROCEDURE Get_Flex_Formula
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_FORMULA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute1       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute10      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute11      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute12      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute13      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute14      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute15      := NULL;
    END IF;

    IF g_FORMULA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute2       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute3       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute4       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute5       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute6       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute7       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute8       := NULL;
    END IF;

    IF g_FORMULA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.attribute9       := NULL;
    END IF;

    IF g_FORMULA_rec.context = FND_API.G_MISS_CHAR THEN
        g_FORMULA_rec.context          := NULL;
    END IF;

END Get_Flex_Formula;

--  Procedure Attributes

PROCEDURE Attributes
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
l_FORMULA_rec		QP_Price_Formula_PUB.Formula_Rec_Type; --[prarasto]
BEGIN

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_FORMULA_rec

    g_FORMULA_rec := p_FORMULA_rec;

    --  Default missing attributes.

    IF g_FORMULA_rec.description = FND_API.G_MISS_CHAR THEN

        g_FORMULA_rec.description := Get_Description;

        IF g_FORMULA_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_FORMULA_rec.description)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_DESCRIPTION
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_FORMULA_rec.end_date_active := Get_End_Date_Active;

        IF g_FORMULA_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_FORMULA_rec.end_date_active)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_END_DATE_ACTIVE
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.formula = FND_API.G_MISS_CHAR THEN

        g_FORMULA_rec.formula := Get_Formula;

        IF g_FORMULA_rec.formula IS NOT NULL THEN

            IF QP_Validate.Formula(g_FORMULA_rec.formula)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_FORMULA
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.formula := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.name = FND_API.G_MISS_CHAR THEN

        g_FORMULA_rec.name := Get_Name;

        IF g_FORMULA_rec.name IS NOT NULL THEN

            IF QP_Validate.Name(g_FORMULA_rec.name)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_NAME
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM THEN

        g_FORMULA_rec.price_formula_id := Get_Price_Formula;

        IF g_FORMULA_rec.price_formula_id IS NOT NULL THEN

            IF QP_Validate.Price_Formula(g_FORMULA_rec.price_formula_id)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_PRICE_FORMULA
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.price_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_FORMULA_rec.start_date_active := Get_Start_Date_Active;

        IF g_FORMULA_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_FORMULA_rec.start_date_active)
            THEN

	        l_FORMULA_rec := g_FORMULA_rec;

                QP_Formula_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Util.G_START_DATE_ACTIVE
                ,   p_FORMULA_rec                 => l_FORMULA_rec
                ,   x_FORMULA_rec                 => g_FORMULA_rec
                );
            ELSE
                g_FORMULA_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Formula;

    END IF;

    IF g_FORMULA_rec.created_by = FND_API.G_MISS_NUM THEN

        g_FORMULA_rec.created_by := NULL;

    END IF;

    IF g_FORMULA_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_FORMULA_rec.creation_date := NULL;

    END IF;

    IF g_FORMULA_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_FORMULA_rec.last_updated_by := NULL;

    END IF;

    IF g_FORMULA_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_FORMULA_rec.last_update_date := NULL;

    END IF;

    IF g_FORMULA_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_FORMULA_rec.last_update_login := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_FORMULA_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.context = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.created_by = FND_API.G_MISS_NUM
    OR  g_FORMULA_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_FORMULA_rec.description = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_FORMULA_rec.formula = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_FORMULA_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_FORMULA_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_FORMULA_rec.name = FND_API.G_MISS_CHAR
    OR  g_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM
    OR  g_FORMULA_rec.start_date_active = FND_API.G_MISS_DATE
    THEN

        QP_Default_Formula.Attributes
        (   p_FORMULA_rec                 => g_FORMULA_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_FORMULA_rec                 => x_FORMULA_rec
        );
    ELSE

        --  Done defaulting attributes

        x_FORMULA_rec := g_FORMULA_rec;

    END IF;

END Attributes;

END QP_Default_Formula;

/

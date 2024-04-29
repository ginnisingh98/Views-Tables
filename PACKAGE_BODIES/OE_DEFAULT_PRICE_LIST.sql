--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_PRICE_LIST" AS
/* $Header: OEXDPRHB.pls 115.2 1999/11/11 21:54:05 pkm ship      $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Price_List';

--  Package global used within the package.

g_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;

--  Get functions.

FUNCTION Get_Comments
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comments;

FUNCTION Get_Currency
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Currency;

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

FUNCTION Get_Freight_Terms
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Freight_Terms;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_Price_List
RETURN NUMBER
IS
   l_price_list_id	NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering OE_Default_Price_List.Get_Price_List');

    select qp_list_headers_b_s.nextval into l_price_list_id
    from dual;

    oe_debug_pub.add('Exiting OE_Default_Price_List.Get_Price_List');
    RETURN l_price_list_id;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Price_List'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Price_List;

FUNCTION Get_Rounding_Factor
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Rounding_Factor;

FUNCTION Get_Secondary_Price_List
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Secondary_Price_List;

FUNCTION Get_Ship_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Ship_Method;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

FUNCTION Get_Terms
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Terms;

PROCEDURE Get_Flex_So_Price_Lists
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute1    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute10   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute11   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute12   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute13   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute14   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute15   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute2    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute3    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute4    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute5    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute6    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute7    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute8    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute9    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.context       := NULL;
    END IF;

END Get_Flex_So_Price_Lists;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_rec                OUT OE_Price_List_PUB.Price_List_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_PRICE_LIST_rec

    g_PRICE_LIST_rec := p_PRICE_LIST_rec;

    --  Default missing attributes.

    IF g_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.comments := Get_Comments;

        IF g_PRICE_LIST_rec.comments IS NOT NULL THEN

            IF OE_Validate_Attr.Comments(g_PRICE_LIST_rec.comments)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_COMMENTS
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.comments := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.currency_code := Get_Currency;

        IF g_PRICE_LIST_rec.currency_code IS NOT NULL THEN

            IF OE_Validate_Attr.Currency(g_PRICE_LIST_rec.currency_code)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_CURRENCY
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.currency_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.description := Get_Description;

        IF g_PRICE_LIST_rec.description IS NOT NULL THEN

            IF OE_Validate_Attr.Description(g_PRICE_LIST_rec.description)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_DESCRIPTION
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.end_date_active := Get_End_Date_Active;

        IF g_PRICE_LIST_rec.end_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.End_Date_Active(g_PRICE_LIST_rec.end_date_active)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_END_DATE_ACTIVE
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.freight_terms_code := Get_Freight_Terms;

        IF g_PRICE_LIST_rec.freight_terms_code IS NOT NULL THEN

            IF OE_Validate_Attr.Freight_Terms(g_PRICE_LIST_rec.freight_terms_code)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_FREIGHT_TERMS
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.freight_terms_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.name := Get_Name;

        IF g_PRICE_LIST_rec.name IS NOT NULL THEN

            IF OE_Validate_Attr.Name(g_PRICE_LIST_rec.name)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_NAME
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.price_list_id := Get_Price_List;

        IF g_PRICE_LIST_rec.price_list_id IS NOT NULL THEN

            IF OE_Validate_Attr.Price_List(g_PRICE_LIST_rec.price_list_id)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_PRICE_LIST
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.price_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.rounding_factor := Get_Rounding_Factor;

        IF g_PRICE_LIST_rec.rounding_factor IS NOT NULL THEN

            IF OE_Validate_Attr.Rounding_Factor(g_PRICE_LIST_rec.rounding_factor)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_ROUNDING_FACTOR
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.secondary_price_list_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.secondary_price_list_id := Get_Secondary_Price_List;

        IF g_PRICE_LIST_rec.secondary_price_list_id IS NOT NULL THEN

            IF OE_Validate_Attr.Secondary_Price_List(g_PRICE_LIST_rec.secondary_price_list_id)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_SECONDARY_PRICE_LIST
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.secondary_price_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.ship_method_code := Get_Ship_Method;

        IF g_PRICE_LIST_rec.ship_method_code IS NOT NULL THEN

            IF OE_Validate_Attr.Ship_Method(g_PRICE_LIST_rec.ship_method_code)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_SHIP_METHOD
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.ship_method_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.start_date_active := Get_Start_Date_Active;

        IF g_PRICE_LIST_rec.start_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.Start_Date_Active(g_PRICE_LIST_rec.start_date_active)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_START_DATE_ACTIVE
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.terms_id := Get_Terms;

        IF g_PRICE_LIST_rec.terms_id IS NOT NULL THEN

            IF OE_Validate_Attr.Terms(g_PRICE_LIST_rec.terms_id)
            THEN
                OE_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Util.G_TERMS
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.terms_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_So_Price_Lists;

    END IF;

    IF g_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.created_by := NULL;

    END IF;

    IF g_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.creation_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.last_updated_by := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.last_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.last_update_login := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.program_application_id := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.program_id := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.program_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.secondary_price_list_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM
    THEN

        OE_Default_Price_List.Attributes
        (   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PRICE_LIST_rec              => x_PRICE_LIST_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PRICE_LIST_rec := g_PRICE_LIST_rec;

    END IF;

END Attributes;

END OE_Default_Price_List;

/

--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_PRICE_LIST_LINE" AS
/* $Header: OEXDPRLB.pls 120.2 2005/07/07 04:46:29 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Price_List_Line';

--  Package global used within the package.

g_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;

--  Get functions.

FUNCTION Get_Comments
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comments;

FUNCTION Get_Customer_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Customer_Item;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Inventory_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Inventory_Item;

FUNCTION Get_List_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Price;

FUNCTION Get_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN 'AMNT';

END Get_Method;

FUNCTION Get_Price_List
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_List;

FUNCTION Get_Price_List_Line
RETURN NUMBER
IS
    l_price_list_line_id	NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering OE_Default_Price_List_Line.Get_Price_List_Line');

    select qp_list_lines_s.nextval into l_price_list_line_id
    from dual;

    oe_debug_pub.add('Exiting OE_Default_Price_List_Line.Get_Price_List_Line: '|| to_char(l_price_list_line_id));

    RETURN l_price_list_line_id;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Agreement'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Price_List_Line;

FUNCTION Get_Pricing_Attribute1
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute1;

FUNCTION Get_Pricing_Attribute10
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute10;

FUNCTION Get_Pricing_Attribute11
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute11;

FUNCTION Get_Pricing_Attribute12
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute12;

FUNCTION Get_Pricing_Attribute13
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute13;

FUNCTION Get_Pricing_Attribute14
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute14;

FUNCTION Get_Pricing_Attribute15
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute15;

FUNCTION Get_Pricing_Attribute2
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute2;

FUNCTION Get_Pricing_Attribute3
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute3;

FUNCTION Get_Pricing_Attribute4
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute4;

FUNCTION Get_Pricing_Attribute5
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute5;

FUNCTION Get_Pricing_Attribute6
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_Pricing_Attribute6;

FUNCTION Get_Pricing_Attribute7
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_Pricing_Attribute7;

FUNCTION Get_Pricing_Attribute8
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_Pricing_Attribute8;

FUNCTION Get_Pricing_Attribute9
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_Pricing_Attribute9;

FUNCTION Get_Pricing_Context
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;
END Get_Pricing_Context;

FUNCTION Get_Pricing_Rule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Rule;

FUNCTION Get_Primary
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Primary;

FUNCTION Get_Reprice
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Reprice;

FUNCTION Get_Revision
RETURN VARCHAR2
IS
BEGIN

    RETURN '1';

END Get_Revision;

FUNCTION Get_Revision_Date
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Revision_Date;

FUNCTION Get_Revision_Reason
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Revision_Reason;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Start_Date_Active;

FUNCTION Get_Unit
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Unit;

PROCEDURE Get_Flex_So_Price_List_Lines
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute1 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute10 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute11 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute12 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute13 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute14 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute15 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute2 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute3 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute4 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute5 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute6 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute7 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute8 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute9 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.context  := NULL;
    END IF;

END Get_Flex_So_Price_List_Lines;

PROCEDURE Get_Flex_Pricing_Attributes
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute1 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute10 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute2 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute3 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute4 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute5 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute6 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute7 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute8 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_attribute9 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.pricing_context := NULL;
    END IF;

END Get_Flex_Pricing_Attributes;

/*
FUNCTION Get_Method_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Method_Type;
*/

FUNCTION Get_List_Line_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN 'PLL';

END Get_List_Line_Type;

/*
FUNCTION Get_Price_Break_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_Type;

FUNCTION Get_Price_Break_low
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_Low;

FUNCTION Get_Price_Break_High
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_High;

FUNCTION Get_Price_Break_Parent_Line
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_Parent_Line;

*/


--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_PRICE_LIST_LINE_rec		OE_Price_List_PUB.Price_List_Line_Rec_Type; --[prarasto]
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

    --  Initialize g_PRICE_LIST_LINE_rec

    g_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    --  Default missing attributes.

    IF g_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.comments := Get_Comments;

        IF g_PRICE_LIST_LINE_rec.comments IS NOT NULL THEN

            IF OE_Validate_Attr.Comments(g_PRICE_LIST_LINE_rec.comments)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_COMMENTS
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.comments := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.customer_item_id := Get_Customer_Item;

        IF g_PRICE_LIST_LINE_rec.customer_item_id IS NOT NULL THEN

            IF OE_Validate_Attr.Customer_Item(g_PRICE_LIST_LINE_rec.customer_item_id)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_CUSTOMER_ITEM
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.customer_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.end_date_active := Get_End_Date_Active;

        IF g_PRICE_LIST_LINE_rec.end_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.End_Date_Active(g_PRICE_LIST_LINE_rec.end_date_active)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_END_DATE_ACTIVE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.inventory_item_id := Get_Inventory_Item;

        IF g_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL THEN

            IF OE_Validate_Attr.Inventory_Item(g_PRICE_LIST_LINE_rec.inventory_item_id)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_INVENTORY_ITEM
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.inventory_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.list_price := Get_List_Price;

        IF g_PRICE_LIST_LINE_rec.list_price IS NOT NULL THEN

            IF OE_Validate_Attr.List_Price(g_PRICE_LIST_LINE_rec.list_price)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_LIST_PRICE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_price := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.method_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.method_code := Get_Method;

        IF g_PRICE_LIST_LINE_rec.method_code IS NOT NULL THEN

            IF OE_Validate_Attr.Method(g_PRICE_LIST_LINE_rec.method_code)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_METHOD
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.method_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.price_list_id := Get_Price_List;

        IF g_PRICE_LIST_LINE_rec.price_list_id IS NOT NULL THEN

            IF OE_Validate_Attr.Price_List(g_PRICE_LIST_LINE_rec.price_list_id)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICE_LIST
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.price_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.price_list_line_id := Get_Price_List_Line;

        IF g_PRICE_LIST_LINE_rec.price_list_line_id IS NOT NULL THEN

            IF OE_Validate_Attr.Price_List_Line(g_PRICE_LIST_LINE_rec.price_list_line_id)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICE_LIST_LINE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.price_list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute1 := Get_Pricing_Attribute1;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute1 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute1(g_PRICE_LIST_LINE_rec.pricing_attribute1)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE1
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute2 := Get_Pricing_Attribute2;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute2 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute2(g_PRICE_LIST_LINE_rec.pricing_attribute2)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE2
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute3 := Get_Pricing_Attribute3;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute3 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute3(g_PRICE_LIST_LINE_rec.pricing_attribute3)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE3
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute3 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute4 := Get_Pricing_Attribute4;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute4 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute4(g_PRICE_LIST_LINE_rec.pricing_attribute4)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE4
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute4 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute5 := Get_Pricing_Attribute5;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute5 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute5(g_PRICE_LIST_LINE_rec.pricing_attribute5)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE5
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute5 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute6 := Get_Pricing_Attribute6;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute6 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute6(g_PRICE_LIST_LINE_rec.pricing_attribute6)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE6
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute6 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute7 := Get_Pricing_Attribute7;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute7 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute7(g_PRICE_LIST_LINE_rec.pricing_attribute7)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE7
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute7 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute8 := Get_Pricing_Attribute8;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute8 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute8(g_PRICE_LIST_LINE_rec.pricing_attribute8)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE8
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute8 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute9 := Get_Pricing_Attribute9;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute9 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute9(g_PRICE_LIST_LINE_rec.pricing_attribute9)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE9
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute9 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute10 := Get_Pricing_Attribute10;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute10 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute10(g_PRICE_LIST_LINE_rec.pricing_attribute10)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE10
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute10 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute11 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute11 := Get_Pricing_Attribute11;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute11 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute11(g_PRICE_LIST_LINE_rec.pricing_attribute11)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE11
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute12 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute12 := Get_Pricing_Attribute12;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute12 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute12(g_PRICE_LIST_LINE_rec.pricing_attribute12)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE12
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute13 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute13 := Get_Pricing_Attribute13;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute13 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute13(g_PRICE_LIST_LINE_rec.pricing_attribute13)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE13
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute14 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute14 := Get_Pricing_Attribute14;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute14 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute14(g_PRICE_LIST_LINE_rec.pricing_attribute14)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE14
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute15 = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_attribute15 := Get_Pricing_Attribute15;

        IF g_PRICE_LIST_LINE_rec.pricing_attribute15 IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Attribute15(g_PRICE_LIST_LINE_rec.pricing_attribute15)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE15
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_attribute15 := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.pricing_context := Get_Pricing_context;

        IF g_PRICE_LIST_LINE_rec.pricing_context IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_context(g_PRICE_LIST_LINE_rec.pricing_context)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_context
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_rule_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.pricing_rule_id := Get_Pricing_Rule;

        IF g_PRICE_LIST_LINE_rec.pricing_rule_id IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Rule(g_PRICE_LIST_LINE_rec.pricing_rule_id)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRICING_RULE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.pricing_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.reprice_flag := Get_Reprice;

        IF g_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL THEN

            IF OE_Validate_Attr.Reprice(g_PRICE_LIST_LINE_rec.reprice_flag)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_REPRICE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.reprice_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.revision := Get_Revision;

        IF g_PRICE_LIST_LINE_rec.revision IS NOT NULL THEN

            IF OE_Validate_Attr.Revision(g_PRICE_LIST_LINE_rec.revision)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_REVISION
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.revision_date := Get_Revision_Date;

        IF g_PRICE_LIST_LINE_rec.revision_date IS NOT NULL THEN

            IF OE_Validate_Attr.Revision_Date(g_PRICE_LIST_LINE_rec.revision_date)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_REVISION_DATE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.revision_reason_code := Get_Revision_Reason;

        IF g_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL THEN

            IF OE_Validate_Attr.Revision_Reason(g_PRICE_LIST_LINE_rec.revision_reason_code)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_REVISION_REASON
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision_reason_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.start_date_active := Get_Start_Date_Active;

        IF g_PRICE_LIST_LINE_rec.start_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.Start_Date_Active(g_PRICE_LIST_LINE_rec.start_date_active)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_START_DATE_ACTIVE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.unit_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.unit_code := Get_Unit;

        IF g_PRICE_LIST_LINE_rec.unit_code IS NOT NULL THEN

            IF OE_Validate_Attr.Unit(g_PRICE_LIST_LINE_rec.unit_code)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_UNIT
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.unit_code := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.list_line_type_code := Get_List_Line_Type;

        IF g_PRICE_LIST_LINE_rec.list_line_type_code IS NOT NULL THEN

            IF OE_Validate_Attr.List_Line_Type(g_PRICE_LIST_LINE_rec.list_line_type_code)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_LIST_LINE_TYPE_CODE
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_line_type_code := NULL;
            END IF;

        END IF;

    END IF;

/*

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary := Get_Primary;

        IF g_PRICE_LIST_LINE_rec.primary IS NOT NULL THEN

            IF OE_Validate_Attr.Primary(g_PRICE_LIST_LINE_rec.primary)
            THEN

	        l_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec; --[prarasto]

                OE_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_List_Line_Util.G_PRIMARY
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary := NULL;
            END IF;

        END IF;

    END IF;  */

    IF g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_So_Price_List_Lines;

    END IF;

    IF g_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Pricing_Attributes;

    END IF;

    IF g_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.created_by := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Price_LIST_LINE_rec.creation_date := Get_Start_Date_Active;

        IF g_Price_LIST_LINE_rec.creation_date IS NOT NULL THEN

            IF OE_Validate_Attr.Start_Date_Active(g_Price_LIST_LINE_rec.creation_date)
            THEN
                OE_Price_LIST_LINE_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_LIST_LINE_Util.G_CREATION_DATE
                ,   p_Price_LIST_LINE_rec             => g_Price_LIST_LINE_rec
                ,   x_Price_LIST_LINE_rec             => g_Price_LIST_LINE_rec
                );
            ELSE
                g_Price_LIST_LINE_rec.creation_date := NULL;
            END IF;
	end if;

    --    g_PRICE_LIST_LINE_rec.creation_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.last_updated_by := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.last_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.last_update_login := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.program_application_id := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.program_id := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.program_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.method_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.pricing_rule_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.primary = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.unit_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR
    THEN

        OE_Default_Price_List_Line.Attributes
        (   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PRICE_LIST_LINE_rec         => x_PRICE_LIST_LINE_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;

    END IF;

END Attributes;



END OE_Default_Price_List_Line;

/

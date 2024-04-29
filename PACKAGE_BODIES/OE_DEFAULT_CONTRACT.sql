--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_CONTRACT" AS
/* $Header: OEXDPCTB.pls 115.0 99/07/15 19:21:06 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Contract';

--  Package global used within the package.

g_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;

--  Get functions.

FUNCTION Get_Agreement
RETURN NUMBER
IS
	l_Agreement_Id	NUMBER := NULL;
BEGIN
    oe_debug_pub.add('Entering OE_Default_Contract.Get_Agreement');

/*
    select oe_agreements_s.nextval into l_Agreement_Id
    from dual;

    RETURN l_Agreement_Id;
*/
    oe_debug_pub.add('Exiting OE_Default_Contract.Get_Agreement, agreement_id: '||to_char(l_Agreement_Id));

    RETURN NULL;
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

END Get_Agreement;

FUNCTION Get_Discount
RETURN NUMBER
IS
    l_Discount_Id	NUMBER := NULL;
BEGIN
    oe_debug_pub.add('Entering OE_Default_Contract.Get_Discount');

/*
    select oe_discounts_s.nextval
    into l_Discount_Id
    from dual;

    RETURN l_Discount_Id;
*/

    oe_debug_pub.add('Exiting OE_Default_Contract.Get_Discount, Discount_Id: '||to_char(l_Discount_Id));

RETURN NULL;
END Get_Discount;

FUNCTION Get_Last_Updated_By
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Last_Updated_By;

FUNCTION Get_Price_List
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_List;

FUNCTION Get_Pricing_Contract
RETURN NUMBER
IS
    l_Pricing_Contract_Id	NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering OE_Default_Contract.Get_Pricing_Contract');

    select oe_pricing_contracts_s.nextval into l_Pricing_Contract_Id
    from dual;

    oe_debug_pub.add('Exiting OE_Default_Contract.Get_Pricing_Contract, pricing_contract_id: '||to_char(l_Pricing_Contract_Id));

    RETURN l_Pricing_Contract_Id;

END Get_Pricing_Contract;

PROCEDURE Get_Flex_Contract
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Contract_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute1      := NULL;
    END IF;

    IF g_Contract_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute10     := NULL;
    END IF;

    IF g_Contract_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute11     := NULL;
    END IF;

    IF g_Contract_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute12     := NULL;
    END IF;

    IF g_Contract_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute13     := NULL;
    END IF;

    IF g_Contract_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute14     := NULL;
    END IF;

    IF g_Contract_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute15     := NULL;
    END IF;

    IF g_Contract_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute2      := NULL;
    END IF;

    IF g_Contract_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute3      := NULL;
    END IF;

    IF g_Contract_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute4      := NULL;
    END IF;

    IF g_Contract_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute5      := NULL;
    END IF;

    IF g_Contract_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute6      := NULL;
    END IF;

    IF g_Contract_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute7      := NULL;
    END IF;

    IF g_Contract_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute8      := NULL;
    END IF;

    IF g_Contract_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.attribute9      := NULL;
    END IF;

    IF g_Contract_rec.context = FND_API.G_MISS_CHAR THEN
        g_Contract_rec.context         := NULL;
    END IF;

END Get_Flex_Contract;

--  Procedure Attributes

PROCEDURE Attributes
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_Default_Contract.Attributes');

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Contract_rec

    g_Contract_rec := p_Contract_rec;

    --  Default missing attributes.

    IF g_Contract_rec.agreement_id = FND_API.G_MISS_NUM THEN

        g_Contract_rec.agreement_id := Get_Agreement;

        IF g_Contract_rec.agreement_id IS NOT NULL THEN

            IF OE_Validate_Attr.Agreement(g_Contract_rec.agreement_id)
            THEN
                OE_Contract_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Contract_Util.G_AGREEMENT
                ,   p_Contract_rec                => g_Contract_rec
                ,   x_Contract_rec                => g_Contract_rec
                );
            ELSE
                g_Contract_rec.agreement_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Contract_rec.discount_id = FND_API.G_MISS_NUM THEN

        g_Contract_rec.discount_id := Get_Discount;

        IF g_Contract_rec.discount_id IS NOT NULL THEN

            IF OE_Validate_Attr.Discount(g_Contract_rec.discount_id)
            THEN
                OE_Contract_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Contract_Util.G_DISCOUNT
                ,   p_Contract_rec                => g_Contract_rec
                ,   x_Contract_rec                => g_Contract_rec
                );
            ELSE
                g_Contract_rec.discount_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Contract_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_Contract_rec.last_updated_by := Get_Last_Updated_By;

        IF g_Contract_rec.last_updated_by IS NOT NULL THEN

            IF OE_Validate_Attr.Last_Updated_By(g_Contract_rec.last_updated_by)
            THEN
                OE_Contract_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Contract_Util.G_LAST_UPDATED_BY
                ,   p_Contract_rec                => g_Contract_rec
                ,   x_Contract_rec                => g_Contract_rec
                );
            ELSE
                g_Contract_rec.last_updated_by := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Contract_rec.price_list_id = FND_API.G_MISS_NUM THEN

        g_Contract_rec.price_list_id := Get_Price_List;

        IF g_Contract_rec.price_list_id IS NOT NULL THEN

            IF OE_Validate_Attr.Price_List(g_Contract_rec.price_list_id)
            THEN
                OE_Contract_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Contract_Util.G_PRICE_LIST
                ,   p_Contract_rec                => g_Contract_rec
                ,   x_Contract_rec                => g_Contract_rec
                );
            ELSE
                g_Contract_rec.price_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM THEN

        g_Contract_rec.pricing_contract_id := Get_Pricing_Contract;

        IF g_Contract_rec.pricing_contract_id IS NOT NULL THEN

            IF OE_Validate_Attr.Pricing_Contract(g_Contract_rec.pricing_contract_id)
            THEN
                OE_Contract_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Contract_Util.G_PRICING_CONTRACT
                ,   p_Contract_rec                => g_Contract_rec
                ,   x_Contract_rec                => g_Contract_rec
                );
            ELSE
                g_Contract_rec.pricing_contract_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Contract_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Contract;

    END IF;

    IF g_Contract_rec.created_by = FND_API.G_MISS_NUM THEN

        g_Contract_rec.created_by := NULL;

    END IF;

    IF g_Contract_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Contract_rec.creation_date := NULL;

    END IF;

    IF g_Contract_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_Contract_rec.last_update_date := NULL;

    END IF;

    IF g_Contract_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_Contract_rec.last_update_login := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Contract_rec.agreement_id = FND_API.G_MISS_NUM
    OR  g_Contract_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.context = FND_API.G_MISS_CHAR
    OR  g_Contract_rec.created_by = FND_API.G_MISS_NUM
    OR  g_Contract_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_Contract_rec.discount_id = FND_API.G_MISS_NUM
    OR  g_Contract_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_Contract_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_Contract_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_Contract_rec.price_list_id = FND_API.G_MISS_NUM
    OR  g_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM
    THEN

        OE_Default_Contract.Attributes
        (   p_Contract_rec                => g_Contract_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Contract_rec                => x_Contract_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Contract_rec := g_Contract_rec;
        oe_debug_pub.add('Agreement_Id : ' || to_char(g_Contract_rec.agreement_id));
        oe_debug_pub.add('Discount_Id : ' || to_char(g_Contract_rec.discount_id));

    END IF;

    oe_debug_pub.add('Exiting OE_Default_Contract.Attributes');

END Attributes;

END OE_Default_Contract;

/

--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_MODIFIER_LIST" AS
/* $Header: QPXDMLHB.pls 120.6 2005/09/27 12:32:44 spgopal ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Modifier_List';

--  Package global used within the package.

g_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;

--  Get functions.

FUNCTION Get_Automatic
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Automatic;

FUNCTION Get_Comments
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comments;

FUNCTION Get_Currency
RETURN VARCHAR2
IS
l_set_of_books_id VARCHAR2(255) := '';
l_currency_code VARCHAR2(15) := '';
l_org_id NUMBER;
BEGIN

  oe_debug_Pub.add('entering currency');
  -- MKARYA for bug 1745313, commented out the procedure call FND_PROFILE.GET() and instead using the
  -- function oe_sys_parameters.value() to get the default currency.
     --added for moac to call Oe_sys_params only if org_id is not null
     l_org_id := QP_UTIL.get_org_id;
     IF l_org_id IS NOT NULL THEN
       l_set_of_books_id := oe_sys_parameters.value('SET_OF_BOOKS_ID', l_org_id);
     ELSE
       l_set_of_books_id := null;
     END IF;--if l_org_id
--   FND_PROFILE.GET('OE_SET_OF_BOOKS_ID', l_set_of_books_id);

  IF l_set_of_books_id is not null THEN

   SELECT CURRENCY_CODE
   INTO l_currency_code
   FROM GL_SETS_OF_BOOKS
   WHERE SET_OF_BOOKS_ID = l_set_of_books_id;

  END IF;

  oe_debug_Pub.add('exiting currency');

  RETURN l_currency_code;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN RETURN NULL;

     WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Currency'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Get_Currency;

FUNCTION Get_Discount_Lines
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Discount_Lines;

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

FUNCTION Get_Gsa_Indicator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Gsa_Indicator;

FUNCTION Get_List_Header
RETURN NUMBER
IS
l_list_header_id NUMBER := FND_API.G_MISS_NUM;
BEGIN

    select QP_LIST_HEADERS_B_S.nextval
    into   l_list_header_id
    from   dual;

    RETURN l_list_header_id;

END Get_List_Header;

FUNCTION Get_List_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_List_Type;

FUNCTION Get_Prorate
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Prorate;

FUNCTION Get_Rounding_Factor
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Rounding_Factor;

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

FUNCTION Get_Start_Date_Active_First
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active_First;

FUNCTION Get_End_Date_Active_First
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active_First;

FUNCTION Get_Active_Date_First_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Active_Date_First_Type;

FUNCTION Get_Start_Date_Active_Second
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active_Second;

FUNCTION Get_Global_Flag
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Global_Flag;

FUNCTION Get_End_Date_Active_Second
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active_Second;

FUNCTION Get_Active_Date_Second_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Active_Date_Second_Type;

FUNCTION Get_Terms
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Terms;

FUNCTION Get_Parent_List_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Parent_List_Header;

FUNCTION Get_Version_No
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Version_no;

FUNCTION Get_Ask_For
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Ask_For;

FUNCTION Get_Source_System
RETURN VARCHAR2
IS
l_source_system_code VARCHAR2(30);
BEGIN

    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE',l_source_system_code);
    RETURN l_source_system_code;

END Get_Source_System;

-- Added for attribute manager change
FUNCTION Get_Pte_Code
RETURN VARCHAR2
IS
l_pte_code VARCHAR2(30);
BEGIN

    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);
    if l_pte_code is NULL then
       l_pte_code := 'ORDFUL';
    end if;

    RETURN l_pte_code;

END Get_Pte_Code;

FUNCTION Get_Active
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Active;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_List_Source_Code
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_List_Source_Code;

FUNCTION Get_Orig_System_Header_Ref
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Orig_System_Header_Ref;

FUNCTION Get_Shareable_Flag
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Shareable_Flag;

--added for MOAC
FUNCTION Get_Org_Id
RETURN NUMBER
IS BEGIN

    RETURN QP_UTIL.Get_Org_Id;

END Get_Org_Id;

PROCEDURE Get_Flex_Modifier_List
IS
BEGIN

    oe_debug_pub.add('BEGIN get_flex_modifier_list in QPXDMLHB');

    --  In the future call Flex APIs for defaults

    IF g_MODIFIER_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute1 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute10 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute11 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute12 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute13 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute14 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute15 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute2 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute3 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute4 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute5 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute6 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute7 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute8 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.attribute9 := NULL;
    END IF;

    IF g_MODIFIER_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.context    := NULL;
    END IF;

    oe_debug_pub.add('END get_flex_modifier_list in QPXDMLHB');
END Get_Flex_Modifier_List;

--  Procedure Attributes

PROCEDURE Attributes
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_iteration                     IN  NUMBER := 1
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_MODIFIER_LIST_rec	QP_Modifiers_PUB.Modifier_List_Rec_Type; --[prarasto]
BEGIN

    oe_debug_pub.add('BEGIN attributes in QPXDMLHB');
    --  Check number of iterations.

    oe_debug_pub.add('BEGIN '||to_char(QP_GLOBALS.G_MAX_DEF_ITERATIONS)||' '||to_char(p_iteration));
    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

    oe_debug_pub.add('EXP');
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_MODIFIER_LIST_rec

    g_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    --  Default missing attributes.


    IF g_MODIFIER_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.automatic_flag := Get_Automatic;

        IF g_MODIFIER_LIST_rec.automatic_flag IS NOT NULL THEN

            IF QP_Validate.Automatic(g_MODIFIER_LIST_rec.automatic_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('auto_flag QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_AUTOMATIC
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.automatic_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.comments = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.comments := Get_Comments;

        IF g_MODIFIER_LIST_rec.comments IS NOT NULL THEN

            IF QP_Validate.Comments(g_MODIFIER_LIST_rec.comments)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('comm QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_COMMENTS
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.comments := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.currency_code := Get_Currency;

        IF g_MODIFIER_LIST_rec.currency_code IS NOT NULL THEN

            IF QP_Validate.Currency(g_MODIFIER_LIST_rec.currency_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_CURRENCY
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.currency_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.discount_lines_flag := Get_Discount_Lines;

        IF g_MODIFIER_LIST_rec.discount_lines_flag IS NOT NULL THEN

            IF QP_Validate.Discount_Lines(g_MODIFIER_LIST_rec.discount_lines_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('disc QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_DISCOUNT_LINES
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.discount_lines_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.end_date_active := Get_End_Date_Active;

        IF g_MODIFIER_LIST_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_MODIFIER_LIST_rec.end_date_active)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('enddate QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_END_DATE_ACTIVE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.freight_terms_code := Get_Freight_Terms;

        IF g_MODIFIER_LIST_rec.freight_terms_code IS NOT NULL THEN

            IF QP_Validate.Freight_Terms(g_MODIFIER_LIST_rec.freight_terms_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('freight QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_FREIGHT_TERMS
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.freight_terms_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.gsa_indicator := Get_Gsa_Indicator;

        IF g_MODIFIER_LIST_rec.gsa_indicator IS NOT NULL THEN

            IF QP_Validate.Gsa_Indicator(g_MODIFIER_LIST_rec.gsa_indicator)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

    oe_debug_pub.add('gsa QPXDMLHB');
                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_GSA_INDICATOR
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.gsa_indicator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.list_header_id := Get_List_Header;

        IF g_MODIFIER_LIST_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_MODIFIER_LIST_rec.list_header_id)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_LIST_HEADER
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.parent_list_header_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.parent_list_header_id := Get_Parent_List_Header;

        IF g_MODIFIER_LIST_rec.parent_list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_MODIFIER_LIST_rec.parent_list_header_id)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_PARENT_LIST_HEADER_ID
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.parent_list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.list_type_code := Get_List_Type;

        IF g_MODIFIER_LIST_rec.list_type_code IS NOT NULL THEN

            IF QP_Validate.List_Type(g_MODIFIER_LIST_rec.list_type_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_LIST_TYPE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.list_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.prorate_flag := Get_Prorate;

        IF g_MODIFIER_LIST_rec.prorate_flag IS NOT NULL THEN

            IF QP_Validate.Prorate(g_MODIFIER_LIST_rec.prorate_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_PRORATE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.prorate_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.rounding_factor := Get_Rounding_Factor;

        IF g_MODIFIER_LIST_rec.rounding_factor IS NOT NULL THEN

            IF QP_Validate.Rounding_Factor(g_MODIFIER_LIST_rec.rounding_factor)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ROUNDING_FACTOR
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.ship_method_code := Get_Ship_Method;

        IF g_MODIFIER_LIST_rec.ship_method_code IS NOT NULL THEN

            IF QP_Validate.Ship_Method(g_MODIFIER_LIST_rec.ship_method_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_SHIP_METHOD
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.ship_method_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.ask_for_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.ask_for_flag := Get_Ask_For;

        IF g_MODIFIER_LIST_rec.ask_for_flag IS NOT NULL THEN

            IF QP_Validate.Ask_For(g_MODIFIER_LIST_rec.ask_for_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ASK_FOR
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.ask_for_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.source_system_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.source_system_code := Get_Source_System;

        IF g_MODIFIER_LIST_rec.source_system_code IS NOT NULL THEN

            IF QP_Validate.Source_System(g_MODIFIER_LIST_rec.source_system_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_SOURCE_SYSTEM_CODE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.source_system_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.pte_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.pte_code := Get_Pte_Code;

        IF g_MODIFIER_LIST_rec.pte_code IS NOT NULL THEN

            IF QP_Validate.Pte_Code(g_MODIFIER_LIST_rec.pte_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_PTE_CODE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.pte_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.active_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.active_flag := Get_Active;

        IF g_MODIFIER_LIST_rec.active_flag IS NOT NULL THEN

            IF QP_Validate.Active(g_MODIFIER_LIST_rec.active_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ACTIVE_FLAG
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.active_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.name = FND_API.G_MISS_CHAR THEN

    oe_debug_pub.add('before get_name');
        g_MODIFIER_LIST_rec.name := Get_Name;

        IF g_MODIFIER_LIST_rec.name IS NOT NULL THEN

            IF QP_Validate.Name(g_MODIFIER_LIST_rec.name)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_NAME
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.description = FND_API.G_MISS_CHAR THEN

    oe_debug_pub.add('before get_desr');
        g_MODIFIER_LIST_rec.description := Get_Description;

        IF g_MODIFIER_LIST_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_MODIFIER_LIST_rec.description)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_DESCRIPTION
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.description := NULL;
            END IF;

        END IF;

    END IF;


    IF g_MODIFIER_LIST_rec.version_no = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.version_no := Get_Version_No;

         IF g_MODIFIER_LIST_rec.version_no IS NOT NULL THEN

            IF QP_Validate.Version(g_MODIFIER_LIST_rec.version_no)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_VERSION_NO
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.version_no := NULL;
            END IF;

        END IF;

    END IF;


    IF g_MODIFIER_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.start_date_active := Get_Start_Date_Active;

        IF g_MODIFIER_LIST_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_MODIFIER_LIST_rec.start_date_active)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_START_DATE_ACTIVE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.start_date_active_first = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.start_date_active_first := Get_Start_Date_Active_First;

        IF g_MODIFIER_LIST_rec.start_date_active_first IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active_First(g_MODIFIER_LIST_rec.start_date_active_first)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_START_DATE_ACTIVE_FIRST
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.start_date_active_first := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.end_date_active_first = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.end_date_active_first := Get_End_Date_Active_First;

        IF g_MODIFIER_LIST_rec.end_date_active_first IS NOT NULL THEN

            IF QP_Validate.End_Date_Active_First(g_MODIFIER_LIST_rec.end_date_active_first)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_END_DATE_ACTIVE_FIRST
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.end_date_active_first := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.active_date_first_type = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.active_date_first_type := Get_Active_Date_First_Type;

        IF g_MODIFIER_LIST_rec.active_date_first_type IS NOT NULL THEN

            IF QP_Validate.Active_Date_First_Type(g_MODIFIER_LIST_rec.active_date_first_type)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ACTIVE_DATE_FIRST_TYPE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.active_date_first_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.start_date_active_second = FND_API.G_MISS_DATE THEN
        g_MODIFIER_LIST_rec.start_date_active_second := Get_Start_Date_Active_Second;
        IF g_MODIFIER_LIST_rec.start_date_active_second IS NOT NULL THEN
            IF QP_Validate.Start_Date_Active_Second(g_MODIFIER_LIST_rec.start_date_active_second)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_START_DATE_ACTIVE_SECOND
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.start_date_active_second := NULL;
            END IF;
        END IF;
    END IF;

    IF g_MODIFIER_LIST_rec.global_flag = FND_API.G_MISS_CHAR THEN
        g_MODIFIER_LIST_rec.global_flag := Get_Global_Flag;
        IF g_MODIFIER_LIST_rec.global_flag IS NOT NULL THEN
            IF QP_Validate.Global_Flag(g_MODIFIER_LIST_rec.global_flag)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_GLOBAL_FLAG
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.global_flag := NULL;
            END IF;
        END IF;
    END IF;


    IF g_MODIFIER_LIST_rec.end_date_active_second = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.end_date_active_second := Get_End_Date_Active_Second;

        IF g_MODIFIER_LIST_rec.end_date_active_second IS NOT NULL THEN

            IF QP_Validate.End_Date_Active_Second(g_MODIFIER_LIST_rec.end_date_active_second)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_END_DATE_ACTIVE_SECOND
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.end_date_active_second := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.active_date_second_type = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.active_date_second_type := Get_Active_Date_Second_Type;

        IF g_MODIFIER_LIST_rec.active_date_second_type IS NOT NULL THEN

            IF QP_Validate.Active_Date_Second_Type(g_MODIFIER_LIST_rec.active_date_second_type)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ACTIVE_DATE_SECOND_TYPE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.active_date_second_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIER_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.terms_id := Get_Terms;

        IF g_MODIFIER_LIST_rec.terms_id IS NOT NULL THEN

            IF QP_Validate.Terms(g_MODIFIER_LIST_rec.terms_id)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_TERMS
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.terms_id := NULL;
            END IF;

        END IF;

    END IF;

-- Blanket Pricing
    IF g_MODIFIER_LIST_rec.orig_system_header_ref = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.orig_system_header_ref := Get_Orig_System_Header_Ref;

        IF g_MODIFIER_LIST_rec.orig_system_header_ref IS NOT NULL THEN

            IF QP_Validate.Orig_System_Header_Ref(g_MODIFIER_LIST_rec.orig_system_header_ref)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_ORIG_SYSTEM_HEADER_REF
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.orig_system_header_ref := NULL;
            END IF;

        END IF;

    END IF;


    IF g_MODIFIER_LIST_rec.list_source_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIER_LIST_rec.list_source_code := Get_List_Source_Code;

        IF g_MODIFIER_LIST_rec.list_source_code IS NOT NULL THEN

            IF QP_Validate.List_Source_Code(g_MODIFIER_LIST_rec.list_source_code)
            THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifier_List_Util.G_LIST_SOURCE_CODE
                ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
                );
            ELSE
                g_MODIFIER_LIST_rec.list_source_code := NULL;
            END IF;

        END IF;

    END IF;

    --added for MOAC
    IF g_MODIFIER_LIST_rec.org_id = FND_API.G_MISS_NUM THEN

      IF  g_MODIFIER_LIST_rec.global_flag = 'N' THEN
       --global_flag defaulting happens before org_id defaulting
        g_MODIFIER_LIST_rec.org_id := Get_Org_Id;
      ELSE
        g_MODIFIER_LIST_rec.org_id := null;
      END IF;

       IF g_MODIFIER_LIST_rec.org_id IS NOT NULL THEN

           IF QP_Validate.Org_id(g_MODIFIER_LIST_rec.org_id) THEN

	        l_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec; --[prarasto]

                QP_Modifier_List_Util.Clear_Dependent_Attr
                (   p_attr_id    => QP_Modifier_List_Util.G_ORG_ID
                ,   p_MODIFIER_LIST_rec   => l_MODIFIER_LIST_rec
                ,   x_MODIFIER_LIST_rec              => g_MODIFIER_LIST_rec
                );
            ELSE
              oe_debug_pub.add('setting ORG_ID to be null');
              g_MODIFIER_LIST_rec.org_id := NULL;
            END IF;

        END IF;
    END IF;


    IF g_MODIFIER_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Modifier_List;

    END IF;

    IF g_MODIFIER_LIST_rec.created_by = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.created_by := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.creation_date := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.last_updated_by := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.last_update_date := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.last_update_login := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.program_application_id := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.program_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.program_id := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_MODIFIER_LIST_rec.program_update_date := NULL;

    END IF;

    IF g_MODIFIER_LIST_rec.request_id = FND_API.G_MISS_NUM THEN

        g_MODIFIER_LIST_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_MODIFIER_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.comments = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.context = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.created_by = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.currency_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.list_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.program_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.request_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.rounding_factor = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.terms_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.parent_list_header_id = FND_API.G_MISS_NUM
    OR  g_MODIFIER_LIST_rec.source_system_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.pte_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.active_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.start_date_active_first = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.end_date_active_first = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.active_date_first_type = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.start_date_active_second = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.global_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.end_date_active_second = FND_API.G_MISS_DATE
    OR  g_MODIFIER_LIST_rec.active_date_second_type = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.ask_for_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.name = FND_API.G_MISS_CHAR
    OR  g_MODIFIER_LIST_rec.description = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Modifier_List.Attributes
        (   p_MODIFIER_LIST_rec           => g_MODIFIER_LIST_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_MODIFIER_LIST_rec           => x_MODIFIER_LIST_rec
        );

    ELSE

        --  Done defaulting attributes

        x_MODIFIER_LIST_rec := g_MODIFIER_LIST_rec;

    END IF;


    oe_debug_pub.add('END attributes in QPXDMLHB');


END Attributes;

END QP_Default_Modifier_List;

/

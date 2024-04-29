--------------------------------------------------------
--  DDL for Package Body QP_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ID_TO_VALUE" AS
/* $Header: QPXSIDVB.pls 120.1 2005/07/15 15:44:22 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Id_To_Value';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_lines';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prorate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'base_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'generate_using_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'gl_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_price_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modifier_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'override';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_break_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_by_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'print_on_invoice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_subtype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_transaction_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'related_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'relationship_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reprice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision_reason';
    --I := I + 1;
    --FND_API.g_attr_tbl(I).name     := 'comparison_operator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_from_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'excluder';
    --I := I + 1;
    --FND_API.g_attr_tbl(I).name     := 'qualifier';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accumulate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_price_attrib';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula_line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_modifier_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_exceed_action';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'comparison_operator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_balance';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'base_currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'row';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_detail';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'markup_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prc_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_valueset';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_valueset';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lookup';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte_source_system';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment_pte';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'attribute_sourcing';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'functional_area';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte_sourcesystem_fnarea';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.


FUNCTION Automatic
(   p_automatic_flag                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_automatic                   VARCHAR2(240) := NULL;
BEGIN

    IF p_automatic_flag IS NOT NULL THEN

        --  SELECT  AUTOMATIC
        --  INTO    l_automatic
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_automatic_flag;

        NULL;

    END IF;

    RETURN l_automatic;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic;

FUNCTION Currency
(   p_currency_code                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_currency                    VARCHAR2(240) := NULL;
BEGIN

    IF p_currency_code IS NOT NULL THEN

        --  SELECT  CURRENCY
        --  INTO    l_currency
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_currency_code;

        NULL;

    END IF;

    RETURN l_currency;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;

FUNCTION Discount_Lines
(   p_discount_lines_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_discount_lines              VARCHAR2(240) := NULL;
BEGIN

    IF p_discount_lines_flag IS NOT NULL THEN

        --  SELECT  DISCOUNT_LINES
        --  INTO    l_discount_lines
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_discount_lines_flag;

        NULL;

    END IF;

    RETURN l_discount_lines;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Lines;

/* FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_freight_terms               VARCHAR2(240) := NULL;
BEGIN

    IF p_freight_terms_code IS NOT NULL THEN

        --  SELECT  FREIGHT_TERMS
        --  INTO    l_freight_terms
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_freight_terms_code;

        NULL;

    END IF;

    RETURN l_freight_terms;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;
*/

FUNCTION List_Header
(   p_list_header_id                IN  NUMBER
) RETURN VARCHAR2
IS
l_list_header                 VARCHAR2(240) := NULL;
BEGIN

    IF p_list_header_id IS NOT NULL THEN

        --  SELECT  LIST_HEADER
        --  INTO    l_list_header
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_list_header_id;

        NULL;

    END IF;

    RETURN l_list_header;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Header;

FUNCTION List_Type
(   p_list_type_code                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_list_type                   VARCHAR2(240) := NULL;
BEGIN

    IF p_list_type_code IS NOT NULL THEN

     SELECT  MEANING
     INTO    l_list_type
     FROM    QP_LOOKUPS
     WHERE   LOOKUP_CODE = p_list_type_code
     AND     LOOKUP_TYPE = 'LIST_TYPE_CODE';

    END IF;

    RETURN l_list_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Type;

FUNCTION Prorate
(   p_prorate_flag                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_prorate                     VARCHAR2(240) := NULL;
BEGIN

    IF p_prorate_flag IS NOT NULL THEN

        --  SELECT  PRORATE
        --  INTO    l_prorate
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_prorate_flag;

        NULL;

    END IF;

    RETURN l_prorate;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prorate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prorate;

/* FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_ship_method                 VARCHAR2(240) := NULL;
BEGIN

    IF p_ship_method_code IS NOT NULL THEN

        --  SELECT  SHIP_METHOD
        --  INTO    l_ship_method
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_ship_method_code;

        NULL;

    END IF;

    RETURN l_ship_method;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Method; */

FUNCTION Terms
(   p_terms_id                      IN  NUMBER
) RETURN VARCHAR2
IS
l_terms                       VARCHAR2(240) := NULL;
BEGIN

    IF p_terms_id IS NOT NULL THEN

        --  SELECT  TERMS
        --  INTO    l_terms
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_terms_id;

        NULL;

    END IF;

    RETURN l_terms;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Terms;

FUNCTION Base_Uom
(   p_base_uom_code                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_base_uom                    VARCHAR2(240) := NULL;
BEGIN

    IF p_base_uom_code IS NOT NULL THEN

        --  SELECT  BASE_UOM
        --  INTO    l_base_uom
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_base_uom_code;

        NULL;

    END IF;

    RETURN l_base_uom;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Uom;

FUNCTION Generate_Using_Formula
(   p_generate_using_formula_id     IN  NUMBER
) RETURN VARCHAR2
IS
l_generate_using_formula      VARCHAR2(240) := NULL;
BEGIN

    IF p_generate_using_formula_id IS NOT NULL THEN

	  select name
	  into l_generate_using_formula
	  from qp_price_formulas_vl
	  where price_formula_id = p_generate_using_formula_id;


        --  SELECT  GENERATE_USING_FORMULA
        --  INTO    l_generate_using_formula
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_generate_using_formula_id;


    END IF;

    RETURN l_generate_using_formula;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','generate_using_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Generate_Using_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Generate_Using_Formula;

/* FUNCTION Gl_Class
(   p_gl_class_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_gl_class                    VARCHAR2(240) := NULL;
BEGIN

    IF p_gl_class_id IS NOT NULL THEN

        --  SELECT  GL_CLASS
        --  INTO    l_gl_class
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_gl_class_id;

        NULL;

    END IF;

    RETURN l_gl_class;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','gl_class');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gl_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Gl_Class;  */

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_inventory_item              VARCHAR2(240) := NULL;
BEGIN

    IF p_inventory_item_id IS NOT NULL THEN

        --  SELECT  INVENTORY_ITEM
        --  INTO    l_inventory_item
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_inventory_item_id;

        NULL;

    END IF;

    RETURN l_inventory_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

FUNCTION List_Line
(   p_list_line_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_list_line                   VARCHAR2(240) := NULL;
BEGIN

    IF p_list_line_id IS NOT NULL THEN

        --  SELECT  LIST_LINE
        --  INTO    l_list_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_list_line_id;

        NULL;

    END IF;

    RETURN l_list_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line;

FUNCTION List_Line_Type
(   p_list_line_type_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_list_line_type              VARCHAR2(80) := NULL;
BEGIN

    IF p_list_line_type_code IS NOT NULL THEN

	  select meaning
	  into  l_list_line_type
	  from qp_lookups
	  where lookup_code = p_list_line_type_code
	  and lookup_type = 'LIST_LINE_TYPE_CODE';


        --  SELECT  LIST_LINE_TYPE
        --  INTO    l_list_line_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_list_line_type_code;

    END IF;

    RETURN l_list_line_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_Type;

FUNCTION List_Price_Uom
(   p_list_price_uom_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_list_price_uom              VARCHAR2(240) := NULL;
BEGIN

    IF p_list_price_uom_code IS NOT NULL THEN

        --  SELECT  LIST_PRICE_UOM
        --  INTO    l_list_price_uom
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_list_price_uom_code;

        NULL;

    END IF;

    RETURN l_list_price_uom;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_price_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Price_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Price_Uom;

FUNCTION Modifier_Level
(   p_modifier_level_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_modifier_level              VARCHAR2(240) := NULL;
BEGIN

    IF p_modifier_level_code IS NOT NULL THEN

        --  SELECT  MODIFIER_LEVEL
        --  INTO    l_modifier_level
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_modifier_level_code;

        NULL;

    END IF;

    RETURN l_modifier_level;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','modifier_level');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifier_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifier_Level;


FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_organization                VARCHAR2(240) := NULL;
BEGIN

    IF p_organization_id IS NOT NULL THEN

        --  SELECT  ORGANIZATION
        --  INTO    l_organization
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_organization_id;

        NULL;

    END IF;

    RETURN l_organization;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;


FUNCTION Organization
(   p_organization_flag               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_organization                VARCHAR2(240) := NULL;
BEGIN

    IF p_organization_flag IS NOT NULL THEN

        --  SELECT  ORGANIZATION
        --  INTO    l_organization
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_organization_flag;

        NULL;

    END IF;

    RETURN l_organization;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION Override
(   p_override_flag                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override                    VARCHAR2(240) := NULL;
BEGIN

    IF p_override_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE
        --  INTO    l_override
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_flag;

        NULL;

    END IF;

    RETURN l_override;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override;

FUNCTION Price_Break_Type
(   p_price_break_type_code         IN  VARCHAR2
) RETURN VARCHAR2
IS
l_price_break_type            VARCHAR2(80) := NULL;
BEGIN

    IF p_price_break_type_code IS NOT NULL THEN

          select meaning
	  into  l_price_break_type
	  from qp_lookups
	  where lookup_code = p_price_break_type_code
	  and lookup_type = 'PRICE_BREAK_TYPE_CODE';

        --  SELECT  PRICE_BREAK_TYPE
        --  INTO    l_price_break_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_break_type_code;


    END IF;

    RETURN l_price_break_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_break_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Break_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Break_Type;

FUNCTION Price_By_Formula
(   p_price_by_formula_id           IN  NUMBER
) RETURN VARCHAR2
IS
l_price_by_formula            VARCHAR2(240) := NULL;
BEGIN

    IF p_price_by_formula_id IS NOT NULL THEN

	  select name
	  into l_price_by_formula
	  from qp_price_formulas_vl
	  where price_formula_id = p_price_by_formula_id;


        --  SELECT  PRICE_BY_FORMULA
        --  INTO    l_price_by_formula
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_by_formula_id;


    END IF;

    RETURN l_price_by_formula;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_by_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_By_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_By_Formula;

FUNCTION Primary_Uom
(   p_primary_uom_flag              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_primary_uom                 VARCHAR2(240) := NULL;
BEGIN

    IF p_primary_uom_flag IS NOT NULL THEN

        --  SELECT  PRIMARY_UOM
        --  INTO    l_primary_uom
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_primary_uom_flag;

        NULL;

    END IF;

    RETURN l_primary_uom;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Uom;

FUNCTION Print_On_Invoice
(   p_print_on_invoice_flag         IN  VARCHAR2
) RETURN VARCHAR2
IS
l_print_on_invoice            VARCHAR2(240) := NULL;
BEGIN

    IF p_print_on_invoice_flag IS NOT NULL THEN

        --  SELECT  PRINT_ON_INVOICE
        --  INTO    l_print_on_invoice
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_print_on_invoice_flag;

        NULL;

    END IF;

    RETURN l_print_on_invoice;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','print_on_invoice');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Print_On_Invoice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Print_On_Invoice;

/* FUNCTION Rebate_Subtype
(   p_rebate_subtype_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_rebate_subtype              VARCHAR2(240) := NULL;
BEGIN

    IF p_rebate_subtype_code IS NOT NULL THEN

        --  SELECT  REBATE_SUBTYPE
        --  INTO    l_rebate_subtype
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_rebate_subtype_code;

        NULL;

    END IF;

    RETURN l_rebate_subtype;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_subtype');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate_Subtype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Subtype; */

FUNCTION Rebate_Transaction_Type
(   p_rebate_trxn_type_code         IN  VARCHAR2
) RETURN VARCHAR2
IS
l_rebate_transaction_type     VARCHAR2(240) := NULL;
BEGIN

    IF p_rebate_trxn_type_code IS NOT NULL THEN

        --  SELECT  REBATE_TRANSACTION_TYPE
        --  INTO    l_rebate_transaction_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_rebate_trxn_type_code;

        NULL;

    END IF;

    RETURN l_rebate_transaction_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_transaction_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate_Transaction_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Transaction_Type;

FUNCTION Related_Item
(   p_related_item_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_related_item                VARCHAR2(240) := NULL;
BEGIN

    IF p_related_item_id IS NOT NULL THEN

        --  SELECT  RELATED_ITEM
        --  INTO    l_related_item
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_related_item_id;

        NULL;

    END IF;

    RETURN l_related_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','related_item');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Related_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Related_Item;

FUNCTION Relationship_Type
(   p_relationship_type_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_relationship_type           VARCHAR2(240) := NULL;
BEGIN

    IF p_relationship_type_id IS NOT NULL THEN

        --  SELECT  RELATIONSHIP_TYPE
        --  INTO    l_relationship_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_relationship_type_id;

        NULL;

    END IF;

    RETURN l_relationship_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','relationship_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Relationship_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Relationship_Type;

FUNCTION Reprice
(   p_reprice_flag                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_reprice                     VARCHAR2(240) := NULL;
BEGIN

    IF p_reprice_flag IS NOT NULL THEN

        --  SELECT  REPRICE
        --  INTO    l_reprice
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_reprice_flag;

        NULL;

    END IF;

    RETURN l_reprice;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reprice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reprice;

/* FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2
IS
l_revision_reason             VARCHAR2(240) := NULL;
BEGIN

    IF p_revision_reason_code IS NOT NULL THEN

        --  SELECT  REVISION_REASON
        --  INTO    l_revision_reason
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_revision_reason_code;

        NULL;

    END IF;

    RETURN l_revision_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason; */

/*FUNCTION Comparison_Operator
(   p_comparison_operator_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_comparison_operator         VARCHAR2(240) := NULL;
BEGIN

    IF p_comparison_operator_code IS NOT NULL THEN

        --  SELECT  COMPARISON_OPERATOR
        --  INTO    l_comparison_operator
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_comparison_operator_code;

        NULL;

    END IF;

    RETURN l_comparison_operator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Comparison_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Comparison_Operator;*/

FUNCTION Created_From_Rule
(   p_created_from_rule_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_created_from_rule           VARCHAR2(240) := NULL;
BEGIN

    IF p_created_from_rule_id IS NOT NULL THEN

         SELECT  name
         INTO    l_created_from_rule
         FROM    QP_QUALIFIER_RULES
         WHERE   qualifier_rule_id = p_created_from_rule_id;


    END IF;

    RETURN l_created_from_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_from_rule');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_From_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_From_Rule;

FUNCTION Excluder
(   p_excluder_flag                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_excluder                    VARCHAR2(240) := NULL;
BEGIN

    IF p_excluder_flag IS NOT NULL THEN

        --  SELECT  EXCLUDER
        --  INTO    l_excluder
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_excluder_flag;

        NULL;

    END IF;

    RETURN l_excluder;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Excluder'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Excluder;

/*
FUNCTION Qualifier
(   p_qualifier_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_qualifier                   VARCHAR2(240) := NULL;
BEGIN

    IF p_qualifier_id IS NOT NULL THEN

        --  SELECT  QUALIFIER
        --  INTO    l_qualifier
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_qualifier_id;

        NULL;

    END IF;

    RETURN l_qualifier;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier;

*/

FUNCTION Qualifier_Rule
(   p_qualifier_rule_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_qualifier_rule              VARCHAR2(240) := NULL;
BEGIN

    IF p_qualifier_rule_id IS NOT NULL THEN

         --SELECT  name
         --INTO    l_qualifier_rule
         --FROM    QP_QUALIFIER_RULES
         --WHERE   qualifier_rule_id = p_qualifier_rule_id;
         null;

    END IF;

    RETURN l_qualifier_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Rule;

FUNCTION Accumulate
(   p_accumulate_flag               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_accumulate                  VARCHAR2(240) := NULL;
BEGIN

    IF p_accumulate_flag IS NOT NULL THEN

        --  SELECT  ACCUMULATE
        --  INTO    l_accumulate
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_accumulate_flag;

        NULL;

    END IF;

    RETURN l_accumulate;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accumulate');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accumulate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accumulate;

FUNCTION Pricing_Attribute
(   p_pricing_attribute_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_pricing_attribute           VARCHAR2(240) := NULL;
BEGIN

    IF p_pricing_attribute_id IS NOT NULL THEN

        --  SELECT  PRICING_ATTRIBUTE
        --  INTO    l_pricing_attribute
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_pricing_attribute_id;

        NULL;

    END IF;

    RETURN l_pricing_attribute;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute;

FUNCTION Product_Uom
(   p_product_uom_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_product_uom                 VARCHAR2(240) := NULL;
BEGIN

    IF p_product_uom_code IS NOT NULL THEN

        --  SELECT  PRODUCT_UOM
        --  INTO    l_product_uom
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_product_uom_code;

        NULL;

    END IF;

    RETURN l_product_uom;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Uom;

FUNCTION Header
(   p_header_id                     IN  NUMBER
) RETURN VARCHAR2
IS
l_header                      VARCHAR2(240) := NULL;
BEGIN

    IF p_header_id IS NOT NULL THEN

        --  SELECT  HEADER
        --  INTO    l_header
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_header_id;

        NULL;

    END IF;

    RETURN l_header;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_line                        VARCHAR2(240) := NULL;
BEGIN

    IF p_line_id IS NOT NULL THEN

        --  SELECT  LINE
        --  INTO    l_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_line_id;

        NULL;

    END IF;

    RETURN l_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Order_Price_Attrib
(   p_order_price_attrib_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_order_price_attrib          VARCHAR2(240) := NULL;
BEGIN

    IF p_order_price_attrib_id IS NOT NULL THEN

        --  SELECT  ORDER_PRICE_ATTRIB
        --  INTO    l_order_price_attrib
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_order_price_attrib_id;

        NULL;

    END IF;

    RETURN l_order_price_attrib;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_price_attrib');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Price_Attrib'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Price_Attrib;



FUNCTION Price_Formula
(   p_price_formula_id              IN  NUMBER
) RETURN VARCHAR2
IS
l_price_formula               VARCHAR2(2000) := NULL;
/* Increased the length of l_price_formula to fix  the bug 1539041 */
BEGIN

    IF p_price_formula_id IS NOT NULL THEN

        --  SELECT  PRICE_FORMULA
        --  INTO    l_price_formula
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_formula_id;

        NULL;

    END IF;

    RETURN l_price_formula;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula;

FUNCTION Price_Formula_Line
(   p_price_formula_line_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_price_formula_line          VARCHAR2(240) := NULL;
BEGIN

    IF p_price_formula_line_id IS NOT NULL THEN

        --  SELECT  PRICE_FORMULA_LINE
        --  INTO    l_price_formula_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_formula_line_id;

        NULL;

    END IF;

    RETURN l_price_formula_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula_Line;

FUNCTION Price_Formula_Line_Type
(   p_formula_line_type_code        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_price_formula_line_type     VARCHAR2(240) := NULL;
BEGIN

    IF p_formula_line_type_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_price_formula_line_type
        FROM    QP_LOOKUPS
        WHERE   LOOKUP_CODE = p_formula_line_type_code
	   AND     LOOKUP_TYPE = 'PRICE_FORMULA_LINE_TYPE_CODE';

    END IF;

    RETURN l_price_formula_line_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line_type');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula_Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula_Line_Type;

FUNCTION Price_List_Line
(   p_price_list_line_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_price_list_line             VARCHAR2(240) := NULL;
BEGIN

    IF p_price_list_line_id IS NOT NULL THEN

        --  SELECT  PRICE_LIST_LINE
        --  INTO    l_price_list_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_list_line_id;

        NULL;

    END IF;

    RETURN l_price_list_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Line;

FUNCTION Arithmetic_Operator
(   p_arithmetic_operator        IN VARCHAR2
) RETURN VARCHAR2
IS
l_arithmetic_operator         VARCHAR2(80) := NULL;
BEGIN

    IF p_arithmetic_operator IS NOT NULL THEN

	   select meaning
	   into l_arithmetic_operator
	   from qp_lookups
	   where lookup_code = p_arithmetic_operator
	   and lookup_type = 'ARITHMETIC_OPERATOR';

    END IF;

    RETURN l_arithmetic_operator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','arithmetic_operator');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Arithmetic_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Arithmetic_Operator;

FUNCTION Price_Modifier_List
(   p_price_modifier_list_id        IN  NUMBER
) RETURN VARCHAR2
IS
l_price_modifier_list         VARCHAR2(240) := NULL;
BEGIN

    IF p_price_modifier_list_id IS NOT NULL THEN

        --  SELECT  PRICE_MODIFIER_LIST
        --  INTO    l_price_modifier_list
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_price_modifier_list_id;

        NULL;

    END IF;

    RETURN l_price_modifier_list;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_modifier_list');
            oe_msg_pub.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Modifier_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Modifier_List;




FUNCTION Accounting_Rule
(   p_accounting_rule_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_accounting_rule             VARCHAR2(240) := NULL;
BEGIN

    IF p_accounting_rule_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_accounting_rule
        FROM    OE_RA_RULES_V
        WHERE   RULE_ID = p_accounting_rule_id;

    END IF;

    RETURN l_accounting_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accounting_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accounting_Rule;



FUNCTION Agreement
(   p_agreement_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_agreement                   VARCHAR2(240) := NULL;
BEGIN

    IF p_agreement_id IS NOT NULL THEN

        --SELECT  NAME
        --INTO    l_agreement
        --FROM    OE_AGREEMENTS_V
        --WHERE   AGREEMENT_ID = p_agreement_id;

	NULL;

    END IF;

    RETURN l_agreement;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement;




FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_freight_terms               VARCHAR2(240) := NULL;
BEGIN

    IF p_freight_terms_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_freight_terms
        FROM    QP_LOOKUPS
        WHERE   LOOKUP_CODE = p_freight_terms_code
        AND     LOOKUP_TYPE = 'FREIGHT_TERMS';

    END IF;

    RETURN l_freight_terms;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;


FUNCTION Invoice_To_Contact
(   p_invoice_to_contact_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_to_contact          VARCHAR2(240) := NULL;
BEGIN

    IF p_invoice_to_contact_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_invoice_to_contact
        FROM    OE_CONTACTS_V
        WHERE   CONTACT_ID = p_invoice_to_contact_id;

    END IF;

    RETURN l_invoice_to_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Contact;



FUNCTION Invoicing_Rule
(   p_invoicing_rule_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_invoicing_rule              VARCHAR2(240) := NULL;
BEGIN

    IF p_invoicing_rule_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_invoicing_rule
        FROM    OE_RA_RULES_V
        WHERE   RULE_ID = p_invoicing_rule_id;

    END IF;

    RETURN l_invoicing_rule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoicing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoicing_Rule;




FUNCTION Payment_Term
(   p_payment_term_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_payment_term                VARCHAR2(240) := NULL;
BEGIN

    IF p_payment_term_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_payment_term
        FROM    OE_RA_TERMS_V
        WHERE   TERM_ID = p_payment_term_id;

    END IF;

    RETURN l_payment_term;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Term;


FUNCTION Price_List
(   p_price_list_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_price_list                  VARCHAR2(240) := NULL;
BEGIN

    IF p_price_list_id IS NOT NULL THEN

        SELECT  NAME
        INTO    l_price_list
        FROM    qp_list_headers_vl
        WHERE   list_header_id = p_price_list_id and
			list_type_code='PRL';

    END IF;

    RETURN l_price_list;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;



FUNCTION Salesrep
(   p_salesrep_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_salesrep                    VARCHAR2(240) := NULL;
cursor c_salesrep(p_salesrep_id number) is
       select name
       from ra_salesreps
       where salesrep_id = p_salesrep_id;
BEGIN

    IF p_salesrep_id IS NOT NULL THEN
        open c_salesrep(p_salesrep_id);
        fetch c_salesrep into  l_salesrep;
        close c_salesrep;
    END IF;

    RETURN l_salesrep;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Salesrep'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Salesrep;


FUNCTION Agreement_Contact
(   p_agreement_contact_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_agreement_contact           VARCHAR2(240) := NULL;
BEGIN

    IF p_agreement_contact_id IS NOT NULL THEN

        --  SELECT  AGREEMENT_CONTACT
        --  INTO    l_agreement_contact
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_agreement_contact_id;

        NULL;

    END IF;

    RETURN l_agreement_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Contact;



FUNCTION Agreement_Type
(   p_agreement_type_code           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_agreement_type              VARCHAR2(240) := NULL;
BEGIN

    IF p_agreement_type_code IS NOT NULL THEN

        --  SELECT  AGREEMENT_TYPE
        --  INTO    l_agreement_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_agreement_type_code;

        NULL;

    END IF;

    RETURN l_agreement_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Type;




FUNCTION Invoice_Contact
(   p_invoice_contact_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_contact             VARCHAR2(240) := NULL;
BEGIN

    IF p_invoice_contact_id IS NOT NULL THEN

        --  SELECT  INVOICE_CONTACT
        --  INTO    l_invoice_contact
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_invoice_contact_id;

        NULL;

    END IF;

    RETURN l_invoice_contact;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_contact');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Invoice_Contact;


FUNCTION Invoice_To_Site_Use
(   p_invoice_to_org_id        IN  NUMBER
) RETURN VARCHAR2
IS
l_invoice_to_site_use         VARCHAR2(240) := NULL;
BEGIN

    IF p_invoice_to_org_id IS NOT NULL THEN

        --  SELECT  INVOICE_TO_SITE_USE
        --  INTO    l_invoice_to_site_use
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_invoice_to_org_id;

        NULL;

    END IF;

    RETURN l_invoice_to_site_use;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_site_use');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Site_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Site_Use;


FUNCTION Override_Arule
(   p_override_arule_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override_arule              VARCHAR2(240) := NULL;
BEGIN

    IF p_override_arule_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE_ARULE
        --  INTO    l_override_arule
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_arule_flag;

        NULL;

    END IF;

    RETURN l_override_arule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_arule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Arule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Override_Arule;


FUNCTION Override_Irule
(   p_override_irule_flag           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_override_irule              VARCHAR2(240) := NULL;
BEGIN

    IF p_override_irule_flag IS NOT NULL THEN

        --  SELECT  OVERRIDE_IRULE
        --  INTO    l_override_irule
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_override_irule_flag;

        NULL;

    END IF;

    RETURN l_override_irule;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_irule');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Irule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Irule;


FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2
IS
l_revision_reason             VARCHAR2(240) := NULL;
BEGIN

    IF p_revision_reason_code IS NOT NULL THEN

        --  SELECT  REVISION_REASON
        --  INTO    l_revision_reason
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_revision_reason_code;

        NULL;

    END IF;

    RETURN l_revision_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason;


FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_ship_method                 VARCHAR2(240) := NULL;
BEGIN

    IF p_ship_method_code IS NOT NULL THEN

          SELECT  meaning
          INTO    l_ship_method
          FROM    oe_ship_methods_v
          WHERE   lookup_code = p_ship_method_code;

        NULL;

    END IF;

    RETURN l_ship_method;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Method;

--Begin code added by rchellam for OKC

FUNCTION Agreement_Source
(   p_agreement_source_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_agreement_source               VARCHAR2(240) := NULL;
BEGIN

    IF p_agreement_source_code IS NOT NULL THEN

          SELECT  meaning
          INTO    l_agreement_source
          FROM    qp_lookups
          WHERE   lookup_code = p_agreement_source_code
          AND     lookup_type = 'AGREEMENT_SOURCE_CODE';

    END IF;

    RETURN l_agreement_source;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_source');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Source;
--Begin code added by rchellam for OKC


FUNCTION Term
(   p_term_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_term                        VARCHAR2(240) := NULL;
BEGIN

    IF p_term_id IS NOT NULL THEN

        --  SELECT  TERM
        --  INTO    l_term
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_term_id;

        NULL;

    END IF;

    RETURN l_term;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','term');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Term;

FUNCTION Customer
(   p_sold_to_org_id                   IN  NUMBER
) RETURN VARCHAR2
IS
l_customer                    VARCHAR2(240) := NULL;
BEGIN

    IF p_sold_to_org_id IS NOT NULL THEN

        --  SELECT  CUSTOMER
        --  INTO    l_customer
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_sold_to_org_id;

        NULL;

    END IF;

    RETURN l_customer;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('QP','QP_ID_TO__VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer;



FUNCTION Limit_Exceed_Action
(   p_limit_exceed_action_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_limit_exceed_action         VARCHAR2(240) := NULL;
BEGIN

    IF p_limit_exceed_action_code IS NOT NULL THEN

        --  SELECT  LIMIT_EXCEED_ACTION
        --  INTO    l_limit_exceed_action
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_limit_exceed_action_code;

        NULL;

    END IF;

    RETURN l_limit_exceed_action;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_exceed_action');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Exceed_Action'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Exceed_Action;

FUNCTION Limit
(   p_limit_id                      IN  NUMBER
) RETURN VARCHAR2
IS
l_limit                       VARCHAR2(240) := NULL;
BEGIN

    IF p_limit_id IS NOT NULL THEN

        --  SELECT  LIMIT
        --  INTO    l_limit
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_limit_id;

        NULL;

    END IF;

    RETURN l_limit;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit;

FUNCTION Limit_Level
(   p_limit_level_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_limit_level                 VARCHAR2(240) := NULL;
BEGIN

    IF p_limit_level_code IS NOT NULL THEN

        --  SELECT  LIMIT_LEVEL
        --  INTO    l_limit_level
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_limit_level_code;

        NULL;

    END IF;

    RETURN l_limit_level;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_level');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Level;

FUNCTION Comparison_Operator
(   p_comparison_operator_code      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_comparison_operator         VARCHAR2(240) := NULL;
BEGIN

    IF p_comparison_operator_code IS NOT NULL THEN

        --  SELECT  COMPARISON_OPERATOR
        --  INTO    l_comparison_operator
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_comparison_operator_code;

        NULL;

    END IF;

    RETURN l_comparison_operator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Comparison_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Comparison_Operator;

FUNCTION Limit_Attribute
(   p_limit_attribute_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_limit_attribute             VARCHAR2(240) := NULL;
BEGIN

    IF p_limit_attribute_id IS NOT NULL THEN

        --  SELECT  LIMIT_ATTRIBUTE
        --  INTO    l_limit_attribute
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_limit_attribute_id;

        NULL;

    END IF;

    RETURN l_limit_attribute;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attribute;

FUNCTION Limit_Balance
(   p_limit_balance_id              IN  NUMBER
) RETURN VARCHAR2
IS
l_limit_balance               VARCHAR2(240) := NULL;
BEGIN

    IF p_limit_balance_id IS NOT NULL THEN

        --  SELECT  LIMIT_BALANCE
        --  INTO    l_limit_balance
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_limit_balance_id;

        NULL;

    END IF;

    RETURN l_limit_balance;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_balance');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Balance'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Balance;

FUNCTION Base_Currency
(   p_base_currency_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_base_currency               VARCHAR2(240) := NULL;
BEGIN

    IF p_base_currency_code IS NOT NULL THEN

        --  SELECT  BASE_CURRENCY
        --  INTO    l_base_currency
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_base_currency_code;

        NULL;

    END IF;

    RETURN l_base_currency;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_currency');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Currency;

FUNCTION Currency_Header
(   p_currency_header_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_currency_header             VARCHAR2(240) := NULL;
BEGIN

    IF p_currency_header_id IS NOT NULL THEN

        --  SELECT  CURRENCY_HEADER
        --  INTO    l_currency_header
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_currency_header_id;

        NULL;

    END IF;

    RETURN l_currency_header;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Header;

-- Added by Sunil Pandey 10/01/01
FUNCTION Base_Markup_Formula
(   p_base_markup_formula_id       IN  NUMBER
) RETURN VARCHAR2
IS
l_base_markup_formula              VARCHAR2(240) := NULL;
BEGIN

    IF p_base_markup_formula_id IS NOT NULL THEN

        --  SELECT  MARKUP_FORMULA
        --  INTO    l_base_markup_formula
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_base_markup_formula_id;

        NULL;

    END IF;

    RETURN l_base_markup_formula;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_markup_formula');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'base_Markup_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Markup_Formula;
-- Added by Sunil Pandey 10/01/01


FUNCTION Row
(   p_row_id                        IN  ROWID
) RETURN VARCHAR2
IS
l_row                         VARCHAR2(240) := NULL;
BEGIN

    IF p_row_id IS NOT NULL THEN

        --  SELECT  ROW
        --  INTO    l_row
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_row_id;

        NULL;

    END IF;

    RETURN l_row;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','row');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Row;

FUNCTION Currency_Detail
(   p_currency_detail_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_currency_detail             VARCHAR2(240) := NULL;
BEGIN

    IF p_currency_detail_id IS NOT NULL THEN

        --  SELECT  CURRENCY_DETAIL
        --  INTO    l_currency_detail
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_currency_detail_id;

        NULL;

    END IF;

    RETURN l_currency_detail;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_detail');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Detail'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Detail;

FUNCTION Markup_Formula
(   p_markup_formula_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_markup_formula              VARCHAR2(240) := NULL;
BEGIN

    IF p_markup_formula_id IS NOT NULL THEN

        --  SELECT  MARKUP_FORMULA
        --  INTO    l_markup_formula
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_markup_formula_id;

        NULL;

    END IF;

    RETURN l_markup_formula;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_formula');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Markup_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Markup_Formula;

FUNCTION To_Currency
(   p_to_currency_code              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_to_currency                 VARCHAR2(240) := NULL;
BEGIN

    IF p_to_currency_code IS NOT NULL THEN

        --  SELECT  TO_CURRENCY
        --  INTO    l_to_currency
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_to_currency_code;

        NULL;

    END IF;

    RETURN l_to_currency;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_currency');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Currency;

FUNCTION Enabled
(   p_enabled_flag                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_enabled                     VARCHAR2(240) := NULL;
BEGIN

    IF p_enabled_flag IS NOT NULL THEN

        --  SELECT  ENABLED
        --  INTO    l_enabled
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_enabled_flag;

        NULL;

    END IF;

    RETURN l_enabled;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Enabled;

FUNCTION Prc_Context
(   p_prc_context_id                IN  NUMBER
) RETURN VARCHAR2
IS
l_prc_context                 VARCHAR2(240) := NULL;
BEGIN

    IF p_prc_context_id IS NOT NULL THEN

        --  SELECT  PRC_CONTEXT
        --  INTO    l_prc_context
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_prc_context_id;

        NULL;

    END IF;

    RETURN l_prc_context;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prc_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prc_Context;

FUNCTION Seeded
(   p_seeded_flag                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_seeded                      VARCHAR2(240) := NULL;
BEGIN

    IF p_seeded_flag IS NOT NULL THEN

        --  SELECT  SEEDED
        --  INTO    l_seeded
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_seeded_flag;

        NULL;

    END IF;

    RETURN l_seeded;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded;

FUNCTION Seeded_Valueset
(   p_seeded_valueset_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_seeded_valueset             VARCHAR2(240) := NULL;
BEGIN

    IF p_seeded_valueset_id IS NOT NULL THEN

        --  SELECT  SEEDED_VALUESET
        --  INTO    l_seeded_valueset
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_seeded_valueset_id;

        NULL;

    END IF;

    RETURN l_seeded_valueset;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_valueset');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Valueset'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Valueset;

FUNCTION Segment
(   p_segment_id                    IN  NUMBER
) RETURN VARCHAR2
IS
l_segment                     VARCHAR2(240) := NULL;
BEGIN

    IF p_segment_id IS NOT NULL THEN

        --  SELECT  SEGMENT
        --  INTO    l_segment
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_segment_id;

        NULL;

    END IF;

    RETURN l_segment;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment;

FUNCTION User_Valueset
(   p_user_valueset_id              IN  NUMBER
) RETURN VARCHAR2
IS
l_user_valueset               VARCHAR2(240) := NULL;
BEGIN

    IF p_user_valueset_id IS NOT NULL THEN

        --  SELECT  USER_VALUESET
        --  INTO    l_user_valueset
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_user_valueset_id;

        NULL;

    END IF;

    RETURN l_user_valueset;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_valueset');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Valueset'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Valueset;

FUNCTION Lookup
(   p_lookup_code                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_lookup                      VARCHAR2(240) := NULL;
BEGIN

    IF p_lookup_code IS NOT NULL THEN

        --  SELECT  LOOKUP
        --  INTO    l_lookup
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_lookup_code;

        NULL;

    END IF;

    RETURN l_lookup;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lookup'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lookup;

FUNCTION Pte
(   p_pte_code                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_pte                         VARCHAR2(240) := NULL;
BEGIN

    IF p_pte_code IS NOT NULL THEN

        --  SELECT  PTE
        --  INTO    l_pte
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_pte_code;

        NULL;

    END IF;

    RETURN l_pte;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte;

FUNCTION Request_Type
(   p_request_type_code             IN  VARCHAR2
) RETURN VARCHAR2
IS
l_request_type                VARCHAR2(240) := NULL;
BEGIN

    IF p_request_type_code IS NOT NULL THEN

        --  SELECT  REQUEST_TYPE
        --  INTO    l_request_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_request_type_code;

        NULL;

    END IF;

    RETURN l_request_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request_Type;

FUNCTION Pte_Source_System
(   p_pte_source_system_id          IN  NUMBER
) RETURN VARCHAR2
IS
l_pte_source_system           VARCHAR2(240) := NULL;
BEGIN

    IF p_pte_source_system_id IS NOT NULL THEN

        --  SELECT  PTE_SOURCE_SYSTEM
        --  INTO    l_pte_source_system
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_pte_source_system_id;

        NULL;

    END IF;

    RETURN l_pte_source_system;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_source_system');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte_Source_System'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte_Source_System;

FUNCTION Segment_Pte
(   p_segment_pte_id                IN  NUMBER
) RETURN VARCHAR2
IS
l_segment_pte                 VARCHAR2(240) := NULL;
BEGIN

    IF p_segment_pte_id IS NOT NULL THEN

        --  SELECT  SEGMENT_PTE
        --  INTO    l_segment_pte
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_segment_pte_id;

        NULL;

    END IF;

    RETURN l_segment_pte;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_pte');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment_Pte'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment_Pte;

FUNCTION Attribute_Sourcing
(   p_attribute_sourcing_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_attribute_sourcing          VARCHAR2(240) := NULL;
BEGIN

    IF p_attribute_sourcing_id IS NOT NULL THEN

        --  SELECT  ATTRIBUTE_SOURCING
        --  INTO    l_attribute_sourcing
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_attribute_sourcing_id;

        NULL;

    END IF;

    RETURN l_attribute_sourcing;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_sourcing');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attribute_Sourcing'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attribute_Sourcing;

FUNCTION Functional_Area
(   p_functional_area_id            IN  NUMBER
) RETURN VARCHAR2
IS
l_functional_area             VARCHAR2(240) := NULL;
BEGIN

    IF p_functional_area_id IS NOT NULL THEN

        --  SELECT  FUNCTIONAL_AREA
        --  INTO    l_functional_area
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_functional_area_id;

        NULL;

    END IF;

    RETURN l_functional_area;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','functional_area');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Functional_Area'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Functional_Area;

FUNCTION Pte_Sourcesystem_Fnarea
(   p_pte_sourcesystem_fnarea_id    IN  NUMBER
) RETURN VARCHAR2
IS
l_pte_sourcesystem_fnarea     VARCHAR2(240) := NULL;
BEGIN

    IF p_pte_sourcesystem_fnarea_id IS NOT NULL THEN

        --  SELECT  PTE_SOURCESYSTEM_FNAREA
        --  INTO    l_pte_sourcesystem_fnarea
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_pte_sourcesystem_fnarea_id;

        NULL;

    END IF;

    RETURN l_pte_sourcesystem_fnarea;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_sourcesystem_fnarea');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte_Sourcesystem_Fnarea'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte_Sourcesystem_Fnarea;
--  END GEN Id_To_Value

END QP_Id_To_Value;

/

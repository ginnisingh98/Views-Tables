--------------------------------------------------------
--  DDL for Package Body QP_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALUE_TO_ID" AS
/* $Header: QPXSVIDB.pls 120.3 2006/05/22 19:16:10 rnayani ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Value_To_Id';

-- Local procedure to get ID from a value set given a value
-- BUG#5228313 RAVI START
PROCEDURE Flex_Meaning_To_Value_Id1 (p_flexfield_name IN VARCHAR2,
                                    p_context        IN VARCHAR2,
                                    p_value          IN VARCHAR2,
			            p_segment        IN VARCHAR2,
                                    p_meaning        IN VARCHAR2,
                                    x_value         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                    x_id            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                    x_format_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
 vset   FND_VSET.valueset_r;
 fmt    FND_VSET.valueset_dr;
 found  BOOLEAN;
 row    NUMBER;
 value  FND_VSET.value_dr;

 x_vsid            NUMBER;
 x_validation_type VARCHAR2(1);

BEGIN
  QP_UTIL.Get_Valueset_Id(p_flexfield_name, p_context, p_segment,
                          x_vsid, x_format_type, x_validation_type);

  FND_VSET.get_valueset(x_vsid, vset, fmt);

  FND_VSET.get_value_init(vset, TRUE);
  FND_VSET.get_value(vset, row, found, value);

  WHILE (found) LOOP
    IF ltrim(rtrim(value.value)) = p_value
    THEN

	 IF fmt.has_id THEN
        x_id := value.id;
	   x_value := value.value;
	 ELSE
        x_value := value.value;
	 END IF;

	 EXIT;

    END IF; -- If value.meaning or value.value matches with p_meaning

    FND_VSET.get_value(vset, row, found, value);
  END LOOP;

  FND_VSET.get_value_end(vset);

  x_value := p_meaning; --If a match is not found in the valueset.

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Flex_Meaning_To_Value_Id');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flex_Meaning_To_Value_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flex_Meaning_To_Value_Id1;

-- BUG#5228313 RAVI START

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
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
    FND_API.g_attr_tbl(I).name     := 'Key_Flex';
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
    FND_API.g_attr_tbl(I).name     := 'pricing_attr_value_from';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attr_value_to';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attr_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attr_value_to';
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

--  Prototypes for value_to_id functions.

--  START GEN value_to_id

--  Key Flex

FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
)
RETURN NUMBER
IS
l_id                          NUMBER;
l_segment_array               FND_FLEX_EXT.SegmentArray;
BEGIN

    l_segment_array := p_segment_array;

    --  Convert any missing values to NULL

    FOR I IN 1..l_segment_array.COUNT LOOP

        IF l_segment_array(I) = FND_API.G_MISS_CHAR THEN
            l_segment_array(I) := NULL;
        END IF;

    END LOOP;

    --  Call Flex conversion routine

    IF NOT FND_FLEX_EXT.get_combination_id
    (   application_short_name        => p_appl_short_name
    ,   key_flex_code                 => p_key_flex_code
    ,   structure_number              => p_structure_number
    ,   validation_date               => NULL
    ,   n_segments                    => l_segment_array.COUNT
    ,   segments                      => l_segment_array
    ,   combination_id                => l_id
    )
    THEN

        --  Error getting combination id.
        --  Function has already pushed a message on the stack. Add to
        --  the API message list.

        oe_msg_pub.Add;
        l_id := FND_API.G_MISS_NUM;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Key_Flex'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Key_Flex;

--  Generator will append new prototypes before end generate comment.


--  Automatic

FUNCTION Automatic
(   p_automatic                     IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_automatic IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_automatic

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Currency

FUNCTION Currency
(   p_currency                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_currency IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Discount_Lines

FUNCTION Discount_Lines
(   p_discount_lines                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_discount_lines IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_discount_lines

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Freight_Terms

FUNCTION Freight_Terms
(   p_freight_terms                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_freight_terms IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_freight_terms

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  List_Header

FUNCTION List_Header
(   p_list_header                   IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_list_header IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_list_header

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  List_Type

FUNCTION List_Type
(   p_list_type                     IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_list_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_list_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Prorate

FUNCTION Prorate
(   p_prorate                       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_prorate IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_prorate

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Ship_Method

/* FUNCTION Ship_Method
(   p_ship_method                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_ship_method IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_ship_method

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Terms

FUNCTION Terms
(   p_terms                         IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_terms IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_terms

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Base_Uom

FUNCTION Base_Uom
(   p_base_uom                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(3);
BEGIN

    IF  p_base_uom IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_base_uom

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_uom_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Generate_Using_Formula

FUNCTION Generate_Using_Formula
(   p_generate_using_formula        IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_generate_using_formula IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_generate_using_formula

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','generate_using_formula_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Inventory_Item

FUNCTION Inventory_Item
(   p_inventory_item                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_inventory_item IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_inventory_item

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  List_Line

FUNCTION List_Line
(   p_list_line                     IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_list_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_list_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  List_Line_Type

FUNCTION List_Line_Type
(   p_list_line_type                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_list_line_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_list_line_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  List_Price_Uom

FUNCTION List_Price_Uom
(   p_list_price_uom                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(3);
BEGIN

    IF  p_list_price_uom IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_list_price_uom

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_price_uom_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Modifier_Level

FUNCTION Modifier_Level
(   p_modifier_level                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_modifier_level IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_modifier_level

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','modifier_level_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Organization

FUNCTION Organization
(   p_organization                  IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_organization IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_organization

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Override

FUNCTION Override
(   p_override                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_override IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_override

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Price_Break_Type

FUNCTION Price_Break_Type
(   p_price_break_type              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_price_break_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_break_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_break_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Price_By_Formula

FUNCTION Price_By_Formula
(   p_price_by_formula              IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_by_formula IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_by_formula

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_by_formula_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Primary_Uom

FUNCTION Primary_Uom
(   p_primary_uom                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_primary_uom IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_primary_uom

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Print_On_Invoice

FUNCTION Print_On_Invoice
(   p_print_on_invoice              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_print_on_invoice IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_print_on_invoice

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','print_on_invoice_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Rebate_Transaction_Type

FUNCTION Rebate_Transaction_Type
(   p_rebate_transaction_type       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_rebate_transaction_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_rebate_transaction_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_trxn_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Related_Item

FUNCTION Related_Item
(   p_related_item                  IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_related_item IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_related_item

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','related_item_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Relationship_Type

FUNCTION Relationship_Type
(   p_relationship_type             IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_relationship_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_relationship_type

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','relationship_type_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Reprice

FUNCTION Reprice
(   p_reprice                       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_reprice IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_reprice

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Revision_Reason

FUNCTION Revision_Reason
(   p_revision_reason               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_revision_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_revision_reason

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason;

--  Comparison_Operator

/*FUNCTION Comparison_Operator
(   p_comparison_operator           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_comparison_operator IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_comparison_operator

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Created_From_Rule

FUNCTION Created_From_Rule
(   p_created_from_rule             IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_created_from_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

     SELECT  qualifier_rule_id
     INTO    l_id
     FROM    QP_QUALIFIER_RULES
     WHERE   name = p_created_from_rule;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_from_rule_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Excluder

FUNCTION Excluder
(   p_excluder                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_excluder IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_excluder

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Qualifier

/*FUNCTION Qualifier
(   p_qualifier                     IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_qualifier IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_qualifier

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier;*/

--  Qualifier_Rule

FUNCTION Qualifier_Rule
(   p_qualifier_rule                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_qualifier_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

     SELECT  qualifier_rule_id
     INTO    l_id
     FROM    QP_QUALIFIER_RULES
     WHERE   name = p_qualifier_rule;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Accumulate

FUNCTION Accumulate
(   p_accumulate                    IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_accumulate IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_accumulate

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accumulate_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Pricing_Attribute

FUNCTION Pricing_Attribute
(   p_pricing_attribute_desc             IN  VARCHAR2,
    p_context                            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_pricing_attribute  VARCHAR2(240);
BEGIN

    IF  p_pricing_attribute_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_pricing_attribute := QP_UTIL.Get_Attribute_Name(
						 p_application_short_name => 'QP',
						 p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
						 p_context_name => p_context,
						 p_attribute_name => p_pricing_attribute_desc);

    RETURN l_pricing_attribute;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Pricing_Attr_Value_From

FUNCTION Pricing_Attr_Value_From
(   p_pricing_attr_value_from_desc             IN  VARCHAR2,
    p_context                                  IN  VARCHAR2,
    p_attribute                                IN  VARCHAR2
) RETURN VARCHAR2
IS
l_segment_name             VARCHAR2(240);
l_pricing_attr_value_from  VARCHAR2(240);
x_value                    VARCHAR2(240);
x_id                       VARCHAR2(150);
x_format_type              VARCHAR2(1);

BEGIN

    IF  p_pricing_attr_value_from_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_segment_name :=
	    QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name('QP_ATTR_DEFNS_PRICING',
					                         p_context,
					                         p_attribute);

         Flex_Meaning_To_Value_Id(
					    p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
					    p_context => p_context,
                             p_segment => l_segment_name,
                             p_meaning => p_pricing_attr_value_from_desc,
                             x_value => x_value,
					    x_id => x_id,
					    x_format_type => x_format_type
					    );
    IF x_id IS NOT NULL THEN
	  l_pricing_attr_value_from := x_id;
    ELSE
	  l_pricing_attr_value_from := x_value;
    END IF;

    RETURN l_pricing_attr_value_from;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_from');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attr_Value_From'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attr_Value_From;

--  Pricing_Attr_Value_To

FUNCTION Pricing_Attr_Value_To
(   p_pricing_attr_value_to_desc             IN  VARCHAR2,
    p_context                                IN  VARCHAR2,
    p_attribute                              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_pricing_attr_value_to    VARCHAR2(240);
l_segment_name             VARCHAR2(240);
x_value                    VARCHAR2(240);
x_id                       VARCHAR2(150);
x_format_type              VARCHAR2(1);

BEGIN

    IF  p_pricing_attr_value_to_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_segment_name :=
	    QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name('QP_ATTR_DEFNS_PRICING',
					                         p_context,
					                         p_attribute);

         Flex_Meaning_To_Value_Id(
					    p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
					    p_context => p_context,
                             p_segment => l_segment_name,
                             p_meaning => p_pricing_attr_value_to_desc,
                             x_value => x_value,
					    x_id => x_id,
					    x_format_type => x_format_type
					    );
    IF x_id IS NOT NULL THEN
	  l_pricing_attr_value_to := x_id;
    ELSE
	  l_pricing_attr_value_to := x_value;
    END IF;

    RETURN l_pricing_attr_value_to;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_to');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attr_Value_to'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attr_Value_to;

--  Qualifier_Attribute

FUNCTION Qualifier_Attribute
(   p_qualifier_attribute_desc             IN  VARCHAR2,
    p_context                              IN  VARCHAR2
) RETURN VARCHAR2
IS
l_qualifier_attribute  VARCHAR2(240);
BEGIN

    IF  p_qualifier_attribute_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_qualifier_attribute := QP_UTIL.Get_Attribute_Name(
						 p_application_short_name => 'QP',
						 p_flexfield_name => 'QP_ATTR_DEFNS_QUALIFIER',
						 p_context_name => p_context,
						 p_attribute_name => p_qualifier_attribute_desc);

    RETURN l_qualifier_attribute;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attribute;

--  Qualifier_Attr_Value

FUNCTION Qualifier_Attr_Value
(   p_qualifier_attr_value_desc             IN  VARCHAR2,
    p_context                               IN  VARCHAR2,
    p_attribute                             IN  VARCHAR2
) RETURN VARCHAR2
IS
l_qualifier_attr_value     VARCHAR2(240);
l_segment_name             VARCHAR2(240);
x_value                    VARCHAR2(240);
x_id                       VARCHAR2(150);
x_format_type              VARCHAR2(1);

BEGIN

    IF  p_qualifier_attr_value_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_segment_name :=
	    QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name('QP_ATTR_DEFNS_QUALIFIER',
					                         p_context,
					                         p_attribute);
         -- BUG#5228313 RAVI START
         Flex_Meaning_To_Value_Id1(
					    p_flexfield_name => 'QP_ATTR_DEFNS_QUALIFIER',
					    p_context => p_context,
                             p_segment => l_segment_name,
                             p_value => p_qualifier_attr_value_desc,
                             p_meaning => p_qualifier_attr_value_desc,
                             x_value => x_value,
					    x_id => x_id,
					    x_format_type => x_format_type
					    );
    IF x_id IS NOT NULL THEN
	  l_qualifier_attr_value := x_id;
    ELSE
	  l_qualifier_attr_value := x_value;
    END IF;

    RETURN l_qualifier_attr_value;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attr_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attr_Value;

--  Qualifier_Attr_Value_To

FUNCTION Qualifier_Attr_Value_To
(   p_qualifier_attr_value_to_desc          IN  VARCHAR2,
    p_context                               IN  VARCHAR2,
    p_attribute                             IN  VARCHAR2
) RETURN VARCHAR2
IS
l_qualifier_attr_value_to  VARCHAR2(240);
l_segment_name             VARCHAR2(240);
x_value                    VARCHAR2(240);
x_id                       VARCHAR2(150);
x_format_type              VARCHAR2(1);

BEGIN

    IF  p_qualifier_attr_value_to_desc IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_segment_name :=
	    QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name('QP_ATTR_DEFNS_QUALIFIER',
					                         p_context,
					                         p_attribute);
         Flex_Meaning_To_Value_Id(
					    p_flexfield_name => 'QP_ATTR_DEFNS_QUALIFIER',
					    p_context => p_context,
                             p_segment => l_segment_name,
                             p_meaning => p_qualifier_attr_value_to_desc,
                             x_value => x_value,
					    x_id => x_id,
					    x_format_type => x_format_type
					    );
    IF x_id IS NOT NULL THEN
	  l_qualifier_attr_value_to := x_id;
    ELSE
	  l_qualifier_attr_value_to := x_value;
    END IF;

    RETURN l_qualifier_attr_value_to;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value_to');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attr_Value_To'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attr_Value_To;

--  Product_Uom

FUNCTION Product_Uom
(   p_product_uom                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(3);
BEGIN

    IF  p_product_uom IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_product_uom

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_uom_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Header

FUNCTION Header
(   p_header                        IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_header IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_header

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Line

FUNCTION Line
(   p_line                          IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Order_Price_Attrib

FUNCTION Order_Price_Attrib
(   p_order_price_attrib            IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_order_price_attrib IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_order_price_attrib

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_price_attrib_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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


--  Price_Formula

FUNCTION Price_Formula
(   p_price_formula                 IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_formula IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_formula

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Price_Formula_Line

FUNCTION Price_Formula_Line
(   p_price_formula_line            IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_formula_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_formula_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Price_Formula_Line_Type

FUNCTION Price_Formula_Line_Type
(   p_price_formula_line_type       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_price_formula_line_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_formula_line_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','formula_line_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Price_List_Line

FUNCTION Price_List_Line
(   p_price_list_line               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_list_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_list_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Price_Modifier_List

FUNCTION Price_Modifier_List
(   p_price_modifier_list           IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_modifier_list IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_modifier_list

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_modifier_list_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Limit_Exceed_Action

FUNCTION Limit_Exceed_Action
(   p_limit_exceed_action           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_limit_exceed_action IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_limit_exceed_action

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_exceed_action_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Limit

FUNCTION Limit
(   p_limit                         IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_limit IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_limit

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Limit_Level

FUNCTION Limit_Level
(   p_limit_level                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_limit_level IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_limit_level

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_level_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Comparison_Operator

FUNCTION Comparison_Operator
(   p_comparison_operator           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_comparison_operator IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_comparison_operator

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Limit_Attribute

FUNCTION Limit_Attribute
(   p_limit_attribute               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_limit_attribute IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_limit_attribute

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Limit_Balance

FUNCTION Limit_Balance
(   p_limit_balance                 IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_limit_balance IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_limit_balance

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_balance_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Base_Currency

FUNCTION Base_Currency
(   p_base_currency                 IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_base_currency IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_base_currency

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_currency_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Currency_Header

FUNCTION Currency_Header
(   p_currency_header               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_currency_header IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency_header

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

/* Commented by Sunil
--  Row

FUNCTION Row
(   p_row                           IN  VARCHAR2
) RETURN ROWID
IS
FND_API.G_MISS_NUM            AND     ;
BEGIN

    IF  p_row IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    FND_API.G_MISS_NUM
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_row

    RETURN FND_API.G_MISS_NUM;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','row_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

Commented by Sunil */

--  Currency_Detail

FUNCTION Currency_Detail
(   p_currency_detail               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_currency_detail IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency_detail

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_detail_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Markup_Formula

FUNCTION Markup_Formula
(   p_markup_formula                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_markup_formula IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_markup_formula

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_formula_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

-- Added by Sunil Pandey 10/01/01
--  Base_Markup_Formula

FUNCTION Base_Markup_Formula
(   p_base_markup_formula                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_base_markup_formula IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_base_markup_formula

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_markup_formula_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Markup_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Markup_Formula;

--  To_Currency

FUNCTION To_Currency
(   p_to_currency                   IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_to_currency IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_to_currency

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_currency_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Enabled

FUNCTION Enabled
(   p_enabled                       IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_enabled IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_enabled

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Prc_Context

FUNCTION Prc_Context
(   p_prc_context                   IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_prc_context IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_prc_context

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Seeded

FUNCTION Seeded
(   p_seeded                        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(1);
BEGIN

    IF  p_seeded IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_seeded

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Seeded_Valueset

FUNCTION Seeded_Valueset
(   p_seeded_valueset               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_seeded_valueset IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_seeded_valueset

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_valueset_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Segment

FUNCTION Segment
(   p_segment                       IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_segment IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_segment

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  User_Valueset

FUNCTION User_Valueset
(   p_user_valueset                 IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_user_valueset IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_user_valueset

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_valueset_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Lookup

FUNCTION Lookup
(   p_lookup                        IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_lookup IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_lookup

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Pte

FUNCTION Pte
(   p_pte                           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_pte IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_pte

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Request_Type

FUNCTION Request_Type
(   p_request_type                  IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(30);
BEGIN

    IF  p_request_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_request_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  Pte_Source_System

FUNCTION Pte_Source_System
(   p_pte_source_system             IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_pte_source_system IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_pte_source_system

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_source_system_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Segment_Pte

FUNCTION Segment_Pte
(   p_segment_pte                   IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_segment_pte IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_segment_pte

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_pte_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Attribute_Sourcing

FUNCTION Attribute_Sourcing
(   p_attribute_sourcing            IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_attribute_sourcing IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_attribute_sourcing

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_sourcing_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Functional_Area

FUNCTION Functional_Area
(   p_functional_area               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_functional_area IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_functional_area

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','functional_area_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Pte_Sourcesystem_Fnarea

FUNCTION Pte_Sourcesystem_Fnarea
(   p_pte_sourcesystem_fnarea       IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_pte_sourcesystem_fnarea IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_pte_sourcesystem_fnarea

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_sourcesystem_fnarea_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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
--  END GEN value_to_id



FUNCTION Accounting_Rule
(   p_accounting_rule               IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_accounting_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_accounting_rule

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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





FUNCTION Agreement_Contact
(   p_Agreement_Contact                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Agreement_Contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Agreement_Contact

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Agreement_Contact_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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




FUNCTION Agreement
(   p_agreement                     IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_agreement IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_agreement

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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



FUNCTION Agreement_Type
(   p_Agreement_Type                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Agreement_Type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Agreement_Type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Agreement_Type_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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



FUNCTION Customer
(   p_Customer                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Customer IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Customer

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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



FUNCTION Invoice_Contact
(   p_Invoice_Contact                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Invoice_Contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Invoice_Contact

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Invoice_Contact_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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
(   p_Invoice_To_Site_Use                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Invoice_To_Site_Use IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Invoice_To_Site_Use

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Invoice_To_Site_Use_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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



FUNCTION Invoicing_Rule
(   p_invoicing_rule                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_invoicing_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_invoicing_rule

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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



FUNCTION Override_Arule
(   p_Override_Arule                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Override_Arule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Override_Arule

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override_Arule_Flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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
(   p_Override_Irule                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Override_Irule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Override_Irule

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override_Irule_Flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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




FUNCTION Price_List
(   p_price_list                    IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_price_list IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_list

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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
(   p_salesrep                      IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    IF  p_salesrep IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_salesrep

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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



FUNCTION Ship_Method
(   p_Ship_Method                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(80);
BEGIN

    IF  p_Ship_Method IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  lookup_code
      INTO    l_code
      FROM    oe_ship_methods_v
      WHERE   meaning = p_Ship_Method and
	 rownum = 1 ;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship_Method_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--Begin of code added by rchellam for OKC
FUNCTION Agreement_Source
(   p_agreement_source    IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(80);
BEGIN

    IF  p_agreement_source IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  lookup_code
    INTO    l_code
    FROM    qp_lookups
    WHERE   meaning = p_agreement_source
    AND     lookup_type = 'AGREEMENT_SOURCE_CODE';

    RETURN l_code;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Agreement_Source_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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
--End of code added by rchellam for OKC

--  Term

FUNCTION Term
(   p_Term                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(15);
BEGIN

    IF  p_Term IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Term

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Term_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

PROCEDURE Flex_Meaning_To_Value_Id (p_flexfield_name IN VARCHAR2,
                                    p_context        IN VARCHAR2,
							 p_segment        IN VARCHAR2,
                                    p_meaning        IN VARCHAR2,
                                    x_value         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                    x_id            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                                    x_format_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
 vset   FND_VSET.valueset_r;
 fmt    FND_VSET.valueset_dr;
 found  BOOLEAN;
 row    NUMBER;
 value  FND_VSET.value_dr;

 x_vsid            NUMBER;
 x_validation_type VARCHAR2(1);

BEGIN

  QP_UTIL.Get_Valueset_Id(p_flexfield_name, p_context, p_segment,
                          x_vsid, x_format_type, x_validation_type);

  FND_VSET.get_valueset(x_vsid, vset, fmt);
  FND_VSET.get_value_init(vset, TRUE);
  FND_VSET.get_value(vset, row, found, value);

  WHILE (found) LOOP
    IF  (fmt.has_meaning AND
	    ltrim(rtrim(value.meaning)) = ltrim(rtrim(p_meaning))
	   ) OR
        ltrim(rtrim(value.value)) = ltrim(rtrim(p_meaning))
    THEN

	 IF fmt.has_id THEN
        x_id := value.id;
	   x_value := value.value;
	 ELSE
        x_value := value.value;
	 END IF;

	 EXIT;

    END IF; -- If value.meaning or value.value matches with p_meaning

    FND_VSET.get_value(vset, row, found, value);
  END LOOP;

  FND_VSET.get_value_end(vset);

  x_value := p_meaning; --If a match is not found in the valueset.

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('QP','QP_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Flex_Meaning_To_Value_Id');
            OE_MSG_PUB.Add;

        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flex_Meaning_To_Value_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flex_Meaning_To_Value_Id;

END QP_Value_To_Id;

/

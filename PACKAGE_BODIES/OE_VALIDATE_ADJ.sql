--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_ADJ" AS
/* $Header: OEXSVADB.pls 120.1 2006/01/24 14:24:19 aycui noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_adj';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
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
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'desc_flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'applied_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_reason_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_reason_text';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_header_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_from';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_to';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_mechanism_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'percent';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_adjustment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'updated_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'update_allowed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'adjusted_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_phase_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'operand';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'arithmetic_operator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_system_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_uom_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'print_on_invoice_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expiration_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_transaction_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_transaction_reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_payment_system_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'redeemed_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'redeemed_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accrual_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'range_break_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accrual_conversion_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_group_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modifier_level_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_break_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitution_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'proration_type_code';

--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

--/old/


FUNCTION Desc_Flex ( p_appl_short_name varchar2,p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

    --  Call FND validate API.


    --  This call is temporarily commented out

    IF	FND_FLEX_DESCVAL.Validate_Desccols
        (   appl_short_name               => p_appl_short_name
        ,   desc_flex_name                => p_flex_name
        )
    THEN
        RETURN TRUE;
    ELSE

        --  Prepare the encoded message by setting it on the message
        --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);

        OE_MSG_PUB.Add;

        --  Derive return status.

        IF FND_FLEX_DESCVAL.value_error OR
            FND_FLEX_DESCVAL.unsupported_error
        THEN

            --  In case of an expected error return FALSE

            RETURN FALSE;

        ELSE

            --  In case of an unexpected error raise an exception.

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DESC_FLEX');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('DESC_FLEX'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Desc_Flex'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Desc_Flex;

FUNCTION Header ( p_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_header_id IS NULL OR
        p_header_id = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_header_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'HEADER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('HEADER_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header;


FUNCTION Last_Updated_By ( p_last_updated_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_updated_by IS NULL OR
        p_last_updated_by = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_updated_by;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATED_BY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_updated_by'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Updated_By'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Updated_By;

FUNCTION Last_Update_Date ( p_last_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_update_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Date;

FUNCTION Last_Update_Login ( p_last_update_login IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_update_login IS NULL OR
        p_last_update_login = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_login;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATE_LOGIN');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_update_login'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Login'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Login;

FUNCTION Program_Application ( p_program_application_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_application_id IS NULL OR
        p_program_application_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_application_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_APPLICATION_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_application_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Application'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Application;

FUNCTION Program ( p_program_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_id IS NULL OR
        p_program_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program;

FUNCTION Program_Update_Date ( p_program_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_update_date IS NULL OR
        p_program_update_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_update_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_UPDATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_update_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Update_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Update_Date;

FUNCTION Request ( p_request_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_request_id IS NULL OR
        p_request_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REQUEST_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('request_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request;

FUNCTION Price_Adjustment ( p_price_adjustment_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_price_adjustment_id IS NULL OR
        p_price_adjustment_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICE_ADJUSTMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('price_adjustment_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Adjustment'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Adjustment;

FUNCTION Discount ( p_discount_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_discount_id IS NULL OR
        p_discount_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_discount_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DISCOUNT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('discount_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount;

FUNCTION Discount_Line ( p_discount_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_discount_line_id <> -1 OR
        p_discount_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;


    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_discount_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DISCOUNT_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('discount_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Line;

FUNCTION Automatic ( p_automatic_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_automatic_flag IS NULL OR
        p_automatic_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_automatic_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AUTOMATIC_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('automatic_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic;

FUNCTION Percent ( p_percent IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


   -- All attribute validation being turned on
--   IF p_percent IS NULL OR
--     p_percent = FND_API.g_miss_num
--     THEN
--      RETURN TRUE;
--    ELSIF p_percent = 0
--      THEN
--      RETURN FALSE;
--   END IF;


   RETURN TRUE;

/*
    IF p_percent IS NULL OR
        p_percent = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_percent;

    RETURN TRUE;
*/
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PERCENT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('percent'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Percent'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Percent;

FUNCTION Line ( p_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_id IS NULL OR
        p_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;


FUNCTION Applied_Flag ( p_Applied_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Applied_Flag IS NULL OR
        p_Applied_Flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

	   if p_applied_flag not in ('Y','N') then

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'APPLIED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Applied_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;
        RETURN FALSE;
     End if;

        RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'APPLIED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Applied_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Applied_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Applied_Flag;



FUNCTION Change_Reason_Code(p_Change_Reason_Code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) :='CHANGE_CODE';
BEGIN


    IF p_Change_Reason_Code IS NULL OR
        p_Change_Reason_Code = FND_API.G_MISS_CHAR OR
        upper(p_Change_Reason_Code)='MANUAL' OR
        upper(p_Change_Reason_Code)='SYSTEM' OR
        upper(p_Change_Reason_Code)='CONFIGURATOR'
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_change_reason_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE  BETWEEN NVL(START_DATE_ACTIVE, SYSDATE) AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHANGE_REASON_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Change_Reason_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Reason_Code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Change_Reason_Code;


FUNCTION Change_Reason_Text(p_Change_Reason_Text IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Change_Reason_Text IS NULL OR
        p_Change_Reason_Text = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHANGE_REASON_TEXT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Change_Reason_Text'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Reason_Text'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Change_Reason_Text;


FUNCTION List_Header_id(p_List_Header_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Header_id IS NULL OR
        p_List_Header_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     qp_list_headers_vl
      WHERE    list_header_id = p_List_Header_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_HEADER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Header_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Header_id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Header_id;


FUNCTION List_Line_id(p_List_Line_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Line_id IS NULL OR
        p_List_Line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     qp_list_lines
      WHERE    list_line_id = p_List_Line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_id;


FUNCTION  List_Line_Type_code(p_List_Line_Type_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Line_Type_code IS NULL OR
        p_List_Line_Type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_LINE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Line_Type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_Type_code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_Type_code;



FUNCTION Pricing_Phase_id(p_Pricing_Phase_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Pricing_Phase_id IS NULL OR
        p_Pricing_Phase_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Pricing_Phase_id');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Pricing_Phase_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Phase_id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Phase_id;


FUNCTION Adjusted_Amount(p_Adjusted_Amount IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Adjusted_Amount IS NULL OR
        p_Adjusted_Amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ADJUSTED_AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ADJUSTED_AMOUNT'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Adjusted_Amount'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Adjusted_Amount;



FUNCTION Modified_From(p_Modified_From IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modified_From IS NULL OR
        p_Modified_From = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIED_FROM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modified_From'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modified_From'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modified_From;

FUNCTION Modified_To(p_Modified_To IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modified_To IS NULL OR
        p_Modified_To = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIED_TO');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modified_To'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modified_To'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modified_To;


FUNCTION  Modifier_mechanism_type_code(p_Modifier_mechanism_type_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modifier_mechanism_type_code IS NULL OR
        p_Modifier_mechanism_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIER_MECHANISM_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modifier_mechanism_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifier_mechanism_type_code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifier_mechanism_type_code;



FUNCTION operand(p_operand IN number)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Operand IS NULL OR
        p_Operand = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OPERAND');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Operand'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operand'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END operand;


FUNCTION arithmetic_operator(p_arithmetic_operator IN varchar2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_arithmetic_operator IS NULL OR
        p_arithmetic_operator = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ARITHMETIC_OPERATOR');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Arithmetic_Operator'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Arithmetic_operator'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Arithmetic_Operator;

FUNCTION List_Line_NO ( p_List_Line_NO IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_List_Line_NO IS NULL OR
        p_List_Line_NO = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_List_Line_NO;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'List_Line_NO');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Line_NO'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List Line NO'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_NO;

FUNCTION Source_System_Code ( p_Source_System_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Source_System_Code IS NULL OR
        p_Source_System_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Source_System_Code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Source_System_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Source_System_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source System Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_System_Code;

FUNCTION Benefit_Qty ( p_Benefit_Qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Benefit_Qty IS NULL OR
        p_Benefit_Qty = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Benefit_Qty;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Benefit_Qty');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Benefit_Qty'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Benefit Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Benefit_Qty;

FUNCTION Benefit_UOM_Code ( p_Benefit_UOM_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Benefit_UOM_Code IS NULL OR
        p_Benefit_UOM_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Benefit_UOM_Code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Benefit_UOM_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Benefit_UOM_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Benefit UOM Code '
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Benefit_UOM_Code;

FUNCTION Print_On_Invoice_Flag ( p_Print_On_Invoice_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Print_On_Invoice_Flag IS NULL OR
        p_Print_On_Invoice_Flag = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Print_On_Invoice_Flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Print_On_Invoice_Flag');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Print_On_Invoice_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Print On Invoice Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Print_On_Invoice_Flag;

FUNCTION Expiration_Date ( p_Expiration_Date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Expiration_Date IS NULL OR
        p_Expiration_Date = FND_API.G_MISS_DATE
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Expiration_Date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Expiration_Date');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Expiration_Date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Expiration Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Expiration_Date;

FUNCTION Rebate_Transaction_Type_Code ( p_Rebate_Transaction_Type_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Rebate_Transaction_Type_Code IS NULL OR
        p_Rebate_Transaction_Type_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Rebate_Transaction_Type_Code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Rebate_Transaction_Type_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Rebate_Transaction_Type_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate Transaction Type Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Transaction_Type_Code;

FUNCTION Rebate_Transaction_Reference ( p_Rebate_Transaction_Reference IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Rebate_Transaction_Reference IS NULL OR
        p_Rebate_Transaction_Reference = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Rebate_Transaction_Reference;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Rebate_Transaction_Reference');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Rebate_Transaction_Reference'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate_Transaction_Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Transaction_Reference;

FUNCTION Rebate_Payment_System_Code ( p_Rebate_Payment_System_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Rebate_Payment_System_Code IS NULL OR
        p_Rebate_Payment_System_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Rebate_Payment_System_Code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Rebate_Payment_System_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Rebate_Payment_System_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate Payment System Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Payment_System_Code;

FUNCTION Redeemed_Date ( p_Redeemed_Date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Redeemed_Date IS NULL OR
        p_Redeemed_Date = FND_API.G_MISS_DATE
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Redeemed_Date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Redeemed_Date');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Redeemed_Date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Redeemed Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Redeemed_Date;

FUNCTION Redeemed_Flag ( p_Redeemed_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Redeemed_Flag IS NULL OR
        p_Redeemed_Flag = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Redeemed_Flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Redeemed_Flag');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Redeemed_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Redeemed Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Redeemed_Flag;

FUNCTION Accrual_Flag ( p_Accrual_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Accrual_Flag IS NULL OR
        p_Accrual_Flag = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Accrual_Flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Accrual_Flag');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Accrual_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accrual Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accrual_Flag;

FUNCTION range_break_quantity ( p_range_break_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_range_break_quantity IS NULL OR
        p_range_break_quantity = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_range_break_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'range_break_quantity');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('range_break_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'range_break_quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END range_break_quantity;

FUNCTION accrual_conversion_rate ( p_accrual_conversion_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_accrual_conversion_rate IS NULL OR
        p_accrual_conversion_rate = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accrual_conversion_rate;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'accrual_conversion_rate');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('accrual_conversion_rate'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'accrual_conversion_rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END accrual_conversion_rate;

FUNCTION pricing_group_sequence ( p_pricing_group_sequence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_group_sequence IS NULL OR
        p_pricing_group_sequence = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_group_sequence;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'pricing_group_sequence');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('pricing_group_sequence'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'pricing_group_sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END pricing_group_sequence;

FUNCTION modifier_level_code ( p_modifier_level_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_modifier_level_code IS NULL OR
        p_modifier_level_code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_modifier_level_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'modifier_level_code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('modifier_level_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'modifier_level_code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END modifier_level_code;

FUNCTION price_break_type_code ( p_price_break_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_break_type_code IS NULL OR
        p_price_break_type_code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_break_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'price_break_type_code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('price_break_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'price_break_type_code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END price_break_type_code;

FUNCTION substitution_attribute ( p_substitution_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_substitution_attribute IS NULL OR
        p_substitution_attribute = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_substitution_attribute;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'substitution_attribute');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('substitution_attribute'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'substitution_attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END substitution_attribute;

FUNCTION proration_type_code ( p_proration_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_proration_type_code IS NULL OR
        p_proration_type_code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_proration_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'proration_type_code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('proration_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'proration_type_code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END proration_type_code;

FUNCTION Updated_Flag(p_Updated_Flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Updated_Flag IS NULL OR
        p_Updated_Flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UPDATED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Updated_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Updated_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Updated_Flag;


FUNCTION Update_Allowed(p_Update_Allowed IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Update_Allowed IS NULL OR
        p_Update_Allowed = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UPDATE_ALLOWED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Update_Allowed'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Allowed'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Allowed;


FUNCTION Created_By ( p_created_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_created_by IS NULL OR
        p_created_by = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_created_by;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREATED_BY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('created_by'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_By'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_By;

FUNCTION Creation_Date ( p_creation_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_creation_date IS NULL OR
        p_creation_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_creation_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREATION_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('creation_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Creation_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Creation_Date;

--

FUNCTION Override_Flag ( p_override_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_override_flag IS NULL OR
        p_override_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OVERRIDE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('override_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'override_flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Flag;

--
FUNCTION Request_Date ( p_request_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_request_date IS NULL OR
        p_request_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REQUEST_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('request_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request_Date;

FUNCTION Price_Adj_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTEXT');

		IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
	        AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   /*IF NOT Desc_Flex('ONT','OE_PRICE_ADJUSTMENTS') THEN
			RETURN FALSE;
                   END IF;*/


                END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'Price_Adj_Desc_Flex');
     END IF;


     RETURN FALSE;


END Price_Adj_Desc_Flex;



FUNCTION Flex_Title ( p_flex_title IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_flex_title IS NULL OR
        p_flex_title = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_flex_title;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','flex_title');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flex_Title'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flex_Title;

FUNCTION Order_Price_Attrib ( p_order_price_attrib_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_order_price_attrib_id IS NULL OR
        p_order_price_attrib_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_price_attrib_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_price_attrib');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Price_Attrib'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Price_Attrib;

--  END GEN validate


END OE_Validate_adj;

/

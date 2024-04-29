--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_HEADER_ADJ" AS
/* $Header: OEXLHADB.pls 120.1 2005/12/29 04:24:29 ppnair noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Header_Adj';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
)
IS
   l_return_status	     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_price_adj_error	VARCHAR2(30):= NULL;
   l_attribute_name	     VARCHAR2(50):= NULL;
   l_tmp_string	     VARCHAR2(30):= NULL;
   l_agr_type_code	     VARCHAR2(30):= NULL;
    -- This change is required since we are dropping the profile OE_ORGANIZATION
    -- _ID. Change made by Esha.
   l_organization_id NUMBER:= To_number(OE_Sys_Parameters.VALUE
  						 ('MASTER_ORGANIZATION_ID'));
  /* l_organization_id	NUMBER	    := To_number(FND_PROFILE.VALUE
						 ('SO_ORGANIZATION_ID'));*/
BEGIN

    oe_debug_pub.Add('Entering OE_VALIDATE_HEADER_ADJ.Entity',1);
    --  Check required attributes.

    IF  p_Header_Adj_rec.price_adjustment_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_adjustment');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    -- Check the Header_Id on the record.

    IF  p_Header_Adj_rec.header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('HEADER_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    IF p_Header_adj_rec.list_header_id is null
	and p_Header_adj_rec.list_line_type_code not in ('COST','TAX')
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_header');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    IF p_Header_adj_rec.list_header_id is not null and
		p_Header_adj_rec.list_line_id IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_Line');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    IF p_Header_adj_rec.list_line_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_line_type_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --

    -- bug 1999869, also check for applied_flag.
    /* IF upper(p_Header_adj_rec.updated_flag) ='Y'  and
       upper(p_Header_adj_rec.applied_flag) ='Y'  and
	p_Header_adj_rec.change_reason_code is null THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','change_reason_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF; */

    IF p_Header_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' and
       p_Header_adj_rec.charge_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('CHARGE_TYPE_CODE'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Header_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
       p_Header_adj_rec.adjusted_amount IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('ADJUSTED_AMOUNT'));
            OE_MSG_PUB.Add;

        END IF;
    END IF;

    IF p_Header_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
          p_Header_adj_rec.operand IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('OPERAND'));
            OE_MSG_PUB.Add;

        END IF;
    END IF;

    /* Added Validation check for the AETC flexfield */

    IF p_Header_adj_rec.ac_attribute1 IS NOT NULL OR
	  p_Header_adj_rec.ac_attribute2 IS NOT NULL OR
	  p_Header_adj_rec.ac_attribute3 IS NOT NULL OR
	  p_Header_adj_rec.ac_attribute4 IS NOT NULL OR
	  p_Header_adj_rec.ac_attribute5 IS NOT NULL OR
	  p_Header_adj_rec.ac_attribute6 IS NOT NULL
    THEN
	   l_attribute_name := NULL;
        IF p_Header_adj_rec.ac_attribute4 IS NULL THEN
		  l_attribute_name := 'AETC Number';
	   END IF;
        IF p_Header_adj_rec.ac_attribute5 IS NULL THEN
		  l_attribute_name := 'AETC Responsibility Code';
	   END IF;
        IF p_Header_adj_rec.ac_attribute6 IS NULL THEN
		  l_attribute_name := 'AETC Reason Code';
	   END IF;
	   IF l_attribute_name IS NOT NULL THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute_name);
                OE_MSG_PUB.Add;

            END IF;
	   END IF;

    END IF;
    --
    --  Validate attribute dependencies here.
    --

    IF p_Header_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
	  p_Header_adj_rec.charge_type_code IS NOT NULL AND
	  p_Header_adj_rec.charge_subtype_code IS NOT NULL AND
       ((NOT OE_GLOBALS.EQUAL(p_Header_adj_rec.charge_type_code,
                             p_Old_Header_adj_rec.charge_type_code)) OR
       (NOT OE_GLOBALS.EQUAL(p_Header_adj_rec.charge_subtype_code,
                             p_Old_Header_adj_rec.charge_subtype_code)))
     THEN

       BEGIN
                SELECT 'VALID'
                INTO l_tmp_string
                FROM QP_LOOKUPS
                WHERE LOOKUP_TYPE = p_Header_Adj_rec.charge_type_code
                AND LOOKUP_CODE = p_Header_Adj_rec.charge_subtype_code
                AND TRUNC(sysdate) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,sysdate))
                    AND TRUNC(NVL(END_DATE_ACTIVE,sysdate))
                AND ENABLED_FLAG = 'Y';
       EXCEPTION

          WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('CHARGE_SUBTYPE_CODE'));
             OE_MSG_PUB.Add;

          WHEN OTHERS THEN
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 OE_MSG_PUB.Add_Exc_Msg
                 ( G_PKG_NAME ,
                   'Record - Charge Type/Subtype validation'
                 );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;

    IF p_Header_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' and
	  p_Header_adj_rec.arithmetic_operator <> 'LUMPSUM'
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('ARITHMETIC_OPERATOR'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;




-- Validate list_header_id , list_line_id, list_line_type_code
    /*
    --  Validate that the total percentage on the header has not exceeded
    --  100%. LOG A DELAYED REQUEST TO EXECUTE LATER.
    oe_delayed_requests_pvt.
      log_request(p_entity_code		=> OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		  p_entity_id		=> p_Header_adj_rec.header_id,
		  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
	          p_requesting_entity_id => p_Header_adj_rec.price_adjustment_id,
		  p_request_type	=> OE_GLOBALS.G_CHECK_PERCENTAGE,
		  x_return_status	=> l_return_status);
*/


    --  Done validating entity

    x_return_status := l_return_status;
    oe_debug_pub.Add('Exiting OE_VALIDATE_HEADER_ADJ.Entity',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
)
IS
BEGIN

    oe_debug_pub.Add('Entering OE_VALIDATE_HEADER_ADJ.Attributes',1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Header_Adj attributes

    IF  p_Header_Adj_rec.price_adjustment_id IS NOT NULL AND
        (   p_Header_Adj_rec.price_adjustment_id <>
            p_old_Header_Adj_rec.price_adjustment_id OR
            p_old_Header_Adj_rec.price_adjustment_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Price_Adjustment(p_Header_Adj_rec.price_adjustment_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.creation_date IS NOT NULL AND
        (   p_Header_Adj_rec.creation_date <>
            p_old_Header_Adj_rec.creation_date OR
            p_old_Header_Adj_rec.creation_date IS NULL )
    THEN
        IF NOT oe_validate_adj.Creation_Date(p_Header_Adj_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    IF  p_Header_Adj_rec.pricing_phase_id IS NOT NULL AND
        (   p_Header_Adj_rec.pricing_phase_id <>
            p_old_Header_Adj_rec.pricing_phase_id OR
            p_old_Header_Adj_rec.pricing_phase_id IS NULL )
    THEN
     IF NOT oe_validate_adj.Pricing_Phase_id(p_Header_Adj_rec.pricing_phase_id)
	 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Header_Adj_rec.adjusted_amount IS NOT NULL AND
        (   p_Header_Adj_rec.adjusted_amount <>
            p_old_Header_Adj_rec.adjusted_amount OR
            p_old_Header_Adj_rec.adjusted_amount IS NULL )
    THEN
     IF NOT oe_validate_adj.Adjusted_Amount(p_Header_Adj_rec.adjusted_amount)
	 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.created_by IS NOT NULL AND
        (   p_Header_Adj_rec.created_by <>
            p_old_Header_Adj_rec.created_by OR
            p_old_Header_Adj_rec.created_by IS NULL )
    THEN
        IF NOT oe_validate_adj.Created_By(p_Header_Adj_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.last_update_date IS NOT NULL AND
        (   p_Header_Adj_rec.last_update_date <>
            p_old_Header_Adj_rec.last_update_date OR
            p_old_Header_Adj_rec.last_update_date IS NULL )
    THEN
        IF NOT oe_validate_adj.Last_Update_Date(p_Header_Adj_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.last_updated_by IS NOT NULL AND
        (   p_Header_Adj_rec.last_updated_by <>
            p_old_Header_Adj_rec.last_updated_by OR
            p_old_Header_Adj_rec.last_updated_by IS NULL )
    THEN
        IF NOT oe_validate_adj.Last_Updated_By(p_Header_Adj_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.last_update_login IS NOT NULL AND
        (   p_Header_Adj_rec.last_update_login <>
            p_old_Header_Adj_rec.last_update_login OR
            p_old_Header_Adj_rec.last_update_login IS NULL )
    THEN
        IF NOT oe_validate_adj.Last_Update_Login(p_Header_Adj_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.program_application_id IS NOT NULL AND
        (   p_Header_Adj_rec.program_application_id <>
            p_old_Header_Adj_rec.program_application_id OR
            p_old_Header_Adj_rec.program_application_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Program_Application(p_Header_Adj_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.program_id IS NOT NULL AND
        (   p_Header_Adj_rec.program_id <>
            p_old_Header_Adj_rec.program_id OR
            p_old_Header_Adj_rec.program_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Program(p_Header_Adj_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.program_update_date IS NOT NULL AND
        (   p_Header_Adj_rec.program_update_date <>
            p_old_Header_Adj_rec.program_update_date OR
            p_old_Header_Adj_rec.program_update_date IS NULL )
    THEN
        IF NOT oe_validate_adj.Program_Update_Date(p_Header_Adj_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.request_id IS NOT NULL AND
        (   p_Header_Adj_rec.request_id <>
            p_old_Header_Adj_rec.request_id OR
            p_old_Header_Adj_rec.request_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Request(p_Header_Adj_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.header_id IS NOT NULL AND
        (   p_Header_Adj_rec.header_id <>
            p_old_Header_Adj_rec.header_id OR
            p_old_Header_Adj_rec.header_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Header(p_Header_Adj_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.discount_id IS NOT NULL AND
        (   p_Header_Adj_rec.discount_id <>
            p_old_Header_Adj_rec.discount_id OR
            p_old_Header_Adj_rec.discount_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Discount(p_Header_Adj_rec.discount_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.discount_line_id IS NOT NULL AND
        (   p_Header_Adj_rec.discount_line_id <>
            p_old_Header_Adj_rec.discount_line_id OR
            p_old_Header_Adj_rec.discount_line_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Discount_Line(p_Header_Adj_rec.discount_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.automatic_flag IS NOT NULL AND
        (   p_Header_Adj_rec.automatic_flag <>
            p_old_Header_Adj_rec.automatic_flag OR
            p_old_Header_Adj_rec.automatic_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.Automatic(p_Header_Adj_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.percent IS NOT NULL AND
        (   p_Header_Adj_rec.percent <>
            p_old_Header_Adj_rec.percent OR
            p_old_Header_Adj_rec.percent IS NULL )
    THEN
        IF NOT oe_validate_adj.Percent(p_Header_Adj_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.line_id IS NOT NULL AND
        (   p_Header_Adj_rec.line_id <>
            p_old_Header_Adj_rec.line_id OR
            p_old_Header_Adj_rec.line_id IS NULL )
    THEN
        IF NOT oe_validate_adj.Line(p_Header_Adj_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.list_line_no IS NOT NULL AND
        (   p_Header_Adj_rec.list_line_no <>
            p_old_Header_Adj_rec.list_line_no OR
            p_old_Header_Adj_rec.list_line_no IS NULL )
    THEN
        IF NOT oe_validate_adj.List_Line_No(p_Header_Adj_rec.list_line_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.source_system_code IS NOT NULL AND
        (   p_Header_Adj_rec.source_system_code <>
            p_old_Header_Adj_rec.source_system_code OR
            p_old_Header_Adj_rec.source_system_code IS NULL )
    THEN
        IF NOT oe_validate_adj.source_system_code(p_Header_Adj_rec.source_system_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.benefit_qty IS NOT NULL AND
        (   p_Header_Adj_rec.benefit_qty <>
            p_old_Header_Adj_rec.benefit_qty OR
            p_old_Header_Adj_rec.benefit_qty IS NULL )
    THEN
        IF NOT oe_validate_adj.benefit_qty(p_Header_Adj_rec.benefit_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.benefit_uom_code IS NOT NULL AND
        (   p_Header_Adj_rec.benefit_uom_code <>
            p_old_Header_Adj_rec.benefit_uom_code OR
            p_old_Header_Adj_rec.benefit_uom_code IS NULL )
    THEN
        IF NOT oe_validate_adj.benefit_uom_code(p_Header_Adj_rec.benefit_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.print_on_invoice_flag IS NOT NULL AND
        (   p_Header_Adj_rec.print_on_invoice_flag <>
            p_old_Header_Adj_rec.print_on_invoice_flag OR
            p_old_Header_Adj_rec.print_on_invoice_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.print_on_invoice_flag(p_Header_Adj_rec.print_on_invoice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.expiration_date IS NOT NULL AND
        (   p_Header_Adj_rec.expiration_date <>
            p_old_Header_Adj_rec.expiration_date OR
            p_old_Header_Adj_rec.expiration_date IS NULL )
    THEN
        IF NOT oe_validate_adj.expiration_date(p_Header_Adj_rec.expiration_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.rebate_transaction_type_code IS NOT NULL AND
        (   p_Header_Adj_rec.rebate_transaction_type_code <>
            p_old_Header_Adj_rec.rebate_transaction_type_code OR
            p_old_Header_Adj_rec.rebate_transaction_type_code IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_transaction_type_code(p_Header_Adj_rec.rebate_transaction_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Header_Adj_rec.rebate_transaction_reference IS NOT NULL AND
        (   p_Header_Adj_rec.rebate_transaction_reference <>
            p_old_Header_Adj_rec.rebate_transaction_reference OR
            p_old_Header_Adj_rec.rebate_transaction_reference IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_transaction_reference(p_Header_Adj_rec.rebate_transaction_reference) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.rebate_payment_system_code IS NOT NULL AND
        (   p_Header_Adj_rec.rebate_payment_system_code <>
            p_old_Header_Adj_rec.rebate_payment_system_code OR
            p_old_Header_Adj_rec.rebate_payment_system_code IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_payment_system_code(p_Header_Adj_rec.rebate_payment_system_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.Redeemed_Date IS NOT NULL AND
        (   p_Header_Adj_rec.Redeemed_Date <>
            p_old_Header_Adj_rec.Redeemed_Date OR
            p_old_Header_Adj_rec.Redeemed_Date IS NULL )
    THEN
        IF NOT oe_validate_adj.Redeemed_Date(p_Header_Adj_rec.Redeemed_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.redeemed_flag IS NOT NULL AND
        (   p_Header_Adj_rec.redeemed_flag <>
            p_old_Header_Adj_rec.redeemed_flag OR
            p_old_Header_Adj_rec.redeemed_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.Redeemed_Flag(p_Header_Adj_rec.redeemed_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.accrual_flag IS NOT NULL AND
        (   p_Header_Adj_rec.accrual_flag <>
            p_old_Header_Adj_rec.accrual_flag OR
            p_old_Header_Adj_rec.accrual_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.Accrual_Flag(p_Header_Adj_rec.accrual_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.credit_or_charge_flag IS NOT NULL AND
        (   p_Header_Adj_rec.credit_or_charge_flag <>
            p_old_Header_Adj_rec.credit_or_charge_flag OR
            p_old_Header_Adj_rec.credit_or_charge_flag IS NULL )
    THEN
        IF NOT OE_Validate.credit_or_charge_flag(p_Header_Adj_rec.credit_or_charge_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.charge_type_code IS NOT NULL AND
        (   p_Header_Adj_rec.charge_type_code <>
            p_old_Header_Adj_rec.charge_type_code OR
            p_old_Header_Adj_rec.charge_type_code IS NULL )
    THEN
        IF NOT OE_Validate.charge_type_code(p_Header_Adj_rec.charge_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.charge_subtype_code IS NOT NULL AND
        (   p_Header_Adj_rec.charge_subtype_code <>
            p_old_Header_Adj_rec.charge_subtype_code OR
            p_old_Header_Adj_rec.charge_subtype_code IS NULL )
    THEN
        IF NOT OE_Validate.charge_subtype_code(p_Header_Adj_rec.charge_subtype_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.estimated_flag IS NOT NULL AND
        (   p_Header_Adj_rec.estimated_flag <>
            p_old_Header_Adj_rec.estimated_flag OR
            p_old_Header_Adj_rec.estimated_flag IS NULL )
    THEN
        IF NOT OE_Validate.estimated(p_Header_Adj_rec.estimated_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Adj_rec.invoiced_flag IS NOT NULL AND
        (   p_Header_Adj_rec.invoiced_flag <>
            p_old_Header_Adj_rec.invoiced_flag OR
            p_old_Header_Adj_rec.invoiced_flag IS NULL )
    THEN
        IF NOT OE_Validate.invoiced(p_Header_Adj_rec.invoiced_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

 if OE_GLOBALS.g_validate_desc_flex ='Y' then --4343612
      oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Header_Adj.attributes ',1);
    IF  (p_Header_Adj_rec.context IS NOT NULL AND
        (   p_Header_Adj_rec.context <>
            p_old_Header_Adj_rec.context OR
            p_old_Header_Adj_rec.context IS NULL ))
    OR  (p_Header_Adj_rec.attribute1 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute1 <>
            p_old_Header_Adj_rec.attribute1 OR
            p_old_Header_Adj_rec.attribute1 IS NULL ))
    OR  (p_Header_Adj_rec.attribute2 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute2 <>
            p_old_Header_Adj_rec.attribute2 OR
            p_old_Header_Adj_rec.attribute2 IS NULL ))
    OR  (p_Header_Adj_rec.attribute3 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute3 <>
            p_old_Header_Adj_rec.attribute3 OR
            p_old_Header_Adj_rec.attribute3 IS NULL ))
    OR  (p_Header_Adj_rec.attribute4 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute4 <>
            p_old_Header_Adj_rec.attribute4 OR
            p_old_Header_Adj_rec.attribute4 IS NULL ))
    OR  (p_Header_Adj_rec.attribute5 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute5 <>
            p_old_Header_Adj_rec.attribute5 OR
            p_old_Header_Adj_rec.attribute5 IS NULL ))
    OR  (p_Header_Adj_rec.attribute6 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute6 <>
            p_old_Header_Adj_rec.attribute6 OR
            p_old_Header_Adj_rec.attribute6 IS NULL ))
    OR  (p_Header_Adj_rec.attribute7 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute7 <>
            p_old_Header_Adj_rec.attribute7 OR
            p_old_Header_Adj_rec.attribute7 IS NULL ))
    OR  (p_Header_Adj_rec.attribute8 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute8 <>
            p_old_Header_Adj_rec.attribute8 OR
            p_old_Header_Adj_rec.attribute8 IS NULL ))
    OR  (p_Header_Adj_rec.attribute9 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute9 <>
            p_old_Header_Adj_rec.attribute9 OR
            p_old_Header_Adj_rec.attribute9 IS NULL ))
    OR  (p_Header_Adj_rec.attribute10 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute10 <>
            p_old_Header_Adj_rec.attribute10 OR
            p_old_Header_Adj_rec.attribute10 IS NULL ))
    OR  (p_Header_Adj_rec.attribute11 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute11 <>
            p_old_Header_Adj_rec.attribute11 OR
            p_old_Header_Adj_rec.attribute11 IS NULL ))
    OR  (p_Header_Adj_rec.attribute12 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute12 <>
            p_old_Header_Adj_rec.attribute12 OR
            p_old_Header_Adj_rec.attribute12 IS NULL ))
    OR  (p_Header_Adj_rec.attribute13 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute13 <>
            p_old_Header_Adj_rec.attribute13 OR
            p_old_Header_Adj_rec.attribute13 IS NULL ))
    OR  (p_Header_Adj_rec.attribute14 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute14 <>
            p_old_Header_Adj_rec.attribute14 OR
            p_old_Header_Adj_rec.attribute14 IS NULL ))
    OR  (p_Header_Adj_rec.attribute15 IS NOT NULL AND
        (   p_Header_Adj_rec.attribute15 <>
            p_old_Header_Adj_rec.attribute15 OR
            p_old_Header_Adj_rec.attribute15 IS NULL ))
    THEN

    --  These calls are temporarily commented out

         oe_debug_pub.add('Before calling Header Adjustment Price_Adj_Desc_Flex',2);

         IF NOT oe_validate_adj.Price_Adj_Desc_Flex
          (p_context            => p_Header_Adj_rec.context
          ,p_attribute1         => p_Header_Adj_rec.attribute1
          ,p_attribute2         => p_Header_Adj_rec.attribute2
          ,p_attribute3         => p_Header_Adj_rec.attribute3
          ,p_attribute4         => p_Header_Adj_rec.attribute4
          ,p_attribute5         => p_Header_Adj_rec.attribute5
          ,p_attribute6         => p_Header_Adj_rec.attribute6
          ,p_attribute7         => p_Header_Adj_rec.attribute7
          ,p_attribute8         => p_Header_Adj_rec.attribute8
          ,p_attribute9         => p_Header_Adj_rec.attribute9
          ,p_attribute10        => p_Header_Adj_rec.attribute10
          ,p_attribute11        => p_Header_Adj_rec.attribute11
          ,p_attribute12        => p_Header_Adj_rec.attribute12
          ,p_attribute13        => p_Header_Adj_rec.attribute13
          ,p_attribute14        => p_Header_Adj_rec.attribute14
          ,p_attribute15        => p_Header_Adj_rec.attribute15) THEN


                x_return_status := FND_API.G_RET_STS_ERROR;

            oe_debug_pub.add('After Header Adjustment desc_flex  ' || x_return_status,2);

         END IF;

    END IF;

    --  Done validating attributes
    oe_debug_pub.Add('Exiting OE_VALIDATE_HEADER_ADJ.Attributes',1);
    end if ; /* if OE_GLOBALS.g_validate_desc_flex ='Y' then bug4343612*/

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;


END OE_Validate_Header_Adj;

/

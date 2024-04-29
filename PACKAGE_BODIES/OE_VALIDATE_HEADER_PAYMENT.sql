--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_HEADER_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_HEADER_PAYMENT" AS
/* $Header: OEXLHPMB.pls 120.5.12010000.2 2009/08/19 05:02:05 amimukhe ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Header_Payment';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
,   p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_REC
)
IS
l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_prepay_payment_amount		NUMBER := 0;
l_prepaid_amount		NUMBER := 0;
l_count  			NUMBER := 0;
l_line_payment_count            NUMBER := 0;
--R12 CC Encryption
l_invoice_to_org_id		NUMBER;
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Payments.Entity',1);
    --  Check required attributes.

    IF  p_Header_Payment_rec.payment_number IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment');
            oe_msg_pub.Add;

        END IF;

    END IF;

    IF  p_Header_Payment_rec.payment_type_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment type code');
            oe_msg_pub.Add;

        END IF;

    END IF;

    IF p_Header_Payment_rec.payment_collection_event = 'PREPAY' THEN

       /*
       IF p_Header_Payment_rec.receipt_method_id is null THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt Method');
            oe_msg_pub.Add;

          END IF;

       END IF;
       */

              -- Modified for Bug 8478559. This will allow users to save Payment record by specifying either the Payment Amount or Payment Percentage for Prepayment case.
              -- One of them is mandatory. This is for Credit Card and Debit Card payment types only. For other Payment Types, Payment Amount will continue to be mandatory.
              IF p_Header_Payment_rec.payment_type_code in ('CREDIT_CARD', 'DIRECT_DEBIT') THEN
                IF p_Header_Payment_rec.payment_amount is null AND
                   p_Header_Payment_rec.payment_percentage is null
                THEN

                   l_return_status := FND_API.G_RET_STS_ERROR;

                   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN

                     FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                     FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment amount or percentage');
                     oe_msg_pub.Add;

                   END IF;
                END IF;
              ELSE
                IF p_Header_Payment_rec.payment_amount is null
                THEN

                   l_return_status := FND_API.G_RET_STS_ERROR;

                   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN

                     FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                     FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment amount');
                     oe_msg_pub.Add;

                   END IF;
                END IF;
              END IF;
              -- End of changes for bug 8478559
        --commented for bug 8478559
       /*IF p_Header_Payment_rec.payment_amount is null THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment amount');
            oe_msg_pub.Add;

          END IF;

       END IF;*/

       IF p_Header_Payment_rec.payment_amount < 0 THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

            FND_MESSAGE.SET_NAME('ONT','ONT_NO_NEGTIVE_PAYMENT_AMOUNT');
            oe_msg_pub.Add;

          END IF;

       END IF;

       /* Removed the following validation.
       -- total prepayment payment amount cannot be greater than order total.
       BEGIN
         select nvl(sum(payment_amount),0)
         into l_prepay_payment_amount
         from oe_payments
         where header_id = p_Header_Payment_rec.header_id
         and payment_collection_event = 'PREPAY'
         and prepaid_amount is null
         and nvl(payment_number, -1) <> nvl(p_Header_Payment_rec.payment_number, -1);
       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_prepay_payment_amount := 0;
       END;


       BEGIN
         select nvl(sum(prepaid_amount),0)
         into l_prepaid_amount
         from oe_payments
         where header_id = p_Header_Payment_rec.header_id
         and prepaid_amount is not null
         and nvl(payment_number, -1) <> nvl(p_Header_Payment_rec.payment_number, -1);
       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_prepaid_amount := 0;
       END;

       l_prepay_payment_amount := l_prepay_payment_amount
                                  + l_prepaid_amount;

      IF (p_Header_Payment_rec.payment_amount + l_prepay_payment_amount)
          > OE_OE_TOTALS_SUMMARY.Outbound_Order_Total(p_Header_Payment_rec.header_id) THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

            FND_MESSAGE.SET_NAME('ONT','ONT_PREPAYMENT_PERCENT');
            oe_msg_pub.Add;

          END IF;

       END IF;
       */



       -- if there exists any line level payment.
       select count(payment_type_code) into l_line_payment_count
       from oe_payments
       where header_id = p_Header_Payment_rec.header_id
       and line_id is not null
       and payment_type_code <> 'COMMITMENT';

       if l_line_payment_count > 0 then

          IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            fnd_message.set_name('ONT', 'ONT_LINE_PAYMENTS_EXIST');
            oe_msg_pub.add;
          END IF;

          l_return_status := FND_API.G_RET_STS_ERROR;

       end if;

    END IF; -- if payment_collection_event = 'PREPAY'

    --  Check rest of required attributes here.
    --

    IF  p_Header_Payment_rec.HEADER_ID IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','HEADER');
            oe_msg_pub.Add;

        END IF;

    END IF;

    IF p_Header_Payment_rec.payment_type_code = 'CREDIT_CARD'  THEN
       --R12 CC Encryption
       IF p_header_payment_rec.trxn_extension_id is null then
	       --bug 5176015
	       /*IF  p_Header_Payment_rec.credit_card_number IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_NUMBER');
		       oe_msg_pub.Add;

		   END IF;
	       ELSIF  p_Header_Payment_rec.credit_card_holder_name IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_HOLDER_NAME');
		       oe_msg_pub.Add;

		   END IF;
	       ELSIF  p_Header_Payment_rec.credit_card_expiration_date IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_EXPIRATION_DATE');
		       oe_msg_pub.Add;

		   END IF;

		END IF;*/
		--bug 5176015
		--R12 CC Encryption
		oe_debug_pub.add('Header id in entity ksu'||p_header_payment_rec.header_id);
	        Begin
			Select 	invoice_to_org_id
			Into	l_invoice_to_org_id
			From	oe_order_headers_all
			Where	header_id = p_header_payment_rec.header_id;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			Null;
		End;
		oe_debug_pub.add('Invoice to org id'||l_invoice_to_org_id);
		IF l_invoice_to_org_id IS NULL THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
	           	IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	          	THEN
	               		FND_MESSAGE.SET_NAME('ONT', 'OE_VPM_INV_TO_REQUIRED');
	              		oe_msg_pub.Add;
	         	END IF;
		END IF;
		--R12 CC Encryption
	END IF;
	--R12 CC Encryption

    ELSIF p_Header_Payment_rec.payment_type_code = 'CHECK' THEN

       IF  p_Header_Payment_rec.check_number IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CHECK_NUMBER');
               oe_msg_pub.Add;

           END IF;
       END IF;
/* comment out for R12
    ELSIF p_Header_Payment_rec.payment_type_code in ('ACH', 'DIRECT_DEBIT')
    THEN

       IF  p_Header_Payment_rec.payment_trx_id IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Bank Account ID');
               oe_msg_pub.Add;

           END IF;
       END IF;
  */

    END IF;

    IF p_Header_Payment_rec.payment_type_code in ('ACH', 'DIRECT_DEBIT') THEN

     IF  p_Header_Payment_rec.receipt_method_id IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt Method');
               oe_msg_pub.Add;

           END IF;
       END IF;

    END IF; -- if payment_type_code in ACH, DIRECT_DEBIT, CREDIT_CARD

    IF NVL(p_Header_Payment_rec.payment_collection_event, 'INVOICE') = 'INVOICE' THEN

         l_count := 0;

         -- Cannot have more than one 'Invoice' payment instrument
         SELECT count(*)
         INTO l_count
         FROM oe_payments
         WHERE header_id = p_Header_Payment_rec.header_id
         AND   line_id is null
         AND   payment_level_code = 'ORDER'
         AND   nvl(payment_collection_event, 'INVOICE') = 'INVOICE'
         AND   nvl(payment_number, -1) <> nvl(p_Header_Payment_rec.payment_number, -1);

         IF l_count > 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','ONT_INVOICE_PAYMENT_INSTRUMENT');
               oe_msg_pub.Add;

           END IF;
         END IF;
    ELSIF p_Header_Payment_rec.payment_type_code = 'WIRE_TRANSFER' AND
          p_Header_Payment_rec.payment_collection_event = 'PREPAY' THEN

         -- wire transfer is not supported for prepayment

          l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
-- Wire Transfer is not supported for prepayments.
               FND_MESSAGE.SET_NAME('ONT','ONT_NO_WIRE_FOR_PREPAY');
               oe_msg_pub.Add;

           END IF;

    END IF;

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --

    --  Done validating entity

    x_return_status := l_return_status;

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Payments.Entity',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
,   p_old_Header_Payment_rec        IN  OE_Order_PUB.Header_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_REC
)
IS
l_line_payment_count number;
l_cc_security_code_use    VARCHAR2(20);  --R12 CVV2
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Payments.Attributes',1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Header_Payment attributes

    IF  p_Header_Payment_rec.created_by IS NOT NULL AND
        (   p_Header_Payment_rec.created_by <>
            p_old_Header_Payment_rec.created_by OR
            p_old_Header_Payment_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate.Created_By(p_Header_Payment_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    oe_debug_pub.add('return status 1 : ' || x_return_status);

    IF  p_Header_Payment_rec.creation_date IS NOT NULL AND
        (   p_Header_Payment_rec.creation_date <>
            p_old_Header_Payment_rec.creation_date OR
            p_old_Header_Payment_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate.Creation_Date(p_Header_Payment_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    oe_debug_pub.add('return status 2 : ' || x_return_status);

    IF  p_Header_Payment_rec.header_id IS NOT NULL AND
        (   p_Header_Payment_rec.header_id <>
            p_old_Header_Payment_rec.header_id OR
            p_old_Header_Payment_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate.Header(p_Header_Payment_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('return status 3 : ' || x_return_status);

    IF  p_Header_Payment_rec.last_updated_by IS NOT NULL AND
        (   p_Header_Payment_rec.last_updated_by <>
            p_old_Header_Payment_rec.last_updated_by OR
            p_old_Header_Payment_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate.Last_Updated_By(p_Header_Payment_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('return status 4 : ' || x_return_status);

    IF  p_Header_Payment_rec.last_update_date IS NOT NULL AND
        (   p_Header_Payment_rec.last_update_date <>
            p_old_Header_Payment_rec.last_update_date OR
            p_old_Header_Payment_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Date(p_Header_Payment_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('return status 5 : ' || x_return_status);

    IF  p_Header_Payment_rec.last_update_login IS NOT NULL AND
        (   p_Header_Payment_rec.last_update_login <>
            p_old_Header_Payment_rec.last_update_login OR
            p_old_Header_Payment_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Login(p_Header_Payment_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.line_id IS NOT NULL AND
        (   p_Header_Payment_rec.line_id <>
            p_old_Header_Payment_rec.line_id OR
            p_old_Header_Payment_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate.Line(p_Header_Payment_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.check_number IS NOT NULL AND
        (   p_Header_Payment_rec.check_number <>
            p_old_Header_Payment_rec.check_number OR
            p_old_Header_Payment_rec.check_number IS NULL )
    THEN
        IF NOT OE_Validate.check_number(p_Header_Payment_rec.check_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.credit_card_approval_code IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_approval_code <>
            p_old_Header_Payment_rec.credit_card_approval_code OR
            p_old_Header_Payment_rec.credit_card_approval_code IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_approval(p_Header_Payment_rec.credit_card_approval_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('return status 6 : ' || x_return_status);


    IF  p_Header_Payment_rec.credit_card_approval_date IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_approval_date <>
            p_old_Header_Payment_rec.credit_card_approval_date OR
            p_old_Header_Payment_rec.credit_card_approval_date IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_approval_date(p_Header_Payment_rec.credit_card_approval_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.credit_card_code IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_code <>
            p_old_Header_Payment_rec.credit_card_code OR
            p_old_Header_Payment_rec.credit_card_code IS NULL )
    THEN
        IF NOT OE_Validate.credit_card(p_Header_Payment_rec.credit_card_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('return status 7 : ' || x_return_status);
    oe_Debug_pub.add('after credit_card_code');

    --R12 CVV2
    IF  p_Header_Payment_rec.credit_card_number IS NOT NULL AND p_Header_Payment_rec.credit_card_number <> FND_API.G_MISS_CHAR THEN
        l_cc_security_code_use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
        IF l_cc_security_code_use = 'REQUIRED' THEN
           IF p_Header_Payment_rec.instrument_security_code IS NULL OR
              p_Header_Payment_rec.instrument_security_code = FND_API.G_MISS_CHAR THEN --bug 4613168, issue 22
	    	FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
     		OE_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
    END IF;
    --R12 CVV2

    oe_debug_pub.add('after security code');


    IF  p_Header_Payment_rec.credit_card_expiration_date IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_expiration_date <>
            p_old_Header_Payment_rec.credit_card_expiration_date OR
            p_old_Header_Payment_rec.credit_card_expiration_date IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_expiration_date(p_Header_Payment_rec.credit_card_expiration_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

     oe_debug_pub.add('return status 8 : ' || x_return_status);
    oe_debug_pub.add('after credit_card_expiration_date');

    IF  p_Header_Payment_rec.credit_card_holder_name IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_holder_name <>
            p_old_Header_Payment_rec.credit_card_holder_name OR
            p_old_Header_Payment_rec.credit_card_holder_name IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_holder_name(p_Header_Payment_rec.credit_card_holder_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after credit_card_holder_name');

    IF  p_Header_Payment_rec.credit_card_number IS NOT NULL AND
        (   p_Header_Payment_rec.credit_card_number <>
            p_old_Header_Payment_rec.credit_card_number OR
            p_old_Header_Payment_rec.credit_card_number IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_number(p_Header_Payment_rec.credit_card_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after credit_card_number');

    IF  p_Header_Payment_rec.payment_level_code IS NOT NULL AND
        (   p_Header_Payment_rec.payment_level_code <>
            p_old_Header_Payment_rec.payment_level_code OR
            p_old_Header_Payment_rec.payment_level_code IS NULL )
    THEN
        IF NOT OE_Validate.payment_level(p_Header_Payment_rec.payment_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

     oe_debug_pub.add('return status 9 : ' || x_return_status);
    oe_debug_pub.add('after payment_level_code');

    IF  p_Header_Payment_rec.commitment_applied_amount IS NOT NULL AND
        (   p_Header_Payment_rec.commitment_applied_amount <>
            p_old_Header_Payment_rec.commitment_applied_amount OR
            p_old_Header_Payment_rec.commitment_applied_amount IS NULL )
    THEN
        IF NOT OE_Validate.commitment_applied_amount(p_Header_Payment_rec.commitment_applied_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after commitment_applied_amount');


    IF  p_Header_Payment_rec.commitment_interfaced_amount IS NOT NULL AND
        (   p_Header_Payment_rec.commitment_interfaced_amount <>
            p_old_Header_Payment_rec.commitment_interfaced_amount OR
            p_old_Header_Payment_rec.commitment_interfaced_amount IS NULL )
    THEN
        IF NOT OE_Validate.commitment_interfaced_amount(p_Header_Payment_rec.commitment_interfaced_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after commitment_interfaced_amount');

    IF  p_Header_Payment_rec.payment_amount IS NOT NULL AND
        (   p_Header_Payment_rec.payment_amount <>
            p_old_Header_Payment_rec.payment_amount OR
            p_old_Header_Payment_rec.payment_amount IS NULL )
    THEN
        IF NOT OE_Validate.payment_amount(p_Header_Payment_rec.payment_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after payment_amount');

    IF  p_Header_Payment_rec.payment_collection_event IS NOT NULL AND
        (   p_Header_Payment_rec.payment_collection_event <>
            p_old_Header_Payment_rec.payment_collection_event OR
            p_old_Header_Payment_rec.payment_collection_event IS NULL )
    THEN
        IF NOT OE_Validate.payment_collection_event(p_Header_Payment_rec.payment_collection_event) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        select count(payment_type_code) into l_line_payment_count
        from oe_payments
        where header_id = p_Header_Payment_rec.header_id
        and line_id is not null;

        if l_line_payment_count > 0 then
           fnd_message.set_name('ONT', 'ONT_LINE_PAYMENTS_EXIST');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

    END IF;

    oe_debug_pub.add('after payment_collection_event');

    IF  p_Header_Payment_rec.payment_trx_id IS NOT NULL AND
        (   p_Header_Payment_rec.payment_trx_id <>
            p_old_Header_Payment_rec.payment_trx_id OR
            p_old_Header_Payment_rec.payment_trx_id IS NULL )
    THEN
        IF NOT OE_Validate.payment_trx(p_Header_Payment_rec.payment_trx_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after payment_trx_id');

    IF  p_Header_Payment_rec.payment_type_code IS NOT NULL AND
        (   p_Header_Payment_rec.payment_type_code <>
            p_old_Header_Payment_rec.payment_type_code OR
            p_old_Header_Payment_rec.payment_type_code IS NULL )
    THEN
        IF NOT OE_Validate.payment_type(p_Header_Payment_rec.payment_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    oe_debug_pub.add('after payment_type_code');

    IF  p_Header_Payment_rec.payment_set_id IS NOT NULL AND
        (   p_Header_Payment_rec.payment_set_id <>
            p_old_Header_Payment_rec.payment_set_id OR
            p_old_Header_Payment_rec.payment_set_id IS NULL )
    THEN
        IF NOT OE_Validate.payment_set(p_Header_Payment_rec.payment_set_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.prepaid_amount IS NOT NULL AND
        (   p_Header_Payment_rec.prepaid_amount <>
            p_old_Header_Payment_rec.prepaid_amount OR
            p_old_Header_Payment_rec.prepaid_amount IS NULL )
    THEN
        IF NOT OE_Validate.prepaid_amount(p_Header_Payment_rec.prepaid_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.receipt_method_id IS NOT NULL AND
        (   p_Header_Payment_rec.receipt_method_id <>
            p_old_Header_Payment_rec.receipt_method_id OR
            p_old_Header_Payment_rec.receipt_method_id IS NULL )
    THEN
        IF NOT OE_Validate.receipt_method(p_Header_Payment_rec.receipt_method_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.tangible_id IS NOT NULL AND
        (   p_Header_Payment_rec.tangible_id <>
            p_old_Header_Payment_rec.tangible_id OR
            p_old_Header_Payment_rec.tangible_id IS NULL )
    THEN
        IF NOT OE_Validate.tangible(p_Header_Payment_rec.tangible_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Payment_rec.trxn_extension_id IS NOT NULL AND	--R12 Process order api changes
        (   p_Header_Payment_rec.trxn_extension_id <>
            p_old_Header_Payment_rec.trxn_extension_id OR
            p_old_Header_Payment_rec.trxn_extension_id IS NULL )
    THEN
        IF NOT OE_Validate.Payment_Trxn_Extension(p_Header_Payment_rec.trxn_extension_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;	--R12 Process order api changes

    oe_debug_pub.add('after trxn_extension_id ');
    oe_debug_pub.add('attribute1 new : ' || p_Header_Payment_rec.attribute1);
    oe_debug_pub.add('attribute1 old : ' || p_old_Header_Payment_rec.attribute1);
    oe_debug_pub.add('attribute10 new : ' || p_Header_Payment_rec.attribute10);
    oe_debug_pub.add('attribute10 old : ' || p_old_Header_Payment_rec.attribute10);
    oe_debug_pub.add('attribute11 new : ' || p_Header_Payment_rec.attribute11);
    oe_debug_pub.add('attribute11 old : ' || p_old_Header_Payment_rec.attribute11);
    oe_debug_pub.add('attribute12 new : ' || p_Header_Payment_rec.attribute12);
    oe_debug_pub.add('attribute12 old : ' || p_old_Header_Payment_rec.attribute12);
    oe_debug_pub.add('attribute13 new : ' || p_Header_Payment_rec.attribute13);
    oe_debug_pub.add('attribute13 old : ' || p_old_Header_Payment_rec.attribute13);
    oe_debug_pub.add('attribute14 new : ' || p_Header_Payment_rec.attribute14);
    oe_debug_pub.add('attribute14 old : ' || p_old_Header_Payment_rec.attribute14);
    oe_debug_pub.add('attribute15 new : ' || p_Header_Payment_rec.attribute15);
    oe_debug_pub.add('attribute15 old : ' || p_old_Header_Payment_rec.attribute15);
    oe_debug_pub.add('attribute2 new : ' || p_Header_Payment_rec.attribute2);
    oe_debug_pub.add('attribute2 old : ' || p_old_Header_Payment_rec.attribute2);
    oe_debug_pub.add('attribute3 new : ' || p_Header_Payment_rec.attribute3);
    oe_debug_pub.add('attribute3 old : ' || p_old_Header_Payment_rec.attribute3);
    oe_debug_pub.add('attribute4 new : ' || p_Header_Payment_rec.attribute4);
    oe_debug_pub.add('attribute4 old : ' || p_old_Header_Payment_rec.attribute4);
    oe_debug_pub.add('attribute5 new : ' || p_Header_Payment_rec.attribute5);
    oe_debug_pub.add('attribute5 old : ' || p_old_Header_Payment_rec.attribute5);
    oe_debug_pub.add('attribute6 new : ' || p_Header_Payment_rec.attribute6);
    oe_debug_pub.add('attribute6 old : ' || p_old_Header_Payment_rec.attribute6);
    oe_debug_pub.add('attribute7 new : ' || p_Header_Payment_rec.attribute7);
    oe_debug_pub.add('attribute7 old : ' || p_old_Header_Payment_rec.attribute7);
    oe_debug_pub.add('attribute8 new : ' || p_Header_Payment_rec.attribute8);
    oe_debug_pub.add('attribute8 old : ' || p_old_Header_Payment_rec.attribute8);
    oe_debug_pub.add('attribute9 new : ' || p_Header_Payment_rec.attribute9);
    oe_debug_pub.add('attribute9 old : ' || p_old_Header_Payment_rec.attribute9);

   if OE_GLOBALS.g_validate_desc_flex ='Y' then    --4343612
        oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Header_Payment.attributes',1);
    IF  (p_Header_Payment_rec.attribute1 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute1 <>
            p_old_Header_Payment_rec.attribute1 OR
            p_old_Header_Payment_rec.attribute1 IS NULL ))
    OR  (p_Header_Payment_rec.attribute10 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute10 <>
            p_old_Header_Payment_rec.attribute10 OR
            p_old_Header_Payment_rec.attribute10 IS NULL ))
    OR  (p_Header_Payment_rec.attribute11 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute11 <>
            p_old_Header_Payment_rec.attribute11 OR
            p_old_Header_Payment_rec.attribute11 IS NULL ))
    OR  (p_Header_Payment_rec.attribute12 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute12 <>
            p_old_Header_Payment_rec.attribute12 OR
            p_old_Header_Payment_rec.attribute12 IS NULL ))
    OR  (p_Header_Payment_rec.attribute13 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute13 <>
            p_old_Header_Payment_rec.attribute13 OR
            p_old_Header_Payment_rec.attribute13 IS NULL ))
    OR  (p_Header_Payment_rec.attribute14 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute14 <>
            p_old_Header_Payment_rec.attribute14 OR
            p_old_Header_Payment_rec.attribute14 IS NULL ))
    OR  (p_Header_Payment_rec.attribute15 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute15 <>
            p_old_Header_Payment_rec.attribute15 OR
            p_old_Header_Payment_rec.attribute15 IS NULL ))
    OR  (p_Header_Payment_rec.attribute2 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute2 <>
            p_old_Header_Payment_rec.attribute2 OR
            p_old_Header_Payment_rec.attribute2 IS NULL ))
    OR  (p_Header_Payment_rec.attribute3 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute3 <>
            p_old_Header_Payment_rec.attribute3 OR
            p_old_Header_Payment_rec.attribute3 IS NULL ))
    OR  (p_Header_Payment_rec.attribute4 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute4 <>
            p_old_Header_Payment_rec.attribute4 OR
            p_old_Header_Payment_rec.attribute4 IS NULL ))
    OR  (p_Header_Payment_rec.attribute5 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute5 <>
            p_old_Header_Payment_rec.attribute5 OR
            p_old_Header_Payment_rec.attribute5 IS NULL ))
    OR  (p_Header_Payment_rec.attribute6 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute6 <>
            p_old_Header_Payment_rec.attribute6 OR
            p_old_Header_Payment_rec.attribute6 IS NULL ))
    OR  (p_Header_Payment_rec.attribute7 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute7 <>
            p_old_Header_Payment_rec.attribute7 OR
            p_old_Header_Payment_rec.attribute7 IS NULL ))
    OR  (p_Header_Payment_rec.attribute8 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute8 <>
            p_old_Header_Payment_rec.attribute8 OR
            p_old_Header_Payment_rec.attribute8 IS NULL ))
    OR  (p_Header_Payment_rec.attribute9 IS NOT NULL AND
        (   p_Header_Payment_rec.attribute9 <>
            p_old_Header_Payment_rec.attribute9 OR
            p_old_Header_Payment_rec.attribute9 IS NULL ))
    OR  (p_Header_Payment_rec.context IS NOT NULL AND
        (   p_Header_Payment_rec.context <>
            p_old_Header_Payment_rec.context OR
            p_old_Header_Payment_rec.context IS NULL ))
    THEN


         oe_debug_pub.add('Before calling Payments_Desc_Flex',2);
         IF NOT OE_VALIDATE.Payments_Desc_Flex
          (p_context            => p_Header_Payment_rec.context
          ,p_attribute1         => p_Header_Payment_rec.attribute1
          ,p_attribute2         => p_Header_Payment_rec.attribute2
          ,p_attribute3         => p_Header_Payment_rec.attribute3
          ,p_attribute4         => p_Header_Payment_rec.attribute4
          ,p_attribute5         => p_Header_Payment_rec.attribute5
          ,p_attribute6         => p_Header_Payment_rec.attribute6
          ,p_attribute7         => p_Header_Payment_rec.attribute7
          ,p_attribute8         => p_Header_Payment_rec.attribute8
          ,p_attribute9         => p_Header_Payment_rec.attribute9
          ,p_attribute10        => p_Header_Payment_rec.attribute10
          ,p_attribute11        => p_Header_Payment_rec.attribute11
          ,p_attribute12        => p_Header_Payment_rec.attribute12
          ,p_attribute13        => p_Header_Payment_rec.attribute13
          ,p_attribute14        => p_Header_Payment_rec.attribute14
          ,p_attribute15        => p_Header_Payment_rec.attribute15) THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

         oe_debug_pub.add('After Payments_Desc_Flex  ' || x_return_status,2);

    END IF;

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Payments.Attributes',1);
    end if ; /*if OE_GLOBALS.g_validate_desc_flex ='Y' then for bug4343612 */
    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Header_Payment_rec            IN  OE_Order_PUB.Header_Payment_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Header_Payments.Entity_Delete',1);
    --  Validate entity delete.
    NULL;
    --  Done.

    x_return_status := l_return_status;
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Header_Payments.Entity_Delete',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END OE_Validate_Header_Payment;

/

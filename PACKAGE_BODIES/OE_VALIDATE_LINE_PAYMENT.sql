--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_LINE_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_LINE_PAYMENT" AS
/* $Header: OEXLLPMB.pls 120.6 2006/07/31 18:44:40 lkxu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Line_Payment';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_count  NUMBER := 0;
l_comt_count NUMBER := 0;
l_prepay_count number;
l_term_id number;
l_prepayment_flag VARCHAR2(1) := NULL;
--R12 CC Encryption
l_invoice_to_org_id NUMBER;

--bug5176401 start
l_hdr_trxn_extn_id NUMBER;
l_hdr_auth_date DATE;
l_lin_creation_date DATE;
l_hdr_cc_pmt_exists BOOLEAN;
l_lin_cc_pmt_allowed BOOLEAN;
--bug5176401 end

BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Line_Payments.Entity',1);
    --  Check required attributes.

    IF  p_Line_Payment_rec.payment_number IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment');
            oe_msg_pub.Add;

        END IF;

    END IF;

    IF  p_Line_Payment_rec.HEADER_ID IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Header');
            oe_msg_pub.Add;

        END IF;

    END IF;


    IF  p_Line_Payment_rec.LINE_ID IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','LINE');
            oe_msg_pub.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF p_Line_Payment_rec.payment_type_code = 'CREDIT_CARD'  THEN
	--Need to validate the credit card attributes only if the
	--trxn extension id is null
	IF p_Line_Payment_rec.trxn_extension_id is null THEN --R12 CC Encryption
		--bug 5176015
	       /*IF  p_Line_Payment_rec.credit_card_number IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_NUMBER');
		       oe_msg_pub.Add;

		   END IF;
	       ELSIF  p_line_Payment_rec.credit_card_holder_name IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_HOLDER_NAME');
		       oe_msg_pub.Add;

		   END IF;
	       ELSIF  p_line_Payment_rec.credit_card_expiration_date IS NULL THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		       FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
		       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CREDIT_CARD_EXPIRATION_DATE');
		       oe_msg_pub.Add;

		   END IF;
	       END IF;*/
	       --bug 5176015

	       --bug5176401 start
            IF p_line_payment_rec.Operation = OE_GLOBALS.G_OPR_CREATE THEN
               BEGIN
		  SELECT trxn_extension_id
		  INTO l_hdr_trxn_extn_id
		  FROM oe_payments
		  WHERE header_id=p_Line_Payment_rec.header_id
		  AND line_id IS NULL
		  AND nvl(payment_collection_event, 'PREPAY') = 'INVOICE';

		  l_hdr_cc_pmt_exists := TRUE;
	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     l_hdr_cc_pmt_exists := FALSE;
		     l_lin_cc_pmt_allowed := TRUE;
		  WHEN OTHERS THEN
		     l_hdr_cc_pmt_exists := FALSE;
		     l_lin_cc_pmt_allowed := TRUE;
	       END;

               IF l_hdr_cc_pmt_exists AND
                  l_hdr_trxn_extn_id IS NOT NULL THEN
                  BEGIN
		     SELECT authorization_date
	             INTO l_hdr_auth_date
	             FROM IBY_TRXN_EXT_AUTHS_V
	             WHERE trxn_extension_id = l_hdr_trxn_extn_id
	             AND authorization_status=0
	             AND effective_auth_amount > 0;

		     IF l_hdr_auth_date IS NOT NULL THEN
			BEGIN
			   SELECT creation_date
			   INTO l_lin_creation_date
			   FROM oe_order_lines_all
			   WHERE line_id=p_line_Payment_rec.line_id;
			EXCEPTION
			   WHEN OTHERS THEN
	                      RAISE FND_API.G_EXC_ERROR;
			END;

			IF l_lin_creation_date <= l_hdr_auth_date THEN
			   l_lin_cc_pmt_allowed := FALSE;
			ELSE
			   l_lin_cc_pmt_allowed := TRUE;
			END IF;
	             ELSE
			l_lin_cc_pmt_allowed := TRUE;
	             END IF;
		  EXCEPTION
		     WHEN NO_DATA_FOUND THEN
			l_lin_cc_pmt_allowed := TRUE;
	             WHEN OTHERS THEN
			l_lin_cc_pmt_allowed := FALSE;
		  END;
               ELSE
                  l_lin_cc_pmt_allowed := TRUE;
               END IF;

	       IF NOT l_lin_cc_pmt_allowed THEN
		   l_return_status := FND_API.G_RET_STS_ERROR;

		   IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN

		      FND_MESSAGE.SET_NAME('ONT','ONT_LIN_CC_NOT_ALLOWED');
		      oe_msg_pub.Add;

		   END IF;

                END IF;
              END IF; --operation is 'CREATE'
               --bug5176401 end

	       --R12 CC Encryption
	       --Bill to is required to create a credit
	       --card
	        Begin
			Select 	invoice_to_org_id
			Into	l_invoice_to_org_id
			From	oe_order_headers_all
			Where	header_id = p_line_payment_rec.header_id;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			Null;
		End;

		IF l_invoice_to_org_id IS NULL THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
	           	IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	          	THEN
	               		FND_MESSAGE.SET_NAME('ONT', 'OE_VPM_INV_TO_REQUIRED');
	              		oe_msg_pub.Add;
	         	END IF;
		END IF;
		--R12 CC Encryption
	END IF; --Trxn extension id is null
    ELSIF p_Line_Payment_rec.payment_type_code = 'CHECK' THEN

       IF  p_Line_Payment_rec.check_number IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CHECK_NUMBER');
               oe_msg_pub.Add;

           END IF;
       END IF;

    /* commment out for R12
    ELSIF p_Line_Payment_rec.payment_type_code in ('ACH', 'DIRECT_DEBIT') THEN

       IF  p_Line_Payment_rec.payment_trx_id IS NULL THEN
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

    IF nvl(p_Line_Payment_rec.payment_collection_event, 'INVOICE') = 'INVOICE' THEN

         -- Cannot have more than one 'Invoice' payment instrument
         SELECT count(payment_type_code)
         INTO l_count
         FROM oe_payments
         WHERE line_id = p_Line_Payment_rec.line_id
         AND   header_id = p_Line_Payment_rec.header_id
         AND   payment_level_code = 'LINE'
         AND   nvl(payment_number, -1) <> nvl(p_Line_Payment_rec.payment_number, -1)
         AND   nvl(payment_collection_event, 'INVOICE') = 'INVOICE'
         and   payment_type_code <> 'COMMITMENT'
         and   p_Line_Payment_rec.payment_type_code <> 'COMMITMENT';

         IF p_Line_Payment_rec.payment_type_code = 'COMMITMENT'
         THEN
            SELECT count(payment_type_code)
            into l_comt_count
            from oe_payments
            where line_id = p_Line_Payment_rec.line_id
            and header_id = p_Line_Payment_rec.header_id
            and payment_level_code = 'LINE'
            and nvl(payment_number, -1) <> nvl(p_Line_Payment_rec.payment_number, -1)
            and payment_type_code = 'COMMITMENT';
         END IF;

         IF l_count > 0 or l_comt_count > 0 THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','ONT_INVOICE_PAYMENT_INSTRUMENT');
               oe_msg_pub.Add;

           END IF;
         END IF;

        select count(payment_type_code) into l_prepay_count
        from oe_payments
        where (payment_collection_event = 'PREPAY'
        or prepaid_amount is not null )
        and header_id = p_Line_Payment_rec.header_id;

        select payment_term_id into l_term_id
        from oe_order_headers_all
        where header_id = p_Line_Payment_rec.header_id;

         if l_prepay_count = 0 then

           if l_term_id is not null then
               l_prepayment_flag := AR_PUBLIC_UTILS.Check_Prepay_Payment_Term(
                          l_term_id);
           end if;
         end if;

         if l_prepay_count > 0  and  nvl(p_Line_Payment_rec.payment_type_code, 'x') <> 'COMMITMENT' then
            oe_Debug_Pub.add('OEXLLPMB.pls: Prepayment exists at order level');

            l_return_status := FND_API.G_RET_STS_ERROR;

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
               fnd_message.set_name('ONT', 'ONT_LINE_INVOICE_NOT_SUPPORTED');
               oe_msg_pub.Add;
             END IF;

         end if;


    ELSIF p_Line_Payment_rec.payment_collection_event = 'PREPAY' THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
--  Prepayment instruments are not supported at line level
               FND_MESSAGE.SET_NAME('ONT','ONT_LINE_PREPAY_NOT_SUPPORTED');
               oe_msg_pub.Add;

           END IF;

    END IF;

    IF p_Line_Payment_rec.payment_type_code in ('ACH', 'DIRECT_DEBIT') THEN

     IF  p_Line_Payment_rec.receipt_method_id IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt Method');
               oe_msg_pub.Add;

           END IF;
     END IF;

    END IF; -- if payment_type_code in ACH, DIRECT_DEBIT, CREDIT_CARD

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

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Line_Payments.Entity',1);
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
,   p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
)
IS
    l_cc_security_code_use  VARCHAR2(20);  --R12 CVV2
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Line_Payments.Attributes',1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Payment attributes

    IF  p_Line_Payment_rec.created_by IS NOT NULL AND
        (   p_Line_Payment_rec.created_by <>
            p_old_Line_Payment_rec.created_by OR
            p_old_Line_Payment_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate.Created_By(p_Line_Payment_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.creation_date IS NOT NULL AND
        (   p_Line_Payment_rec.creation_date <>
            p_old_Line_Payment_rec.creation_date OR
            p_old_Line_Payment_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate.Creation_Date(p_Line_Payment_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.header_id IS NOT NULL AND
        (   p_Line_Payment_rec.header_id <>
            p_old_Line_Payment_rec.header_id OR
            p_old_Line_Payment_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate.Header(p_Line_Payment_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.last_updated_by IS NOT NULL AND
        (   p_Line_Payment_rec.last_updated_by <>
            p_old_Line_Payment_rec.last_updated_by OR
            p_old_Line_Payment_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate.Last_Updated_By(p_Line_Payment_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.last_update_date IS NOT NULL AND
        (   p_Line_Payment_rec.last_update_date <>
            p_old_Line_Payment_rec.last_update_date OR
            p_old_Line_Payment_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Date(p_Line_Payment_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.last_update_login IS NOT NULL AND
        (   p_Line_Payment_rec.last_update_login <>
            p_old_Line_Payment_rec.last_update_login OR
            p_old_Line_Payment_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate.Last_Update_Login(p_Line_Payment_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.line_id IS NOT NULL AND
        (   p_Line_Payment_rec.line_id <>
            p_old_Line_Payment_rec.line_id OR
            p_old_Line_Payment_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate.Line(p_Line_Payment_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.check_number IS NOT NULL AND
        (   p_Line_Payment_rec.check_number <>
            p_old_Line_Payment_rec.check_number OR
            p_old_Line_Payment_rec.check_number IS NULL )
    THEN
        IF NOT OE_Validate.check_number(p_Line_Payment_rec.check_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.credit_card_approval_code IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_approval_code <>
            p_old_Line_Payment_rec.credit_card_approval_code OR
            p_old_Line_Payment_rec.credit_card_approval_code IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_approval(p_Line_Payment_rec.credit_card_approval_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Line_Payment_rec.credit_card_approval_date IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_approval_date <>
            p_old_Line_Payment_rec.credit_card_approval_date OR
            p_old_Line_Payment_rec.credit_card_approval_date IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_approval_date(p_Line_Payment_rec.credit_card_approval_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.credit_card_code IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_code <>
            p_old_Line_Payment_rec.credit_card_code OR
            p_old_Line_Payment_rec.credit_card_code IS NULL )
    THEN
        IF NOT OE_Validate.credit_card(p_Line_Payment_rec.credit_card_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --R12 CVV2
    IF  p_Line_Payment_rec.credit_card_number IS NOT NULL AND p_Line_Payment_rec.credit_card_number <> FND_API.G_MISS_CHAR THEN --bug 4613168, issue 22
        l_cc_security_code_use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
        IF l_cc_security_code_use = 'REQUIRED' THEN
           IF p_Line_Payment_rec.instrument_security_code IS NULL OR
              p_Line_Payment_rec.instrument_security_code = FND_API.G_MISS_CHAR
           THEN
	      FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
              OE_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
    END IF;
    --R12 CVV2

    IF  p_Line_Payment_rec.credit_card_expiration_date IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_expiration_date <>
            p_old_Line_Payment_rec.credit_card_expiration_date OR
            p_old_Line_Payment_rec.credit_card_expiration_date IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_expiration_date(p_Line_Payment_rec.credit_card_expiration_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.credit_card_holder_name IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_holder_name <>
            p_old_Line_Payment_rec.credit_card_holder_name OR
            p_old_Line_Payment_rec.credit_card_holder_name IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_holder_name(p_Line_Payment_rec.credit_card_holder_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.credit_card_number IS NOT NULL AND
        (   p_Line_Payment_rec.credit_card_number <>
            p_old_Line_Payment_rec.credit_card_number OR
            p_old_Line_Payment_rec.credit_card_number IS NULL )
    THEN
        IF NOT OE_Validate.credit_card_number(p_Line_Payment_rec.credit_card_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_level_code IS NOT NULL AND
        (   p_Line_Payment_rec.payment_level_code <>
            p_old_Line_Payment_rec.payment_level_code OR
            p_old_Line_Payment_rec.payment_level_code IS NULL )
    THEN
        IF NOT OE_Validate.payment_level(p_Line_Payment_rec.payment_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.commitment_applied_amount IS NOT NULL AND
        (   p_Line_Payment_rec.commitment_applied_amount <>
            p_old_Line_Payment_rec.commitment_applied_amount OR
            p_old_Line_Payment_rec.commitment_applied_amount IS NULL )
    THEN
        IF NOT OE_Validate.commitment_applied_amount(p_Line_Payment_rec.commitment_applied_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.commitment_interfaced_amount IS NOT NULL AND
        (   p_Line_Payment_rec.commitment_interfaced_amount <>
            p_old_Line_Payment_rec.commitment_interfaced_amount OR
            p_old_Line_Payment_rec.commitment_interfaced_amount IS NULL )
    THEN
        IF NOT OE_Validate.commitment_interfaced_amount(p_Line_Payment_rec.commitment_interfaced_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_amount IS NOT NULL AND
        (   p_Line_Payment_rec.payment_amount <>
            p_old_Line_Payment_rec.payment_amount OR
            p_old_Line_Payment_rec.payment_amount IS NULL )
    THEN
        IF NOT OE_Validate.payment_amount(p_Line_Payment_rec.payment_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_collection_event IS NOT NULL AND
        (   p_Line_Payment_rec.payment_collection_event <>
            p_old_Line_Payment_rec.payment_collection_event OR
            p_old_Line_Payment_rec.payment_collection_event IS NULL )
    THEN
        IF NOT OE_Validate.payment_collection_event(p_Line_Payment_rec.payment_collection_event) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_trx_id IS NOT NULL AND
        (   p_Line_Payment_rec.payment_trx_id <>
            p_old_Line_Payment_rec.payment_trx_id OR
            p_old_Line_Payment_rec.payment_trx_id IS NULL )
    THEN
        IF NOT OE_Validate.payment_trx(p_Line_Payment_rec.payment_trx_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_type_code IS NOT NULL AND
        (   p_Line_Payment_rec.payment_type_code <>
            p_old_Line_Payment_rec.payment_type_code OR
            p_old_Line_Payment_rec.payment_type_code IS NULL )
    THEN
        IF NOT OE_Validate.payment_type(p_Line_Payment_rec.payment_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.payment_set_id IS NOT NULL AND
        (   p_Line_Payment_rec.payment_set_id <>
            p_old_Line_Payment_rec.payment_set_id OR
            p_old_Line_Payment_rec.payment_set_id IS NULL )
    THEN
        IF NOT OE_Validate.payment_set(p_Line_Payment_rec.payment_set_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.prepaid_amount IS NOT NULL AND
        (   p_Line_Payment_rec.prepaid_amount <>
            p_old_Line_Payment_rec.prepaid_amount OR
            p_old_Line_Payment_rec.prepaid_amount IS NULL )
    THEN
        IF NOT OE_Validate.prepaid_amount(p_Line_Payment_rec.prepaid_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.receipt_method_id IS NOT NULL AND
        (   p_Line_Payment_rec.receipt_method_id <>
            p_old_Line_Payment_rec.receipt_method_id OR
            p_old_Line_Payment_rec.receipt_method_id IS NULL )
    THEN
        IF NOT OE_Validate.receipt_method(p_Line_Payment_rec.receipt_method_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.tangible_id IS NOT NULL AND
        (   p_Line_Payment_rec.tangible_id <>
            p_old_Line_Payment_rec.tangible_id OR
            p_old_Line_Payment_rec.tangible_id IS NULL )
    THEN
        IF NOT OE_Validate.tangible(p_Line_Payment_rec.tangible_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Payment_rec.trxn_extension_id IS NOT NULL AND	--R12 Process order api changes
        (   p_Line_Payment_rec.trxn_extension_id <>
            p_old_Line_Payment_rec.trxn_extension_id OR
            p_old_Line_Payment_rec.trxn_extension_id IS NULL )
    THEN
        IF NOT OE_Validate.Payment_Trxn_Extension(p_Line_Payment_rec.trxn_extension_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;	--R12 Process order api changes
    if OE_GLOBALS.g_validate_desc_flex ='Y' then --bug 4343612
      oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Line_Payment.attributes ',1);
    IF  (p_Line_Payment_rec.attribute1 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute1 <>
            p_old_Line_Payment_rec.attribute1 OR
            p_old_Line_Payment_rec.attribute1 IS NULL ))
    OR  (p_Line_Payment_rec.attribute10 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute10 <>
            p_old_Line_Payment_rec.attribute10 OR
            p_old_Line_Payment_rec.attribute10 IS NULL ))
    OR  (p_Line_Payment_rec.attribute11 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute11 <>
            p_old_Line_Payment_rec.attribute11 OR
            p_old_Line_Payment_rec.attribute11 IS NULL ))
    OR  (p_Line_Payment_rec.attribute12 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute12 <>
            p_old_Line_Payment_rec.attribute12 OR
            p_old_Line_Payment_rec.attribute12 IS NULL ))
    OR  (p_Line_Payment_rec.attribute13 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute13 <>
            p_old_Line_Payment_rec.attribute13 OR
            p_old_Line_Payment_rec.attribute13 IS NULL ))
    OR  (p_Line_Payment_rec.attribute14 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute14 <>
            p_old_Line_Payment_rec.attribute14 OR
            p_old_Line_Payment_rec.attribute14 IS NULL ))
    OR  (p_Line_Payment_rec.attribute15 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute15 <>
            p_old_Line_Payment_rec.attribute15 OR
            p_old_Line_Payment_rec.attribute15 IS NULL ))
    OR  (p_Line_Payment_rec.attribute2 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute2 <>
            p_old_Line_Payment_rec.attribute2 OR
            p_old_Line_Payment_rec.attribute2 IS NULL ))
    OR  (p_Line_Payment_rec.attribute3 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute3 <>
            p_old_Line_Payment_rec.attribute3 OR
            p_old_Line_Payment_rec.attribute3 IS NULL ))
    OR  (p_Line_Payment_rec.attribute4 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute4 <>
            p_old_Line_Payment_rec.attribute4 OR
            p_old_Line_Payment_rec.attribute4 IS NULL ))
    OR  (p_Line_Payment_rec.attribute5 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute5 <>
            p_old_Line_Payment_rec.attribute5 OR
            p_old_Line_Payment_rec.attribute5 IS NULL ))
    OR  (p_Line_Payment_rec.attribute6 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute6 <>
            p_old_Line_Payment_rec.attribute6 OR
            p_old_Line_Payment_rec.attribute6 IS NULL ))
    OR  (p_Line_Payment_rec.attribute7 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute7 <>
            p_old_Line_Payment_rec.attribute7 OR
            p_old_Line_Payment_rec.attribute7 IS NULL ))
    OR  (p_Line_Payment_rec.attribute8 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute8 <>
            p_old_Line_Payment_rec.attribute8 OR
            p_old_Line_Payment_rec.attribute8 IS NULL ))
    OR  (p_Line_Payment_rec.attribute9 IS NOT NULL AND
        (   p_Line_Payment_rec.attribute9 <>
            p_old_Line_Payment_rec.attribute9 OR
            p_old_Line_Payment_rec.attribute9 IS NULL ))
    OR  (p_Line_Payment_rec.context IS NOT NULL AND
        (   p_Line_Payment_rec.context <>
            p_old_Line_Payment_rec.context OR
            p_old_Line_Payment_rec.context IS NULL ))
    THEN


         oe_debug_pub.add('Before calling Payments_Desc_Flex',2);
         IF NOT OE_VALIDATE.Payments_Desc_Flex
          (p_context            => p_Line_Payment_rec.context
          ,p_attribute1         => p_Line_Payment_rec.attribute1
          ,p_attribute2         => p_Line_Payment_rec.attribute2
          ,p_attribute3         => p_Line_Payment_rec.attribute3
          ,p_attribute4         => p_Line_Payment_rec.attribute4
          ,p_attribute5         => p_Line_Payment_rec.attribute5
          ,p_attribute6         => p_Line_Payment_rec.attribute6
          ,p_attribute7         => p_Line_Payment_rec.attribute7
          ,p_attribute8         => p_Line_Payment_rec.attribute8
          ,p_attribute9         => p_Line_Payment_rec.attribute9
          ,p_attribute10        => p_Line_Payment_rec.attribute10
          ,p_attribute11        => p_Line_Payment_rec.attribute11
          ,p_attribute12        => p_Line_Payment_rec.attribute12
          ,p_attribute13        => p_Line_Payment_rec.attribute13
          ,p_attribute14        => p_Line_Payment_rec.attribute14
          ,p_attribute15        => p_Line_Payment_rec.attribute15) THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

         oe_debug_pub.add('After Payments_Desc_Flex  ' || x_return_status,2);

    END IF;

    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Line_Payments.Attributes',1);
    --  Done validating attributes
    end if ; /*if OE_GLOBALS.g_validate_desc_flex ='Y' then bug 4343612*/
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
,   p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_Line_Payments.Entity_Delete',1);
    --  Validate entity delete.
    NULL;
    --  Done.

    x_return_status := l_return_status;
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_Line_Payments.Entity_Delete',1);

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

END OE_Validate_Line_Payment;

/

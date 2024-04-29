--------------------------------------------------------
--  DDL for Package Body OE_PAYMENT_TRXN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PAYMENT_TRXN_UTIL" AS
/*  $Header: OEXUPTXB.pls 120.28.12010000.13 2010/02/03 20:28:17 lagrawal ship $ */
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_PAYMENT_TRXN_UTIL';


--9092936 start
PROCEDURE Process_Credit_Card
(p_payer		IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type
 ,  p_credit_card		IN IBY_FNDCPT_SETUP_PUB.CreditCard_rec_Type
 ,  p_assignment_attribs   IN IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type
 ,  p_assign_id		OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,  p_response		OUT NOCOPY /* file.sql.39 change */ IBY_FNDCPT_COMMON_PUB.Result_rec_type
 ,   p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
 ,   p_msg_data         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 ,   p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

		IBY_FNDCPT_SETUP_PUB.Process_Credit_Card
		(
		 p_api_version		=> 1.0,
		 p_commit		=> FND_API.G_FALSE,
		 X_return_status	=> p_return_status,
		 X_msg_count		=> p_msg_count,
		 X_msg_data		=> p_msg_data,
		 P_payer		=> p_payer,
		 P_credit_card		=> p_credit_card,
		 P_assignment_attribs	=> p_assignment_attribs,
		 X_assign_id		=> p_assign_id,
		 X_response		=> p_response
		);

     IF p_return_status =FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Credit_Card'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
            );
END  Process_Credit_Card;
--9092936 end

Procedure Create_Payment_Trxn
(p_header_id		IN NUMBER,
P_line_id		IN NUMBER,
p_cust_id		IN NUMBER,
P_site_use_id		IN NUMBER,
P_payment_trx_id	IN NUMBER,
P_payment_type_code	IN VARCHAR2,
p_payment_number	IN NUMBER, --Newly added
P_card_number		IN VARCHAR2 DEFAULT NULL,
p_card_code		IN VARCHAR2 DEFAULT NULL,
P_card_holder_name	IN VARCHAR2 DEFAULT NULL,
P_exp_date		IN VARCHAR2 DEFAULT NULL,
P_instrument_security_code IN VARCHAR2 DEFAULT NULL,
P_credit_card_approval_code	IN VARCHAR2 DEFAULT NULL,
P_credit_card_approval_date	IN DATE DEFAULT NULL,
p_instrument_id		IN NUMBER DEFAULT NULL,
p_instrument_assignment_id IN NUMBER DEFAULT NULL,
p_receipt_method_id	IN NUMBER,
p_update_card_flag	IN VARCHAR2 DEFAULT 'N',
P_x_trxn_extension_id	IN OUT NOCOPY NUMBER,
X_return_status		OUT NOCOPY VARCHAR2,
X_msg_count		OUT NOCOPY NUMBER,
X_msg_data		OUT NOCOPY VARCHAR2)

IS
--R12 CC Encryption
L_credit_card_rec	IBY_FNDCPT_SETUP_PUB.CreditCard_rec_Type;
L_card_exists		VARCHAR2(1) := 'N';
L_return_status		VARCHAR2(30);
L_msg_count		NUMBER;
L_msg_data		VARCHAR2(2000);
L_party_id		NUMBER;
L_response_code		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_org_id		NUMBER;
l_org_type		VARCHAR2(80) := 'OPERATING_UNIT'; --Verify
L_card_id		NUMBER;
L_payer			IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
L_assignment_attribs	IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
L_instrument		IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
L_assign_id		NUMBER;
L_trxn_attribs		IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
L_pmt_channel_code	IBY_FNDCPT_PMT_CHNNLS_VL.payment_channel_code%TYPE;
l_instrument_type	IBY_FNDCPT_PMT_CHNNLS_VL.instrument_type%TYPE;
--l_instrument_id		IBY_FNDCPT_PAYER_ALL_INSTRS_V.instrument_id%TYPE;
l_trxn_extension_id     NUMBER;
l_invoice_to_org_id	OE_ORDER_LINES_ALL.invoice_to_org_id%TYPE;
l_err_message		VARCHAR2(4000);
l_instrument_security_code VARCHAR2(30);
l_cust_account_id	NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_party_site_id		NUMBER;
l_instrument_id		NUMBER; -- bug 5170754

BEGIN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('ENTERING OE_PAYMENT_TRXN_UTIL.Create_Payment_Trxn....');
		oe_debug_pub.add('Instrument security code and payment number.....'||p_instrument_security_code||' and '||p_payment_number);
		oe_debug_pub.add('Instrument id'||p_instrument_id);
		oe_debug_pub.add('Instrument assgn id'||p_instrument_assignment_id);
		oe_debug_pub.add('Trxn extension id'||P_x_trxn_extension_id);
	END IF;
	BEGIN

	-- map payment type to the payment channel
		IF p_payment_type_code IN( 'CREDIT_CARD') THEN
			L_pmt_channel_code := p_payment_type_code;
		ELSIF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
                       /*
			select arm.payment_channel_code
			into l_pmt_channel_code
			from ar_receipt_methods arm
			where arm.receipt_method_id = p_receipt_method_id;
                        */
                        l_pmt_channel_code := 'BANK_ACCT_XFER';
		END IF;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('ksurendr payment channel code '||l_pmt_channel_code);
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Error in getting payment channel code'||l_pmt_channel_code);
				oe_debug_pub.add('Return status'||l_return_status||l_msg_data);
				RAISE;
			END IF;
	END;

	-- BEGIN
		IF p_line_id is not null then
			Select INVOICE_TO_ORG_ID,ORG_ID into l_invoice_to_org_id,l_org_id
			from oe_order_lines_all where header_id = p_header_id
			and line_id = p_line_id;
		ELSE
                        /*
			select invoice_to_org_id,org_id into l_invoice_to_org_id,l_org_id
			from oe_order_headers_all where header_id = p_header_id;
                        */
                        -- get cached value.
                        oe_order_cache.load_order_header(p_header_id);
                        l_invoice_to_org_id := OE_Order_Cache.g_header_rec.invoice_to_org_id;
                        l_org_id := OE_Order_Cache.g_header_rec.org_id;
		END IF;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Invoice_to_org_id'||l_invoice_to_org_id);
			oe_debug_pub.add('org id'||l_org_id);
		END IF;
        /*
	EXCEPTION
		WHEN OTHERS THEN
			l_err_message := SQLERRM;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Error in getting org id'||l_err_message);
			oe_debug_pub.add('Invoice to org id'||l_invoice_to_org_id);
			oe_debug_pub.add('Org id'||l_org_id);
			RAISE;
		END IF;
	END;
        */

	BEGIN
		Select	hca.party_id, acct_site.cust_account_id,acct_site.party_site_id
		Into 	l_party_id, l_cust_account_id,l_party_site_id
		From 	HZ_CUST_SITE_USES_ALL 	SITE,
			HZ_CUST_ACCT_SITES      ACCT_SITE,
                        HZ_CUST_ACCOUNTS_ALL    HCA
		Where 	SITE.SITE_USE_ID = p_site_use_id
		AND	SITE.SITE_USE_CODE  = 'BILL_TO'
		AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
		AND   	ACCT_SITE.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
		AND  	 SITE.ORG_ID = ACCT_SITE.ORG_ID;

		 IF l_debug_level > 0 THEN
			oe_debug_pub.add('Party id in Create payment trxn'||l_party_id);
		 END IF;

		 l_payer.payment_function :=  'CUSTOMER_PAYMENT';
		 l_payer.party_id	 := l_party_id;
		 l_payer.org_type	 := l_org_type;
		 l_payer.org_id		:= l_org_id;
		 l_payer.cust_account_id	:= l_cust_account_id;
		 l_payer.account_site_id	:= p_site_use_id;
		 IF l_debug_level > 0 THEN
			oe_debug_pub.add('Cust id and acct site id'||p_cust_id||'and'||p_site_use_id);
			oe_debug_pub.add('Payer context values');
			oe_debug_pub.add('Payment function --- CUSTOMER_PAYMENT');
			oe_debug_pub.add('PARTY ID'||l_party_id);
			oe_debug_pub.add('org_id'||l_org_id);
			oe_debug_pub.add('org type'||l_org_type);
			oe_debug_pub.add('cust acct id'||l_cust_account_id);
			oe_debug_pub.add('account site id'||p_site_use_id);
		 END IF;

	EXCEPTION
		WHEN OTHERS THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Error in PARTY ID'||l_party_id);
			oe_debug_pub.add('Invoice to org id'||l_invoice_to_org_id);
			oe_debug_pub.add('Org id'||l_org_id);
			oe_debug_pub.add('payment_number'||p_payment_number);
			oe_debug_pub.add('Return status'||l_return_status||l_msg_data);
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END;

	--Getting the instrument type based on
	--payment channel code
	SELECT ifapc.instrument_type
	INTO    l_instrument_type
	FROM iby_fndcpt_all_pmt_channels_v ifapc
	WHERE ifapc.payment_channel_code = l_pmt_channel_code;

	--if p_x_trxn_extension_id is null, then create a new id using the IN data.
	--If it is not null, then we first get the instrument assignment id for
	--the p_x_trxn_extension_id and use this assignment id to create a new
	--trxn_extension_id, this is used for Copy Order
	IF p_x_trxn_extension_id IS NULL THEN
		-- get the l_trxn_attribs information
		l_instrument.instrument_id := p_instrument_id;
		l_instrument.instrument_type := l_instrument_type;
		l_assignment_attribs.instrument := l_instrument;

		IF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN

			--bug 5170754
			/*IF p_payment_trx_id IS NOT NULL THEN
				L_assign_id := p_payment_trx_id;
			ELSE*/

			--Since the ACH LOV shows the bank account numbers belonging
			--to different assignments (bill to), always calling the
			--set_payer_assignment API of payments to get the assignment
			--id even though the assignment id is passed from the front end.

			IF p_payment_trx_id IS NOT NULL THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Assignment id for ach / direct debit --> '||p_payment_trx_id);
				END IF;

				SELECT INSTRUMENT_ID into
				l_instrument_id from
				IBY_FNDCPT_PAYER_ASSGN_INSTR_V
				where INSTR_ASSIGNMENT_ID = p_payment_trx_id;

				l_assignment_attribs.instrument.instrument_id := l_instrument_id;
			END IF;

			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Before call to Set payer instr assignment API...');
				oe_debug_pub.add('Assignment attributes passed ');
				oe_debug_pub.add('l_instrument.instrument_id ---> '||p_instrument_id);
				oe_debug_pub.add('l_instrument.instrument_type -> '||l_instrument_type);
			END IF;

			IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment
			(p_api_version		=> 1.0,
			 p_commit		=> FND_API.G_FALSE,
			 X_return_status	=> l_return_status,
			 X_msg_count		=> l_msg_count,
			 X_msg_data		=> l_msg_data,
			 P_payer		=> l_payer,
			 P_assignment_attribs	=> l_assignment_attribs,
			 X_assign_id		=> l_assign_id,
			 X_response		=> l_response_code);

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Set Payer instr assignment Successful....');
					oe_debug_pub.add('After calling Set_Payer_Instr_Assignment');
					oe_debug_pub.add('Instr assignment id'||l_assign_id);
				END IF;
			END IF;
			--END IF; bug 5170754
		ELSIF p_payment_type_code = 'CREDIT_CARD' THEN

			IF p_update_card_flag = 'Y' AND p_instrument_id is not null THEN
				L_credit_card_rec.expiration_date := p_exp_date;
				l_credit_card_rec.Card_Holder_Name := p_card_holder_name;
				l_credit_Card_rec.card_id := p_instrument_id;
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Before call to Update_Card API....');
					--oe_debug_pub.add('Expiration date --> '||p_exp_date);
					--oe_debug_pub.add('Holder Name ------> '||p_card_holder_name);
					oe_debug_pub.add('Instrument id ----> '||p_instrument_id);
				END IF;
				  IBY_FNDCPT_SETUP_PUB.Update_Card
				  (
				    p_api_version       => 1.0,
				    p_init_msg_list     => FND_API.G_TRUE,
				    p_commit            => FND_API.G_FALSE,
				    x_return_status     => l_return_status,
				    X_msg_count		=> l_msg_count,
				    X_msg_data		=> l_msg_data,
				    p_card_instrument   => l_credit_card_rec,
				    x_response          => l_response_code
				  );
				--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);
				IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Update_Card exp'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Update_Card unxc'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Update_Card Successful....');
						oe_debug_pub.add('Return status '||l_return_status);
					END IF;
				END IF;
			END IF;

			IF p_instrument_assignment_id IS NOT NULL THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Before call to Set payer instr assignment API...');
					oe_debug_pub.add('Assignment attributes passed ');
					oe_debug_pub.add('l_instrument.instrument_id ---> '||p_instrument_id);
					oe_debug_pub.add('l_instrument.instrument_type -> '||l_instrument_type);
				END IF;

				IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment
				(p_api_version		=> 1.0,
				 p_commit		=> FND_API.G_FALSE,
				 X_return_status	=> l_return_status,
				 X_msg_count		=> l_msg_count,
				 X_msg_data		=> l_msg_data,
				 P_payer		=> l_payer,
				 P_assignment_attribs	=> l_assignment_attribs,
				 X_assign_id		=> l_assign_id,
				 X_response		=> l_response_code);

				IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Set Payer instr assignment Successful....');
						oe_debug_pub.add('After calling Set_Payer_Instr_Assignment');
						oe_debug_pub.add('Instr assignment id'||l_assign_id);
					END IF;
				END IF;
				--l_assign_id := p_instrument_assignment_id;
			ELSE
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Values of credit card passed to process_credit_card');
					oe_debug_pub.add('Owner id'||l_party_id);
					oe_debug_pub.add('site use id /invoice to org id'||p_site_use_id);
					oe_debug_pub.add('l_party_site_id/stmt billing address id'||l_party_site_id);
					--oe_debug_pub.add('card number'||p_card_number);
					--oe_debug_pub.add('expiration date'||p_exp_date);
					oe_debug_pub.add('instrument_type'||l_instrument_type);
					--oe_debug_pub.add('Card issuer'||p_card_code);
					oe_debug_pub.add('Instrument id'||l_assignment_attribs.instrument.instrument_id);
					oe_debug_pub.add('call to process credit card');
				END IF;

				L_credit_card_rec.owner_id := l_party_id;
				L_credit_card_rec.billing_address_id := l_party_site_id;
				L_credit_card_rec.card_number := p_card_number;
				L_credit_card_rec.expiration_date := p_exp_date;
				L_credit_card_rec.instrument_type := l_instrument_type;
				L_credit_card_rec.Card_Issuer := p_card_code;
				l_credit_card_rec.Card_Holder_Name := p_card_holder_name;
				--bug 5176015
				IF L_credit_card_rec.card_number IS NOT NULL THEN
        /*9092936 start
					IBY_FNDCPT_SETUP_PUB.Process_Credit_Card
					(
					 p_api_version		=> 1.0,
					 p_commit		=> FND_API.G_FALSE,
					 X_return_status	=> l_return_status,
					 X_msg_count		=> l_msg_count,
					 X_msg_data		=> l_msg_data,
					 P_payer		=> l_payer,
					 P_credit_card		=> l_credit_card_rec,
					 P_assignment_attribs	=> l_assignment_attribs,
					 X_assign_id		=> l_assign_id,
					 X_response		=> l_response_code
					);
          9092936 end*/
          --9092936 start
		        Process_Credit_Card
		        		(
		        		 P_payer		=> l_payer,
		 		        P_credit_card		=> l_credit_card_rec,
		 		        P_assignment_attribs	=> l_assignment_attribs,
		 		        p_assign_id		=> l_assign_id,
		 		        p_response		=> l_response_code,
		        		 p_msg_count            => l_msg_count,
 		 		        p_msg_data             => l_msg_data,
		         		 p_return_status        => l_return_status
				        );
          --9092936 end

					--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

					IF l_return_status = FND_API.G_RET_STS_ERROR THEN
						IF l_debug_level > 0 THEN
							oe_debug_pub.add('Result error code in Process_Credit_Card -->'||l_response_code.result_code);
						END IF;
						IF l_response_code.result_code = 'INVALID_CARD_NUMBER' THEN
							FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
							OE_MSG_PUB.ADD;
							IF l_debug_level  > 0 THEN
							    oe_debug_pub.add(  'OEXUPTXB: Invalid card number or expiration date' ) ;
							END IF;
						ELSIF l_response_code.result_code = 'INVALID_ADDRESS' THEN
							FND_MESSAGE.SET_NAME('ONT','OE_CC_BILL_TO_ADDRESS_INVALID');
							OE_MSG_PUB.ADD;
							IF l_debug_level  > 0 THEN
							    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
							END IF;
						ELSIF l_response_code.result_code = 'INVALID_CARD_ISSUER' THEN
							FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET'); --bug 5012613
							OE_MSG_PUB.ADD;
							IF l_debug_level  > 0 THEN
							    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
							END IF;
						ELSE --Setting a generic message bug 5244099
							FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
							OE_MSG_PUB.ADD;
							IF l_debug_level  > 0 THEN
							    oe_debug_pub.add(  'OEXUPTXB: Setting the generic message' ) ;
							END IF;
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET'); --bug 5244099
						OE_MSG_PUB.ADD;
						IF l_debug_level > 0 THEN
							oe_debug_pub.add('Unexpected result error code in Process_Credit_Card-->'||l_response_code.result_code);
						END IF;
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
						IF l_debug_level > 0 THEN
							oe_debug_pub.add('Process_Credit_Card assignment Successful....');
							oe_debug_pub.add('After calling Process_Credit_Card');
							oe_debug_pub.add('Instr assignment id'||l_assign_id);
						END IF;
						--If trxn extension id is null and approval code is not, then
						--this approval code was obtained from outside payments system
						--and we need to set up voice authorization in this case.
						IF p_credit_card_approval_code IS NOT NULL THEN
							L_trxn_attribs.VoiceAuth_flag := 'Y';
							L_trxn_attribs.VoiceAuth_code := p_credit_card_approval_code;
							L_trxn_attribs.VoiceAuth_date := p_credit_card_approval_date;
						END IF;
					END IF; -- return status
				END IF;
				--bug 5176015
			END IF; -- assignment id not null
		END IF;
		--No need to create trxn extension id for check payments
		L_trxn_attribs.order_id := p_header_id;
		l_trxn_attribs.trxn_ref_number2 := p_payment_number;

		-- store the line id in trx_ref_number1 if this is a line level payment
		IF p_line_id IS NOT NULL THEN
			l_trxn_attribs.trxn_ref_number1 := p_line_id;
		END IF;

	ELSE
	-- p_x_trxn_extension_id is not null, then find the instrument assignment id first,
	-- then create a new trxn transaction id using this assignment id. This is used in Copy Order.
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before call to Get Transaction Extension API...');
			oe_debug_pub.add('Trxn attributes passed ');
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 ---> '||p_line_id);
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 ---> '||p_payment_number);
			oe_debug_pub.add('L_trxn_attribs.order_id -----------> '||p_header_id);
		END IF;
		IBY_FNDCPT_TRXN_PUB.Get_Transaction_Extension
			(p_api_version		=> 1.0,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data,
			P_entity_id		=> p_x_trxn_extension_id,
			P_payer			=> l_payer,
			X_trxn_attribs		=> l_trxn_attribs,
			--x_authorized		=> l_authorized,
			--x_settled		=> l_settled,
			X_response		=> l_response_code);
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Get_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Get_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Get_Transaction_Extension assignment Successful....');
				oe_debug_pub.add('After call to Get Transaction Extension'||l_return_status);
				oe_debug_pub.add('After call to get trxn...instr sec code'||l_trxn_attribs.instrument_security_code);
			END IF;
		END IF;

	-- Based on the trxn extension id get the corresponding
	-- assignment id from the payments table
	  -- bug 8586227
		select instr_assignment_id into l_assign_id
		from IBY_EXTN_INSTR_DETAILS_V where trxn_extension_id = p_x_trxn_extension_id;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Instrument assignment id for existing instrument'||l_assign_id);
		END IF;

	END IF;

	--<populate data to l_trxn_attribs from l_assignment_attribs, l_credit_card_rec if it is a  credit card>

	--Oracle payments requires that the combination of order_id, trxn_ref_number1 and trxn_ref_number2
	--in the record type l_trxn_attribs must provide a unique transaction identifier for the application


	IF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
		l_trxn_attribs.Originating_Application_Id := 660;
	ELSIF p_payment_type_code = 'CREDIT_CARD' THEN
		l_trxn_attribs.Originating_Application_Id := 660;
		--For copy order call, the instrument security code is obtained from
		--the original order by the call to Get_Transaction_Extension
		IF p_x_trxn_extension_id is null then
			l_trxn_attribs.Instrument_Security_Code := p_instrument_security_code;
                ELSE
                        l_trxn_attribs.Instrument_Security_Code := NULL; --bug 5190146
		END IF;

	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Before calling create_transaction extension');
		oe_debug_pub.add('payment channel -->'||l_pmt_channel_code);
		oe_debug_pub.add('Assignment id ---->'|| l_assign_id);
		oe_debug_pub.add('trxn attributes record type values');
		oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||p_instrument_security_code);
		oe_debug_pub.add('l_trxn_attribs.Originating application id ---> 660');
		oe_debug_pub.add('l_trxn_attribs.order_id ----> '||p_header_id);
		oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||p_line_id);
		oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||p_payment_number);
		--oe_debug_pub.add('l_trxn_attribs.VoiceAuth_date ---->'||p_credit_card_approval_date);
		--oe_debug_pub.add('l_trxn_attribs.VoiceAuth_code ---->'||p_credit_card_approval_code);
	END IF;
	--bug 5176015
	IF l_assign_id IS NOT NULL THEN

          -- bug 5575513, regarding authorization for copied order.
          l_trxn_attribs.order_id := p_header_id;
          l_trxn_attribs.trxn_ref_number1 := p_line_id;

          IF l_debug_level > 0 THEN
            oe_debug_pub.add('new l_trxn_attribs.order_id -----> '||l_trxn_attribs.order_id);
          END IF;

		IBY_Fndcpt_Trxn_Pub.Create_Transaction_Extension
				(p_api_version		=> 1.0,
				p_init_msg_list		=> FND_API.G_TRUE,
				p_commit		=> FND_API.G_FALSE,
				X_return_status		=> l_return_status,
				X_msg_count		=> l_msg_count,
				X_msg_data		=> l_msg_data,
				P_payer			=> l_payer,
				P_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
				P_pmt_channel		=> l_pmt_channel_code,
				P_instr_assignment	=> l_assign_id,
				P_trxn_attribs		=> l_trxn_attribs,
				x_entity_id		=> l_trxn_extension_id,
				X_response		=> l_response_code);

		--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('After calling Create_Transaction_Extension'||l_trxn_extension_id);
			oe_debug_pub.add('Result code'||l_Response_code.result_code);
			oe_debug_pub.add('Return status'||l_Return_Status);
		END IF;

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Create_Transaction_Extension assignment Successful....');
				oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
				oe_debug_pub.add('After call to create Transaction Extension');
				oe_debug_pub.add('New trxn extension id'||l_trxn_extension_id);
				oe_debug_pub.add('Return status'||l_return_status);
			END IF;

                        -- bug 5204275
                        IF p_payment_type_code = 'CREDIT_CARD'
                        AND p_x_trxn_extension_id IS NULL
                        AND p_line_id IS NOT NULL
                        THEN
                          UPDATE oe_payments
                          SET    credit_card_approval_code = NULL
                          WHERE  header_id = p_header_id
                          AND    line_id = p_line_id;
                        END IF;

		END IF;
	END IF;
	--bug 5176015
	P_x_trxn_extension_id := l_trxn_extension_id;
	X_return_status := FND_API.G_RET_STS_SUCCESS;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Exiting Create_Payment_Trxn.....');
	END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Transaction_Extension assignment error....exc');
		oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Transaction_Extension assignment error....unxc');
		oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('f Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Transaction_Extension assignment error....others');
		oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('trx Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_PAYMENT_TRXN_UTIL'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Payment_Trxn;

Procedure Update_Payment_Trxn
(p_header_id		IN NUMBER,
P_line_id		IN NUMBER,
p_cust_id		IN NUMBER,
P_site_use_id		IN NUMBER,
p_payment_trx_id	IN NUMBER,
p_payment_type_code	IN VARCHAR2,
p_payment_number	IN NUMBER, --New
p_card_number		IN VARCHAR2,
P_card_code	IN VARCHAR2,
p_card_holder_name	IN VARCHAR2,
p_exp_date		IN DATE,
p_instrument_security_code IN VARCHAR2,
--Bug 7460481 starts
P_credit_card_approval_code	IN VARCHAR2 DEFAULT NULL,
P_credit_card_approval_date	IN DATE DEFAULT NULL,
--Bug 7460481 ends
p_instrument_id		IN NUMBER DEFAULT NULL,
p_instrument_assignment_id IN NUMBER DEFAULT NULL,
p_receipt_method_id	IN NUMBER,
p_update_card_flag	IN VARCHAR2 DEFAULT 'N',
p_trxn_extension_id	IN OUT NOCOPY NUMBER, --bug 4885313
X_return_status		OUT NOCOPY  VARCHAR2,
X_msg_count		OUT NOCOPY NUMBER,
X_msg_data		OUT NOCOPY VARCHAR2)

IS
--R12 CC Encryption
L_return_status		VARCHAR2(30);
L_msg_count		NUMBER;
L_msg_data		VARCHAR2(2000);
L_party_id		NUMBER;
p_card_type		VARCHAR2(80);
L_response_code		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
L_payer			IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
L_trxn_attribs		IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_org_id		NUMBER;
l_org_type		VARCHAR2(80) := 'OPERATING_UNIT';
l_instrument_type	IBY_FNDCPT_PMT_CHNNLS_VL.instrument_type%TYPE;
l_instrument_id		IBY_FNDCPT_PAYER_ALL_INSTRS_V.instrument_id%TYPE := p_instrument_id;
l_instrument_assignment_id IBY_FNDCPT_PAYER_ASSGN_INSTR_V.instr_assignment_id%TYPE := p_instrument_assignment_id;
L_credit_card_rec	IBY_FNDCPT_SETUP_PUB.CreditCard_rec_Type;
L_assignment_attribs	IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
L_instrument		IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
L_assign_id		NUMBER;
l_invoice_to_org_id	OE_ORDER_LINES_ALL.invoice_to_org_id%TYPE;
L_pmt_channel_code	IBY_FNDCPT_PMT_CHNNLS_VL.payment_channel_code%TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_payment_number	NUMBER;
l_cust_account_id	NUMBER; --New
l_party_site_id     NUMBER;
--Bug 4885313
l_trxn_extension_id	NUMBER;

--bug 5028932
l_approval_code			VARCHAR2(80);
l_settled_flag			VARCHAR2(1);
l_effective_auth_amount NUMBER;
l_reauthorize_flag VARCHAR2(1);

--bug 5299050
l_old_instrument_id NUMBER;
l_old_card_number   VARCHAR2(80);

l_pos                   NUMBER := 0;
l_retry_num             NUMBER := 0;
l_trxn_ref_number2      NUMBER;

BEGIN


	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering OE_PAYMENT_TRXN_UTIL.Update_Payment_Trxn...');
	END IF;

	IF p_payment_type_code IN( 'CREDIT_CARD') THEN
		L_pmt_channel_code := p_payment_type_code;
	ELSIF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
               /*
		select arm.payment_channel_code
		into l_pmt_channel_code
		from ar_receipt_methods arm
		where arm.receipt_method_id = p_receipt_method_id;
                */

                l_pmt_channel_code := 'BANK_ACCT_XFER';
	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Payment channel code returned --->'||l_pmt_channel_code);
	END IF;

	--Getting the instrument type based on
	--payment channel code
	SELECT ifapc.instrument_type
	INTO    l_instrument_type
	FROM iby_fndcpt_all_pmt_channels_v ifapc
	WHERE ifapc.payment_channel_code = l_pmt_channel_code;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Instrument type and instrument id'||l_instrument_type||' and '||l_instrument_id);
	END IF;

	--Get party id for the bill to site Verify

	IF p_line_id is not null then
		Select INVOICE_TO_ORG_ID,ORG_ID into l_invoice_to_org_id,l_org_id
		from oe_order_lines_all where header_id = p_header_id and line_id = p_line_id;
	else
                /*
		select invoice_to_org_id,org_id into l_invoice_to_org_id,l_org_id
		from oe_order_headers_all where header_id = p_header_id;
                */

                oe_order_cache.load_order_header(p_header_id);
                l_invoice_to_org_id := OE_Order_Cache.g_header_rec.invoice_to_org_id;
                l_org_id := OE_Order_Cache.g_header_rec.org_id;
	end if;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('INVOICE_TO_ORG_ID and ORG_ID'||l_invoice_to_org_id||' and '||l_org_id);
	END IF;

Begin
		Select	hca.party_id, acct_site.cust_account_id,acct_site.party_site_id
		Into 	l_party_id, l_cust_account_id,l_party_site_id
		From 	HZ_CUST_SITE_USES_ALL SITE,
			HZ_CUST_ACCT_SITES    ACCT_SITE,
                        HZ_CUST_ACCOUNTS_ALL  HCA
		Where 	SITE.SITE_USE_ID = p_site_use_id
		AND	SITE.SITE_USE_CODE  = 'BILL_TO'
		AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
		AND   	ACCT_SITE.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
		AND  	 SITE.ORG_ID = ACCT_SITE.ORG_ID;

Exception
When No_Data_Found THEN
	Null;
End;

 IF l_debug_level > 0 THEN
	oe_debug_pub.add('Party id retrieved from hz tables-->'||l_party_id);
	oe_debug_pub.add('Payment trxid..'||p_payment_trx_id);
 END IF;


l_payer.payment_function := 'CUSTOMER_PAYMENT';
l_payer.party_id	 := l_party_id;
l_payer.org_type	 := l_org_type;
l_payer.org_id		 := l_org_id;
l_payer.cust_account_id	 := l_cust_account_id;
l_payer.account_site_id	 := p_site_use_id;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Payer context values');
	oe_debug_pub.add('Payment function --- CUSTOMER_PAYMENT');
	oe_debug_pub.add('PARTY ID'||l_party_id);
	oe_debug_pub.add('org_id'||l_org_id);
	oe_debug_pub.add('org type'||l_org_type);
	oe_debug_pub.add('cust acct id'||l_cust_account_id);
	oe_debug_pub.add('account site id'||p_site_use_id);
END IF;

	IF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
		--bug 5170754
		/*IF p_payment_trx_id IS NOT NULL THEN
			L_assign_id := p_payment_trx_id;
		ELSE*/

		--Since the ACH LOV shows the bank account numbers belonging
		--to different assignments (bill to), always calling the
		--set_payer_assignment API of payments to get the assignment
		--id even though the assignment id is passed from the front end.
		IF p_payment_trx_id IS NOT NULL THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Assignment id for ach / direct debit --> '||p_payment_trx_id);
			END IF;

			SELECT INSTRUMENT_ID into
			l_instrument_id from
			IBY_FNDCPT_PAYER_ASSGN_INSTR_V
			where INSTR_ASSIGNMENT_ID = p_payment_trx_id;
		END IF;


		l_instrument.instrument_id := l_instrument_id;
		l_instrument.instrument_type := l_instrument_type;
		l_assignment_attribs.instrument := l_instrument;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before call to Set payer instr assignment API...');
			oe_debug_pub.add('Assignment attributes passed ');
			oe_debug_pub.add('l_instrument.instrument_id ---> '||l_instrument_id);
			oe_debug_pub.add('l_instrument.instrument_type -> '||l_instrument_type);
		END IF;

	--<p_payment_trx_id stores the instr_assignment_id, if not null, then no need to call this API>
		IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment
			(p_api_version		=> 1.0,
			p_commit		=> FND_API.G_FALSE,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data,
			P_payer			=> l_payer,
			P_assignment_attribs	=> l_assignment_attribs,
			X_assign_id		=> l_assign_id,
			X_response		=> l_response_code);

		--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Set_Payer_Instr_Assignment'||l_response_code.result_code);
			END IF;
			IF l_response_code.result_code = 'INVALID_CARD_NUMBER' THEN
				FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
				OE_MSG_PUB.ADD;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OEXUPTXB: Invalid card number or expiration date' ) ;
				END IF;
			ELSIF l_response_code.result_code = 'INVALID_ADDRESS' THEN
				FND_MESSAGE.SET_NAME('ONT','OE_CC_BILL_TO_ADDRESS_INVALID');
				OE_MSG_PUB.ADD;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
				END IF;
			ELSIF l_response_code.result_code = 'INVALID_CARD_ISSUER' THEN
				FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET'); --bug 5012613
				OE_MSG_PUB.ADD;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
				END IF;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Set_Payer_Instr_Assignment'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Set_Payer_Instr_Assignment assignment Successful....');
				oe_debug_pub.add('After calling Set_Payer_Instr_Assignment');
				oe_debug_pub.add('Instr assignment id'||l_assign_id);
			END IF;
		END IF;

		--END IF; --bug 5170754
	ELSIF p_payment_type_code = 'CREDIT_CARD' THEN

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('l_inst id'||l_instrument_id);
			oe_debug_pub.add('Instr assignment id'||l_instrument_assignment_id);
			--oe_debug_pub.add('X value'||instr(p_card_number,'X'));
		END IF;

		IF p_update_card_flag = 'Y' AND l_instrument_id is not null THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Before calling update_card..');
				--oe_debug_pub.add('Expiration date passed...'||p_exp_date);
				--oe_debug_pub.add('Holder name'||p_card_holder_name);
				oe_debug_pub.add('Instrument id'||l_instrument_id);
			END IF;
			L_credit_card_rec.expiration_date := p_exp_date;
			l_credit_card_rec.Card_Holder_Name := p_card_holder_name;
			l_credit_Card_rec.card_id := l_instrument_id;
			  IBY_FNDCPT_SETUP_PUB.Update_Card
			  (
			    p_api_version       => 1.0,
			    p_init_msg_list     => FND_API.G_TRUE,
			    p_commit            => FND_API.G_FALSE,
			    x_return_status     => l_return_status,
			    X_msg_count		=> l_msg_count,
			    X_msg_data		=> l_msg_data,
			    p_card_instrument   => l_credit_card_rec,
			    x_response          => l_response_code
			  );
			--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Update_Card exp'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Update_Card unxc'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Update_Card Successful....');
					oe_debug_pub.add('Return status '||l_return_status);
				END IF;
			END IF; --return status
		END IF; --update card flag

		IF l_instrument_assignment_id IS NOT NULL THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Before call to Set payer instr assignment API...');
				oe_debug_pub.add('Assignment attributes passed ');
				oe_debug_pub.add('l_instrument.instrument_id ---> '||l_instrument_id);
				oe_debug_pub.add('l_instrument.instrument_type -> '||l_instrument_type);
			END IF;
			l_instrument.instrument_id := l_instrument_id;
			l_instrument.instrument_type := l_instrument_type;
			l_assignment_attribs.instrument := l_instrument;

			IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment
			(p_api_version		=> 1.0,
			 p_commit		=> FND_API.G_FALSE,
			 X_return_status	=> l_return_status,
			 X_msg_count		=> l_msg_count,
			 X_msg_data		=> l_msg_data,
			 P_payer		=> l_payer,
			 P_assignment_attribs	=> l_assignment_attribs,
			 X_assign_id		=> l_assign_id,
			 X_response		=> l_response_code);

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in set payer instr assignment'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Set Payer instr assignment Successful....');
					oe_debug_pub.add('After calling Set_Payer_Instr_Assignment');
					oe_debug_pub.add('Instr assignment id'||l_assign_id);
				END IF;
			END IF;
		ELSE
			L_credit_card_rec.owner_id := l_party_id;
			L_credit_card_rec.billing_address_id := l_party_site_id;
			L_credit_card_rec.card_number := p_card_number;
			L_credit_card_rec.expiration_date := p_exp_date;
			l_credit_card_rec.Card_Holder_Name := p_card_holder_name;
			L_credit_card_rec.card_issuer	:= p_card_code;
			L_credit_card_rec.instrument_type := l_instrument_type;

			 IF l_debug_level > 0 THEN
				oe_debug_pub.add('Before calling process credit card....');
				oe_debug_pub.add('l_party_site_id/stmt billing add'||l_party_site_id);
				oe_debug_pub.add('site use id/invoice to org'||p_site_use_id);
				--oe_debug_pub.add('card number'||p_card_number);
				--oe_debug_pub.add('expiration date'||p_exp_date);
				--oe_debug_pub.add('instrument_type'||l_instrument_type);
				--oe_debug_pub.add('Card issuer'||p_card_code);
				oe_debug_pub.add('Instrument id'||l_instrument_id);
				--oe_debug_pub.add('Holder name'||p_card_holder_name);
				oe_debug_pub.add('call to process credit card');
			 END IF;

/*9092936 start
			IBY_FNDCPT_SETUP_PUB.Process_Credit_Card
			(p_api_version		=> 1.0,
			p_commit		=> FND_API.G_FALSE,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data,
			P_payer			=> l_payer,
			P_credit_card		=> l_credit_card_rec,
			P_assignment_attribs	=> l_assignment_attribs,
			X_assign_id		=> l_assign_id,
			X_response		=> l_response_code);
9092936 end*/
--9092936  start
		        Process_Credit_Card
		        		(
		        		 P_payer		=> l_payer,
		 		         P_credit_card		=> l_credit_card_rec,
		 		         P_assignment_attribs	=> l_assignment_attribs,
		 		         p_assign_id		=> l_assign_id,
		 		         p_response		=> l_response_code,
		        		 p_msg_count            => l_msg_count,
 		 		         p_msg_data             => l_msg_data,
		         		 p_return_status        => l_return_status
				        );
--9092936  end

			--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

			 IF l_debug_level > 0 THEN
				oe_debug_pub.add('After call to process credit card....');
			 END IF;


			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Process_Credit_Card -->'||l_response_code.result_code);
				END IF;
				IF l_response_code.result_code = 'INVALID_CARD_NUMBER' THEN
					FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
					OE_MSG_PUB.ADD;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'OEXUPTXB: Invalid card number or expiration date' ) ;
					END IF;
				ELSIF l_response_code.result_code = 'INVALID_ADDRESS' THEN
					FND_MESSAGE.SET_NAME('ONT','OE_CC_BILL_TO_ADDRESS_INVALID');
					OE_MSG_PUB.ADD;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
					END IF;
				ELSIF l_response_code.result_code = 'INVALID_CARD_ISSUER' THEN
					FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET'); --bug 5012613
					OE_MSG_PUB.ADD;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'OEXUPTXB: Invalid billing address' ) ;
					END IF;
				ELSE --Setting a generic message bug 5244099
					FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
					OE_MSG_PUB.ADD;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'OEXUPTXB: Setting the generic message' ) ;
					END IF;
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET'); --bug 5244099
				OE_MSG_PUB.ADD;
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Unexpected result error code in Process_Credit_Card-->'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Process_Credit_Card assignment Successful....');
					oe_debug_pub.add('After calling Process_Credit_Card');
					oe_debug_pub.add('Instr assignment id'||l_assign_id);
				END IF;
			END IF; --Return status
		END IF;--Instrument assignment id
	END IF;--payment type code
	--No need to create trxn extension ids for check payments
	--as it would be stored in OM tables itself

	L_trxn_attribs.order_id := p_header_id;
	L_trxn_attribs.trxn_ref_number2 := p_payment_number;
	-- store the line id in trx_ref_number1 if this is a line level payment
	IF p_line_id IS NOT NULL THEN
		l_trxn_attribs.trxn_ref_number1 := p_line_id;
	END IF;
--END IF;
	  IF OE_Payment_Trxn_Util.g_old_bill_to_site IS NULL THEN
		--<populate data to l_trxn_attribs from l_assignment_attribs, l_credit_card_rec if it is a  credit card>
		--<Update the transaction in the IBY payment trasaction extenstion table>
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Calling update transaction extension...');
		END IF;

		IF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
			l_trxn_attribs.Originating_Application_Id := 660;
		ELSIF p_payment_type_code = 'CREDIT_CARD' THEN
			l_trxn_attribs.Originating_Application_Id := 660;

			--Need to pass the instrument security code as G_MISS_CHAR
			--if the Security code is null to the payments API to update
			--the value appropriately.
			IF p_instrument_security_code is not null then
				l_trxn_attribs.Instrument_Security_Code := p_instrument_security_code;
			ELSE
				l_trxn_attribs.Instrument_Security_Code := FND_API.G_MISS_CHAR;
			END IF;
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Values passed to Update_trxn_extn');
			oe_debug_pub.add('payment channel -->'||l_pmt_channel_code);
			oe_debug_pub.add('Assignment id ---->'|| l_assign_id);
			oe_debug_pub.add('trxn attributes record type values');
			oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||p_instrument_security_code);
			oe_debug_pub.add('l_trxn_attribs.Originating application id ---> 660');
			oe_debug_pub.add('l_trxn_attribs.order_id ----> '||p_header_id);
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||p_line_id);
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||p_payment_number);
			--oe_debug_pub.add('l_trxn_attribs.VoiceAuth_date ---->'||p_credit_card_approval_date);
			--oe_debug_pub.add('l_trxn_attribs.VoiceAuth_code ---->'||p_credit_card_approval_code);
		END IF;

 	        --bug 5028932
		BEGIN
			SELECT AUTHORIZATION_CODE into
			l_approval_code FROM IBY_TRXN_EXT_AUTHS_V
			WHERE TRXN_EXTENSION_ID = p_trxn_extension_id
                        AND INITIATOR_EXTENSION_ID = p_trxn_extension_id; -- bug 9145261/9335940

		EXCEPTION
		WHEN OTHERS THEN
			l_approval_code := null;
			IF l_debug_level >0 THEN
				oe_debug_pub.add('Others part approval code value ---> '||l_approval_code);
			END IF;
		END;

		-- to check if the authorization has been settled
		BEGIN
		  -- bug 8586227
			/*SELECT 	nvl(settled_flag, 'N'),instrument_id,card_number
			INTO	l_settled_flag,l_old_instrument_id,l_old_card_number
			FROM 	iby_trxn_extensions_v
			WHERE   trxn_extension_id = p_trxn_extension_id;*/
			SELECT 	nvl(settled_flag, 'N'),instrument_id,card_number
			 INTO	l_settled_flag,l_old_instrument_id,l_old_card_number
			FROM 	IBY_EXTN_INSTR_DETAILS_V iextn,
			        IBY_EXTN_SETTLEMENTS_V iset
			WHERE
			        iextn.trxn_extension_id= iset.trxn_extension_id (+) AND
			        iextn.trxn_extension_id = p_trxn_extension_id;

		EXCEPTION WHEN NO_DATA_FOUND THEN
			l_settled_flag := 'N';
			l_old_instrument_id := NULL;
			l_old_card_number   := NULL;
		END;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Settled Flag value....'||l_settled_flag);
		END IF;


		--If approval code is not null then the transaction
		--extension has already been authorized once. So cannot
		--call update_transaction API for this trxn_extension_id
		IF (l_approval_code IS NOT NULL AND
		NOT OE_GLOBALS.Equal(l_approval_code,FND_API.G_MISS_CHAR))
		OR l_settled_flag = 'Y' THEN

			IF l_settled_flag = 'N' THEN
				-- need to re-authorize if the authorization has expired.
				-- effective_auth_amount of 0 indicates auth has expired.
				-- the auth would be valid if authorization_amount is equal to
				-- effective_auth_amount
				BEGIN
					SELECT effective_auth_amount
					INTO   l_effective_auth_amount
					FROM   iby_trxn_ext_auths_v
					WHERE  trxn_extension_id = p_trxn_extension_id
					AND    INITIATOR_EXTENSION_ID = p_trxn_extension_id  -- bug 9335940/9145261
					AND    nvl(authorization_amount,0) > 0
					AND    authorization_status=0;
				EXCEPTION WHEN NO_DATA_FOUND THEN
					--This case is not possible as the approval code
					--for the transaction extension id is not null which
					--means that the transaction has been authorized atleast once
					NULL;
				END;

				IF nvl(l_effective_auth_amount,0) = 0 THEN
					l_reauthorize_flag := 'Y';
					IF l_debug_level  > 0 THEN
						oe_debug_pub.add(  'OEXUPTXB: authorization has either expired or not exists.');
					END IF;
				END IF;

				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Reauthorize flag value ----> '||l_reauthorize_flag);
				END IF;
			END IF;

			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Old instrument_id ---> '||l_old_instrument_id);
				oe_debug_pub.add('New instrument id..... '||l_instrument_id);
				--oe_debug_pub.add('Old card number -----> '||l_old_card_number);
				--oe_debug_pub.add('New card number -----> '||p_card_number);
			END IF;

		        IF l_settled_flag = 'Y' OR l_reauthorize_flag = 'Y' THEN

				IF l_debug_level  > 0 THEN
				  oe_debug_pub.add(  'OEXUPTXB.pls: authorization has been settled, need to re-authorize.');
				END IF;

				IF Oe_Payment_Trxn_Util.Get_CC_Security_Code_Use = 'REQUIRED'
				AND (l_trxn_attribs.Instrument_Security_Code IS NULL OR
				OE_GLOBALS.Equal(l_trxn_attribs.Instrument_Security_Code,FND_API.G_MISS_CHAR))
				THEN

					FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
					OE_Msg_Pub.Add;
					RAISE FND_API.G_EXC_ERROR;

				ELSIF Oe_Payment_Trxn_Util.Get_CC_Security_Code_Use = 'REQUIRED'
				AND l_trxn_attribs.Instrument_Security_Code IS NOT NULL
				AND NOT OE_GLOBALS.Equal(l_trxn_attribs.Instrument_Security_Code,FND_API.G_MISS_CHAR)
				THEN

					-- need to create a new payment transaction extension as the old one has been settled.
					IF l_debug_level  > 0 THEN
						oe_debug_pub.add(  'OEXUPTXB.pls: Before calling Create_New_Payment_Trxn');
						oe_debug_pub.add(  'p_trxn_extension --->'||p_trxn_extension_id);
						oe_debug_pub.add(  'p_org_id -----> '||l_org_id);
						oe_debug_pub.add(  'p_site_use_id ---> '||p_site_use_id);
						oe_debug_pub.add(  'l_trxn_extension_id --> '||l_trxn_extension_id);
					END IF;

					OE_Verify_Payment_PUB.Create_New_Payment_Trxn (p_trxn_extension_id => p_trxn_extension_id,
								 p_org_id	     => l_org_id,
								 p_site_use_id	     => p_site_use_id,
								 p_instrument_security_code => l_trxn_attribs.Instrument_Security_Code,
								 x_trxn_extension_id => l_trxn_extension_id,
								 x_msg_count         => x_msg_count,
								 x_msg_data          => x_msg_data,
								 x_return_status     => x_return_status);

					IF l_return_status = FND_API.G_RET_STS_ERROR THEN
						IF l_debug_level  > 0 THEN
						  oe_debug_pub.add(  'OEXUPTXB.pls: Exp. error in call to Create_New_Payment_Trxn');
						  oe_debug_pub.add(  'SQL ERRM ----> '||sqlerrm);
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						IF l_debug_level  > 0 THEN
						  oe_debug_pub.add(  'OEXUPTXB.pls: Unexp. error in call to Create_New_Payment_Trxn');
						  oe_debug_pub.add(  'SQL ERRM ----> '||sqlerrm);
						END IF;
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					END IF;

					IF l_debug_level  > 0 THEN
					  oe_debug_pub.add(  'OEXUPTXB.pls: After successful call to Create_New_Payment_Trxn');
					  oe_debug_pub.add(  'New trxn extension --->'||l_trxn_extension_id);
					END IF;

				       -- update oe_payments table
				       p_trxn_extension_id := l_trxn_extension_id;
				END IF; --Security code use ='REQUIRED'
			--bug 5299050
			ELSIF NOT OE_GLOBALS.Is_Same_Credit_Card(l_old_card_number,
			p_card_number,l_old_instrument_id,l_instrument_id) THEN

				l_trxn_attribs.Originating_Application_Id := 660;
				l_trxn_attribs.Instrument_Security_Code := p_instrument_security_code;

                                -- bug 5575513
                                -- per IBY, The combination of order_id, trxn ref1 and
                                -- trxn ref2 must be different for each trxn extension
                                -- as they produce the order id used to distinguish
                                -- payment operations. Since this is going to be a
                                -- different trxn_extension_id for the same order, we will
                                -- need to make sure the trxn ref2 is different, as the
                                -- order id and trxn ref1 would be the same.

                               oe_debug_pub.add('Linda -- p_trxn_extension_id is: '||p_trxn_extension_id);

                                BEGIN
                                  -- bug 8586227
                                  select trxn_ref_number2
                                  into   l_trxn_ref_number2
                                  from   IBY_EXTN_INSTR_DETAILS_V
                                  where  trxn_extension_id = p_trxn_extension_id;

                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                  null;
                                END;

                                 l_pos := instr(l_trxn_ref_number2,'R');


                                 IF l_pos > 0 THEN
                                   l_retry_num := substr(l_trxn_ref_number2, l_pos+1, length(l_trxn_ref_number2)) + 1;
                                   l_trxn_attribs.trxn_ref_number2 := substr(l_trxn_ref_number2, 1, l_pos)||to_char(l_retry_num);
                                ELSE
                                  l_retry_num := 1;
                                  l_trxn_attribs.trxn_ref_number2 := l_trxn_ref_number2||'R'||to_char(l_retry_num);
                                END IF;
                                -- end of bug 5575513

				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Before calling create_transaction extension');
					oe_debug_pub.add('payment channel -->'||l_pmt_channel_code);
					oe_debug_pub.add('Assignment id ---->'|| l_assign_id);
					oe_debug_pub.add('trxn attributes record type values');
					oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||p_instrument_security_code);
					oe_debug_pub.add('l_trxn_attribs.Originating application id ---> '||l_trxn_attribs.Originating_application_id);
					oe_debug_pub.add('l_trxn_attribs.order_id ----> '||l_trxn_attribs.order_id);
					oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||l_trxn_attribs.trxn_ref_number1);
					oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||l_trxn_attribs.trxn_ref_number2);
				END IF;

				IBY_Fndcpt_Trxn_Pub.Create_Transaction_Extension
						(p_api_version		=> 1.0,
						p_init_msg_list		=> FND_API.G_TRUE,
						p_commit		=> FND_API.G_FALSE,
						X_return_status		=> l_return_status,
						X_msg_count		=> l_msg_count,
						X_msg_data		=> l_msg_data,
						P_payer			=> l_payer,
						P_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
						P_pmt_channel		=> l_pmt_channel_code,
						P_instr_assignment	=> l_assign_id,
						P_trxn_attribs		=> l_trxn_attribs,
						x_entity_id		=> l_trxn_extension_id,
						X_response		=> l_response_code);

				--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

				IF l_debug_level > 0 THEN
					oe_debug_pub.add('After calling Create_Transaction_Extension'||l_trxn_extension_id);
					oe_debug_pub.add('Result code'||l_Response_code.result_code);
					oe_debug_pub.add('Return status'||l_Return_Status);
				END IF;

				IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
					--Setting the trxn extension id to the new value
					--as the old trxn extension id was deleted
					p_trxn_extension_id := l_trxn_extension_id ;
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Create_Transaction_Extension assignment Successful....');
						oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
						oe_debug_pub.add('After call to create Transaction Extension');
						oe_debug_pub.add('New trxn extension id'||l_trxn_extension_id);
						oe_debug_pub.add('Return status'||l_return_status);
					END IF;
				END IF;
			--bug 5299050
			END IF; -- Settled or Expired

		--If approval code is null, then this transaction has not yet been authorized
		--So can call update transaction API to update the required details for this
		--trxn extension id.
		ELSE
                        --Bug 7460481 starts
                        IF p_payment_type_code = 'CREDIT_CARD'
                        THEN
                              IF p_credit_card_approval_code IS NOT NULL THEN
                                    L_trxn_attribs.VoiceAuth_flag := 'Y';
                                    L_trxn_attribs.VoiceAuth_code := p_credit_card_approval_code;
                                    --Bug 8500353
                                   IF p_credit_card_approval_date is not null then
                                    L_trxn_attribs.VoiceAuth_date := p_credit_card_approval_date;
                                   ELSE
                                      L_trxn_attribs.VoiceAuth_date := sysdate;
                                   END IF;
                                   --Bug 8500353
                              END IF;
                        END IF;

                        IF l_debug_level > 0 THEN
                                 oe_debug_pub.add('l_trxn_attribs.VoiceAuth_date ---->'||l_trxn_attribs.VoiceAuth_date);
                                 oe_debug_pub.add('l_trxn_attribs.VoiceAuth_code ---->'||l_trxn_attribs.VoiceAuth_code);
                        END IF;
                        --Bug 7460481 ends

			IBY_Fndcpt_Trxn_Pub.Update_Transaction_Extension
				(p_api_version		=> 1.0,
				p_init_msg_list		=> FND_API.G_TRUE,
				p_commit		=> FND_API.G_FALSE,
				X_return_status		=> l_return_status,
				X_msg_count		=> l_msg_count,
				X_msg_data		=> l_msg_data,
				P_payer			=> l_payer,
				p_entity_id		=> p_trxn_extension_id,
				P_trxn_attribs		=> l_trxn_attribs,
				x_response		=> l_response_code,
				p_pmt_channel => L_pmt_channel_code,
				p_instr_assignment => l_assign_id);

			--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

			IF l_debug_level > 0 THEN
				oe_debug_pub.add('After calling update transaction extension...');
			END IF;

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Update_Transaction_Extension'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Update_Transaction_Extension'||l_response_code.result_code);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Update_Transaction_Extension assignment Successful....');
					oe_debug_pub.add('After calling Update_Transaction_Extension');
				END IF;
			END IF;
		END IF; -- Approval code not null
		--bug 5028932
	--bug 4885313
	ELSIF OE_Payment_Trxn_Util.g_old_bill_to_site IS NOT NULL THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Bill to has changed....Need to delete this trxn id as context has changed!');
			oe_debug_pub.add('Before calling Delete Transaction Extension API...');
			oe_debug_pub.add('Trxn extension id --------> '||p_trxn_extension_id);
			oe_debug_pub.add('Payer equivalency --------> '||IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_IMMEDIATE);
		END IF;
		--Setting the context corresponding to the old bill to
		--site as the trxn extension id was created for that site.
		l_payer.account_site_id := OE_Payment_Trxn_Util.g_old_bill_to_site;

		--Resetting the bill to change flag so as to
		--maintain the consistent behaviour in different sessions

		OE_Payment_Trxn_Util.g_old_bill_to_site := null;

		IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
		(
		 p_api_version		=> 1.0,
		 X_return_status	=> l_return_status,
		 X_msg_count		=> l_msg_count,
		 X_msg_data		=> l_msg_data,
		 p_commit		=> FND_API.G_FALSE,
		 P_payer		=> l_payer,
		 p_payer_equivalency    => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_IMMEDIATE,
		 X_response		=> l_response_code,
		 p_entity_id            => p_trxn_extension_id);

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Delete_Transaction_Extension'||l_response_code.result_code);
				oe_debug_pub.add('sql error'||sqlerrm);
				oe_debug_pub.add('msg data'||l_msg_data);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Delete_Transaction_Extension'||l_response_code.result_code);
				oe_debug_pub.add('sql error'||sqlerrm);
				oe_debug_pub.add('msg data'||l_msg_data);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Delete_Transaction_Extension Successful....');
				oe_debug_pub.add('After calling Delete_Transaction_Extension');
				oe_debug_pub.add('sql error'||sqlerrm);
				oe_debug_pub.add('msg data'||l_msg_data);
			END IF;
		END IF;

		IF p_payment_type_code IN ('ACH', 'DIRECT_DEBIT') THEN
			l_trxn_attribs.Originating_Application_Id := 660;
		ELSIF p_payment_type_code = 'CREDIT_CARD' THEN
			l_trxn_attribs.Originating_Application_Id := 660;
			l_trxn_attribs.Instrument_Security_Code := p_instrument_security_code;
			/*IF p_instrument_security_code IS NOT NULL AND
			NOT OE_GLOBALS.Equal(p_instrument_security_code,FND_API.G_MISS_CHAR) THEN
				--The bill to site has changed and a new credit card
				--has been brought in. Since the CVV2 value used here
				--would be of the previous cards', displaying this message
				--to the user.
				FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
				OE_Msg_Pub.Add;
			END IF;*/
		END IF;
		--Now setting the account site id as the new bill to site
		--for creating this trxn extension id
		l_payer.account_site_id := p_site_use_id;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before calling create_transaction extension');
			oe_debug_pub.add('payment channel -->'||l_pmt_channel_code);
			oe_debug_pub.add('Assignment id ---->'|| l_assign_id);
			oe_debug_pub.add('trxn attributes record type values');
			oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||p_instrument_security_code);
			oe_debug_pub.add('l_trxn_attribs.Originating application id ---> '||l_trxn_attribs.Originating_application_id);
			oe_debug_pub.add('l_trxn_attribs.order_id ----> '||l_trxn_attribs.order_id);
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||l_trxn_attribs.trxn_ref_number1);
			oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||l_trxn_attribs.trxn_ref_number2);
		END IF;

		IBY_Fndcpt_Trxn_Pub.Create_Transaction_Extension
				(p_api_version		=> 1.0,
				p_init_msg_list		=> FND_API.G_TRUE,
				p_commit		=> FND_API.G_FALSE,
				X_return_status		=> l_return_status,
				X_msg_count		=> l_msg_count,
				X_msg_data		=> l_msg_data,
				P_payer			=> l_payer,
				P_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
				P_pmt_channel		=> l_pmt_channel_code,
				P_instr_assignment	=> l_assign_id,
				P_trxn_attribs		=> l_trxn_attribs,
				x_entity_id		=> l_trxn_extension_id,
				X_response		=> l_response_code);

		--oe_msg_pub.add_text(p_message_text => l_response_code.result_message);

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('After calling Create_Transaction_Extension'||l_trxn_extension_id);
			oe_debug_pub.add('Result code'||l_Response_code.result_code);
			oe_debug_pub.add('Return status'||l_Return_Status);
		END IF;

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
			--Setting the trxn extension id to the new value
			--as the old trxn extension id was deleted
			p_trxn_extension_id := l_trxn_extension_id ;
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Create_Transaction_Extension assignment Successful....');
				oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
				oe_debug_pub.add('After call to create Transaction Extension');
				oe_debug_pub.add('New trxn extension id'||l_trxn_extension_id);
				oe_debug_pub.add('Return status'||l_return_status);
			END IF;
		END IF;

	END IF; -- old bill to site
	--bug 4885313
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Exiting Update_Payment_Trxn.....');
	END IF;

	X_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      X_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
    RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_PAYMENT_TRXN_UTIL'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Payment_Trxn;

Procedure Copy_Payment_Trxn(	p_header_id		IN NUMBER,
				P_line_id		IN NUMBER,
				p_cust_id		IN NUMBER,
				P_site_use_id		IN NUMBER,
				p_trxn_extension_id	IN NUMBER,
				x_trxn_extension_id	OUT NOCOPY NUMBER,
				X_return_status		OUT NOCOPY VARCHAR2,
				X_msg_count		OUT NOCOPY NUMBER,
				X_msg_data		OUT NOCOPY VARCHAR2)
IS
--R12 CC Encryption
L_return_status		VARCHAR2(30);
L_msg_count		NUMBER;
L_msg_data		VARCHAR2(2000);
L_party_id		NUMBER;
L_trxn_attribs		IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
L_response_code		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
L_payer			IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_org_id		NUMBER;
l_org_type		VARCHAR2(80) := 'OPERATING_UNIT';
p_entities		IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
l_invoice_to_org_id	OE_ORDER_LINES_ALL.invoice_to_org_id%TYPE;
l_cust_account_id	NUMBER; --New
l_err_message VARCHAR2(2000);
l_assignment_attribs	IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
l_instr_assignment_id	IBY_FNDCPT_PAYER_ASSGN_INSTR_V.instr_assignment_id%TYPE;
l_instrument_id		IBY_FNDCPT_PAYER_ALL_INSTRS_V.instrument_id%TYPE;
l_instrument_type	IBY_FNDCPT_PMT_CHNNLS_VL.instrument_type%TYPE;
l_instrument		IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
l_exists_assignment	VARCHAR2(1) := 'N';
l_assign_id		IBY_FNDCPT_PAYER_ASSGN_INSTR_V.instr_assignment_id%TYPE;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
--Get party id for the bill to site;??
IF p_line_id is not null then
	Select INVOICE_TO_ORG_ID,ORG_ID into l_invoice_to_org_id,l_org_id
	from oe_order_lines_all where header_id = p_header_id and line_id = p_line_id;
else
        /*
	select invoice_to_org_id,ORG_ID into l_invoice_to_org_id,l_org_id
	from oe_order_headers_all where header_id = p_header_id;
        */

        oe_order_cache.load_order_header(p_header_id);
        l_invoice_to_org_id := OE_Order_Cache.g_header_rec.invoice_to_org_id;
        l_org_id := OE_Order_Cache.g_header_rec.org_id;
end if;
IF l_debug_level > 0 THEN
	oe_debug_pub.add('INVOICE_TO_ORG_ID and ORG_ID'||l_invoice_to_org_id||' and '||l_org_id);
END IF;

Begin
	Select	hca.party_id, acct_site.cust_account_id
	Into 	l_party_id, l_cust_account_id
	From 	HZ_CUST_SITE_USES_ALL SITE,
		HZ_CUST_ACCT_SITES    ACCT_SITE,
                HZ_CUST_ACCOUNTS_ALL  HCA
	Where 	SITE.SITE_USE_ID = p_site_use_id
	AND	SITE.SITE_USE_CODE  = 'BILL_TO'
	AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
	AND   	ACCT_SITE.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
	AND  	SITE.ORG_ID = ACCT_SITE.ORG_ID;

Exception
When No_Data_Found THEN
	Null;
End;

l_payer.payment_function := 'CUSTOMER_PAYMENT';
l_payer.party_id	:= l_party_id;
l_payer.org_type	:= l_org_type;
l_payer.org_id		:= l_org_id;
l_payer.cust_account_id	:= l_cust_account_id;
l_payer.account_site_id	:= p_site_use_id;

	Begin
	  -- Bug 8586227
	select 	instrument_id, instrument_type, instr_assignment_id
	into	l_instrument_id, l_instrument_type, l_instr_assignment_id
	from 	IBY_EXTN_INSTR_DETAILS_V
	where	trxn_extension_id = p_trxn_extension_id;
	Exception When NO_DATA_FOUND THEN
		null;
	End;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('instrument_id is: '||l_instrument_id,1);
	END IF;

	-- Need to call the Set Payer Instr Assignment API always
	--to create a new assignment id at the account level as iStore
	--creates the assignment id at the Party or Site level.

	--Commenting out this check for that.
	/*Begin
	Select	'Y'
	Into	l_exists_assignment
	From	IBY_FNDCPT_PAYER_ASSGN_INSTR_V
	Where 	party_id = l_party_id
	And	instr_assignment_id = l_instr_assignment_id
	And 	rownum = 1;
	Exception When NO_DATA_FOUND THEN
		l_exists_assignment := 'N';
	End;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('l_exists_assignment is: '||l_exists_assignment,1);
	END IF;

	IF l_exists_assignment = 'N' THEN*/

	-- create a new instrument assignment id for the payer
	-- and the instrument

	l_instrument.instrument_type := l_instrument_type;
	l_instrument.instrument_id := l_instrument_id;
	l_assignment_attribs.instrument := l_instrument;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Calling Oracle Payments API to create new assignment.',1);
		oe_debug_pub.add('Before call to Set payer instr assignment API...');
		oe_debug_pub.add('Assignment attributes passed ');
		oe_debug_pub.add('l_instrument.instrument_id ---> '||l_instrument_id);
		oe_debug_pub.add('l_instrument.instrument_type -> '||l_instrument_type);
	END IF;

	IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment
	(p_api_version		=> 1.0,
	p_init_msg_list		=> FND_API.G_TRUE,
	p_commit		=> FND_API.G_FALSE,
	X_return_status		=> l_return_status,
	X_msg_count		=> l_msg_count,
	X_msg_data		=> l_msg_data,
	P_payer			=> l_payer,
	P_assignment_attribs	=> l_assignment_attribs,
	X_assign_id		=> l_assign_id,
	X_response		=> l_response_code);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Set_Payer_Instr_Assignment'||l_response_code.result_code);
		END IF;
		--IF l_response_code.result_code = '
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Set_Payer_Instr_Assignment'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result code in Set_Payer_Instr_Assignment'||l_response_code.result_code);
			oe_debug_pub.add('new assignment id is: '||l_assign_id,1);
		END IF;
	END IF;

	--Populating the new assignment id to the copy instr
	--assign id attribute and then calling copy transaction API.
	l_trxn_attribs.copy_instr_assign_id := l_assign_id;
	l_trxn_attribs.order_id := p_header_id;

	p_entities(1) := p_trxn_extension_id;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Payer context in copy...'||l_party_id||' and '||l_org_type ||'and'||l_cust_account_id||'and'||'and'||p_site_use_id||'and'||p_trxn_extension_id||'and'||p_header_id);
	END IF;

	--<store the line id in trx_ref_number1 if this is a line level payment>
	IF p_line_id IS NOT NULL THEN
		l_trxn_attribs.trxn_ref_number1 := p_line_id;
	END IF;

	l_trxn_attribs.Originating_Application_Id := 660;

	--<Copy the transaction in the IBY payment trasaction extenstion table>
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Values passed to Copy_transaction_extension');
		oe_debug_pub.add('original trxn extension id ---->'||p_entities(1));
		oe_debug_pub.add('trxn attributes record type values');
		--oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||p_instrument_security_code);
		oe_debug_pub.add('l_trxn_attribs.Originating application id ---> 660');
		oe_debug_pub.add('l_trxn_attribs.order_id ----> '||p_header_id);
		oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||p_line_id);
		--oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||p_payment_number);
		oe_debug_pub.add('l_trxn_attribs.copy_instr_assign_id ---->'||l_assign_id);
	END IF;
	IBY_Fndcpt_Trxn_Pub.Copy_Transaction_Extension
			(p_api_version		=> 1.0,
			p_init_msg_list		=> FND_API.G_TRUE,
			p_commit		=> FND_API.G_FALSE,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data,
			P_payer			=> l_payer,
			P_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
			p_entities		=> p_entities,
			p_trxn_attribs		=> l_trxn_attribs,
			X_entity_id		=> x_trxn_extension_id,
			x_response		=> l_response_code);

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Return status from Copy_Transaction_Extension'||l_return_status);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Copy_Transaction_Extension'||l_response_code.result_code);
		END IF;
		--IF l_response_code.result_code = '
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Copy_Transaction_Extension'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result code in Copy_Transaction_Extension'||l_response_code.result_code);
		END IF;
	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Exiting OE_PAYMENT_TRXN_UTIL.Copy_Payment_Trxn.', 1);
	END IF;

	X_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Copy_Transaction_Extension  error....exc');
		oe_debug_pub.add('After call to Copy_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Copy_Transaction_Extension  error....unxc');
		oe_debug_pub.add('After call to Copy_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('f Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Transaction_Extension assignment error....others');
		oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('trx Error'||l_err_message);
	END IF;

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_PAYMENT_TRXN_UTIL'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	--R12 CC Encryption
END Copy_Payment_Trxn;

Procedure Get_Payment_Trxn_Info(p_header_id	IN NUMBER,
				P_trxn_extension_id		IN NUMBER,
				P_payment_type_code		IN VARCHAR2,
				X_credit_card_number		OUT NOCOPY VARCHAR2,
				X_credit_card_holder_name	OUT NOCOPY VARCHAR2,
				X_credit_card_expiration_date	OUT NOCOPY VARCHAR2,
				X_credit_card_code		OUT NOCOPY VARCHAR2,
				X_credit_card_approval_code	OUT NOCOPY VARCHAR2,
				X_credit_card_approval_date	OUT NOCOPY VARCHAR2,
				X_bank_account_number		OUT NOCOPY VARCHAR2,
				--X_check_number		OUT NOCOPY VARCHAR2,
				X_instrument_security_code	OUT NOCOPY VARCHAR2,
				X_instrument_id			OUT NOCOPY NUMBER,
				X_instrument_assignment_id	OUT NOCOPY NUMBER,
				X_return_status			OUT NOCOPY VARCHAR2,
				X_msg_count			OUT NOCOPY NUMBER,
				X_msg_data			OUT NOCOPY VARCHAR2) IS

--R12 CC Encryption
L_trxn_extension_id 	NUMBER := P_trxn_extension_id;
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;
l_payer		     IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_party_id	     NUMBER;

l_auth_result	     IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
l_response	     IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_cust_account_id NUMBER;
l_acct_site_use_id NUMBER;
l_org_type	   VARCHAR2(80);
l_payment_function VARCHAR2(80);
l_org_id NUMBER;
l_trxn_attribs IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_err_message VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
L_authorized VARCHAR2(1);
l_encrypted	VARCHAR2(30);  --PADSS
BEGIN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering Get_Payment_Trxn_Info...');
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	--< if l_trxn_extension_id is null, this might be called from sales order header>
	IF l_trxn_extension_id IS NULL THEN
		SELECT trxn_extension_id
		INTO l_trxn_extension_id
		FROM oe_payments
		WHERE header_id = p_header_id;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Trxn extension id from oe_payments'||l_trxn_extension_id);
	END IF;

	END IF;

	IF l_trxn_extension_id is not null then
		IF p_payment_type_code in ('ACH', 'DIRECT_DEBIT') then
		  -- bug 8586227
			Select account_number
			Into x_bank_account_number
			From IBY_EXTN_INSTR_DETAILS_V
			Where trxn_extension_id = l_trxn_extension_id;
		ELSIF p_payment_type_code = 'CREDIT_CARD' THEN
		  -- bug 8586227
			/*Select  itev.card_number,
				itev.card_holder_name,
				--itev.card_expirydate,
				itev.masked_card_expirydate,  --PADSS
				itev.card_issuer_code,
				itev.authorized_flag,
				itev.instrument_security_code,
				itev.instrument_id,
				itev.instr_assignment_id
			into
				x_credit_card_number,
				x_credit_card_holder_name,
				x_credit_card_expiration_date,
				x_credit_card_code,
				l_authorized,
				x_instrument_security_code,
				x_instrument_id,
				x_instrument_assignment_id
			FROM
				IBY_TRXN_EXTENSIONS_V ITEV
			WHERE	ITEV.TRXN_EXTENSION_ID = l_trxn_extension_id;*/

			Select  itev.card_number,
				itev.card_holder_name,
				--itev.card_expirydate,
				itev.masked_card_expirydate,  --PADSS
				itev.card_issuer_code,
				iauth.authorized_flag,
				itev.instrument_security_code,
				itev.instrument_id,
				itev.instr_assignment_id
			 into
				x_credit_card_number,
				x_credit_card_holder_name,
				x_credit_card_expiration_date,
				x_credit_card_code,
				l_authorized,
				x_instrument_security_code,
				x_instrument_id,
				x_instrument_assignment_id
			FROM
			      IBY_EXTN_INSTR_DETAILS_V ITEV,
			      IBY_EXTN_AUTHORIZATIONS_V IAUTH
			WHERE
			      itev.TRXN_EXTENSION_ID= IAUTH.TRXN_EXTENSION_ID (+) AND
			      ITEV.TRXN_EXTENSION_ID = l_trxn_extension_id;


			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Values retrieved in Get_Payment_Trxn_Info...');
				--oe_debug_pub.add('x_credit_card_number ----> '||x_credit_card_number);
				--oe_debug_pub.add('x_credit_card_holder_name ----> '||x_credit_card_holder_name);
				--oe_debug_pub.add('x_credit_card_expiration_date ---> '||x_credit_card_expiration_date);
				--oe_debug_pub.add('x_credit_card_code ---> '||x_credit_card_code);
				oe_debug_pub.add('l_authorized ---> '||l_authorized);
				oe_debug_pub.add('x_instrument_security_code ----> '||x_instrument_security_code);
				oe_debug_pub.add('x_instrument_id ---> '||x_instrument_id);
				oe_debug_pub.add('x_instrument_assignment_id ----> '||x_instrument_assignment_id);
			END IF;

                        --PADSS start
                        begin
                        select encrypted
			into l_encrypted
			from iby_creditcard
                        where instrid=x_instrument_id;
                        exception
                          when others then
                            l_encrypted:=null;
                        end;
			--IF iby_cc_security_pub.encryption_enabled() THEN
			IF nvl(l_encrypted,'N')= 'A' THEN
			   x_credit_card_expiration_date := NULL;
			ELSE
			   x_credit_card_expiration_date := to_date(x_credit_card_expiration_date,'mm/yy');
			END IF;
			--PADSS end

			IF l_authorized = 'Y' THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Before calling IBY Get_authorization API...');
					oe_debug_pub.add('trxn extn id passed to get auth'||l_trxn_extension_id);
				END IF;
				IBY_Fndcpt_Trxn_Pub.Get_Authorization
				(p_api_version		=> 1.0,
				x_return_status		=> l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data,
				p_payer			=> l_payer,
				p_trxn_entity_id	=> l_trxn_extension_id,
				x_auth_result		=> l_auth_result,
				x_response		=> l_response);

				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Return status from Get_Authorization'||l_return_status);
				END IF;

				IF l_return_status = FND_API.G_RET_STS_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Get_Authorization'||l_response.result_code);
					END IF;
					--IF l_response_code.result_code = '
				ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Result error code in Get_Authorization'||l_response.result_code);
					END IF;
				ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('Success in Get_Authorization'||l_response.result_code);
						--oe_debug_pub.add('approval code ----> '||l_auth_result.auth_code);
						--oe_debug_pub.add('x_credit_card_approval_date ---> '||l_auth_result.auth_date);
					END IF;
					x_credit_card_approval_code := l_auth_result.auth_code;
					x_credit_card_approval_date := l_auth_result.auth_date;
				END IF;
			END IF; --Authorized flag = 'Y'

		END IF; --Payment type code = 'Credit_card'

	END IF; --trxn extension id not null

	X_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Exiting Get_Payment_Trxn_Info....');
        END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Get_Payment_Trxn_Info error....exc');
		oe_debug_pub.add('After call to Get_Payment_Trxn_Info'||l_return_status);
		oe_debug_pub.add('Result code'||l_response.result_code);
		oe_debug_pub.add('Error'||l_err_message);
	END IF;


      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Get_Payment_Trxn_Info error....unxc');
		oe_debug_pub.add('After call to Get_Payment_Trxn_Info'||l_return_status);
		oe_debug_pub.add('Result code'||l_response.result_code);
		oe_debug_pub.add('f Error'||l_err_message);
	END IF;


      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Get_Payment_Trxn_Info error....others');
		oe_debug_pub.add('After call to Get_Payment_Trxn_Info'||l_return_status);
		oe_debug_pub.add('Result code'||l_response.result_code);
		oe_debug_pub.add('trx Error'||l_err_message);
	END IF;


      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_PAYMENT_TRXN_UTIL'
            );
      END IF;

    --  FND_MESSAGE.SET_NAME('ONT','Exception in Get_Payment_Trxn_Info');
    --  OE_MSG_PUB.Add;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Get_Payment_Trxn_Info;

PROCEDURE Delete_Payment_Trxn
(p_header_id	    IN NUMBER,
 p_line_id	    IN NUMBER,
 p_payment_number   IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_count        OUT NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2,
 p_trxn_extension_id        IN   NUMBER,
 P_site_use_id	    IN NUMBER
 )
IS
L_payer			IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_org_id		NUMBER;
l_org_type		VARCHAR2(80) := 'OPERATING_UNIT';
L_return_status		VARCHAR2(30);
L_msg_count		NUMBER;
L_msg_data		VARCHAR2(2000);
L_party_id		NUMBER;
L_response_code		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_cust_account_id	NUMBER;
l_err_message		VARCHAR2(2000);
l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
l_site_use_id	        NUMBER := p_site_use_id;
l_payment_channel_code	VARCHAR2(80);
l_invoice_to_org_id	NUMBER;
-- bug 5194228
l_settled_flag		VARCHAR2(1);
l_authorized_flag	VARCHAR2(1);

BEGIN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering Delete_Payment_Trxn...');
	END IF;

	IF p_line_id is not null then
		Select ORG_ID into l_org_id
		from oe_order_lines_all where line_id = p_line_id and header_id = p_header_id;
	else
        	oe_order_cache.load_order_header(p_header_id);
        	l_org_id := OE_Order_Cache.g_header_rec.org_id;
	end if;
	--For ACH and direct debit payment types, the site use id that
	--needs to be queried from payment tables is different from the query
	--for Credit card payments. Hence to differentiate this, the payment
	--channel code is used.
	begin
	   -- BUG 8586227
		/*select payment_channel_code,settled_flag,authorized_flag
		into l_payment_channel_code,l_settled_flag,l_authorized_flag -- bug 5194228
		from iby_trxn_extensions_v where trxn_Extension_id=p_trxn_extension_id;*/
		select payment_channel_code,nvl(settled_flag,'N'),nvl(authorized_flag,'N')
		  into l_payment_channel_code,l_settled_flag,l_authorized_flag -- bug 5194228
		from IBY_EXTN_INSTR_DETAILS_V itev ,
		     IBY_EXTN_AUTHORIZATIONS_V iauth,
		     IBY_EXTN_SETTLEMENTS_V iset
		where itev.trxn_extension_id=iauth.trxn_extension_id (+)
		  and itev.trxn_extension_id=iset.trxn_extension_id (+)
		  and itev.trxn_extension_id=p_trxn_extension_id;

	exception
	when others then
		oe_debug_pub.add('Trxn extn id not found....');
	end ;

	--Incase of deleting payments due to bill to site change
	--the invoice to org id is passed as null. So querying the
	--old invoice to org id from the payments tables in this case.
	IF l_site_use_id is null then
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Inside l_site_use_id is null....'||l_payment_channel_code);
			oe_debug_pub.add('Trxn extension id used to query ----> '||p_trxn_extension_id);
		END IF;

		BEGIN
			IF l_payment_channel_code = 'CREDIT_CARD' THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Inside the credit card query for site use id...'||p_trxn_extension_id);
				END IF;
				-- bug 8586227
				select ifpai.acct_site_use_id into l_site_use_id
				from iby_fndcpt_payer_assgn_instr_v ifpai,
				IBY_EXTN_INSTR_DETAILS_V itev where
				ifpai.instr_assignment_id = itev.instr_assignment_id and
				itev.trxn_extension_id = p_trxn_extension_id;
			ELSE
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Inside the ACH and Direct debit query for site use id...'||p_trxn_extension_id);
				END IF;
				select iepa.acct_site_use_id into l_site_use_id from
				iby_external_payers_all iepa, iby_fndcpt_tx_extensions ifte
				where iepa.ext_payer_id = ifte.ext_payer_id and
				ifte.trxn_extension_id = p_trxn_extension_id;
			END IF;
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('site use id queried ---> '||l_site_use_id);
			END IF;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('site use id not found..!!'||sqlerrm);
			END IF;
		END;
	END IF;

	Select	hca.party_id, acct_site.cust_account_id
	Into 	l_party_id, l_cust_account_id
	From 	HZ_CUST_SITE_USES_ALL SITE,
	        HZ_CUST_ACCT_SITES    ACCT_SITE,
                HZ_CUST_ACCOUNTS_ALL  HCA
	Where 	SITE.SITE_USE_ID = l_site_use_id
	AND	SITE.SITE_USE_CODE  = 'BILL_TO'
	AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
	AND   	ACCT_SITE.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
	AND  	 SITE.ORG_ID = ACCT_SITE.ORG_ID;


	l_payer.payment_function :=  'CUSTOMER_PAYMENT';
	l_payer.party_id	 := l_party_id;
	l_payer.org_type	 := l_org_type;
	l_payer.org_id		:= l_org_id;
	l_payer.cust_account_id	:= l_cust_account_id;
	--Setting the payer context appropriately
	l_payer.account_site_id	:= l_site_use_id;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Payer context values...');
		oe_debug_pub.add('party id'||l_party_id);
		oe_debug_pub.add('org id'||l_org_id);
		oe_debug_pub.add('cust acct id'||l_cust_account_id);
		oe_debug_pub.add('site use id'||l_site_use_id);
	END IF;

	BEGIN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Before calling Delete Transaction Extension API...');
			oe_debug_pub.add('Trxn extension id --------> '||p_trxn_extension_id);
			oe_debug_pub.add('Payer equivalency --------> '||IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_IMMEDIATE);
		END IF;
		-- bug 5194228
		IF nvl(l_authorized_flag,'N') = 'N' and nvl(l_Settled_flag,'N') = 'N' THEN
			IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
			(
			 p_api_version		=> 1.0,
			 X_return_status	=> l_return_status,
			 X_msg_count		=> l_msg_count,
			 X_msg_data		=> l_msg_data,
			 p_commit		=> FND_API.G_FALSE,
			 P_payer		=> l_payer,
			 p_payer_equivalency    => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_IMMEDIATE,
			 X_response		=> l_response_code,
			 p_entity_id            => p_trxn_extension_id);

			IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Delete_Transaction_Extension'||l_response_code.result_code);
					oe_debug_pub.add('sql error'||sqlerrm);
					oe_debug_pub.add('msg data'||l_msg_data);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Result error code in Delete_Transaction_Extension'||l_response_code.result_code);
					oe_debug_pub.add('sql error'||sqlerrm);
					oe_debug_pub.add('msg data'||l_msg_data);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Delete_Transaction_Extension Successful....');
					oe_debug_pub.add('After calling Delete_Transaction_Extension');
					oe_debug_pub.add('sql error'||sqlerrm);
					oe_debug_pub.add('msg data'||l_msg_data);
				END IF;
				x_return_status := FND_API.G_RET_STS_SUCCESS;
			END IF;
		END IF;
		-- bug 5194228
	 END;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
	l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Delete_Payment_Trxn error....exc');
		oe_debug_pub.add('After call to Delete_Payment_Trxn'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('Error'||l_err_message);
	END IF;

	X_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Count_And_Get
	    ( p_count => l_msg_count,
	      p_data  => l_msg_data
	    );
	RAISE FND_API.G_EXC_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Delete_Payment_Trxn error....unxc');
		oe_debug_pub.add('After call to Delete_Payment_Trxn'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('f Error'||l_err_message);
	END IF;

	X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	OE_MSG_PUB.Count_And_Get
	    ( p_count => l_msg_count,
	      p_data  => l_msg_data
	    );
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
	l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Delete_Payment_Trxn error....others');
		oe_debug_pub.add('After call to Delete_Payment_Trxn'||l_return_status);
		oe_debug_pub.add('Result code'||l_response_code.result_code);
		oe_debug_pub.add('trx Error'||l_err_message);
	END IF;

	X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	FND_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME
	    ,   'OE_PAYMENT_TRXN_UTIL'
	    );
	END IF;

    --	FND_MESSAGE.SET_NAME('ONT','Exception in Delete_Payment_Trxn'||sqlerrm);
    --	OE_MSG_PUB.Add;

	OE_MSG_PUB.Count_And_Get
	    ( p_count => l_msg_count,
	      p_data  => l_msg_data
	    );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Payment_Trxn;

FUNCTION Get_Settled_Flag(p_Trxn_Extension_Id Number)
RETURN VARCHAR2
IS
l_settled_flag VARCHAR2(1) := 'N';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering Get_Settled_Flag Function....');
		oe_debug_pub.add('Trxn extension id ---> '||p_Trxn_Extension_id);
	END IF;

	BEGIN
		IF p_trxn_extension_id IS NOT NULL AND
		NOT OE_GLOBALS.Equal(p_trxn_Extension_id, FND_API.G_MISS_NUM) THEN
		  -- bug 8586227
			select settled_flag
			into l_Settled_flag
			from IBY_EXTN_SETTLEMENTS_V
			where trxn_Extension_id = p_trxn_extension_id;
		END IF;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Settled flag retrieved successfully...');
			oe_debug_pub.add('Value of settled flag ----> '||l_settled_flag);
		END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_settled_flag := 'N';
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('The transaction extension not found in IBY Table...');
		END IF;
	WHEN OTHERS THEN
		NULL;
	END;

	RETURN l_settled_flag;
EXCEPTION
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Get_CC_Security_Code_Use'
            );
        END IF;

END Get_Settled_Flag;

FUNCTION Get_CC_Security_Code_Use
RETURN VARCHAR2
IS
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;
L_response_code	     IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_channel_attrib_uses IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Before calling Get_Payment_Channel_Attribs API...');
		oe_debug_pub.add('Payment channel ---> CREDIT_CARD');
	END IF;

	IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
	(p_api_version		=> 1.0,
	X_return_status		=> l_return_status,
	X_msg_count		=> l_msg_count,
	X_msg_data		=> l_msg_data,
	P_channel_code		=> 'CREDIT_CARD',
	X_channel_attrib_uses	=> l_channel_attrib_uses,
	X_response		=> l_response_code);

	G_CC_Security_Code_Use := l_channel_attrib_uses.Instr_SecCode_Use;
	--G_CC_Security_Code_Use := 'OPTIONAL';

	IF l_debug_level > 0 then
    		oe_debug_pub.add('Return Status --> '||l_return_status);
		oe_debug_pub.add('Response code --> '||l_response_code.result_code);
		oe_debug_pub.add('Security code use ---> '||G_CC_Security_Code_Use);
		oe_debug_pub.add('Statement Billing Address Use ----> '|| l_channel_attrib_uses.Instr_Billing_Address);
		oe_debug_pub.add('Exiting OE_PAYMENT_TRXN_UTIL.Get_CC_Security_Code_Use: '||l_return_status, 1);
	END IF;

	RETURN G_CC_Security_Code_Use;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Get_CC_Security_Code_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_CC_Security_Code_Use;


--R12 CC Encryption
END OE_PAYMENT_TRXN_UTIL;

/

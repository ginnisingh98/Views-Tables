--------------------------------------------------------
--  DDL for Package Body ASO_PAYMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PAYMENT_INT" as
/* $Header: asoipayb.pls 120.25.12010000.13 2014/06/30 08:15:33 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_PAYMENT_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_APP_ID       CONSTANT   NUMBER       :=  697;
G_AUTH_ERROR   CONSTANT   NUMBER       :=  3;
G_PKG_NAME     CONSTANT   VARCHAR2(30) :=  'ASO_PAYMENT_INT';
G_FILE_NAME    CONSTANT   VARCHAR2(12) :=  'asoipayb.pls';



FUNCTION Get_payment_term_id ( p_qte_header_id      NUMBER,
                               p_qte_line_id        NUMBER
                             ) RETURN NUMBER
IS

  cursor c_pay_term1 is
  select payment_term_id from aso_payments
  where   quote_line_id   = p_qte_line_id
  and     quote_header_id = p_qte_header_id;

  cursor c_pay_term2 is
  select payment_term_id from aso_payments
  where  quote_header_id = p_qte_header_id;

  l_payment_term_id           NUMBER;

BEGIN

    OPEN c_pay_term1;
    FETCH c_pay_term1 INTO l_payment_term_id;

    IF c_pay_term1%FOUND and l_payment_term_id IS NOT NULL and l_payment_term_id <> FND_API.G_MISS_NUM THEN

        CLOSE c_pay_term1;
        return l_payment_term_id;

    END IF;
    CLOSE c_pay_term1;

    OPEN c_pay_term2;
    FETCH c_pay_term2 INTO l_payment_term_id;

    IF c_pay_term2%FOUND and l_payment_term_id IS NOT NULL and l_payment_term_id <> FND_API.G_MISS_NUM THEN

        CLOSE c_pay_term2;
        return l_payment_term_id;

    END IF;
    CLOSE c_pay_term2;

    return l_payment_term_id;

END Get_payment_term_id;


PROCEDURE create_iby_payment(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             db_payment_rec  IN         aso_quote_pub.payment_rec_type := aso_quote_pub.G_MISS_PAYMENT_REC,
					    p_payer         IN         IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2)
IS
  l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
  l_credit_card         IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
  l_assignment_attribs  IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
  lx_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  lx_assign_id          number;
  lx_entity_id          number;
  l_trxn_attribs        IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
  l_payment_rec         aso_quote_pub.payment_rec_type := p_payment_rec;
  l_api_name            varchar2(1000) := 'create_iby_payment';
  l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;

Begin

     SAVEPOINT CREATE_IBY_PAYMENT_INT;

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Begin create_iby_payment ', 1, 'Y');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     x_payment_rec := l_payment_rec;

     l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_payment_rec.Quote_Header_Id );

     IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
	  l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( l_payment_rec.Quote_Line_Id );
     END IF;



     if (l_payment_rec.payment_type_code = 'CREDIT_CARD'
        or ( l_payment_rec.payment_type_code = fnd_api.g_miss_char and db_payment_rec.payment_type_code = 'CREDIT_CARD'))
	   and
        l_payment_rec.payment_ref_number is not null and
        l_payment_rec.payment_ref_number <> fnd_api.g_miss_char then

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Inside if for payment type credit card', 1, 'Y');
           END IF;

       If (l_payment_rec.instr_assignment_id is null or l_payment_rec.instr_assignment_id = fnd_api.g_miss_num ) then

           l_credit_card.card_id := null;

           If ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
              l_credit_card.owner_id  := l_qte_line_rec.invoice_to_cust_party_id;
              l_credit_card.billing_address_id := l_qte_line_rec.invoice_to_party_site_id;
           Else
              l_credit_card.owner_id  := l_qte_header_rec.invoice_to_cust_party_id;
              l_credit_card.billing_address_id := l_qte_header_rec.invoice_to_party_site_id;
           End If;

           l_credit_card.card_number := l_payment_rec.payment_ref_number;
           l_credit_card.expiration_date := last_day(l_payment_rec.credit_card_expiration_date);
           l_credit_card.instrument_type := 'CREDITCARD';
           l_credit_card.purchasecard_subtype := null;
           l_credit_card.PurchaseCard_Flag := 'N';
           l_credit_card.card_issuer := l_payment_rec.credit_card_code;
           l_credit_card.card_holder_name := l_payment_rec.credit_card_holder_name;
           l_credit_card.fi_name := null;
           l_credit_card.single_use_flag := 'N';
           l_credit_card.info_only_flag := 'N';
           l_credit_card.card_purpose := null;
           l_credit_card.card_description := null;
           l_credit_card.inactive_date := null;

           l_assignment_attribs.assignment_id := null;
           l_assignment_attribs.instrument.instrument_type := 'CREDITCARD';
           l_assignment_attribs.instrument.instrument_id := null;
           l_assignment_attribs.priority := null;
           l_assignment_attribs.start_date := sysdate;
           l_assignment_attribs.end_date := null;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card ', 1, 'Y');

              /* Code change for PA-DSS ER 8499296 Start
              aso_debug_pub.add('l_credit_card.card_number:     '|| l_credit_card.card_number, 1, 'Y');
	      aso_debug_pub.add('l_credit_card.expiration_date: '|| l_credit_card.expiration_date, 1, 'Y');
	      Code change for PA-DSS ER 8499296 End */

              aso_debug_pub.add('l_credit_card.card_issuer:     '|| l_credit_card.card_issuer, 1, 'Y');

              /* Code change for PA-DSS ER 8499296 Start
	      aso_debug_pub.add('l_credit_card.card_holder_name:'|| l_credit_card.card_holder_name, 1, 'Y');
	      Code change for PA-DSS ER 8499296 End */

              aso_debug_pub.add('l_credit_card.owner_id:        '|| l_credit_card.owner_id, 1, 'Y');
              aso_debug_pub.add('p_payer.party_id:              '|| p_payer.party_id, 1, 'Y');
           END IF;

           IBY_FNDCPT_SETUP_PUB.Process_Credit_Card
            (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_payer              => p_payer,
            p_credit_card        => l_credit_card,
            p_assignment_attribs => l_assignment_attribs,
            x_assign_id          => lx_assign_id,
            x_response           => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card ', 1, 'Y');
              aso_debug_pub.add('IBY Process_Credit_Card Return Status:              '||x_return_status, 1, 'Y');
		    aso_debug_pub.add('IBY Process_Credit_Card x_response.result_code:     '|| to_char(lx_response.result_code), 1, 'Y');
		    aso_debug_pub.add('IBY Process_Credit_Card x_response.result_category: '|| to_char(lx_response.result_category), 1, 'Y');
		    aso_debug_pub.add('IBY Process_Credit_Card x_response.result_message:  '|| to_char(lx_response.result_message), 1, 'Y');
		    aso_debug_pub.add('IBY Process_Credit_Card x_assign_id:                '|| to_char(lx_assign_id), 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_SETUP_PUB.Process_Credit_Card ', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;

           x_payment_rec.instr_assignment_id := lx_assign_id;

       end if;-- for instrument id check
   end if; -- for payment type check

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('END create_iby_payment',1,'N');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End create_iby_payment;



PROCEDURE create_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2)
IS
  l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
  l_credit_card         IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
  l_assignment_attribs  IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
  lx_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  lx_assign_id          number;
  lx_entity_id          number;
  l_trxn_attribs        IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
  l_payment_rec         aso_quote_pub.payment_rec_type := p_payment_rec;
  l_api_name            varchar2(1000) := 'create_payment_row';
  l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  lx_channel_attrib_uses IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
  l_payment_ref_number  varchar2(240);

 Cursor c_get_payer_id ( p_assignment_id NUMBER) is
 select party_id
 from iby_fndcpt_payer_assgn_instr_v
 where instr_assignment_id = p_assignment_id;

 Cursor c_get_payment_id is
 SELECT ASO_PAYMENTS_S.nextval FROM sys.dual;

 Cursor c_get_db_hdr_payment (p_qte_hdr_id NUMBER) is
 select payment_id
 from aso_payments
 where quote_header_id = p_qte_hdr_id
 and quote_line_id is null;

 Cursor c_get_db_line_payment (p_qte_hdr_id NUMBER, p_qte_line_id NUMBER) is
 select payment_id
 from aso_payments
 where quote_header_id = p_qte_hdr_id
 and quote_line_id = p_qte_line_id;

 l_existing_payment_id   number;

Begin

     SAVEPOINT CREATE_PAYMENT_ROW_INT;

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Begin create_payment_row ', 1, 'Y');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_payment_rec.Quote_Header_Id: '||l_payment_rec.Quote_Header_Id, 1, 'Y');
              aso_debug_pub.add('l_payment_rec.Quote_Line_Id: '||l_payment_rec.Quote_Line_Id, 1, 'Y');
              aso_debug_pub.add('l_payment_rec.payment_type_code: '||l_payment_rec.payment_type_code, 1, 'Y');
              aso_debug_pub.add('l_payment_rec.instr_assignment_id: '||l_payment_rec.instr_assignment_id, 1, 'Y');
           END IF;

           -- Check for duplicate payments see bug 5118000
           IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Checking for duplicate payment records at line level', 1, 'Y');
             END IF;
             open c_get_db_line_payment(l_payment_rec.Quote_Header_Id,l_payment_rec.Quote_Line_Id);
             fetch c_get_db_line_payment into l_existing_payment_id;
             if c_get_db_line_payment%FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               close c_get_db_line_payment;
               FND_MESSAGE.Set_Name('ASO', 'ASO_API_MULTIPLE_PAYMENTS');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             end if;
             close c_get_db_line_payment;
           ELSE
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Checking for duplicate payment records at Header level', 1, 'Y');
             END IF;
             open c_get_db_hdr_payment(l_payment_rec.Quote_Header_Id);
             fetch c_get_db_hdr_payment into l_existing_payment_id;
             if c_get_db_hdr_payment%FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               close c_get_db_hdr_payment;
               FND_MESSAGE.Set_Name('ASO', 'ASO_API_MULTIPLE_PAYMENTS');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
             end if;
             close c_get_db_hdr_payment;
           END IF;


           l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_payment_rec.Quote_Header_Id );

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After querying the header row', 1, 'Y');
              aso_debug_pub.add('l_qte_header_rec.quote_header_id: ' || l_qte_header_rec.quote_header_id, 1, 'Y');
           END IF;

           IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
	         l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( l_payment_rec.Quote_Line_Id );
           END IF;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After querying the line row', 1, 'Y');
           END IF;

     if ( l_payment_rec.payment_type_code = 'CREDIT_CARD' and
        ((l_payment_rec.payment_ref_number is not null and l_payment_rec.payment_ref_number <> fnd_api.g_miss_char) or
	    (l_payment_rec.instr_assignment_id is not null and  l_payment_rec.instr_assignment_id <> fnd_api.g_miss_num)) )  then

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Inside if for payment type credit card', 1, 'Y');
           END IF;

            -- do the validation for the payment record
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info ', 1, 'Y');
           END IF;
		 aso_validate_pvt.Validate_cc_info
            (
                p_init_msg_list     =>  fnd_api.g_false,
                p_payment_rec       =>  l_payment_rec,
                p_qte_header_rec    =>  l_qte_header_rec,
                P_Qte_Line_rec      =>  l_qte_line_rec,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling Validate_cc_info ', 1, 'Y');
              aso_debug_pub.add('Validate_cc_info  Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

		  l_payer.cust_account_id := null;
            l_payer.account_site_id := null;
            l_payer.payment_function := 'CUSTOMER_PAYMENT';

        if (p_payment_rec.instr_assignment_id is null or p_payment_rec.instr_assignment_id = fnd_api.g_miss_num) then
            -- this is the Quoting flow

		If ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
              l_payer.party_id := l_qte_line_rec.invoice_to_cust_party_id;
            Else
		  l_payer.party_id := l_qte_header_rec.invoice_to_cust_party_id;
            End If;

            -- call api to create credit card and assigment , if needed
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling create_iby_payment' , 1, 'Y');
           END IF;

           aso_payment_int.create_iby_payment(p_payment_rec   => p_payment_rec,
                                              p_payer         => l_payer,
                                              x_payment_rec   => l_payment_rec,
                                              x_return_status => x_return_status ,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling create_iby_payment ', 1, 'Y');
              aso_debug_pub.add('create_iby_payment Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
         else
            -- this is the iStore Flow
            open c_get_payer_id(p_payment_rec.instr_assignment_id);
            fetch c_get_payer_id into l_payer.party_id;
            close c_get_payer_id;

	    l_payer.cust_account_id := l_qte_header_rec.cust_account_id; -- code change done for Bug 15976651

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('l_payer.party_id: '|| l_payer.party_id, 1, 'Y');
		 aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
             END IF;

         end if;

            -- generate the payment id if it is not passed, this is possible
		  -- when quote is being created first time and payment rec is created at same time
		  if (l_payment_rec.payment_id is null or l_payment_rec.payment_id = fnd_api.g_miss_num) then
		    open c_get_payment_id;
		    fetch c_get_payment_id into l_payment_rec.payment_id;
		    close c_get_payment_id;
            end if;

            l_trxn_attribs.Originating_Application_Id := 697;
            l_trxn_attribs.Order_Id := to_char(l_payment_rec.payment_id)||'-'||l_qte_header_rec.quote_number;
            l_trxn_attribs.PO_Number := null;
            l_trxn_attribs.PO_Line_Number := null;
            l_trxn_attribs.Trxn_Ref_Number1 := l_payment_rec.quote_header_id;
            IF l_payment_rec.quote_line_id = fnd_api.g_miss_num then
              l_trxn_attribs.Trxn_Ref_Number2 := null;
            Else
              l_trxn_attribs.Trxn_Ref_Number2 := l_payment_rec.quote_line_id;
            End if;

            -- Check to see if cvv2 is mandatory or not
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
           END IF;

		  IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
            (
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_channel_code         => 'CREDIT_CARD',
            x_channel_attrib_uses  => lx_channel_attrib_uses,
            x_response             => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
            aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
            aso_debug_pub.add('cvv2 use:      '||lx_channel_attrib_uses.Instr_SecCode_Use, 1, 'Y');
            aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
            aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
            aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

           IF (nvl(lx_channel_attrib_uses.Instr_SecCode_Use,'null') = 'REQUIRED' and
               (l_payment_rec.cvv2 is null or l_payment_rec.cvv2 = fnd_api.g_miss_char)) then

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('ASO', 'ASO_CC_INVALID');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;


            if l_payment_rec.cvv2 = fnd_api.g_miss_char then
              l_trxn_attribs.Instrument_Security_Code := null;
            else
              l_trxn_attribs.Instrument_Security_Code := l_payment_rec.cvv2;
            end if;

            l_trxn_attribs.VoiceAuth_Flag := null;
            l_trxn_attribs.VoiceAuth_Date := null;
            l_trxn_attribs.VoiceAuth_Code := null;
            l_trxn_attribs.Additional_Info := null;


           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Instrument Assignment id: '|| l_payment_rec.instr_assignment_id, 1, 'Y');
           END IF;

            IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
            (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_payer,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_pmt_channel       => l_payment_rec.payment_type_code,
            p_instr_assignment  => l_payment_rec.instr_assignment_id,
            p_trxn_attribs      => l_trxn_attribs,
            x_entity_id         => lx_entity_id,
            x_response          => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
		  aso_debug_pub.add('lx_entity_id:            '||lx_entity_id, 1, 'Y');
		  aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
		  aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
		  aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;

     end if;



           IF l_payment_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD' then
		    l_payment_ref_number := null;
		 else
		    l_payment_ref_number := l_payment_rec.PAYMENT_REF_NUMBER;
		 END IF;


           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling the table handler to insert the data ', 1, 'Y');
           END IF;


     ASO_PAYMENTS_PKG.Insert_Row(
            px_PAYMENT_ID                 => l_payment_rec.PAYMENT_ID,
            p_CREATION_DATE               => SYSDATE,
            p_CREATED_BY                  => fnd_global.USER_ID,
            p_LAST_UPDATE_DATE            => SYSDATE,
            p_LAST_UPDATED_BY             => fnd_global.USER_ID,
            p_LAST_UPDATE_LOGIN           => FND_GLOBAL.CONC_LOGIN_ID,
            p_REQUEST_ID                  => l_payment_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID      => l_payment_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID                  => l_payment_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE         => l_payment_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID             => l_payment_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID               => l_payment_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID           => l_payment_rec.QUOTE_SHIPMENT_ID ,
            p_PAYMENT_TYPE_CODE           => l_payment_rec.PAYMENT_TYPE_CODE,
            p_PAYMENT_REF_NUMBER          => l_payment_ref_number,
            p_PAYMENT_OPTION              => l_payment_rec.PAYMENT_OPTION,
            p_PAYMENT_TERM_ID             => l_payment_rec.PAYMENT_TERM_ID,
            p_CREDIT_CARD_CODE            => null,
            p_CREDIT_CARD_HOLDER_NAME     => null,
            p_CREDIT_CARD_EXPIRATION_DATE => null,
            p_CREDIT_CARD_APPROVAL_CODE   => null,
            p_CREDIT_CARD_APPROVAL_DATE   => null,
            p_PAYMENT_AMOUNT              => l_payment_rec.PAYMENT_AMOUNT,
            p_ATTRIBUTE_CATEGORY          => l_payment_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1                  => l_payment_rec.ATTRIBUTE1,
            p_ATTRIBUTE2                  => l_payment_rec.ATTRIBUTE2,
            p_ATTRIBUTE3                  => l_payment_rec.ATTRIBUTE3,
            p_ATTRIBUTE4                  => l_payment_rec.ATTRIBUTE4,
            p_ATTRIBUTE5                  => l_payment_rec.ATTRIBUTE5,
            p_ATTRIBUTE6                  => l_payment_rec.ATTRIBUTE6,
            p_ATTRIBUTE7                  => l_payment_rec.ATTRIBUTE7,
            p_ATTRIBUTE8                  => l_payment_rec.ATTRIBUTE8,
            p_ATTRIBUTE9                  => l_payment_rec.ATTRIBUTE9,
            p_ATTRIBUTE10                 => l_payment_rec.ATTRIBUTE10,
            p_ATTRIBUTE11                 => l_payment_rec.ATTRIBUTE11,
            p_ATTRIBUTE12                 => l_payment_rec.ATTRIBUTE12,
            p_ATTRIBUTE13                 => l_payment_rec.ATTRIBUTE13,
            p_ATTRIBUTE14                 => l_payment_rec.ATTRIBUTE14,
            p_ATTRIBUTE15                 => l_payment_rec.ATTRIBUTE15,
           p_ATTRIBUTE16                 => l_payment_rec.ATTRIBUTE16,
            p_ATTRIBUTE17                 => l_payment_rec.ATTRIBUTE17,
            p_ATTRIBUTE18                 => l_payment_rec.ATTRIBUTE18,
            p_ATTRIBUTE19                 => l_payment_rec.ATTRIBUTE19,
            p_ATTRIBUTE20                 => l_payment_rec.ATTRIBUTE20,
          p_CUST_PO_NUMBER              => l_payment_rec.CUST_PO_NUMBER,
           p_PAYMENT_TERM_ID_FROM        => l_payment_rec.PAYMENT_TERM_ID_FROM,
          p_OBJECT_VERSION_NUMBER       => l_payment_rec.OBJECT_VERSION_NUMBER,
            p_CUST_PO_LINE_NUMBER         => l_payment_rec.CUST_PO_LINE_NUMBER,
            p_trxn_extension_id           => lx_entity_id
          );

            x_payment_rec := l_payment_rec;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('END create_payment_row',1,'N');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End create_payment_row;



PROCEDURE update_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_payment_rec   OUT NOCOPY aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2) is

l_api_name            varchar2(1000) := 'update_payment_row';
l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_credit_card         IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
l_assignment_attribs  IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
lx_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
lx_assign_id          number;
lx_entity_id          number;
l_trxn_attribs        IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_payment_rec         aso_quote_pub.payment_rec_type := p_payment_rec;
l_db_payment_rec      aso_quote_pub.payment_rec_type;
l_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_card_instrument     IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
lx_channel_attrib_uses   IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
l_payment_ref_number     varchar2(240);
l_shared_cart_scenario   varchar2(1) := 'N';
l_orig_party_id          number;

/*** Start : Code Added for Bug 8712439 for HTML Quoting PA-DSS update issue ***/
lc_payment_rec        aso_quote_pub.payment_rec_type := p_payment_rec;
/*** End : Code Added for Bug 8712439 for HTML Quoting PA-DSS update issue ***/


 Cursor c_get_payer_id ( p_assignment_id NUMBER) is
 select party_id
 from iby_fndcpt_payer_assgn_instr_v
 where instr_assignment_id = p_assignment_id;

 /*** Commented this for Bug 9751000 ***/
/*
 Cursor c_get_payer_from_trxn(p_trxn_extension_id number) is
 select a.party_id
 from iby_fndcpt_payer_assgn_instr_v a, IBY_TRXN_EXTENSIONS_V b
 where a.instr_assignment_id = b.instr_assignment_id
 and b.trxn_extension_id = p_trxn_extension_id;
*/

/*** Added this cursor for Bug 9751000 instead of the above query.
This change is done to get the record that is inactivated by Istore.***/

Cursor c_get_payer_from_trxn(p_trxn_extension_id number) is
SELECT p.party_id
FROM fnd_lookup_values_vl ccunk,
  iby_creditcard c,
  iby_creditcard_issuers_vl i,
  iby_external_payers_all p,
  iby_ext_bank_accounts_v b,
  iby_pmt_instr_uses_all u,
  hz_parties hzcc,
  IBY_TRXN_EXTENSIONS_V t
WHERE(u.ext_pmt_party_id = p.ext_payer_id)
 AND(decode(u.instrument_type,   'CREDITCARD',   u.instrument_id,   'DEBITCARD',   u.instrument_id,   NULL) = c.instrid(+))
 AND(decode(u.instrument_type,   'BANKACCOUNT',   u.instrument_id,   NULL) = b.bank_account_id(+))
 AND(c.card_issuer_code = i.card_issuer_code(+))
 AND(c.card_owner_id = hzcc.party_id(+))
 AND(u.payment_flow = 'FUNDS_CAPTURE')
 --AND(nvl(c.inactive_date,   sysdate + 10) > sysdate) /***  Commented to get all the creditcard records for bug 9751000 ***/
 AND(ccunk.lookup_type = 'IBY_CARD_TYPES')
 AND(ccunk.lookup_code = 'UNKNOWN')
 AND u.instrument_payment_use_id = t.instr_assignment_id
 AND t.trxn_extension_id = p_trxn_extension_id;

 /*** Start : Code change done for Bug 14619666 ***/
 Cursor c_check_authorized_flag(p_trxn_extension_id number) is
 select authorized_flag
 from IBY_TRXN_EXTENSIONS_V
 where trxn_extension_id = p_trxn_extension_id;

 l_authorized_flag  VARCHAR2(1);
 /*** End : Code change done for Bug 14619666 ***/

Begin

     SAVEPOINT UPDATE_PAYMENT_ROW_INT;

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Begin update_payment_row ', 1, 'Y');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;



     -- Start API Body
     l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_payment_rec.Quote_Header_Id );

     IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
	  l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( l_payment_rec.Quote_Line_Id );
     END IF;

     --Get the databse payment record and assign it to l_db_payment_rec
     IF ( l_payment_rec.Quote_Line_Id = fnd_api.g_miss_num) then
	    l_payment_rec.quote_line_id := null;
     END IF;
     l_payment_tbl := aso_utility_pvt.Query_Payment_Rows(l_payment_rec.quote_header_id,l_payment_rec.quote_line_id);
     l_db_payment_rec := l_payment_tbl(1);

     /*** Start : Code Added for Bug 8712439 for HTML Quoting PA-DSS update issue ***/

     If (nvl(l_db_payment_rec.payment_type_code,'NULL') = 'CREDIT_CARD') And
        (l_payment_rec.payment_type_code Is Null Or l_payment_rec.payment_type_code = fnd_api.g_miss_char) Then

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Database payment_type_code is CREDIT_CARD ', 1, 'Y');
            aso_debug_pub.add('Input payment_type_code is NULL ',1, 'Y');
         End if;

         If (l_payment_rec.PAYMENT_REF_NUMBER is Not Null or l_payment_rec.PAYMENT_REF_NUMBER <> fnd_api.g_miss_num) Then

	     l_payment_rec.payment_type_code := 'CREDIT_CARD';
             lc_payment_rec.payment_type_code := 'CREDIT_CARD';

             If (l_db_payment_rec.trxn_extension_id Is Not Null) And (l_payment_rec.trxn_extension_id Is Null) Then

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Database trxn_extension_id is Not Null ', 1, 'Y');
                     aso_debug_pub.add('Input trxn_extension_id is NULL ',1, 'Y');
                  End if;

	          l_payment_rec.trxn_extension_id := l_db_payment_rec.trxn_extension_id;
	          lc_payment_rec.trxn_extension_id := l_db_payment_rec.trxn_extension_id;
	     End If;
         End If;
     End If;

     /*** End : Code Added for Bug 8712439 for HTML Quoting PA-DSS update issue ***/

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Database payment_type_code is : '||l_db_payment_rec.payment_type_code, 1, 'Y');
              aso_debug_pub.add('Database trxn_extension_id is : '||l_db_payment_rec.trxn_extension_id, 1, 'Y');
              aso_debug_pub.add('Input payment_type_code is :    '|| l_payment_rec.payment_type_code, 1, 'Y');
              aso_debug_pub.add('Input instr_assignment_id is :  '|| l_payment_rec.instr_assignment_id, 1, 'Y');

              /* Code change for PA-DSS ER 8499296 Start
	      aso_debug_pub.add('Input payment_ref_number is :   '|| l_payment_rec.payment_ref_number, 1, 'Y');
	      Code change for PA-DSS ER 8499296 End */

              aso_debug_pub.add('Input trxn_extension_id  is :   '|| l_payment_rec.trxn_extension_id, 1, 'Y');
              aso_debug_pub.add('Input instrument_id is :        '|| l_payment_rec.instrument_id, 1, 'Y');
              aso_debug_pub.add('Input cvv2 is :                 '|| l_payment_rec.cvv2, 1, 'Y');
     END IF;


            -- do the validation for the payment record
        IF l_payment_rec.payment_type_code = 'CREDIT_CARD' THEN
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info ', 1, 'Y');
           END IF;
           aso_validate_pvt.Validate_cc_info
            (
                p_init_msg_list     =>  fnd_api.g_false,
                p_payment_rec       =>  l_payment_rec,
                p_qte_header_rec    =>  l_qte_header_rec,
                P_Qte_Line_rec      =>  l_qte_line_rec,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling Validate_cc_info ', 1, 'Y');
              aso_debug_pub.add('Validate_cc_info  Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
        END IF;

        -- setting the payer record as it is used in no of cases below
            l_payer.payment_function := 'CUSTOMER_PAYMENT';
	    --	  l_payer.cust_account_id := null;
            l_payer.account_site_id := null;

	-- Start : code change done for Bug 17446596
	-- If l_qte_header_rec.QUOTE_SOURCE_CODE = 'IStore Account' Then
	If l_qte_header_rec.QUOTE_SOURCE_CODE In ('IStore Account','IStore Oneclick','IStore Walkin','IStore ProcPunchout') Then -- added for Bug 18838805
	   l_payer.cust_account_id := l_qte_header_rec.cust_account_id;
	End If;
	-- End : code change done for Bug 17446596

   If (nvl(l_db_payment_rec.payment_type_code,'NULL') <> 'CREDIT_CARD' and l_payment_rec.payment_type_code = 'CREDIT_CARD') then

       -- this is similar to the create flow

     If (l_payment_rec.instr_assignment_id is null or l_payment_rec.instr_assignment_id = fnd_api.g_miss_num ) then
         -- this is quoting flow
         -- call api to create credit card and assigment , if needed
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling create_iby_payment' , 1, 'Y');
           END IF;

            If ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
              l_payer.party_id := l_qte_line_rec.invoice_to_cust_party_id;
            Else
		  l_payer.party_id := l_qte_header_rec.invoice_to_cust_party_id;
            End If;

         aso_payment_int.create_iby_payment(p_payment_rec   => p_payment_rec,
                                            p_payer         => l_payer,
                                             x_payment_rec   => l_payment_rec,
                                             x_return_status => x_return_status ,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling create_iby_payment ', 1, 'Y');
              aso_debug_pub.add('create_iby_payment Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
     else
            -- this is the iStore Flow
            open c_get_payer_id(p_payment_rec.instr_assignment_id);
            fetch c_get_payer_id into l_payer.party_id;
            close c_get_payer_id;

	    -- l_payer.cust_account_id := l_qte_header_rec.cust_account_id; -- code change done for Bug 15976651 , commented due to fix done for Bug 17446596

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('l_payer.party_id: '|| l_payer.party_id, 1, 'Y');
		 aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
             END IF;

     end if;

            l_trxn_attribs.Originating_Application_Id := 697;
            l_trxn_attribs.Order_Id := to_char(l_payment_rec.payment_id)||'-'||l_qte_header_rec.quote_number;
            l_trxn_attribs.PO_Number := null;
            l_trxn_attribs.PO_Line_Number := null;
            l_trxn_attribs.Trxn_Ref_Number1 := l_payment_rec.quote_header_id;

            IF l_payment_rec.quote_line_id = fnd_api.g_miss_num then
             l_trxn_attribs.Trxn_Ref_Number2 := null;
            Else
             l_trxn_attribs.Trxn_Ref_Number2 := l_payment_rec.quote_line_id;
            End if;


            -- Check to see if cvv2 is mandatory or not
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
           END IF;

            IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
            (
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_channel_code         => 'CREDIT_CARD',
            x_channel_attrib_uses  => lx_channel_attrib_uses,
            x_response             => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
            aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
            aso_debug_pub.add('cvv2 use:      '||lx_channel_attrib_uses.Instr_SecCode_Use, 1, 'Y');
            aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
            aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
            aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

           IF (nvl(lx_channel_attrib_uses.Instr_SecCode_Use,'null') = 'REQUIRED' and
               (l_payment_rec.cvv2 is null or l_payment_rec.cvv2 = fnd_api.g_miss_char)) then

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('ASO', 'ASO_CC_INVALID');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

            if l_payment_rec.cvv2 = fnd_api.g_miss_char then
              l_trxn_attribs.Instrument_Security_Code := null;
            else
              l_trxn_attribs.Instrument_Security_Code := l_payment_rec.cvv2;
            end if;

            l_trxn_attribs.VoiceAuth_Flag := null;
            l_trxn_attribs.VoiceAuth_Date := null;
            l_trxn_attribs.VoiceAuth_Code := null;
            l_trxn_attribs.Additional_Info := null;


           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Instrument Assignment id: '|| l_payment_rec.instr_assignment_id, 1, 'Y');
           END IF;

           --bug 5154775
           IF (l_payment_rec.instr_assignment_id is not null and l_payment_rec.instr_assignment_id <> fnd_api.g_miss_num) then
            IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
            (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_payer,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_pmt_channel       => l_payment_rec.payment_type_code,
            p_instr_assignment  => l_payment_rec.instr_assignment_id,
            p_trxn_attribs      => l_trxn_attribs,
            x_entity_id         => lx_entity_id,
            x_response          => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
            aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
		  aso_debug_pub.add('lx_entity_id:                 '||lx_entity_id, 1, 'Y');
		  aso_debug_pub.add('x_response.result_code:       '|| to_char(lx_response.result_code), 1, 'Y');
		  aso_debug_pub.add('x_response.result_category:   '|| to_char(lx_response.result_category), 1, 'Y');
		  aso_debug_pub.add('x_response.result_message:    '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;
           l_payment_rec.trxn_extension_id := lx_entity_id;
          END IF; -- end if for the instr_assignment_id null check

   elsif (l_db_payment_rec.payment_type_code = 'CREDIT_CARD' and nvl(l_payment_rec.payment_type_code,'NULL')  <> 'CREDIT_CARD'
         and nvl(l_payment_rec.payment_type_code,'NULL') <> FND_API.G_MISS_CHAR) then

      -- similar to delete flow, delete the trxn extension for the cc in the db
            open c_get_payer_from_trxn(l_db_payment_rec.trxn_extension_id);
            fetch c_get_payer_from_trxn into l_payer.party_id;
            close c_get_payer_from_trxn;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('l_payer.party_id:                '|| l_payer.party_id, 1, 'Y');
              aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
	      aso_debug_pub.add('l_payment_rec.trxn_extension_id: '|| l_db_payment_rec.trxn_extension_id, 1, 'Y');
           END IF;

          IF (l_db_payment_rec.trxn_extension_id is not null and l_db_payment_rec.trxn_extension_id <> fnd_api.g_miss_num ) then
            IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
            (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_payer,
            p_entity_id         => l_db_payment_rec.trxn_extension_id,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            x_response          => lx_response
            );

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Return Status from IBY Delete API:                       '||x_return_status, 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_code:     '|| to_char(lx_response.result_code), 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_category: '|| to_char(lx_response.result_category), 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_message:  '|| to_char(lx_response.result_message), 1, 'Y');
            END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', ' IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;
		 end if; -- end if for the trxn ext id null check
            l_payment_rec.trxn_extension_id := null;

  elsif ( (nvl(l_db_payment_rec.payment_type_code,'NULL') = 'CREDIT_CARD') and
         ((l_payment_rec.payment_type_code = 'CREDIT_CARD') OR (l_payment_rec.payment_type_code = fnd_api.g_miss_char))) then


        if ((l_payment_rec.instr_assignment_id is null or l_payment_rec.instr_assignment_id = fnd_api.g_miss_num)
	      and (l_payment_rec.instrument_id is null or l_payment_rec.instrument_id = fnd_api.g_miss_num) )then
          -- bug 5154775
          if (l_payment_rec.payment_ref_number is not null and l_payment_rec.payment_ref_number <> fnd_api.g_miss_char ) then
           -- this is again similar to create flow , create card and assignment, if needed and update extension
           -- this is the quoting flow
           -- call api to create credit card and assigment , if needed
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling create_iby_payment' , 1, 'Y');
           END IF;

            If ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
              l_payer.party_id := l_qte_line_rec.invoice_to_cust_party_id;
            Else
		  l_payer.party_id := l_qte_header_rec.invoice_to_cust_party_id;
            End If;

	    /***Bug 8712439: Passing lc_payment_rec with 'CREDIT_CARD' as payment type code for HTML Quoting PA-DSS update issue ***/

             aso_payment_int.create_iby_payment(p_payment_rec   => lc_payment_rec, --p_payment_rec,
                                                db_payment_rec  => l_db_payment_rec,
						p_payer         => l_payer,
						x_payment_rec   => l_payment_rec,
                                                x_return_status => x_return_status ,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling create_iby_payment ', 1, 'Y');
              aso_debug_pub.add('create_iby_payment Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
           else
		  -- this means the input cc is a fax cc
               l_shared_cart_scenario := 'Y';
               IF (l_db_payment_rec.trxn_extension_id is not null and l_db_payment_rec.trxn_extension_id <> fnd_api.g_miss_num) then
                  open c_get_payer_from_trxn(l_db_payment_rec.trxn_extension_id);
                  fetch c_get_payer_from_trxn into l_orig_party_id;
                  close c_get_payer_from_trxn;
               END IF;
           end if; -- check for payment ref num
        elsif ((l_payment_rec.instr_assignment_id is not null and l_payment_rec.instr_assignment_id <> fnd_api.g_miss_num)
	        and (l_payment_rec.instrument_id is not null and l_payment_rec.instrument_id <> fnd_api.g_miss_num) )then

           -- this means card has been updated, this is the quoting flow
            If ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
              l_payer.party_id := l_qte_line_rec.invoice_to_cust_party_id;
            Else
		  l_payer.party_id := l_qte_header_rec.invoice_to_cust_party_id;
            End If;

             l_card_instrument.card_id := l_payment_rec.instrument_id;

             -- user can possibly change exp date and name on the card
             if l_payment_rec.credit_card_expiration_date = fnd_api.g_miss_date then
                l_card_instrument.expiration_date := null;
             else
                l_card_instrument.expiration_date := last_day(l_payment_rec.credit_card_expiration_date);
             end if;

             if l_payment_rec.credit_card_holder_name = fnd_api.g_miss_char then
                l_card_instrument.card_holder_name := null;
             else
                l_card_instrument.card_holder_name := l_payment_rec.credit_card_holder_name;
             end if;

             if l_payment_rec.credit_card_code = fnd_api.g_miss_char then
                l_card_instrument.card_issuer := null;
             else
                l_card_instrument.card_issuer := l_payment_rec.credit_card_code;
             end if;


           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_SETUP_PUB.Update_Card', 1, 'Y');
              aso_debug_pub.add('Instrument id: '|| l_payment_rec.instrument_id, 1, 'Y');
           END IF;
             IBY_FNDCPT_SETUP_PUB.Update_Card
                 (
                 p_api_version       => 1.0,
                 p_init_msg_list     => FND_API.G_FALSE,
                 p_commit            => FND_API.G_FALSE,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_card_instrument  =>  l_card_instrument,
                 x_response         =>  lx_response);
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_SETUP_PUB.Update_Card', 1, 'Y');
            aso_debug_pub.add('Return Status:                  '||x_return_status, 1, 'Y');
		  aso_debug_pub.add('x_response.result_code:         '|| to_char(lx_response.result_code), 1, 'Y');
		  aso_debug_pub.add('x_response.result_category:     '|| to_char(lx_response.result_category), 1, 'Y');
		  aso_debug_pub.add('x_response.result_message:      '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_SETUP_PUB.Update_Card', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           end if;

       else
            -- this is the iStore Flow
            open c_get_payer_id(l_payment_rec.instr_assignment_id);
            fetch c_get_payer_id into l_payer.party_id;
            close c_get_payer_id;

	    -- l_payer.cust_account_id := l_qte_header_rec.cust_account_id; -- code change done for Bug 15976651 , commented due to fix done for Bug 17446596

            -- fix for bug 4767905
            IF (l_db_payment_rec.trxn_extension_id is not null and l_db_payment_rec.trxn_extension_id <> fnd_api.g_miss_num) then
              open c_get_payer_from_trxn(l_db_payment_rec.trxn_extension_id);
              fetch c_get_payer_from_trxn into l_orig_party_id;
              close c_get_payer_from_trxn;

              IF ( nvl(l_payer.party_id,0) <> nvl(l_orig_party_id,0)  ) THEN
                 l_shared_cart_scenario := 'Y';
              END IF;

            END IF; -- trxn_extension_id not null check
       end if;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_payer.party_id:        '|| l_payer.party_id, 1, 'Y');
	      aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
              aso_debug_pub.add('l_orig_party_id:         '|| l_orig_party_id, 1, 'Y');
              aso_debug_pub.add('l_shared_cart_scenario:  '|| l_shared_cart_scenario, 1, 'Y');
            END IF;

            l_trxn_attribs.Originating_Application_Id := 697;
            l_trxn_attribs.Order_Id := to_char(l_payment_rec.payment_id)||'-'||l_qte_header_rec.quote_number;
            l_trxn_attribs.PO_Number := null;
            l_trxn_attribs.PO_Line_Number := null;
            l_trxn_attribs.Trxn_Ref_Number1 := l_payment_rec.quote_header_id;
            If l_payment_rec.quote_line_id = fnd_api.g_miss_num then
		   l_trxn_attribs.Trxn_Ref_Number2 := null;
		  Else
		   l_trxn_attribs.Trxn_Ref_Number2 := l_payment_rec.quote_line_id;
            End if;

            -- Check to see if cvv2 is mandatory or not
           /* In case of updating the trxn no need to check for cvv2 see bug 4746260
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
           END IF;

            IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
            (
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_channel_code         => 'CREDIT_CARD',
            x_channel_attrib_uses  => lx_channel_attrib_uses,
            x_response             => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
            aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
            aso_debug_pub.add('cvv2 use:      '||lx_channel_attrib_uses.Instr_SecCode_Use, 1, 'Y');
            aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
            aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
            aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

           IF (nvl(lx_channel_attrib_uses.Instr_SecCode_Use,'null') = 'REQUIRED' and
               (l_payment_rec.cvv2 is null or l_payment_rec.cvv2 = fnd_api.g_miss_char)) then

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('ASO', 'ASO_CC_INVALID');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
           */

            if l_payment_rec.cvv2 = fnd_api.g_miss_char then
              l_trxn_attribs.Instrument_Security_Code := null;
            else
              l_trxn_attribs.Instrument_Security_Code := l_payment_rec.cvv2;
            end if;

            l_trxn_attribs.VoiceAuth_Flag := null;
            l_trxn_attribs.VoiceAuth_Date := null;
            l_trxn_attribs.VoiceAuth_Code := null;
            l_trxn_attribs.Additional_Info := null;


            --bug 5154775
           IF ( (l_db_payment_rec.trxn_extension_id is not null and l_db_payment_rec.trxn_extension_id <> fnd_api.g_miss_num) and
			 (l_payment_rec.instr_assignment_id IS NOT NULL AND l_payment_rec.instr_assignment_id <> fnd_api.g_miss_num)   and
                (l_shared_cart_scenario = 'N'))  then

		/*** Start : Code change done for Bug 14619666 ***/
                Open c_check_authorized_flag(l_db_payment_rec.trxn_extension_id);
		Fetch c_check_authorized_flag Into l_authorized_flag;
		Close c_check_authorized_flag;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('update_payment_row , l_authorized_flag : '||l_authorized_flag, 1, 'Y');
                END IF;

		IF NVL(l_authorized_flag,'N') = 'N' Then
                /*** End : Code change done for Bug 14619666 ***/

			   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension ', 1, 'Y');
                   aso_debug_pub.add('Instrument Assignment id: '|| l_payment_rec.instr_assignment_id, 1, 'Y');
                  END IF;

			  IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension
                    (
                    p_api_version       => 1.0,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit            => FND_API.G_FALSE,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_payer             => l_payer,
                    p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                    p_entity_id        =>   l_db_payment_rec.trxn_extension_id,
		          p_pmt_channel       => l_db_payment_rec.payment_type_code,
                    p_instr_assignment  => l_payment_rec.instr_assignment_id,
                    p_trxn_attribs      => l_trxn_attribs,
                    x_response          => lx_response);

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension ', 1, 'Y');
                       aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
		             aso_debug_pub.add('x_response.result_code:  '|| to_char(lx_response.result_code), 1, 'Y');
		             aso_debug_pub.add('x_response.result_category:  '|| to_char(lx_response.result_category), 1, 'Y');
		             aso_debug_pub.add('x_response.result_message:   '|| to_char(lx_response.result_message), 1, 'Y');
                    END IF;

                    IF x_return_status <> fnd_api.g_ret_sts_success then
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                         FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', FALSE);
                         FND_MSG_PUB.ADD;
                      END IF;
                      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                          RAISE FND_API.G_EXC_ERROR;
                      END IF;
                    END IF;

                End If;  -- l_authorized_flag is N

           ELSE  -- else condition for trxn id not null
               -- fix for bug 4767905 and  5154775
               -- if cc has been created by shared user, then delete the previous extension
               if ( l_shared_cart_scenario = 'Y' and l_db_payment_rec.trxn_extension_id is not null
			     and l_db_payment_rec.trxn_extension_id <> fnd_api.g_miss_num ) THEN

                  -- set the party id to that of the orig user for deleting the trxn
                  l_payer.party_id := l_orig_party_id;
                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Before Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
                     aso_debug_pub.add('l_payer.party_id:                   '|| l_payer.party_id, 1, 'Y');
		     aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
                     aso_debug_pub.add('l_db_payment_rec.trxn_extension_id: '|| l_db_payment_rec.trxn_extension_id, 1, 'Y');
                  END IF;

                    IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
                     (
                     p_api_version       => 1.0,
                     p_init_msg_list     => FND_API.G_FALSE,
                     p_commit            => FND_API.G_FALSE,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data,
                     p_payer             => l_payer,
                     p_entity_id         => l_db_payment_rec.trxn_extension_id,
                     p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                     x_response          => lx_response
                     );

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
                        aso_debug_pub.add('Return Status from IBY Delete API:                       '||x_return_status, 1, 'Y');
                        aso_debug_pub.add('Delete_Transaction_Extension x_response.result_code:     '|| to_char(lx_response.result_code), 1, 'Y');
                        aso_debug_pub.add('Delete_Transaction_Extension x_response.result_category: '|| to_char(lx_response.result_category), 1, 'Y');
                        aso_debug_pub.add('Delete_Transaction_Extension x_response.result_message:  '|| to_char(lx_response.result_message), 1, 'Y');
                     END IF;

                     if x_return_status <> fnd_api.g_ret_sts_success then
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                           FND_MESSAGE.Set_Token('API', ' IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension', FALSE);
                           FND_MSG_PUB.ADD;
                        END IF;
                        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                       end if;
                       -- reset the party id to that of the shared user
                       open c_get_payer_id(l_payment_rec.instr_assignment_id);
                       fetch c_get_payer_id into l_payer.party_id;
                       close c_get_payer_id;
                       -- set the trxn ext id to null
				   l_payment_rec.trxn_extension_id := null;

                       -- l_payer.cust_account_id := l_qte_header_rec.cust_account_id; -- code change done for Bug 15976651 , commented due to fix done for Bug 17446596

		       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('l_payer.party_id: '|| l_payer.party_id, 1, 'Y');
		          aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
                       END IF;

               end if; -- end if for the l_shared_cart_scenario flag check

		    -- The earlier card stored in the db had no transaction ext id so it must be an Istore Fax CC scenario
              -- or this is a shared card scenario and cc has been created by shared user, hence create a new trxn ext
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('No trx ext id exists for cc iStore Fax CC being updated ', 1, 'Y');
			  aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
                 aso_debug_pub.add('Instrument Assignment id: '|| l_payment_rec.instr_assignment_id, 1, 'Y');
                 aso_debug_pub.add('l_payer.party_id: '|| l_payer.party_id,1,'Y');
               END IF;

                -- Check to see if cvv2 is mandatory or not
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
               END IF;

                IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
                (
                  p_api_version          => 1.0,
                  p_init_msg_list        => FND_API.G_FALSE,
                  x_return_status        => x_return_status,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data,
                  p_channel_code         => 'CREDIT_CARD',
                  x_channel_attrib_uses  => lx_channel_attrib_uses,
                  x_response             => lx_response);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
                  aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
                  aso_debug_pub.add('cvv2 use:      '||lx_channel_attrib_uses.Instr_SecCode_Use, 1, 'Y');
                  aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
                  aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
                  aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
                END IF;

                IF (nvl(lx_channel_attrib_uses.Instr_SecCode_Use,'null') = 'REQUIRED' and
                   (l_payment_rec.cvv2 is null or l_payment_rec.cvv2 = fnd_api.g_miss_char)) then

                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.Set_Name('ASO', 'ASO_CC_INVALID');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

              if (l_payment_rec.instr_assignment_id is not null and l_payment_rec.instr_assignment_id <> fnd_api.g_miss_num) then
               IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
               (
                 p_api_version       => 1.0,
                 p_init_msg_list     => FND_API.G_FALSE,
                 p_commit            => FND_API.G_FALSE,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_payer             => l_payer,
                 p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                 p_pmt_channel       => l_payment_rec.payment_type_code,
                 p_instr_assignment  => l_payment_rec.instr_assignment_id,
                 p_trxn_attribs      => l_trxn_attribs,
                 x_entity_id         => lx_entity_id,
                 x_response          => lx_response);

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
                    aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
                    aso_debug_pub.add('lx_entity_id:            '||lx_entity_id, 1, 'Y');
                    aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
                    aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
                    aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
                 END IF;

                 if x_return_status <> fnd_api.g_ret_sts_success then
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                     FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', FALSE);
                     FND_MSG_PUB.ADD;
                    END IF;
                    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 end if;
                 l_payment_rec.trxn_extension_id := lx_entity_id;
		     end if; -- end if for the instr_assignment_id check

		 end if; -- check for trxn extension id
   end if;


           IF ((l_payment_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD') or
		     ( l_db_payment_rec.payment_type_code = 'CREDIT_CARD' and l_payment_rec.PAYMENT_TYPE_CODE = fnd_api.g_miss_char))  then
              l_payment_ref_number := null;
           else
              l_payment_ref_number := l_payment_rec.PAYMENT_REF_NUMBER;
           END IF;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('before calling the table handler to update  the data ', 1, 'Y');
           END IF;

	ASO_PAYMENTS_PKG.Update_Row(
	    p_PAYMENT_ID                           => l_payment_rec.PAYMENT_ID,
	    p_CREATION_DATE                        => l_payment_rec.creation_date,
	    p_CREATED_BY                           => fnd_global.USER_ID,
	    p_LAST_UPDATE_DATE	                  => sysdate,
	    p_LAST_UPDATED_BY                      => fnd_global.USER_ID,
	    p_LAST_UPDATE_LOGIN                    => FND_GLOBAL.CONC_LOGIN_ID,
	    p_REQUEST_ID                           => l_payment_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID               => l_payment_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID                           => l_payment_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE                  => l_payment_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID                      => l_payment_rec.quote_header_id,
	    p_QUOTE_LINE_ID                        => l_payment_rec.QUOTE_LINE_ID,
	    p_PAYMENT_TYPE_CODE                    => l_payment_rec.PAYMENT_TYPE_CODE,
	    p_PAYMENT_REF_NUMBER                   => l_payment_ref_number,
	    p_PAYMENT_OPTION                       => l_payment_rec.PAYMENT_OPTION,
	    p_PAYMENT_TERM_ID                      => l_payment_rec.PAYMENT_TERM_ID,
	    p_CREDIT_CARD_CODE	                  => null,
	    p_CREDIT_CARD_HOLDER_NAME              => null,
	    p_CREDIT_CARD_EXPIRATION_DATE          => null,
	    p_CREDIT_CARD_APPROVAL_CODE            => null,
	    p_CREDIT_CARD_APPROVAL_DATE            => null,
	    p_PAYMENT_AMOUNT                       => l_payment_rec.PAYMENT_AMOUNT,
	    p_ATTRIBUTE_CATEGORY                   => l_payment_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1                           => l_payment_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2                           => l_payment_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3                           => l_payment_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4                           => l_payment_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5                           => l_payment_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6                           => l_payment_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7                           => l_payment_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8                           => l_payment_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9                           => l_payment_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10                          => l_payment_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11                          => l_payment_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12                          => l_payment_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13                          => l_payment_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14                          => l_payment_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15                          => l_payment_rec.ATTRIBUTE15,
         p_ATTRIBUTE16                          => l_payment_rec.ATTRIBUTE16,
         p_ATTRIBUTE17                          => l_payment_rec.ATTRIBUTE17,
         p_ATTRIBUTE18                          => l_payment_rec.ATTRIBUTE18,
         p_ATTRIBUTE19                          => l_payment_rec.ATTRIBUTE19,
         p_ATTRIBUTE20                          => l_payment_rec.ATTRIBUTE20,
		p_QUOTE_SHIPMENT_ID                   => l_payment_rec.QUOTE_SHIPMENT_ID,
	    p_CUST_PO_NUMBER                       => l_payment_rec.CUST_PO_NUMBER,
           p_PAYMENT_TERM_ID_FROM               => l_payment_rec.PAYMENT_TERM_ID_FROM,
		 p_OBJECT_VERSION_NUMBER              => l_payment_rec.OBJECT_VERSION_NUMBER,
          p_CUST_PO_LINE_NUMBER                 => l_payment_rec.CUST_PO_LINE_NUMBER,
		p_TRXN_EXTENSION_ID                   => l_payment_rec.trxn_extension_id
	    );

            x_payment_rec := l_payment_rec;


      -- End API Body


      -- Standard check for p_commit
      /*IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF; */

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('END update_payment_row',1,'N');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
end  update_payment_row;


PROCEDURE delete_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2)
IS

  L_API_NAME            varchar2(1000) := 'delete_payment_row';
  l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
  l_payment_rec         aso_quote_pub.payment_rec_type := p_payment_rec;
  l_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
  lx_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;


 Cursor c_get_payer_from_trxn(p_trxn_extension_id number) is
 select a.party_id
 from iby_fndcpt_payer_assgn_instr_v a, IBY_TRXN_EXTENSIONS_V b
 where a.instr_assignment_id = b.instr_assignment_id
 and b.trxn_extension_id = p_trxn_extension_id;

Begin

     SAVEPOINT DELETE_PAYMENT_ROW_INT;
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Begin delete_payment_row ', 1, 'Y');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_payment_rec.Quote_Header_Id );

     IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
       l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( l_payment_rec.Quote_Line_Id );
     END IF;

     --Get the databse payment record and assign it to l_payment_rec
     IF ( l_payment_rec.Quote_Line_Id = fnd_api.g_miss_num) then
	    l_payment_rec.quote_line_id := null;
     END IF;

     l_payment_tbl := aso_utility_pvt.Query_Payment_Rows(l_payment_rec.quote_header_id,l_payment_rec.quote_line_id);
     l_payment_rec := l_payment_tbl(1);

     if l_payment_tbl.count > 0 and l_payment_rec.payment_type_code = 'CREDIT_CARD' then

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Database payment_type_code is :  '|| l_payment_rec.payment_type_code, 1, 'Y');
         END IF;

          l_payer.payment_function := 'CUSTOMER_PAYMENT';
          -- l_payer.cust_account_id := null;
          l_payer.account_site_id := null;

	  -- Start : code change done for Bug 17446596
	  If l_qte_header_rec.QUOTE_SOURCE_CODE = 'IStore Account' Then
	     l_payer.cust_account_id := l_qte_header_rec.cust_account_id;
	  End If;
	  -- End : code change done for Bug 17446596

            open c_get_payer_from_trxn(l_payment_rec.trxn_extension_id);
            fetch c_get_payer_from_trxn into l_payer.party_id;
            close c_get_payer_from_trxn;


            IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('l_payer.party_id:                '|| l_payer.party_id, 1, 'Y');
	      aso_debug_pub.add('l_payer.cust_account_id: '|| l_payer.cust_account_id, 1, 'Y');
              aso_debug_pub.add('l_payment_rec.trxn_extension_id: '|| l_payment_rec.trxn_extension_id, 1, 'Y');
           END IF;

            IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
            (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_payer,
            p_entity_id         => l_payment_rec.trxn_extension_id,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
		  x_response          => lx_response
            );

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Return Status from IBY Delete API:                       '||x_return_status, 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_code:     '|| to_char(lx_response.result_code), 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_category: '|| to_char(lx_response.result_category), 1, 'Y');
              aso_debug_pub.add('Delete_Transaction_Extension x_response.result_message:  '|| to_char(lx_response.result_message), 1, 'Y');
            END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', ' IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;
     end if;

     ASO_PAYMENTS_PKG.Delete_Row(p_PAYMENT_ID => p_payment_rec.PAYMENT_ID);

      -- Standard check for p_commit
      /*IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF; */

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('END delete_payment_row',1,'N');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End delete_payment_row;

/* Code change for Bug 9746746 Start */
PROCEDURE PURGE_ASO_PAYMENTS_DATA IS

Begin

     UPDATE ASO_PAYMENTS
     SET    CREDIT_CARD_EXPIRATION_DATE = NULL,
            CREDIT_CARD_HOLDER_NAME = NULL,
            PAYMENT_REF_NUMBER = NULL
     WHERE  PAYMENT_TYPE_CODE = 'CREDIT_CARD';

     COMMIT;

EXCEPTION
	 WHEN OTHERS THEN
         aso_debug_pub.ADD('Exception in PURGE_ASO_PAYMENTS_DATA, Sqlerrm :' || SQLERRM,1,'N');
	 aso_debug_pub.ADD('Exception in PURGE_ASO_PAYMENTS_DATA, SqlCode :' || SQLCODE,1,'N');

End PURGE_ASO_PAYMENTS_DATA;
/* Code change for Bug 9746746 End */

End ASO_PAYMENT_INT;

/

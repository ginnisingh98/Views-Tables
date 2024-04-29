--------------------------------------------------------
--  DDL for Package Body AR_PMT_PROCESS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_PMT_PROCESS_WRAPPER" AS
/* $Header: ARIPAYWB.pls 120.3 2005/09/14 11:21:25 sgnagara noship $ */

 /*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

 /*========================================================================
 | PUBLIC PROCEDURE Authorize_Payment
 |
 | DESCRIPTION
 |      This procedure makes a  call to iPayment's API for Authorization
 |      IBY_Payment_Adapter_pub.OraPmtReq.
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_receipt_info_rec IN
 |         This parameter is for capturing certain receipt related information
 |         that could be useful in customizations.
 |
 |      p_authorize_input_rec      IN
 |         This parameter is for capturing all the information that is required
 |         to send to iPayment for Authorizations.
 |
 |      x_authorize_output_rec     OUT
 |         This is the output record and comprises of the output record
 |         returned by iPayment API IBY_Payment_Adapter_pub.ReqResp_rec_type
 |
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-MAR-2004           Jyoti Pandey      Created
 | 14-JUN-2004           Jyoti Pandey      Bug 3672953 Pass unique reference
 |                                         for AUTH
 *=======================================================================*/
  PROCEDURE Authorize_Payment (
   p_receipt_info_rec IN receipt_info_rec,
   p_authorize_input_rec IN authorize_input_rec,
   x_authorize_output_rec OUT NOCOPY authorize_output_rec,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2) IS

  /*-----------------------------------------------------------------------+
   | Local Variable Declarations and initializations                       |
   +-----------------------------------------------------------------------*/
  l_payee_rec       IBY_Payment_Adapter_pub.Payee_Rec_type;
  l_customer_rec    IBY_Payment_Adapter_pub.Payer_Rec_type;
  l_tangible_rec    IBY_Payment_Adapter_pub.Tangible_Rec_type;
  l_pmtreqtrxn_rec  IBY_Payment_Adapter_pub.PmtReqTrxn_Rec_type;
  l_pmtinstr_rec    IBY_payment_adapter_pub.PmtInstr_Rec_type;
  /* Bug-4606039
  l_cc_instr_rec    IBY_Payment_Adapter_pub.CreditCardInstr_Rec_Type; */
  l_reqresp_rec     IBY_Payment_Adapter_pub.ReqResp_rec_type;
  l_riskinfo_rec    IBY_Payment_Adapter_pub.RiskInfo_rec_type;

  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('AR_PMT_PROCESS_WRAPPER.Authorize_Payment(+)');
  END IF;

  -- set up payee record:
  l_payee_rec.payee_id := p_authorize_input_rec.merchant_ref;

  -- set up payer (=customer) record
  /* Bug-4606039
  l_customer_rec.payer_name := p_authorize_input_rec.cus_bank_act_name; */

  -- set up cc instrument record
  /* Bug-4606039
  l_cc_instr_rec.cc_num     := p_authorize_input_rec.cus_bank_act_num;
  l_cc_instr_rec.cc_ExpDate := p_authorize_input_rec.cus_bank_exp_date;
  l_cc_instr_rec.cc_HolderName := p_authorize_input_rec.cus_bank_act_name; */

  -- set the credit card as the payment instrument
  /* Bug-4606039
  l_pmtinstr_rec.creditcardinstr:= l_cc_instr_rec; */

  --set the tangible record
  l_tangible_rec.tangible_id:= p_authorize_input_rec.payment_server_order_num;
  l_tangible_rec.tangible_amount := p_authorize_input_rec.receipt_amount;
  l_tangible_rec.currency_code   := p_authorize_input_rec.currency_code;
  l_tangible_rec.refinfo         := p_authorize_input_rec.receipt_number;

  l_pmtreqtrxn_rec.pmtmode   := 'ONLINE';
  l_pmtreqtrxn_rec.auth_type := 'AUTHONLY';

  ---Bug 3672953 Pass Unique reference for Auth
  l_pmtreqtrxn_rec.TrxnRef   := p_authorize_input_rec.unique_reference;

  -- call to iPayment API OraPmtReq to authorize funds
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('Calling OraPmtReq');
    arp_standard.debug('l_pmtreqtrxn_rec.pmtmode: '||
                        l_pmtreqtrxn_rec.pmtmode);
    arp_standard.debug('l_pmtreqtrxn_rec.auth_type: '||
                        l_pmtreqtrxn_rec.auth_type);

    ---Bug 3672953 Pass Unique reference for Auth
    arp_standard.debug('l_pmtreqtrxn_rec.TrxnRef: '||
                        l_pmtreqtrxn_rec.TrxnRef);

    arp_standard.debug('l_tangible_rec.tangible_id: '||
                        p_authorize_input_rec.payment_server_order_num);
    arp_standard.debug('l_tangible_rec.tangible_amount: ' ||
                        to_char(l_tangible_rec.tangible_amount) );
    arp_standard.debug('l_tangible_rec.currency_code: ' ||
                        l_tangible_rec.currency_code );
    arp_standard.debug('l_tangible_rec.refinfo: ' || l_tangible_rec.refinfo);
  /* Bug-4606039
    arp_standard.debug('l_cc_instr_rec.cc_num: ' ||l_cc_instr_rec.cc_num );
    arp_standard.debug('l_cc_instr_rec.cc_ExpDate: ' ||
                        to_char(l_cc_instr_rec.cc_ExpDate));
    arp_standard.debug('l_cc_instr_rec.cc_HolderName: ' ||
                        l_cc_instr_rec.cc_HolderName ); */
    arp_standard.debug('l_payee_rec.payee_id: ' ||l_payee_rec.payee_id );
  /* Bug-4606039
    arp_standard.debug('l_customer_rec.payer_name: ' ||
                        l_customer_rec.payer_name); */
  END IF;

  IBY_Payment_Adapter_pub.OraPmtReq(
     p_api_version 	=> 1.0,
     p_init_msg_list 	=> FND_API.G_TRUE,
     p_commit       	=> FND_API.G_FALSE,
     p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
     p_ecapp_id           => 222,  -- AR product id
     x_return_status      => l_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data           => l_msg_data,
     p_payee_rec          => l_payee_rec,
     p_payer_rec          => l_customer_rec,
     p_pmtinstr_rec       => l_pmtinstr_rec,
     p_tangible_rec       => l_tangible_rec,
     p_pmtreqtrxn_rec     => l_pmtreqtrxn_rec,
     p_riskinfo_rec       => l_riskinfo_rec,
     x_reqresp_rec        => l_reqresp_rec);


    --Asssign the values to OUT Parameters
    x_return_status       := l_return_status;
    x_msg_count           := l_msg_count;
    x_msg_data            := l_msg_data;
    x_authorize_output_rec.x_reqresp_rec := l_reqresp_rec;

    ---previously p_response_error_code was an OUT parameter
    x_authorize_output_rec.x_reqresp_rec.response.errcode :=
                    l_reqresp_rec.response.errcode;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  '-------------------------------------');
       arp_standard.debug(  'x_return_status: ' || x_return_status);
       arp_standard.debug(  'l_reqresp_rec.response.errcode: ' ||
                             l_reqresp_rec.response.errcode);
       arp_standard.debug(  'l_reqresp_rec.response.errmessage: ' ||
                             l_reqresp_rec.response.errmessage);
       arp_standard.debug(  'l_reqresp_rec.errorlocation: ' ||
                             l_reqresp_rec.errorlocation);
       arp_standard.debug(  'l_reqresp_rec.beperrcode: ' ||
                             l_reqresp_rec.beperrcode);
       arp_standard.debug(  'l_reqresp_rec.beperrmessage: ' ||
                             l_reqresp_rec.beperrmessage);
       arp_standard.debug(  'NVL(l_reqresp_rec.response.status,0): ' ||
                          to_char(NVL(l_reqresp_rec.response.status,0)));
       arp_standard.debug(  'Authcode: ' || l_reqresp_rec.authcode);
       arp_standard.debug(  'Trxn ID: ' || l_reqresp_rec.Trxn_ID);
       arp_standard.debug(  '-------------------------------------');
    END IF;

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
          FND_MSG_PUB.Add;
          x_return_status := l_return_status;
          RETURN;
   END IF;


  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('AR_PMT_PROCESS_WRAPPER.Authorize_Payment(-)');
  END IF;


END Authorize_payment;

 /*========================================================================
 | PUBLIC PROCEDURE Capture_Payment
 |
 | DESCRIPTION
 |      This procedure makes a  call to iPayment's API for Capture
 |      IBY_Payment_Adapter_pub.OraPmtCapture
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_receipt_info_rec IN
 |         This parameter is for capturing certain receipt related information
 |         that could be useful in customizations.
 |
 |      p_capture_input_rec      IN
 |         This parameter is for capturing all the information that is required
 |         to send to iPayment for Capture.
 |
 |      x_capture_output_rec     OUT
 |        This is the output record and comprises of the output record
 |        returned by iPayment API IBY_Payment_Adapter_pub.CaptureResp_rec_type
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-MAR-2004           Jyoti Pandey      Created
 |
 *=======================================================================*/
 PROCEDURE Capture_payment (
  p_receipt_info_rec IN receipt_info_rec,
  p_capture_input_rec        IN capture_input_rec,
  x_capture_output_rec       OUT NOCOPY capture_output_rec,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2) IS

   /*-----------------------------------------------------------------------+
   | Cursor Declarations                                                    |
   +-----------------------------------------------------------------------*/

   CURSOR iby_trxn_id_cur(l_payment_server_order_num IN VARCHAR2) IS
   SELECT DISTINCT transactionid
   FROM iby_trans_all_v
   WHERE tangibleid = l_payment_server_order_num;

  /*-----------------------------------------------------------------------+
   | Local Variable Declarations and initializations                       |
   +-----------------------------------------------------------------------*/

  l_capturetrxn_rec     IBY_Payment_Adapter_pub.CaptureTrxn_rec_type;
  l_capresp_rec         IBY_Payment_Adapter_pub.CaptureResp_rec_type;
  iby_trxn_id		NUMBER;

  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('AR_PMT_PROCESS_WRAPPER.Capture_Payment(+)');
  END IF;

  --get the trx_id
   IF p_capture_input_rec.payment_server_order_num IS NOT NULL THEN
      OPEN iby_trxn_id_cur(p_capture_input_rec.payment_server_order_num);
       FETCH iby_trxn_id_cur INTO iby_trxn_id;
          IF iby_trxn_id_cur%NOTFOUND then
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Process_Credit_Card: ' ||
                                'PSON passed is Invalid..Need to re-authorize');
              END IF;
              l_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;

          END IF;
          CLOSE iby_trxn_id_cur;

      IF iby_trxn_id is not null then

         l_capturetrxn_rec.Trxn_ID := iby_trxn_id;
         l_capturetrxn_rec.currency := p_capture_input_rec.currency_code;
         l_capturetrxn_rec.price :=    p_capture_input_rec.receipt_amount;
         l_capturetrxn_rec.TrxnRef :=  p_capture_input_rec.TrxnRef;
         l_capturetrxn_rec.PmtMode := 'ONLINE';

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Calling OraPmtReq');
            arp_standard.debug('l_capturetrxn_rec.Trxn_ID: '||
                                l_capturetrxn_rec.Trxn_ID);
            arp_standard.debug('l_capturetrxn_rec.currency: '||
                                l_capturetrxn_rec.currency);
            arp_standard.debug('l_capturetrxn_rec.price: ' ||
                                to_char(l_capturetrxn_rec.price) );
            arp_standard.debug('l_capturetrxn_rec.TrxnRef: ' ||
                                l_capturetrxn_rec.TrxnRef );
            arp_standard.debug('l_capturetrxn_rec.PmtMode: ' ||
                                l_capturetrxn_rec.PmtMode );
         END IF;

         IBY_Payment_Adapter_pub.OraPmtCapture(
           p_api_version        => 1.0,
           p_init_msg_list      => FND_API.G_FALSE,
           p_commit             => FND_API.G_FALSE,
   	       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
	       p_ecapp_id           => 222,  -- AR product id
           x_return_status      => l_return_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data,
           p_capturetrxn_rec    => l_capturetrxn_rec,
           x_capresp_rec        => l_capresp_rec);

          --Asssign the values to OUT Parameters
          x_return_status       := l_return_status;
          x_msg_count           := l_msg_count;
          x_msg_data            := l_msg_data;
          x_capture_output_rec.x_capresp_rec := l_capresp_rec;

	    IF PG_DEBUG in ('Y', 'C') THEN
	        arp_standard.debug(  '-------------------------------------');
            arp_standard.debug(  'x_return_status: ' || x_return_status);
            arp_standard.debug(  'l_capresp_rec.response.errcode: ' || l_capresp_rec.response.errcode);
            arp_standard.debug(  'l_capresp_rec.response.errmessage: ' || l_capresp_rec.response.errmessage);
            arp_standard.debug(  'l_capresp_rec.errorlocation: ' || l_capresp_rec.errorlocation);
            arp_standard.debug(  'l_capresp_rec.beperrcode: ' || l_capresp_rec.beperrcode);
            arp_standard.debug(  'l_capresp_rec.beperrmessage: ' || l_capresp_rec.beperrmessage);
            arp_standard.debug(  'NVL(l_capresp_rec.response.status,0): ' || to_char(NVL(l_capresp_rec.response.status,0)));
            arp_standard.debug(  'PmtInstr_Type: ' || l_capresp_rec.PmtInstr_Type);
            arp_standard.debug(  'Trxn ID: ' || l_capresp_rec.Trxn_ID);
            arp_standard.debug(  '-------------------------------------');

	    END IF;


        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.set_name('AR', 'AR_CC_CAPTURE_FAILED');
          FND_MSG_PUB.Add;
          x_return_status := l_return_status;
          RETURN;
        END IF;

      END IF;

  END IF; --pson not null


  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('AR_PMT_PROCESS_WRAPPER.Capture_Payment(-)');
  END IF;
end;

end AR_PMT_PROCESS_WRAPPER;

/

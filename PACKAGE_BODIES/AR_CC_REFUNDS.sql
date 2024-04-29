--------------------------------------------------------
--  DDL for Package Body AR_CC_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CC_REFUNDS" AS
/* $Header: ARCCRFDB.pls 120.17 2005/09/14 10:53:48 sgnagara ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE handle_exception (
     p_return_status in varchar2,
     p_msg_count in number,
     p_vend_err_mesg in out NOCOPY varchar2,
     p_context in varchar2) IS

v_msg_data varchar2(2000);
v_msg_index_out number;
v_error varchar2(2000);
v_error_description varchar2(4000);

BEGIN


/*
 FOR i in 1..p_msg_count loop
   v_error := fnd_msg_pub.get(i);
   v_error_description := v_error_description || ':' || v_error;
 END LOOP;
*/

  IF p_vend_err_mesg IS NULL THEN
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS then
      IF (FND_MSG_PUB.Count_Msg > 1) then
        -- More than one error message
        FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
          FND_MSG_PUB.Get(
               p_msg_index=>j,
               p_encoded=>'F',
               p_data=>v_msg_data,
               p_msg_index_out=>v_msg_index_out);
          v_error_description := v_error_description || ':' || v_msg_data;
        END LOOP;
      ELSE
        -- Only one error message
        FND_MSG_PUB.Get(
              p_msg_index=>1,
              p_encoded=>'F',
              p_data=>v_msg_data,
              p_msg_index_out=>v_msg_index_out);
        v_error_description := v_error_description || v_msg_data;
      END IF;
    --  p_vend_err_mesg := p_context || ' ' ||v_error_description;
    END IF;
    p_vend_err_mesg := substr(p_context || ' ' ||v_error_description, 1, 240);
  ELSE
    p_vend_err_mesg := substr(p_context || ' ' ||p_vend_err_mesg, 1, 240);
  END IF;


END handle_exception;

PROCEDURE process_refund(
                      cc_currency IN VARCHAR2,
                      cc_price IN VARCHAR2,
                      cc_pay_server_order_num IN OUT NOCOPY VARCHAR2,
		      cc_unique_reference IN VARCHAR2,
                      cc_merchant_id IN VARCHAR2,
                      cc_pmt_instr_id IN VARCHAR2,
                      cc_pmt_instr_exp IN VARCHAR2,
                      cc_status_code IN OUT NOCOPY VARCHAR2,
                      cc_statusmsg IN OUT NOCOPY VARCHAR2,
                      cc_err_location IN OUT NOCOPY VARCHAR2,
                      cc_vend_err_code IN OUT NOCOPY VARCHAR2,
                      cc_vend_err_mesg IN OUT NOCOPY VARCHAR2,
                      cc_return_status IN OUT NOCOPY VARCHAR2,
                      cc_cash_receipt_id IN VARCHAR2 DEFAULT NULL
                        ) IS

p_api_version		NUMBER := 1.0;
p_init_msg_list		VARCHAR2(2000) := FND_API.G_FALSE;
p_commit		VARCHAR2(30) := FND_API.G_FALSE;
p_validation_level	NUMBER := FND_API.G_VALID_LEVEL_FULL;
p_ecapp_id		NUMBER := 222;

cc_status               VARCHAR2(2000);
x_msg_count	        NUMBER;   /* output message count */
x_msg_data		VARCHAR2(2000);  /* reference string for
                                            output message text  */
cc_iby_trxn_id		NUMBER;
cc_iby_trxn_pson	VARCHAR2(50);

/* Records for Credit Card Payment Return */
cc_returntrxn_rec	iby_payment_adapter_pub.returntrxn_rec_type;
cc_returnresp_rec 	iby_payment_adapter_pub.returnresp_rec_type;

/* Records for Credit Card Payment Credit */

cc_payee_rec         	iby_payment_adapter_pub.Payee_rec_type ;
cc_pmtinstr_rec   	iby_payment_adapter_pub.PmtInstr_rec_type ;
cc_tangible_rec      	iby_payment_adapter_pub.Tangible_rec_type ;
cc_credittrxn_rec 	iby_payment_adapter_pub.CreditTrxn_rec_type ;
cc_creditresp_rec 	iby_payment_adapter_pub.CreditResp_rec_type ;


CURSOR cc_iby_trxn_id_cur IS
        SELECT DISTINCT transactionid
         FROM iby_trans_all_v
        WHERE tangibleid = cc_pay_server_order_num;

/* Added for Bug 3646482 */

CURSOR cc_iby_dup_cur IS
        SELECT DISTINCT tangibleid
        FROM iby_trans_all_v
        WHERE trxnref = cc_unique_reference
        AND reqtype = 'ORAPMTCREDIT';

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        fnd_file.put_line(FND_FILE.LOG, 'ar_cc_refunds.process_refund()+');
     END IF;

     /* Assign the input parameter to global variable **/
     g_cash_receipt_id := cc_cash_receipt_id;
     /* Print input parameters */
/* bug3771406 */
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_file.write_log('Cash Receipt Id : [' || cc_cash_receipt_id ||']');
        arp_file.write_log('g_cash_receipt_id :[' || g_cash_receipt_id ||']');
        arp_file.write_log('PSON :[' || cc_pay_server_order_num ||']');
        arp_file.write_log('cc_currency : [' || cc_currency ||']');
        arp_file.write_log('cc_merchant_id :[' || cc_merchant_id ||']');
        arp_file.write_log('cc_pmt_instr_id :[' || substrb(cc_pmt_instr_id,1,4) ||']');
        arp_file.write_log('cc_pmt_instr_exp :[' || cc_pmt_instr_exp ||']');
     END IF;
     /* FETCH iPayment Transactionid */

     OPEN cc_iby_trxn_id_cur;
     FETCH cc_iby_trxn_id_cur INTO cc_iby_trxn_id;

     IF cc_iby_trxn_id_cur%NOTFOUND then
        /* return error conditions */
        cc_vend_err_code := '1 PMT-TRXN ERR';
        cc_vend_err_mesg := 'Error in In getting trxn_id';
        Return;
     END IF;

     CLOSE cc_iby_trxn_id_cur;

     /* BEGIN Credit Card Payment Return */

      /* ASSIGN Values to Payment Return Api Record Variables */


      cc_returntrxn_rec.trxn_id          := TO_NUMBER(cc_iby_trxn_id);
      cc_returntrxn_rec.pmtmode          := 'ONLINE';
      cc_returntrxn_rec.settlement_date  := NULL;
      cc_returntrxn_rec.currency         := cc_currency ;
      cc_returntrxn_rec.price            := ABS(cc_price) ;
      cc_returntrxn_rec.nls_lang         := NULL;
      cc_returntrxn_rec.TrxnRef		 := cc_unique_reference;

      IF PG_DEBUG in ('Y', 'C') THEN
      	arp_file.write_log('Calling iby_payment_adapter_pub.OraPmtReturn()+..');
      END IF;

      /* Call Payment return API */
      BEGIN
          iby_payment_adapter_pub.orapmtreturn (
              p_api_version             =>      p_api_version
             ,p_init_msg_list           =>      p_init_msg_list
             ,p_commit                  =>      p_commit
             ,p_validation_level        =>      p_validation_level
             ,p_ecapp_id                =>      p_ecapp_id
             ,p_returntrxn_rec          =>      cc_returntrxn_rec
             ,x_return_status           =>      cc_return_status
             ,x_msg_count               =>      x_msg_count
             ,x_msg_data                =>      x_msg_data
             ,x_retresp_rec             =>      cc_returnresp_rec );


      cc_status            :=   cc_returnresp_rec.response.status;
      cc_status_code       :=   cc_returnresp_rec.response.errcode;
      cc_statusmsg         :=   cc_returnresp_rec.response.errmessage;

      cc_err_location   :=      cc_returnresp_rec.errorlocation;
      cc_vend_err_code  :=      cc_returnresp_rec.beperrcode;
      cc_vend_err_mesg  :=      cc_returnresp_rec.beperrmessage;

      EXCEPTION
         WHEN OTHERS THEN
            cc_vend_err_code := '2 PMT-RETURN ERR';
            -- cc_vend_err_mesg := 'Error in Return api';
            handle_exception(cc_return_status,
                             x_msg_count,
                             cc_vend_err_mesg,
                             'Exception in Return api: ');
            Return;
      END;
	IF PG_DEBUG in ('Y', 'C') THEN
        	arp_file.write_log('OraPmtReturn return status..'||cc_return_status);
		arp_file.write_log('OraPmtReturn status code..'||cc_status_code);
		arp_file.write_log('iby_payment_adapter_pub.OraPmtReturn()-');
        END IF;

      /*  Check the return status.  An S means Success.  If it failed
          when need to check the status code as you can only give a
          refund once per PSON (Payment Server Order Number).  Any
          additional refund must be treated as a Credit and given its
          own PSON number */

      /* Bug 2503608 - Removed the ELSE part of the IF statement
         which was going to error even if it is success.*/

      /* Bug 2777278 - Included error codes IBY_0002, 20604
         and 50308 for duplicate refunds */

      /* bug 3646482. IBY_20402 error has to be treated as success in AR side */
      IF cc_return_status <> 'S' THEN
	IF  cc_status_code = 'IBY_20402' THEN
                cc_return_status := 'S';
                RETURN;
        ELSIF  cc_status_code = 'IBY_204460' OR
            cc_status_code = 'IBY_0002'   OR
            cc_status_code = 'IBY_20604'  OR
            cc_status_code = 'IBY_50308'
        THEN
          /* we need to begin the CREDIT process instead of REFUND */
	 IF PG_DEBUG in ('Y', 'C') THEN
                arp_file.write_log('We need to begin the CREDIT process instead of REFUND ');
	 END If;

          /* Clear out NOCOPY variable used in Refund Call */
          cc_return_status 	:= NULL;
          cc_status 		:= NULL;
          cc_status_code 	:= NULL;
          cc_statusmsg		:= NULL;
	  cc_err_location	:= NULL;
	  cc_vend_err_code	:= NULL;
	  cc_vend_err_mesg	:= NULL;

	  cc_iby_trxn_pson := null;

          /* since we need a new PSON number, we also need to clear that
             out NOCOPY and retrieve a new one */
          cc_pay_server_order_num	:= NULL;

	  OPEN cc_iby_dup_cur;
          FETCH cc_iby_dup_cur INTO cc_iby_trxn_pson;

	  IF cc_iby_trxn_pson is not null THEN
                cc_pay_server_order_num := cc_iby_trxn_pson;
		IF PG_DEBUG in ('Y', 'C') THEN
                	arp_file.write_log('Corrected PSON is..'||cc_pay_server_order_num);
          	END IF;

	  ELSIF cc_iby_dup_cur%NOTFOUND THEN

            SELECT 'AR_'||ar_payment_server_ord_num_s.nextval
            INTO cc_pay_server_order_num
            FROM DUAL;
	    IF PG_DEBUG in ('Y', 'C') THEN
                arp_file.write_log('Generated PSON is..'||cc_pay_server_order_num);
            END IF;
	  END IF;

          /* ASSIGN Values to Credit Card Credit Api Record Variables */

          cc_payee_rec.payee_id                         	:= cc_merchant_id;

         /*  cc_pmtinstr_rec.creditcardinstr.cc_num        	:= cc_pmt_instr_id;  Bug-4606039 */
          -- Bugfix 2976396.
	  /* Follwing statement commented for bug 3646482. ADD_MONTHS returns INVALID MONTH error. Next statement is added instead. */
         /* cc_pmtinstr_rec.creditcardinstr.cc_expdate 	:= ADD_MONTHS(to_date(cc_pmt_instr_exp, 'MM/YYYY'),1) -1 ; */
          /* Bug-4606039
	  cc_pmtinstr_rec.creditcardinstr.cc_expdate := last_day(to_date(cc_pmt_instr_exp,'DD-MM-YY')); */

          cc_tangible_rec.tangible_id           := cc_pay_server_order_num;
          cc_tangible_rec.tangible_amount       := ABS(cc_price);
          cc_tangible_rec.currency_code         := cc_currency;

          cc_credittrxn_rec.pmtmode     := 'ONLINE' ;
	  cc_credittrxn_rec.TrxnRef     := cc_unique_reference;

	  IF PG_DEBUG in ('Y', 'C') THEN
		arp_file.write_log('Calling iby_payment_adapter_pub.OraPmtCredit()+...');
	  END IF;

          /* Call Credit API */
            iby_payment_adapter_pub.OraPmtCredit (
                 p_api_version             =>      p_api_version
                ,p_init_msg_list           =>      p_init_msg_list
                ,p_commit          	   =>      p_commit
                ,p_validation_level        =>      p_validation_level
                ,p_ecapp_id                =>      p_ecapp_id
                ,p_payee_rec               =>      cc_payee_rec
                ,p_pmtinstr_rec    	   =>      cc_pmtinstr_rec
                ,p_tangible_rec            =>      cc_tangible_rec
                ,p_credittrxn_rec  	   =>      cc_credittrxn_rec
                ,x_return_status  	   =>      cc_return_status
                ,x_msg_count               =>      x_msg_count
                ,x_msg_data                =>      x_msg_data
                ,x_creditresp_rec  	   =>      cc_creditresp_rec
                 );

             cc_status             := cc_creditresp_rec.response.status;
             cc_status_code        := cc_creditresp_rec.response.errcode;
             cc_statusmsg          := cc_creditresp_rec.response.errmessage;

             cc_err_location    := cc_creditresp_rec.errorlocation;
             cc_vend_err_code   := cc_creditresp_rec.beperrcode;
             cc_vend_err_mesg   := cc_creditresp_rec.beperrmessage;


             /* Bug 2976396. Modified Exceptions block into IF clause
		since the api orapmtcredit does not throw any exception.
	      */
	     /* Following condition added for bug 3646482. IBY_20402 has to be treated as success */

	     IF (cc_return_status <> FND_API.G_RET_STS_SUCCESS) AND (cc_status_code = 'IBY_20402') THEN
		IF PG_DEBUG in ('Y', 'C') THEN
        		arp_file.write_log('OraPmtCredit API returned status code..'||cc_status_code);
     		END IF;
		cc_return_status := FND_API.G_RET_STS_SUCCESS;
		RETURN;
	     END IF;

	     IF (cc_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

                   IF( cc_vend_err_code IS NULL) THEN
                      cc_vend_err_code := '3 PMT-RETURN ERR';  /* bug4220521 */
                      cc_vend_err_mesg := 'Error in Return api';
                   END IF;

                   handle_exception(cc_return_status,
                             x_msg_count,
                                    cc_vend_err_mesg,
                                    'Exception in Credit api: ');
                   Return;
	     END IF;
	    IF PG_DEBUG in ('Y', 'C') THEN
		arp_file.write_log('iby_payment_adapter_pub.OraPmtCredit()-');
	    END IF;
         ELSE
                   IF( cc_vend_err_code IS NULL) THEN
                      cc_vend_err_code := '4 PMT-RETURN ERR';  /* bug4220521 */
                      cc_vend_err_mesg := 'Error in Return api';
                   END IF;

             handle_exception(cc_return_status,
                             x_msg_count,
                              cc_vend_err_mesg,
                              'Error in Return api (' || cc_status_code || '): ');
             Return;
         END IF;

      END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        fnd_file.put_line(FND_FILE.LOG, 'ar_cc_refunds.process_refund()+');
     END IF;

END process_refund;

END;

/

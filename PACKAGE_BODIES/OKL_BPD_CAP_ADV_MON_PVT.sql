--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CAP_ADV_MON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CAP_ADV_MON_PVT" AS
 /* $Header: OKLRAMSB.pls 120.5 2007/08/02 07:08:50 dcshanmu noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

---------------------------------------------------------------------------
-- PROCEDURE handle_advanced_manual_pay
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_advanced_manual_pay
  -- Description     : procedure for inserting the records in
  --                   table OKL_TRX_CSH_RECEIPT_B and OKL_EXT_CSH_RCPTS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status,
  --                   x_msg_count, x_msg_data, p_adv_rcpt_rec, x_adv_rcpt_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE handle_advanced_manual_pay ( p_api_version		        IN  NUMBER,
  				                                 p_init_msg_list	       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
					                                  x_return_status	       OUT NOCOPY VARCHAR2,
				                                   x_msg_count		          OUT NOCOPY NUMBER,
				                                   x_msg_data	            OUT NOCOPY VARCHAR2,
                                       p_adv_rcpt_rec	        IN adv_rcpt_rec,
					                                  x_adv_rcpt_rec         OUT NOCOPY adv_rcpt_rec ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  lp_adv_rcpt_rec			            adv_rcpt_rec := p_adv_rcpt_rec;

  l_customer_id			              OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT lp_adv_rcpt_rec.customer_id;
  l_customer_num		              AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT lp_adv_rcpt_rec.customer_num;

  l_contract_id			              OKC_K_HEADERS_V.ID%TYPE DEFAULT lp_adv_rcpt_rec.contract_id;
  l_last_contract_id		   	      OKC_K_HEADERS_V.ID%TYPE DEFAULT 1;
  l_contract_num		              OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT lp_adv_rcpt_rec.contract_num;
  l_contract_number_start_date		OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
  l_contract_number_id			       OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  --
  l_currency_conv_type			       OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT lp_adv_rcpt_rec.currency_conv_type;
  l_currency_conv_date			       OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT lp_adv_rcpt_rec.currency_conv_date;
  l_currency_conv_rate		       	OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT lp_adv_rcpt_rec.currency_conv_rate;
  --
  l_conversion_rate			          GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_conversion_rate		GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_inverse_conversion_rate		   GL_DAILY_RATES_V.INVERSE_CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_currency		      	OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_invoice_currency_code		     OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_receipt_currency_code	     	OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT lp_adv_rcpt_rec.currency_code;
  l_irm_id			                   OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT lp_adv_rcpt_rec.irm_id;      -- receipt method id
  l_check_number		              OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT lp_adv_rcpt_rec.check_number;
  l_rcpt_amount			              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT lp_adv_rcpt_rec.rcpt_amount;
  l_rcpt_type			                OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT lp_adv_rcpt_rec.receipt_type;
  l_rcpt_amount_orig		         	OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT lp_adv_rcpt_rec.rcpt_amount;
  l_converted_receipt_amount	  	OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_rcpt_date				               OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT lp_adv_rcpt_rec.receipt_date;
  l_gl_date				                 OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT lp_adv_rcpt_rec.gl_date;
  l_comments				                AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT lp_adv_rcpt_rec.comments;
  l_fully_applied_flag                OKL_TRX_CSH_RECEIPT_V.FULLY_APPLIED_FLAG%TYPE DEFAULT lp_adv_rcpt_rec.fully_applied_flag;
  l_expired_flag                      OKL_TRX_CSH_RECEIPT_V.EXPIRED_FLAG%TYPE DEFAULT lp_adv_rcpt_rec.expired_flag;
  l_cash_receipt_id			          AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_receivables_invoice_num		   NUMBER DEFAULT NULL;

  l_over_pay                     VARCHAR(1) := 'O';
  l_ordered			                  CONSTANT VARCHAR2(3) := 'ODD';
  l_prorate			                  CONSTANT VARCHAR2(3) := 'PRO';
  l_start_date			               DATE;
  l_same_cash_app_rule			       VARCHAR(1) DEFAULT NULL;
  l_same_date				               VARCHAR(1) DEFAULT NULL;
  l_org_id			                  	OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  i				                         NUMBER DEFAULT NULL;
  d					                        NUMBER DEFAULT NULL;
  t					                        NUMBER DEFAULT NULL;
  l_first_prorate_rec			        NUMBER DEFAULT NULL;
  l_order_count				             NUMBER DEFAULT NULL;

  l_appl_tolerance		            NUMBER := 0;
  l_temp_val			                 NUMBER := 0;
  l_inv_tot			                  NUMBER := 0;
  l_cont_tot			                 NUMBER := 0;
  l_stream_tot				              NUMBER := 0;
  l_pro_rate_inv_total	       		NUMBER := 0;

  l_rct_id			                   OKL_TRX_CSH_RECEIPT_B.ID%TYPE;
  l_rca_id			                   OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_xcr_id			                   NUMBER;

  l_dup_rcpt_flag			            NUMBER DEFAULT NULL;
  l_cash_applied_flag			        VARCHAR2(1) DEFAULT NULL;
  l_cont_applic				             VARCHAR2(1) DEFAULT 'N';
  l_cons_bill_applic			         VARCHAR2(1) DEFAULT 'N';

  l_api_version			              NUMBER := 1.0;
  l_init_msg_list		             VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		             VARCHAR2(1);
  l_msg_count			                NUMBER;
  l_msg_data			                 VARCHAR2(2000);

  l_api_name				CONSTANT VARCHAR2(30) := 'handle_advanced_manual_pay';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  l_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  l_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  x_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  x_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  x_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

----------

-- External Trans

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  l_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  t_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;


-------------------
-- DECLARE Cursors
-------------------
-- get a contract id if not known
  CURSOR   c_get_contract_id (cp_contract_num IN VARCHAR2) IS
    SELECT  lpt.contract_id
    FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
    WHERE	lpt.contract_number = cp_contract_num
    AND	    lpt.status = 'OP'
    AND	    lpt.amount_due_remaining > 0
    ORDER BY lpt.start_date;

 -- get org_id for contract
   CURSOR   c_get_org_id (cp_contract_num IN VARCHAR2) IS
   SELECT  authoring_org_id
   FROM   OKC_K_HEADERS_B
   WHERE  contract_number = cp_contract_num;

----------

 -- check for duplicate receipt numbers
   CURSOR   c_dup_rcpt( cp_customer_id IN NUMBER
                       ,cp_check_num IN VARCHAR2
                       ,cp_receipt_date IN DATE
                      ) IS
    SELECT  '1'
    FROM    OKL_TRX_CSH_RECEIPT_V
    WHERE   ile_id = cp_customer_id
    AND     check_number = cp_check_num
    AND     TRUNC(date_effective) = TRUNC(cp_receipt_date);

----------

   -- get header and line id's for contract reference
   CURSOR   c_get_int_id_cont ( cp_customer_id IN NUMBER
                               ,cp_check_num IN VARCHAR2
                               ,cp_amount IN NUMBER
                               ,cp_contract_id IN NUMBER) IS
    SELECT  a.id, b.id
    FROM    OKL_TRX_CSH_RECEIPT_V a, OKL_TXL_RCPT_APPS_V b
    WHERE   a.id = b.rct_id_details
    AND     a.ile_id = cp_customer_id
    AND     a.check_number = cp_check_num
    AND     a.amount = cp_amount
    AND     b.khr_id = NVL(cp_contract_id, NULL);

----------

 -- get bank details
    CURSOR   c_get_remit_bnk_dtls ( cp_irm_id IN NUMBER ) IS
    SELECT  bank_name, bank_account_num
    FROM    OKL_BPD_RCPT_MTHDS_UV
    WHERE   receipt_method_id = cp_irm_id;

----------

  --get currency code
    CURSOR l_khr_curr_csr(cp_contract_id IN NUMBER) IS
    SELECT currency_code
    FROM okl_k_headers_full_v
    WHERE id = cp_contract_id;

    l_currency_code okl_k_headers_full_v.currency_code%type;

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_functional_currency := okl_accounting_util.get_func_curr_code;


   IF  (lp_adv_rcpt_rec.contract_id IS NOT NULL) THEN

     OPEN c_get_org_id(l_contract_num);
     FETCH c_get_org_id into l_org_id;
     CLOSE c_get_org_id;

     OPEN l_khr_curr_csr(lp_adv_rcpt_rec.contract_id);
     FETCH l_khr_curr_csr INTO l_currency_code;
     CLOSE l_khr_curr_csr;

      IF  (l_currency_code <> lp_adv_rcpt_rec.currency_code) THEN
          OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_KHR_CURR_ERROR');

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END IF;

   OPEN  c_dup_rcpt(l_customer_id, l_check_number, TRUNC(l_rcpt_date));
   FETCH c_dup_rcpt INTO l_dup_rcpt_flag;
   CLOSE c_dup_rcpt;

   IF l_dup_rcpt_flag = 1 THEN
     -- Message Text: Duplicate receipt number for customer
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.set_message( p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_BPD_DUP_RECEIPT');

      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 -- If invoice currency code is not equal to the receipt currency code and the conversion tye
  -- is not specified then display the error.
   IF  l_functional_currency <> l_receipt_currency_code AND l_currency_conv_type IN ('NONE') THEN

  -- Message Text: Please enter a currency type.
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');

        RAISE G_EXCEPTION_HALT_VALIDATION;

   END IF;

   IF  l_functional_currency = l_receipt_currency_code THEN
        IF l_currency_conv_type IN ('CORPORATE', 'SPOT', 'USER') OR l_currency_conv_rate <> '0' THEN

  -- Message Text: Currency conversion values are not required when the receipt and invoice currency's are the same.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name => G_APP_NAME,
            p_msg_name  => 'OKL_BPD_SAME_CURRENCY');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

   END IF;

  -- If invoice currency code is not equal to the receipt currency code and currency conversion type is not 'USER'....
   IF  l_functional_currency <> l_receipt_currency_code AND l_currency_conv_type NOT IN ('USER') THEN

        IF l_currency_conv_date IS NULL OR l_currency_conv_date = '' THEN
            l_currency_conv_date := l_rcpt_date;
        END IF;

        IF l_currency_conv_type = 'CORPORATE' THEN
            l_currency_conv_type := 'Corporate';
        ELSE
            l_currency_conv_type := 'Spot';
        END IF;

        l_functional_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                              ,l_functional_currency
	                                                                             ,l_currency_conv_date
	                                                                             ,l_currency_conv_type
                                                                              );

        l_inverse_conversion_rate := okl_accounting_util.get_curr_con_rate( l_functional_currency
                                                                           ,l_receipt_currency_code
	                                                                          ,l_currency_conv_date
	                                                                          ,l_currency_conv_type
                                                                           );

       IF  l_functional_conversion_rate IN (0,-1) THEN

 -- Message Text: No exchange rate defined
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');

       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

        l_currency_conv_rate := l_functional_conversion_rate;

   ELSIF  l_functional_currency <> l_receipt_currency_code AND l_currency_conv_type IN ('USER') THEN

        IF  l_currency_conv_rate IS NULL OR l_currency_conv_rate = '0' THEN

  -- Message Text: No exchange rate defined for currency conversion type USER.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_USR_RTE_SUPPLIED');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        ELSE

            l_functional_conversion_rate := l_currency_conv_rate;
            l_inverse_conversion_rate := l_functional_conversion_rate / 1;

        END IF;

        l_currency_conv_type := 'User';
        l_currency_conv_date := SYSDATE;

   ELSE
        -- no currency conversion required
        l_currency_conv_date := NULL;
        l_currency_conv_type := NULL;
        l_currency_conv_rate := NULL;

   END IF;

   IF  l_rcpt_amount = 0 OR l_rcpt_amount IS NULL THEN
-- Message Text: The receipt cannot have a value of zero
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name      => G_APP_NAME,
                            p_msg_name      => 'OKL_BPD_ZERO_RECEIPT');

       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


-- Create record in Internal Transaction Table.

	-- CREATE HEADER REC

  	l_rctv_rec.IRM_ID		        	:= l_irm_id;
  	l_rctv_rec.ILE_ID		       	    := l_customer_id;
    l_rctv_rec.CHECK_NUMBER	            := l_check_number;
    l_rctv_rec.AMOUNT		        	:= l_rcpt_amount_orig;          -- in receipt amount
	l_rctv_rec.CURRENCY_CODE		    := l_receipt_currency_code;     -- entered currency

    l_rctv_rec.EXCHANGE_RATE		    := l_currency_conv_rate;
  	l_rctv_rec.EXCHANGE_RATE_TYPE		:= l_currency_conv_type;
	l_rctv_rec.EXCHANGE_RATE_DATE		:= l_currency_conv_date;

    l_rctv_rec.DATE_EFFECTIVE		    := l_rcpt_date;
	l_rctv_rec.GL_DATE			        := l_gl_date;
	l_rctv_rec.ORG_ID		           	:= l_org_id;
	l_rctv_rec.RECEIPT_TYPE		     	:= l_rcpt_type;

    i := 1;

    IF(l_expired_flag = 'Y') THEN
      l_rcav_tbl(i).KHR_ID          := l_contract_id;
      l_rcav_tbl(i).ILE_ID          := l_customer_id;
      l_rcav_tbl(i).AMOUNT          := l_rcpt_amount_orig;
      l_rcav_tbl(i).ORG_ID          := l_org_id;
    END IF;
  -- This procedure will insert the records in internal transaction table OKL_TRX_CSH_RECEIPT_B.
    Okl_Rct_Pub.create_internal_trans (l_api_version
			    		       ,l_init_msg_list
				    	       ,l_return_status
				    	       ,l_msg_count
				    	       ,l_msg_data
					           ,l_rctv_rec
					           ,l_rcav_tbl
    					       ,x_rctv_rec
	    				       ,x_rcav_tbl);

   IF  (IS_DEBUG_PROCEDURE_ON) THEN
       BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Rct_Pub.create_internal_trans  ');
       END;
   END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

        l_rct_id := x_rctv_rec.ID;

  	-- Internal Record created.

    --  **************************************************
    --  Contract level cash application processing BEGINS
    --  **************************************************

   IF  l_contract_num IS NOT NULL THEN -- (1)
       l_cont_applic := 'Y';

       IF  l_contract_id IS NULL THEN
           OPEN c_get_contract_id(l_contract_num);
           FETCH c_get_contract_id INTO l_contract_id;
           CLOSE c_get_contract_id;
        END IF;

   END IF;

-- Create record in External Transaction Table.

 -- CREATE HEADER REC

 -- obtain remittance bank details.
/*
    OPEN c_get_remit_bnk_dtls(l_irm_id);
    FETCH c_get_remit_bnk_dtls
    INTO l_xcrv_rec.REMITTANCE_BANK_NAME
	        ,l_xcrv_rec.ACCOUNT;
    CLOSE c_get_remit_bnk_dtls;

    l_xcrv_rec.RCT_ID		          := l_rct_id;
    l_xcrv_rec.CHECK_NUMBER	     := l_check_number;
    l_xcrv_rec.RECEIPT_METHOD        := NULL;  -- prefer IRM_ID !
    l_xcrv_rec.RECEIPT_DATE	         := l_rcpt_date;
    l_xcrv_rec.RECEIPT_TYPE	         := l_rcpt_type;
    l_xcrv_rec.GL_DATE               := l_gl_date;
    l_xcrv_rec.CURRENCY_CODE	     := l_receipt_currency_code;

-- store the functional currency at header lvl

   IF  l_receipt_currency_code <> l_functional_currency THEN

        l_xcrv_rec.EXCHANGE_RATE_TYPE   := l_currency_conv_type;
        l_xcrv_rec.EXCHANGE_RATE_DATE   := l_currency_conv_date;
        l_xcrv_rec.ATTRIBUTE1           := l_functional_conversion_rate;
         -- in functional currency ...
   END IF;

   IF  l_receipt_currency_code         <>  l_invoice_currency_code THEN
       l_xcrv_rec.EXCHANGE_RATE        :=  l_conversion_rate;
       l_xcrv_rec.REMITTANCE_AMOUNT    :=  l_converted_receipt_amount;
 -- in transaction currency ...
   ELSE
       l_xcrv_rec.REMITTANCE_AMOUNT    := l_rcpt_amount_orig;
       -- in receipt currency ...
   END IF;

    l_xcrv_rec.CUSTOMER_NUMBER	        := l_customer_num;
    l_xcrv_rec.COMMENTS                := l_comments;
    l_xcrv_rec.ORG_ID                  := l_org_id;
    l_xcrv_rec.fully_applied_flag      := l_fully_applied_flag;
    l_xcrv_rec.expired_flag            := l_expired_flag;

   -- Start of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.create_ext_ar_txns
   IF  (IS_DEBUG_PROCEDURE_ON) THEN
       BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Xcr_Pub.create_ext_ar_txns  ');
       END;
   END IF;

  -- This procedure will insert the records in external transaction table OKL_EXT_CSH_RCPTS_B.
  Okl_Xcr_Pub.create_ext_ar_txns( l_api_version
  		                          ,l_init_msg_list
  	                              ,l_return_status
				                  ,l_msg_count
			    	              ,l_msg_data
				                  ,l_xcrv_rec
				                  ,l_xcav_tbl
				                  ,x_xcrv_rec
				                  ,x_xcav_tbl
                                 );

   IF  (IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
    OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Xcr_Pub.create_ext_ar_txns  ');
    END;
   END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.create_ext_ar_txns

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
 -- CREATE RECEIPT IN AR ONCE EVERYTHING IS OKAY AT THIS POINT

    okl_cash_receipt.CASH_RECEIPT     (p_api_version      => l_api_version
                                      ,p_init_msg_list    => l_init_msg_list
                                      ,x_return_status    => l_return_status
                                      ,x_msg_count        => l_msg_count
                                      ,x_msg_data         => l_msg_data
                                      ,p_over_pay         => l_over_pay
                                      ,p_conc_proc        => NULL
                                      ,p_xcrv_rec         => l_xcrv_rec
                                      ,p_xcav_tbl         => l_xcav_tbl
                                      ,x_cash_receipt_id  => l_cash_receipt_id
                                      );

    x_return_status := l_return_status;

	   IF  x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

 -- Message Text: Error creating receipt in AR
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_ERR_CRT_RCT_AR');
        RAISE G_EXCEPTION_HALT_VALIDATION;

	    END IF;

 -- UPDATE EXT HEADER WITH CASH RECEIPT ID
/*
     SELECT ID INTO l_xcr_id
     FROM   okl_ext_csh_rcpts_b
     WHERE  rct_id = l_rct_id;

     l_rctv_rec.id := l_xcr_id;
*/
     l_rctv_rec := x_rctv_rec;
     l_rctv_rec.cash_receipt_id := l_cash_receipt_id;
     l_rctv_rec.fully_applied_flag      := l_fully_applied_flag;
     l_rctv_rec.expired_flag            := l_expired_flag;

--     l_xcrv_rec.attribute1   := NULL;

   	 x_adv_rcpt_rec := lp_adv_rcpt_rec;
--     x_adv_rcpt_rec.rct_id := l_rct_id;
--     x_adv_rcpt_rec.xcr_id := l_xcr_id;
     x_adv_rcpt_rec.icr_id := l_cash_receipt_id;

-- Start of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.update_ext_csh_txns
   IF (IS_DEBUG_PROCEDURE_ON) THEN
       BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Rct_Pub.update_internal_trans ');
       END;
   END IF;

  -- Updates the record in the external transactiion table OKL_EXT_CSH_RCPTS_B.
/*   Okl_Xcr_Pub.update_ext_csh_txns( p_api_version
                                    ,p_init_msg_list
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data
                                    ,l_xcrv_rec
                                    ,x_xcrv_rec
                                  );
*/
    Okl_Rct_Pub.update_internal_trans (l_api_version
			    		       ,l_init_msg_list
				    	       ,l_return_status
				    	       ,l_msg_count
				    	       ,l_msg_data
					           ,l_rctv_rec
					           ,l_rcav_tbl
    					       ,x_rctv_rec
	    				       ,x_rcav_tbl);

   IF  (IS_DEBUG_PROCEDURE_ON) THEN
       BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Rct_Pub.update_internal_trans ');
       END;
   END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.update_ext_csh_txns

       x_return_status := l_return_status;
       x_msg_data      := l_msg_data;
       x_msg_count     := l_msg_count;

   IF     (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF  (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_EXCEPTION_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END handle_advanced_manual_pay;
END OKL_BPD_CAP_ADV_MON_PVT;

/

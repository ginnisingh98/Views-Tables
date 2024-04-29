--------------------------------------------------------
--  DDL for Package Body OKL_UPDT_CASH_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UPDT_CASH_DTLS" AS
/* $Header: OKLRCUPB.pls 120.5 2007/08/02 07:11:24 dcshanmu noship $ */

---------------------------------------------------------------------------
-- PROCEDURE update_cash_details
---------------------------------------------------------------------------

PROCEDURE update_cash_details ( p_api_version	   IN  NUMBER
		                       ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status    OUT NOCOPY VARCHAR2
				               ,x_msg_count	       OUT NOCOPY NUMBER
				               ,x_msg_data	       OUT NOCOPY VARCHAR2
                               ,p_strm_tbl         IN  okl_cash_dtls_tbl_type
                               ,x_strm_tbl         OUT NOCOPY okl_cash_dtls_tbl_type
    					       ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_strm_tbl                 okl_cash_dtls_tbl_type;

  l_lsm_id                   OKL_TXL_RCPT_APPS_B.LSM_ID%TYPE;
  l_rca_id                   OKL_TXL_RCPT_APPS_B.ID%TYPE DEFAULT NULL;
  l_rct_id_details           OKL_TXL_RCPT_APPS_B.RCT_ID_DETAILS%TYPE DEFAULT NULL;
  l_xcr_id_details           NUMBER DEFAULT NULL;
  l_cnr_id                   OKL_TXL_RCPT_APPS_B.CNR_ID%TYPE DEFAULT NULL;     -- consolidated bill id
  l_khr_id                   OKL_TXL_RCPT_APPS_B.KHR_ID%TYPE DEFAULT NULL;     -- contract id


  l_cash_receipt_id          AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;

  l_conversion_rate          AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE%TYPE DEFAULT NULL;

  l_rcpt_amount              OKL_TRX_CSH_RECEIPT_B.AMOUNT%TYPE DEFAULT NULL;
  l_rcpt_currency_code       OKL_TRX_CSH_RECEIPT_B.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_func_rcpt_amount         AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE DEFAULT NULL;
  l_func_currency_code       AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_total_amount_applied     AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE;


  l_over_pay                 VARCHAR(1) DEFAULT NULL;
  l_conc_proc                VARCHAR(2) DEFAULT 'NN';
  l_over_payment_code        OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE;

  i                          NUMBER DEFAULT NULL;
  j                          NUMBER DEFAULT NULL;

  l_api_version			     NUMBER := 1.0;
  l_init_msg_list	    	 VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		     VARCHAR2(1);
  l_msg_count		    	 NUMBER;
  l_msg_data	    		 VARCHAR2(2000);

  l_api_name                 CONSTANT VARCHAR2(30) := 'update_cash_details';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

-------------------
-- DECLARE Cursors
-------------------

   CURSOR c_ovr_pay_alloc_code IS
     SELECT OVER_PAYMENT_ALLOCATION_CODE
     FROM   OKL_CASH_ALLCTN_RLS;


----------

   -- external line info
   CURSOR c_get_rca_id (cp_xca_id IN NUMBER) IS
     SELECT rca_id, xcr_id_details
     FROM   okl_xtl_csh_apps_v
     WHERE  id = cp_xca_id;

----------

   -- internal line info
   CURSOR c_get_strm_dtls (cp_rca_id IN NUMBER) IS
     SELECT rct_id_details, cnr_id, khr_id
     FROM   okl_txl_rcpt_apps_v
     WHERE  id = cp_rca_id;

----------

   -- internal line info
   CURSOR c_get_internal (cp_rct_id_details IN NUMBER) IS
     SELECT id, lsm_id
     FROM   okl_txl_rcpt_apps_v
     WHERE  rct_id_details = cp_rct_id_details;

   c_get_internal_rec c_get_internal%ROWTYPE;

----------

   -- external hdr/ln info
   CURSOR c_get_external_hdr (cp_xcr_id_details IN NUMBER) IS
     SELECT a.id, a.rct_id, a.remittance_amount, a.check_number, a.receipt_date,
            a.gl_date, a.customer_number, a.currency_code, a.org_id, a.exchange_rate_type,
            a.exchange_rate_date, a.attribute1
     FROM   okl_ext_csh_rcpts_b a, okl_xtl_csh_apps_b b
     WHERE  a.id = b.xcr_id_details
     AND    b.xcr_id_details = cp_xcr_id_details;

----------

   -- currency conversion rate
   CURSOR c_get_conv_rate (cp_xcr_id IN NUMBER) IS
     SELECT a.exchange_rate
     FROM   okl_ext_csh_rcpts_b a
     WHERE  a.id = cp_xcr_id;

----------

   -- get receipt info
   CURSOR c_get_rcpt_info (cp_rct_id IN NUMBER) IS
     SELECT a.currency_code, a.amount,                      -- rcpt currency
            b.currency_code, b.remittance_amount            -- functional currency
     FROM   okl_trx_csh_receipt_b a,
            okl_ext_csh_rcpts_b b
     WHERE  a.id = cp_rct_id
     AND    a.id = b.rct_id;

----------


BEGIN

    l_strm_tbl := p_strm_tbl;

    IF l_strm_tbl.COUNT = 0 THEN

           -- Message Text: no allocation required ...
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name    => G_APP_NAME,
                                 p_msg_name    =>'OKL_BPD_NO_ALLOC_REQ');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF l_strm_tbl(1).asset_id = 1 THEN


        OPEN  c_get_rca_id(l_strm_tbl(1).xtl_cash_apps_id);
	    FETCH c_get_rca_id INTO l_rca_id, l_xcr_id_details;
	    CLOSE c_get_rca_id;

        -- Check for exceptions
	    IF l_rca_id = NULL THEN

            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

	    END IF;

        OPEN  c_get_strm_dtls(l_rca_id);
	    FETCH c_get_strm_dtls INTO l_rct_id_details, l_cnr_id, l_khr_id;
	    CLOSE c_get_strm_dtls;

        -- clear up internal receipt
        DELETE FROM OKL_TRX_CSH_RECEIPT_B
        WHERE ID = l_rct_id_details;

        -- clear up internal receipt lines
        DELETE FROM OKL_TXL_RCPT_APPS_B
        WHERE RCT_ID_DETAILS = l_rct_id_details;

        -- clear up external receipt
        DELETE FROM OKL_EXT_CSH_RCPTS_B
        WHERE ID = l_xcr_id_details;

        -- clear up external receipt lines
        DELETE FROM OKL_XTL_CSH_APPS_B
        WHERE XCR_ID_DETAILS = l_xcr_id_details;

        x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    ELSE

	    -- get internal lines id to obtain fixed values l_rct_id_details, cnr_id and khr_id.
        -- only one record is required.

        i := 1;

  	    OPEN  c_get_rca_id(l_strm_tbl(1).xtl_cash_apps_id);
	    FETCH c_get_rca_id INTO l_rca_id, l_xcr_id_details;
	    CLOSE c_get_rca_id;

        -- Check for exceptions
	    IF l_rca_id = NULL THEN

            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

	    END IF;

        OPEN  c_get_strm_dtls(l_rca_id);
	    FETCH c_get_strm_dtls INTO l_rct_id_details, l_cnr_id, l_khr_id;
	    CLOSE c_get_strm_dtls;

        -- Check for exceptions
	    IF l_rct_id_details = NULL THEN
            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;

        OPEN  c_get_rcpt_info(l_rct_id_details);
        FETCH c_get_rcpt_info INTO l_rcpt_currency_code     -- receipt currency
                                  ,l_rcpt_amount            -- receipt amount
                                  ,l_func_currency_code     -- invoice currency code ( functional )
                                  ,l_func_rcpt_amount;      -- invoice amount
        CLOSE c_get_rcpt_info;

        -- Check for exceptions
	    IF l_rcpt_currency_code = NULL THEN
            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;


        -- check applied amount < = the receipt amount ...
        j := 1;
        l_total_amount_applied := 0;

        LOOP
            l_total_amount_applied := l_total_amount_applied + l_strm_tbl(j).applied_stream_amount;     -- working in functional currency.
            EXIT WHEN j = (l_strm_tbl.LAST);
            j := j + 1;
        END LOOP;

        IF l_func_rcpt_amount < l_total_amount_applied THEN  -- in functional currency ...
            -- Message Text: the amount applied must be equal or less than receipt amount
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name    => G_APP_NAME,
                                 p_msg_name    =>'OKL_BPD_RCPT_ALLOC_ERR');

            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- old internal records no longer required.

        i := 1;

        OPEN c_get_internal(l_rct_id_details);
	    LOOP
  	        FETCH c_get_internal INTO c_get_internal_rec;
            EXIT WHEN c_get_internal%NOTFOUND;
            l_rcav_tbl(i).ID := c_get_internal_rec.id;
      	    i := i + 1;
        END LOOP;
        CLOSE c_get_internal;

        -- call delete internal

        Okl_Txl_Rcpt_Apps_Pub.delete_txl_rcpt_apps( l_api_version
                                                   ,l_init_msg_list
                                                   ,l_return_status
                                                   ,l_msg_count
                                                   ,l_msg_data
                                                   ,l_rcav_tbl
                                                   );

        x_return_status := l_return_status;
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- prepare new internal transaction records

        i := 1;
        j := 1;

        -- get conversion rate if there is one.
 	    OPEN  c_get_conv_rate(l_xcr_id_details);
	    FETCH c_get_conv_rate INTO l_conversion_rate;
	    CLOSE c_get_conv_rate;

        LOOP
            l_rcav_tbl(i).rct_id_details := l_rct_id_details;
            l_rcav_tbl(i).cnr_id := l_cnr_id;
            l_rcav_tbl(i).khr_id := l_khr_id;
            l_rcav_tbl(i).lsm_id := l_strm_tbl(j).lsm_id;

            IF l_rcpt_currency_code <> l_func_currency_code THEN
                l_rcav_tbl(i).amount := l_strm_tbl(j).applied_stream_amount / l_conversion_rate; -- in receipt currency
            ELSE
                l_rcav_tbl(i).amount := l_strm_tbl(j).applied_stream_amount; -- in functional currency.
            END IF;

            l_rcav_tbl(i).line_number := i;
	    	EXIT WHEN (j = l_strm_tbl.LAST);
            i := i + 1;
            j := j + 1;
        END LOOP;

        Okl_Txl_Rcpt_Apps_Pub.insert_txl_rcpt_apps( l_api_version
                                                   ,l_init_msg_list
                                                   ,l_return_status
                                                   ,l_msg_count
                                                   ,l_msg_data
                                                   ,l_rcav_tbl
                                                   ,x_rcav_tbl
                                                   );

        x_return_status := l_return_status;
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- update external transaction records

        i := 1;
        j := 1;

        OPEN c_get_internal(l_rct_id_details);
	    LOOP
  	        FETCH c_get_internal INTO l_rca_id, l_lsm_id;

            EXIT WHEN c_get_internal%NOTFOUND;
            LOOP
                IF  l_strm_tbl(j).lsm_id = l_lsm_id THEN

                    l_xcav_tbl(i).ID := l_strm_tbl(j).xtl_cash_apps_id;
                    l_xcav_tbl(i).RCA_ID := l_rca_id;

                    IF l_strm_tbl(j).applied_stream_amount NOT IN (0,0.00) THEN

                        l_xcav_tbl(i).AMOUNT_APPLIED := l_strm_tbl(j).applied_stream_amount;
                    ELSE
                        l_xcav_tbl(i).AMOUNT_APPLIED := 0;
                    END IF;

                    IF l_rcpt_currency_code <> l_func_currency_code THEN
                        l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_strm_tbl(j).applied_stream_amount / l_conversion_rate;
                    END IF;

                    l_xcav_tbl(i).LSM_ID := l_strm_tbl(j).lsm_id;

                    j := 1;
                    EXIT;

                ELSE

  	                j := j + 1;

                END IF;

            END LOOP;

            i := i + 1;

        END LOOP;
        CLOSE c_get_internal;

        Okl_Xtl_Csh_Apps_Pub.update_xtl_csh_apps(   l_api_version
                                                   ,l_init_msg_list
                                                   ,l_return_status
                                                   ,l_msg_count
                                                   ,l_msg_data
                                                   ,l_xcav_tbl
                                                   ,x_xcav_tbl
                                                );

        x_return_status := l_return_status;
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- prepare to call receipt_api.

        OPEN c_get_external_hdr(l_xcr_id_details);
	    LOOP
            EXIT WHEN c_get_external_hdr%NOTFOUND;

      	    FETCH c_get_external_hdr INTO  l_xcrv_rec.id
                                          ,l_xcrv_rec.rct_id
                                          ,l_xcrv_rec.remittance_amount
                                          ,l_xcrv_rec.check_number
                                          ,l_xcrv_rec.receipt_date
                                          ,l_xcrv_rec.gl_date
                                          ,l_xcrv_rec.customer_number
                                          ,l_xcrv_rec.currency_code
                                          ,l_xcrv_rec.org_id
                                          ,l_xcrv_rec.exchange_rate_type
                                          ,l_xcrv_rec.exchange_rate_date
                                          ,l_xcrv_rec.attribute1;
        END LOOP;
        CLOSE c_get_external_hdr;

        OPEN c_ovr_pay_alloc_code;
        FETCH c_ovr_pay_alloc_code INTO l_over_payment_code;
        CLOSE c_ovr_pay_alloc_code;

        IF l_over_payment_code IN ('M','m') THEN

            l_over_pay := 'U';  -- UNAPPLIED;
            -- just create money against customer and thats it...

        ELSIF l_over_payment_code IN ('B','b') THEN

            l_over_pay := 'O';  -- CUSTOMERS ACCOUNT
            -- apply money to customers account...

        ELSIF l_over_payment_code IN ('F','f') THEN

            -- KICK OFF PROCESS FOR FUTURE AMOUNTS DUE
            l_over_pay := 'O';  -- CUSTOMERS ACCOUNT

        END IF;

        okl_cash_receipt.CASH_RECEIPT (p_api_version      => l_api_version
                                      ,p_init_msg_list    => l_init_msg_list
                                      ,x_return_status    => l_return_status
                                      ,x_msg_count        => l_msg_count
                                      ,x_msg_data         => l_msg_data
                                      ,p_over_pay         => l_over_pay
                                      ,p_conc_proc        => l_conc_proc
                                      ,p_xcrv_rec         => l_xcrv_rec
                                      ,p_xcav_tbl         => l_xcav_tbl
                                      ,x_cash_receipt_id  => l_cash_receipt_id
                                      );

        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        x_msg_count     := l_msg_count;

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- UPDATE EXT HEADER WITH CASH RECEIPT ID

        l_xcrv_rec.icr_id := l_cash_receipt_id;

        Okl_Xcr_Pub.update_ext_csh_txns( p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_xcrv_rec
                                        ,x_xcrv_rec
                                       );

        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        x_msg_count     := l_msg_count;

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


    END IF;


-------------------------------------------------------------------------------------------
-- clean up redundant records without amounts applied before calling AR

    DELETE
    FROM    OKL_XTL_CSH_APPS_B
    WHERE   AMOUNT_APPLIED = 0
    AND     XCR_ID_DETAILS = l_xcr_id_details;

-------------------------------------------------------------------------------------------


EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
NULL;
/*
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
*/

END update_cash_details;
END Okl_Updt_Cash_Dtls;

/

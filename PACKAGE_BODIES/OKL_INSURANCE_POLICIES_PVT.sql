--------------------------------------------------------
--  DDL for Package Body OKL_INSURANCE_POLICIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INSURANCE_POLICIES_PVT" AS
/* $Header: OKLRIPXB.pls 120.47.12010000.6 2009/12/17 10:50:14 rpillay ship $ */


-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.INSURANCE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
    --------------------------------------------------------
    -- Procedures and Functions
    ---------------------------------------------------------------------------


 ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Function Name    : ON_ACCOUNT_CREDIT_MEMO
    -- Description      :It creates on account credit memo in the BPD's internal
    --                   Transaction Tables.
    -- Business Rules   :
    -- Parameters               :
    -- Version          : 1.0
    -- End of Comments
  ---------------------------------------------------------------------------

-- gboomina Bug 4622198 - Added to get codes for Investor Special Accounting treatment - Start

PROCEDURE get_special_acct_codes(
  p_khr_id           IN           NUMBER,
  p_trx_date         IN  DATE,
  x_fact_sync_code   OUT  NOCOPY  VARCHAR2,
  x_inv_acct_code    OUT  NOCOPY  VARCHAR2
)
IS

  l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
		l_scs_code           VARCHAR2(2000);

		-- cursor to get scs_code
		CURSOR scs_code_csr IS
		SELECT scs_code
		FROM OKL_K_HEADERS_FULL_V
		WHERE id = p_khr_id;

BEGIN
  		-- get scs_code
		FOR x IN scs_code_csr
		LOOP
				l_scs_code := x.scs_code;
		END LOOP;

		IF l_scs_code IS NULL THEN
				OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCS_CODE');
				RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF;

		OKL_SECURITIZATION_PVT.check_khr_ia_associated(
			p_api_version                  => 1.0
		,p_init_msg_list                => l_init_msg_list
		,x_return_status                => l_return_status
		,x_msg_count                    => l_msg_count
		,x_msg_data                     => l_msg_data
		,p_khr_id                       => p_khr_id
		,p_scs_code                     => l_scs_code
		,p_trx_date                     => p_trx_date
		,x_fact_synd_code               => x_fact_sync_code
		,x_inv_acct_code                => x_inv_acct_code
		);

		-- store the highest degree of error
		IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
			 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			   -- need to leave
		    Okl_Api.set_message(p_app_name     => g_app_name,
				  p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			 ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		    Okl_Api.set_message(p_app_name     => g_app_name,
				  p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
		    RAISE OKL_API.G_EXCEPTION_ERROR;
			 END IF;
		END IF;

END get_special_acct_codes;

-- gboomina Bug 4622198 - Added to get codes for Investor Special Accounting treatment - End


--Added for bug 3976894

     PROCEDURE on_account_credit_memo
            (
            p_api_version                  IN NUMBER,
            p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
            p_try_id                       IN NUMBER,
            p_khr_id                     IN NUMBER,
            p_kle_id                     IN NUMBER,
            p_ipy_id                       IN NUMBER,
            p_credit_date                  IN DATE,
            p_credit_amount                IN NUMBER,
            p_credit_sty_id                IN NUMBER,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            x_tai_id                       OUT NOCOPY  NUMBER

          )IS


      l_api_name CONSTANT VARCHAR2(30) := 'on_account_credit_memo';

      l_api_version         CONSTANT NUMBER := 1;
      l_return_status      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;


      /*
      l_bpd_acc_rec    OKL_INSURANCE_POLICIES_PVT.bpd_acc_rec_type ;
      l_taiv_rec       OKL_INSURANCE_POLICIES_PVT.taiv_rec_type ;
      lx_taiv_rec      OKL_INSURANCE_POLICIES_PVT.taiv_rec_type ;
      l_tilv_rec       OKL_INSURANCE_POLICIES_PVT.tilv_rec_type ;
      lx_tilv_rec      OKL_INSURANCE_POLICIES_PVT.tilv_rec_type;
      */

    -- Bug 5897792 Start
    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_rec        okl_til_pvt.tilv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    -- Bug 5897792 End


      BEGIN

                     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                              G_PKG_NAME,
                                                              p_init_msg_list,
                                                              l_api_version,
                                                              p_api_version,
                                                              '_PROCESS',
                                                              x_return_status);




             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;


   -- Bug 5897792 Start
    /*
      ---- Create Header Record

             l_taiv_rec.khr_id           := p_khr_id;
             l_taiv_rec.try_id           := p_try_id;
             l_taiv_rec.ipy_id           := p_ipy_id ;
             l_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
             l_taiv_rec.date_entered     := trunc(sysdate) ;
             l_taiv_rec.amount           := p_credit_amount;
             l_taiv_rec.trx_status_code  := 'SUBMITTED';
             l_taiv_rec.legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => p_khr_id);


      -- Start of Debug code generator for okl_acc_call_pub.create_acc_trans
    IF(L_DEBUG_ENABLED='Y') THEN
       L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
      IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;

    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices ');
      END;
    END IF;

             okl_trx_ar_invoices_pub.insert_trx_ar_invoices(p_api_version,
                                                            p_init_msg_list,
                                                            l_return_status,
                                                            x_msg_count,
                                                            x_msg_data,
                                                            l_taiv_rec,
                                                            lx_taiv_rec);
      IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
              OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_trx_ar_invoices_pub.insert_trx_ar_invoices ');
          END;
      END IF;

             IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status      :=     l_return_status;
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                x_return_status      :=     l_return_status;
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;




       x_tai_id             :=     lx_taiv_rec.id;
       ----------------------------------------------------
      --- Create Line Record
       -------------------------------------------------------

      l_tilv_rec.amount                 := p_credit_amount;
      l_tilv_rec.kle_id                 := p_kle_id;
      l_tilv_rec.line_number            := 1;
      l_tilv_rec.tai_id                 := x_tai_id;
      l_tilv_rec.description            :=  'OKL Credit Memo';
      l_tilv_rec.inv_receiv_line_code   := 'LINE';
      l_tilv_rec.sty_id                 := p_credit_sty_id;


      -- Start of Debug code generator for okl_acc_call_pub.create_acc_trans
          IF(L_DEBUG_ENABLED='Y') THEN
             L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
            IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
          END IF;

          IF(IS_DEBUG_PROCEDURE_ON) THEN
            BEGIN
                 OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns ');
            END;
          END IF;



              okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns(p_api_version,
                                                           p_init_msg_list,
                                                           l_return_status,
                                                           x_msg_count,
                                                           x_msg_data,
                                                           l_tilv_rec,
                                                           lx_tilv_rec);

      IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
             OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns ');
          END;
      END IF;

             IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status      :=     l_return_status;
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                x_return_status      :=     l_return_status;
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;




       ----------------------------------------------------
       --- Create Accounting entries
       ----------------------------------------------------


          l_bpd_acc_rec.id           := lx_tilv_rec.id;
          l_bpd_acc_rec.source_table := 'OKL_TXL_AR_INV_LNS_B';


        -- Start of Debug code generator for okl_acc_call_pub.create_acc_trans
    IF(L_DEBUG_ENABLED='Y') THEN
       L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
      IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;

    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_acc_call_pub.create_acc_trans ');
      END;
    END IF;

              OKL_ACC_CALL_PUB.CREATE_ACC_TRANS(
                          p_api_version         => p_api_version
                          ,p_init_msg_list      => p_init_msg_list
                          ,x_return_status      => l_return_status
                          ,x_msg_count          => x_msg_count
                          ,x_msg_data           => x_msg_data
                          ,p_bpd_acc_rec        => l_bpd_acc_rec);

    IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_acc_call_pub.create_acc_trans ');
    END;
  END IF;
-- End of Debug for okl_acc_call_pub.create_acc_trans
 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               x_return_status      :=     l_return_status;
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
               x_return_status      :=     l_return_status;
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

     */ -- 5897792 End

      -- 5897792 Start Replace by central billing txn API call
      ---- Create Header Record

             lp_taiv_rec.khr_id           := p_khr_id;
             lp_taiv_rec.try_id           := p_try_id;
             lp_taiv_rec.ipy_id           := p_ipy_id ;
             lp_taiv_rec.date_invoiced    := NVL(p_credit_date,trunc(sysdate));
             lp_taiv_rec.date_entered     := trunc(sysdate) ;
             lp_taiv_rec.amount           := p_credit_amount;
             lp_taiv_rec.trx_status_code  := 'SUBMITTED';
             lp_taiv_rec.legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => p_khr_id);
             lp_taiv_rec.okl_source_billing_trx  := 'INSURANCE';

      --- Create Line Record

      lp_tilv_rec.amount                 := p_credit_amount;
      lp_tilv_rec.kle_id                 := p_kle_id;
      lp_tilv_rec.line_number            := 1;
      lp_tilv_rec.tai_id                 := x_tai_id;
      lp_tilv_rec.description            :=  'OKL Credit Memo';
      lp_tilv_rec.inv_receiv_line_code   := 'LINE';
      lp_tilv_rec.sty_id                 := p_credit_sty_id;

      lp_tilv_tbl(1) := lp_tilv_rec;

      okl_internal_billing_pvt.create_billing_trx(
                       p_api_version =>l_api_version,
                       p_init_msg_list =>p_init_msg_list,
                       x_return_status =>  x_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data,
                       p_taiv_rec => lp_taiv_rec,
                       p_tilv_tbl => lp_tilv_tbl,
                       p_tldv_tbl => lp_tldv_tbl,
                       x_taiv_rec => lx_taiv_rec,
                       x_tilv_tbl => lx_tilv_tbl,
                       x_tldv_tbl => lx_tldv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- 5897792 Start End

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
              WHEN OKC_API.G_EXCEPTION_ERROR THEN
                x_return_status := OKC_API.HANDLE_EXCEPTIONS
                (
                  l_api_name,
                  G_PKG_NAME,
                  'OKC_API.G_RET_STS_ERROR',
                  x_msg_count,
                  x_msg_data,
                  '_PROCESS'
                );
              WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
                x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                (
                  l_api_name,
                  G_PKG_NAME,
                  'OKC_API.G_RET_STS_UNEXP_ERROR',
                  x_msg_count,
                  x_msg_data,
                  '_PROCESS'
                );
              WHEN OTHERS THEN
                x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                (
                  l_api_name,
                  G_PKG_NAME,
                  'OTHERS',
                  x_msg_count,
                  x_msg_data,
                  '_PROCESS'
      );

  END ON_ACCOUNT_CREDIT_MEMO;



   ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name	: get_contract_status
  -- Description		:It get Contract status based on contract id.
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
   FUNCTION get_contract_status (
            p_khr_id IN  NUMBER,
            x_contract_status OUT NOCOPY VARCHAR2
          ) RETURN VARCHAR2 IS
            l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
            CURSOR okc_k_status_csr(p_khr_id  IN NUMBER) IS
                SELECT STE_CODE
  	          FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
                WHERE  KHR.ID =  p_khr_id
                AND KHR.STS_CODE = OST.CODE ;

          BEGIN
            OPEN  okc_k_status_csr(p_khr_id);
           FETCH okc_k_status_csr INTO x_contract_status ;
           IF(okc_k_status_csr%NOTFOUND) THEN
              -- store SQL error message on message stack for caller
                 OKL_API.set_message(G_APP_NAME,
                 			   G_INVALID_CONTRACT
                 			   );
                 CLOSE okc_k_status_csr ;
                 l_return_status := OKC_API.G_RET_STS_ERROR;
                 -- Change it to
                 RETURN(l_return_status);
           END IF;
           CLOSE okc_k_status_csr ;
           RETURN(l_return_status);
           EXCEPTION
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        		-- verify that cursor was closed
      		IF okc_k_status_csr%ISOPEN THEN
  	    	   CLOSE okc_k_status_csr;
  		    END IF;
            	RETURN(l_return_status);
        END get_contract_status;

        -----------------------------------------------------

    PROCEDURE   insert_ap_request(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_tap_id          IN NUMBER,
       p_credit_amount   IN NUMBER,
       p_credit_sty_id   IN NUMBER,
       p_khr_id         IN NUMBER ,
       p_kle_id         IN NUMBER,
       p_invoice_date   IN DATE,
       p_trx_id         IN NUMBER,
       p_vendor_site_id      IN NUMBER ,
       x_request_id     OUT NOCOPY NUMBER
  ) IS

      l_tplv_rec           okl_tpl_pvt.tplv_rec_type ;
      l_tapv_rec           okl_tap_pvt.tapv_rec_type ;

      x_tplv_rec           okl_tpl_pvt.tplv_rec_type ;
      x_tapv_rec           okl_tap_pvt.tapv_rec_type ;

        /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start Changes */
         l_tplv_tbl       okl_tpl_pvt.tplv_tbl_type ;
         x_tplv_tbl      okl_tpl_pvt.tplv_tbl_type ;
        /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End Changes */

       CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
        SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;

        CURSOR c_tap_info (P_TAP_ID NUMBER) IS
        SELECT
       CURRENCY_CODE,
       SET_OF_BOOKS_ID
      FROM OKL_TRX_AP_INVOICES_B
      WHERE ID = P_TAP_ID ;

      CURSOR C_CURRENCY (P_khr_ID NUMBER) IS
      SELECT   CURRENCY_CODE --Bug:3825159
      FROM OKC_K_HEADERS_B
      WHERE ID = P_khr_ID ;


      l_ctxt_val_tbl            Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
     l_acc_gen_primary_key_tbl    Okl_Account_Dist_Pub.acc_gen_primary_key;
     l_template_tbl            Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
     l_amount_tbl              Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;


   CURSOR c_app_info  IS
        SELECT APPLICATION_ID
      FROM FND_APPLICATION
      WHERE APPLICATION_SHORT_NAME = 'OKL' ;

   ------

        l_api_name CONSTANT VARCHAR2(30) := 'insert_ap_request';

       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;
      l_trx_type_ID      okl_trx_types_v.id%TYPE;

      p_name    VARCHAR2(30) := 'BILLING' ;
      -- Need to change code for hard coded value
      p_language VARCHAR2(2)  := 'US' ;
      l_sql      NUMBER ;
      l_app_id   NUMBER;

      l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
      lx_dbseqnm          VARCHAR2(2000):= '';
      lx_dbseqid          NUMBER(38):= NULL;

  BEGIN

               l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;



       -- GET Application Info
          OPEN c_app_info ;
          FETCH c_app_info INTO l_app_id;
          CLOSE c_app_info;

          --Removed as part of fixing 3745151
         /*
          IF(c_app_info%NOTFOUND) THEN
              -- Change Message
               Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
               G_COL_NAME_TOKEN,'Billing');
               x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE c_app_info ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;
         */
          --Removed as part of fixing 3745151



    l_tapv_rec.IPVS_ID := p_vendor_site_id ;



  -- Header Information
  l_tapv_rec.sfwt_flag := 'N' ;
  l_tapv_rec.TRX_STATUS_CODE  := 'ENTERED' ;
   IF ( p_tap_id <>  NULL  OR p_tap_id <> OKC_API.G_MISS_NUM ) THEN
      OPEN c_tap_info (p_tap_id);
      FETCH c_tap_info INTO l_tapv_rec.CURRENCY_CODE,l_tapv_rec.SET_OF_BOOKS_ID;
      IF(c_tap_info%NOTFOUND) THEN
           Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_INVOICE');
           x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE c_tap_info ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
     END if ;
      CLOSE c_tap_info;
      l_tapv_rec.TAP_ID_REVERSES := p_tap_id ;
      l_tapv_rec.INVOICE_TYPE := 'CREDIT';
   ELSE

     OPEN C_CURRENCY (p_khr_id);
      FETCH C_CURRENCY INTO l_tapv_rec.CURRENCY_CODE;--,l_tapv_rec.SET_OF_BOOKS_ID;
      IF(C_CURRENCY%NOTFOUND) THEN
           Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_CONTRACT');
           x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_CURRENCY ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
     END if ;
      CLOSE C_CURRENCY;

        l_tapv_rec.TAP_ID_REVERSES := OKC_API.G_MISS_NUM ;
        l_tapv_rec.INVOICE_TYPE := 'STANDARD';
        -- GET  SET OF BOOK
        l_tapv_rec.SET_OF_BOOKS_ID := OKL_ACCOUNTING_UTIL.get_set_of_books_id; --smoduga fix for bug 4238141

   END IF;

  l_tapv_rec.TRY_ID := p_trx_id ;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  Start changes */
      l_tapv_rec.KHR_ID := null ; -- p_khr_id ;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  End changes */
  l_tapv_rec.AMOUNT := p_credit_amount;

  BEGIN
      l_tapv_rec.Invoice_Number := fnd_seqnum.get_next_sequence
                   (appid      =>  l_app_id,
                   cat_code    =>  l_document_category,
                   sobid       =>  l_tapv_rec.SET_OF_BOOKS_ID,
                   met_code    =>  'A',
                   trx_date    =>  SYSDATE,
                   dbseqnm     =>  lx_dbseqnm,
                   dbseqid     =>  lx_dbseqid);

       EXCEPTION
       WHEN OTHERS THEN
          OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                            p_token1        => 'OKL_SQLCODE',
                            p_token1_value  => SQLCODE,
                            p_token2        => 'OKL_SQLERRM',
                       p_token2_value  => SQLERRM);
    END;

  --l_tapv_rec.INVOICE_NUMBER := 'OKLINV' || TO_CHAR(l_sql);
  l_tapv_rec.WORKFLOW_YN := 'N';
  l_tapv_rec.CONSOLIDATE_YN  := 'N';
  l_tapv_rec.WAIT_VENDOR_INVOICE_YN := 'N';
  l_tapv_rec.DATE_INVOICED := p_invoice_date;
  l_tapv_rec.DATE_GL :=  p_invoice_date;
  l_tapv_rec.DATE_ENTERED := SYSDATE;
  l_tapv_rec.object_version_number := 1;
  SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
         DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
         DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
         DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
         mo_global.get_current_org_id()  INTO l_tapv_rec.REQUEST_ID,
              l_tapv_rec.PROGRAM_APPLICATION_ID,
              l_tapv_rec.PROGRAM_ID,
              l_tapv_rec.PROGRAM_UPDATE_DATE,
              l_tapv_rec.ORG_ID FROM dual;
  l_tapv_rec.legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => p_khr_id);



  --------------

  l_tplv_rec.SFWT_FLAG := 'N';
  l_tplv_rec.KLE_ID := p_kle_id;
--  l_tplv_rec.INV_DISTR_LINE_CODE := 'A' ; -- Need to find out from rina
  l_tplv_rec.INV_DISTR_LINE_CODE := 'ITEM' ; --| 03-Oct-2007 cklee   Fixed Bug 6469797                                        |
  l_tplv_rec.STY_ID := p_credit_sty_id;
  l_tplv_rec.TAP_ID := x_tapv_rec.id ;
  l_tplv_rec.AMOUNT := p_credit_amount;
  l_tplv_rec.LINE_NUMBER :=  1;
  l_tplv_rec.object_version_number := 1;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  Start Changes  */
  l_tplv_rec.KHR_ID := p_khr_id ;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  End Changes  */


  SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
       DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
       DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
       DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
       mo_global.get_current_org_id()  INTO l_tplv_rec.REQUEST_ID,
            l_tplv_rec.PROGRAM_APPLICATION_ID,
            l_tplv_rec.PROGRAM_ID,
            l_tplv_rec.PROGRAM_UPDATE_DATE,
            l_tplv_rec.ORG_ID FROM dual;



------------------------------------------------------------------------------------
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start changes */

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_CREATE_DISB_TRANS_PVT.create_disb_trx ');
    END;
  END IF;

  l_tplv_tbl(0) := l_tplv_rec;

  OKL_CREATE_DISB_TRANS_PVT.create_disb_trx(p_api_version
                            ,p_init_msg_list     => p_init_msg_list
                            ,x_return_status     => l_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_tapv_rec         =>l_tapv_rec
                            ,p_tplv_tbl           =>l_tplv_tbl
                            ,x_tapv_rec          =>x_tapv_rec
                            ,x_tplv_tbl           =>x_tplv_tbl
                            );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_CREATE_DISB_TRANS_PVT.create_disb_trx ');
    END;
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  x_request_id := x_tapv_rec.id ;

/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End changes */

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
  END insert_ap_request;




  PROCEDURE   insert_ap_request(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_tap_id          IN NUMBER,
       p_credit_amount   IN NUMBER,
       p_credit_sty_id   IN NUMBER,
       p_khr_id         IN NUMBER ,
       p_kle_id         IN NUMBER,
       p_invoice_date   IN DATE,
       p_trx_id         IN NUMBER

  )

  IS
      l_tplv_rec           okl_tpl_pvt.tplv_rec_type ;
      l_tapv_rec           okl_tap_pvt.tapv_rec_type ;

      x_tplv_rec           okl_tpl_pvt.tplv_rec_type ;
      x_tapv_rec           okl_tap_pvt.tapv_rec_type ;

      /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start Changes */
      l_tplv_tbl       okl_tpl_pvt.tplv_tbl_type ;
      x_tplv_tbl      okl_tpl_pvt.tplv_tbl_type ;
     /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End Changes */

-- skgautam Added as part of fix of bug  4146178
      l_vendor_id          NUMBER;
      l_vendor             VARCHAR2(100);
      l_org                NUMBER;

        CURSOR c_vendor_info (p_kle_id NUMBER ) IS --bug  4146178
        SELECT PV.VENDOR_ID VENDOR_ID,PV.VENDOR_NAME VENDOR_NAME,CHR.AUTHORING_ORG_ID ORG_ID
        FROM   OKL_INS_POLICIES_B IPYB ,
               OKC_K_HEADERS_B    CHR,
               PO_VENDORS         PV
        WHERE  IPYB.KLE_ID     = p_kle_id
        AND    CHR.ID          = IPYB.KHR_ID
        AND    IPYB.ISU_ID     = PV.VENDOR_ID;

-- skgautam Added as part of fix of bug  4146178
        CURSOR c_vendor_site_info (p_vendor_id NUMBER,p_org_id NUMBER ) IS
        SELECT IPOV.ID1 ID1
        FROM   OKX_VENDOR_SITES_V IPOV
        WHERE  IPOV.VENDOR_ID      = p_vendor_id
        AND    IPOV.ORG_ID         = p_org_id
        AND    IPOV.PAY_SITE_FLAG  = 'Y';

        CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
        SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;

        CURSOR c_tap_info (P_TAP_ID NUMBER) IS
        SELECT
          CURRENCY_CODE,
          SET_OF_BOOKS_ID
        FROM OKL_TRX_AP_INVOICES_B
        WHERE ID = P_TAP_ID ;

       CURSOR C_CURRENCY (P_khr_ID NUMBER) IS
       SELECT   CURRENCY_CODE
       FROM OKC_K_HEADERS_B                -- Changed to table
       WHERE ID = P_khr_ID ;


     l_ctxt_val_tbl               Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
     l_acc_gen_primary_key_tbl    Okl_Account_Dist_Pub.acc_gen_primary_key;
     l_template_tbl               Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
     l_amount_tbl                 Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;


   CURSOR c_app_info  IS
        SELECT APPLICATION_ID
      FROM FND_APPLICATION
      WHERE APPLICATION_SHORT_NAME = 'OKL' ;


        l_api_name CONSTANT VARCHAR2(30) := 'insert_ap_request';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;
      l_trx_type_ID      okl_trx_types_v.id%TYPE;

      p_name    VARCHAR2(30) := 'BILLING' ;
      -- Need to change code for hard coded value
      p_language VARCHAR2(2)  := 'US' ;
      l_sql      NUMBER ;
      l_app_id   NUMBER;

      l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
      lx_dbseqnm          VARCHAR2(2000):= '';
      lx_dbseqid          NUMBER(38):= NULL;

  BEGIN

       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PROCESS',
                                                 x_return_status);

       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;



       -- GET Application Info
          OPEN c_app_info ;
          FETCH c_app_info INTO l_app_id;
          CLOSE c_app_info;

          --Removed as part of fixing 3745151

          -- Get Vendor
          OPEN c_vendor_info (p_kle_id); -- Bug 4146178
          FETCH c_vendor_info INTO l_vendor_id,l_vendor,l_org;
          CLOSE c_vendor_info;

         -- Get Vendor Site
          OPEN c_vendor_site_info(l_vendor_id,l_org); -- Bug 4146178
          FETCH c_vendor_site_info INTO l_tapv_rec.IPVS_ID;
          IF(c_vendor_site_info%NOTFOUND) THEN
             -- Change Message
               Okc_Api.set_message(G_APP_NAME, 'OKL_NO_VENDOR_SITE','VENDOR',l_vendor,'ORG',l_org);  -- Bug 4146178
               x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE c_vendor_site_info ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;

      CLOSE c_vendor_site_info;


  -- Header Information
  l_tapv_rec.sfwt_flag := 'N' ;
  l_tapv_rec.TRX_STATUS_CODE  := 'ENTERED' ;
  IF ( p_tap_id <>  NULL  AND p_tap_id <> OKC_API.G_MISS_NUM ) THEN
      OPEN c_tap_info (p_tap_id);
      FETCH c_tap_info INTO l_tapv_rec.CURRENCY_CODE,l_tapv_rec.SET_OF_BOOKS_ID;
        IF(c_tap_info%NOTFOUND) THEN
           Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_INVOICE');
           x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE c_tap_info ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END if ;
      CLOSE c_tap_info;
      l_tapv_rec.TAP_ID_REVERSES := p_tap_id ;
      l_tapv_rec.INVOICE_TYPE := 'CREDIT';
  ELSE

      OPEN C_CURRENCY (p_khr_id);
      FETCH C_CURRENCY INTO l_tapv_rec.CURRENCY_CODE;--,l_tapv_rec.SET_OF_BOOKS_ID;
      IF(C_CURRENCY%NOTFOUND) THEN
           Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_CONTRACT');
           x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_CURRENCY ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
      END if ;
      CLOSE C_CURRENCY;
      l_tapv_rec.TAP_ID_REVERSES := OKC_API.G_MISS_NUM ;
      l_tapv_rec.INVOICE_TYPE := 'STANDARD';
      -- GET  SET OF BOOK
      l_tapv_rec.SET_OF_BOOKS_ID := OKL_ACCOUNTING_UTIL.get_set_of_books_id; --smoduga fix for bug 4238141
  END IF;


  l_tapv_rec.TRY_ID := p_trx_id ;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  Start changes  */
  l_tapv_rec.KHR_ID := null ; -- p_khr_id ;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT  End changes  */

  -- l_tapv_rec.CPLV_ID := 1001 ; -- GET PARTY ROLE
  l_tapv_rec.AMOUNT := p_credit_amount;


  BEGIN


      l_tapv_rec.Invoice_Number := fnd_seqnum.get_next_sequence
                   (appid      =>  l_app_id,
                   cat_code    =>  l_document_category,
                   sobid       =>  l_tapv_rec.SET_OF_BOOKS_ID,
                   met_code    =>  'A',
                   trx_date    =>  SYSDATE,
                   dbseqnm     =>  lx_dbseqnm,
                   dbseqid     =>  lx_dbseqid);

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
  END;

  --l_tapv_rec.INVOICE_NUMBER := 'OKLINV' || TO_CHAR(l_sql);
  l_tapv_rec.WORKFLOW_YN := 'N';
  l_tapv_rec.CONSOLIDATE_YN  := 'N';
  l_tapv_rec.WAIT_VENDOR_INVOICE_YN := 'N';
  l_tapv_rec.DATE_INVOICED := p_invoice_date;
  l_tapv_rec.DATE_GL :=  p_invoice_date;
  l_tapv_rec.DATE_ENTERED := SYSDATE;
  l_tapv_rec.object_version_number := 1;
  SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
                     DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
                     DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
                     DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                     mo_global.get_current_org_id()  INTO l_tapv_rec.REQUEST_ID,
                          l_tapv_rec.PROGRAM_APPLICATION_ID,
                          l_tapv_rec.PROGRAM_ID,
                          l_tapv_rec.PROGRAM_UPDATE_DATE,
                          l_tapv_rec.ORG_ID FROM dual;
  l_tapv_rec.legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => p_khr_id);

  --------------

                l_tplv_rec.SFWT_FLAG := 'N';
                l_tplv_rec.KLE_ID := p_kle_id;
--            l_tplv_rec.INV_DISTR_LINE_CODE := 'A' ; -- Need to find out from rina
            l_tplv_rec.INV_DISTR_LINE_CODE := 'ITEM' ; --| 03-Oct-2007 cklee   Fixed Bug 6469797                                        |
            l_tplv_rec.STY_ID := p_credit_sty_id;
                l_tplv_rec.TAP_ID := x_tapv_rec.id ;
                l_tplv_rec.AMOUNT := p_credit_amount;
                l_tplv_rec.LINE_NUMBER :=  1;
                l_tplv_rec.object_version_number := 1;
                /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start change*/
                l_tplv_rec.KHR_ID := p_khr_id ;
                /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End changes*/

                SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
                     DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
                     DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
                     DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
                     mo_global.get_current_org_id()  INTO l_tplv_rec.REQUEST_ID,
                          l_tplv_rec.PROGRAM_APPLICATION_ID,
                          l_tplv_rec.PROGRAM_ID,
                          l_tplv_rec.PROGRAM_UPDATE_DATE,
                          l_tplv_rec.ORG_ID FROM dual;


  ------------------------------------------------------------------------------------
  /*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start changes */
 IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_CREATE_DISB_TRANS_PVT.create_disb_trx ');
    END;
  END IF;

  l_tplv_tbl(0) := l_tplv_rec;

  OKL_CREATE_DISB_TRANS_PVT.create_disb_trx(p_api_version
                            ,p_init_msg_list     => p_init_msg_list
                            ,x_return_status     => l_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_tapv_rec         =>l_tapv_rec
                            ,p_tplv_tbl           =>l_tplv_tbl
                            ,x_tapv_rec          =>x_tapv_rec
                            ,x_tplv_tbl           =>x_tplv_tbl
                            );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_CREATE_DISB_TRANS_PVT.create_disb_trx ');
    END;
  END IF;

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
/*      22-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End changes */


  	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
  END insert_ap_request;



        PROCEDURE pay_comp_refund(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                  IN  ipyv_rec_type,
       x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
       )IS
        l_ret_status  varchar2(1) ;
       l_value       NUMBER ;
       l_contract_id  NUMBER;
       l_contract_line NUMBER;
       l_api_name CONSTANT VARCHAR2(30) := 'pay_comp_refund';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;
       l_amount  NUMBER;
       l_strm_type_id   NUMBER ;
       l_lsm_id         NUMBER;
       l_tai_id         NUMBER;



        CURSOR okl_trx_types(cp_name VARCHAR2,cp_language VARCHAR2) IS
         SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;


       p_name VARCHAR2(150) :='Credit Memo';
       p_lang VARCHAR2(2) := 'US' ;
       l_trx_type NUMBER ;
       l_sty_id  NUMBER ;


         CURSOR  C_OKL_STRM_TYPE_CRE_V IS
        select ID
         from OKL_STRM_TYPE_TL
         where NAME = 'INSURANCE REFUND'
         AND LANGUAGE = 'US';



         CURSOR  C_OKL_CNSLD_AR_STRMB IS
         SELECT SUM(STRE.AMOUNT)
         FROM OKL_STRM_ELEMENTS STRE, OKL_STREAMS STR
         WHERE STR.KHR_ID = P_IPYV_REC.KHR_ID
         AND STR.KLE_ID = P_IPYV_REC.KLE_ID
         AND STR.ID = STRE.STM_ID
         AND STRE.DATE_BILLED IS NOT NULL;

       BEGIN
               l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                       G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;



       --1. Stream id

          BEGIN



          OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
                   x_return_status := OKC_API.G_RET_STS_ERROR ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

          END;

         ---2 GET Transaction Type
        BEGIN

          OPEN okl_trx_types (p_name, p_lang);
          FETCH okl_trx_types INTO l_trx_type;
          IF(okl_trx_types%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
              G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,p_name);
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE okl_trx_types ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;
          CLOSE okl_trx_types;



          BEGIN

          /*OPEN C_OKL_STRM_TYPE_CRE_V;
          FETCH C_OKL_STRM_TYPE_CRE_V INTO l_strm_type_id;
          IF(C_OKL_STRM_TYPE_CRE_V%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
              G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE REFUND');
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_OKL_STRM_TYPE_CRE_V ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
           END if ;
          CLOSE C_OKL_STRM_TYPE_CRE_V;*/


           OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_REFUND',
                                                   l_return_status,
                                                   l_strm_type_id);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_REFUND');
                   x_return_status := OKC_API.G_RET_STS_ERROR ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

          END;

       --3. get Amount Received
          OPEN C_OKL_CNSLD_AR_STRMB;
          FETCH C_OKL_CNSLD_AR_STRMB INTO l_amount;
          IF(l_amount IS NOT NULL AND l_amount <> OKC_API.G_MISS_NUM ) THEN
             l_amount := - l_amount;
              -- Call API to create Credit Memo
-- Start of wraper code generated automatically by Debug code generator for okl_credit_memo_pub.insert_request
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call on_account_credit_memo');
    END;
  END IF;
         on_account_credit_memo
                                 (
                                 p_api_version     => l_api_version,
                                 p_init_msg_list   => OKL_API.G_FALSE,
                                 p_try_id        => l_trx_type,
                                 p_khr_id       =>      p_ipyv_rec.khr_id,
                                 p_kle_id       =>p_ipyv_rec.kle_id     ,
                                 p_ipy_id       =>p_ipyv_rec.ID ,
                                 p_credit_date  => p_ipyv_rec.CANCELLATION_DATE ,
                                 p_credit_amount  => l_amount,
                                 p_credit_sty_id  => l_strm_type_id,
                                 x_return_status   => L_return_status,
                                 x_msg_count       =>x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 x_tai_id          => l_tai_id  ) ;

  IF(IS_DEBUG_PROCEDURE_ON) THEN

 BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call on_account_credit_memo ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_credit_memo_pub.insert_request

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
           END if ;

        CLOSE C_OKL_CNSLD_AR_STRMB ;
      END;


  	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
       END pay_comp_refund;




        PROCEDURE delete_policy(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                  IN  ipyv_rec_type,
       x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
       )
       IS
       l_api_name CONSTANT VARCHAR2(30) := 'delete_policy';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       ls_check_tpi         VARCHAR2(3);
       l_id                 NUMBER ;
       l_ipyv_rec           ipyv_rec_type;

        CURSOR c_ins_info( p_ipy_id NUMBER) IS
       SELECT IPYB.KHR_ID, IPYB.KLE_ID ,IPYB.OBJECT_VERSION_NUMBER, ISS_CODE, IPY_TYPE ,FACTOR_CODE
       FROM OKL_INS_POLICIES_B IPYB
       WHERE IPYB.ID = p_ipy_id;
       l_khr_status  VARCHAR2(30) ;
        l_clev_rec			   okl_okc_migration_pvt.clev_rec_type;
       lx_clev_rec		       okl_okc_migration_pvt.clev_rec_type;
       l_klev_rec			   Okl_Kle_Pvt.klev_rec_type ;
       lx_klev_rec		       Okl_Kle_Pvt.klev_rec_type ;

       BEGIN

       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
        l_ipyv_rec := p_ipyv_rec ;

             OPEN c_ins_info(l_ipyv_rec.ID);
             FETCH c_ins_info INTO l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID ,l_ipyv_rec.OBJECT_VERSION_NUMBER, l_ipyv_rec.ISS_CODE, l_ipyv_rec.IPY_TYPE ,l_ipyv_rec.FACTOR_CODE  ;
             IF(c_ins_info%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_POLICY );
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_ins_info ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_ins_info ;

       -- Check for Third Party also
        IF(l_ipyv_rec.IPY_TYPE = 'THIRD_PARTY_POLICY') THEN
   	      OKC_API.set_message(G_APP_NAME, 'OKL_NO_DELETED' ); -- For Third party Error
  	      RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

       IF(l_ipyv_rec.ISS_CODE = 'ACTIVE') THEN
   	      OKC_API.set_message(G_APP_NAME, 'OKL_ACTIVE_POLICY' );
  	      RAISE OKC_API.G_EXCEPTION_ERROR;
       ELSE
                 -- PAY Customer Refund
                 pay_comp_refund(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec   => l_ipyv_rec ,
                      x_ipyv_rec => x_ipyv_rec );


          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
      --    l_ipyv_rec := x_ipyv_rec ;


               ---Inactivate all stream / accounting entries
                 Inactivate_open_items(
                         p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_contract_id   => l_ipyv_rec.khr_id ,
                      p_contract_line => l_ipyv_rec.kle_id,
                      p_policy_status =>  l_ipyv_rec.iss_code );

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

                              -- GET contract status
         	l_return_status :=	get_contract_status(l_ipyv_rec.khr_id, l_khr_status);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          IF (l_khr_status =  'ACTIVE' ) THEN
               -- if active, end date contract line and update status

               l_clev_rec.ID := l_ipyv_rec.kle_id ;
    		l_clev_rec.sts_code :=  'TERMINATED';
  		l_klev_rec.ID := l_ipyv_rec.kle_id ;
                l_clev_rec.END_DATE :=  l_ipyv_rec.CANCELLATION_DATE;


  		  Okl_Contract_Pub.update_contract_line
  		   (
      	   p_api_version      => l_api_version ,
  		   p_init_msg_list           => OKC_API.G_FALSE,
  		   x_return_status      => l_return_status    ,
  		   x_msg_count           => x_msg_count,
  		   x_msg_data            => x_msg_data ,
  		   p_clev_rec            => l_clev_rec  ,
  		   p_klev_rec            => l_klev_rec,
  		   p_edit_mode            =>'N'        ,
  		   x_clev_rec            => lx_clev_rec,
  		   x_klev_rec            => lx_klev_rec
  		   );

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                -- Status temp
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

                -- Status temp
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

              ELSE


                         l_clev_rec.ID := l_ipyv_rec.kle_id ;
	          		l_clev_rec.sts_code :=  'TERMINATED';
	        		l_klev_rec.ID := l_ipyv_rec.kle_id ;
	                      l_clev_rec.END_DATE :=  l_ipyv_rec.CANCELLATION_DATE;


	        		  Okl_Contract_Pub.update_contract_line
	        		   (
	            	   p_api_version      => l_api_version ,
	        		   p_init_msg_list           => OKC_API.G_FALSE,
	        		   x_return_status      => l_return_status    ,
	        		   x_msg_count           => x_msg_count,
	        		   x_msg_data            => x_msg_data ,
	        		   p_clev_rec            => l_clev_rec  ,
	        		   p_klev_rec            => l_klev_rec,
	        		   p_edit_mode            =>'N'        ,
	        		   x_clev_rec            => lx_clev_rec,
	        		   x_klev_rec            => lx_klev_rec
	        		   );

	                    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	                      -- Status temp
	                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

	                      -- Status temp
	                      RAISE OKC_API.G_EXCEPTION_ERROR;
	                    END IF;


              /*
              -- else call delete contract line
                             --Delete Line
                 OKL_CONTRACT_PUB.delete_contract_line(
                        p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                   p_line_id  => l_ipyv_rec.kle_id );

              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
              */



            END IF;
                 l_ipyv_rec.iss_code := 'DELETED';
                 --Update Policy

-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
            	   Okl_Ins_Policies_Pub.update_ins_policies(
  	         p_api_version                  => p_api_version,
  	          p_init_msg_list                => OKC_API.G_FALSE,
  	          x_return_status                => l_return_status,
  	          x_msg_count                    => x_msg_count,
  	          x_msg_data                     => x_msg_data,
  	          p_ipyv_rec                     => l_ipyv_rec,
  	          x_ipyv_rec                     => x_ipyv_rec
  	          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

                 -- send Notification to customer
                   --  To be implemented


       END IF;

       	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
      END delete_policy;



       PROCEDURE   calc_vendor_clawback(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                  IN  ipyv_rec_type,
       x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type,
       x_vendor_adjustment        OUT NOCOPY NUMBER
       )   IS
        l_api_name CONSTANT VARCHAR2(30) := 'calc_vendor_clawback';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       l_attribute_label    ak_attributes_tl.attribute_label_long%TYPE := NULL; -- 3927315

         CURSOR  c_okl_ins_asset IS
        select SUM(lessor_premium) -- Smoduga fix fro bug 4238141
         from OKL_INS_ASSETS  OINB
         where OINB.IPY_ID   = p_ipyv_rec.ID
         GROUP BY OINB.IPY_ID;


           CURSOR  C_OKL_STRM_TYPE_V (p_stream_type VARCHAR2)IS
            select ID
            from OKL_STRM_TYPE_V
            where code = p_stream_type;


          CURSOR c_total_paid(l_stm_type_id NUMBER)  IS
          SELECT SUM(STRE.AMOUNT)
            FROM  okl_strm_elements STRE, OKL_STREAMS STR
            WHERE STR.ID =  STRE.STM_ID
          AND STR.STY_ID = l_stm_type_id
          AND STRE.DATE_BILLED IS NOT NULL
          AND STR.KHR_ID = p_ipyv_rec.KHR_ID
          AND STR.KLE_ID = p_ipyv_rec.KLE_ID;


              l_tapv_rec              Okl_tap_pvt.tapv_rec_type;
              lx_tapv_rec             Okl_tap_pvt.tapv_rec_type;
              l_tplv_rec              okl_tpl_pvt.tplv_rec_type;
              lx_tplv_rec             okl_tpl_pvt.tplv_rec_type;

              li_months        NUMBER ;
              l_total_lessor_premium NUMBER;
              ln_premium         NUMBER;
              l_strm_type_id NUMBER;
             l_total_paid  NUMBER;
             ln_refund NUMBER ;
             l_amount  NUMBER ;
             l_to_refund NUMBER;
             l_tra_id    NUMBER;


        CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
        SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;

        l_trx_type_ID NUMBER ;



           CURSOR c_ins_opt_premium (p_covered_amount IN NUMBER) IS
	    SELECT  ((INSURER_RATE *  p_covered_amount )/100 )
	           FROM OKL_INS_POLICIES_B IPYB ,   OKL_INS_RATES INR
	       WHERE  IPYB.ipt_id = inr.ipt_id AND
	        kle_id = p_ipyv_rec.KLE_ID     and
	        khr_id   = p_ipyv_rec.KHR_ID
	        AND     IPYB.date_from between inr.date_FROM and DECODE(NVL(inr.date_TO,NULL),NULL,SYSDATE, inr.date_TO)
	        and    IPYB.territory_code = inr.ic_id
	        AND    IPYB.FACTOR_VALUE BETWEEN  inr.FACTOR_RANGE_START AND inr.FACTOR_RANGE_END ;


        l_functional_currency  okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;

	x_contract_currency   okl_k_headers_full_v.currency_code%TYPE;
	x_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
	x_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
	x_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;
	x_functional_covered_amt  NUMBER ;
	p_contract_currency      fnd_currencies_vl.currency_code%TYPE ;


         l_func_total_lessor_premium NUMBER;

         CURSOR c_con_start  IS
	         SELECT  start_date
	         FROM    okc_k_headers_b
	         WHERE   id      = p_ipyv_rec.KHR_ID ;
	 l_start_date DATE;



       BEGIN

         l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                    G_PKG_NAME,
                                                    p_init_msg_list,
                                                    l_api_version,
                                                    p_api_version,
                                                    '_PROCESS',
                                                    x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


       OPEN c_con_start;
       FETCH c_con_start INTO l_start_date;
       IF(c_con_start%NOTFOUND) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_VALUE', G_COL_NAME_TOKEN,'Contract Start Date');
                 x_return_status := OKC_API.G_RET_STS_ERROR ;
                  CLOSE c_con_start ;
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END if ;
       CLOSE c_con_start ;

     --- How much he should have been paid
     -- +++ EFF DATED TERMINATION CHANGES ++++++-----------
     -- If cancellation Reason is not cancelled by customer and policy type is Lease  ----
     IF p_ipyv_rec.crx_code <> 'CANCELED_BY_CUSTOMER'
                AND p_ipyv_rec.ipy_type = 'LEASE_POLICY' THEN -- [1]
     -- cancellation because of PreDated Termination
     -- If termination eff date is lesser than start date of Ins pOlicy then
     -- Calculate months between start date of insurance policy and Sysdate to get
       -- Months paid
        IF p_ipyv_rec.cancellation_date < p_ipyv_rec.date_from THEN -- [3]
            IF p_ipyv_rec.date_from < SYSDATE THEN
                li_months := MONTHS_BETWEEN(SYSDATE,p_ipyv_rec.date_from);
            ELSIF p_ipyv_rec.date_from > SYSDATE THEN
                li_months := 0;
            END IF;
        END IF; -- [3]
     ELSE
          li_months := MONTHS_BETWEEN( p_ipyv_rec.cancellation_date,p_ipyv_rec.date_from);
     END IF; -- [1]
     -- +++ EFF DATED TERMINATION CHANGES ++++++-----------
     --li_months := MONTHS_BETWEEN( p_ipyv_rec.cancellation_date,p_ipyv_rec.date_from);

  IF (p_ipyv_rec.ipy_type = 'LEASE_POLICY') THEN
     -- Select premium from insured_asset table
       OPEN c_okl_ins_asset;
       FETCH c_okl_ins_asset INTO l_total_lessor_premium;
       IF(c_okl_ins_asset%NOTFOUND) THEN
          Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_POLICY', G_COL_NAME_TOKEN,p_ipyv_rec.ID);
          x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE c_okl_ins_asset ;
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END if ;
       CLOSE c_okl_ins_asset ;
    ELSE

         -- Covered amount from contract to functional

         OKL_ACCOUNTING_UTIL.convert_to_functional_currency
	 	 (
	 	  p_ipyv_rec.khr_id,
	 	  l_functional_currency ,
	 	  l_start_date,
	 	  p_ipyv_rec.COVERED_AMOUNT,
	 	  x_contract_currency  ,
	 	  x_currency_conversion_type ,
	 	  x_currency_conversion_rate  ,
	 	  x_currency_conversion_date,
	 	  x_functional_covered_amt  ) ;

                x_functional_covered_amt :=
	      okl_accounting_util.cross_currency_round_amount(p_amount =>
	      x_functional_covered_amt,
               p_currency_code => l_functional_currency);

           OPEN c_ins_opt_premium (x_functional_covered_amt);
	       FETCH c_ins_opt_premium INTO l_func_total_lessor_premium;
	       IF(c_ins_opt_premium%NOTFOUND) THEN
	          Okc_Api.set_message(G_APP_NAME, 'OKL_NO_OPTINSPRODUCT_RATE');--Fix for 3745151
	          x_return_status := OKC_API.G_RET_STS_ERROR ;
	           CLOSE c_okl_ins_asset ;
	          RAISE OKC_API.G_EXCEPTION_ERROR;
	       END if ;

	   --- total lessor premium from functional to contract currency
	     OKL_ACCOUNTING_UTIL.convert_to_contract_currency
	   	(
	   	p_ipyv_rec.khr_id,
	   	l_functional_currency,
	   	p_ipyv_rec.date_from,
	   	l_func_total_lessor_premium,
	   	x_contract_currency  ,
	   	x_currency_conversion_type ,
	   	x_currency_conversion_rate  ,
	   	x_currency_conversion_date,
	   	l_total_lessor_premium ) ;

	   	l_total_lessor_premium :=
		okl_accounting_util.cross_currency_round_amount(p_amount =>
		l_total_lessor_premium,
               p_currency_code => x_contract_currency);

    END IF ;


      -- Money should have been paid (System profile)
       ln_premium  := li_months * l_total_lessor_premium ;
       -- How much have we paid him

          /*OPEN C_OKL_STRM_TYPE_V('INSURANCE PAYABLE');
          FETCH C_OKL_STRM_TYPE_V INTO l_strm_type_id;
          IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
              G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE PAYABLE');
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_OKL_STRM_TYPE_V ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
           END if ;
          CLOSE C_OKL_STRM_TYPE_V;*/
          -- cursor fetch replaced with the call to get the stream type id
            OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_strm_type_id);
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                        RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;



          OPEN c_total_paid(l_strm_type_id);
          FETCH c_total_paid INTO l_total_paid;
          IF(c_total_paid%NOTFOUND) THEN
              l_total_paid := 0 ;
           END if ;
          CLOSE c_total_paid;


          IF (ln_premium < l_total_paid) THEN

                   -- cursor fetch replaced with the call to get the stream type id
                   -- changed for use defined streams bug 3924300
                     OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_ADJUSTMENT',
                                                   l_return_status,
                                                   l_strm_type_id);

               IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN, 'INSURANCE_ADJUSTMENT'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;



              ln_refund := l_total_paid - ln_premium ;

            -- GET MONEY BACK FROM VENDOR

                      l_to_refund := -ln_refund ;

                          -- GET TRANSACTION TYPE
                      OPEN c_trx_type ('Debit Memo', 'US');
                      FETCH c_trx_type INTO l_trx_type_ID;
                      IF(c_trx_type%NOTFOUND) THEN
                           Okc_Api.set_message(G_APP_NAME, 'OKL_AM_NO_TRX_TYPE_FOUND',
                           'TRY_NAME','Debit Memo'); --Changed message code for bug 3745151
                           x_return_status := OKC_API.G_RET_STS_ERROR ;
                           CLOSE c_trx_type ;
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                     END if ;
                  CLOSE c_trx_type;
                      -- Call API to create Debit Memo
                      insert_ap_request(p_api_version     => l_api_version,
                            p_init_msg_list   => OKL_API.G_FALSE,
                            x_return_status   => l_return_status,
                            x_msg_count       =>x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_tap_id          => l_tra_id,
                          p_credit_amount   => l_to_refund,
                           p_credit_sty_id  => l_strm_type_id,
                           p_khr_id         =>  p_ipyv_rec.khr_id,
                           p_kle_id         => p_ipyv_rec.kle_id,
                           p_invoice_date   => SYSDATE,
                           p_trx_id         => l_trx_type_ID   );

                     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

          ELSIF (ln_premium > l_total_paid) THEN
                l_tra_id := OKC_API.G_MISS_NUM ;
                l_to_refund := ln_premium - l_total_paid ;

                -- cursor fetch replaced with the call to get the stream type id
                -- changed for user defined sreams, bug 3924300
                  OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;



                                        -- GET TRANSACTION TYPE
                      OPEN c_trx_type ('Disbursement', 'US');
                      FETCH c_trx_type INTO l_trx_type_ID;
                      IF(c_trx_type%NOTFOUND) THEN
                     l_attribute_label := OKL_ACCOUNTING_UTIL.get_message_token('OKL_LA_SEC_INVESTOR','OKL_LA_SEC_BILL'); --3927315
                           Okc_Api.set_message(G_APP_NAME, 'OKL_AM_NO_TRX_TYPE_FOUND',
                           'TRY_NAME',l_attribute_label); -- 3745151
                           l_attribute_label := null;
                           x_return_status := OKC_API.G_RET_STS_ERROR ;
                           CLOSE c_trx_type ;
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                     END if ;
                     CLOSE c_trx_type ;

                         insert_ap_request(p_api_version     => l_api_version,
                          p_init_msg_list   => OKL_API.G_FALSE,
                            x_return_status   => l_return_status,
                            x_msg_count       =>x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_tap_id          => l_tra_id,
                          p_credit_amount   => l_to_refund,
                           p_credit_sty_id   => l_strm_type_id,
                           p_khr_id         =>  p_ipyv_rec.khr_id,
                           p_kle_id         => p_ipyv_rec.kle_id,
                           p_invoice_date  => SYSDATE,
                            p_trx_id         => l_trx_type_ID   );

                     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
          END IF ;
     	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
       END calc_vendor_clawback ;

      PROCEDURE   Inactivate_open_items(

       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_contract_id                  IN  NUMBER,
       p_contract_line            IN NUMBER,
       p_policy_status            IN VARCHAR2
       )
       IS
       l_api_name CONSTANT VARCHAR2(30) := 'Inactivate_open_items';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;

       l_recv_strm_id NUMBER ;
       l_payb_strm_id NUMBER ;
       l_paybacc_strm_id NUMBER ;
       l_recvacc_strm_id NUMBER ;
       ls_strm_type    VARCHAR2(30);
       ls_strm_purpose varchar2(100);


       l_stream_element_id NUMBER ;
       l_stream NUMBER ;

  --- For Recievables
       CURSOR c_okl_strem_rec(l_recv_strm_id NUMBER) IS
       SELECT STM.ID
       FROM  OKL_STREAMS STM
       WHERE  STM.STY_ID = l_recv_strm_id
      AND STM.KLE_ID = p_contract_line
      AND STM.KHR_ID = p_contract_id;



    ---- For accrual
    CURSOR c_okl_strem_rec_acc (l_recv_strm_id NUMBER) IS
       SELECT STM.ID
       FROM  OKL_STREAMS STM
       WHERE  STM.STY_ID = l_recv_strm_id
      AND STM.KLE_ID = p_contract_line
      AND STM.KHR_ID = p_contract_id
      AND STM.PURPOSE_CODE IS NULL;


    ---- For Reporting accrual
    CURSOR c_okl_strem_rec_repacc (l_recv_strm_id NUMBER) IS
       SELECT STM.ID
       FROM  OKL_STREAMS STM
       WHERE  STM.STY_ID = l_recv_strm_id
      AND STM.KLE_ID = p_contract_line
      AND STM.KHR_ID = p_contract_id
      AND STM.PURPOSE_CODE ='REPORT';


       CURSOR c_okl_strem_type_rec(ls_strm_type VARCHAR2) IS
       select ID
       from   OKL_STRM_TYPE_TL
       where NAME = ls_strm_type
       AND LANGUAGE = 'US';

    	p_stmv_rec			Okl_Streams_Pub.stmv_rec_type;
  	x_stmv_rec		        Okl_Streams_Pub.stmv_rec_type;

       BEGIN
            l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- Setup data
       p_stmv_rec.ACTIVE_YN  := 'N' ;
       p_stmv_rec.SAY_CODE := 'HIST';
       p_stmv_rec.DATE_HISTORY := SYSDATE ;

       -- Receivable
       ls_strm_type := 'INSURANCE RECEIVABLE' ;
        ls_strm_purpose := 'INSURANCE_RECEIVABLE';


        -- cursor fetch replaced with the call to get the stream type id
        -- changed for user defined streams, bug 3924300

                  OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   ls_strm_purpose,
                                                   l_return_status,
                                                   l_recv_strm_id);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_COL_NAME_TOKEN,ls_strm_purpose);
		  RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


       ---
       OPEN c_okl_strem_rec(l_recv_strm_id);
       FETCH c_okl_strem_rec INTO  p_stmv_rec.id;
  	 IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN

-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
              OKL_STREAMS_PUB.update_streams(
                  p_api_version
                 ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_stmv_rec
                  ,x_stmv_rec
               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              CLOSE c_okl_strem_rec ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              CLOSE c_okl_strem_rec ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
       CLOSE c_okl_strem_rec ;

       -- Receivable Accounting
       p_stmv_rec := Okl_StM_PVT.g_miss_stmv_rec;

      ls_strm_type := 'INSURANCE INCOME' ;
      ls_strm_purpose := 'INSURANCE_INCOME_ACCRUAL';

       p_stmv_rec.ACTIVE_YN  := 'N' ;
       p_stmv_rec.SAY_CODE := 'HIST';
       p_stmv_rec.DATE_HISTORY := SYSDATE ;



        -- cursor fetch replaced with the call to get the stream type id
        -- changed for user defined streams, bug 3924300
                   OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   ls_strm_purpose,
                                                   l_return_status,
                                                   l_recv_strm_id);

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,ls_strm_purpose); --bug 4024785
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;



       --- For Accrual
       OPEN c_okl_strem_rec_acc(l_recv_strm_id);
       FETCH c_okl_strem_rec_acc INTO  p_stmv_rec.id;
  	 IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
              OKL_STREAMS_PUB.update_streams(
                  p_api_version
                 ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_stmv_rec
                  ,x_stmv_rec
               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              CLOSE c_okl_strem_rec_acc ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              CLOSE c_okl_strem_rec_acc ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
       CLOSE c_okl_strem_rec_acc ;


       --- For Reporing Accrual
              OPEN c_okl_strem_rec_repacc(l_recv_strm_id);
              FETCH c_okl_strem_rec_repacc INTO  p_stmv_rec.id;
         	 IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
                     OKL_STREAMS_PUB.update_streams(
                         p_api_version
                        ,p_init_msg_list
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,p_stmv_rec
                         ,x_stmv_rec
                      );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     CLOSE c_okl_strem_rec_repacc ;
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     CLOSE c_okl_strem_rec_repacc ;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
               END IF;
       CLOSE c_okl_strem_rec_repacc ;


   IF  (p_policy_status = 'ACTIVE') THEN
         -- payable
           p_stmv_rec := Okl_StM_PVT.g_miss_stmv_rec;
           p_stmv_rec.ACTIVE_YN  := 'N' ;
           p_stmv_rec.SAY_CODE := 'HIST';
           p_stmv_rec.DATE_HISTORY := SYSDATE ;

           ls_strm_type := 'INSURANCE PAYABLE' ;
            ls_strm_purpose := 'INSURANCE_PAYABLE';

         -- cursor fetch replaced with the call to get the stream type id,
         -- changed for user defined streams, Bug 3924300

              OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   ls_strm_purpose,
                                                   l_return_status,
                                                   l_recv_strm_id);

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,ls_strm_purpose); --bug 4024785
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;


          OPEN c_okl_strem_rec(l_recv_strm_id);
           FETCH c_okl_strem_rec INTO  p_stmv_rec.id;
  	     IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
              OKL_STREAMS_PUB.update_streams(
                  p_api_version
                 ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_stmv_rec
                  ,x_stmv_rec
               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              CLOSE c_okl_strem_rec ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              CLOSE c_okl_strem_rec ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
       CLOSE c_okl_strem_rec ;


       -- Payable Accounting
        p_stmv_rec := Okl_StM_PVT.g_miss_stmv_rec;
       p_stmv_rec.ACTIVE_YN  := 'N' ;
       p_stmv_rec.SAY_CODE := 'HIST';
       p_stmv_rec.DATE_HISTORY := SYSDATE ;


         ls_strm_type := 'INSURANCE EXPENSE' ;
         ls_strm_purpose := 'INSURANCE_EXPENSE_ACCRUAL';


       -- cursor fetch replaced with the call to get the stream type id,
       -- changed for user defined streams, bug 3924300

             OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   ls_strm_purpose,
                                                   l_return_status,
                                                   l_recv_strm_id);

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN ,ls_strm_purpose); --bug 4024785
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;



       --- For Accrual
       OPEN c_okl_strem_rec_acc(l_recv_strm_id);
       FETCH c_okl_strem_rec_acc INTO  p_stmv_rec.id;
  	 IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
              OKL_STREAMS_PUB.update_streams(
                  p_api_version
                 ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_stmv_rec
                  ,x_stmv_rec
               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              CLOSE c_okl_strem_rec_acc ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              CLOSE c_okl_strem_rec_acc ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
       CLOSE c_okl_strem_rec_acc ;



   --- For Reporting Accrual
       OPEN c_okl_strem_rec_repacc(l_recv_strm_id);
       FETCH c_okl_strem_rec_repacc INTO  p_stmv_rec.id;
  	 IF(p_stmv_rec.id IS NOT NULL AND p_stmv_rec.id <> OKC_API.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
              OKL_STREAMS_PUB.update_streams(
                  p_api_version
                 ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_stmv_rec
                  ,x_stmv_rec
               );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_STREAMS_PUB.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAMS_PUB.update_streams

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              CLOSE c_okl_strem_rec_repacc ;
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              CLOSE c_okl_strem_rec_repacc ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
        END IF;
       CLOSE c_okl_strem_rec_repacc ;

      END IF;

   OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
       END Inactivate_open_items ;


    PROCEDURE cancel_policies(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_contract_id                  IN  NUMBER,
       p_cancellation_date            IN DATE
       ,p_crx_code                     IN VARCHAR2 DEFAULT NULL --++++++++ Effective Dated Term Qte changes  +++++++++
       )
       IS

       l_api_name CONSTANT VARCHAR2(30) := 'cancel_policies';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       l_ipyv_rec                  ipyv_rec_type;
       lx_ipyv_rec                  ipyv_rec_type;
       l_cancellation_date   DATE ;

       -- 3976894 Modified cursor to fetch Pending policies and also
       -- 3976894 get the ISS_CODE in the select clause.
       CURSOR c_okl_ins_policies(p_contract_id NUMBER) IS
       SELECT ID, IPY_TYPE, ISS_CODE
       FROM OKL_INS_POLICIES_B
       WHERE KHR_ID = p_contract_id
       and ISS_CODE in ('ACTIVE','PENDING');

       BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- Check for contract_id (NULL)
       IF ((p_contract_id IS NULL ) OR (p_contract_id = OKC_API.G_MISS_NUM )) THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Contract ID');
          RAISE OKC_API.G_EXCEPTION_ERROR;

      END IF;



       -- Check for Date put SYSDATE if NULL
       l_cancellation_date := p_cancellation_date ;
       IF ((l_cancellation_date IS NULL ) OR (l_cancellation_date = OKC_API.G_MISS_DATE )) THEN

       l_cancellation_date := SYSDATE;

       END IF;




       OPEN c_okl_ins_policies(p_contract_id);


       --------------
        LOOP

  	  -- 3976894 Modified to fetch ISS_CODE
           FETCH c_okl_ins_policies INTO l_ipyv_rec.ID, l_ipyv_rec.IPY_TYPE, l_ipyv_rec.ISS_CODE;
           EXIT WHEN c_okl_ins_policies%NOTFOUND;
           IF  (l_ipyv_rec.IPY_TYPE IS NULL) OR (l_ipyv_rec.IPY_TYPE = OKC_API.G_MISS_CHAR) THEN
            NULL;

           ELSIF( l_ipyv_rec.IPY_TYPE <> 'THIRD_PARTY_POLICY' )THEN
              --l_ipyv_rec.crx_code := 'CONTRACT_CANCELED' ;
              ---+++ Effective dated Termination Changes Start+++++------
              IF (p_crx_code IS NOT NULL) OR (p_crx_code <> OKC_API.G_MISS_CHAR ) THEN
              l_ipyv_rec.crx_code := p_crx_code;--'CONTRACT_CANCELED' ;
              END IF;
              ---+++ Effective dated Termination Changes End +++++------
              l_ipyv_rec.cancellation_date := p_cancellation_date;

               -- bug 3976894 : Added check for policy status and cancel in
             -- case of Active else set the policy status to deleted
             -- by calling delete policy.
             IF (l_ipyv_rec.ISS_CODE = 'ACTIVE') THEN
              cancel_policy(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec      => l_ipyv_rec,
                      x_ipyv_rec      => lx_ipyv_rec);
             ELSIF(l_ipyv_rec.ISS_CODE = 'PENDING') THEN
             delete_policy(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec      => l_ipyv_rec,
                      x_ipyv_rec      => lx_ipyv_rec);
            END IF;
          END IF;
         END LOOP ;
         CLOSE c_okl_ins_policies ;
          OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
      END cancel_policies;

-------------------------------------------------------------------------------------
          		   --Validate Cancel_policy
--------------------------------------------------------------------------------
 --Added as part of bug 4056603
      FUNCTION  Validate_Cancel_Policy
                         (p_chr_id    IN  NUMBER) RETURN VARCHAR2 IS
        l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Cancel_Policy';
        l_api_version	    CONSTANT NUMBER	:= 1.0;
        x_cancel_flag     VARCHAR2(1) := 'N';
      --ger Max version
      CURSOR c_get_chr_version(cp_chr_id NUMBER) IS
      SELECT MAX(major_version)
      FROM   OKC_K_HEADERS_BH
      WHERE  id = cp_chr_id;
      --- Check for addition  of the fixed asset line
      -- gboomina Bug 5015042 - Start
      -- Changing where condition to handle more than one asset
      -- gboomina Bug 5054871 - Start
      -- Changing Cursor definition to check asset category of
      -- asset with Insurance Product.
      CURSOR c_asset_addition(cp_chr_id NUMBER) IS
       SELECT 'X'
       FROM OKL_K_ASSETS_UV NEW_ASST
       WHERE
            NEW_ASST.KLE_ID not in
              (SELECT INA.KLE_ID
              FROM
              OKL_INS_ASSETS INA,
              OKL_INS_POLICIES_B IPY
              WHERE
              IPY.KHR_ID = cp_chr_id
              AND IPY.ID =  INA.IPY_ID
              AND IPY.ISS_CODE IN ( 'PENDING', 'ACTIVE')
              )
       AND NEW_ASST.CONTRACT_ID = cp_chr_id
       AND ROWNUM  = 1;
      -- gboomina Bug 5054871 - End
      -- gboomina Bug 5015042 - End
      ---  Check for termination of the fixed asset line
      CURSOR c_asset_termination(cp_chr_id NUMBER) IS
       SELECT 'X'
       FROM OKL_INS_ASSETS INA,
       OKC_K_LINES_B FINAC_CLE,
       OKC_LINE_STYLES_B FINAC_LS ,
       OKL_INS_POLICIES_B IPY
       WHERE FINAC_CLE.ID = INA.KLE_ID
       AND FINAC_LS.LTY_CODE = 'FREE_FORM1'
       AND FINAC_CLE.LSE_ID = FINAC_LS.ID
       AND FINAC_CLE.STS_CODE <>  'BOOKED'
       AND IPY.KHR_ID = FINAC_CLE.chr_id
       AND IPY.ID =  INA.IPY_ID
       AND FINAC_CLE.chr_id = cp_chr_id
       AND IPY.ISS_CODE IN ( 'PENDING', 'ACTIVE')
       AND ROWNUM  = 1;
      -- Quantity change
      CURSOR c_quantity_changed(cp_chr_id NUMBER,cp_major_version NUMBER) IS
      SELECT  'X'
      FROM
              OKC_K_LINES_B     C_CLE,
              OKC_K_ITEMS       C_CIT,
              OKC_K_ITEMS_H     H_CIT,
              OKC_LINE_STYLES_B C_LSE,
              OKL_INS_POLICIES_B IPY,
              OKL_INS_ASSETS INA
      WHERE   c_cle.dnz_chr_id = cp_chr_id
      AND     c_cle.id         = c_cit.cle_id
      AND     c_cle.lse_id     = c_lse.id
      AND     c_cit.id         = h_cit.id
      AND     c_lse.lty_code    = 'FIXED_ASSET'
      AND     c_cit.jtot_object1_code = 'OKX_ASSET'
      AND h_cit.MAJOR_VERSION = cp_major_version
      AND c_cit.number_of_items <> h_cit.number_of_items
      AND INA.KLE_ID = c_cle.CLE_ID
      AND IPY.KHR_ID = c_cle.dnz_chr_id
      AND IPY.ID =  INA.IPY_ID
      AND IPY.ISS_CODE IN ( 'PENDING', 'ACTIVE')
      AND ROWNUM  = 1;
      -- Unit Cost Changed
      CURSOR c_get_unit_price(cp_chr_id NUMBER, cp_version NUMBER) IS
      SELECT  'X'
      FROM    OKC_K_LINES_B     C_CLE,
              OKC_K_LINES_BH    H_CLE,
              OKC_LINE_STYLES_B C_LSE,
              OKL_K_LINES       c_kle,
              OKL_K_LINES_H     h_kle ,
              OKL_INS_POLICIES_B IPY,
              OKL_INS_ASSETS INA
      WHERE   c_cle.dnz_chr_id = cp_chr_id
      AND     c_cle.id         = h_cle.id
      AND     c_cle.lse_id     = c_lse.id
      AND     c_cle.id         = c_kle.id
      AND     h_kle.id         = c_kle.id
      AND     h_cle.major_version = cp_version
      AND     c_lse.lty_code    = 'FIXED_ASSET'
      AND c_cle.price_unit <> h_cle.price_unit
      AND INA.KLE_ID = c_cle.CLE_ID
      AND IPY.KHR_ID = c_cle.dnz_chr_id
      AND IPY.ID =  INA.IPY_ID
      AND IPY.ISS_CODE IN ( 'PENDING', 'ACTIVE')
      AND ROWNUM  = 1;
      --- Location Change
      -- get start date and  term
      CURSOR c_get_chr_start_end_date(cp_version NUMBER,cp_chr_id NUMBER) IS
      SELECT  c_chr.START_DATE c_start_date,h_chr.START_DATE h_start_date,
              round (months_between(c_chr.end_date,c_chr.START_DATE)) c_term,
              round (months_between(h_chr.end_date,h_chr.START_DATE)) h_term
      FROM    OKC_K_HEADERS_B    C_CHR,
              OKC_K_HEADERS_BH   H_CHR
      WHERE   c_chr.id             = h_chr.id
      AND     h_chr.major_version  = cp_version
      AND     c_chr.id             = cp_chr_id
      AND ROWNUM  = 1;
      l_version         NUMBER;
      l_line_version    NUMBER;
      l_c_start_date    DATE;
      l_h_start_date    DATE;
      l_c_term          NUMBER;
      l_h_term          NUMBER;
      l_flag     VARCHAR2(1) := 'N';
      BEGIN
           OPEN c_get_chr_version(p_chr_id);
           FETCH c_get_chr_version INTO l_version;
           CLOSE c_get_chr_version;
          -- for Addition check
           OPEN c_asset_addition(p_chr_id);
           FETCH c_asset_addition INTO l_flag;
           IF (l_flag = 'X' ) THEN
           	CLOSE c_asset_addition;
              x_cancel_flag := 'Y' ;
              RETURN (x_cancel_flag);
           END IF ;
           CLOSE c_asset_addition;
           -- for asset termination
           OPEN c_asset_termination(p_chr_id);
           FETCH c_asset_termination INTO l_flag;
           IF (l_flag = 'X' ) THEN
                CLOSE c_asset_termination;
                x_cancel_flag := 'Y' ;
                RETURN (x_cancel_flag);
            END IF ;
            CLOSE c_asset_termination;
           -- gboomina Bug 5188230 - Start
	          -- Passing correct values to c_quantity_changed cursor
           OPEN c_quantity_changed( p_chr_id, l_version);
           -- gboomina Bug 5188230 - End
                FETCH c_quantity_changed INTO l_flag;
                IF (l_flag = 'X' ) THEN
                     CLOSE c_quantity_changed;
                     x_cancel_flag := 'Y' ;
                     RETURN (x_cancel_flag);
                 END IF ;
            CLOSE c_quantity_changed;
           OPEN c_get_unit_price(p_chr_id, l_version);
                     FETCH c_get_unit_price INTO l_flag;
                     IF (l_flag = 'X' ) THEN
                          CLOSE c_get_unit_price;
                          x_cancel_flag := 'Y' ;
                          RETURN (x_cancel_flag);
                      END IF ;
            CLOSE c_get_unit_price;
           OPEN c_get_chr_start_end_date(l_version,p_chr_id);
           FETCH c_get_chr_start_end_date INTO l_c_start_date,l_h_start_date,l_c_term,l_h_term;
           CLOSE c_get_chr_start_end_date;
           IF (l_c_start_date <> l_h_start_date) OR (l_c_term <> l_h_term) THEN
             x_cancel_flag := 'Y';
             RETURN(x_cancel_flag);
           ELSE
             x_cancel_flag := 'N';
             RETURN(x_cancel_flag);
           END IF;
             EXCEPTION
                   WHEN OTHERS THEN
                     		x_cancel_flag	 := 'N';
              	    		RETURN(x_cancel_flag);
END Validate_Cancel_Policy;


----------------------------------------------
    		 --- Function get_insurance_info
----------------------------------------------
 --++ Added as part of fix for bug 4056603 ++--
FUNCTION get_insurance_info(p_ipy_id IN NUMBER,
                            x_return_status OUT NOCOPY  VARCHAR2 ) RETURN ipyv_rec_type IS
    --Skgautam:4542203 : added IPYB.iss_code
    CURSOR c_ins_info( c_ipy_id NUMBER) IS
           SELECT IPYB.KHR_ID, IPYB.KLE_ID ,IPYB.OBJECT_VERSION_NUMBER, IPYB.date_from,
                  IPYB.ipy_type,IPYB.factor_code,IPYB.IPF_CODE,IPYB.date_to,IPYB.premium,IPYB.COVERED_AMOUNT,IPYB.ISS_CODE
           FROM OKL_INS_POLICIES_B IPYB
           WHERE IPYB.ID = c_ipy_id;

        lx_ipyv_rec           ipyv_rec_type;

 BEGIN
         lx_ipyv_rec.id := p_ipy_id;
         --Skgautam:4542203 : fetched IPYB.iss_code
         OPEN c_ins_info(p_ipy_id);
         FETCH c_ins_info INTO lx_ipyv_rec.KHR_ID , lx_ipyv_rec.KLE_ID
                ,lx_ipyv_rec.OBJECT_VERSION_NUMBER, lx_ipyv_rec.date_from, lx_ipyv_rec.ipy_type,
                lx_ipyv_rec.FACTOR_CODE,lx_ipyv_rec.IPF_CODE,lx_ipyv_rec.date_to,lx_ipyv_rec.premium,
                lx_ipyv_rec.covered_amount,lx_ipyv_rec.iss_code;
           IF(c_ins_info%NOTFOUND) THEN
                Okc_Api.set_message(G_APP_NAME, G_INVALID_POLICY );
                x_return_status := OKC_API.G_RET_STS_ERROR ;
         CLOSE c_ins_info ;
              RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF ;
           CLOSE c_ins_info ;
           RETURN lx_ipyv_rec;
         EXCEPTION
             WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  	 -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  RETURN NULL;
END get_insurance_info;
----------------------------------------------------------
       -- Calculate customer Refund
-----------------------------------------------------------
FUNCTION get_cust_refund(p_ipyv_rec IN ipyv_rec_type,
                         x_return_status OUT NOCOPY  VARCHAR2) RETURN NUMBER IS
       l_stm_type_rcvbl_id             OKL_STRM_TYPE_TL.ID%TYPE := 0;
       l_no_of_rec                      NUMBER := 0;
       l_monthly_premium                NUMBER;
       l_freq_factor                    NUMBER;
       l_vld_cncl_dt                    VARCHAR2(1) := '?';
       l_total_manual_invoice_months    NUMBER;
       l_total_num_months_paid          NUMBER;
       lx_refund_amount                 NUMBER;
       l_unconsumed_months              NUMBER;
       l_total_consumed_months          NUMBER;
       l_ipyv_rec                       ipyv_rec_type;
       -- gboomina Bug 4885759 - Added - Start
       l_no_days_in_last_month          NUMBER;
       l_return_status                  VARCHAR2(1);
       -- gboomina Bug 4885759 - End

       --Get total amount paid by the customer
        CURSOR c_total_amount_paid (c_sty_id NUMBER,c_contract_id NUMBER,c_contract_line_id NUMBER)IS
        SELECT COUNT(*)
        FROM  okl_strm_elements STRE, OKL_STREAMS STR
        WHERE STR.ID =  STRE.STM_ID
            AND STR.STY_ID = c_sty_id
            AND STRE.DATE_BILLED IS NOT NULL
            AND STR.KHR_ID = c_contract_id
            AND STR.KLE_ID = c_contract_line_id;
        CURSOR  C_OKL_STRM_TYPE_V(ls_stm_code VARCHAR2) IS
        SELECT ID
        FROM   OKL_STRM_TYPE_TL
        WHERE  NAME  = ls_stm_code
           AND LANGUAGE = 'US';
       BEGIN
       l_ipyv_rec := p_ipyv_rec;
       OPEN C_OKL_STRM_TYPE_V('INSURANCE RECEIVABLE');
              FETCH C_OKL_STRM_TYPE_V INTO l_stm_type_rcvbl_id;
              IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE RECEIVABLE');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE C_OKL_STRM_TYPE_V ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF ;
          CLOSE C_OKL_STRM_TYPE_V;
        -- get total amount received from customer
            OPEN c_total_amount_paid(l_stm_type_rcvbl_id,l_ipyv_rec.KHR_ID,l_ipyv_rec.KLE_ID) ;
            FETCH c_total_amount_paid INTO l_no_of_rec;
                IF(c_total_amount_paid%NOTFOUND) THEN
                    l_no_of_rec := 0;
                END IF ;
            CLOSE c_total_amount_paid;
            -- get freq factor for the payment frequency
             IF(l_ipyv_rec.IPF_CODE = 'MONTHLY') THEN
                    l_freq_factor := 1;
             ELSIF(l_ipyv_rec.IPF_CODE = 'BI_MONTHLY') THEN
                    l_freq_factor := 1/2;
             ELSIF(l_ipyv_rec.IPF_CODE = 'HALF_YEARLY') THEN
                    l_freq_factor := 6;
             ELSIF(l_ipyv_rec.IPF_CODE = 'QUARTERLY') THEN
                     l_freq_factor := 3;
             ELSIF(l_ipyv_rec.IPF_CODE = 'YEARLY') THEN
                     l_freq_factor := 12;
             ELSIF(l_ipyv_rec.IPF_CODE = 'LUMP_SUM') THEN
                     l_freq_factor :=   ROUND(MONTHS_BETWEEN( l_ipyv_rec.date_to,l_ipyv_rec.date_from));
             END IF;
             -- get monthly premium
            l_monthly_premium   := l_ipyv_rec.premium/l_freq_factor ;
           ----------------------------------------
            -- Caclulation of Refund Months
            -----------------------------------------
            -- get the number of months paid
            l_total_num_months_paid := l_freq_factor * l_no_of_rec;
            IF(( l_total_num_months_paid IS NULL) OR (l_total_num_months_paid = OKC_API.G_MISS_NUM )) THEN --[1]
                l_total_num_months_paid := 0 ;
            END IF ;
             -- check to see if the cancellation date is between the start and end date of the policy
             --SELECT 'X' INTO l_vld_cncl_dt  FROM DUAL
             --WHERE l_ipyv_rec.cancellation_date BETWEEN  l_ipyv_rec.date_from AND l_ipyv_rec.date_to;
             --Check rebook date between start and end date of policy
             --IF  l_vld_cncl_dt = 'X'  THEN --[1.2]
	     -- gboomina Bug 4994786 Changed - start
	     -- Instead of implicit cusor, used IF condition check
             IF l_ipyv_rec.cancellation_date >= l_ipyv_rec.date_from AND l_ipyv_rec.cancellation_date <= l_ipyv_rec.date_to THEN
	     -- gboomina Bug 4994786 - end
               -- gboomina Bug 4885759 - Start
	       -- Changed refund_amount calculation to get accurate amount.
               l_total_consumed_months := FLOOR(MONTHS_BETWEEN( l_ipyv_rec.cancellation_date,l_ipyv_rec.date_from));

               l_no_days_in_last_month :=  OKL_STREAM_GENERATOR_PVT.get_day_count(ADD_MONTHS(l_ipyv_rec.date_from,l_total_consumed_months),
                                      p_end_date      => l_ipyv_rec.cancellation_date,
                                      p_arrears       => 'Y',
                                      x_return_status => l_return_status);
               IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
               -- Refund Amount
	       lx_refund_amount := (l_total_num_months_paid - l_total_consumed_months)* l_monthly_premium - l_no_days_in_last_month * l_monthly_premium/30 ;
               -- gboomina Bug 4885759 - End
             ELSE -- If rebook is before start date of the policy
                   -- Issue complete refund
                   lx_refund_amount := l_total_num_months_paid * l_monthly_premium;
             END IF;-- [1.2]
         RETURN(lx_refund_amount);

       EXCEPTION
           WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        	 	     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        	 	     RETURN 0;
END get_cust_refund;
-----------------------------------------
-- Proceduren get_vendor_refund
--------------------------------------------
PROCEDURE  get_vendor_refund(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                     IN  ipyv_rec_type,
       pn_refund                      OUT NOCOPY NUMBER
       )   IS
       l_api_name CONSTANT VARCHAR2(30) := 'get_vendor_refund';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       l_start_date                   DATE;
       li_months                      NUMBER;
       l_vld_cncl_dt                  VARCHAR2(1) := '?';
       l_func_total_lessor_premium    NUMBER;
       l_total_lessor_premium         NUMBER;
       l_lessor_premium   	          NUMBER;
       ln_premium                     NUMBER;
       l_total_paid                   NUMBER;
       ln_refund                      NUMBER;
       l_amount                       NUMBER;
       l_to_refund                    NUMBER;
       l_tra_id                       NUMBER;
       l_pay_strm_type_id             NUMBER;
       l_Adj_strm_type_id             NUMBER;
       l_trx_type_id                  NUMBER;
       l_ipyv_rec                    ipyv_rec_type;
       l_attribute_label ak_attributes_tl.attribute_label_long%TYPE := NULL; --3927315

       CURSOR  c_con_start(c_khr_id NUMBER)IS
         SELECT  START_DATE
         FROM    okc_k_headers_b
         WHERE   id      = c_khr_id ;
       -- get lease premium
       CURSOR  c_okl_ins_asset IS
         SELECT  SUM(lessor_premium)
         FROM OKL_INS_ASSETS  OINB
         WHERE OINB.IPY_ID   = p_ipyv_rec.ID
         GROUP BY OINB.IPY_ID;
          -- calculate total amount paid to vendor
       CURSOR c_total_paid(p_stm_type_id NUMBER)  IS
         SELECT SUM(STRE.AMOUNT)
         FROM   okl_strm_elements STRE, OKL_STREAMS STR
         WHERE  STR.ID =  STRE.STM_ID
         AND    STR.STY_ID = p_stm_type_id
         AND    STRE.DATE_BILLED IS NOT NULL
         AND    STR.KHR_ID = p_ipyv_rec.KHR_ID
         AND    STR.KLE_ID = p_ipyv_rec.KLE_ID;

      CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
        SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;
        CURSOR c_ins_opt_premium (p_covered_amount IN NUMBER) IS
         SELECT  ((INSURER_RATE *  p_covered_amount )/100 )
	       FROM OKL_INS_POLICIES_B IPYB ,   OKL_INS_RATES INR
	       WHERE  IPYB.ipt_id = inr.ipt_id AND
	        kle_id = p_ipyv_rec.KLE_ID     and
	        khr_id   = p_ipyv_rec.KHR_ID
	        AND     IPYB.date_from between inr.date_FROM and DECODE(NVL(inr.date_TO,NULL),NULL,SYSDATE, inr.date_TO)
	        and    IPYB.territory_code = inr.ic_id
	        AND    IPYB.FACTOR_VALUE BETWEEN  inr.FACTOR_RANGE_START AND inr.FACTOR_RANGE_END ;

        l_functional_currency       okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;
	x_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
	x_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
	x_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
	x_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
	x_functional_covered_amt    NUMBER ;
	p_contract_currency         fnd_currencies_vl.currency_code%TYPE ;

  BEGIN

       l_ipyv_rec := p_ipyv_rec;
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                    G_PKG_NAME,
                                                    p_init_msg_list,
                                                    l_api_version,
                                                    p_api_version,
                                                    '_PROCESS',
                                                    x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

        OPEN c_con_start(l_ipyv_rec.khr_id);
        FETCH c_con_start INTO l_start_date;
        IF(c_con_start%NOTFOUND) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_VALUE', G_COL_NAME_TOKEN,'Contract Start Date');
                 x_return_status := OKC_API.G_RET_STS_ERROR ;
                  CLOSE c_con_start ;
                 RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF ;
        CLOSE c_con_start ;
              --- How much he should have been paid
    IF (p_ipyv_rec.ipy_type = 'LEASE_POLICY') THEN
     -- Select premium from insured_asset table
       OPEN c_okl_ins_asset;
       FETCH c_okl_ins_asset INTO l_lessor_premium;
       IF(c_okl_ins_asset%NOTFOUND) THEN
          Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_POLICY', G_COL_NAME_TOKEN,p_ipyv_rec.ID);
          x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE c_okl_ins_asset ;
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END if ;
       CLOSE c_okl_ins_asset ;

    ELSE
         -- Covered amount from contract to functional
         OKL_ACCOUNTING_UTIL.convert_to_functional_currency
	 	 (
	 	  p_ipyv_rec.khr_id,
	 	  l_functional_currency ,
	 	  l_start_date,
	 	  p_ipyv_rec.COVERED_AMOUNT,
	 	  x_contract_currency  ,
	 	  x_currency_conversion_type ,
	 	  x_currency_conversion_rate  ,
	 	  x_currency_conversion_date,
	 	  x_functional_covered_amt  ) ;
      x_functional_covered_amt :=
                  okl_accounting_util.cross_currency_round_amount(p_amount =>
                  x_functional_covered_amt,
      p_currency_code => l_functional_currency);
         OPEN c_ins_opt_premium (x_functional_covered_amt);
	       FETCH c_ins_opt_premium INTO l_func_total_lessor_premium;
	       IF(c_ins_opt_premium%NOTFOUND) THEN
	          Okc_Api.set_message(G_APP_NAME, 'OKL_INVALID_POLICY', G_COL_NAME_TOKEN,p_ipyv_rec.ID);
	          x_return_status := OKC_API.G_RET_STS_ERROR ;
	           CLOSE c_ins_opt_premium ;
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	       END if ;
	       --- total lessor premium from functional to contract currency
	     OKL_ACCOUNTING_UTIL.convert_to_contract_currency
	   	(
	   	p_ipyv_rec.khr_id,
	   	l_functional_currency,
	   	p_ipyv_rec.date_from,
	   	l_func_total_lessor_premium,
	   	x_contract_currency  ,
	   	x_currency_conversion_type ,
	   	x_currency_conversion_rate  ,
	   	x_currency_conversion_date,
	   	l_total_lessor_premium ) ;
	   	l_total_lessor_premium :=
		  okl_accounting_util.cross_currency_round_amount(p_amount =>
		  l_total_lessor_premium,
      p_currency_code => x_contract_currency);
    END IF ;
         	IF(p_ipyv_rec.ipf_code = 'MONTHLY') THEN
	            		l_total_lessor_premium :=  l_lessor_premium ;
	        ELSIF(p_ipyv_rec.ipf_code = 'BI_MONTHLY') THEN
	           l_total_lessor_premium :=  l_lessor_premium  * 2;
	        ELSIF(p_ipyv_rec.ipf_code = 'HALF_YEARLY') THEN
			l_total_lessor_premium :=  l_lessor_premium  / 6; 	--- ETC.
	        ELSIF(p_ipyv_rec.ipf_code = 'QUARTERLY') THEN
		   l_total_lessor_premium :=  l_lessor_premium  / 3;
	        ELSIF(p_ipyv_rec.ipf_code = 'YEARLY') THEN
			l_total_lessor_premium :=  l_lessor_premium  / 12;
         	END IF;

       -- Check if the cancellation date is in between start and end date
       --SELECT 'X' INTO l_vld_cncl_dt  FROM DUAL
       --WHERE l_ipyv_rec.cancellation_date BETWEEN  l_ipyv_rec.date_from AND l_ipyv_rec.date_to;
       --IF l_vld_cncl_dt = 'X'  THEN --[3]
       -- gboomina Bug 4994786 Changed - start
       -- Instead of implicit cusor, used IF condition check
       IF l_ipyv_rec.cancellation_date >= l_ipyv_rec.date_from AND l_ipyv_rec.cancellation_date <= l_ipyv_rec.date_to THEN
       -- gboomina Bug 4994786 - end
          li_months := MONTHS_BETWEEN( l_ipyv_rec.cancellation_date,l_ipyv_rec.date_from);
       ELSIF (l_ipyv_rec.cancellation_date <= l_ipyv_rec.date_from )  THEN
          li_months := 0;
       END IF;-- [3]

       -- Money should have been paid (System profile)
          ln_premium  := li_months * l_total_lessor_premium ;

       -- How much have we paid him
         -- cursor fetch replaced with the call to get the stream type id
            OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_pay_strm_type_id);
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE');
                        RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
          OPEN c_total_paid(l_pay_strm_type_id);
          FETCH c_total_paid INTO l_total_paid;
          IF(c_total_paid%NOTFOUND) THEN
              l_total_paid := 0 ;
          END IF ;
          CLOSE c_total_paid;
          IF ((l_total_paid IS NULL ) OR (l_total_paid = OKC_API.G_MISS_NUM )) THEN
	              l_total_paid := 0;
         END IF ;
              ln_refund := l_total_paid - ln_premium ;
              pn_refund:= ln_refund;
          IF (ln_premium < l_total_paid) THEN  -- clawback
                  OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_ADJUSTMENT',
                                                   l_return_status,
                                                   l_Adj_strm_type_id);
               IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN, 'INSURANCE_ADJUSTMENT'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

            -- GET MONEY BACK FROM VENDOR
                         l_to_refund := -ln_refund ;

                    -- GET TRANSACTION TYPE
                      OPEN c_trx_type ('Debit Memo', 'US');
                      FETCH c_trx_type INTO l_trx_type_id;
                      IF(c_trx_type%NOTFOUND) THEN
                           Okc_Api.set_message(G_APP_NAME, 'OKL_AM_NO_TRX_TYPE_FOUND',
                           'TRY_NAME','Debit Memo');-- 3745151
                           x_return_status := OKC_API.G_RET_STS_ERROR ;
                           CLOSE c_trx_type ;
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                     END if ;
                     CLOSE c_trx_type;

                   -- Call API to create Debit Memo
                      insert_ap_request(p_api_version     => l_api_version,
                            p_init_msg_list   => OKL_API.G_FALSE,
                            x_return_status   => l_return_status,
                            x_msg_count       =>x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_tap_id          => l_tra_id,
                            p_credit_amount   => l_to_refund,
                           p_credit_sty_id  => l_Adj_strm_type_id,
                           p_khr_id         =>  p_ipyv_rec.khr_id,
                           p_kle_id         => p_ipyv_rec.kle_id,
                           p_invoice_date   => SYSDATE,
                           p_trx_id         => l_trx_type_ID   );
                     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

           ELSIF (ln_premium > l_total_paid) THEN
                l_tra_id := OKC_API.G_MISS_NUM ;
                l_to_refund := ln_premium - l_total_paid ;
                OKL_STREAMS_UTIL.get_primary_stream_type(p_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_PAY_strm_type_id);
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
                -- GET TRANSACTION TYPE
                      OPEN c_trx_type('Disbursement', 'US');
                      FETCH c_trx_type INTO l_trx_type_ID;
                      IF(c_trx_type%NOTFOUND) THEN
                     l_attribute_label := OKL_ACCOUNTING_UTIL.get_message_token('OKL_LA_SEC_INVESTOR','OKL_LA_SEC_BILL'); --3927315
                           Okc_Api.set_message(G_APP_NAME, 'OKL_AM_NO_TRX_TYPE_FOUND',
                           'TRY_NAME',l_attribute_label); --3745151
                           l_attribute_label := null;
                           x_return_status := OKC_API.G_RET_STS_ERROR ;
                           CLOSE c_trx_type ;
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                     END IF ;
                     CLOSE c_trx_type ;
                     IF(L_DEBUG_ENABLED='Y') THEN
              L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
              IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
           END IF;
           IF(IS_DEBUG_PROCEDURE_ON) THEN
           BEGIN
           OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug call insert_ap_request');
           END;
           END IF;
             insert_ap_request(p_api_version   => l_api_version,
                             p_init_msg_list   => OKL_API.G_FALSE,
                             x_return_status   => l_return_status,
                             x_msg_count       =>x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_tap_id          => l_tra_id,
                             p_credit_amount   => l_to_refund,
                             p_credit_sty_id   => l_pay_strm_type_id,
                             p_khr_id          =>  p_ipyv_rec.khr_id,
                             p_kle_id          => p_ipyv_rec.kle_id,
                             p_invoice_date    => SYSDATE,
                             p_trx_id          => l_trx_type_id  );
          IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
             OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug call insert_ap_request');
          END;
          END IF;
                     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                     END IF;
          END IF ;

       OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

       EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
END get_vendor_refund;
-----------------------------------------------
-- Procedure rebook_inc_adjustment
---------------------------------------------------
PROCEDURE rebook_inc_adjustment(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                     IN ipyv_rec_type,
       p_refund_amount                IN NUMBER,
       p_src_trx_id                   IN NUMBER) IS
       l_api_name                     CONSTANT VARCHAR2(30) := 'rebook_inc_adjustment';
       l_return_status                VARCHAR2(1);
       l_api_version                  NUMBER:= 1.0;
       l_tra_id                       NUMBER;
       l_total_billed                 NUMBER;
       l_total_bill_accrued           NUMBER;
       l_strm_type_id                 NUMBER;
       l_strm_type_id_rep             NUMBER;  -- MGAAP 7263041
       l_adjustment_amount            NUMBER;
       l_refund_amount                NUMBER;
       l_ins_try_id                   NUMBER;
       l_ipyv_rec                     ipyv_rec_type;
      CURSOR c_total_billed(l_khr_id NUMBER, l_kle_id   NUMBER,l_stream_type_id NUMBER) IS
              SELECT SUM(amount)
              --FROM OKL_STREAMS STM,
              FROM OKL_STREAMS_REP_V STM, -- MGAAP 7263041
                   OKL_STRM_ELEMENTS STEM
              where  STM.STY_ID = l_stream_type_id
                    AND STM.KLE_ID = l_kle_id
                    AND STM.KHR_ID = l_khr_id
                    AND STM.ID = STEM.STM_ID
                    AND STEM.DATE_BILLED IS NOT NULL ;
      -- cursor changed to take the stream type id as the parameter, for user defined streams, bug 3924300
            CURSOR c_total_bill_accrued(l_khr_id NUMBER, l_kle_id   NUMBER, l_stream_type_id NUMBER) IS
                SELECT SUM(amount)
                --FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                FROM OKL_STREAMS_REP_V STM , OKL_STRM_ELEMENTS STEM --MGAAP 7263041
                WHERE STM.STY_ID = l_stream_type_id
                AND STM.KLE_ID = l_kle_id
                AND STM.KHR_ID = l_khr_id
                AND STM.ID = STEM.STM_ID
                AND STEM.ACCRUED_YN = 'Y'
                --AND STM.PURPOSE_CODE IS NULL;
                AND (STM.PURPOSE_CODE IS NULL OR STM.PURPOSE_CODE='REPORT');
            CURSOR okl_trx_types (cp_name VARCHAR2, cp_language VARCHAR2) IS
            SELECT  id
            FROM    okl_trx_types_tl
            WHERE   name      = cp_name
            AND     language  = cp_language;

/*          Start Bug#5955320

            l_tcnv_rec_in              OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
            x_tcnv_rec_in              OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
            l_tclv_tbl		       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;
            x_tclv_tbl		       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;

            l_ctxt_val_tbl             Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
            l_acc_gen_primary_key_tbl  Okl_Account_Dist_Pub.acc_gen_primary_key;
            l_template_tbl             Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
            l_amount_tbl               Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;

            End Bug#5955320
*/
--          Start Bug#5955320

	    l_gl_date 		       DATE;
            l_trx_number               VARCHAR2(30) := NULL; -- MGAAP
            l_accrual_rec              OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
            l_stream_tbl               OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
            l_ins_acc_adj          VARCHAR2(240);

--          End Bug#5955320

            l_inc_sty_id               NUMBER ;

            -- MGAAP start 7263041

            l_inc_sty_id_rep           NUMBER ; -- MGAAP 7263041
            CURSOR check_csr(p_khr_id NUMBER) IS
            SELECT A.MULTI_GAAP_YN, B.REPORTING_PDT_ID
            FROM   OKL_K_HEADERS A,
                   OKL_PRODUCTS B
            WHERE A.ID = p_khr_id
            AND   A.PDT_ID = B.ID;

            l_multi_gaap_yn            OKL_K_HEADERS.MULTI_GAAP_YN%TYPE;
            l_reporting_pdt_id         OKL_PRODUCTS.REPORTING_PDT_ID%TYPE;

            l_total_bill_accrued_rep           NUMBER;
            l_adjustment_amount_rep            NUMBER;
            l_sob_id                      NUMBER;

            -- MGAAP end 7263041

            CURSOR l_contract_currency_csr IS
            SELECT  currency_code
	               ,currency_conversion_type
	             -- ,currency_conversion_rate
	               ,currency_conversion_date
	          FROM    okl_k_headers_full_v
    	   	  WHERE   id = p_ipyv_rec.khr_id ;

           l_currency_conversion_type   okl_k_headers_full_v.currency_conversion_type%TYPE;
	   l_currency_conversion_date   okl_k_headers_full_v.currency_conversion_date%TYPE;

           CURSOR l_acc_dtls_csr(p_khr_id IN NUMBER) IS
           SELECT khr.pdt_id   pdt_id
      	   FROM  okl_k_headers_v khr
  	   	   WHERE khr.ID = p_khr_id;

										l_dist_info_rec   Okl_Account_Dist_Pub.dist_info_REC_TYPE;
          l_acct_call_rec     l_acc_dtls_csr%ROWTYPE;
          l_tmpl_identify_rec Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;

   	  -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
          l_fact_sync_code         VARCHAR2(2000);
          l_inv_acct_code          VARCHAR2(2000);
          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

														l_ptid  NUMBER ;
              l_curr_code   GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    ----- Account Generator sources
    Cursor salesP_csr( chrId NUMBER) IS
        select ct.object1_id1 id
        from   okc_contacts        ct,
               okc_contact_sources csrc,
               okc_k_party_roles_b pty,
               okc_k_headers_b     chr
        where  ct.cpl_id               = pty.id
              and    ct.cro_code             = csrc.cro_code
              and    ct.jtot_object1_code    = csrc.jtot_object_code
              and    ct.dnz_chr_id           =  chr.id
              and    pty.rle_code            = csrc.rle_code
              and    csrc.cro_code           = 'SALESPERSON'
              and    csrc.rle_code           = 'LESSOR'
              and    csrc.buy_or_sell        = chr.buy_or_sell
              and    pty.dnz_chr_id          = chr.id
              and    pty.chr_id              = chr.id
              and    chr.id                  = chrId;

      l_salesP_rec salesP_csr%ROWTYPE;

      Cursor fnd_pro_csr IS
          select mo_global.get_current_org_id() l_fnd_profile
          from dual;
      fnd_pro_rec                fnd_pro_csr%ROWTYPE;
      counter                    NUMBER;

   -- bug 9191475 .. start
      l_trxnum_tbl               okl_generate_accruals_pvt.trxnum_tbl_type;
   -- bug 9191475 .. end

       BEGIN

       l_ipyv_rec := p_ipyv_rec;
       l_refund_amount := p_refund_amount;

       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        l_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       		OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_strm_type_id);
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
                    RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
                 OPEN c_total_billed(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                 FETCH c_total_billed INTO l_total_billed;
                 CLOSE c_total_billed ;
                -- Removed for fixing 3745151 as no exception
                -- needs to be thrown as we are setting total billed
                -- to zero if cursor fetch fails.
                /*
                IF(c_total_billed%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_billed ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 */

                 IF ((l_total_billed IS NULL ) OR (l_total_billed = OKC_API.G_MISS_NUM )) THEN
                    l_total_billed := 0;
                 END IF ;

                 -- MGAAP start 7263041
                 OPEN check_csr(l_ipyv_rec.khr_id);
                 FETCH check_csr INTO
                 l_multi_gaap_yn, l_reporting_pdt_id;
                 CLOSE check_csr;
                 -- MGAAP end 7263041

                  OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id);
                   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                OPEN c_total_bill_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_bill_accrued INTO l_total_bill_accrued;
                CLOSE c_total_bill_accrued ;
                -- Removed for fixing 3745151 as no exception
                -- needs to be thrown as we are setting total billed
                -- to zero if cursor fetch fails.
                /*
                IF(c_total_bill_accrued%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_bill_accrued ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                  */
                  IF ((l_total_bill_accrued IS NULL ) OR (l_total_bill_accrued = OKC_API.G_MISS_NUM )) THEN
                       l_total_bill_accrued := 0;
                  END IF ;

            IF ((l_refund_amount IS NULL ) OR (l_refund_amount = OKC_API.G_MISS_NUM )) THEN
	                  l_refund_amount := 0;
            END IF ;
                 l_adjustment_amount := l_total_billed - l_total_bill_accrued - l_refund_amount ;

            -- MGAAP start 7263041

            IF (l_multi_gaap_yn = 'Y') THEN
                  OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
                  OKL_STREAMS_UTIL.get_primary_stream_type_rep(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id_rep);
                   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                OPEN c_total_bill_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id_rep);
                FETCH c_total_bill_accrued INTO l_total_bill_accrued_rep;
                CLOSE c_total_bill_accrued ;

                OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
                  IF ((l_total_bill_accrued_rep IS NULL ) OR (l_total_bill_accrued_rep = OKC_API.G_MISS_NUM )) THEN
                       l_total_bill_accrued_rep := 0;
                  END IF ;

                IF ((l_refund_amount IS NULL ) OR (l_refund_amount = OKC_API.G_MISS_NUM )) THEN
	                  l_refund_amount := 0;
                END IF ;
                l_adjustment_amount_rep := l_total_billed - l_total_bill_accrued_rep - l_refund_amount ;

            END IF;
            -- MGAAP end 7263041

/*          Start Bug#5955320

                  --gboomina Bug 4885759 - Start - Changing the transaction type from Insurance to Accrual
                  OPEN okl_trx_types ('Accrual', 'US');
                  FETCH okl_trx_types INTO l_ins_try_id;
                  IF(okl_trx_types%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
                      G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,'Accrual');
                      x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE okl_trx_types ;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                   END IF ;
                   CLOSE okl_trx_types;
                   --gboomina Bug 4885759 - End
	                                      -- GET Product
              OPEN l_acc_dtls_csr(l_ipyv_rec.KHR_ID );
              FETCH l_acc_dtls_csr INTO l_ptid;
              IF(l_acc_dtls_csr%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSREFUND');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE l_acc_dtls_csr ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
              CLOSE l_acc_dtls_csr;
            BEGIN
	      OPEN l_contract_currency_csr;
	      FETCH l_contract_currency_csr INTO  l_curr_code,l_currency_conversion_type,
	       l_currency_conversion_date ;
	      CLOSE l_contract_currency_csr;
	       EXCEPTION
	      	 WHEN NO_DATA_FOUND THEN
	      	 	OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,p_ipyv_rec.khr_id );
	      	 	x_return_status := OKC_API.G_RET_STS_ERROR;
	      	        IF l_contract_currency_csr%ISOPEN THEN
	      	   	   CLOSE l_contract_currency_csr;
	      	   	 END IF;
	      	 	RAISE OKC_API.G_EXCEPTION_ERROR;
	      	        WHEN OTHERS THEN
	      	 	  IF l_contract_currency_csr%ISOPEN THEN
	      	   	      	      CLOSE l_contract_currency_csr;
	      	   	   END IF;
	      	 		-- store SQL error message on message stack for caller
	      	           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
	      	                                           SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
	      	 		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
	      	 	    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
	      	   END;
 ---                l_curr_code := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

                 IF (l_adjustment_amount <> 0 ) THEN

                   -- header data
                    l_tcnv_rec_in.khr_id                    := l_ipyv_rec.KHR_ID ;
                    l_tcnv_rec_in.try_id                    := l_ins_try_id;
                    l_tcnv_rec_in.tsu_code                  := 'ENTERED';
                    l_tcnv_rec_in.tcn_type                  := 'AAJ';
                    l_tcnv_rec_in.date_transaction_occurred := l_ipyv_rec.CANCELLATION_DATE;
                    l_tcnv_rec_in.amount                    := l_adjustment_amount;
                    l_tcnv_rec_in.currency_code             := l_curr_code ;
                    l_tcnv_rec_in.currency_conversion_type  := l_currency_conversion_type ;
                    l_tcnv_rec_in.currency_conversion_date  := l_currency_conversion_date ;
                    l_tcnv_rec_in.legal_entity_id           := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => l_ipyv_rec.KHR_ID);

                    -- Line Data
                    l_tclv_tbl(1).line_number         :=  1;
                    l_tclv_tbl(1).khr_id              :=  l_ipyv_rec.KHR_ID;
                    l_tclv_tbl(1).tcl_type            := 'AAJ' ;
                    l_tclv_tbl(1).AMOUNT              := l_adjustment_amount;
                    l_tclv_tbl(1).currency_code       := l_curr_code ;
                    l_tclv_tbl(1).ORG_ID              := l_ipyv_rec.org_id ;
                    l_tclv_tbl(1).STY_ID              := l_strm_type_id;


-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
                     OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
                       p_api_version  => l_api_version,
                       p_init_msg_list  => OKC_API.G_FALSE,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_tcnv_rec       =>l_tcnv_rec_in  ,
                       p_tclv_tbl       => l_tclv_tbl,
                       x_tcnv_rec       => x_tcnv_rec_in,
                       x_tclv_tbl      => x_tclv_tbl );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts


   ---------------------------------------------------------------------------------------
                  counter := 1;
	                 OPEN  fnd_pro_csr;
	                 FETCH fnd_pro_csr INTO fnd_pro_rec;
	                 IF ( fnd_pro_csr%FOUND ) Then
	                     l_acc_gen_primary_key_tbl(counter).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
	                     l_acc_gen_primary_key_tbl(counter).primary_key_column := fnd_pro_rec.l_fnd_profile;
	                     counter := counter + 1 ;
	                 End IF;
	                 CLOSE fnd_pro_csr;
	                 OPEN  salesP_csr(l_ipyv_rec.KHR_ID);
	                 FETCH salesP_csr INTO l_salesP_rec;
	                 IF ( salesP_csr%FOUND ) Then
	                         l_acc_gen_primary_key_tbl(counter).source_table := 'JTF_RS_SALESREPS_MO_V';
	                 	l_acc_gen_primary_key_tbl(counter).primary_key_column := l_salesP_rec.id;
	                        counter := counter + 1 ;
	                 END IF ;
                 CLOSE salesP_csr;
       ------------------------------------------------------------------------------------

                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

End Bug#5955320 */


/*  Start Bug#5955320
          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
          get_special_acct_codes(p_khr_id                => l_ipyv_rec.KHR_ID,
                                 p_trx_date              => SYSDATE,
                                 x_fact_sync_code        => l_fact_sync_code,
                            	 x_inv_acct_code         => l_inv_acct_code );
          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

          -- Populate Records for Accounting Call.
          l_tmpl_identify_rec.PRODUCT_ID             := l_ptid;
    	  l_tmpl_identify_rec.TRANSACTION_TYPE_ID    := l_ins_try_id;
          l_tmpl_identify_rec.STREAM_TYPE_ID         := l_inc_sty_id;
    	  l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
   	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting  - Start
    	  l_tmpl_identify_rec.FACTORING_SYND_FLAG    := l_fact_sync_code;
	  l_tmpl_identify_rec.INVESTOR_CODE          := l_inv_acct_code;
	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting - End
    	  l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
          l_tmpl_identify_rec.FACTORING_CODE         := NULL;
    	  l_tmpl_identify_rec.MEMO_YN                := 'N';
          l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';
          l_dist_info_rec.SOURCE_ID                  := x_tclv_tbl(1).ID;
          l_dist_info_rec.SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
          l_dist_info_rec.ACCOUNTING_DATE            := SYSDATE;
          l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
          --gboomina Bug 4885759 - Start
          -- Making Tracactions 'Actual' instead of 'Draft' by setting post_to_gl as 'Y'
          l_dist_info_rec.POST_TO_GL                 := 'Y';
          --gboomina Bug 4885759 - End
          l_dist_info_rec.AMOUNT                     := l_adjustment_amount;
          l_dist_info_rec.CURRENCY_CODE              := l_curr_code;
          --- Not sure
          l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
          l_dist_info_rec.CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
          l_dist_info_rec.CONTRACT_ID                := l_ipyv_rec.KHR_ID  ;
          l_dist_info_rec.CONTRACT_LINE_ID           := l_ipyv_rec.KLE_ID;
  IF (l_adjustment_amount > 0 )THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;

      Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
  				     p_api_version             => p_api_version
                                    ,p_init_msg_list  		 => p_init_msg_list
                                    ,x_return_status  		 => x_return_status
                                    ,x_msg_count      		 => x_msg_count
                                    ,x_msg_data       		 => x_msg_data
                                    ,p_tmpl_identify_rec 	 => l_tmpl_identify_rec
                                    ,p_dist_info_rec             => l_dist_info_rec
                                    ,p_ctxt_val_tbl              => l_ctxt_val_tbl
                                    ,p_acc_gen_primary_key_tbl   => l_acc_gen_primary_key_tbl
                                    ,x_template_tbl              => l_template_tbl
                                    ,x_amount_tbl                => l_amount_tbl);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
           END IF ;
  END IF;

End Bug#5955320 */

--Start Bug#5955320
  IF (l_adjustment_amount <> 0 ) THEN

         OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   l_inc_sty_id);
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
               Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_ipyv_rec.CANCELLATION_DATE);
        l_ins_acc_adj := fnd_message.get_string('OKL','OKL_INS_INC_ACC_ADJ');
        if(l_ins_acc_adj IS NULL) then
         l_ins_acc_adj := 'Insurance income accrual adjustment';
        end if;

    -- Populate Records for adjust_accrual_rec_type.
          l_accrual_rec.contract_id             := l_ipyv_rec.KHR_ID;
          l_accrual_rec.accrual_date            := l_gl_date;
          l_accrual_rec.description             := l_ins_acc_adj; --'Insurance income accrual adjustment';
          l_accrual_rec.source_trx_id           := p_src_trx_id; -- source transaction id, either rebook or termination trx
          l_accrual_rec.source_trx_type         := 'TCN';

    -- Populate Records for stream_rec_type.
          l_stream_tbl(0).stream_type_id         := l_inc_sty_id;
          l_stream_tbl(0).stream_type_name       := NULL;
          l_stream_tbl(0).stream_id              := NULL;
          l_stream_tbl(0).stream_element_id      := NULL;
          l_stream_tbl(0).stream_amount          := l_adjustment_amount;
          l_stream_tbl(0).kle_id                 := l_ipyv_rec.KLE_ID;

-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
    END;
  END IF;
          OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS(
  				     p_api_version             => p_api_version
                                    ,p_init_msg_list  		 => p_init_msg_list
                                    ,x_return_status  		 => x_return_status
                                    ,x_msg_count      		 => x_msg_count
                                    ,x_msg_data       		 => x_msg_data
                                    --,x_trx_number        	 => l_trx_number-- bug 9191475
									,x_trx_tbl               => l_trxnum_tbl
                                    ,p_accrual_rec               => l_accrual_rec
                                    ,p_stream_tbl                => l_stream_tbl);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

  END IF;
--End Bug#5955320

         -- MGAAP start 7263041
         IF (l_multi_gaap_yn = 'Y') THEN
         IF (l_adjustment_amount_rep <> 0) THEN
           OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
           OKL_STREAMS_UTIL.get_primary_stream_type_rep(l_ipyv_rec.khr_id,
                                                     'INSURANCE_INCOME_ACCRUAL',
                                                     l_return_status,
                                                     l_inc_sty_id_rep);
           IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
             l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'SECONDARY');
             l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_ipyv_rec.CANCELLATION_DATE, p_ledger_id => l_sob_id); --MGAAP 7263041
             l_ins_acc_adj := fnd_message.get_string('OKL','OKL_INS_INC_ACC_ADJ');
             if(l_ins_acc_adj IS NULL) then
              l_ins_acc_adj := 'Insurance income accrual adjustment';
             end if;

           -- Populate Records for adjust_accrual_rec_type.
               l_accrual_rec.contract_id             := l_ipyv_rec.KHR_ID;
               l_accrual_rec.accrual_date            := l_gl_date;
               l_accrual_rec.description             := l_ins_acc_adj; --'Insurance income accrual adjustment';
               l_accrual_rec.source_trx_id           := p_src_trx_id; -- source transaction id, either rebook or termination trx
               l_accrual_rec.source_trx_type         := 'TCN';

           -- Populate Records for stream_rec_type.
               l_stream_tbl(0).stream_type_id        := l_inc_sty_id_rep;
               l_stream_tbl(0).stream_type_name      := NULL;
               l_stream_tbl(0).stream_id             := NULL;
               l_stream_tbl(0).stream_element_id     := NULL;
               l_stream_tbl(0).stream_amount         := l_adjustment_amount_rep;
               l_stream_tbl(0).kle_id                := l_ipyv_rec.KLE_ID;

             -- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
             IF(IS_DEBUG_PROCEDURE_ON) THEN
               BEGIN
                 OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
               END;
             END IF;

               --l_accrual_rec.trx_number := l_trx_number; -- bug 9191475
               OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS(
  			p_api_version             => p_api_version
                        ,p_init_msg_list  		 => p_init_msg_list
                        ,x_return_status  		 => x_return_status
                        ,x_msg_count      		 => x_msg_count
                        ,x_msg_data       		 => x_msg_data
                        --,x_trx_number        	 => l_trx_number
					    ,x_trx_tbl               => l_trxnum_tbl
                        ,p_accrual_rec               => l_accrual_rec
                        ,p_stream_tbl                => l_stream_tbl,
                        p_representation_type     => 'SECONDARY');

              OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
              IF(IS_DEBUG_PROCEDURE_ON) THEN
                BEGIN
                    OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
                END;
              END IF;


              IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
              END IF;

           END IF;
         END IF;
         END IF;
         -- MGAAP end 7263041

  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
	            x_return_status := OKC_API.HANDLE_EXCEPTIONS
	            (
	                l_api_name,
	                G_PKG_NAME,
	                'OKC_API.G_RET_STS_ERROR',
	                x_msg_count,
	                x_msg_data,
	                '_PROCESS'
	            );
            WHEN OTHERS THEN
            OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
END rebook_inc_adjustment;
--------------------------------------------
-- Procedure rebook_exp_adjustment
---------------------------------------
 PROCEDURE rebook_exp_adjustment(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                     IN ipyv_rec_type,
       lp_vendor_refund_amount        IN NUMBER,
       p_src_trx_id                   IN NUMBER) IS

       l_api_name CONSTANT VARCHAR2(30) := 'rebook_exp_adjustment';
       l_api_version             CONSTANT NUMBER := 1;
       l_return_status           VARCHAR2(1) ;
       l_total_paid              NUMBER;
       l_total_pay_accrued       NUMBER;
       l_vendor_refund_amount    NUMBER;
       l_strm_type_id            NUMBER;
       l_adjustment_amount       NUMBER;
       l_ins_try_id              NUMBER;
       l_ipyv_rec                ipyv_rec_type;
          CURSOR c_total_paid(l_khr_id NUMBER, l_kle_id   NUMBER,l_stream_type_id NUMBER) IS
                SELECT SUM(amount)
                --FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                FROM OKL_STREAMS_REP_V STM , OKL_STRM_ELEMENTS STEM -- MGAAP
                WHERE STM.STY_ID = l_stream_type_id
                AND STM.KLE_ID = l_kle_id
                AND STM.KHR_ID = l_khr_id
                AND STM.ID = STEM.STM_ID
                AND STEM.DATE_BILLED IS NOT NULL;
         CURSOR c_total_payment_accrued(l_khr_id NUMBER, l_kle_id   NUMBER, l_stream_type_id NUMBER) IS
                 SELECT SUM(amount)
                 --FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                 FROM OKL_STREAMS_REP_V STM , OKL_STRM_ELEMENTS STEM -- MGAAP
                 WHERE STM.STY_ID = l_stream_type_id
                 AND STM.KLE_ID = l_kle_id
                 AND STM.KHR_ID = l_khr_id
                 AND STM.ID = STEM.STM_ID
                 AND STEM.ACCRUED_YN = 'Y'
                 --AND STM.PURPOSE_CODE IS NULL;
                 AND (STM.PURPOSE_CODE IS NULL OR STM.PURPOSE_CODE='REPORT'); --Bug# 9191475
            CURSOR okl_trx_types (cp_name VARCHAR2, cp_language VARCHAR2) IS
            SELECT  id
            FROM    okl_trx_types_tl
            WHERE   name      = cp_name
            AND     language  = cp_language;

/*          Start Bug#5955320

            l_tcnv_rec_in              OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
            x_tcnv_rec_in              OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
            l_tclv_tbl		       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;
            x_tclv_tbl		       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;

            l_ctxt_val_tbl             Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
            l_acc_gen_primary_key_tbl  Okl_Account_Dist_Pub.acc_gen_primary_key;
            l_template_tbl             Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
            l_amount_tbl               Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;

            End Bug#5955320
*/

            l_inc_sty_id               NUMBER ;
--          Start Bug#5955320

	    l_gl_date                  DATE;
            l_trx_number               VARCHAR2(30) := NULL;
            l_accrual_rec              OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
            l_stream_tbl               OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
            l_ins_acc_adj              VARCHAR2(240);

--          End Bug#5955320

            CURSOR l_contract_currency_csr IS
            SELECT  currency_code
	               ,currency_conversion_type
	             -- ,currency_conversion_rate
	               ,currency_conversion_date
	    FROM    okl_k_headers_full_v
    	    WHERE   id = p_ipyv_rec.khr_id ;

            CURSOR l_acc_dtls_csr(p_khr_id IN NUMBER) IS
            SELECT khr.pdt_id   pdt_id,
                   khr.multi_gaap_yn mylti_gaap_yn, -- MGAAP
                   pdt.reporting_pdt_id reporting_pdt_id
      	    FROM  okl_k_headers_v khr,
      	          okl_products    pdt
  	    WHERE khr.ID = p_khr_id
  	    AND   khr.PDT_ID = pdt.ID;

     --smoduga..Bug 4493213 fix..08-aug-2005..start
     ----- Account Generator sources
     Cursor salesP_csr( chrId NUMBER) IS
         select ct.object1_id1 id
         from   okc_contacts        ct,
                okc_contact_sources csrc,
                okc_k_party_roles_b pty,
                okc_k_headers_b     chr
         where  ct.cpl_id               = pty.id
               and    ct.cro_code             = csrc.cro_code
               and    ct.jtot_object1_code    = csrc.jtot_object_code
               and    ct.dnz_chr_id           =  chr.id
               and    pty.rle_code            = csrc.rle_code
               and    csrc.cro_code           = 'SALESPERSON'
               and    csrc.rle_code           = 'LESSOR'
               and    csrc.buy_or_sell        = chr.buy_or_sell
               and    pty.dnz_chr_id          = chr.id
               and    pty.chr_id              = chr.id
               and    chr.id                  = chrId;

       l_salesP_rec salesP_csr%ROWTYPE;

       Cursor fnd_pro_csr IS
           select mo_global.get_current_org_id() l_fnd_profile
           from dual;
       fnd_pro_rec                fnd_pro_csr%ROWTYPE;
       counter                    NUMBER;
     --smoduga..Bug 4493213 fix..08-aug-2005..end


 	l_ptid                       NUMBER;
        l_currency_conversion_type   okl_k_headers_full_v.currency_conversion_type%TYPE;
        l_currency_conversion_date   okl_k_headers_full_v.currency_conversion_date%TYPE;
        l_curr_code                  GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;

        l_dist_info_rec              Okl_Account_Dist_Pub.dist_info_REC_TYPE;
        --l_acct_call_rec            l_acc_dtls_csr%ROWTYPE;
        l_tmpl_identify_rec          Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
        -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
        l_fact_sync_code         VARCHAR2(2000);
        l_inv_acct_code          VARCHAR2(2000);
        -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

       -- MGAAP start 7263041

       l_strm_type_id_rep            NUMBER;
       l_adjustment_amount_rep       NUMBER;
       l_multi_gaap_yn               okl_k_headers.multi_gaap_yn%TYPE;
       l_reporting_pdt_id            okl_products.reporting_pdt_id%TYPE;
       l_sob_id                      NUMBER;
       l_total_pay_accrued_rep       NUMBER;
       l_inc_sty_id_rep              NUMBER ;

       -- MGAAP end 7263041
   -- bug 9191475 .. start
      l_trxnum_tbl               okl_generate_accruals_pvt.trxnum_tbl_type;
   -- bug 9191475 .. end

 BEGIN
         l_ipyv_rec             := p_ipyv_rec ;
         l_vendor_refund_amount := lp_vendor_refund_amount;

         l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                        G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        l_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

              -- MGAAP start 7263041
              -- Moved from bottom
	      OPEN l_acc_dtls_csr(l_ipyv_rec.KHR_ID );
              FETCH l_acc_dtls_csr INTO l_ptid,
                                        l_multi_gaap_yn,  -- MGAAP
                                        l_reporting_pdt_id; -- MGAAP
              IF(l_acc_dtls_csr%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSREFUND');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE l_acc_dtls_csr ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
              CLOSE l_acc_dtls_csr;
              -- MGAAP end 7263041

    -- Expense Adjustment
            -- Sum of Disbursed Payable(1) - Sum of payable debit(sign)(2) - Sum of accrued insurance (3)
               OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_strm_type_id);
               IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                 RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
                OPEN c_total_paid(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_paid INTO l_total_paid;
                CLOSE c_total_paid ;
                --
                -- Removed for fixing 3745151 as no exception
                -- needs to be thrown as we are setting total paid
                -- to zero if cursor fetch fails.
                /*
                IF(c_total_paid%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_paid ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 */

                 IF ((l_total_paid IS NULL ) OR (l_total_paid = OKC_API.G_MISS_NUM )) THEN
		      l_total_paid := 0;
                 END IF ;
                 OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id);
                 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;
                OPEN c_total_payment_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_payment_accrued INTO l_total_pay_accrued;
                CLOSE c_total_payment_accrued ;
                --
                -- Removed for fixing 3745151 as no exception
                -- needs to be thrown as we are setting total paid
                -- to zero if cursor fetch fails.
                /*
                IF(c_total_payment_accrued%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_payment_accrued ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                */

                   IF ((l_total_pay_accrued IS NULL ) OR (l_total_pay_accrued = OKC_API.G_MISS_NUM )) THEN
		        l_total_pay_accrued := 0;
		    END IF ;

                  IF ((l_vendor_refund_amount IS NULL ) OR (l_vendor_refund_amount = OKC_API.G_MISS_NUM )) THEN
	    	       l_vendor_refund_amount := 0;
	    	  END IF ;
                 l_adjustment_amount := l_total_paid - l_total_pay_accrued - l_vendor_refund_amount;

                 -- MGAAP start 7263041
                 IF (l_multi_gaap_yn = 'Y') THEN
                   OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id_rep);
                  IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                  OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
                  OPEN c_total_payment_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id_rep);
                  FETCH c_total_payment_accrued INTO l_total_pay_accrued_rep;
                  CLOSE c_total_payment_accrued ;

                     IF ((l_total_pay_accrued_rep IS NULL ) OR (l_total_pay_accrued_rep = OKC_API.G_MISS_NUM )) THEN
		          l_total_pay_accrued_rep := 0;
		      END IF ;

                    IF ((l_vendor_refund_amount IS NULL ) OR (l_vendor_refund_amount = OKC_API.G_MISS_NUM )) THEN
	    	       l_vendor_refund_amount := 0;
	    	    END IF ;
                   l_adjustment_amount_rep := l_total_paid - l_total_pay_accrued_rep - l_vendor_refund_amount;
                   END IF;
                 END IF;
                 OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
                 -- MGAAP start 7263041

/*  Start Bug#5955320
                 --gboomina Bug 4885759 - Start - Changing the transaction type from Insurance to Accrual
                 OPEN okl_trx_types ('Accrual', 'US');
		 FETCH okl_trx_types INTO l_ins_try_id;
		 IF(okl_trx_types%NOTFOUND) THEN
		     Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
		     G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,'Accrual');
		     x_return_status := OKC_API.G_RET_STS_ERROR ;
		     CLOSE okl_trx_types ;
		    RAISE OKC_API.G_EXCEPTION_ERROR;
		 END IF ;
		 CLOSE okl_trx_types;
                 --gboomina Bug 4885759 - End
	      OPEN l_acc_dtls_csr(l_ipyv_rec.KHR_ID );
              FETCH l_acc_dtls_csr INTO l_ptid;
              IF(l_acc_dtls_csr%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSREFUND');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE l_acc_dtls_csr ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
              CLOSE l_acc_dtls_csr;
			      BEGIN
	      OPEN l_contract_currency_csr;
	      FETCH l_contract_currency_csr INTO  l_curr_code,l_currency_conversion_type,
	       l_currency_conversion_date ;
	      CLOSE l_contract_currency_csr;
	       EXCEPTION
	      	 WHEN NO_DATA_FOUND THEN
	      	 	OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,p_ipyv_rec.khr_id );
	      	 	x_return_status := OKC_API.G_RET_STS_ERROR;
	      	        IF l_contract_currency_csr%ISOPEN THEN
	      	   	   CLOSE l_contract_currency_csr;
	      	   	 END IF;
	      	 	RAISE OKC_API.G_EXCEPTION_ERROR;
	      	        WHEN OTHERS THEN
	      	 	  IF l_contract_currency_csr%ISOPEN THEN
	      	   	      	      CLOSE l_contract_currency_csr;
	      	   	   END IF;
	      	 		-- store SQL error message on message stack for caller
	      	           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
	      	                                           SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
	      	 		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
	      	 	    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
	      	   END;
                 IF (l_adjustment_amount <> 0 ) THEN
                    l_tcnv_rec_in.khr_id                    := l_ipyv_rec.KHR_ID ;
                    l_tcnv_rec_in.try_id                    := l_ins_try_id;
                    l_tcnv_rec_in.tsu_code                  := 'ENTERED';
                    l_tcnv_rec_in.tcn_type                  := 'AAJ';
                    l_tcnv_rec_in.date_transaction_occurred := l_ipyv_rec.CANCELLATION_DATE;
                    l_tcnv_rec_in.amount                    := l_adjustment_amount;
                    l_tcnv_rec_in.currency_code             := l_curr_code ;
		    l_tcnv_rec_in.currency_conversion_type  := l_currency_conversion_type ;
		    l_tcnv_rec_in.currency_conversion_date  := l_currency_conversion_date ;
                    l_tcnv_rec_in.legal_entity_id           := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => l_ipyv_rec.KHR_ID);
		    -- Line Data
		    l_tclv_tbl(1).line_number         :=  1;
		    l_tclv_tbl(1).khr_id              :=  l_ipyv_rec.KHR_ID;
		    l_tclv_tbl(1).tcl_type            := 'AAJ' ;
		    l_tclv_tbl(1).AMOUNT              := l_adjustment_amount;
		    l_tclv_tbl(1).currency_code       := l_curr_code ;
                    l_tclv_tbl(1).ORG_ID              := l_ipyv_rec.org_id ;
                    l_tclv_tbl(1).STY_ID              := l_strm_type_id;

-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
                    OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
			   p_api_version  => l_api_version,
			   p_init_msg_list  => OKC_API.G_FALSE,
			   x_return_status => x_return_status,
			   x_msg_count     => x_msg_count,
			   x_msg_data      => x_msg_data,
			   p_tcnv_rec       =>l_tcnv_rec_in  ,
			   p_tclv_tbl       => l_tclv_tbl,
		           x_tcnv_rec       => x_tcnv_rec_in,
		           x_tclv_tbl      => x_tclv_tbl
    			);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts
                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

--smoduga..Bug 4493213 fix..01-aug-2005..start
                   counter := 1;
                      OPEN  fnd_pro_csr;
                      FETCH fnd_pro_csr INTO fnd_pro_rec;
                      IF ( fnd_pro_csr%FOUND ) Then
                          l_acc_gen_primary_key_tbl(counter).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
                          l_acc_gen_primary_key_tbl(counter).primary_key_column := fnd_pro_rec.l_fnd_profile;
                          counter := counter + 1 ;
                      End IF;
                      CLOSE fnd_pro_csr;
                      OPEN  salesP_csr(l_ipyv_rec.KHR_ID);
                      FETCH salesP_csr INTO l_salesP_rec;
                      IF ( salesP_csr%FOUND ) Then
                         l_acc_gen_primary_key_tbl(counter).source_table := 'JTF_RS_SALESREPS_MO_V';
                         l_acc_gen_primary_key_tbl(counter).primary_key_column := l_salesP_rec.id;
                             counter := counter + 1 ;
                      END IF ;
                  CLOSE salesP_csr;
           --smoduga..Bug 4493213 fix..01-aug-2005..end

                 OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id);
                 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;

   	  -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
          get_special_acct_codes(p_khr_id                => l_ipyv_rec.KHR_ID,
                                 p_trx_date              => SYSDATE,
	                         x_fact_sync_code        => l_fact_sync_code,
	  	          	 x_inv_acct_code         => l_inv_acct_code );
          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

									 -- Populate Records for Accounting Call.
          l_tmpl_identify_rec.PRODUCT_ID             := l_ptid;
    	  l_tmpl_identify_rec.TRANSACTION_TYPE_ID    := l_ins_try_id;
          l_tmpl_identify_rec.STREAM_TYPE_ID         := l_inc_sty_id;
    	  l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
     	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting  - Start
    	  l_tmpl_identify_rec.FACTORING_SYND_FLAG    := l_fact_sync_code;
     	  l_tmpl_identify_rec.INVESTOR_CODE          := l_inv_acct_code;
	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting - End
    	  l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
          l_tmpl_identify_rec.FACTORING_CODE         := NULL;
    	  l_tmpl_identify_rec.MEMO_YN                := 'N';
          l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';
          l_dist_info_rec.SOURCE_ID                  := x_tclv_tbl(1).ID;
          l_dist_info_rec.SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
          l_dist_info_rec.ACCOUNTING_DATE            := SYSDATE;
          l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
          --gboomina Bug 4885759 - Start
          -- Making Tracactions 'Actual' instead of 'Draft' by setting post_to_gl as 'Y'
          l_dist_info_rec.POST_TO_GL                 := 'Y';
          --gboomina Bug 4885759 - End
          l_dist_info_rec.AMOUNT                     := l_adjustment_amount;
          l_dist_info_rec.CURRENCY_CODE              := l_curr_code;
          l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
          l_dist_info_rec.CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
          l_dist_info_rec.CONTRACT_ID                := l_ipyv_rec.KHR_ID  ;
          l_dist_info_rec.CONTRACT_LINE_ID           := l_ipyv_rec.KLE_ID;
  IF ( l_adjustment_amount > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
      Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
  								   p_api_version             => p_api_version
                                    ,p_init_msg_list  		 => p_init_msg_list
                                    ,x_return_status  		 => x_return_status
                                    ,x_msg_count      		 => x_msg_count
                                    ,x_msg_data       		 => x_msg_data
                                    ,p_tmpl_identify_rec 	 => l_tmpl_identify_rec
                                    ,p_dist_info_rec           => l_dist_info_rec
                                    ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                    ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                    ,x_template_tbl            => l_template_tbl
                                    ,x_amount_tbl              => l_amount_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF ;
  END IF;

End Bug#5955320 */

  --Start Bug#5955320
    IF (l_adjustment_amount <> 0 ) THEN

           OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                     'INSURANCE_EXPENSE_ACCRUAL',
                                                     l_return_status,
                                                     l_inc_sty_id);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                  RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

          l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_ipyv_rec.CANCELLATION_DATE);
          l_ins_acc_adj := fnd_message.get_string('OKL','OKL_INS_EXP_ACC_ADJ');
          if(l_ins_acc_adj IS NULL) then
           l_ins_acc_adj := 'Insurance expense accrual adjustment';
          end if;

      -- Populate Records for adjust_accrual_rec_type.
            l_accrual_rec.contract_id             := l_ipyv_rec.KHR_ID;
            l_accrual_rec.accrual_date            := l_gl_date;
            l_accrual_rec.description             := l_ins_acc_adj;
            l_accrual_rec.source_trx_id           := p_src_trx_id; -- source transaction id, either rebook or termination trx
            l_accrual_rec.source_trx_type         := 'TCN';

      -- Populate Records for stream_rec_type.
            l_stream_tbl(0).stream_type_id         := l_inc_sty_id;
            l_stream_tbl(0).stream_type_name       := NULL;
            l_stream_tbl(0).stream_id              := NULL;
            l_stream_tbl(0).stream_element_id      := NULL;
            l_stream_tbl(0).stream_amount          := l_adjustment_amount;
            l_stream_tbl(0).kle_id                 := l_ipyv_rec.KLE_ID;

  -- Start of wraper code generated automatically by Debug code generator for OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS
    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
      END;
    END IF;

            OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS(
    				       p_api_version           => p_api_version
                                      ,p_init_msg_list         => p_init_msg_list
                                      ,x_return_status         => x_return_status
                                      ,x_msg_count             => x_msg_count
                                      ,x_msg_data              => x_msg_data
                                      --,x_trx_number            => l_trx_number -- bug 9191475
									  ,x_trx_tbl               => l_trxnum_tbl
                                      ,p_accrual_rec           => l_accrual_rec
                                      ,p_stream_tbl            => l_stream_tbl);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

  END IF;
  --End Bug#5955320

  -- MGAAP start 7263041

  IF (l_multi_gaap_yn = 'Y') THEN
    IF (l_adjustment_amount_rep <> 0 ) THEN

           OKL_STREAMS_UTIL.get_primary_stream_type_rep(l_ipyv_rec.khr_id,
                                                     'INSURANCE_EXPENSE_ACCRUAL',
                                                     l_return_status,
                                                     l_inc_sty_id_rep);
           IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

           l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'SECONDARY');
          l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => l_ipyv_rec.CANCELLATION_DATE, p_ledger_id => l_sob_id);
          l_ins_acc_adj := fnd_message.get_string('OKL','OKL_INS_EXP_ACC_ADJ');
          if(l_ins_acc_adj IS NULL) then
           l_ins_acc_adj := 'Insurance expense accrual adjustment';
          end if;

      -- Populate Records for adjust_accrual_rec_type.
            l_accrual_rec.contract_id             := l_ipyv_rec.KHR_ID;
            l_accrual_rec.accrual_date            := l_gl_date;
            l_accrual_rec.description             := l_ins_acc_adj;
            l_accrual_rec.source_trx_id           := p_src_trx_id; -- source transaction id, either rebook or termination trx
            l_accrual_rec.source_trx_type         := 'TCN';

      -- Populate Records for stream_rec_type.
            l_stream_tbl(0).stream_type_id         := l_inc_sty_id_rep;
            l_stream_tbl(0).stream_type_name       := NULL;
            l_stream_tbl(0).stream_id              := NULL;
            l_stream_tbl(0).stream_element_id      := NULL;
            l_stream_tbl(0).stream_amount          := l_adjustment_amount_rep;
            l_stream_tbl(0).kle_id                 := l_ipyv_rec.KLE_ID;

      -- Start of wraper code generated automatically by Debug code generator for OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS
        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
              OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
          END;
        END IF;

            --l_accrual_rec.trx_number := l_trx_number; -- bug 9191475
            OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS(
    				       p_api_version           => p_api_version
                                      ,p_init_msg_list         => p_init_msg_list
                                      ,x_return_status         => x_return_status
                                      ,x_msg_count             => x_msg_count
                                      ,x_msg_data              => x_msg_data
                                      --,x_trx_number            => l_trx_number -- bug 9191475
									  ,x_trx_tbl               => l_trxnum_tbl
                                      ,p_accrual_rec           => l_accrual_rec
                                      ,p_stream_tbl            => l_stream_tbl
                                      ,p_representation_type   => 'SECONDARY');

           IF(IS_DEBUG_PROCEDURE_ON) THEN
             BEGIN
                 OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS ');
             END;
           END IF;
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;

    END IF;

  END IF;

  -- MGAAP end 7263041


  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
	            x_return_status := OKC_API.HANDLE_EXCEPTIONS
	            (
	                l_api_name,
	                G_PKG_NAME,
	                'OKC_API.G_RET_STS_ERROR',
	                x_msg_count,
	                x_msg_data,
	                '_PROCESS'
	            );
            WHEN OTHERS THEN
            OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
END rebook_exp_adjustment;

------------------------------------
-- Procedure Rebook_manual_invoice
----------------------------------
PROCEDURE Rebook_manual_invoice(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_khr_id                       IN NUMBER
    ,p_kle_id                       IN NUMBER
    ,p_strm_typ_id                  IN NUMBER
    ,p_inv_amount                   IN NUMBER
    --Bug 8810880
    ,p_ipy_id                       IN NUMBER) IS
--------------------------
-- DECLARE Local Variables
---------------------------
    l_api_name	        CONSTANT VARCHAR2(30) := 'Rebook_Manual_Invoice';
    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_try_id             NUMBER;
----------------------------
-- DECLARE Records/Tables
----------------------------

     --Get Transaction type Id
    CURSOR l_try_id_cur IS
    SELECT ID
    FROM okl_trx_types_tl
    WHERE NAME = 'Billing' AND LANGUAGE = 'US';

    -- Bug 8810880 Start
    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_rec        okl_til_pvt.tilv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    -- Bug 8810880 End

      BEGIN
      	x_return_status := OKL_API.G_RET_STS_SUCCESS;
      	l_return_status := OKL_API.START_ACTIVITY(
                            p_api_name	        => l_api_name,
                            p_pkg_name	        => g_pkg_name,
    		            p_init_msg_list	=> p_init_msg_list,
    		            l_api_version	=> l_api_version,
    	                    p_api_version	=> p_api_version,
    		            p_api_type	        => '_PROCESS',
    		            x_return_status	=> l_return_status);
    	 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
      -- Header level
        OPEN l_try_id_cur;
        FETCH l_try_id_cur INTO l_try_id;
        IF(l_try_id_cur %NOTFOUND) THEN
           Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
           G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,'Billing');
           x_return_status := OKC_API.G_RET_STS_ERROR ;
        CLOSE l_try_id_cur ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF ;

      -- Bug 8810880 Start Replace by central billing txn API call
      ---- Create Header Record

      lp_taiv_rec.khr_id           := p_khr_id;
      lp_taiv_rec.try_id           := l_try_id;
      lp_taiv_rec.ipy_id           := p_ipy_id;
      lp_taiv_rec.date_invoiced    := trunc(sysdate);
      lp_taiv_rec.date_entered     := trunc(sysdate);
      lp_taiv_rec.amount           := p_inv_amount;
      lp_taiv_rec.trx_status_code  := 'SUBMITTED';
      lp_taiv_rec.legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => p_khr_id);
      lp_taiv_rec.okl_source_billing_trx  := 'INSURANCE';

      --- Create Line Record

      lp_tilv_rec.amount                 := p_inv_amount;
      lp_tilv_rec.kle_id                 := p_kle_id;
      lp_tilv_rec.line_number            := 1;
      lp_tilv_rec.tai_id                 := lx_taiv_rec.id;
      lp_tilv_rec.description            := 'Insurance manual invoice';
      lp_tilv_rec.inv_receiv_line_code   := 'LINE';
      lp_tilv_rec.sty_id                 := p_strm_typ_id;

      lp_tilv_tbl(1) := lp_tilv_rec;

      IF(L_DEBUG_ENABLED='Y') THEN
        L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
        IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
      END IF;
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug call Okl_Internal_Billing_Pvt.create_billing_trx');
        END;
      END IF;

      okl_internal_billing_pvt.create_billing_trx(
                       p_api_version =>l_api_version,
                       p_init_msg_list => l_init_msg_list,
                       x_return_status => x_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data,
                       p_taiv_rec => lp_taiv_rec,
                       p_tilv_tbl => lp_tilv_tbl,
                       p_tldv_tbl => lp_tldv_tbl,
                       x_taiv_rec => lx_taiv_rec,
                       x_tilv_tbl => lx_tilv_tbl,
                       x_tldv_tbl => lx_tldv_tbl);

      IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug call Okl_Internal_Billing_Pvt.create_billing_trx');
      END;
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug 8810880 End

      OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
    EXCEPTION
           WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
END Rebook_manual_invoice;


------------------------------------
--Procedure Cancel Rebbok Policy
------------------------------------

PROCEDURE cancel_rebook_policy(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_src_trx_id                   IN NUMBER,
       p_ipyv_rec                     IN  ipyv_rec_type,
       x_ipyv_rec                     OUT NOCOPY  ipyv_rec_type
       )
       IS
  -- Local Variables Declaration
       l_cr_memo                      VARCHAR2(150):='Credit Memo';
       l_lang                         VARCHAR2(2) := 'US' ;
       l_strm_type_id                 NUMBER ;
       l_trx_type                     NUMBER ;
       l_pro_refund_amount            NUMBER := 0;
       l_return_status                VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;
       l_api_name                     CONSTANT VARCHAR2(30) := 'cancel_rebook_policy';
       l_api_version                  CONSTANT NUMBER := 1;
       ls_check_tpi                   VARCHAR2(3);
       l_strm_refund_id               NUMBER ;
       l_strm_rcvbl_id                NUMBER;
       l_cust_refund_amount           NUMBER;
       l_id                           NUMBER;
       l_tai_id                       NUMBER;
       l_vendor_refund_amount         NUMBER;
       l_khr_status                   VARCHAR2(30) ;
       l_clev_rec			   okl_okc_migration_pvt.clev_rec_type;
       lx_clev_rec		       okl_okc_migration_pvt.clev_rec_type;
       l_klev_rec			   Okl_Kle_Pvt.klev_rec_type ;
       lx_klev_rec		       Okl_Kle_Pvt.klev_rec_type ;
      --
       -- Records /Tables Declaration
       l_ipyv_rec                     ipyv_rec_type;

 -- get transaction type ID
       CURSOR okl_trx_types(cp_name VARCHAR2,cp_language VARCHAR2) IS
       SELECT  id
       FROM    okl_trx_types_tl
       WHERE   NAME      = cp_name
       AND     LANGUAGE  = cp_language;

-----------------------------------------
-- Begin for cancel_rebook_policy
-----------------------------------------
   BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       --Check for Insurance Policy ID
       IF ((p_ipyv_rec.ID IS NULL ) OR (p_ipyv_rec.ID = OKC_API.G_MISS_NUM )) THEN --[1]
         x_return_status := OKC_API.G_RET_STS_ERROR;
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy ID');
          RAISE OKC_API.G_EXCEPTION_ERROR;
       ELSE
        -------------------------------------------------
        -- Get Insurance contract and line information
        --------------------------------------------------
           l_ipyv_rec := get_insurance_info(p_ipyv_rec.ID,l_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
           l_ipyv_rec.cancellation_date := p_ipyv_rec.cancellation_date;
       END IF;  --[1]
       -----------------------------------------------
       -- Customer Refund
       -----------------------------------------------
        l_cust_refund_amount  := get_cust_refund(l_ipyv_rec,l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
       -----------------------------------------------
       -- Start Credit Memo Creation
       -----------------------------------------------
          OPEN okl_trx_types (l_cr_memo, l_lang);
          FETCH okl_trx_types INTO l_trx_type;
          IF(okl_trx_types%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
              G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,l_cr_memo);
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE okl_trx_types ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF ;
          CLOSE okl_trx_types;

         --Added by kthiruva on 17-Oct-2005
         --Bug 4667686 - Start of Changes
          OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_strm_rcvbl_id);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          --Bug 4667686 - End of Changes


         IF l_cust_refund_amount > 0 THEN  -- [a]
          --negate refund amount
          l_pro_refund_amount := -(l_cust_refund_amount);
          OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_REFUND',
                                                   l_return_status,
                                                   l_strm_refund_id);
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
		Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_REFUND'); --bug 4024785
                        RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;
    -- Call API to create Credit Memo
    -- Start of Debug code generator for on_account_credit_memo
    IF(L_DEBUG_ENABLED='Y') THEN
        L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
        IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;
    IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_credit_memo_pub.insert_request ');
        END;
    END IF;
    --- Creating credit memo
   on_account_credit_memo
              (
              p_api_version     => l_api_version,
              p_init_msg_list   => OKL_API.G_FALSE,
              p_try_id          => l_trx_type,
              p_khr_id  	=> l_ipyv_rec.khr_id,
              p_kle_id  	=> l_ipyv_rec.kle_id,
              p_ipy_id          => l_ipyv_rec.id,
              p_credit_date     => TRUNC(SYSDATE),
              p_credit_amount   => l_pro_refund_amount,
              p_credit_sty_id   => l_strm_refund_id,
              x_return_status   => l_return_status,
              x_msg_count       =>x_msg_count,
              x_msg_data        => x_msg_data,
              x_tai_id          => l_tai_id
          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call on_account_credit_memo ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_credit_memo_pub.insert_request
             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := l_return_status ;
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                x_return_status := l_return_status ;
                RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
     ELSIF(l_cust_refund_amount < 0 )THEN
           l_pro_refund_amount := -l_cust_refund_amount; --for making positive invoice amount
	  -- Start of Debug code generator for Rebook_manual_invoice
		 IF(L_DEBUG_ENABLED='Y') THEN
		    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
		   IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
		 END IF;
		 IF(IS_DEBUG_PROCEDURE_ON) THEN
		 BEGIN
		       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug call Rebook_manual_invoice');
		 END;
		 END IF;
		  Rebook_manual_invoice( p_api_version
					,p_init_msg_list
					,x_return_status
					,x_msg_count
					,x_msg_data
					,l_ipyv_rec.khr_id
					,l_ipyv_rec.kle_id
					,l_strm_rcvbl_id
					,l_pro_refund_amount
                              --Bug 8810880
                              ,l_ipyv_rec.id);
		 IF(IS_DEBUG_PROCEDURE_ON) THEN
		 BEGIN
		     OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug call Rebook_manual_invoice');
		 END;
		 END IF;
		 l_return_status := x_return_status;
       -- End of wraper code generated automatically by Debug code generator for Rebook_manual_invoice
		 IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
		   RAISE Fnd_Api.G_EXC_ERROR;
		 ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
		   RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
                 END IF;
     END IF ;
 ------------------------------------------
 --- PAY or clawback from vendor
 ------------------------------------------
      get_vendor_refund( p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec      => l_ipyv_rec,
                      pn_refund       => l_vendor_refund_amount);
              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;


                 ---Inactivate all stream / accounting entries
                 Inactivate_open_items(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_contract_id   => l_ipyv_rec.khr_id ,
                      p_contract_line => l_ipyv_rec.kle_id,
                      p_policy_status =>  l_ipyv_rec.iss_code );
              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
                  -- GET contract status
             	l_return_status :=	get_contract_status(l_ipyv_rec.khr_id, l_khr_status);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          IF (l_khr_status =  'ACTIVE' ) THEN
               -- if active, end date contract line and update status
              l_clev_rec.ID := l_ipyv_rec.kle_id ;
    			l_clev_rec.sts_code :=  'TERMINATED';
  			l_klev_rec.ID := l_ipyv_rec.kle_id ;
              l_clev_rec.DATE_TERMINATED :=  l_ipyv_rec.CANCELLATION_DATE;
  		  Okl_Contract_Pub.update_contract_line
  		   (
      	           p_api_version      => l_api_version ,
  		   p_init_msg_list           => OKC_API.G_FALSE,
  		   x_return_status      => l_return_status    ,
  		   x_msg_count           => x_msg_count,
  		   x_msg_data            => x_msg_data ,
  		   p_clev_rec            => l_clev_rec  ,
  		   p_klev_rec            => l_klev_rec,
  		   p_edit_mode            =>'N'        ,
  		   x_clev_rec            => lx_clev_rec,
  		   x_klev_rec            => lx_klev_rec
  		   );
              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                -- Status temp
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                -- Status temp
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
              ELSE

       		l_clev_rec.ID := l_ipyv_rec.kle_id ;
	       	l_clev_rec.sts_code :=  'TERMINATED';
	     	l_klev_rec.ID := l_ipyv_rec.kle_id ;
	        l_clev_rec.DATE_TERMINATED :=  l_ipyv_rec.CANCELLATION_DATE;

	     	Okl_Contract_Pub.update_contract_line
		     		(
		         	p_api_version      => l_api_version ,
		     		p_init_msg_list           => OKC_API.G_FALSE,
		     		x_return_status      => l_return_status    ,
		     		x_msg_count           => x_msg_count,
		     		x_msg_data            => x_msg_data ,
		     		p_clev_rec            => l_clev_rec  ,
		     		p_edit_mode            =>'N'        ,
		     		p_klev_rec            => l_klev_rec,
		     		x_clev_rec            => lx_clev_rec,
		     		x_klev_rec            => lx_klev_rec );
		         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		                   -- Status temp
		             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
		                   -- Status temp
		                   RAISE OKC_API.G_EXCEPTION_ERROR;
              		  END IF;
            END IF;
 ------------------------------------------
 --- Income Adjustment
 ------------------------------------------
      rebook_inc_adjustment(p_api_version => l_api_version,
       p_init_msg_list                =>Okc_Api.G_FALSE,
       x_return_status                => l_return_status,
       x_msg_count                    =>x_msg_count,
       x_msg_data                     =>x_msg_data,
       p_ipyv_rec                     =>l_ipyv_rec,
       p_refund_amount                =>l_cust_refund_amount,
       p_src_trx_id                   => p_src_trx_id
       );

        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
------------------------------------------
 --- Expense Adjustment
 ------------------------------------------
      rebook_exp_adjustment(p_api_version => l_api_version,
       p_init_msg_list                =>Okc_Api.G_FALSE,
       x_return_status                => l_return_status,
       x_msg_count                    =>x_msg_count,
       x_msg_data                     =>x_msg_data,
       p_ipyv_rec                     =>l_ipyv_rec,
       lp_vendor_refund_amount        =>l_vendor_refund_amount,
       p_src_trx_id                   => p_src_trx_id
       );
        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE Fnd_Api.G_EXC_ERROR;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
  l_ipyv_rec.iss_code := 'CANCELED';
            -- Create entry for adjustment
                 --Update Policy
-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
            	   Okl_Ins_Policies_Pub.update_ins_policies(
  	         p_api_version                  => p_api_version,
  	          p_init_msg_list                => OKC_API.G_FALSE,
  	          x_return_status                => l_return_status,
  	          x_msg_count                    => x_msg_count,
  	          x_msg_data                     => x_msg_data,
  	          p_ipyv_rec                     => l_ipyv_rec,
  	          x_ipyv_rec                     => x_ipyv_rec
  	          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
             x_return_status := l_return_status;
          OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
       END cancel_rebook_policy;
 --++ Added as part of fix for bug 4056603 ++--

------------------------------------------------------------
--Bug#5955320
      PROCEDURE cancel_create_policies(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_khr_id                       IN  NUMBER,
       p_cancellation_date            IN  DATE,
       p_crx_code                     IN VARCHAR2 DEFAULT NULL, --++++++++ Effective Dated Term Qte changes  +++++++++
       p_transaction_id               IN NUMBER,
       x_ignore_flag                  OUT NOCOPY VARCHAR2 --3945995
       ) IS
       l_api_name CONSTANT   VARCHAR2(30) := 'cancel_create';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status       VARCHAR2(1) ;
       l_ipyv_rec            ipyv_rec_type;
       l_delipyv_rec         ipyv_rec_type;
       lx_ipyv_rec           ipyv_rec_type;
       lx_ipyv_newrec        ipyv_rec_type;
       l_cancellation_date   DATE ;
       l_msg_count           NUMBER ;
       l_msg_data            VARCHAR2(2000);
       l_contract_status     VARCHAR2(30);
       x_message             VARCHAR2(100) ;
       x_iasset_tbl          Okl_Ins_Quote_Pvt.iasset_tbl_type ;
       l_inq_id               NUMBER;
       l_ipy_id               NUMBER;
       l_iss_code            VARCHAR2(30);
       l_new_k_start_date     DATE;
       l_new_k_end_date       DATE;
       l_maj_ver_num          NUMBER;
       l_k_end_date           DATE;
       l_k_start_date         DATE;
-- bug 4056603
       l_vld_cncl_dt          VARCHAR2(1) := '?';
       l_cancel_pol_flag      VARCHAR2(1) := 'N';
       CURSOR c_okl_ins_policies(p_contract_id NUMBER) IS
       SELECT ID, IPY_TYPE, ISS_CODE
       FROM OKL_INS_POLICIES_B
       WHERE KHR_ID = p_contract_id
       and ISS_CODE IN ('ACTIVE','ACCEPTED','PENDING')
       and IPY_TYPE = 'LEASE_POLICY'
       AND DATE_TO > p_cancellation_date; -- bug 4056603
       CURSOR c_okl_ins_quote(p_contract_id NUMBER,p_quote_id NUMBER) IS
       SELECT ipy_id
       FROM OKL_INS_POLICIES_B
       WHERE KHR_ID = p_contract_id
       AND   ID = p_quote_id;
       CURSOR okc_k_status_csr(p_khr_id  IN NUMBER) IS
       SELECT OST.STE_CODE
       FROM  OKC_K_HEADERS_V KHR , OKC_STATUSES_B OST
       WHERE  KHR.ID =  p_khr_id
       AND KHR.STS_CODE = OST.CODE ;
        -- Get start date and end date for rebook contract ---
       CURSOR okc_new_k_effdate_csr(p_khr_id  IN NUMBER) IS
       select chr.start_date ,chr.end_date
       from OKC_K_HEADERS_B chr ,
           OKL_TRX_CONTRACTS TRX
       where chr.ORIG_SYSTEM_ID1 = p_khr_id
       and chr.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK'
       and chr.orig_system_id1 = trx.khr_id
       and chr.id = trx.khr_id_new
       and chr.sts_code <> 'ABANDONED'
       and trx.tsu_code <> 'PROCESSED'
       and trx.representation_type = 'PRIMARY'; -- MGAAP 7263041
       --Get Major_version of the original contract in case of rebook---
      CURSOR okc_maj_ver_csr(p_khr_id  IN NUMBER) IS
      select max(major_version) from okc_k_headers_bh where ID =p_khr_id ;
      -- Get Orginal contract dates from contract history before doing rebook
      CURSOR okc_old_k_effdate_csr(p_khr_id  IN NUMBER,l_maj_ver_num IN NUMBER) IS
      select start_date ,end_date
      From okc_k_headers_bh
      where ID = p_khr_id
      And major_version = l_maj_ver_num;
       PROCEDURE migrate (
       	      p_from IN ipyv_rec_type,
       	      p_to   IN OUT NOCOPY ipyv_rec_type
       	    ) IS
       	    BEGIN
       	      p_to.ipy_type := p_from.ipy_type;
       	      p_to.payment_frequency := p_from.payment_frequency;
       	      p_to.ipf_code := p_from.ipf_code;
       	      p_to.ipe_code := p_from.ipe_code;
       	      p_to.date_to :=  p_from.date_to;
       	      p_to.date_from := p_from.date_from;
       	      p_to.on_file_yn := p_from.on_file_yn;
       	      p_to.private_label_yn := p_from.private_label_yn;
       	      p_to.agent_yn := p_from.agent_yn;
       	      p_to.lessor_insured_yn := p_from.lessor_insured_yn;
       	      p_to.lessor_payee_yn := p_from.lessor_payee_yn;
       	      p_to.khr_id := p_from.khr_id;
       	      p_to.int_id := p_from.int_id;
       	      p_to.isu_id := p_from.isu_id;
       	      p_to.insurance_factor := p_from.insurance_factor;
       	      p_to.factor_code := p_from.factor_code;
       	      p_to.factor_value := p_from.factor_value;
       	      p_to.agency_number := p_from.agency_number;
       	      p_to.agency_site_id := p_from.agency_site_id;
       	      p_to.sales_rep_id := p_from.sales_rep_id;
       	      p_to.agent_site_id := p_from.agent_site_id;
       	      p_to.adjusted_by_id := p_from.adjusted_by_id;
       	      p_to.territory_code := p_from.territory_code;
       END migrate;
       --Mark
        ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ipyv_rec_type IS
    CURSOR okl_ipyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ADJUSTMENT,
            CALCULATED_PREMIUM,
            OBJECT_VERSION_NUMBER,
            AGENCY_NUMBER,
            SFWT_FLAG,
            IPF_CODE,
            INT_ID,
            KHR_ID,
            ISU_ID,
            IPT_ID,
            IPY_ID,
            IPE_CODE,
            CRX_CODE,
            AGENCY_SITE_ID,
            ISS_CODE,
            KLE_ID,
            AGENT_SITE_ID,
            IPY_TYPE,
            POLICY_NUMBER,
            QUOTE_YN,
            ENDORSEMENT,
            INSURANCE_FACTOR,
            FACTOR_CODE,
            COVERED_AMOUNT,
            ADJUSTED_BY_ID,
            FACTOR_VALUE,
            DATE_QUOTED,
            SALES_REP_ID,
            DATE_PROOF_REQUIRED,
            DATE_QUOTE_EXPIRY,
            DEDUCTIBLE,
            PAYMENT_FREQUENCY,
            DATE_PROOF_PROVIDED,
            DATE_FROM,
            NAME_OF_INSURED,
            DATE_TO,
            DESCRIPTION,
            ON_FILE_YN,
            PREMIUM,
            COMMENTS,
            ACTIVATION_DATE,
            PRIVATE_LABEL_YN,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            CANCELLATION_DATE,
            CANCELLATION_COMMENT,
            AGENT_YN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TERRITORY_CODE
      FROM Okl_Ins_Policies_V
     WHERE okl_ins_policies_v.id = p_id;
    l_okl_ipyv_pk                  okl_ipyv_pk_csr%ROWTYPE;
    l_ipyv_rec                     ipyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ipyv_pk_csr (px_ipyv_rec.id);
    FETCH okl_ipyv_pk_csr INTO
              l_ipyv_rec.ID,
              l_ipyv_rec.ADJUSTMENT,
              l_ipyv_rec.CALCULATED_PREMIUM,
              l_ipyv_rec.OBJECT_VERSION_NUMBER,
              l_ipyv_rec.AGENCY_NUMBER,
              l_ipyv_rec.SFWT_FLAG,
              l_ipyv_rec.IPF_CODE,
              l_ipyv_rec.INT_ID,
              l_ipyv_rec.KHR_ID,
              l_ipyv_rec.ISU_ID,
              l_ipyv_rec.IPT_ID,
              l_ipyv_rec.IPY_ID,
              l_ipyv_rec.IPE_CODE,
              l_ipyv_rec.CRX_CODE,
              l_ipyv_rec.AGENCY_SITE_ID,
              l_ipyv_rec.ISS_CODE,
              l_ipyv_rec.KLE_ID,
              l_ipyv_rec.AGENT_SITE_ID,
              l_ipyv_rec.IPY_TYPE,
              l_ipyv_rec.POLICY_NUMBER,
              l_ipyv_rec.QUOTE_YN,
              l_ipyv_rec.ENDORSEMENT,
              l_ipyv_rec.INSURANCE_FACTOR,
              l_ipyv_rec.FACTOR_CODE,
              l_ipyv_rec.COVERED_AMOUNT,
              l_ipyv_rec.ADJUSTED_BY_ID,
              l_ipyv_rec.FACTOR_VALUE,
              l_ipyv_rec.DATE_QUOTED,
              l_ipyv_rec.SALES_REP_ID,
              l_ipyv_rec.DATE_PROOF_REQUIRED,
              l_ipyv_rec.DATE_QUOTE_EXPIRY,
              l_ipyv_rec.DEDUCTIBLE,
              l_ipyv_rec.PAYMENT_FREQUENCY,
              l_ipyv_rec.DATE_PROOF_PROVIDED,
              l_ipyv_rec.DATE_FROM,
              l_ipyv_rec.NAME_OF_INSURED,
              l_ipyv_rec.DATE_TO,
              l_ipyv_rec.DESCRIPTION,
              l_ipyv_rec.ON_FILE_YN,
              l_ipyv_rec.PREMIUM,
              l_ipyv_rec.COMMENTS,
              l_ipyv_rec.ACTIVATION_DATE,
              l_ipyv_rec.PRIVATE_LABEL_YN,
              l_ipyv_rec.LESSOR_INSURED_YN,
              l_ipyv_rec.LESSOR_PAYEE_YN,
              l_ipyv_rec.CANCELLATION_DATE,
              l_ipyv_rec.CANCELLATION_COMMENT,
              l_ipyv_rec.AGENT_YN,
              l_ipyv_rec.ATTRIBUTE_CATEGORY,
              l_ipyv_rec.ATTRIBUTE1,
              l_ipyv_rec.ATTRIBUTE2,
              l_ipyv_rec.ATTRIBUTE3,
              l_ipyv_rec.ATTRIBUTE4,
              l_ipyv_rec.ATTRIBUTE5,
              l_ipyv_rec.ATTRIBUTE6,
              l_ipyv_rec.ATTRIBUTE7,
              l_ipyv_rec.ATTRIBUTE8,
              l_ipyv_rec.ATTRIBUTE9,
              l_ipyv_rec.ATTRIBUTE10,
              l_ipyv_rec.ATTRIBUTE11,
              l_ipyv_rec.ATTRIBUTE12,
              l_ipyv_rec.ATTRIBUTE13,
              l_ipyv_rec.ATTRIBUTE14,
              l_ipyv_rec.ATTRIBUTE15,
              l_ipyv_rec.ORG_ID,
              l_ipyv_rec.REQUEST_ID,
              l_ipyv_rec.PROGRAM_APPLICATION_ID,
              l_ipyv_rec.PROGRAM_ID,
              l_ipyv_rec.PROGRAM_UPDATE_DATE,
              l_ipyv_rec.CREATED_BY,
              l_ipyv_rec.CREATION_DATE,
              l_ipyv_rec.LAST_UPDATED_BY,
              l_ipyv_rec.LAST_UPDATE_DATE,
              l_ipyv_rec.LAST_UPDATE_LOGIN,
              l_ipyv_rec.TERRITORY_CODE;
    x_no_data_found := okl_ipyv_pk_csr%NOTFOUND;
    CLOSE okl_ipyv_pk_csr;
    px_ipyv_rec := l_ipyv_rec;
    RETURN(px_ipyv_rec);
  END get_rec;
  FUNCTION get_rec (
    px_ipyv_rec       IN OUT NOCOPY ipyv_rec_type
  ) RETURN ipyv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(px_ipyv_rec, l_row_notfound));
  END get_rec;
       -- END MARK
      BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PROCESS',
                                                x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       SAVEPOINT cancel_create;
       x_ignore_flag := OKC_API.G_FALSE; --3945995
        -- Check for contract_id (NULL)
       IF ((p_khr_id IS NULL ) OR (p_khr_id = OKC_API.G_MISS_NUM )) THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ContractID');
          ROLLBACK TO cancel_create;
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       -- Check for Date put SYSDATE if NULL
       IF ((p_cancellation_date IS NULL ) OR (p_cancellation_date = OKC_API.G_MISS_DATE )) THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Cancellation Date');
       ROLLBACK TO cancel_create;
       RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       l_cancellation_date := p_cancellation_date ;
        OPEN c_okl_ins_policies(p_khr_id);
          FETCH c_okl_ins_policies INTO l_ipyv_rec.ID, l_ipyv_rec.IPY_TYPE,
          l_ipyv_rec.ISS_CODE ;

           CLOSE c_okl_ins_policies;
            IF  (l_ipyv_rec.IPY_TYPE IS NULL) OR (l_ipyv_rec.IPY_TYPE = OKC_API.G_MISS_CHAR) THEN
              NULL;
            ELSIF( l_ipyv_rec.IPY_TYPE <> 'THIRD_PARTY_POLICY' AND
                   l_ipyv_rec.IPY_TYPE <> 'OPTIONAL_POLICY')THEN
                 IF (p_crx_code IS NOT NULL) OR (p_crx_code <> OKC_API.G_MISS_CHAR ) THEN
                 l_ipyv_rec.crx_code :=  p_crx_code;--'ASSET_TERMINATION' ;
                 END IF;
                 l_ipyv_rec.cancellation_date := p_cancellation_date;
                 l_iss_code := l_ipyv_rec.ISS_CODE ;
--++ Added as part of fix for bug 4056603 ++--
            l_cancel_pol_flag := validate_cancel_policy(p_khr_id);

      IF l_cancel_pol_flag = 'Y' THEN
            IF l_ipyv_rec.ISS_CODE = 'ACTIVE' THEN
-- Call function validate_cancel_plicy
--++ Added as part of fix for bug 4056603 ++--
                cancel_rebook_policy(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_src_trx_id    => p_transaction_id,
                      p_ipyv_rec      => l_ipyv_rec,
                      x_ipyv_rec      => lx_ipyv_rec);
             ELSE
               l_delipyv_rec := get_rec(l_ipyv_rec);
               l_delipyv_rec.cancellation_date := l_cancellation_date;
               delete_policy(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec      => l_delipyv_rec,
                      x_ipyv_rec      => lx_ipyv_rec);
             END IF;
              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                ROLLBACK TO cancel_create;
	            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
	            ROLLBACK TO cancel_create;
	            RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN --[1]
                SAVEPOINT save_quote; -- 3945995
               --** CANCELLED OLD POLICIES SUCCESSFULLY     **--
                --** STARTING QUOTE PROCESS FOR NEW POLICIES **--
                --****
               -- Copy needed information from cancelled policy record to
               -- New Policy to be created.
                --****
                migrate(lx_ipyv_rec, lx_ipyv_newrec);
               --** Process Policy covering full contract during rebooking **--
                  -- Dates of the Rebooked contract ----
                OPEN okc_new_k_effdate_csr(p_khr_id);
                FETCH okc_new_k_effdate_csr INTO l_new_k_start_date, l_new_k_end_date;
                -- If contract has been rebooked --
                IF okc_new_k_effdate_csr%FOUND THEN ---[1]
                 --get maximum version number for contract
                  OPEN okc_maj_ver_csr(p_khr_id);
                  FETCH okc_maj_ver_csr INTO l_maj_ver_num;
                  CLOSE okc_maj_ver_csr;
                   --check to see rebook has been requested
                   IF l_maj_ver_num > 1 THEN --[2]
                      l_maj_ver_num := l_maj_ver_num -1;
                    --get Original contract dates before doing rebook --
                     OPEN okc_old_k_effdate_csr(p_khr_id,l_maj_ver_num);
                     FETCH okc_old_k_effdate_csr INTO l_k_start_date, l_k_end_date;
                     CLOSE okc_old_k_effdate_csr;
                     --Check to see if policy covers full term of contract
                     --gboomina Bug 4889211 Start - Changed - Check only To dates
                     IF trunc(l_k_end_date)=trunc(lx_ipyv_rec.date_to) THEN  -- [3]
                        -- lx_ipyv_newrec.date_from := trunc(l_new_k_start_date); - gboomina commented Bug 4889211
                        lx_ipyv_newrec.date_to := trunc(l_new_k_end_date);
		     --gboomina Bug 4889211 End
                     END IF;  --[3]
                   END IF; --[2]
                ELSE
                   lx_ipyv_newrec.date_from := p_cancellation_date;
                END IF; --[1]
                CLOSE okc_new_k_effdate_csr;
               --** END Process Policy covering full contract during rebooking **--
               --+++++ EFF DATED TERM START +++++++++------
               --check for future and prior date's of termination
                    -- if quote termination is before start of insurance policy.
                    IF p_cancellation_date < lx_ipyv_rec.date_from THEN
                      lx_ipyv_newrec.date_from := lx_ipyv_rec.date_from;
                    END IF;
               --+++++ EFF DATED TERM END+++++++++------
                --** SAVE quote **--
                 -- check to see if the cancellation date is between the start and end date of the policy -- Bug 4056603
	        --SELECT 'X' INTO l_vld_cncl_dt  FROM DUAL
		--WHERE p_cancellation_date BETWEEN  lx_ipyv_rec.date_from AND lx_ipyv_rec.date_to;
                --IF l_vld_cncl_dt = 'X' then
      	        -- gboomina Bug 4994786 Changed - start
    	        -- Instead of implicit cusor, used IF condition check
	        IF p_cancellation_date >= lx_ipyv_rec.date_from AND p_cancellation_date <= lx_ipyv_rec.date_to THEN
             	-- gboomina Bug 4994786 - end
         	  lx_ipyv_newrec.date_from := p_cancellation_date;
                END IF;
                lx_ipyv_newrec.date_quoted := SYSDATE - 10;
                lx_ipyv_newrec.date_quote_expiry := SYSDATE + 20;

                --Bug# 7497783
                IF p_transaction_id IS NOT NULL THEN
                  IF lx_ipyv_newrec.date_quote_expiry > lx_ipyv_newrec.date_to THEN
                    lx_ipyv_newrec.date_quote_expiry := lx_ipyv_newrec.date_to;
                  END IF;
                END IF;
                --Bug# 7497783
                lx_ipyv_newrec.object_version_number := 1;
                lx_ipyv_newrec.adjustment := 0;
-- Start of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.save_quote
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_ins_quote_pub.save_quote ');
    END;
  END IF;
                okl_ins_quote_pub.save_quote(
                p_api_version                  => l_api_version,
                p_init_msg_list                => Okc_Api.G_TRUE ,
                x_return_status                => l_return_status,
                x_msg_count                    => l_msg_count,
                x_msg_data                     => l_msg_data,
                px_ipyv_rec                    => lx_ipyv_newrec,
                x_message                      => x_message  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_ins_quote_pub.save_quote ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.save_quote
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  ROLLBACK TO save_quote;
		  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  ROLLBACK TO save_quote;
		  RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
                l_inq_id := lx_ipyv_newrec.id;
                 IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN --[2]
                    SAVEPOINT accept_quote; -- 3945995
                      --** ACCEPT quote **--
                    lx_ipyv_newrec.adjustment := 0;
-- Start of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.accept_quote
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_ins_quote_pub.accept_quote ');
    END;
  END IF;
                      okl_ins_quote_pub.accept_quote(
                     p_api_version                  => l_api_version,
                      p_init_msg_list                => Okc_Api.G_TRUE ,
                        x_return_status                => l_return_status,
                       x_msg_count                    => l_msg_count,
                      x_msg_data                     => l_msg_data,
                     p_quote_id                     => lx_ipyv_newrec.ID
                        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_ins_quote_pub.accept_quote ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.accept_quote
		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  ROLLBACK TO accept_quote; -- 3945995
		  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  ROLLBACK  TO accept_quote; -- 3945995
		  RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
               IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN --[3]
                 SAVEPOINT policy_activate; -- 3945995
                 --** CHECK for contract status **--
                 OPEN  okc_k_status_csr(p_khr_id);
		          FETCH okc_k_status_csr INTO l_contract_status ;
		          IF(okc_k_status_csr%NOTFOUND) THEN
		          -- store SQL error message on message stack for caller
		          OKL_API.set_message(G_APP_NAME,
		               	          G_INVALID_CONTRACT
		               	            );
		            IF okc_k_status_csr%ISOPEN THEN
		     	      CLOSE okc_k_status_csr;
		            END IF;
                           x_ignore_flag := okc_api.G_TRUE; -- 3945995
		           x_return_status := OKC_API.G_RET_STS_ERROR;
		           ROLLBACK TO policy_activate; -- 3945995
		           RAISE OKC_API.G_EXCEPTION_ERROR;
		          END IF;
                CLOSE okc_k_status_csr;
              --** Get Policy ID for the Quote Created above **--
              OPEN  c_okl_ins_quote(p_khr_id,l_inq_id);
	      FETCH c_okl_ins_quote INTO l_ipy_id ;
              CLOSE c_okl_ins_quote;
                          -- 3745151 Removing error as it is not needed
                          /*
		          IF(c_okl_ins_quote%NOTFOUND) THEN
		          -- store SQL error message on message stack for caller
		          OKL_API.set_message(G_APP_NAME,G_INVALID_CONTRACT
		               	            );
		          IF c_okl_ins_quote%ISOPEN THEN
		     	      CLOSE c_okl_ins_quote;
		          END IF;
		        x_return_status := OKC_API.G_RET_STS_ERROR;
		        ROLLBACK TO policy_activate; -- 3945995
		        RAISE OKC_API.G_EXCEPTION_ERROR;
		        END IF;
                        */
  IF (L_iss_code = 'ACTIVE' ) THEN --[5]
   IF (l_contract_status = 'ACTIVE') THEN --[4]
  -- Start of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.activate_ins_policy
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call okl_ins_quote_pub.activate_ins_policy ');
    END;
  END IF;
                   okl_ins_quote_pub.activate_ins_policy(
		     p_api_version                  => l_api_version ,
		     p_init_msg_list                => Okc_Api.G_TRUE,
		     x_return_status                => l_return_status,
		     x_msg_count                    => l_msg_count,
		     x_msg_data                     => l_msg_data,
         	    p_ins_policy_id                => l_ipy_id  	);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call okl_ins_quote_pub.activate_ins_policy ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_ins_quote_pub.activate_ins_policy
         	   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       ROLLBACK TO  policy_activate; -- 3945995
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        x_ignore_flag := okc_api.G_TRUE; -- 3945995
                        ROLLBACK TO policy_activate; -- 3945995
		        RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
    END IF ;       --[5]
                  END IF;--[4]
                END IF; --[3]
               END IF; --[2]
            END IF; --[1]
          END IF; -- validate cancel policy
            END IF;
         OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
             -- 3945995 begin
             IF (x_ignore_flag = Okc_Api.G_TRUE)THEN
              x_return_status := l_return_status;
              OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
             ELSE -- 3945995 END
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
             END IF; -- 3945995
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
      END cancel_create_policies;

       --+++++++++++++ Effective Dated Term Qte changes -- start +++++++++
       -------------------------------------------------------------------------
       -- PROCEDURE CHECK_CLAIMS
       -- Called to check if any unsubmitted claims exist for a contract being
       -- terminated
       -- smoduga created 06-Sep-04
       -------------------------------------------------------------------------
       PROCEDURE check_claims(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       x_clm_exist                    OUT NOCOPY VARCHAR2,
       p_khr_id                       IN  NUMBER,
       p_trx_date                     IN  DATE
       ) IS
       l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       l_claim_id                NUMBER;
       l_claim_date              DATE;
       l_contract_number         VARCHAR2(120);
       l_api_name CONSTANT   VARCHAR2(30) := 'check_claims';
       l_api_version         CONSTANT NUMBER := 1;

       -- Fetch count of unsubmitted Insurance claims for the insurance policies
       -- attached to assets of the contract.
       cursor chk_claims (c_khr_id NUMBER ,c_qte_eff_date DATE )is
        Select CLMB.ID,CLMB.claim_date
        From okl_ins_claims_B  CLMB,
            OKL_INS_POLICIES_V IPYV
        WHERE CLMB.ipy_id = IPYV.id
        AND trunc(CLMB.claim_date) >= trunc(c_qte_eff_date)
        AND CLMB.CSU_CODE <> 'SUBMITTED'
        AND IPYV.ISS_CODE ='ACTIVE'
        AND IPYV.IPY_TYPE ='LEASE_POLICY'
        AND IPYV.khr_id = c_khr_id;

        -- Get contract number
        cursor get_chr_number(c_khr_id NUMBER) is
        select contract_number
        From okc_k_headers_b
        where id = c_khr_id;

        chk_claims_rec chk_claims%ROWTYPE;

       BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PROCESS',
                                                x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       -- Check if ther are any claims open for this contract
       -- at the time of raising the termination quote
       OPEN chk_claims (p_khr_id,p_trx_date);
       FETCH chk_claims INTO l_claim_id,l_claim_date;
       IF chk_claims%FOUND THEN
               x_clm_exist := 'Y';
       END IF;
       CLOSE chk_claims;

        IF ( x_clm_exist = 'Y' ) Then

              l_return_status := OKC_API.G_RET_STS_ERROR;

              OPEN get_chr_number(p_khr_id);
               FETCH get_chr_number into l_contract_number;
              close get_chr_number;

          FOR chk_claims_rec IN chk_claims(p_khr_id,p_trx_date) LOOP
               OKL_API.set_message(G_APP_NAME, 'OKL_INS_CLAIMS_EXIST',
                    'CONTRACT_NUM',l_contract_number,
                    'CLAIM_DATE',l_claim_date);

          END LOOP;

               RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSE
                x_clm_exist := 'N' ;
        END IF;

       x_return_status := l_return_status;

       OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

      EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN

              IF chk_claims%ISOPEN THEN
	      	   	   CLOSE chk_claims;
              END IF;

              IF get_chr_number%ISOPEN THEN
	      	   	   CLOSE get_chr_number;
              END IF;

              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );

            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

              IF chk_claims%ISOPEN THEN
	      	   	   CLOSE chk_claims;
              END IF;

              IF get_chr_number%ISOPEN THEN
	      	   	   CLOSE get_chr_number;
              END IF;

              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );

              WHEN OTHERS THEN

              IF chk_claims%ISOPEN THEN
	      	   	   CLOSE chk_claims;
              END IF;

              IF get_chr_number%ISOPEN THEN
	      	   	   CLOSE get_chr_number;
              END IF;

              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );

       END check_claims;
       --+++++++++++++ Effective Dated Term Qte changes -- end +++++++++



       PROCEDURE cancel_policy(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_ipyv_rec                  IN  ipyv_rec_type,
       x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
       )
       IS
       l_api_name CONSTANT VARCHAR2(30) := 'cancel_policy';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       ls_check_tpi         VARCHAR2(3);
       l_id                 NUMBER ;
       l_ipyv_rec           ipyv_rec_type;
       l_clev_rec			   okl_okc_migration_pvt.clev_rec_type;
       lx_clev_rec		       okl_okc_migration_pvt.clev_rec_type;
       l_klev_rec			   Okl_Kle_Pvt.klev_rec_type ;
       lx_klev_rec		       Okl_Kle_Pvt.klev_rec_type ;
       l_cust_refund  NUMBER ;
       l_vendor_adjustment NUMBER;
       l_khr_status VARCHAR2(30) ;
       l_adjustment_amount   NUMBER ;
       l_strm_type_id 	  NUMBER;
       l_ins_try_id NUMBER ;
       l_total_billed NUMBER ;
       l_total_paid   NUMBER ;
       l_total_bill_accrued NUMBER ;
       l_total_pay_accrued NUMBER ;
       l_inc_sty_id  NUMBER ;
/* Bug#5955320
     --  l_tcnv_rec_in         OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
     --  x_tcnv_rec_in         OKL_TRX_CONTRACTS_PUB.tcnv_rec_type ;
     --  l_tclv_tbl	       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;
     --  x_tclv_tbl	       OKL_TRX_CONTRACTS_PUB.tclv_tbl_type ;
     --  l_ctxt_val_tbl        		Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
     --  l_acc_gen_primary_key_tbl	Okl_Account_Dist_Pub.acc_gen_primary_key;
     --  l_template_tbl         	Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
     --  l_amount_tbl           	Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
*/
       l_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
       l_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;
       l_dist_info_rec   Okl_Account_Dist_Pub.dist_info_REC_TYPE;
       l_tmpl_identify_rec Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;

       -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
       l_fact_sync_code         VARCHAR2(2000);
       l_inv_acct_code          VARCHAR2(2000);
       -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

       l_ptid  NUMBER ;
       l_curr_code   GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
       counter NUMBER;
       -- smoduga added for 3845998
       l_rcvbl_strm_type_id   NUMBER;
       l_last_billed_date     DATE;
       l_check_refund_months NUMBER;
       -- smoduga added for 3845998

       -- schodava added Covered_amount to the cursor for Bug 4701170
       CURSOR c_ins_info( p_ipy_id NUMBER) IS
       SELECT IPYB.KHR_ID, IPYB.KLE_ID ,IPYB.OBJECT_VERSION_NUMBER, IPYB.date_from, IPYB.ipy_type,IPYB.factor_code,
              IPYB.COVERED_AMOUNT
       FROM OKL_INS_POLICIES_B IPYB
       WHERE IPYB.ID = p_ipy_id;



       CURSOR c_okl_third_party(l_khr_id NUMBER, l_cancellation_date  DATE) IS
       SELECT ID
       FROM OKL_INS_POLICIES_B IPYB
       WHERE IPYB.IPY_TYPE = 'THIRD_PARTY_POLICY'
       AND l_cancellation_date BETWEEN IPYB.date_from and IPYB.date_to;

      -- cursor changed to take the stream type id as the parameter, for user defined streams, bug 3924300
      CURSOR c_total_billed(l_khr_id NUMBER, l_kle_id   NUMBER,l_stream_type_id NUMBER) IS
             SELECT SUM(amount)
              FROM OKL_STREAMS STM,
                   OKL_STRM_ELEMENTS STEM
              where  STM.STY_ID = l_stream_type_id
                    AND STM.KLE_ID = l_kle_id
                    AND STM.KHR_ID = l_khr_id
                    AND STM.ID = STEM.STM_ID
                    AND STEM.DATE_BILLED IS NOT NULL ;

      -- cursor changed to take the stream type id as the parameter, for user defined streams, bug 3924300
         CURSOR c_total_paid(l_khr_id NUMBER, l_kle_id   NUMBER,l_stream_type_id NUMBER) IS
             SELECT SUM(amount)
                FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                WHERE STM.STY_ID = l_stream_type_id
                AND STM.KLE_ID = l_kle_id
                AND STM.KHR_ID = l_khr_id
                AND STM.ID = STEM.STM_ID
                AND STEM.DATE_BILLED IS NOT NULL;

      -- cursor changed to take the stream type id as the parameter, for user defined streams, bug 3924300
            CURSOR c_total_bill_accrued(l_khr_id NUMBER, l_kle_id   NUMBER, l_stream_type_id NUMBER) IS
              SELECT SUM(amount)
                FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                WHERE STM.STY_ID = l_stream_type_id
                AND STM.KLE_ID = l_kle_id
                AND STM.KHR_ID = l_khr_id
                AND STM.ID = STEM.STM_ID
                AND STEM.ACCRUED_YN = 'Y'
                AND STM.PURPOSE_CODE IS NULL;

      -- cursor changed to take the stream type id as the parameter, for user defined streams, bug 3924300

           CURSOR c_total_payment_accrued(l_khr_id NUMBER, l_kle_id   NUMBER, l_stream_type_id NUMBER) IS
             SELECT SUM(amount)
                 FROM OKL_STREAMS STM , OKL_STRM_ELEMENTS STEM
                 WHERE STM.STY_ID = l_stream_type_id
                 AND STM.KLE_ID = l_kle_id
                 AND STM.KHR_ID = l_khr_id
                 AND STM.ID = STEM.STM_ID
                 AND STEM.ACCRUED_YN = 'Y'
                 AND STM.PURPOSE_CODE IS NULL;



            CURSOR okl_trx_types (cp_name VARCHAR2, cp_language VARCHAR2) IS
            SELECT  id
            FROM    okl_trx_types_tl
            WHERE   name      = cp_name
            AND     language  = cp_language;



            CURSOR  C_OKL_STRM_TYPE_V(ls_stm_code VARCHAR2) IS
                select ID
             from OKL_STRM_TYPE_TL
             where NAME  = ls_stm_code
             AND LANGUAGE = 'US';



            CURSOR l_contract_currency_csr IS
            SELECT  currency_code
	               ,currency_conversion_type
	               ,currency_conversion_date
	        FROM    okl_k_headers_full_v
    		WHERE   id = p_ipyv_rec.khr_id ;



           CURSOR l_acc_dtls_csr(p_khr_id IN NUMBER) IS
            SELECT khr.pdt_id   pdt_id
      	   FROM  okl_k_headers_v khr
  	   	   WHERE khr.ID = p_khr_id;

           l_acct_call_rec     l_acc_dtls_csr%ROWTYPE;


    ----- Account Generator sources

    Cursor salesP_csr( chrId NUMBER) IS
        select ct.object1_id1 id
        from   okc_contacts        ct,
               okc_contact_sources csrc,
               okc_k_party_roles_b pty,
               okc_k_headers_b     chr
        where  ct.cpl_id               = pty.id
              and    ct.cro_code             = csrc.cro_code
              and    ct.jtot_object1_code    = csrc.jtot_object_code
              and    ct.dnz_chr_id           =  chr.id
              and    pty.rle_code            = csrc.rle_code
              and    csrc.cro_code           = 'SALESPERSON'
              and    csrc.rle_code           = 'LESSOR'
              and    csrc.buy_or_sell        = chr.buy_or_sell
              and    pty.dnz_chr_id          = chr.id
              and    pty.chr_id              = chr.id
              and    chr.id                  = chrId;


       l_salesP_rec salesP_csr%ROWTYPE;

      Cursor fnd_pro_csr IS
          select mo_global.get_current_org_id() l_fnd_profile
          from dual;
      fnd_pro_rec fnd_pro_csr%ROWTYPE;

      -- smoduga added for 3845998
      -- Cursor to get the maximum billed date for insurance recievables
      Cursor rcvbl_max_billed_date (c_sty_id NUMBER, c_khr_id NUMBER, c_kle_id NUMBER) IS
          SELECT max (stre.date_billed)
          FROM okl_strm_elements STRE,
               OKL_STREAMS STR
          WHERE STR.ID = STRE.STM_ID
            AND STR.STY_ID = c_sty_id
            AND STRE.DATE_BILLED IS NOT NULL
            AND STR.KHR_ID = c_khr_id
            AND STR.KLE_ID = c_kle_id;



       BEGIN
       l_ipyv_rec := p_ipyv_rec ;
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

        IF ((l_ipyv_rec.ID IS NULL ) OR (l_ipyv_rec.ID = OKC_API.G_MISS_NUM )) THEN
         x_return_status := OKC_API.G_RET_STS_ERROR;
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy ID');
          RAISE OKC_API.G_EXCEPTION_ERROR;
       ELSE
                       -- Check for TPI
                -- Added covered amount for bug 4701170
                OPEN c_ins_info(p_ipyv_rec.ID);
                FETCH c_ins_info INTO l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID
                ,l_ipyv_rec.OBJECT_VERSION_NUMBER, l_ipyv_rec.date_from, l_ipyv_rec.ipy_type,
                l_ipyv_rec.FACTOR_CODE, l_ipyv_rec.covered_amount;
                IF(c_ins_info%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_POLICY );
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_ins_info ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_ins_info ;
      END IF;


       IF (l_ipyv_rec.CRX_CODE = 'CANCELED_BY_CUSTOMER') THEN
          -- GET system profile to check for third party information
  	   ls_check_tpi := fnd_profile.value('OKLINCANCHECKTPI');
         IF ((ls_check_tpi IS NULL ) OR (ls_check_tpi = OKC_API.G_MISS_CHAR )) THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
  	      OKC_API.set_message(G_APP_NAME, G_NO_SYSTEM_PROFILE,G_SYS_PROFILE_NAME,'OKL: Cancel policy with proof of third party insurance' );
  	      RAISE OKC_API.G_EXCEPTION_ERROR;
         ELSIF  (ls_check_tpi = 'YES' )THEN
                -- Check for TPI
                OPEN c_okl_third_party(p_ipyv_rec.KHR_ID , p_ipyv_rec.cancellation_date);
                FETCH c_okl_third_party INTO l_id;
                IF(c_okl_third_party%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_NO_THIRD_PARTY,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,p_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_okl_third_party ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_okl_third_party ;
        END IF;
    END IF;



    -- PAY Customer Refund

               -- Start Fix for 3845998
               -- Checking for profile OKL:Maximum number of months allowed after payment for refund

                 -- procedure call added for insurance user defined streams, bug 3924300
                 OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

                   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                      Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
                       RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                 --smoduga: Bug  4387062 Start:
                   -- addded following assignment as l_rcvbl_strm_type_id contains no value resulting in billing cursor to fetch no records
                  l_rcvbl_strm_type_id:=l_strm_type_id;
                  --smoduga: Bug  4387062 End:

               OPEN rcvbl_max_billed_date(l_rcvbl_strm_type_id, l_ipyv_rec.khr_id, l_ipyv_rec.kle_id );
               FETCH rcvbl_max_billed_date INTO l_last_billed_date;
               CLOSE rcvbl_max_billed_date;

               l_check_refund_months:= fnd_profile.value('OKLINMAXNOOFMONTHSREFUND');

               IF MONTHS_BETWEEN (l_ipyv_rec.cancellation_date,l_last_billed_date) < l_check_refund_months THEN  --[A]
                 pay_cust_refund(
                                  p_api_version   => l_api_version,
                                  p_init_msg_list => OKC_API.G_FALSE,
                                  x_return_status => l_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_contract_id   => l_ipyv_rec.khr_id ,
                                  p_contract_line => l_ipyv_rec.kle_id ,
                                  p_cancellation_date => l_ipyv_rec.cancellation_date, ---++ Eff Dated Termination
                                  x_refund_amount  => l_cust_refund);

                  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                END IF; -- [A] End fix for  3845998

  --- PAY or clawback from vendor

                 calc_vendor_clawback(
                      p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_ipyv_rec   => l_ipyv_rec ,
                      x_ipyv_rec => x_ipyv_rec ,
                      x_vendor_adjustment => l_vendor_adjustment);

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;



 ---Inactivate all stream / accounting entries
                 Inactivate_open_items(
                         p_api_version   => l_api_version,
                      p_init_msg_list => OKC_API.G_FALSE,
                      x_return_status => l_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_contract_id   => l_ipyv_rec.khr_id ,
                      p_contract_line => l_ipyv_rec.kle_id,
                      p_policy_status =>  l_ipyv_rec.iss_code );

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
                  -- GET contract status
             	l_return_status :=	get_contract_status(l_ipyv_rec.khr_id, l_khr_status);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          IF (l_khr_status =  'ACTIVE' ) THEN
               -- if active, end date contract line and update status

              l_clev_rec.ID := l_ipyv_rec.kle_id ;
    			l_clev_rec.sts_code :=  'TERMINATED';
  			l_klev_rec.ID := l_ipyv_rec.kle_id ;
              l_clev_rec.DATE_TERMINATED :=  l_ipyv_rec.CANCELLATION_DATE;


  		  Okl_Contract_Pub.update_contract_line
  		   (
      	   p_api_version      => l_api_version ,
  		   p_init_msg_list           => OKC_API.G_FALSE,
  		   x_return_status      => l_return_status    ,
  		   x_msg_count           => x_msg_count,
  		   x_msg_data            => x_msg_data ,
  		   p_clev_rec            => l_clev_rec  ,
  		   p_klev_rec            => l_klev_rec,
  		   p_edit_mode            =>'N'        ,
  		   x_clev_rec            => lx_clev_rec,
  		   x_klev_rec            => lx_klev_rec
  		   );

              IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                -- Status temp
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

                -- Status temp
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;

              -- contract status is not active
              ELSE

                        l_clev_rec.ID := l_ipyv_rec.kle_id ;
		       	l_clev_rec.sts_code :=  'TERMINATED';
		     	l_klev_rec.ID := l_ipyv_rec.kle_id ;
		        l_clev_rec.DATE_TERMINATED :=  l_ipyv_rec.CANCELLATION_DATE;


		     	Okl_Contract_Pub.update_contract_line
		     		(
		         	p_api_version      => l_api_version ,
		     		p_init_msg_list           => OKC_API.G_FALSE,
		     		x_return_status      => l_return_status    ,
		     		x_msg_count           => x_msg_count,
		     		x_msg_data            => x_msg_data ,
		     		p_clev_rec            => l_clev_rec  ,
		     		p_edit_mode            =>'N'        ,
		     		p_klev_rec            => l_klev_rec,
		     		x_clev_rec            => lx_clev_rec,
		     		x_klev_rec            => lx_klev_rec );

		         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		                   -- Status temp
		             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
		                   -- Status temp
		                   RAISE OKC_API.G_EXCEPTION_ERROR;
              		  END IF;

            END IF;


            -- Income Adjustment
            -- Sum of Billed Premium(1) - Sum of refund amount(2) - Sum of accrued income(3)
                 -- stream type id added to the cursor parameters, user defined streams, bug 3924300
                OPEN c_total_billed(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_rcvbl_strm_type_id);
                FETCH c_total_billed INTO l_total_billed;

                IF(c_total_billed%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_billed ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_total_billed ;



                  -- procedure call added to get the stream type id, user defined streams
                  -- bug 3924300

                  OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id);

                   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;


                 -- stream type id added as additional parameter to the cursor,
                 -- for user defined streams changes, bug 3924300
                OPEN c_total_bill_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_bill_accrued INTO l_total_bill_accrued;
                IF(c_total_bill_accrued%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_bill_accrued ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_total_bill_accrued ;
                 l_adjustment_amount := l_total_billed - l_total_bill_accrued - l_cust_refund ;


                  OPEN okl_trx_types ('Insurance', 'US');
                  FETCH okl_trx_types INTO l_ins_try_id;
                  IF(okl_trx_types%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
                      G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,'Insurance');
                      x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE okl_trx_types ;
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                   END if ;
                   CLOSE okl_trx_types;

                                                 -- GET Product
               OPEN l_acc_dtls_csr(l_ipyv_rec.KHR_ID );
              FETCH l_acc_dtls_csr INTO l_ptid;
              IF(l_acc_dtls_csr%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSREFUND');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
               CLOSE l_acc_dtls_csr ;
               RAISE OKC_API.G_EXCEPTION_ERROR;
               END if ;
              CLOSE l_acc_dtls_csr;



            BEGIN
	      OPEN l_contract_currency_csr;
	      FETCH l_contract_currency_csr INTO  l_curr_code,l_currency_conversion_type,
	       l_currency_conversion_date ;
	      CLOSE l_contract_currency_csr;
	       EXCEPTION
	      	 WHEN NO_DATA_FOUND THEN
	      	 	OKC_API.set_message(G_APP_NAME, G_NO_K_TERM,G_COL_VALUE_TOKEN,p_ipyv_rec.khr_id );
	      	 	x_return_status := OKC_API.G_RET_STS_ERROR;
	      	        IF l_contract_currency_csr%ISOPEN THEN
	      	   	   CLOSE l_contract_currency_csr;
	      	   	 END IF;
	      	 	RAISE OKC_API.G_EXCEPTION_ERROR;
	      	        WHEN OTHERS THEN
	      	 	  IF l_contract_currency_csr%ISOPEN THEN
	      	   	      	      CLOSE l_contract_currency_csr;
	      	   	   END IF;
	      	 		-- store SQL error message on message stack for caller
	      	           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,
	      	                                           SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
	      	 		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR ;
	      	 	    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
	      	   END;


 ---                l_curr_code := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

/* Bug#5955320
                 IF (l_adjustment_amount <> 0 ) THEN

                   -- header data
                    l_tcnv_rec_in.khr_id                    := l_ipyv_rec.KHR_ID ;
                    l_tcnv_rec_in.try_id                    := l_ins_try_id;
                    l_tcnv_rec_in.tsu_code                  := 'ENTERED';
                    l_tcnv_rec_in.tcn_type                  := 'AAJ';
                    l_tcnv_rec_in.date_transaction_occurred := l_ipyv_rec.CANCELLATION_DATE;
                    l_tcnv_rec_in.amount                    := l_adjustment_amount;
                    l_tcnv_rec_in.currency_code             := l_curr_code ;
                    l_tcnv_rec_in.currency_conversion_type  := l_currency_conversion_type ;
                    l_tcnv_rec_in.currency_conversion_date := l_currency_conversion_date ;
                  -- Line Data
                  l_tclv_tbl(1).line_number :=  1;
                  l_tclv_tbl(1).khr_id :=  l_ipyv_rec.KHR_ID;
                  l_tclv_tbl(1).tcl_type := 'AAJ' ;
                  l_tclv_tbl(1).AMOUNT := l_adjustment_amount;
                  l_tclv_tbl(1).currency_code       := l_curr_code ;
                  l_tclv_tbl(1).ORG_ID := l_ipyv_rec.org_id ;




-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
                     OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
                       p_api_version  => l_api_version,
                       p_init_msg_list  => OKC_API.G_FALSE,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_tcnv_rec       =>l_tcnv_rec_in  ,
                       p_tclv_tbl       => l_tclv_tbl,
		       x_tcnv_rec       => x_tcnv_rec_in,
    			x_tclv_tbl      => x_tclv_tbl
    			);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts


   ---------------------------------------------------------------------------------------
                  counter := 1;

	                 OPEN  fnd_pro_csr;
	                 FETCH fnd_pro_csr INTO fnd_pro_rec;
	                 IF ( fnd_pro_csr%FOUND ) Then
	                     l_acc_gen_primary_key_tbl(counter).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
	                     l_acc_gen_primary_key_tbl(counter).primary_key_column := fnd_pro_rec.l_fnd_profile;
	                     counter := counter + 1 ;
	                 End IF;
	                 CLOSE fnd_pro_csr;



	                 OPEN  salesP_csr(l_ipyv_rec.KHR_ID);
	                 FETCH salesP_csr INTO l_salesP_rec;
	                 IF ( salesP_csr%FOUND ) Then
	                         l_acc_gen_primary_key_tbl(counter).source_table := 'JTF_RS_SALESREPS_MO_V';
	                 	l_acc_gen_primary_key_tbl(counter).primary_key_column := l_salesP_rec.id;
	                        counter := counter + 1 ;
	                 END IF ;
                 CLOSE salesP_csr;

       ------------------------------------------------------------------------------------

 */
/* Bug#5955320


                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
*/
                /*OPEN C_OKL_STRM_TYPE_V('INSURANCE INCOME');
              FETCH C_OKL_STRM_TYPE_V INTO l_inc_sty_id;
              IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
                  Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                  G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE INCOME');
                  x_return_status := OKC_API.G_RET_STS_ERROR ;
                   CLOSE C_OKL_STRM_TYPE_V ;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
             END if ;
              CLOSE C_OKL_STRM_TYPE_V;*/

/* Bug#5955320
             -- cursor fetch replaced with the call to get the stream type id
             -- changes done for user defined streams, bug 3924300
                OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_INCOME_ACCRUAL',
                                                   l_return_status,
                                                   l_inc_sty_id);

                 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_INCOME_ACCRUAL'); --bug 4024785
                  RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;

          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - Start
          get_special_acct_codes(p_khr_id                => l_ipyv_rec.KHR_ID,
                                 p_trx_date              => SYSDATE,
                                 x_fact_sync_code        => l_fact_sync_code,
	                         x_inv_acct_code         => l_inv_acct_code );
          -- gboomina Bug 4622198 - Added for Investor Special Accounting Codes - End

          -- Populate Records for Accounting Call.
          l_tmpl_identify_rec.PRODUCT_ID             := l_ptid;
    	  l_tmpl_identify_rec.TRANSACTION_TYPE_ID    := l_ins_try_id;
          l_tmpl_identify_rec.STREAM_TYPE_ID         := l_inc_sty_id;
    	  l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting  - Start
          l_tmpl_identify_rec.FACTORING_SYND_FLAG    := l_fact_sync_code;
	  l_tmpl_identify_rec.INVESTOR_CODE          := l_inv_acct_code;
	  -- gboomina Bug 4622198 - Modified for Investor Special Accounting - End
    	  l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
          l_tmpl_identify_rec.FACTORING_CODE         := NULL;
    	  l_tmpl_identify_rec.MEMO_YN                := 'N';
          l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';

          l_dist_info_rec.SOURCE_ID                  := x_tclv_tbl(1).ID;
          l_dist_info_rec.SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
          l_dist_info_rec.ACCOUNTING_DATE            := SYSDATE;
          l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
          l_dist_info_rec.POST_TO_GL                 := 'N';
          l_dist_info_rec.AMOUNT                     := l_adjustment_amount;
          l_dist_info_rec.CURRENCY_CODE              := l_curr_code;
          --- Not sure
          l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
          l_dist_info_rec.CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
          l_dist_info_rec.CONTRACT_ID                := l_ipyv_rec.KHR_ID  ;
          l_dist_info_rec.CONTRACT_LINE_ID           := l_ipyv_rec.KLE_ID;



  IF (l_adjustment_amount > 0 )THEN






-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;




      Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
  								   p_api_version             => p_api_version
                                    ,p_init_msg_list  		 => p_init_msg_list
                                    ,x_return_status  		 => x_return_status
                                    ,x_msg_count      		 => x_msg_count
                                    ,x_msg_data       		 => x_msg_data
                                    ,p_tmpl_identify_rec 		 => l_tmpl_identify_rec
                                    ,p_dist_info_rec           => l_dist_info_rec
                                    ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                    ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                    ,x_template_tbl            => l_template_tbl
                                    ,x_amount_tbl              => l_amount_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST



              IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
           END IF ;

  END IF;
*/

-- Create accouting for income
         --

           -- Expense Adjustment
            -- Sum of Disbursed Payable(1) - Sum of payable debit(sign)(2) - Sum of accrued insurance (3)

               -- call added to get the stream type id, changes done for user defined streams
               -- bug 3924300
                 OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_PAYABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

               IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_PAYABLE'); --bug 4024785
                 RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;
              -- cursor opened with additional parameter stream type id,
              -- changes done for user defined streams, bug 3924300

              OPEN c_total_paid(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_paid INTO l_total_paid;
                IF(c_total_paid%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_paid ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_total_paid ;

/* Bug#5955320
                   -- call added to get the stream type id, changes done for user defined streams
                   -- bug 3924300
                 OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   l_strm_type_id);

                 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;


                -- additional parameter stream type id added to the cursor call
                -- changes done for user defined streams, bug 3924300

                 OPEN c_total_payment_accrued(l_ipyv_rec.KHR_ID , l_ipyv_rec.KLE_ID,l_strm_type_id);
                FETCH c_total_payment_accrued INTO l_total_pay_accrued;
                IF(c_total_payment_accrued%NOTFOUND) THEN
                      Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT,
                          G_COL_NAME_TOKEN,'Contract ID',G_COL_VALUE_TOKEN,l_ipyv_rec.KHR_ID);
                          x_return_status := OKC_API.G_RET_STS_ERROR ;
                      CLOSE c_total_payment_accrued ;
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                 CLOSE c_total_payment_accrued ;

                 l_adjustment_amount := l_total_paid- l_vendor_adjustment- l_total_pay_accrued;

	  IF (l_adjustment_amount <> 0 ) THEN

                    l_tcnv_rec_in.khr_id                    := l_ipyv_rec.KHR_ID ;
                    l_tcnv_rec_in.try_id                    := l_ins_try_id;
                    l_tcnv_rec_in.tsu_code                  := 'ENTERED';
                    l_tcnv_rec_in.tcn_type                  := 'AAJ';
                    l_tcnv_rec_in.date_transaction_occurred := l_ipyv_rec.CANCELLATION_DATE;
                    l_tcnv_rec_in.amount                    := l_adjustment_amount;
                    l_tcnv_rec_in.currency_code             := l_curr_code ;
		    l_tcnv_rec_in.currency_conversion_type  := l_currency_conversion_type ;
		    l_tcnv_rec_in.currency_conversion_date := l_currency_conversion_date ;

		    -- Line Data
		    l_tclv_tbl(1).line_number :=  1;
		    l_tclv_tbl(1).khr_id :=  l_ipyv_rec.KHR_ID;
		    l_tclv_tbl(1).tcl_type := 'AAJ' ;
		    l_tclv_tbl(1).AMOUNT := l_adjustment_amount;
		    l_tclv_tbl(1).currency_code       := l_curr_code ;
                    l_tclv_tbl(1).ORG_ID := l_ipyv_rec.org_id ;



-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
                    OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
			   p_api_version  => l_api_version,
			   p_init_msg_list  => OKC_API.G_FALSE,
			   x_return_status => x_return_status,
			   x_msg_count     => x_msg_count,
			   x_msg_data      => x_msg_data,
			   p_tcnv_rec       =>l_tcnv_rec_in  ,
			   p_tclv_tbl       => l_tclv_tbl,
		       	   x_tcnv_rec       => x_tcnv_rec_in,
			   x_tclv_tbl      => x_tclv_tbl
    			);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_contracts ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_contracts


                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;
*/
               /* OPEN C_OKL_STRM_TYPE_V('INSURANCE EXPENSE');
                  FETCH C_OKL_STRM_TYPE_V INTO l_inc_sty_id;
                  IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
                    Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
                    G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE EXPENSE');
                    x_return_status := OKC_API.G_RET_STS_ERROR ;
                    CLOSE C_OKL_STRM_TYPE_V ;
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                  END if ;
                  CLOSE C_OKL_STRM_TYPE_V;*/

/* Bug#5955320
               -- cursor fetch to get the stream type id replaced with the call,
               --  changed for insurance user defined streams, bug 3924300

                OKL_STREAMS_UTIL.get_primary_stream_type(l_ipyv_rec.khr_id,
                                                   'INSURANCE_EXPENSE_ACCRUAL',
                                                   l_return_status,
                                                   l_inc_sty_id);

                    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                      Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_EXPENSE_ACCRUAL'); --bug 4024785

                      RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;


                              -- Populate Records for Accounting Call.
        	l_tmpl_identify_rec.PRODUCT_ID             := l_ptid;
    	    l_tmpl_identify_rec.TRANSACTION_TYPE_ID    := l_ins_try_id;
        	l_tmpl_identify_rec.STREAM_TYPE_ID         := l_inc_sty_id;
    	    l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
        	l_tmpl_identify_rec.FACTORING_SYND_FLAG    := NULL;
    	    l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
        	l_tmpl_identify_rec.FACTORING_CODE         := NULL;
    	    l_tmpl_identify_rec.MEMO_YN                := 'N';
        	l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';



          l_dist_info_rec.SOURCE_ID                  := x_tclv_tbl(1).ID;
          l_dist_info_rec.SOURCE_TABLE               := 'OKL_TXL_CNTRCT_LNS';
          l_dist_info_rec.ACCOUNTING_DATE            := SYSDATE;
          l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
          l_dist_info_rec.POST_TO_GL                 := 'N';
          l_dist_info_rec.AMOUNT                     := l_adjustment_amount;
          l_dist_info_rec.CURRENCY_CODE              := l_curr_code;
          l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := l_currency_conversion_type;
          l_dist_info_rec.CURRENCY_CONVERSION_DATE   := l_currency_conversion_date;
          l_dist_info_rec.CONTRACT_ID                := l_ipyv_rec.KHR_ID  ;
          l_dist_info_rec.CONTRACT_LINE_ID           := l_ipyv_rec.KLE_ID;



     IF ( l_adjustment_amount > 0) THEN


	-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
	  IF(IS_DEBUG_PROCEDURE_ON) THEN
	    BEGIN
	        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
	    END;
	  END IF;
	      Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
  								   p_api_version             => p_api_version
                                    ,p_init_msg_list  		 => p_init_msg_list
                                    ,x_return_status  		 => x_return_status
                                    ,x_msg_count      		 => x_msg_count
                                    ,x_msg_data       		 => x_msg_data
                                    ,p_tmpl_identify_rec 		 => l_tmpl_identify_rec
                                    ,p_dist_info_rec           => l_dist_info_rec
                                    ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                    ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                    ,x_template_tbl            => l_template_tbl
                                    ,x_amount_tbl              => l_amount_tbl);
	  	IF(IS_DEBUG_PROCEDURE_ON) THEN
	  	  BEGIN
	  	      OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
	  	  END;
	  	END IF;
	--	 End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST



	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;

   END IF ;


  END IF;

*/
                l_ipyv_rec.iss_code := 'CANCELED';

            -- Create entry for adjustment
                 --Update Policy

-- Start of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
            Okl_Ins_Policies_Pub.update_ins_policies(
  	         p_api_version                  => p_api_version,
  	          p_init_msg_list                => OKC_API.G_FALSE,
  	          x_return_status                => l_return_status,
  	          x_msg_count                    => x_msg_count,
  	          x_msg_data                     => x_msg_data,
  	          p_ipyv_rec                     => l_ipyv_rec,
  	          x_ipyv_rec                     => x_ipyv_rec
  	          );

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call Okl_Ins_Policies_Pub.update_ins_policies ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Ins_Policies_Pub.update_ins_policies

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

                 -- Notify Vendor
                   -- To be implemented

                 -- send Notification to customer
                   --  To be implemented

      --   END IF ;
  --     END IF;
              -- gboomina start - Bug 4728636
              OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( p_ipyv_rec.khr_id );
              -- gboomina end - Bug 4728636
              OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
            EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
      END cancel_policy;


       PROCEDURE get_refund(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_policy_id                  IN  NUMBER,
       p_cancellation_date          IN DATE DEFAULT NULL, --++ Effective Dated Termination ++--
       p_crx_code                     IN VARCHAR2 DEFAULT NULL,
       x_refund_amount            OUT NOCOPY NUMBER
       )IS
       l_value       NUMBER ;
       l_contract_id  NUMBER;
       l_contract_line NUMBER;
       l_api_name CONSTANT VARCHAR2(30) := 'get_refund';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1) ;
       l_params	okl_execute_formula_pub.ctxt_val_tbl_type; ---+++ Effective Dated Termination ++++----

       CURSOR okl_ipy_rec(p_policy_id NUMBER) IS
       SELECT KHR_ID ,  KLE_ID
       FROM OKL_INS_POLICIES_B
       WHERE ID = p_policy_id;

       BEGIN

           l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OPEN okl_ipy_rec(p_policy_id);
       FETCH okl_ipy_rec INTO l_contract_id, l_contract_line;
       IF(okl_ipy_rec%NOTFOUND) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_POLICY,
          G_COL_NAME_TOKEN,'Policy ID',G_COL_VALUE_TOKEN,p_policy_id);
          x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE okl_ipy_rec ;
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END if ;
       CLOSE okl_ipy_rec ;
-- Start of wraper code generated automatically by Debug code generator for OKL_EXECUTE_FORMULA_PUB.EXECUTE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call OKL_EXECUTE_FORMULA_PUB.EXECUTE ');
    END;
  END IF;
                --++ Effective Dated Termination ++----
                l_params(1).name	:= G_FORMULA_PARAM_1;
           	l_params (1).value	:= to_char(p_cancellation_date);
                l_params(2).name        := G_FORMULA_PARAM_2;
                l_params(2).value	:= to_char(p_crx_code);
                --++ Effective Dated Termination ++----

                OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => l_api_version,
                                           p_init_msg_list => OKC_API.G_FALSE,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_formula_name  => G_FORMULA_REFUND_CALC,
                                           p_contract_id   => l_contract_id,
                                           p_line_id       => l_contract_line,
                                           p_additional_parameters => l_params, ---+++ Eff Dated Term changes ++----
                                           x_value         => x_refund_amount );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call OKL_EXECUTE_FORMULA_PUB.EXECUTE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_EXECUTE_FORMULA_PUB.EXECUTE
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;


     EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
     END get_refund;

          PROCEDURE pay_cust_refund(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_contract_id                  IN  NUMBER,
       p_contract_line            IN NUMBER,
       p_cancellation_date        IN DATE DEFAULT NULL, --++Eff Dated Termination ++--
       p_crx_code                 IN VARCHAR2,
       x_refund_amount            OUT NOCOPY NUMBER
       )IS
        l_ret_status  varchar2(1) ;
       l_value       NUMBER ;
       l_contract_id  NUMBER;
       l_contract_line NUMBER;
       l_api_name CONSTANT VARCHAR2(30) := 'pay_cust_refund';
       l_api_version         CONSTANT NUMBER := 1;
       l_return_status      VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS ;
       l_policy_id      NUMBER ;
       l_refund_amount  NUMBER;
       l_strm_type_id   NUMBER ;
       l_amount NUMBER;



        CURSOR okl_trx_types(cp_name VARCHAR2,cp_language VARCHAR2) IS
         SELECT  id
        FROM    okl_trx_types_tl
        WHERE   name      = cp_name
        AND     language  = cp_language;


       CURSOR okl_ins_policy_id(p_contract_line NUMBER) IS
       SELECT id
       FROM OKL_INS_POLICIES_B
       WHERE KLE_ID = p_contract_line;
       p_name VARCHAR2(150) :='Credit Memo'; --bug 3923601
       p_lang VARCHAR2(2) := 'US' ;
       l_trx_type NUMBER ;
       l_sty_id  NUMBER ;
       l_strm_refund_id NUMBER;
       l_tai_id  NUMBER ;

       CURSOR  C_OKL_STRM_TYPE_V(ls_stm_code VARCHAR2) IS
        select ID
         from OKL_STRM_TYPE_TL
         where NAME  = ls_stm_code
         AND LANGUAGE = 'US';


       BEGIN
          l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                         G_PKG_NAME,
                                                        p_init_msg_list,
                                                        l_api_version,
                                                        p_api_version,
                                                        '_PROCESS',
                                                        x_return_status);
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


       -- GET REFUND

       --1. get Policy id
        OPEN okl_ins_policy_id(p_contract_line);
        FETCH okl_ins_policy_id INTO l_policy_id;
       IF(okl_ins_policy_id%NOTFOUND) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_POLICY,
          G_COL_NAME_TOKEN,'Contract Line ID',G_COL_VALUE_TOKEN,p_contract_line);
          x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE okl_ins_policy_id ;
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END if ;
       CLOSE okl_ins_policy_id ;
       --2.

       get_refund(
       p_api_version                  => l_api_version,
       p_init_msg_list                =>Okc_Api.G_FALSE,
       x_return_status                => l_return_status,
       x_msg_count                    =>x_msg_count,
       x_msg_data                     =>x_msg_data,
       p_policy_id                  => l_policy_id,
       p_cancellation_date            => p_cancellation_Date,
       p_crx_code                    => p_crx_code,
       x_refund_amount            => l_refund_amount );

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status ; --bug 3923601
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          x_return_status := l_return_status ; --bug 3923601
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
      x_refund_amount  := l_refund_amount ;


  --- GET Transaction Type
      BEGIN

          OPEN okl_trx_types (p_name, p_lang);
          FETCH okl_trx_types INTO l_trx_type;
          IF(okl_trx_types%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_TRX,
              G_COL_NAME_TOKEN,'Transaction Type',G_COL_VALUE_TOKEN,p_name);
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE okl_trx_types ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;
          CLOSE okl_trx_types;
      END;

     IF(l_refund_amount > 0 ) THEN

      -- GET STream ID
       l_refund_amount := -(x_refund_amount) ; --bug 3923601
       BEGIN

          /*OPEN C_OKL_STRM_TYPE_V('INSURANCE RECEIVABLE');
          FETCH C_OKL_STRM_TYPE_V INTO l_strm_type_id;
          IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
              G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE RECEIVABLE');
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_OKL_STRM_TYPE_V ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;
          CLOSE C_OKL_STRM_TYPE_V;*/
          -- cursor fetch replaced with the procedure call to get the stream type id,
          -- changes done for user defined streams, bug 3924300

                   OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_strm_type_id);

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
             Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE',G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); --bug 4024785
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;



      END;
      BEGIN

          /*OPEN C_OKL_STRM_TYPE_V('INSURANCE REFUND');
          FETCH C_OKL_STRM_TYPE_V INTO l_strm_refund_id;
          IF(C_OKL_STRM_TYPE_V%NOTFOUND) THEN
              Okc_Api.set_message(G_APP_NAME, G_NO_STREAM,
              G_COL_NAME_TOKEN,'Stream Type',G_COL_VALUE_TOKEN,'INSURANCE REFUND');
              x_return_status := OKC_API.G_RET_STS_ERROR ;
           CLOSE C_OKL_STRM_TYPE_V ;
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END if ;
          CLOSE C_OKL_STRM_TYPE_V;*/

            -- call added to  get the stream type id,
            -- changes done for user defined streams, bug 3924300

             OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   'INSURANCE_REFUND',
                                                   l_return_status,
                                                   l_strm_refund_id);

           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
		Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_REFUND'); --bug 4024785
                        RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;


       END;

    -- Call API to create Credit Memo
    -- Start of wraper code generated automatically by Debug code generator for on_account_credit_memo
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRIPXB.pls call on_account_credit_memo ');
    END;
  END IF;

--bug 3923601
 on_account_credit_memo
              (
              p_api_version     => l_api_version,
              p_init_msg_list   => OKL_API.G_FALSE,
              p_try_id          => l_trx_type,
              p_khr_id          => p_contract_id,
              p_kle_id          => p_contract_line,
              p_ipy_id          => l_policy_id,
              p_credit_date     => TRUNC(SYSDATE),
              p_credit_amount   => l_refund_amount,
              p_credit_sty_id   => l_strm_refund_id,
              x_return_status   => l_return_status,
              x_msg_count       =>x_msg_count,
              x_msg_data        => x_msg_data,
              x_tai_id          => l_tai_id

          );


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRIPXB.pls call on_account_credit_memo ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for  on_account_credit_memo.

             IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := l_return_status ; --bug 3923601
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 x_return_status := l_return_status ; --bug 3923601
                RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;


        NULL;




     END IF ;

  	 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
            WHEN OTHERS THEN
              x_return_status :=OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PROCESS'
              );
       END pay_cust_refund;




        PROCEDURE OKL_INSURANCE_PARTY_MERGE (
           p_entity_name                IN   VARCHAR2,
           p_from_id                    IN   NUMBER,
           x_to_id                      OUT NOCOPY  NUMBER,
           p_from_fk_id                 IN    NUMBER,
           p_to_fk_id                   IN   NUMBER,
           p_parent_entity_name         IN   VARCHAR2,
           p_batch_id                   IN   NUMBER,
           p_batch_party_id             IN   NUMBER,
           x_return_status              OUT NOCOPY  VARCHAR2)
       IS
       --
          l_merge_reason_code          VARCHAR2(30);
          l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_PARTY_MERGE';
          l_count                      NUMBER(10)   := 0;
       --
       BEGIN
       --
          fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_MERGE');
       --
          arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_MERGE()+');

          x_return_status :=  FND_API.G_RET_STS_SUCCESS;


       --
          select merge_reason_code
          into   l_merge_reason_code
          from   hz_merge_batch
          where  batch_id  = p_batch_id;

          if l_merge_reason_code = 'DUPLICATE' then
       	 -- if reason code is duplicate then allow the party merge to happen without
       	 -- any validations.
       	 null;
          else
       	 -- if there are any validations to be done, include it in this section
       	 null;
          end if;

          -- If the parent has not changed (ie. Parent getting transferred) then nothing
          -- needs to be done. Set Merged To Id is same as Merged From Id and return

          if p_from_fk_id = p_to_fk_id then
       	 x_to_id := p_from_id;
             return;
          end if;

          -- If the parent has changed(ie. Parent is getting merged) then transfer the
          -- dependent record to the new parent. Before transferring check if a similar
          -- dependent record exists on the new parent. If a duplicate exists then do
          -- not transfer and return the id of the duplicate record as the Merged To Id

          if p_from_fk_id <> p_to_fk_id then
             begin
               arp_message.set_name('AR','AR_UPDATING_TABLE');
               arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);
       --
       --

         UPDATE OKL_INS_POLICIES_B IPYB
         SET IPYB.ISU_ID = p_to_fk_id
            ,IPYB.object_version_number = IPYB.object_version_number + 1
            ,IPYB.last_update_date      = SYSDATE
            ,IPYB.last_updated_by       = arp_standard.profile.user_id
            ,IPYB.last_update_login     = arp_standard.profile.last_update_login
         WHERE IPYB.ISU_ID = p_from_fk_id ;
       x_to_id := p_from_id;
         l_count := sql%rowcount;
         arp_message.set_name('AR','AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS',to_char(l_count));
       --
         exception
           when others then
                 arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
       --
       	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
       	       'OKL_INS_POLICIES for = '|| p_from_id));
       --
                 fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
                 x_return_status :=  FND_API.G_RET_STS_ERROR;
         end;
        end if;
END OKL_INSURANCE_PARTY_MERGE ;


-----------------------------------------------------------------------------------
 PROCEDURE OKL_INSURANCE_PARTY_SITE_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_PARTY_SITE_MERGE';
   l_count                      NUMBER(10)   := 0;
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_SITE_MERGE');
--
   arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_SITE_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);
--
--

  UPDATE OKL_INS_POLICIES_B IPYB
  SET IPYB.AGENCY_SITE_ID = p_to_fk_id
     ,IPYB.object_version_number = IPYB.object_version_number + 1
     ,IPYB.last_update_date      = SYSDATE
     ,IPYB.last_updated_by       = arp_standard.profile.user_id
     ,IPYB.last_update_login     = arp_standard.profile.last_update_login
  WHERE IPYB.AGENCY_SITE_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_INS_POLICIES for = '|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_INSURANCE_PARTY_SITE_MERGE ;

----------------------------------------------------------------------------------
 PROCEDURE OKL_INSURANCE_AGENT_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_AGENT_MERGE';
   l_count                      NUMBER(10)   := 0;
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_MERGE');
--
   arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);
--
--

  UPDATE OKL_INS_POLICIES_B IPYB
  SET IPYB.INT_ID = p_to_fk_id
     ,IPYB.object_version_number = IPYB.object_version_number + 1
     ,IPYB.last_update_date      = SYSDATE
     ,IPYB.last_updated_by       = arp_standard.profile.user_id
     ,IPYB.last_update_login     = arp_standard.profile.last_update_login
  WHERE IPYB.INT_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_INS_POLICIES for = '|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_INSURANCE_AGENT_MERGE ;
-----------------------------------------------------------------------------
 PROCEDURE OKL_INSURANCE_AGENT_SITE_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_AGENT_SITE_MERGE';
   l_count                      NUMBER(10)   := 0;
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_SITE_MERGE');
--
   arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_SITE_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);
--
--

  UPDATE OKL_INS_POLICIES_B IPYB
  SET IPYB.AGENT_SITE_ID = p_to_fk_id
     ,IPYB.object_version_number = IPYB.object_version_number + 1
     ,IPYB.last_update_date      = SYSDATE
     ,IPYB.last_updated_by       = arp_standard.profile.user_id
     ,IPYB.last_update_login     = arp_standard.profile.last_update_login
  WHERE IPYB.AGENT_SITE_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_INS_POLICIES for = '|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_INSURANCE_AGENT_SITE_MERGE ;

END OKL_INSURANCE_POLICIES_PVT;

/

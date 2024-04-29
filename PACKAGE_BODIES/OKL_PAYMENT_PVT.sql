--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_PVT" AS
/* $Header: OKLRPAYB.pls 120.21 2007/10/11 16:03:11 varangan noship $ */

  SUBTYPE rctv_rec_type IS Okl_Rct_Pvt.rctv_rec_type;
  SUBTYPE rcav_tbl_type IS Okl_Rca_Pvt.rcav_tbl_type;

  SUBTYPE rcpt_rec_type IS OKL_RECEIPTS_PVT.rcpt_rec_type;
  SUBTYPE appl_tbl_type IS OKL_RECEIPTS_PVT.appl_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;
  ---------------------------------------------------------------------------
  -- PROCEDURE GET_ORG_ID
  ---------------------------------------------------------------------------
  -- Get Org ID for a contract
  FUNCTION GET_ORG_ID(
			     	p_contract_id	IN NUMBER,
				x_org_id	 OUT NOCOPY NUMBER
			   )
  RETURN VARCHAR2 AS
  -- get org_id for contract
    CURSOR get_org_id_csr (p_contract_id IN VARCHAR2) IS
      SELECT authoring_org_id
      FROM   okc_k_headers_b
      WHERE  id = p_contract_id;

    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

  BEGIN

    OPEN get_org_id_csr(p_contract_id);
    FETCH get_org_id_csr INTO x_org_id;
    CLOSE get_org_id_csr;

    RETURN l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END GET_ORG_ID;

  ---------------------------------------------------------------------------
  -- PROCEDURE CREATE_INTERNAL_TRANS
  ---------------------------------------------------------------------------
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_contract_id			IN NUMBER,
     p_contract_num                 IN VARCHAR2 DEFAULT NULL,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version       CONSTANT NUMBER := 1;
  l_api_name          CONSTANT VARCHAR2(30) := 'OKL_PAYMENT_PVT';
  l_return_status     VARCHAR2(1)           := Okl_Api.G_RET_STS_SUCCESS;
  i                   NUMBER                := 1;
  l_check             NUMBER := 0;
  l_org_id            NUMBER;
  l_rctv_rec          rctv_rec_type;
  x_rctv_rec          rctv_rec_type;
  l_rcav_tbl          rcav_tbl_type;
  x_rcav_tbl          rcav_tbl_type;

  CURSOR   get_receipt_method_csr(p_payment_method_id NUMBER) IS
    SELECT  1
    FROM   ar_receipt_methods
    WHERE  receipt_method_id = p_payment_method_id;

--jsanju 07/09 as per IEX requirements ( bug #3040085)
cursor c_get_exchange_info (p_contract_id IN NUMBER) IS
-- converting into upper because of the BPD code, they are looking for
-- upper conversion_types - CORPORATE, SPOT ,USER in okl_cash_appl_rules.
--                                                   handle_manual_pay
 select UPPER(currency_conversion_type),
        currency_conversion_rate,
        currency_conversion_date
 from okl_k_headers
 where id =p_contract_id;

 l_functional_currency   okl_trx_contracts.currency_code%TYPE;

  BEGIN

    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PAYMENT',
                                              x_return_status);

    /*    Processing Starts     */
    -- Check if Customer ID is null
    IF p_customer_id IS NULL THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_CUSTOMER_ID_NULL );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Check if Contract ID is null
    IF p_contract_id IS NULL THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_CONTRACT_ID_NULL );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Get org Id for the contract
    --l_return_status := get_org_id(p_contract_id, l_org_id);

    l_org_id :=mo_global.get_current_org_id();
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- get payment method
    OPEN  get_receipt_method_csr(p_payment_method_id);
    FETCH get_receipt_method_csr INTO l_check;
    CLOSE get_receipt_method_csr;

    -- Check if payment_method is null
    IF (l_check <> 1) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_PAYMENT_METHOD_INVALID );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Create record in Internal Transaction Table.
    -- CREATE HEADER REC
    --  l_rctv_rec.IBA_ID	 := l_iba_id;        -- bank account id
    l_rctv_rec.IRM_ID		 := p_payment_method_id;      -- receipts method id  (HARD CODED FOR NOW)
    l_rctv_rec.ILE_ID		 := p_customer_id;
    l_rctv_rec.CHECK_NUMBER	 := p_payment_ref_number;
    l_rctv_rec.AMOUNT		 := p_payment_amount;
    l_rctv_rec.CURRENCY_CODE	 := p_currency_code;
    l_rctv_rec.DATE_EFFECTIVE	 := SYSDATE;
    l_rctv_rec.ORG_ID          := l_org_id;
    i := 1;

-- populate the currency conversion fields
-- get the 3 fields from okl_k_headers for a contract
--for bug #(3040085)
--jsanju 07/10
-- populate this only if receipt currency is diff from
-- functional currency.
 l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
 if l_functional_currency <> p_currency_code THEN
/*    OPEN c_get_exchange_info (p_contract_id);
    FETCH c_get_exchange_info INTO l_rctv_rec.exchange_rate_type,
              l_rctv_rec.exchange_rate,
              l_rctv_rec.exchange_rate_date ;
    CLOSE c_get_exchange_info;
 */
 -- The values should be coming in from the UI.
 -- so for the time being hard coded to 'CORPORATE'
 --07/15
    l_rctv_rec.exchange_rate_type := 'CORPORATE';
End if;

/*
    l_rctv_rec.exchange_rate_type := 'CORPORATE';
    l_rctv_rec.exchange_rate :=.53;
    l_rctv_rec.exchange_rate_date := '01-JAN-03';

   IF (l_rctv_rec.exchange_rate_type IS NULL) AND (l_rctv_rec.exchange_rate IS NULL)
       AND (l_rctv_rec.exchange_rate_date IS NULL) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_PAYMENT_METHOD_INVALID );
       RAISE okl_api.G_EXCEPTION_ERROR;
   END IF;
 */

    l_rcav_tbl(i).CNR_ID       := NULL;
    l_rcav_tbl(i).KHR_ID       := p_contract_id;
    -- l_rcav_tbl(i).LLN_ID        := l_lln_id;        -- consolidated ar lines id
    -- l_rcav_tbl(i).LSM_ID        := l_lsm_id;        -- consolidated ar streams id
    l_rcav_tbl(i).ILE_ID       := p_customer_id;
    l_rcav_tbl(i).AMOUNT       := p_payment_amount;
    l_rcav_tbl(i).LINE_NUMBER  := i;
    l_rcav_tbl(i).ORG_ID       := l_org_id;

    Okl_Rct_Pub.create_internal_trans
                     (
					  p_api_version
					  ,p_init_msg_list
					  ,x_return_status
					  ,x_msg_count
					  ,x_msg_data
					  ,l_rctv_rec
                                       	  ,l_rcav_tbl
					  ,x_rctv_rec
					  ,x_rcav_tbl
                              );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_payment_id    := x_rctv_rec.id;
    x_return_status := l_return_status;

    /*    Processing Ends       */

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
          x_return_status := okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_ERROR',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
      WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_UNEXP_ERROR',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
      WHEN OTHERS THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
  END CREATE_INTERNAL_TRANS;

  ---------------------------------------------------------------------------
  -- PROCEDURE CREATE_INTERNAL_TRANS
  ---------------------------------------------------------------------------
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_invoice_id			      IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                    CONSTANT VARCHAR2(30) := 'OKL_PAYMENT_PVT';
  l_return_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  i                             NUMBER := 1;
  l_check             NUMBER := 0;
  l_org_id            NUMBER;
  l_rctv_rec          rctv_rec_type;
  x_rctv_rec          rctv_rec_type;
  l_rcav_tbl          rcav_tbl_type;
  x_rcav_tbl          rcav_tbl_type;

  G_CUSTOMER_ID_NULL     CONSTANT VARCHAR2(200) := 'OKL_CUSTOMER_ID_NULL';
  G_INVOICE_ID_NULL     CONSTANT VARCHAR2(200) := 'OKL_INVOICE_ID_NULL';
  G_PAYMENT_METHOD_NULL  CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_METHOD_NULL';
  G_PAYMENT_METHOD_INVALID  CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_METHOD_INVALID';

  CURSOR   get_receipt_method_csr(p_payment_method_id NUMBER) IS
    SELECT  1
    FROM   ar_receipt_methods
    WHERE  receipt_method_id = p_payment_method_id;

--jsanju 07/09 as per IEX requirements ( bug #3040085)
cursor c_get_exchange_info (p_invoice_id IN NUMBER) IS
select upper(chr.currency_conversion_type),
        chr.currency_conversion_rate,
        chr.currency_conversion_date
 from okl_k_headers chr,
      okl_cnsld_ar_lines_b lln,
      okl_cnsld_ar_strms_b strm
 where strm.khr_id =chr.id
 and  lln.cnr_id  =p_invoice_id
 and  strm.lln_id =lln.id
 and rownum <2
 group by chr.currency_conversion_type,
        chr.currency_conversion_rate,
        chr.currency_conversion_date
Order by chr.currency_conversion_type;

l_functional_currency   okl_trx_contracts.currency_code%TYPE;

  BEGIN

    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PAYMENT',
                                              x_return_status);

    /*    Processing Starts     */
    -- Check if Customer ID is null
    IF p_customer_id IS NULL THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_CUSTOMER_ID_NULL );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Check if Contract ID is null
    IF p_invoice_id IS NULL THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_INVOICE_ID_NULL );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Get org Id for OKL
    l_org_id :=mo_global.get_current_org_id();

    -- get payment method
    OPEN  get_receipt_method_csr(p_payment_method_id);
    FETCH get_receipt_method_csr INTO l_check;
    CLOSE get_receipt_method_csr;

    -- Check if payment_method is null
    IF (l_check <> 1) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_PAYMENT_METHOD_INVALID );
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;


-- populate the currency conversion fields
-- get the 3 fields from okl_k_headers for a contract
--for bug #(3040085)
--jsanju 07/10
-- populate this only if receipt currency is diff from
-- functional currency.
 l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
 if l_functional_currency <> p_currency_code THEN
    OPEN c_get_exchange_info (p_invoice_id);
/*    OPEN c_get_exchange_info (p_contract_id);
    FETCH c_get_exchange_info INTO l_rctv_rec.exchange_rate_type,
              l_rctv_rec.exchange_rate,
              l_rctv_rec.exchange_rate_date ;
    CLOSE c_get_exchange_info;
 */
 -- The values should be coming in from the UI.
 -- so for the time being hard coded to 'CORPORATE'
 --07/15/03
    l_rctv_rec.exchange_rate_type := 'CORPORATE';

End if;

/*
    l_rctv_rec.exchange_rate_type := 'CORPORATE';
    l_rctv_rec.exchange_rate :=.53;
    l_rctv_rec.exchange_rate_date := '01-JAN-03';

   IF (l_rctv_rec.exchange_rate_type IS NULL) AND (l_rctv_rec.exchange_rate IS NULL)
       AND (l_rctv_rec.exchange_rate_date IS NULL) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_PAYMENT_METHOD_INVALID );
       RAISE okl_api.G_EXCEPTION_ERROR;
   END IF;
 */

    -- Create record in Internal Transaction Table.
    -- CREATE HEADER REC
    --  l_rctv_rec.IBA_ID	 := l_iba_id;        -- bank account id
    l_rctv_rec.IRM_ID		 := p_payment_method_id;      -- receipts method id  (HARD CODED FOR NOW)
    l_rctv_rec.ILE_ID		 := p_customer_id;
    l_rctv_rec.CHECK_NUMBER	 := p_payment_ref_number;
    l_rctv_rec.AMOUNT		 := p_payment_amount;
    l_rctv_rec.CURRENCY_CODE	 := p_currency_code;
    l_rctv_rec.DATE_EFFECTIVE	 := SYSDATE;
    l_rctv_rec.ORG_ID          := l_org_id;
    i := 1;

    l_rcav_tbl(i).CNR_ID       := p_invoice_id;
    l_rcav_tbl(i).KHR_ID       := NULL;
    -- l_rcav_tbl(i).LLN_ID        := l_lln_id;        -- consolidated ar lines id
    -- l_rcav_tbl(i).LSM_ID        := l_lsm_id;        -- consolidated ar streams id
    l_rcav_tbl(i).ILE_ID       := p_customer_id;
    l_rcav_tbl(i).AMOUNT       := p_payment_amount;
    l_rcav_tbl(i).LINE_NUMBER  := i;
    l_rcav_tbl(i).ORG_ID       := l_org_id;

    Okl_Rct_Pub.create_internal_trans
                              (
					  p_api_version
					  ,p_init_msg_list
					  ,x_return_status
					  ,x_msg_count
					  ,x_msg_data
					  ,l_rctv_rec
					  ,l_rcav_tbl
					  ,x_rctv_rec
					  ,x_rcav_tbl
                              );

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_payment_id    := x_rctv_rec.id;
    x_return_status := l_return_status;

    /*    Processing Ends       */

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
          x_return_status := okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_ERROR',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
      WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'okl_api.G_RET_STS_UNEXP_ERROR',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
      WHEN OTHERS THEN
          x_return_status :=okl_api.HANDLE_EXCEPTIONS
          (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PAYMENT'
          );
  END CREATE_INTERNAL_TRANS;


  ---------------------------------------------------------------------------
  -- PROCEDURE CREATE_PAYMENTS
  ---------------------------------------------------------------------------
  PROCEDURE CREATE_PAYMENTS(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level             IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_receipt_rec                  IN  receipt_rec_type,
     p_payment_tbl                  IN  payment_tbl_type,
     x_payment_ref_number           OUT NOCOPY AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE,
     x_cash_receipt_id              OUT NOCOPY NUMBER
  )

  IS

  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'OKL_PAYMENT_PVT';
  l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_init_msg_list	    VARCHAR2(1) := Okc_Api.g_false;
  l_msg_count		    NUMBER;
  l_msg_data		    VARCHAR2(2000);
  i                         NUMBER := 1;
  l_counter                 NUMBER := 0;
  l_check                   NUMBER := 0;
  l_commit                  VARCHAR2(1);
  l_validation_level        NUMBER;
  l_customer_site_use_id    NUMBER;
  l_payment_date            OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL;
  l_rct_id                  OKL_TRX_CSH_RECEIPT_V.ID%TYPE;
  l_xcr_id                  NUMBER;
  l_cash_receipt_id         NUMBER;
  l_cons_bill_id    	    OKL_CNSLD_AR_HDRS_V.ID%TYPE;
  l_cons_bill_num           OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE;
  l_currency_code   	    OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
  l_currency_conv_type	    OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE;
  l_currency_conv_date      OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE;
  l_currency_conv_rate      OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE;
  l_irm_id    	      	    OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE;
  l_payment_ref_number 	    AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE DEFAULT NULL;
  l_rcpt_amount	  	        OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE;
  l_contract_id     	    OKC_K_HEADERS_B.ID%TYPE;
  l_contract_num    	    OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_cust_acct_id     	    NUMBER;
  l_customer_num    	    HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
  l_gl_date                 OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_receipt_date            OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE;
  l_rcpt_date                    OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_receipt_rec.PAYMENT_DATE);
  l_org_id                       Number DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  l_rcpt_rec                rcpt_rec_type;
  l_appl_tbl                appl_tbl_type;
  l_customer_trx_id              NUMBER;
  l_payment_trxn_extension_id    NUMBER;
  l_remit_bank_acct_id           NUMBER;
  l_payment_channel_code     varchar2(240);

 --Getting Trx Date
/*
	 Cursor c_get_date (l_orgid Number,l_customer_trx_id Number) Is
	 Select Trx_date apply_date
	 from ra_customer_trx_all
	 where customer_trx_id=l_customer_trx_id
	 and org_id=l_orgid;
*/
  ------------------------------------------------------------------------------

  CURSOR get_rct_id ( cp_amount IN NUMBER
                     ,cp_bank_acct_id IN NUMBER
                     ,cp_cust_id IN NUMBER
                     ,cp_rcpt_date IN DATE
                     ,cp_irm_id IN NUMBER) IS

  SELECT ID INTO l_rct_id
  FROM   OKL_TRX_CSH_RECEIPT_V
  WHERE  AMOUNT = cp_amount
  AND    IBA_ID = cp_bank_acct_id
  AND    ILE_ID = cp_cust_id
  AND    DATE_EFFECTIVE = cp_rcpt_date
  AND    IRM_ID = cp_irm_id
  ORDER BY CREATION_DATE DESC;

  CURSOR c_get_invoice_org_id(ar_inv_id IN NUMBER) IS
  SELECT ORG_ID
  FROM   RA_CUSTOMER_TRX_ALL
  WHERE  CUSTOMER_TRX_ID = ar_inv_id;

  CURSOR c_get_cons_inv_org_id(cons_inv_id IN NUMBER) IS
  SELECT ORG_ID
  FROM   OKL_CNSLD_AR_HDRS_ALL_B
  WHERE  ID = cons_inv_id;

  CURSOR c_get_receipt_method_id(p_org_id IN NUMBER, cp_payment_channel_code IN VARCHAR2) IS
  SELECT receipt_method_id
  FROM   okl_pmt_channel_methods_All
  WHERE  ORG_ID = p_org_id
  AND    payment_channel_code = cp_payment_channel_code;

  CURSOR c_get_remittance_details(cp_org_id IN NUMBER, cp_irm_id IN NUMBER) IS
  SELECT bank_account_id
  FROM   okl_bpd_rcpt_mthds_uv
  WHERE  ORG_ID = cp_org_id
  AND    RECEIPT_METHOD_ID = cp_irm_id;

  CURSOR c_get_payment_channel(cp_trx_extn_id IN NUMBER) IS
  SELECT PAYMENT_CHANNEL_CODE
  FROM IBY_FNDCPT_TX_EXTENSIONS
  WHERE TRXN_EXTENSION_ID = cp_trx_extn_id;
  ------------------------------------------------------------------------------

  /*
  CURSOR get_icr_id (cp_rct_id IN NUMBER) IS

  SELECT ID, ICR_ID
  FROM   OKL_EXT_CSH_RCPTS_V
  WHERE  RCT_ID = cp_rct_id;
  */
  ------------------------------------------------------------------------------


  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PAYMENT_PVT.CREATE_PAYMENTS','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_receipt_rec.p_currency_code :'||p_receipt_rec.currency_code);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_currency_conv_type :'||p_receipt_rec.currency_conv_type);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_currency_conv_date :'||p_receipt_rec.currency_conv_date);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_currency_conv_rate :'||p_receipt_rec.currency_conv_rate);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_irm_id :'||p_receipt_rec.irm_id);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_contract_id :'||p_receipt_rec.contract_id);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_contract_num :'||p_receipt_rec.contract_num);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_customer_id :'||p_receipt_rec.cust_acct_id);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_customer_num :'||p_receipt_rec.customer_num);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_gl_date :'||p_receipt_rec.gl_date);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_payment_date :'||p_receipt_rec.payment_date);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_customer_site_use_id :'||p_receipt_rec.customer_site_use_id);

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_PAYMENT_PVT.CREATE_PAYMENTS.',
              'p_expiration_date :'||p_receipt_rec.expiration_date);

     END IF;

    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    l_currency_code   		:= p_receipt_rec.currency_code;
    l_currency_conv_type	:= p_receipt_rec.currency_conv_type;
    l_currency_conv_date        := p_receipt_rec.currency_conv_date;
    l_currency_conv_rate        := p_receipt_rec.currency_conv_rate;
    l_payment_ref_number        := NULL;
    l_cust_acct_id     		:= p_receipt_rec.cust_acct_id;
    l_customer_num    		:= p_receipt_rec.customer_num;
    l_gl_date                   := p_receipt_rec.gl_date;
    l_receipt_date              := p_receipt_rec.payment_date;
    l_customer_site_use_id      := p_receipt_rec.customer_site_use_id;
    l_commit                    := p_commit;
    l_payment_trxn_extension_id := p_receipt_rec.payment_trxn_extension_id;
    l_irm_id			:=p_receipt_rec.irm_id;
    l_remit_bank_acct_id        :=p_receipt_rec.rem_bank_acc_id;

-- Setting SYSDATE as receipt date if it is null
  If l_rcpt_date Is Null Then
     l_rcpt_date := TRUNC(SYSDATE);
  End If;

  i := p_payment_tbl.FIRST;

  --Populate receipt header record
  l_rcpt_rec.cash_receipt_id := NULL;
  l_rcpt_rec.amount := l_rcpt_amount;
  l_rcpt_rec.currency_code := l_currency_code;
  l_rcpt_rec.customer_number := l_customer_num;
  l_rcpt_rec.customer_id := l_cust_acct_id;
  l_rcpt_rec.receipt_date := l_receipt_date;
  l_rcpt_rec.gl_date := l_receipt_date;
  l_rcpt_rec.payment_trx_extension_id := l_payment_trxn_extension_id;
  l_rcpt_rec.exchange_rate_type := l_currency_conv_type;
  l_rcpt_rec.exchange_rate := l_currency_conv_rate;
  l_rcpt_rec.exchange_date := l_currency_conv_date;
  l_rcpt_rec.receipt_method_id := l_irm_id;
  l_rcpt_rec.create_mode := 'UNAPPLIED';
  l_rcpt_rec.receipt_method_id :=l_irm_id;
  l_rcpt_rec.remittance_bank_account_id :=l_remit_bank_acct_id;


  l_counter := 0;
  --If payment table is not empty
  IF (p_payment_tbl.COUNT > 0) THEN
    --Get the org id from either consolidated invoice or AR invoice
    IF (p_payment_tbl(i).con_inv_id IS NOT NULL) THEN
      OPEN c_get_cons_inv_org_id(p_payment_tbl(i).con_inv_id);
      FETCH c_get_cons_inv_org_id INTO l_org_id;
      CLOSE c_get_cons_inv_org_id;
    ELSIF (p_payment_tbl(i).ar_inv_id IS NOT NULL) THEN
      OPEN c_get_invoice_org_id(p_payment_tbl(i).ar_inv_id);
      FETCH c_get_invoice_org_id INTO l_org_id;
      CLOSE c_get_invoice_org_id;
    END IF;

    IF l_org_id IS NOT NULL THEN
      l_rcpt_rec.org_id := l_org_id;
      mo_global.init('M');
      MO_GLOBAL.set_policy_context('S',l_org_id);
    END IF;


        OPEN c_get_payment_channel(l_payment_trxn_extension_id);
	FETCH c_get_payment_channel INTO l_payment_channel_code;
	CLOSE c_get_payment_channel;
	If l_irm_id Is Null Then
	        --Get receipt method id
		OPEN c_get_receipt_method_id(l_org_id,l_payment_channel_code);
		FETCH c_get_receipt_method_id INTO l_irm_id;
		CLOSE c_get_receipt_method_id;
		l_rcpt_rec.receipt_method_id := l_irm_id;
	End If;

	If ((l_remit_bank_acct_id Is Null) And  (l_irm_id Is Not Null)) Then
		--Get remittance bank details
		OPEN c_get_remittance_details(l_org_id, l_irm_id);
		FETCH c_get_remittance_details INTO l_remit_bank_acct_id;
		CLOSE c_get_remittance_details;
		l_rcpt_rec.remittance_bank_account_id := l_remit_bank_acct_id;
	End If;

	IF l_irm_id IS NULL THEN
	      OKC_API.set_message( p_app_name    => G_APP_NAME,
		                  p_msg_name    =>'OKL_BPD_RCPT_MTHD_NULL');
	      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

    --If it needs to be applied for AR Invoice header then handle it
    IF (p_payment_tbl.COUNT = 1 AND p_payment_tbl(i).line_id IS NULL) THEN
      --Apply against consolidated invoice
	  IF p_payment_tbl(i).CON_INV_ID IS NOT NULL THEN
	    l_appl_tbl(0).con_inv_id := p_payment_tbl(i).con_inv_id;
	    l_appl_tbl(0).amount_to_apply := p_payment_tbl(i).amount;
	  --Apply against AR Invoice
	  ELSIF p_payment_tbl(i).AR_INV_ID IS NOT NULL THEN
	    l_appl_tbl(0).ar_inv_id := p_payment_tbl(i).ar_inv_id;
	    l_appl_tbl(0).amount_to_apply := p_payment_tbl(i).amount;
	  END IF;
	  l_rcpt_amount := p_payment_tbl(i).amount;
    --Else it needs to be applied for selected invoice lines
    ELSE
      l_rcpt_amount := 0;
      FOR i IN p_payment_tbl.FIRST..p_payment_tbl.LAST
      LOOP
        l_appl_tbl(l_counter).ar_inv_id := p_payment_tbl(i).ar_inv_id;
        l_appl_tbl(l_counter).line_id := p_payment_tbl(i).line_id;
        l_appl_tbl(l_counter).amount_to_apply := p_payment_tbl(i).amount;
        l_appl_tbl(l_counter).original_applied_amount := 0;
        l_rcpt_amount := l_rcpt_amount + p_payment_tbl(i).amount;
        l_counter := l_counter + 1;
      END LOOP;
	END IF;
  END IF;
  l_rcpt_rec.amount := l_rcpt_amount;
 l_rcpt_rec.customer_bank_account_id := NULL;
  OKL_RECEIPTS_PVT.handle_receipt( p_api_version      => l_api_version
  				                  ,p_init_msg_list    => l_init_msg_list
				                  ,x_return_status    => l_return_status
				                  ,x_msg_count	      => l_msg_count
				                  ,x_msg_data	      => l_msg_data
				                  ,p_rcpt_rec         => l_rcpt_rec
								  ,p_appl_tbl         => l_appl_tbl
								  ,x_cash_receipt_id  => l_cash_receipt_id);

  --Set back policy context to M
  LOOP
    l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
    IF l_msg_data is NULL Then
      EXIT;
    END if;
  END loop;
  MO_GLOBAL.set_policy_context('M',-1);
  x_return_status := l_return_status;

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF l_cash_receipt_id IS NOT NULL THEN
    l_payment_ref_number := OKL_PAYMENT_PUB.get_ar_receipt_number(l_cash_receipt_id);
  END IF;

  x_msg_data      := l_msg_data;
  x_msg_count     := l_msg_count;
  x_payment_ref_number := l_payment_ref_number;
  x_cash_receipt_id  := l_cash_receipt_id;
  okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_PAYMENT_PVT.CREATE_PAYMENTS','end(-)');
  END IF;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PAYMENT.CREATE_PAYMENTS ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
       END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PAYMENT.CREATE_PAYMENTS ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
       END IF;

        x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

    WHEN OTHERS THEN

       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_PAYMENT.CREATE_PAYMENTS ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

  END CREATE_PAYMENTS;
END OKL_PAYMENT_PVT;

/

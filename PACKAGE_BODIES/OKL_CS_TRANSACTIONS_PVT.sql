--------------------------------------------------------
--  DDL for Package Body OKL_CS_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_TRANSACTIONS_PVT" AS
/* $Header: OKLRBFNB.pls 120.9 2008/02/22 12:04:13 dkagrawa noship $ */

  ------------------------------------------------------------------------------
  -- PROCEDURE get_totals
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    -- Purpose:
    --  Return Trasaction, Receipt, and Disbursement Totals
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------
  PROCEDURE get_totals (p_select          IN           VARCHAR2,
                        p_from            IN           VARCHAR2,
                        p_where           IN           VARCHAR2,
                        x_inv_total       OUT NOCOPY   NUMBER,
                        x_rec_total       OUT NOCOPY   NUMBER,
                        x_due_total       OUT NOCOPY   NUMBER,
			x_credit_total    OUT NOCOPY   NUMBER,
			x_adjust_total    OUT NOCOPY   NUMBER,
                        x_row_count       OUT NOCOPY   NUMBER,
                        x_return_status   OUT NOCOPY   VARCHAR2,
                        x_msg_count       OUT NOCOPY   NUMBER,
                        x_msg_data        OUT NOCOPY   VARCHAR2) IS

      l_sql           VARCHAR2(1000);
      l_cursor        INTEGER;
      l_rows          NUMBER;

  BEGIN

      IF p_where IS NOT NULL THEN
        l_sql := ' SELECT '||p_select||' FROM '||p_from||' WHERE '||p_where;
      ELSE
        l_sql := ' SELECT '||p_select||' FROM '||p_from;
      END IF;

      l_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_cursor, l_sql , DBMS_SQL.V7);

      DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, x_inv_total);
      DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, x_rec_total);
      DBMS_SQL.DEFINE_COLUMN(l_cursor, 3, x_due_total);
      IF p_from  IN ('OKL_CS_BILLINGTRX_UV','OKL_CS_ACCOUNT_CONT_INV_UV','OKL_CS_ACCOUNT_INV_UV') THEN
         DBMS_SQL.DEFINE_COLUMN(l_cursor, 4, x_credit_total);
         DBMS_SQL.DEFINE_COLUMN(l_cursor, 5, x_adjust_total);
      END IF;

      l_rows := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor);

      IF l_rows = 1 THEN

        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, x_inv_total);
        DBMS_SQL.COLUMN_VALUE(l_cursor, 2, x_rec_total);
        DBMS_SQL.COLUMN_VALUE(l_cursor, 3, x_due_total);
	IF p_from  IN ('OKL_CS_BILLINGTRX_UV','OKL_CS_ACCOUNT_CONT_INV_UV','OKL_CS_ACCOUNT_INV_UV')  THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 4, x_credit_total);
            DBMS_SQL.COLUMN_VALUE(l_cursor, 5, x_adjust_total);
	END IF;

        x_return_status := OKL_API.G_RET_STS_SUCCESS;

      ELSIF l_rows = 0 THEN

        x_return_status := OKL_API.G_RET_STS_ERROR;

      END IF;

    x_row_count := l_rows;
    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      DBMS_SQL.CLOSE_CURSOR(l_cursor);

  END get_totals;


  ------------------------------------------------------------------------------
  -- PROCEDURE get_svf_info
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Check whether Rule exists for the Service Fee Code first
    --  If Rule exists
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  PROCEDURE get_svf_info (p_khr_id         IN  NUMBER,
                          p_svf_code       IN  VARCHAR2,
                          x_svf_info_rec   OUT NOCOPY svf_info_rec,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2) IS

    CURSOR c_svf_applicable IS
                     SELECT rul.rule_information1 svf_applicability
                     FROM   okc_rules_b rul
                     WHERE  rul.dnz_chr_id = p_khr_id
                       AND  rul.rule_information_category = p_svf_code;

    CURSOR c_svf_info IS
                     SELECT svf.id svf_id,
                            fnd.meaning svf_name,
                            svf.amount svf_amount,
                            fnd.description svf_desc
                     FROM   fnd_lookups fnd,
                            okl_service_fees_b svf
                     WHERE  svf.srv_code = p_svf_code
                       AND  NVL(svf.organization_id, -99) = NVL(mo_global.get_current_org_id(), -99)
                       AND  svf.srv_code = fnd.lookup_code
                       AND  lookup_type = 'OKL_SERVICE_FEES';

    i BINARY_INTEGER := 0;
    l_svf_applicable VARCHAR2(1) := '?';


  BEGIN

    OPEN c_svf_applicable;
    FETCH c_svf_applicable INTO l_svf_applicable;
    CLOSE c_svf_applicable;

    IF (l_svf_applicable = '?') OR (l_svf_applicable = 'N') THEN
      RETURN;
    ELSIF (l_svf_applicable = 'Y') THEN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;

    OPEN c_svf_info;
    FETCH c_svf_info INTO x_svf_info_rec;
    CLOSE c_svf_info;
    IF x_svf_info_rec.SVF_ID IS NOT NULL THEN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_svf_info;


  ------------------------------------------------------------------------------
  -- PROCEDURE get_credit_memo_info
  ------------------------------------------------------------------------------
    -- Created by  : SMODUGA
      --
      --  Purpose:
      --  Get Credit Memo Data for Interaction
      --  If credit memo exists
      -- Known limitations/enhancements and/or remarks:
      --
  ------------------------------------------------------------------------------

    PROCEDURE get_credit_memo_info (p_khr_id         IN  NUMBER,
                            p_tai_id         IN  NUMBER,
                            x_trx_type       OUT NOCOPY VARCHAR2,
                            x_inv_num        OUT NOCOPY NUMBER,
                            x_trx_date       OUT NOCOPY DATE,
                            x_trx_amount     OUT NOCOPY NUMBER,
                            x_amnt_app       OUT NOCOPY NUMBER,
                            x_amnt_due       OUT NOCOPY NUMBER,
                            x_crd_amnt       OUT NOCOPY NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2) IS

      CURSOR c_credit_memo_tld IS
                        select STYT.NAME,CNR.CONSOLIDATED_INVOICE_NUMBER
                              ,APS.TRX_DATE,APS.AMOUNT_DUE_ORIGINAL,
                              APS.AMOUNT_APPLIED,APS.AMOUNT_DUE_REMAINING
                              ,TIL.Amount
                       from OKL_TRX_AR_INVOICES_B TAI
                            ,OKL_TXL_AR_INV_LNS_B TIL
                            ,OKL_TXD_AR_LN_DTLS_B TLD2
                            ,OKL_TXD_AR_LN_DTLS_B TLD
                            ,OKL_STRM_TYPE_TL  STYT
                            ,OKL_XTL_SELL_INVS_V XLS
                            ,OKC_K_HEADERS_V CHR
                            ,OKL_CNSLD_AR_STRMS_B LSM
                            ,OKL_CNSLD_AR_LINES_B LLN
                            ,AR_PAYMENT_SCHEDULES_ALL APS
                            ,OKL_CNSLD_AR_HDRS_B CNR
                      where TAI.ID = p_tai_id
                            AND CHR.ID = p_khr_id
                            AND   TIL.TAI_ID =TAI.ID
                            AND TIL.ID = TLD2.TIL_ID_DETAILS
                            AND TLD2.TLD_ID_REVERSES =TLD.ID
                            AND TLD.STY_ID = STYT.ID
                            AND STYT.LANGUAGE = USERENV('LANG')
                            AND XLS.TLD_ID = TLD.ID
                            AND XLS.LSM_ID = LSM.ID
                            AND LSM.RECEIVABLES_INVOICE_ID = APS.CUSTOMER_TRX_ID
                            AND LSM.LLN_ID = LLN.ID
                            AND LLN.CNR_ID = CNR.ID
                     UNION
                       select STYT.NAME,CNR.CONSOLIDATED_INVOICE_NUMBER
                              ,APS.TRX_DATE,APS.AMOUNT_DUE_ORIGINAL,
                              APS.AMOUNT_APPLIED,APS.AMOUNT_DUE_REMAINING
                              ,TIL.Amount
                       from OKL_TRX_AR_INVOICES_B TAI
                            ,OKL_TXL_AR_INV_LNS_B TIL2
                            ,OKL_TXL_AR_INV_LNS_B TIL
                            ,OKL_STRM_TYPE_TL  STYT
                            ,OKL_XTL_SELL_INVS_V XLS
                            ,OKC_K_HEADERS_V CHR
                            ,OKL_CNSLD_AR_STRMS_B LSM
                            ,OKL_CNSLD_AR_LINES_B LLN
                            ,AR_PAYMENT_SCHEDULES_ALL APS
                            ,OKL_CNSLD_AR_HDRS_B CNR
                      where TAI.ID = p_tai_id
                            AND CHR.ID = p_khr_id
                            AND  TIL.TAI_ID =TAI.ID
                            AND TIL2.TIL_ID_REVERSES = TIL.ID
                            AND TIL.STY_ID = STYT.ID
                            AND  STYT.LANGUAGE = USERENV('LANG')
                            AND XLS.TIL_ID = TIL.ID
                            AND XLS.LSM_ID = LSM.ID
                            AND LSM.RECEIVABLES_INVOICE_ID = APS.CUSTOMER_TRX_ID
                            AND LSM.LLN_ID = LLN.ID
                            AND LLN.CNR_ID = CNR.ID
                     UNION --Added following union for new invoices --dkagrawa
		       SELECT DISTINCT STYT.NAME
                              ,RACTRX.TRX_NUMBER CONSOLIDATED_INVOICE_NUMBER
                              ,APS.TRX_DATE
                              ,RACTRL.AMOUNT_DUE_ORIGINAL
                              ,OKL_BILLING_UTIL_PVT.INVOICE_LINE_AMOUNT_APPLIED(RACTRX.customer_trx_id, RACTRL.customer_trx_line_id) AMOUNT_APPLIED
                              ,RACTRL.AMOUNT_DUE_REMAINING
                              ,TIL.Amount
                       from OKL_TRX_AR_INVOICES_B TAI
                            ,OKL_TXL_AR_INV_LNS_B TIL
                            ,OKL_TXD_AR_LN_DTLS_B TLD2
                            ,OKL_TXD_AR_LN_DTLS_B TLD
                            ,OKL_STRM_TYPE_TL  STYT
                            ,OKC_K_HEADERS_V CHR
                            ,AR_PAYMENT_SCHEDULES_ALL APS
                            ,RA_CUSTOMER_TRX_ALL RACTRX
                            ,RA_CUSTOMER_TRX_LINES_ALL RACTRL
                      where TAI.ID = p_tai_id
         		    AND CHR.ID = p_khr_id
                            AND TIL.TAI_ID =TAI.ID
                            AND TIL.ID = TLD2.TIL_ID_DETAILS
                            AND TLD2.TLD_ID_REVERSES =TLD.ID
		            AND TLD.khr_id = CHR.ID
                            AND TLD.STY_ID = STYT.ID
                            AND STYT.LANGUAGE = USERENV('LANG')
                            AND TLD.ID = RACTRL.INTERFACE_LINE_ATTRIBUTE14
                            AND APS.CUSTOMER_TRX_ID = RACTRL.CUSTOMER_TRX_ID
                            AND RACTRL.CUSTOMER_TRX_ID = RACTRX.CUSTOMER_TRX_ID
			    AND RACTRL.INTERFACE_LINE_ATTRIBUTE1 IS NULL;

		       /*select STYT.NAME,CNR.CONSOLIDATED_INVOICE_NUMBER
                              ,APS.TRX_DATE,APS.AMOUNT_DUE_ORIGINAL,
                              APS.AMOUNT_APPLIED,APS.AMOUNT_DUE_REMAINING
                              ,TIL.Amount
                       from OKL_TRX_AR_INVOICES_B TAI
                            ,OKL_TXL_AR_INV_LNS_B TIL
                            ,OKL_TXD_AR_LN_DTLS_B TLD
                            ,OKL_STRM_TYPE_TL  STYT
                            ,OKL_XTL_SELL_INVS_V XLS
                            ,OKC_K_HEADERS_V CHR
                            ,OKL_CNSLD_AR_STRMS_B LSM
                            ,OKL_CNSLD_AR_LINES_B LLN
                            ,AR_PAYMENT_SCHEDULES_ALL APS
                            ,OKL_CNSLD_AR_HDRS_B CNR
                            ,OKC_K_LINES_B CLE
                            ,OKC_LINE_STYLES_B LSE
                            ,OKC_K_ITEMS CIM
                            ,FA_ADDITIONS_B FAA
                      where TAI.ID = p_lsm_id
                            AND CHR.ID = p_khr_id
                            AND   TIL.TAI_ID =TAI.ID
                            AND   TIL.TIL_ID_REVERSES = TLD.TIL_ID_DETAILS
                            AND   TLD.STY_ID = STYT.ID
                            AND   STYT.LANGUAGE = USERENV('LANG')
                            AND XLS.TLD_ID = TLD.ID
                            AND XLS.XTRX_CONTRACT = CHR.CONTRACT_NUMBER
                            AND XLS.LSM_ID = LSM.ID
                            AND LSM.RECEIVABLES_INVOICE_ID = APS.CUSTOMER_TRX_ID
                            AND LSM.LLN_ID = LLN.ID
                            AND LLN.CNR_ID = CNR.ID
                            AND LSM.KHR_ID = CHR.ID
                            AND LSM.KLE_ID = CLE.CLE_ID
                            AND CLE.LSE_ID = LSE.ID
                            AND LSE.LTY_CODE = 'FIXED_ASSET'
                            AND CLE.ID = CIM.CLE_ID
                            AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
                            AND CIM.OBJECT1_ID1 = FAA.ASSET_ID;


       CURSOR c_credit_memo_til IS
                       select STYT.NAME,CNR.CONSOLIDATED_INVOICE_NUMBER
                              ,APS.TRX_DATE,APS.AMOUNT_DUE_ORIGINAL,
                              APS.AMOUNT_APPLIED,APS.AMOUNT_DUE_REMAINING
                              ,TIL.Amount
                       from OKL_TRX_AR_INVOICES_B TAI
                            ,OKL_TXL_AR_INV_LNS_B TIL
                            ,OKL_TXD_AR_LN_DTLS_B TLD
                            ,OKL_STRM_TYPE_TL  STYT
                            ,OKL_XTL_SELL_INVS_V XLS
                            ,OKC_K_HEADERS_V CHR
                            ,OKL_CNSLD_AR_STRMS_B LSM
                            ,OKL_CNSLD_AR_LINES_B LLN
                            ,AR_PAYMENT_SCHEDULES_ALL APS
                            ,OKL_CNSLD_AR_HDRS_B CNR
                            ,OKC_K_LINES_B CLE
                            ,OKC_LINE_STYLES_B LSE
                            ,OKC_K_ITEMS CIM
                            ,FA_ADDITIONS_B FAA
                      where TAI.ID = p_lsm_id
                            AND CHR.ID = p_khr_id
                            AND   TIL.TAI_ID =TAI.ID
                            AND   TIL.TIL_ID_REVERSES = TLD.TIL_ID_DETAILS
                            AND   TLD.STY_ID = STYT.ID
                            AND   STYT.LANGUAGE = USERENV('LANG')
                            AND XLS.TIL_ID = TIL.ID
                            AND XLS.XTRX_CONTRACT = CHR.CONTRACT_NUMBER
                            AND XLS.LSM_ID = LSM.ID
                            AND LSM.RECEIVABLES_INVOICE_ID = APS.CUSTOMER_TRX_ID
                            AND LSM.LLN_ID = LLN.ID
                            AND LLN.CNR_ID = CNR.ID
                            AND LSM.KHR_ID = CHR.ID
                            AND LSM.KLE_ID = CLE.CLE_ID
                            AND CLE.LSE_ID = LSE.ID
                            AND LSE.LTY_CODE = 'FIXED_ASSET'
                            AND CLE.ID = CIM.CLE_ID
                            AND CIM.JTOT_OBJECT1_CODE = 'OKX_ASSET'
                            AND CIM.OBJECT1_ID1 = FAA.ASSET_ID;*/



      i BINARY_INTEGER := 0;
      l_credit_memo VARCHAR2(1) := '?';
      l_row_notfound                 BOOLEAN := TRUE;
      l_no_data_found                 BOOLEAN := TRUE;

    BEGIN


      OPEN c_credit_memo_tld;
      FETCH c_credit_memo_tld INTO x_trx_type,x_inv_num,x_trx_date,x_trx_amount,x_amnt_app,x_amnt_due,x_crd_amnt;
      l_row_notfound := c_credit_memo_tld%NOTFOUND;
      CLOSE c_credit_memo_tld;

      /*IF(l_row_notfound) THEN
      OPEN c_credit_memo_til;
      FETCH c_credit_memo_til INTO x_trx_type,x_inv_num,x_trx_date,x_trx_amount,x_amnt_app,x_amnt_due,x_crd_amnt;
      l_no_data_found := c_credit_memo_til%NOTFOUND;
      CLOSE c_credit_memo_til;*/
        IF(l_row_notfound) THEN
         RETURN;
        END IF;
      --END IF;



      x_return_status := OKL_API.G_RET_STS_SUCCESS;

    EXCEPTION

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UNEXPECTED_ERROR,
                             p_token1       => G_SQLCODE_TOKEN,
                             p_token1_value => SQLCODE,
                             p_token2       => G_SQLERRM_TOKEN,
                             p_token2_value => SQLERRM);

        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    END get_credit_memo_info;


  ------------------------------------------------------------------------------
  -- PROCEDURE check_process_template
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Check for existance of at least one valid Process Template record
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  PROCEDURE check_process_template (p_ptm_code       IN VARCHAR2,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2) IS

    CURSOR c_ptm IS SELECT 1
                    FROM   okl_process_tmplts_b
                    WHERE  NVL(org_id, -99) = NVL(mo_global.get_current_org_id(), -99)
                      AND  ptm_code = p_ptm_code
                      AND  start_date  <= TRUNC(SYSDATE)
                      AND  NVL(end_date, TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

    l_dummy VARCHAR2(1);

  BEGIN

      OPEN c_ptm;
      FETCH c_ptm INTO l_dummy;
      IF c_ptm%FOUND THEN
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      ELSE
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      CLOSE c_ptm;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_process_template;


  ------------------------------------------------------------------------------
  -- PROCEDURE get_pvt_label_email
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Retrieve Email Address of the Lessors Private Label
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  PROCEDURE get_pvt_label_email (p_khr_id         IN         NUMBER,
                                 x_email          OUT NOCOPY VARCHAR2,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2) IS

    CURSOR c_email IS SELECT email_address
                      FROM   hz_parties hzp, okc_k_party_roles_b cpl
                      WHERE  cpl.dnz_chr_id = p_khr_id
                        AND  cpl.jtot_object1_code = 'OKX_PARTY'
                        AND  cpl.rle_code = 'PRIVATE_LABEL'
                        AND  cpl.object1_id1 = hzp.party_id;

  BEGIN

    OPEN c_email;
    FETCH c_email INTO x_email;
    IF c_email%NOTFOUND THEN
      x_email := -1;
    END IF;
    CLOSE c_email;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_pvt_label_email;


  ------------------------------------------------------------------------------
  -- FUNCTION get_try_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve ID of a given Transaction Type
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_try_id (p_try_name IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_try IS
      SELECT  id
      FROM    okl_trx_types_tl
      WHERE   name = p_try_name
        AND   language = 'US';

    l_try_id      NUMBER;

  BEGIN

    OPEN c_try;
    FETCH c_try INTO l_try_id;
    CLOSE c_try;

    RETURN  l_try_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_try_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_sty_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve ID of a given Stream Type
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_sty_id (p_sty_purpose IN VARCHAR2, p_khr_id in NUMBER) RETURN NUMBER IS

    /*CURSOR c_sty IS
      SELECT  sty.id
      FROM    okl_strm_type_tl styt, okl_strm_type_b sty
      WHERE   styt.name = p_sty_name
        AND   styt.language = 'US'
        AND   sty.id = styt.id
        AND   sty.start_date <= TRUNC(SYSDATE)
        AND   NVL(sty.end_date, SYSDATE) >= TRUNC(SYSDATE);*/

    l_sty_id      NUMBER;
    l_return_status varchar2(10);

  BEGIN

    /*OPEN c_sty;
    FETCH c_sty INTO l_sty_id;
    CLOSE c_sty;*/

    -- Stream id got from Streams util API passing the purpose and contract id
    -- changes done for user defined streams, bug 3924303
    OKL_STREAMS_UTIL.get_primary_stream_type(p_khr_id,
                                            p_sty_purpose,
                                            l_return_status,
                                            l_sty_id);

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_NO_STREAM_TYPE',
                             p_token1       => OKL_API.G_COL_NAME_TOKEN,
                             p_token1_value => p_sty_purpose);

                   RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    RETURN  l_sty_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_sty_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_svf_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve ID of a given Service Fee Code
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_svf_id (p_svf_code IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_svf IS
      SELECT  id
      FROM    okl_service_fees_b
      WHERE   srv_code = p_svf_code
        AND   start_date <= TRUNC(SYSDATE)
        AND   NVL(end_date, SYSDATE) >= TRUNC(SYSDATE);

    l_svf_id      NUMBER;

  BEGIN

    OPEN c_svf;
    FETCH c_svf INTO l_svf_id;
    CLOSE c_svf;

    RETURN  l_svf_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_svf_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_pdt_id
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Private Procedure to retrieve Product ID of a given Contract
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_pdt_id (p_khr_id IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_pdt IS
      SELECT  pdt_id
      FROM    okl_k_headers
      WHERE   id = p_khr_id;

    l_pdt_id      NUMBER;

  BEGIN

    OPEN c_pdt;
    FETCH c_pdt INTO l_pdt_id;
    CLOSE c_pdt;

    RETURN  l_pdt_id;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_pdt_id;


  ------------------------------------------------------------------------------
  -- FUNCTION get_factor_synd
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Returns NULL if Contract is neither syndicated nor factored.  Ortherwise returns
    --  the appropriate value.
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_factor_synd(p_khr_id IN NUMBER) RETURN VARCHAR2 IS

    CURSOR c_synd IS
       SELECT scs_code
       FROM   okc_k_headers_b
       WHERE  scs_code = 'SYNDICATION'
         AND  id = p_khr_id;

    CURSOR c_fact IS
       SELECT 1
       FROM   okc_rules_b
       WHERE  dnz_chr_id = p_khr_id
         AND  rule_information_category = 'LAFCTG';

    l_contract_type   VARCHAR2(30);

  BEGIN

    OPEN c_synd;
    FETCH c_synd INTO l_contract_type;
    CLOSE c_synd;

    IF l_contract_type IS NOT NULL THEN
      RETURN  l_contract_type;
    END IF;

    OPEN c_fact;
    FETCH c_fact INTO l_contract_type;
    CLOSE c_fact;

    IF l_contract_type IS NOT NULL THEN
      l_contract_type := 'FACTORING';
      RETURN  l_contract_type;
    END IF;

    RETURN NULL;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_factor_synd;


  ------------------------------------------------------------------------------
  -- PROCEDURE create_svf_invoice
  ------------------------------------------------------------------------------
    -- Created by  : RFEDANE
    --
    --  Purpose:
    --  Create an Invoice Entry in the Internal OKL Invoice tables
    --
    -- Known limitations/enhancements and/or remarks:
    -- Changes
    -- 29-Oct-2004 kpvs  Bug 3924303, User defined streams changes
    --                    stream type purpose is passed into the parameter
    --                    p_sty_name instead of stream type name
  ------------------------------------------------------------------------------

  PROCEDURE create_svf_invoice (p_khr_id            IN NUMBER,
                                p_sty_name          IN VARCHAR2,
                                p_svf_code          IN VARCHAR2,
                                p_svf_amount        IN NUMBER,
                                p_svf_desc          IN VARCHAR2,
                                p_syndication_code  IN VARCHAR2,
                                p_factoring_code    IN VARCHAR2,
                                x_tai_id            OUT NOCOPY NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2) IS

    l_sysdate           DATE;
    l_khr_id            NUMBER;
    l_sty_name          VARCHAR2(150);
    l_sty_purpose       VARCHAR2(150);
    l_svf_code          VARCHAR2(30);
    l_svf_amount        NUMBER;
    l_svf_desc          VARCHAR2(4000);

    l_try_id            NUMBER;
    l_sty_id            NUMBER;
    l_svf_id            NUMBER;
    l_pdt_id            NUMBER;
    l_factoring_synd    VARCHAR2(30);
    l_syndication_code  VARCHAR2(30);
    l_factoring_code    VARCHAR2(30);

    l_api_version       CONSTANT NUMBER    :=    1;
    l_init_msg_list     CONSTANT CHAR      :=    'F';
    l_return_status     VARCHAR2(1)        :=    OKL_API.G_RET_STS_SUCCESS;
    l_line_number       CONSTANT NUMBER    :=    1;

    -- Invoice Header
    i_taiv_rec          okl_trx_ar_invoices_pub.taiv_rec_type;
    r_taiv_rec          okl_trx_ar_invoices_pub.taiv_rec_type;

    -- Invoice Line
    i_tilv_rec          okl_txl_ar_inv_lns_pub.tilv_rec_type;
    r_tilv_rec          okl_txl_ar_inv_lns_pub.tilv_rec_type;

    -- Accouting Engine (AE) Records
    l_tmpl_identify_rec             OKL_ACCOUNT_DIST_PUB.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec                 OKL_ACCOUNT_DIST_PUB.DIST_INFO_REC_TYPE;
    l_ctxt_val_tbl                  OKL_ACCOUNT_DIST_PUB.CTXT_VAL_TBL_TYPE;
    l_acc_gen_primary_key_tbl       OKL_ACCOUNT_DIST_PUB.ACC_GEN_PRIMARY_KEY;
    lx_template_tbl                 OKL_ACCOUNT_DIST_PUB.AVLV_TBL_TYPE;
    lx_amount_tbl                   OKL_ACCOUNT_DIST_PUB.AMOUNT_TBL_TYPE;

	--Added for bug 4122293
    l_bpd_acc_rec 		    Okl_Acc_Call_Pub.bpd_acc_rec_type;

  BEGIN

    l_syndication_code   := p_syndication_code;
    l_factoring_code     := p_factoring_code;

    IF (l_syndication_code IS NOT NULL) AND (l_factoring_code IS NOT NULL) THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_SYND_FACTOR_EXCLUSIVE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_sysdate         :=        TRUNC(SYSDATE);
    l_khr_id          :=        p_khr_id;
    l_sty_purpose     :=        p_sty_name;
    l_svf_code        :=        p_svf_code;
    l_svf_amount      :=        p_svf_amount;
    l_svf_desc        :=        p_svf_desc;

    l_try_id          := get_try_id ('Billing');
    l_sty_id          := get_sty_id (l_sty_purpose,l_khr_id);
    l_svf_id          := get_svf_id (l_svf_code);
    l_pdt_id          := get_pdt_id (l_khr_id);

    IF l_pdt_id IS NULL THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_NO_PRODUCT_FOUND');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --l_factoring_synd     := get_factor_synd(l_khr_id);
      l_factoring_synd     := NULL;  -- BUG 2451833
    ----------------------------------------------------------------------------------
    -- Preparing Invoice Header.  Assumption: Charge will be to Primary Leasee
    ----------------------------------------------------------------------------------
    i_taiv_rec.try_id            := l_try_id;
    i_taiv_rec.khr_id            := l_khr_id;
    i_taiv_rec.date_entered      := l_sysdate;
    i_taiv_rec.date_invoiced     := l_sysdate;
    i_taiv_rec.description       := l_svf_desc;
    i_taiv_rec.amount            := l_svf_amount;
    i_taiv_rec.trx_status_code   := 'SUBMITTED';
    i_taiv_rec.svf_id            := l_svf_id;
    i_taiv_rec.legal_entity_id   := okl_legal_entity_util.get_khr_le_id(l_khr_id);  --dkagrawa populated le_id

    ----------------------------------------------------------------------------------
    -- May be useful to other functional areas.  Not populated for now.
    ----------------------------------------------------------------------------------
    i_taiv_rec.cra_id           := NULL;  -- OKL_CURE_REP_AMTS_V
    i_taiv_rec.qte_id           := NULL;  -- OKL_TRX_QUOTES_V
    i_taiv_rec.tcn_id           := NULL;  -- OKL_TRX_CONTRACTS
    i_taiv_rec.ipy_id           := NULL;  -- OKL_INS_POLICIES_V
    i_taiv_rec.tap_id           := NULL;  -- OKL_TRX_AP_INVOICES_V

    ----------------------------------------------------------------------------------
    -- Insert Invoice Header record
    ----------------------------------------------------------------------------------
    okl_trx_ar_invoices_pub.insert_trx_ar_invoices(p_api_version     => l_api_version,
                                                   p_init_msg_list   => l_init_msg_list,
                                                   x_return_status   => l_return_status,
                                                   x_msg_count       => x_msg_count,
                                                   x_msg_data        => x_msg_data,
                                                   p_taiv_rec        => i_taiv_rec,
                                                   x_taiv_rec        => r_taiv_rec);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ----------------------------------------------------------------------------------
    -- Prepare Invoice Line
    ----------------------------------------------------------------------------------
    i_tilv_rec.line_number            := l_line_number;
    i_tilv_rec.tai_id                 := r_taiv_rec.id;
    i_tilv_rec.description            := l_svf_desc;
    i_tilv_rec.amount                 := r_taiv_rec.amount;
    i_tilv_rec.sty_id                 := l_sty_id;

    -- this field is passed as invoice description in AR
    -- you can actually put 'LINE' or 'CHARGE'
    -- 'CHARGE' is used for financial charges and has some accounting
    -- implications in AR; till further notice please always use LINE

    i_tilv_rec.inv_receiv_line_code := 'LINE';

    ----------------------------------------------------------------------------------
    -- Insert transaction line record
    ----------------------------------------------------------------------------------

    okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (p_api_version       => l_api_version,
                                                   p_init_msg_list   => l_init_msg_list,
                                                   x_return_status   => l_return_status,
                                                   x_msg_count       => x_msg_count,
                                                   x_msg_data        => x_msg_data,
                                                   p_tilv_rec        => i_tilv_rec,
                                                   x_tilv_rec        => r_tilv_rec);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Commented the following lines to call the Accounting Wrapper API.
    --The commented call does not take into account the dynamically
    --generated Accounts. it works only if the Static accounts are specified.
    --The new call handles this case.
    --This was fixed for Credit memo via bug fix 3843941
    --The same code is being fixed in this API via bug 4122293

/*
    ----------------------------------------------------------------------------------
    -- Prepare OKL Accouting Engine parameters
    ----------------------------------------------------------------------------------

    l_tmpl_identify_rec.PRODUCT_ID              := l_pdt_id;
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID     := l_try_id;
    l_tmpl_identify_rec.STREAM_TYPE_ID          := l_sty_id;
    l_tmpl_identify_rec.ADVANCE_ARREARS         := NULL;
    l_tmpl_identify_rec.FACTORING_SYND_FLAG     := l_factoring_synd;
    l_tmpl_identify_rec.SYNDICATION_CODE        := l_syndication_code;
    l_tmpl_identify_rec.FACTORING_CODE          := l_factoring_code;
    l_tmpl_identify_rec.MEMO_YN                 := 'N';
    l_tmpl_identify_rec.PRIOR_YEAR_YN           := 'N';

    l_dist_info_rec.SOURCE_ID                   := r_tilv_rec.id;
    l_dist_info_rec.SOURCE_TABLE                := 'OKL_TXL_AR_INV_LNS_B';
    l_dist_info_rec.ACCOUNTING_DATE             := l_sysdate;
    l_dist_info_rec.GL_REVERSAL_FLAG            := 'N';
    l_dist_info_rec.POST_TO_GL                  := 'N';
    l_dist_info_rec.AMOUNT                      := l_svf_amount;
    l_dist_info_rec.CURRENCY_CODE               := NULL;
    l_dist_info_rec.CURRENCY_CONVERSION_TYPE    := NULL;
    l_dist_info_rec.CURRENCY_CONVERSION_DATE    := NULL;
    l_dist_info_rec.CONTRACT_ID                 := l_khr_id;
    l_dist_info_rec.CONTRACT_LINE_ID            := NULL;

    l_ctxt_val_tbl(1).name                      := NULL;
    l_ctxt_val_tbl(1).value                     := NULL;

    l_acc_gen_primary_key_tbl(1).source_table       := 'RA_CUST_TRX_TYPES';
    l_acc_gen_primary_key_tbl(1).primary_key_column := 'CUSTOMER_TRX_ID';

    okl_account_dist_pub.create_accounting_dist(p_api_version               => l_api_version,
                                                p_init_msg_list             => l_init_msg_list,
                                                x_return_status             => l_return_status,
                                                x_msg_count                 => x_msg_count,
                                                x_msg_data                  => x_msg_data,
                                                p_tmpl_identify_rec         => l_tmpl_identify_rec,
                                                p_dist_info_rec             => l_dist_info_rec,
                                                p_ctxt_val_tbl              => l_ctxt_val_tbl,
                                                p_acc_gen_primary_key_tbl   => l_acc_gen_primary_key_tbl,
                                                x_template_tbl              => lx_template_tbl,
                                                x_amount_tbl                => lx_amount_tbl);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

*/

	--New call to call the BPD wrapper API.
            ------------------------------------------------------
            -- Create distributions using Accounting Engine
            ------------------------------------------------------
            l_bpd_acc_rec.id           := r_tilv_rec.id;
            l_bpd_acc_rec.source_table := 'OKL_TXL_AR_INV_LNS_B';
            ----------------------------------------------------
            -- Create Accounting Distributions
            ----------------------------------------------------
            Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
                  			p_api_version 		=> l_api_version
                 			,p_init_msg_list        => l_init_msg_list
                   			,x_return_status	=> l_return_status
                   			,x_msg_count		=> x_msg_count
			                ,x_msg_data		=> x_msg_data
		                        ,p_bpd_acc_rec		=> l_bpd_acc_rec);


    	IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    	END IF;


    x_tai_id        := r_taiv_rec.id;
    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END create_svf_invoice;

END okl_cs_transactions_pvt;

/

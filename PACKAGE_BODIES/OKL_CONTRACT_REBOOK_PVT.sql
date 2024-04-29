--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_REBOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_REBOOK_PVT" AS
/* $Header: OKLRRBKB.pls 120.50.12010000.12 2009/12/24 06:43:56 rgooty ship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Global Variables
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_REBOOK_PVT';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

   --Bug# 4212626
   G_INSURANCE_LSE_ID CONSTANT NUMBER := 47;

--   subtype tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
   SUBTYPE stmv_rec_type IS OKL_STREAMS_PUB.stmv_rec_type;
   SUBTYPE stmv_tbl_type IS OKL_STREAMS_PUB.stmv_tbl_type;
   SUBTYPE selv_rec_type IS OKL_STREAMS_PUB.selv_rec_type;
   SUBTYPE selv_tbl_type IS OKL_STREAMS_PUB.selv_tbl_type;
   SUBTYPE khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
   SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   SUBTYPE clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;
   SUBTYPE klev_tbl_type IS OKL_CONTRACT_PUB.klev_tbl_type;
   SUBTYPE klev_rec_type IS OKL_CONTRACT_PUB.klev_rec_type;
   SUBTYPE clev_rec_type IS OKL_OKC_MIGRATION_PVT.clev_rec_type;
   SUBTYPE rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
   SUBTYPE rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;
   SUBTYPE rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
   SUBTYPE cvmv_rec_type IS OKL_VERSION_PUB.cvmv_rec_type;
   SUBTYPE cimv_rec_type IS Okl_Okc_Migration_Pvt.cimv_rec_type;
   --SUBTYPE talv_rec_type IS Okl_Txl_Assets_Pub.tlpv_rec_type;
   --SUBTYPE itiv_tbl_type IS Okl_Txl_Itm_Insts_Pub.iipv_tbl_type;
   SUBTYPE cplv_rec_type IS OKL_OKC_MIGRATION_PVT.cplv_rec_type;
   SUBTYPE rmpv_rec_type IS OKL_RULE_PUB.rmpv_rec_type;
   SUBTYPE inv_agmt_chr_id_tbl_type IS okl_securitization_pvt.inv_agmt_chr_id_tbl_type;

   -- sjalasut: added global constants to support fee types; changes added as part of Rebook Change Control Enhancement. START
   G_ROLLOVER_FEE CONSTANT fnd_lookups.lookup_code%TYPE DEFAULT 'ROLLOVER';
   -- sjalasut: added global constants to support fee types; changes added as part of Rebook Change Control Enhancement. END

   /*
   -- mvasudev, 08/23/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_REBOOK_REQUESTED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.rebook_requested';

   G_WF_ITM_SRC_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'SOURCE_CONTRACT_ID';
   G_WF_ITM_REVISION_DATE CONSTANT VARCHAR2(15)    := 'REVISION_DATE';
   G_WF_ITM_DEST_CONTRACT_ID CONSTANT VARCHAR2(25) := 'DESTINATION_CONTRACT_ID';

   --Bug# 8652738
   G_ASSET_FILING_RGP           CONSTANT VARCHAR2(10) := 'LAAFLG';
   G_ASSET_RETURN_RGP           CONSTANT VARCHAR2(10) := 'AMLARL';
   G_BILLING_SETUP_RGP          CONSTANT VARCHAR2(10) := 'LABILL';
   G_COND_PARTIAL_TERM_QTE_RGP  CONSTANT VARCHAR2(10) := 'AMTPAR';
   G_CONTRACT_PORTFOLIO_RGP     CONSTANT VARCHAR2(10) := 'AMCOPO';
   G_EARLY_TERM_PUR_OPT_RGP     CONSTANT VARCHAR2(10) := 'AMTEOC';
   G_END_OF_TERM_PUR_OPT_RGP    CONSTANT VARCHAR2(10) := 'AMTFOC';
   G_EVERGREEN_ELIG_RGP         CONSTANT VARCHAR2(10) := 'LAEVEL';
   G_FACTORING_RGP              CONSTANT VARCHAR2(10) := 'LAFCTG';
   G_GAIN_LOSS_TERM_QTE_RGP     CONSTANT VARCHAR2(10) := 'AMTGAL';
   G_LATE_CHARGES_RGP           CONSTANT VARCHAR2(10) := 'LALCGR';
   G_LATE_INTEREST_RGP          CONSTANT VARCHAR2(10) := 'LALIGR';
   G_QUOTE_APPROVER_RGP         CONSTANT VARCHAR2(10) := 'AMQR5A';
   G_QUOTE_COURTESY_COPY_RGP    CONSTANT VARCHAR2(10) := 'AMQR9F';
   G_QUOTE_RECEPIENT_RGP        CONSTANT VARCHAR2(10) := 'AMQR1R';
   G_RENEWAL_OPTIONS_RGP        CONSTANT VARCHAR2(10) := 'LARNOP';
   G_REPURCHASE_QTE_CALC_RGP    CONSTANT VARCHAR2(10) := 'AMREPQ';
   G_RESIDUAL_VALUE_INS_RGP     CONSTANT VARCHAR2(10) := 'LARVIN';
   G_SECURITY_DEPOSIT_RGP       CONSTANT VARCHAR2(10) := 'LASDEP';
   G_TAXES_AND_DUTIES_RGP       CONSTANT VARCHAR2(10) := 'LAHDTX';
   G_EARLY_TERM_QTE_CALC_RGP    CONSTANT VARCHAR2(10) := 'AMTEWC';
   G_END_OF_TERM_QTE_CALC_RGP   CONSTANT VARCHAR2(10) := 'AMTFWC';
   G_TERM_QUOTE_PROCESS_RGP     CONSTANT VARCHAR2(10) := 'AMTQPR';
   G_ASSET_TAXES_AND_DUTIES_RGP CONSTANT VARCHAR2(10) := 'LAASTX';
   G_REBOOK_LIMIT_DATE_RGP      CONSTANT VARCHAR2(10) := 'LAREBL';
   G_PRIVATE_ACTIVITY_BOND_RGP  CONSTANT VARCHAR2(10) := 'LAPACT';
   G_NON_NOTIFICATION_RGP       CONSTANT VARCHAR2(10) := 'LANNTF';
   --Bug# 8652738

------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );

    FOR i IN 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;


  ---------------------------------------------------------------------------
  -- FUNCTION get_chrv_rec for: OKC_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_chrv_rec (p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                         x_return_status OUT NOCOPY VARCHAR2)
  RETURN chrv_rec_type IS
    CURSOR okc_chrv_pk_csr(p_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID_RESPONSE,
           CHR_ID_AWARD,
           INV_ORGANIZATION_ID,
           STS_CODE,
           QCL_ID,
           SCS_CODE,
           CONTRACT_NUMBER,
           CURRENCY_CODE,
           CONTRACT_NUMBER_MODIFIER,
           ARCHIVED_YN,
           DELETED_YN,
           CUST_PO_NUMBER_REQ_YN,
           PRE_PAY_REQ_YN,
           CUST_PO_NUMBER,
           SHORT_DESCRIPTION,
           COMMENTS,
           DESCRIPTION,
           DPAS_RATING,
           COGNOMEN,
           TEMPLATE_YN,
           TEMPLATE_USED,
           DATE_APPROVED,
           DATETIME_CANCELLED,
           AUTO_RENEW_DAYS,
           DATE_ISSUED,
           DATETIME_RESPONDED,
           NON_RESPONSE_REASON,
           NON_RESPONSE_EXPLAIN,
           RFP_TYPE,
           CHR_TYPE,
           KEEP_ON_MAIL_LIST,
           SET_ASIDE_REASON,
           SET_ASIDE_PERCENT,
           RESPONSE_COPIES_REQ,
           DATE_CLOSE_PROJECTED,
           DATETIME_PROPOSED,
           DATE_SIGNED,
           DATE_TERMINATED,
           DATE_RENEWED,
           TRN_CODE,
           START_DATE,
           END_DATE,
           AUTHORING_ORG_ID,
           BUY_OR_SELL,
           ISSUE_OR_RECEIVE,
           ESTIMATED_AMOUNT,
           ESTIMATED_AMOUNT_RENEWED,
           CURRENCY_CODE_RENEWED,
           UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           APPLICATION_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
     FROM okc_k_headers_v chrv
     WHERE chrv.id = p_id;
     x_chrv_rec chrv_rec_type;
  BEGIN
    OPEN okc_chrv_pk_csr (p_chr_id);
    FETCH okc_chrv_pk_csr INTO
          x_chrv_rec.ID,
          x_chrv_rec.OBJECT_VERSION_NUMBER,
          x_chrv_rec.SFWT_FLAG,
          x_chrv_rec.CHR_ID_RESPONSE,
          x_chrv_rec.CHR_ID_AWARD,
          x_chrv_rec.INV_ORGANIZATION_ID,
          x_chrv_rec.STS_CODE,
          x_chrv_rec.QCL_ID,
          x_chrv_rec.SCS_CODE,
          x_chrv_rec.CONTRACT_NUMBER,
          x_chrv_rec.CURRENCY_CODE,
          x_chrv_rec.CONTRACT_NUMBER_MODIFIER,
          x_chrv_rec.ARCHIVED_YN,
          x_chrv_rec.DELETED_YN,
          x_chrv_rec.CUST_PO_NUMBER_REQ_YN,
          x_chrv_rec.PRE_PAY_REQ_YN,
          x_chrv_rec.CUST_PO_NUMBER,
          x_chrv_rec.SHORT_DESCRIPTION,
          x_chrv_rec.COMMENTS,
          x_chrv_rec.DESCRIPTION,
          x_chrv_rec.DPAS_RATING,
          x_chrv_rec.COGNOMEN,
          x_chrv_rec.TEMPLATE_YN,
          x_chrv_rec.TEMPLATE_USED,
          x_chrv_rec.DATE_APPROVED,
          x_chrv_rec.DATETIME_CANCELLED,
          x_chrv_rec.AUTO_RENEW_DAYS,
          x_chrv_rec.DATE_ISSUED,
          x_chrv_rec.DATETIME_RESPONDED,
          x_chrv_rec.NON_RESPONSE_REASON,
          x_chrv_rec.NON_RESPONSE_EXPLAIN,
          x_chrv_rec.RFP_TYPE,
          x_chrv_rec.CHR_TYPE,
          x_chrv_rec.KEEP_ON_MAIL_LIST,
          x_chrv_rec.SET_ASIDE_REASON,
          x_chrv_rec.SET_ASIDE_PERCENT,
          x_chrv_rec.RESPONSE_COPIES_REQ,
          x_chrv_rec.DATE_CLOSE_PROJECTED,
          x_chrv_rec.DATETIME_PROPOSED,
          x_chrv_rec.DATE_SIGNED,
          x_chrv_rec.DATE_TERMINATED,
          x_chrv_rec.DATE_RENEWED,
          x_chrv_rec.TRN_CODE,
          x_chrv_rec.START_DATE,
          x_chrv_rec.END_DATE,
          x_chrv_rec.AUTHORING_ORG_ID,
          x_chrv_rec.BUY_OR_SELL,
          x_chrv_rec.ISSUE_OR_RECEIVE,
          x_chrv_rec.ESTIMATED_AMOUNT,
          x_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
          x_chrv_rec.CURRENCY_CODE_RENEWED,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF,
          x_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
          x_chrv_rec.APPLICATION_ID,
          x_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
          x_chrv_rec.ORIG_SYSTEM_ID1,
          x_chrv_rec.ORIG_SYSTEM_REFERENCE1,
          x_chrv_rec.ATTRIBUTE_CATEGORY,
          x_chrv_rec.ATTRIBUTE1,
          x_chrv_rec.ATTRIBUTE2,
          x_chrv_rec.ATTRIBUTE3,
          x_chrv_rec.ATTRIBUTE4,
          x_chrv_rec.ATTRIBUTE5,
          x_chrv_rec.ATTRIBUTE6,
          x_chrv_rec.ATTRIBUTE7,
          x_chrv_rec.ATTRIBUTE8,
          x_chrv_rec.ATTRIBUTE9,
          x_chrv_rec.ATTRIBUTE10,
          x_chrv_rec.ATTRIBUTE11,
          x_chrv_rec.ATTRIBUTE12,
          x_chrv_rec.ATTRIBUTE13,
          x_chrv_rec.ATTRIBUTE14,
          x_chrv_rec.ATTRIBUTE15,
          x_chrv_rec.CREATED_BY,
          x_chrv_rec.CREATION_DATE,
          x_chrv_rec.LAST_UPDATED_BY,
          x_chrv_rec.LAST_UPDATE_DATE,
          x_chrv_rec.LAST_UPDATE_LOGIN;
    IF okc_chrv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_chrv_pk_csr;
    RETURN(x_chrv_rec);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              'SQLcode',
              SQLCODE,
              'SQLerrm',
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- if the cursor is open
      IF okc_chrv_pk_csr%ISOPEN THEN
         CLOSE okc_chrv_pk_csr;
      END IF;

  END get_chrv_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION get_khrv_rec for: OKL_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_khrv_rec (
    p_khr_id                       IN  OKL_K_HEADERS_V.ID%TYPE,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN khrv_rec_type IS
    CURSOR okl_k_headers_v_pk_csr (p_id IN OKL_K_HEADERS_V.ID%TYPE) IS
      SELECT
	ID,
        OBJECT_VERSION_NUMBER,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        AMD_CODE,
        DATE_FIRST_ACTIVITY,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        DATE_REFINANCED,
        CREDIT_ACT_YN,
        TERM_DURATION,
        CONVERTED_ACCOUNT_YN,
        DATE_CONVERSION_EFFECTIVE,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_DEAL_TRANSFERRED,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN
      FROM OKL_K_HEADERS_V
      WHERE OKL_K_HEADERS_V.id     = p_id;
      l_okl_k_headers_v_pk     okl_k_headers_v_pk_csr%ROWTYPE;
      l_khrv_rec               khrv_rec_type;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Get current database values
    OPEN okl_k_headers_v_pk_csr (p_khr_id);
    FETCH okl_k_headers_v_pk_csr INTO
       l_khrv_rec.ID,
        l_khrv_rec.OBJECT_VERSION_NUMBER,
        l_khrv_rec.ISG_ID,
        l_khrv_rec.KHR_ID,
        l_khrv_rec.PDT_ID,
        l_khrv_rec.AMD_CODE,
        l_khrv_rec.DATE_FIRST_ACTIVITY,
        l_khrv_rec.GENERATE_ACCRUAL_YN,
        l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_khrv_rec.DATE_REFINANCED,
        l_khrv_rec.CREDIT_ACT_YN,
        l_khrv_rec.TERM_DURATION,
        l_khrv_rec.CONVERTED_ACCOUNT_YN,
        l_khrv_rec.DATE_CONVERSION_EFFECTIVE,
        l_khrv_rec.SYNDICATABLE_YN,
        l_khrv_rec.SALESTYPE_YN,
        l_khrv_rec.DATE_DEAL_TRANSFERRED,
        l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_khrv_rec.DATE_PROPOSAL_ACCEPTED,
        l_khrv_rec.ATTRIBUTE_CATEGORY,
        l_khrv_rec.ATTRIBUTE1,
        l_khrv_rec.ATTRIBUTE2,
        l_khrv_rec.ATTRIBUTE3,
        l_khrv_rec.ATTRIBUTE4,
        l_khrv_rec.ATTRIBUTE5,
        l_khrv_rec.ATTRIBUTE6,
        l_khrv_rec.ATTRIBUTE7,
        l_khrv_rec.ATTRIBUTE8,
        l_khrv_rec.ATTRIBUTE9,
        l_khrv_rec.ATTRIBUTE10,
        l_khrv_rec.ATTRIBUTE11,
        l_khrv_rec.ATTRIBUTE12,
        l_khrv_rec.ATTRIBUTE13,
        l_khrv_rec.ATTRIBUTE14,
        l_khrv_rec.ATTRIBUTE15,
        l_khrv_rec.CREATED_BY,
        l_khrv_rec.CREATION_DATE,
        l_khrv_rec.LAST_UPDATED_BY,
        l_khrv_rec.LAST_UPDATE_DATE,
        l_khrv_rec.LAST_UPDATE_LOGIN,
        l_khrv_rec.PRE_TAX_YIELD,
        l_khrv_rec.AFTER_TAX_YIELD,
        l_khrv_rec.IMPLICIT_INTEREST_RATE,
        l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_khrv_rec.TARGET_PRE_TAX_YIELD,
        l_khrv_rec.TARGET_AFTER_TAX_YIELD,
        l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_khrv_rec.DEAL_TYPE,
        l_khrv_rec.PRE_TAX_IRR,
        l_khrv_rec.AFTER_TAX_IRR,
        l_khrv_rec.EXPECTED_DELIVERY_DATE,
        l_khrv_rec.ACCEPTED_DATE,
        l_khrv_rec.PREFUNDING_ELIGIBLE_YN,
        l_khrv_rec.REVOLVING_CREDIT_YN
        ;
    IF okl_k_headers_v_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_k_headers_v_pk_csr;
    RETURN(l_khrv_rec);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              'SQLcode',
              SQLCODE,
              'SQLerrm',
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      -- if the cursor is open
      IF okl_k_headers_v_pk_csr%ISOPEN THEN
         CLOSE okl_k_headers_v_pk_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_khrv_rec;

------------------------------------------------------------------------------
-- PROCEDURE validate_rebook_reason
--
--  This procedure validate rebook reason code
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE validate_rebook_reason(
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_rebook_reason_code IN  VARCHAR2
                                  ) IS

  l_proc_name VARCHAR2(35) := 'VALIDATE_REBOOK_REASON';
  l_dummy     VARCHAR2(1);

  CURSOR rebook_csr (p_rebook_reason_code VARCHAR2) IS
  SELECT 'X'
  FROM   FND_LOOKUPS
  WHERE  lookup_type = 'OKL_REBOOK_REASON'
  AND    lookup_code = p_rebook_reason_code;

  rebook_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN rebook_csr(p_rebook_reason_code);
    FETCH rebook_csr INTO l_dummy;
    IF rebook_csr%NOTFOUND THEN
       RAISE rebook_failed;
    END IF;
    CLOSE rebook_csr;

    RETURN;

  EXCEPTION
    WHEN rebook_failed THEN
       okl_api.set_message(
                            G_APP_NAME,
                            G_INVALID_VALUE,
                            'COL_NAME',
                            'REBOOK REASON'
                           );
       x_return_status := OKC_API.G_RET_STS_ERROR;

  END validate_rebook_reason;

------------------------------------------------------------------------------
-- PROCEDURE copy_rebook_stream
--
--  This procedure copys streams from Rebook Contract to Original Contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE copy_rebook_stream(
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE
                              ) IS
  l_proc_name VARCHAR2(35) := 'COPY_REBOOK_STREAM';
  l_stmv_rec  stmv_rec_type;
  l_selv_tbl  selv_tbl_type;
  x_stmv_rec  stmv_rec_type;
  x_selv_tbl  selv_tbl_type;
  l_no_of_ele NUMBER := 0;
  copy_failed EXCEPTION;

  CURSOR strm_hdr_csr (p_rebook_chr_id OKC_K_HEADERS_V.ID%TYPE) IS -- Bug 3984890
  SELECT
    str.id,
    str.sty_id,
    str.khr_id,
    str.kle_id,
    str.sgn_code,
    str.say_code,
    str.transaction_number,
    str.active_yn,
    str.object_version_number,
    str.created_by,
    str.creation_date,
    str.last_updated_by,
    str.last_update_date,
    str.date_current,
    str.date_working,
    str.date_history,
    str.comments,
    str.program_id,
    str.request_id,
    str.program_application_id,
    str.program_update_date,
    str.last_update_login,
    str.purpose_code,
    sty.stream_type_purpose,
    --Bug# 4212626
    trx_id,
    link_hist_stream_id
    -- sty_code -- dropped after inclusion
  FROM   okl_streams str,
         okl_strm_type_v sty
  WHERE  str.khr_id   = p_rebook_chr_id
  AND    str.sty_id   = sty.id
  AND    str.say_code = 'CURR';


  -- Bug# 2857333
  CURSOR orig_strm_csr (p_khr_id       OKC_K_HEADERS_V.ID%TYPE,
                        p_kle_id       OKC_K_LINES_V.ID%TYPE,
                        p_sty_id       OKL_STREAMS.sty_id%TYPE,
                        p_purpose_code OKL_STREAMS.PURPOSE_CODE%TYPE) IS
  SELECT id
  FROM   okl_streams
  WHERE  khr_id = p_khr_id
  AND    sty_id = p_sty_id
  AND    NVL(kle_id,-1) = NVL(p_kle_id, -1)
  AND    say_code <> 'HIST'
  --  AND    sgn_code <> 'INTC' -- bug 4737555
  AND    sgn_code NOT IN ('INTC','LATE_CALC') -- Bug 6472228
  AND    NVL(purpose_code,'XXXX') = NVL(p_purpose_code, 'XXXX');

  CURSOR strm_element_csr(p_stm_id okl_strm_elements.stm_id%TYPE) IS
  SELECT *
  FROM   okl_strm_elements
  WHERE  stm_id = p_stm_id;

  CURSOR orig_line_csr (p_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT orig_system_id1
  FROM   okc_k_lines_b
  WHERE  id = p_line_id;

  CURSOR new_line_csr (p_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT id
  FROM   okc_k_lines_b
  WHERE  orig_system_id1 = p_line_id;

  CURSOR unbill_adj_csr( khrId NUMBER,
                         kleid NUMBER ) IS
  SELECT NVL(ele.amount,0) amount
  FROM   okl_strm_elements ele,
         okl_streams str,
         --okl_strm_type_tl sty
         okl_strm_type_v sty
  WHERE  NVL(str.kle_id,-1) = kleid
  AND    str.khr_id      = khrId
  AND    str.sty_id      = sty.id
  AND    str.say_code    = 'CURR'
  AND    str.active_yn   = 'Y'
  --AND    sty.name        = 'BILLING ADJUSTMENT'
  AND    sty.stream_type_purpose = 'REBOOK_BILLING_ADJUSTMENT'
  --AND    sty.LANGUAGE    = 'US'
  AND    ele.stm_id      = str.id
  AND    ele.date_billed IS NULL;

  CURSOR undesb_adj_csr( khrId NUMBER,
                         kleid NUMBER ) IS
  SELECT NVL(ele.amount,0) amount
  FROM   okl_strm_elements ele,
         okl_streams str,
         --okl_strm_type_tl sty
         okl_strm_type_v sty
  WHERE  NVL(str.kle_id,-1) = kleid
  AND    str.khr_id      = khrId
  AND    str.sty_id      = sty.id
  AND    str.say_code    = 'CURR'
  AND    str.active_yn   = 'Y'
  --AND    sty.name        = 'INVESTOR DISBURSEMENT ADJUSTMENT'
  AND    sty.stream_type_purpose = 'INVESTOR_DISB_ADJUSTMENT'
  --AND    sty.LANGUAGE    = 'US'
  AND    ele.stm_id      = str.id
  AND    ele.date_billed IS NULL;

/* not required after UDS
  CURSOR strm_code_csr (p_sty_id NUMBER) IS
  SELECT code
  FROM   okl_strm_type_v
  WHERE  id = p_sty_id;
*/

  l_orig_line_id OKC_K_LINES_B.ID%TYPE;

  l_orig_strm_tbl stmv_tbl_type;
  x_orig_strm_tbl stmv_tbl_type;

  l_orig_strm_count NUMBER := 0;
  --l_strm_code OKL_STRM_TYPE_V.CODE%TYPE;
  l_unbill_adj_amount NUMBER := 0;
  l_undesb_adj_amount NUMBER := 0;

  x_billing_adj_sty_id  NUMBER;
  x_inv_disb_adj_sty_id NUMBER;

  --Bug# 4212626
  -- Cursor to fetch Streams deleted during rebook
  CURSOR deleted_streams_csr(p_orig_chr_id  IN NUMBER,
                             p_rebook_chr_id   IN NUMBER) IS
  SELECT orig_stm.id orig_stm_id,
         sty.stream_type_purpose,
         cle.lse_id
  FROM   okl_streams orig_stm,
         okc_k_lines_b cle,
         okl_strm_type_v sty
  WHERE  orig_stm.khr_id = p_orig_chr_id
  AND    orig_stm.say_code = 'CURR'
  --AND    orig_stm.sgn_code <> 'INTC' -- bug 4737555
  AND    orig_stm.sgn_code NOT IN ('INTC','LATE_CALC') -- Bug6472228
  AND    cle.id(+) = orig_stm.kle_id
  AND    cle.dnz_chr_id(+) = orig_stm.khr_id
  AND    sty.id = orig_stm.sty_id
  AND    NOT EXISTS (SELECT 1
                     FROM okl_streams new_stm
                     WHERE new_stm.khr_id = p_rebook_chr_id
                     AND   new_stm.say_code = 'CURR'
                     AND   new_stm.link_hist_stream_id = orig_stm.id);

  --Bug# 4212626
  -- Cursor to determine if Stream is billed
  CURSOR stm_not_billed_csr(p_stm_id IN NUMBER) IS
  SELECT 1
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND sel.date_billed IS NULL
  AND rownum = 1;

  stm_not_billed_rec stm_not_billed_csr%ROWTYPE;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

/*
 * Not required, got purpose from driving cursor strm_hdr_csr
 *
     -- Get Stream id for purpose = BILLING ADJUSTMENT
     OKL_STREAMS_UTIL.get_primary_stream_type(
       p_khr_id               => p_orig_chr_id,
       p_primary_sty_purpose  => 'REBOOK_BILLING_ADJUSTMENT',
       x_return_status        => x_return_status,
       x_primary_sty_id       => x_billing_adj_sty_id
       );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE copy_failed;
     END IF;

     -- Get Stream id for purpose = INVESTOR_DISB_ADJUSTMENT
     x_inv_disb_adj_sty_id := NULL;
     OPEN inv_adj_csr;
     FETCH inv_adj_csr INTO x_inv_disb_adj_sty_id;
     CLOSE inv_adj_csr;

     OKL_STREAMS_UTIL.get_primary_stream_type(
       p_khr_id               => p_orig_chr_id,
       p_primary_sty_purpose  => 'INVESTOR_DISB_ADJUSTMENT',
       x_return_status        => x_return_status,
       x_primary_sty_id       => x_inv_disb_adj_sty_id
       );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE copy_failed;
     END IF;
*/

     --Bug# 4212626: start
     -- Historize Streams in the original contract
     -- which are deleted during rebook
     -- This cursor ignores all streams linked to
     -- the Insurance Line, so no Insurance Streams
     -- will be historized by this process

     l_orig_strm_tbl.DELETE;
     l_orig_strm_count := 0;

     FOR deleted_streams_rec IN deleted_streams_csr
                                 (p_orig_chr_id   => p_orig_chr_id,
                                  p_rebook_chr_id => p_rebook_chr_id)
     LOOP

       -- Ignore Insurance Streams
       IF (NVL(deleted_streams_rec.lse_id,-1) = G_INSURANCE_LSE_ID) THEN

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ignore Insurance Stream Line ID: '||deleted_streams_rec.orig_stm_id);
         END IF;
         NULL;

       -- Ignore Investor Disbursement Adjustment Streams when
       -- historizing streams deleted during rebook.
       ELSIF (deleted_streams_rec.stream_type_purpose = 'INVESTOR_DISB_ADJUSTMENT') THEN

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ignore Inv Disb Adj Stream Line ID: '||deleted_streams_rec.orig_stm_id);
         END IF;
         NULL;

       -- Bug# 4775555
       -- Ignore all Investor Streams when historizing streams deleted during rebook.
       ELSIF (deleted_streams_rec.stream_type_purpose IN
             ('INVESTOR_CNTRCT_OBLIGATION_PAY','INVESTOR_DISB_ADJUSTMENT','INVESTOR_EVERGREEN_RENT_PAY',
              'INVESTOR_INTEREST_INCOME','INVESTOR_INTEREST_PAYABLE','INVESTOR_LATE_FEE_PAYABLE',
              'INVESTOR_LATE_INTEREST_PAY','INVESTOR_PAYABLE','INVESTOR_PRETAX_INCOME',
              'INVESTOR_PRINCIPAL_PAYABLE','INVESTOR_RECEIVABLE','INVESTOR_RENTAL_ACCRUAL',
              'INVESTOR_RENT_BUYBACK','INVESTOR_RENT_DISB_BASIS','INVESTOR_RENT_PAYABLE',
              'INVESTOR_RESIDUAL_BUYBACK','INVESTOR_RESIDUAL_DISB_BASIS','INVESTOR_RESIDUAL_PAY',
              'INVESTOR_VARIABLE_INTEREST','PV_RENT_SECURITIZED','PV_RV_SECURITIZED'))THEN

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ignore Investor Stream Line ID: '||deleted_streams_rec.orig_stm_id);
         END IF;
         NULL;

       -- Historize Billing Adjustment Streams only if they have been billed, else
       -- ignore Billing Adjustment Streams.
       ELSIF (deleted_streams_rec.stream_type_purpose = 'REBOOK_BILLING_ADJUSTMENT') THEN

         OPEN stm_not_billed_csr(p_stm_id => deleted_streams_rec.orig_stm_id);
         FETCH stm_not_billed_csr INTO stm_not_billed_rec;
         IF stm_not_billed_csr%FOUND THEN
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Ignore Billing Adj Stream Line ID: '||deleted_streams_rec.orig_stm_id);
           END IF;
           NULL;

         ELSE
           l_orig_strm_count := l_orig_strm_count + 1;
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Historize Billing Adj Stream Line ID: '||deleted_streams_rec.orig_stm_id);
           END IF;

           l_orig_strm_tbl(l_orig_strm_count).id        := deleted_streams_rec.orig_stm_id;
           l_orig_strm_tbl(l_orig_strm_count).say_code  := 'HIST';
           l_orig_strm_tbl(l_orig_strm_count).date_history  := SYSDATE;
           l_orig_strm_tbl(l_orig_strm_count).active_yn := 'N';
         END IF;
         CLOSE stm_not_billed_csr;

       ELSE
         l_orig_strm_count := l_orig_strm_count + 1;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Historize Deleted Stream Line ID: '||deleted_streams_rec.orig_stm_id);
         END IF;

         l_orig_strm_tbl(l_orig_strm_count).id        := deleted_streams_rec.orig_stm_id;
         l_orig_strm_tbl(l_orig_strm_count).say_code  := 'HIST';
         l_orig_strm_tbl(l_orig_strm_count).date_history  := SYSDATE;
         l_orig_strm_tbl(l_orig_strm_count).active_yn := 'N';
       END IF;
     END LOOP;
     --Bug# 4212626: end

     IF (l_orig_strm_tbl.COUNT > 0) THEN
       okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKC_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_tbl       => l_orig_strm_tbl,
                                      x_stmv_tbl       => x_orig_strm_tbl
                                     );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Deleted Orig strm to HIST '||x_return_status);
       END IF;

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE copy_failed;
       END IF;
     END IF;

     FOR strm_hdr_rec IN strm_hdr_csr (p_rebook_chr_id)
     LOOP
/*
     OPEN strm_hdr_csr(p_rebook_chr_id);
     FETCH strm_hdr_csr INTO l_stmv_rec;

     IF strm_hdr_csr%NOTFOUND THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_NO_STREAM
                           );

        RAISE copy_failed;
     END IF;
     CLOSE strm_hdr_csr;
*/
        --l_stmv_rec := strm_hdr_rec;

        l_stmv_rec.id                     := strm_hdr_rec.id;
        l_stmv_rec.sty_id                 := strm_hdr_rec.sty_id;
        l_stmv_rec.khr_id                 := strm_hdr_rec.khr_id;
        l_stmv_rec.kle_id                 := strm_hdr_rec.kle_id;
        l_stmv_rec.sgn_code               := strm_hdr_rec.sgn_code;
        l_stmv_rec.say_code               := strm_hdr_rec.say_code;
        l_stmv_rec.transaction_number     := strm_hdr_rec.transaction_number;
        l_stmv_rec.active_yn              := strm_hdr_rec.active_yn;
        l_stmv_rec.object_version_number  := strm_hdr_rec.object_version_number;
        l_stmv_rec.created_by             := strm_hdr_rec.created_by;
        l_stmv_rec.creation_date          := strm_hdr_rec.creation_date;
        l_stmv_rec.last_updated_by        := strm_hdr_rec.last_updated_by;
        l_stmv_rec.last_update_date       := strm_hdr_rec.last_update_date;
        l_stmv_rec.date_current           := strm_hdr_rec.date_current;
        l_stmv_rec.date_working           := strm_hdr_rec.date_working;
        l_stmv_rec.date_history           := strm_hdr_rec.date_history;
        l_stmv_rec.comments               := strm_hdr_rec.comments;
        l_stmv_rec.program_id             := strm_hdr_rec.program_id;
        l_stmv_rec.request_id             := strm_hdr_rec.request_id;
        l_stmv_rec.program_application_id := strm_hdr_rec.program_application_id;
        l_stmv_rec.program_update_date    := strm_hdr_rec.program_update_date;
        l_stmv_rec.last_update_login      := strm_hdr_rec.last_update_login;
        l_stmv_rec.purpose_code           := strm_hdr_rec.purpose_code;
        --Bug# 4212626
        l_stmv_rec.trx_id                 := strm_hdr_rec.trx_id;
        l_stmv_rec.link_hist_stream_id    := strm_hdr_rec.link_hist_stream_id;


/* not required after UDS
        -- Get Stream name
        FOR strm_code_rec IN strm_code_csr (l_stmv_rec.sty_id)
        LOOP
           l_strm_code := strm_code_rec.code;
        END LOOP;
*/

        --
        -- Get Original line id, Bug# 2745885
        --
        IF (l_stmv_rec.kle_id IS NOT NULL) THEN
           OPEN orig_line_csr (l_stmv_rec.kle_id);
           FETCH orig_line_csr INTO l_orig_line_id;
           CLOSE orig_line_csr;

           IF( l_orig_line_id IS NULL) THEN -- New line added during rebook
             OPEN new_line_csr(l_stmv_rec.kle_id);
             FETCH new_line_csr INTO l_orig_line_id;
             CLOSE new_line_csr;
           END IF;

        ELSE
           l_orig_line_id := NULL; -- Stream at header level
        END IF;

        --
        -- Get unbilled adjustment stream amount
        --
        l_unbill_adj_amount := 0;
        --Bug# 4212626: Billing Adjustment is now calculated during Activation
        /*
        OPEN unbill_adj_csr (p_orig_chr_id,
                             NVL(l_orig_line_id,-1));
        FETCH unbill_adj_csr INTO l_unbill_adj_amount;
        CLOSE unbill_adj_csr;
        */

        --
        -- Get undisbursed adjustment stream amount
        --
        l_undesb_adj_amount := 0;
        OPEN undesb_adj_csr (p_orig_chr_id,
                             NVL(l_orig_line_id,-1));
        FETCH undesb_adj_csr INTO l_undesb_adj_amount;
        CLOSE undesb_adj_csr;

        --
        -- Bug# 2857333, 03/12/2003
        -- Process to check and update stream to 'HIST'
        -- on original contract
        --
        l_orig_strm_tbl.DELETE;
        l_orig_strm_count := 0;

        FOR orig_strm_rec IN orig_strm_csr (p_orig_chr_id,
                                            l_orig_line_id,
                                            l_stmv_rec.sty_id,
                                            l_stmv_rec.purpose_code)
        LOOP
          l_orig_strm_count := l_orig_strm_count + 1;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Stream Line ID: '||orig_strm_rec.id);
          END IF;

          l_orig_strm_tbl(l_orig_strm_count).id        := orig_strm_rec.id;
          l_orig_strm_tbl(l_orig_strm_count).say_code  := 'HIST';
          l_orig_strm_tbl(l_orig_strm_count).active_yn := 'N';
          l_orig_strm_tbl(l_orig_strm_count).date_history  := SYSDATE;
        END LOOP;

        IF (l_orig_strm_tbl.COUNT > 0) THEN
          okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKC_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_tbl       => l_orig_strm_tbl,
                                      x_stmv_tbl       => x_orig_strm_tbl
                                     );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Orig strm to HIST '||x_return_status);
          END IF;

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE copy_failed;
          END IF;
        END IF;

        l_stmv_rec.khr_id             := p_orig_chr_id;  -- Overwriting Rebook CHR_ID with Original CHR_ID
        l_stmv_rec.kle_id             := l_orig_line_id; -- Overwritting Rebook Line ID with Original Line ID
        l_stmv_rec.say_code           := 'CURR';
        -- l_stmv_rec.active_yn          := 'Y';  -- Commented for Multi-Gap enhancement
        l_stmv_rec.sgn_code           := 'STMP-REBK';
        l_stmv_rec.comments           := 'Copied Stream From Contract '||
                                          l_stmv_rec.khr_id||', TRX_NUMBER='||l_stmv_rec.transaction_number||
                                          ' during Rebooking.';
        l_no_of_ele                   := 0;
        l_stmv_rec.date_current       := SYSDATE;
        l_selv_tbl.DELETE; -- initialize table

        FOR strm_element_rec IN strm_element_csr(l_stmv_rec.id)
        LOOP
           l_no_of_ele := l_no_of_ele + 1;

           l_selv_tbl(l_no_of_ele).object_version_number  := strm_element_rec.object_version_number;
           l_selv_tbl(l_no_of_ele).stm_id                 := strm_element_rec.stm_id;

           --
           -- Consider unbilled adjustment from orig contract, if any
           --
           --Bug# 4212626: Calculation of l_unbill_adj_amount has been commented out, so l_unbill_adj_amount
           --will always be zero.
           --IF (l_strm_code = 'BILLING ADJUSTMENT') THEN

           --debug_message('Adj: '||l_unbill_adj_amount);
           --debug_message('x_billing_adj_sty_id : '||x_billing_adj_sty_id);
           --debug_message('l_stmv_rec.sty_id : '||l_stmv_rec.sty_id);

           l_selv_tbl(l_no_of_ele).amount := strm_element_rec.amount;
           --IF (x_billing_adj_sty_id = l_stmv_rec.sty_id) THEN

           IF (strm_hdr_rec.stream_type_purpose = 'REBOOK_BILLING_ADJUSTMENT') THEN -- Bug 3984890
              l_selv_tbl(l_no_of_ele).amount := strm_element_rec.amount + NVL(l_unbill_adj_amount,0);
           END IF;

           --
           -- Consider undisbursed adjustment from orig contract, if any
           --

           --IF (l_strm_code = 'INVESTOR DISBURSEMENT ADJUSTMENT') THEN
           --IF (x_inv_disb_adj_sty_id = l_stmv_rec.sty_id) THEN

           IF (strm_hdr_rec.stream_type_purpose = 'INVESTOR_DISB_ADJUSTMENT') THEN -- Bug 3984890
              l_selv_tbl(l_no_of_ele).amount := strm_element_rec.amount + NVL(l_undesb_adj_amount,0);
           END IF;

           l_selv_tbl(l_no_of_ele).comments               := strm_element_rec.comments;
           l_selv_tbl(l_no_of_ele).accrued_yn             := strm_element_rec.accrued_yn;
           l_selv_tbl(l_no_of_ele).stream_element_date    := strm_element_rec.stream_element_date;
           l_selv_tbl(l_no_of_ele).program_id             := strm_element_rec.program_id;
           l_selv_tbl(l_no_of_ele).request_id             := strm_element_rec.request_id;
           l_selv_tbl(l_no_of_ele).program_application_id := strm_element_rec.program_application_id;
           l_selv_tbl(l_no_of_ele).program_update_date    := strm_element_rec.program_update_date;
           l_selv_tbl(l_no_of_ele).se_line_number         := strm_element_rec.se_line_number;
           l_selv_tbl(l_no_of_ele).date_billed            := strm_element_rec.date_billed;
           --Bug# 4212626
           l_selv_tbl(l_no_of_ele).bill_adj_flag          := strm_element_rec.bill_adj_flag;
           l_selv_tbl(l_no_of_ele).accrual_adj_flag       := strm_element_rec.accrual_adj_flag;
           --Bug#4884423
           l_selv_tbl(l_no_of_ele).date_disbursed         := strm_element_rec.date_disbursed;

        END LOOP;

        IF (l_no_of_ele = 0) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_LLA_NO_STREAM_ELEMENT
                              );
           RAISE copy_failed;
        END IF;

        -- call API to create new streams
        okl_streams_pub.create_streams(
                                       p_api_version    => 1.0,
                                       p_init_msg_list  => OKC_API.G_FALSE,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_stmv_rec       => l_stmv_rec,
                                       p_selv_tbl       => l_selv_tbl,
                                       x_stmv_rec       => x_stmv_rec,
                                       x_selv_tbl       => x_selv_tbl
                                      );

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE copy_failed;
        END IF;

     END LOOP; -- Header stream


     RETURN;

  EXCEPTION
     WHEN copy_failed THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
  END copy_rebook_stream;

------------------------------------------------------------------------------
-- PROCEDURE get_orig_chr_id
--
--  This procedure gets the Oroginal Contract ID for a given contract.
--  Used here to get Parent Contract Header ID from which rebooking got initiated
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE get_orig_chr_id(
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_chr_id        IN  NUMBER,
                            x_orig_chr_id   OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                           ) IS

  l_proc_name      VARCHAR2(35) := 'GET_ORIG_CHR_ID';
  l_orig_system_id OKC_K_HEADERS_V.ID%TYPE;
  orig_failed      EXCEPTION;

  CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.id%TYPE) IS
  SELECT orig_system_id1
  FROM   OKC_K_HEADERS_V
  WHERE  id = p_chr_id;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    OPEN orig_csr(p_chr_id);
    FETCH orig_csr INTO l_orig_system_id;
    IF orig_csr%NOTFOUND THEN
       RAISE orig_failed;
    END IF;
    IF (l_orig_system_id IS NULL) THEN
       RAISE orig_failed;
    END IF;

    CLOSE orig_csr;
    x_orig_chr_id := l_orig_system_id;

    RETURN;

  EXCEPTION

     WHEN orig_failed THEN
       IF orig_csr%ISOPEN THEN
         CLOSE orig_csr;
       END IF;
       x_return_status := OKC_API.G_RET_STS_ERROR;

  END get_orig_chr_id;

------------------------------------------------------------------------------
-- PROCEDURE change_stream_status
--
--  This procedure changes Stream Status to 3rd parameter for a contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE change_stream_status(
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_status        IN  VARCHAR2,
                                 p_active_yn     IN  VARCHAR2
                                ) IS

  l_proc_name VARCHAR2(35) := 'CHANGE_STREAM_STATUS';
  l_stmv_rec  stmv_rec_type;
  x_stmv_rec  stmv_rec_type;
  strm_failed EXCEPTION;
  l_id        NUMBER;

  CURSOR strm_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okl_streams
  WHERE  khr_id = p_chr_id
  -- BUg 4737555
--  AND    SGN_CODE <> 'INTC';
  AND    SGN_CODE NOT IN ('INTC','LATE_CALC'); -- Bug 6472228

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status     := OKC_API.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    FOR strm_rec IN strm_csr (p_chr_id)
    LOOP
/*
    OPEN strm_csr(p_chr_id);
    FETCH strm_csr INTO l_id;
    IF strm_csr%NOTFOUND THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_LLA_NO_STREAM
                          );
       debug_message('Failed');
       RAISE strm_failed;
    END IF;
    CLOSE strm_csr;
*/

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After CSR');
       END IF;
       l_stmv_rec.id       := strm_rec.id;
       l_stmv_rec.khr_id   := p_chr_id;
       l_stmv_rec.say_code := p_status;
       l_stmv_rec.active_yn := p_active_yn;

       IF p_status = 'WORK' THEN
         l_stmv_rec.date_working := SYSDATE;
       ELSIF p_status = 'CURR' THEN
         l_stmv_rec.date_current := SYSDATE;
       ELSIF p_status = 'HIST' THEN
         l_stmv_rec.date_history := SYSDATE;
       END IF;

       okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKC_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_rec       => l_stmv_rec,
                                      x_stmv_rec       => x_stmv_rec
                                     );
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update API Call');
       END IF;
       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE strm_failed;
       END IF;

    END LOOP;

    RETURN;

  EXCEPTION
     WHEN strm_failed THEN
        IF strm_csr%ISOPEN THEN
           CLOSE strm_csr;
        END IF;
        x_return_status := OKC_API.G_RET_STS_ERROR;
  END change_stream_status;

------------------------------------------------------------------------------
-- PROCEDURE get_sll_rules
--
--  This procedure retrieves all SLL related to given SLH rule under LALEVL Category
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_rule_info(
                  x_return_status OUT NOCOPY VARCHAR2,
                  p_rebook_chr_id IN  NUMBER,
                  p_rebook_cle_id IN  NUMBER,
                  p_rgd_code      IN  VARCHAR2,
                  p_rule_code     IN  VARCHAR2,
                  x_rulv_rec      OUT NOCOPY rulv_rec_type,
                  x_rule_count    OUT NOCOPY NUMBER
                 ) IS
    CURSOR okc_rulv_csr (p_rgd_code  IN VARCHAR2,
                         p_rule_code IN VARCHAR2,
                         p_chr_id    IN NUMBER,
                         p_cle_id    IN NUMBER) IS
    SELECT
            rule.ID,
            rule.OBJECT_VERSION_NUMBER,
            rule.SFWT_FLAG,
            rule.OBJECT1_ID1,
            rule.OBJECT2_ID1,
            rule.OBJECT3_ID1,
            rule.OBJECT1_ID2,
            rule.OBJECT2_ID2,
            rule.OBJECT3_ID2,
            rule.JTOT_OBJECT1_CODE,
            rule.JTOT_OBJECT2_CODE,
            rule.JTOT_OBJECT3_CODE,
            rule.DNZ_CHR_ID,
            rule.RGP_ID,
            rule.PRIORITY,
            rule.STD_TEMPLATE_YN,
            rule.COMMENTS,
            rule.WARN_YN,
            rule.ATTRIBUTE_CATEGORY,
            rule.ATTRIBUTE1,
            rule.ATTRIBUTE2,
            rule.ATTRIBUTE3,
            rule.ATTRIBUTE4,
            rule.ATTRIBUTE5,
            rule.ATTRIBUTE6,
            rule.ATTRIBUTE7,
            rule.ATTRIBUTE8,
            rule.ATTRIBUTE9,
            rule.ATTRIBUTE10,
            rule.ATTRIBUTE11,
            rule.ATTRIBUTE12,
            rule.ATTRIBUTE13,
            rule.ATTRIBUTE14,
            rule.ATTRIBUTE15,
            rule.CREATED_BY,
            rule.CREATION_DATE,
            rule.LAST_UPDATED_BY,
            rule.LAST_UPDATE_DATE,
            rule.LAST_UPDATE_LOGIN,
            --rule.TEXT,
            rule.RULE_INFORMATION_CATEGORY,
            rule.RULE_INFORMATION1,
            rule.RULE_INFORMATION2,
            rule.RULE_INFORMATION3,
            rule.RULE_INFORMATION4,
            rule.RULE_INFORMATION5,
            rule.RULE_INFORMATION6,
            rule.RULE_INFORMATION7,
            rule.RULE_INFORMATION8,
            rule.RULE_INFORMATION9,
            rule.RULE_INFORMATION10,
            rule.RULE_INFORMATION11,
            rule.RULE_INFORMATION12,
            rule.RULE_INFORMATION13,
            rule.RULE_INFORMATION14,
            rule.RULE_INFORMATION15,
            rule.TEMPLATE_YN,
            rule.ans_set_jtot_object_code,
            rule.ans_set_jtot_object_id1,
            rule.ans_set_jtot_object_id2,
            rule.DISPLAY_SEQUENCE
     FROM OKC_RULE_GROUPS_V rgp,
          Okc_Rules_V rule
     WHERE rgp.id                    = rule.rgp_id
     AND   rgp.rgd_code              = p_rgd_code
     AND   RULE_INFORMATION_CATEGORY = p_rule_code
     AND   rgp.dnz_chr_id            = p_chr_id
     AND   NVL(rgp.cle_id, -1)       = p_cle_id;

     l_rulv_rec                  rulv_rec_type;
     i                           NUMBER DEFAULT 0;
     l_proc_name                 VARCHAR2(35) := 'GET_RULE_INFO';
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rgd_code : '||p_rgd_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rule_code : '||p_rule_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'chr_id : '||p_rebook_chr_id);
    END IF;
    -- Get current database values
    OPEN okc_rulv_csr (p_rgd_code,
                       p_rule_code,
                       p_rebook_chr_id,
                       p_rebook_cle_id);
    LOOP
    FETCH okc_rulv_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              --l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    EXIT WHEN okc_rulv_csr%NOTFOUND;
      i := okc_rulv_csr%RowCount;
      x_rulv_rec := l_rulv_rec;
    END LOOP;
    CLOSE okc_rulv_csr;
    x_rule_count := i;

    RETURN;

   END get_rule_info;

------------------------------------------------------------------------------
-- PROCEDURE get_sll_rules
--
--  This procedure retrieves all SLL related to given SLH rule under LALEVL Category
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_sll_rules(
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           p_rgpv_rec       IN  rgpv_rec_type,
                           p_rdf_code       IN  VARCHAR2,
                           p_slh_id         IN  NUMBER,
                           x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                           x_rule_count     OUT NOCOPY NUMBER
                          ) IS
    CURSOR okc_rulv_csr (p_rgp_id IN NUMBER,
                         p_rdf_code IN VARCHAR2,
                         p_slh_id   IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            OBJECT1_ID1,
            OBJECT2_ID1,
            OBJECT3_ID1,
            OBJECT1_ID2,
            OBJECT2_ID2,
            OBJECT3_ID2,
            JTOT_OBJECT1_CODE,
            JTOT_OBJECT2_CODE,
            JTOT_OBJECT3_CODE,
            DNZ_CHR_ID,
            RGP_ID,
            PRIORITY,
            STD_TEMPLATE_YN,
            COMMENTS,
            WARN_YN,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            --TEXT,
            RULE_INFORMATION_CATEGORY,
            RULE_INFORMATION1,
            RULE_INFORMATION2,
            RULE_INFORMATION3,
            RULE_INFORMATION4,
            RULE_INFORMATION5,
            RULE_INFORMATION6,
            RULE_INFORMATION7,
            RULE_INFORMATION8,
            RULE_INFORMATION9,
            RULE_INFORMATION10,
            RULE_INFORMATION11,
            RULE_INFORMATION12,
            RULE_INFORMATION13,
            RULE_INFORMATION14,
            RULE_INFORMATION15,
            TEMPLATE_YN,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            DISPLAY_SEQUENCE
     FROM Okc_Rules_V
     WHERE okc_rules_v.rgp_id      = p_rgp_id
     AND   okc_rules_v.object2_id1 = p_slh_id
     AND   RULE_INFORMATION_CATEGORY = DECODE(p_rdf_code,NULL,RULE_INFORMATION_CATEGORY,p_rdf_code);

     l_rulv_rec                  rulv_rec_type;
     i                           NUMBER DEFAULT 0;
     l_proc_name                 VARCHAR2(35) := 'GET_SLL_RULES';
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    -- Get current database values
    OPEN okc_rulv_csr (p_rgpv_rec.id,
                       p_rdf_code,
                       p_slh_id);
    LOOP
    FETCH okc_rulv_csr INTO
              l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              --l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    EXIT WHEN okc_rulv_csr%NOTFOUND;
      i := okc_rulv_csr%RowCount;
      x_rulv_tbl(i) := l_rulv_rec;
    END LOOP;
    CLOSE okc_rulv_csr;
    x_rule_count := i;

    RETURN;

   END get_sll_rules;

------------------------------------------------------------------------------
-- PROCEDURE sync_header_slh_sll
--
--  This procedure synchronizes Header SLH and SLL Rules
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_header_slh_sll(
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_for_line      IN  VARCHAR2, -- DEFAULT 'N',
                         p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                         p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                        ) IS

  l_proc_name          VARCHAR2(35)    := 'SYNC_HEADER_SLH_SLL';
  sync_header_failed   EXCEPTION;

  CURSOR rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT
    id
    ,object_version_number
    ,sfwt_flag
    ,rgd_code
    ,sat_code
    ,rgp_type
    ,cle_id
    ,chr_id
    ,dnz_chr_id
    ,parent_rgp_id
    ,comments
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id     IS NULL
  AND    rgd_code   = 'LALEVL';

  CURSOR orig_rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS

  SELECT id
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id IS NULL
  AND    rgd_code = 'LALEVL';

  --x_new_rgpv_rec      rgpv_rec_type;
  x_new_slh_rulv_rec  rulv_rec_type;

  x_slh_rulv_tbl      rulv_tbl_type;
  x_slh_rule_count    NUMBER;

  x_sll_rulv_tbl      rulv_tbl_type;
  x_sll_rule_count    NUMBER;

  x_rulv_rec          rulv_rec_type;

  l_rebook_rgpv_rec   rgpv_rec_type;
  l_slh_rulv_rec      rulv_rec_type;
  l_sll_rulv_rec      rulv_rec_type;

  l_rebook_rgp_id NUMBER;
  l_orig_rgp_id   NUMBER;

  l_rebook_cle_id NUMBER;
  l_orig_cle_id   NUMBER;

  l_rulv_tbl      rulv_tbl_type;
  i               NUMBER := 0;

  l_rgpv_rec      rgpv_rec_type;
  x_rgpv_rec      rgpv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    FOR rebook_rgp_rec IN rgp_csr(p_rebook_chr_id)  -- Getting Rebook RGP_ID
    LOOP

      OPEN orig_rgp_csr(p_orig_chr_id);      -- Get Original Contract RGP_ID
      FETCH orig_rgp_csr INTO l_orig_rgp_id;
      IF orig_rgp_csr%NOTFOUND THEN -- Header payment added during rebook
         -- Create LALEVL rule group at header
         l_rgpv_rec            := NULL;

         l_rgpv_rec.rgd_code   := 'LALEVL';
         l_rgpv_rec.chr_id     := p_orig_chr_id;
         l_rgpv_rec.dnz_chr_id := p_orig_chr_id;
         l_rgpv_rec.cle_id     := NULL;
         l_rgpv_rec.rgp_type   := 'KRG';

         OKL_RULE_PUB.create_rule_group(
                                      p_api_version     => 1.0,
                                      p_init_msg_list   => OKL_API.G_FALSE,
                                      x_return_status   => x_return_status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      p_rgpv_rec        => l_rgpv_rec,
                                      x_rgpv_rec        => x_rgpv_rec
                                     );

         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            RAISE sync_header_failed;
         END IF;

         l_orig_rgp_id := x_rgpv_rec.id;

      END IF;

      CLOSE orig_rgp_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig RGP ID: ' || l_orig_rgp_id);
      END IF;

      l_rebook_rgpv_rec := rebook_rgp_rec;
      --
      -- Get SLH Rule from Rebook Contract
      --
      Okl_Rule_Apis_Pvt.Get_Contract_Rules(
                                           p_api_version    => 1.0,
                                           p_init_msg_list  => Okl_Api.G_FALSE,
                                           p_rgpv_rec       => l_rebook_rgpv_rec,
                                           p_rdf_code       => 'LASLH',
                                           x_return_status  => x_return_status,
                                           x_msg_count      => x_msg_count,
                                           x_msg_data       => x_msg_data,
                                           x_rulv_tbl       => x_slh_rulv_tbl,
                                           x_rule_count     => x_slh_rule_count
                                          );
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         RAISE sync_header_failed;
      END IF;

      --x_slh_rulv_tbl_out := x_slh_rulv_tbl;
      --x_slh_count        := x_slh_rule_count;

      FOR i IN 1..x_slh_rule_count
      LOOP
         l_slh_rulv_rec            := x_slh_rulv_tbl(i);
         l_slh_rulv_rec.rgp_id     := l_orig_rgp_id;
         l_slh_rulv_rec.dnz_chr_id := p_orig_chr_id;

         Okl_Rule_Pub.create_rule(
                                  p_api_version     => 1.0,
                                  p_init_msg_list   => Okc_Api.G_FALSE,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_rulv_rec        => l_slh_rulv_rec,
                                  x_rulv_rec        => x_new_slh_rulv_rec
                                 );
         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             x_return_status := Okc_Api.G_RET_STS_ERROR;
             RAISE sync_header_failed;
         END IF;

         --
         -- Get SLL Rules from Header for a SLH
         --
         get_sll_rules(
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_rgpv_rec       => l_rebook_rgpv_rec,
                       p_rdf_code       => 'LASLL',
                       p_slh_id         => x_slh_rulv_tbl(i).id,
                       x_rulv_tbl       => x_sll_rulv_tbl,
                       x_rule_count     => x_sll_rule_count
                      );
         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            RAISE sync_header_failed;
         END IF;

         --x_sll_rulv_tbl_out := x_sll_rulv_tbl;
         --x_sll_count        := x_sll_rule_count;

         -- Create a SLL rule under SLH created above
         FOR i IN 1..x_sll_rule_count
         LOOP

            l_sll_rulv_rec             := x_sll_rulv_tbl(i);
            l_sll_rulv_rec.rgp_id      := l_orig_rgp_id;
            l_sll_rulv_rec.object2_id1 := x_new_slh_rulv_rec.id;
            l_sll_rulv_rec.dnz_chr_id  := p_orig_chr_id;

            Okl_Rule_Pub.create_rule(
                                     p_api_version     => 1.0,
                                     p_init_msg_list   => Okc_Api.G_FALSE,
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_rulv_rec        => l_sll_rulv_rec,
                                     x_rulv_rec        => x_rulv_rec
                                    );
               IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                   x_return_status := Okc_Api.G_RET_STS_ERROR;
                   RAISE sync_header_failed;
               END IF;
         END LOOP; -- SLL

      END LOOP; -- SLH

    END LOOP;

  EXCEPTION
    WHEN sync_header_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;

  END sync_header_slh_sll;

------------------------------------------------------------------------------
-- PROCEDURE sync_slh_sll
--
--  This procedure synchronizes SLH and SLL Rules
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_slh_sll(
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_for_line      IN  VARCHAR2, -- DEFAULT 'N',
                         p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                         p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                        ) IS

  l_proc_name   VARCHAR2(35)    := 'SYNC_SLH_SLL';
  sync_failed   EXCEPTION;

  x_new_rgpv_rec      rgpv_rec_type;
  x_new_slh_rulv_rec  rulv_rec_type;

  x_slh_rulv_tbl      rulv_tbl_type;
  x_slh_rule_count    NUMBER;

  x_sll_rulv_tbl      rulv_tbl_type;
  x_sll_rule_count    NUMBER;

  x_rulv_rec          rulv_rec_type;

  l_rebook_rgpv_rec   rgpv_rec_type;
  l_slh_rulv_rec      rulv_rec_type;
  l_sll_rulv_rec      rulv_rec_type;

  l_rebook_rgp_id NUMBER;
  l_orig_rgp_id   NUMBER;

  l_rebook_cle_id NUMBER;
  l_orig_cle_id   NUMBER;

  l_rulv_tbl      rulv_tbl_type;
  i               NUMBER := 0;

  CURSOR rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT
    id
    ,object_version_number
    ,sfwt_flag
    ,rgd_code
    ,sat_code
    ,rgp_type
    ,cle_id
    ,chr_id
    ,dnz_chr_id
    ,parent_rgp_id
    ,comments
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    rgd_code   = 'LALEVL';

  CURSOR orig_cle_csr(p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT orig_system_id1
  FROM   okc_k_lines_v
  WHERE  id = p_cle_id;

  CURSOR orig_rgp_csr(p_cle_id OKC_K_LINES_V.ID%TYPE,
                      p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    ((cle_id = p_cle_id AND p_cle_id IS NOT NULL)
          OR
          cle_id IS NULL AND p_cle_id IS NULL)
  AND    rgd_code = 'LALEVL';

  CURSOR del_rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    rgd_code   = 'LALEVL';

  CURSOR rule_csr(p_rgp_id NUMBER) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  rgp_id = p_rgp_id;

  --Bug# 4899328
  l_lalevl_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
  x_lalevl_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

/*
      -- Delete SLH, SLL from Original Contract
      i := 1;

      FOR del_rgp_rec IN del_rgp_csr(p_orig_chr_id)
      LOOP
         FOR rule_rec IN rule_csr(del_rgp_rec.id)
         LOOP
            l_rulv_tbl(i).id := rule_rec.id;
            i := i+ 1;
         END LOOP;
      END LOOP;

      okl_rule_pub.delete_rule(
                               p_api_version    => 1.0,
                               p_init_msg_list  => OKC_API.G_FALSE,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_rulv_tbl       => l_rulv_tbl
                              );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_failed;
      END IF;
*/

    FOR rebook_rgp_rec IN rgp_csr(p_rebook_chr_id)  -- Getting Rebook RGP_ID
    LOOP
      l_orig_cle_id := NULL;
      IF rebook_rgp_rec.cle_id IS NOT NULL THEN     -- For line level rule group get Original Contract Line No.
        OPEN orig_cle_csr(rebook_rgp_rec.cle_id);
        FETCH orig_cle_csr INTO l_orig_cle_id;
        CLOSE orig_cle_csr;

      ELSE -- Header level payment
        sync_header_slh_sll(
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_for_line      => 'N',
                            p_rebook_chr_id => p_rebook_chr_id,
                            p_orig_chr_id   => p_orig_chr_id
                           );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE sync_failed;
        END IF;
        GOTO process_next;

      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Rebook CLE ID: '||rebook_rgp_rec.id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig CLE ID: '|| l_orig_cle_id);
      END IF;

      IF (l_orig_cle_id IS NULL) THEN
         GOTO process_next;
      END IF;

      --Bug# 4899328
      l_orig_rgp_id := NULL;
      OPEN orig_rgp_csr(l_orig_cle_id,
                        p_orig_chr_id);      -- Get Original Contract RGP_ID
      FETCH orig_rgp_csr INTO l_orig_rgp_id;
      CLOSE orig_rgp_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig RGP ID: ' || l_orig_rgp_id);
      END IF;

      l_rebook_rgpv_rec := rebook_rgp_rec;
      --
      -- Get SLH Rule from Rebook Contract
      --
      Okl_Rule_Apis_Pvt.Get_Contract_Rules(
                                           p_api_version    => 1.0,
                                           p_init_msg_list  => Okl_Api.G_FALSE,
                                           p_rgpv_rec       => l_rebook_rgpv_rec,
                                           p_rdf_code       => 'LASLH',
                                           x_return_status  => x_return_status,
                                           x_msg_count      => x_msg_count,
                                           x_msg_data       => x_msg_data,
                                           x_rulv_tbl       => x_slh_rulv_tbl,
                                           x_rule_count     => x_slh_rule_count
                                          );
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         RAISE sync_failed;
      END IF;

      --x_slh_rulv_tbl_out := x_slh_rulv_tbl;
      --x_slh_count        := x_slh_rule_count;

      --Bug# 4899328
      IF l_orig_rgp_id IS NULL THEN

        l_lalevl_rgpv_rec.id := null;
        l_lalevl_rgpv_rec.rgd_code := 'LALEVL';
        l_lalevl_rgpv_rec.dnz_chr_id := p_orig_chr_id;
        l_lalevl_rgpv_rec.cle_id := l_orig_cle_id;
        l_lalevl_rgpv_rec.rgp_type := 'KRG';

        OKL_RULE_PUB.create_rule_group(
          p_api_version    => 1.0,
          p_init_msg_list  => Okc_Api.G_False,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rgpv_rec       => l_lalevl_rgpv_rec,
          x_rgpv_rec       => x_lalevl_rgpv_rec);

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           RAISE sync_failed;
        END IF;

        l_orig_rgp_id := x_lalevl_rgpv_rec.id;

      END IF;
      --Bug# 4899328

      FOR i IN 1..x_slh_rule_count
      LOOP
         l_slh_rulv_rec            := x_slh_rulv_tbl(i);
         l_slh_rulv_rec.rgp_id     := l_orig_rgp_id;
         l_slh_rulv_rec.dnz_chr_id := p_orig_chr_id;

         Okl_Rule_Pub.create_rule(
                                  p_api_version     => 1.0,
                                  p_init_msg_list   => Okc_Api.G_FALSE,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_rulv_rec        => l_slh_rulv_rec,
                                  x_rulv_rec        => x_new_slh_rulv_rec
                                 );
         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             x_return_status := Okc_Api.G_RET_STS_ERROR;
             RAISE sync_failed;
         END IF;

         --
         -- Get SLL Rules from Header for a SLH
         --
         get_sll_rules(
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_rgpv_rec       => l_rebook_rgpv_rec,
                       p_rdf_code       => 'LASLL',
                       p_slh_id         => x_slh_rulv_tbl(i).id,
                       x_rulv_tbl       => x_sll_rulv_tbl,
                       x_rule_count     => x_sll_rule_count
                      );
         IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            RAISE sync_failed;
         END IF;

         --x_sll_rulv_tbl_out := x_sll_rulv_tbl;
         --x_sll_count        := x_sll_rule_count;

         -- Create a SLL rule under SLH created above
         FOR i IN 1..x_sll_rule_count
         LOOP

            l_sll_rulv_rec             := x_sll_rulv_tbl(i);
            l_sll_rulv_rec.rgp_id      := l_orig_rgp_id;
            l_sll_rulv_rec.object2_id1 := x_new_slh_rulv_rec.id;
            l_sll_rulv_rec.dnz_chr_id  := p_orig_chr_id;

            Okl_Rule_Pub.create_rule(
                                     p_api_version     => 1.0,
                                     p_init_msg_list   => Okc_Api.G_FALSE,
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_rulv_rec        => l_sll_rulv_rec,
                                     x_rulv_rec        => x_rulv_rec
                                    );
               IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                   x_return_status := Okc_Api.G_RET_STS_ERROR;
                   RAISE sync_failed;
               END IF;
         END LOOP; -- SLL

      END LOOP; -- SLH

    <<process_next>>
    NULL;
    END LOOP;

  EXCEPTION
    WHEN sync_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_slh_sll;

------------------------------------------------------------------------------
-- PROCEDURE sync_party_role
--
--  This procedure synchronizes party roles created during rebook process
--  Sunchronize Lease Vendor (OKX_VENDOR) only
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_party_role(
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                           ) IS

  CURSOR rebook_party_csr (p_rebook_chr_id OKC_K_HEADERS_B.ID%TYPE,
                           p_orig_chr_id   OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT rbk.id,
         rbk.object1_id1,
         rbk.object1_id2,
         rbk.jtot_object1_code,
         rbk.rle_code
  FROM   okc_k_party_roles_b rbk
  WHERE  rbk.chr_id            = p_rebook_chr_id
  AND    rbk.jtot_object1_code = 'OKX_VENDOR'  -- Bug# 3311403
  AND    NOT EXISTS (
                     SELECT 'Y'
                     FROM   okc_k_party_roles_b orig
                     WHERE  orig.object1_id1        = rbk.object1_id1
                     AND    orig.object1_id2        = rbk.object1_id2
                     AND    orig.jtot_object1_code  = rbk.jtot_object1_code
                     AND    orig.rle_code           = rbk.rle_code
                     AND    orig.chr_id             = p_orig_chr_id
                     AND    orig.jtot_object1_code  = 'OKX_VENDOR'  -- Bug# 3311403
                    );

  CURSOR party_rule_csr (p_chr_id NUMBER,
                         p_cpl_id NUMBER) IS
  SELECT rgp_id
  FROM   okc_rg_party_roles_v
  WHERE  cpl_id     = p_cpl_id
  AND    dnz_chr_id = p_chr_id;

  l_proc_name VARCHAR2(35) := 'SYNC_PARTY_ROLE';
  x_cpl_id   NUMBER;
  x_rgp_id   NUMBER;

  CURSOR rbk_evg_hdr_csr (p_chr_id NUMBER) IS
  SELECT *
  FROM   okl_party_payment_hdr
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id IS NULL;

  CURSOR orig_evg_hdr_csr (p_chr_id NUMBER) IS
  SELECT id
  FROM   okl_party_payment_hdr
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id IS NULL;

  CURSOR orig_party_csr (p_chr_id NUMBER) IS
  SELECT party.id party_id,
         party.object1_id1,
         pyd.ID pyd_id,
         pyd.CPL_ID,
         pyd.VENDOR_ID,
         pyd.PAY_SITE_ID,
         pyd.PAYMENT_TERM_ID,
         pyd.PAYMENT_METHOD_CODE,
         pyd.PAY_GROUP_CODE,
         pyd.PAYMENT_HDR_ID,
         pyd.PAYMENT_START_DATE,
         pyd.PAYMENT_FREQUENCY,
         pyd.REMIT_DAYS,
         pyd.DISBURSEMENT_BASIS,
         pyd.DISBURSEMENT_FIXED_AMOUNT,
         pyd.DISBURSEMENT_PERCENT,
         pyd.PROCESSING_FEE_BASIS,
         pyd.PROCESSING_FEE_FIXED_AMOUNT,
         pyd.PROCESSING_FEE_PERCENT,
         pyd.PAYMENT_BASIS
  FROM   okc_k_party_roles_b party,
         okl_party_payment_dtls pyd
  WHERE  party.dnz_chr_id = p_chr_id
  AND    party.rle_code   = 'OKL_VENDOR'
  AND    party.cle_id     IS NULL
  AND    party.id         = pyd.cpl_id (+);

  CURSOR rbk_evg_dtl_csr (p_pmnt_hdr_id NUMBER,
                          p_vendor_id   NUMBER) IS
  select *
  from   okl_party_payment_dtls
  where  payment_hdr_id = p_pmnt_hdr_id
  and    vendor_id      = p_vendor_id;

  rbk_evg_dtl_rec rbk_evg_dtl_csr%ROWTYPE;

  l_orig_evg_hdr_id NUMBER;
  l_rbk_evg_hdr_id  NUMBER;

  l_pphv_rec        okl_party_payments_pvt.pphv_rec_type;
  x_pphv_rec        okl_party_payments_pvt.pphv_rec_type;

  l_ppydv_c_rec       okl_party_payments_pvt.ppydv_rec_type;
  l_ppydv_u_rec       okl_party_payments_pvt.ppydv_rec_type;
  x_ppydv_rec       okl_party_payments_pvt.ppydv_rec_type;

  sync_party_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    -- Sync evergreen passthru at contract header and party
    FOR rbk_evg_hdr_rec IN rbk_evg_hdr_csr (p_rebook_chr_id)
    LOOP
       l_rbk_evg_hdr_id := rbk_evg_hdr_rec.id; -- saved for use during detail update/create
       OPEN orig_evg_hdr_csr (p_orig_chr_id);
       FETCH orig_evg_hdr_csr INTO l_orig_evg_hdr_id;
       IF orig_evg_hdr_csr%NOTFOUND THEN
          -- create header rec
          l_pphv_rec.dnz_chr_id              := p_orig_chr_id;
          l_pphv_rec.payout_basis            := rbk_evg_hdr_rec.payout_basis;
          l_pphv_rec.payout_basis_formula    := rbk_evg_hdr_rec.payout_basis_formula;
          l_pphv_rec.passthru_stream_type_id := rbk_evg_hdr_rec.passthru_stream_type_id;
          --added by rkuttiya for bug #6873960
          l_pphv_rec.effective_from          := rbk_evg_hdr_rec.effective_from;
          l_pphv_rec.passthru_term           := rbk_evg_hdr_rec.passthru_term;
          --

          okl_party_payments_pvt.create_party_payment_hdr(
                p_api_version       => 1.0,
                p_init_msg_list     => OKL_API.G_FALSE,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_pphv_rec          => l_pphv_rec,
                x_pphv_rec          => x_pphv_rec
               );
          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_party_failed;
          END IF;
       ELSE
          -- Update header rec
          l_pphv_rec.id                      := l_orig_evg_hdr_id;
          l_pphv_rec.dnz_chr_id              := p_orig_chr_id;
          l_pphv_rec.payout_basis            := rbk_evg_hdr_rec.payout_basis;
          l_pphv_rec.payout_basis_formula    := rbk_evg_hdr_rec.payout_basis_formula;
          l_pphv_rec.passthru_stream_type_id := rbk_evg_hdr_rec.passthru_stream_type_id;
          okl_party_payments_pvt.update_party_payment_hdr(
                p_api_version       => 1.0,
                p_init_msg_list     => OKL_API.G_FALSE,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_pphv_rec          => l_pphv_rec,
                x_pphv_rec          => x_pphv_rec
               );
          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_party_failed;
          END IF;
       END IF;
       CLOSE orig_evg_hdr_csr;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_pphv_rec.id: '||x_pphv_rec.id);
    END IF;
    IF (l_rbk_evg_hdr_id IS NOT NULL) THEN -- header evergreen exists
       -- Update vendor evergreen detail if any
       FOR orig_party_rec IN orig_party_csr (p_orig_chr_id)
       LOOP
          IF (orig_party_rec.payment_hdr_id IS NOT NULL) THEN

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update party payment detail for Vendor: '||orig_party_rec.object1_id1);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'orig_party_rec.payment_hdr_id: '||orig_party_rec.payment_hdr_id);
             END IF;
             -- update evg detail
             --Bug# 4880939: Changed Open/Fetch to For Loop
             /*
             OPEN rbk_evg_dtl_csr (l_rbk_evg_hdr_id,
                                   orig_party_rec.object1_id1
                                  );
             FETCH rbk_evg_dtl_csr INTO rbk_evg_dtl_rec;
             CLOSE rbk_evg_dtl_csr;
             */

            FOR rbk_evg_dtl_rec IN rbk_evg_dtl_csr (l_rbk_evg_hdr_id,
                                                    orig_party_rec.object1_id1)
            LOOP

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'orig_party_rec.pyd_id: '||orig_party_rec.pyd_id);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.pay_site_id: '||rbk_evg_dtl_rec.pay_site_id);
             END IF;


             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.remit_days: '||rbk_evg_dtl_rec.remit_days);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.payment_method_code: '||rbk_evg_dtl_rec.payment_method_code);
             END IF;
             l_ppydv_u_rec.id                          := orig_party_rec.pyd_id;
             l_ppydv_u_rec.pay_site_id                 := rbk_evg_dtl_rec.pay_site_id;
             l_ppydv_u_rec.payment_term_id             := rbk_evg_dtl_rec.payment_term_id;
             l_ppydv_u_rec.payment_method_code         := rbk_evg_dtl_rec.payment_method_code;
             l_ppydv_u_rec.pay_group_code              := rbk_evg_dtl_rec.pay_group_code;
             l_ppydv_u_rec.payment_start_date          := rbk_evg_dtl_rec.payment_start_date;
             l_ppydv_u_rec.payment_frequency           := rbk_evg_dtl_rec.payment_frequency;
             l_ppydv_u_rec.remit_days                  := rbk_evg_dtl_rec.remit_days;
             l_ppydv_u_rec.disbursement_basis          := rbk_evg_dtl_rec.disbursement_basis;
             l_ppydv_u_rec.disbursement_fixed_amount   := rbk_evg_dtl_rec.disbursement_fixed_amount;
             l_ppydv_u_rec.disbursement_percent        := rbk_evg_dtl_rec.disbursement_percent;
             l_ppydv_u_rec.processing_fee_basis        := rbk_evg_dtl_rec.processing_fee_basis;
             l_ppydv_u_rec.processing_fee_fixed_amount := rbk_evg_dtl_rec.processing_fee_fixed_amount;
             l_ppydv_u_rec.processing_fee_percent      := rbk_evg_dtl_rec.processing_fee_percent;
             l_ppydv_u_rec.payment_basis               := rbk_evg_dtl_rec.payment_basis;

             okl_party_payments_pvt.update_party_payment_dtls(
                   p_api_version      => 1.0,
                   p_init_msg_list    => OKL_API.G_FALSE,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_ppydv_rec        => l_ppydv_u_rec,
                   x_ppydv_rec        => x_ppydv_rec
                  );

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update Status: '||x_return_status);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_ppydv_rec.id: '||x_ppydv_rec.id);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_party_failed;
             END IF;
            END LOOP;
            --Bug# 4880939
          ELSE
             -- create evg detail

             l_ppydv_c_rec := NULL;
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Create party payment detail for Vendor: '||orig_party_rec.object1_id1);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'orig_party_rec.payment_hdr_id: '||orig_party_rec.payment_hdr_id);
             END IF;
             -- update evg detail
             --Bug# 4880939: Changed Open/Fetch to For Loop
             /*
             OPEN rbk_evg_dtl_csr (l_rbk_evg_hdr_id,
                                   orig_party_rec.object1_id1
                                  );
             FETCH rbk_evg_dtl_csr INTO rbk_evg_dtl_rec;
             CLOSE rbk_evg_dtl_csr;
             */

            FOR rbk_evg_dtl_rec IN rbk_evg_dtl_csr (l_rbk_evg_hdr_id,
                                                    orig_party_rec.object1_id1)
            LOOP

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'orig_party_rec.pyd_id: '||orig_party_rec.pyd_id);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.pay_site_id: '||rbk_evg_dtl_rec.pay_site_id);
             END IF;


             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.remit_days: '||rbk_evg_dtl_rec.remit_days);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rbk_evg_dtl_rec.payment_method_code: '||rbk_evg_dtl_rec.payment_method_code);
             END IF;

             --l_ppydv_c_rec.object_version_number       := 1;
             --rkuttiya added for bug 6873960
             l_ppydv_c_rec.payment_hdr_id              := x_pphv_rec.id ;
             l_ppydv_c_rec.cpl_id                      := orig_party_rec.party_id;
             l_ppydv_c_rec.vendor_id                   := orig_party_rec.object1_id1;
             l_ppydv_c_rec.pay_site_id                 := rbk_evg_dtl_rec.pay_site_id;
             l_ppydv_c_rec.payment_term_id             := rbk_evg_dtl_rec.payment_term_id;
             l_ppydv_c_rec.payment_method_code         := rbk_evg_dtl_rec.payment_method_code;
             l_ppydv_c_rec.pay_group_code              := rbk_evg_dtl_rec.pay_group_code;
             l_ppydv_c_rec.payment_start_date          := rbk_evg_dtl_rec.payment_start_date;
             l_ppydv_c_rec.payment_frequency           := rbk_evg_dtl_rec.payment_frequency;
             l_ppydv_c_rec.remit_days                  := rbk_evg_dtl_rec.remit_days;
             l_ppydv_c_rec.disbursement_basis          := rbk_evg_dtl_rec.disbursement_basis;
             l_ppydv_c_rec.disbursement_fixed_amount   := rbk_evg_dtl_rec.disbursement_fixed_amount;
             l_ppydv_c_rec.disbursement_percent        := rbk_evg_dtl_rec.disbursement_percent;
             l_ppydv_c_rec.processing_fee_basis        := rbk_evg_dtl_rec.processing_fee_basis;
             l_ppydv_c_rec.processing_fee_fixed_amount := rbk_evg_dtl_rec.processing_fee_fixed_amount;
             l_ppydv_c_rec.processing_fee_percent      := rbk_evg_dtl_rec.processing_fee_percent;
             l_ppydv_c_rec.payment_basis               := rbk_evg_dtl_rec.payment_basis;

             okl_party_payments_pvt.create_party_payment_dtls(
                   p_api_version      => 1.0,
                   p_init_msg_list    => OKL_API.G_FALSE,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_ppydv_rec        => l_ppydv_c_rec,
                   x_ppydv_rec        => x_ppydv_rec
                  );

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Create Status: '||x_return_status);
               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_ppydv_rec.id: '||x_ppydv_rec.id);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_party_failed;
             END IF;
           END LOOP;
           --Bug# 4880939
          END IF;
       END LOOP;
    END IF;

    FOR rebook_party_rec IN rebook_party_csr (p_rebook_chr_id,
                                              p_orig_chr_id)
    LOOP

       okl_copy_contract_pub.copy_party_roles(
                                              p_api_version     => 1.0,
                                              p_init_msg_list   => OKL_API.G_FALSE,
                                              x_return_status   => x_return_status,
                                              x_msg_count       => x_msg_count,
                                              x_msg_data        => x_msg_data,
                                              p_cpl_id          => rebook_party_rec.id,
                                              p_cle_id          => NULL,
                                              p_chr_id          => p_orig_chr_id,
                                              p_rle_code        => rebook_party_rec.rle_code,
                                              x_cpl_id	        => x_cpl_id
                                             );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE sync_party_failed;
       END IF;

       FOR party_rule_rec IN party_rule_csr (p_rebook_chr_id,
                                             rebook_party_rec.id)
       LOOP
          --
          -- Now copy Rules attached to the party copied above
          --
          okl_copy_contract_pub.copy_rules (
	                                    p_api_version       => 1.0,
                                            p_init_msg_list	=> OKL_API.G_FALSE,
                                            x_return_status 	=> x_return_status,
                                            x_msg_count     	=> x_msg_count,
                                            x_msg_data      	=> x_msg_data,
                                            p_rgp_id	      	=> party_rule_rec.rgp_id,
                                            p_cle_id		=> NULL,
                                            p_chr_id	        => p_orig_chr_id,
	                                    p_to_template_yn    => 'N',
                                            x_rgp_id		=> x_rgp_id
                                           );

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_party_failed;
          END IF;
       END LOOP; -- rule

    END LOOP; -- role

  EXCEPTION
    WHEN sync_party_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_party_role;

------------------------------------------------------------------------------
-- PROCEDURE sync_header_values
--
--  This procedure synchronizes Rebook and Original Contract Header Values
--  . Change Due Date
--  . Change Start Date
--  . Extend Term
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_header_values(
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                              ) IS

  CURSOR header_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT start_date,
         end_date,
         term_duration,
         pre_tax_yield,
         after_tax_yield,
         target_pre_tax_yield,
         target_after_tax_yield,
         pre_tax_irr,
         after_tax_irr,
         implicit_interest_rate,
         --Bug# 4558486
         khr_attribute_category,
         khr_attribute1,
         khr_attribute2,
         khr_attribute3,
         khr_attribute4,
         khr_attribute5,
         khr_attribute6,
         khr_attribute7,
         khr_attribute8,
         khr_attribute9,
         khr_attribute10,
         khr_attribute11,
         khr_attribute12,
         khr_attribute13,
         khr_attribute14,
         khr_attribute15
         --Bug# 4558486
         -- sjalasut, added for rebook change control enhancement. START
         ,date_tradein
         ,tradein_amount
         ,tradein_description
         -- sjalasut, added for rebook change control enhancement. END
         --Bug# 8652738
         ,short_description
         ,description
         ,cust_po_number
         ,amd_code
         ,bill_to_site_use_id
         ,expected_delivery_date
         ,accepted_date
         ,date_signed
         ,credit_act_yn
         ,assignable_yn
         --Bug# 8652738
  FROM   okl_k_headers_full_v
  WHERE  id = p_chr_id;

  l_proc_name   VARCHAR2(35)    := 'SYNC_HEADER_VALUES';
  l_khrv_rec    khrv_rec_type;
  l_chrv_rec    chrv_rec_type;
  x_khrv_rec    khrv_rec_type;
  x_chrv_rec    chrv_rec_type;

  sync_failed   EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     l_khrv_rec := get_khrv_rec(
                                p_khr_id        => p_orig_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_failed;
     END IF;

     l_chrv_rec := get_chrv_rec(
                                p_chr_id        => p_orig_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_failed;
     END IF;

     FOR header_rec IN header_csr(p_rebook_chr_id)
     LOOP
        --l_khrv_rec.id := p_orig_chr_id;
        --l_chrv_rec.id := p_orig_chr_id;

        l_khrv_rec.term_duration := header_rec.term_duration;

        l_khrv_rec.pre_tax_yield          := header_rec.pre_tax_yield;
        l_khrv_rec.after_tax_yield        := header_rec.after_tax_yield;
        l_khrv_rec.target_pre_tax_yield   := header_rec.target_pre_tax_yield;
        l_khrv_rec.target_after_tax_yield := header_rec.target_after_tax_yield;
        l_khrv_rec.pre_tax_irr            := header_rec.pre_tax_irr;
        l_khrv_rec.after_tax_irr          := header_rec.after_tax_irr;
        l_khrv_rec.implicit_interest_rate := header_rec.implicit_interest_rate;

        --Bug# 4558486
        l_khrv_rec.attribute_category := header_rec.khr_attribute_category;
        l_khrv_rec.attribute1         := header_rec.khr_attribute1;
        l_khrv_rec.attribute2         := header_rec.khr_attribute2;
        l_khrv_rec.attribute3         := header_rec.khr_attribute3;
        l_khrv_rec.attribute4         := header_rec.khr_attribute4;
        l_khrv_rec.attribute5         := header_rec.khr_attribute5;
        l_khrv_rec.attribute6         := header_rec.khr_attribute6;
        l_khrv_rec.attribute7         := header_rec.khr_attribute7;
        l_khrv_rec.attribute8         := header_rec.khr_attribute8;
        l_khrv_rec.attribute9         := header_rec.khr_attribute9;
        l_khrv_rec.attribute10        := header_rec.khr_attribute10;
        l_khrv_rec.attribute11        := header_rec.khr_attribute11;
        l_khrv_rec.attribute12        := header_rec.khr_attribute12;
        l_khrv_rec.attribute13        := header_rec.khr_attribute13;
        l_khrv_rec.attribute14        := header_rec.khr_attribute14;
        l_khrv_rec.attribute15        := header_rec.khr_attribute15;
        --Bug# 4558486

        -- sjalasut, added for rebook change control enhancement. START
        l_khrv_rec.date_tradein := header_rec.date_tradein;
        l_khrv_rec.tradein_amount := header_rec.tradein_amount;
        l_khrv_rec.tradein_description := header_rec.tradein_description;
        -- sjalasut, added for rebook change control enhancement. END

        l_chrv_rec.start_date    := header_rec.start_date;
        l_chrv_rec.end_date      := header_rec.end_date;

        --Bug# 8652738
        l_chrv_rec.short_description        := header_rec.short_description;
        l_chrv_rec.description              := header_rec.description;
        l_chrv_rec.cust_po_number           := header_rec.cust_po_number;
        l_khrv_rec.amd_code                 := header_rec.amd_code;
        l_chrv_rec.bill_to_site_use_id      := header_rec.bill_to_site_use_id;
        l_khrv_rec.expected_delivery_date   := header_rec.expected_delivery_date;
        l_khrv_rec.accepted_date            := header_rec.accepted_date;
        l_chrv_rec.date_signed              := header_rec.date_signed;
        l_khrv_rec.credit_act_yn            := header_rec.credit_act_yn;
        l_khrv_rec.assignable_yn            := header_rec.assignable_yn;
        --Bug# 8652738

        okl_contract_pub.update_contract_header(
                                                p_api_version        => 1.0,
                                                p_init_msg_list      => OKC_API.G_FALSE,
                                                x_return_status      => x_return_status,
                                                x_msg_count          => x_msg_count,
                                                x_msg_data           => x_msg_data,
                                                p_restricted_update  => OKC_API.G_FALSE,
                                                p_chrv_rec           => l_chrv_rec,
                                                p_khrv_rec           => l_khrv_rec,
                                                x_chrv_rec           => x_chrv_rec,
                                                x_khrv_rec           => x_khrv_rec
                                               );
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            x_return_status := Okc_Api.G_RET_STS_ERROR;
            RAISE sync_failed;
        END IF;

     END LOOP;

     RETURN;

  EXCEPTION
    WHEN sync_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_header_values;

  PROCEDURE sync_passthru_party(
                                x_return_status OUT NOCOPY VARCHAR2
                               ) IS
  BEGIN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
  END sync_passthru_party;

------------------------------------------------------------------------------
-- PROCEDURE process_pth_detail
--
--  This procedure creates/updates passthru detail
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE process_pth_detail(
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_orig_chr_id   IN  NUMBER,
                               p_orig_cle_id   IN  NUMBER,
                               p_orig_cpl_id   IN  NUMBER,
                               p_vendor_id     IN  OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE,
                               p_rbk_chr_id    IN  NUMBER,
                               p_rbk_cle_id    IN  NUMBER,
                               p_rbk_cpl_id    IN  NUMBER
                              ) IS

   CURSOR rbk_pth_detail_csr (p_cle_id NUMBER,
                              p_cpl_id NUMBER) IS
   SELECT hdr.id hdr_id,
          hdr.passthru_term,
          dtl.*
   FROM   okl_party_payment_dtls dtl,
          okl_party_payment_hdr hdr
   WHERE  cpl_id         = p_cpl_id
   AND    cle_id         = p_cle_id
   AND    hdr.id         = dtl.payment_hdr_id;

   CURSOR orig_pth_detail_csr (p_vendor_id OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE,
                               p_cle_id    NUMBER,
                               p_term      OKL_PARTY_PAYMENT_HDR.PASSTHRU_TERM%TYPE) IS
   SELECT dtl.*
   FROM   okl_party_payment_dtls dtl,
          okl_party_payment_hdr hdr
   WHERE  vendor_id         = p_vendor_id
   AND    cle_id            = p_cle_id
   AND    hdr.passthru_term = p_term
   AND    hdr.id            = dtl.payment_hdr_id;

   orig_pth_detail_rec orig_pth_detail_csr%ROWTYPE;

   CURSOR orig_pth_hdr_csr (p_cle_id NUMBER,
                            p_term   OKL_PARTY_PAYMENT_HDR.PASSTHRU_TERM%TYPE) IS
   SELECT id
   FROM   okl_party_payment_hdr
   WHERE  cle_id        = p_cle_id
   AND    passthru_term = p_term;

   l_orig_pth_hdr_id NUMBER;

   process_pth_failed EXCEPTION;

   l_proc_name VARCHAR2(35) := 'PROCESS_PTH_DETAIL';
   l_ppydv_rec okl_party_payments_pvt.ppydv_rec_type;
   x_ppydv_rec okl_party_payments_pvt.ppydv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    FOR rbk_pth_detail_rec IN rbk_pth_detail_csr(p_cle_id => p_rbk_cle_id,
                                                 p_cpl_id => p_rbk_cpl_id)
    LOOP
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>> pth rebook detail...term :'||rbk_pth_detail_rec.passthru_term);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>> pth rebook detail...cle  :'||p_orig_cle_id);
       END IF;
       OPEN orig_pth_detail_csr (p_vendor_id => p_vendor_id,
                                 p_cle_id    => p_orig_cle_id,
                                 p_term      => rbk_pth_detail_rec.passthru_term);
       FETCH orig_pth_detail_csr INTO orig_pth_detail_rec;
       IF orig_pth_detail_csr%NOTFOUND THEN
          -- Create passthru detail
          OPEN orig_pth_hdr_csr(p_cle_id => p_orig_cle_id,
                                p_term   => rbk_pth_detail_rec.passthru_term);
          FETCH orig_pth_hdr_csr INTO l_orig_pth_hdr_id;
          CLOSE orig_pth_hdr_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>>> pth orig detail not found.');
          END IF;
          l_ppydv_rec.id                            := NULL;
          l_ppydv_rec.cpl_id                        := p_orig_cpl_id;
          l_ppydv_rec.vendor_id                     := p_vendor_id;
          l_ppydv_rec.payment_hdr_id                := l_orig_pth_hdr_id;
          l_ppydv_rec.pay_site_id                   := rbk_pth_detail_rec.pay_site_id;
          l_ppydv_rec.payment_term_id               := rbk_pth_detail_rec.payment_term_id;
          l_ppydv_rec.payment_method_code           := rbk_pth_detail_rec.payment_method_code;
          l_ppydv_rec.pay_group_code                := rbk_pth_detail_rec.pay_group_code;
	  l_ppydv_rec.payment_start_date            := rbk_pth_detail_rec.payment_start_date;
	  l_ppydv_rec.payment_frequency             := rbk_pth_detail_rec.payment_frequency;
	  l_ppydv_rec.remit_days                    := rbk_pth_detail_rec.remit_days;
	  l_ppydv_rec.disbursement_basis            := rbk_pth_detail_rec.disbursement_basis;
	  l_ppydv_rec.disbursement_fixed_amount     := rbk_pth_detail_rec.disbursement_fixed_amount;
	  l_ppydv_rec.disbursement_percent          := rbk_pth_detail_rec.disbursement_percent;
	  l_ppydv_rec.processing_fee_basis          := rbk_pth_detail_rec.processing_fee_basis;
	  l_ppydv_rec.processing_fee_fixed_amount   := rbk_pth_detail_rec.processing_fee_fixed_amount;
	  l_ppydv_rec.processing_fee_percent        := rbk_pth_detail_rec.processing_fee_percent;
	  l_ppydv_rec.payment_basis                 := rbk_pth_detail_rec.payment_basis;

          okl_party_payments_pvt.create_party_payment_dtls(
               p_api_version    => 1.0,
               p_init_msg_list  => OKL_API.G_FALSE,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_ppydv_rec      => l_ppydv_rec,
               x_ppydv_rec      => x_ppydv_rec
              );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>>> Pth detail created: '||x_return_status);
          END IF;

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE process_pth_failed;
          END IF;
       ELSE
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>>> pth orig detail...header_id: '||orig_pth_detail_rec.payment_hdr_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>>> pth orig detail...id       : '||orig_pth_detail_rec.id);
          END IF;
          l_ppydv_rec.id                            := orig_pth_detail_rec.id;
          l_ppydv_rec.cpl_id                        := p_orig_cpl_id;
          l_ppydv_rec.vendor_id                     := p_vendor_id;
          l_ppydv_rec.payment_hdr_id                := orig_pth_detail_rec.payment_hdr_id;
          l_ppydv_rec.pay_site_id                   := rbk_pth_detail_rec.pay_site_id;
          l_ppydv_rec.payment_term_id               := rbk_pth_detail_rec.payment_term_id;
          l_ppydv_rec.payment_method_code           := rbk_pth_detail_rec.payment_method_code;
          l_ppydv_rec.pay_group_code                := rbk_pth_detail_rec.pay_group_code;
	  l_ppydv_rec.payment_start_date            := rbk_pth_detail_rec.payment_start_date;
	  l_ppydv_rec.payment_frequency             := rbk_pth_detail_rec.payment_frequency;
	  l_ppydv_rec.remit_days                    := rbk_pth_detail_rec.remit_days;
	  l_ppydv_rec.disbursement_basis            := rbk_pth_detail_rec.disbursement_basis;
	  l_ppydv_rec.disbursement_fixed_amount     := rbk_pth_detail_rec.disbursement_fixed_amount;
	  l_ppydv_rec.disbursement_percent          := rbk_pth_detail_rec.disbursement_percent;
	  l_ppydv_rec.processing_fee_basis          := rbk_pth_detail_rec.processing_fee_basis;
	  l_ppydv_rec.processing_fee_fixed_amount   := rbk_pth_detail_rec.processing_fee_fixed_amount;
	  l_ppydv_rec.processing_fee_percent        := rbk_pth_detail_rec.processing_fee_percent;
	  l_ppydv_rec.payment_basis                 := rbk_pth_detail_rec.payment_basis;

          okl_party_payments_pvt.update_party_payment_dtls(
               p_api_version    => 1.0,
               p_init_msg_list  => OKL_API.G_FALSE,
               x_return_status  => x_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_ppydv_rec      => l_ppydv_rec,
               x_ppydv_rec      => x_ppydv_rec
              );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>>>> Pth detail updated: '||x_return_status);
          END IF;

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE process_pth_failed;
          END IF;
          -- update passthru detail
       END IF;
       CLOSE orig_pth_detail_csr;
    END LOOP; -- rbk_pth_detail_csr

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_proc_name ---> done');
    END IF;

EXCEPTION

  WHEN process_pth_failed THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
END process_pth_detail;

------------------------------------------------------------------------------
-- PROCEDURE sync_passthru_detail
--
--  This procedure synchronizes passthru line detail and corresponding vendor
--  and vendor level parameters as well
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE sync_passthru_detail(
                   x_return_status OUT NOCOPY VARCHAR2,
                   x_msg_count     OUT NOCOPY NUMBER,
                   x_msg_data      OUT NOCOPY VARCHAR2,
                   p_rebook_chr_id IN  NUMBER,
                   p_orig_chr_id   IN  NUMBER
                  ) IS
   l_proc_name VARCHAR2(35) := 'SYNC_PASSTHRU_DETAIL';
   pth_failed EXCEPTION;

   CURSOR pth_csr (p_chr_id NUMBER) IS
   SELECT okc.id, okc.orig_system_id1, okc.lse_id
   FROM   okc_k_lines_b okc,
          okl_k_lines okl
   WHERE  dnz_chr_id    = p_chr_id
   AND    lse_id        = 52 -- FEE top line
   AND    okl.fee_type  = 'PASSTHROUGH'
   AND    okc.id        = okl.id
   AND    okc.orig_system_id1 IS NOT NULL -- only old lines
   --Bug# 4959361
   AND    okc.sts_code <> 'TERMINATED'
   UNION -- Service line
   SELECT okc.id, okc.orig_system_id1, okc.lse_id
   FROM   okc_k_lines_b okc
   WHERE  dnz_chr_id    = p_chr_id
   AND    lse_id        = 48 -- SERVICE top line
   AND    okc.orig_system_id1 IS NOT NULL -- only old lines
   --Bug# 4959361
   AND    okc.sts_code <> 'TERMINATED'
   UNION -- Asset line
   SELECT okc.id, okc.orig_system_id1, okc.lse_id
   FROM   okc_k_lines_b okc
   WHERE  dnz_chr_id    = p_chr_id
   AND    lse_id        = 33 -- Fin. Asset top line
   AND    okc.orig_system_id1 IS NOT NULL -- only old lines
   --Bug# 4959361
   AND    okc.sts_code <> 'TERMINATED';

   CURSOR pth_rbk_hdr_csr (p_chr_id NUMBER,
                           p_cle_id NUMBER) IS
   SELECT *
   FROM   okl_party_payment_hdr
   WHERE  dnz_chr_id = p_chr_id
   AND    cle_id     = p_cle_id;

   CURSOR pth_orig_hdr_csr (p_chr_id NUMBER,
                            p_cle_id NUMBER,
                            p_pth_term okl_party_payment_hdr.passthru_term%TYPE) IS
   SELECT id
   FROM   okl_party_payment_hdr
   WHERE  dnz_chr_id    = p_chr_id
   AND    cle_id        = p_cle_id
   AND    passthru_term = p_pth_term;

   CURSOR pth_vendor_csr (p_chr_id NUMBER,
                          p_cle_id NUMBER) IS
   SELECT object1_id1 vendor_id,
          id
   FROM   okc_k_party_roles_b
   WHERE  cle_id     = p_cle_id
   AND    rle_code   = 'OKL_VENDOR'
   AND    dnz_chr_id = p_chr_id;

   CURSOR orig_vendor_csr (p_vendor_id OKC_K_PARTY_ROLES_B.OBJECT1_id1%TYPE,
                           p_cle_id    NUMBER) IS
   SELECT id
   FROM   okc_k_party_roles_b
   WHERE  cle_id      = p_cle_id
   AND    object1_id1 = p_vendor_id
   AND    rle_code    = 'OKL_VENDOR';

   CURSOR rbk_del_vendor_csr (p_orig_chr_id NUMBER,
                              p_orig_cle_id NUMBER,
                              p_rbk_chr_id  NUMBER,
                              p_rbk_cle_id  NUMBER) IS
   SELECT orig.object1_id1,
          orig.id
   FROM   okc_k_party_roles_b orig
   WHERE  orig.cle_id     = p_orig_cle_id
   AND    orig.dnz_chr_id = p_orig_chr_id
   AND    orig.rle_code   = 'OKL_VENDOR'
   AND    NOT EXISTS (
                      SELECT 'Y'
                      FROM   okc_k_party_roles_b rbk
                      WHERE  rbk.rle_code     = 'OKL_VENDOR'
                      AND    rbk.dnz_chr_id   = p_rbk_chr_id
                      AND    rbk.cle_id       = p_rbk_cle_id
                      AND    orig.object1_id1 = rbk.object1_id1
                      );

   ins NUMBER := 0;
   l_c_pphv_tbl okl_party_payments_pvt.pphv_tbl_type;

   upd NUMBER := 0;
   l_u_pphv_tbl okl_party_payments_pvt.pphv_tbl_type;

   x_pphv_tbl okl_party_payments_pvt.pphv_tbl_type;
   l_pth_orig_hdr_id NUMBER;
   l_pth_rebook_hdr_id NUMBER;

   l_orig_pth_tbl okl_party_payments_pvt.passthru_param_tbl_type;
   l_rbk_pth_tbl okl_party_payments_pvt.passthru_param_tbl_type;

   l_ppydv_rec okl_party_payments_pvt.ppydv_rec_type;
   x_ppydv_rec okl_party_payments_pvt.ppydv_rec_type;

   l_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
   x_cplv_rec okl_okc_migration_pvt.cplv_rec_type;

   l_orig_cpl_id NUMBER;

   --Bug# 4558486
   l_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
   x_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     FOR pth_rec IN pth_csr (p_rebook_chr_id)
     LOOP
        -- Bug# 4350255
        l_c_pphv_tbl.DELETE;
        l_u_pphv_tbl.DELETE;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Process line: '||pth_rec.id||', '||pth_rec.lse_id);
        END IF;

        FOR pth_rbk_hdr_rec IN pth_rbk_hdr_csr (p_rebook_chr_id,
                                                pth_rec.id)
        LOOP

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pth_rbk_hdr_rec.passthru_term: '|| pth_rbk_hdr_rec.passthru_term);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pth_rbk_hdr_rec.effective_from: '||pth_rbk_hdr_rec.effective_from);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pth_rbk_hdr_rec.effective_to: '||pth_rbk_hdr_rec.effective_to);
          END IF;

          l_pth_rebook_hdr_id := pth_rbk_hdr_rec.id;

          OPEN pth_orig_hdr_csr(p_orig_chr_id,
                                pth_rec.orig_system_id1,
                                pth_rbk_hdr_rec.passthru_term);
          FETCH pth_orig_hdr_csr INTO l_pth_orig_hdr_id;
          IF (pth_orig_hdr_csr%NOTFOUND) THEN
             -- Create pth header
             ins := ins + 1;
             l_c_pphv_tbl(ins).dnz_chr_id          := p_orig_chr_id;
             l_c_pphv_tbl(ins).cle_id              := pth_rec.orig_system_id1;
             l_c_pphv_tbl(ins).passthru_start_date := pth_rbk_hdr_rec.passthru_start_date;
             l_c_pphv_tbl(ins).payout_basis  := pth_rbk_hdr_rec.payout_basis;
             l_c_pphv_tbl(ins).payout_basis_formula := pth_rbk_hdr_rec.payout_basis_formula;
             l_c_pphv_tbl(ins).effective_from := pth_rbk_hdr_rec.effective_from;
             l_c_pphv_tbl(ins).effective_to  := pth_rbk_hdr_rec.effective_to;
             l_c_pphv_tbl(ins).passthru_term := pth_rbk_hdr_rec.passthru_term;
             l_c_pphv_tbl(ins).passthru_stream_type_id := pth_rbk_hdr_rec.passthru_stream_type_id;
          ELSE
             -- Update pth header
             upd := upd + 1;
             l_u_pphv_tbl(upd).id := l_pth_orig_hdr_id;
             l_u_pphv_tbl(upd).passthru_start_date := pth_rbk_hdr_rec.passthru_start_date;
             l_u_pphv_tbl(upd).payout_basis  := pth_rbk_hdr_rec.payout_basis;
             l_u_pphv_tbl(upd).payout_basis_formula := pth_rbk_hdr_rec.payout_basis_formula;
             l_u_pphv_tbl(upd).effective_from := pth_rbk_hdr_rec.effective_from;
             l_u_pphv_tbl(upd).effective_to  := pth_rbk_hdr_rec.effective_to;
             l_u_pphv_tbl(upd).passthru_term := pth_rbk_hdr_rec.passthru_term;
             l_u_pphv_tbl(upd).passthru_stream_type_id := pth_rbk_hdr_rec.passthru_stream_type_id;
          END IF;
          CLOSE pth_orig_hdr_csr;

        END LOOP; -- pth_hdr_csr

        IF (l_c_pphv_tbl.COUNT > 0) THEN
           okl_party_payments_pvt.create_party_payment_hdr(
              p_api_version    => 1.0,
              p_init_msg_list  => OKL_API.G_FALSE,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_pphv_tbl       => l_c_pphv_tbl,
              x_pphv_tbl       => x_pphv_tbl
             );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PTH header insert for: '||pth_rec.orig_system_id1||': '||x_return_status);
           END IF;
           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE pth_failed;
           END IF;
        END IF;
        IF (l_u_pphv_tbl.COUNT > 0) THEN
           okl_party_payments_pvt.update_party_payment_hdr(
              p_api_version    => 1.0,
              p_init_msg_list  => OKL_API.G_FALSE,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_pphv_tbl       => l_u_pphv_tbl,
              x_pphv_tbl       => x_pphv_tbl
             );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PTH header update for: '||pth_rec.orig_system_id1||': '||x_return_status);
           END IF;
           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE pth_failed;
           END IF;
        END IF;

        FOR pth_vendor_rec in pth_vendor_csr(p_rebook_chr_id,
                                             pth_rec.id)
        LOOP
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>rebook vendor id: '||pth_vendor_rec.vendor_id);
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>rebook cpl id   : '||pth_vendor_rec.id);
           END IF;
           -- get original vendor and cpl_id for this record
           OPEN orig_vendor_csr(pth_vendor_rec.vendor_id,
                                pth_rec.orig_system_id1);
           FETCH orig_vendor_csr INTO l_orig_cpl_id;
           IF orig_vendor_csr%NOTFOUND THEN
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>> vendor not found.');
             END IF;
             -- Create party for orig fee
             l_cplv_rec.dnz_chr_id        := p_orig_chr_id;
             l_cplv_rec.cle_id            := pth_rec.orig_system_id1;
             l_cplv_rec.object1_id1       := pth_vendor_rec.vendor_id;
             l_cplv_rec.object1_id2       := '#';
             l_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
             l_cplv_rec.rle_code          := 'OKL_VENDOR';

             --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
             --              to create records in tables
             --              okc_k_party_roles_b and okl_k_party_roles
             /*
             okl_okc_migration_pvt.create_k_party_role(
                  p_api_version         => 1.0,
                  p_init_msg_list       => OKL_API.G_FALSE,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_cplv_rec            => l_cplv_rec,
                  x_cplv_rec            => x_cplv_rec);
              */

              okl_k_party_roles_pvt.create_k_party_role(
                p_api_version          => 1.0,
                p_init_msg_list        => OKL_API.G_FALSE,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data,
                p_cplv_rec             => l_cplv_rec,
                x_cplv_rec             => x_cplv_rec,
                p_kplv_rec             => l_kplv_rec,
                x_kplv_rec             => x_kplv_rec);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>> Vendor '||pth_vendor_rec.vendor_id||' created: '||x_return_status);
              END IF;

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE pth_failed;
              END IF;

              process_pth_detail(
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_orig_chr_id   => p_orig_chr_id,
                                p_orig_cle_id   => pth_rec.orig_system_id1,
                                p_orig_cpl_id   => x_cplv_rec.id,
                                p_vendor_id     => pth_vendor_rec.vendor_id,
                                p_rbk_chr_id    => p_rebook_chr_id,
                                p_rbk_cle_id    => pth_rec.id,
                                p_rbk_cpl_id    => pth_vendor_rec.id
                               );

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE pth_failed;
              END IF;

           ELSE
             -- get rebook pth header+detail for this vendor
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>> pth detail for above vendor');
             END IF;
             process_pth_detail(
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_orig_chr_id   => p_orig_chr_id,
                                p_orig_cle_id   => pth_rec.orig_system_id1,
                                p_orig_cpl_id   => l_orig_cpl_id,
                                p_vendor_id     => pth_vendor_rec.vendor_id,
                                p_rbk_chr_id    => p_rebook_chr_id,
                                p_rbk_cle_id    => pth_rec.id,
                                p_rbk_cpl_id    => pth_vendor_rec.id
                               );

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE pth_failed;
              END IF;

           END IF; -- orig_vendor_csr
           CLOSE orig_vendor_csr;

        END LOOP; -- pth_vendor_rec

        -- for delated vendors, if any
        FOR rbk_del_vendor_rec IN rbk_del_vendor_csr(p_orig_chr_id => p_orig_chr_id,
                                                     p_orig_cle_id => pth_rec.orig_system_id1,
                                                     p_rbk_chr_id  => p_rebook_chr_id,
                                                     p_rbk_cle_id  => pth_rec.id)
        LOOP
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>> Vendor to be deleted: '||rbk_del_vendor_rec.object1_id1);
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'>> Vendor to be deleted cpl_id: '||rbk_del_vendor_rec.id);
           END IF;
           okl_maintain_fee_pvt.delete_passthru_party(
                                    p_api_version    => 1.0,
                                    p_init_msg_list  => OKL_API.G_FALSE,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_cpl_id         => rbk_del_vendor_rec.id
                                   );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Vendor deleted: '||x_return_status);
           END IF;

           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE pth_failed;
           END IF;

        END LOOP; -- rbk_del_vendor_rec

     END LOOP; -- pth_csr

   EXCEPTION
     WHEN pth_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
   END sync_passthru_detail;

------------------------------------------------------------------------------
-- PROCEDURE sync_fee_line
--
--  This procedure synchronizes FEE line(s) between Orig. and Rebooked contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_fee_line(
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          p_rebook_chr_id  IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_orig_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE
                         ) IS

  CURSOR fee_line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.*
  FROM   okl_k_Lines_full_v line,
         okc_line_styles_v style
  WHERE  line.sts_code   = 'BOOKED'
  AND    style.lty_code  = 'FEE'
  AND    line.dnz_chr_id = p_chr_id
  AND    line.lse_id     = style.id
  AND    line.fee_type   = 'GENERAL';

  CURSOR fee_subline_csr (p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT id
  FROM   okc_k_lines_v
  WHERE  cle_id = p_cle_id
  AND    sts_code = 'BOOKED';

  CURSOR rbk_new_fee_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.*
  FROM   okl_k_Lines_full_v line,
         okc_line_styles_v style
  WHERE  style.lty_code  = 'FEE'
  AND    line.dnz_chr_id = p_chr_id
  AND    line.lse_id     = style.id
  AND    line.orig_system_id1 IS NULL
  --Bug# 8766336
  AND    line.sts_code <> 'ABANDONED';

  CURSOR orig_fee_strm_csr (p_kle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT id
  FROM   okl_streams
  WHERE  kle_id = p_kle_id
  AND    say_code <> 'HIST';

  CURSOR txn_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT trx_number,
         rbr_code,
         date_transaction_occurred
  FROM   okl_trx_contracts
  WHERE  khr_id = p_chr_id
  AND    tcn_type = 'TRBK'
  AND    tsu_code = 'ENTERED'
  AND    representation_type = 'PRIMARY'; -- MGAAP 7263041

  i NUMBER;
  l_fee_present VARCHAR2(1);

  l_gen_count    NUMBER;

  l_rbk_fee_tbl  klev_tbl_type;
  lx_rbk_fee_tbl klev_tbl_type;

  l_orig_fee_strm_tbl stmv_tbl_type;
  x_orig_fee_strm_tbl stmv_tbl_type;

  l_clev_rec          clev_rec_type;
  l_klev_rec          klev_rec_type;
  x_clev_rec          clev_rec_type;
  x_klev_rec          klev_rec_type;

  l_old_clev_rec      clev_rec_type;
  l_old_klev_rec      klev_rec_type;
  x_old_clev_rec      clev_rec_type;
  x_old_klev_rec      klev_rec_type;

  l_old_clev_sub_rec  clev_rec_type;
  l_old_klev_sub_rec  klev_rec_type;
  x_old_clev_sub_rec  clev_rec_type;
  x_old_klev_sub_rec  klev_rec_type;

  l_cplv_rec          cplv_rec_type;
  x_cplv_rec          cplv_rec_type;

  l_cle_id            OKC_K_LINES_B.ID%TYPE;
  l_trx_date          okl_trx_contracts.date_transaction_occurred%TYPE;

  l_rgpv_rec          rgpv_rec_type;
  x_rgpv_rec          rgpv_rec_type;
  l_rulv_rec          rulv_rec_type;
  x_rulv_rec          rulv_rec_type;

  x_rulv_freq_rec     rulv_rec_type;
  x_rulv_exp_rec      rulv_rec_type;

  l_del_rulv_tbl      rulv_tbl_type;
  l_orig_rgp_id       NUMBER;
  l_orig_rule_id      NUMBER;

  sync_fee_failed EXCEPTION;

  -- changed the cursor to also include fee lines whose fee purpose code is null
  -- so that the same logic is applied to other fee lines while synchronization.
  -- changes introduced as part of Rebook Change Control Enhancement (RBCCE) START
  CURSOR c_fee_rbk_csr (cp_chr_id okc_k_headers_b.id%TYPE) IS
  SELECT okc.id
        ,okc.dnz_chr_id
        ,item.id item_id
        ,item.object1_id1
        ,item.object1_id2
        ,okc.start_date
        ,okc.end_date
        ,okl.amount
        ,okl.initial_direct_cost
        ,okl.qte_id
        ,okl.funding_date
        ,okc.orig_system_id1
        ,okl.fee_type
        --,partyb.id role_id -- change added for Rebook Change Control Enhancement
        --,partyb.object1_id1 vendor_party_id -- change added for Rebook Change Control Enhancement
        --,partyb.rle_code -- change added for Rebook Change Control Enhancement
        --,partyb.jtot_object1_code -- change added for Rebook Change Control Enhancement
        --Bug# 4558486
        ,okl.attribute_category
        ,okl.attribute1
        ,okl.attribute2
        ,okl.attribute3
        ,okl.attribute4
        ,okl.attribute5
        ,okl.attribute6
        ,okl.attribute7
        ,okl.attribute8
        ,okl.attribute9
        ,okl.attribute10
        ,okl.attribute11
        ,okl.attribute12
        ,okl.attribute13
        ,okl.attribute14
        ,okl.attribute15
   FROM okc_k_lines_b okc
       ,okl_k_lines okl
       ,okc_k_items item
       ,okc_line_styles_b style
       --,okc_k_party_roles_b partyb -- change added for Rebook Change Control Enhancement
  WHERE okc.id                 = okl.id
    AND okc.id                 = item.cle_id
    AND okc.dnz_chr_id         = item.dnz_chr_id
    AND okl.id                 = item.cle_id
    AND okc.dnz_chr_id         = cp_chr_id
    AND okc.lse_id             = style.id
    AND item.jtot_object1_code = 'OKL_STRMTYP'
    AND style.lty_code         = 'FEE'
    AND okc.orig_system_id1    IS NOT NULL
    AND (okl.fee_purpose_code   IN ('SALESTAX','RVI') -- Bug# 8652738 - Sales tax or RVI related fee line
        OR okl.fee_purpose_code IS NULL)
    --Bug# 4959361
    AND    okc.sts_code <> 'TERMINATED'; -- change added for Rebook Change Control Enhancement
    --AND partyb.dnz_chr_id (+) = okc.dnz_chr_id -- change added for Rebook Change Control Enhancement
    --AND partyb.cle_id (+) = okc.id; -- change added for Rebook Change Control Enhancement

  -- get fee top line info and optional supplier info from the original contract
  -- cursor added as part of rebook change control enhancement
  CURSOR c_fee_orig_csr(cp_chr_id okc_k_headers_b.id%TYPE, cp_cle_id okc_k_lines_b.id%TYPE) IS
  SELECT okc.id,
         item.id item_id,
         item.object1_id1,
         item.object1_id2,
         okc.start_date,
         okc.end_date,
         okl.amount,
         okl.initial_direct_cost,
         okl.qte_id,
         okl.funding_date,
         okc.orig_system_id1,
         --partyb.id role_id,
         --partyb.object1_id1 vendor_party_id,
         --partyb.rle_code,
         --partyb.jtot_object1_code,
         okl.fee_type,
         --Bug# 4558486
         okl.attribute_category,
         okl.attribute1,
         okl.attribute2,
         okl.attribute3,
         okl.attribute4,
         okl.attribute5,
         okl.attribute6,
         okl.attribute7,
         okl.attribute8,
         okl.attribute9,
         okl.attribute10,
         okl.attribute11,
         okl.attribute12,
         okl.attribute13,
         okl.attribute14,
         okl.attribute15
    FROM okc_k_lines_b okc,
         okl_k_lines okl,
         okc_k_items item,
         okc_line_styles_b style
         --okc_k_party_roles_b partyb
   WHERE okc.id = okl.id
     AND okc.id = item.cle_id
     AND okc.dnz_chr_id = item.dnz_chr_id
     AND okl.id = item.cle_id
     AND okc.dnz_chr_id = cp_chr_id
     AND okc.id = cp_cle_id
     AND okc.lse_id = style.id
     AND item.jtot_object1_code = 'OKL_STRMTYP'
     AND style.lty_code = 'FEE';
     --AND partyb.dnz_chr_id (+) = okc.dnz_chr_id
     --AND partyb.cle_id (+) = okc.id;

  c_fee_orig_rec c_fee_orig_csr%ROWTYPE;
  c_fee_rbk_rec c_fee_rbk_csr%ROWTYPE;

  -- changes introduced as part of Rebook Change Control Enhancement (RBCCE) END

  l_orig_st_fee_rec okl_maintain_fee_pvt.fee_types_rec_type;
  x_orig_st_fee_rec okl_maintain_fee_pvt.fee_types_rec_type;

  CURSOR rbk_fee_party_csr (p_line_id NUMBER,
                            p_chr_id  NUMBER) IS
  SELECT id, object1_id1, object1_id2,name
  FROM   okc_k_party_roles_b cpl,
         okx_vendors_v ven
  WHERE  cpl.cle_id     = p_line_id
  AND    cpl.dnz_chr_id = p_chr_id
  AND    cpl.rle_code   = 'OKL_VENDOR'
  AND    ven.id1 = cpl.object1_id1;

  CURSOR orig_fee_party_csr (p_line_id NUMBER,
                             p_chr_id  NUMBER) IS
  SELECT id, object1_id1
  FROM   okc_k_party_roles_b
  WHERE  cle_id      = p_line_id
  AND    dnz_chr_id  = p_chr_id
  AND    rle_code    = 'OKL_VENDOR';

  CURSOR orig_fee_item_csr (p_line_id NUMBER,
                            p_chr_id NUMBER) IS
  SELECT id
  FROM   okc_k_items
  WHERE  cle_id            = p_line_id
  AND    dnz_chr_id        = p_chr_id
  AND    jtot_object1_code = 'OKL_STRMTYP';

  l_orig_party_id NUMBER;
  l_orig_object1_id1 OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE;
  l_orig_item_id  NUMBER;
  l_orig_fee_top_line_id NUMBER;

  --Bug# 4880939
  CURSOR rbk_fee_asset_csr (p_top_line_id NUMBER,
                            p_chr_id      NUMBER) IS
  SELECT okc_cov_ast.orig_system_id1, okc_cov_ast.id line_id, okc_fin.name, SUBSTR(okc_fin.item_description,1,200) item_description,
         okl.capital_amount, okl.amount,
         item.id item_id, item.object1_id1, item.object1_id2, item.jtot_object1_code
  FROM   okc_k_lines_b okc_cov_ast,
         okl_k_lines okl,
         okc_line_styles_b style,
         okc_k_items item,
         okc_k_lines_v okc_fin
  WHERE  okc_cov_ast.cle_id = p_top_line_id
  AND    okc_cov_ast.dnz_chr_id = p_chr_id
  AND    okc_cov_ast.id = okl.id
  AND    okc_cov_ast.id = item.cle_id
  AND    okc_cov_ast.dnz_chr_id = item.dnz_chr_id
  AND    item.jtot_object1_code = 'OKX_COVASST'
  AND    okc_cov_ast.lse_id = style.id
  AND    style.lty_code = 'LINK_FEE_ASSET'
  AND    okc_fin.id = TO_NUMBER(item.object1_id1)
  AND    okc_fin.dnz_chr_id = p_chr_id
  --Bug# 4959361
  --Bug# 8766336
  AND    okc_cov_ast.sts_code NOT IN ('TERMINATED','ABANDONED');

  CURSOR orig_fee_asset_csr (p_sub_line_id NUMBER,
                             p_chr_id      NUMBER) IS
  SELECT okc.orig_system_id1, okc.id line_id, okc.name, okc.item_description,
         okl.capital_amount,
         item.id item_id, item.object1_id1, item.object1_id2, item.jtot_object1_code
  FROM   okc_k_lines_v okc,
         okl_k_lines okl,
         okc_line_styles_b style,
         okc_k_items item
  WHERE  okc.id = p_sub_line_id
  AND    okc.dnz_chr_id = p_chr_id
  AND    okc.id = okl.id
  AND    okc.id = item.cle_id
  AND    okc.dnz_chr_id = item.dnz_chr_id
  AND    item.jtot_object1_code = 'OKX_COVASST'
  AND    okc.lse_id = style.id
  AND    style.lty_code = 'LINK_FEE_ASSET';

  upd NUMBER := 0;
  l_u_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  x_u_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  ins NUMBER := 0;
  l_c_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  x_c_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;

  CURSOR rbk_d_fee_asset_csr (p_orig_chr_id NUMBER,
                              p_rbk_chr_id  NUMBER) IS
  select origl.id orig_link_fee_id,
         origk.id orig_link_fee_item_id,
         origp.id orig_parent_fee_id
  from   okc_k_lines_b origl,
         okc_k_lines_b origp,
         okc_k_items_v origk
  where  origl.dnz_chr_id        = p_orig_chr_id
  and    origl.lse_id            = 53 -- LINK_FEE_ASSET
  and    origl.cle_id            = origp.id
  and    origl.dnz_chr_id        = origp.dnz_chr_id
  and    origp.lse_id            = 52 -- FEE
  and    origp.dnz_chr_id        = p_orig_chr_id
  and    origl.id                = origk.cle_id
  and    origk.jtot_object1_code = 'OKX_COVASST'
  and    not exists (
                     select 'Y'
                     from   okc_k_lines_b rbkl
                     where  to_char(origl.id) = rbkl.orig_system_id1
                     and    rbkl.dnz_chr_id   = p_rbk_chr_id
                     );

  del NUMBER := 0;
  l_d_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;

  l_orig_freq_rule_id  NUMBER;
  l_orig_freq_rgp_id   NUMBER;
  l_orig_freq          OKC_RULES_V.OBJECT1_ID1%TYPE;
  l_orig_exp_rule_id   NUMBER;
  l_orig_exp_rgp_id    NUMBER;
  l_orig_exp_period    NUMBER;
  l_orig_exp_amount    NUMBER;
  x_rule_count         NUMBER;

  l_proc_name   VARCHAR2(35)    := 'SYNC_FEE_LINES';

  --Bug# 4558486
  l_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
  x_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

  --Bug# 4899328
  l_cov_ast_tbl  klev_tbl_type;
  lx_cov_ast_tbl klev_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    -- ABANDON Orig FEE line only if Orig contract has FEE_TYPE='GENERAL'

    FOR orig_fee_rec IN fee_line_csr(p_orig_chr_id) LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Abandon line: '||orig_fee_rec.id);
      END IF;
      -- Delete from Orig contract
      -- l_clev_rec    := NULL;
      -- l_klev_rec    := NULL;

      l_clev_rec.id := orig_fee_rec.id;
      l_clev_rec.chr_id := p_orig_chr_id;
      l_klev_rec.id := orig_fee_rec.id;
      l_clev_rec.sts_code := 'ABANDONED';

      -- Make Fee top-line ABANDONED
      okl_contract_pub.update_contract_line(
                                            p_api_version   => 1.0,
                                            p_init_msg_list => OKL_API.G_FALSE,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_clev_rec      => l_clev_rec,
                                            p_klev_rec      => l_klev_rec,
                                            x_clev_rec      => x_clev_rec,
                                            x_klev_rec      => x_klev_rec
                                           );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_fee_failed;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Line deleted');
      END IF;

      -- ABANDONED FEE sub-lines
      FOR fee_subline_rec IN fee_subline_csr(orig_fee_rec.id) LOOP
        l_clev_rec.id := fee_subline_rec.id;
        l_klev_rec.id := fee_subline_rec.id;

        l_clev_rec.sts_code := 'ABANDONED';

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sub line delete: '||fee_subline_rec.id);
        END IF;
        okl_contract_pub.update_contract_line(
                                              p_api_version   => 1.0,
                                              p_init_msg_list => OKL_API.G_FALSE,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_clev_rec      => l_clev_rec,
                                              p_klev_rec      => l_klev_rec,
                                              x_clev_rec      => x_clev_rec,
                                              x_klev_rec      => x_klev_rec
                                             );
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_fee_failed;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sub line deleted');
        END IF;
      END LOOP;

      -- HIST related Streams
      i := 0;
      FOR orig_fee_strm_rec IN orig_fee_strm_csr (orig_fee_rec.id) LOOP
        i := i + 1;
        l_orig_fee_strm_tbl(i).id        := orig_fee_strm_rec.id;
        l_orig_fee_strm_tbl(i).say_code  := 'HIST';
        l_orig_fee_strm_tbl(i).active_yn := 'N';
        l_orig_fee_strm_tbl(i).date_history  := SYSDATE;
      END LOOP;
      IF (l_orig_fee_strm_tbl.COUNT <> 0) THEN
        okl_streams_pub.update_streams(
                                  p_api_version    => 1.0,
                                  p_init_msg_list  => OKC_API.G_FALSE,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_stmv_tbl       => l_orig_fee_strm_tbl,
                                  x_stmv_tbl       => x_orig_fee_strm_tbl
                                 );

        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_fee_failed;
        END IF;
      END IF; -- end of l_orig_fee_strm_tbl.COUNT <> 0
    END LOOP; -- Orig Fee line ABANDON

    l_rbk_fee_tbl.DELETE;
    i := 0;
    --
    -- Check for New FEE line being added during rebook
    --
    FOR rbk_fee_rec IN rbk_new_fee_csr(p_rebook_chr_id)
    LOOP
       i := i + 1;
       l_rbk_fee_tbl(i).id := rbk_fee_rec.id;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Old Fee line: '||rbk_fee_rec.id);
       END IF;

    END LOOP; -- rbk_fee_csr

    IF (i > 0) THEN
       okl_copy_asset_pub.copy_all_lines(
                                         p_api_version        => 1.0,
                                         p_init_msg_list      => OKL_API.G_FALSE,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_from_cle_id_tbl    => l_rbk_fee_tbl,
                                         p_to_cle_id          => NULL,
                                         p_to_chr_id          => p_orig_chr_id,
                                         p_to_template_yn     => 'N',
                                         p_copy_reference     => 'COPY',
                                         p_copy_line_party_yn => 'Y',
                                         p_renew_ref_yn       => 'N',
                                         p_trans_type         => 'CRB',
                                         x_cle_id_tbl         => lx_rbk_fee_tbl
                                        );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE sync_fee_failed;
       END IF;

    END IF;

    -- OKL.H Projects changes -- Bug# 4373029
    -- Sync old fee lines for any update where purpose=SALESTAX

    -- Bug# 8652738: Sync all existing fee lines including SALESTAX and RVI
    OPEN c_fee_rbk_csr (cp_chr_id => p_rebook_chr_id);
    LOOP
      FETCH c_fee_rbk_csr INTO c_fee_rbk_rec;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL.H*** ST Fee Line: '|| c_fee_rbk_rec.id);
      END IF;
      EXIT WHEN c_fee_rbk_csr%NOTFOUND;
      OPEN c_fee_orig_csr(cp_chr_id => p_orig_chr_id, cp_cle_id => c_fee_rbk_rec.orig_system_id1);
      FETCH c_fee_orig_csr INTO c_fee_orig_rec;

      IF(c_fee_orig_csr%NOTFOUND) THEN
        CLOSE c_fee_orig_csr;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSE
        l_orig_fee_top_line_id  := c_fee_rbk_rec.orig_system_id1; -- for future use
        -- check if either of the fee, (amount where fee type is not Rollover), idc,
        -- (qte_id and fee type is not Rollover), supplier are changed between the contracts only then merge the change
        -- onto the fee line that belongs to the original contract
        -- fee start date change would not sync up the fee lines for start date, the original date remains

        IF(
           (c_fee_orig_rec.object1_id1 <> c_fee_rbk_rec.object1_id1) -- fee lov value has changed
         -- amount has changed on a fee type that is not Rollover
         OR((NVL(c_fee_orig_rec.amount,0) <> NVL(c_fee_rbk_rec.amount,0)) AND c_fee_orig_rec.fee_type <> G_ROLLOVER_FEE)
         OR(NVL(c_fee_orig_rec.initial_direct_cost,0) <> NVL(c_fee_rbk_rec.initial_direct_cost,0)) -- idc has changed
         -- for non rollover fee quote has changed (is there a quote for other fee types??)
         OR((NVL(c_fee_orig_rec.qte_id, OKL_API.G_MISS_NUM) <> NVL(c_fee_rbk_rec.qte_id, OKL_API.G_MISS_NUM)) AND c_fee_orig_rec.fee_type <> G_ROLLOVER_FEE)
--       OR(NVL(c_fee_orig_rec.vendor_party_id, OKL_API.G_MISS_NUM) <> NVL(c_fee_rbk_rec.vendor_party_id, OKL_API.G_MISS_NUM)) -- optional supplier info has changed
--       fee start date changes are not synced up on the original fee line
--       OR(TRUNC(NVL(c_fee_orig_rec.start_date,OKL_API.G_MISS_DATE)) <> TRUNC(NVL(c_fee_rbk_rec.start_date,OKL_API.G_MISS_DATE)))
         OR(TRUNC(NVL(c_fee_orig_rec.end_date,OKL_API.G_MISS_DATE)) <> TRUNC(NVL(c_fee_rbk_rec.end_date,OKL_API.G_MISS_DATE)))
         --Bug# 4558486
         OR(NVL(c_fee_orig_rec.attribute_category, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute_category, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute1, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute1, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute2, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute2, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute3, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute3, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute4, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute4, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute5, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute5, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute6, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute6, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute7, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute7, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute8, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute8, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute9, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute9, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute10, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute10, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute11, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute11, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute12, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute12, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute13, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute13, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute14, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute14, OKL_API.G_MISS_CHAR))
         OR(NVL(c_fee_orig_rec.attribute15, OKL_API.G_MISS_CHAR) <> NVL(c_fee_rbk_rec.attribute15, OKL_API.G_MISS_CHAR))

        )THEN
          l_orig_st_fee_rec.line_id               := c_fee_rbk_rec.orig_system_id1;
          l_orig_st_fee_rec.dnz_chr_id            := p_orig_chr_id;
          -- item id in okc_k_items remains as of the original contract
          l_orig_st_fee_rec.item_id               := c_fee_orig_rec.item_id;
          l_orig_st_fee_rec.item_id1              := c_fee_rbk_rec.object1_id1;
          l_orig_st_fee_rec.item_id2              := c_fee_rbk_rec.object1_id2;
          -- l_orig_st_fee_rec.effective_from        := c_fee_rbk_rec.start_date;
          -- the start date on the fee line is not updateable, the original value remains
          -- coded as per Rebook Change Control Enhancement
          l_orig_st_fee_rec.effective_from        := c_fee_orig_rec.start_date;
          l_orig_st_fee_rec.effective_to          := c_fee_rbk_rec.end_date;
          l_orig_st_fee_rec.amount                := c_fee_rbk_rec.amount;
          l_orig_st_fee_rec.initial_direct_cost   := c_fee_rbk_rec.initial_direct_cost;
          l_orig_st_fee_rec.fee_type              := c_fee_orig_rec.fee_type;

          l_orig_st_fee_rec.party_id  := NULL;
          l_orig_st_fee_rec.party_id1 := NULL;
          l_orig_st_fee_rec.party_id2 := NULL;
          --Bug# 4880939
          l_orig_st_fee_rec.party_name := NULL;
          IF (c_fee_rbk_rec.fee_type <> 'PASSTHROUGH') THEN

            FOR orig_fee_party_rec IN
                orig_fee_party_csr(l_orig_fee_top_line_id, p_orig_chr_id) LOOP
              l_orig_st_fee_rec.party_id := orig_fee_party_rec.id;
            END LOOP;

            FOR rbk_fee_party_rec IN
                rbk_fee_party_csr(c_fee_rbk_rec.id,c_fee_rbk_rec.dnz_chr_id) LOOP
              l_orig_st_fee_rec.party_id1 := rbk_fee_party_rec.object1_id1;
              l_orig_st_fee_rec.party_id2 := rbk_fee_party_rec.object1_id2;
              l_orig_st_fee_rec.party_name := rbk_fee_party_rec.name;
            END LOOP;

          END IF;

          -- just to make sure that we are not syncing up the qte_id for a rollover fee
          l_orig_st_fee_rec.qte_id := c_fee_orig_rec.qte_id;

          --Bug# 4558486
          l_orig_st_fee_rec.attribute_category    := c_fee_rbk_rec.attribute_category;
          l_orig_st_fee_rec.attribute1            := c_fee_rbk_rec.attribute1;
          l_orig_st_fee_rec.attribute2            := c_fee_rbk_rec.attribute2;
          l_orig_st_fee_rec.attribute3            := c_fee_rbk_rec.attribute3;
          l_orig_st_fee_rec.attribute4            := c_fee_rbk_rec.attribute4;
          l_orig_st_fee_rec.attribute5            := c_fee_rbk_rec.attribute5;
          l_orig_st_fee_rec.attribute6            := c_fee_rbk_rec.attribute6;
          l_orig_st_fee_rec.attribute7            := c_fee_rbk_rec.attribute7;
          l_orig_st_fee_rec.attribute7            := c_fee_rbk_rec.attribute8;
          l_orig_st_fee_rec.attribute9            := c_fee_rbk_rec.attribute9;
          l_orig_st_fee_rec.attribute10           := c_fee_rbk_rec.attribute10;
          l_orig_st_fee_rec.attribute11           := c_fee_rbk_rec.attribute11;
          l_orig_st_fee_rec.attribute12           := c_fee_rbk_rec.attribute12;
          l_orig_st_fee_rec.attribute13           := c_fee_rbk_rec.attribute13;
          l_orig_st_fee_rec.attribute14           := c_fee_rbk_rec.attribute14;
          l_orig_st_fee_rec.attribute15           := c_fee_rbk_rec.attribute15;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.line_id: '||l_orig_st_fee_rec.line_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.dnz_chr_id: '||l_orig_st_fee_rec.dnz_chr_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.item_id: '||l_orig_st_fee_rec.item_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.item_id1: '||l_orig_st_fee_rec.item_id1);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.item_id2: '||l_orig_st_fee_rec.item_id2);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.effective_from: '||l_orig_st_fee_rec.effective_from);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.effective_to: '||l_orig_st_fee_rec.effective_to);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.amount: '||l_orig_st_fee_rec.amount);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.initial_direct_cost: '||l_orig_st_fee_rec.initial_direct_cost);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_st_fee_rec.fee_type: '||l_orig_st_fee_rec.fee_type);
          END IF;

          -- Update corresponding Orig Fee line
          okl_maintain_fee_pvt.update_fee_type(
                p_api_version   => 1.0,
                p_init_msg_list => OKL_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_fee_types_rec => l_orig_st_fee_rec,
                x_fee_types_rec => x_orig_st_fee_rec
               );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL.H*** After Update Top line: '||x_return_status);
          END IF;

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE sync_fee_failed;
          END IF;
        END IF; -- end of attribute comparision and calling update_fee_type API

        IF (c_fee_rbk_rec.fee_type = 'PASSTHROUGH') THEN
           sync_passthru_party(x_return_status => x_return_status);
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE sync_fee_failed;
           END IF;
        ELSE
           -- Sync Fee expense rules for Financed Fee line
           -- Also syncing the Misc and Expense Fee lines as part of Contract Rebook Change Control Enhancement
           IF (c_fee_rbk_rec.fee_type IN ('FINANCED','MISCELLANEOUS','EXPENSE')) THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sync Financed Fee - Expense Rule');
              END IF;
              -- get original Expense rule LAFREQ
              get_rule_info(
                    x_return_status => x_return_status,
                    p_rebook_chr_id => p_orig_chr_id,
                    p_rebook_cle_id => l_orig_fee_top_line_id,
                    p_rgd_code      => 'LAFEXP',
                    p_rule_code     => 'LAFREQ',
                    x_rulv_rec      => x_rulv_freq_rec,
                    x_rule_count    => x_rule_count
                   );

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_fee_failed;
              END IF;
              l_orig_freq_rule_id := x_rulv_freq_rec.id;
              l_orig_freq_rgp_id  := x_rulv_freq_rec.rgp_id;
              l_orig_freq         := x_rulv_freq_rec.object1_id1;

              -- get rebook Expense rule LAFREQ
              get_rule_info(
                    x_return_status => x_return_status,
                    p_rebook_chr_id => p_rebook_chr_id,
                    p_rebook_cle_id => c_fee_rbk_rec.id,
                    p_rgd_code      => 'LAFEXP',
                    p_rule_code     => 'LAFREQ',
                    x_rulv_rec      => x_rulv_freq_rec,
                    x_rule_count    => x_rule_count
                   );
              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_fee_failed;
              END IF;

              IF (l_orig_freq <> x_rulv_freq_rec.object1_id1) THEN
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update Freq to: '||x_rulv_freq_rec.object1_id1);
                 END IF;
                 x_rulv_freq_rec.id     := l_orig_freq_rule_id;
                 x_rulv_freq_rec.rgp_id := l_orig_freq_rgp_id;
                 x_rulv_freq_rec.dnz_chr_id  := p_orig_chr_id;
                 okl_rule_pub.update_rule(
                                          p_api_version   => 1.0,
                                          p_init_msg_list => OKL_API.G_FALSE,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_rulv_rec      => x_rulv_freq_rec,
                                          x_rulv_rec      => x_rulv_rec
                                         );

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update LAFREQ : '||x_return_status);
                  END IF;

                  IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                      x_return_status := Okc_Api.G_RET_STS_ERROR;
                      RAISE sync_fee_failed;
                  END IF;
              END IF;

              -- get original Expense rule LAFEXP
              get_rule_info(
                    x_return_status => x_return_status,
                    p_rebook_chr_id => p_orig_chr_id,
                    p_rebook_cle_id => l_orig_fee_top_line_id,
                    p_rgd_code      => 'LAFEXP',
                    p_rule_code     => 'LAFEXP',
                    x_rulv_rec      => x_rulv_exp_rec,
                    x_rule_count    => x_rule_count
                   );

              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_fee_failed;
              END IF;
              l_orig_exp_rule_id  := x_rulv_exp_rec.id;
              l_orig_exp_rgp_id   := x_rulv_exp_rec.rgp_id;
              l_orig_exp_period   := x_rulv_exp_rec.rule_information1;
              l_orig_exp_amount   := x_rulv_exp_rec.rule_information2;

              -- get rebook Expense rule LAFEXP
              get_rule_info(
                    x_return_status => x_return_status,
                    p_rebook_chr_id => p_rebook_chr_id,
                    p_rebook_cle_id => c_fee_rbk_rec.id,
                    p_rgd_code      => 'LAFEXP',
                    p_rule_code     => 'LAFEXP',
                    x_rulv_rec      => x_rulv_exp_rec,
                    x_rule_count    => x_rule_count
                   );
              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 RAISE sync_fee_failed;
              END IF;

              IF (l_orig_exp_period <> x_rulv_exp_rec.rule_information1
                  OR
                  l_orig_exp_amount <> x_rulv_exp_rec.rule_information2) THEN
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update period to: '||x_rulv_exp_rec.rule_information1);
                   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update amount to: '||x_rulv_exp_rec.rule_information2);
                 END IF;
                 x_rulv_exp_rec.id     := l_orig_exp_rule_id;
                 x_rulv_exp_rec.rgp_id := l_orig_exp_rgp_id;
                 x_rulv_exp_rec.dnz_chr_id  := p_orig_chr_id;
                 okl_rule_pub.update_rule(
                                          p_api_version   => 1.0,
                                          p_init_msg_list => OKL_API.G_FALSE,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_rulv_rec      => x_rulv_exp_rec,
                                          x_rulv_rec      => x_rulv_rec
                                         );
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update LAFEXP : '||x_return_status);
                  END IF;

                  IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                      x_return_status := Okc_Api.G_RET_STS_ERROR;
                      RAISE sync_fee_failed;
                  END IF;
              END IF;
           END IF;
           -- Check for party
           FOR rbk_fee_party_rec IN rbk_fee_party_csr(c_fee_rbk_rec.id,
                                                      c_fee_rbk_rec.dnz_chr_id)
           LOOP
              l_orig_party_id := NULL;
              OPEN orig_fee_party_csr(l_orig_fee_top_line_id, p_orig_chr_id);
              FETCH orig_fee_party_csr INTO l_orig_party_id, l_orig_object1_id1;

              CLOSE orig_fee_party_csr;

              IF (l_orig_party_id IS NOT NULL) THEN
                 IF (l_orig_object1_id1 <> rbk_fee_party_rec.object1_id1) THEN
                    -- Update
                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update Party...');
                    END IF;
                    l_cplv_rec.id                := l_orig_party_id;
                    l_cplv_rec.object1_id1       := rbk_fee_party_rec.object1_id1;

                    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
                    --              to update records in tables
                    --              okc_k_party_roles_b and okl_k_party_roles
                    /*
                    okl_okc_migration_pvt.update_k_party_role(
                p_api_version	=> 1.0,
                p_init_msg_list	=> OKL_API.G_FALSE,
                x_return_status 	=> x_return_status,
                x_msg_count     	=> x_msg_count,
                x_msg_data      	=> x_msg_data,
                p_cplv_rec		=> l_cplv_rec,
                x_cplv_rec		=> x_cplv_rec);
                    */

                    l_kplv_rec.id := l_cplv_rec.id;
                    okl_k_party_roles_pvt.update_k_party_role(
                      p_api_version          => 1.0,
                      p_init_msg_list        => OKL_API.G_FALSE,
                      x_return_status        => x_return_status,
                      x_msg_count            => x_msg_count,
                      x_msg_data             => x_msg_data,
                      p_cplv_rec             => l_cplv_rec,
                      x_cplv_rec             => x_cplv_rec,
                      p_kplv_rec             => l_kplv_rec,
                      x_kplv_rec             => x_kplv_rec );

                     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE sync_fee_failed;
                     END IF;
                 END IF;
              ELSE -- new party
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Create Party...');
                 END IF;
                 -- Create party for orig fee
                 l_cplv_rec.dnz_chr_id        := p_orig_chr_id;
                 l_cplv_rec.cle_id            := l_orig_fee_top_line_id;
                 l_cplv_rec.object1_id1       := rbk_fee_party_rec.object1_id1;
                 l_cplv_rec.object1_id2       := rbk_fee_party_rec.object1_id2;
                 l_cplv_rec.jtot_object1_code := 'OKX_VENDOR';
                 l_cplv_rec.rle_code          := 'OKL_VENDOR';

                 --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
                 --              to create records in tables
                 --              okc_k_party_roles_b and okl_k_party_roles
                 /*
                 okl_okc_migration_pvt.create_k_party_role(
             p_api_version	=> 1.0,
             p_init_msg_list	=> OKL_API.G_FALSE,
             x_return_status 	=> x_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_cplv_rec		=> l_cplv_rec,
             x_cplv_rec		=> x_cplv_rec);
                */

                 okl_k_party_roles_pvt.create_k_party_role(
                   p_api_version          => 1.0,
                   p_init_msg_list        => OKL_API.G_FALSE,
                   x_return_status        => x_return_status,
                   x_msg_count            => x_msg_count,
                   x_msg_data             => x_msg_data,
                   p_cplv_rec             => l_cplv_rec,
                   x_cplv_rec             => x_cplv_rec,
                   p_kplv_rec             => l_kplv_rec,
                   x_kplv_rec             => x_kplv_rec);

                  IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                    RAISE sync_fee_failed;
                  END IF;
              END IF;
          END LOOP; -- party
        END IF; -- passthru

        -- Linked Fee Asset
        upd := 0; -- update line count
        l_u_line_item_tbl.DELETE;

        ins := 0; -- insert line count
        l_c_line_item_tbl.DELETE;
        --Bug# 4899328
        l_cov_ast_tbl.DELETE;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update link asset for: '||c_fee_rbk_rec.id);
        END IF;
        FOR rbk_fee_asset_rec IN rbk_fee_asset_csr (c_fee_rbk_rec.id,
                                                    c_fee_rbk_rec.dnz_chr_id)
        LOOP

           IF (rbk_fee_asset_rec.orig_system_id1 IS NOT NULL) THEN -- update the line
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'--->Update Rebook Asset: '||rbk_fee_asset_rec.line_id);
              END IF;
              FOR orig_fee_asset_rec IN orig_fee_asset_csr(rbk_fee_asset_rec.orig_system_id1,
                                                           p_orig_chr_id)
              LOOP
                -- Update existing line
                upd := upd + 1;
                l_u_line_item_tbl(upd).parent_cle_id  := l_orig_fee_top_line_id;
                l_u_line_item_tbl(upd).cle_id         := orig_fee_asset_rec.line_id;
                l_u_line_item_tbl(upd).chr_id         := p_orig_chr_id;
                l_u_line_item_tbl(upd).item_id        := orig_fee_asset_rec.item_id;
                l_u_line_item_tbl(upd).item_id1       := rbk_fee_asset_rec.object1_id1;
                l_u_line_item_tbl(upd).item_id2       := rbk_fee_asset_rec.object1_id2;
                l_u_line_item_tbl(upd).item_object1_code  := rbk_fee_asset_rec.jtot_object1_code;
                l_u_line_item_tbl(upd).name           := rbk_fee_asset_rec.name;
                l_u_line_item_tbl(upd).item_description := rbk_fee_asset_rec.item_description;
                l_u_line_item_tbl(upd).capital_amount := NVL(rbk_fee_asset_rec.capital_amount,
                                                             rbk_fee_asset_rec.amount) ;

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update record: '||upd||': '||l_u_line_item_tbl(upd).name);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Capital amt: '||l_u_line_item_tbl(upd).capital_amount);
                END IF;
              END LOOP;
           ELSE
              -- Create new asset association line
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'--->Insert Rebook Asset: '||rbk_fee_asset_rec.line_id);
              END IF;
              ins := ins + 1;
              --Bug# 4899328
              l_cov_ast_tbl(ins).id := rbk_fee_asset_rec.line_id;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Insert record: '||ins||': '||rbk_fee_asset_rec.name);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Capital amt: '||NVL(rbk_fee_asset_rec.capital_amount,rbk_fee_asset_rec.amount));
              END IF;

              /*
              l_c_line_item_tbl(ins).parent_cle_id  := l_orig_fee_top_line_id;
              l_c_line_item_tbl(ins).chr_id         := p_orig_chr_id;
              l_c_line_item_tbl(ins).item_id1       := rbk_fee_asset_rec.object1_id1;
              l_c_line_item_tbl(ins).item_id2       := rbk_fee_asset_rec.object1_id2;
              l_c_line_item_tbl(ins).item_object1_code := rbk_fee_asset_rec.jtot_object1_code;
              l_c_line_item_tbl(ins).name           := rbk_fee_asset_rec.name;
              l_c_line_item_tbl(ins).item_description := rbk_fee_asset_rec.item_description;
              l_c_line_item_tbl(ins).capital_amount := NVL(rbk_fee_asset_rec.capital_amount,
                                                             rbk_fee_asset_rec.amount) ;

              debug_message('Insert record: '||ins||': '||l_c_line_item_tbl(ins).name);
              debug_message('Capital amt: '||l_c_line_item_tbl(ins).capital_amount);
              */
              --Bug# 4899328

           END IF;
        END LOOP; -- subline

        IF (l_u_line_item_tbl.COUNT > 0) THEN
           okl_contract_line_item_pvt.update_contract_line_item(
                  p_api_version     => 1.0,
                  p_init_msg_list   => OKL_API.G_FALSE,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_line_item_tbl   => l_u_line_item_tbl,
                  x_line_item_tbl   => x_u_line_item_tbl
                 );
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_fee_failed;
           END IF;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Fee asset updated; '||l_u_line_item_tbl.COUNT);
        END IF;

        --Bug# 4899328
        -- Change call from okl_contract_line_item_pvt.create_contract_line_item to
        -- okl_copy_asset_pub.copy_all_lines in order to copy Payments associated to
        -- new covered asset lines.
        IF (l_cov_ast_tbl.COUNT > 0) THEN
          okl_copy_asset_pub.copy_all_lines(
                                             p_api_version        => 1.0,
                                             p_init_msg_list      => OKC_API.G_FALSE,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data,
                                             P_from_cle_id_tbl    => l_cov_ast_tbl,
                                             p_to_chr_id          => NULL,
                                             p_to_cle_id          => l_orig_fee_top_line_id,
                                             p_to_template_yn     => 'N',
                                             p_copy_reference     => 'Y',
                                             p_copy_line_party_yn => 'Y',
                                             p_renew_ref_yn       => 'N',
                                             p_trans_type         => 'CRB',
                                             x_cle_id_tbl         => lx_cov_ast_tbl
                                            );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE sync_fee_failed;
          END IF;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Fee asset inserted; '||l_cov_ast_tbl.COUNT);
        END IF;


        /*
        IF (l_c_line_item_tbl.COUNT > 0) THEN
           okl_contract_line_item_pvt.create_contract_line_item(
                  p_api_version     => 1.0,
                  p_init_msg_list   => OKL_API.G_FALSE,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_line_item_tbl   => l_c_line_item_tbl,
                  x_line_item_tbl   => x_c_line_item_tbl
                 );
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_fee_failed;
           END IF;
        END IF;
        debug_message('Link Fee asset inserted; '||l_c_line_item_tbl.COUNT);
        */
        --Bug# 4899328

      END IF;
      CLOSE c_fee_orig_csr;
    END LOOP; -- c_fee_rbk_rec
    CLOSE c_fee_rbk_csr;

    -- OKL.H Projects changes ---
  EXCEPTION
    WHEN sync_fee_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;

    when OKL_API.G_EXCEPTION_ERROR then
       x_return_status := 'OKC_API.G_RET_STS_ERROR';

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
       x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';

  END sync_fee_line;

------------------------------------------------------------------------------
-- PROCEDURE sync_service_line
--
--  This procedure synchronizes SERVICE line(s) between Orig. and Rebooked contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_service_line(
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          p_rebook_chr_id  IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_orig_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE
                         ) IS


  CURSOR rbk_new_service_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.id
  FROM   okc_k_lines_b line,
         okc_line_styles_b style
  WHERE  style.lty_code  = 'SOLD_SERVICE'
  AND    line.dnz_chr_id = p_chr_id
  AND    line.chr_id     = p_chr_id
  AND    line.lse_id     = style.id
  AND    line.orig_system_id1 IS NULL
  --Bug# 8766336
  AND    line.sts_code <> 'ABANDONED';

  i NUMBER;

  l_rbk_service_tbl  klev_tbl_type;
  lx_rbk_service_tbl klev_tbl_type;

  l_orig_clev_rec          clev_rec_type;
  l_orig_klev_rec          klev_rec_type;
  l_orig_cimv_rec          cimv_rec_type;
  l_orig_cplv_rec          cplv_rec_type;

  x_clev_rec               clev_rec_type;
  x_klev_rec               klev_rec_type;
  x_cimv_rec               cimv_rec_type;
  x_cplv_rec               cplv_rec_type;

  l_orig_service_top_line_id okc_k_headers_b.id%TYPE;

  sync_service_failed EXCEPTION;

  CURSOR c_service_rbk_csr (cp_chr_id okc_k_headers_b.id%TYPE) IS
  SELECT okc.id
        ,okc.dnz_chr_id
        ,okc.item_description
        ,okc.orig_system_id1
        ,item.id item_id
        ,item.object1_id1
        ,item.object1_id2
        ,item.jtot_object1_code
        ,okc.start_date
        ,okc.end_date
        ,okl.amount
        ,okl.attribute_category
        ,okl.attribute1
        ,okl.attribute2
        ,okl.attribute3
        ,okl.attribute4
        ,okl.attribute5
        ,okl.attribute6
        ,okl.attribute7
        ,okl.attribute8
        ,okl.attribute9
        ,okl.attribute10
        ,okl.attribute11
        ,okl.attribute12
        ,okl.attribute13
        ,okl.attribute14
        ,okl.attribute15
   FROM okc_k_lines_v okc
       ,okl_k_lines okl
       ,okc_k_items item
       ,okc_line_styles_b style
  WHERE okc.id                 = okl.id
    AND okc.id                 = item.cle_id
    AND okc.dnz_chr_id         = item.dnz_chr_id
    AND okl.id                 = item.cle_id
    AND okc.dnz_chr_id         = cp_chr_id
    AND okc.chr_id             = cp_chr_id
    AND okc.lse_id             = style.id
    AND item.jtot_object1_code = 'OKX_SERVICE'
    AND style.lty_code         = 'SOLD_SERVICE'
    AND okc.orig_system_id1    IS NOT NULL
    AND okc.sts_code <> 'TERMINATED';

  CURSOR c_service_orig_csr(cp_chr_id okc_k_headers_b.id%TYPE, cp_cle_id okc_k_lines_b.id%TYPE) IS
  SELECT okc.id,
         okc.dnz_chr_id,
         okc.line_number,
         okc.exception_yn,
         okc.display_sequence,
         okc.lse_id,
         okc.currency_code,
         okc.sts_code,
         okc.item_description,
         okc.orig_system_id1,
         item.id item_id,
         item.object1_id1,
         item.object1_id2,
         item.uom_code,
         item.number_of_items,
         item.exception_yn item_exception_yn,
         okc.start_date,
         okc.end_date,
         okl.kle_id,
         okl.amount,
         okl.attribute_category,
         okl.attribute1,
         okl.attribute2,
         okl.attribute3,
         okl.attribute4,
         okl.attribute5,
         okl.attribute6,
         okl.attribute7,
         okl.attribute8,
         okl.attribute9,
         okl.attribute10,
         okl.attribute11,
         okl.attribute12,
         okl.attribute13,
         okl.attribute14,
         okl.attribute15
    FROM okc_k_lines_v okc,
         okl_k_lines okl,
         okc_k_items item,
         okc_line_styles_b style
   WHERE okc.id = okl.id
     AND okc.id = item.cle_id
     AND okc.dnz_chr_id = item.dnz_chr_id
     AND okl.id = item.cle_id
     AND okc.dnz_chr_id = cp_chr_id
     AND okc.id = cp_cle_id
     AND okc.lse_id = style.id
     AND item.jtot_object1_code = 'OKX_SERVICE'
     AND style.lty_code = 'SOLD_SERVICE';

  c_service_orig_rec c_service_orig_csr%ROWTYPE;
  c_service_rbk_rec c_service_rbk_csr%ROWTYPE;

  CURSOR rbk_service_asset_csr (p_top_line_id NUMBER,
                                p_chr_id      NUMBER) IS
  SELECT okc_cov_ast.orig_system_id1, okc_cov_ast.id line_id, okc_fin.name, SUBSTR(okc_fin.item_description,1,200) item_description,
         okl.capital_amount, okl.amount,
         item.id item_id, item.object1_id1, item.object1_id2, item.jtot_object1_code
  FROM   okc_k_lines_b okc_cov_ast,
         okl_k_lines okl,
         okc_line_styles_b style,
         okc_k_items item,
         okc_k_lines_v okc_fin
  WHERE  okc_cov_ast.cle_id = p_top_line_id
  AND    okc_cov_ast.dnz_chr_id = p_chr_id
  AND    okc_cov_ast.id = okl.id
  AND    okc_cov_ast.id = item.cle_id
  AND    okc_cov_ast.dnz_chr_id = item.dnz_chr_id
  AND    item.jtot_object1_code = 'OKX_COVASST'
  AND    okc_cov_ast.lse_id = style.id
  AND    style.lty_code = 'LINK_SERV_ASSET'
  AND    okc_fin.id = TO_NUMBER(item.object1_id1)
  AND    okc_fin.dnz_chr_id = p_chr_id
  --Bug# 8766336
  AND    okc_cov_ast.sts_code NOT IN ('TERMINATED','ABANDONED');

  CURSOR orig_service_asset_csr (p_sub_line_id NUMBER,
                                 p_chr_id      NUMBER) IS
  SELECT okc.orig_system_id1, okc.id line_id, okc.name, okc.item_description,
         okl.capital_amount,
         item.id item_id, item.object1_id1, item.object1_id2, item.jtot_object1_code
  FROM   okc_k_lines_v okc,
         okl_k_lines okl,
         okc_line_styles_b style,
         okc_k_items item
  WHERE  okc.id = p_sub_line_id
  AND    okc.dnz_chr_id = p_chr_id
  AND    okc.id = okl.id
  AND    okc.id = item.cle_id
  AND    okc.dnz_chr_id = item.dnz_chr_id
  AND    item.jtot_object1_code = 'OKX_COVASST'
  AND    okc.lse_id = style.id
  AND    style.lty_code = 'LINK_SERV_ASSET';

  upd NUMBER := 0;
  l_u_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  x_u_line_item_tbl okl_contract_line_item_pvt.line_item_tbl_type;
  ins NUMBER := 0;

     l_orig_freq_rule_id  NUMBER;
  l_orig_freq_rgp_id   NUMBER;
  l_orig_freq          OKC_RULES_V.OBJECT1_ID1%TYPE;
  l_orig_exp_rule_id   NUMBER;
  l_orig_exp_rgp_id    NUMBER;
  l_orig_exp_period    NUMBER;
  l_orig_exp_amount    NUMBER;
  x_rule_count         NUMBER;

  x_rulv_freq_rec     rulv_rec_type;
  x_rulv_exp_rec      rulv_rec_type;
  x_rulv_rec          rulv_rec_type;

  l_proc_name   VARCHAR2(35)    := 'SYNC_SERVICE_LINES';

  l_cov_ast_tbl  klev_tbl_type;
  lx_cov_ast_tbl klev_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    l_rbk_service_tbl.DELETE;
    i := 0;
    --
    -- Check for New SERVICE line being added during rebook
    --
    FOR rbk_service_rec IN rbk_new_service_csr(p_rebook_chr_id)
    LOOP
       i := i + 1;
       l_rbk_service_tbl(i).id := rbk_service_rec.id;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Service line: '||rbk_service_rec.id);
       END IF;
    END LOOP; -- rbk_service_csr

    IF (i > 0) THEN
       okl_copy_asset_pub.copy_all_lines(
                                         p_api_version        => 1.0,
                                         p_init_msg_list      => OKL_API.G_FALSE,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_from_cle_id_tbl    => l_rbk_service_tbl,
                                         p_to_cle_id          => NULL,
                                         p_to_chr_id          => p_orig_chr_id,
                                         p_to_template_yn     => 'N',
                                         p_copy_reference     => 'COPY',
                                         p_copy_line_party_yn => 'Y',
                                         p_renew_ref_yn       => 'N',
                                         p_trans_type         => 'CRB',
                                         x_cle_id_tbl         => lx_rbk_service_tbl
                                        );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE sync_service_failed;
       END IF;
    END IF;

    -- Bug# 8652738: Sync all existing service lines
    OPEN c_service_rbk_csr (cp_chr_id => p_rebook_chr_id);
    LOOP
      FETCH c_service_rbk_csr INTO c_service_rbk_rec;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Service Line: '|| c_service_rbk_rec.id);
      END IF;
      EXIT WHEN c_service_rbk_csr%NOTFOUND;
      OPEN c_service_orig_csr(cp_chr_id => p_orig_chr_id, cp_cle_id => c_service_rbk_rec.orig_system_id1);
      FETCH c_service_orig_csr INTO c_service_orig_rec;

      IF(c_service_orig_csr%NOTFOUND) THEN
        CLOSE c_service_orig_csr;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSE
        l_orig_service_top_line_id  := c_service_rbk_rec.orig_system_id1; -- for future use

        IF(
           (c_service_orig_rec.object1_id1 <> c_service_rbk_rec.object1_id1)
         OR(c_service_orig_rec.item_description <> c_service_rbk_rec.item_description)
         OR(NVL(c_service_orig_rec.amount,0) <> NVL(c_service_rbk_rec.amount,0))
         OR(TRUNC(NVL(c_service_orig_rec.end_date,OKL_API.G_MISS_DATE)) <> TRUNC(NVL(c_service_rbk_rec.end_date,OKL_API.G_MISS_DATE)))
         OR(NVL(c_service_orig_rec.attribute_category, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute_category, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute1, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute1, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute2, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute2, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute3, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute3, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute4, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute4, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute5, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute5, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute6, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute6, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute7, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute7, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute8, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute8, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute9, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute9, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute10, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute10, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute11, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute11, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute12, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute12, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute13, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute13, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute14, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute14, OKL_API.G_MISS_CHAR))
         OR(NVL(c_service_orig_rec.attribute15, OKL_API.G_MISS_CHAR) <> NVL(c_service_rbk_rec.attribute15, OKL_API.G_MISS_CHAR))

        )THEN

           l_orig_clev_rec.id                := c_service_orig_rec.id;
           l_orig_clev_rec.chr_id            := c_service_orig_rec.dnz_chr_id;
           l_orig_clev_rec.dnz_chr_id        := c_service_orig_rec.dnz_chr_id;
           l_orig_clev_rec.line_number       := c_service_orig_rec.line_number;
           l_orig_clev_rec.exception_yn      := c_service_orig_rec.exception_yn;
           l_orig_clev_rec.display_sequence  := c_service_orig_rec.display_sequence;
           l_orig_clev_rec.lse_id            := c_service_orig_rec.lse_id;
           l_orig_clev_rec.sts_code          := c_service_orig_rec.sts_code;
           l_orig_clev_rec.currency_code     := c_service_orig_rec.currency_code;
           l_orig_clev_rec.start_date        := c_service_orig_rec.start_date;

           l_orig_clev_rec.item_description  := c_service_rbk_rec.item_description;
           l_orig_clev_rec.end_date          := c_service_rbk_rec.end_date;

           l_orig_klev_rec.id                 := c_service_orig_rec.id;
           l_orig_klev_rec.kle_id             := c_service_orig_rec.kle_id;

           l_orig_klev_rec.attribute_category := c_service_rbk_rec.attribute_category;
           l_orig_klev_rec.attribute1         := c_service_rbk_rec.attribute1;
           l_orig_klev_rec.attribute2         := c_service_rbk_rec.attribute2;
           l_orig_klev_rec.attribute3         := c_service_rbk_rec.attribute3;
           l_orig_klev_rec.attribute4         := c_service_rbk_rec.attribute4;
           l_orig_klev_rec.attribute5         := c_service_rbk_rec.attribute5;
           l_orig_klev_rec.attribute6         := c_service_rbk_rec.attribute6;
           l_orig_klev_rec.attribute7         := c_service_rbk_rec.attribute7;
           l_orig_klev_rec.attribute8         := c_service_rbk_rec.attribute8;
           l_orig_klev_rec.attribute9         := c_service_rbk_rec.attribute9;
           l_orig_klev_rec.attribute10        := c_service_rbk_rec.attribute10;
           l_orig_klev_rec.attribute11        := c_service_rbk_rec.attribute11;
           l_orig_klev_rec.attribute12        := c_service_rbk_rec.attribute12;
           l_orig_klev_rec.attribute13        := c_service_rbk_rec.attribute13;
           l_orig_klev_rec.attribute14        := c_service_rbk_rec.attribute14;
           l_orig_klev_rec.attribute15        := c_service_rbk_rec.attribute15;
           l_orig_klev_rec.amount             := c_service_rbk_rec.amount;

           l_orig_cimv_rec.id                 := c_service_orig_rec.item_id;
           l_orig_cimv_rec.cle_id             := c_service_orig_rec.id;
           l_orig_cimv_rec.dnz_chr_id         := c_service_orig_rec.dnz_chr_id;
           l_orig_cimv_rec.exception_yn       := c_service_orig_rec.item_exception_yn;
           l_orig_cimv_rec.uom_code           := c_service_orig_rec.uom_code;
           l_orig_cimv_rec.number_of_items    := c_service_orig_rec.number_of_items;

           l_orig_cimv_rec.object1_id1        := c_service_rbk_rec.object1_id1;
           l_orig_cimv_rec.object1_id2        := c_service_rbk_rec.object1_id2;
           l_orig_cimv_rec.jtot_object1_code  := c_service_rbk_rec.jtot_object1_code;

           l_orig_cplv_rec.dnz_chr_id         := c_service_orig_rec.dnz_chr_id;
           l_orig_cplv_rec.cle_id             := c_service_orig_rec.id;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_clev_rec.id: '||l_orig_clev_rec.id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_clev_rec.dnz_chr_id: '||l_orig_clev_rec.dnz_chr_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_cimv_rec.id: '||l_orig_cimv_rec.id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_cimv_rec.object1_id1: '||l_orig_cimv_rec.object1_id1);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_cimv_rec.object1_id2: '||l_orig_cimv_rec.object1_id2);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_clev_rec.start_date: '||l_orig_clev_rec.start_date);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_clev_rec.end_date: '||l_orig_clev_rec.end_date);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_klev_rec.amount: '||l_orig_klev_rec.amount);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_clev_rec.item_description: '||l_orig_clev_rec.item_description);
          END IF;

          -- Update corresponding Orig service line
          okl_contract_top_line_pvt.update_contract_top_line(
                p_api_version   => 1.0,
                p_init_msg_list => OKL_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_clev_rec      => l_orig_clev_rec,
                p_klev_rec      => l_orig_klev_rec,
                p_cimv_rec      => l_orig_cimv_rec,
                p_cplv_rec      => l_orig_cplv_rec,
                x_clev_rec      => x_clev_rec,
                x_klev_rec      => x_klev_rec,
                x_cimv_rec      => x_cimv_rec,
                x_cplv_rec      => x_cplv_rec
               );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update Service Top line: '||x_return_status);
          END IF;

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE sync_service_failed;
          END IF;
        END IF;

        -- Sync Service line expense rules
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sync Service Line - Expense Rule');
        END IF;

        -- get original Expense rule LAFREQ
        get_rule_info(
          x_return_status => x_return_status,
          p_rebook_chr_id => p_orig_chr_id,
          p_rebook_cle_id => l_orig_service_top_line_id,
          p_rgd_code      => 'LAFEXP',
          p_rule_code     => 'LAFREQ',
          x_rulv_rec      => x_rulv_freq_rec,
          x_rule_count    => x_rule_count
        );

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_service_failed;
        END IF;

        l_orig_freq_rule_id := x_rulv_freq_rec.id;
        l_orig_freq_rgp_id  := x_rulv_freq_rec.rgp_id;
        l_orig_freq         := x_rulv_freq_rec.object1_id1;

        -- get rebook Expense rule LAFREQ
        get_rule_info(
          x_return_status => x_return_status,
          p_rebook_chr_id => p_rebook_chr_id,
          p_rebook_cle_id => c_service_rbk_rec.id,
          p_rgd_code      => 'LAFEXP',
          p_rule_code     => 'LAFREQ',
          x_rulv_rec      => x_rulv_freq_rec,
          x_rule_count    => x_rule_count
        );

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_service_failed;
        END IF;

        IF (l_orig_freq <> x_rulv_freq_rec.object1_id1) THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update Freq to: '||x_rulv_freq_rec.object1_id1);
          END IF;

          x_rulv_freq_rec.id     := l_orig_freq_rule_id;
          x_rulv_freq_rec.rgp_id := l_orig_freq_rgp_id;
          x_rulv_freq_rec.dnz_chr_id  := p_orig_chr_id;
          okl_rule_pub.update_rule(
            p_api_version   => 1.0,
            p_init_msg_list => OKL_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_rulv_rec      => x_rulv_freq_rec,
            x_rulv_rec      => x_rulv_rec
          );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update LAFREQ : '||x_return_status);
          END IF;

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            x_return_status := Okc_Api.G_RET_STS_ERROR;
            RAISE sync_service_failed;
          END IF;
        END IF;

        -- get original Expense rule LAFEXP
        get_rule_info(
          x_return_status => x_return_status,
          p_rebook_chr_id => p_orig_chr_id,
          p_rebook_cle_id => l_orig_service_top_line_id,
          p_rgd_code      => 'LAFEXP',
          p_rule_code     => 'LAFEXP',
          x_rulv_rec      => x_rulv_exp_rec,
          x_rule_count    => x_rule_count
        );

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_service_failed;
        END IF;

        l_orig_exp_rule_id  := x_rulv_exp_rec.id;
        l_orig_exp_rgp_id   := x_rulv_exp_rec.rgp_id;
        l_orig_exp_period   := x_rulv_exp_rec.rule_information1;
        l_orig_exp_amount   := x_rulv_exp_rec.rule_information2;

        -- get rebook Expense rule LAFEXP
        get_rule_info(
          x_return_status => x_return_status,
          p_rebook_chr_id => p_rebook_chr_id,
          p_rebook_cle_id => c_service_rbk_rec.id,
          p_rgd_code      => 'LAFEXP',
          p_rule_code     => 'LAFEXP',
          x_rulv_rec      => x_rulv_exp_rec,
          x_rule_count    => x_rule_count
        );
        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_service_failed;
        END IF;

        IF (l_orig_exp_period <> x_rulv_exp_rec.rule_information1 OR
            l_orig_exp_amount <> x_rulv_exp_rec.rule_information2) THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update period to: '||x_rulv_exp_rec.rule_information1);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update amount to: '||x_rulv_exp_rec.rule_information2);
          END IF;

          x_rulv_exp_rec.id     := l_orig_exp_rule_id;
          x_rulv_exp_rec.rgp_id := l_orig_exp_rgp_id;
          x_rulv_exp_rec.dnz_chr_id  := p_orig_chr_id;
          okl_rule_pub.update_rule(
            p_api_version   => 1.0,
            p_init_msg_list => OKL_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_rulv_rec      => x_rulv_exp_rec,
            x_rulv_rec      => x_rulv_rec
          );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update LAFEXP : '||x_return_status);
          END IF;

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
            x_return_status := Okc_Api.G_RET_STS_ERROR;
            RAISE sync_service_failed;
          END IF;
        END IF;

        -- Linked Service Asset
        upd := 0; -- update line count
        l_u_line_item_tbl.DELETE;

        l_cov_ast_tbl.DELETE;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update link asset for: '||c_service_rbk_rec.id);
        END IF;
        FOR rbk_service_asset_rec IN rbk_service_asset_csr (c_service_rbk_rec.id,
                                                            c_service_rbk_rec.dnz_chr_id)
        LOOP

           IF (rbk_service_asset_rec.orig_system_id1 IS NOT NULL) THEN -- update the line
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'--->Update Rebook Asset: '||rbk_service_asset_rec.line_id);
              END IF;
              FOR orig_service_asset_rec IN orig_service_asset_csr(rbk_service_asset_rec.orig_system_id1,
                                                                   p_orig_chr_id)
              LOOP
                -- Update existing line
                upd := upd + 1;
                l_u_line_item_tbl(upd).parent_cle_id      := l_orig_service_top_line_id;
                l_u_line_item_tbl(upd).cle_id             := orig_service_asset_rec.line_id;
                l_u_line_item_tbl(upd).chr_id             := p_orig_chr_id;
                l_u_line_item_tbl(upd).item_id            := orig_service_asset_rec.item_id;
                l_u_line_item_tbl(upd).item_id1           := rbk_service_asset_rec.object1_id1;
                l_u_line_item_tbl(upd).item_id2           := rbk_service_asset_rec.object1_id2;
                l_u_line_item_tbl(upd).item_object1_code  := rbk_service_asset_rec.jtot_object1_code;
                l_u_line_item_tbl(upd).name               := rbk_service_asset_rec.name;
                l_u_line_item_tbl(upd).item_description   := rbk_service_asset_rec.item_description;
                l_u_line_item_tbl(upd).capital_amount     := rbk_service_asset_rec.capital_amount;

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Update record: '||upd||': '||l_u_line_item_tbl(upd).name);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Capital amt: '||l_u_line_item_tbl(upd).capital_amount);
                END IF;
              END LOOP;
           ELSE
              -- Create new asset association line
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'--->Insert Rebook Asset: '||rbk_service_asset_rec.line_id);
              END IF;
              ins := ins + 1;
              --Bug# 4899328
              l_cov_ast_tbl(ins).id := rbk_service_asset_rec.line_id;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Insert record: '||ins||': '||rbk_service_asset_rec.name);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Capital amt: '||rbk_service_asset_rec.capital_amount);
              END IF;

           END IF;
        END LOOP; -- subline

        IF (l_u_line_item_tbl.COUNT > 0) THEN
           okl_contract_line_item_pvt.update_contract_line_item(
                  p_api_version     => 1.0,
                  p_init_msg_list   => OKL_API.G_FALSE,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_line_item_tbl   => l_u_line_item_tbl,
                  x_line_item_tbl   => x_u_line_item_tbl
                 );
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_service_failed;
           END IF;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Service asset updated; '||l_u_line_item_tbl.COUNT);
        END IF;

        IF (l_cov_ast_tbl.COUNT > 0) THEN
          okl_copy_asset_pub.copy_all_lines(
                                             p_api_version        => 1.0,
                                             p_init_msg_list      => OKC_API.G_FALSE,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data,
                                             P_from_cle_id_tbl    => l_cov_ast_tbl,
                                             p_to_chr_id          => NULL,
                                             p_to_cle_id          => l_orig_service_top_line_id,
                                             p_to_template_yn     => 'N',
                                             p_copy_reference     => 'Y',
                                             p_copy_line_party_yn => 'Y',
                                             p_renew_ref_yn       => 'N',
                                             p_trans_type         => 'CRB',
                                             x_cle_id_tbl         => lx_cov_ast_tbl
                                            );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE sync_service_failed;
          END IF;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Link Service asset inserted; '||l_cov_ast_tbl.COUNT);
        END IF;

      END IF;
      CLOSE c_service_orig_csr;
    END LOOP; -- c_service_rbk_rec
    CLOSE c_service_rbk_csr;

  EXCEPTION
    WHEN sync_service_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;

    when OKL_API.G_EXCEPTION_ERROR then
       x_return_status := 'OKC_API.G_RET_STS_ERROR';

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
       x_return_status := 'OKC_API.G_RET_STS_UNEXP_ERROR';

  END sync_service_line;

------------------------------------------------------------------------------
-- PROCEDURE sync_line_terms_conditions
--
--  This procedure synchronizes Rebook and Original Contract Terms and Conditions
--  that have been defined for Asset lines
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_line_terms_conditions (
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                           ) IS

  l_proc_name VARCHAR2(35) := 'SYNC_LINE_TERMS_CONDITIONS';
  sync_terms_failed EXCEPTION;

  l_rul_rbk_rec  rulv_rec_type;
  l_rul_orig_rec rulv_rec_type;

  l_rulv_rec     rulv_rec_type;
  x_rulv_rec     rulv_rec_type;

  x_rgp_id       OKC_RULE_GROUPS_B.id%TYPE;

  l_rgpv_rec     rgpv_rec_type;

  CURSOR l_rgp_orig_csr(p_chr_id IN NUMBER) IS
  SELECT rgp.id,
         rgp.rgd_code,
         rgp.cle_id
  FROM okc_rule_groups_b rgp
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   rgp.cle_id IS NOT NULL
  AND   rgp.rgd_code IN
    (G_ASSET_FILING_RGP, G_BILLING_SETUP_RGP, G_ASSET_TAXES_AND_DUTIES_RGP);

  CURSOR l_rgp_rbk_csr(p_chr_id       IN NUMBER,
                       p_rgd_code     IN VARCHAR2,
                       p_orig_cle_id  IN NUMBER) IS
  SELECT rgp.id
  FROM okc_rule_groups_b rgp,
       okc_k_lines_b cle
  WHERE cle.dnz_chr_id = p_chr_id
  AND   cle.chr_id = p_chr_id
  AND   cle.orig_system_id1 = p_orig_cle_id
  AND   rgp.dnz_chr_id = cle.chr_id
  AND   rgp.cle_id     = cle.id
  AND   rgp.rgd_code   = p_rgd_code;

  l_rgp_rbk_rec l_rgp_rbk_csr%ROWTYPE;

  CURSOR l_rul_orig_csr(p_rgp_id IN NUMBER,
                        p_chr_id IN NUMBER) IS
  SELECT rul_orig.ID,
         rul_orig.OBJECT_VERSION_NUMBER,
         rul_orig.SFWT_FLAG,
         rul_orig.OBJECT1_ID1,
         rul_orig.OBJECT2_ID1,
         rul_orig.OBJECT3_ID1,
         rul_orig.OBJECT1_ID2,
         rul_orig.OBJECT2_ID2,
         rul_orig.OBJECT3_ID2,
         rul_orig.JTOT_OBJECT1_CODE,
         rul_orig.JTOT_OBJECT2_CODE,
         rul_orig.JTOT_OBJECT3_CODE,
         rul_orig.DNZ_CHR_ID,
         rul_orig.RGP_ID,
         rul_orig.PRIORITY,
         rul_orig.STD_TEMPLATE_YN,
         rul_orig.COMMENTS,
         rul_orig.WARN_YN,
         rul_orig.ATTRIBUTE_CATEGORY,
         rul_orig.ATTRIBUTE1,
         rul_orig.ATTRIBUTE2,
         rul_orig.ATTRIBUTE3,
         rul_orig.ATTRIBUTE4,
         rul_orig.ATTRIBUTE5,
         rul_orig.ATTRIBUTE6,
         rul_orig.ATTRIBUTE7,
         rul_orig.ATTRIBUTE8,
         rul_orig.ATTRIBUTE9,
         rul_orig.ATTRIBUTE10,
         rul_orig.ATTRIBUTE11,
         rul_orig.ATTRIBUTE12,
         rul_orig.ATTRIBUTE13,
         rul_orig.ATTRIBUTE14,
         rul_orig.ATTRIBUTE15,
         rul_orig.CREATED_BY,
         rul_orig.CREATION_DATE,
         rul_orig.LAST_UPDATED_BY,
         rul_orig.LAST_UPDATE_DATE,
         rul_orig.LAST_UPDATE_LOGIN,
         --rul_orig.TEXT,
         rul_orig.RULE_INFORMATION_CATEGORY,
         rul_orig.RULE_INFORMATION1,
         rul_orig.RULE_INFORMATION2,
         rul_orig.RULE_INFORMATION3,
         rul_orig.RULE_INFORMATION4,
         rul_orig.RULE_INFORMATION5,
         rul_orig.RULE_INFORMATION6,
         rul_orig.RULE_INFORMATION7,
         rul_orig.RULE_INFORMATION8,
         rul_orig.RULE_INFORMATION9,
         rul_orig.RULE_INFORMATION10,
         rul_orig.RULE_INFORMATION11,
         rul_orig.RULE_INFORMATION12,
         rul_orig.RULE_INFORMATION13,
         rul_orig.RULE_INFORMATION14,
         rul_orig.RULE_INFORMATION15,
         rul_orig.TEMPLATE_YN,
         rul_orig.ANS_SET_JTOT_OBJECT_CODE,
         rul_orig.ANS_SET_JTOT_OBJECT_ID1,
         rul_orig.ANS_SET_JTOT_OBJECT_ID2,
         rul_orig.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_orig
  WHERE rul_orig.dnz_chr_id = p_chr_id
  AND   rul_orig.rgp_id     = p_rgp_id;

  CURSOR l_rul_rbk_csr(p_rgp_id IN NUMBER,
                       p_chr_id IN NUMBER,
                       p_rul_info_cat IN VARCHAR2) IS
  SELECT rul_rbk.ID,
         rul_rbk.OBJECT_VERSION_NUMBER,
         rul_rbk.SFWT_FLAG,
         rul_rbk.OBJECT1_ID1,
         rul_rbk.OBJECT2_ID1,
         rul_rbk.OBJECT3_ID1,
         rul_rbk.OBJECT1_ID2,
         rul_rbk.OBJECT2_ID2,
         rul_rbk.OBJECT3_ID2,
         rul_rbk.JTOT_OBJECT1_CODE,
         rul_rbk.JTOT_OBJECT2_CODE,
         rul_rbk.JTOT_OBJECT3_CODE,
         rul_rbk.DNZ_CHR_ID,
         rul_rbk.RGP_ID,
         rul_rbk.PRIORITY,
         rul_rbk.STD_TEMPLATE_YN,
         rul_rbk.COMMENTS,
         rul_rbk.WARN_YN,
         rul_rbk.ATTRIBUTE_CATEGORY,
         rul_rbk.ATTRIBUTE1,
         rul_rbk.ATTRIBUTE2,
         rul_rbk.ATTRIBUTE3,
         rul_rbk.ATTRIBUTE4,
         rul_rbk.ATTRIBUTE5,
         rul_rbk.ATTRIBUTE6,
         rul_rbk.ATTRIBUTE7,
         rul_rbk.ATTRIBUTE8,
         rul_rbk.ATTRIBUTE9,
         rul_rbk.ATTRIBUTE10,
         rul_rbk.ATTRIBUTE11,
         rul_rbk.ATTRIBUTE12,
         rul_rbk.ATTRIBUTE13,
         rul_rbk.ATTRIBUTE14,
         rul_rbk.ATTRIBUTE15,
         rul_rbk.CREATED_BY,
         rul_rbk.CREATION_DATE,
         rul_rbk.LAST_UPDATED_BY,
         rul_rbk.LAST_UPDATE_DATE,
         rul_rbk.LAST_UPDATE_LOGIN,
         --rul_rbk.TEXT,
         rul_rbk.RULE_INFORMATION_CATEGORY,
         rul_rbk.RULE_INFORMATION1,
         rul_rbk.RULE_INFORMATION2,
         rul_rbk.RULE_INFORMATION3,
         rul_rbk.RULE_INFORMATION4,
         rul_rbk.RULE_INFORMATION5,
         rul_rbk.RULE_INFORMATION6,
         rul_rbk.RULE_INFORMATION7,
         rul_rbk.RULE_INFORMATION8,
         rul_rbk.RULE_INFORMATION9,
         rul_rbk.RULE_INFORMATION10,
         rul_rbk.RULE_INFORMATION11,
         rul_rbk.RULE_INFORMATION12,
         rul_rbk.RULE_INFORMATION13,
         rul_rbk.RULE_INFORMATION14,
         rul_rbk.RULE_INFORMATION15,
         rul_rbk.TEMPLATE_YN,
         rul_rbk.ANS_SET_JTOT_OBJECT_CODE,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID1,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID2,
         rul_rbk.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_rbk
  WHERE rul_rbk.dnz_chr_id = p_chr_id
  AND   rul_rbk.rgp_id     = p_rgp_id
  AND   rul_rbk.rule_information_category = p_rul_info_cat;

  CURSOR l_rbk_new_rgp_csr(p_orig_chr_id    IN NUMBER,
                           p_rebook_chr_id  IN NUMBER) IS
  SELECT rgp_rbk.id,
         cle_rbk.orig_system_id1
  FROM okc_rule_groups_b rgp_rbk,
       okc_k_lines_b cle_rbk
  WHERE cle_rbk.dnz_chr_id = p_rebook_chr_id
  AND   cle_rbk.chr_id = p_rebook_chr_id
  AND   cle_rbk.orig_system_id1 IS NOT NULL
  AND   rgp_rbk.dnz_chr_id = cle_rbk.chr_id
  AND   rgp_rbk.cle_id = cle_rbk.id
  AND   rgp_rbk.rgd_code IN (G_ASSET_FILING_RGP, G_BILLING_SETUP_RGP, G_ASSET_TAXES_AND_DUTIES_RGP)
  AND NOT EXISTS (SELECT 1
                  FROM okc_rule_groups_b rgp_orig
                  WHERE rgp_orig.dnz_chr_id = p_orig_chr_id
                  AND rgp_orig.cle_id = cle_rbk.orig_system_id1
                  AND rgp_orig.rgd_code = rgp_rbk.rgd_code);

  CURSOR l_rbk_new_rul_csr(p_orig_chr_id    IN NUMBER,
                           p_rebook_chr_id  IN NUMBER,
                           p_orig_rgp_id    IN NUMBER,
                           p_rbk_rgp_id     IN NUMBER) IS
  SELECT rul_rbk.ID,
         rul_rbk.OBJECT_VERSION_NUMBER,
         rul_rbk.SFWT_FLAG,
         rul_rbk.OBJECT1_ID1,
         rul_rbk.OBJECT2_ID1,
         rul_rbk.OBJECT3_ID1,
         rul_rbk.OBJECT1_ID2,
         rul_rbk.OBJECT2_ID2,
         rul_rbk.OBJECT3_ID2,
         rul_rbk.JTOT_OBJECT1_CODE,
         rul_rbk.JTOT_OBJECT2_CODE,
         rul_rbk.JTOT_OBJECT3_CODE,
         rul_rbk.DNZ_CHR_ID,
         rul_rbk.RGP_ID,
         rul_rbk.PRIORITY,
         rul_rbk.STD_TEMPLATE_YN,
         rul_rbk.COMMENTS,
         rul_rbk.WARN_YN,
         rul_rbk.ATTRIBUTE_CATEGORY,
         rul_rbk.ATTRIBUTE1,
         rul_rbk.ATTRIBUTE2,
         rul_rbk.ATTRIBUTE3,
         rul_rbk.ATTRIBUTE4,
         rul_rbk.ATTRIBUTE5,
         rul_rbk.ATTRIBUTE6,
         rul_rbk.ATTRIBUTE7,
         rul_rbk.ATTRIBUTE8,
         rul_rbk.ATTRIBUTE9,
         rul_rbk.ATTRIBUTE10,
         rul_rbk.ATTRIBUTE11,
         rul_rbk.ATTRIBUTE12,
         rul_rbk.ATTRIBUTE13,
         rul_rbk.ATTRIBUTE14,
         rul_rbk.ATTRIBUTE15,
         rul_rbk.CREATED_BY,
         rul_rbk.CREATION_DATE,
         rul_rbk.LAST_UPDATED_BY,
         rul_rbk.LAST_UPDATE_DATE,
         rul_rbk.LAST_UPDATE_LOGIN,
         --rul_rbk.TEXT,
         rul_rbk.RULE_INFORMATION_CATEGORY,
         rul_rbk.RULE_INFORMATION1,
         rul_rbk.RULE_INFORMATION2,
         rul_rbk.RULE_INFORMATION3,
         rul_rbk.RULE_INFORMATION4,
         rul_rbk.RULE_INFORMATION5,
         rul_rbk.RULE_INFORMATION6,
         rul_rbk.RULE_INFORMATION7,
         rul_rbk.RULE_INFORMATION8,
         rul_rbk.RULE_INFORMATION9,
         rul_rbk.RULE_INFORMATION10,
         rul_rbk.RULE_INFORMATION11,
         rul_rbk.RULE_INFORMATION12,
         rul_rbk.RULE_INFORMATION13,
         rul_rbk.RULE_INFORMATION14,
         rul_rbk.RULE_INFORMATION15,
         rul_rbk.TEMPLATE_YN,
         rul_rbk.ANS_SET_JTOT_OBJECT_CODE,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID1,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID2,
         rul_rbk.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_rbk
  WHERE rul_rbk.dnz_chr_id = p_rebook_chr_id
  AND   rul_rbk.rgp_id = p_rbk_rgp_id
  AND NOT EXISTS (SELECT 1
                  FROM okc_rules_b rul_orig
                  WHERE rul_orig.dnz_chr_id = p_orig_chr_id
                  AND rul_orig.rgp_id = p_orig_rgp_id
                  AND rul_orig.rule_information_category = rul_rbk.rule_information_category);

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Sync rule groups that existed on the original contract
    FOR l_rgp_orig_rec IN l_rgp_orig_csr(p_chr_id => p_orig_chr_id) LOOP

      l_rgp_rbk_rec := NULL;
      OPEN l_rgp_rbk_csr(p_chr_id      => p_rebook_chr_id,
                         p_rgd_code    => l_rgp_orig_rec.rgd_code,
                         p_orig_cle_id => l_rgp_orig_rec.cle_id);
      FETCH l_rgp_rbk_csr INTO l_rgp_rbk_rec;
      CLOSE l_rgp_rbk_csr;

      -- Rule group exists on rebook copy contract
      IF (l_rgp_rbk_rec.id IS NOT NULL) THEN

        FOR l_rul_orig_rec IN l_rul_orig_csr(p_rgp_id => l_rgp_orig_rec.id,
                                             p_chr_id => p_orig_chr_id) LOOP

          l_rul_rbk_rec := NULL;
          OPEN l_rul_rbk_csr(p_rgp_id       => l_rgp_orig_rec.id,
                             p_chr_id       => p_rebook_chr_id,
                             p_rul_info_cat => l_rul_orig_rec.rule_information_category);
          FETCH l_rul_rbk_csr INTO l_rul_rbk_rec;
          CLOSE l_rul_rbk_csr;

          -- Rule exists on rebook copy contract
          IF (l_rul_rbk_rec.id IS NOT NULL) THEN

            -- Check for changes during rebook
            IF (NVL(l_rul_rbk_rec.rule_information1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information3,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information3,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information4,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information4,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information5,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information5,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information6,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information6,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information7,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information7,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information8,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information8,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information9,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information9,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information10,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information10,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information11,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information11,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information12,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information12,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information13,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information13,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information14,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information14,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information15,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information15,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object1_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object1_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object2_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object2_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object3_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object3_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object1_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object1_id2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object2_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object2_id2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object3_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object3_id2,OKL_API.G_MISS_CHAR)
               ) THEN

                   l_rul_rbk_rec.id         := l_rul_orig_rec.id;
                   l_rul_rbk_rec.rgp_id     := l_rul_orig_rec.rgp_id;
                   l_rul_rbk_rec.dnz_chr_id := l_rul_orig_rec.dnz_chr_id;

                   okl_rule_pub.update_rule(
                                        p_api_version   => 1.0,
                                        p_init_msg_list => OKL_API.G_FALSE,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_rulv_rec      => l_rul_rbk_rec,
                                        x_rulv_rec      => x_rulv_rec
                                       );

                   IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                     RAISE sync_terms_failed;
                   END IF;

            END IF;
          -- Rule has been deleted on rebook copy contract,
          -- Delete rule from original contract
          ELSE

            l_rulv_rec.id         := l_rul_orig_rec.id;

            okl_rule_pub.delete_rule(
              p_api_version    => 1.0,
              p_init_msg_list  => OKL_API.G_FALSE,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_rulv_rec       => l_rulv_rec);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_terms_failed;
            END IF;

          END IF;
        END LOOP;

        -- Sync rules that were added on the rebook copy contract
        l_rul_rbk_rec := NULL;
        OPEN l_rbk_new_rul_csr(p_orig_chr_id    => p_orig_chr_id,
                               p_rebook_chr_id  => p_rebook_chr_id,
                               p_orig_rgp_id    => l_rgp_orig_rec.id,
                               p_rbk_rgp_id     => l_rgp_rbk_rec.id);

        LOOP
          FETCH l_rbk_new_rul_csr INTO l_rul_rbk_rec;
          EXIT WHEN l_rbk_new_rul_csr%NOTFOUND;

          l_rul_rbk_rec.id         := NULL;
          l_rul_rbk_rec.rgp_id     := l_rgp_orig_rec.id;
          l_rul_rbk_rec.dnz_chr_id := p_orig_chr_id;

          okl_rule_pub.create_rule(
            p_api_version    => 1.0,
            p_init_msg_list  => OKL_API.G_FALSE,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rulv_rec       => l_rul_rbk_rec,
            x_rulv_rec       => x_rulv_rec);

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            CLOSE l_rbk_new_rul_csr;
            RAISE sync_terms_failed;
          END IF;

        END LOOP;
        CLOSE l_rbk_new_rul_csr;


      -- Rule group has been deleted on rebook copy contract,
      -- Delete rule group from original contract
      ELSE

        l_rgpv_rec.id         := l_rgp_orig_rec.id;

        okl_rule_pub.delete_rule_group(
          p_api_version     => 1.0,
          p_init_msg_list   => OKL_API.G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_rgpv_rec        => l_rgpv_rec);

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_terms_failed;
        END IF;

      END IF;
    END LOOP;

    -- Sync rule groups that were added on the rebook copy contract
    FOR l_rbk_new_rgp_rec IN l_rbk_new_rgp_csr(p_orig_chr_id    => p_orig_chr_id,
                                               p_rebook_chr_id  => p_rebook_chr_id) LOOP

      okl_copy_contract_pvt.copy_rules(
        p_api_version     => 1.0,
        p_init_msg_list   => OKL_API.G_FALSE,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_rgp_id          => l_rbk_new_rgp_rec.id,
        p_cle_id          => l_rbk_new_rgp_rec.orig_system_id1,
        p_chr_id          => NULL,
        p_to_template_yn  => 'N',
        x_rgp_id          => x_rgp_id);

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_terms_failed;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN sync_terms_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_line_terms_conditions;

------------------------------------------------------------------------------
-- PROCEDURE sync_line_values
--
--  This procedure synchronizes Rebook and Original Contract Line Values
--  Sync 1. Adjust Residual Value
--       2. Adjust Cost
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_line_values(
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                             p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                             x_new_klev_tbl  OUT NOCOPY klev_tbl_type,
                             x_new_clev_tbl  OUT NOCOPY clev_tbl_type
                            ) IS

  l_proc_name   VARCHAR2(35)    := 'SYNC_LINE_VALUES';
  sync_failed   EXCEPTION;

  -- Sync only Financial Asset and child lines
  CURSOR rebook_line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT *
  FROM   okl_k_lines_full_v
  WHERE  dnz_chr_id = p_chr_id
  AND    orig_system_id1 IS NOT NULL
  AND    lse_id in (33,34,42,43,44,45,70)
  --Bug# 8766336
  AND    sts_code <> 'ABANDONED';

  CURSOR rebook_new_line_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.*
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v  style
  WHERE  line.dnz_chr_id = p_chr_id
  AND    line.lse_id     = style.id
  AND    style.lty_code  = 'FREE_FORM1'
  AND    orig_system_id1 IS NULL
  --Bug# 8766336
  AND    line.sts_code <> 'ABANDONED';

  --Bug# 5207066
  CURSOR rebook_new_ib_line_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.*,
         parent_cle.orig_system_id1 parent_orig_system_id1,
         parent_cle.start_date parent_orig_start_date
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v  style,
         okc_k_lines_b parent_cle
  WHERE  line.dnz_chr_id = p_chr_id
  AND    line.lse_id     = style.id
  AND    style.lty_code  = 'FREE_FORM2'
  AND    line.orig_system_id1 IS NULL
  AND    parent_cle.orig_system_id1 IS NOT NULL
  AND    line.cle_id = parent_cle.id
  AND    line.dnz_chr_id = parent_cle.dnz_chr_id
  --Bug# 8766336
  AND    line.sts_code <> 'ABANDONED';

  CURSOR del_rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    rgd_code   = 'LALEVL';

  CURSOR rule_csr(p_rgp_id NUMBER) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  rgp_id = p_rgp_id;

  CURSOR rebook_new_all_line_csr (p_top_line_id NUMBER) IS
  SELECT id,
         start_date
  FROM 	 okc_k_lines_b
  CONNECT BY  PRIOR id = cle_id
  START WITH  id = p_top_line_id;
  --Bug# 5362977 start
  --Bug# 5207066 - bug start
   CURSOR items_csr(p_cle_id NUMBER) IS
   SELECT cim.id,
          cim.cle_id,
          cim.number_of_items,
          cim.object1_id1,
	  cim.object1_id2,
	  cim.jtot_object1_code,
	  cle.lse_id
   FROM   okc_k_items cim,
           okc_k_lines_b cle
   WHERE  cim.cle_id = cle.id
   AND    cle.id = p_cle_id;
   l_items_rec     items_csr%ROWTYPE;
   l_items_old_rec items_csr%ROWTYPE;

     l_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
     x_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
     --  bug 5121256 end




  CURSOR party_roles_csr(p_cle_id IN NUMBER,
                       p_chr_id IN NUMBER) IS
   SELECT   cpl.id,
            cpl.object1_id1,
            cpl.object1_id2,
            cpl.jtot_object1_code,
            cpl.rle_code
     FROM   okc_k_party_roles_b cpl
     WHERE  cpl.cle_id = p_cle_id
     AND    cpl.dnz_chr_id = p_chr_id
     AND    cpl.jtot_object1_code = 'OKX_VENDOR';
  l_item_cle_id_old okc_k_items.cle_id%type;
  l_item_id_old     okc_k_items.id%type;

  l_party_roles_new_rec party_roles_csr%ROWTYPE;
l_party_roles_old_rec party_roles_csr%ROWTYPE;

l_cplv_rec      cplv_rec_type;
x_cplv_rec      cplv_rec_type;
--  bug 5121256 end

l_cplv_temp_rec cplv_rec_type;
l_cim_temp_rec  okl_okc_migration_pvt.cimv_rec_type;

x_cpl_id        NUMBER;
--Bug# 5362977 end

  --Bug# 5207066 end

  l_clev_tbl      clev_tbl_type;
  l_klev_tbl      klev_tbl_type;

  x_clev_tbl      clev_tbl_type;
  x_klev_tbl      klev_tbl_type;

  l_new_klev_tbl  klev_tbl_type;
  lx_new_klev_tbl klev_tbl_type;
  x_cle_id        OKC_K_LINES_V.ID%TYPE;
  i               NUMBER := 0;
  j               NUMBER := 0;
  k               NUMBER := 0;
  m               NUMBER := 0;
  l_tran_date     DATE;

  l_rulv_tbl      rulv_tbl_type;
  l_r_count NUMBER;

  --Bug# 5207066
  l_temp_klev_tbl  klev_tbl_type;

  --Bug# 8652738
  CURSOR rebook_new_addon_line_csr(p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT line.*,
         parent_cle.orig_system_id1 parent_orig_system_id1,
         parent_cle.start_date parent_orig_start_date
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v  style,
         okc_k_lines_b parent_cle
  WHERE line.dnz_chr_id = p_chr_id
  AND    line.lse_id     = style.id
  AND    style.lty_code  = 'ADD_ITEM'
  AND    line.orig_system_id1 IS NULL
  AND    parent_cle.orig_system_id1 IS NOT NULL
  AND    line.cle_id = parent_cle.id
  AND    line.dnz_chr_id = parent_cle.dnz_chr_id
  --Bug# 8766336
  AND    line.sts_code <> 'ABANDONED';

  l_sidv_rec      OKL_SUPP_INVOICE_DTLS_PVT.sidv_rec_type;
  x_sidv_rec      OKL_SUPP_INVOICE_DTLS_PVT.sidv_rec_type;
  l_sidv_temp_rec OKL_SUPP_INVOICE_DTLS_PVT.sidv_rec_type;

  CURSOR supp_invoice_dtls_csr(p_cle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT id,
         cle_id,
         fa_cle_id,
         invoice_number,
         date_invoiced,
         shipping_address_id1,
         shipping_address_id2,
         shipping_address_code
  FROM okl_supp_invoice_dtls
  WHERE cle_id = p_cle_id;

  CURSOR orig_fa_cle_csr(p_rbk_fa_cle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT orig_system_id1
  FROM   okc_k_lines_b cleb_fa
  WHERE  id = p_rbk_fa_cle_id;

  l_orig_fa_cle_id       OKC_K_LINES_B.id%TYPE;
  l_supp_invoice_old_rec supp_invoice_dtls_csr%ROWTYPE;
  l_supp_invoice_new_rec supp_invoice_dtls_csr%ROWTYPE;
  --Bug# 8652738

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;


    -- Delete Line level existing SLH, SLL from Original Contract

    i := 1;
    FOR del_rgp_rec IN del_rgp_csr(p_orig_chr_id)
    LOOP
       FOR rule_rec IN rule_csr(del_rgp_rec.id)
       LOOP
          l_rulv_tbl(i).id := rule_rec.id;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Rule Deleted: '||l_rulv_tbl(i).id);
          END IF;
          i := i+ 1;
       END LOOP;
    END LOOP;

    okl_rule_pub.delete_rule(
                             p_api_version    => 1.0,
                             p_init_msg_list  => OKC_API.G_FALSE,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_rulv_tbl       => l_rulv_tbl
                            );
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      RAISE sync_failed;
    END IF;

    i := 1;
    FOR rebook_line_rec IN rebook_line_csr(p_rebook_chr_id)
    LOOP

       IF (rebook_line_rec.orig_system_id1 IS NOT NULL) THEN -- Old Line, Update

          l_clev_tbl(i).id                    := rebook_line_rec.orig_system_id1;
          l_klev_tbl(i).id                    := rebook_line_rec.orig_system_id1;
          l_klev_tbl(i).residual_percentage   := rebook_line_rec.residual_percentage;
          l_klev_tbl(i).residual_value        := rebook_line_rec.residual_value;
          l_klev_tbl(i).residual_grnty_amount := rebook_line_rec.residual_grnty_amount;
          l_klev_tbl(i).oec                   := rebook_line_rec.oec;
          l_klev_tbl(i).capital_amount        := rebook_line_rec.capital_amount;

          -- sjalasut, added for rebook change control enhancement. START
          l_klev_tbl(i).tradein_amount := rebook_line_rec.tradein_amount;
          -- sjalasut, added for rebook change control enhancement. END

           --Bug# 8652738
          l_klev_tbl(i).capital_reduction          := rebook_line_rec.capital_reduction;
          l_klev_tbl(i).capital_reduction_percent  := rebook_line_rec.capital_reduction_percent;
          l_klev_tbl(i).down_payment_receiver_code := rebook_line_rec.down_payment_receiver_code;
          l_klev_tbl(i).capitalize_down_payment_yn := rebook_line_rec.capitalize_down_payment_yn;
          l_klev_tbl(i).residual_code              := rebook_line_rec.residual_code;

          l_klev_tbl(i).manufacturer_name          := rebook_line_rec.manufacturer_name;
          l_klev_tbl(i).model_number               := rebook_line_rec.model_number;
          l_klev_tbl(i).year_of_manufacture        := rebook_line_rec.year_of_manufacture;

          l_clev_tbl(i).comments                   := rebook_line_rec.comments;

          l_klev_tbl(i).prescribed_asset_yn        := rebook_line_rec.prescribed_asset_yn;
          l_klev_tbl(i).date_funding_expected      := rebook_line_rec.date_funding_expected;
          l_klev_tbl(i).date_delivery_expected     := rebook_line_rec.date_delivery_expected;

          l_clev_tbl(i).bill_to_site_use_id        := rebook_line_rec.bill_to_site_use_id;
          --Bug# 8652738

          --Bug# 4558486
          l_klev_tbl(i).attribute_category    := rebook_line_rec.okl_attribute_category;
          l_klev_tbl(i).attribute1            := rebook_line_rec.okl_attribute1;
          l_klev_tbl(i).attribute2            := rebook_line_rec.okl_attribute2;
          l_klev_tbl(i).attribute3            := rebook_line_rec.okl_attribute3;
          l_klev_tbl(i).attribute4            := rebook_line_rec.okl_attribute4;
          l_klev_tbl(i).attribute5            := rebook_line_rec.okl_attribute5;
          l_klev_tbl(i).attribute6            := rebook_line_rec.okl_attribute6;
          l_klev_tbl(i).attribute7            := rebook_line_rec.okl_attribute7;
          l_klev_tbl(i).attribute8            := rebook_line_rec.okl_attribute8;
          l_klev_tbl(i).attribute9            := rebook_line_rec.okl_attribute9;
          l_klev_tbl(i).attribute10           := rebook_line_rec.okl_attribute10;
          l_klev_tbl(i).attribute11           := rebook_line_rec.okl_attribute11;
          l_klev_tbl(i).attribute12           := rebook_line_rec.okl_attribute12;
          l_klev_tbl(i).attribute13           := rebook_line_rec.okl_attribute13;
          l_klev_tbl(i).attribute14           := rebook_line_rec.okl_attribute14;
          l_klev_tbl(i).attribute15           := rebook_line_rec.okl_attribute15;
          --Bug# 4558486

          l_clev_tbl(i).price_unit            := rebook_line_rec.price_unit;

	   --akrangan Bug# 5362977 start
             l_klev_tbl(i).year_built            := rebook_line_rec.year_built;
             l_clev_tbl(i).item_description      := rebook_line_rec.item_description;
           --akrangan Bug# 5362977 end
           --akrangan Bug# 5362977 start

          --Bug# 5207066 -- start

             l_items_rec := NULL;
             OPEN  items_csr(rebook_line_rec.id); -- rebook_line_rec.id
             FETCH items_csr INTO l_items_rec;
             CLOSE items_csr;

             l_items_old_rec := NULL;
             OPEN  items_csr(l_clev_tbl(i).id); -- original contract
             FETCH items_csr INTO l_items_old_rec;
             CLOSE items_csr;

             l_cim_rec := l_cim_temp_rec;
             IF l_items_old_rec.id IS NOT NULL AND
               (l_items_old_rec.number_of_items IS NOT NULL OR
                l_items_rec.number_of_items IS NOT NULL) THEN

               l_cim_rec.id := l_items_old_rec.id;
               l_cim_rec.cle_id := l_items_old_rec.cle_id;
               l_cim_rec.number_of_items := l_items_rec.number_of_items;

               --Bug# 8652738
               IF l_items_old_rec.lse_id IN (34,44) THEN -- Model Line and Add On Line

                 -- Sync Inventory Item
                 l_cim_rec.object1_id1 := l_items_rec.object1_id1;
                 l_cim_rec.object1_id2 := l_items_rec.object1_id2;
                 l_cim_rec.jtot_object1_code := l_items_rec.jtot_object1_code;

                 --Sync Supplier Invoice
                 l_party_roles_new_rec := NULL;
                 open party_roles_csr(p_cle_id => rebook_line_rec.id,
                                      p_chr_id => p_rebook_chr_id);
                 fetch party_roles_csr into l_party_roles_new_rec;
                 close party_roles_csr;

                 if l_party_roles_new_rec.id is not null then

                   l_party_roles_old_rec := NULL;
                   open party_roles_csr(p_cle_id => l_clev_tbl(i).id,
                                        p_chr_id => p_orig_chr_id);
                   fetch party_roles_csr into l_party_roles_old_rec;
                   close party_roles_csr;

                   if l_party_roles_old_rec.id is null then
                     -- Supplier Invoice added during rebook

                     okl_copy_contract_pub.copy_party_roles(
                       p_api_version     => 1.0,
                       p_init_msg_list   => OKL_API.G_FALSE,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data,
                       p_cpl_id          => l_party_roles_new_rec.id,
                       p_cle_id          => l_clev_tbl(i).id,
                       p_chr_id          => NULL,
                       p_rle_code        => l_party_roles_new_rec.rle_code,
                       x_cpl_id            => x_cpl_id
                       );
		         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
		           okl_debug_pub.logmessage('okl_copy_contract_pub.copy_party_roles sync_failed ');
		           RAISE sync_failed;
		         END IF;

		       elsif (l_party_roles_old_rec.object1_id1 <> l_party_roles_new_rec.object1_id1) then
                   -- Supplier Invoice updated during rebook

                     l_cplv_rec := l_cplv_temp_rec;

                     l_cplv_rec.id := l_party_roles_old_rec.id;
                     l_cplv_rec.object1_id1 := l_party_roles_new_rec.object1_id1;
                     l_cplv_rec.object1_id2 := l_party_roles_new_rec.object1_id2;
                     l_cplv_rec.jtot_object1_code := l_party_roles_new_rec.jtot_object1_code;
                     l_cplv_rec.rle_code := l_party_roles_new_rec.rle_code;

                     okl_okc_migration_pvt.update_k_party_role(
                       p_api_version   => 1.0,
                       p_init_msg_list => OKL_API.G_FALSE,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_cplv_rec      => l_cplv_rec,
                       x_cplv_rec      => x_cplv_rec);

                     -- check return status
                     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                       okl_debug_pub.logmessage(' okl_okc_migration_pvt.update_contract_item sync_failed ');
                       RAISE sync_failed;
                     END IF;

                   end if;

                   l_supp_invoice_new_rec := NULL;
                   OPEN  supp_invoice_dtls_csr(rebook_line_rec.id); -- rebook_line_rec.id
                   FETCH supp_invoice_dtls_csr INTO l_supp_invoice_new_rec;
                   CLOSE supp_invoice_dtls_csr;

                   IF (l_supp_invoice_new_rec.id IS NOT NULL) THEN

                     l_supp_invoice_old_rec := NULL;
                     OPEN  supp_invoice_dtls_csr(l_clev_tbl(i).id); -- original contract
                     FETCH supp_invoice_dtls_csr INTO l_supp_invoice_old_rec;
                     CLOSE supp_invoice_dtls_csr;

                     IF (l_supp_invoice_old_rec.id IS NULL) THEN
                     -- Supplier Invoice Details added during rebook

                       l_orig_fa_cle_id := NULL;
                       OPEN orig_fa_cle_csr(p_rbk_fa_cle_id => l_supp_invoice_new_rec.fa_cle_id);
                       FETCH orig_fa_cle_csr INTO l_orig_fa_cle_id;
                       CLOSE orig_fa_cle_csr;

                       l_sidv_rec := l_sidv_temp_rec;

                       l_sidv_rec.cle_id                := l_clev_tbl(i).id;
                       l_sidv_rec.fa_cle_id             := l_orig_fa_cle_id;
                       l_sidv_rec.invoice_number        := l_supp_invoice_new_rec.invoice_number;
                       l_sidv_rec.date_invoiced         := l_supp_invoice_new_rec.date_invoiced;
                       l_sidv_rec.shipping_address_id1  := l_supp_invoice_new_rec.shipping_address_id1;
                       l_sidv_rec.shipping_address_id2  := l_supp_invoice_new_rec.shipping_address_id2;
                       l_sidv_rec.shipping_address_code := l_supp_invoice_new_rec.shipping_address_code;

                       OKL_SUPP_INVOICE_DTLS_PVT.create_sup_inv_dtls(
                         p_api_version    => 1.0,
                         p_init_msg_list  => OKL_API.G_FALSE,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_sidv_rec       => l_sidv_rec,
                         x_sidv_rec       => x_sidv_rec);

                       -- check return status
                       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                         okl_debug_pub.logmessage(' OKL_SUPP_INVOICE_DTLS_PVT.create_sup_inv_dtls failed ');
                         RAISE sync_failed;
                       END IF;

                     ELSIF (  NVL(l_supp_invoice_old_rec.invoice_number,OKL_API.G_MISS_CHAR) <> NVL(l_supp_invoice_new_rec.invoice_number,OKL_API.G_MISS_CHAR)
                           OR NVL(l_supp_invoice_old_rec.date_invoiced,OKL_API.G_MISS_DATE) <> NVL(l_supp_invoice_new_rec.date_invoiced,OKL_API.G_MISS_DATE)
                           OR NVL(l_supp_invoice_old_rec.shipping_address_id1,OKL_API.G_MISS_NUM) <> NVL(l_supp_invoice_new_rec.shipping_address_id1,OKL_API.G_MISS_NUM)) THEN

                       l_sidv_rec := l_sidv_temp_rec;

                       l_sidv_rec.id                    := l_supp_invoice_old_rec.id;
                       l_sidv_rec.cle_id                := l_supp_invoice_old_rec.cle_id;
                       l_sidv_rec.fa_cle_id             := l_supp_invoice_old_rec.fa_cle_id;
                       l_sidv_rec.invoice_number        := l_supp_invoice_new_rec.invoice_number;
                       l_sidv_rec.date_invoiced         := l_supp_invoice_new_rec.date_invoiced;
                       l_sidv_rec.shipping_address_id1  := l_supp_invoice_new_rec.shipping_address_id1;
                       l_sidv_rec.shipping_address_id2  := l_supp_invoice_new_rec.shipping_address_id2;
                       l_sidv_rec.shipping_address_code := l_supp_invoice_new_rec.shipping_address_code;

                       OKL_SUPP_INVOICE_DTLS_PVT.update_sup_inv_dtls(
                         p_api_version    => 1.0,
                         p_init_msg_list  => OKL_API.G_FALSE,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_sidv_rec       => l_sidv_rec,
                         x_sidv_rec       => x_sidv_rec);

                       -- check return status
                       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                         okl_debug_pub.logmessage(' OKL_SUPP_INVOICE_DTLS_PVT.update_sup_inv_dtls failed ');
                         RAISE sync_failed;
                       END IF;

                     END IF;
                   END IF;

                 end if;
               END IF;

               okl_okc_migration_pvt.update_contract_item(

                   p_api_version                  => 1.0,
                   p_init_msg_list                => okc_api.g_false,
                   x_return_status                =>x_return_status,
                   x_msg_count                    =>x_msg_count,
                   x_msg_data                     =>x_msg_data,
                   p_cimv_rec                     =>l_cim_rec,
                   x_cimv_rec                     =>x_cim_rec);


               IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' okc_cim_pvt.update_row sync_failed= ');
                 END IF;
                 RAISE sync_failed;
               END IF;
             END IF;
          --Bug# 5207066 -- End
          --akrangan Bug# 5362977 end

          -- dedey
          x_new_clev_tbl(i).id                := rebook_line_rec.orig_system_id1;
          x_new_klev_tbl(i).id                := rebook_line_rec.orig_system_id1;
          x_new_clev_tbl(i).start_date        := rebook_line_rec.start_date;

          i := i+ 1;

       END IF;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig: '||p_orig_chr_id);
    END IF;

    okl_contract_pub.update_contract_line(
                                          p_api_version     => 1.0,
                                          p_init_msg_list   => OKC_API.G_FALSE,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          p_clev_tbl        => l_clev_tbl,
                                          p_klev_tbl        => l_klev_tbl,
                                          x_clev_tbl        => x_clev_tbl,
                                          x_klev_tbl        => x_klev_tbl
                                         );
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      RAISE sync_failed;
    END IF;

    --Bug# 8652738
    -- Sync Asset level Terms and Conditions
    sync_line_terms_conditions(
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_rebook_chr_id => p_rebook_chr_id,
                       p_orig_chr_id   => p_orig_chr_id
                      );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE sync_failed;
    END IF;

    j := 1;
    FOR rebook_new_line_rec IN rebook_new_line_csr(p_rebook_chr_id)
    LOOP
       l_new_klev_tbl(j).id := rebook_new_line_rec.id;
       l_tran_date          := rebook_new_line_rec.start_date; --Used later to update line

       j := j + 1;
    END LOOP;

    IF (j > 1) THEN -- New Asset Lines came in
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'new line id: '||l_new_klev_tbl(1).id);
       END IF;
       okl_copy_asset_pub.copy_all_lines(
                                         p_api_version        => 1.0,
                                         p_init_msg_list      => OKL_API.G_FALSE,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_from_cle_id_tbl    => l_new_klev_tbl,
                                         p_to_cle_id          => NULL,
                                         p_to_chr_id          => p_orig_chr_id,
                                         p_to_template_yn     => 'N',
                                         p_copy_reference     => 'COPY',
                                         p_copy_line_party_yn => 'Y',
                                         p_renew_ref_yn       => 'N',
                                         p_trans_type         => 'CRB',
                                         x_cle_id_tbl         => lx_new_klev_tbl
                                        );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE sync_failed;
       END IF;

       --
       -- Get New Lines id (including sub lines) and
       -- populate tables with transaction date as start date
       -- and sts_code as BOOKED
       --
       -- This table of record is used to update new lines later
       --
       k := 1;
       FOR k IN 1..lx_new_klev_tbl.COUNT
       LOOP
       --m := 1; -- dedey
       m := x_new_clev_tbl.LAST + 1;

       FOR rebook_new_all_line_rec IN rebook_new_all_line_csr(lx_new_klev_tbl(k).id)
	 LOOP
             --INSERT INTO dd_dummy VALUES ('==> New line id : '||rebook_new_all_line_rec.id);
           x_new_clev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_klev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_clev_tbl(m).start_date := l_tran_date;
	   x_new_clev_tbl(m).sts_code   := 'BOOKED';
	   m := m + 1;
         END LOOP;
       END LOOP;

    END IF;

    --Bug# 5207066: start
    j := 1;
    FOR rebook_new_ib_line_rec IN rebook_new_ib_line_csr(p_rebook_chr_id)
    LOOP

       l_new_klev_tbl := l_temp_klev_tbl;

       l_new_klev_tbl(j).id := rebook_new_ib_line_rec.id;
       l_tran_date          := rebook_new_ib_line_rec.parent_orig_start_date; --Used later to update line

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'new line id: '||l_new_klev_tbl(1).id);
       END IF;
       okl_copy_asset_pub.copy_all_lines(
                                         p_api_version        => 1.0,
                                         p_init_msg_list      => OKL_API.G_FALSE,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_from_cle_id_tbl    => l_new_klev_tbl,
                                         p_to_cle_id          => rebook_new_ib_line_rec.parent_orig_system_id1,
                                         p_to_chr_id          => NULL,
                                         p_to_template_yn     => 'N',
                                         p_copy_reference     => 'COPY',
                                         p_copy_line_party_yn => 'Y',
                                         p_renew_ref_yn       => 'N',
                                         p_trans_type         => 'CRB',
                                         x_cle_id_tbl         => lx_new_klev_tbl
                                        );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE sync_failed;
       END IF;

       --
       -- Get New Lines id (including sub lines) and
       -- populate tables with transaction date as start date
       -- and sts_code as BOOKED
       --
       -- This table of record is used to update new lines later
       --
       k := 1;
       FOR k IN 1..lx_new_klev_tbl.COUNT
       LOOP

         m := x_new_clev_tbl.LAST + 1;

         FOR rebook_new_all_line_rec IN rebook_new_all_line_csr(lx_new_klev_tbl(k).id)
	     LOOP
           --INSERT INTO dd_dummy VALUES ('==> New line id : '||rebook_new_all_line_rec.id);
           x_new_clev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_klev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_clev_tbl(m).start_date := l_tran_date;
	       x_new_clev_tbl(m).sts_code   := 'BOOKED';
	       m := m + 1;
         END LOOP;
       END LOOP;
    END LOOP;
    --Bug# 5207066: end

    --Bug# 8652738: start
    j := 1;
    FOR rebook_new_addon_line_rec IN rebook_new_addon_line_csr(p_rebook_chr_id)
    LOOP

       l_new_klev_tbl := l_temp_klev_tbl;

       l_new_klev_tbl(j).id := rebook_new_addon_line_rec.id;
       l_tran_date          := rebook_new_addon_line_rec.parent_orig_start_date; --Used later to update line

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'new line id: '||l_new_klev_tbl(1).id);
       END IF;
       okl_copy_asset_pub.copy_all_lines(
                                         p_api_version        => 1.0,
                                         p_init_msg_list      => OKL_API.G_FALSE,
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         p_from_cle_id_tbl    => l_new_klev_tbl,
                                         p_to_cle_id          => rebook_new_addon_line_rec.parent_orig_system_id1,
                                         p_to_chr_id          => NULL,
                                         p_to_template_yn     => 'N',
                                         p_copy_reference     => 'COPY',
                                         p_copy_line_party_yn => 'Y',
                                         p_renew_ref_yn       => 'N',
                                         p_trans_type         => 'CRB',
                                         x_cle_id_tbl         => lx_new_klev_tbl
                                        );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE sync_failed;
       END IF;

       -- Supplier Invoice details do not get copied over when copying only Add-On lines
       -- Create Supplier Invoice Details on original contract based on Supplier Invoice
       -- Details entered on rebook copy contract
       l_supp_invoice_new_rec := NULL;
       OPEN  supp_invoice_dtls_csr(rebook_new_addon_line_rec.id); -- rebook_line_rec.id
       FETCH supp_invoice_dtls_csr INTO l_supp_invoice_new_rec;
       CLOSE supp_invoice_dtls_csr;

       IF (l_supp_invoice_new_rec.id IS NOT NULL) THEN

         l_orig_fa_cle_id := NULL;
         OPEN orig_fa_cle_csr(p_rbk_fa_cle_id => l_supp_invoice_new_rec.fa_cle_id);
         FETCH orig_fa_cle_csr INTO l_orig_fa_cle_id;
         CLOSE orig_fa_cle_csr;

         l_sidv_rec := l_sidv_temp_rec;
         l_sidv_rec.cle_id                := lx_new_klev_tbl(j).id;
         l_sidv_rec.fa_cle_id             := l_orig_fa_cle_id;
         l_sidv_rec.invoice_number        := l_supp_invoice_new_rec.invoice_number;
         l_sidv_rec.date_invoiced         := l_supp_invoice_new_rec.date_invoiced;
         l_sidv_rec.shipping_address_id1  := l_supp_invoice_new_rec.shipping_address_id1;
         l_sidv_rec.shipping_address_id2  := l_supp_invoice_new_rec.shipping_address_id2;
         l_sidv_rec.shipping_address_code := l_supp_invoice_new_rec.shipping_address_code;

         OKL_SUPP_INVOICE_DTLS_PVT.create_sup_inv_dtls(
           p_api_version    => 1.0,
           p_init_msg_list  => OKL_API.G_FALSE,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_sidv_rec       => l_sidv_rec,
           x_sidv_rec       => x_sidv_rec);

         -- check return status
         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           okl_debug_pub.logmessage(' OKL_SUPP_INVOICE_DTLS_PVT.create_sup_inv_dtls failed ');
           RAISE sync_failed;
         END IF;
       END IF;

       --
       -- Get New Lines id (including sub lines) and
       -- populate tables with transaction date as start date
       -- and sts_code as BOOKED
       --
       -- This table of record is used to update new lines later
       --
       k := 1;
       FOR k IN 1..lx_new_klev_tbl.COUNT
       LOOP

         m := x_new_clev_tbl.LAST + 1;

         FOR rebook_new_all_line_rec IN rebook_new_all_line_csr(lx_new_klev_tbl(k).id)
	     LOOP
           --INSERT INTO dd_dummy VALUES ('==> New line id : '||rebook_new_all_line_rec.id);
           x_new_clev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_klev_tbl(m).id         := rebook_new_all_line_rec.id;
           x_new_clev_tbl(m).start_date := l_tran_date;
	       x_new_clev_tbl(m).sts_code   := 'BOOKED';
	       m := m + 1;
         END LOOP;
       END LOOP;
    END LOOP;
    --Bug# 8652738: end

/*
    FOR i IN 1..x_new_clev_tbl.LAST
    LOOP
       INSERT INTO dd_dummy VALUES (x_new_clev_tbl(i).id||', '||x_new_clev_tbl(i).start_date);
    END LOOP;
*/

    --
    -- Sync FEE line
    --
    sync_fee_line(
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_rebook_chr_id  => p_rebook_chr_id,
                  p_orig_chr_id    => p_orig_chr_id
                 );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      RAISE sync_failed;
    END IF;

    --Bug# 8652738
    --
    -- Sync SERVICE line
    --
    sync_service_line(
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_rebook_chr_id  => p_rebook_chr_id,
                  p_orig_chr_id    => p_orig_chr_id
                 );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      RAISE sync_failed;
    END IF;

  EXCEPTION
    WHEN sync_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_line_values;

------------------------------------------------------------------------------
-- PROCEDURE version_contract
--
--  This procedure versions contract, i.e. making a contract Version History
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE version_contract(
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE
                            ) IS

  l_proc_name VARCHAR2(35) := 'VERSION_CONTRACT';
  l_cvmv_rec  cvmv_rec_type;
  x_cvmv_rec  cvmv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_cvmv_rec.chr_id := p_chr_id;
    okl_version_pub.version_contract(
                                     p_api_version => 1.0,
                                     p_init_msg_list => OKC_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_cvmv_rec      => l_cvmv_rec,
                                     x_cvmv_rec      => x_cvmv_rec --,
                                     --p_commit        => OKC_API.G_FALSE
                                    );
    RETURN;

  END version_contract;

------------------------------------------------------------------------------
-- PROCEDURE check_and_update_date
--
--  This procedure checks for any term and/or start date modification
--  during rebook process and updates original contract header date accordingly.
--  This process has to be called before synchronization.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE check_and_update_date(
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                                  p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE
                                 ) IS
  CURSOR term_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT term_duration,
         start_date
  FROM   okl_k_headers_full_v
  WHERE  id = p_chr_id;

  CURSOR date_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT start_date,
         end_date,
         term_duration
  FROM   okl_k_headers_full_v
  WHERE  id = p_chr_id;

  l_proc_name VARCHAR2(35) := 'CHECK_AND_UPDATE_DATE';
  l_chrv_rec  chrv_rec_type;
  x_chrv_rec  chrv_rec_type;
  l_khrv_rec  khrv_rec_type;
  x_khrv_rec  khrv_rec_type;

  l_orig_term   OKL_K_HEADERS.TERM_DURATION%TYPE;
  l_rebook_term OKL_K_HEADERS.TERM_DURATION%TYPE;

  l_orig_start_date   OKC_K_HEADERS_B.START_DATE%TYPE;
  l_rebook_start_date OKC_K_HEADERS_B.START_DATE%TYPE;

  l_new_start_date OKC_K_HEADERS_V.START_DATE%TYPE;
  l_new_end_date   OKC_K_HEADERS_V.END_DATE%TYPE;
  l_new_term       OKL_K_HEADERS.TERM_DURATION%TYPE;

  check_update_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_orig_term := NULL;
    OPEN term_csr(p_orig_chr_id);
    FETCH term_csr INTO l_orig_term,
                        l_orig_start_date;
    CLOSE term_csr;

    IF l_orig_term IS NULL THEN
       RAISE check_update_failed;
    END IF;

    l_rebook_term := NULL;
    OPEN term_csr(p_rebook_chr_id);
    FETCH term_csr INTO l_rebook_term,
                        l_rebook_start_date;
    CLOSE term_csr;

    IF l_rebook_term IS NULL THEN
       RAISE check_update_failed;
    END IF;

    IF (l_orig_term <> l_rebook_term
        OR
        l_orig_start_date <> l_rebook_start_date) THEN

      OPEN date_csr (p_rebook_chr_id);
      FETCH date_csr INTO l_new_start_date,
                          l_new_end_date,
                          l_new_term;
      CLOSE date_csr;

      l_chrv_rec.id            := p_orig_chr_id;
      l_chrv_rec.start_date    := l_new_start_date;
      l_chrv_rec.end_date      := l_new_end_date;

      l_khrv_rec.id            := p_orig_chr_id;
      l_khrv_rec.term_duration := l_new_term;

      -- Update contrat header with new start and end date
      okl_contract_pub.update_contract_header(
                                p_api_version        => 1.0,
                                p_init_msg_list      => OKL_API.G_FALSE,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_restricted_update  => OKL_API.G_FALSE,
                                p_chrv_rec           => l_chrv_rec,
                                p_khrv_rec           => l_khrv_rec,
                                x_chrv_rec           => x_chrv_rec,
                                x_khrv_rec           => x_khrv_rec
                               );

      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
  	  RAISE check_update_failed;
      ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
  	  RAISE check_update_failed;
      END IF;

    END IF;

  EXCEPTION
    WHEN check_update_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
  END check_and_update_date;

--Bug# 8652738
------------------------------------------------------------------------------
-- PROCEDURE sync_terms_conditions
--
--  This procedure synchronizes Rebook and Original Contract Terms and Conditions
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_terms_conditions (
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE
                           ) IS

  l_proc_name VARCHAR2(35) := 'SYNC_TERMS_CONDITIONS';
  sync_terms_failed EXCEPTION;

  l_rul_rbk_rec  rulv_rec_type;
  l_rul_orig_rec rulv_rec_type;

  l_rulv_rec     rulv_rec_type;
  x_rulv_rec     rulv_rec_type;

  x_rgp_id       OKC_RULE_GROUPS_B.id%TYPE;

  l_rgpv_rec     rgpv_rec_type;

  CURSOR l_rgp_orig_csr(p_chr_id IN NUMBER) IS
  SELECT rgp.id,
         rgp.rgd_code
  FROM okc_rule_groups_b rgp
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   rgp.chr_id     = p_chr_id
  AND   rgp.rgd_code IN
    (G_ASSET_FILING_RGP,         G_ASSET_RETURN_RGP,        G_BILLING_SETUP_RGP,
     G_COND_PARTIAL_TERM_QTE_RGP,G_CONTRACT_PORTFOLIO_RGP,  G_EARLY_TERM_PUR_OPT_RGP,
     G_END_OF_TERM_PUR_OPT_RGP,  G_EVERGREEN_ELIG_RGP,      G_FACTORING_RGP,
     G_GAIN_LOSS_TERM_QTE_RGP,   G_LATE_CHARGES_RGP,        G_LATE_INTEREST_RGP,
     G_QUOTE_APPROVER_RGP,       G_QUOTE_COURTESY_COPY_RGP, G_QUOTE_RECEPIENT_RGP,
     G_RENEWAL_OPTIONS_RGP,      G_REPURCHASE_QTE_CALC_RGP, G_RESIDUAL_VALUE_INS_RGP,
     G_SECURITY_DEPOSIT_RGP,     G_TAXES_AND_DUTIES_RGP,    G_EARLY_TERM_QTE_CALC_RGP,
     G_END_OF_TERM_QTE_CALC_RGP, G_TERM_QUOTE_PROCESS_RGP,  G_REBOOK_LIMIT_DATE_RGP,
     G_NON_NOTIFICATION_RGP,     G_PRIVATE_ACTIVITY_BOND_RGP);

  CURSOR l_rgp_rbk_csr(p_chr_id   IN NUMBER,
                       p_rgd_code IN VARCHAR2) IS
  SELECT rgp.id
  FROM okc_rule_groups_b rgp
  WHERE rgp.dnz_chr_id = p_chr_id
  AND   rgp.chr_id     = p_chr_id
  AND   rgp.rgd_code   = p_rgd_code;

  l_rgp_rbk_rec l_rgp_rbk_csr%ROWTYPE;

  CURSOR l_rul_orig_csr(p_rgp_id IN NUMBER,
                        p_chr_id IN NUMBER) IS
  SELECT rul_orig.ID,
         rul_orig.OBJECT_VERSION_NUMBER,
         rul_orig.SFWT_FLAG,
         rul_orig.OBJECT1_ID1,
         rul_orig.OBJECT2_ID1,
         rul_orig.OBJECT3_ID1,
         rul_orig.OBJECT1_ID2,
         rul_orig.OBJECT2_ID2,
         rul_orig.OBJECT3_ID2,
         rul_orig.JTOT_OBJECT1_CODE,
         rul_orig.JTOT_OBJECT2_CODE,
         rul_orig.JTOT_OBJECT3_CODE,
         rul_orig.DNZ_CHR_ID,
         rul_orig.RGP_ID,
         rul_orig.PRIORITY,
         rul_orig.STD_TEMPLATE_YN,
         rul_orig.COMMENTS,
         rul_orig.WARN_YN,
         rul_orig.ATTRIBUTE_CATEGORY,
         rul_orig.ATTRIBUTE1,
         rul_orig.ATTRIBUTE2,
         rul_orig.ATTRIBUTE3,
         rul_orig.ATTRIBUTE4,
         rul_orig.ATTRIBUTE5,
         rul_orig.ATTRIBUTE6,
         rul_orig.ATTRIBUTE7,
         rul_orig.ATTRIBUTE8,
         rul_orig.ATTRIBUTE9,
         rul_orig.ATTRIBUTE10,
         rul_orig.ATTRIBUTE11,
         rul_orig.ATTRIBUTE12,
         rul_orig.ATTRIBUTE13,
         rul_orig.ATTRIBUTE14,
         rul_orig.ATTRIBUTE15,
         rul_orig.CREATED_BY,
         rul_orig.CREATION_DATE,
         rul_orig.LAST_UPDATED_BY,
         rul_orig.LAST_UPDATE_DATE,
         rul_orig.LAST_UPDATE_LOGIN,
         --rul_orig.TEXT,
         rul_orig.RULE_INFORMATION_CATEGORY,
         rul_orig.RULE_INFORMATION1,
         rul_orig.RULE_INFORMATION2,
         rul_orig.RULE_INFORMATION3,
         rul_orig.RULE_INFORMATION4,
         rul_orig.RULE_INFORMATION5,
         rul_orig.RULE_INFORMATION6,
         rul_orig.RULE_INFORMATION7,
         rul_orig.RULE_INFORMATION8,
         rul_orig.RULE_INFORMATION9,
         rul_orig.RULE_INFORMATION10,
         rul_orig.RULE_INFORMATION11,
         rul_orig.RULE_INFORMATION12,
         rul_orig.RULE_INFORMATION13,
         rul_orig.RULE_INFORMATION14,
         rul_orig.RULE_INFORMATION15,
         rul_orig.TEMPLATE_YN,
         rul_orig.ANS_SET_JTOT_OBJECT_CODE,
         rul_orig.ANS_SET_JTOT_OBJECT_ID1,
         rul_orig.ANS_SET_JTOT_OBJECT_ID2,
         rul_orig.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_orig
  WHERE rul_orig.dnz_chr_id = p_chr_id
  AND   rul_orig.rgp_id     = p_rgp_id;

  CURSOR l_rul_rbk_csr(p_rgp_id IN NUMBER,
                       p_chr_id IN NUMBER,
                       p_rul_info_cat IN VARCHAR2) IS
  SELECT rul_rbk.ID,
         rul_rbk.OBJECT_VERSION_NUMBER,
         rul_rbk.SFWT_FLAG,
         rul_rbk.OBJECT1_ID1,
         rul_rbk.OBJECT2_ID1,
         rul_rbk.OBJECT3_ID1,
         rul_rbk.OBJECT1_ID2,
         rul_rbk.OBJECT2_ID2,
         rul_rbk.OBJECT3_ID2,
         rul_rbk.JTOT_OBJECT1_CODE,
         rul_rbk.JTOT_OBJECT2_CODE,
         rul_rbk.JTOT_OBJECT3_CODE,
         rul_rbk.DNZ_CHR_ID,
         rul_rbk.RGP_ID,
         rul_rbk.PRIORITY,
         rul_rbk.STD_TEMPLATE_YN,
         rul_rbk.COMMENTS,
         rul_rbk.WARN_YN,
         rul_rbk.ATTRIBUTE_CATEGORY,
         rul_rbk.ATTRIBUTE1,
         rul_rbk.ATTRIBUTE2,
         rul_rbk.ATTRIBUTE3,
         rul_rbk.ATTRIBUTE4,
         rul_rbk.ATTRIBUTE5,
         rul_rbk.ATTRIBUTE6,
         rul_rbk.ATTRIBUTE7,
         rul_rbk.ATTRIBUTE8,
         rul_rbk.ATTRIBUTE9,
         rul_rbk.ATTRIBUTE10,
         rul_rbk.ATTRIBUTE11,
         rul_rbk.ATTRIBUTE12,
         rul_rbk.ATTRIBUTE13,
         rul_rbk.ATTRIBUTE14,
         rul_rbk.ATTRIBUTE15,
         rul_rbk.CREATED_BY,
         rul_rbk.CREATION_DATE,
         rul_rbk.LAST_UPDATED_BY,
         rul_rbk.LAST_UPDATE_DATE,
         rul_rbk.LAST_UPDATE_LOGIN,
         --rul_rbk.TEXT,
         rul_rbk.RULE_INFORMATION_CATEGORY,
         rul_rbk.RULE_INFORMATION1,
         rul_rbk.RULE_INFORMATION2,
         rul_rbk.RULE_INFORMATION3,
         rul_rbk.RULE_INFORMATION4,
         rul_rbk.RULE_INFORMATION5,
         rul_rbk.RULE_INFORMATION6,
         rul_rbk.RULE_INFORMATION7,
         rul_rbk.RULE_INFORMATION8,
         rul_rbk.RULE_INFORMATION9,
         rul_rbk.RULE_INFORMATION10,
         rul_rbk.RULE_INFORMATION11,
         rul_rbk.RULE_INFORMATION12,
         rul_rbk.RULE_INFORMATION13,
         rul_rbk.RULE_INFORMATION14,
         rul_rbk.RULE_INFORMATION15,
         rul_rbk.TEMPLATE_YN,
         rul_rbk.ANS_SET_JTOT_OBJECT_CODE,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID1,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID2,
         rul_rbk.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_rbk
  WHERE rul_rbk.dnz_chr_id = p_chr_id
  AND   rul_rbk.rgp_id     = p_rgp_id
  AND   rul_rbk.rule_information_category = p_rul_info_cat;

  CURSOR l_rbk_new_rgp_csr(p_orig_chr_id    IN NUMBER,
                           p_rebook_chr_id  IN NUMBER) IS
  SELECT rgp_rbk.id
  FROM okc_rule_groups_b rgp_rbk
  WHERE rgp_rbk.dnz_chr_id = p_rebook_chr_id
  AND   rgp_rbk.chr_id = p_rebook_chr_id
  AND   rgp_rbk.rgd_code IN
    (G_ASSET_FILING_RGP,         G_ASSET_RETURN_RGP,        G_BILLING_SETUP_RGP,
     G_COND_PARTIAL_TERM_QTE_RGP,G_CONTRACT_PORTFOLIO_RGP,  G_EARLY_TERM_PUR_OPT_RGP,
     G_END_OF_TERM_PUR_OPT_RGP,  G_EVERGREEN_ELIG_RGP,      G_FACTORING_RGP,
     G_GAIN_LOSS_TERM_QTE_RGP,   G_LATE_CHARGES_RGP,        G_LATE_INTEREST_RGP,
     G_QUOTE_APPROVER_RGP,       G_QUOTE_COURTESY_COPY_RGP, G_QUOTE_RECEPIENT_RGP,
     G_RENEWAL_OPTIONS_RGP,      G_REPURCHASE_QTE_CALC_RGP, G_RESIDUAL_VALUE_INS_RGP,
     G_SECURITY_DEPOSIT_RGP,     G_TAXES_AND_DUTIES_RGP,    G_EARLY_TERM_QTE_CALC_RGP,
     G_END_OF_TERM_QTE_CALC_RGP, G_TERM_QUOTE_PROCESS_RGP,  G_REBOOK_LIMIT_DATE_RGP,
     G_NON_NOTIFICATION_RGP,     G_PRIVATE_ACTIVITY_BOND_RGP)
  AND NOT EXISTS (SELECT 1
                  FROM okc_rule_groups_b rgp_orig
                  WHERE rgp_orig.dnz_chr_id = p_orig_chr_id
                  AND rgp_orig.chr_id = p_orig_chr_id
                  AND rgp_orig.rgd_code = rgp_rbk.rgd_code);

  CURSOR l_rbk_new_rul_csr(p_orig_chr_id    IN NUMBER,
                           p_rebook_chr_id  IN NUMBER,
                           p_orig_rgp_id    IN NUMBER,
                           p_rbk_rgp_id     IN NUMBER) IS
  SELECT rul_rbk.ID,
         rul_rbk.OBJECT_VERSION_NUMBER,
         rul_rbk.SFWT_FLAG,
         rul_rbk.OBJECT1_ID1,
         rul_rbk.OBJECT2_ID1,
         rul_rbk.OBJECT3_ID1,
         rul_rbk.OBJECT1_ID2,
         rul_rbk.OBJECT2_ID2,
         rul_rbk.OBJECT3_ID2,
         rul_rbk.JTOT_OBJECT1_CODE,
         rul_rbk.JTOT_OBJECT2_CODE,
         rul_rbk.JTOT_OBJECT3_CODE,
         rul_rbk.DNZ_CHR_ID,
         rul_rbk.RGP_ID,
         rul_rbk.PRIORITY,
         rul_rbk.STD_TEMPLATE_YN,
         rul_rbk.COMMENTS,
         rul_rbk.WARN_YN,
         rul_rbk.ATTRIBUTE_CATEGORY,
         rul_rbk.ATTRIBUTE1,
         rul_rbk.ATTRIBUTE2,
         rul_rbk.ATTRIBUTE3,
         rul_rbk.ATTRIBUTE4,
         rul_rbk.ATTRIBUTE5,
         rul_rbk.ATTRIBUTE6,
         rul_rbk.ATTRIBUTE7,
         rul_rbk.ATTRIBUTE8,
         rul_rbk.ATTRIBUTE9,
         rul_rbk.ATTRIBUTE10,
         rul_rbk.ATTRIBUTE11,
         rul_rbk.ATTRIBUTE12,
         rul_rbk.ATTRIBUTE13,
         rul_rbk.ATTRIBUTE14,
         rul_rbk.ATTRIBUTE15,
         rul_rbk.CREATED_BY,
         rul_rbk.CREATION_DATE,
         rul_rbk.LAST_UPDATED_BY,
         rul_rbk.LAST_UPDATE_DATE,
         rul_rbk.LAST_UPDATE_LOGIN,
         --rul_rbk.TEXT,
         rul_rbk.RULE_INFORMATION_CATEGORY,
         rul_rbk.RULE_INFORMATION1,
         rul_rbk.RULE_INFORMATION2,
         rul_rbk.RULE_INFORMATION3,
         rul_rbk.RULE_INFORMATION4,
         rul_rbk.RULE_INFORMATION5,
         rul_rbk.RULE_INFORMATION6,
         rul_rbk.RULE_INFORMATION7,
         rul_rbk.RULE_INFORMATION8,
         rul_rbk.RULE_INFORMATION9,
         rul_rbk.RULE_INFORMATION10,
         rul_rbk.RULE_INFORMATION11,
         rul_rbk.RULE_INFORMATION12,
         rul_rbk.RULE_INFORMATION13,
         rul_rbk.RULE_INFORMATION14,
         rul_rbk.RULE_INFORMATION15,
         rul_rbk.TEMPLATE_YN,
         rul_rbk.ANS_SET_JTOT_OBJECT_CODE,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID1,
         rul_rbk.ANS_SET_JTOT_OBJECT_ID2,
         rul_rbk.DISPLAY_SEQUENCE
  FROM okc_rules_v rul_rbk
  WHERE rul_rbk.dnz_chr_id = p_rebook_chr_id
  AND   rul_rbk.rgp_id = p_rbk_rgp_id
  AND NOT EXISTS (SELECT 1
                  FROM okc_rules_b rul_orig
                  WHERE rul_orig.dnz_chr_id = p_orig_chr_id
                  AND rul_orig.rgp_id = p_orig_rgp_id
                  AND rul_orig.rule_information_category = rul_rbk.rule_information_category);

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Sync rule groups that existed on the original contract
    FOR l_rgp_orig_rec IN l_rgp_orig_csr(p_chr_id => p_orig_chr_id) LOOP

      l_rgp_rbk_rec := NULL;
      OPEN l_rgp_rbk_csr(p_chr_id   => p_rebook_chr_id,
                         p_rgd_code => l_rgp_orig_rec.rgd_code);
      FETCH l_rgp_rbk_csr INTO l_rgp_rbk_rec;
      CLOSE l_rgp_rbk_csr;

      -- Rule group exists on rebook copy contract
      IF (l_rgp_rbk_rec.id IS NOT NULL) THEN

        FOR l_rul_orig_rec IN l_rul_orig_csr(p_rgp_id => l_rgp_orig_rec.id,
                                             p_chr_id => p_orig_chr_id) LOOP

          l_rul_rbk_rec := NULL;
          OPEN l_rul_rbk_csr(p_rgp_id       => l_rgp_orig_rec.id,
                             p_chr_id       => p_rebook_chr_id,
                             p_rul_info_cat => l_rul_orig_rec.rule_information_category);
          FETCH l_rul_rbk_csr INTO l_rul_rbk_rec;
          CLOSE l_rul_rbk_csr;

          -- Rule exists on rebook copy contract
          IF (l_rul_rbk_rec.id IS NOT NULL) THEN

            -- Check for changes during rebook
            IF (NVL(l_rul_rbk_rec.rule_information1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information3,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information3,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information4,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information4,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information5,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information5,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information6,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information6,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information7,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information7,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information8,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information8,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information9,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information9,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information10,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information10,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information11,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information11,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information12,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information12,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information13,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information13,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information14,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information14,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.rule_information15,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.rule_information15,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object1_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object1_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object2_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object2_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object3_id1,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object3_id1,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object1_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object1_id2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object2_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object2_id2,OKL_API.G_MISS_CHAR)
                OR
                NVL(l_rul_rbk_rec.object3_id2,OKL_API.G_MISS_CHAR) <> NVL(l_rul_orig_rec.object3_id2,OKL_API.G_MISS_CHAR)
               ) THEN

                   l_rul_rbk_rec.id         := l_rul_orig_rec.id;
                   l_rul_rbk_rec.rgp_id     := l_rul_orig_rec.rgp_id;
                   l_rul_rbk_rec.dnz_chr_id := l_rul_orig_rec.dnz_chr_id;

                   okl_rule_pub.update_rule(
                                        p_api_version   => 1.0,
                                        p_init_msg_list => OKL_API.G_FALSE,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_rulv_rec      => l_rul_rbk_rec,
                                        x_rulv_rec      => x_rulv_rec
                                       );

                   IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                     RAISE sync_terms_failed;
                   END IF;

            END IF;
          -- Rule has been deleted on rebook copy contract,
          -- Delete rule from original contract
          ELSE

            l_rulv_rec.id         := l_rul_orig_rec.id;

            okl_rule_pub.delete_rule(
              p_api_version    => 1.0,
              p_init_msg_list  => OKL_API.G_FALSE,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_rulv_rec       => l_rulv_rec);

            IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE sync_terms_failed;
            END IF;

          END IF;
        END LOOP;

        -- Sync rules that were added on the rebook copy contract
        l_rul_rbk_rec := NULL;
        OPEN l_rbk_new_rul_csr(p_orig_chr_id    => p_orig_chr_id,
                               p_rebook_chr_id  => p_rebook_chr_id,
                               p_orig_rgp_id    => l_rgp_orig_rec.id,
                               p_rbk_rgp_id     => l_rgp_rbk_rec.id);

        LOOP
          FETCH l_rbk_new_rul_csr INTO l_rul_rbk_rec;
          EXIT WHEN l_rbk_new_rul_csr%NOTFOUND;

          l_rul_rbk_rec.id         := NULL;
          l_rul_rbk_rec.rgp_id     := l_rgp_orig_rec.id;
          l_rul_rbk_rec.dnz_chr_id := p_orig_chr_id;

          okl_rule_pub.create_rule(
            p_api_version    => 1.0,
            p_init_msg_list  => OKL_API.G_FALSE,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rulv_rec       => l_rul_rbk_rec,
            x_rulv_rec       => x_rulv_rec);

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            CLOSE l_rbk_new_rul_csr;
            RAISE sync_terms_failed;
          END IF;

        END LOOP;
        CLOSE l_rbk_new_rul_csr;


      -- Rule group has been deleted on rebook copy contract,
      -- Delete rule group from original contract
      ELSE

        l_rgpv_rec.id         := l_rgp_orig_rec.id;

        okl_rule_pub.delete_rule_group(
          p_api_version     => 1.0,
          p_init_msg_list   => OKL_API.G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_rgpv_rec        => l_rgpv_rec);

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE sync_terms_failed;
        END IF;

      END IF;
    END LOOP;

    -- Sync rule groups that were added on the rebook copy contract
    FOR l_rbk_new_rgp_rec IN l_rbk_new_rgp_csr(p_orig_chr_id    => p_orig_chr_id,
                                               p_rebook_chr_id  => p_rebook_chr_id) LOOP

      okl_copy_contract_pvt.copy_rules(
        p_api_version     => 1.0,
        p_init_msg_list   => OKL_API.G_FALSE,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_rgp_id          => l_rbk_new_rgp_rec.id,
        p_cle_id          => NULL,
        p_chr_id          => p_orig_chr_id,
        p_to_template_yn  => 'N',
        x_rgp_id          => x_rgp_id);

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE sync_terms_failed;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN sync_terms_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END sync_terms_conditions;

------------------------------------------------------------------------------
-- PROCEDURE sync_rebook_orig_contract
--
--  This procedure synchronize Rebook and Original Contract. It does following:
--  1. Synchronize Contract Header for any change
--  2. Synchronize Contract Lines for any change
--  3. Synchronize SLH and SLL for both Header and Line level
--  4. Change Rebook Contract Status to 'ABANDONED'
--  5. Version Original Contract
--  6. Synchronize Party role at contract header
--  7. Synchronize Terms and Conditions
--  8. Synchronize Rate Parameters
--  9. Synchronize Passthrough Details
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_rebook_orig_contract(
                                      p_api_version        IN  NUMBER,
                                      p_init_msg_list      IN  VARCHAR2, -- DEFAULT OKC_API.G_FALSE,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      p_rebook_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE
                                     ) IS
  l_api_name    VARCHAR2(35)    := 'sync_rebook_orig_contract';
  l_proc_name   VARCHAR2(35)    := 'SYNC_REBOOK_ORIG_CONTRACT';

  l_orig_chr_id OKC_K_HEADERS_V.ID%TYPE;
  l_khrv_rec    khrv_rec_type;
  l_chrv_rec    chrv_rec_type;

  x_khrv_rec    khrv_rec_type;
  x_chrv_rec    chrv_rec_type;

  l_tcnv_rec    tcnv_rec_type;
  x_tcnv_rec    tcnv_rec_type;

  i                    NUMBER :=0;
  l_update_clev_tbl    clev_tbl_type;
  l_update_klev_tbl    klev_tbl_type;
  x_update_clev_tbl    clev_tbl_type;
  x_update_klev_tbl    klev_tbl_type;

  CURSOR trx_csr(p_chr_id_new OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   OKL_TRX_CONTRACTS
  WHERE  khr_id_new = p_chr_id_new
  AND    representation_type = 'PRIMARY'; -- MGAAP 7263041

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
	                                      p_api_name      => l_api_name,
	                                      p_pkg_name      => G_PKG_NAME,
	                                      p_init_msg_list => p_init_msg_list,
	                                      l_api_version   => p_api_version,
	                                      p_api_version   => p_api_version,
	                                      p_api_type      => G_API_TYPE,
	                                      x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    get_orig_chr_id(
                    x_return_status => x_return_status,
                    p_chr_id        => p_rebook_chr_id,
                    x_orig_chr_id   => l_orig_chr_id
                   );
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       okl_api.set_message(
                            G_APP_NAME,
                            G_LLA_NO_ORIG_REFERENCE
                           );
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --
    -- Version the Original Contract
    --

    version_contract(
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_chr_id        => l_orig_chr_id
                    );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Versioning of Contract');
    END IF;

    -- Start Synchronzing Rebook and Original Contracts

    --
    -- Fix Bug# 2691056
    -- Check for term modification on contract
    -- If so, update contract header with new start_date
    -- and end_date.
    -- This is to fix Line effectivity issue during rebook
    --
    -- Check for start date change is added along with term
    --
    check_and_update_date(
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_orig_chr_id   => l_orig_chr_id,
                          p_rebook_chr_id => p_rebook_chr_id
                         );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --
    -- Fix Bug# 3042346
    --
    sync_party_role(
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_rebook_chr_id => p_rebook_chr_id,
                     p_orig_chr_id   => l_orig_chr_id
                    );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --
    -- 1. Adjust Residual Value
    -- 2. Adjust Cost
    --
    sync_line_values(
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_rebook_chr_id => p_rebook_chr_id,
                     p_orig_chr_id   => l_orig_chr_id,
                     x_new_klev_tbl  => l_update_klev_tbl,
                     x_new_clev_tbl  => l_update_clev_tbl
                    );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- 3. Change Due Date
    -- 4. Change Start Date
    -- 5. Adjust Rent
    -- 6. Adjust Cost
    -- 7. Extend Term

    sync_header_values(
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_rebook_chr_id => p_rebook_chr_id,
                       p_orig_chr_id   => l_orig_chr_id
                      );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --4542290
    OKL_K_RATE_PARAMS_PVT.SYNC_RATE_PARAMS(
                     p_orig_contract_id  => p_rebook_chr_id,
                     p_new_contract_id   => l_orig_chr_id);
    --
    -- If a new line got created during rebook process
    -- update the line with start_date as transaction_date
    -- and sts_code as BOOKED
    --

    --Bug# 8652738
    sync_terms_conditions(
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_rebook_chr_id => p_rebook_chr_id,
                       p_orig_chr_id   => l_orig_chr_id
                      );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_update_clev_tbl.COUNT > 0 THEN

       OKL_CONTRACT_PUB.update_contract_line(
                        p_api_version   => p_api_version,
                        p_init_msg_list => OKC_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_clev_tbl      => l_update_clev_tbl,
                        p_klev_tbl      => l_update_klev_tbl,
                        x_clev_tbl      => x_update_clev_tbl,
                        x_klev_tbl      => x_update_klev_tbl);

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

    sync_slh_sll(
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_for_line      => 'N',
                 p_rebook_chr_id => p_rebook_chr_id,
                 p_orig_chr_id   => l_orig_chr_id
                );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After SYNC_SLH_SLL');
    END IF;


    -- Sync passthru vendor and line parameters
    sync_passthru_detail(
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_rebook_chr_id => p_rebook_chr_id,
                   p_orig_chr_id   => l_orig_chr_id
                  );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END sync_rebook_orig_contract;

------------------------------------------------------------------------------
-- PROCEDURE create_txn_contract
--
--  This procedure creates Rebook Contract and Create a Transaction for that
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_txn_contract(
                                p_api_version        IN  NUMBER,
                                p_init_msg_list      IN  VARCHAR2, -- DEFAULT OKC_API.G_FALSE,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2,
                                p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                p_rebook_reason_code IN  VARCHAR2,
                                p_rebook_description IN  VARCHAR2,
                                p_trx_date           IN  DATE,
                                x_tcnv_rec           OUT NOCOPY tcnv_rec_type,
                                x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS

  l_api_name    VARCHAR2(35)    := 'create_txn_contract';
  l_proc_name   VARCHAR2(35)    := 'CREATE_TXN_CONTRACT';
  l_api_version CONSTANT NUMBER := 1;

  l_tcnv_rec        tcnv_rec_type;
  l_out_tcnv_rec    tcnv_rec_type;

  --Bug# 8351588
  CURSOR l_rbk_limit_date_csr(p_chr_id IN NUMBER) IS
  SELECT rul.rule_information1
  FROM okc_rules_b rul,
       okc_rule_groups_b rgp
  WHERE rgp.chr_id = p_chr_id
  AND   rgp.dnz_chr_id = p_chr_id
  AND   rgp.rgd_code = 'LAREBL'
  AND   rul.rgp_id = rgp.id
  AND   rul.dnz_chr_id = rgp.dnz_chr_id
  AND   rul.rule_information_category = 'LAREBL';

  l_rbk_limit_date_rec l_rbk_limit_date_csr%ROWTYPE;
  l_icx_date_format    VARCHAR2(240);
  --Bug# 8351588

    /*
    -- mvasudev, 08/23/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
    ,p_new_chr_id IN NUMBER
	   ,x_return_status OUT NOCOPY VARCHAR2
    )
	IS

      l_parameter_list           wf_parameter_list_t;
	BEGIN

  		 wf_event.AddParameterToList(G_WF_ITM_SRC_CONTRACT_ID,p_chr_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_REVISION_DATE,fnd_date.date_to_canonical(p_trx_date),l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_DEST_CONTRACT_ID,p_new_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_REBOOK_REQUESTED,
								 p_parameters     => l_parameter_list);



     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/23/2004
    -- END, PROCEDURE to enable Business Event
    */


  BEGIN -- main process begins here

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 8351588
      OPEN l_rbk_limit_date_csr(p_chr_id => p_from_chr_id);
      FETCH l_rbk_limit_date_csr INTO l_rbk_limit_date_rec;
      CLOSE l_rbk_limit_date_csr;

      IF (l_rbk_limit_date_rec.rule_information1 IS NOT NULL AND
          p_trx_date <=  FND_DATE.canonical_to_date(l_rbk_limit_date_rec.rule_information1))
      THEN

         l_icx_date_format := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

         OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LLA_CHK_RBK_LIMIT_DATE',
                             p_token1       => 'REBOOK_LIMIT_DATE',
                             p_token1_value => TO_CHAR(FND_DATE.canonical_to_date(l_rbk_limit_date_rec.rule_information1),l_icx_date_format));
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --Bug# 8351588

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Create Rebook Contract
      --
      create_rebook_contract(
                             p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             p_from_chr_id        => p_from_chr_id,
                             x_rebook_chr_id      => x_rebook_chr_id,
                             p_rbk_date           => p_trx_date
                            );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Create Transaction for the rebook-ed contract
      okl_transaction_pvt.create_transaction(
                         p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         p_chr_id             => p_from_chr_id,
                         p_new_chr_id         => x_rebook_chr_id,
                         p_reason_code        => p_rebook_reason_code,
                         p_description        => p_rebook_description,
                         p_trx_date           => p_trx_date,
                         p_trx_type           => 'REBOOK',
                         x_tcnv_rec           => x_tcnv_rec
                        );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   /*
   -- mvasudev, 08/23/2004
   -- Code change to enable Business Event
   */
	raise_business_event(p_chr_id        => p_from_chr_id
	                    ,p_new_chr_id => x_rebook_chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/23/2004
   -- END, Code change to enable Business Event
   */

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_txn_contract;

------------------------------------------------------------------------------
-- PROCEDURE process_securitization_stream
--
--  This procedure process securitization stream after rebook process completes.
--  This process must be called after rebook stream is synchronized
--  back to original contract.
--
-- Calls:
-- Called By: sync_rebook_stream
------------------------------------------------------------------------------
   PROCEDURE  process_securitization_stream(
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count     OUT NOCOPY NUMBER,
                                    x_msg_data      OUT NOCOPY VARCHAR2,
                                    p_orig_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                                    p_rebook_chr_id IN  OKC_K_HEADERS_V.ID%TYPE
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'process_securitization_stream';
  l_proc_name   VARCHAR2(35)    := 'PROCESS_SECURITIZATION_STREAM';
  l_api_version CONSTANT NUMBER := 1;

  CURSOR txn_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT date_transaction_occurred
  FROM   okl_trx_contracts
  WHERE  khr_id   = p_chr_id
  AND    tcn_type = 'TRBK'
  AND    tsu_code = 'ENTERED'
  AND    representation_type = 'PRIMARY'; -- MGAAP 7263041

  CURSOR disb_strm_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT strm.id
  FROM   okl_streams strm,
         okl_strm_type_v TYPE
  WHERE  TYPE.id                   = strm.sty_id
  AND    TYPE.stream_type_subclass = 'INVESTOR_DISBURSEMENT'
  AND    strm.khr_id               = p_chr_id
  AND    strm.say_code             = 'CURR';

  CURSOR accu_strm_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT strm.id
  FROM   okl_streams strm,
         okl_strm_type_v TYPE
  WHERE  TYPE.id       = strm.sty_id
/*
  AND    TYPE.name IN (
                       'INVESTOR RENTAL ACCRUAL',
                       'INVESTOR PRE-TAX INCOME',
                       'INVESTOR INTEREST INCOME',
                       'INVESTOR VARIABLE INTEREST'
                      )
*/
  AND    TYPE.stream_type_purpose IN (
                       'INVESTOR_RENTAL_ACCRUAL',
                       'INVESTOR_PRE_TAX_INCOME',
                       'INVESTOR_INTEREST_INCOME',
                       'INVESTOR_VARIABLE_INTEREST'
                      )
  AND    strm.khr_id   = p_chr_id
  AND    strm.say_code = 'CURR';

  i NUMBER := 0;
  l_disb_strm_tbl stmv_tbl_type;
  x_disb_strm_tbl stmv_tbl_type;

  l_accu_strm_tbl stmv_tbl_type;
  x_accu_strm_tbl stmv_tbl_type;

  l_rebook_date DATE;
  l_contract_secu VARCHAR2(1);
  l_inv_agmt_chr_id_tbl inv_agmt_chr_id_tbl_type;

  secu_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    --
    -- Check for Securitized Contract
    --
    FOR txn_rec IN txn_csr (p_orig_chr_id)
    LOOP
      l_rebook_date := txn_rec.date_transaction_occurred;
    END LOOP;

    okl_securitization_pvt.check_khr_securitized(
                                                 p_api_version         => 1.0,
                                                 p_init_msg_list       => OKC_API.G_FALSE,
                                                 x_return_status       => x_return_status,
                                                 x_msg_count           => x_msg_count,
                                                 x_msg_data            => x_msg_data,
                                                 p_khr_id              => p_orig_chr_id,
                                                 p_effective_date      => l_rebook_date,
                                                 x_value               => l_contract_secu,
                                                 x_inv_agmt_chr_id_tbl => l_inv_agmt_chr_id_tbl
                                                );

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE secu_failed;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Securitized? '||l_contract_secu);
    END IF;

    IF (l_contract_secu <> OKL_API.G_TRUE) THEN -- Do not proceed, return success
       x_return_status := OKL_API.G_RET_STS_SUCCESS;
       RETURN;
    END IF;

    --
    -- HISTorize disbursement streams, with subclass = 'INVESTOR_DISBURSEMENT'
    --
    FOR disb_strm_rec IN disb_strm_csr (p_orig_chr_id)
    LOOP
       i := disb_strm_csr%ROWCOUNT;
       l_disb_strm_tbl(i).id        := disb_strm_rec.id;
       l_disb_strm_tbl(i).say_code  := 'HIST';
       l_disb_strm_tbl(i).active_yn := 'N';
       l_disb_strm_tbl(i).date_history  := SYSDATE;
    END LOOP;

    IF (l_disb_strm_tbl.COUNT > 0) THEN
        okl_streams_pub.update_streams(
                                       p_api_version    => 1.0,
                                       p_init_msg_list  => OKC_API.G_FALSE,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_stmv_tbl       => l_disb_strm_tbl,
                                       x_stmv_tbl       => x_disb_strm_tbl
                                     );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE secu_failed;
      END IF;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After disbursment HIST streams');
    END IF;
    --
    -- Create Pool transaction after rebook
    --
    okl_securitization_pvt.modify_pool_contents(
                                                p_api_version         => 1.0,
                                                p_init_msg_list       => OKC_API.G_FALSE,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_transaction_reason  => OKL_SECURITIZATION_PVT.G_TRX_REASON_CONTRACT_REBOOK,
                                                p_khr_id              => p_orig_chr_id,
                                                p_transaction_date    => l_rebook_date,
                                                p_effective_date      => l_rebook_date
                                               );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE secu_failed;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Modify pool contents');
    END IF;

-- Bug# 4775555: Start
-- Accrual Streams will now be Historized in OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS
-- This API will create the new accrual streams, link the old and new streams
-- and then Historize the old streams
/*
    --
    -- HISTorize accrual streams
    --
    FOR accu_strm_rec IN accu_strm_csr (p_orig_chr_id)
    LOOP
       i := accu_strm_csr%ROWCOUNT;
       l_accu_strm_tbl(i).id        := accu_strm_rec.id;
       l_accu_strm_tbl(i).say_code  := 'HIST';
       l_accu_strm_tbl(i).active_yn := 'N';
    END LOOP;

    IF (l_accu_strm_tbl.COUNT > 0) THEN
        okl_streams_pub.update_streams(
                                       p_api_version    => 1.0,
                                       p_init_msg_list  => OKC_API.G_FALSE,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_stmv_tbl       => l_accu_strm_tbl,
                                       x_stmv_tbl       => x_accu_strm_tbl
                                     );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE secu_failed;
      END IF;
    END IF;

    debug_message('After accrual HIST streams');
*/
-- Bug# 4775555: End

    --
    -- Regenerate disbursement streams
    --
    okl_stream_generator_pvt.create_disb_streams(
                                                 p_api_version         => 1.0,
                                                 p_init_msg_list       => OKC_API.G_FALSE,
                                                 x_return_status       => x_return_status,
                                                 x_msg_count           => x_msg_count,
                                                 x_msg_data            => x_msg_data,
                                                 p_contract_id         => p_orig_chr_id
                                                );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE secu_failed;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After regerating disb. streams');
    END IF;

    -- Bug# 4775555
    --
    -- Regenerate Present Value Disbursement streams
    --
    okl_stream_generator_pvt.create_pv_streams(
                                       p_api_version         => 1.0,
                                       p_init_msg_list       => OKC_API.G_FALSE,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_contract_id         => p_orig_chr_id
                                       );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE secu_failed;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After regerating Present Value Disbursement streams');
    END IF;

    --
    -- Generate Investor accrual streams
    --
    OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
                                       p_api_version    => 1.0,
                                       p_init_msg_list  => OKL_API.G_FALSE,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_khr_id         => p_orig_chr_id
                                      );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE secu_failed;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After regerating Investor accrual streams');
    END IF;

    RETURN;

  EXCEPTION
      WHEN secu_failed THEN
         NULL; -- excception is handled by caller

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END process_securitization_stream;

------------------------------------------------------------------------------
-- PROCEDURE sync_rebook_stream
--
--  This procedure Synchronizes between Rebooked Contract Stream and Orginal Stream
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_rebook_stream(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2, -- DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_stream_status      IN  OKL_STREAMS.SAY_CODE%TYPE
                              ) IS

  l_api_name    VARCHAR2(35)    := 'sync_rebook_stream';
  l_proc_name   VARCHAR2(35)    := 'SYNC_REBOOK_STREAM';
  l_api_version CONSTANT NUMBER := 1;

  l_orig_chr_id NUMBER;

  -- Bug# 4775555: Start
  cursor l_rbk_trx_csr(p_chr_id IN NUMBER) is
  SELECT ktrx.date_transaction_occurred,ktrx.id,
         khr.multi_gaap_yn, pdt.reporting_pdt_id -- MGAAP 7263041
  FROM   okc_k_headers_b CHR,
         okl_trx_contracts ktrx,
         okl_k_headers khr,
         okl_products pdt
  WHERE  ktrx.khr_id_new = chr.id
  AND    ktrx.tsu_code = 'ENTERED'
  AND    ktrx.rbr_code is NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
  AND    CHR.id = p_chr_id
  AND    CHR.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK'
  -- MGAAP start 7263041
  AND    ktrx.representation_type = 'PRIMARY'
  AND    chr.id = khr.id
  AND    khr.pdt_id = pdt.id;
  -- MGAAP end 7263041

  l_rbk_trx_rec     l_rbk_trx_csr%ROWTYPE;
  l_inv_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_inv_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  lx_trx_number OKL_TRX_CONTRACTS.trx_number%TYPE := null; -- MGAAP 7263041
  -- Bug# 4775555: End

  --Bug# 9191475
  lx_trxnum_tbl     OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
--**********************************************************

      get_orig_chr_id(
                      x_return_status => x_return_status,
                      p_chr_id        => p_chr_id,
                      x_orig_chr_id   => l_orig_chr_id
                     );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         okl_api.set_message(
                              G_APP_NAME,
                              G_LLA_NO_ORIG_REFERENCE
                             );
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

/*
 * Bug# , 03/12/2003
 * Code commented as HISTorization of stream
 * is done during stream synchronization process later
 * at copy_rebook_stream() procedure
*/
/*
      -- Change status of Original Stream to 'HIST'
      change_stream_status(
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_chr_id        => l_orig_chr_id,
                           p_status        => 'HIST',
                           p_active_yn     => 'N'
                          );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      debug_message('Change Status: '||x_return_status);
*/

      -- Copy Rebooked Streams under Original Contract
      copy_rebook_stream(
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_orig_chr_id   => l_orig_chr_id,
                         p_rebook_chr_id => p_chr_id
                        );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- Change status of Rebooked Stream to 'HIST'
      change_stream_status(
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_chr_id        => p_chr_id,
                           p_status        => 'HIST',
                           p_active_yn     => 'N'
                          );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Change Status 2: '||x_return_status);
      END IF;

      --
      -- Securitization stream processing
      --
      process_securitization_stream(
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_orig_chr_id   => l_orig_chr_id,
                                    p_rebook_chr_id => p_chr_id
                                   );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      -- Bug# 4775555: Start
      --
      -- Create Investor Disbursement Adjustment
      --
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call create_inv_disb_adjustment');
      END IF;
      create_inv_disb_adjustment(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_orig_khr_id     => l_orig_chr_id
                         );
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call create_inv_disb_adjustment'||x_return_status);
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --get rebook transaction
      OPEN l_rbk_trx_csr (p_chr_id => p_chr_id);
      FETCH l_rbk_trx_csr INTO l_rbk_trx_rec;
      CLOSE l_rbk_trx_csr;

      --
      -- Create Investor Accrual Adjustment
      --
      OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;  -- MGAAP 7263041
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call calc_inv_acc_adjustment');
      END IF;
      calc_inv_acc_adjustment(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_orig_khr_id     => l_orig_chr_id,
                         p_trx_id          => l_rbk_trx_rec.id,
                         p_trx_date        => sysdate,
                         x_inv_accrual_rec => l_inv_accrual_rec,
                         x_inv_stream_tbl  => l_inv_stream_tbl
                         );
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call calc_inv_acc_adjustment'||x_return_status);
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_inv_stream_tbl.COUNT > 0) THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call okl_generate_accruals_pvt.adjust_accruals');
        END IF;
        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_inv_accrual_rec,
          p_stream_tbl     => l_inv_stream_tbl);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call okl_generate_accruals_pvt.adjust_accruals'||x_return_status);
        END IF;

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- Bug# 4775555: End

      -- MGAAP start 7263041

      IF (l_rbk_trx_rec.multi_gaap_yn = 'Y') THEN

        OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call calc_inv_acc_adjustment for SECONDARY');
        END IF;
        calc_inv_acc_adjustment(
                           p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_orig_khr_id     => l_orig_chr_id,
                           p_trx_id          => l_rbk_trx_rec.id,
                           p_trx_date        => sysdate,
                           x_inv_accrual_rec => l_inv_accrual_rec,
                           x_inv_stream_tbl  => l_inv_stream_tbl,
                           p_product_id      => l_rbk_trx_rec.reporting_pdt_id
                           );
        OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call calc_inv_acc_adjustment'||x_return_status);
        END IF;

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF (l_inv_stream_tbl.COUNT > 0) THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call okl_generate_accruals_pvt.adjust_accruals');
          END IF;

          --Bug# 9191475
          --l_inv_accrual_rec.trx_number := lx_trx_number;

          OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data ,
            --Bug# 9191475
            --x_trx_number     => lx_trx_number,
            x_trx_tbl        => lx_trxnum_tbl,
            p_accrual_rec    => l_inv_accrual_rec,
            p_stream_tbl     => l_inv_stream_tbl,
            p_representation_type     => 'SECONDARY');
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call okl_generate_accruals_pvt.adjust_accruals'||x_return_status);
          END IF;

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        END IF;

      END IF;
      -- MGAAP end 7263041

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END sync_rebook_stream;

------------------------------------------------------------------------------
-- PROCEDURE create_rebook_contract
--
--  This procedure creates a Rebook Contract from Original Contract provieded as parameter
--  p_from_chr_id and set the status of new contract as 'ENTERED'.
--  This process does not touch/chnage the original contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE create_rebook_contract(
                                   p_api_version        IN  NUMBER,
                                   p_init_msg_list      IN  VARCHAR2, -- DEFAULT OKC_API.G_FALSE,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE,
                                   p_rbk_date           IN  DATE DEFAULT NULL
                                  ) IS

  l_api_name             VARCHAR2(35)    := 'create_rebook_contract';
  l_proc_name            VARCHAR2(35)    := 'CREATE_REBOOK_CONTRACT';
  l_api_version          CONSTANT NUMBER := 1;
  x_chr_id               OKC_K_HEADERS_V.ID%TYPE;
  l_seq_no               NUMBER;
  l_orig_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
  l_orig_sts_code        OKC_K_HEADERS_V.sts_code%TYPE; --|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |
  l_new_contract_number  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
  l_khrv_rec             khrv_rec_type;
  x_khrv_rec             khrv_rec_type;
  l_chrv_rec             chrv_rec_type;
  x_chrv_rec             chrv_rec_type;
  x_cle_id               OKC_K_LINES_V.ID%TYPE;
  l_from_cle_id_tbl      okl_kle_pvt.klev_tbl_type;
  x_cle_id_tbl           okl_kle_pvt.klev_tbl_type;
  i                      NUMBER := 1;

--start:|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |
/*  CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT contract_number
  FROM   okc_k_headers_v
  WHERE  id = p_chr_id;
*/
  CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT contract_number, sts_code
  FROM   okc_k_headers_v
  WHERE  id = p_chr_id;
--end:|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |

  CURSOR top_line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_k_lines_v
  WHERE  chr_id = p_chr_id;
  --AND    lse_id = 33; -- ??? Temporary , Fin Asset Line Only

  l_orig_chr_id NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
--**********************************************************
      -- Get Sequence Number to generate Contract Number
      SELECT okl_rbk_seq.NEXTVAL
      INTO   l_seq_no
      FROM   DUAL;

      -- Get Contract Number from Original Contract
      OPEN orig_csr(p_from_chr_id);
      FETCH orig_csr INTO l_orig_contract_number, l_orig_sts_code;--:|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |

      IF orig_csr%NOTFOUND THEN
         okl_api.set_message(
                             G_APP_NAME,
                             G_LLA_CHR_ID
                            );
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--start:|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |
      ELSE
         IF l_orig_sts_code <> 'BOOKED' THEN
           okl_api.set_message(
                             G_APP_NAME,
                             'OKL_LLA_REV_ONLY_BOOKED'
                            );
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
--end:|          24-Mar-08 cklee  Bug# 6801137 -- Added validation logic         |

      END IF;

      CLOSE orig_csr;
      l_new_contract_number :=  l_orig_contract_number||'-RB'||l_seq_no;

      --
      -- Copy Contract to Create Rebook Contract
      --
      okl_copy_contract_pub.copy_lease_contract_new(
                                                 p_api_version              => 1.0,
                                                 p_init_msg_list            => OKC_API.G_FALSE,
                                                 x_return_status            => x_return_status,
                                                 x_msg_count                => x_msg_count,
                                                 x_msg_data                 => x_msg_data,
                                                 p_chr_id                   => p_from_chr_id,
                                                 p_contract_number          => l_new_contract_number,
                                                 p_contract_number_modifier => NULL,
                                                 p_renew_ref_yn             => 'N',
                                                 p_trans_type               => 'CRB',
                                                 x_chr_id                   => x_chr_id,
                                                 p_rbk_date               => p_rbk_date
                                                );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


/*
      okl_copy_contract_pub.copy_contract(
                                          p_api_version                  => 1.0,
                                          p_init_msg_list                => OKC_API.G_FALSE,
                                          x_return_status                => x_return_status,
                                          x_msg_count                    => x_msg_count,
                                          x_msg_data                     => x_msg_data,
                                          p_commit                       => OKC_API.G_FALSE,
                                          p_chr_id                       => p_from_chr_id,
                                          p_contract_number              => l_new_contract_number,
                                          p_contract_number_modifier     => NULL,
                                          p_to_template_yn               => 'N',
                                          p_renew_ref_yn                 => 'N',
                                          p_copy_lines_yn                => 'N',
                                          p_override_org                 => 'N',
                                          x_chr_id                       => x_chr_id
                                         );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      debug_message('New Chr ID: '||x_chr_id);

      i := 1;
      FOR top_line_rec IN top_line_csr(p_from_chr_id)
      LOOP
         debug_message('Top Line: '||top_line_rec.id);
         l_from_cle_id_tbl(i).id := top_line_rec.id;
         i := i + 1;
      END LOOP;

         okl_copy_asset_pub.copy_all_lines(
                                             p_api_version        => 1.0,
                                             p_init_msg_list      => OKC_API.G_FALSE,
                                             x_return_status      => x_return_status,
                                             x_msg_count          => x_msg_count,
                                             x_msg_data           => x_msg_data,
                                             P_from_cle_id_tbl    => l_from_cle_id_tbl,
                                             p_to_chr_id          => x_chr_id,
                                             p_to_template_yn	  => 'N',
                                             p_copy_reference	  => 'Y',
                                             p_copy_line_party_yn => 'Y',
                                             p_renew_ref_yn       => 'N',
                                             p_trans_type         => 'CRB',
                                             x_cle_id_tbl         => x_cle_id_tbl
                                            );
         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

*/
      --
      -- Update Rebook Contract Status to 'NEW'
      -- and source to 'OKL_REBOOK'
      --
      l_khrv_rec.id                      := x_chr_id;
      l_chrv_rec.id                      := x_chr_id;
      l_chrv_rec.sts_code                := 'NEW';
      l_chrv_rec.orig_system_source_code := 'OKL_REBOOK';

      Okl_Okc_Migration_Pvt.update_contract_header(
	                                           p_api_version       => 1.0,
	                                           p_init_msg_list     => OKC_API.G_FALSE,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data,
                                                   p_restricted_update => OKC_API.G_FALSE,
                                                   p_chrv_rec          => l_chrv_rec,
                                                   x_chrv_rec          => x_chrv_rec
					          );
/* dedey - 27-AUG-2002

   --changed the call as it is over-writing line start date
   --with old date

      okl_contract_pub.update_contract_header(
                                              p_api_version         => 1.0,
                                              p_init_msg_list       => p_init_msg_list,
                                              x_return_status       => x_return_status,
                                              x_msg_count           => x_msg_count,
                                              x_msg_data            => x_msg_data,
                                              p_restricted_update   => OKC_API.G_FALSE,
                                              p_chrv_rec            => l_chrv_rec,
                                              p_khrv_rec            => l_khrv_rec,
                                              x_chrv_rec            => x_chrv_rec,
                                              x_khrv_rec            => x_khrv_rec
                                             );
*/

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_rebook_chr_id := x_chr_id;

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_rebook_contract;

--Bug# 4212626: start
  ------------------------------------------------------------------------------
-- PROCEDURE link_streams
--
--  This procedure links the WORK Streams created during Rebook
--  to the corresponding matching CURR Streams in the original contract and
--  also updates the WORK streams with Source Transaction Id.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE link_streams(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_khr_id          IN  NUMBER
                         ) IS

  l_api_name             VARCHAR2(35)    := 'link_streams';
  l_proc_name            VARCHAR2(35)    := 'LINK_STREAMS';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR chk_rbk_csr(p_chr_id IN NUMBER) is
  SELECT '!',chr.orig_system_id1, ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx
  WHERE  ktrx.khr_id_new = chr.id
  AND    ktrx.tsu_code = 'ENTERED'
  AND    ktrx.rbr_code is NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
  AND    chr.id = p_chr_id
  AND    chr.orig_system_source_code = 'OKL_REBOOK'
  AND    ktrx.representation_type = 'PRIMARY'; -- MGAAP 7263041

  CURSOR chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
  SELECT '!', ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx
  WHERE  chr.id          = p_chr_id
  AND    ktrx.khr_id     =  chr.id
  AND    ktrx.tsu_code   = 'ENTERED'
  AND    ktrx.rbr_code   IS NOT NULL
  AND    ktrx.tcn_type   = 'TRBK'
  AND    ktrx.representation_type = 'PRIMARY' -- MGAAP 7263041
  AND    EXISTS (SELECT '1'
                 FROM   okl_rbk_selected_contract rbk_khr
                 WHERE  rbk_khr.khr_id = chr.id
                 AND    rbk_khr.status <> 'PROCESSED');

  CURSOR curr_streams_csr(p_khr_id IN NUMBER) IS
  SELECT new_stm.id  new_stm_id,
         new_stm.kle_id
  FROM   okl_streams new_stm
  WHERE  new_stm.khr_id = p_khr_id
  AND    new_stm.say_code = 'WORK';

  CURSOR ol_rbk_kle_hist_strms_csr(p_new_stm_id  IN NUMBER,
                                   p_rbk_khr_id  IN NUMBER,
                                   p_orig_khr_id IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id
  FROM   okl_streams new_stm,
         okc_k_lines_b cle,
         okl_streams orig_stm
  WHERE  new_stm.id = p_new_stm_id
  AND    cle.id = new_stm.kle_id
  AND    cle.dnz_chr_id = p_rbk_khr_id
  AND    orig_stm.khr_id = p_orig_khr_id
  AND    orig_stm.kle_id = cle.orig_system_id1
  AND    orig_stm.sty_id = new_stm.sty_id
  AND    NVL(orig_stm.purpose_code,'ORIG') = NVL(new_stm.purpose_code,'ORIG')
  AND    orig_stm.say_code  = 'CURR';

  CURSOR ol_rbk_khr_hist_strms_csr(p_new_stm_id  IN NUMBER,
                                   p_orig_khr_id IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id
  FROM   okl_streams new_stm,
         okl_streams orig_stm
  WHERE  new_stm.id = p_new_stm_id
  AND    orig_stm.khr_id = p_orig_khr_id
  AND    orig_stm.kle_id IS NULL
  AND    orig_stm.sty_id = new_stm.sty_id
  AND    NVL(orig_stm.purpose_code,'ORIG') = NVL(new_stm.purpose_code,'ORIG')
  AND    orig_stm.say_code  = 'CURR';

  l_orig_stm_id OKL_STREAMS.ID%TYPE;

  CURSOR mass_rbk_hist_strms_csr(p_new_stm_id IN NUMBER,
                                 p_khr_id     IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id
  FROM   okl_streams new_stm,
         okl_streams orig_stm
  WHERE  new_stm.id = p_new_stm_id
  AND    orig_stm.khr_id = new_stm.khr_id
  AND    NVL(orig_stm.kle_id,-1) = NVL(new_stm.kle_id,-1)
  AND    orig_stm.sty_id = new_stm.sty_id
  AND    NVL(orig_stm.purpose_code,'ORIG') = NVL(new_stm.purpose_code,'ORIG')
  AND    orig_stm.say_code = 'CURR';

  mass_rbk_hist_strms_rec mass_rbk_hist_strms_csr%ROWTYPE;

  l_rbk_khr           VARCHAR2(1);
  l_mass_rbk_khr      VARCHAR2(1);
  l_orig_khr_id       NUMBER;
  l_mass_rbk_trx_id   NUMBER;
  l_online_rbk_trx_id NUMBER;

  l_new_strm_tbl stmv_tbl_type;
  x_new_strm_tbl stmv_tbl_type;

  l_new_strm_count NUMBER := 0;

  --Bug# 6344223
  --Cursor to check whether split asset transaction is in progress for the contract
  CURSOR check_split_trx_csr IS
  SELECT tas.id
  FROM OKL_TXL_ASSETS_B txl, OKL_TRX_ASSETS tas
  WHERE txl.tal_type= 'ALI'
  AND txl.dnz_khr_id = p_khr_id
  AND txl.tas_id = tas.id
  AND tas.tas_type = 'ALI'
  AND tas.tsu_code = 'ENTERED';

  l_split_trans_id    OKL_TRX_ASSETS.ID%TYPE;
  --end Bug# 6344223

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 6344223
      OPEN check_split_trx_csr;
      FETCH check_split_trx_csr INTO l_split_trans_id;
      CLOSE check_split_trx_csr;
      --end Bug# 6344223

      --check for mass rebook contract
      l_mass_rbk_khr := '?';
      l_mass_rbk_trx_id := null;
      OPEN chk_mass_rbk_csr (p_chr_id => p_khr_id);
      FETCH chk_mass_rbk_csr INTO l_mass_rbk_khr, l_mass_rbk_trx_id;
      CLOSE chk_mass_rbk_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_khr: '||l_mass_rbk_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_trx_id: '||l_mass_rbk_trx_id);
      END IF;

      --check for rebook contract
      l_rbk_khr := '?';
      l_orig_khr_id := null;
      l_online_rbk_trx_id := null;
      OPEN chk_rbk_csr (p_chr_id => p_khr_id);
      FETCH chk_rbk_csr INTO l_rbk_khr,l_orig_khr_id,l_online_rbk_trx_id;
      CLOSE chk_rbk_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rbk_khr: '||l_rbk_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_orig_khr_id: '||l_orig_khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_online_rbk_trx_id: '||l_online_rbk_trx_id);
      END IF;

      --Added condition l_split_trans_id IS NOT NULL for Bug# 6344223
      IF ((l_split_trans_id IS NOT NULL) OR l_mass_rbk_khr = '!' OR  l_rbk_khr = '!') THEN

        l_new_strm_tbl.DELETE;
        l_new_strm_count := 0;

        FOR curr_streams_rec IN curr_streams_csr(p_khr_id => p_khr_id)
        LOOP

          l_new_strm_count := l_new_strm_count + 1;
          l_new_strm_tbl(l_new_strm_count).id  := curr_streams_rec.new_stm_id;

          --Added condition l_split_trans_id IS NOT NULL for Bug# 6344223
          IF (l_mass_rbk_khr = '!' OR (l_split_trans_id IS NOT NULL)) THEN
          -- Process for Mass Rebook and Split Asset

            --Bug# 6344223
            IF (l_mass_rbk_khr = '!') THEN
              l_new_strm_tbl(l_new_strm_count).trx_id  := l_mass_rbk_trx_id;
            ELSIF (l_split_trans_id IS NOT NULL) THEN
              l_new_strm_tbl(l_new_strm_count).trx_id  := l_split_trans_id;
            END IF;

            mass_rbk_hist_strms_rec.orig_stm_id := NULL;
            OPEN mass_rbk_hist_strms_csr(p_new_stm_id => curr_streams_rec.new_stm_id,
                                         p_khr_id     => p_khr_id);
            FETCH mass_rbk_hist_strms_csr INTO mass_rbk_hist_strms_rec;
            CLOSE mass_rbk_hist_strms_csr;

            IF mass_rbk_hist_strms_rec.orig_stm_id IS NOT NULL THEN
              l_new_strm_tbl(l_new_strm_count).link_hist_stream_id := mass_rbk_hist_strms_rec.orig_stm_id;
            END IF;

          ELSIF l_rbk_khr = '!' THEN
          -- Process for Online Rebook

            l_new_strm_tbl(l_new_strm_count).trx_id  := l_online_rbk_trx_id;

            l_orig_stm_id := NULL;
            IF (curr_streams_rec.kle_id IS NULL) THEN
            -- Contract Header level stream
              OPEN ol_rbk_khr_hist_strms_csr(p_new_stm_id  => curr_streams_rec.new_stm_id,
                                             p_orig_khr_id => l_orig_khr_id);
              FETCH ol_rbk_khr_hist_strms_csr INTO l_orig_stm_id;
              CLOSE ol_rbk_khr_hist_strms_csr;

            ELSE
            -- Contract Line level stream
              OPEN ol_rbk_kle_hist_strms_csr(p_new_stm_id  => curr_streams_rec.new_stm_id,
                                             p_rbk_khr_id  => p_khr_id,
                                             p_orig_khr_id => l_orig_khr_id);
              FETCH ol_rbk_kle_hist_strms_csr INTO l_orig_stm_id;
              CLOSE ol_rbk_kle_hist_strms_csr;
            END IF;

            IF l_orig_stm_id IS NOT NULL THEN
              l_new_strm_tbl(l_new_strm_count).link_hist_stream_id := l_orig_stm_id;
            END IF;

          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream ID: '||l_new_strm_tbl(l_new_strm_count).id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream ID: '||l_new_strm_tbl(l_new_strm_count).link_hist_stream_id);
          END IF;

        END LOOP;

        IF (l_new_strm_tbl.COUNT > 0) THEN

          -- Call Streams api to update Link_Hist_Stream_Id and Trx_Id
          okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_tbl       => l_new_strm_tbl,
                                      x_stmv_tbl       => x_new_strm_tbl
                                     );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of New Strms - Trx ID and Hist ID '||x_return_status);
          END IF;

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END link_streams;

  --Bug# 4884423
  ------------------------------------------------------------------------------
-- PROCEDURE create_pth_disb_adjustment
--
--  This procedure calculates the passthrough disbursement adjustment
--  where there is a difference between amount actually disbursed and amount
--  that should have been disbursed and calls the Disbursement api to create the
--  disbursement transaction. The current streams taken into account for
--  calculating disbursement adjustment are then marked as Disbursment adjusted
--  in order to stop duplicate disbursement.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_pth_disb_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE
                         ) IS

  l_api_name             VARCHAR2(35)    := 'create_pth_disb_adjustment';
  l_proc_name            VARCHAR2(35)    := 'CREATE_PTH_DISB_ADJUSTMENT';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR curr_billable_streams_csr(p_khr_id  IN NUMBER) IS
  SELECT new_stm.id     new_stm_id,
         orig_stm.id    orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id
  FROM   okl_streams new_stm,
         okl_strm_type_b sty,
         okl_streams orig_stm,
         okl_party_payment_hdr pph
  WHERE  new_stm.khr_id = p_khr_id
  AND    new_stm.say_code = 'CURR'
  AND    new_stm.sty_id = sty.id
  AND    sty.billable_yn = 'Y'
  AND    orig_stm.id = new_stm.link_hist_stream_id
  AND    pph.dnz_chr_id = new_stm.khr_id
  AND    pph.cle_id = new_stm.kle_id
  AND    pph.payout_basis = 'DUE_DATE'
  AND    pph.passthru_term = 'BASE';

  CURSOR max_disb_date_csr(p_stm_id IN NUMBER) IS
  SELECT MAX(sel.stream_element_date) stream_element_date
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.date_disbursed IS NOT NULL;

  CURSOR actual_amount_disb_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(sel.amount),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.date_disbursed IS NOT NULL;

  CURSOR amount_to_be_disb_csr(p_stm_id IN NUMBER,
                               p_max_disb_date IN DATE) IS
  SELECT sel.id sel_id,
         NVL(sel.amount,0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.stream_element_date <= p_max_disb_date;

  -- Cursor to fetch Streams deleted during rebook
  CURSOR del_billable_streams_csr(p_orig_khr_id  IN NUMBER,
                                  p_rbk_khr_id   IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         cle.lse_id
  FROM   okl_streams orig_stm,
         okl_strm_type_b sty,
         okc_k_lines_b cle,
         okl_party_payment_hdr pph
  WHERE  orig_stm.khr_id = p_orig_khr_id
  AND    orig_stm.say_code = 'CURR'
  AND    orig_stm.sty_id = sty.id
  AND    orig_stm.sgn_code NOT IN ('INTC','LATE_CALC') -- Bug6472228
  AND    sty.billable_yn = 'Y'
  AND    cle.id = orig_stm.kle_id
  AND    cle.dnz_chr_id = orig_stm.khr_id
  AND    pph.dnz_chr_id = orig_stm.khr_id
  AND    pph.cle_id = orig_stm.kle_id
  AND    pph.payout_basis = 'DUE_DATE'
  AND    pph.passthru_term = 'BASE'
  AND    NOT EXISTS (SELECT 1
                     FROM okl_streams new_stm
                     WHERE new_stm.khr_id = p_rbk_khr_id
                     AND   new_stm.say_code = 'CURR'
                     AND   new_stm.link_hist_stream_id = orig_stm.id);

  l_max_disb_date DATE;
  l_actual_amount_disbursed NUMBER;
  l_amount_to_be_disbursed NUMBER;
  l_disb_adjustment NUMBER;

  l_selv_tbl  selv_tbl_type;
  x_selv_tbl  selv_tbl_type;

  l_selv_count NUMBER;
  i NUMBER;
  l_rebook_adj_tbl OKL_REBOOK_CM_PVT.rebook_adj_tbl_type;

  -- sjalasut, added variable that supports out parameter
  lx_disb_rec OKL_BPD_TERMINATION_ADJ_PVT.disb_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate disbursement adjustment
      -- for all Current Billable Streams for which disbursement was done
      -- in the Original contract

      i := 0;
      l_rebook_adj_tbl.DELETE;
      FOR curr_billable_streams_rec in curr_billable_streams_csr(p_khr_id => p_rbk_khr_id)
      LOOP

        l_max_disb_date := NULL;
        OPEN max_disb_date_csr(p_stm_id => curr_billable_streams_rec.orig_stm_id);
        FETCH max_disb_date_csr INTO l_max_disb_date;
        CLOSE max_disb_date_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream Id: '||curr_billable_streams_rec.new_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream Id: '||curr_billable_streams_rec.orig_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Max Disbursed Date: '||l_max_disb_date);
        END IF;

        IF l_max_disb_date IS NOT NULL THEN

          l_actual_amount_disbursed := 0;
          OPEN actual_amount_disb_csr(p_stm_id => curr_billable_streams_rec.orig_stm_id);
          FETCH actual_amount_disb_csr INTO l_actual_amount_disbursed;
          CLOSE actual_amount_disb_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Disbursed: '||l_actual_amount_disbursed);
          END IF;

          l_amount_to_be_disbursed := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_disb_rec IN
              amount_to_be_disb_csr(p_stm_id => curr_billable_streams_rec.new_stm_id,
                                    p_max_disb_date => l_max_disb_date)
          LOOP

            -- Call Streams api to update date_disbursed
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_disbursed := l_amount_to_be_disbursed + amount_to_be_disb_rec.amount;

            l_selv_tbl(l_selv_count).id        := amount_to_be_disb_rec.sel_id;
            l_selv_tbl(l_selv_count).date_disbursed := trunc(SYSDATE);

          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount to be Disbursed: '||l_amount_to_be_disbursed);
          END IF;

          l_disb_adjustment := l_amount_to_be_disbursed -  l_actual_amount_disbursed;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Adjustment: '||l_disb_adjustment);
          END IF;

          IF l_disb_adjustment <> 0 THEN
            i := i + 1;
            l_rebook_adj_tbl(i).khr_id          := p_orig_khr_id;
            l_rebook_adj_tbl(i).kle_id          := curr_billable_streams_rec.kle_id;
            l_rebook_adj_tbl(i).sty_id          := curr_billable_streams_rec.sty_id;
            l_rebook_adj_tbl(i).adjusted_amount := l_disb_adjustment;
            l_rebook_adj_tbl(i).date_invoiced   := p_trx_date;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Adjustment Record');
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).khr_id: '||l_rebook_adj_tbl(i).khr_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).kle_id: '||l_rebook_adj_tbl(i).kle_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).sty_id: '||l_rebook_adj_tbl(i).sty_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).adjusted_amount: '||l_rebook_adj_tbl(i).adjusted_amount);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).date_invoiced: '||l_rebook_adj_tbl(i).date_invoiced);
            END IF;

          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Stream Elements - Date Disbursed '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;
      END LOOP;

      -- For On-line rebook, calculate billing adjustment
      -- for Streams deleted during Rebook
      -- Insurance Streams are ignored by this process, so no
      -- adjustment will be calculated for Insurance Streams here
      IF (p_rbk_khr_id <> p_orig_khr_id) THEN  -- Online rebook

        FOR del_billable_streams_rec IN
            del_billable_streams_csr(p_orig_khr_id  => p_orig_khr_id,
                                     p_rbk_khr_id   => p_rbk_khr_id)
        LOOP
          -- Do not process Insurance Streams
          IF (NVL(del_billable_streams_rec.lse_id,-1) <> G_INSURANCE_LSE_ID) THEN

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Deleted Orig Stream Id: '||del_billable_streams_rec.orig_stm_id);
            END IF;

            l_actual_amount_disbursed := 0;
            OPEN actual_amount_disb_csr(p_stm_id => del_billable_streams_rec.orig_stm_id);
            FETCH actual_amount_disb_csr INTO l_actual_amount_disbursed;
            CLOSE actual_amount_disb_csr;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Disbursed: '||l_actual_amount_disbursed);
            END IF;

            l_disb_adjustment := -1 * l_actual_amount_disbursed;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Adjustment: '||l_disb_adjustment);
            END IF;

            IF l_actual_amount_disbursed <> 0 THEN
              i := i + 1;
              l_rebook_adj_tbl(i).khr_id          := p_orig_khr_id;
              l_rebook_adj_tbl(i).kle_id          := del_billable_streams_rec.kle_id;
              l_rebook_adj_tbl(i).sty_id          := del_billable_streams_rec.sty_id;
              l_rebook_adj_tbl(i).adjusted_amount := l_disb_adjustment;
              l_rebook_adj_tbl(i).date_invoiced   := p_trx_date;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Adjustment Record');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).khr_id: '||l_rebook_adj_tbl(i).khr_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).kle_id: '||l_rebook_adj_tbl(i).kle_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).sty_id: '||l_rebook_adj_tbl(i).sty_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).adjusted_amount: '||l_rebook_adj_tbl(i).adjusted_amount);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).date_invoiced: '||l_rebook_adj_tbl(i).date_invoiced);
              END IF;

            END IF;
          END IF;
        END LOOP;

      END IF;

      IF (l_rebook_adj_tbl.COUNT > 0) THEN

        -- sjalasut, added code for Contract Rebook Enhancement. START
        OKL_BPD_TERMINATION_ADJ_PVT.create_rbk_passthru_adj
          (p_api_version    => p_api_version
          ,p_init_msg_list  => p_init_msg_list
          ,p_rebook_adj_tbl => l_rebook_adj_tbl
          ,x_disb_rec       => lx_disb_rec
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data);

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling OKL_BPD_TERMINATION_ADJ_PVT.create_rbk_passthru_adj '||x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- sjalasut, added code for Contract Rebook Enhancement. END

      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_pth_disb_adjustment;
  --Bug# 4884423

  ------------------------------------------------------------------------------
-- PROCEDURE create_billing_adjustment
--
--  This procedure calculates the billing adjustment for all billable streams
--  where there is a difference between amount actually billed and amount
--  that should have been billed and calls the Billing api to create the
--  billing transaction. The current streams taken into account for
--  calculating billing adjustment are then marked as Billing adjusted in order
--  to stop duplicate billing.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_billing_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE
                         ) IS

  l_api_name             VARCHAR2(35)    := 'create_billing_adjustment';
  l_proc_name            VARCHAR2(35)    := 'CREATE_BILLING_ADJUSTMENT';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR curr_billable_streams_csr(p_khr_id  IN NUMBER) IS
  SELECT new_stm.id     new_stm_id,
         orig_stm.id    orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id
  FROM   okl_streams new_stm,
         okl_strm_type_b sty,
         okl_streams orig_stm
  WHERE  new_stm.khr_id = p_khr_id
  AND    new_stm.say_code = 'CURR'
  AND    new_stm.sty_id = sty.id
  AND    sty.billable_yn = 'Y'
  AND    orig_stm.id = new_stm.link_hist_stream_id;

  CURSOR max_bill_date_csr(p_stm_id IN NUMBER) IS
  SELECT MAX(sel.stream_element_date) stream_element_date
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.date_billed IS NOT NULL;

  CURSOR actual_amount_billed_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(sel.amount),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.date_billed IS NOT NULL;

  CURSOR amount_to_be_billed_csr(p_stm_id IN NUMBER,
                                 p_max_bill_date IN DATE) IS
  SELECT sel.id sel_id,
         NVL(sel.amount,0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.stream_element_date <= p_max_bill_date;

  -- Cursor to fetch Streams deleted during rebook
  CURSOR del_billable_streams_csr(p_orig_khr_id  IN NUMBER,
                                  p_rbk_khr_id   IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         cle.lse_id
  FROM   okl_streams orig_stm,
         okl_strm_type_b sty,
         okc_k_lines_b cle
  WHERE  orig_stm.khr_id = p_orig_khr_id
  AND    orig_stm.say_code = 'CURR'

  AND    orig_stm.sty_id = sty.id
  AND    orig_stm.sgn_code NOT IN ('INTC','LATE_CALC') -- Bug 6472228
  -- gboomina Bug 6129455 - Start
  AND    sty.STREAM_TYPE_PURPOSE <>'ACTUAL_PROPERTY_TAX'
  -- gboomina Bug 6129455 - End
  AND    sty.billable_yn = 'Y'
  AND    cle.id(+) = orig_stm.kle_id
  AND    cle.dnz_chr_id(+) = orig_stm.khr_id
  AND    NOT EXISTS (SELECT 1
                     FROM okl_streams new_stm
                     WHERE new_stm.khr_id = p_rbk_khr_id
                     AND   new_stm.say_code = 'CURR'
                     AND   new_stm.link_hist_stream_id = orig_stm.id);

  l_max_bill_date DATE;
  l_actual_amount_billed NUMBER;
  l_amount_to_be_billed NUMBER;
  l_billing_adjustment NUMBER;

  l_selv_tbl  selv_tbl_type;
  x_selv_tbl  selv_tbl_type;

  l_selv_count NUMBER;
  i NUMBER;
  l_rebook_adj_tbl OKL_REBOOK_CM_PVT.rebook_adj_tbl_type;

  -- sjalasut, added variable that supports out parameter
  lx_disb_rec OKL_BPD_TERMINATION_ADJ_PVT.disb_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate billing adjustment
      -- for all Current Billable Streams for which billing was done
      -- in the Original contract

      i := 0;
      l_rebook_adj_tbl.DELETE;
      FOR curr_billable_streams_rec in curr_billable_streams_csr(p_khr_id => p_rbk_khr_id)
      LOOP

        l_max_bill_date := NULL;
        OPEN max_bill_date_csr(p_stm_id => curr_billable_streams_rec.orig_stm_id);
        FETCH max_bill_date_csr INTO l_max_bill_date;
        CLOSE max_bill_date_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream Id: '||curr_billable_streams_rec.new_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream Id: '||curr_billable_streams_rec.orig_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Max Bill Date: '||l_max_bill_date);
        END IF;

        IF l_max_bill_date IS NOT NULL THEN

          l_actual_amount_billed := 0;
          OPEN actual_amount_billed_csr(p_stm_id => curr_billable_streams_rec.orig_stm_id);
          FETCH actual_amount_billed_csr INTO l_actual_amount_billed;
          CLOSE actual_amount_billed_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Billed: '||l_actual_amount_billed);
          END IF;

          l_amount_to_be_billed := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_billed_rec IN
              amount_to_be_billed_csr(p_stm_id => curr_billable_streams_rec.new_stm_id,
                                      p_max_bill_date => l_max_bill_date)
          LOOP

            -- Call Streams api to update date_billed, bill_adj_flag
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_billed := l_amount_to_be_billed + amount_to_be_billed_rec.amount;

            l_selv_tbl(l_selv_count).id        := amount_to_be_billed_rec.sel_id;
            l_selv_tbl(l_selv_count).date_billed := SYSDATE;
            l_selv_tbl(l_selv_count).bill_adj_flag  := 'Y';

          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount to be Billed: '||l_amount_to_be_billed);
          END IF;

          l_billing_adjustment := l_amount_to_be_billed -  l_actual_amount_billed;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Billing Adjustment: '||l_billing_adjustment);
          END IF;

          IF l_billing_adjustment <> 0 THEN
            i := i + 1;
            l_rebook_adj_tbl(i).khr_id          := p_orig_khr_id;
            l_rebook_adj_tbl(i).kle_id          := curr_billable_streams_rec.kle_id;
            l_rebook_adj_tbl(i).sty_id          := curr_billable_streams_rec.sty_id;
            l_rebook_adj_tbl(i).adjusted_amount := l_billing_adjustment;
            l_rebook_adj_tbl(i).date_invoiced   := p_trx_date;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Billing Adjustment Record');
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).khr_id: '||l_rebook_adj_tbl(i).khr_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).kle_id: '||l_rebook_adj_tbl(i).kle_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).sty_id: '||l_rebook_adj_tbl(i).sty_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).adjusted_amount: '||l_rebook_adj_tbl(i).adjusted_amount);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).date_invoiced: '||l_rebook_adj_tbl(i).date_invoiced);
            END IF;

          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Stream Elements - Date Billed and Bill Adj Flag '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;
      END LOOP;

      -- For On-line rebook, calculate billing adjustment
      -- for Streams deleted during Rebook
      -- Insurance Streams are ignored by this process, so no
      -- adjustment will be calculated for Insurance Streams here
      IF (p_rbk_khr_id <> p_orig_khr_id) THEN  -- Online rebook

        FOR del_billable_streams_rec IN
            del_billable_streams_csr(p_orig_khr_id  => p_orig_khr_id,
                                     p_rbk_khr_id   => p_rbk_khr_id)
        LOOP
          -- Do not process Insurance Streams
          IF (NVL(del_billable_streams_rec.lse_id,-1) <> G_INSURANCE_LSE_ID) THEN

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Deleted Orig Stream Id: '||del_billable_streams_rec.orig_stm_id);
            END IF;

            l_actual_amount_billed := 0;
            OPEN actual_amount_billed_csr(p_stm_id => del_billable_streams_rec.orig_stm_id);
            FETCH actual_amount_billed_csr INTO l_actual_amount_billed;
            CLOSE actual_amount_billed_csr;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Billed: '||l_actual_amount_billed);
            END IF;

            l_billing_adjustment := -1 * l_actual_amount_billed;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Billing Adjustment: '||l_billing_adjustment);
            END IF;

            IF l_actual_amount_billed <> 0 THEN
              i := i + 1;
              l_rebook_adj_tbl(i).khr_id          := p_orig_khr_id;
              l_rebook_adj_tbl(i).kle_id          := del_billable_streams_rec.kle_id;
              l_rebook_adj_tbl(i).sty_id          := del_billable_streams_rec.sty_id;
              l_rebook_adj_tbl(i).adjusted_amount := l_billing_adjustment;
              l_rebook_adj_tbl(i).date_invoiced   := p_trx_date;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Billing Adjustment Record');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).khr_id: '||l_rebook_adj_tbl(i).khr_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).kle_id: '||l_rebook_adj_tbl(i).kle_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).sty_id: '||l_rebook_adj_tbl(i).sty_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).adjusted_amount: '||l_rebook_adj_tbl(i).adjusted_amount);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rebook_adj_tbl(i).date_invoiced: '||l_rebook_adj_tbl(i).date_invoiced);
              END IF;

            END IF;
          END IF;
        END LOOP;

      END IF;

      IF (l_rebook_adj_tbl.COUNT > 0) THEN
        OKL_REBOOK_CM_PVT.Rebook_Bill_adjustments
          (p_api_version          => p_api_version
          ,p_init_msg_list        => p_init_msg_list
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
          ,p_commit               => OKL_API.G_FALSE
          ,p_rebook_adj_tbl       => l_rebook_adj_tbl
          );

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling OKL_REBOOK_CM_PVT.Rebook_Bill_adjustments '||x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 4884423
        --Added new procedure for passthrough adjustments
        /*
        -- sjalasut, added code for Contract Rebook Enhancement. START
        OKL_BPD_TERMINATION_ADJ_PVT.create_rbk_passthru_adj(p_api_version    => p_api_version
                                                           ,p_init_msg_list  => p_init_msg_list
                                                           ,p_rebook_adj_tbl => l_rebook_adj_tbl
                                                           ,x_disb_rec       => lx_disb_rec
                                                           ,x_return_status  => x_return_status
                                                           ,x_msg_count      => x_msg_count
                                                           ,x_msg_data       => x_msg_data
                                                           );
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- sjalasut, added code for Contract Rebook Enhancement. END
        */

      END IF;

      --Bug# 4884423
      OKL_CONTRACT_REBOOK_PVT.create_pth_disb_adjustment
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_rbk_khr_id      => p_rbk_khr_id,
           p_orig_khr_id     => p_orig_khr_id,
           p_trx_id          => p_trx_id,
           p_trx_date        => p_trx_date
          );

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_billing_adjustment;


-- dedey, Bug#4264314
/*

  ------------------------------------------------------------------------------
-- PROCEDURE create_accrual_adjustment
--
--  This procedure calculates the accrual adjustment for all accrual streams
--  where there is a difference between amount actually accrued and amount
--  that should have been accrued and calls the Accrual api to make the
--  accrual adjustment. The current streams taken into account for
--  calculating accrual adjustment are then marked as Accrual adjusted in order
--  to stop duplicate accrual.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_accrual_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE
                         ) IS

  l_api_name             VARCHAR2(35)    := 'create_accrual_adjustment';
  l_proc_name            VARCHAR2(35)    := 'CREATE_ACCRUAL_ADJUSTMENT';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR curr_accrual_streams_csr(p_khr_id  IN NUMBER) IS
  SELECT new_stm.id   new_stm_id,
         orig_stm.id  orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         styt.name
  FROM   okl_streams new_stm,
         okl_prod_strm_types psty,
         okl_k_headers khr,
         okl_streams orig_stm,
         okl_strm_type_tl styt
  WHERE  khr.id = p_khr_id
  AND    psty.pdt_id = khr.pdt_id
  AND    psty.accrual_yn = 'Y'
  AND    psty.sty_id = new_stm.sty_id
  AND    new_stm.khr_id = khr.id
  AND    new_stm.say_code = 'CURR'
  AND    orig_stm.id = new_stm.link_hist_stream_id
  AND    styt.id = orig_stm.sty_id
  AND    styt.language = USERENV('LANG');

  CURSOR max_accrual_date_csr(p_stm_id IN NUMBER) IS
  SELECT MAX(sel.stream_element_date) stream_element_date
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR actual_amount_accrued_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(sel.amount),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR amount_to_be_accrued_csr(p_stm_id IN NUMBER,
                                  p_max_accrual_date IN DATE) IS
  SELECT sel.id sel_id,
         NVL(sel.amount,0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.stream_element_date <= p_max_accrual_date;

  -- Cursor to fetch Streams deleted during rebook
  CURSOR del_accrual_streams_csr(p_orig_khr_id  IN NUMBER,
                                 p_rbk_khr_id   IN NUMBER) IS
  SELECT orig_stm.id orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         styt.name,
         cle.lse_id
  FROM   okl_streams orig_stm,
         okl_prod_strm_types psty,
         okl_k_headers khr,
         okc_k_lines_b cle,
         okl_strm_type_tl styt
  WHERE  khr.id = p_orig_khr_id
  AND    psty.pdt_id = khr.pdt_id
  AND    psty.accrual_yn = 'Y'
  AND    psty.sty_id = orig_stm.sty_id
  AND    orig_stm.khr_id = khr.id
  AND    orig_stm.say_code = 'CURR'
  AND    cle.id(+) = orig_stm.kle_id
  AND    cle.dnz_chr_id(+) = orig_stm.khr_id
  AND    NOT EXISTS (SELECT 1
                     FROM okl_streams new_stm
                     WHERE new_stm.khr_id = p_rbk_khr_id
                     AND   new_stm.say_code = 'CURR'
                     AND   new_stm.link_hist_stream_id = orig_stm.id)
  AND    styt.id = orig_stm.sty_id
  AND    styt.language = USERENV('LANG');

  l_max_accrual_date DATE;
  l_actual_amount_accrued NUMBER;
  l_amount_to_be_accrued NUMBER;
  l_accrual_adjustment NUMBER;

  l_selv_tbl    selv_tbl_type;
  x_selv_tbl    selv_tbl_type;

  l_selv_count  NUMBER;

  i             NUMBER;
  lx_trx_number OKL_TRX_CONTRACTS.trx_number%TYPE;
  l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  l_gl_date     DATE;

  BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      debug_message(l_proc_name);
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate accrual adjustment
      -- for all Current Accrual Streams for which Accruals were generated
      -- in the Original contract

      i := 0;
      l_stream_tbl.DELETE;
      FOR curr_accrual_streams_rec in curr_accrual_streams_csr(p_khr_id => p_rbk_khr_id)
      LOOP

        l_max_accrual_date := NULL;
        OPEN max_accrual_date_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
        FETCH max_accrual_date_csr INTO l_max_accrual_date;
        CLOSE max_accrual_date_csr;

        debug_message('New Stream Id: '||curr_accrual_streams_rec.new_stm_id);
        debug_message('Orig Stream Id: '||curr_accrual_streams_rec.orig_stm_id);
        debug_message('Max Accrual Date: '||l_max_accrual_date);

        IF l_max_accrual_date IS NOT NULL THEN

          l_actual_amount_accrued := 0;
          OPEN actual_amount_accrued_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
          FETCH actual_amount_accrued_csr INTO l_actual_amount_accrued;
          CLOSE actual_amount_accrued_csr;

          debug_message('Actual Amount Accrued: '||l_actual_amount_accrued);

          l_amount_to_be_accrued := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_accrued_rec IN
              amount_to_be_accrued_csr(p_stm_id => curr_accrual_streams_rec.new_stm_id,
                                      p_max_accrual_date => l_max_accrual_date)
          LOOP

            -- Call Streams api to update accrued_yn, accrual_adj_flag
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_accrued := l_amount_to_be_accrued + amount_to_be_accrued_rec.amount;

            l_selv_tbl(l_selv_count).id        := amount_to_be_accrued_rec.sel_id;
            l_selv_tbl(l_selv_count).accrued_yn := 'Y';
            l_selv_tbl(l_selv_count).accrual_adj_flag  := 'Y';

          END LOOP;

          debug_message('Amount to be Accrued: '||l_amount_to_be_accrued);

          l_accrual_adjustment := l_amount_to_be_accrued -  l_actual_amount_accrued;

          debug_message('Accrual Adjustment: '||l_accrual_adjustment);

          IF l_accrual_adjustment <> 0 THEN
            i := i + 1;
            l_stream_tbl(i).stream_type_id   := curr_accrual_streams_rec.sty_id;
            l_stream_tbl(i).stream_type_name := curr_accrual_streams_rec.name;
            l_stream_tbl(i).stream_amount    := l_accrual_adjustment;
            l_stream_tbl(i).kle_id           := curr_accrual_streams_rec.kle_id;

            debug_message('Accrual Adjustment Record');
            debug_message('i '||i);
            debug_message('l_stream_tbl(i).stream_type_id: '||l_stream_tbl(i).stream_type_id);
            debug_message('l_stream_tbl(i).stream_type_name: '||l_stream_tbl(i).stream_type_name);
            debug_message('l_stream_tbl(i).stream_amount: '||l_stream_tbl(i).stream_amount);
            debug_message('l_stream_tbl(i).kle_id: '||l_stream_tbl(i).kle_id);
          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            debug_message('After Update of Stream Elements - Accrued Yn and Accrual Adj Flag '||x_return_status);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;
      END LOOP;

      -- For On-line rebook, calculate accrual adjustment
      -- for Streams deleted during Rebook
      -- Insurance Streams are ignored by this process, so no
      -- adjustment will be calculated for Insurance Streams here
      IF (p_rbk_khr_id <> p_orig_khr_id) THEN  -- Online rebook

        FOR del_accrual_streams_rec IN
            del_accrual_streams_csr(p_orig_khr_id  => p_orig_khr_id,
                                    p_rbk_khr_id   => p_rbk_khr_id)
        LOOP

          -- Do not process Insurance Streams
          IF (NVL(del_accrual_streams_rec.lse_id,-1) <> G_INSURANCE_LSE_ID) THEN

            debug_message('Deleted Orig Stream Id: '||del_accrual_streams_rec.orig_stm_id);

            l_actual_amount_accrued := 0;
            OPEN actual_amount_accrued_csr(p_stm_id => del_accrual_streams_rec.orig_stm_id);
            FETCH actual_amount_accrued_csr INTO l_actual_amount_accrued;
            CLOSE actual_amount_accrued_csr;

            debug_message('Actual Amount Accrued: '||l_actual_amount_accrued);

            l_accrual_adjustment := -1 * l_actual_amount_accrued;

            debug_message('Accrual Adjustment: '||l_accrual_adjustment);

            IF l_actual_amount_accrued <> 0 THEN
              i := i + 1;
              l_stream_tbl(i).stream_type_id   := del_accrual_streams_rec.sty_id;
              l_stream_tbl(i).stream_type_name := del_accrual_streams_rec.name;
              l_stream_tbl(i).stream_amount    := l_accrual_adjustment;
              l_stream_tbl(i).kle_id           := del_accrual_streams_rec.kle_id;

              debug_message('Accrual Adjustment Record');
              debug_message('i '||i);
              debug_message('l_stream_tbl(i).stream_type_id: '||l_stream_tbl(i).stream_type_id);
              debug_message('l_stream_tbl(i).stream_type_name: '||l_stream_tbl(i).stream_type_name);
              debug_message('l_stream_tbl(i).stream_amount: '||l_stream_tbl(i).stream_amount);
              debug_message('l_stream_tbl(i).kle_id: '||l_stream_tbl(i).kle_id);
            END IF;
          END IF;
        END LOOP;

      END IF;

      IF (l_stream_tbl.COUNT > 0) THEN

        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => p_trx_date);

        l_accrual_rec.contract_id   := p_orig_khr_id;
        l_accrual_rec.accrual_date  := l_gl_date;
        l_accrual_rec.description   := 'Rebook Adjustment';
        l_accrual_rec.source_trx_id := p_trx_id;
        l_accrual_rec.source_trx_type := 'TCN';

        debug_message('Accrual Adjustment Header Record');
        debug_message('l_accrual_rec.contract_id: '||l_accrual_rec.contract_id);
        debug_message('l_accrual_rec.accrual_date: '||l_accrual_rec.accrual_date);
        debug_message('l_accrual_rec.description: '||l_accrual_rec.description);
        debug_message('l_accrual_rec.source_trx_id: '||l_accrual_rec.source_trx_id);
        debug_message('l_accrual_rec.source_trx_type: '||l_accrual_rec.source_trx_type);

        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          x_trx_number     => lx_trx_number,
          p_accrual_rec    => l_accrual_rec,
          p_stream_tbl     => l_stream_tbl);

        debug_message('After calling OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS '||x_return_status);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_accrual_adjustment;
--Bug# 4212626: end
*/

  ------------------------------------------------------------------------------
-- PROCEDURE calc_accrual_adjustment
--
--  This procedure calculates the accrual adjustment for all accrual streams
--  where there is a difference between amount actually accrued and amount
--  that should have been accrued and calls the Accrual api to make the
--  accrual adjustment. The current streams taken into account for
--  calculating accrual adjustment are then marked as Accrual adjusted in order
--  to stop duplicate accrual.
--
-- Calls:
-- Called By:
-- Added new input parameters p_trx_tbl_code and p_trx_type for Bug# 6344223
------------------------------------------------------------------------------
PROCEDURE calc_accrual_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE,
                         x_accrual_rec     OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type,
                         x_stream_tbl      OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type,
                         p_trx_tbl_code    IN  VARCHAR2 DEFAULT 'TCN',
                         p_trx_type        IN  VARCHAR2 DEFAULT 'CRB'
                         ) IS

  l_api_name             VARCHAR2(35)    := 'calc_accrual_adjustment';
  l_proc_name            VARCHAR2(35)    := 'calc_accrual_adjustment';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR curr_accrual_streams_csr(p_khr_id  IN NUMBER,
                                  p_reporting_pdt_id IN NUMBER) IS -- MGAAP
  SELECT new_stm.id   new_stm_id,
         orig_stm.id  orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         sty.name
  --FROM   okl_streams new_stm,
  FROM   okl_streams_rep_v new_stm, -- MGAAP 7263041
         okl_prod_strm_types psty,
         okl_k_headers khr,
         --okl_streams orig_stm,
         okl_streams_rep_v orig_stm, -- MGAAP 7263041
         okl_strm_type_v sty
  WHERE  khr.id = p_khr_id
  --AND    psty.pdt_id = khr.pdt_id
  AND    psty.pdt_id = DECODE(OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY,
                'PRIMARY', khr.pdt_id, p_reporting_pdt_id) -- MGAAP 7263041
  AND    psty.accrual_yn = 'Y'
  AND    psty.sty_id = new_stm.sty_id
  AND    new_stm.khr_id = khr.id
  AND    new_stm.say_code = 'CURR'
  AND    orig_stm.id = new_stm.link_hist_stream_id
  AND    sty.id = orig_stm.sty_id
  -- Bug# 4775555: Exclude Investor accrual streams
  AND    sty.stream_type_purpose NOT IN
         ('INVESTOR_RENTAL_ACCRUAL',
          'INVESTOR_PRETAX_INCOME',
          'INVESTOR_INTEREST_INCOME',
          'INVESTOR_VARIABLE_INTEREST');

  CURSOR max_accrual_date_csr(p_stm_id IN NUMBER) IS
  SELECT MAX(sel.stream_element_date) stream_element_date
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR actual_amount_accrued_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(sel.amount),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR amount_to_be_accrued_csr(p_stm_id IN NUMBER,
                                  p_max_accrual_date IN DATE) IS
  SELECT sel.id sel_id,
         NVL(sel.amount,0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.stream_element_date <= p_max_accrual_date;

  -- Cursor to fetch Streams deleted during rebook
  CURSOR del_accrual_streams_csr(p_orig_khr_id  IN NUMBER,
                                 p_rbk_khr_id   IN NUMBER,
                                 p_reporting_pdt_id   IN NUMBER) IS -- MGAAP
  SELECT orig_stm.id orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         sty.name,
         cle.lse_id
  --FROM   okl_streams orig_stm,
  FROM   okl_streams_rep_v orig_stm, -- MGAAP 7263041
         okl_prod_strm_types psty,
         okl_k_headers khr,
         okc_k_lines_b cle,
         okl_strm_type_v sty
  WHERE  khr.id = p_orig_khr_id
  --AND    psty.pdt_id = khr.pdt_id
  AND    psty.pdt_id = DECODE(OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY,
                'PRIMARY', khr.pdt_id, p_reporting_pdt_id) -- MGAAP 7263041
  AND    psty.accrual_yn = 'Y'
  AND    psty.sty_id = orig_stm.sty_id
  AND    orig_stm.khr_id = khr.id
  AND    orig_stm.say_code = 'CURR'
  AND    orig_stm.sgn_code NOT IN ('INTC','LATE_CALC') -- Bug6472228
  AND    cle.id(+) = orig_stm.kle_id
  AND    cle.dnz_chr_id(+) = orig_stm.khr_id
  AND    NOT EXISTS (SELECT 1
                     --FROM okl_streams new_stm
                     FROM okl_streams_rep_v new_stm -- MGAAP 7263041
                     WHERE new_stm.khr_id = p_rbk_khr_id
                     AND   new_stm.say_code = 'CURR'
                     AND   new_stm.link_hist_stream_id = orig_stm.id)
  AND    sty.id = orig_stm.sty_id
  -- Bug# 4775555: Exclude Investor accrual streams
  AND    sty.stream_type_purpose NOT IN
         ('INVESTOR_RENTAL_ACCRUAL',
          'INVESTOR_PRETAX_INCOME',
          'INVESTOR_INTEREST_INCOME',
          'INVESTOR_VARIABLE_INTEREST');

  l_max_accrual_date DATE;
  l_actual_amount_accrued NUMBER;
  l_amount_to_be_accrued NUMBER;
  l_accrual_adjustment NUMBER;

  l_selv_tbl    selv_tbl_type;
  x_selv_tbl    selv_tbl_type;

  l_selv_count  NUMBER;

  i             NUMBER;
  --lx_trx_number OKL_TRX_CONTRACTS.trx_number%TYPE;
  l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  l_gl_date     DATE;

  -- MGAAP start 7263041
  CURSOR c_get_reporting_pdt_id(p_chr_id IN NUMBER) IS
  SELECT b.reporting_pdt_id, a.multi_gaap_yn
  FROM   okl_k_headers a,
         okl_products b
  WHERE  a.ID = p_chr_id
  AND    a.PDT_ID = b.ID;

  l_reporting_pdt_id OKL_PRODUCTS.reporting_pdt_id%TYPE := null;
  l_multi_gaap_yn  OKL_K_HEADERS.MULTI_GAAP_YN%TYPE;
  l_current_mgaap_context VARCHAR2(10);
  -- MGAAP end 7263041

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate accrual adjustment
      -- for all Current Accrual Streams for which Accruals were generated
      -- in the Original contract

      -- MGAAP start 7263041
      l_current_mgaap_context := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;
      IF (l_current_mgaap_context = 'REPORT') THEN
        OPEN c_get_reporting_pdt_id(p_rbk_khr_id);
        FETCH c_get_reporting_pdt_id INTO l_reporting_pdt_id, l_multi_gaap_yn;
        CLOSE c_get_reporting_pdt_id;
      END IF;
      -- MGAAP end 7263041

      i := 0;
      l_stream_tbl.DELETE;
      FOR curr_accrual_streams_rec IN curr_accrual_streams_csr(p_khr_id => p_rbk_khr_id, p_reporting_pdt_id => l_reporting_pdt_id)
      LOOP

        l_max_accrual_date := NULL;
        OPEN max_accrual_date_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
        FETCH max_accrual_date_csr INTO l_max_accrual_date;
        CLOSE max_accrual_date_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream Id: '||curr_accrual_streams_rec.new_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream Id: '||curr_accrual_streams_rec.orig_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Max Accrual Date: '||l_max_accrual_date);
        END IF;

        IF l_max_accrual_date IS NOT NULL THEN

          l_actual_amount_accrued := 0;
          OPEN actual_amount_accrued_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
          FETCH actual_amount_accrued_csr INTO l_actual_amount_accrued;
          CLOSE actual_amount_accrued_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Accrued: '||l_actual_amount_accrued);
          END IF;

          l_amount_to_be_accrued := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_accrued_rec IN
              amount_to_be_accrued_csr(p_stm_id => curr_accrual_streams_rec.new_stm_id,
                                      p_max_accrual_date => l_max_accrual_date)
          LOOP

            -- Call Streams api to update accrued_yn, accrual_adj_flag
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_accrued := l_amount_to_be_accrued + amount_to_be_accrued_rec.amount;

            l_selv_tbl(l_selv_count).id        := amount_to_be_accrued_rec.sel_id;
            l_selv_tbl(l_selv_count).accrued_yn := 'Y';
            l_selv_tbl(l_selv_count).accrual_adj_flag  := 'Y';

          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount to be Accrued: '||l_amount_to_be_accrued);
          END IF;

          l_accrual_adjustment := l_amount_to_be_accrued -  l_actual_amount_accrued;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment: '||l_accrual_adjustment);
          END IF;

          IF l_accrual_adjustment <> 0 THEN
            i := i + 1;
            l_stream_tbl(i).stream_type_id   := curr_accrual_streams_rec.sty_id;
            l_stream_tbl(i).stream_type_name := curr_accrual_streams_rec.name;
            l_stream_tbl(i).stream_amount    := l_accrual_adjustment;
            l_stream_tbl(i).kle_id           := curr_accrual_streams_rec.kle_id;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment Record');
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_id: '||l_stream_tbl(i).stream_type_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_name: '||l_stream_tbl(i).stream_type_name);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_amount: '||l_stream_tbl(i).stream_amount);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).kle_id: '||l_stream_tbl(i).kle_id);
            END IF;
          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Stream Elements - Accrued Yn and Accrual Adj Flag '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;
      END LOOP;

      -- For On-line rebook, calculate accrual adjustment
      -- for Streams deleted during Rebook
      -- Insurance Streams are ignored by this process, so no
      -- adjustment will be calculated for Insurance Streams here
      IF (p_rbk_khr_id <> p_orig_khr_id) THEN  -- Online rebook

        FOR del_accrual_streams_rec IN
            del_accrual_streams_csr(p_orig_khr_id  => p_orig_khr_id,
                                    p_rbk_khr_id   => p_rbk_khr_id,
                                    p_reporting_pdt_id   => l_reporting_pdt_id)
        LOOP

          -- Do not process Insurance Streams
          IF (NVL(del_accrual_streams_rec.lse_id,-1) <> G_INSURANCE_LSE_ID) THEN

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Deleted Orig Stream Id: '||del_accrual_streams_rec.orig_stm_id);
            END IF;

            l_actual_amount_accrued := 0;
            OPEN actual_amount_accrued_csr(p_stm_id => del_accrual_streams_rec.orig_stm_id);
            FETCH actual_amount_accrued_csr INTO l_actual_amount_accrued;
            CLOSE actual_amount_accrued_csr;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Accrued: '||l_actual_amount_accrued);
            END IF;

            l_accrual_adjustment := -1 * l_actual_amount_accrued;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment: '||l_accrual_adjustment);
            END IF;

            IF l_actual_amount_accrued <> 0 THEN
              i := i + 1;
              l_stream_tbl(i).stream_type_id   := del_accrual_streams_rec.sty_id;
              l_stream_tbl(i).stream_type_name := del_accrual_streams_rec.name;
              l_stream_tbl(i).stream_amount    := l_accrual_adjustment;
              l_stream_tbl(i).kle_id           := del_accrual_streams_rec.kle_id;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment Record');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_id: '||l_stream_tbl(i).stream_type_id);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_name: '||l_stream_tbl(i).stream_type_name);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_amount: '||l_stream_tbl(i).stream_amount);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).kle_id: '||l_stream_tbl(i).kle_id);
              END IF;
            END IF;
          END IF;
        END LOOP;

      END IF;

      IF (l_stream_tbl.COUNT > 0) THEN

        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => p_trx_date);

        l_accrual_rec.contract_id   := p_orig_khr_id;
        l_accrual_rec.accrual_date  := l_gl_date;
        l_accrual_rec.source_trx_id := p_trx_id;

        --Bug# 6344223
        l_accrual_rec.source_trx_type := p_trx_tbl_code;
        IF p_trx_type = 'CRB' THEN
          l_accrual_rec.description   := 'Rebook Adjustment';
        ELSIF p_trx_type = 'ALI' THEN
          l_accrual_rec.description   := 'Split Asset Adjustment';
        END IF;
        --end Bug# 6344223

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment Header Record');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.contract_id: '||l_accrual_rec.contract_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.accrual_date: '||l_accrual_rec.accrual_date);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.description: '||l_accrual_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.source_trx_id: '||l_accrual_rec.source_trx_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.source_trx_type: '||l_accrual_rec.source_trx_type);
        END IF;


          x_stream_tbl := l_stream_tbl;
          x_accrual_rec := l_accrual_rec;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);
  END calc_accrual_adjustment;

-- dedey, Bug#4264314

-- Bug# 4775555: Start
------------------------------------------------------------------------------
-- PROCEDURE create_inv_disb_adjustment
--
--  This procedure calculates the disbursement adjustment for all disbursement streams
--  where there is a difference between amount actually disbursed and amount
--  that should have been disbursed and creates an Inverstor Disbursement Adjustment
--  Stream for the adjustment amount. The current streams taken into account for
--  calculating disbursement adjustment are then marked as Disbursement adjusted in order
--  to stop duplicate disbursement.
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_inv_disb_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_orig_khr_id     IN  NUMBER
                         ) IS

  l_api_name             VARCHAR2(35)    := 'create_inv_disb_adjustment';
  l_proc_name            VARCHAR2(35)    := 'CREATE_INV_DISB_ADJUSTMENT';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR  chr_assets_csr(p_khr_id IN NUMBER) IS
  SELECT  id    cle_id
  FROM    okc_k_lines_b cle
  WHERE   cle.chr_id = p_khr_id
  AND     cle.dnz_chr_id = p_khr_id
  AND     cle.lse_id = 33;

  CURSOR  curr_sec_strms_csr(p_khr_id IN NUMBER,
                             p_kle_id IN NUMBER) IS
  SELECT  pol.khr_id     agreement_id,
          new_stm.khr_id khr_id,
          new_stm.kle_id kle_id,
          new_stm.sty_id sty_id,
          new_stm.id     new_stm_id,
          orig_stm.id    orig_stm_id
  FROM    okl_pools pol,
          okl_pool_contents pcn,
	  okl_strm_type_b sty,
	  okl_streams new_stm,
          okl_streams orig_stm
  WHERE   pcn.sty_id = sty.id
  AND     pcn.pol_id = pol.id
  AND     new_stm.kle_id = pcn.kle_id
  AND     new_stm.khr_id = pcn.khr_id
  AND     new_stm.sty_id = pcn.sty_id
  AND     new_stm.say_code = 'CURR'
  AND     new_stm.active_yn = 'Y'
  AND     pol.status_code = 'ACTIVE'
  AND     pcn.status_code = 'ACTIVE'
  AND     new_stm.khr_id = p_khr_id
  AND     new_stm.kle_id = p_kle_id
  AND     sty.billable_yn = 'Y'
  AND     orig_stm.id = new_stm.link_hist_stream_id;

  CURSOR actual_amount_disb_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(inv_sel.amount),0) amount
  FROM   okl_strm_elements inv_sel,
         okl_strm_elements sel
  WHERE  sel.stm_id = p_stm_id
  AND    sel.date_billed IS NOT NULL
  AND    inv_sel.sel_id = sel.id;

  CURSOR amount_to_be_disb_csr(p_stm_id IN NUMBER) IS
  SELECT inv_sel.id sel_id,
         NVL(inv_sel.amount,0) amount
  FROM   okl_strm_elements inv_sel,
         okl_strm_elements sel
  WHERE  sel.stm_id = p_stm_id
  AND    sel.date_billed IS NOT NULL
  AND    inv_sel.sel_id = sel.id;

  l_actual_amount_disb NUMBER;
  l_amount_to_be_disb NUMBER;
  l_disb_adjustment NUMBER;

  TYPE disb_adj_rec_type IS RECORD (
     kle_id       NUMBER := NULL,
     disb_adj_amt NUMBER := NULL);

  TYPE disb_adj_tbl_type IS TABLE OF disb_adj_rec_type
  INDEX BY BINARY_INTEGER;

  l_disb_adj_tbl  disb_adj_tbl_type;

  l_stmv_rec_init       Okl_Streams_pub.stmv_rec_type;

  l_stmv_rec_new_disb   Okl_Streams_pub.stmv_rec_type;
  l_selv_tbl_new_disb   Okl_Streams_pub.selv_tbl_type;
  lx_stmv_rec_new_disb  Okl_Streams_pub.stmv_rec_type;
  lx_selv_tbl_new_disb  Okl_Streams_pub.selv_tbl_type;

  l_stmv_rec_old_disb   Okl_Streams_pub.stmv_rec_type;
  lx_stmv_rec_old_disb  Okl_Streams_pub.stmv_rec_type;

  l_selv_tbl  selv_tbl_type;
  x_selv_tbl  selv_tbl_type;

  l_selv_count NUMBER;
  i NUMBER;

  CURSOR l_trx_num_csr IS
  SELECT OKL_SIF_SEQ.NEXTVAL
  FROM dual;

  l_transaction_number NUMBER;

  CURSOR old_disb_adj_stm_csr(p_chr_id  NUMBER,
                              p_kle_id  NUMBER)
  IS
  SELECT stm.id stm_id
  FROM   okl_streams stm,
         okl_strm_type_b sty
  WHERE stm.khr_id    = p_chr_id
  AND   stm.kle_id    = p_kle_id
  AND   stm.sty_id    = sty.id
  AND   stm.say_code  = 'CURR'
  AND   stm.active_yn = 'Y'
  AND   sty.stream_type_purpose = 'INVESTOR_DISB_ADJUSTMENT';

  l_old_disb_adj_stm_rec old_disb_adj_stm_csr%ROWTYPE;

  CURSOR undisb_adj_amt_csr(p_stm_id  NUMBER)
  IS
  SELECT NVL(SUM(sel.AMOUNT),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND sel.date_billed IS NULL;

  l_undisb_adj_amt_rec undisb_adj_amt_csr%ROWTYPE;

  CURSOR chk_old_adj_disb_csr(p_stm_id  NUMBER)
  IS
  SELECT 'Y'
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND sel.date_billed IS NULL;

  l_undisb_adj_exists VARCHAR2(30);

  l_disb_adj_sty_id  OKL_STRM_TYPE_B.id%TYPE;
  l_inv_agreement_id OKC_K_HEADERS_B.id%TYPE;

 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate disbursement adjustment
      -- for all Current Billable Securitized Streams for which billing was done
      -- in the Original contract

      i := 0;
      l_disb_adj_tbl.DELETE;
      FOR chr_assets_rec IN chr_assets_csr(p_khr_id => p_orig_khr_id)
      LOOP

        i := i+1;
        FOR curr_sec_strms_rec in curr_sec_strms_csr(p_khr_id => p_orig_khr_id,
                                                     p_kle_id => chr_assets_rec.cle_id)
        LOOP

          l_inv_agreement_id :=  curr_sec_strms_rec.agreement_id;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream Id: '||curr_sec_strms_rec.new_stm_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream Id: '||curr_sec_strms_rec.orig_stm_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Kle Id: '||curr_sec_strms_rec.kle_id);
          END IF;

          l_actual_amount_disb:= 0;
          OPEN actual_amount_disb_csr(p_stm_id => curr_sec_strms_rec.orig_stm_id);
          FETCH actual_amount_disb_csr INTO l_actual_amount_disb;
          CLOSE actual_amount_disb_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Disbursed: '||l_actual_amount_disb);
          END IF;

          l_amount_to_be_disb := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_disb_rec IN
              amount_to_be_disb_csr(p_stm_id => curr_sec_strms_rec.new_stm_id)
          LOOP

            -- Call Streams api to update date_billed, bill_adj_flag
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_disb := l_amount_to_be_disb + amount_to_be_disb_rec.amount;
            l_selv_tbl(l_selv_count).id        := amount_to_be_disb_rec.sel_id;
            l_selv_tbl(l_selv_count).date_billed := SYSDATE;
            l_selv_tbl(l_selv_count).bill_adj_flag  := 'Y';
          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount to be Disbursed: '||l_amount_to_be_disb);
          END IF;

          l_disb_adjustment := l_amount_to_be_disb -  l_actual_amount_disb;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disbursement Adjustment: '||l_disb_adjustment);
          END IF;

          l_disb_adj_tbl(i).kle_id := curr_sec_strms_rec.kle_id;
          l_disb_adj_tbl(i).disb_adj_amt := NVL(l_disb_adj_tbl(i).disb_adj_amt,0) + l_disb_adjustment;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i: '||i);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_disb_adj_tbl(i).kle_id: '||l_disb_adj_tbl(i).kle_id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_disb_adj_tbl(i).disb_adj_amt: '||l_disb_adj_tbl(i).disb_adj_amt);
          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => p_api_version,
                                      p_init_msg_list  => p_init_msg_list,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Stream Elements - Date Billed and Bill Adj Flag '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
              raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
              raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END LOOP;
      END LOOP;

      IF (l_disb_adj_tbl.COUNT > 0) THEN

        OKL_STREAMS_UTIL.get_primary_stream_type(
          p_khr_id               => l_inv_agreement_id,
          p_primary_sty_purpose  => 'INVESTOR_DISB_ADJUSTMENT',
          x_return_status        => x_return_status,
          x_primary_sty_id       => l_disb_adj_sty_id
         );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Disb Adjustment Stream Type Id: '||l_disb_adj_sty_id);
        END IF;

        --Bug# 6788253
        i := l_disb_adj_tbl.FIRST;
        LOOP

          l_stmv_rec_old_disb := l_stmv_rec_init;
          l_stmv_rec_new_disb := l_stmv_rec_init;
          l_selv_tbl_new_disb.DELETE;

          -- Fetch Existing Disbursement Adjustment Stream
          l_old_disb_adj_stm_rec.stm_id := NULL;
          OPEN old_disb_adj_stm_csr(p_chr_id  => p_orig_khr_id,
                                    p_kle_id  => l_disb_adj_tbl(i).kle_id);
          FETCH old_disb_adj_stm_csr INTO l_old_disb_adj_stm_rec;
          CLOSE old_disb_adj_stm_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Old Disb Adjustment Stream Id: '||l_old_disb_adj_stm_rec.stm_id);
          END IF;

          -- If New Disbursement Adjustment <> 0
          IF (NVL(l_disb_adj_tbl(i).disb_adj_amt,0) <> 0) THEN

            -- Fetch Existing Undisbursed Adjustment Amount
            l_undisb_adj_amt_rec.amount := 0;
            IF l_old_disb_adj_stm_rec.stm_id IS NOT NULL THEN
              OPEN undisb_adj_amt_csr(p_stm_id => l_old_disb_adj_stm_rec.stm_id);
              FETCH undisb_adj_amt_csr INTO l_undisb_adj_amt_rec;
              CLOSE undisb_adj_amt_csr;
            END IF;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Old Disb Adjustment Amount: '||l_undisb_adj_amt_rec.amount);
            END IF;

            -- Historize existing Disbursement Adjustment stream
            IF l_old_disb_adj_stm_rec.stm_id IS NOT NULL THEN

              l_stmv_rec_old_disb.id        := l_old_disb_adj_stm_rec.stm_id;
              l_stmv_rec_old_disb.say_code  := 'HIST';
              l_stmv_rec_old_disb.active_yn := 'N';
              l_stmv_rec_old_disb.date_history  := SYSDATE;

              Okl_Streams_Pub.update_streams(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_stmv_rec      => l_stmv_rec_old_disb,
                            x_stmv_rec      => lx_stmv_rec_old_disb);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Historizing Existing Investor Disbursement Adjustment Stream');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling OKL_STREAMS_PUB.update_streams'||x_return_status);
              END IF;

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;

            l_stmv_rec_new_disb.khr_id := p_orig_khr_id;
            l_stmv_rec_new_disb.kle_id := l_disb_adj_tbl(i).kle_id;
            l_stmv_rec_new_disb.say_code := 'CURR';
            l_stmv_rec_new_disb.active_yn := 'Y';
            l_stmv_rec_new_disb.date_current := sysdate;

            -- to get the transaction number of the contract
            OPEN  l_trx_num_csr;
            FETCH l_trx_num_csr INTO l_transaction_number;
            CLOSE l_trx_num_csr;

            l_stmv_rec_new_disb.transaction_number := l_transaction_number;
            l_stmv_rec_new_disb.sgn_code           := 'MANL';
            l_stmv_rec_new_disb.sty_id             := l_disb_adj_sty_id;
            l_stmv_rec_new_disb.source_id          := l_inv_agreement_id;
            l_stmv_rec_new_disb.source_table       := 'OKL_K_HEADERS';

            l_selv_tbl_new_disb(1).amount := l_disb_adj_tbl(i).disb_adj_amt + l_undisb_adj_amt_rec.amount;
            l_selv_tbl_new_disb(1).accrued_yn := 'Y';
            l_selv_tbl_new_disb(1).stream_element_date := sysdate;
            l_selv_tbl_new_disb(1).se_line_number := 1;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Total Disb Adjustment Amount: '||l_selv_tbl_new_disb(1).amount);
            END IF;

            IF l_selv_tbl_new_disb(1).amount <> 0 THEN
              Okl_Streams_Pub.create_streams(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_stmv_rec      => l_stmv_rec_new_disb,
                            p_selv_tbl      => l_selv_tbl_new_disb,
                            x_stmv_rec      => lx_stmv_rec_new_disb,
                            x_selv_tbl      => lx_selv_tbl_new_disb);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Creating New Investor Disbursement Adjustment Stream');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling OKL_STREAMS_PUB.create_streams'||x_return_status);
              END IF;

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;

          -- New Disbursement Adjustment = 0
          ELSE

            l_undisb_adj_exists := 'N';
            OPEN chk_old_adj_disb_csr(p_stm_id => l_old_disb_adj_stm_rec.stm_id);
            FETCH chk_old_adj_disb_csr INTO l_undisb_adj_exists;
            CLOSE chk_old_adj_disb_csr;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Undisbursed Disb Adjustment Exists: '||l_undisb_adj_exists);
            END IF;

            -- Historize existing Disbursement Adjustment stream
            -- if it has been disbursed
            IF (l_old_disb_adj_stm_rec.stm_id IS NOT NULL AND l_undisb_adj_exists = 'N') THEN

              l_stmv_rec_old_disb.id        := l_old_disb_adj_stm_rec.stm_id;
              l_stmv_rec_old_disb.say_code  := 'HIST';
              l_stmv_rec_old_disb.active_yn := 'N';
              l_stmv_rec_old_disb.date_history := SYSDATE;

              Okl_Streams_Pub.update_streams(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_stmv_rec      => l_stmv_rec_old_disb,
                            x_stmv_rec      => lx_stmv_rec_old_disb);

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Historizing Existing Investor Disbursement Adjustment Stream');
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling OKL_STREAMS_PUB.update_streams'||x_return_status);
              END IF;

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;
          END IF;

          --Bug# 6788253
          EXIT WHEN i = l_disb_adj_tbl.LAST;
          i := l_disb_adj_tbl.NEXT(i);
        END LOOP;

      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_inv_disb_adjustment;

    ------------------------------------------------------------------------------
-- PROCEDURE link_inv_accrual_streams
--
--  This procedure links the Inversotr Accrual WORK Streams created during Rebook
--  to the corresponding matching CURR Streams in the original contract and
--  also updates the WORK streams with Source Transaction Id.
--
-- Calls:
-- Called By:
-- HISTORY - sechawla 12-Mar-09 : MG Impact on Investor Agreements - Update reporting
--                    streams generated during rebook with trx_id and link_hist_stream_id
------------------------------------------------------------------------------
  PROCEDURE link_inv_accrual_streams(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_khr_id          IN  NUMBER
                         ) IS

  l_api_name             VARCHAR2(35)    := 'link_inv_accrual_streams';
  l_proc_name            VARCHAR2(35)    := 'LINK_INV_ACCRUAL_STREAMS';
  l_api_version          CONSTANT NUMBER := 1;

  --get the Online Rebook transaction in ENTERED status for Primary representation
  CURSOR chk_rbk_csr(p_chr_id IN NUMBER) is
  SELECT '!', ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx,
         okc_k_headers_b cpy_chr
  WHERE  ktrx.khr_id = chr.id
  AND    ktrx.khr_id_new = cpy_chr.id
  AND    ktrx.tsu_code = 'ENTERED'
  AND    ktrx.rbr_code is NOT NULL --sechawla - added comment: identifies the actual online rebook process transaction.
                                   --           This transaction is created only for primary rep.
                                   --           ID of this transaction (ktrx.id) is stamped on both primary and reporting streams
  AND    ktrx.tcn_type = 'TRBK'
  AND    chr.id = p_chr_id
  AND    cpy_chr.orig_system_id1 = chr.id
  AND    cpy_chr.orig_system_source_code = 'OKL_REBOOK'
  AND    ktrx.representation_type = 'PRIMARY'; -- MGAAP 7263041

 /*
  --sechawla 12-mar-09 MG Impact on Rebook
  --get the Online Rebook transaction in Entered status for secondary representation
  CURSOR chk_rbk_secondary_csr(p_chr_id IN NUMBER) is
  SELECT '!', ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx,
         okc_k_headers_b cpy_chr
  WHERE  ktrx.khr_id = chr.id
  AND    ktrx.khr_id_new = cpy_chr.id
  AND    ktrx.tsu_code = 'ENTERED'
  AND    ktrx.rbr_code is NOT NULL
  AND    ktrx.tcn_type = 'TRBK'
  AND    chr.id = p_chr_id
  AND    cpy_chr.orig_system_id1 = chr.id
  AND    cpy_chr.orig_system_source_code = 'OKL_REBOOK'
  AND    ktrx.representation_type = 'SECONDARY';
  */
  --Get the mass rebook transaction in Entered status for primary representation
  CURSOR chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
  SELECT '!', ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx
  WHERE  chr.id          = p_chr_id
  AND    ktrx.khr_id     =  chr.id
  AND    ktrx.tsu_code   = 'ENTERED'
  AND    ktrx.rbr_code   IS NOT NULL --sechawla : added comment: identifies the actual online rebook process transaction.
                                     --           This transaction is created only for primary rep.
                                     --           ID of this transaction (ktrx.id) is stamped on both primary and reporting streams
  AND    ktrx.tcn_type   = 'TRBK'
  AND    ktrx.representation_type = 'PRIMARY'  -- MGAAP 7263041
  AND    EXISTS (SELECT '1'
                 FROM   okl_rbk_selected_contract rbk_khr
                 WHERE  rbk_khr.khr_id = chr.id
                 AND    rbk_khr.status <> 'PROCESSED');

/*
  --sechawla 12-mar-09 MG Impact on Rebook
  --get the Mass Rebook transaction in Entered status for secondary representation
  CURSOR chk_mass_rbk_secondary_csr (p_chr_id IN NUMBER) IS
  SELECT '!', ktrx.id
  FROM   okc_k_headers_b chr,
         okl_trx_contracts ktrx
  WHERE  chr.id          = p_chr_id
  AND    ktrx.khr_id     =  chr.id
  AND    ktrx.tsu_code   = 'ENTERED'
  AND    ktrx.rbr_code   IS NOT NULL
  AND    ktrx.tcn_type   = 'TRBK'
  AND    ktrx.representation_type = 'SECONDARY'
  AND    EXISTS (SELECT '1'
                 FROM   okl_rbk_selected_contract rbk_khr
                 WHERE  rbk_khr.khr_id = chr.id
                 AND    rbk_khr.status <> 'PROCESSED');
  */

  --sechawla 12-mar-09 MG Impact on Rebook
  -- Modified to pick only primary streams
  CURSOR curr_streams_csr(p_khr_id IN NUMBER) IS
  SELECT new_stm.id  new_stm_id,
         new_stm.kle_id
  FROM   okl_streams new_stm,
         okl_strm_type_b sty
  WHERE  new_stm.khr_id   = p_khr_id
  AND    new_stm.say_code = 'WORK'
  AND    new_stm.sty_id   = sty.id
  AND    nvl(new_stm.purpose_code,'XXX') <> 'REPORT' ----sechawla 12-mar-09 Added
  AND    sty.stream_type_purpose IN
         ('INVESTOR_RENTAL_ACCRUAL',
          'INVESTOR_PRETAX_INCOME',
          'INVESTOR_INTEREST_INCOME',  --> these are generated for primary product but not for reporting
          'INVESTOR_VARIABLE_INTEREST');  --> these are generated for primary product but not for reporting

  --sechawla 12-mar-09 MG Impact on Rebook
  --get the new reporting streams created during rebook
  CURSOR curr_streams_secondary_csr(p_khr_id IN NUMBER) IS
  SELECT new_stm.id  new_stm_id,
         new_stm.kle_id
  FROM   okl_streams new_stm,
         okl_strm_type_b sty
  WHERE  new_stm.khr_id   = p_khr_id
  AND    new_stm.say_code = 'WORK'
  AND    new_stm.sty_id   = sty.id
  AND    new_stm.purpose_code = 'REPORT'
  AND    sty.stream_type_purpose IN
         ('INVESTOR_RENTAL_ACCRUAL',
          'INVESTOR_PRETAX_INCOME'); --Reporting streams are not generated for INVESTOR_INTEREST_INCOME,INVESTOR_VARIABLE_INTEREST

  --sechawla 12-mar-09 MG Impact on Rebook
  -- Modified to pick only primary streams
  CURSOR hist_strms_csr(p_new_stm_id IN NUMBER,
                        p_khr_id     IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id
  FROM   okl_streams new_stm,
         okl_streams orig_stm
  WHERE  new_stm.id = p_new_stm_id
  AND    orig_stm.khr_id = new_stm.khr_id
  AND    NVL(orig_stm.kle_id,-1) = NVL(new_stm.kle_id,-1)
  AND    orig_stm.sty_id = new_stm.sty_id
  AND    NVL(orig_stm.purpose_code,'ORIG') = NVL(new_stm.purpose_code,'ORIG')
  AND    nvl(orig_stm.purpose_code,'XXX') <> 'REPORT' ----sechawla 12-mar-09 Added
  AND    orig_stm.say_code = 'CURR';

  --sechawla 12-mar-09 MG Impact on Rebook
  --get the old reporting streams on the contract
  CURSOR hist_strms_secondary_csr(p_new_stm_id IN NUMBER,
                        p_khr_id     IN NUMBER) IS
  SELECT orig_stm.id  orig_stm_id
  FROM   okl_streams new_stm,
         okl_streams orig_stm
  WHERE  new_stm.id = p_new_stm_id
  AND    orig_stm.khr_id = new_stm.khr_id
  AND    NVL(orig_stm.kle_id,-1) = NVL(new_stm.kle_id,-1)
  AND    orig_stm.sty_id = new_stm.sty_id
-- AND    NVL(orig_stm.purpose_code,'ORIG') = NVL(new_stm.purpose_code,'ORIG')
  AND    orig_stm.purpose_code = 'REPORT'
  AND    orig_stm.say_code = 'CURR';

  hist_strms_rec hist_strms_csr%ROWTYPE;

  l_rbk_khr           VARCHAR2(1);
  l_mass_rbk_khr      VARCHAR2(1);
  l_mass_rbk_trx_id   NUMBER;
  l_online_rbk_trx_id NUMBER;

  l_new_strm_tbl stmv_tbl_type;
  x_new_strm_tbl stmv_tbl_type;

  l_new_strm_count NUMBER := 0;

  --sechawla 12-mar-09 MG Impact on Rebook
  hist_strms_sec_rec  hist_strms_csr%ROWTYPE;

  l_rbk_sec_khr           VARCHAR2(1);
  l_mass_rbk_sec_khr      VARCHAR2(1);
  l_mass_rbk_sec_trx_id   NUMBER;
  l_online_rbk_sec_trx_id NUMBER;

  l_new_strm_sec_tbl stmv_tbl_type;
  x_new_strm_sec_tbl stmv_tbl_type;

  l_new_strm_sec_count NUMBER := 0;

  --Bug# 6344223
  --Cursor to check whether split asset transaction is in progress for the contract
  CURSOR check_split_trx_csr IS
  SELECT tas.id
  FROM OKL_TXL_ASSETS_B txl, OKL_TRX_ASSETS tas
  WHERE txl.tal_type= 'ALI'
  AND txl.dnz_khr_id = p_khr_id
  AND txl.tas_id = tas.id
  AND tas.tas_type = 'ALI'
  AND tas.tsu_code = 'ENTERED';

  l_split_trans_id    OKL_TRX_ASSETS.ID%TYPE;
  --end Bug# 6344223

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 6344223
      OPEN check_split_trx_csr;
      FETCH check_split_trx_csr INTO l_split_trans_id;
      CLOSE check_split_trx_csr;
      --end Bug# 6344223

      --check for mass rebook contract - primary rep
      l_mass_rbk_khr := '?';
      l_mass_rbk_trx_id := null;
      OPEN chk_mass_rbk_csr (p_chr_id => p_khr_id);
      FETCH chk_mass_rbk_csr INTO l_mass_rbk_khr,l_mass_rbk_trx_id;
      CLOSE chk_mass_rbk_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_khr: '||l_mass_rbk_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_trx_id: '||l_mass_rbk_trx_id);
      END IF;

/*
      --sechawla 12-mar-09 MG Impact on Rebook
      --check for mass rebook contract - secondary rep
      l_mass_rbk_sec_khr := '?';
      l_mass_rbk_sec_trx_id := null;
      OPEN chk_mass_rbk_secondary_csr (p_chr_id => p_khr_id);
      FETCH chk_mass_rbk_secondary_csr INTO l_mass_rbk_sec_khr,l_mass_rbk_sec_trx_id;
      CLOSE chk_mass_rbk_secondary_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_sec_khr: '||l_mass_rbk_sec_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_mass_rbk_sec_trx_id: '||l_mass_rbk_sec_trx_id);
      END IF;
  */

      --check for rebook contract - primary rep
      l_rbk_khr := '?';
      l_online_rbk_trx_id := null;
      OPEN chk_rbk_csr (p_chr_id => p_khr_id);
      FETCH chk_rbk_csr INTO l_rbk_khr,l_online_rbk_trx_id;
      CLOSE chk_rbk_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rbk_khr: '||l_rbk_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_online_rbk_trx_id: '||l_online_rbk_trx_id);
      END IF;

/*      --sechawla 12-mar-09 MG Impact on Rebook
      --check for rebook contract - secondary rep
      l_rbk_sec_khr := '?';
      l_online_rbk_sec_trx_id := null;
      OPEN chk_rbk_secondary_csr (p_chr_id => p_khr_id);
      FETCH chk_rbk_secondary_csr INTO l_rbk_sec_khr,l_online_rbk_sec_trx_id;
      CLOSE chk_rbk_secondary_csr;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rbk_khr: '||l_rbk_sec_khr);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_online_rbk_trx_id: '||l_online_rbk_sec_trx_id);
      END IF;
  */
      --sechawla
      --Update trx_id, link_hist_stream_id on the (new) primary Investor streams created during rebook
      --trx_id --> ID of source primary transaction that initaied rebook - online rebook, mass rebook, split asset
      --link_hist_stream_id --> ID of corresponding old stream that existed prior to this rebook
      --Added condition l_split_trans_id IS NOT NULL for Bug# 6344223
      IF ((l_split_trans_id IS NOT NULL) OR l_mass_rbk_khr = '!' OR  l_rbk_khr = '!') THEN

        l_new_strm_tbl.DELETE;
        l_new_strm_count := 0;

        --Loop around the WORK streams created during rebook
        FOR curr_streams_rec IN curr_streams_csr(p_khr_id => p_khr_id)
        LOOP

          l_new_strm_count := l_new_strm_count + 1;
          l_new_strm_tbl(l_new_strm_count).id  := curr_streams_rec.new_stm_id;

          IF l_mass_rbk_khr = '!' THEN
            l_new_strm_tbl(l_new_strm_count).trx_id  := l_mass_rbk_trx_id;
          --Bug# 6344223
          ELSIF l_split_trans_id IS NOT NULL THEN
            l_new_strm_tbl(l_new_strm_count).trx_id  := l_split_trans_id;
          ELSIF l_rbk_khr = '!' THEN
            l_new_strm_tbl(l_new_strm_count).trx_id  := l_online_rbk_trx_id;
          END IF;

          hist_strms_rec.orig_stm_id := NULL;
          -- Get the Old stream ID based upon new Stream ID (curr_streams_rec.new_stm_id)
          OPEN hist_strms_csr(p_new_stm_id => curr_streams_rec.new_stm_id,
                              p_khr_id     => p_khr_id);
          FETCH hist_strms_csr INTO hist_strms_rec;
          CLOSE hist_strms_csr;

          IF hist_strms_rec.orig_stm_id IS NOT NULL THEN
              -- Update link_hist_stream_id field on new streams with stream ID of old stream
              l_new_strm_tbl(l_new_strm_count).link_hist_stream_id := hist_strms_rec.orig_stm_id;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream ID: '||l_new_strm_tbl(l_new_strm_count).id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream ID: '||l_new_strm_tbl(l_new_strm_count).link_hist_stream_id);
          END IF;

        END LOOP;

        IF (l_new_strm_tbl.COUNT > 0) THEN

          -- Call Streams api to update Link_Hist_Stream_Id and Trx_Id
          okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_tbl       => l_new_strm_tbl,
                                      x_stmv_tbl       => x_new_strm_tbl
                                     );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of New Strms - Trx ID and Hist ID '||x_return_status);
          END IF;

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        --sechawla
        --Update trx_id, link_hist_stream_id on the (new) Reporting Investor streams created during rebook
        --trx_id --> ID of source transaction that initaied rebook - online rebook, mass rebook, split asset
        --Same trx_id is stamped on both primary and reporting streams
        --link_hist_stream_id --> ID of corresponding old stream that existed prior to this rebook
        l_new_strm_sec_tbl.DELETE;
        l_new_strm_sec_count := 0;

        --Loop around the WORK streams created during rebook
        FOR curr_streams_secondary_rec IN curr_streams_secondary_csr(p_khr_id => p_khr_id)
        LOOP

          l_new_strm_sec_count := l_new_strm_sec_count + 1;
          l_new_strm_sec_tbl(l_new_strm_sec_count).id  := curr_streams_secondary_rec.new_stm_id;

          IF l_mass_rbk_khr = '!' THEN
            l_new_strm_sec_tbl(l_new_strm_sec_count).trx_id  := l_mass_rbk_trx_id;
          --Bug# 6344223
          ELSIF l_split_trans_id IS NOT NULL THEN
            l_new_strm_sec_tbl(l_new_strm_sec_count).trx_id  := l_split_trans_id;
          ELSIF l_rbk_khr = '!' THEN
            l_new_strm_sec_tbl(l_new_strm_sec_count).trx_id  := l_online_rbk_trx_id;
          END IF;

          hist_strms_sec_rec.orig_stm_id := NULL;
          -- Get the Old stream ID based upon new Stream ID (curr_streams_rec.new_stm_id)
          OPEN hist_strms_secondary_csr(p_new_stm_id => curr_streams_secondary_rec.new_stm_id,
                              p_khr_id     => p_khr_id);
          FETCH hist_strms_secondary_csr INTO hist_strms_sec_rec;
          CLOSE hist_strms_secondary_csr;

          IF hist_strms_sec_rec.orig_stm_id IS NOT NULL THEN
              -- Update link_hist_stream_id field on new streams with stream ID of old stream
              l_new_strm_sec_tbl(l_new_strm_sec_count).link_hist_stream_id := hist_strms_sec_rec.orig_stm_id;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream ID: '||l_new_strm_tbl(l_new_strm_count).id);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream ID: '||l_new_strm_tbl(l_new_strm_count).link_hist_stream_id);
          END IF;

        END LOOP;

        IF (l_new_strm_sec_tbl.COUNT > 0) THEN

          -- Call Streams api to update Link_Hist_Stream_Id and Trx_Id
          okl_streams_pub.update_streams(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_stmv_tbl       => l_new_strm_sec_tbl,
                                      x_stmv_tbl       => x_new_strm_sec_tbl
                                     );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of New Strms - Trx ID and Hist ID '||x_return_status);
          END IF;

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;


      END IF;


      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END link_inv_accrual_streams;

    ------------------------------------------------------------------------------
-- PROCEDURE calc_inv_acc_adjustment
--
--  This procedure calculates the accrual adjustment for Investor accrual streams
--  where there is a difference between amount actually accrued and amount
--  that should have been accrued and calls the Accrual api to make the
--  accrual adjustment. The current streams taken into account for
--  calculating accrual adjustment are then marked as Accrual adjusted in order
--  to stop duplicate accrual.
--
-- Calls:
-- Called By:
-- Added new input parameters p_trx_tbl_code and p_trx_type for Bug# 6344223
------------------------------------------------------------------------------
  PROCEDURE calc_inv_acc_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE,
                         x_inv_accrual_rec OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type,
                         x_inv_stream_tbl  OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type,
                         p_trx_tbl_code    IN  VARCHAR2 DEFAULT 'TCN',
                         p_trx_type        IN  VARCHAR2 DEFAULT 'CRB',
                         p_product_id      IN  NUMBER   DEFAULT  NULL -- MGAAP
                         ) IS

  l_api_name             VARCHAR2(35)    := 'calc_inv_acc_adjustment';
  l_proc_name            VARCHAR2(35)    := 'CALC_INV_ACC_ADJUSTMENT';
  l_api_version          CONSTANT NUMBER := 1;

  CURSOR curr_accrual_streams_csr(p_khr_id  IN NUMBER) IS
  SELECT new_stm.id   new_stm_id,
         orig_stm.id  orig_stm_id,
         orig_stm.sty_id,
         orig_stm.kle_id,
         sty.name
  --FROM   okl_streams new_stm,
  FROM   okl_streams_rep_v new_stm,  -- MGAAP 7263041
         okl_prod_strm_types psty,
         okl_k_headers khr,
         --okl_streams orig_stm,
         okl_streams_rep_v orig_stm,  -- MGAAP 7263041
         okl_strm_type_v sty
  WHERE  khr.id = p_khr_id
  --AND    psty.pdt_id = khr.pdt_id
  AND    psty.pdt_id = NVL(p_product_id, khr.pdt_id) -- MGAAP 7263041
  AND    psty.accrual_yn = 'Y'
  AND    psty.sty_id = new_stm.sty_id
  AND    new_stm.khr_id = khr.id
  AND    new_stm.say_code = 'CURR'
  AND    orig_stm.id = new_stm.link_hist_stream_id
  AND    sty.id = orig_stm.sty_id
  AND    sty.stream_type_purpose IN
         ('INVESTOR_RENTAL_ACCRUAL',
          'INVESTOR_PRETAX_INCOME',
          'INVESTOR_INTEREST_INCOME',
          'INVESTOR_VARIABLE_INTEREST');

  CURSOR max_accrual_date_csr(p_stm_id IN NUMBER) IS
  SELECT MAX(sel.stream_element_date) stream_element_date
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR actual_amount_accrued_csr(p_stm_id IN NUMBER) IS
  SELECT NVL(SUM(sel.amount),0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.accrued_yn IS NOT NULL;

  CURSOR amount_to_be_accrued_csr(p_stm_id IN NUMBER,
                                  p_max_accrual_date IN DATE) IS
  SELECT sel.id sel_id,
         NVL(sel.amount,0) amount
  FROM okl_strm_elements sel
  WHERE sel.stm_id = p_stm_id
  AND   sel.stream_element_date <= p_max_accrual_date;

  l_max_accrual_date DATE;
  l_actual_amount_accrued NUMBER;
  l_amount_to_be_accrued NUMBER;
  l_accrual_adjustment NUMBER;

  l_selv_tbl    selv_tbl_type;
  x_selv_tbl    selv_tbl_type;

  l_selv_count  NUMBER;

  i             NUMBER;

  l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  l_gl_date     DATE;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- For On-line and Mass rebook, calculate accrual adjustment
      -- for all Current Accrual Streams for which Accruals were generated
      -- in the Original contract

      i := 0;
      l_stream_tbl.DELETE;
      FOR curr_accrual_streams_rec IN curr_accrual_streams_csr(p_khr_id => p_orig_khr_id)
      LOOP

        l_max_accrual_date := NULL;
        OPEN max_accrual_date_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
        FETCH max_accrual_date_csr INTO l_max_accrual_date;
        CLOSE max_accrual_date_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Stream Id: '||curr_accrual_streams_rec.new_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Orig Stream Id: '||curr_accrual_streams_rec.orig_stm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Max Accrual Date: '||l_max_accrual_date);
        END IF;

        IF l_max_accrual_date IS NOT NULL THEN

          l_actual_amount_accrued := 0;
          OPEN actual_amount_accrued_csr(p_stm_id => curr_accrual_streams_rec.orig_stm_id);
          FETCH actual_amount_accrued_csr INTO l_actual_amount_accrued;
          CLOSE actual_amount_accrued_csr;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Actual Amount Accrued: '||l_actual_amount_accrued);
          END IF;

          l_amount_to_be_accrued := 0;
          l_selv_count := 0;
          l_selv_tbl.DELETE;

          FOR amount_to_be_accrued_rec IN
              amount_to_be_accrued_csr(p_stm_id => curr_accrual_streams_rec.new_stm_id,
                                      p_max_accrual_date => l_max_accrual_date)
          LOOP

            -- Call Streams api to update accrued_yn, accrual_adj_flag
            l_selv_count := l_selv_count + 1;
            l_amount_to_be_accrued := l_amount_to_be_accrued + amount_to_be_accrued_rec.amount;

            l_selv_tbl(l_selv_count).id        := amount_to_be_accrued_rec.sel_id;
            l_selv_tbl(l_selv_count).accrued_yn := 'Y';
            l_selv_tbl(l_selv_count).accrual_adj_flag  := 'Y';

          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount to be Accrued: '||l_amount_to_be_accrued);
          END IF;

          l_accrual_adjustment := l_amount_to_be_accrued -  l_actual_amount_accrued;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment: '||l_accrual_adjustment);
          END IF;

          IF l_accrual_adjustment <> 0 THEN
            i := i + 1;
            l_stream_tbl(i).stream_type_id   := curr_accrual_streams_rec.sty_id;
            l_stream_tbl(i).stream_type_name := curr_accrual_streams_rec.name;
            l_stream_tbl(i).stream_amount    := l_accrual_adjustment;
            l_stream_tbl(i).kle_id           := curr_accrual_streams_rec.kle_id;

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment Record');
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i '||i);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_id: '||l_stream_tbl(i).stream_type_id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_type_name: '||l_stream_tbl(i).stream_type_name);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).stream_amount: '||l_stream_tbl(i).stream_amount);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tbl(i).kle_id: '||l_stream_tbl(i).kle_id);
            END IF;
          END IF;

          IF (l_selv_tbl.COUNT > 0) THEN
            okl_streams_pub.update_stream_elements(
                                      p_api_version    => 1.0,
                                      p_init_msg_list  => OKL_API.G_FALSE,
                                      x_return_status  => x_return_status,
                                      x_msg_count      => x_msg_count,
                                      x_msg_data       => x_msg_data,
                                      p_selv_tbl       => l_selv_tbl,
                                      x_selv_tbl       => x_selv_tbl
                                     );

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update of Stream Elements - Accrued Yn and Accrual Adj Flag '||x_return_status);
            END IF;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;
      END LOOP;

      IF (l_stream_tbl.COUNT > 0) THEN

        l_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(p_gl_date => p_trx_date);

        l_accrual_rec.contract_id   := p_orig_khr_id;
        l_accrual_rec.accrual_date  := l_gl_date;
        l_accrual_rec.source_trx_id := p_trx_id;

        --Bug# 6344223
        l_accrual_rec.source_trx_type := p_trx_tbl_code;
        IF p_trx_type = 'CRB' THEN
          l_accrual_rec.description   := 'Rebook Adjustment';
        ELSIF p_trx_type = 'ALI' THEN
          l_accrual_rec.description   := 'Split Asset Adjustment';
        END IF;
        --end Bug# 6344223

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Accrual Adjustment Header Record');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.contract_id: '||l_accrual_rec.contract_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.accrual_date: '||l_accrual_rec.accrual_date);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.description: '||l_accrual_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.source_trx_id: '||l_accrual_rec.source_trx_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_accrual_rec.source_trx_type: '||l_accrual_rec.source_trx_type);
        END IF;


          x_inv_stream_tbl := l_stream_tbl;
          x_inv_accrual_rec := l_accrual_rec;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);
  END calc_inv_acc_adjustment;
-- Bug# 4775555: End

END OKL_CONTRACT_REBOOK_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKL_CS_PRINCIPAL_PAYDOWN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_PRINCIPAL_PAYDOWN_PVT" AS
/* $Header: OKLRPPDB.pls 120.39.12010000.3 2009/08/05 13:00:57 rpillay ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'NO_PARENT_RECORD';
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'REQUIRED_VALUE';

------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

-----------------------------------------------------------------------------------
 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_CS_PRINCIPAL_PAYDOWN';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNSCHED_PP_STREAM           CONSTANT  VARCHAR2(60)   := 'UNSCHEDULED_PRINCIPAL_PAYMENT';
  G_UNSCHED_LP_STREAM           CONSTANT  VARCHAR2(60)   := 'UNSCHEDULED_LOAN_PAYMENT';
  G_RENT_STREAM		        CONSTANT  VARCHAR2(60)   := 'RENT';
  G_PRINCIPAL_PAYMENT           CONSTANT  VARCHAR2(60)   := 'PRINCIPAL_PAYMENT';

   subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
   subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  TYPE kle_rec_type IS RECORD (
    ID          OKL_K_LINES_V.ID%TYPE
  );

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER;
 SUBTYPE selv_tbl_type IS Okl_Streams_Pvt.selv_tbl_type;




PROCEDURE PRINT_MESSAGES(l_payment_struc IN okl_mass_rebook_pvt.strm_lalevl_tbl_type)
IS
  i Number;
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  i := 0;
 IF l_payment_struc.COUNT > 0 THEN
    i := l_payment_struc.FIRST;
     LOOP
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Starting the Loop ....');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).chr_id ' || i ||' - '||l_payment_struc(i).chr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).cle_id ' || i ||' - '||l_payment_struc(i).cle_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION_CATEGORY ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION_CATEGORY);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION2 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION2);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION3 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION3);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION5 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION5);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION6 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION6);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION7 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION7);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION8 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION8);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION10 ' || i ||' - '|| l_payment_struc(i).RULE_INFORMATION10);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).OBJECT1_ID1 ' || i ||' - '|| l_payment_struc(i).OBJECT1_ID1);
        END IF;
        EXIT WHEN i = l_payment_struc.LAST;
        i := l_payment_struc.NEXT(i);
     END LOOP;
  END IF;

END PRINT_MESSAGES;

PROCEDURE PRINT_STM_PAYMENTS(p_payment_tbl IN payment_tbl_type)
IS
 i NUMBER;
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
 i := 0;
 IF p_payment_tbl.COUNT > 0 THEN
    i := p_payment_tbl.FIRST;
    LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).KHR_ID       :'||i||' -'|| p_payment_tbl(i).KHR_ID);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).KLE_ID       :'||i||' -'|| p_payment_tbl(i).KLE_ID);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).STY_ID       :'||i||' -'|| p_payment_tbl(i).STY_ID);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).start_date   :'||i||' -'|| p_payment_tbl(i).start_date);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).structure    :'||i||' -'|| p_payment_tbl(i).structure);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).arrears_yn   :'||i||' -'|| p_payment_tbl(i).arrears_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).periods      :'||i||' -'|| p_payment_tbl(i).periods);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).frequency    :'||i||' -'|| p_payment_tbl(i).frequency);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).amount       :'||i||' -'|| p_payment_tbl(i).amount);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).stub_days    :'||i||' -'|| p_payment_tbl(i).stub_days);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).stub_amount  :'||i||' -'|| p_payment_tbl(i).stub_amount);
      END IF;
      EXIT WHEN i = p_payment_tbl.LAST;
      i := p_payment_tbl.NEXT(i);
    END LOOP;
 END IF;
END PRINT_STM_PAYMENTS;

PROCEDURE PRINT_ISG_PARAMS(p_payment_tbl IN okl_pricing_pvt.payment_tbl_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

FOR i in p_payment_tbl.FIRST..p_payment_tbl.LAST LOOP
IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).start_date   :'||i||' -'|| p_payment_tbl(i).start_date);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).structure    :'||i||' -'|| p_payment_tbl(i).structure);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).arrears_yn   :'||i||' -'|| p_payment_tbl(i).arrears_yn);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).periods      :'||i||' -'|| p_payment_tbl(i).periods);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).frequency    :'||i||' -'|| p_payment_tbl(i).frequency);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).amount       :'||i||' -'|| p_payment_tbl(i).amount);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).stub_days    :'||i||' -'|| p_payment_tbl(i).stub_days);
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'    p_payment_tbl(i).stub_amount  :'||i||' -'|| p_payment_tbl(i).stub_amount);
END IF;
END LOOP;
END PRINT_ISG_PARAMS;

--added by rkuttiya for 11i OKL.H

Function re_organize_payment_tbl(p_payment_tbl IN OKL_CS_PRINCIPAL_PAYDOWN_PVT.payment_tbl_type)
 RETURN OKL_CS_PRINCIPAL_PAYDOWN_PVT.payment_tbl_type IS
  i             number;
  j             number;
  l_payment_tbl OKL_CS_PRINCIPAL_PAYDOWN_PVT.payment_tbl_type;
  l_rec_found   varchar2(1);
 BEGIN
  i := 0;
  IF p_payment_tbl.COUNT > 0 THEN
    i := p_payment_tbl.FIRST;

    -- First record of the input table is blindly copied to the local table.
    l_payment_tbl(i).KHR_ID        := p_payment_tbl(i).KHR_ID;
    l_payment_tbl(i).KLE_ID        := p_payment_tbl(i).KLE_ID;
    l_payment_tbl(i).STY_ID        := p_payment_tbl(i).STY_ID;
    l_payment_tbl(i).start_date    := p_payment_tbl(i).start_date;
    l_payment_tbl(i).structure     := p_payment_tbl(i).structure;
    l_payment_tbl(i).arrears_yn    := p_payment_tbl(i).arrears_yn;
    l_payment_tbl(i).periods       := p_payment_tbl(i).periods;
    l_payment_tbl(i).frequency     := p_payment_tbl(i).frequency;
    l_payment_tbl(i).amount        := p_payment_tbl(i).amount;
    l_payment_tbl(i).stub_days     := p_payment_tbl(i).stub_days;
    l_payment_tbl(i).stub_amount   := p_payment_tbl(i).stub_amount;

    LOOP
      EXIT WHEN i = p_payment_tbl.LAST;
      i := p_payment_tbl.NEXT(i);
      -- 2nd or greater record from the input table will be processed here

      l_rec_found := 'N';
      j := 0;
      j := l_payment_tbl.FIRST;
      LOOP
        IF (l_payment_tbl(j).kle_id = p_payment_tbl(i).KLE_ID
           and l_payment_tbl(j).frequency = p_payment_tbl(i).frequency
           and l_payment_tbl(j).amount  = p_payment_tbl(i).amount) THEN
          --Bug#4964710 changed start_date derivation, removed  + 1 --dkagrawa
          l_payment_tbl(j).start_date    := (least(p_payment_tbl(i).start_date,l_payment_tbl(j).start_date) );
          l_payment_tbl(j).periods       := l_payment_tbl(j).periods + p_payment_tbl(i).periods;
          l_rec_found := 'Y';
          EXIT;
        END IF;
        EXIT WHEN j = l_payment_tbl.LAST;
        j := l_payment_tbl.NEXT(j);
      END LOOP;

      IF l_rec_found = 'N' THEN
        l_payment_tbl(i).KHR_ID        := p_payment_tbl(i).KHR_ID;
        l_payment_tbl(i).KLE_ID        := p_payment_tbl(i).KLE_ID;
        l_payment_tbl(i).STY_ID        := p_payment_tbl(i).STY_ID;
        l_payment_tbl(i).start_date    := p_payment_tbl(i).start_date;
        l_payment_tbl(i).structure     := p_payment_tbl(i).structure;
        l_payment_tbl(i).arrears_yn    := p_payment_tbl(i).arrears_yn;
        l_payment_tbl(i).periods       := p_payment_tbl(i).periods;
        l_payment_tbl(i).frequency     := p_payment_tbl(i).frequency;
        l_payment_tbl(i).amount        := p_payment_tbl(i).amount;
        l_payment_tbl(i).stub_days     := p_payment_tbl(i).stub_days;
        l_payment_tbl(i).stub_amount   := p_payment_tbl(i).stub_amount;
      END IF;

    END LOOP;
  END IF;

  RETURN l_payment_tbl;
END;


  FUNCTION get_status
   (p_request_id	IN	NUMBER)
   RETURN VARCHAR2

  AS

    CURSOR c_cs_status_csr (a_id IN NUMBER)
	IS
    SELECT request_status_code,
	   object1_id1,
	   jtot_object1_code
    FROM okl_trx_requests
    where id=a_id;

    CURSOR c_supertrump_csr (a_id IN NUMBER)
	IS
    SELECT sis_code
    FROM   okl_stream_interfaces
    WHERE  ID=a_id;

	l_status_code	VARCHAR2(80);
	l_object1_id1	VARCHAR2(40);
	l_object1_code	VARCHAR2(30);
	l_sis_code	VARCHAR2(80);

  BEGIN

	OPEN c_cs_Status_csr(p_request_id);
	FETCH c_cs_Status_csr INTO l_status_code,l_object1_id1,l_object1_code;
	CLOSE c_cs_Status_csr;

	IF l_status_code='SUBMITTED_CALCULATION' THEN
		--Still not processed, Check for the status in Streams table.
		IF l_object1_code = 'OKL_STREAM_INTERFACES' THEN
			open c_supertrump_csr(l_object1_id1);
			FETCH c_supertrump_csr INTO l_sis_code;
			CLOSE c_supertrump_csr;
		END IF;
		l_status_code :=l_sis_code;
	END IF;
	RETURN l_status_code;

  END get_status;




------------------------------------------------------------------
--Functions to Fetch Data from Tables.
-----------------------------------------------------------------
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

  FUNCTION get_factor_synd(p_khr_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR c_synd IS
        SELECT
          'SYNDICATION'
        FROM
          okc_k_headers_b chr
        WHERE
          EXISTS ( SELECT 'x' FROM okc_k_items cim
                        WHERE  cim.object1_id1 = to_char(chr.id) AND
          EXISTS ( SELECT 'x' FROM okc_k_lines_b cle, okc_line_styles_b  lse
                        WHERE  cle.lse_id = lse.id AND
          lse.lty_code = 'SHARED' AND cle.id = cim.cle_id ) AND
          EXISTS ( SELECT 'x' FROM okc_k_headers_b chr2
                        WHERE  chr2.id = cim.dnz_chr_id AND
          chr2.scs_code = 'SYNDICATION'                     AND
          chr2.sts_code not in  ('TERMINATED','ABANDONED') ) ) AND
          chr.scs_code = 'LEASE' AND
          id = p_khr_id;

    CURSOR c_fact IS
        select '1'
        from   okc_rules_b
        where  dnz_chr_id  = p_khr_id
        and    rule_information_category = 'LAFCTG'
        and    (rule_information1 is not null
        or      rule_information2 is not null
        or      rule_information3 is not null);
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

 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
		p_commit		IN	VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER)
  AS
        l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_WORKING_COPY';
	l_seq_no	    NUMBER;
	l_orig_contract_number OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
	l_new_contract_number  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
	l_khrv_rec             khrv_rec_type;
	x_khrv_rec             khrv_rec_type;
	l_chrv_rec             chrv_rec_type;
	x_chrv_rec             chrv_rec_type;



  CURSOR orig_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT contract_number
  FROM   okc_k_headers_v
  WHERE  id = p_chr_id;


   BEGIN

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	--Create the working copy here....

      -- Get Sequence Number to generate Contract Number
      SELECT okl_rbk_seq.nextval
      INTO   l_seq_no
      FROM   DUAL;

      -- Get Contract Number from Original Contract
      OPEN orig_csr(p_chr_id);
      FETCH orig_csr INTO l_orig_contract_number;

      IF orig_csr%NOTFOUND THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      CLOSE orig_csr;
      l_new_contract_number :=  l_orig_contract_number||'-PPD'||l_seq_no;

      okl_copy_contract_pub.copy_lease_contract(
                                                 p_api_version              => 1.0,
                                                 p_init_msg_list            => OKC_API.G_FALSE,
                                                 x_return_status            => x_return_status,
                                                 x_msg_count                => x_msg_count,
                                                 x_msg_data                 => x_msg_data,
                                                 p_chr_id                   => p_chr_id,
                                                 p_contract_number          => l_new_contract_number,
                                                 p_contract_number_modifier => NULL,
                                                 p_renew_ref_yn             => 'N',
                                                 p_trans_type               => 'CRB',
                                                 x_chr_id                   => x_chr_id
                                                );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --
      -- Update Rebook Contract Status to 'ABANDONED'
      --
      l_khrv_rec.id                      := x_chr_id;
      l_chrv_rec.id                      := x_chr_id;
      l_chrv_rec.sts_code                := 'ABANDONED';

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


      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);
if p_commit= OKC_API.G_TRUE then
	commit;
end if;

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                          p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => '_PVT');

  END create_working_copy;

-----------------------------------------------------------------
--API to update the HDR info about the Start date, term and End date for the working copy...
----------------------------------------------------------------

 PROCEDURE update_hdr_info(
			       x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               p_working_copy_chr_id 	IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_start_date     IN  OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
                               p_end_date       IN  OKL_K_HEADERS_FULL_V.END_DATE%TYPE,
                               p_term_duration  IN  OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE
                              )
 IS

  l_khrv_rec    khrv_rec_type;
  l_chrv_rec    chrv_rec_type;
  x_khrv_rec    khrv_rec_type;
  x_chrv_rec    chrv_rec_type;

  update_failed		EXCEPTION;
 BEGIN
	x_return_status := OKC_API.G_RET_STS_SUCCESS;
     l_khrv_rec := get_khrv_rec(
                                p_khr_id        => p_working_copy_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE update_failed;
     END IF;

     l_chrv_rec := get_chrv_rec(
                                p_chr_id        => p_working_copy_chr_id,
                                x_return_status => x_return_status
                               );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE update_failed;
     END IF;


	l_khrv_rec.term_duration := p_term_duration;

        l_chrv_rec.start_date    := p_start_date;
        l_chrv_rec.end_date      := p_end_date;

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
            RAISE update_failed;
        END IF;

     --END LOOP;

     --RETURN;

  EXCEPTION
    WHEN update_failed THEN
       x_return_status := OKC_API.G_RET_STS_ERROR;
  END update_hdr_info;

--
/*
  PROCEDURE get_principal_balance(
		p_khr_id		IN	NUMBER
		,x_principal_balance OUT NOCOPY NUMBER)
  IS

       CURSOR c_payments_made(c_khr_id	NUMBER)
	IS
	SELECT count(sele.amount)
	FROM okl_strm_elements sele,
       	    okl_streams str,
       	    okl_strm_type_v sty
	WHERE sele.stm_id = str.id
       	    AND str.sty_id = sty.id
       	    AND UPPER(sty.name) = 'PRINCIPAL PAYMENT'
            AND str.say_code = 'CURR'
           --multigaap changes
           AND str.ACTIVE_YN = 'Y'
           AND str.PURPOSE_CODE is NULL
           --end multigaap changes
       	    AND str.khr_id = c_khr_id
       	    and sele.DATE_BILLED is not null;

	CURSOR c_initial_principal(c_khr_id NUMBER)
	 IS
	  SELECT sum(sele.amount)
	  FROM okl_strm_elements sele,
		okl_streams str,
		okl_strm_type_v sty
	WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.name) = 'PRINCIPAL BALANCE'
           AND str.say_code = 'CURR'
           --multigaap changes
           AND str.ACTIVE_YN = 'Y'
           AND str.PURPOSE_CODE is NULL
           --end multigaap changes
           AND str.khr_id = c_khr_id
           and sele.stream_element_date = (select min(sele.stream_element_date)
    					FROM okl_strm_elements sele,
						okl_streams str,
						okl_strm_type_v sty
					WHERE sele.stm_id = str.id
					AND str.sty_id = sty.id
					AND UPPER(sty.name) = 'PRINCIPAL PAYMENT'
					AND str.say_code = 'CURR'
				        --multigaap changes
				        AND str.ACTIVE_YN = 'Y'
				        AND str.PURPOSE_CODE is NULL
				        --end multigaap changes
					AND str.khr_id = c_khr_id
					AND sele.DATE_BILLED is null);

	CURSOR c_current_principal(c_khr_id NUMBER)
	 IS
	  SELECT sum(sele.amount)
	  FROM okl_strm_elements sele,
		okl_streams str,
		okl_strm_type_v sty
	WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.name) = 'PRINCIPAL BALANCE'
           AND str.say_code = 'CURR'
           --multigaap changes
           AND str.ACTIVE_YN = 'Y'
           AND str.PURPOSE_CODE is NULL
           --end multigaap changes
           AND str.khr_id = c_khr_id
           and sele.stream_element_date = (select max(sele.stream_element_date)
    					FROM okl_strm_elements sele,
						okl_streams str,
						okl_strm_type_v sty
					WHERE sele.stm_id = str.id
					AND str.sty_id = sty.id
					AND UPPER(sty.name) = 'PRINCIPAL PAYMENT'
					AND str.say_code = 'CURR'
                                        --multigaap changes
                                        AND str.ACTIVE_YN = 'Y'
                                        AND str.PURPOSE_CODE is NULL
                                        --end multigaap changes
					AND str.khr_id = c_khr_id
					AND sele.DATE_BILLED is not null);

	l_knt_paid		NUMBER;

BEGIN
	OPEN c_payments_made(p_khr_id);
	FETCH c_payments_made INTO l_knt_paid;
	CLOSE c_payments_made;

	IF l_knt_paid = 0 THEN
		--No payment have been made yet.
		OPEN c_initial_principal(p_khr_id);
		FETCH c_initial_principal INTO x_principal_balance;
		CLOSE c_initial_principal;
	ELSE
		--Some payments have been made till now.
		OPEN c_current_principal(p_khr_id);
		FETCH c_current_principal INTO x_principal_balance;
		CLOSE c_current_principal;
	END IF;

END get_principal_balance;

*/
/*
 PROCEDURE get_payments_remaining(
		p_kle_id		IN	NUMBER
        ,p_parent_kle_id_passed IN VARCHAR2
		,x_payments_remaining	OUT NOCOPY NUMBER)
  IS
    l_parent_kle_id     NUMBER;
      CURSOR c_remaining_payments(c_kle_id	NUMBER)
	IS
	SELECT count(sele.amount)
	FROM okl_strm_elements sele,
       	    okl_streams str,
       	    okl_strm_type_v sty
	WHERE sele.stm_id = str.id
       	    AND str.sty_id = sty.id
       	    AND UPPER(sty.name) = 'PRINCIPAL PAYMENT'
            AND str.say_code = 'CURR'
           --multigaap changes
           AND str.ACTIVE_YN = 'Y'
           AND str.PURPOSE_CODE is NULL
           --end multigaap changes
       	    AND str.kle_id = c_kle_id
       	    and sele.DATE_BILLED is null;
    CURSOR c_get_parent_kle_id(c_kle_id NUMBER)
    IS
    SELECT orig_system_id1
    FROM okc_k_lines_b
    where id=c_kle_id;

BEGIN
 --Since Streams are not generated for the Copied Contract, We have to
 --get the kle_id of the original contract and find the values for
 -- that contract from the streams table.
 -- The parameter p_parent_kle_id_passed will be 'F' if copied kle_id
 -- is passed.

 If (p_parent_kle_id_passed = 'F') THEN
    OPEN c_get_parent_kle_id(p_kle_id);
    FETCH c_get_parent_kle_id INTO l_parent_kle_id;
    CLOSE c_get_parent_kle_id;
ELSE
    l_parent_kle_id := p_kle_id;
END IF;
	OPEN c_remaining_payments(l_parent_kle_id);
	FETCH c_remaining_payments INTO x_payments_remaining;
	CLOSE c_remaining_payments;


END get_payments_remaining;

*/
FUNCTION get_end_date(
    l_start_date      IN  DATE,
    p_frequency       IN  VARCHAR2,
    p_period          IN  NUMBER)
    RETURN DATE IS
    l_end_date date;
    factor number := 0;
    BEGIN
     if(p_frequency = 'M') then
        factor := 1;
     elsif(p_frequency = 'Q') then
        factor := 3;
     elsif(p_frequency = 'S') then
        factor := 6;
     elsif(p_frequency = 'A') then
        factor := 12;
     end if;
     l_end_date := add_months(l_start_date, (factor * nvl(p_period,0)));
     l_end_date := l_end_date - 1;
     return l_end_date;
EXCEPTION
    WHEN OTHERS THEN
      RETURN null;
END get_end_date;

FUNCTION get_final_end_date(
    p_start_date      IN  VARCHAR2,
    p_stub_days       IN  VARCHAR2,
    p_frequency       IN  VARCHAR2,
    p_period          IN  VARCHAR2)
    RETURN DATE IS
    l_end_date date;
    BEGIN
     if(p_stub_days is not null and p_stub_days <> OKL_API.G_MISS_CHAR) then -- end date for stub entry.
        l_end_date := FND_DATE.canonical_to_date(p_start_date) + to_number(p_stub_days);
        l_end_date := l_end_date - 1;
     else -- end date for level entry.
        l_end_date := get_end_date(FND_DATE.canonical_to_date(p_start_date), p_frequency, to_number(nvl(p_period,0)));
     end if;
     return l_end_date;
EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
END get_final_end_date;

--************************************************************************
-- API for getting the payment details for a contract.
-- This API will be used when we call ISG for Stream Generation
-- This API accepts the contract ID and then gets the asset lines on the
-- contract  and calculates the remaining payments for the asset line.
-- For calculation of the remaining payments we do no see whether the
-- Billing has been run for the contract or not.
-- We get the number of remaining payments are of the paydown date
-- and calculate the number of payments going forward.
-- We figure out which line has the longest term remaining and get the
-- Frequency and Advance arrears for that line and send it to ISG.
--***********************************************************************



PROCEDURE get_payment_details
(	p_contract_id		IN	NUMBER
	,p_paydown_date		IN	DATE
        ,x_line_id              OUT NOCOPY NUMBER
        ,x_frequency            OUT NOCOPY VARCHAR2
        ,x_arrears_yn           OUT NOCOPY VARCHAR2
	,x_payments_remaining	OUT NOCOPY NUMBER)
AS
    l_number_of_payments    NUMBER;
    l_max_number_of_payments    NUMBER := 0;
    l_line_id_max_payments  NUMBER;
    l_rent_slh_id       NUMBER;

    CURSOR c_line_id (l_khr_id NUMBER)
    IS
       SELECT line.id line_id
       FROM okl_k_lines_full_v line,
            okc_line_styles_v lse
       WHERE line.lse_id=lse.id
       and lse.lty_code='FREE_FORM1'
       and dnz_chr_id=l_khr_id;


    CURSOR c_get_remaining_payments(c_line_id NUMBER,c_pay_date DATE)
    IS
      SELECT count(sel.amount)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.name = 'PRINCIPAL PAYMENT'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code is NULL
        AND stm.kle_id = c_line_id
        AND sel.stm_id = stm.id
        AND sel.stream_element_date >
                   ( SELECT NVL(MAX(sel.stream_element_date), c_pay_date)
                     FROM okl_strm_elements sel,okl_streams stm,
                          okl_strm_type_v sty
                     WHERE sty.name = 'PRINCIPAL PAYMENT'
                       AND stm.sty_id = sty.id
                       AND stm.say_code = 'CURR'
                       AND stm.active_yn = 'Y'
                       AND stm.purpose_code is NULL
                       AND stm.kle_id = c_line_id
                       AND sel.stm_id = stm.id
                       AND sel.stream_element_date <= c_pay_date);

    CURSOR c_get_rent_slh_id(c_line_id NUMBER,c_khr_id NUMBER)
    IS
        select rl.id
        from okc_rule_groups_v rg,
             okc_rules_v rl
        where rl.rgp_id = rg.id
          and rl.dnz_chr_id = rg.dnz_chr_id
          and rg.cle_id = c_line_id
          and rg.rgd_code = 'LALEVL'
          and rl.rule_information_category = 'LASLH'
          and rl.dnz_chr_id = c_khr_id
          and rl.object1_id1=(select id from okl_strm_type_b where code='RENT');

    CURSOR c_get_freq_arr(c_line_id NUMBER,c_khr_id NUMBER,c_rent_slh_id NUMBER)
    IS
        select rl.object1_id1 frequency
              ,nvl(rl.rule_information10,'N') Arrears
        from okc_rule_groups_v rg,
             okc_rules_v rl
        where rl.rgp_id = rg.id
          and rl.dnz_chr_id = rg.dnz_chr_id
          and rg.cle_id = c_line_id
          and rg.rgd_code = 'LALEVL'
          and rl.rule_information_category = 'LASLL'
          and rl.dnz_chr_id = c_khr_id
          and rl.object2_id1=c_rent_slh_id
          and rownum = 1;


BEGIN

	FOR cur_rec in c_line_id(p_contract_id) LOOP

    		OPEN c_get_remaining_payments(cur_rec.line_id,p_paydown_date);
		FETCH c_get_remaining_payments INTO l_number_of_payments;
		CLOSE c_get_remaining_payments;

    		If l_number_of_payments > l_max_number_of_payments THEN
        		l_max_number_of_payments := l_number_of_payments;
        		l_line_id_max_payments := cur_rec.line_id;
    		END IF;

	END LOOP;

    	OPEN c_get_rent_slh_id(l_line_id_max_payments,p_contract_id);
    	FETCH c_get_rent_slh_id INTO l_rent_slh_id;
    	CLOSE c_get_rent_slh_id;

    	OPEN c_get_freq_arr(l_line_id_max_payments,p_contract_id,l_rent_slh_id);
    	FETCH c_get_freq_arr INTO x_frequency,x_arrears_yn;
    	CLOSE c_get_freq_arr;


    	x_line_id := l_line_id_max_payments;
    	x_payments_remaining := l_max_number_of_payments;


END get_payment_details;

  PROCEDURE get_current_payments(
    p_khr_id            IN  NUMBER,
    x_payment_struc     OUT NOCOPY okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_prim_sty_id       OUT NOCOPY NUMBER,
    x_upp_sty_id        OUT NOCOPY NUMBER,
    x_primary_strm_type  OUT NOCOPY VARCHAR2) AS

   /*-----------------------------------------------------------------------+
 *    | Cursor Declarations                                                   |
 *       +-----------------------------------------------------------------------*/

--added by rkuttiya for 11i OKL.H Variable Rate Project
   --Get type of Stream type , Principal Payment Stream type or Rent Stream type
   CURSOR  l_stream_type_csr(p_stream_type IN VARCHAR2
                           ,p_khr_id IN NUMBER) IS
    SELECT  COUNT(*)
    FROM    okc_rules_b sll_rul,
            okl_strmtyp_source_v sttyp,
            okc_rules_b slh_rul,
            okc_rule_groups_b rgp
    WHERE   sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    AND     sttyp.stream_type_purpose = p_stream_type
    AND     rgp.dnz_chr_id = p_khr_id;

    -- Get all the assets attached to the contract
    -- These lines may or may not have payments associated with them
    CURSOR l_okcklines_csr(cp_chr_id IN NUMBER) IS
    SELECT cle.id, cle.lse_id, lse.lty_code
    FROM   okc_k_lines_b cle, okc_line_styles_b lse
    WHERE  cle.lse_id = lse.id
    AND    cle.sts_code = 'BOOKED'
    AND    lse.lty_code = 'FREE_FORM1'
    AND    chr_id = cp_chr_id;

    --This cursor returns the payments associated with an Asset
    -- Get the current Line Level payments
    CURSOR  l_lpayments_csr(cp_cle_id IN NUMBER
                           ,cp_sty_id IN NUMBER) IS
    SELECT  rgp.cle_id cle_id,
        sttyp.id1   sty_id,
        sttyp.code  stream_type,
        tuom.id1 frequency,
        sll_rul.rule_information1 seq_num,
        sll_rul.rule_information2 start_date,
        sll_rul.rule_information3 period_in_months,
        sll_rul.rule_information5 advance_periods,
        sll_rul.rule_information6 amount,
        sll_rul.rule_information10 due_arrears_yn,
        sll_rul.rule_information7 stub_days,
        sll_rul.rule_information8 stub_amount,
        rgp.dnz_chr_id khr_id
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    AND     rgp.cle_id = cp_cle_id
    AND     sttyp.id1 = cp_sty_id
    ORDER BY stream_type, start_date;



 /*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/
    l_prev_sty_id NUMBER := -99;
    l_payment_struc              okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    i                            NUMBER :=1;
    x_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    --l_rent_sty_id            NUMBER;
    l_prim_sty_id            NUMBER;
    l_strm_type              VARCHAR2(80);
    l_upp_sty_id             NUMBER;
    l_rent_count             NUMBER;
    l_principal_count        NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.get_current_payments'
                                                                        ,'Begin(+)');
    END IF;

    --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.get_current_payments.',
              'p_khr_id  :'||p_khr_id );

   END IF;

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Get current payments');
END IF;

    --rkuttiya added for 11i OKL.H Variable Rate Project
      -- Get primary stream type on the contract
       OPEN l_stream_type_csr('PRINCIPAL_PAYMENT',p_khr_id);
       FETCH l_stream_type_csr INTO l_principal_count;
       CLOSE l_stream_type_csr;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_principal_count);
        END IF;

       OPEN l_stream_type_csr('RENT',p_khr_id);
       FETCH l_stream_type_csr INTO l_rent_count;
       CLOSE l_stream_type_csr;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_rent_count);
        END IF;

       IF l_principal_count > 0 THEN
         l_strm_type := 'PRINCIPAL_PAYMENT';
       --get the sty_id for principal payment
       OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_PRINCIPAL_PAYMENT
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_prim_sty_id);

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After getting primary stream type for Principal Payment'|| x_return_status);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Primary Stream Type Id for Principal Payment'|| l_prim_sty_id);
          END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 --Get the Stream type id for UPP.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'dependent stream type id: '||l_upp_sty_id);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

       ELSIF l_rent_count  > 0 THEN
         l_strm_type := 'RENT';
          --get the sty id for rent.
        OKL_STREAMS_UTIL.get_primary_stream_type
                (p_khr_id              => p_khr_id
                ,p_primary_sty_purpose => G_RENT_STREAM
                ,x_return_status       => x_return_status
                ,x_primary_sty_id      => l_prim_sty_id);
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Get primary strm type for Rent ' || x_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Primary Stream Type Id for Rent'   || l_prim_sty_id);
 END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Get the Stream type id for UPP.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Dependent Stream Type Id :' || l_upp_sty_id);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       END IF;



   --------------get curent line level payments ---------------------------
   -- get all the contract lines
   FOR l_okcklines_rec IN l_okcklines_csr(p_khr_id) LOOP

       l_prev_sty_id := -99;

	--Get the Rent Payments
       FOR l_lpayments_rec IN l_lpayments_csr(l_okcklines_rec.id,l_prim_sty_id) LOOP
        IF l_prev_sty_id <> l_lpayments_rec.sty_id THEN
            --Create the SLH here
            l_payment_struc(i).chr_id :=  l_lpayments_rec.khr_id;
            l_payment_struc(i).cle_id :=  l_lpayments_rec.cle_id;
            l_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLH';
            l_payment_struc(i).OBJECT1_ID1 :=  l_lpayments_rec.sty_id;
            i := i+ 1;
        END IF;
              --Now populate LASLLs
            l_payment_struc(i).chr_id :=  l_lpayments_rec.khr_id;
            l_payment_struc(i).cle_id :=  l_lpayments_rec.cle_id;
            l_payment_struc(i).rule_information1 := l_lpayments_rec.seq_num;
            l_payment_struc(i).RULE_INFORMATION2 := l_lpayments_rec.start_date;
            l_payment_struc(i).rule_information3 := l_lpayments_rec.period_in_months;
            l_payment_struc(i).rule_information5 := l_lpayments_rec.advance_periods;
            l_payment_struc(i).rule_information6 := l_lpayments_rec.amount;
            l_payment_struc(i).rule_information7 := l_lpayments_rec.stub_days;
            l_payment_struc(i).rule_information8 := l_lpayments_rec.stub_amount;
            l_payment_struc(i).rule_information10 := l_lpayments_rec.due_arrears_yn;
            l_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLL';
            l_payment_struc(i).OBJECT1_ID1 := l_lpayments_rec.frequency;  --Freq
            -- ansethur 28-feb-08 bug # 6697542
            l_payment_struc(i).OBJECT2_ID2 := '#';
            -- ansethur 28-feb-08 bug # 6697542
            i := i + 1;
            l_prev_sty_id :=  l_lpayments_rec.sty_id;

       END LOOP;

	--Get the earlier Unscheduled Principal Payments for this line.
       FOR l_lpayments_rec IN l_lpayments_csr(l_okcklines_rec.id,l_upp_sty_id) LOOP
        IF l_prev_sty_id <> l_lpayments_rec.sty_id THEN
            --Create the SLH here
            l_payment_struc(i).chr_id :=  l_lpayments_rec.khr_id;
            l_payment_struc(i).cle_id :=  l_lpayments_rec.cle_id;
            l_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLH';
            l_payment_struc(i).OBJECT1_ID1 :=  l_lpayments_rec.sty_id;
            i := i+ 1;
        END IF;
              --Now populate LASLLs
            l_payment_struc(i).chr_id :=  l_lpayments_rec.khr_id;
            l_payment_struc(i).cle_id :=  l_lpayments_rec.cle_id;
            l_payment_struc(i).rule_information1 := l_lpayments_rec.seq_num;
            l_payment_struc(i).RULE_INFORMATION2 := l_lpayments_rec.start_date;
            l_payment_struc(i).rule_information3 := l_lpayments_rec.period_in_months;
            l_payment_struc(i).rule_information5 := l_lpayments_rec.advance_periods;
            l_payment_struc(i).rule_information6 := l_lpayments_rec.amount;
            l_payment_struc(i).rule_information7 := l_lpayments_rec.stub_days;
            l_payment_struc(i).rule_information8 := l_lpayments_rec.stub_amount;
            l_payment_struc(i).rule_information10 := l_lpayments_rec.due_arrears_yn;
            l_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLL';
            l_payment_struc(i).OBJECT1_ID1 := l_lpayments_rec.frequency;  --Freq
            --asawanka added for bug #6679623 start
            l_payment_struc(i).OBJECT2_ID2 := '#';
            --asawanka added for bug #6679623 end
            i := i + 1;
            l_prev_sty_id :=  l_lpayments_rec.sty_id;
       END LOOP;


   END LOOP;
   --------------------end get current line level payments -----------------------

  -- set the return status and out variables
  x_payment_struc := l_payment_struc;
  x_primary_strm_type := l_strm_type;
  x_prim_sty_id       := l_prim_sty_id;
  x_upp_sty_id        := l_upp_sty_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.get_current_payments'
                                                                        ,'End(-)');
  END IF;
  END get_current_payments;

PROCEDURE modify_payments(
    p_payment_struc     IN okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    p_ppd_date		IN DATE,
    p_blank_amount	IN VARCHAR2,
    p_rent_sty_id	IN NUMBER,
    x_modified_payment_struc     OUT NOCOPY okl_mass_rebook_pvt.strm_lalevl_tbl_type)
AS


   --The parameter p_blank_amount is very important and the allowable
   --values are 'Y', 'N' or 'NEGATE'
   --If the value is 'Y' , then the amount will be set to Zero
   --If the value is 'NEGATE', then the amount will be multiplied by -1 to
   --negate the value.
   --If the value is 'N', then the amount will not be touched.
   --In the CASE of ISG, the amount should not be touched.
   --In the CASE of ESG, the amount should be negated. We are doing this because
   --we need to figure out whether to lock the amount or rate or both when
   --sending the params to Pricing using ESG. So, if the amount is -ve, we
   --lock the rate and set the amount back to positive, if the amount is +ve,
   --we lock Both and send the amount as is.

 /*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/
    l_prev_sty_id NUMBER := -99;
    l_payment_struc              okl_mass_rebook_pvt.strm_lalevl_tbl_type := p_payment_struc;
    i                            NUMBER :=1;
    x_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sty_id			NUMBER;

   --Split
    l_end_date      DATE;
    l_upper_period        NUMBER;
    l_lower_period        NUMBER;
    l_payment_already_split VARCHAR2(1) := 'N';
    k       NUMBER := 1;
    l_modified_payments okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    l_prev_cle_id NUMBER := -99;
    pymnt_knt   NUMBER;
    l_stub_pymnt    VARCHAR2(1);
    l_upper_stub_days   NUMBER;
    l_lower_stub_days   NUMBER;
    l_stub_days   NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN --[1]
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments'
                                                                        ,'Begin(+)');
    END IF; --[1]


   FOR j in l_payment_struc.FIRST..l_payment_struc.LAST LOOP
    IF l_prev_cle_id <> l_payment_struc(j).cle_id THEN --[2]
        l_payment_already_split := 'N';
        l_prev_cle_id   := l_payment_struc(j).cle_id;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments.',
              'cle_id is  :'||l_payment_struc(j).cle_id );
        END IF;

    END IF; --[2]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLH' THEN --[3]
        --Copy the values to the other payment stuc table.
        l_modified_payments(k) :=  l_payment_struc(j);
	l_sty_id	       := l_payment_struc(j).object1_id1;
        k := k+ 1;
    END IF; -- [3]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLL' THEN --[4]
	IF l_sty_id = p_rent_sty_id THEN --[5]
            l_end_date := get_final_end_date(
                     p_start_date => l_payment_struc(j).RULE_INFORMATION2
                    ,p_stub_days  => l_payment_struc(j).rule_information7
                    ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                    ,p_period     => l_payment_struc(j).rule_information3);

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End Date is : '|| l_end_date);
     END IF;
            IF l_end_date > p_ppd_date  THEN --[6]

                IF l_payment_already_split <> 'Y' THEN --[7]
                    --Split Only this payment.
                    l_payment_already_split := 'Y';
                    IF l_payment_struc(j).rule_information7 <> 0 THEN
                        pymnt_knt := l_payment_struc(j).rule_information7; --Use Stub days
                        l_stub_pymnt := 'Y';
                    ELSE
                        pymnt_knt := l_payment_struc(j).rule_information3; --Use actual periods
                        l_stub_pymnt := 'N';
                    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        		    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Stub Payment is : '|| l_stub_pymnt);
      END IF;
                    FOR i in 1..pymnt_knt LOOP
                        IF l_stub_pymnt = 'Y' THEN
                            l_stub_days := i;
                        ELSE
                            l_stub_days := l_payment_struc(j).rule_information7;
                        END IF;
                        l_end_date := get_final_end_date(
                        p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        ,p_stub_days  => l_stub_days
                        ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        ,p_period     => i);
                        IF l_stub_pymnt = 'Y' THEN
                            l_upper_stub_days := i;
                        ELSE
                            l_upper_period := i;
                        END IF;
                        IF l_end_date >= p_ppd_date THEN --[8]
                            IF l_stub_pymnt = 'Y' THEN
                                l_lower_stub_days := l_payment_struc(j).rule_information7 - l_upper_stub_days;
                            ELSE
                                l_lower_period := l_payment_struc(j).rule_information3 - l_upper_period ;
                            END IF;
			    --Check for Adv/arrears and split accordingly.
		            IF l_payment_struc(j).rule_information10 = 'Y' THEN --Arrear payment
				IF l_stub_pymnt = 'Y' THEN
					l_upper_stub_days := l_upper_stub_days - 1;
					l_lower_stub_days := l_lower_stub_days + 1;
				ELSE
					l_upper_period := l_upper_period -1;
					l_lower_period := l_lower_period +1;
				END IF;
				--recalculate the end days.
                        	l_end_date := get_final_end_date(
                        		p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        		,p_stub_days  => l_upper_stub_days
                        		,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        		,p_period     => l_upper_period);
			    END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         			    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Lower Period is :' || l_lower_period);
  			    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Upper Period is :' || l_upper_period);
       END IF;
                            EXIT;
                        END IF; --[8]
                    END LOOP;
                    l_modified_payments(k) :=  l_payment_struc(j);
                    IF l_stub_pymnt = 'N' THEN
                        l_modified_payments(k).rule_information3 := l_upper_period; --SEt the period
                    ELSE
                        l_modified_payments(k).rule_information7 := l_upper_stub_days; --Set the stub days
                    END IF;
                    k := K+1;
                    --For the second part of the split payment
                    l_modified_payments(k) :=  l_payment_struc(j);
                    --l_modified_payments(k).RULE_INFORMATION2 := to_date(l_end_date +1);
                    l_modified_payments(k).RULE_INFORMATION2 := FND_DATE.date_to_canonical(l_end_date +1);
                    --  l_modified_payments(k).RULE_INFORMATION2 := FND_DATE.date_to_canonical(l_end_date);
                    IF l_stub_pymnt = 'N' THEN --[9]
                        l_modified_payments(k).rule_information3 := l_lower_period;
			IF p_blank_amount = 'Y' THEN
	                        l_modified_payments(k).rule_information6 := 0;  --Set amount to Zero
            		ELSIF p_blank_amount = 'NEGATE' THEN
                            l_modified_payments(k).rule_information6 := -1
							* NVL(l_modified_payments(k).rule_information6,0);

			END IF;
                    ELSE --[9]
                        l_modified_payments(k).rule_information7 := l_lower_stub_days;
			IF p_blank_amount = 'Y' THEN
                        	l_modified_payments(k).rule_information8 := 0; --Set Stub amount to Zero
            		ELSIF p_blank_amount = 'NEGATE' THEN
                            	l_modified_payments(k).rule_information8 := -1
							 * NVL(l_modified_payments(k).rule_information8,0);

			END IF;
                    END IF;                        --[9]
                    k := k+1;
                ELSE --[7]
                    l_modified_payments(k) :=  l_payment_struc(j);
                    IF   l_payment_struc(j).rule_information7 <> 0 THEN
			IF p_blank_amount = 'Y' THEN
                            l_modified_payments(k).rule_information8 := 0; --Set Stub amount to Zero
            		ELSIF p_blank_amount = 'NEGATE' THEN
                            	l_modified_payments(k).rule_information8 := -1
							 * NVL(l_modified_payments(k).rule_information8,0);
			END IF;
                    ELSE
			IF p_blank_amount = 'Y' THEN
                            l_modified_payments(k).rule_information6 := 0; --Set amount to Zero
            		ELSIF p_blank_amount = 'NEGATE' THEN
                            l_modified_payments(k).rule_information6 := -1
							* NVL(l_modified_payments(k).rule_information6,0);
			END IF;
                    END IF;
                    k := k+ 1;
                END IF; --[7]
            ELSE  --[6]
                l_modified_payments(k) :=  l_payment_struc(j);
                k := k+ 1;
            END IF; --[6]
	ELSE --[5]
	    l_modified_payments(k) :=  l_payment_struc(j);
            k := k+ 1;
	END IF; --[5]
    END IF; --[4]
END LOOP;



  -- set the return status and out variables
  x_modified_payment_struc := l_modified_payments;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments'
                                                                        ,'End(-)');
  END IF;
END modify_payments;

PROCEDURE modify_terms(
    p_payment_struc     IN okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    p_chr_id                 IN NUMBER,
    p_ppd_date		         IN DATE,
    p_ppd_amount	         IN VARCHAR2,
    p_total_k_cost           IN NUMBER,
    p_sty_id	             IN NUMBER,
    p_upp_sty_id             IN NUMBER,
    x_modified_payment_struc     OUT NOCOPY okl_mass_rebook_pvt.strm_lalevl_tbl_type)
AS


   --The parameter p_blank_amount is very important and the allowable
   --values are 'Y', 'N' or 'NEGATE'
   --If the value is 'Y' , then the amount will be set to Zero
   --If the value is 'NEGATE', then the amount will be multiplied by -1 to
   --negate the value.
   --If the value is 'N', then the amount will not be touched.
   --In the CASE of ISG, the amount should not be touched.
   --In the CASE of ESG, the amount should be negated. We are doing this because
   --we need to figure out whether to lock the amount or rate or both when
   --sending the params to Pricing using ESG. So, if the amount is -ve, we
   --lock the rate and set the amount back to positive, if the amount is +ve,
   --we lock Both and send the amount as is.

 /*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/
    l_prev_sty_id NUMBER := -99;
    l_payment_struc              okl_mass_rebook_pvt.strm_lalevl_tbl_type := p_payment_struc;
    i                            NUMBER :=1;
    x_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version                 CONSTANT NUMBER := 1;
    l_init_msg_list               VARCHAR2(1) := 'T';
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_message                     VARCHAR2(2000);
    l_sty_id			          NUMBER;
    l_currency_code			      VARCHAR2(30);
    l_acc_int                     NUMBER;
    l_current_amount              NUMBER;

   --Split
    l_end_date              DATE;
    l_upper_period          NUMBER;
    l_lower_period          NUMBER;
    l_term_already_split VARCHAR2(1) := 'N';
    k                       NUMBER := 1;
    l_modified_payments     okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    l_prev_cle_id           NUMBER := -99;
    pymnt_knt               NUMBER;
    l_stub_pymnt            VARCHAR2(1);
    l_upper_stub_days       NUMBER;
    l_lower_stub_days       NUMBER;
    l_stub_days             NUMBER;
    l_principal_balance      NUMBER;
    l_asset_cost            NUMBER;
    l_ppd_for_asset         NUMBER;
    l_raw_ppd_amount        NUMBER;
    l_ppd_amount            NUMBER;
    l_raw_ppd_for_asset     NUMBER;
    l_total_princ_balance   NUMBER;
    l_amount                NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN --[1]
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_terms'
                                                                        ,'Begin(+)');
    END IF; --[1]


   FOR j in l_payment_struc.FIRST..l_payment_struc.LAST LOOP
    IF l_prev_cle_id <> l_payment_struc(j).cle_id THEN --[2]
        l_term_already_split := 'N';

        l_prev_cle_id   := l_payment_struc(j).cle_id;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments.',
              'cle_id is  :'||l_payment_struc(j).cle_id );
        END IF;

    END IF; --[2]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLH' THEN --[3]
        --Copy the values to the other payment stuc table.
        l_modified_payments(k) :=  l_payment_struc(j);
	l_sty_id	       := l_payment_struc(j).object1_id1;
        k := k+ 1;
    END IF; -- [3]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLL' THEN --[4]
	IF l_sty_id = p_sty_id THEN --[5]
            l_end_date := get_final_end_date(
                     p_start_date => l_payment_struc(j).RULE_INFORMATION2
                    ,p_stub_days  => l_payment_struc(j).rule_information7
                    ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                    ,p_period     => l_payment_struc(j).rule_information3);

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End Date is : '|| l_end_date);
     END IF;
            IF l_end_date > p_ppd_date  THEN --[6]

                IF l_term_already_split <> 'Y' THEN --[7]
                    --Split Only this payment.
                    l_term_already_split := 'Y';
                    --Bug#5100215 following cade added to drive upper period -dkagrawa
                    IF l_payment_struc(j).rule_information7 <> 0 THEN
                        pymnt_knt := l_payment_struc(j).rule_information7; --Use Stub days
                        l_stub_pymnt := 'Y';
                    ELSE
                        pymnt_knt := l_payment_struc(j).rule_information3; --Use actual periods
                        l_stub_pymnt := 'N';
                    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        		    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Stub Payment is : '|| l_stub_pymnt);
      END IF;
                    FOR i in 1..pymnt_knt LOOP
                        IF l_stub_pymnt = 'Y' THEN
                            l_stub_days := i;
                        ELSE
                            l_stub_days := l_payment_struc(j).rule_information7;
                        END IF;
                        l_end_date := get_final_end_date(
                        p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        ,p_stub_days  => l_stub_days
                        ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        ,p_period     => i);
                        IF l_stub_pymnt = 'Y' THEN
                            l_upper_stub_days := i;
                        ELSE
                            l_upper_period := i;
                        END IF;
                        IF l_end_date >= p_ppd_date THEN --[8]
			    --Check for Adv/arrears and split accordingly.
		            IF l_payment_struc(j).rule_information10 = 'Y' THEN --Arrear payment
				IF l_stub_pymnt = 'Y' THEN
					l_upper_stub_days := l_upper_stub_days - 1;
				ELSE
					l_upper_period := l_upper_period -1;
				END IF;
				--recalculate the end days.
                        	l_end_date := get_final_end_date(
                        		p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        		,p_stub_days  => l_upper_stub_days
                        		,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        		,p_period     => l_upper_period);
			    END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         			    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Upper Period is :' || l_upper_period);
       END IF;
                            EXIT;
                        END IF; --[8]
                    END LOOP;
                    l_modified_payments(k) :=  l_payment_struc(j);
                    IF l_stub_pymnt = 'N' THEN
                       l_modified_payments(k).rule_information3 := l_upper_period; --SEt the period
                    ELSE
                       l_modified_payments(k).rule_information7 := l_upper_stub_days; --Set the stub days
                    END IF;
                    --l_current_amount := l_payment_struc(j).rule_information6;
                    --l_payment_struc(j).rule_information3 := (l_ppd_amount/l_current_amount);
		    --l_modified_payments(k) :=  l_payment_struc(j);
                    --Bug#5100215 end
                END IF; --[7]
                k := k + 1;
             ELSE
                l_modified_payments(k) :=  l_payment_struc(j);
                k := k+ 1;
             END IF; --[6]
        ELSE
          l_modified_payments(k) :=  l_payment_struc(j);
          k := k+ 1;
        END IF; --[5]
    END IF; --[4]
    --populate the unscheduled principal payment here,

    l_modified_payments(k).chr_id := l_payment_struc(j).chr_id;
    l_modified_payments(k).cle_id := l_payment_struc(j).cle_id;
    l_modified_payments(k).rule_information2 := p_ppd_date;
    l_modified_payments(k).rule_information7 := 1;
    l_modified_payments(k).rule_information8 := p_ppd_amount;
    k := k + 1;
END LOOP;

  -- set the return status and out variables
  x_modified_payment_struc := l_modified_payments;


END modify_terms;


PROCEDURE modify_principal_payments(
                p_payment_struc         IN okl_mass_rebook_pvt.strm_lalevl_tbl_type,
                p_chr_id                IN NUMBER,
                p_ppd_date		         IN DATE,
                p_ppd_amount	         IN VARCHAR2,
                p_total_k_cost           IN NUMBER,
                p_sty_id	             IN NUMBER,
                p_upp_sty_id              IN NUMBER,
                x_modified_payment_struc     OUT NOCOPY okl_mass_rebook_pvt.strm_lalevl_tbl_type)
AS

 /*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/
    l_prev_sty_id NUMBER := -99;
    l_payment_struc              okl_mass_rebook_pvt.strm_lalevl_tbl_type := p_payment_struc;
    i                            NUMBER :=1;
    x_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version                 CONSTANT NUMBER := 1;
    l_init_msg_list               VARCHAR2(1) := 'T';
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_message                     VARCHAR2(2000);
    l_sty_id			          NUMBER;
    l_currency_code			      VARCHAR2(30);
    l_acc_int                     NUMBER;

   --Split
    l_end_date              DATE;
    l_upper_period          NUMBER;
    l_lower_period          NUMBER;
    l_payment_already_split VARCHAR2(1) := 'N';
    k                       NUMBER := 1;
    l_modified_payments     okl_mass_rebook_pvt.strm_lalevl_tbl_type;
    l_prev_cle_id           NUMBER := -99;
    pymnt_knt               NUMBER;
    l_stub_pymnt            VARCHAR2(1);
    l_upper_stub_days       NUMBER;
    l_lower_stub_days       NUMBER;
    l_stub_days             NUMBER;
    l_principal_balance      NUMBER;
    l_asset_cost            NUMBER;
    l_ppd_for_asset         NUMBER;
    l_raw_ppd_amount        NUMBER;
    l_ppd_amount            NUMBER;
    l_raw_ppd_for_asset     NUMBER;
    l_total_princ_balance   NUMBER;
    l_amount                NUMBER;
    j                       NUMBER := 0;

    CURSOR c_get_cur(cp_khr_id IN NUMBER) IS
    	SELECT currency_code
    	FROM   okc_k_headers_b
    	WHERE  id = cp_khr_id;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN --[1]
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments'
                                                                        ,'Begin(+)');
    END IF; --[1]
     open c_get_cur(p_chr_id);
     fetch c_get_cur into l_currency_code;
     close c_get_cur;

    IF l_payment_struc.COUNT > 0 THEN
       j := l_payment_struc.FIRST;
       LOOP
         IF l_prev_cle_id <> l_payment_struc(j).cle_id THEN --[2]
           l_payment_already_split := 'N';
--get the line cost here.
          OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => l_api_version,
                                          p_init_msg_list => l_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          p_formula_name  => 'LINE_CAP_AMNT',
                                          p_contract_id   => p_chr_id,
                                          p_line_id       => l_payment_struc(j).cle_id,
                                          x_value         => l_asset_cost);

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute LINE_CAP_AMNT:  in modify principal payments'|| l_asset_cost);
           END IF;
                        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                        	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                        	raise OKC_API.G_EXCEPTION_ERROR;
			End If;

--Pro rate the ppd amt for this line
			l_raw_ppd_for_asset := (l_asset_cost/p_total_k_cost)
							* p_ppd_amount;
                            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'raw ppd for asset'||l_raw_ppd_for_asset);
                            END IF;

                        l_ppd_for_asset := Okl_Accounting_Util.ROUND_AMOUNT(
                                		p_amount => l_raw_ppd_for_asset,
                                		p_currency_code => l_currency_code);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PPD for Asset : '|| l_ppd_for_asset);
                        END IF;

        		OKL_STREAM_GENERATOR_PVT.get_sched_principal_bal(
                                         p_api_version       => l_api_version,
                                         p_init_msg_list     => l_init_msg_list,
                                         p_khr_id            => p_chr_id,
                                         p_kle_id            => l_payment_struc(j).cle_id,
                                         p_date              => p_ppd_date,
                                         x_principal_balance => l_principal_balance,
                                         x_accumulated_int   => l_acc_int,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => l_msg_count,
                                         x_msg_data          => l_msg_data);

        		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        		ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_ERROR;
        		END IF;
		--l_total_princ_balance := l_principal_balance + l_acc_int ;
                  l_total_princ_balance := l_principal_balance;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'total Principal Balance  : ' || l_total_princ_balance);
                 END IF;

			--PPD amount for the asset = Principal Balance on asset
			--				- Pro rated ppd for this asset.
			--dkagrawa commented the following code for bug#5203265
                        --l_raw_ppd_amount := nvl(l_total_princ_balance,0) - nvl(l_ppd_for_asset,0);
                        --l_ppd_amount := Okl_Accounting_Util.ROUND_AMOUNT(
                        --        		p_amount => l_raw_ppd_amount,
                        --        		p_currency_code => l_currency_code);
                        --Bug# 5203265 end




        l_prev_cle_id   := l_payment_struc(j).cle_id;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments.',
              'cle_id is  :'||l_payment_struc(j).cle_id );
        END IF;

    END IF; --[2]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLH' THEN --[3]
        --Copy the values to the other payment stuc table.
        l_modified_payments(k) :=  l_payment_struc(j);
	l_sty_id	       := l_payment_struc(j).object1_id1;
        k := k+ 1;
    END IF; -- [3]

    IF l_payment_struc(j).RULE_INFORMATION_CATEGORY = 'LASLL' THEN --[4]
	IF l_sty_id = p_sty_id THEN --[5]
            l_end_date := get_final_end_date(
                     p_start_date => l_payment_struc(j).RULE_INFORMATION2
                    ,p_stub_days  => l_payment_struc(j).rule_information7
                    ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                    ,p_period     => l_payment_struc(j).rule_information3);

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End Date is : '|| l_end_date);
     END IF;
            IF l_end_date > p_ppd_date  THEN --[6]
                IF l_payment_already_split <> 'Y' THEN --[7]
                    --Split Only this payment.
                    l_payment_already_split := 'Y';
                    IF l_payment_struc(j).rule_information7 <> 0 THEN
                        pymnt_knt := l_payment_struc(j).rule_information7; --Use Stub days
                        l_stub_pymnt := 'Y';
                    ELSE
                        pymnt_knt := l_payment_struc(j).rule_information3; --Use actual periods
                        l_stub_pymnt := 'N';
                    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        		    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Stub Payment is : '|| l_stub_pymnt);
      END IF;
                    FOR i in 1..pymnt_knt LOOP
                        IF l_stub_pymnt = 'Y' THEN
                            l_stub_days := i;
                        ELSE
                            l_stub_days := l_payment_struc(j).rule_information7;
                        END IF;
                        l_end_date := get_final_end_date(
                        p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        ,p_stub_days  => l_stub_days
                        ,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        ,p_period     => i);
                        IF l_stub_pymnt = 'Y' THEN
                            l_upper_stub_days := i;
                        ELSE
                            l_upper_period := i;
                        END IF;
                        IF l_end_date >= p_ppd_date THEN --[8]
                            IF l_stub_pymnt = 'Y' THEN
                                l_lower_stub_days := l_payment_struc(j).rule_information7 - l_upper_stub_days;
                            ELSE
                                l_lower_period := l_payment_struc(j).rule_information3 - l_upper_period ;
                            END IF;
			    --Check for Adv/arrears and split accordingly.
		            IF l_payment_struc(j).rule_information10 = 'Y' THEN --Arrear payment
				IF l_stub_pymnt = 'Y' THEN
					l_upper_stub_days := l_upper_stub_days - 1;
					l_lower_stub_days := l_lower_stub_days + 1;
				ELSE
					l_upper_period := l_upper_period -1;
					l_lower_period := l_lower_period +1;
				END IF;
				--recalculate the end days.
                        	l_end_date := get_final_end_date(
                        		p_start_date => l_payment_struc(j).RULE_INFORMATION2
                        		,p_stub_days  => l_upper_stub_days
                        		,p_frequency  => l_payment_struc(j).OBJECT1_ID1
                        		,p_period     => l_upper_period);
			    END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         			    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Lower Period is :' || l_lower_period);
  			    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Upper Period is :' || l_upper_period);
       END IF;
                            EXIT;
                        END IF; --[8]
                    END LOOP;
                      l_modified_payments(k) :=  l_payment_struc(j);
                      IF l_stub_pymnt = 'N' THEN
                         l_modified_payments(k).rule_information3 := l_upper_period; --SEt the period
                      ELSE
                         l_modified_payments(k).rule_information7 := l_upper_stub_days; --Set the stub days
                      END IF;
                      k := K+1;
                      --For the second part of the split payment
                      l_modified_payments(k) :=  l_payment_struc(j);
                      --l_modified_payments(k).RULE_INFORMATION2 := to_date(l_end_date +1);
                      l_modified_payments(k).RULE_INFORMATION2 := FND_DATE.date_to_canonical(l_end_date +1);
                      IF l_stub_pymnt = 'N' THEN --[9]
                        l_modified_payments(k).rule_information3 := l_lower_period;

                        --dkagrawa modified the logic to calculate the amount for bug#5203265
                        --l_amount  := l_ppd_amount/l_lower_period;
                        l_amount := l_modified_payments(k).rule_information6 - (l_ppd_for_asset*l_modified_payments(k).rule_information6/l_total_princ_balance);
                        l_modified_payments(k).rule_information6 := l_amount;

                    ELSE --[9]
                        l_modified_payments(k).rule_information7 := l_lower_stub_days;
                        --how do we modfiy stib amounts? Need to verify
                        l_modified_payments(k).rule_information8 := l_payment_struc(j).rule_information8;

                    END IF;                        --[9]
                    k := k+1;
                ELSE --[7]
                    l_modified_payments(k) :=  l_payment_struc(j);
                    IF   l_payment_struc(j).rule_information7 <> 0 THEN
                        l_modified_payments(k).rule_information8 := 0;
            	    ELSE
	               --dkagrawa modified the logic to calculate the amount for bug#5203265
                        l_amount := l_modified_payments(k).rule_information6 - (l_ppd_for_asset*l_modified_payments(k).rule_information6/l_total_princ_balance);
                        l_modified_payments(k).rule_information6 := l_amount;
	                --l_modified_payments(k).rule_information6 := l_payment_struc(j).rule_information6; --Set amount to Zero
                     END IF;
                     k := k+ 1;
                 END IF; --[7]
            ELSE  --[6]
                l_modified_payments(k) :=  l_payment_struc(j);
                k := k+ 1;
            END IF; --[6]
	ELSE --[5]
	    l_modified_payments(k) :=  l_payment_struc(j);
            k := k+ 1;
	END IF; --[5]
    END IF; --[4]

   EXIT WHEN j = l_payment_struc.LAST;
        j := l_payment_struc.NEXT(j);
   END LOOP;
  END IF;


  -- set the return status and out variables
  x_modified_payment_struc := l_modified_payments;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.modify_payments'
                                                                        ,'End(-)');
  END IF;
END Modify_Principal_Payments;



PROCEDURE delete_payments(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_request_id            IN  NUMBER)
AS


   SUBTYPE cafv_rec_type IS okl_cash_flows_pub.cafv_rec_type;
   SUBTYPE cflv_rec_type IS okl_cash_flow_levels_pub.cflv_rec_type;

    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'delete_payments';
    lp_cafv_rec                  cafv_rec_type;
    lp_cflv_rec                  cflv_rec_type;
    l_caf_id                     NUMBER;
    l_cfo_id                     NUMBER;



    CURSOR l_cfo_id_csr(cp_request_id IN NUMBER) IS
    SELECT id
    FROM OKL_CASH_FLOW_OBJECTS
    WHERE source_id = cp_request_id;


    CURSOR l_caf_id_csr(cp_request_id IN NUMBER
                        ,cp_cfo_id  IN  NUMBER) IS
    SELECT id
    FROM OKL_CASH_FLOWS
    WHERE cfo_id=cp_cfo_id
    AND dnz_qte_id=cp_request_id;

    CURSOR l_cfl_id_csr(cp_caf_id  IN  NUMBER) IS
    SELECT id
    FROM OKL_CASH_FLOW_LEVELS
    WHERE caf_id=cp_caf_id;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments.',
              'p_request_id :'||p_request_id);
    END IF;
    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

    --Call start_activity to create savepoint,
    --check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Get the CFO Id for the Request id
    FOR cfo_rec IN l_cfo_id_csr(p_request_id) LOOP

        l_cfo_id := cfo_rec.id;

        FOR caf_rec IN l_caf_id_csr(p_request_id,l_cfo_id) LOOP

            l_caf_id := caf_rec.id;
            FOR cfl_rec IN l_cfl_id_csr(l_caf_id) LOOP

                lp_cflv_rec.id := cfl_rec.id;
                --Delete all the Cash flow levels for this Cash flow.
                 OKL_CASH_FLOW_LEVELS_PUB.delete_cash_flow_level(
                            p_api_version              =>    p_api_version,
                            p_init_msg_list            =>    OKL_API.G_FALSE,
                            x_return_status            =>    l_return_status,
                            x_msg_count                =>    x_msg_count,
                            x_msg_data                 =>    x_msg_data,
                            p_cflv_rec                 =>    lp_cflv_rec);

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Deleting  CFL - Return Status: ' || l_return_status);
                  END IF;
                  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
            END LOOP;
            --Delete all the Cashflows for this Request.
            lp_cafv_rec.id := l_caf_id;
             okl_cash_flows_pub.delete_cash_flow(
                    p_api_version              =>    p_api_version,
                    p_init_msg_list            =>    OKL_API.G_FALSE,
                    x_return_status            =>    l_return_status,
                    x_msg_count                =>    x_msg_count,
                    x_msg_data                 =>    x_msg_data,
                    p_cafv_rec                 =>    lp_cafv_rec);
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Deleting  CAF - Return Status: ' || l_return_status);
              END IF;
              IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
        END LOOP;
    END LOOP;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments','End(-)');
    END IF;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.delete_payments ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END delete_payments;

--*****************************************************88

--Call the extraction API to extract info for the working copy.
-- Populate the parameters, i.e Tweak with the output params....

--*****************************************************88
   PROCEDURE calculate(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_trqv_tbl              IN okl_trx_requests_pub.trqv_tbl_type,
                x_trqv_tbl              OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type)
  AS
	l_api_name          		CONSTANT VARCHAR2(30) := 'CALCULATE';
	p_chr_id	    		NUMBER;
	l_trans_id	    		NUMBER;
	l_trans_status	    		VARCHAR2(100);
	l_trqv_tbl          		okl_trx_requests_pub.trqv_tbl_type;
	l_upd_trqv_tbl          	okl_trx_requests_pub.trqv_tbl_type;
    l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
    lx_trqv_rec         okl_trx_requests_pub.trqv_rec_type;
        l_prim_sty_id                   NUMBER;

	l_skip_prc_engine               VARCHAR2(1) := OKL_API.G_FALSE;
	l_csm_loan_header               okl_create_streams_pvt.csm_loan_rec_type;
	l_csm_loan_lines_tbl            okl_create_streams_pvt.csm_loan_line_tbl_type;
	l_csm_loan_levels_tbl           okl_create_streams_pvt.csm_loan_level_tbl_type;
	l_csm_one_off_fee_tbl           okl_create_streams_pub.csm_one_off_fee_tbl_type;
	l_csm_periodic_expenses_tbl     okl_create_streams_pub.csm_periodic_expenses_tbl_type;
	l_csm_yields_tbl                okl_create_streams_pub.csm_yields_tbl_type;
	l_csm_stream_types_tbl          okl_create_streams_pub.csm_stream_types_tbl_type;

     	l_rents_tbl                	Okl_Create_Streams_Pub.csm_periodic_expenses_tbl_type;
     	l_reduce_residual_ptg_by    	NUMBER;
	l_amount             		NUMBER := 0;
      	l_principal_amount              NUMBER := 0;
      	l_principal_balance              NUMBER := 0;
      	l_acc_int              		NUMBER := 0;
      	l_iir 				NUMBER;
      	l_line_iir 			NUMBER;
      	l_payments_remaining 		NUMBER;
	l_pricing_engine   		VARCHAR2(100);
        l_primary_strm_type             VARCHAR2(80);

	l_line_id 			NUMBER;
	l_frequency 			VARCHAR2(50);
	l_arrears_yn 			VARCHAR2(50);
      	l_new_payment_amount 		NUMBER;
	l_payment_struc			okl_mass_rebook_pvt.strm_lalevl_tbl_type;
	l_modified_payment_struc        okl_mass_rebook_pvt.strm_lalevl_tbl_type;
	lx_cfo_id 			NUMBER;
	knt 				NUMBER :=0;

    	l_total_ppd_to_date 		NUMBER;
    	l_asset_amount 			NUMBER;
    	l_total_k_cost 			NUMBER;
    	l_asset_cost 			NUMBER;
        l_raw_ppd_for_asset			NUMBER;
        l_ppd_for_asset			NUMBER;
        l_ppd_funding 			NUMBER;
	l_total_princ_balance		NUMBER;
        l_raw_ppd_amount 			NUMBER;
        l_ppd_amount 			NUMBER;
        p        			NUMBER;
        q        			NUMBER :=0;
	l_pay_level			okl_pricing_pvt.payment_tbl_type;
	lx_pay_level			okl_pricing_pvt.payment_tbl_type;
	l_payments_tbl			payment_tbl_type;
	l_rent_sty_id			NUMBER;
	l_upp_sty_id 			NUMBER;
	l_currency_code			VARCHAR2(30);
        l_balance_type                  VARCHAR2(100);

	l_freq 				VARCHAR2(50);
	l_arr 				VARCHAR2(50);
	l_days_to_reduce 		NUMBER;
	l_index                         NUMBER;
        l_sum_ppd_amount                NUMBER := 0;




        CURSOR c_get_iir (c_khr_id NUMBER)
        IS
        SELECT implicit_interest_rate
        FROM okl_k_headers
        where id = c_khr_id;

        CURSOR c_get_line_iir (c_line_id NUMBER)
        IS
        SELECT implicit_interest_rate
        FROM okl_k_lines
        where id = c_line_id;

        CURSOR c_get_total_ppd (c_cle_id NUMBER
			       ,c_sty_id NUMBER)
	IS
	SELECT  sum(sll_rul.rule_information8)
    	FROM okc_rules_b sll_rul,
        	okl_strmtyp_source_v sttyp,
        	okc_rules_b slh_rul,
        	okc_rule_groups_b rgp
    	WHERE   sll_rul.object2_id1 = to_char(slh_rul.id)
    	AND     sll_rul.rgp_id    = rgp.id
    	AND     sll_rul.rule_information_category = 'LASLL'
    	AND     sttyp.id1 = slh_rul.object1_id1
    	AND     slh_rul.rgp_id = rgp.id
    	AND     slh_rul.rule_information_category = 'LASLH'
    	AND     rgp.rgd_code = 'LALEVL'
    	AND     rgp.cle_id = c_cle_id
    	AND     sttyp.id1 = c_sty_id;

	CURSOR c_get_payment_details (c_req_id NUMBER
				     ,c_kle_id NUMBER
				     ,c_sty_id NUMBER)
	IS
	SELECT KLE_ID
	      ,NUMBER_OF_PERIODS
              ,amount
              ,frequency_code
              ,decode(arrears,'N','ADVANCE','ARREARS') advance_or_arrears
	      ,start_date
              ,stub_days
              ,stub_amount
              ,advance_payments
	FROM okl_cs_ppd_payments_uv
	WHERE request_id = c_req_id
	AND kle_id=c_kle_id
	AND sty_id= c_sty_id
	ORDER BY start_date;

    	CURSOR l_okcklines_csr(cp_chr_id IN NUMBER) IS
    	SELECT cle.id kle_id
    	FROM   okc_k_lines_b cle, okc_line_styles_b lse
    	WHERE  cle.lse_id = lse.id
    	AND    cle.sts_code = 'BOOKED'
    	AND    lse.lty_code = 'FREE_FORM1'
    	AND    chr_id = cp_chr_id;

        CURSOR c_get_future_pay_details (c_req_id NUMBER
                                     ,c_kle_id NUMBER
				     ,c_start_date DATE
				     ,c_sty_id NUMBER)
        IS
        SELECT KLE_ID
	      ,START_DATE
              ,NUMBER_OF_PERIODS
              ,frequency_code
	      ,ADVANCE_PAYMENTS
              ,arrears
              ,amount
	      ,stub_days
	      ,stub_amount
        FROM okl_cs_ppd_payments_uv
        WHERE request_id = c_req_id
        AND kle_id=c_kle_id
	and start_date > c_start_date
	AND sty_id = c_sty_id
        ORDER BY start_date;


    	CURSOR c_get_cur(cp_khr_id IN NUMBER) IS
    	SELECT currency_code
    	FROM   okc_k_headers_b
    	WHERE  id = cp_khr_id;

	CURSOR c_get_freq_arr (c_req_id NUMBER
			     ,c_kle_id NUMBER
			     ,c_rent_sty_id NUMBER)
	IS
	SELECT distinct
              frequency_code
              ,arrears
	       ,DECODE(frequency_code,'M',30,'Q',90,'S',180,'A',360)
	FROM okl_cs_ppd_payments_uv
	WHERE request_id = c_req_id
	AND kle_id=c_kle_id
	AND sty_id=c_rent_sty_id
	AND stub_days is null;

	-- added for ppd bug #6657481 ansethur
	CURSOR c_get_object_ver (c_trq_id NUMBER)
	is
	select object_version_number
	from OKL_TRX_REQUESTS
	where id = c_trq_id ;
	l_object_version_number number ;

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;
        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        p_chr_id := p_trqv_tbl(1).dnz_khr_id;
	--Commented for 11i10+.
	--We will not be using parent_khr_id
	--p_parent_chr_id := p_trqv_tbl(1).parent_khr_id;
        --Get the Rate

        open c_get_iir(p_chr_id);
        fetch c_get_iir into l_iir;
        close c_get_iir;

        open c_get_cur(p_chr_id);
        fetch c_get_cur into l_currency_code;
        close c_get_cur;

	OKL_STREAM_GENERATOR_PVT.get_sched_principal_bal(
                                         p_api_version  => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         p_khr_id        => p_chr_id,
                                         p_kle_id        => NULL,
                                         p_date          => p_trqv_tbl(1).payment_date,
                                         x_principal_balance => l_principal_balance,
                                         x_accumulated_int => l_acc_int,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_sched_principal_bal  : ' || l_payment_struc.count);
  END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
	l_principal_amount := l_principal_balance + l_acc_int ;
	l_amount:=  (nvl(l_principal_amount,0) - nvl(p_trqv_tbl(1).payment_amount,0));


        OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => 'CONTRACT_CAP_AMNT',
                                        p_contract_id   => p_chr_id,
                                        p_line_id       => NULL,
                                        x_value         => l_total_k_cost);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute CONTRACT_CAP_AMNT: '|| l_total_k_cost || x_return_status);
                        END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


	IF p_trqv_tbl(1).id IS NULL THEN
		-- Call the public API for insertion here.
		  okl_trx_requests_pub.insert_trx_requests(
                                     	      	p_api_version  	      => p_api_version,
	       		                      	p_init_msg_list       =>p_init_msg_list,
                 		              	x_return_status       => x_return_status,
                                		x_msg_count           => x_msg_count,
						x_msg_data            => x_msg_data,
                                		p_trqv_tbl            => p_trqv_tbl,
                                		x_trqv_tbl            => x_trqv_tbl);

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Insert Request:'|| x_return_status);
                     END IF;

	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            		RAISE OKL_API.G_EXCEPTION_ERROR;
          	  END IF;
	ELSE
		l_upd_trqv_tbl	:=	p_trqv_tbl;

		--Reset the params before calling the API
		    l_upd_trqv_tbl(1).amount := NULL;
		    l_upd_trqv_tbl(1).request_status_code := 'ENTERED';


		--Call update here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_upd_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);
                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Update Request:'|| x_return_status);
                     END IF;

	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_ERROR;
	          END IF;
		 --Delete all the payments for this request.
                  delete_payments(
                                  p_api_version         => p_api_version,
                                  p_init_msg_list       =>p_init_msg_list,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data,
                                  p_request_id          => p_trqv_tbl(1).id);
                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Delete PAyments:'|| x_return_status);
                     END IF;
	          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	             RAISE OKL_API.G_EXCEPTION_ERROR;
	          END IF;

	END IF;

   	--get the sty id for rent.
        OKL_STREAMS_UTIL.get_primary_stream_type
                (p_khr_id => p_chr_id
                ,p_primary_sty_purpose => G_RENT_STREAM
                ,x_return_status    => x_return_status
                ,x_primary_sty_id   => l_rent_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Get primary strm type ' || x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Get the Stream type id.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_chr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
        END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        	RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	OKL_STREAMS_UTIL.get_pricing_engine(
		p_khr_id			=> p_chr_id
		,x_pricing_engine		=> l_pricing_engine
		,x_return_status		=> x_return_status);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Pricing Engine is : ' || l_pricing_engine
			|| ' API return status: '|| x_return_status);
 END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    	IF l_pricing_engine = 'INTERNAL' THEN
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Using ISG for Pricing');
  END IF;
		--get_payments for this contract
                --Get the Existing payments from SLL/SLH
                get_current_payments(p_khr_id    => p_chr_id,
                             x_payment_struc     => l_payment_struc,
                             x_prim_sty_id       => l_prim_sty_id,
                             x_upp_sty_id        => l_upp_sty_id,
                             x_primary_strm_type => l_primary_strm_type);

                --Tweak these payments to split them based on the PPd date
		--modify_payments for this contract
                modify_payments( p_payment_struc  => l_payment_struc
                                ,p_ppd_date => x_trqv_tbl(1).payment_date
                                ,p_blank_amount => 'N'
				,p_rent_sty_id => l_rent_sty_id
                                ,x_modified_payment_struc  => l_modified_payment_struc);
                --Store this whole lot of payments in Payment Schema.
               store_payments(p_api_version  => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ppd_request_id => x_trqv_tbl(1).id,
                              p_ppd_khr_id     => p_chr_id,
                              p_payment_structure => l_modified_payment_struc,
                              x_cfo_id         => lx_cfo_id);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Store payments in ISG pricing:' || x_return_status
				|| 'CFO Id: '|| lx_cfo_id);
  END IF;

		--Get the Lines for this K
		FOR l_okcklines_rec IN l_okcklines_csr(p_chr_id) LOOP

			OKL_EXECUTE_FORMULA_PUB.execute(p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => 'LINE_CAP_AMNT',
                                        p_contract_id   => p_chr_id,
                                        p_line_id       => l_okcklines_rec.kle_id,
                                        x_value         => l_asset_cost);

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute LINE_CAP_AMNT: '|| l_asset_cost);
                        END IF;
                        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                        	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                        	raise OKC_API.G_EXCEPTION_ERROR;
			End If;

			--Pro rate the ppd amt for this line
			l_raw_ppd_for_asset := (l_asset_cost/l_total_k_cost)
							* x_trqv_tbl(1).payment_amount;

                        l_ppd_for_asset := Okl_Accounting_Util.ROUND_AMOUNT(
                                		p_amount => l_raw_ppd_for_asset,
                                		p_currency_code => l_currency_code);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PPD for Asset : '|| l_ppd_for_asset);
                        END IF;

        		OKL_STREAM_GENERATOR_PVT.get_sched_principal_bal(
                                         p_api_version  => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         p_khr_id        => p_chr_id,
                                         p_kle_id        => l_okcklines_rec.kle_id,
                                         p_date          => p_trqv_tbl(1).payment_date,
                                         x_principal_balance => l_principal_balance,
                                         x_accumulated_int => l_acc_int,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data);

        		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        		ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_ERROR;
        		END IF;
        		l_total_princ_balance := l_principal_balance + l_acc_int ;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'total Principal Balance  : ' || l_total_princ_balance);
                 END IF;

			--PPD amount for the asset = Principal Balance on asset
			--				- Pro rated ppd for this asset.
			l_raw_ppd_amount := nvl(l_total_princ_balance,0) - nvl(l_ppd_for_asset,0);
                        l_ppd_amount := Okl_Accounting_Util.ROUND_AMOUNT(
                                		p_amount => l_raw_ppd_amount,
                                		p_currency_code => l_currency_code);

			--Get the iir for this line
			OPEN c_get_line_iir(l_okcklines_rec.kle_id);
			FETCH c_get_line_iir INTO l_line_iir;
			CLOSE c_get_line_iir;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PPD Amount to Pricing : '|| l_ppd_amount);
                        END IF;

			p := 0;


			--For Arrear payments the query for c_get_future_pay_details
			--would not fetch any rows, so we need to calculate the
			--no.of days to reach a prior period.

			OPEN c_get_freq_arr(x_trqv_tbl(1).id
					   ,l_okcklines_rec.kle_id
					   ,l_rent_sty_id);
			FETCH c_get_freq_arr INTO l_freq,l_arr,l_days_to_reduce;
			CLOSE c_get_freq_arr;

			IF l_arr <> 'Y' THEN
				l_days_to_reduce := 0;
			END IF;
			--Get the modified payments that we just stored for this asset.

                       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_trqv_tbl(1).id :'|| x_trqv_tbl(1).id);
                         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_okcklines_rec.kle_id :'|| l_okcklines_rec.kle_id);
                         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_trqv_tbl(1).payment_date :'|| x_trqv_tbl(1).payment_date);
                         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'days_to_reduce :'|| l_days_to_reduce);
                         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rent_sty_id :'|| l_rent_sty_id);
                       END IF;
                        FOR cur_rec in c_get_future_pay_details(x_trqv_tbl(1).id
                                                        ,l_okcklines_rec.kle_id
							,(p_trqv_tbl(1).payment_date - l_days_to_reduce)
							,l_rent_sty_id) LOOP
                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In get_future_pay_details csr');
                         END IF;
				p:=  p+1;
				l_pay_level(p).start_date    := cur_rec.start_date;
				l_pay_level(p).periods       := cur_rec.number_of_periods;
				l_pay_level(p).frequency     := cur_rec.frequency_code;
				l_pay_level(p).structure     := cur_rec.advance_payments;
				l_pay_level(p).arrears_yn    := cur_rec.arrears;
				l_pay_level(p).amount        := cur_rec.amount;
				l_pay_level(p).stub_days     := cur_rec.stub_days;
				l_pay_level(p).stub_amount   := cur_rec.stub_amount;
                        END LOOP;

			--call the pricing api.
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_kle_id: ' || l_okcklines_rec.kle_id);
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_ppd_amount: ' || l_ppd_amount);
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_rate: ' || l_line_iir);
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_ppd_date: ' ||x_trqv_tbl(1).payment_date);
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Printing l_pay_level');
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====================');
                        END IF;
			print_isg_params(l_pay_level);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Calling the Pricing API');
                        END IF;
			okl_pricing_pvt.get_payment_after_ppd( p_api_version        => p_api_version,
                              			       p_init_msg_list       => p_init_msg_list,
                                                       x_return_status       => x_return_status,
                                                       x_msg_count           => x_msg_count,
                                                       x_msg_data            => x_msg_data,
                                                       p_khr_id              => p_chr_id,
                                                       p_kle_id              => l_okcklines_rec.kle_id,
                          			       p_ppd_amt             => l_ppd_amount,
                          			       p_rate                => l_line_iir,
                          			       p_ppd_date            => x_trqv_tbl(1).payment_date,
						       p_pay_level	     => l_pay_level,
						       x_pay_level	     => lx_pay_level);

               		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               		ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         	RAISE OKL_API.G_EXCEPTION_ERROR;
               		END IF;

			--collect the out param.
			--Build the pl/sql table of all payments
			FOR pay_knt in lx_pay_level.FIRST..lx_pay_level.LAST LOOP
			    q := q+1;
			    l_payments_tbl(q).KHR_ID     := p_chr_id;
			    l_payments_tbl(q).KLE_ID     := l_okcklines_rec.kle_id;
			    l_payments_tbl(q).STY_ID     := l_rent_sty_id;
			    l_payments_tbl(q).start_date := lx_pay_level(pay_knt).start_date;
			    l_payments_tbl(q).structure  := lx_pay_level(pay_knt).structure;
			    l_payments_tbl(q).arrears_yn := lx_pay_level(pay_knt).arrears_yn;
			    l_payments_tbl(q).periods    := lx_pay_level(pay_knt).periods;
			    l_payments_tbl(q).frequency  :=lx_pay_level(pay_knt).frequency;
			    l_payments_tbl(q).amount     := lx_pay_level(pay_knt).amount;
			    l_payments_tbl(q).stub_days  := lx_pay_level(pay_knt).stub_days;
			    l_payments_tbl(q).stub_amount:= lx_pay_level(pay_knt).stub_amount;
			END LOOP;
			--Now populate the l_payments_tbl with the UNSCHEDULED_PRINCIPAL_PAYMENT
			--to account for this ppd.
			q := q+1;
			l_payments_tbl(q).KHR_ID     := p_chr_id;
			l_payments_tbl(q).KLE_ID     := l_okcklines_rec.kle_id;
			l_payments_tbl(q).STY_ID     := l_upp_sty_id;
			l_payments_tbl(q).start_date := x_trqv_tbl(1).payment_date;
			l_payments_tbl(q).stub_days  := 1;
			l_payments_tbl(q).stub_amount:= l_ppd_for_asset;
			--Bug#5511937 by dkagrawa start
                        l_index := q;
                        l_sum_ppd_amount := l_sum_ppd_amount + l_ppd_for_asset;
                        --Bug#5511937 end
		END LOOP;
                --Bug#5332964 by dkagrawa start
                IF ( x_trqv_tbl(1).payment_amount - l_sum_ppd_amount <> 0 ) THEN
                  l_payments_tbl(l_index).stub_amount := l_payments_tbl(l_index).stub_amount + (x_trqv_tbl(1).payment_amount - l_sum_ppd_amount );
                END IF;
                --Bug#5332964 end
		--Store this at one time.
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Printing l_payments_tbl');
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====================');
                        END IF;
			print_stm_payments(l_payments_tbl);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'calling the Store stm API');
                        END IF;
		store_stm_payments(p_api_version  => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ppd_request_id => x_trqv_tbl(1).id,
                              p_ppd_khr_id     => p_chr_id,
                              p_payment_tbl 	=> l_payments_tbl,
                              x_cfo_id         => lx_cfo_id);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Store stm payments in ISG pricing:' || x_return_status
				|| 'CFO Id: '|| lx_cfo_id);
  END IF;
               	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                       	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                       	RAISE OKL_API.G_EXCEPTION_ERROR;
               	END IF;

	        IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
                        l_trqv_tbl(1).id := x_trqv_tbl(1).id;
                        l_trqv_tbl(1).object_version_number := x_trqv_tbl(1).object_version_number;
                        l_trqv_tbl(1).request_status_code := 'COMPLETE';
                        --Call update here.
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updating TRX Requests');
                        END IF;
                        okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Updating trx request to Complete in ISG pricing:'
				|| x_return_status );
   END IF;

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
		END IF;



	ELSE
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'======Using ESG for Pricing========');
  END IF;
	--External stream generation from here.
       		--Send the Request to Supertrump only if the amount is not Zero.
	       -- If it is Zero we are updating the payment amount to 0 and setting
	       -- the status of request to Complete.
      		IF l_amount = 0 THEN
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'New Prin balance is Zero');
   END IF;
			l_trqv_tbl(1).id := x_trqv_tbl(1).id;
	       		l_trqv_tbl(1).object_version_number := x_trqv_tbl(1).object_version_number;
			l_trqv_tbl(1).amount := 0;
			l_trqv_tbl(1).request_status_code := 'COMPLETE';
                	--Call update here.
                  	okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);

                  	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_ERROR;
                  	END IF;

      		ELSE
     		--NEW Principal Balance is not Zero

            	--Get the Existing payments from SLL/SLH
	        get_current_payments(p_khr_id => p_chr_id,
                                     x_payment_struc => l_payment_struc,
                                     x_prim_sty_id       => l_prim_sty_id,
                                     x_upp_sty_id        => l_upp_sty_id,
                                     x_primary_strm_type => l_primary_strm_type);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_current_payments payments count is : ' || l_payment_struc.count);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Total Contract cost '||l_total_k_cost);
  END IF;

       --rkuttiya added for 11i OKL.H Variable Rate Project
       --check for the Principal Payment Stream and Solve for Payment option
            IF l_primary_strm_type = 'PRINCIPAL_PAYMENT' AND x_trqv_tbl(1).method_of_calculation_code = 'P' THEN
                 modify_principal_payments(
                       p_payment_struc         => l_payment_struc,
                       p_chr_id                => x_trqv_tbl(1).dnz_khr_id,
                       p_ppd_date	       => x_trqv_tbl(1).payment_date,
                       p_ppd_amount	       => x_trqv_tbl(1).payment_amount,
                       p_total_k_cost          => l_total_k_cost,
                       p_sty_id	               => l_prim_sty_id,
                       p_upp_sty_id            => l_upp_sty_id,
                       x_modified_payment_struc => l_modified_payment_struc);

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After modifying principal payments count is : ' || l_modified_payment_struc.count);
END IF;


                 store_principal_payments(p_api_version  => p_api_version,
	                      p_init_msg_list => p_init_msg_list,
			      x_return_status => x_return_status,
			      x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ppd_request_id => x_trqv_tbl(1).id,
                              p_ppd_khr_id     => p_chr_id,
                              p_payment_structure => l_modified_payment_struc,
                              x_cfo_id         => lx_cfo_id);

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After storing principal payments'|| x_return_status);
           END IF;

                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_ERROR;
                  	END IF;

                    --Update the Request with the status of complete.
                        l_trqv_tbl(1).id := x_trqv_tbl(1).id;
                        l_trqv_tbl(1).object_version_number := x_trqv_tbl(1).object_version_number;

                        l_trqv_tbl(1).request_status_code := 'COMPLETE';

                        --Call update here.
                        okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);

               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after updating request status '|| x_return_Status);
               END IF;
                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;


           ELSE
              IF (l_primary_strm_type = 'RENT' AND x_trqv_tbl(1).method_of_calculation_code = 'P') THEN
            	--Tweak these payments to split them based on the PPd date
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ppd_date : ' ||  x_trqv_tbl(1).payment_date);
  END IF;
		--For ESG also we will not be setting the payments to be
		--calculated as Zero, they will be sent as they are so that
		--the proportions can be calculated.

		modify_payments( p_payment_struc  => l_payment_struc
				,p_ppd_date => x_trqv_tbl(1).payment_date
				,p_blank_amount => 'NEGATE'
				,p_rent_sty_id => l_rent_sty_id
    				,x_modified_payment_struc  => l_modified_payment_struc);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After modifying payments count is : ' || l_modified_payment_struc.count);
  END IF;

          	--Store this whole lot of payments in Payment Schema.
	       store_payments(p_api_version  => p_api_version,
	                      p_init_msg_list => p_init_msg_list,
			      x_return_status => x_return_status,
			      x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ppd_request_id => x_trqv_tbl(1).id,
                              p_ppd_khr_id     => p_chr_id,
                              p_payment_structure => l_modified_payment_struc,
                              x_cfo_id         => lx_cfo_id);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After store payments cfo id is : ' || lx_cfo_id || ' ret status is: '|| x_return_status);
  END IF;

     		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		    	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            		RAISE OKL_API.G_EXCEPTION_ERROR;
          	END IF;
         ELSIF x_trqv_tbl(1).method_of_calculation_code = 'T' THEN
          modify_terms(  p_payment_struc         => l_payment_struc,
                       p_chr_id                => x_trqv_tbl(1).dnz_khr_id,
                       p_ppd_date	       => x_trqv_tbl(1).payment_date,
                       p_ppd_amount	       => x_trqv_tbl(1).payment_amount,
                       p_total_k_cost          => l_total_k_cost,
                       p_sty_id	               => l_prim_sty_id,
                       p_upp_sty_id            => l_upp_sty_id,
                       x_modified_payment_struc => l_modified_payment_struc);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After modifying payments count is : ' || l_modified_payment_struc.count);
  END IF;

          	--Store this whole lot of payments in Payment Schema.
	       store_payments(p_api_version  => p_api_version,
	                      p_init_msg_list => p_init_msg_list,
			      x_return_status => x_return_status,
			      x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_ppd_request_id => x_trqv_tbl(1).id,
                              p_ppd_khr_id     => p_chr_id,
                              p_payment_structure => l_modified_payment_struc,
                              x_cfo_id         => lx_cfo_id);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After store payments cfo id is : ' || lx_cfo_id || ' ret status is: '|| x_return_status);
  END IF;
     		IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		    	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            		RAISE OKL_API.G_EXCEPTION_ERROR;
          	END IF;

         END IF;


--rkuttiya commenting following code for 11i OKL.H Variable Rate Project
--API name has changed from extract_params loan to extract_params_loan_paydown
              /*  -Call the Extract params API
    			OKL_LA_STREAM_PUB.extract_params_loan(p_api_version               => p_api_version,
	               				                p_init_msg_list             => p_init_msg_list,
								p_chr_id                    => p_chr_id,
								x_return_status             => x_return_status,
								x_msg_count                 => x_msg_count,
                                        			x_msg_data                  => x_msg_data,
								x_csm_loan_header           => l_csm_loan_header,
								x_csm_loan_lines_tbl        => l_csm_loan_lines_tbl,
								x_csm_loan_levels_tbl       => l_csm_loan_levels_tbl,
								x_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
								x_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
								x_csm_yields_tbl            => l_csm_yields_tbl,
								x_csm_stream_types_tbl      => l_csm_stream_types_tbl);*/



--rkuttiya added the following for 11i OKL.H Variable Rate

  -- Get the Balance type code
     IF x_trqv_tbl(1).method_of_calculation_code = 'T' THEN
       l_balance_type := 'BALANCE_TERM';
     ELSIF x_trqv_tbl(1).method_of_calculation_code = 'P' THEN
       l_balance_type := 'BALANCE_PAYMENT';
     END IF;

            	--Call the Extract params API
    			OKL_LA_STREAM_PUB.extract_params_loan_paydown(p_api_version         => p_api_version,
	               				                p_init_msg_list             => p_init_msg_list,
								p_chr_id                    => p_chr_id,
                                                                p_deal_type                 => NULL,
                                                                p_paydown_type              => 'PPD',
                                                                p_paydown_date              => x_trqv_tbl(1).payment_date,
                                                                p_paydown_amount            => x_trqv_tbl(1).payment_amount,
                                                                --p_balance_type_code         => NULL,
								p_balance_type_code         => l_balance_type,     --Bug#5100215
                                                                x_return_status             => x_return_status,
								x_msg_count                 => x_msg_count,
                                        			x_msg_data                  => x_msg_data,
								x_csm_loan_header           => l_csm_loan_header,
								x_csm_loan_lines_tbl        => l_csm_loan_lines_tbl,
								x_csm_loan_levels_tbl       => l_csm_loan_levels_tbl,
								x_csm_one_off_fee_tbl       => l_csm_one_off_fee_tbl,
								x_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
								x_csm_yields_tbl            => l_csm_yields_tbl,
								x_csm_stream_types_tbl      => l_csm_stream_types_tbl);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After extract params loan: '|| x_return_status);
   END IF;
			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            			RAISE OKL_API.G_EXCEPTION_ERROR;
          	  	END IF;

--rkuttiya commenting following lines of code for 11i OKL.H Variable Rate

/*
	        --Get the Stream type id.
        		OKL_STREAMS_UTIL.get_dependent_stream_type(
                        	p_khr_id                        => p_chr_id
                        	,p_primary_sty_purpose          => G_RENT_STREAM
                        	,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                        	,x_return_status                => x_return_status
                        	,x_dependent_sty_id             => l_upp_sty_id);

			print_to_log('After get_depend_stream type: '|| x_return_status);
			print_to_log('Rent Sty ID : ' || l_rent_sty_id);
			print_to_log('Unsched Prin Pay Sty ID : ' || l_upp_sty_id);

		        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        		ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                		RAISE OKL_API.G_EXCEPTION_ERROR;
        		END IF;
*/

            	--Modify the x_csm_loan_header and x_csm_loan_levels_tbl
        		l_csm_loan_header.jtot_object1_code := 'OKL_TRX_REQUESTS';
        		l_csm_loan_header.object1_id1 :=  x_trqv_tbl(1).id;

--rkuttiya commenting following lines of code for 11i OKL.H PPD Impacts of Variable Rate
/*        		l_csm_loan_header.orp_code := OKL_CREATE_STREAMS_PUB.G_ORP_CODE_RENEWAL;

			l_csm_loan_levels_tbl.delete;

			FOR i in 1..l_csm_loan_lines_tbl.COUNT LOOP
				knt := knt+1;
				l_index		:= 1;

    				OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                  	p_init_msg_list => p_init_msg_list,
                                  	x_return_status => x_return_status,
                                  	x_msg_count     => x_msg_count,
                                  	x_msg_data      => x_msg_data,
                                  	p_formula_name  => 'LINE_CAP_AMNT',
                                  	p_contract_id   => p_chr_id,
                                  	p_line_id       => l_csm_loan_lines_tbl(i).kle_loan_id,
                                  	x_value         => l_asset_cost);

				print_to_log('Asset Cost After executing LINE_CAP_AMNT: '|| l_asset_cost);

   				If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
        				raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   				Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
         				raise OKC_API.G_EXCEPTION_ERROR;
   				End If;


				l_csm_loan_levels_tbl(knt).DESCRIPTION := 'Funding';
				l_csm_loan_levels_tbl(knt).date_start := l_csm_loan_header.date_start;
				l_csm_loan_levels_tbl(knt).kle_loan_id := l_csm_loan_lines_tbl(i).kle_loan_id;
				l_csm_loan_levels_tbl(knt).level_index_number := l_index;
				l_csm_loan_levels_tbl(knt).level_type := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_FUNDING;
				l_csm_loan_levels_tbl(knt).amount := l_asset_cost;
				l_csm_loan_levels_tbl(knt).lock_level_step := NULL;
				l_csm_loan_levels_tbl(knt).period := NULL;
				l_csm_loan_levels_tbl(knt).advance_or_arrears := NULL;
				l_csm_loan_levels_tbl(knt).income_or_expense := NULL;
				l_csm_loan_levels_tbl(knt).structure :=NULL;
				l_csm_loan_levels_tbl(knt).query_level_yn := NULL;

				--Now open a csr and get only the rent payments
				FOR cur_rec in  c_get_payment_details(x_trqv_tbl(1).id
							,l_csm_loan_lines_tbl(i).kle_loan_id
							,l_rent_sty_id) LOOP
					knt := knt+1;
					l_index := l_index + 1;
                                        IF cur_rec.stub_days IS NOT NULL
                                            AND cur_rec.stub_amount IS NOT NULL THEN
                                        	l_csm_loan_levels_tbl(knt).description := 'RENT';
                                        	l_csm_loan_levels_tbl(knt).date_start := cur_rec.start_date + cur_rec.stub_days;
                                        	l_csm_loan_levels_tbl(knt).kle_loan_id := l_csm_loan_lines_tbl(i).kle_loan_id;
                                        	l_csm_loan_levels_tbl(knt).level_index_number := l_index;
                                        	l_csm_loan_levels_tbl(knt).level_type := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
                                        	l_csm_loan_levels_tbl(knt).number_of_periods := 1;
   						--In the CASE of ESG, the amount to be calculated is negated.
						--We are doing this because, we need to figure out whether
						--to lock the amount or rate or both when,
   						--sending the params to Pricing using ESG. So, if the amount
						--is -ve, we lock the rate and set the amount back to positive,
						--if the amount is +ve,we lock Both and send the amount as is.

                                        	IF cur_rec.stub_amount > 0 THEN
                                                	l_csm_loan_levels_tbl(knt).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_BOTH;
                                        		l_csm_loan_levels_tbl(knt).amount := cur_rec.stub_amount;
                                        	ELSE
                                                	l_csm_loan_levels_tbl(knt).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_RATE;
                                        		l_csm_loan_levels_tbl(knt).amount := -1 * NVL(cur_rec.stub_amount,0);
                                        	END IF;
                                        	l_csm_loan_levels_tbl(knt).rate := l_iir;
                                        	l_csm_loan_levels_tbl(knt).period := 'T';
                                        	l_csm_loan_levels_tbl(knt).advance_or_arrears := cur_rec.advance_or_arrears;
                                        	l_csm_loan_levels_tbl(knt).income_or_expense := OKL_CREATE_STREAMS_PUB.G_INCOME;
                                        	l_csm_loan_levels_tbl(knt).structure := nvl(cur_rec.advance_payments,0);
                                        	l_csm_loan_levels_tbl(knt).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;
                 			ELSE
						l_csm_loan_levels_tbl(knt).description := 'RENT';
						l_csm_loan_levels_tbl(knt).date_start := cur_rec.start_date;
						l_csm_loan_levels_tbl(knt).kle_loan_id := l_csm_loan_lines_tbl(i).kle_loan_id;
						l_csm_loan_levels_tbl(knt).level_index_number := l_index;
						l_csm_loan_levels_tbl(knt).level_type := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
						l_csm_loan_levels_tbl(knt).number_of_periods := cur_rec.number_of_periods;
   						--In the CASE of ESG, the amount to be calculated is negated.
						--We are doing this because, we need to figure out whether
						--to lock the amount or rate or both when,
   						--sending the params to Pricing using ESG. So, if the amount
						--is -ve, we lock the rate and set the amount back to positive,
						--if the amount is +ve,we lock Both and send the amount as is.
						IF cur_rec.amount > 0 THEN
							l_csm_loan_levels_tbl(knt).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_BOTH;
							l_csm_loan_levels_tbl(knt).amount := cur_rec.amount;
						ELSE
							l_csm_loan_levels_tbl(knt).lock_level_step := Okl_Create_Streams_Pub.G_LOCK_RATE;
							l_csm_loan_levels_tbl(knt).amount := -1 * NVL(cur_rec.amount,0);
				 		END IF;
						l_csm_loan_levels_tbl(knt).rate := l_iir;
						l_csm_loan_levels_tbl(knt).period := cur_rec.frequency_code;
						l_csm_loan_levels_tbl(knt).advance_or_arrears := cur_rec.advance_or_arrears;
						l_csm_loan_levels_tbl(knt).income_or_expense := OKL_CREATE_STREAMS_PUB.G_INCOME;
						l_csm_loan_levels_tbl(knt).structure :=nvl(cur_rec.advance_payments,0);
						l_csm_loan_levels_tbl(knt).query_level_yn := Okl_Create_Streams_Pub.G_FND_YES;
                 			END IF;
				END LOOP;
				--Open the cursor and get the PPD payments that
				--have happenned before this PPD.

                               FOR cur_rec in c_get_payment_details(x_trqv_tbl(1).id
                                                        ,l_csm_loan_lines_tbl(i).kle_loan_id
                                                        ,l_upp_sty_id) LOOP
                                	knt := knt+1;
                                	l_index := l_index + 1;
					l_csm_loan_levels_tbl(knt).DESCRIPTION := 'Funding';
					l_csm_loan_levels_tbl(knt).date_start := cur_rec.start_date;
					l_csm_loan_levels_tbl(knt).kle_loan_id := l_csm_loan_lines_tbl(i).kle_loan_id;
					l_csm_loan_levels_tbl(knt).level_index_number := l_index;
					l_csm_loan_levels_tbl(knt).level_type := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_FUNDING;
					l_csm_loan_levels_tbl(knt).lock_level_step := NULL;
					l_csm_loan_levels_tbl(knt).period := NULL;
					l_csm_loan_levels_tbl(knt).advance_or_arrears := NULL;
					l_csm_loan_levels_tbl(knt).income_or_expense := NULL;
					l_csm_loan_levels_tbl(knt).structure :=NULL;
					l_csm_loan_levels_tbl(knt).query_level_yn := NULL;
					l_csm_loan_levels_tbl(knt).amount :=  (-1 * cur_rec.stub_amount);
			       END LOOP;

                                knt := knt+1;
                                l_index := l_index + 1;

				--Now populate the PPD funding for this Asset
				l_csm_loan_levels_tbl(knt).DESCRIPTION := 'Funding';
				l_csm_loan_levels_tbl(knt).date_start := x_trqv_tbl(1).payment_date;
				l_csm_loan_levels_tbl(knt).kle_loan_id := l_csm_loan_lines_tbl(i).kle_loan_id;
				l_csm_loan_levels_tbl(knt).level_index_number := l_index;
				l_csm_loan_levels_tbl(knt).level_type := OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_FUNDING;
				l_csm_loan_levels_tbl(knt).lock_level_step := NULL;
				l_csm_loan_levels_tbl(knt).period := NULL;
				l_csm_loan_levels_tbl(knt).advance_or_arrears := NULL;
				l_csm_loan_levels_tbl(knt).income_or_expense := NULL;
				l_csm_loan_levels_tbl(knt).structure :=NULL;
				l_csm_loan_levels_tbl(knt).query_level_yn := NULL;

				--Pro rate the ppd amount for this asset.
				--Formula would be: (asset_cost/total_cost) * Paydown amount

				print_to_log('l_asset_cost: '|| l_asset_cost);
				print_to_log('l_total_k_cost: '|| l_total_k_cost);
				print_to_log('Payment amount: '|| x_trqv_tbl(1).payment_amount);
				l_ppd_for_asset := ((l_asset_cost/l_total_k_cost) * x_trqv_tbl(1).payment_amount);

				print_to_log('l_ppd_for_asset: '|| l_ppd_for_asset);
				-- We need to send Negative Funding to ST.
				l_ppd_funding := l_ppd_for_asset * -1;
 				print_to_log('l_ppd_funding amount: '|| l_ppd_funding);

				l_csm_loan_levels_tbl(knt).amount := l_ppd_funding;

			END LOOP;

 IF l_csm_loan_levels_tbl.count > 0 THEN
   FOR i IN l_csm_loan_levels_tbl.first..l_csm_loan_levels_tbl.last LOOP
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').DESCRIPTION = '||l_csm_loan_levels_tbl(i).DESCRIPTION,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').DATE_START = '||TO_CHAR(l_csm_loan_levels_tbl(i).DATE_START), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').KLE_LOAN_ID = '||TO_CHAR(l_csm_loan_levels_tbl(i).KLE_LOAN_ID), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').LEVEL_INDEX_NUMBER = '||TO_CHAR(l_csm_loan_levels_tbl(i).LEVEL_INDEX_NUMBER), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').LEVEL_TYPE = '||l_csm_loan_levels_tbl(i).LEVEL_TYPE,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').NUMBER_OF_PERIODS = '||TO_CHAR(l_csm_loan_levels_tbl(i).NUMBER_OF_PERIODS), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').AMOUNT = '||TO_CHAR(l_csm_loan_levels_tbl(i).AMOUNT), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').LOCK_LEVEL_STEP = '||l_csm_loan_levels_tbl(i).LOCK_LEVEL_STEP,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').RATE = '||TO_CHAR(l_csm_loan_levels_tbl(i).RATE), 1, 255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').PERIOD = '||l_csm_loan_levels_tbl(i).PERIOD,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').ADVANCE_OR_ARREARS = '||l_csm_loan_levels_tbl(i).ADVANCE_OR_ARREARS,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').INCOME_OR_EXPENSE = '||l_csm_loan_levels_tbl(i).INCOME_OR_EXPENSE,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').STRUCTURE = '||l_csm_loan_levels_tbl(i).STRUCTURE,1,255));
print_to_log(SubStr('l_csm_loan_levels_tbl('||TO_CHAR(i)||').QUERY_LEVEL_YN = '||l_csm_loan_levels_tbl(i).QUERY_LEVEL_YN,1,255));
print_to_log (' ');
    END LOOP;
  END IF;
*/
--rkuttiya end commenting code for 11i OKL.H Variable Rate

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      		 	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling ESG streams');
    END IF;
           	       --Call the Create streams
  			Okl_Create_Streams_Pub.Create_Streams_Loan_Restr(p_api_version  => p_api_version,
								p_init_msg_list         => p_init_msg_list,
								p_skip_prc_engine       => l_skip_prc_engine,
								p_csm_loan_header       => l_csm_loan_header,
                                				p_csm_loan_lines_tbl    => l_csm_loan_lines_tbl,
								p_csm_loan_levels_tbl   => l_csm_loan_levels_tbl,
								p_csm_one_off_fee_tbl   => l_csm_one_off_fee_tbl,
								p_csm_periodic_expenses_tbl => l_csm_periodic_expenses_tbl,
								p_csm_yields_tbl        => l_csm_yields_tbl,
								p_csm_stream_types_tbl  => l_csm_stream_types_tbl,
								x_trans_id              => l_trans_id,
								x_trans_status          => l_trans_status,
								x_return_status	   	=> x_return_status,
								x_msg_count	   	=> x_msg_count,
								x_msg_data	   	=> x_msg_data);


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      		 	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling ESG streams:'|| x_return_status);
    END IF;
			IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          	  	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            			RAISE OKL_API.G_EXCEPTION_ERROR;
          	  	END IF;
			--Now update the Status and the Transaction id in the CS Request Table.
			-- fetch the object version no from the db and update
			        open c_get_object_ver(x_trqv_tbl(1).id);
				fetch c_get_object_ver into l_object_version_number;
				close c_get_object_ver;

			l_trqv_tbl(1).id := x_trqv_tbl(1).id;
			l_trqv_tbl(1).object_version_number := l_object_version_number;--x_trqv_tbl(1).object_version_number;
			l_trqv_tbl(1).jtot_object1_code := 'OKL_STREAM_INTERFACES';
			l_trqv_tbl(1).object1_id1 := l_trans_id;
			if (l_object_version_number = x_trqv_tbl(1).object_version_number) then
				l_trqv_tbl(1).request_status_code := 'PRICING';
                        end if ;

                	--Call update here.
                  	okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_tbl            => l_trqv_tbl,
                                                x_trqv_tbl            => x_trqv_tbl);

                  	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     		RAISE OKL_API.G_EXCEPTION_ERROR;
                  	END IF;

                   END IF; -- End If for Principal Payment and Solve for payment

  		END IF;-- End if for l_amount =0
	END IF; -- End if for Check for profile
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');


 END calculate;

PROCEDURE update_ppd_request(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_trqv_rec              IN  okl_trx_requests_pub.trqv_rec_type
    ,x_trqv_rec              OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type)
 AS

        l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_PPD_REQUEST';
    	l_trqv_rec          okl_trx_requests_pub.trqv_rec_type := p_trqv_rec;

	CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT object_Version_number
	FROM   okl_trx_requests
	WHERE id=a_id;

   BEGIN

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	OPEN c_obj_vers_csr(l_trqv_rec.id);
	FETCH c_obj_vers_csr INTO l_trqv_rec.object_Version_number;
	CLOSE c_obj_vers_csr;

	--Check the Status that is being passed in and decode that status before callin
	-- the update API.
	--The status should be present in the FND_LOOKUP.


		IF (l_trqv_rec.request_status_code = 'PROCESS_COMPLETE' ) THEN
			l_trqv_rec.request_status_code := 'COMPLETE';
		ELSIF (l_trqv_rec.request_status_code = 'PROCESS_COMPLETE_ERROR' ) THEN
			l_trqv_rec.request_status_code := 'INCOMPLETE';
		END IF;


                -- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
                                                p_api_version         => p_api_version,
                                                p_init_msg_list       =>p_init_msg_list,
                                                x_return_status       => x_return_status,
                                                x_msg_count           => x_msg_count,
                                                x_msg_data            => x_msg_data,
                                                p_trqv_rec            => l_trqv_rec,
                                                x_trqv_rec            => x_trqv_rec);


                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');


 END update_ppd_request;


  ------------------------------------------------------------------------------
  -- FUNCTION get_try_id
  ------------------------------------------------------------------------------
    -- Created by  : RVADURI
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
    -- Created by  : RVADURI
    --
    --  Purpose:
    --  Private Procedure to retrieve ID of a given Stream Type
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  FUNCTION get_sty_id (p_sty_name IN VARCHAR2) RETURN NUMBER IS

    CURSOR c_sty IS
      SELECT  sty.id
      FROM    okl_strm_type_tl styt, okl_strm_type_b sty
      WHERE   styt.name = p_sty_name
        AND   styt.language = 'US'
        AND   sty.id = styt.id
        AND   sty.start_date <= TRUNC(SYSDATE)
        AND   NVL(sty.end_date, SYSDATE) >= TRUNC(SYSDATE);

    l_sty_id      NUMBER;

  BEGIN

    OPEN c_sty;
    FETCH c_sty INTO l_sty_id;
    CLOSE c_sty;

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
  -- FUNCTION get_pdt_id
  ------------------------------------------------------------------------------
    -- Created by  : RVADURI
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
  -- PROCEDURE create_ppd_invoice
  ------------------------------------------------------------------------------
    -- Created by  : RVADURI
    --
    --  Purpose:
    --  Create an Invoice Entry in the Internal OKL Invoice tables
    --
    -- Known limitations/enhancements and/or remarks:
    --
  ------------------------------------------------------------------------------

  PROCEDURE create_ppd_invoice (p_khr_id            IN NUMBER,
                                p_ppd_amount        IN NUMBER,
                                p_ppd_desc          IN VARCHAR2, --Will be default null
                                p_syndication_code  IN VARCHAR2, --Will be default null
                                p_factoring_code    IN VARCHAR2, --Will be default null
                                x_tai_id            OUT NOCOPY NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2) IS

    l_sysdate           DATE;
    l_khr_id            NUMBER;
    l_sty_name          VARCHAR2(150) := 'PRINCIPAL PAYMENT';

    l_ppd_amount        NUMBER;
    l_ppd_desc          VARCHAR2(4000);

    l_try_id            NUMBER;
    l_sty_id            NUMBER;
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
    l_ppd_amount      :=        p_ppd_amount;
    l_ppd_desc        :=        nvl(p_ppd_desc,'Principal Paydown');

    l_try_id          := get_try_id ('Billing');
    l_sty_id          := get_sty_id (l_sty_name);
    l_pdt_id          := get_pdt_id (l_khr_id);

    IF l_pdt_id IS NULL THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_NO_PRODUCT_FOUND');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    ----------------------------------------------------------------------------------
    -- Preparing Invoice Header.  Assumption: Charge will be to Primary Leasee
    ----------------------------------------------------------------------------------
    i_taiv_rec.try_id            := l_try_id;
    i_taiv_rec.khr_id            := l_khr_id;
    i_taiv_rec.date_entered      := l_sysdate;
    i_taiv_rec.date_invoiced     := l_sysdate;
    i_taiv_rec.description       := l_ppd_desc;
    i_taiv_rec.amount            := l_ppd_amount;
    i_taiv_rec.trx_status_code   := 'SUBMITTED';
    i_taiv_rec.legal_entity_id   := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_khr_id);  --dkagrawa added to populate le_id


    ----------------------------------------------------------------------------------
    -- May be useful to other functional areas.  Not populated for now.
    ----------------------------------------------------------------------------------
    i_taiv_rec.svf_id           := NULL;
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
    i_tilv_rec.description            := l_ppd_desc;
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

    ----------------------------------------------------------------------------------
    -- Prepare OKL Accounting Engine parameters
    ----------------------------------------------------------------------------------
      l_factoring_synd     := get_factor_synd(l_khr_id);


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
    l_dist_info_rec.AMOUNT                      := l_ppd_amount;
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

  END create_ppd_invoice;

--************************************************************************
-- API for cancelling any unaccepted PPD requests on a contract.
--This API accepts the Contract Id
--LOGIC: Fetch all the ppd requests for the contract which are in statuses
--       other than ('ACCEPTED','REJECTED','ERROR','PROCESSED','CANCELLED')
--       Mark these requests as cancelled.
--       This API will be called by rebook API to cancel any pending
--       PPD requests on the contract.
--************************************************************************

 PROCEDURE cancel_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER) IS


 l_api_name          CONSTANT VARCHAR2(30) := 'CANCEL_PPD';
 l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
 x_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

 CURSOR c_get_unaccepted_ppd(c_khr_id IN NUMBER)
 IS
 SELECT ID
	,OBJECT_VERSION_NUMBER
 FROM OKL_TRX_REQUESTS
 WHERE REQUEST_TYPE_CODE='PRINCIPAL_PAYDOWN'
 AND REQUEST_STATUS_CODE NOT IN ('ACCEPTED','REJECTED'
				 ,'ERROR','PROCESSED','CANCELLED'
				,'REBOOK_IN_PROCESS','REBOOK_COMPLETE')
 AND DNZ_KHR_ID = c_khr_id;

 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility
	--and initialize message list
        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Cancel PPD');
 END IF;


 --Select all the unaccepted PPD requests for this contract.
 --Set the status of all these requests to CANCELLED.

 	FOR cur_rec in c_get_unaccepted_ppd(p_khr_id) LOOP

		--Insert a log message here for cancelling the request.
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cancel PPD with Id:'|| l_trqv_rec.id);
 END IF;

		l_trqv_rec.id := cur_rec.id;
		l_trqv_rec.object_version_number := cur_rec.object_version_number;
		l_trqv_rec.request_status_code := 'CANCELLED';

		-- Call the public API for updation here.
                  okl_trx_requests_pub.update_trx_requests(
					 p_api_version         => p_api_version,
                                         p_init_msg_list       => p_init_msg_list,
                                         x_return_status       => x_return_status,
                                         x_msg_count           => x_msg_count,
                                         x_msg_data            => x_msg_data,
                                         p_trqv_rec            => l_trqv_rec,
                                         x_trqv_rec            => x_trqv_rec);
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Cancel PPD :'|| x_return_status);
 END IF;

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

	END LOOP;
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');


 END cancel_ppd;

--************************************************************************
-- API for invoicing the ppd, marking the ppd stream as billed,
-- applying the selected receipt to the generated invoice.
--Parameters: Contract Id, Transaction Id
-- LOGIC:
--       figure out if invoice application needs to be done.
--       If not required, EXIT From API
--       If Reqd, then
--              Create online AR Invoice
--              Mark the "Unscheduled Principal Payment" stream as Billed.
--          	Apply the selected receipt on the generated invoices.
--	             Update the status of the request to Processed.

--************************************************************************

 PROCEDURE invoice_apply_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER
                ,p_trx_id               IN  NUMBER) IS


 l_api_name          CONSTANT VARCHAR2(30) := 'INVOICE_APPLY_PPD';
 l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
 lx_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
 l_trx_id            NUMBER := 0;
 l_src_trx_id            NUMBER := 0;
 l_req_id            NUMBER := 0;
 l_obj_ver	     VARCHAR2(10);

 CURSOR c_get_source_trx_id (c_trx_id NUMBER)
 IS
 SELECT SOURCE_TRX_ID
 FROM OKL_TRX_CONTRACTS
 WHERE ID=c_trx_id;

 CURSOR c_check_if_ppd (c_trx_id NUMBER)
 IS
 SELECT ID
 FROM OKL_TRX_CONTRACTS
 WHERE ID=c_trx_id
 AND TCN_TYPE='PPD';


 CURSOR c_get_req_id_csr (c_trx_id NUMBER)
 IS
 SELECT ID,object_Version_number
 FROM OKL_TRX_REQUESTS
 WHERE TCN_ID=c_trx_id;


 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd'
									,'Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              'p_trx_id :'||p_trx_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              'p_khr_id :'||p_khr_id);
    END IF;


    x_return_status := OKL_API.G_RET_STS_SUCCESS;
   --Call start_activity to create savepoint,
   --check compatibility and initialize message list

/*
    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

    OPEN c_get_source_trx_id(p_trx_id);
    FETCH c_get_source_trx_id INTO l_src_trx_id;
    CLOSE c_get_source_trx_id;


 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Source TRX Id for this transaction is :'|| l_src_trx_id);
 END IF;
  IF l_src_trx_id IS NOT NULL THEN
    OPEN c_check_if_ppd(l_src_trx_id);
    FETCH c_check_if_ppd INTO l_trx_id;
    CLOSE c_check_if_ppd;

    IF l_trx_id = 0 THEN
        --This rebook was not due PPD so Exit from the procedure.
    	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              		'This transaction is not due to PPD. Return from invoice_app_ppd at this point.');
	END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The Transaction ' || p_trx_id || ' did not originate from PPD');
 END IF;
    ELSE
    	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              		'This transaction is due to PPD.');
	END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The Transaction is due to PPD');
 END IF;
        --This rebook was due  to PPD.
	OPEN c_get_req_id_csr(l_trx_id);
	FETCH c_get_req_id_csr INTO l_req_id,l_obj_ver;
	CLOSE c_get_req_id_csr;

    	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              		'Request id :' || l_req_id);
	END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Req id is :' || l_req_id  || ' - '|| l_obj_ver);
 END IF;

	--Update the Request to Rebook Complete.
    	--Get the request details.
        l_trqv_rec.id := l_req_id;
	l_trqv_rec.object_Version_number := l_obj_ver;
        l_trqv_rec.request_status_code := 'REBOOK_COMPLETE';


 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before updating Request ');
 END IF;
        okl_trx_requests_pub.update_trx_requests( p_api_version         => p_api_version,
                                                p_init_msg_list         => p_init_msg_list,
                                                x_return_status         => x_return_status,
                                                x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data,
                                                p_trqv_rec              => l_trqv_rec,
                                                x_trqv_rec              => lx_trqv_rec);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After updating Request :' || x_return_status);
 END IF;
/*
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
*/



    	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              		'After updating the status of the request to REBOOK_COMPLETE');
	END IF;

	--Call the WF which does the following
        	-- 1. Create online AR Invoice.
        	-- 2. Mark the "Unscheduled Principal Payment" stream as Billed.
        	-- 3. Apply the selected receipt on the generated invoices.
        	-- 4. Update the status of the request to Processed.

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling WF');
 END IF;
	 OKL_CS_WF.raise_principal_paydown_event(l_req_id);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling WF');
 END IF;

    	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_apply_ppd.',
              		'After invoking the Workflow for Principal Paydown ');
	END IF;
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The Transaction ' || p_trx_id || ' originated from PPD');
 END IF;

    END IF;
 END IF;
/*
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);
*/

/*
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');


*/
 END invoice_apply_ppd;

  FUNCTION check_for_ppd
   (p_khr_id	IN	NUMBER
   ,p_effective_date IN DATE)
   RETURN VARCHAR2
  AS

    l_count    NUMBER :=0;
    l_ppd_exists VARCHAR2(5);

    --Check for any accepted/processed PPD requests
    -- after a date for a contract.

    CURSOR c_chk_ppd_csr (a_khr_id NUMBER,a_effective_date DATE)
	IS
    SELECT count(id)
    FROM okl_trx_requests
    where request_type_code='PRINCIPAL_PAYDOWN'
    and dnz_khr_id = a_khr_id
    and payment_date > a_effective_date
    and request_status_code IN ('ACCEPTED','REBOOK_IN_PROCESS'
				,'REBOOK_COMPLETE','PROCESSED');


  BEGIN
	OPEN c_chk_ppd_csr(p_khr_id,p_effective_date);
	FETCH c_chk_ppd_csr INTO l_count;
	CLOSE c_chk_ppd_csr;

	IF (l_count = 0) THEN
		l_ppd_exists := 'N';
	ELSE
		l_ppd_exists := 'Y';
	END IF;
	RETURN l_ppd_exists;
  END check_for_ppd;

  FUNCTION check_if_ppd
   (p_request_id    IN      NUMBER)
   RETURN VARCHAR2
  AS

    l_count    NUMBER :=0;
    l_ppd_exists VARCHAR2(5);


    CURSOR c_chk_ppd_csr (a_id NUMBER)
    IS
    SELECT count(id)
    FROM okl_trx_requests
    where request_type_code='PRINCIPAL_PAYDOWN'
    and id=a_id;

  BEGIN
        OPEN c_chk_ppd_csr(p_request_id);
        FETCH c_chk_ppd_csr INTO l_count;
        CLOSE c_chk_ppd_csr;

        IF (l_count = 0) THEN
                l_ppd_exists := 'N';
        ELSE
                l_ppd_exists := 'Y';
        END IF;
        RETURN l_ppd_exists;

  END check_if_ppd;


--================================================================
PROCEDURE create_cash_flow_object(p_api_version    IN   NUMBER,
                                  x_msg_count      OUT 	NOCOPY NUMBER,
  			          x_msg_data       OUT 	NOCOPY VARCHAR2,
                                  p_obj_type_code  IN   VARCHAR2,
                                  p_src_table      IN   VARCHAR2,
                                  p_src_id         IN   NUMBER,
                                  p_base_src_id    IN   NUMBER,
                                  x_cfo_id         OUT  NOCOPY NUMBER,
                                  x_return_status  OUT 	NOCOPY   VARCHAR2) IS


/*-----------------------------------------------------------------------+
 *  | Cursor Declarations                                                   |
 *   +-----------------------------------------------------------------------*/
  --This cursor checks if an object already exists
 CURSOR l_cash_flow_objects_csr(cp_oty_code IN VARCHAR2,
				cp_source_table IN VARCHAR2,
                                cp_source_id IN NUMBER,
                                cp_base_src_id IN NUMBER) IS
 SELECT cfo.id
 FROM   okl_cash_flow_objects cfo, OKL_TRX_QTE_CF_OBJECTS qco
 WHERE  cfo.id = qco.cfo_id
 AND    cfo.oty_code = cp_oty_code
 AND    cfo.source_table = cp_source_table
 AND    cfo.source_id = cp_source_id
 AND    qco.base_source_id = cp_base_src_id;


 /*-----------------------------------------------------------------------+
 *  | SubType Declarations
 *   +-----------------------------------------------------------------------*/

 SUBTYPE cfov_rec_type IS okl_cash_flow_objects_pub.cfov_rec_type;


/*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/

 l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_CASH_FLOW_OBJECT';
l_cfo_id                     NUMBER;
lp_cfov_rec                  cfov_rec_type;
lx_cfov_rec                  cfov_rec_type;
l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object','Begin(+)');
   END IF;

   --Print Input Variables
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object.',
              'p_obj_type_code :'||p_obj_type_code);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object.',
              'p_src_table :'||p_src_table);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object.',
              'p_src_id :'||p_src_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object.',
              'p_base_src_id :'||p_base_src_id);

    END IF;



-- Check if Object already exists
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Check for CFO');
  END IF;
  OPEN  l_cash_flow_objects_csr(p_obj_type_code, p_src_table, p_src_id,p_base_src_id);
  FETCH l_cash_flow_objects_csr INTO l_cfo_id;

  IF l_cash_flow_objects_csr%NOTFOUND THEN  -- Object does not exist

     lp_cfov_rec.oty_code := p_obj_type_code;
     lp_cfov_rec.source_table := p_src_table;
     lp_cfov_rec.source_id := p_src_id;

     okl_cash_flow_objects_pub.insert_cash_flow_object(p_api_version    => p_api_version,
                                                       p_init_msg_list  => OKL_API.G_FALSE,
                                                       x_return_status  => l_return_status,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data,
                                                       p_cfov_rec       => lp_cfov_rec,
                                                       x_cfov_rec       => lx_cfov_rec);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Created CFO');
 END IF;
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     x_cfo_id := lx_cfov_rec.id;

  ELSE

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'CFO already exists - ' || l_cfo_id);
 END IF;
     x_cfo_id := l_cfo_id;

  END IF;

  CLOSE l_cash_flow_objects_csr;
  x_return_status := l_return_status;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object','end(-)');
  END IF;
 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.create_cash_flow_object ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_cash_flow_object;


PROCEDURE store_esg_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_ppd_request_id            IN  NUMBER,
    p_ppd_khr_id                IN  NUMBER,
    p_payment_tbl               IN payment_tbl_type)

 AS
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'store_esg_payments';
    lx_cfo_id			NUMBER;

    l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
    lx_trqv_rec         okl_trx_requests_pub.trqv_rec_type;
    l_rent_sty_id		NUMBER;
    l_upp_sty_id		NUMBER;
    l_payment_tbl	payment_tbl_type := p_payment_tbl;
    l_store_payment_tbl	payment_tbl_type;
    l_temp_tbl            payment_tbl_type;

    knt			NUMBER := 0;
    i			NUMBER := 0;
    l_total_k_cost	NUMBER := 0;
    l_asset_cost	NUMBER := 0;
    l_kle_id		NUMBER;
    l_prev_kle_id		NUMBER;
    l_pymt_count		NUMBER :=0;
    l_currency_code             VARCHAR2(30);
    l_raw_ppd_for_asset		NUMBER :=0;
    l_ppd_for_asset		NUMBER :=0;
    l_principal_count           NUMBER :=0; --Bug#5100215
    l_index                     NUMBER;
    l_ppd_amount                NUMBER := 0;

    CURSOR l_kheaders_csr(cp_khr_id IN NUMBER) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = cp_khr_id;

    CURSOR c_req_details_csr (a_id NUMBER)
    IS
    SELECT object_Version_number
	      ,payment_amount
	      ,payment_date
    FROM   okl_trx_requests
    WHERE id=a_id;

    --Bug#5100215 added cursor start --dkagrawa
    CURSOR  l_stream_type_csr(p_stream_type IN VARCHAR2
                           ,p_khr_id IN NUMBER) IS
    SELECT  COUNT(*)
    FROM    okc_rules_b sll_rul,
            okl_strmtyp_source_v sttyp,
            okc_rules_b slh_rul,
            okc_rule_groups_b rgp
    WHERE   sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    AND     sttyp.stream_type_purpose = p_stream_type
    AND     rgp.dnz_chr_id = p_khr_id;

    ---Bug#5100215 end --dkagrawa

 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Entering store_esg_payments: ');
 END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments.',
              'p_ppd_request_id :'||p_ppd_request_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments.',
              'p_ppd_khr_id :'||p_ppd_khr_id);
   END IF;

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint,
        --check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===== Begin Payments sent to the API before any modifications ====');
 END IF;
		 PRINT_STM_PAYMENTS(l_payment_tbl);
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===== End Payments sent to the API before any modifications ====');
 END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' before reorganizing');
       END IF;

      -- added by rkuttiya for 11i OKL.H
       --reorganize the payments
       l_temp_tbl := re_organize_payment_tbl(l_payment_tbl);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'===== Begin Payments after reorganizing ====');
      END IF;
	  PRINT_STM_PAYMENTS(l_temp_tbl);



   	--Get the currency code for the Contract
   	OPEN  l_kheaders_csr(p_ppd_khr_id);
   	FETCH l_kheaders_csr INTO l_currency_code;
   	CLOSE l_kheaders_csr;

	OPEN c_req_details_csr(p_ppd_request_id);
        FETCH c_req_details_csr INTO l_trqv_rec.object_Version_number
				  ,l_trqv_rec.payment_amount
				  ,l_trqv_rec.payment_date;
        CLOSE c_req_details_csr;

       --Bug#5100215 added the following code start -- dkagrawa

       OPEN l_stream_type_csr('PRINCIPAL_PAYMENT',p_ppd_khr_id);
       FETCH l_stream_type_csr INTO l_principal_count;
       CLOSE l_stream_type_csr;

       IF l_principal_count > 0
       THEN
         OKL_STREAMS_UTIL.get_dependent_stream_type
                     (p_khr_id                => p_ppd_khr_id
                     ,p_primary_sty_purpose   => G_RENT_STREAM
                    ,p_dependent_sty_purpose  => G_PRINCIPAL_PAYMENT
                    ,x_return_status          => x_return_status
                    ,x_dependent_sty_id       => l_rent_sty_id);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       ELSE
         OKL_STREAMS_UTIL.get_primary_stream_type
                      (p_khr_id => p_ppd_khr_id
                      ,p_primary_sty_purpose => G_RENT_STREAM
                      ,x_return_status    => x_return_status
                      ,x_primary_sty_id   => l_rent_sty_id);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       --Bug#5100215 end


        --Get the Stream type id for UPP.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_ppd_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
         END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => 'CONTRACT_CAP_AMNT',
                                        p_contract_id   => p_ppd_khr_id,
                                        p_line_id       => NULL,
                                        x_value         => l_total_k_cost);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute CONTRACT_CAP_AMNT: '|| l_total_k_cost || x_return_status);
        END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Now populate the l_payments_tbl with the UNSCHEDULED_PRINCIPAL_PAYMENT
        --to account for this ppd.

	--We will have to loop thru the payment table to get the asset id
	--For this asset id calculate the ppd  and
	--populate this value in the table after the RENT payment.
	--An Example for this.
	--If the raw payments sent to the API are as follows:
	--     	p_payment_tbl(1).KHR_ID       :=26132
        --	p_payment_tbl(1).KLE_ID       :=360591535465800234004677727590576912380
     	--	p_payment_tbl(1).STY_ID       :=NULL
     	--	p_payment_tbl(1).start_date   :=01-Feb-2004
     	--	p_payment_tbl(1).structure    :=NULL
     	--	p_payment_tbl(1).arrears_yn   :=N
     	--	p_payment_tbl(1).periods      :=35
     	--	p_payment_tbl(1).frequency    :=M
     	--	p_payment_tbl(1).amount       :=4780.5860395779
     	--	p_payment_tbl(1).stub_days    :=NULL
     	--	p_payment_tbl(1).stub_amount  :=NULL
	--
     	--	p_payment_tbl(2).KHR_ID       :=26132
     	--	p_payment_tbl(2).KLE_ID       :=360814321906377868722110133214346573627
     	--	p_payment_tbl(2).STY_ID       :=NULL
     	--	p_payment_tbl(2).start_date   :=01-Feb-2004
     	--	p_payment_tbl(2).structure    :=NULL
     	--	p_payment_tbl(2).arrears_yn   :=N
     	--	p_payment_tbl(2).periods      :=35
     	--	p_payment_tbl(2).frequency    :=M
     	--	p_payment_tbl(2).amount       :=2390.29303623929
     	--	p_payment_tbl(2).stub_days    :=NULL
     	--	p_payment_tbl(2).stub_amount  :=NULL

	--After Modification they would be as follows:

	--     	p_payment_tbl(1).KHR_ID       :=26132
        --	p_payment_tbl(1).KLE_ID       :=360591535465800234004677727590576912380
     	--	p_payment_tbl(1).STY_ID       :=251601487757888615031160220891184821165 --Rent Sty
     	--	p_payment_tbl(1).start_date   :=01-Feb-2004
     	--	p_payment_tbl(1).structure    :=NULL
     	--	p_payment_tbl(1).arrears_yn   :=N
     	--	p_payment_tbl(1).periods      :=35
     	--	p_payment_tbl(1).frequency    :=M
     	--	p_payment_tbl(1).amount       :=4780.5860395779
     	--	p_payment_tbl(1).stub_days    :=NULL
     	--	p_payment_tbl(1).stub_amount  :=NULL
	--
	--     	p_payment_tbl(2).KHR_ID       :=26132
        --	p_payment_tbl(2).KLE_ID       :=360591535465800234004677727590576912380
     	--	p_payment_tbl(2).STY_ID       :=352077033884154096951239569973480360897 --PPD STY
     	--	p_payment_tbl(2).start_date   :=01-Jan-2004
     	--	p_payment_tbl(2).structure    :=NULL
     	--	p_payment_tbl(2).arrears_yn   :=NULL
     	--	p_payment_tbl(2).periods      :=NULL
     	--	p_payment_tbl(2).frequency    :=NULL
     	--	p_payment_tbl(2).amount       :=NULL
     	--	p_payment_tbl(2).stub_days    :=1
     	--	p_payment_tbl(2).stub_amount  :=6666.66
	--
     	--	p_payment_tbl(3).KHR_ID       :=26132
     	--	p_payment_tbl(3).KLE_ID       :=360814321906377868722110133214346573627
     	--	p_payment_tbl(3).STY_ID       :=251601487757888615031160220891184821165 --Rent Sty
     	--	p_payment_tbl(3).start_date   :=01-Feb-2004
     	--	p_payment_tbl(3).structure    :=NULL
     	--	p_payment_tbl(3).arrears_yn   :=N
     	--	p_payment_tbl(3).periods      :=35
     	--	p_payment_tbl(3).frequency    :=M
     	--	p_payment_tbl(3).amount       :=2390.29303623929
     	--	p_payment_tbl(3).stub_days    :=NULL
     	--	p_payment_tbl(3).stub_amount  :=NULL

	--     	p_payment_tbl(4).KHR_ID       :=26132
        --	p_payment_tbl(4).KLE_ID       :=360814321906377868722110133214346573627
     	--	p_payment_tbl(4).STY_ID       :=352077033884154096951239569973480360897 --PPD STY
     	--	p_payment_tbl(4).start_date   :=01-Jan-2004
     	--	p_payment_tbl(4).structure    :=NULL
     	--	p_payment_tbl(4).arrears_yn   :=NULL
     	--	p_payment_tbl(4).periods      :=NULL
     	--	p_payment_tbl(4).frequency    :=NULL
     	--	p_payment_tbl(4).amount       :=NULL
     	--	p_payment_tbl(4).stub_days    :=1
     	--	p_payment_tbl(4).stub_amount  :=3333.34
	--
IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before updating ppd amounts');
END IF;

	l_prev_kle_id	:= -99;
        knt := 1;
    IF l_temp_tbl.count > 0 THEN
      i:= l_temp_tbl.FIRST;
      LOOP
		l_kle_id	:= l_temp_tbl(i).kle_id;
		--ESG will not populate the styid for rent
		--so populate for each row.
        	l_store_payment_tbl(knt) :=  l_temp_tbl(i);
		l_store_payment_tbl(knt).sty_id	:= l_rent_sty_id;

		If l_kle_id <> l_prev_kle_id THEN
			l_prev_kle_id := l_kle_id;

			OKL_EXECUTE_FORMULA_PUB.execute(
				p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_formula_name  => 'LINE_CAP_AMNT',
                                p_contract_id   => p_ppd_khr_id,
                                p_line_id       => l_kle_id,
                                x_value         => l_asset_cost);

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute LINE_CAP_AMNT: '|| l_asset_cost);
                        END IF;
                        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                                raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                                raise OKC_API.G_EXCEPTION_ERROR;
                        End If;

                        --Pro rate the ppd amt for this line
                        l_raw_ppd_for_asset := (l_asset_cost/l_total_k_cost)
                                                        * l_trqv_rec.payment_amount;

                        l_ppd_for_asset := Okl_Accounting_Util.ROUND_AMOUNT(
                                                p_amount => l_raw_ppd_for_asset,
                                                p_currency_code => l_currency_code);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PPD for Asset : '|| l_ppd_for_asset);
                        END IF;

			knt := knt +1;
        		l_store_payment_tbl(knt).KHR_ID     := p_ppd_khr_id;
                	l_store_payment_tbl(knt).KLE_ID     := l_kle_id;
                	l_store_payment_tbl(knt).STY_ID     := l_upp_sty_id;
                	l_store_payment_tbl(knt).start_date := l_trqv_rec.payment_date;
                	l_store_payment_tbl(knt).stub_days  := 1;
                	l_store_payment_tbl(knt).stub_amount:= l_ppd_for_asset;
        		--Bug#5511937 by dkagrawa start
                        l_index := knt;
                        l_ppd_amount := l_ppd_amount + l_ppd_for_asset;
                        --Bug#5511937 end
		END IF;
		knt := knt +1;
		EXIT WHEN i = l_temp_tbl.LAST;
	    i := l_temp_tbl.NEXT(i);
  	  END LOOP;
    END IF;
    --Bug#5511937 by dkagrawa start
    IF ( l_trqv_rec.payment_amount - l_ppd_amount <> 0 ) THEN
      l_store_payment_tbl(l_index).stub_amount := l_store_payment_tbl(l_index).stub_amount + (l_trqv_rec.payment_amount - l_ppd_amount );
    END IF;
    --Bug#5511937 end


	PRINT_STM_PAYMENTS(l_store_payment_tbl);

	--Call the Store stm payments api.
                store_stm_payments(p_api_version  => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_ppd_request_id => p_ppd_request_id,
                              p_ppd_khr_id     => p_ppd_khr_id,
                              p_payment_tbl    => l_store_payment_tbl,
                              x_cfo_id         => lx_cfo_id);
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Store stm payments in ESG Inbound:' || x_return_status
                                || 'CFO Id: '|| lx_cfo_id);
                END IF;
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

	--Update the Request with the status of complete.

        l_trqv_rec.request_status_code := 'COMPLETE';
        l_trqv_rec.id := p_ppd_request_id;

        okl_trx_requests_pub.update_trx_requests( p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
						x_msg_data      => x_msg_data,
                                                p_trqv_rec      => l_trqv_rec,
                                                x_trqv_rec      => lx_trqv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments'
                                                                        ,'End(-)');
  	END IF;

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END store_esg_payments;



 PROCEDURE store_stm_payments(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER,
    p_ppd_khr_id        	IN  NUMBER,
    p_payment_tbl       	IN payment_tbl_type,
    x_cfo_id            	OUT NOCOPY NUMBER)

 AS

  /*-----------------------------------------------------------------------+
 *  *  | Subype Declarations                                                   |
 *   *
 *   +-----------------------------------------------------------------------*/

   SUBTYPE cfov_rec_type IS okl_cash_flow_objects_pub.cfov_rec_type;
   SUBTYPE cafv_rec_type IS okl_cash_flows_pub.cafv_rec_type;
   SUBTYPE cflv_rec_type IS okl_cash_flow_levels_pub.cflv_rec_type;
   SUBTYPE qcov_rec_type IS okl_trx_qte_cf_objects_pub.qcov_rec_type;


 /*-----------------------------------------------------------------------+
 *  *  | Local Variable Declarations and initializations                       |
 *   *
 *   +-----------------------------------------------------------------------*/
    lp_cfov_rec                  cfov_rec_type;
    lx_cfov_rec                  cfov_rec_type;

    lp_cafv_rec                  cafv_rec_type;
    lx_cafv_rec                  cafv_rec_type;

    lp_cflv_rec                  cflv_rec_type;
    lx_cflv_rec                  cflv_rec_type;

    lp_qcov_rec                  qcov_rec_type;
    lx_qcov_rec                  qcov_rec_type;


    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'store_stm_payments';
    l_prev_sty_id		NUMBER;
    l_sty_id			NUMBER;
    l_prev_kle_id               NUMBER;
    l_kle_id                    NUMBER;
    l_cfo_id			NUMBER;
    l_caf_id			NUMBER;
    l_cfl_id			NUMBER;
    l_stub_amount		NUMBER;
    l_amount			NUMBER;
    l_currency_code         	VARCHAR2(30);
    l_qco_id       		NUMBER;


    CURSOR l_kheaders_csr(cp_khr_id IN NUMBER) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = cp_khr_id;

    CURSOR l_qco_id_csr(cp_qte_id IN NUMBER
                        ,cp_cfo_id  IN  NUMBER
                        ,cp_base_src_id IN  NUMBER) IS
    SELECT id
    FROM OKL_TRX_QTE_CF_OBJECTS
    WHERE qte_id=cp_qte_id
    AND cfo_id=cp_cfo_id
    AND base_source_id=cp_base_src_id;

    CURSOR l_caf_id_csr(cp_qte_id IN NUMBER
                        ,cp_cfo_id  IN  NUMBER
                        ,cp_sty_id IN  NUMBER) IS
    SELECT id
    FROM OKL_CASH_FLOWS
    WHERE cfo_id=cp_cfo_id
    AND dnz_qte_id=cp_qte_id
    AND sty_id = cp_sty_id;

    CURSOR l_cfl_id_csr(cp_caf_id  IN  NUMBER
                        ,cp_start_date IN  DATE) IS
    SELECT id
    FROM OKL_CASH_FLOW_LEVELS
    WHERE caf_id=cp_caf_id
    AND start_date=cp_start_date;

    i        NUMBER := 0;
    --dkagrawa added the following code for bug#5443418 start
    CURSOR l_calc_method ( cp_trq_id IN NUMBER) IS
    SELECT method_of_calculation_code
    FROM okl_trx_requests
    WHERE id = cp_trq_id;

    CURSOR l_cfl_id_csr_esg(cp_caf_id IN  NUMBER
                           ,cp_amount IN  number) IS
    SELECT id,number_of_periods,start_date
    FROM OKL_CASH_FLOW_LEVELS
    WHERE caf_id=cp_caf_id
    AND amount = cp_amount
    AND stub_days IS null;

    l_periods        NUMBER;
    l_solve_type     VARCHAR2(10);
    l_start_date     DATE;
    l_pricing_engine VARCHAR2(50);
    --dkagrawa bug#5443418 end
 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments.',
              'p_ppd_request_id :'||p_ppd_request_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments.',
              'p_ppd_khr_id :'||p_ppd_khr_id);
   END IF;

   --Get the currency code for the Contract
   OPEN  l_kheaders_csr(p_ppd_khr_id);
   FETCH l_kheaders_csr INTO l_currency_code;
   CLOSE l_kheaders_csr;

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint,
	--check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_prev_sty_id := 0;
        l_prev_kle_id := 0;  --Bug#5046204
   --Create a cash flow object for this type.
   IF p_payment_tbl.count > 0 THEN
      i:= p_payment_tbl.FIRST;
    LOOP
        create_cash_flow_object(p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                       		  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_FIN_ASSET_OBJECT_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_ppd_request_id,
                                  p_base_src_id    => p_payment_tbl(i).kle_id,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking for  QCO');
      END IF;
         --Check if this association exists.
	 l_qco_id := NULL;
         OPEN l_qco_id_csr(p_ppd_request_id,l_cfo_id,p_payment_tbl(i).kle_id);
         FETCH l_qco_id_csr INTO l_qco_id;
         CLOSE l_qco_id_csr;

         IF l_qco_id IS NULL THEN
             --Create the association to Request and kle_id
             l_qco_id           := NULL;
	     lp_qcov_rec 	:= NULL;
             lp_qcov_rec.qte_id := p_ppd_request_id;
             lp_qcov_rec.cfo_id := l_cfo_id;
             lp_qcov_rec.BASE_SOURCE_ID := p_payment_tbl(i).kle_id;
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating QCO');
             END IF;

             OKL_TRX_QTE_CF_OBJECTS_PUB.insert_quote_cf_object(p_api_version => p_api_version,
                                                            p_init_msg_list  => OKL_API.G_FALSE,
                                                            x_return_status  => l_return_status,
                                                            x_msg_count      => x_msg_count,
                                                            x_msg_data       => x_msg_data,
                                                            p_qcov_rec       => lp_qcov_rec,
                                                            x_qcov_rec       => lx_qcov_rec);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating QCO - Return Status: ' || l_return_status);
         END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

	 ELSE
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'QCO ID :' || l_qco_id);
  END IF;
         END IF;
       --Create the Cash flows for this Object.

	 l_sty_id := p_payment_tbl(i).sty_id;
         l_kle_id := p_payment_tbl(i).kle_id; --Bug#5046204
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Sty ID in store_stm_payment: - ' ||i || ' -'|| l_sty_id);
  END IF;


         --This will be a CASH Flow
         --Create the Cash flow only if it is a different stream type,
         --otherwise only create the lines since it is for the same
         --stream type.
         --Bug#5046204 or if line id is different then also cash flow needs to be created
         IF l_sty_id <> l_prev_sty_id OR l_kle_id <> l_prev_kle_id THEN

               --check if a cash flow exists of this type.
		l_caf_id := NULL;
               OPEN l_caf_id_csr(p_ppd_request_id,l_cfo_id,l_sty_id);
               FETCH l_caf_id_csr INTO l_caf_id;
               CLOSE l_caf_id_csr;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Check for CAF ID: - ' || l_caf_id);
  END IF;

               IF l_caf_id is NULL THEN
	 		lp_cafv_rec		:= NULL;
                	lp_cafv_rec.cfo_id := l_cfo_id;
                	lp_cafv_rec.sts_code := G_PROPOSED_STATUS;
                	lp_cafv_rec.sty_id := l_sty_id;
                	lp_cafv_rec.cft_code := G_CASH_FLOW_TYPE;
                	lp_cafv_rec.due_arrears_yn := nvl(p_payment_tbl(i).arrears_yn,'N');
        		lp_cafv_rec.start_date :=p_payment_tbl(i).start_date;
                	lp_cafv_rec.number_of_advance_periods := p_payment_tbl(i).structure;
                	lp_cafv_rec.dnz_khr_id := p_ppd_khr_id;
                	lp_cafv_rec.dnz_qte_id := p_ppd_request_id;
                       --Call the API to create the Cash Flow.
                        okl_cash_flows_pub.insert_cash_flow(
                            p_api_version              =>    p_api_version,
                            p_init_msg_list            =>    OKL_API.G_FALSE,
                            x_return_status            =>    l_return_status,
                            x_msg_count                =>    x_msg_count,
                            x_msg_data                 =>    x_msg_data,
                            p_cafv_rec                 =>    lp_cafv_rec,
                            x_cafv_rec                 =>    lx_cafv_rec);

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating CAF - Return Status: ' || l_return_status);
                     END IF;
                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                        l_caf_id            := lx_cafv_rec.id;
               ELSE
	 		lp_cafv_rec	:= NULL;
                        lp_cafv_rec.id := l_caf_id;
                	lp_cafv_rec.cfo_id := l_cfo_id;
                	lp_cafv_rec.sts_code := G_PROPOSED_STATUS;
                	lp_cafv_rec.sty_id := l_sty_id;
                	lp_cafv_rec.cft_code := G_CASH_FLOW_TYPE;
                	lp_cafv_rec.due_arrears_yn := nvl(p_payment_tbl(i).arrears_yn,'N');
        		lp_cafv_rec.start_date :=p_payment_tbl(i).start_date;
                	lp_cafv_rec.number_of_advance_periods := p_payment_tbl(i).structure;
                	lp_cafv_rec.dnz_khr_id := p_ppd_khr_id;
                	lp_cafv_rec.dnz_qte_id := p_ppd_request_id;
                       --Call the API to create the Cash Flow.
                        okl_cash_flows_pub.update_cash_flow(
                            p_api_version              =>    p_api_version,
                            p_init_msg_list            =>    OKL_API.G_FALSE,
                            x_return_status            =>    l_return_status,
                            x_msg_count                =>    x_msg_count,
                            x_msg_data                 =>    x_msg_data,
                            p_cafv_rec                 =>    lp_cafv_rec,
                            x_cafv_rec                 =>    lx_cafv_rec);

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Updating CAF - Return Status: ' || l_return_status);
                     END IF;
                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
               END IF; --Check for existence of Caf

         END IF; --Check for Sty_id

         --Now create the Cash flow lines
       --check if a cash flow line exists of this type.
	l_cfl_id := NULL;
        --dkagrawa added the following code for bug#5443418 start
        OKL_STREAMS_UTIL.get_pricing_engine(
                    p_khr_id                        => p_ppd_khr_id
                   ,x_pricing_engine                => l_pricing_engine
                   ,x_return_status                => x_return_status);
        IF l_pricing_engine = 'INTERNAL' THEN
          l_solve_type := 'P';   --assgining it to 'P' bcoz for ISG we have not handled solve for term
        ELSE
          OPEN l_calc_method(p_ppd_request_id);
          FETCH l_calc_method INTO l_solve_type;
          CLOSE l_calc_method;
        END IF;
        IF l_solve_type = 'T' THEN
          OPEN l_cfl_id_csr_esg(l_caf_id,p_payment_tbl(i).amount);
          FETCH l_cfl_id_csr_esg INTO l_cfl_id,l_periods,l_start_date;
          CLOSE l_cfl_id_csr_esg;
        ELSE
        --dkagrawa bug#5443418 end
          OPEN l_cfl_id_csr(l_caf_id,p_payment_tbl(i).start_date);
          FETCH l_cfl_id_csr INTO l_cfl_id;
          CLOSE l_cfl_id_csr;
	END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Check for CFL ID: - ' || l_cfl_id);
  END IF;

       IF l_cfl_id IS NULL THEN
		lp_cflv_rec	   := NULL;
        	lp_cflv_rec.caf_id := l_caf_id;

        	IF p_payment_tbl(i).stub_days IS NOT NULL THEN --STUB DAYS
        		l_stub_amount     :=  Okl_Accounting_Util.ROUND_AMOUNT(
					 p_amount => p_payment_tbl(i).stub_amount, --stub amount
			                 p_currency_code => l_currency_code);
                	lp_cflv_rec.stub_days := p_payment_tbl(i).stub_days;
                	lp_cflv_rec.stub_amount := l_stub_amount;
        	ELSE
--rkuttiya commetning out rounding for amount
--for bug:4905281
--because mass rebook fails in the qa checker when principal payments defined on the contract
-- if the amounts are not accurate.
                	/*l_amount     :=  Okl_Accounting_Util.ROUND_AMOUNT(
		               		 p_amount => p_payment_tbl(i).amount, --amount
   			                 p_currency_code => l_currency_code);*/
                        l_amount := p_payment_tbl(i).amount;

                	lp_cflv_rec.amount := l_amount;
                	lp_cflv_rec.number_of_periods := p_payment_tbl(i).periods;
                	lp_cflv_rec.fqy_code := p_payment_tbl(i).frequency;
        	END IF;
        	lp_cflv_rec.start_date := p_payment_tbl(i).start_date;

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating CFL');
             END IF;
                    OKL_CASH_FLOW_LEVELS_PUB.insert_cash_flow_level(
					p_api_version     =>    p_api_version,
                                       p_init_msg_list   => OKL_API.G_FALSE,
                                       x_return_status   => l_return_status,
                                       x_msg_count       => x_msg_count,
                                       x_msg_data        => x_msg_data,
                                       p_cflv_rec        => lp_cflv_rec,
                                       x_cflv_rec        => lx_cflv_rec);
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating CFL - Return Status: ' || l_return_status);
                 END IF;

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
        ELSE
		lp_cflv_rec	   := NULL;
        	lp_cflv_rec.caf_id := l_caf_id;

        	IF p_payment_tbl(i).stub_days IS NOT NULL THEN --STUB DAYS
        		l_stub_amount     :=  Okl_Accounting_Util.ROUND_AMOUNT(
					 p_amount => p_payment_tbl(i).stub_amount, --stub amount
			                 p_currency_code => l_currency_code);
                	lp_cflv_rec.stub_days := p_payment_tbl(i).stub_days;
                	lp_cflv_rec.stub_amount := l_stub_amount;
        	ELSE
                	/*l_amount     :=  Okl_Accounting_Util.ROUND_AMOUNT(
		               		 p_amount => p_payment_tbl(i).amount, --amount
   			                 p_currency_code => l_currency_code); */
                        l_amount := p_payment_tbl(i).amount;

                	lp_cflv_rec.amount := l_amount;
			--dkagrawa added the following code for bug#5443418 start
                        IF l_solve_type = 'T' THEN
                          lp_cflv_rec.number_of_periods := nvl(l_periods,0) + p_payment_tbl(i).periods;
                        ELSE
                          lp_cflv_rec.number_of_periods := p_payment_tbl(i).periods;
			END IF;
			--dkagrawa bug#5443418 end
                	lp_cflv_rec.fqy_code := p_payment_tbl(i).frequency;
        	END IF;
		--dkagrawa added the following code for bug#5443418 start
                IF l_solve_type = 'T' THEN
                  lp_cflv_rec.start_date := l_start_date;
                ELSE
                  lp_cflv_rec.start_date := p_payment_tbl(i).start_date;
		END IF;
                --dkagrawa bug#5443418 end
                lp_cflv_rec.id := l_cfl_id;
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Updating CFL');
                END IF;
                    OKL_CASH_FLOW_LEVELS_PUB.update_cash_flow_level(
					p_api_version     =>    p_api_version,
                                       p_init_msg_list   => OKL_API.G_FALSE,
                                       x_return_status   => l_return_status,
                                       x_msg_count       => x_msg_count,
                                       x_msg_data        => x_msg_data,
                                       p_cflv_rec        => lp_cflv_rec,
                                       x_cflv_rec        => lx_cflv_rec);
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Updating CFL - Return Status: ' || l_return_status);
                 END IF;

                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

         END IF; --check for Cash flow level.
              l_prev_sty_id := l_sty_id;
	      l_prev_kle_id := l_kle_id; --missed assigntment in bug 5046204
      EXIT WHEN i = p_payment_tbl.LAST;
	    i := p_payment_tbl.NEXT(i);
      END LOOP;
    END IF;
   x_cfo_id := l_cfo_id;
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments'
                                                                        ,'End(-)');
   END IF;

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_stm_payments ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END store_stm_payments;




 PROCEDURE store_payments(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER,
    p_ppd_khr_id        	IN  NUMBER,
    p_payment_structure 	IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_cfo_id            	OUT NOCOPY NUMBER)

 AS

  /*-----------------------------------------------------------------------+
 *  | Subype Declarations                                                   |
 *   +-----------------------------------------------------------------------*/

   SUBTYPE cfov_rec_type IS okl_cash_flow_objects_pub.cfov_rec_type;
   SUBTYPE cafv_rec_type IS okl_cash_flows_pub.cafv_rec_type;
   SUBTYPE cflv_rec_type IS okl_cash_flow_levels_pub.cflv_rec_type;
   SUBTYPE qcov_rec_type IS okl_trx_qte_cf_objects_pub.qcov_rec_type;


 /*-----------------------------------------------------------------------+
 *  | Local Variable Declarations and initializations                       |
 *   +-----------------------------------------------------------------------*/
    lp_cfov_rec                  cfov_rec_type;
    lx_cfov_rec                  cfov_rec_type;

    lp_cafv_rec                  cafv_rec_type;
    lx_cafv_rec                  cafv_rec_type;

    lp_cflv_rec                  cflv_rec_type;
    lx_cflv_rec                  cflv_rec_type;

    lp_qcov_rec                  qcov_rec_type;
    lx_qcov_rec                  qcov_rec_type;


    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'STORE_PAYMENTS';
    l_prev_sty_id		NUMBER;
    l_sty_id			NUMBER;
    l_cfo_id			NUMBER;
    l_caf_id			NUMBER;
    l_cfl_id			NUMBER;
    l_stub_amount		NUMBER;
    l_amount			NUMBER;
    l_currency_code         	VARCHAR2(30);
    l_qco_id       		NUMBER;

    l_prev_cle_id		NUMBER;
    l_cle_id			NUMBER;
    i                   NUMBER := 0;


    CURSOR l_kheaders_csr(cp_khr_id IN NUMBER) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = cp_khr_id;

    CURSOR l_qco_id_csr(cp_qte_id IN NUMBER
                        ,cp_cfo_id  IN  NUMBER
                        ,cp_base_src_id IN  NUMBER) IS
    SELECT id
    FROM OKL_TRX_QTE_CF_OBJECTS
    WHERE qte_id=cp_qte_id
    AND cfo_id=cp_cfo_id
    AND base_source_id=cp_base_src_id;

    CURSOR l_caf_id_csr(cp_qte_id IN NUMBER
                        ,cp_cfo_id  IN  NUMBER
                        ,cp_sty_id IN  NUMBER) IS
    SELECT id
    FROM OKL_CASH_FLOWS
    WHERE cfo_id=cp_cfo_id
    AND dnz_qte_id=cp_qte_id
    AND sty_id = cp_sty_id;

    CURSOR l_cfl_id_csr(cp_caf_id  IN  NUMBER
                        ,cp_start_date IN  DATE) IS
    SELECT id
    FROM OKL_CASH_FLOW_LEVELS
    WHERE caf_id=cp_caf_id
    AND start_date=cp_start_date;


 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_ppd_request_id :'||p_ppd_request_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_ppd_khr_id :'||p_ppd_khr_id);
       FOR i in p_payment_structure.FIRST..p_payment_structure.LAST LOOP
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Chr_Id :'||p_payment_structure(i).Chr_Id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Cle_id :'||p_payment_structure(i).Cle_Id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information1 :'||p_payment_structure(i).Rule_Information1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information2 :'||p_payment_structure(i).Rule_Information2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information3 :'||p_payment_structure(i).Rule_Information3);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information4 :'||p_payment_structure(i).Rule_Information4);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information5 :'||p_payment_structure(i).Rule_Information5);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information6 :'||p_payment_structure(i).Rule_Information6);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information7 :'||p_payment_structure(i).Rule_Information7);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information8 :'||p_payment_structure(i).Rule_Information8);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information9 :'||p_payment_structure(i).Rule_Information9);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information10 :'||p_payment_structure(i).Rule_Information10);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information11 :'||p_payment_structure(i).Rule_Information11);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information12 :'||p_payment_structure(i).Rule_Information12);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information13 :'||p_payment_structure(i).Rule_Information13);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information14 :'||p_payment_structure(i).Rule_Information14);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information15 :'||p_payment_structure(i).Rule_Information15);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information_Category :'||p_payment_structure(i).Rule_Information_Category);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object1_Id1 :'||p_payment_structure(i).Object1_Id1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object1_Id2 :'||p_payment_structure(i).Object1_Id2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object2_Id1 :'||p_payment_structure(i).Object2_Id1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object2_Id2 :'||p_payment_structure(i).Object2_Id2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object3_Id1 :'||p_payment_structure(i).Object3_Id1);
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object3_Id2 :'||p_payment_structure(i).Object3_Id2);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object1_Code :'||p_payment_structure(i).Jtot_Object1_Code);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object2_Code :'||p_payment_structure(i).Jtot_Object2_Code);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object3_Code :'||p_payment_structure(i).Jtot_Object3_Code);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'End of record:' ||i);
        END LOOP;
   END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Printing Variables in store_payments');
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====================================');
 END IF;
	print_messages(p_payment_structure);

   --Get the currency code for the Contract
   OPEN  l_kheaders_csr(p_ppd_khr_id);
   FETCH l_kheaders_csr INTO l_currency_code;
   CLOSE l_kheaders_csr;

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating CFO');
 END IF;
        l_prev_sty_id := 0;
	l_prev_cle_id := 0;

    IF p_payment_structure.count > 0 THEN
      i:= p_payment_structure.FIRST;
     LOOP
   --Create a cash flow object for this type.
          create_cash_flow_object(p_api_version    => p_api_version,
                                  x_msg_count      => x_msg_count,
                       		  x_msg_data       => x_msg_data,
                                  p_obj_type_code  => G_FIN_ASSET_OBJECT_TYPE,
                                  p_src_table      => G_OBJECT_SRC_TABLE,
                                  p_src_id         => p_ppd_request_id,
                                  p_base_src_id    => p_payment_structure(i).cle_id,
                                  x_cfo_id         => l_cfo_id,
                                  x_return_status  => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking for  QCO');
 END IF;
         --Check if this association exists.
	 l_qco_id := NULL;
         OPEN l_qco_id_csr(p_ppd_request_id,l_cfo_id,p_payment_structure(i).cle_id);
         FETCH l_qco_id_csr INTO l_qco_id;
         CLOSE l_qco_id_csr;

         IF l_qco_id IS NULL THEN
             --Create the association to Request and cle_id
             l_qco_id           := NULL;
	     lp_qcov_rec 	:= NULL;
             lp_qcov_rec.qte_id := p_ppd_request_id;
             lp_qcov_rec.cfo_id := l_cfo_id;
             lp_qcov_rec.BASE_SOURCE_ID := p_payment_structure(i).cle_id;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating QCO');
  END IF;

             OKL_TRX_QTE_CF_OBJECTS_PUB.insert_quote_cf_object(p_api_version => p_api_version,
                                                            p_init_msg_list  => OKL_API.G_FALSE,
                                                            x_return_status  => l_return_status,
                                                            x_msg_count      => x_msg_count,
                                                            x_msg_data       => x_msg_data,
                                                            p_qcov_rec       => lp_qcov_rec,
                                                            x_qcov_rec       => lx_qcov_rec);

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating QCO - Return Status: ' || l_return_status);
         END IF;

             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

         END IF;
       --Create the Cash flows for this Object.

        IF p_payment_structure(i).rule_information_category = 'LASLH' THEN
	        	l_sty_id := p_payment_structure(i).object1_id1;
			l_cle_id := p_payment_structure(i).cle_id;
	END IF;

        IF p_payment_structure(i).rule_information_category = 'LASLL' THEN
                --This will be a CASH Flow
                --Create the Cash flow only if it is a different stream type,
                --otherwise only create the lines since it is for the same
                --stream type.
                IF l_sty_id <> l_prev_sty_id  OR  l_cle_id <> l_prev_cle_id THEN
		    l_caf_id := NULL;
                    OPEN l_caf_id_csr(p_ppd_request_id,l_cfo_id,l_sty_id);
                    FETCH l_caf_id_csr INTO l_caf_id;
                    CLOSE l_caf_id_csr;

                    IF l_caf_id is NULL THEN
	 	    	lp_cafv_rec		:= NULL;
                    	lp_cafv_rec.cfo_id := l_cfo_id;
                    	lp_cafv_rec.sts_code := G_PROPOSED_STATUS;
                    	lp_cafv_rec.sty_id := l_sty_id;
                    	lp_cafv_rec.cft_code := G_CASH_FLOW_TYPE;
                    	lp_cafv_rec.due_arrears_yn := nvl(p_payment_structure(i).rule_information10,'N');
        	    	lp_cafv_rec.start_date := FND_DATE.canonical_to_date(
							p_payment_structure(i).rule_information2);
                    	lp_cafv_rec.number_of_advance_periods := p_payment_structure(i).rule_information5;
                    	lp_cafv_rec.dnz_khr_id := p_ppd_khr_id;
                    	lp_cafv_rec.dnz_qte_id := p_ppd_request_id;


   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating CAF');
   END IF;

                	--Call the API to create the Cash Flow.
                         okl_cash_flows_pub.insert_cash_flow(
                             p_api_version              =>    p_api_version,
                             p_init_msg_list            =>    OKL_API.G_FALSE,
                             x_return_status            =>    l_return_status,
                             x_msg_count                =>    x_msg_count,
                             x_msg_data                 =>    x_msg_data,
                             p_cafv_rec                 =>    lp_cafv_rec,
                             x_cafv_rec                 =>    lx_cafv_rec);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating CAF - Return Status: ' || l_return_status);
   END IF;
                         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                         END IF;
                         l_caf_id            := lx_cafv_rec.id;
                    ELSE
	 	    	lp_cafv_rec		:= NULL;
                    	lp_cafv_rec.cfo_id := l_cfo_id;
                    	lp_cafv_rec.sts_code := G_PROPOSED_STATUS;
                    	lp_cafv_rec.sty_id := l_sty_id;
                    	lp_cafv_rec.cft_code := G_CASH_FLOW_TYPE;
                    	lp_cafv_rec.due_arrears_yn := nvl(p_payment_structure(i).rule_information10,'N');
        	    	lp_cafv_rec.start_date := FND_DATE.canonical_to_date(
							p_payment_structure(i).rule_information2);
                    	lp_cafv_rec.number_of_advance_periods := p_payment_structure(i).rule_information5;
                    	lp_cafv_rec.dnz_khr_id := p_ppd_khr_id;
                    	lp_cafv_rec.dnz_qte_id := p_ppd_request_id;
                        lp_cafv_rec.id := l_caf_id;
                       --Call the API to create the Cash Flow.
                        okl_cash_flows_pub.update_cash_flow(
                            p_api_version              =>    p_api_version,
                            p_init_msg_list            =>    OKL_API.G_FALSE,
                            x_return_status            =>    l_return_status,
                            x_msg_count                =>    x_msg_count,
                            x_msg_data                 =>    x_msg_data,
                            p_cafv_rec                 =>    lp_cafv_rec,
                            x_cafv_rec                 =>    lx_cafv_rec);

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Updating CAF - Return Status: ' || l_return_status);
                     END IF;
                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                             RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                     END IF; --Check for existence of Caf
                END IF; --Check for Sty_id

                --Now create the Cash flow lines
		--check if a cash flow line exists of this type.
		l_cfl_id := NULL;
       		OPEN l_cfl_id_csr(l_caf_id, FND_DATE.canonical_to_date(
                                                p_payment_structure(i).rule_information2));
       		FETCH l_cfl_id_csr INTO l_cfl_id;
       		CLOSE l_cfl_id_csr;

       		IF l_cfl_id IS NULL THEN
			lp_cflv_rec	   := NULL;
                	lp_cflv_rec.caf_id := l_caf_id;

                	IF p_payment_structure(i).rule_information7 IS NOT NULL THEN --STUB DAYS
                        	l_stub_amount :=  Okl_Accounting_Util.ROUND_AMOUNT(
					p_amount => p_payment_structure(i).rule_information8,
			        	p_currency_code => l_currency_code);
                        	lp_cflv_rec.stub_days := p_payment_structure(i).rule_information7;
                        	lp_cflv_rec.stub_amount := l_stub_amount;
                	ELSE
                     		l_amount:= Okl_Accounting_Util.ROUND_AMOUNT(
					p_amount => p_payment_structure(i).rule_information6, --amount
			        	p_currency_code => l_currency_code);

                        	lp_cflv_rec.amount := l_amount;
                        	lp_cflv_rec.number_of_periods := p_payment_structure(i).rule_information3;
                        	lp_cflv_rec.fqy_code := p_payment_structure(i).object1_id1;
                	END IF;

                	lp_cflv_rec.level_sequence := p_payment_structure(i).rule_information1;
			lp_cflv_rec.start_date := FND_DATE.canonical_to_date(
						p_payment_structure(i).rule_information2);


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      				OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Creating CFL');
    END IF;
                	OKL_CASH_FLOW_LEVELS_PUB.insert_cash_flow_level(
							p_api_version     =>    p_api_version,
                                                        p_init_msg_list   => OKL_API.G_FALSE,
                                                        x_return_status   => l_return_status,
                                                        x_msg_count       => x_msg_count,
                                                        x_msg_data        => x_msg_data,
                                                        p_cflv_rec        => lp_cflv_rec,
                                                        x_cflv_rec        => lx_cflv_rec);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     			OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Creating CFL - Return Status: ' || l_return_status);
   END IF;

                	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    		RAISE OKL_API.G_EXCEPTION_ERROR;
                	END IF;
                ELSE
			lp_cflv_rec	   := NULL;
                	lp_cflv_rec.caf_id := l_caf_id;

                	IF p_payment_structure(i).rule_information7 IS NOT NULL THEN --STUB DAYS
                        	l_stub_amount :=  Okl_Accounting_Util.ROUND_AMOUNT(
					p_amount => p_payment_structure(i).rule_information8,
			        	p_currency_code => l_currency_code);
                        	lp_cflv_rec.stub_days := p_payment_structure(i).rule_information7;
                        	lp_cflv_rec.stub_amount := l_stub_amount;
                	ELSE
                     		l_amount:= Okl_Accounting_Util.ROUND_AMOUNT(
					p_amount => p_payment_structure(i).rule_information6, --amount
			        	p_currency_code => l_currency_code);

                        	lp_cflv_rec.amount := l_amount;
                        	lp_cflv_rec.number_of_periods := p_payment_structure(i).rule_information3;
                        	lp_cflv_rec.fqy_code := p_payment_structure(i).object1_id1;
                	END IF;

                	lp_cflv_rec.level_sequence := p_payment_structure(i).rule_information1;
			lp_cflv_rec.start_date := FND_DATE.canonical_to_date(
						p_payment_structure(i).rule_information2);


                        lp_cflv_rec.id := l_cfl_id;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Updating CFL');
                 END IF;
                        OKL_CASH_FLOW_LEVELS_PUB.update_cash_flow_level(
					p_api_version     =>    p_api_version,
                                       p_init_msg_list   => OKL_API.G_FALSE,
                                       x_return_status   => l_return_status,
                                       x_msg_count       => x_msg_count,
                                       x_msg_data        => x_msg_data,
                                       p_cflv_rec        => lp_cflv_rec,
                                       x_cflv_rec        => lx_cflv_rec);
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Updating CFL - Return Status: ' || l_return_status);
                 END IF;

                        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                END IF; --check for Cash flow level.

              l_prev_sty_id := l_sty_id;
	      l_prev_cle_id := l_cle_id;
        END IF;    --LASLL Check
       EXIT WHEN i = p_payment_structure.LAST;
	    i := p_payment_structure.NEXT(i);
  	  END LOOP;
    END IF;
	x_cfo_id := l_cfo_id;
 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END store_payments;


PROCEDURE store_principal_payments(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER,
    p_ppd_khr_id        	IN  NUMBER,
    p_payment_structure 	IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_cfo_id            	OUT NOCOPY NUMBER)

 AS
    l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30) := 'store_esg_payments';
    lx_cfo_id			NUMBER;

    l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
    lx_trqv_rec         okl_trx_requests_pub.trqv_rec_type;
    l_pp_sty_id		NUMBER;
    l_upp_sty_id		NUMBER;
    l_payment_tbl	payment_tbl_type ;
    l_store_payment_tbl	payment_tbl_type;
    l_temp_tbl            payment_tbl_type;

    knt			NUMBER := 0;
    i			NUMBER := 0;
    j           NUMBER := 0;
    l_total_k_cost	NUMBER := 0;
    l_asset_cost	NUMBER := 0;
    l_kle_id		NUMBER;
    l_prev_kle_id		NUMBER;
    l_pymt_count		NUMBER :=0;
    l_currency_code             VARCHAR2(30);
    l_raw_ppd_for_asset		NUMBER :=0;
    l_ppd_for_asset		NUMBER :=0;
    l_index                     NUMBER;
    l_ppd_amount                NUMBER := 0;

    CURSOR l_kheaders_csr(cp_khr_id IN NUMBER) IS
    SELECT currency_code
    FROM   okc_k_headers_b
    WHERE  id = cp_khr_id;

    CURSOR c_req_details_csr (a_id NUMBER)
    IS
    SELECT object_Version_number
	      ,payment_amount
	      ,payment_date
    FROM   okl_trx_requests
    WHERE id=a_id;



 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_ppd_request_id :'||p_ppd_request_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_ppd_khr_id :'||p_ppd_khr_id);
       FOR i in p_payment_structure.FIRST..p_payment_structure.LAST LOOP
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Chr_Id :'||p_payment_structure(i).Chr_Id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Cle_id :'||p_payment_structure(i).Cle_Id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information1 :'||p_payment_structure(i).Rule_Information1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information2 :'||p_payment_structure(i).Rule_Information2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information3 :'||p_payment_structure(i).Rule_Information3);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information4 :'||p_payment_structure(i).Rule_Information4);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information5 :'||p_payment_structure(i).Rule_Information5);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information6 :'||p_payment_structure(i).Rule_Information6);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information7 :'||p_payment_structure(i).Rule_Information7);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information8 :'||p_payment_structure(i).Rule_Information8);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information9 :'||p_payment_structure(i).Rule_Information9);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information10 :'||p_payment_structure(i).Rule_Information10);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information11 :'||p_payment_structure(i).Rule_Information11);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information12 :'||p_payment_structure(i).Rule_Information12);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information13 :'||p_payment_structure(i).Rule_Information13);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information14 :'||p_payment_structure(i).Rule_Information14);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information15 :'||p_payment_structure(i).Rule_Information15);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Rule_Information_Category :'||p_payment_structure(i).Rule_Information_Category);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object1_Id1 :'||p_payment_structure(i).Object1_Id1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object1_Id2 :'||p_payment_structure(i).Object1_Id2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object2_Id1 :'||p_payment_structure(i).Object2_Id1);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object2_Id2 :'||p_payment_structure(i).Object2_Id2);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object3_Id1 :'||p_payment_structure(i).Object3_Id1);
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Object3_Id2 :'||p_payment_structure(i).Object3_Id2);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object1_Code :'||p_payment_structure(i).Jtot_Object1_Code);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object2_Code :'||p_payment_structure(i).Jtot_Object2_Code);

           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'p_payment_structure.Jtot_Object3_Code :'||p_payment_structure(i).Jtot_Object3_Code);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments.',
              'End of record:' ||i);
        END LOOP;
   END IF;

       x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint, check compatibility and initialize message list

        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Printing Variables in store_payments');
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====================================');
 END IF;
	print_messages(p_payment_structure);

   --Get the currency code for the Contract
   OPEN  l_kheaders_csr(p_ppd_khr_id);
   FETCH l_kheaders_csr INTO l_currency_code;
   CLOSE l_kheaders_csr;



        OPEN c_req_details_csr(p_ppd_request_id);
        FETCH c_req_details_csr INTO l_trqv_rec.object_Version_number
				  ,l_trqv_rec.payment_amount
				  ,l_trqv_rec.payment_date;
        CLOSE c_req_details_csr;


	--Get the Stream type id for UPP.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_ppd_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_PRINCIPAL_PAYMENT
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_pp_sty_id);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
         END IF;


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Get the Stream type id for UPP.
        OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => p_ppd_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type: '|| x_return_status);
         END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => 'CONTRACT_CAP_AMNT',
                                        p_contract_id   => p_ppd_khr_id,
                                        p_line_id       => NULL,
                                        x_value         => l_total_k_cost);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute CONTRACT_CAP_AMNT: '|| l_total_k_cost || x_return_status);
        END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


      -- loop through the payment structure
        knt := 1;
        i := 0;
    IF p_payment_structure.count > 0 THEN
      i:= p_payment_structure.FIRST;
      --Bug#5046204 start
    LOOP
      IF p_payment_structure(i).rule_information_category = 'LASLH' THEN
         l_pp_sty_id := p_payment_structure(i).object1_id1;
      END IF;
      --Bug#5046204 end
      IF p_payment_structure(i).rule_information_category = 'LASLL' THEN
         l_payment_tbl(knt).khr_id := p_payment_Structure(i).chr_id;
         l_payment_tbl(knt).kle_id := p_payment_structure(i).cle_id;
         l_payment_tbl(knt).sty_id := l_pp_sty_id;
         l_payment_tbl(knt).start_date := FND_DATE.canonical_to_date(p_payment_structure(i).rule_information2);
         l_payment_tbl(knt).periods := p_payment_structure(i).rule_information3;
         l_payment_tbl(knt).frequency := p_payment_structure(i).object1_id1;
         l_payment_tbl(knt).arrears_yn := p_payment_structure(i).rule_information10;
         l_payment_tbl(knt).amount  := p_payment_structure(i).rule_information6;
         l_payment_tbl(knt).stub_days := p_payment_structure(i).rule_information7;
         l_payment_tbl(knt).stub_amount := p_payment_structure(i).rule_information8;
         knt := knt + 1;
      END IF;
      EXIT WHEN i = p_payment_structure.LAST;
        i := p_payment_structure.NEXT(i);
      END LOOP;
    END IF;

    PRINT_STM_PAYMENTS(l_payment_tbl);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before updating ppd amounts');
   END IF;

	l_prev_kle_id	:= -99;
        knt := 1;
        j := 0;
    IF l_payment_tbl.count > 0 THEN
      j:= l_payment_tbl.FIRST;
      LOOP
		l_kle_id	:= l_payment_tbl(j).kle_id;
		--ESG will not populate the styid for rent
		--so populate for each row.
        	l_store_payment_tbl(knt) :=  l_payment_tbl(j);
		--l_store_payment_tbl(knt).sty_id	:= l_rent_sty_id;

		If l_kle_id <> l_prev_kle_id THEN
			l_prev_kle_id := l_kle_id;

			OKL_EXECUTE_FORMULA_PUB.execute(
				p_api_version => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_formula_name  => 'LINE_CAP_AMNT',
                                p_contract_id   => p_ppd_khr_id,
                                p_line_id       => l_kle_id,
                                x_value         => l_asset_cost);

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After execute LINE_CAP_AMNT: '|| l_asset_cost);
                        END IF;
                        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                                raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                                raise OKC_API.G_EXCEPTION_ERROR;
                        End If;

                        --Pro rate the ppd amt for this line
                        l_raw_ppd_for_asset := (l_asset_cost/l_total_k_cost)
                                                        * l_trqv_rec.payment_amount;

                        l_ppd_for_asset := Okl_Accounting_Util.ROUND_AMOUNT(
                                                p_amount => l_raw_ppd_for_asset,
                                                p_currency_code => l_currency_code);
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PPD for Asset : '|| l_ppd_for_asset);
                        END IF;

			knt := knt +1;
        		l_store_payment_tbl(knt).KHR_ID     := p_ppd_khr_id;
                	l_store_payment_tbl(knt).KLE_ID     := l_kle_id;
                	l_store_payment_tbl(knt).STY_ID     := l_upp_sty_id;
                	l_store_payment_tbl(knt).start_date := l_trqv_rec.payment_date;
                	l_store_payment_tbl(knt).stub_days  := 1;
                	l_store_payment_tbl(knt).stub_amount:= l_ppd_for_asset;
			--Bug#5511937 by dkagrawa start
                        l_index := knt;
                        l_ppd_amount := l_ppd_amount + l_ppd_for_asset;
                        --Bug#5511937 end
		END IF;
		knt := knt +1;
		EXIT WHEN j = l_payment_tbl.LAST;
	    j := l_payment_tbl.NEXT(j);
  	  END LOOP;
    END IF;
    --Bug#5511937 by dkagrawa start
    IF ( l_trqv_rec.payment_amount - l_ppd_amount <> 0 ) THEN
      l_store_payment_tbl(l_index).stub_amount := l_store_payment_tbl(l_index).stub_amount + (l_trqv_rec.payment_amount - l_ppd_amount );
    END IF;
    --Bug#5511937 end


	PRINT_STM_PAYMENTS(l_store_payment_tbl);

	--Call the Store stm payments api.
                store_stm_payments(p_api_version  => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => x_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_ppd_request_id => p_ppd_request_id,
                              p_ppd_khr_id     => p_ppd_khr_id,
                              p_payment_tbl    => l_store_payment_tbl,
                              x_cfo_id         => lx_cfo_id);
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Store stm payments in ESG Inbound:' || x_return_status
                                || 'CFO Id: '|| lx_cfo_id);
                END IF;
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_esg_payments'
                                                                        ,'End(-)');
  	END IF;



 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.store_payments ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END store_principal_payments;


  PROCEDURE extract_payments(
    p_ppd_request_id    	IN  NUMBER,
    p_payment_struc         OUT NOCOPY okl_mass_rebook_pvt.strm_lalevl_tbl_type)
  IS

    i               NUMBER := 1;
    l_prev_sty_id   NUMBER := -1;

    CURSOR get_payments_csr(a_id NUMBER)
    IS
    SELECT  dnz_khr_id
            ,kle_id
            ,sty_id
            ,frequency_code
            ,Arrears
            ,number_of_periods
            ,amount
            ,stub_days
            ,stub_amount
            ,start_date
            ,advance_payments
    FROM    OKL_CS_PPD_PAYMENTS_UV
    WHERE   request_id = a_id
    order by kle_id,sty_id,start_date;


  BEGIN

    --Populate the Payments Table
    --Sample payments
    --RENT - Asset A1 -Advance - For Contract K1
    --3 Months 100$ 01-01-2004
    --6 Months 90$ 04-01-2004
    --3 Months 150$ 10-01-2004
    --PPD - Asset A1 - for Contract K1
    --1 Stub for 1 day - Start on 15-AUG-2004 for 1000$


    --Sample payment table should look like this.
    --SLH1
    --p_payment_struc(1).chr_id   := K1;
    --p_payment_struc(1).cle_id   := A1;
    --p_payment_struc(1).RULE_INFORMATION_CATEGORY := 'LASLH';
    --p_payment_struc(1).OBJECT1_ID1 := 251601487757888615031160220891184821165; --Sty id

    --SLL1.1
    --  p_payment_struc(2).chr_id   := K1;
    --  p_payment_struc(2).cle_id   := A1;
    --  p_payment_struc(2).RULE_INFORMATION2 := '2004/01/01 00:00:00';
    --  p_payment_struc(2).RULE_INFORMATION3 := '3';
    --  p_payment_struc(2).RULE_INFORMATION5 := '0'; --Adv Period
    --  p_payment_struc(2).RULE_INFORMATION6 := '100';
    --  p_payment_struc(2).RULE_INFORMATION7 := 'Stub Days';
    --  p_payment_struc(2).RULE_INFORMATION8 := 'Stub Amount;
    --  p_payment_struc(2).RULE_INFORMATION_CATEGORY := 'LASLL';
    --  p_payment_struc(2).OBJECT1_ID1 := 'M';  --Freq
    --  p_payment_struc(2).Jtot_Object2_Code := 'OKL_STRMHDR';
    --SLL1.2
    --  p_payment_struc(3).chr_id   := K1;
    --  p_payment_struc(3).cle_id   := A1;
    --  p_payment_struc(3).RULE_INFORMATION2 := '2004/04/01 00:00:00';
    --  p_payment_struc(3).RULE_INFORMATION3 := '6';
    --  p_payment_struc(3).RULE_INFORMATION5 := '0';
    --  p_payment_struc(3).RULE_INFORMATION6 := '90';
    --  p_payment_struc(3).RULE_INFORMATION7 := 'Stub Days';
    --  p_payment_struc(3).RULE_INFORMATION8 := 'Stub Amount;
    --  p_payment_struc(3).RULE_INFORMATION_CATEGORY := 'LASLL';
    --  p_payment_struc(3).OBJECT1_ID1 := 'M';
    --  p_payment_struc(3).Jtot_Object2_Code := 'OKL_STRMHDR';
    --
    --SLL1.3
    --  p_payment_struc(4).RULE_INFORMATION2 := '2004/10/01 00:00:00';
    --  p_payment_struc(4).RULE_INFORMATION3 := '3';
    --  p_payment_struc(4).RULE_INFORMATION5 := '0';
    --  p_payment_struc(4).RULE_INFORMATION6 := '120';
    --  p_payment_struc(4).RULE_INFORMATION7 := 'Stub Days';
    --  p_payment_struc(4).RULE_INFORMATION8 := 'Stub Amount;
    --  p_payment_struc(4).RULE_INFORMATION_CATEGORY := 'LASLL';
    --  p_payment_struc(4).OBJECT1_ID1 := 'M';
    --  p_payment_struc(4).Jtot_Object2_Code := 'OKL_STRMHDR';


    --SLH2
    --p_payment_struc(1).chr_id   := K1;
    --p_payment_struc(1).cle_id   := A1;
    --p_payment_struc(1).RULE_INFORMATION_CATEGORY := 'LASLH';
    --p_payment_struc(1).OBJECT1_ID1 := sty_id for PPD; --Sty id

    --SLL2.1
    --  p_payment_struc(2).chr_id   := K1;
    --  p_payment_struc(2).cle_id   := A1;
    --  p_payment_struc(2).RULE_INFORMATION2 := '2004/15/01 00:00:00';
    --  p_payment_struc(2).RULE_INFORMATION3 := NULL; --No of periods
    --  p_payment_struc(2).RULE_INFORMATION5 := '0'; --Adv Period
    --  p_payment_struc(2).RULE_INFORMATION6 := NULL; --Amount
    --  p_payment_struc(2).RULE_INFORMATION7 := 1; --Stub Days
    --  p_payment_struc(2).RULE_INFORMATION8 := 1000; -- Stub Amount
    --  p_payment_struc(2).RULE_INFORMATION_CATEGORY := 'LASLL';
    --  p_payment_struc(2).OBJECT1_ID1 := 'M'; --Freq
    --  p_payment_struc(2).Jtot_Object2_Code := 'OKL_STRMHDR';


    FOR cur_rec in get_payments_csr(p_ppd_request_id) LOOP
        IF l_prev_sty_id <>  cur_rec.sty_id THEN --Same Sty type so make it LASLH
            p_payment_struc(i).chr_id :=  cur_rec.dnz_khr_id;
            p_payment_struc(i).cle_id :=  cur_rec.kle_id;
            p_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLH';
            p_payment_struc(i).OBJECT1_ID1 :=  cur_rec.sty_id;
	    p_payment_struc(i).Jtot_Object1_Code := 'OKL_STRMTYP';
            i := i +1;
        END IF;

            --Now populate LASLLs
            p_payment_struc(i).chr_id :=  cur_rec.dnz_khr_id;
            p_payment_struc(i).cle_id :=  cur_rec.kle_id;
            p_payment_struc(i).RULE_INFORMATION2 := fnd_date.date_to_canonical(cur_rec.start_date);
            p_payment_struc(i).RULE_INFORMATION3 := cur_rec.number_of_periods;
		--This will Null for Stubs,but we need to pass a value,
		--so passing zero
            p_payment_struc(i).RULE_INFORMATION5 := NVL(cur_rec.advance_payments,0); --Adv Period
            p_payment_struc(i).RULE_INFORMATION6 := cur_rec.amount;
            p_payment_struc(i).RULE_INFORMATION7 := cur_rec.stub_days;
            p_payment_struc(i).RULE_INFORMATION8 := cur_rec.stub_amount;
            p_payment_struc(i).RULE_INFORMATION10 := cur_rec.arrears;
            p_payment_struc(i).RULE_INFORMATION_CATEGORY := 'LASLL';
		--This will Null for Stubs,but we need to pass an amount.
            p_payment_struc(i).OBJECT1_ID1 := NVL(cur_rec.frequency_code,'M');  --Freq
            --asawanka added for bug #6679623 start
            p_payment_struc(i).OBJECT2_ID2 := '#';
            --asawanka added for bug #6679623 end
	    p_payment_struc(i).Jtot_Object1_Code := 'OKL_TUOM';
	    p_payment_struc(i).Jtot_Object2_Code := 'OKL_STRMHDR';

        i := i + 1;
        l_prev_sty_id :=  cur_rec.sty_id;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);
  END extract_payments;


 PROCEDURE process_ppd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER)
  AS

	l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_PPD';
	l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
	lx_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

	l_post_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

	l_kle_tbl        OKL_MASS_REBOOK_PVT.kle_tbl_type;
	l_payment_struc  okl_mass_rebook_pvt.strm_lalevl_tbl_type;
        i                   NUMBER := 1;
	l_tcnv_rec                   OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

	CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT dnz_khr_id
           ,payment_date
           ,payment_amount
           ,object_Version_number
	   ,request_status_code
	FROM   okl_trx_requests
	WHERE id=a_id;

    	CURSOR c_kle_id_csr (a_id NUMBER)
    	IS
    	SELECT base_source_id
    	FROM okl_trx_qte_cf_objects
    	WHERE qte_id=a_id;


   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd.',
              'p_ppd_request_id :'||p_ppd_request_id);
    END IF;

    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

   --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Get the request details.
	l_trqv_rec.id := p_ppd_request_id;

	OPEN c_obj_vers_csr(l_trqv_rec.id);
	FETCH c_obj_vers_csr INTO l_trqv_rec.dnz_khr_id
                              ,l_trqv_rec.payment_date
                              ,l_trqv_rec.payment_amount
                              ,l_trqv_rec.object_Version_number
                              ,l_trqv_rec.request_status_code;

	CLOSE c_obj_vers_csr;

      --Bug# 8756653
      -- Check if contract has been upgraded for effective dated rebook
      OKL_LLA_UTIL_PVT.check_rebook_upgrade
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => l_trqv_rec.dnz_khr_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    --Create the PPD Transaction in OKL_TRX_CONTRACTS
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call to okl_transaction_pvt.create_ppd_transaction');
   END IF;
   okl_transaction_pvt.create_ppd_transaction(
         p_api_version        => p_api_version,
         p_init_msg_list      => p_init_msg_list,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_chr_id             => l_trqv_rec.dnz_khr_id,
         p_trx_date           => l_trqv_rec.payment_date,
         p_trx_type           => 'PPD',
         p_reason_code        => G_PPD_REASON_CODE,
         x_tcnv_rec           => l_tcnv_rec);

   if (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error occurred from okl_transaction_pvt.create_ppd_transaction');
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_msg_data=' || x_msg_data);
     END IF;
   end if;
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
   END IF;




	l_trqv_rec.request_status_code := 'ACCEPTED';
        l_trqv_rec.tcn_id              := l_tcnv_rec.id;

    --Update the status of the Request to "ACCEPTED"
	okl_trx_requests_pub.update_trx_requests( p_api_version         => p_api_version,
                                                p_init_msg_list 	=> p_init_msg_list,
                                                x_return_status       	=> x_return_status,
                                                x_msg_count           	=> x_msg_count,
                                                x_msg_data            	=> x_msg_data,
                                                p_trqv_rec            	=> l_trqv_rec,
                                                x_trqv_rec            	=> lx_trqv_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated Request to ACCEPTED');
   END IF;
    --Call the Rebook API to Rebook the contract.

    --Populate the kle ids Table.
    FOR cur_rec in c_kle_id_csr(p_ppd_request_id) LOOP

        l_kle_tbl(i).id :=  cur_rec.base_source_id;
        i := i+ 1;
    END LOOP;

    --Populate the Payments Table

	extract_payments(p_ppd_request_id	=>  p_ppd_request_id
			,p_payment_struc	=>  l_payment_struc);

	IF (l_payment_struc.count = 0 ) THEN

		OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_CS_PPD_NO_PAYMENTS');
                RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	 --Print out the payment structure:

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=== Print out the payment structure before passing to OKL_PROCESS_PPD_PVT.apply_ppd === ');
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Starting the Loop ....');
 END IF;
	 FOR j in l_payment_struc.FIRST..l_payment_struc.LAST LOOP
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'  ');
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).chr_id ' || j ||' - '||l_payment_struc(j).chr_id);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).cle_id ' || j ||' - '||l_payment_struc(j).cle_id);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION_CATEGORY ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION_CATEGORY);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION2 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION2);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION3 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION3);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION5 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION5);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION6 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION6);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION7 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION7);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION8 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION8);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).RULE_INFORMATION10 ' || j ||' - '|| l_payment_struc(j).RULE_INFORMATION10);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).OBJECT1_ID1 ' || j ||' - '|| l_payment_struc(j).OBJECT1_ID1);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).jtot_object1_code ' || j ||' - '|| l_payment_struc(j).jtot_object1_code);
  	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_payment_struc(j).jtot_object2_code ' || j ||' - '|| l_payment_struc(j).jtot_object2_code);
 END IF;

	 END LOOP;



       OKL_PROCESS_PPD_PVT.apply_ppd(p_api_version     => p_api_version,
                                  p_init_msg_list 	=> p_init_msg_list,
                                  x_return_status   => x_return_status,
                                  x_msg_count       => x_msg_count,
                                  x_msg_data        => x_msg_data,
                                  p_chr_id          => l_trqv_rec.dnz_khr_id,
                                  p_kle_tbl         => l_kle_tbl,
                                  p_transaction_date => l_trqv_rec.payment_date,
                                  p_ppd_amount      => l_trqv_rec.payment_amount,
                                  p_ppd_reason_code  => G_PPD_REASON_CODE,
                                  p_payment_struc   =>  l_payment_struc,
                                  p_ppd_txn_id      => l_tcnv_rec.id);


            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return Status after call to apply_ppd: '|| x_return_status);
            END IF;
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    --Now the Rebook process has comeback succesffuly.
    --Update the status to "REBOOK_IN_PROCESS"

    	l_post_trqv_rec.id := p_ppd_request_id;

	OPEN c_obj_vers_csr(l_post_trqv_rec.id);
	FETCH c_obj_vers_csr INTO l_post_trqv_rec.dnz_khr_id
                              ,l_post_trqv_rec.payment_date
                              ,l_post_trqv_rec.payment_amount
                              ,l_post_trqv_rec.object_Version_number
                              ,l_post_trqv_rec.request_status_code;

	CLOSE c_obj_vers_csr;

    IF l_post_trqv_rec.request_status_code NOT IN ('REBOOK_COMPLETE','REBOOK_IN_COMPLETE','PROCESSED') THEN
	l_post_trqv_rec.request_status_code := 'REBOOK_IN_PROCESS';
	--l_post_trqv_rec.tcn_id      := lx_ppd_txn_id;

	okl_trx_requests_pub.update_trx_requests( p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_trqv_rec      => l_post_trqv_rec,
                                                x_trqv_rec      => lx_trqv_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    END IF;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd','End(+)');
    END IF;

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END process_ppd;


--************************************************************************
-- API for maeking the ppd stream as billed.
-- Parameters: Contract Id, request Id Id
-- LOGIC:

--************************************************************************


  PROCEDURE invoice_bill_apply(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER
                ,p_req_id               IN  NUMBER) IS

	l_api_name          CONSTANT 	VARCHAR2(30) := 'INVOICE_BILL_APPLY';
	l_contract_number	     	VARCHAR2(100);
	l_payment_date			DATE;
	l_from_bill_date		DATE;
	l_to_bill_date			DATE;
	l_receipt_id			NUMBER;
	l_receipt_amount		NUMBER :=0; --Pass this as 0 as per BVAGHELA
        l_receipt_date                  DATE;

	l_ar_inv_tbl 		OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type;
        l_xcav_tbl              OKL_BPD_ADVANCED_CASH_APP_PVT.xcav_tbl_type;
	CURSOR c_get_k_number (c_id NUMBER)
	IS
	SELECT contract_number
	from okc_k_headers_b
	where id=c_id;

	CURSOR c_get_req_details(c_req_id NUMBER)
	IS
	SELECT payment_date
	      ,receipt_id
	FROM okl_trx_requests
	where id=c_req_id;

        --Bug#5032427 added cursor to get receipt_date by dkagrawa
        CURSOR  c_get_rcpt_date (c_rcpt_id IN NUMBER)
        IS
        SELECT receipt_date
        FROM OKL_CS_PPD_RECEIPTS_UV
        WHERE receipt_id = c_rcpt_id;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_bill_apply'
                                                                        ,'Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_bill_apply.',
              'p_request_id :'||p_req_id);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_bill_apply.',
              'p_khr_id :'||p_khr_id);
    END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Entering invoice_bill_apply api:');
        END IF;

        x_return_status    := OKL_API.G_RET_STS_SUCCESS;

        --Call start_activity to create savepoint,
        --check compatibility and initialize message list
/*
        x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

        --Check if activity started successfully

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
*/

	OPEN c_get_k_number(p_khr_id);
	FETCH c_get_k_number INTO l_contract_number;
	CLOSE c_get_k_number;

	OPEN c_get_req_details(p_req_id);
	FETCH c_get_req_details INTO l_payment_date,l_receipt_id;
	CLOSE c_get_req_details;

	--Set the dates for billing:
	l_from_bill_date := l_payment_date -1;
	l_to_bill_date := l_payment_date + 1;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Calling Invoice api:');
        END IF;
	--Call the API to invoice the ppd stream
        OKL_BPD_ADVANCED_BILLING_PVT.advanced_billing( p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_contract_number  => l_contract_number,
                                                p_from_bill_date => l_from_bill_date,
                                                p_to_bill_date  => l_to_bill_date,
                                                p_source  => 'PRINCIPAL_PAYDOWN',
                                                x_ar_inv_tbl      => l_ar_inv_tbl,
						p_ppd_flow => 'Y');

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Calling Invoice api: Count is :'|| l_ar_inv_tbl.COUNT);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return Status after call to advanced_billing : '|| x_return_status);
        END IF;

	--Now call the Receipt application API to apply the receipt to these
	--AR invoices.
    IF l_receipt_id IS NOT NULL AND x_return_status = 'S' THEN
        --Bug#5032427 added cursor to get receipt_date by dkagrawa
       OPEN c_get_rcpt_date(l_receipt_id);
       FETCH c_get_rcpt_date INTO l_receipt_date;
       CLOSE c_get_rcpt_date;
       --Bug# 5032427 end
       OKL_BPD_ADVANCED_CASH_APP_PUB.AR_ADVANCE_RECEIPT( p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
						p_xcav_tbl	=> l_xcav_tbl,
                                                p_receipt_id    => l_receipt_id,
						p_receipt_amount => l_receipt_amount, --PAss this as Zero
                                                p_receipt_date  => l_receipt_date,  --Bug#5032427
                                                p_ar_inv_tbl    => l_ar_inv_tbl);

    END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return Status at the end of invoice_bill_apply : '|| x_return_status);
 END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.invoice_bill_apply'
                                                                        ,'End(-)');
    END IF;
/*
  EXCEPTION


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
*/
  END invoice_bill_apply;

PROCEDURE process_lpd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER)
  AS

	l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_PPD';
	l_trqv_rec          okl_trx_requests_pub.trqv_rec_type;
	lx_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

	l_post_trqv_rec          okl_trx_requests_pub.trqv_rec_type;

	l_kle_tbl        OKL_MASS_REBOOK_PVT.kle_tbl_type;
	l_payment_struc  okl_mass_rebook_pvt.strm_lalevl_tbl_type;
	l_tcnv_rec                   OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
        l_out_tcnv_rec               OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

	CURSOR c_obj_vers_csr (a_id NUMBER)
	IS
	SELECT id
           ,dnz_khr_id
           ,payment_date
           ,payment_amount
           ,object_Version_number
	   ,request_status_code,
           paydown_type
	FROM   okl_trx_requests
	WHERE id=a_id;

    	CURSOR c_kle_id_csr (a_id NUMBER)
    	IS
    	SELECT base_source_id
    	FROM okl_trx_qte_cf_objects
    	WHERE qte_id=a_id;


        CURSOR try_csr_lpd IS
        SELECT id
        FROM   okl_trx_types_tl
        WHERE  LANGUAGE = 'US'
        AND    name     = 'Loan Paydown';

        CURSOR try_csr_ppd IS
        SELECT id
        FROM okl_trx_types_tl
        WHERE LANGUAGE = 'US'
        AND name = 'Principal Paydown';

        CURSOR con_header_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
        SELECT currency_code,
               authoring_org_id
        FROM   okl_k_headers_full_v
        WHERE  id = p_chr_id;

        CURSOR c_tran_num_csr IS
        SELECT  okl_sif_seq.nextval
        FROM    dual;

        CURSOR c_stm_id_line_number(c_stm_id NUMBER) IS
        SELECT SE_LINE_NUMBER
        FROM   OKL_STRM_ELEMENTS_V
        WHERE  stm_id = c_stm_id
        ORDER BY SE_LINE_NUMBER DESC;

         l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
         lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
         l_selv_rec          Okl_Streams_Pub.selv_rec_type;
         lx_selv_rec         Okl_Streams_Pub.selv_rec_type;
         L_rulv_tbl_type     OKL_RULE_PUB.rulv_tbl_type;
         l_pym_hdr_rec       okl_la_payments_pvt.pym_hdr_rec_type;
         l_pym_tbl           okl_la_payments_pvt.pym_tbl_type;

     CURSOR c_unscheduled_payment_str(p_contract_id IN NUMBER,
                                     p_sty_id      IN NUMBER) IS
    SELECT  rgp.cle_id cle_id,
        sttyp.id1   sty_id,
        sttyp.code  stream_type,
        tuom.id1 frequency,
        sll_rul.id rule_id,
        sll_rul.rule_information1 seq_num,
        to_date(sll_rul.rule_information2,'YYYY/MM/DD HH24:MI:SS') start_date,
        sll_rul.rule_information3 period_in_months,
        sll_rul.rule_information5 advance_periods,
        sll_rul.rule_information6 amount,
        sll_rul.rule_information10 due_arrears_yn,
        sll_rul.rule_information7 stub_days,
        sll_rul.rule_information8 stub_amount,
        rgp.dnz_chr_id khr_id
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    and     rgp.dnz_chr_id = p_contract_id
    AND     sttyp.id1 = p_sty_id;

     CURSOR c_unscheduled_count(p_contract_id IN NUMBER,
                                     p_sty_id      IN NUMBER) IS
    SELECT  COUNT(*)
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    and     rgp.dnz_chr_id = p_contract_id
    AND     sttyp.id1 = p_sty_id;

    CURSOR c_max_date(p_contract_id IN NUMBER,
                      p_sty_id      IN NUMBER) IS
	SELECT  max(to_date(sll_rul.rule_information2,'YYYY/MM/DD HH24:MI:SS')) start_date
    FROM    okl_time_units_v tuom,
        okc_rules_b sll_rul,
        okl_strmtyp_source_v sttyp,
        okc_rules_b slh_rul,
        okc_rule_groups_b rgp
    WHERE   tuom.id1      = sll_rul.object1_id1
    AND     sll_rul.object2_id1 = to_char(slh_rul.id)
    AND     sll_rul.rgp_id    = rgp.id
    AND     sll_rul.rule_information_category = 'LASLL'
    AND     sttyp.id1 = slh_rul.object1_id1
    AND     slh_rul.rgp_id = rgp.id
    AND     slh_rul.rule_information_category = 'LASLH'
    AND     rgp.rgd_code = 'LALEVL'
    and     rgp.dnz_chr_id = p_contract_id
    AND     sttyp.id1 = p_sty_id;


    CURSOR c_contract_details(p_contract_id IN NUMBER) IS
    SELECT *
    FROM OKC_K_HEADERS_B
    WHERE ID = p_contract_id;
    l_contract_id      NUMBER ;

    l_contract_rec    okc_k_headers_b%rowtype;
    l_ppd_date       DATE;
    l_ppd_amount     NUMBER;
    l_new_start_date DATE;
    l_next_start_dt  DATE;
    l_no_months      NUMBER;
    l_no_Days        NUMBER;
    l_count          NUMBER;
    l_ppd_day        NUMBER;
    l_start_dt_day   NUMBER;
    i                NUMBER := 1;
    l_max_date       DATE;
    j                NUMBER;
    l_previous_month DATE;
    l_last_day       NUMBER;
    l_try_id            NUMBER;
    l_upp_sty_id        NUMBER;
    l_sty_id            NUMBER;
    l_khr_id            NUMBER;
    l_kle_id            NUMBER;
    l_rule_id           NUMBER;
    l_comments          VARCHAR2(1995);

   BEGIN
     IF (G_DEBUG_ENABLED = 'Y') THEN
       G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
     END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_lpd','Begin(+)');
    END IF;

    --Print Input Variables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_lpd.',
              'p_ppd_request_id :'||p_ppd_request_id);
    END IF;

    x_return_status    := OKL_API.G_RET_STS_SUCCESS;

   --Call start_activity to create savepoint, check compatibility and initialize message list

    x_return_status := OKL_API.START_ACTIVITY(
                              l_api_name
                              ,p_init_msg_list
                              ,'_PVT'
                              ,x_return_status);

    --Check if activity started successfully

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Get the request details.
	l_trqv_rec.id := p_ppd_request_id;

	OPEN c_obj_vers_csr(l_trqv_rec.id);
	FETCH c_obj_vers_csr INTO l_trqv_rec.id
                              ,l_trqv_rec.dnz_khr_id
                              ,l_trqv_rec.payment_date
                              ,l_trqv_rec.payment_amount
                              ,l_trqv_rec.object_Version_number
                              ,l_trqv_rec.request_status_code
                              ,l_trqv_rec.paydown_type;

	CLOSE c_obj_vers_csr;

    --Create the LPD Transaction in OKL_TRX_CONTRACTS
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call to okl_transaction_pvt.create_ppd_transaction');
   END IF;
    l_try_id := NULL;

  --check the type of paydown
   IF l_trqv_rec.paydown_type = 'L' THEN
      OPEN try_csr_lpd;
      FETCH try_csr_lpd INTO l_try_id;
      CLOSE try_csr_lpd;
      l_tcnv_rec.description := 'Loan Paydown';
   ELSIF l_trqv_rec.paydown_type = 'P' THEN
      OPEN try_csr_ppd;
      FETCH try_csr_ppd INTO l_try_id;
      CLOSE try_csr_ppd;
      l_tcnv_rec.description := 'Principal Paydown';
   END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER getting try id');
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Try ID: '||l_try_id);
      END IF;

      l_tcnv_rec.try_id                    := l_try_id;
      l_tcnv_rec.tsu_code                  := 'ENTERED';
      l_tcnv_rec.tcn_type                  := 'LPD';
      l_tcnv_rec.khr_id                    := l_trqv_rec.dnz_khr_id;
      l_tcnv_rec.date_transaction_occurred := l_trqv_rec.payment_date;
      l_tcnv_rec.legal_entity_id           := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_trqv_rec.dnz_khr_id); --dkagrawa added to populate le_id

      FOR con_header_rec IN con_header_csr (l_trqv_rec.dnz_khr_id)
      LOOP
         l_tcnv_rec.org_id        := con_header_rec.authoring_org_id;
         l_tcnv_rec.currency_code := con_header_rec.currency_code;
      END LOOP;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'BEFORE calling okl_trx_contracts_pub.create_trx_contracts');
 END IF;
      -- Create Transaction Header only
      okl_trx_contracts_pub.create_trx_contracts(
                                                 p_api_version    => 1.0,
                                                 p_init_msg_list  => p_init_msg_list,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_tcnv_rec       => l_tcnv_rec,
                                                 x_tcnv_rec       => l_out_tcnv_rec
                                                );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AFTER calling okl_trx_contracts_pub.create_trx_contracts');
      END IF;

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;



   if (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error occurred from creating loan transactions');
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'x_msg_data=' || x_msg_data);
     END IF;
   end if;
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
   END IF;




	l_trqv_rec.request_status_code := 'ACCEPTED';
        l_trqv_rec.tcn_id              := l_out_tcnv_rec.id;

    --Update the status of the Request to "ACCEPTED"
	okl_trx_requests_pub.update_trx_requests( p_api_version         => p_api_version,
                                                p_init_msg_list 	=> p_init_msg_list,
                                                x_return_status       	=> x_return_status,
                                                x_msg_count           	=> x_msg_count,
                                                x_msg_data            	=> x_msg_data,
                                                p_trqv_rec            	=> l_trqv_rec,
                                                x_trqv_rec            	=> lx_trqv_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated Request to ACCEPTED');
   END IF;

--get the dependent stream type
    --check whether loan paydown or principal paydown
    IF l_trqv_rec.paydown_type = 'L' THEN
        l_comments := 'Unscheduled Loan Payment';

         OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => l_trqv_rec.dnz_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_LP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type LP: '|| x_return_status);
        END IF;


	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    ELSIF l_trqv_rec.paydown_type = 'P' THEN
      l_comments := 'Unscheduled Principal Payment';
      OKL_STREAMS_UTIL.get_dependent_stream_type(
                 p_khr_id                        => l_trqv_rec.dnz_khr_id
                 ,p_primary_sty_purpose          => G_RENT_STREAM
                 ,p_dependent_sty_purpose        => G_UNSCHED_PP_STREAM
                 ,x_return_status                => x_return_status
                 ,x_dependent_sty_id             => l_upp_sty_id);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After get_depend_stream type PP: '|| x_return_status);
        END IF;


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

--Updating Payments on the contract
--Bug # 4880714
  l_contract_id  := l_trqv_rec.dnz_khr_id;
  l_ppd_date     := l_trqv_rec.payment_date;
  l_ppd_amount  :=  l_trqv_rec.payment_amount;

   OPEN c_unscheduled_count(l_contract_id,l_upp_sty_id);
   FETCH c_unscheduled_count INTO l_count;
   CLOSE c_unscheduled_count;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'payment count: ' ||l_count);
   END IF;

   OPEN c_contract_details(l_contract_id);
   FETCH c_contract_details INTO l_contract_rec;
   CLOSE c_contract_details;

   OPEN c_max_date(l_contract_id,l_upp_sty_id);
   FETCH c_max_date INTO l_max_date;
   CLOSE c_max_date;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'maximum date on the payments: '||l_max_date);
  END IF;


--Populating the Payment header record.
     l_pym_hdr_rec.structure       := '0';
     l_pym_hdr_rec.frequency       := 'M';
     l_pym_hdr_rec.arrears         := 'N';

     IF NVL(l_count,0) = 0 THEN
        l_no_months := FLOOR(MONTHS_BETWEEN(l_ppd_date,l_contract_rec.start_date));
        l_ppd_day := to_number(substr(to_char(l_ppd_date,'DD-MON-YY'),1,2));
        l_start_dt_day := to_number(substr(to_char(l_contract_rec.start_date,'DD-MON-YY'),1,2));

        IF l_ppd_day > l_start_dt_day THEN
           l_no_days := l_ppd_day - l_start_Dt_day;
        ELSIF l_start_dt_day > l_ppd_day THEN
          l_previous_month := l_ppd_date - 30;
          l_no_months := FLOOR(MONTHS_BETWEEN(l_previous_month,l_contract_rec.start_date));
          l_last_day  := substr(to_char(last_day(trunc(l_previous_month)),'DD-MON-YYYY'),1,2);
          l_no_days  := (l_last_day - l_start_dt_day) + l_ppd_day;
        ELSIF l_ppd_day = l_start_dt_day THEN
          l_no_days := 0;
        END IF;

        l_new_start_date := ADD_MONTHS(l_contract_rec.start_date,l_no_months);

       IF l_no_months > 0 THEN
         l_pym_tbl(1).amount := 0;
         l_pym_tbl(1).period   := l_no_months;
         l_pym_tbl(1).update_type := 'CREATE';

         IF l_no_days <> 0 THEN
           l_pym_tbl(2).stub_amount := 0;
           l_pym_tbl(2).stub_days   := l_no_days;
           l_pym_tbl(2).update_type := 'CREATE';
         END IF;
       ELSE
         IF l_ppd_day > l_start_dt_day THEN
           l_no_days := l_ppd_day - l_start_Dt_day;
         ELSIF l_start_dt_day > l_ppd_day THEN
           l_last_day  := substr(to_char(last_day(trunc(l_contract_rec.start_Date)),'DD-MON-YYYY'),1,2);
           l_no_days  := (l_last_day - l_start_dt_day) + l_ppd_day;
         END IF;
         l_pym_tbl(1).stub_amount := 0;
         l_pym_tbl(1).stub_days   := l_no_days;
         l_pym_tbl(1).update_type := 'CREATE';
       END IF;

       l_pym_tbl(3).stub_amount := l_ppd_amount;
       l_pym_tbl(3).stub_days   := 1;
       l_pym_tbl(3).update_type := 'CREATE';


     ELSIF NVL(l_count,0) > 0 THEN
         FOR l_payment_rec IN c_unscheduled_payment_str(l_contract_id,l_upp_sty_id) LOOP
           l_pym_tbl(i).sort_date := l_payment_rec.start_date;
           IF l_payment_rec.period_in_months IS NOT NULL THEN
             l_pym_tbl(i).period := l_payment_rec.period_in_months;
             l_pym_tbl(i).amount := l_payment_rec.amount;
           ELSIF l_payment_rec.stub_days IS NOT NULL THEN
             l_pym_tbl(i).stub_days := l_payment_rec.stub_days;
 	     l_pym_tbl(i).stub_amount := l_payment_rec.stub_amount;
	   END IF;
   	   l_pym_tbl(i).rule_id := l_payment_rec.rule_id;
       	   l_pym_tbl(i).update_type := 'DELETE';
	   i := i + 1;
         END LOOP;

        okl_la_payments_pvt.process_payment(p_api_version                  => p_api_version,
                                          p_init_msg_list                  => p_init_msg_list,
                                          x_return_status                  => x_return_status,
                                          x_msg_count                      => x_msg_count,
                                          x_msg_data                       => x_msg_data,
                                          p_chr_id                         => l_contract_id,
                                          p_service_fee_id                 => NULL,
                                          p_asset_id                       => NULL,
                                          p_payment_id                     => l_upp_sty_id,
                                          p_pym_hdr_rec                    => l_pym_hdr_rec,
                                          p_pym_tbl                        => l_pym_tbl,
                                          p_update_type                    => 'DELETE',
                                          x_rulv_tbl                       => l_rulv_tbl_type    );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'status after deleting original payments: '||x_return_status);
         END IF;

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

        i := 0;
        IF l_pym_tbl.COUNT > 0 THEN
           i := l_pym_tbl.FIRST;
           LOOP
             l_pym_tbl(i).sort_date := NULL;
             l_pym_tbl(i).rule_id := NULL;
             l_pym_tbl(i).update_type := 'CREATE';
             EXIT WHEN i = l_pym_tbl.LAST;
             i := l_pym_tbl.NEXT(i);
           END LOOP;
        END IF;

        i := i + 1;
        l_new_start_date := l_max_date + 1;
        l_no_months := FLOOR(MONTHS_BETWEEN(l_ppd_date,l_new_start_date));

        l_ppd_day      := to_number(substr(to_char(l_ppd_date,'DD-MON-YY'),1,2));
        l_start_dt_day := to_number(substr(to_char(l_new_start_date,'DD-MON-YY'),1,2));

        IF l_ppd_day > l_start_dt_day THEN
           l_no_days := l_ppd_day - l_start_Dt_day;
        ELSIF l_start_dt_day > l_ppd_day THEN
           l_previous_month := l_ppd_date - 30;
           l_no_months := FLOOR(MONTHS_BETWEEN(l_previous_month,l_new_start_date));
           l_last_day  := substr(to_char(last_day(trunc(l_previous_month)),'DD-MON-YYYY'),1,2);
           l_no_days  := (l_last_day - l_start_dt_day) + l_ppd_day;
        ELSIF l_ppd_day = l_start_dt_day THEN
           l_no_days := 0;
        END IF;

        IF l_no_months > 0 THEN
           l_next_start_dt := ADD_MONTHS(l_new_start_date,l_no_months);
           l_pym_tbl(i).amount := 0;
           l_pym_tbl(i).period   := l_no_months;
           l_pym_tbl(i).update_type := 'CREATE';

           IF l_no_days <> 0 THEN
             i := i + 1;
             l_pym_tbl(i).stub_amount := 0;
             l_pym_tbl(i).stub_days   := l_no_days;
             l_pym_tbl(i).update_type := 'CREATE';
           END IF;
         ELSIF l_no_months = 0 THEN
           IF l_ppd_day > l_start_dt_day THEN
             l_no_days := l_ppd_day - l_start_Dt_day;
           ELSIF l_start_dt_day > l_ppd_day THEN
             l_last_day  := substr(to_char(last_day(trunc(l_new_start_Date)),'DD-MON-YYYY'),1,2);
             l_no_days  := (l_last_day - l_start_dt_day) + l_ppd_day;
           END IF;
           l_pym_tbl(i).stub_amount := 0;
           l_pym_tbl(i).stub_days   := l_no_days;
           l_pym_tbl(i).update_type := 'CREATE';
         END IF;
         i := i + 1;
           l_pym_tbl(i).stub_amount := l_ppd_amount;
           l_pym_tbl(i).stub_days   := 1;
           l_pym_tbl(i).update_type := 'CREATE';

     END IF;

     j := 0;
    IF l_pym_tbl.COUNT > 0 THEN
      j := l_pym_tbl.FIRST;
      LOOP
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'period '   || l_pym_tbl(j).period);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'amount'  ||l_pym_tbl(j).amount);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub days '|| l_pym_tbl(j).stub_days);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub amount '||l_pym_tbl(j).stub_amount);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update_type '||l_pym_tbl(j).update_type);
        END IF;
        EXIT WHEN j = l_pym_tbl.LAST;
        j := l_pym_tbl.NEXT(j);
      END LOOP;
    END IF;

     --Update the Payment on the contract with the Unscheduled  Payment.
        okl_la_payments_pvt.process_payment(p_api_version                  => p_api_version,
                                            p_init_msg_list                => p_init_msg_list,
                                            x_return_status                => x_return_status,
                                            x_msg_count                    => x_msg_count,
                                            x_msg_data                     => x_msg_data,
                                            p_chr_id                       => l_contract_id,
                                            p_service_fee_id               => NULL,
                                            p_asset_id                     => NULL,
                                            p_payment_id                   => l_upp_sty_id,
                                            p_pym_hdr_rec                  => l_pym_hdr_rec,
                                            p_pym_tbl                      => l_pym_tbl,
                                            p_update_type                  => 'CREATE',
                                            x_rulv_tbl                     => l_rulv_tbl_type    );

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'status after updating payments: '||x_return_status);
        END IF;
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


-- Creating stream for Unscheduled  Payment

               OPEN  c_tran_num_csr;
               FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
               CLOSE c_tran_num_csr;


               l_stmv_rec.sty_id               := l_upp_sty_id;
               l_stmv_rec.khr_id                := l_trqv_rec.dnz_khr_id;
               l_stmv_rec.kle_id                := NULL;
               l_stmv_rec.sgn_code              := 'MANL';
               l_stmv_rec.say_code              := 'CURR';
               l_stmv_rec.active_yn             := 'Y';
               l_stmv_rec.date_current          := SYSDATE;
               l_stmv_rec.comments              := l_comments;


               Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from creating streams'|| x_return_status);
 END IF;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

       l_selv_rec.stm_id := lx_stmv_rec.id;

--Creating stream elements
         l_selv_rec.accrued_yn   := 'N';
          l_selv_rec.comments     := l_comments;
          l_selv_rec.stream_element_date := l_trqv_rec.payment_date;
         --bug 4889833 commenting date billed
         --l_selv_rec.date_billed := SYSDATE;
          l_selv_rec.amount := l_trqv_rec.payment_amount;

          -- to populate mandatory field in table Okl_Strm_Elements.
          l_selv_rec.se_line_number := NULL;
          OPEN  c_stm_id_line_number(l_selv_rec.stm_id);
          FETCH c_stm_id_line_number INTO l_selv_rec.se_line_number;
          if(c_stm_id_line_number%rowcount = 0) THEN
            l_selv_rec.se_line_number := 1;
          else
            l_selv_rec.se_line_number := l_selv_rec.se_line_number+1;
          end if;
          CLOSE c_stm_id_line_number;

         Okl_Streams_Pub.create_stream_elements(
                p_api_version    =>     p_api_version,
                p_init_msg_list  =>     p_init_msg_list,
                x_return_status  =>     x_return_status,
                x_msg_count      =>     x_msg_count,
                x_msg_data       =>     x_msg_data,
                p_selv_rec       =>     l_selv_rec,
                x_selv_rec       =>     lx_selv_rec);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Return status from creating stream elements'|| x_return_status);
 END IF;


              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;




/*	l_trqv_rec.request_status_code := 'SUBMITTED';


	okl_trx_requests_pub.update_trx_requests( p_api_version => p_api_version,
                                                p_init_msg_list => p_init_msg_list,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_trqv_rec      => l_trqv_rec,
                                                x_trqv_rec      => lx_trqv_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF; */

      --Call the WF which does the following
        	-- 1. Create online AR Invoice.
        	-- 2. Mark the "Unscheduled Principal Payment" stream as Billed.
        	-- 3. Apply the selected receipt on the generated invoices.
        	-- 4. Update the status of the request to Processed. --Call BPD API to create AR journal entries

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling WF');
     END IF;

	 OKL_CS_WF.raise_principal_paydown_event(l_trqv_rec.id);

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling WF');
 END IF;


    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd','End(+)');
    END IF;

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
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
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_CS_PRINCIPAL_PAYDOWN_PVT.process_ppd ',
                  'EXCEPTION :'||sqlerrm);
       END IF;

       x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END process_lpd;



END OKL_CS_PRINCIPAL_PAYDOWN_PVT;

/

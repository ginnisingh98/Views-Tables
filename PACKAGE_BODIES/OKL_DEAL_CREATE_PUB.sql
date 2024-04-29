--------------------------------------------------------
--  DDL for Package Body OKL_DEAL_CREATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DEAL_CREATE_PUB" AS
/* $Header: OKLPDCRB.pls 120.49.12010000.3 2008/09/08 23:32:47 rkuttiya ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
   G_API_TYPE	VARCHAR2(3) := 'PUB';

   G_RLE_CODE  VARCHAR2(10) := 'LESSEE';
   G_STS_CODE  VARCHAR2(10) := 'NEW';
   G_LEASE_VENDOR  VARCHAR2(10) := 'OKL_VENDOR';
   G_VENDOR_BILL_RGD_CODE  VARCHAR2(10) := 'LAVENB';
   G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_CODE';

   SUBTYPE rgpv_rec_type IS OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
   SUBTYPE rulv_rec_type IS Okl_Rule_Pub.rulv_rec_type;
   SUBTYPE rulv_tbl_type IS Okl_Rule_Pub.rulv_tbl_type;
   SUBTYPE chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;
   SUBTYPE khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;

   /*
   -- mvasudev, 08/17/2004
   -- Added Constants to enable Business Event
   */
   G_WF_EVT_KHR_CREATED CONSTANT VARCHAR2(41) := 'oracle.apps.okl.la.lease_contract.created';
   G_WF_EVT_KHR_UPDATED CONSTANT VARCHAR2(41) := 'oracle.apps.okl.la.lease_contract.updated';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(11) := 'CONTRACT_ID';



  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	--start modified abhsaxen for performance SQLID 20562566
	    select a.attribute_label_long
	 from ak_region_items ri, ak_regions r, ak_attributes_vl a
	 where ri.region_code = r.region_code
	 and ri.region_application_id = r.region_application_id
	 and ri.attribute_code = a.attribute_code
	 and ri.attribute_application_id = a.attribute_application_id
	 and ri.region_code  =  p_ak_region
	 and ri.attribute_code = p_ak_attribute
	--end modified abhsaxen for performance SQLID 20562566
	;

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	RETURN(l_ak_prompt);
  END;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_chrv_rec                     IN chrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN chrv_rec_type IS
    CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
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
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            PROGRAM_APPLICATION_ID,
            PRICE_LIST_ID,
            PRICING_DATE,
            SIGN_BY_DATE,
            TOTAL_LINE_LIST_PRICE,
            USER_ESTIMATED_AMOUNT,
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
      FROM Okc_K_Headers_V
     WHERE okc_k_headers_v.id   = p_id;
    l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
    l_chrv_rec                     chrv_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_chrv_pk_csr (p_chrv_rec.id);
    FETCH okc_chrv_pk_csr INTO
              l_chrv_rec.ID,
              l_chrv_rec.OBJECT_VERSION_NUMBER,
              l_chrv_rec.SFWT_FLAG,
              l_chrv_rec.CHR_ID_RESPONSE,
              l_chrv_rec.CHR_ID_AWARD,
              l_chrv_rec.INV_ORGANIZATION_ID,
              l_chrv_rec.STS_CODE,
              l_chrv_rec.QCL_ID,
              l_chrv_rec.SCS_CODE,
              l_chrv_rec.CONTRACT_NUMBER,
              l_chrv_rec.CURRENCY_CODE,
              l_chrv_rec.CONTRACT_NUMBER_MODIFIER,
              l_chrv_rec.ARCHIVED_YN,
              l_chrv_rec.DELETED_YN,
              l_chrv_rec.CUST_PO_NUMBER_REQ_YN,
              l_chrv_rec.PRE_PAY_REQ_YN,
              l_chrv_rec.CUST_PO_NUMBER,
              l_chrv_rec.SHORT_DESCRIPTION,
              l_chrv_rec.COMMENTS,
              l_chrv_rec.DESCRIPTION,
              l_chrv_rec.DPAS_RATING,
              l_chrv_rec.COGNOMEN,
              l_chrv_rec.TEMPLATE_YN,
              l_chrv_rec.TEMPLATE_USED,
              l_chrv_rec.DATE_APPROVED,
              l_chrv_rec.DATETIME_CANCELLED,
              l_chrv_rec.AUTO_RENEW_DAYS,
              l_chrv_rec.DATE_ISSUED,
              l_chrv_rec.DATETIME_RESPONDED,
              l_chrv_rec.NON_RESPONSE_REASON,
              l_chrv_rec.NON_RESPONSE_EXPLAIN,
              l_chrv_rec.RFP_TYPE,
              l_chrv_rec.CHR_TYPE,
              l_chrv_rec.KEEP_ON_MAIL_LIST,
              l_chrv_rec.SET_ASIDE_REASON,
              l_chrv_rec.SET_ASIDE_PERCENT,
              l_chrv_rec.RESPONSE_COPIES_REQ,
              l_chrv_rec.DATE_CLOSE_PROJECTED,
              l_chrv_rec.DATETIME_PROPOSED,
              l_chrv_rec.DATE_SIGNED,
              l_chrv_rec.DATE_TERMINATED,
              l_chrv_rec.DATE_RENEWED,
              l_chrv_rec.TRN_CODE,
              l_chrv_rec.START_DATE,
              l_chrv_rec.END_DATE,
              l_chrv_rec.AUTHORING_ORG_ID,
              l_chrv_rec.BUY_OR_SELL,
              l_chrv_rec.ISSUE_OR_RECEIVE,
	      l_chrv_rec.ESTIMATED_AMOUNT,
              l_chrv_rec.ESTIMATED_AMOUNT_RENEWED,
              l_chrv_rec.CURRENCY_CODE_RENEWED,
	      l_chrv_rec.UPG_ORIG_SYSTEM_REF,
	      l_chrv_rec.UPG_ORIG_SYSTEM_REF_ID,
	      l_chrv_rec.APPLICATION_ID,
              l_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
              l_chrv_rec.ORIG_SYSTEM_ID1,
              l_chrv_rec.ORIG_SYSTEM_REFERENCE1,
              l_chrv_rec.program_id,
              l_chrv_rec.request_id,
              l_chrv_rec.program_update_date,
              l_chrv_rec.program_application_id,
              l_chrv_rec.price_list_id,
              l_chrv_rec.pricing_date,
              l_chrv_rec.sign_by_date,
              l_chrv_rec.total_line_list_price,
              l_chrv_rec.USER_ESTIMATED_AMOUNT,
              l_chrv_rec.ATTRIBUTE_CATEGORY,
              l_chrv_rec.ATTRIBUTE1,
              l_chrv_rec.ATTRIBUTE2,
              l_chrv_rec.ATTRIBUTE3,
              l_chrv_rec.ATTRIBUTE4,
              l_chrv_rec.ATTRIBUTE5,
              l_chrv_rec.ATTRIBUTE6,
              l_chrv_rec.ATTRIBUTE7,
              l_chrv_rec.ATTRIBUTE8,
              l_chrv_rec.ATTRIBUTE9,
              l_chrv_rec.ATTRIBUTE10,
              l_chrv_rec.ATTRIBUTE11,
              l_chrv_rec.ATTRIBUTE12,
              l_chrv_rec.ATTRIBUTE13,
              l_chrv_rec.ATTRIBUTE14,
              l_chrv_rec.ATTRIBUTE15,
              l_chrv_rec.CREATED_BY,
              l_chrv_rec.CREATION_DATE,
              l_chrv_rec.LAST_UPDATED_BY,
              l_chrv_rec.LAST_UPDATE_DATE,
              l_chrv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_chrv_pk_csr%NOTFOUND;
    CLOSE okc_chrv_pk_csr;
    RETURN(l_chrv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_chrv_rec                     IN chrv_rec_type
  ) RETURN chrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_chrv_rec, l_row_notfound));

  END get_rec;
 ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_khrv_rec                     IN khrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN khrv_rec_type IS
    CURSOR okl_k_headers_v_pk_csr (p_id                 IN NUMBER) IS
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
        REVOLVING_CREDIT_YN,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_TYPE,
        ASSIGNABLE_YN
      FROM OKL_K_HEADERS_V
      WHERE OKL_K_HEADERS_V.id     = p_id;
      l_okl_k_headers_v_pk             okl_k_headers_v_pk_csr%ROWTYPE;
      l_khrv_rec                      khrv_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_headers_v_pk_csr (p_khrv_rec.id);
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
        l_khrv_rec.REVOLVING_CREDIT_YN,
        l_khrv_rec.CURRENCY_CONVERSION_RATE,
        l_khrv_rec.CURRENCY_CONVERSION_DATE,
	l_khrv_rec.CURRENCY_CONVERSION_TYPE,
	l_khrv_rec.ASSIGNABLE_YN
        ;
    x_no_data_found := okl_k_headers_v_pk_csr%NOTFOUND;
    CLOSE okl_k_headers_v_pk_csr;
    RETURN(l_khrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_khrv_rec                     IN khrv_rec_type
  ) RETURN khrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_khrv_rec, l_row_notfound));
  END get_rec;

-- Start of comments
--
-- Procedure Name  : create_from_template
-- Description     : creates a deal from a template
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY  NUMBER) AS

    l_end_date           OKL_K_HEADERS_FULL_V.END_DATE%TYPE DEFAULT NULL;
    l_start_date         OKL_K_HEADERS_FULL_V.START_DATE%TYPE DEFAULT NULL;
    l_term_duration      OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE DEFAULT NULL;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    CURSOR get_k_start_date_and_term_csr(l_chr_id NUMBER) IS
    -- START: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938
	--SELECT ADD_MONTHS(start_date,term_duration)-1
	SELECT chr.start_date, khr.term_duration
	FROM okl_k_headers khr,
         okc_k_headers_b chr
    WHERE khr.id = chr.id
	AND chr.id = l_chr_id;
    -- START: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938
	--WHERE id = l_chr_id;

    --Bug 4654486
    l_scs_code                     VARCHAR2(30);

    Cursor l_scs_csr  is
    Select scs_code
    From   okc_k_headers_b
    where  id = p_source_chr_id;
    --Bug 4654486 : end

  BEGIN

  --Bug 4654486
   --Call the old api in case of MASTER_LEASE agreement
    OPEN l_scs_csr;
    FETCH l_scs_csr into l_scs_code;
    CLOSE l_scs_csr;

    IF (l_scs_code  IS NOT NULL) AND (l_scs_code  = 'MASTER_LEASE')  Then
       OKL_COPY_CONTRACT_PUB.copy_lease_contract(
          p_api_version              => p_api_version,
          p_init_msg_list            => p_init_msg_list,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data,
          p_chr_id                   => p_source_chr_id,
          p_contract_number          => p_contract_number,
          p_contract_number_modifier => null,
          p_renew_ref_yn             => OKC_API.G_FALSE,
          p_trans_type               => 'CFA',
          x_chr_id                   => x_chr_id);
    ELSE
      OKL_COPY_CONTRACT_PUB.copy_lease_contract_new(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_chr_id                   => p_source_chr_id,
      p_contract_number          => p_contract_number,
      p_contract_number_modifier => NULL,
      p_renew_ref_yn             => OKC_API.G_FALSE,
      p_trans_type               => 'CFA',
      x_chr_id                   => x_chr_id);
    END IF;

	  -- START: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938
	  /*
      OPEN get_k_start_date_and_term_csr(x_chr_id);
      FETCH get_k_start_date_and_term_csr INTO l_end_date;
      CLOSE get_k_start_date_and_term_csr;
	  */
	  FOR get_k_start_date_and_term_rec IN get_k_start_date_and_term_csr(x_chr_id)
	  LOOP
	    l_end_date := OKL_LLA_UTIL_PVT.calculate_end_date(get_k_start_date_and_term_rec.start_date,get_k_start_date_and_term_rec.term_duration);
	  END LOOP;
	  -- END: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938

      lp_chrv_rec.id := x_chr_id;
      lp_khrv_rec.id := x_chr_id;
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_CONTRACT;
      lp_chrv_rec.end_date := l_end_date;


      IF l_end_date IS NOT NULL THEN
      	      OKL_CONTRACT_PUB.update_contract_header(
	         p_api_version    => p_api_version,
	         p_init_msg_list  => p_init_msg_list,
	         x_return_status  => x_return_status,
	         x_msg_count      => x_msg_count,
	         x_msg_data       => x_msg_data,
	         p_chrv_rec       => lp_chrv_rec,
	         p_khrv_rec       => lp_khrv_rec,
	         x_chrv_rec       => lx_chrv_rec,
	         x_khrv_rec       => lx_khrv_rec);
      END IF;

  END;


-- Start of comments
--
-- Procedure Name  : create_from_contract
-- Description     : creates a deal from a template
-- Business Rules  : I might need to provide yes to p_renew_ref_yn. Then I need to provide Class Operation ID
--                   somewhere inside that package
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS

    --Bug 4654486
    l_scs_code                     VARCHAR2(30);

    Cursor l_scs_csr  is
    Select scs_code
    From   okc_k_headers_b
    where  id = p_source_chr_id;
    --Bug 4654486 : end

  BEGIN

  --Bug 4654486
   --Call the old api in case of MASTER_LEASE agreement
    OPEN l_scs_csr;
    FETCH l_scs_csr into l_scs_code;
    CLOSE l_scs_csr;

    IF (l_scs_code  IS NOT NULL) AND (l_scs_code  = 'MASTER_LEASE')  Then
       OKL_COPY_CONTRACT_PUB.copy_lease_contract(
          p_api_version              => p_api_version,
          p_init_msg_list            => p_init_msg_list,
          x_return_status            => x_return_status,
          x_msg_count                => x_msg_count,
          x_msg_data                 => x_msg_data,
          p_chr_id                   => p_source_chr_id,
          p_contract_number          => p_contract_number,
          p_contract_number_modifier => null,
          p_renew_ref_yn             => OKC_API.G_FALSE,
          p_trans_type               => 'CFA',
          x_chr_id                   => x_chr_id);
    ELSE
      OKL_COPY_CONTRACT_PUB.copy_lease_contract_new(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_chr_id                   => p_source_chr_id,
      p_contract_number          => p_contract_number,
      p_contract_number_modifier => NULL,
      p_renew_ref_yn             => OKC_API.G_FALSE,
      p_trans_type               => 'CFA',
      x_chr_id                   => x_chr_id);
    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  END;


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
                         p_new_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE,
                         p_old_rgp_id    IN  NUMBER,
                         p_new_rgp_id    IN  NUMBER
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

  l_old_rgpv_rec      rgpv_rec_type;
  l_slh_rulv_rec      rulv_rec_type;
  l_sll_rulv_rec      rulv_rec_type;

  l_rebook_rgp_id NUMBER;
  l_orig_rgp_id   NUMBER;

  l_rulv_tbl      rulv_tbl_type;
  i               NUMBER := 0;

  CURSOR orig_cle_csr(p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT orig_system_id1
  FROM   okc_k_lines_v
  WHERE  id = p_cle_id;

  CURSOR del_rgp_csr(p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                     p_rgp_id NUMBER) IS
  SELECT id
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    id         = p_rgp_id
  AND    rgd_code   = 'LALEVL';

  CURSOR rule_csr(p_rgp_id NUMBER) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  rgp_id = p_rgp_id
  AND    rule_information_category IN ('LASLH','LASLL');

  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      -- Delete SLH, SLL from Original Contract
      i := 1;

      FOR del_rgp_rec IN del_rgp_csr(p_new_chr_id,
                                     p_new_rgp_id)
      LOOP
         FOR rule_rec IN rule_csr(del_rgp_rec.id)
         LOOP
            l_rulv_tbl(i).id := rule_rec.id;
            i := i+ 1;
         END LOOP;
      END LOOP;

      Okl_Rule_Pub.delete_rule(
                               p_api_version    => 1.0,
                               p_init_msg_list  => Okc_Api.G_FALSE,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_rulv_tbl       => l_rulv_tbl
                              );
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        RAISE sync_failed;
      END IF;

      l_old_rgpv_rec.id := p_old_rgp_id;
      --
      -- Get SLH Rule from OLD Contract
      --
      Okl_Rule_Apis_Pvt.Get_Contract_Rules(
                                           p_api_version    => 1.0,
                                           p_init_msg_list  => Okl_Api.G_FALSE,
                                           p_rgpv_rec       => l_old_rgpv_rec,
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

      --
      -- create SLH Rule from OLD Contract
      --
      FOR i IN 1..x_slh_rule_count
      LOOP
         l_slh_rulv_rec            := x_slh_rulv_tbl(i);
         l_slh_rulv_rec.rgp_id     := p_new_rgp_id;
         l_slh_rulv_rec.dnz_chr_id := p_new_chr_id;

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
                       p_rgpv_rec       => l_old_rgpv_rec,
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
            l_sll_rulv_rec.rgp_id      := p_new_rgp_id;
            l_sll_rulv_rec.object2_id1 := x_new_slh_rulv_rec.id;
            l_sll_rulv_rec.dnz_chr_id  := p_new_chr_id;

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

  EXCEPTION
    WHEN sync_failed THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;
  END sync_slh_sll;

-- Start Bug 2376998
------------------------------------------------------------------------------
-- PROCEDURE link_slh_sll
--
--  This procedure links SLH and SLL by calling sync_slh_sll at LINE level
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE link_slh_sll(
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_old_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE,
                         p_new_cle_id    IN  OKC_K_LINES_V.ID%TYPE,
                         p_new_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE
                        ) IS

 link_failed EXCEPTION;

 CURSOR lalevl_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                    p_cle_id OKC_K_LINES_V.ID%TYPE) IS
 SELECT id,
        cle_id
 FROM   okc_rule_groups_v
 WHERE  dnz_chr_id = p_chr_id
 AND    cle_id     = p_cle_id
 AND    rgd_code   = 'LALEVL';

 CURSOR old_lalevl_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                        p_cle_id OKC_K_LINES_V.ID%TYPE) IS
 SELECT id
 FROM   okc_rule_groups_v
 WHERE  dnz_chr_id = p_chr_id
 AND    rgd_code   = 'LALEVL'
 AND    (cle_id    = p_cle_id
         OR ( cle_id IS NULL
              AND
              p_cle_id IS NULL));

 CURSOR old_line_csr (p_cle_id OKC_K_LINES_V.ID%TYPE) IS
 SELECT orig_system_id1
 FROM   OKC_K_LINES_V
 WHERE  id = p_cle_id;

 l_old_lalevl_id NUMBER;
 l_new_lalevl_id NUMBER;
 l_old_cle_id    OKC_K_LINES_V.ID%TYPE;
 l_new_cle_id    OKC_K_LINES_V.ID%TYPE;

 BEGIN

   -- get into the loop if lalevl entries found for the new contract
   FOR new_lalevl_rec IN lalevl_csr(p_new_chr_id,
                                    p_new_cle_id)
   LOOP
      l_new_lalevl_id := new_lalevl_rec.id;
      l_new_cle_id    := new_lalevl_rec.cle_id; -- new lalevl cle id in the rule group

      l_old_cle_id    := NULL;
      IF (l_new_cle_id IS NOT NULL) THEN
         OPEN old_line_csr (l_new_cle_id);  --get the old cle id
         FETCH old_line_csr INTO l_old_cle_id;
         CLOSE old_line_csr;
      END IF;

      OPEN old_lalevl_csr(p_old_chr_id,
                          l_old_cle_id);
      FETCH old_lalevl_csr INTO l_old_lalevl_id; -- get the old lalevl rue group id
      CLOSE old_lalevl_csr;

      sync_slh_sll(
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_new_chr_id    => p_new_chr_id,
                   p_old_rgp_id    => l_old_lalevl_id,
                   p_new_rgp_id    => l_new_lalevl_id
                  );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
   END LOOP;

 EXCEPTION
   WHEN link_failed THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
 END link_slh_sll;

  PROCEDURE link_slh_sll(
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_old_chr_id    IN OKC_K_HEADERS_V.ID%TYPE,
                         p_new_chr_id    IN OKC_K_HEADERS_V.ID%TYPE
                        ) IS

 link_failed EXCEPTION;

 CURSOR lalevl_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
 SELECT id,
        cle_id
 FROM   okc_rule_groups_v
 WHERE  dnz_chr_id = p_chr_id
 AND    cle_id     IS NULL       -- Bug 2376998
 AND    rgd_code   = 'LALEVL';

 CURSOR old_lalevl_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                        p_cle_id OKC_K_LINES_V.ID%TYPE) IS
 SELECT id
 FROM   okc_rule_groups_v
 WHERE  dnz_chr_id = p_chr_id
 AND    rgd_code   = 'LALEVL'
 AND    (cle_id    = p_cle_id
         OR ( cle_id IS NULL
              AND
              p_cle_id IS NULL));

 CURSOR old_line_csr (p_cle_id OKC_K_LINES_V.ID%TYPE) IS
 SELECT orig_system_id1
 FROM   OKC_K_LINES_V
 WHERE  id = p_cle_id;

 l_old_lalevl_id NUMBER;
 l_new_lalevl_id NUMBER;
 l_old_cle_id    OKC_K_LINES_V.ID%TYPE;
 l_new_cle_id    OKC_K_LINES_V.ID%TYPE;

 BEGIN

   FOR new_lalevl_rec IN lalevl_csr(p_new_chr_id)
   LOOP
      l_new_lalevl_id := new_lalevl_rec.id;
      l_new_cle_id    := new_lalevl_rec.cle_id;

      l_old_cle_id    := NULL;
      IF (l_new_cle_id IS NOT NULL) THEN
         OPEN old_line_csr (l_new_cle_id);
         FETCH old_line_csr INTO l_old_cle_id;
         CLOSE old_line_csr;
      END IF;

      OPEN old_lalevl_csr(p_old_chr_id,
                          l_old_cle_id);
      FETCH old_lalevl_csr INTO l_old_lalevl_id;
      CLOSE old_lalevl_csr;

      sync_slh_sll(
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_new_chr_id    => p_new_chr_id,
                   p_old_rgp_id    => l_old_lalevl_id,
                   p_new_rgp_id    => l_new_lalevl_id
                  );
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END LOOP;

 EXCEPTION
   WHEN link_failed THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
 END link_slh_sll;


  PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lx_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

    CURSOR get_curr_csr(p_id IN NUMBER) IS
    SELECT id,currency_code,currency_conversion_type,currency_conversion_date,currency_conversion_rate, cust_acct_id, khr_id
    FROM   okl_k_headers_full_v
    WHERE  scs_code = 'QUOTE'
    AND    id = p_id;

    CURSOR c_rgpv IS
    SELECT rgp.id
    FROM okc_rule_groups_b rgp, okc_subclass_rg_defs rg_defs
    WHERE rgp.dnz_chr_id = p_source_chr_id
    AND rgp.rgd_code = rg_defs.rgd_code
    AND rg_defs.scs_code = 'LEASE'
    AND  rgp.cle_id IS NULL
    AND  rgp.rgd_code NOT IN ('LATOWN','CURRENCY');

    CURSOR c_governances IS
    SELECT gvr.chr_id_referred
    FROM okc_governances gvr,
         okc_k_headers_b CHR,
         okc_k_headers_b mla
	WHERE gvr.dnz_chr_id = p_source_chr_id
    AND gvr.chr_id = p_source_chr_id
    AND gvr.cle_id IS NULL
    AND CHR.id = gvr.dnz_chr_id
    AND mla.id = gvr.chr_id_referred
    AND mla.scs_code = 'MASTER_LEASE';

    CURSOR c_catv IS
    SELECT id
    FROM okc_k_articles_b
    WHERE dnz_chr_id = p_source_chr_id
    AND cle_id IS NULL;

    CURSOR c_cplv IS
    SELECT cpl.id
    FROM okc_k_party_roles_b cpl, okc_subclass_roles ROLES
    WHERE dnz_chr_id = p_source_chr_id
    AND cpl.rle_code = ROLES.rle_code
    AND ROLES.scs_code = 'LEASE'
    AND cpl.cle_id IS NULL;


        CURSOR c_lines IS
        SELECT cle.id
        FROM   okc_k_lines_b cle,
               okc_line_styles_b lse,
               okc_subclass_top_line stl
        WHERE  chr_id = p_source_chr_id
        AND    cle.lse_id= lse.id
        AND    stl.scs_code = 'LEASE'
        AND    lse.id = stl.lse_id
        AND    lse.lse_type = 'TLS'
        AND    lse.lse_parent_id IS NULL;

        CURSOR new_c_lines(p_dest_chr_id NUMBER) IS
        SELECT cle.id
        FROM   okc_k_lines_b cle,
               okc_line_styles_b lse,
               okc_subclass_top_line stl
        WHERE  chr_id = p_dest_chr_id
        AND    cle.lse_id= lse.id
        AND    stl.scs_code = 'LEASE'
        AND    lse.id = stl.lse_id
        AND    lse.lse_type = 'TLS'
        AND    lse.lse_parent_id IS NULL;

    l_cust_acct_id   okc_k_headers_b.cust_acct_id%type;
    l_khr_id         okl_k_headers.khr_id%type;

    l_chr_id			NUMBER;
    l_rgp_id			NUMBER;
    l_cpl_id			NUMBER;
    l_cle_id			NUMBER;
    l_cle_id_out		NUMBER;
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'CREATE_NEW_DEAL';

    i				NUMBER;
    j				NUMBER := 0;
    l_mla_gvr_chr_id_referred NUMBER := NULL;

    l_line_tab okl_copy_asset_pub.klev_tbl_type;
    x_cle_id_tbl okl_copy_asset_pub.klev_tbl_type;

    l_currency_code okc_k_headers_b.currency_code%TYPE := NULL;
    l_currency_conversion_type okl_k_headers.currency_conversion_type%TYPE := NULL;
    l_currency_conversion_date okl_k_headers.currency_conversion_date%TYPE := NULL;
    l_currency_conversion_rate okl_k_headers.currency_conversion_rate%TYPE := NULL;

    lp_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;
    lx_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;

  BEGIN

  --  read hdr info from the quote contract and create a lease contract
  --  use get_rec to read the info

      x_return_status := OKC_API.START_ACTIVITY(
  			p_api_name      => l_api_name,
  			p_pkg_name      => g_pkg_name,
  			p_init_msg_list => p_init_msg_list,
  			l_api_version   => l_api_version,
  			p_api_version   => p_api_version,
  			p_api_type      => g_api_type,
  			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      lp_chrv_rec.id := NULL;
      l_cust_acct_id := NULL;
      l_khr_id := NULL;
      OPEN get_curr_csr(p_source_chr_id);
      FETCH get_curr_csr INTO lp_chrv_rec.id,l_currency_code,l_currency_conversion_type,l_currency_conversion_date,l_currency_conversion_rate, l_cust_acct_id,l_khr_id;
      CLOSE get_curr_csr;

      IF lp_chrv_rec.id IS NULL THEN
	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'quote_chr_id_not_found');
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;


      lp_khrv_rec.id := lp_chrv_rec.id;
      lp_chrv_rec.id := lp_chrv_rec.id;

      lp_chrv_rec := get_rec(lp_chrv_rec);
      lp_khrv_rec := get_rec(lp_khrv_rec);

      lp_chrv_rec.id := NULL;
      lp_chrv_rec.scs_code := 'LEASE';
      lp_khrv_rec.id := NULL;

      lp_chrv_rec.sfwt_flag := 'N';
      lp_chrv_rec.object_version_number := 1.0;
      lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
      lp_chrv_rec.scs_code := 'LEASE';
      lp_chrv_rec.contract_number := p_contract_number;
      lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
      lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
--      lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);

      lp_chrv_rec.cust_acct_id := l_cust_acct_id;
      lp_chrv_rec.currency_code := l_currency_code;

      lp_khrv_rec.currency_conversion_type := l_currency_conversion_type;
      lp_khrv_rec.currency_conversion_date := l_currency_conversion_date;
      lp_khrv_rec.currency_conversion_rate := l_currency_conversion_rate;
      lp_khrv_rec.khr_id := l_khr_id;

      lp_chrv_rec.currency_code_renewed := NULL;
      lp_chrv_rec.template_yn := 'N';
      lp_chrv_rec.chr_type := 'CYA';
      lp_chrv_rec.archived_yn := 'N';
      lp_chrv_rec.deleted_yn := 'N';
      lp_chrv_rec.buy_or_sell := 'S';
      lp_chrv_rec.issue_or_receive := 'I';
      lp_chrv_rec.orig_system_source_code := 'OKL_QUOTE';
      lp_chrv_rec.orig_system_id1 := p_source_chr_id;

      lp_khrv_rec.object_version_number := 1.0;
      lp_khrv_rec.generate_accrual_yn := 'Y';
      lp_khrv_rec.generate_accrual_override_yn := 'N';
  /*
      OKL_CONTRACT_PUB.validate_contract_header(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_chrv_rec       => lp_chrv_rec,
        p_khrv_rec       => lp_khrv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
  */
      OKL_CONTRACT_PUB.create_contract_header(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_chrv_rec       => lp_chrv_rec,
        p_khrv_rec       => lp_khrv_rec,
        x_chrv_rec       => lx_chrv_rec,
        x_khrv_rec       => lx_khrv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_chr_id := lx_chrv_rec.id;
      l_chr_id := x_chr_id;

-- copy master lease
    OPEN c_governances;
    FETCH c_governances INTO l_mla_gvr_chr_id_referred;
    CLOSE c_governances;

  IF( l_mla_gvr_chr_id_referred IS NOT NULL) THEN

    lp_mla_gvev_rec.id := NULL;
    lp_mla_gvev_rec.dnz_chr_id := l_chr_id;
    lp_mla_gvev_rec.chr_id := l_chr_id;
    lp_mla_gvev_rec.chr_id_referred := l_mla_gvr_chr_id_referred;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.create_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec,
        x_gvev_rec       => lx_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

-- parties
      FOR l_c_cplv IN c_cplv LOOP
            -- l_old_return_status := x_return_status;

        OKL_COPY_CONTRACT_PUB.copy_party_roles(
 	        p_api_version    => p_api_version,
	        p_init_msg_list  => p_init_msg_list,
	        x_return_status  => x_return_status,
	        x_msg_count      => x_msg_count,
	        x_msg_data       => x_msg_data,
	        p_cpl_id         => l_c_cplv.id,
	        p_cle_id         => NULL,
	        p_chr_id         => l_chr_id,
	        P_rle_code       => NULL,
	        x_cpl_id	 => l_cpl_id);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP;


-- rules

    FOR l_c_rgpv IN c_rgpv LOOP

      -- l_old_return_status := l_return_status;

      OKL_COPY_CONTRACT_PUB.copy_rules (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> x_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_rgp_id	      	=> l_c_rgpv.id,
           p_cle_id		=> NULL,
           p_chr_id	        => l_chr_id, -- the new generated contract header id
	   p_to_template_yn     => 'N',
           x_rgp_id		=> l_rgp_id);

	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    END LOOP;

-- lines

   OPEN c_lines;
    LOOP
     FETCH c_lines INTO l_cle_id;
     EXIT WHEN c_lines%NOTFOUND;
     i := c_lines%RowCount;
     l_line_tab(i).id := l_cle_id;
     j := j + 1;
    END LOOP;
   CLOSE c_lines;

   IF( j > 0) THEN

      OKL_COPY_ASSET_PUB.copy_all_lines(
               p_api_version	     => p_api_version,
               p_init_msg_list	     => p_init_msg_list,
               x_return_status 	     => x_return_status,
               x_msg_count     	     => x_msg_count,
               x_msg_data      	     => x_msg_data,
               p_from_cle_id_tbl     => l_line_tab,
     	       p_to_cle_id 	     => NULL,
               p_to_chr_id 	     => l_chr_id,
       	       p_to_template_yn      => 'N',
               p_copy_reference      => 'COPY',
               p_copy_line_party_yn  => 'Y',
               p_renew_ref_yn        => 'N',
               p_trans_type          => 'CFA',
               x_cle_id_tbl	     => x_cle_id_tbl);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

   --
   -- Special Process for LALEVL (SLH, SLL) rules
   --
    l_cle_id := NULL;
    OPEN new_c_lines(l_chr_id);
     LOOP
      FETCH new_c_lines INTO l_cle_id;
      EXIT WHEN new_c_lines%NOTFOUND;

        link_slh_sll(
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_old_chr_id    => p_source_chr_id,
                     p_new_cle_id    => l_cle_id,
                     p_new_chr_id    => l_chr_id
                    );

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

     END LOOP;
   CLOSE new_c_lines;

   --
   -- Special Process for LALEVL (SLH, SLL) rules
   --

   link_slh_sll(
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_old_chr_id    => p_source_chr_id,
                p_new_chr_id    => l_chr_id
               );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,     x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : create_from_contract
-- Description     : creates a deal from a template
-- Business Rules  : I might need to provide yes to p_renew_ref_yn. Then I need to provide Class Operation ID
--                   somewhere inside that package
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_quote(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

  BEGIN
/*
   OKL_QUOTE_TO_CONTRACT_PVT.create_contract(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_contract_number          => p_contract_number,
      p_parent_object_code       => p_source_object_code,
      p_parent_object_id         => p_source_chr_id,
      x_chr_id                   => x_chr_id);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    x_chr_id := x_chr_id;

  END;

-- Start of comments
--
-- Procedure Name  : create_from_contract
-- Description     : creates a deal from a template
-- Business Rules  : I might need to provide yes to p_renew_ref_yn.
--                   Then I need to provide Class Operation ID
--                   somewhere inside that package
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_quote(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_object_code           IN VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    p_chr_id NUMBER;
    x_contract_number   VARCHAR2(120);

  BEGIN

   OKL_QUOTE_TO_CONTRACT_PVT.create_contract(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_contract_number          => p_contract_number,
      p_parent_object_code       => p_source_object_code,
      p_parent_object_id         => p_source_chr_id,
      x_chr_id                   => x_chr_id,
      x_contract_number          => x_contract_number
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_chr_id := x_chr_id;

  END;

-- Start of comments
--
-- Procedure Name  : create_new_deal
-- Description     : creates a deal with no source
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_new_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    --Bug# 4558486
    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lx_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

    lp_cplv_rec1 OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_cplv_rec1 OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'CREATE_NEW_DEAL';

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

    --Bug# 4558486
    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
    lp_chrv_rec.scs_code := p_scs_code;
    lp_chrv_rec.contract_number := p_contract_number;
    lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
    lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);
    lp_chrv_rec.currency_code_renewed := NULL;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';

    lp_khrv_rec.object_version_number := 1.0;
--    lp_khrv_rec.khr_id := 1;
    lp_khrv_rec.generate_accrual_yn := 'Y';
    lp_khrv_rec.generate_accrual_override_yn := 'N';
    --Added by dpsingh for LE Uptake
    lp_khrv_rec.legal_entity_id := p_legal_entity_id;
    OKL_CONTRACT_PUB.validate_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := x_chr_id;
    lp_cplv_rec.chr_id := x_chr_id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    IF(lp_cplv_rec.object1_id1 IS NOT NULL AND lp_cplv_rec.object1_id2 IS NOT NULL) THEN

    OKC_CONTRACT_PARTY_PUB.validate_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

     END IF;

----  Changes End

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);
    */

    lp_cplv_rec1.object_version_number := lp_cplv_rec.object_version_number;
    lp_cplv_rec1.sfwt_flag := lp_cplv_rec.sfwt_flag;
    lp_cplv_rec1.dnz_chr_id := lp_cplv_rec.dnz_chr_id;
    lp_cplv_rec1.chr_id := lp_cplv_rec.chr_id;
    lp_cplv_rec1.cle_id := lp_cplv_rec.cle_id;
    lp_cplv_rec1.object1_id1 := lp_cplv_rec.object1_id1;
    lp_cplv_rec1.object1_id2 := lp_cplv_rec.object1_id2;
    lp_cplv_rec1.jtot_object1_code :=lp_cplv_rec.jtot_object1_code;
    lp_cplv_rec1.rle_code := lp_cplv_rec.rle_code;

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec1,
      x_cplv_rec         => lx_cplv_rec1,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : create_new_deal
-- Description     : creates a deal with no source
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_new_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    --Bug# 4558486
    lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'CREATE_NEW_DEAL';

    row_count         NUMBER DEFAULT 0;

    CURSOR check_party_csr(p_chr_id NUMBER) IS
	--start modified abhsaxen for performance SQLID 20562707
	SELECT COUNT(1)
	    FROM okc_k_party_roles_B
	    WHERE dnz_chr_id = p_chr_id
	    AND chr_id = p_chr_id
	    AND rle_code = G_RLE_CODE
	    AND object1_id1 = p_customer_id1
	    AND object1_id2 = p_customer_id2
	--end modified abhsaxen for performance SQLID 20562707
	;
    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

    --Bug# 4558486
    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
    lp_chrv_rec.scs_code := p_scs_code;
    lp_chrv_rec.contract_number := p_contract_number;
    lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
    lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);
    lp_chrv_rec.currency_code_renewed := NULL;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';

    lp_khrv_rec.object_version_number := 1.0;
--    lp_khrv_rec.khr_id := 1;
    lp_khrv_rec.generate_accrual_yn := 'Y';
    lp_khrv_rec.generate_accrual_override_yn := 'N';
    --Added by dpsingh for LE Uptake
    lp_khrv_rec.legal_entity_id := p_legal_entity_id;
    OKL_CONTRACT_PUB.validate_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := x_chr_id;
    lp_cplv_rec.chr_id := x_chr_id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    OPEN check_party_csr(x_chr_id);
    FETCH check_party_csr INTO row_count;
    CLOSE check_party_csr;
    IF row_count = 1 THEN
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/*
    okl_la_validation_util_pvt.Validate_Party (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => x_chr_id,
      p_cle_id         => null,
      p_cpl_id         => null,
      p_lty_code       => null,
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => lp_cplv_rec.jtot_object1_code);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/


----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

       okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

      END IF;

----  Changes End

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);
    */

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


-- Start of comments
--
-- Procedure Name  : create_new_deal
-- Description     : creates a deal with no source
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_new_deal(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN  OUT NOCOPY VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_template_yn                  IN  VARCHAR2,
    p_template_type                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_program_name                 IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    -- 5116278
    SUBTYPE l_cplv_tbl_type is OKL_OKC_MIGRATION_PVT.cplv_tbl_type;
    SUBTYPE l_kplv_tbl_type is okl_kpl_pvt.kplv_tbl_type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    --Bug# 4558486
    lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    -- 5116278
    l_cplv_tbl l_cplv_tbl_type;
    l_kplv_tbl l_kplv_tbl_type;
    lx_cplv_tbl l_cplv_tbl_type;
    lx_kplv_tbl l_kplv_tbl_type;

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'CREATE_NEW_DEAL';

    row_count         NUMBER DEFAULT 0;

    CURSOR check_party_csr(p_chr_id NUMBER) IS
	--start modified abhsaxen for performance SQLID 20562694
	SELECT COUNT(1)
	    FROM okc_k_party_roles_B
	    WHERE dnz_chr_id = p_chr_id
	    AND chr_id = p_chr_id
	    AND rle_code = G_RLE_CODE
	    AND object1_id1 = p_customer_id1
	    AND object1_id2 = p_customer_id2
	--end modified abhsaxen for performance SQLID 20562694
	;

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    SELECT  access_level
    FROM    OKC_ROLE_SOURCES
    WHERE rle_code = p_rle_code
    AND     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;

    --Bug# 4558486
    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

    --Bug#5116278    start
    l_vp_cpl_id okc_k_party_roles_v.id%TYPE := NULL;
    x_cpl_id   okc_k_party_roles_v.id%TYPE := NULL;
    l_chr_id   okc_k_headers_b.id%type := NULL;

    CURSOR c_vp_cpl_csr(p_source_id NUMBER) IS
     SELECT id, object_version_number, sfwt_flag,
            cpl_id, chr_id, cle_id,
            rle_code, dnz_chr_id, object1_id1,
            object1_id2, jtot_object1_code, cognomen,
            code, facility, minority_group_lookup_code,
            small_business_flag, women_owned_flag, alias,
            attribute_category, attribute1, attribute2,
            attribute3, attribute4, attribute5,
            attribute6, attribute7, attribute8,
            attribute9, attribute10, attribute11,
            attribute12, attribute13, attribute14,
            attribute15, created_by, creation_date,
            last_updated_by, last_update_date, last_update_login,
            cust_acct_id, bill_to_site_use_id
     FROM okc_k_party_roles_v cplv
     WHERE cplv.rle_code = G_LEASE_VENDOR
     AND cplv.chr_id = p_source_id; -- vendor program id

    --Bug#5116278  end


  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
    lp_chrv_rec.scs_code := p_scs_code;
    lp_chrv_rec.contract_number := p_contract_number;
    lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;

--    lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);
    lp_chrv_rec.currency_code := OKL_ACCOUNTING_UTIL.get_func_curr_code;

    lp_chrv_rec.currency_code_renewed := NULL;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';
    lp_chrv_rec.start_date := p_effective_from;
/*
    IF ( p_template_yn = 'Y' ) THEN
      lp_chrv_rec.template_yn := 'Y';
    END IF;
*/
    lp_khrv_rec.object_version_number := 1.0;

    IF ( p_program_name IS NOT NULL ) THEN
      lp_khrv_rec.khr_id := p_program_id;
    END IF;

    IF ( p_template_type IS NOT NULL ) THEN
      lp_khrv_rec.template_type_code := p_template_type;
      lp_chrv_rec.template_yn := 'Y';
    END IF;
    --Added by dpsingh for LE Uptake
    lp_khrv_rec.legal_entity_id := p_legal_entity_id;
    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_chr_id := lx_chrv_rec.id;

    --Bug#5116278  start
    IF ( p_program_name IS NOT NULL ) THEN

       -- copy vp party lease vendor to lease contract
       l_vp_cpl_id := NULL;

       OPEN c_vp_cpl_csr(p_program_id);
       FETCH c_vp_cpl_csr BULK COLLECT INTO l_cplv_tbl;
       CLOSE c_vp_cpl_csr;

       IF( l_cplv_tbl.COUNT > 0 ) THEN

        FOR i IN l_cplv_tbl.FIRST..l_cplv_tbl.LAST
        LOOP
          l_cplv_tbl(i).ID := null;
          IF (l_cplv_tbl(i).CHR_ID IS NOT NULL) THEN
            l_cplv_tbl(i).CHR_ID := x_chr_id;
          END IF;
          IF (l_cplv_tbl(i).DNZ_CHR_ID IS NOT NULL) THEN
            l_cplv_tbl(i).DNZ_CHR_ID := x_chr_id;
          END IF;
          l_kplv_tbl(i).attribute_category := null;
        END LOOP;

  	IF okl_context.get_okc_org_id  IS NULL THEN
   	  l_chr_id := x_chr_id;
	  okl_context.set_okc_org_context(p_chr_id => l_chr_id );
        END IF;

        /*OKL_COPY_CONTRACT_PUB.copy_party_roles(
                  p_api_version	=> p_api_version,
                  p_init_msg_list	=> p_init_msg_list,
                  x_return_status 	=> x_return_status,
                  x_msg_count     	=> x_msg_count,
                  x_msg_data      	=> x_msg_data,
     	          p_cpl_id              => l_vp_cpl_id,
     	          p_cle_id              => NULL,
     	          p_chr_id              => x_chr_id,
     	          p_rle_code            => G_LEASE_VENDOR,
     	          x_cpl_id		=> x_cpl_id
     	   );*/

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cplv_tbl.count=' || l_cplv_tbl.count);
         END IF;
         okl_k_party_roles_pvt.create_k_party_role(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_cplv_tbl         => l_cplv_tbl,
           x_cplv_tbl         => lx_cplv_tbl,
           p_kplv_tbl         => l_kplv_tbl,
           x_kplv_tbl         => lx_kplv_tbl);

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

       END IF;

    END IF;
    --Bug#5116278  end

    IF ( p_customer_name IS NOT NULL ) THEN

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := x_chr_id;
    lp_cplv_rec.chr_id := x_chr_id;
    lp_cplv_rec.cle_id := NULL;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    OPEN check_party_csr(x_chr_id);
    FETCH check_party_csr INTO row_count;
    CLOSE check_party_csr;
    IF row_count = 1 THEN
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_already_exists');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

      END IF;

----  Changes End

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);
    */

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    END IF;


    OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

  PROCEDURE delete_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_old_khr_id                   IN  NUMBER, -- prev vp id
    p_source_id                    IN  NUMBER, -- vp id
    p_dest_id                      IN  NUMBER, -- k id
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER) IS

    l_api_name	VARCHAR2(30) := 'DELETE_RULES';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    lp_rgpv_rec Okl_Rule_Pub.rgpv_rec_type;

    lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lp_rmpv_rec OKL_OKC_MIGRATION_PVT.rmpv_rec_type;

    l_rgpr_id NUMBER := NULL;
    l_vp_tmpl_id  NUMBER;
    l_k_cpl_id okc_k_party_roles_v.id%TYPE := NULL;
    l_k_object1_id1 okc_k_party_roles_v.object1_id1%TYPE := NULL;

--Cursor to get vp template
    CURSOR vp_tmpl_csr(p_vp_id IN NUMBER) IS
    /* Modified this query to improve performance for bug#6979120
    SELECT id
    FROM   okl_k_headers_full_v
    WHERE  scs_code = 'PROGRAM'
    AND    sts_code IN ('ACTIVE','PASSED')
    AND    khr_id = p_vp_id
    AND    NVL(template_yn,'N') = 'Y'; */
    SELECT CHRB.ID ID
    FROM OKC_K_HEADERS_ALL_B CHRB,
         OKL_K_HEADERS KHR
    WHERE CHRB.SCS_CODE = 'PROGRAM'
    AND CHRB.ID = KHR.ID
    AND CHRB.STS_CODE IN ('ACTIVE', 'PASSED')
    AND CHRB.TEMPLATE_YN = 'Y'
    AND KHR.KHR_ID = p_vp_id;

 -- returns rgp id thet exist in lease as well as vp
    CURSOR c_prev_src_crs(p_vp_tmpl_id IN NUMBER) IS
         SELECT rglease.id, rglease.rgd_code
         FROM  okc_rule_groups_v rglease
         WHERE dnz_chr_id = p_dest_id
         AND chr_id = p_dest_id
         AND EXISTS(
               SELECT '1'
               FROM   okc_rule_groups_v rg,
                      okc_k_headers_v hdr
               WHERE  rg.chr_id = p_vp_tmpl_id
               AND    hdr.id = rg.chr_id
               AND    hdr.id = rg.dnz_chr_id
               AND    rg.cle_id IS NULL
               AND    rg.rgd_code = rglease.rgd_code
	       );

-- gets the party lease vendor that exists in vp
--start modifying abhsaxen Cursor not in use
--   CURSOR c_prev_cpl_csr IS
--end  modifying abhsaxen Cursor not in use

--start modifying abhsaxen Cursor not in use

--   CURSOR c_rg_party_csr(p_cpl_id IN NUMBER, p_object1_id1 IN okc_k_party_roles_v.object1_id1%TYPE) IS
--end modifying abhsaxen Cursor not in use
  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN vp_tmpl_csr(p_vp_id => p_old_khr_id);
    FETCH vp_tmpl_csr INTO l_vp_tmpl_id;

      IF vp_tmpl_csr%NOTFOUND THEN
         NULL;
      ELSE

        -- copy vp rules to lease contract
        FOR l_c_prev_src_crs IN c_prev_src_crs(p_vp_tmpl_id => l_vp_tmpl_id) LOOP

          lp_rgpv_rec.id := l_c_prev_src_crs.id;

          IF(l_c_prev_src_crs.rgd_code IS NOT NULL AND l_c_prev_src_crs.rgd_code <> G_VENDOR_BILL_RGD_CODE) THEN

            OKL_RULE_PUB.delete_rule_group(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> x_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_rgpv_rec         => lp_rgpv_rec
             );

	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;

         END IF;

        END LOOP;

     END IF;

   CLOSE vp_tmpl_csr;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_id                    IN  NUMBER, -- vp id
    p_dest_id                      IN  NUMBER, -- k id
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER) IS

    l_api_name	VARCHAR2(30) := 'COPY_RULES';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_rgp_id 		okc_rule_groups_v.id%TYPE;
    l_cle_id		okc_rule_groups_v.cle_id%TYPE DEFAULT NULL;
    l_chr_id		okc_rule_groups_v.chr_id%TYPE := p_dest_id;
    l_to_template_yn	VARCHAR2(5) :='N';
    x_rgp_id		okc_rule_groups_v.id%TYPE;

    l_func_curr_code     	okc_k_headers_b.currency_code%TYPE := NULL;
    l_k_curr_code        	okc_k_headers_b.currency_code%TYPE := NULL;
    l_start_date                okc_k_headers_b.start_date%TYPE;
    l_rule_amt                  NUMBER;
    x_contract_currency	        okl_k_headers_full_v.currency_code%TYPE := NULL;
    x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE := NULL;
    x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE := NULL;
    x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE := NULL;
    x_converted_amount 		NUMBER := NULL;

    l_rgd_code                  okc_rule_groups_b.rgd_code%TYPE := NULL;
    l_rule_info_cat             okc_rules_b.rule_information_category%TYPE := NULL;
    l_rule_id                   NUMBER := NULL;
    l_rule_segment              VARCHAR2(250) := NULL;

    l_no_data_found BOOLEAN := TRUE;

    l_vp_tmpl_id  NUMBER;

  --Cursor to get vp template
    CURSOR vp_tmpl_csr(p_vp_id IN NUMBER) IS
    /* Modified this query to improve performance for bug#6979120
    SELECT id
    FROM   okl_k_headers_full_v
    WHERE  scs_code = 'PROGRAM'
    AND    sts_code IN ('ACTIVE','PASSED')
    AND    khr_id = p_vp_id
    AND    NVL(template_yn,'N') = 'Y'; */
    SELECT CHRB.ID ID
    FROM OKC_K_HEADERS_ALL_B CHRB,
         OKL_K_HEADERS KHR
    WHERE CHRB.SCS_CODE = 'PROGRAM'
    AND CHRB.ID = KHR.ID
    AND CHRB.STS_CODE IN ('ACTIVE', 'PASSED')
    AND CHRB.TEMPLATE_YN = 'Y'
    AND KHR.KHR_ID = p_vp_id;

    -- returns vendor program rgd codes which are qualified for lease
    CURSOR c_src_crs(p_vp_tmpl_id IN NUMBER) IS
        SELECT rg.id
        FROM   okc_rule_groups_v rg,
               okc_k_headers_v hdr
        WHERE  rg.chr_id = p_vp_tmpl_id
        AND    hdr.id = rg.chr_id
        AND    hdr.id = rg.dnz_chr_id
        AND    rg.cle_id IS NULL
        AND  EXISTS
             (SELECT '1'
              FROM   okc_subclass_rg_defs rgdfs
              WHERE  rgdfs.rgd_code = rg.rgd_code
              AND    rgdfs.scs_code = 'LEASE')
        AND NOT EXISTS
           (SELECT '1'
            FROM  okc_rule_groups_v rglease
            WHERE dnz_chr_id =p_dest_id
            AND chr_id = p_dest_id
        AND rglease.rgd_code = rg.rgd_code);

     CURSOR c_rule_amt_crs(p_rule_code IN VARCHAR2, p_rule_group_code IN VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562750
	SELECT fus.application_column_name
		FROM   FND_DESCR_FLEX_COLUMN_USAGES fus,
		       fnd_flex_value_sets ffv,
		       okc_rg_def_rules    defrul,
		       fnd_lookup_values   flup,
		       okc_rule_defs_v     rulup
		WHERE  fus.DESCRIPTIVE_FLEX_CONTEXT_CODE  = defrul.rdf_code
		AND    fus.application_id = 540
		AND    ffv.flex_value_set_id = fus.flex_value_set_id
		AND    flup.lookup_code         = defrul.rgd_code
		AND    flup.lookup_type         = 'OKC_RULE_GROUP_DEF'
		AND    rulup.rule_code          = defrul.rdf_code
		AND    defrul.rdf_code          = p_rule_code
		AND    defrul.rgd_code          = p_rule_group_code
		AND    flex_value_set_name = 'OKC_AMOUNT'
	--end modified abhsaxen for performance SQLID 20562750
	;
     CURSOR c_rule_csr (p_rgp_id IN NUMBER) IS
	--Start modified abhsaxen for performance SQLID 20562755
	select rgp.rgd_code,rul.rule_information_category,rul.id
	 from okc_rule_groups_b rgp, okc_rules_b rul
	 where rgp.id = rul.rgp_id
	 and rul.dnz_chr_id = p_dest_id
	 and rgp.id = p_rgp_id
	 and exists (
	  select 1
	  from   FND_DESCR_FLEX_COLUMN_USAGES fus,
	      fnd_flex_value_sets ffv,
	      okc_rg_def_rules    defrul,
	      fnd_lookup_values   flup,
	      okc_rule_defs_b     rulup
	  where  fus.descriptive_flex_context_code  = defrul.rdf_code
		  and    fus.application_id = 540
	  and    ffv.flex_value_set_id(+) =  fus.flex_value_set_id
	  and    flup.lookup_code         =  defrul.rgd_code
	  and    flup.lookup_type         =  'OKC_RULE_GROUP_DEF'
	  and    rulup.rule_code          =  defrul.rdf_code
	  and    flex_value_set_name      =  'OKC_AMOUNT'
	  and    defrul.rdf_code          =  rul.rule_information_category -- rule
	  and    defrul.rgd_code          =  rgp.rgd_code -- rule group
	  );
	--end modified abhsaxen for performance SQLID 20562755

    CURSOR c_k_curr_csr IS
     SELECT currency_code, start_date
     FROM okc_k_headers_b
     WHERE id = p_dest_id;

    CURSOR c_rule_segmnts_csr(p_rule_id IN NUMBER) IS
     SELECT RULE_INFORMATION1,RULE_INFORMATION2,RULE_INFORMATION3,RULE_INFORMATION4,RULE_INFORMATION5,
            RULE_INFORMATION6,RULE_INFORMATION7,RULE_INFORMATION8,RULE_INFORMATION9,RULE_INFORMATION10,
            RULE_INFORMATION11,RULE_INFORMATION12,RULE_INFORMATION13,RULE_INFORMATION14,RULE_INFORMATION15
     FROM okc_rules_v
     WHERE id = p_rule_id
     AND   dnz_chr_id = p_dest_id;

    rul_seg_rec c_rule_segmnts_csr%ROWTYPE;

    lp_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lp_rmpv_rec OKL_OKC_MIGRATION_PVT.rmpv_rec_type;
    lx_rmpv_rec OKL_OKC_MIGRATION_PVT.rmpv_rec_type;

    l_vp_cpl_id okc_k_party_roles_v.id%TYPE := NULL;
    x_cpl_id   okc_k_party_roles_v.id%TYPE := NULL;

    l_cpl_id  okc_k_party_roles_v.id%TYPE := NULL;
    l_rrd_id  NUMBER := NULL;
    l_vndr_blng_rgp_id NUMBER := NULL;
--start modifying abhsaxen Cursor not in use
--   CURSOR c_lse_vndr_csr IS
--end modifying abhsaxen Cursor not in use

   CURSOR c_rrdid_csr IS
    SELECT   rgrdfs.id
    FROM     okc_k_headers_b CHR,
             okc_subclass_roles sre,
             okc_role_sources rse,
             okc_subclass_rg_defs rgdfs,
             okc_rg_role_defs rgrdfs
    WHERE    CHR.id =  p_dest_id
    AND      sre.scs_code = CHR.scs_code
    AND      sre.rle_code = rse.rle_code
    AND      rse.rle_code = G_LEASE_VENDOR
    AND      rse.buy_or_sell = CHR.buy_or_sell
    AND      rgdfs.scs_code = CHR.scs_code
    AND      rgdfs.rgd_code = G_VENDOR_BILL_RGD_CODE
    AND      rgrdfs.srd_id = rgdfs.id
    AND      rgrdfs.sre_id = sre.id;

   CURSOR c_vndr_blng_id_csr IS
    SELECT rgpv.id
    FROM okc_rule_groups_v rgpv
    WHERE rgpv.rgd_code = G_VENDOR_BILL_RGD_CODE
    AND rgpv.dnz_chr_id   = p_source_id;

   CURSOR c_vp_cpl_csr IS
--Start modified abhsaxen for performance SQLID 20562566
select cplv.id
    from okc_k_party_roles_b cplv
    where cplv.rle_code = g_lease_vendor
    and cplv.chr_id = p_source_id
    and cplv.dnz_chr_id = cplv.chr_id
    and not exists (select 1
                    from okc_k_party_roles_b s_cpl
                    where s_cpl.chr_id = p_dest_id
                    and s_cpl.dnz_chr_id = s_cpl.chr_id
                    and s_cpl.rle_code = g_lease_vendor
                    and cplv.object1_id1 = s_cpl.object1_id1
                    );
--end modified abhsaxen for performance SQLID 20562566

    BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);


    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

         -- copy vp party lease vendor to lease contract
         l_vp_cpl_id := NULL;

         OPEN c_vp_cpl_csr;
         FETCH c_vp_cpl_csr INTO l_vp_cpl_id;
         CLOSE c_vp_cpl_csr;

         IF( l_vp_cpl_id IS NOT NULL) THEN

           OKL_COPY_CONTRACT_PUB.copy_party_roles(
              p_api_version	=> p_api_version,
              p_init_msg_list	=> p_init_msg_list,
              x_return_status 	=> x_return_status,
              x_msg_count     	=> x_msg_count,
              x_msg_data      	=> x_msg_data,
 	      p_cpl_id          => l_vp_cpl_id,
 	      p_cle_id          => NULL,
 	      p_chr_id          => l_chr_id,
 	      P_rle_code        => G_LEASE_VENDOR,
 	      x_cpl_id		=> x_cpl_id
 	     );

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
 	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

           l_vndr_blng_rgp_id := NULL;
           OPEN c_vndr_blng_id_csr;
           FETCH c_vndr_blng_id_csr INTO l_vndr_blng_rgp_id;
           CLOSE c_vndr_blng_id_csr;

           IF( l_vndr_blng_rgp_id IS NOT NULL AND x_cpl_id IS NOT NULL) THEN

            OKL_COPY_CONTRACT_PUB.copy_rules(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> x_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_rgp_id		=> l_vndr_blng_rgp_id,
             p_cle_id		=> NULL,
             p_chr_id		=> l_chr_id,
             p_to_template_yn   => l_to_template_yn,
             x_rgp_id		=> x_rgp_id);

	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;

           END IF;


           IF( x_rgp_id IS NOT NULL AND x_cpl_id IS NOT NULL) THEN

             l_rrd_id := NULL;
             OPEN c_rrdid_csr;
             FETCH c_rrdid_csr INTO l_rrd_id;
             CLOSE c_rrdid_csr;

             lp_rmpv_rec.rgp_id := x_rgp_id;
             lp_rmpv_rec.cpl_id := x_cpl_id;
             lp_rmpv_rec.dnz_chr_id := l_chr_id;
             lp_rmpv_rec.rrd_id := l_rrd_id;

             OKL_RULE_PUB.create_rg_mode_pty_role(
	          p_api_version    => p_api_version,
	          p_init_msg_list  => p_init_msg_list,
	          x_return_status  => x_return_status,
	          x_msg_count      => x_msg_count,
	          x_msg_data       => x_msg_data,
	          p_rmpv_rec       => lp_rmpv_rec,
	          x_rmpv_rec       => lx_rmpv_rec
	          );

	     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	           RAISE OKC_API.G_EXCEPTION_ERROR;
	     END IF;

           END IF;

        END IF;


    OPEN vp_tmpl_csr(p_vp_id => p_source_id);
      FETCH vp_tmpl_csr INTO l_vp_tmpl_id;
      IF vp_tmpl_csr%NOTFOUND THEN
         NULL;
      ELSE

        -- copy vp rules to lease contract
        FOR l_c_src_crs IN c_src_crs(p_vp_tmpl_id => l_vp_tmpl_id) LOOP

        l_rgp_id := l_c_src_crs.id; -- gets vendor program rgd code

        OKL_COPY_CONTRACT_PUB.copy_rules(
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> x_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_rgp_id		=> l_rgp_id,
             p_cle_id		=> l_cle_id,
             p_chr_id		=> l_chr_id,
             p_to_template_yn   => l_to_template_yn,
             x_rgp_id		=> x_rgp_id);

	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;


-- start of currency conversion for program rules

IF ( x_rgp_id IS NOT NULL) THEN

  l_func_curr_code := NULL;
  -- if functional currency code is not equal to contract currency code
  l_func_curr_code := OKL_ACCOUNTING_UTIL.get_func_curr_code;

  l_k_curr_code := NULL;
  l_start_date := NULL;

  OPEN c_k_curr_csr;
  FETCH c_k_curr_csr INTO l_k_curr_code, l_start_date;
  CLOSE c_k_curr_csr;

  IF(l_func_curr_code IS NOT NULL AND l_k_curr_code IS NOT NULL AND l_func_curr_code <> l_k_curr_code) THEN


     FOR l_c_rule_csr IN c_rule_csr(p_rgp_id => x_rgp_id) LOOP -- get all the rules

          l_rgd_code          := l_c_rule_csr.rgd_code;
          l_rule_info_cat     := l_c_rule_csr.rule_information_category;
          l_rule_id           := l_c_rule_csr.id;

           OPEN c_rule_segmnts_csr (l_rule_id);
           FETCH c_rule_segmnts_csr INTO rul_seg_rec;
           CLOSE c_rule_segmnts_csr;

           l_rule_segment := NULL;
           l_rule_amt := NULL;

           lp_rulv_rec.RULE_INFORMATION1 := rul_seg_rec.RULE_INFORMATION1;
           lp_rulv_rec.RULE_INFORMATION2 := rul_seg_rec.RULE_INFORMATION2;
           lp_rulv_rec.RULE_INFORMATION3 := rul_seg_rec.RULE_INFORMATION3;
           lp_rulv_rec.RULE_INFORMATION4 := rul_seg_rec.RULE_INFORMATION4;
           lp_rulv_rec.RULE_INFORMATION5 := rul_seg_rec.RULE_INFORMATION5;
           lp_rulv_rec.RULE_INFORMATION6 := rul_seg_rec.RULE_INFORMATION6;
           lp_rulv_rec.RULE_INFORMATION7 := rul_seg_rec.RULE_INFORMATION7;
           lp_rulv_rec.RULE_INFORMATION8 := rul_seg_rec.RULE_INFORMATION8;
           lp_rulv_rec.RULE_INFORMATION9 := rul_seg_rec.RULE_INFORMATION9;
           lp_rulv_rec.RULE_INFORMATION10 := rul_seg_rec.RULE_INFORMATION10;
           lp_rulv_rec.RULE_INFORMATION11 := rul_seg_rec.RULE_INFORMATION11;
           lp_rulv_rec.RULE_INFORMATION12 := rul_seg_rec.RULE_INFORMATION12;
           lp_rulv_rec.RULE_INFORMATION13 := rul_seg_rec.RULE_INFORMATION13;
           lp_rulv_rec.RULE_INFORMATION14 := rul_seg_rec.RULE_INFORMATION14;
           lp_rulv_rec.RULE_INFORMATION15 := rul_seg_rec.RULE_INFORMATION15;

           FOR l_c_rule_amt_crs IN c_rule_amt_crs(p_rule_code => l_rule_info_cat, p_rule_group_code => l_rgd_code) LOOP -- get all the rule amount segments

             l_rule_segment := l_c_rule_amt_crs.application_column_name;
             IF(l_rule_segment IS NOT NULL) THEN

               IF (l_rule_segment = 'RULE_INFORMATION1') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION1;
               ELSIF (l_rule_segment = 'RULE_INFORMATION2') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION2;
               ELSIF (l_rule_segment = 'RULE_INFORMATION3') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION3;
               ELSIF (l_rule_segment = 'RULE_INFORMATION4') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION4;
               ELSIF (l_rule_segment = 'RULE_INFORMATION5') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION5;
               ELSIF (l_rule_segment = 'RULE_INFORMATION6') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION6;
               ELSIF (l_rule_segment = 'RULE_INFORMATION7') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION7;
               ELSIF (l_rule_segment = 'RULE_INFORMATION8') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION8;
               ELSIF (l_rule_segment = 'RULE_INFORMATION9') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION9;
               ELSIF (l_rule_segment = 'RULE_INFORMATION10') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION10;
               ELSIF (l_rule_segment = 'RULE_INFORMATION11') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION11;
               ELSIF (l_rule_segment = 'RULE_INFORMATION12') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION12;
               ELSIF (l_rule_segment = 'RULE_INFORMATION13') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION13;
               ELSIF (l_rule_segment = 'RULE_INFORMATION14') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION14;
               ELSIF (l_rule_segment = 'RULE_INFORMATION15') THEN
                l_rule_amt := rul_seg_rec.RULE_INFORMATION15;
               END IF;

             END IF;

               IF (l_rule_amt IS NOT NULL) THEN
                -- do currency conversion for DFF amount columns
                OKL_ACCOUNTING_UTIL.convert_to_contract_currency (
   	  		p_khr_id  		  	=> l_chr_id,
	 		p_from_currency   		=> l_func_curr_code,
	 		p_transaction_date 		=> l_start_date,
	 		p_amount 			=> l_rule_amt,
	 		x_contract_currency		=> x_contract_currency,
	 		x_currency_conversion_type	=> x_currency_conversion_type,
	 		x_currency_conversion_rate	=> x_currency_conversion_rate,
	 		x_currency_conversion_date	=> x_currency_conversion_date,
	 		x_converted_amount 		=> x_converted_amount);


		       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
		          RAISE OKC_API.G_EXCEPTION_ERROR;
		       END IF;

                     IF(l_rule_id IS NOT NULL AND x_converted_amount IS NOT NULL) THEN

                       x_converted_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount
                                (
                       		p_amount =>  x_converted_amount,
                       		p_currency_code => l_k_curr_code
                       		);

                       lp_rulv_rec.id := l_rule_id;
	               IF (l_rule_segment = 'RULE_INFORMATION1') THEN
                               lp_rulv_rec.RULE_INFORMATION1 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION2') THEN
	                       lp_rulv_rec.RULE_INFORMATION2 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION3') THEN
	                       lp_rulv_rec.RULE_INFORMATION3 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION4') THEN
	                       lp_rulv_rec.RULE_INFORMATION4 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION5') THEN
	                       lp_rulv_rec.RULE_INFORMATION5 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION6') THEN
	                       lp_rulv_rec.RULE_INFORMATION6 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION7') THEN
	                       lp_rulv_rec.RULE_INFORMATION7 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION8') THEN
	                       lp_rulv_rec.RULE_INFORMATION8:= TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION9') THEN
	                       lp_rulv_rec.RULE_INFORMATION9 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION10') THEN
	                       lp_rulv_rec.RULE_INFORMATION10 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION11') THEN
	                       lp_rulv_rec.RULE_INFORMATION11 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION12') THEN
	                       lp_rulv_rec.RULE_INFORMATION12 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION13') THEN
	                       lp_rulv_rec.RULE_INFORMATION13 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION14') THEN
	                       lp_rulv_rec.RULE_INFORMATION14 := TO_CHAR(x_converted_amount);
	               ELSIF (l_rule_segment = 'RULE_INFORMATION15') THEN
	                       lp_rulv_rec.RULE_INFORMATION15 := TO_CHAR(x_converted_amount);
	               END IF;

	 	       l_rule_segment := NULL;
	 	       l_rule_amt := NULL;

                     END IF;
               END IF;

 	   END LOOP;

           IF(l_rule_id IS NOT NULL AND x_converted_amount IS NOT NULL) THEN

               OKL_RULE_PUB.update_rule(
		         p_api_version    => p_api_version,
		         p_init_msg_list  => p_init_msg_list,
		         x_return_status  => x_return_status,
		         x_msg_count      => x_msg_count,
		         x_msg_data       => x_msg_data,
		         p_rulv_rec       => lp_rulv_rec,
		         x_rulv_rec       => lx_rulv_rec);

                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
  		          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
		          RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

            END IF;

            l_rgd_code := NULL;
            l_rule_info_cat := NULL;
            l_rule_id := NULL;
            rul_seg_rec := NULL;
            x_converted_amount := NULL;

      END LOOP;

  END IF;

 END IF;

-- end of currency conversion for program rules

 END LOOP;

 END IF;

 CLOSE vp_tmpl_csr;

 OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_old_khr_id                   IN  NUMBER, -- prev k khr id
    p_prog_override_yn             IN  VARCHAR2, -- program yn
    p_source_id                    IN  NUMBER, -- vp id
    p_dest_id                      IN  NUMBER, -- k id
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER) IS

    l_api_name	VARCHAR2(30) := 'COPY_RULES';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_org_id =>  p_org_id,  p_organization_id => p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    IF( (p_old_khr_id IS NOT NULL AND p_source_id IS NOT NULL AND p_old_khr_id <> p_source_id
    	  			AND p_prog_override_yn IS NOT NULL AND p_prog_override_yn = 'Y' )
      OR (p_old_khr_id IS NOT NULL AND p_source_id IS NULL
      				AND p_prog_override_yn IS NOT NULL AND p_prog_override_yn = 'Y' )

      ) THEN

          -- delete all the rules of the old_khr_id'S program template rules
           delete_rules(
	        p_api_version       => p_api_version,
	        p_init_msg_list     => p_init_msg_list,
	        x_return_status     => x_return_status,
	        x_msg_count         => x_msg_count,
	        x_msg_data          => x_msg_data,
	        p_old_khr_id        => p_old_khr_id,
	        p_source_id         => p_source_id,
	        p_dest_id           => p_dest_id,
	        p_org_id            => okl_context.get_okc_org_id,
	        p_organization_id   => okl_context.get_okc_organization_id
	        );

           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	         RAISE OKC_API.G_EXCEPTION_ERROR;
           END IF;

    END IF;


    IF( p_source_id IS NOT NULL AND p_old_khr_id IS NULL ) THEN

           copy_rules(
	        p_api_version       => p_api_version,
	        p_init_msg_list     => p_init_msg_list,
	        x_return_status     => x_return_status,
	        x_msg_count         => x_msg_count,
	        x_msg_data          => x_msg_data,
                p_source_id         => p_source_id, -- vp id
                p_dest_id           => p_dest_id, -- k id
	        p_org_id            => okl_context.get_okc_org_id,
	        p_organization_id   => okl_context.get_okc_organization_id
	        );

	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;

    ELSIF( p_source_id IS NOT NULL AND p_old_khr_id IS NOT NULL AND p_prog_override_yn IS NOT NULL AND p_prog_override_yn = 'Y' ) THEN

           copy_rules(
	        p_api_version       => p_api_version,
	        p_init_msg_list     => p_init_msg_list,
	        x_return_status     => x_return_status,
	        x_msg_count         => x_msg_count,
	        x_msg_data          => x_msg_data,
                p_source_id         => p_source_id, -- vp id
                p_dest_id           => p_dest_id, -- k id
	        p_org_id            => okl_context.get_okc_org_id,
	        p_organization_id   => okl_context.get_okc_organization_id
	        );

	    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	       RAISE OKC_API.G_EXCEPTION_ERROR;
	    END IF;

    END IF;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_source_crs IS
      SELECT template_yn, chr_type
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    l_template_yn OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_source_chr_id IS NULL) OR (p_source_chr_id = OKC_API.G_MISS_NUM) THEN
      create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => p_customer_code,
         x_chr_id          => x_chr_id,
    --Added by dpsingh for LE Uptake
         p_legal_entity_id => p_legal_entity_id);
    ELSE
    -- need to figure out what kind of source do we have
	OPEN l_source_crs;
        FETCH l_source_crs INTO l_template_yn, l_chr_type;
        CLOSE l_source_crs;

        -- copy from template
        IF (l_template_yn = 'Y') THEN
          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
        ELSE
          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
        END IF;
    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

/* Bug# 3948361 - Re-lease contract functionality is moved to Revisions page
-- Start of comments
--
-- Procedure Name  : create_from_release
-- Description     : creates a deal from release
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_from_release (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER) AS

    x_new_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    x_new_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    l_old_contract_number  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_new_contract_number  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_value VARCHAR2(1) := OKL_API.G_FALSE;

    CURSOR l_source_k_num_crs IS
      SELECT contract_number
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    l_inv_agmt_chr_id_tbl_type Okl_Securitization_Pvt.inv_agmt_chr_id_tbl_type;

    l_api_name	VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   okl_securitization_pvt.check_khr_securitized(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_khr_id                       => p_source_chr_id, --source_contract_id
      p_effective_date               => SYSDATE,    -- sysdate
      x_value                        => l_value, -- varchar2(1)
      x_inv_agmt_chr_id_tbl          => l_inv_agmt_chr_id_tbl_type    --okl_securitization_pvt.inv_agmt_chr_id_tbl_type
   );


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF(l_value = OKL_API.G_TRUE) THEN
            OKC_API.SET_MESSAGE(     p_app_name => g_app_name
          			   , p_msg_name => 'OKL_LLA_CONTRACT_SECU_ERROR'
          			   );
            RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;

   l_new_contract_number := p_contract_number;

   OPEN  l_source_k_num_crs;
   FETCH l_source_k_num_crs INTO l_old_contract_number;
   CLOSE l_source_k_num_crs;

   okl_release_pvt.create_release_contract(
      p_api_version          => p_api_version,
      p_init_msg_list        => p_init_msg_list,
      x_return_status        => x_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_old_contract_number  => l_old_contract_number,
      p_new_contract_number  => l_new_contract_number,
      x_new_chrv_rec         => x_new_chrv_rec,
      x_new_khrv_rec         => x_new_khrv_rec);

      x_chr_id := x_new_chrv_rec.id;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;
*/

-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	        VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_source_crs IS
      SELECT template_yn, chr_type
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_k_num_crs IS
      SELECT contract_number
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;

  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_source_chr_id IS NULL) OR (p_source_chr_id = OKC_API.G_MISS_NUM) THEN
      create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => p_customer_code,
         x_chr_id          => x_chr_id,
    --Added by dpsingh for LE Uptake
         p_legal_entity_id => p_legal_entity_id);
    ELSE
    -- need to figure out what kind of source do we have
	OPEN l_source_crs;
        FETCH l_source_crs INTO l_template_yn, l_chr_type;
        CLOSE l_source_crs;

        -- copy from template
        IF (p_source_code = 'template') THEN

          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

        /* Bug# 3948361 - Re-lease contract functionality is moved to Revisions page
        ELSIF (p_source_code = 'Re-Lease') THEN

          create_from_release(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
        */

        ELSIF (p_source_code = 'copy' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

        ELSIF (p_source_code = 'quote') THEN

          create_from_quote(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

        END IF;
    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	        VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_source_crs IS
      SELECT template_yn, chr_type
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_k_num_crs IS
      SELECT contract_number
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       , okc_k_party_roles_b prl
       WHERE prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND CHR.template_yn = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code     VARCHAR2(30) DEFAULT NULL;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
	 IF p_scs_code = 'LEASE' THEN
         	l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
         ELSIF p_scs_code = 'MASTER_LEASE' THEN
         	l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_LA_AGREEMENT_NUMBER');
         END IF;

         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_customer_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_la_validation_util_pvt.Get_Party_Jtot_data (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_scs_code       => p_scs_code,
      p_buy_or_sell    => 'S',
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => l_object_code,
      p_ak_region      => 'OKL_LA_DEAL_CREAT',
      p_ak_attribute   => 'OKL_CUSTOMER_NAME'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NOT NULL) THEN

     IF (p_source_code = 'template') THEN
       OPEN l_source_chr_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
     ELSIF (p_source_code = 'quote') THEN
       OPEN l_source_chr_id_crs('QUOTE','N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
     ELSE
       OPEN l_source_chr_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
     END IF;

     IF(p_source_chr_id IS NULL) THEN
   	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
 				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
 				, p_token1 => 'COL_NAME'
 				, p_token1_value => l_ak_prompt
 			   );
 	 RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    END IF;

    IF (p_source_code = 'new') THEN

        create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => l_object_code,
         p_customer_name   => p_customer_name,
         x_chr_id          => x_chr_id,
    --Added by dpsingh for LE Uptake
         p_legal_entity_id => p_legal_entity_id);

        -- copy from template
    ELSIF (p_source_code = 'template') THEN

          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    /* Bug# 3948361 - Re-lease contract functionality is moved to Revisions page
    ELSIF (p_source_code = 'Re-Lease') THEN

          create_from_release(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
    */

    ELSIF (p_source_code = 'copy' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'quote') THEN

          create_from_quote(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_template_yn                  IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	        VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    CURSOR l_source_crs IS
      SELECT template_yn, chr_type
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_k_num_crs IS
      SELECT contract_number
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       , okc_k_party_roles_b prl
       WHERE prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND CHR.template_yn = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number;

    CURSOR l_src_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       WHERE CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND CHR.template_yn = p_temp_yn
       AND CHR.contract_number = p_source_contract_number;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code        VARCHAR2(30) DEFAULT NULL;
    l_chr_id             OKC_K_HEADERS_B.ID%TYPE;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    /*
    -- mvasudev, 08/17/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
	   ,x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  l_check VARCHAR2(1);
      l_parameter_list           wf_parameter_list_t;
	BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	  -- Raise the event if it is a new Contract
	  --l_check := Okl_Lla_Util_Pvt.check_new_contract(p_chr_id);
      --IF (l_check= OKL_API.G_TRUE) THEN
	  IF (p_source_code = 'new') THEN
  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_CREATED,
								 p_parameters     => l_parameter_list);

	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/17/2004
    -- END, PROCEDURE to enable Business Event
    */


  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    If(p_contract_number is null) Then
	 x_return_status := OKC_API.g_ret_sts_error;
	 If p_scs_code = 'LEASE' Then
         	l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
         elsIf p_scs_code = 'MASTER_LEASE' Then
         	l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_LA_AGREEMENT_NUMBER');
         End If;

         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/

    IF(p_customer_name IS NULL) THEN
     IF p_scs_code = 'MASTER_LEASE' THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
    END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF(p_customer_name IS NOT NULL) THEN

    okl_la_validation_util_pvt.Get_Party_Jtot_data (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_scs_code       => p_scs_code,
      p_buy_or_sell    => 'S',
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => l_object_code,
      p_ak_region      => 'OKL_LA_DEAL_CREAT',
      p_ak_attribute   => 'OKL_CUSTOMER_NAME'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NOT NULL) THEN

    IF(p_customer_name IS NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_src_chr_id_crs(p_scs_code,'Y');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_src_chr_id_crs('QUOTE','N');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      ELSE
       OPEN l_src_chr_id_crs(p_scs_code,'N');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
     END IF;

    ELSE

      IF (p_source_code = 'template') THEN
       OPEN l_source_chr_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_source_chr_id_crs('QUOTE','N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      ELSE
       OPEN l_source_chr_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
     END IF;

    END IF;

     IF(p_source_chr_id IS NULL) THEN
   	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
 				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
 				, p_token1 => 'COL_NAME'
 				, p_token1_value => l_ak_prompt
 			   );
 	 RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    END IF;

    IF (p_source_code = 'new') THEN
/*
        create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => l_object_code,
         p_customer_name   => p_customer_name,
         p_template_yn     => p_template_yn,
         x_chr_id          => x_chr_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
*/
       l_chr_id := x_chr_id;

       IF okl_context.get_okc_org_id  IS NULL THEN
		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
       END IF;

       -- bug 4227922  property tax options defaulting onto contract
       IF ( p_scs_code = 'LEASE') THEN

       OKL_LA_PROPERTY_TAX_PVT.create_est_prop_tax_rules(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => l_chr_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       END IF;

        -- copy from template
    ELSIF (p_source_code = 'template') THEN

          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    /* Bug# 3948361 - Re-lease contract functionality is moved to Revisions page
    ELSIF (p_source_code = 'Re-Lease') THEN

          create_from_release(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
    */

    ELSIF (p_source_code = 'copy' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'quote') THEN

          create_from_quote(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


-- update contract header for template_yn
   IF ( p_template_yn = 'Y' AND ( p_source_code = 'quote' OR p_source_code = 'copy' OR p_source_code = 'Re-Lease' OR p_source_code = 'template' )) THEN

    lp_chrv_rec.id := x_chr_id;
    lp_khrv_rec.id := x_chr_id;
    lp_chrv_rec.template_yn := 'Y';

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

   /*
   -- mvasudev, 08/17/2004
   -- Code change to enable Business Event
   */
	raise_business_event(p_chr_id        => x_chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/17/2004
   -- END, Code change to enable Business Event
   */

   OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;



-- Start of comments
--
-- Procedure Name  : create_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_code                  IN  VARCHAR2,
    p_template_type                IN  VARCHAR2,
    p_contract_number              IN  VARCHAR2,
    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY  VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_program_name                 IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN OUT NOCOPY  NUMBER,
    p_source_contract_number       IN  VARCHAR2,
    x_chr_id                       OUT NOCOPY NUMBER,
    --Added by dpsingh for LE Uptake
    p_legal_entity_id              IN  NUMBER) AS

    l_api_name	        VARCHAR2(30) := 'CREATE_DEAL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_program_id	NUMBER;

    CURSOR l_source_crs IS
      SELECT template_yn, chr_type
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    CURSOR l_source_k_num_crs IS
      SELECT contract_number
      FROM   okc_k_headers_b
      WHERE  id = p_source_chr_id;

    -- cursor when only customer is selected
    CURSOR l_source_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       , okc_k_party_roles_b prl
       WHERE prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(chr.template_yn,'N') = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number;

    -- cursor when only customer is selected

    CURSOR l_leaseAppTmpl1_crs(p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2) IS
       SELECT CHR.id
       FROM okl_k_headers_full_v CHR
          , okc_k_party_roles_b prl
       WHERE prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = 'LEASE'
       AND CHR.chr_type = 'CYA'
       AND NVL(chr.template_yn,'N') = 'Y'
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND NVL(CHR.TEMPLATE_TYPE_CODE,'XXX') = 'LEASEAPP'
       AND CHR.contract_number = p_source_contract_number;

    -- cursor when only customer and program is selected
    CURSOR l_source_chr_prog_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2, l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
          , okc_k_party_roles_b prl
       WHERE chr.id = khr.id
       AND prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = p_temp_yn
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number
       AND exists( select 1 from okl_vp_associations vpaso
                   where vpaso.chr_id = l_prog_id);

    -- cursor when only customer and program is selected
    CURSOR l_leaseAppTmpl2_crs(p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2, p_customer_code VARCHAR2, l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
          , okc_k_party_roles_b prl
       WHERE chr.id = khr.id
       AND prl.dnz_chr_id = CHR.id
       AND prl.chr_id = CHR.id
       AND CHR.scs_code = 'LEASE'
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = 'Y'
       AND prl.rle_code = G_RLE_CODE
       AND prl.object1_id1 = p_object1_id1
       AND prl.object1_id2 = p_object1_id2
       AND prl.jtot_object1_code = p_customer_code
       AND CHR.contract_number = p_source_contract_number
       AND NVL(KHR.TEMPLATE_TYPE_CODE,'XXX') = 'LEASEAPP'
       AND khr_id = l_prog_id;

    -- cursor when only program is selected
    CURSOR l_source_prog_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2, l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
       WHERE chr.id = khr.id
       AND CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = p_temp_yn
       AND CHR.contract_number = p_source_contract_number
       AND exists( select 1 from okl_vp_associations vpaso
                   where vpaso.chr_id = l_prog_id);

    -- cursor when only program is selected
    CURSOR l_leaseAppTmpl3_crs(l_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR,
            okl_k_headers khr
       WHERE chr.id = khr.id
       AND CHR.scs_code = 'LEASE'
       AND CHR.chr_type = 'CYA'
       AND NVL(CHR.template_yn,'N') = 'Y'
       AND CHR.contract_number = p_source_contract_number
       AND NVL(KHR.TEMPLATE_TYPE_CODE,'XXX') = 'LEASEAPP'
       AND khr_id = l_prog_id;

    CURSOR l_src_chr_id_crs(p_scs_code VARCHAR2, p_temp_yn VARCHAR2) IS
       SELECT CHR.id
       FROM okc_k_headers_b CHR
       WHERE CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND CHR.template_yn = p_temp_yn
       AND CHR.contract_number = p_source_contract_number;

    CURSOR l_leaseAppTmpl_crs IS
       SELECT CHR.id
       FROM okl_k_headers_full_v CHR
       WHERE CHR.scs_code = 'LEASE'
       AND CHR.chr_type = 'CYA'
       AND nvl(CHR.template_yn,'N') = 'Y'
       AND NVL(CHR.TEMPLATE_TYPE_CODE,'XXX') = 'LEASEAPP'
       AND CHR.contract_number = p_source_contract_number;

    CURSOR l_program_csr IS
       SELECT chr.id
       FROM okl_k_headers_full_v chr
       WHERE chr.scs_code = 'PROGRAM'
       AND nvl(chr.template_yn, 'N') = 'N'
       AND chr.sts_code = 'ACTIVE'
       AND chr.authoring_org_id = p_org_id
       AND NVL(chr.start_date,p_effective_from) <= p_effective_from
       AND NVL(chr.end_date,p_effective_from) >= p_effective_from
       AND chr.contract_number = p_program_name;

    CURSOR l_progAgrmntTemp_crs(p_prog_id NUMBER) IS
       SELECT CHR.id
       FROM okl_k_headers_full_v CHR
       WHERE CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND nvl(chr.template_yn,'N') = 'Y'
       AND NVL(chr.template_type_code,'XXX') = OKL_TEMP_TYPE_PROGRAM
       AND CHR.contract_number = p_source_contract_number;
       /*
       AND exists( select 1
                   from okl_vp_associations vpaso
                   where vpaso.chr_id = p_prog_id
                   and vpaso.assoc_object_type_code = 'LC_TEMPLATE'
                   and NVL(vpaso.start_date,p_effective_from) <= p_effective_from
                   and NVL(vpaso.end_date,p_effective_from) >= p_effective_from);
                   */

    CURSOR l_progAgrmntTemp1_crs IS
       SELECT CHR.id
       FROM okl_k_headers_full_v CHR
       WHERE CHR.scs_code = p_scs_code
       AND CHR.chr_type = 'CYA'
       AND nvl(chr.template_yn,'N') = 'Y'
       AND NVL(chr.template_type_code,'XXX') = OKL_TEMP_TYPE_PROGRAM
       AND CHR.contract_number = p_source_contract_number;

--start changed by abhsaxen for Bug#6174484
     CURSOR l_quote_crs(p_auth_org_id NUMBER, p_inv_org_id NUMBER, p_quote_number VARCHAR2) IS
	select
	  lsq.id quote_id
	 from
	  okl_lease_quotes_b lsq
	 ,okl_lease_quotes_tl lsqt
	 ,okl_lease_opportunities_b lop
	 where  lop.org_id = p_auth_org_id
	 and lop.inv_org_id = p_inv_org_id
	 and lsq.parent_object_code = 'LEASEOPP'
	 and lop.id = lsq.parent_object_id
	 and lsq.id = lsqt.id
	 and lsqt.language = userenv('LANG')
	 and lsq.status = 'ACCEPTED'
	 and lsq.reference_number = p_quote_number
	 and not exists (select 1
			 from okl_lease_apps_all_b
			 where lease_opportunity_id = lop.id
			 and application_status <> 'WITHDRAWN')
	 and not exists (select 1
			 from okc_k_headers_all_b
			 where orig_system_source_code = 'OKL_QUOTE'
			 and orig_system_id1 = lsq.id
			 and sts_code <> 'ABANDONED');
--end changed by abhsaxen for Bug#6174484

--start changed by abhsaxen for Bug#6174484
    CURSOR l_leaseapp_crs(p_auth_org_id NUMBER, p_inv_org_id NUMBER, p_leaseapp_number VARCHAR2) IS
	select
	  lap.id leaseapp_id
	 from
	  okl_lease_applications_b lap
	 ,okl_lease_applications_tl lapt
	 where
	     lap.org_id = p_auth_org_id
	 and lap.inv_org_id = p_inv_org_id
	 and lap.id = lapt.id
	 and lapt.language = userenv('LANG')
	 and lap.application_status = 'CR-APPROVED'
	 and lap.reference_number = p_leaseapp_number
	 and not exists (select 1
			 from okc_k_headers_all_b
			 where orig_system_source_code = 'OKL_LEASE_APP'
			 and orig_system_id1 = lap.id
			 and sts_code <> 'ABANDONED')
	 and not exists (select 1
	   from okl_lease_apps_all_b
	   where parent_leaseapp_id = lap.id
	   and application_status not in ('WITHDRAWN' , 'CR-REJECTED'))
	;
--end changed by abhsaxen for Bug#6174484

    l_template_type      OKL_K_HEADERS.TEMPLATE_TYPE_CODE%TYPE;
    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code        VARCHAR2(30) DEFAULT NULL;
    l_chr_id             OKC_K_HEADERS_B.ID%TYPE;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    /*
    -- mvasudev, 08/17/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
	   ,x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  l_check VARCHAR2(1);
      l_parameter_list           wf_parameter_list_t;
	BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	  -- Raise the event if it is a new Contract
	  --l_check := Okl_Lla_Util_Pvt.check_new_contract(p_chr_id);
      --IF (l_check= OKL_API.G_TRUE) THEN
	  IF (p_source_code = 'new') THEN
  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_CREATED,
								 p_parameters     => l_parameter_list);

	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 08/17/2004
    -- END, PROCEDURE to enable Business Event
    */


  BEGIN

    OKC_CONTEXT.SET_OKC_ORG_CONTEXT(
		p_org_id =>  p_org_id,
		p_organization_id	=> p_organization_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_customer_name IS NULL) THEN
     IF p_scs_code = 'MASTER_LEASE' THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
    END IF;

    IF(p_program_name IS NOT NULL AND p_scs_code <> 'MASTER_LEASE' ) THEN
         l_program_id := null;
         open l_program_csr;
         fetch l_program_csr into l_program_id;
         close l_program_csr;

         IF( l_program_id IS NULL ) THEN

	   x_return_status := OKC_API.g_ret_sts_error;
           l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_PROGRAM');
           OKC_API.SET_MESSAGE(   p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	   RAISE OKC_API.G_EXCEPTION_ERROR;

	 END IF;
    END IF;

    IF(p_source_code <> 'new' AND p_source_contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   IF(p_customer_name IS NOT NULL) THEN

    okl_la_validation_util_pvt.Get_Party_Jtot_data (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_scs_code       => p_scs_code,
      p_buy_or_sell    => 'S',
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => l_object_code,
      p_ak_region      => 'OKL_LA_DEAL_CREAT',
      p_ak_attribute   => 'OKL_CUSTOMER_NAME'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

   IF(p_source_code <> 'new' AND p_source_contract_number IS NOT NULL) THEN

    IF(p_customer_name IS NULL AND p_program_name IS NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_src_chr_id_crs(p_scs_code,'Y');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_quote_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_quote_crs INTO p_source_chr_id;
       CLOSE l_quote_crs;
      ELSIF (p_source_code = 'leaseApp') THEN
       OPEN l_leaseapp_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_leaseapp_crs INTO p_source_chr_id;
       CLOSE l_leaseapp_crs;
      ELSIF (p_source_code = 'progAgrmntTemp') THEN
       OPEN  l_progAgrmntTemp1_crs;
       FETCH l_progAgrmntTemp1_crs INTO p_source_chr_id;
       CLOSE l_progAgrmntTemp1_crs;
      ELSIF (p_source_code = 'leaseAppTemp') THEN
       OPEN l_leaseAppTmpl_crs;
       FETCH l_leaseAppTmpl_crs INTO p_source_chr_id;
       CLOSE l_leaseAppTmpl_crs;
      ELSE
       OPEN l_src_chr_id_crs(p_scs_code,'N');
       FETCH l_src_chr_id_crs INTO p_source_chr_id;
       CLOSE l_src_chr_id_crs;
      END IF;

    ELSIF( p_customer_name IS NOT NULL AND p_program_name IS NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_chr_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_quote_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_quote_crs INTO p_source_chr_id;
       CLOSE l_quote_crs;
      ELSIF (p_source_code = 'leaseApp') THEN
       OPEN l_leaseapp_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_leaseapp_crs INTO p_source_chr_id;
       CLOSE l_leaseapp_crs;
      ELSIF (p_source_code = 'progAgrmntTemp') THEN
       OPEN  l_progAgrmntTemp1_crs;
       FETCH l_progAgrmntTemp1_crs INTO p_source_chr_id;
       CLOSE l_progAgrmntTemp1_crs;
      ELSIF (p_source_code = 'leaseAppTemp') THEN
       OPEN l_leaseAppTmpl1_crs(p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_leaseAppTmpl1_crs INTO p_source_chr_id;
       CLOSE l_leaseAppTmpl1_crs;
      ELSE
       OPEN l_source_chr_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code);
       FETCH l_source_chr_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_id_crs;
      END IF;

    ELSIF( p_customer_name IS NOT NULL AND p_program_name IS NOT NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_chr_prog_id_crs(p_scs_code,'Y',p_customer_id1,p_customer_id2,l_object_code, l_program_id);
       FETCH l_source_chr_prog_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_prog_id_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_quote_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_quote_crs INTO p_source_chr_id;
       CLOSE l_quote_crs;
      ELSIF (p_source_code = 'leaseApp') THEN
       OPEN l_leaseapp_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_leaseapp_crs INTO p_source_chr_id;
       CLOSE l_leaseapp_crs;
      ELSIF (p_source_code = 'progAgrmntTemp') THEN
       OPEN  l_progAgrmntTemp_crs(l_program_id);
       FETCH l_progAgrmntTemp_crs INTO p_source_chr_id;
       CLOSE l_progAgrmntTemp_crs;
      ELSIF (p_source_code = 'leaseAppTemp') THEN
       OPEN l_leaseAppTmpl2_crs(p_customer_id1,p_customer_id2,l_object_code, l_program_id);
       FETCH l_leaseAppTmpl2_crs INTO p_source_chr_id;
       CLOSE l_leaseAppTmpl2_crs;
      ELSE
       OPEN l_source_chr_prog_id_crs(p_scs_code,'N',p_customer_id1,p_customer_id2,l_object_code, l_program_id);
       FETCH l_source_chr_prog_id_crs INTO p_source_chr_id;
       CLOSE l_source_chr_prog_id_crs;
      END IF;

    ELSIF( p_customer_name IS NULL AND p_program_name IS NOT NULL) THEN

      IF (p_source_code = 'template') THEN
       OPEN l_source_prog_crs(p_scs_code,'Y',l_program_id);
       FETCH l_source_prog_crs INTO p_source_chr_id;
       CLOSE l_source_prog_crs;
      ELSIF (p_source_code = 'quote') THEN
       OPEN l_quote_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_quote_crs INTO p_source_chr_id;
       CLOSE l_quote_crs;
      ELSIF (p_source_code = 'leaseApp') THEN
       OPEN l_leaseapp_crs(p_org_id, p_organization_id, p_source_contract_number);
       FETCH l_leaseapp_crs INTO p_source_chr_id;
       CLOSE l_leaseapp_crs;
      ELSIF (p_source_code = 'progAgrmntTemp') THEN
       OPEN  l_progAgrmntTemp_crs(l_program_id);
       FETCH l_progAgrmntTemp_crs INTO p_source_chr_id;
       CLOSE l_progAgrmntTemp_crs;
      ELSIF (p_source_code = 'leaseAppTemp') THEN
       OPEN l_leaseAppTmpl3_crs(l_program_id);
       FETCH l_leaseAppTmpl3_crs INTO p_source_chr_id;
       CLOSE l_leaseAppTmpl3_crs;
      ELSE
       OPEN l_source_prog_crs(p_scs_code,'N',l_program_id);
       FETCH l_source_prog_crs INTO p_source_chr_id;
       CLOSE l_source_prog_crs;
      END IF;

    END IF;

    IF(p_source_chr_id IS NULL) THEN
   	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_SOURCE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
 				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
 				, p_token1 => 'COL_NAME'
 				, p_token1_value => l_ak_prompt
 			   );
 	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    END IF;

    IF (p_source_code = 'new') THEN

        create_new_deal(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_contract_number => p_contract_number,
         p_scs_code        => p_scs_code,
         p_customer_id1    => p_customer_id1,
         p_customer_id2    => p_customer_id2,
         p_customer_code   => l_object_code,
         p_customer_name   => p_customer_name,
         p_template_yn     => l_template_yn,
         p_template_type   => p_template_type,
         p_effective_from  => p_effective_from,
         p_program_name    => p_program_name,
         p_program_id      => p_program_id,
         x_chr_id          => x_chr_id,
    --Added by dpsingh for LE Uptake
         p_legal_entity_id => p_legal_entity_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       l_chr_id := x_chr_id;

       IF okl_context.get_okc_org_id  IS NULL THEN
		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
       END IF;

       -- bug 4227922  property tax options defaulting onto contract
       IF ( p_scs_code = 'LEASE') THEN

       OKL_LA_PROPERTY_TAX_PVT.create_est_prop_tax_rules(
         p_api_version     => l_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => l_chr_id);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       END IF;

        -- copy from template
    ELSIF (p_source_code = 'template') THEN

          create_from_template(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    /* Bug# 3948361 - Re-lease contract functionality is moved to Revisions page
    ELSIF (p_source_code = 'Re-Lease') THEN

          create_from_release(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);
    */

    ELSIF (p_source_code = 'copy' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'progAgrmntTemp' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'leaseAppTemp' ) THEN

          create_from_contract(
            p_api_version     => l_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_contract_number => p_contract_number,
            p_source_chr_id   => p_source_chr_id,
            x_chr_id          => x_chr_id);

    ELSIF (p_source_code = 'quote' ) THEN
    -- LEASEOPP
          create_from_quote(
            p_api_version        => l_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_contract_number    => p_contract_number,
            p_source_object_code => 'LEASEOPP',
            p_source_chr_id      => p_source_chr_id,
            x_chr_id             => x_chr_id);

    ELSIF (p_source_code = 'leaseApp' ) THEN
    -- LEASEAPP
          create_from_quote(
            p_api_version        => l_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_contract_number    => p_contract_number,
            p_source_object_code => 'LEASEAPP',
            p_source_chr_id      => p_source_chr_id,
            x_chr_id             => x_chr_id);

    END IF;

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   -- update contract header for template_yn
   IF ( p_template_type IS NOT NULL AND ( p_source_code = 'quote' OR p_source_code = 'copy' OR p_source_code = 'Re-Lease' OR p_source_code = 'template' OR p_source_code = 'progAgrmntTemp')) THEN

    lp_chrv_rec.id := x_chr_id;
    lp_khrv_rec.id := x_chr_id;

    IF(p_template_type = OKL_TEMP_TYPE_PROGRAM) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_PROGRAM;
      lp_chrv_rec.template_yn := 'Y';
    ELSIF(p_template_type = OKL_TEMP_TYPE_CONTRACT) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_CONTRACT;
      lp_chrv_rec.template_yn := 'Y';
    ELSIF(p_template_type = OKL_TEMP_TYPE_LEASEAPP) THEN
      lp_khrv_rec.template_type_code := OKL_TEMP_TYPE_LEASEAPP;
      lp_chrv_rec.template_yn := 'Y';
    ELSE
      lp_khrv_rec.template_type_code := NULL;
    END IF;

    IF(p_effective_from IS NOT NULL) THEN

      lp_chrv_rec.start_date := p_effective_from;

    END IF;

    IF(l_program_id IS NOT NULL) THEN

      lp_khrv_rec.khr_id := l_program_id;

    END IF;

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   ELSIF ( p_template_type IS NULL AND ( p_source_code = 'quote' OR p_source_code = 'copy' OR p_source_code = 'Re-Lease' OR p_source_code = 'template' OR p_source_code = 'progAgrmntTemp' OR p_source_code = 'leaseAppTemp')) THEN

    lp_chrv_rec.id := x_chr_id;
    lp_khrv_rec.id := x_chr_id;
    lp_chrv_rec.template_yn := 'N';
    lp_khrv_rec.template_type_code := NULL;

    IF(p_effective_from IS NOT NULL) THEN

      lp_chrv_rec.start_date := p_effective_from;

    END IF;

    IF(l_program_id IS NOT NULL) THEN

      lp_khrv_rec.khr_id := l_program_id;

    END IF;

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   END IF;

   /*
   -- mvasudev, 08/17/2004
   -- Code change to enable Business Event
   */
	raise_business_event(p_chr_id        => x_chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/17/2004
   -- END, Code change to enable Business Event
   */

   OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


-- Start of comments
--
-- Procedure Name  : validate_deal
-- Description     : creates a deal based on the information that comes
--	             from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_deal(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_customer_id1                 IN OUT NOCOPY VARCHAR2,
    p_customer_id2                 IN OUT NOCOPY  VARCHAR2,
    p_customer_code                IN OUT NOCOPY VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_customer_acc_id1             IN OUT NOCOPY VARCHAR2,
    p_customer_acc_id2             IN OUT NOCOPY VARCHAR2,
    p_customer_acc_code            IN OUT NOCOPY VARCHAR2,
    p_customer_acc_name            IN  VARCHAR2,
    p_product_name                 IN  VARCHAR2,
    p_product_id                   IN OUT NOCOPY VARCHAR2,
    p_contact_id1                  IN OUT NOCOPY VARCHAR2,
    p_contact_id2                  IN OUT NOCOPY VARCHAR2,
    p_contact_code                 IN OUT NOCOPY VARCHAR2,
    p_contact_name                 IN  VARCHAR2,
    p_mla_no                       IN  VARCHAR2,
    p_mla_id                       IN OUT NOCOPY VARCHAR2,
    p_chrv_rec       		   IN  chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY  khrv_rec_type
    ) AS

    l_api_name	        VARCHAR2(30) := 'validate_deal';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code     VARCHAR2(30) DEFAULT NULL;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
    l_chr_id	NUMBER;

    CURSOR l_chk_cust_acc_csr(p_cust_acc_id1 VARCHAR2, p_name VARCHAR2) IS
    SELECT COUNT(1)
    FROM okx_customer_accounts_v ca, okx_parties_v P
    WHERE P.id1 = ca.party_id
    AND ca.description = p_cust_acc_id1
    AND P.name = p_name;

    CURSOR l_product_csr IS
    SELECT id
    FROM OKL_PRODUCTS_V
    WHERE name = p_product_name;

    row_cnt  NUMBER;

  BEGIN

  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_chrv_rec.id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- contract number validation

   IF(p_chrv_rec.contract_number IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- customer validation

   IF(p_customer_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_la_validation_util_pvt.Get_Party_Jtot_data (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_scs_code       => p_chrv_rec.scs_code,
      p_buy_or_sell    => 'S',
      p_rle_code       => G_RLE_CODE,
      p_id1            => p_customer_id1,
      p_id2            => p_customer_id2,
      p_name           => p_customer_name,
      p_object_code    => p_customer_code,
      p_ak_region      => 'OKL_LA_DEAL_CREAT',
      p_ak_attribute   => 'OKL_CUSTOMER_NAME'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- customer account validation

   IF(p_customer_acc_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_la_validation_util_pvt.Validate_Rule (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => p_chrv_rec.id,
      p_rgd_code       => 'LACAN',
      p_rdf_code       => 'CAN',
      p_id1            => p_customer_acc_id1,
      p_id2            => p_customer_acc_id2,
      p_name           => p_customer_acc_name,
      p_object_code    => p_customer_acc_code,
      p_ak_region      => 'OKL_CONTRACT_DTLS',
      p_ak_attribute   => 'OKL_KDTLS_CUSTOMER_ACCOUNT_N'
      );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN l_chk_cust_acc_csr(p_customer_acc_name,p_customer_name);
    FETCH l_chk_cust_acc_csr INTO row_cnt;
    CLOSE l_chk_cust_acc_csr;

    IF row_cnt = 0 THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- product validation

    IF(p_product_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN l_product_csr;
    FETCH l_product_csr INTO p_product_id;
    CLOSE l_product_csr;

    IF p_product_id IS NULL THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- contact validation

   IF(p_contact_name IS NOT NULL) THEN

     okl_la_validation_util_pvt.Validate_Contact (
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_chr_id         => p_chrv_rec.id,
       p_rle_code       => 'LESSOR',
       p_cro_code       => 'SALESPERSON',
       p_id1            => p_contact_id1,
       p_id2            => p_contact_id2,
       p_name           => p_contact_name,
       p_object_code    => p_contact_code,
       p_ak_region      => 'OKL_CONTRACT_DTLS',
       p_ak_attribute   => 'OKL_KDTLS_SALES_REPRESENTATIVE'
       );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

   END IF;

   OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


-- Start of comments
--
-- Procedure Name  : update_release_contract
-- Description     : update release contract for
--                   PRODUCT_CHANGE/CUSTOMER_CHANGE
--
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_release_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_contract_number              IN  VARCHAR2,
    p_chr_description              IN  VARCHAR2,
    p_cust_id                      IN  NUMBER,
    p_customer_name                IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_acc_name            IN  VARCHAR2,
    p_customer_acct_id1            IN  VARCHAR2,
    p_product_name                 IN  VARCHAR2,
    p_mla_id                       IN  NUMBER,
    p_mla_no                       IN  VARCHAR2,
    p_gvr_id_mla                   IN  NUMBER,
    p_cl_id                        IN  NUMBER,
    p_cl_no                        IN  VARCHAR2,
    p_gvr_id_cl                    IN  NUMBER,
    p_deal_type                    IN  VARCHAR2,
    p_program_no                   IN  VARCHAR2,
    p_program_id                   IN  NUMBER,
    p_program_yn                   IN  VARCHAR2
    ) AS

    l_api_name	        VARCHAR2(30) := 'update_release_contract';
    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code     VARCHAR2(30) DEFAULT NULL;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
    l_chr_id	NUMBER;

    cursor l_get_cust_id_csr(p_name VARCHAR2) is
    select OKX_PARTY.ID1, OKX_PARTY.ID2
    from OKX_PARTIES_V OKX_PARTY
    where OKX_PARTY.name = p_name
    and okx_party.id1 = p_customer_id1;

    l_cust_id1 OKX_PARTIES_V.ID1%type := null;
    l_cust_id2 OKX_PARTIES_V.ID2%type := null;

    cursor l_get_cust_acc_csr(p_cust_acc_desc VARCHAR2, p_name VARCHAR2) is
    select ca.id1
    from okx_customer_accounts_v ca,
         okx_parties_v p
    where p.id1 = ca.party_id
    and ca.description = p_cust_acc_desc
    and p.name = p_name;

    l_cust_acct_id okx_customer_accounts_v.id1%type := null;

    CURSOR l_product_csr IS
    SELECT id
    FROM OKL_PRODUCTS_V
    WHERE name = p_product_name;

    l_product_id OKL_PRODUCTS_V.id%type := null;

    row_cnt  NUMBER;

    Cursor l_rbr_csr IS
    SELECT rbr_code
    FROM okl_trx_contracts
    WHERE khr_id_new = p_chr_id
--rkuttiya added for 12.1.1 multigaap project
    AND representation_type = 'PRIMARY';
--

    l_rbr_code okl_trx_contracts.rbr_code%type := null;

    cursor l_mla_csr is
    select id
    from OKL_k_headers_full_V
    where contract_number = p_mla_no
    and   scs_code = 'MASTER_LEASE'
    and STS_CODE = 'ACTIVE'
    and TEMPLATE_YN = 'N'
    and BUY_OR_SELL = 'S';

    l_mla_id number;

    cursor l_credit_line_csr is
    select cl.id
    from okl_k_hdr_crdtln_uv cl
    where  cl.contract_number = p_cl_no
    and exists ( select 1
                 from okc_k_headers_b chr
                 where chr.currency_code = cl.currency_code
                 and cl.end_date >= chr.start_date
                 and cl.cust_name  = p_customer_name
                 and cl.cust_acc_number = p_customer_acc_name);

    l_cl_id NUMBER;

    cursor l_program_csr is
    select id
    from OKL_k_headers_full_V prg_hdr
    where contract_number = p_program_no
    and scs_code = 'PROGRAM'
    and nvl(TEMPLATE_YN, 'N') = 'N'
    and sts_code = 'ACTIVE'
    and exists (select 1
                from okc_k_headers_b
                where id = p_chr_id
                and authoring_org_id = prg_hdr.authoring_org_id);

    l_program_id number;

    old_khr_id  NUMBER;

    CURSOR c_vp_exsts_csr IS
    SELECT khr_id
    FROM okl_k_headers_full_v
    WHERE id = p_chr_id;

    CURSOR c_context_csr IS
    SELECT authoring_org_id, inv_organization_id
    FROM okl_k_headers_full_V
    WHERE id = p_chr_id;

    l_auth_org_id okc_k_headers_b.authoring_org_id%type;
    l_inv_org_id okc_k_headers_b.inv_organization_id%type;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_lessee_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_lessee_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    lp_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lp_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    lx_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lx_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

    lp_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;
    lx_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;

    lp_cl_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;
    lx_cl_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;

    X_NO_DATA_FOUND BOOLEAN := TRUE;

    --Bug# 4558486
    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

  BEGIN

  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_chr_id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_rbr_code := null;
    open l_rbr_csr;
    fetch l_rbr_csr into l_rbr_code;
    close l_rbr_csr;

   If(l_rbr_code is not null and l_rbr_code = 'PRODUCT_CHANGE') Then

    -- product validation
    IF(p_product_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_product_id := null;
    OPEN l_product_csr;
    FETCH l_product_csr INTO l_product_id;
    CLOSE l_product_csr;

    IF l_product_id IS NULL THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  END IF;

  If(l_rbr_code is not null and l_rbr_code = 'CUSTOMER_CHANGE') Then

     -- customer validation
     IF(p_customer_name IS NULL) THEN
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    -- customer account validation
    IF(p_customer_acc_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_cust_id1 := null;
    l_cust_id2 := null;
    Open l_get_cust_id_csr(p_customer_name);
    Fetch l_get_cust_id_csr into l_cust_id1,l_cust_id2;
    Close l_get_cust_id_csr;

    If l_cust_id1 is null Then
     x_return_status := OKC_API.g_ret_sts_error;
     l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');
     OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
     raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_cust_acct_id := null;
    Open l_get_cust_acc_csr(p_customer_acc_name, p_customer_name);
    Fetch l_get_cust_acc_csr into l_cust_acct_id;
    Close l_get_cust_acc_csr;

    If l_cust_acct_id is null Then
     x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
     raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- mla validation
    If(p_mla_no is not null) Then

     l_mla_id := null;
     open l_mla_csr;
     fetch l_mla_csr into l_mla_id;
     close l_mla_csr;

     If l_mla_id is null Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_MASTER_LEASE_NUMBER');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;
     End If;

    End If;

   End If; -- end of customer change if

   If(l_rbr_code is not null and (l_rbr_code = 'CUSTOMER_CHANGE'  or  l_rbr_code = 'PRODUCT_CHANGE')) Then

    -- creditline validation
    If(p_cl_no is not null) Then

      l_cl_id := null;

      open l_credit_line_csr;
      fetch l_credit_line_csr into l_cl_id;
      close l_credit_line_csr;

      If l_cl_id is null Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                                , p_token1 => 'COL_NAME'
                                , p_token1_value => l_ak_prompt

                           );
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    End If;

    -- validation for creditline contract
    okl_la_validation_util_pvt.validate_creditline(
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_chr_id         => p_chr_id,
       p_deal_type      => p_deal_type,
       p_mla_no         => p_mla_no,
       p_cl_no          => p_cl_no
       );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

    -- program validation
    If(p_program_no is not null) Then

      l_program_id := null;
      open l_program_csr;
      fetch l_program_csr into l_program_id;
      close l_program_csr;

      If l_program_id is null Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PROGRAM');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

    End If;

End If;


  If(l_rbr_code is not null and (l_rbr_code = 'CUSTOMER_CHANGE'  or  l_rbr_code = 'PRODUCT_CHANGE')) Then

    -- product changes
    lp_pdtv_rec.id := l_product_id;
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters
          (p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
      	   x_no_data_found => x_no_data_found,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
      	   p_pdtv_rec      => lp_pdtv_rec,
      	   p_product_date  => NULL,
      	   p_pdt_parameter_rec => lx_pdt_param_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.id := p_chr_id;
    lp_chrv_rec.contract_number := p_contract_number;
    lp_chrv_rec.short_description := p_chr_description;
    lp_chrv_rec.description :=  p_chr_description;

    If(l_rbr_code is not null and l_rbr_code = 'CUSTOMER_CHANGE') Then

     lp_chrv_rec.cust_acct_id := l_cust_acct_id;

    End IF;

    If(l_rbr_code is not null and l_rbr_code = 'PRODUCT_CHANGE') Then

     lp_khrv_rec.deal_type :=  lx_pdt_param_rec.Deal_Type;

    End IF;

    lp_khrv_rec.id := p_chr_id;
    lp_khrv_rec.khr_id := l_program_id;

    OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

  END IF;

  If(l_rbr_code is not null and l_rbr_code = 'CUSTOMER_CHANGE' ) Then

        lp_lessee_cplv_rec.id := p_cust_id;
        lp_lessee_cplv_rec.dnz_chr_id := p_chr_id;
        lp_lessee_cplv_rec.chr_id := p_chr_id;
        lp_lessee_cplv_rec.object1_id1 := l_cust_id1;
        lp_lessee_cplv_rec.object1_id2 := l_cust_id2;
        lp_lessee_cplv_rec.rle_code := 'LESSEE';
        lp_lessee_cplv_rec.jtot_object1_code := 'OKX_PARTY';

      --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
      --              to update records in tables
      --              okc_k_party_roles_b and okl_k_party_roles
      /*
      OKL_OKC_MIGRATION_PVT.update_k_party_role(
             p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_cplv_rec       => lp_lessee_cplv_rec,
            x_cplv_rec       => lx_lessee_cplv_rec);
      */

      lp_kplv_rec.id := lp_lessee_cplv_rec.id;
      okl_k_party_roles_pvt.update_k_party_role(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_cplv_rec         => lp_lessee_cplv_rec,
        x_cplv_rec         => lx_lessee_cplv_rec,
        p_kplv_rec         => lp_kplv_rec,
        x_kplv_rec         => lx_kplv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   -- mla
   IF (p_gvr_id_mla IS NULL AND p_mla_no IS NOT NULL ) THEN

    lp_mla_gvev_rec.id := NULL;
    lp_mla_gvev_rec.dnz_chr_id := p_chr_id;
    lp_mla_gvev_rec.chr_id := p_chr_id;
    lp_mla_gvev_rec.chr_id_referred := l_mla_id;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.create_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec,
        x_gvev_rec       => lx_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_gvr_id_mla IS NOT NULL AND p_mla_no IS NOT NULL ) THEN

    lp_mla_gvev_rec.id := p_gvr_id_mla;
    lp_mla_gvev_rec.dnz_chr_id := p_chr_id;
    lp_mla_gvev_rec.chr_id := p_chr_id;
    lp_mla_gvev_rec.chr_id_referred := l_mla_id;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.update_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec,
        x_gvev_rec       => lx_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


   ELSIF (p_gvr_id_mla IS NOT NULL AND p_mla_no IS NULL ) THEN

     lp_mla_gvev_rec.id := p_gvr_id_mla;

     OKL_OKC_MIGRATION_PVT.delete_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

  END IF;

  If(l_rbr_code is not null and (l_rbr_code = 'CUSTOMER_CHANGE'  or  l_rbr_code = 'PRODUCT_CHANGE')) Then

   -- creditline
   IF (p_gvr_id_cl IS NULL AND p_cl_no IS NOT NULL ) THEN

    lp_cl_gvev_rec.id := NULL;
    lp_cl_gvev_rec.dnz_chr_id := p_chr_id;
    lp_cl_gvev_rec.chr_id := p_chr_id;
    lp_cl_gvev_rec.chr_id_referred := l_cl_id;
    lp_cl_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.create_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec,
        x_gvev_rec       => lx_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_gvr_id_cl IS NOT NULL AND p_cl_no IS NOT NULL ) THEN

    lp_cl_gvev_rec.id := p_gvr_id_cl;
    lp_cl_gvev_rec.dnz_chr_id := p_chr_id;
    lp_cl_gvev_rec.chr_id := p_chr_id;
    lp_cl_gvev_rec.chr_id_referred := l_cl_id;
    lp_cl_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.update_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec,
        x_gvev_rec       => lx_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_gvr_id_cl IS NOT NULL AND p_cl_no IS NULL ) THEN

    lp_cl_gvev_rec.id := p_gvr_id_cl;

    OKL_OKC_MIGRATION_PVT.delete_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

    IF (p_program_no IS NULL) THEN
     l_program_id := null;
    END IF;

    old_khr_id := NULL;
    OPEN c_vp_exsts_csr;
    FETCH c_vp_exsts_csr INTO old_khr_id;
    CLOSE c_vp_exsts_csr;

    l_auth_org_id := null;
    l_inv_org_id := null;

    OPEN c_context_csr;
    FETCH c_context_csr INTO l_auth_org_id, l_inv_org_id;
    CLOSE c_context_csr;

    IF (p_program_no IS NOT NULL OR old_khr_id IS NOT NULL) THEN

       copy_rules
       (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_old_khr_id        => old_khr_id,
        p_prog_override_yn  => p_program_yn, -- program flag yn
        p_source_id         => l_program_id,
        p_dest_id           => p_chr_id,
        p_org_id            => l_auth_org_id,
        p_organization_id   => l_inv_org_id
       );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

  END IF;

   If(l_rbr_code is not null and l_rbr_code = 'PRODUCT_CHANGE') Then

    -- product validation
    IF(p_product_name IS NULL) THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_REQUIRED_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_product_id := null;
    OPEN l_product_csr;
    FETCH l_product_csr INTO l_product_id;
    CLOSE l_product_csr;

    IF l_product_id IS NULL THEN
	 x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_ak_prompt
			   );
	 RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- product changes
    lp_pdtv_rec.id := l_product_id;
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters
          (p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
      	   x_no_data_found => x_no_data_found,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
      	   p_pdtv_rec      => lp_pdtv_rec,
      	   p_product_date  => NULL,
      	   p_pdt_parameter_rec => lx_pdt_param_rec);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    lp_chrv_rec.id := p_chr_id;
    lp_khrv_rec.id := p_chr_id;
    lp_khrv_rec.deal_type :=  lx_pdt_param_rec.Deal_Type;
    lp_khrv_rec.pdt_id := l_product_id;

    OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   End if; -- end of rbr code block

   OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


  PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  deal_rec_type,
      x_durv_rec                     OUT NOCOPY deal_rec_type
    ) AS

    l_api_name	       VARCHAR2(30) := 'update_deal';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    l_template_yn      OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type         OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number  OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code      VARCHAR2(30) DEFAULT NULL;
    l_temp_yn          OKC_K_HEADERS_B.TEMPLATE_YN%TYPE := p_durv_rec.chr_template_yn;

    l_ak_prompt        AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
    l_chr_id	       NUMBER;
    row_cnt  NUMBER;
    l_rgp_id NUMBER := NULL;
    l_rul_id NUMBER := NULL;

    CURSOR l_qcl_csr IS
    SELECT qcl.id
    FROM  OKC_QA_CHECK_LISTS_TL qcl,
          OKC_QA_CHECK_LISTS_B qclv
    WHERE qclv.Id = qcl.id
    AND UPPER(qcl.name) = 'OKL LA QA CHECK LIST'
    AND qcl.LANGUAGE = USERENV('LANG');

	-- START: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938
	/*
    CURSOR l_end_date_csr IS
    SELECT ADD_MONTHS(p_durv_rec.chr_start_date,p_durv_rec.khr_term_duration)-1
	FROM dual;
	*/
	-- END: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938

    CURSOR l_vers_version_csr IS
    SELECT vers.major_version||'.'||vers.minor_version
    FROM okc_k_vers_numbers_v vers
    WHERE vers.chr_id = p_durv_rec.chr_id;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_lessee_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_lessee_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

    lp_lessor_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lx_lessor_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
    lp_ctcv_rec OKL_OKC_MIGRATION_PVT.ctcv_rec_type;
    lx_ctcv_rec OKL_OKC_MIGRATION_PVT.ctcv_rec_type;

    lp_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;
    lx_mla_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;

    lp_cl_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;
    lx_cl_gvev_rec OKL_OKC_MIGRATION_PVT.gvev_rec_type;

    lp_larles_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_larles_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_larles_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_larles_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_LAREBL_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_LAREBL_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_LAREBL_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_LAREBL_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_LATOWN_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_LATOWN_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_LATOWN_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_LATOWN_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_LANNTF_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_LANNTF_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_LANNTF_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_LANNTF_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_LACPLN_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_LACPLN_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_LACPLN_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_LACPLN_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_LAPACT_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lx_LAPACT_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
    lp_LAPACT_rulv_rec Okl_Rule_Pub.rulv_rec_type;
    lx_LAPACT_rulv_rec Okl_Rule_Pub.rulv_rec_type;

    lp_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lp_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    lx_pdtv_rec OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
    lx_pdt_param_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

    lp_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lp_klev_rec    okl_kle_pvt.klev_rec_type;
    lx_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    lx_klev_rec    okl_kle_pvt.klev_rec_type;

    --Bug# 4558486
    lp_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;
    lx_kplv_rec      okl_k_party_roles_pvt.kplv_rec_type;

    X_NO_DATA_FOUND BOOLEAN := TRUE;

    old_khr_id  NUMBER;

    CURSOR c_vp_exsts_csr IS
      SELECT khr_id
      FROM okl_k_headers_full_v
      WHERE id = p_durv_rec.chr_id;

    l_fin_ast VARCHAR2(1) := 'N';
    l_lrls_yn VARCHAR2(1) := 'X';

    CURSOR chk_fin_ast_csr IS
    SELECT 'Y'
    FROM okc_k_headers_b CHR
    WHERE EXISTS (SELECT 1
              FROM okc_line_styles_b lse,
	               okc_k_lines_b cle,
	               okl_k_lines kle
              WHERE cle.dnz_chr_id = CHR.id
              AND cle.lse_id = lse.id
              AND cle.id = kle.id
              -- START: cklee/mvasudev,10/14/2005,bug#4300891 - (okl.g Bug#4307723)
              AND cle.sts_code <> 'ABANDONED'
              -- END: cklee/mvasudev,10/14/2005,bug#4300891 - (okl.g Bug#4307723)
              AND lse.lty_code = 'FREE_FORM1')
    AND CHR.id =  p_durv_rec.chr_id;


    CURSOR get_larles_csr IS
    SELECT rul.rule_information1
    FROM okc_rule_groups_b rgp,
         okc_rules_b rul
    WHERE rgp.id = rul.rgp_id
    AND rgp.rgd_code = 'LARLES'
    AND rul.rule_information_category = 'LARLES'
    AND rgp.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.chr_id = p_durv_rec.chr_id
    AND rul.dnz_chr_id = p_durv_rec.chr_id;

    l_fin_ast_id NUMBER  := NULL;
    l_lacpln_yn VARCHAR2(1) := 'X';

    CURSOR get_fin_ast_csr IS
    SELECT cle.id
    FROM okc_line_styles_b lse,
	 okc_k_lines_b cle,
	 okl_k_lines kle
    WHERE cle.dnz_chr_id = p_durv_rec.chr_id
    AND cle.lse_id = lse.id
    AND cle.id = kle.id
    AND lse.lty_code = 'FREE_FORM1';

    CURSOR get_lacpln_csr IS
    SELECT rul.rule_information1
    FROM okc_rules_b rul,
         okc_rule_groups_b rgp
    WHERE rgp.id = rul.rgp_id
    AND rul.rule_information_category = 'LACPLN'
    AND rgp.RGD_CODE = 'LACPLN'
    AND rul.dnz_chr_id = rgp.dnz_chr_id
    AND rgp.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.chr_id = p_durv_rec.chr_id;

    CURSOR is_re_lease_csr IS
    select chr.orig_system_source_code
    from okc_k_headers_b chr
    where chr.id = p_durv_rec.chr_id;

    l_orig_sys_src_code okc_k_headers_b.orig_system_source_code%type := null;

    --Bug# 4619575
    CURSOR l_ptmpl_csr (p_chr_id IN NUMBER) IS
    SELECT chrb.template_yn,
           khr.template_type_code
    FROM   okc_k_headers_b chrb,
           okl_k_headers khr
    WHERE   chrb.id = khr.id
    AND chrb.id = p_chr_id;

    CURSOR l_pqcl_csr IS
    SELECT qcl.id
    FROM  OKC_QA_CHECK_LISTS_TL qcl,
          OKC_QA_CHECK_LISTS_B qclv
    WHERE qclv.Id = qcl.id
    AND UPPER(qcl.name) = 'OKL KT for PA QA Checklist'
    AND qcl.LANGUAGE = 'US';

    CURSOR l_laqcl_csr IS
    SELECT qcl.id
    FROM  OKC_QA_CHECK_LISTS_TL qcl,
          OKC_QA_CHECK_LISTS_B qclv
    WHERE qclv.Id = qcl.id
    AND UPPER(qcl.name) = 'OKL KT FOR LA QA CHECKLIST'
    AND qcl.LANGUAGE = 'US';

    l_template_type_code okl_k_headers.template_type_code%type;
    l_ptemplate_yn okc_k_headers_b.template_yn%type;

    /*
    -- mvasudev, 08/18/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
    	p_chr_id IN NUMBER
	   ,x_return_status OUT NOCOPY VARCHAR2
    )
	IS
	  l_check VARCHAR2(1);
      l_parameter_list           wf_parameter_list_t;
	BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	  -- Raise the event if it is a new Contract
	  l_check := Okl_Lla_Util_Pvt.check_new_contract(p_chr_id);
      IF (l_check= OKL_API.G_TRUE) THEN
  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_UPDATED,
								 p_parameters     => l_parameter_list);

	  END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;

    /*
    -- mvasudev, 08/17/2004
    -- END, PROCEDURE to enable Business Event
    */


  BEGIN

  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_durv_rec.chr_id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_orig_sys_src_code := null;
    Open is_re_lease_csr;
    Fetch is_re_lease_csr into l_orig_sys_src_code;
    Close is_re_lease_csr;

    If(l_orig_sys_src_code is not null and l_orig_sys_src_code = 'OKL_RELEASE') Then

    lp_chrv_rec.contract_number :=  p_durv_rec.chr_contract_number;
    lp_chrv_rec.description :=  p_durv_rec.chr_description;
      update_release_contract(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_chr_id	        => p_durv_rec.chr_id,
        p_contract_number       => p_durv_rec.chr_contract_number,
        p_chr_description       => p_durv_rec.chr_description,
        p_cust_id	        => p_durv_rec.cust_id,
        p_customer_name         => p_durv_rec.cust_name,
        p_customer_id1          => p_durv_rec.cust_object1_id1,
        p_customer_acc_name     => p_durv_rec.customer_account,
        p_customer_acct_id1     => p_durv_rec.chr_cust_acct_id,
        p_product_name          => p_durv_rec.product_name,
        p_mla_id                => p_durv_rec.mla_gvr_chr_id_referred,
        p_mla_no                => p_durv_rec.mla_contract_number,
        p_gvr_id_mla            => p_durv_rec.mla_gvr_id,
        p_cl_id                 => p_durv_rec.cl_gvr_chr_id_referred,
        p_cl_no                 => p_durv_rec.cl_contract_number,
        p_gvr_id_cl             => p_durv_rec.cl_gvr_id,
        p_deal_type             => p_durv_rec.khr_deal_type,
   	p_program_no            => p_durv_rec.program_contract_number,
   	p_program_id            => p_durv_rec.khr_khr_id,
   	p_program_yn            => p_durv_rec.khr_generate_accrual_yn
        );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    Else

    -- not a release contract, continue with the process

      x_durv_rec.cust_object1_id1         :=  p_durv_rec.cust_object1_id1;
      x_durv_rec.cust_object1_id2         :=  p_durv_rec.cust_object1_id2 ;
      x_durv_rec.cust_jtot_object1_code   :=  p_durv_rec.cust_jtot_object1_code ;
      x_durv_rec.chr_cust_acct_id         :=  p_durv_rec.chr_cust_acct_id;
      x_durv_rec.contact_object1_id1      :=  p_durv_rec.contact_object1_id1;
      x_durv_rec.contact_object1_id2      :=  p_durv_rec.contact_object1_id2;
      x_durv_rec.contact_jtot_object1_code:=  p_durv_rec.contact_jtot_object1_code;
      x_durv_rec.mla_gvr_chr_id_referred  :=  p_durv_rec.mla_gvr_chr_id_referred;
      x_durv_rec.khr_khr_id               :=  p_durv_rec.khr_khr_id;
      x_durv_rec.chr_currency_code        :=  p_durv_rec.chr_currency_code;
      x_durv_rec.cl_gvr_chr_id_referred   :=  p_durv_rec.cl_gvr_chr_id_referred;
      x_durv_rec.khr_pdt_id               :=  p_durv_rec.khr_pdt_id;
      x_durv_rec.product_description      :=  p_durv_rec.product_description;
      x_durv_rec.product_description      :=  p_durv_rec.chr_template_yn;

      okl_la_validation_util_pvt.validate_deal(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_chr_id	        => p_durv_rec.chr_id,
   	p_scs_code		=> 'LEASE',
   	p_contract_number	=> p_durv_rec.chr_contract_number ,
   	p_customer_id1          => x_durv_rec.cust_object1_id1,
   	p_customer_id2          => x_durv_rec.cust_object1_id2,
   	p_customer_code         => x_durv_rec.cust_jtot_object1_code,
   	p_customer_name         => p_durv_rec.cust_name,
   	p_chr_cust_acct_id      => x_durv_rec.chr_cust_acct_id,
   	p_customer_acc_name     => p_durv_rec.customer_account,
        p_product_name          => p_durv_rec.product_name,
   	p_product_id            => x_durv_rec.khr_pdt_id,
   	p_product_desc          => x_durv_rec.product_description,
   	p_contact_id1           => x_durv_rec.contact_object1_id1,
   	p_contact_id2           => x_durv_rec.contact_object1_id2,
   	p_contact_code          => x_durv_rec.contact_jtot_object1_code,
   	p_contact_name          => p_durv_rec.contact_name,
    	p_mla_no                => p_durv_rec.mla_contract_number,
   	p_mla_id                => x_durv_rec.mla_gvr_chr_id_referred,
   	p_program_no            => p_durv_rec.program_contract_number,
   	p_program_id            => x_durv_rec.khr_khr_id,
   	p_credit_line_no        => p_durv_rec.cl_contract_number,
   	p_credit_line_id        => x_durv_rec.cl_gvr_chr_id_referred,
   	p_currency_name         => p_durv_rec.currency_name,
   	p_currency_code         => x_durv_rec.chr_currency_code,
   	p_start_date            => p_durv_rec.chr_start_date,
   	p_deal_type             => p_durv_rec.khr_deal_type
   	);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- product changes
      lp_pdtv_rec.id := x_durv_rec.khr_pdt_id;
      OKL_SETUPPRODUCTS_PUB.Getpdt_parameters(
           p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
      	   x_no_data_found => x_no_data_found,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
      	   p_pdtv_rec      => lp_pdtv_rec,
      	   p_product_date  => NULL,
      	   p_pdt_parameter_rec => lx_pdt_param_rec);


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    x_durv_rec.khr_deal_type := lx_pdt_param_rec.Deal_Type;
    x_durv_rec.r_latown_rule_information1 := lx_pdt_param_rec.tax_owner;

    -- validation for creditline contract
     okl_la_validation_util_pvt.validate_creditline(
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_chr_id         => p_durv_rec.chr_id,
       p_deal_type      => x_durv_rec.khr_deal_type,
       p_mla_no         => p_durv_rec.mla_contract_number,
       p_cl_no          => p_durv_rec.cl_contract_number
       );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- update contract header
    lp_chrv_rec.id := p_durv_rec.chr_id;
    lp_khrv_rec.id := p_durv_rec.chr_id;
    lp_chrv_rec.contract_number :=  p_durv_rec.chr_contract_number;
    lp_chrv_rec.description :=  p_durv_rec.chr_description;
    lp_chrv_rec.short_description :=  p_durv_rec.chr_description;
    lp_chrv_rec.sts_code :=  p_durv_rec.chr_sts_code;
    lp_chrv_rec.start_date :=  p_durv_rec.chr_start_date;
    lp_chrv_rec.end_date :=  p_durv_rec.chr_end_date;
    lp_khrv_rec.term_duration :=  p_durv_rec.khr_term_duration;
    lp_chrv_rec.CUST_PO_NUMBER :=  p_durv_rec.chr_CUST_PO_NUMBER;
    lp_chrv_rec.INV_ORGANIZATION_ID :=  p_durv_rec.chr_INV_ORGANIZATION_ID;
    lp_chrv_rec.AUTHORING_ORG_ID :=  p_durv_rec.chr_AUTHORING_ORG_ID;
    lp_khrv_rec.GENERATE_ACCRUAL_YN :=  p_durv_rec.khr_GENERATE_ACCRUAL_YN;
    lp_khrv_rec.SYNDICATABLE_YN :=  p_durv_rec.khr_SYNDICATABLE_YN;
    lp_khrv_rec.PREFUNDING_ELIGIBLE_YN :=  p_durv_rec.khr_PREFUNDING_ELIGIBLE_YN;
    lp_khrv_rec.REVOLVING_CREDIT_YN :=  p_durv_rec.khr_REVOLVING_CREDIT_YN;
    lp_khrv_rec.CONVERTED_ACCOUNT_YN :=  p_durv_rec.khr_CONVERTED_ACCOUNT_YN;
    lp_khrv_rec.CREDIT_ACT_YN :=  p_durv_rec.khr_CREDIT_ACT_YN;
    lp_chrv_rec.TEMPLATE_YN :=  p_durv_rec.chr_TEMPLATE_YN;
    lp_chrv_rec.DATE_SIGNED :=  p_durv_rec.chr_DATE_SIGNED;
    lp_khrv_rec.DATE_DEAL_TRANSFERRED :=  p_durv_rec.khr_DATE_DEAL_TRANSFERRED;
    lp_khrv_rec.ACCEPTED_DATE :=  p_durv_rec.khr_ACCEPTED_DATE;
    lp_khrv_rec.EXPECTED_DELIVERY_DATE :=  p_durv_rec.khr_EXPECTED_DELIVERY_DATE;
    lp_khrv_rec.AMD_CODE :=  p_durv_rec.khr_AMD_CODE;
--    lp_khrv_rec.DEAL_TYPE :=  p_durv_rec.khr_DEAL_TYPE;
    lp_khrv_rec.DEAL_TYPE :=  lx_pdt_param_rec.Deal_Type;
    lp_chrv_rec.currency_code :=  x_durv_rec.chr_currency_code;
    lp_khrv_rec.currency_conversion_type :=  p_durv_rec.khr_currency_conv_type;
    lp_khrv_rec.currency_conversion_rate :=  p_durv_rec.khr_currency_conv_rate;
    lp_khrv_rec.currency_conversion_date :=  p_durv_rec.khr_currency_conv_date;
    lp_khrv_rec.assignable_yn :=  p_durv_rec.khr_assignable_yn;
    lp_chrv_rec.cust_acct_id := x_durv_rec.chr_cust_acct_id;
   --Added by dpsingh for LE Uptake
    lp_khrv_rec.legal_entity_id :=p_durv_rec.legal_entity_id;
    IF (p_durv_rec.khr_assignable_yn <> 'Y') THEN
     lp_khrv_rec.assignable_yn := 'N';
    END IF;

    l_template_yn := 'N';
    l_template_type_code := 'XXX';
    OPEN l_ptmpl_csr(p_chr_id => l_chr_id);
    FETCH l_ptmpl_csr INTO l_template_yn, l_template_type_code;
    CLOSE l_ptmpl_csr;

    --Bug# 4619575
    IF(l_ptemplate_yn = 'Y' AND l_template_type_code = 'PROGRAM') THEN
     OPEN  l_pqcl_csr;
     FETCH l_pqcl_csr INTO lp_chrv_rec.qcl_id;
     CLOSE l_pqcl_csr;
    --Bug# 4619575
    ELSIF(l_ptemplate_yn = 'Y' AND l_template_type_code = 'LEASEAPP') THEN
     OPEN  l_laqcl_csr;
     FETCH l_laqcl_csr INTO lp_chrv_rec.qcl_id;
     CLOSE l_laqcl_csr;
    ELSE
     OPEN  l_qcl_csr;
     FETCH l_qcl_csr INTO lp_chrv_rec.qcl_id;
     CLOSE l_qcl_csr;
    END IF;

    -- START: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938
   /*
    OPEN  l_end_date_csr;
    FETCH l_end_date_csr INTO lp_chrv_rec.end_date;
    CLOSE l_end_date_csr;
   */
	lp_chrv_rec.end_date := OKL_LLA_UTIL_PVT.calculate_end_date(p_durv_rec.chr_start_date,p_durv_rec.khr_term_duration);
    -- END: cklee/mvasudev,6/2/2005, Bug#4392051/okl.h 4437938

    x_durv_rec.chr_end_date := lp_chrv_rec.end_date;

   /*
    If (lp_chrv_rec.TEMPLATE_YN is not null and lp_chrv_rec.TEMPLATE_YN = 'Y') then
      lp_chrv_rec.end_date := null;
      x_durv_rec.chr_end_date := null;
    End If;
   */

    IF (p_durv_rec.product_name IS NULL) THEN
     lp_khrv_rec.pdt_id :=  NULL;
     x_durv_rec.khr_pdt_id := NULL;
    ELSE
     lp_khrv_rec.pdt_id :=  x_durv_rec.khr_pdt_id;
    END IF;

    IF (p_durv_rec.program_contract_number IS NULL) THEN
     lp_khrv_rec.khr_id :=  NULL;
     x_durv_rec.khr_khr_id := NULL;
    END IF;

     old_khr_id := NULL;
     OPEN c_vp_exsts_csr;
     FETCH c_vp_exsts_csr INTO old_khr_id;
     CLOSE c_vp_exsts_csr;

     lp_khrv_rec.khr_id :=  x_durv_rec.khr_khr_id;

   IF( p_durv_rec.cust_id IS NOT NULL AND p_durv_rec.cust_name IS NULL AND l_temp_yn IS NOT NULL AND l_temp_yn = 'Y' ) THEN
    lp_chrv_rec.cust_acct_id := NULL;
   END IF;

    OKL_CONTRACT_PUB.update_contract_header(
        p_api_version    	=> p_api_version,
        p_init_msg_list  	=> p_init_msg_list,
        x_return_status  	=> x_return_status,
        x_msg_count      	=> x_msg_count,
        x_msg_data       	=> x_msg_data,
        p_restricted_update     => 'F',
        p_chrv_rec       	=> lp_chrv_rec,
        p_khrv_rec       	=> lp_khrv_rec,
        x_chrv_rec       	=> lx_chrv_rec,
        x_khrv_rec       	=> lx_khrv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   /*
    open  l_vers_version_csr;
    fetch l_vers_version_csr into x_durv_rec.vers_version;
    close l_vers_version_csr;
   */
-- lessee

    IF (p_durv_rec.cust_id IS NULL AND p_durv_rec.cust_name IS NOT NULL ) THEN

    lp_lessee_cplv_rec.id := NULL;
    lp_lessee_cplv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_lessee_cplv_rec.chr_id := p_durv_rec.chr_id;
    lp_lessee_cplv_rec.object1_id1 := x_durv_rec.cust_object1_id1;
    lp_lessee_cplv_rec.object1_id2 := x_durv_rec.cust_object1_id2;
    lp_lessee_cplv_rec.rle_code := 'LESSEE';
    lp_lessee_cplv_rec.jtot_object1_code := p_durv_rec.cust_jtot_object1_code;


    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to create records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    OKL_OKC_MIGRATION_PVT.create_k_party_role(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_cplv_rec       => lp_lessee_cplv_rec,
        x_cplv_rec       => lx_lessee_cplv_rec);
    */

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_lessee_cplv_rec,
      x_cplv_rec         => lx_lessee_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.cust_id := lx_lessee_cplv_rec.id;

   ELSIF (p_durv_rec.cust_id IS NOT NULL AND p_durv_rec.cust_name IS NOT NULL ) THEN

    lp_lessee_cplv_rec.id := p_durv_rec.cust_id;
    lp_lessee_cplv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_lessee_cplv_rec.chr_id := p_durv_rec.chr_id;
    lp_lessee_cplv_rec.object1_id1 := x_durv_rec.cust_object1_id1;
    lp_lessee_cplv_rec.object1_id2 := x_durv_rec.cust_object1_id2;
    lp_lessee_cplv_rec.rle_code := 'LESSEE';
    lp_lessee_cplv_rec.jtot_object1_code := p_durv_rec.cust_jtot_object1_code;

    --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
    --              to update records in tables
    --              okc_k_party_roles_b and okl_k_party_roles
    /*
    OKL_OKC_MIGRATION_PVT.update_k_party_role(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_cplv_rec       => lp_lessee_cplv_rec,
        x_cplv_rec       => lx_lessee_cplv_rec);
    */

    lp_kplv_rec.id := lp_lessee_cplv_rec.id;
    okl_k_party_roles_pvt.update_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_lessee_cplv_rec,
      x_cplv_rec         => lx_lessee_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF( p_durv_rec.cust_id IS NOT NULL AND p_durv_rec.cust_name IS NULL ) THEN

    IF( l_temp_yn = 'Y' ) THEN

	lp_lessee_cplv_rec.id := p_durv_rec.cust_id;
        lp_lessee_cplv_rec.dnz_chr_id := p_durv_rec.chr_id;
        lp_lessee_cplv_rec.chr_id := p_durv_rec.chr_id;

        --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
        --              to delete records in tables
        --              okc_k_party_roles_b and okl_k_party_roles
        /*
        OKL_OKC_MIGRATION_PVT.delete_k_party_role(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_cplv_rec       => lp_lessee_cplv_rec);
        */

        lp_kplv_rec.id := lp_lessee_cplv_rec.id;
        OKL_K_PARTY_ROLES_PVT.delete_k_party_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_cplv_rec      => lp_lessee_cplv_rec,
          p_kplv_rec      => lp_kplv_rec);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

       l_rgp_id := NULL;
       l_rul_id := NULL;

     END IF;

   END IF;

-- contact
   IF (p_durv_rec.contact_id IS NULL AND p_durv_rec.contact_name IS NOT NULL ) THEN

    lp_ctcv_rec.id := NULL;
    lp_ctcv_rec.cpl_id := p_durv_rec.lessor_id;
    lp_ctcv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_ctcv_rec.object1_id1 := x_durv_rec.contact_object1_id1;
    lp_ctcv_rec.object1_id2 := x_durv_rec.contact_object1_id2;
    lp_ctcv_rec.jtot_object1_code := p_durv_rec.contact_jtot_object1_code;
    lp_ctcv_rec.cro_code := 'SALESPERSON';

    OKL_OKC_MIGRATION_PVT.create_contact(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_ctcv_rec       => lp_ctcv_rec,
        x_ctcv_rec       => lx_ctcv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.contact_id := lx_ctcv_rec.id;

   ELSIF (p_durv_rec.contact_id IS NOT NULL AND p_durv_rec.contact_name IS NOT NULL ) THEN

    lp_ctcv_rec.id := p_durv_rec.contact_id;
    lp_ctcv_rec.cpl_id := lx_lessor_cplv_rec.id;
    lp_ctcv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_ctcv_rec.object1_id1 := x_durv_rec.contact_object1_id1;
    lp_ctcv_rec.object1_id2 := x_durv_rec.contact_object1_id2;
    lp_ctcv_rec.jtot_object1_code := p_durv_rec.contact_jtot_object1_code;
    lp_ctcv_rec.cro_code := 'SALESPERSON';

    OKL_OKC_MIGRATION_PVT.update_contact(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_ctcv_rec       => lp_ctcv_rec,
        x_ctcv_rec       => lx_ctcv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_durv_rec.contact_id IS NOT NULL AND p_durv_rec.contact_name IS NULL ) THEN

    lp_ctcv_rec.id := p_durv_rec.contact_id;
    lp_ctcv_rec.cpl_id := lx_lessor_cplv_rec.id;
    lp_ctcv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_ctcv_rec.object1_id1 := x_durv_rec.contact_object1_id1;
    lp_ctcv_rec.object1_id2 := x_durv_rec.contact_object1_id2;
    lp_ctcv_rec.jtot_object1_code := p_durv_rec.contact_jtot_object1_code;
    lp_ctcv_rec.cro_code := 'SALESPERSON';

    OKL_OKC_MIGRATION_PVT.delete_contact(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_ctcv_rec       => lp_ctcv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

     x_durv_rec.contact_id := NULL;

   END IF;

-- mla
   IF (p_durv_rec.mla_gvr_id IS NULL AND p_durv_rec.mla_contract_number IS NOT NULL ) THEN

    lp_mla_gvev_rec.id := NULL;
    lp_mla_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id_referred := x_durv_rec.mla_gvr_chr_id_referred;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.create_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec,
        x_gvev_rec       => lx_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.mla_gvr_id := lx_mla_gvev_rec.id;

   ELSIF (p_durv_rec.mla_gvr_id IS NOT NULL AND p_durv_rec.mla_contract_number IS NOT NULL ) THEN

    lp_mla_gvev_rec.id := p_durv_rec.mla_gvr_id;
    lp_mla_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id_referred := x_durv_rec.mla_gvr_chr_id_referred;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.update_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec,
        x_gvev_rec       => lx_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_durv_rec.mla_gvr_id IS NOT NULL AND p_durv_rec.mla_contract_number IS NULL ) THEN

    lp_mla_gvev_rec.id := p_durv_rec.mla_gvr_id;
    lp_mla_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_mla_gvev_rec.chr_id_referred := x_durv_rec.mla_gvr_chr_id_referred;
    lp_mla_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.delete_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_mla_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.mla_gvr_id := NULL;

   END IF;

-- creditline
   IF (p_durv_rec.cl_gvr_id IS NULL AND p_durv_rec.cl_contract_number IS NOT NULL ) THEN

    lp_cl_gvev_rec.id := NULL;
    lp_cl_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id_referred := x_durv_rec.cl_gvr_chr_id_referred;
    lp_cl_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.create_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec,
        x_gvev_rec       => lx_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.cl_gvr_id := lx_cl_gvev_rec.id;

   ELSIF (p_durv_rec.cl_gvr_id IS NOT NULL AND p_durv_rec.cl_contract_number IS NOT NULL ) THEN

    lp_cl_gvev_rec.id := p_durv_rec.cl_gvr_id;
    lp_cl_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id_referred := x_durv_rec.cl_gvr_chr_id_referred;
    lp_cl_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.update_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec,
        x_gvev_rec       => lx_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   ELSIF (p_durv_rec.cl_gvr_id IS NOT NULL AND p_durv_rec.cl_contract_number IS NULL ) THEN

    lp_cl_gvev_rec.id := p_durv_rec.cl_gvr_id;
    lp_cl_gvev_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id := p_durv_rec.chr_id;
    lp_cl_gvev_rec.chr_id_referred := x_durv_rec.cl_gvr_chr_id_referred;
    lp_cl_gvev_rec.copied_only_yn := 'N';

    OKL_OKC_MIGRATION_PVT.delete_governance(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gvev_rec       => lp_cl_gvev_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.cl_gvr_id := NULL;

   END IF;

-- rule group larles
   IF (p_durv_rec.rg_larles_id IS NULL) THEN

    lp_larles_rgpv_rec.id := NULL;
    lp_larles_rgpv_rec.rgd_code := 'LARLES';
    lp_larles_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larles_rgpv_rec.chr_id := p_durv_rec.chr_id;
    lp_larles_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larles_rgpv_rec,
        x_rgpv_rec       => lx_larles_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.rg_larles_id := lx_larles_rgpv_rec.id;

   ELSIF (p_durv_rec.rg_larles_id IS NOT NULL ) THEN

    lp_larles_rgpv_rec.id := p_durv_rec.rg_larles_id;
    lp_larles_rgpv_rec.rgd_code := 'LARLES';
    lp_larles_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larles_rgpv_rec.chr_id := p_durv_rec.chr_id;
    lp_larles_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.update_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larles_rgpv_rec,
        x_rgpv_rec       => lx_larles_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

-- rule larles
   IF (p_durv_rec.r_larles_id IS NULL ) THEN

    lp_larles_rulv_rec.id := NULL;
    lp_larles_rulv_rec.rgp_id := lx_larles_rgpv_rec.id;
    lp_larles_rulv_rec.rule_information_category := 'LARLES';
    lp_larles_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larles_rulv_rec.rule_information1 := p_durv_rec.r_larles_rule_information1;
    lp_larles_rulv_rec.WARN_YN := 'N';
    lp_larles_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larles_rulv_rec,
        x_rulv_rec       => lx_larles_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.r_larles_id := lx_larles_rulv_rec.id;

   ELSIF (p_durv_rec.r_larles_id IS NOT NULL ) THEN

    l_fin_ast := 'N';
    OPEN chk_fin_ast_csr;
    FETCH chk_fin_ast_csr INTO l_fin_ast;
    CLOSE chk_fin_ast_csr;

    l_lrls_yn := 'X';
    OPEN get_larles_csr;
    FETCH get_larles_csr INTO l_lrls_yn;
    CLOSE get_larles_csr;

    IF( (l_fin_ast = 'Y') AND (NOT(p_durv_rec.r_larles_rule_information1 = l_lrls_yn))) THEN

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_RELSE_AST'
               );
         RAISE OKC_API.G_EXCEPTION_ERROR;

    END IF;

    lp_larles_rulv_rec.id := p_durv_rec.r_larles_id;
    lp_larles_rulv_rec.rgp_id := lx_larles_rgpv_rec.id;
    lp_larles_rulv_rec.rule_information_category := 'LARLES';
    lp_larles_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larles_rulv_rec.rule_information1 := p_durv_rec.r_larles_rule_information1;
    lp_larles_rulv_rec.WARN_YN := 'N';
    lp_larles_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larles_rulv_rec,
        x_rulv_rec       => lx_larles_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

-- rule group LAREBL
   IF (p_durv_rec.rg_LAREBL_id IS NULL) THEN

    lp_larebl_rgpv_rec.id := NULL;
    lp_larebl_rgpv_rec.rgd_code := 'LAREBL';
    lp_larebl_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larebl_rgpv_rec.chr_id := p_durv_rec.chr_id;
    lp_larebl_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larebl_rgpv_rec,
        x_rgpv_rec       => lx_larebl_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.rg_larebl_id := lx_larebl_rgpv_rec.id;

   ELSIF (p_durv_rec.rg_larebl_id IS NOT NULL ) THEN

    lp_larebl_rgpv_rec.id := p_durv_rec.rg_larebl_id;
    lp_larebl_rgpv_rec.rgd_code := 'LAREBL';
    lp_larebl_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larebl_rgpv_rec.chr_id := p_durv_rec.chr_id;
    lp_larebl_rgpv_rec.rgp_type := 'KRG';

    OKL_RULE_PUB.update_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_larebl_rgpv_rec,
        x_rgpv_rec       => lx_larebl_rgpv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

-- rule larebl
   IF (p_durv_rec.r_larebl_id IS NULL) THEN

    lp_larebl_rulv_rec.id := NULL;
    lp_larebl_rulv_rec.rgp_id := lx_larebl_rgpv_rec.id;
    lp_larebl_rulv_rec.rule_information_category := 'LAREBL';
    lp_larebl_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larebl_rulv_rec.rule_information1 := p_durv_rec.r_larebl_rule_information1;
    lp_larebl_rulv_rec.WARN_YN := 'N';
    lp_larebl_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larebl_rulv_rec,
        x_rulv_rec       => lx_larebl_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_durv_rec.r_larebl_id := lx_larebl_rulv_rec.id;

   ELSIF (p_durv_rec.r_larebl_id IS NOT NULL ) THEN

    lp_larebl_rulv_rec.id := p_durv_rec.r_larebl_id;
    lp_larebl_rulv_rec.rgp_id := lx_larebl_rgpv_rec.id;
    lp_larebl_rulv_rec.rule_information_category := 'LAREBL';
    lp_larebl_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larebl_rulv_rec.rule_information1 := p_durv_rec.r_larebl_rule_information1;
    lp_larebl_rulv_rec.WARN_YN := 'N';
    lp_larebl_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.update_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larebl_rulv_rec,
        x_rulv_rec       => lx_larebl_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   ELSIF (p_durv_rec.r_larebl_id IS NOT NULL AND p_durv_rec.r_larebl_rule_information1 IS NULL) THEN

    lp_larebl_rulv_rec.id := p_durv_rec.r_larebl_id;
    lp_larebl_rulv_rec.rgp_id := lx_larebl_rgpv_rec.id;
    lp_larebl_rulv_rec.rule_information_category := 'LAREBL';
    lp_larebl_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
    lp_larebl_rulv_rec.rule_information1 := p_durv_rec.r_larebl_rule_information1;
    lp_larebl_rulv_rec.WARN_YN := 'N';
    lp_larebl_rulv_rec.STD_TEMPLATE_YN := 'N';

    OKL_RULE_PUB.delete_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_larebl_rulv_rec);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    x_durv_rec.r_larebl_id := NULL;

   END IF;

 -- rule group lanntf
    IF (p_durv_rec.rg_lanntf_id IS NULL) THEN

     lp_lanntf_rgpv_rec.id := NULL;
     lp_lanntf_rgpv_rec.rgd_code := 'LANNTF';
     lp_lanntf_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lanntf_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lanntf_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.create_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lanntf_rgpv_rec,
         x_rgpv_rec       => lx_lanntf_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

        x_durv_rec.rg_lanntf_id := lx_lanntf_rgpv_rec.id;

    ELSIF (p_durv_rec.rg_lanntf_id IS NOT NULL ) THEN

     lp_lanntf_rgpv_rec.id := p_durv_rec.rg_lanntf_id;
     lp_lanntf_rgpv_rec.rgd_code := 'LANNTF';
     lp_lanntf_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lanntf_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lanntf_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.update_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lanntf_rgpv_rec,
         x_rgpv_rec       => lx_lanntf_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

 -- rule lanntf
    IF (p_durv_rec.r_lanntf_id IS NULL) THEN

     lp_lanntf_rulv_rec.id := NULL;
     lp_lanntf_rulv_rec.rgp_id := lx_lanntf_rgpv_rec.id;
     lp_lanntf_rulv_rec.rule_information_category := 'LANNTF';
     lp_lanntf_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lanntf_rulv_rec.rule_information1 := p_durv_rec.r_lanntf_rule_information1;
     lp_lanntf_rulv_rec.WARN_YN := 'N';
     lp_lanntf_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.create_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lanntf_rulv_rec,
         x_rulv_rec       => lx_lanntf_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       x_durv_rec.r_lanntf_id := lx_lanntf_rulv_rec.id;

    ELSIF (p_durv_rec.r_lanntf_id IS NOT NULL ) THEN

     lp_lanntf_rulv_rec.id := p_durv_rec.r_lanntf_id;
     lp_lanntf_rulv_rec.rgp_id := lx_lanntf_rgpv_rec.id;
     lp_lanntf_rulv_rec.rule_information_category := 'LANNTF';
     lp_lanntf_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lanntf_rulv_rec.rule_information1 := p_durv_rec.r_lanntf_rule_information1;
     lp_lanntf_rulv_rec.WARN_YN := 'N';
     lp_lanntf_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.update_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lanntf_rulv_rec,
         x_rulv_rec       => lx_lanntf_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

  -- rule group lacpln
    IF (p_durv_rec.rg_lacpln_id IS NULL) THEN

     lp_lacpln_rgpv_rec.id := NULL;
     lp_lacpln_rgpv_rec.rgd_code := 'LACPLN';
     lp_lacpln_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lacpln_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lacpln_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.create_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lacpln_rgpv_rec,
         x_rgpv_rec       => lx_lacpln_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       x_durv_rec.rg_lacpln_id := lx_lacpln_rgpv_rec.id;

    ELSIF (p_durv_rec.rg_lacpln_id IS NOT NULL ) THEN

     lp_lacpln_rgpv_rec.id := p_durv_rec.rg_lacpln_id;
     lp_lacpln_rgpv_rec.rgd_code := 'LACPLN';
     lp_lacpln_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lacpln_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lacpln_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.update_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lacpln_rgpv_rec,
         x_rgpv_rec       => lx_lacpln_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

 -- rule lacpln
    IF (p_durv_rec.r_lacpln_id IS NULL) THEN

     lp_lacpln_rulv_rec.id := NULL;
     lp_lacpln_rulv_rec.rgp_id := lx_lacpln_rgpv_rec.id;
     lp_lacpln_rulv_rec.rule_information_category := 'LACPLN';
     lp_lacpln_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lacpln_rulv_rec.rule_information1 := p_durv_rec.r_lacpln_rule_information1;
     lp_lacpln_rulv_rec.WARN_YN := 'N';
     lp_lacpln_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.create_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lacpln_rulv_rec,
         x_rulv_rec       => lx_lacpln_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       x_durv_rec.r_lacpln_id := lx_lacpln_rulv_rec.id;

    ELSIF (p_durv_rec.r_lacpln_id IS NOT NULL ) THEN

    l_lacpln_yn := 'X';

    OPEN get_lacpln_csr;
    FETCH get_lacpln_csr INTO l_lacpln_yn;
    CLOSE get_lacpln_csr;

    IF( l_lacpln_yn = 'Y' AND  NVL(p_durv_rec.r_lacpln_rule_information1,'N') = 'N') THEN

	l_fin_ast_id := NULL;
        -- update capitalized interest to null
	FOR l_get_fin_ast_csr IN get_fin_ast_csr LOOP

	  -- l_fin_ast_id := l_get_fin_ast_csr.id;
	  lp_klev_rec.id := l_get_fin_ast_csr.id;
	  lp_clev_rec.id := l_get_fin_ast_csr.id;
          lp_klev_rec.capitalized_interest := NULL;

          OKL_CONTRACT_PUB.update_contract_line(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
	    p_clev_rec       => lp_clev_rec,
	    p_klev_rec       => lp_klev_rec,
	    p_edit_mode      => 'N',
	    x_clev_rec       => lx_clev_rec,
	    x_klev_rec       => lx_klev_rec);

          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

 	END LOOP;

     END IF;

     lp_lacpln_rulv_rec.id := p_durv_rec.r_lacpln_id;
     lp_lacpln_rulv_rec.rgp_id := lx_lacpln_rgpv_rec.id;
     lp_lacpln_rulv_rec.rule_information_category := 'LACPLN';
     lp_lacpln_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lacpln_rulv_rec.rule_information1 := p_durv_rec.r_lacpln_rule_information1;
     lp_lacpln_rulv_rec.WARN_YN := 'N';
     lp_lacpln_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.update_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lacpln_rulv_rec,
         x_rulv_rec       => lx_lacpln_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;


 -- rule group lapact
    IF (p_durv_rec.rg_lapact_id IS NULL) THEN

     lp_lapact_rgpv_rec.id := NULL;
     lp_lapact_rgpv_rec.rgd_code := 'LAPACT';
     lp_lapact_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lapact_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lapact_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.create_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lapact_rgpv_rec,
         x_rgpv_rec       => lx_lapact_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       x_durv_rec.rg_lapact_id := lx_lapact_rgpv_rec.id;

    ELSIF (p_durv_rec.rg_lapact_id IS NOT NULL ) THEN

     lp_lapact_rgpv_rec.id := p_durv_rec.rg_lapact_id;
     lp_lapact_rgpv_rec.rgd_code := 'LAPACT';
     lp_lapact_rgpv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lapact_rgpv_rec.chr_id := p_durv_rec.chr_id;
     lp_lapact_rgpv_rec.rgp_type := 'KRG';

     OKL_RULE_PUB.update_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_lapact_rgpv_rec,
         x_rgpv_rec       => lx_lapact_rgpv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

 -- rule lapact
    IF (p_durv_rec.r_lapact_id IS NULL) THEN

     lp_lapact_rulv_rec.id := NULL;
     lp_lapact_rulv_rec.rgp_id := lx_lapact_rgpv_rec.id;
     lp_lapact_rulv_rec.rule_information_category := 'LAPACT';
     lp_lapact_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lapact_rulv_rec.rule_information1 := p_durv_rec.r_lapact_rule_information1;
     lp_lapact_rulv_rec.WARN_YN := 'N';
     lp_lapact_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.create_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lapact_rulv_rec,
         x_rulv_rec       => lx_lapact_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       x_durv_rec.r_lapact_id := lx_lapact_rulv_rec.id;

    ELSIF (p_durv_rec.r_lapact_id IS NOT NULL ) THEN

     lp_lapact_rulv_rec.id := p_durv_rec.r_lapact_id;
     lp_lapact_rulv_rec.rgp_id := lx_lapact_rgpv_rec.id;
     lp_lapact_rulv_rec.rule_information_category := 'LAPACT';
     lp_lapact_rulv_rec.dnz_chr_id := p_durv_rec.chr_id;
     lp_lapact_rulv_rec.rule_information1 := p_durv_rec.r_lapact_rule_information1;
     lp_lapact_rulv_rec.WARN_YN := 'N';
     lp_lapact_rulv_rec.STD_TEMPLATE_YN := 'N';

     OKL_RULE_PUB.update_rule(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rulv_rec       => lp_lapact_rulv_rec,
         x_rulv_rec       => lx_lapact_rulv_rec);

       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;

  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_durv_rec.chr_id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

  IF (p_durv_rec.program_contract_number IS NOT NULL OR old_khr_id IS NOT NULL) THEN

       copy_rules(
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_old_khr_id        => old_khr_id,
        p_prog_override_yn  => p_durv_rec.khr_generate_accrual_yn, -- program flag yn
        p_source_id         => x_durv_rec.khr_khr_id, -- program id
        p_dest_id           => p_durv_rec.chr_id,
        p_org_id            => okl_context.get_okc_org_id,
        p_organization_id   => okl_context.get_okc_organization_id
        );

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

   END IF;

 End if; --close of release if block
   /*
   -- mvasudev, 08/17/2004
   -- Code change to enable Business Event
   */
	raise_business_event(p_chr_id        => p_durv_rec.chr_id
	                    ,x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /*
   -- mvasudev, 08/17/2004
   -- END, Code change to enable Business Event
   */


  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;

PROCEDURE load_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_rec                     IN  deal_rec_type,
      x_durv_rec                     OUT NOCOPY  deal_rec_type
    ) AS

    l_api_name	       VARCHAR2(30) := 'load_deal';
    l_api_version      CONSTANT NUMBER	  := 1.0;

    l_template_yn      OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type         OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number  OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code      VARCHAR2(30) DEFAULT NULL;

    l_ak_prompt        AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
    l_chr_id	       NUMBER;
    row_cnt  NUMBER;

    CURSOR l_load_hdr_csr IS
    SELECT id,
        contract_number,
        description,
        sts_code,
        start_date,
        end_date,
        term_duration,
        cust_po_number,
        inv_organization_id,
        authoring_org_id,
        generate_accrual_yn,
        syndicatable_yn,
        prefunding_eligible_yn,
        revolving_credit_yn,
        converted_account_yn,
        credit_act_yn,
        template_yn,
        date_signed,
        date_deal_transferred,
        accepted_date,
        expected_delivery_date,
        amd_code,
        deal_type,
--        orig_system_reference1,
--        orig_system_source_code,
--        orig_system_id1,
        currency_code,
        pdt_id,
        khr_id
    FROM okl_k_headers_full_v
    WHERE id = p_durv_rec.chr_id;


    CURSOR l_vers_version_csr IS
    SELECT vers.major_version||'.'||vers.minor_version
    FROM okc_k_vers_numbers_v vers
    WHERE vers.chr_id = p_durv_rec.chr_id;

    CURSOR l_gvr_csr(p_scs_code VARCHAR2) IS
    SELECT mla.contract_number, gvr.chr_id_referred, gvr.id
    FROM  okl_k_headers_full_v mla, okc_governances_v gvr
    WHERE mla.id = gvr.chr_id_referred
    AND mla.scs_code = p_scs_code -- mla or cl
    AND gvr.chr_id = p_durv_rec.chr_id
    AND gvr.dnz_chr_id = p_durv_rec.chr_id;

    CURSOR l_dff_rule_csr(p_rgd_code VARCHAR2, p_rule_information_category VARCHAR2) IS
    SELECT rgp.id, rul.id, rul.rule_information1
    FROM  okc_rule_groups_v rgp, okc_rules_v rul
    WHERE rgp.id = rul.rgp_id
    AND rgp.rgd_code = p_rgd_code
    AND rul.rule_information_category = p_rule_information_category
    AND rul.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.chr_id = p_durv_rec.chr_id;

    CURSOR l_party_csr(p_rle_code VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20563248
	SELECT cpl.id,cpl.object1_id1,cpl.object1_id2,cpl.jtot_object1_code
	    FROM okc_k_party_roles_B cpl
	    WHERE cpl.rle_code = p_rle_code
	    AND cpl.chr_id = p_durv_rec.chr_id
	    AND cpl.dnz_chr_id = p_durv_rec.chr_id
	--end modified abhsaxen for performance SQLID 20563248
	;
    CURSOR l_customer_account_csr IS
    SELECT rgp.id, rul.id, rul.object1_id1,rul.object1_id2,rul.jtot_object1_code
    FROM  okc_rule_groups_v rgp, okc_rules_v rul
    WHERE rgp.id = rul.rgp_id
    AND rgp.rgd_code = 'LACAN'
    AND rul.rule_information_category = 'CAN'
    AND rul.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.dnz_chr_id = p_durv_rec.chr_id
    AND rgp.chr_id = p_durv_rec.chr_id;

    CURSOR l_legal_address_csr(p_cust_id1 VARCHAR2) IS
    SELECT cust_site.description
    FROM okx_cust_site_uses_v cust_site
    WHERE cust_site.party_id = p_cust_id1
    AND cust_site.site_use_code = 'LEGAL';

    CURSOR l_product_csr(product_id  NUMBER) IS
    SELECT id,name,description
    FROM okl_products_v
    WHERE id = product_id;

    CURSOR l_currency_csr(p_currency_code  VARCHAR2) IS
    SELECT currency_code, name
    FROM fnd_currencies_vl
    WHERE currency_code = p_currency_code;

    CURSOR l_program_csr(program_id  NUMBER) IS
    SELECT id,contract_number
    FROM okl_k_headers_full_v
    WHERE id = program_id;

    CURSOR l_contact_csr IS
	--Start modified abhsaxen for performance SQLID 20563327
	select ctc.id,ctc.object1_id1,ctc.object1_id2,ctc.jtot_object1_code
	    from okc_k_party_roles_b cpl, okc_contacts ctc
	    where cpl.id = ctc.cpl_id
	    and cpl.rle_code = 'LESSOR'
	    and ctc.cro_code = 'SALESPERSON'
	    and cpl.chr_id = p_durv_rec.chr_id
	    and cpl.dnz_chr_id = p_durv_rec.chr_id
	    and ctc.dnz_chr_id = p_durv_rec.chr_id
	--end modified abhsaxen for performance SQLID 20563327
	;

    CURSOR l_sts_code_csr IS
    SELECT CHR.sts_code
    FROM OKC_STATUSES_B sts,okc_k_headers_v CHR
    WHERE STS.CODE = CHR.STS_CODE
    AND CHR.id = p_durv_rec.chr_id;


  BEGIN

  IF okl_context.get_okc_org_id  IS NULL THEN
	l_chr_id := p_durv_rec.chr_id;
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  END IF;

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    open l_load_hdr_csr;
    fetch l_load_hdr_csr into   x_durv_rec.chr_id,
 		   	        x_durv_rec.chr_contract_number,
    				x_durv_rec.chr_description,
    				x_durv_rec.chr_sts_code,
    				x_durv_rec.chr_start_date,
    				x_durv_rec.chr_end_date,
    				x_durv_rec.khr_term_duration,
    				x_durv_rec.chr_cust_po_number,
    				x_durv_rec.chr_inv_organization_id,
    				x_durv_rec.chr_authoring_org_id,
    				x_durv_rec.khr_generate_accrual_yn,
    				x_durv_rec.khr_syndicatable_yn,
    				x_durv_rec.khr_prefunding_eligible_yn,
    				x_durv_rec.khr_revolving_credit_yn,
    				x_durv_rec.khr_converted_account_yn,
    				x_durv_rec.khr_credit_act_yn,
    				x_durv_rec.chr_template_yn,
    				x_durv_rec.chr_date_signed,
    				x_durv_rec.khr_date_deal_transferred,
    				x_durv_rec.khr_accepted_date,
    				x_durv_rec.khr_expected_delivery_date,
    				x_durv_rec.khr_amd_code,
    				x_durv_rec.khr_deal_type,
--    				x_durv_rec.chr_orig_system_reference1,
--    				x_durv_rec.chr_orig_system_source_code,
--    				x_durv_rec.chr_orig_system_id1,
    				x_durv_rec.chr_currency_code,
    				x_durv_rec.khr_pdt_id,
    				x_durv_rec.khr_khr_id;
    close  l_load_hdr_csr;

    open l_vers_version_csr;
    fetch l_vers_version_csr into x_durv_rec.vers_version;
    close l_vers_version_csr;

    open l_gvr_csr('MASTER_LEASE');
    fetch l_gvr_csr into x_durv_rec.mla_contract_number, x_durv_rec.mla_gvr_chr_id_referred, x_durv_rec.mla_gvr_id;
    close l_gvr_csr;

    open l_gvr_csr('CREDITLINE_CONTRACT');
    fetch l_gvr_csr into x_durv_rec.cl_contract_number, x_durv_rec.cl_gvr_chr_id_referred, x_durv_rec.cl_gvr_id;
    close l_gvr_csr;

    open l_dff_rule_csr('LARLES','LARLES');
    fetch l_dff_rule_csr into x_durv_rec.rg_larles_id,x_durv_rec.r_larles_id,x_durv_rec.r_larles_rule_information1;
    close l_dff_rule_csr;

    open l_dff_rule_csr('LANNTF','LANNTF');
    fetch l_dff_rule_csr into x_durv_rec.rg_lanntf_id,x_durv_rec.r_lanntf_id,x_durv_rec.r_lanntf_rule_information1;
    close l_dff_rule_csr;

    open l_dff_rule_csr('LATOWN','LATOWN');
    fetch l_dff_rule_csr into x_durv_rec.rg_latown_id,x_durv_rec.r_latown_id,x_durv_rec.r_latown_rule_information1;
    close l_dff_rule_csr;

    open l_dff_rule_csr('LAPACT','LAPACT');
    fetch l_dff_rule_csr into x_durv_rec.rg_lapact_id,x_durv_rec.r_lapact_id,x_durv_rec.r_lapact_rule_information1;
    close l_dff_rule_csr;

    open l_dff_rule_csr('LAREBL','LAREBL');
    fetch l_dff_rule_csr into x_durv_rec.rg_larebl_id,x_durv_rec.r_larebl_id,x_durv_rec.r_larebl_rule_information1;
    close l_dff_rule_csr;

    open l_dff_rule_csr('LACPLN','LACPLN');
    fetch l_dff_rule_csr into x_durv_rec.rg_lacpln_id,x_durv_rec.r_lacpln_id,x_durv_rec.r_lacpln_rule_information1;
    close l_dff_rule_csr;

    open l_party_csr('LESSEE');
    fetch l_party_csr into x_durv_rec.cust_id,x_durv_rec.cust_object1_id1,x_durv_rec.cust_object1_id2,x_durv_rec.cust_jtot_object1_code;
    close l_party_csr;

    open l_party_csr('LESSOR');
    fetch l_party_csr into x_durv_rec.lessor_id,x_durv_rec.lessor_object1_id1,x_durv_rec.lessor_object1_id2,x_durv_rec.lessor_jtot_object1_code;
    close l_party_csr;

    open l_customer_account_csr;
    fetch l_customer_account_csr into x_durv_rec.rg_lacan_id,x_durv_rec.r_can_id,x_durv_rec.r_can_object1_id1,x_durv_rec.r_can_object1_id2,x_durv_rec.r_can_jtot_object1_code;
    close l_customer_account_csr;

    open l_legal_address_csr(x_durv_rec.cust_object1_id1);
    fetch l_legal_address_csr into x_durv_rec.cust_site_description;
    close l_legal_address_csr;

    open l_product_csr(x_durv_rec.khr_pdt_id);
    fetch l_product_csr into x_durv_rec.khr_pdt_id,x_durv_rec.product_name,x_durv_rec.product_description;
    close l_product_csr;

    open l_currency_csr(x_durv_rec.chr_currency_code);
    fetch l_currency_csr into x_durv_rec.chr_currency_code, x_durv_rec.currency_name;
    close l_currency_csr;

    open l_program_csr(x_durv_rec.khr_khr_id);
    fetch l_program_csr into x_durv_rec.khr_khr_id,x_durv_rec.program_contract_number;
    close l_program_csr;

    open l_contact_csr;
    fetch l_contact_csr into x_durv_rec.contact_id,x_durv_rec.contact_object1_id1,x_durv_rec.contact_object1_id2,x_durv_rec.contact_jtot_object1_code;
    close l_contact_csr;
*/
/*
    open l_set_of_books_csr;
    fetch l_set_of_books_csr into x_durv_rec.books_short_name,x_durv_rec.oper_units_name;
    close l_set_of_books_csr;
*/
/*
    open l_sts_code_csr;
    fetch l_sts_code_csr into x_durv_rec.chr_sts_code;
    close l_sts_code_csr;
    */
  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;


Procedure confirm_cancel_contract
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER,
                   p_contract_number      IN VARCHAR2) AS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'confirm_cancel_contract';
l_api_version          CONSTANT NUMBER := 1.0;

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_maintain_contract_pvt.confirm_cancel_contract(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_contract_id    => p_contract_id,
      p_new_contract_number => p_contract_number);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

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

end;

PROCEDURE create_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      ) AS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'create_party';
l_api_version          CONSTANT NUMBER := 1.0;

lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_cplv_rec.id := p_kpl_rec.id;
    lp_cplv_rec.object1_id1 := p_kpl_rec.object1_id1;
    lp_cplv_rec.object1_id2 := p_kpl_rec.object1_id2;
    lp_cplv_rec.jtot_object1_code := p_kpl_rec.jtot_object1_code;
    lp_cplv_rec.rle_code := p_kpl_rec.rle_code;
    lp_cplv_rec.dnz_chr_id := p_kpl_rec.dnz_chr_id;
    lp_cplv_rec.chr_id := p_kpl_rec.chr_id;
    lp_kplv_rec.attribute_category := p_kpl_rec.attribute_category;
    lp_kplv_rec.attribute1 := p_kpl_rec.attribute1;
    lp_kplv_rec.attribute2 := p_kpl_rec.attribute2;
    lp_kplv_rec.attribute3 := p_kpl_rec.attribute3;
    lp_kplv_rec.attribute4 := p_kpl_rec.attribute4;
    lp_kplv_rec.attribute5 := p_kpl_rec.attribute5;
    lp_kplv_rec.attribute6 := p_kpl_rec.attribute6;
    lp_kplv_rec.attribute7 := p_kpl_rec.attribute7;
    lp_kplv_rec.attribute8 := p_kpl_rec.attribute8;
    lp_kplv_rec.attribute9 := p_kpl_rec.attribute9;
    lp_kplv_rec.attribute10 := p_kpl_rec.attribute10;
    lp_kplv_rec.attribute11 := p_kpl_rec.attribute11;
    lp_kplv_rec.attribute12 := p_kpl_rec.attribute12;
    lp_kplv_rec.attribute13 := p_kpl_rec.attribute13;
    lp_kplv_rec.attribute14 := p_kpl_rec.attribute14;
    lp_kplv_rec.attribute15 := p_kpl_rec.attribute15;

    IF(p_kpl_rec.rle_code IS NOT NULL AND
    	NOT (p_kpl_rec.rle_code = 'LESSEE' OR p_kpl_rec.rle_code = 'LESSOR')) THEN
     lp_kplv_rec.validate_dff_yn := 'Y';
    END IF;

    okl_k_party_roles_pvt.create_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);

    x_kpl_rec.id := lx_cplv_rec.id;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

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

end;

PROCEDURE update_party(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_kpl_rec                 IN  party_rec_type,
      x_kpl_rec                 OUT NOCOPY party_rec_type
      ) AS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'update_party';
l_api_version          CONSTANT NUMBER := 1.0;

lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
lp_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;
lx_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_cplv_rec.id := p_kpl_rec.id;
    lp_cplv_rec.object1_id1 := p_kpl_rec.object1_id1;
    lp_cplv_rec.object1_id2 := p_kpl_rec.object1_id2;
    lp_cplv_rec.rle_code := p_kpl_rec.rle_code;
    lp_cplv_rec.dnz_chr_id := p_kpl_rec.dnz_chr_id;
    lp_cplv_rec.chr_id := p_kpl_rec.chr_id;
    lp_kplv_rec.attribute_category := p_kpl_rec.attribute_category;
    lp_kplv_rec.attribute1 := p_kpl_rec.attribute1;
    lp_kplv_rec.attribute2 := p_kpl_rec.attribute2;
    lp_kplv_rec.attribute3 := p_kpl_rec.attribute3;
    lp_kplv_rec.attribute4 := p_kpl_rec.attribute4;
    lp_kplv_rec.attribute5 := p_kpl_rec.attribute5;
    lp_kplv_rec.attribute6 := p_kpl_rec.attribute6;
    lp_kplv_rec.attribute7 := p_kpl_rec.attribute7;
    lp_kplv_rec.attribute8 := p_kpl_rec.attribute8;
    lp_kplv_rec.attribute9 := p_kpl_rec.attribute9;
    lp_kplv_rec.attribute10 := p_kpl_rec.attribute10;
    lp_kplv_rec.attribute11 := p_kpl_rec.attribute11;
    lp_kplv_rec.attribute12 := p_kpl_rec.attribute12;
    lp_kplv_rec.attribute13 := p_kpl_rec.attribute13;
    lp_kplv_rec.attribute14 := p_kpl_rec.attribute14;
    lp_kplv_rec.attribute15 := p_kpl_rec.attribute15;
    lp_kplv_rec.validate_dff_yn := 'Y';

    okl_k_party_roles_pvt.update_k_party_role(
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_cplv_rec         => lp_cplv_rec,
      x_cplv_rec         => lx_cplv_rec,
      p_kplv_rec         => lp_kplv_rec,
      x_kplv_rec         => lx_kplv_rec);


    x_kpl_rec.id := lx_cplv_rec.id;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

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

end;

END Okl_Deal_Create_Pub;

/

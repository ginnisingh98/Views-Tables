--------------------------------------------------------
--  DDL for Package Body OKS_CDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CDT_PVT" AS
/* $Header: OKSRCDTB.pls 120.2 2005/08/10 05:46:50 mchoudha noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  l_debug VARCHAR2(1) := 'N';

  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_DEFAULTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cdt_rec                      IN cdt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cdt_rec_type IS
    CURSOR oks_k_defaults_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CDT_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            SEGMENT_ID1,
            SEGMENT_ID2,
            JTOT_OBJECT_CODE,
            PDF_ID,
            QCL_ID,
            CGP_NEW_ID,
            CGP_RENEW_ID,
            PRICE_LIST_ID1,
            PRICE_LIST_ID2,
            RENEWAL_TYPE,
            PO_REQUIRED_YN,
            RENEWAL_PRICING_TYPE,
            MARKUP_PERCENT,
            RLE_CODE,
            START_DATE,
            END_DATE,
            --SECURITY_GROUP_ID,
            REVENUE_ESTIMATED_PERCENT,
            REVENUE_ESTIMATED_DURATION,
            REVENUE_ESTIMATED_PERIOD,
            TEMPLATE_SET_ID,
            THRESHOLD_CURRENCY,
            THRESHOLD_AMOUNT,
            EMAIL_ADDRESS,
            BILLING_PROFILE_ID,
            USER_ID,
            THRESHOLD_ENABLED_YN,
            GRACE_PERIOD,
            GRACE_DURATION,
            PAYMENT_TERMS_ID1,
            PAYMENT_TERMS_ID2,
            EVERGREEN_THRESHOLD_CURR,
            EVERGREEN_THRESHOLD_AMT,
            PAYMENT_METHOD,
            PAYMENT_THRESHOLD_CURR,
            PAYMENT_THRESHOLD_AMT,
            INTERFACE_PRICE_BREAK,
            CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start
            BASE_CURRENCY,
            APPROVAL_TYPE,
            EVERGREEN_APPROVAL_TYPE,
            ONLINE_APPROVAL_TYPE,
            PURCHASE_ORDER_FLAG,
            CREDIT_CARD_FLAG,
            WIRE_FLAG,
            COMMITMENT_NUMBER_FLAG,
            CHECK_FLAG,
            PERIOD_TYPE,
            PERIOD_START,
            PRICE_UOM,
            TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
      FROM Oks_K_Defaults
     WHERE oks_k_defaults.id    = p_id;
    l_oks_k_defaults_pk            oks_k_defaults_pk_csr%ROWTYPE;
    l_cdt_rec                      cdt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_k_defaults_pk_csr (p_cdt_rec.id);
    FETCH oks_k_defaults_pk_csr INTO
              l_cdt_rec.ID,
              l_cdt_rec.CDT_TYPE,
              l_cdt_rec.OBJECT_VERSION_NUMBER,
              l_cdt_rec.CREATED_BY,
              l_cdt_rec.CREATION_DATE,
              l_cdt_rec.LAST_UPDATED_BY,
              l_cdt_rec.LAST_UPDATE_DATE,
              l_cdt_rec.SEGMENT_ID1,
              l_cdt_rec.SEGMENT_ID2,
              l_cdt_rec.JTOT_OBJECT_CODE,
              l_cdt_rec.PDF_ID,
              l_cdt_rec.QCL_ID,
              l_cdt_rec.CGP_NEW_ID,
              l_cdt_rec.CGP_RENEW_ID,
              l_cdt_rec.PRICE_LIST_ID1,
              l_cdt_rec.PRICE_LIST_ID2,
              l_cdt_rec.RENEWAL_TYPE,
              l_cdt_rec.PO_REQUIRED_YN,
              l_cdt_rec.RENEWAL_PRICING_TYPE,
              l_cdt_rec.MARKUP_PERCENT,
              l_cdt_rec.RLE_CODE,
              l_cdt_rec.START_DATE,
              l_cdt_rec.END_DATE,
              --l_cdt_rec.SECURITY_GROUP_ID,
              l_cdt_rec.REVENUE_ESTIMATED_PERCENT,
              l_cdt_rec.REVENUE_ESTIMATED_DURATION,
              l_cdt_rec.REVENUE_ESTIMATED_PERIOD,
              l_cdt_rec.TEMPLATE_SET_ID,
              l_cdt_rec.THRESHOLD_CURRENCY,
              l_cdt_rec.THRESHOLD_AMOUNT,
              l_cdt_rec.EMAIL_ADDRESS,
              l_cdt_rec.BILLING_PROFILE_ID,
              l_cdt_rec.USER_ID,
              l_cdt_rec.THRESHOLD_ENABLED_YN,
              l_cdt_rec.GRACE_PERIOD,
              l_cdt_rec.GRACE_DURATION,
              l_cdt_rec.PAYMENT_TERMS_ID1,
              l_cdt_rec.PAYMENT_TERMS_ID2,
              l_cdt_rec.EVERGREEN_THRESHOLD_CURR,
              l_cdt_rec.EVERGREEN_THRESHOLD_AMT,
              l_cdt_rec.PAYMENT_METHOD,
              l_cdt_rec.PAYMENT_THRESHOLD_CURR,
              l_cdt_rec.PAYMENT_THRESHOLD_AMT,
              l_cdt_rec.INTERFACE_PRICE_BREAK,
              l_cdt_rec.CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start
              l_cdt_rec.BASE_CURRENCY,
              l_cdt_rec.APPROVAL_TYPE,
              l_cdt_rec.EVERGREEN_APPROVAL_TYPE,
              l_cdt_rec.ONLINE_APPROVAL_TYPE,
              l_cdt_rec.PURCHASE_ORDER_FLAG,
              l_cdt_rec.CREDIT_CARD_FLAG,
              l_cdt_rec.WIRE_FLAG,
              l_cdt_rec.COMMITMENT_NUMBER_FLAG,
              l_cdt_rec.CHECK_FLAG,
              l_cdt_rec.PERIOD_TYPE,
              l_cdt_rec.PERIOD_START,
              l_cdt_rec.PRICE_UOM,
              l_cdt_rec.TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
;

    x_no_data_found := oks_k_defaults_pk_csr%NOTFOUND;
    CLOSE oks_k_defaults_pk_csr;
    RETURN(l_cdt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cdt_rec                      IN cdt_rec_type
  ) RETURN cdt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cdt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_DEFAULTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cdtv_rec                     IN cdtv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cdtv_rec_type IS
    CURSOR oks_kdf_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CDT_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            SEGMENT_ID1,
            SEGMENT_ID2,
            JTOT_OBJECT_CODE,
            PDF_ID,
            QCL_ID,
            CGP_NEW_ID,
            CGP_RENEW_ID,
            PRICE_LIST_ID1,
            PRICE_LIST_ID2,
            RENEWAL_TYPE,
            PO_REQUIRED_YN,
            RENEWAL_PRICING_TYPE,
            MARKUP_PERCENT,
            RLE_CODE,
            START_DATE,
            END_DATE,
            REVENUE_ESTIMATED_PERCENT,
            REVENUE_ESTIMATED_DURATION,
            REVENUE_ESTIMATED_PERIOD,
            TEMPLATE_SET_ID,
            THRESHOLD_CURRENCY,
            THRESHOLD_AMOUNT,
            EMAIL_ADDRESS,
            BILLING_PROFILE_ID,
            USER_ID,
            THRESHOLD_ENABLED_YN,
            GRACE_PERIOD,
            GRACE_DURATION,
            PAYMENT_TERMS_ID1,
            PAYMENT_TERMS_ID2,
            EVERGREEN_THRESHOLD_CURR,
            EVERGREEN_THRESHOLD_AMT,
            PAYMENT_METHOD,
            PAYMENT_THRESHOLD_CURR,
            PAYMENT_THRESHOLD_AMT,
            INTERFACE_PRICE_BREAK,
            CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start  /* mmadhavi 4485150 : add other columns */
            PERIOD_TYPE,
            PERIOD_START,
            PRICE_UOM,
            BASE_CURRENCY,
            APPROVAL_TYPE,
            EVERGREEN_APPROVAL_TYPE,
            ONLINE_APPROVAL_TYPE,
            PURCHASE_ORDER_FLAG,
            CREDIT_CARD_FLAG,
            WIRE_FLAG,
            COMMITMENT_NUMBER_FLAG,
            CHECK_FLAG,
            TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
      FROM Oks_K_Defaults_V
     WHERE oks_k_defaults_v.id  = p_id;
    l_oks_kdf_pk                   oks_kdf_pk_csr%ROWTYPE;
    l_cdtv_rec                     cdtv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_kdf_pk_csr (p_cdtv_rec.id);
    FETCH oks_kdf_pk_csr INTO
              l_cdtv_rec.ID,
              l_cdtv_rec.CDT_TYPE,
              l_cdtv_rec.OBJECT_VERSION_NUMBER,
              l_cdtv_rec.CREATED_BY,
              l_cdtv_rec.CREATION_DATE,
              l_cdtv_rec.LAST_UPDATED_BY,
              l_cdtv_rec.LAST_UPDATE_DATE,
              l_cdtv_rec.SEGMENT_ID1,
              l_cdtv_rec.SEGMENT_ID2,
              l_cdtv_rec.JTOT_OBJECT_CODE,
              l_cdtv_rec.PDF_ID,
              l_cdtv_rec.QCL_ID,
              l_cdtv_rec.CGP_NEW_ID,
              l_cdtv_rec.CGP_RENEW_ID,
              l_cdtv_rec.PRICE_LIST_ID1,
              l_cdtv_rec.PRICE_LIST_ID2,
              l_cdtv_rec.RENEWAL_TYPE,
              l_cdtv_rec.PO_REQUIRED_YN,
              l_cdtv_rec.RENEWAL_PRICING_TYPE,
              l_cdtv_rec.MARKUP_PERCENT,
              l_cdtv_rec.RLE_CODE,
              l_cdtv_rec.START_DATE,
              l_cdtv_rec.END_DATE,
              l_cdtv_rec.REVENUE_ESTIMATED_PERCENT,
              l_cdtv_rec.REVENUE_ESTIMATED_DURATION,
              l_cdtv_rec.REVENUE_ESTIMATED_PERIOD,
              l_cdtv_rec.template_set_id,
              l_cdtv_rec.THRESHOLD_CURRENCY,
              l_cdtv_rec.THRESHOLD_AMOUNT,
              l_cdtv_rec.EMAIL_ADDRESS,
              l_cdtv_rec.BILLING_PROFILE_ID,
              l_cdtv_rec.USER_ID,
              l_cdtv_rec.THRESHOLD_ENABLED_YN,
              l_cdtv_rec.GRACE_PERIOD,
              l_cdtv_rec.GRACE_DURATION,
              l_cdtv_rec.PAYMENT_TERMS_ID1,
              l_cdtv_rec.PAYMENT_TERMS_ID2,
              l_cdtv_rec.EVERGREEN_THRESHOLD_CURR,
              l_cdtv_rec.EVERGREEN_THRESHOLD_AMT,
              l_cdtv_rec.PAYMENT_METHOD,
              l_cdtv_rec.PAYMENT_THRESHOLD_CURR,
              l_cdtv_rec.PAYMENT_THRESHOLD_AMT,
              l_cdtv_rec.INTERFACE_PRICE_BREAK,
              l_cdtv_rec.CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start   /* mmadhavi 4485150 : add other columns */
              l_cdtv_rec.PERIOD_TYPE,
              l_cdtv_rec.PERIOD_START,
              l_cdtv_rec.PRICE_UOM,
              l_cdtv_rec.BASE_CURRENCY,
              l_cdtv_rec.APPROVAL_TYPE,
              l_cdtv_rec.EVERGREEN_APPROVAL_TYPE,
              l_cdtv_rec.ONLINE_APPROVAL_TYPE,
              l_cdtv_rec.PURCHASE_ORDER_FLAG,
              l_cdtv_rec.CREDIT_CARD_FLAG,
              l_cdtv_rec.WIRE_FLAG,
              l_cdtv_rec.COMMITMENT_NUMBER_FLAG,
              l_cdtv_rec.CHECK_FLAG,
              l_cdtv_rec.TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End

;
    x_no_data_found := oks_kdf_pk_csr%NOTFOUND;
    CLOSE oks_kdf_pk_csr;
    RETURN(l_cdtv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cdtv_rec                     IN cdtv_rec_type
  ) RETURN cdtv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cdtv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_K_DEFAULTS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cdtv_rec	IN cdtv_rec_type
  ) RETURN cdtv_rec_type IS
    l_cdtv_rec	cdtv_rec_type := p_cdtv_rec;
  BEGIN
    IF (l_cdtv_rec.cdt_type = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.cdt_type := NULL;
    END IF;
    IF (l_cdtv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.object_version_number := NULL;
    END IF;
    IF (l_cdtv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.created_by := NULL;
    END IF;
    IF (l_cdtv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cdtv_rec.creation_date := NULL;
    END IF;
    IF (l_cdtv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cdtv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cdtv_rec.last_update_date := NULL;
    END IF;
    IF (l_cdtv_rec.segment_id1 = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.segment_id1 := NULL;
    END IF;
    IF (l_cdtv_rec.segment_id2 = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.segment_id2 := NULL;
    END IF;
    IF (l_cdtv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.jtot_object_code := NULL;
    END IF;
    IF (l_cdtv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.pdf_id := NULL;
    END IF;
    IF (l_cdtv_rec.qcl_id = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.qcl_id := NULL;
    END IF;
    IF (l_cdtv_rec.cgp_new_id = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.cgp_new_id := NULL;
    END IF;
    IF (l_cdtv_rec.cgp_renew_id = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.cgp_renew_id := NULL;
    END IF;
    IF (l_cdtv_rec.price_list_id1 = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.price_list_id1 := NULL;
    END IF;
    IF (l_cdtv_rec.price_list_id2 = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.price_list_id2 := NULL;
    END IF;
    IF (l_cdtv_rec.renewal_type = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.renewal_type := NULL;
    END IF;
    IF (l_cdtv_rec.po_required_yn = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.po_required_yn := NULL;
    END IF;
    IF (l_cdtv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.renewal_pricing_type := NULL;
    END IF;
    IF (l_cdtv_rec.markup_percent = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.markup_percent := NULL;
    END IF;
    IF (l_cdtv_rec.rle_code= OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.rle_code:= NULL;
    END IF;
    IF (l_cdtv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_cdtv_rec.start_date := NULL;
    END IF;
    IF (l_cdtv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_cdtv_rec.end_date := NULL;
    END IF;
    IF (l_cdtv_rec.revenue_estimated_percent = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.revenue_estimated_percent := NULL;
    END IF;
    IF (l_cdtv_rec.revenue_estimated_duration = OKC_API.G_MISS_NUM) THEN
      l_cdtv_rec.revenue_estimated_duration := NULL;
    END IF;
    IF (l_cdtv_rec.revenue_estimated_period = OKC_API.G_MISS_CHAR) THEN
      l_cdtv_rec.revenue_estimated_period := NULL;
    END IF;
    IF (l_cdtv_rec.template_set_id = OKC_API.G_MISS_NUM ) THEN
        l_cdtv_rec.template_set_id := NULL;
    END IF;
    IF (l_cdtv_rec.THRESHOLD_CURRENCY = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.THRESHOLD_CURRENCY := NULL;
    END IF;
    IF (l_cdtv_rec.THRESHOLD_AMOUNT = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.THRESHOLD_AMOUNT := NULL;
    END IF;
    IF (l_cdtv_rec.EMAIL_ADDRESS = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.EMAIL_ADDRESS := NULL;
    END IF;
    IF (l_cdtv_rec.BILLING_PROFILE_ID = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.BILLING_PROFILE_ID := NULL;
    END IF;
    IF (l_cdtv_rec.USER_ID = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.USER_ID := NULL;
    END IF;
    IF (l_cdtv_rec.THRESHOLD_ENABLED_YN = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.THRESHOLD_ENABLED_YN := NULL;
    END IF;
    IF (l_cdtv_rec.GRACE_PERIOD = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.GRACE_PERIOD := NULL;
    END IF;
    IF (l_cdtv_rec.GRACE_DURATION = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.GRACE_DURATION := NULL;
    END IF;
    IF (l_cdtv_rec.PAYMENT_TERMS_ID1 = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PAYMENT_TERMS_ID1 := NULL;
    END IF;
    IF (l_cdtv_rec.PAYMENT_TERMS_ID2 = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PAYMENT_TERMS_ID2 := NULL;
    END IF;
    IF (l_cdtv_rec.EVERGREEN_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.EVERGREEN_THRESHOLD_CURR := NULL;
    END IF;
    IF (l_cdtv_rec.EVERGREEN_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.EVERGREEN_THRESHOLD_AMT := NULL;
    END IF;
    IF (l_cdtv_rec.PAYMENT_METHOD = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PAYMENT_METHOD := NULL;
    END IF;
    IF (l_cdtv_rec.PAYMENT_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PAYMENT_THRESHOLD_CURR := NULL;
    END IF;
    IF (l_cdtv_rec.PAYMENT_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
        l_cdtv_rec.PAYMENT_THRESHOLD_AMT := NULL;
    END IF;
    IF (l_cdtv_rec.INTERFACE_PRICE_BREAK = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.INTERFACE_PRICE_BREAK := NULL;
    END IF;
    IF (l_cdtv_rec.CREDIT_AMOUNT = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.CREDIT_AMOUNT := NULL;
    END IF;
-- R12 Data Model Changes 4485150 Start    /* mmadhavi 4485150 : add other columns */
    IF (l_cdtv_rec.PERIOD_TYPE = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PERIOD_TYPE := NULL;
    END IF;
    IF (l_cdtv_rec.PERIOD_START = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PERIOD_START := NULL;
    END IF;
    IF (l_cdtv_rec.PRICE_UOM = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PRICE_UOM := NULL;
    END IF;
    IF (l_cdtv_rec.BASE_CURRENCY = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.BASE_CURRENCY := NULL;
    END IF;
    IF (l_cdtv_rec.APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.APPROVAL_TYPE := NULL;
    END IF;
    IF (l_cdtv_rec.EVERGREEN_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.EVERGREEN_APPROVAL_TYPE := NULL;
    END IF;
    IF (l_cdtv_rec.ONLINE_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.ONLINE_APPROVAL_TYPE := NULL;
    END IF;
    IF (l_cdtv_rec.PURCHASE_ORDER_FLAG = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.PURCHASE_ORDER_FLAG := NULL;
    END IF;
    IF (l_cdtv_rec.CREDIT_CARD_FLAG = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.CREDIT_CARD_FLAG := NULL;
    END IF;
    IF (l_cdtv_rec.WIRE_FLAG = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.WIRE_FLAG := NULL;
    END IF;
    IF (l_cdtv_rec.COMMITMENT_NUMBER_FLAG = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.COMMITMENT_NUMBER_FLAG := NULL;
    END IF;
    IF (l_cdtv_rec.CHECK_FLAG = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.CHECK_FLAG := NULL;
    END IF;
    IF (l_cdtv_rec.TEMPLATE_LANGUAGE = OKC_API.G_MISS_CHAR) THEN
        l_cdtv_rec.TEMPLATE_LANGUAGE := NULL;
    END IF;
-- R12 Data Model Changes 4485150 End


    RETURN(l_cdtv_rec);
  END null_out_defaults;
  ----------------------------------------------
  -- Validate_Attributes for:OKS_K_DEFAULTS_V --
  ----------------------------------------------
  -- Validate ID--
  -----------------------------------------------------
  PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
				p_id   IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status;
		NULL;
  When OTHERS THEN
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_id;

  -----------------------------------------------------
  -- Validate Object Version Number --
  -----------------------------------------------------
  PROCEDURE validate_objvernum(x_return_status OUT NOCOPY varchar2,
					 P_object_version_number IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_object_version_number = OKC_API.G_MISS_NUM OR
       p_object_version_number IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_objvernum;

  -- Start of comments
  --
  -- Procedure Name  : validate_Renewl_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_Renewal_Type(x_return_status OUT NOCOPY  VARCHAR2,
                                 p_Renewal_Type      IN    VARCHAR2) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check that data exists
    If  NOT (p_Renewal_Type = OKC_API.G_MISS_CHAR or
        p_Renewal_Type IS NULL)
    Then
	    IF upper(p_Renewal_Type) NOT IN ('NSR','SFA','EVN','DNR', 'ERN')
    		THEN
  	  	OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name	=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'RENEWAL_TYPE');
	   -- notify caller of an error
        	x_return_status := OKC_API.G_RET_STS_ERROR;
	   -- halt validation
    	    End If;
    END IF;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_renewal_Type;

  -- Start of comments
  --
  -- Procedure Name  : validate_po_required_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_po_required_yn(x_return_status OUT NOCOPY  VARCHAR2,
                            p_po_Required      IN    VARCHAR2) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If  NOT (p_PO_Required= OKC_API.G_MISS_CHAR or
        p_PO_Required IS NULL)
    Then
    -- check allowed values
    If upper(p_po_required) NOT IN ('Y','N') Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'po_required_yn');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    END IF;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_po_required_yn;

    -- Procedure Name  : validate_threshold_enabled_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_threshold_enabled_yn(x_return_status OUT NOCOPY  VARCHAR2,
                            p_threshold_enabled      IN    VARCHAR2) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If  NOT (p_threshold_enabled = OKC_API.G_MISS_CHAR or
        p_threshold_enabled IS NULL)
    Then
    -- check allowed values
    If upper(p_threshold_enabled) NOT IN ('Y','N') Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'threshold_enabled_yn');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    END IF;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_threshold_enabled_yn;


  -- Start of comments
  --
  -- Procedure Name  : validate_renewal_pricing_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_renewal_pricing_type(x_return_status OUT NOCOPY  VARCHAR2,
                            p_renewal_pricing_type      IN    VARCHAR2) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check allowed values
    If  NOT (p_Renewal_Pricing_Type = OKC_API.G_MISS_CHAR or
        p_Renewal_Pricing_Type IS NULL)
    Then
    If upper(p_renewal_pricing_type) NOT IN ('LST','PCT','MAN') Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'renewal_pricing_type');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    END IF;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_renewal_pricing_type;

  -- Start of comments
  --
  -- Procedure Name  : validate_Markup_Percent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_markup_percent(x_return_status OUT NOCOPY  VARCHAR2,
                            		 p_markup_Percent      IN    NUMBER) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_markup_percent;

-- R12 Data Model Changes 4485150 Start

  -- Start of comments
  -- Procedure Name  : validate_currency_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_currency_code(x_return_status OUT NOCOPY   VARCHAR2,
                                   p_currency_code      IN    VARCHAR2) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_fndv_csr Is
  		select 'x'
		from FND_CURRENCIES_VL
		where currency_code = p_currency_code
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
		and enabled_flag = 'Y';
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CHR_PVT');
       okc_debug.log('500: Entered validate_currency_code', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_currency_code = OKC_API.G_MISS_CHAR or
  	   p_currency_code IS NULL)
    Then
  /*	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Currency Code');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
   */
    NULL;
    ELSE

    -- check data is in lookup table
      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'currency_code');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_currency_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

    END IF;
  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_currency_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_currency_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  End validate_currency_code;

  -- R12 Data Model Changes 4485150 End

-- Start of comments
  -- R12 Data Model Changes 4485150 Start
  -- Procedure Name  : validate_approval_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_approval_type(x_return_status OUT NOCOPY   VARCHAR2,
                                   p_approval_type      IN    VARCHAR2) is /* mmadhavi 4485150 : change data type */

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_approval_type ---- Check Up
                and (lookup_type = 'OKS_REN_ONLINE_APPROVAL'
     		  or lookup_type = 'OKS_REN_MANUAL_APPROVAL')
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CHR_PVT');
       okc_debug.log('500: Entered validate_approval_type', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_approval_type = OKC_API.G_MISS_CHAR or
  	   p_approval_type IS NULL)
    Then
        NULL;
    Else
    -- check data is in lookup table
      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'approval_type');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_approval_type', 2);
       okc_debug.Reset_Indentation;
    END IF;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_approval_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_approval_type:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  End validate_approval_type;

  -- R12 Data Model Changes 4485150 End

-- Start of comments
  -- R12 Data Model Changes 4485150 Start
  -- Procedure Name  : val_evergreen_appl_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE val_evergreen_appl_type(x_return_status OUT NOCOPY   VARCHAR2,      /* mmadhavi 4485150 : change procedure name */
                                   p_evergreen_approval_type      IN    VARCHAR2) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_evergreen_approval_type
                and (lookup_type = 'OKS_REN_MANUAL_APPROVAL')
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CHR_PVT');
       okc_debug.log('500: Entered validate_approval_type', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_evergreen_approval_type = OKC_API.G_MISS_CHAR or
  	   p_evergreen_approval_type IS NULL)
    Then
        NULL;
    Else
    -- check data is in lookup table
      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'evergreen_approval_type');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting val_evergreen_appl_type', 2);
       okc_debug.Reset_Indentation;
    END IF;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting val_evergreen_appl_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting val_evergreen_appl_type:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  End val_evergreen_appl_type;

  -- R12 Data Model Changes 4485150 End

-- Start of comments
  -- R12 Data Model Changes 4485150 Start
  -- Procedure Name  : val_online_approval_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE val_online_approval_type(x_return_status OUT NOCOPY   VARCHAR2,         /* mmadhavi 4485150 : change procedure name */
                                   p_online_approval_type      IN    VARCHAR2) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_fndv_csr Is
  		select 'x'
		from FND_LOOKUPS
		where lookup_code = p_online_approval_type
                and (lookup_type = 'OKS_REN_ONLINE_APPROVAL')
		and sysdate between nvl(start_date_active,sysdate)
					 and nvl(end_date_active,sysdate)
                and enabled_flag = 'Y';
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_RCD_PVT');
       okc_debug.log('500: Entered validate_online_approval_type', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_online_approval_type = OKC_API.G_MISS_CHAR or
  	   p_online_approval_type IS NULL)
    Then
        NULL;
    Else
    -- check data is in lookup table
      Open l_fndv_csr;
      Fetch l_fndv_csr Into l_dummy_var;
      Close l_fndv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'online_approval_type');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_online_approval_type', 2);
       okc_debug.Reset_Indentation;
    END IF;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_approval_type:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_approval_type:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;


  End val_online_approval_type;

  -- R12 Data Model Changes 4485150 End


---------------------------------------------------
  -- Validate_Attributes for:OKS_K_DEFAULTS_V
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_cdtv_rec IN  cdtv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_K_DEFAULTS_V',x_return_status);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there is a error
          l_return_status := x_return_status;
       END IF;
    END IF;

    --Column Level Validation

    --ID
    validate_id(x_return_status, p_cdtv_rec.id);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    --OBJECT_VERSION_NUMBER
    validate_objvernum(x_return_status, p_cdtv_rec.object_version_number);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    	--RENEWAL_TYPE
    validate_Renewal_Type(x_return_status, p_cdtv_rec.Renewal_Type);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--PO_REQUIRED_YN

    validate_po_required_yn(x_return_status, p_cdtv_rec.PO_Required_YN);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- threshold_enabled_yn
    validate_threshold_enabled_yn(x_return_status, p_cdtv_rec.threshold_enabled_yn);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--RENEWAL_PRICING_TYPE
    validate_Renewal_Pricing_Type(x_return_status, p_cdtv_rec.Renewal_Pricing_Type);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--MARKUP_PERCENT
   validate_Markup_Percent(x_return_status, p_cdtv_rec.Markup_Percent);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

-- R12 Data Model Changes 4485150 Start
	--APPROVAL_TYPE
   validate_Approval_Type(x_return_status, p_cdtv_rec.Approval_type);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--ONLINE_APPROVAL_TYPE
   val_Online_Approval_Type(x_return_status, p_cdtv_rec.Online_Approval_type);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--EVERGREEN_APPROVAL_TYPE
   val_evergreen_appl_type(x_return_status, p_cdtv_rec.Evergreen_Approval_type);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

-- R12 Data Model Changes 4485150 End

       Return (l_return_status);
  Exception

  When G_EXCEPTION_HALT_VALIDATION Then

       Return (l_return_status);

  When OTHERS Then
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);

       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       Return(l_return_status);

  END validate_attributes;

/*  FUNCTION Validate_Attributes (
    p_cdtv_rec IN  cdtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_cdtv_rec.id = OKC_API.G_MISS_NUM OR
       p_cdtv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cdtv_rec.cdt_type = OKC_API.G_MISS_CHAR OR
          p_cdtv_rec.cdt_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cdt_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cdtv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cdtv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKS_K_DEFAULTS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_cdtv_rec IN cdtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cdtv_rec_type,
    p_to	OUT NOCOPY cdt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cdt_type := p_from.cdt_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.segment_id1 := p_from.segment_id1;
    p_to.segment_id2 := p_from.segment_id2;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.pdf_id := p_from.pdf_id;
    p_to.qcl_id := p_from.qcl_id;
    p_to.cgp_new_id := p_from.cgp_new_id;
    p_to.cgp_renew_id := p_from.cgp_renew_id;
    p_to.price_list_id1 := p_from.price_list_id1;
    p_to.price_list_id2 := p_from.price_list_id2;
    p_to.renewal_type := p_from.renewal_type;
    p_to.po_required_yn := p_from.po_required_yn;
    p_to.renewal_pricing_type := p_from.renewal_pricing_type;
    p_to.markup_percent := p_from.markup_percent;
    p_to.rle_code:= p_from.rle_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.revenue_estimated_percent := p_from.revenue_estimated_percent;
    p_to.revenue_estimated_duration := p_from.revenue_estimated_duration;
    p_to.revenue_estimated_period := p_from.revenue_estimated_period;
    p_to.template_set_id := p_from.template_set_id;
    p_to.THRESHOLD_CURRENCY := p_from.THRESHOLD_CURRENCY;
    p_to.THRESHOLD_AMOUNT := p_from.THRESHOLD_AMOUNT;
    p_to.EMAIL_ADDRESS := p_from.EMAIL_ADDRESS;
    p_to.BILLING_PROFILE_ID := p_from.BILLING_PROFILE_ID;
    p_to.USER_ID := p_from.USER_ID;
    p_to.THRESHOLD_ENABLED_YN := p_from.THRESHOLD_ENABLED_YN;
    p_to.GRACE_PERIOD := p_from.GRACE_PERIOD;
    p_to.GRACE_DURATION := p_from.GRACE_DURATION;
    p_to.PAYMENT_TERMS_ID1 := p_from.PAYMENT_TERMS_ID1;
    p_to.PAYMENT_TERMS_ID2 := p_from.PAYMENT_TERMS_ID2;
    p_to.EVERGREEN_THRESHOLD_CURR := p_from.EVERGREEN_THRESHOLD_CURR;
    p_to.EVERGREEN_THRESHOLD_AMT := p_from.EVERGREEN_THRESHOLD_AMT;
    p_to.PAYMENT_METHOD := p_from.PAYMENT_METHOD;
    p_to.PAYMENT_THRESHOLD_CURR := p_from.PAYMENT_THRESHOLD_CURR;
    p_to.PAYMENT_THRESHOLD_AMT := p_from.PAYMENT_THRESHOLD_AMT;
    p_to.INTERFACE_PRICE_BREAK := p_from.INTERFACE_PRICE_BREAK;
    p_to.CREDIT_AMOUNT := p_from.CREDIT_AMOUNT;
-- R12 Data Model Changes 4485150 Start  /* mmadhavi 4485150 : add other columns */
    p_to.PERIOD_TYPE := p_from.PERIOD_TYPE;
    p_to.PERIOD_START := p_from.PERIOD_START;
    p_to.PRICE_UOM :=  p_from.PRICE_UOM;
    p_to.BASE_CURRENCY :=  p_from.BASE_CURRENCY;
    p_to.APPROVAL_TYPE :=  p_from.APPROVAL_TYPE;
    p_to.EVERGREEN_APPROVAL_TYPE :=  p_from.EVERGREEN_APPROVAL_TYPE;
    p_to.ONLINE_APPROVAL_TYPE :=  p_from.ONLINE_APPROVAL_TYPE;
    p_to.PURCHASE_ORDER_FLAG :=  p_from.PURCHASE_ORDER_FLAG;
    p_to.CREDIT_CARD_FLAG :=  p_from.CREDIT_CARD_FLAG;
    p_to.WIRE_FLAG :=  p_from.WIRE_FLAG;
    p_to.COMMITMENT_NUMBER_FLAG :=  p_from.COMMITMENT_NUMBER_FLAG;
    p_to.CHECK_FLAG :=  p_from.CHECK_FLAG;
    p_to.TEMPLATE_LANGUAGE :=  p_from.TEMPLATE_LANGUAGE;
-- R12 Data Model Changes 4485150 End
  END migrate;
  PROCEDURE migrate (
    p_from	IN cdt_rec_type,
    p_to	OUT NOCOPY cdtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cdt_type := p_from.cdt_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.segment_id1 := p_from.segment_id1;
    p_to.segment_id2 := p_from.segment_id2;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.pdf_id := p_from.pdf_id;
    p_to.qcl_id := p_from.qcl_id;
    p_to.cgp_new_id := p_from.cgp_new_id;
    p_to.cgp_renew_id := p_from.cgp_renew_id;
    p_to.price_list_id1 := p_from.price_list_id1;
    p_to.price_list_id2 := p_from.price_list_id2;
    p_to.renewal_type := p_from.renewal_type;
    p_to.po_required_yn := p_from.po_required_yn;
    p_to.renewal_pricing_type := p_from.renewal_pricing_type;
    p_to.markup_percent := p_from.markup_percent;
    p_to.rle_code:= p_from.rle_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.revenue_estimated_percent := p_from.revenue_estimated_percent;
    p_to.revenue_estimated_duration := p_from.revenue_estimated_duration;
    p_to.revenue_estimated_period := p_from.revenue_estimated_period;
    p_to.template_set_id := p_from.template_set_id;
    p_to.THRESHOLD_CURRENCY := p_from.THRESHOLD_CURRENCY;
    p_to.THRESHOLD_AMOUNT := p_from.THRESHOLD_AMOUNT;
    p_to.EMAIL_ADDRESS := p_from.EMAIL_ADDRESS;
    p_to.BILLING_PROFILE_ID := p_from.BILLING_PROFILE_ID;
    p_to.USER_ID := p_from.USER_ID;
    p_to.THRESHOLD_ENABLED_YN := p_from.THRESHOLD_ENABLED_YN;
    p_to.GRACE_PERIOD := p_from.GRACE_PERIOD;
    p_to.GRACE_DURATION := p_from.GRACE_DURATION;
    p_to.PAYMENT_TERMS_ID1 := p_from.PAYMENT_TERMS_ID1;
    p_to.PAYMENT_TERMS_ID2 := p_from.PAYMENT_TERMS_ID2;
    p_to.EVERGREEN_THRESHOLD_CURR := p_from.EVERGREEN_THRESHOLD_CURR;
    p_to.EVERGREEN_THRESHOLD_AMT := p_from.EVERGREEN_THRESHOLD_AMT;
    p_to.PAYMENT_METHOD := p_from.PAYMENT_METHOD;
    p_to.PAYMENT_THRESHOLD_CURR := p_from.PAYMENT_THRESHOLD_CURR;
    p_to.PAYMENT_THRESHOLD_AMT := p_from.PAYMENT_THRESHOLD_AMT;
    p_to.INTERFACE_PRICE_BREAK := p_from.INTERFACE_PRICE_BREAK;
    p_to.CREDIT_AMOUNT := p_from.CREDIT_AMOUNT;
-- R12 Data Model Changes 4485150 Start  /* mmadhavi 4485150 : add other columns */
    p_to.PERIOD_TYPE := p_from.PERIOD_TYPE;
    p_to.PERIOD_START := p_from.PERIOD_START;
    p_to.PRICE_UOM :=  p_from.PRICE_UOM;
    p_to.BASE_CURRENCY :=  p_from.BASE_CURRENCY;
    p_to.APPROVAL_TYPE :=  p_from.APPROVAL_TYPE;
    p_to.EVERGREEN_APPROVAL_TYPE :=  p_from.EVERGREEN_APPROVAL_TYPE;
    p_to.ONLINE_APPROVAL_TYPE :=  p_from.ONLINE_APPROVAL_TYPE;
    p_to.PURCHASE_ORDER_FLAG :=  p_from.PURCHASE_ORDER_FLAG;
    p_to.CREDIT_CARD_FLAG :=  p_from.CREDIT_CARD_FLAG;
    p_to.WIRE_FLAG :=  p_from.WIRE_FLAG;
    p_to.COMMITMENT_NUMBER_FLAG :=  p_from.COMMITMENT_NUMBER_FLAG;
    p_to.CHECK_FLAG :=  p_from.CHECK_FLAG;
    p_to.TEMPLATE_LANGUAGE :=  p_from.TEMPLATE_LANGUAGE;
-- R12 Data Model Changes 4485150 End

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKS_K_DEFAULTS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdtv_rec                     cdtv_rec_type := p_cdtv_rec;
    l_cdt_rec                      cdt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_cdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:CDTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cdtv_tbl.COUNT > 0) THEN
      i := p_cdtv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cdtv_rec                     => p_cdtv_tbl(i));
        EXIT WHEN (i = p_cdtv_tbl.LAST);
        i := p_cdtv_tbl.NEXT(i);
      END LOOP;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- insert_row for:OKS_K_DEFAULTS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdt_rec                      IN cdt_rec_type,
    x_cdt_rec                      OUT NOCOPY cdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFAULTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdt_rec                      cdt_rec_type := p_cdt_rec;
    l_def_cdt_rec                  cdt_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKS_K_DEFAULTS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_cdt_rec IN  cdt_rec_type,
      x_cdt_rec OUT NOCOPY cdt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdt_rec := p_cdt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cdt_rec,                         -- IN
      l_cdt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_K_DEFAULTS(
        id,
        cdt_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        segment_id1,
        segment_id2,
        jtot_object_code,
        pdf_id,
        qcl_id,
        cgp_new_id,
        cgp_renew_id,
        price_list_id1,
        price_list_id2,
        renewal_type,
        po_required_yn,
        renewal_pricing_type,
        markup_percent,
        rle_code,
        start_date,
        end_date,
        --security_group_id,
        revenue_estimated_percent,
        revenue_estimated_duration,
        revenue_estimated_period,
        template_set_id,
        THRESHOLD_CURRENCY,
        THRESHOLD_AMOUNT,
        EMAIL_ADDRESS,
        BILLING_PROFILE_ID,
        USER_ID,
        THRESHOLD_ENABLED_YN,
        GRACE_PERIOD,
        GRACE_DURATION,
        PAYMENT_TERMS_ID1,
        PAYMENT_TERMS_ID2,
        EVERGREEN_THRESHOLD_CURR,
        EVERGREEN_THRESHOLD_AMT,
        PAYMENT_METHOD,
        PAYMENT_THRESHOLD_CURR,
        PAYMENT_THRESHOLD_AMT,
        INTERFACE_PRICE_BREAK,
        CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start
        BASE_CURRENCY	,
        APPROVAL_TYPE	,
        EVERGREEN_APPROVAL_TYPE	,
        ONLINE_APPROVAL_TYPE	,
        PURCHASE_ORDER_FLAG	,
        CREDIT_CARD_FLAG	,
        WIRE_FLAG	,
        COMMITMENT_NUMBER_FLAG	,
        CHECK_FLAG	,
        PERIOD_TYPE	,
        PERIOD_START	,
        PRICE_UOM	,
        TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
        ) VALUES (
        l_cdt_rec.id,
        l_cdt_rec.cdt_type,
        l_cdt_rec.object_version_number,
        l_cdt_rec.created_by,
        l_cdt_rec.creation_date,
        l_cdt_rec.last_updated_by,
        l_cdt_rec.last_update_date,
        l_cdt_rec.segment_id1,
        l_cdt_rec.segment_id2,
        l_cdt_rec.jtot_object_code,
        l_cdt_rec.pdf_id,
        l_cdt_rec.qcl_id,
        l_cdt_rec.cgp_new_id,
        l_cdt_rec.cgp_renew_id,
        l_cdt_rec.price_list_id1,
        l_cdt_rec.price_list_id2,
        l_cdt_rec.renewal_type,
        l_cdt_rec.po_required_yn,
        l_cdt_rec.renewal_pricing_type,
        l_cdt_rec.markup_percent,
        l_cdt_rec.rle_code,
        l_cdt_rec.start_date,
        l_cdt_rec.end_date,
        --l_cdt_rec.security_group_id,
        l_cdt_rec.revenue_estimated_percent,
        l_cdt_rec.revenue_estimated_duration,
        l_cdt_rec.revenue_estimated_period,
        l_cdt_rec.template_set_id,
        l_cdt_rec.THRESHOLD_CURRENCY,
        l_cdt_rec.THRESHOLD_AMOUNT,
        l_cdt_rec.EMAIL_ADDRESS,
        l_cdt_rec.BILLING_PROFILE_ID,
        l_cdt_rec.USER_ID,
        l_cdt_rec.THRESHOLD_ENABLED_YN,
        l_cdt_rec.GRACE_PERIOD,
        l_cdt_rec.GRACE_DURATION,
        l_cdt_rec.PAYMENT_TERMS_ID1,
        l_cdt_rec.PAYMENT_TERMS_ID2,
        l_cdt_rec.EVERGREEN_THRESHOLD_CURR,
        l_cdt_rec.EVERGREEN_THRESHOLD_AMT,
        l_cdt_rec.PAYMENT_METHOD,
        l_cdt_rec.PAYMENT_THRESHOLD_CURR,
        l_cdt_rec.PAYMENT_THRESHOLD_AMT,
        l_cdt_rec.INTERFACE_PRICE_BREAK,
        l_cdt_rec.CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start
        l_cdt_rec.BASE_CURRENCY	,
        l_cdt_rec.APPROVAL_TYPE	,
        l_cdt_rec.EVERGREEN_APPROVAL_TYPE	,
        l_cdt_rec.ONLINE_APPROVAL_TYPE	,
        l_cdt_rec.PURCHASE_ORDER_FLAG	,
        l_cdt_rec.CREDIT_CARD_FLAG	,
        l_cdt_rec.WIRE_FLAG	,
        l_cdt_rec.COMMITMENT_NUMBER_FLAG	,
        l_cdt_rec.CHECK_FLAG	,
        l_cdt_rec.PERIOD_TYPE	,
        l_cdt_rec.PERIOD_START	,
        l_cdt_rec.PRICE_UOM	,
        l_cdt_rec.TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_cdt_rec := l_cdt_rec;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------
  -- insert_row for:OKS_K_DEFAULTS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdtv_rec                     cdtv_rec_type;
    l_def_cdtv_rec                 cdtv_rec_type;
    l_cdt_rec                      cdt_rec_type;
    lx_cdt_rec                     cdt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cdtv_rec	IN cdtv_rec_type
    ) RETURN cdtv_rec_type IS
      l_cdtv_rec	cdtv_rec_type := p_cdtv_rec;
    BEGIN
      l_cdtv_rec.CREATION_DATE := SYSDATE;
      l_cdtv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cdtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cdtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_cdtv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKS_K_DEFAULTS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cdtv_rec IN  cdtv_rec_type,
      x_cdtv_rec OUT NOCOPY cdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdtv_rec := p_cdtv_rec;
      x_cdtv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_cdtv_rec := null_out_defaults(p_cdtv_rec);
    -- Set primary key value
    l_cdtv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cdtv_rec,                        -- IN
      l_def_cdtv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cdtv_rec := fill_who_columns(l_def_cdtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cdtv_rec, l_cdt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cdt_rec,
      lx_cdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cdt_rec, l_def_cdtv_rec);
    -- Set OUT values
    x_cdtv_rec := l_def_cdtv_rec;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:CDTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cdtv_tbl.COUNT > 0) THEN
      i := p_cdtv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cdtv_rec                     => p_cdtv_tbl(i),
          x_cdtv_rec                     => x_cdtv_tbl(i));
        EXIT WHEN (i = p_cdtv_tbl.LAST);
        i := p_cdtv_tbl.NEXT(i);
      END LOOP;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------
  -- lock_row for:OKS_K_DEFAULTS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdt_rec                      IN cdt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cdt_rec IN cdt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_DEFAULTS
     WHERE ID = p_cdt_rec.id
       AND OBJECT_VERSION_NUMBER = p_cdt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cdt_rec IN cdt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_DEFAULTS
    WHERE ID = p_cdt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFAULTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_K_DEFAULTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_K_DEFAULTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cdt_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cdt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cdt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cdt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------
  -- lock_row for:OKS_K_DEFAULTS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdt_rec                      cdt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_cdtv_rec, l_cdt_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:CDTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cdtv_tbl.COUNT > 0) THEN
      i := p_cdtv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cdtv_rec                     => p_cdtv_tbl(i));
        EXIT WHEN (i = p_cdtv_tbl.LAST);
        i := p_cdtv_tbl.NEXT(i);
      END LOOP;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- update_row for:OKS_K_DEFAULTS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdt_rec                      IN cdt_rec_type,
    x_cdt_rec                      OUT NOCOPY cdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFAULTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdt_rec                      cdt_rec_type := p_cdt_rec;
    l_def_cdt_rec                  cdt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cdt_rec	IN cdt_rec_type,
      x_cdt_rec	OUT NOCOPY cdt_rec_type
    ) RETURN VARCHAR2 IS
      l_cdt_rec                      cdt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdt_rec := p_cdt_rec;
      -- Get current database values
      l_cdt_rec := get_rec(p_cdt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cdt_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.id := l_cdt_rec.id;
      END IF;
      IF (x_cdt_rec.cdt_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.cdt_type := l_cdt_rec.cdt_type;
      END IF;
      IF (x_cdt_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.object_version_number := l_cdt_rec.object_version_number;
      END IF;
      IF (x_cdt_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.created_by := l_cdt_rec.created_by;
      END IF;
      IF (x_cdt_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdt_rec.creation_date := l_cdt_rec.creation_date;
      END IF;
      IF (x_cdt_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.last_updated_by := l_cdt_rec.last_updated_by;
      END IF;
      IF (x_cdt_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdt_rec.last_update_date := l_cdt_rec.last_update_date;
      END IF;
      IF (x_cdt_rec.segment_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.segment_id1 := l_cdt_rec.segment_id1;
      END IF;
      IF (x_cdt_rec.segment_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.segment_id2 := l_cdt_rec.segment_id2;
      END IF;
      IF (x_cdt_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.jtot_object_code := l_cdt_rec.jtot_object_code;
      END IF;
      IF (x_cdt_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.pdf_id := l_cdt_rec.pdf_id;
      END IF;
      IF (x_cdt_rec.qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.qcl_id := l_cdt_rec.qcl_id;
      END IF;
      IF (x_cdt_rec.cgp_new_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.cgp_new_id := l_cdt_rec.cgp_new_id;
      END IF;
      IF (x_cdt_rec.cgp_renew_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.cgp_renew_id := l_cdt_rec.cgp_renew_id;
      END IF;
      IF (x_cdt_rec.price_list_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.price_list_id1 := l_cdt_rec.price_list_id1;
      END IF;
      IF (x_cdt_rec.price_list_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.price_list_id2 := l_cdt_rec.price_list_id2;
      END IF;
      IF (x_cdt_rec.renewal_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.renewal_type := l_cdt_rec.renewal_type;
      END IF;
      IF (x_cdt_rec.po_required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.po_required_yn := l_cdt_rec.po_required_yn;
      END IF;
      IF (x_cdt_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.renewal_pricing_type := l_cdt_rec.renewal_pricing_type;
      END IF;
      IF (x_cdt_rec.markup_percent = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.markup_percent := l_cdt_rec.markup_percent;
      END IF;
      IF (x_cdt_rec.rle_code= OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.rle_code:= l_cdt_rec.rle_code;
      END IF;
      IF (x_cdt_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdt_rec.start_date := l_cdt_rec.start_date;
      END IF;
      IF (x_cdt_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdt_rec.end_date := l_cdt_rec.end_date;
      END IF;

/*
      IF (x_cdt_rec.security_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.security_group_id := l_cdt_rec.security_group_id;
      END IF;
*/

      IF (x_cdt_rec.revenue_estimated_percent = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.revenue_estimated_percent := l_cdt_rec.revenue_estimated_percent;
      END IF;
      IF (x_cdt_rec.revenue_estimated_duration = OKC_API.G_MISS_NUM)
      THEN
        x_cdt_rec.revenue_estimated_duration := l_cdt_rec.revenue_estimated_duration;
      END IF;
      IF (x_cdt_rec.revenue_estimated_period = OKC_API.G_MISS_CHAR)
      THEN
        x_cdt_rec.revenue_estimated_period := l_cdt_rec.revenue_estimated_period;
      END IF;
      IF (x_cdt_rec.template_set_id = OKC_API.G_MISS_NUM)
        THEN
          x_cdt_rec.template_set_id := l_cdt_rec.template_set_id;
      END IF;
      IF (x_cdt_rec.THRESHOLD_CURRENCY = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.THRESHOLD_CURRENCY := NULL;
      END IF;
      IF (x_cdt_rec.THRESHOLD_AMOUNT = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.THRESHOLD_AMOUNT := NULL;
      END IF;
      IF (x_cdt_rec.EMAIL_ADDRESS = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.EMAIL_ADDRESS := NULL;
      END IF;
      IF (x_cdt_rec.BILLING_PROFILE_ID = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.BILLING_PROFILE_ID := NULL;
      END IF;
      IF (x_cdt_rec.USER_ID = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.USER_ID := NULL;
      END IF;
      IF (x_cdt_rec.THRESHOLD_ENABLED_YN = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.THRESHOLD_ENABLED_YN := NULL;
      END IF;
      IF (x_cdt_rec.GRACE_PERIOD = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.GRACE_PERIOD := NULL;
      END IF;
      IF (x_cdt_rec.GRACE_DURATION = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.GRACE_DURATION := NULL;
      END IF;
      IF (x_cdt_rec.PAYMENT_TERMS_ID1 = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PAYMENT_TERMS_ID1 := NULL;
      END IF;
      IF (x_cdt_rec.PAYMENT_TERMS_ID2 = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PAYMENT_TERMS_ID2 := NULL;
      END IF;
      IF (x_cdt_rec.EVERGREEN_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.EVERGREEN_THRESHOLD_CURR := NULL;
      END IF;
      IF (x_cdt_rec.EVERGREEN_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.EVERGREEN_THRESHOLD_AMT := NULL;
      END IF;
      IF (x_cdt_rec.PAYMENT_METHOD = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PAYMENT_METHOD := NULL;
      END IF;
      IF (x_cdt_rec.PAYMENT_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PAYMENT_THRESHOLD_CURR := NULL;
      END IF;
      IF (x_cdt_rec.PAYMENT_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
          x_cdt_rec.PAYMENT_THRESHOLD_AMT := NULL;
      END IF;
      IF (x_cdt_rec.INTERFACE_PRICE_BREAK = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.INTERFACE_PRICE_BREAK := NULL;
      END IF;
      IF (x_cdt_rec.CREDIT_AMOUNT = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.CREDIT_AMOUNT := NULL;
      END IF;

-- R12 Data Model Changes 4485150 Start
      IF (x_cdt_rec.BASE_CURRENCY = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.BASE_CURRENCY := NULL;
      END IF;
      IF (x_cdt_rec.APPROVAL_TYPE  = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.APPROVAL_TYPE := NULL;
      END IF;
      IF (x_cdt_rec.EVERGREEN_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.EVERGREEN_APPROVAL_TYPE := NULL;
      END IF;
      IF (x_cdt_rec.ONLINE_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.ONLINE_APPROVAL_TYPE := NULL;
      END IF;
      IF (x_cdt_rec.PURCHASE_ORDER_FLAG  = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PURCHASE_ORDER_FLAG := NULL;
      END IF;
      IF (x_cdt_rec.CREDIT_CARD_FLAG = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.CREDIT_CARD_FLAG := NULL;
      END IF;
      IF (x_cdt_rec.WIRE_FLAG = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.WIRE_FLAG := NULL;
      END IF;
      IF (x_cdt_rec.COMMITMENT_NUMBER_FLAG  = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.COMMITMENT_NUMBER_FLAG := NULL;
      END IF;
      IF (x_cdt_rec.CHECK_FLAG = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.CHECK_FLAG := NULL;
      END IF;
      IF (x_cdt_rec.PERIOD_TYPE = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PERIOD_TYPE := NULL;
      END IF;
      IF (x_cdt_rec.PERIOD_START  = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PERIOD_START := NULL;
      END IF;
      IF (x_cdt_rec.PRICE_UOM = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.PRICE_UOM := NULL;
      END IF;
      IF (x_cdt_rec.TEMPLATE_LANGUAGE = OKC_API.G_MISS_CHAR) THEN
          x_cdt_rec.TEMPLATE_LANGUAGE := NULL;
      END IF;

-- R12 Data Model Changes 4485150 End
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKS_K_DEFAULTS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_cdt_rec IN  cdt_rec_type,
      x_cdt_rec OUT NOCOPY cdt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdt_rec := p_cdt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cdt_rec,                         -- IN
      l_cdt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cdt_rec, l_def_cdt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_K_DEFAULTS
    SET CDT_TYPE = l_def_cdt_rec.cdt_type,
        OBJECT_VERSION_NUMBER = l_def_cdt_rec.object_version_number,
        CREATED_BY = l_def_cdt_rec.created_by,
        CREATION_DATE = l_def_cdt_rec.creation_date,
        LAST_UPDATED_BY = l_def_cdt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cdt_rec.last_update_date,
        SEGMENT_ID1 = l_def_cdt_rec.segment_id1,
        SEGMENT_ID2 = l_def_cdt_rec.segment_id2,
        JTOT_OBJECT_CODE = l_def_cdt_rec.jtot_object_code,
        PDF_ID = l_def_cdt_rec.pdf_id,
        QCL_ID = l_def_cdt_rec.qcl_id,
        CGP_NEW_ID = l_def_cdt_rec.cgp_new_id,
        CGP_RENEW_ID = l_def_cdt_rec.cgp_renew_id,
        PRICE_LIST_ID1 = l_def_cdt_rec.price_list_id1,
        PRICE_LIST_ID2 = l_def_cdt_rec.price_list_id2,
        RENEWAL_TYPE = l_def_cdt_rec.renewal_type,
        PO_REQUIRED_YN = l_def_cdt_rec.po_required_yn,
        RENEWAL_PRICING_TYPE = l_def_cdt_rec.renewal_pricing_type,
        MARKUP_PERCENT = l_def_cdt_rec.markup_percent,
        RLE_CODE= l_def_cdt_rec.rle_code,
        START_DATE = l_def_cdt_rec.start_date,
        END_DATE = l_def_cdt_rec.end_date,
        --SECURITY_GROUP_ID = l_def_cdt_rec.security_group_id,
        REVENUE_ESTIMATED_PERCENT = l_def_cdt_rec.revenue_estimated_percent,
        REVENUE_ESTIMATED_DURATION = l_def_cdt_rec.revenue_estimated_duration,
        REVENUE_ESTIMATED_PERIOD = l_def_cdt_rec.revenue_estimated_period,
        TEMPLATE_SET_ID = l_def_cdt_rec.template_set_id,
        THRESHOLD_CURRENCY = l_def_cdt_rec.THRESHOLD_CURRENCY,
        THRESHOLD_AMOUNT = l_def_cdt_rec.THRESHOLD_AMOUNT,
        EMAIL_ADDRESS = l_def_cdt_rec.EMAIL_ADDRESS,
        BILLING_PROFILE_ID = l_def_cdt_rec.BILLING_PROFILE_ID,
        USER_ID = l_def_cdt_rec.USER_ID,
        THRESHOLD_ENABLED_YN = l_def_cdt_rec.THRESHOLD_ENABLED_YN,
        GRACE_PERIOD = l_def_cdt_rec.GRACE_PERIOD,
        GRACE_DURATION = l_def_cdt_rec.GRACE_DURATION,
        PAYMENT_TERMS_ID1 = l_def_cdt_rec.PAYMENT_TERMS_ID1,
        PAYMENT_TERMS_ID2 = l_def_cdt_rec.PAYMENT_TERMS_ID2,
        EVERGREEN_THRESHOLD_CURR = l_def_cdt_rec.EVERGREEN_THRESHOLD_CURR,
        EVERGREEN_THRESHOLD_AMT = l_def_cdt_rec.EVERGREEN_THRESHOLD_AMT,
        PAYMENT_METHOD = l_def_cdt_rec.PAYMENT_METHOD,
        PAYMENT_THRESHOLD_CURR = l_def_cdt_rec.PAYMENT_THRESHOLD_CURR,
        PAYMENT_THRESHOLD_AMT = l_def_cdt_rec.PAYMENT_THRESHOLD_AMT,
        INTERFACE_PRICE_BREAK = l_def_cdt_rec.INTERFACE_PRICE_BREAK,
        CREDIT_AMOUNT = l_def_cdt_rec.CREDIT_AMOUNT,
-- R12 Data Model Changes 4485150 Start
        BASE_CURRENCY = l_def_cdt_rec.BASE_CURRENCY,
        APPROVAL_TYPE = l_def_cdt_rec.APPROVAL_TYPE,
        EVERGREEN_APPROVAL_TYPE	= l_def_cdt_rec.EVERGREEN_APPROVAL_TYPE,
        ONLINE_APPROVAL_TYPE	= l_def_cdt_rec.ONLINE_APPROVAL_TYPE,
        PURCHASE_ORDER_FLAG	= l_def_cdt_rec.PURCHASE_ORDER_FLAG,
        CREDIT_CARD_FLAG	= l_def_cdt_rec.CREDIT_CARD_FLAG,
        WIRE_FLAG	= l_def_cdt_rec.WIRE_FLAG,
        COMMITMENT_NUMBER_FLAG	= l_def_cdt_rec.COMMITMENT_NUMBER_FLAG,
        CHECK_FLAG	= l_def_cdt_rec.CHECK_FLAG,
        PERIOD_TYPE	= l_def_cdt_rec.PERIOD_TYPE,
        PERIOD_START	= l_def_cdt_rec.PERIOD_START,
        PRICE_UOM	= l_def_cdt_rec.PRICE_UOM,
        TEMPLATE_LANGUAGE	= l_def_cdt_rec.TEMPLATE_LANGUAGE
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_cdt_rec.id;

    x_cdt_rec := l_def_cdt_rec;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------
  -- update_row for:OKS_K_DEFAULTS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdtv_rec                     cdtv_rec_type := p_cdtv_rec;
    l_def_cdtv_rec                 cdtv_rec_type;
    l_cdt_rec                      cdt_rec_type;
    lx_cdt_rec                     cdt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cdtv_rec	IN cdtv_rec_type
    ) RETURN cdtv_rec_type IS
      l_cdtv_rec	cdtv_rec_type := p_cdtv_rec;
    BEGIN
      l_cdtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cdtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_cdtv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cdtv_rec	IN cdtv_rec_type,
      x_cdtv_rec	OUT NOCOPY cdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_cdtv_rec                     cdtv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdtv_rec := p_cdtv_rec;
      -- Get current database values
      l_cdtv_rec := get_rec(p_cdtv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cdtv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.id := l_cdtv_rec.id;
      END IF;
      IF (x_cdtv_rec.cdt_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.cdt_type := l_cdtv_rec.cdt_type;
      END IF;
      IF (x_cdtv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.object_version_number := l_cdtv_rec.object_version_number;
      END IF;
      IF (x_cdtv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.created_by := l_cdtv_rec.created_by;
      END IF;
      IF (x_cdtv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdtv_rec.creation_date := l_cdtv_rec.creation_date;
      END IF;
      IF (x_cdtv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.last_updated_by := l_cdtv_rec.last_updated_by;
      END IF;
      IF (x_cdtv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdtv_rec.last_update_date := l_cdtv_rec.last_update_date;
      END IF;
      IF (x_cdtv_rec.segment_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.segment_id1 := l_cdtv_rec.segment_id1;
      END IF;
      IF (x_cdtv_rec.segment_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.segment_id2 := l_cdtv_rec.segment_id2;
      END IF;
      IF (x_cdtv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.jtot_object_code := l_cdtv_rec.jtot_object_code;
      END IF;
      IF (x_cdtv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.pdf_id := l_cdtv_rec.pdf_id;
      END IF;
      IF (x_cdtv_rec.qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.qcl_id := l_cdtv_rec.qcl_id;
      END IF;
      IF (x_cdtv_rec.cgp_new_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.cgp_new_id := l_cdtv_rec.cgp_new_id;
      END IF;
      IF (x_cdtv_rec.cgp_renew_id = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.cgp_renew_id := l_cdtv_rec.cgp_renew_id;
      END IF;
      IF (x_cdtv_rec.price_list_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.price_list_id1 := l_cdtv_rec.price_list_id1;
      END IF;
      IF (x_cdtv_rec.price_list_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.price_list_id2 := l_cdtv_rec.price_list_id2;
      END IF;
      IF (x_cdtv_rec.renewal_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.renewal_type := l_cdtv_rec.renewal_type;
      END IF;
      IF (x_cdtv_rec.po_required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.po_required_yn := l_cdtv_rec.po_required_yn;
      END IF;
      IF (x_cdtv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.renewal_pricing_type := l_cdtv_rec.renewal_pricing_type;
      END IF;
      IF (x_cdtv_rec.markup_percent = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.markup_percent := l_cdtv_rec.markup_percent;
      END IF;
      IF (x_cdtv_rec.rle_code= OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.rle_code:= l_cdtv_rec.rle_code;
      END IF;
      IF (x_cdtv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdtv_rec.start_date := l_cdtv_rec.start_date;
      END IF;
      IF (x_cdtv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_cdtv_rec.end_date := l_cdtv_rec.end_date;
      END IF;
      IF (x_cdtv_rec.revenue_estimated_percent = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.revenue_estimated_percent := l_cdtv_rec.revenue_estimated_percent;
      END IF;
      IF (x_cdtv_rec.revenue_estimated_duration = OKC_API.G_MISS_NUM)
      THEN
        x_cdtv_rec.revenue_estimated_duration := l_cdtv_rec.revenue_estimated_duration;
      END IF;
      IF (x_cdtv_rec.revenue_estimated_period = OKC_API.G_MISS_CHAR)
      THEN
        x_cdtv_rec.revenue_estimated_period := l_cdtv_rec.revenue_estimated_period;
      END IF;
      IF (x_cdtv_rec.template_set_id = OKC_API.G_MISS_NUM)
      THEN
          x_cdtv_rec.template_set_id := l_cdtv_rec.template_set_id;
      END IF;
      IF (x_cdtv_rec.THRESHOLD_CURRENCY = OKC_API.G_MISS_CHAR) THEN
          x_cdtv_rec.THRESHOLD_CURRENCY := l_cdtv_rec.THRESHOLD_CURRENCY;
    END IF;
    IF (x_cdtv_rec.THRESHOLD_AMOUNT = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.THRESHOLD_AMOUNT := l_cdtv_rec.THRESHOLD_AMOUNT;
    END IF;
    IF (x_cdtv_rec.EMAIL_ADDRESS = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.EMAIL_ADDRESS := l_cdtv_rec.EMAIL_ADDRESS;
    END IF;
    IF (x_cdtv_rec.BILLING_PROFILE_ID = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.BILLING_PROFILE_ID := l_cdtv_rec.BILLING_PROFILE_ID;
    END IF;
    IF (x_cdtv_rec.USER_ID = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.USER_ID := l_cdtv_rec.USER_ID;
    END IF;
    IF (x_cdtv_rec.THRESHOLD_ENABLED_YN = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.THRESHOLD_ENABLED_YN := l_cdtv_rec.THRESHOLD_ENABLED_YN;
    END IF;
    IF (x_cdtv_rec.GRACE_PERIOD = OKC_API.G_MISS_CHAR) THEN
       x_cdtv_rec.GRACE_PERIOD := l_cdtv_rec.GRACE_PERIOD;
    END IF;
    IF (x_cdtv_rec.GRACE_DURATION = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.GRACE_DURATION := l_cdtv_rec.GRACE_DURATION;
    END IF;
    IF (x_cdtv_rec.PAYMENT_TERMS_ID1 = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PAYMENT_TERMS_ID1 := l_cdtv_rec.PAYMENT_TERMS_ID1;
    END IF;
    IF (x_cdtv_rec.PAYMENT_TERMS_ID2 = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PAYMENT_TERMS_ID2 := l_cdtv_rec.PAYMENT_TERMS_ID1;
    END IF;
    IF (x_cdtv_rec.EVERGREEN_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.EVERGREEN_THRESHOLD_CURR := l_cdtv_rec.EVERGREEN_THRESHOLD_CURR;
    END IF;
    IF (x_cdtv_rec.EVERGREEN_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.EVERGREEN_THRESHOLD_AMT := l_cdtv_rec.EVERGREEN_THRESHOLD_AMT;
    END IF;
    IF (x_cdtv_rec.PAYMENT_METHOD = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PAYMENT_METHOD := l_cdtv_rec.PAYMENT_METHOD;
    END IF;
    IF (x_cdtv_rec.PAYMENT_THRESHOLD_CURR = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PAYMENT_THRESHOLD_CURR := l_cdtv_rec.PAYMENT_THRESHOLD_CURR;
    END IF;
    IF (x_cdtv_rec.PAYMENT_THRESHOLD_AMT = OKC_API.G_MISS_NUM) THEN
        x_cdtv_rec.PAYMENT_THRESHOLD_AMT := l_cdtv_rec.PAYMENT_THRESHOLD_AMT;
    END IF;
    IF (x_cdtv_rec.INTERFACE_PRICE_BREAK = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.INTERFACE_PRICE_BREAK := l_cdtv_rec.INTERFACE_PRICE_BREAK;
    END IF;
    IF (x_cdtv_rec.CREDIT_AMOUNT = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.CREDIT_AMOUNT := l_cdtv_rec.CREDIT_AMOUNT;
    END IF;
-- R12 Data Model Changes 4485150 Start  /* mmadhavi 4485150 : add other columns */
    IF (x_cdtv_rec.PERIOD_TYPE = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PERIOD_TYPE := l_cdtv_rec.PERIOD_TYPE;
    END IF;
    IF (x_cdtv_rec.PERIOD_START= OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PERIOD_START := l_cdtv_rec.PERIOD_START;
    END IF;
    IF (x_cdtv_rec.PRICE_UOM = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PRICE_UOM := l_cdtv_rec.PRICE_UOM;
    END IF;
    IF (x_cdtv_rec.BASE_CURRENCY = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.BASE_CURRENCY := l_cdtv_rec.BASE_CURRENCY;
    END IF;
    IF (x_cdtv_rec.APPROVAL_TYPE= OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.APPROVAL_TYPE := l_cdtv_rec.APPROVAL_TYPE;
    END IF;
    IF (x_cdtv_rec.EVERGREEN_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.EVERGREEN_APPROVAL_TYPE := l_cdtv_rec.EVERGREEN_APPROVAL_TYPE;
    END IF;
    IF (x_cdtv_rec.ONLINE_APPROVAL_TYPE = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.ONLINE_APPROVAL_TYPE := l_cdtv_rec.ONLINE_APPROVAL_TYPE;
    END IF;
    IF (x_cdtv_rec.PURCHASE_ORDER_FLAG= OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.PURCHASE_ORDER_FLAG := l_cdtv_rec.PURCHASE_ORDER_FLAG;
    END IF;
    IF (x_cdtv_rec.CREDIT_CARD_FLAG = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.CREDIT_CARD_FLAG := l_cdtv_rec.CREDIT_CARD_FLAG;
    END IF;
    IF (x_cdtv_rec.WIRE_FLAG = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.WIRE_FLAG := l_cdtv_rec.WIRE_FLAG;
    END IF;
    IF (x_cdtv_rec.COMMITMENT_NUMBER_FLAG= OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.COMMITMENT_NUMBER_FLAG := l_cdtv_rec.COMMITMENT_NUMBER_FLAG;
    END IF;
    IF (x_cdtv_rec.CHECK_FLAG = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.CHECK_FLAG := l_cdtv_rec.CHECK_FLAG;
    END IF;
    IF (x_cdtv_rec.TEMPLATE_LANGUAGE = OKC_API.G_MISS_CHAR) THEN
        x_cdtv_rec.TEMPLATE_LANGUAGE := l_cdtv_rec.TEMPLATE_LANGUAGE;
    END IF;
-- R12 Data Model Changes 4485150 End

      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKS_K_DEFAULTS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cdtv_rec IN  cdtv_rec_type,
      x_cdtv_rec OUT NOCOPY cdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cdtv_rec := p_cdtv_rec;
      x_cdtv_rec.OBJECT_VERSION_NUMBER := NVL(x_cdtv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cdtv_rec,                        -- IN
      l_cdtv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cdtv_rec, l_def_cdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cdtv_rec := fill_who_columns(l_def_cdtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cdtv_rec, l_cdt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cdt_rec,
      lx_cdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cdt_rec, l_def_cdtv_rec);
    x_cdtv_rec := l_def_cdtv_rec;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:CDTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cdtv_tbl.COUNT > 0) THEN
      i := p_cdtv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cdtv_rec                     => p_cdtv_tbl(i),
          x_cdtv_rec                     => x_cdtv_tbl(i));
        EXIT WHEN (i = p_cdtv_tbl.LAST);
        i := p_cdtv_tbl.NEXT(i);
      END LOOP;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- delete_row for:OKS_K_DEFAULTS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdt_rec                      IN cdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DEFAULTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdt_rec                      cdt_rec_type:= p_cdt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKS_K_DEFAULTS
     WHERE ID = l_cdt_rec.id;

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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------
  -- delete_row for:OKS_K_DEFAULTS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cdtv_rec                     cdtv_rec_type := p_cdtv_rec;
    l_cdt_rec                      cdt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cdtv_rec, l_cdt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:CDTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cdtv_tbl.COUNT > 0) THEN
      i := p_cdtv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cdtv_rec                     => p_cdtv_tbl(i));
        EXIT WHEN (i = p_cdtv_tbl.LAST);
        i := p_cdtv_tbl.NEXT(i);
      END LOOP;
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
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKS_CDT_PVT;

/

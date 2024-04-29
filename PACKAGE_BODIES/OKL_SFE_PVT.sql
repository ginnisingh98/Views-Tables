--------------------------------------------------------
--  DDL for Package Body OKL_SFE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SFE_PVT" AS
/* $Header: OKLSSFEB.pls 120.5.12010000.3 2009/07/21 00:26:36 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

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
  -- FUNCTION get_rec for: OKL_SIF_FEES

  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sfe_rec                      IN sfe_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sfe_rec_type IS
    CURSOR sfe_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SFE_TYPE,
            DATE_START,
            DATE_PAID,
            AMOUNT,
            IDC_ACCOUNTING_FLAG,
            INCOME_OR_EXPENSE,
            DESCRIPTION,
            FEE_INDEX_NUMBER,
            LEVEL_INDEX_NUMBER,
            ADVANCE_OR_ARREARS,
            LEVEL_TYPE,
            LOCK_LEVEL_STEP,
            PERIOD,
            NUMBER_OF_PERIODS,
            LEVEL_LINE_NUMBER,
            SIF_ID,
            KLE_ID,
            SIL_ID,
       	    RATE,
       	    -- mvasudev, 05/13/2002
       	    QUERY_LEVEL_YN,
       	    STRUCTURE,
       	    DAYS_IN_PERIOD,
       	    --
       	    cash_effect_yn,
       	    tax_effect_yn,
            days_in_month,
            days_in_year,
            balance_type_code,
            OBJECT_VERSION_NUMBER,
            STREAM_INTERFACE_ATTRIBUTE01,
            STREAM_INTERFACE_ATTRIBUTE02,
            STREAM_INTERFACE_ATTRIBUTE03,
            STREAM_INTERFACE_ATTRIBUTE04,
            STREAM_INTERFACE_ATTRIBUTE05,
            STREAM_INTERFACE_ATTRIBUTE06,
            STREAM_INTERFACE_ATTRIBUTE07,
            STREAM_INTERFACE_ATTRIBUTE08,
            STREAM_INTERFACE_ATTRIBUTE09,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE13,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE15,
            STREAM_INTERFACE_ATTRIBUTE16,
            STREAM_INTERFACE_ATTRIBUTE17,
            STREAM_INTERFACE_ATTRIBUTE18,
            STREAM_INTERFACE_ATTRIBUTE19,
            STREAM_INTERFACE_ATTRIBUTE20,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            DOWN_PAYMENT_AMOUNT,
            orig_contract_line_id
      FROM Okl_Sif_Fees
     WHERE okl_sif_fees.id      = p_id;
    l_sfe_pk                       sfe_pk_csr%ROWTYPE;
    l_sfe_rec                      sfe_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sfe_pk_csr (p_sfe_rec.id);
    FETCH sfe_pk_csr INTO
              l_sfe_rec.ID,
              l_sfe_rec.SFE_TYPE,
              l_sfe_rec.DATE_START,
              l_sfe_rec.DATE_PAID,
              l_sfe_rec.AMOUNT,
              l_sfe_rec.IDC_ACCOUNTING_FLAG,
              l_sfe_rec.INCOME_OR_EXPENSE,
              l_sfe_rec.DESCRIPTION,
              l_sfe_rec.FEE_INDEX_NUMBER,
              l_sfe_rec.LEVEL_INDEX_NUMBER,
              l_sfe_rec.ADVANCE_OR_ARREARS,
              l_sfe_rec.LEVEL_TYPE,
              l_sfe_rec.LOCK_LEVEL_STEP,
              l_sfe_rec.PERIOD,
              l_sfe_rec.NUMBER_OF_PERIODS,
              l_sfe_rec.LEVEL_LINE_NUMBER,
              l_sfe_rec.SIF_ID,
              l_sfe_rec.KLE_ID,
              l_sfe_rec.SIL_ID,
              l_sfe_rec.RATE,
              -- mvasudev, 05/13/2002
              l_sfe_rec.QUERY_LEVEL_YN,
              l_sfe_rec.STRUCTURE,
              l_sfe_rec.DAYS_IN_PERIOD,
              --
              l_sfe_rec.OBJECT_VERSION_NUMBER,
              l_sfe_rec.cash_effect_yn,
              l_sfe_rec.tax_effect_yn,
              l_sfe_rec.days_in_month,
              l_sfe_rec.days_in_year,
              l_sfe_rec.balance_type_code    ,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE01,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE02,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE03,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE04,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE05,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE06,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE07,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE08,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE09,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE10,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE11,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE12,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE13,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE14,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE16,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE17,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE18,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE19,
              l_sfe_rec.STREAM_INTERFACE_ATTRIBUTE20,
              l_sfe_rec.CREATED_BY,
              l_sfe_rec.LAST_UPDATED_BY,
              l_sfe_rec.CREATION_DATE,
              l_sfe_rec.LAST_UPDATE_DATE,
              l_sfe_rec.LAST_UPDATE_LOGIN,
              l_sfe_rec.DOWN_PAYMENT_AMOUNT,
			  l_sfe_rec.orig_contract_line_id;
    x_no_data_found := sfe_pk_csr%NOTFOUND;
    CLOSE sfe_pk_csr;
    RETURN(l_sfe_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sfe_rec                      IN sfe_rec_type
  ) RETURN sfe_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sfe_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_FEES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sfev_rec                     IN sfev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sfev_rec_type IS
    CURSOR sfev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SFE_TYPE,
            DATE_START,
            DATE_PAID,
            AMOUNT,
            IDC_ACCOUNTING_FLAG,
            INCOME_OR_EXPENSE,
            DESCRIPTION,
            FEE_INDEX_NUMBER,
            LEVEL_INDEX_NUMBER,
            ADVANCE_OR_ARREARS,
            LEVEL_TYPE,
            LOCK_LEVEL_STEP,
            PERIOD,
            NUMBER_OF_PERIODS,
            LEVEL_LINE_NUMBER,
            SIF_ID,
            KLE_ID,
            SIL_ID,
            RATE,
            -- mvasudev, 05/13/2002
            QUERY_LEVEL_YN,
            STRUCTURE,
            DAYS_IN_PERIOD,
            --
            OBJECT_VERSION_NUMBER,
       	    cash_effect_yn,
            tax_effect_yn,
            days_in_month,
            days_in_year,
            balance_type_code    ,
            STREAM_INTERFACE_ATTRIBUTE01,
            STREAM_INTERFACE_ATTRIBUTE02,
            STREAM_INTERFACE_ATTRIBUTE03,
            STREAM_INTERFACE_ATTRIBUTE04,
            STREAM_INTERFACE_ATTRIBUTE05,
            STREAM_INTERFACE_ATTRIBUTE06,
            STREAM_INTERFACE_ATTRIBUTE07,
            STREAM_INTERFACE_ATTRIBUTE08,
            STREAM_INTERFACE_ATTRIBUTE09,
            STREAM_INTERFACE_ATTRIBUTE10,
            STREAM_INTERFACE_ATTRIBUTE11,
            STREAM_INTERFACE_ATTRIBUTE12,
            STREAM_INTERFACE_ATTRIBUTE13,
            STREAM_INTERFACE_ATTRIBUTE14,
            STREAM_INTERFACE_ATTRIBUTE15,
            STREAM_INTERFACE_ATTRIBUTE16,
            STREAM_INTERFACE_ATTRIBUTE17,
            STREAM_INTERFACE_ATTRIBUTE18,
            STREAM_INTERFACE_ATTRIBUTE19,
            STREAM_INTERFACE_ATTRIBUTE20,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            DOWN_PAYMENT_AMOUNT,
            orig_contract_line_id
      FROM Okl_Sif_Fees_V
     WHERE okl_sif_fees_v.id    = p_id;
    l_sfev_pk                      sfev_pk_csr%ROWTYPE;
    l_sfev_rec                     sfev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sfev_pk_csr (p_sfev_rec.id);

    FETCH sfev_pk_csr INTO
              l_sfev_rec.ID,
              l_sfev_rec.SFE_TYPE,
              l_sfev_rec.DATE_START,
              l_sfev_rec.DATE_PAID,
              l_sfev_rec.AMOUNT,
              l_sfev_rec.IDC_ACCOUNTING_FLAG,
              l_sfev_rec.INCOME_OR_EXPENSE,
              l_sfev_rec.DESCRIPTION,
              l_sfev_rec.FEE_INDEX_NUMBER,
              l_sfev_rec.LEVEL_INDEX_NUMBER,
              l_sfev_rec.ADVANCE_OR_ARREARS,
              l_sfev_rec.LEVEL_TYPE,
              l_sfev_rec.LOCK_LEVEL_STEP,
              l_sfev_rec.PERIOD,
              l_sfev_rec.NUMBER_OF_PERIODS,
              l_sfev_rec.LEVEL_LINE_NUMBER,
              l_sfev_rec.SIF_ID,
              l_sfev_rec.KLE_ID,
              l_sfev_rec.SIL_ID,
              l_sfev_rec.RATE,
              -- mvasudev, 05/13/2002
              l_sfev_rec.QUERY_LEVEL_YN,
              l_sfev_rec.STRUCTURE,
              l_sfev_rec.DAYS_IN_PERIOD,
              --
              l_sfev_rec.OBJECT_VERSION_NUMBER,
              l_sfev_rec.cash_effect_yn,
       	      l_sfev_rec.tax_effect_yn,
              l_sfev_rec.days_in_month,
              l_sfev_rec.days_in_year,
              l_sfev_rec.balance_type_code    ,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE01,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE02,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE03,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE04,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE05,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE06,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE07,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE08,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE09,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE10,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE11,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE12,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE13,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE14,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE16,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE17,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE18,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE19,
              l_sfev_rec.STREAM_INTERFACE_ATTRIBUTE20,
              l_sfev_rec.CREATED_BY,
              l_sfev_rec.LAST_UPDATED_BY,
              l_sfev_rec.CREATION_DATE,
              l_sfev_rec.LAST_UPDATE_DATE,
              l_sfev_rec.LAST_UPDATE_LOGIN,
              l_sfev_rec.DOWN_PAYMENT_AMOUNT,
			  l_sfev_rec.orig_contract_line_id;
    x_no_data_found := sfev_pk_csr%NOTFOUND;
    CLOSE sfev_pk_csr;
    RETURN(l_sfev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sfev_rec                     IN sfev_rec_type
  ) RETURN sfev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sfev_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_FEES_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_sfev_rec	IN sfev_rec_type
  ) RETURN sfev_rec_type IS
    l_sfev_rec	sfev_rec_type := p_sfev_rec;
  BEGIN
    IF (l_sfev_rec.sfe_type = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.sfe_type := NULL;
    END IF;
    IF (l_sfev_rec.date_start = OKC_API.G_MISS_DATE) THEN
      l_sfev_rec.date_start := NULL;
    END IF;
    IF (l_sfev_rec.date_paid = OKC_API.G_MISS_DATE) THEN
      l_sfev_rec.date_paid := NULL;
    END IF;
    IF (l_sfev_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.amount := NULL;
    END IF;
    IF (l_sfev_rec.idc_accounting_flag = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.idc_accounting_flag := NULL;
    END IF;
    IF (l_sfev_rec.income_or_expense = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.income_or_expense := NULL;
    END IF;
    IF (l_sfev_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.description := NULL;
    END IF;
    IF (l_sfev_rec.fee_index_number = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.fee_index_number := NULL;
    END IF;
    IF (l_sfev_rec.level_index_number = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.level_index_number := NULL;

    END IF;
    IF (l_sfev_rec.advance_or_arrears = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.advance_or_arrears := NULL;
    END IF;

    IF (l_sfev_rec.cash_effect_yn = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.cash_effect_yn := NULL;
    END IF;

    IF (l_sfev_rec.tax_effect_yn = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.tax_effect_yn := NULL;
    END IF;

    IF (l_sfev_rec.days_in_month = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.days_in_month := NULL;
    END IF;

    IF (l_sfev_rec.days_in_year = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.days_in_year := NULL;
    END IF;

    IF (l_sfev_rec.balance_type_code = OKC_API.G_MISS_CHAR) THEN
        l_sfev_rec.balance_type_code := NULL;
    END IF;

    IF (l_sfev_rec.level_type = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.level_type := NULL;
    END IF;
    IF (l_sfev_rec.lock_level_step = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.lock_level_step := NULL;
    END IF;
    IF (l_sfev_rec.period = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.period := NULL;
    END IF;
    IF (l_sfev_rec.number_of_periods = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.number_of_periods := NULL;
    END IF;
    IF (l_sfev_rec.level_line_number = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.level_line_number := NULL;
    END IF;
    IF (l_sfev_rec.sif_id = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.sif_id := NULL;
    END IF;
    IF (l_sfev_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.kle_id := NULL;
    END IF;
    IF (l_sfev_rec.sil_id = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.sil_id := NULL;
    END IF;
    IF (l_sfev_rec.rate = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.rate := NULL;
    END IF;
    -- mvasudev, 05/13/2002
    IF (l_sfev_rec.query_level_yn = OKC_API.G_MISS_CHAR) THEN
          l_sfev_rec.query_level_yn := NULL;
    END IF;
    IF (l_sfev_rec.structure = OKC_API.G_MISS_CHAR) THEN
              l_sfev_rec.structure := NULL;
    END IF;
    IF (l_sfev_rec.DAYS_IN_PERIOD = OKC_API.G_MISS_NUM) THEN
              l_sfev_rec.DAYS_IN_PERIOD := NULL;
    END IF;
    --
    IF (l_sfev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.object_version_number := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute16 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute16 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute17 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute17 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute18 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute18 := NULL;
    END IF;

    IF (l_sfev_rec.stream_interface_attribute19 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute19 := NULL;
    END IF;
    IF (l_sfev_rec.stream_interface_attribute20 = OKC_API.G_MISS_CHAR) THEN
      l_sfev_rec.stream_interface_attribute20 := NULL;
    END IF;
    IF (l_sfev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.created_by := NULL;
    END IF;
    IF (l_sfev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.last_updated_by := NULL;
    END IF;
    IF (l_sfev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sfev_rec.creation_date := NULL;
    END IF;
    IF (l_sfev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sfev_rec.last_update_date := NULL;
    END IF;
    IF (l_sfev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.last_update_login := NULL;
    END IF;
    IF (l_sfev_rec.down_payment_amount = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.down_payment_amount := NULL;
    END IF;

    IF (l_sfev_rec.orig_contract_line_id = OKC_API.G_MISS_NUM) THEN
      l_sfev_rec.orig_contract_line_id := NULL;
    END IF;

    RETURN(l_sfev_rec);
  END null_out_defaults;

    -- START change : akjain , 09/05/2001
    /*
    -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_SIF_FEES_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_sfev_rec IN  sfev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sfev_rec.id = OKC_API.G_MISS_NUM OR
       p_sfev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.sfe_type = OKC_API.G_MISS_CHAR OR
          p_sfev_rec.sfe_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sfe_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.income_or_expense = OKC_API.G_MISS_CHAR OR
          p_sfev_rec.income_or_expense IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'income_or_expense');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.fee_index_number = OKC_API.G_MISS_NUM OR
          p_sfev_rec.fee_index_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fee_index_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.level_index_number = OKC_API.G_MISS_NUM OR
          p_sfev_rec.level_index_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'level_index_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.advance_or_arrears = OKC_API.G_MISS_CHAR OR
          p_sfev_rec.advance_or_arrears IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'advance_or_arrears');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.level_type = OKC_API.G_MISS_CHAR OR
          p_sfev_rec.level_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'level_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.period = OKC_API.G_MISS_CHAR OR
          p_sfev_rec.period IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'period');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.number_of_periods = OKC_API.G_MISS_NUM OR
          p_sfev_rec.number_of_periods IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'number_of_periods');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.level_line_number = OKC_API.G_MISS_NUM OR
          p_sfev_rec.level_line_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'level_line_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sfev_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sfev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  */

  -- END COMMENTED CODE akjain


  /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.id = Okc_Api.G_MISS_NUM OR
      p_sfev_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_sfev_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN

                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfe_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfe_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sfe_Type(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
    l_found VARCHAR2(1);
  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Sfe_Type = Okc_Api.G_MISS_CHAR OR
       p_sfev_rec.Sfe_Type IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sfe_Type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	--Check if Sfe_Type exists in the fnd_common_lookups or not
	l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_SFE_TYPE',
						    p_lookup_code => p_sfev_rec.Sfe_Type);


	IF (l_found <> OKL_API.G_TRUE ) THEN
     OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Sfe_Type');
	     x_return_status := Okc_Api.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;


    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sfe_Type;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Income_Or_Expense
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Income_Or_Expense
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Income_Or_Expense(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
--dbms_output.put_line('Validate_Income_Or_Expense value '||p_sfev_rec.Income_Or_Expense);
    IF p_sfev_rec.Income_Or_Expense = Okc_Api.G_MISS_CHAR OR
       p_sfev_rec.Income_Or_Expense IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Income_Or_Expense');
      x_return_status := Okc_Api.G_RET_STS_ERROR;

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Income_Or_Expense;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fee_Index_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fee_Index_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fee_Index_Number(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Fee_Index_Number = Okc_Api.G_MISS_NUM OR
       p_sfev_rec.Fee_Index_Number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Fee_Index_Number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fee_Index_Number;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Level_Index_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Level_Index_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Level_Index_Number(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Level_Index_Number = Okc_Api.G_MISS_NUM OR

       p_sfev_rec.Level_Index_Number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Level_Index_Number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Level_Index_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Advance_Or_Arrears
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Advance_Or_Arrears
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Advance_Or_Arrears(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
--dbms_output.put_line('Validate_Advance_Or_Arrears value '||p_sfev_rec.Advance_Or_Arrears);
    IF p_sfev_rec.Advance_Or_Arrears = Okc_Api.G_MISS_CHAR OR
       p_sfev_rec.Advance_Or_Arrears IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Advance_Or_Arrears');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Advance_Or_Arrears;

  /*
  -- mvasudev -- 02/21/2002
  -- Validation removed as LEVEL_TYPE is made NULLABLE.

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Level_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Level_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Level_Type(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
    l_found VARCHAR2(1);
  BEGIN


    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Level_Type = Okc_Api.G_MISS_CHAR OR
       p_sfev_rec.Level_type IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Level_type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
      /*
      -- UnComment this Code if an FND entity is created for this
    ELSE
	--Check if Level_type exists in the fnd_common_lookups or not
	l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_SFE_LEVEL',
						    p_lookup_code => p_sfev_rec.Level_type);


	IF (l_found <> OKL_API.G_TRUE ) THEN
     OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Level_type');
	     x_return_status := Okc_Api.G_RET_STS_ERROR;
		 -- raise the exception as there's no matching foreign key value
		 RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
	*
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Level_type;

  -- end,mvasudev -- 02/21/2002
  */

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sif_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sif_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sif_Id(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIF_FK;
  CURSOR okl_sifv_pk_csr (p_id IN OKL_SIF_FEES_V.sif_id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES_V
   WHERE OKL_STREAM_INTERFACES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.sif_id = Okc_Api.G_MISS_NUM OR
       p_sfev_rec.sif_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sif_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sifv_pk_csr(p_sfev_rec.Sif_id);
    FETCH okl_sifv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sifv_pk_csr%NOTFOUND;
    CLOSE okl_sifv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sifv_pk_csr%ISOPEN THEN
        CLOSE okl_sifv_pk_csr;
      END IF;

  END Validate_Sif_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Kle_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Kle_Id(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_KLE_FK;
  CURSOR okl_klev_pk_csr (p_id IN OKL_SIF_FEES_V.kle_id%TYPE) IS
  SELECT '1'
    FROM OKL_K_LINES_V
   WHERE OKL_K_LINES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.kle_id <> Okc_Api.G_MISS_NUM AND
       p_sfev_rec.kle_id IS NOT NULL
    THEN
	    OPEN okl_klev_pk_csr(p_sfev_rec.kle_id);
	    FETCH okl_klev_pk_csr INTO l_dummy;
	    l_row_not_found := okl_klev_pk_csr%NOTFOUND;
	    CLOSE okl_klev_pk_csr;

	    IF l_row_not_found THEN
	      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Kle_id');
	      x_return_status := Okc_Api.G_RET_STS_ERROR;
	    END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_klev_pk_csr%ISOPEN THEN
        CLOSE okl_klev_pk_csr;
      END IF;

  END Validate_Kle_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sil_Id
  ---------------------------------------------------------------------------

  -- Start of comments
  --
  -- Procedure Name  : Validate_Sil_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sil_Id(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SIL_SIL_FK;
  CURSOR okl_sfev_pk_csr (p_id IN OKL_SIF_FEES_V.Sil_id%TYPE) IS
  SELECT '1'
    FROM OKL_SIF_LINES_V
   WHERE OKL_SIF_LINES_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Sil_id <> Okc_Api.G_MISS_NUM AND
       p_sfev_rec.Sil_id IS NOT NULL
    THEN
        OPEN okl_sfev_pk_csr(p_sfev_rec.Sil_id);
    	FETCH okl_sfev_pk_csr INTO l_dummy;
    	l_row_not_found := okl_sfev_pk_csr%NOTFOUND;
    	CLOSE okl_sfev_pk_csr;
    	IF l_row_not_found THEN
    	  Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Sil_id');
    	  x_return_status := Okc_Api.G_RET_STS_ERROR;
	END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sfev_pk_csr%ISOPEN THEN
        CLOSE okl_sfev_pk_csr;
      END IF;

  END Validate_Sil_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Start
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Start
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Start(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Date_Start = Okc_Api.G_MISS_DATE OR
       p_sfev_rec.Date_Start IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Start');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue

    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Start;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Paid
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Paid
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Paid(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Date_Paid = Okc_Api.G_MISS_DATE OR
       p_sfev_rec.Date_Paid IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Paid');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Paid;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amount
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Amount
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Amount(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Rate IS NULL AND (p_sfev_rec.Amount = Okc_Api.G_MISS_NUM OR
       p_sfev_rec.Amount IS NULL)
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Amount');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Amount;


---------------------------------------------------------------------------
  -- PROCEDURE Validate_Period
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Period
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Period(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Period = Okc_Api.G_MISS_CHAR OR
       p_sfev_rec.Period IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Period');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Period;

---------------------------------------------------------------------------
  -- PROCEDURE Validate_Number_Of_Periods
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Number_Of_Periods
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Number_Of_Periods(
    p_sfev_rec      IN   sfev_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sfev_rec.Number_Of_Periods = Okc_Api.G_MISS_NUM OR
       p_sfev_rec.Number_Of_Periods IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Number_Of_Periods');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Number_Of_Periods;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_sfev_rec IN  sfev_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    -- Validate_Id
    Validate_Id(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sif_id
    Validate_Sif_id(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN

          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Kle_Id
    Validate_Kle_Id(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sil_Id
    Validate_Sil_Id(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Sfe_Type
    Validate_Sfe_Type(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Income_Or_Expense
    Validate_Income_Or_Expense(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Advance_Or_Arrears
    Validate_Advance_Or_Arrears(p_sfev_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

	-- Validate_Amount
	    Validate_Amount(p_sfev_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

    IF (p_sfev_rec.Sfe_Type = G_SFE_TYPE_ONE_OFF)
    THEN
	    -- Validate_Date_Paid
	    Validate_Date_Paid(p_sfev_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
    ELSIF (   p_sfev_rec.Sfe_Type = G_SFE_TYPE_PERIODIC_EXPENSE
           OR p_sfev_rec.Sfe_Type = G_SFE_TYPE_RENT
           OR p_sfev_rec.Sfe_Type = G_SFE_TYPE_PERIODIC_INCOME
    	   OR p_sfev_rec.Sfe_Type = G_SFE_TYPE_LOAN )
    THEN
	    -- Validate_Date_Start
	    Validate_Date_Start(p_sfev_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    -- Validate_Level_Index_Number
	    Validate_Level_Index_Number(p_sfev_rec, x_return_status);

	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;

	    /*
            -- mvasudev -- 02/21/2002
            -- Validation removed as LEVEL_TYPE is made NULLABLE.

	    -- Validate_Level_Type
	    Validate_Level_Type(p_sfev_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
            -- end,mvasudev -- 02/21/2002
	    */

	    -- Validate_Period
	    Validate_Period(p_sfev_rec, x_return_status);

    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
     -- Validate_Number_Of_Periods
	    Validate_Number_Of_Periods(p_sfev_rec, x_return_status);
	    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
		  -- need to exit
		  l_return_status := x_return_status;
		  RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
		  -- there was an error
		  l_return_status := x_return_status;
	       END IF;
	    END IF;
    END IF;
  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;
  -- END change : akjain

PROCEDURE Validate_Unique_Sfe_Record(
          p_sfev_rec      IN   sfev_rec_type,
            x_return_status OUT NOCOPY  VARCHAR2
          ) IS

          l_dummy                 VARCHAR2(1) := '?';
          l_row_found             BOOLEAN := FALSE;

          -- Cursor For OKL_SIF_FEES_V - Unique Key Constraint
          CURSOR okl_sfe_unique_csr (p_rec IN sfev_rec_type) IS
          SELECT '1'
            FROM OKL_SIF_FEES_V
           WHERE OKL_SIF_FEES_V.sif_id = p_rec.sif_id
           AND
           OKL_SIF_FEES_V.sfe_type = p_rec.sfe_type
           AND
           OKL_SIF_FEES_V.fee_index_number = p_rec.fee_index_number
           AND
           OKL_SIF_FEES_V.sil_id = p_rec.sil_id
           AND
           OKL_SIF_FEES_V.level_index_number = p_rec.level_index_number
           AND
           id     <> NVL(p_rec.id,-9999);

          BEGIN
            OPEN okl_sfe_unique_csr (p_sfev_rec);
            FETCH okl_sfe_unique_csr INTO l_dummy;
            l_row_found := okl_sfe_unique_csr%FOUND;
            CLOSE okl_sfe_unique_csr;

            IF l_row_found THEN
	          	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	          	x_return_status := Okc_Api.G_RET_STS_ERROR;
           END IF;
          EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue
            -- with the next column
            NULL;
            IF okl_sfe_unique_csr%ISOPEN THEN
    	            CLOSE okl_sfe_unique_csr;
            END IF;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                                 ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                                 ,p_token1       => G_OKL_SQLCODE_TOKEN
                                 ,p_token1_value => SQLCODE
                                 ,p_token2       => G_OKL_SQLERRM_TOKEN
                                 ,p_token2_value => SQLERRM);

              -- notify caller of an UNEXPECTED error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

              -- verify that the cursor was closed
              IF okl_sfe_unique_csr%ISOPEN THEN
                CLOSE okl_sfe_unique_csr;
              END IF;
          END Validate_Unique_Sfe_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_SIF_FEES_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_sfev_rec IN sfev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
      -- Validate_Unique_Sfe_Record
      Validate_Unique_Sfe_Record(p_sfev_rec, l_return_status);
      IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
      END IF;

      RETURN(l_return_status);
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
         -- exit with return status
         NULL;
         RETURN (l_return_status);

      WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                             p_token1           => G_OKL_SQLCODE_TOKEN,
                             p_token1_value     => SQLCODE,
                             p_token2           => G_OKL_SQLERRM_TOKEN,
                             p_token2_value     => SQLERRM);
         -- notify caller of an UNEXPECTED error
         l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sfev_rec_type,
    p_to	IN OUT NOCOPY sfe_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfe_type := p_from.sfe_type;
    p_to.date_start := p_from.date_start;
    p_to.date_paid := p_from.date_paid;
    p_to.amount := p_from.amount;
    p_to.idc_accounting_flag := p_from.idc_accounting_flag;
    p_to.income_or_expense := p_from.income_or_expense;
    p_to.description := p_from.description;
    p_to.fee_index_number := p_from.fee_index_number;
    p_to.level_index_number := p_from.level_index_number;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.level_type := p_from.level_type;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.period := p_from.period;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.level_line_number := p_from.level_line_number;
    p_to.sif_id := p_from.sif_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sil_id := p_from.sil_id;
    p_to.rate := p_from.rate;
    -- mvasudev, 05/13/2002
    p_to.query_level_yn := p_from.query_level_yn;
    p_to.structure := p_from.structure;
    p_to.days_in_period := p_from.days_in_period;
    --
    p_to.object_version_number := p_from.object_version_number;
    p_to.cash_effect_yn := p_from.cash_effect_yn;
    p_to.tax_effect_yn := p_from.tax_effect_yn;
    p_to.days_in_month := p_from.days_in_month;
    p_to.days_in_year  := p_from.days_in_year;
    p_to.balance_type_code     := p_from.balance_type_code    ;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.stream_interface_attribute16 := p_from.stream_interface_attribute16;
    p_to.stream_interface_attribute17 := p_from.stream_interface_attribute17;
    p_to.stream_interface_attribute18 := p_from.stream_interface_attribute18;
    p_to.stream_interface_attribute19 := p_from.stream_interface_attribute19;
    p_to.stream_interface_attribute20 := p_from.stream_interface_attribute20;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.down_payment_amount:= p_from.down_payment_amount;
    p_to.orig_contract_line_id:= p_from.orig_contract_line_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sfe_rec_type,
    p_to	IN OUT NOCOPY sfev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfe_type := p_from.sfe_type;
    p_to.date_start := p_from.date_start;
    p_to.date_paid := p_from.date_paid;

    p_to.amount := p_from.amount;
    p_to.idc_accounting_flag := p_from.idc_accounting_flag;
    p_to.income_or_expense := p_from.income_or_expense;
    p_to.description := p_from.description;
    p_to.fee_index_number := p_from.fee_index_number;
    p_to.level_index_number := p_from.level_index_number;
    p_to.advance_or_arrears := p_from.advance_or_arrears;
    p_to.level_type := p_from.level_type;
    p_to.lock_level_step := p_from.lock_level_step;
    p_to.period := p_from.period;
    p_to.number_of_periods := p_from.number_of_periods;
    p_to.level_line_number := p_from.level_line_number;
    p_to.sif_id := p_from.sif_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sil_id := p_from.sil_id;
    p_to.rate := p_from.rate;
    -- mvasudev, 05/13/2002
    p_to.query_level_yn := p_from.query_level_yn;
    p_to.structure := p_from.structure;
    p_to.days_in_period := p_from.days_in_period;
    --
    p_to.object_version_number := p_from.object_version_number;
    p_to.cash_effect_yn := p_from.cash_effect_yn;
    p_to.tax_effect_yn := p_from.tax_effect_yn;
    p_to.days_in_month := p_from.days_in_month;
    p_to.days_in_year  := p_from.days_in_year;
    p_to.balance_type_code     := p_from.balance_type_code    ;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.stream_interface_attribute16 := p_from.stream_interface_attribute16;
    p_to.stream_interface_attribute17 := p_from.stream_interface_attribute17;
    p_to.stream_interface_attribute18 := p_from.stream_interface_attribute18;
    p_to.stream_interface_attribute19 := p_from.stream_interface_attribute19;
    p_to.stream_interface_attribute20 := p_from.stream_interface_attribute20;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.down_payment_amount:= p_from.down_payment_amount;
    p_to.orig_contract_line_id:= p_from.orig_contract_line_id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_SIF_FEES_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfev_rec                     sfev_rec_type := p_sfev_rec;
    l_sfe_rec                      sfe_rec_type;
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
    l_return_status := Validate_Attributes(l_sfev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sfev_rec);
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
  -- PL/SQL TBL validate_row for:SFEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sfev_tbl.COUNT > 0) THEN
      i := p_sfev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sfev_rec                     => p_sfev_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sfev_tbl.LAST);
        i := p_sfev_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  ---------------------------------
  -- insert_row for:OKL_SIF_FEES --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfe_rec                      IN sfe_rec_type,
    x_sfe_rec                      OUT NOCOPY sfe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'FEES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfe_rec                      sfe_rec_type := p_sfe_rec;
    l_def_sfe_rec                  sfe_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_SIF_FEES --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_sfe_rec IN  sfe_rec_type,
      x_sfe_rec OUT NOCOPY sfe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfe_rec := p_sfe_rec;
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
      p_sfe_rec,                         -- IN
      l_sfe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_SIF_FEES(
        id,
        sfe_type,
        date_start,
        date_paid,
        amount,
        idc_accounting_flag,
        income_or_expense,
        description,
        fee_index_number,
        level_index_number,
        advance_or_arrears,
        level_type,
        lock_level_step,
        period,
        number_of_periods,
        level_line_number,
        sif_id,
        kle_id,
        sil_id,
        rate,
        -- mvasudev, 05/13/2002
        query_level_yn,
        structure,
        days_in_period,
        --
        object_version_number,
       	cash_effect_yn,
       	tax_effect_yn,
        days_in_month,
        days_in_year,
        balance_type_code    ,
        stream_interface_attribute01,
        stream_interface_attribute02,
        stream_interface_attribute03,
        stream_interface_attribute04,
        stream_interface_attribute05,
        stream_interface_attribute06,
        stream_interface_attribute07,
        stream_interface_attribute08,
        stream_interface_attribute09,
        stream_interface_attribute10,
        stream_interface_attribute11,
        stream_interface_attribute12,
        stream_interface_attribute13,
        stream_interface_attribute14,
        stream_interface_attribute15,
        stream_interface_attribute16,
        stream_interface_attribute17,
        stream_interface_attribute18,
        stream_interface_attribute19,
        stream_interface_attribute20,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login,
        down_payment_amount,
		orig_contract_line_id)
      VALUES (
        l_sfe_rec.id,
        l_sfe_rec.sfe_type,
        l_sfe_rec.date_start,
        l_sfe_rec.date_paid,
        l_sfe_rec.amount,
        l_sfe_rec.idc_accounting_flag,
        l_sfe_rec.income_or_expense,
        l_sfe_rec.description,
        l_sfe_rec.fee_index_number,
        l_sfe_rec.level_index_number,
        l_sfe_rec.advance_or_arrears,
        l_sfe_rec.level_type,
        l_sfe_rec.lock_level_step,
        l_sfe_rec.period,
        l_sfe_rec.number_of_periods,
        l_sfe_rec.level_line_number,
        l_sfe_rec.sif_id,
        l_sfe_rec.kle_id,
        l_sfe_rec.sil_id,
        l_sfe_rec.rate,
        -- mvasudev, 05/13/2002
        l_sfe_rec.QUERY_LEVEL_YN,
        l_sfe_rec.STRUCTURE,
        l_sfe_rec.DAYS_IN_PERIOD,
        --
        l_sfe_rec.object_version_number,
       	l_sfe_rec.cash_effect_yn,
       	l_sfe_rec.tax_effect_yn,
        l_sfe_rec.days_in_month,
        l_sfe_rec.days_in_year,
        l_sfe_rec.balance_type_code,
        l_sfe_rec.stream_interface_attribute01,
        l_sfe_rec.stream_interface_attribute02,
        l_sfe_rec.stream_interface_attribute03,
        l_sfe_rec.stream_interface_attribute04,
        l_sfe_rec.stream_interface_attribute05,
        l_sfe_rec.stream_interface_attribute06,
        l_sfe_rec.stream_interface_attribute07,
        l_sfe_rec.stream_interface_attribute08,
        l_sfe_rec.stream_interface_attribute09,
        l_sfe_rec.stream_interface_attribute10,
        l_sfe_rec.stream_interface_attribute11,
        l_sfe_rec.stream_interface_attribute12,
        l_sfe_rec.stream_interface_attribute13,
        l_sfe_rec.stream_interface_attribute14,
        l_sfe_rec.stream_interface_attribute15,
        l_sfe_rec.stream_interface_attribute16,
        l_sfe_rec.stream_interface_attribute17,
        l_sfe_rec.stream_interface_attribute18,
        l_sfe_rec.stream_interface_attribute19,
        l_sfe_rec.stream_interface_attribute20,
        l_sfe_rec.created_by,
        l_sfe_rec.last_updated_by,
        l_sfe_rec.creation_date,
        l_sfe_rec.last_update_date,
        l_sfe_rec.last_update_login,
        l_sfe_rec.down_payment_amount,
		l_sfe_rec.orig_contract_line_id);
    -- Set OUT values
    x_sfe_rec := l_sfe_rec;
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
  -----------------------------------
  -- insert_row for:OKL_SIF_FEES_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfev_rec                     sfev_rec_type;
    l_def_sfev_rec                 sfev_rec_type;
    l_sfe_rec                      sfe_rec_type;
    lx_sfe_rec                     sfe_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sfev_rec	IN sfev_rec_type
    ) RETURN sfev_rec_type IS
      l_sfev_rec	sfev_rec_type := p_sfev_rec;
    BEGIN
      l_sfev_rec.CREATION_DATE := SYSDATE;
      l_sfev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sfev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sfev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sfev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sfev_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_FEES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_sfev_rec IN  sfev_rec_type,
      x_sfev_rec OUT NOCOPY sfev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfev_rec := p_sfev_rec;
      x_sfev_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sfev_rec := null_out_defaults(p_sfev_rec);
    -- Set primary key value
    l_sfev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sfev_rec,                        -- IN
      l_def_sfev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sfev_rec := fill_who_columns(l_def_sfev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sfev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sfev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sfev_rec, l_sfe_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sfe_rec,
      lx_sfe_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sfe_rec, l_def_sfev_rec);
    -- Set OUT values
    x_sfev_rec := l_def_sfev_rec;
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
  -- PL/SQL TBL insert_row for:SFEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sfev_tbl.COUNT > 0) THEN
      i := p_sfev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sfev_rec                     => p_sfev_tbl(i),
          x_sfev_rec                     => x_sfev_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_sfev_tbl.LAST);
        i := p_sfev_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
  -------------------------------
  -- lock_row for:OKL_SIF_FEES --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfe_rec                      IN sfe_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sfe_rec IN sfe_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_FEES
     WHERE ID = p_sfe_rec.id
       AND OBJECT_VERSION_NUMBER = p_sfe_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sfe_rec IN sfe_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_FEES
    WHERE ID = p_sfe_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'FEES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_FEES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_FEES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sfe_rec);
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

      OPEN lchk_csr(p_sfe_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sfe_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sfe_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
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
  ---------------------------------
  -- lock_row for:OKL_SIF_FEES_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfe_rec                      sfe_rec_type;
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
    migrate(p_sfev_rec, l_sfe_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sfe_rec
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
  -- PL/SQL TBL lock_row for:SFEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sfev_tbl.COUNT > 0) THEN
      i := p_sfev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sfev_rec                     => p_sfev_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sfev_tbl.LAST);
        i := p_sfev_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
  ---------------------------------
  -- update_row for:OKL_SIF_FEES --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfe_rec                      IN sfe_rec_type,
    x_sfe_rec                      OUT NOCOPY sfe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'FEES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfe_rec                      sfe_rec_type := p_sfe_rec;
    l_def_sfe_rec                  sfe_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sfe_rec	IN sfe_rec_type,
      x_sfe_rec	OUT NOCOPY sfe_rec_type
    ) RETURN VARCHAR2 IS
      l_sfe_rec                      sfe_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfe_rec := p_sfe_rec;
      -- Get current database values
      l_sfe_rec := get_rec(p_sfe_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sfe_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.id := l_sfe_rec.id;
      END IF;
      IF (x_sfe_rec.sfe_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.sfe_type := l_sfe_rec.sfe_type;
      END IF;
      IF (x_sfe_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_sfe_rec.date_start := l_sfe_rec.date_start;
      END IF;
      IF (x_sfe_rec.date_paid = OKC_API.G_MISS_DATE)
      THEN
        x_sfe_rec.date_paid := l_sfe_rec.date_paid;
      END IF;
      IF (x_sfe_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.amount := l_sfe_rec.amount;
      END IF;
      IF (x_sfe_rec.idc_accounting_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.idc_accounting_flag := l_sfe_rec.idc_accounting_flag;
      END IF;
      IF (x_sfe_rec.income_or_expense = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.income_or_expense := l_sfe_rec.income_or_expense;
      END IF;
      IF (x_sfe_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.description := l_sfe_rec.description;
      END IF;
      IF (x_sfe_rec.fee_index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.fee_index_number := l_sfe_rec.fee_index_number;
      END IF;
      IF (x_sfe_rec.level_index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.level_index_number := l_sfe_rec.level_index_number;
      END IF;
      IF (x_sfe_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.advance_or_arrears := l_sfe_rec.advance_or_arrears;
      END IF;

      IF (x_sfe_rec.cash_effect_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.cash_effect_yn := l_sfe_rec.cash_effect_yn;
      END IF;

      IF (x_sfe_rec.tax_effect_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.tax_effect_yn := l_sfe_rec.tax_effect_yn;
      END IF;

      IF (x_sfe_rec.days_in_month = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.days_in_month := l_sfe_rec.days_in_month;
      END IF;

      IF (x_sfe_rec.days_in_year = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.days_in_year := l_sfe_rec.days_in_year;
      END IF;

      IF (x_sfe_rec.balance_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.balance_type_code := l_sfe_rec.balance_type_code;
      END IF;

      IF (x_sfe_rec.level_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.level_type := l_sfe_rec.level_type;

      END IF;
      IF (x_sfe_rec.lock_level_step = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.lock_level_step := l_sfe_rec.lock_level_step;
      END IF;
      IF (x_sfe_rec.period = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.period := l_sfe_rec.period;
      END IF;
      IF (x_sfe_rec.number_of_periods = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.number_of_periods := l_sfe_rec.number_of_periods;
      END IF;
      IF (x_sfe_rec.level_line_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.level_line_number := l_sfe_rec.level_line_number;
      END IF;
      IF (x_sfe_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.sif_id := l_sfe_rec.sif_id;
      END IF;
      IF (x_sfe_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.kle_id := l_sfe_rec.kle_id;
      END IF;
      IF (x_sfe_rec.sil_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.sil_id := l_sfe_rec.sil_id;
      END IF;
      IF (x_sfe_rec.rate = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.rate := l_sfe_rec.rate;
      END IF;
      -- mvasudev, 05/13/2002
      IF (x_sfe_rec.query_level_yn = OKC_API.G_MISS_CHAR)
      THEN
              x_sfe_rec.query_level_yn := l_sfe_rec.query_level_yn;
      END IF;
      IF (x_sfe_rec.STRUCTURE = OKC_API.G_MISS_CHAR)
      THEN
              x_sfe_rec.STRUCTURE := l_sfe_rec.STRUCTURE;
      END IF;
      IF (x_sfe_rec.DAYS_IN_PERIOD = OKC_API.G_MISS_NUM)
      THEN
              x_sfe_rec.DAYS_IN_PERIOD := l_sfe_rec.DAYS_IN_PERIOD;
      END IF;
      --
      IF (x_sfe_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.object_version_number := l_sfe_rec.object_version_number;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute01 := l_sfe_rec.stream_interface_attribute01;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute02 := l_sfe_rec.stream_interface_attribute02;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute03 := l_sfe_rec.stream_interface_attribute03;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute04 := l_sfe_rec.stream_interface_attribute04;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute05 := l_sfe_rec.stream_interface_attribute05;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute06 := l_sfe_rec.stream_interface_attribute06;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute07 := l_sfe_rec.stream_interface_attribute07;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute08 := l_sfe_rec.stream_interface_attribute08;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute09 := l_sfe_rec.stream_interface_attribute09;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute10 := l_sfe_rec.stream_interface_attribute10;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute11 := l_sfe_rec.stream_interface_attribute11;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute12 := l_sfe_rec.stream_interface_attribute12;
      END IF;

      IF (x_sfe_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute13 := l_sfe_rec.stream_interface_attribute13;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute14 := l_sfe_rec.stream_interface_attribute14;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute15 := l_sfe_rec.stream_interface_attribute15;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute16 := l_sfe_rec.stream_interface_attribute16;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute17 := l_sfe_rec.stream_interface_attribute17;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute18 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute18 := l_sfe_rec.stream_interface_attribute18;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute19 := l_sfe_rec.stream_interface_attribute19;
      END IF;
      IF (x_sfe_rec.stream_interface_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfe_rec.stream_interface_attribute20 := l_sfe_rec.stream_interface_attribute20;
      END IF;
      IF (x_sfe_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.created_by := l_sfe_rec.created_by;
      END IF;
      IF (x_sfe_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.last_updated_by := l_sfe_rec.last_updated_by;
      END IF;
      IF (x_sfe_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sfe_rec.creation_date := l_sfe_rec.creation_date;
      END IF;
      IF (x_sfe_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sfe_rec.last_update_date := l_sfe_rec.last_update_date;
      END IF;
      IF (x_sfe_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.last_update_login := l_sfe_rec.last_update_login;
      END IF;
      IF (x_sfe_rec.down_payment_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.down_payment_amount := l_sfe_rec.down_payment_amount;
      END IF;

      IF (x_sfe_rec.orig_contract_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfe_rec.orig_contract_line_id := l_sfe_rec.orig_contract_line_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_SIF_FEES --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_sfe_rec IN  sfe_rec_type,
      x_sfe_rec OUT NOCOPY sfe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfe_rec := p_sfe_rec;
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
      p_sfe_rec,                         -- IN
      l_sfe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sfe_rec, l_def_sfe_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_FEES
    SET SFE_TYPE = l_def_sfe_rec.sfe_type,
        DATE_START = l_def_sfe_rec.date_start,
        DATE_PAID = l_def_sfe_rec.date_paid,
        AMOUNT = l_def_sfe_rec.amount,
        IDC_ACCOUNTING_FLAG = l_def_sfe_rec.idc_accounting_flag,
        INCOME_OR_EXPENSE = l_def_sfe_rec.income_or_expense,
        DESCRIPTION = l_def_sfe_rec.description,
        FEE_INDEX_NUMBER = l_def_sfe_rec.fee_index_number,
        LEVEL_INDEX_NUMBER = l_def_sfe_rec.level_index_number,
        ADVANCE_OR_ARREARS = l_def_sfe_rec.advance_or_arrears,
        LEVEL_TYPE = l_def_sfe_rec.level_type,
        LOCK_LEVEL_STEP = l_def_sfe_rec.lock_level_step,
        -- mvasudev, 05/13/2002
        QUERY_LEVEL_YN = l_def_sfe_rec.query_level_yn,
        STRUCTURE = l_def_sfe_rec.STRUCTURE,
        DAYS_IN_PERIOD = l_def_sfe_rec.DAYS_IN_PERIOD,
        --
        PERIOD = l_def_sfe_rec.period,
        cash_effect_yn = l_def_sfe_rec.cash_effect_yn,
        tax_effect_yn = l_def_sfe_rec.tax_effect_yn,
        days_in_month = l_def_sfe_rec.days_in_month,
        days_in_year = l_def_sfe_rec.days_in_year,
        balance_type_code     = l_def_sfe_rec.balance_type_code     ,
        NUMBER_OF_PERIODS = l_def_sfe_rec.number_of_periods,
        LEVEL_LINE_NUMBER = l_def_sfe_rec.level_line_number,
        SIF_ID = l_def_sfe_rec.sif_id,
        KLE_ID = l_def_sfe_rec.kle_id,
        SIL_ID = l_def_sfe_rec.sil_id,
        RATE = l_def_sfe_rec.rate,
        OBJECT_VERSION_NUMBER = l_def_sfe_rec.object_version_number,
        STREAM_INTERFACE_ATTRIBUTE01 = l_def_sfe_rec.stream_interface_attribute01,
        STREAM_INTERFACE_ATTRIBUTE02 = l_def_sfe_rec.stream_interface_attribute02,
        STREAM_INTERFACE_ATTRIBUTE03 = l_def_sfe_rec.stream_interface_attribute03,
        STREAM_INTERFACE_ATTRIBUTE04 = l_def_sfe_rec.stream_interface_attribute04,
        STREAM_INTERFACE_ATTRIBUTE05 = l_def_sfe_rec.stream_interface_attribute05,
        STREAM_INTERFACE_ATTRIBUTE06 = l_def_sfe_rec.stream_interface_attribute06,
        STREAM_INTERFACE_ATTRIBUTE07 = l_def_sfe_rec.stream_interface_attribute07,
        STREAM_INTERFACE_ATTRIBUTE08 = l_def_sfe_rec.stream_interface_attribute08,
        STREAM_INTERFACE_ATTRIBUTE09 = l_def_sfe_rec.stream_interface_attribute09,
        STREAM_INTERFACE_ATTRIBUTE10 = l_def_sfe_rec.stream_interface_attribute10,
        STREAM_INTERFACE_ATTRIBUTE11 = l_def_sfe_rec.stream_interface_attribute11,
        STREAM_INTERFACE_ATTRIBUTE12 = l_def_sfe_rec.stream_interface_attribute12,
        STREAM_INTERFACE_ATTRIBUTE13 = l_def_sfe_rec.stream_interface_attribute13,
        STREAM_INTERFACE_ATTRIBUTE14 = l_def_sfe_rec.stream_interface_attribute14,
        STREAM_INTERFACE_ATTRIBUTE15 = l_def_sfe_rec.stream_interface_attribute15,
        STREAM_INTERFACE_ATTRIBUTE16 = l_def_sfe_rec.stream_interface_attribute16,
        STREAM_INTERFACE_ATTRIBUTE17 = l_def_sfe_rec.stream_interface_attribute17,
        STREAM_INTERFACE_ATTRIBUTE18 = l_def_sfe_rec.stream_interface_attribute18,
        STREAM_INTERFACE_ATTRIBUTE19 = l_def_sfe_rec.stream_interface_attribute19,
        STREAM_INTERFACE_ATTRIBUTE20 = l_def_sfe_rec.stream_interface_attribute20,
        CREATED_BY = l_def_sfe_rec.created_by,
        LAST_UPDATED_BY = l_def_sfe_rec.last_updated_by,
        CREATION_DATE = l_def_sfe_rec.creation_date,
        LAST_UPDATE_DATE = l_def_sfe_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sfe_rec.last_update_login,
        DOWN_PAYMENT_AMOUNT = l_def_sfe_rec.down_payment_amount,
        orig_contract_line_id = l_def_sfe_rec.orig_contract_line_id
    WHERE ID = l_def_sfe_rec.id;

    x_sfe_rec := l_def_sfe_rec;
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
  -----------------------------------
  -- update_row for:OKL_SIF_FEES_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfev_rec                     sfev_rec_type := p_sfev_rec;
    l_def_sfev_rec                 sfev_rec_type;
    l_sfe_rec                      sfe_rec_type;
    lx_sfe_rec                     sfe_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sfev_rec	IN sfev_rec_type
    ) RETURN sfev_rec_type IS
      l_sfev_rec	sfev_rec_type := p_sfev_rec;
    BEGIN
      l_sfev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sfev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sfev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sfev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sfev_rec	IN sfev_rec_type,
      x_sfev_rec	OUT NOCOPY sfev_rec_type
    ) RETURN VARCHAR2 IS
      l_sfev_rec                     sfev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfev_rec := p_sfev_rec;
      -- Get current database values
      l_sfev_rec := get_rec(p_sfev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sfev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.id := l_sfev_rec.id;
      END IF;
      IF (x_sfev_rec.sfe_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.sfe_type := l_sfev_rec.sfe_type;
      END IF;
      IF (x_sfev_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_sfev_rec.date_start := l_sfev_rec.date_start;
      END IF;
      IF (x_sfev_rec.date_paid = OKC_API.G_MISS_DATE)
      THEN
        x_sfev_rec.date_paid := l_sfev_rec.date_paid;
      END IF;
      IF (x_sfev_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.amount := l_sfev_rec.amount;
      END IF;
      IF (x_sfev_rec.idc_accounting_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.idc_accounting_flag := l_sfev_rec.idc_accounting_flag;
      END IF;
      IF (x_sfev_rec.income_or_expense = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.income_or_expense := l_sfev_rec.income_or_expense;
      END IF;
      IF (x_sfev_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.description := l_sfev_rec.description;
      END IF;
      IF (x_sfev_rec.fee_index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.fee_index_number := l_sfev_rec.fee_index_number;
      END IF;
      IF (x_sfev_rec.level_index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.level_index_number := l_sfev_rec.level_index_number;
      END IF;
      IF (x_sfev_rec.advance_or_arrears = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.advance_or_arrears := l_sfev_rec.advance_or_arrears;
      END IF;

      IF (x_sfev_rec.cash_effect_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.cash_effect_yn := l_sfev_rec.cash_effect_yn;
      END IF;

      IF (x_sfev_rec.tax_effect_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.tax_effect_yn := l_sfev_rec.tax_effect_yn;
      END IF;

      IF (x_sfev_rec.days_in_month = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.days_in_month := l_sfev_rec.days_in_month;
      END IF;

      IF (x_sfev_rec.days_in_year = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.days_in_year := l_sfev_rec.days_in_year;
      END IF;

      IF (x_sfev_rec.balance_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.balance_type_code := l_sfev_rec.balance_type_code;
      END IF;

      IF (x_sfev_rec.level_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.level_type := l_sfev_rec.level_type;
      END IF;
      IF (x_sfev_rec.lock_level_step = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.lock_level_step := l_sfev_rec.lock_level_step;
      END IF;
      -- mvasudev, 05/13/2002
      IF (x_sfev_rec.query_level_yn = OKC_API.G_MISS_CHAR)
      THEN
              x_sfev_rec.query_level_yn := l_sfev_rec.query_level_yn;
      END IF;
      IF (x_sfev_rec.STRUCTURE = OKC_API.G_MISS_CHAR)
      THEN
              x_sfev_rec.STRUCTURE := l_sfev_rec.STRUCTURE;
      END IF;
      IF (x_sfev_rec.DAYS_IN_PERIOD = OKC_API.G_MISS_NUM)
      THEN
             x_sfev_rec.DAYS_IN_PERIOD := l_sfev_rec.DAYS_IN_PERIOD;
      END IF;
      --
      IF (x_sfev_rec.period = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.period := l_sfev_rec.period;

      END IF;
      IF (x_sfev_rec.number_of_periods = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.number_of_periods := l_sfev_rec.number_of_periods;
      END IF;
      IF (x_sfev_rec.level_line_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.level_line_number := l_sfev_rec.level_line_number;
      END IF;
      IF (x_sfev_rec.sif_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.sif_id := l_sfev_rec.sif_id;
      END IF;
      IF (x_sfev_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.kle_id := l_sfev_rec.kle_id;
      END IF;
      IF (x_sfev_rec.sil_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.sil_id := l_sfev_rec.sil_id;
      END IF;
      IF (x_sfev_rec.rate = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.rate := l_sfev_rec.rate;
      END IF;
      IF (x_sfev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.object_version_number := l_sfev_rec.object_version_number;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute01 := l_sfev_rec.stream_interface_attribute01;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute02 := l_sfev_rec.stream_interface_attribute02;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute03 := l_sfev_rec.stream_interface_attribute03;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute04 := l_sfev_rec.stream_interface_attribute04;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute05 := l_sfev_rec.stream_interface_attribute05;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute06 := l_sfev_rec.stream_interface_attribute06;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute07 := l_sfev_rec.stream_interface_attribute07;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute08 := l_sfev_rec.stream_interface_attribute08;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute09 := l_sfev_rec.stream_interface_attribute09;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute10 := l_sfev_rec.stream_interface_attribute10;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute11 := l_sfev_rec.stream_interface_attribute11;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute12 := l_sfev_rec.stream_interface_attribute12;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute13 := l_sfev_rec.stream_interface_attribute13;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute14 := l_sfev_rec.stream_interface_attribute14;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute15 := l_sfev_rec.stream_interface_attribute15;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute16 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute16 := l_sfev_rec.stream_interface_attribute16;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute17 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute17 := l_sfev_rec.stream_interface_attribute17;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute18 = OKC_API.G_MISS_CHAR)
      THEN

        x_sfev_rec.stream_interface_attribute18 := l_sfev_rec.stream_interface_attribute18;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute19 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute19 := l_sfev_rec.stream_interface_attribute19;
      END IF;
      IF (x_sfev_rec.stream_interface_attribute20 = OKC_API.G_MISS_CHAR)
      THEN
        x_sfev_rec.stream_interface_attribute20 := l_sfev_rec.stream_interface_attribute20;
      END IF;
      IF (x_sfev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.created_by := l_sfev_rec.created_by;
      END IF;
      IF (x_sfev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.last_updated_by := l_sfev_rec.last_updated_by;
      END IF;
      IF (x_sfev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sfev_rec.creation_date := l_sfev_rec.creation_date;
      END IF;
      IF (x_sfev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sfev_rec.last_update_date := l_sfev_rec.last_update_date;
      END IF;
      IF (x_sfev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.last_update_login := l_sfev_rec.last_update_login;
      END IF;
      IF (x_sfev_rec.down_payment_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.down_payment_amount := l_sfev_rec.down_payment_amount;
      END IF;

      IF (x_sfev_rec.orig_contract_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_sfev_rec.orig_contract_line_id := l_sfev_rec.orig_contract_line_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_FEES_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_sfev_rec IN  sfev_rec_type,
      x_sfev_rec OUT NOCOPY sfev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sfev_rec := p_sfev_rec;
      x_sfev_rec.OBJECT_VERSION_NUMBER := NVL(x_sfev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sfev_rec,                        -- IN
      l_sfev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sfev_rec, l_def_sfev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sfev_rec := fill_who_columns(l_def_sfev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sfev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sfev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sfev_rec, l_sfe_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,

      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sfe_rec,
      lx_sfe_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sfe_rec, l_def_sfev_rec);
    x_sfev_rec := l_def_sfev_rec;
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
  -- PL/SQL TBL update_row for:SFEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sfev_tbl.COUNT > 0) THEN
      i := p_sfev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sfev_rec                     => p_sfev_tbl(i),
          x_sfev_rec                     => x_sfev_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sfev_tbl.LAST);
        i := p_sfev_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
  ---------------------------------
  -- delete_row for:OKL_SIF_FEES --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfe_rec                      IN sfe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'FEES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfe_rec                      sfe_rec_type:= p_sfe_rec;
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
    DELETE FROM OKL_SIF_FEES
     WHERE ID = l_sfe_rec.id;

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
  -----------------------------------
  -- delete_row for:OKL_SIF_FEES_V --
  -----------------------------------
  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sfev_rec                     sfev_rec_type := p_sfev_rec;
    l_sfe_rec                      sfe_rec_type;
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
    migrate(l_sfev_rec, l_sfe_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sfe_rec
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
  -- PL/SQL TBL delete_row for:SFEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_sfev_tbl.COUNT > 0) THEN
      i := p_sfev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sfev_rec                     => p_sfev_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sfev_tbl.LAST);
        i := p_sfev_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
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
END OKL_SFE_PVT;

/

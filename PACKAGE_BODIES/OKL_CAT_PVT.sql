--------------------------------------------------------
--  DDL for Package Body OKL_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CAT_PVT" AS
/* $Header: OKLSCATB.pls 120.6 2006/07/13 12:54:46 adagur noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
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

  /************************** BEGIN HAND-CODED *****************************/

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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_catv_rec.object_version_number IS NULL) OR
       (p_catv_rec.object_version_Number = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Name(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_catv_rec      IN   catv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  CURSOR c1( p_name OKL_CASH_ALLCTN_RLS.name%TYPE) IS
  SELECT 1
  FROM OKL_CASH_ALLCTN_RLS
  WHERE name = p_name
  AND id <> NVL(p_catv_rec.id,-9999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_catv_rec.name IS NULL) OR
       (p_catv_rec.name = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'name');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check if name is unique

    OPEN c1(p_catv_rec.name);
    FETCH c1 INTO l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
          Okl_Api.set_message(G_APP_NAME,G_UNQS);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Und_Pymnt_Alloc_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Und_Pymnt_Alloc_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Und_Pymnt_Alloc_Code(x_return_status OUT NOCOPY  VARCHAR2
                                                  ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ((p_catv_rec.under_payment_allocation_code IS NULL) OR
        (p_catv_rec.under_payment_allocation_code = Okl_Api.G_MISS_NUM)) OR
	    (p_catv_rec.under_payment_allocation_code NOT IN ('t','T','p','P','u','U')) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'under_payment_allocation_code');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Und_Pymnt_Alloc_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ovr_Pymnt_Alloc_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ovr_Pymnt_Alloc_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ovr_Pymnt_Alloc_Code(x_return_status OUT NOCOPY  VARCHAR2
                                         ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF ((p_catv_rec.over_payment_allocation_code IS NULL) OR
        (p_catv_rec.over_payment_allocation_code = Okl_Api.G_MISS_NUM)) OR
	    (p_catv_rec.over_payment_allocation_code NOT IN ('m','M','b','B','f','F')) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'over_payment_allocation_code');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Ovr_Pymnt_Alloc_Code;

    ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rec_Mismatch_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rec_Mismatch_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rec_Mismatch_Code(x_return_status OUT NOCOPY  VARCHAR2
                                      ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ((p_catv_rec.receipt_msmtch_allocation_code IS NULL) OR
        (p_catv_rec.receipt_msmtch_allocation_code = Okl_Api.G_MISS_NUM)) OR
	    (p_catv_rec.receipt_msmtch_allocation_code NOT IN ('a','A','o','O','n','N')) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'receipt_mismatch_allocation_code');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Rec_Mismatch_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amt_Tol_Percent
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Amt_Tol_Percent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Amt_Tol_Percent(x_return_status OUT NOCOPY  VARCHAR2
                                    ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF ((p_catv_rec.amount_tolerance_percent IS NULL) OR
        (p_catv_rec.amount_tolerance_percent = Okl_Api.G_MISS_NUM)) OR
       ((p_catv_rec.amount_tolerance_percent < 0) OR
        (p_catv_rec.amount_tolerance_percent > 100)) THEN

       Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name       => 'OKL_BPD_VALID_TOLERANCE');
                      --    ,p_token1         => g_col_name_token
                      --    ,p_token1_value   => 'amount_tolerance_percent');

       x_return_status    := Okl_Api.G_RET_STS_ERROR;

       -- halt further validation of this column
       -- RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END Validate_Amt_Tol_Percent;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_days_pst_code_val_tol
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_days_pst_code_val_tol
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_days_pst_code_val_tol(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ((p_catv_rec.days_past_quote_valid_toleranc IS NULL) OR
        (p_catv_rec.days_past_quote_valid_toleranc = Okl_Api.G_MISS_NUM)) OR
        (p_catv_rec.days_past_quote_valid_toleranc < 0) THEN

       Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name       => 'OKL_BPD_VALID_TERMINATION');
--                          ,p_msg_name       => 'OKL_BPD_VALID_TOLERANCE');
                     --     ,p_token1         => g_col_name_token
                     --     ,p_token1_value   => 'days_past_quote_valid_toleranc');
       x_return_status := okl_api.G_RET_STS_ERROR;
       --x_return_status    := 'U';
       -- halt further validation of this column
       -- RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END Validate_days_pst_code_val_tol;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_mnths_bill_ahead
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_mnths_bill_ahead
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_mnths_bill_ahead(x_return_status OUT NOCOPY  VARCHAR2
                                     ,p_catv_rec      IN   catv_rec_type)
  IS
  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- check for data before processing

    -- sjalasut, commented code as part of user defined streams build. this item
    -- is no more being displayed on the migrated OAFWK Cash Application Rule Create/ Update page.
    /*IF ((p_catv_rec.months_to_bill_ahead IS NULL) OR
        (p_catv_rec.months_to_bill_ahead = Okl_Api.G_MISS_NUM)) OR
        (p_catv_rec.months_to_bill_ahead < 0) THEN

       Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name       => 'OKL_BPD_VALID_MNTHS');
                     --     ,p_token1         => g_col_name_token
                     --     ,p_token1_value   => 'months_to_bill_ahead');
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       -- halt further validation of this column
       -- RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;*/

  END Validate_mnths_bill_ahead;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_CAU_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_CAU_ID
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_CAU_ID(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_catv_rec      IN   catv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_dummy                 NUMBER;
  l_row_found             BOOLEAN := FALSE;

  CURSOR c1( p_CAU_ID OKL_CSH_ALLCTN_RL_HDR.ID%TYPE) IS
  SELECT 1
  FROM OKL_CSH_ALLCTN_RL_HDR
  WHERE id = p_CAU_ID;

  BEGIN
    IF (p_catv_rec.CAU_ID = OKL_API.G_MISS_NUM OR
        p_catv_rec.CAU_ID IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CAU_ID');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
      OPEN c1(p_catv_rec.CAU_ID);
      FETCH c1 INTO l_dummy;
      IF (c1%NOTFOUND) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'CAU_ID',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                                    p_token2_value	=> 'OKL_CASH_ALLCTN_RLS',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_CSH_ALLCTN_RL_HDR');
        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c1;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_CAU_ID;


  --------------------------------------------
  -- Validate_Attributes for: START_DATE --
  --------------------------------------------
  PROCEDURE validate_start_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) AS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_catv_rec.start_date = OKC_API.G_MISS_DATE OR
        p_catv_rec.start_date IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;

  /************************** END HAND-CODED *****************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CASH_ALLCTN_RLS
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the okl_cash_allctn_rls table.
  -- Business Rules  :
  -- Parameters      : p_cat_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_cat_rec                      IN cat_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cat_rec_type IS
    CURSOR cat_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            START_DATE,
            END_DATE,
            AMOUNT_TOLERANCE_PERCENT,
            DAYS_PAST_QUOTE_VALID_TOLERANC,
            MONTHS_TO_BILL_AHEAD,
			UNDER_PAYMENT_ALLOCATION_CODE,
			OVER_PAYMENT_ALLOCATION_CODE,
			RECEIPT_MSMTCH_ALLOCATION_CODE,
            DEFAULT_RULE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CAU_ID,
-- column added to hold the number of days for advanced receipts
	    NUM_DAYS_HOLD_ADV_PAY
      FROM Okl_Cash_Allctn_Rls
     WHERE okl_cash_allctn_rls.id = p_id;
    l_cat_pk                       cat_pk_csr%ROWTYPE;
    l_cat_rec                      cat_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cat_pk_csr (p_cat_rec.id);
    FETCH cat_pk_csr INTO
              l_cat_rec.ID,
              l_cat_rec.NAME,
              l_cat_rec.OBJECT_VERSION_NUMBER,
              l_cat_rec.DESCRIPTION,
              l_cat_rec.start_date,
              l_cat_rec.end_date,
              l_cat_rec.AMOUNT_TOLERANCE_PERCENT,
              l_cat_rec.DAYS_PAST_QUOTE_VALID_TOLERANC,
              l_cat_rec.MONTHS_TO_BILL_AHEAD,
			  l_cat_rec.UNDER_PAYMENT_ALLOCATION_CODE,
			  l_cat_rec.OVER_PAYMENT_ALLOCATION_CODE,
			  l_cat_rec.RECEIPT_MSMTCH_ALLOCATION_CODE,
			  l_cat_rec.DEFAULT_RULE,
              l_cat_rec.ATTRIBUTE_CATEGORY,
              l_cat_rec.ATTRIBUTE1,
              l_cat_rec.ATTRIBUTE2,
              l_cat_rec.ATTRIBUTE3,
              l_cat_rec.ATTRIBUTE4,
              l_cat_rec.ATTRIBUTE5,
              l_cat_rec.ATTRIBUTE6,
              l_cat_rec.ATTRIBUTE7,
              l_cat_rec.ATTRIBUTE8,
              l_cat_rec.ATTRIBUTE9,
              l_cat_rec.ATTRIBUTE10,
              l_cat_rec.ATTRIBUTE11,
              l_cat_rec.ATTRIBUTE12,
              l_cat_rec.ATTRIBUTE13,
              l_cat_rec.ATTRIBUTE14,
              l_cat_rec.ATTRIBUTE15,
              l_cat_rec.ORG_ID,
              l_cat_rec.CREATED_BY,
              l_cat_rec.CREATION_DATE,
              l_cat_rec.LAST_UPDATED_BY,
              l_cat_rec.LAST_UPDATE_DATE,
              l_cat_rec.LAST_UPDATE_LOGIN,
              l_cat_rec.CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
	      l_cat_rec.NUM_DAYS_HOLD_ADV_PAY;
    x_no_data_found := cat_pk_csr%NOTFOUND;
    CLOSE cat_pk_csr;
    RETURN(l_cat_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cat_rec                      IN cat_rec_type
  ) RETURN cat_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cat_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CASH_ALLCTN_RLS_V
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_rec
  -- Description     : To get the record from the okl_cash_allctn_rls table.
  -- Business Rules  :
  -- Parameters      : p_catv_rec, x_no_data_found
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION get_rec (
    p_catv_rec                     IN catv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN catv_rec_type IS
    CURSOR okl_catv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
            start_date,
            end_date,
            AMOUNT_TOLERANCE_PERCENT,
            DAYS_PAST_QUOTE_VALID_TOLERANC,
            MONTHS_TO_BILL_AHEAD,
			UNDER_PAYMENT_ALLOCATION_CODE,
			OVER_PAYMENT_ALLOCATION_CODE,
			RECEIPT_MSMTCH_ALLOCATION_CODE,
			DEFAULT_RULE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
	    NUM_DAYS_HOLD_ADV_PAY
      FROM OKL_CASH_ALLCTN_RLS
     WHERE OKL_CASH_ALLCTN_RLS.id = p_id;
    l_okl_catv_pk                  okl_catv_pk_csr%ROWTYPE;
    l_catv_rec                     catv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_catv_pk_csr (p_catv_rec.id);
    FETCH okl_catv_pk_csr INTO
              l_catv_rec.ID,
              l_catv_rec.OBJECT_VERSION_NUMBER,
              l_catv_rec.NAME,
              l_catv_rec.DESCRIPTION,
              l_catv_rec.start_date,
              l_catv_rec.end_date,
              l_catv_rec.AMOUNT_TOLERANCE_PERCENT,
              l_catv_rec.DAYS_PAST_QUOTE_VALID_TOLERANC,
              l_catv_rec.MONTHS_TO_BILL_AHEAD,
			  l_catv_rec.UNDER_PAYMENT_ALLOCATION_CODE,
			  l_catv_rec.OVER_PAYMENT_ALLOCATION_CODE,
			  l_catv_rec.RECEIPT_MSMTCH_ALLOCATION_CODE,
			  l_catv_rec.DEFAULT_RULE,
              l_catv_rec.ATTRIBUTE_CATEGORY,
              l_catv_rec.ATTRIBUTE1,
              l_catv_rec.ATTRIBUTE2,
              l_catv_rec.ATTRIBUTE3,
              l_catv_rec.ATTRIBUTE4,
              l_catv_rec.ATTRIBUTE5,
              l_catv_rec.ATTRIBUTE6,
              l_catv_rec.ATTRIBUTE7,
              l_catv_rec.ATTRIBUTE8,
              l_catv_rec.ATTRIBUTE9,
              l_catv_rec.ATTRIBUTE10,
              l_catv_rec.ATTRIBUTE11,
              l_catv_rec.ATTRIBUTE12,
              l_catv_rec.ATTRIBUTE13,
              l_catv_rec.ATTRIBUTE14,
              l_catv_rec.ATTRIBUTE15,
              l_catv_rec.ORG_ID,
              l_catv_rec.CREATED_BY,
              l_catv_rec.CREATION_DATE,
              l_catv_rec.LAST_UPDATED_BY,
              l_catv_rec.LAST_UPDATE_DATE,
              l_catv_rec.LAST_UPDATE_LOGIN,
              l_catv_rec.CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
       l_catv_rec.NUM_DAYS_HOLD_ADV_PAY;
    x_no_data_found := okl_catv_pk_csr%NOTFOUND;
    CLOSE okl_catv_pk_csr;
    RETURN(l_catv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_catv_rec                     IN catv_rec_type
  ) RETURN catv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_catv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CASH_ALLCTN_RLS_V --
  -----------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : null_out_defaults
  -- Description     : If the field has default values then equate it to null.
  -- Business Rules  :
  -- Parameters      : p_catv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include the validation
  --                   for NUM_OF_DAYS_TO_HOLD_ADV_PAY column also.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults (
    p_catv_rec	IN catv_rec_type
  ) RETURN catv_rec_type IS
    l_catv_rec	catv_rec_type := p_catv_rec;
  BEGIN
    IF (l_catv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.object_version_number := NULL;
    END IF;
    IF (l_catv_rec.name = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.name := NULL;
    END IF;
    IF (l_catv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.description := NULL;
    END IF;

    IF (l_catv_rec.start_date = Okl_Api.G_MISS_DATE) THEN
      l_catv_rec.start_date := NULL;
    END IF;

    IF (l_catv_rec.end_date = Okl_Api.G_MISS_DATE) THEN
      l_catv_rec.end_date := NULL;
    END IF;

    IF (l_catv_rec.amount_tolerance_percent = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.amount_tolerance_percent := NULL;
    END IF;
    IF (l_catv_rec.days_past_quote_valid_toleranc = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.days_past_quote_valid_toleranc := NULL;
    END IF;
    IF (l_catv_rec.months_to_bill_ahead = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.months_to_bill_ahead := NULL;
    END IF;
	IF (l_catv_rec.under_payment_allocation_code = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.under_payment_allocation_code := NULL;
    END IF;
	IF (l_catv_rec.over_payment_allocation_code = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.over_payment_allocation_code := NULL;
    END IF;
	IF (l_catv_rec.receipt_msmtch_allocation_code = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.receipt_msmtch_allocation_code := NULL;
    END IF;
    IF (l_catv_rec.default_rule = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.default_rule := NULL;
    END IF;
    IF (l_catv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute_category := NULL;
    END IF;
    IF (l_catv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute1 := NULL;
    END IF;
    IF (l_catv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute2 := NULL;
    END IF;
    IF (l_catv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute3 := NULL;
    END IF;
    IF (l_catv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute4 := NULL;
    END IF;
    IF (l_catv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute5 := NULL;
    END IF;
    IF (l_catv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute6 := NULL;
    END IF;
    IF (l_catv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute7 := NULL;
    END IF;
    IF (l_catv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute8 := NULL;
    END IF;
    IF (l_catv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute9 := NULL;
    END IF;
    IF (l_catv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute10 := NULL;
    END IF;
    IF (l_catv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute11 := NULL;
    END IF;
    IF (l_catv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute12 := NULL;
    END IF;
    IF (l_catv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute13 := NULL;
    END IF;
    IF (l_catv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute14 := NULL;
    END IF;
    IF (l_catv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_catv_rec.attribute15 := NULL;
    END IF;
    IF (l_catv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.org_id := NULL;
    END IF;
    IF (l_catv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.created_by := NULL;
    END IF;
    IF (l_catv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_catv_rec.creation_date := NULL;
    END IF;
    IF (l_catv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.last_updated_by := NULL;
    END IF;
    IF (l_catv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_catv_rec.last_update_date := NULL;
    END IF;
    IF (l_catv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.last_update_login := NULL;
    END IF;

    IF (l_catv_rec.CAU_ID = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.CAU_ID := NULL;
    END IF;
-- new column  to hold number of days to reserve advanced payment for contract.
    IF (l_catv_rec.num_days_hold_adv_pay = Okl_Api.G_MISS_NUM) THEN
      l_catv_rec.num_days_hold_adv_pay := NULL;
    END IF;
    RETURN(l_catv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CASH_ALLCTN_RLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_catv_rec IN  catv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- call each column-level validation

    IF p_catv_rec.id = Okl_Api.G_MISS_NUM OR
       p_catv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;


    -- Validate_Object_Version_Number

    Validate_Object_Version_Number(x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        -- record that there was an error
        l_return_status := x_return_status;
      END IF;
    END IF;


    -- ***
    -- start_date
    -- ***
    validate_start_date(l_return_status, p_catv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;


    /*
    -- Validate_Name and check for uniqueness

    Validate_Name (x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);


	-- Validate_Under_Payment_Allocation_Code

    Validate_Und_Pymnt_Alloc_Code (x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);

	-- Validate_Over_Payment_Allocation_Code

    Validate_Ovr_Pymnt_Alloc_Code (x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);

	-- Validate_Rec_Mismatch_Allocation_Code

    Validate_Rec_Mismatch_Code (x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);

*/

Validate_Amt_Tol_Percent(x_return_status => x_return_status,
			 	         p_catv_rec      => p_catv_rec);

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

Validate_days_pst_code_val_tol(x_return_status => x_return_status,
	   	 	                   p_catv_rec      => p_catv_rec);


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


Validate_mnths_bill_ahead(x_return_status => x_return_status,
  		 	              p_catv_rec      => p_catv_rec);
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

    -- Validate_CAU_ID

    Validate_CAU_ID (x_return_status, p_catv_rec);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
          -- record that there was an error
          l_return_status := x_return_status;
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
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CASH_ALLCTN_RLS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_catv_rec IN catv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN catv_rec_type,
    p_to	IN OUT NOCOPY cat_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;

    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;

    p_to.amount_tolerance_percent := p_from.amount_tolerance_percent;
    p_to.days_past_quote_valid_toleranc := p_from.days_past_quote_valid_toleranc;
    p_to.months_to_bill_ahead := p_from.months_to_bill_ahead;
	p_to.under_payment_allocation_code := p_from.under_payment_allocation_code;
	p_to.over_payment_allocation_code := p_from.over_payment_allocation_code;
	p_to.receipt_msmtch_allocation_code := p_from.receipt_msmtch_allocation_code;
	p_to.default_rule := p_from.default_rule;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.CAU_ID := p_from.CAU_ID;
-- new column  to hold number of days to reserve advanced payment for contract.
    p_to.num_days_hold_adv_pay := p_from.num_days_hold_adv_pay;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : migrate
  -- Description     : This procedure is used for copying the record structure.
  -- Business Rules  :
  -- Parameters      : p_from, p_to
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN cat_rec_type,
    p_to	IN OUT NOCOPY catv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;

    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;

    p_to.amount_tolerance_percent := p_from.amount_tolerance_percent;
    p_to.days_past_quote_valid_toleranc := p_from.days_past_quote_valid_toleranc;
    p_to.months_to_bill_ahead := p_from.months_to_bill_ahead;
	p_to.under_payment_allocation_code := p_from.under_payment_allocation_code;
	p_to.over_payment_allocation_code := p_from.over_payment_allocation_code;
	p_to.receipt_msmtch_allocation_code := p_from.receipt_msmtch_allocation_code;
	p_to.default_rule := p_from.default_rule;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.CAU_ID := p_from.CAU_ID;
 -- new column  to hold number of days for advanced receipts.
    p_to.num_days_hold_adv_pay := p_from.num_days_hold_adv_pay;
  END migrate;
/*
  PROCEDURE migrate (
    p_from	IN cat_rec_type,
    p_to	IN OUT NOCOPY okl_cash_allctn_rls_h_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.amount_tolerance_percent := p_from.amount_tolerance_percent;
    p_to.days_past_quote_valid_toleranc := p_from.days_past_quote_valid_toleranc;
    p_to.months_to_bill_ahead := p_from.months_to_bill_ahead;
	p_to.under_payment_allocation_code := p_from.under_payment_allocation_code;
	p_to.over_payment_allocation_code := p_from.over_payment_allocation_code;
	p_to.receipt_msmtch_allocation_code := p_from.receipt_msmtch_allocation_code;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_CASH_ALLCTN_RLS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_cat_rec                      cat_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_catv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_catv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:CATV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- insert_row for:OKL_CASH_ALLCTN_RLS_H --
  ------------------------------------------
/*  -- history tables not supported -- 04 APR 2002
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cash_allctn_rls_h_rec    IN okl_cash_allctn_rls_h_rec_type,
    x_okl_cash_allctn_rls_h_rec    OUT NOCOPY okl_cash_allctn_rls_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'H_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_cash_allctn_rls_h_rec    okl_cash_allctn_rls_h_rec_type := p_okl_cash_allctn_rls_h_rec;
    ldefoklcashallctnrlshrec       okl_cash_allctn_rls_h_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CASH_ALLCTN_RLS_H --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cash_allctn_rls_h_rec IN  okl_cash_allctn_rls_h_rec_type,
      x_okl_cash_allctn_rls_h_rec OUT NOCOPY okl_cash_allctn_rls_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cash_allctn_rls_h_rec := p_okl_cash_allctn_rls_h_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_cash_allctn_rls_h_rec,       -- IN
      l_okl_cash_allctn_rls_h_rec);      -- OUT
    --- If any errors happen abort API

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_okl_cash_allctn_rls_h_rec.ID := get_seq_id;

    INSERT INTO OKL_CASH_ALLCTN_RLS_H(
        id,
        major_version,
        name,
        object_version_number,
        description,
        amount_tolerance_percent,
        days_past_quote_valid_toleranc,
        months_to_bill_ahead,
	under_payment_allocation_code,
        over_payment_allocation_code,
        receipt_msmtch_allocation_code,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_cash_allctn_rls_h_rec.id,
--      l_okl_cash_allctn_rls_h_rec.major_version,
        1,
        l_okl_cash_allctn_rls_h_rec.name,
        l_okl_cash_allctn_rls_h_rec.object_version_number,
        l_okl_cash_allctn_rls_h_rec.description,
        l_okl_cash_allctn_rls_h_rec.amount_tolerance_percent,
        l_okl_cash_allctn_rls_h_rec.days_past_quote_valid_toleranc,
        l_okl_cash_allctn_rls_h_rec.months_to_bill_ahead,
	l_okl_cash_allctn_rls_h_rec.under_payment_allocation_code,
        l_okl_cash_allctn_rls_h_rec.over_payment_allocation_code,
        l_okl_cash_allctn_rls_h_rec.receipt_msmtch_allocation_code,
        l_okl_cash_allctn_rls_h_rec.attribute_category,
        l_okl_cash_allctn_rls_h_rec.attribute1,
        l_okl_cash_allctn_rls_h_rec.attribute2,
        l_okl_cash_allctn_rls_h_rec.attribute3,
        l_okl_cash_allctn_rls_h_rec.attribute4,
        l_okl_cash_allctn_rls_h_rec.attribute5,
        l_okl_cash_allctn_rls_h_rec.attribute6,
        l_okl_cash_allctn_rls_h_rec.attribute7,
        l_okl_cash_allctn_rls_h_rec.attribute8,
        l_okl_cash_allctn_rls_h_rec.attribute9,
        l_okl_cash_allctn_rls_h_rec.attribute10,
        l_okl_cash_allctn_rls_h_rec.attribute11,
        l_okl_cash_allctn_rls_h_rec.attribute12,
        l_okl_cash_allctn_rls_h_rec.attribute13,
        l_okl_cash_allctn_rls_h_rec.attribute14,
        l_okl_cash_allctn_rls_h_rec.attribute15,
        l_okl_cash_allctn_rls_h_rec.created_by,
        l_okl_cash_allctn_rls_h_rec.creation_date,
        l_okl_cash_allctn_rls_h_rec.last_updated_by,
        l_okl_cash_allctn_rls_h_rec.last_update_date,
        l_okl_cash_allctn_rls_h_rec.last_update_login);
    -- Set OUT values
    x_okl_cash_allctn_rls_h_rec := l_okl_cash_allctn_rls_h_rec;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
*/

  ----------------------------------------
  -- insert_row for:OKL_CASH_ALLCTN_RLS --
  ----------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : insert_row
  -- Description     : Inserts the row in the table OKL_CASH_ALLCTN_RLS.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_cat_rec, x_cat_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type,
    x_cat_rec                      OUT NOCOPY cat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RLS_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type := p_cat_rec;
    l_def_cat_rec                  cat_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CASH_ALLCTN_RLS --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_cat_rec IN  cat_rec_type,
      x_cat_rec OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cat_rec := p_cat_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cat_rec,                         -- IN
      l_cat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CASH_ALLCTN_RLS(
        id,
        name,
        object_version_number,
        description,
        start_date,
        end_date,
        amount_tolerance_percent,
        days_past_quote_valid_toleranc,
        months_to_bill_ahead,
		under_payment_allocation_code,
		over_payment_allocation_code,
		receipt_msmtch_allocation_code,
        default_rule,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
	       num_days_hold_adv_pay)
      VALUES (
        l_cat_rec.id,
        l_cat_rec.name,
        l_cat_rec.object_version_number,
        l_cat_rec.description,
        l_cat_rec.start_date,
        l_cat_rec.end_date,
        l_cat_rec.amount_tolerance_percent,
        l_cat_rec.days_past_quote_valid_toleranc,
        l_cat_rec.months_to_bill_ahead,
		l_cat_rec.under_payment_allocation_code,
		l_cat_rec.over_payment_allocation_code,
		l_cat_rec.receipt_msmtch_allocation_code,
		l_cat_rec.default_rule,
        l_cat_rec.attribute_category,
        l_cat_rec.attribute1,
        l_cat_rec.attribute2,
        l_cat_rec.attribute3,
        l_cat_rec.attribute4,
        l_cat_rec.attribute5,
        l_cat_rec.attribute6,
        l_cat_rec.attribute7,
        l_cat_rec.attribute8,
        l_cat_rec.attribute9,
        l_cat_rec.attribute10,
        l_cat_rec.attribute11,
        l_cat_rec.attribute12,
        l_cat_rec.attribute13,
        l_cat_rec.attribute14,
        l_cat_rec.attribute15,
        l_cat_rec.org_id,
        l_cat_rec.created_by,
        l_cat_rec.creation_date,
        l_cat_rec.last_updated_by,
        l_cat_rec.last_update_date,
        l_cat_rec.last_update_login,
        l_cat_rec.CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
	l_cat_rec.num_days_hold_adv_pay);
    -- Set OUT values
    x_cat_rec := l_cat_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      NULL;
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_CASH_ALLCTN_RLS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type;
    l_def_catv_rec                 catv_rec_type;
    l_cat_rec                      cat_rec_type;
    lx_cat_rec                     cat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_catv_rec	IN catv_rec_type
    ) RETURN catv_rec_type IS
      l_catv_rec	catv_rec_type := p_catv_rec;
    BEGIN
      l_catv_rec.CREATION_DATE := SYSDATE;
      l_catv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_catv_rec.LAST_UPDATE_DATE := l_catv_rec.CREATION_DATE;
      l_catv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_catv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_catv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CASH_ALLCTN_RLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_catv_rec IN  catv_rec_type,
      x_catv_rec OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_catv_rec := p_catv_rec;
      x_catv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
/*
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/
    l_catv_rec := null_out_defaults(p_catv_rec);
    -- Set primary key value
    l_catv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_catv_rec,                        -- IN
      l_def_catv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_catv_rec := fill_who_columns(l_def_catv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_catv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_catv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec,
      lx_cat_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cat_rec, l_def_catv_rec);
    -- Set OUT values
    x_catv_rec := l_def_catv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
      WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
     */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
     */
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i),
          x_catv_rec                     => x_catv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- lock_row for:OKL_CASH_ALLCTN_RLS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cat_rec IN cat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CASH_ALLCTN_RLS
     WHERE ID = p_cat_rec.id
       AND OBJECT_VERSION_NUMBER = p_cat_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cat_rec IN cat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CASH_ALLCTN_RLS
    WHERE ID = p_cat_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RLS_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CASH_ALLCTN_RLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CASH_ALLCTN_RLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_cat_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cat_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cat_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cat_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_CASH_ALLCTN_RLS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CATV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- update_row for:OKL_CASH_ALLCTN_RLS --
  ----------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Update the existing row in the table OKL_CASH_ALLCTN_RLS
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_cat_rec, x_cat_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type,
    x_cat_rec                      OUT NOCOPY cat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RLS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type := p_cat_rec;
    l_def_cat_rec                  cat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;

-- history tables not supported -- 04 APR 2002
--    l_okl_cash_allctn_rls_h_rec    okl_cash_allctn_rls_h_rec_type;
--    lx_okl_cash_allctn_rls_h_rec   okl_cash_allctn_rls_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_cat_rec	IN cat_rec_type,
      x_cat_rec	OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_cat_rec                      cat_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cat_rec := p_cat_rec;
      -- Get current database values
      l_cat_rec := get_rec(p_cat_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database

-- history tables not supported -- 04 APR 2002
--      migrate(l_cat_rec, l_okl_cash_allctn_rls_h_rec);

      IF (x_cat_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.id := l_cat_rec.id;
      END IF;
      IF (x_cat_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.name := l_cat_rec.name;
      END IF;
      IF (x_cat_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.object_version_number := l_cat_rec.object_version_number;
      END IF;
      IF (x_cat_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.description := l_cat_rec.description;
      END IF;

      IF (x_cat_rec.start_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cat_rec.start_date := l_cat_rec.start_date;
      END IF;

      IF (x_cat_rec.end_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cat_rec.end_date := l_cat_rec.end_date;
      END IF;

      IF (x_cat_rec.amount_tolerance_percent = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.amount_tolerance_percent := l_cat_rec.amount_tolerance_percent;
      END IF;
      IF (x_cat_rec.days_past_quote_valid_toleranc = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.days_past_quote_valid_toleranc := l_cat_rec.days_past_quote_valid_toleranc;
      END IF;
      IF (x_cat_rec.months_to_bill_ahead = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.months_to_bill_ahead := l_cat_rec.months_to_bill_ahead;
      END IF;
	  IF (x_cat_rec.under_payment_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.under_payment_allocation_code := l_cat_rec.under_payment_allocation_code;
      END IF;
	  IF (x_cat_rec.over_payment_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.over_payment_allocation_code := l_cat_rec.over_payment_allocation_code;
      END IF;
	  IF (x_cat_rec.receipt_msmtch_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.receipt_msmtch_allocation_code := l_cat_rec.receipt_msmtch_allocation_code;
      END IF;
	  IF (x_cat_rec.default_rule = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.default_rule := l_cat_rec.default_rule;
      END IF;
      IF (x_cat_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute_category := l_cat_rec.attribute_category;
      END IF;
      IF (x_cat_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute1 := l_cat_rec.attribute1;
      END IF;
      IF (x_cat_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute2 := l_cat_rec.attribute2;
      END IF;
      IF (x_cat_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute3 := l_cat_rec.attribute3;
      END IF;
      IF (x_cat_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute4 := l_cat_rec.attribute4;
      END IF;
      IF (x_cat_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute5 := l_cat_rec.attribute5;
      END IF;
      IF (x_cat_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute6 := l_cat_rec.attribute6;
      END IF;
      IF (x_cat_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute7 := l_cat_rec.attribute7;
      END IF;
      IF (x_cat_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute8 := l_cat_rec.attribute8;
      END IF;
      IF (x_cat_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute9 := l_cat_rec.attribute9;
      END IF;
      IF (x_cat_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute10 := l_cat_rec.attribute10;
      END IF;
      IF (x_cat_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute11 := l_cat_rec.attribute11;
      END IF;
      IF (x_cat_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute12 := l_cat_rec.attribute12;
      END IF;
      IF (x_cat_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute13 := l_cat_rec.attribute13;
      END IF;
      IF (x_cat_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute14 := l_cat_rec.attribute14;
      END IF;
      IF (x_cat_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cat_rec.attribute15 := l_cat_rec.attribute15;
      END IF;
      IF (x_cat_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.org_id := l_cat_rec.org_id;
      END IF;
      IF (x_cat_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.created_by := l_cat_rec.created_by;
      END IF;
      IF (x_cat_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cat_rec.creation_date := l_cat_rec.creation_date;
      END IF;
      IF (x_cat_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.last_updated_by := l_cat_rec.last_updated_by;
      END IF;
      IF (x_cat_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cat_rec.last_update_date := l_cat_rec.last_update_date;
      END IF;
      IF (x_cat_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.last_update_login := l_cat_rec.last_update_login;
      END IF;

      IF (x_cat_rec.CAU_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.CAU_ID := l_cat_rec.CAU_ID;
      END IF;
      -- new column  to hold number of days to reserve advanced payment for contract.
      IF (x_cat_rec.num_days_hold_adv_pay = Okl_Api.G_MISS_NUM)
      THEN
        x_cat_rec.num_days_hold_adv_pay := l_cat_rec.num_days_hold_adv_pay;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CASH_ALLCTN_RLS --
    --------------------------------------------

    FUNCTION Set_Attributes (
      p_cat_rec IN  cat_rec_type,
      x_cat_rec OUT NOCOPY cat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cat_rec := p_cat_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cat_rec,                         -- IN
      l_cat_rec);                        -- OUT

    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cat_rec, l_def_cat_rec);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_CASH_ALLCTN_RLS
    SET NAME = l_def_cat_rec.name,
        OBJECT_VERSION_NUMBER = l_def_cat_rec.object_version_number,
        DESCRIPTION = l_def_cat_rec.description,
        start_date = l_def_cat_rec.start_date,
        end_date = l_def_cat_rec.end_date,
        AMOUNT_TOLERANCE_PERCENT = l_def_cat_rec.amount_tolerance_percent,
        DAYS_PAST_QUOTE_VALID_TOLERANC = l_def_cat_rec.days_past_quote_valid_toleranc,
        MONTHS_TO_BILL_AHEAD = l_def_cat_rec.months_to_bill_ahead,
		UNDER_PAYMENT_ALLOCATION_CODE = l_def_cat_rec.under_payment_allocation_code,
		OVER_PAYMENT_ALLOCATION_CODE = l_def_cat_rec.over_payment_allocation_code,
		RECEIPT_MSMTCH_ALLOCATION_CODE = l_def_cat_rec.receipt_msmtch_allocation_code,
		DEFAULT_RULE = l_def_cat_rec.default_rule,
        ATTRIBUTE_CATEGORY = l_def_cat_rec.attribute_category,
        ATTRIBUTE1 = l_def_cat_rec.attribute1,
        ATTRIBUTE2 = l_def_cat_rec.attribute2,
        ATTRIBUTE3 = l_def_cat_rec.attribute3,
        ATTRIBUTE4 = l_def_cat_rec.attribute4,
        ATTRIBUTE5 = l_def_cat_rec.attribute5,
        ATTRIBUTE6 = l_def_cat_rec.attribute6,
        ATTRIBUTE7 = l_def_cat_rec.attribute7,
        ATTRIBUTE8 = l_def_cat_rec.attribute8,
        ATTRIBUTE9 = l_def_cat_rec.attribute9,
        ATTRIBUTE10 = l_def_cat_rec.attribute10,
        ATTRIBUTE11 = l_def_cat_rec.attribute11,
        ATTRIBUTE12 = l_def_cat_rec.attribute12,
        ATTRIBUTE13 = l_def_cat_rec.attribute13,
        ATTRIBUTE14 = l_def_cat_rec.attribute14,
        ATTRIBUTE15 = l_def_cat_rec.attribute15,
        ORG_ID = l_def_cat_rec.org_id,
        CREATED_BY = l_def_cat_rec.created_by,
        CREATION_DATE = l_def_cat_rec.creation_date,
        LAST_UPDATED_BY = l_def_cat_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cat_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cat_rec.last_update_login,
        CAU_ID = l_def_cat_rec.CAU_ID,
      -- new column  to hold number of days to reserve advanced payment for contract.
      	NUM_DAYS_HOLD_ADV_PAY = l_def_cat_rec.num_days_hold_adv_pay
    WHERE ID = l_def_cat_rec.id;

/*  -- history tables not supported -- 04 APR 2002
    -- Insert into History table

    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cash_allctn_rls_h_rec,
      lx_okl_cash_allctn_rls_h_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/

    x_cat_rec := l_def_cat_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
    NULL;
    /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */

  END update_row;
  ------------------------------------------
  -- update_row for:OKL_CASH_ALLCTN_RLS_V --
  ------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : update_row
  -- Description     : Update the row in the table OKL_CASH_ALLCTN_RLS.
  -- Business Rules  :
  -- Parameters      : p_init_msg_list, x_return_status, x_msg_count, x_msg_data,
  --                   p_catv_rec, x_catv_rec
  -- Version         : 1.0
  -- History         : 25-AUG-04 abindal modified to include NUM_OF_DAYS_TO_HOLD_ADV_PAY column.
  --                 : 12-oct-04 sjalasut changed the column NUM_OF_DAYS_TO_HOLD_ADV_PAY
  --                                      to NUM_DAYS_HOLD_ADV_PAY per user defined streams build
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_def_catv_rec                 catv_rec_type;
    l_cat_rec                      cat_rec_type;
    lx_cat_rec                     cat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_catv_rec	IN catv_rec_type
    ) RETURN catv_rec_type IS
      l_catv_rec	catv_rec_type := p_catv_rec;
    BEGIN
      l_catv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_catv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_catv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_catv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------

    FUNCTION populate_new_record (
      p_catv_rec	IN catv_rec_type,
      x_catv_rec	OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_catv_rec                     catv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_catv_rec := p_catv_rec;
      -- Get current database values
      l_catv_rec := get_rec(p_catv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_catv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.id := l_catv_rec.id;
      END IF;
      IF (x_catv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.object_version_number := l_catv_rec.object_version_number;
      END IF;
      IF (x_catv_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.name := l_catv_rec.name;
      END IF;
      IF (x_catv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.description := l_catv_rec.description;
      END IF;

      IF (x_catv_rec.start_date = Okl_Api.G_MISS_DATE)
      THEN
        x_catv_rec.start_date := l_catv_rec.start_date;
      END IF;

      IF (x_catv_rec.end_date = Okl_Api.G_MISS_DATE)
      THEN
        x_catv_rec.end_date := l_catv_rec.end_date;
      END IF;

      IF (x_catv_rec.amount_tolerance_percent = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.amount_tolerance_percent := l_catv_rec.amount_tolerance_percent;
      END IF;
      IF (x_catv_rec.days_past_quote_valid_toleranc = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.days_past_quote_valid_toleranc := l_catv_rec.days_past_quote_valid_toleranc;
      END IF;
      IF (x_catv_rec.months_to_bill_ahead = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.months_to_bill_ahead := l_catv_rec.months_to_bill_ahead;
      END IF;
      IF (x_catv_rec.under_payment_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.under_payment_allocation_code := l_catv_rec.under_payment_allocation_code;
      END IF;
      IF (x_catv_rec.over_payment_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.over_payment_allocation_code := l_catv_rec.over_payment_allocation_code;
      END IF;
      IF (x_catv_rec.receipt_msmtch_allocation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.receipt_msmtch_allocation_code := l_catv_rec.receipt_msmtch_allocation_code;
      END IF;
      IF (x_catv_rec.default_rule = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.default_rule := l_catv_rec.default_rule;
      END IF;
      IF (x_catv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute_category := l_catv_rec.attribute_category;
      END IF;
      IF (x_catv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute1 := l_catv_rec.attribute1;
      END IF;
      IF (x_catv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute2 := l_catv_rec.attribute2;
      END IF;
      IF (x_catv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute3 := l_catv_rec.attribute3;
      END IF;
      IF (x_catv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute4 := l_catv_rec.attribute4;
      END IF;
      IF (x_catv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute5 := l_catv_rec.attribute5;
      END IF;
      IF (x_catv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute6 := l_catv_rec.attribute6;
      END IF;
      IF (x_catv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute7 := l_catv_rec.attribute7;
      END IF;
      IF (x_catv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute8 := l_catv_rec.attribute8;
      END IF;
      IF (x_catv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute9 := l_catv_rec.attribute9;
      END IF;
      IF (x_catv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute10 := l_catv_rec.attribute10;
      END IF;
      IF (x_catv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute11 := l_catv_rec.attribute11;
      END IF;
      IF (x_catv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute12 := l_catv_rec.attribute12;
      END IF;
      IF (x_catv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute13 := l_catv_rec.attribute13;
      END IF;
      IF (x_catv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute14 := l_catv_rec.attribute14;
      END IF;
      IF (x_catv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_catv_rec.attribute15 := l_catv_rec.attribute15;
      END IF;
      IF (x_catv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.org_id := l_catv_rec.org_id;
      END IF;
      IF (x_catv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.created_by := l_catv_rec.created_by;
      END IF;
      IF (x_catv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_catv_rec.creation_date := l_catv_rec.creation_date;
      END IF;
      IF (x_catv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.last_updated_by := l_catv_rec.last_updated_by;
      END IF;
      IF (x_catv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_catv_rec.last_update_date := l_catv_rec.last_update_date;
      END IF;
      IF (x_catv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.last_update_login := l_catv_rec.last_update_login;
      END IF;

      IF (x_catv_rec.CAU_ID = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.CAU_ID := l_catv_rec.CAU_ID;
      END IF;
      -- new column  to hold number of days to reserve advanced payment for contract.
      IF (x_catv_rec.num_days_hold_adv_pay = Okl_Api.G_MISS_NUM)
      THEN
        x_catv_rec.num_days_hold_adv_pay := l_catv_rec.num_days_hold_adv_pay;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CASH_ALLCTN_RLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_catv_rec IN  catv_rec_type,
      x_catv_rec OUT NOCOPY catv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_catv_rec := p_catv_rec;
      x_catv_rec.OBJECT_VERSION_NUMBER := NVL(x_catv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

-- this caused probs before.

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_catv_rec,                        -- IN
      l_catv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_catv_rec, l_def_catv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_catv_rec := fill_who_columns(l_def_catv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_catv_rec);      -- this is failing ....
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_catv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------


    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec,
      lx_cat_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cat_rec, l_def_catv_rec);
    x_catv_rec := l_def_catv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
    null;
      x_return_status := 'U';
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
     */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    null;
     x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
    NULL;
     x_return_status := 'U';
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

     */
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i),
          x_catv_rec                     => x_catv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- delete_row for:OKL_CASH_ALLCTN_RLS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_rec                      IN cat_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RLS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cat_rec                      cat_rec_type:= p_cat_rec;
    l_row_notfound                 BOOLEAN := TRUE;

-- history tables not supported -- 04 APR 2002
--  l_okl_cash_allctn_rls_h_rec    okl_cash_allctn_rls_h_rec_type;
--  lx_okl_cash_allctn_rls_h_rec   okl_cash_allctn_rls_h_rec_type;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    -- Insert into History table
    l_cat_rec := get_rec(l_cat_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

--    history tables not supported -- 04 APR 2002
--    migrate(l_cat_rec, l_okl_cash_allctn_rls_h_rec);
/*
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cash_allctn_rls_h_rec,
      lx_okl_cash_allctn_rls_h_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/

    DELETE FROM OKL_CASH_ALLCTN_RLS
     WHERE ID = l_cat_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------
  -- delete_row for:OKL_CASH_ALLCTN_RLS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_catv_rec                     catv_rec_type := p_catv_rec;
    l_cat_rec                      cat_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_catv_rec, l_cat_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cat_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:CATV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Begin Post-Generation Change
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_catv_tbl.COUNT > 0) THEN
      i := p_catv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_catv_rec                     => p_catv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_catv_tbl.LAST);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Cat_Pvt;

/

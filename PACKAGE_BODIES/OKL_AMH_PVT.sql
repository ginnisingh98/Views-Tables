--------------------------------------------------------
--  DDL for Package Body OKL_AMH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AMH_PVT" AS
/* $Header: OKLSAMHB.pls 120.7 2006/08/07 14:36:12 dcshanmu noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY okl_api.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a okl_api.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN okl_api.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> okl_api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> okl_api.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
  -- FUNCTION get_rec for: OKL_AMORT_HOLD_SETUPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_amhv_rec                     IN amhv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN amhv_rec_type IS
    CURSOR okl_amhv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            HOLD_PERIOD_DAYS,
            CATEGORY_ID,
            BOOK_TYPE_CODE,
            METHOD_ID,
            -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
            deprn_rate,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_AMORT_HOLD_SETUPS
     WHERE OKL_AMORT_HOLD_SETUPS.id = p_id;
    l_okl_amhv_pk                  okl_amhv_pk_csr%ROWTYPE;
    l_amhv_rec                     amhv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_amhv_pk_csr (p_amhv_rec.id);
    FETCH okl_amhv_pk_csr INTO
              l_amhv_rec.id,
              l_amhv_rec.object_version_number,
              l_amhv_rec.hold_period_days,
              l_amhv_rec.category_id,
              l_amhv_rec.book_type_code,
              l_amhv_rec.method_id,
              -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
              l_amhv_rec.deprn_rate,
              l_amhv_rec.org_id,
              l_amhv_rec.created_by,
              l_amhv_rec.creation_date,
              l_amhv_rec.last_updated_by,
              l_amhv_rec.last_update_date,
              l_amhv_rec.last_update_login;
    x_no_data_found := okl_amhv_pk_csr%NOTFOUND;
    CLOSE okl_amhv_pk_csr;
    RETURN(l_amhv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_amhv_rec                     IN amhv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN amhv_rec_type IS
    l_amhv_rec                     amhv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_amhv_rec := get_rec(p_amhv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      okl_api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := okl_api.G_RET_STS_ERROR;
    ELSE
      x_return_status := okl_api.G_RET_STS_SUCCESS;
    END IF;
    RETURN(l_amhv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_amhv_rec                     IN amhv_rec_type
  ) RETURN amhv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_amhv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AMORT_HOLD_SETUPS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_amh_rec                      IN amh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN amh_rec_type IS
    CURSOR amh_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            HOLD_PERIOD_DAYS,
            CATEGORY_ID,
            BOOK_TYPE_CODE,
            METHOD_ID,
            -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
            deprn_rate,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Amort_Hold_Setups
     WHERE okl_amort_hold_setups.id = p_id;
    l_amh_pk                       amh_pk_csr%ROWTYPE;
    l_amh_rec                      amh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN amh_pk_csr (p_amh_rec.id);
    FETCH amh_pk_csr INTO
              l_amh_rec.id,
              l_amh_rec.object_version_number,
              l_amh_rec.hold_period_days,
              l_amh_rec.category_id,
              l_amh_rec.book_type_code,
              l_amh_rec.method_id,
              -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
              l_amh_rec.deprn_rate,
              l_amh_rec.org_id,
              l_amh_rec.created_by,
              l_amh_rec.creation_date,
              l_amh_rec.last_updated_by,
              l_amh_rec.last_update_date,
              l_amh_rec.last_update_login;
    x_no_data_found := amh_pk_csr%NOTFOUND;
    CLOSE amh_pk_csr;
    RETURN(l_amh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_amh_rec                      IN amh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN amh_rec_type IS
    l_amh_rec                      amh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_amh_rec := get_rec(p_amh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      okl_api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_amh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_amh_rec                      IN amh_rec_type
  ) RETURN amh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_amh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AMORT_HOLD_SETUPS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_amhv_rec   IN amhv_rec_type
  ) RETURN amhv_rec_type IS
    l_amhv_rec                     amhv_rec_type := p_amhv_rec;
  BEGIN
    IF (l_amhv_rec.id = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.id := NULL;
    END IF;
    IF (l_amhv_rec.object_version_number = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.object_version_number := NULL;
    END IF;
    IF (l_amhv_rec.hold_period_days = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.hold_period_days := NULL;
    END IF;
    IF (l_amhv_rec.category_id = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.category_id := NULL;
    END IF;
    IF (l_amhv_rec.book_type_code = okl_api.G_MISS_CHAR ) THEN
      l_amhv_rec.book_type_code := NULL;
    END IF;
    IF (l_amhv_rec.method_id = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.method_id := NULL;
    END IF;

    -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
    IF (l_amhv_rec.deprn_rate = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.deprn_rate := NULL;
    END IF;


    IF (l_amhv_rec.org_id = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.org_id := NULL;
    END IF;
    IF (l_amhv_rec.created_by = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.created_by := NULL;
    END IF;
    IF (l_amhv_rec.creation_date = okl_api.G_MISS_DATE ) THEN
      l_amhv_rec.creation_date := NULL;
    END IF;
    IF (l_amhv_rec.last_updated_by = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.last_updated_by := NULL;
    END IF;
    IF (l_amhv_rec.last_update_date = okl_api.G_MISS_DATE ) THEN
      l_amhv_rec.last_update_date := NULL;
    END IF;
    IF (l_amhv_rec.last_update_login = okl_api.G_MISS_NUM ) THEN
      l_amhv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_amhv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := okl_api.G_RET_STS_SUCCESS;
    IF (p_id = okl_api.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      okl_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := okl_api.G_RET_STS_SUCCESS;
    IF (p_object_version_number = okl_api.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      okl_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ------------------------------------------
  -- Validate_Attributes for: CATEGORY_ID --
  ------------------------------------------
  PROCEDURE validate_category_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_category_id                  IN NUMBER) IS
  BEGIN
    x_return_status := okl_api.G_RET_STS_SUCCESS;

    IF (p_category_id = okl_api.G_MISS_NUM OR
        p_category_id IS NULL)
    THEN
      okc_api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Asset Category');
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  /*
    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_AMORT_HOLD_SETUPS_V'
                          ,p_col_name      => 'category_id'
                          ,p_col_value     => p_category_id
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    */
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      okl_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
  END validate_category_id;
  ---------------------------------------------
  -- Validate_Attributes for: BOOK_TYPE_CODE --
  ---------------------------------------------
  PROCEDURE validate_book_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_book_type_code               IN VARCHAR2) IS
  BEGIN

    x_return_status := okl_api.G_RET_STS_SUCCESS;

    IF (p_book_type_code = okl_api.G_MISS_CHAR OR
        p_book_type_code IS NULL)
    THEN
--      okc_api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Asset Book');
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'Asset Book');

      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Verify the value fits the length of the column in the database
    /*
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_AMORT_HOLD_SETUPS_V'
                          ,p_col_name      => 'book_type_code'
                          ,p_col_value     => p_book_type_code
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
      x_return_status := okl_api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      okl_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
  END validate_book_type_code;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_AMORT_HOLD_SETUPS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_amhv_rec                     IN amhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN

    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(l_return_status, p_amhv_rec.id);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_amhv_rec.object_version_number);
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;


    -- ***
    -- category_id
    -- ***
    validate_category_id(l_return_status, p_amhv_rec.category_id);
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;


    -- ***
    -- book_type_code
    -- ***
    validate_book_type_code(l_return_status, p_amhv_rec.book_type_code);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    RETURN(x_return_status);
  EXCEPTION
-- Code by Ravi : Removed the G_EXCEPTION_HALT_VALIDATION --
--    WHEN G_EXCEPTION_HALT_VALIDATION THEN
  --    RETURN(l_return_status);
-- End of Code by Ravi
    WHEN OTHERS THEN
      okc_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate Record for:OKL_AMORT_HOLD_SETUPS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_amhv_rec IN amhv_rec_type,
    p_db_amhv_rec IN amhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_amhv_rec IN amhv_rec_type,
      p_db_amhv_rec IN amhv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_amhv_acg_fk_csr (p_id1 IN VARCHAR2) IS
      SELECT 'x'
        FROM Okx_Asst_Catgrs_V
       WHERE okx_asst_catgrs_v.id1 = p_id1;
      l_okl_amhv_acg_fk              okl_amhv_acg_fk_csr%ROWTYPE;

      CURSOR okl_amhv_abk_fk_csr (p_id1 IN VARCHAR2) IS
      SELECT 'x'
      FROM   Okx_Asst_Bk_Controls_V
      WHERE okx_asst_bk_controls_v.id1 = p_id1;

      l_okl_amhv_abk_fk              okl_amhv_abk_fk_csr%ROWTYPE;

      CURSOR okl_amhv_adm_fk_csr (p_id1 IN VARCHAR2) IS
      SELECT 'x'
      -- SECHAWLA 26-MAY-04 3645574 : use the new view
      --FROM Okx_Asst_Dep_Methods_V
      FROM  OKL_AM_ASST_DEP_METHODS_UV
      WHERE OKL_AM_ASST_DEP_METHODS_UV.id1 = p_id1;

      -- SECHAWLA 26-MAY-04 3645574 : New cursor
      CURSOR fa_flat_rates_csr(p_method_id IN NUMBER, p_deprn_rate IN NUMBER  ) IS
      SELECT 'x'
      FROM   fa_flat_rates
      WHERE  method_id = p_method_id
      AND    adjusted_rate = p_deprn_rate/100  -- rate is passed from the screen as a percentage but stored as the actual value
      AND    nvl(adjusting_rate,0) = 0 ;


      l_okl_amhv_adm_fk              okl_amhv_adm_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
      x_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

      -- SECHAWLA 26-MAY-04 3645574 : new declarations
      l_dummy                        VARCHAR2(1);
    BEGIN

      IF ((p_amhv_rec.CATEGORY_ID IS NOT NULL)
       AND
          (p_amhv_rec.CATEGORY_ID <> p_db_amhv_rec.CATEGORY_ID))
      THEN
        OPEN okl_amhv_acg_fk_csr (p_amhv_rec.CATEGORY_ID);
        FETCH okl_amhv_acg_fk_csr INTO l_okl_amhv_acg_fk;
        l_row_notfound := okl_amhv_acg_fk_csr%NOTFOUND;
        CLOSE okl_amhv_acg_fk_csr;
        IF (l_row_notfound) THEN
          okl_api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CATEGORY_ID');
          --RAISE item_not_found_error;
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
        end if;
      end if;

      IF ((p_amhv_rec.METHOD_ID IS NOT NULL)
       AND
          (p_amhv_rec.METHOD_ID <> p_db_amhv_rec.METHOD_ID))
      THEN
        OPEN okl_amhv_adm_fk_csr (p_amhv_rec.METHOD_ID);
        FETCH okl_amhv_adm_fk_csr INTO l_okl_amhv_adm_fk;
        l_row_notfound := okl_amhv_adm_fk_csr%NOTFOUND;
        CLOSE okl_amhv_adm_fk_csr;
        IF (l_row_notfound) THEN
          okl_api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'METHOD_ID');
          --RAISE item_not_found_error;
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
        end if;
      end if;

      -- SECHAWLA 26-MAY-04 3645574 : Validate depreciation rate
      IF (p_amhv_rec.deprn_rate IS NOT NULL) THEN

        IF (p_amhv_rec.METHOD_ID IS NULL) THEN
           okl_api.SET_MESSAGE(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'METHOD_ID');
           l_return_status := OKL_API.G_RET_STS_ERROR;
        ELSE

           OPEN  fa_flat_rates_csr(p_amhv_rec.METHOD_ID, p_amhv_rec.deprn_rate );
           FETCH fa_flat_rates_csr INTO l_dummy;
           IF fa_flat_rates_csr%NOTFOUND THEN
              okl_api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DEPRN_RATE');
              l_return_status := OKL_API.G_RET_STS_ERROR;
           END IF;
           CLOSE fa_flat_rates_csr;
        END IF;
      END IF;


      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
        end if;
      end if;

      -- SECHAWLA 26-MAY-04 3645574 : End Validate depreciation rate

      IF ((p_amhv_rec.BOOK_TYPE_CODE IS NOT NULL)
       AND
          (p_amhv_rec.BOOK_TYPE_CODE <> p_db_amhv_rec.BOOK_TYPE_CODE))
      THEN
        OPEN okl_amhv_abk_fk_csr (p_amhv_rec.BOOK_TYPE_CODE);
        FETCH okl_amhv_abk_fk_csr INTO l_okl_amhv_abk_fk;
        l_row_notfound := okl_amhv_abk_fk_csr%NOTFOUND;
        CLOSE okl_amhv_abk_fk_csr;
        IF (l_row_notfound) THEN
          okl_api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BOOK_TYPE_CODE');
          --RAISE item_not_found_error;
          l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
        end if;
      end if;

      RETURN (x_return_status);
    EXCEPTION
      --WHEN item_not_found_error THEN
        --l_return_status := okl_api.G_RET_STS_ERROR;
        --RETURN (l_return_status);
     WHEN OTHERS THEN
      okl_api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
    END validate_foreign_keys;


    -- Start of comments
    --
    -- Procedure Name : validate_unique_keys
    -- Description    : validates the uniqueness of category and book type code
    -- Business Rules :
    -- Parameters     :
    -- Version        : 1.0
    -- History        : SECHAWLA 18-MAR-03 : Changed the app name to OKL for message OKL_AM_CAT_BOOK_NOT_UNIQUE
    --                  SECHAWLA 05-MAY-04 3578894 : Display category description instead of category id in
    --                           message OKL_AM_CAT_BOOK_NOT_UNIQUE
    -- End of comments

    FUNCTION validate_unique_keys (
      p_amhv_rec IN amhv_rec_type
    ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_dummy                        VARCHAR2(1) := NULL;
    CURSOR okl_cat_book_unq_csr(p_id NUMBER, p_category_id NUMBER, p_book VARCHAR2) IS
    SELECT 'x'
    FROM   OKL_AMORT_HOLD_SETUPS
    WHERE  category_id = p_category_id
    AND    book_type_code = p_book
    AND    id <> nvl(p_id, -99999);

    --SECHAWLA 05-MAY-04 3578894 : Get the category description  for displaying in the error message OKL_AM_CAT_BOOK_NOT_UNIQUE
    CURSOR l_factegory_csr(p_cat_id IN NUMBER) IS
    SELECT description
    FROM   FA_CATEGORIES_VL
    WHERE  category_id = p_cat_id;

    l_cat_desc      FA_CATEGORIES_VL.description%TYPE;

    BEGIN

    OPEN  okl_cat_book_unq_csr(p_amhv_rec.id, p_amhv_rec.category_id,p_amhv_rec.book_type_code);
    FETCH okl_cat_book_unq_csr INTO l_dummy;
    CLOSE okl_cat_book_unq_csr;

    IF l_dummy = 'x' THEN

       OPEN  l_factegory_csr(p_amhv_rec.category_id);
       FETCH l_factegory_csr INTO l_cat_desc;
       CLOSE l_factegory_csr;


       -- SECHAWLA 18-MAR-03 : Changed the app name to OKL
       okl_api.SET_MESSAGE( p_app_name     => 'OKL'
                          ,p_msg_name     => 'OKL_AM_CAT_BOOK_NOT_UNIQUE'
                          ,p_token1       => 'CATEGORY'
                          --SECHAWLA 05-MAY-04 3578894: display cat desc
                          --,p_token1_value => p_amhv_rec.category_id
                          ,p_token1_value => l_cat_desc
                          ,p_token2       => 'BOOK'
                          ,p_token2_value => p_amhv_rec.book_type_code);

        l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    RETURN l_return_status;
    END validate_unique_keys;

  BEGIN
    l_return_status := validate_foreign_keys(p_amhv_rec, p_db_amhv_rec);
    IF l_return_status <> okl_api.G_RET_STS_SUCCESS THEN
       l_overall_status := l_return_status;
    END IF;

    l_return_status := validate_unique_keys(p_amhv_rec);
    IF l_return_status <> okl_api.G_RET_STS_SUCCESS THEN
       l_overall_status := l_return_status;
    END IF;

    --RETURN (l_return_status);
    RETURN (l_overall_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_amhv_rec IN amhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_db_amhv_rec                  amhv_rec_type := get_rec(p_amhv_rec);
  BEGIN

    l_return_status := Validate_Record(p_amhv_rec => p_amhv_rec,
                                       p_db_amhv_rec => l_db_amhv_rec);

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN amhv_rec_type,
    p_to   IN OUT NOCOPY amh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.hold_period_days := p_from.hold_period_days;
    p_to.category_id := p_from.category_id;
    p_to.book_type_code := p_from.book_type_code;
    p_to.method_id := p_from.method_id;

    -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
    p_to.deprn_rate := p_from.deprn_rate;

    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN amh_rec_type,
    p_to   IN OUT NOCOPY amhv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.hold_period_days := p_from.hold_period_days;
    p_to.category_id := p_from.category_id;
    p_to.book_type_code := p_from.book_type_code;
    p_to.method_id := p_from.method_id;

    -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
    p_to.deprn_rate := p_from.deprn_rate;

    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKL_AMORT_HOLD_SETUPS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amhv_rec                     amhv_rec_type := p_amhv_rec;
    l_amh_rec                      amh_rec_type;
    l_amh_rec                      amh_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_amhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_amhv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_AMORT_HOLD_SETUPS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      i := p_amhv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         okl_api.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => okl_api.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_amhv_rec                     => p_amhv_tbl(i));
          IF (l_error_rec.error_type <> okl_api.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN okl_api.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_amhv_tbl.LAST);
        i := p_amhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_AMORT_HOLD_SETUPS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_error_tbl                    okl_api.ERROR_TBL_TYPE;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => okl_api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_amhv_tbl                     => p_amhv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_AMORT_HOLD_SETUPS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amh_rec                      IN amh_rec_type,
    x_amh_rec                      OUT NOCOPY amh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amh_rec                      amh_rec_type := p_amh_rec;
    l_def_amh_rec                  amh_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_AMORT_HOLD_SETUPS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_amh_rec IN amh_rec_type,
      x_amh_rec OUT NOCOPY amh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amh_rec := p_amh_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_amh_rec,                         -- IN
      l_amh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_AMORT_HOLD_SETUPS(
      id,
      object_version_number,
      hold_period_days,
      category_id,
      book_type_code,
      method_id,
      -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
      deprn_rate,
      org_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_amh_rec.id,
      l_amh_rec.object_version_number,
      l_amh_rec.hold_period_days,
      l_amh_rec.category_id,
      l_amh_rec.book_type_code,
      l_amh_rec.method_id,

      -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
      l_amh_rec.deprn_rate/100,

      l_amh_rec.org_id,
      l_amh_rec.created_by,
      l_amh_rec.creation_date,
      l_amh_rec.last_updated_by,
      l_amh_rec.last_update_date,
      l_amh_rec.last_update_login);
    -- Set OUT values
    x_amh_rec := l_amh_rec;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------------
  -- insert_row for :OKL_AMORT_HOLD_SETUPS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type,
    x_amhv_rec                     OUT NOCOPY amhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amhv_rec                     amhv_rec_type := p_amhv_rec;
    l_def_amhv_rec                 amhv_rec_type;
    l_amh_rec                      amh_rec_type;
    lx_amh_rec                     amh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_amhv_rec IN amhv_rec_type
    ) RETURN amhv_rec_type IS
      l_amhv_rec amhv_rec_type := p_amhv_rec;
    BEGIN
      l_amhv_rec.CREATION_DATE := SYSDATE;
      l_amhv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_amhv_rec.LAST_UPDATE_DATE := l_amhv_rec.CREATION_DATE;
      l_amhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_amhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_amhv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_AMORT_HOLD_SETUPS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_amhv_rec IN amhv_rec_type,
      x_amhv_rec OUT NOCOPY amhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amhv_rec := p_amhv_rec;
      x_amhv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Default the ORG ID if a value is not passed
      IF p_amhv_rec.org_id IS NULL
      OR p_amhv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_amhv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_amhv_rec := null_out_defaults(p_amhv_rec);
    -- Set primary key value
    l_amhv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_amhv_rec,                        -- IN
      l_def_amhv_rec);                   -- OUT
    --- If any errors happen abort API

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_def_amhv_rec := fill_who_columns(l_def_amhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_amhv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_amhv_rec);

    IF (l_return_status = okc_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okc_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okc_api.G_RET_STS_ERROR) THEN
      RAISE okc_api.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_amhv_rec, l_amh_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_amh_rec,
      lx_amh_rec
    );
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_amh_rec, l_def_amhv_rec);
    -- Set OUT values
    x_amhv_rec := l_def_amhv_rec;
    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
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
  -- PL/SQL TBL insert_row for:AMHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      i := p_amhv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         okl_api.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => okl_api.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_amhv_rec                     => p_amhv_tbl(i),
            x_amhv_rec                     => x_amhv_tbl(i));
          IF (l_error_rec.error_type <> okl_api.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN okl_api.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_amhv_tbl.LAST);
        i := p_amhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:AMHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_error_tbl                    okl_api.ERROR_TBL_TYPE;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => okl_api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_amhv_tbl                     => p_amhv_tbl,
        x_amhv_tbl                     => x_amhv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- lock_row for:OKL_AMORT_HOLD_SETUPS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amh_rec                      IN amh_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_amh_rec IN amh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AMORT_HOLD_SETUPS
     WHERE ID = p_amh_rec.id
       AND OBJECT_VERSION_NUMBER = p_amh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_amh_rec IN amh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AMORT_HOLD_SETUPS
     WHERE ID = p_amh_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_AMORT_HOLD_SETUPS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_AMORT_HOLD_SETUPS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_amh_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_amh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_amh_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_amh_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      okl_api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------------
  -- lock_row for: OKL_AMORT_HOLD_SETUPS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amh_rec                      amh_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_amhv_rec, l_amh_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_amh_rec
    );
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:AMHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      i := p_amhv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         okl_api.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => okl_api.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_amhv_rec                     => p_amhv_tbl(i));
          IF (l_error_rec.error_type <> okl_api.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN okl_api.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_amhv_tbl.LAST);
        i := p_amhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:AMHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_error_tbl                    okl_api.ERROR_TBL_TYPE;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => okl_api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_amhv_tbl                     => p_amhv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- update_row for:OKL_AMORT_HOLD_SETUPS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amh_rec                      IN amh_rec_type,
    x_amh_rec                      OUT NOCOPY amh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amh_rec                      amh_rec_type := p_amh_rec;
    l_def_amh_rec                  amh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_amh_rec IN amh_rec_type,
      x_amh_rec OUT NOCOPY amh_rec_type
    ) RETURN VARCHAR2 IS
      l_amh_rec                      amh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amh_rec := p_amh_rec;
      -- Get current database values
      l_amh_rec := get_rec(p_amh_rec, l_return_status);
      IF (l_return_status = okl_api.G_RET_STS_SUCCESS) THEN
        IF (x_amh_rec.id = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.id := l_amh_rec.id;
        END IF;
        IF (x_amh_rec.object_version_number = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.object_version_number := l_amh_rec.object_version_number;
        END IF;
        IF (x_amh_rec.hold_period_days = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.hold_period_days := l_amh_rec.hold_period_days;
        END IF;
        IF (x_amh_rec.category_id = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.category_id := l_amh_rec.category_id;
        END IF;
        IF (x_amh_rec.book_type_code = okl_api.G_MISS_CHAR)
        THEN
          x_amh_rec.book_type_code := l_amh_rec.book_type_code;
        END IF;
        IF (x_amh_rec.method_id = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.method_id := l_amh_rec.method_id;
        END IF;

        -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
        IF (x_amh_rec.deprn_rate = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.deprn_rate := l_amh_rec.deprn_rate;
        END IF;


        IF (x_amh_rec.org_id = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.org_id := l_amh_rec.org_id;
        END IF;
        IF (x_amh_rec.created_by = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.created_by := l_amh_rec.created_by;
        END IF;
        IF (x_amh_rec.creation_date = okl_api.G_MISS_DATE)
        THEN
          x_amh_rec.creation_date := l_amh_rec.creation_date;
        END IF;
        IF (x_amh_rec.last_updated_by = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.last_updated_by := l_amh_rec.last_updated_by;
        END IF;
        IF (x_amh_rec.last_update_date = okl_api.G_MISS_DATE)
        THEN
          x_amh_rec.last_update_date := l_amh_rec.last_update_date;
        END IF;
        IF (x_amh_rec.last_update_login = okl_api.G_MISS_NUM)
        THEN
          x_amh_rec.last_update_login := l_amh_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_AMORT_HOLD_SETUPS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_amh_rec IN amh_rec_type,
      x_amh_rec OUT NOCOPY amh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amh_rec := p_amh_rec;
      x_amh_rec.OBJECT_VERSION_NUMBER := p_amh_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_amh_rec,                         -- IN
      l_amh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_amh_rec, l_def_amh_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_AMORT_HOLD_SETUPS
    SET OBJECT_VERSION_NUMBER = l_def_amh_rec.object_version_number,
        HOLD_PERIOD_DAYS = l_def_amh_rec.hold_period_days,
        CATEGORY_ID = l_def_amh_rec.category_id,
        BOOK_TYPE_CODE = l_def_amh_rec.book_type_code,
        METHOD_ID = l_def_amh_rec.method_id,
        -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
        deprn_rate = l_def_amh_rec.deprn_rate/100,

        ORG_ID = l_def_amh_rec.org_id,
        CREATED_BY = l_def_amh_rec.created_by,
        CREATION_DATE = l_def_amh_rec.creation_date,
        LAST_UPDATED_BY = l_def_amh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_amh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_amh_rec.last_update_login
    WHERE ID = l_def_amh_rec.id;

    x_amh_rec := l_amh_rec;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------------
  -- update_row for:OKL_AMORT_HOLD_SETUPS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type,
    x_amhv_rec                     OUT NOCOPY amhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amhv_rec                     amhv_rec_type := p_amhv_rec;
    l_def_amhv_rec                 amhv_rec_type;
    l_db_amhv_rec                  amhv_rec_type;
    l_amh_rec                      amh_rec_type;
    lx_amh_rec                     amh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_amhv_rec IN amhv_rec_type
    ) RETURN amhv_rec_type IS
      l_amhv_rec amhv_rec_type := p_amhv_rec;
    BEGIN
      l_amhv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_amhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_amhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_amhv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_amhv_rec IN amhv_rec_type,
      x_amhv_rec OUT NOCOPY amhv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okc_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amhv_rec := p_amhv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_amhv_rec := get_rec(p_amhv_rec, l_return_status);
      IF (l_return_status = okl_api.G_RET_STS_SUCCESS) THEN
        IF (x_amhv_rec.id = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.id := l_db_amhv_rec.id;
        END IF;

-- Added by Ravi --
        IF (x_amhv_rec.object_version_number = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.object_version_number := l_db_amhv_rec.object_version_number;
        END IF;
-- End of changes by Ravi --


        IF (x_amhv_rec.hold_period_days = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.hold_period_days := l_db_amhv_rec.hold_period_days;
        END IF;
        IF (x_amhv_rec.category_id = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.category_id := l_db_amhv_rec.category_id;
        END IF;
        IF (x_amhv_rec.book_type_code = okl_api.G_MISS_CHAR)
        THEN
          x_amhv_rec.book_type_code := l_db_amhv_rec.book_type_code;
        END IF;
        IF (x_amhv_rec.method_id = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.method_id := l_db_amhv_rec.method_id;
        END IF;

        -- SECHAWLA 26-MAY-04 3645574 : addded deprn_rate
        IF (x_amhv_rec.deprn_rate = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.deprn_rate := l_db_amhv_rec.deprn_rate;
        END IF;

        IF (x_amhv_rec.org_id = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.org_id := l_db_amhv_rec.org_id;
        END IF;
        IF (x_amhv_rec.created_by = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.created_by := l_db_amhv_rec.created_by;
        END IF;
        IF (x_amhv_rec.creation_date = okl_api.G_MISS_DATE)
        THEN
          x_amhv_rec.creation_date := l_db_amhv_rec.creation_date;
        END IF;
        IF (x_amhv_rec.last_updated_by = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.last_updated_by := l_db_amhv_rec.last_updated_by;
        END IF;
        IF (x_amhv_rec.last_update_date = okl_api.G_MISS_DATE)
        THEN
          x_amhv_rec.last_update_date := l_db_amhv_rec.last_update_date;
        END IF;
        IF (x_amhv_rec.last_update_login = okl_api.G_MISS_NUM)
        THEN
          x_amhv_rec.last_update_login := l_db_amhv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_AMORT_HOLD_SETUPS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_amhv_rec IN amhv_rec_type,
      x_amhv_rec OUT NOCOPY amhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_amhv_rec := p_amhv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_amhv_rec,                        -- IN
      x_amhv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_amhv_rec, l_def_amhv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_amhv_rec := fill_who_columns(l_def_amhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_amhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_amhv_rec, l_db_amhv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

/* dapatel: commented until full object_version_number functionality implemented
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_amhv_rec                     => p_amhv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
*/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_amhv_rec, l_amh_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_amh_rec,
      lx_amh_rec
    );
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_amh_rec, l_def_amhv_rec);
    x_amhv_rec := l_def_amhv_rec;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:amhv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      i := p_amhv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         okl_api.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => okl_api.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_amhv_rec                     => p_amhv_tbl(i),
            x_amhv_rec                     => x_amhv_tbl(i));
          IF (l_error_rec.error_type <> okl_api.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN okl_api.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_amhv_tbl.LAST);
        i := p_amhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:AMHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    x_amhv_tbl                     OUT NOCOPY amhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_error_tbl                    okl_api.ERROR_TBL_TYPE;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => okl_api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_amhv_tbl                     => p_amhv_tbl,
        x_amhv_tbl                     => x_amhv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- delete_row for:OKL_AMORT_HOLD_SETUPS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amh_rec                      IN amh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amh_rec                      amh_rec_type := p_amh_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_AMORT_HOLD_SETUPS
     WHERE ID = p_amh_rec.id;

    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------------
  -- delete_row for:OKL_AMORT_HOLD_SETUPS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_rec                     IN amhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_amhv_rec                     amhv_rec_type := p_amhv_rec;
    l_amh_rec                      amh_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_amhv_rec, l_amh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_amh_rec
    );
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_AMORT_HOLD_SETUPS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      i := p_amhv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         okl_api.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => okl_api.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_amhv_rec                     => p_amhv_tbl(i));
          IF (l_error_rec.error_type <> okl_api.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN okl_api.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := okl_api.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_amhv_tbl.LAST);
        i := p_amhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_AMORT_HOLD_SETUPS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_amhv_tbl                     IN amhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_error_tbl                    okl_api.ERROR_TBL_TYPE;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_amhv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => okl_api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_amhv_tbl                     => p_amhv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
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
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_AMH_PVT;

/

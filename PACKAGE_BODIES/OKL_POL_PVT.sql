--------------------------------------------------------
--  DDL for Package Body OKL_POL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POL_PVT" AS
/* $Header: OKLSPOLB.pls 120.5 2008/04/23 21:00:19 racheruv noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

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
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
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
  -- FUNCTION get_rec for: OKL_POOLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_polv_rec                     IN polv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN polv_rec_type IS
    CURSOR okl_polv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            POT_ID,
            KHR_ID,
            POOL_NUMBER,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            CURRENCY_CODE,
            TOTAL_PRINCIPAL_AMOUNT,
            TOTAL_RECEIVABLE_AMOUNT,
            SECURITIES_CREDIT_RATING,
            DATE_CREATED,
            DATE_LAST_UPDATED,
            DATE_LAST_RECONCILED,
            DATE_TOTAL_PRINCIPAL_CALC,
            STATUS_CODE,
			DISPLAY_IN_LEASE_CENTER,
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
	    LEGAL_ENTITY_ID
      FROM OKL_POOLS
     WHERE OKL_POOLS.id = p_id;
    l_okl_polv_pk                  okl_polv_pk_csr%ROWTYPE;
    l_polv_rec                     polv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_polv_pk_csr (p_polv_rec.id);
    FETCH okl_polv_pk_csr INTO
	l_polv_rec.id,
	l_polv_rec.object_version_number,
	l_polv_rec.pot_id,
	l_polv_rec.khr_id,
	l_polv_rec.pool_number,
	l_polv_rec.description,
	l_polv_rec.short_description,
	l_polv_rec.currency_code,
	l_polv_rec.total_principal_amount,
	l_polv_rec.total_receivable_amount,
	l_polv_rec.securities_credit_rating,
	l_polv_rec.date_created,
	l_polv_rec.date_last_updated,
	l_polv_rec.date_last_reconciled,
	l_polv_rec.date_total_principal_calc,
	l_polv_rec.status_code,
	l_polv_rec.display_in_lease_center,
	l_polv_rec.attribute_category,
	l_polv_rec.attribute1,
	l_polv_rec.attribute2,
	l_polv_rec.attribute3,
	l_polv_rec.attribute4,
	l_polv_rec.attribute5,
	l_polv_rec.attribute6,
	l_polv_rec.attribute7,
	l_polv_rec.attribute8,
	l_polv_rec.attribute9,
	l_polv_rec.attribute10,
	l_polv_rec.attribute11,
	l_polv_rec.attribute12,
	l_polv_rec.attribute13,
	l_polv_rec.attribute14,
	l_polv_rec.attribute15,
	l_polv_rec.org_id,
	l_polv_rec.request_id,
	l_polv_rec.program_application_id,
	l_polv_rec.program_id,
	l_polv_rec.program_update_date,
	l_polv_rec.created_by,
	l_polv_rec.creation_date,
	l_polv_rec.last_updated_by,
	l_polv_rec.last_update_date,
	l_polv_rec.last_update_login,
	l_polv_rec.legal_entity_id;
    x_no_data_found := okl_polv_pk_csr%NOTFOUND;
    CLOSE okl_polv_pk_csr;
    RETURN(l_polv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_polv_rec                     IN polv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN polv_rec_type IS
    l_polv_rec                     polv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_polv_rec := get_rec(p_polv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_polv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_polv_rec                     IN polv_rec_type
  ) RETURN polv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_polv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_pools
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pol_rec                      IN pol_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pol_rec_type IS
    CURSOR okl_pools_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            POT_ID,
            KHR_ID,
            POOL_NUMBER,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            CURRENCY_CODE,
            TOTAL_PRINCIPAL_AMOUNT,
            TOTAL_RECEIVABLE_AMOUNT,
            SECURITIES_CREDIT_RATING,
            DATE_CREATED,
            DATE_LAST_UPDATED,
            DATE_LAST_RECONCILED,
            DATE_TOTAL_PRINCIPAL_CALC,
            STATUS_CODE,
			DISPLAY_IN_LEASE_CENTER,
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
	    LEGAL_ENTITY_ID
     FROM okl_pools
     WHERE okl_pools.id = p_id;
    l_okl_pools_pk       okl_pools_pk_csr%ROWTYPE;
    l_pol_rec                      pol_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pools_pk_csr (p_pol_rec.id);
    FETCH okl_pools_pk_csr INTO
	l_pol_rec.id,
	l_pol_rec.object_version_number,
	l_pol_rec.pot_id,
	l_pol_rec.khr_id,
	l_pol_rec.pool_number,
	l_pol_rec.description,
	l_pol_rec.short_description,
	l_pol_rec.currency_code,
	l_pol_rec.total_principal_amount,
	l_pol_rec.total_receivable_amount,
	l_pol_rec.securities_credit_rating,
	l_pol_rec.date_created,
	l_pol_rec.date_last_updated,
	l_pol_rec.date_last_reconciled,
	l_pol_rec.date_total_principal_calc,
	l_pol_rec.status_code,
	l_pol_rec.display_in_lease_center,
	l_pol_rec.attribute_category,
	l_pol_rec.attribute1,
	l_pol_rec.attribute2,
	l_pol_rec.attribute3,
	l_pol_rec.attribute4,
	l_pol_rec.attribute5,
	l_pol_rec.attribute6,
	l_pol_rec.attribute7,
	l_pol_rec.attribute8,
	l_pol_rec.attribute9,
	l_pol_rec.attribute10,
	l_pol_rec.attribute11,
	l_pol_rec.attribute12,
	l_pol_rec.attribute13,
	l_pol_rec.attribute14,
	l_pol_rec.attribute15,
	l_pol_rec.org_id,
	l_pol_rec.request_id,
	l_pol_rec.program_application_id,
	l_pol_rec.program_id,
	l_pol_rec.program_update_date,
	l_pol_rec.created_by,
	l_pol_rec.creation_date,
	l_pol_rec.last_updated_by,
	l_pol_rec.last_update_date,
	l_pol_rec.last_update_login,
	l_pol_rec.legal_entity_id;
    x_no_data_found := okl_pools_pk_csr%NOTFOUND;
    CLOSE okl_pools_pk_csr;
    RETURN(l_pol_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pol_rec                      IN pol_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pol_rec_type IS
    l_pol_rec                      pol_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_pol_rec := get_rec(p_pol_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pol_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pol_rec                      IN pol_rec_type
  ) RETURN pol_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pol_rec, l_row_not_found));
  END get_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_POOLS_V
  -- mvasudev, hold this off for now
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_polv_rec   IN polv_rec_type
  ) RETURN polv_rec_type IS
    l_polv_rec                     polv_rec_type := p_polv_rec;
  BEGIN
    IF (l_polv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.id := NULL;
    END IF;
    IF (l_polv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.object_version_number := NULL;
    END IF;
    IF (l_polv_rec.pot_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.pot_id := NULL;
    END IF;
    IF (l_polv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.khr_id := NULL;
    END IF;
    IF (l_polv_rec.pool_number = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.pool_number := NULL;
    END IF;
    IF (l_polv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.description := NULL;
    END IF;
    IF (l_polv_rec.short_description = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.short_description := NULL;
    END IF;
    IF (l_polv_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.currency_code := NULL;
    END IF;
    IF (l_polv_rec.total_principal_amount = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.total_principal_amount := NULL;
    END IF;
    IF (l_polv_rec.total_receivable_amount = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.total_receivable_amount := NULL;
    END IF;
    IF (l_polv_rec.securities_credit_rating = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.securities_credit_rating := NULL;
    END IF;
    IF (l_polv_rec.date_created = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.date_created := NULL;
    END IF;
    IF (l_polv_rec.date_last_updated = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.date_last_updated := NULL;
    END IF;
    IF (l_polv_rec.date_last_reconciled = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.date_last_reconciled := NULL;
    END IF;
    IF (l_polv_rec.date_total_principal_calc = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.date_total_principal_calc := NULL;
    END IF;
    IF (l_polv_rec.status_code = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.status_code := NULL;
    END IF;
    IF (l_polv_rec.display_in_lease_center = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.display_in_lease_center := NULL;
    END IF;
    IF (l_polv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute_category := NULL;
    END IF;
    IF (l_polv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute1 := NULL;
    END IF;
    IF (l_polv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute2 := NULL;
    END IF;
    IF (l_polv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute3 := NULL;
    END IF;
    IF (l_polv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute4 := NULL;
    END IF;
    IF (l_polv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute5 := NULL;
    END IF;
    IF (l_polv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute6 := NULL;
    END IF;
    IF (l_polv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute7 := NULL;
    END IF;
    IF (l_polv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute8 := NULL;
    END IF;
    IF (l_polv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute9 := NULL;
    END IF;
    IF (l_polv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute10 := NULL;
    END IF;
    IF (l_polv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute11 := NULL;
    END IF;
    IF (l_polv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute12 := NULL;
    END IF;
    IF (l_polv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute13 := NULL;
    END IF;
    IF (l_polv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute14 := NULL;
    END IF;
    IF (l_polv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute15 := NULL;
    END IF;
    IF (l_polv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_polv_rec.attribute1 := NULL;
    END IF;
    IF (l_polv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.org_id := NULL;
    END IF;
    IF (l_polv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.request_id := NULL;
    END IF;
    IF (l_polv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.program_application_id := NULL;
    END IF;
    IF (l_polv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.program_id := NULL;
    END IF;
    IF (l_polv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.program_update_date := NULL;
    END IF;
    IF (l_polv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.created_by := NULL;
    END IF;
    IF (l_polv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.creation_date := NULL;
    END IF;
    IF (l_polv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.last_updated_by := NULL;
    END IF;
    IF (l_polv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_polv_rec.last_update_date := NULL;
    END IF;
    IF (l_polv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.last_update_login := NULL;
    END IF;
    IF (l_polv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_polv_rec.legal_entity_id := NULL;
    END IF;
    RETURN(l_polv_rec);
  END null_out_defaults;

  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_id = OKL_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;

  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'OBJECT_VERSION_NUMBER');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  -------------------------------------
  -- Validate_Attributes for: pot_id --
  -------------------------------------
  PROCEDURE validate_pot_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pot_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_POT_FK;
  CURSOR okl_potv_pk_csr (p_id IN OKL_POOLS.pot_id%TYPE) IS
  SELECT '1'
    FROM OKL_POOL_TYPES_V
   WHERE OKL_POOL_TYPES_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pot_id <> OKL_API.G_MISS_NUM  AND  p_pot_id IS NOT NULL)
    THEN
	    OPEN okl_potv_pk_csr(p_pot_id);
	    FETCH okl_potv_pk_csr INTO l_dummy;
	    l_row_not_found := okl_potv_pk_csr%NOTFOUND;
	    CLOSE okl_potv_pk_csr;

	    IF l_row_not_found THEN
	      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'pot_id');
	      x_return_status := OKL_API.G_RET_STS_ERROR;
	    END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF okl_potv_pk_csr%ISOPEN THEN
        CLOSE okl_potv_pk_csr;
      END IF;
  END validate_pot_id;

  -------------------------------------
  -- Validate_Attributes for: khr_id --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_POL_KHR_FK;
  CURSOR okl_khrv_pk_csr (p_id IN OKL_POOLS.khr_id%TYPE) IS
  SELECT '1'
    FROM OKL_K_HEADERS_V
   WHERE OKL_K_HEADERS_V.id = p_id;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_khr_id <> OKL_API.G_MISS_NUM  AND  p_khr_id IS NOT NULL)
    THEN
	    OPEN okl_khrv_pk_csr(p_khr_id);
	    FETCH okl_khrv_pk_csr INTO l_dummy;
	    l_row_not_found := okl_khrv_pk_csr%NOTFOUND;
	    CLOSE okl_khrv_pk_csr;

	    IF l_row_not_found THEN
	      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'khr_id');
	      x_return_status := OKL_API.G_RET_STS_ERROR;
	    END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF okl_khrv_pk_csr%ISOPEN THEN
        CLOSE okl_khrv_pk_csr;
      END IF;
  END validate_khr_id;

  --------------------------------------
  -- Validate_Attributes for: pool_number --
  --------------------------------------
  PROCEDURE validate_pool_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pool_number                      IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_pool_number = OKL_API.G_MISS_CHAR OR
        p_pool_number IS NULL)
    THEN
            g_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_POOL_NUMBER');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => g_ak_prompt);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_pool_number;

  --------------------------------------------
  -- Validate_Attributes for: currency_code --
  --------------------------------------------
  PROCEDURE validate_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_currency_code                IN VARCHAR2) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_CURRENCIES;
  CURSOR okl_fnd_curr_csr (p_code IN OKL_POOLS.currency_code%TYPE) IS
  SELECT '1'
    FROM FND_CURRENCIES_VL
   WHERE FND_CURRENCIES_VL.currency_code = p_code; -- Bug 6982517. Changed to use the parameter.


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_currency_code = OKL_API.G_MISS_CHAR OR
        p_currency_code IS NULL)
    THEN
            g_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_CURRENCY');
            OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => g_ak_prompt);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_fnd_curr_csr(p_currency_code);
    FETCH okl_fnd_curr_csr INTO l_dummy;
    l_row_not_found := okl_fnd_curr_csr%NOTFOUND;
    CLOSE okl_fnd_curr_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'currency_code');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF okl_fnd_curr_csr%ISOPEN THEN
        CLOSE okl_fnd_curr_csr;
      END IF;
  END validate_currency_code;
  -----------------------------------------
  -- Validate_Attributes for: date_created --
  -----------------------------------------
  PROCEDURE validate_date_created(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_date_created                   IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_date_created = OKL_API.G_MISS_DATE OR
        p_date_created IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'date_created');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_date_created;


    -----------------------------------------
  -- Validate_Attributes for: legal_entity_id --
  -----------------------------------------
  PROCEDURE validate_legal_entity_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_legal_entity_id                   IN NUMBER) IS
    l_dummy                       VARCHAR2(1);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_legal_entity_id = OKL_API.G_MISS_NUM OR
        p_legal_entity_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'legal_entity_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      l_dummy := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_legal_entity_id);
      IF  l_dummy <>1 THEN
          Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'legal_entity_id');
	  x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_legal_entity_id;



  -----------------------------------------
  -- Validate_Attributes for: date_last_updated --
  -----------------------------------------
  PROCEDURE validate_date_last_updated(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_date_last_updated                   IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_date_last_updated = OKL_API.G_MISS_DATE OR
        p_date_last_updated IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'date_last_updated');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_date_last_updated;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_POOLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_polv_rec                     IN polv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_polv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_polv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pot_id
    -- ***
    validate_pot_id(x_return_status, p_polv_rec.pot_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_polv_rec.khr_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pool_number
    -- ***
    validate_pool_number(x_return_status, p_polv_rec.pool_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- currency_code
    -- ***
    validate_currency_code(x_return_status, p_polv_rec.currency_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- date_created
    -- ***
    validate_date_created(x_return_status, p_polv_rec.date_created);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- date_last_updated
    -- ***
    validate_date_last_updated(x_return_status, p_polv_rec.date_last_updated);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- legal_entity_id
    -- ***
    validate_legal_entity_id(x_return_status, p_polv_rec.legal_entity_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Pol_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pol_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Pol_Record(
    p_polv_rec      IN   polv_rec_type,
    x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for PIT Unique Key
  CURSOR okl_pol_uk_csr(p_rec polv_rec_type) IS
  SELECT '1'
  FROM OKL_POOLS
  WHERE  pool_number = p_rec.pool_number
    AND  id     <> NVL(p_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN okl_pol_uk_csr(p_polv_rec);
    FETCH okl_pol_uk_csr INTO l_dummy;
    l_row_found := okl_pol_uk_csr%FOUND;
    CLOSE okl_pol_uk_csr;
    IF l_row_found THEN
	OKL_API.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- verify that the cursor was closed
	  IF okl_pol_uk_csr%ISOPEN THEN
        CLOSE okl_pol_uk_csr;
      END IF;
  END Validate_Unique_Pol_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:OKL_POOLS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_polv_rec IN polv_rec_type,
    p_db_polv_rec IN polv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_polv_rec IN polv_rec_type,
      p_db_polv_rec IN polv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_polv_rec, p_db_polv_rec);
    -- mvasudev added, 12/30/2002
    validate_unique_pol_record(p_polv_rec, l_return_status);
    RETURN (l_return_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_polv_rec IN polv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_polv_rec                  polv_rec_type := get_rec(p_polv_rec);
  BEGIN
    l_return_status := Validate_Record(p_polv_rec => p_polv_rec,
                                       p_db_polv_rec => l_db_polv_rec);
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN polv_rec_type,
    p_to   IN OUT NOCOPY pol_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pot_id := p_from.pot_id;
    p_to.khr_id := p_from.khr_id;
    p_to.pool_number := p_from.pool_number;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.currency_code := p_from.currency_code;
    p_to.total_principal_amount := p_from.total_principal_amount;
    p_to.total_receivable_amount := p_from.total_receivable_amount;
    p_to.securities_credit_rating := p_from.securities_credit_rating;
    p_to.date_created := p_from.date_created;
    p_to.date_last_updated := p_from.date_last_updated;
    p_to.date_last_reconciled := p_from.date_last_reconciled;
    p_to.date_total_principal_calc := p_from.date_total_principal_calc;
    p_to.status_code := p_from.status_code;
    p_to.display_in_lease_center := p_from.display_in_lease_center;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN pol_rec_type,
    p_to   IN OUT NOCOPY polv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.pot_id := p_from.pot_id;
    p_to.khr_id := p_from.khr_id;
    p_to.pool_number := p_from.pool_number;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.currency_code := p_from.currency_code;
    p_to.total_principal_amount := p_from.total_principal_amount;
    p_to.total_receivable_amount := p_from.total_receivable_amount;
    p_to.securities_credit_rating := p_from.securities_credit_rating;
    p_to.date_created := p_from.date_created;
    p_to.date_last_updated := p_from.date_last_updated;
    p_to.date_last_reconciled := p_from.date_last_reconciled;
    p_to.date_total_principal_calc := p_from.date_total_principal_calc;
    p_to.status_code := p_from.status_code;
    p_to.display_in_lease_center := p_from.display_in_lease_center;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_POOLS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_polv_rec                     polv_rec_type := p_polv_rec;
    l_pol_rec                      pol_rec_type;
    l_pol_rec                      pol_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_polv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_polv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_POOLS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      i := p_polv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_polv_rec                     => p_polv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_polv_tbl.LAST);
        i := p_polv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_POOLS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_polv_tbl                     => p_polv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- insert_row for:okl_pools --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pol_rec                      IN pol_rec_type,
    x_pol_rec                      OUT NOCOPY pol_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pol_rec                      pol_rec_type := p_pol_rec;
    l_def_pol_rec                  pol_rec_type;
    --------------------------------------------
    -- Set_Attributes for:okl_pools --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pol_rec IN pol_rec_type,
      x_pol_rec OUT NOCOPY pol_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pol_rec := p_pol_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_pol_rec,                         -- IN
      l_pol_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO okl_pools(
	ID,
	OBJECT_VERSION_NUMBER,
	POT_ID,
	KHR_ID,
	POOL_NUMBER,
	DESCRIPTION,
	SHORT_DESCRIPTION,
	CURRENCY_CODE,
	TOTAL_PRINCIPAL_AMOUNT,
	TOTAL_RECEIVABLE_AMOUNT,
	SECURITIES_CREDIT_RATING,
	DATE_CREATED,
	DATE_LAST_UPDATED,
	DATE_LAST_RECONCILED,
	DATE_TOTAL_PRINCIPAL_CALC,
	STATUS_CODE,
	DISPLAY_IN_LEASE_CENTER,
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
	LEGAL_ENTITY_ID)
    VALUES (
	l_pol_rec.id,
	l_pol_rec.object_version_number,
	l_pol_rec.pot_id,
	l_pol_rec.khr_id,
	l_pol_rec.pool_number,
	l_pol_rec.description,
	l_pol_rec.short_description,
	l_pol_rec.currency_code,
	l_pol_rec.total_principal_amount,
	l_pol_rec.total_receivable_amount,
	l_pol_rec.securities_credit_rating,
	l_pol_rec.date_created,
	l_pol_rec.date_last_updated,
	l_pol_rec.date_last_reconciled,
	l_pol_rec.date_total_principal_calc,
	l_pol_rec.status_code,
	l_pol_rec.display_in_lease_center,
	l_pol_rec.attribute_category,
	l_pol_rec.attribute1,
	l_pol_rec.attribute2,
	l_pol_rec.attribute3,
	l_pol_rec.attribute4,
	l_pol_rec.attribute5,
	l_pol_rec.attribute6,
	l_pol_rec.attribute7,
	l_pol_rec.attribute8,
	l_pol_rec.attribute9,
	l_pol_rec.attribute10,
	l_pol_rec.attribute11,
	l_pol_rec.attribute12,
	l_pol_rec.attribute13,
	l_pol_rec.attribute14,
	l_pol_rec.attribute15,
	l_pol_rec.org_id,
	l_pol_rec.request_id,
	l_pol_rec.program_application_id,
	l_pol_rec.program_id,
	l_pol_rec.program_update_date,
	l_pol_rec.created_by,
	l_pol_rec.creation_date,
	l_pol_rec.last_updated_by,
	l_pol_rec.last_update_date,
	l_pol_rec.last_update_login,
	l_pol_rec.legal_entity_id);
    -- Set OUT values
    x_pol_rec := l_pol_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------------
  -- insert_row for :OKL_POOLS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type,
    x_polv_rec                     OUT NOCOPY polv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_polv_rec                     polv_rec_type := p_polv_rec;
    l_def_polv_rec                 polv_rec_type;
    l_pol_rec                      pol_rec_type;
    lx_pol_rec                     pol_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_polv_rec IN polv_rec_type
    ) RETURN polv_rec_type IS
      l_polv_rec polv_rec_type := p_polv_rec;
    BEGIN
      l_polv_rec.CREATION_DATE := SYSDATE;
      l_polv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_polv_rec.LAST_UPDATE_DATE := l_polv_rec.CREATION_DATE;
      l_polv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_polv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_polv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_polv_rec IN polv_rec_type,
      x_polv_rec OUT NOCOPY polv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_polv_rec := p_polv_rec;
      x_polv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_polv_rec.REQUEST_ID
            ,x_polv_rec.PROGRAM_APPLICATION_ID
            ,x_polv_rec.PROGRAM_ID
            ,x_polv_rec.PROGRAM_UPDATE_DATE
      FROM DUAL;
      x_polv_rec.org_id := mo_global.get_current_org_id();
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_polv_rec := null_out_defaults(p_polv_rec);
    -- Set primary key value
    l_polv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_polv_rec,                        -- IN
      l_def_polv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_polv_rec := fill_who_columns(l_def_polv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_polv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_polv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_polv_rec, l_pol_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pol_rec,
      lx_pol_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pol_rec, l_def_polv_rec);
    -- Set OUT values
    x_polv_rec := l_def_polv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:polV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      i := p_polv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_polv_rec                     => p_polv_tbl(i),
            x_polv_rec                     => x_polv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_polv_tbl.LAST);
        i := p_polv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:polV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_polv_tbl                     => p_polv_tbl,
        x_polv_tbl                     => x_polv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:okl_pools --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pol_rec                      IN pol_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pol_rec IN pol_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pools
     WHERE ID = p_pol_rec.id
       AND OBJECT_VERSION_NUMBER = p_pol_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pol_rec IN pol_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_pools
     WHERE ID = p_pol_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        okl_pools.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       okl_pools.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_pol_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_pol_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pol_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pol_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------
  -- lock_row for: OKL_POOLS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pol_rec                      pol_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_polv_rec, l_pol_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pol_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:polV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      i := p_polv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_polv_rec                     => p_polv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_polv_tbl.LAST);
        i := p_polv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:polV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_polv_tbl                     => p_polv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:okl_pools --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pol_rec                      IN pol_rec_type,
    x_pol_rec                      OUT NOCOPY pol_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pol_rec                      pol_rec_type := p_pol_rec;
    l_def_pol_rec                  pol_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pol_rec IN pol_rec_type,
      x_pol_rec OUT NOCOPY pol_rec_type
    ) RETURN VARCHAR2 IS
      l_pol_rec                      pol_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pol_rec := p_pol_rec;
      -- Get current database values
      l_pol_rec := get_rec(p_pol_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_pol_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.id := l_pol_rec.id;
        END IF;
        IF (x_pol_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.object_version_number := l_pol_rec.object_version_number;
        END IF;
        IF (x_pol_rec.pot_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.pot_id := l_pol_rec.pot_id;
        END IF;
        IF (x_pol_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.khr_id := l_pol_rec.khr_id;
        END IF;
        IF (x_pol_rec.pool_number = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.pool_number := l_pol_rec.pool_number;
        END IF;
        IF (x_pol_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.description := l_pol_rec.description;
        END IF;
        IF (x_pol_rec.short_description = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.short_description := l_pol_rec.short_description;
        END IF;
        IF (x_pol_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.currency_code := l_pol_rec.currency_code;
        END IF;
        IF (x_pol_rec.total_principal_amount = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.total_principal_amount := l_pol_rec.total_principal_amount;
        END IF;
        IF (x_pol_rec.total_receivable_amount = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.total_receivable_amount := l_pol_rec.total_receivable_amount;
        END IF;
        IF (x_pol_rec.securities_credit_rating = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.securities_credit_rating := l_pol_rec.securities_credit_rating;
        END IF;
        IF (x_pol_rec.date_created = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.date_created := l_pol_rec.date_created;
        END IF;
        IF (x_pol_rec.date_last_updated = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.date_last_updated := l_pol_rec.date_last_updated;
        END IF;
        IF (x_pol_rec.date_last_reconciled = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.date_last_reconciled := l_pol_rec.date_last_reconciled;
        END IF;
        IF (x_pol_rec.date_total_principal_calc = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.date_total_principal_calc := l_pol_rec.date_total_principal_calc;
        END IF;
        IF (x_pol_rec.status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.status_code := l_pol_rec.status_code;
        END IF;
        IF (x_pol_rec.display_in_lease_center = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.display_in_lease_center := l_pol_rec.display_in_lease_center;
        END IF;
        IF (x_pol_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute_category := l_pol_rec.attribute_category;
        END IF;
        IF (x_pol_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute1 := l_pol_rec.attribute1;
        END IF;
        IF (x_pol_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute2 := l_pol_rec.attribute2;
        END IF;
        IF (x_pol_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute3 := l_pol_rec.attribute3;
        END IF;
        IF (x_pol_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute4 := l_pol_rec.attribute4;
        END IF;
        IF (x_pol_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute5 := l_pol_rec.attribute5;
        END IF;
        IF (x_pol_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute6 := l_pol_rec.attribute6;
        END IF;
        IF (x_pol_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute7 := l_pol_rec.attribute7;
        END IF;
        IF (x_pol_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute8 := l_pol_rec.attribute8;
        END IF;
        IF (x_pol_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute9 := l_pol_rec.attribute9;
        END IF;
        IF (x_pol_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute10 := l_pol_rec.attribute10;
        END IF;
        IF (x_pol_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute11 := l_pol_rec.attribute11;
        END IF;
        IF (x_pol_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute12 := l_pol_rec.attribute12;
        END IF;
        IF (x_pol_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute13 := l_pol_rec.attribute13;
        END IF;
        IF (x_pol_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute14 := l_pol_rec.attribute14;
        END IF;
        IF (x_pol_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_pol_rec.attribute15 := l_pol_rec.attribute15;
        END IF;


        IF (x_pol_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.org_id := l_pol_rec.org_id;
        END IF;
        IF (x_pol_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.request_id := l_pol_rec.request_id;
        END IF;
        IF (x_pol_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.program_application_id := l_pol_rec.program_application_id;
        END IF;
        IF (x_pol_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.program_id := l_pol_rec.program_id;
        END IF;
        IF (x_pol_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.program_update_date := l_pol_rec.program_update_date;
        END IF;
        IF (x_pol_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.created_by := l_pol_rec.created_by;
        END IF;
        IF (x_pol_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.creation_date := l_pol_rec.creation_date;
        END IF;
        IF (x_pol_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.last_updated_by := l_pol_rec.last_updated_by;
        END IF;
        IF (x_pol_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_pol_rec.last_update_date := l_pol_rec.last_update_date;
        END IF;
        IF (x_pol_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.last_update_login := l_pol_rec.last_update_login;
        END IF;
        IF (x_pol_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_pol_rec.legal_entity_id := l_pol_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:okl_pools --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_pol_rec IN pol_rec_type,
      x_pol_rec OUT NOCOPY pol_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pol_rec := p_pol_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_pol_rec,                         -- IN
      l_pol_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pol_rec, l_def_pol_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE okl_pools
    SET OBJECT_VERSION_NUMBER = l_def_pol_rec.object_version_number,
        POT_ID = l_def_pol_rec.pot_id,
        KHR_ID = l_def_pol_rec.khr_id,
        POOL_NUMBER = l_def_pol_rec.pool_number,
        DESCRIPTION = l_def_pol_rec.description,
        SHORT_DESCRIPTION = l_def_pol_rec.short_description,
        CURRENCY_CODE = l_def_pol_rec.currency_code,
        TOTAL_PRINCIPAL_AMOUNT = l_def_pol_rec.total_principal_amount,
        TOTAL_RECEIVABLE_AMOUNT = l_def_pol_rec.total_receivable_amount,
        SECURITIES_CREDIT_RATING = l_def_pol_rec.securities_credit_rating,
        DATE_CREATED = l_def_pol_rec.date_created,
        DATE_LAST_UPDATED = l_def_pol_rec.date_last_updated,
        DATE_LAST_RECONCILED = l_def_pol_rec.date_last_reconciled,
        DATE_TOTAL_PRINCIPAL_CALC = l_def_pol_rec.date_total_principal_calc,
        STATUS_CODE = l_def_pol_rec.status_code,
        DISPLAY_IN_LEASE_CENTER = l_def_pol_rec.display_in_lease_center,
        ATTRIBUTE_CATEGORY = l_def_pol_rec.attribute_category,
        ATTRIBUTE1 = l_def_pol_rec.attribute1,
        ATTRIBUTE2 = l_def_pol_rec.attribute2,
        ATTRIBUTE3 = l_def_pol_rec.attribute3,
        ATTRIBUTE4 = l_def_pol_rec.attribute4,
        ATTRIBUTE5 = l_def_pol_rec.attribute5,
        ATTRIBUTE6 = l_def_pol_rec.attribute6,
        ATTRIBUTE7 = l_def_pol_rec.attribute7,
        ATTRIBUTE8 = l_def_pol_rec.attribute8,
        ATTRIBUTE9 = l_def_pol_rec.attribute9,
        ATTRIBUTE10 = l_def_pol_rec.attribute10,
        ATTRIBUTE11 = l_def_pol_rec.attribute11,
        ATTRIBUTE12 = l_def_pol_rec.attribute12,
        ATTRIBUTE13 = l_def_pol_rec.attribute13,
        ATTRIBUTE14 = l_def_pol_rec.attribute14,
        ATTRIBUTE15 = l_def_pol_rec.attribute15,
        ORG_ID = l_def_pol_rec.org_id,
        REQUEST_ID = l_def_pol_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_pol_rec.program_application_id,
        PROGRAM_ID = l_def_pol_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_pol_rec.program_update_date,
        CREATED_BY = l_def_pol_rec.created_by,
        CREATION_DATE = l_def_pol_rec.creation_date,
        LAST_UPDATED_BY = l_def_pol_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pol_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pol_rec.last_update_login,
        LEGAL_ENTITY_ID = l_def_pol_rec.legal_entity_id
    WHERE ID = l_def_pol_rec.id;

    x_pol_rec := l_pol_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------
  -- update_row for:OKL_POOLS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type,
    x_polv_rec                     OUT NOCOPY polv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_polv_rec                     polv_rec_type := p_polv_rec;
    l_def_polv_rec                 polv_rec_type;
    l_db_polv_rec                  polv_rec_type;
    l_pol_rec                      pol_rec_type;
    lx_pol_rec                     pol_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_polv_rec IN polv_rec_type
    ) RETURN polv_rec_type IS
      l_polv_rec polv_rec_type := p_polv_rec;
    BEGIN
      l_polv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_polv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_polv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_polv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_polv_rec IN polv_rec_type,
      x_polv_rec OUT NOCOPY polv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_polv_rec := p_polv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_polv_rec := get_rec(p_polv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_polv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.id := l_db_polv_rec.id;
        END IF;
        IF (x_polv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.object_version_number := l_db_polv_rec.object_version_number;
        END IF;
        IF (x_polv_rec.pot_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.pot_id := l_db_polv_rec.pot_id;
        END IF;
        IF (x_polv_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.khr_id := l_db_polv_rec.khr_id;
        END IF;
        IF (x_polv_rec.pool_number = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.pool_number := l_db_polv_rec.pool_number;
        END IF;
        IF (x_polv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.description := l_db_polv_rec.description;
        END IF;
        IF (x_polv_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.currency_code := l_db_polv_rec.currency_code;
        END IF;
        IF (x_polv_rec.total_principal_amount = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.total_principal_amount := l_db_polv_rec.total_principal_amount;
        END IF;
        IF (x_polv_rec.total_receivable_amount = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.total_receivable_amount := l_db_polv_rec.total_receivable_amount;
        END IF;
        IF (x_polv_rec.securities_credit_rating = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.securities_credit_rating := l_db_polv_rec.securities_credit_rating;
        END IF;
        IF (x_polv_rec.date_created = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.date_created := l_db_polv_rec.date_created;
        END IF;
        IF (x_polv_rec.date_last_updated = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.date_last_updated := l_db_polv_rec.date_last_updated;
        END IF;
        IF (x_polv_rec.date_last_reconciled = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.date_last_reconciled := l_db_polv_rec.date_last_reconciled;
        END IF;
        IF (x_polv_rec.date_total_principal_calc = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.date_total_principal_calc := l_db_polv_rec.date_total_principal_calc;
        END IF;
        IF (x_polv_rec.status_code = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.status_code := l_db_polv_rec.status_code;
        END IF;
        IF (x_polv_rec.display_in_lease_center = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.display_in_lease_center := l_db_polv_rec.display_in_lease_center;
        END IF;
        IF (x_polv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute_category := l_db_polv_rec.attribute_category;
        END IF;
        IF (x_polv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute1 := l_db_polv_rec.attribute1;
        END IF;
        IF (x_polv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute2 := l_db_polv_rec.attribute2;
        END IF;
        IF (x_polv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute3 := l_db_polv_rec.attribute3;
        END IF;
        IF (x_polv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute4 := l_db_polv_rec.attribute4;
        END IF;
        IF (x_polv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute5 := l_db_polv_rec.attribute5;
        END IF;
        IF (x_polv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute6 := l_db_polv_rec.attribute6;
        END IF;
        IF (x_polv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute7 := l_db_polv_rec.attribute7;
        END IF;
        IF (x_polv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute8 := l_db_polv_rec.attribute8;
        END IF;
        IF (x_polv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute9 := l_db_polv_rec.attribute9;
        END IF;
        IF (x_polv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute10 := l_db_polv_rec.attribute10;
        END IF;
        IF (x_polv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute11 := l_db_polv_rec.attribute11;
        END IF;
        IF (x_polv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute12 := l_db_polv_rec.attribute12;
        END IF;
        IF (x_polv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute13 := l_db_polv_rec.attribute13;
        END IF;
        IF (x_polv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute14 := l_db_polv_rec.attribute14;
        END IF;
        IF (x_polv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_polv_rec.attribute15 := l_db_polv_rec.attribute15;
        END IF;
        IF (x_polv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.org_id := l_db_polv_rec.org_id;
        END IF;
        IF (x_polv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.request_id := l_db_polv_rec.request_id;
        END IF;
        IF (x_polv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.program_application_id := l_db_polv_rec.program_application_id;
        END IF;
        IF (x_polv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.program_id := l_db_polv_rec.program_id;
        END IF;
        IF (x_polv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.program_update_date := l_db_polv_rec.program_update_date;
        END IF;
        IF (x_polv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.created_by := l_db_polv_rec.created_by;
        END IF;
        IF (x_polv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.creation_date := l_db_polv_rec.creation_date;
        END IF;
        IF (x_polv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.last_updated_by := l_db_polv_rec.last_updated_by;
        END IF;
        IF (x_polv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_polv_rec.last_update_date := l_db_polv_rec.last_update_date;
        END IF;
        IF (x_polv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.last_update_login := l_db_polv_rec.last_update_login;
        END IF;
        IF (x_polv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_polv_rec.legal_entity_id := l_db_polv_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_POOLS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_polv_rec IN polv_rec_type,
      x_polv_rec OUT NOCOPY polv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_polv_rec := p_polv_rec;
	  x_polv_rec.OBJECT_VERSION_NUMBER := NVL(x_polv_rec.OBJECT_VERSION_NUMBER,0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_polv_rec,                        -- IN
      x_polv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_polv_rec, l_def_polv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_polv_rec := fill_who_columns(l_def_polv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_polv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_polv_rec, l_db_polv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
    -- MVASUDEV COMMENTED
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_polv_rec                     => p_polv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_polv_rec, l_pol_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pol_rec,
      lx_pol_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pol_rec, l_def_polv_rec);
    x_polv_rec := l_def_polv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:polv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      i := p_polv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_polv_rec                     => p_polv_tbl(i),
            x_polv_rec                     => x_polv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_polv_tbl.LAST);
        i := p_polv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:polV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    x_polv_tbl                     OUT NOCOPY polv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_polv_tbl                     => p_polv_tbl,
        x_polv_tbl                     => x_polv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:okl_pools --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pol_rec                      IN pol_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_pol_rec                      pol_rec_type := p_pol_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM okl_pools
     WHERE ID = p_pol_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_POOLS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_rec                     IN polv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_polv_rec                     polv_rec_type := p_polv_rec;
    l_pol_rec                      pol_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_polv_rec, l_pol_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pol_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_POOLS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      i := p_polv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_polv_rec                     => p_polv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.SQLCODE := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_polv_tbl.LAST);
        i := p_polv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_POOLS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_polv_tbl                     IN polv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_polv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_polv_tbl                     => p_polv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_POL_PVT;

/

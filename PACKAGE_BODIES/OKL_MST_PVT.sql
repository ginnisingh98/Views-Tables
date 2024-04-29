--------------------------------------------------------
--  DDL for Package Body OKL_MST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MST_PVT" AS
/* $Header: OKLSMSTB.pls 115.7 2004/02/24 22:42:55 dedey noship $ */



  ---------------------------------
  -- Validate_Attributes for: request_name  --
  -- Hand Coded by DEDEY
  -- Validates FK with OKL_MASS_RBK_CRITERIA.ID
  ---------------------------------

  PROCEDURE validate_request_name(
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 p_request_name    IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE
                                ) IS

    l_present VARCHAR2(1) := 'N';

    CURSOR crit_csr (p_request_name OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE) IS
    SELECT 'Y'
    FROM   okl_mass_rbk_criteria
    WHERE  request_name = p_request_name;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN crit_csr(p_request_name);
    FETCH crit_csr INTO l_present;
    IF crit_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'request_name');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    CLOSE crit_csr;

    RETURN;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      IF crit_csr%ISOPEN THEN
        CLOSE crit_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_request_name;

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
  -- FUNCTION get_rec for: OKL_RBK_SELECTED_CONTRACT_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_mstv_rec                     IN mstv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN mstv_rec_type IS
    CURSOR okl_mstv_pk1_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            REQUEST_NAME,
            KHR_ID,
            CONTRACT_NUMBER,
            CONTRACT_DESCRIPTION,
            KLE_ID,
            TRANSACTION_ID,
            SELECTED_FLAG,
            STATUS,
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
            TRANSACTION_DATE
      FROM Okl_Rbk_Selected_Contract_V
     WHERE okl_rbk_selected_contract_v.id = p_id;
    l_okl_mstv_pk1                 okl_mstv_pk1_csr%ROWTYPE;
    l_mstv_rec                     mstv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_mstv_pk1_csr (p_mstv_rec.id);
    FETCH okl_mstv_pk1_csr INTO
              l_mstv_rec.id,
              l_mstv_rec.request_name,
              l_mstv_rec.khr_id,
              l_mstv_rec.contract_number,
              l_mstv_rec.contract_description,
              l_mstv_rec.kle_id,
              l_mstv_rec.transaction_id,
              l_mstv_rec.selected_flag,
              l_mstv_rec.status,
              l_mstv_rec.attribute_category,
              l_mstv_rec.attribute1,
              l_mstv_rec.attribute2,
              l_mstv_rec.attribute3,
              l_mstv_rec.attribute4,
              l_mstv_rec.attribute5,
              l_mstv_rec.attribute6,
              l_mstv_rec.attribute7,
              l_mstv_rec.attribute8,
              l_mstv_rec.attribute9,
              l_mstv_rec.attribute10,
              l_mstv_rec.attribute11,
              l_mstv_rec.attribute12,
              l_mstv_rec.attribute13,
              l_mstv_rec.attribute14,
              l_mstv_rec.attribute15,
              l_mstv_rec.created_by,
              l_mstv_rec.creation_date,
              l_mstv_rec.last_updated_by,
              l_mstv_rec.last_update_date,
              l_mstv_rec.last_update_login,
              l_mstv_rec.transaction_date;
    x_no_data_found := okl_mstv_pk1_csr%NOTFOUND;
    CLOSE okl_mstv_pk1_csr;
    RETURN(l_mstv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_mstv_rec                     IN mstv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN mstv_rec_type IS
    l_mstv_rec                     mstv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_mstv_rec := get_rec(p_mstv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_mstv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_mstv_rec                     IN mstv_rec_type
  ) RETURN mstv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_mstv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_RBK_SELECTED_CONTRACT
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_mst_rec                      IN mst_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN mst_rec_type IS
    CURSOR okl_mst_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            request_name,
            KHR_ID,
            CONTRACT_NUMBER,
            contract_description,
            KLE_ID,
            TRANSACTION_ID,
            SELECTED_FLAG,
            STATUS,
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
            TRANSACTION_DATE
      FROM Okl_Rbk_Selected_Contract
     WHERE okl_rbk_selected_contract.id = p_id;
    l_okl_mst_pk                   okl_mst_pk_csr%ROWTYPE;
    l_mst_rec                      mst_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_mst_pk_csr (p_mst_rec.id);
    FETCH okl_mst_pk_csr INTO
              l_mst_rec.id,
              l_mst_rec.request_name,
              l_mst_rec.khr_id,
              l_mst_rec.contract_number,
              l_mst_rec.contract_description,
              l_mst_rec.kle_id,
              l_mst_rec.transaction_id,
              l_mst_rec.selected_flag,
              l_mst_rec.status,
              l_mst_rec.attribute_category,
              l_mst_rec.attribute1,
              l_mst_rec.attribute2,
              l_mst_rec.attribute3,
              l_mst_rec.attribute4,
              l_mst_rec.attribute5,
              l_mst_rec.attribute6,
              l_mst_rec.attribute7,
              l_mst_rec.attribute8,
              l_mst_rec.attribute9,
              l_mst_rec.attribute10,
              l_mst_rec.attribute11,
              l_mst_rec.attribute12,
              l_mst_rec.attribute13,
              l_mst_rec.attribute14,
              l_mst_rec.attribute15,
              l_mst_rec.created_by,
              l_mst_rec.creation_date,
              l_mst_rec.last_updated_by,
              l_mst_rec.last_update_date,
              l_mst_rec.last_update_login,
              l_mst_rec.transaction_date;
    x_no_data_found := okl_mst_pk_csr%NOTFOUND;
    CLOSE okl_mst_pk_csr;
    RETURN(l_mst_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_mst_rec                      IN mst_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN mst_rec_type IS
    l_mst_rec                      mst_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_mst_rec := get_rec(p_mst_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_mst_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_mst_rec                      IN mst_rec_type
  ) RETURN mst_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_mst_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_RBK_SELECTED_CONTRACT_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_mstv_rec   IN mstv_rec_type
  ) RETURN mstv_rec_type IS
    l_mstv_rec                     mstv_rec_type := p_mstv_rec;
  BEGIN
    IF (l_mstv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.id := NULL;
    END IF;
    IF (l_mstv_rec.request_name = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.request_name := NULL;
    END IF;
    IF (l_mstv_rec.khr_id = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.khr_id := NULL;
    END IF;
    IF (l_mstv_rec.contract_number = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.contract_number := NULL;
    END IF;
    IF (l_mstv_rec.contract_description = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.contract_description := NULL;
    END IF;
    IF (l_mstv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.kle_id := NULL;
    END IF;
    IF (l_mstv_rec.transaction_id = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.transaction_id := NULL;
    END IF;
    IF (l_mstv_rec.selected_flag = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.selected_flag := NULL;
    END IF;
    IF (l_mstv_rec.status = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.status := NULL;
    END IF;
    IF (l_mstv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute_category := NULL;
    END IF;
    IF (l_mstv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute1 := NULL;
    END IF;
    IF (l_mstv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute2 := NULL;
    END IF;
    IF (l_mstv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute3 := NULL;
    END IF;
    IF (l_mstv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute4 := NULL;
    END IF;
    IF (l_mstv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute5 := NULL;
    END IF;
    IF (l_mstv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute6 := NULL;
    END IF;
    IF (l_mstv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute7 := NULL;
    END IF;
    IF (l_mstv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute8 := NULL;
    END IF;
    IF (l_mstv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute9 := NULL;
    END IF;
    IF (l_mstv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute10 := NULL;
    END IF;
    IF (l_mstv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute11 := NULL;
    END IF;
    IF (l_mstv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute12 := NULL;
    END IF;
    IF (l_mstv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute13 := NULL;
    END IF;
    IF (l_mstv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute14 := NULL;
    END IF;
    IF (l_mstv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_mstv_rec.attribute15 := NULL;
    END IF;
    IF (l_mstv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.created_by := NULL;
    END IF;
    IF (l_mstv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_mstv_rec.creation_date := NULL;
    END IF;
    IF (l_mstv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.last_updated_by := NULL;
    END IF;
    IF (l_mstv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_mstv_rec.last_update_date := NULL;
    END IF;
    IF (l_mstv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_mstv_rec.last_update_login := NULL;
    END IF;
    IF (l_mstv_rec.transaction_date = OKL_API.G_MISS_DATE ) THEN
      l_mstv_rec.transaction_date := NULL;
    END IF;
    RETURN(l_mstv_rec);
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
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------
  -- Validate_Attributes for:OKL_RBK_SELECTED_CONTRACT_V --
  ---------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_mstv_rec                     IN mstv_rec_type
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
    validate_id(x_return_status, p_mstv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --
    -- Hand Coded, DEDEY
    --
    /* Commented to incorporate AM Mass re-book requirement
     * dedey, Bug# , 06/27/2002

    validate_request_name(x_return_status, p_mstv_rec.request_name);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */
    --
    -- Hand Coded, DEDEY
    --

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
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate Record for:OKL_RBK_SELECTED_CONTRACT_V --
  -----------------------------------------------------
  FUNCTION Validate_Record (
    p_mstv_rec IN mstv_rec_type,
    p_db_mstv_rec IN mstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_mstv_rec IN mstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_mstv_rec                  mstv_rec_type := get_rec(p_mstv_rec);
  BEGIN
    l_return_status := Validate_Record(p_mstv_rec => p_mstv_rec,
                                       p_db_mstv_rec => l_db_mstv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN mstv_rec_type,
    p_to   IN OUT NOCOPY mst_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.request_name := p_from.request_name;
    p_to.khr_id := p_from.khr_id;
    p_to.contract_number := p_from.contract_number;
    p_to.contract_description := p_from.contract_description;
    p_to.kle_id := p_from.kle_id;
    p_to.transaction_id := p_from.transaction_id;
    p_to.selected_flag := p_from.selected_flag;
    p_to.status := p_from.status;
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
    p_to.transaction_date := p_from.transaction_date;
  END migrate;
  PROCEDURE migrate (
    p_from IN mst_rec_type,
    p_to   IN OUT NOCOPY mstv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.request_name := p_from.request_name;
    p_to.khr_id := p_from.khr_id;
    p_to.contract_number := p_from.contract_number;
    p_to.contract_description := p_from.contract_description;
    p_to.kle_id := p_from.kle_id;
    p_to.transaction_id := p_from.transaction_id;
    p_to.selected_flag := p_from.selected_flag;
    p_to.status := p_from.status;
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
    p_to.transaction_date := p_from.transaction_date;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- validate_row for:OKL_RBK_SELECTED_CONTRACT_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mstv_rec                     mstv_rec_type := p_mstv_rec;
    l_mst_rec                      mst_rec_type;
    l_mst_rec                      mst_rec_type;
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
    l_return_status := Validate_Attributes(l_mstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_mstv_rec);
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
  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_RBK_SELECTED_CONTRACT_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    i                              NUMBER := 0;
    l_final_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mstv_tbl.COUNT > 0) THEN
      i := p_mstv_tbl.FIRST;
      LOOP
        validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_mstv_rec                     => p_mstv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_final_status := x_return_status;
        END IF;

        EXIT WHEN (i = p_mstv_tbl.LAST);
        i := p_mstv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_final_status;
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
  ----------------------------------------------
  -- insert_row for:OKL_RBK_SELECTED_CONTRACT --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mst_rec                      IN mst_rec_type,
    x_mst_rec                      OUT NOCOPY mst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mst_rec                      mst_rec_type := p_mst_rec;
    l_def_mst_rec                  mst_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_RBK_SELECTED_CONTRACT --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_mst_rec IN mst_rec_type,
      x_mst_rec OUT NOCOPY mst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mst_rec := p_mst_rec;
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
      p_mst_rec,                         -- IN
      l_mst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_RBK_SELECTED_CONTRACT(
      id,
      request_name,
      khr_id,
      contract_number,
      contract_description,
      kle_id,
      transaction_id,
      selected_flag,
      status,
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
      last_update_login,
      transaction_date)
    VALUES (
      l_mst_rec.id,
      l_mst_rec.request_name,
      l_mst_rec.khr_id,
      l_mst_rec.contract_number,
      l_mst_rec.contract_description,
      l_mst_rec.kle_id,
      l_mst_rec.transaction_id,
      l_mst_rec.selected_flag,
      l_mst_rec.status,
      l_mst_rec.attribute_category,
      l_mst_rec.attribute1,
      l_mst_rec.attribute2,
      l_mst_rec.attribute3,
      l_mst_rec.attribute4,
      l_mst_rec.attribute5,
      l_mst_rec.attribute6,
      l_mst_rec.attribute7,
      l_mst_rec.attribute8,
      l_mst_rec.attribute9,
      l_mst_rec.attribute10,
      l_mst_rec.attribute11,
      l_mst_rec.attribute12,
      l_mst_rec.attribute13,
      l_mst_rec.attribute14,
      l_mst_rec.attribute15,
      l_mst_rec.created_by,
      l_mst_rec.creation_date,
      l_mst_rec.last_updated_by,
      l_mst_rec.last_update_date,
      l_mst_rec.last_update_login,
      l_mst_rec.transaction_date);
    -- Set OUT values
    x_mst_rec := l_mst_rec;
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
  -------------------------------------------------
  -- insert_row for :OKL_RBK_SELECTED_CONTRACT_V --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type,
    x_mstv_rec                     OUT NOCOPY mstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mstv_rec                     mstv_rec_type := p_mstv_rec;
    l_def_mstv_rec                 mstv_rec_type;
    l_mst_rec                      mst_rec_type;
    lx_mst_rec                     mst_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_mstv_rec IN mstv_rec_type
    ) RETURN mstv_rec_type IS
      l_mstv_rec mstv_rec_type := p_mstv_rec;
    BEGIN
      l_mstv_rec.CREATION_DATE := SYSDATE;
      l_mstv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_mstv_rec.LAST_UPDATE_DATE := l_mstv_rec.CREATION_DATE;
      l_mstv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_mstv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_mstv_rec);
    END fill_who_columns;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_RBK_SELECTED_CONTRACT_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_mstv_rec IN mstv_rec_type,
      x_mstv_rec OUT NOCOPY mstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mstv_rec := p_mstv_rec;
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
    l_mstv_rec := null_out_defaults(p_mstv_rec);
    -- Set primary key value
    l_mstv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_mstv_rec,                        -- IN
      l_def_mstv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_mstv_rec := fill_who_columns(l_def_mstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_mstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_mstv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_mstv_rec, l_mst_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_mst_rec,
      lx_mst_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_mst_rec, l_def_mstv_rec);
    -- Set OUT values
    x_mstv_rec := l_def_mstv_rec;
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
  -- PL/SQL TBL insert_row for:MSTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type,
    x_mstv_tbl                     OUT NOCOPY mstv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    i                              NUMBER := 0;
    l_final_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mstv_tbl.COUNT > 0) THEN
      i := p_mstv_tbl.FIRST;
      LOOP
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_mstv_rec                     => p_mstv_tbl(i),
            x_mstv_rec                     => x_mstv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           l_final_status := x_return_status;
        END IF;

        EXIT WHEN (i = p_mstv_tbl.LAST);
        i := p_mstv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_final_status;
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
  --------------------------------------------
  -- lock_row for:OKL_RBK_SELECTED_CONTRACT --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mst_rec                      IN mst_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_mst_rec IN mst_rec_type) IS
    SELECT *
      FROM OKL_RBK_SELECTED_CONTRACT
     WHERE ID = p_mst_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_mst_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      IF (l_lock_var.id <> p_mst_rec.id) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.request_name <> p_mst_rec.request_name) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.khr_id <> p_mst_rec.khr_id) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.contract_number <> p_mst_rec.contract_number) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.contract_description <> p_mst_rec.contract_description) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.kle_id <> p_mst_rec.kle_id) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.transaction_id <> p_mst_rec.transaction_id) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.selected_flag <> p_mst_rec.selected_flag) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.status <> p_mst_rec.status) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute_category <> p_mst_rec.attribute_category) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute1 <> p_mst_rec.attribute1) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute2 <> p_mst_rec.attribute2) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute3 <> p_mst_rec.attribute3) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute4 <> p_mst_rec.attribute4) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute5 <> p_mst_rec.attribute5) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute6 <> p_mst_rec.attribute6) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute7 <> p_mst_rec.attribute7) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute8 <> p_mst_rec.attribute8) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute9 <> p_mst_rec.attribute9) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute10 <> p_mst_rec.attribute10) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute11 <> p_mst_rec.attribute11) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute12 <> p_mst_rec.attribute12) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute13 <> p_mst_rec.attribute13) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute14 <> p_mst_rec.attribute14) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute15 <> p_mst_rec.attribute15) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_mst_rec.created_by) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_mst_rec.creation_date) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_mst_rec.last_updated_by) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_mst_rec.last_update_date) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_mst_rec.last_update_login) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.transaction_date <> p_mst_rec.transaction_date) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
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
  -----------------------------------------------
  -- lock_row for: OKL_RBK_SELECTED_CONTRACT_V --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mst_rec                      mst_rec_type;
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
    migrate(p_mstv_rec, l_mst_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_mst_rec
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
  -- PL/SQL TBL lock_row for:MSTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    i                              NUMBER := 0;
    l_final_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_mstv_tbl.COUNT > 0) THEN
      i := p_mstv_tbl.FIRST;
      LOOP
        lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_mstv_rec                     => p_mstv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           l_final_status := x_return_status;
        END IF;
        EXIT WHEN (i = p_mstv_tbl.LAST);
        i := p_mstv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_final_status;
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
  ----------------------------------------------
  -- update_row for:OKL_RBK_SELECTED_CONTRACT --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mst_rec                      IN mst_rec_type,
    x_mst_rec                      OUT NOCOPY mst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mst_rec                      mst_rec_type := p_mst_rec;
    l_def_mst_rec                  mst_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_mst_rec IN mst_rec_type,
      x_mst_rec OUT NOCOPY mst_rec_type
    ) RETURN VARCHAR2 IS
      l_mst_rec                      mst_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mst_rec := p_mst_rec;
      -- Get current database values
      l_mst_rec := get_rec(p_mst_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_mst_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.id := l_mst_rec.id;
        END IF;
        IF (x_mst_rec.request_name = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.request_name := l_mst_rec.request_name;
        END IF;
        IF (x_mst_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.khr_id := l_mst_rec.khr_id;
        END IF;
        IF (x_mst_rec.contract_number = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.contract_number := l_mst_rec.contract_number;
        END IF;
        IF (x_mst_rec.contract_description = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.contract_description := l_mst_rec.contract_description;
        END IF;
        IF (x_mst_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.kle_id := l_mst_rec.kle_id;
        END IF;
        IF (x_mst_rec.transaction_id = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.transaction_id := l_mst_rec.transaction_id;
        END IF;
        IF (x_mst_rec.selected_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.selected_flag := l_mst_rec.selected_flag;
        END IF;
        IF (x_mst_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.status := l_mst_rec.status;
        END IF;
        IF (x_mst_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute_category := l_mst_rec.attribute_category;
        END IF;
        IF (x_mst_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute1 := l_mst_rec.attribute1;
        END IF;
        IF (x_mst_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute2 := l_mst_rec.attribute2;
        END IF;
        IF (x_mst_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute3 := l_mst_rec.attribute3;
        END IF;
        IF (x_mst_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute4 := l_mst_rec.attribute4;
        END IF;
        IF (x_mst_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute5 := l_mst_rec.attribute5;
        END IF;
        IF (x_mst_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute6 := l_mst_rec.attribute6;
        END IF;
        IF (x_mst_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute7 := l_mst_rec.attribute7;
        END IF;
        IF (x_mst_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute8 := l_mst_rec.attribute8;
        END IF;
        IF (x_mst_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute9 := l_mst_rec.attribute9;
        END IF;
        IF (x_mst_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute10 := l_mst_rec.attribute10;
        END IF;
        IF (x_mst_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute11 := l_mst_rec.attribute11;
        END IF;
        IF (x_mst_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute12 := l_mst_rec.attribute12;
        END IF;
        IF (x_mst_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute13 := l_mst_rec.attribute13;
        END IF;
        IF (x_mst_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute14 := l_mst_rec.attribute14;
        END IF;
        IF (x_mst_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_mst_rec.attribute15 := l_mst_rec.attribute15;
        END IF;
        IF (x_mst_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.created_by := l_mst_rec.created_by;
        END IF;
        IF (x_mst_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_mst_rec.creation_date := l_mst_rec.creation_date;
        END IF;
        IF (x_mst_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.last_updated_by := l_mst_rec.last_updated_by;
        END IF;
        IF (x_mst_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_mst_rec.last_update_date := l_mst_rec.last_update_date;
        END IF;
        IF (x_mst_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_mst_rec.last_update_login := l_mst_rec.last_update_login;
        END IF;
        IF (x_mst_rec.transaction_date = OKL_API.G_MISS_DATE)
        THEN
          x_mst_rec.transaction_date := l_mst_rec.transaction_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_RBK_SELECTED_CONTRACT --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_mst_rec IN mst_rec_type,
      x_mst_rec OUT NOCOPY mst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mst_rec := p_mst_rec;
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
      p_mst_rec,                         -- IN
      l_mst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_mst_rec, l_def_mst_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_RBK_SELECTED_CONTRACT
    SET request_name = l_def_mst_rec.request_name,
        KHR_ID = l_def_mst_rec.khr_id,
        CONTRACT_NUMBER = l_def_mst_rec.contract_number,
        contract_description = l_def_mst_rec.contract_description,
        KLE_ID = l_def_mst_rec.kle_id,
        TRANSACTION_ID = l_def_mst_rec.transaction_id,
        SELECTED_FLAG = l_def_mst_rec.selected_flag,
        STATUS = l_def_mst_rec.status,
        ATTRIBUTE_CATEGORY = l_def_mst_rec.attribute_category,
        ATTRIBUTE1 = l_def_mst_rec.attribute1,
        ATTRIBUTE2 = l_def_mst_rec.attribute2,
        ATTRIBUTE3 = l_def_mst_rec.attribute3,
        ATTRIBUTE4 = l_def_mst_rec.attribute4,
        ATTRIBUTE5 = l_def_mst_rec.attribute5,
        ATTRIBUTE6 = l_def_mst_rec.attribute6,
        ATTRIBUTE7 = l_def_mst_rec.attribute7,
        ATTRIBUTE8 = l_def_mst_rec.attribute8,
        ATTRIBUTE9 = l_def_mst_rec.attribute9,
        ATTRIBUTE10 = l_def_mst_rec.attribute10,
        ATTRIBUTE11 = l_def_mst_rec.attribute11,
        ATTRIBUTE12 = l_def_mst_rec.attribute12,
        ATTRIBUTE13 = l_def_mst_rec.attribute13,
        ATTRIBUTE14 = l_def_mst_rec.attribute14,
        ATTRIBUTE15 = l_def_mst_rec.attribute15,
        CREATED_BY = l_def_mst_rec.created_by,
        CREATION_DATE = l_def_mst_rec.creation_date,
        LAST_UPDATED_BY = l_def_mst_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_mst_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_mst_rec.last_update_login,
        TRANSACTION_DATE = l_def_mst_rec.transaction_date
    WHERE ID = l_def_mst_rec.id;

    x_mst_rec := l_mst_rec;
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
  ------------------------------------------------
  -- update_row for:OKL_RBK_SELECTED_CONTRACT_V --
  ------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type,
    x_mstv_rec                     OUT NOCOPY mstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mstv_rec                     mstv_rec_type := p_mstv_rec;
    l_def_mstv_rec                 mstv_rec_type;
    l_db_mstv_rec                  mstv_rec_type;
    l_mst_rec                      mst_rec_type;
    lx_mst_rec                     mst_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_mstv_rec IN mstv_rec_type
    ) RETURN mstv_rec_type IS
      l_mstv_rec mstv_rec_type := p_mstv_rec;
    BEGIN
      l_mstv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_mstv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_mstv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_mstv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_mstv_rec IN mstv_rec_type,
      x_mstv_rec OUT NOCOPY mstv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mstv_rec := p_mstv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_mstv_rec := get_rec(p_mstv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_mstv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.id := l_db_mstv_rec.id;
        END IF;
        IF (x_mstv_rec.request_name = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.request_name := l_db_mstv_rec.request_name;
        END IF;
        IF (x_mstv_rec.khr_id = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.khr_id := l_db_mstv_rec.khr_id;
        END IF;
        IF (x_mstv_rec.contract_number = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.contract_number := l_db_mstv_rec.contract_number;
        END IF;
        IF (x_mstv_rec.contract_description = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.contract_description := l_db_mstv_rec.contract_description;
        END IF;
        IF (x_mstv_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.kle_id := l_db_mstv_rec.kle_id;
        END IF;
        IF (x_mstv_rec.transaction_id = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.transaction_id := l_db_mstv_rec.transaction_id;
        END IF;
        IF (x_mstv_rec.selected_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.selected_flag := l_db_mstv_rec.selected_flag;
        END IF;
        IF (x_mstv_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.status := l_db_mstv_rec.status;
        END IF;
        IF (x_mstv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute_category := l_db_mstv_rec.attribute_category;
        END IF;
        IF (x_mstv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute1 := l_db_mstv_rec.attribute1;
        END IF;
        IF (x_mstv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute2 := l_db_mstv_rec.attribute2;
        END IF;
        IF (x_mstv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute3 := l_db_mstv_rec.attribute3;
        END IF;
        IF (x_mstv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute4 := l_db_mstv_rec.attribute4;
        END IF;
        IF (x_mstv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute5 := l_db_mstv_rec.attribute5;
        END IF;
        IF (x_mstv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute6 := l_db_mstv_rec.attribute6;
        END IF;
        IF (x_mstv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute7 := l_db_mstv_rec.attribute7;
        END IF;
        IF (x_mstv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute8 := l_db_mstv_rec.attribute8;
        END IF;
        IF (x_mstv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute9 := l_db_mstv_rec.attribute9;
        END IF;
        IF (x_mstv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute10 := l_db_mstv_rec.attribute10;
        END IF;
        IF (x_mstv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute11 := l_db_mstv_rec.attribute11;
        END IF;
        IF (x_mstv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute12 := l_db_mstv_rec.attribute12;
        END IF;
        IF (x_mstv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute13 := l_db_mstv_rec.attribute13;
        END IF;
        IF (x_mstv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute14 := l_db_mstv_rec.attribute14;
        END IF;
        IF (x_mstv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_mstv_rec.attribute15 := l_db_mstv_rec.attribute15;
        END IF;
        IF (x_mstv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.created_by := l_db_mstv_rec.created_by;
        END IF;
        IF (x_mstv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_mstv_rec.creation_date := l_db_mstv_rec.creation_date;
        END IF;
        IF (x_mstv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.last_updated_by := l_db_mstv_rec.last_updated_by;
        END IF;
        IF (x_mstv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_mstv_rec.last_update_date := l_db_mstv_rec.last_update_date;
        END IF;
        IF (x_mstv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_mstv_rec.last_update_login := l_db_mstv_rec.last_update_login;
        END IF;
        IF (x_mstv_rec.transaction_date = OKL_API.G_MISS_DATE)
        THEN
          x_mstv_rec.transaction_date := l_db_mstv_rec.transaction_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------------
    -- Set_Attributes for:OKL_RBK_SELECTED_CONTRACT_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_mstv_rec IN mstv_rec_type,
      x_mstv_rec OUT NOCOPY mstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mstv_rec := p_mstv_rec;
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
      p_mstv_rec,                        -- IN
      x_mstv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_mstv_rec, l_def_mstv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_mstv_rec := fill_who_columns(l_def_mstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_mstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_mstv_rec, l_db_mstv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_mstv_rec, l_mst_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_mst_rec,
      lx_mst_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_mst_rec, l_def_mstv_rec);
    x_mstv_rec := l_def_mstv_rec;
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
  -- PL/SQL TBL update_row for:mstv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type,
    x_mstv_tbl                     OUT NOCOPY mstv_tbl_type ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    i                              NUMBER := 0;
    l_final_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mstv_tbl.COUNT > 0) THEN
      i := p_mstv_tbl.FIRST;
      LOOP
        update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_mstv_rec                     => p_mstv_tbl(i),
            x_mstv_rec                     => x_mstv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           l_final_status := x_return_status;
        END IF;

        EXIT WHEN (i = p_mstv_tbl.LAST);
        i := p_mstv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_final_status;
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
  ----------------------------------------------
  -- delete_row for:OKL_RBK_SELECTED_CONTRACT --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mst_rec                      IN mst_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mst_rec                      mst_rec_type := p_mst_rec;
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

    DELETE FROM OKL_RBK_SELECTED_CONTRACT
     WHERE ID = p_mst_rec.id;

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

  ------------------------------------------------
  -- delete_row for:OKL_RBK_SELECTED_CONTRACT_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_rec                     IN mstv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_mstv_rec                     mstv_rec_type := p_mstv_rec;
    l_mst_rec                      mst_rec_type;
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
    migrate(l_mstv_rec, l_mst_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_mst_rec
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

  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_RBK_SELECTED_CONTRACT_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mstv_tbl                     IN mstv_tbl_type ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    i                              NUMBER := 0;
    l_final_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mstv_tbl.COUNT > 0) THEN
      i := p_mstv_tbl.FIRST;
      LOOP
        delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_mstv_rec                     => p_mstv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           l_final_status := x_return_status;
        END IF;

        EXIT WHEN (i = p_mstv_tbl.LAST);
        i := p_mstv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_final_status;
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

END OKL_MST_PVT;

/

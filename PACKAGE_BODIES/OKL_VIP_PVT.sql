--------------------------------------------------------
--  DDL for Package Body OKL_VIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VIP_PVT" AS
/* $Header: OKLSVIPB.pls 115.3 2003/02/19 22:07:59 sanahuja noship $ */
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
  -- FUNCTION get_rec for: OKL_VAR_INT_PROCESS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vipv_rec                     IN vipv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vipv_rec_type IS
    CURSOR okl_vipv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PARENT_TRX_ID,
            CHILD_TRX_ID,
            CONTRACT_NUMBER,
            REBOOK_STATUS,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
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
      FROM Okl_Var_Int_Process_V
     WHERE okl_var_int_process_v.id = p_id;
    l_okl_vipv_pk                  okl_vipv_pk_csr%ROWTYPE;
    l_vipv_rec                     vipv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_vipv_pk_csr (p_vipv_rec.id);
    FETCH okl_vipv_pk_csr INTO
              l_vipv_rec.id,
              l_vipv_rec.object_version_number,
              l_vipv_rec.parent_trx_id,
              l_vipv_rec.child_trx_id,
              l_vipv_rec.contract_number,
              l_vipv_rec.rebook_status,
              l_vipv_rec.REQUEST_ID,
              l_vipv_rec.PROGRAM_APPLICATION_ID,
              l_vipv_rec.PROGRAM_ID,
              l_vipv_rec.PROGRAM_UPDATE_DATE,
              l_vipv_rec.ORG_ID,
              l_vipv_rec.attribute_category,
              l_vipv_rec.attribute1,
              l_vipv_rec.attribute2,
              l_vipv_rec.attribute3,
              l_vipv_rec.attribute4,
              l_vipv_rec.attribute5,
              l_vipv_rec.attribute6,
              l_vipv_rec.attribute7,
              l_vipv_rec.attribute8,
              l_vipv_rec.attribute9,
              l_vipv_rec.attribute10,
              l_vipv_rec.attribute11,
              l_vipv_rec.attribute12,
              l_vipv_rec.attribute13,
              l_vipv_rec.attribute14,
              l_vipv_rec.attribute15,
              l_vipv_rec.created_by,
              l_vipv_rec.creation_date,
              l_vipv_rec.last_updated_by,
              l_vipv_rec.last_update_date,
              l_vipv_rec.last_update_login;
    x_no_data_found := okl_vipv_pk_csr%NOTFOUND;
    CLOSE okl_vipv_pk_csr;
    RETURN(l_vipv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vipv_rec                     IN vipv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN vipv_rec_type IS
    l_vipv_rec                     vipv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_vipv_rec := get_rec(p_vipv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_vipv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vipv_rec                     IN vipv_rec_type
  ) RETURN vipv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vipv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_VAR_INT_PROCESS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vip_rec                      IN vip_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vip_rec_type IS
    CURSOR okl_var_int_process_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            PARENT_TRX_ID,
            CHILD_TRX_ID,
            CONTRACT_NUMBER,
            REBOOK_STATUS,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ORG_ID,
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
            OBJECT_VERSION_NUMBER
      FROM Okl_Var_Int_Process_B
     WHERE okl_var_int_process_b.id = p_id;
    l_okl_var_int_process_b_pk     okl_var_int_process_b_pk_csr%ROWTYPE;
    l_vip_rec                      vip_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_var_int_process_b_pk_csr (p_vip_rec.id);
    FETCH okl_var_int_process_b_pk_csr INTO
              l_vip_rec.id,
              l_vip_rec.parent_trx_id,
              l_vip_rec.child_trx_id,
              l_vip_rec.contract_number,
              l_vip_rec.rebook_status,
              l_vip_rec.REQUEST_ID,
              l_vip_rec.PROGRAM_APPLICATION_ID,
              l_vip_rec.PROGRAM_ID,
              l_vip_rec.PROGRAM_UPDATE_DATE,
              l_vip_rec.ORG_ID,
              l_vip_rec.attribute_category,
              l_vip_rec.attribute1,
              l_vip_rec.attribute2,
              l_vip_rec.attribute3,
              l_vip_rec.attribute4,
              l_vip_rec.attribute5,
              l_vip_rec.attribute6,
              l_vip_rec.attribute7,
              l_vip_rec.attribute8,
              l_vip_rec.attribute9,
              l_vip_rec.attribute10,
              l_vip_rec.attribute11,
              l_vip_rec.attribute12,
              l_vip_rec.attribute13,
              l_vip_rec.attribute14,
              l_vip_rec.attribute15,
              l_vip_rec.created_by,
              l_vip_rec.creation_date,
              l_vip_rec.last_updated_by,
              l_vip_rec.last_update_date,
              l_vip_rec.last_update_login,
              l_vip_rec.object_version_number;
    x_no_data_found := okl_var_int_process_b_pk_csr%NOTFOUND;
    CLOSE okl_var_int_process_b_pk_csr;
    RETURN(l_vip_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vip_rec                      IN vip_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN vip_rec_type IS
    l_vip_rec                      vip_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_vip_rec := get_rec(p_vip_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_vip_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vip_rec                      IN vip_rec_type
  ) RETURN vip_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vip_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_VAR_INT_PROCESS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_vipv_rec   IN vipv_rec_type
  ) RETURN vipv_rec_type IS
    l_vipv_rec                     vipv_rec_type := p_vipv_rec;
  BEGIN
    IF (l_vipv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.id := NULL;
    END IF;
    IF (l_vipv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.object_version_number := NULL;
    END IF;
    IF (l_vipv_rec.parent_trx_id = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.parent_trx_id := NULL;
    END IF;
    IF (l_vipv_rec.child_trx_id = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.child_trx_id := NULL;
    END IF;
    IF (l_vipv_rec.contract_number = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.contract_number := NULL;
    END IF;
    IF (l_vipv_rec.rebook_status = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.rebook_status := NULL;
    END IF;
    IF (l_vipv_rec.request_id = Okl_Api.G_MISS_NUM) THEN
      l_vipv_rec.request_id := NULL;
    END IF;
    IF (l_vipv_rec.program_application_id = Okl_Api.G_MISS_NUM) THEN
      l_vipv_rec.program_application_id := NULL;
    END IF;
    IF (l_vipv_rec.program_id = Okl_Api.G_MISS_NUM) THEN
      l_vipv_rec.program_id := NULL;
    END IF;
    IF (l_vipv_rec.program_update_date = Okl_Api.G_MISS_DATE) THEN
      l_vipv_rec.program_update_date := NULL;
    END IF;
    IF (l_vipv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_vipv_rec.org_id := NULL;
    END IF;
    IF (l_vipv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute_category := NULL;
    END IF;
    IF (l_vipv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute1 := NULL;
    END IF;
    IF (l_vipv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute2 := NULL;
    END IF;
    IF (l_vipv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute3 := NULL;
    END IF;
    IF (l_vipv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute4 := NULL;
    END IF;
    IF (l_vipv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute5 := NULL;
    END IF;
    IF (l_vipv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute6 := NULL;
    END IF;
    IF (l_vipv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute7 := NULL;
    END IF;
    IF (l_vipv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute8 := NULL;
    END IF;
    IF (l_vipv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute9 := NULL;
    END IF;
    IF (l_vipv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute10 := NULL;
    END IF;
    IF (l_vipv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute11 := NULL;
    END IF;
    IF (l_vipv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute12 := NULL;
    END IF;
    IF (l_vipv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute13 := NULL;
    END IF;
    IF (l_vipv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute14 := NULL;
    END IF;
    IF (l_vipv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_vipv_rec.attribute15 := NULL;
    END IF;
    IF (l_vipv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.created_by := NULL;
    END IF;
    IF (l_vipv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_vipv_rec.creation_date := NULL;
    END IF;
    IF (l_vipv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.last_updated_by := NULL;
    END IF;
    IF (l_vipv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_vipv_rec.last_update_date := NULL;
    END IF;
    IF (l_vipv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_vipv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_vipv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  --------------------------------------------
  -- Validate_Attributes for: PARENT_TRX_ID --
  --------------------------------------------
  PROCEDURE validate_parent_trx_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_parent_trx_id                IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_parent_trx_id = OKC_API.G_MISS_NUM OR
        p_parent_trx_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'parent_trx_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_parent_trx_id;
  ----------------------------------------------
  -- Validate_Attributes for: CONTRACT_NUMBER --
  ----------------------------------------------
  PROCEDURE validate_contract_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_contract_number              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_contract_number = OKC_API.G_MISS_CHAR OR
        p_contract_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'contract_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_contract_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_VAR_INT_PROCESS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_vipv_rec                     IN vipv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_vipv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_vipv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    -- ***
    -- parent_trx_id
    -- ***
    validate_parent_trx_id(x_return_status, p_vipv_rec.parent_trx_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    -- ***
    -- contract_number
    -- ***
    validate_contract_number(x_return_status, p_vipv_rec.contract_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    -- ***
    -- Post-TAPI changes to make sure all fields are validated
    -- ***
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate Record for:OKL_VAR_INT_PROCESS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_vipv_rec IN vipv_rec_type,
    p_db_vipv_rec IN vipv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_vipv_rec IN vipv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_vipv_rec                  vipv_rec_type := get_rec(p_vipv_rec);
  BEGIN
    l_return_status := Validate_Record(p_vipv_rec => p_vipv_rec,
                                       p_db_vipv_rec => l_db_vipv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN vipv_rec_type,
    p_to   IN OUT NOCOPY vip_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.parent_trx_id := p_from.parent_trx_id;
    p_to.child_trx_id := p_from.child_trx_id;
    p_to.contract_number := p_from.contract_number;
    p_to.rebook_status := p_from.rebook_status;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from IN vip_rec_type,
    p_to   IN OUT NOCOPY vipv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.parent_trx_id := p_from.parent_trx_id;
    p_to.child_trx_id := p_from.child_trx_id;
    p_to.contract_number := p_from.contract_number;
    p_to.rebook_status := p_from.rebook_status;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.org_id := p_from.org_id;
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
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_VAR_INT_PROCESS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_rec                     IN vipv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vipv_rec                     vipv_rec_type := p_vipv_rec;
    l_vip_rec                      vip_rec_type;
    l_vip_rec                      vip_rec_type;
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
    l_return_status := Validate_Attributes(l_vipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_vipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:OKL_VAR_INT_PROCESS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_tbl                     IN vipv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vipv_tbl.COUNT > 0) THEN
      i := p_vipv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vipv_rec                     => p_vipv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_vipv_tbl.LAST);
        i := p_vipv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_VAR_INT_PROCESS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vip_rec                      IN vip_rec_type,
    x_vip_rec                      OUT NOCOPY vip_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vip_rec                      vip_rec_type := p_vip_rec;
    l_def_vip_rec                  vip_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_VAR_INT_PROCESS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vip_rec IN vip_rec_type,
      x_vip_rec OUT NOCOPY vip_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vip_rec := p_vip_rec;
      x_vip_rec.OBJECT_VERSION_NUMBER := 1;

	IF (x_vip_rec.request_id IS NULL OR x_vip_rec.request_id = Okl_Api.G_MISS_NUM) THEN
	  SELECT
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
	  		DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
	  		DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
	  INTO
	  	   x_vip_rec.request_id,
	  	   x_vip_rec.program_application_id,
	  	   x_vip_rec.program_id,
	  	   x_vip_rec.program_update_date
	  FROM dual;
	END IF;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_vip_rec,                         -- IN
      l_vip_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_VAR_INT_PROCESS_B(
      id,
      parent_trx_id,
      child_trx_id,
      contract_number,
      rebook_status,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      org_id,
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
      object_version_number)
    VALUES (
      l_vip_rec.id,
      l_vip_rec.parent_trx_id,
      l_vip_rec.child_trx_id,
      l_vip_rec.contract_number,
      l_vip_rec.rebook_status,
      l_vip_rec.request_id,
      l_vip_rec.program_application_id,
      l_vip_rec.program_id,
      l_vip_rec.program_update_date,
      l_vip_rec.org_id,
      l_vip_rec.attribute_category,
      l_vip_rec.attribute1,
      l_vip_rec.attribute2,
      l_vip_rec.attribute3,
      l_vip_rec.attribute4,
      l_vip_rec.attribute5,
      l_vip_rec.attribute6,
      l_vip_rec.attribute7,
      l_vip_rec.attribute8,
      l_vip_rec.attribute9,
      l_vip_rec.attribute10,
      l_vip_rec.attribute11,
      l_vip_rec.attribute12,
      l_vip_rec.attribute13,
      l_vip_rec.attribute14,
      l_vip_rec.attribute15,
      l_vip_rec.created_by,
      l_vip_rec.creation_date,
      l_vip_rec.last_updated_by,
      l_vip_rec.last_update_date,
      l_vip_rec.last_update_login,
      l_vip_rec.object_version_number);
    -- Set OUT values
    x_vip_rec := l_vip_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKL_VAR_INT_PROCESS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_rec                     IN vipv_rec_type,
    x_vipv_rec                     OUT NOCOPY vipv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vipv_rec                     vipv_rec_type := p_vipv_rec;
    l_def_vipv_rec                 vipv_rec_type;
    l_vip_rec                      vip_rec_type;
    lx_vip_rec                     vip_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vipv_rec IN vipv_rec_type
    ) RETURN vipv_rec_type IS
      l_vipv_rec vipv_rec_type := p_vipv_rec;
    BEGIN
      l_vipv_rec.CREATION_DATE := SYSDATE;
      l_vipv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_vipv_rec.LAST_UPDATE_DATE := l_vipv_rec.CREATION_DATE;
      l_vipv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vipv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vipv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_VAR_INT_PROCESS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vipv_rec IN vipv_rec_type,
      x_vipv_rec OUT NOCOPY vipv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vipv_rec := p_vipv_rec;
      x_vipv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_vipv_rec := null_out_defaults(p_vipv_rec);
    -- Set primary key value
    l_vipv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_vipv_rec,                        -- IN
      l_def_vipv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vipv_rec := fill_who_columns(l_def_vipv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vipv_rec, l_vip_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vip_rec,
      lx_vip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vip_rec, l_def_vipv_rec);
    -- Set OUT values
    x_vipv_rec := l_def_vipv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:VIPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_tbl                     IN vipv_tbl_type,
    x_vipv_tbl                     OUT NOCOPY vipv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vipv_tbl.COUNT > 0) THEN
      i := p_vipv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vipv_rec                     => p_vipv_tbl(i),
          x_vipv_rec                     => x_vipv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_vipv_tbl.LAST);
        i := p_vipv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_VAR_INT_PROCESS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vip_rec                      IN vip_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_vip_rec IN vip_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_VAR_INT_PROCESS_B
     WHERE ID = p_vip_rec.id
       AND OBJECT_VERSION_NUMBER = p_vip_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_vip_rec IN vip_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_VAR_INT_PROCESS_B
     WHERE ID = p_vip_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_VAR_INT_PROCESS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_VAR_INT_PROCESS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_vip_rec);
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
      OPEN lchk_csr(p_vip_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_vip_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_vip_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKL_VAR_INT_PROCESS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_rec                     IN vipv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vip_rec                      vip_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_vipv_rec, l_vip_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:VIPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_tbl                     IN vipv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_vipv_tbl.COUNT > 0) THEN
      i := p_vipv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vipv_rec                     => p_vipv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_vipv_tbl.LAST);
        i := p_vipv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_VAR_INT_PROCESS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vip_rec                      IN vip_rec_type,
    x_vip_rec                      OUT NOCOPY vip_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vip_rec                      vip_rec_type := p_vip_rec;
    l_def_vip_rec                  vip_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vip_rec IN vip_rec_type,
      x_vip_rec OUT NOCOPY vip_rec_type
    ) RETURN VARCHAR2 IS
      l_vip_rec                      vip_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vip_rec := p_vip_rec;
      -- Get current database values
      l_vip_rec := get_rec(p_vip_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_vip_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.id := l_vip_rec.id;
        END IF;
        IF (x_vip_rec.parent_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.parent_trx_id := l_vip_rec.parent_trx_id;
        END IF;
        IF (x_vip_rec.child_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.child_trx_id := l_vip_rec.child_trx_id;
        END IF;
        IF (x_vip_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.contract_number := l_vip_rec.contract_number;
        END IF;
        IF (x_vip_rec.rebook_status = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.rebook_status := l_vip_rec.rebook_status;
        END IF;
      IF (x_vip_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vip_rec.request_id := l_vip_rec.request_id;
      END IF;
      IF (x_vip_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vip_rec.program_application_id := l_vip_rec.program_application_id;
      END IF;
      IF (x_vip_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vip_rec.program_id := l_vip_rec.program_id;
      END IF;
      IF (x_vip_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_vip_rec.program_update_date := l_vip_rec.program_update_date;
      END IF;
      IF (x_vip_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vip_rec.org_id := l_vip_rec.org_id;
      END IF;
        IF (x_vip_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute_category := l_vip_rec.attribute_category;
        END IF;
        IF (x_vip_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute1 := l_vip_rec.attribute1;
        END IF;
        IF (x_vip_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute2 := l_vip_rec.attribute2;
        END IF;
        IF (x_vip_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute3 := l_vip_rec.attribute3;
        END IF;
        IF (x_vip_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute4 := l_vip_rec.attribute4;
        END IF;
        IF (x_vip_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute5 := l_vip_rec.attribute5;
        END IF;
        IF (x_vip_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute6 := l_vip_rec.attribute6;
        END IF;
        IF (x_vip_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute7 := l_vip_rec.attribute7;
        END IF;
        IF (x_vip_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute8 := l_vip_rec.attribute8;
        END IF;
        IF (x_vip_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute9 := l_vip_rec.attribute9;
        END IF;
        IF (x_vip_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute10 := l_vip_rec.attribute10;
        END IF;
        IF (x_vip_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute11 := l_vip_rec.attribute11;
        END IF;
        IF (x_vip_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute12 := l_vip_rec.attribute12;
        END IF;
        IF (x_vip_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute13 := l_vip_rec.attribute13;
        END IF;
        IF (x_vip_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute14 := l_vip_rec.attribute14;
        END IF;
        IF (x_vip_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_vip_rec.attribute15 := l_vip_rec.attribute15;
        END IF;
        IF (x_vip_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.created_by := l_vip_rec.created_by;
        END IF;
        IF (x_vip_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_vip_rec.creation_date := l_vip_rec.creation_date;
        END IF;
        IF (x_vip_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.last_updated_by := l_vip_rec.last_updated_by;
        END IF;
        IF (x_vip_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_vip_rec.last_update_date := l_vip_rec.last_update_date;
        END IF;
        IF (x_vip_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.last_update_login := l_vip_rec.last_update_login;
        END IF;
        IF (x_vip_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_vip_rec.object_version_number := l_vip_rec.object_version_number;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_VAR_INT_PROCESS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vip_rec IN vip_rec_type,
      x_vip_rec OUT NOCOPY vip_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vip_rec := p_vip_rec;
      x_vip_rec.OBJECT_VERSION_NUMBER := p_vip_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_vip_rec,                         -- IN
      l_vip_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vip_rec, l_def_vip_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_VAR_INT_PROCESS_B
    SET PARENT_TRX_ID = l_def_vip_rec.parent_trx_id,
        CHILD_TRX_ID = l_def_vip_rec.child_trx_id,
        CONTRACT_NUMBER = l_def_vip_rec.contract_number,
        REBOOK_STATUS = l_def_vip_rec.rebook_status,
        REQUEST_ID = l_def_vip_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_vip_rec.program_application_id,
        PROGRAM_ID = l_def_vip_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_vip_rec.program_update_date,
        ORG_ID = l_def_vip_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_vip_rec.attribute_category,
        ATTRIBUTE1 = l_def_vip_rec.attribute1,
        ATTRIBUTE2 = l_def_vip_rec.attribute2,
        ATTRIBUTE3 = l_def_vip_rec.attribute3,
        ATTRIBUTE4 = l_def_vip_rec.attribute4,
        ATTRIBUTE5 = l_def_vip_rec.attribute5,
        ATTRIBUTE6 = l_def_vip_rec.attribute6,
        ATTRIBUTE7 = l_def_vip_rec.attribute7,
        ATTRIBUTE8 = l_def_vip_rec.attribute8,
        ATTRIBUTE9 = l_def_vip_rec.attribute9,
        ATTRIBUTE10 = l_def_vip_rec.attribute10,
        ATTRIBUTE11 = l_def_vip_rec.attribute11,
        ATTRIBUTE12 = l_def_vip_rec.attribute12,
        ATTRIBUTE13 = l_def_vip_rec.attribute13,
        ATTRIBUTE14 = l_def_vip_rec.attribute14,
        ATTRIBUTE15 = l_def_vip_rec.attribute15,
        CREATED_BY = l_def_vip_rec.created_by,
        CREATION_DATE = l_def_vip_rec.creation_date,
        LAST_UPDATED_BY = l_def_vip_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_vip_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_vip_rec.last_update_login,
        OBJECT_VERSION_NUMBER = l_def_vip_rec.object_version_number
    WHERE ID = l_def_vip_rec.id;

    x_vip_rec := l_vip_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_VAR_INT_PROCESS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_rec                     IN vipv_rec_type,
    x_vipv_rec                     OUT NOCOPY vipv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vipv_rec                     vipv_rec_type := p_vipv_rec;
    l_def_vipv_rec                 vipv_rec_type;
    l_db_vipv_rec                  vipv_rec_type;
    l_vip_rec                      vip_rec_type;
    lx_vip_rec                     vip_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vipv_rec IN vipv_rec_type
    ) RETURN vipv_rec_type IS
      l_vipv_rec vipv_rec_type := p_vipv_rec;
    BEGIN
      l_vipv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_vipv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vipv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vipv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vipv_rec IN vipv_rec_type,
      x_vipv_rec OUT NOCOPY vipv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vipv_rec := p_vipv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_vipv_rec := get_rec(p_vipv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	-- Post-TAPI changes - Added for object version compatibility for now
        IF (x_vipv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_vipv_rec.object_version_number := l_db_vipv_rec.object_version_number;
        END IF;
        IF (x_vipv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.id := l_db_vipv_rec.id;
        END IF;
        IF (x_vipv_rec.parent_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.parent_trx_id := l_db_vipv_rec.parent_trx_id;
        END IF;
        IF (x_vipv_rec.child_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.child_trx_id := l_db_vipv_rec.child_trx_id;
        END IF;
        IF (x_vipv_rec.contract_number = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.contract_number := l_db_vipv_rec.contract_number;
        END IF;
        IF (x_vipv_rec.rebook_status = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.rebook_status := l_db_vipv_rec.rebook_status;
        END IF;
      IF (x_vipv_rec.request_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vipv_rec.request_id := l_db_vipv_rec.request_id;
      END IF;
      IF (x_vipv_rec.program_application_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vipv_rec.program_application_id := l_db_vipv_rec.program_application_id;
      END IF;
      IF (x_vipv_rec.program_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vipv_rec.program_id := l_db_vipv_rec.program_id;
      END IF;
      IF (x_vipv_rec.program_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_vipv_rec.program_update_date := l_db_vipv_rec.program_update_date;
      END IF;
      IF (x_vipv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_vipv_rec.org_id := l_db_vipv_rec.org_id;
      END IF;
        IF (x_vipv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute_category := l_db_vipv_rec.attribute_category;
        END IF;
        IF (x_vipv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute1 := l_db_vipv_rec.attribute1;
        END IF;
        IF (x_vipv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute2 := l_db_vipv_rec.attribute2;
        END IF;
        IF (x_vipv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute3 := l_db_vipv_rec.attribute3;
        END IF;
        IF (x_vipv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute4 := l_db_vipv_rec.attribute4;
        END IF;
        IF (x_vipv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute5 := l_db_vipv_rec.attribute5;
        END IF;
        IF (x_vipv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute6 := l_db_vipv_rec.attribute6;
        END IF;
        IF (x_vipv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute7 := l_db_vipv_rec.attribute7;
        END IF;
        IF (x_vipv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute8 := l_db_vipv_rec.attribute8;
        END IF;
        IF (x_vipv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute9 := l_db_vipv_rec.attribute9;
        END IF;
        IF (x_vipv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute10 := l_db_vipv_rec.attribute10;
        END IF;
        IF (x_vipv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute11 := l_db_vipv_rec.attribute11;
        END IF;
        IF (x_vipv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute12 := l_db_vipv_rec.attribute12;
        END IF;
        IF (x_vipv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute13 := l_db_vipv_rec.attribute13;
        END IF;
        IF (x_vipv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute14 := l_db_vipv_rec.attribute14;
        END IF;
        IF (x_vipv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_vipv_rec.attribute15 := l_db_vipv_rec.attribute15;
        END IF;
        IF (x_vipv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.created_by := l_db_vipv_rec.created_by;
        END IF;
        IF (x_vipv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_vipv_rec.creation_date := l_db_vipv_rec.creation_date;
        END IF;
        IF (x_vipv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.last_updated_by := l_db_vipv_rec.last_updated_by;
        END IF;
        IF (x_vipv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_vipv_rec.last_update_date := l_db_vipv_rec.last_update_date;
        END IF;
        IF (x_vipv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_vipv_rec.last_update_login := l_db_vipv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_VAR_INT_PROCESS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vipv_rec IN vipv_rec_type,
      x_vipv_rec OUT NOCOPY vipv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vipv_rec := p_vipv_rec;
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
      p_vipv_rec,                        -- IN
      x_vipv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vipv_rec, l_def_vipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vipv_rec := fill_who_columns(l_def_vipv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vipv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vipv_rec, l_db_vipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /* Post-TAPI changes - Remove for object_version_compitability
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_vipv_rec                     => p_vipv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vipv_rec, l_vip_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vip_rec,
      lx_vip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vip_rec, l_def_vipv_rec);
    x_vipv_rec := l_def_vipv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:VIPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_tbl                     IN vipv_tbl_type,
    x_vipv_tbl                     OUT NOCOPY vipv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vipv_tbl.COUNT > 0) THEN
      i := p_vipv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vipv_rec                     => p_vipv_tbl(i),
          x_vipv_rec                     => x_vipv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_vipv_tbl.LAST);
        i := p_vipv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_VAR_INT_PROCESS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vip_rec                      IN vip_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vip_rec                      vip_rec_type := p_vip_rec;
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

    DELETE FROM OKL_VAR_INT_PROCESS_B
     WHERE ID = p_vip_rec.id;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_VAR_INT_PROCESS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_rec                     IN vipv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_vipv_rec                     vipv_rec_type := p_vipv_rec;
    l_vip_rec                      vip_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_vipv_rec, l_vip_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vip_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:OKL_VAR_INT_PROCESS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vipv_tbl                     IN vipv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vipv_tbl.COUNT > 0) THEN
      i := p_vipv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_vipv_rec                     => p_vipv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_vipv_tbl.LAST);
        i := p_vipv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_VIP_PVT;



/

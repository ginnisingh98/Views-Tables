--------------------------------------------------------
--  DDL for Package Body OKL_CSP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSP_PVT" AS
/* $Header: OKLSCSPB.pls 115.6 2002/11/30 09:12:15 spillaip noship $ */
  G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
  G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
  G_NO_MATCHING_RECORD          CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_khr_id
-- Description          : FK validation with OKL_K_HEADERS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_khr_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_cspv_rec IN cspv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_khr_id_validate(p_khr_id OKL_K_HEADERS_V.ID%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_K_HEADERS khrv
                  WHERE khrv.id = p_khr_id);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_cspv_rec.khr_id = OKL_API.G_MISS_NUM) OR
       (p_cspv_rec.khr_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_khr_id_validate(p_cspv_rec.khr_id);
    -- If the cursor is open then it has to be closed
    IF c_khr_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_khr_id_validate into ln_dummy;
    CLOSE c_khr_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is Required Value
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'khr_id');
    -- If the cursor is open then it has to be closed
    IF c_khr_id_validate%ISOPEN THEN
       CLOSE c_khr_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'khr_id');
    -- If the cursor is open then it has to be closed
    IF c_khr_id_validate%ISOPEN THEN
       CLOSE c_khr_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_khr_id_validate%ISOPEN THEN
       CLOSE c_khr_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_khr_id;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_pov_id
-- Description          : FK validation with OKL_PDT_OPT_VALS
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_pov_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_cspv_rec IN cspv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_pov_id_validate(p_pov_id OKL_PDT_OPT_VALS.ID%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKL_PDT_OPT_VALS
                 WHERE id = p_pov_id);
    BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_cspv_rec.pov_id = OKL_API.G_MISS_NUM) OR
       (p_cspv_rec.pov_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_pov_id_validate(p_cspv_rec.pov_id);
    IF c_pov_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_pov_id_validate into ln_dummy;
    CLOSE c_pov_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is Required Value
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'pov_id');
    -- If the cursor is open then it has to be closed
    IF c_pov_id_validate%ISOPEN THEN
       CLOSE c_pov_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'pov_id');
    IF c_pov_id_validate%ISOPEN THEN
       CLOSE c_pov_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_pov_id_validate%ISOPEN THEN
       CLOSE c_pov_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_pov_id;
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
  -- FUNCTION get_rec for: OKL_SLCTD_OPTNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_csp_rec                      IN csp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN csp_rec_type IS
    CURSOR csp_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            POV_ID,
            KHR_ID,
            OBJECT_VERSION_NUMBER,
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
      FROM Okl_Slctd_Optns
     WHERE okl_slctd_optns.id   = p_id;
    l_csp_pk                       csp_pk_csr%ROWTYPE;
    l_csp_rec                      csp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN csp_pk_csr (p_csp_rec.id);
    FETCH csp_pk_csr INTO
              l_csp_rec.ID,
              l_csp_rec.POV_ID,
              l_csp_rec.KHR_ID,
              l_csp_rec.OBJECT_VERSION_NUMBER,
              l_csp_rec.ATTRIBUTE_CATEGORY,
              l_csp_rec.ATTRIBUTE1,
              l_csp_rec.ATTRIBUTE2,
              l_csp_rec.ATTRIBUTE3,
              l_csp_rec.ATTRIBUTE4,
              l_csp_rec.ATTRIBUTE5,
              l_csp_rec.ATTRIBUTE6,
              l_csp_rec.ATTRIBUTE7,
              l_csp_rec.ATTRIBUTE8,
              l_csp_rec.ATTRIBUTE9,
              l_csp_rec.ATTRIBUTE10,
              l_csp_rec.ATTRIBUTE11,
              l_csp_rec.ATTRIBUTE12,
              l_csp_rec.ATTRIBUTE13,
              l_csp_rec.ATTRIBUTE14,
              l_csp_rec.ATTRIBUTE15,
              l_csp_rec.CREATED_BY,
              l_csp_rec.CREATION_DATE,
              l_csp_rec.LAST_UPDATED_BY,
              l_csp_rec.LAST_UPDATE_DATE,
              l_csp_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := csp_pk_csr%NOTFOUND;
    CLOSE csp_pk_csr;
    RETURN(l_csp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_csp_rec                      IN csp_rec_type
  ) RETURN csp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_csp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SLCTD_OPTNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cspv_rec                     IN cspv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cspv_rec_type IS
    CURSOR okl_cspv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            POV_ID,
            KHR_ID,
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
      FROM Okl_Slctd_Optns_V
     WHERE okl_slctd_optns_v.id = p_id;
    l_okl_cspv_pk                  okl_cspv_pk_csr%ROWTYPE;
    l_cspv_rec                     cspv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cspv_pk_csr (p_cspv_rec.id);
    FETCH okl_cspv_pk_csr INTO
              l_cspv_rec.ID,
              l_cspv_rec.OBJECT_VERSION_NUMBER,
              l_cspv_rec.POV_ID,
              l_cspv_rec.KHR_ID,
              l_cspv_rec.ATTRIBUTE_CATEGORY,
              l_cspv_rec.ATTRIBUTE1,
              l_cspv_rec.ATTRIBUTE2,
              l_cspv_rec.ATTRIBUTE3,
              l_cspv_rec.ATTRIBUTE4,
              l_cspv_rec.ATTRIBUTE5,
              l_cspv_rec.ATTRIBUTE6,
              l_cspv_rec.ATTRIBUTE7,
              l_cspv_rec.ATTRIBUTE8,
              l_cspv_rec.ATTRIBUTE9,
              l_cspv_rec.ATTRIBUTE10,
              l_cspv_rec.ATTRIBUTE11,
              l_cspv_rec.ATTRIBUTE12,
              l_cspv_rec.ATTRIBUTE13,
              l_cspv_rec.ATTRIBUTE14,
              l_cspv_rec.ATTRIBUTE15,
              l_cspv_rec.CREATED_BY,
              l_cspv_rec.CREATION_DATE,
              l_cspv_rec.LAST_UPDATED_BY,
              l_cspv_rec.LAST_UPDATE_DATE,
              l_cspv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cspv_pk_csr%NOTFOUND;
    CLOSE okl_cspv_pk_csr;
    RETURN(l_cspv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cspv_rec                     IN cspv_rec_type
  ) RETURN cspv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cspv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SLCTD_OPTNS_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cspv_rec	IN cspv_rec_type
  ) RETURN cspv_rec_type IS
    l_cspv_rec	cspv_rec_type := p_cspv_rec;
  BEGIN
    IF (l_cspv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.object_version_number := NULL;
    END IF;
    IF (l_cspv_rec.pov_id = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.pov_id := NULL;
    END IF;
    IF (l_cspv_rec.khr_id = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.khr_id := NULL;
    END IF;
    IF (l_cspv_rec.attribute_category = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute_category := NULL;
    END IF;
    IF (l_cspv_rec.attribute1 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute1 := NULL;
    END IF;
    IF (l_cspv_rec.attribute2 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute2 := NULL;
    END IF;
    IF (l_cspv_rec.attribute3 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute3 := NULL;
    END IF;
    IF (l_cspv_rec.attribute4 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute4 := NULL;
    END IF;
    IF (l_cspv_rec.attribute5 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute5 := NULL;
    END IF;
    IF (l_cspv_rec.attribute6 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute6 := NULL;
    END IF;
    IF (l_cspv_rec.attribute7 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute7 := NULL;
    END IF;
    IF (l_cspv_rec.attribute8 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute8 := NULL;
    END IF;
    IF (l_cspv_rec.attribute9 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute9 := NULL;
    END IF;
    IF (l_cspv_rec.attribute10 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute10 := NULL;
    END IF;
    IF (l_cspv_rec.attribute11 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute11 := NULL;
    END IF;
    IF (l_cspv_rec.attribute12 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute12 := NULL;
    END IF;
    IF (l_cspv_rec.attribute13 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute13 := NULL;
    END IF;
    IF (l_cspv_rec.attribute14 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute14 := NULL;
    END IF;
    IF (l_cspv_rec.attribute15 = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.attribute15 := NULL;
    END IF;
    IF (l_cspv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.created_by := NULL;
    END IF;
    IF (l_cspv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_cspv_rec.creation_date := NULL;
    END IF;
    IF (l_cspv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cspv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_cspv_rec.last_update_date := NULL;
    END IF;
    IF (l_cspv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_cspv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cspv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKL_SLCTD_OPTNS_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_cspv_rec IN  cspv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_cspv_rec.id = OKL_API.G_MISS_NUM OR
       p_cspv_rec.id IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF p_cspv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_cspv_rec.object_version_number IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    validate_khr_id(x_return_status => l_return_status,
                    p_cspv_rec      => p_cspv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_pov_id(x_return_status => l_return_status,
                    p_cspv_rec      => p_cspv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Record for:OKL_SLCTD_OPTNS_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_cspv_rec IN cspv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cspv_rec_type,
    p_to	OUT NOCOPY csp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pov_id := p_from.pov_id;
    p_to.khr_id := p_from.khr_id;
    p_to.object_version_number := p_from.object_version_number;
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
  PROCEDURE migrate (
    p_from	IN csp_rec_type,
    p_to	OUT NOCOPY cspv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pov_id := p_from.pov_id;
    p_to.khr_id := p_from.khr_id;
    p_to.object_version_number := p_from.object_version_number;
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
  ----------------------------------------
  -- validate_row for:OKL_SLCTD_OPTNS_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cspv_rec                     cspv_rec_type := p_cspv_rec;
    l_csp_rec                      csp_rec_type;
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
    l_return_status := Validate_Attributes(l_cspv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cspv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:CSPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cspv_tbl.COUNT > 0) THEN
      i := p_cspv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cspv_rec                     => p_cspv_tbl(i));
        EXIT WHEN (i = p_cspv_tbl.LAST);
        i := p_cspv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- insert_row for:OKL_SLCTD_OPTNS --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csp_rec                      IN csp_rec_type,
    x_csp_rec                      OUT NOCOPY csp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTNS_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_csp_rec                      csp_rec_type := p_csp_rec;
    l_def_csp_rec                  csp_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKL_SLCTD_OPTNS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_csp_rec IN  csp_rec_type,
      x_csp_rec OUT NOCOPY csp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_csp_rec := p_csp_rec;
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
      p_csp_rec,                         -- IN
      l_csp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SLCTD_OPTNS(
        id,
        pov_id,
        khr_id,
        object_version_number,
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
        l_csp_rec.id,
        l_csp_rec.pov_id,
        l_csp_rec.khr_id,
        l_csp_rec.object_version_number,
        l_csp_rec.attribute_category,
        l_csp_rec.attribute1,
        l_csp_rec.attribute2,
        l_csp_rec.attribute3,
        l_csp_rec.attribute4,
        l_csp_rec.attribute5,
        l_csp_rec.attribute6,
        l_csp_rec.attribute7,
        l_csp_rec.attribute8,
        l_csp_rec.attribute9,
        l_csp_rec.attribute10,
        l_csp_rec.attribute11,
        l_csp_rec.attribute12,
        l_csp_rec.attribute13,
        l_csp_rec.attribute14,
        l_csp_rec.attribute15,
        l_csp_rec.created_by,
        l_csp_rec.creation_date,
        l_csp_rec.last_updated_by,
        l_csp_rec.last_update_date,
        l_csp_rec.last_update_login);
    -- Set OUT values
    x_csp_rec := l_csp_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  --------------------------------------
  -- insert_row for:OKL_SLCTD_OPTNS_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cspv_rec                     cspv_rec_type;
    l_def_cspv_rec                 cspv_rec_type;
    l_csp_rec                      csp_rec_type;
    lx_csp_rec                     csp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cspv_rec	IN cspv_rec_type
    ) RETURN cspv_rec_type IS
      l_cspv_rec	cspv_rec_type := p_cspv_rec;
    BEGIN
      l_cspv_rec.CREATION_DATE := SYSDATE;
      l_cspv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cspv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cspv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cspv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cspv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKL_SLCTD_OPTNS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cspv_rec IN  cspv_rec_type,
      x_cspv_rec OUT NOCOPY cspv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cspv_rec := p_cspv_rec;
      x_cspv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cspv_rec := null_out_defaults(p_cspv_rec);
    -- Set primary key value
    l_cspv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cspv_rec,                        -- IN
      l_def_cspv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cspv_rec := fill_who_columns(l_def_cspv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cspv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cspv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cspv_rec, l_csp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_csp_rec,
      lx_csp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_csp_rec, l_def_cspv_rec);
    -- Set OUT values
    x_cspv_rec := l_def_cspv_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:CSPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cspv_tbl.COUNT > 0) THEN
      i := p_cspv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cspv_rec                     => p_cspv_tbl(i),
          x_cspv_rec                     => x_cspv_tbl(i));
        EXIT WHEN (i = p_cspv_tbl.LAST);
        i := p_cspv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ----------------------------------
  -- lock_row for:OKL_SLCTD_OPTNS --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csp_rec                      IN csp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_csp_rec IN csp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SLCTD_OPTNS
     WHERE ID = p_csp_rec.id
       AND OBJECT_VERSION_NUMBER = p_csp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_csp_rec IN csp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SLCTD_OPTNS
    WHERE ID = p_csp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTNS_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SLCTD_OPTNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SLCTD_OPTNS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
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
      OPEN lock_csr(p_csp_rec);
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
      OPEN lchk_csr(p_csp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_csp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_csp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------
  -- lock_row for:OKL_SLCTD_OPTNS_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_csp_rec                      csp_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_cspv_rec, l_csp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_csp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:CSPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cspv_tbl.COUNT > 0) THEN
      i := p_cspv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cspv_rec                     => p_cspv_tbl(i));
        EXIT WHEN (i = p_cspv_tbl.LAST);
        i := p_cspv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- update_row for:OKL_SLCTD_OPTNS --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csp_rec                      IN csp_rec_type,
    x_csp_rec                      OUT NOCOPY csp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTNS_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_csp_rec                      csp_rec_type := p_csp_rec;
    l_def_csp_rec                  csp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_csp_rec	IN csp_rec_type,
      x_csp_rec	OUT NOCOPY csp_rec_type
    ) RETURN VARCHAR2 IS
      l_csp_rec                      csp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_csp_rec := p_csp_rec;
      -- Get current database values
      l_csp_rec := get_rec(p_csp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_csp_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.id := l_csp_rec.id;
      END IF;
      IF (x_csp_rec.pov_id = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.pov_id := l_csp_rec.pov_id;
      END IF;
      IF (x_csp_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.khr_id := l_csp_rec.khr_id;
      END IF;
      IF (x_csp_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.object_version_number := l_csp_rec.object_version_number;
      END IF;
      IF (x_csp_rec.attribute_category = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute_category := l_csp_rec.attribute_category;
      END IF;
      IF (x_csp_rec.attribute1 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute1 := l_csp_rec.attribute1;
      END IF;
      IF (x_csp_rec.attribute2 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute2 := l_csp_rec.attribute2;
      END IF;
      IF (x_csp_rec.attribute3 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute3 := l_csp_rec.attribute3;
      END IF;
      IF (x_csp_rec.attribute4 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute4 := l_csp_rec.attribute4;
      END IF;
      IF (x_csp_rec.attribute5 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute5 := l_csp_rec.attribute5;
      END IF;
      IF (x_csp_rec.attribute6 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute6 := l_csp_rec.attribute6;
      END IF;
      IF (x_csp_rec.attribute7 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute7 := l_csp_rec.attribute7;
      END IF;
      IF (x_csp_rec.attribute8 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute8 := l_csp_rec.attribute8;
      END IF;
      IF (x_csp_rec.attribute9 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute9 := l_csp_rec.attribute9;
      END IF;
      IF (x_csp_rec.attribute10 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute10 := l_csp_rec.attribute10;
      END IF;
      IF (x_csp_rec.attribute11 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute11 := l_csp_rec.attribute11;
      END IF;
      IF (x_csp_rec.attribute12 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute12 := l_csp_rec.attribute12;
      END IF;
      IF (x_csp_rec.attribute13 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute13 := l_csp_rec.attribute13;
      END IF;
      IF (x_csp_rec.attribute14 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute14 := l_csp_rec.attribute14;
      END IF;
      IF (x_csp_rec.attribute15 = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.attribute15 := l_csp_rec.attribute15;
      END IF;
      IF (x_csp_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.created_by := l_csp_rec.created_by;
      END IF;
      IF (x_csp_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_csp_rec.creation_date := l_csp_rec.creation_date;
      END IF;
      IF (x_csp_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.last_updated_by := l_csp_rec.last_updated_by;
      END IF;
      IF (x_csp_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_csp_rec.last_update_date := l_csp_rec.last_update_date;
      END IF;
      IF (x_csp_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_csp_rec.last_update_login := l_csp_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_SLCTD_OPTNS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_csp_rec IN  csp_rec_type,
      x_csp_rec OUT NOCOPY csp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_csp_rec := p_csp_rec;
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
      p_csp_rec,                         -- IN
      l_csp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_csp_rec, l_def_csp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SLCTD_OPTNS
    SET POV_ID = l_def_csp_rec.pov_id,
        KHR_ID = l_def_csp_rec.khr_id,
        OBJECT_VERSION_NUMBER = l_def_csp_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_csp_rec.attribute_category,
        ATTRIBUTE1 = l_def_csp_rec.attribute1,
        ATTRIBUTE2 = l_def_csp_rec.attribute2,
        ATTRIBUTE3 = l_def_csp_rec.attribute3,
        ATTRIBUTE4 = l_def_csp_rec.attribute4,
        ATTRIBUTE5 = l_def_csp_rec.attribute5,
        ATTRIBUTE6 = l_def_csp_rec.attribute6,
        ATTRIBUTE7 = l_def_csp_rec.attribute7,
        ATTRIBUTE8 = l_def_csp_rec.attribute8,
        ATTRIBUTE9 = l_def_csp_rec.attribute9,
        ATTRIBUTE10 = l_def_csp_rec.attribute10,
        ATTRIBUTE11 = l_def_csp_rec.attribute11,
        ATTRIBUTE12 = l_def_csp_rec.attribute12,
        ATTRIBUTE13 = l_def_csp_rec.attribute13,
        ATTRIBUTE14 = l_def_csp_rec.attribute14,
        ATTRIBUTE15 = l_def_csp_rec.attribute15,
        CREATED_BY = l_def_csp_rec.created_by,
        CREATION_DATE = l_def_csp_rec.creation_date,
        LAST_UPDATED_BY = l_def_csp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_csp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_csp_rec.last_update_login
    WHERE ID = l_def_csp_rec.id;

    x_csp_rec := l_def_csp_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------
  -- update_row for:OKL_SLCTD_OPTNS_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cspv_rec                     cspv_rec_type := p_cspv_rec;
    l_def_cspv_rec                 cspv_rec_type;
    l_csp_rec                      csp_rec_type;
    lx_csp_rec                     csp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cspv_rec	IN cspv_rec_type
    ) RETURN cspv_rec_type IS
      l_cspv_rec	cspv_rec_type := p_cspv_rec;
    BEGIN
      l_cspv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cspv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cspv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cspv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cspv_rec	IN cspv_rec_type,
      x_cspv_rec	OUT NOCOPY cspv_rec_type
    ) RETURN VARCHAR2 IS
      l_cspv_rec                     cspv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cspv_rec := p_cspv_rec;
      -- Get current database values
      l_cspv_rec := get_rec(p_cspv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cspv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.id := l_cspv_rec.id;
      END IF;
      IF (x_cspv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.object_version_number := l_cspv_rec.object_version_number;
      END IF;
      IF (x_cspv_rec.pov_id = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.pov_id := l_cspv_rec.pov_id;
      END IF;
      IF (x_cspv_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.khr_id := l_cspv_rec.khr_id;
      END IF;
      IF (x_cspv_rec.attribute_category = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute_category := l_cspv_rec.attribute_category;
      END IF;
      IF (x_cspv_rec.attribute1 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute1 := l_cspv_rec.attribute1;
      END IF;
      IF (x_cspv_rec.attribute2 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute2 := l_cspv_rec.attribute2;
      END IF;
      IF (x_cspv_rec.attribute3 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute3 := l_cspv_rec.attribute3;
      END IF;
      IF (x_cspv_rec.attribute4 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute4 := l_cspv_rec.attribute4;
      END IF;
      IF (x_cspv_rec.attribute5 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute5 := l_cspv_rec.attribute5;
      END IF;
      IF (x_cspv_rec.attribute6 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute6 := l_cspv_rec.attribute6;
      END IF;
      IF (x_cspv_rec.attribute7 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute7 := l_cspv_rec.attribute7;
      END IF;
      IF (x_cspv_rec.attribute8 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute8 := l_cspv_rec.attribute8;
      END IF;
      IF (x_cspv_rec.attribute9 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute9 := l_cspv_rec.attribute9;
      END IF;
      IF (x_cspv_rec.attribute10 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute10 := l_cspv_rec.attribute10;
      END IF;
      IF (x_cspv_rec.attribute11 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute11 := l_cspv_rec.attribute11;
      END IF;
      IF (x_cspv_rec.attribute12 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute12 := l_cspv_rec.attribute12;
      END IF;
      IF (x_cspv_rec.attribute13 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute13 := l_cspv_rec.attribute13;
      END IF;
      IF (x_cspv_rec.attribute14 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute14 := l_cspv_rec.attribute14;
      END IF;
      IF (x_cspv_rec.attribute15 = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.attribute15 := l_cspv_rec.attribute15;
      END IF;
      IF (x_cspv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.created_by := l_cspv_rec.created_by;
      END IF;
      IF (x_cspv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_cspv_rec.creation_date := l_cspv_rec.creation_date;
      END IF;
      IF (x_cspv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.last_updated_by := l_cspv_rec.last_updated_by;
      END IF;
      IF (x_cspv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_cspv_rec.last_update_date := l_cspv_rec.last_update_date;
      END IF;
      IF (x_cspv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_cspv_rec.last_update_login := l_cspv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_SLCTD_OPTNS_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cspv_rec IN  cspv_rec_type,
      x_cspv_rec OUT NOCOPY cspv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cspv_rec := p_cspv_rec;
      x_cspv_rec.OBJECT_VERSION_NUMBER := NVL(x_cspv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cspv_rec,                        -- IN
      l_cspv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cspv_rec, l_def_cspv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cspv_rec := fill_who_columns(l_def_cspv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cspv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cspv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cspv_rec, l_csp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_csp_rec,
      lx_csp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_csp_rec, l_def_cspv_rec);
    x_cspv_rec := l_def_cspv_rec;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:CSPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cspv_tbl.COUNT > 0) THEN
      i := p_cspv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cspv_rec                     => p_cspv_tbl(i),
          x_cspv_rec                     => x_cspv_tbl(i));
        EXIT WHEN (i = p_cspv_tbl.LAST);
        i := p_cspv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- delete_row for:OKL_SLCTD_OPTNS --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_csp_rec                      IN csp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPTNS_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_csp_rec                      csp_rec_type:= p_csp_rec;
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
    DELETE FROM OKL_SLCTD_OPTNS
     WHERE ID = l_csp_rec.id;

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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------
  -- delete_row for:OKL_SLCTD_OPTNS_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cspv_rec                     cspv_rec_type := p_cspv_rec;
    l_csp_rec                      csp_rec_type;
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
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_cspv_rec, l_csp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_csp_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:CSPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cspv_tbl.COUNT > 0) THEN
      i := p_cspv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cspv_rec                     => p_cspv_tbl(i));
        EXIT WHEN (i = p_cspv_tbl.LAST);
        i := p_cspv_tbl.NEXT(i);
      END LOOP;
    END IF;
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_CSP_PVT;

/

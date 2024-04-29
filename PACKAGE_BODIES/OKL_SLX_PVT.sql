--------------------------------------------------------
--  DDL for Package Body OKL_SLX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SLX_PVT" AS
/* $Header: OKLSSLXB.pls 115.3 2002/12/18 13:08:57 kjinger noship $ */
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

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYPE_EXEMPT_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_slxv_rec                     IN slxv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN slxv_rec_type IS
    CURSOR okl_strm_type_exempt_v_pk_csr (p_id IN NUMBER) IS
    SELECT ID,
           LPO_ID,
            STY_ID,
            OBJECT_VERSION_NUMBER,
            LATE_POLICY_EXEMPT_YN,
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
      FROM Okl_Strm_Type_Exempt_V
     WHERE okl_strm_type_exempt_v.id = p_id;
    l_okl_strm_type_exempt_v_pk    okl_strm_type_exempt_v_pk_csr%ROWTYPE;
    l_slxv_rec                     slxv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_strm_type_exempt_v_pk_csr (p_slxv_rec.id);
    FETCH okl_strm_type_exempt_v_pk_csr INTO
              l_slxv_rec.id,
              l_slxv_rec.lpo_id,
              l_slxv_rec.sty_id,
              l_slxv_rec.object_version_number,
              l_slxv_rec.late_policy_exempt_yn,
              l_slxv_rec.attribute_category,
              l_slxv_rec.attribute1,
              l_slxv_rec.attribute2,
              l_slxv_rec.attribute3,
              l_slxv_rec.attribute4,
              l_slxv_rec.attribute5,
              l_slxv_rec.attribute6,
              l_slxv_rec.attribute7,
              l_slxv_rec.attribute8,
              l_slxv_rec.attribute9,
              l_slxv_rec.attribute10,
              l_slxv_rec.attribute11,
              l_slxv_rec.attribute12,
              l_slxv_rec.attribute13,
              l_slxv_rec.attribute14,
              l_slxv_rec.attribute15,
              l_slxv_rec.created_by,
              l_slxv_rec.creation_date,
              l_slxv_rec.last_updated_by,
              l_slxv_rec.last_update_date,
              l_slxv_rec.last_update_login;
    x_no_data_found := okl_strm_type_exempt_v_pk_csr%NOTFOUND;
    CLOSE okl_strm_type_exempt_v_pk_csr;
    RETURN(l_slxv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_slxv_rec                     IN slxv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN slxv_rec_type IS
    l_slxv_rec                     slxv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
 BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_slxv_rec := get_rec(p_slxv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_slxv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_slxv_rec                     IN slxv_rec_type
  ) RETURN slxv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_slxv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYPE_EXEMPT
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_slx_rec                      IN slx_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN slx_rec_type IS
    CURSOR okl_strm_type_exempt_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LPO_ID,
            STY_ID,
            OBJECT_VERSION_NUMBER,
            LATE_POLICY_EXEMPT_YN,
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
      FROM Okl_Strm_Type_Exempt
     WHERE okl_strm_type_exempt.id = p_id;
    l_okl_strm_type_exempt_pk      okl_strm_type_exempt_pk_csr%ROWTYPE;
    l_slx_rec                      slx_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_strm_type_exempt_pk_csr (p_slx_rec.id);
    FETCH okl_strm_type_exempt_pk_csr INTO
              l_slx_rec.id,
              l_slx_rec.lpo_id,
              l_slx_rec.sty_id,
              l_slx_rec.object_version_number,
              l_slx_rec.late_policy_exempt_yn,
              l_slx_rec.attribute_category,
              l_slx_rec.attribute1,
              l_slx_rec.attribute2,
              l_slx_rec.attribute3,
              l_slx_rec.attribute4,
              l_slx_rec.attribute5,
              l_slx_rec.attribute6,
              l_slx_rec.attribute7,
              l_slx_rec.attribute8,
              l_slx_rec.attribute9,
              l_slx_rec.attribute10,
              l_slx_rec.attribute11,
              l_slx_rec.attribute12,
              l_slx_rec.attribute13,
              l_slx_rec.attribute14,
              l_slx_rec.attribute15,
              l_slx_rec.created_by,
              l_slx_rec.creation_date,
              l_slx_rec.last_updated_by,
              l_slx_rec.last_update_date,
              l_slx_rec.last_update_login;
    x_no_data_found := okl_strm_type_exempt_pk_csr%NOTFOUND;
    CLOSE okl_strm_type_exempt_pk_csr;
    RETURN(l_slx_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_slx_rec                      IN slx_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN slx_rec_type IS
    l_slx_rec                      slx_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    l_slx_rec := get_rec(p_slx_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_slx_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_slx_rec                      IN slx_rec_type
  ) RETURN slx_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_slx_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STRM_TYPE_EXEMPT_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_slxv_rec   IN slxv_rec_type
  ) RETURN slxv_rec_type IS
    l_slxv_rec                     slxv_rec_type := p_slxv_rec;
  BEGIN
    IF (l_slxv_rec.id = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.id := NULL;
    END IF;
    IF (l_slxv_rec.lpo_id = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.lpo_id := NULL;
    END IF;
    IF (l_slxv_rec.sty_id = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.sty_id := NULL;
    END IF;
    IF (l_slxv_rec.object_version_number = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.object_version_number := NULL;
    END IF;
    IF (l_slxv_rec.late_policy_exempt_yn = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.late_policy_exempt_yn := NULL;
    END IF;
    IF (l_slxv_rec.attribute_category = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute_category := NULL;
    END IF;
    IF (l_slxv_rec.attribute1 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute1 := NULL;
    END IF;
    IF (l_slxv_rec.attribute2 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute2 := NULL;
    END IF;
    IF (l_slxv_rec.attribute3 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute3 := NULL;
    END IF;
    IF (l_slxv_rec.attribute4 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute4 := NULL;
    END IF;
    IF (l_slxv_rec.attribute5 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute5 := NULL;
    END IF;
    IF (l_slxv_rec.attribute6 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute6 := NULL;
    END IF;
    IF (l_slxv_rec.attribute7 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute7 := NULL;
    END IF;
    IF (l_slxv_rec.attribute8 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute8 := NULL;
    END IF;
    IF (l_slxv_rec.attribute9 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute9 := NULL;
    END IF;
    IF (l_slxv_rec.attribute10 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute10 := NULL;
    END IF;
    IF (l_slxv_rec.attribute11 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute11 := NULL;
    END IF;
    IF (l_slxv_rec.attribute12 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute12 := NULL;
    END IF;
    IF (l_slxv_rec.attribute13 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute13 := NULL;
    END IF;
    IF (l_slxv_rec.attribute14 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute14 := NULL;
    END IF;
    IF (l_slxv_rec.attribute15 = Okc_Api.G_MISS_CHAR ) THEN
      l_slxv_rec.attribute15 := NULL;
    END IF;
    IF (l_slxv_rec.created_by = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.created_by := NULL;
    END IF;
    IF (l_slxv_rec.creation_date = Okc_Api.G_MISS_DATE ) THEN
      l_slxv_rec.creation_date := NULL;
    END IF;
    IF (l_slxv_rec.last_updated_by = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.last_updated_by := NULL;
    END IF;
    IF (l_slxv_rec.last_update_date = Okc_Api.G_MISS_DATE ) THEN
      l_slxv_rec.last_update_date := NULL;
    END IF;
    IF (l_slxv_rec.last_update_login = Okc_Api.G_MISS_NUM ) THEN
      l_slxv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_slxv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKL_STRM_TYPE_EXEMPT_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_slxv_rec                     IN slxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    Okc_Util.ADD_VIEW('OKL_STRM_TYPE_EXEMPT_V', x_return_status);
    IF p_slxv_rec.id = Okl_Api.G_MISS_NUM OR
       p_slxv_rec.id IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_slxv_rec.lpo_id = Okl_Api.G_MISS_NUM OR
       p_slxv_rec.lpo_id IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lpo_id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_slxv_rec.sty_id = Okl_Api.G_MISS_NUM OR
       p_slxv_rec.sty_id IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_slxv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
       p_slxv_rec.object_version_number IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_slxv_rec.late_policy_exempt_yn = Okl_Api.G_MISS_CHAR OR
       p_slxv_rec.late_policy_exempt_yn IS NULL THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'late_policy_exempt_yn');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate Record for:OKL_STRM_TYPE_EXEMPT_V --
  ------------------------------------------------
  FUNCTION Validate_Record (p_slxv_rec IN slxv_rec_type)
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN slxv_rec_type,
    p_to   IN OUT NOCOPY slx_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.lpo_id := p_from.lpo_id;
    p_to.sty_id := p_from.sty_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_policy_exempt_yn := p_from.late_policy_exempt_yn;
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
    p_from IN slx_rec_type,
    p_to   IN OUT NOCOPY slxv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.lpo_id := p_from.lpo_id;
    p_to.sty_id := p_from.sty_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.late_policy_exempt_yn := p_from.late_policy_exempt_yn;
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
  ---------------------------------------------
  -- validate_row for:OKL_STRM_TYPE_EXEMPT_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slxv_rec                     slxv_rec_type := p_slxv_rec;
    l_slx_rec                      slx_rec_type;
    l_slx_rec                      slx_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_slxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_slxv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_STRM_TYPE_EXEMPT_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_slxv_tbl.COUNT > 0) THEN
      i := p_slxv_tbl.FIRST;
      LOOP
        validate_row (p_api_version    => p_api_version,
                      p_init_msg_list  => Okc_Api.G_FALSE,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_slxv_rec       => p_slxv_tbl(i));
        EXIT WHEN (i = p_slxv_tbl.LAST);
        i := p_slxv_tbl.NEXT(i);
      END LOOP;
    END IF;
     Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- insert_row for:OKL_STRM_TYPE_EXEMPT --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slx_rec                      IN slx_rec_type,
    x_slx_rec                      OUT NOCOPY slx_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slx_rec                      slx_rec_type := p_slx_rec;
    l_def_slx_rec                  slx_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_EXEMPT --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_slx_rec IN slx_rec_type,
      x_slx_rec OUT NOCOPY slx_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slx_rec := p_slx_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_slx_rec,                         -- IN
      l_slx_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_STRM_TYPE_EXEMPT(
      id,
      lpo_id,
      sty_id,
      object_version_number,
      late_policy_exempt_yn,
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
      l_slx_rec.id,
      l_slx_rec.lpo_id,
      l_slx_rec.sty_id,
      l_slx_rec.object_version_number,
      l_slx_rec.late_policy_exempt_yn,
      l_slx_rec.attribute_category,
      l_slx_rec.attribute1,
      l_slx_rec.attribute2,
      l_slx_rec.attribute3,
      l_slx_rec.attribute4,
      l_slx_rec.attribute5,
      l_slx_rec.attribute6,
      l_slx_rec.attribute7,
      l_slx_rec.attribute8,
      l_slx_rec.attribute9,
      l_slx_rec.attribute10,
      l_slx_rec.attribute11,
      l_slx_rec.attribute12,
      l_slx_rec.attribute13,
      l_slx_rec.attribute14,
      l_slx_rec.attribute15,
      l_slx_rec.created_by,
      l_slx_rec.creation_date,
      l_slx_rec.last_updated_by,
      l_slx_rec.last_update_date,
      l_slx_rec.last_update_login);
    -- Set OUT values
    x_slx_rec := l_slx_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  --------------------------------------------
  -- insert_row for :OKL_STRM_TYPE_EXEMPT_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type,
    x_slxv_rec                     OUT NOCOPY slxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slxv_rec                     slxv_rec_type := p_slxv_rec;
    l_def_slxv_rec                 slxv_rec_type;
    l_slx_rec                      slx_rec_type;
    lx_slx_rec                     slx_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_slxv_rec IN slxv_rec_type
    ) RETURN slxv_rec_type IS
      l_slxv_rec slxv_rec_type := p_slxv_rec;
    BEGIN
      l_slxv_rec.CREATION_DATE := SYSDATE;
      l_slxv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_slxv_rec.LAST_UPDATE_DATE := l_slxv_rec.CREATION_DATE;
      l_slxv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_slxv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_slxv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_EXEMPT_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_slxv_rec IN slxv_rec_type,
      x_slxv_rec OUT NOCOPY slxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slxv_rec := p_slxv_rec;
      x_slxv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_slxv_rec := null_out_defaults(p_slxv_rec);
    -- Set primary key value
    l_slxv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_slxv_rec,                        -- IN
      l_def_slxv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_slxv_rec := fill_who_columns(l_def_slxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_slxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_slxv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_slxv_rec, l_slx_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_slx_rec,
      lx_slx_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_slx_rec, l_def_slxv_rec);
    -- Set OUT values
    x_slxv_rec := l_def_slxv_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:SLXV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type,
    x_slxv_tbl                     OUT NOCOPY slxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_slxv_tbl.COUNT > 0) THEN
      i := p_slxv_tbl.FIRST;
      LOOP
        insert_row (
           p_api_version                  => p_api_version,
           p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_slxv_rec                     => p_slxv_tbl(i),
           x_slxv_rec                     => x_slxv_tbl(i));
        EXIT WHEN (i = p_slxv_tbl.LAST);
        i := p_slxv_tbl.NEXT(i);
      END LOOP;
   END IF;
   Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- lock_row for:OKL_STRM_TYPE_EXEMPT --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slx_rec                      IN slx_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_slx_rec IN slx_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYPE_EXEMPT
     WHERE ID = p_slx_rec.id
       AND OBJECT_VERSION_NUMBER = p_slx_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_slx_rec IN slx_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYPE_EXEMPT
     WHERE ID = p_slx_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_STRM_TYPE_EXEMPT.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_STRM_TYPE_EXEMPT.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_slx_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_slx_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_slx_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_slx_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------------
  -- lock_row for: OKL_STRM_TYPE_EXEMPT_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slx_rec                      slx_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_slxv_rec, l_slx_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_slx_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SLXV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_slxv_tbl.COUNT > 0) THEN
      i := p_slxv_tbl.FIRST;
      LOOP
         lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => Okc_Api.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
            p_slxv_rec                     => p_slxv_tbl(i));
        EXIT WHEN (i = p_slxv_tbl.LAST);
        i := p_slxv_tbl.NEXT(i);
      END LOOP;
    END IF;
   Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- update_row for:OKL_STRM_TYPE_EXEMPT --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slx_rec                      IN slx_rec_type,
    x_slx_rec                      OUT NOCOPY slx_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slx_rec                      slx_rec_type := p_slx_rec;
    l_def_slx_rec                  slx_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_slx_rec IN slx_rec_type,
      x_slx_rec OUT NOCOPY slx_rec_type
    ) RETURN VARCHAR2 IS
      l_slx_rec                      slx_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slx_rec := p_slx_rec;
      -- Get current database values
      l_slx_rec := get_rec(p_slx_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_slx_rec.id = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.id := l_slx_rec.id;
        END IF;
        IF (x_slx_rec.lpo_id = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.lpo_id := l_slx_rec.lpo_id;
        END IF;
        IF (x_slx_rec.sty_id = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.sty_id := l_slx_rec.sty_id;
        END IF;
        IF (x_slx_rec.object_version_number = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.object_version_number := l_slx_rec.object_version_number;
        END IF;
        IF (x_slx_rec.late_policy_exempt_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.late_policy_exempt_yn := l_slx_rec.late_policy_exempt_yn;
        END IF;
        IF (x_slx_rec.attribute_category = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute_category := l_slx_rec.attribute_category;
        END IF;
        IF (x_slx_rec.attribute1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute1 := l_slx_rec.attribute1;
        END IF;
        IF (x_slx_rec.attribute2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute2 := l_slx_rec.attribute2;
        END IF;
        IF (x_slx_rec.attribute3 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute3 := l_slx_rec.attribute3;
        END IF;
        IF (x_slx_rec.attribute4 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute4 := l_slx_rec.attribute4;
        END IF;
        IF (x_slx_rec.attribute5 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute5 := l_slx_rec.attribute5;
        END IF;
        IF (x_slx_rec.attribute6 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute6 := l_slx_rec.attribute6;
        END IF;
        IF (x_slx_rec.attribute7 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute7 := l_slx_rec.attribute7;
        END IF;
        IF (x_slx_rec.attribute8 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute8 := l_slx_rec.attribute8;
        END IF;
        IF (x_slx_rec.attribute9 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute9 := l_slx_rec.attribute9;
        END IF;
        IF (x_slx_rec.attribute10 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute10 := l_slx_rec.attribute10;
        END IF;
        IF (x_slx_rec.attribute11 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute11 := l_slx_rec.attribute11;
        END IF;
        IF (x_slx_rec.attribute12 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute12 := l_slx_rec.attribute12;
        END IF;
        IF (x_slx_rec.attribute13 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute13 := l_slx_rec.attribute13;
        END IF;
        IF (x_slx_rec.attribute14 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute14 := l_slx_rec.attribute14;
        END IF;
        IF (x_slx_rec.attribute15 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slx_rec.attribute15 := l_slx_rec.attribute15;
        END IF;
        IF (x_slx_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.created_by := l_slx_rec.created_by;
        END IF;
        IF (x_slx_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_slx_rec.creation_date := l_slx_rec.creation_date;
        END IF;
        IF (x_slx_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.last_updated_by := l_slx_rec.last_updated_by;
        END IF;
        IF (x_slx_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_slx_rec.last_update_date := l_slx_rec.last_update_date;
        END IF;
        IF (x_slx_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_slx_rec.last_update_login := l_slx_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_EXEMPT --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_slx_rec IN slx_rec_type,
      x_slx_rec OUT NOCOPY slx_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slx_rec := p_slx_rec;
      x_slx_rec.OBJECT_VERSION_NUMBER := p_slx_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_slx_rec,                         -- IN
      l_slx_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_slx_rec, l_def_slx_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_STRM_TYPE_EXEMPT
    SET LPO_ID = l_def_slx_rec.lpo_id,
        STY_ID = l_def_slx_rec.sty_id,
        OBJECT_VERSION_NUMBER = l_def_slx_rec.object_version_number,
        LATE_POLICY_EXEMPT_YN = l_def_slx_rec.late_policy_exempt_yn,
        ATTRIBUTE_CATEGORY = l_def_slx_rec.attribute_category,
        ATTRIBUTE1 = l_def_slx_rec.attribute1,
        ATTRIBUTE2 = l_def_slx_rec.attribute2,
        ATTRIBUTE3 = l_def_slx_rec.attribute3,
        ATTRIBUTE4 = l_def_slx_rec.attribute4,
        ATTRIBUTE5 = l_def_slx_rec.attribute5,
        ATTRIBUTE6 = l_def_slx_rec.attribute6,
        ATTRIBUTE7 = l_def_slx_rec.attribute7,
        ATTRIBUTE8 = l_def_slx_rec.attribute8,
        ATTRIBUTE9 = l_def_slx_rec.attribute9,
        ATTRIBUTE10 = l_def_slx_rec.attribute10,
        ATTRIBUTE11 = l_def_slx_rec.attribute11,
        ATTRIBUTE12 = l_def_slx_rec.attribute12,
        ATTRIBUTE13 = l_def_slx_rec.attribute13,
        ATTRIBUTE14 = l_def_slx_rec.attribute14,
        ATTRIBUTE15 = l_def_slx_rec.attribute15,
        CREATED_BY = l_def_slx_rec.created_by,
        CREATION_DATE = l_def_slx_rec.creation_date,
        LAST_UPDATED_BY = l_def_slx_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_slx_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_slx_rec.last_update_login
    WHERE ID = l_def_slx_rec.id;

    x_slx_rec := l_slx_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------------
  -- update_row for:OKL_STRM_TYPE_EXEMPT_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type,
    x_slxv_rec                     OUT NOCOPY slxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slxv_rec                     slxv_rec_type := p_slxv_rec;
    l_def_slxv_rec                 slxv_rec_type;
    l_db_slxv_rec                  slxv_rec_type;
    l_slx_rec                      slx_rec_type;
    lx_slx_rec                     slx_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_slxv_rec IN slxv_rec_type
    ) RETURN slxv_rec_type IS
      l_slxv_rec slxv_rec_type := p_slxv_rec;
    BEGIN
      l_slxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_slxv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_slxv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_slxv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_slxv_rec IN slxv_rec_type,
      x_slxv_rec OUT NOCOPY slxv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slxv_rec := p_slxv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_slxv_rec := get_rec(p_slxv_rec, l_return_status);
      IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_slxv_rec.id = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.id := l_db_slxv_rec.id;
        END IF;
        IF (x_slxv_rec.object_version_number = Okl_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.object_version_number := l_db_slxv_rec.object_version_number;
        END IF;
        IF (x_slxv_rec.lpo_id = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.lpo_id := l_db_slxv_rec.lpo_id;
        END IF;
        IF (x_slxv_rec.sty_id = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.sty_id := l_db_slxv_rec.sty_id;
        END IF;
        IF (x_slxv_rec.late_policy_exempt_yn = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.late_policy_exempt_yn := l_db_slxv_rec.late_policy_exempt_yn;
        END IF;
        IF (x_slxv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute_category := l_db_slxv_rec.attribute_category;
        END IF;
        IF (x_slxv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute1 := l_db_slxv_rec.attribute1;
        END IF;
        IF (x_slxv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute2 := l_db_slxv_rec.attribute2;
        END IF;
        IF (x_slxv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute3 := l_db_slxv_rec.attribute3;
        END IF;
        IF (x_slxv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute4 := l_db_slxv_rec.attribute4;
        END IF;
        IF (x_slxv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute5 := l_db_slxv_rec.attribute5;
        END IF;
        IF (x_slxv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute6 := l_db_slxv_rec.attribute6;
        END IF;
        IF (x_slxv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute7 := l_db_slxv_rec.attribute7;
        END IF;
        IF (x_slxv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute8 := l_db_slxv_rec.attribute8;
        END IF;
        IF (x_slxv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute9 := l_db_slxv_rec.attribute9;
        END IF;
        IF (x_slxv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute10 := l_db_slxv_rec.attribute10;
        END IF;
        IF (x_slxv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute11 := l_db_slxv_rec.attribute11;
        END IF;
        IF (x_slxv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute12 := l_db_slxv_rec.attribute12;
        END IF;
        IF (x_slxv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute13 := l_db_slxv_rec.attribute13;
        END IF;
        IF (x_slxv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute14 := l_db_slxv_rec.attribute14;
        END IF;
        IF (x_slxv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
        THEN
          x_slxv_rec.attribute15 := l_db_slxv_rec.attribute15;
        END IF;
        IF (x_slxv_rec.created_by = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.created_by := l_db_slxv_rec.created_by;
        END IF;
        IF (x_slxv_rec.creation_date = Okc_Api.G_MISS_DATE)
        THEN
          x_slxv_rec.creation_date := l_db_slxv_rec.creation_date;
        END IF;
        IF (x_slxv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.last_updated_by := l_db_slxv_rec.last_updated_by;
        END IF;
        IF (x_slxv_rec.last_update_date = Okc_Api.G_MISS_DATE)
        THEN
          x_slxv_rec.last_update_date := l_db_slxv_rec.last_update_date;
        END IF;
        IF (x_slxv_rec.last_update_login = Okc_Api.G_MISS_NUM)
        THEN
          x_slxv_rec.last_update_login := l_db_slxv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYPE_EXEMPT_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_slxv_rec IN slxv_rec_type,
      x_slxv_rec OUT NOCOPY slxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_slxv_rec := p_slxv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_slxv_rec,                        -- IN
      x_slxv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_slxv_rec, l_def_slxv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_slxv_rec := fill_who_columns(l_def_slxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_slxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_slxv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_slxv_rec, l_slx_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_slx_rec,
      lx_slx_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_slx_rec, l_def_slxv_rec);
    x_slxv_rec := l_def_slxv_rec;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:slxv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type,
    x_slxv_tbl                     OUT NOCOPY slxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_slxv_tbl.COUNT > 0) THEN
      i := p_slxv_tbl.FIRST;
      LOOP
         update_row (
           p_api_version                  => p_api_version,
           p_init_msg_list                => Okc_Api.G_FALSE,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_slxv_rec                     => p_slxv_tbl(i),
           x_slxv_rec                     => x_slxv_tbl(i));
        EXIT WHEN (i = p_slxv_tbl.LAST);
        i := p_slxv_tbl.NEXT(i);
      END LOOP;
    END IF;
   Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
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
  -----------------------------------------
  -- delete_row for:OKL_STRM_TYPE_EXEMPT --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slx_rec                      IN slx_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slx_rec                      slx_rec_type := p_slx_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_STRM_TYPE_EXEMPT
     WHERE ID = p_slx_rec.id;

    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------------
  -- delete_row for:OKL_STRM_TYPE_EXEMPT_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_rec                     IN slxv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_slxv_rec                     slxv_rec_type := p_slxv_rec;
    l_slx_rec                      slx_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_slxv_rec, l_slx_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_slx_rec
    );
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_STRM_TYPE_EXEMPT_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_slxv_tbl                     IN slxv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_slxv_tbl.COUNT > 0) THEN
      i := p_slxv_tbl.FIRST;
      LOOP
         delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => Okc_Api.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_slxv_rec                     => p_slxv_tbl(i));

        EXIT WHEN (i = p_slxv_tbl.LAST);
        i := p_slxv_tbl.NEXT(i);
      END LOOP;
    END IF;
   Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END Okl_Slx_Pvt;

/

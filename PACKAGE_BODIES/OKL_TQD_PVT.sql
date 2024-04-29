--------------------------------------------------------
--  DDL for Package Body OKL_TQD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TQD_PVT" AS
/* $Header: OKLSTQDB.pls 120.2 2006/07/11 10:33:22 dkagrawa noship $ */
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
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
  -- FUNCTION get_rec for: OKL_TXD_QUOTE_LINE_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_tqdv_rec       IN tqdv_rec_type,
                    x_no_data_found  OUT NOCOPY BOOLEAN)
    RETURN tqdv_rec_type IS

    CURSOR okl_tqdv_pk_csr (p_id IN NUMBER) IS
    SELECT  ID,
            OBJECT_VERSION_NUMBER,
            NUMBER_OF_UNITS,
            TQL_ID,
            KLE_ID,
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
            ATTRIBUTE15
      FROM OKL_TXD_QUOTE_LINE_DTLS
     WHERE OKL_TXD_QUOTE_LINE_DTLS.id = p_id;
    l_okl_tqdv_pk                  okl_tqdv_pk_csr%ROWTYPE;
    l_tqdv_rec                     tqdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tqdv_pk_csr (p_tqdv_rec.id);
    FETCH okl_tqdv_pk_csr INTO
              l_tqdv_rec.id,
              l_tqdv_rec.object_version_number,
              l_tqdv_rec.number_of_units,
              l_tqdv_rec.tql_id,
              l_tqdv_rec.kle_id,
              l_tqdv_rec.org_id,
              l_tqdv_rec.request_id,
              l_tqdv_rec.program_application_id,
              l_tqdv_rec.program_id,
              l_tqdv_rec.program_update_date,
              l_tqdv_rec.created_by,
              l_tqdv_rec.creation_date,
              l_tqdv_rec.last_updated_by,
              l_tqdv_rec.last_update_date,
              l_tqdv_rec.last_update_login,
              l_tqdv_rec.attribute_category,
              l_tqdv_rec.attribute1,
              l_tqdv_rec.attribute2,
              l_tqdv_rec.attribute3,
              l_tqdv_rec.attribute4,
              l_tqdv_rec.attribute5,
              l_tqdv_rec.attribute6,
              l_tqdv_rec.attribute7,
              l_tqdv_rec.attribute8,
              l_tqdv_rec.attribute9,
              l_tqdv_rec.attribute10,
              l_tqdv_rec.attribute11,
              l_tqdv_rec.attribute12,
              l_tqdv_rec.attribute13,
              l_tqdv_rec.attribute14,
              l_tqdv_rec.attribute15;
    x_no_data_found := okl_tqdv_pk_csr%NOTFOUND;
    CLOSE okl_tqdv_pk_csr;
    RETURN(l_tqdv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (p_tqdv_rec       IN tqdv_rec_type,
                    x_return_status  OUT NOCOPY VARCHAR2)
    RETURN tqdv_rec_type IS
    l_tqdv_rec                     tqdv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_tqdv_rec := get_rec(p_tqdv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tqdv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (p_tqdv_rec  IN tqdv_rec_type)
    RETURN tqdv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tqdv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_QUOTE_LINE_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_tqd_rec        IN tqd_rec_type,
                    x_no_data_found  OUT NOCOPY BOOLEAN)
    RETURN tqd_rec_type IS
    CURSOR okl_txd_quote_line_dtls_pk_csr (p_id IN NUMBER) IS
    SELECT  ID,
            OBJECT_VERSION_NUMBER,
            NUMBER_OF_UNITS,
            KLE_ID,
            TQL_ID,
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
            ATTRIBUTE15
      FROM Okl_Txd_Quote_Line_Dtls
     WHERE okl_txd_quote_line_dtls.id = p_id;
    l_okl_txd_quote_line_dtls_pk   okl_txd_quote_line_dtls_pk_csr%ROWTYPE;
    l_tqd_rec                      tqd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txd_quote_line_dtls_pk_csr (p_tqd_rec.id);
    FETCH okl_txd_quote_line_dtls_pk_csr INTO
              l_tqd_rec.id,
              l_tqd_rec.object_version_number,
              l_tqd_rec.number_of_units,
              l_tqd_rec.kle_id,
              l_tqd_rec.tql_id,
              l_tqd_rec.org_id,
              l_tqd_rec.request_id,
              l_tqd_rec.program_application_id,
              l_tqd_rec.program_id,
              l_tqd_rec.program_update_date,
              l_tqd_rec.created_by,
              l_tqd_rec.creation_date,
              l_tqd_rec.last_updated_by,
              l_tqd_rec.last_update_date,
              l_tqd_rec.last_update_login,
              l_tqd_rec.attribute_category,
              l_tqd_rec.attribute1,
              l_tqd_rec.attribute2,
              l_tqd_rec.attribute3,
              l_tqd_rec.attribute4,
              l_tqd_rec.attribute5,
              l_tqd_rec.attribute6,
              l_tqd_rec.attribute7,
              l_tqd_rec.attribute8,
              l_tqd_rec.attribute9,
              l_tqd_rec.attribute10,
              l_tqd_rec.attribute11,
              l_tqd_rec.attribute12,
              l_tqd_rec.attribute13,
              l_tqd_rec.attribute14,
              l_tqd_rec.attribute15;
    x_no_data_found := okl_txd_quote_line_dtls_pk_csr%NOTFOUND;
    CLOSE okl_txd_quote_line_dtls_pk_csr;
    RETURN(l_tqd_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (p_tqd_rec        IN tqd_rec_type,
                    x_return_status  OUT NOCOPY VARCHAR2)
    RETURN tqd_rec_type IS
    l_tqd_rec                      tqd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_tqd_rec := get_rec(p_tqd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tqd_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (p_tqd_rec  IN tqd_rec_type)
    RETURN tqd_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tqd_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXD_QUOTE_LINE_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (p_tqdv_rec   IN tqdv_rec_type)
    RETURN tqdv_rec_type IS
    l_tqdv_rec                     tqdv_rec_type := p_tqdv_rec;
  BEGIN
    IF (l_tqdv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.id := NULL;
    END IF;
    IF (l_tqdv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.object_version_number := NULL;
    END IF;
    IF (l_tqdv_rec.number_of_units = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.number_of_units := NULL;
    END IF;
    IF (l_tqdv_rec.tql_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.tql_id := NULL;
    END IF;
    IF (l_tqdv_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.kle_id := NULL;
    END IF;
    IF (l_tqdv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.org_id := NULL;
    END IF;
    IF (l_tqdv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.request_id := NULL;
    END IF;
    IF (l_tqdv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.program_application_id := NULL;
    END IF;
    IF (l_tqdv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.program_id := NULL;
    END IF;
    IF (l_tqdv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_tqdv_rec.program_update_date := NULL;
    END IF;
    IF (l_tqdv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.created_by := NULL;
    END IF;
    IF (l_tqdv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_tqdv_rec.creation_date := NULL;
    END IF;
    IF (l_tqdv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tqdv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_tqdv_rec.last_update_date := NULL;
    END IF;
    IF (l_tqdv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_tqdv_rec.last_update_login := NULL;
    END IF;
    IF (l_tqdv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute_category := NULL;
    END IF;
    IF (l_tqdv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute1 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute2 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute3 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute4 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute5 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute6 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute7 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute8 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute9 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute10 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute11 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute12 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute13 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute14 := NULL;
    END IF;
    IF (l_tqdv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_tqdv_rec.attribute15 := NULL;
    END IF;
    RETURN(l_tqdv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(x_return_status  OUT NOCOPY VARCHAR2,
                        p_id             IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL) THEN
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
  ---------------------------------
  -- Validate_Attributes for: ORG_ID --
  ---------------------------------
 -- Start of comments
  --
  -- Procedure Name  : validate_org_id
  -- Description     : To check for valid Org Id
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_org_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_org_id IN NUMBER) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_org_id IS NOT NULL OR
       p_org_id <> OKC_API.G_MISS_NUM) THEN
      x_return_status := OKL_UTIL.check_org_id(p_org_id => p_org_id);
      IF (x_return_status <>  OKC_API.G_RET_STS_SUCCESS) THEN
        OKC_API.SET_MESSAGE(p_app_name	     => G_APP_NAME,
                            p_msg_name	     => G_INVALID_VALUE,
                            p_token1	     => G_COL_NAME_TOKEN,
                            p_token1_value  => 'org_id');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_org_id;
  -------------------------------------
  -- Validate_Attributes for: TQL_ID --
  -------------------------------------
 -- Start of comments
  --
  -- Procedure Name  : validate_tql_id
  -- Description     : Foreign Key validation for Okl_Txl_Quote_Lines_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_tql_id(x_return_status  OUT NOCOPY VARCHAR2,
                            p_tql_id         IN NUMBER) IS
    ln_dummy            NUMBER := 0;

    CURSOR okl_tqlv_pk_csr (p_tql_id IN NUMBER) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT 'x'
    FROM Okl_Txl_Quote_Lines_V
    WHERE okl_txl_quote_lines_v.id = p_tql_id);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tql_id = OKC_API.G_MISS_NUM OR
        p_tql_id IS NULL) THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TQL_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN  okl_tqlv_pk_csr(p_tql_id => p_tql_id);
    FETCH okl_tqlv_pk_csr INTO ln_dummy;
    IF okl_tqlv_pk_csr%NOTFOUND THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TQL_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    CLOSE okl_tqlv_pk_csr;
    IF ln_dummy = 0 THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TQL_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
      null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF okl_tqlv_pk_csr%ISOPEN THEN
        CLOSE okl_tqlv_pk_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      IF okl_tqlv_pk_csr%ISOPEN THEN
        CLOSE okl_tqlv_pk_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tql_id;

  -------------------------------------
  -- Validate_Attributes for: KLE_ID --
  -------------------------------------
 -- Start of comments
  --
  -- Procedure Name  : validate_kle_id
  -- Description     : Foreign Key validation for Okl_k_lines_v
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_kle_id(x_return_status  OUT NOCOPY VARCHAR2,
                            p_kle_id         IN NUMBER) IS
    ln_dummy            NUMBER := 0;

    CURSOR okl_klev_pk_csr (p_kle_id IN NUMBER) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT 'x'
    FROM Okl_k_lines_V kle
    WHERE kle.id = p_kle_id);

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_kle_id = OKC_API.G_MISS_NUM OR
        p_kle_id IS NULL) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN  okl_klev_pk_csr(p_kle_id => p_kle_id);
    FETCH okl_klev_pk_csr INTO ln_dummy;
    IF okl_klev_pk_csr%NOTFOUND THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KLE_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    CLOSE okl_klev_pk_csr;
    IF ln_dummy = 0 THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KLE_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
      null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF okl_klev_pk_csr%ISOPEN THEN
        CLOSE okl_klev_pk_csr;
      END IF;
      null;
    WHEN OTHERS THEN
      IF okl_klev_pk_csr%ISOPEN THEN
        CLOSE okl_klev_pk_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_kle_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_TXD_QUOTE_LINE_DTLS_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tqdv_rec                     IN tqdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    validate_id(x_return_status, p_tqdv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_tql_id(x_return_status, p_tqdv_rec.tql_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_org_id(x_return_status, p_tqdv_rec.org_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_kle_id(x_return_status, p_tqdv_rec.kle_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS OR
       x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
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
  ---------------------------------------------------
  -- Validate Record for:OKL_TXD_QUOTE_LINE_DTLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (p_tqdv_rec     IN tqdv_rec_type,
                            p_db_tqdv_rec  IN tqdv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_tqdv_rec IN tqdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_tqdv_rec                  tqdv_rec_type := get_rec(p_tqdv_rec);
  BEGIN
    l_return_status := Validate_Record(p_tqdv_rec => p_tqdv_rec,
                                       p_db_tqdv_rec => l_db_tqdv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (p_from IN tqdv_rec_type,
                    p_to   IN OUT NOCOPY tqd_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.number_of_units := p_from.number_of_units;
    p_to.kle_id := p_from.kle_id;
    p_to.tql_id := p_from.tql_id;
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
  END migrate;
  PROCEDURE migrate (p_from IN tqd_rec_type,
                    p_to   IN OUT NOCOPY tqdv_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.number_of_units := p_from.number_of_units;
    p_to.tql_id := p_from.tql_id;
    p_to.kle_id := p_from.kle_id;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:OKL_TXD_QUOTE_LINE_DTLS_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_rec                     IN tqdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_tqdv_rec                     tqdv_rec_type := p_tqdv_rec;
    l_tqd_rec                      tqd_rec_type;
    l_tqd_rec                      tqd_rec_type;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Attributes(l_tqdv_rec);
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := Validate_Record(l_tqdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END validate_row;
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TXD_QUOTE_LINE_DTLS_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_tbl                     IN tqdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tqdv_tbl.COUNT > 0) THEN
      i := p_tqdv_tbl.FIRST;
      LOOP
        validate_row (p_api_version    => p_api_version,
                      p_init_msg_list  => OKC_API.G_FALSE,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_tqdv_rec       => p_tqdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_tqdv_tbl.LAST);
        i := p_tqdv_tbl.NEXT(i);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END validate_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- insert_row for:OKL_TXD_QUOTE_LINE_DTLS --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqd_rec                      IN tqd_rec_type,
    x_tqd_rec                      OUT NOCOPY tqd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_tqd_rec                      tqd_rec_type := p_tqd_rec;
    l_def_tqd_rec                  tqd_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QUOTE_LINE_DTLS --
    ------------------------------------------------
    FUNCTION Set_Attributes (p_tqd_rec IN tqd_rec_type,
                             x_tqd_rec OUT NOCOPY tqd_rec_type) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqd_rec := p_tqd_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    x_return_status := Set_Attributes(
      p_tqd_rec,                         -- IN
      l_tqd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXD_QUOTE_LINE_DTLS(
      id,
      object_version_number,
      number_of_units,
      kle_id,
      tql_id,
      org_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
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
      attribute15)
    VALUES (
      l_tqd_rec.id,
      l_tqd_rec.object_version_number,
      l_tqd_rec.number_of_units,
      l_tqd_rec.kle_id,
      l_tqd_rec.tql_id,
      l_tqd_rec.org_id,
      decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, FND_GLOBAL.CONC_REQUEST_ID),
      decode(FND_GLOBAL.PROG_APPL_ID, -1, NULL, FND_GLOBAL.PROG_APPL_ID),
      decode(FND_GLOBAL.CONC_PROGRAM_ID, -1, NULL, FND_GLOBAL.CONC_PROGRAM_ID),
      decode(FND_GLOBAL.CONC_REQUEST_ID, -1, NULL, SYSDATE),
      l_tqd_rec.created_by,
      l_tqd_rec.creation_date,
      l_tqd_rec.last_updated_by,
      l_tqd_rec.last_update_date,
      l_tqd_rec.last_update_login,
      l_tqd_rec.attribute_category,
      l_tqd_rec.attribute1,
      l_tqd_rec.attribute2,
      l_tqd_rec.attribute3,
      l_tqd_rec.attribute4,
      l_tqd_rec.attribute5,
      l_tqd_rec.attribute6,
      l_tqd_rec.attribute7,
      l_tqd_rec.attribute8,
      l_tqd_rec.attribute9,
      l_tqd_rec.attribute10,
      l_tqd_rec.attribute11,
      l_tqd_rec.attribute12,
      l_tqd_rec.attribute13,
      l_tqd_rec.attribute14,
      l_tqd_rec.attribute15);
    -- Set OUT values
    x_tqd_rec := l_tqd_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END insert_row;
  -----------------------------------------------
  -- insert_row for :OKL_TXD_QUOTE_LINE_DTLS_V --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_rec                     IN tqdv_rec_type,
    x_tqdv_rec                     OUT NOCOPY tqdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_tqdv_rec                     tqdv_rec_type := p_tqdv_rec;
    l_def_tqdv_rec                 tqdv_rec_type;
    l_tqd_rec                      tqd_rec_type;
    lx_tqd_rec                     tqd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tqdv_rec IN tqdv_rec_type
    ) RETURN tqdv_rec_type IS
      l_tqdv_rec tqdv_rec_type := p_tqdv_rec;
    BEGIN
      l_tqdv_rec.CREATION_DATE := SYSDATE;
      l_tqdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tqdv_rec.LAST_UPDATE_DATE := l_tqdv_rec.CREATION_DATE;
      l_tqdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tqdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tqdv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QUOTE_LINE_DTLS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_tqdv_rec IN tqdv_rec_type,
      x_tqdv_rec OUT NOCOPY tqdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqdv_rec := p_tqdv_rec;
      x_tqdv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tqdv_rec := null_out_defaults(p_tqdv_rec);
    -- Set primary key value
    l_tqdv_rec.ID := get_seq_id;
    -- Setting item attributes
    x_return_Status := Set_Attributes(
      l_tqdv_rec,                        -- IN
      l_def_tqdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tqdv_rec := fill_who_columns(l_def_tqdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Attributes(l_def_tqdv_rec);
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := Validate_Record(l_def_tqdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_tqdv_rec, l_tqd_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tqd_rec,
      lx_tqd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tqd_rec, l_def_tqdv_rec);
    -- Set OUT values
    x_tqdv_rec := l_def_tqdv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:TQDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_tbl                     IN tqdv_tbl_type,
    x_tqdv_tbl                     OUT NOCOPY tqdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tqdv_tbl.COUNT > 0) THEN
      i := p_tqdv_tbl.FIRST;
      LOOP
        insert_row (p_api_version    => p_api_version,
                    p_init_msg_list  => OKC_API.G_FALSE,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_tqdv_rec       => p_tqdv_tbl(i),
                    x_tqdv_rec       => x_tqdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_tqdv_tbl.LAST);
        i := p_tqdv_tbl.NEXT(i);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END insert_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- lock_row for:OKL_TXD_QUOTE_LINE_DTLS --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqd_rec                      IN tqd_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tqd_rec IN tqd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_QUOTE_LINE_DTLS
     WHERE ID = p_tqd_rec.id
       AND OBJECT_VERSION_NUMBER = p_tqd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_tqd_rec IN tqd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_QUOTE_LINE_DTLS
     WHERE ID = p_tqd_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_object_version_number        OKL_TXD_QUOTE_LINE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TXD_QUOTE_LINE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tqd_rec);
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
      OPEN lchk_csr(p_tqd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tqd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tqd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END lock_row;
  ---------------------------------------------
  -- lock_row for: OKL_TXD_QUOTE_LINE_DTLS_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_rec                     IN tqdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_tqd_rec                      tqd_rec_type;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_tqdv_rec, l_tqd_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tqd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:TQDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_tbl                     IN tqdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_tqdv_tbl.COUNT > 0) THEN
      i := p_tqdv_tbl.FIRST;
      LOOP
        lock_row(p_api_version    => p_api_version,
                 p_init_msg_list  => OKC_API.G_FALSE,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_tqdv_rec       => p_tqdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_tqdv_tbl.LAST);
        i := p_tqdv_tbl.NEXT(i);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- update_row for:OKL_TXD_QUOTE_LINE_DTLS --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqd_rec                      IN tqd_rec_type,
    x_tqd_rec                      OUT NOCOPY tqd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_tqd_rec                      tqd_rec_type := p_tqd_rec;
    l_def_tqd_rec                  tqd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tqd_rec IN tqd_rec_type,
      x_tqd_rec OUT NOCOPY tqd_rec_type
    ) RETURN VARCHAR2 IS
      l_tqd_rec                      tqd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqd_rec := p_tqd_rec;
      -- Get current database values
      l_tqd_rec := get_rec(p_tqd_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_tqd_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.id := l_tqd_rec.id;
        END IF;
        IF (x_tqd_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.object_version_number := l_tqd_rec.object_version_number;
        END IF;
        IF (x_tqd_rec.number_of_units = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.number_of_units := l_tqd_rec.number_of_units;
        END IF;
        IF (x_tqd_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.kle_id := l_tqd_rec.kle_id;
        END IF;
        IF (x_tqd_rec.tql_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.tql_id := l_tqd_rec.tql_id;
        END IF;
        IF (x_tqd_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.org_id := l_tqd_rec.org_id;
        END IF;
        IF (x_tqd_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.request_id := l_tqd_rec.request_id;
        END IF;
        IF (x_tqd_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.program_application_id := l_tqd_rec.program_application_id;
        END IF;
        IF (x_tqd_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.program_id := l_tqd_rec.program_id;
        END IF;
        IF (x_tqd_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqd_rec.program_update_date := l_tqd_rec.program_update_date;
        END IF;
        IF (x_tqd_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.created_by := l_tqd_rec.created_by;
        END IF;
        IF (x_tqd_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqd_rec.creation_date := l_tqd_rec.creation_date;
        END IF;
        IF (x_tqd_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.last_updated_by := l_tqd_rec.last_updated_by;
        END IF;
        IF (x_tqd_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqd_rec.last_update_date := l_tqd_rec.last_update_date;
        END IF;
        IF (x_tqd_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_tqd_rec.last_update_login := l_tqd_rec.last_update_login;
        END IF;
        IF (x_tqd_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute_category := l_tqd_rec.attribute_category;
        END IF;
        IF (x_tqd_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute1 := l_tqd_rec.attribute1;
        END IF;
        IF (x_tqd_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute2 := l_tqd_rec.attribute2;
        END IF;
        IF (x_tqd_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute3 := l_tqd_rec.attribute3;
        END IF;
        IF (x_tqd_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute4 := l_tqd_rec.attribute4;
        END IF;
        IF (x_tqd_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute5 := l_tqd_rec.attribute5;
        END IF;
        IF (x_tqd_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute6 := l_tqd_rec.attribute6;
        END IF;
        IF (x_tqd_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute7 := l_tqd_rec.attribute7;
        END IF;
        IF (x_tqd_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute8 := l_tqd_rec.attribute8;
        END IF;
        IF (x_tqd_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute9 := l_tqd_rec.attribute9;
        END IF;
        IF (x_tqd_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute10 := l_tqd_rec.attribute10;
        END IF;
        IF (x_tqd_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute11 := l_tqd_rec.attribute11;
        END IF;
        IF (x_tqd_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute12 := l_tqd_rec.attribute12;
        END IF;
        IF (x_tqd_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute13 := l_tqd_rec.attribute13;
        END IF;
        IF (x_tqd_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute14 := l_tqd_rec.attribute14;
        END IF;
        IF (x_tqd_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqd_rec.attribute15 := l_tqd_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QUOTE_LINE_DTLS --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_tqd_rec IN tqd_rec_type,
      x_tqd_rec OUT NOCOPY tqd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqd_rec := p_tqd_rec;
      x_tqd_rec.OBJECT_VERSION_NUMBER := p_tqd_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    x_return_status := Set_Attributes(
      p_tqd_rec,                         -- IN
      l_tqd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := populate_new_record(l_tqd_rec, l_def_tqd_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TXD_QUOTE_LINE_DTLS
    SET OBJECT_VERSION_NUMBER = l_def_tqd_rec.object_version_number,
        NUMBER_OF_UNITS = l_def_tqd_rec.number_of_units,
        KLE_ID = l_def_tqd_rec.kle_id,
        TQL_ID = l_def_tqd_rec.tql_id,
        ORG_ID = l_def_tqd_rec.org_id,
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1, NULL,
                 FND_GLOBAL.CONC_REQUEST_ID),l_def_tqd_rec.request_id),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,
                 FND_GLOBAL.PROG_APPL_ID),l_def_tqd_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,
                 FND_GLOBAL.CONC_PROGRAM_ID),l_def_tqd_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,
                 SYSDATE),NULL,l_def_tqd_rec.program_update_date,SYSDATE),
        CREATED_BY = l_def_tqd_rec.created_by,
        CREATION_DATE = l_def_tqd_rec.creation_date,
        LAST_UPDATED_BY = l_def_tqd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tqd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tqd_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_tqd_rec.attribute_category,
        ATTRIBUTE1 = l_def_tqd_rec.attribute1,
        ATTRIBUTE2 = l_def_tqd_rec.attribute2,
        ATTRIBUTE3 = l_def_tqd_rec.attribute3,
        ATTRIBUTE4 = l_def_tqd_rec.attribute4,
        ATTRIBUTE5 = l_def_tqd_rec.attribute5,
        ATTRIBUTE6 = l_def_tqd_rec.attribute6,
        ATTRIBUTE7 = l_def_tqd_rec.attribute7,
        ATTRIBUTE8 = l_def_tqd_rec.attribute8,
        ATTRIBUTE9 = l_def_tqd_rec.attribute9,
        ATTRIBUTE10 = l_def_tqd_rec.attribute10,
        ATTRIBUTE11 = l_def_tqd_rec.attribute11,
        ATTRIBUTE12 = l_def_tqd_rec.attribute12,
        ATTRIBUTE13 = l_def_tqd_rec.attribute13,
        ATTRIBUTE14 = l_def_tqd_rec.attribute14,
        ATTRIBUTE15 = l_def_tqd_rec.attribute15
    WHERE ID = l_def_tqd_rec.id;
    x_tqd_rec := l_tqd_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END update_row;
  ----------------------------------------------
  -- update_row for:OKL_TXD_QUOTE_LINE_DTLS_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_rec                     IN tqdv_rec_type,
    x_tqdv_rec                     OUT NOCOPY tqdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_tqdv_rec                     tqdv_rec_type := p_tqdv_rec;
    l_def_tqdv_rec                 tqdv_rec_type;
    l_db_tqdv_rec                  tqdv_rec_type;
    l_tqd_rec                      tqd_rec_type;
    lx_tqd_rec                     tqd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tqdv_rec IN tqdv_rec_type
    ) RETURN tqdv_rec_type IS
      l_tqdv_rec tqdv_rec_type := p_tqdv_rec;
    BEGIN
      l_tqdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tqdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tqdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tqdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tqdv_rec IN tqdv_rec_type,
      x_tqdv_rec OUT NOCOPY tqdv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqdv_rec := p_tqdv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_tqdv_rec := get_rec(p_tqdv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_tqdv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.id := l_db_tqdv_rec.id;
        END IF;
        IF (x_tqdv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.object_version_number := l_db_tqdv_rec.object_version_number;
        END IF;
        IF (x_tqdv_rec.number_of_units = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.number_of_units := l_db_tqdv_rec.number_of_units;
        END IF;
        IF (x_tqdv_rec.tql_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.tql_id := l_db_tqdv_rec.tql_id;
        END IF;
        IF (x_tqdv_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.kle_id := l_db_tqdv_rec.kle_id;
        END IF;
        IF (x_tqdv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.org_id := l_db_tqdv_rec.org_id;
        END IF;
        IF (x_tqdv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.request_id := l_db_tqdv_rec.request_id;
        END IF;
        IF (x_tqdv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.program_application_id := l_db_tqdv_rec.program_application_id;
        END IF;
        IF (x_tqdv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.program_id := l_db_tqdv_rec.program_id;
        END IF;
        IF (x_tqdv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqdv_rec.program_update_date := l_db_tqdv_rec.program_update_date;
        END IF;
        IF (x_tqdv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.created_by := l_db_tqdv_rec.created_by;
        END IF;
        IF (x_tqdv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqdv_rec.creation_date := l_db_tqdv_rec.creation_date;
        END IF;
        IF (x_tqdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.last_updated_by := l_db_tqdv_rec.last_updated_by;
        END IF;
        IF (x_tqdv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tqdv_rec.last_update_date := l_db_tqdv_rec.last_update_date;
        END IF;
        IF (x_tqdv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_tqdv_rec.last_update_login := l_db_tqdv_rec.last_update_login;
        END IF;
        IF (x_tqdv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute_category := l_db_tqdv_rec.attribute_category;
        END IF;
        IF (x_tqdv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute1 := l_db_tqdv_rec.attribute1;
        END IF;
        IF (x_tqdv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute2 := l_db_tqdv_rec.attribute2;
        END IF;
        IF (x_tqdv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute3 := l_db_tqdv_rec.attribute3;
        END IF;
        IF (x_tqdv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute4 := l_db_tqdv_rec.attribute4;
        END IF;
        IF (x_tqdv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute5 := l_db_tqdv_rec.attribute5;
        END IF;
        IF (x_tqdv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute6 := l_db_tqdv_rec.attribute6;
        END IF;
        IF (x_tqdv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute7 := l_db_tqdv_rec.attribute7;
        END IF;
        IF (x_tqdv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute8 := l_db_tqdv_rec.attribute8;
        END IF;
        IF (x_tqdv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute9 := l_db_tqdv_rec.attribute9;
        END IF;
        IF (x_tqdv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute10 := l_db_tqdv_rec.attribute10;
        END IF;
        IF (x_tqdv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute11 := l_db_tqdv_rec.attribute11;
        END IF;
        IF (x_tqdv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute12 := l_db_tqdv_rec.attribute12;
        END IF;
        IF (x_tqdv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute13 := l_db_tqdv_rec.attribute13;
        END IF;
        IF (x_tqdv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute14 := l_db_tqdv_rec.attribute14;
        END IF;
        IF (x_tqdv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_tqdv_rec.attribute15 := l_db_tqdv_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_TXD_QUOTE_LINE_DTLS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_tqdv_rec IN tqdv_rec_type,
      x_tqdv_rec OUT NOCOPY tqdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tqdv_rec := p_tqdv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    x_return_status := Set_Attributes(
      p_tqdv_rec,                        -- IN
      x_tqdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := populate_new_record(l_tqdv_rec, l_def_tqdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tqdv_rec := fill_who_columns(l_def_tqdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Attributes(l_def_tqdv_rec);
    --- If any errors happen abort API
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := Validate_Record(l_def_tqdv_rec, l_db_tqdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_tqdv_rec                     => l_def_tqdv_rec);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_tqdv_rec, l_tqd_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tqd_rec,
      lx_tqd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tqd_rec, l_def_tqdv_rec);
    x_tqdv_rec := l_def_tqdv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:tqdv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_tbl                     IN tqdv_tbl_type,
    x_tqdv_tbl                     OUT NOCOPY tqdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tqdv_tbl.COUNT > 0) THEN
      i := p_tqdv_tbl.FIRST;
      LOOP
        update_row (p_api_version    => p_api_version,
                    p_init_msg_list  => OKC_API.G_FALSE,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_tqdv_rec       => p_tqdv_tbl(i),
                    x_tqdv_rec       => x_tqdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_tqdv_tbl.LAST);
        i := p_tqdv_tbl.NEXT(i);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END update_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- delete_row for:OKL_TXD_QUOTE_LINE_DTLS --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqd_rec                      IN tqd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_tqd_rec                      tqd_rec_type := p_tqd_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_TXD_QUOTE_LINE_DTLS
    WHERE ID = p_tqd_rec.id;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END delete_row;
  ----------------------------------------------
  -- delete_row for:OKL_TXD_QUOTE_LINE_DTLS_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_rec                     IN tqdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_tqdv_rec                     tqdv_rec_type := p_tqdv_rec;
    l_tqd_rec                      tqd_rec_type;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_tqdv_rec, l_tqd_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tqd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END delete_row;
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TXD_QUOTE_LINE_DTLS_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqdv_tbl                     IN tqdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tqdv_tbl.COUNT > 0) THEN
      i := p_tqdv_tbl.FIRST;
      LOOP
        delete_row (
            p_api_version                  => p_api_version,
                 p_init_msg_list  => OKC_API.G_FALSE,
                 x_return_status  => x_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_tqdv_rec       => p_tqdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_tqdv_tbl.LAST);
        i := p_tqdv_tbl.NEXT(i);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OTHERS',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
  END delete_row;
END OKL_TQD_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKC_CTI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CTI_PVT" AS
/* $Header: OKCSCTIB.pls 120.0 2005/05/26 09:37:21 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_ctiv_rec IN  ctiv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_COVER_TIMES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_rul_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_rul_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_ctiv_rec      IN    ctiv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_rulv_csr IS
      SELECT 'x'
        FROM OKC_RULES_B rulv
       WHERE rulv.ID = p_ctiv_rec.RUL_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data required
    IF (p_ctiv_rec.rul_id = OKC_API.G_MISS_NUM OR
        p_ctiv_rec.rul_id IS NULL) THEN

      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'rul_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_rulv_csr;
    FETCH l_rulv_csr INTO l_dummy_var;
    CLOSE l_rulv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'rul_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_RULES_V');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rulv_csr%ISOPEN THEN
      CLOSE l_rulv_csr;
    END IF;
  END validate_rul_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_tve_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_tve_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_ctiv_rec      IN    ctiv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_tvev_csr IS
      SELECT 'x'
        FROM OKC_TIMEVALUES tvev
       WHERE tvev.ID = p_ctiv_rec.TVE_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data required
    IF (p_ctiv_rec.tve_id = OKC_API.G_MISS_NUM OR
        p_ctiv_rec.tve_id IS NULL) THEN

      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'tve_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_tvev_csr;
    FETCH l_tvev_csr INTO l_dummy_var;
    CLOSE l_tvev_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'tve_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_TIMEVALUES_V');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_tvev_csr%ISOPEN THEN
      CLOSE l_tvev_csr;
    END IF;
  END validate_tve_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_dnz_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_dnz_chr_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_ctiv_rec      IN    ctiv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_chrv_csr IS
      SELECT 'x'
        FROM OKC_K_HEADERS_B chrv
       WHERE chrv.ID = p_ctiv_rec.DNZ_CHR_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data required
    IF (p_ctiv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
        p_ctiv_rec.dnz_chr_id IS NULL) THEN

      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'dnz_chr_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_chrv_csr;
    FETCH l_chrv_csr INTO l_dummy_var;
    CLOSE l_chrv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'dnz_chr_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_K_HEADERS_V');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_chrv_csr%ISOPEN THEN
      CLOSE l_chrv_csr;
    END IF;
  END validate_dnz_chr_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_ctiv_rec IN  ctiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    validate_rul_id(
      x_return_status => l_return_status,
      p_ctiv_rec      => p_ctiv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_tve_id(
      x_return_status => l_return_status,
      p_ctiv_rec      => p_ctiv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_dnz_chr_id(
      x_return_status => l_return_status,
      p_ctiv_rec      => p_ctiv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE
      (p_app_name     => G_APP_NAME,
       p_msg_name     => G_UNEXPECTED_ERROR,
       p_token1       => G_SQLCODE_TOKEN,
       p_token1_value => SQLCODE,
       p_token2       => G_SQLERRM_TOKEN,
       p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- return status to caller
    RETURN x_return_status;

  END Validate_Attributes;

/***********************  END HAND-CODED  **************************/

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
  -- FUNCTION get_rec for: OKC_COVER_TIMES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cti_rec                      IN cti_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cti_rec_type IS
    CURSOR cti_pk_csr (p_rul_id             IN NUMBER,
                       p_tve_id             IN NUMBER) IS
    SELECT
            RUL_ID,
            TVE_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Cover_Times
     WHERE okc_cover_times.rul_id = p_rul_id
       AND okc_cover_times.tve_id = p_tve_id;
    l_cti_pk                       cti_pk_csr%ROWTYPE;
    l_cti_rec                      cti_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cti_pk_csr (p_cti_rec.rul_id,
                     p_cti_rec.tve_id);
    FETCH cti_pk_csr INTO
              l_cti_rec.RUL_ID,
              l_cti_rec.TVE_ID,
              l_cti_rec.DNZ_CHR_ID,
              l_cti_rec.OBJECT_VERSION_NUMBER,
              l_cti_rec.CREATED_BY,
              l_cti_rec.CREATION_DATE,
              l_cti_rec.LAST_UPDATED_BY,
              l_cti_rec.LAST_UPDATE_DATE,
              l_cti_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cti_pk_csr%NOTFOUND;
    CLOSE cti_pk_csr;
    RETURN(l_cti_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cti_rec                      IN cti_rec_type
  ) RETURN cti_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cti_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_COVER_TIMES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ctiv_rec                     IN ctiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ctiv_rec_type IS
    CURSOR okc_ctiv_pk_csr (p_rul_id             IN NUMBER,
                            p_tve_id             IN NUMBER) IS
    SELECT
            RUL_ID,
            TVE_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Cover_Times_V
     WHERE okc_cover_times_v.rul_id = p_rul_id
       AND okc_cover_times_v.tve_id = p_tve_id;
    l_okc_ctiv_pk                  okc_ctiv_pk_csr%ROWTYPE;
    l_ctiv_rec                     ctiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_ctiv_pk_csr (p_ctiv_rec.rul_id,
                          p_ctiv_rec.tve_id);
    FETCH okc_ctiv_pk_csr INTO
              l_ctiv_rec.RUL_ID,
              l_ctiv_rec.TVE_ID,
              l_ctiv_rec.DNZ_CHR_ID,
              l_ctiv_rec.OBJECT_VERSION_NUMBER,
              l_ctiv_rec.CREATED_BY,
              l_ctiv_rec.CREATION_DATE,
              l_ctiv_rec.LAST_UPDATED_BY,
              l_ctiv_rec.LAST_UPDATE_DATE,
              l_ctiv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_ctiv_pk_csr%NOTFOUND;
    CLOSE okc_ctiv_pk_csr;
    RETURN(l_ctiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ctiv_rec                     IN ctiv_rec_type
  ) RETURN ctiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ctiv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_COVER_TIMES_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ctiv_rec	IN ctiv_rec_type
  ) RETURN ctiv_rec_type IS
    l_ctiv_rec	ctiv_rec_type := p_ctiv_rec;
  BEGIN
    IF (l_ctiv_rec.rul_id = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.rul_id := NULL;
    END IF;
    IF (l_ctiv_rec.tve_id = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.tve_id := NULL;
    END IF;
    IF (l_ctiv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_ctiv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.object_version_number := NULL;
    END IF;
    IF (l_ctiv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.created_by := NULL;
    END IF;
    IF (l_ctiv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ctiv_rec.creation_date := NULL;
    END IF;
    IF (l_ctiv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ctiv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ctiv_rec.last_update_date := NULL;
    END IF;
    IF (l_ctiv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ctiv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ctiv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKC_COVER_TIMES_V --
  -----------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_ctiv_rec IN  ctiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ctiv_rec.rul_id = OKC_API.G_MISS_NUM OR
       p_ctiv_rec.rul_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rul_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ctiv_rec.tve_id = OKC_API.G_MISS_NUM OR
          p_ctiv_rec.tve_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tve_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ctiv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_ctiv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ctiv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_ctiv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Record for:OKC_COVER_TIMES_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_ctiv_rec IN ctiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ctiv_rec_type,
    p_to	IN OUT NOCOPY cti_rec_type
  ) IS
  BEGIN
    p_to.rul_id := p_from.rul_id;
    p_to.tve_id := p_from.tve_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cti_rec_type,
    p_to	IN OUT NOCOPY ctiv_rec_type
  ) IS
  BEGIN
    p_to.rul_id := p_from.rul_id;
    p_to.tve_id := p_from.tve_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
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
  -- validate_row for:OKC_COVER_TIMES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN ctiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
    l_cti_rec                      cti_rec_type;
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
    l_return_status := Validate_Attributes(l_ctiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ctiv_rec);
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
  -- PL/SQL TBL validate_row for:CTIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN ctiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctiv_tbl.COUNT > 0) THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctiv_rec                     => p_ctiv_tbl(i));
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
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
  ------------------------------------
  -- insert_row for:OKC_COVER_TIMES --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cti_rec                      IN cti_rec_type,
    x_cti_rec                      OUT NOCOPY cti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TIMES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cti_rec                      cti_rec_type := p_cti_rec;
    l_def_cti_rec                  cti_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_COVER_TIMES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cti_rec IN  cti_rec_type,
      x_cti_rec OUT NOCOPY cti_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cti_rec := p_cti_rec;
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
      p_cti_rec,                         -- IN
      l_cti_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_COVER_TIMES(
        rul_id,
        tve_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cti_rec.rul_id,
        l_cti_rec.tve_id,
        l_cti_rec.dnz_chr_id,
        l_cti_rec.object_version_number,
        l_cti_rec.created_by,
        l_cti_rec.creation_date,
        l_cti_rec.last_updated_by,
        l_cti_rec.last_update_date,
        l_cti_rec.last_update_login);
    -- Set OUT values
    x_cti_rec := l_cti_rec;
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
  --------------------------------------
  -- insert_row for:OKC_COVER_TIMES_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctiv_rec                     ctiv_rec_type;
    l_def_ctiv_rec                 ctiv_rec_type;
    l_cti_rec                      cti_rec_type;
    lx_cti_rec                     cti_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ctiv_rec	IN ctiv_rec_type
    ) RETURN ctiv_rec_type IS
      l_ctiv_rec	ctiv_rec_type := p_ctiv_rec;
    BEGIN
      l_ctiv_rec.CREATION_DATE := SYSDATE;
      l_ctiv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ctiv_rec.LAST_UPDATE_DATE := l_ctiv_rec.CREATION_DATE;
      l_ctiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ctiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ctiv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKC_COVER_TIMES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_ctiv_rec IN  ctiv_rec_type,
      x_ctiv_rec OUT NOCOPY ctiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ctiv_rec := p_ctiv_rec;
      x_ctiv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ctiv_rec := null_out_defaults(p_ctiv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ctiv_rec,                        -- IN
      l_def_ctiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ctiv_rec := fill_who_columns(l_def_ctiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ctiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ctiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ctiv_rec, l_cti_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cti_rec,
      lx_cti_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cti_rec, l_def_ctiv_rec);
    -- Set OUT values
    x_ctiv_rec := l_def_ctiv_rec;
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
  -- PL/SQL TBL insert_row for:CTIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctiv_tbl.COUNT > 0) THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctiv_rec                     => p_ctiv_tbl(i),
          x_ctiv_rec                     => x_ctiv_tbl(i));
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
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
  ----------------------------------
  -- lock_row for:OKC_COVER_TIMES --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cti_rec                      IN cti_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cti_rec IN cti_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_COVER_TIMES
     WHERE RUL_ID = p_cti_rec.rul_id
       AND TVE_ID = p_cti_rec.tve_id
       AND OBJECT_VERSION_NUMBER = p_cti_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cti_rec IN cti_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_COVER_TIMES
    WHERE RUL_ID = p_cti_rec.rul_id
       AND TVE_ID = p_cti_rec.tve_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TIMES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_COVER_TIMES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_COVER_TIMES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cti_rec);
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
      OPEN lchk_csr(p_cti_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cti_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cti_rec.object_version_number THEN
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
  ------------------------------------
  -- lock_row for:OKC_COVER_TIMES_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN ctiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cti_rec                      cti_rec_type;
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
    migrate(p_ctiv_rec, l_cti_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cti_rec
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
  -- PL/SQL TBL lock_row for:CTIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN ctiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctiv_tbl.COUNT > 0) THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctiv_rec                     => p_ctiv_tbl(i));
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
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
  ------------------------------------
  -- update_row for:OKC_COVER_TIMES --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cti_rec                      IN cti_rec_type,
    x_cti_rec                      OUT NOCOPY cti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TIMES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cti_rec                      cti_rec_type := p_cti_rec;
    l_def_cti_rec                  cti_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cti_rec	IN cti_rec_type,
      x_cti_rec	OUT NOCOPY cti_rec_type
    ) RETURN VARCHAR2 IS
      l_cti_rec                      cti_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cti_rec := p_cti_rec;
      -- Get current database values
      l_cti_rec := get_rec(p_cti_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cti_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.rul_id := l_cti_rec.rul_id;
      END IF;
      IF (x_cti_rec.tve_id = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.tve_id := l_cti_rec.tve_id;
      END IF;
      IF (x_cti_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.dnz_chr_id := l_cti_rec.dnz_chr_id;
      END IF;
      IF (x_cti_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.object_version_number := l_cti_rec.object_version_number;
      END IF;
      IF (x_cti_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.created_by := l_cti_rec.created_by;
      END IF;
      IF (x_cti_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cti_rec.creation_date := l_cti_rec.creation_date;
      END IF;
      IF (x_cti_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.last_updated_by := l_cti_rec.last_updated_by;
      END IF;
      IF (x_cti_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cti_rec.last_update_date := l_cti_rec.last_update_date;
      END IF;
      IF (x_cti_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cti_rec.last_update_login := l_cti_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_COVER_TIMES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cti_rec IN  cti_rec_type,
      x_cti_rec OUT NOCOPY cti_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cti_rec := p_cti_rec;
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
      p_cti_rec,                         -- IN
      l_cti_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cti_rec, l_def_cti_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_COVER_TIMES
    SET DNZ_CHR_ID = l_def_cti_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_cti_rec.object_version_number,
        CREATED_BY = l_def_cti_rec.created_by,
        CREATION_DATE = l_def_cti_rec.creation_date,
        LAST_UPDATED_BY = l_def_cti_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cti_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cti_rec.last_update_login
    WHERE RUL_ID = l_def_cti_rec.rul_id
      AND TVE_ID = l_def_cti_rec.tve_id;

    x_cti_rec := l_def_cti_rec;
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
  --------------------------------------
  -- update_row for:OKC_COVER_TIMES_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
    l_def_ctiv_rec                 ctiv_rec_type;
    l_cti_rec                      cti_rec_type;
    lx_cti_rec                     cti_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ctiv_rec	IN ctiv_rec_type
    ) RETURN ctiv_rec_type IS
      l_ctiv_rec	ctiv_rec_type := p_ctiv_rec;
    BEGIN
      l_ctiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ctiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ctiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ctiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ctiv_rec	IN ctiv_rec_type,
      x_ctiv_rec	OUT NOCOPY ctiv_rec_type
    ) RETURN VARCHAR2 IS
      l_ctiv_rec                     ctiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ctiv_rec := p_ctiv_rec;
      -- Get current database values
      l_ctiv_rec := get_rec(p_ctiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ctiv_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.rul_id := l_ctiv_rec.rul_id;
      END IF;
      IF (x_ctiv_rec.tve_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.tve_id := l_ctiv_rec.tve_id;
      END IF;
      IF (x_ctiv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.dnz_chr_id := l_ctiv_rec.dnz_chr_id;
      END IF;
      IF (x_ctiv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.object_version_number := l_ctiv_rec.object_version_number;
      END IF;
      IF (x_ctiv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.created_by := l_ctiv_rec.created_by;
      END IF;
      IF (x_ctiv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctiv_rec.creation_date := l_ctiv_rec.creation_date;
      END IF;
      IF (x_ctiv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.last_updated_by := l_ctiv_rec.last_updated_by;
      END IF;
      IF (x_ctiv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctiv_rec.last_update_date := l_ctiv_rec.last_update_date;
      END IF;
      IF (x_ctiv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ctiv_rec.last_update_login := l_ctiv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_COVER_TIMES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_ctiv_rec IN  ctiv_rec_type,
      x_ctiv_rec OUT NOCOPY ctiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ctiv_rec := p_ctiv_rec;
      x_ctiv_rec.OBJECT_VERSION_NUMBER := NVL(x_ctiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ctiv_rec,                        -- IN
      l_ctiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ctiv_rec, l_def_ctiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ctiv_rec := fill_who_columns(l_def_ctiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ctiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ctiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ctiv_rec, l_cti_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cti_rec,
      lx_cti_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cti_rec, l_def_ctiv_rec);
    x_ctiv_rec := l_def_ctiv_rec;
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
  -- PL/SQL TBL update_row for:CTIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctiv_tbl.COUNT > 0) THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctiv_rec                     => p_ctiv_tbl(i),
          x_ctiv_rec                     => x_ctiv_tbl(i));
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
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
  ------------------------------------
  -- delete_row for:OKC_COVER_TIMES --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cti_rec                      IN cti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TIMES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cti_rec                      cti_rec_type:= p_cti_rec;
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

     -- Bug#3080839 fix to delete time values associated
     -- with coverage times at line level.
     IF l_cti_rec.tve_id is not null THEN
        okc_time_pub.delete_timevalues_n_tasks(
        p_api_version   => l_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_tve_id        => l_cti_rec.tve_id);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
     END IF;


        -- delete cover times
        DELETE FROM OKC_COVER_TIMES
        WHERE RUL_ID = l_cti_rec.rul_id AND TVE_ID = l_cti_rec.tve_id;

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
  --------------------------------------
  -- delete_row for:OKC_COVER_TIMES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN ctiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
    l_cti_rec                      cti_rec_type;
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
    migrate(l_ctiv_rec, l_cti_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cti_rec
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
  -- PL/SQL TBL delete_row for:CTIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN ctiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctiv_tbl.COUNT > 0) THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctiv_rec                     => p_ctiv_tbl(i));
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_COVER_TIMES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_ctiv_tbl ctiv_tbl_type) IS
  l_tabsize NUMBER := p_ctiv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_rul_id                        OKC_DATATYPES.NumberTabTyp;
  in_tve_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN
   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_ctiv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_rul_id                   (j) := p_ctiv_tbl(i).rul_id;
    in_tve_id                   (j) := p_ctiv_tbl(i).tve_id;
    in_dnz_chr_id               (j) := p_ctiv_tbl(i).dnz_chr_id;
    in_object_version_number    (j) := p_ctiv_tbl(i).object_version_number;
    in_created_by               (j) := p_ctiv_tbl(i).created_by;
    in_creation_date            (j) := p_ctiv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_ctiv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_ctiv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_ctiv_tbl(i).last_update_login;
    i:=p_ctiv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_COVER_TIMES
      (
        rul_id,
        tve_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
-- REMOVE comma from the previous line
     )
     VALUES (
        in_rul_id(i),
        in_tve_id(i),
        in_dnz_chr_id(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
-- REMOVE comma from the previous line
     );

EXCEPTION
  WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

--    RAISE;
END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_cover_times_h
  (
      major_version,
      rul_id,
      tve_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      rul_id,
      tve_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_cover_times
WHERE dnz_chr_id = p_chr_id;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_cover_times
  (
      rul_id,
      tve_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      rul_id,
      tve_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_cover_times_h
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END restore_version;
--
END OKC_CTI_PVT;

/

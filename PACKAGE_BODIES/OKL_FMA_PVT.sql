--------------------------------------------------------
--  DDL for Package Body OKL_FMA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FMA_PVT" AS
/* $Header: OKLSFMAB.pls 120.5 2007/01/09 08:42:13 abhsaxen noship $ */
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_FORMULAE_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_FORMULAE_B B   --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_FORMULAE_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_FORMULAE_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_FORMULAE_TL SUBB, OKL_FORMULAE_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_FORMULAE_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_FORMULAE_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_FORMULAE_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FORMULAE_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fma_rec                      IN fma_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fma_rec_type IS
    CURSOR okl_formulae_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            ORG_ID,
            THERE_CAN_BE_ONLY_ONE_YN,
            CGR_ID,
            FYP_CODE,
            VERSION,
            FORMULA_STRING,
            OBJECT_VERSION_NUMBER,
            START_DATE,
            ATTRIBUTE_CATEGORY,
            END_DATE,
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
      FROM Okl_Formulae_B
     WHERE okl_formulae_b.id    = p_id;
    l_okl_formulae_b_pk            okl_formulae_b_pk_csr%ROWTYPE;
    l_fma_rec                      fma_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_formulae_b_pk_csr (p_fma_rec.id);
    FETCH okl_formulae_b_pk_csr INTO
              l_fma_rec.ID,
              l_fma_rec.NAME,
              l_fma_rec.ORG_ID,
              l_fma_rec.THERE_CAN_BE_ONLY_ONE_YN,
              l_fma_rec.CGR_ID,
              l_fma_rec.FYP_CODE,
              l_fma_rec.VERSION,
              l_fma_rec.FORMULA_STRING,
              l_fma_rec.OBJECT_VERSION_NUMBER,
              l_fma_rec.START_DATE,
              l_fma_rec.ATTRIBUTE_CATEGORY,
              l_fma_rec.END_DATE,
              l_fma_rec.ATTRIBUTE1,
              l_fma_rec.ATTRIBUTE2,
              l_fma_rec.ATTRIBUTE3,
              l_fma_rec.ATTRIBUTE4,
              l_fma_rec.ATTRIBUTE5,
              l_fma_rec.ATTRIBUTE6,
              l_fma_rec.ATTRIBUTE7,
              l_fma_rec.ATTRIBUTE8,
              l_fma_rec.ATTRIBUTE9,
              l_fma_rec.ATTRIBUTE10,
              l_fma_rec.ATTRIBUTE11,
              l_fma_rec.ATTRIBUTE12,
              l_fma_rec.ATTRIBUTE13,
              l_fma_rec.ATTRIBUTE14,
              l_fma_rec.ATTRIBUTE15,
              l_fma_rec.CREATED_BY,
              l_fma_rec.CREATION_DATE,
              l_fma_rec.LAST_UPDATED_BY,
              l_fma_rec.LAST_UPDATE_DATE,
              l_fma_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_formulae_b_pk_csr%NOTFOUND;
    CLOSE okl_formulae_b_pk_csr;
    RETURN(l_fma_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fma_rec                      IN fma_rec_type
  ) RETURN fma_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fma_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FORMULAE_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_formulae_tl_rec_type IS
    CURSOR okl_formulae_tl_pk_csr (p_id                 IN NUMBER,
                                   p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Formulae_Tl
     WHERE okl_formulae_tl.id   = p_id
       AND okl_formulae_tl.language = p_language;
    l_okl_formulae_tl_pk           okl_formulae_tl_pk_csr%ROWTYPE;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_formulae_tl_pk_csr (p_okl_formulae_tl_rec.id,
                                 p_okl_formulae_tl_rec.language);
    FETCH okl_formulae_tl_pk_csr INTO
              l_okl_formulae_tl_rec.ID,
              l_okl_formulae_tl_rec.LANGUAGE,
              l_okl_formulae_tl_rec.SOURCE_LANG,
              l_okl_formulae_tl_rec.SFWT_FLAG,
              l_okl_formulae_tl_rec.DESCRIPTION,
              l_okl_formulae_tl_rec.CREATED_BY,
              l_okl_formulae_tl_rec.CREATION_DATE,
              l_okl_formulae_tl_rec.LAST_UPDATED_BY,
              l_okl_formulae_tl_rec.LAST_UPDATE_DATE,
              l_okl_formulae_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_formulae_tl_pk_csr%NOTFOUND;
    CLOSE okl_formulae_tl_pk_csr;
    RETURN(l_okl_formulae_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type
  ) RETURN okl_formulae_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_formulae_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FORMULAE_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fmav_rec                     IN fmav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fmav_rec_type IS
    CURSOR okl_fmav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CGR_ID,
            FYP_CODE,
            NAME,
            FORMULA_STRING,
            DESCRIPTION,
            VERSION,
            START_DATE,
            END_DATE,
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
            THERE_CAN_BE_ONLY_ONE_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Formulae_V
     WHERE okl_formulae_v.id    = p_id;
    l_okl_fmav_pk                  okl_fmav_pk_csr%ROWTYPE;
    l_fmav_rec                     fmav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_fmav_pk_csr (p_fmav_rec.id);
    FETCH okl_fmav_pk_csr INTO
              l_fmav_rec.ID,
              l_fmav_rec.OBJECT_VERSION_NUMBER,
              l_fmav_rec.SFWT_FLAG,
              l_fmav_rec.CGR_ID,
              l_fmav_rec.FYP_CODE,
              l_fmav_rec.NAME,
              l_fmav_rec.FORMULA_STRING,
              l_fmav_rec.DESCRIPTION,
              l_fmav_rec.VERSION,
              l_fmav_rec.START_DATE,
              l_fmav_rec.END_DATE,
              l_fmav_rec.ATTRIBUTE_CATEGORY,
              l_fmav_rec.ATTRIBUTE1,
              l_fmav_rec.ATTRIBUTE2,
              l_fmav_rec.ATTRIBUTE3,
              l_fmav_rec.ATTRIBUTE4,
              l_fmav_rec.ATTRIBUTE5,
              l_fmav_rec.ATTRIBUTE6,
              l_fmav_rec.ATTRIBUTE7,
              l_fmav_rec.ATTRIBUTE8,
              l_fmav_rec.ATTRIBUTE9,
              l_fmav_rec.ATTRIBUTE10,
              l_fmav_rec.ATTRIBUTE11,
              l_fmav_rec.ATTRIBUTE12,
              l_fmav_rec.ATTRIBUTE13,
              l_fmav_rec.ATTRIBUTE14,
              l_fmav_rec.ATTRIBUTE15,
              l_fmav_rec.ORG_ID,
              l_fmav_rec.THERE_CAN_BE_ONLY_ONE_YN,
              l_fmav_rec.CREATED_BY,
              l_fmav_rec.CREATION_DATE,
              l_fmav_rec.LAST_UPDATED_BY,
              l_fmav_rec.LAST_UPDATE_DATE,
              l_fmav_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fmav_pk_csr%NOTFOUND;
    CLOSE okl_fmav_pk_csr;
    RETURN(l_fmav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fmav_rec                     IN fmav_rec_type
  ) RETURN fmav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fmav_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_FORMULAE_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_fmav_rec	IN fmav_rec_type
  ) RETURN fmav_rec_type IS
    l_fmav_rec	fmav_rec_type := p_fmav_rec;
  BEGIN
    IF (l_fmav_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.object_version_number := NULL;
    END IF;
    IF (l_fmav_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.sfwt_flag := NULL;
    END IF;
    IF (l_fmav_rec.cgr_id = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.cgr_id := NULL;
    END IF;
    IF (l_fmav_rec.fyp_code = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.fyp_code := NULL;
    END IF;
    IF (l_fmav_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.name := NULL;
    END IF;
    IF (l_fmav_rec.formula_string = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.formula_string := NULL;
    END IF;
    IF (l_fmav_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.description := NULL;
    END IF;
    IF (l_fmav_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.version := NULL;
    END IF;
    IF (l_fmav_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_fmav_rec.start_date := NULL;
    END IF;
    IF (l_fmav_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_fmav_rec.end_date := NULL;
    END IF;
    IF (l_fmav_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute_category := NULL;
    END IF;
    IF (l_fmav_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute1 := NULL;
    END IF;
    IF (l_fmav_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute2 := NULL;
    END IF;
    IF (l_fmav_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute3 := NULL;
    END IF;
    IF (l_fmav_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute4 := NULL;
    END IF;
    IF (l_fmav_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute5 := NULL;
    END IF;
    IF (l_fmav_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute6 := NULL;
    END IF;
    IF (l_fmav_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute7 := NULL;
    END IF;
    IF (l_fmav_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute8 := NULL;
    END IF;
    IF (l_fmav_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute9 := NULL;
    END IF;
    IF (l_fmav_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute10 := NULL;
    END IF;
    IF (l_fmav_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute11 := NULL;
    END IF;
    IF (l_fmav_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute12 := NULL;
    END IF;
    IF (l_fmav_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute13 := NULL;
    END IF;
    IF (l_fmav_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute14 := NULL;
    END IF;
    IF (l_fmav_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.attribute15 := NULL;
    END IF;
    IF (l_fmav_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.org_id := NULL;
    END IF;
    IF (l_fmav_rec.there_can_be_only_one_yn = OKC_API.G_MISS_CHAR) THEN
      l_fmav_rec.there_can_be_only_one_yn := NULL;
    END IF;
    IF (l_fmav_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.created_by := NULL;
    END IF;
    IF (l_fmav_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_fmav_rec.creation_date := NULL;
    END IF;
    IF (l_fmav_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.last_updated_by := NULL;
    END IF;
    IF (l_fmav_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_fmav_rec.last_update_date := NULL;
    END IF;
    IF (l_fmav_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_fmav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_fmav_rec);
  END null_out_defaults;

  /** Commented out generated code in favor of hand written code *** SBALASHA001 Start ***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_FORMULAE_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_fmav_rec IN  fmav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_fmav_rec.id = OKC_API.G_MISS_NUM OR
       p_fmav_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_fmav_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.cgr_id = OKC_API.G_MISS_NUM OR
          p_fmav_rec.cgr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cgr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.fyp_code = OKC_API.G_MISS_CHAR OR
          p_fmav_rec.fyp_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fyp_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.name = OKC_API.G_MISS_CHAR OR
          p_fmav_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.version = OKC_API.G_MISS_CHAR OR
          p_fmav_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fmav_rec.start_date = OKC_API.G_MISS_DATE OR
          p_fmav_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_FORMULAE_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_fmav_rec IN fmav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  *** SBALASHA001 End *** **/

 /** SBALASHA001 Start *** -
      INFO: hand coded function related to validate_attribute  **/

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
  PROCEDURE Validate_Id (x_return_status OUT NOCOPY  VARCHAR2
				,p_fmav_rec      IN   fmav_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_fmav_rec.id IS NULL) OR
       (p_fmav_rec.id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_fmav_rec      IN   fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ( p_fmav_rec.object_version_number IS NULL ) OR
       ( p_fmav_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                            p_msg_name       => g_required_value,
                            p_token1         => g_col_name_token,
                            p_token1_value   => 'object_version_number' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfwt_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfwt_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sfwt_Flag(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN   fmav_rec_type)
  IS

  -- l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_return_status         VARCHAR2(1)  := OKC_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      -- l_return_status := OKL_UTIL.check_domain_yn(p_fmav_rec.sfwt_flag);
      l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_fmav_rec.sfwt_flag,0,0);
      IF (l_return_status = OKC_API.G_FALSE) THEN
	          OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => g_invalid_value,
                             p_token1           => g_col_name_token,
                             p_token1_value     => 'sfwt_flag');
                  x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Sfwt_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_TCBOO_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_TCBOO_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_TCBOO_YN(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN   fmav_rec_type)
  IS

  -- l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_return_status         VARCHAR2(1)  := OKC_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      -- l_return_status := OKL_UTIL.check_domain_yn(p_fmav_rec.there_can_be_only_one_yn);
      l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_fmav_rec.there_can_be_only_one_yn,0,0);
      IF (l_return_status = OKC_API.G_FALSE) THEN
	          OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => g_invalid_value,
                             p_token1           => g_col_name_token,
                             p_token1_value     => 'there_can_be_only_one_yn');
                  x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_TCBOO_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cgr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cgr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cgr_Id(
    x_return_status OUT NOCOPY  VARCHAR2,
    p_fmav_rec      IN   fmav_rec_type
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             Boolean := False;

  -- Cursor For OKL_FMA_CGR_FK - Foreign Key Constraint
  CURSOR okl_cgrv_pk_csr (p_id IN OKL_FORMULAE_V.cgr_id%TYPE) IS
  SELECT '1'
    FROM OKL_CONTEXT_GROUPS_V
   WHERE OKL_CONTEXT_GROUPS_V.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_fmav_rec.cgr_id = OKC_API.G_MISS_NUM OR
       p_fmav_rec.cgr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Context');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_cgrv_pk_csr(p_fmav_rec.cgr_id);
    FETCH okl_cgrv_pk_csr INTO l_dummy;
    l_row_not_found := okl_cgrv_pk_csr%NOTFOUND;
    CLOSE okl_cgrv_pk_csr;

    IF l_row_not_found then
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Context');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_cgrv_pk_csr%ISOPEN THEN
        CLOSE okl_cgrv_pk_csr;
      END IF;
  END Validate_Cgr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fyp_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fyp_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fyp_Code(
    x_return_status OUT NOCOPY  VARCHAR2,
    p_fmav_rec      IN   fmav_rec_type
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  -- l_row_not_found             Boolean := False;
  l_row_found             VARCHAR2(1) := OKL_API.G_TRUE;

  -- Cursor For OKL_FMA_FYP_FK - Foreign Key Constraint
/*
  CURSOR okl_fndv_pk_csr (p_code IN OKL_FORMULAE_V.fyp_code%TYPE) IS
  SELECT '1'
    FROM fnd_common_lookups
   WHERE fnd_common_lookups.lookup_code = p_code
   AND fnd_common_lookups.lookup_type = 'OKL_FORMULA_TYPE';
*/

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- RPOONUGA001 modified if condition to check with G_MISS_CHAR than G_MISS_NUM
    IF p_fmav_rec.fyp_code = OKC_API.G_MISS_CHAR OR
       p_fmav_rec.fyp_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fyp_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*
    OPEN okl_fndv_pk_csr(p_fmav_rec.fyp_code);
    FETCH okl_fndv_pk_csr INTO l_dummy;
    l_row_not_found := okl_fndv_pk_csr%NOTFOUND;
    CLOSE okl_fndv_pk_csr;
*/

    l_row_found := OKL_ACCOUNTING_UTIL.validate_lookup_code('OKL_FORMULA_TYPE', p_fmav_rec.fyp_code);

    IF (l_row_found = OKL_API.G_FALSE) then
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'fyp_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      /*
      IF okl_fndv_pk_csr%ISOPEN THEN
        CLOSE okl_fndv_pk_csr;
      END IF;
      */
  END Validate_Fyp_Code;

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
  PROCEDURE Validate_Name(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN OUT NOCOPY  fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_fmav_rec.name IS NULL) OR
       (p_fmav_rec.name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'name' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    p_fmav_rec.name := Okl_Accounting_Util.okl_upper(p_fmav_rec.name);


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Formula_String
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Formula_String
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Formula_String(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN   fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_fmav_rec.formula_string IS NULL) OR
       (p_fmav_rec.formula_string = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'formula_string' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Formula_String;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Version(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN   fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_fmav_rec.version IS NULL) OR
       (p_fmav_rec.version = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'Version' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Start_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Start_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Start_Date(x_return_status OUT NOCOPY  VARCHAR2,
                              p_fmav_rec      IN   fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
	-- RPOONUGA001 modified if condition to check with G_MISS_DATE than G_MISS_CHAR
    IF (p_fmav_rec.start_date IS NULL) OR
       (p_fmav_rec.start_date = OKC_API.G_MISS_DATE) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'start_date' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Start_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_end_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_end_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_end_Date(p_fmav_rec      IN   fmav_rec_type
			     ,x_return_status OUT NOCOPY  VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF p_fmav_rec.end_date IS NOT NULL AND
       p_fmav_rec.end_date <> OKL_API.G_MISS_DATE AND
       p_fmav_rec.end_date < p_fmav_rec.start_date THEN
       OKC_API.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name       => g_to_date_error );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_end_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
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
    p_fmav_rec IN OUT NOCOPY fmav_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fmav_rec fmav_rec_type := p_fmav_rec;
  BEGIN

  	-- call each column-level validation

	-- Validate ID
/*    IF l_fmav_rec.id = OKC_API.G_MISS_NUM OR
       l_fmav_rec.id IS NULL
    THEN
      OKC_API.set_message( G_APP_NAME,
	  					  G_REQUIRED_VALUE,
						  G_COL_NAME_TOKEN, 'id' );
      l_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;
*/

-- Added by Santonyr

       Validate_Id (x_return_status, l_fmav_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;


/*	-- Valid object_version_number
	IF ( l_fmav_rec.object_version_number IS NOT NULL ) AND
	( l_fmav_rec.object_version_number <> OKC_API.G_MISS_NUM ) THEN
		Validate_Object_Version_Number( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/

-- Added by Santonyr
	Validate_Object_Version_Number( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;

/*	-- Valid name
	IF ( l_fmav_rec.name IS NOT NULL ) AND
	( l_fmav_rec.name <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Name( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid name
	Validate_Name( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;

/*	-- Valid version
	IF ( l_fmav_rec.version IS NOT NULL ) AND
	( l_fmav_rec.version <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Version( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid version
	Validate_Version( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;

/*	-- Valid start_date
	-- RPOONUGA001 modified if condition to check with G_MISS_DATE than G_MISS_CHAR
	IF ( l_fmav_rec.start_date IS NOT NULL ) AND
	( l_fmav_rec.start_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_Start_Date( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid start_date
	-- RPOONUGA001 modified if condition to check with G_MISS_DATE than G_MISS_CHAR
	Validate_Start_Date( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;


/*	-- Valid Cgr_Id
	IF ( l_fmav_rec.cgr_id IS NOT NULL ) AND
	( l_fmav_rec.cgr_id <> OKC_API.G_MISS_NUM ) THEN
		Validate_Cgr_Id( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid Cgr_Id
	Validate_Cgr_Id( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;


/*	-- Valid formula_string
	IF ( l_fmav_rec.formula_string IS NOT NULL ) AND
	( l_fmav_rec.formula_string <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Formula_String( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid formula_string
	Validate_Formula_String( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;

	-- Valid there_can_be_only_one_yn
	IF ( l_fmav_rec.there_can_be_only_one_yn IS NOT NULL ) AND
	( l_fmav_rec.there_can_be_only_one_yn <> OKC_API.G_MISS_CHAR ) THEN
		Validate_TCBOO_YN( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;

	-- Valid sfwt_flag
	-- RPOONUGA001 modified if condition to check sfwt_flag than name
	IF ( l_fmav_rec.sfwt_flag IS NOT NULL ) AND
	( l_fmav_rec.sfwt_flag <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Sfwt_Flag( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;

/*	-- Valid Fyp_Code
	-- RPOONUGA001 modified if condition to check with G_MISS_CHAR than G_MISS_NUM
	IF ( l_fmav_rec.fyp_code IS NOT NULL ) AND
	( l_fmav_rec.fyp_code <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Fyp_Code( x_return_status, l_fmav_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;
*/
-- Added by Santonyr
	-- Valid Fyp_Code
	-- RPOONUGA001 modified if condition to check with G_MISS_CHAR than G_MISS_NUM
	Validate_Fyp_Code( x_return_status, l_fmav_rec );
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
		IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
			-- need to leave
			l_return_status := x_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		ELSE
			-- record that there was an error
			l_return_status := x_return_status;
		END IF;
	END IF;


    p_fmav_rec := l_fmav_rec;

    RETURN(l_return_status);
	EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

/**  *** SBALASHA001 End ***  **/

/**  *** SBALASHA002 Start *** -
      INFO: hand coded function related to validate_record **/


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Fma_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Fma_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Fma_Record(
                                  x_return_status OUT NOCOPY     VARCHAR2,
                                  p_fmav_rec      IN      fmav_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  -- RPOONUGA002 modified the cursor.  Deleted the extra where clause condition id = p_id
  -- and removed p_id as input parameter to the cursor
  CURSOR c1(p_name okl_formulae_v.name%TYPE,
			p_version okl_formulae_v.version%TYPE ) is
  SELECT 1
  FROM okl_formulae_v
  WHERE  name = p_name
  AND   version = p_version
  AND    id <> nvl( p_fmav_rec.id, -9999 );

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- RPOONUGA002 modified the cursor call
    OPEN c1( p_fmav_rec.name, p_fmav_rec.version );
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		OKC_API.set_message( 'OKL', G_UNQS, G_TABLE_TOKEN, 'Okl_Formulae_V' );
		x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Fma_Record;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_fmav_rec IN fmav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	-- Validate_Unique_Fma_Record
	Validate_Unique_Fma_Record( x_return_status, p_fmav_rec );
	-- store the highest degree of error
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
	  IF ( x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
	      -- need to leave
	      l_return_status := x_return_status;
	      RAISE G_EXCEPTION_HALT_VALIDATION;
	      ELSE
	      -- record that there was an error
	      l_return_status := x_return_status;
	  END IF;
	END IF;

    -- Validate_end_Date
	-- Suresh Gorantla: Added this call to validate end date.
	-- Valid end date
	IF ( p_fmav_rec.end_date IS NOT NULL ) AND
	( p_fmav_rec.end_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_end_Date(p_fmav_rec, x_return_status );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;

	RETURN( l_return_status );

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN ( l_return_status );

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN (x_return_status);
  END Validate_Record;


/** *** SBALASHA002 End *** **/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  -- RPOONUGA003: Add IN to p_to parameter in all migrate procedures
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN fmav_rec_type,
    p_to	IN OUT NOCOPY fma_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.org_id := p_from.org_id;
    p_to.there_can_be_only_one_yn := p_from.there_can_be_only_one_yn;
    p_to.cgr_id := p_from.cgr_id;
    p_to.fyp_code := p_from.fyp_code;
    p_to.version := p_from.version;
    p_to.formula_string := p_from.formula_string;
    p_to.object_version_number := p_from.object_version_number;
    p_to.start_date := p_from.start_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.end_date := p_from.end_date;
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
    p_from	IN fma_rec_type,
    p_to	IN OUT NOCOPY fmav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.org_id := p_from.org_id;
    p_to.there_can_be_only_one_yn := p_from.there_can_be_only_one_yn;
    p_to.cgr_id := p_from.cgr_id;
    p_to.fyp_code := p_from.fyp_code;
    p_to.version := p_from.version;
    p_to.formula_string := p_from.formula_string;
    p_to.object_version_number := p_from.object_version_number;
    p_to.start_date := p_from.start_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.end_date := p_from.end_date;
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
    p_from	IN fmav_rec_type,
    p_to	IN OUT NOCOPY okl_formulae_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_formulae_tl_rec_type,
    p_to	IN OUT NOCOPY fmav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_FORMULAE_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fmav_rec                     fmav_rec_type := p_fmav_rec;
    l_fma_rec                      fma_rec_type;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_fmav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_fmav_rec);
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
  -- PL/SQL TBL validate_row for:FMAV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA003: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fmav_tbl.COUNT > 0) THEN
      i := p_fmav_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fmav_rec                     => p_fmav_tbl(i));
        -- RPOONUGA003: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_fmav_tbl.LAST);
        i := p_fmav_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA003: return overall status
	x_return_status := l_overall_status;
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
  -----------------------------------
  -- insert_row for:OKL_FORMULAE_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_rec                      IN fma_rec_type,
    x_fma_rec                      OUT NOCOPY fma_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fma_rec                      fma_rec_type := p_fma_rec;
    l_def_fma_rec                  fma_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_fma_rec IN  fma_rec_type,
      x_fma_rec OUT NOCOPY fma_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fma_rec := p_fma_rec;
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
      p_fma_rec,                         -- IN
      l_fma_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_FORMULAE_B(
        id,
        name,
        org_id,
        there_can_be_only_one_yn,
        cgr_id,
        fyp_code,
        version,
        formula_string,
        object_version_number,
        start_date,
        attribute_category,
        end_date,
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
        l_fma_rec.id,
        l_fma_rec.name,
        l_fma_rec.org_id,
        l_fma_rec.there_can_be_only_one_yn,
        l_fma_rec.cgr_id,
        l_fma_rec.fyp_code,
        l_fma_rec.version,
        l_fma_rec.formula_string,
        l_fma_rec.object_version_number,
        l_fma_rec.start_date,
        l_fma_rec.attribute_category,
        l_fma_rec.end_date,
        l_fma_rec.attribute1,
        l_fma_rec.attribute2,
        l_fma_rec.attribute3,
        l_fma_rec.attribute4,
        l_fma_rec.attribute5,
        l_fma_rec.attribute6,
        l_fma_rec.attribute7,
        l_fma_rec.attribute8,
        l_fma_rec.attribute9,
        l_fma_rec.attribute10,
        l_fma_rec.attribute11,
        l_fma_rec.attribute12,
        l_fma_rec.attribute13,
        l_fma_rec.attribute14,
        l_fma_rec.attribute15,
        l_fma_rec.created_by,
        l_fma_rec.creation_date,
        l_fma_rec.last_updated_by,
        l_fma_rec.last_update_date,
        l_fma_rec.last_update_login);
    -- Set OUT values
    x_fma_rec := l_fma_rec;
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
  ------------------------------------
  -- insert_row for:OKL_FORMULAE_TL --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type,
    x_okl_formulae_tl_rec          OUT NOCOPY okl_formulae_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type := p_okl_formulae_tl_rec;
    l_def_okl_formulae_tl_rec      okl_formulae_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_formulae_tl_rec IN  okl_formulae_tl_rec_type,
      x_okl_formulae_tl_rec OUT NOCOPY okl_formulae_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_formulae_tl_rec := p_okl_formulae_tl_rec;
      x_okl_formulae_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_formulae_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_formulae_tl_rec,             -- IN
      l_okl_formulae_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_formulae_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_FORMULAE_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_formulae_tl_rec.id,
          l_okl_formulae_tl_rec.language,
          l_okl_formulae_tl_rec.source_lang,
          l_okl_formulae_tl_rec.sfwt_flag,
          l_okl_formulae_tl_rec.description,
          l_okl_formulae_tl_rec.created_by,
          l_okl_formulae_tl_rec.creation_date,
          l_okl_formulae_tl_rec.last_updated_by,
          l_okl_formulae_tl_rec.last_update_date,
          l_okl_formulae_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_formulae_tl_rec := l_okl_formulae_tl_rec;
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
  -- insert_row for:OKL_FORMULAE_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fmav_rec                     fmav_rec_type;
    l_def_fmav_rec                 fmav_rec_type;
    l_fma_rec                      fma_rec_type;
    lx_fma_rec                     fma_rec_type;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
    lx_okl_formulae_tl_rec         okl_formulae_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fmav_rec	IN fmav_rec_type
    ) RETURN fmav_rec_type IS
      l_fmav_rec	fmav_rec_type := p_fmav_rec;
    BEGIN
      l_fmav_rec.CREATION_DATE := SYSDATE;
      l_fmav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_fmav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fmav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fmav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fmav_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_fmav_rec IN  fmav_rec_type,
      x_fmav_rec OUT NOCOPY fmav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fmav_rec := p_fmav_rec;
      x_fmav_rec.OBJECT_VERSION_NUMBER := 1;
      x_fmav_rec.SFWT_FLAG := 'N';
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
    l_fmav_rec := null_out_defaults(p_fmav_rec);
    -- Set primary key value
    l_fmav_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_fmav_rec,                        -- IN
      l_def_fmav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fmav_rec := fill_who_columns(l_def_fmav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fmav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fmav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fmav_rec, l_fma_rec);
    migrate(l_def_fmav_rec, l_okl_formulae_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fma_rec,
      lx_fma_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fma_rec, l_def_fmav_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_formulae_tl_rec,
      lx_okl_formulae_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_formulae_tl_rec, l_def_fmav_rec);
    -- Set OUT values
    x_fmav_rec := l_def_fmav_rec;
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
  -- PL/SQL TBL insert_row for:FMAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type,
    x_fmav_tbl                     OUT NOCOPY fmav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA003: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fmav_tbl.COUNT > 0) THEN
      i := p_fmav_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fmav_rec                     => p_fmav_tbl(i),
          x_fmav_rec                     => x_fmav_tbl(i));
        -- RPOONUGA003: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_fmav_tbl.LAST);
        i := p_fmav_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA003: return overall status
	x_return_status := l_overall_status;
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
  ---------------------------------
  -- lock_row for:OKL_FORMULAE_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_rec                      IN fma_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fma_rec IN fma_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FORMULAE_B
     WHERE ID = p_fma_rec.id
       AND OBJECT_VERSION_NUMBER = p_fma_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_fma_rec IN fma_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FORMULAE_B
    WHERE ID = p_fma_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_FORMULAE_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_FORMULAE_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_fma_rec);
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
      OPEN lchk_csr(p_fma_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_fma_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_fma_rec.object_version_number THEN
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
  ----------------------------------
  -- lock_row for:OKL_FORMULAE_TL --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_formulae_tl_rec IN okl_formulae_tl_rec_type) IS
    SELECT *
      FROM OKL_FORMULAE_TL
     WHERE ID = p_okl_formulae_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okl_formulae_tl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  -- lock_row for:OKL_FORMULAE_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fma_rec                      fma_rec_type;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
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
    migrate(p_fmav_rec, l_fma_rec);
    migrate(p_fmav_rec, l_okl_formulae_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fma_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_formulae_tl_rec
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
  -- PL/SQL TBL lock_row for:FMAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA003: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fmav_tbl.COUNT > 0) THEN
      i := p_fmav_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fmav_rec                     => p_fmav_tbl(i));
        -- RPOONUGA003: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_fmav_tbl.LAST);
        i := p_fmav_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA003: return overall status
	x_return_status := l_overall_status;
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
  -----------------------------------
  -- update_row for:OKL_FORMULAE_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_rec                      IN fma_rec_type,
    x_fma_rec                      OUT NOCOPY fma_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fma_rec                      fma_rec_type := p_fma_rec;
    l_def_fma_rec                  fma_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fma_rec	IN fma_rec_type,
      x_fma_rec	OUT NOCOPY fma_rec_type
    ) RETURN VARCHAR2 IS
      l_fma_rec                      fma_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fma_rec := p_fma_rec;
      -- Get current database values
      l_fma_rec := get_rec(p_fma_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fma_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.id := l_fma_rec.id;
      END IF;
      IF (x_fma_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.name := l_fma_rec.name;
      END IF;
      IF (x_fma_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.org_id := l_fma_rec.org_id;
      END IF;
      IF (x_fma_rec.there_can_be_only_one_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.there_can_be_only_one_yn := l_fma_rec.there_can_be_only_one_yn;
      END IF;
      IF (x_fma_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.cgr_id := l_fma_rec.cgr_id;
      END IF;
      IF (x_fma_rec.fyp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.fyp_code := l_fma_rec.fyp_code;
      END IF;
      IF (x_fma_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.version := l_fma_rec.version;
      END IF;
      IF (x_fma_rec.formula_string = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.formula_string := l_fma_rec.formula_string;
      END IF;
      IF (x_fma_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.object_version_number := l_fma_rec.object_version_number;
      END IF;
      IF (x_fma_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_fma_rec.start_date := l_fma_rec.start_date;
      END IF;
      IF (x_fma_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute_category := l_fma_rec.attribute_category;
      END IF;
      IF (x_fma_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_fma_rec.end_date := l_fma_rec.end_date;
      END IF;
      IF (x_fma_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute1 := l_fma_rec.attribute1;
      END IF;
      IF (x_fma_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute2 := l_fma_rec.attribute2;
      END IF;
      IF (x_fma_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute3 := l_fma_rec.attribute3;
      END IF;
      IF (x_fma_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute4 := l_fma_rec.attribute4;
      END IF;
      IF (x_fma_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute5 := l_fma_rec.attribute5;
      END IF;
      IF (x_fma_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute6 := l_fma_rec.attribute6;
      END IF;
      IF (x_fma_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute7 := l_fma_rec.attribute7;
      END IF;
      IF (x_fma_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute8 := l_fma_rec.attribute8;
      END IF;
      IF (x_fma_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute9 := l_fma_rec.attribute9;
      END IF;
      IF (x_fma_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute10 := l_fma_rec.attribute10;
      END IF;
      IF (x_fma_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute11 := l_fma_rec.attribute11;
      END IF;
      IF (x_fma_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute12 := l_fma_rec.attribute12;
      END IF;
      IF (x_fma_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute13 := l_fma_rec.attribute13;
      END IF;
      IF (x_fma_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute14 := l_fma_rec.attribute14;
      END IF;
      IF (x_fma_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_fma_rec.attribute15 := l_fma_rec.attribute15;
      END IF;
      IF (x_fma_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.created_by := l_fma_rec.created_by;
      END IF;
      IF (x_fma_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_fma_rec.creation_date := l_fma_rec.creation_date;
      END IF;
      IF (x_fma_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.last_updated_by := l_fma_rec.last_updated_by;
      END IF;
      IF (x_fma_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_fma_rec.last_update_date := l_fma_rec.last_update_date;
      END IF;
      IF (x_fma_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_fma_rec.last_update_login := l_fma_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_fma_rec IN  fma_rec_type,
      x_fma_rec OUT NOCOPY fma_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fma_rec := p_fma_rec;
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
      p_fma_rec,                         -- IN
      l_fma_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fma_rec, l_def_fma_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_FORMULAE_B
    SET NAME = l_def_fma_rec.name,
        ORG_ID = l_def_fma_rec.org_id,
        THERE_CAN_BE_ONLY_ONE_YN = l_def_fma_rec.there_can_be_only_one_yn,
        CGR_ID = l_def_fma_rec.cgr_id,
        FYP_CODE = l_def_fma_rec.fyp_code,
        VERSION = l_def_fma_rec.version,
        FORMULA_STRING = l_def_fma_rec.formula_string,
        OBJECT_VERSION_NUMBER = l_def_fma_rec.object_version_number,
        START_DATE = l_def_fma_rec.start_date,
        ATTRIBUTE_CATEGORY = l_def_fma_rec.attribute_category,
        END_DATE = l_def_fma_rec.end_date,
        ATTRIBUTE1 = l_def_fma_rec.attribute1,
        ATTRIBUTE2 = l_def_fma_rec.attribute2,
        ATTRIBUTE3 = l_def_fma_rec.attribute3,
        ATTRIBUTE4 = l_def_fma_rec.attribute4,
        ATTRIBUTE5 = l_def_fma_rec.attribute5,
        ATTRIBUTE6 = l_def_fma_rec.attribute6,
        ATTRIBUTE7 = l_def_fma_rec.attribute7,
        ATTRIBUTE8 = l_def_fma_rec.attribute8,
        ATTRIBUTE9 = l_def_fma_rec.attribute9,
        ATTRIBUTE10 = l_def_fma_rec.attribute10,
        ATTRIBUTE11 = l_def_fma_rec.attribute11,
        ATTRIBUTE12 = l_def_fma_rec.attribute12,
        ATTRIBUTE13 = l_def_fma_rec.attribute13,
        ATTRIBUTE14 = l_def_fma_rec.attribute14,
        ATTRIBUTE15 = l_def_fma_rec.attribute15,
        CREATED_BY = l_def_fma_rec.created_by,
        CREATION_DATE = l_def_fma_rec.creation_date,
        LAST_UPDATED_BY = l_def_fma_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fma_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fma_rec.last_update_login
    WHERE ID = l_def_fma_rec.id;

    x_fma_rec := l_def_fma_rec;
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
  ------------------------------------
  -- update_row for:OKL_FORMULAE_TL --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type,
    x_okl_formulae_tl_rec          OUT NOCOPY okl_formulae_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type := p_okl_formulae_tl_rec;
    l_def_okl_formulae_tl_rec      okl_formulae_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_formulae_tl_rec	IN okl_formulae_tl_rec_type,
      x_okl_formulae_tl_rec	OUT NOCOPY okl_formulae_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_formulae_tl_rec := p_okl_formulae_tl_rec;
      -- Get current database values
      l_okl_formulae_tl_rec := get_rec(p_okl_formulae_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_formulae_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_formulae_tl_rec.id := l_okl_formulae_tl_rec.id;
      END IF;
      IF (x_okl_formulae_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_formulae_tl_rec.language := l_okl_formulae_tl_rec.language;
      END IF;
      IF (x_okl_formulae_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_formulae_tl_rec.source_lang := l_okl_formulae_tl_rec.source_lang;
      END IF;
      IF (x_okl_formulae_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_formulae_tl_rec.sfwt_flag := l_okl_formulae_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_formulae_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_formulae_tl_rec.description := l_okl_formulae_tl_rec.description;
      END IF;
      IF (x_okl_formulae_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_formulae_tl_rec.created_by := l_okl_formulae_tl_rec.created_by;
      END IF;
      IF (x_okl_formulae_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_formulae_tl_rec.creation_date := l_okl_formulae_tl_rec.creation_date;
      END IF;
      IF (x_okl_formulae_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_formulae_tl_rec.last_updated_by := l_okl_formulae_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_formulae_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_formulae_tl_rec.last_update_date := l_okl_formulae_tl_rec.last_update_date;
      END IF;
      IF (x_okl_formulae_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_formulae_tl_rec.last_update_login := l_okl_formulae_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_formulae_tl_rec IN  okl_formulae_tl_rec_type,
      x_okl_formulae_tl_rec OUT NOCOPY okl_formulae_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_formulae_tl_rec := p_okl_formulae_tl_rec;
      x_okl_formulae_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_formulae_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_formulae_tl_rec,             -- IN
      l_okl_formulae_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_formulae_tl_rec, l_def_okl_formulae_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_FORMULAE_TL
    SET DESCRIPTION = l_def_okl_formulae_tl_rec.description,
        CREATED_BY = l_def_okl_formulae_tl_rec.created_by,
        SOURCE_LANG = l_def_okl_formulae_tl_rec.source_lang,
        CREATION_DATE = l_def_okl_formulae_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_formulae_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_formulae_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_formulae_tl_rec.last_update_login
    WHERE ID = l_def_okl_formulae_tl_rec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_FORMULAE_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_formulae_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_formulae_tl_rec := l_def_okl_formulae_tl_rec;
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
  -- update_row for:OKL_FORMULAE_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type,
    x_fmav_rec                     OUT NOCOPY fmav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fmav_rec                     fmav_rec_type := p_fmav_rec;
    l_def_fmav_rec                 fmav_rec_type;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
    lx_okl_formulae_tl_rec         okl_formulae_tl_rec_type;
    l_fma_rec                      fma_rec_type;
    lx_fma_rec                     fma_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fmav_rec	IN fmav_rec_type
    ) RETURN fmav_rec_type IS
      l_fmav_rec	fmav_rec_type := p_fmav_rec;
    BEGIN
      l_fmav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fmav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fmav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fmav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fmav_rec	IN fmav_rec_type,
      x_fmav_rec	OUT NOCOPY fmav_rec_type
    ) RETURN VARCHAR2 IS
      l_fmav_rec                     fmav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fmav_rec := p_fmav_rec;
      -- Get current database values
      l_fmav_rec := get_rec(p_fmav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fmav_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.id := l_fmav_rec.id;
      END IF;
      IF (x_fmav_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.object_version_number := l_fmav_rec.object_version_number;
      END IF;
      IF (x_fmav_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.sfwt_flag := l_fmav_rec.sfwt_flag;
      END IF;
      IF (x_fmav_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.cgr_id := l_fmav_rec.cgr_id;
      END IF;
      IF (x_fmav_rec.fyp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.fyp_code := l_fmav_rec.fyp_code;
      END IF;
      IF (x_fmav_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.name := l_fmav_rec.name;
      END IF;
      IF (x_fmav_rec.formula_string = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.formula_string := l_fmav_rec.formula_string;
      END IF;
      IF (x_fmav_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.description := l_fmav_rec.description;
      END IF;
      IF (x_fmav_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.version := l_fmav_rec.version;
      END IF;
      IF (x_fmav_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_fmav_rec.start_date := l_fmav_rec.start_date;
      END IF;
      IF (x_fmav_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_fmav_rec.end_date := l_fmav_rec.end_date;
      END IF;
      IF (x_fmav_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute_category := l_fmav_rec.attribute_category;
      END IF;
      IF (x_fmav_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute1 := l_fmav_rec.attribute1;
      END IF;
      IF (x_fmav_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute2 := l_fmav_rec.attribute2;
      END IF;
      IF (x_fmav_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute3 := l_fmav_rec.attribute3;
      END IF;
      IF (x_fmav_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute4 := l_fmav_rec.attribute4;
      END IF;
      IF (x_fmav_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute5 := l_fmav_rec.attribute5;
      END IF;
      IF (x_fmav_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute6 := l_fmav_rec.attribute6;
      END IF;
      IF (x_fmav_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute7 := l_fmav_rec.attribute7;
      END IF;
      IF (x_fmav_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute8 := l_fmav_rec.attribute8;
      END IF;
      IF (x_fmav_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute9 := l_fmav_rec.attribute9;
      END IF;
      IF (x_fmav_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute10 := l_fmav_rec.attribute10;
      END IF;
      IF (x_fmav_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute11 := l_fmav_rec.attribute11;
      END IF;
      IF (x_fmav_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute12 := l_fmav_rec.attribute12;
      END IF;
      IF (x_fmav_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute13 := l_fmav_rec.attribute13;
      END IF;
      IF (x_fmav_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute14 := l_fmav_rec.attribute14;
      END IF;
      IF (x_fmav_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.attribute15 := l_fmav_rec.attribute15;
      END IF;
      IF (x_fmav_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.org_id := l_fmav_rec.org_id;
      END IF;
      IF (x_fmav_rec.there_can_be_only_one_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_fmav_rec.there_can_be_only_one_yn := l_fmav_rec.there_can_be_only_one_yn;
      END IF;
      IF (x_fmav_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.created_by := l_fmav_rec.created_by;
      END IF;
      IF (x_fmav_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_fmav_rec.creation_date := l_fmav_rec.creation_date;
      END IF;
      IF (x_fmav_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.last_updated_by := l_fmav_rec.last_updated_by;
      END IF;
      IF (x_fmav_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_fmav_rec.last_update_date := l_fmav_rec.last_update_date;
      END IF;
      IF (x_fmav_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_fmav_rec.last_update_login := l_fmav_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_fmav_rec IN  fmav_rec_type,
      x_fmav_rec OUT NOCOPY fmav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fmav_rec := p_fmav_rec;
      x_fmav_rec.OBJECT_VERSION_NUMBER := NVL(x_fmav_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_fmav_rec,                        -- IN
      l_fmav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fmav_rec, l_def_fmav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fmav_rec := fill_who_columns(l_def_fmav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fmav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fmav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fmav_rec, l_okl_formulae_tl_rec);
    migrate(l_def_fmav_rec, l_fma_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_formulae_tl_rec,
      lx_okl_formulae_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_formulae_tl_rec, l_def_fmav_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fma_rec,
      lx_fma_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fma_rec, l_def_fmav_rec);
    x_fmav_rec := l_def_fmav_rec;
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
  -- PL/SQL TBL update_row for:FMAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type,
    x_fmav_tbl                     OUT NOCOPY fmav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA003: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fmav_tbl.COUNT > 0) THEN
      i := p_fmav_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fmav_rec                     => p_fmav_tbl(i),
          x_fmav_rec                     => x_fmav_tbl(i));
        -- RPOONUGA003: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_fmav_tbl.LAST);
        i := p_fmav_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA003: return overall status
	x_return_status := l_overall_status;
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
  -----------------------------------
  -- delete_row for:OKL_FORMULAE_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_rec                      IN fma_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fma_rec                      fma_rec_type:= p_fma_rec;
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
    DELETE FROM OKL_FORMULAE_B
     WHERE ID = l_fma_rec.id;

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
  ------------------------------------
  -- delete_row for:OKL_FORMULAE_TL --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_formulae_tl_rec          IN okl_formulae_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type:= p_okl_formulae_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------
    -- Set_Attributes for:OKL_FORMULAE_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_formulae_tl_rec IN  okl_formulae_tl_rec_type,
      x_okl_formulae_tl_rec OUT NOCOPY okl_formulae_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_formulae_tl_rec := p_okl_formulae_tl_rec;
      x_okl_formulae_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_formulae_tl_rec,             -- IN
      l_okl_formulae_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_FORMULAE_TL
     WHERE ID = l_okl_formulae_tl_rec.id;

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
  -- delete_row for:OKL_FORMULAE_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_rec                     IN fmav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fmav_rec                     fmav_rec_type := p_fmav_rec;
    l_okl_formulae_tl_rec          okl_formulae_tl_rec_type;
    l_fma_rec                      fma_rec_type;
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
    migrate(l_fmav_rec, l_okl_formulae_tl_rec);
    migrate(l_fmav_rec, l_fma_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_formulae_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fma_rec
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
  -- PL/SQL TBL delete_row for:FMAV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fmav_tbl                     IN fmav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA003: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fmav_tbl.COUNT > 0) THEN
      i := p_fmav_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fmav_rec                     => p_fmav_tbl(i));
        -- RPOONUGA003: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_fmav_tbl.LAST);
        i := p_fmav_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA003: return overall status
	x_return_status := l_overall_status;
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

 -------------------------------------------------------------------------------
  -- Procedure TRANSLATE_ROW
 -------------------------------------------------------------------------------

  PROCEDURE TRANSLATE_ROW(p_fmav_rec IN fmav_rec_type,
                          p_owner IN VARCHAR2,
                          p_last_update_date IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2) IS
   f_luby    NUMBER;  -- entity owner in file
   f_ludate  DATE;    -- entity update date in file
   db_luby     NUMBER;  -- entity owner in db
   db_ludate   DATE;    -- entity update date in db

   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

     SELECT  LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO  db_luby, db_ludate
      FROM OKL_FORMULAE_TL
      where ID = to_number(p_fmav_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
    	 --Update TL
    	UPDATE OKL_FORMULAE_TL
    	SET	DESCRIPTION       = p_fmav_rec.DESCRIPTION,
        	LAST_UPDATE_DATE  = f_ludate,
        	LAST_UPDATED_BY   = f_luby,
        	LAST_UPDATE_LOGIN = 0,
        	SOURCE_LANG       = USERENV('LANG')
    	WHERE ID = to_number(p_fmav_rec.id)
      	AND USERENV('LANG') IN (language,source_lang);
      END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_fmav_rec IN fmav_rec_type,
                     p_owner    IN VARCHAR2,
                     p_last_update_date IN VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2) IS
    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db
   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO id, db_luby, db_ludate
      FROM OKL_FORMULAE_B
      where ID = p_fmav_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
        UPDATE OKL_FORMULAE_B
        SET
         ORG_ID	   	   = TO_NUMBER(p_fmav_rec.ORG_ID),
	     THERE_CAN_BE_ONLY_ONE_YN = p_fmav_rec.THERE_CAN_BE_ONLY_ONE_YN,
	     CGR_ID		   = TO_NUMBER(p_fmav_rec.CGR_ID),
	     FYP_CODE		   = p_fmav_rec.FYP_CODE,
	     FORMULA_STRING        = p_fmav_rec.FORMULA_STRING,
	     OBJECT_VERSION_NUMBER = TO_NUMBER(p_fmav_rec.OBJECT_VERSION_NUMBER),
	     START_DATE	  	   = p_fmav_rec.START_DATE,
	     END_DATE		   = p_fmav_rec.END_DATE,
         ATTRIBUTE_CATEGORY	   = p_fmav_rec.ATTRIBUTE_CATEGORY,
	     ATTRIBUTE1		   = p_fmav_rec.ATTRIBUTE1,
	     ATTRIBUTE2		   = p_fmav_rec.ATTRIBUTE2,
	     ATTRIBUTE3        = p_fmav_rec.ATTRIBUTE3,
	     ATTRIBUTE4        = p_fmav_rec.ATTRIBUTE4,
	     ATTRIBUTE5        = p_fmav_rec.ATTRIBUTE5,
	     ATTRIBUTE6        = p_fmav_rec.ATTRIBUTE6,
	     ATTRIBUTE7        = p_fmav_rec.ATTRIBUTE7,
	     ATTRIBUTE8        = p_fmav_rec.ATTRIBUTE8,
	     ATTRIBUTE9        = p_fmav_rec.ATTRIBUTE9,
	     ATTRIBUTE10       = p_fmav_rec.ATTRIBUTE10,
	     ATTRIBUTE11       = p_fmav_rec.ATTRIBUTE11,
	     ATTRIBUTE12       = p_fmav_rec.ATTRIBUTE12,
	     ATTRIBUTE13       = p_fmav_rec.ATTRIBUTE13,
	     ATTRIBUTE14       = p_fmav_rec.ATTRIBUTE14,
	     ATTRIBUTE15       = p_fmav_rec.ATTRIBUTE15,
         LAST_UPDATE_DATE  = f_ludate,
         LAST_UPDATED_BY   = f_luby,
         LAST_UPDATE_LOGIN = 0
        WHERE ID = to_number(p_fmav_rec.id);
        --Update _TL

        UPDATE OKL_FORMULAE_TL
        SET
         DESCRIPTION       = p_fmav_rec.DESCRIPTION,
         LAST_UPDATE_DATE  = f_ludate,
         LAST_UPDATED_BY   = f_luby,
         LAST_UPDATE_LOGIN = 0,
         SOURCE_LANG       = USERENV('LANG')
        WHERE ID = to_number(p_fmav_rec.id)
          AND USERENV('LANG') IN (language,source_lang);

        IF(sql%notfound) THEN
           INSERT INTO OKL_FORMULAE_TL
        	(
        	ID,
        	LANGUAGE,
        	SOURCE_LANG,
        	SFWT_FLAG,
        	DESCRIPTION,
        	CREATED_BY,
        	CREATION_DATE,
        	LAST_UPDATED_BY,
        	LAST_UPDATE_DATE,
        	LAST_UPDATE_LOGIN
        	)
        	SELECT
             TO_NUMBER(p_fmav_rec.id),
        	 L.LANGUAGE_CODE,
        	 USERENV('LANG'),
        	 DECODE(L.LANGUAGE_CODE,USERENV('LANG'),'N','Y'),
        	 p_fmav_rec.description,
        	 f_luby,
        	 f_ludate,
        	 f_luby,
        	 f_ludate,
        	 0
        	FROM FND_LANGUAGES L
        	WHERE L.INSTALLED_FLAG IN ('I','B')
             AND NOT EXISTS
                (SELECT NULL
                 FROM   OKL_FORMULAE_TL TL
                 WHERE  TL.ID = TO_NUMBER(p_fmav_rec.id)
                 AND    TL.LANGUAGE = L.LANGUAGE_CODE);
        END IF;

     END IF;

    END;
    EXCEPTION
     when no_data_found then

       INSERT INTO OKL_FORMULAE_B
    	(
    	ID,
    	NAME,
    	ORG_ID,
    	THERE_CAN_BE_ONLY_ONE_YN,
    	CGR_ID,
    	FYP_CODE,
    	VERSION,
    	FORMULA_STRING,
    	OBJECT_VERSION_NUMBER,
    	START_DATE,
    	END_DATE,
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
    	)
        SELECT
    	TO_NUMBER(p_fmav_rec.id),
    	p_fmav_rec.NAME,
    	TO_NUMBER(p_fmav_rec.ORG_ID),
    	p_fmav_rec.THERE_CAN_BE_ONLY_ONE_YN,
    	TO_NUMBER(p_fmav_rec.CGR_ID),
    	p_fmav_rec.FYP_CODE,
    	p_fmav_rec.VERSION,
    	p_fmav_rec.FORMULA_STRING,
    	TO_NUMBER(p_fmav_rec.OBJECT_VERSION_NUMBER),
    	p_fmav_rec.START_DATE,
    	p_fmav_rec.END_DATE,
    	p_fmav_rec.ATTRIBUTE_CATEGORY,
    	p_fmav_rec.ATTRIBUTE1,
    	p_fmav_rec.ATTRIBUTE2,
    	p_fmav_rec.ATTRIBUTE3,
    	p_fmav_rec.ATTRIBUTE4,
    	p_fmav_rec.ATTRIBUTE5,
    	p_fmav_rec.ATTRIBUTE6,
    	p_fmav_rec.ATTRIBUTE7,
    	p_fmav_rec.ATTRIBUTE8,
    	p_fmav_rec.ATTRIBUTE9,
    	p_fmav_rec.ATTRIBUTE10,
    	p_fmav_rec.ATTRIBUTE11,
    	p_fmav_rec.ATTRIBUTE12,
    	p_fmav_rec.ATTRIBUTE13,
    	p_fmav_rec.ATTRIBUTE14,
    	p_fmav_rec.ATTRIBUTE15,
    	f_luby,
    	f_ludate,
    	f_luby,
    	f_ludate,
    	0
       FROM DUAL
       WHERE NOT EXISTS (SELECT 1
                         from OKL_FORMULAE_B
                         where ( ID = TO_NUMBER(p_fmav_rec.id) OR
                        (NAME = p_fmav_rec.NAME AND VERSION = p_fmav_rec.VERSION)));

       INSERT INTO OKL_FORMULAE_TL
    	(
    	ID,
    	LANGUAGE,
    	SOURCE_LANG,
    	SFWT_FLAG,
    	DESCRIPTION,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN
    	)
    	SELECT  TO_NUMBER(p_fmav_rec.id),
    		L.LANGUAGE_CODE,
    		userenv('LANG'),
    		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
    		p_fmav_rec.DESCRIPTION,
    		f_luby,
    		f_ludate,
    		f_luby,
    		f_ludate,
    		0
    	FROM FND_LANGUAGES L
    	WHERE L.INSTALLED_FLAG IN ('I','B')
        	AND NOT EXISTS
              (SELECT NULL
               FROM   OKL_FORMULAE_TL TL
         	   WHERE  TL.ID = TO_NUMBER(p_fmav_rec.id)
               AND    TL.LANGUAGE = L.LANGUAGE_CODE);

    END LOAD_ROW;
 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode                   IN VARCHAR2,
    p_formulae_id                   IN VARCHAR2,
    p_name                          IN VARCHAR2,
    p_version                       IN VARCHAR2,
    p_org_id                        IN VARCHAR2,
    p_there_can_be_only_one_yn      IN VARCHAR2,
    p_cgr_id                        IN VARCHAR2,
    p_fyp_code                      IN VARCHAR2,
    p_formula_string                IN VARCHAR2,
    p_object_version_number         IN VARCHAR2,
    p_start_date                    IN VARCHAR2,
    p_end_date                      IN VARCHAR2,
    p_attribute_category            IN VARCHAR2,
    p_attribute1                    IN VARCHAR2,
    p_attribute2                    IN VARCHAR2,
    p_attribute3                    IN VARCHAR2,
    p_attribute4                    IN VARCHAR2,
    p_attribute5                    IN VARCHAR2,
    p_attribute6                    IN VARCHAR2,
    p_attribute7                    IN VARCHAR2,
    p_attribute8                    IN VARCHAR2,
    p_attribute9                    IN VARCHAR2,
    p_attribute10                   IN VARCHAR2,
    p_attribute11                   IN VARCHAR2,
    p_attribute12                   IN VARCHAR2,
    p_attribute13                   IN VARCHAR2,
    p_attribute14                   IN VARCHAR2,
    p_attribute15                   IN VARCHAR2,
    p_description                   IN VARCHAR2,
    p_owner                         IN VARCHAR2,
    p_last_update_date              IN VARCHAR2)IS

  l_api_version   CONSTANT number := 1;
  l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
  l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
  l_msg_count              number;
  l_msg_data               varchar2(4000);
  l_init_msg_list          VARCHAR2(1):= 'T';
  l_fmav_rec               fmav_rec_type;
  BEGIN
  --Prepare Record Structure for Insert/Update
   l_fmav_rec.id                      	:= 	p_formulae_id;
   l_fmav_rec.object_version_number   	:= 	p_object_version_number;
   l_fmav_rec.cgr_id                  	:= 	p_cgr_id;
   l_fmav_rec.fyp_code                	:= 	p_fyp_code;
   l_fmav_rec.name                    	:= 	p_name;
   l_fmav_rec.formula_string          	:= 	p_formula_string;
   l_fmav_rec.description             	:= 	p_description;
   l_fmav_rec.version                 	:= 	p_version;
   l_fmav_rec.start_date              	:= 	TO_DATE(p_start_date,'YYYY/MM/DD');
   l_fmav_rec.end_date                	:= 	TO_DATE(p_end_date,'YYYY/MM/DD');
   l_fmav_rec.attribute_category      	:= 	p_attribute_category;
   l_fmav_rec.attribute1              	:= 	p_attribute1;
   l_fmav_rec.attribute2              	:= 	p_attribute2;
   l_fmav_rec.attribute3              	:= 	p_attribute3;
   l_fmav_rec.attribute4              	:= 	p_attribute4;
   l_fmav_rec.attribute5              	:=	p_attribute5;
   l_fmav_rec.attribute6              	:= 	p_attribute6;
   l_fmav_rec.attribute7              	:= 	p_attribute7;
   l_fmav_rec.attribute8              	:= 	p_attribute8;
   l_fmav_rec.attribute9              	:= 	p_attribute9;
   l_fmav_rec.attribute10             	:= 	p_attribute10;
   l_fmav_rec.attribute11             	:= 	p_attribute11;
   l_fmav_rec.attribute12             	:= 	p_attribute12;
   l_fmav_rec.attribute13             	:= 	p_attribute13;
   l_fmav_rec.attribute14             	:= 	p_attribute14;
   l_fmav_rec.attribute15             	:= 	p_attribute15;
   l_fmav_rec.org_id                  	:= 	p_org_id;
   l_fmav_rec.there_can_be_only_one_yn	:= 	p_there_can_be_only_one_yn;

   IF(p_upload_mode = 'NLS') then
	 OKL_FMA_PVT.TRANSLATE_ROW(p_fmav_rec => l_fmav_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_FMA_PVT.LOAD_ROW(p_fmav_rec => l_fmav_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;
 END LOAD_SEED_ROW;

END OKL_FMA_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKL_PMR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PMR_PVT" AS
/* $Header: OKLSPMRB.pls 120.5 2007/01/09 08:43:02 abhsaxen noship $ */
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
    DELETE FROM OKL_PARAMETERS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_PARAMETERS_B B --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_PARAMETERS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_PARAMETERS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_PARAMETERS_TL SUBB, OKL_PARAMETERS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_PARAMETERS_TL (
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
        FROM OKL_PARAMETERS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_PARAMETERS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PARAMETERS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pmr_rec                      IN pmr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pmr_rec_type IS
    CURSOR okl_parameters_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            CUSTOMIZATION_LEVEL,
            DATATYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Parameters_B
     WHERE okl_parameters_b.id  = p_id;
    l_okl_parameters_b_pk          okl_parameters_b_pk_csr%ROWTYPE;
    l_pmr_rec                      pmr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_parameters_b_pk_csr (p_pmr_rec.id);
    FETCH okl_parameters_b_pk_csr INTO
              l_pmr_rec.ID,
              l_pmr_rec.NAME,
              l_pmr_rec.DATATYPE,
              l_pmr_rec.CUSTOMIZATION_LEVEL,
              l_pmr_rec.OBJECT_VERSION_NUMBER,
              l_pmr_rec.CREATED_BY,
              l_pmr_rec.CREATION_DATE,
              l_pmr_rec.LAST_UPDATED_BY,
              l_pmr_rec.LAST_UPDATE_DATE,
              l_pmr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_parameters_b_pk_csr%NOTFOUND;
    CLOSE okl_parameters_b_pk_csr;
    RETURN(l_pmr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pmr_rec                      IN pmr_rec_type
  ) RETURN pmr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pmr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PARAMETERS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_parameters_tl_rec_type IS
    CURSOR okl_parameters_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Parameters_Tl
     WHERE okl_parameters_tl.id = p_id
       AND okl_parameters_tl.language = p_language;
    l_okl_parameters_tl_pk         okl_parameters_tl_pk_csr%ROWTYPE;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_parameters_tl_pk_csr (p_okl_parameters_tl_rec.id,
                                   p_okl_parameters_tl_rec.language);
    FETCH okl_parameters_tl_pk_csr INTO
              l_okl_parameters_tl_rec.ID,
              l_okl_parameters_tl_rec.LANGUAGE,
              l_okl_parameters_tl_rec.SOURCE_LANG,
              l_okl_parameters_tl_rec.SFWT_FLAG,
              l_okl_parameters_tl_rec.DESCRIPTION,
              l_okl_parameters_tl_rec.CREATED_BY,
              l_okl_parameters_tl_rec.CREATION_DATE,
              l_okl_parameters_tl_rec.LAST_UPDATED_BY,
              l_okl_parameters_tl_rec.LAST_UPDATE_DATE,
              l_okl_parameters_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_parameters_tl_pk_csr%NOTFOUND;
    CLOSE okl_parameters_tl_pk_csr;
    RETURN(l_okl_parameters_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type
  ) RETURN okl_parameters_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_parameters_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PARAMETERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pmrv_rec                     IN pmrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pmrv_rec_type IS
    CURSOR okl_pmrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            CUSTOMIZATION_LEVEL,
            DATATYPE,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Parameters_V
     WHERE okl_parameters_v.id  = p_id;
    l_okl_pmrv_pk                  okl_pmrv_pk_csr%ROWTYPE;
    l_pmrv_rec                     pmrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pmrv_pk_csr (p_pmrv_rec.id);
    FETCH okl_pmrv_pk_csr INTO
              l_pmrv_rec.ID,
              l_pmrv_rec.OBJECT_VERSION_NUMBER,
              l_pmrv_rec.SFWT_FLAG,
              l_pmrv_rec.NAME,
              l_pmrv_rec.CUSTOMIZATION_LEVEL,
              l_pmrv_rec.DATATYPE,
              l_pmrv_rec.DESCRIPTION,
              l_pmrv_rec.CREATED_BY,
              l_pmrv_rec.CREATION_DATE,
              l_pmrv_rec.LAST_UPDATED_BY,
              l_pmrv_rec.LAST_UPDATE_DATE,
              l_pmrv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pmrv_pk_csr%NOTFOUND;
    CLOSE okl_pmrv_pk_csr;
    RETURN(l_pmrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pmrv_rec                     IN pmrv_rec_type
  ) RETURN pmrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pmrv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PARAMETERS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pmrv_rec	IN pmrv_rec_type
  ) RETURN pmrv_rec_type IS
    l_pmrv_rec	pmrv_rec_type := p_pmrv_rec;
  BEGIN
    IF (l_pmrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pmrv_rec.object_version_number := NULL;
    END IF;
    IF (l_pmrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_pmrv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_pmrv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_pmrv_rec.name := NULL;
    END IF;
    IF (l_pmrv_rec.CUSTOMIZATION_LEVEL = OKC_API.G_MISS_CHAR) THEN
      l_pmrv_rec.CUSTOMIZATION_LEVEL := NULL;
    END IF;
    IF (l_pmrv_rec.datatype = OKC_API.G_MISS_CHAR) THEN
      l_pmrv_rec.datatype := NULL;
    END IF;
    IF (l_pmrv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_pmrv_rec.description := NULL;
    END IF;
    IF (l_pmrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pmrv_rec.created_by := NULL;
    END IF;
    IF (l_pmrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pmrv_rec.creation_date := NULL;
    END IF;
    IF (l_pmrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pmrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pmrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pmrv_rec.last_update_date := NULL;
    END IF;
    IF (l_pmrv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pmrv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pmrv_rec);
  END null_out_defaults;

  /** Commented out nocopy generated code in favor of hand written code *** SBALASHA001 Start ***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_PARAMETERS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_pmrv_rec IN  pmrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pmrv_rec.id = OKC_API.G_MISS_NUM OR
       p_pmrv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pmrv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_pmrv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pmrv_rec.name = OKC_API.G_MISS_CHAR OR
          p_pmrv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pmrv_rec.CUSTOMIZATION_LEVEL = OKC_API.G_MISS_CHAR OR
          p_pmrv_rec.CUSTOMIZATION_LEVEL IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'customization_level');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pmrv_rec.datatype = OKC_API.G_MISS_CHAR OR
          p_pmrv_rec.datatype IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'datatype');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_PARAMETERS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_pmrv_rec IN pmrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  *** SBALASHA001 End *** **/




  /** SBALASHA001 Start *** -
      INFO: hand coded function related to validate_attribute  **/

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
                                          ,p_pmrv_rec      IN   pmrv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ( p_pmrv_rec.object_version_number IS NULL ) OR
       ( p_pmrv_rec.object_version_Number = OKC_API.G_MISS_NUM ) THEN
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
                              p_pmrv_rec      IN   pmrv_rec_type)
  IS

  -- l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_return_status         VARCHAR2(1)  := OKL_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      -- l_return_status := OKL_UTIL.check_domain_yn(p_pmrv_rec.sfwt_flag);
      l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_pmrv_rec.sfwt_flag,0,0);

      -- IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      IF (l_return_status = OKL_API.G_FALSE) THEN
	       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'sfwt_flag' );
 	      x_return_status    := OKC_API.G_RET_STS_ERROR;
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
                              p_pmrv_rec      IN   pmrv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pmrv_rec.name IS NULL) OR
       (p_pmrv_rec.name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'name' );
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

  END Validate_Name;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Data_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Data_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Data_Type(x_return_status OUT NOCOPY     VARCHAR2
                              ,p_pmrv_rec      IN      pmrv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pmrv_rec.datatype IS NULL) OR
       (p_pmrv_rec.datatype = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'datatype');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- verify that data is uppercase
      IF (p_pmrv_rec.datatype) <> UPPER(p_pmrv_rec.datatype) THEN
         OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                            ,p_msg_name        => g_uppercase_required
                            ,p_token1          => g_col_name_token
                            ,p_token1_value    => 'datatype');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check for valid data_type
    IF (UPPER(p_pmrv_rec.datatype) NOT IN ('CHAR','NUMBER','DATE')) THEN
         OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => g_invalid_value
                            ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'datatype');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Data_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Customization_level
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Customization_level
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Customization_level(x_return_status OUT NOCOPY     VARCHAR2
                              ,p_pmrv_rec      IN      pmrv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pmrv_rec.Customization_level IS NULL) OR
       (p_pmrv_rec.Customization_level = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Customization_level');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*
      -- verify that data is uppercase
      IF (p_pmrv_rec.Customization_level) <> UPPER(p_pmrv_rec.Customization_level) THEN
         OKC_API.SET_MESSAGE(p_app_name        => g_app_name
                            ,p_msg_name        => g_uppercase_required
                            ,p_token1          => g_col_name_token
                            ,p_token1_value    => 'Customization_level');

         -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -- check for valid data_type
    IF (UPPER(p_pmrv_rec.Customization_level) NOT IN ('S','U')) THEN
         OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                            ,p_msg_name       => g_invalid_value
                            ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'Customization_level');
         x_return_status    := OKC_API.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
*/
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Customization_level;



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
    p_pmrv_rec IN  pmrv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	-- Validate Foreign Keys
	-- INFO: There are no foreign keys for this table.

  	-- call each column-level validation

	-- Validate ID
    IF p_pmrv_rec.id = OKC_API.G_MISS_NUM OR
       p_pmrv_rec.id IS NULL
    THEN
      OKC_API.set_message( G_APP_NAME,
	  					  G_REQUIRED_VALUE,
						  G_COL_NAME_TOKEN, 'id' );
      l_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;

	-- Valid object_version_number
	IF ( p_pmrv_rec.object_version_number IS NOT NULL ) AND
	( p_pmrv_rec.object_version_number <> OKC_API.G_MISS_NUM ) THEN
		Validate_Object_Version_Number( x_return_status, p_pmrv_rec );
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
	IF ( p_pmrv_rec.sfwt_flag IS NOT NULL ) AND
	( p_pmrv_rec.sfwt_flag <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Sfwt_Flag( x_return_status, p_pmrv_rec );
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


	-- Valid name
	IF ( p_pmrv_rec.name IS NOT NULL ) AND
	( p_pmrv_rec.name <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Name( x_return_status, p_pmrv_rec );
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

	-- Valid datatype
	IF ( p_pmrv_rec.datatype IS NOT NULL ) AND
	( p_pmrv_rec.datatype <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Data_Type( x_return_status, p_pmrv_rec );
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

	-- Valid customization_level
	IF ( p_pmrv_rec.customization_level IS NOT NULL ) AND
	( p_pmrv_rec.customization_level <> OKC_API.G_MISS_CHAR ) THEN
		Validate_customization_level( x_return_status, p_pmrv_rec );
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
  -- PROCEDURE Validate_Unique_Pmr_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pmr_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Pmr_Record(
                                  x_return_status OUT NOCOPY     VARCHAR2,
                                  p_pmrv_rec      IN      pmrv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1( p_id okl_parameters_v.id%TYPE,
			p_name okl_parameters_v.name%TYPE ) is
  SELECT 1
  FROM okl_parameters_v
  WHERE  id = p_id
  AND name = p_name
  AND    id <> nvl( p_pmrv_rec.id, -9999 );

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN c1( p_pmrv_rec.id, p_pmrv_rec.name );
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    /* RPOONUGA001: Changed the token name from G_TABLE_NAME to G_TABLE_TOKEN */
    IF l_row_found then
		OKC_API.set_message( G_APP_NAME, G_UNQS, G_TABLE_TOKEN, 'Okl_Parameters_V' );
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

  END Validate_Unique_Pmr_Record;


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
    p_pmrv_rec IN pmrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	-- Validate_Unique_Pmr_Record
	Validate_Unique_Pmr_Record( x_return_status, p_pmrv_rec );
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

  END Validate_Record;


/** *** SBALASHA002 End *** **/





  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pmrv_rec_type,
    p_to	IN OUT NOCOPY pmr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.customization_level := p_from.customization_level;
    p_to.datatype := p_from.datatype;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pmr_rec_type,
    p_to	OUT NOCOPY pmrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.customization_level := p_from.customization_level;
    p_to.datatype := p_from.datatype;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pmrv_rec_type,
    p_to	OUT NOCOPY okl_parameters_tl_rec_type
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
    p_from	IN okl_parameters_tl_rec_type,
    p_to	OUT NOCOPY pmrv_rec_type
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
  ---------------------------------------
  -- validate_row for:OKL_PARAMETERS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_rec                     IN pmrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmrv_rec                     pmrv_rec_type := p_pmrv_rec;
    l_pmr_rec                      pmr_rec_type;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_pmrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pmrv_rec);
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
  -- PL/SQL TBL validate_row for:PMRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_tbl                     IN pmrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmrv_tbl.COUNT > 0) THEN
      i := p_pmrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pmrv_rec                     => p_pmrv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_pmrv_tbl.LAST);
        i := p_pmrv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  -------------------------------------
  -- insert_row for:OKL_PARAMETERS_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmr_rec                      IN pmr_rec_type,
    x_pmr_rec                      OUT NOCOPY pmr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmr_rec                      pmr_rec_type := p_pmr_rec;
    l_def_pmr_rec                  pmr_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pmr_rec IN  pmr_rec_type,
      x_pmr_rec OUT NOCOPY pmr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmr_rec := p_pmr_rec;
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
      p_pmr_rec,                         -- IN
      l_pmr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PARAMETERS_B(
        id,
        name,
        datatype,
        object_version_number,
        customization_level,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_pmr_rec.id,
        l_pmr_rec.name,
        l_pmr_rec.datatype,
        l_pmr_rec.object_version_number,
        l_pmr_rec.customization_level,
        l_pmr_rec.created_by,
        l_pmr_rec.creation_date,
        l_pmr_rec.last_updated_by,
        l_pmr_rec.last_update_date,
        l_pmr_rec.last_update_login);
    -- Set OUT values
    x_pmr_rec := l_pmr_rec;
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
  -- insert_row for:OKL_PARAMETERS_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type,
    x_okl_parameters_tl_rec        OUT NOCOPY okl_parameters_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type := p_okl_parameters_tl_rec;
    l_def_okl_parameters_tl_rec    okl_parameters_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_parameters_tl_rec IN  okl_parameters_tl_rec_type,
      x_okl_parameters_tl_rec OUT NOCOPY okl_parameters_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_parameters_tl_rec := p_okl_parameters_tl_rec;
      x_okl_parameters_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_parameters_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_parameters_tl_rec,           -- IN
      l_okl_parameters_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_parameters_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_PARAMETERS_TL(
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
          l_okl_parameters_tl_rec.id,
          l_okl_parameters_tl_rec.language,
          l_okl_parameters_tl_rec.source_lang,
          l_okl_parameters_tl_rec.sfwt_flag,
          l_okl_parameters_tl_rec.description,
          l_okl_parameters_tl_rec.created_by,
          l_okl_parameters_tl_rec.creation_date,
          l_okl_parameters_tl_rec.last_updated_by,
          l_okl_parameters_tl_rec.last_update_date,
          l_okl_parameters_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_parameters_tl_rec := l_okl_parameters_tl_rec;
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
  -------------------------------------
  -- insert_row for:OKL_PARAMETERS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_rec                     IN pmrv_rec_type,
    x_pmrv_rec                     OUT NOCOPY pmrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmrv_rec                     pmrv_rec_type;
    l_def_pmrv_rec                 pmrv_rec_type;
    l_pmr_rec                      pmr_rec_type;
    lx_pmr_rec                     pmr_rec_type;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
    lx_okl_parameters_tl_rec       okl_parameters_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pmrv_rec	IN pmrv_rec_type
    ) RETURN pmrv_rec_type IS
      l_pmrv_rec	pmrv_rec_type := p_pmrv_rec;
    BEGIN
      l_pmrv_rec.CREATION_DATE := SYSDATE;
      l_pmrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pmrv_rec.LAST_UPDATE_DATE := l_pmrv_rec.CREATION_DATE;
      l_pmrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pmrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pmrv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pmrv_rec IN  pmrv_rec_type,
      x_pmrv_rec OUT NOCOPY pmrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmrv_rec := p_pmrv_rec;
      x_pmrv_rec.OBJECT_VERSION_NUMBER := 1;
      x_pmrv_rec.SFWT_FLAG := 'N';
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
    l_pmrv_rec := null_out_defaults(p_pmrv_rec);
    -- Set primary key value
    l_pmrv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pmrv_rec,                        -- IN
      l_def_pmrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pmrv_rec := fill_who_columns(l_def_pmrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pmrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pmrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pmrv_rec, l_pmr_rec);
    migrate(l_def_pmrv_rec, l_okl_parameters_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pmr_rec,
      lx_pmr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pmr_rec, l_def_pmrv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_parameters_tl_rec,
      lx_okl_parameters_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_parameters_tl_rec, l_def_pmrv_rec);
    -- Set OUT values
    x_pmrv_rec := l_def_pmrv_rec;
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
  -- PL/SQL TBL insert_row for:PMRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_tbl                     IN pmrv_tbl_type,
    x_pmrv_tbl                     OUT NOCOPY pmrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmrv_tbl.COUNT > 0) THEN
      i := p_pmrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pmrv_rec                     => p_pmrv_tbl(i),
          x_pmrv_rec                     => x_pmrv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_pmrv_tbl.LAST);
        i := p_pmrv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  -----------------------------------
  -- lock_row for:OKL_PARAMETERS_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmr_rec                      IN pmr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pmr_rec IN pmr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PARAMETERS_B
     WHERE ID = p_pmr_rec.id
       AND OBJECT_VERSION_NUMBER = p_pmr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pmr_rec IN pmr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PARAMETERS_B
    WHERE ID = p_pmr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PARAMETERS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PARAMETERS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pmr_rec);
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
      OPEN lchk_csr(p_pmr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pmr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pmr_rec.object_version_number THEN
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
  -- lock_row for:OKL_PARAMETERS_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_parameters_tl_rec IN okl_parameters_tl_rec_type) IS
    SELECT *
      FROM OKL_PARAMETERS_TL
     WHERE ID = p_okl_parameters_tl_rec.id
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
      OPEN lock_csr(p_okl_parameters_tl_rec);
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
  -----------------------------------
  -- lock_row for:OKL_PARAMETERS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_rec                     IN pmrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmr_rec                      pmr_rec_type;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
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
    migrate(p_pmrv_rec, l_pmr_rec);
    migrate(p_pmrv_rec, l_okl_parameters_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pmr_rec
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
      l_okl_parameters_tl_rec
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
  -- PL/SQL TBL lock_row for:PMRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_tbl                     IN pmrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmrv_tbl.COUNT > 0) THEN
      i := p_pmrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pmrv_rec                     => p_pmrv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_pmrv_tbl.LAST);
        i := p_pmrv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  -------------------------------------
  -- update_row for:OKL_PARAMETERS_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmr_rec                      IN pmr_rec_type,
    x_pmr_rec                      OUT NOCOPY pmr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmr_rec                      pmr_rec_type := p_pmr_rec;
    l_def_pmr_rec                  pmr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pmr_rec	IN pmr_rec_type,
      x_pmr_rec	OUT NOCOPY pmr_rec_type
    ) RETURN VARCHAR2 IS
      l_pmr_rec                      pmr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmr_rec := p_pmr_rec;
      -- Get current database values
      l_pmr_rec := get_rec(p_pmr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pmr_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pmr_rec.id := l_pmr_rec.id;
      END IF;
      IF (x_pmr_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pmr_rec.name := l_pmr_rec.name;
      END IF;
      IF (x_pmr_rec.datatype = OKC_API.G_MISS_CHAR)
      THEN
        x_pmr_rec.datatype := l_pmr_rec.datatype;
      END IF;
      IF (x_pmr_rec.customization_level = OKC_API.G_MISS_CHAR)
      THEN
        x_pmr_rec.customization_level := l_pmr_rec.customization_level;
      END IF;
      IF (x_pmr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pmr_rec.object_version_number := l_pmr_rec.object_version_number;
      END IF;
      IF (x_pmr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pmr_rec.created_by := l_pmr_rec.created_by;
      END IF;
      IF (x_pmr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pmr_rec.creation_date := l_pmr_rec.creation_date;
      END IF;
      IF (x_pmr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pmr_rec.last_updated_by := l_pmr_rec.last_updated_by;
      END IF;
      IF (x_pmr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pmr_rec.last_update_date := l_pmr_rec.last_update_date;
      END IF;
      IF (x_pmr_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pmr_rec.last_update_login := l_pmr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pmr_rec IN  pmr_rec_type,
      x_pmr_rec OUT NOCOPY pmr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmr_rec := p_pmr_rec;
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
      p_pmr_rec,                         -- IN
      l_pmr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pmr_rec, l_def_pmr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PARAMETERS_B
    SET DATATYPE = l_def_pmr_rec.datatype,
        CUSTOMIZATION_LEVEL = l_def_pmr_rec.customization_level,
        NAME = l_def_pmr_rec.name,
        OBJECT_VERSION_NUMBER = l_def_pmr_rec.object_version_number,
        CREATED_BY = l_def_pmr_rec.created_by,
        CREATION_DATE = l_def_pmr_rec.creation_date,
        LAST_UPDATED_BY = l_def_pmr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pmr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pmr_rec.last_update_login
    WHERE ID = l_def_pmr_rec.id;

    x_pmr_rec := l_def_pmr_rec;
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
  -- update_row for:OKL_PARAMETERS_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type,
    x_okl_parameters_tl_rec        OUT NOCOPY okl_parameters_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type := p_okl_parameters_tl_rec;
    l_def_okl_parameters_tl_rec    okl_parameters_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_parameters_tl_rec	IN okl_parameters_tl_rec_type,
      x_okl_parameters_tl_rec	OUT NOCOPY okl_parameters_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_parameters_tl_rec := p_okl_parameters_tl_rec;
      -- Get current database values
      l_okl_parameters_tl_rec := get_rec(p_okl_parameters_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_parameters_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_parameters_tl_rec.id := l_okl_parameters_tl_rec.id;
      END IF;
      IF (x_okl_parameters_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_parameters_tl_rec.language := l_okl_parameters_tl_rec.language;
      END IF;
      IF (x_okl_parameters_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_parameters_tl_rec.source_lang := l_okl_parameters_tl_rec.source_lang;
      END IF;
      IF (x_okl_parameters_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_parameters_tl_rec.sfwt_flag := l_okl_parameters_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_parameters_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_parameters_tl_rec.description := l_okl_parameters_tl_rec.description;
      END IF;
      IF (x_okl_parameters_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_parameters_tl_rec.created_by := l_okl_parameters_tl_rec.created_by;
      END IF;
      IF (x_okl_parameters_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_parameters_tl_rec.creation_date := l_okl_parameters_tl_rec.creation_date;
      END IF;
      IF (x_okl_parameters_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_parameters_tl_rec.last_updated_by := l_okl_parameters_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_parameters_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_parameters_tl_rec.last_update_date := l_okl_parameters_tl_rec.last_update_date;
      END IF;
      IF (x_okl_parameters_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_parameters_tl_rec.last_update_login := l_okl_parameters_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_parameters_tl_rec IN  okl_parameters_tl_rec_type,
      x_okl_parameters_tl_rec OUT NOCOPY okl_parameters_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_parameters_tl_rec := p_okl_parameters_tl_rec;
      x_okl_parameters_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_parameters_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_parameters_tl_rec,           -- IN
      l_okl_parameters_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_parameters_tl_rec, l_def_okl_parameters_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PARAMETERS_TL
    SET
        DESCRIPTION = l_def_okl_parameters_tl_rec.description,
        CREATED_BY = l_def_okl_parameters_tl_rec.created_by,
        SOURCE_LANG = l_def_okl_parameters_tl_rec.source_lang,
        CREATION_DATE = l_def_okl_parameters_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_parameters_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_parameters_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_parameters_tl_rec.last_update_login
    WHERE ID = l_def_okl_parameters_tl_rec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_PARAMETERS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_parameters_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_parameters_tl_rec := l_def_okl_parameters_tl_rec;
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
  -------------------------------------
  -- update_row for:OKL_PARAMETERS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_rec                     IN pmrv_rec_type,
    x_pmrv_rec                     OUT NOCOPY pmrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmrv_rec                     pmrv_rec_type := p_pmrv_rec;
    l_def_pmrv_rec                 pmrv_rec_type;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
    lx_okl_parameters_tl_rec       okl_parameters_tl_rec_type;
    l_pmr_rec                      pmr_rec_type;
    lx_pmr_rec                     pmr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pmrv_rec	IN pmrv_rec_type
    ) RETURN pmrv_rec_type IS
      l_pmrv_rec	pmrv_rec_type := p_pmrv_rec;
    BEGIN
      l_pmrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pmrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pmrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pmrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pmrv_rec	IN pmrv_rec_type,
      x_pmrv_rec	OUT NOCOPY pmrv_rec_type
    ) RETURN VARCHAR2 IS
      l_pmrv_rec                     pmrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmrv_rec := p_pmrv_rec;
      -- Get current database values
      l_pmrv_rec := get_rec(p_pmrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pmrv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pmrv_rec.id := l_pmrv_rec.id;
      END IF;
      IF (x_pmrv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pmrv_rec.object_version_number := l_pmrv_rec.object_version_number;
      END IF;
      IF (x_pmrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pmrv_rec.sfwt_flag := l_pmrv_rec.sfwt_flag;
      END IF;
      IF (x_pmrv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pmrv_rec.name := l_pmrv_rec.name;
      END IF;
      IF (x_pmrv_rec.datatype = OKC_API.G_MISS_CHAR)
      THEN
        x_pmrv_rec.datatype := l_pmrv_rec.datatype;
      END IF;
      IF (x_pmrv_rec.customization_level = OKC_API.G_MISS_CHAR)
      THEN
        x_pmrv_rec.customization_level  := l_pmrv_rec.customization_level ;
      END IF;
      IF (x_pmrv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_pmrv_rec.description := l_pmrv_rec.description;
      END IF;
      IF (x_pmrv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pmrv_rec.created_by := l_pmrv_rec.created_by;
      END IF;
      IF (x_pmrv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pmrv_rec.creation_date := l_pmrv_rec.creation_date;
      END IF;
      IF (x_pmrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pmrv_rec.last_updated_by := l_pmrv_rec.last_updated_by;
      END IF;
      IF (x_pmrv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pmrv_rec.last_update_date := l_pmrv_rec.last_update_date;
      END IF;
      IF (x_pmrv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pmrv_rec.last_update_login := l_pmrv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pmrv_rec IN  pmrv_rec_type,
      x_pmrv_rec OUT NOCOPY pmrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmrv_rec := p_pmrv_rec;
      x_pmrv_rec.OBJECT_VERSION_NUMBER := NVL(x_pmrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_pmrv_rec,                        -- IN
      l_pmrv_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_pmrv_rec, l_def_pmrv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_pmrv_rec := fill_who_columns(l_def_pmrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pmrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pmrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pmrv_rec, l_okl_parameters_tl_rec);
    migrate(l_def_pmrv_rec, l_pmr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_parameters_tl_rec,
      lx_okl_parameters_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_parameters_tl_rec, l_def_pmrv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pmr_rec,
      lx_pmr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pmr_rec, l_def_pmrv_rec);
    x_pmrv_rec := l_def_pmrv_rec;
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
  -- PL/SQL TBL update_row for:PMRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_tbl                     IN pmrv_tbl_type,
    x_pmrv_tbl                     OUT NOCOPY pmrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmrv_tbl.COUNT > 0) THEN
      i := p_pmrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pmrv_rec                     => p_pmrv_tbl(i),
          x_pmrv_rec                     => x_pmrv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_pmrv_tbl.LAST);
        i := p_pmrv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  -------------------------------------
  -- delete_row for:OKL_PARAMETERS_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmr_rec                      IN pmr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmr_rec                      pmr_rec_type:= p_pmr_rec;
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
    DELETE FROM OKL_PARAMETERS_B
     WHERE ID = l_pmr_rec.id;

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
  -- delete_row for:OKL_PARAMETERS_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_parameters_tl_rec        IN okl_parameters_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type:= p_okl_parameters_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKL_PARAMETERS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_parameters_tl_rec IN  okl_parameters_tl_rec_type,
      x_okl_parameters_tl_rec OUT NOCOPY okl_parameters_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_parameters_tl_rec := p_okl_parameters_tl_rec;
      x_okl_parameters_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_parameters_tl_rec,           -- IN
      l_okl_parameters_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_PARAMETERS_TL
     WHERE ID = l_okl_parameters_tl_rec.id;

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
  -------------------------------------
  -- delete_row for:OKL_PARAMETERS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_rec                     IN pmrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmrv_rec                     pmrv_rec_type := p_pmrv_rec;
    l_okl_parameters_tl_rec        okl_parameters_tl_rec_type;
    l_pmr_rec                      pmr_rec_type;
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
    migrate(l_pmrv_rec, l_okl_parameters_tl_rec);
    migrate(l_pmrv_rec, l_pmr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_parameters_tl_rec
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
      l_pmr_rec
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
  -- PL/SQL TBL delete_row for:PMRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmrv_tbl                     IN pmrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmrv_tbl.COUNT > 0) THEN
      i := p_pmrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pmrv_rec                     => p_pmrv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_pmrv_tbl.LAST);
        i := p_pmrv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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

  PROCEDURE TRANSLATE_ROW(p_pmrv_rec IN pmrv_rec_type,
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
      FROM OKL_PARAMETERS_TL
      where ID = to_number(p_pmrv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then

   	 UPDATE OKL_PARAMETERS_TL
   	 SET	 DESCRIPTION       = p_pmrv_rec.description,
        	 LAST_UPDATE_DATE  = f_ludate,
         	LAST_UPDATED_BY   = f_luby,
	         LAST_UPDATE_LOGIN = 0,
	         SOURCE_LANG       = USERENV('LANG')
	    WHERE ID = to_number(p_pmrv_rec.id)
	      AND USERENV('LANG') IN (language,source_lang);
     END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_pmrv_rec IN pmrv_rec_type,
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
      FROM OKL_PARAMETERS_B
      where ID = p_pmrv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
        UPDATE OKL_PARAMETERS_B
        SET
         DATATYPE 		       = p_pmrv_rec.datatype,
	     OBJECT_VERSION_NUMBER = TO_NUMBER(p_pmrv_rec.object_version_number),
	     CUSTOMIZATION_LEVEL   = p_pmrv_rec.customization_level,
         LAST_UPDATE_DATE      = f_ludate,
         LAST_UPDATED_BY       = f_luby,
         LAST_UPDATE_LOGIN     = 0
        WHERE ID = to_number(p_pmrv_rec.id);
       --Update _TL
       UPDATE OKL_PARAMETERS_TL
       SET	DESCRIPTION       = p_pmrv_rec.description,
            LAST_UPDATE_DATE  = f_ludate,
            LAST_UPDATED_BY   = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG       = USERENV('LANG')
       WHERE ID = to_number(p_pmrv_rec.id)
        AND  USERENV('LANG') IN (language,source_lang);

       IF(sql%notfound) THEN

         INSERT INTO OKL_PARAMETERS_TL
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
         TO_NUMBER(p_pmrv_rec.id),
		 L.LANGUAGE_CODE,
		 userenv('LANG'),
		 decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
		 p_pmrv_rec.DESCRIPTION,
		 f_luby,
		 f_ludate,
		 f_luby,
		 f_ludate,
		 0
	    FROM FND_LANGUAGES L
	    WHERE L.INSTALLED_FLAG IN ('I','B')
    	 AND NOT EXISTS
          (SELECT NULL
           FROM   OKL_PARAMETERS_TL TL
     	   WHERE  TL.ID = TO_NUMBER(p_pmrv_rec.id)
           AND    TL.LANGUAGE = L.LANGUAGE_CODE);
       END IF;
      END IF;

    END;
    EXCEPTION
     when no_data_found then
     INSERT INTO OKL_PARAMETERS_B
	 (
    	ID,
    	NAME,
    	DATATYPE,
    	OBJECT_VERSION_NUMBER,
    	CUSTOMIZATION_LEVEL,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN
	  )
     SELECT
    	TO_NUMBER(p_pmrv_rec.id),
    	p_pmrv_rec.name,
    	p_pmrv_rec.datatype,
    	TO_NUMBER(p_pmrv_rec.object_version_number),
    	p_pmrv_rec.customization_level,
    	f_luby,
    	f_ludate,
    	f_luby,
    	f_ludate,
    	0
     FROM DUAL
      WHERE NOT EXISTS (SELECT 1
         from OKL_PARAMETERS_B
         where ( ID = TO_NUMBER(p_pmrv_rec.id)  OR (NAME = p_pmrv_rec.name)));

     INSERT INTO OKL_PARAMETERS_TL
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
	 SELECT  TO_NUMBER(p_pmrv_rec.id),
		L.LANGUAGE_CODE,
		userenv('LANG'),
		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
		p_pmrv_rec.description,
		f_luby,
		f_ludate,
		f_luby,
		f_ludate,
		0
	 FROM FND_LANGUAGES L
	 WHERE L.INSTALLED_FLAG IN ('I','B')
    	AND NOT EXISTS
          (SELECT NULL
           FROM   OKL_PARAMETERS_TL TL
     	   WHERE  TL.ID = TO_NUMBER(p_pmrv_rec.id)
           AND    TL.LANGUAGE = L.LANGUAGE_CODE);

   END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode            IN VARCHAR2,
    p_parameter_id           IN VARCHAR2,
    p_name                   IN VARCHAR2,
    p_datatype               IN VARCHAR2,
    p_object_version_number  IN VARCHAR2,
    p_customization_level    IN VARCHAR2,
    p_description            IN VARCHAR2,
    p_owner                  IN VARCHAR2,
    p_last_update_date       IN VARCHAR2)IS

    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_init_msg_list          VARCHAR2(1):= 'T';
    l_pmrv_rec               pmrv_rec_type;

  BEGIN
  --Prepare Record Structure for Insert/Update
    l_pmrv_rec.id                    := p_parameter_id;
    l_pmrv_rec.object_version_number := p_object_version_number;
    l_pmrv_rec.customization_level   := p_customization_level;
    l_pmrv_rec.name                  := p_name;
    l_pmrv_rec.datatype              := p_datatype;
    l_pmrv_rec.description           := p_description;

   IF(p_upload_mode = 'NLS') then
	 OKL_PMR_PVT.TRANSLATE_ROW(p_pmrv_rec => l_pmrv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_PMR_PVT.LOAD_ROW(p_pmrv_rec => l_pmrv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;
  END LOAD_SEED_ROW;

END OKL_PMR_PVT;

/

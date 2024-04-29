--------------------------------------------------------
--  DDL for Package Body OKL_OPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPD_PVT" AS
/* $Header: OKLSOPDB.pls 120.6 2007/01/09 08:42:47 abhsaxen noship $ */

  --Added by kthiruva for Pricing Enhancements
  G_INCORRECT_FUNC_TYPE CONSTANT VARCHAR2(200) := 'OKL_OPRND_INCORRECT_FUNCTION';
  --End of Changes for Pricing Enhancements

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
    DELETE FROM OKL_OPERANDS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_OPERANDS_B B    --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_OPERANDS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_OPERANDS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_OPERANDS_TL SUBB, OKL_OPERANDS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_OPERANDS_TL (
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
        FROM OKL_OPERANDS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_OPERANDS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPERANDS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_opd_rec                      IN opd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN opd_rec_type IS
    CURSOR okl_operands_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            FMA_ID,
            DSF_ID,
            VERSION,
            OPD_TYPE,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            START_DATE,
            SOURCE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            END_DATE
      FROM Okl_Operands_B
     WHERE okl_operands_b.id    = p_id;
    l_okl_operands_b_pk            okl_operands_b_pk_csr%ROWTYPE;
    l_opd_rec                      opd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_operands_b_pk_csr (p_opd_rec.id);
    FETCH okl_operands_b_pk_csr INTO
              l_opd_rec.ID,
              l_opd_rec.NAME,
              l_opd_rec.FMA_ID,
              l_opd_rec.DSF_ID,
              l_opd_rec.VERSION,
              l_opd_rec.OPD_TYPE,
              l_opd_rec.OBJECT_VERSION_NUMBER,
              l_opd_rec.ORG_ID,
              l_opd_rec.START_DATE,
              l_opd_rec.SOURCE,
              l_opd_rec.CREATED_BY,
              l_opd_rec.CREATION_DATE,
              l_opd_rec.LAST_UPDATED_BY,
              l_opd_rec.LAST_UPDATE_DATE,
              l_opd_rec.LAST_UPDATE_LOGIN,
              l_opd_rec.END_DATE;
    x_no_data_found := okl_operands_b_pk_csr%NOTFOUND;
    CLOSE okl_operands_b_pk_csr;
    RETURN(l_opd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_opd_rec                      IN opd_rec_type
  ) RETURN opd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_opd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPERANDS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_operands_tl_rec_type IS
    CURSOR okl_operands_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Operands_Tl
     WHERE okl_operands_tl.id   = p_id
       AND okl_operands_tl.language = p_language;
    l_okl_operands_tl_pk           okl_operands_tl_pk_csr%ROWTYPE;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_operands_tl_pk_csr (p_okl_operands_tl_rec.id,
                                 p_okl_operands_tl_rec.language);
    FETCH okl_operands_tl_pk_csr INTO
              l_okl_operands_tl_rec.ID,
              l_okl_operands_tl_rec.LANGUAGE,
              l_okl_operands_tl_rec.SOURCE_LANG,
              l_okl_operands_tl_rec.SFWT_FLAG,
              l_okl_operands_tl_rec.DESCRIPTION,
              l_okl_operands_tl_rec.CREATED_BY,
              l_okl_operands_tl_rec.CREATION_DATE,
              l_okl_operands_tl_rec.LAST_UPDATED_BY,
              l_okl_operands_tl_rec.LAST_UPDATE_DATE,
              l_okl_operands_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_operands_tl_pk_csr%NOTFOUND;
    CLOSE okl_operands_tl_pk_csr;
    RETURN(l_okl_operands_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type
  ) RETURN okl_operands_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_operands_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPERANDS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_opdv_rec                     IN opdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN opdv_rec_type IS
    CURSOR okl_opdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            FMA_ID,
            DSF_ID,
            NAME,
            DESCRIPTION,
            VERSION,
            START_DATE,
            END_DATE,
            SOURCE,
            OPD_TYPE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Operands_V
     WHERE okl_operands_v.id    = p_id;
    l_okl_opdv_pk                  okl_opdv_pk_csr%ROWTYPE;
    l_opdv_rec                     opdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_opdv_pk_csr (p_opdv_rec.id);
    FETCH okl_opdv_pk_csr INTO
              l_opdv_rec.ID,
              l_opdv_rec.OBJECT_VERSION_NUMBER,
              l_opdv_rec.SFWT_FLAG,
              l_opdv_rec.FMA_ID,
              l_opdv_rec.DSF_ID,
              l_opdv_rec.NAME,
              l_opdv_rec.DESCRIPTION,
              l_opdv_rec.VERSION,
              l_opdv_rec.START_DATE,
              l_opdv_rec.END_DATE,
              l_opdv_rec.SOURCE,
              l_opdv_rec.OPD_TYPE,
              l_opdv_rec.ORG_ID,
              l_opdv_rec.CREATED_BY,
              l_opdv_rec.CREATION_DATE,
              l_opdv_rec.LAST_UPDATED_BY,
              l_opdv_rec.LAST_UPDATE_DATE,
              l_opdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_opdv_pk_csr%NOTFOUND;
    CLOSE okl_opdv_pk_csr;
    RETURN(l_opdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_opdv_rec                     IN opdv_rec_type
  ) RETURN opdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_opdv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPERANDS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_opdv_rec	IN opdv_rec_type
  ) RETURN opdv_rec_type IS
    l_opdv_rec	opdv_rec_type := p_opdv_rec;
  BEGIN
    IF (l_opdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.object_version_number := NULL;
    END IF;
    IF (l_opdv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_opdv_rec.fma_id = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.fma_id := NULL;
    END IF;
    IF (l_opdv_rec.dsf_id = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.dsf_id := NULL;
    END IF;
    IF (l_opdv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.name := NULL;
    END IF;
    IF (l_opdv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.description := NULL;
    END IF;
    IF (l_opdv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.version := NULL;
    END IF;
    IF (l_opdv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_opdv_rec.start_date := NULL;
    END IF;
    IF (l_opdv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_opdv_rec.end_date := NULL;
    END IF;
    IF (l_opdv_rec.source = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.source := NULL;
    END IF;
    IF (l_opdv_rec.opd_type = OKC_API.G_MISS_CHAR) THEN
      l_opdv_rec.opd_type := NULL;
    END IF;
    IF (l_opdv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.org_id := NULL;
    END IF;
    IF (l_opdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.created_by := NULL;
    END IF;
    IF (l_opdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_opdv_rec.creation_date := NULL;
    END IF;
    IF (l_opdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_opdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_opdv_rec.last_update_date := NULL;
    END IF;
    IF (l_opdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_opdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_opdv_rec);
  END null_out_defaults;
  /** Commented out generated code in favor of hand written code *** RPOONUGA001 Start ***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_OPERANDS_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_opdv_rec IN  opdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_opdv_rec.id = OKC_API.G_MISS_NUM OR
       p_opdv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_opdv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_opdv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_opdv_rec.name = OKC_API.G_MISS_CHAR OR
          p_opdv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_opdv_rec.version = OKC_API.G_MISS_CHAR OR
          p_opdv_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_opdv_rec.start_date = OKC_API.G_MISS_DATE OR
          p_opdv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_opdv_rec.opd_type = OKC_API.G_MISS_CHAR OR
          p_opdv_rec.opd_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opd_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_OPERANDS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_opdv_rec IN opdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  *** RPOONUGA001 End *** **/

  /** RPOONUGA001
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
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
  PROCEDURE Validate_Id(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.id = Okc_Api.G_MISS_NUM OR
       p_opdv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

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
                                p_opdv_rec      IN   opdv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_opdv_rec.start_date IS NULL) OR
       (p_opdv_rec.start_date = OKC_API.G_MISS_DATE) THEN
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
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM );

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
  PROCEDURE Validate_end_Date(p_opdv_rec      IN   opdv_rec_type
			     ,x_return_status OUT NOCOPY  VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_opdv_rec.end_date IS NOT NULL) AND
       (p_opdv_rec.end_date < p_opdv_rec.start_date) THEN
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
  PROCEDURE Validate_Object_Version_Number(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_opdv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Opd_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Opd_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Opd_Type(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  -- l_row_not_found             BOOLEAN := FALSE;
  l_row_found             VARCHAR2(1) := OKL_API.G_TRUE;

  -- Cursor For OKL_OPD_FCL_FK;
/*
  CURSOR okl_fclv_code_csr (p_code IN OKL_OPERANDS_V.opd_type%TYPE) IS
  SELECT '1'
    FROM FND_COMMON_LOOKUPS
   WHERE FND_COMMON_LOOKUPS.LOOKUP_CODE     = p_code
   AND FND_COMMON_LOOKUPS.LOOKUP_TYPE = 'OKL_OPERAND_TYPE';
*/

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.opd_type = Okc_Api.G_MISS_CHAR OR
       p_opdv_rec.opd_type IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opd_type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*
    OPEN okl_fclv_code_csr(p_opdv_rec.opd_type);
    FETCH okl_fclv_code_csr INTO l_dummy;
    l_row_not_found := okl_fclv_code_csr%NOTFOUND;
    CLOSE okl_fclv_code_csr;
*/
    l_row_found := OKL_ACCOUNTING_UTIL.validate_lookup_code('OKL_OPERAND_TYPE', p_opdv_rec.opd_type);

    IF (l_row_found = OKL_API.G_FALSE) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'opd_type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

	-- RPOONUGA002: Added this check to validate the values in opd_type and its
	-- attached fields(dsf_id, fma_id, source)
    IF p_opdv_rec.opd_type = G_FUNCTION_TYPE AND (p_opdv_rec.dsf_id = OKL_API.G_MISS_NUM OR
   						  p_opdv_rec.dsf_id IS NULL)
    THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> 'OKL',
			       p_msg_name		=> G_MISS_DATA,
			       p_token1		=> G_COL_NAME_TOKEN,
			       p_token1_value	=> 'DSF_ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	IF p_opdv_rec.opd_type = G_FORMULA_TYPE AND (p_opdv_rec.fma_id = OKL_API.G_MISS_NUM OR
	   						  				  	 p_opdv_rec.fma_id IS NULL)
    THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> 'OKL',
						   p_msg_name		=> G_MISS_DATA,
						   p_token1			=> G_COL_NAME_TOKEN,
						   p_token1_value	=> 'FMA_ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_opdv_rec.opd_type = G_CONSTANT_TYPE AND (p_opdv_rec.source = OKL_API.G_MISS_CHAR OR
   						  p_opdv_rec.source IS NULL)
    THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> 'OKL',
						   p_msg_name		=> G_MISS_DATA,
						   p_token1			=> G_COL_NAME_TOKEN,
						   p_token1_value	=> 'SOURCE');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
    /*
      IF okl_fclv_code_csr%ISOPEN THEN
        CLOSE okl_fclv_code_csr;
      END IF;
    */

  END Validate_Opd_Type;

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
  PROCEDURE Validate_Name(
    p_opdv_rec      IN OUT NOCOPY  opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  l_dummy                 VARCHAR2(1) := '?';
  l_row_found             BOOLEAN := FALSE;

  -- Cursor for Name Attribute
  CURSOR okl_opd_name_csr(p_name OKL_OPERANDS_V.name%TYPE)
  IS
  SELECT '1'
    FROM OKL_OPERANDS_V
   WHERE  name =  p_opdv_rec.name
     AND  id   <> p_opdv_rec.id;


  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.name = Okc_Api.G_MISS_CHAR OR
       p_opdv_rec.name IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    p_opdv_rec.name := Okl_Accounting_Util.okl_upper(p_opdv_rec.name);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_opd_name_csr%ISOPEN THEN
        CLOSE okl_opd_name_csr;
      END IF;
  END Validate_Name;

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
  PROCEDURE Validate_Version(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.version = Okc_Api.G_MISS_CHAR OR
       p_opdv_rec.version IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Dsf_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Dsf_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Dsf_Id(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_OPD_DSF_FK;
  CURSOR okl_dsfv_pk_csr (p_id IN OKL_OPERANDS_V.dsf_id%TYPE) IS
  SELECT '1'
    FROM OKL_DATA_SRC_FNCTNS_V
   WHERE OKL_DATA_SRC_FNCTNS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.dsf_id = Okc_Api.G_MISS_NUM OR
       p_opdv_rec.dsf_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dsf_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_Dsfv_pk_csr(p_opdv_rec.dsf_id);
    FETCH okl_dsfv_pk_csr INTO l_dummy;
    l_row_not_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_dsfv_pk_csr%ISOPEN THEN
        CLOSE okl_dsfv_pk_csr;
      END IF;

  END Validate_Dsf_Id;

 --Added by kthiruva on 08-Jun-2005 for Pricing Enhancements
 --Bug 4421600 - Start of Changes
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Func_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Func_Code
  -- Description     : Operands can only be associated with functions whose
  --                   function code is 'PLSQL'
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Func_Code(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_OPD_DSF_FK;
  CURSOR okl_dsfv_pk_csr (p_id IN OKL_OPERANDS_V.dsf_id%TYPE) IS
  SELECT '1'
    FROM OKL_DATA_SRC_FNCTNS_V
   WHERE OKL_DATA_SRC_FNCTNS_V.id = p_id
   AND OKL_DATA_SRC_FNCTNS_V.fnctn_code = 'PLSQL';

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN okl_Dsfv_pk_csr(p_opdv_rec.dsf_id);
    FETCH okl_dsfv_pk_csr INTO l_dummy;
    l_row_not_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INCORRECT_FUNC_TYPE);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_dsfv_pk_csr%ISOPEN THEN
        CLOSE okl_dsfv_pk_csr;
      END IF;

  END Validate_Func_Code;
  --Bug 4421600 - End of Changes for Pricing Enhancements

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fma_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fma_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fma_Id(
    p_opdv_rec      IN   opdv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_OPD_FMA_FK;
  -- RPOONUGA001: Correcting the cursor to the correct view
  CURSOR okl_fmav_pk_csr (p_id IN OKL_OPERANDS_V.fma_id%TYPE) IS
  SELECT '1'
    FROM OKL_FORMULAE_V
   WHERE OKL_FORMULAE_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_opdv_rec.fma_id = Okc_Api.G_MISS_NUM OR
       p_opdv_rec.fma_id IS NULL
    THEN
	  -- RPOONUGA001: Corrected column from dsf_id to fma_id
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fma_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_fmav_pk_csr(p_opdv_rec.fma_id);
    FETCH okl_fmav_pk_csr INTO l_dummy;
    l_row_not_found := okl_fmav_pk_csr%NOTFOUND;
    CLOSE okl_fmav_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_fmav_pk_csr%ISOPEN THEN
        CLOSE okl_fmav_pk_csr;
      END IF;

  END Validate_Fma_Id;

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
  PROCEDURE Validate_Sfwt_Flag( p_opdv_rec      IN   opdv_rec_type,
								x_return_status OUT NOCOPY  VARCHAR2 )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      IF (p_opdv_rec.sfwt_flag  IS NULL)OR (p_opdv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
          l_return_status:=Okl_Api.G_RET_STS_ERROR;
	  ELSE
	     IF UPPER(p_opdv_rec.sfwt_flag) NOT IN('Y','N') THEN
         	l_return_status:=Okl_Api.G_RET_STS_ERROR;
      	 END IF;
      END IF;

      IF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	          Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => g_invalid_value,
                             p_token1           => g_col_name_token,
                             p_token1_value     => 'sfwt_flag');

      END IF;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM );

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sfwt_Flag;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
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
    p_opdv_rec IN OUT NOCOPY opdv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_opdv_rec opdv_rec_type := p_opdv_rec;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sfwt_Flag
    Validate_Sfwt_Flag(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Name
    Validate_Name(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Version
    Validate_Version(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Start_Date
	-- Suresh Gorantla: Added this call to validate start date.
	-- Valid start_date

/*	IF ( l_opdv_rec.start_date IS NOT NULL ) AND
	( l_opdv_rec.start_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_Start_Date( x_return_status, l_opdv_rec );
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
	Validate_Start_Date( x_return_status, l_opdv_rec );
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



    -- Validate_Opd_Type
	-- RPOONUGA001: Removed this call because the field opd_type will be
	-- removed
	-- RPOONUGA002: Uncommenting this code

    Validate_Opd_Type(l_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Dsf_Id
	-- RPOONUGA001: Added this condition to support null inputs
	IF ( l_opdv_rec.dsf_id IS NOT NULL ) AND
	( l_opdv_rec.dsf_id <> OKC_API.G_MISS_NUM ) THEN
       Validate_Dsf_Id(l_opdv_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;
   END IF;

    -- Added by kthiruva for Pricing Enhancements
    -- Bug 4421600  - Start of Changes
    -- Validate_Func_Code
    --gboomina Bug 4725127 - Start
    IF ( l_opdv_rec.opd_type = 'FNCT') THEN
       Validate_Func_Code(l_opdv_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;
   END IF;
   --gboomina Bug 4725127 - End
   --Bug 4421600 - End of Changes for Pricing Enhancements


    -- Validate_Fma_Id
	-- RPOONUGA001: Added this condition to support null inputs
	IF ( l_opdv_rec.fma_id IS NOT NULL ) AND
	( l_opdv_rec.fma_id <> OKC_API.G_MISS_NUM ) THEN
       Validate_Fma_Id(l_opdv_rec, x_return_status);
       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             -- need to exit
             l_return_status := x_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             -- there was an error
             l_return_status := x_return_status;
          END IF;
       END IF;
   END IF;
   p_opdv_rec := l_opdv_rec;
   RETURN(l_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;

    ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Opd_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Opd_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Opd_Record(p_opdv_rec      IN      opdv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for OPD Unique Key
  CURSOR okl_opd_uk_csr(p_rec opdv_rec_type) IS
  SELECT '1'
  FROM OKL_OPERANDS_V
  WHERE  name =  p_rec.name
    AND  version =  p_rec.version
    AND  id     <> NVL(p_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_opd_uk_csr(p_opdv_rec);
    FETCH okl_opd_uk_csr INTO l_dummy;
    l_row_found := okl_opd_uk_csr%FOUND;
    CLOSE okl_opd_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message('OKL',G_UNQS, G_TABLE_TOKEN, 'Okl_Operands_V');
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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

  END Validate_Unique_opd_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
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
    p_opdv_rec IN opdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_opd_Record
    Validate_Unique_opd_Record(p_opdv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Valid end date
	-- Suresh Gorantla: Added this call to Valid end_date.
	-- Valid_end_date
	IF ( p_opdv_rec.end_date IS NOT NULL ) AND
	( p_opdv_rec.end_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_end_Date(p_opdv_rec, x_return_status );
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
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

/** RPOONUGA001 changes **/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  -- RPOONUGA001: Add IN to p_to parameter of migrate procedure
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN opdv_rec_type,
    p_to	IN OUT NOCOPY opd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.fma_id := p_from.fma_id;
    p_to.dsf_id := p_from.dsf_id;
    p_to.version := p_from.version;
    p_to.opd_type := p_from.opd_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.source := p_from.source;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.end_date := p_from.end_date;
  END migrate;
  PROCEDURE migrate (
    p_from	IN opd_rec_type,
    p_to	IN OUT NOCOPY opdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.fma_id := p_from.fma_id;
    p_to.dsf_id := p_from.dsf_id;
    p_to.version := p_from.version;
    p_to.opd_type := p_from.opd_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.source := p_from.source;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.end_date := p_from.end_date;
  END migrate;
  PROCEDURE migrate (
    p_from	IN opdv_rec_type,
    p_to	IN OUT NOCOPY okl_operands_tl_rec_type
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
    p_from	IN okl_operands_tl_rec_type,
    p_to	IN OUT NOCOPY opdv_rec_type
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
  -- validate_row for:OKL_OPERANDS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opdv_rec                     opdv_rec_type := p_opdv_rec;
    l_opd_rec                      opd_rec_type;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_opdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_opdv_rec);
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
  -- PL/SQL TBL validate_row for:OPDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_opdv_tbl.COUNT > 0) THEN
      i := p_opdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_opdv_rec                     => p_opdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_opdv_tbl.LAST);
        i := p_opdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- insert_row for:OKL_OPERANDS_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opd_rec                      IN opd_rec_type,
    x_opd_rec                      OUT NOCOPY opd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opd_rec                      opd_rec_type := p_opd_rec;
    l_def_opd_rec                  opd_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_opd_rec IN  opd_rec_type,
      x_opd_rec OUT NOCOPY opd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opd_rec := p_opd_rec;
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
      p_opd_rec,                         -- IN
      l_opd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPERANDS_B(
        id,
        name,
        fma_id,
        dsf_id,
        version,
        opd_type,
        object_version_number,
        org_id,
        start_date,
        source,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        end_date)
      VALUES (
        l_opd_rec.id,
        l_opd_rec.name,
        l_opd_rec.fma_id,
        l_opd_rec.dsf_id,
        l_opd_rec.version,
        l_opd_rec.opd_type,
        l_opd_rec.object_version_number,
        l_opd_rec.org_id,
        l_opd_rec.start_date,
        l_opd_rec.source,
        l_opd_rec.created_by,
        l_opd_rec.creation_date,
        l_opd_rec.last_updated_by,
        l_opd_rec.last_update_date,
        l_opd_rec.last_update_login,
        l_opd_rec.end_date);
    -- Set OUT values
    x_opd_rec := l_opd_rec;
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
  -- insert_row for:OKL_OPERANDS_TL --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type,
    x_okl_operands_tl_rec          OUT NOCOPY okl_operands_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type := p_okl_operands_tl_rec;
    l_def_okl_operands_tl_rec      okl_operands_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_operands_tl_rec IN  okl_operands_tl_rec_type,
      x_okl_operands_tl_rec OUT NOCOPY okl_operands_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_operands_tl_rec := p_okl_operands_tl_rec;
      x_okl_operands_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_operands_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_operands_tl_rec,             -- IN
      l_okl_operands_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_operands_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_OPERANDS_TL(
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
          l_okl_operands_tl_rec.id,
          l_okl_operands_tl_rec.language,
          l_okl_operands_tl_rec.source_lang,
          l_okl_operands_tl_rec.sfwt_flag,
          l_okl_operands_tl_rec.description,
          l_okl_operands_tl_rec.created_by,
          l_okl_operands_tl_rec.creation_date,
          l_okl_operands_tl_rec.last_updated_by,
          l_okl_operands_tl_rec.last_update_date,
          l_okl_operands_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_operands_tl_rec := l_okl_operands_tl_rec;
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
  -- insert_row for:OKL_OPERANDS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opdv_rec                     opdv_rec_type;
    l_def_opdv_rec                 opdv_rec_type;
    l_opd_rec                      opd_rec_type;
    lx_opd_rec                     opd_rec_type;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
    lx_okl_operands_tl_rec         okl_operands_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_opdv_rec	IN opdv_rec_type
    ) RETURN opdv_rec_type IS
      l_opdv_rec	opdv_rec_type := p_opdv_rec;
    BEGIN
      l_opdv_rec.CREATION_DATE := SYSDATE;
      l_opdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_opdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_opdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_opdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_opdv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_opdv_rec IN  opdv_rec_type,
      x_opdv_rec OUT NOCOPY opdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opdv_rec := p_opdv_rec;
      x_opdv_rec.OBJECT_VERSION_NUMBER := 1;
      x_opdv_rec.SFWT_FLAG := 'N';
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
    l_opdv_rec := null_out_defaults(p_opdv_rec);
    -- Set primary key value
    l_opdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_opdv_rec,                        -- IN
      l_def_opdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_opdv_rec := fill_who_columns(l_def_opdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_opdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_opdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_opdv_rec, l_opd_rec);
    migrate(l_def_opdv_rec, l_okl_operands_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opd_rec,
      lx_opd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_opd_rec, l_def_opdv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_operands_tl_rec,
      lx_okl_operands_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_operands_tl_rec, l_def_opdv_rec);
    -- Set OUT values
    x_opdv_rec := l_def_opdv_rec;
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
  -- PL/SQL TBL insert_row for:OPDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type,
    x_opdv_tbl                     OUT NOCOPY opdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_opdv_tbl.COUNT > 0) THEN
      i := p_opdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_opdv_rec                     => p_opdv_tbl(i),
          x_opdv_rec                     => x_opdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_opdv_tbl.LAST);
        i := p_opdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- lock_row for:OKL_OPERANDS_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opd_rec                      IN opd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_opd_rec IN opd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPERANDS_B
     WHERE ID = p_opd_rec.id
       AND OBJECT_VERSION_NUMBER = p_opd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_opd_rec IN opd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPERANDS_B
    WHERE ID = p_opd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_OPERANDS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_OPERANDS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_opd_rec);
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
      OPEN lchk_csr(p_opd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_opd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_opd_rec.object_version_number THEN
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
  -- lock_row for:OKL_OPERANDS_TL --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_operands_tl_rec IN okl_operands_tl_rec_type) IS
    SELECT *
      FROM OKL_OPERANDS_TL
     WHERE ID = p_okl_operands_tl_rec.id
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
      OPEN lock_csr(p_okl_operands_tl_rec);
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
  -- lock_row for:OKL_OPERANDS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opd_rec                      opd_rec_type;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
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
    migrate(p_opdv_rec, l_opd_rec);
    migrate(p_opdv_rec, l_okl_operands_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opd_rec
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
      l_okl_operands_tl_rec
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
  -- PL/SQL TBL lock_row for:OPDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_opdv_tbl.COUNT > 0) THEN
      i := p_opdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_opdv_rec                     => p_opdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_opdv_tbl.LAST);
        i := p_opdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- update_row for:OKL_OPERANDS_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opd_rec                      IN opd_rec_type,
    x_opd_rec                      OUT NOCOPY opd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opd_rec                      opd_rec_type := p_opd_rec;
    l_def_opd_rec                  opd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_opd_rec	IN opd_rec_type,
      x_opd_rec	OUT NOCOPY opd_rec_type
    ) RETURN VARCHAR2 IS
      l_opd_rec                      opd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opd_rec := p_opd_rec;
      -- Get current database values
      l_opd_rec := get_rec(p_opd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_opd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.id := l_opd_rec.id;
      END IF;
      IF (x_opd_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_opd_rec.name := l_opd_rec.name;
      END IF;
      IF (x_opd_rec.fma_id = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.fma_id := l_opd_rec.fma_id;
      END IF;
      IF (x_opd_rec.dsf_id = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.dsf_id := l_opd_rec.dsf_id;
      END IF;
      IF (x_opd_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_opd_rec.version := l_opd_rec.version;
      END IF;
      IF (x_opd_rec.opd_type = OKC_API.G_MISS_CHAR)
      THEN
        x_opd_rec.opd_type := l_opd_rec.opd_type;
      END IF;
      IF (x_opd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.object_version_number := l_opd_rec.object_version_number;
      END IF;
      IF (x_opd_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.org_id := l_opd_rec.org_id;
      END IF;
      IF (x_opd_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_opd_rec.start_date := l_opd_rec.start_date;
      END IF;
      IF (x_opd_rec.source = OKC_API.G_MISS_CHAR)
      THEN
        x_opd_rec.source := l_opd_rec.source;
      END IF;
      IF (x_opd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.created_by := l_opd_rec.created_by;
      END IF;
      IF (x_opd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_opd_rec.creation_date := l_opd_rec.creation_date;
      END IF;
      IF (x_opd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.last_updated_by := l_opd_rec.last_updated_by;
      END IF;
      IF (x_opd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_opd_rec.last_update_date := l_opd_rec.last_update_date;
      END IF;
      IF (x_opd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_opd_rec.last_update_login := l_opd_rec.last_update_login;
      END IF;
      IF (x_opd_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_opd_rec.end_date := l_opd_rec.end_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_opd_rec IN  opd_rec_type,
      x_opd_rec OUT NOCOPY opd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opd_rec := p_opd_rec;
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
      p_opd_rec,                         -- IN
      l_opd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_opd_rec, l_def_opd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OPERANDS_B
    SET NAME = l_def_opd_rec.name,
        FMA_ID = l_def_opd_rec.fma_id,
        DSF_ID = l_def_opd_rec.dsf_id,
        VERSION = l_def_opd_rec.version,
        OPD_TYPE = l_def_opd_rec.opd_type,
        OBJECT_VERSION_NUMBER = l_def_opd_rec.object_version_number,
        ORG_ID = l_def_opd_rec.org_id,
        START_DATE = l_def_opd_rec.start_date,
        SOURCE = l_def_opd_rec.source,
        CREATED_BY = l_def_opd_rec.created_by,
        CREATION_DATE = l_def_opd_rec.creation_date,
        LAST_UPDATED_BY = l_def_opd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_opd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_opd_rec.last_update_login,
        END_DATE = l_def_opd_rec.end_date
    WHERE ID = l_def_opd_rec.id;

    x_opd_rec := l_def_opd_rec;
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
  -- update_row for:OKL_OPERANDS_TL --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type,
    x_okl_operands_tl_rec          OUT NOCOPY okl_operands_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type := p_okl_operands_tl_rec;
    l_def_okl_operands_tl_rec      okl_operands_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_operands_tl_rec	IN okl_operands_tl_rec_type,
      x_okl_operands_tl_rec	OUT NOCOPY okl_operands_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_operands_tl_rec          okl_operands_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_operands_tl_rec := p_okl_operands_tl_rec;
      -- Get current database values
      l_okl_operands_tl_rec := get_rec(p_okl_operands_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_operands_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_operands_tl_rec.id := l_okl_operands_tl_rec.id;
      END IF;
      IF (x_okl_operands_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_operands_tl_rec.language := l_okl_operands_tl_rec.language;
      END IF;
      IF (x_okl_operands_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_operands_tl_rec.source_lang := l_okl_operands_tl_rec.source_lang;
      END IF;
      IF (x_okl_operands_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_operands_tl_rec.sfwt_flag := l_okl_operands_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_operands_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_operands_tl_rec.description := l_okl_operands_tl_rec.description;
      END IF;
      IF (x_okl_operands_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_operands_tl_rec.created_by := l_okl_operands_tl_rec.created_by;
      END IF;
      IF (x_okl_operands_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_operands_tl_rec.creation_date := l_okl_operands_tl_rec.creation_date;
      END IF;
      IF (x_okl_operands_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_operands_tl_rec.last_updated_by := l_okl_operands_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_operands_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_operands_tl_rec.last_update_date := l_okl_operands_tl_rec.last_update_date;
      END IF;
      IF (x_okl_operands_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_operands_tl_rec.last_update_login := l_okl_operands_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_operands_tl_rec IN  okl_operands_tl_rec_type,
      x_okl_operands_tl_rec OUT NOCOPY okl_operands_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_operands_tl_rec := p_okl_operands_tl_rec;
      x_okl_operands_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_operands_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_operands_tl_rec,             -- IN
      l_okl_operands_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_operands_tl_rec, l_def_okl_operands_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OPERANDS_TL
    SET DESCRIPTION = l_def_okl_operands_tl_rec.description,
        CREATED_BY = l_def_okl_operands_tl_rec.created_by,
        SOURCE_LANG = l_def_okl_operands_tl_rec.source_lang,
        CREATION_DATE = l_def_okl_operands_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_operands_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_operands_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_operands_tl_rec.last_update_login
    WHERE ID = l_def_okl_operands_tl_rec.id
       AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_OPERANDS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_operands_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_operands_tl_rec := l_def_okl_operands_tl_rec;
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
  -- update_row for:OKL_OPERANDS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opdv_rec                     opdv_rec_type := p_opdv_rec;
    l_def_opdv_rec                 opdv_rec_type;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
    lx_okl_operands_tl_rec         okl_operands_tl_rec_type;
    l_opd_rec                      opd_rec_type;
    lx_opd_rec                     opd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_opdv_rec	IN opdv_rec_type
    ) RETURN opdv_rec_type IS
      l_opdv_rec	opdv_rec_type := p_opdv_rec;
    BEGIN
      l_opdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_opdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_opdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_opdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_opdv_rec	IN opdv_rec_type,
      x_opdv_rec	OUT NOCOPY opdv_rec_type
    ) RETURN VARCHAR2 IS
      l_opdv_rec                     opdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opdv_rec := p_opdv_rec;
      -- Get current database values
      l_opdv_rec := get_rec(p_opdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_opdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.id := l_opdv_rec.id;
      END IF;
      IF (x_opdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.object_version_number := l_opdv_rec.object_version_number;
      END IF;
      IF (x_opdv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.sfwt_flag := l_opdv_rec.sfwt_flag;
      END IF;
      IF (x_opdv_rec.fma_id = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.fma_id := l_opdv_rec.fma_id;
      END IF;
      IF (x_opdv_rec.dsf_id = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.dsf_id := l_opdv_rec.dsf_id;
      END IF;
      IF (x_opdv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.name := l_opdv_rec.name;
      END IF;
      IF (x_opdv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.description := l_opdv_rec.description;
      END IF;
      IF (x_opdv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.version := l_opdv_rec.version;
      END IF;
      IF (x_opdv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_opdv_rec.start_date := l_opdv_rec.start_date;
      END IF;
      IF (x_opdv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_opdv_rec.end_date := l_opdv_rec.end_date;
      END IF;
      IF (x_opdv_rec.source = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.source := l_opdv_rec.source;
      END IF;
      IF (x_opdv_rec.opd_type = OKC_API.G_MISS_CHAR)
      THEN
        x_opdv_rec.opd_type := l_opdv_rec.opd_type;
      END IF;
      IF (x_opdv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.org_id := l_opdv_rec.org_id;
      END IF;
      IF (x_opdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.created_by := l_opdv_rec.created_by;
      END IF;
      IF (x_opdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_opdv_rec.creation_date := l_opdv_rec.creation_date;
      END IF;
      IF (x_opdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.last_updated_by := l_opdv_rec.last_updated_by;
      END IF;
      IF (x_opdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_opdv_rec.last_update_date := l_opdv_rec.last_update_date;
      END IF;
      IF (x_opdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_opdv_rec.last_update_login := l_opdv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_opdv_rec IN  opdv_rec_type,
      x_opdv_rec OUT NOCOPY opdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_opdv_rec := p_opdv_rec;
      x_opdv_rec.OBJECT_VERSION_NUMBER := NVL(x_opdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_opdv_rec,                        -- IN
      l_opdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_opdv_rec, l_def_opdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_opdv_rec := fill_who_columns(l_def_opdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_opdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_opdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_opdv_rec, l_okl_operands_tl_rec);
    migrate(l_def_opdv_rec, l_opd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_operands_tl_rec,
      lx_okl_operands_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_operands_tl_rec, l_def_opdv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_opd_rec,
      lx_opd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_opd_rec, l_def_opdv_rec);
    x_opdv_rec := l_def_opdv_rec;
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
  -- PL/SQL TBL update_row for:OPDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type,
    x_opdv_tbl                     OUT NOCOPY opdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_opdv_tbl.COUNT > 0) THEN
      i := p_opdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_opdv_rec                     => p_opdv_tbl(i),
          x_opdv_rec                     => x_opdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_opdv_tbl.LAST);
        i := p_opdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- delete_row for:OKL_OPERANDS_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opd_rec                      IN opd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opd_rec                      opd_rec_type:= p_opd_rec;
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
    DELETE FROM OKL_OPERANDS_B
     WHERE ID = l_opd_rec.id;

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
  -- delete_row for:OKL_OPERANDS_TL --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_operands_tl_rec          IN okl_operands_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type:= p_okl_operands_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPERANDS_TL --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_operands_tl_rec IN  okl_operands_tl_rec_type,
      x_okl_operands_tl_rec OUT NOCOPY okl_operands_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_operands_tl_rec := p_okl_operands_tl_rec;
      x_okl_operands_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_operands_tl_rec,             -- IN
      l_okl_operands_tl_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_OPERANDS_TL
     WHERE ID = l_okl_operands_tl_rec.id;

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
  -- delete_row for:OKL_OPERANDS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_opdv_rec                     opdv_rec_type := p_opdv_rec;
    l_okl_operands_tl_rec          okl_operands_tl_rec_type;
    l_opd_rec                      opd_rec_type;
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
    migrate(l_opdv_rec, l_okl_operands_tl_rec);
    migrate(l_opdv_rec, l_opd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_operands_tl_rec
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
      l_opd_rec
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
  -- PL/SQL TBL delete_row for:OPDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_opdv_tbl.COUNT > 0) THEN
      i := p_opdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_opdv_rec                     => p_opdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_opdv_tbl.LAST);
        i := p_opdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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

  PROCEDURE TRANSLATE_ROW(p_opdv_rec IN opdv_rec_type,
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
      FROM OKL_OPERANDS_TL
      where ID = to_number(p_opdv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
	UPDATE OKL_OPERANDS_TL
	SET	DESCRIPTION       = p_opdv_rec.description,
	    LAST_UPDATE_DATE  = f_ludate,
	    LAST_UPDATED_BY   = f_luby,
	    LAST_UPDATE_LOGIN = 0,
	    SOURCE_LANG       = USERENV('LANG')
	WHERE ID = to_number(p_opdv_rec.id)
	  AND USERENV('LANG') IN (language,source_lang);
     END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_opdv_rec IN opdv_rec_type,
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
      FROM OKL_OPERANDS_B
      where ID = p_opdv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
	    UPDATE OKL_OPERANDS_B
	    SET NAME           = p_opdv_rec.name,
            FMA_ID		   = p_opdv_rec.id,
	        DSF_ID		   = p_opdv_rec.DSF_ID,
	 	    OPD_TYPE	   = p_opdv_rec.OPD_TYPE,
	 	    OBJECT_VERSION_NUMBER = TO_NUMBER(p_opdv_rec.OBJECT_VERSION_NUMBER),
	 	    ORG_ID	   	   = TO_NUMBER(p_opdv_rec.ORG_ID),
	 	    START_DATE	  = p_opdv_rec.START_DATE,
	 	    END_DATE	  = p_opdv_rec.END_DATE,
	 	    SOURCE		  = p_opdv_rec.SOURCE,
	        LAST_UPDATE_DATE  = f_ludate,
	        LAST_UPDATED_BY   = f_luby,
	        LAST_UPDATE_LOGIN = 0
	    WHERE ID = to_number(p_opdv_rec.id);
        --Update _TL
	     UPDATE OKL_OPERANDS_TL
	     SET DESCRIPTION       = p_opdv_rec.DESCRIPTION,
	         LAST_UPDATE_DATE  = f_ludate,
	         LAST_UPDATED_BY   = f_luby,
	         LAST_UPDATE_LOGIN = 0,
	         SOURCE_LANG       = USERENV('LANG')
	     WHERE ID = to_number(p_opdv_rec.id)
	       AND USERENV('LANG') IN (language,source_lang);
	     IF(sql%notfound) THEN

	       INSERT INTO OKL_OPERANDS_TL
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
	 	  SELECT  TO_NUMBER(p_opdv_rec.id),
	 		L.LANGUAGE_CODE,
	 		userenv('LANG'),
	 		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
	 		p_opdv_rec.description,
	 		f_luby,
	 		f_ludate,
	 		f_luby,
	 		f_ludate,
	 		0
	       FROM FND_LANGUAGES L
	 	   WHERE L.INSTALLED_FLAG IN ('I','B')
	       	AND NOT EXISTS
	           (SELECT NULL
	            FROM   OKL_OPERANDS_TL TL
	      	   WHERE  TL.ID = TO_NUMBER(p_opdv_rec.id)
	            AND    TL.LANGUAGE = L.LANGUAGE_CODE);
	     end if;

      END IF;

    END;
    EXCEPTION
     when no_data_found then
	   INSERT INTO OKL_OPERANDS_B
	 	(
	 	ID,
	 	NAME,
	 	FMA_ID,
	 	DSF_ID,
	 	VERSION,
	 	OPD_TYPE,
	 	OBJECT_VERSION_NUMBER,
	 	ORG_ID,
	 	START_DATE,
	 	END_DATE,
	 	SOURCE,
	 	CREATED_BY,
	 	CREATION_DATE,
	 	LAST_UPDATED_BY,
	 	LAST_UPDATE_DATE,
	 	LAST_UPDATE_LOGIN
	 	)
	   SELECT
	 	TO_NUMBER(p_opdv_rec.id),
	 	p_opdv_rec.name,
	 	TO_NUMBER(p_opdv_rec.fma_id),
	 	TO_NUMBER(p_opdv_rec.dsf_id),
	 	p_opdv_rec.version,
	 	p_opdv_rec.opd_type,
	 	TO_NUMBER(p_opdv_rec.object_version_number),
	 	TO_NUMBER(p_opdv_rec.org_id),
	 	p_opdv_rec.start_date,
	 	p_opdv_rec.end_date,
	 	p_opdv_rec.source,
	 	f_luby,
	 	f_ludate,
	 	f_luby,
	 	f_ludate,
	 	0
	   FROM DUAL
	     WHERE NOT EXISTS (SELECT 1
	               from OKL_OPERANDS_B
	               where ( ID = TO_NUMBER(p_opdv_rec.id) OR
	 		  (NAME = p_opdv_rec.name AND VERSION = p_opdv_rec.version)));

	   INSERT INTO OKL_OPERANDS_TL
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
            TO_NUMBER(p_opdv_rec.id),
	 		L.LANGUAGE_CODE,
	 		userenv('LANG'),
	 		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
	 		p_opdv_rec.DESCRIPTION,
	 		f_luby,
	 		f_ludate,
	 		f_luby,
	 		f_ludate,
	 		0
	 	FROM FND_LANGUAGES L
	 	WHERE L.INSTALLED_FLAG IN ('I','B')
	      AND NOT EXISTS
	          (SELECT NULL
	           FROM   OKL_OPERANDS_TL TL
	      	   WHERE  TL.ID = TO_NUMBER(p_opdv_rec.id)
	            AND    TL.LANGUAGE = L.LANGUAGE_CODE);

   END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode               IN VARCHAR2,
    p_okl_operand_id            IN VARCHAR2,
    p_name                      IN VARCHAR2,
    p_version                   IN VARCHAR2,
    p_fma_id                    IN VARCHAR2,
    p_dsf_id                    IN VARCHAR2,
    p_opd_type                  IN VARCHAR2,
    p_object_version_number     IN VARCHAR2,
    p_org_id                    IN VARCHAR2,
    p_start_date                IN VARCHAR2,
    p_end_date                  IN VARCHAR2,
    p_source                    IN VARCHAR2,
    p_last_update_date          IN VARCHAR2,
    p_owner                     IN VARCHAR2,
    p_description               IN VARCHAR2) IS

    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_init_msg_list          VARCHAR2(1):= 'T';
    l_opdv_rec               opdv_rec_type;
  BEGIN
  --Prepare Record Structure for Insert/Update
    l_opdv_rec.id                     := p_okl_operand_id;
    l_opdv_rec.object_version_number  := p_object_version_number;
    l_opdv_rec.fma_id                 := p_fma_id;
    l_opdv_rec.dsf_id                 := p_dsf_id;
    l_opdv_rec.name                   := p_name;
    l_opdv_rec.description            := p_description;
    l_opdv_rec.version                := p_version;
    l_opdv_rec.start_date             := TO_DATE(p_start_date,'YYYY/MM/DD');
    l_opdv_rec.end_date               := TO_DATE(p_end_date,'YYYY/MM/DD');
    l_opdv_rec.source                 := p_source;
    l_opdv_rec.opd_type               := p_opd_type;
    l_opdv_rec.org_id                 := p_org_id;

   IF(p_upload_mode = 'NLS') then
	 OKL_OPD_PVT.TRANSLATE_ROW(p_opdv_rec => l_opdv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_OPD_PVT.LOAD_ROW(p_opdv_rec => l_opdv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;

 END LOAD_SEED_ROW;

END OKL_OPD_PVT;

/

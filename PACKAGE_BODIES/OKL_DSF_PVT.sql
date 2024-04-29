--------------------------------------------------------
--  DDL for Package Body OKL_DSF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DSF_PVT" AS
/* $Header: OKLSDSFB.pls 120.5 2007/01/09 08:41:39 abhsaxen noship $ */
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
    DELETE FROM OKL_DATA_SRC_FNCTNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_DATA_SRC_FNCTNS_B B   --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_DATA_SRC_FNCTNS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_DATA_SRC_FNCTNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_DATA_SRC_FNCTNS_TL SUBB, OKL_DATA_SRC_FNCTNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_DATA_SRC_FNCTNS_TL (
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
        FROM OKL_DATA_SRC_FNCTNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_DATA_SRC_FNCTNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_DATA_SRC_FNCTNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_dsf_rec                      IN dsf_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN dsf_rec_type IS
    CURSOR okl_data_src_fnctns_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            VERSION,
            SOURCE,
            ORG_ID,
            START_DATE,
            END_DATE,
            FNCTN_CODE,
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
      FROM Okl_Data_Src_Fnctns_B
     WHERE okl_data_src_fnctns_b.id = p_id;
    l_okl_data_src_fnctns_b_pk     okl_data_src_fnctns_b_pk_csr%ROWTYPE;
    l_dsf_rec                      dsf_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_data_src_fnctns_b_pk_csr (p_dsf_rec.id);
    FETCH okl_data_src_fnctns_b_pk_csr INTO
              l_dsf_rec.ID,
              l_dsf_rec.OBJECT_VERSION_NUMBER,
              l_dsf_rec.NAME,
              l_dsf_rec.VERSION,
              l_dsf_rec.SOURCE,
              l_dsf_rec.ORG_ID,
              l_dsf_rec.START_DATE,
              l_dsf_rec.END_DATE,
              l_dsf_rec.FNCTN_CODE,
              l_dsf_rec.ATTRIBUTE_CATEGORY,
              l_dsf_rec.ATTRIBUTE1,
              l_dsf_rec.ATTRIBUTE2,
              l_dsf_rec.ATTRIBUTE3,
              l_dsf_rec.ATTRIBUTE4,
              l_dsf_rec.ATTRIBUTE5,
              l_dsf_rec.ATTRIBUTE6,
              l_dsf_rec.ATTRIBUTE7,
              l_dsf_rec.ATTRIBUTE8,
              l_dsf_rec.ATTRIBUTE9,
              l_dsf_rec.ATTRIBUTE10,
              l_dsf_rec.ATTRIBUTE11,
              l_dsf_rec.ATTRIBUTE12,
              l_dsf_rec.ATTRIBUTE13,
              l_dsf_rec.ATTRIBUTE14,
              l_dsf_rec.ATTRIBUTE15,
              l_dsf_rec.CREATED_BY,
              l_dsf_rec.CREATION_DATE,
              l_dsf_rec.LAST_UPDATED_BY,
              l_dsf_rec.LAST_UPDATE_DATE,
              l_dsf_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_data_src_fnctns_b_pk_csr%NOTFOUND;
    CLOSE okl_data_src_fnctns_b_pk_csr;
    RETURN(l_dsf_rec);
  END get_rec;

  FUNCTION get_rec (
    p_dsf_rec                      IN dsf_rec_type
  ) RETURN dsf_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_dsf_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_DATA_SRC_FNCTNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklDataSrcFnctnsTlRecType IS
    CURSOR okl_data_src_fnctns_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Data_Src_Fnctns_Tl
     WHERE okl_data_src_fnctns_tl.id = p_id
       AND okl_data_src_fnctns_tl.language = p_language;
    l_okl_data_src_fnctns_tl_pk    okl_data_src_fnctns_tl_pk_csr%ROWTYPE;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_data_src_fnctns_tl_pk_csr (p_okl_data_src_fnctns_tl_rec.id,
                                        p_okl_data_src_fnctns_tl_rec.language);
    FETCH okl_data_src_fnctns_tl_pk_csr INTO
              l_okl_data_src_fnctns_tl_rec.ID,
              l_okl_data_src_fnctns_tl_rec.LANGUAGE,
              l_okl_data_src_fnctns_tl_rec.SOURCE_LANG,
              l_okl_data_src_fnctns_tl_rec.SFWT_FLAG,
              l_okl_data_src_fnctns_tl_rec.DESCRIPTION,
              l_okl_data_src_fnctns_tl_rec.CREATED_BY,
              l_okl_data_src_fnctns_tl_rec.CREATION_DATE,
              l_okl_data_src_fnctns_tl_rec.LAST_UPDATED_BY,
              l_okl_data_src_fnctns_tl_rec.LAST_UPDATE_DATE,
              l_okl_data_src_fnctns_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_data_src_fnctns_tl_pk_csr%NOTFOUND;
    CLOSE okl_data_src_fnctns_tl_pk_csr;
    RETURN(l_okl_data_src_fnctns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType
  ) RETURN OklDataSrcFnctnsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_data_src_fnctns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_DATA_SRC_FNCTNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_dsfv_rec                     IN dsfv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN dsfv_rec_type IS
    CURSOR okl_dsfv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            FNCTN_CODE,
            NAME,
            DESCRIPTION,
            VERSION,
            START_DATE,
            END_DATE,
            SOURCE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Data_Src_Fnctns_V
     WHERE okl_data_src_fnctns_v.id = p_id;
    l_okl_dsfv_pk                  okl_dsfv_pk_csr%ROWTYPE;
    l_dsfv_rec                     dsfv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_dsfv_pk_csr (p_dsfv_rec.id);
    FETCH okl_dsfv_pk_csr INTO
              l_dsfv_rec.ID,
              l_dsfv_rec.OBJECT_VERSION_NUMBER,
              l_dsfv_rec.SFWT_FLAG,
              l_dsfv_rec.FNCTN_CODE,
              l_dsfv_rec.NAME,
              l_dsfv_rec.DESCRIPTION,
              l_dsfv_rec.VERSION,
              l_dsfv_rec.START_DATE,
              l_dsfv_rec.END_DATE,
              l_dsfv_rec.SOURCE,
              l_dsfv_rec.ATTRIBUTE_CATEGORY,
              l_dsfv_rec.ATTRIBUTE1,
              l_dsfv_rec.ATTRIBUTE2,
              l_dsfv_rec.ATTRIBUTE3,
              l_dsfv_rec.ATTRIBUTE4,
              l_dsfv_rec.ATTRIBUTE5,
              l_dsfv_rec.ATTRIBUTE6,
              l_dsfv_rec.ATTRIBUTE7,
              l_dsfv_rec.ATTRIBUTE8,
              l_dsfv_rec.ATTRIBUTE9,
              l_dsfv_rec.ATTRIBUTE10,
              l_dsfv_rec.ATTRIBUTE11,
              l_dsfv_rec.ATTRIBUTE12,
              l_dsfv_rec.ATTRIBUTE13,
              l_dsfv_rec.ATTRIBUTE14,
              l_dsfv_rec.ATTRIBUTE15,
              l_dsfv_rec.ORG_ID,
              l_dsfv_rec.CREATED_BY,
              l_dsfv_rec.CREATION_DATE,
              l_dsfv_rec.LAST_UPDATED_BY,
              l_dsfv_rec.LAST_UPDATE_DATE,
              l_dsfv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;
    RETURN(l_dsfv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_dsfv_rec                     IN dsfv_rec_type
  ) RETURN dsfv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_dsfv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_DATA_SRC_FNCTNS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_dsfv_rec	IN dsfv_rec_type
  ) RETURN dsfv_rec_type IS
    l_dsfv_rec	dsfv_rec_type := p_dsfv_rec;
  BEGIN
    IF (l_dsfv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_dsfv_rec.object_version_number := NULL;
    END IF;
    IF (l_dsfv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_dsfv_rec.fnctn_code = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.fnctn_code := NULL;
    END IF;
    IF (l_dsfv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.name := NULL;
    END IF;
    IF (l_dsfv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.description := NULL;
    END IF;
    IF (l_dsfv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.version := NULL;
    END IF;
    IF (l_dsfv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_dsfv_rec.start_date := NULL;
    END IF;
    IF (l_dsfv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_dsfv_rec.end_date := NULL;
    END IF;
    IF (l_dsfv_rec.source = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.source := NULL;
    END IF;
    IF (l_dsfv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute_category := NULL;
    END IF;
    IF (l_dsfv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute1 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute2 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute3 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute4 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute5 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute6 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute7 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute8 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute9 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute10 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute11 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute12 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute13 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute14 := NULL;
    END IF;
    IF (l_dsfv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_dsfv_rec.attribute15 := NULL;
    END IF;
    IF (l_dsfv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_dsfv_rec.org_id := NULL;
    END IF;
    IF (l_dsfv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_dsfv_rec.created_by := NULL;
    END IF;
    IF (l_dsfv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_dsfv_rec.creation_date := NULL;
    END IF;
    IF (l_dsfv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_dsfv_rec.last_updated_by := NULL;
    END IF;
    IF (l_dsfv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_dsfv_rec.last_update_date := NULL;
    END IF;
    IF (l_dsfv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_dsfv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_dsfv_rec);
  END null_out_defaults;
  /** Commented out generated code in favor of hand written code *** SBALASHA001 Start ***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_DATA_SRC_FNCTNS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_dsfv_rec IN  dsfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_dsfv_rec.id = OKC_API.G_MISS_NUM OR
       p_dsfv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_dsfv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.fnctn_code = OKC_API.G_MISS_CHAR OR
          p_dsfv_rec.fnctn_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fnctn_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.name = OKC_API.G_MISS_CHAR OR
          p_dsfv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.version = OKC_API.G_MISS_CHAR OR
          p_dsfv_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.start_date = OKC_API.G_MISS_DATE OR
          p_dsfv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_dsfv_rec.source = OKC_API.G_MISS_CHAR OR
          p_dsfv_rec.source IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'source');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_DATA_SRC_FNCTNS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_dsfv_rec IN dsfv_rec_type
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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT  NOCOPY VARCHAR2
                                          ,p_dsfv_rec      IN   dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ( p_dsfv_rec.object_version_number IS NULL ) OR
       ( p_dsfv_rec.object_version_Number = OKC_API.G_MISS_NUM ) THEN
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
                              p_dsfv_rec      IN   dsfv_rec_type)
  IS

  -- l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_return_status         VARCHAR2(1)  := OKL_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      -- l_return_status := OKL_UTIL.check_domain_yn(p_dsfv_rec.sfwt_flag);
      l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_dsfv_rec.sfwt_flag,0,0);
      IF (l_return_status = OKL_API.G_FALSE) THEN
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
                              p_dsfv_rec      IN OUT  NOCOPY dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_dsfv_rec.name IS NULL) OR
       (p_dsfv_rec.name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'name' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    p_dsfv_rec.name := Okl_Accounting_Util.okl_upper(p_dsfv_rec.name);


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
  PROCEDURE Validate_Version(x_return_status OUT NOCOPY VARCHAR2,
                              p_dsfv_rec      IN   dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_dsfv_rec.version IS NULL) OR
       (p_dsfv_rec.version = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'version' );
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
                              p_dsfv_rec      IN   dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_dsfv_rec.start_date IS NULL) OR
       (p_dsfv_rec.start_date = OKC_API.G_MISS_DATE) THEN
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
  PROCEDURE Validate_end_Date(p_dsfv_rec      IN   dsfv_rec_type
			     ,x_return_status OUT NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_dsfv_rec.end_date IS NOT NULL) AND
       (p_dsfv_rec.end_date < p_dsfv_rec.start_date) THEN
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
  -- PROCEDURE Validate_Source
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Source(x_return_status OUT NOCOPY VARCHAR2,
                              p_dsfv_rec      IN   dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_dsfv_rec.source IS NULL) OR
       (p_dsfv_rec.source = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                           p_msg_name       => g_required_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'source' );
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

  END Validate_Source;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fnctn_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fnctn_Code
  -- Description     : This procedure is added as part of the fix for the new
  --                   attribute fnctn_code according to RPOONUGA001
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fnctn_Code(
    p_dsfv_rec      IN   dsfv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  -- l_row_not_found             BOOLEAN := FALSE;
  l_row_found             VARCHAR2(1) := OKL_API.G_TRUE;

  -- Cursor For OKL_DSF_FCL_FK;
/*
  CURSOR okl_fclv_code_csr (p_code IN OKL_DATA_SRC_FNCTNS_V.fnctn_code%TYPE) IS
  SELECT '1'
    FROM FND_COMMON_LOOKUPS
   WHERE FND_COMMON_LOOKUPS.LOOKUP_CODE     = p_code
   AND FND_COMMON_LOOKUPS.LOOKUP_TYPE = 'OKL_FUNCTION_TYPE';
*/

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_dsfv_rec.fnctn_code = Okc_Api.G_MISS_CHAR OR
       p_dsfv_rec.fnctn_code IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fnctn_code');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*
    OPEN okl_fclv_code_csr(p_dsfv_rec.fnctn_code);
    FETCH okl_fclv_code_csr INTO l_dummy;
    l_row_not_found := okl_fclv_code_csr%NOTFOUND;
    CLOSE okl_fclv_code_csr;
*/
    l_row_found := OKL_ACCOUNTING_UTIL.validate_lookup_code('OKL_FUNCTION_TYPE', p_dsfv_rec.fnctn_code);
    IF (l_row_found = OKL_API.G_FALSE) THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'fnctn_code');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

	IF p_dsfv_rec.fnctn_code = G_PLSQL_TYPE AND (p_dsfv_rec.source = OKL_API.G_MISS_CHAR OR
	   						  				  	 p_dsfv_rec.source IS NULL)
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

  END Validate_Fnctn_Code;

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
    p_dsfv_rec IN OUT NOCOPY dsfv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsfv_rec dsfv_rec_type := p_dsfv_rec;
  BEGIN

	-- Validate Foreign Keys
	-- INFO: No foriegn keys for this entites.

  	-- call each column-level validation

	-- Validate ID
    IF l_dsfv_rec.id = OKC_API.G_MISS_NUM OR
       l_dsfv_rec.id IS NULL
    THEN
      OKC_API.set_message( G_APP_NAME,
	  					  G_REQUIRED_VALUE,
						  G_COL_NAME_TOKEN, 'id' );
      l_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;

	-- Valid object_version_number
/*	IF ( l_dsfv_rec.object_version_number IS NOT NULL ) AND
	( l_dsfv_rec.object_version_number <> OKC_API.G_MISS_NUM ) THEN
		Validate_Object_Version_Number( x_return_status, l_dsfv_rec );
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
	Validate_Object_Version_Number( x_return_status, l_dsfv_rec );
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


	-- Valid sfwt_flag
	IF ( l_dsfv_rec.sfwt_flag IS NOT NULL ) AND
	( l_dsfv_rec.name <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Sfwt_Flag( x_return_status, l_dsfv_rec );
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
/*	IF ( l_dsfv_rec.name IS NOT NULL ) AND
	( l_dsfv_rec.name <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Name( x_return_status, l_dsfv_rec );
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

	Validate_Name( x_return_status, l_dsfv_rec );
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


	-- Valid version
/*	IF ( l_dsfv_rec.version IS NOT NULL ) AND
	( l_dsfv_rec.version <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Version( x_return_status, l_dsfv_rec );
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
	Validate_Version( x_return_status, l_dsfv_rec );
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


	-- Valid start_date
/*	IF ( l_dsfv_rec.start_date IS NOT NULL ) AND
	( l_dsfv_rec.start_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_Start_Date( x_return_status, l_dsfv_rec );
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
	Validate_Start_Date( x_return_status, l_dsfv_rec );
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


	-- Validate fnctn_code
/*	IF ( l_dsfv_rec.fnctn_code IS NOT NULL ) AND
	( l_dsfv_rec.fnctn_code <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Fnctn_Code( l_dsfv_rec, x_return_status );
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
	Validate_Fnctn_Code( l_dsfv_rec, x_return_status );
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


	-- Valid source
/*	IF ( l_dsfv_rec.source IS NOT NULL ) AND
	( l_dsfv_rec.source <> OKC_API.G_MISS_CHAR ) THEN
		Validate_Source( x_return_status, l_dsfv_rec );
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
	Validate_Source( x_return_status, l_dsfv_rec );
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


	p_dsfv_rec := l_dsfv_rec;

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
  -- PROCEDURE Validate_Unique_Dsf_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Dsf_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Dsf_Record(
                                  x_return_status OUT NOCOPY    VARCHAR2,
                                  p_dsfv_rec      IN      dsfv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;

/*
CURSOR c1( p_id okl_data_src_fnctns_v.id%TYPE,
			 p_name okl_data_src_fnctns_v.name%TYPE,
			 p_version okl_data_src_fnctns_v.version%TYPE ) is
  SELECT 1
  FROM okl_data_src_fnctns_v
  WHERE  id = p_id
  AND	name = p_name
  AND	version = p_version
  AND    id <> nvl( p_dsfv_rec.id, -9999 );
*/

-- Changed the cursor select statement
CURSOR c1( p_id okl_data_src_fnctns_v.id%TYPE,
			 p_name okl_data_src_fnctns_v.name%TYPE,
			 p_version okl_data_src_fnctns_v.version%TYPE ) is
  SELECT 1
  FROM okl_data_src_fnctns_v
  WHERE  name = p_name
  AND	version = p_version
  AND    id <> nvl( p_dsfv_rec.id, -9999 );


  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN c1( p_dsfv_rec.id , p_dsfv_rec.name, p_dsfv_rec.version);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		OKC_API.set_message( 'OKL', G_UNQS, G_TABLE_TOKEN, 'Okl_Data_Src_Fnctns_V' );
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

  END Validate_Unique_Dsf_Record;


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
    p_dsfv_rec IN dsfv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	-- Validate_Unique_Dsf_Record
	Validate_Unique_Dsf_Record( x_return_status, p_dsfv_rec );
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

    -- Valid end date
	-- Suresh Gorantla: Added this call to Valid end_date.
	-- Valid_end_date
	IF ( p_dsfv_rec.end_date IS NOT NULL ) AND
	( p_dsfv_rec.end_date <> OKC_API.G_MISS_DATE ) THEN
		Validate_end_Date(p_dsfv_rec, x_return_status );
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

  END Validate_Record;


/** *** SBALASHA002 End *** **/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  -- RPOONUGA001: Add IN for p_to parameter in migrate procedures
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN dsfv_rec_type,
    p_to	IN OUT NOCOPY dsf_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.source := p_from.source;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.fnctn_code := p_from.fnctn_code;
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
    p_from	IN dsf_rec_type,
    p_to	IN OUT NOCOPY dsfv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.source := p_from.source;
    p_to.org_id := p_from.org_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.fnctn_code := p_from.fnctn_code;
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
    p_from	IN dsfv_rec_type,
    p_to	IN OUT NOCOPY OklDataSrcFnctnsTlRecType
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
    p_from	IN OklDataSrcFnctnsTlRecType,
    p_to	IN OUT NOCOPY dsfv_rec_type
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
  --------------------------------------------
  -- validate_row for:OKL_DATA_SRC_FNCTNS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsfv_rec                     dsfv_rec_type := p_dsfv_rec;
    l_dsf_rec                      dsf_rec_type;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
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
    l_return_status := Validate_Attributes(l_dsfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_dsfv_rec);
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
  -- PL/SQL TBL validate_row for:DSFV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dsfv_tbl.COUNT > 0) THEN
      i := p_dsfv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dsfv_rec                     => p_dsfv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_dsfv_tbl.LAST);
        i := p_dsfv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKL_DATA_SRC_FNCTNS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsf_rec                      IN dsf_rec_type,
    x_dsf_rec                      OUT NOCOPY dsf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsf_rec                      dsf_rec_type := p_dsf_rec;
    l_def_dsf_rec                  dsf_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dsf_rec IN  dsf_rec_type,
      x_dsf_rec OUT NOCOPY dsf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsf_rec := p_dsf_rec;
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
      p_dsf_rec,                         -- IN
      l_dsf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_DATA_SRC_FNCTNS_B(
        id,
        object_version_number,
        name,
        version,
        source,
        org_id,
        start_date,
        end_date,
        fnctn_code,
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
        l_dsf_rec.id,
        l_dsf_rec.object_version_number,
        l_dsf_rec.name,
        l_dsf_rec.version,
        l_dsf_rec.source,
        l_dsf_rec.org_id,
        l_dsf_rec.start_date,
        l_dsf_rec.end_date,
        l_dsf_rec.fnctn_code,
        l_dsf_rec.attribute_category,
        l_dsf_rec.attribute1,
        l_dsf_rec.attribute2,
        l_dsf_rec.attribute3,
        l_dsf_rec.attribute4,
        l_dsf_rec.attribute5,
        l_dsf_rec.attribute6,
        l_dsf_rec.attribute7,
        l_dsf_rec.attribute8,
        l_dsf_rec.attribute9,
        l_dsf_rec.attribute10,
        l_dsf_rec.attribute11,
        l_dsf_rec.attribute12,
        l_dsf_rec.attribute13,
        l_dsf_rec.attribute14,
        l_dsf_rec.attribute15,
        l_dsf_rec.created_by,
        l_dsf_rec.creation_date,
        l_dsf_rec.last_updated_by,
        l_dsf_rec.last_update_date,
        l_dsf_rec.last_update_login);
    -- Set OUT values
    x_dsf_rec := l_dsf_rec;
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
  -------------------------------------------
  -- insert_row for:OKL_DATA_SRC_FNCTNS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType,
    x_okl_data_src_fnctns_tl_rec   OUT NOCOPY OklDataSrcFnctnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType := p_okl_data_src_fnctns_tl_rec;
    ldefokldatasrcfnctnstlrec      OklDataSrcFnctnsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_data_src_fnctns_tl_rec IN  OklDataSrcFnctnsTlRecType,
      x_okl_data_src_fnctns_tl_rec OUT NOCOPY OklDataSrcFnctnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_data_src_fnctns_tl_rec := p_okl_data_src_fnctns_tl_rec;
      x_okl_data_src_fnctns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_data_src_fnctns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_data_src_fnctns_tl_rec,      -- IN
      l_okl_data_src_fnctns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_data_src_fnctns_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_DATA_SRC_FNCTNS_TL(
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
          l_okl_data_src_fnctns_tl_rec.id,
          l_okl_data_src_fnctns_tl_rec.language,
          l_okl_data_src_fnctns_tl_rec.source_lang,
          l_okl_data_src_fnctns_tl_rec.sfwt_flag,
          l_okl_data_src_fnctns_tl_rec.description,
          l_okl_data_src_fnctns_tl_rec.created_by,
          l_okl_data_src_fnctns_tl_rec.creation_date,
          l_okl_data_src_fnctns_tl_rec.last_updated_by,
          l_okl_data_src_fnctns_tl_rec.last_update_date,
          l_okl_data_src_fnctns_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_data_src_fnctns_tl_rec := l_okl_data_src_fnctns_tl_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_DATA_SRC_FNCTNS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsfv_rec                     dsfv_rec_type;
    l_def_dsfv_rec                 dsfv_rec_type;
    l_dsf_rec                      dsf_rec_type;
    lx_dsf_rec                     dsf_rec_type;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
    lx_okl_data_src_fnctns_tl_rec  OklDataSrcFnctnsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_dsfv_rec	IN dsfv_rec_type
    ) RETURN dsfv_rec_type IS
      l_dsfv_rec	dsfv_rec_type := p_dsfv_rec;
    BEGIN
      l_dsfv_rec.CREATION_DATE := SYSDATE;
      l_dsfv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_dsfv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_dsfv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_dsfv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_dsfv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dsfv_rec IN  dsfv_rec_type,
      x_dsfv_rec OUT NOCOPY dsfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsfv_rec := p_dsfv_rec;
      x_dsfv_rec.OBJECT_VERSION_NUMBER := 1;
      x_dsfv_rec.SFWT_FLAG := 'N';
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
    l_dsfv_rec := null_out_defaults(p_dsfv_rec);
    -- Set primary key value
    l_dsfv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_dsfv_rec,                        -- IN
      l_def_dsfv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_dsfv_rec := fill_who_columns(l_def_dsfv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_dsfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_dsfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_dsfv_rec, l_dsf_rec);
    migrate(l_def_dsfv_rec, l_okl_data_src_fnctns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dsf_rec,
      lx_dsf_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_dsf_rec, l_def_dsfv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_data_src_fnctns_tl_rec,
      lx_okl_data_src_fnctns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_data_src_fnctns_tl_rec, l_def_dsfv_rec);
    -- Set OUT values
    x_dsfv_rec := l_def_dsfv_rec;
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
  -- PL/SQL TBL insert_row for:DSFV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dsfv_tbl.COUNT > 0) THEN
      i := p_dsfv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dsfv_rec                     => p_dsfv_tbl(i),
          x_dsfv_rec                     => x_dsfv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_dsfv_tbl.LAST);
        i := p_dsfv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKL_DATA_SRC_FNCTNS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsf_rec                      IN dsf_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_dsf_rec IN dsf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DATA_SRC_FNCTNS_B
     WHERE ID = p_dsf_rec.id
       AND OBJECT_VERSION_NUMBER = p_dsf_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_dsf_rec IN dsf_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DATA_SRC_FNCTNS_B
    WHERE ID = p_dsf_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_DATA_SRC_FNCTNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_DATA_SRC_FNCTNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_dsf_rec);
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
      OPEN lchk_csr(p_dsf_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_dsf_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_dsf_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKL_DATA_SRC_FNCTNS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_data_src_fnctns_tl_rec IN OklDataSrcFnctnsTlRecType) IS
    SELECT *
      FROM OKL_DATA_SRC_FNCTNS_TL
     WHERE ID = p_okl_data_src_fnctns_tl_rec.id
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
      OPEN lock_csr(p_okl_data_src_fnctns_tl_rec);
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
  ----------------------------------------
  -- lock_row for:OKL_DATA_SRC_FNCTNS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsf_rec                      dsf_rec_type;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
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
    migrate(p_dsfv_rec, l_dsf_rec);
    migrate(p_dsfv_rec, l_okl_data_src_fnctns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dsf_rec
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
      l_okl_data_src_fnctns_tl_rec
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
  -- PL/SQL TBL lock_row for:DSFV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dsfv_tbl.COUNT > 0) THEN
      i := p_dsfv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dsfv_rec                     => p_dsfv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_dsfv_tbl.LAST);
        i := p_dsfv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKL_DATA_SRC_FNCTNS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsf_rec                      IN dsf_rec_type,
    x_dsf_rec                      OUT NOCOPY dsf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsf_rec                      dsf_rec_type := p_dsf_rec;
    l_def_dsf_rec                  dsf_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_dsf_rec	IN dsf_rec_type,
      x_dsf_rec	OUT NOCOPY dsf_rec_type
    ) RETURN VARCHAR2 IS
      l_dsf_rec                      dsf_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsf_rec := p_dsf_rec;
      -- Get current database values
      l_dsf_rec := get_rec(p_dsf_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_dsf_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.id := l_dsf_rec.id;
      END IF;
      IF (x_dsf_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.object_version_number := l_dsf_rec.object_version_number;
      END IF;
      IF (x_dsf_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.name := l_dsf_rec.name;
      END IF;
      IF (x_dsf_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.version := l_dsf_rec.version;
      END IF;
      IF (x_dsf_rec.source = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.source := l_dsf_rec.source;
      END IF;
      IF (x_dsf_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.org_id := l_dsf_rec.org_id;
      END IF;
      IF (x_dsf_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsf_rec.start_date := l_dsf_rec.start_date;
      END IF;
      IF (x_dsf_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsf_rec.end_date := l_dsf_rec.end_date;
      END IF;
      IF (x_dsf_rec.fnctn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.fnctn_code := l_dsf_rec.fnctn_code;
      END IF;
      IF (x_dsf_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute_category := l_dsf_rec.attribute_category;
      END IF;
      IF (x_dsf_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute1 := l_dsf_rec.attribute1;
      END IF;
      IF (x_dsf_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute2 := l_dsf_rec.attribute2;
      END IF;
      IF (x_dsf_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute3 := l_dsf_rec.attribute3;
      END IF;
      IF (x_dsf_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute4 := l_dsf_rec.attribute4;
      END IF;
      IF (x_dsf_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute5 := l_dsf_rec.attribute5;
      END IF;
      IF (x_dsf_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute6 := l_dsf_rec.attribute6;
      END IF;
      IF (x_dsf_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute7 := l_dsf_rec.attribute7;
      END IF;
      IF (x_dsf_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute8 := l_dsf_rec.attribute8;
      END IF;
      IF (x_dsf_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute9 := l_dsf_rec.attribute9;
      END IF;
      IF (x_dsf_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute10 := l_dsf_rec.attribute10;
      END IF;
      IF (x_dsf_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute11 := l_dsf_rec.attribute11;
      END IF;
      IF (x_dsf_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute12 := l_dsf_rec.attribute12;
      END IF;
      IF (x_dsf_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute13 := l_dsf_rec.attribute13;
      END IF;
      IF (x_dsf_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute14 := l_dsf_rec.attribute14;
      END IF;
      IF (x_dsf_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsf_rec.attribute15 := l_dsf_rec.attribute15;
      END IF;
      IF (x_dsf_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.created_by := l_dsf_rec.created_by;
      END IF;
      IF (x_dsf_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsf_rec.creation_date := l_dsf_rec.creation_date;
      END IF;
      IF (x_dsf_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.last_updated_by := l_dsf_rec.last_updated_by;
      END IF;
      IF (x_dsf_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsf_rec.last_update_date := l_dsf_rec.last_update_date;
      END IF;
      IF (x_dsf_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_dsf_rec.last_update_login := l_dsf_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dsf_rec IN  dsf_rec_type,
      x_dsf_rec OUT NOCOPY dsf_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsf_rec := p_dsf_rec;
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
      p_dsf_rec,                         -- IN
      l_dsf_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_dsf_rec, l_def_dsf_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_DATA_SRC_FNCTNS_B
    SET OBJECT_VERSION_NUMBER = l_def_dsf_rec.object_version_number,
        NAME = l_def_dsf_rec.name,
        VERSION = l_def_dsf_rec.version,
        SOURCE = l_def_dsf_rec.source,
        ORG_ID = l_def_dsf_rec.org_id,
        START_DATE = l_def_dsf_rec.start_date,
        END_DATE = l_def_dsf_rec.end_date,
        FNCTN_CODE = l_def_dsf_rec.fnctn_code,
        ATTRIBUTE_CATEGORY = l_def_dsf_rec.attribute_category,
        ATTRIBUTE1 = l_def_dsf_rec.attribute1,
        ATTRIBUTE2 = l_def_dsf_rec.attribute2,
        ATTRIBUTE3 = l_def_dsf_rec.attribute3,
        ATTRIBUTE4 = l_def_dsf_rec.attribute4,
        ATTRIBUTE5 = l_def_dsf_rec.attribute5,
        ATTRIBUTE6 = l_def_dsf_rec.attribute6,
        ATTRIBUTE7 = l_def_dsf_rec.attribute7,
        ATTRIBUTE8 = l_def_dsf_rec.attribute8,
        ATTRIBUTE9 = l_def_dsf_rec.attribute9,
        ATTRIBUTE10 = l_def_dsf_rec.attribute10,
        ATTRIBUTE11 = l_def_dsf_rec.attribute11,
        ATTRIBUTE12 = l_def_dsf_rec.attribute12,
        ATTRIBUTE13 = l_def_dsf_rec.attribute13,
        ATTRIBUTE14 = l_def_dsf_rec.attribute14,
        ATTRIBUTE15 = l_def_dsf_rec.attribute15,
        CREATED_BY = l_def_dsf_rec.created_by,
        CREATION_DATE = l_def_dsf_rec.creation_date,
        LAST_UPDATED_BY = l_def_dsf_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_dsf_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_dsf_rec.last_update_login
    WHERE ID = l_def_dsf_rec.id;

    x_dsf_rec := l_def_dsf_rec;
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
  -------------------------------------------
  -- update_row for:OKL_DATA_SRC_FNCTNS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType,
    x_okl_data_src_fnctns_tl_rec   OUT NOCOPY OklDataSrcFnctnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType := p_okl_data_src_fnctns_tl_rec;
    ldefokldatasrcfnctnstlrec      OklDataSrcFnctnsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_data_src_fnctns_tl_rec	IN OklDataSrcFnctnsTlRecType,
      x_okl_data_src_fnctns_tl_rec	OUT NOCOPY OklDataSrcFnctnsTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_data_src_fnctns_tl_rec := p_okl_data_src_fnctns_tl_rec;
      -- Get current database values
      l_okl_data_src_fnctns_tl_rec := get_rec(p_okl_data_src_fnctns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_data_src_fnctns_tl_rec.id := l_okl_data_src_fnctns_tl_rec.id;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_data_src_fnctns_tl_rec.language := l_okl_data_src_fnctns_tl_rec.language;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_data_src_fnctns_tl_rec.source_lang := l_okl_data_src_fnctns_tl_rec.source_lang;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_data_src_fnctns_tl_rec.sfwt_flag := l_okl_data_src_fnctns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_data_src_fnctns_tl_rec.description := l_okl_data_src_fnctns_tl_rec.description;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_data_src_fnctns_tl_rec.created_by := l_okl_data_src_fnctns_tl_rec.created_by;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_data_src_fnctns_tl_rec.creation_date := l_okl_data_src_fnctns_tl_rec.creation_date;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_data_src_fnctns_tl_rec.last_updated_by := l_okl_data_src_fnctns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_data_src_fnctns_tl_rec.last_update_date := l_okl_data_src_fnctns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_data_src_fnctns_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_data_src_fnctns_tl_rec.last_update_login := l_okl_data_src_fnctns_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_data_src_fnctns_tl_rec IN  OklDataSrcFnctnsTlRecType,
      x_okl_data_src_fnctns_tl_rec OUT NOCOPY OklDataSrcFnctnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_data_src_fnctns_tl_rec := p_okl_data_src_fnctns_tl_rec;
      x_okl_data_src_fnctns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_data_src_fnctns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_data_src_fnctns_tl_rec,      -- IN
      l_okl_data_src_fnctns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_data_src_fnctns_tl_rec, ldefokldatasrcfnctnstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_DATA_SRC_FNCTNS_TL
    SET DESCRIPTION = ldefokldatasrcfnctnstlrec.description,
        CREATED_BY = ldefokldatasrcfnctnstlrec.created_by,
        SOURCE_LANG = ldefokldatasrcfnctnstlrec.source_lang,
        CREATION_DATE = ldefokldatasrcfnctnstlrec.creation_date,
        LAST_UPDATED_BY = ldefokldatasrcfnctnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokldatasrcfnctnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokldatasrcfnctnstlrec.last_update_login
    WHERE ID = ldefokldatasrcfnctnstlrec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_DATA_SRC_FNCTNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokldatasrcfnctnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_data_src_fnctns_tl_rec := ldefokldatasrcfnctnstlrec;
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
  ------------------------------------------
  -- update_row for:OKL_DATA_SRC_FNCTNS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsfv_rec                     dsfv_rec_type := p_dsfv_rec;
    l_def_dsfv_rec                 dsfv_rec_type;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
    lx_okl_data_src_fnctns_tl_rec  OklDataSrcFnctnsTlRecType;
    l_dsf_rec                      dsf_rec_type;
    lx_dsf_rec                     dsf_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_dsfv_rec	IN dsfv_rec_type
    ) RETURN dsfv_rec_type IS
      l_dsfv_rec	dsfv_rec_type := p_dsfv_rec;
    BEGIN
      l_dsfv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_dsfv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_dsfv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_dsfv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_dsfv_rec	IN dsfv_rec_type,
      x_dsfv_rec	OUT NOCOPY dsfv_rec_type
    ) RETURN VARCHAR2 IS
      l_dsfv_rec                     dsfv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsfv_rec := p_dsfv_rec;
      -- Get current database values
      l_dsfv_rec := get_rec(p_dsfv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_dsfv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.id := l_dsfv_rec.id;
      END IF;
      IF (x_dsfv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.object_version_number := l_dsfv_rec.object_version_number;
      END IF;
      IF (x_dsfv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.sfwt_flag := l_dsfv_rec.sfwt_flag;
      END IF;
      IF (x_dsfv_rec.fnctn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.fnctn_code := l_dsfv_rec.fnctn_code;
      END IF;
      IF (x_dsfv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.name := l_dsfv_rec.name;
      END IF;
      IF (x_dsfv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.description := l_dsfv_rec.description;
      END IF;
      IF (x_dsfv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.version := l_dsfv_rec.version;
      END IF;
      IF (x_dsfv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsfv_rec.start_date := l_dsfv_rec.start_date;
      END IF;
      IF (x_dsfv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsfv_rec.end_date := l_dsfv_rec.end_date;
      END IF;
      IF (x_dsfv_rec.source = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.source := l_dsfv_rec.source;
      END IF;
      IF (x_dsfv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute_category := l_dsfv_rec.attribute_category;
      END IF;
      IF (x_dsfv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute1 := l_dsfv_rec.attribute1;
      END IF;
      IF (x_dsfv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute2 := l_dsfv_rec.attribute2;
      END IF;
      IF (x_dsfv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute3 := l_dsfv_rec.attribute3;
      END IF;
      IF (x_dsfv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute4 := l_dsfv_rec.attribute4;
      END IF;
      IF (x_dsfv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute5 := l_dsfv_rec.attribute5;
      END IF;
      IF (x_dsfv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute6 := l_dsfv_rec.attribute6;
      END IF;
      IF (x_dsfv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute7 := l_dsfv_rec.attribute7;
      END IF;
      IF (x_dsfv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute8 := l_dsfv_rec.attribute8;
      END IF;
      IF (x_dsfv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute9 := l_dsfv_rec.attribute9;
      END IF;
      IF (x_dsfv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute10 := l_dsfv_rec.attribute10;
      END IF;
      IF (x_dsfv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute11 := l_dsfv_rec.attribute11;
      END IF;
      IF (x_dsfv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute12 := l_dsfv_rec.attribute12;
      END IF;
      IF (x_dsfv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute13 := l_dsfv_rec.attribute13;
      END IF;
      IF (x_dsfv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute14 := l_dsfv_rec.attribute14;
      END IF;
      IF (x_dsfv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_dsfv_rec.attribute15 := l_dsfv_rec.attribute15;
      END IF;
      IF (x_dsfv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.org_id := l_dsfv_rec.org_id;
      END IF;
      IF (x_dsfv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.created_by := l_dsfv_rec.created_by;
      END IF;
      IF (x_dsfv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsfv_rec.creation_date := l_dsfv_rec.creation_date;
      END IF;
      IF (x_dsfv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.last_updated_by := l_dsfv_rec.last_updated_by;
      END IF;
      IF (x_dsfv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_dsfv_rec.last_update_date := l_dsfv_rec.last_update_date;
      END IF;
      IF (x_dsfv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_dsfv_rec.last_update_login := l_dsfv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dsfv_rec IN  dsfv_rec_type,
      x_dsfv_rec OUT NOCOPY dsfv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dsfv_rec := p_dsfv_rec;
      x_dsfv_rec.OBJECT_VERSION_NUMBER := NVL(x_dsfv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_dsfv_rec,                        -- IN
      l_dsfv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_dsfv_rec, l_def_dsfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_dsfv_rec := fill_who_columns(l_def_dsfv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_dsfv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_dsfv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_dsfv_rec, l_okl_data_src_fnctns_tl_rec);
    migrate(l_def_dsfv_rec, l_dsf_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_data_src_fnctns_tl_rec,
      lx_okl_data_src_fnctns_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_data_src_fnctns_tl_rec, l_def_dsfv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dsf_rec,
      lx_dsf_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_dsf_rec, l_def_dsfv_rec);
    x_dsfv_rec := l_def_dsfv_rec;
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
  -- PL/SQL TBL update_row for:DSFV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dsfv_tbl.COUNT > 0) THEN
      i := p_dsfv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dsfv_rec                     => p_dsfv_tbl(i),
          x_dsfv_rec                     => x_dsfv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_dsfv_tbl.LAST);
        i := p_dsfv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKL_DATA_SRC_FNCTNS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsf_rec                      IN dsf_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsf_rec                      dsf_rec_type:= p_dsf_rec;
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
    DELETE FROM OKL_DATA_SRC_FNCTNS_B
     WHERE ID = l_dsf_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_DATA_SRC_FNCTNS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_data_src_fnctns_tl_rec   IN OklDataSrcFnctnsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType:= p_okl_data_src_fnctns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKL_DATA_SRC_FNCTNS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_data_src_fnctns_tl_rec IN  OklDataSrcFnctnsTlRecType,
      x_okl_data_src_fnctns_tl_rec OUT NOCOPY OklDataSrcFnctnsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_data_src_fnctns_tl_rec := p_okl_data_src_fnctns_tl_rec;
      x_okl_data_src_fnctns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_data_src_fnctns_tl_rec,      -- IN
      l_okl_data_src_fnctns_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_DATA_SRC_FNCTNS_TL
     WHERE ID = l_okl_data_src_fnctns_tl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_DATA_SRC_FNCTNS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dsfv_rec                     dsfv_rec_type := p_dsfv_rec;
    l_okl_data_src_fnctns_tl_rec   OklDataSrcFnctnsTlRecType;
    l_dsf_rec                      dsf_rec_type;
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
    migrate(l_dsfv_rec, l_okl_data_src_fnctns_tl_rec);
    migrate(l_dsfv_rec, l_dsf_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_data_src_fnctns_tl_rec
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
      l_dsf_rec
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
  -- PL/SQL TBL delete_row for:DSFV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dsfv_tbl.COUNT > 0) THEN
      i := p_dsfv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dsfv_rec                     => p_dsfv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_dsfv_tbl.LAST);
        i := p_dsfv_tbl.NEXT(i);
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

  PROCEDURE TRANSLATE_ROW(p_dsfv_rec IN dsfv_rec_type,
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
      FROM OKL_DATA_SRC_FNCTNS_TL
      where ID = to_number(p_dsfv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
     	UPDATE OKL_DATA_SRC_FNCTNS_TL
    	SET	DESCRIPTION       = p_dsfv_rec.DESCRIPTION,
        	LAST_UPDATE_DATE  = f_ludate,
        	LAST_UPDATED_BY   = f_luby,
        	LAST_UPDATE_LOGIN = 0,
        	SOURCE_LANG       = USERENV('LANG')
   	WHERE ID = to_number(p_dsfv_rec.id)
     	AND USERENV('LANG') IN (language,source_lang);
      END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_dsfv_rec IN dsfv_rec_type,
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
      FROM OKL_DATA_SRC_FNCTNS_B
      where ID = p_dsfv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        --Update _b
        UPDATE OKL_DATA_SRC_FNCTNS_B
        SET
         OBJECT_VERSION_NUMBER = TO_NUMBER(p_dsfv_rec.OBJECT_VERSION_NUMBER),
         NAME          = p_dsfv_rec.NAME,
 	     SOURCE		   = p_dsfv_rec.SOURCE,
 	     ORG_ID	   	   = TO_NUMBER(p_dsfv_rec.org_id),
 	     START_DATE	   = p_dsfv_rec.start_date,
 	     END_DATE	   = p_dsfv_rec.end_date,
 	     FNCTN_CODE	   = p_dsfv_rec.fnctn_code,
         ATTRIBUTE_CATEGORY	   = p_dsfv_rec.attribute_category,
 	     ATTRIBUTE1	   = p_dsfv_rec.attribute1,
 	     ATTRIBUTE2	   = p_dsfv_rec.attribute2,
 	     ATTRIBUTE3    = p_dsfv_rec.attribute3,
 	     ATTRIBUTE4    = p_dsfv_rec.attribute4,
 	     ATTRIBUTE5    = p_dsfv_rec.attribute5,
 	     ATTRIBUTE6    = p_dsfv_rec.attribute6,
 	     ATTRIBUTE7    = p_dsfv_rec.attribute7,
 	     ATTRIBUTE8    = p_dsfv_rec.attribute8,
 	     ATTRIBUTE9    = p_dsfv_rec.attribute9,
 	     ATTRIBUTE10   = p_dsfv_rec.attribute10,
 	     ATTRIBUTE11   = p_dsfv_rec.attribute11,
 	     ATTRIBUTE12   = p_dsfv_rec.attribute12,
 	     ATTRIBUTE13   = p_dsfv_rec.attribute13,
 	     ATTRIBUTE14   = p_dsfv_rec.attribute14,
 	     ATTRIBUTE15   = p_dsfv_rec.attribute15,
         LAST_UPDATE_DATE  = f_ludate,
         LAST_UPDATED_BY   = f_luby,
         LAST_UPDATE_LOGIN = 0
        WHERE ID = to_number(p_dsfv_rec.id);
        --Update _TL
        UPDATE OKL_DATA_SRC_FNCTNS_TL
        SET	DESCRIPTION       = p_dsfv_rec.DESCRIPTION,
            LAST_UPDATE_DATE  = f_ludate,
            LAST_UPDATED_BY   = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG       = USERENV('LANG')
        WHERE ID = to_number(p_dsfv_rec.id)
          AND USERENV('LANG') IN (language,source_lang);

        IF(sql%notfound) THEN
           INSERT INTO OKL_DATA_SRC_FNCTNS_TL
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
    	   SELECT  TO_NUMBER(p_dsfv_rec.id),
		    L.LANGUAGE_CODE,
    		userenv('LANG'),
    		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
    		p_dsfv_rec.description,
    		f_luby,
    		f_ludate,
    		f_luby,
    		f_ludate,
    		0
	       FROM FND_LANGUAGES L
	       WHERE L.INSTALLED_FLAG IN ('I','B')
    	    AND NOT EXISTS
             (SELECT NULL
              FROM   OKL_DATA_SRC_FNCTNS_TL TL
     	      WHERE  TL.ID = TO_NUMBER(p_dsfv_rec.id)
              AND    TL.LANGUAGE = L.LANGUAGE_CODE);
        END IF;


     END IF;

    END;
    EXCEPTION
     when no_data_found then
      INSERT INTO OKL_DATA_SRC_FNCTNS_B
     	(
     	ID,
     	OBJECT_VERSION_NUMBER,
     	NAME,
     	VERSION,
     	SOURCE,
     	ORG_ID,
     	START_DATE,
     	END_DATE,
     	FNCTN_CODE,
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
     	TO_NUMBER(p_dsfv_rec.id),
     	TO_NUMBER(p_dsfv_rec.object_version_number),
     	p_dsfv_rec.name,
     	p_dsfv_rec.version,
     	p_dsfv_rec.source,
     	TO_NUMBER(p_dsfv_rec.org_id),
     	p_dsfv_rec.start_date,
     	p_dsfv_rec.end_date,
     	p_dsfv_rec.FNCTN_CODE,
     	p_dsfv_rec.ATTRIBUTE_CATEGORY,
     	p_dsfv_rec.ATTRIBUTE1,
     	p_dsfv_rec.ATTRIBUTE2,
     	p_dsfv_rec.ATTRIBUTE3,
     	p_dsfv_rec.ATTRIBUTE4,
     	p_dsfv_rec.ATTRIBUTE5,
     	p_dsfv_rec.ATTRIBUTE6,
     	p_dsfv_rec.ATTRIBUTE7,
     	p_dsfv_rec.ATTRIBUTE8,
     	p_dsfv_rec.ATTRIBUTE9,
     	p_dsfv_rec.ATTRIBUTE10,
     	p_dsfv_rec.ATTRIBUTE11,
     	p_dsfv_rec.ATTRIBUTE12,
     	p_dsfv_rec.ATTRIBUTE13,
     	p_dsfv_rec.ATTRIBUTE14,
     	p_dsfv_rec.ATTRIBUTE15,
     	f_luby,
     	f_ludate,
     	f_luby,
     	f_ludate,
     	0
       FROM DUAL
       WHERE NOT EXISTS (SELECT 1
              from OKL_DATA_SRC_FNCTNS_B
              where (ID = TO_NUMBER(p_dsfv_rec.id) OR
             (NAME = p_dsfv_rec.name AND VERSION = p_dsfv_rec.version)));

       INSERT INTO OKL_DATA_SRC_FNCTNS_TL
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
     	SELECT  TO_NUMBER(p_dsfv_rec.id),
     		L.LANGUAGE_CODE,
     		userenv('LANG'),
     		decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
     		p_dsfv_rec.DESCRIPTION,
     		f_luby,
     		f_ludate,
     		f_luby,
     		f_ludate,
     		0
     	FROM FND_LANGUAGES L
     	WHERE L.INSTALLED_FLAG IN ('I','B')
         	AND NOT EXISTS
               (SELECT NULL
                FROM   OKL_DATA_SRC_FNCTNS_TL TL
          	   WHERE  TL.ID = TO_NUMBER(p_dsfv_rec.id)
                AND    TL.LANGUAGE = L.LANGUAGE_CODE);
 END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode		     IN VARCHAR2,
    p_data_src_fnctn_id      IN VARCHAR2,
    p_name                   IN VARCHAR2,
    p_version                IN VARCHAR2,
    p_object_version_number  IN VARCHAR2,
    p_source                 IN VARCHAR2,
    p_org_id                 IN VARCHAR2,
    p_start_date             IN VARCHAR2,
    p_end_date               IN VARCHAR2,
    p_fnctn_code             IN VARCHAR2,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2,
    p_description            IN VARCHAR2,
    p_owner                  IN VARCHAR2,
    p_last_update_date       IN VARCHAR2)IS

  l_api_version   CONSTANT number := 1;
  l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
  l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
  l_msg_count              number;
  l_msg_data               varchar2(4000);
  l_init_msg_list          VARCHAR2(1):= 'T';
  l_dsfv_rec               dsfv_rec_type;

  BEGIN
  --Prepare Record Structure for Insert/Update
    l_dsfv_rec.id                     :=  p_data_src_fnctn_id;
    l_dsfv_rec.object_version_number  :=  p_object_version_number;
    l_dsfv_rec.fnctn_code             :=  p_fnctn_code;
    l_dsfv_rec.name                   :=  p_name;
    l_dsfv_rec.description            :=  p_description;
    l_dsfv_rec.version                :=  p_version;
    l_dsfv_rec.start_date             :=  TO_DATE(p_start_date,'YYYY/MM/DD');
    l_dsfv_rec.end_date               :=  TO_DATE(p_end_date,'YYYY/MM/DD');
    l_dsfv_rec.source                 :=  p_source;
    l_dsfv_rec.attribute_category     :=  p_attribute_category;
    l_dsfv_rec.attribute1             :=  p_attribute1;
    l_dsfv_rec.attribute2             :=  p_attribute2;
    l_dsfv_rec.attribute3             :=  p_attribute3;
    l_dsfv_rec.attribute4             :=  p_attribute4;
    l_dsfv_rec.attribute5             :=  p_attribute5;
    l_dsfv_rec.attribute6             :=  p_attribute6;
    l_dsfv_rec.attribute7             :=  p_attribute7;
    l_dsfv_rec.attribute8             :=  p_attribute8;
    l_dsfv_rec.attribute9             :=  p_attribute9;
    l_dsfv_rec.attribute10            :=  p_attribute10;
    l_dsfv_rec.attribute11            :=  p_attribute11;
    l_dsfv_rec.attribute12            :=  p_attribute12;
    l_dsfv_rec.attribute13            :=  p_attribute13;
    l_dsfv_rec.attribute14            :=  p_attribute14;
    l_dsfv_rec.attribute15            :=  p_attribute15;
    l_dsfv_rec.org_id                 :=  p_org_id;

   IF(p_upload_mode = 'NLS') then
	 OKL_DSF_PVT.TRANSLATE_ROW(p_dsfv_rec => l_dsfv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_DSF_PVT.LOAD_ROW(p_dsfv_rec => l_dsfv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;
 END LOAD_SEED_ROW;

END OKL_DSF_PVT;

/

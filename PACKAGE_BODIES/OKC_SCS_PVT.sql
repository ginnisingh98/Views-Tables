--------------------------------------------------------
--  DDL for Package Body OKC_SCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SCS_PVT" AS
/* $Header: OKCSSCSB.pls 120.0 2005/05/25 22:31:59 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
    DELETE FROM OKC_SUBCLASSES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_SUBCLASSES_B B
         WHERE B.CODE = T.CODE
        );

    UPDATE OKC_SUBCLASSES_TL T SET (
        MEANING,
        DESCRIPTION) = (SELECT
                                  B.MEANING,
                                  B.DESCRIPTION
                                FROM OKC_SUBCLASSES_TL B
                               WHERE B.CODE = T.CODE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.CODE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.CODE,
                  SUBT.LANGUAGE
                FROM OKC_SUBCLASSES_TL SUBB, OKC_SUBCLASSES_TL SUBT
               WHERE SUBB.CODE = SUBT.CODE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.MEANING <> SUBT.MEANING
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKC_SUBCLASSES_TL (
        CODE,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        MEANING,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.CODE,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.MEANING,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_SUBCLASSES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_SUBCLASSES_TL T
                     WHERE T.CODE = B.CODE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SUBCLASSES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scs_rec                      IN scs_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scs_rec_type IS
    CURSOR scs_pk_csr (p_code               IN VARCHAR2) IS
    SELECT
            CODE,
            CLS_CODE,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CREATE_OPP_YN,
            ACCESS_LEVEL
      FROM Okc_Subclasses_B
     WHERE okc_subclasses_b.code = p_code;
    l_scs_pk                       scs_pk_csr%ROWTYPE;
    l_scs_rec                      scs_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN scs_pk_csr (p_scs_rec.code);
    FETCH scs_pk_csr INTO
              l_scs_rec.CODE,
              l_scs_rec.CLS_CODE,
              l_scs_rec.START_DATE,
              l_scs_rec.END_DATE,
              l_scs_rec.OBJECT_VERSION_NUMBER,
              l_scs_rec.CREATED_BY,
              l_scs_rec.CREATION_DATE,
              l_scs_rec.LAST_UPDATED_BY,
              l_scs_rec.LAST_UPDATE_DATE,
              l_scs_rec.LAST_UPDATE_LOGIN,
              l_scs_rec.CREATE_OPP_YN,
              l_scs_rec.ACCESS_LEVEL;
    x_no_data_found := scs_pk_csr%NOTFOUND;
    CLOSE scs_pk_csr;
    RETURN(l_scs_rec);
  END get_rec;

  FUNCTION get_rec (
    p_scs_rec                      IN scs_rec_type
  ) RETURN scs_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_scs_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SUBCLASSES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_subclasses_tl_rec_type IS
    CURSOR scs_pktl_csr (p_code               IN VARCHAR2,
                         p_language           IN VARCHAR2) IS
    SELECT
            CODE,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            MEANING,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Subclasses_Tl
     WHERE okc_subclasses_tl.code = p_code
       AND okc_subclasses_tl.language = p_language;
    l_scs_pktl                     scs_pktl_csr%ROWTYPE;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN scs_pktl_csr (p_okc_subclasses_tl_rec.code,
                       p_okc_subclasses_tl_rec.language);
    FETCH scs_pktl_csr INTO
              l_okc_subclasses_tl_rec.CODE,
              l_okc_subclasses_tl_rec.LANGUAGE,
              l_okc_subclasses_tl_rec.SOURCE_LANG,
              l_okc_subclasses_tl_rec.SFWT_FLAG,
              l_okc_subclasses_tl_rec.MEANING,
              l_okc_subclasses_tl_rec.DESCRIPTION,
              l_okc_subclasses_tl_rec.CREATED_BY,
              l_okc_subclasses_tl_rec.CREATION_DATE,
              l_okc_subclasses_tl_rec.LAST_UPDATED_BY,
              l_okc_subclasses_tl_rec.LAST_UPDATE_DATE,
              l_okc_subclasses_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := scs_pktl_csr%NOTFOUND;
    CLOSE scs_pktl_csr;
    RETURN(l_okc_subclasses_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type
  ) RETURN okc_subclasses_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_subclasses_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SUBCLASSES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scsv_rec                     IN scsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scsv_rec_type IS
    CURSOR okc_scsv_pk_csr (p_code               IN VARCHAR2) IS
    SELECT
            CODE,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CLS_CODE,
            MEANING,
            DESCRIPTION,
            START_DATE,
            END_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CREATE_OPP_YN,
            ACCESS_LEVEL
     FROM Okc_Subclasses_V
     WHERE okc_subclasses_v.code = p_code;
    l_okc_scsv_pk                  okc_scsv_pk_csr%ROWTYPE;
    l_scsv_rec                     scsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_scsv_pk_csr (p_scsv_rec.code);
    FETCH okc_scsv_pk_csr INTO
              l_scsv_rec.CODE,
              l_scsv_rec.OBJECT_VERSION_NUMBER,
              l_scsv_rec.SFWT_FLAG,
              l_scsv_rec.CLS_CODE,
              l_scsv_rec.MEANING,
              l_scsv_rec.DESCRIPTION,
              l_scsv_rec.START_DATE,
              l_scsv_rec.END_DATE,
              l_scsv_rec.CREATED_BY,
              l_scsv_rec.CREATION_DATE,
              l_scsv_rec.LAST_UPDATED_BY,
              l_scsv_rec.LAST_UPDATE_DATE,
              l_scsv_rec.LAST_UPDATE_LOGIN,
              l_scsv_rec.CREATE_OPP_YN,
              l_scsv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_scsv_pk_csr%NOTFOUND;
    CLOSE okc_scsv_pk_csr;
    RETURN(l_scsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_scsv_rec                     IN scsv_rec_type
  ) RETURN scsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_scsv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SUBCLASSES_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_scsv_rec	IN scsv_rec_type
  ) RETURN scsv_rec_type IS
    l_scsv_rec	scsv_rec_type := p_scsv_rec;
  BEGIN
    IF (l_scsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_scsv_rec.object_version_number := NULL;
    END IF;
    IF (l_scsv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_scsv_rec.cls_code = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.cls_code := NULL;
    END IF;
    IF (l_scsv_rec.meaning = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.meaning := NULL;
    END IF;
    IF (l_scsv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.description := NULL;
    END IF;
    IF (l_scsv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_scsv_rec.start_date := NULL;
    END IF;
    IF (l_scsv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_scsv_rec.end_date := NULL;
    END IF;
    IF (l_scsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_scsv_rec.created_by := NULL;
    END IF;
    IF (l_scsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_scsv_rec.creation_date := NULL;
    END IF;
    IF (l_scsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_scsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_scsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_scsv_rec.last_update_date := NULL;
    END IF;
    IF (l_scsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_scsv_rec.last_update_login := NULL;
    END IF;
    IF (l_scsv_rec.create_opp_yn = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.create_opp_yn := NULL;
    END IF;
    IF (l_scsv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_scsv_rec.access_level := NULL;
    END IF;

    RETURN(l_scsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_code(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.code = OKC_API.G_MISS_CHAR OR
       p_scsv_rec.code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_scsv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_cls_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_cls_code(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.cls_code = OKC_API.G_MISS_CHAR OR
       p_scsv_rec.cls_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cls_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_cls_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_meaning
  ---------------------------------------------------------------------------
  PROCEDURE validate_meaning(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.meaning = OKC_API.G_MISS_CHAR OR
       p_scsv_rec.meaning IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'meaning');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_meaning;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_description
  ---------------------------------------------------------------------------
  PROCEDURE validate_description(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.description = OKC_API.G_MISS_CHAR OR
       p_scsv_rec.description IS NULL
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN,
                          SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_description;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(
    p_scsv_rec          IN scsv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_scsv_rec.start_date = OKC_API.G_MISS_DATE OR
       p_scsv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_CREATE_OPP_YN
  ---------------------------------------------------------------------------
PROCEDURE validate_create_opp_yn(
          p_scsv_rec      IN    scsv_rec_type,
          x_return_status 	OUT NOCOPY VARCHAR2) IS
  Begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_scsv_rec.create_opp_yn <> OKC_API.G_MISS_CHAR and
  	   p_scsv_rec.create_opp_yn IS NOT NULL)
    Then
       If p_scsv_rec.create_opp_yn NOT IN ('Y','N') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
				 p_msg_name	=> g_invalid_value,
				 p_token1	=> g_col_name_token,
				 p_token1_value	=> 'create_opp_yn');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
	     raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End validate_create_opp_yn;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_ACCESS_LEVEL
  ---------------------------------------------------------------------------
PROCEDURE validate_access_level(
          p_scsv_rec      IN    scsv_rec_type,
          x_return_status 	OUT NOCOPY VARCHAR2) IS
  Begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_scsv_rec.access_level <> OKC_API.G_MISS_CHAR and
  	   p_scsv_rec.access_level IS NOT NULL)
    Then
       If p_scsv_rec.access_level NOT IN ('S','E', 'U') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
				 p_msg_name	=> g_invalid_value,
				 p_token1	=> g_col_name_token,
				 p_token1_value	=> 'access_level');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
	     raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End validate_access_level;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKC_SUBCLASSES_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_scsv_rec IN  scsv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
    VALIDATE_code(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_object_version_number(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_cls_code(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_meaning(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_description(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_start_date(p_scsv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
         x_return_status := l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_create_opp_yn(p_scsv_rec, l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
         x_return_status := l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_access_level(p_scsv_rec, l_return_status);
    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
         x_return_status := l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;


    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      return(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_SUBCLASSES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_scsv_rec IN scsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_scsv_rec IN scsv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_clsv_pk_csr (p_code               IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Classes_V
       WHERE okc_classes_v.code   = p_code;
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_scsv_rec.CLS_CODE IS NOT NULL)
      THEN
        OPEN okc_clsv_pk_csr(p_scsv_rec.CLS_CODE);
        FETCH okc_clsv_pk_csr INTO l_dummy;
        l_row_notfound := okc_clsv_pk_csr%NOTFOUND;
        CLOSE okc_clsv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    IF p_scsv_rec.start_date IS NOT NULL AND
       p_scsv_rec.end_date IS NOT NULL THEN
      IF p_scsv_rec.end_date < p_scsv_rec.start_date THEN
        OKC_API.set_message(G_APP_NAME, 'OKC_INVALID_END_DATE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    l_return_status := validate_foreign_keys (p_scsv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN scsv_rec_type,
    p_to	OUT NOCOPY scs_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.cls_code := p_from.cls_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.create_opp_yn := p_from.create_opp_yn;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN scs_rec_type,
    p_to	IN OUT NOCOPY scsv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.cls_code := p_from.cls_code;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.create_opp_yn := p_from.create_opp_yn;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN scsv_rec_type,
    p_to	OUT NOCOPY okc_subclasses_tl_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_subclasses_tl_rec_type,
    p_to	IN OUT NOCOPY scsv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.meaning := p_from.meaning;
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
  -- validate_row for:OKC_SUBCLASSES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
    l_scs_rec                      scs_rec_type;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_scsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_scsv_rec);
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
  -- PL/SQL TBL validate_row for:SCSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN scsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scsv_tbl.COUNT > 0) THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scsv_rec                     => p_scsv_tbl(i));
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
  -------------------------------------
  -- insert_row for:OKC_SUBCLASSES_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scs_rec                      IN scs_rec_type,
    x_scs_rec                      OUT NOCOPY scs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scs_rec                      scs_rec_type := p_scs_rec;
    l_def_scs_rec                  scs_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_scs_rec IN  scs_rec_type,
      x_scs_rec OUT NOCOPY scs_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scs_rec := p_scs_rec;
      x_scs_rec.CREATE_OPP_YN := UPPER(x_scs_rec.CREATE_OPP_YN);
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
      p_scs_rec,                         -- IN
      l_scs_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SUBCLASSES_B(
        code,
        cls_code,
        start_date,
        end_date,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        create_opp_yn,
        access_level)
      VALUES (
        l_scs_rec.code,
        l_scs_rec.cls_code,
        l_scs_rec.start_date,
        l_scs_rec.end_date,
        l_scs_rec.object_version_number,
        l_scs_rec.created_by,
        l_scs_rec.creation_date,
        l_scs_rec.last_updated_by,
        l_scs_rec.last_update_date,
        l_scs_rec.last_update_login,
        l_scs_rec.create_opp_yn,
        l_scs_rec.access_level);
    -- Set OUT values
    x_scs_rec := l_scs_rec;
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
  -- insert_row for:OKC_SUBCLASSES_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type,
    x_okc_subclasses_tl_rec        OUT NOCOPY okc_subclasses_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type := p_okc_subclasses_tl_rec;
    l_def_okc_subclasses_tl_rec    okc_subclasses_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_subclasses_tl_rec IN  okc_subclasses_tl_rec_type,
      x_okc_subclasses_tl_rec OUT NOCOPY okc_subclasses_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_subclasses_tl_rec := p_okc_subclasses_tl_rec;
      x_okc_subclasses_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_subclasses_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_subclasses_tl_rec,           -- IN
      l_okc_subclasses_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_subclasses_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_SUBCLASSES_TL(
          code,
          language,
          source_lang,
          sfwt_flag,
          meaning,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_subclasses_tl_rec.code,
          l_okc_subclasses_tl_rec.language,
          l_okc_subclasses_tl_rec.source_lang,
          l_okc_subclasses_tl_rec.sfwt_flag,
          l_okc_subclasses_tl_rec.meaning,
          l_okc_subclasses_tl_rec.description,
          l_okc_subclasses_tl_rec.created_by,
          l_okc_subclasses_tl_rec.creation_date,
          l_okc_subclasses_tl_rec.last_updated_by,
          l_okc_subclasses_tl_rec.last_update_date,
          l_okc_subclasses_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_subclasses_tl_rec := l_okc_subclasses_tl_rec;
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
  -- insert_row for:OKC_SUBCLASSES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scsv_rec                     scsv_rec_type;
    l_def_scsv_rec                 scsv_rec_type;
    l_scs_rec                      scs_rec_type;
    lx_scs_rec                     scs_rec_type;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
    lx_okc_subclasses_tl_rec       okc_subclasses_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scsv_rec	IN scsv_rec_type
    ) RETURN scsv_rec_type IS
      l_scsv_rec	scsv_rec_type := p_scsv_rec;
    BEGIN
      l_scsv_rec.CREATION_DATE := SYSDATE;
      l_scsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_scsv_rec.LAST_UPDATE_DATE := l_scsv_rec.CREATION_DATE;
      l_scsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_scsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_scsv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_scsv_rec IN  scsv_rec_type,
      x_scsv_rec OUT NOCOPY scsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scsv_rec := p_scsv_rec;
      x_scsv_rec.OBJECT_VERSION_NUMBER := 1;
      x_scsv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
    -------------------------------
    -- FUNCTION Populate_Code --
    -- This function will generate the category code based on the last number
    -- that was used. The code will be in the format of <cls_code>n where n
    -- is 1 + number that was used last time to generate the code of the same
    -- class.
    -------------------------------
    FUNCTION Populate_Code (
      p_scsv_rec	IN scsv_rec_type
    ) RETURN scsv_rec_type IS
      l_scsv_rec	scsv_rec_type := p_scsv_rec;
      l_seq             Number;
      l_dummy           Varchar2(1);
      l_row_notfound    Boolean;
      --
      CURSOR c1 (p_cls_code IN okc_subclasses_b.cls_code%TYPE) IS
      SELECT nvl(max(replace(code, cls_code)), '0')
        FROM Okc_Subclasses_B
       WHERE cls_code = p_cls_code
         AND Instr(code, p_cls_code) > 0;
      --
      CURSOR c2 (p_code IN okc_subclasses_v.code%TYPE) IS
      SELECT 'x'
        FROM Okc_Subclasses_B
       WHERE code = p_code;
      --
    BEGIN
      If l_scsv_rec.code Is Null OR
	    l_scsv_rec.code = OKC_API.G_MISS_CHAR
	 Then
        Open c1(l_scsv_rec.cls_code);
        Fetch c1 Into l_seq;
        Close c1;
        Loop
          l_scsv_rec.code := l_scsv_rec.cls_code || To_Char(l_seq + 1);
          Open c2(l_scsv_rec.code);
          Fetch c2 Into l_dummy;
          l_row_notfound := c2%NotFound;
          Close c2;
          Exit When l_row_notfound;
          l_seq := l_seq + 1;
        End Loop;
      End If;
      RETURN(l_scsv_rec);
    END Populate_Code;
    -----------------------------------------------
    -- Validate_Unique_Keys for:OKC_SUBCLASSES_V --
    -----------------------------------------------
    FUNCTION validate_unique_keys (
      p_scsv_rec IN  scsv_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      CURSOR c1 (p_code IN okc_subclasses_v.code%TYPE) IS
      SELECT 'x'
        FROM Okc_Subclasses_B
       WHERE code = p_code;
      CURSOR c2 (p_meaning IN okc_subclasses_v.meaning%TYPE) IS
      SELECT 'x'
        FROM Okc_Subclasses_V
       WHERE meaning = p_meaning;
      l_dummy                VARCHAR2(1);
      l_return_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found            BOOLEAN := FALSE;
    BEGIN
      IF (p_scsv_rec.CODE IS NOT NULL) THEN
        OPEN c1(p_scsv_rec.CODE);
        FETCH c1 INTO l_dummy;
        l_row_found := c1%FOUND;
        CLOSE c1;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CODE');
          RAISE unique_key_error;
        END IF;
      END IF;
      IF (p_scsv_rec.MEANING IS NOT NULL) THEN
        OPEN c2(p_scsv_rec.MEANING);
        FETCH c2 INTO l_dummy;
        l_row_found := c2%FOUND;
        CLOSE c2;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'MEANING');
          RAISE unique_key_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN unique_key_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_unique_keys;
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
    l_scsv_rec := null_out_defaults(p_scsv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_scsv_rec,                        -- IN
      l_def_scsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_scsv_rec := fill_who_columns(l_def_scsv_rec);
    -- For normal users, the category code will be passed as null.
    -- Generate it first before validating it.
    l_def_scsv_rec := Populate_Code(l_def_scsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_scsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_scsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Unique_Keys(l_def_scsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_scsv_rec, l_scs_rec);
    migrate(l_def_scsv_rec, l_okc_subclasses_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scs_rec,
      lx_scs_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scs_rec, l_def_scsv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_subclasses_tl_rec,
      lx_okc_subclasses_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_subclasses_tl_rec, l_def_scsv_rec);
    -- Set OUT values
    x_scsv_rec := l_def_scsv_rec;
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
  -- PL/SQL TBL insert_row for:SCSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scsv_tbl.COUNT > 0) THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scsv_rec                     => p_scsv_tbl(i),
          x_scsv_rec                     => x_scsv_tbl(i));
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
  -----------------------------------
  -- lock_row for:OKC_SUBCLASSES_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scs_rec                      IN scs_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_scs_rec IN scs_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASSES_B
     WHERE CODE = p_scs_rec.code
       AND OBJECT_VERSION_NUMBER = p_scs_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_scs_rec IN scs_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASSES_B
    WHERE CODE = p_scs_rec.code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SUBCLASSES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SUBCLASSES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_scs_rec);
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
      OPEN lchk_csr(p_scs_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_scs_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_scs_rec.object_version_number THEN
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
  -- lock_row for:OKC_SUBCLASSES_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_subclasses_tl_rec IN okc_subclasses_tl_rec_type) IS
    SELECT *
      FROM OKC_SUBCLASSES_TL
     WHERE CODE = p_okc_subclasses_tl_rec.code
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
      OPEN lock_csr(p_okc_subclasses_tl_rec);
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
  -- lock_row for:OKC_SUBCLASSES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scs_rec                      scs_rec_type;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
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
    migrate(p_scsv_rec, l_scs_rec);
    migrate(p_scsv_rec, l_okc_subclasses_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scs_rec
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
      l_okc_subclasses_tl_rec
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
  -- PL/SQL TBL lock_row for:SCSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN scsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scsv_tbl.COUNT > 0) THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scsv_rec                     => p_scsv_tbl(i));
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
  -------------------------------------
  -- update_row for:OKC_SUBCLASSES_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scs_rec                      IN scs_rec_type,
    x_scs_rec                      OUT NOCOPY scs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scs_rec                      scs_rec_type := p_scs_rec;
    l_def_scs_rec                  scs_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scs_rec	IN scs_rec_type,
      x_scs_rec	OUT NOCOPY scs_rec_type
    ) RETURN VARCHAR2 IS
      l_scs_rec                      scs_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scs_rec := p_scs_rec;
      -- Get current database values
      l_scs_rec := get_rec(p_scs_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scs_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_scs_rec.code := l_scs_rec.code;
      END IF;
      IF (x_scs_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_scs_rec.cls_code := l_scs_rec.cls_code;
      END IF;
      IF (x_scs_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_scs_rec.start_date := l_scs_rec.start_date;
      END IF;
      IF (x_scs_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_scs_rec.end_date := l_scs_rec.end_date;
      END IF;
      IF (x_scs_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scs_rec.object_version_number := l_scs_rec.object_version_number;
      END IF;
      IF (x_scs_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scs_rec.created_by := l_scs_rec.created_by;
      END IF;
      IF (x_scs_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scs_rec.creation_date := l_scs_rec.creation_date;
      END IF;
      IF (x_scs_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scs_rec.last_updated_by := l_scs_rec.last_updated_by;
      END IF;
      IF (x_scs_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scs_rec.last_update_date := l_scs_rec.last_update_date;
      END IF;
      IF (x_scs_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_scs_rec.last_update_login := l_scs_rec.last_update_login;
      END IF;

      IF (x_scs_rec.create_opp_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_scs_rec.create_opp_yn := l_scs_rec.create_opp_yn;
      END IF;
      IF (x_scs_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_scs_rec.access_level := l_scs_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_scs_rec IN  scs_rec_type,
      x_scs_rec OUT NOCOPY scs_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scs_rec := p_scs_rec;
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
      p_scs_rec,                         -- IN
      l_scs_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scs_rec, l_def_scs_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SUBCLASSES_B
    SET CLS_CODE = l_def_scs_rec.cls_code,
        START_DATE = l_def_scs_rec.start_date,
        END_DATE = l_def_scs_rec.end_date,
        OBJECT_VERSION_NUMBER = l_def_scs_rec.object_version_number,
        CREATED_BY = l_def_scs_rec.created_by,
        CREATION_DATE = l_def_scs_rec.creation_date,
        LAST_UPDATED_BY = l_def_scs_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_scs_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_scs_rec.last_update_login,
        CREATE_OPP_YN     = l_def_scs_rec.create_opp_yn,
        ACCESS_LEVEL     = l_def_scs_rec.access_level
    WHERE CODE = l_def_scs_rec.code;

    x_scs_rec := l_def_scs_rec;
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
  -- update_row for:OKC_SUBCLASSES_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type,
    x_okc_subclasses_tl_rec        OUT NOCOPY okc_subclasses_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type := p_okc_subclasses_tl_rec;
    l_def_okc_subclasses_tl_rec    okc_subclasses_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_subclasses_tl_rec	IN okc_subclasses_tl_rec_type,
      x_okc_subclasses_tl_rec	OUT NOCOPY okc_subclasses_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_subclasses_tl_rec := p_okc_subclasses_tl_rec;
      -- Get current database values
      l_okc_subclasses_tl_rec := get_rec(p_okc_subclasses_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_subclasses_tl_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.code := l_okc_subclasses_tl_rec.code;
      END IF;
      IF (x_okc_subclasses_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.language := l_okc_subclasses_tl_rec.language;
      END IF;
      IF (x_okc_subclasses_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.source_lang := l_okc_subclasses_tl_rec.source_lang;
      END IF;
      IF (x_okc_subclasses_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.sfwt_flag := l_okc_subclasses_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_subclasses_tl_rec.meaning = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.meaning := l_okc_subclasses_tl_rec.meaning;
      END IF;
      IF (x_okc_subclasses_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_subclasses_tl_rec.description := l_okc_subclasses_tl_rec.description;
      END IF;
      IF (x_okc_subclasses_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_subclasses_tl_rec.created_by := l_okc_subclasses_tl_rec.created_by;
      END IF;
      IF (x_okc_subclasses_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_subclasses_tl_rec.creation_date := l_okc_subclasses_tl_rec.creation_date;
      END IF;
      IF (x_okc_subclasses_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_subclasses_tl_rec.last_updated_by := l_okc_subclasses_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_subclasses_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_subclasses_tl_rec.last_update_date := l_okc_subclasses_tl_rec.last_update_date;
      END IF;
      IF (x_okc_subclasses_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_subclasses_tl_rec.last_update_login := l_okc_subclasses_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_subclasses_tl_rec IN  okc_subclasses_tl_rec_type,
      x_okc_subclasses_tl_rec OUT NOCOPY okc_subclasses_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_subclasses_tl_rec := p_okc_subclasses_tl_rec;
      x_okc_subclasses_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_subclasses_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_subclasses_tl_rec,           -- IN
      l_okc_subclasses_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_subclasses_tl_rec, l_def_okc_subclasses_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SUBCLASSES_TL
    SET MEANING = l_def_okc_subclasses_tl_rec.meaning,
        DESCRIPTION = l_def_okc_subclasses_tl_rec.description,
        CREATED_BY = l_def_okc_subclasses_tl_rec.created_by,
        CREATION_DATE = l_def_okc_subclasses_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_subclasses_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_subclasses_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_subclasses_tl_rec.last_update_login
    WHERE CODE = l_def_okc_subclasses_tl_rec.code
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_SUBCLASSES_TL
    SET SFWT_FLAG = 'Y'
    WHERE CODE = l_def_okc_subclasses_tl_rec.code
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_subclasses_tl_rec := l_def_okc_subclasses_tl_rec;
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
  -- update_row for:OKC_SUBCLASSES_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type,
    x_scsv_rec                     OUT NOCOPY scsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
    l_def_scsv_rec                 scsv_rec_type;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
    lx_okc_subclasses_tl_rec       okc_subclasses_tl_rec_type;
    l_scs_rec                      scs_rec_type;
    lx_scs_rec                     scs_rec_type;
--kjhamb
    l_tl_scsv_rec                  scsv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scsv_rec	IN scsv_rec_type
    ) RETURN scsv_rec_type IS
      l_scsv_rec	scsv_rec_type := p_scsv_rec;
    BEGIN
      l_scsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_scsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_scsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_scsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scsv_rec	IN scsv_rec_type,
      x_scsv_rec	OUT NOCOPY scsv_rec_type
    ) RETURN VARCHAR2 IS
      l_scsv_rec                     scsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scsv_rec := p_scsv_rec;
      -- Get current database values
      l_scsv_rec := get_rec(p_scsv_rec, l_row_notfound);
      l_tl_scsv_rec := l_scsv_rec;
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scsv_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.code := l_scsv_rec.code;
      END IF;
      IF (x_scsv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scsv_rec.object_version_number := l_scsv_rec.object_version_number;
      END IF;
      IF (x_scsv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.sfwt_flag := l_scsv_rec.sfwt_flag;
      END IF;
      IF (x_scsv_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.cls_code := l_scsv_rec.cls_code;
      END IF;
      IF (x_scsv_rec.meaning = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.meaning := l_scsv_rec.meaning;
      END IF;
      IF (x_scsv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.description := l_scsv_rec.description;
      END IF;
      IF (x_scsv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_scsv_rec.start_date := l_scsv_rec.start_date;
      END IF;
      IF (x_scsv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_scsv_rec.end_date := l_scsv_rec.end_date;
      END IF;
      IF (x_scsv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scsv_rec.created_by := l_scsv_rec.created_by;
      END IF;
      IF (x_scsv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scsv_rec.creation_date := l_scsv_rec.creation_date;
      END IF;
      IF (x_scsv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scsv_rec.last_updated_by := l_scsv_rec.last_updated_by;
      END IF;
      IF (x_scsv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scsv_rec.last_update_date := l_scsv_rec.last_update_date;
      END IF;
      IF (x_scsv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_scsv_rec.last_update_login := l_scsv_rec.last_update_login;
      END IF;

      IF (x_scsv_rec.create_opp_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.create_opp_yn := l_scsv_rec.create_opp_yn;
      END IF;
      IF (x_scsv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_scsv_rec.access_level := l_scsv_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_scsv_rec IN  scsv_rec_type,
      x_scsv_rec OUT NOCOPY scsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scsv_rec := p_scsv_rec;
      x_scsv_rec.OBJECT_VERSION_NUMBER := NVL(x_scsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_scsv_rec,                        -- IN
      l_scsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scsv_rec, l_def_scsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_scsv_rec := fill_who_columns(l_def_scsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_scsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_scsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_scsv_rec, l_okc_subclasses_tl_rec);
    migrate(l_def_scsv_rec, l_scs_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
   IF ((l_tl_scsv_rec.Meaning <> l_okc_subclasses_tl_rec.Meaning) OR
      (l_tl_scsv_rec.Description <> l_okc_subclasses_tl_rec.Description)) THEN
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_subclasses_tl_rec,
      lx_okc_subclasses_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_subclasses_tl_rec, l_def_scsv_rec);
  else
    migrate(l_okc_subclasses_tl_rec, l_def_scsv_rec);
  end if;
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scs_rec,
      lx_scs_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scs_rec, l_def_scsv_rec);
    x_scsv_rec := l_def_scsv_rec;
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
  -- PL/SQL TBL update_row for:SCSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN scsv_tbl_type,
    x_scsv_tbl                     OUT NOCOPY scsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scsv_tbl.COUNT > 0) THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scsv_rec                     => p_scsv_tbl(i),
          x_scsv_rec                     => x_scsv_tbl(i));
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
  -------------------------------------
  -- delete_row for:OKC_SUBCLASSES_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scs_rec                      IN scs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scs_rec                      scs_rec_type:= p_scs_rec;
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
    DELETE FROM OKC_SUBCLASSES_B
     WHERE CODE = l_scs_rec.code;

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
  -- delete_row for:OKC_SUBCLASSES_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_subclasses_tl_rec        IN okc_subclasses_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type:= p_okc_subclasses_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASSES_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_subclasses_tl_rec IN  okc_subclasses_tl_rec_type,
      x_okc_subclasses_tl_rec OUT NOCOPY okc_subclasses_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_subclasses_tl_rec := p_okc_subclasses_tl_rec;
      x_okc_subclasses_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_subclasses_tl_rec,           -- IN
      l_okc_subclasses_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_SUBCLASSES_TL
     WHERE CODE = l_okc_subclasses_tl_rec.code;

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
  -- delete_row for:OKC_SUBCLASSES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_rec                     IN scsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scsv_rec                     scsv_rec_type := p_scsv_rec;
    l_okc_subclasses_tl_rec        okc_subclasses_tl_rec_type;
    l_scs_rec                      scs_rec_type;
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
    migrate(l_scsv_rec, l_okc_subclasses_tl_rec);
    migrate(l_scsv_rec, l_scs_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_subclasses_tl_rec
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
      l_scs_rec
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
  -- PL/SQL TBL delete_row for:SCSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scsv_tbl                     IN scsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scsv_tbl.COUNT > 0) THEN
      i := p_scsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scsv_rec                     => p_scsv_tbl(i));
        EXIT WHEN (i = p_scsv_tbl.LAST);
        i := p_scsv_tbl.NEXT(i);
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
END OKC_SCS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKC_RLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RLD_PVT" as
/* $Header: OKCSRLDB.pls 120.0 2005/05/27 05:18:21 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

FUNCTION Validate_dff(p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type) RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
    DELETE FROM OKC_RULE_DEFS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_RULE_DEFS_TL B
         WHERE B.RULE_CODE =T.RULE_CODE
        );

    UPDATE OKC_RULE_DEFS_TL T SET(
        MEANING,
        DESCRIPTION) = (SELECT
                                  B.MEANING,
                                  B.DESCRIPTION
                                FROM OKC_RULE_DEFS_TL B
                               WHERE B.RULE_CODE = T.RULE_CODE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.RULE_CODE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.RULE_CODE,
                  SUBT.LANGUAGE
                FROM OKC_RULE_DEFS_TL SUBB, OKC_RULE_DEFS_TL SUBT
               WHERE SUBB.RULE_CODE = SUBT.RULE_CODE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.MEANING <> SUBT.MEANING
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.MEANING IS NOT NULL AND SUBT.MEANING IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKC_RULE_DEFS_TL (
        RULE_CODE,
        MEANING,
        DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.RULE_CODE,
            B.MEANING,
            B.DESCRIPTION,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_RULE_DEFS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKC_RULE_DEFS_TL T
                     WHERE T.RULE_CODE = B.RULE_CODE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_DEFS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_rule_defs_v_rec_type IS
    CURSOR okc_rule_defs_pk_csr (p_rule_code IN VARCHAR2) IS
    SELECT
            APPLICATION_ID,
            APPLICATION_NAME,
            RULE_CODE,
            DESCRIPTIVE_FLEXFIELD_NAME,
            MEANING,
            DESCRIPTION,
            SFWT_FLAG,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Defs_V
     WHERE okc_rule_defs_v.rule_code = p_rule_code;
    l_okc_rule_defs_pk             okc_rule_defs_pk_csr%ROWTYPE;
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rule_defs_pk_csr (p_okc_rule_defs_v_rec.rule_code);
    FETCH okc_rule_defs_pk_csr INTO
              l_okc_rule_defs_v_rec.application_id,
              l_okc_rule_defs_v_rec.application_name,
              l_okc_rule_defs_v_rec.rule_code,
              l_okc_rule_defs_v_rec.descriptive_flexfield_name,
              l_okc_rule_defs_v_rec.meaning,
              l_okc_rule_defs_v_rec.description,
              l_okc_rule_defs_v_rec.sfwt_flag,
              l_okc_rule_defs_v_rec.object_version_number,
              l_okc_rule_defs_v_rec.created_by,
              l_okc_rule_defs_v_rec.creation_date,
              l_okc_rule_defs_v_rec.last_updated_by,
              l_okc_rule_defs_v_rec.last_update_date,
              l_okc_rule_defs_v_rec.last_update_login;
    x_no_data_found := okc_rule_defs_pk_csr%NOTFOUND;
    CLOSE okc_rule_defs_pk_csr;
    RETURN(l_okc_rule_defs_v_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_rule_defs_v_rec_type IS
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_v_rec := get_rec(p_okc_rule_defs_v_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'RULE_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_rule_defs_v_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type
  ) RETURN okc_rule_defs_v_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_rule_defs_v_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_DEFS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_rule_defs_b_rec_type IS
    CURSOR okc_rule_defs_b_pk_csr (p_rule_code IN VARCHAR2) IS
    SELECT
            RULE_CODE,
            APPLICATION_ID,
            DESCRIPTIVE_FLEXFIELD_NAME,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Defs_B
     WHERE okc_rule_defs_b.rule_code = p_rule_code;
    l_okc_rule_defs_b_pk           okc_rule_defs_b_pk_csr%ROWTYPE;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rule_defs_b_pk_csr (p_okc_rule_defs_b_rec.rule_code);
    FETCH okc_rule_defs_b_pk_csr INTO
              l_okc_rule_defs_b_rec.rule_code,
              l_okc_rule_defs_b_rec.application_id,
              l_okc_rule_defs_b_rec.descriptive_flexfield_name,
              l_okc_rule_defs_b_rec.object_version_number,
              l_okc_rule_defs_b_rec.created_by,
              l_okc_rule_defs_b_rec.creation_date,
              l_okc_rule_defs_b_rec.last_updated_by,
              l_okc_rule_defs_b_rec.last_update_date,
              l_okc_rule_defs_b_rec.last_update_login;
    x_no_data_found := okc_rule_defs_b_pk_csr%NOTFOUND;
    CLOSE okc_rule_defs_b_pk_csr;
    RETURN(l_okc_rule_defs_b_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_rule_defs_b_rec_type IS
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_b_rec := get_rec(p_okc_rule_defs_b_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'RULE_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_rule_defs_b_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type
  ) RETURN okc_rule_defs_b_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_rule_defs_b_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_DEFS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_rule_defs_tl_rec_type IS
    CURSOR okc_rule_defs_tl_pk_csr (p_rule_code IN VARCHAR2,
                                    p_language  IN VARCHAR2) IS
    SELECT
            RULE_CODE,
            MEANING,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Rule_Defs_Tl
     WHERE okc_rule_defs_tl.rule_code = p_rule_code
       AND okc_rule_defs_tl.language = p_language;
    l_okc_rule_defs_tl_pk          okc_rule_defs_tl_pk_csr%ROWTYPE;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rule_defs_tl_pk_csr (p_okc_rule_defs_tl_rec.rule_code,
                                  p_okc_rule_defs_tl_rec.language);
    FETCH okc_rule_defs_tl_pk_csr INTO
              l_okc_rule_defs_tl_rec.rule_code,
              l_okc_rule_defs_tl_rec.meaning,
              l_okc_rule_defs_tl_rec.description,
              l_okc_rule_defs_tl_rec.language,
              l_okc_rule_defs_tl_rec.source_lang,
              l_okc_rule_defs_tl_rec.sfwt_flag,
              l_okc_rule_defs_tl_rec.created_by,
              l_okc_rule_defs_tl_rec.creation_date,
              l_okc_rule_defs_tl_rec.last_updated_by,
              l_okc_rule_defs_tl_rec.last_update_date,
              l_okc_rule_defs_tl_rec.last_update_login;
    x_no_data_found := okc_rule_defs_tl_pk_csr%NOTFOUND;
    CLOSE okc_rule_defs_tl_pk_csr;
    RETURN(l_okc_rule_defs_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_rule_defs_tl_rec_type IS
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_tl_rec := get_rec(p_okc_rule_defs_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'RULE_CODE');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_rule_defs_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type
  ) RETURN okc_rule_defs_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_rule_defs_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_RULE_DEFS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_okc_rule_defs_v_rec   IN okc_rule_defs_v_rec_type
  ) RETURN okc_rule_defs_v_rec_type IS
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
  BEGIN
    IF (l_okc_rule_defs_v_rec.application_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_rule_defs_v_rec.application_id := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.application_name = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.application_name := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.rule_code = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.rule_code := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.descriptive_flexfield_name = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.descriptive_flexfield_name := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.meaning = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.meaning := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.description := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_okc_rule_defs_v_rec.sfwt_flag := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_okc_rule_defs_v_rec.object_version_number := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_okc_rule_defs_v_rec.created_by := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_rule_defs_v_rec.creation_date := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_okc_rule_defs_v_rec.last_updated_by := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_rule_defs_v_rec.last_update_date := NULL;
    END IF;
    IF (l_okc_rule_defs_v_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_okc_rule_defs_v_rec.last_update_login := NULL;
    END IF;
    RETURN(l_okc_rule_defs_v_rec);
  END null_out_defaults;
  ---------------------------------------------
  -- Validate_Attributes for: APPLICATION_ID --
  ---------------------------------------------
  PROCEDURE validate_application_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_application_id               IN NUMBER) IS
    l_applid_var   VARCHAR2(1) := '?';
    Cursor l_applid_csr Is
  	  select '!'
	  from FND_APPLICATION
  	  where application_id = p_application_id;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    Open l_applid_csr;
    Fetch l_applid_csr Into l_applid_var;
    Close l_applid_csr;
    IF (p_application_id = OKC_API.G_MISS_NUM OR
        p_application_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'application_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (l_applid_var = '?') THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'APPLICATION_ID');
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
  END validate_application_id;
  -----------------------------------------------
  -- Validate_Attributes for: APPLICATION_NAME --
  -----------------------------------------------
  PROCEDURE validate_application_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_application_name             IN VARCHAR2) IS
/*
    l_applnm_var   VARCHAR2(1) := '?';
    Cursor l_applnm_csr Is
  	  select '!'
	  from FND_APPLICATION
  	  where application_short_name = p_application_name;
*/
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
/*
    Open l_applnm_csr;
    Fetch l_applnm_csr Into l_applnm_var;
    Close l_applnm_csr;
*/
    IF (p_application_name = OKC_API.G_MISS_CHAR OR
        p_application_name IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'application_name');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
/*
    ELSIF (l_applnm_var = '?') THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'APPLICATION_NAME');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
*/
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
  END validate_application_name;
  ----------------------------------------
  -- Validate_Attributes for: RULE_CODE --
  ----------------------------------------
  PROCEDURE validate_rule_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_rule_code                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_rule_code = OKC_API.G_MISS_CHAR OR
        p_rule_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'rule_code');
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
  END validate_rule_code;
  ---------------------------------------------------------
  -- Validate_Attributes for: DESCRIPTIVE_FLEXFIELD_NAME --
  ---------------------------------------------------------
  PROCEDURE validate_dff_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_descriptive_flexfield_name   IN VARCHAR2) IS
    l_dff_var   VARCHAR2(1) := '?';
    Cursor l_dff_csr Is
  	  select distinct '!'
	  from FND_DESCR_FLEX_CONTEXTS_VL
  	  where descriptive_flexfield_name = p_descriptive_flexfield_name;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    Open l_dff_csr;
    Fetch l_dff_csr Into l_dff_var;
    Close l_dff_csr;
    IF (p_descriptive_flexfield_name = OKC_API.G_MISS_CHAR OR
        p_descriptive_flexfield_name IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'descriptive_flexfield_name');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (l_dff_var = '?')   THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'DESCRIPTIVE_FLEXFIELD_NAME');
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
  END validate_dff_name;
  --------------------------------------
  -- Validate_Attributes for: MEANING --
  --------------------------------------
  PROCEDURE validate_meaning(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_meaning                      IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_meaning = OKC_API.G_MISS_CHAR OR
        p_meaning IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'meaning');
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
  END validate_meaning;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
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
  END validate_sfwt_flag;
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
  ----------------------------------------------------------------------------------
  -- Validate_Attributes for: APPLICATION_ID,RULE_CODE,DESCRIPTIVE_FLEXFIELD_NAME --
  ----------------------------------------------------------------------------------
  PROCEDURE validate_appl_rule_dff(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_application_id               IN NUMBER,
    p_rule_code                    IN VARCHAR2,
    p_descriptive_flexfield_name   IN VARCHAR2) IS
    l_var   VARCHAR2(1) := '?';
    Cursor l_csr Is
  	  select distinct '!'
	  from FND_DESCR_FLEX_CONTEXTS_VL
  	  where
  	   APPLICATION_ID = p_application_id
  	  and
  	   DESCRIPTIVE_FLEX_CONTEXT_CODE = p_rule_code
  	  and
  	   DESCRIPTIVE_FLEXFIELD_NAME = p_descriptive_flexfield_name;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    Open l_csr;
    Fetch l_csr Into l_var;
    Close l_csr;
    IF (l_var = '?')   THEN
      OKC_API.set_message( G_APP_NAME,
                           G_INVALID_VALUE,
                           G_COL_NAME_TOKEN,
                           'APPLICATION_ID,RULE_CODE,DESCRIPTIVE_FLEXFIELD_NAME');
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
  END validate_appl_rule_dff;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKC_RULE_DEFS_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- application_id
    -- ***
    validate_application_id(x_return_status, p_okc_rule_defs_v_rec.application_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- application_name
    -- ***
    validate_application_name(x_return_status, p_okc_rule_defs_v_rec.application_name);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- rule_code
    -- ***
    validate_rule_code(x_return_status, p_okc_rule_defs_v_rec.rule_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- descriptive_flexfield_name
    -- ***
    validate_dff_name(x_return_status, p_okc_rule_defs_v_rec.descriptive_flexfield_name);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- application_id, rule_code, descriptive_flexfield_name
    -- ***
    validate_appl_rule_dff(x_return_status,
                           p_okc_rule_defs_v_rec.application_id,
                           p_okc_rule_defs_v_rec.rule_code,
                           p_okc_rule_defs_v_rec.descriptive_flexfield_name);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- meaning
    -- ***
    validate_meaning(x_return_status, p_okc_rule_defs_v_rec.meaning);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_okc_rule_defs_v_rec.sfwt_flag);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_okc_rule_defs_v_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
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
  -----------------------------------------
  -- Validate Record for:OKC_RULE_DEFS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type,
    p_db_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type
  ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_okc_rule_defs_v_rec       okc_rule_defs_v_rec_type := get_rec(p_okc_rule_defs_v_rec);
  BEGIN
    l_return_status := Validate_Record(p_okc_rule_defs_v_rec => p_okc_rule_defs_v_rec,
                                       p_db_okc_rule_defs_v_rec => l_db_okc_rule_defs_v_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN okc_rule_defs_v_rec_type,
    p_to   IN OUT NOCOPY okc_rule_defs_b_rec_type
  ) IS
  BEGIN
    p_to.rule_code := p_from.rule_code;
    p_to.application_id := p_from.application_id;
    p_to.descriptive_flexfield_name := p_from.descriptive_flexfield_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okc_rule_defs_b_rec_type,
    p_to   IN OUT NOCOPY okc_rule_defs_v_rec_type
  ) IS
  BEGIN
    p_to.application_id := p_from.application_id;
    p_to.rule_code := p_from.rule_code;
    p_to.descriptive_flexfield_name := p_from.descriptive_flexfield_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okc_rule_defs_v_rec_type,
    p_to   IN OUT NOCOPY okc_rule_defs_tl_rec_type
  ) IS
  BEGIN
    p_to.rule_code := p_from.rule_code;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okc_rule_defs_tl_rec_type,
    p_to   IN OUT NOCOPY okc_rule_defs_v_rec_type
  ) IS
  BEGIN
    p_to.rule_code := p_from.rule_code;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKC_RULE_DEFS_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_okc_rule_defs_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_okc_rule_defs_v_rec);
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
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKC_RULE_DEFS_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      i := p_okc_rule_defs_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_rule_defs_v_tbl.LAST);
        i := p_okc_rule_defs_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKC_RULE_DEFS_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_rule_defs_v_tbl          => p_okc_rule_defs_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ------------------------------------
  -- insert_row for:OKC_RULE_DEFS_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type,
    x_okc_rule_defs_b_rec          OUT NOCOPY okc_rule_defs_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type := p_okc_rule_defs_b_rec;
    l_def_okc_rule_defs_b_rec      okc_rule_defs_b_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_b_rec IN okc_rule_defs_b_rec_type,
      x_okc_rule_defs_b_rec OUT NOCOPY okc_rule_defs_b_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_b_rec := p_okc_rule_defs_b_rec;
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
      p_okc_rule_defs_b_rec,             -- IN
      l_okc_rule_defs_b_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_RULE_DEFS_B(
      rule_code,
      application_id,
      descriptive_flexfield_name,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_okc_rule_defs_b_rec.rule_code,
      l_okc_rule_defs_b_rec.application_id,
      l_okc_rule_defs_b_rec.descriptive_flexfield_name,
      l_okc_rule_defs_b_rec.object_version_number,
      l_okc_rule_defs_b_rec.created_by,
      l_okc_rule_defs_b_rec.creation_date,
      l_okc_rule_defs_b_rec.last_updated_by,
      l_okc_rule_defs_b_rec.last_update_date,
      l_okc_rule_defs_b_rec.last_update_login);
    -- Set OUT values
    x_okc_rule_defs_b_rec := l_okc_rule_defs_b_rec;
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
  -------------------------------------
  -- insert_row for:OKC_RULE_DEFS_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type,
    x_okc_rule_defs_tl_rec         OUT NOCOPY okc_rule_defs_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type := p_okc_rule_defs_tl_rec;
    l_def_okc_rule_defs_tl_rec     okc_rule_defs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_tl_rec IN okc_rule_defs_tl_rec_type,
      x_okc_rule_defs_tl_rec OUT NOCOPY okc_rule_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_tl_rec := p_okc_rule_defs_tl_rec;
      x_okc_rule_defs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_rule_defs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_rule_defs_tl_rec,            -- IN
      l_okc_rule_defs_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_rule_defs_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_RULE_DEFS_TL(
        rule_code,
        meaning,
        description,
        language,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okc_rule_defs_tl_rec.rule_code,
        l_okc_rule_defs_tl_rec.meaning,
        l_okc_rule_defs_tl_rec.description,
        l_okc_rule_defs_tl_rec.language,
        l_okc_rule_defs_tl_rec.source_lang,
        l_okc_rule_defs_tl_rec.sfwt_flag,
        l_okc_rule_defs_tl_rec.created_by,
        l_okc_rule_defs_tl_rec.creation_date,
        l_okc_rule_defs_tl_rec.last_updated_by,
        l_okc_rule_defs_tl_rec.last_update_date,
        l_okc_rule_defs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_rule_defs_tl_rec := l_okc_rule_defs_tl_rec;
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
  -------------------------------------
  -- insert_row for :OKC_RULE_DEFS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_okc_rule_defs_v_rec          OUT NOCOPY okc_rule_defs_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    l_def_okc_rule_defs_v_rec      okc_rule_defs_v_rec_type;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
    lx_okc_rule_defs_b_rec         okc_rule_defs_b_rec_type;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
    lx_okc_rule_defs_tl_rec        okc_rule_defs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type
    ) RETURN okc_rule_defs_v_rec_type IS
      l_okc_rule_defs_v_rec okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    BEGIN
      l_okc_rule_defs_v_rec.CREATION_DATE := SYSDATE;
      l_okc_rule_defs_v_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_okc_rule_defs_v_rec.LAST_UPDATE_DATE := l_okc_rule_defs_v_rec.CREATION_DATE;
      l_okc_rule_defs_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okc_rule_defs_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okc_rule_defs_v_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type,
      x_okc_rule_defs_v_rec OUT NOCOPY okc_rule_defs_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_v_rec := p_okc_rule_defs_v_rec;
      x_okc_rule_defs_v_rec.OBJECT_VERSION_NUMBER := 1;
      x_okc_rule_defs_v_rec.SFWT_FLAG := 'N';
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
    l_okc_rule_defs_v_rec := null_out_defaults(p_okc_rule_defs_v_rec);
    -- Set primary key value
    -- Error: Primary Key Column "RULE_CODE"
    --        Does not have a NUMBER datatype, cannot assign get_seq_id
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_okc_rule_defs_v_rec,             -- IN
      l_def_okc_rule_defs_v_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okc_rule_defs_v_rec := fill_who_columns(l_def_okc_rule_defs_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okc_rule_defs_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okc_rule_defs_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okc_rule_defs_v_rec, l_okc_rule_defs_b_rec);
    migrate(l_def_okc_rule_defs_v_rec, l_okc_rule_defs_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_b_rec,
      lx_okc_rule_defs_b_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_defs_b_rec, l_def_okc_rule_defs_v_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_tl_rec,
      lx_okc_rule_defs_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_defs_tl_rec, l_def_okc_rule_defs_v_rec);
    -- Set OUT values
    x_okc_rule_defs_v_rec := l_def_okc_rule_defs_v_rec;
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
  ---------------------------------------------------
  -- PL/SQL TBL insert_row for:OKC_RULE_DEFS_V_TBL --
  ---------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      i := p_okc_rule_defs_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_tbl(i),
            x_okc_rule_defs_v_rec          => x_okc_rule_defs_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_rule_defs_v_tbl.LAST);
        i := p_okc_rule_defs_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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

  ---------------------------------------------------
  -- PL/SQL TBL insert_row for:OKC_RULE_DEFS_V_TBL --
  ---------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_rule_defs_v_tbl          => p_okc_rule_defs_v_tbl,
        x_okc_rule_defs_v_tbl          => x_okc_rule_defs_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ----------------------------------
  -- lock_row for:OKC_RULE_DEFS_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_rule_defs_b_rec IN okc_rule_defs_b_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_DEFS_B
     WHERE RULE_CODE = p_okc_rule_defs_b_rec.rule_code
       AND OBJECT_VERSION_NUMBER = p_okc_rule_defs_b_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_okc_rule_defs_b_rec IN okc_rule_defs_b_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_RULE_DEFS_B
     WHERE RULE_CODE = p_okc_rule_defs_b_rec.rule_code;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKC_RULE_DEFS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKC_RULE_DEFS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_okc_rule_defs_b_rec);
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
      OPEN lchk_csr(p_okc_rule_defs_b_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_okc_rule_defs_b_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_okc_rule_defs_b_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:OKC_RULE_DEFS_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_rule_defs_tl_rec IN okc_rule_defs_tl_rec_type) IS
    SELECT *
      FROM OKC_RULE_DEFS_TL
     WHERE RULE_CODE = p_okc_rule_defs_tl_rec.rule_code
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okc_rule_defs_tl_rec);
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
  -----------------------------------
  -- lock_row for: OKC_RULE_DEFS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
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
    migrate(p_okc_rule_defs_v_rec, l_okc_rule_defs_b_rec);
    migrate(p_okc_rule_defs_v_rec, l_okc_rule_defs_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_b_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_tl_rec
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
  -------------------------------------------------
  -- PL/SQL TBL lock_row for:OKC_RULE_DEFS_V_TBL --
  -------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      i := p_okc_rule_defs_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_rule_defs_v_tbl.LAST);
        i := p_okc_rule_defs_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
  -------------------------------------------------
  -- PL/SQL TBL lock_row for:OKC_RULE_DEFS_V_TBL --
  -------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_rule_defs_v_tbl          => p_okc_rule_defs_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ------------------------------------
  -- update_row for:OKC_RULE_DEFS_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type,
    x_okc_rule_defs_b_rec          OUT NOCOPY okc_rule_defs_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type := p_okc_rule_defs_b_rec;
    l_def_okc_rule_defs_b_rec      okc_rule_defs_b_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_rule_defs_b_rec IN okc_rule_defs_b_rec_type,
      x_okc_rule_defs_b_rec OUT NOCOPY okc_rule_defs_b_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_b_rec := p_okc_rule_defs_b_rec;
      -- Get current database values
      l_okc_rule_defs_b_rec := get_rec(p_okc_rule_defs_b_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_rule_defs_b_rec.rule_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_b_rec.rule_code := l_okc_rule_defs_b_rec.rule_code;
        END IF;
        IF (x_okc_rule_defs_b_rec.application_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_b_rec.application_id := l_okc_rule_defs_b_rec.application_id;
        END IF;
        IF (x_okc_rule_defs_b_rec.descriptive_flexfield_name = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_b_rec.descriptive_flexfield_name := l_okc_rule_defs_b_rec.descriptive_flexfield_name;
        END IF;
        IF (x_okc_rule_defs_b_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_b_rec.object_version_number := l_okc_rule_defs_b_rec.object_version_number;
        END IF;
        IF (x_okc_rule_defs_b_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_b_rec.created_by := l_okc_rule_defs_b_rec.created_by;
        END IF;
        IF (x_okc_rule_defs_b_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_b_rec.creation_date := l_okc_rule_defs_b_rec.creation_date;
        END IF;
        IF (x_okc_rule_defs_b_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_b_rec.last_updated_by := l_okc_rule_defs_b_rec.last_updated_by;
        END IF;
        IF (x_okc_rule_defs_b_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_b_rec.last_update_date := l_okc_rule_defs_b_rec.last_update_date;
        END IF;
        IF (x_okc_rule_defs_b_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_b_rec.last_update_login := l_okc_rule_defs_b_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_b_rec IN okc_rule_defs_b_rec_type,
      x_okc_rule_defs_b_rec OUT NOCOPY okc_rule_defs_b_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_b_rec := p_okc_rule_defs_b_rec;
      x_okc_rule_defs_b_rec.OBJECT_VERSION_NUMBER := p_okc_rule_defs_b_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_okc_rule_defs_b_rec,             -- IN
      l_okc_rule_defs_b_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_rule_defs_b_rec, l_def_okc_rule_defs_b_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_RULE_DEFS_B
    SET APPLICATION_ID = l_def_okc_rule_defs_b_rec.application_id,
        DESCRIPTIVE_FLEXFIELD_NAME = l_def_okc_rule_defs_b_rec.descriptive_flexfield_name,
        OBJECT_VERSION_NUMBER = l_def_okc_rule_defs_b_rec.object_version_number,
        CREATED_BY = l_def_okc_rule_defs_b_rec.created_by,
        CREATION_DATE = l_def_okc_rule_defs_b_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_rule_defs_b_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_rule_defs_b_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_rule_defs_b_rec.last_update_login
    WHERE RULE_CODE = l_def_okc_rule_defs_b_rec.rule_code;

    x_okc_rule_defs_b_rec := l_okc_rule_defs_b_rec;
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
  -------------------------------------
  -- update_row for:OKC_RULE_DEFS_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type,
    x_okc_rule_defs_tl_rec         OUT NOCOPY okc_rule_defs_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type := p_okc_rule_defs_tl_rec;
    l_def_okc_rule_defs_tl_rec     okc_rule_defs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_rule_defs_tl_rec IN okc_rule_defs_tl_rec_type,
      x_okc_rule_defs_tl_rec OUT NOCOPY okc_rule_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_tl_rec := p_okc_rule_defs_tl_rec;
      -- Get current database values
      l_okc_rule_defs_tl_rec := get_rec(p_okc_rule_defs_tl_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_rule_defs_tl_rec.rule_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.rule_code := l_okc_rule_defs_tl_rec.rule_code;
        END IF;
        IF (x_okc_rule_defs_tl_rec.meaning = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.meaning := l_okc_rule_defs_tl_rec.meaning;
        END IF;
        IF (x_okc_rule_defs_tl_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.description := l_okc_rule_defs_tl_rec.description;
        END IF;
        IF (x_okc_rule_defs_tl_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.language := l_okc_rule_defs_tl_rec.language;
        END IF;
        IF (x_okc_rule_defs_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.source_lang := l_okc_rule_defs_tl_rec.source_lang;
        END IF;
        IF (x_okc_rule_defs_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_tl_rec.sfwt_flag := l_okc_rule_defs_tl_rec.sfwt_flag;
        END IF;
        IF (x_okc_rule_defs_tl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_tl_rec.created_by := l_okc_rule_defs_tl_rec.created_by;
        END IF;
        IF (x_okc_rule_defs_tl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_tl_rec.creation_date := l_okc_rule_defs_tl_rec.creation_date;
        END IF;
        IF (x_okc_rule_defs_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_tl_rec.last_updated_by := l_okc_rule_defs_tl_rec.last_updated_by;
        END IF;
        IF (x_okc_rule_defs_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_tl_rec.last_update_date := l_okc_rule_defs_tl_rec.last_update_date;
        END IF;
        IF (x_okc_rule_defs_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_tl_rec.last_update_login := l_okc_rule_defs_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_tl_rec IN okc_rule_defs_tl_rec_type,
      x_okc_rule_defs_tl_rec OUT NOCOPY okc_rule_defs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_tl_rec := p_okc_rule_defs_tl_rec;
      x_okc_rule_defs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_rule_defs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_rule_defs_tl_rec,            -- IN
      l_okc_rule_defs_tl_rec);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_rule_defs_tl_rec, l_def_okc_rule_defs_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_RULE_DEFS_TL
    SET MEANING = l_def_okc_rule_defs_tl_rec.meaning,
        DESCRIPTION = l_def_okc_rule_defs_tl_rec.description,
        CREATED_BY = l_def_okc_rule_defs_tl_rec.created_by,
        CREATION_DATE = l_def_okc_rule_defs_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_rule_defs_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_rule_defs_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_rule_defs_tl_rec.last_update_login
    WHERE RULE_CODE = l_def_okc_rule_defs_tl_rec.rule_code
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKC_RULE_DEFS_TL
    SET SFWT_FLAG = 'Y'
    WHERE RULE_CODE = l_def_okc_rule_defs_tl_rec.rule_code
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_rule_defs_tl_rec := l_okc_rule_defs_tl_rec;
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
  ------------------------------------
  -- update_row for:OKC_RULE_DEFS_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_okc_rule_defs_v_rec          OUT NOCOPY okc_rule_defs_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    l_def_okc_rule_defs_v_rec      okc_rule_defs_v_rec_type;
    l_db_okc_rule_defs_v_rec       okc_rule_defs_v_rec_type;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
    lx_okc_rule_defs_b_rec         okc_rule_defs_b_rec_type;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
    lx_okc_rule_defs_tl_rec        okc_rule_defs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type
    ) RETURN okc_rule_defs_v_rec_type IS
      l_okc_rule_defs_v_rec okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    BEGIN
      l_okc_rule_defs_v_rec.LAST_UPDATE_DATE := SYSDATE;
      l_okc_rule_defs_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okc_rule_defs_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okc_rule_defs_v_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type,
      x_okc_rule_defs_v_rec OUT NOCOPY okc_rule_defs_v_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_v_rec := p_okc_rule_defs_v_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_okc_rule_defs_v_rec := get_rec(p_okc_rule_defs_v_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_rule_defs_v_rec.application_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_v_rec.application_id := l_db_okc_rule_defs_v_rec.application_id;
        END IF;
        IF (x_okc_rule_defs_v_rec.application_name = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.application_name := l_db_okc_rule_defs_v_rec.application_name;
        END IF;
        IF (x_okc_rule_defs_v_rec.rule_code = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.rule_code := l_db_okc_rule_defs_v_rec.rule_code;
        END IF;
        IF (x_okc_rule_defs_v_rec.descriptive_flexfield_name = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.descriptive_flexfield_name := l_db_okc_rule_defs_v_rec.descriptive_flexfield_name;
        END IF;
        IF (x_okc_rule_defs_v_rec.meaning = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.meaning := l_db_okc_rule_defs_v_rec.meaning;
        END IF;
        IF (x_okc_rule_defs_v_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.description := l_db_okc_rule_defs_v_rec.description;
        END IF;
        IF (x_okc_rule_defs_v_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_rule_defs_v_rec.sfwt_flag := l_db_okc_rule_defs_v_rec.sfwt_flag;
        END IF;
        IF (x_okc_rule_defs_v_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_v_rec.created_by := l_db_okc_rule_defs_v_rec.created_by;
        END IF;
        IF (x_okc_rule_defs_v_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_v_rec.creation_date := l_db_okc_rule_defs_v_rec.creation_date;
        END IF;
        IF (x_okc_rule_defs_v_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_v_rec.last_updated_by := l_db_okc_rule_defs_v_rec.last_updated_by;
        END IF;
        IF (x_okc_rule_defs_v_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_rule_defs_v_rec.last_update_date := l_db_okc_rule_defs_v_rec.last_update_date;
        END IF;
        IF (x_okc_rule_defs_v_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_rule_defs_v_rec.last_update_login := l_db_okc_rule_defs_v_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_RULE_DEFS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type,
      x_okc_rule_defs_v_rec OUT NOCOPY okc_rule_defs_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_rule_defs_v_rec := p_okc_rule_defs_v_rec;
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
      p_okc_rule_defs_v_rec,             -- IN
      x_okc_rule_defs_v_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_rule_defs_v_rec, l_def_okc_rule_defs_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okc_rule_defs_v_rec := fill_who_columns(l_def_okc_rule_defs_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okc_rule_defs_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okc_rule_defs_v_rec, l_db_okc_rule_defs_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okc_rule_defs_v_rec, l_okc_rule_defs_b_rec);
    migrate(l_def_okc_rule_defs_v_rec, l_okc_rule_defs_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_b_rec,
      lx_okc_rule_defs_b_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_defs_b_rec, l_def_okc_rule_defs_v_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_tl_rec,
      lx_okc_rule_defs_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_rule_defs_tl_rec, l_def_okc_rule_defs_v_rec);
    x_okc_rule_defs_v_rec := l_def_okc_rule_defs_v_rec;
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
  ---------------------------------------------------
  -- PL/SQL TBL update_row for:okc_rule_defs_v_tbl --
  ---------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      i := p_okc_rule_defs_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_tbl(i),
            x_okc_rule_defs_v_rec          => x_okc_rule_defs_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_rule_defs_v_tbl.LAST);
        i := p_okc_rule_defs_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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

  ---------------------------------------------------
  -- PL/SQL TBL update_row for:OKC_RULE_DEFS_V_TBL --
  ---------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_rule_defs_v_tbl          => p_okc_rule_defs_v_tbl,
        x_okc_rule_defs_v_tbl          => x_okc_rule_defs_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
  ------------------------------------
  -- delete_row for:OKC_RULE_DEFS_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_b_rec          IN okc_rule_defs_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type := p_okc_rule_defs_b_rec;
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

    DELETE FROM OKC_RULE_DEFS_B
     WHERE RULE_CODE = p_okc_rule_defs_b_rec.rule_code;

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
  -------------------------------------
  -- delete_row for:OKC_RULE_DEFS_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_tl_rec         IN okc_rule_defs_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type := p_okc_rule_defs_tl_rec;
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

    DELETE FROM OKC_RULE_DEFS_TL
     WHERE RULE_CODE = p_okc_rule_defs_tl_rec.rule_code;

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
  ------------------------------------
  -- delete_row for:OKC_RULE_DEFS_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_rule_defs_v_rec          okc_rule_defs_v_rec_type := p_okc_rule_defs_v_rec;
    l_okc_rule_defs_tl_rec         okc_rule_defs_tl_rec_type;
    l_okc_rule_defs_b_rec          okc_rule_defs_b_rec_type;
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
    migrate(l_okc_rule_defs_v_rec, l_okc_rule_defs_tl_rec);
    migrate(l_okc_rule_defs_v_rec, l_okc_rule_defs_b_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_rule_defs_b_rec
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
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKC_RULE_DEFS_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      i := p_okc_rule_defs_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_rule_defs_v_rec          => p_okc_rule_defs_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_rule_defs_v_tbl.LAST);
        i := p_okc_rule_defs_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKC_RULE_DEFS_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_rule_defs_v_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_rule_defs_v_tbl          => p_okc_rule_defs_v_tbl,
        px_error_tbl                   => l_error_tbl);
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

PROCEDURE set_RULE_DEFS (
    rule_code   IN VARCHAR2
)   IS

CURSOR c1(r_c IN varchar2) IS
SELECT application_id ,descriptive_flexfield_name
FROM   okc_rule_defs_b
where rule_code = r_c;

BEGIN
if rule_code is not NULL then
    p_rule_code:=rule_code;
    open c1(rule_code);
    fetch c1
    into p_appl_id, p_dff_name;
    close c1;
end if;
return;
EXCEPTION
    WHEN NO_DATA_FOUND then
    p_appl_id:=NULL;
    p_dff_name:=NULL;
END set_RULE_DEFS;

function get_appl_id(rule_code  IN VARCHAR2)
return number
is
begin
if rule_code is null then
    return NULL;
elsif rule_code = p_rule_code then
    return p_appl_id;
else
    set_rule_defs(rule_code);
    return p_appl_id;
end if;
end get_appl_id;

function get_dff_name(rule_code  IN VARCHAR2)
return varchar2
is
begin
if rule_code is null then
    return NULL;
elsif rule_code = p_rule_code then
    return p_dff_name;
else
    set_rule_defs(rule_code);
    return p_dff_name;
end if;
end get_dff_name;

FUNCTION Validate_dff (
    p_okc_rule_defs_v_rec IN okc_rule_defs_v_rec_type
) RETURN VARCHAR2 IS

cursor c1(rule_code IN varchar2,
            appl_id IN number,
            dff_name IN varchar2) is
SELECT
    'Y'
FROM
    FND_DESCRIPTIVE_FLEXS B,
    FND_DESCR_FLEX_CONTEXTS A
WHERE
    A.DESCRIPTIVE_FLEX_CONTEXT_CODE = rule_code
and (A.APPLICATION_ID = B.APPLICATION_ID
and B.APPLICATION_ID = appl_id)
and (A.DESCRIPTIVE_FLEXFIELD_NAME = B.DESCRIPTIVE_FLEXFIELD_NAME
and B.DESCRIPTIVE_FLEXFIELD_NAME= dff_name);

    enabled_flag varchar2(3):='N';

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    open c1(
    p_okc_rule_defs_v_rec.rule_code,
    p_okc_rule_defs_v_rec.application_id,
    p_okc_rule_defs_v_rec.descriptive_flexfield_name);
    fetch c1 into enabled_flag;
    close c1;
    if enabled_flag <> 'Y' then  l_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    RETURN (l_return_status);

    EXCEPTION
    when NO_DATA_FOUND then
        l_return_status := OKC_API.G_RET_STS_ERROR;
        close c1;
        return(l_return_status);
    WHEN OTHERS THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        close c1;
        return(l_return_status);
  END Validate_dff;

END OKC_RLD_PVT;

/

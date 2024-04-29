--------------------------------------------------------
--  DDL for Package Body OKC_COR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_COR_PVT" AS
/* $Header: OKCSCORB.pls 120.1 2006/06/06 21:41:58 upillai noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT_VALIDATION  exception;
/*+++++++++++++End of hand code +++++++++++++++++++*/
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

/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/* Refer Bugs 3723612, 4210278 and 5261743

    DELETE FROM OKC_CHANGES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CHANGES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_CHANGES_TL T SET (
        SHORT_DESCRIPTION,
        CHANGE_TEXT) = (SELECT
                                  B.SHORT_DESCRIPTION,
                                  B.CHANGE_TEXT
                                FROM OKC_CHANGES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_CHANGES_TL SUBB, OKC_CHANGES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
-- Commented in favor of handcode
---                      OR SUBB.CHANGE_TEXT <> SUBT.CHANGE_TEXT
--+Hand code start
                      OR ( (SUBB.CHANGE_TEXT IS NOT NULL AND SUBT.CHANGE_TEXT IS NOT NULL)
				   AND (DBMS_LOB.COMPARE(SUBB.CHANGE_TEXT,SUBT.CHANGE_TEXT) <> 0))
--+Hand code end
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.CHANGE_TEXT IS NULL AND SUBT.CHANGE_TEXT IS NOT NULL)
                      OR (SUBB.CHANGE_TEXT IS NOT NULL AND SUBT.CHANGE_TEXT IS NULL)
              ));

*/

/* Modifying Insert as per performance guidelines given in bug 3723874 */
    INSERT /*+ append parallel(tt) */ INTO OKC_CHANGES_TL tt(
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        SHORT_DESCRIPTION,
        CHANGE_TEXT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
	 SELECT /*+ parallel(v) parallel(t) use_nl(t) */ v.* FROM
      (SELECT /*+ no_merge ordered parallel(b) */
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.SHORT_DESCRIPTION,
            B.CHANGE_TEXT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_CHANGES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
	  ) v, OKC_CHANGES_TL T
	  WHERE T.ID(+) = v.ID
	  AND T.LANGUAGE(+) = v.LANGUAGE_CODE
	  AND T.ID IS NULL;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cor_rec                      IN cor_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cor_rec_type IS
    CURSOR cor_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CRT_ID,
            CHANGE_SEQUENCE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DATETIME_INEFFECTIVE,
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
      FROM Okc_Changes_B
     WHERE okc_changes_b.id     = p_id;
    l_cor_pk                       cor_pk_csr%ROWTYPE;
    l_cor_rec                      cor_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cor_pk_csr (p_cor_rec.id);
    FETCH cor_pk_csr INTO
              l_cor_rec.ID,
              l_cor_rec.CRT_ID,
              l_cor_rec.CHANGE_SEQUENCE,
              l_cor_rec.OBJECT_VERSION_NUMBER,
              l_cor_rec.CREATED_BY,
              l_cor_rec.CREATION_DATE,
              l_cor_rec.LAST_UPDATED_BY,
              l_cor_rec.LAST_UPDATE_DATE,
              l_cor_rec.DATETIME_INEFFECTIVE,
              l_cor_rec.LAST_UPDATE_LOGIN,
              l_cor_rec.ATTRIBUTE_CATEGORY,
              l_cor_rec.ATTRIBUTE1,
              l_cor_rec.ATTRIBUTE2,
              l_cor_rec.ATTRIBUTE3,
              l_cor_rec.ATTRIBUTE4,
              l_cor_rec.ATTRIBUTE5,
              l_cor_rec.ATTRIBUTE6,
              l_cor_rec.ATTRIBUTE7,
              l_cor_rec.ATTRIBUTE8,
              l_cor_rec.ATTRIBUTE9,
              l_cor_rec.ATTRIBUTE10,
              l_cor_rec.ATTRIBUTE11,
              l_cor_rec.ATTRIBUTE12,
              l_cor_rec.ATTRIBUTE13,
              l_cor_rec.ATTRIBUTE14,
              l_cor_rec.ATTRIBUTE15;
    x_no_data_found := cor_pk_csr%NOTFOUND;
    CLOSE cor_pk_csr;
    RETURN(l_cor_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cor_rec                      IN cor_rec_type
  ) RETURN cor_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cor_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_changes_tl_rec_type IS
    CURSOR cor_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            SHORT_DESCRIPTION,
            CHANGE_TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Changes_Tl
     WHERE okc_changes_tl.id    = p_id
       AND okc_changes_tl.language = p_language;
    l_cor_pktl                     cor_pktl_csr%ROWTYPE;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cor_pktl_csr (p_okc_changes_tl_rec.id,
                       p_okc_changes_tl_rec.language);
    FETCH cor_pktl_csr INTO
              l_okc_changes_tl_rec.ID,
              l_okc_changes_tl_rec.LANGUAGE,
              l_okc_changes_tl_rec.SOURCE_LANG,
              l_okc_changes_tl_rec.SFWT_FLAG,
              l_okc_changes_tl_rec.SHORT_DESCRIPTION,
              l_okc_changes_tl_rec.CHANGE_TEXT,
              l_okc_changes_tl_rec.CREATED_BY,
              l_okc_changes_tl_rec.CREATION_DATE,
              l_okc_changes_tl_rec.LAST_UPDATED_BY,
              l_okc_changes_tl_rec.LAST_UPDATE_DATE,
              l_okc_changes_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cor_pktl_csr%NOTFOUND;
    CLOSE cor_pktl_csr;
    RETURN(l_okc_changes_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type
  ) RETURN okc_changes_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_changes_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_corv_rec                     IN corv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN corv_rec_type IS
    CURSOR okc_corv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CRT_ID,
            CHANGE_SEQUENCE,
            CHANGE_TEXT,
            SHORT_DESCRIPTION,
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
      FROM Okc_Changes_V
     WHERE okc_changes_v.id     = p_id;
    l_okc_corv_pk                  okc_corv_pk_csr%ROWTYPE;
    l_corv_rec                     corv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_corv_pk_csr (p_corv_rec.id);
    FETCH okc_corv_pk_csr INTO
              l_corv_rec.ID,
              l_corv_rec.OBJECT_VERSION_NUMBER,
              l_corv_rec.SFWT_FLAG,
              l_corv_rec.CRT_ID,
              l_corv_rec.CHANGE_SEQUENCE,
              l_corv_rec.CHANGE_TEXT,
              l_corv_rec.SHORT_DESCRIPTION,
              l_corv_rec.ATTRIBUTE_CATEGORY,
              l_corv_rec.ATTRIBUTE1,
              l_corv_rec.ATTRIBUTE2,
              l_corv_rec.ATTRIBUTE3,
              l_corv_rec.ATTRIBUTE4,
              l_corv_rec.ATTRIBUTE5,
              l_corv_rec.ATTRIBUTE6,
              l_corv_rec.ATTRIBUTE7,
              l_corv_rec.ATTRIBUTE8,
              l_corv_rec.ATTRIBUTE9,
              l_corv_rec.ATTRIBUTE10,
              l_corv_rec.ATTRIBUTE11,
              l_corv_rec.ATTRIBUTE12,
              l_corv_rec.ATTRIBUTE13,
              l_corv_rec.ATTRIBUTE14,
              l_corv_rec.ATTRIBUTE15,
              l_corv_rec.CREATED_BY,
              l_corv_rec.CREATION_DATE,
              l_corv_rec.LAST_UPDATED_BY,
              l_corv_rec.LAST_UPDATE_DATE,
              l_corv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_corv_pk_csr%NOTFOUND;
    CLOSE okc_corv_pk_csr;
    RETURN(l_corv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_corv_rec                     IN corv_rec_type
  ) RETURN corv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_corv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CHANGES_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_corv_rec	IN corv_rec_type
  ) RETURN corv_rec_type IS
    l_corv_rec	corv_rec_type := p_corv_rec;
  BEGIN
    IF (l_corv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.object_version_number := NULL;
    END IF;
    IF (l_corv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_corv_rec.crt_id = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.crt_id := NULL;
    END IF;
    IF (l_corv_rec.change_sequence = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.change_sequence := NULL;
    END IF;
---change_text field is NULL initially
---    IF (l_corv_rec.change_text = OKC_API.G_MISS_NUM) THEN
---      l_corv_rec.change_text := NULL;
---    END IF;
    IF (l_corv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.short_description := NULL;
    END IF;
    IF (l_corv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute_category := NULL;
    END IF;
    IF (l_corv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute1 := NULL;
    END IF;
    IF (l_corv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute2 := NULL;
    END IF;
    IF (l_corv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute3 := NULL;
    END IF;
    IF (l_corv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute4 := NULL;
    END IF;
    IF (l_corv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute5 := NULL;
    END IF;
    IF (l_corv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute6 := NULL;
    END IF;
    IF (l_corv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute7 := NULL;
    END IF;
    IF (l_corv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute8 := NULL;
    END IF;
    IF (l_corv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute9 := NULL;
    END IF;
    IF (l_corv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute10 := NULL;
    END IF;
    IF (l_corv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute11 := NULL;
    END IF;
    IF (l_corv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute12 := NULL;
    END IF;
    IF (l_corv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute13 := NULL;
    END IF;
    IF (l_corv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute14 := NULL;
    END IF;
    IF (l_corv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_corv_rec.attribute15 := NULL;
    END IF;
    IF (l_corv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.created_by := NULL;
    END IF;
    IF (l_corv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_corv_rec.creation_date := NULL;
    END IF;
    IF (l_corv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.last_updated_by := NULL;
    END IF;
    IF (l_corv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_corv_rec.last_update_date := NULL;
    END IF;
    IF (l_corv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_corv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_corv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_crt_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_crt_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_corv_rec	  IN	corv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_crt_csr is
  select 'x'
  from OKC_change_requests_B
  where id = p_corv_rec.crt_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_corv_rec.crt_id = OKC_API.G_MISS_NUM) then
	return;
  end if;
  if (p_corv_rec.crt_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CRT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_crt_csr;
  fetch l_crt_csr into l_dummy_var;
  close l_crt_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_crt_csr%ISOPEN then
      close l_crt_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_crt_id;


/*+++++++++++++End of hand code +++++++++++++++++++*/
  -------------------------------------------
  -- Validate_Attributes for:OKC_CHANGES_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_corv_rec IN  corv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    IF p_corv_rec.id = OKC_API.G_MISS_NUM OR
       p_corv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_corv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_corv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_corv_rec.change_sequence = OKC_API.G_MISS_NUM OR
          p_corv_rec.change_sequence IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'change_sequence');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_crt_id(x_return_status => l_return_status,
                    p_corv_rec      => p_corv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    return x_return_status;
  exception
    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;
  END Validate_Attributes;
/*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKC_CHANGES_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_corv_rec IN corv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN corv_rec_type,
    p_to	IN OUT NOCOPY cor_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crt_id := p_from.crt_id;
    p_to.change_sequence := p_from.change_sequence;
    p_to.object_version_number := p_from.object_version_number;
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
  PROCEDURE migrate (
    p_from	IN cor_rec_type,
    p_to	IN OUT NOCOPY corv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.crt_id := p_from.crt_id;
    p_to.change_sequence := p_from.change_sequence;
    p_to.object_version_number := p_from.object_version_number;
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
  PROCEDURE migrate (
    p_from	IN corv_rec_type,
    p_to	IN OUT NOCOPY okc_changes_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.change_text := p_from.change_text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_changes_tl_rec_type,
    p_to	IN OUT NOCOPY corv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.change_text := p_from.change_text;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKC_CHANGES_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_rec                     IN corv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_corv_rec                     corv_rec_type := p_corv_rec;
    l_cor_rec                      cor_rec_type;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_corv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_corv_rec);
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
  -- PL/SQL TBL validate_row for:CORV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_tbl                     IN corv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_corv_tbl.COUNT > 0) THEN
      i := p_corv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_corv_rec                     => p_corv_tbl(i));
        EXIT WHEN (i = p_corv_tbl.LAST);
        i := p_corv_tbl.NEXT(i);
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
  ----------------------------------
  -- insert_row for:OKC_CHANGES_B --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cor_rec                      IN cor_rec_type,
    x_cor_rec                      OUT NOCOPY cor_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cor_rec                      cor_rec_type := p_cor_rec;
    l_def_cor_rec                  cor_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKC_CHANGES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cor_rec IN  cor_rec_type,
      x_cor_rec OUT NOCOPY cor_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cor_rec := p_cor_rec;
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
      p_cor_rec,                         -- IN
      l_cor_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CHANGES_B(
        id,
        crt_id,
        change_sequence,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        datetime_ineffective,
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
        l_cor_rec.id,
        l_cor_rec.crt_id,
        l_cor_rec.change_sequence,
        l_cor_rec.object_version_number,
        l_cor_rec.created_by,
        l_cor_rec.creation_date,
        l_cor_rec.last_updated_by,
        l_cor_rec.last_update_date,
        l_cor_rec.datetime_ineffective,
        l_cor_rec.last_update_login,
        l_cor_rec.attribute_category,
        l_cor_rec.attribute1,
        l_cor_rec.attribute2,
        l_cor_rec.attribute3,
        l_cor_rec.attribute4,
        l_cor_rec.attribute5,
        l_cor_rec.attribute6,
        l_cor_rec.attribute7,
        l_cor_rec.attribute8,
        l_cor_rec.attribute9,
        l_cor_rec.attribute10,
        l_cor_rec.attribute11,
        l_cor_rec.attribute12,
        l_cor_rec.attribute13,
        l_cor_rec.attribute14,
        l_cor_rec.attribute15);
    -- Set OUT values
    x_cor_rec := l_cor_rec;
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
  -- insert_row for:OKC_CHANGES_TL --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type,
    x_okc_changes_tl_rec           OUT NOCOPY okc_changes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type := p_okc_changes_tl_rec;
    l_def_okc_changes_tl_rec       okc_changes_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------
    -- Set_Attributes for:OKC_CHANGES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_changes_tl_rec IN  okc_changes_tl_rec_type,
      x_okc_changes_tl_rec OUT NOCOPY okc_changes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_changes_tl_rec := p_okc_changes_tl_rec;
      x_okc_changes_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_changes_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_changes_tl_rec,              -- IN
      l_okc_changes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_changes_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_CHANGES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          short_description,
          change_text,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_changes_tl_rec.id,
          l_okc_changes_tl_rec.language,
          l_okc_changes_tl_rec.source_lang,
          l_okc_changes_tl_rec.sfwt_flag,
          l_okc_changes_tl_rec.short_description,
          l_okc_changes_tl_rec.change_text,
          l_okc_changes_tl_rec.created_by,
          l_okc_changes_tl_rec.creation_date,
          l_okc_changes_tl_rec.last_updated_by,
          l_okc_changes_tl_rec.last_update_date,
          l_okc_changes_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_changes_tl_rec := l_okc_changes_tl_rec;
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
  ----------------------------------
  -- insert_row for:OKC_CHANGES_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_rec                     IN corv_rec_type,
    x_corv_rec                     OUT NOCOPY corv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_corv_rec                     corv_rec_type;
    l_def_corv_rec                 corv_rec_type;
    l_cor_rec                      cor_rec_type;
    lx_cor_rec                     cor_rec_type;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
    lx_okc_changes_tl_rec          okc_changes_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_corv_rec	IN corv_rec_type
    ) RETURN corv_rec_type IS
      l_corv_rec	corv_rec_type := p_corv_rec;
    BEGIN
      l_corv_rec.CREATION_DATE := SYSDATE;
      l_corv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_corv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_corv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_corv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_corv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKC_CHANGES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_corv_rec IN  corv_rec_type,
      x_corv_rec OUT NOCOPY corv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_corv_rec := p_corv_rec;
      x_corv_rec.OBJECT_VERSION_NUMBER := 1;
      x_corv_rec.SFWT_FLAG := 'N';
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
    l_corv_rec := null_out_defaults(p_corv_rec);
    -- Set primary key value
    l_corv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_corv_rec,                        -- IN
      l_def_corv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_corv_rec := fill_who_columns(l_def_corv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_corv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_corv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_corv_rec, l_cor_rec);
    migrate(l_def_corv_rec, l_okc_changes_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cor_rec,
      lx_cor_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cor_rec, l_def_corv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_changes_tl_rec,
      lx_okc_changes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_changes_tl_rec, l_def_corv_rec);
    -- Set OUT values
    x_corv_rec := l_def_corv_rec;
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
  -- PL/SQL TBL insert_row for:CORV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_tbl                     IN corv_tbl_type,
    x_corv_tbl                     OUT NOCOPY corv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_corv_tbl.COUNT > 0) THEN
      i := p_corv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_corv_rec                     => p_corv_tbl(i),
          x_corv_rec                     => x_corv_tbl(i));
        EXIT WHEN (i = p_corv_tbl.LAST);
        i := p_corv_tbl.NEXT(i);
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
  --------------------------------
  -- lock_row for:OKC_CHANGES_B --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cor_rec                      IN cor_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cor_rec IN cor_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGES_B
     WHERE ID = p_cor_rec.id
       AND OBJECT_VERSION_NUMBER = p_cor_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cor_rec IN cor_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGES_B
    WHERE ID = p_cor_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CHANGES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CHANGES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cor_rec);
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
      OPEN lchk_csr(p_cor_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cor_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cor_rec.object_version_number THEN
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
  ---------------------------------
  -- lock_row for:OKC_CHANGES_TL --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_changes_tl_rec IN okc_changes_tl_rec_type) IS
    SELECT *
      FROM OKC_CHANGES_TL
     WHERE ID = p_okc_changes_tl_rec.id
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
      OPEN lock_csr(p_okc_changes_tl_rec);
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
  --------------------------------
  -- lock_row for:OKC_CHANGES_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_rec                     IN corv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cor_rec                      cor_rec_type;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
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
    migrate(p_corv_rec, l_cor_rec);
    migrate(p_corv_rec, l_okc_changes_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cor_rec
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
      l_okc_changes_tl_rec
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
  -- PL/SQL TBL lock_row for:CORV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_tbl                     IN corv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_corv_tbl.COUNT > 0) THEN
      i := p_corv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_corv_rec                     => p_corv_tbl(i));
        EXIT WHEN (i = p_corv_tbl.LAST);
        i := p_corv_tbl.NEXT(i);
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
  ----------------------------------
  -- update_row for:OKC_CHANGES_B --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cor_rec                      IN cor_rec_type,
    x_cor_rec                      OUT NOCOPY cor_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cor_rec                      cor_rec_type := p_cor_rec;
    l_def_cor_rec                  cor_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cor_rec	IN cor_rec_type,
      x_cor_rec	OUT NOCOPY cor_rec_type
    ) RETURN VARCHAR2 IS
      l_cor_rec                      cor_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cor_rec := p_cor_rec;
      -- Get current database values
      l_cor_rec := get_rec(p_cor_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cor_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.id := l_cor_rec.id;
      END IF;
      IF (x_cor_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.crt_id := l_cor_rec.crt_id;
      END IF;
      IF (x_cor_rec.change_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.change_sequence := l_cor_rec.change_sequence;
      END IF;
      IF (x_cor_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.object_version_number := l_cor_rec.object_version_number;
      END IF;
      IF (x_cor_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.created_by := l_cor_rec.created_by;
      END IF;
      IF (x_cor_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cor_rec.creation_date := l_cor_rec.creation_date;
      END IF;
      IF (x_cor_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.last_updated_by := l_cor_rec.last_updated_by;
      END IF;
      IF (x_cor_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cor_rec.last_update_date := l_cor_rec.last_update_date;
      END IF;
      IF (x_cor_rec.datetime_ineffective = OKC_API.G_MISS_DATE)
      THEN
        x_cor_rec.datetime_ineffective := l_cor_rec.datetime_ineffective;
      END IF;
      IF (x_cor_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cor_rec.last_update_login := l_cor_rec.last_update_login;
      END IF;
      IF (x_cor_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute_category := l_cor_rec.attribute_category;
      END IF;
      IF (x_cor_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute1 := l_cor_rec.attribute1;
      END IF;
      IF (x_cor_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute2 := l_cor_rec.attribute2;
      END IF;
      IF (x_cor_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute3 := l_cor_rec.attribute3;
      END IF;
      IF (x_cor_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute4 := l_cor_rec.attribute4;
      END IF;
      IF (x_cor_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute5 := l_cor_rec.attribute5;
      END IF;
      IF (x_cor_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute6 := l_cor_rec.attribute6;
      END IF;
      IF (x_cor_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute7 := l_cor_rec.attribute7;
      END IF;
      IF (x_cor_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute8 := l_cor_rec.attribute8;
      END IF;
      IF (x_cor_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute9 := l_cor_rec.attribute9;
      END IF;
      IF (x_cor_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute10 := l_cor_rec.attribute10;
      END IF;
      IF (x_cor_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute11 := l_cor_rec.attribute11;
      END IF;
      IF (x_cor_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute12 := l_cor_rec.attribute12;
      END IF;
      IF (x_cor_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute13 := l_cor_rec.attribute13;
      END IF;
      IF (x_cor_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute14 := l_cor_rec.attribute14;
      END IF;
      IF (x_cor_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cor_rec.attribute15 := l_cor_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_CHANGES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cor_rec IN  cor_rec_type,
      x_cor_rec OUT NOCOPY cor_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cor_rec := p_cor_rec;
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
      p_cor_rec,                         -- IN
      l_cor_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cor_rec, l_def_cor_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CHANGES_B
    SET CRT_ID = l_def_cor_rec.crt_id,
        CHANGE_SEQUENCE = l_def_cor_rec.change_sequence,
        OBJECT_VERSION_NUMBER = l_def_cor_rec.object_version_number,
        CREATED_BY = l_def_cor_rec.created_by,
        CREATION_DATE = l_def_cor_rec.creation_date,
        LAST_UPDATED_BY = l_def_cor_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cor_rec.last_update_date,
        DATETIME_INEFFECTIVE = l_def_cor_rec.datetime_ineffective,
        LAST_UPDATE_LOGIN = l_def_cor_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_cor_rec.attribute_category,
        ATTRIBUTE1 = l_def_cor_rec.attribute1,
        ATTRIBUTE2 = l_def_cor_rec.attribute2,
        ATTRIBUTE3 = l_def_cor_rec.attribute3,
        ATTRIBUTE4 = l_def_cor_rec.attribute4,
        ATTRIBUTE5 = l_def_cor_rec.attribute5,
        ATTRIBUTE6 = l_def_cor_rec.attribute6,
        ATTRIBUTE7 = l_def_cor_rec.attribute7,
        ATTRIBUTE8 = l_def_cor_rec.attribute8,
        ATTRIBUTE9 = l_def_cor_rec.attribute9,
        ATTRIBUTE10 = l_def_cor_rec.attribute10,
        ATTRIBUTE11 = l_def_cor_rec.attribute11,
        ATTRIBUTE12 = l_def_cor_rec.attribute12,
        ATTRIBUTE13 = l_def_cor_rec.attribute13,
        ATTRIBUTE14 = l_def_cor_rec.attribute14,
        ATTRIBUTE15 = l_def_cor_rec.attribute15
    WHERE ID = l_def_cor_rec.id;

    x_cor_rec := l_def_cor_rec;
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
  -- update_row for:OKC_CHANGES_TL --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type,
    x_okc_changes_tl_rec           OUT NOCOPY okc_changes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type := p_okc_changes_tl_rec;
    l_def_okc_changes_tl_rec       okc_changes_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_changes_tl_rec	IN okc_changes_tl_rec_type,
      x_okc_changes_tl_rec	OUT NOCOPY okc_changes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_changes_tl_rec           okc_changes_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_changes_tl_rec := p_okc_changes_tl_rec;
      -- Get current database values
      l_okc_changes_tl_rec := get_rec(p_okc_changes_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_changes_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_changes_tl_rec.id := l_okc_changes_tl_rec.id;
      END IF;
      IF (x_okc_changes_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_changes_tl_rec.language := l_okc_changes_tl_rec.language;
      END IF;
      IF (x_okc_changes_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_changes_tl_rec.source_lang := l_okc_changes_tl_rec.source_lang;
      END IF;
      IF (x_okc_changes_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_changes_tl_rec.sfwt_flag := l_okc_changes_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_changes_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_changes_tl_rec.short_description := l_okc_changes_tl_rec.short_description;
      END IF;
-- Commented in favor of hand code
---      IF (x_okc_changes_tl_rec.change_text = OKC_API.G_MISS_CHAR)
	      IF (x_okc_changes_tl_rec.change_text is NULL)
      THEN
        x_okc_changes_tl_rec.change_text := l_okc_changes_tl_rec.change_text;
      END IF;
      IF (x_okc_changes_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_changes_tl_rec.created_by := l_okc_changes_tl_rec.created_by;
      END IF;
      IF (x_okc_changes_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_changes_tl_rec.creation_date := l_okc_changes_tl_rec.creation_date;
      END IF;
      IF (x_okc_changes_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_changes_tl_rec.last_updated_by := l_okc_changes_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_changes_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_changes_tl_rec.last_update_date := l_okc_changes_tl_rec.last_update_date;
      END IF;
      IF (x_okc_changes_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_changes_tl_rec.last_update_login := l_okc_changes_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_CHANGES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_changes_tl_rec IN  okc_changes_tl_rec_type,
      x_okc_changes_tl_rec OUT NOCOPY okc_changes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_changes_tl_rec := p_okc_changes_tl_rec;
      x_okc_changes_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_changes_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_changes_tl_rec,              -- IN
      l_okc_changes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_changes_tl_rec, l_def_okc_changes_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CHANGES_TL
    SET SHORT_DESCRIPTION = l_def_okc_changes_tl_rec.short_description,
        CHANGE_TEXT = l_def_okc_changes_tl_rec.change_text,
        CREATED_BY = l_def_okc_changes_tl_rec.created_by,
        CREATION_DATE = l_def_okc_changes_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_changes_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_changes_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_changes_tl_rec.last_update_login,
        SOURCE_LANG = l_def_okc_changes_tl_rec.source_lang
    WHERE ID = l_def_okc_changes_tl_rec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);

    UPDATE  OKC_CHANGES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_changes_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_changes_tl_rec := l_def_okc_changes_tl_rec;
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
  ----------------------------------
  -- update_row for:OKC_CHANGES_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_rec                     IN corv_rec_type,
    x_corv_rec                     OUT NOCOPY corv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_corv_rec                     corv_rec_type := p_corv_rec;
    l_def_corv_rec                 corv_rec_type;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
    lx_okc_changes_tl_rec          okc_changes_tl_rec_type;
    l_cor_rec                      cor_rec_type;
    lx_cor_rec                     cor_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_corv_rec	IN corv_rec_type
    ) RETURN corv_rec_type IS
      l_corv_rec	corv_rec_type := p_corv_rec;
    BEGIN
      l_corv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_corv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_corv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_corv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_corv_rec	IN corv_rec_type,
      x_corv_rec	OUT NOCOPY corv_rec_type
    ) RETURN VARCHAR2 IS
      l_corv_rec                     corv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_corv_rec := p_corv_rec;
      -- Get current database values
      l_corv_rec := get_rec(p_corv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_corv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.id := l_corv_rec.id;
      END IF;
      IF (x_corv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.object_version_number := l_corv_rec.object_version_number;
      END IF;
      IF (x_corv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.sfwt_flag := l_corv_rec.sfwt_flag;
      END IF;
      IF (x_corv_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.crt_id := l_corv_rec.crt_id;
      END IF;
      IF (x_corv_rec.change_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.change_sequence := l_corv_rec.change_sequence;
      END IF;
      IF (x_corv_rec.change_text is NULL)
      THEN
        x_corv_rec.change_text := l_corv_rec.change_text;
      END IF;
      IF (x_corv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.short_description := l_corv_rec.short_description;
      END IF;
      IF (x_corv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute_category := l_corv_rec.attribute_category;
      END IF;
      IF (x_corv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute1 := l_corv_rec.attribute1;
      END IF;
      IF (x_corv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute2 := l_corv_rec.attribute2;
      END IF;
      IF (x_corv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute3 := l_corv_rec.attribute3;
      END IF;
      IF (x_corv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute4 := l_corv_rec.attribute4;
      END IF;
      IF (x_corv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute5 := l_corv_rec.attribute5;
      END IF;
      IF (x_corv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute6 := l_corv_rec.attribute6;
      END IF;
      IF (x_corv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute7 := l_corv_rec.attribute7;
      END IF;
      IF (x_corv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute8 := l_corv_rec.attribute8;
      END IF;
      IF (x_corv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute9 := l_corv_rec.attribute9;
      END IF;
      IF (x_corv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute10 := l_corv_rec.attribute10;
      END IF;
      IF (x_corv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute11 := l_corv_rec.attribute11;
      END IF;
      IF (x_corv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute12 := l_corv_rec.attribute12;
      END IF;
      IF (x_corv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute13 := l_corv_rec.attribute13;
      END IF;
      IF (x_corv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute14 := l_corv_rec.attribute14;
      END IF;
      IF (x_corv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_corv_rec.attribute15 := l_corv_rec.attribute15;
      END IF;
      IF (x_corv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.created_by := l_corv_rec.created_by;
      END IF;
      IF (x_corv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_corv_rec.creation_date := l_corv_rec.creation_date;
      END IF;
      IF (x_corv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.last_updated_by := l_corv_rec.last_updated_by;
      END IF;
      IF (x_corv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_corv_rec.last_update_date := l_corv_rec.last_update_date;
      END IF;
      IF (x_corv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_corv_rec.last_update_login := l_corv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_CHANGES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_corv_rec IN  corv_rec_type,
      x_corv_rec OUT NOCOPY corv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_corv_rec := p_corv_rec;
      x_corv_rec.OBJECT_VERSION_NUMBER := NVL(x_corv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_corv_rec,                        -- IN
      l_corv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_corv_rec, l_def_corv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_corv_rec := fill_who_columns(l_def_corv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_corv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_corv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_corv_rec, l_okc_changes_tl_rec);
    migrate(l_def_corv_rec, l_cor_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_changes_tl_rec,
      lx_okc_changes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_changes_tl_rec, l_def_corv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cor_rec,
      lx_cor_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cor_rec, l_def_corv_rec);
    x_corv_rec := l_def_corv_rec;
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
  -- PL/SQL TBL update_row for:CORV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_tbl                     IN corv_tbl_type,
    x_corv_tbl                     OUT NOCOPY corv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_corv_tbl.COUNT > 0) THEN
      i := p_corv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_corv_rec                     => p_corv_tbl(i),
          x_corv_rec                     => x_corv_tbl(i));
        EXIT WHEN (i = p_corv_tbl.LAST);
        i := p_corv_tbl.NEXT(i);
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
  ----------------------------------
  -- delete_row for:OKC_CHANGES_B --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cor_rec                      IN cor_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cor_rec                      cor_rec_type:= p_cor_rec;
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
    DELETE FROM OKC_CHANGES_B
     WHERE ID = l_cor_rec.id;

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
  -- delete_row for:OKC_CHANGES_TL --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_changes_tl_rec           IN okc_changes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type:= p_okc_changes_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------
    -- Set_Attributes for:OKC_CHANGES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_changes_tl_rec IN  okc_changes_tl_rec_type,
      x_okc_changes_tl_rec OUT NOCOPY okc_changes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_changes_tl_rec := p_okc_changes_tl_rec;
      x_okc_changes_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_changes_tl_rec,              -- IN
      l_okc_changes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CHANGES_TL
     WHERE ID = l_okc_changes_tl_rec.id;

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
  ----------------------------------
  -- delete_row for:OKC_CHANGES_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_rec                     IN corv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_corv_rec                     corv_rec_type := p_corv_rec;
    l_okc_changes_tl_rec           okc_changes_tl_rec_type;
    l_cor_rec                      cor_rec_type;
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
    migrate(l_corv_rec, l_okc_changes_tl_rec);
    migrate(l_corv_rec, l_cor_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_changes_tl_rec
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
      l_cor_rec
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
  -- PL/SQL TBL delete_row for:CORV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_corv_tbl                     IN corv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_corv_tbl.COUNT > 0) THEN
      i := p_corv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_corv_rec                     => p_corv_tbl(i));
        EXIT WHEN (i = p_corv_tbl.LAST);
        i := p_corv_tbl.NEXT(i);
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
END OKC_COR_PVT;

/

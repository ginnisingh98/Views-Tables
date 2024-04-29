--------------------------------------------------------
--  DDL for Package Body OKC_CRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CRT_PVT" AS
/* $Header: OKCSCRTB.pls 120.1 2006/06/06 20:47:50 upillai noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
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
/* Refer Bugs 4210278, 3723612, 5264746

    DELETE FROM OKC_CHANGE_REQUESTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CHANGE_REQUESTS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_CHANGE_REQUESTS_TL T SET (
        NAME,
        SHORT_DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.SHORT_DESCRIPTION
                                FROM OKC_CHANGE_REQUESTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_CHANGE_REQUESTS_TL SUBB, OKC_CHANGE_REQUESTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
              ));
*/

    /* Modifying Insert as per performance guidelines given in bug 3723874 */
    INSERT /*+ append parallel(tt) */ INTO OKC_CHANGE_REQUESTS_TL tt(
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        SHORT_DESCRIPTION,
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
            B.NAME,
            B.SHORT_DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_CHANGE_REQUESTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
	  ) v, OKC_CHANGE_REQUESTS_TL T
       WHERE T.ID(+) = v.ID
	  AND T.LANGUAGE(+) = v.LANGUAGE_CODE
	  AND T.ID IS NULL;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGE_REQUESTS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crt_rec                      IN crt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crt_rec_type IS
    CURSOR crt_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            CRS_CODE,
            USER_ID,
            DATETIME_REQUEST,
            CRT_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DATETIME_EFFECTIVE,
            EXTENDED_YN,
            AUTHORITY,
            SIGNATURE_REQUIRED_YN,
            DATETIME_APPROVED,
            DATETIME_REJECTED,
            DATETIME_INEFFECTIVE,
            VERSION_CONTRACT,
            APPLIED_CONTRACT_VERSION,
            DATETIME_APPLIED,
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
      FROM Okc_Change_Requests_B
     WHERE okc_change_requests_b.id = p_id;
    l_crt_pk                       crt_pk_csr%ROWTYPE;
    l_crt_rec                      crt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN crt_pk_csr (p_crt_rec.id);
    FETCH crt_pk_csr INTO
              l_crt_rec.ID,
              l_crt_rec.CHR_ID,
              l_crt_rec.CRS_CODE,
              l_crt_rec.USER_ID,
              l_crt_rec.DATETIME_REQUEST,
              l_crt_rec.CRT_TYPE,
              l_crt_rec.OBJECT_VERSION_NUMBER,
              l_crt_rec.CREATED_BY,
              l_crt_rec.CREATION_DATE,
              l_crt_rec.LAST_UPDATED_BY,
              l_crt_rec.LAST_UPDATE_DATE,
              l_crt_rec.DATETIME_EFFECTIVE,
              l_crt_rec.EXTENDED_YN,
              l_crt_rec.AUTHORITY,
              l_crt_rec.SIGNATURE_REQUIRED_YN,
              l_crt_rec.DATETIME_APPROVED,
              l_crt_rec.DATETIME_REJECTED,
              l_crt_rec.DATETIME_INEFFECTIVE,
              l_crt_rec.VERSION_CONTRACT,
              l_crt_rec.APPLIED_CONTRACT_VERSION,
              l_crt_rec.DATETIME_APPLIED,
              l_crt_rec.LAST_UPDATE_LOGIN,
              l_crt_rec.ATTRIBUTE_CATEGORY,
              l_crt_rec.ATTRIBUTE1,
              l_crt_rec.ATTRIBUTE2,
              l_crt_rec.ATTRIBUTE3,
              l_crt_rec.ATTRIBUTE4,
              l_crt_rec.ATTRIBUTE5,
              l_crt_rec.ATTRIBUTE6,
              l_crt_rec.ATTRIBUTE7,
              l_crt_rec.ATTRIBUTE8,
              l_crt_rec.ATTRIBUTE9,
              l_crt_rec.ATTRIBUTE10,
              l_crt_rec.ATTRIBUTE11,
              l_crt_rec.ATTRIBUTE12,
              l_crt_rec.ATTRIBUTE13,
              l_crt_rec.ATTRIBUTE14,
              l_crt_rec.ATTRIBUTE15;
    x_no_data_found := crt_pk_csr%NOTFOUND;
    CLOSE crt_pk_csr;
    RETURN(l_crt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crt_rec                      IN crt_rec_type
  ) RETURN crt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGE_REQUESTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcChangeRequestsTlRecType IS
    CURSOR crt_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            SHORT_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Change_Requests_Tl
     WHERE okc_change_requests_tl.id = p_id
       AND okc_change_requests_tl.language = p_language;
    l_crt_pktl                     crt_pktl_csr%ROWTYPE;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN crt_pktl_csr (p_okc_change_requests_tl_rec.id,
                       p_okc_change_requests_tl_rec.language);
    FETCH crt_pktl_csr INTO
              l_okc_change_requests_tl_rec.ID,
              l_okc_change_requests_tl_rec.LANGUAGE,
              l_okc_change_requests_tl_rec.SOURCE_LANG,
              l_okc_change_requests_tl_rec.SFWT_FLAG,
              l_okc_change_requests_tl_rec.NAME,
              l_okc_change_requests_tl_rec.SHORT_DESCRIPTION,
              l_okc_change_requests_tl_rec.CREATED_BY,
              l_okc_change_requests_tl_rec.CREATION_DATE,
              l_okc_change_requests_tl_rec.LAST_UPDATED_BY,
              l_okc_change_requests_tl_rec.LAST_UPDATE_DATE,
              l_okc_change_requests_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := crt_pktl_csr%NOTFOUND;
    CLOSE crt_pktl_csr;
    RETURN(l_okc_change_requests_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType
  ) RETURN OkcChangeRequestsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_change_requests_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGE_REQUESTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crtv_rec                     IN crtv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crtv_rec_type IS
    CURSOR okc_crtv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CHR_ID,
            CRS_CODE,
            USER_ID,
            NAME,
            DATETIME_REQUEST,
            SHORT_DESCRIPTION,
            EXTENDED_YN,
            AUTHORITY,
            SIGNATURE_REQUIRED_YN,
            DATETIME_APPROVED,
            DATETIME_REJECTED,
            DATETIME_EFFECTIVE,
            DATETIME_INEFFECTIVE,
            DATETIME_APPLIED,
            VERSION_CONTRACT,
            APPLIED_CONTRACT_VERSION,
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
            CRT_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Change_Requests_V
     WHERE okc_change_requests_v.id = p_id;
    l_okc_crtv_pk                  okc_crtv_pk_csr%ROWTYPE;
    l_crtv_rec                     crtv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_crtv_pk_csr (p_crtv_rec.id);
    FETCH okc_crtv_pk_csr INTO
              l_crtv_rec.ID,
              l_crtv_rec.OBJECT_VERSION_NUMBER,
              l_crtv_rec.SFWT_FLAG,
              l_crtv_rec.CHR_ID,
              l_crtv_rec.CRS_CODE,
              l_crtv_rec.USER_ID,
              l_crtv_rec.NAME,
              l_crtv_rec.DATETIME_REQUEST,
              l_crtv_rec.SHORT_DESCRIPTION,
              l_crtv_rec.EXTENDED_YN,
              l_crtv_rec.AUTHORITY,
              l_crtv_rec.SIGNATURE_REQUIRED_YN,
              l_crtv_rec.DATETIME_APPROVED,
              l_crtv_rec.DATETIME_REJECTED,
              l_crtv_rec.DATETIME_EFFECTIVE,
              l_crtv_rec.DATETIME_INEFFECTIVE,
              l_crtv_rec.DATETIME_APPLIED,
              l_crtv_rec.VERSION_CONTRACT,
              l_crtv_rec.APPLIED_CONTRACT_VERSION,
              l_crtv_rec.ATTRIBUTE_CATEGORY,
              l_crtv_rec.ATTRIBUTE1,
              l_crtv_rec.ATTRIBUTE2,
              l_crtv_rec.ATTRIBUTE3,
              l_crtv_rec.ATTRIBUTE4,
              l_crtv_rec.ATTRIBUTE5,
              l_crtv_rec.ATTRIBUTE6,
              l_crtv_rec.ATTRIBUTE7,
              l_crtv_rec.ATTRIBUTE8,
              l_crtv_rec.ATTRIBUTE9,
              l_crtv_rec.ATTRIBUTE10,
              l_crtv_rec.ATTRIBUTE11,
              l_crtv_rec.ATTRIBUTE12,
              l_crtv_rec.ATTRIBUTE13,
              l_crtv_rec.ATTRIBUTE14,
              l_crtv_rec.ATTRIBUTE15,
              l_crtv_rec.CRT_TYPE,
              l_crtv_rec.CREATED_BY,
              l_crtv_rec.CREATION_DATE,
              l_crtv_rec.LAST_UPDATED_BY,
              l_crtv_rec.LAST_UPDATE_DATE,
              l_crtv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_crtv_pk_csr%NOTFOUND;
    CLOSE okc_crtv_pk_csr;
    RETURN(l_crtv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crtv_rec                     IN crtv_rec_type
  ) RETURN crtv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crtv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CHANGE_REQUESTS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_crtv_rec	IN crtv_rec_type
  ) RETURN crtv_rec_type IS
    l_crtv_rec	crtv_rec_type := p_crtv_rec;
  BEGIN
    IF (l_crtv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.object_version_number := NULL;
    END IF;
    IF (l_crtv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_crtv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.chr_id := NULL;
    END IF;
    IF (l_crtv_rec.crs_code = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.crs_code := NULL;
    END IF;
    IF (l_crtv_rec.user_id = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.user_id := NULL;
    END IF;
    IF (l_crtv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.name := NULL;
    END IF;
    IF (l_crtv_rec.datetime_request = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_request := NULL;
    END IF;
    IF (l_crtv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.short_description := NULL;
    END IF;
    IF (l_crtv_rec.extended_yn = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.extended_yn := NULL;
    END IF;
    IF (l_crtv_rec.authority = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.authority := NULL;
    END IF;
    IF (l_crtv_rec.signature_required_yn = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.signature_required_yn := NULL;
    END IF;
    IF (l_crtv_rec.datetime_approved = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_approved := NULL;
    END IF;
    IF (l_crtv_rec.datetime_rejected = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_rejected := NULL;
    END IF;
    IF (l_crtv_rec.datetime_effective = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_effective := NULL;
    END IF;
    IF (l_crtv_rec.datetime_ineffective = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_ineffective := NULL;
    END IF;
    IF (l_crtv_rec.datetime_applied = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.datetime_applied := NULL;
    END IF;
    IF (l_crtv_rec.version_contract = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.version_contract := NULL;
    END IF;
    IF (l_crtv_rec.applied_contract_version = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.applied_contract_version := NULL;
    END IF;
    IF (l_crtv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute_category := NULL;
    END IF;
    IF (l_crtv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute1 := NULL;
    END IF;
    IF (l_crtv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute2 := NULL;
    END IF;
    IF (l_crtv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute3 := NULL;
    END IF;
    IF (l_crtv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute4 := NULL;
    END IF;
    IF (l_crtv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute5 := NULL;
    END IF;
    IF (l_crtv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute6 := NULL;
    END IF;
    IF (l_crtv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute7 := NULL;
    END IF;
    IF (l_crtv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute8 := NULL;
    END IF;
    IF (l_crtv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute9 := NULL;
    END IF;
    IF (l_crtv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute10 := NULL;
    END IF;
    IF (l_crtv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute11 := NULL;
    END IF;
    IF (l_crtv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute12 := NULL;
    END IF;
    IF (l_crtv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute13 := NULL;
    END IF;
    IF (l_crtv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute14 := NULL;
    END IF;
    IF (l_crtv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.attribute15 := NULL;
    END IF;
    IF (l_crtv_rec.crt_type = OKC_API.G_MISS_CHAR) THEN
      l_crtv_rec.crt_type := NULL;
    END IF;
    IF (l_crtv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.created_by := NULL;
    END IF;
    IF (l_crtv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.creation_date := NULL;
    END IF;
    IF (l_crtv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.last_updated_by := NULL;
    END IF;
    IF (l_crtv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_crtv_rec.last_update_date := NULL;
    END IF;
    IF (l_crtv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_crtv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_crtv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_crt_type
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_crt_type(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	crtv_rec_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.crt_type in ('AMT','ALN',OKC_API.G_MISS_CHAR)) then
	return;
  end if;
  OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CRT_TYPE');
  x_return_status := OKC_API.G_RET_STS_ERROR;
end validate_crt_type;

-- Start of comments
--
-- Procedure Name  : validate_user_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_user_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	crtv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_user_csr is
  select 'x'
  from fnd_user_view
  where user_id = p_crtv_rec.user_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.user_id is NULL or p_crtv_rec.user_id = OKC_API.G_MISS_NUM) then
	return;
  end if;
  open l_user_csr;
  fetch l_user_csr into l_dummy_var;
  close l_user_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'USER_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
exception
  when OTHERS then
    if l_user_csr%ISOPEN then
      close l_user_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_user_id;

-- Start of comments
--
-- Procedure Name  : validate_crs_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_crs_code(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	CRTV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.crs_code is NULL or p_crtv_rec.crs_code = OKC_API.G_MISS_CHAR) then
    return;
  end if;
  x_return_status := OKC_UTIL.check_lookup_code('OKC_CHANGE_REQUEST_STATUS',p_crtv_rec.crs_code);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRS_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
exception
  when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_crs_code;

-- Start of comments
--
-- Procedure Name  : validate_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_name(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	CRTV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.name = OKC_API.G_MISS_CHAR) then
    return;
  end if;
  if (p_crtv_rec.name is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'NAME');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
exception
  when OTHERS then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_name;

-- Start of comments
--
-- Procedure Name  : validate_datetime_request
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_datetime_request(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	CRTV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.datetime_request = OKC_API.G_MISS_DATE) then
    return;
  end if;
  if (p_crtv_rec.datetime_request is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DATETIME_REQUEST');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
exception
  when OTHERS then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_datetime_request;

-- Start of comments
--
-- Procedure Name  : validate_datetime_effective
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_datetime_effective(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	CRTV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.datetime_effective = OKC_API.G_MISS_DATE) then
    return;
  end if;
  if (p_crtv_rec.datetime_effective is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DATETIME_EFFECTIVE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
exception
  when OTHERS then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_datetime_effective;

-- Start of comments
--
-- Procedure Name  : validate_version_contract
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_version_contract(x_return_status OUT NOCOPY VARCHAR2,
                          p_crtv_rec	  IN	crtv_rec_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_crtv_rec.version_contract in ('Y','N',OKC_API.G_MISS_CHAR) or
	p_crtv_rec.version_contract is NULL) then
	return;
  end if;
  OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CRT_TYPE');
  x_return_status := OKC_API.G_RET_STS_ERROR;
end validate_version_contract;

/*+++++++++++++End of hand code +++++++++++++++++++*/
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_CHANGE_REQUESTS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_crtv_rec IN  crtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    IF p_crtv_rec.id = OKC_API.G_MISS_NUM OR
       p_crtv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_crtv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_crtv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_crtv_rec.name = OKC_API.G_MISS_CHAR OR
          p_crtv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_crtv_rec.datetime_request = OKC_API.G_MISS_DATE OR
          p_crtv_rec.datetime_request IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'datetime_request');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_crtv_rec.datetime_effective = OKC_API.G_MISS_DATE OR
          p_crtv_rec.datetime_effective IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'datetime_effective');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_crtv_rec.crt_type = OKC_API.G_MISS_CHAR OR
          p_crtv_rec.crt_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'crt_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_crt_type(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_user_id(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_crs_code(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_name(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_datetime_request(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_datetime_effective(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  --
    validate_version_contract(x_return_status => l_return_status,
                    p_crtv_rec      => p_crtv_rec);
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
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_CHANGE_REQUESTS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_crtv_rec IN crtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  /*-------------Commented in favor of hand code------
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_crtv_rec IN crtv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR fnd_common_lookup_pk_csr (p_lookup_code        IN VARCHAR2) IS
      SELECT
              APPLICATION_ID,
              LOOKUP_TYPE,
              LOOKUP_CODE,
              MEANING,
              DESCRIPTION,
              ENABLED_FLAG,
              START_DATE_ACTIVE,
              END_DATE_ACTIVE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
        FROM Fnd_Common_Lookups
       WHERE fnd_common_lookups.lookup_code = p_lookup_code;
      l_fnd_common_lookup_pk         fnd_common_lookup_pk_csr%ROWTYPE;
      CURSOR fnd_userv_pk_csr (p_user_id            IN NUMBER) IS
      SELECT
              USER_ID,
              USER_NAME,
              ENCRYPTED_FOUNDATION_PASSWORD,
              START_DATE,
              END_DATE
        FROM Fnd_User_View
       WHERE fnd_user_view.user_id = p_user_id;
      l_fnd_userv_pk                 fnd_userv_pk_csr%ROWTYPE;
      CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              VERSION,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              WCR_ID_MASTER,
              CHR_ID_RESPONSE,
              CHR_ID_AWARD,
              STS_CODE,
              QCL_ID,
              CLS_CODE,
              CONTRACT_NUMBER,
              CURRENCY_CODE,
              CONTRACT_NUMBER_MODIFIER,
              ARCHIVED_YN,
              DELETED_YN,
              CUST_PO_NUMBER_REQ_YN,
              PRE_PAY_REQ_YN,
              CUST_PO_NUMBER,
              SHORT_DESCRIPTION,
              COMMENTS,
              DESCRIPTION,
              DPAS_RATING,
              COGNOMEN,
              TEMPLATE_YN,
              TEMPLATE_USED,
              DATE_APPROVED,
              DATETIME_CANCELLED,
              AUTO_RENEW_DAYS,
              DATE_ISSUED,
              DATETIME_RESPONDED,
              NON_RESPONSE_REASON,
              NON_RESPONSE_EXPLAIN,
              RFP_TYPE,
              CHR_TYPE,
              KEEP_ON_MAIL_LIST,
              SET_ASIDE_REASON,
              SET_ASIDE_PERCENT,
              RESPONSE_COPIES_REQ,
              DATE_CLOSE_PROJECTED,
              DATETIME_PROPOSED,
              DATE_SIGNED,
              DATE_TERMINATED,
              DATE_RENEWED,
              TRN_CODE,
              START_DATE,
              END_DATE,
              AUTHORING_ORG_ID,
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
        FROM Okc_K_Headers_V
       WHERE okc_k_headers_v.id   = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_crtv_rec.CRS_CODE IS NOT NULL)
      THEN
        OPEN fnd_common_lookup_pk_csr(p_crtv_rec.CRS_CODE);
        FETCH fnd_common_lookup_pk_csr INTO l_fnd_common_lookup_pk;
        l_row_notfound := fnd_common_lookup_pk_csr%NOTFOUND;
        CLOSE fnd_common_lookup_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_crtv_rec.USER_ID IS NOT NULL)
      THEN
        OPEN fnd_userv_pk_csr(p_crtv_rec.USER_ID);
        FETCH fnd_userv_pk_csr INTO l_fnd_userv_pk;
        l_row_notfound := fnd_userv_pk_csr%NOTFOUND;
        CLOSE fnd_userv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'USER_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_crtv_rec.CHR_ID IS NOT NULL)
      THEN
        OPEN okc_chrv_pk_csr(p_crtv_rec.CHR_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
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
    l_return_status := validate_foreign_keys (p_crtv_rec);
    RETURN (l_return_status);
  END Validate_Record;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
cursor aln_chr_csr is
  select '!'
  from okc_k_hdr_agreeds_v
  where id = p_crtv_rec.chr_id;
cursor amt_chr_csr is
  select '!'
--  from okc_k_hdr_rfps_v
  from okc_k_headers_v
  where id = p_crtv_rec.chr_id;
l_dummy varchar2(1) := '?';
  BEGIN
    if (p_crtv_rec.crt_type = 'ALN') then
	if not (p_crtv_rec.extended_yn is NULL
			or p_crtv_rec.extended_yn = OKC_API.G_MISS_CHAR)
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'EXTENDED_YN');
	end if;
	open aln_chr_csr;
	fetch aln_chr_csr into l_dummy;
	close aln_chr_csr;
	if l_dummy = '?'
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CHR_ID');
	end if;
	if not (p_crtv_rec.SIGNATURE_REQUIRED_YN in ('Y','N',OKC_API.G_MISS_CHAR))
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SIGNATURE_REQUIRED_YN');
	end if;
    end if;
    if (p_crtv_rec.crt_type = 'AMT') then
	if not (p_crtv_rec.authority is NULL
			or p_crtv_rec.authority = OKC_API.G_MISS_CHAR)
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'AUTHORITY');
	end if;
	if not (p_crtv_rec.SIGNATURE_REQUIRED_YN is NULL
			or p_crtv_rec.SIGNATURE_REQUIRED_YN = OKC_API.G_MISS_CHAR)
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SIGNATURE_REQUIRED_YN');
	end if;
	open amt_chr_csr;
	fetch amt_chr_csr into l_dummy;
	close amt_chr_csr;
	if l_dummy = '?'
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CHR_ID');
	end if;
	if not (p_crtv_rec.EXTENDED_YN in ('Y','N',OKC_API.G_MISS_CHAR))
	then
		x_return_status := OKC_API.G_RET_STS_ERROR;
  		OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'EXTENDED_YN');
	end if;
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
  END Validate_Record;
/*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN crtv_rec_type,
    p_to	IN OUT NOCOPY crt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.crs_code := p_from.crs_code;
    p_to.user_id := p_from.user_id;
    p_to.datetime_request := p_from.datetime_request;
    p_to.crt_type := p_from.crt_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.datetime_effective := p_from.datetime_effective;
    p_to.extended_yn := p_from.extended_yn;
    p_to.authority := p_from.authority;
    p_to.signature_required_yn := p_from.signature_required_yn;
    p_to.datetime_approved := p_from.datetime_approved;
    p_to.datetime_rejected := p_from.datetime_rejected;
    p_to.datetime_ineffective := p_from.datetime_ineffective;
    p_to.version_contract := p_from.version_contract;
    p_to.applied_contract_version := p_from.applied_contract_version;
    p_to.datetime_applied := p_from.datetime_applied;
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
    p_from	IN crt_rec_type,
    p_to	IN OUT NOCOPY crtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.crs_code := p_from.crs_code;
    p_to.user_id := p_from.user_id;
    p_to.datetime_request := p_from.datetime_request;
    p_to.crt_type := p_from.crt_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.datetime_effective := p_from.datetime_effective;
    p_to.extended_yn := p_from.extended_yn;
    p_to.authority := p_from.authority;
    p_to.signature_required_yn := p_from.signature_required_yn;
    p_to.datetime_approved := p_from.datetime_approved;
    p_to.datetime_rejected := p_from.datetime_rejected;
    p_to.datetime_ineffective := p_from.datetime_ineffective;
    p_to.version_contract := p_from.version_contract;
    p_to.applied_contract_version := p_from.applied_contract_version;
    p_to.datetime_applied := p_from.datetime_applied;
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
    p_from	IN crtv_rec_type,
    p_to	IN OUT NOCOPY OkcChangeRequestsTlRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.short_description := p_from.short_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OkcChangeRequestsTlRecType,
    p_to	IN OUT NOCOPY crtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.short_description := p_from.short_description;
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
  -- validate_row for:OKC_CHANGE_REQUESTS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crtv_rec                     crtv_rec_type := p_crtv_rec;
    l_crt_rec                      crt_rec_type;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
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
    l_return_status := Validate_Attributes(l_crtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_crtv_rec);
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
  -- PL/SQL TBL validate_row for:CRTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crtv_tbl.COUNT > 0) THEN
      i := p_crtv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crtv_rec                     => p_crtv_tbl(i));
        EXIT WHEN (i = p_crtv_tbl.LAST);
        i := p_crtv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_CHANGE_REQUESTS_B --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crt_rec                      IN crt_rec_type,
    x_crt_rec                      OUT NOCOPY crt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crt_rec                      crt_rec_type := p_crt_rec;
    l_def_crt_rec                  crt_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crt_rec IN  crt_rec_type,
      x_crt_rec OUT NOCOPY crt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crt_rec := p_crt_rec;
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
      p_crt_rec,                         -- IN
      l_crt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CHANGE_REQUESTS_B(
        id,
        chr_id,
        crs_code,
        user_id,
        datetime_request,
        crt_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        datetime_effective,
        extended_yn,
        authority,
        signature_required_yn,
        datetime_approved,
        datetime_rejected,
        datetime_ineffective,
        version_contract,
        applied_contract_version,
        datetime_applied,
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
        l_crt_rec.id,
        l_crt_rec.chr_id,
        l_crt_rec.crs_code,
        l_crt_rec.user_id,
        l_crt_rec.datetime_request,
        l_crt_rec.crt_type,
        l_crt_rec.object_version_number,
        l_crt_rec.created_by,
        l_crt_rec.creation_date,
        l_crt_rec.last_updated_by,
        l_crt_rec.last_update_date,
        l_crt_rec.datetime_effective,
        l_crt_rec.extended_yn,
        l_crt_rec.authority,
        l_crt_rec.signature_required_yn,
        l_crt_rec.datetime_approved,
        l_crt_rec.datetime_rejected,
        l_crt_rec.datetime_ineffective,
        l_crt_rec.version_contract,
        l_crt_rec.applied_contract_version,
        l_crt_rec.datetime_applied,
        l_crt_rec.last_update_login,
        l_crt_rec.attribute_category,
        l_crt_rec.attribute1,
        l_crt_rec.attribute2,
        l_crt_rec.attribute3,
        l_crt_rec.attribute4,
        l_crt_rec.attribute5,
        l_crt_rec.attribute6,
        l_crt_rec.attribute7,
        l_crt_rec.attribute8,
        l_crt_rec.attribute9,
        l_crt_rec.attribute10,
        l_crt_rec.attribute11,
        l_crt_rec.attribute12,
        l_crt_rec.attribute13,
        l_crt_rec.attribute14,
        l_crt_rec.attribute15);
    -- Set OUT values
    x_crt_rec := l_crt_rec;
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
  -- insert_row for:OKC_CHANGE_REQUESTS_TL --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType,
    x_okc_change_requests_tl_rec   OUT NOCOPY OkcChangeRequestsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType := p_okc_change_requests_tl_rec;
    ldefokcchangerequeststlrec     OkcChangeRequestsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_change_requests_tl_rec IN  OkcChangeRequestsTlRecType,
      x_okc_change_requests_tl_rec OUT NOCOPY OkcChangeRequestsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_change_requests_tl_rec := p_okc_change_requests_tl_rec;
      x_okc_change_requests_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_change_requests_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_change_requests_tl_rec,      -- IN
      l_okc_change_requests_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_change_requests_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_CHANGE_REQUESTS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          short_description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_change_requests_tl_rec.id,
          l_okc_change_requests_tl_rec.language,
          l_okc_change_requests_tl_rec.source_lang,
          l_okc_change_requests_tl_rec.sfwt_flag,
          l_okc_change_requests_tl_rec.name,
          l_okc_change_requests_tl_rec.short_description,
          l_okc_change_requests_tl_rec.created_by,
          l_okc_change_requests_tl_rec.creation_date,
          l_okc_change_requests_tl_rec.last_updated_by,
          l_okc_change_requests_tl_rec.last_update_date,
          l_okc_change_requests_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_change_requests_tl_rec := l_okc_change_requests_tl_rec;
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
  -- insert_row for:OKC_CHANGE_REQUESTS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type,
    x_crtv_rec                     OUT NOCOPY crtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crtv_rec                     crtv_rec_type;
    l_def_crtv_rec                 crtv_rec_type;
    l_crt_rec                      crt_rec_type;
    lx_crt_rec                     crt_rec_type;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
    lx_okc_change_requests_tl_rec  OkcChangeRequestsTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crtv_rec	IN crtv_rec_type
    ) RETURN crtv_rec_type IS
      l_crtv_rec	crtv_rec_type := p_crtv_rec;
    BEGIN
      l_crtv_rec.CREATION_DATE := SYSDATE;
      l_crtv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_crtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crtv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crtv_rec IN  crtv_rec_type,
      x_crtv_rec OUT NOCOPY crtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crtv_rec := p_crtv_rec;
      x_crtv_rec.OBJECT_VERSION_NUMBER := 1;
      x_crtv_rec.SFWT_FLAG := 'N';
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
    l_crtv_rec := null_out_defaults(p_crtv_rec);
    -- Set primary key value
    l_crtv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_crtv_rec,                        -- IN
      l_def_crtv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_crtv_rec := fill_who_columns(l_def_crtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_crtv_rec, l_crt_rec);
    migrate(l_def_crtv_rec, l_okc_change_requests_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crt_rec,
      lx_crt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crt_rec, l_def_crtv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_change_requests_tl_rec,
      lx_okc_change_requests_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_change_requests_tl_rec, l_def_crtv_rec);
    -- Set OUT values
    x_crtv_rec := l_def_crtv_rec;
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
  -- PL/SQL TBL insert_row for:CRTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type,
    x_crtv_tbl                     OUT NOCOPY crtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crtv_tbl.COUNT > 0) THEN
      i := p_crtv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crtv_rec                     => p_crtv_tbl(i),
          x_crtv_rec                     => x_crtv_tbl(i));
        EXIT WHEN (i = p_crtv_tbl.LAST);
        i := p_crtv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_CHANGE_REQUESTS_B --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crt_rec                      IN crt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_crt_rec IN crt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGE_REQUESTS_B
     WHERE ID = p_crt_rec.id
       AND OBJECT_VERSION_NUMBER in (p_crt_rec.object_version_number, OKC_API.G_MISS_NUM)
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_crt_rec IN crt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGE_REQUESTS_B
    WHERE ID = p_crt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CHANGE_REQUESTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CHANGE_REQUESTS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_crt_rec);
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
      OPEN lchk_csr(p_crt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_crt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_crt_rec.object_version_number THEN
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
  -- lock_row for:OKC_CHANGE_REQUESTS_TL --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_change_requests_tl_rec IN OkcChangeRequestsTlRecType) IS
    SELECT *
      FROM OKC_CHANGE_REQUESTS_TL
     WHERE ID = p_okc_change_requests_tl_rec.id
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
      OPEN lock_csr(p_okc_change_requests_tl_rec);
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
  -- lock_row for:OKC_CHANGE_REQUESTS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crt_rec                      crt_rec_type;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
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
    migrate(p_crtv_rec, l_crt_rec);
    migrate(p_crtv_rec, l_okc_change_requests_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crt_rec
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
      l_okc_change_requests_tl_rec
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
  -- PL/SQL TBL lock_row for:CRTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crtv_tbl.COUNT > 0) THEN
      i := p_crtv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crtv_rec                     => p_crtv_tbl(i));
        EXIT WHEN (i = p_crtv_tbl.LAST);
        i := p_crtv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_CHANGE_REQUESTS_B --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crt_rec                      IN crt_rec_type,
    x_crt_rec                      OUT NOCOPY crt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crt_rec                      crt_rec_type := p_crt_rec;
    l_def_crt_rec                  crt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crt_rec	IN crt_rec_type,
      x_crt_rec	OUT NOCOPY crt_rec_type
    ) RETURN VARCHAR2 IS
      l_crt_rec                      crt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crt_rec := p_crt_rec;
      -- Get current database values
      l_crt_rec := get_rec(p_crt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crt_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.id := l_crt_rec.id;
      END IF;
      IF (x_crt_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.chr_id := l_crt_rec.chr_id;
      END IF;
      IF (x_crt_rec.crs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.crs_code := l_crt_rec.crs_code;
      END IF;
      IF (x_crt_rec.user_id = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.user_id := l_crt_rec.user_id;
      END IF;
      IF (x_crt_rec.datetime_request = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_request := l_crt_rec.datetime_request;
      END IF;
      IF (x_crt_rec.crt_type = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.crt_type := l_crt_rec.crt_type;
      END IF;
      IF (x_crt_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.object_version_number := l_crt_rec.object_version_number;
      END IF;
      IF (x_crt_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.created_by := l_crt_rec.created_by;
      END IF;
      IF (x_crt_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.creation_date := l_crt_rec.creation_date;
      END IF;
      IF (x_crt_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.last_updated_by := l_crt_rec.last_updated_by;
      END IF;
      IF (x_crt_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.last_update_date := l_crt_rec.last_update_date;
      END IF;
      IF (x_crt_rec.datetime_effective = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_effective := l_crt_rec.datetime_effective;
      END IF;
      IF (x_crt_rec.extended_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.extended_yn := l_crt_rec.extended_yn;
      END IF;
      IF (x_crt_rec.authority = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.authority := l_crt_rec.authority;
      END IF;
      IF (x_crt_rec.signature_required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.signature_required_yn := l_crt_rec.signature_required_yn;
      END IF;
      IF (x_crt_rec.datetime_approved = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_approved := l_crt_rec.datetime_approved;
      END IF;
      IF (x_crt_rec.datetime_rejected = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_rejected := l_crt_rec.datetime_rejected;
      END IF;
      IF (x_crt_rec.datetime_ineffective = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_ineffective := l_crt_rec.datetime_ineffective;
      END IF;
      IF (x_crt_rec.version_contract = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.version_contract := l_crt_rec.version_contract;
      END IF;
      IF (x_crt_rec.applied_contract_version = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.applied_contract_version := l_crt_rec.applied_contract_version;
      END IF;
      IF (x_crt_rec.datetime_applied = OKC_API.G_MISS_DATE)
      THEN
        x_crt_rec.datetime_applied := l_crt_rec.datetime_applied;
      END IF;
      IF (x_crt_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_crt_rec.last_update_login := l_crt_rec.last_update_login;
      END IF;
      IF (x_crt_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute_category := l_crt_rec.attribute_category;
      END IF;
      IF (x_crt_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute1 := l_crt_rec.attribute1;
      END IF;
      IF (x_crt_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute2 := l_crt_rec.attribute2;
      END IF;
      IF (x_crt_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute3 := l_crt_rec.attribute3;
      END IF;
      IF (x_crt_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute4 := l_crt_rec.attribute4;
      END IF;
      IF (x_crt_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute5 := l_crt_rec.attribute5;
      END IF;
      IF (x_crt_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute6 := l_crt_rec.attribute6;
      END IF;
      IF (x_crt_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute7 := l_crt_rec.attribute7;
      END IF;
      IF (x_crt_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute8 := l_crt_rec.attribute8;
      END IF;
      IF (x_crt_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute9 := l_crt_rec.attribute9;
      END IF;
      IF (x_crt_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute10 := l_crt_rec.attribute10;
      END IF;
      IF (x_crt_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute11 := l_crt_rec.attribute11;
      END IF;
      IF (x_crt_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute12 := l_crt_rec.attribute12;
      END IF;
      IF (x_crt_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute13 := l_crt_rec.attribute13;
      END IF;
      IF (x_crt_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute14 := l_crt_rec.attribute14;
      END IF;
      IF (x_crt_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_crt_rec.attribute15 := l_crt_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_B --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crt_rec IN  crt_rec_type,
      x_crt_rec OUT NOCOPY crt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crt_rec := p_crt_rec;
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
      p_crt_rec,                         -- IN
      l_crt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crt_rec, l_def_crt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CHANGE_REQUESTS_B
    SET CHR_ID = l_def_crt_rec.chr_id,
        CRS_CODE = l_def_crt_rec.crs_code,
        USER_ID = l_def_crt_rec.user_id,
        DATETIME_REQUEST = l_def_crt_rec.datetime_request,
        CRT_TYPE = l_def_crt_rec.crt_type,
        OBJECT_VERSION_NUMBER = l_def_crt_rec.object_version_number,
        CREATED_BY = l_def_crt_rec.created_by,
        CREATION_DATE = l_def_crt_rec.creation_date,
        LAST_UPDATED_BY = l_def_crt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_crt_rec.last_update_date,
        DATETIME_EFFECTIVE = l_def_crt_rec.datetime_effective,
        EXTENDED_YN = l_def_crt_rec.extended_yn,
        AUTHORITY = l_def_crt_rec.authority,
        SIGNATURE_REQUIRED_YN = l_def_crt_rec.signature_required_yn,
        DATETIME_APPROVED = l_def_crt_rec.datetime_approved,
        DATETIME_REJECTED = l_def_crt_rec.datetime_rejected,
        DATETIME_INEFFECTIVE = l_def_crt_rec.datetime_ineffective,
        VERSION_CONTRACT = l_def_crt_rec.version_contract,
        APPLIED_CONTRACT_VERSION = l_def_crt_rec.applied_contract_version,
        DATETIME_APPLIED = l_def_crt_rec.datetime_applied,
        LAST_UPDATE_LOGIN = l_def_crt_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_crt_rec.attribute_category,
        ATTRIBUTE1 = l_def_crt_rec.attribute1,
        ATTRIBUTE2 = l_def_crt_rec.attribute2,
        ATTRIBUTE3 = l_def_crt_rec.attribute3,
        ATTRIBUTE4 = l_def_crt_rec.attribute4,
        ATTRIBUTE5 = l_def_crt_rec.attribute5,
        ATTRIBUTE6 = l_def_crt_rec.attribute6,
        ATTRIBUTE7 = l_def_crt_rec.attribute7,
        ATTRIBUTE8 = l_def_crt_rec.attribute8,
        ATTRIBUTE9 = l_def_crt_rec.attribute9,
        ATTRIBUTE10 = l_def_crt_rec.attribute10,
        ATTRIBUTE11 = l_def_crt_rec.attribute11,
        ATTRIBUTE12 = l_def_crt_rec.attribute12,
        ATTRIBUTE13 = l_def_crt_rec.attribute13,
        ATTRIBUTE14 = l_def_crt_rec.attribute14,
        ATTRIBUTE15 = l_def_crt_rec.attribute15
    WHERE ID = l_def_crt_rec.id;

    x_crt_rec := l_def_crt_rec;
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
  -- update_row for:OKC_CHANGE_REQUESTS_TL --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType,
    x_okc_change_requests_tl_rec   OUT NOCOPY OkcChangeRequestsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType := p_okc_change_requests_tl_rec;
    ldefokcchangerequeststlrec     OkcChangeRequestsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_change_requests_tl_rec	IN OkcChangeRequestsTlRecType,
      x_okc_change_requests_tl_rec	OUT NOCOPY OkcChangeRequestsTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_change_requests_tl_rec := p_okc_change_requests_tl_rec;
      -- Get current database values
      l_okc_change_requests_tl_rec := get_rec(p_okc_change_requests_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_change_requests_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_change_requests_tl_rec.id := l_okc_change_requests_tl_rec.id;
      END IF;
      IF (x_okc_change_requests_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_change_requests_tl_rec.language := l_okc_change_requests_tl_rec.language;
      END IF;
      IF (x_okc_change_requests_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_change_requests_tl_rec.source_lang := l_okc_change_requests_tl_rec.source_lang;
      END IF;
      IF (x_okc_change_requests_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_change_requests_tl_rec.sfwt_flag := l_okc_change_requests_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_change_requests_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_change_requests_tl_rec.name := l_okc_change_requests_tl_rec.name;
      END IF;
      IF (x_okc_change_requests_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_change_requests_tl_rec.short_description := l_okc_change_requests_tl_rec.short_description;
      END IF;
      IF (x_okc_change_requests_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_change_requests_tl_rec.created_by := l_okc_change_requests_tl_rec.created_by;
      END IF;
      IF (x_okc_change_requests_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_change_requests_tl_rec.creation_date := l_okc_change_requests_tl_rec.creation_date;
      END IF;
      IF (x_okc_change_requests_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_change_requests_tl_rec.last_updated_by := l_okc_change_requests_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_change_requests_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_change_requests_tl_rec.last_update_date := l_okc_change_requests_tl_rec.last_update_date;
      END IF;
      IF (x_okc_change_requests_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_change_requests_tl_rec.last_update_login := l_okc_change_requests_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_change_requests_tl_rec IN  OkcChangeRequestsTlRecType,
      x_okc_change_requests_tl_rec OUT NOCOPY OkcChangeRequestsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_change_requests_tl_rec := p_okc_change_requests_tl_rec;
      x_okc_change_requests_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_change_requests_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_change_requests_tl_rec,      -- IN
      l_okc_change_requests_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_change_requests_tl_rec, ldefokcchangerequeststlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CHANGE_REQUESTS_TL
    SET NAME = ldefokcchangerequeststlrec.name,
        SHORT_DESCRIPTION = ldefokcchangerequeststlrec.short_description,
        CREATED_BY = ldefokcchangerequeststlrec.created_by,
        CREATION_DATE = ldefokcchangerequeststlrec.creation_date,
        LAST_UPDATED_BY = ldefokcchangerequeststlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcchangerequeststlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcchangerequeststlrec.last_update_login,
        SOURCE_LANG = ldefokcchangerequeststlrec.source_lang
    WHERE ID = ldefokcchangerequeststlrec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);

    UPDATE  OKC_CHANGE_REQUESTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcchangerequeststlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_change_requests_tl_rec := ldefokcchangerequeststlrec;
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
  -- update_row for:OKC_CHANGE_REQUESTS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type,
    x_crtv_rec                     OUT NOCOPY crtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crtv_rec                     crtv_rec_type := p_crtv_rec;
    l_def_crtv_rec                 crtv_rec_type;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
    lx_okc_change_requests_tl_rec  OkcChangeRequestsTlRecType;
    l_crt_rec                      crt_rec_type;
    lx_crt_rec                     crt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crtv_rec	IN crtv_rec_type
    ) RETURN crtv_rec_type IS
      l_crtv_rec	crtv_rec_type := p_crtv_rec;
    BEGIN
      l_crtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crtv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crtv_rec	IN crtv_rec_type,
      x_crtv_rec	OUT NOCOPY crtv_rec_type
    ) RETURN VARCHAR2 IS
      l_crtv_rec                     crtv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crtv_rec := p_crtv_rec;
      -- Get current database values
      l_crtv_rec := get_rec(p_crtv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crtv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.id := l_crtv_rec.id;
      END IF;
      IF (x_crtv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.object_version_number := l_crtv_rec.object_version_number;
      END IF;
      IF (x_crtv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.sfwt_flag := l_crtv_rec.sfwt_flag;
      END IF;
      IF (x_crtv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.chr_id := l_crtv_rec.chr_id;
      END IF;
      IF (x_crtv_rec.crs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.crs_code := l_crtv_rec.crs_code;
      END IF;
      IF (x_crtv_rec.user_id = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.user_id := l_crtv_rec.user_id;
      END IF;
      IF (x_crtv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.name := l_crtv_rec.name;
      END IF;
      IF (x_crtv_rec.datetime_request = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_request := l_crtv_rec.datetime_request;
      END IF;
      IF (x_crtv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.short_description := l_crtv_rec.short_description;
      END IF;
      IF (x_crtv_rec.extended_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.extended_yn := l_crtv_rec.extended_yn;
      END IF;
      IF (x_crtv_rec.authority = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.authority := l_crtv_rec.authority;
      END IF;
      IF (x_crtv_rec.signature_required_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.signature_required_yn := l_crtv_rec.signature_required_yn;
      END IF;
      IF (x_crtv_rec.datetime_approved = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_approved := l_crtv_rec.datetime_approved;
      END IF;
      IF (x_crtv_rec.datetime_rejected = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_rejected := l_crtv_rec.datetime_rejected;
      END IF;
      IF (x_crtv_rec.datetime_effective = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_effective := l_crtv_rec.datetime_effective;
      END IF;
      IF (x_crtv_rec.datetime_ineffective = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_ineffective := l_crtv_rec.datetime_ineffective;
      END IF;
      IF (x_crtv_rec.datetime_applied = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.datetime_applied := l_crtv_rec.datetime_applied;
      END IF;
      IF (x_crtv_rec.version_contract = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.version_contract := l_crtv_rec.version_contract;
      END IF;
      IF (x_crtv_rec.applied_contract_version = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.applied_contract_version := l_crtv_rec.applied_contract_version;
      END IF;
      IF (x_crtv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute_category := l_crtv_rec.attribute_category;
      END IF;
      IF (x_crtv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute1 := l_crtv_rec.attribute1;
      END IF;
      IF (x_crtv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute2 := l_crtv_rec.attribute2;
      END IF;
      IF (x_crtv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute3 := l_crtv_rec.attribute3;
      END IF;
      IF (x_crtv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute4 := l_crtv_rec.attribute4;
      END IF;
      IF (x_crtv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute5 := l_crtv_rec.attribute5;
      END IF;
      IF (x_crtv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute6 := l_crtv_rec.attribute6;
      END IF;
      IF (x_crtv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute7 := l_crtv_rec.attribute7;
      END IF;
      IF (x_crtv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute8 := l_crtv_rec.attribute8;
      END IF;
      IF (x_crtv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute9 := l_crtv_rec.attribute9;
      END IF;
      IF (x_crtv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute10 := l_crtv_rec.attribute10;
      END IF;
      IF (x_crtv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute11 := l_crtv_rec.attribute11;
      END IF;
      IF (x_crtv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute12 := l_crtv_rec.attribute12;
      END IF;
      IF (x_crtv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute13 := l_crtv_rec.attribute13;
      END IF;
      IF (x_crtv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute14 := l_crtv_rec.attribute14;
      END IF;
      IF (x_crtv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.attribute15 := l_crtv_rec.attribute15;
      END IF;
      IF (x_crtv_rec.crt_type = OKC_API.G_MISS_CHAR)
      THEN
        x_crtv_rec.crt_type := l_crtv_rec.crt_type;
      END IF;
      IF (x_crtv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.created_by := l_crtv_rec.created_by;
      END IF;
      IF (x_crtv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.creation_date := l_crtv_rec.creation_date;
      END IF;
      IF (x_crtv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.last_updated_by := l_crtv_rec.last_updated_by;
      END IF;
      IF (x_crtv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_crtv_rec.last_update_date := l_crtv_rec.last_update_date;
      END IF;
      IF (x_crtv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_crtv_rec.last_update_login := l_crtv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_crtv_rec IN  crtv_rec_type,
      x_crtv_rec OUT NOCOPY crtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crtv_rec := p_crtv_rec;
      x_crtv_rec.OBJECT_VERSION_NUMBER := NVL(x_crtv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_crtv_rec,                        -- IN
      l_crtv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crtv_rec, l_def_crtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_crtv_rec := fill_who_columns(l_def_crtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_crtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_crtv_rec, l_okc_change_requests_tl_rec);
    migrate(l_def_crtv_rec, l_crt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_change_requests_tl_rec,
      lx_okc_change_requests_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_change_requests_tl_rec, l_def_crtv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crt_rec,
      lx_crt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crt_rec, l_def_crtv_rec);
    x_crtv_rec := l_def_crtv_rec;
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
  -- PL/SQL TBL update_row for:CRTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type,
    x_crtv_tbl                     OUT NOCOPY crtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crtv_tbl.COUNT > 0) THEN
      i := p_crtv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crtv_rec                     => p_crtv_tbl(i),
          x_crtv_rec                     => x_crtv_tbl(i));
        EXIT WHEN (i = p_crtv_tbl.LAST);
        i := p_crtv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_CHANGE_REQUESTS_B --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crt_rec                      IN crt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crt_rec                      crt_rec_type:= p_crt_rec;
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
    DELETE FROM OKC_CHANGE_REQUESTS_B
     WHERE ID = l_crt_rec.id;

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
  -- delete_row for:OKC_CHANGE_REQUESTS_TL --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_change_requests_tl_rec   IN OkcChangeRequestsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType:= p_okc_change_requests_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_REQUESTS_TL --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_change_requests_tl_rec IN  OkcChangeRequestsTlRecType,
      x_okc_change_requests_tl_rec OUT NOCOPY OkcChangeRequestsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_change_requests_tl_rec := p_okc_change_requests_tl_rec;
      x_okc_change_requests_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_change_requests_tl_rec,      -- IN
      l_okc_change_requests_tl_rec);     -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CHANGE_REQUESTS_TL
     WHERE ID = l_okc_change_requests_tl_rec.id;

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
  -- delete_row for:OKC_CHANGE_REQUESTS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crtv_rec                     crtv_rec_type := p_crtv_rec;
    l_okc_change_requests_tl_rec   OkcChangeRequestsTlRecType;
    l_crt_rec                      crt_rec_type;
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
    migrate(l_crtv_rec, l_okc_change_requests_tl_rec);
    migrate(l_crtv_rec, l_crt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_change_requests_tl_rec
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
      l_crt_rec
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
  -- PL/SQL TBL delete_row for:CRTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crtv_tbl.COUNT > 0) THEN
      i := p_crtv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crtv_rec                     => p_crtv_tbl(i));
        EXIT WHEN (i = p_crtv_tbl.LAST);
        i := p_crtv_tbl.NEXT(i);
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
END OKC_CRT_PVT;

/

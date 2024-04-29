--------------------------------------------------------
--  DDL for Package Body OKC_ATN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ATN_PVT" AS
/* $Header: OKCSATNB.pls 120.0 2005/05/25 22:59:09 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
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
  -- FUNCTION get_rec for: OKC_ARTICLE_TRANS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_atn_rec                      IN atn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN atn_rec_type IS
    CURSOR atn_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CAT_ID,
            RUL_ID,
            CLE_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Article_Trans
     WHERE okc_article_trans.id = p_id;
    l_atn_pk                       atn_pk_csr%ROWTYPE;
    l_atn_rec                      atn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN atn_pk_csr (p_atn_rec.id);
    FETCH atn_pk_csr INTO
              l_atn_rec.ID,
              l_atn_rec.CAT_ID,
              l_atn_rec.RUL_ID,
              l_atn_rec.CLE_ID,
              l_atn_rec.DNZ_CHR_ID,
              l_atn_rec.OBJECT_VERSION_NUMBER,
              l_atn_rec.CREATED_BY,
              l_atn_rec.CREATION_DATE,
              l_atn_rec.LAST_UPDATED_BY,
              l_atn_rec.LAST_UPDATE_DATE,
              l_atn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := atn_pk_csr%NOTFOUND;
    CLOSE atn_pk_csr;
    RETURN(l_atn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_atn_rec                      IN atn_rec_type
  ) RETURN atn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_atn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ARTICLE_TRANS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_atnv_rec                     IN atnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN atnv_rec_type IS
    CURSOR okc_atnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CAT_ID,
            CLE_ID,
            RUL_ID,
            DNZ_CHR_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Article_Trans_V
     WHERE okc_article_trans_v.id = p_id;
    l_okc_atnv_pk                  okc_atnv_pk_csr%ROWTYPE;
    l_atnv_rec                     atnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_atnv_pk_csr (p_atnv_rec.id);
    FETCH okc_atnv_pk_csr INTO
              l_atnv_rec.ID,
              l_atnv_rec.OBJECT_VERSION_NUMBER,
              l_atnv_rec.CAT_ID,
              l_atnv_rec.CLE_ID,
              l_atnv_rec.RUL_ID,
              l_atnv_rec.DNZ_CHR_ID,
              l_atnv_rec.CREATED_BY,
              l_atnv_rec.CREATION_DATE,
              l_atnv_rec.LAST_UPDATED_BY,
              l_atnv_rec.LAST_UPDATE_DATE,
              l_atnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_atnv_pk_csr%NOTFOUND;
    CLOSE okc_atnv_pk_csr;
    RETURN(l_atnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_atnv_rec                     IN atnv_rec_type
  ) RETURN atnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_atnv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ARTICLE_TRANS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_atnv_rec	IN atnv_rec_type
  ) RETURN atnv_rec_type IS
    l_atnv_rec	atnv_rec_type := p_atnv_rec;
  BEGIN
    IF (l_atnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.object_version_number := NULL;
    END IF;
    IF (l_atnv_rec.cat_id = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.cat_id := NULL;
    END IF;
    IF (l_atnv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.cle_id := NULL;
    END IF;
    IF (l_atnv_rec.rul_id = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.rul_id := NULL;
    END IF;
    IF (l_atnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_atnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.created_by := NULL;
    END IF;
    IF (l_atnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_atnv_rec.creation_date := NULL;
    END IF;
    IF (l_atnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_atnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_atnv_rec.last_update_date := NULL;
    END IF;
    IF (l_atnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_atnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_atnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/
-- Start of comments
--
-- Procedure Name  : validate_cat_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_cat_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_atnv_rec	  IN	ATNV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cat_csr is
  select '!'
  from OKC_K_ARTICLES_B
  where id = p_atnv_rec.cat_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_atnv_rec.cat_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_atnv_rec.cat_id is NULL) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CAT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_cat_csr;
  fetch l_cat_csr into l_dummy_var;
  close l_cat_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_cat_csr%ISOPEN then
      close l_cat_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_cat_id;

-- Start of comments
--
-- Procedure Name  : validate_cle_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_atnv_rec	  IN	ATNV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cle_csr is
  select '!'
  from OKC_K_LINES_B
  where id = p_atnv_rec.cle_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_atnv_rec.cle_id = OKC_API.G_MISS_NUM or p_atnv_rec.cle_id is NULL) then
    return;
  end if;
  open l_cle_csr;
  fetch l_cle_csr into l_dummy_var;
  close l_cle_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_cle_csr%ISOPEN then
      close l_cle_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_cle_id;

-- Start of comments
--
-- Procedure Name  : validate_rul_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_rul_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_atnv_rec	  IN	ATNV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_rul_csr is
  select '!'
  from OKC_RULES_B
  where id = p_atnv_rec.rul_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_atnv_rec.rul_id = OKC_API.G_MISS_NUM or p_atnv_rec.rul_id is NULL) then
    return;
  end if;
  open l_rul_csr;
  fetch l_rul_csr into l_dummy_var;
  close l_rul_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RUL_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_rul_csr%ISOPEN then
      close l_rul_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_rul_id;

-- Start of comments
--
-- Procedure Name  : validate_dnz_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_atnv_rec	  IN	atnv_rec_TYPE) is
l_dummy varchar2(1) := '?';
cursor Kt_Hr_Mj_Vr is
    select '!'
    from okc_k_headers_b
    where id = p_atnv_rec.dnz_chr_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_atnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_atnv_rec.dnz_chr_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;
  open Kt_Hr_Mj_Vr;
  fetch Kt_Hr_Mj_Vr into l_dummy;
  close Kt_Hr_Mj_Vr;
  if (l_dummy='?') then
  	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
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
end validate_dnz_chr_id;

/*+++++++++++++End of hand code +++++++++++++++++*/
  -------------------------------------------------
  -- Validate_Attributes for:OKC_ARTICLE_TRANS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_atnv_rec IN  atnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    IF p_atnv_rec.id = OKC_API.G_MISS_NUM OR
       p_atnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_atnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_atnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_atnv_rec.cat_id = OKC_API.G_MISS_NUM OR
          p_atnv_rec.cat_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cat_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_atnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_atnv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_cat_id(x_return_status => l_return_status,
                    p_atnv_rec      => p_atnv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_cle_id(x_return_status => l_return_status,
                    p_atnv_rec      => p_atnv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_rul_id(x_return_status => l_return_status,
                    p_atnv_rec      => p_atnv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    validate_dnz_chr_id(x_return_status => l_return_status,
                    p_atnv_rec      => p_atnv_rec);
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
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;
  END Validate_Attributes;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKC_ARTICLE_TRANS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_atnv_rec IN atnv_rec_type
--+++++++++++++++Start handcode +++++++++++++++++++++++++++++++++++
    ,p_mode IN varchar2 DEFAULT 'UPDATE'  -- or 'INSERT'
--+++++++++++++++End   handcode +++++++++++++++++++++++++++++++++++
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_atnv_rec IN atnv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_catv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              CHR_ID,
              CLE_ID,
              CAT_ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              SAV_SAE_ID,
              SAV_SAV_RELEASE,
              SBT_CODE,
              DNZ_CHR_ID,
              COMMENTS,
              FULLTEXT_YN,
              VARIATION_DESCRIPTION,
              NAME,
              TEXT,
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
              CAT_TYPE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_K_Articles_V
       WHERE okc_k_articles_v.id  = p_id;
      l_okc_catv_pk                  okc_catv_pk_csr%ROWTYPE;
      CURSOR okc_rulv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              OBJECT1_ID1,
              OBJECT2_ID1,
              OBJECT3_ID1,
              OBJECT1_ID2,
              OBJECT2_ID2,
              OBJECT3_ID2,
              JTOT_OBJECT1_CODE,
              JTOT_OBJECT2_CODE,
              JTOT_OBJECT3_CODE,
              DNZ_CHR_ID,
              RGP_ID,
              SAV_SAE_ID,
              SAV_SAV_RELEASE,
              PRIORITY,
              STD_TEMPLATE_YN,
              COMMENTS,
              WARN_YN,
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
              LAST_UPDATE_LOGIN,
              TEXT,
              RULE_INFORMATION_CATEGORY,
              RULE_INFORMATION1,
              RULE_INFORMATION2,
              RULE_INFORMATION3,
              RULE_INFORMATION4,
              RULE_INFORMATION5,
              RULE_INFORMATION6,
              RULE_INFORMATION7,
              RULE_INFORMATION8,
              RULE_INFORMATION9,
              RULE_INFORMATION10,
              RULE_INFORMATION11,
              RULE_INFORMATION12,
              RULE_INFORMATION13,
              RULE_INFORMATION14,
              RULE_INFORMATION15
        FROM Okc_Rules_V
       WHERE okc_rules_v.id       = p_id;
      l_okc_rulv_pk                  okc_rulv_pk_csr%ROWTYPE;
      CURSOR okc_clev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              CHR_ID,
              CLE_ID,
              LSE_ID,
              LINE_NUMBER,
              STS_CODE,
              DISPLAY_SEQUENCE,
              TRN_CODE,
              DNZ_CHR_ID,
              COMMENTS,
              ITEM_DESCRIPTION,
              HIDDEN_IND,
              PRICE_NEGOTIATED,
              PRICE_LEVEL_IND,
              INVOICE_LINE_LEVEL_IND,
              DPAS_RATING,
              BLOCK23TEXT,
              EXCEPTION_YN,
              TEMPLATE_USED,
              DATE_TERMINATED,
              NAME,
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
              PRICE_TYPE,
              UNIT_OF_MEASURE,
              CURRENCY_CODE,
              LAST_UPDATE_LOGIN
        FROM Okc_K_Lines_V
       WHERE okc_k_lines_v.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_atnv_rec.CAT_ID IS NOT NULL)
      THEN
        OPEN okc_catv_pk_csr(p_atnv_rec.CAT_ID);
        FETCH okc_catv_pk_csr INTO l_okc_catv_pk;
        l_row_notfound := okc_catv_pk_csr%NOTFOUND;
        CLOSE okc_catv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_atnv_rec.RUL_ID IS NOT NULL)
      THEN
        OPEN okc_rulv_pk_csr(p_atnv_rec.RUL_ID);
        FETCH okc_rulv_pk_csr INTO l_okc_rulv_pk;
        l_row_notfound := okc_rulv_pk_csr%NOTFOUND;
        CLOSE okc_rulv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RUL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_atnv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_atnv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
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
    l_return_status := validate_foreign_keys (p_atnv_rec);
    RETURN (l_return_status);
  END Validate_Record;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/

  cursor pk1_csr is
    select '!' from okc_article_trans_v
    where cat_id = p_atnv_rec.cat_id
      and cle_id = p_atnv_rec.cle_id;
  cursor pk2_csr is
    select '!' from okc_article_trans_v
    where cat_id = p_atnv_rec.cat_id
      and rul_id = p_atnv_rec.rul_id;
  l_dummy varchar2(1) := '?';
  BEGIN
      if (p_atnv_rec.cle_id IS NULL and p_atnv_rec.rul_id IS NULL)
      then
        OKC_API.SET_MESSAGE(g_app_name,g_required_value,g_col_name_token,'CLE_ID V RUL_ID');
           l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
      if ((p_atnv_rec.cle_id IS NOT NULL and p_atnv_rec.cle_id <> OKC_API.G_MISS_NUM) and
          (p_atnv_rec.rul_id IS NOT NULL and p_atnv_rec.rul_id <> OKC_API.G_MISS_NUM))
      then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID V RUL_ID');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
--
/*
    if (p_mode = 'INSERT') then
      if not(p_atnv_rec.cle_id is NULL or p_atnv_rec.cle_id = OKC_API.G_MISS_NUM)
	then
	  open pk1_csr;
	  fetch pk1_csr into l_dummy;
        close pk1_csr;
	  if (l_dummy = '?') then
          return OKC_API.G_RET_STS_SUCCESS;
	  end if;
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID, CLE_ID');
        return OKC_API.G_RET_STS_ERROR;
      end if;
      if not(p_atnv_rec.rul_id is NULL or p_atnv_rec.rul_id = OKC_API.G_MISS_NUM)
	then
	  open pk2_csr;
	  fetch pk2_csr into l_dummy;
        close pk2_csr;
	  if (l_dummy = '?') then
          return OKC_API.G_RET_STS_SUCCESS;
	  end if;
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID, RUL_ID');
        return OKC_API.G_RET_STS_ERROR;
      end if;
    end if;
*/
--
  RETURN (l_return_status);
  exception
    when G_EXCEPTION_HALT_VALIDATION then RETURN(OKC_API.G_RET_STS_ERROR);
    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      RETURN(OKC_API.G_RET_STS_UNEXP_ERROR);
  END Validate_Record;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN atnv_rec_type,
    p_to	IN OUT NOCOPY atn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cat_id := p_from.cat_id;
    p_to.rul_id := p_from.rul_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN atn_rec_type,
    p_to	IN OUT NOCOPY atnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cat_id := p_from.cat_id;
    p_to.rul_id := p_from.rul_id;
    p_to.cle_id := p_from.cle_id;
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
  ------------------------------------------
  -- validate_row for:OKC_ARTICLE_TRANS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_rec                     IN atnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atnv_rec                     atnv_rec_type := p_atnv_rec;
    l_atn_rec                      atn_rec_type;
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
    l_return_status := Validate_Attributes(l_atnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_atnv_rec);
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
  -- PL/SQL TBL validate_row for:ATNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_tbl                     IN atnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atnv_tbl.COUNT > 0) THEN
      i := p_atnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atnv_rec                     => p_atnv_tbl(i));
        EXIT WHEN (i = p_atnv_tbl.LAST);
        i := p_atnv_tbl.NEXT(i);
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
  --------------------------------------
  -- insert_row for:OKC_ARTICLE_TRANS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atn_rec                      IN atn_rec_type,
    x_atn_rec                      OUT NOCOPY atn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atn_rec                      atn_rec_type := p_atn_rec;
    l_def_atn_rec                  atn_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKC_ARTICLE_TRANS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_atn_rec IN  atn_rec_type,
      x_atn_rec OUT NOCOPY atn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atn_rec := p_atn_rec;
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
      p_atn_rec,                         -- IN
      l_atn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ARTICLE_TRANS(
        id,
        cat_id,
        rul_id,
        cle_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_atn_rec.id,
        l_atn_rec.cat_id,
        l_atn_rec.rul_id,
        l_atn_rec.cle_id,
        l_atn_rec.dnz_chr_id,
        l_atn_rec.object_version_number,
        l_atn_rec.created_by,
        l_atn_rec.creation_date,
        l_atn_rec.last_updated_by,
        l_atn_rec.last_update_date,
        l_atn_rec.last_update_login);
    -- Set OUT values
    x_atn_rec := l_atn_rec;
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
  -- insert_row for:OKC_ARTICLE_TRANS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_rec                     IN atnv_rec_type,
    x_atnv_rec                     OUT NOCOPY atnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atnv_rec                     atnv_rec_type;
    l_def_atnv_rec                 atnv_rec_type;
    l_atn_rec                      atn_rec_type;
    lx_atn_rec                     atn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_atnv_rec	IN atnv_rec_type
    ) RETURN atnv_rec_type IS
      l_atnv_rec	atnv_rec_type := p_atnv_rec;
    BEGIN
      l_atnv_rec.CREATION_DATE := SYSDATE;
      l_atnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_atnv_rec.LAST_UPDATE_DATE := l_atnv_rec.CREATION_DATE;
      l_atnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_atnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_atnv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKC_ARTICLE_TRANS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_atnv_rec IN  atnv_rec_type,
      x_atnv_rec OUT NOCOPY atnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atnv_rec := p_atnv_rec;
      x_atnv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_atnv_rec := null_out_defaults(p_atnv_rec);
    -- Set primary key value
    l_atnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_atnv_rec,                        -- IN
      l_def_atnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_atnv_rec := fill_who_columns(l_def_atnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_atnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*------------------------commented in favor of hand code-----------
    l_return_status := Validate_Record(l_def_atnv_rec);
------------------------commented in favor of hand code-----------*/
--++++++++++++++++++++++Hand code start+++++++++++++++++++++++++++++
    l_return_status := Validate_Record(l_def_atnv_rec,'INSERT');
--++++++++++++++++++++++Hand code   end+++++++++++++++++++++++++++++
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_atnv_rec, l_atn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atn_rec,
      lx_atn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_atn_rec, l_def_atnv_rec);
    -- Set OUT values
    x_atnv_rec := l_def_atnv_rec;
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
  -- PL/SQL TBL insert_row for:ATNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_tbl                     IN atnv_tbl_type,
    x_atnv_tbl                     OUT NOCOPY atnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atnv_tbl.COUNT > 0) THEN
      i := p_atnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atnv_rec                     => p_atnv_tbl(i),
          x_atnv_rec                     => x_atnv_tbl(i));
        EXIT WHEN (i = p_atnv_tbl.LAST);
        i := p_atnv_tbl.NEXT(i);
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
  ------------------------------------
  -- lock_row for:OKC_ARTICLE_TRANS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atn_rec                      IN atn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_atn_rec IN atn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ARTICLE_TRANS
     WHERE ID = p_atn_rec.id
       AND OBJECT_VERSION_NUMBER = p_atn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_atn_rec IN atn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ARTICLE_TRANS
    WHERE ID = p_atn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ARTICLE_TRANS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ARTICLE_TRANS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_atn_rec);
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
      OPEN lchk_csr(p_atn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_atn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_atn_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKC_ARTICLE_TRANS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_rec                     IN atnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atn_rec                      atn_rec_type;
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
    migrate(p_atnv_rec, l_atn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atn_rec
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
  -- PL/SQL TBL lock_row for:ATNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_tbl                     IN atnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atnv_tbl.COUNT > 0) THEN
      i := p_atnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atnv_rec                     => p_atnv_tbl(i));
        EXIT WHEN (i = p_atnv_tbl.LAST);
        i := p_atnv_tbl.NEXT(i);
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
  --------------------------------------
  -- update_row for:OKC_ARTICLE_TRANS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atn_rec                      IN atn_rec_type,
    x_atn_rec                      OUT NOCOPY atn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atn_rec                      atn_rec_type := p_atn_rec;
    l_def_atn_rec                  atn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_atn_rec	IN atn_rec_type,
      x_atn_rec	OUT NOCOPY atn_rec_type
    ) RETURN VARCHAR2 IS
      l_atn_rec                      atn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atn_rec := p_atn_rec;
      -- Get current database values
      l_atn_rec := get_rec(p_atn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_atn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.id := l_atn_rec.id;
      END IF;
      IF (x_atn_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.cat_id := l_atn_rec.cat_id;
      END IF;
      IF (x_atn_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.rul_id := l_atn_rec.rul_id;
      END IF;
      IF (x_atn_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.cle_id := l_atn_rec.cle_id;
      END IF;
      IF (x_atn_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.dnz_chr_id := l_atn_rec.dnz_chr_id;
      END IF;
      IF (x_atn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.object_version_number := l_atn_rec.object_version_number;
      END IF;
      IF (x_atn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.created_by := l_atn_rec.created_by;
      END IF;
      IF (x_atn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_atn_rec.creation_date := l_atn_rec.creation_date;
      END IF;
      IF (x_atn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.last_updated_by := l_atn_rec.last_updated_by;
      END IF;
      IF (x_atn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_atn_rec.last_update_date := l_atn_rec.last_update_date;
      END IF;
      IF (x_atn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_atn_rec.last_update_login := l_atn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_ARTICLE_TRANS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_atn_rec IN  atn_rec_type,
      x_atn_rec OUT NOCOPY atn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atn_rec := p_atn_rec;
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
      p_atn_rec,                         -- IN
      l_atn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_atn_rec, l_def_atn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ARTICLE_TRANS
    SET CAT_ID = l_def_atn_rec.cat_id,
        RUL_ID = l_def_atn_rec.rul_id,
        CLE_ID = l_def_atn_rec.cle_id,
        DNZ_CHR_ID = l_def_atn_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_atn_rec.object_version_number,
        CREATED_BY = l_def_atn_rec.created_by,
        CREATION_DATE = l_def_atn_rec.creation_date,
        LAST_UPDATED_BY = l_def_atn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_atn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_atn_rec.last_update_login
    WHERE ID = l_def_atn_rec.id;

    x_atn_rec := l_def_atn_rec;
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
  -- update_row for:OKC_ARTICLE_TRANS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_rec                     IN atnv_rec_type,
    x_atnv_rec                     OUT NOCOPY atnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atnv_rec                     atnv_rec_type := p_atnv_rec;
    l_def_atnv_rec                 atnv_rec_type;
    l_atn_rec                      atn_rec_type;
    lx_atn_rec                     atn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_atnv_rec	IN atnv_rec_type
    ) RETURN atnv_rec_type IS
      l_atnv_rec	atnv_rec_type := p_atnv_rec;
    BEGIN
      l_atnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_atnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_atnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_atnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_atnv_rec	IN atnv_rec_type,
      x_atnv_rec	OUT NOCOPY atnv_rec_type
    ) RETURN VARCHAR2 IS
      l_atnv_rec                     atnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atnv_rec := p_atnv_rec;
      -- Get current database values
      l_atnv_rec := get_rec(p_atnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_atnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.id := l_atnv_rec.id;
      END IF;
      IF (x_atnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.object_version_number := l_atnv_rec.object_version_number;
      END IF;
      IF (x_atnv_rec.cat_id = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.cat_id := l_atnv_rec.cat_id;
      END IF;
      IF (x_atnv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.cle_id := l_atnv_rec.cle_id;
      END IF;
      IF (x_atnv_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.rul_id := l_atnv_rec.rul_id;
      END IF;
      IF (x_atnv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.dnz_chr_id := l_atnv_rec.dnz_chr_id;
      END IF;
      IF (x_atnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.created_by := l_atnv_rec.created_by;
      END IF;
      IF (x_atnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_atnv_rec.creation_date := l_atnv_rec.creation_date;
      END IF;
      IF (x_atnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.last_updated_by := l_atnv_rec.last_updated_by;
      END IF;
      IF (x_atnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_atnv_rec.last_update_date := l_atnv_rec.last_update_date;
      END IF;
      IF (x_atnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_atnv_rec.last_update_login := l_atnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_ARTICLE_TRANS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_atnv_rec IN  atnv_rec_type,
      x_atnv_rec OUT NOCOPY atnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_atnv_rec := p_atnv_rec;
      x_atnv_rec.OBJECT_VERSION_NUMBER := NVL(x_atnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_atnv_rec,                        -- IN
      l_atnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_atnv_rec, l_def_atnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_atnv_rec := fill_who_columns(l_def_atnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_atnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_atnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_atnv_rec, l_atn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atn_rec,
      lx_atn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_atn_rec, l_def_atnv_rec);
    x_atnv_rec := l_def_atnv_rec;
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
  -- PL/SQL TBL update_row for:ATNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_tbl                     IN atnv_tbl_type,
    x_atnv_tbl                     OUT NOCOPY atnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atnv_tbl.COUNT > 0) THEN
      i := p_atnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atnv_rec                     => p_atnv_tbl(i),
          x_atnv_rec                     => x_atnv_tbl(i));
        EXIT WHEN (i = p_atnv_tbl.LAST);
        i := p_atnv_tbl.NEXT(i);
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
  --------------------------------------
  -- delete_row for:OKC_ARTICLE_TRANS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atn_rec                      IN atn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atn_rec                      atn_rec_type:= p_atn_rec;
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
    DELETE FROM OKC_ARTICLE_TRANS
     WHERE ID = l_atn_rec.id;

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
  -- delete_row for:OKC_ARTICLE_TRANS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_rec                     IN atnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_atnv_rec                     atnv_rec_type := p_atnv_rec;
    l_atn_rec                      atn_rec_type;
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
    migrate(l_atnv_rec, l_atn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_atn_rec
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
  -- PL/SQL TBL delete_row for:ATNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_atnv_tbl                     IN atnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atnv_tbl.COUNT > 0) THEN
      i := p_atnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atnv_rec                     => p_atnv_tbl(i));
        EXIT WHEN (i = p_atnv_tbl.LAST);
        i := p_atnv_tbl.NEXT(i);
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


--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS


  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_article_trans_h
  (
      major_version,
      id,
      cat_id,
      rul_id,
      cle_id,
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
      id,
      cat_id,
      rul_id,
      cle_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_article_trans
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
INSERT INTO okc_article_trans
  (
      id,
      cat_id,
      rul_id,
      cle_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      cat_id,
      rul_id,
      cle_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_article_trans_h
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

END OKC_ATN_PVT;

/

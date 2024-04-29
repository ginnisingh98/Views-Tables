--------------------------------------------------------
--  DDL for Package Body OKC_SAE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SAE_PVT" AS
/* $Header: OKCSSAEB.pls 120.2 2006/02/28 17:04:55 smallya noship $ */

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('500: Entered add_language', 2);
    END IF;

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_STD_ARTICLES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_STD_ARTICLES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_STD_ARTICLES_TL T SET (
        NAME) = (SELECT
                                  B.NAME
                                FROM OKC_STD_ARTICLES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_STD_ARTICLES_TL SUBB, OKC_STD_ARTICLES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
              ));
*/

    INSERT INTO OKC_STD_ARTICLES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
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
            B.NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_STD_ARTICLES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_STD_ARTICLES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  add_language ', 2);
   okc_debug.Reset_Indentation;
END IF;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ARTICLES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sae_rec                      IN sae_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sae_rec_type IS
    CURSOR sae_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SBT_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
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
      FROM Okc_Std_Articles_B
     WHERE okc_std_articles_b.id = p_id;
    l_sae_pk                       sae_pk_csr%ROWTYPE;
    l_sae_rec                      sae_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('600: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sae_pk_csr (p_sae_rec.id);
    FETCH sae_pk_csr INTO
              l_sae_rec.ID,
              l_sae_rec.SBT_CODE,
              l_sae_rec.OBJECT_VERSION_NUMBER,
              l_sae_rec.CREATED_BY,
              l_sae_rec.CREATION_DATE,
              l_sae_rec.LAST_UPDATED_BY,
              l_sae_rec.LAST_UPDATE_DATE,
              l_sae_rec.LAST_UPDATE_LOGIN,
              l_sae_rec.ATTRIBUTE_CATEGORY,
              l_sae_rec.ATTRIBUTE1,
              l_sae_rec.ATTRIBUTE2,
              l_sae_rec.ATTRIBUTE3,
              l_sae_rec.ATTRIBUTE4,
              l_sae_rec.ATTRIBUTE5,
              l_sae_rec.ATTRIBUTE6,
              l_sae_rec.ATTRIBUTE7,
              l_sae_rec.ATTRIBUTE8,
              l_sae_rec.ATTRIBUTE9,
              l_sae_rec.ATTRIBUTE10,
              l_sae_rec.ATTRIBUTE11,
              l_sae_rec.ATTRIBUTE12,
              l_sae_rec.ATTRIBUTE13,
              l_sae_rec.ATTRIBUTE14,
              l_sae_rec.ATTRIBUTE15;
    x_no_data_found := sae_pk_csr%NOTFOUND;
    CLOSE sae_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_sae_rec);

  END get_rec;

  FUNCTION get_rec (
    p_sae_rec                      IN sae_rec_type
  ) RETURN sae_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_sae_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ARTICLES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_std_articles_tl_rec_type IS
    CURSOR sae_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Articles_Tl
     WHERE okc_std_articles_tl.id = p_id
       AND okc_std_articles_tl.language = p_language;
    l_sae_pktl                     sae_pktl_csr%ROWTYPE;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('800: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sae_pktl_csr (p_okc_std_articles_tl_rec.id,
                       p_okc_std_articles_tl_rec.language);
    FETCH sae_pktl_csr INTO
              l_okc_std_articles_tl_rec.ID,
              l_okc_std_articles_tl_rec.LANGUAGE,
              l_okc_std_articles_tl_rec.SOURCE_LANG,
              l_okc_std_articles_tl_rec.SFWT_FLAG,
              l_okc_std_articles_tl_rec.NAME,
              l_okc_std_articles_tl_rec.CREATED_BY,
              l_okc_std_articles_tl_rec.CREATION_DATE,
              l_okc_std_articles_tl_rec.LAST_UPDATED_BY,
              l_okc_std_articles_tl_rec.LAST_UPDATE_DATE,
              l_okc_std_articles_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sae_pktl_csr%NOTFOUND;
    CLOSE sae_pktl_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_okc_std_articles_tl_rec);

  END get_rec;

  FUNCTION get_rec (
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type
  ) RETURN okc_std_articles_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_okc_std_articles_tl_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ARTICLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_saev_rec                     IN saev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN saev_rec_type IS
    CURSOR okc_saev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            SBT_CODE,
            NAME,
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
      FROM Okc_Std_Articles_V
     WHERE okc_std_articles_v.id = p_id;
    l_okc_saev_pk                  okc_saev_pk_csr%ROWTYPE;
    l_saev_rec                     saev_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('1000: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_saev_pk_csr (p_saev_rec.id);
    FETCH okc_saev_pk_csr INTO
              l_saev_rec.ID,
              l_saev_rec.OBJECT_VERSION_NUMBER,
              l_saev_rec.SFWT_FLAG,
              l_saev_rec.SBT_CODE,
              l_saev_rec.NAME,
              l_saev_rec.ATTRIBUTE_CATEGORY,
              l_saev_rec.ATTRIBUTE1,
              l_saev_rec.ATTRIBUTE2,
              l_saev_rec.ATTRIBUTE3,
              l_saev_rec.ATTRIBUTE4,
              l_saev_rec.ATTRIBUTE5,
              l_saev_rec.ATTRIBUTE6,
              l_saev_rec.ATTRIBUTE7,
              l_saev_rec.ATTRIBUTE8,
              l_saev_rec.ATTRIBUTE9,
              l_saev_rec.ATTRIBUTE10,
              l_saev_rec.ATTRIBUTE11,
              l_saev_rec.ATTRIBUTE12,
              l_saev_rec.ATTRIBUTE13,
              l_saev_rec.ATTRIBUTE14,
              l_saev_rec.ATTRIBUTE15,
              l_saev_rec.CREATED_BY,
              l_saev_rec.CREATION_DATE,
              l_saev_rec.LAST_UPDATED_BY,
              l_saev_rec.LAST_UPDATE_DATE,
              l_saev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_saev_pk_csr%NOTFOUND;
    CLOSE okc_saev_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('900: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_saev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_saev_rec                     IN saev_rec_type
  ) RETURN saev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_saev_rec, l_row_notfound));

  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_STD_ARTICLES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_saev_rec	IN saev_rec_type
  ) RETURN saev_rec_type IS
    l_saev_rec	saev_rec_type := p_saev_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('1200: Entered null_out_defaults', 2);
    END IF;

    IF (l_saev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_saev_rec.object_version_number := NULL;
    END IF;
    IF (l_saev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_saev_rec.sbt_code = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.sbt_code := NULL;
    END IF;
    IF (l_saev_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.name := NULL;
    END IF;
    IF (l_saev_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute_category := NULL;
    END IF;
    IF (l_saev_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute1 := NULL;
    END IF;
    IF (l_saev_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute2 := NULL;
    END IF;
    IF (l_saev_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute3 := NULL;
    END IF;
    IF (l_saev_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute4 := NULL;
    END IF;
    IF (l_saev_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute5 := NULL;
    END IF;
    IF (l_saev_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute6 := NULL;
    END IF;
    IF (l_saev_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute7 := NULL;
    END IF;
    IF (l_saev_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute8 := NULL;
    END IF;
    IF (l_saev_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute9 := NULL;
    END IF;
    IF (l_saev_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute10 := NULL;
    END IF;
    IF (l_saev_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute11 := NULL;
    END IF;
    IF (l_saev_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute12 := NULL;
    END IF;
    IF (l_saev_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute13 := NULL;
    END IF;
    IF (l_saev_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute14 := NULL;
    END IF;
    IF (l_saev_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_saev_rec.attribute15 := NULL;
    END IF;
    IF (l_saev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_saev_rec.created_by := NULL;
    END IF;
    IF (l_saev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_saev_rec.creation_date := NULL;
    END IF;
    IF (l_saev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_saev_rec.last_updated_by := NULL;
    END IF;
    IF (l_saev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_saev_rec.last_update_date := NULL;
    END IF;
    IF (l_saev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_saev_rec.last_update_login := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_saev_rec);

  END null_out_defaults;

/******************ADDED AFTER TAPI****************/
---------------------------------------------------------------------------
  -- Private Validation Procedures
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : Validate_no_k_attached
-- Description     : Called from forms
-- Business Rules  : Cannot delete an article whose release is being refernced by a contract
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_no_k_attached(p_saev_rec 	IN 	saev_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 Cursor l_ate_csr is select '1'
       from okc_k_articles_b ate
       where ate.sav_sae_id=p_saev_rec.id;

 dummy varchar2(1):='0';

 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('1300: Entered validate_no_k_attached', 2);
    END IF;

  x_return_status:=OKC_API.G_RET_STS_SUCCESS;

 --check that this article is not being referenced by any contract
    Open l_ate_csr;
    Fetch l_ate_csr into dummy;
    Close l_ate_csr;
    IF dummy='1' then
    	x_return_status:=OKC_API.G_RET_STS_ERROR;
   End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Leaving  validate_no_k_attached', 2);
       okc_debug.Reset_Indentation;
    END IF;
 EXCEPTION
    -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_no_k_attached:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_no_k_attached;

-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_id(p_saev_rec 	IN 	saev_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('1600: Entered validate_id', 2);
    END IF;

  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saev_rec.id is null) OR (p_saev_rec.id=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ID');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Leaving  validate_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
    null;
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_id:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_id;

-- Start of comments
-- Procedure Name  : validate_Object_Version_number
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Object_Version_Number(p_saev_rec 	IN 	saev_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('2000: Entered validate_Object_Version_Number', 2);
    END IF;

  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saev_rec.object_version_number is null) OR (p_saev_rec.object_version_number=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'OBJECT_VERSION_NUMBER');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Leaving  validate_Object_Version_Number', 2);
       okc_debug.Reset_Indentation;
    END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_Object_Version_Number:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
    null;
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Exiting validate_Object_Version_Number:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_object_version_number;



-- Start of comments
-- Procedure Name  : validate_sfwt_flag
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sfwt_flag(p_saev_rec 	IN 	saev_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is
 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('2400: Entered validate_sfwt_flag', 2);
    END IF;

 x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saev_rec.sfwt_flag is null) OR (p_saev_rec.sfwt_flag=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

 --check in domain
  If UPPER(p_saev_rec.sfwt_flag) not in('Y','N') then
    x_return_status:=OKC_API.G_RET_STS_ERROR;

    --set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');

    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

--check uppercase
 IF p_saev_rec.sfwt_flag <> UPPER(p_saev_rec.sfwt_flag) then
  	x_return_status:=OKC_API.G_RET_STS_ERROR;

	--set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NOT_UPPER,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');

      RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Leaving  validate_sfwt_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_sfwt_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
    null;
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2700: Exiting validate_sfwt_flag:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sfwt_flag;


-- Start of comments
-- Procedure Name  : validate_sbt_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sbt_code(p_saev_rec 	IN 	saev_rec_type,
                          x_return_status OUT  NOCOPY VARCHAR2) is

 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('2800: Entered validate_sbt_code', 2);
    END IF;

   x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saev_rec.sbt_code is null) OR (p_saev_rec.sbt_code=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SBT_CODE');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  --check within length limit
  If  (length(p_saev_rec.sbt_code)>30)  Then
     x_return_status:=OKC_API.G_RET_STS_ERROR;
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_LEN_CHK,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'SBT_CODE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


  -- Check if the value is valid code from lookup table for SUBJECT
  x_return_status:=OKC_UTIL.check_lookup_code('OKC_SUBJECT',p_saev_rec.sbt_code);
  If  (x_return_status=OKC_API.G_RET_STS_ERROR)  Then
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_INVALID_VALUE,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'SBT_CODE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  ELSIF (x_return_status=OKC_API.G_RET_STS_UNEXP_ERROR)  Then
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Leaving  validate_sbt_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_sbt_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
    null;
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting validate_sbt_code:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sbt_code;


-- Start of comments
-- Procedure Name  : validate_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_name(p_saev_rec 	IN 	saev_rec_type,
                        x_return_status OUT NOCOPY VARCHAR2) is

    cursor c1 is select id  from okc_std_articles_v where UPPER(name)=UPPER(p_saev_rec.name);
    l_id          number:=OKC_API.G_MISS_NUM;
 BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('3200: Entered validate_name', 2);
    END IF;

  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saev_rec.name is null) OR (p_saev_rec.name=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  'OKC_ARTICLE_NAME_REQUIRED');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  --check unique
    Open c1;
    Fetch c1 into l_id;
    close c1;

    IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_saev_rec.id,0)) THEN
      x_return_status:=OKC_API.G_RET_STS_ERROR;
      OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
	                  p_msg_name => 'OKC_ART_NAME_NOT_UNIQUE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Leaving  validate_name', 2);
       okc_debug.Reset_Indentation;
    END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_name:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
    null;
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Exiting validate_name:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_STD_ARTICLES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_saev_rec IN  saev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('3600: Entered Validate_Attributes', 2);
    END IF;

    validate_id(p_saev_rec,l_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_saev_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sfwt_flag(p_saev_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sbt_code(p_saev_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_name(p_saev_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Leaving  Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_return_status);

EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Exiting Validate_Attributes:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    --just come out with return status
        RETURN(l_return_status);
     -- other appropriate handlers
  When others then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Exiting Validate_Attributes:others Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    RETURN(l_return_status);

  END Validate_Attributes;
  /****************END ADDED AFTER TAPI**************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKC_STD_ARTICLES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_saev_rec IN saev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN saev_rec_type,
    p_to	OUT NOCOPY sae_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sbt_code := p_from.sbt_code;
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
    p_from	IN sae_rec_type,
    p_to	IN OUT NOCOPY saev_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sbt_code := p_from.sbt_code;
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
    p_from	IN saev_rec_type,
    p_to	OUT  NOCOPY okc_std_articles_tl_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;


  PROCEDURE migrate (
    p_from	IN okc_std_articles_tl_rec_type,
    p_to	IN OUT NOCOPY saev_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKC_STD_ARTICLES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saev_rec                     saev_rec_type := p_saev_rec;
    l_sae_rec                      sae_rec_type;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('4500: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_saev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_saev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4600: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4900: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:SAEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_tbl                     IN saev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('5000: Entered validate_row', 2);
    END IF;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saev_rec                     => p_saev_tbl(i));
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Leaving  validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- insert_row for:OKC_STD_ARTICLES_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_rec                      IN sae_rec_type,
    x_sae_rec                      OUT NOCOPY sae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sae_rec                      sae_rec_type := p_sae_rec;
    l_def_sae_rec                  sae_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sae_rec IN  sae_rec_type,
      x_sae_rec OUT NOCOPY sae_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_sae_rec := p_sae_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('5600: Entered insert_row', 2);
    END IF;

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
      p_sae_rec,                         -- IN
      l_sae_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_STD_ARTICLES_B(
        id,
        sbt_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
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
        l_sae_rec.id,
        l_sae_rec.sbt_code,
        l_sae_rec.object_version_number,
        l_sae_rec.created_by,
        l_sae_rec.creation_date,
        l_sae_rec.last_updated_by,
        l_sae_rec.last_update_date,
        l_sae_rec.last_update_login,
        l_sae_rec.attribute_category,
        l_sae_rec.attribute1,
        l_sae_rec.attribute2,
        l_sae_rec.attribute3,
        l_sae_rec.attribute4,
        l_sae_rec.attribute5,
        l_sae_rec.attribute6,
        l_sae_rec.attribute7,
        l_sae_rec.attribute8,
        l_sae_rec.attribute9,
        l_sae_rec.attribute10,
        l_sae_rec.attribute11,
        l_sae_rec.attribute12,
        l_sae_rec.attribute13,
        l_sae_rec.attribute14,
        l_sae_rec.attribute15);
    -- Set OUT values
    x_sae_rec := l_sae_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- insert_row for:OKC_STD_ARTICLES_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type,
    x_okc_std_articles_tl_rec      OUT NOCOPY okc_std_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type := p_okc_std_articles_tl_rec;
    ldefokcstdarticlestlrec        okc_std_articles_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_articles_tl_rec IN  okc_std_articles_tl_rec_type,
      x_okc_std_articles_tl_rec OUT NOCOPY okc_std_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_std_articles_tl_rec := p_okc_std_articles_tl_rec;
      --x_okc_std_articles_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_std_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      --x_okc_std_articles_tl_rec.SOURCE_LANG := USERENV('LANG');
      x_okc_std_articles_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('6200: Entered insert_row', 2);
    END IF;

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
      p_okc_std_articles_tl_rec,         -- IN
      l_okc_std_articles_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_std_articles_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_STD_ARTICLES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_std_articles_tl_rec.id,
          l_okc_std_articles_tl_rec.language,
          l_okc_std_articles_tl_rec.source_lang,
          l_okc_std_articles_tl_rec.sfwt_flag,
          l_okc_std_articles_tl_rec.name,
          l_okc_std_articles_tl_rec.created_by,
          l_okc_std_articles_tl_rec.creation_date,
          l_okc_std_articles_tl_rec.last_updated_by,
          l_okc_std_articles_tl_rec.last_update_date,
          l_okc_std_articles_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_std_articles_tl_rec := l_okc_std_articles_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- insert_row for:OKC_STD_ARTICLES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type,
    x_saev_rec                     OUT NOCOPY saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saev_rec                     saev_rec_type;
    l_def_saev_rec                 saev_rec_type;
    l_sae_rec                      sae_rec_type;
    lx_sae_rec                     sae_rec_type;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
    lx_okc_std_articles_tl_rec     okc_std_articles_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saev_rec	IN saev_rec_type
    ) RETURN saev_rec_type IS
      l_saev_rec	saev_rec_type := p_saev_rec;
    BEGIN

      l_saev_rec.CREATION_DATE := SYSDATE;
      l_saev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_saev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saev_rec.LAST_UPDATE_DATE := l_saev_rec.creation_date;
      l_saev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saev_rec);

    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_saev_rec IN  saev_rec_type,
      x_saev_rec OUT NOCOPY saev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_saev_rec := p_saev_rec;
      x_saev_rec.OBJECT_VERSION_NUMBER := 1;
      x_saev_rec.SFWT_FLAG := 'N';
      /****************ADDED AFTER TAPI**************/
      x_saev_rec.SFWT_FLAG :=UPPER(TRIM( x_saev_rec.SFWT_FLAG));
      x_saev_rec.NAME :=TRIM(p_saev_rec.NAME);
      x_saev_rec.SBT_CODE :=UPPER(TRIM( p_saev_rec.sbt_code));
      /****************END ADDED AFTER TAPI**************/

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('6900: Entered insert_row', 2);
    END IF;

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
    l_saev_rec := null_out_defaults(p_saev_rec);
    -- Set primary key value
    l_saev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_saev_rec,                        -- IN
      l_def_saev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saev_rec := fill_who_columns(l_def_saev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saev_rec, l_sae_rec);
    migrate(l_def_saev_rec, l_okc_std_articles_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sae_rec,
      lx_sae_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sae_rec, l_def_saev_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_articles_tl_rec,
      lx_okc_std_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_std_articles_tl_rec, l_def_saev_rec);
    -- Set OUT values
    x_saev_rec := l_def_saev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:SAEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_tbl                     IN saev_tbl_type,
    x_saev_tbl                     OUT NOCOPY saev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('7400: Entered insert_row', 2);
    END IF;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saev_rec                     => p_saev_tbl(i),
          x_saev_rec                     => x_saev_tbl(i));
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7500: Leaving  insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- lock_row for:OKC_STD_ARTICLES_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_rec                      IN sae_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sae_rec IN sae_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ARTICLES_B
     WHERE ID = p_sae_rec.id
       AND OBJECT_VERSION_NUMBER = p_sae_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sae_rec IN sae_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ARTICLES_B
    WHERE ID = p_sae_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_STD_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_STD_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('7900: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('8000: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_sae_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sae_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sae_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sae_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- lock_row for:OKC_STD_ARTICLES_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_std_articles_tl_rec IN okc_std_articles_tl_rec_type) IS
    SELECT *
      FROM OKC_STD_ARTICLES_TL
     WHERE ID = p_okc_std_articles_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('8700: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('8800: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_okc_std_articles_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- lock_row for:OKC_STD_ARTICLES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sae_rec                      sae_rec_type;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('9500: Entered lock_row', 2);
    END IF;

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
    migrate(p_saev_rec, l_sae_rec);
    migrate(p_saev_rec, l_okc_std_articles_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sae_rec
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
      l_okc_std_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:SAEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_tbl                     IN saev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('10000: Entered lock_row', 2);
    END IF;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saev_rec                     => p_saev_tbl(i));
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Leaving  lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- update_row for:OKC_STD_ARTICLES_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_rec                      IN sae_rec_type,
    x_sae_rec                      OUT NOCOPY sae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sae_rec                      sae_rec_type := p_sae_rec;
    l_def_sae_rec                  sae_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sae_rec	IN sae_rec_type,
      x_sae_rec	OUT NOCOPY sae_rec_type
    ) RETURN VARCHAR2 IS
      l_sae_rec                      sae_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('10500: Entered populate_new_record', 2);
    END IF;

      x_sae_rec := p_sae_rec;
      -- Get current database values
      l_sae_rec := get_rec(p_sae_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sae_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sae_rec.id := l_sae_rec.id;
      END IF;
      IF (x_sae_rec.sbt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.sbt_code := l_sae_rec.sbt_code;
      END IF;
      IF (x_sae_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sae_rec.object_version_number := l_sae_rec.object_version_number;
      END IF;
      IF (x_sae_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sae_rec.created_by := l_sae_rec.created_by;
      END IF;
      IF (x_sae_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sae_rec.creation_date := l_sae_rec.creation_date;
      END IF;
      IF (x_sae_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sae_rec.last_updated_by := l_sae_rec.last_updated_by;
      END IF;
      IF (x_sae_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sae_rec.last_update_date := l_sae_rec.last_update_date;
      END IF;
      IF (x_sae_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sae_rec.last_update_login := l_sae_rec.last_update_login;
      END IF;
      IF (x_sae_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute_category := l_sae_rec.attribute_category;
      END IF;
      IF (x_sae_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute1 := l_sae_rec.attribute1;
      END IF;
      IF (x_sae_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute2 := l_sae_rec.attribute2;
      END IF;
      IF (x_sae_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute3 := l_sae_rec.attribute3;
      END IF;
      IF (x_sae_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute4 := l_sae_rec.attribute4;
      END IF;
      IF (x_sae_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute5 := l_sae_rec.attribute5;
      END IF;
      IF (x_sae_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute6 := l_sae_rec.attribute6;
      END IF;
      IF (x_sae_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute7 := l_sae_rec.attribute7;
      END IF;
      IF (x_sae_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute8 := l_sae_rec.attribute8;
      END IF;
      IF (x_sae_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute9 := l_sae_rec.attribute9;
      END IF;
      IF (x_sae_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute10 := l_sae_rec.attribute10;
      END IF;
      IF (x_sae_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute11 := l_sae_rec.attribute11;
      END IF;
      IF (x_sae_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute12 := l_sae_rec.attribute12;
      END IF;
      IF (x_sae_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute13 := l_sae_rec.attribute13;
      END IF;
      IF (x_sae_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute14 := l_sae_rec.attribute14;
      END IF;
      IF (x_sae_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sae_rec.attribute15 := l_sae_rec.attribute15;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sae_rec IN  sae_rec_type,
      x_sae_rec OUT NOCOPY sae_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_sae_rec := p_sae_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('10700: Entered update_row', 2);
    END IF;

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
      p_sae_rec,                         -- IN
      l_sae_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sae_rec, l_def_sae_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ARTICLES_B
    SET SBT_CODE = l_def_sae_rec.sbt_code,
        OBJECT_VERSION_NUMBER = l_def_sae_rec.object_version_number,
        CREATED_BY = l_def_sae_rec.created_by,
        CREATION_DATE = l_def_sae_rec.creation_date,
        LAST_UPDATED_BY = l_def_sae_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sae_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sae_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_sae_rec.attribute_category,
        ATTRIBUTE1 = l_def_sae_rec.attribute1,
        ATTRIBUTE2 = l_def_sae_rec.attribute2,
        ATTRIBUTE3 = l_def_sae_rec.attribute3,
        ATTRIBUTE4 = l_def_sae_rec.attribute4,
        ATTRIBUTE5 = l_def_sae_rec.attribute5,
        ATTRIBUTE6 = l_def_sae_rec.attribute6,
        ATTRIBUTE7 = l_def_sae_rec.attribute7,
        ATTRIBUTE8 = l_def_sae_rec.attribute8,
        ATTRIBUTE9 = l_def_sae_rec.attribute9,
        ATTRIBUTE10 = l_def_sae_rec.attribute10,
        ATTRIBUTE11 = l_def_sae_rec.attribute11,
        ATTRIBUTE12 = l_def_sae_rec.attribute12,
        ATTRIBUTE13 = l_def_sae_rec.attribute13,
        ATTRIBUTE14 = l_def_sae_rec.attribute14,
        ATTRIBUTE15 = l_def_sae_rec.attribute15
    WHERE ID = l_def_sae_rec.id;

    x_sae_rec := l_def_sae_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('10800: Leaving  update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- update_row for:OKC_STD_ARTICLES_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type,
    x_okc_std_articles_tl_rec      OUT NOCOPY okc_std_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type := p_okc_std_articles_tl_rec;
    ldefokcstdarticlestlrec        okc_std_articles_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_std_articles_tl_rec	IN okc_std_articles_tl_rec_type,
      x_okc_std_articles_tl_rec	OUT NOCOPY okc_std_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('11200: Entered populate_new_record', 2);
    END IF;

      x_okc_std_articles_tl_rec := p_okc_std_articles_tl_rec;
      -- Get current database values
      l_okc_std_articles_tl_rec := get_rec(p_okc_std_articles_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_std_articles_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_articles_tl_rec.id := l_okc_std_articles_tl_rec.id;
      END IF;
      IF (x_okc_std_articles_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_articles_tl_rec.language := l_okc_std_articles_tl_rec.language;
      END IF;
      IF (x_okc_std_articles_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_articles_tl_rec.source_lang := l_okc_std_articles_tl_rec.source_lang;
      END IF;
      IF (x_okc_std_articles_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_articles_tl_rec.sfwt_flag := l_okc_std_articles_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_std_articles_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_articles_tl_rec.name := l_okc_std_articles_tl_rec.name;
      END IF;
      IF (x_okc_std_articles_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_articles_tl_rec.created_by := l_okc_std_articles_tl_rec.created_by;
      END IF;
      IF (x_okc_std_articles_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_std_articles_tl_rec.creation_date := l_okc_std_articles_tl_rec.creation_date;
      END IF;
      IF (x_okc_std_articles_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_articles_tl_rec.last_updated_by := l_okc_std_articles_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_std_articles_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_std_articles_tl_rec.last_update_date := l_okc_std_articles_tl_rec.last_update_date;
      END IF;
      IF (x_okc_std_articles_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_articles_tl_rec.last_update_login := l_okc_std_articles_tl_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11250: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_articles_tl_rec IN  okc_std_articles_tl_rec_type,
      x_okc_std_articles_tl_rec OUT NOCOPY okc_std_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_std_articles_tl_rec := p_okc_std_articles_tl_rec;
      x_okc_std_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      --x_okc_std_articles_tl_rec.LANGUAGE := USERENV('LANG');
      --x_okc_std_articles_tl_rec.SOURCE_LANG := USERENV('LANG');
      x_okc_std_articles_tl_rec.SOURCE_LANG :=okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('11400: Entered update_row', 2);
    END IF;

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
      p_okc_std_articles_tl_rec,         -- IN
      l_okc_std_articles_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_std_articles_tl_rec, ldefokcstdarticlestlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ARTICLES_TL
    SET NAME = ldefokcstdarticlestlrec.name,
        CREATED_BY = ldefokcstdarticlestlrec.created_by,
        CREATION_DATE = ldefokcstdarticlestlrec.creation_date,
        LAST_UPDATED_BY = ldefokcstdarticlestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcstdarticlestlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcstdarticlestlrec.last_update_login
--added after tapi
       ,SOURCE_LANG  =     ldefokcstdarticlestlrec.source_lang
--end added after tapi
    WHERE ID = ldefokcstdarticlestlrec.id
--commented after tapi replaced with following
      --AND SOURCE_LANG = USERENV('LANG');
      AND USERENV('LANG')  IN (SOURCE_LANG,LANGUAGE);


    UPDATE  OKC_STD_ARTICLES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcstdarticlestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_std_articles_tl_rec := ldefokcstdarticlestlrec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11800: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- update_row for:OKC_STD_ARTICLES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type,
    x_saev_rec                     OUT NOCOPY saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saev_rec                     saev_rec_type := p_saev_rec;
    l_def_saev_rec                 saev_rec_type;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
    lx_okc_std_articles_tl_rec     okc_std_articles_tl_rec_type;
    l_sae_rec                      sae_rec_type;
    lx_sae_rec                     sae_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saev_rec	IN saev_rec_type
    ) RETURN saev_rec_type IS
      l_saev_rec	saev_rec_type := p_saev_rec;
    BEGIN

      l_saev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saev_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_saev_rec	IN saev_rec_type,
      x_saev_rec	OUT NOCOPY saev_rec_type
    ) RETURN VARCHAR2 IS
      l_saev_rec                     saev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('12000: Entered populate_new_record', 2);
    END IF;

      x_saev_rec := p_saev_rec;
      -- Get current database values
      l_saev_rec := get_rec(p_saev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_saev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_saev_rec.id := l_saev_rec.id;
      END IF;
      IF (x_saev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_saev_rec.object_version_number := l_saev_rec.object_version_number;
      END IF;
      IF (x_saev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.sfwt_flag := l_saev_rec.sfwt_flag;
      END IF;
      IF (x_saev_rec.sbt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.sbt_code := l_saev_rec.sbt_code;
      END IF;
      IF (x_saev_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.name := l_saev_rec.name;
      END IF;
      IF (x_saev_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute_category := l_saev_rec.attribute_category;
      END IF;
      IF (x_saev_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute1 := l_saev_rec.attribute1;
      END IF;
      IF (x_saev_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute2 := l_saev_rec.attribute2;
      END IF;
      IF (x_saev_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute3 := l_saev_rec.attribute3;
      END IF;
      IF (x_saev_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute4 := l_saev_rec.attribute4;
      END IF;
      IF (x_saev_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute5 := l_saev_rec.attribute5;
      END IF;
      IF (x_saev_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute6 := l_saev_rec.attribute6;
      END IF;
      IF (x_saev_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute7 := l_saev_rec.attribute7;
      END IF;
      IF (x_saev_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute8 := l_saev_rec.attribute8;
      END IF;
      IF (x_saev_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute9 := l_saev_rec.attribute9;
      END IF;
      IF (x_saev_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute10 := l_saev_rec.attribute10;
      END IF;
      IF (x_saev_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute11 := l_saev_rec.attribute11;
      END IF;
      IF (x_saev_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute12 := l_saev_rec.attribute12;
      END IF;
      IF (x_saev_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute13 := l_saev_rec.attribute13;
      END IF;
      IF (x_saev_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute14 := l_saev_rec.attribute14;
      END IF;
      IF (x_saev_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_saev_rec.attribute15 := l_saev_rec.attribute15;
      END IF;
      IF (x_saev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_saev_rec.created_by := l_saev_rec.created_by;
      END IF;
      IF (x_saev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_saev_rec.creation_date := l_saev_rec.creation_date;
      END IF;
      IF (x_saev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_saev_rec.last_updated_by := l_saev_rec.last_updated_by;
      END IF;
      IF (x_saev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_saev_rec.last_update_date := l_saev_rec.last_update_date;
      END IF;
      IF (x_saev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_saev_rec.last_update_login := l_saev_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('12100: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_saev_rec IN  saev_rec_type,
      x_saev_rec OUT NOCOPY saev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_saev_rec := p_saev_rec;
      x_saev_rec.OBJECT_VERSION_NUMBER := NVL(x_saev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      /****************ADDED AFTER TAPI**************/
      x_saev_rec.SFWT_FLAG :=UPPER(TRIM( p_saev_rec.SFWT_FLAG));
      x_saev_rec.NAME :=TRIM(p_saev_rec.NAME);
      x_saev_rec.SBT_CODE :=UPPER(TRIM(p_saev_rec.sbt_code));
     /****************END ADDED AFTER TAPI**************/

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('12200: Entered update_row', 2);
    END IF;

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
      p_saev_rec,                        -- IN
      l_saev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_saev_rec, l_def_saev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saev_rec := fill_who_columns(l_def_saev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saev_rec, l_okc_std_articles_tl_rec);
    migrate(l_def_saev_rec, l_sae_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_articles_tl_rec,
      lx_okc_std_articles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_std_articles_tl_rec, l_def_saev_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sae_rec,
      lx_sae_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sae_rec, l_def_saev_rec);
    x_saev_rec := l_def_saev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


    IF (l_debug = 'Y') THEN
       okc_debug.log('12300: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:SAEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_tbl                     IN saev_tbl_type,
    x_saev_tbl                     OUT NOCOPY saev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('12700: Entered update_row', 2);
    END IF;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saev_rec                     => p_saev_tbl(i),
          x_saev_rec                     => x_saev_tbl(i));
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12800: Leaving  update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13100: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- delete_row for:OKC_STD_ARTICLES_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sae_rec                      IN sae_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sae_rec                      sae_rec_type:= p_sae_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('13200: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_STD_ARTICLES_B
     WHERE ID = l_sae_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('13300: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13600: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- delete_row for:OKC_STD_ARTICLES_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_articles_tl_rec      IN okc_std_articles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type:= p_okc_std_articles_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKC_STD_ARTICLES_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_articles_tl_rec IN  okc_std_articles_tl_rec_type,
      x_okc_std_articles_tl_rec OUT NOCOPY okc_std_articles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('13700: Entered Set_Attributes', 2);
    END IF;

      x_okc_std_articles_tl_rec := p_okc_std_articles_tl_rec;
      --x_okc_std_articles_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_std_articles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('13800: Entered delete_row', 2);
    END IF;

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
      p_okc_std_articles_tl_rec,         -- IN
      l_okc_std_articles_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_STD_ARTICLES_TL
     WHERE ID = l_okc_std_articles_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('13900: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------------
  -- delete_row for:OKC_STD_ARTICLES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saev_rec                     saev_rec_type := p_saev_rec;
    l_okc_std_articles_tl_rec      okc_std_articles_tl_rec_type;
    l_sae_rec                      sae_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('14300: Entered delete_row', 2);
    END IF;

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
    migrate(l_saev_rec, l_okc_std_articles_tl_rec);
    migrate(l_saev_rec, l_sae_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_articles_tl_rec
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
      l_sae_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('14400: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14500: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14600: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('14700: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:SAEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_tbl                     IN saev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_SAE_PVT');
       okc_debug.log('14800: Entered delete_row', 2);
    END IF;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saev_rec                     => p_saev_tbl(i));
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('14900: Leaving  delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('15100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('15200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

END OKC_SAE_PVT;

/

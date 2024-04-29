--------------------------------------------------------
--  DDL for Package Body OKC_SAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SAV_PVT" AS
/* $Header: OKCSSAVB.pls 120.0 2005/05/25 22:30:43 appldev noship $ */

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
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_STD_ART_VERSIONS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_STD_ART_VERSIONS_B B
         WHERE B.SAE_ID = T.SAE_ID
           AND B.SAV_RELEASE = T.SAV_RELEASE
        );

    UPDATE OKC_STD_ART_VERSIONS_TL T SET (
        TEXT,
        SHORT_DESCRIPTION) = (SELECT
                                  B.TEXT,
                                  B.SHORT_DESCRIPTION
                                FROM OKC_STD_ART_VERSIONS_TL B
                               WHERE B.SAE_ID = T.SAE_ID
                                 AND B.SAV_RELEASE = T.SAV_RELEASE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.SAE_ID,
              T.SAV_RELEASE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.SAE_ID,
                  SUBT.SAV_RELEASE,
                  SUBT.LANGUAGE
                FROM OKC_STD_ART_VERSIONS_TL SUBB, OKC_STD_ART_VERSIONS_TL SUBT
               WHERE SUBB.SAE_ID = SUBT.SAE_ID
                 AND SUBB.SAV_RELEASE = SUBT.SAV_RELEASE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND
                     --commented after tapi
                     --(SUBB.TEXT <> SUBT.TEXT
                      --OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                    -- added as per alex's solution
                     OR ((SUBB.TEXT is not NULL AND SUBT.TEXT is not NULL)
                         AND (DBMS_LOB.COMPARE(SUBB.TEXT,SUBT.TEXT)<>0))
                    --alex--
                     OR (SUBB.TEXT IS NULL AND SUBT.TEXT IS NOT NULL)
                      OR (SUBB.TEXT IS NOT NULL AND SUBT.TEXT IS NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)

              ));
*/

    INSERT INTO OKC_STD_ART_VERSIONS_TL (
        SAE_ID,
        SAV_RELEASE,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        TEXT,
        SHORT_DESCRIPTION,
        LAST_UPDATE_LOGIN)
      SELECT
            B.SAE_ID,
            B.SAV_RELEASE,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.OBJECT_VERSION_NUMBER,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.TEXT,
            B.SHORT_DESCRIPTION,
            B.LAST_UPDATE_LOGIN
        FROM OKC_STD_ART_VERSIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_STD_ART_VERSIONS_TL T
                     WHERE T.SAE_ID = B.SAE_ID
                       AND T.SAV_RELEASE = B.SAV_RELEASE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ART_VERSIONS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sav_rec                      IN sav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sav_rec_type IS
    CURSOR sav_pk_csr (p_sae_id             IN NUMBER,
                       p_sav_release        IN VARCHAR2) IS
    SELECT
            SAV_RELEASE,
            SAE_ID,
            DATE_ACTIVE,
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
      FROM Okc_Std_Art_Versions_B
     WHERE okc_std_art_versions_b.sae_id = p_sae_id
       AND okc_std_art_versions_b.sav_release = p_sav_release;
    l_sav_pk                       sav_pk_csr%ROWTYPE;
    l_sav_rec                      sav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sav_pk_csr (p_sav_rec.sae_id,
                     p_sav_rec.sav_release);
    FETCH sav_pk_csr INTO
              l_sav_rec.SAV_RELEASE,
              l_sav_rec.SAE_ID,
              l_sav_rec.DATE_ACTIVE,
              l_sav_rec.OBJECT_VERSION_NUMBER,
              l_sav_rec.CREATED_BY,
              l_sav_rec.CREATION_DATE,
              l_sav_rec.LAST_UPDATED_BY,
              l_sav_rec.LAST_UPDATE_DATE,
              l_sav_rec.LAST_UPDATE_LOGIN,
              l_sav_rec.ATTRIBUTE_CATEGORY,
              l_sav_rec.ATTRIBUTE1,
              l_sav_rec.ATTRIBUTE2,
              l_sav_rec.ATTRIBUTE3,
              l_sav_rec.ATTRIBUTE4,
              l_sav_rec.ATTRIBUTE5,
              l_sav_rec.ATTRIBUTE6,
              l_sav_rec.ATTRIBUTE7,
              l_sav_rec.ATTRIBUTE8,
              l_sav_rec.ATTRIBUTE9,
              l_sav_rec.ATTRIBUTE10,
              l_sav_rec.ATTRIBUTE11,
              l_sav_rec.ATTRIBUTE12,
              l_sav_rec.ATTRIBUTE13,
              l_sav_rec.ATTRIBUTE14,
              l_sav_rec.ATTRIBUTE15;
    x_no_data_found := sav_pk_csr%NOTFOUND;
    CLOSE sav_pk_csr;
    RETURN(l_sav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sav_rec                      IN sav_rec_type
  ) RETURN sav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sav_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ART_VERSIONS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OkcStdArtVersionsTlRecType IS
    CURSOR sav_pktl_csr (p_sae_id             IN NUMBER,
                         p_sav_release        IN VARCHAR2,
                         p_language           IN VARCHAR2) IS
    SELECT
            SAE_ID,
            SAV_RELEASE,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            TEXT,
            SHORT_DESCRIPTION,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Art_Versions_Tl
     WHERE okc_std_art_versions_tl.sae_id = p_sae_id
       AND okc_std_art_versions_tl.sav_release = p_sav_release
       AND okc_std_art_versions_tl.language = p_language;
    l_sav_pktl                     sav_pktl_csr%ROWTYPE;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sav_pktl_csr (p_okc_std_art_versions_tl_rec.sae_id,
                       p_okc_std_art_versions_tl_rec.sav_release,
                       p_okc_std_art_versions_tl_rec.language);
    FETCH sav_pktl_csr INTO
              l_okc_std_art_versions_tl_rec.SAE_ID,
              l_okc_std_art_versions_tl_rec.SAV_RELEASE,
              l_okc_std_art_versions_tl_rec.LANGUAGE,
              l_okc_std_art_versions_tl_rec.SOURCE_LANG,
              l_okc_std_art_versions_tl_rec.SFWT_FLAG,
              l_okc_std_art_versions_tl_rec.OBJECT_VERSION_NUMBER,
              l_okc_std_art_versions_tl_rec.CREATED_BY,
              l_okc_std_art_versions_tl_rec.CREATION_DATE,
              l_okc_std_art_versions_tl_rec.LAST_UPDATED_BY,
              l_okc_std_art_versions_tl_rec.LAST_UPDATE_DATE,
              l_okc_std_art_versions_tl_rec.TEXT,
              l_okc_std_art_versions_tl_rec.SHORT_DESCRIPTION,
              l_okc_std_art_versions_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sav_pktl_csr%NOTFOUND;
    CLOSE sav_pktl_csr;
    RETURN(l_okc_std_art_versions_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType
  ) RETURN OkcStdArtVersionsTlRecType IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_std_art_versions_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ART_VERSIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_savv_rec                     IN savv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN savv_rec_type IS
    CURSOR okc_savv_pk_csr (p_sae_id             IN NUMBER,
                            p_sav_release        IN VARCHAR2) IS
    SELECT
            SAE_ID,
            SAV_RELEASE,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            DATE_ACTIVE,
            TEXT,
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
      FROM Okc_Std_Art_Versions_V
     WHERE okc_std_art_versions_v.sae_id = p_sae_id
       AND okc_std_art_versions_v.sav_release = p_sav_release;
    l_okc_savv_pk                  okc_savv_pk_csr%ROWTYPE;
    l_savv_rec                     savv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_savv_pk_csr (p_savv_rec.sae_id,
                          p_savv_rec.sav_release);
    FETCH okc_savv_pk_csr INTO
              l_savv_rec.SAE_ID,
              l_savv_rec.SAV_RELEASE,
              l_savv_rec.OBJECT_VERSION_NUMBER,
              l_savv_rec.SFWT_FLAG,
              l_savv_rec.DATE_ACTIVE,
              l_savv_rec.TEXT,
              l_savv_rec.SHORT_DESCRIPTION,
              l_savv_rec.ATTRIBUTE_CATEGORY,
              l_savv_rec.ATTRIBUTE1,
              l_savv_rec.ATTRIBUTE2,
              l_savv_rec.ATTRIBUTE3,
              l_savv_rec.ATTRIBUTE4,
              l_savv_rec.ATTRIBUTE5,
              l_savv_rec.ATTRIBUTE6,
              l_savv_rec.ATTRIBUTE7,
              l_savv_rec.ATTRIBUTE8,
              l_savv_rec.ATTRIBUTE9,
              l_savv_rec.ATTRIBUTE10,
              l_savv_rec.ATTRIBUTE11,
              l_savv_rec.ATTRIBUTE12,
              l_savv_rec.ATTRIBUTE13,
              l_savv_rec.ATTRIBUTE14,
              l_savv_rec.ATTRIBUTE15,
              l_savv_rec.CREATED_BY,
              l_savv_rec.CREATION_DATE,
              l_savv_rec.LAST_UPDATED_BY,
              l_savv_rec.LAST_UPDATE_DATE,
              l_savv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_savv_pk_csr%NOTFOUND;
    CLOSE okc_savv_pk_csr;
    RETURN(l_savv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_savv_rec                     IN savv_rec_type
  ) RETURN savv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_savv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_STD_ART_VERSIONS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_savv_rec	IN savv_rec_type
  ) RETURN savv_rec_type IS
    l_savv_rec	savv_rec_type := p_savv_rec;
  BEGIN
    IF (l_savv_rec.sae_id = OKC_API.G_MISS_NUM) THEN
      l_savv_rec.sae_id := NULL;
    END IF;
    IF (l_savv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_savv_rec.object_version_number := NULL;
    END IF;
    IF (l_savv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_savv_rec.date_active = OKC_API.G_MISS_DATE) THEN
      l_savv_rec.date_active := NULL;
    END IF;
    --alex solun after tapi
    /*IF (l_savv_rec.text = OKC_API.G_MISS_DATE) THEN
      l_savv_rec.text := NULL;
    END IF;*/
    IF (l_savv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.short_description := NULL;
    END IF;
    IF (l_savv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute_category := NULL;
    END IF;
    IF (l_savv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute1 := NULL;
    END IF;
    IF (l_savv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute2 := NULL;
    END IF;
    IF (l_savv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute3 := NULL;
    END IF;
    IF (l_savv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute4 := NULL;
    END IF;
    IF (l_savv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute5 := NULL;
    END IF;
    IF (l_savv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute6 := NULL;
    END IF;
    IF (l_savv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute7 := NULL;
    END IF;
    IF (l_savv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute8 := NULL;
    END IF;
    IF (l_savv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute9 := NULL;
    END IF;
    IF (l_savv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute10 := NULL;
    END IF;
    IF (l_savv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute11 := NULL;
    END IF;
    IF (l_savv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute12 := NULL;
    END IF;
    IF (l_savv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute13 := NULL;
    END IF;
    IF (l_savv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute14 := NULL;
    END IF;
    IF (l_savv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_savv_rec.attribute15 := NULL;
    END IF;
    IF (l_savv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_savv_rec.created_by := NULL;
    END IF;
    IF (l_savv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_savv_rec.creation_date := NULL;
    END IF;
    IF (l_savv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_savv_rec.last_updated_by := NULL;
    END IF;
    IF (l_savv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_savv_rec.last_update_date := NULL;
    END IF;
    IF (l_savv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_savv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_savv_rec);
  END null_out_defaults;

/******************ADDED AFTER TAPI****************/
---------------------------------------------------------------------------
  -- Private Validation Procedures
  ---------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : Validate_no_k_attached
-- Description     : Called from delete_row,validate_updatable,forms -Used when Update_row is called.
-- Business Rules  : date_active,text not updatable if release being referenced in a contract
--                   A release cannot be deleted if being refernced by a contract
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_no_k_attached(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 Cursor l_ate_csr is select '1'
       from okc_k_articles_v ate
       where ate.sav_sav_release=p_savv_rec.sav_release and ate.sav_sae_id=p_savv_rec.sae_id;

 dummy varchar2(1):='0';

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;

 --check that this release is not being referenced by any contract
    Open l_ate_csr;
    Fetch l_ate_csr into dummy;
    Close l_ate_csr;
    IF dummy='1' then
    	x_return_status:=OKC_API.G_RET_STS_ERROR;
   End If;

 EXCEPTION
    -- other appropriate handlers
  When others then
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
-- Procedure Name  : validate_latest
-- Description     : Called from validate_updatable,forms -Used Only when Update_row is called.
-- Business Rules  : date_active,text not updatable if not latest release
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_latest(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 Cursor l_sav_csr is select sav_release
       from okc_std_art_versions_v sav
       where sav.sae_id=p_savv_rec.sae_id order by date_active desc, creation_date DESC ;

 l_sav_release    OKC_STD_ART_VERSIONS_B.SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR;

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;

   --check that this release is the latest version else it cannot be modified
    Open l_sav_csr;
    Fetch l_sav_csr into l_sav_release;
    Close l_sav_csr;
    IF (l_sav_release<>OKC_API.G_MISS_CHAR) and (l_sav_release<>p_savv_rec.sav_release) then
    	x_return_status:=OKC_API.G_RET_STS_ERROR;
    End If;

 EXCEPTION
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_latest;

-- Start of comments
-- Procedure Name  : validate_Updatable
-- Description     : Used Only when Update_row is called.
-- Business Rules  : date_active,text not updatable if not latest version or referenced version
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_updatable(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check if date_active or text can be updated
  IF (p_savv_rec.date_active<>OKC_API.G_MISS_DATE) OR (p_savv_rec.text is not NULL) THEN

	 --check that this release is not being referenced by any contract
  	validate_no_k_attached(p_savv_rec,x_return_status);
  	If (x_return_status=OKC_API.G_RET_STS_ERROR) then
    		--set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        	    p_msg_name     =>   G_ATE_REFERENCES);
    	       RAISE G_EXCEPTION_HALT_VALIDATION;
 	 End If;

   	 --check that this release is the latest version else it cannot be modified
	validate_latest(p_savv_rec,x_return_status);
  	If (x_return_status=OKC_API.G_RET_STS_ERROR) then
    		--set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        	    p_msg_name     	   => G_NOT_LATEST);
    		RAISE G_EXCEPTION_HALT_VALIDATION;
    	End If;
   END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_updatable;

-- Procedure Name  : Valid_Date_For_Ins_Upd
-- Description     : Called from insert_row,validate_updatable
-- Business Rules  : date_active cannot be less than sysdate or less than latest release's date_active
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure Valid_Date_For_Ins_Upd(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) IS

  Cursor l_date_csr is select max(date_active)
    from okc_std_art_versions_v
    where sae_id = p_savv_rec.sae_id and sav_release<>p_savv_rec.sav_release;
   l_date           OKC_STD_ART_VERSIONS_V.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE;

 Begin

/* commented as result of bug launched 1162366 - which doesnot want to treat this as error
 -- check that it is not before today
  If  trunc(p_savv_rec.date_active)<trunc(sysdate) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_LESS_THAN_SYSDATE);
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
*/

  -- check that it is later than the date active of last release
  Open l_date_csr;
  Fetch l_date_csr into l_date;
  Close l_date_csr;
  IF l_date<>OKC_API.G_MISS_DATE then
       IF (p_savv_rec.date_active < l_date) then
         x_return_status:=OKC_API.G_RET_STS_ERROR;
    	--set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     =>  G_LESS_THAN_RELEASE_DATE);
    	RAISE G_EXCEPTION_HALT_VALIDATION;
      End If;
  End If;


 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;

    -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Valid_Date_For_Ins_Upd;


-- Start of comments
-- Procedure Name  : validate_Sav_Release
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sav_release(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_savv_rec.sav_release is null) OR (p_savv_rec.sav_release=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Article Release');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
 /*--check uppercase
 IF p_savv_rec.sav_release <> UPPER(p_savv_rec.sav_release) then
  	x_return_status:=OKC_API.G_RET_STS_ERROR;

	--set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NOT_UPPER,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAV_RELEASE');

      RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;*/

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sav_release;

-- Start of comments
-- Procedure Name  : validate_sae_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sae_id(p_savv_rec 	IN 	savv_rec_type,
                          x_return_status OUT  NOCOPY VARCHAR2) is
  CURSOR l_sae_id_csr IS
   SELECT '1'
   FROM   okc_std_articles_b  sae
   	    WHERE  sae.id = p_savv_rec.sae_id;
  l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_savv_rec.sae_id is null) OR (p_savv_rec.sae_id=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


   --check FK Relation with okc_std_articles_v.sae_id
   OPEN l_sae_id_csr;
   FETCH l_sae_id_csr into l_dummy_var;
   CLOSE l_sae_id_csr;
   IF (l_dummy_var<>'1') Then

	--Corresponding Column value not found
  	x_return_status:= OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID',
                        p_token2       =>  G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKC_STD_ARTICLES_V');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sae_id;


-- Start of comments
-- Procedure Name  : validate_Object_Version_number
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Object_Version_Number(p_savv_rec 	IN 	savv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_savv_rec.object_version_number is null) OR (p_savv_rec.object_version_number=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'OBJECT_VERSION_NUMBER');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
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
procedure validate_sfwt_flag(p_savv_rec 	IN 	savv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is
 BEGIN
 x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_savv_rec.sfwt_flag is null) OR (p_savv_rec.sfwt_flag=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

 --check in domain
  If UPPER(p_savv_rec.sfwt_flag) not in('Y','N') then
    x_return_status:=OKC_API.G_RET_STS_ERROR;

    --set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');

    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

--check uppercase
 IF p_savv_rec.sfwt_flag <> UPPER(p_savv_rec.sfwt_flag) then
  	x_return_status:=OKC_API.G_RET_STS_ERROR;

	--set error message in message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NOT_UPPER,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SFWT_FLAG');

      RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
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
-- Procedure Name  : validate_date_active
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_date_active(p_savv_rec 	IN 	savv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is

 Cursor l_csr is select date_active,sav_release
    from okc_std_art_versions_v
    where sae_id = p_savv_rec.sae_id and sav_release=p_savv_rec.sav_release;

 l_date           OKC_STD_ART_VERSIONS_V.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE;
 l_sav_release    OKC_STD_ART_VERSIONS_V.SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR;

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_savv_rec.date_active is null) OR (p_savv_rec.date_active=OKC_API.G_MISS_DATE) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Start Date');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Open l_csr;
  Fetch l_csr into l_date,l_sav_release;
  Close l_csr;

  IF (l_sav_release=OKC_API.G_MISS_CHAR)
       OR (l_sav_release=p_savv_rec.sav_release and (l_date<>p_savv_rec.date_active) ) then

         Valid_Date_For_Ins_Upd(p_savv_rec,x_return_status);
         If (x_return_status<>OKC_API.G_RET_STS_SUCCESS) then
             RAISE G_EXCEPTION_HALT_VALIDATION;
         end if;
  End If;


 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status

    null;
     -- other appropriate handlers
  When others then

      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_date_active;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_STD_ART_VERSIONS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_savv_rec IN  savv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    validate_sav_release(p_savv_rec,l_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

   validate_sae_id(p_savv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_savv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_sfwt_flag(p_savv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_date_active(p_savv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    RETURN(l_return_status);
EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
        RETURN(l_return_status);
     -- other appropriate handlers
  When others then
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
  ------------------------------------------------
  -- Validate_Record for:OKC_STD_ART_VERSIONS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_savv_rec IN savv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN savv_rec_type,
    p_to	OUT NOCOPY sav_rec_type
  ) IS
  BEGIN
    p_to.sav_release := p_from.sav_release;
    p_to.sae_id := p_from.sae_id;
    p_to.date_active := p_from.date_active;
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
    p_from	IN sav_rec_type,
    p_to	IN OUT NOCOPY savv_rec_type
  ) IS
  BEGIN
    p_to.sav_release := p_from.sav_release;
    p_to.sae_id := p_from.sae_id;
    p_to.date_active := p_from.date_active;
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
    p_from	IN savv_rec_type,
    p_to	OUT NOCOPY OkcStdArtVersionsTlRecType
  ) IS
  BEGIN
    p_to.sae_id := p_from.sae_id;
    p_to.sav_release := p_from.sav_release;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.text := p_from.text;
    p_to.short_description := p_from.short_description;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN OkcStdArtVersionsTlRecType,
    p_to	IN OUT NOCOPY savv_rec_type
  ) IS
  BEGIN
    p_to.sae_id := p_from.sae_id;
    p_to.sav_release := p_from.sav_release;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.text := p_from.text;
    p_to.short_description := p_from.short_description;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_STD_ART_VERSIONS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
    l_sav_rec                      sav_rec_type;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
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
    l_return_status := Validate_Attributes(l_savv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_savv_rec);
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
  -- PL/SQL TBL validate_row for:SAVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_savv_tbl.COUNT > 0) THEN
      i := p_savv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_savv_rec                     => p_savv_tbl(i));
        EXIT WHEN (i = p_savv_tbl.LAST);
        i := p_savv_tbl.NEXT(i);
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
  -------------------------------------------
  -- insert_row for:OKC_STD_ART_VERSIONS_B --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sav_rec                      IN sav_rec_type,
    x_sav_rec                      OUT NOCOPY sav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sav_rec                      sav_rec_type := p_sav_rec;
    l_def_sav_rec                  sav_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_B --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sav_rec IN  sav_rec_type,
      x_sav_rec OUT NOCOPY sav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sav_rec := p_sav_rec;
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
      p_sav_rec,                         -- IN
      l_sav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_STD_ART_VERSIONS_B(
        sav_release,
        sae_id,
        date_active,
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
        l_sav_rec.sav_release,
        l_sav_rec.sae_id,
        l_sav_rec.date_active,
        l_sav_rec.object_version_number,
        l_sav_rec.created_by,
        l_sav_rec.creation_date,
        l_sav_rec.last_updated_by,
        l_sav_rec.last_update_date,
        l_sav_rec.last_update_login,
        l_sav_rec.attribute_category,
        l_sav_rec.attribute1,
        l_sav_rec.attribute2,
        l_sav_rec.attribute3,
        l_sav_rec.attribute4,
        l_sav_rec.attribute5,
        l_sav_rec.attribute6,
        l_sav_rec.attribute7,
        l_sav_rec.attribute8,
        l_sav_rec.attribute9,
        l_sav_rec.attribute10,
        l_sav_rec.attribute11,
        l_sav_rec.attribute12,
        l_sav_rec.attribute13,
        l_sav_rec.attribute14,
        l_sav_rec.attribute15);
    -- Set OUT values
    x_sav_rec := l_sav_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_STD_ART_VERSIONS_TL --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType,
    x_okc_std_art_versions_tl_rec  OUT NOCOPY OkcStdArtVersionsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType := p_okc_std_art_versions_tl_rec;
    ldefokcstdartversionstlrec     OkcStdArtVersionsTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_TL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_art_versions_tl_rec IN  OkcStdArtVersionsTlRecType,
      x_okc_std_art_versions_tl_rec OUT NOCOPY OkcStdArtVersionsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_std_art_versions_tl_rec := p_okc_std_art_versions_tl_rec;
      --x_okc_std_art_versions_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_std_art_versions_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      --x_okc_std_art_versions_tl_rec.SOURCE_LANG := USERENV('LANG');
      x_okc_std_art_versions_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_std_art_versions_tl_rec,     -- IN
      l_okc_std_art_versions_tl_rec);    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_std_art_versions_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_STD_ART_VERSIONS_TL(
          sae_id,
          sav_release,
          language,
          source_lang,
          sfwt_flag,
          object_version_number,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          text,
          short_description,
          last_update_login)
        VALUES (
          l_okc_std_art_versions_tl_rec.sae_id,
          l_okc_std_art_versions_tl_rec.sav_release,
          l_okc_std_art_versions_tl_rec.language,
          l_okc_std_art_versions_tl_rec.source_lang,
          l_okc_std_art_versions_tl_rec.sfwt_flag,
          l_okc_std_art_versions_tl_rec.object_version_number,
          l_okc_std_art_versions_tl_rec.created_by,
          l_okc_std_art_versions_tl_rec.creation_date,
          l_okc_std_art_versions_tl_rec.last_updated_by,
          l_okc_std_art_versions_tl_rec.last_update_date,
          l_okc_std_art_versions_tl_rec.text,
          l_okc_std_art_versions_tl_rec.short_description,
          l_okc_std_art_versions_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_std_art_versions_tl_rec := l_okc_std_art_versions_tl_rec;
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
  -- insert_row for:OKC_STD_ART_VERSIONS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type;
    l_def_savv_rec                 savv_rec_type;
    l_sav_rec                      sav_rec_type;
    lx_sav_rec                     sav_rec_type;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
    lx_okc_std_art_versions_tl_rec OkcStdArtVersionsTlRecType;

    /****************ADDED AFTER TAPI**************/
    -- ------------------------------------------------------
    -- To check for any matching row, for unique combination.
    -- Bug 1636056 related changes - Shyam
    -- ------------------------------------------------------
       CURSOR cur_sav IS
       SELECT 'x'
	  FROM   okc_std_art_versions_b
       WHERE  sae_id      = l_def_savv_rec.SAE_ID
       AND    sav_release = l_def_savv_rec.SAV_RELEASE;

     l_row_found   BOOLEAN := FALSE;
     l_dummy       VARCHAR2(1);

    /****************END ADDED AFTER TAPI**************/

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_savv_rec	IN savv_rec_type
    ) RETURN savv_rec_type IS
      l_savv_rec	savv_rec_type := p_savv_rec;
    BEGIN
      l_savv_rec.CREATION_DATE := SYSDATE;
      l_savv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_savv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_savv_rec.LAST_UPDATE_DATE := l_savv_rec.CREATION_DATE;
      l_savv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_savv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_savv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_savv_rec IN  savv_rec_type,
      x_savv_rec OUT NOCOPY savv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_savv_rec := p_savv_rec;
      x_savv_rec.OBJECT_VERSION_NUMBER := 1;
      x_savv_rec.SFWT_FLAG := 'N';
  /****************ADDED AFTER TAPI**************/
      x_savv_rec.SFWT_FLAG :=UPPER(TRIM( x_savv_rec.SFWT_FLAG));
  /****************END ADDED AFTER TAPI**************/

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
    l_savv_rec := null_out_defaults(p_savv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_savv_rec,                        -- IN
      l_def_savv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_savv_rec := fill_who_columns(l_def_savv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_savv_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_savv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    /****************ADDED AFTER TAPI**************/
    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call is replaced with
    -- the explicit cursors above, for identical function to
    -- check uniqueness for SAE_ID + SAV_RELEASE in OKC_STD_ART_VERSIONS_V
    -- ---------------------------------------------------------------------
    IF (       (l_def_savv_rec.sae_id IS NOT NULL)
           AND (l_def_savv_rec.sae_id <> OKC_API.G_MISS_NUM)     )
	   AND
		(    (l_def_savv_rec.sav_release IS NOT NULL)
		AND  (l_def_savv_rec.sav_release <> OKC_API.G_MISS_CHAR) )
    THEN
        OPEN  cur_sav;
        FETCH cur_sav INTO l_dummy;
	   l_row_found := cur_sav%FOUND;
	   CLOSE cur_sav;

        IF (l_row_found)
        THEN
	       -- Display the newly defined error message
		  OKC_API.set_message(G_APP_NAME,
		                      'OKC_DUP_SAV_RELEASE');

		  -- Set return status as error and raise exception
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

	END IF;

    /****************END ADDED AFTER TAPI**************/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_savv_rec, l_sav_rec);
    migrate(l_def_savv_rec, l_okc_std_art_versions_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sav_rec,
      lx_sav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sav_rec, l_def_savv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_art_versions_tl_rec,
      lx_okc_std_art_versions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_std_art_versions_tl_rec, l_def_savv_rec);
    -- Set OUT values
    x_savv_rec := l_def_savv_rec;
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
  -- PL/SQL TBL insert_row for:SAVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_savv_tbl.COUNT > 0) THEN
      i := p_savv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_savv_rec                     => p_savv_tbl(i),
          x_savv_rec                     => x_savv_tbl(i));
        EXIT WHEN (i = p_savv_tbl.LAST);
        i := p_savv_tbl.NEXT(i);
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
  -----------------------------------------
  -- lock_row for:OKC_STD_ART_VERSIONS_B --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sav_rec                      IN sav_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sav_rec IN sav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_VERSIONS_B
     WHERE SAE_ID = p_sav_rec.sae_id
       AND SAV_RELEASE = p_sav_rec.sav_release
       AND OBJECT_VERSION_NUMBER = p_sav_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sav_rec IN sav_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_VERSIONS_B
    WHERE SAE_ID = p_sav_rec.sae_id
       AND SAV_RELEASE = p_sav_rec.sav_release;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_STD_ART_VERSIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_STD_ART_VERSIONS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sav_rec);
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
      OPEN lchk_csr(p_sav_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sav_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sav_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKC_STD_ART_VERSIONS_TL --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_std_art_versions_tl_rec IN OkcStdArtVersionsTlRecType) IS
    SELECT *
      FROM OKC_STD_ART_VERSIONS_TL
     WHERE SAE_ID = p_okc_std_art_versions_tl_rec.sae_id
       AND SAV_RELEASE = p_okc_std_art_versions_tl_rec.sav_release
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
      OPEN lock_csr(p_okc_std_art_versions_tl_rec);
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
  -----------------------------------------
  -- lock_row for:OKC_STD_ART_VERSIONS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sav_rec                      sav_rec_type;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
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
    migrate(p_savv_rec, l_sav_rec);
    migrate(p_savv_rec, l_okc_std_art_versions_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sav_rec
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
      l_okc_std_art_versions_tl_rec
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
  -- PL/SQL TBL lock_row for:SAVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_savv_tbl.COUNT > 0) THEN
      i := p_savv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_savv_rec                     => p_savv_tbl(i));
        EXIT WHEN (i = p_savv_tbl.LAST);
        i := p_savv_tbl.NEXT(i);
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
  -------------------------------------------
  -- update_row for:OKC_STD_ART_VERSIONS_B --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sav_rec                      IN sav_rec_type,
    x_sav_rec                      OUT NOCOPY sav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sav_rec                      sav_rec_type := p_sav_rec;
    l_def_sav_rec                  sav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sav_rec	IN sav_rec_type,
      x_sav_rec	OUT NOCOPY sav_rec_type
    ) RETURN VARCHAR2 IS
      l_sav_rec                      sav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sav_rec := p_sav_rec;
      -- Get current database values
      l_sav_rec := get_rec(p_sav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sav_rec.sav_release = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.sav_release := l_sav_rec.sav_release;
      END IF;
      IF (x_sav_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_sav_rec.sae_id := l_sav_rec.sae_id;
      END IF;
      IF (x_sav_rec.date_active = OKC_API.G_MISS_DATE)
      THEN
        x_sav_rec.date_active := l_sav_rec.date_active;
      END IF;
      IF (x_sav_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sav_rec.object_version_number := l_sav_rec.object_version_number;
      END IF;
      IF (x_sav_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sav_rec.created_by := l_sav_rec.created_by;
      END IF;
      IF (x_sav_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sav_rec.creation_date := l_sav_rec.creation_date;
      END IF;
      IF (x_sav_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sav_rec.last_updated_by := l_sav_rec.last_updated_by;
      END IF;
      IF (x_sav_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sav_rec.last_update_date := l_sav_rec.last_update_date;
      END IF;
      IF (x_sav_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sav_rec.last_update_login := l_sav_rec.last_update_login;
      END IF;
      IF (x_sav_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute_category := l_sav_rec.attribute_category;
      END IF;
      IF (x_sav_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute1 := l_sav_rec.attribute1;
      END IF;
      IF (x_sav_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute2 := l_sav_rec.attribute2;
      END IF;
      IF (x_sav_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute3 := l_sav_rec.attribute3;
      END IF;
      IF (x_sav_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute4 := l_sav_rec.attribute4;
      END IF;
      IF (x_sav_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute5 := l_sav_rec.attribute5;
      END IF;
      IF (x_sav_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute6 := l_sav_rec.attribute6;
      END IF;
      IF (x_sav_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute7 := l_sav_rec.attribute7;
      END IF;
      IF (x_sav_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute8 := l_sav_rec.attribute8;
      END IF;
      IF (x_sav_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute9 := l_sav_rec.attribute9;
      END IF;
      IF (x_sav_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute10 := l_sav_rec.attribute10;
      END IF;
      IF (x_sav_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute11 := l_sav_rec.attribute11;
      END IF;
      IF (x_sav_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute12 := l_sav_rec.attribute12;
      END IF;
      IF (x_sav_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute13 := l_sav_rec.attribute13;
      END IF;
      IF (x_sav_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute14 := l_sav_rec.attribute14;
      END IF;
      IF (x_sav_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sav_rec.attribute15 := l_sav_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_B --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sav_rec IN  sav_rec_type,
      x_sav_rec OUT NOCOPY sav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sav_rec := p_sav_rec;
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
      p_sav_rec,                         -- IN
      l_sav_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sav_rec, l_def_sav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ART_VERSIONS_B
    SET DATE_ACTIVE = l_def_sav_rec.date_active,
        OBJECT_VERSION_NUMBER = l_def_sav_rec.object_version_number,
        CREATED_BY = l_def_sav_rec.created_by,
        CREATION_DATE = l_def_sav_rec.creation_date,
        LAST_UPDATED_BY = l_def_sav_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sav_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sav_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_sav_rec.attribute_category,
        ATTRIBUTE1 = l_def_sav_rec.attribute1,
        ATTRIBUTE2 = l_def_sav_rec.attribute2,
        ATTRIBUTE3 = l_def_sav_rec.attribute3,
        ATTRIBUTE4 = l_def_sav_rec.attribute4,
        ATTRIBUTE5 = l_def_sav_rec.attribute5,
        ATTRIBUTE6 = l_def_sav_rec.attribute6,
        ATTRIBUTE7 = l_def_sav_rec.attribute7,
        ATTRIBUTE8 = l_def_sav_rec.attribute8,
        ATTRIBUTE9 = l_def_sav_rec.attribute9,
        ATTRIBUTE10 = l_def_sav_rec.attribute10,
        ATTRIBUTE11 = l_def_sav_rec.attribute11,
        ATTRIBUTE12 = l_def_sav_rec.attribute12,
        ATTRIBUTE13 = l_def_sav_rec.attribute13,
        ATTRIBUTE14 = l_def_sav_rec.attribute14,
        ATTRIBUTE15 = l_def_sav_rec.attribute15
    WHERE SAE_ID = l_def_sav_rec.sae_id
      AND SAV_RELEASE = l_def_sav_rec.sav_release;

    x_sav_rec := l_def_sav_rec;
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
  --------------------------------------------
  -- update_row for:OKC_STD_ART_VERSIONS_TL --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType,
    x_okc_std_art_versions_tl_rec  OUT NOCOPY OkcStdArtVersionsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType := p_okc_std_art_versions_tl_rec;
    ldefokcstdartversionstlrec     OkcStdArtVersionsTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_std_art_versions_tl_rec	IN OkcStdArtVersionsTlRecType,
      x_okc_std_art_versions_tl_rec	OUT NOCOPY OkcStdArtVersionsTlRecType
    ) RETURN VARCHAR2 IS
      l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_std_art_versions_tl_rec := p_okc_std_art_versions_tl_rec;
      -- Get current database values
      l_okc_std_art_versions_tl_rec := get_rec(p_okc_std_art_versions_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_art_versions_tl_rec.sae_id := l_okc_std_art_versions_tl_rec.sae_id;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.sav_release = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_art_versions_tl_rec.sav_release := l_okc_std_art_versions_tl_rec.sav_release;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_art_versions_tl_rec.language := l_okc_std_art_versions_tl_rec.language;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_art_versions_tl_rec.source_lang := l_okc_std_art_versions_tl_rec.source_lang;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_art_versions_tl_rec.sfwt_flag := l_okc_std_art_versions_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_art_versions_tl_rec.object_version_number := l_okc_std_art_versions_tl_rec.object_version_number;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_art_versions_tl_rec.created_by := l_okc_std_art_versions_tl_rec.created_by;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_std_art_versions_tl_rec.creation_date := l_okc_std_art_versions_tl_rec.creation_date;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_art_versions_tl_rec.last_updated_by := l_okc_std_art_versions_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_std_art_versions_tl_rec.last_update_date := l_okc_std_art_versions_tl_rec.last_update_date;
      END IF;
--alex solution added after tapi
 	-- IF (x_okc_std_art_versions_tl_rec.text = OKC_API.G_MISS_DATE)
        IF (x_okc_std_art_versions_tl_rec.text is NULL)
      THEN
        x_okc_std_art_versions_tl_rec.text := l_okc_std_art_versions_tl_rec.text;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_std_art_versions_tl_rec.short_description := l_okc_std_art_versions_tl_rec.short_description;
      END IF;
      IF (x_okc_std_art_versions_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_std_art_versions_tl_rec.last_update_login := l_okc_std_art_versions_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_TL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_art_versions_tl_rec IN  OkcStdArtVersionsTlRecType,
      x_okc_std_art_versions_tl_rec OUT NOCOPY OkcStdArtVersionsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_std_art_versions_tl_rec := p_okc_std_art_versions_tl_rec;
      --x_okc_std_art_versions_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_std_art_versions_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      --x_okc_std_art_versions_tl_rec.SOURCE_LANG := USERENV('LANG');
      x_okc_std_art_versions_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_std_art_versions_tl_rec,     -- IN
      l_okc_std_art_versions_tl_rec);    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_std_art_versions_tl_rec, ldefokcstdartversionstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ART_VERSIONS_TL
    SET OBJECT_VERSION_NUMBER = ldefokcstdartversionstlrec.object_version_number,
        CREATED_BY = ldefokcstdartversionstlrec.created_by,
        CREATION_DATE = ldefokcstdartversionstlrec.creation_date,
        LAST_UPDATED_BY = ldefokcstdartversionstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcstdartversionstlrec.last_update_date,
        TEXT = ldefokcstdartversionstlrec.text,
        SHORT_DESCRIPTION = ldefokcstdartversionstlrec.short_description,
        LAST_UPDATE_LOGIN = ldefokcstdartversionstlrec.last_update_login
--added after tapi
	,SOURCE_LANG  =     ldefokcstdartversionstlrec.source_lang
--end added after tapi
    WHERE SAE_ID = ldefokcstdartversionstlrec.sae_id
      AND SAV_RELEASE = ldefokcstdartversionstlrec.sav_release
--commented after tapi replaced with following
      --AND SOURCE_LANG = USERENV('LANG');
      AND USERENV('LANG')  IN (SOURCE_LANG,LANGUAGE);

    UPDATE  OKC_STD_ART_VERSIONS_TL
    SET SFWT_FLAG = 'Y'
    WHERE SAE_ID = ldefokcstdartversionstlrec.sae_id
      AND SAV_RELEASE = ldefokcstdartversionstlrec.sav_release
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_std_art_versions_tl_rec := ldefokcstdartversionstlrec;
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
  -- update_row for:OKC_STD_ART_VERSIONS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
    l_def_savv_rec                 savv_rec_type;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
    lx_okc_std_art_versions_tl_rec OkcStdArtVersionsTlRecType;
    l_sav_rec                      sav_rec_type;
    lx_sav_rec                     sav_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_savv_rec	IN savv_rec_type
    ) RETURN savv_rec_type IS
      l_savv_rec	savv_rec_type := p_savv_rec;
    BEGIN
      l_savv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_savv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_savv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_savv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_savv_rec	IN savv_rec_type,
      x_savv_rec	OUT NOCOPY savv_rec_type
    ) RETURN VARCHAR2 IS
      l_savv_rec                     savv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_savv_rec := p_savv_rec;
      -- Get current database values
      l_savv_rec := get_rec(p_savv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_savv_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_savv_rec.sae_id := l_savv_rec.sae_id;
      END IF;
      IF (x_savv_rec.sav_release = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.sav_release := l_savv_rec.sav_release;
      END IF;
      IF (x_savv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_savv_rec.object_version_number := l_savv_rec.object_version_number;
      END IF;
      IF (x_savv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.sfwt_flag := l_savv_rec.sfwt_flag;
      END IF;
      IF (x_savv_rec.date_active = OKC_API.G_MISS_DATE)
      THEN
        x_savv_rec.date_active := l_savv_rec.date_active;
      END IF;
--added after tapi
--alex solution
      --IF (x_savv_rec.text = OKC_API.G_MISS_DATE)
      IF (x_savv_rec.text is NULL)
      THEN
        x_savv_rec.text := l_savv_rec.text;
      END IF;
      IF (x_savv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.short_description := l_savv_rec.short_description;
      END IF;
      IF (x_savv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute_category := l_savv_rec.attribute_category;
      END IF;
      IF (x_savv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute1 := l_savv_rec.attribute1;
      END IF;
      IF (x_savv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute2 := l_savv_rec.attribute2;
      END IF;
      IF (x_savv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute3 := l_savv_rec.attribute3;
      END IF;
      IF (x_savv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute4 := l_savv_rec.attribute4;
      END IF;
      IF (x_savv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute5 := l_savv_rec.attribute5;
      END IF;
      IF (x_savv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute6 := l_savv_rec.attribute6;
      END IF;
      IF (x_savv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute7 := l_savv_rec.attribute7;
      END IF;
      IF (x_savv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute8 := l_savv_rec.attribute8;
      END IF;
      IF (x_savv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute9 := l_savv_rec.attribute9;
      END IF;
      IF (x_savv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute10 := l_savv_rec.attribute10;
      END IF;
      IF (x_savv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute11 := l_savv_rec.attribute11;
      END IF;
      IF (x_savv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute12 := l_savv_rec.attribute12;
      END IF;
      IF (x_savv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute13 := l_savv_rec.attribute13;
      END IF;
      IF (x_savv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute14 := l_savv_rec.attribute14;
      END IF;
      IF (x_savv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_savv_rec.attribute15 := l_savv_rec.attribute15;
      END IF;
      IF (x_savv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_savv_rec.created_by := l_savv_rec.created_by;
      END IF;
      IF (x_savv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_savv_rec.creation_date := l_savv_rec.creation_date;
      END IF;
      IF (x_savv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_savv_rec.last_updated_by := l_savv_rec.last_updated_by;
      END IF;
      IF (x_savv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_savv_rec.last_update_date := l_savv_rec.last_update_date;
      END IF;
      IF (x_savv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_savv_rec.last_update_login := l_savv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_savv_rec IN  savv_rec_type,
      x_savv_rec OUT NOCOPY savv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_savv_rec := p_savv_rec;
      x_savv_rec.OBJECT_VERSION_NUMBER := NVL(x_savv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
  /****************ADDED AFTER TAPI**************/
      x_savv_rec.SFWT_FLAG :=UPPER(TRIM( p_savv_rec.SFWT_FLAG));
  /****************END ADDED AFTER TAPI**************/

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
      p_savv_rec,                        -- IN
      l_savv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    /****************ADDED AFTER TAPI**************/
    validate_updatable(l_savv_rec,l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    /****************END ADDED AFTER TAPI**************/
    l_return_status := populate_new_record(l_savv_rec, l_def_savv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_savv_rec := fill_who_columns(l_def_savv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_savv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_savv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_savv_rec, l_okc_std_art_versions_tl_rec);
    migrate(l_def_savv_rec, l_sav_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_art_versions_tl_rec,
      lx_okc_std_art_versions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_std_art_versions_tl_rec, l_def_savv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sav_rec,
      lx_sav_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sav_rec, l_def_savv_rec);
    x_savv_rec := l_def_savv_rec;
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
  -- PL/SQL TBL update_row for:SAVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_savv_tbl.COUNT > 0) THEN
      i := p_savv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_savv_rec                     => p_savv_tbl(i),
          x_savv_rec                     => x_savv_tbl(i));
        EXIT WHEN (i = p_savv_tbl.LAST);
        i := p_savv_tbl.NEXT(i);
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
  -------------------------------------------
  -- delete_row for:OKC_STD_ART_VERSIONS_B --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sav_rec                      IN sav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sav_rec                      sav_rec_type:= p_sav_rec;
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
    DELETE FROM OKC_STD_ART_VERSIONS_B
     WHERE SAE_ID = l_sav_rec.sae_id AND
SAV_RELEASE = l_sav_rec.sav_release;

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
  --------------------------------------------
  -- delete_row for:OKC_STD_ART_VERSIONS_TL --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_std_art_versions_tl_rec  IN OkcStdArtVersionsTlRecType) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType:= p_okc_std_art_versions_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_VERSIONS_TL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_std_art_versions_tl_rec IN  OkcStdArtVersionsTlRecType,
      x_okc_std_art_versions_tl_rec OUT NOCOPY OkcStdArtVersionsTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_std_art_versions_tl_rec := p_okc_std_art_versions_tl_rec;
      x_okc_std_art_versions_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_std_art_versions_tl_rec,     -- IN
      l_okc_std_art_versions_tl_rec);    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_STD_ART_VERSIONS_TL
     WHERE SAE_ID = l_okc_std_art_versions_tl_rec.sae_id AND
SAV_RELEASE = l_okc_std_art_versions_tl_rec.sav_release;

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
  -- delete_row for:OKC_STD_ART_VERSIONS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
    l_okc_std_art_versions_tl_rec  OkcStdArtVersionsTlRecType;
    l_sav_rec                      sav_rec_type;
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
    /****************ADDED AFTER TAPI***************************/
     --check that this release is not being referenced by any contract
    validate_no_k_attached(l_savv_rec,l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                --set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        	    p_msg_name     =>   G_ATE_CANNOT_DELETE);
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    /****************END ADDED AFTER TAPI************************/

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_savv_rec, l_okc_std_art_versions_tl_rec);
    migrate(l_savv_rec, l_sav_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_std_art_versions_tl_rec
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
      l_sav_rec
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
  -- PL/SQL TBL delete_row for:SAVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_savv_tbl.COUNT > 0) THEN
      i := p_savv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_savv_rec                     => p_savv_tbl(i));
        EXIT WHEN (i = p_savv_tbl.LAST);
        i := p_savv_tbl.NEXT(i);
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
END OKC_SAV_PVT;

/

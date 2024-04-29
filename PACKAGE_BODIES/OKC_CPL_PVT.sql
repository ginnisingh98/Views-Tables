--------------------------------------------------------
--  DDL for Package Body OKC_CPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CPL_PVT" AS
/* $Header: OKCSCPLB.pls 120.3.12010000.2 2008/10/24 08:03:40 ssreekum ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT_VALIDATION  exception;
G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
G_VIEW			 CONSTANT	VARCHAR2(200) := 'OKC_K_PARTY_ROLES_V';
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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('500: Entered add_language', 2);
    END IF;

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_K_PARTY_ROLES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_PARTY_ROLES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_K_PARTY_ROLES_TL T SET (
        COGNOMEN,
        ALIAS) = (SELECT
                                  B.COGNOMEN,
                                  B.ALIAS
                                FROM OKC_K_PARTY_ROLES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_K_PARTY_ROLES_TL SUBB, OKC_K_PARTY_ROLES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COGNOMEN <> SUBT.COGNOMEN
                      OR SUBB.ALIAS <> SUBT.ALIAS
                      OR (SUBB.COGNOMEN IS NULL AND SUBT.COGNOMEN IS NOT NULL)
                      OR (SUBB.COGNOMEN IS NOT NULL AND SUBT.COGNOMEN IS NULL)
                      OR (SUBB.ALIAS IS NULL AND SUBT.ALIAS IS NOT NULL)
                      OR (SUBB.ALIAS IS NOT NULL AND SUBT.ALIAS IS NULL)
              ));
*/
/* Modifying Insert as per performance guidelines given in bug 3723874 */
    INSERT /*+ append parallel(tt) */ INTO OKC_K_PARTY_ROLES_TL tt (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        COGNOMEN,
        ALIAS,
        LAST_UPDATE_LOGIN)
      select /*+ parallel(v) parallel(t) use_nl(t)  */  v.* from
      (SELECT /*+ no_merge ordered parallel(b) */
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.COGNOMEN,
            B.ALIAS,
            B.LAST_UPDATE_LOGIN
        FROM OKC_K_PARTY_ROLES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
        ) v , OKC_K_PARTY_ROLES_TL t
        WHERE t.ID(+) = v.ID
        AND t.LANGUAGE(+) = v.LANGUAGE_CODE
	AND t.id IS NULL;

/* Commenting delete and update for bug 3723874 */
/*
    DELETE FROM OKC_K_PARTY_ROLES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_K_PARTY_ROLES_BH B
         WHERE B.ID = T.ID
         AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_K_PARTY_ROLES_TLH T SET (
        COGNOMEN,
        ALIAS) = (SELECT
                                  B.COGNOMEN,
                                  B.ALIAS
                                FROM OKC_K_PARTY_ROLES_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_K_PARTY_ROLES_TLH SUBB, OKC_K_PARTY_ROLES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.COGNOMEN <> SUBT.COGNOMEN
                      OR SUBB.ALIAS <> SUBT.ALIAS
                      OR (SUBB.COGNOMEN IS NULL AND SUBT.COGNOMEN IS NOT NULL)
                      OR (SUBB.COGNOMEN IS NOT NULL AND SUBT.COGNOMEN IS NULL)
                      OR (SUBB.ALIAS IS NULL AND SUBT.ALIAS IS NOT NULL)
                      OR (SUBB.ALIAS IS NOT NULL AND SUBT.ALIAS IS NULL)
              ));
*/
/* Modifying Insert as per performance guidelines given in bug 3723874 */

    INSERT /*+ append parallel(tt) */ INTO OKC_K_PARTY_ROLES_TLH tt(
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        COGNOMEN,
        ALIAS,
        LAST_UPDATE_LOGIN)
      select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
      ( SELECT /*+ no_merge ordered parallel(b) */
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.COGNOMEN,
            B.ALIAS,
            B.LAST_UPDATE_LOGIN
        FROM OKC_K_PARTY_ROLES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
        ) v, OKC_K_PARTY_ROLES_TLH t
        WHERE t.ID(+) = v.ID
        AND t.MAJOR_VERSION(+) = v.MAJOR_VERSION
        AND t.LANGUAGE(+) = v.LANGUAGE_CODE
        AND t.id IS NULL;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  add_language ', 2);
   okc_debug.Reset_Indentation;
END IF;

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_PARTY_ROLES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cpl_rec                      IN cpl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cpl_rec_type IS
    CURSOR cpl_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CPL_ID,CHR_ID,
            CLE_ID,
            DNZ_CHR_ID,
            RLE_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CODE,
            FACILITY,
            MINORITY_GROUP_LOOKUP_CODE,
            SMALL_BUSINESS_FLAG,
            WOMEN_OWNED_FLAG,
            LAST_UPDATE_LOGIN,
		  PRIMARY_YN,
		  CUST_ACCT_ID,
	  	  BILL_TO_SITE_USE_ID,
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
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Okc_K_Party_Roles_B
     WHERE okc_k_party_roles_b.id = p_id;
    l_cpl_pk                       cpl_pk_csr%ROWTYPE;
    l_cpl_rec                      cpl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('600: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cpl_pk_csr (p_cpl_rec.id);
    FETCH cpl_pk_csr INTO
              l_cpl_rec.ID,
              l_cpl_rec.CPL_ID,l_cpl_rec.CHR_ID,
              l_cpl_rec.CLE_ID,
              l_cpl_rec.DNZ_CHR_ID,
              l_cpl_rec.RLE_CODE,
              l_cpl_rec.OBJECT1_ID1,
              l_cpl_rec.OBJECT1_ID2,
              l_cpl_rec.JTOT_OBJECT1_CODE,
              l_cpl_rec.OBJECT_VERSION_NUMBER,
              l_cpl_rec.CREATED_BY,
              l_cpl_rec.CREATION_DATE,
              l_cpl_rec.LAST_UPDATED_BY,
              l_cpl_rec.LAST_UPDATE_DATE,
              l_cpl_rec.CODE,
              l_cpl_rec.FACILITY,
              l_cpl_rec.MINORITY_GROUP_LOOKUP_CODE,
              l_cpl_rec.SMALL_BUSINESS_FLAG,
              l_cpl_rec.WOMEN_OWNED_FLAG,
              l_cpl_rec.LAST_UPDATE_LOGIN,
		    l_cpl_rec.PRIMARY_YN,
              l_cpl_rec.CUST_ACCT_ID,
              l_cpl_rec.BILL_TO_SITE_USE_ID,
              l_cpl_rec.ATTRIBUTE_CATEGORY,
              l_cpl_rec.ATTRIBUTE1,
              l_cpl_rec.ATTRIBUTE2,
              l_cpl_rec.ATTRIBUTE3,
              l_cpl_rec.ATTRIBUTE4,
              l_cpl_rec.ATTRIBUTE5,
              l_cpl_rec.ATTRIBUTE6,
              l_cpl_rec.ATTRIBUTE7,
              l_cpl_rec.ATTRIBUTE8,
              l_cpl_rec.ATTRIBUTE9,
              l_cpl_rec.ATTRIBUTE10,
              l_cpl_rec.ATTRIBUTE11,
              l_cpl_rec.ATTRIBUTE12,
              l_cpl_rec.ATTRIBUTE13,
              l_cpl_rec.ATTRIBUTE14,
              l_cpl_rec.ATTRIBUTE15,
-- R12 Data Model Changes 4485150 Start
              l_cpl_rec.ORIG_SYSTEM_ID1,
              l_cpl_rec.ORIG_SYSTEM_REFERENCE1,
              l_cpl_rec.ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := cpl_pk_csr%NOTFOUND;
    CLOSE cpl_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('700: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_cpl_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cpl_rec                      IN cpl_rec_type
  ) RETURN cpl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cpl_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_PARTY_ROLES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_k_party_roles_tl_rec_type IS
    CURSOR cpl_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            COGNOMEN,
            ALIAS,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Party_Roles_Tl
     WHERE okc_k_party_roles_tl.id = p_id
       AND okc_k_party_roles_tl.language = p_language;
    l_cpl_pktl                     cpl_pktl_csr%ROWTYPE;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('800: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cpl_pktl_csr (p_okc_k_party_roles_tl_rec.id,
                       p_okc_k_party_roles_tl_rec.language);
    FETCH cpl_pktl_csr INTO
              l_okc_k_party_roles_tl_rec.ID,
              l_okc_k_party_roles_tl_rec.LANGUAGE,
              l_okc_k_party_roles_tl_rec.SOURCE_LANG,
              l_okc_k_party_roles_tl_rec.SFWT_FLAG,
              l_okc_k_party_roles_tl_rec.CREATED_BY,
              l_okc_k_party_roles_tl_rec.CREATION_DATE,
              l_okc_k_party_roles_tl_rec.LAST_UPDATED_BY,
              l_okc_k_party_roles_tl_rec.LAST_UPDATE_DATE,
              l_okc_k_party_roles_tl_rec.COGNOMEN,
              l_okc_k_party_roles_tl_rec.ALIAS,
              l_okc_k_party_roles_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cpl_pktl_csr%NOTFOUND;
    CLOSE cpl_pktl_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('900: Entered get_rec', 2);
    END IF;

    RETURN(l_okc_k_party_roles_tl_rec);

  END get_rec;

  FUNCTION get_rec (
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type
  ) RETURN okc_k_party_roles_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_okc_k_party_roles_tl_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_PARTY_ROLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cplv_rec                     IN cplv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cplv_rec_type IS
    CURSOR okc_cplv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            CPL_ID,CHR_ID,
            CLE_ID,
            RLE_CODE,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            COGNOMEN,
            CODE,
            FACILITY,
            MINORITY_GROUP_LOOKUP_CODE,
            SMALL_BUSINESS_FLAG,
            WOMEN_OWNED_FLAG,
            ALIAS,
		  PRIMARY_YN,
            CUST_ACCT_ID,
            BILL_TO_SITE_USE_ID,
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
      FROM Okc_K_Party_Roles_V
     WHERE okc_k_party_roles_v.id = p_id;
    l_okc_cplv_pk                  okc_cplv_pk_csr%ROWTYPE;
    l_cplv_rec                     cplv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('1000: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cplv_pk_csr (p_cplv_rec.id);
    FETCH okc_cplv_pk_csr INTO
              l_cplv_rec.ID,
              l_cplv_rec.OBJECT_VERSION_NUMBER,
              l_cplv_rec.SFWT_FLAG,
              l_cplv_rec.CPL_ID,l_cplv_rec.CHR_ID,
              l_cplv_rec.CLE_ID,
              l_cplv_rec.RLE_CODE,
              l_cplv_rec.DNZ_CHR_ID,
              l_cplv_rec.OBJECT1_ID1,
              l_cplv_rec.OBJECT1_ID2,
              l_cplv_rec.JTOT_OBJECT1_CODE,
              l_cplv_rec.COGNOMEN,
              l_cplv_rec.CODE,
              l_cplv_rec.FACILITY,
              l_cplv_rec.MINORITY_GROUP_LOOKUP_CODE,
              l_cplv_rec.SMALL_BUSINESS_FLAG,
              l_cplv_rec.WOMEN_OWNED_FLAG,
              l_cplv_rec.ALIAS,
		    l_cplv_rec.PRIMARY_YN,
              l_cplv_rec.CUST_ACCT_ID,
              l_cplv_rec.BILL_TO_SITE_USE_ID,
              l_cplv_rec.ATTRIBUTE_CATEGORY,
              l_cplv_rec.ATTRIBUTE1,
              l_cplv_rec.ATTRIBUTE2,
              l_cplv_rec.ATTRIBUTE3,
              l_cplv_rec.ATTRIBUTE4,
              l_cplv_rec.ATTRIBUTE5,
              l_cplv_rec.ATTRIBUTE6,
              l_cplv_rec.ATTRIBUTE7,
              l_cplv_rec.ATTRIBUTE8,
              l_cplv_rec.ATTRIBUTE9,
              l_cplv_rec.ATTRIBUTE10,
              l_cplv_rec.ATTRIBUTE11,
              l_cplv_rec.ATTRIBUTE12,
              l_cplv_rec.ATTRIBUTE13,
              l_cplv_rec.ATTRIBUTE14,
              l_cplv_rec.ATTRIBUTE15,
              l_cplv_rec.CREATED_BY,
              l_cplv_rec.CREATION_DATE,
              l_cplv_rec.LAST_UPDATED_BY,
              l_cplv_rec.LAST_UPDATE_DATE,
              l_cplv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cplv_pk_csr%NOTFOUND;
    CLOSE okc_cplv_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CPL_PVT');
   okc_debug.log('1050: Entered get_rec', 2);
END IF;

    RETURN(l_cplv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cplv_rec                     IN cplv_rec_type
  ) RETURN cplv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cplv_rec, l_row_notfound));

  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_PARTY_ROLES_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cplv_rec	IN cplv_rec_type
  ) RETURN cplv_rec_type IS
    l_cplv_rec	cplv_rec_type := p_cplv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('1200: Entered null_out_defaults', 2);
    END IF;

    IF (l_cplv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.object_version_number := NULL;
    END IF;
    IF (l_cplv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_cplv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.cpl_id := NULL;
    END IF;
    IF (l_cplv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.chr_id := NULL;
    END IF;
    IF (l_cplv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.cle_id := NULL;
    END IF;
    IF (l_cplv_rec.rle_code = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.rle_code := NULL;
    END IF;
    IF (l_cplv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_cplv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.object1_id1 := NULL;
    END IF;
    IF (l_cplv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.object1_id2 := NULL;
    END IF;
    IF (l_cplv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.JTOT_OBJECT1_CODE := NULL;
    END IF;
    IF (l_cplv_rec.cognomen = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.cognomen := NULL;
    END IF;
    IF (l_cplv_rec.code = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.code := NULL;
    END IF;
    IF (l_cplv_rec.facility = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.facility := NULL;
    END IF;
    IF (l_cplv_rec.minority_group_lookup_code = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.minority_group_lookup_code := NULL;
    END IF;
    IF (l_cplv_rec.small_business_flag = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.small_business_flag := NULL;
    END IF;
    IF (l_cplv_rec.women_owned_flag = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.women_owned_flag := NULL;
    END IF;
    IF (l_cplv_rec.alias = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.alias := NULL;
    END IF;
    IF (l_cplv_rec.primary_yn = OKC_API.G_MISS_CHAR) THEN
	  l_cplv_rec.primary_yn := NULL;
    END IF;
    IF (l_cplv_rec.cust_acct_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.cust_acct_id := NULL;
    END IF;
    IF (l_cplv_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.bill_to_site_use_id := NULL;
    END IF;
    IF (l_cplv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute_category := NULL;
    END IF;
    IF (l_cplv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute1 := NULL;
    END IF;
    IF (l_cplv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute2 := NULL;
    END IF;
    IF (l_cplv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute3 := NULL;
    END IF;
    IF (l_cplv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute4 := NULL;
    END IF;
    IF (l_cplv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute5 := NULL;
    END IF;
    IF (l_cplv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute6 := NULL;
    END IF;
    IF (l_cplv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute7 := NULL;
    END IF;
    IF (l_cplv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute8 := NULL;
    END IF;
    IF (l_cplv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute9 := NULL;
    END IF;
    IF (l_cplv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute10 := NULL;
    END IF;
    IF (l_cplv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute11 := NULL;
    END IF;
    IF (l_cplv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute12 := NULL;
    END IF;
    IF (l_cplv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute13 := NULL;
    END IF;
    IF (l_cplv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute14 := NULL;
    END IF;
    IF (l_cplv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_cplv_rec.attribute15 := NULL;
    END IF;
    IF (l_cplv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.created_by := NULL;
    END IF;
    IF (l_cplv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cplv_rec.creation_date := NULL;
    END IF;
    IF (l_cplv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cplv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cplv_rec.last_update_date := NULL;
    END IF;
    IF (l_cplv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cplv_rec.last_update_login := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('1150: Entered get_rec', 2);
    END IF;

    RETURN(l_cplv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_cle_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cle_csr is
  select 'x'
  from OKC_K_LINES_B
  where id = p_cplv_rec.cle_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('1300: Entered validate_cle_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.cle_id = OKC_API.G_MISS_NUM or p_cplv_rec.cle_id is NULL) then
      IF (l_debug = 'Y') THEN
         okc_debug.Reset_Indentation;
      END IF;
      return;
  end if;
  open l_cle_csr;
  fetch l_cle_csr into l_dummy_var;
  close l_cle_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('1400: Leaving validate_cle_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_cle_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting validate_cle_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cle_csr%ISOPEN then
      close l_cle_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cle_id;

-- Start of comments
--
-- Procedure Name  : validate_cpl_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cpl_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cpl_csr is
  select 'x'
  from OKC_K_PARTY_ROLES_B
  where id = p_cplv_rec.cpl_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('1700: Entered validate_cpl_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.cpl_id = OKC_API.G_MISS_NUM or p_cplv_rec.cpl_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
  open l_cpl_csr;
  fetch l_cpl_csr into l_dummy_var;
  close l_cpl_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPL_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('1800: Leaving validate_cpl_id', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_cpl_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cpl_csr%ISOPEN then
      close l_cpl_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cpl_id;

-- Start of comments
--
-- Procedure Name  : validate_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_chr_csr is
  select 'x'
  from OKC_K_HEADERS_ALL_B -- Modified by jvorugan for Bug:4645341 OKC_K_HEADERS_B
  where id = p_cplv_rec.chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('2000: Entered validate_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.chr_id = OKC_API.G_MISS_NUM or p_cplv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
  open l_chr_csr;
  fetch l_chr_csr into l_dummy_var;
  close l_chr_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Leaving validate_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_chr_csr%ISOPEN then
      close l_chr_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_chr_id;

-- Start of comments
--
-- Procedure Name  : validate_rle_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_rle_code(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
--
l_dummy_var                 varchar2(1) := '?';
--

cursor chr_csr is
select '!'
from
	OKC_K_HEADERS_ALL_B -- Modified by jvorugan for Bug:4645341 OKC_K_HEADERS_B
	,okc_subclass_roles
where
	okc_k_headers_all_b.id = p_cplv_rec.chr_id
	and okc_subclass_roles.scs_code = okc_k_headers_all_b.scs_code
	and okc_subclass_roles.rle_code = p_cplv_rec.rle_code
	and sysdate between okc_subclass_roles.start_date
	and NVL(okc_subclass_roles.end_date,sysdate)
;
--
cursor cle_csr is
select '!'
from
	okc_k_lines_b
	,okc_line_style_roles
where
	okc_k_lines_b.ID = p_cplv_rec.cle_id
	and okc_line_style_roles.LSE_ID = okc_k_lines_b.LSE_ID
	and okc_line_style_roles.SRE_ID in
	(
		select okc_subclass_roles.ID
		from
			OKC_K_HEADERS_ALL_B -- Modified by jvorugan for Bug:4645341 OKC_K_HEADERS_B
			,okc_subclass_roles
		where
			okc_k_headers_all_b.id = p_cplv_rec.dnz_chr_id
			and okc_subclass_roles.scs_code = okc_k_headers_all_b.scs_code
			and okc_subclass_roles.rle_code = p_cplv_rec.rle_code
			and sysdate between okc_subclass_roles.start_date
			and NVL(okc_subclass_roles.end_date,sysdate)
	)
;

--commenting for Bug 3607178
/*
--
--Bug#3101222
---Check wether it is Service Contrcats or NOT.
CURSOR l_Service_Contract_csr IS
  SELECT 'x'
  FROM OKC_SUBCLASSES_B SCS ,
       OKC_K_HEADERS_B HDR
WHERE SCS.CODE = HDR.SCS_CODE
  AND SCS.CLS_CODE = 'SERVICE'
  AND HDR.ID = p_cplv_rec.chr_id ;

--Duplicate Party Role Check
--Only for service Contract
CURSOR l_Duplicate_role_csr IS
  SELECT 'x'
  FROM OKC_K_PARTY_ROLES_B PARTY
  WHERE PARTY.DNZ_CHR_ID = p_cplv_rec.chr_id
    AND PARTY.CLE_ID IS NULL
    AND PARTY.RLE_CODE = p_cplv_rec.rle_code ;
--Bug#3101222 */
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('2300: Entered validate_rle_code', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
--1
  if (p_cplv_rec.rle_code = OKC_API.G_MISS_CHAR) then
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
--2
  if (p_cplv_rec.rle_code is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RLE_CODE');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
--3

  x_return_status := OKC_UTIL.check_lookup_code('OKC_ROLE',p_cplv_rec.rle_code);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
--4
  if (p_cplv_rec.chr_id is not NULL and p_cplv_rec.chr_id <> OKC_API.G_MISS_NUM) then
    open chr_csr;
    fetch chr_csr into l_dummy_var;
    close chr_csr;
    if (l_dummy_var = '?') then
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE');
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;
  end if;
--5
  if (p_cplv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
     IF (l_debug = 'Y') THEN
        okc_debug.Reset_Indentation;
     END IF;
	return;
  end if;
  if (p_cplv_rec.cle_id is not NULL and p_cplv_rec.cle_id <> OKC_API.G_MISS_NUM) then
    open cle_csr;
    fetch cle_csr into l_dummy_var;
    close cle_csr;
    if (l_dummy_var = '?') then
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE');
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;
  end if;
--end

--commenting for Bug 3607178
/*
--BUG#3101222

	  l_dummy_var   := '?';
       open  l_Service_Contract_csr;
       fetch l_Service_Contract_csr into l_dummy_var;
       close l_Service_Contract_csr;

	  -- l_dummy_var='x', Then it is a Service Contract.
	  IF (l_dummy_var = 'x')   THEN
		 IF (p_cplv_rec.rle_code <> OKC_API.G_MISS_CHAR OR p_cplv_rec.rle_code IS NOT NULL) THEN
			l_dummy_var   := '?'; --resetting the contents
			OPEN  l_Duplicate_role_csr;
			feTCH l_Duplicate_role_csr INTO l_dummy_var;
			CLOSE l_Duplicate_role_csr ;
			IF l_dummy_var = 'x'  THEN
			   OKC_API.set_message(G_APP_NAME, 'OKC_DUPLICATE_PARTY_ROLE');
			   x_return_status := OKC_API.G_RET_STS_ERROR;
			   raise G_EXCEPTION_HALT_VALIDATION;
               END IF;
            END IF;
        END IF;
--BUG#3101222
*/
 IF (l_debug = 'Y') THEN
    okc_debug.log('2400: Leaving validate_rle_code', 2);
    okc_debug.Reset_Indentation;
 END IF;

exception
  when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Exiting validate_rle_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_rle_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if chr_csr%ISOPEN then
      close chr_csr;
    end if;
    if cle_csr%ISOPEN then
      close cle_csr;
    end if;
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_rle_code;

-- Start of comments
--
-- Procedure Name  : validate_small_business_flag
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_small_business_flag(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('2700: Entered validate_small_business_flag', 2);
    END IF;

  if (P_CPLV_REC.small_business_flag in ('Y','N',OKC_API.G_MISS_CHAR)
      or  P_CPLV_REC.small_business_flag is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  else
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SMALL_BUSINESS_FLAG');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2750: Leaving validate_small_bussiness_flag', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_small_business_flag;

-- Start of comments
--
-- Procedure Name  : validate_women_owned_flag
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_women_owned_flag(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('2800: Entered validate_women_owned_flag', 2);
    END IF;

  if (P_CPLV_REC.women_owned_flag in ('Y','N',OKC_API.G_MISS_CHAR)
      or  P_CPLV_REC.women_owned_flag is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  else
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'WOMEN_OWNED_FLAG');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2850: Leaving validate_women_owned_flag', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_women_owned_flag;


-- Start of comments
--
-- Procedure Name  : validate_JTOT_OBJECT1_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_JTOT_OBJECT1_CODE(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	cplv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
cursor l_object1_csr is
select '!'
from
	okc_role_sources RS
	,OKC_K_HEADERS_ALL_B KH -- Modified by jvorugan for Bug:4645341 okc_k_headers_b KH
where
	RS.rle_code = p_cplv_rec.rle_code
	and RS.jtot_object_code = p_cplv_rec.jtot_object1_code
	and sysdate >= RS.start_date
	and (RS.end_date is NULL or RS.end_date>=sysdate)
	and KH.ID = p_cplv_rec.DNZ_CHR_ID
	and RS.BUY_OR_SELL = KH.BUY_OR_SELL
;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('2900: Entered validate_JTOT_OBJECT1_CODE', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_cplv_rec.jtot_object1_code is NULL) then
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
--
  open l_object1_csr;
  fetch l_object1_csr into l_dummy_var;
  close l_object1_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Leaving validate_JTOT_OBJECT1_CODE', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting validate_JTOT_OBJECT1_CODE:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_JTOT_OBJECT1_CODE;

-- Start of comments
--
-- Procedure Name  : validate_object1_id1
-- Description     :  to be called from validate record
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_object1_id1(x_return_status OUT NOCOPY VARCHAR2,
                               p_cplv_rec      IN	cplv_rec_TYPE) is
l_dummy_var                     VARCHAR2(1) := '?';
L_FROM_TABLE    		VARCHAR2(200);
L_WHERE_CLAUSE                  VARCHAR2(2000);

cursor l_object1_csr is
select
	from_table
	,trim(where_clause) where_clause
from
	jtf_objects_vl OB
where
	OB.OBJECT_CODE = p_cplv_rec.jtot_object1_code;

e_no_data_found EXCEPTION;
PRAGMA EXCEPTION_INIT(e_no_data_found,100);
e_too_many_rows EXCEPTION;
PRAGMA EXCEPTION_INIT(e_too_many_rows,-1422);
e_source_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_source_not_exists,-942);
e_source_not_exists1 EXCEPTION;
PRAGMA EXCEPTION_INIT(e_source_not_exists1,-903);
e_column_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_column_not_exists,-904);


begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('3200: Entered validate_object1_id1', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_cplv_rec.jtot_object1_code is NULL) then
     IF (l_debug = 'Y') THEN
        okc_debug.log('3300: Leaving validate_object1_id1', 2);
        okc_debug.Reset_Indentation;
     END IF;
    return;
  end if;
  if (p_cplv_rec.object1_id1 = OKC_API.G_MISS_CHAR or p_cplv_rec.object1_id1 is NULL) then
     IF (l_debug = 'Y') THEN
        okc_debug.log('3300: Leaving validate_object1_id1', 2);
        okc_debug.Reset_Indentation;
     END IF;
    return;
  end if;
  open l_object1_csr;
  fetch l_object1_csr into l_from_table, l_where_clause;
  close l_object1_csr;
  if (l_where_clause is not null) then
	l_where_clause := ' and '||l_where_clause;
  end if;
  EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
	into l_dummy_var
	USING p_cplv_rec.object1_id1, p_cplv_rec.object1_id2;

IF (l_debug = 'Y') THEN
   okc_debug.log('3300: Leaving validate_object1_id1', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when e_source_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_object1_id1:e_source_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_source_not_exists1 then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Exiting validate_object1_id1:e_source_not_exists1 Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Exiting validate_object1_id1:e_column_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Exiting validate_object1_id1:e_no_data_found Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME , 'OKC_INVALID_PARTY');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_too_many_rows then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Exiting validate_object1_id1:e_too_many_rows Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Exiting validate_object1_id1:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_object1_id1;

-- Start of comments
--
-- Procedure Name  : validate_dnz_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cplv_rec	  IN	CPLV_REC_TYPE) is
l_dummy varchar2(1) := '?';
cursor Kt_Hr_Mj_Vr is
    select '!'
    from okc_k_headers_all_b -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b
    where id = p_cplv_rec.dnz_chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('4000: Entered validate_dnz_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cplv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
  if (p_cplv_rec.dnz_chr_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
     IF (l_debug = 'Y') THEN
        okc_debug.Reset_Indentation;
     END IF;
	return;
  end if;
  open Kt_Hr_Mj_Vr;
  fetch Kt_Hr_Mj_Vr into l_dummy;
  close Kt_Hr_Mj_Vr;
  if (l_dummy='?') then
  	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
     x_return_status := OKC_API.G_RET_STS_ERROR;
     IF (l_debug = 'Y') THEN
        okc_debug.Reset_Indentation;
     END IF;
	return;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4100: Leaving validate_dnz_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Exiting validate_dnz_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_dnz_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_primary_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_primary_yn(x_return_status OUT NOCOPY   VARCHAR2,
                                p_cplv_rec      IN    cplv_rec_type) IS

  l_dummy varchar2(1) := '?';

  CURSOR l_party_csr IS
  SELECT '!'
  FROM OKC_K_PARTY_ROLES_B
  WHERE Id  <>  NVL(p_cplv_rec.id,-99999)
  AND   dnz_chr_id =  p_cplv_rec.dnz_chr_id
  AND   cle_id     IS NULL
  AND   primary_yn = 'Y';



  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
   	 okc_debug.log('4150: Entered validate_primary_yn', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    IF (p_cplv_rec.primary_yn IS NOT NULL AND
        p_cplv_rec.primary_yn <> OKC_API.G_MISS_CHAR) THEN

        IF p_cplv_rec.primary_yn NOT IN ('Y','N') Then
                 OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                     p_msg_name     => g_invalid_value,
                                     p_token1       => g_col_name_token,
                                     p_token1_value => 'PRIMARY_YN');
                    -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt validation
           raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;  -- end of (p_cplv_rec.primary_yn <> OKC_API.G_MISS_CHAR OR ---

    IF (p_cplv_rec.primary_yn = 'Y') THEN
       OPEN  l_party_csr;
       FETCH l_party_csr INTO l_dummy;
       CLOSE l_party_csr;
       IF (l_dummy='!') THEN
          OKC_API.set_message(G_APP_NAME,'OKC_PRIMARY_PARTY_ERROR');
          x_return_status := OKC_API.G_RET_STS_ERROR;
          IF (l_debug = 'Y') THEN
             okc_debug.Reset_Indentation;
          END IF;
          RETURN;
       END IF;
     END IF;    --end of (p_cplv_rec.primary_yn = 'Y')
     IF (l_debug = 'Y') THEN
        okc_debug.log('4160: Leaving validate_primary_yn', 2);
        okc_debug.Reset_Indentation;
     END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
  IF (l_debug = 'Y') THEN
     okc_debug.log('4170: Exiting validate_primary_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
     okc_debug.Reset_Indentation;
  END IF;

  -- no processing necessary; validation can continue with next column
  null;
    when OTHERS then
    IF (l_debug = 'Y') THEN
       okc_debug.log('4180: Exiting validate_primary_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
	  OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
					  p_msg_name        => g_unexpected_error,
					  p_token1          => g_sqlcode_token,
					  p_token1_value    => sqlcode,
					  p_token2          => g_sqlerrm_token,
					  p_token2_value    => sqlerrm);

       -- notify caller of an error as UNEXPETED error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_primary_yn;

/*+++++++++++++End of hand code +++++++++++++++++++*/
  -------------------------------------------------
  -- Validate_Attributes for:OKC_K_PARTY_ROLES_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cplv_rec IN  cplv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('4300: Entered Validate_Attributes', 2);
    END IF;

    IF p_cplv_rec.id = OKC_API.G_MISS_NUM OR
       p_cplv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cplv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cplv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cplv_rec.rle_code = OKC_API.G_MISS_CHAR OR
          p_cplv_rec.rle_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rle_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cplv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_cplv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('4100: Leaving validate_Attributes', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_return_status);

  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_cpl_id(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_chr_id(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_cle_id(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
/* --> validate record
    validate_rle_code(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
*/
--
    validate_small_business_flag(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_women_owned_flag(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_dnz_chr_id(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_primary_yn(x_return_status => l_return_status,
				    p_cplv_rec      => p_cplv_rec);
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
    	   return OKC_API.G_RET_STS_UNEXP_ERROR;
    end If;
    If (l_return_status = OKC_API.G_RET_STS_ERROR
	   and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
    	   x_return_status := OKC_API.G_RET_STS_ERROR;
    end If;

    return x_return_status;

IF (l_debug = 'Y') THEN
   okc_debug.log('4150: Leaving validate_Attributes', 2);
   okc_debug.Reset_Indentation;
END IF;

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
  ---------------------------------------------
  -- Validate_Record for:OKC_K_PARTY_ROLES_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_cplv_rec IN cplv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
--+UK
  l_unq_tbl OKC_UTIL.unq_tbl_type;

 -- indirection
 l_buy_or_sell               varchar2(3);
 l_access_level              varchar2(1);

 cursor c_buy_or_sell is
  select buy_or_sell
  from okc_k_headers_all_b  -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b
  where id = p_cplv_rec.dnz_chr_id;

 cursor c_access_level(p_intent varchar2) is
  select access_level
  from okc_role_sources
  where rle_code = p_cplv_rec.rle_code
    and buy_or_sell = p_intent;
 --


  cursor c1(p_chr_id okc_k_party_roles_b.chr_id%TYPE,
            p_rle_code okc_k_party_roles_b.rle_code%TYPE,
            p_jtot_object1_code okc_k_party_roles_b.jtot_object1_code%TYPE,
            p_object1_id1 okc_k_party_roles_b.object1_id1%TYPE,
            p_object1_id2 okc_k_party_roles_b.object1_id2%TYPE) is
  select id
    from okc_k_party_roles_b
   where chr_id = p_chr_id
     and rle_code = p_rle_code
     and jtot_object1_code = p_jtot_object1_code
     and object1_id1 = p_object1_id1
     and object1_id2 = p_object1_id2;

  cursor c2(p_cle_id okc_k_party_roles_b.cle_id%TYPE,
            p_rle_code okc_k_party_roles_b.rle_code%TYPE,
            p_jtot_object1_code okc_k_party_roles_b.jtot_object1_code%TYPE,
            p_object1_id1 okc_k_party_roles_b.object1_id1%TYPE,
            p_object1_id2 okc_k_party_roles_b.object1_id2%TYPE) is
  select id
    from okc_k_party_roles_b
   where cle_id = p_cle_id
     and rle_code = p_rle_code
     and jtot_object1_code = p_jtot_object1_code
     and object1_id1 = p_object1_id1
     and object1_id2 = p_object1_id2;

  l_id Number;
  l_row_found Boolean := False;
--+UK
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('5000: Entered Validate_Record', 2);
    END IF;
      if (p_cplv_rec.chr_id IS NULL and p_cplv_rec.cle_id IS NULL) then
        OKC_API.set_message(g_app_name,g_required_value,g_col_name_token,'CHR_ID, CLE_ID');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
      if ((p_cplv_rec.chr_id IS NOT NULL and p_cplv_rec.chr_id <> OKC_API.G_MISS_NUM) and
          (p_cplv_rec.cle_id IS NOT NULL and p_cplv_rec.cle_id <> OKC_API.G_MISS_NUM)) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID, CLE_ID');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_rle_code(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
  -- indirection
  Open c_buy_or_sell;
  Fetch c_buy_or_sell Into l_buy_or_sell;
  Close c_buy_or_sell;

  Open c_access_level(l_buy_or_sell);
  Fetch c_access_level Into l_access_level;
  Close c_access_level;

  If l_access_level = 'U' Then -- if user defined

    validate_JTOT_OBJECT1_CODE(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      IF (l_debug = 'Y') THEN
          okc_debug.log('5020: Exiting Validate_jtot_object1_code in validate_record:unexp err', 2);
          okc_debug.Reset_Indentation;
      END IF;
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_object1_id1(x_return_status => l_return_status,
                    p_cplv_rec      => p_cplv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       IF (l_debug = 'Y') THEN
           okc_debug.log('5030: Exiting Validate_object1_id1 in validate_record:unexp err', 2);
           okc_debug.Reset_Indentation;
      END IF;
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
  End If; -- if user defined
--
--+UK
    If p_cplv_rec.chr_id IS Not Null and p_cplv_rec.chr_id <> OKC_API.G_MISS_NUM Then
      Open c1(p_cplv_rec.chr_id,
              p_cplv_rec.rle_code,
              p_cplv_rec.jtot_object1_code,
              p_cplv_rec.object1_id1,
              p_cplv_rec.object1_id2);
      Fetch c1 into l_id;
      l_row_found := c1%FOUND;
      Close c1;
    Else
      Open c2(p_cplv_rec.cle_id,
              p_cplv_rec.rle_code,
              p_cplv_rec.jtot_object1_code,
              p_cplv_rec.object1_id1,
              p_cplv_rec.object1_id2);
      Fetch c2 into l_id;
      l_row_found := c2%FOUND;
      Close c2;
    End If;
    If l_row_found Then
	 If l_id <> p_cplv_rec.id Then
        OKC_API.set_message(G_APP_NAME, 'OKC_DUPLICATE_PARTY');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    -- Bug 1631244 : The following code commented out since it was not using bind
    -- variables and parsing was taking place for every party added. Replaced with
    -- explicit cursor as above.
    /* l_unq_tbl(1).p_col_name := 'RLE_CODE';
    l_unq_tbl(1).p_col_val  := p_cplv_rec.RLE_CODE;
    l_unq_tbl(2).p_col_name := 'CHR_ID';
    l_unq_tbl(2).p_col_val  := p_cplv_rec.CHR_ID;
    l_unq_tbl(3).p_col_name := 'JTOT_OBJECT1_CODE';
    l_unq_tbl(3).p_col_val  := p_cplv_rec.JTOT_OBJECT1_CODE;
    l_unq_tbl(4).p_col_name := 'OBJECT1_ID1';
    l_unq_tbl(4).p_col_val  := p_cplv_rec.OBJECT1_ID1;
    l_unq_tbl(5).p_col_name := 'OBJECT1_ID2';
    l_unq_tbl(5).p_col_val  := p_cplv_rec.OBJECT1_ID2;
    l_unq_tbl(6).p_col_name := 'CLE_ID';
    l_unq_tbl(6).p_col_val  := p_cplv_rec.CLE_ID;
    OKC_UTIL.Check_Comp_Unique(
    p_view_name  => 'OKC_K_PARTY_ROLES_V',
    p_col_tbl	 => l_unq_tbl,
    p_id         => p_cplv_rec.ID,
    x_return_status  => l_return_status);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if; */
--+UK
    IF (l_debug = 'Y') THEN
        okc_debug.log('5100: Leaving Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;
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
    p_from	IN cplv_rec_type,
    p_to	IN OUT NOCOPY cpl_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.rle_code := p_from.rle_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.code := p_from.code;
    p_to.facility := p_from.facility;
    p_to.minority_group_lookup_code := p_from.minority_group_lookup_code;
    p_to.small_business_flag := p_from.small_business_flag;
    p_to.women_owned_flag := p_from.women_owned_flag;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.primary_yn        := p_from.primary_yn;
    p_to.cust_acct_id      := p_from.cust_acct_id;
    p_to.bill_to_site_use_id:= p_from.bill_to_site_use_id;
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
    p_from	IN cpl_rec_type,
    p_to	IN OUT NOCOPY cplv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.rle_code := p_from.rle_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.code := p_from.code;
    p_to.facility := p_from.facility;
    p_to.minority_group_lookup_code := p_from.minority_group_lookup_code;
    p_to.small_business_flag := p_from.small_business_flag;
    p_to.women_owned_flag := p_from.women_owned_flag;
    p_to.last_update_login := p_from.last_update_login;
    p_to.primary_yn        := p_from.primary_yn;
    p_to.cust_acct_id        := p_from.cust_acct_id;
    p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
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
    p_from	IN cplv_rec_type,
    p_to	IN OUT NOCOPY okc_k_party_roles_tl_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.cognomen := p_from.cognomen;
    p_to.alias := p_from.alias;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  PROCEDURE migrate (
    p_from	IN okc_k_party_roles_tl_rec_type,
    p_to	IN OUT NOCOPY cplv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.cognomen := p_from.cognomen;
    p_to.alias := p_from.alias;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKC_K_PARTY_ROLES_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cplv_rec                     cplv_rec_type := p_cplv_rec;
    l_cpl_rec                      cpl_rec_type;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('5200: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_cplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cplv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5500: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5600: Exiting validate_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL validate_row for:CPLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('5700: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cplv_tbl.COUNT > 0) THEN
      i := p_cplv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cplv_rec                     => p_cplv_tbl(i));
        EXIT WHEN (i = p_cplv_tbl.LAST);
        i := p_cplv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('5800: Leaving validate_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6000: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6100: Exiting validate_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- insert_row for:OKC_K_PARTY_ROLES_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_rec                      IN cpl_rec_type,
    x_cpl_rec                      OUT NOCOPY cpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpl_rec                      cpl_rec_type := p_cpl_rec;
    l_def_cpl_rec                  cpl_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cpl_rec IN  cpl_rec_type,
      x_cpl_rec OUT NOCOPY cpl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_application_id number; /*bug6911126*/
    BEGIN

      x_cpl_rec := p_cpl_rec;

      /*changes made for bug6911126*/
      SELECT application_id
         INTO l_application_id
        FROM OKC_K_HEADERS_ALL_B
       WHERE id = x_cpl_rec.dnz_chr_id;

      IF l_application_id = 540 THEN
        IF x_cpl_rec.orig_system_id1 = OKC_API.G_MISS_NUM THEN
          x_cpl_rec.orig_system_id1 := NULL;
        END IF;
	IF x_cpl_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR THEN
          x_cpl_rec.orig_system_reference1 := NULL;
        END IF;
        IF x_cpl_rec.orig_system_source_code = OKC_API.G_MISS_CHAR THEN
          x_cpl_rec.orig_system_source_code := NULL;
        END IF;
      END IF;
      /*end of changes for bug6911126*/

      x_cpl_rec.primary_yn := UPPER(x_cpl_rec.PRIMARY_YN);
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('6300: Entered insert_row', 2);
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
      p_cpl_rec,                         -- IN
      l_cpl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_PARTY_ROLES_B(
        id,
        cpl_id,
        chr_id,
        cle_id,
        dnz_chr_id,
        rle_code,
        object1_id1,
        object1_id2,
        JTOT_OBJECT1_CODE,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        code,
        facility,
        minority_group_lookup_code,
        small_business_flag,
        women_owned_flag,
        last_update_login,
	   primary_yn,
        cust_acct_id,
        bill_to_site_use_id,
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
-- R12 Data Model Changes 4485150 Start
        orig_system_id1,
        orig_system_reference1,
        orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
      VALUES (
        l_cpl_rec.id,
        l_cpl_rec.cpl_id,
        l_cpl_rec.chr_id,
        l_cpl_rec.cle_id,
        l_cpl_rec.dnz_chr_id,
        l_cpl_rec.rle_code,
        l_cpl_rec.object1_id1,
        l_cpl_rec.object1_id2,
        l_cpl_rec.JTOT_OBJECT1_CODE,
        l_cpl_rec.object_version_number,
        l_cpl_rec.created_by,
        l_cpl_rec.creation_date,
        l_cpl_rec.last_updated_by,
        l_cpl_rec.last_update_date,
        l_cpl_rec.code,
        l_cpl_rec.facility,
        l_cpl_rec.minority_group_lookup_code,
        l_cpl_rec.small_business_flag,
        l_cpl_rec.women_owned_flag,
        l_cpl_rec.last_update_login,
	   l_cpl_rec.primary_yn,
	   l_cpl_rec.cust_acct_id,
	   l_cpl_rec.bill_to_site_use_id,
        l_cpl_rec.attribute_category,
        l_cpl_rec.attribute1,
        l_cpl_rec.attribute2,
        l_cpl_rec.attribute3,
        l_cpl_rec.attribute4,
        l_cpl_rec.attribute5,
        l_cpl_rec.attribute6,
        l_cpl_rec.attribute7,
        l_cpl_rec.attribute8,
        l_cpl_rec.attribute9,
        l_cpl_rec.attribute10,
        l_cpl_rec.attribute11,
        l_cpl_rec.attribute12,
        l_cpl_rec.attribute13,
        l_cpl_rec.attribute14,
        l_cpl_rec.attribute15,
-- R12 Data Model Changes 4485150 Start
        l_cpl_rec.orig_system_id1,
        l_cpl_rec.orig_system_reference1,
        l_cpl_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_cpl_rec := l_cpl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6600: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6700: Exiting insert_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- insert_row for:OKC_K_PARTY_ROLES_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type,
    x_okc_k_party_roles_tl_rec     OUT NOCOPY okc_k_party_roles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type := p_okc_k_party_roles_tl_rec;
    ldefokckpartyrolestlrec        okc_k_party_roles_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_party_roles_tl_rec IN  okc_k_party_roles_tl_rec_type,
      x_okc_k_party_roles_tl_rec OUT NOCOPY okc_k_party_roles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_k_party_roles_tl_rec := p_okc_k_party_roles_tl_rec;
      x_okc_k_party_roles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_k_party_roles_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('6900: Entered insert_row', 2);
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
      p_okc_k_party_roles_tl_rec,        -- IN
      l_okc_k_party_roles_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_k_party_roles_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_K_PARTY_ROLES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          cognomen,
          alias,
          last_update_login)
        VALUES (
          l_okc_k_party_roles_tl_rec.id,
          l_okc_k_party_roles_tl_rec.language,
          l_okc_k_party_roles_tl_rec.source_lang,
          l_okc_k_party_roles_tl_rec.sfwt_flag,
          l_okc_k_party_roles_tl_rec.created_by,
          l_okc_k_party_roles_tl_rec.creation_date,
          l_okc_k_party_roles_tl_rec.last_updated_by,
          l_okc_k_party_roles_tl_rec.last_update_date,
          l_okc_k_party_roles_tl_rec.cognomen,
          l_okc_k_party_roles_tl_rec.alias,
          l_okc_k_party_roles_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_k_party_roles_tl_rec := l_okc_k_party_roles_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('7000: Leaving insert_row', 2);
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
  -- insert_row for:OKC_K_PARTY_ROLES_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cplv_rec                     cplv_rec_type;
    l_def_cplv_rec                 cplv_rec_type;
    l_cpl_rec                      cpl_rec_type;
    lx_cpl_rec                     cpl_rec_type;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
    lx_okc_k_party_roles_tl_rec    okc_k_party_roles_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cplv_rec	IN cplv_rec_type
    ) RETURN cplv_rec_type IS
      l_cplv_rec	cplv_rec_type := p_cplv_rec;
    BEGIN

      l_cplv_rec.CREATION_DATE := SYSDATE;
      l_cplv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cplv_rec.LAST_UPDATE_DATE := l_cplv_rec.CREATION_DATE;
      l_cplv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cplv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_cplv_rec);

    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cplv_rec IN  cplv_rec_type,
      x_cplv_rec OUT NOCOPY cplv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cplv_rec := p_cplv_rec;
      x_cplv_rec.OBJECT_VERSION_NUMBER := 1;
      x_cplv_rec.SFWT_FLAG := 'N';

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('7600: Entered insert_row', 2);
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
    l_cplv_rec := null_out_defaults(p_cplv_rec);
    -- Set primary key value
    l_cplv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cplv_rec,                        -- IN
      l_def_cplv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cplv_rec := fill_who_columns(l_def_cplv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cplv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cplv_rec, l_cpl_rec);
    migrate(l_def_cplv_rec, l_okc_k_party_roles_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpl_rec,
      lx_cpl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cpl_rec, l_def_cplv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_party_roles_tl_rec,
      lx_okc_k_party_roles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_party_roles_tl_rec, l_def_cplv_rec);
    -- Set OUT values
    x_cplv_rec := l_def_cplv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7900: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8000: Exiting insert_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL insert_row for:CPLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('8100: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cplv_tbl.COUNT > 0) THEN
      i := p_cplv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cplv_rec                     => p_cplv_tbl(i),
          x_cplv_rec                     => x_cplv_tbl(i));
        EXIT WHEN (i = p_cplv_tbl.LAST);
        i := p_cplv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('8200: Leaving insert_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8400: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8500: Exiting insert_row:OTHERS Exception', 2);
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
  --------------------------------------
  -- lock_row for:OKC_K_PARTY_ROLES_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_rec                      IN cpl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cpl_rec IN cpl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_PARTY_ROLES_B
     WHERE ID = p_cpl_rec.id
       AND OBJECT_VERSION_NUMBER = p_cpl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cpl_rec IN cpl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_PARTY_ROLES_B
    WHERE ID = p_cpl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_PARTY_ROLES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_PARTY_ROLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('8600: Entered lock_row', 2);
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
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('8700: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_cpl_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cpl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cpl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cpl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9300: Exiting lock_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- lock_row for:OKC_K_PARTY_ROLES_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_k_party_roles_tl_rec IN okc_k_party_roles_tl_rec_type) IS
    SELECT *
      FROM OKC_K_PARTY_ROLES_TL
     WHERE ID = p_okc_k_party_roles_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('9400: Entered lock_row', 2);
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
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('9500: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_okc_k_party_roles_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

 IF (l_debug = 'Y') THEN
    okc_debug.log('9600: Exiting lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Exiting lock_row:E_Resource_Busy Exception', 2);
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
    okc_debug.log('9800: Exiting lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10100: Exiting lock_row:OTHERS Exception', 2);
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
  -- lock_row for:OKC_K_PARTY_ROLES_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpl_rec                      cpl_rec_type;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('10200: Entered lock_row', 2);
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
    migrate(p_cplv_rec, l_cpl_rec);
    migrate(p_cplv_rec, l_okc_k_party_roles_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpl_rec
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
      l_okc_k_party_roles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10500: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10600: Exiting lock_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL lock_row for:CPLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('10700: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cplv_tbl.COUNT > 0) THEN
      i := p_cplv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cplv_rec                     => p_cplv_tbl(i));
        EXIT WHEN (i = p_cplv_tbl.LAST);
        i := p_cplv_tbl.NEXT(i);
      END LOOP;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('10800: Leaving lock_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11100: Exiting lock_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- update_row for:OKC_K_PARTY_ROLES_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_rec                      IN cpl_rec_type,
    x_cpl_rec                      OUT NOCOPY cpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpl_rec                      cpl_rec_type := p_cpl_rec;
    l_def_cpl_rec                  cpl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cpl_rec	IN cpl_rec_type,
      x_cpl_rec	OUT NOCOPY cpl_rec_type
    ) RETURN VARCHAR2 IS
      l_cpl_rec                      cpl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('11200: Entered populate_new_record', 2);
    END IF;

      x_cpl_rec := p_cpl_rec;
      -- Get current database values
      l_cpl_rec := get_rec(p_cpl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cpl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.id := l_cpl_rec.id;
      END IF;
      IF (x_cpl_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.cpl_id := l_cpl_rec.cpl_id;
      END IF;
      IF (x_cpl_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.chr_id := l_cpl_rec.chr_id;
      END IF;
      IF (x_cpl_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.cle_id := l_cpl_rec.cle_id;
      END IF;
      IF (x_cpl_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.dnz_chr_id := l_cpl_rec.dnz_chr_id;
      END IF;
      IF (x_cpl_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.rle_code := l_cpl_rec.rle_code;
      END IF;
      IF (x_cpl_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.object1_id1 := l_cpl_rec.object1_id1;
      END IF;
      IF (x_cpl_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.object1_id2 := l_cpl_rec.object1_id2;
      END IF;
      IF (x_cpl_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.JTOT_OBJECT1_CODE := l_cpl_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_cpl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.object_version_number := l_cpl_rec.object_version_number;
      END IF;
      IF (x_cpl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.created_by := l_cpl_rec.created_by;
      END IF;
      IF (x_cpl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpl_rec.creation_date := l_cpl_rec.creation_date;
      END IF;
      IF (x_cpl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.last_updated_by := l_cpl_rec.last_updated_by;
      END IF;
      IF (x_cpl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpl_rec.last_update_date := l_cpl_rec.last_update_date;
      END IF;
      IF (x_cpl_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.code := l_cpl_rec.code;
      END IF;
      IF (x_cpl_rec.facility = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.facility := l_cpl_rec.facility;
      END IF;
      IF (x_cpl_rec.minority_group_lookup_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.minority_group_lookup_code := l_cpl_rec.minority_group_lookup_code;
      END IF;
      IF (x_cpl_rec.small_business_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.small_business_flag := l_cpl_rec.small_business_flag;
      END IF;
      IF (x_cpl_rec.women_owned_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.women_owned_flag := l_cpl_rec.women_owned_flag;
      END IF;
      IF (x_cpl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.last_update_login := l_cpl_rec.last_update_login;
      END IF;
      IF (x_cpl_rec.primary_yn = OKC_API.G_MISS_CHAR)
      THEN
	   x_cpl_rec.primary_yn := l_cpl_rec.primary_yn;
      END IF;
      IF (x_cpl_rec.cust_acct_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.cust_acct_id := l_cpl_rec.cust_acct_id;
      END IF;
      IF (x_cpl_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpl_rec.bill_to_site_use_id := l_cpl_rec.bill_to_site_use_id;
      END IF;
      IF (x_cpl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute_category := l_cpl_rec.attribute_category;
      END IF;
      IF (x_cpl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute1 := l_cpl_rec.attribute1;
      END IF;
      IF (x_cpl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute2 := l_cpl_rec.attribute2;
      END IF;
      IF (x_cpl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute3 := l_cpl_rec.attribute3;
      END IF;
      IF (x_cpl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute4 := l_cpl_rec.attribute4;
      END IF;
      IF (x_cpl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute5 := l_cpl_rec.attribute5;
      END IF;
      IF (x_cpl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute6 := l_cpl_rec.attribute6;
      END IF;
      IF (x_cpl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute7 := l_cpl_rec.attribute7;
      END IF;
      IF (x_cpl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute8 := l_cpl_rec.attribute8;
      END IF;
      IF (x_cpl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute9 := l_cpl_rec.attribute9;
      END IF;
      IF (x_cpl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute10 := l_cpl_rec.attribute10;
      END IF;
      IF (x_cpl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute11 := l_cpl_rec.attribute11;
      END IF;
      IF (x_cpl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute12 := l_cpl_rec.attribute12;
      END IF;
      IF (x_cpl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute13 := l_cpl_rec.attribute13;
      END IF;
      IF (x_cpl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute14 := l_cpl_rec.attribute14;
      END IF;
      IF (x_cpl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.attribute15 := l_cpl_rec.attribute15;
      END IF;

-- R12 Data Model Changes 4485150 Start
      IF (x_cpl_rec.orig_system_id1 = OKC_API.G_MISS_NUM)  /* mmadhavi 4485150 : it is G_MISS_NUM */
      THEN
        x_cpl_rec.orig_system_id1 := l_cpl_rec.orig_system_id1;
      END IF;
      IF (x_cpl_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.orig_system_reference1 := l_cpl_rec.orig_system_reference1;
      END IF;
      IF (x_cpl_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cpl_rec.orig_system_source_code := l_cpl_rec.orig_system_source_code;
      END IF;
-- R12 Data Model Changes 4485150 End

IF (l_debug = 'Y') THEN
   okc_debug.log('11350: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cpl_rec IN  cpl_rec_type,
      x_cpl_rec OUT NOCOPY cpl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cpl_rec := p_cpl_rec;
      RETURN(l_return_status);

    END Set_Attributes;
-------------------------------------
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
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
      p_cpl_rec,                         -- IN
      l_cpl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cpl_rec, l_def_cpl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_PARTY_ROLES_B
    SET CPL_ID = l_def_cpl_rec.cpl_id,CHR_ID = l_def_cpl_rec.chr_id,
        CLE_ID = l_def_cpl_rec.cle_id,
        DNZ_CHR_ID = l_def_cpl_rec.dnz_chr_id,
        RLE_CODE = l_def_cpl_rec.rle_code,
        OBJECT1_ID1 = l_def_cpl_rec.object1_id1,
        OBJECT1_ID2 = l_def_cpl_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_cpl_rec.JTOT_OBJECT1_CODE,
        OBJECT_VERSION_NUMBER = l_def_cpl_rec.object_version_number,
        CREATED_BY = l_def_cpl_rec.created_by,
        CREATION_DATE = l_def_cpl_rec.creation_date,
        LAST_UPDATED_BY = l_def_cpl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cpl_rec.last_update_date,
        CODE = l_def_cpl_rec.code,
        FACILITY = l_def_cpl_rec.facility,
        MINORITY_GROUP_LOOKUP_CODE = l_def_cpl_rec.minority_group_lookup_code,
        SMALL_BUSINESS_FLAG = l_def_cpl_rec.small_business_flag,
        WOMEN_OWNED_FLAG = l_def_cpl_rec.women_owned_flag,
        LAST_UPDATE_LOGIN = l_def_cpl_rec.last_update_login,
	   PRIMARY_YN        = l_def_cpl_rec.primary_yn,
	   CUST_ACCT_ID        = l_def_cpl_rec.cust_acct_id,
	   BILL_TO_SITE_USE_ID    = l_def_cpl_rec.bill_to_site_use_id,
        ATTRIBUTE_CATEGORY = l_def_cpl_rec.attribute_category,
        ATTRIBUTE1 = l_def_cpl_rec.attribute1,
        ATTRIBUTE2 = l_def_cpl_rec.attribute2,
        ATTRIBUTE3 = l_def_cpl_rec.attribute3,
        ATTRIBUTE4 = l_def_cpl_rec.attribute4,
        ATTRIBUTE5 = l_def_cpl_rec.attribute5,
        ATTRIBUTE6 = l_def_cpl_rec.attribute6,
        ATTRIBUTE7 = l_def_cpl_rec.attribute7,
        ATTRIBUTE8 = l_def_cpl_rec.attribute8,
        ATTRIBUTE9 = l_def_cpl_rec.attribute9,
        ATTRIBUTE10 = l_def_cpl_rec.attribute10,
        ATTRIBUTE11 = l_def_cpl_rec.attribute11,
        ATTRIBUTE12 = l_def_cpl_rec.attribute12,
        ATTRIBUTE13 = l_def_cpl_rec.attribute13,
        ATTRIBUTE14 = l_def_cpl_rec.attribute14,
        ATTRIBUTE15 = l_def_cpl_rec.attribute15,
-- R12 Data Model Changes 4485150 Start
        ORIG_SYSTEM_ID1	= l_def_cpl_rec.orig_system_id1,
        ORIG_SYSTEM_REFERENCE1	= l_def_cpl_rec.orig_system_reference1,
        ORIG_SYSTEM_SOURCE_CODE	= l_def_cpl_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_cpl_rec.id;

    x_cpl_rec := l_def_cpl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Leaving update_row', 2);
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
  -----------------------------------------
  -- update_row for:OKC_K_PARTY_ROLES_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type,
    x_okc_k_party_roles_tl_rec     OUT NOCOPY okc_k_party_roles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type := p_okc_k_party_roles_tl_rec;
    ldefokckpartyrolestlrec        okc_k_party_roles_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_k_party_roles_tl_rec	IN okc_k_party_roles_tl_rec_type,
      x_okc_k_party_roles_tl_rec	OUT NOCOPY okc_k_party_roles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('11900: Entered populate_new_record', 2);
    END IF;

      x_okc_k_party_roles_tl_rec := p_okc_k_party_roles_tl_rec;
      -- Get current database values
      l_okc_k_party_roles_tl_rec := get_rec(p_okc_k_party_roles_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_party_roles_tl_rec.id := l_okc_k_party_roles_tl_rec.id;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_party_roles_tl_rec.language := l_okc_k_party_roles_tl_rec.language;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_party_roles_tl_rec.source_lang := l_okc_k_party_roles_tl_rec.source_lang;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_party_roles_tl_rec.sfwt_flag := l_okc_k_party_roles_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_party_roles_tl_rec.created_by := l_okc_k_party_roles_tl_rec.created_by;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_k_party_roles_tl_rec.creation_date := l_okc_k_party_roles_tl_rec.creation_date;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_party_roles_tl_rec.last_updated_by := l_okc_k_party_roles_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_k_party_roles_tl_rec.last_update_date := l_okc_k_party_roles_tl_rec.last_update_date;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.cognomen = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_party_roles_tl_rec.cognomen := l_okc_k_party_roles_tl_rec.cognomen;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.alias = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_k_party_roles_tl_rec.alias := l_okc_k_party_roles_tl_rec.alias;
      END IF;
      IF (x_okc_k_party_roles_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_k_party_roles_tl_rec.last_update_login := l_okc_k_party_roles_tl_rec.last_update_login;
      END IF;

   IF (l_debug = 'Y') THEN
      okc_debug.log('11950: Leaving  populate_new_record ', 2);
      okc_debug.Reset_Indentation;
   END IF;

      RETURN(l_return_status);


    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_party_roles_tl_rec IN  okc_k_party_roles_tl_rec_type,
      x_okc_k_party_roles_tl_rec OUT NOCOPY okc_k_party_roles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_k_party_roles_tl_rec := p_okc_k_party_roles_tl_rec;
      x_okc_k_party_roles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_k_party_roles_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('12100: Entered update_row', 2);
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
      p_okc_k_party_roles_tl_rec,        -- IN
      l_okc_k_party_roles_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_k_party_roles_tl_rec, ldefokckpartyrolestlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_PARTY_ROLES_TL
    SET CREATED_BY = ldefokckpartyrolestlrec.created_by,
        CREATION_DATE = ldefokckpartyrolestlrec.creation_date,
        LAST_UPDATED_BY = ldefokckpartyrolestlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokckpartyrolestlrec.last_update_date,
        COGNOMEN = ldefokckpartyrolestlrec.cognomen,
        ALIAS = ldefokckpartyrolestlrec.alias,
        LAST_UPDATE_LOGIN = ldefokckpartyrolestlrec.last_update_login
--+
        ,SOURCE_LANG = ldefokckpartyrolestlrec.SOURCE_LANG
--+
    WHERE ID = ldefokckpartyrolestlrec.id
---      AND SOURCE_LANG = USERENV('LANG');
--+
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
--+
    UPDATE  OKC_K_PARTY_ROLES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokckpartyrolestlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_k_party_roles_tl_rec := ldefokckpartyrolestlrec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12300: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('12400: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('12500: Exiting update_row:OTHERS Exception', 2);
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
  -- update_row for:OKC_K_PARTY_ROLES_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cplv_rec                     cplv_rec_type := p_cplv_rec;
    l_def_cplv_rec                 cplv_rec_type;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
    lx_okc_k_party_roles_tl_rec    okc_k_party_roles_tl_rec_type;
    l_cpl_rec                      cpl_rec_type;
    lx_cpl_rec                     cpl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cplv_rec	IN cplv_rec_type
    ) RETURN cplv_rec_type IS
      l_cplv_rec	cplv_rec_type := p_cplv_rec;
    BEGIN

      l_cplv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cplv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cplv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_cplv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cplv_rec	IN cplv_rec_type,
      x_cplv_rec	OUT NOCOPY cplv_rec_type
    ) RETURN VARCHAR2 IS
      l_cplv_rec                     cplv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('12700: Entered populate_new_record', 2);
    END IF;

      x_cplv_rec := p_cplv_rec;
      -- Get current database values
      l_cplv_rec := get_rec(p_cplv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cplv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.id := l_cplv_rec.id;
      END IF;
      IF (x_cplv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.object_version_number := l_cplv_rec.object_version_number;
      END IF;
      IF (x_cplv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.sfwt_flag := l_cplv_rec.sfwt_flag;
      END IF;
      IF (x_cplv_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.cpl_id := l_cplv_rec.cpl_id;
      END IF;
      IF (x_cplv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.chr_id := l_cplv_rec.chr_id;
      END IF;
      IF (x_cplv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.cle_id := l_cplv_rec.cle_id;
      END IF;
      IF (x_cplv_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.rle_code := l_cplv_rec.rle_code;
      END IF;
      IF (x_cplv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.dnz_chr_id := l_cplv_rec.dnz_chr_id;
      END IF;
      IF (x_cplv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.object1_id1 := l_cplv_rec.object1_id1;
      END IF;
      IF (x_cplv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.object1_id2 := l_cplv_rec.object1_id2;
      END IF;
      IF (x_cplv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.JTOT_OBJECT1_CODE := l_cplv_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_cplv_rec.cognomen = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.cognomen := l_cplv_rec.cognomen;
      END IF;
      IF (x_cplv_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.code := l_cplv_rec.code;
      END IF;
      IF (x_cplv_rec.facility = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.facility := l_cplv_rec.facility;
      END IF;
      IF (x_cplv_rec.minority_group_lookup_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.minority_group_lookup_code := l_cplv_rec.minority_group_lookup_code;
      END IF;
      IF (x_cplv_rec.small_business_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.small_business_flag := l_cplv_rec.small_business_flag;
      END IF;
      IF (x_cplv_rec.women_owned_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.women_owned_flag := l_cplv_rec.women_owned_flag;
      END IF;
      IF (x_cplv_rec.alias = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.alias := l_cplv_rec.alias;
      END IF;
      IF (x_cplv_rec.primary_yn = OKC_API.G_MISS_CHAR)
      THEN
	   x_cplv_rec.primary_yn := l_cplv_rec.primary_yn;
	 END IF;
      IF (x_cplv_rec.cust_acct_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.cust_acct_id := l_cplv_rec.cust_acct_id;
      END IF;
      IF (x_cplv_rec.bill_to_site_use_id = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.bill_to_site_use_id := l_cplv_rec.bill_to_site_use_id;
      END IF;
      IF (x_cplv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute_category := l_cplv_rec.attribute_category;
      END IF;
      IF (x_cplv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute1 := l_cplv_rec.attribute1;
      END IF;
      IF (x_cplv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute2 := l_cplv_rec.attribute2;
      END IF;
      IF (x_cplv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute3 := l_cplv_rec.attribute3;
      END IF;
      IF (x_cplv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute4 := l_cplv_rec.attribute4;
      END IF;
      IF (x_cplv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute5 := l_cplv_rec.attribute5;
      END IF;
      IF (x_cplv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute6 := l_cplv_rec.attribute6;
      END IF;
      IF (x_cplv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute7 := l_cplv_rec.attribute7;
      END IF;
      IF (x_cplv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute8 := l_cplv_rec.attribute8;
      END IF;
      IF (x_cplv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute9 := l_cplv_rec.attribute9;
      END IF;
      IF (x_cplv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute10 := l_cplv_rec.attribute10;
      END IF;
      IF (x_cplv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute11 := l_cplv_rec.attribute11;
      END IF;
      IF (x_cplv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute12 := l_cplv_rec.attribute12;
      END IF;
      IF (x_cplv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute13 := l_cplv_rec.attribute13;
      END IF;
      IF (x_cplv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute14 := l_cplv_rec.attribute14;
      END IF;
      IF (x_cplv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cplv_rec.attribute15 := l_cplv_rec.attribute15;
      END IF;
      IF (x_cplv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.created_by := l_cplv_rec.created_by;
      END IF;
      IF (x_cplv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cplv_rec.creation_date := l_cplv_rec.creation_date;
      END IF;
      IF (x_cplv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.last_updated_by := l_cplv_rec.last_updated_by;
      END IF;
      IF (x_cplv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cplv_rec.last_update_date := l_cplv_rec.last_update_date;
      END IF;
      IF (x_cplv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cplv_rec.last_update_login := l_cplv_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('12750: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cplv_rec IN  cplv_rec_type,
      x_cplv_rec OUT NOCOPY cplv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cplv_rec := p_cplv_rec;
      x_cplv_rec.OBJECT_VERSION_NUMBER := NVL(x_cplv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('12900: Entered update_row', 2);
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
      p_cplv_rec,                        -- IN
      l_cplv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cplv_rec, l_def_cplv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cplv_rec := fill_who_columns(l_def_cplv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cplv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cplv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cplv_rec, l_okc_k_party_roles_tl_rec);
    migrate(l_def_cplv_rec, l_cpl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_party_roles_tl_rec,
      lx_okc_k_party_roles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_k_party_roles_tl_rec, l_def_cplv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpl_rec,
      lx_cpl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cpl_rec, l_def_cplv_rec);
    x_cplv_rec := l_def_cplv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('13000: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13100: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('13200: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('13300: Exiting update_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL update_row for:CPLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('13400: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cplv_tbl.COUNT > 0) THEN
      i := p_cplv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cplv_rec                     => p_cplv_tbl(i),
          x_cplv_rec                     => x_cplv_tbl(i));
        EXIT WHEN (i = p_cplv_tbl.LAST);
        i := p_cplv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('13500: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('13700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('13800: Exiting update_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- delete_row for:OKC_K_PARTY_ROLES_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_rec                      IN cpl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpl_rec                      cpl_rec_type:= p_cpl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('13900: Entered delete_row', 2);
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
    DELETE FROM OKC_K_PARTY_ROLES_B
     WHERE ID = l_cpl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('14000: Leaving delete_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('14200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('14300: Exiting delete_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- delete_row for:OKC_K_PARTY_ROLES_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_party_roles_tl_rec     IN okc_k_party_roles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type:= p_okc_k_party_roles_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_PARTY_ROLES_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_party_roles_tl_rec IN  okc_k_party_roles_tl_rec_type,
      x_okc_k_party_roles_tl_rec OUT NOCOPY okc_k_party_roles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_okc_k_party_roles_tl_rec := p_okc_k_party_roles_tl_rec;
      x_okc_k_party_roles_tl_rec.LANGUAGE := okc_util.get_userenv_lang;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('14500: Entered delete_row', 2);
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
      p_okc_k_party_roles_tl_rec,        -- IN
      l_okc_k_party_roles_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_K_PARTY_ROLES_TL
     WHERE ID = l_okc_k_party_roles_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('14600: Leaving delete_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('14800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('14900: Exiting delete_row:OTHERS Exception', 2);
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
  -- delete_row for:OKC_K_PARTY_ROLES_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cplv_rec                     cplv_rec_type := p_cplv_rec;
    l_okc_k_party_roles_tl_rec     okc_k_party_roles_tl_rec_type;
    l_cpl_rec                      cpl_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('15000: Entered delete_row', 2);
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
    migrate(l_cplv_rec, l_okc_k_party_roles_tl_rec);
    migrate(l_cplv_rec, l_cpl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_party_roles_tl_rec
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
      l_cpl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('15100: Leaving delete_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('15300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('15400: Exiting delete_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL delete_row for:CPLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('15500: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cplv_tbl.COUNT > 0) THEN
      i := p_cplv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cplv_rec                     => p_cplv_tbl(i));
        EXIT WHEN (i = p_cplv_tbl.LAST);
        i := p_cplv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('15600: Leaving delete_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('15700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('15800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('15900: Exiting delete_row:OTHERS Exception', 2);
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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_K_PARTY_ROLES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_cplv_tbl cplv_tbl_type) IS
  l_tabsize NUMBER := p_cplv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_cpl_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_rle_code                      OKC_DATATYPES.Var30TabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
  in_cognomen                      OKC_DATATYPES.Var300TabTyp;
  in_code                          OKC_DATATYPES.Var30TabTyp;
  in_facility                      OKC_DATATYPES.Var30TabTyp;
  in_minority_group_lookup_code    OKC_DATATYPES.Var75TabTyp;
  in_small_business_flag           OKC_DATATYPES.Var3TabTyp;
  in_women_owned_flag              OKC_DATATYPES.Var3TabTyp;
  in_alias                         OKC_DATATYPES.Var150TabTyp;
  in_primary_yn                    OKC_DATATYPES.Var3TabTyp;
  in_cust_acct_id                  OKC_DATATYPES.Number15TabTyp;
  in_bill_to_site_use_id           OKC_DATATYPES.Number15TabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN

    -- Initializing return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('16000: Entered INSERT_ROW_UPG', 2);
    END IF;

  i := p_cplv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_cplv_tbl(i).id;
    in_object_version_number    (j) := p_cplv_tbl(i).object_version_number;
    in_sfwt_flag                (j) := p_cplv_tbl(i).sfwt_flag;
    in_cpl_id                   (j) := p_cplv_tbl(i).cpl_id;
    in_chr_id                   (j) := p_cplv_tbl(i).chr_id;
    in_cle_id                   (j) := p_cplv_tbl(i).cle_id;
    in_rle_code                 (j) := p_cplv_tbl(i).rle_code;
    in_dnz_chr_id               (j) := p_cplv_tbl(i).dnz_chr_id;
    in_object1_id1              (j) := p_cplv_tbl(i).object1_id1;
    in_object1_id2              (j) := p_cplv_tbl(i).object1_id2;
    in_jtot_object1_code        (j) := p_cplv_tbl(i).jtot_object1_code;
    in_cognomen                 (j) := p_cplv_tbl(i).cognomen;
    in_code                     (j) := p_cplv_tbl(i).code;
    in_facility                 (j) := p_cplv_tbl(i).facility;
    in_minority_group_lookup_code(j) := p_cplv_tbl(i).minority_group_lookup_code;
    in_small_business_flag      (j) := p_cplv_tbl(i).small_business_flag;
    in_women_owned_flag         (j) := p_cplv_tbl(i).women_owned_flag;
    in_alias                    (j) := p_cplv_tbl(i).alias;
    in_primary_yn               (j) := p_cplv_tbl(i).primary_yn;
    in_cust_acct_id             (j) := p_cplv_tbl(i).cust_acct_id;
    in_bill_to_site_use_id      (j) := p_cplv_tbl(i).bill_to_site_use_id;
    in_attribute_category       (j) := p_cplv_tbl(i).attribute_category;
    in_attribute1               (j) := p_cplv_tbl(i).attribute1;
    in_attribute2               (j) := p_cplv_tbl(i).attribute2;
    in_attribute3               (j) := p_cplv_tbl(i).attribute3;
    in_attribute4               (j) := p_cplv_tbl(i).attribute4;
    in_attribute5               (j) := p_cplv_tbl(i).attribute5;
    in_attribute6               (j) := p_cplv_tbl(i).attribute6;
    in_attribute7               (j) := p_cplv_tbl(i).attribute7;
    in_attribute8               (j) := p_cplv_tbl(i).attribute8;
    in_attribute9               (j) := p_cplv_tbl(i).attribute9;
    in_attribute10              (j) := p_cplv_tbl(i).attribute10;
    in_attribute11              (j) := p_cplv_tbl(i).attribute11;
    in_attribute12              (j) := p_cplv_tbl(i).attribute12;
    in_attribute13              (j) := p_cplv_tbl(i).attribute13;
    in_attribute14              (j) := p_cplv_tbl(i).attribute14;
    in_attribute15              (j) := p_cplv_tbl(i).attribute15;
    in_created_by               (j) := p_cplv_tbl(i).created_by;
    in_creation_date            (j) := p_cplv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_cplv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_cplv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_cplv_tbl(i).last_update_login;
    i:=p_cplv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_K_PARTY_ROLES_B
      (
        id,
        cpl_id,
        chr_id,
        cle_id,
        dnz_chr_id,
        rle_code,
        object1_id1,
        object1_id2,
        jtot_object1_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        code,
        facility,
        minority_group_lookup_code,
        small_business_flag,
        women_owned_flag,
        last_update_login,
	   primary_yn,
        cust_acct_id,
        bill_to_site_use_id,
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
        attribute15
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        in_cpl_id(i),
        in_chr_id(i),
        in_cle_id(i),
        in_dnz_chr_id(i),
        in_rle_code(i),
        in_object1_id1(i),
        in_object1_id2(i),
        in_jtot_object1_code(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_code(i),
        in_facility(i),
        in_minority_group_lookup_code(i),
        in_small_business_flag(i),
        in_women_owned_flag(i),
        in_last_update_login(i),
	   in_primary_yn(i),
	   in_cust_acct_id(i),
	   in_bill_to_site_use_id(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i)
-- REMOVE comma from the previous line
     );

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..l_tabsize
      INSERT INTO OKC_K_PARTY_ROLES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        cognomen,
        alias,
        last_update_login
-- REMOVE comma from the previous line
     )
     VALUES (
        in_id(i),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        in_sfwt_flag(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_cognomen(i),
        in_alias(i),
        in_last_update_login(i)
-- REMOVE comma from the previous line
      );
      END LOOP;

 IF (l_debug = 'Y') THEN
    okc_debug.log('16100: Leaving INSERT_ROW_UPG', 2);
    okc_debug.Reset_Indentation;
 END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('16200: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


--    RAISE;

END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('16300: Entered create_version', 2);
    END IF;

INSERT INTO okc_k_party_roles_bh
  (
      major_version,
      id,
      chr_id,
      cle_id,
      dnz_chr_id,
      rle_code,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      code,
      facility,
      minority_group_lookup_code,
      small_business_flag,
      women_owned_flag,
      last_update_login,
	 primary_yn,
      cust_acct_id,
      bill_to_site_use_id,
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
      cpl_id --,
-- R12 Data Model Changes 4485150 Start
    --  orig_system_id1,
    -- orig_system_reference1,
    --   orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
  SELECT
      p_major_version,
      id,
      chr_id,
      cle_id,
      dnz_chr_id,
      rle_code,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      code,
      facility,
      minority_group_lookup_code,
      small_business_flag,
      women_owned_flag,
      last_update_login,
	 primary_yn,
      cust_acct_id,
      bill_to_site_use_id,
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
      cpl_id --,
-- R12 Data Model Changes 4485150 Start
     -- orig_system_id1,
     --  orig_system_reference1,
     --  orig_system_source_code
-- R12 Data Model Changes 4485150 End

  FROM okc_k_party_roles_b
 WHERE dnz_chr_id = p_chr_id;

--------------------------------
-- Version TL Table
--------------------------------

INSERT INTO okc_k_party_roles_tlh
  (
      major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      cognomen,
      alias,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      language,
      source_lang,
      sfwt_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      cognomen,
      alias,
      last_update_login
  FROM okc_k_party_roles_tl
 WHERE id in (select id
			 from okc_k_party_roles_b
			where dnz_chr_id = p_chr_id);

IF (l_debug = 'Y') THEN
   okc_debug.log('16400: Leaving create_version', 2);
   okc_debug.Reset_Indentation;
END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('16500: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CPL_PVT');
       okc_debug.log('16600: Entered restore_version', 2);
    END IF;

INSERT INTO okc_k_party_roles_tl
  (
      id,
      language,
      source_lang,
      sfwt_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      cognomen,
      alias,
      last_update_login
)
  SELECT
      id,
      language,
      source_lang,
      sfwt_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      cognomen,
      alias,
      last_update_login
  FROM okc_k_party_roles_tlh
WHERE id in (SELECT id
			FROM okc_k_party_roles_bh
		    WHERE dnz_chr_id = p_chr_id)
  AND major_version = p_major_version;

----------------------------------------
-- Restoring Base Table
----------------------------------------

INSERT INTO okc_k_party_roles_b
  (
      id,
      chr_id,
      cle_id,
      dnz_chr_id,
      rle_code,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      code,
      facility,
      minority_group_lookup_code,
      small_business_flag,
      women_owned_flag,
      last_update_login,
	 primary_yn,
      cust_acct_id,
      bill_to_site_use_id,
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
      cpl_id --,
-- R12 Data Model Changes 4485150 Start
    /*  orig_system_id1,
      orig_system_reference1,
      orig_system_source_code */
-- R12 Data Model Changes 4485150 End
)
  SELECT
      id,
      chr_id,
      cle_id,
      dnz_chr_id,
      rle_code,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      code,
      facility,
      minority_group_lookup_code,
      small_business_flag,
      women_owned_flag,
      last_update_login,
	 primary_yn,
      cust_acct_id,
      bill_to_site_use_id,
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
      cpl_id --,
-- R12 Data Model Changes 4485150 Start
     /* orig_system_id1,
      orig_system_reference1,
      orig_system_source_code */
-- R12 Data Model Changes 4485150 End
  FROM okc_k_party_roles_bh
 WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('16700: Leaving restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('16800: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

END OKC_CPL_PVT;

/
